#Bridget Iris Turner
#200542400
#May 27, 2025
#This script is used to create a function that will take three numeric variables and find the mean and then the variance of them. Then it will
#return the standard deviation to them


#This is the function
function Calculate-Results {

#Using write host to explain what the function does to the user
Write-Host "Welcome to the Calculate Results Function. This function is used to calculate the mean and then variance of the three"
Write-Host "intergers you give it. It will then return the standard deviation of the three integers to you"

#These are my variable where the three interger values with be stored to call upon them later in the function using Read-Host
#Needed to put [int] in front of the variable to get the function to recognize them as seperate intergers and not a singular integer as
#was going on with my testing before.
[int]$valueOne = Read-Host "Please enter in the first numeric value: "
[int]$valueTwo = Read-Host "Please enter in the second numeric value: "
[int]$valueThree = Read-Host "Please enter in the third numeric value: "

#This is where the two calculations are being done. The first one is stored as a variable called mean. Adding all three intergers in each variable.
#Then dividing by three using / to allow for decimals. The three variable are incased in a backet so the addition is done first.
$mean = ($valueOne + $valueTwo + $valueThree) / 3 

#This second one is variance. Using each of the three integer variables and using [Math] .NET type to allow me to using exponents since powershell
#7 keep on giving me errors tying to use **. the variable subtracts the value variables by the mean then exponents them to the power of 2 before
#finally divding it all by the amount of integers. In this case three.  
$variance = ([Math]::Pow(($valueOne - $mean), 2) + [Math]::Pow(($valueTwo - $mean), 2) + [Math]::Pow(($valueThree - $mean), 2)) / 3  

#This is the return to return the standard deviation to determine how dispersed the three values are. Using the Math .NET type again. This time
#using Sqrt instead of Pow to square root the variance to get the standard deviation. It also tells the user as well 
Write-Host "The Standard Deviation of $valueOne, $valueTwo, and $ValueThree is: "
return [Math]::Sqrt($variance)
}


#Calls the function
Calculate-Results