# frozen_string_literal: true

require 'spec_helper'

describe 'log group' do
  let(:component) do
    var(role: :root, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :root, name: 'deployment_identifier')
  end
  let(:service_name) do
    var(role: :root, name: 'service_name')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'creates log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .once)
    end

    it 'derives the log group name from the component, deployment ' \
       'identifier and service name' do
      log_group_name =
        "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:name, log_group_name))
    end

    it 'has infinite retention on the log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:retention_in_days, 0))
    end

    it 'includes component and deployment identifier tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                )
              ))
    end

    it 'includes a service tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(
                :tags, a_hash_including(Service: service_name)
              ))
    end
  end

  describe 'when log_group_retention is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.log_group_retention = 14
      end
    end

    it 'uses the provided log group retention' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:retention_in_days, 14))
    end
  end

  describe 'when include_log_group is false' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.include_log_group = false
      end
    end

    it 'does not create a log group' do
      expect(@plan)
        .not_to(include_resource_creation(type: 'aws_cloudwatch_log_group'))
    end
  end

  describe 'when include_log_group is true' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.include_log_group = true
      end
    end

    it 'creates log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .once)
    end

    it 'derives the log group name from the component, deployment ' \
       'identifier and service name' do
      log_group_name =
        "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:name, log_group_name))
    end

    it 'has infinite retention on the log group' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(:retention_in_days, 0))
    end

    it 'includes component and deployment identifier tags' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(
                :tags,
                a_hash_including(
                  Component: component,
                  DeploymentIdentifier: deployment_identifier
                )
              ))
    end

    it 'includes a service tag' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_cloudwatch_log_group')
              .with_attribute_value(
                :tags, a_hash_including(Service: service_name)
              ))
    end
  end
end
