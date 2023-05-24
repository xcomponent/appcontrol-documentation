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

| <b>Description</b> | <b>Links</b> |
| :---------- | :---- |
| Public SaaS portal | [X4B SaaS](https://x4b.xcomponent.com) |
| Getting Started | - [Get started](#get-started)<br/> - [How to create your application map?](./Documentation/map.md)<br/> - [Enrich your application with dynamic informations](./Documentation/appcontrol_worker/dynamicmapinformations.md)<br/>
| Deploy your own agents | - [How to install AppControl Agent to execute the components actions?](./Documentation/agents.md)<br>- [How to install your gateways ?](./Documentation/x4bcli.md)<br> - [Configuration best practices](./Documentation/bestpractices.md)|
| Advanced | - [AppControl Cli](./Documentation/cli.md)<br/>- [How to import your Centreon setup into AppControl?](./Documentation/centreon.md)<br/>- [How to integrate AppControl with a ServiceNow Cmdb?](./Documentation/cmdb.md) |
| Interactions between AppControl and Scenario |- [Using an OpenFaaS function to implement an XC Scenario task](./Documentation/openfaas/synchronous.md)<br/>- [Using the AppControl Worker to implement an XC Scenario task](./Documentation/appcontrol_worker/README.md)<br/> |

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

#### Diagnostic

In this situation, there are 2 issues:

- 2 components are stopped whereas there parents are started

--> AppControl has detected the issues.

![Diagnostic](images/diagnostic.png)

#### Resolution

1. AppControl stops orphans components

   ![Resolution1](images/resolution1.png)

2. Healthy situation, we are ready to restore the services

   ![Resolution2](images/resolution2.png)

3. Restart by branch

   ![Restart](images/restart.png)

4. Normal situation

   ![Normal](images/normal.png)

## Get Started

- Go to the [XComponent AppControl website](https://appcontrol.xcomponent.com).
- Log in using a social provider
- That's all, you are logged!

In the example section, copy the following link to the demo application: [demo application](https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/main/examples/helloworld%2Cv1.xml).

On the AppControl website, go to the Import Application and paste the link of the [demo application](https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/main/examples/helloworld%2Cv1.xml).

Follow the wizard (clicking on 'Next' button). In the **'Gateway'** tab select 'X4B SaaS'. On the last tab click on **'Import'**.


![Sceenshot Menu](images/sceenshot_menu.png)

Go the **'Overview'**, and select the helloworld application by clicking on the checkbox.
Then click on the load button.
![Dashboard1](images/dashboard1.png)

Click on the **'Architecture'** button:

![Map1](images/map1.png)

Using, the command bar, it's easy to start/stop the Hello World application.
![Command Bar](images/command_bar.png)

## Q/A

1. Does AppControl replace the monitoring tools (Nagios, Centreon, Zabbix, ...) ?

   No, AppControl is not intended to replace these tools. It is possible to rely on these probes and add additional action commands.
