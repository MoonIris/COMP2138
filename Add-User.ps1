#Bridget Iris Turner
#200542400
#June 10, 2025
#This script is used to create a new user account, only asking the user for their first and last name

#This is the function
function Add-User {

#Ask the user for their first and last name only. Combined the two for full name as well

$firstName = Read-Host "Enter your first name"
$lastName = Read-Host "Enter your last name"
$fullName = "$firstName $lastName"

#These two variables set up the email and sam account respectivly 

$UPN = "$firstName.$lastName@adatum.com"
$SamAccountName = "$firstName"

#This is the command to actually create the new AD-User. Make it user reable by using using the backtick to make line continuations. While
#providing all the output needed  

New-ADUser -Name $fullName `
           -GivenName $firstName `
           -Surname $lastName `
           -UserPrincipalName $UPN `
           -EmailAddress $UPN `
           -SamAccountName $SamAccountName `
           -AccountPassword (ConvertTo-SecureString "Letmein123" -AsPlainText -Force) `
           -Enabled $true `
           -ChangePasswordAtLogon $true 

#Tells the user the account was created succesfully

Write-Host "New AD User created named $fullName with Email Address $EmailAddress and password Letmein123 to be changed on restart"


}


#Calls the function
Add-User 