# -*- coding: utf-8; -*-
require 'portbrew/command'
require 'portbrew/user_intaraction'


#
#
#
class PortBrew::CommandManager
  include PortBrew::UserInteraction

  #
  #
  #
  def self.instance
    @command_manager ||= new
  end

  #
  #
  #
  def self.reset
    @command_manager = nil
  end

  #
  #
  #
  def initialize
    require 'timeout'

    @commands = {}
    register_command :install
    register_command :uninstall
    register_command :search
    register_command :list
  end

  #
  #
  #
  def instance
    self
  end

  #
  #
  #
  def register_command(command, placeholder = false)
    @commands[command] = placeholder
  end

  #
  #
  #
  def unregister_command(command)
    @commands.delete command
  end
end
