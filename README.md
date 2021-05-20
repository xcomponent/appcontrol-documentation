<p align="center">
  <img src="images/logo.svg" alt="logo" width="200" />
</p>
<p align="left">
  AppControl reduces your applications downtimes by letting you react quickly to an ongoing incident.
  <br>
  <br>
  Supplementing your existing monitoring and supervision tools, AppControl acts on your applications to restart, repair, execute any custom actions, as you wish, on your information system.
  <br>
  <br>
  AppControl empowers your teams, increases their confidence level and lowers their stress during operations.
</p>

## USEFUL LINKS

| <div style="width:140px"><b>Description</b></div> | <div style="width:300px"><b>Links</b></div> |
| :---------- | :---- |
| Public SaaS portal | [X4B SaaS](https://x4b.xcomponent.com) |
| Other documentations | <ul><li>[How to install AppControl Agent to execute the components actions?](./Documentation/agents.md)</li><li>[How to connect your personal workstation with X4B AppControl SaaS for testing?](./Documentation/x4bcli.md)</li><li>[How to connect your corporate private network with X4B AppControl SaaS?](./Documentation/x4bcli.md)</li><li>[How to create your application map?](./Documentation/map.md)</li><li>[How to import your Centreon setup into AppControl?](./Documentation/centreon.md)</li><li>[How to integrate AppControl with a ServiceNow Cmdb?](./Documentation/cmdb.md)</li><li>[Using an OpenFaaS function to implement an XC Scenario task](./Documentation/openfaas/synchronous.md)</li> |

## OBJECTIVES

- Find root cause with no human intervention
- Eliminate human error when restarting
- Keep operational procedures tested and up-to-date

AppControl allows you to both monitor the status of applications in real time but **above all to act** when an incident occurs.
Where monitoring software signals you problems, AppControl offers to correct them.
<br>

<p align="center">
  <img src="images/screenshot.png" alt="Screenshot" width="50%" height="50%" />
</p>

## HOW IT WORKS

In AppControl, an application is a hierarchy of components. <br> A component have several commands:

- A check command to retrieve the current state
- A start command
- A stop command
- And some optionals custom commands

- #### Dependencies behaviour
- A component can only starts if its parent's components are started.
- A component can only stops if its children's components are stopped.

#### 1. Diagnostic

In this situation, there are 2 issues:

- 2 components are stopped whereas there parents are started

--> AppControl has detected the issues.

![Diagnostic](images/diagnostic.png)

#### 2. Resolution

<ol>
  <li>AppControl stops orphans components

  ![Resolution1](images/resolution1.png)
  </li>

  <li>Healthy situation, we are ready to restore the services

  ![Resolution2](images/resolution2.png)
  </li>
  <li>Restart by branch

  ![Restart](images/restart.png)
  </li>
  <li>Normal situation

  ![Normal](images/normal.png)
  </li>
</ol>

## Get Started

- Go to the [XComponent AppControl website](https://appcontrol.xcomponent.com).
- Log in using a social provider
- That's all, you are logged!

In the example section, retrieve the helloworld,v1.xml demo application.

On the AppControl website, go to the Import Application and select "Use Default Agent".
Because you don't have installed your own agent yet, select "Use Default Agent".
Click on **Import** button.

![Sceenshot Menu](images/sceenshot_menu.png)

Go the dashboard, and select the helloworld application by clicking on the checkbox.
Then click on the load button.
![Dashboard1](images/dashboard1.png)

Your application is loaded:
![Dashboard2](images/dashboard2.png)

Click on the map button:

![Map1](images/map1.png)

Using, the command bar, it's easy to start/stop the Hello World application.
![Command Bar](images/command_bar.png)

## Q/A

1. Does AppControl replace the monitoring tools (Nagios, Centreon, Zabbix, ...) ?

   No, AppControl is not intended to replace these tools. It is possible to rely on these probes and add additional action commands.
