## 5.1.0 (June 4th, 2026)

IMPROVEMENTS:

* This module now supports deploying services on AWS Fargate. Set the
  `use_fargate` variable to `true` to enable. When enabled, the task definition
  uses `awsvpc` network mode, requires the `FARGATE` compatibility, and the
  service launch type is set to `FARGATE`.
* The following variables have been added to support Fargate:
    - `service_task_cpu`
    - `service_task_memory`
    - `service_task_ephemeral_storage`
    - `service_task_operating_system_family`
    - `service_task_cpu_architecture`
    - `task_execution_role_arn`
* When using Fargate without supplying a `task_execution_role_arn`, the module
  now creates a default task execution role with ECR pull and CloudWatch logs
  permissions.

## 5.0.0 (November 4th, 2023)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 1.1 and higher.
* This module now requires at least Terraform AWS provider version 4.59 or 
  later.
* The `Environment` tag on the created log group has been renamed to
  `DeploymentIdentifier` for consistency with other resources.
* All variables previously using `"yes|no"` have been replaced with
  `true|false`.
* The following variables have had their default value replaced from `""` to
  `null`:
    - `service_role`
    - `service_discovery_container_name`
    - `service_discovery_container_port`

IMPROVEMENTS:

* An `always_use_latest_task_definition` variable has been added which, if true,
  forces the service to use the latest ACTIVE revision of the task definition
  even if that revision wasn't created by this module.
* This module now uses the nullable feature to simplify variable defaults.

## 4.0.0 (May 27th, 2021)

BACKWARDS INCOMPATIBILITIES / NOTES:

* This module is now compatible with Terraform 0.14 and higher.
