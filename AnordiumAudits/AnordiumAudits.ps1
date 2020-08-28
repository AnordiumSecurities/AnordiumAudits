#Anordium Audits#
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

$WelcomeSubmitButton_Click = {
	$MainForm.Hide()
	$MainFormXYLoc = $MainForm.Location
	$AuxiliaryForm.Location = $MainFormXYLoc
	$AuxiliaryForm.ShowDialog()
}

$AuxiliaryBack_Click = {
	$AuxiliaryForm.Hide()
	$AuxiliaryFormXYLoc = $AuxiliaryForm.Location
	$MainForm.Location = $AuxiliaryFormXYLoc
	$MainForm.Show()
}

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')