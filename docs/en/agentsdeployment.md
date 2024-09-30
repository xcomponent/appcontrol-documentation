### Deploy Agents Automatically via the Gateway

AppControl simplifies the process of deploying agents in your infrastructure by leveraging the gateway. To automate the deployment of agents, AppControl requires **SSH access** to the target infrastructure using the **private SSH key**. Below are the steps to configure SSH, generate SSH keys on both Linux and Windows, and provide the necessary key to enable automatic deployment.

#### 1. Configure SSH Access

For AppControl to deploy agents automatically, the gateway needs access to the target machines via SSH. Ensure that SSH is properly configured on your target systems.

-   **Port**: By default, SSH uses port 22, but AppControl allows you to customize this if needed.
-   **User Permissions**: The user account that AppControl will use for SSH should have the necessary permissions to install and manage agents on the target machine.

#### 2. Generate SSH Keys (Private Key Required by AppControl)

To allow AppControl to manage agent deployment via the gateway, the **private SSH key** must be provided. Follow the steps below to generate SSH keys on Linux or Windows.

##### Linux (or macOS)

To generate SSH keys on Linux or macOS:

1. Open a terminal.
2. Run the following command to generate a new SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/appcontrol_key
    ```

    - `-t rsa`: Specifies the RSA algorithm.
    - `-b 2048`: Specifies the key length (2048 bits).
    - `-f ~/.ssh/appcontrol_key`: Saves the key pair to the specified file (`appcontrol_key`).

3. When prompted for a passphrase, press **Enter** to leave it empty (or add a passphrase if required for extra security).

This command will generate two files:

-   **Private key**: `~/.ssh/appcontrol_key`
-   **Public key**: `~/.ssh/appcontrol_key.pub`

##### Windows

To generate SSH keys on Windows, you can use either **Git Bash** or **PowerShell** (with OpenSSH).

###### Option 1: Using Git Bash

1. Install [Git for Windows](https://gitforwindows.org/) if you haven’t already.
2. Open **Git Bash**.
3. Run the following command to generate an SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/appcontrol_key
    ```

4. When prompted, press **Enter** to use the default file location, and leave the passphrase empty (or add one if you prefer).

###### Option 2: Using PowerShell (Windows 10/11)

1. Open **PowerShell** as an administrator.
2. Run the following command to generate an SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 2048 -f $env:USERPROFILE\.ssh\appcontrol_key
    ```

This will generate two files:

-   **Private key**: `C:\Users\YourUsername\.ssh\appcontrol_key`
-   **Public key**: `C:\Users\YourUsername\.ssh\appcontrol_key.pub`

3. When prompted for a passphrase, press **Enter** to skip or provide a passphrase if additional security is needed.

#### 3. Provide the Private SSH Key to AppControl

AppControl requires the **private SSH key** for authentication during agent deployment. The **public key** is added to the target machines in the `~/.ssh/authorized_keys` file, and the **private key** remains with AppControl to establish the connection.

1. **Locate the Private Key**:
    - Linux: `~/.ssh/appcontrol_key`
    - Windows: `C:\Users\YourUsername\.ssh\appcontrol_key`
2. **Upload the Private Key to AppControl**:
    1. Log in to the AppControl dashboard.
    2. Navigate to **Gateway Configuration** and select the gateway that will manage the agent deployment.
    3. Upload the private SSH key (`appcontrol_key`).
    4. AppControl will securely store the key and use it for deploying agents.

> **Note**: The private SSH key remains confidential and is only used by AppControl to establish a secure SSH connection to the target machines. The corresponding public key should already be added to the `~/.ssh/authorized_keys` file on the target machines.

#### 4. Deploy Agents via the Gateway

Once SSH is configured and the private key is provided, follow these steps:

1. **Select the Target Machines**: In the AppControl dashboard, go to the "Deploy Agents" section and select the machines where agents should be deployed.
2. **Verify Connectivity**: AppControl will verify the SSH connection to the target machines using the private key.
3. **Deploy Agents**: Once the connection is established, AppControl will automatically deploy the agents to the selected machines.

#### 5. Troubleshooting SSH Connection

If you encounter any issues with the SSH connection, check the following:

-   Ensure that the private SSH key is properly configured and uploaded.
-   Verify that the SSH port and user permissions are correctly set up on the target machine.
-   Check firewall rules or network configurations that might block SSH access.

---
