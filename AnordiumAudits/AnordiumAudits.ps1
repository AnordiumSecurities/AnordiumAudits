#Anordium Audits#

$MainForm.ShowDialog()

$WelcomeSubmitButton_Click = {
	$MainForm.Hide()
	$AuxiliaryForm.ShowDialog()
}

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')
