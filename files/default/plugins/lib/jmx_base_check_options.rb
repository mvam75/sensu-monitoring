require 'mixlib/cli'

class JmxBaseCheckOptions

  include Mixlib::CLI
  option :proxy,
    :long => "--proxy jmx_proxy_server_url",
    :description => "The URL of the JMX Proxy Server",
    :required => true

  option :host,
    :long => "--host host",
    :description => "Target host",
    :required => true

  option :port,
    :long => "--port jmx_port",
    :description => "The jmx port for the target server",
    :required => true

  option :mbean,
    :long => "--mbean mbean_pattern",
    :description => "The mbean pattern that the check relies on.  e.g.: thePlatform:application=MediaDataService,endpoint=MediaData,name=requestStatistics",
    :required => true

  option :scheme,
    :long => "--scheme graphite",
    :description => "the graphite scheme prefix to use for this JMX collector",
    :required => false

  option :critical,
    :long => "--critical value",
    :description => "The threshold at which a critical alert will be generated. It's up to the implementing script whether this is greater than, less than and what the units are."

  option :warn,
    :long => "--warn value",
    :description => "The threshold at which a warning alert will be generated.  It's up to the implementing script whether this is greater than, less than and what the units are."
end