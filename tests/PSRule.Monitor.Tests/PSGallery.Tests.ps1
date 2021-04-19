# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#
# Unit tests for validating module for publishing
#

[CmdletBinding()]
param ()

# Setup error handling
$ErrorActionPreference = 'Stop';
Set-StrictMode -Version latest;

# Setup tests paths
$rootPath = $PWD;

Describe 'PSRule.Monitor' -Tag 'PowerShellGallery' {
    $modulePath = (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Monitor);

    Context 'Module' {
        It 'Can be imported' {
            Import-Module $modulePath -Force;
        }
    }

    Context 'Manifest' {
        $manifestPath = (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Monitor/PSRule.Monitor.psd1);
        $result = Test-ModuleManifest -Path $manifestPath;
        $Global:psEditor = $True;
        $Null = Import-Module $modulePath -Force;
        $commands = Get-Command -Module PSRule.Monitor -All;

        It 'Has required fields' {
            $result.Name | Should -Be 'PSRule.Monitor';
            $result.Description | Should -Not -BeNullOrEmpty;
            $result.LicenseUri | Should -Not -BeNullOrEmpty;
            $result.ReleaseNotes | Should -Not -BeNullOrEmpty;
        }

        It 'Exports functions' {
            $filteredCommands = @($commands | Where-Object -FilterScript { $_ -is [System.Management.Automation.FunctionInfo] });
            $filteredCommands | Should -Not -BeNullOrEmpty;
            $expected = @(
                'Send-PSRuleMonitorRecord'
            )
            $expected | Should -BeIn $filteredCommands.Name;
            $expected | Should -BeIn $result.ExportedFunctions.Keys;
        }
    }

    Context 'Static analysis' {
        It 'Has no quality errors' {
            $modulePath = (Join-Path -Path $rootPath -ChildPath out/modules/PSRule.Monitor);
            $result = @(Invoke-ScriptAnalyzer -Path $modulePath);

            $warningCount = ($result | Where-Object { $_.Severity -eq 'Warning' } | Measure-Object).Count;
            $errorCount = ($result | Where-Object { $_.Severity -eq 'Error' } | Measure-Object).Count;

            if ($warningCount -gt 0) {
                Write-Warning -Message "PSScriptAnalyzer reports $warningCount warnings.";
            }

            $errorCount | Should -BeLessOrEqual 0;
        }
    }
}
