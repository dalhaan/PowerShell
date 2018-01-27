
# PowerShell

Handy PowerShell scripts

* Join-Url

## Join-Url

The Join-Url function combines seperate Url segments into a single Url.

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
