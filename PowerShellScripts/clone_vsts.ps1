$Name = Read-Host "Account"
$Collection = Read-Host "Collection"
if ($null -eq $Collection) { "DefaultCollection" }
$username = Read-Host "Username"
$password = Read-Host "Password"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

$Repos = (Invoke-RestMethod -uri https://dev.azure.com/$Name/$Collection/_apis/git/repositories?api-version=7.0 -Headers @{Authorization = ("Basic {0}" -f $base64AuthInfo) })

foreach ($Repo in $Repos.value) {
    Write-Output $Repo.name
    git clone $Repo.remoteUrl
    Write-Output ---
}
