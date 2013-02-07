require 'rubyports'
require 'rubyports/command_manager'
require 'rubyports/config_file'


class Port::PortRunner

  def initialize(options = {})
    @command_manager_type = options[:command_manager] || Port::CommandManager
    @config_file_class = options[:config_file] || Port::ConfigFile
  end

  def run(args)
    if args.include '--' then
      build_args = args[args.index( '--' ) + 1...args.length]
      args = args[0...args.index( '--' )]
    end

    configuration args
    command = @command_manager_class.instance

    command.command_names.each do |command_name|
      config_args = Port::configuration[command_name]
      config_args = case config_args
                      when String
                      config_args.split ' '
                      else
                      Array( config_args )
                    end

      Port::Command.add_specific_extra_args command_name, config_args
    end

    command.run Port::configuration.args, build_args
  end

end
