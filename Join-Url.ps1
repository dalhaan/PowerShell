function Join-Url {
    <#
    .SYNOPSIS
        Combines urls into a single url.
    .DESCRIPTION
        The Join-Url function combines seperate url segments into a single url.
    .EXAMPLE
        Join-Url -Paths 'https://www.google.com/', 'search?q=', 'PowerShell'
        https://www.google.com/search?q=PowerShell
    #>
    [CmdletBinding(
        ConfirmImpact = 'None')]
    [OutputType([String])]
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]$Paths
    )
    Begin {
        $Delimiters = @('?', '=', '&', '#', '.' ,'!', '"', '%', "'", '*', '+', ',', ':', ';', '@', '^', '_', '`', '|', '~', '-', '(', ')', '{', '}', '[', ']', '<', '>')
    } Process {
        # Determine how to, and join urls
        $Result = $Paths[0]
        For ($i=0; $i -lt $Paths.Length-1; $i++) {
            $PathB = $Paths[$i+1]
            $EndsWithSlash = $false
            $StartsWithSlash = $false
            $EndsWithDelimiter = $false
            $StartsWithDelimiter = $false
        
            # Check if PathA ends with a slash or delimiter
            if ($Result[-1] -eq '/') {
                $EndsWithSlash = $true
            } else {
                ForEach ($Delimiter in $Delimiters) {
                    if ($Result[-1] -eq $Delimiter) {
                        $EndsWithDelimiter = $true
                        break
                    }
                }
            }
            
            # Check if PathB starts with a slash or delimiter
            if ($PathB[0] -eq '/') {
                $StartsWithSlash = $true
            } else {
                ForEach ($Delimiter in $Delimiters) {
                    if ($PathB[0] -eq $Delimiter) {
                        $StartsWithDelimiter = $true
                        break
                    }
                }
            }
            
            # Handle if there are slashes between paths
            if ($EndsWithSlash -or $StartsWithSlash) {
                if ($EndsWithSlash) {
                    if ($StartsWithSlash) {
                      $Result += $PathB.SubString(1)
                    } else {
                      $Result += $PathB
                    }
                } ElseIf ($StartsWithSlash) {
                    $Result += $PathB
                }
            } 
            
            # Handle if there are delimiter(s) between paths
            elseif ($EndsWithDelimiter -or $StartsWithDelimiter) {
                $Result += $PathB
            } 
            
            # Handle if there are neither
            else {
                $Result += ('/' + $PathB)
            }
        }
        return $Result
    } End {
    }
}