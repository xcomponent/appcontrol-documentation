# AppControl Application

In AppControl, applications (also called maps) are described using an XML file.
For AppControl, an aplication is a hierarchy of components.

This file contains mainly the following informations:

- **Component elements** described by a check command (mandatory), a start command (optional), a stop command (optional), a list of customs commands (optional)
- List of agents used to execute commands described above
- Identity elements to run the following components for specific users
- Scheduling elements to scedule start/stop commands

A minimalist AppControl <em>Hello World</em> ARTEFACT:

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
	<hosts>
       <!-- The way to join the agent -->
		<host hostid="LOCAL" host="127.0.0.1" port="12567" sslprotocol="tls12" />
	</hosts>
	<auths>
        <!-- Identity of the user executing the commands. If empty, commands inherits from agent credentials -->
		<auth authid="LOCAL" domain="" password="" user="" />
	</auths>
	<app name="hello_world" version="v1" retry="1">
       <!-- A simple component executing an 'echo command' every minute -->
		<component name="test_map" hostref="LOCAL" authref="LOCAL" redirectoutput="true" checkFrequency="60" type="service">
			<action value="echo &quot;It's running&quot;" name="check" />
		</component>
	</app>
</apps>
```

#### The <em>apps</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
    <hosts>...</hosts>
    <auths>...</auths>
     <app>
       <component>
         ...
       </component>
       ...
     </app>
   <crontable>...</crontable>
</apps>
```

#### The <em>hosts</em> TAG

The `hosts` tag groups together a set of `host` tags describing the way to communicate with the agents.

The attributes of a **host** are:

| Attribute   | Description                                                                                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| host        | **Required** Value: string. Name to resolve or IPv4 address of the machine to be contacted on the network                                                            |
| port        | **Required** Value: integer. Tcp port number to use join the agent.                                                                                                  |
| hostid      | **Required** Value: string. Mnemonic name to designate the host agent and which will then be used as the value of the hostref attribute in a <em>component</em> tag. |
| sslprotocol | **Optional** Default value is set to tls12. Possible values: ssl, tls, tls12. <br>Note: on most Operating Systems ssl and tls are obsolete                           |

#### The <em>auths</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <auths>
     <auth authid="LOCAL" domain="" password="" user="" />
   </auths>
   <!-- ... -->
</apps>
```

The `auths` tag groups together a set of `auth` tags describing the identities used to perform actions of application components.
These identities will be used by agents.

| Attribute | Description                                                                                                                                                                           |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| authid    | **Required** Mnemonic name to designate the identity that will be used as the value of the authref attribute in a component tag                                                       |
| user      | **Required** . Can be empty. Username/Identity. If the value is empty, the username will be the one running the agent                                                                 |
| password  | **Required** Can be empty Value: string. Clear password of the user to identify. If the value is empty, as well as the username, the identity used will be the one running the agent. |
| domain    | **Optional** Microsoft Windows only, Windows domain name for authentication                                                                                                           |

#### The <em>app</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <app name="TrainingMap" version="current" cronref="MCO">
       <!-- ... -->
   </app>
   <!-- ... -->
</apps>
```

| Attribute | Description                                                                                                                          |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| name      | **Required** Mnemonic name to designate an application                                                                               |
| version   | **Required** . Mnemonic name of the application version. Perhaps in a numbered form "1.3.6", named "current" or mixed "1.3.6-Stable" |
| cronref   | **Optional** Reference to a "crontable"                                                                                              |
| retry     | **Optional** Value: integer. The value of the default number of retries to perform component actions on the application              |

#### The <em>component</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <app name="TrainingMap" version="current" cronref="MCO">
        <component name="File exist" group="TEST" hostref="LOCAL" authref="LOCAL">
            <action name="check" value="dir componentFile.txt" />
            <action name="enable" value="echo start > componentFile.txt" />
            <action name="custom" visibility="Public" commandname="File search" value="dir $(file)">
                <parameters>
                    <parameter name="file"
                        description="Filename to list"
                        value=""
                        canedit="true"
                        validation="\S+"
                    />
                </parameters>
            </action>
        </component>
   </app>
   <!-- ... -->
</apps>
```
### Component properties

| Attribute      | Description                                                                                                                                                                                                                                                                        |
| -------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name           | **Required** Name of the component (should be unique in the application                                                                                                                                                                                                                                                                           |
| group          | **Optional** Name of the group. Used to group a set of components in the UI                                                                                                                                                                                                                                                                       |
| hostref        | Value : string. Reference to the agent (see hosts tag). Mandatory if not set on the action                                                                                                                                                                                                                                                        |
| authref        | Value : string. Reference to the agent identity (see auths tag). Mandatory if not set on the action                                                                                                                                                                                                                                               |
| type           | **Optional** Used to display an icon on the map. An url to an image (png, jpeg or svg) can be set. Anyway you can use one of the following value: browser, cd, chip, data-information, devises, dollar, euro, file, green-thermometer, hdd, memflash, memory, middleware, network, orange-thermometer, pounds, process, service, tools, user, yen |
| description    | **Optional** Value: string Label of the component in addition to the name                                                                                                                                                                                                                                                                         |
| redirectoutput | **Optional** Value: True. If true, standard output will be parsed to find dynamic messages or dynamic components 																																																								 |                                                                                                                                                                                                                                                                                                                   |
| checkFrequency | **Optional** Value: integer. Component check cycle frequency (in seconds). Default value is set at server configuration level                                                                                                                                                                                                                     |
| retryNumber    | **Optional** Value: integer. Maximum number of attempts                                                                                                                                                                                                                                                                                           |
| displayname    | **Optional** Value: string. Display name of an application component replacing "name" in the UI                                                                                                                                                                                                                                                   |

#### The <em>father</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <app name="TrainingMap" version="current" cronref="MCO">
        <component name="File exist" group="TEST" hostref="LOCAL" authref="LOCAL">
            <father>Attribut NAME du COMPOSANT PERE #1</father>
            <father>Attribut NAME du COMPOSANT PERE #2</father>
            <action name="check" value="dir componentFile.txt" />
            <action name="enable" value="echo start > componentFile.txt" />
            <action name="check" value="del /Q componentFile.txt" />
            <action name="custom" visibility="Public" commandname="File search" value="dir $(file)">
                <parameters>
                    <parameter name="file"
                        description="Filename to list"
                        value=""
                        canedit="true"
                        validation="\S+"
                    />
                </parameters>
            </action>
        </component>
   </app>
   <!-- ... -->
</apps>
```

The `father` tag creates a dependency on a component. The AppControl approach is based on the fact that child components have the knowledge of father(s).
<br>Multiple fathers for a component are allowed.
<br>Be careful not to create a loop which is not allowed and generates an error during loading.

#### The <em>action</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <app name="TrainingMap" version="current" cronref="MCO">
        <component name="File exist" group="TEST" hostref="LOCAL" authref="LOCAL">
            <!-- ... -->
            <action name="check" value="dir componentFile.txt" />
            <action name="enable" value="echo start > componentFile.txt" />
            <action name="check" value="del /Q componentFile.txt" />
            <action name="custom" visibility="Public" commandname="File search" value="dir $(file)">
                <parameters>
                    <parameter name="file"
                        description="Filename to list"
                        value=""
                        canedit="true"
                        validation="\S+"
                    />
                </parameters>
            </action>
        </component>
   </app>
   <!-- ... -->
</apps>
```

The `action` tag is used to describe 4 kinds of actions:

- **check** : Periodic verification of the state of the component at a frequency in seconds. <em>Only one by component</em>
- **enable** : Starts a component <em>From 0 to 1 by component</em>
- **disable** : Stops a component <em>From 0 to 1 by component</em>
- **custom** : On demand commands <em>From 0 to n by component</em>

| Attribute   | Description                                                                                                                                                                                                                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name        | **Required** Value : check                                                                                                                                                                                                                                                                                                                        | enable | disable | custom |
| value       | **Required** Command line to execute                                                                                                                                                                                                                                                                                                              |
| retryTime   | **Optional** Value: integer. Time in seconds before retrying communication with the agent                                                                                                                                                                                                                                                         |
| commandname | **Required** Display name / Identifier of the command                                                                                                                                                                                                                                                                                             |
| visibility  | **Optional** Control the visibility of this custion action outside AppControl (in XC Scenario). If the value is Public, the AppControl worker will publish this action as a Scenario task. Default is Private, do not publish the action.                                                                                                                                                                                                                                                                                             |
| parameters  | **Optional** Used to display an icon on the map. An url to an image (png, jpeg or svg) can be set. Anyway you can use one of the following value: browser, cd, chip, data-information, devises, dollar, euro, file, green-thermometer, hdd, memflash, memory, middleware, network, orange-thermometer, pounds, process, service, tools, user, yen |
| hostref     | **Optional** Value : string. Reference to the agent (see hosts tag). Mandatory if not set on the component                                                                                                                                                                                                                                        |
| authref     | **Optional** Value : string. Reference to the agent identity (see auths tag). Mandatory if not set on the component                                                                                                                                                                                                                               |

###### The <em>parameters</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
   <!-- ... -->
   <app name="TrainingMap" version="current" cronref="MCO">
        <component name="File exist" group="TEST" hostref="LOCAL" authref="LOCAL">
            <!-- ... -->
             <action name="custom" visibility="Public" commandname="File search" value="dir $(file)">
                <parameters>
                    <parameter name="file"
                        description="Filename to list"
                        value=""
                        canedit="true"
                        validation="\S+"
                    />
                </parameters>
            </action>
        </component>
   </app>
   <!-- ... -->
</apps>
```

The `parameters` tag is used to describe parameters of custom actions. The parameters will be avaible in the UI.
<br>
The syntax of variables in AppControl is: $ (variableName)
In the tag, "parameters", several `parameter` tags will have the following attributes:

| Attribute   | Description                                                                                                |
| ----------- | ---------------------------------------------------------------------------------------------------------- |
| name        | **Required** Name of the variable                                                                          |
| description | **Optional** Description of the variable. This description is displayed in the UI                          |
| value       | **Required** Default value of the variable                                                                 |
| canedit     | **Optional** Values: True (Default) or False. If False it will not be possible to edit the value in the UI |
| validation  | **Optional** Value: regex. This regex is applied to the value.                                             |

#### The <em>crontable</em> TAG

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
	<crontable>
		<cronrules cronid="scheduling">
       	<trigger name="CRON#1" action="stop" force="true" components="A1" propagate="false" expression="0 00 * * * ? *" />
			<trigger name="CRON#2" action="start" force="true" components="A1" propagate="true" expression="0 15 * * * ? *" />
		    <trigger name="customDir" action="custom" components="A1" customactionname="dirAction" customactionparameters="option=c;directory=c:\temp"   expression="0 0/5 * 1/1 * ? *" />
			<trigger name="CRON#3" action="stop" expression="0 0/5 * 1/1 * ? *" />
			<trigger name="CRON#3" action="start" expression="0 0/2 * 1/1 * ? *" />
		</cronrules>
	</crontable>

	<app name="CronDemo" version="v1" cronref="scheduling">
	<component name="A1" description="A1 component" hostref="LOCAL" authref="LOCAL" >
			<action value="echo demo" name="check" />
			<action value="start.sh" name="enable"  />
			<action value="stop.sh" name="disable" />
			<action name="custom" commandname="Perl version" value="C:\Strawberry\perl\bin\perl.exe  -$(version)">
				<parameters>
					<parameter name="version" value="V" canedit="false" validation="*" />
				</parameters>
			</action>
			<action value="dir -$(option)  $(directory)" visibility="public" commandname="dirAction" name="custom">
				<parameters>
					<parameter name="option" value="c" canedit="false" validation="*" />
					<parameter name="directory" value="c:\sources\*" canedit="true" validation="*" />
				</parameters>
			</action>
		</component>
    </app>
</apps>
```

You can refer to the [Quartz Scheduler](https://www.quartz-scheduler.net/documentation/quartz-3.x/tutorial/crontrigger.html#introduction) link to have the complete documentation of allowed cron expressions.

As you can observe in the example above, you can be multiple cron expressions in the same file. You can schedule start/stop or customs actions.
