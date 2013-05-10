#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require File.join(File.dirname(__FILE__), 'lib/jmx_proxy.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_base_check_options.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_util.rb')
require File.join(File.dirname(__FILE__), 'lib/scheme.rb')

class CheckJmxTpGcStatistics < Sensu::Plugin::Check::CLI

  def self.options
    JmxBaseCheckOptions.options
  end

  def run
    config[:mbean] ||= 'thePlatform:application=*,name=gcStatistics,collector=*'
    config[:scheme] ||= Scheme.jmx(config[:host])
    attr_mem_used_percent = 'MemoryUsedPercent'

    jmx = JmxProxy.new(config)
    data = jmx.query(config[:mbean], [attr_mem_used_percent])
    data.keys.each do |bean|
      value = data[bean][attr_mem_used_percent]
      if config[:critical] and value > config[:critical]
        critical "#{config[:scheme]}.#{attr_mem_used_percent}: #{value} > #{config[:critical]}"
        return
      end

      if config[:warning] and value <= config[:warning]
        warning "#{config[:scheme]}.#{attr_mem_used_percent}: #{value} <= #{config[:warning]}"
        return
      end
      ok "#{config[:scheme]}.#{attr_mem_used_percent}: #{value}"
    end
    warning "No mbeans matching #{config[:mbean]}"
  end
end