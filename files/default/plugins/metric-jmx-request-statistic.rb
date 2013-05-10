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

  def initialize
    super
    # mbean attribute names
    @attr_success_count = 'SuccessfulRequestCount1Minute'
    @attr_fail_count = 'FailedRequestCount1Minute'
    @attr_error_count = 'InternalErrorCount1Minute'
    @attr_total_count = 'TotalRequestCount1Minute'
    @attr_fail_response_time = 'FailedAverageResponseTime1Minute'
    @attr_success_response_time = 'SuccessfulAverageResponseTime1Minute'
    @attr_total_response_time = 'TotalAverageResponseTime1Minute'

    # derived attribute names
    @attr_success_percent = 'PercentSuccess'
    @attr_fail_percent = 'PercentClientFailure'
    @attr_error_percent = 'PercentServerError'
  end

  def run
    config[:scheme] ||= Scheme.jmx(config[:host])
    config[:mbean] ||= "thePlatform:application=*,endpoint=*,name=*equestStatistics"
    config[:attributes] ||= [
      @attr_fail_response_time,
      @attr_success_response_time,
      @attr_total_response_time,
      @attr_fail_count,
      @attr_success_count,
      @attr_error_count,
      @attr_total_count
    ]

    #metrics = JmxUtil.query(config)
    time = Time.now.to_i
    jmx = JmxProxy.new(config)
    data = jmx.query(config[:mbean], config[:attributes])
    out = JmxUtil.convert_jmx_to_metrics(data, config[:scheme])
    out.each do |k,v|
      output k, v, time
    end

    data.keys.each do |bean|
      output_success_percent(bean, data[bean], time)
      output_fail_percent(bean, data[bean], time)
      output_error_percent(bean, data[bean], time)
    end

    ok
  end

  def output_success_percent(bean, data, time)
    success_count = data[@attr_success_count]
    total_count = data[@attr_total_count]
    if success_count and total_count and total_count > 0
      success_percent = success_count / total_count
      out = JmxUtil.convert_jmx_to_metrics({bean => {@attr_success_percent => success_percent}}, config[:scheme])
      out.each do |k,v|
        output k,v, Time.new.to_i
      end
      #output(JmxUtil.convert_to_metrics({bean => {@attr_success_percent => success_percent}}, config[:scheme]), time)
    end
  end

  def output_fail_percent(bean, data, time)
    fail_count = data[@attr_fail_count]
    total_count = data[@attr_total_count]
    if fail_count and total_count and total_count > 0
      fail_percent = fail_count / total_count
      out = JmxUtil.convert_jmx_to_metrics({bean => {@attr_fail_percent => fail_percent}}, config[:scheme])
      out.each do |k,v|
        output k,v, Time.new.to_i
      end
      #output(JmxUtil.convert_to_metrics({bean => {@attr_fail_percent => fail_percent}}, config[:scheme]), time)
    end
  end

  def output_error_percent(bean, data, time)
    error_count = data[@attr_error_count]
    total_count = data[@attr_total_count]
    if error_count and total_count and total_count > 0
      error_percent = error_count / total_count
      out = JmxUtil.convert_jmx_to_metrics({bean => {@attr_error_percent => error_percent}}, config[:scheme])
      out.each do |k,v|
        output k,v, Time.new.to_i
      end
      #output(JmxUtil.convert_to_metrics({bean => {@attr_error_percent => error_percent}}, config[:scheme]), time)
    end
  end
end
