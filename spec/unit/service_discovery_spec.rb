# frozen_string_literal: true

require 'spec_helper'

describe 'service discovery' do
  let(:service_name) do
    var(role: :root, name: 'service_name')
  end
  let(:service_discovery_namespace_id) do
    output(role: :prerequisites, name: 'service_discovery_namespace_id')
  end

  describe 'by default' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
      end
    end

    it 'does not create a service discovery service' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_service_discovery_service'
                ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_create_registry is "no"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_create_registry = 'no'
      end
    end

    it 'does not create a service discovery service' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_service_discovery_service'
                ))
    end
  end

  describe 'when register_in_service_discovery is "no" and ' \
           'service_discovery_create_registry is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'no'
        vars.service_discovery_create_registry = 'yes'
      end
    end

    it 'does not create a service discovery service' do
      expect(@plan)
        .not_to(include_resource_creation(
                  type: 'aws_service_discovery_service'
                ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_create_registry is not provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_namespace_id =
          output(role: :prerequisites, name: 'service_discovery_namespace_id')
      end
    end

    it 'creates a service discovery service' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .once)
    end

    it 'uses the provided service name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(:name, service_name))
    end

    it 'uses the provided DNS namespace ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :namespace_id],
                service_discovery_namespace_id
              ))
    end

    it 'uses a TTL of 10 seconds in the DNS record config' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :dns_records, 0, :ttl], 10
              ))
    end

    it 'uses a record type of "SRV" in the DNS record config' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :dns_records, 0, :type], 'SRV'
              ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_create_registry is "yes"' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_create_registry = 'yes'
        vars.service_discovery_namespace_id =
          output(role: :prerequisites, name: 'service_discovery_namespace_id')
      end
    end

    it 'creates a service discovery service' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .once)
    end

    it 'uses the provided service name' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(:name, service_name))
    end

    it 'uses the provided DNS namespace ID' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :namespace_id],
                service_discovery_namespace_id
              ))
    end

    it 'uses a TTL of 10 seconds in the DNS record config' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :dns_records, 0, :ttl], 10
              ))
    end

    it 'uses a record type of "SRV" in the DNS record config' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :dns_records, 0, :type], 'SRV'
              ))
    end
  end

  describe 'when register_in_service_discovery is "yes" and ' \
           'service_discovery_record_type is provided' do
    before(:context) do
      @plan = plan(role: :root) do |vars|
        vars.service_elb_name =
          output(role: :prerequisites, name: 'load_balancer_name')
        vars.register_in_service_discovery = 'yes'
        vars.service_discovery_record_type = 'CNAME'
      end
    end

    it 'uses the provided record type in the DNS record config' do
      expect(@plan)
        .to(include_resource_creation(type: 'aws_service_discovery_service')
              .with_attribute_value(
                [:dns_config, 0, :dns_records, 0, :type], 'CNAME'
              ))
    end
  end
end
