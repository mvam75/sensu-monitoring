require File.join(File.dirname(__FILE__), "jmx_proxy.rb")

class JmxUtil
  ##
  # Utility method that runs a jmx_proxy query then converts
  # the response to Graphite metrics
  ##
  def self.query(config)
    jmx = JmxProxy.new(config)
    data = jmx.query(config[:mbean], config[:attributes])
    convert_jmx_to_metrics(data, config[:scheme])
  end

  ##
  # Given a jmx query response (i.e.: {mbean => { attribute => value }})
  # and a scheme prefix (i.e.: "stats.hostname.jmx")
  # return an array of graphite-friendly metrics in the form
  # [
  #   ["metric.name.1", metric_value_1, timestamp],
  #   ["metric.name.2", metric_value_2, timestamp],
  #   ...
  # ]
  ##
  def self.convert_jmx_to_metrics(jmx_response, scheme_prefix, time = Time.now.to_i)
    raise ArgumentError unless jmx_response && scheme_prefix
    metrics = []
    jmx_response.each do |mbean, attributes|
      unless attributes.nil?
        scheme = "#{scheme_prefix}.#{convert_mbean_to_scheme(mbean)}"
        convert_attributes_to_metrics(attributes, scheme, metrics, time)
      end
    end
    metrics
  end

  ##
  # convert an mbean name to a graphite metric.  For example, this
  #   "thePlatform:application=TaskService,name=cacheStatistics,cache=ServiceUriPath"
  # would be converted to this
  #   "TaskService.cacheStatistics.ServiceUriPath"
  ##
  def self.convert_mbean_to_scheme(mbean)
    i = mbean.index(":")
    if i == 0
      return mbean # not an mbean
    else
      metric = mbean.slice(i+1, mbean.length).gsub(/\w+=(\w+)/, '\\1').gsub(",", ".")
    end
  end

  ##
  # Recursive method that converts attribute hash to graphite metrics
  # I.e.:
  #   { attribute1 => value1, attribute2 => value2 }
  # would get converted to
  #   [[scheme_prefix.attribute1, value1, time], [scheme_prefix.attribute2, value2, time]]
  def self.convert_attributes_to_metrics(hash, scheme_prefix, metrics = [], time = Time.now.to_i)
    hash.each do |key,value|
      scheme = "#{scheme_prefix}.#{key}"
      if value.is_a? Hash
        convert_attributes_to_metrics(value, scheme, metrics, time)
      else
        metrics << [scheme, value, time]
      end
    end
    metrics
  end
end