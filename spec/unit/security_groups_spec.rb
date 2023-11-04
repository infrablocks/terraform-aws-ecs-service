# frozen_string_literal: true

require 'spec_helper'

describe 'security groups' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:service_name) do
    var(role: :root, name: 'service_name')
  end
  let(:vpc_id) do
    output(role: :prerequisites, name: 'vpc_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'does not create a security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end

    it 'does not create any security group rules' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule'))
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

    it 'does not create a security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end

    it 'does not create any security group rules' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule'))
    end
  end

  describe 'when service_task_network_mode is "awsvpc" and ' \
           'associate_default_security_group is not provided and ' \
           'include_default_ingress_rule is not provided and ' \
           'include_default_egress_rule is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
      end
    end

    it 'creates a security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'derives the security group name from the component, ' \
       'deployment identifier and service name' do
      security_group_name =
        "#{component}-#{deployment_identifier}-#{service_name}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(:name, security_group_name))
    end

    it 'includes the component, deployment identifier and ' \
       'service name in the security group description' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :description,
                including(component)
                  .and(including(deployment_identifier))
                  .and(including(service_name))
              ))
    end

    it 'uses the provided VPC ID for the security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(:vpc_id, vpc_id))
    end

    it 'adds component and deployment identifier tags to the security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                )
              ))
    end

    it 'adds a service name tag to the security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags, a_hash_including(ServiceName: service_name)
              ))
    end

    it 'adds a name tag to the security group' do
      security_group_name =
        "#{component}-#{deployment_identifier}-#{service_name}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .with_attribute_value(
                :tags, a_hash_including(Name: security_group_name)
              ))
    end

    it 'creates an ingress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .once)
    end

    it 'allows all ports and protocols in the ingress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:protocol, '-1')
              .with_attribute_value(:from_port, 0)
              .with_attribute_value(:to_port, 0))
    end

    it 'allows ingress from "10.0.0.0/8" in the ingress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:cidr_blocks, ['10.0.0.0/8']))
    end

    it 'creates an egress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .once)
    end

    it 'allows all ports and protocols in the egress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:protocol, '-1')
              .with_attribute_value(:from_port, 0)
              .with_attribute_value(:to_port, 0))
    end

    it 'allows egress to "0.0.0.0/0" in the egress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:cidr_blocks, ['0.0.0.0/0']))
    end
  end

  describe 'when default_security_group_ingress_cidrs is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.default_security_group_ingress_cidrs = ['10.1.0.0/16']
      end
    end

    it 'allows ingress from the provided CIDR in the ingress ' \
       'security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .with_attribute_value(:cidr_blocks, ['10.1.0.0/16']))
    end
  end

  describe 'when default_security_group_egress_cidrs is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.default_security_group_egress_cidrs = ['10.0.0.0/8']
      end
    end

    it 'allows egress from the provided CIDR in the egress ' \
       'security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .with_attribute_value(:cidr_blocks, ['10.0.0.0/8']))
    end
  end

  describe 'when service_task_network_mode is "awsvpc" and ' \
           'associate_default_security_group is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.associate_default_security_group = false
      end
    end

    it 'does not create a security group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group'))
    end

    it 'does not create any security group rules' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule'))
    end
  end

  describe 'when service_task_network_mode is "awsvpc" and ' \
           'associate_default_security_group is true and' \
           'include_default_ingress_rule is not provided and ' \
           'include_default_egress_rule is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.associate_default_security_group = true
      end
    end

    it 'creates a security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'creates an ingress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .once)
    end

    it 'creates an egress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .once)
    end
  end

  describe 'when service_task_network_mode is "awsvpc" and ' \
           'associate_default_security_group is true and' \
           'include_default_ingress_rule is true and ' \
           'include_default_egress_rule is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.associate_default_security_group = true
        vars.include_default_ingress_rule = true
        vars.include_default_egress_rule = true
      end
    end

    it 'creates a security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'creates an ingress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress')
              .once)
    end

    it 'creates an egress security group rule' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress')
              .once)
    end
  end

  describe 'when service_task_network_mode is "awsvpc" and ' \
           'associate_default_security_group is true and' \
           'include_default_ingress_rule is false and ' \
           'include_default_egress_rule is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.service_task_network_mode = 'awsvpc'
        vars.associate_default_security_group = true
        vars.include_default_ingress_rule = false
        vars.include_default_egress_rule = false
      end
    end

    it 'creates a security group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_security_group')
              .once)
    end

    it 'does not create an ingress security group rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'ingress'))
    end

    it 'does not create an egress security group rule' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_security_group_rule')
              .with_attribute_value(:type, 'egress'))
    end
  end
end
