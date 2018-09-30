
function Get-Opt
{
    <#
    .SYNOPSIS
    Provides options for user input
    #>
    param([string]$Entry)
    $opt = Read-Host -Prompt $Entry
    switch ($opt)
    {
        Y { $choice = "Y" }
        N { $choice = "N" }
    }
    return $choice
}

# Edits records in the database
function Edit-Record
{
    <#
    .SYNOPSIS
    Edits a given record in the database by issuing an SQL UPDATE query.
    #>
    param(
        [string]$tableName,
        [string]$Field,
        [int]$UniqueId,
        $Connection
        )
    $prompt = "Enter a new '$Field' field for this file or type '-j' to skip"
    [string]$newField = Read-Host -Prompt $prompt
    if ($newField -ne '-j') {
        $stmnt = "UPDATE $tableName SET $Field = '$newField' WHERE ID = $ID"
        Invoke-SqliteQuery -SQLiteConnection $Connection -Query $stmnt
    }
    else { Write-Output "'$Field' was skipped`n" }
}
