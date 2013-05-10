#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require File.join(File.dirname(__FILE__), 'lib/jmx_proxy.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_base_check_options.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_util.rb')
require File.join(File.dirname(__FILE__), 'lib/scheme.rb')

class CheckJmxResponseTime < Sensu::Plugin::Check::CLI

  def self.options
    JmxBaseCheckOptions.options
  end

  def run
    attr_response_time = "TotalAverageResponseTime1Minute"

    config[:scheme] ||= Scheme.jmx(config[:host])

    jmx = JmxProxy.new(config)
    data = jmx.query(config[:mbean], [attr_response_time])
    data.each do |bean,value_map|
      avg_response_time = data[bean][attr_response_time]

      if config[:critical] and avg_response_time >= config[:critical].to_i
        critical "#{config[:scheme]}.#{attr_response_time}: #{avg_response_time} >= #{config[:critical]}"
      elsif config[:warning] and avg_response_time >= config[:warning].to_i
        warning "#{config[:scheme]}.#{attr_response_time}: #{avg_response_time} >= #{config[:warning]}"
      else
        ok "#{config[:scheme]}.#{attr_response_time}: #{avg_response_time}"
      end
    end
  end
end
