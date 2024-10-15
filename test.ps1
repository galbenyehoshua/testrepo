param(
   [string]$smbpath
)


$acl = Get-ACL -LiteralPath "$smbpath"
$access = $acl.Access
foreach($ao in $access){
$x = $ao.IdentityReference.Value
if($x -inotmatch "BUILTIN|NT AUTHORITY|CREATOR OWNER|DataMover|dlp|RMFT|GOA_XNES|sqladmin|Ti|priva|runtask|gc|S-1-5-21|ibolt"){
Write-Host $x 
$results += $x
} 
}
