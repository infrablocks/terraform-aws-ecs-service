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
