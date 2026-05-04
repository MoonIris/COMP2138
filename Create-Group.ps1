#Bridget Iris Turner
#200542400
#June 10, 2025
#This script is used to create a new global security group


#This is the function to create the group
function Create-Group {

#Asks the user the name of their new group they want to make and stores it in a variable named $groupName

$groupName = Read-Host "Please enter in what you want to name your new global security group: "

#This command is to create the new group using the name the useer typed in earlier. Making the groupCategory security and the GroupScope as Global
#as per the instructions

New-ADGroup -Name $groupName `
            -GroupScope Global `
            -GroupCategory Security

#Tells the user the new global security group was created

Write-Host "New Global Security group named $groupName created"

}

#Calls the function

Create-Group
