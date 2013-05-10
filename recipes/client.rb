#
# Cookbook Name:: sensu-monitoring
# Recipe:: client
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sensu::default"

client_attributes = node["sensu-monitoring"]["additional_client_attributes"].to_hash

port = nested_hash_value(node.to_hash, :jetty_http_port)
context = nested_hash_value(node.to_hash, :alive_path)
jmx_port = (port.to_i + 1)

if client_attributes["vip"]
  vip = nested_hash_value(node.to_hash, :vip)
else
  vip = "localhost"
end

sensu_client node.name do
  address node["ipaddress"]
  subscriptions node["roles"]
  #additional client_attributes
  additional(:port => "#{port}", :jmx_port => "#{jmx_port}", :context => "#{context}", :vip => "#{vip}")
end

%w[
  check-procs.rb
  check-banner.rb
  check-http.rb
  check-log.rb
  check-mtime.rb
  check-tail.rb
  check-fs-writable.rb
  check-disk.rb
  vmstat-metrics.rb
  cpu-metrics.rb
  check-alive.rb
  metric-alive.rb
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}" do
    source "plugins/#{default_plugin}"
    mode 0755
  end
end

%w[zenoss.rb].each do |default_handlers|
  cookbook_file "/etc/sensu/handlers/#{default_handlers}" do
    source "handlers/#{default_handlers}"
    mode 0755
  end
end

# chef client move to cron
sensu_check "chef-client" do
  command "/etc/sensu/plugins/check-procs.rb -p chef-client -C 1"
  action :delete
  handlers ["zenoss"]
  subscribers ["linux-application-server", "linux-database-server"]
  interval 60
end

sensu_handler "zenoss" do
  type "pipe"
  command "/etc/sensu/handlers/zenoss.rb"
end

gem_package "sensu-plugin" do
  action :install
end

include_recipe "sensu::client_service"
