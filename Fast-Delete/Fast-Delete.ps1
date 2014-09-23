<#
.SYNOPSIS
Fast-Delete
AUTHOR: Angelo Yin
EMAIL: angelo.yin@gmail.com

.DESCRIPTION
In order to resolve to delete big data on windows.
When to delete big data with mounts of files on windows in explorer,
explorer will be hanging up and speed is slow. Whole windows
will be slowed down.

.NOTES
DONE: Remove-Item : The specified path, file name, or both are too long. The fully qualified file name must be less than 260
Solution:
ref: http://superuser.com/questions/78434/tool-for-deleting-directories-with-path-names-too-long-for-normal-delete
rmdir /S /Q <dir>
ref: http://social.technet.microsoft.com/wiki/contents/articles/12179.net-powershell-path-too-long-exception-and-a-net-powershell-robocopy-clone.aspx
ref: http://blogs.msdn.com/b/kebab/archive/2013/06/09/an-introduction-to-error-handling-in-powershell.aspx

##########
TODO: Exception calling "DeleteFolder" with "2" argument(s): "Exception from HRESULT: 0x800A004C (CTL_E_PATHNOTFOUND)"
At D:\Tools\Delete-Folder-Recursely.ps1:27 char:20
+         Measure-Command {$fso.DeleteFolder($path,$true)}
+                          ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [], MethodInvocationException
    + FullyQualifiedErrorId : ComMethodTargetInvocation

.LINK
http://social.technet.microsoft.com/Forums/windowsserver/en-US/14089f8a-65eb-4c31-8d87-2485963bda2b/quickly-delete-large-folders-with-ps?forum=winserverpowershell

cls
Write-Host "Method 1: Use native cmdlets"
Measure-Command {Remove-Item -Path "\\<Server>\Home$\DelTest1" -Recurse -Force}

Write-Host "Method 2: FileSystemObject still works"
$fso = New-Object -ComObject scripting.filesystemobject
Measure-Command {$fso.DeleteFolder("\\<Server>\Home$\DelTest2",$true)}

Write-Host "Method 3: Use .NET classes"
Measure-Command {dir "\\<Server>\Home$\DelTest3*" | foreach { [io.directory]::delete($_.fullname,$true) }}

.EXAMPLE
 .\Fast-Delete.ps1 D:\tmp2

#>
param($path = $null)

$ErrorActionPreference = "Stop"

$ErrorMark = "The specified path, file name, or both are too long"
function Remove-Path($path)
{
	try {
		Remove-Item -Path "$path" -Recurse -Force
	} catch {
		if (($_ | Out-String).Contains($ErrorMark)) {
			Write-Host $_ -Foreground Red
			Write-Host "********************"
			Write-Warning "Change to use Cmd /C rmdir /S /Q <path>"
			Cmd /C "rmdir /S /Q $path"
		} else {
			throw $_
		}
	}
}

if ($path -eq $null) {
	Write-Error "Path param is required."
	return
}

$title = "Delete file"

$message = "Will go to delete $path recersely. Please confirm?"

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
	"Deletes all the files in the folder."

$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
	"Retains all the files in the folder."

$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)

[int]$defaultOption = 1
$result = $host.ui.PromptForChoice($title, $message, $options, $defaultOption)

switch ($result) {
0 {
	Write-Host "Deleting $path..."
	Measure-Command {Remove-Path $path}
	}
1 {
	Write-Host "Delete action is canceled."
	}
}