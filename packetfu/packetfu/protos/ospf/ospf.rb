=begin
 require OSPF Packet File
=end

cwd = File.expand_path(File.dirname(__FILE__))

require File.join(cwd, "ospf_module")
require File.join(cwd, "ospf_combo")
require File.join(cwd, "ospf_opts")
require File.join(cwd, "ospf_header")
require File.join(cwd, "ospf_hello")
require File.join(cwd, "ospf_dbd")
require File.join(cwd, "ospf_lsr")
require File.join(cwd, "ospf_lsu")
require File.join(cwd, "ospf_lsack")

require File.join(cwd, "lsa")

require File.join(cwd, "ospf_factory")

=begin
load "ospf_module.rb"
load "ospf_combo.rb"
load "ospf_opts.rb"
load "ospf_header.rb"
load "ospf_hello.rb"
load "ospf_dbd.rb"
load "ospf_lsr.rb"
load "ospf_lsu.rb"
load "ospf_lsack.rb"

load "lsa.rb"

load "ospf_factory.rb"
=end

