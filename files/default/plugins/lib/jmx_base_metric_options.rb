require 'mixlib/cli'
require File.join(File.dirname(__FILE__), 'scheme.rb')

class JmxBaseMetricOptions
  include Mixlib::CLI

  def self.get_hostname
    config[:host]
  end

  option :proxy,
    :long => "--proxy jmx_proxy_server_url",
    :description => "The URL of the JMX Proxy Server",
    :required => true

  option :host,
    :long => "--host host",
    :description => "Target host",
    :required => false,
    :default => Scheme.clean_hostname(`hostname`)

  option :port,
    :long => "--port jmx_port",
    :description => "The jmx port for the target server",
    :required => true

  option :mbean,
    :long => "--mbean mbean_pattern",
    :description => "The mbean pattern that the check relies on.  e.g.: thePlatform:application=MediaDataService,endpoint=MediaData,name=requestStatistics",
    :required => false

  option :attributes,
    :long => "--attributes comma_delimited_attribute_names",
    :description => "comma delimited list of attribute names to collect for all matching mbeans",
    :required => false

  option :scheme,
    :long => "--scheme graphite",
    :description => "the graphite scheme prefix to use for this JMX collector",
    :required => false
end
