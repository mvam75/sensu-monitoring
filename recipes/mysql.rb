# mike.deman 2013.05.03 for newer machines, MySQL binaries are in /app/mysql with a
# symlink pointing to the current installation.  We need to smarten up this install
# to accomodate legacy machines.
gem_package "mysql2" do
  options("-- --with-mysql-dir=/app/mysql")
  action :install 
end

%w[
  metric-mysql.rb
].each do |default_plugin|
  cookbook_file "/etc/sensu/plugins/#{default_plugin}" do
    source "plugins/#{default_plugin}"
    mode 0755
  end
end


sensu_check "mysql_metrics" do
  type "metric"
  command "/etc/sensu/plugins/metric-mysql.rb -h :::name::: -P 3306 -u zenoss -p thePlatform --scheme stats.:::name:::.mysql"
  handlers ["graphite"]
  subscribers ["sensu-mysql-test"]
  interval 60
end

