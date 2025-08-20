#Requires -Module Az.Compute

<#
	.SYNOPSIS
	Start, stop, restart or show status information of a virtual machine in Azure
	.PARAMETER Action
	Select the action you would like to execute
	.PARAMETER VMQueryResult
	Select a virtual machine
	.PARAMETER Name
	The virtual machine name
	.PARAMETER ResourceGroup
	Specify the name of the resource group of the virtual machine
	.NOTES
	This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner.
	The customer or user is authorized to copy the script from the repository and use them in ScriptRunner.
	The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function,
	the use and the consequences of the use of this freely available script.
	PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
	© ScriptRunner Software GmbH
#>
function ManageVirtualMachine {
	[CmdletBinding()]
	param (
		[ValidateSet('Start', 'Stop', 'Restart', 'Show status')]
		[Parameter(Mandatory)]
		[string]$Action,
		[Parameter(Mandatory, HelpMessage = 'ASRDisplay(Splatting)')]
		[hashtable]$VMQueryResult,
		[Parameter(DontShow)]
		[string]$Name,
		[Parameter(DontShow)]
		[string]$ResourceGroup
	)

	'Query result:'
	$VMQueryResult | Out-String

	$cmdArgs = @{
		ResourceGroupName = $ResourceGroup
		Name = $Name
	}
	'Command args:'
	$cmdArgs | Out-String

	switch -Exact ($Action) {
		'Start' {
			Start-AzVM $cmdArgs
		}
		'Stop' {
			Stop-AzVM $cmdArgs
		}
		'Restart' {
			Restart-AzVM $cmdArgs
		}
		'Show status' {
			Get-AzVM $cmdArgs -Status
		}
		Default {
			"No match for action '$($Action)'."
		}
	}
}

