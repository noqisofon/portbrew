require 'rbconfig'


module Ports
  VERSION = "0.0.1"
end


require 'rubyports/compatibility'

require 'rubyports/defaults'
require 'rubyports/deprecate'
require 'rubyports/errors'


module Port


  PORT_PATH = File.dirname File.expand_path( __FILE__ )


end
