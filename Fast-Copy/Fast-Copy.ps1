# Fast-Copy large files
# ref: http://blogs.technet.com/b/askperf/archive/2007/05/08/slow-large-file-copy-issues.aspx
# Several copy method
# robocopy
# xcopy /j without cache

# TODO
# Requirements:
# Copy from src list to one dest path

# TODO
#Issue about log
#not use start-process to execute cmd, just output to console

#BigData when data > 1G, we'd better use it

param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string]$SrcPath, 
    [Parameter(Mandatory = $true, Position = 2)]
    [string]$DestPath,
    [switch]$BigData) # by default is robocopy but use xcopy for big data

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
    #retry 10times
    #MT with 8 threads
    #                 /E :: copy subdirectories, including Empty ones.
    #                 /Z :: copy files in restartable mode.
    #                /ZB :: use restartable mode; if access denied use Backup mode.
    #                /PF :: check run hours on a Per File (not per pass) basis.
    #            /MT[:n] :: Do multi-threaded copies with n threads (default 8).
    #                       n must be at least 1 and not greater than 128.
    #                       This option is incompatible with the /IPG and /EFSRAW options.
    #                       Redirect output using /LOG option for better performance.
    #               /R:n :: number of Retries on failed copies: default 1 million.
    #                 /V :: produce Verbose output, showing skipped files.
    #                /FP :: include Full Pathname of files in the output.
    #               /ETA :: show Estimated Time of Arrival of copied files.
    #          /LOG:file :: output status to LOG file (overwrite existing log).
    #               /TEE :: output to console window, as well as the log file.
    #/LOG:log.txt, need timestamp on log file name
    $args = "$SrcPath $DestPath /E /ZB /MT /COPYALL /R:10 /V /PF /FP /ETA /TEE /LOG:" + (Get-LogName)
    Start-Process "robocopy" $args -Wait
    Write-Host "End to do robocopy"
        
}

function Get-LogName
{
        $logName = (Get-Date  -UFormat "%Y%m%d-%H-%M-%S")
        return $logName + ".txt"
}

function Do-XCopy ($src, $dest) {
    # XCOPY
    #  /E           Copies directories and subdirectories, including empty ones.
    #               Same as /S /E. May be used to modify /T.
    #  /V           Verifies the size of each new file.
    #  /F           Displays full source and destination file names while copying.
    #  /Y           Suppresses prompting to confirm you want to overwrite an
    #               existing destination file.
    #  /Z           Copies networked files in restartable mode.
    #  /J           Copies using unbuffered I/O. Recommended for very large files.
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