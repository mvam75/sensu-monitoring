include_recipe "sensu-monitoring::jmx_req_stats"
include_recipe "sensu-monitoring::jmx_pipeline"
include_recipe "sensu-monitoring::jmx_os_process"
include_recipe "sensu-monitoring::jmx_cache"

directory "/etc/sensu/plugins/lib" do
  action :create
  user "sensu"
  group "sensu"
end

%w[
  jmx_base_check_options.rb
  jmx_base_metric_options.rb
  jmx_proxy.rb
  jmx_util.rb
  scheme.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/lib/#{plugin}" do
    source "plugins/lib/#{plugin}"
    mode 0755
  end
end

