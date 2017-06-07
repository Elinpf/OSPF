=begin
 	require All File
=end

cwd = File.expand_path(File.dirname(__FILE__))
$: << cwd
# packetfu
require "/opt/metasploit/msf3/lib/packetfu/packetfu.rb"
# socket2
require "/root/git/2laySocket/socket/socket2.rb"
# ospf
require File.join(cwd,"ospf.rb")
