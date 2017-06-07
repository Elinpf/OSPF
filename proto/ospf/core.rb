cwd = File.expand_path(File.dirname(__FILE__))

$: << cwd

load "/root/.msf4/lib/packetfu/packetfu/protos/ospf/core.rb"

# singleton
require "singleton"

# state machine
require File.join(cwd, "state")

# data structure
require File.join(cwd, "data")

# packet handler
require File.join(cwd, "packet_handler")

# singleton facotry 
require File.join(cwd, "factory")
