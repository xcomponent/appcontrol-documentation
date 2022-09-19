# AppControl AGENTS

## Latest Available versions

| Operating System | Format| Latest version |
| -----------------|------|------------|
| Microsoft Windows | zip | [Windows Agent Zip](https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcAgent-binary-Win32.zip) |  
| Alpine|  tar.gz| [Alpine tar.gz](https://github.com/xcomponent/appcontrol-documentation/releases/latest//download/alpine.tar.gz) |
| Alma Linux (EL)| tar.gz| [Alma tar.gz](https://github.com/xcomponent/appcontrol-documentation/releases/latest//download/almalinux.tar.gz)|
| Rocky Linux (EL)| tar.gz| [Rocky Linux](https://github.com/xcomponent/appcontrol-documentation/releases/latest//download/rockylinux.tar.gz)|
| Debian| tar.gz| [Dedian tar.gz](https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/debian.tar.gz)|
| Alpine| docker| docker pull xcomponent/appcontrol-agent:latest-alpine|
| Alma Linux| docker| docker pull xcomponent/appcontrol-agent:latest-almalinux|
| Debian| docker| docker pull xcomponent/appcontrol-agent:latest-debian|

All binaries versions are listed here: [All binaries versions](https://github.com/xcomponent/appcontrol-documentation/releases/)

All docker versions are listed here: [All docker versions](
https://hub.docker.com/r/xcomponent/appcontrol-agent/tags)

## Microsoft Windows Platform

To install XComponent AppControl Agent under Windows OS, unzip the following [file](https://github.com/xcomponent/appcontrol-documentation/releases/download/1.0/xcAgent_win32_1.0.zip) into an installation directory.
The configuration file (** config.dat **) is located in the same directory.
Refer to the agent configuration section to customize the configuration.

##### 1. Install the agent as a Microsoft Windows Service

- To register the program in the service registry of the Microsoft� Windows machine execute the following command in a prompt (cmd.exe) with administrative permissions:

```console
C:\appcontrol>xcAgent --install --servicename XComponentAppControlAgent
XComponent App Control Agent, version 9.9
Copyright © Invivoo Software 2022
XComponent AppControl service name: XComponentAppControlAgentXComponent AppControl service display name: XComponent AppControl AgentXComponentAppControlAgent is installed.
```

- We can either specify the display service name during registration: 
```console
C:\appcontrol>xcAgent.exe --install --servicename appcontrolagent --servicedisplayname "Agent AppControl"
XComponent App Control Agent, version 9.9
Copyright © Invivoo Software 2022
XComponent App Control service name: appcontrolagent
XComponent App Control service display name: Agent AppControl
appcontrolagent is installed.
```
- Uninstalling the agent can be done also with the following command line:
```console
C:\appcontrol>xcAgent.exe --uninstall --servicename appcontrolagent
XComponent App Control Agent, version 9.9
Copyright © Invivoo Software 2022
appcontrolagent has been uninstalled.
```

- Start the service **XComponent AppControl Agent**

![Agent Service](../images/agent_service.png)

##### 2. Start the agent from prompt (cmd.exe)

Run cmd.exe and the go the agent folder.

```console
C:\appcontrol>xcAgent.exe --console
XComponent AppControl Agent, version 7.0.0-R1
Copyright © Invivoo Software 2022

```

## ENTERPRISE LINUX

At the moment EL versions of XComponent AppControl Agent are Rocky Linux and Alma Linux.

To install XComponent AppControl Agent under EL, untar the following [Alma tar.gz](https://github.com/xcomponent/appcontrol-documentation/releases/latest//download/almalinux.tar.gz) into an installation directory (Tarball file).
The configuration file (** config.dat **) is located in the same directory.
Refer to the agent configuration section to customize the configuration.

Replace **/usr/src/app/xcagent** by your own installation folder.

```console
/usr/src/app/xcagent $ export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/src/app/xcagent/libs
/usr/src/app/xcagent $ ./xcAgent.bin --file /usr/src/app/xcagent/config.dat

XComponent AppControl Agent, version 7.0.0-R1
Copyright � Invivoo Software 2022

```

## AGENTLESS LINUX & UNIX

From an XComponent AppControl Linux agent, you can enable AgentLess mode via SSH2.
This mode allows a Linux XComponent AppControl Agent to forward actions provided by the AppControl server under a non permanent Ssh channel to the IP address and account configured in the agent configuration file.
Refer to the agent configuration section to customize the configuration.

## DOCKER INSTALLATION

The docker image of the agent is available [here](https://hub.docker.com/r/xcomponent/appcontrol-agent) on docker hub.

You can pull the docker image using the following command line:

```console
root $ docker pull xcomponent/appcontrol-agent:latest
```

Environment variables exposed by the docker image are the following:

| Variable               | Description                                                                                                        |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------ |
| CONFIG_FILE_PATH       | Path to the **config.dat**                                                                                         |
| TRUSTED_SERVERS        | List of IP addresses, or Dns names of XComponent AppControl servers authorized to contact the agent (Can be empty) |
| LOG_LEVEL              | Log levels ('NONE', 'ERROR', 'INFO', 'TRACE')                                                                      |
| PORT                   | Default value: 12567. Port used as the agent's TCP listening port. Numerical format.                               |
| NB_DAYS_TO_DELETE_LOGS | Default value: 0. Retention period for trace files archived under logdirectory /logs-backup/ (In number of days)   |
| LOG_STANDARD_OUTPUT    | Default value: true. Boolean value (true or false). If true redirect all the logs to std output                    |

Some Technicals Points:

1. If your agent needs to access to local resources (eg: scripts), you have 2 ways to achieve this:
   - Inherits from this docker image and create your own image
   - Or you can map a directory to the docker image

Running the docker image:

```console
root $ docker run -p 12567:12567 xcomponent/appcontrol-agent:latest
```

## Agent Configuration

The default configuration file is name config.dat. It's located near the XComponent AppControl Agent configuration file.

```xml
<config>
  <item key="networkAddress"     value="127.0.0.1" />
  <item key="port"               value="12567" />
  <item key="checktimeout"       value="20" />
  <item key="logdirectory"       value="log" />
  <item key="tempdirectory"      value="tmp" />
  <item key="maxlogsizeinmo"     value="5" />
  <item key="nbdaystodeletelogs" value="10" />
  <item key="executionthreshold" value="30" />
  <!--Log level : NONE, INFO, TRACE, ERROR -->
  <item key="loglevel"           value="INFO" />
  <item key="trustedservers"     value="127.0.0.1" />
  <item key="sshhost"            value="127.0.0.1" />
  <item key="sshkeydirectory"    value="sshkeys" />
</config>
```

| Key                | Description                                                                                                                                                                                                                                                                                                    |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| networkAddress     | IP address used to open the agent's TCP listening port. A.B.C.D format (0.0.0.0 for all interfaces of the machine)                                                                                                                                                                                             |
| port               | Port used as the agent's TCP listening port. Numerical format.                                                                                                                                                                                                                                                 |
| checktimeout       | Maximum time allowed for a check command. Once this period has passed, the check order is considered completed. (In seconds)                                                                                                                                                                                   |
| logdirectory       | Agent's trace file recording directory.                                                                                                                                                                                                                                                                        |
| tempdirectory      | Agent's working directory                                                                                                                                                                                                                                                                                      |
| maxlogsizeinmo     | Maximum size before rotation of the trace file (In Megabytes)                                                                                                                                                                                                                                                  |
| nbdaystodeletelogs | Retention period for trace files archived under logdirectory /logs-backup/ (In number of days)                                                                                                                                                                                                                 |
| loglevel           | Log levels ('NONE', 'ERROR', 'INFO', 'TRACE')                                                                                                                                                                                                                                                                  |
| executionthreshold | Maximum number of parallel executions for (Start/Stop/Custom actions). This parameter is not applied on check actions.                                                                                                                                                                                         |
| trustedservers     | List of IP addresses, or Dns names of XComponent AppControl servers authorized to contact the agent (Can be empty)                                                                                                                                                                                             |
| sshhost            | This parameter allows the agent to perform an SSH session with the account specified in the configuration of the application. The file containing the private key to use is located in the 'sshkeydirectory' directory and bears the name of the targeted user.This property works exclusively on Linux agent. |
| sshkeydirectory    | Directory for storing Ssh private key files. The name of the expected files must be named with the name of the user targeted by the application configuration. The public key must be present in the ~/ssh/authorized_keys file of the remote account                                                          |

## Environment variables configuration

Config.dat configuration supports environment variables as a value.

 **Under Microsoft Windows:**

In Microsoft Windows, environment variables are defined with the following pattern: %VARIABLE%.

```xml
<config>
  <item key="tempdirectory" value="%TEMP%" />
  <item key="maxlogsizeinmo" value="%MYVALUE%" />
</config>
```

**Under Linux/Unix:**

In Linux/Unix, environment variables are defined with the following pattern: $VARIABLE.

```xml
<config>
   <item key="tempdirectory" value=”$TEMP" />
   <item key="maxlogsizeinmo" value="$MYVALUE" />
</config>
```

**Note:**
```
Each item key of the config.dat file can be overriden  by an environment variable named XC_MYITEMKEYINUPPERCASE. The priority is the following:
1. If an XC_... variable exists the agent will use it
2. The values in the config.dat are used only if the XC_... variables don't exist.

Example: 
if an env variable named XC_TEMPDIRECTORY exists, this value will be used instead of the variable 'tempdirectory' defined in the config.dat.

```



