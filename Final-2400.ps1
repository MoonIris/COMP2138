#Bridget Iris Turner
#200542400
#August 7, 2025
#This is my final project for COMP2138, Windows Server and Powershell
#The purpose of this script is to create a working menu system for a ServiceDesk team.

#This is the main function 
function Service-Menu {

#This whole main menu function is encased in a do-while loop until the user enters the number 9 to break the loop which will end and exit out of the script.
#Entering the number 0 at any point in any sub menu will bring user back to the main menu. Used if statements and return to accomplish. Told to the user in every sub menu  

do {

#This part of the script is the gui of the main menu that the user sees


 Write-Host "                     ---------------------"
 Write-Host "                     ServiceDesk Team Menu"
 Write-Host "                     ---------------------"    	

 Write-Host ""
 Write-Host ""

 Write-Host "Active Directory                                Folders And Shares"
 Write-Host "----------------                                ------------------"
 Write-Host "1.New User                                      3.New Folder"
 Write-Host "2.Reset User Password                           4.New Share"

 Write-Host ""
 Write-Host ""

 Write-Host "Permissions                                     Server Information"
 Write-Host "------------                                    ------------------"
 Write-Host "5.Add Permission To Folder                      7.Display Server Specs"
 Write-Host "6.View Existion Permission on a Folder          8.Display Resource Information"

 Write-Host ""
 Write-Host ""

 Write-Host "                            Exit Menu"
 Write-Host "                            ---------"
 Write-Host "                            9.Exit" 

 Write-Host ""
 Write-Host ""

#Here I have created a switch for when a user chooses a number corresponding to its submenu. It will continue to loop until the user enters in 9 to break
#I have added a default here as a fail safe if the user does not enter something from the switch. 

 $UserChoice = Read-Host "Please Select A Number Corresponding To Your Need"

 switch ($UserChoice) {
	'1' {New-User}
	'2' {Reset-Password}
	'3' {New-Folder}
	'4' {New-Share}
	'5' {Add-Permission}
	'6' {View-Permission}
	'7' {Display-Specs}
	'8' {Display-Resources}
	'9' {Write-Host "Exiting Menu"; break}
	default {Write-Host "Invalid Input. Please Enter A Valid Input From 1-9"}
  }

 } while ($UserChoice -ne '9')
  
}

#This function corresponds to option 1 on the menu. Allowing the user to create a new ADUser

function New-User {

#Ask the user for their first and last name only. Combined the two for full name as well. Password as well too.

Write-Host ""
Write-Host "Welcome to the New User Sub-Menu. Here you can create a new ADUser"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""
$firstName = Read-Host "Enter your first name"
if ($firstName -eq '0') { return }
$lastName = Read-Host "Enter your last name"
if ($lastName -eq '0') { return }
$fullName = "$firstName $lastName"
if ($fullName -eq '0') { return }

#So I have this do-until loop here to make sure the account password is complex enough so that there is one. The contents of the variable $PlainPassword is the only way I could
#find to convert Securestring into plainstring so I could check it to see if it is complex enough using an if-else statement for upper and lower case letters, numbers, and symbols
#if it does then $validPassword is set to true which is the condition for the loop to finish. If not the loop repeats until it does

do {
    $AccountPassword = Read-Host "Enter in a password" -AsSecureString
    $PlainPassword = [System.Net.NetworkCredential]::new("", $AccountPassword).Password

    if (
        $PlainPassword -match '[A-Z]' -and
        $PlainPassword -match '[a-z]' -and
        $PlainPassword -match '\d' -and
        $PlainPassword -match '[^a-zA-Z0-9]'
    ) 
	
    {
        $validPassword = $true
    }
    else {
        Write-Host "Password is not complex enough."
        Write-Host "Please include Uppercase, Lowercase, Numbers, and Symbols"
        $validPassword = $false
    }
} until ($validPassword)


$UPN = "$firstName.$lastName@adatum.com"
$SamAccountName = "$firstName $lastName"


New-ADUser -Name $fullName `
 -GivenName $firstName `
 -Surname $lastName `
 -UserPrincipalName $UPN `
 -EmailAddress $UPN `
 -SamAccountName $SamAccountName `
 -AccountPassword $AccountPassword `
 -Enabled $true


Write-Host "New AD User created named $fullName with Email Address $UPN"

Start-Sleep 2


}

#This function corresponds to option 2 on the menu. Allowing the user to reset an ADUser password
#I used a do-while loop to check if the user account name exists if not then it loops to ask again. If it exists the loop breaks and asks for the new password

function Reset-Password {

Write-Host ""
Write-Host "Welcome to the Reset Password Sub-Menu. Here you can reset the password of an existing ADUser"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""

do {
	$UserName = Read-Host "Please Enter In The User Account Name That You Want To Reset The Password For"
	if ($UserName -eq '0') { return }

	$UserCheck = Get-ADUser -Identity $UserName
		if (-not $UserCheck) {
			Write-Host "User Not Found. Please Try Again"
			continue
		}
   
		break		

} while($true)

#Grabed my do-while loop for creating password from New-User and put it here with more appropriate variable names for Reset-Password

do {
    $NewPassword = Read-Host "Enter in a new password" -AsSecureString
    $NewPlainPassword = [System.Net.NetworkCredential]::new("", $NewPassword).Password

    if (
        $NewPlainPassword -match '[A-Z]' -and
        $NewPlainPassword -match '[a-z]' -and
        $NewPlainPassword -match '\d' -and
        $NewPlainPassword -match '[^a-zA-Z0-9]'
    ) 
	
    {
        $validPassword = $true
    }
    else {
        Write-Host "Password is not complex enough."
        Write-Host "Please include Uppercase, Lowercase, Numbers, and Symbols"
        $validPassword = $false
    }
} until ($validPassword)


#Sets the new password once everything is in order and tells the user

Set-ADAccountPassword -Identity $UserName -NewPassword $NewPassword -Reset

Write-Host "Password for $UserName has been Reset"

Start-Sleep 2

}


#This function corresponds to option 3 on the menu. Allowing the user to create a new folder

function New-Folder {

Write-Host ""
Write-Host "Welcome to the New Folder Sub-Menu. Here you can create a new folder"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""

#This do-until loop asks the user for the folder name and full file path. It then stores it in variable using Join-Path to combine foldername and folderpath together.
#Then I use try except to attempt to create a folder at the file destination. If it succeeds then it will create it and tell the user and then set the $FolderCreated variable
#to true which fulfilles the until condition which breaks the loop. If an error occurs it catches it and repeats the do-while loop until it succeeds or the user returns 

do {

 $FolderName = Read-Host "Please enter in the folder name"
 if ($FolderName -eq '0') { return }
 $FolderPath = Read-Host "Please enter in the full folder path"
 if ($FolderPath -eq '0') { return }
 $FullPath = Join-Path -Path $FolderPath -ChildPath $FolderName

 try {
    New-Item -ItemType Directory -Path $FullPath | Out-Null
    Write-Host "Folder created at: $FullPath"
    Start-Sleep 2 
    $FolderCreated = $true
 }
 catch {
    Write-Host " Error creating folder. Please Specify a valid path" 
 }
    
} until ($FolderCreated)


}

#This function corresponds to option 4 on the menu. Allowing the user to create and manage smb shares

function New-Share {

Write-Host ""
Write-Host "Welcome to the Smb Share Sub-Menu. Here you can modify Smb-Shares for files/folders"
Write-Host ""

#Just like in the main menu, I have a do while loop and switch to make a menu to submenus for the smb shares with folders

do {

Write-Host ""
Write-Host "1.New Smb-Share"
Write-Host "2.Existing Share"
Write-Host "3.Encryption"
Write-Host "4.Remove Share Access"
Write-Host "5.Add Read Access"
Write-Host "6.Add Full Access"
Write-Host "7.Return To Main Menu"
Write-Host ""

$UserChoice = Read-Host "Please Select A Number Corresponding To Your Need"

 switch ($UserChoice) {
	'1' {New-Smb}
	'2' {Existing-Share}
	'3' {Encryption}
	'4' {Remove-Access}
	'5' {Add-Read}
	'6' {Add-FullAccess}
	'7' {Write-Host "Exiting Menu"; break}
	default {Write-Host "Invalid Input. Please Enter A Valid Input From 1-7"}
  }

 } while ($UserChoice -ne '7')

}

#This function corresponds to option 5 on the menu. Allowing the user to add NTFS-Permissions to folders


function Add-Permission {

Write-Host ""
Write-Host "Welcome to the NTFS Permissions Sub-Menu. Here you can modify NTFS Permissions for files/folders"
Write-Host ""

do {

Write-Host ""
Write-Host "1.Add NTFS Permission"
Write-Host "2.Remove NTFS Permission"
Write-Host "3.Remove NTFS Inherited Rights"
Write-Host "4.Return To Main Menu"
Write-Host ""

$UserChoice = Read-Host "Please Select A Number Corresponding To Your Need"

 switch ($UserChoice) {
	'1' {Add-NTFS}
	'2' {Remove-NTFS}
	'3' {Remove-Inherited}
	'4' {Write-Host "Exiting Menu"; break}
	default {Write-Host "Invalid Input. Please Enter A Valid Input From 1-4"}
  }

 } while ($UserChoice -ne '4')

}



#This function corresponds to option 6 on the menu. Allowing the user to View NTFS-Permissions


function View-Permission {

Write-Host ""
Write-Host "Welcome to the View NTFS Permission sub-menu. Here you can check out the NTFS Permissions of a folder/file"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""

#Variable here set to false otherwise it errors and can't choose anything. Another do-until loop and try except to make sure
#that the user actually inputs in a proper file and/or folder path


do {

 $FolderPath = Read-Host "Please enter in the full folder cand/or file path"
 if ($FolderPath -eq '0') { return }

 try {
    Get-NTFSAccess -Path $FolderPath | Format-Table -AutoSize
    $PathFound = $true
 }
 catch {
    Write-Host " Error finding folder and/or file. Please Specify a valid path"
    $PathFound = $false 
 }
    
} until ($PathFound)


}



#This function corresponds to option 7 on the menu. Allowing the user to display the server specs


function Display-Specs {

Write-Host ""
Write-Host "Welcome to the Server Specs Sub-Menu. Here you can check out the server specs"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""



$os = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Caption
$Version = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty Version
Write-Host "Operating System: $os"
Write-Host "Version: $Version"

$cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -ExpandProperty Name
Write-Host "CPU: $cpu"

$memory = Get-CimInstance -ClassName Win32_PhysicalMemory | Select-Object -ExpandProperty Capacity
Write-Host "Memory: $memory"


$diskGB = Get-Volume | Select-Object `
	@{Name='Name';Expression={$_.DriveLetter}}, `
	@{Name='Size(GB)';Expression={$_.Size/ 1GB}} 

Write-Host "Disks:"
$diskGB | Format-Table -AutoSize




Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""

$Return = Read-Host "Return to Menu? (Press 0)"
if ($Return -eq '0') { return }


}


#This function corresponds to option 8 on the menu. Allowing the user to display the servers resources

function Display-Resources {


Write-Host ""
Write-Host "Welcome to the Server Resources Sub-Menu. Here you can check out the server resources"
Write-Host "Enter 0 to return to main menu at any point"
Write-Host ""

$uptime = Get-Uptime
Write-Host "Uptime: $uptime"

$diskGB = Get-Volume | Select-Object `
	@{Name='Name';Expression={$_.DriveLetter}}, `
	@{Name='Free Space(GB)';Expression={$_.SizeRemaining/ 1GB}} `

Write-Host "Disks:"
$diskGB | Format-Table -AutoSize


$cpuUtility = (Get-CimInstance -ClassName Win32_Processor).LoadPercentage -join ' '
Write-Host "CPU Utilization (per socket): $cpuUtility"


Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""


$Return = Read-Host "Return to Menu? (Press 0)"
if ($Return -eq '0') { return }

}


#Down here is the small functions that get called for file modification and smb share
#All of them use try and catch for error checking and handeling

function New-Smb {

Write-Host ""
Write-Host "Here you can create a new smb-share"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }
 $FolderPath = Read-Host "Please enter in the full folder path"
  if ($FolderPath -eq '0') { return }

 New-SmbShare -Name $ShareName -Path $FolderPath

 Write-Host "Create share $ShareName at $FolderPath"

 }

 catch {
	Write-Host "Failed to create smb-share. Please check folder name and file path"
 }

}


function Existing-Share {

Write-Host ""
Write-Host "Here you can check out the existing share permissions of a share"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }

 Get-SmbShareAccess -Name $ShareName | Get-SmbShareAccess | Format-Table -GroupBy Name

}

 catch {
	Write-Host "Failed to get smb-share access. Please check smb share name"
 }

}


function Encryption {

Write-Host ""
Write-Host "Here you can encrypt a share if you choose"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }

 Set-SmbShare -Name $ShareName -EncryptData $true -Force

 Write-Host "Encrypted share $ShareName"

}

 catch {
	Write-Host "Failed to encrypt share. Please check smb share name"
 }

}


function Remove-Access {

Write-Host ""
Write-Host "Here you can remove share access from a share"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }
 $AccountName = Read-Host "Please enter in the account name"
  if ($AccountName -eq '0') { return }

 $RemoveShare = @{
	Name = $ShareName
	AccountName = $AccountName
	Confirm = $false
	}
	Revoke-SmbShareAccess @RemoveShare -ErrorAction Stop

	Write-Host "Removed Access to $ShareName for $AccountName" 

}

 catch {
	Write-Host "Failed to remove share. Please check smb share name and or account name"
 }

}



function Add-Read {

Write-Host ""
Write-Host "Here you can add a read share if you choose"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }
 $AccountName = Read-Host "Please enter in the account name"
  if ($AccountName -eq '0') { return }

 $ReadShare = @{
	Name = $ShareName
	AccessRight = "Read"
	AccountName = $AccountName
	Confirm = $false
	}
	Grant-SmbShareAccess @ReadShare -ErrorAction Stop

	Write-Host "Added Read share to $ShareName for $AccountName"

}

 catch {
	Write-Host "Failed to add read access. Please check smb share name and or account name"
 }

}


function Add-FullAccess {

Write-Host ""
Write-Host "Here you can add full access to a share for an account if you choose"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $ShareName = Read-Host "Please enter in the share name"
  if ($ShareName -eq '0') { return }
 $AccountName = Read-Host "Please enter in the account name"
 if ($AccountName -eq '0') { return }

 $FullShare = @{
	Name = $ShareName
	AccessRight = "Full"
	AccountName = $AccountName
	Confirm = $false
	}
	Grant-SmbShareAccess @FullShare -ErrorAction Stop

	Write-Host "Added full access to $ShareName for $AccountName"

}

 catch {
	Write-Host "Failed to add full access. Please check smb share name and or account name"
 }

}


#These function are called upon in the NTFS Permission sub-menu

function Add-NTFS {

Write-Host ""
Write-Host "Here you can add NTFS Permissions to a file or folder"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $FullPath = Read-Host "Please enter in the full path"
  if ($Path -eq '0') { return }
 $AccountName = Read-Host "Please enter in the account name"
 if ($AccountName -eq '0') { return }

 $AddNTFS = @{
	Path = $FullPath
	AccountName = $AccountName
	AccessRight = "FullControl"
	}
	Add-NTFSAccess @AddNTFS -ErrorAction Stop

	Write-Host "Added access to $Path for $AccountName"

}

 catch {
	Write-Host "Failed to add access. Please check the path and or account name"
 }

}



function Remove-NTFS {


Write-Host ""
Write-Host "Here you can remove NTFS Permissions to a file or folder"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $FullPath = Read-Host "Please enter in the full path"
  if ($Path -eq '0') { return }
 $AccountName = Read-Host "Please enter in the account name"
 if ($AccountName -eq '0') { return }

 $RemoveNTFS = @{
	Path = $FullPath
	AccountName = $AccountName
	AccessRight = "FullControl"
	}
	Remove-NTFSAccess @RemoveNTFS -ErrorAction Stop

	Write-Host "Removed access to $Path for $AccountName"

}

 catch {
	Write-Host "Failed to remove access. Please check the path and or account name"
 }

}



function Remove-Inherited {

Write-Host ""
Write-Host "Here you can remove NTFS inherited rights to a file or folder"
Write-Host "Return to previous menu by pressing 0"
Write-Host ""

try {

 $FullPath = Read-Host "Please enter in the full path"
  if ($Path -eq '0') { return }

 $RemoveInheritNTFS = @{
	Path = $FullPath
	RemoveInheritedAccessRules = $True
	}
	Disable-NTFSAccessInheritance @RemoveInheritNTFS -ErrorAction Stop

	Write-Host "Removed inherited rights to $FullPath"

}

 catch {
	Write-Host "Failed to remove access. Please check the path and or account name"
 }

}




#Calls the Service Menu

Service-Menu