# Plan: fix `desired_count` drift and add optional autoscaling

## Problem

`aws_ecs_service.service` sets `desired_count = var.service_desired_count`
(`service.tf:5`). If a user enables Application Auto Scaling for the service
outside this module, every subsequent apply of the module resets the live task
count back to `service_desired_count`, undoing whatever scaling decision AWS
made.

There is no way to have Terraform leave the attribute alone by passing an empty
value: the provider schema for `aws_ecs_service.desired_count` is
`optional: true` and **not** `computed`, so `null` means "0 tasks", not "keep
whatever AWS has".

```
$ terraform providers schema -json | jq '...aws_ecs_service...desired_count'
{"type": "number", "description_kind": "plain", "optional": true}
```

The only fix is `lifecycle { ignore_changes = [desired_count] }`.

## Key constraint

`lifecycle` blocks take **static** values only — no variables, no ternaries. So
the ignore cannot be toggled by an `include_autoscaling` flag. The alternative,
two `aws_ecs_service` resources selected by `count`, means flipping the flag on
an existing service changes the resource address and Terraform destroys and
recreates the service. Not acceptable.

Therefore: **`desired_count` is ignored unconditionally**, for all users,
whether or not they use autoscaling. This is a breaking behaviour change and
needs a major version bump.

## Decisions

### 1. `service_desired_count` is renamed, not removed

It cannot be removed. `desired_count` is still required at create time — omit it
and the service is created with 0 tasks, and for users who do not enable
autoscaling nothing will ever bring it up. Even with autoscaling enabled,
relying on Application Auto Scaling to scale out to `min_capacity` after the
target registers leaves a window at zero and makes initial capacity a side
effect of registration ordering.

It is renamed to **`service_initial_desired_count`** rather than kept under the
old name with a new description. The reason is the failure mode on upgrade:

- Keeping the name: anyone who currently scales by bumping the variable gets a
  *silent* no-op. Plan shows nothing, count never changes.
- Renaming: Terraform fails at plan time with `An argument named
  "service_desired_count" is not expected here`, forcing them to read the
  changelog.

A major version is the right place to spend that breakage.

Note that the sibling module `terraform-aws-ecs-cluster` made the equivalent
change (`ignore_changes = [desired_capacity]` on its ASG) and *kept* its variable
name, `cluster_desired_capacity`. That is not a precedent against renaming here —
that change shipped in its 6.1.0, so renaming there now would be a fresh breaking
change that helps nobody already upgraded, whereas this module is taking a major
bump regardless and the rename rides along free. Different lifecycle point,
different answer. See `desired-capacity-drift-note.md` in that repo.

### 2. `service_min_capacity` is required when autoscaling is enabled

No default. Defaulting the floor to `service_initial_desired_count` would be the
same class of silent surprise this change is fixing — a capacity floor should be
stated, not inherited.

### 3. Autoscaling moves into the module, behind a flag

Not strictly required to fix the drift (the `ignore_changes` alone does that),
but it gives the module somewhere to clamp the initial count against the bounds,
and somewhere to hang optional target-tracking policies later.

## Changes

### `service.tf`

```hcl
resource "aws_ecs_service" "service" {
  # ...
  desired_count = var.include_autoscaling ? max(
    var.service_initial_desired_count, var.service_min_capacity
  ) : var.service_initial_desired_count

  lifecycle {
    ignore_changes = [desired_count]
  }
}
```

The clamp stops the initial count and the floor contradicting each other on
create.

### `variables.tf`

Rename:

| Old | New | Notes |
|-----|-----|-------|
| `service_desired_count` | `service_initial_desired_count` | Same type/default (`number`, `3`, `nullable = false`). Description must say the count is applied at creation only and is not enforced on subsequent applies. |

Add:

| Name | Type | Default | Notes |
|------|------|---------|-------|
| `include_autoscaling` | `bool` | `false` | Follows the existing `include_log_group` pattern. |
| `service_min_capacity` | `number` | `null` | Required when `include_autoscaling` is true. |
| `service_max_capacity` | `number` | `null` | Required when `include_autoscaling` is true. |

Both capacity variables default to `null` so their absence is detectable; add a
`validation` (or a `precondition` on the target resource) asserting they are
non-null when `include_autoscaling` is true, and that
`service_max_capacity >= service_min_capacity`.

### `autoscaling.tf` (new)

```hcl
resource "aws_appautoscaling_target" "service" {
  count = var.include_autoscaling ? 1 : 0

  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_id}/${aws_ecs_service.service.name}"
  scalable_dimension = "ecs:service:DesiredCount"

  min_capacity = var.service_min_capacity
  max_capacity = var.service_max_capacity
}
```

Note: `resource_id` needs the cluster *name*, not the full ARN.
`var.ecs_cluster_id` may be either — derive the name from it rather than
interpolating it raw.

Scaling policies (target tracking on CPU / memory / ALB request count) are
deliberately out of scope for this change. The target alone is enough to hold
the bounds and to make the module the owner of capacity.

### `outputs.tf`

Add `autoscaling_target_resource_id` so callers can attach their own scaling
policies without reconstructing the resource id. Follow the existing convention
in this file of returning `""` when the resource is absent.

### `README.md`

- Update the variable table: rename the `service_desired_count` row, add the
  three new rows.
- Update the example at line ~42.
- Add a note that the desired count is not managed after creation.

### `CHANGELOG.md`

New major section (6.0.0) with a `BACKWARDS INCOMPATIBILITIES / NOTES` block
covering:

- `service_desired_count` renamed to `service_initial_desired_count`.
- The service's `desired_count` is no longer managed after creation. To change
  the running count, use autoscaling or change it out of band.

and an `IMPROVEMENTS` block covering `include_autoscaling`,
`service_min_capacity`, `service_max_capacity`.

## Tests

Unit specs (`spec/unit/`), following the existing `plan(role: :root)` style:

- New `spec/unit/autoscaling_spec.rb`:
  - by default, creates no `aws_appautoscaling_target`
  - when `include_autoscaling` is true, creates one with the given min/max and a
    correctly formed `resource_id`
  - when `include_autoscaling` is true and min or max is omitted, the plan fails
  - when `service_max_capacity < service_min_capacity`, the plan fails
- `spec/unit/service_spec.rb`:
  - update existing `service_desired_count` references to the new name
  - `desired_count` is the initial count when autoscaling is off
  - `desired_count` is clamped up to `service_min_capacity` when autoscaling is
    on and the initial count is below the floor

`config/roles/` needs the new variables threaded through for the specs, and
`spec/integration/` should get a case that enables autoscaling and asserts the
target is registered.

## Migration for consumers

1. Rename `service_desired_count` to `service_initial_desired_count` at the call
   site.
2. First apply after upgrading shows no `desired_count` diff even if the live
   count differs from the configured value — this is expected.
3. To manage capacity going forward, set `include_autoscaling = true` with
   explicit `service_min_capacity` and `service_max_capacity`.

## Open questions

### Naming of the bounds — not yet decided

The plan above uses `service_min_capacity` / `service_max_capacity` throughout,
but that is a draft spelling, not a settled decision. The alternative is to match
`terraform-aws-ecs-cluster`, which uses `cluster_minimum_size` /
`cluster_maximum_size`.

- For `_min_capacity` / `_max_capacity`: these are the literal attribute names on
  `aws_appautoscaling_target`, so the variables map straight onto the resource,
  and "capacity" is the vocabulary ECS and Application Auto Scaling actually use.
  "Size" would be the odd word out against AWS's own terminology.
- For `_minimum_size` / `_maximum_size`: family consistency, and it avoids
  "capacity" meaning two different things in one root config — `ecs-cluster`
  already uses it for *instance* count, so a config composing both modules would
  have `cluster_desired_capacity` (machines) next to `service_min_capacity`
  (tasks).

Current lean is to keep `service_min_capacity` / `service_max_capacity`: matching
the underlying AWS attribute beats matching a sibling module describing a
different resource in a different service's terminology, and the `cluster_` /
`service_` prefixes already disambiguate. House-style call — settle before
implementing, since it touches every file in the Changes section.

### External autoscaling target

Whether `include_autoscaling` should also support attaching to an
externally-created `aws_appautoscaling_target` (i.e. accept a target resource id
instead of creating one), for users who already manage the target elsewhere and
only want the `ignore_changes` behaviour. They get that for free from this
change without setting the flag at all, so probably not needed — but worth
confirming before release.
