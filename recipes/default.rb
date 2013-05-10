#
# Cookbook Name:: sensu-monitoring
# Recipe:: default
#
# Copyright 2013, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "sensu-monitoring::client"
include_recipe "sensu-monitoring::alive"
include_recipe "sensu-monitoring::filesystems"
include_recipe "sensu-monitoring::cpu"
include_recipe "sensu-monitoring::dns"
include_recipe "sensu-monitoring::jmx"