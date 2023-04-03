$insvFilePath = $args[0]
$insvFileName = [System.IO.Path]::GetFileNameWithoutExtension($insvFilePath)
$gpxFilePath = Join-Path -Path $PSScriptRoot -ChildPath "$insvFileName.gpx"

exiftool -ee -p gpx.fmt "$insvFilePath" | Out-File -Encoding "UTF8" "$gpxFilePath"

$firstPointTime = Select-Xml -Path $gpxFilePath -Namespace @{
    gpx = "http://www.topografix.com/GPX/1/0"
} -XPath "//gpx:trkpt[1]/gpx:time" | Select-Object -ExpandProperty Node | Select-Object -ExpandProperty InnerText

$firstPointTimeFormatted = [datetime]::ParseExact($firstPointTime, "yyyy-MM-ddTHH:mm:ssZ", $null).ToString("yyyy:MM:dd HH:mm:ss")

$framesFolderPath = Join-Path -Path $PSScriptRoot -ChildPath "FRAMES"
New-Item -ItemType Directory -Path $framesFolderPath -Force

Write-Output "GPX file created at $gpxFilePath"
Write-Output "Time of first point in GPX file: $firstPointTimeFormatted"
Write-Output "FRAMES folder created at $framesFolderPath"

$videoFileName = $args[1]
$fps = $args[2]

$framesOutputPath = Join-Path -Path $framesFolderPath -ChildPath "img%d.jpg"
$ffmpegCommand = "ffmpeg -i `"$videoFileName`" -r $fps `"$framesOutputPath`""
Invoke-Expression $ffmpegCommand

Write-Output "Video frames extracted at $framesFolderPath"

exiftool -datetimeoriginal="$firstPointTimeFormatted" FRAMES/

$addDateTimeCommand = "exiftool -fileorder FileName -ext jpg '-datetimeoriginal+<0:0:`${filesequence;`$_=int(`$_/`"$fps`")}' FRAMES/"
Invoke-Expression $addDateTimeCommand 

exiftool -ext jpg -geotag "$gpxFilePath" FRAMES/