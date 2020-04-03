require 'spec_helper'

describe 'CloudWatch' do
  include_context :terraform

  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }
  let(:service_name) { vars.service_name }

  let(:log_group) {
    log_group_name_prefix =
        "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}"
    cloudwatch_logs_client
        .describe_log_groups(
            {log_group_name_prefix: log_group_name_prefix})
        .log_groups
        .first
  }

  context 'when told to create the log group' do
    before(:all) do
      reprovision(
          include_log_group: 'yes')
    end

    it 'creates log group' do
      expect(log_group).to_not be_nil
    end

    it 'outputs the log group name' do
      expect(
          "/#{component}/#{deployment_identifier}/ecs-service/#{service_name}")
          .to(eq(log_group.log_group_name))
    end
  end

  context 'when told not to create the log group' do
    before(:all) do
      reprovision(
          include_log_group: 'no')
    end

    it 'does not create the log group' do
      expect(log_group).to be_nil
    end

    it 'has an empty output' do
      expect(output_for(:harness, 'log_group')).to(eq(''))
    end
  end
end
