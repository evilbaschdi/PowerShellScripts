# Windows Update for Nano Server 
# winupdatefornano.ps1 
 
$typename = "System.Management.Automation.Host.ChoiceDescription" 
$yes = new-object $typename("&Yes", "Yes") 
$no = new-object $typename("&No", "No") 
$assembly = $yes.getType().AssemblyQualifiedName 
$choice = new-object "System.Collections.ObjectModel.Collection``1[[$assembly]]" 
$choice.add($yes) 
$choice.add($no) 
 
$currentbuild = (Get-ComputerInfo).WindowsBuildLabEx 
Write-Host "-----------------------------------------------------------------------" 
Write-Host "Current build is " $currentbuild 
Write-Host "-----------------------------------------------------------------------" 
Write-Host "Searching for updates..." 
$sess = New-CimInstance -Namespace root/Microsoft/Windows/WindowsUpdate -ClassName MSFT_WUOperationsSession 
$scanResults = Invoke-CimMethod -InputObject $sess -MethodName ScanForUpdates -Arguments @{SearchCriteria = "IsInstalled=0"; OnlineScan = $true}  
if ($scanResults.Updates.Count -eq 0) { 
    Write-Host "There are no applicable updates." 
} 
else { 
    $scanResults.Updates 
    $answer = $host.ui.PromptForChoice("Confirm", "Do you install this update?", $choice, 0) 
    if ($answer -eq 0) { 
        Write-Host "Installing updates..." 
        $scanResults = Invoke-CimMethod -InputObject $sess -MethodName ApplyApplicableUpdates 
        Write-Host "Done." 
        Write-Host "It is recommended to reboot. (type Restart-Computer)" 
    } 
    else { 
        Write-Host "Canceled." 
    } 
}
