# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$bannerText = "

**************************************

    AppControl Gateway & Agent installer

**************************************

"
    Write-Host $bannerText -ForegroundColor White
    Write-Host
    Write-Host
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# Get the full path of the script
$scriptPath = $MyInvocation.MyCommand.Path

# Check if the script is running locally
$isLocalExecution = $scriptPath -eq $ExecutionContext.SessionState.Path.CurrentLocation.Path

# Check if the script is running with administrative privileges
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "This script requires administrative privileges."
    if($isLocalExecution)
    {
        $choice = Read-Host "Do you want to relaunch the script as an administrator? (Y/N)"

        if ($choice -eq 'Y' -or $choice -eq 'y') {
            Write-Host "Relaunching script with elevated privileges..."
            Start-Process powershell.exe -Verb RunAs -ArgumentList "-File $scriptPath"
            Exit
        } else {
            Write-Host "Exiting the script. Run the script as an administrator to proceed."
            Exit
        }
    }
    else {
            Write-Host "Exiting the script. Run the script as an administrator to proceed."
            Exit
        }
    
}

$appcontrolRootUrl = "https://appcontrol.xcomponent.com";
$appcontrolUrl = "$appcontrolRootUrl/core";
$apiEndpoint = "$appcontrolUrl/api/DevicesRegistration"

# Make the API request
$response = Invoke-RestMethod -Uri $apiEndpoint -Method Get

# Assuming the API returns a string, you can access it like this
$codeString = $response


# Display a clickable hyperlink in PowerShell 7 or Windows Terminal
Write-Host "Please, log-in here " -ForegroundColor Blue -NoNewline
Write-Host " $appcontrolRootUrl/register/gateways" -NoNewline -ForegroundColor Green
Write-Host " and enter this code: $codeString"

# Define the interval between each poll (in seconds)
$pollingInterval = 5

# Function to check the login status
# Function to check the login status
function CheckLoginStatus {
    $body = @{
        Code = $codeString
    } | ConvertTo-Json
    try{
        $response = Invoke-RestMethod -Uri $apiEndpoint -Method Post -Body $body -ContentType 'application/json'
        return $response
    }
    catch {
        # Display exception information
        Write-Host "Exception Type: $($_.Exception.GetType().FullName)"
        Write-Host "Exception Message: $($_.Exception.Message)"
        Write-Host "Stack Trace: $($_.Exception.StackTrace)"
        # You can access other properties of the exception as needed
    }

}

# Loop until the user is logged in
while ($true) {
    $loginStatus = CheckLoginStatus | ConvertTo-Json
    # Convert back from JSON to a PowerShell object
    $loginStatusObject =  $loginStatus | ConvertFrom-Json
    $gatewayProperty = $loginStatusObject.Gateway
    $accessKeyProperty = $loginStatusObject.AccessKey
    $secretAccessKeyProperty = $loginStatusObject.SecretAccessKey
    
    if ($null -ne $gatewayProperty -and $null -ne $accessKeyProperty -and $null -ne $secretAccessKeyProperty) {
        Write-Host
        Write-Host "Registration has been successfully done!"

        # Extract properties from the JSON response and set environment variables
        $gatewayName = $gatewayProperty
        $accessKey = $accessKeyProperty
        $secretAccessKey = $secretAccessKeyProperty
        break
    }

    Write-Host "." -NoNewline
    # If the user is not logged in, wait for the specified interval before the next poll
    Start-Sleep -Seconds $pollingInterval
}

$x4bgatewayUrl = 'https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/x4bgateway.zip'
$appcontrolAgent = 'https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcAgent-binary-Win32.zip'

$agentServiceName="XComponentAppControlAgent"
$gatewayServiceName="x4bGatewayService"





# Build the full path to the %APPDATA% directory
$appDataPath = [System.IO.Path]::Combine($env:APPDATA, "AppControl")
$agentDataPath = [System.IO.Path]::Combine($appDataPath, "xcagent")
$gatewayDataPath = [System.IO.Path]::Combine($appDataPath, "gateway")

if (Test-Path -Path $appDataPath -PathType Container) {

$bannerText = "

**************************************

    AppControl is already installed

**************************************

"
    Write-Host $bannerText -ForegroundColor White

    # Check if the service exists
    if (Get-Service -Name $agentServiceName -ErrorAction SilentlyContinue) {
        Write-Host "Removing agent service..."  -NoNewline  -ForegroundColor Yellow
        Stop-Service -Name $agentServiceName | Out-Null
        # Remove the service
        $serviceController = (Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq $agentServiceName })
        $serviceController.Delete() | Out-Null
        Write-Host "The service '$agentServiceName' has been removed."  -ForegroundColor Green
    } 
    if (Get-Service -Name $gatewayServiceName -ErrorAction SilentlyContinue) {
        Stop-Service -Name $gatewayServiceName | Out-Null
        Write-Host "Removing gateway service..."  -NoNewline  -ForegroundColor Yellow
        # Remove the service
        $serviceController = (Get-WmiObject -Class Win32_Service | Where-Object { $_.Name -eq $gatewayServiceName })
        $serviceController.Delete() | Out-Null
        Write-Host "The service '$gatewayServiceName' has been removed."  -ForegroundColor Green
    } 
    Remove-Item -Path $appDataPath -Recurse -Force | Out-Null
    Write-Host 
    Write-Host 
    Write-Host "Previous AppControl version has been sucessfully deleted."  -ForegroundColor Green
}

New-Item -ItemType Directory -Path $agentDataPath -Force | Out-Null
New-Item -ItemType Directory -Path $gatewayDataPath -Force | Out-Null

$bannerText = "
    
**************************************

          Gateway Installation

**************************************

"
Write-Host $bannerText -ForegroundColor White

Write-Host "Downloading gateway package... "  -NoNewline  -ForegroundColor Yellow
Invoke-WebRequest -Uri $x4bgatewayUrl -OutFile "$gatewayDataPath\gateway.zip" -UseBasicParsing
Write-Host "Package downloaded"  -ForegroundColor Green
Write-Host "Installing gateway binaries... " -NoNewline  -ForegroundColor Yellow
Expand-Archive -Path "$gatewayDataPath\gateway.zip" -DestinationPath $gatewayDataPath
Remove-Item -Path "$gatewayDataPath\gateway.zip" -Force | Out-Null
Write-Host "Gateway binaries installed"  -ForegroundColor Green

Write-Host "Installing gateway service... "  -NoNewline  -ForegroundColor Yellow
# Start the process
$x4bprocess = New-Object System.Diagnostics.Process 
$x4bprocess.StartInfo.FileName = "$gatewayDataPath\x4b.exe" 
$x4bprocess.StartInfo.Arguments = "install -servicename x4bGatewayService -a $accessKey -p $gatewayName -k $secretAccessKey -u $appcontrolUrl"
$x4bprocess.StartInfo.UseShellExecute = $false
$x4bprocess.StartInfo.RedirectStandardOutput = $false
$x4bprocess.StartInfo.RedirectStandardError = $false
$x4bprocess.StartInfo.RedirectStandardInput = $true
$x4bprocess.StartInfo.CreateNoWindow = $true
$x4bprocess.Start() | Out-Null

# Simulate pressing "Enter" by providing a newline character as input
$x4bprocess.StandardInput.WriteLine()


$x4bprocess.WaitForExit()

$x4bprocess.Close()

Write-Host "Gateway service installed" -ForegroundColor Green
Write-Host "Starting Gateway service... "  -NoNewline  -ForegroundColor Yellow
Start-Service -Name $gatewayServiceName | Out-Null
Write-Host "Gateway service started" -ForegroundColor Green

$bannerText = "
    
**************************************

         Agent Installation

**************************************

"
Write-Host $bannerText -ForegroundColor White

Write-Host "Downloading agent package... " -NoNewline  -ForegroundColor Yellow
Invoke-WebRequest -Uri $appcontrolAgent -OutFile "$agentDataPath\agent.zip" -UseBasicParsing
Write-Host "Package downloaded"  -ForegroundColor Green
Write-Host "Installing agent binaries... " -NoNewline  -ForegroundColor Yellow
Expand-Archive -Path "$agentDataPath\agent.zip" -DestinationPath $agentDataPath | Out-Null
Remove-Item -Path "$agentDataPath\agent.zip" -Force | Out-Null
Write-Host "Agent binaries installed" -ForegroundColor Green
Write-Host "Installing agent service... "  -NoNewline  -ForegroundColor Yellow

$agentprocess = New-Object System.Diagnostics.Process 
$agentprocess.StartInfo.FileName = "$agentDataPath\xcAgent.exe"
$agentprocess.StartInfo.Arguments = "--install"
$agentprocess.StartInfo.UseShellExecute = $false
$agentprocess.StartInfo.RedirectStandardOutput = $false
$agentprocess.StartInfo.RedirectStandardError = $false
$agentprocess.StartInfo.RedirectStandardInput = $false
$agentprocess.StartInfo.CreateNoWindow = $true
$agentprocess.Start() | Out-Null
$agentprocess.WaitForExit()
$agentprocess.Close()

Write-Host "Agent service installed"  -ForegroundColor Green
Write-Host "Starting Agent service... " -NoNewline  -ForegroundColor Yellow
Start-Service -Name $agentServiceName | Out-Null
Write-Host "Agent service started" -ForegroundColor Green

$bannerText = "
    
**************************************

    Installation done !!!!

**************************************

"
Write-Host $bannerText -ForegroundColor White


