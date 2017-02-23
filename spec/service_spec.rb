require 'spec_helper'

describe 'ECS Service' do
  include_context :terraform

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:private_network_cidr) { RSpec.configuration.private_network_cidr }
  let(:service_name) { RSpec.configuration.service_name }
  let(:service_port) { RSpec.configuration.service_port }

  let(:vpc_id) { Terraform.output(name: 'vpc_id') }
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
      expect(subject.desired_count).to(eq(3))
    end

    it 'has the correct load balancer' do
      expect(subject.load_balancers.first.load_balancer_name).to(eq("elb-#{service_name}-#{component}-#{deployment_identifier}"))
      expect(subject.load_balancers.first.container_name).to(eq(service_name))
      expect(subject.load_balancers.first.container_port).to(eq(service_port))
    end

    it 'has the correct role' do
      expect(subject.role_arn).to(eq(service_role_arn))
    end
  end

  context 'elb' do
    subject {
      elb("elb-#{service_name}-#{component}-#{deployment_identifier}")
    }

    it { should exist }

    its(:health_check_target) { should eq("HTTP:#{service_port}/health")}
    its(:health_check_interval) { should eq(30)}
    its(:health_check_timeout) { should eq(3)}
    its(:health_check_unhealthy_threshold) { should eq(2)}
    its(:health_check_healthy_threshold) { should eq(2)}
  end

  context 'security group' do

    subject { security_group("elb-#{component}-#{deployment_identifier}") }

    it { should exist }
    its(:vpc_id) { should eq(vpc_id) }
    its(:description) { should eq("#{component}-elb") }

    it 'allows inbound TCP connectivity on all ports from any address within the Service' do
      expect(subject.inbound_rule_count).to(eq(1))

      ingress_rule = subject.ip_permissions.first

      expect(ingress_rule.from_port).to(eq(443))
      expect(ingress_rule.to_port).to(eq(443))
      expect(ingress_rule.ip_protocol).to(eq('tcp'))
      expect(ingress_rule.ip_ranges.map(&:cidr_ip)).to(eq([private_network_cidr]))
    end

    it 'allows outbound TCP connectivity on all ports and protocols anywhere' do
      expect(subject.outbound_rule_count).to(be(1))

      egress_rule = subject.ip_permissions_egress.first

      expect(egress_rule.from_port).to(eq(1))
      expect(egress_rule.to_port).to(eq(65535))
      expect(egress_rule.ip_protocol).to(eq('tcp'))
      expect(egress_rule.ip_ranges.map(&:cidr_ip)).to(eq([private_network_cidr]))
    end
  end

  context 'task definition' do

    subject { ecs_task_definition("#{service_name}-#{component}-#{deployment_identifier}") }

    it { should exist }
    its(:family) {should eq("#{service_name}-#{component}-#{deployment_identifier}")}

  end
end
