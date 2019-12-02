# Install Powershell PowerShell Core
# https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-6#powershell-core

# Install AZ Module. Requires admin privileges.
Install-Module -Name Az -AllowClobber -Scope AllUsers 

# Clone or download AZ Lab Service / DevTest repo at https://github.com/Azure/azure-devtestlab.git

# Import AZ Lab Service module from cloned repo
Import-Module "<PATH_TO_azure-devtestlab>/Az.LabServices.psm1"

# Connect to your Azure account
Connect-AzAccount

# Set Subscription
Select-AzSubscription -SubscriptionID "YOUR_SUBSCRIPTION_ID"

# Get the labs for all the lab accounts
Get-AzLabAccount | Get-AzLab

# Browse all the functions in the library
Get-Command -Module Az.LabServices

# The following snippet create and publishes a new lab

$vmResourceGroupName = "rg-test-az-lab-austria"
$vmLocation = "West Europe"
$labAccountName = "computersciencedepartment"
$labName = "operatingsystems"
$labTitle = "CS140: Operating Systems"
$labDescription = "This class introduces the basic facilities provided in modern operating systems."

# Create a new resource group
New-AzResourceGroup -Name $vmResourceGroupName -Location $vmLocation

# Create a new Lab account or get an existing one
$la = New-AzLabAccount -ResourceGroupName $vmResourceGroupName -LabAccountName $labAccountName

$lab = $la | New-AzLab -LabName $labName -MaxUsers 10 -UsageQuotaInHours 15 -UserAccessMode Restricted -SharedPasswordEnabled

# Get an image from the Store Gallery, if enabled by the lab account owner
$img = $la | Get-AzLabAccountGalleryImage | Where-Object {$_.name -like 'CentOS-Based*'}

# Or get one from an image already created in the shared image gallery
# $img = $la | Get-AzLabAccountSharedImage | Where-Object {$_.name -like 'MyPreviouslyCreatedVmImage'}

# Specify a template for the VM
$lab = $lab | New-AzLabTemplateVM -Image $img -Size 'Small' -Title $labTitle -Description $labDescription -UserName 'vmuser' -Password 'Vmuser6.,.' -LinuxRdpEnabled

# Publish the lab by installing the template image on all the available VMs, 10 in this case. Warning: resets the state of assigned VMs
$lab = $lab | Publish-AzLab

$today = (Get-Date).ToString()
$end = (Get-Date).AddDays(1)

# Schedule some labs
@(
    [PSCustomObject]@{Frequency='Weekly';FromDate=$today;ToDate = $end;StartTime='10:00';EndTime='11:00';Notes='Theory'}
    [PSCustomObject]@{Frequency='Weekly';FromDate=$tomorrow;ToDate = $end;StartTime='11:00';EndTime='12:00';Notes='Practice'}
) | ForEach-Object { $_ | New-AzLabSchedule -Lab $lab} | Out-Null

# Remove Resource Group, including all the resources in it. This is useful if multiple resources live in the same resource group
Remove-AzResourceGroup -Name $vmResourceGroupName

# Eventually stop all the VMs
# Get-AzLabAccount | Get-AzLab | Get-AzLabVm -Status Running | Stop-AzLabVm
