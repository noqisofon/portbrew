# -*- coding: utf-8; -*-
#
# Copyright (c) 2013 by ned rihine All rights reserved.
#
# See LICENSE.md for permissions.
#
require 'portbrew'
require 'portbrew/command_manager'
require 'portbrew/config_file'


PortBrew::load_env_plugins rescue nil


class PortBrew::PortRunner
  # オプションハッシュを渡して PortRunner のオブジェクトを作成します。
  #
  # == Parameters:
  # options::
  #    オプション。
  #
  def initialize(options = {})
    @command_manager_type = options[:command_manager] || PortBrew::CommandManager
    @config_file_class = options[:config_file] || PortBrew::ConfigFile
  end

  # Portbrew を走らせます。
  #
  # == Parameters:
  # args::
  #   コマンドラインオプションの配列。
  #
  # == Returns:
  #
  #
  def run(args)
    if args.include '--' then
      build_args = args[args.index( '--' ) + 1...args.length]
      args = args[0...args.index( '--' )]
    end

    configuration args
    command = @command_manager_class.instance

    command.command_names.each do |command_name|
      config_args = PortBrew.configuration[command_name]
      config_args = case config_args
                      when String
                      config_args.split ' '
                      else
                      Array( config_args )
                    end

      Port::Command.add_specific_extra_args command_name, config_args
    end

    command.run PortBrew::configuration.args, build_args
  end

  private
  #
  #
  #
  def configuration(args)
    PortBrew::configuration = port_conf = @config_file_class.new args
    PortBrew::usr_paths port_conf[:porthome], port_conf[:porthome]

    PortBrew::Command.extra_args = port_conf[:port]
  end
end

PortBrew::load_plugins
