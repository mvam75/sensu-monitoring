%w[
  check-rabbitmq-messages.rb
  rabbitmq-overview-metrics.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "check-rabbitmq-messages" do
  command "/etc/sensu/plugins/check-rabbitmq-messages.rb"
  interval 10
  handlers ["zenoss"]
  standalone true
  subscribers ["sensu-db"]
end

sensu_check "rabbitmq-overview-metrics" do
  command "/etc/sensu/plugins/rabbitmq-overview-metrics.rb --scheme stats.:::name:::"
  type "metric"
  interval 10
  standalone true
  handlers ["graphite"]
  subscribers ["sensu-db"]
end
