# *narc-media*: A system for retrieving, storing and editing media file metadata
This repository contains Powershell scripts that enable the user to do the following:

* Find media files (audio and video) on a drive.
* Create a database of file metadata (i.e. file information)
* Play files from the database
* Edit fields of interest (i.e. Title and Minister's Name)

## Usage
### Quick start (TL;DR)
The easiest way to use this repository is as follows:

* `git clone` or download/exract the ZIP archive of this repository.
* [Start PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/setup/starting-windows-powershell?view=powershell-6) and then [navigate](https://docs.microsoft.com/en-us/powershell/scripting/getting-started/cookbooks/managing-current-location?view=powershell-6) to the repository.
* Run `./index.ps1` and follow the prompts.

## More details
The user may work directly with the core files by navigating to the `scripts` directory and doing the following:  

### Media search and store
To find media files within a directory and its children, run the following line in the console
```
./locate-media.ps1 path/to/folder
```
where *folder* is the path to a given directory. For example, to search the entire computer (recommended) one should say
```
./locate-media.ps1 C:
```
The file metadata are extracted and stored in an `SQLite` database, but the actual files are left *in situ*. Note that this operation may take some time to complete.

### Media player and database update
To update the database, run this command
```
./rename-media.ps1 
```
The user will be prompted to supply the path to the database; these prompts should be followed to make any desired changes to the database. The user will also be given the option to play a media file. Note that for video files, only the audio stream is presented.

## Dependencies
The scripts depend on [*SQLite*](https://sqlite.org/download.html) binaries and the [PSSQLite Module](https://github.com/RamblingCookieMonster/PSSQLite), and will attempt to install them if missing. Should this fail, visit those locations to obtain them.  

Also, the scripts will work best for PowerShell version 3.0 and above. To check version, run
```
$PSVersionTable.PSVersion
```

## Feedback
Please report any issues [here](https://github.com/DevSolutionsLtd/narc-media/issues) or email <victor@dev-solu.com>.
