# frozen_string_literal: true

require 'spec_helper'

describe 'CloudWatch' do
  # let(:component) do
  #   var(role: :root, name: 'component')
  # end
  # let(:deployment_identifier) do
  #   var(role: :root, name: 'deployment_identifier')
  # end
  # let(:service_name) do
  #   var(role: :root, name: 'service_name')
  # end

  # let(:log_group) {
  #   log_group_name_prefix =
  #       "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
  #   cloudwatch_logs_client
  #       .describe_log_groups(
  #           {log_group_name_prefix: log_group_name_prefix})
  #       .log_groups
  #       .first
  # }

  describe 'when include_log_group is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.include_log_group = 'yes'
      end
    end

    it 'creates log group' do
      expect(@plan)
        .to(include_resource_creation(name: 'include_log_group'))
    end

    # it 'outputs the log group name' do
    #   expect(
    #       "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}")
    #       .to(eq(log_group.log_group_name))
    # end
  end

  # context 'when told to create the log group with retention' do
  #   before(:all) do
  #     reprovision(
  #       include_log_group: 'yes',
  #       log_group_retention: 30)
  #   end
  #
  #   it 'creates log group' do
  #     expect(log_group).to_not be_nil
  #   end
  #
  #   it 'outputs the log group name' do
  #     expect(
  #       "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}")
  #       .to(eq(log_group.log_group_name))
  #   end
  #
  #   it 'has a retention of 30 days' do
  #     expect(
  #       log_group.retention_in_days)
  #       .to(eq(30))
  #   end
  # end
  #
  # context 'when told not to create the log group' do
  #   before(:all) do
  #     reprovision(
  #         include_log_group: 'no',
  #         service_task_container_definitions:
  #             File.read('spec/fixtures/no_logs_service.json.tpl'))
  #   end
  #
  #   it 'does not create the log group' do
  #     expect(log_group).to be_nil
  #   end
  # end
end
