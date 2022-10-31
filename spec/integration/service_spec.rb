# frozen_string_literal: true

require 'spec_helper'

# TODO: incorporate the below tests into some other examples
#
# describe 'ECS Service' do
#   let(:component) do
#     var(role: :full, name: 'component')
#   end
#   let(:deployment_identifier) do
#     var(role: :full, name: 'deployment_identifier')
#   end
#
#   let(:service_name) do
#     var(role: :full, name: 'service_name')
#   end
#   let(:service_port) do
#     var(role: :full, name: 'service_port').to_i
#   end
#
#   let(:service_desired_count) do
#     var(role: :full, name: 'service_desired_count').to_i
#   end
#
#   let(:service_deployment_maximum_percent) do
#     var(role: :full, name: 'service_deployment_maximum_percent').to_i
#   end
#   let(:service_deployment_minimum_healthy_percent) do
#     var(role: :full, name: 'service_deployment_minimum_healthy_percent').to_i
#   end
#
#   let(:service_task_network_mode) do
#     var(role: :full, name: 'service_task_network_mode')
#   end
#   let(:service_task_pid_mode) do
#     var(role: :full, name: 'service_task_pid_mode')
#   end
#
#   let(:scheduling_strategy) do
#     var(role: :full, name: 'scheduling_strategy')
#   end
#
#   let(:placement_constraint_type) do
#     configuration.for(:harness).placement_constraint_type
#   end
#   let(:placement_constraint_expression) do
#     configuration.for(:harness).placement_constraint_expression
#   end
#
#   let(:cluster_id) do
#     output(role: :full, name: 'cluster_id')
#   end
#   let(:task_definition_arn) do
#     output(role: :full, name: 'task_definition_arn')
#   end
#   let(:service_role_arn) do
#     output(role: :full, name: 'service_role_arn')
#   end
#   let(:load_balancer_name) do
#     output(role: :full, name: 'load_balancer_name')
#   end
#   let(:target_group_arn) do
#     output(role: :full, name: 'target_group_arn')
#   end
#
#   describe 'service' do
#     subject(:ecs_service) do
#       ecs_client.describe_services(
#         cluster: cluster_id,
#         services: [service_name]
#       ).services.first
#     end
#
#     it 'exists' do
#       expect(ecs_service).not_to(be_nil)
#     end
#
#     it 'is associated with the correct task definition' do
#       expect(ecs_service.task_definition).to(eq(task_definition_arn))
#     end
#
#     it 'has the correct desired count' do
#       expect(ecs_service.desired_count).to(eq(service_desired_count))
#     end
#
#     it 'defines the deployment maximum percent' do
#       expect(ecs_service.deployment_configuration.maximum_percent)
#         .to(eq(service_deployment_maximum_percent))
#     end
#
#     it 'defines the deployment minimum healthy percent' do
#       expect(ecs_service.deployment_configuration.minimum_healthy_percent)
#         .to(eq(service_deployment_minimum_healthy_percent))
#     end
#
#     it 'defines the deployment minimum healthy percent' do
#       expect(ecs_service.scheduling_strategy)
#         .to(eq(scheduling_strategy))
#     end
#
#
#     it 'uses the supplied placement constraint' do
#       expect(ecs_service.placement_constraints.length).to(eq(1))
#       expect(ecs_service.placement_constraints.first.type)
#         .to(eq(placement_constraint_type))
#       expect(ecs_service.placement_constraints.first.expression)
#         .to(eq(placement_constraint_expression))
#     end
#     #
#     describe 'network configuration (for awsvpc network mode)' do
#       describe 'when using default security group' do
#         let(:service_name) { 'service-with-awsvpc' }
#         let(:service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#         let(:security_groups) do
#           service
#             .network_configuration
#             .awsvpc_configuration
#             .security_groups
#             .map { |sg| security_group(sg) }
#         end
#
#         before(:all) do
#           reprovision(
#             service_name: 'service-with-awsvpc',
#             service_task_network_mode: 'awsvpc',
#             associate_default_security_group: 'yes',
#             default_security_group_ingress_cidrs: ['10.0.0.0/16'],
#             default_security_group_egress_cidrs: ['10.0.0.0/16']
#           )
#         end
#
#
#         it('associates a security group allowing inbound TCP and UDP ' \
#            'for all ports for the supplied ingress CIDRs') do
#           expect(security_groups.length).to(eq(1))
#
#           security_group = security_groups.first
#
#           expect(security_group.inbound_rule_count).to(eq(1))
#
#           ingress_rule = security_group.ip_permissions.first
#
#           expect(ingress_rule.from_port).to(be_nil)
#           expect(ingress_rule.to_port).to(be_nil)
#           expect(ingress_rule.ip_protocol).to(eq('-1'))
#           expect(ingress_rule.ip_ranges.map(&:cidr_ip))
#             .to(eq(['10.0.0.0/16']))
#         end
#         #
#
#         it('associates a security group allowing outbound TCP and UDP ' \
#            'for all ports for the supplied egress CIDRs') do
#           expect(security_groups.length).to(eq(1))
#
#           security_group = security_groups.first
#
#           expect(security_group.outbound_rule_count).to(eq(1))
#
#           egress_rule = security_group.ip_permissions_egress.first
#
#           expect(egress_rule.from_port).to(be_nil)
#           expect(egress_rule.to_port).to(be_nil)
#           expect(egress_rule.ip_protocol).to(eq('-1'))
#           expect(egress_rule.ip_ranges.map(&:cidr_ip))
#             .to(eq(['10.0.0.0/16']))
#         end
#         #       end
#     end
#
#     describe 'load balancer configuration' do
#       describe 'when asked not to attach to a load balancer' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         let(:service_name) { 'service-without-lb' }
#
#         before(:all) do
#           reprovision(
#             service_name: 'service-without-lb',
#             attach_to_load_balancer: 'no'
#           )
#         end
#
#         it 'has a service with no load balancer configured' do
#           expect(ecs_service.load_balancers).to(be_empty)
#         end
#       end
#
#       describe 'when asked to attach to a classic load balancer' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         let(:service_name) { 'service-with-elb' }
#
#         before(:all) do
#           reprovision(
#             service_name: 'service-with-elb',
#             attach_to_load_balancer: 'yes',
#             service_elb_name:
#               output_for(:prerequisites, 'load_balancer_name'),
#             service_health_check_grace_period_seconds: 60
#           )
#         end
#
#
#         it 'has the correct load balancer' do
#           expect(ecs_service.load_balancers.first.load_balancer_name)
#             .to(eq(output_for(:prerequisites, 'load_balancer_name')))
#           expect(ecs_service.load_balancers.first.target_group_arn)
#             .to(be_nil)
#           expect(ecs_service.load_balancers.first.container_name)
#             .to(eq(service_name))
#           expect(ecs_service.load_balancers.first.container_port)
#             .to(eq(service_port))
#         end
#         #
#         it 'has the correct role' do
#           expect(ecs_service.role_arn).to(eq(service_role_arn))
#         end
#
#         it 'defines the health check grace period' do
#           expect(ecs_service.health_check_grace_period_seconds)
#             .to(eq(60))
#         end
#       end
#
#       describe 'when asked to attach to an application load balancer' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         let(:service_name) { 'service-with-alb' }
#
#         before(:all) do
#           reprovision(
#             service_name: 'service-with-alb',
#             attach_to_load_balancer: 'yes',
#             target_group_arn: output(role: :full, name: 'target_group_arn'),
#             service_health_check_grace_period_seconds: 60
#           )
#         end
#
#
#         it 'has the correct load balancer' do
#           expect(ecs_service.load_balancers.first.load_balancer_name)
#             .to(be_nil)
#           expect(ecs_service.load_balancers.first.target_group_arn)
#             .to(eq(output(role: :full, name: 'target_group_arn')))
#           expect(ecs_service.load_balancers.first.container_name)
#             .to(eq(service_name))
#           expect(ecs_service.load_balancers.first.container_port)
#             .to(eq(service_port))
#         end
#         #
#         it 'has the correct role' do
#           expect(ecs_service.role_arn).to(eq(service_role_arn))
#         end
#
#         it 'defines the health check grace period' do
#           expect(ecs_service.health_check_grace_period_seconds)
#             .to(eq(60))
#         end
#       end
#     end
#
#     describe 'service discovery configuration' do
#       describe 'when asked not to register in service discovery' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         let(:service_name) { 'service-without-sd' }
#
#         before(:all) do
#           reprovision(
#             service_name: 'service-without-sd',
#             service_task_network_mode: 'bridge',
#             register_in_service_discovery: 'no'
#           )
#         end
#
#         it 'does not register with service discovery' do
#           expect(ecs_service.service_registries).to(be_empty)
#         end
#       end
#
#       describe 'when asked to register in service discovery using ' \
#                'existing registry' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         before(:all) do
#           registry_arn = output_for(
#             :prerequisites, 'service_discovery_registry_arn'
#           )
#
#           reprovision(
#             service_name: 'service-with-sd-existing-registry',
#             register_in_service_discovery: 'yes',
#             service_discovery_create_registry: 'no',
#             service_discovery_registry_arn: registry_arn,
#             service_discovery_record_type: 'SRV'
#           )
#         end
#
#         let(:service_name) { 'service-with-sd-existing-registry' }
#
#         let(:service_discovery_registry_arn) do
#           output(
#             role: :full, name: 'service_discovery_registry_arn'
#           )
#         end
#
#
#         it 'registers with the provided service registry' do
#           found_registry = ecs_service.service_registries.first
#
#           expect(found_registry.registry_arn)
#             .to(eq(service_discovery_registry_arn))
#           expect(found_registry.port).to(be_nil)
#           expect(found_registry.container_port).to(eq(service_port))
#           expect(found_registry.container_name).to(eq(service_name))
#         end
#         #       end
#
#       describe 'when asked to register in service discovery as a ' \
#                'SRV record' do
#         subject(:ecs_service) do
#           ecs_client.describe_services(
#             cluster: cluster_id,
#             services: [service_name]
#           ).services.first
#         end
#
#         before(:all) do
#           namespace_id =
#             output(role: :full, name: 'service_discovery_namespace_id')
#
#           reprovision(
#             service_name: 'service-with-sd-srv',
#             register_in_service_discovery: 'yes',
#             service_discovery_namespace_id: namespace_id,
#             service_discovery_record_type: 'SRV'
#           )
#         end
#
#         let(:service_name) { 'service-with-sd-srv' }
#
#         let(:service_discovery_namespace_id) do
#           output(role: :full, name: 'service_discovery_namespace_id')
#         end
#
#         let(:created_registry) do
#           service_summary =
#             service_discovery_client
#             .list_services(
#               max_results: 1,
#               filters: [
#                 {
#                   name: 'NAMESPACE_ID',
#                   values: [service_discovery_namespace_id],
#                   condition: 'EQ'
#                 }
#               ]
#             )
#             .services
#             .first
#
#           service = service_discovery_client
#                     .get_service(id: service_summary.id)
#                     .service
#
#           service
#         end
#
#
#         it 'creates a service registry for the service' do
#           expect(created_registry.name).to(eq(service_name))
#
#           dns_config = created_registry.dns_config
#
#           expect(dns_config.namespace_id)
#             .to(eq(service_discovery_namespace_id))
#
#           dns_records = dns_config.dns_records
#
#           expect(dns_records.length).to(eq(1))
#
#           dns_record = dns_records.first
#
#           expect(dns_record.type).to(eq('SRV'))
#           expect(dns_record.ttl).to(eq(10))
#         end
#         #
#
#         it 'registers with the created service registry' do
#           found_registry = ecs_service.service_registries.first
#
#           expect(found_registry.registry_arn)
#             .to(eq(created_registry.arn))
#           expect(found_registry.port).to(be_nil)
#           expect(found_registry.container_port).to(eq(service_port))
#           expect(found_registry.container_name).to(eq(service_name))
#         end
#         #       end
#     end
#
#     describe 'when asked to register in service discovery as an A record' do
#       subject(:ecs_service) do
#         ecs_client.describe_services(
#           cluster: cluster_id,
#           services: [service_name]
#         ).services.first
#       end
#
#       before(:all) do
#         namespace_id =
#           output(role: :full, name: 'service_discovery_namespace_id')
#
#         reprovision(
#           service_name: 'service-with-sd-a',
#           service_task_network_mode: 'awsvpc',
#           register_in_service_discovery: 'yes',
#           service_discovery_namespace_id: namespace_id,
#           service_discovery_record_type: 'A'
#         )
#       end
#
#       let(:service_name) { 'service-with-sd-a' }
#
#       let(:service_discovery_namespace_id) do
#         output(role: :full, name: 'service_discovery_namespace_id')
#       end
#
#       let(:created_registry) do
#         service_summary =
#           service_discovery_client
#           .list_services(
#             max_results: 1,
#             filters: [
#               {
#                 name: 'NAMESPACE_ID',
#                 values: [service_discovery_namespace_id],
#                 condition: 'EQ'
#               }
#             ]
#           )
#           .services
#           .first
#
#         service = service_discovery_client
#                   .get_service(id: service_summary.id)
#                   .service
#
#         service
#       end
#
#
#       it 'creates a service registry for the service' do
#         expect(created_registry.name).to(eq(service_name))
#
#         dns_config = created_registry.dns_config
#
#         expect(dns_config.namespace_id)
#           .to(eq(service_discovery_namespace_id))
#
#         dns_records = dns_config.dns_records
#
#         expect(dns_records.length).to(eq(1))
#
#         dns_record = dns_records.first
#
#         expect(dns_record.type).to(eq('A'))
#         expect(dns_record.ttl).to(eq(10))
#       end
#       #
#
#       it 'registers with the created service registry' do
#         found_registry = ecs_service.service_registries.first
#
#         expect(found_registry.registry_arn)
#           .to(eq(created_registry.arn))
#         expect(found_registry.port).to(be_nil)
#         expect(found_registry.container_port).to(be_nil)
#         expect(found_registry.container_name).to(be_nil)
#       end
#       #     end
#   end
#
#   describe 'task definition' do
#     subject(:task_definition) do
#       ecs_task_definition(
#         "#{component}-#{service_name}-#{deployment_identifier}"
#       )
#     end
#
#     before(:all) do
#       reprovision
#     end
#
#     it { is_expected.to exist }
#
#     its(:family) do
#       is_expected
#         .to(eq("#{component}-#{service_name}-#{deployment_identifier}"))
#     end
#
#     it 'uses the supplied network mode' do
#       expect(task_definition.network_mode).to(eq(service_task_network_mode))
#     end
#
#     it 'uses the supplied pid mode' do
#       expect(task_definition.pid_mode).to(eq(service_task_pid_mode))
#     end
#
#
#     it 'includes the specified service volumes' do
#       expect(task_definition.volumes.size).to(eq(1))
#
#       volume = task_definition.volumes[0]
#       expect(volume.name)
#         .to(eq(configuration.for(:harness).service_volume_1_name))
#       expect(volume.host.source_path)
#         .to(eq(configuration.for(:harness).service_volume_1_host_path))
#     end
#     #
#     describe 'when no service role is specified' do
#       before(:all) do
#         reprovision(service_role: '')
#       end
#
#       its(:task_role_arn) { is_expected.to be_nil }
#     end
#
#     describe 'when a service role is specified' do
#       before(:all) do
#         reprovision(
#           service_role:
#             output(role: :full, name: 'task_role_arn')
#         )
#       end
#
#       its(:task_role_arn) do
#         is_expected
#           .to(eq(output(role: :full, name: 'task_role_arn')))
#       end
#     end
#   end
# end
#
