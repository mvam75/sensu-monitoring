%w[
  redis-graphite.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "redis-graphite" do
  command "/etc/sensu/plugins/redis-graphite.rb --scheme stats.:::name:::"
  type "metric"
  interval 60
  standalone true
  handlers ["graphite"]
  subscribers ["sensu-db"]
end

gem_package "redis" do
  action :install
end
