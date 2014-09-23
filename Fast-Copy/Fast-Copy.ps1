<#
.SYNOPSIS
	Fast-Copy is to resolve big data copy on windows.
.DESCRIPTION
	We usually do Hyper-V VM data copy from one serve to another. But data
is to T size. It is not good to use manual copy. It is not trackable and
explorer is always hanging up. Also for copy mount of files in small size.

BigData when data > 1G, we d better use it

Requirements:
	1. Better performance
	2. Copy log to track
	3. Run in command line

Copy method:
	1. robocopy
	2. xcopy /j without cache

.NOTES
TODO:
	1. Copy from src list to one dest path
	2. not use start-process to execute cmd, just output to console

Robocopy parameter using:
	/E :: copy subdirectories, including Empty ones.
	/Z :: copy files in restartable mode.
	/ZB :: use restartable mode; if access denied use Backup mode.
	/PF :: check run hours on a Per File (not per pass) basis.
	/MT[:n] :: Do multi-threaded copies with n threads (default 8).
		n must be at least 1 and not greater than 128.
		This option is incompatible with the /IPG and /EFSRAW options.
	Redirect output using /LOG option for better performance.
	/R:n :: number of Retries on failed copies: default 1 million.
	/V :: produce Verbose output, showing skipped files.
	/FP :: include Full Pathname of files in the output.
	/ETA :: show Estimated Time of Arrival of copied files.
	/LOG:file :: output status to LOG file (overwrite existing log).
	/TEE :: output to console window, as well as the log file.

XCOPY parameter using:
	/E	Copies directories and subdirectories, including empty ones.
		Same as /S /E. May be used to modify /T.
	/V	Verifies the size of each new file.
	/F	Displays full source and destination file names while copying.
	/Y	Suppresses prompting to confirm you want to overwrite an 
		existing destination file.
	/Z	Copies networked files in restartable mode.
	/J	Copies using unbuffered I/O. Recommended for very large files.
.LINK
http://blogs.technet.com/b/askperf/archive/2007/05/08/slow-large-file-copy-issues.aspx

.EXAMPLE

.EXAMPLE
#>

param(
	[Parameter(Mandatory = $true, Position = 1)]
	[string]$SrcPath,
	[Parameter(Mandatory = $true, Position = 2)]
	[string]$DestPath,
	[switch]$BigData)

if (-not (Test-Path $SrcPath)) {
	throw "Src path: $SrcPath does not exist!"
}

if (-not (Test-Path $DestPath)) {
	Write-Warning "Destination path: $DestPath does not exist!"
	Write-Host "Create Destination path: $DestPath."
	mkdir $DestPath
}

function Do-Robocopy ($src, $dest) {
	Write-Host "Start to do robocopy"
	$args = "$SrcPath $DestPath /E /ZB /MT /COPYALL `
		/R:10 /V /PF /FP /ETA /TEE /LOG:" + (Get-LogName)
	Start-Process "robocopy" $args -Wait
	Write-Host "End to do robocopy"
}

function Get-LogName
{
	$logName = (Get-Date  -UFormat "%Y%m%d-%H-%M-%S")
	return $logName + ".txt"
}

function Do-XCopy ($src, $dest) {
	Write-Host "Start XCopy from $src to $dest"
	$args = "$src $dest /E /V /F /Y /Z /J"
	Start-Process "XCopy" $args -Wait -RedirectStandardOutput (Get-LogName)
	Write-Host "End XCopy"
}

if($BigData) {
	Do-XCopy $SrcPath $DestPath
} else {
	Do-Robocopy $SrcPath $DestPath
}