Terraform AWS ECS Service
=========================

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

![Diagram of infrastructure managed by this module](/docs/architecture.png?raw=true)

Usage
-----

To use the module, include something like the following in your terraform
configuration:

```hcl-terraform
module "ecs_cluster" {
  source = "git@github.com:tobyclemson/terraform-aws-ecs-service.git//src"
  
  region = "eu-west-2"
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
  
  ecs_cluster_id = "arn:aws:ecs:eu-west-2:151388205202:cluster/web-app"
  ecs_cluster_service_role_arn = "arn:aws:iam::151388205202:role/cluster-service-role-web-app"
  ecs_cluster_log_group = "/web-app"
}
```

By default, the module will use the provided region, log group, service name, 
image, port and command to build a suitable task definition.

If further configuration of the task definition is required, provide the task
definition content using the var `service_task_definition`. In this case, 
`service_image` and `service_command` need not be provided.

As mentioned above, the ECS service deploys into an existing base network and
ECS cluster using an existing ELB. Whilst these can be created using any 
mechanism you like, the following modules may be of use: 
* [AWS Base Networking](https://github.com/tobyclemson/terraform-aws-base-networking)
* [AWS ECS Cluster](https://github.com/tobyclemson/terraform-aws-ecs-cluster)
* [AWS ECS Load Balancer](https://github.com/tobyclemson/terraform-aws-ecs-load-balancer)


### Inputs

| Name                                       | Description                                                         | Default            | Required |
|--------------------------------------------|---------------------------------------------------------------------|:------------------:|:--------:|
| region                                     | The region into which to deploy the service                         | -                  | yes      |
| vpc_id                                     | The ID of the VPC into which to deploy the service                  | -                  | yes      |
| component                                  | The component this service will contain                             | -                  | yes      |
| deployment_identifier                      | An identifier for this instantiation                                | -                  | yes      |
| service_name                               | The name of the service being created                               | -                  | yes      |
| service_image                              | The docker image (including version) to deploy                      | -                  | no       |
| service_port                               | The port the containers will be listening on                        | -                  | yes      |
| service_command                            | The command to run to start the container                           | []                 | no       |
| service_desired_count                      | The number of container instances to aim for                        | 3                  | yes      |
| service_deployment_maximum_percent         | The maximum percentage of the desired count that can be running     | 200                | yes      |
| service_deployment_minimum_healthy_percent | The minimum healthy percentage of the desired count to keep running | see src/policies   | no       |
| service_elb_name                           | The name of the ELB to configure to point at the service instances  | -                  | yes      |
| ecs_cluster_id                             | The ID of the ECS cluster in which to deploy the service            | -                  | yes      |
| ecs_cluster_service_role_arn               | The ARN of the IAM role to provide to ECS to manage the service     | -                  | yes      |
| ecs_cluster_log_group                      | The log group to use to collect service logs                        | -                  | yes      |

### Outputs

| Name                      | Description                                                          |
|---------------------------|----------------------------------------------------------------------|
| task_definition_arn       | The ARN of the created ECS task definition                           |


Development
-----------

### Machine Requirements

In order for the build to run correctly, a few tools will need to be installed on your
development machine:

* Ruby (2.3.1)
* Bundler
* git
* git-crypt
* gnupg
* direnv

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
rbenv install 2.3.1
rbenv rehash
rbenv local 2.3.1
gem install bundler

# git, git-crypt, gnupg
brew install git
brew install git-crypt
brew install gnupg

# direnv
brew install direnv
echo "$(direnv hook bash)" >> ~/.bash_profile
echo "$(direnv hook zsh)" >> ~/.zshrc
eval "$(direnv hook $SHELL)"

direnv allow <repository-directory>
```

### Running the build

To provision module infrastructure, run tests and then destroy that infrastructure,
execute:

```bash
./go
```

To provision the module test contents:

```bash
./go provision:aws[<deployment_identifier>]
```

To destroy the module test contents:

```bash
./go destroy:aws[<deployment_identifier>]
```

### Common Tasks

To generate an SSH key pair:

```
ssh-keygen -t rsa -b 4096 -C integration-test@example.com -N '' -f config/secrets/keys/bastion/ssh
```

To generate a self signed certificate:
```
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365
```

To decrypt the resulting key:

```
openssl rsa -in key.pem -out ssl.key
```

Contributing
------------

Bug reports and pull requests are welcome on GitHub at https://github.com/tobyclemson/terraform-aws-ecs-cluster. 
This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to 
the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


License
-------

The library is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
