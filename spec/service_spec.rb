require 'spec_helper'

describe 'ECS Service' do
  include_context :terraform

  let(:component) { vars.component }
  let(:deployment_identifier) { vars.deployment_identifier }

  let(:service_name) { vars.service_name }
  let(:service_port) { vars.service_port.to_i }

  let(:service_desired_count) { vars.service_desired_count.to_i }

  let(:service_deployment_maximum_percent) {
    vars.service_deployment_maximum_percent.to_i
  }
  let(:service_deployment_minimum_healthy_percent) {
    vars.service_deployment_minimum_healthy_percent.to_i
  }

  let(:service_task_network_mode) { vars.service_task_network_mode }
  let(:service_task_pid_mode) { vars.service_task_pid_mode }

  let(:scheduling_strategy) { vars.scheduling_strategy }

  let(:placement_constraint_type) {
    configuration.for(:harness).placement_constraint_type
  }
  let(:placement_constraint_expression) {
    configuration.for(:harness).placement_constraint_expression
  }

  let(:cluster_id) { output_for(:prerequisites, 'cluster_id') }
  let(:task_definition_arn) { output_for(:harness, 'task_definition_arn') }
  let(:service_role_arn) { output_for(:prerequisites, 'service_role_arn') }
  let(:load_balancer_name) { output_for(:prerequisites, 'load_balancer_name') }
  let(:target_group_arn) { output_for(:prerequisites, 'target_group_arn') }

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

    it 'defines the deployment maximum percent' do
      expect(subject.deployment_configuration.maximum_percent)
          .to(eq(service_deployment_maximum_percent))
    end

    it 'defines the deployment minimum healthy percent' do
      expect(subject.deployment_configuration.minimum_healthy_percent)
          .to(eq(service_deployment_minimum_healthy_percent))
    end

    it 'defines the deployment minimum healthy percent' do
      expect(subject.scheduling_strategy)
          .to(eq(scheduling_strategy))
    end

    it 'uses the supplied placement constraint' do
      expect(subject.placement_constraints.length).to(eq(1))
      expect(subject.placement_constraints.first.type)
          .to(eq(placement_constraint_type))
      expect(subject.placement_constraints.first.expression)
          .to(eq(placement_constraint_expression))
    end

    context 'network configuration (for awsvpc network mode)' do
      context 'when using default security group' do
        let(:service_name) { 'service-with-awsvpc' }

        before(:all) do
          reprovision(
              service_name: 'service-with-awsvpc',
              service_task_network_mode: 'awsvpc',
              associate_default_security_group: "yes",
              default_security_group_ingress_cidrs: ["10.0.0.0/16"],
              default_security_group_egress_cidrs: ["10.0.0.0/16"])
        end

        let(:service) {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }
        let(:security_groups) {
          service
              .network_configuration
              .awsvpc_configuration
              .security_groups
              .map { |sg| security_group(sg) }
        }

        it('associates a security group allowing inbound TCP and UDP ' +
            'for all ports for the supplied ingress CIDRs') do
          expect(security_groups.length).to(eq(1))

          security_group = security_groups.first

          expect(security_group.inbound_rule_count).to(eq(1))

          ingress_rule = security_group.ip_permissions.first

          expect(ingress_rule.from_port).to(be_nil)
          expect(ingress_rule.to_port).to(be_nil)
          expect(ingress_rule.ip_protocol).to(eq('-1'))
          expect(ingress_rule.ip_ranges.map(&:cidr_ip))
              .to(eq(["10.0.0.0/16"]))
        end

        it('associates a security group allowing outbound TCP and UDP ' +
            'for all ports for the supplied egress CIDRs') do
          expect(security_groups.length).to(eq(1))

          security_group = security_groups.first

          expect(security_group.outbound_rule_count).to(eq(1))

          egress_rule = security_group.ip_permissions_egress.first

          expect(egress_rule.from_port).to(be_nil)
          expect(egress_rule.to_port).to(be_nil)
          expect(egress_rule.ip_protocol).to(eq('-1'))
          expect(egress_rule.ip_ranges.map(&:cidr_ip))
              .to(eq(["10.0.0.0/16"]))
        end
      end
    end

    context 'load balancer configuration' do
      context 'when asked not to attach to a load balancer' do
        let(:service_name) { 'service-without-lb' }

        before(:all) do
          reprovision(
              service_name: 'service-without-lb',
              attach_to_load_balancer: 'no')
        end

        subject {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }

        it 'has a service with no load balancer configured' do
          expect(subject.load_balancers).to(be_empty)
        end
      end

      context 'when asked to attach to a classic load balancer' do
        let(:service_name) { 'service-with-elb' }

        before(:all) do
          reprovision(
              service_name: 'service-with-elb',
              attach_to_load_balancer: 'yes',
              service_elb_name:
                  output_for(:prerequisites, 'load_balancer_name'))
        end

        subject {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }

        it 'has the correct load balancer' do
          expect(subject.load_balancers.first.load_balancer_name)
              .to(eq(output_for(:prerequisites, 'load_balancer_name')))
          expect(subject.load_balancers.first.target_group_arn)
              .to(be_nil)
          expect(subject.load_balancers.first.container_name)
              .to(eq(service_name))
          expect(subject.load_balancers.first.container_port)
              .to(eq(service_port))
        end

        it 'has the correct role' do
          expect(subject.role_arn).to(eq(service_role_arn))
        end
      end

      context 'when asked to attach to an application load balancer' do
        let(:service_name) { 'service-with-alb' }

        before(:all) do
          reprovision(
              service_name: 'service-with-alb',
              attach_to_load_balancer: 'yes',
              target_group_arn: output_for(:prerequisites, 'target_group_arn'))
        end

        subject {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }

        it 'has the correct load balancer' do
          expect(subject.load_balancers.first.load_balancer_name)
              .to(be_nil)
          expect(subject.load_balancers.first.target_group_arn)
              .to(eq(output_for(:prerequisites, 'target_group_arn')))
          expect(subject.load_balancers.first.container_name)
              .to(eq(service_name))
          expect(subject.load_balancers.first.container_port)
              .to(eq(service_port))
        end

        it 'has the correct role' do
          expect(subject.role_arn).to(eq(service_role_arn))
        end
      end
    end

    fcontext 'service discovery configuration' do
      context 'when asked not to register in service discovery' do
        let(:service_name) { 'service-without-sd' }

        before(:all) do
          reprovision(
              service_name: 'service-without-sd',
              service_task_network_mode: 'bridge',
              register_in_service_discovery: 'no')
        end

        subject {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }

        it 'does not register with service discovery' do
          expect(subject.service_registries).to(be_empty)
        end
      end

      context 'when asked to register in service discovery as a SRV record' do
        before(:all) do
          namespace_id = output_for(:prerequisites,
              'service_discovery_namespace_id')

          reprovision(
              service_name: 'service-with-sd',
              register_in_service_discovery: 'yes',
              service_discovery_namespace_id: namespace_id,
              service_discovery_record_type: 'SRV')
        end

        subject {
          ecs_client.describe_services(
              cluster: cluster_id,
              services: [service_name]).services.first
        }

        let(:service_name) { 'service-with-sd' }

        let(:service_discovery_namespace_id) {
          output_for(:prerequisites, 'service_discovery_namespace_id')
        }

        let(:created_registry) {
          service_summary = service_discovery_client
              .list_services(
                  max_results: 1,
                  filters: [
                      {
                          name: "NAMESPACE_ID",
                          values: [service_discovery_namespace_id],
                          condition: "EQ",
                      },
                  ])
              .services
              .first

          service = service_discovery_client
              .get_service(id: service_summary.id)
              .service

          service
        }

        it 'creates a service registry for the service' do
          expect(created_registry.name).to(eq(service_name))

          dns_config = created_registry.dns_config

          expect(dns_config.namespace_id)
              .to(eq(service_discovery_namespace_id))

          dns_records = dns_config.dns_records

          expect(dns_records.length).to(eq(1))

          dns_record = dns_records.first

          expect(dns_record.type).to(eq('SRV'))
          expect(dns_record.ttl).to(eq(10))
        end

        it 'registers with the created service registry' do
          found_registry = subject.service_registries.first

          expect(found_registry.registry_arn)
              .to(eq(created_registry.arn))
          expect(found_registry.port).to(be_nil)
          expect(found_registry.container_port).to(eq(service_port))
          expect(found_registry.container_name).to(eq(service_name))
        end
      end
    end

    context 'when asked to register in service discovery as an A record' do
      before(:all) do
        namespace_id = output_for(:prerequisites,
            'service_discovery_namespace_id')

        reprovision(
            service_name: 'service-with-sd',
            service_task_network_mode: 'awsvpc',
            register_in_service_discovery: 'yes',
            service_discovery_namespace_id: namespace_id,
            service_discovery_record_type: 'A')
      end

      subject {
        ecs_client.describe_services(
            cluster: cluster_id,
            services: [service_name]).services.first
      }

      let(:service_name) { 'service-with-sd' }

      let(:service_discovery_namespace_id) {
        output_for(:prerequisites, 'service_discovery_namespace_id')
      }

      let(:created_registry) {
        service_summary = service_discovery_client
            .list_services(
                max_results: 1,
                filters: [
                    {
                        name: "NAMESPACE_ID",
                        values: [service_discovery_namespace_id],
                        condition: "EQ",
                    },
                ])
            .services
            .first

        service = service_discovery_client
            .get_service(id: service_summary.id)
            .service

        service
      }

      it 'creates a service registry for the service' do
        expect(created_registry.name).to(eq(service_name))

        dns_config = created_registry.dns_config

        expect(dns_config.namespace_id)
            .to(eq(service_discovery_namespace_id))

        dns_records = dns_config.dns_records

        expect(dns_records.length).to(eq(1))

        dns_record = dns_records.first

        expect(dns_record.type).to(eq('A'))
        expect(dns_record.ttl).to(eq(10))
      end

      it 'registers with the created service registry' do
        found_registry = subject.service_registries.first

        expect(found_registry.registry_arn)
            .to(eq(created_registry.arn))
        expect(found_registry.port).to(be_nil)
        expect(found_registry.container_port).to(be_nil)
        expect(found_registry.container_name).to(be_nil)
      end
    end
  end

  context 'task definition' do
    before(:all) do
      reprovision
    end

    subject {
      ecs_task_definition(
          "#{component}-#{service_name}-#{deployment_identifier}")
    }

    it { should exist }
    its(:family) {
      should eq("#{component}-#{service_name}-#{deployment_identifier}")
    }

    it 'uses the supplied network mode' do
      expect(subject.network_mode).to(eq(service_task_network_mode))
    end

    it 'uses the supplied pid mode' do
      expect(subject.pid_mode).to(eq(service_task_pid_mode))
    end

    it 'includes the specified service volumes' do
      expect(subject.volumes.size).to(eq(1))

      volume = subject.volumes[0]
      expect(volume.name)
          .to(eq(configuration.for(:harness).service_volume_1_name))
      expect(volume.host.source_path)
          .to(eq(configuration.for(:harness).service_volume_1_host_path))
    end

    context 'when no service role is specified' do
      before(:all) do
        reprovision(service_role: '')
      end

      its(:task_role_arn) { should be_nil }
    end

    context 'when a service role is specified' do
      before(:all) do
        reprovision(service_role: output_for(:prerequisites, 'task_role_arn'))
      end

      its(:task_role_arn) {
        should eq(output_for(:prerequisites, 'task_role_arn'))
      }
    end
  end
end
