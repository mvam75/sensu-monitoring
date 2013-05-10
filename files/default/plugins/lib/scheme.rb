class Scheme
  def self.jmx(host)
    "stats.#{clean_hostname(host)}.jmx"
  end

  def self.clean_hostname(hostname)
    length = hostname.index(".") || hostname.length
    hostname[0, length].downcase
  end
end
