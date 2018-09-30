# rename-media.ps1
# Companion script to 'locate-media.ps1'

# Copyright (c) 2018 DevSolutions Ltd. All rights reserved.
# See LICENSE for details.

# ------------------------------------------------------------
# Powershell script for reviewing, identifying and 
# relabelling audio and video nedia files in a database
# ------------------------------------------------------------

. $PSScriptRoot/helpers.ps1

Import-Module PSSQLite

# Create an SQLite connection
[string]$database = Read-Host -Prompt "Enter path to the database"
$Conn = New-SQLiteConnection -DataSource $database

# Fetch a record of files without titles
$table = Read-Host -Prompt "Enter the name of the table you want to query"
$query = "SELECT filepath FROM $table WHERE title IS NULL"
[array]$arrFiles = Invoke-SqliteQuery -SQLiteConnection $Conn -Query $query
$numFiles = $arrFiles.Count
Read-Host -Prompt "`n$numFiles records are avaiable for editing. Press ENTER to continue"

# Bring up the media player 
Add-Type -AssemblyName presentationCore
$mediaPlayer = New-Object System.Windows.Media.MediaPlayer

# Loop through the list of files, playing them one after the other
# and making any relevant edits to the records in the database
foreach ($file in $arrFiles.filepath)
{    
    # Get the unique identifier of this particular file
    $query = "SELECT ID FROM $table WHERE filepath = '$file'"
    [long]$ID = $(Invoke-SqliteQuery -SQLiteConnection $Conn -Query $query).ID

    $mediaPlayer.Open("$file")
    $mediaPlayer.Play()

    $filename = Split-Path $file -Leaf
    [string]$ans = Read-Host -Prompt "`nNow Playing - '$filename'.`nTo stop playback, type 'q'"
    if ($ans -eq 'q')
    {
        $mediaPlayer.Stop()
        $ans = Read-Host -Prompt "Edit the record for this media file? (Y/N)"
        if ($ans -eq 'Y') 
        {
            Edit-Record -tableName $table -Field "title" -UniqueId $ID -Connection $Conn
            Edit-Record -tableName $table -Field "minister" -UniqueId $ID -Connection $Conn

            # View selected fields
            Write-Host "Status:`n" -ForegroundColor Yellow
            $query = "SELECT title, minister, filename FROM $table WHERE ID = $ID"
            Invoke-SqliteQuery -SQLiteConnection $Conn -Query $query
        }
        $ans = Read-Host -Prompt "Listen to another file? (Y/N)"
        if ($ans -eq 'N') { break}
    }
 }
$mediaPlayer.Close()

# References: 
# 1. http://eddiejackson.net/wp/?p=9268
# 2. http://ramblingcookiemonster.github.io/SQLite-and-PowerShell/
