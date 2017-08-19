require 'spec_helper'

describe 'CloudWatch' do
  include_context :terraform

  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }
  let(:service_name) { vars.service_name }

  let(:log_group) {
    cloudwatch_logs_client.describe_log_groups(
        {log_group_name_prefix: "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"}).log_groups.first }

  context 'logging' do
    it 'creates log group' do
      expect(log_group).to_not be_nil
    end
  end

  context 'outputs' do
    it 'outputs the log group name' do
      expect("/#{component}/#{deployment_identifier}/ecs-service/#{service_name}").to(eq(log_group.log_group_name))
    end
  end
end