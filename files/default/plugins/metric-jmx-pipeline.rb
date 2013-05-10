#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require File.join(File.dirname(__FILE__), 'lib/jmx_base_metric_options.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_util.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_proxy.rb')
require File.join(File.dirname(__FILE__), 'lib/scheme.rb')

class JmxPipelineMetrics < Sensu::Plugin::Metric::CLI::Graphite

  def self.options
    JmxBaseMetricOptions.options
  end

  def run
    config[:scheme] ||= Scheme.jmx(config[:host])
    config[:mbean] ||= "thePlatform:application=*,name=pipelines,pipeline=*,phaseExecutionStatistics=*"
    config[:attributes] ||= %w(
      AverageActiveThreads1Minute
      AverageExecutionTime1Minute
      AverageQueueSize1Minute
      AverageWaitTime1Minute
      Executions1Minute
      FailedExecutions1Minute
      MaximumActiveThreads1Minute
      MaximumExecutionTime1Minute
      MaximumQueueSize1Minute
      MaximumWaitTime1Minute
      MinimumActiveThreads1Minute
      MinimumExecutionTime1Minute
      MinimumQueueSize1Minute
      MinimumWaitTime1Minute
      SuccessfulExecutions1Minute
    )

    metrics = JmxUtil.query(config)
    metrics.each do |name, value, time|
      output name.gsub(/phaseExecutionStatistics\[(.*)\]/, '\1'), value, time
    end

    ok
  end
end