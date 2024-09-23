# AppControl Application

In AppControl, applications (also referred to as "maps") were traditionally defined using an XML file. However, the preferred and modern format is now **YAML**, which offers greater flexibility and readability, making it easier to manage complex configurations.

Applications in AppControl are structured as a hierarchy of components, with each component representing a critical part of the system. These components can be defined manually by editing YAML files, giving you full control over every aspect of the application setup. For users who prefer a more guided approach, AppControl also provides **built-in wizards** within the UI. These wizards simplify the process by generating application definitions based on your local infrastructure or from Azure environments, allowing you to create these files quickly and efficiently.

Whether you choose to manually create your application configurations or leverage the built-in wizards, AppControl offers the flexibility to adapt to your preferred workflow, ensuring seamless integration with your existing systems.

---

## YAML Format

This document describes the configuration schema for AppControl applications, which is defined in **YAML format**. The YAML configuration file specifies the structure of an application, including its components, agents, authentication methods, scheduling, and actions.

If you're unfamiliar with YAML, you can learn more about it here: [YAML Documentation](https://yaml.org/).

In the YAML format, AppControl configurations are more readable and user-friendly. YAML offers greater support for advanced features and is the recommended format for defining applications in AppControl.

The YAML file typically includes the following key information:

-   **Component Definitions**: Each component is described by a set of commands:
    -   **Check Command**: Mandatory for verifying the component's status.
    -   **Start Command**: Optional, used to start the component.
    -   **Stop Command**: Optional, used to stop the component.
    -   **Custom Commands**: Optional, for executing specific tasks or actions tailored to the component.
-   **Agent List**: Specifies the agents responsible for executing the commands for each component.
-   **Identity Information**: Defines which users are authorized to run the commands for specific components.
-   **Scheduling Information**: Allows scheduling of start/stop commands for automatic execution at predefined times.

Full YAML Format described below:

### 1. Name

-   **Type**: `string`
-   **Description**: The name of the service.

### 2. Version

-   **Type**: `string`
-   **Description**: The version of the service.

### 3. Description

-   **Type**: `string`
-   **Description**: A brief description of the service.

### 4. NbRetry

-   **Type**: `integer`
-   **Description**: The number of restart attempts for the service.

### 5. Variables

-   **Type**: `array`
-   **Description**: A list of variables used by the service.
-   **Properties**:
    -   **Name**: The name of the variable (`string`).
    -   **Value**: The value of the variable (`string`).

### 6. Agents

-   **Type**: `array`
-   **Description**: A list of agents responsible for executing commands.
-   **Properties**:
    -   **Name**: The name of the agent (`string`).
    -   **Address**: The address of the agent (`string`).
    -   **Port**: The port used by the agent (`integer`).
    -   **Gateway**: The gateway used by the agent (`string`).
    -   **DependsOnComponent**: Specifies that the agent is triggered when the component is started (`string`).
    -   **SslProtocol**: The SSL protocol used by the agent (`tls`, `tls12`, or `tls13`).

### 7. Authentications

-   **Type**: `array`
-   **Description**: A list of authentication methods used for securing agent communications.
-   **Properties**:
    -   **Name**: The name of the authentication method (`string`).

### 8. SchedulingStart

-   **Type**: `array`
-   **Description**: Scheduling of start tasks using cron expressions.
-   **Properties**:
    -   **Name**: The name of the start task (`string`).
    -   **Expression**: The cron expression that defines the schedule (`string`).

### 9. SchedulingStop

-   **Type**: `array`
-   **Description**: Scheduling of stop tasks using cron expressions.
-   **Properties**:
    -   **Name**: The name of the stop task (`string`).
    -   **Expression**: The cron expression that defines the schedule (`string`).

### 10. Components

-   **Type**: `array`
-   **Description**: The components of the service, each defined by a set of properties and actions.
-   **Properties**:
    -   **Name**: The name of the component (`string`).
    -   **DisplayName**: The display name of the component (`string`).
    -   **Agent**: Defines the agent associated with the component, including:
        -   **AgentName**: The name of the agent (`string`).
        -   **AuthentificationName**: The name of the authentication method used (`string`).
    -   **CheckFrequency**: The frequency (in seconds) for checking the status of the component (`integer`).
    -   **Icon**: Icon properties, including:
        -   **SystemName**: The system name of the icon (e.g., `browser`, `sqlserver`, etc.) (`string`).
        -   **Url**: The URL for the icon (`string`).
    -   **Group**: The component's group (`string`).
    -   **Description**: A description of the component (`string`).
    -   **Actions**: A list of actions available for the component:
        -   **Name**: The name of the action (`string`).
        -   **Type**: The type of the action (`string`).
        -   **Value**: The command to execute the action (`string`).
        -   **RetryTime**: The time to retry the action (`integer`).
        -   **Visibility**: Visibility of the action (`Private`, `Public`).
        -   **WaitAfter**: Time to wait after the action (`integer`).
        -   **Description**: A description of the action (`string`).
        -   **InputParameters**: Input parameters for the action:
            -   **Name**: The name of the parameter (`string`).
            -   **Value**: The value of the parameter (`string`).
            -   **Description**: A description of the parameter (`string`).
            -   **CanEdit**: Specifies if the parameter can be edited (`boolean`).
            -   **Validation**: Validation rules for the parameter (`string`).
        -   **OutputParameters**: Output parameters for the action:
            -   **Name**: The name of the parameter (`string`).
            -   **Value**: The value of the parameter (`string`).
            -   **Description**: A description of the parameter (`string`).
        -   **HypertextResources**: Additional hypertext resources related to the action.

### 11. Triggers

-   **Type**: `array`
-   **Description**: Cron-based triggers for the components.
-   **Properties**:
    -   **Name**: The name of the trigger (`string`).
    -   **Expression**: The cron expression (`string`).
    -   **TimeZoneId**: The time zone ID for the trigger (`string`).

### 12. Filters

-   **Type**: `array`
-   **Description**: Filters that define specific conditions for components.
-   **Properties**:
    -   **Name**: The name of the filter (`string`).
    -   **Value**: The value for the filter (`string`).

### 13. InteractWithDesktop

-   **Type**: `boolean`
-   **Description**: (Windows only) Specifies if the agent running as a service can interact with the desktop.

---

## Required Fields

The following fields are **required** in the AppControl YAML configuration file:

-   **Name**
-   **Version**
-   **Description**
-   **NbRetry**
-   **Agents**
-   **Authentications**
-   **Components**

Below is an example of a minimalist AppControl **Hello World** artefact in **YAML**:

```yaml
Name: helloworld
Version: v1
Icon: {}
Agents:
    - Name: LOCAL
      Port: 12567
      SslProtocol: tls12
Authentications:
    - Name: LOCAL
Components:
    - Name: hello
      Agent:
          AgentName: LOCAL
          AuthentificationName: LOCAL
      Icon:
          SystemName: file
      Group: Hello group
      Description: Hello World
      Actions:
          - Name: check hello
            Type: check
            Value: cat hello.txt
          - Name: start hello
            Type: start
            Value: echo hello > hello.txt
          - Name: stop hello
            Type: stop
            Value: rm hello.txt
          - Name: Say Hello
            Type: custom
            Value: echo $(message)
            InputParameters:
                - Name: message
                  Value: Hello
                  CanEdit: true
                  Validation: '*'
```

## XML Format

While the XML format is still supported, it is generally less flexible and more complex than YAML. The XML format is often used for legacy configurations.

The XML file typically includes the following key information:

-   **Component Definitions**: Each component is described by a set of commands:

    -   **Check Command**: Mandatory for verifying the component's status.
    -   **Start Command**: Optional, used to start the component.
    -   **Stop Command**: Optional, used to stop the component.
    -   **Custom Commands**: Optional, for executing specific tasks or actions tailored to the component.

-   **Agent List**: Specifies the agents responsible for executing the commands for each component.

-   **Identity Information**: Defines which users are authorized to run the commands for specific components.

-   **Scheduling Information**: Allows scheduling of start/stop commands for automatic execution at predefined times.

Below is an example of a minimalist AppControl Hello World artefact in XML:

```xml
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<apps>
    <hosts>
       <!-- The way to join the agent -->
        <host hostid="LOCAL" host="127.0.0.1" port="12567" sslprotocol="tls12" />
    </hosts>
    <auths>
        <!-- Identity of the user executing the commands. If empty, commands inherit from agent credentials -->
        <auth authid="LOCAL" domain="" password="" user="" />
    </auths>
    <app name="helloworld" version="v1" retry="1">
       <!-- A simple component executing an 'echo command' every minute -->
        <component name="hello" hostref="LOCAL" authref="LOCAL" redirectoutput="true" checkFrequency="60" type="file">
            <action value="cat hello.txt" name="check" />
            <action value="echo hello > hello.txt" name="enable" />
            <action value="rm hello.txt" name="disable" />
            <action value="echo $(message)" commandname="echo Action" name="custom">
                <parameters>
                    <parameter name="message" value="Hello" canedit="true" validation="*" />
                </parameters>
            </action>
        </component>
    </app>
</apps>

```

---

### XML Tag Descriptions

### The `<apps>` Tag

The `<apps>` tag is the root element that contains all the elements of the configuration.

```xml
<apps>
    <hosts>...</hosts>
    <auths>...</auths>
    <app>...</app>
    <crontable>...</crontable>
</apps>
```

### The `<hosts>` Tag

The `hosts` tag groups together a set of `host` tags that describe the agents used to communicate with the components.

| Attribute   | Description                                                                                                                                                          |
| ----------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| host        | **Required** Value: string. Name to resolve or IPv4 address of the machine to be contacted on the network                                                            |
| port        | **Required** Value: integer. Tcp port number to use join the agent.                                                                                                  |
| hostid      | **Required** Value: string. Mnemonic name to designate the host agent and which will then be used as the value of the hostref attribute in a <em>component</em> tag. |
| sslprotocol | **Optional** Default value is set to tls12. Possible values: ssl, tls, tls12. <br>Note: on most Operating Systems ssl and tls are obsolete                           |

### The `<auths>` Tag

The `auths` tag groups together a set of `auth` tags that describe the identities used to perform actions on application components. These identities will be utilized by agents.

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

| Attribute | Description                                                                                                                                                                                       |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| authid    | **Required** A mnemonic name used to identify the identity that will be referenced by the `authref` attribute in a component tag.                                                                 |
| user      | **Required** Can be empty. The username or identity. If this value is empty, the username will default to the one running the agent.                                                              |
| password  | **Required** Can be empty. Value: string. The user's clear text password for authentication. If both the username and password are empty, the identity will default to the one running the agent. |
| domain    | **Optional** Microsoft Windows only. The Windows domain name for authentication.                                                                                                                  |

                                                                                                  |

### The `<app>` Tag

The `app` tag defines the application and its version It can also contain a reference to a cron schedule for automatic actions.

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

### The `<component>` Tag

The `component` tag defines the individual components of the application and their actions (check, start, stop, custom).

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

| Attribute      | Description                                                                                                                                                                                                                                                                                                                                       |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name           | **Required** Name of the component (should be unique in the application).                                                                                                                                                                                                                                                                         |
| group          | **Optional** Name of the group. Used to group a set of components in the UI.                                                                                                                                                                                                                                                                      |
| hostref        | **Mandatory** Value: string. Reference to the agent (see `<hosts>` tag). Required if not set on the action.                                                                                                                                                                                                                                       |
| authref        | **Mandatory** Value: string. Reference to the agent identity (see `<auths>` tag). Required if not set on the action.                                                                                                                                                                                                                              |
| type           | **Optional** Used to display an icon on the map. A URL to an image (png, jpeg, or svg) can be set. You can also use one of the following values: browser, cd, chip, data-information, devices, dollar, euro, file, green-thermometer, hdd, memflash, memory, middleware, network, orange-thermometer, pounds, process, service, tools, user, yen. |
| description    | **Optional** Value: string. Label of the component in addition to the name.                                                                                                                                                                                                                                                                       |
| redirectoutput | **Optional** Value: boolean. If set to true, standard output will be parsed to find dynamic messages or dynamic components.                                                                                                                                                                                                                       |
| checkFrequency | **Optional** Value: integer. Component check cycle frequency (in seconds). The default value is set at the server configuration level.                                                                                                                                                                                                            |
| retryNumber    | **Optional** Value: integer. Maximum number of retry attempts.                                                                                                                                                                                                                                                                                    |
| displayname    | **Optional** Value: string. Display name of an application component, replacing "name" in the UI.                                                                                                                                                                                                                                                 |

#### The <em>father</em> TAG

The `father` tag creates a dependency on a component. AppControl's approach is based on the principle that child components have knowledge of their parent(s).  
Multiple parents for a component are allowed.  
However, be careful not to create a loop, as it is not allowed and will generate an error during loading.

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

#### The <em>action</em> TAG

The `action` tag is used to describe four kinds of actions:

-   **check**: Periodic verification of the component's state at a specified frequency (in seconds). Only one `check` action is allowed per component.
-   **enable**: Starts a component. Only one `enable` action is allowed per component.
-   **disable**: Stops a component. Only one `disable` action is allowed per component.
-   **custom**: Custom commands executed on demand. There can be 0 to n `custom` actions per component.

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

| Attribute   | Description                                                                                                                                                                                                                                                                                                                                       |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name        | **Required** Value: Specifies the type of check. Possible values: `enable`, `disable`, `custom`.                                                                                                                                                                                                                                                  |
| value       | **Required** The command line to execute.                                                                                                                                                                                                                                                                                                         |
| retryTime   | **Optional** Value: integer. Time in seconds before retrying communication with the agent.                                                                                                                                                                                                                                                        |
| commandname | **Required** Display name or identifier of the command.                                                                                                                                                                                                                                                                                           |
| visibility  | **Optional** Controls the visibility of this custom action outside of AppControl (in XC Scenario). If set to `Public`, the AppControl worker will publish this action as a Scenario task. The default is `Private`, meaning the action will not be published.                                                                                     |
| parameters  | **Optional** Used to display an icon on the map. A URL to an image (png, jpeg, or svg) can be set. You can also use one of the following values: browser, cd, chip, data-information, devices, dollar, euro, file, green-thermometer, hdd, memflash, memory, middleware, network, orange-thermometer, pounds, process, service, tools, user, yen. |
| hostref     | **Optional** Value: string. Reference to the agent (see `<hosts>` tag). Required if not set on the component.                                                                                                                                                                                                                                     |
| authref     | **Optional** Value: string. Reference to the agent identity (see `<auths>` tag). Required if not set on the component.                                                                                                                                                                                                                            |

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

The `parameters` tag is used to define the parameters of custom actions. These parameters will be available in the UI.

The syntax for variables in AppControl is: `$(variableName)`  
Within the `parameters` tag, several `parameter` tags can be defined with the following attributes:

| Attribute   | Description                                                                                         |
| ----------- | --------------------------------------------------------------------------------------------------- |
| name        | **Required** The name of the variable.                                                              |
| description | **Optional** A description of the variable. This description is displayed in the UI.                |
| value       | **Required** The default value of the variable.                                                     |
| canedit     | **Optional** Values: `True` (default) or `False`. If `False`, the value cannot be edited in the UI. |
| validation  | **Optional** Value: regex. A regular expression applied to validate the value.                      |

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

You can refer to the [Quartz Scheduler](https://www.quartz-scheduler.net/documentation/quartz-3.x/tutorial/crontrigger.html#introduction) documentation for a complete list of allowed cron expressions.

As shown in the example above, you can include multiple cron expressions in the same file. You can schedule start/stop actions or custom actions.

---

## Built-in wizards

### Auto-Generate Application from Running Processes

AppControl includes the ability to **retrieve running processes** on a computer through its agent. The agent, which runs on the target system (Windows or Linux), scans the machine for all active processes and reports them back to AppControl.

In the **AppControl wizard**, this data is then utilized to allow you to easily create applications (also referred to as "maps"). The wizard displays the list of running processes, and you can select the ones you wish to include in your application definition. Once selected, AppControl automatically generates a YAML file that represents the application.

The generated application is capable of **starting, stopping, and checking the status** of the selected processes. This provides a seamless way to monitor and control your applications' critical components without the need for manual configuration, ensuring that you can manage both legacy and modern systems efficiently.

-   To start the wizard go to **Overview/New application** and select **Discover your infrastructure**
-   Select: **From Servers** and then select your gateway and your agent.

<div style="display: flex; justify-content: center; align-items: center;">
<img src="/images/wizardprocess1.png" alt="wizard" style="width: 400px; height: auto; margin-right: 15px;" />
<img src="/images/wizardprocess2.png" alt="wizard" style="width: 400px; height: auto; margin-right: 15px;" />
</div>

### Auto-Generate Application from Azure Tenant

AppControl includes the ability to **retrieve and visualize Azure resources** from your Azure tenant through its integration with Azure APIs. Using its agent which interacts directly with your Azure environment, AppControl can scan your Azure tenant for all active resources and report them back to AppControl.

In the AppControl wizard, this data is utilized to help you easily create applications (also referred to as "maps"). The wizard displays a list of your Azure resources, such as virtual machines, databases, and other components, allowing you to select the ones you wish to include in your application definition. Once selected, AppControl automatically generates a YAML file that represents the application based on your Azure infrastructure.

The generated application is capable of starting, stopping, and checking the status of the selected Azure resources, providing a seamless way to monitor and control your critical cloud components. This eliminates the need for manual configuration and ensures that you can manage both cloud-native and hybrid environments efficiently.

Before starting the wizard, you have the good credentials.

To use the Azure discovery feature in AppControl, you will need to create an Azure Service Principal with sufficient permissions to allow AppControl to interact with your Azure resources.

**Step 1:** Create a Service Principal

1. **Open your terminal** or command-line interface.
2. **Run the following command** to create a service principal and assign it the "Reader" role (sufficient for discovery and read-only access to resources). It's better to limit the scope to specific resources but it's not mandatory.
   Ensure that you replace <subscription-id> with your actual Azure subscription ID:

```bash
az ad sp create-for-rbac --name "AppControlServicePrincipal" --role Reader  --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>
```

3. **Output:** The command will return a JSON object containing:

AppId (Client ID)
Password (Client secret)
Tenant (Tenant ID)
Subscription ID (Subscription scope where the role is assigned)
Save this information securely as it will be required for configuring AppControl.

**Step 2:** Assign Permissions (OPTIONAL)

If you need to limit the service principal's permissions to specific resource groups, or if you need to grant more access (such as managing resources), you can assign additional roles. For example, to restrict access to specific resource groups, use this command:

```bash
az role assignment create \
    --role Reader \
    --assignee <AppId> \
    --scope /subscriptions/<subscription-id>/resourceGroups/<resource-group-name>
```

**Step 3:** Configure AppControl with the Service Principal Credentials

Once you’ve created the Service Principal, you need to provide the credentials to AppControl for authentication.

1. Navigate to **Overview/New application** and select **Discover your infrastructure**.
2. Choose **From Azure**
3. Enter the Client User Name, Client Password (obtained when creating the Service Principal), Tenant ID, Subscription ID and Tenant ID.

AppControl will use these credentials to authenticate with Azure and retrieve your resources.

<div style="display: flex; justify-content: center; align-items: center;">
<img src="/images/wizardazure.png" alt="wizard" style="width: 400px; height: auto; margin-right: 15px;" />
</div>

This feature empowers you to visualize and manage your entire Azure infrastructure directly from AppControl, ensuring real-time control over your cloud assets.
