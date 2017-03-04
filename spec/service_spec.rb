require 'spec_helper'

describe 'ECS Service' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }

  let(:service_name) { RSpec.configuration.service_name }
  let(:service_port) { RSpec.configuration.service_port }

  let(:service_desired_count) { RSpec.configuration.service_desired_count }

  let(:service_deployment_maximum_percent) { RSpec.configuration.service_deployment_maximum_percent }
  let(:service_deployment_minimum_healthy_percent) { RSpec.configuration.service_deployment_minimum_healthy_percent }

  let(:cluster_id) { Terraform.output(name: 'cluster_id') }
  let(:task_definition_arn) { Terraform.output(name: 'task_definition_arn') }
  let(:service_role_arn) { Terraform.output(name: 'service_role_arn') }

  context 'service' do
    subject {
      ecs_client.describe_services(
          cluster: cluster_id,
          services: [service_name]).services.first
    }

    it 'exists' do
      expect(subject).not_to(be_nil)
    end

    it "is associated with the correct task definition" do
      expect(subject.task_definition).to(eq(task_definition_arn))
    end

    it "has the correct desired count" do
      expect(subject.desired_count).to(eq(service_desired_count))
    end

    it 'has the correct load balancer' do
      expect(subject.load_balancers.first.load_balancer_name).to(eq("elb-#{service_name}-#{component}-#{deployment_identifier}"))
      expect(subject.load_balancers.first.container_name).to(eq(service_name))
      expect(subject.load_balancers.first.container_port).to(eq(service_port))
    end

    it 'has the correct role' do
      expect(subject.role_arn).to(eq(service_role_arn))
    end

    it 'defines the deployment maximum percent' do
      expect(subject.deployment_configuration.maximum_percent)
          .to(eq(service_deployment_maximum_percent))
    end

    it 'defines the deployment minimum healthy percent' do
      expect(subject.deployment_configuration.minimum_healthy_percent)
          .to(eq(service_deployment_minimum_healthy_percent))
    end
  end

  context 'task definition' do
    subject { ecs_task_definition("#{service_name}-#{component}-#{deployment_identifier}") }

    it { should exist }
    its(:family) { should eq("#{service_name}-#{component}-#{deployment_identifier}") }
  end
end
