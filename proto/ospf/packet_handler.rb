cwd = File.expand_path(File.dirname(__FILE__))
cwd = File.join(cwd, "packet_handler")

# Capture
require File.join(cwd, "pcaprub.so")
require File.join(cwd, "capture")

require File.join(cwd, "parse")
require File.join(cwd, "receive")
require File.join(cwd, "send")


