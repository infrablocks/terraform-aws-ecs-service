# frozen_string_literal: true

require 'spec_helper'

describe 'service' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:service_name) do
    var(role: :root, name: 'service_name')
  end
  let(:service_port) do
    var(role: :root, name: 'service_port')
  end
  let(:service_elb_name) do
    output(role: :prerequisites, name: 'load_balancer_name')
  end
  let(:ecs_cluster_id) do
    output(role: :prerequisites, name: 'cluster_id')
  end
  let(:ecs_cluster_service_role_arn) do
    output(role: :prerequisites, name: 'service_role_arn')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'creates an ECS service' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .once)
    end

    it 'uses the provided service name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:name, service_name))
    end

    it 'uses the provided ECS cluster' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:cluster, ecs_cluster_id))
    end

    it 'uses a service desired count of 3' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:desired_count, 3))
    end

    it 'uses the provided ECS cluster service role ARN as the IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:iam_role, ecs_cluster_service_role_arn))
    end

    it 'uses a deployment maximum percent of 200' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:deployment_maximum_percent, 200))
    end

    it 'uses a deployment minimum healthy percent of 50' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:deployment_minimum_healthy_percent, 50))
    end

    it 'uses a health check grace period of 0 seconds' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:health_check_grace_period_seconds, 0))
    end

    it 'uses a scheduling strategy of "REPLICA"' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:scheduling_strategy, 'REPLICA'))
    end

    it 'does not force a new deployment' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:force_new_deployment, false))
    end

    it 'does not configure VPC networking' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:network_configuration, a_nil_value))
    end

    it 'does not configure placement constraints' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:placement_constraints, a_nil_value))
    end

    it 'does not configure service registries' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:service_registries, a_nil_value))
    end

    it 'configures a load balancer using the provided load balancer details' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:load_balancer, 0, :elb_name], service_elb_name
              ))
    end
  end

  describe 'when service_desired_count is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_desired_count = 5
      end
    end

    it 'uses the provided desired count' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:desired_count, 5))
    end
  end

  describe 'when service_deployment_maximum_percent is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_deployment_maximum_percent = 300
      end
    end

    it 'uses the provided deployment maximum percent' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:deployment_maximum_percent, 300))
    end
  end

  describe 'when service_deployment_minimum_healthy_percent is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_deployment_minimum_healthy_percent = 100
      end
    end

    it 'uses the provided deployment minimum healthy percent' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:deployment_minimum_healthy_percent, 100))
    end
  end

  describe 'when service_health_check_grace_period_seconds is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_health_check_grace_period_seconds = 15
      end
    end

    it 'uses the provided health check grace period' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:health_check_grace_period_seconds, 15))
    end
  end

  describe 'when scheduling_strategy is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.scheduling_strategy = 'DAEMON'
      end
    end

    it 'uses the provided scheduling strategy' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:scheduling_strategy, 'DAEMON'))
    end
  end

  describe 'when force_new_deployment is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.force_new_deployment = 'yes'
      end
    end

    it 'forces a new deployment on apply' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:force_new_deployment, true))
    end
  end

  describe 'when force_new_deployment is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.force_new_deployment = 'no'
      end
    end

    it 'does not force a new deployment on apply' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:force_new_deployment, false))
    end
  end

  describe 'when attach_to_load_balancer is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.attach_to_load_balancer = 'no'
      end
    end

    it 'does not set an IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:iam_role, a_nil_value))
    end

    it 'does not set the health check grace period' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                :health_check_grace_period_seconds, a_nil_value
              ))
    end

    it 'does not configure a load balancer' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:load_balancer, a_nil_value))
    end
  end

  describe 'when attach_to_load_balancer is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.attach_to_load_balancer = 'yes'
      end
    end

    it 'uses the provided ECS cluster service role ARN as the IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:iam_role, ecs_cluster_service_role_arn))
    end

    it 'sets the health check grace period' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:health_check_grace_period_seconds, 0))
    end
  end

  describe 'when attach_to_load_balancer is "yes" and only ' \
           'service_elb_name is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.attach_to_load_balancer = 'yes'
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'configures a load balancer using the provided ELB' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:load_balancer, 0],
                a_hash_including(
                  elb_name: service_elb_name,
                  target_group_arn: ''
                )
              ))
    end
  end

  describe 'when attach_to_load_balancer is "yes" and both ' \
           'service_elb_name and target_group_arn are provided' do
    let(:target_group_arn) do
      output(role: :prerequisites, name: 'target_group_arn')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.attach_to_load_balancer = 'yes'
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.target_group_arn =
          output(role: :prerequisites, name: 'target_group_arn')
      end
    end

    it 'configures a load balancer using the provided target group ARN' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:load_balancer, 0],
                a_hash_including(
                  elb_name: '',
                  target_group_arn:
                )
              ))
    end
  end

  describe 'when attach_to_load_balancer is "yes" and ' \
           'target_container_name and target_port are not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.attach_to_load_balancer = 'yes'
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'configures a load balancer using the service name and port as the ' \
       'load balancer container name and port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:load_balancer, 0],
                a_hash_including(
                  container_name: service_name,
                  container_port: service_port.to_i
                )
              ))
    end
  end

  describe 'when attach_to_load_balancer is "yes" and ' \
           'target_container_name and target_port are provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.attach_to_load_balancer = 'yes'
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.target_container_name = 'some-service-name'
        vars.target_port = 9009
      end
    end

    it 'configures a load balancer using the target container name and ' \
       'target port as the load balancer container name and port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:load_balancer, 0],
                a_hash_including(
                  container_name: 'some-service-name',
                  container_port: 9009
                )
              ))
    end
  end

  describe 'when service_task_network_mode is "awsvpc"' do
    let(:subnet_ids) do
      output(role: :prerequisites, name: 'private_subnet_ids')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.subnet_ids =
          output(role: :prerequisites, name: 'private_subnet_ids')
      end
    end

    it 'does not set an IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:iam_role, a_nil_value))
    end

    it 'configures VPC networking using the provided subnets' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:network_configuration, 0, :subnets],
                containing_exactly(*subnet_ids)
              ))
    end
  end

  describe 'when service_task_network_mode is not "awsvpc"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'bridge'
      end
    end

    it 'uses the provided ECS cluster service role ARN as the IAM role' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:iam_role, ecs_cluster_service_role_arn))
    end

    it 'does not configure VPC networking' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:network_configuration, a_nil_value))
    end
  end

  describe 'when placement_constraints are provided' do
    before(:context) do
      @type = 'memberOf'
      @expression =
        'attribute:ecs.availability-zone in [eu-west-2a, eu-west-2b]'
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.placement_constraints = [
          {
            type: @type,
            expression: @expression
          }
        ]
      end
    end

    it 'configures the placement constraints on the service' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                :placement_constraints,
                containing_exactly(
                  a_hash_including(
                    type: @type,
                    expression: @expression
                  )
                )
              ))
    end
  end

  describe 'when placement_constraints is empty' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.placement_constraints = []
      end
    end

    it 'does not configure placement constraints' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:placement_constraints, a_nil_value))
    end
  end

  describe 'when register_in_service_discovery is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'no'
      end
    end

    it 'does not configure a service registry' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(:service_registries, a_nil_value))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_record_type, ' \
           'service_discovery_container_name and ' \
           'service_discovery_container_port are not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
      end
    end

    it 'configures a service registry with the service name and port as the ' \
       'container name and port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:service_registries, 0],
                a_hash_including(
                  container_name: service_name,
                  container_port: service_port.to_i
                )
              ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_container_name and ' \
           'service_discovery_container_port are provided and ' \
           'service_discovery_record_type is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_container_name = 'some-service-name'
        vars.service_discovery_container_port = 9009
      end
    end

    it 'configures a service registry with the provided container name ' \
       'and port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:service_registries, 0],
                a_hash_including(
                  container_name: 'some-service-name',
                  container_port: 9009
                )
              ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_record_type is not "SRV"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_record_type = 'CNAME'
      end
    end

    it 'configures a service registry with no container name ' \
       'and port' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:service_registries, 0],
                a_hash_including(
                  container_name: a_nil_value,
                  container_port: a_nil_value
                )
              ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_create_registry is "no"' do
    let(:service_discovery_registry_arn) do
      output(role: :prerequisites, name: 'service_discovery_registry_arn')
    end

    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_create_registry = 'no'
        vars.service_discovery_registry_arn =
          output(role: :prerequisites, name: 'service_discovery_registry_arn')
      end
    end

    it 'configures a service registry using the provided registry ARN' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_ecs_service')
              .with_attribute_value(
                [:service_registries, 0],
                a_hash_including(
                  registry_arn: service_discovery_registry_arn
                )
              ))
    end
  end
end
