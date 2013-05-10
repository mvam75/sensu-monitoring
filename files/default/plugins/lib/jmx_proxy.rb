#!/usr/bin/env ruby

require 'rest_client'
require 'json'

class JmxProxy
  ##
  # config should be a hash with the parameters from JmxBaseMetricOptions
  # required: proxy, host, port
  ##
  def initialize(config)
    @config = config
  end

  ##
  # Return a hash of { mbean => { attribute1 => value1, attribute2 => value2 }}
  # for the specified mbean_pattern and attribute list.  if no
  # attributes are specified, then all attributes are returned for all matching mbeans
  ##
  def query(mbean_pattern, attributes = [])
    begin
      json = RestClient.get(@config[:proxy], params(mbean_pattern, attributes))
      map = JSON.parse(json)
      if map['responseCode'] and map['responseCode'] != '200'
        raise Exception.new("JMX Proxy Request failed: Error #{map['responseCode']}: #{map['message']}\n\tat #{map['stackTrace']}")
      end
    rescue => e
      raise Exception.new("JMX Proxy Request failed: #{e.message}")
    end
    map
  end

  private
  def params(mbean_pattern, attributes)
    params = {}
    params[:host] = @config[:host]
    params[:port] = @config[:port]
    params[:mbean] = mbean_pattern

    if attributes and attributes.length > 0
      params[:attributes] = attributes.join(",")
    end

    if @config[:user] and @config[:user].length > 0
      params[:user] = @config[:user]
    end

    if @config[:password] and @config[:password].length > 0
      params[:password] = @config[:password]
    end
    {:params => params}
  end
end