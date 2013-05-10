#! /usr/bin/env ruby

require 'sensu-plugin/metric/cli'
require 'net/https'
require 'uri'
require 'socket'

class AliveMetrics < Sensu::Plugin::Metric::CLI::Graphite

  option :url,
    :short => "-u URL",
    :long => "--url URL",
    :description => "Full URL to nginx status page, example: http://data.media.theplatform.com This ignores ALL other options EXCEPT --scheme"

  option :hostname,
    :short => "-h HOSTNAME",
    :long => "--host HOSTNAME",
    :description => "Nginx hostname"

  option :port,
    :short => "-P PORT",
    :long => "--port PORT",
    :description => "Nginx  port",
    :default => "80"

  option :path,
    :short => "-q STATUSPATH",
    :long => "--statspath STATUSPATH",
    :description => "Path to your stub status module",
    :default => "/management/alive"

  option :scheme,
    :description => "Metric naming scheme, text to prepend to metric",
    :short => "-s SCHEME",
    :long => "--scheme SCHEME",
    :default => "#{Socket.gethostname}.alivecheck"

  def run
    begin

    found = false
    attempts = 0
    until (found || attempts >= 5)
      attempts+=1 
      if config[:url]
        uri = URI.parse(config[:url])
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == 'https' then 
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        if response.code=="200"
          found = true
        elsif response.header['location']!=nil
	  config[:url] = response.header['location']
        end
      else
        response= Net::HTTP.start(config[:hostname], config[:port]) do |http|
          request = Net::HTTP::Get.new("/#{config[:path]}")
          http.request(request)
        end
      end
    end 

    if response.code == "200"
      response.body.split(/\r?\n/).each do |line|
        timestamp = Time.now.to_i
        if line.match(/^Web Service is Ok/)
          output "#{config[:scheme]}.alive", 1, timestamp
        end
      end
    else
      response.body.split(/\r?\n/).each do |line|
        if line.match(/^false/)
          output "#{config[:scheme]}.alive", 0, timestamp
        end
      end
    end

    rescue Errno::ECONNREFUSED
      output "#{config[:scheme]}.alive", 0, timestamp
    end

    ok
  end

end
