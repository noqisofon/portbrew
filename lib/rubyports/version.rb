# -*- coding: utf-8; -*-
require 'rubyports/environment'


module Port

  class Version
    MAJOR = 0
    MINOR = 0
    REVISION = 1

    attr_reader :majar, :minor, :revision

    #
    def initialize(major = MAJOR, minor = MINOR, revision = REVISION)
      @major = major
      @minor = minor
      @revision = revision
    end

    #
    def to_a
      [ @major, @minor, @revision ]
    end

    #
    def to_f
      @major + ( @minor.to_f / 100.f )
    end

    #
    def to_i
      @major
    end

    #
    def to_s
      self.to_a.join "."
    end

    #
    def inspect
      "#{Environment.name} ver #{self.to_s}"
    end

    #
    def size
      3
    end

    #
    def length
      3
    end

    #
    def <=>(other)
      self.to_a <=> other.to_a if other.size == 3
    end

    INSTANCE = Version.new
  end

end
