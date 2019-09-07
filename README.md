
# PowerShell

Handy PowerShell scripts

* Join-Url
* ConvertTo-VDJ

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

## ConvertTo-VDJ

The ConvertTo-VDJ function converts Rekordbox track metadata to a VirtualDJ-compatible format allowing tracks to be prepared only once using Rekordbox.

DJ software is notorious not supporting cross-DJ platform support resulting in the need to readd metadata (cue points, key, bpm, etc) each time you use new a DJ platform (Rekordbox, Serato, VirtualDJ, etc). DJ software stores your track metadata in propietary, closed-source databases. Rekordbox and VirtualDJ both use XML for storing track metadata, allowing for them to be converted to each other's format.

**Syntax**
```powershell
ConvertTo-VDJ -LoadPath <String> -SavePath <String> [<CommonParameters>]
```
