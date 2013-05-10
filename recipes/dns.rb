%w[
  check-dns.rb
].each do |plugin|
  cookbook_file "/etc/sensu/plugins/#{plugin}" do
    source "plugins/#{plugin}"
    mode 0755
  end
end

sensu_check "check-dns" do
  command "/etc/sensu/plugins/check-dns.rb -d :::vip:::"
  interval 600
  handlers ["zenoss"]
  subscribers ["linux-application-server"]
end
