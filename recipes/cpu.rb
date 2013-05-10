%w[
  check-load.rb
  metric-load.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "check-load" do
  command "/etc/sensu/plugins/check-load.rb"
  interval 300
  handlers ["zenoss"]
  subscribers ["linux-application-server", "linux-database-server"]
end

sensu_check "load-metrics" do
  command "/etc/sensu/plugins/metric-load.rb --scheme stats.:::name:::.cpu.loadavg"
  type "metric"
  interval 60
  handlers ["graphite"]
  subscribers ["linux-application-server", "linux-database-server"]
end
