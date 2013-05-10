#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'

require File.join(File.dirname(__FILE__), "lib/jmx_base_metric_options.rb")
require File.join(File.dirname(__FILE__), "lib/jmx_util.rb")
require File.join(File.dirname(__FILE__), "lib/scheme.rb")

class JmxMemoryUsageMetrics < Sensu::Plugin::Metric::CLI::Graphite

  def self.options
    JmxBaseMetricOptions.options
  end

  def run
    config[:scheme] ||= Scheme.jmx(config[:host])
    config[:mbean] ||= 'java.lang:type=Memory'
    config[:attributes] ||= [
      'HeapMemoryUsage',
      'NonHeapMemoryUsage'
    ]

    metrics = JmxUtil.query(config)
    metrics.each {|name, value, time| output(name, value, time)}
    ok
  end
end
