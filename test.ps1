param(
    [Parameter(Mandatory=$true)]
    [string]$smbpath,
    
    [Parameter(Mandatory=$true)]
    [string]$outputPath
)

# Create an empty array to store results
$results = @()

# Get ACL for the specified path
$acl = Get-Acl -LiteralPath $smbpath

# Loop through each access rule
foreach ($accessRule in $acl.Access) {
    $identity = $accessRule.IdentityReference.Value
    
    # Check if the identity matches any of the exclusion criteria
    if ($identity -notmatch "BUILTIN|NT AUTHORITY|CREATOR OWNER|DataMover|dlp|RMFT|GOA_XNES|sqladmin|Ti|priva|runtask|gc|S-1-5-21|ibolt") {
        # Create a custom object with the desired properties
        $resultObject = [PSCustomObject]@{
            Path = $smbpath
            Identity = $identity
            AccessControlType = $accessRule.AccessControlType
            FileSystemRights = $accessRule.FileSystemRights
        }
        
        # Add the object to the results array
        $results += $resultObject
        
        # Also write to host for immediate feedback
        Write-Host "Added: $identity"
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputPath -NoTypeInformation

Write-Host "Results exported to $outputPath"
