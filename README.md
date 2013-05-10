sensu-monitoring Cookbook
=========================
Application cookbook for Senu


Requirements
------------
The Sensu cookbook

Usage
-----
#### sensu-monitoring::default

Just include `sensu-monitoring` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[sensu-monitoring]"
  ]
}
```
