# -*- coding: utf-8; -*-

require 'optparse'

require 'portbrew/requirement'
require 'portbrew/user_interaction'


#
# portbrew のサブコマンドを表します。
#
#
class PortBrew::Command
  include PortBrew::UserIntaraction

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
    raise PortBrew::Exception, "generic command has no actions"
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

      alert_error "Possible alternatives: #{suggestions.join( ", " )}" unless suggestions.empty?
    end
  end

  #
  # 全ての Port の名前を返します。
  #
  def get_all_port_names
    args = options[:args]

    if args.nil? or args.empty? then
      raise PortBrew::CommandLineError, "Please specify at least one port name (e.g. port build PORTNAME)"
    end

    args.select { |arg| arg !~ /^-/ }
  end

  #
  #
  #
  def get_all_port_names_and_versions
    get_all_port_names.map do |name|
      if /\A(.*):(#{PortBrew::Requirement::PATTERN_RAW})\z/ =~ name then
        [ $1, $2 ]
      else
        [ name ]
      end
    end
  end

  #
  # コマンドラインオプションから Port 名を 1 つ返します。
  #
  def get_one_port_name
    args = options[:args]

    if args.nil? or args.empty? then
      raise Port::CommandLineError, "Please specify a port name on the command line (e.g. port build PORTNAME)"
    end

    if args.size > 1 then
      raise Port::CommandLineError, "Too many port names (#{args.join( ", " )}); please spacify only one"
    end

    args.first
  end

  #
  #
  #
  def get_one_optional_argument
    args = options[:args] || []

    args.first
  end

  #
  #
  #
  def arguments
    ""
  end

  #
  #
  #
  def defaults_str
    nil
  end

  #
  #
  #
  def description
  end

  #
  #
  #
  def usage
    program_name
  end

  #
  # ヘルプメッセージを表示します。
  #
  def show_help
    parser.program_name = usage

    say parser
  end

  #
  # コマンドを引数を渡して呼び出します。
  #
  def invoke(*args)
    invoke_with_build_args args, nil
  end

  #
  # 引数を与えてコマンドを実行します。
  #
  def invoke_with_build_args(args, build_args)
    handle_options args

    options[:build_args] = build_args

    if options[:help] then
      show_help
    elsif @when_incoked then
      @when_invoked.call options
    else
      execute
    end
  end

  #
  #
  #
  def when_invoked(&block)
    @when_invoked = block
  end

  #
  # コマンドにオプションとそれに対応するハンドラを追加します。
  #
  def add_option(*opts, &handler)
    group_name = Symbol === opts.first ? opts.shift : options

    @option_groups[group_name] << [ opts, handler ]
  end

  #
  # コマンドに追加したオプションを削除します。
  #
  def remove_optoon(name)
    @option_groups.each do |_, option_list|
      option_list.reject! { |args, _| args.any? { |arg| arg =~ /^#{name}/  } }
    end
  end

  #
  # 渡された引数と元から持っているオプションとでマージします。
  #
  def merge_options(new_options)
    @options = @defaults.clone

    new_options.each { |k, v| @options[k] = v }
  end

  #
  # オプションに対応するハンドルがあるかどうか判別します。
  #
  def handles?(args)
    parser.parse! args.dup

    return true
  rescue
    return false
  end

  #
  #
  #
  def handle_options(args)
    args = add_extra_args( args )
    @optsions = Marshal.load Marshal.dump @defaults      # deep copy
    parser.parse! args
    @options[:args] = args
  end

  #
  #
  #
  def add_extra_args(args)
    result = []

    s_extra = Port::Command.specific_extra_args @command
    extra = Port::Command.extra_args + s_extra

    until extra.empty? do
      ex = []
      ex << extra.shift
      ex << extra.shift if extra.first.to_s =~ /^[^-]/

      result << ex if handles? ex
    end

    result.flattern!
    result.concat args
    result
  end


  private
  #
  #
  #
  def add_parser_description
    return nil unless description

    formatted = description.split( "\n\n" ).map { |chunk|
      wrap chank, 80 * 4
    }.join "\n"

    @parser.separator nil
    @parser.separator " Description:"
    formatted.split( "\n" ).each do |line|
      @paraser.separator nil
      configure_options group_name, option_list
    end
  end

  #
  #
  #
  def add_parser_run_info(title, content)
    return nil if content.empty?

    @parser.separator nil
  end
end
