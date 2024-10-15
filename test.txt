param(
    [Parameter(Mandatory=$true)]
    [string]$smbpath
)

# Create a filename based on the smbpath
$safeFolderName = ($smbpath -replace '[\\\/:]', '_').Trim('_')
$outputFile = "C:\Users\GalBY\Desktop\Permissions_$safeFolderName.csv"

# Create an empty array to store results
$results = @()

# Get ACL for the specified path
$acl = Get-Acl -LiteralPath $smbpath

# Loop through each access rule
foreach ($accessRule in $acl.Access) {
    $identity = $accessRule.IdentityReference.Value
    
    # Check if the identity matches any of the exclusion criteria
    if ($identity -notmatch "BUILTIN|NT AUTHORITY|CREATOR OWNER|DataMover|dlp|RMFT|GOA_XNES|sqladmin|Ti|priva|runtask|gc|S-1-5-21|ibolt") {
        # Filter and simplify FileSystemRights
        $rights = $accessRule.FileSystemRights.ToString()
        $simplifiedRights = switch -Regex ($rights) {
            "Read" { "Read" }
            "ReadAndExecute" { "ReadAndExecute" }
            "Modify" { "Modify" }
            default { "Other" }
        }
        
        # Skip if rights are not Read, ReadAndExecute, or Modify
        if ($simplifiedRights -eq "Other") { continue }

        # Create a custom object with the desired properties
        $resultObject = [PSCustomObject]@{
            Path = $smbpath
            Identity = $identity
            FileSystemRights = $simplifiedRights
        }
        
        # Add the object to the results array
        $results += $resultObject
        
        # Also write to host for immediate feedback
        Write-Host "$identity : $simplifiedRights"
    }
}

# Export results to CSV
$results | Export-Csv -Path $outputFile -NoTypeInformation -Append

Write-Host "Results exported to $outputFile"
