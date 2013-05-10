#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'

require File.join(File.dirname(__FILE__), "lib/jmx_base_metric_options.rb")
require File.join(File.dirname(__FILE__), "lib/jmx_util.rb")
require File.join(File.dirname(__FILE__), "lib/scheme.rb")

class JmxRequestStatisticMetrics < Sensu::Plugin::Metric::CLI::Graphite

  def self.options
    JmxBaseMetricOptions.options
  end

  def run
    config[:scheme] ||= Scheme.jmx(config[:host])
    config[:mbean] ||= "java.lang:type=OperatingSystem"
    config[:attributes] ||= %w(
      ProcessCpuTime
    )
    metrics = JmxUtil.query(config)

    metrics.each do |k,v|
      output "#{k}", "#{v}", Time.now.to_i
    end
    ok
  end
end
