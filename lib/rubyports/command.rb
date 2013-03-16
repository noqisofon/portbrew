# -*- coding: utf-8; -*-

require 'optparse'

require 'rubyports/requirement'
require 'rubyports/user_interaction'


#
# rubyports のサブコマンドを表します。
#
#
class Port::Command
  include Port::UserIntaraction

  # コマンド名。
  attr_reader :command
  # コマンドのオプション。
  attr_reader :options
  # デフォルトのオプション。
  attr_accessor :defaults
  # コマンドのプログラム名。
  attr_accessor :program_name
  # コマンドの短い説明。
  attr_accessor :summary

  #
  # Port、またはパッケージをビルドするのに使う引数を返します。
  #
  def self.build_args
    @build_args ||= []
  end

  #
  # Port、またはパッケージをビルドするのに使う引数を設定します。
  #
  # == Parameter:
  # value::
  #    Port、またはパッケージをビルドするのに使う引数の配列。
  #
  # == Returns:
  #   設定後の build_args。
  #
  def self.build_args=(value)
    @build_args = value
  end

  #
  #
  #
  def self.common_options
    @common_options ||= []
  end

  #
  #
  #
  def self.add_common_option(*args, &handler)
    Port.Command.command_options << [ args, handler ]
  end

  #
  #
  #
  def self.extra_args
    @extra_args ||= []
  end

  #
  #
  #
  def self.extra_args=(value)
    case value
      when Array
      @extra_args = value

      when String
      @extra_args = value.split
    end
  end

  #
  #
  #
  def self.specific_extra_args(command)
    specific_extra_args_hash[command]
  end

  #
  #
  #
  def self.add_specific_extra_args(command, args)
    args = args.split( /s+/ ) if args.kind_of? String

    specific_extra_args_hash[command] = args
  end

  #
  #
  #
  def self.specific_extra_args_hash
    @specific_extra_args_hash ||= Hash.new { |that, key| that[key] = [] }
  end

  #
  # == Parameters:
  # command::
  #   コマンド名。
  #
  # summary::
  #   コマンドの短い説明。
  #
  # defaults::
  #   コマンドのデフォルトオプション。
  #
  def initialize(command, summray = nil, defaults = {})
    @command, @summary, @defaults = command, summary, defaults

    @program_name = "port-#{command}"
    @options = default.dup
    @option_groups = Hash.new { |that, key| that[key] = [] }

    @parser = nil
    @when_invoked = nil
  end

  #
  # long オプションの先頭が short オプションの幾つかの文字で始まっているかどうかを判別します。
  #
  def begins?(long, short)
    return false if short.nil?

    long[0, short.length] == short
  end

  # コマンドを実行します。
  #
  # このクラスでは Port::Exception がスローされます。
  #
  #
  def execute
    raise Port::Exception, "generic command has no actions"
  end

  #
  #
  #
  def show_lookup_faulure(port_name, version, errros, domain)
    if errors and not erros.empty? then
      message = "Could not find a valid port '#{port_name} @#{version}', here is why:\n"

      errors.each { |error| message << "         #{error.wordy}\n" }
      alert_error message
    else
      alert_error "Could not find a valid port '#{port_name} @#{version}' in any repository"
    end

    unless domain == :local then
      suggestions = Port::SpecFetcher.fetcher.suggest_ports_from_name port_name

      alert_error "Possible alternatives: " unless suggestions.empty?
    end
  end
end
