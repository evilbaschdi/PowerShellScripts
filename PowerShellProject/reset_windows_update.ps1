# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal = new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole)) {
    # We are running "as Administrator" - so change the title and background color to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
    $Host.UI.RawUI.BackgroundColor = "DarkRed"
    clear-host
}
else {
    # We are not running "as Administrator" - so relaunch as administrator
   
    # Create a new process object that starts PowerShell
    $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
    # Specify the current script path and name as a parameter
    $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
   
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
   
    # Exit from the current, unelevated, process
    exit
}


net stop bits
net stop wuauserv
sc config wuauserv start= disabled
net stop appidsvc
net stop cryptsvc
Remove-Item /S /Q C:\Windows\SoftwareDistribution
net start bits
sc config wuauserv start= demand
sc config wuauserv start= automatic
net start wuauserv
net start appidsvc
net start cryptsvc