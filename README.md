Terraform AWS ECS Service
=========================

[![CircleCI](https://circleci.com/gh/infrablocks/terraform-aws-ecs-service.svg?style=svg)](https://circleci.com/gh/infrablocks/terraform-aws-ecs-service)

A Terraform module for deploying an ECS service in AWS.

The ECS service requires:
* An existing VPC containing an ECS cluster
* A service role ARN allowing ECS to manage load balancers
* An ELB for the service
* A CloudWatch log group

The ECS service consists of:
* An ECS task definition for the containers making up the service
* An ECS service to maintain a number of instances of the task
* Log collection via the provided CloudWatch log group

![Diagram of infrastructure managed by this module](https://raw.githubusercontent.com/infrablocks/terraform-aws-ecs-service/main/docs/architecture.png)

Usage
-----

To use the module, include something like the following in your Terraform
configuration:

```hcl-terraform
module "ecs_service" {
  source = "infrablocks/ecs-service/aws"
  version = "2.0.0"

  vpc_id = "vpc-fb7dc365"

  component = "important-component"
  deployment_identifier = "production"

  service_name = "web-app"
  service_image = "images/web-app:0.3.1"
  service_port = "8000"
  service_command = "[\"node\", \"server.js\"]"

  service_desired_count = "3"
  service_deployment_maximum_percent = "50"
  service_deployment_minimum_healthy_percent = "200"

  service_elb_name = "elb-service-web-app"

  service_role = "arn:aws:iam::151388205202:role/service-task-role"

  service_volumes = [
    {
      name = "data"
    }
  ]

  ecs_cluster_id = "arn:aws:ecs:eu-west-2:151388205202:cluster/web-app"
  ecs_cluster_service_role_arn = "arn:aws:iam::151388205202:role/cluster-service-role-web-app"
}
```

By default, the module will use the provided region, log group, service name,
image, port and command to build a suitable task definition. Set `service_use_latest_task_definition = true` to use the latest active revision.

If further configuration of the task definition is required, provide the task
definition content using the var `service_task_definition`. In this case,
`service_image` and `service_command` need not be provided.

As mentioned above, the ECS service deploys into an existing base network and
ECS cluster using an existing ELB. Whilst these can be created using any
mechanism you like, the following modules may be of use:
* [AWS Base Networking](https://github.com/infrablocks/terraform-aws-base-networking)
* [AWS ECS Cluster](https://github.com/infrablocks/terraform-aws-ecs-cluster)
* [AWS ECS Load Balancer](https://github.com/infrablocks/terraform-aws-ecs-load-balancer)

See the
[Terraform registry entry](https://registry.terraform.io/modules/infrablocks/ecs-service/aws/latest)
for more details.

### Inputs

| Name                                       | Description                                                                  | Default                   | Required                                                                |
|--------------------------------------------|------------------------------------------------------------------------------|:-------------------------:|:-----------------------------------------------------------------------:|
| region                                     | The region into which to deploy the service                                  | -                         | yes                                                                     |
| vpc_id                                     | The ID of the VPC into which to deploy the service                           | -                         | yes                                                                     |
| component                                  | The component this service will contain                                      | -                         | yes                                                                     |
| deployment_identifier                      | An identifier for this instantiation                                         | -                         | yes                                                                     |
| service_task_container_definitions         | A template for the container definitions in the task                         | see container-definitions | no                                                                      |
| service_use_latest_task_definition         | if true use the latest ACTIVE revision of the task definition                | false                     | no                                                                      |
| service_name                               | The name of the service being created                                        | -                         | yes                                                                     |
| service_image                              | The docker image (including version) to deploy                               | -                         | no                                                                      |
| service_command                            | The command to run to start the container                                    | []                        | no                                                                      |
| service_port                               | The port the containers will be listening on                                 | -                         | yes                                                                     |
| service_task_network_mode                  | The network mode used for the containers in the task                         | bridge                    | yes                                                                     |
| service_desired_count                      | The desired number of tasks in the service                                   | 3                         | yes                                                                     |
| service_deployment_maximum_percent         | The maximum percentage of the desired count that can be running              | 200                       | yes                                                                     |
| service_deployment_minimum_healthy_percent | The minimum healthy percentage of the desired count to keep running          | 50                        | yes                                                                     |
| scheduling_strategy                        | The scheduling strategy to use for the service ("REPLICA" or "DAEMON")       | "REPLICA"                 | yes                                                                     |
| attach_to_load_balancer                    | Whether or not this service should attach to a load balancer ("yes" or "no") | "yes"                     | yes                                                                     |
| service_elb_name                           | The name of the ELB to configure to point at the service containers          | -                         | if attach_to_load_balancer is yes and target_group_arn is not specified |
| target_group_arn                           | The ARN of the ALB's target group to point at the service containers         | -                         | if attach_to_load_balancer is yes and service_elb_name is not specified |
| service_role                               | The ARN of the service task role to use                                      | No task role              | yes                                                                     |
| service_volumes                            | A list of volumes to make available to the containers in the service         | []                        | yes                                                                     |
| ecs_cluster_id                             | The ID of the ECS cluster in which to deploy the service                     | -                         | yes                                                                     |
| ecs_cluster_service_role_arn               | The ARN of the IAM role to provide to ECS to manage the service              | -                         | yes                                                                     |


### Outputs

| Name                | Description                                         |
|---------------------|-----------------------------------------------------|
| task_definition_arn | The ARN of the created ECS task definition          |
| log_group           | The name of the log group capturing all task output |

### Compatibility

This module is compatible with Terraform versions greater than or equal to
Terraform 1.0.

Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed
on your development machine:

* Ruby (3.1.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv
* aws-vault

#### Mac OS X Setup

Installing the required tools is best managed by [homebrew](http://brew.sh).

To install homebrew:

```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then, to install the required tools:

```
# ruby
brew install rbenv
brew install ruby-build
echo 'eval "$(rbenv init - bash)"' >> ~/.bash_profile
echo 'eval "$(rbenv init - zsh)"' >> ~/.zshrc
eval "$(rbenv init -)"
rbenv install 3.1.1
rbenv rehash
rbenv local 3.1.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# aws-vault
brew cask install

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

Running the build requires an AWS account and AWS credentials. You are free to
configure credentials however you like as long as an access key ID and secret
access key are available. These instructions utilise
[aws-vault](https://github.com/99designs/aws-vault) which makes credential
management easy and secure.

To provision module infrastructure, run tests and then destroy that
infrastructure, execute:

```bash
aws-vault exec <profile> -- ./go
```

To provision the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:provision[<deployment_identifier>]
```

To provision the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:provision[<deployment_identifier>]
```

To destroy the module contents:

```bash
aws-vault exec <profile> -- ./go deployment:root:destroy[<deployment_identifier>]
```

To destroy the module prerequisites:

```bash
aws-vault exec <profile> -- ./go deployment:prerequisites:destroy[<deployment_identifier>]
```

Configuration parameters can be overridden via environment variables:

```bash
DEPLOYMENT_IDENTIFIER=testing aws-vault exec <profile> -- ./go
```


### Common Tasks

#### Generating an SSH key pair

To generate an SSH key pair:

```
ssh-keygen -m PEM -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

#### Generating a self-signed certificate

To generate a self signed certificate:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

#### Managing CircleCI keys

To encrypt a GPG key for use by CircleCI:

```bash
openssl aes-256-cbc \
  -e \
  -md sha1 \
  -in ./config/secrets/ci/gpg.private \
  -out ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

To check decryption is working correctly:

```bash
openssl aes-256-cbc \
  -d \
  -md sha1 \
  -in ./.circleci/gpg.private.enc \
  -k "<passphrase>"
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at
https://github.com/infrablocks/terraform-aws-ecs-service. This project is
intended to be a safe, welcoming space for collaboration, and contributors are
expected to adhere to the
[Contributor Covenant](http://contributor-covenant.org) code of conduct.

License
-------

The library is available as open source under the terms of the
[MIT License](http://opensource.org/licenses/MIT).
