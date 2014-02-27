check_missing_hosts
===================

Icinga Plugin to check for hosts not monitored

Introduction
------------

While it should be one of most important principles when using monitoring that each and every host that should be monitored has to be reported to monitoring team and included into the monitoring software there are teams where this communication is not as reliable as it should be. If you ever "found" a host that was running in your network but missing from your monitoring software, this plugin is for you.

The plugin uses nmap and ping scans to find all hosts on a subnet and check if every one of them is configured to be monitored.

Please note that this is a very "work in progress" plugin. It was developed on site for a customer as a one-shot script to search for hosts and turned into an icinga plugin as a very dirty quick fix. Please do not consider it production ready by now.

Example
-------

Just call it as icinga user with options -s holding the subnet and -i holding the path of the icinga.cfg . You have to skip the last triple of the subnet.

    $USER1$/check_missing_hosts.sh -s 192.168.23 -i /etc/icinga/icinga.cfg

Bugs and RFEs
-------------

Issues are tracked at the [plugins GitHub page](https://github.com/widhalmt/check_missing_hosts)
