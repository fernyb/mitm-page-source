#!/usr/bin/env ruby

require "lwes"
require "json"

emitter = LWES::Emitter.new({
  :address => '224.1.1.11',
  :port => 56299,
  :heartbeat => 30, # nil to disable
  :ttl => 1
})

if ARGV.size == 1
  File.open(File.expand_path("~/Desktop/lwes.txt"), "w+") {|f| f.write(ARGV[0].to_s) }
  emitter.emit "HTTP", { :json => ARGV[0].to_s }
end
