<#
.SYNOPSIS   
Locate media files on a specific computer, 
obtain the metadata and store in a database
.DESCRIPTION
Will search a given directory tree for media files - both audio
and video. The file formats that are searched for include 
wav, mp3, mp4, wma, wmv, midi and m4a. When found, the list of
files, as well as file attributes are stored in an SQLite 
database (user will be prompted for the path of the database). 
If the database is not pre-existing, then it will be created.
Again, the user is prompted to provide the name of the database
table where the data are stored.
.NOTES
Copyright (c) 2018 DevSolutions Ltd. All rights reserved.
See LICENSE for details.
.LINK
https://github.com/DevSolutionsLtd/narc-media
#>

# Ensure permission to run PS scripts
if (-not $(Get-ExecutionPolicy).Equals('Unrestricted')) {

    Set-ExecutionPolicy -ExecutionPolicy 'ByPass' -Scope CurrentUser
}

# Load user-defined functions
. $PSScriptRoot/helpers.ps1        
# Check and if possible ensure module availability
. $PSScriptRoot/install-pssqlite.ps1

Import-Module PSSQLite -Verbose

# Collect a list of media files
$prompt = "Enter the path of the directory where your search will start"
[string]$srchRoot = Read-Host -Prompt $prompt
if (-not $(Test-Path $srchRoot)) { 
    Write-Error "Path does not exist" 
}
else { 
    Write-Output "Searching... "
}
                                              # TODO: Complain about inability to use string variable
$fileList = Get-ChildItem $srchRoot -Recurse -Include *.wav,*.mp3,*.mp4,*.wma,*.wmv,*.midi,*.m4a 
if ($null -eq $fileList) {
    Write-Output "No media files were discovered`n"
    exit
}
else {
    [int]$numFiles = $fileList.Count
    Write-Output "Search completed.`n$numFiles files were found.`n"
}

# Connect to database
# If table does not exist, create new one
[string]$Database = Read-Host -Prompt "Provide path to new/existing database"

[string]$table = Read-Host -Prompt "Enter the name of the table you want to query"
$SQLQuery = "CREATE TABLE IF NOT EXISTS $table (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT,
    minister TEXT,
    created DATETIME NOT NULL,
    modified DATETIME NOT NULL,
    accessed DATETIME NOT NULL,
    format TEXT NOT NULL,
    size INTEGER NOT NULL,
    filepath TEXT NOT NULL,
    filename TEXT NOT NULL,
    location TEXT NOT NULL,
    computer TEXT NOT NULL,
    user TEXT
    )"

Invoke-SqliteQuery -Query $SQLQuery -DataSource $Database

$response = Get-Opt -Entry "View the resulting schema? (Y/N)"
if ($response -eq 'Y') {
    Invoke-SqliteQuery -DataSource $Database -Query "PRAGMA table_info($table)" 
}

foreach ($file in $fileList.FullName) 
{
    # Remove apostrophe's from any of the paths
    if ($file.Contains("'")) {
        $newName = $file.Replace("'", "")
        Write-Output "Renaming $file by removing special character (')"
        Rename-Item -Path $file -NewName $newName -Force 
        $file = $newName
    }

    $props = Get-ItemProperty $file
    $SQLQuery = "INSERT INTO $table (
                     created,
                     modified,
                     accessed,
                     format,
                     size,
                     filepath,
                     filename,
                     location,
                     computer,
                     user)
                 VALUES (
                     @created,
                     @modified,
                     @accessed,
                     @format,
                     @size,
                     @filepath,
                     @filename,
                     @location,
                     @computer,
                     @user)" 
    Invoke-SqliteQuery -DataSource $Database -Verbose -Query $SQLQuery `
    -SqlParameters @{
                     created = $props.CreationTime
                     modified = $props.LastWriteTime
                     accessed = $props.LastAccessTime
                     format = $props.Extension
                     size = $props.Length
                     filepath = $props.FullName
                     filename = $props.Name
                     location = $props.DirectoryName
                     computer = $env:COMPUTERNAME
                     user = $env:USERNAME
                    }
}
