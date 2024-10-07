### Deploy Agents Automatically via the Gateway

AppControl simplifies the process of deploying agents in your infrastructure by leveraging the gateway. To automate the deployment of agents, AppControl requires **SSH access** to the target infrastructure using the **private SSH key**. Below are the steps to configure SSH, generate SSH keys on both Linux and Windows, and provide the necessary key to enable automatic deployment.

---

#### 1. Configure SSH Access

For AppControl to deploy agents automatically, the gateway needs access to the target machines via SSH. Ensure that SSH is properly configured on your target systems.

-   **Port**: By default, SSH uses port 22, but AppControl allows you to customize this if needed.
-   **User Permissions**: The user account that AppControl will use for SSH must have sufficient permissions to install and manage agents on the target machine.

> **Note**: The **public SSH key** must be added to the `~/.ssh/authorized_keys` file on the SSH server of the target machines. This ensures that AppControl can authenticate using the corresponding **private SSH key**.

---

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

3. When prompted for a passphrase, press **Enter** to leave it empty (or add a passphrase if extra security is required).

This command will generate two files:

-   **Private key**: `~/.ssh/appcontrol_key`
-   **Public key**: `~/.ssh/appcontrol_key.pub`

4. Add the **public key** to the `authorized_keys` file on the target machine:

    ```bash
    cat ~/.ssh/appcontrol_key.pub >> ~/.ssh/authorized_keys
    ```

##### Windows

To generate SSH keys on Windows, you can use either **Git Bash** or **PowerShell** (with OpenSSH).

###### Option 1: Using Git Bash

1. Install [Git for Windows](https://gitforwindows.org/) if not already installed.
2. Open **Git Bash**.
3. Run the following command to generate an SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 2048 -f ~/.ssh/appcontrol_key
    ```

4. When prompted, press **Enter** to use the default file location, and leave the passphrase empty (or add one if preferred).

5. Add the **public key** to the `authorized_keys` file on the target machine:

    ```bash
    cat ~/.ssh/appcontrol_key.pub >> ~/.ssh/authorized_keys
    ```

###### Option 2: Using PowerShell (Windows 10/11)

1. Open **PowerShell** as an administrator.
2. Run the following command to generate an SSH key pair:

    ```bash
    ssh-keygen -t rsa -b 2048 -f $env:USERPROFILE\.ssh\appcontrol_key
    ```

This will generate two files:

-   **Private key**: `C:\Users\YourUsername\.ssh\appcontrol_key`
-   **Public key**: `C:\Users\YourUsername\.ssh\appcontrol_key.pub`

3. Add the **public key** to the `authorized_keys` file on the target machine:

    ```powershell
    Get-Content $env:USERPROFILE\.ssh\appcontrol_key.pub | Out-File -Append -Encoding ascii $env:USERPROFILE\.ssh\authorized_keys
    ```

---

#### 3. SSH Server on Windows (Optional)

For Windows systems, you can optionally deploy an SSH server to allow AppControl to connect and manage agents. **OpenSSH Server** is an optional feature in Windows, which you can enable via the following steps:

1. Go to **Settings** > **Apps** > **Optional Features**.
2. Scroll down and click **Add a feature**.
3. Search for **OpenSSH Server**, select it, and click **Install**.

> For more detailed instructions, refer to the [official Windows documentation](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse).

Once installed, configure the SSH server, and ensure the **public key** is added to the `authorized_keys` file.

---

### 4. Deploy Agents via the Gateway

Once SSH is configured and the private key is provided, follow these steps to deploy agents using the AppControl gateway:

1. **Select the Target Machines**:

    - In the AppControl dashboard, go to the **"Deploy Agents"** section and select the machines where agents should be deployed.

2. **Verify Connectivity**:

    - AppControl will verify the SSH connection to the target machines using the private SSH key.

3. **Deploy Agents**:
    - Once the connection is established, AppControl will automatically deploy the agents to the selected machines.

> **Installation Paths**:

-   On **Windows**: Agents will be installed in `C:/ProgramData/appcontrol/agent`.
-   On **Linux**: The installation folder is `/opt/appcontrol/xcagent`.
-   On **macOS**: The installation folder is `~/appcontrol/xcagent`.

---

#### 5. Troubleshooting SSH Connection

If you encounter issues with the SSH connection during the deployment process, check the following:

1. **Private SSH Key**:

    - Ensure that the private SSH key is properly configured and uploaded to AppControl.

2. **SSH Port and User Permissions**:

    - Verify that the SSH port and user permissions are correctly set up on the target machine.

3. **Firewall and Network Configuration**:
    - Check firewall rules or network configurations that might block SSH access to the target machine.

---

#### 6. Provide the Private SSH Key to AppControl

AppControl requires the **private SSH key** for authentication during agent deployment. The **public key** is added to the target machines in the `~/.ssh/authorized_keys` file, and the **private key** remains with AppControl to establish the connection.

1. **Locate the Private Key**:
    - **Linux**: `~/.ssh/appcontrol_key`
    - **Windows**: `C:\Users\YourUsername\.ssh\appcontrol_key`
2. **Upload the Private Key to AppControl**:
    1. Log in to the AppControl dashboard.
    2. Navigate to **Gateway Configuration** and select the gateway that will manage the agent deployment.
    3. Upload the private SSH key (`appcontrol_key`).
    4. AppControl will securely store the key and use it for deploying agents.

> **Note**: The private SSH key remains confidential and is only used by AppControl to establish a secure SSH connection to the target machines. The corresponding public key should already be added to the `~/.ssh/authorized_keys` file on the target machines.
