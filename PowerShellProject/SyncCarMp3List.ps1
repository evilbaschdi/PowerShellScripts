[xml]$XmlDocument = Get-Content "D:\Users\evilb\OneDrive\Dokumente\Audi.ffs_gui"

$SyncPair = $XmlDocument.CreateElement("Pair")
$Left = $XmlDocument.CreateElement("Left")
$Right = $XmlDocument.CreateElement("Right")

$Left.InnerText = "TestLinks"
$Right.InnerText = "TestRechts"

$SyncPair.AppendChild($Left)
$SyncPair.AppendChild($Right)

$XmlDocument.FreeFileSync.FolderPairs.AppendChild($SyncPair)

$XmlDocument.InnerXml