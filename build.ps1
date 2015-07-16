[cmdletbinding()]
param()

function Get-ScriptDirectory{
    split-path (((Get-Variable MyInvocation -Scope 1).Value).MyCommand.Path)
}
$scriptDir = ((Get-ScriptDirectory) + "\")

<#
.SYNOPSIS
    Will make sure that psbuild is installed and loaded. If not it will
    be downloaded.
#>
function EnsurePsbuildInstlled{
    [cmdletbinding()]
    param(
        [string]$psbuildInstallUri = 'https://raw.githubusercontent.com/ligershark/psbuild/master/src/GetPSBuild.ps1'
    )
    process{
        # if psbuild is not available
        if(-Not (Get-Command "Invoke-MsBuild" -errorAction SilentlyContinue)){
            'Installing psbuild from [{0}]' -f $psbuildInstallUri | Write-Verbose
            (new-object Net.WebClient).DownloadString($psbuildInstallUri) | iex
        }
        else{
            'psbuild already loaded' | Write-Verbose
        }
    }
}

[System.IO.FileInfo]$slnfile = (Join-Path $scriptDir '.\Fast Koala.sln')

# begin script
EnsurePsbuildInstlled
'Restoring nuget packages for [''{0}'']' -f $slnfile.FullName | Write-Host
&nuget restore "$($slnfile.FullName)"
Invoke-MSBuild -projectsToBuild $slnfile.FullName -visualStudioVersion 14.0 -properties @{'DeployExtension'='false'}