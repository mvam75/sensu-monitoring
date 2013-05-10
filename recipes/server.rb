#
# Cookbook Name:: sensu-monitoring
# Recipe:: server
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sensu::default"
include_recipe "sensu::api_service"
include_recipe "sensu::server_service"

client_attributes = node["sensu-monitoring"]["additional_client_attributes"].to_hash

sensu_client node.name do
  address node["ipaddress"]
  subscriptions node["roles"]
  additional client_attributes
end

sensu_handler "default" do
 type "pipe"
 command "default.rb"
end

%w[
  check-procs.rb
  check-banner.rb
  check-http.rb
  check-log.rb
  check-mtime.rb
  check-tail.rb
  check-fs-writable.rb
  vmstat-metrics.rb
  cpu-metrics.rb
  check-disk.rb
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

sensu_check "chef-client" do
  command "/etc/sensu/plugins/check-procs.rb -p chef-client -C 1"
  action :delete
  handlers ["zenoss"]
  subscribers ["linux-application-server", "linux-database-server"]
  interval 60
end

=begin
sensu_check "alive_check" do
  command "/etc/sensu/plugins/check-alive.rb -h :::name::: -P :::port::: -q :::context:::"
  handlers ["zenoss"]
  subscribers ["task-service-test"]
  interval 60
end

sensu_check "alive_metric" do
  type "metric"
  command "/etc/sensu/plugins/metric-alive.rb -h :::name::: -P :::port::: -q :::context::: --scheme stats.:::name:::"
  handlers ["graphite"]
  subscribers ["task-service-test"]
  interval 60
end
=end

sensu_handler "zenoss" do
  type "pipe"
  command "/etc/sensu/handlers/zenoss.rb"
end

gem_package "sensu-plugin" do
  action :install
end

include_recipe "sensu::client_service"
