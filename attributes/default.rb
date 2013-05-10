override["sensu"]["version"] = "0.9.12-2"
override["sensu"]["use_embedded_ruby"] = false

default["sensu-monitoring"]["master_address"] = nil

default["sensu-monitoring"]["environment_aware_search"] = false
default["sensu-monitoring"]["use_local_ipv4"] = true

default["sensu-monitoring"]["sensu_plugin_version"] = "0.1.7"

default["sensu-monitoring"]["additional_client_attributes"] = Mash.new

default["sensu-monitoring"]["default_handlers"] = ["debug"]
default["sensu-monitoring"]["metric_handlers"] = ["debug"]
