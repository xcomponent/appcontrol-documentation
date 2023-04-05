# X4B Gateway


## Latest Available versions

| Operating System | Format| Latest version |
| -----------------|------|------------|
| Microsoft Windows | zip | [Windows Gateway Zip](https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/x4bgateway.zip) |  
| N/A|  docker | docker pull xcomponent/x4b-gateway:latest |


X4B Gateway is necessary to take advantage of agents deployed on premises.

Agents can be deployed anywhere on your I.S. They don't need to have an internet access.

Please refer to the agents installation section for agents installation.

![Network architecture](../images/architectures-X4BCLI.svg)

Thanks to X4B Gateway, you can deploy your applications in the AppControl Cloud Platform with Agents deployed on premises.

#### How does it work ?

The first step, is to go log-in on [AppControl](https://appcontrol.xcomponent.com).

1. Navigate to **Gateways** and click on **Register New Gateway**
   ![Agent Proxy Settings](../images/agentproxy1.png)

2. Give a name to your gateway and validate.

3. Once your gateway is created, an Access Key and a Secret Access Key are generated.

![Gateway Settings](../images/agentproxy2.png)

4. We are ready to install the X4B Gateway. Please refer to the below documentation for the installation procedure.
5. Because X4B Gateway communicates with agents, you need to install at least one agent.
6. Once your X4B Gateway and your agent are up and running, your are ready to deploy a new application.

### X4B Gateway installation

The first step is to retrieve the X4B Gateway credentials. Navigate to the **Gateway** page and note the following informations:

- Name
- Access Key
- Secret Access Key

![Agent Proxy Settings](../images/agentproxy3.png)

## Microsoft Windows Platform

On Microsoft Windows, the [.NET Framework 4.7.2](https://dotnet.microsoft.com/download/dotnet-framework/net472) or above is required .

Most of the time it is already installed. Unzip the following [file](https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/x4bgateway.zip).

On a prompt (cmd.exe), execute the following command line.
Replace MY_ACCESS_KEY, MY_SECRET_ACCESSKEY and MY_GATEWAY_NAME with the suitable values.

```console
c:\x4b> x4b appcontrol run -a MY_ACCESS_KEY -p MY_SECRET_ACCESSKEY -n MY_GATEWAY_NAME -l Trace
```

You can also, set the following environment variables:

```console
c:\x4b> set X4B_ACCESS_KEY = MY_ACCESS_KEY
c:\x4b> set X4B_SECRET_ACCESS_KEY = MY_SECRET_ACCESSKEY
c:\x4b> set X4B_GATEWAY_NAME = MY_GATEWAY_NAME
```

Once these environment variables are set, you can run the gateway using the following command line:

```console
c:\x4b> x4b appcontrol run -l Trace
```

If the configuration is correct, you should observe the following lines in the terminal:

```console
  __  ______ ___  __  __ ____   ___  _   _ _____ _   _ _____
 \ \/ / ___/ _ \|  \/  |  _ \ / _ \| \ | | ____| \ | |_   _|
  \  / |  | | | | |\/| | |_) | | | |  \| |  _| |  \| | | |
  /  \ |__| |_| | |  | |  __/| |_| | |\  | |___| |\  | | |
 /_/\_\____\___/|_|  |_|_|    \___/|_| \_|_____|_| \_| |_|


XComponent For Business by Invivoo Software - 2021
25/02/2021 09:15:20# X4B Proxy is up and running... (Press Ctrl+C to exit)
25/02/2021 09:15:21# Waiting for websocket connection
25/02/2021 09:15:39# HeartBeat successfully published
25/02/2021 09:15:39# Websocket connection established

```

## Run the gateway as a Microsoft Windows service

In a prompt with administrative permissions:

```console
c:\x4b> x4b install -servicename x4bGatewayServiceName  -server "https://appcontrol.xcomponent.com/core" -loglevel "Trace" -access "myAccesToken" -proxyname "myGatewayName" -secret "mySecretToken"
```

The first parameters to register the gateway as a service is the topshelf syntax: 

[Topshelf Command-Line Reference — Topshelf 3.0 documentation](http://docs.topshelf-project.com/en/latest/overview/commandline.html)


The following parameters are specific to the gateway:

-server "https://appcontrol.xcomponent.com/core" -loglevel "Trace" -access "myAccesToken" -proxyname "myGatewayName" -secret "mySecretToken"



## Deployment using Docker

The docker image is available on docker hub: [x4b-gateway](https://hub.docker.com/r/xcomponent/xcomponent/x4b-gateway)

```console
docker run -e X4B_ACCESS_KEY=MY_ACCESS_KEY -e X4B_SECRET_ACCESS_KEY=MY_SECRET_ACCESSKEY -e X4B_GATEWAY_NAME=MY_GATEWAY_NAME xcomponent/x4b-cli:latest
```

If the configuration is correct, you should observe the following lines in the terminal:

```console
  __  ______ ___  __  __ ____   ___  _   _ _____ _   _ _____
 \ \/ / ___/ _ \|  \/  |  _ \ / _ \| \ | | ____| \ | |_   _|
  \  / |  | | | | |\/| | |_) | | | |  \| |  _| |  \| | | |
  /  \ |__| |_| | |  | |  __/| |_| | |\  | |___| |\  | | |
 /_/\_\____\___/|_|  |_|_|    \___/|_| \_|_____|_| \_| |_|


XComponent For Business by Invivoo Software - 2021
25/02/2021 09:15:20# X4B Proxy is up and running... (Press Ctrl+C to exit)
25/02/2021 09:15:21# Waiting for websocket connection
25/02/2021 09:15:39# HeartBeat successfully published
25/02/2021 09:15:39# Websocket connection established

```
