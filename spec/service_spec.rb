require 'spec_helper'

describe 'ECS Service' do
  include_context :terraform

  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:service_name) { vars.service_name }
  let(:service_port) { vars.service_port }

  let(:service_desired_count) { vars.service_desired_count }

  let(:service_deployment_maximum_percent) { vars.service_deployment_maximum_percent }
  let(:service_deployment_minimum_healthy_percent) { vars.service_deployment_minimum_healthy_percent }

  let(:service_task_network_mode) { vars.service_task_network_mode }

  let(:cluster_id) { output_with_name('cluster_id') }
  let(:task_definition_arn) { output_with_name('task_definition_arn') }
  let(:service_role_arn) { output_with_name('service_role_arn') }

  context 'service' do
    subject {
      ecs_client.describe_services(
          cluster: cluster_id,
          services: [service_name]).services.first
    }

    it 'exists' do
      expect(subject).not_to(be_nil)
    end

    it 'is associated with the correct task definition' do
      expect(subject.task_definition).to(eq(task_definition_arn))
    end

    it 'has the correct desired count' do
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

    it "uses a the supplied network mode" do
      expect(subject.network_mode).to(eq(service_task_network_mode))
    end

    context 'when no service role is specified' do
      before(:all) do
        reprovision(service_role: '')
      end

      its(:task_role_arn) { should be_nil }
    end

    context 'when a service role is specified' do
      before(:all) do
        reprovision(service_role: output_with_name('task_role_arn'))
      end

      its(:task_role_arn) { should eq(output_with_name('task_role_arn')) }
    end
  end
end
