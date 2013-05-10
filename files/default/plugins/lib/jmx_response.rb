require 'json'

class JmxResponse
  attr_reader :json
  attr_reader :code
  attr_reader :data

  def initialize(json)
    @json = json
    map = JSON.parse(json)
    @code = map['responseCode'].to_i ? map['responseCode'] : 200
    @data = {}
    if @code != 200
      map.each do |k,v|
        if k != 'responseCode'
          data[k] = v
        end
      end
    else @data = map
    end
  end

  def to_metrics(scheme)
    metrics = {}
    @data.each do |bean, values|
      if values.length > 0
        #hash = self.nested_property_hash(bean)
        #scheme = scheme.clone
        #hash.each {|k,v| scheme += ".#{v}"}
        #values.each {|attribute, value| metrics["#{scheme}.#{attribute}"] = value}
      end
    end
    metrics
  end

  def mbeans
    if @code == 200
      @data.keys
    end
  end

  def attributes(mbean)
    if @code == 20
      @data[mbean]
    end
  end

  def find(bean_regex, attributes=[])
    found = {}
    @data.each do |mbean,sub_hash|
      if mbean.index(bean_regex)
        sub_hash.each do |name,value|
          if attributes.include? name
            found[bean] = {}
            found[bean][name] = value
          end
        end
      end
    end
  end

  def to_s
    @json
  end
end