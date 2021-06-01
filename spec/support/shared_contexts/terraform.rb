# frozen_string_literal: true

require 'aws-sdk'
require 'awspec'
require 'ostruct'

require_relative '../terraform_module'

shared_context :terraform do
  include Awspec::Helper::Finder

  let(:cloudwatch_logs_client) { Aws::CloudWatchLogs::Client.new }
  let(:service_discovery_client) { Aws::ServiceDiscovery::Client.new }

  let(:vars) do
    OpenStruct.new(
      TerraformModule.configuration
      .for(:harness)
      .vars
    )
  end

  def configuration
    TerraformModule.configuration
  end

  def output_for(role, name)
    TerraformModule.output_for(role, name)
  end

  def provision(overrides = nil)
    TerraformModule.provision_for(
      :harness,
      TerraformModule.configuration.for(:harness, overrides).vars
    )
  end

  def destroy(overrides = nil)
    TerraformModule.destroy_for(
        :harness,
        TerraformModule.configuration.for(:harness, overrides).vars,
        force: true)
  end

  def reprovision(overrides = nil)
    destroy(overrides)
    sleep(5)
    provision(overrides)
  end
end
