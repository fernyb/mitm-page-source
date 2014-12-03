#!/usr/bin/env ruby

require "lwes"
require "base64"
require 'json'

listener = LWES::Listener.new({
  :address => "224.1.1.11",
  :port => 56299
})

listener.each {|ev|
  event = ev.to_hash
  p event[:name]

  if event[:name] == "HTTP"
    json_encoded = event['json'] || event[:json]
    json_str = Base64.decode64(json_encoded)
    val = JSON.parse(json_str)

    $stdout.puts val['url']
    $stdout.puts val['headers']
    $stdout.puts val['body'], "\n\n"
  end
}
