# Centreon Import
The X4B platform includes a mechanism for importing your current Centreon (or Nagios) setup. This allows you to start off with a draft AppControl map file which includes all the hosts and services that you have defined in your Centreon configuration.
## AppControl map
The import will create one AppControl component for each host, and one for each service, with the host component being designated as a parent of the service component. The parent-child relationship denotes a dependency relation, where the child depends on a properly working parent to perform its own function.

You can designate one of your servers as a **bastion host**. If you do, it is assumed that you will deploy an AppControl agent on it, and then that server will be used to run remote checks on other hosts, using the ping or ssh commands, for example.

By default, the host components have a check command that does **ping -c 1 &lt;hostname&gt;**. The service components are created with sample check, start, and stop commands that simulate the actual checks using a temporary file. All these default commands assume the agent is running on a linux machine, but you can also configure your map to deploy the agents on Windows servers (see xxx for more details on AppControl agents).
## Importing your setup
The import tool is a Windows binary that you can download from [here](https://github.com/xcomponent/appcontrol-documentation/releases/download/1.0/ac_from_centreon.exe). To import your setup, first log on to your Centreon server, and export your configuration to a text file, with the following command:
  
```console
centreon -u <admin_user> -p <admin_password> -e > centreon_export.txt
```
  Second, run the import tool, specifying your export file as the input file:
```console
ac_from_centreon.exe -f centreon_export.txt -n CentreonExported -v 1.0
```
This creates a file called **CentreonExported,1.0.xml** in the current directory (you are free to pick any name and version you want, see the available options below). You can open this file in the editor of your choice to inspect or edit it, and you can upload it to AppControl with the New button on the AppControl UI.
Other options are available:
```console
Usage: ac_from_centreon.exe OPTIONS
Options:
    -f <filepath>
    -r | --root-host <hostname>
    -b | --bastion-host <hostname>
    -n <map name> (required)
    -v <version> (required)
    -o <map_filepath>
```
The **--root-host** option lets you specify one server as being the root, in the AppControl architecture map, of the servers graph. This indicates that all the other server depend on this one; you would typically choose a server playing some essential role, such as a DNS server.

The **--bastion-host** option lets specify one server as being the bastion, as described above.

The **-n** and **-v** options are required, they define the map name and version. If no path is given for the map file, then the file gets created in the current directory, with the name &lt;map_name&gt;,&lt;version&gt;.xml; alternatively, you may specify a different path and name using the **-o** option. 
   
