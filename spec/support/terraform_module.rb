require 'ruby_terraform'

require_relative '../../lib/configuration'

module TerraformModule
  class <<self
    def configuration
      @configuration ||= Configuration.new
    end

    def output_with_name(name)
      RubyTerraform.output(name: name, state: configuration.state_file)
    end

    def provision(vars)
      puts
      puts "Provisioning with deployment identifier: #{configuration.vars.deployment_identifier}"
      puts

      FileUtils.rm_rf(File.dirname(configuration.configuration_directory))
      FileUtils.mkdir_p(File.dirname(configuration.configuration_directory))
      FileUtils.cp_r(
          configuration.source_directory,
          configuration.configuration_directory)

      Dir.chdir(configuration.configuration_directory) do
        RubyTerraform.init
        RubyTerraform.apply(
            state: configuration.state_file,
            directory: '.',
            vars: vars.to_h)
      end

      puts
    end

    def destroy(vars)
      unless ENV['DEPLOYMENT_IDENTIFIER']
        puts
        puts "Destroying with deployment identifier: #{configuration.vars.deployment_identifier}"
        puts

        FileUtils.rm_rf(File.dirname(configuration.configuration_directory))
        FileUtils.mkdir_p(File.dirname(configuration.configuration_directory))
        FileUtils.cp_r(
            configuration.source_directory,
            configuration.configuration_directory)

        Dir.chdir(configuration.configuration_directory) do
          RubyTerraform.init
          RubyTerraform.destroy(
              state: configuration.state_file,
              directory: '.',
              vars: vars.to_h,
              force: true)
        end

        puts
      end
    end
  end
end