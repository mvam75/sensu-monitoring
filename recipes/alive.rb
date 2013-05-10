%w[
  check-alive.rb
  metric-alive.rb
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}" do
    source "plugins/#{default_plugin}"
    mode 0755
  end
end

sensu_check "alive_check" do
  command "/etc/sensu/plugins/check-alive.rb -h :::name::: -P :::port::: -q :::context:::"
  handlers ["zenoss"]
  subscribers ["task-service-test"]
  interval 60
end

sensu_check "metric-alive" do
  type "metric"
  command "/etc/sensu/plugins/metric-alive.rb -h :::name::: -P :::port::: -q :::context::: --scheme stats.:::name:::"
  handlers ["graphite"]
  subscribers ["task-service-test"]
  interval 60
end
