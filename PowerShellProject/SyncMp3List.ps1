$File = "D:\Users\evilb\OneDrive\Dokumente\Music.ffs_gui"
[xml]$XmlDocument = Get-Content $File

$RemotePath = "H:\"
$Mp3Path = "F:\mp3\"

ForEach ($Directory in Get-ChildItem -Path $RemotePath) {
    If ($Directory.PSIsContainer -eq $True) {

        $RightPath = $Directory.FullName
        $LeftPath = $RightPath.Replace($RemotePath, $Mp3Path)
        Write-Output $LeftPath
        Write-Output $RightPath

        $SyncPair = $XmlDocument.CreateElement("Pair")
        $Left = $XmlDocument.CreateElement("Left")
        $Right = $XmlDocument.CreateElement("Right")

        $Left.InnerText = $LeftPath
        $Right.InnerText = $RightPath

        $SyncPair.AppendChild($Left)
        $SyncPair.AppendChild($Right)

        $XmlDocument.FreeFileSync.FolderPairs.AppendChild($SyncPair)

    }
}


$XmlDocument.Save($File)

