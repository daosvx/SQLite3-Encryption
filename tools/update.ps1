# Copyright (c) Jan Chren 2014
# Licensed under BSD 3

# This script updates wxSQLite SQLite source code


"Updating of wxSQLite started"


$CP_HERE_YES_TO_ALL = 16

$WebClient  = New-Object System.Net.WebClient
$Shell      = New-Object -com Shell.Application

$PROJECT_ROOT_DIR = $(Resolve-Path "$PSScriptRoot\..")
$OUTPUT_DIR       = "$PROJECT_ROOT_DIR\src"
$TMP_FILE         = "$env:TMP\wxsqlite3.zip"

$WXSQLITE_GH_API_URL = "https://api.github.com/repos/utelle/wxsqlite3/releases/latest"
$WXSQLITE_OBJ = Invoke-WebRequest $WXSQLITE_GH_API_URL | ConvertFrom-Json

function compareVersions ($a, $b){
    (New-Object System.Version($a)).CompareTo((New-Object System.Version($b)))
}

function getRemoteWxSqliteVersion(){
    $WXSQLITE_OBJ.tag_name  -replace 'v', ''
}

function getLocalVersion($type){
    Get-Content "$PROJECT_ROOT_DIR\VERSIONS" | where { $_ -match "^\s*$type" } | %{$_ -replace '.*=\s*([^\s]*)\s*', '$1'}
}

function setLocalVersion($type, $value){
    $SRC_FILE="$PROJECT_ROOT_DIR\VERSIONS"
    $DEST_FILE="$SRC_FILE.tmp"
    Get-Content $SRC_FILE | %{$_ -replace "^\s*($type[^= ]*)\s*=\s*([^\s]*)\s*", "`$1=$value" } | Set-Content $DEST_FILE
    Move-Item $DEST_FILE $SRC_FILE -Force
}

function getSqliteVersion(){
    Get-Content "$OUTPUT_DIR\sqlite3.h" | where { $_ -match "#define SQLITE_VERSION " } | %{$_ -replace '.*"([\d.]{5,})".*', '$1'}
}
# from https://social.msdn.microsoft.com/Forums/vstudio/en-US/de846ebb-c225-44a4-b443-e64760486e70/how-to-post-data-to-the-restful-webservice-from-cnet?forum=csharpgeneral

Function Get-RedirectedUrl() {
      Param (
	         [Parameter(Mandatory=$true)]
	         [String]$URL     )
	Write-Host "Getting $url"
      $request = [System.Net.WebRequest]::Create($url)
     $request.AllowAutoRedirect=$false
     $response=$request.GetResponse()
     If ($response.StatusCode -eq "Found") {
         $response.GetResponseHeader("Location")
     }
}
# link in json is to api.*, which doesn't actually serve zip, it redirects.
#$WXSQLITE_URL = Get-RedirectedUrl $WXSQLITE_OBJ.zipball_url.toString() 
#Write-Host "Link was " + $WXSQLITE_OBJ.zipball_url + " Now is $WXSQLITE_URL"

$OLD_WXSQLITE_VERSION = getLocalVersion "wxsqlite"
$REMOTE_WXSQLITE_VERSION = getRemoteWxSqliteVersion

if ($(compareVersions $OLD_WXSQLITE_VERSION $REMOTE_WXSQLITE_VERSION) -ne -1){
    "You already have the newest version of wxSqlite - {0}" -f $OLD_WXSQLITE_VERSION
    exit
}

$OLD_SQLITE_VERSION = getSqliteVersion

try
{
Write-Host "Downloading $WXSQLITE_URL to $TMP_FILE"
$request = [System.Net.WebRequest]::Create($WXSQLITE_OBJ.zipball_url.toString())
$request.Accept = "*/*";
$request.UserAgent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0 .NET4.0C;)"
$resp = $request.GetResponse()
if( $resp.GetType().Name -eq "HttpWebResponse" -and $resp.StatusCode -eq [System.Net.HttpStatusCode]::OK )
{
	$writer = new-object System.IO.StreamReader $resp.GetResponseStream()
	$writer.ReadToEnd() | Out-File $TMP_FILE
 Write-Host "Yay" 
}
else
{
	Write-Host "Unable to Download"
	exit
}
$found = $False
$zip = $Shell.Namespace($TMP_FILE)
foreach($item in $zip.items())
{
	Write-Host "- " $item.Name
    if ( $item.Name -like "*-wxsqlite3-*" ){
        $items = $Shell.NameSpace("$TMP_FILE\"+$item.Name+"\sqlite3\secure\src").Items()
        $Shell.Namespace($OUTPUT_DIR).Copyhere($items, $CP_HERE_YES_TO_ALL)
		$found = $True
    }
}

#Remove-Item $TMP_FILE
} catch 
{
	Write-Host "Error Downloading"
	exit
}


if( ! $found ) {
	Write-Host "Failed to copy items"
	exit
}

$NEW_SQLITE_VERSION = getSqliteVersion

setLocalVersion "sqlite"   $NEW_SQLITE_VERSION
setLocalVersion "wxsqlite" $REMOTE_WXSQLITE_VERSION

"wxSQLite has been updated from {0} to {1}" -f $OLD_WXSQLITE_VERSION, $REMOTE_WXSQLITE_VERSION
"SQLite has been updated from {0} to {1}" -f $OLD_SQLITE_VERSION, $NEW_SQLITE_VERSION
