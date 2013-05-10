#! /usr/bin/env ruby

require 'rubygems' if RUBY_VERSION < '1.9.0'
require 'sensu-plugin/metric/cli'
require File.join(File.dirname(__FILE__), 'lib/jmx_base_metric_options.rb')
require File.join(File.dirname(__FILE__), 'lib/jmx_util.rb')
require File.join(File.dirname(__FILE__), 'lib/scheme.rb')

class JmxCacheMetrics < Sensu::Plugin::Metric::CLI::Graphite

  def self.options
    JmxBaseMetricOptions.options
  end

  def run
    config[:scheme] ||= Scheme.jmx(config[:host])
    config[:attributes] = %w(
      CacheHitRatio
      CacheHits
      CacheMisses
      CacheSize
    )
    config[:mbean] = "thePlatform:application=*,name=cacheStatistics,cache=*"

    jmx = JmxProxy.new(config)
    data = jmx.query(config[:mbean], config[:attributes])
    data.filter_cache_names
    metrics = JmxUtil.convert_jmx_to_metrics(data, config[:scheme])
    metrics.each {|name, value, time| output(name, value, time)}
    ok
  end
end

# decorate Hash with a new filter method
class Hash
  def filter_cache_names
    self.keys.each do |bean|
      self[bean.without_dot_prefixes] = self[bean]
      delete(bean)
    end
  end
end

# decorate String with a new filter method
class String
  def without_dot_prefixes
    self.gsub(/(\w+\.)*(\w+)/, '\2')
  end
end