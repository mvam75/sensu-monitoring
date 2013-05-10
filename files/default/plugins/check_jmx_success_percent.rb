#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/check/cli'
require File.join(File.dirname(__FILE__), 'lib/jmx_proxy.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_base_check_options.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_util.rb')
require File.join(File.dirname(__FILE__), 'lib/scheme.rb')

class CheckJmxSuccessPercent < Sensu::Plugin::Check::CLI

  def self.options
    JmxBaseCheckOptions.options
  end

  def run
    attr_success = "SuccessfulRequestCount1Minute"
    attr_total = "TotalRequestCount1Minute"
    attr_failed = "FailedRequestCount1Minute"
    metric_success_pct = "SuccessPercent1Minute"

    config[:scheme] ||= Scheme.jmx(config[:host])

    jmx = JmxProxy.new(config)
    attribute_map = jmx.query(config[:mbean],
      [attr_total, attr_success, attr_failed])
    success_count = attribute_map[config[:mbean]][attr_success]
    total_count = attribute_map[config[:mbean]][attr_total]
    failed_count = attribute_map[config[:mbean]][attr_failed]
    success_pct = 1.0

    # we don't alert if there is zero traffic, or if all requests are client failures
    if total_count > 0 and total_count - failed_count > 0
      success_pct = success_count / (total_count - failed_count)
      if config[:critical] and success_pct <= config[:critical].to_f
        critical "#{config[:scheme]}.#{metric_success_pct}: #{success_pct} <= #{config[:critical]}"
        return
      end

      if config[:warning] and success_pct <= config[:warning].to_f
        warning "#{config[:scheme]}.#{metric_success_pct}: #{success_pct} <= #{config[:warning]}"
        return
      end
    end
    ok "#{config[:scheme]}.#{metric_success_pct}: #{success_pct}"
  end
end