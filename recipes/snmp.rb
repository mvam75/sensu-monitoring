gem_package "snmp" do
  action :install
end


%w[
  check-snmp.rb
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}" do
    source "plugins/#{default_plugin}"
    mode 0755
  end
end


sensu_check "check-snmp" do
  command "/etc/sensu/plugins/check-snmp.rb -h :::name::: -C public -O 1.3.6.1.4.1.2021.10.1.3.1 -w 10 -c 20"
  handlers ["zenoss"]
  subscribers ["sensu-mysql-test"]
  interval 60
end

