%w[
  check-disk.rb
  metric-disk-capacity.rb
  metric-iostat-extended.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "check-disk" do
  command "/etc/sensu/plugins/check-disk.rb"
  interval 60
  handlers ["zenoss"]
  subscribers ["linux-application-server"]
end

sensu_check "disk-capacity-metrics" do
  command "/etc/sensu/plugins/metric-disk-capacity.rb --scheme stats.:::name:::"
  type "metric" 
  interval 60
  handlers ["graphite"]
  subscribers ["linux-application-server", "linux-database-server"]
end

sensu_check "iostat-extended-metrics" do
  command "etc/sensu/plugins/metric-iostat-extended.rb --scheme stats.:::name:::.disk"
  type "metric"
  handlers ["graphite"]
  subscribers ["linux-application-server", "linux-database-server"]
end  
