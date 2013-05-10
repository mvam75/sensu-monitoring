%w[
  metric-jmx-os-process.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "jmx_os_process" do
  command "/etc/sensu/plugins/metric-jmx-os-process.rb --proxy 'http://tools.qa.testlab.com:8095/jmx/proxy' --host :::name::: --port :::jmx_port::: --mbean java.lang:type=OperatingSystem"
  type "metric"
  interval 60
  handlers ["graphite"]
  subscribers ["task-service-test"]
end
