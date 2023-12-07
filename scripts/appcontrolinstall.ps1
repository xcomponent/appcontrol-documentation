# Check the instructions here on how to use it https://massgrave.dev/

$ErrorActionPreference = "Stop"
# Enable TLSv1.2 for compatibility with older clients
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

$x4bgatewayUrl = 'https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/x4bgateway.zip'
$appcontrolAgent = 'https://github.com/xcomponent/appcontrol-documentation/releases/latest/download/xcAgent-binary-Win32.zip'

$agentServiceName="XComponentAppControlAgent"
$gatewayServiceName="x4bGatewayService"

$bannerText = "
    
**************************************

        Filling gateway settings

**************************************

"
Write-Host $bannerText -ForegroundColor White

# Prompt the user to enter a value for the variable
$gatewayName = Read-Host "Gateway name"
$accessKey = Read-Host "Gateway Access Key"
$secretAccessKey = Read-Host "Gateway Secret Access Key"


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
$x4bprocess.StartInfo.Arguments = "install -servicename x4bGatewayService -a $accessKey -p $gatewayName -k $secretAccessKey"
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


