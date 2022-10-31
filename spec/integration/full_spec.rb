# frozen_string_literal: true

require 'spec_helper'

describe 'full' do
  let(:component) do
    var(role: :basic, name: 'component')
  end
  let(:deployment_identifier) do
    var(role: :basic, name: 'deployment_identifier')
  end

  let(:service_name) { 'web-proxy' }
  let(:service_port) { 80 }

  let(:cluster_id) do
    output(role: :basic, name: 'cluster_id')
  end
  let(:service_role_arn) do
    output(role: :basic, name: 'service_role_arn')
  end
  let(:task_definition_arn) do
    output(role: :basic, name: 'task_definition_arn')
  end
  let(:load_balancer_name) do
    output(role: :basic, name: 'load_balancer_name')
  end

  before(:context) do
    apply(role: :basic)
  end

  after(:context) do
    destroy(
      role: :basic,
      only_if: -> { !ENV['FORCE_DESTROY'].nil? || ENV['SEED'].nil? }
    )
  end

  describe 'service' do
    subject(:ecs_service) do
      ecs_client.describe_services(
        cluster: cluster_id,
        services: [service_name]
      ).services.first
    end

    it 'exists' do
      expect(ecs_service).not_to(be_nil)
    end

    it 'is associated with the correct task definition' do
      expect(ecs_service.task_definition).to(eq(task_definition_arn))
    end

    it 'has a desired count of 3' do
      expect(ecs_service.desired_count).to(eq(3))
    end

    it 'has a deployment maximum percent of 200' do
      expect(ecs_service.deployment_configuration.maximum_percent)
        .to(eq(200))
    end

    it 'has a deployment minimum healthy percent of 50' do
      expect(ecs_service.deployment_configuration.minimum_healthy_percent)
        .to(eq(50))
    end

    it 'deploys the service using "REPLICA" scheduling strategy' do
      expect(ecs_service.scheduling_strategy)
        .to(eq('REPLICA'))
    end

    # rubocop:disable RSpec/MultipleExpectations
    it 'has the correct load balancer' do
      expect(ecs_service.load_balancers.first.load_balancer_name)
        .to(eq(load_balancer_name))
      expect(ecs_service.load_balancers.first.target_group_arn)
        .to(be_nil)
      expect(ecs_service.load_balancers.first.container_name)
        .to(eq(service_name))
      expect(ecs_service.load_balancers.first.container_port)
        .to(eq(service_port))
    end
    # rubocop:enable RSpec/MultipleExpectations

    it 'has the correct role' do
      expect(ecs_service.role_arn).to(eq(service_role_arn))
    end

    it 'sets the health check grace period to 0' do
      expect(ecs_service.health_check_grace_period_seconds)
        .to(eq(0))
    end
  end

  describe 'task definition' do
    subject(:task_definition) do
      ecs_task_definition(
        "#{component}-#{service_name}-#{deployment_identifier}"
      )
    end

    it { is_expected.to exist }

    its(:task_role_arn) { is_expected.to be_nil }

    its(:family) do
      is_expected
        .to(eq("#{component}-#{service_name}-#{deployment_identifier}"))
    end

    it 'uses "bridge" network mode' do
      expect(task_definition.network_mode).to(eq('bridge'))
    end

    it 'does not set a PID mode' do
      expect(task_definition.pid_mode).to(be_nil)
    end
  end

  describe 'log group' do
    let(:log_group) do
      log_group_name_prefix =
        "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
      cloudwatch_logs_client
        .describe_log_groups(
          { log_group_name_prefix: }
        )
        .log_groups
        .first
    end

    it 'creates log group' do
      expect(log_group).not_to(be_nil)
    end

    it 'outputs the log group name' do
      expected_log_group_name =
        "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
      expect(log_group.log_group_name)
        .to(eq(expected_log_group_name))
    end
  end
end
