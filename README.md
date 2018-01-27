
# PowerShell

Handy PowerShell scripts

* Join-Url

## Join-Url

The Join-Url function combines seperate url segments into a single url.

**Syntax**
```powershell
Join-Url [-Paths] <String[]> [<CommonParameters>]
```

**Example**
```powershell
$QueryType = 'search'
$Query = 'PowerShell'
Join-Url -Paths 'https://www.google.com/', $QueryType, '?q=', $Query
https://www.google.com/search?q=PowerShell
```
