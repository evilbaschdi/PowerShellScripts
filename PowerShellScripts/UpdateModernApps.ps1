$namespaceName = "root\cimv2\mdm\dmmap"
$className = "MDM_EnterpriseModernAppManagement_AppManagement01"
$wmiObj = Get-CimInstance -Namespace $namespaceName -Class $className
$wmiObj.UpdateScanMethod()
