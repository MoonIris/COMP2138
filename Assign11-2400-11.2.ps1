#Bridget Iris Turner
#200542400
#July 31, 2025
#This script is used to display scheduled tasks, microsoft edge services and computer details
#Needed to format-table otherwise the script output was wonkey and all over the place


#This function is used to get the scheduled running tasks
function Scheduled-Tasks {

Write-Host "---------------------------------"
Write-Host "Scheduled Tasks In Running State"
Write-Host "---------------------------------"	

Get-CimInstance -ClassName Win32_Process |
Where-Object { $_.Name -eq 'taskeng.exe' } |
Select-Object ProcessId, Name, CommandLine |
Format-Table -AutoSize

}

#This function is for displaying the microsoft edge services

function Edge-Services {

Write-Host "------------------------"
Write-Host "Microsoft Edge Services"
Write-Host "------------------------"

Get-CimInstance -ClassName Win32_Service |
Where-Object { $_.DisplayName -like '*Microsoft Edge*' -or $_.Name -like '*msedge' } |
Select-Object Name, State | 
Format-Table -AutoSize


}

#This function is for displaying computer details.
function Computer-Details {

Write-Host "-----------------"
Write-Host "Computer Details"
Write-Host "-----------------"

$os = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption
Write-Host "Operating System: $os"

$memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object -ExpandProperty Capacity
Write-Host "Memory: $memory"

$diskGB = Get-Volume | Select-Object `
	@{Name='Name';Expression={$_.DriveLetter}}, `
	@{Name='Free Space(GB)';Expression={$_.SizeRemaining/ 1GB}}, `
	@{Name='Size(GB)';Expression={$_.Size/ 1GB}} 

Write-Host "Disks:"
$diskGB | Format-Table -AutoSize

$networkAdapter = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127.*'} | Select-Object InterfaceAlias, IPAddress, PrefixLength, IPv4DefaultGateway 

Write-Host "Network Adapter:"
$networkAdapter | Format-List

$uptime = Get-Uptime
Write-Host "Uptime: $uptime"


$cpuUtility = (Get-CimInstance -ClassName Win32_Processor).LoadPercentage -join ' '
Write-Host "CPU Utilization (per socket): $cpuUtility"


}




#Calls the functions

Scheduled-Tasks
Edge-Services
Computer-Details