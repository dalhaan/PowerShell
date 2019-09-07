Function Load-Xml {
    [OutputType([System.Xml.XmlDocument])]
    Param (
        [ValidateNotNullOrEmpty()]
        [String]$Path
    )
    Begin {
    } Process {
        $xml = New-Object System.Xml.XmlDocument
        $xml.PreserveWhitespace = $true
        $xml.Load($Path)
    } End {
        return $xml
    }
}

Function New-TimeT {
    Param (
        [ValidateNotNullOrEmpty()]
        [System.DateTime]$Date
    )
    Process {
        $1970 = Get-Date -Date "01/01/1970"
        $timeT = (New-TimeSpan -Start $1970 -End $Date).TotalSeconds
    } End {
        return [math]::Round($timeT)
    }
}

# Harmonic to Key
$CamelotWheel = @{
	"1A" = "Abm"
	"2A" = "Ebm"
	"3A" = "Bbm"
	"4A" = "Fm"
	"5A" = "Cm"
	"6A" = "Gm"
	"7A" = "Dm"
	"8A" = "Am"
	"9A" = "Em"
	"10A" = "Bm"
	"11A" = "F#m"
	"12A" = "Dbm"
	"1B" = "B"
	"2B" = "F#"
	"3B" = "Db"
	"4B" = "Ab"
	"5B" = "Eb"
	"6B" = "Bb"
	"7B" = "F"
	"8B" = "C"
	"9B" = "G"
	"10B" = "D"
	"11B" = "A"
	"12B" = "E"
}

Function ConvertTo-VDJ {
    Param (
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [String]$LoadPath,

        [ValidateScript({Test-Path -Path $_ -PathType Leaf -IsValid})]
        [String]$SavePath
    )
    Begin {
    } Process {
        $rekordboxDb = Load-Xml -Path $LoadPath

        # Load tracks from Rekordbox Db
        $tracks = @()
        $rekordboxDb.DJ_PLAYLISTS.COLLECTION.TRACK | % {
            $track = @{}
            $track.FilePath = [uri]::UnescapeDataString($_.Location).Replace("file://localhost/","").Replace("/", "\")
            $track.FileSize = "$($_.Size)"
            $track.Author = "$($_.Artist)"
            $track.Title = "$($_.Name)"
            $track.Genre = "$($_.Genre)"
            $track.Album = "$($_.Album)"
            $track.Label = "$($_.Label)"
            $track.TrackNumber = "$($_.TrackNumber)"
            $track.Year = "$($_.Year)"
            if ($_.TEMPO.Count -gt 1) {
                $track.Bpm = "$([math]::Round(60/$_.TEMPO[0].Bpm, 6))"
            } else {
                $track.Bpm = "$([math]::Round(60/$_.TEMPO.Bpm, 6))"
            }
            $track.Key = "$($CamelotWheel[$_.Tonality])"
            $track.PlayCount = "$($_.PlayCount)" 
            $track.Bitrate = "$($_.Bitrate)"
            $track.Comment = "$($_.Comments)"
            $track.FirstSeen = "$(New-TimeT -Date (Get-Date))"

            $count = 1
            $_.POSITION_MARK | % {
                $cuePoint = @{}
                $cuePoint.Name = "Cue $count"
                $cuePoint.Pos = "$($_.Start)"
                $cuePoint.Num = "$count"

                $track.CuePoints += ,$cuePoint
                $count++
            }

            $tracks += $track
        }

        # Create VDJ Xml from Rekordbox tracks
        $databaseVersion = "8.2"
        [xml]$doc = New-Object System.Xml.XmlDocument
        $dec = $doc.CreateXmlDeclaration("1.0", "UTF-8", $null)
        $null = $doc.AppendChild($dec)

        $virtualDJDatabaseNode = $doc.CreateElement("VirtualDJ_Database")
        $virtualDJDatabaseNode.SetAttribute("Version", $databaseVersion)

        $tracks | % {
            $songNode = $doc.CreateElement("Song")
            $songNode.SetAttribute("FilePath", $_.FilePath)
            $songNode.SetAttribute("FileSize", $_.FileSize)

            $tagsNode = $doc.CreateElement("Tags")
            $tagsNode.SetAttribute("Author", $_.Author)
            $tagsNode.SetAttribute("Title", $_.Title)
            $tagsNode.SetAttribute("Genre", $_.Genre)
            $tagsNode.SetAttribute("Album", $_.Album)
            $tagsNode.SetAttribute("Label", $_.Label)
            $tagsNode.SetAttribute("TrackNumber", $_.TrackNumber)
            $tagsNode.SetAttribute("Year", $_.Year)
            $tagsNode.SetAttribute("Bpm", $_.Bpm)
            $tagsNode.SetAttribute("Key", $_.Key)
            $tagsNode.SetAttribute("Flag", "1")
            $null = $songNode.AppendChild($tagsNode)

            $infosNode = $doc.CreateElement("Infos")
            $infosNode.SetAttribute("FirstSeen", $_.FirstSeen)
            #$infosNode.SetAttribute("Bitrate", $_.Bitrate)
            $infosNode.SetAttribute("Cover", "1")
            $null = $songNode.AppendChild($infosNode)

            $commentNode = $doc.CreateElement("Comment")
            $commentNode.InnerText = $_.Comment
            $null = $songNode.AppendChild($commentNode)

            $_.CuePoints | % {
                $poiNode = $doc.CreateElement("Poi")
                $poiNode.SetAttribute("Name", $_.Name)
                $poiNode.SetAttribute("Pos", $_.Pos)
                $poiNode.SetAttribute("Num", $_.Num)
                $null = $songNode.AppendChild($poiNode)
            }

            $null = $virtualDJDatabaseNode.AppendChild($songNode)
        }
        $null = $doc.AppendChild($virtualDJDatabaseNode)
    } End {
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Encoding = [System.Text.Encoding]::UTF8
        $settings.IndentChars = " "
        $settings.Indent = $true
        $writer = [System.Xml.XmlWriter]::Create($SavePath, $settings)
        
        $doc.Save($writer)
        $writer.Flush()
        $writer.Close()
    }
}