#!/usr/bin/env ruby

require 'optparse'
require 'pty'
require 'expect'

options = {
  :on => nil
}

$opts = nil

OptionParser.new do |opts|
  opts.banner = %Q{Usage: proxy_settings --[on|off]}

  opts.on("--on", "Turn on proxy settings") {
    options[:on] = true
  }

  opts.on("--off", "Turn off proxy settings") {
    options[:on] = false
  }
  $opts = opts
end.parse!

if options[:on].nil?
  puts $opts
  exit
end

def get_current_interface
  str = `ifconfig | pcregrep -M -o '^[^\t:]+:([^\n]|\n\t)*status: active'`.strip
  str =~ /^(.*):\s+/ ? $1.strip : nil
end

def get_service_name(interface)
  out = `networksetup -listnetworkserviceorder | pcregrep '[^\(\d+\)]\s.*\n*Device: #{ interface.strip }'`
  out =~ /Port: (.*), Device:/ ? $1.strip : nil
end

def safety_spawn cmd, &block
  PTY.spawn(cmd) do |r,w,p|
    begin
      yield r,w,p
    rescue Errno::EIO
    ensure
      Process.wait p
    end
    $?.exitstatus
  end
end

def run_as_sudo cmd
  $stdout.puts cmd
  safety_spawn cmd do |r,w,p|
    until r.eof? do
      r.expect(/Password:/i) {|rr|
        w.puts ENV['SUDO_PASSWORD']
      }
      line = r.readline
      $stdout.puts line
    end
  end
  $stdout.puts "\n"
end

def turn_proxy_setting_off(service_name)
  run_as_sudo %Q{sudo networksetup -setwebproxystate "#{service_name}" off}
end

def set_proxy_setting_to service_name, address, port
  run_as_sudo %Q{sudo networksetup -setwebproxy "#{service_name}" #{address} #{port}}
end


if options[:on] === true || options[:on] === false
  if en = get_current_interface
    service_name = get_service_name(en)
    $stdout.puts "Interface: #{ en }"
    $stdout.puts "Service Name: #{ service_name }"
    turn_proxy_setting_off service_name

    if options[:on] === true
      $stdout.puts "* Setting HTTP Proxy to 127.0.0.1:8080"
      set_proxy_setting_to service_name, "127.0.0.1", "8080"
    end
  end
end
