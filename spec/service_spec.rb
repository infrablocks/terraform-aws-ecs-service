require 'spec_helper'

describe 'ECS Service' do

  let(:component) { RSpec.configuration.component }
  let(:deployment_identifier) { RSpec.configuration.deployment_identifier }
  let(:vpc_id) { Terraform.output(name: 'vpc_id') }
  let(:private_network_cidr) { RSpec.configuration.private_network_cidr }


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
end
