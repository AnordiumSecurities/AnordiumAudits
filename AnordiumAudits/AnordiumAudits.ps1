#Anordium Audits#
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing
# Menu Nav
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

# Everything Tab
$AllScriptList_ListUpdate = {
	if($AllScriptList.SelectedItem -eq "Everything"){
		$AllOutput.Clear()
		$AllOutput.AppendText("A")
	}else{
		$AllOutput.Clear()
		$AllOutput.AppendText("F")
	}
}

# Requirement Two Tab
$Req2ScriptList_ListUpdate = {
	if($Req2ScriptList.SelectedItem -eq "Sample Running Services"){
		$Req2Output.Clear()
		$Req2Output.AppendText("A")
	}elseif($Req2ScriptList.SelectedItem -eq "Grab Running Services"){
		$Req2Output.Clear()
		$Req2Output.AppendText("B")
	}elseif($Req2ScriptList.SelectedItem -eq "Grab Listening Services"){
		$Req2Output.Clear()
		$Req2Output.AppendText("C")
	}elseif($Req2ScriptList.SelectedItem -eq "Grab Installed Software"){
		$Req2Output.Clear()
		$Req2Output.AppendText("D")
	}elseif($Req2ScriptList.SelectedItem -eq "Everything in Requirement Two"){
		$Req2Output.Clear()
		$Req2Output.AppendText("Everything in Requirement Two")
	}else{
		$Req2Output.Clear()
		$Req2Output.AppendText("F")
	}
}

# Requirement Four Tab
$Req4ScriptList_ListUpdate = {
	if($Req4ScriptList.SelectedItem -eq "Analyse Wi-Fi Environment"){
		$Req4Output.Clear()
		$Req4Output.AppendText("A")
	}elseif($Req4ScriptList.SelectedItem -eq "Analyse Keys and Certificates"){
		$Req4Output.Clear()
		$Req4Output.AppendText("B")
	}elseif($Req4ScriptList.SelectedItem -eq "Everything in Requirement Four"){
		$Req4Output.Clear()
		$Req4Output.AppendText("Everything in Requirement Four")
	}else{
		$Req4Output.Clear()
		$Req4Output.AppendText("F")
	}
}

# Requirement Five Tab
$Req5ScriptList_ListUpdate = {
	if($Req5ScriptList.SelectedItem -eq "Grab Windows Defender Settings from GPO"){
		$Req5Output.Clear()
		$Req5Output.AppendText("A")
	}elseif($Req5ScriptList.SelectedItem -eq "Grab Software Deployment Settings in Organization"){
		$Req5Output.Clear()
		$Req5Output.AppendText("B")
	}elseif($Req5ScriptList.SelectedItem -eq "Check end user permissions to modify antivirus software"){
		$Req5Output.Clear()
		$Req5Output.AppendText("C")
	}elseif($Req5ScriptList.SelectedItem -eq "Everything in Requirement Five"){
		$Req5Output.Clear()
		$Req5Output.AppendText("Everything in Requirement Five")
	}else{
		$Req5Output.Clear()
		$Req5Output.AppendText("F")
	}
}

# Requirement Seven Tab
$Req7ScriptList_ListUpdate = {
	if($Req7ScriptList.SelectedItem -eq "Grab folder permissions that hold sensitive data"){
		$Req7Output.Clear()
		$Req7Output.AppendText("A")
	}elseif($Req7ScriptList.SelectedItem -eq "Analyse folder permissions"){
		$Req7Output.Clear()
		$Req7Output.AppendText("B")
	}elseif($Req7ScriptList.SelectedItem -eq "Check for deny all permissions"){
		$Req7Output.Clear()
		$Req7Output.AppendText("C")
	}elseif($Req7ScriptList.SelectedItem -eq "Grab User Privileges"){
		$Req7Output.Clear()
		$Req7Output.AppendText("D")
	}elseif($Req7ScriptList.SelectedItem -eq "Everything in Requirement Seven"){
		$Req7Output.Clear()
		$Req7Output.AppendText("Everything in Requirement Seven")
	}else{
		$Req7Output.Clear()
		$Req7Output.AppendText("F")
	}
}

# Requirement Eight Tab
$Req8ScriptList_ListUpdate = {
	if($Req8ScriptList.SelectedItem -eq "Grab Domain Password Policy Settings"){
		$Req8Output.Clear()
		$Req8Output.AppendText("1")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab Local Password Policy Settings"){
		$Req8Output.Clear()
		$Req8Output.AppendText("2")
	}elseif($Req8ScriptList.SelectedItem -eq "Dump of Active Active Directory Users"){
		$Req8Output.Clear()
		$Req8Output.AppendText("3")
	}elseif($Req8ScriptList.SelectedItem -eq "Dump of Disabled Active Directory Users"){
		$Req8Output.Clear()
		$Req8Output.AppendText("4")
	}elseif($Req8ScriptList.SelectedItem -eq "Dump of Inactive Active Directory Users"){
		$Req8Output.Clear()
		$Req8Output.AppendText("5")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab Current User"){
		$Req8Output.Clear()
		$Req8Output.AppendText("6")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab Local Administrator Accounts"){
		$Req8Output.Clear()
		$Req8Output.AppendText("7")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab Domain Administrator Accounts"){
		$Req8Output.Clear()
		$Req8Output.AppendText("8")
	}elseif($Req8ScriptList.SelectedItem -eq "Dump of Users whose Password Never Expire"){
		$Req8Output.Clear()
		$Req8Output.AppendText("9")
	}elseif($Req8ScriptList.SelectedItem -eq "Dump of Users and Their Last Password Change"){
		$Req8Output.Clear()
		$Req8Output.AppendText("10")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab the Screensaver Settings"){
		$Req8Output.Clear()
		$Req8Output.AppendText("11")
	}elseif($Req8ScriptList.SelectedItem -eq "Grab RDP Encryption and Idle Settings"){
		$Req8Output.Clear()
		$Req8Output.AppendText("12")
	}elseif($Req8ScriptList.SelectedItem -eq "Check for MFA"){
		$Req8Output.Clear()
		$Req8Output.AppendText("13")
	}elseif($Req8ScriptList.SelectedItem -eq "Everything in Requirement Eight"){
		$Req8Output.Clear()
		$Req8Output.AppendText("Everything in Requirement Eight")
	}else{
		$Req8Output.Clear()
		$Req8Output.AppendText("F")
	}
}

# Requirement Ten Tab
$Req10ScriptList_ListUpdate = {
	if($Req10ScriptList.SelectedItem -eq "Dump of Audit Category Settings from GPO"){
		$Req10Output.Clear()
		$Req10Output.AppendText("A")
	}elseif($Req10ScriptList.SelectedItem -eq "Grab NTP Settings"){
		$Req10Output.Clear()
		$Req10Output.AppendText("B")
	}elseif($Req10ScriptList.SelectedItem -eq "Check NTP Settings on Multiple Devices"){
		$Req10Output.Clear()
		$Req10Output.AppendText("C")
	}elseif($Req10ScriptList.SelectedItem -eq "Check Audit Log Permissions"){
		$Req10Output.Clear()
		$Req10Output.AppendText("D")
	}elseif($Req10ScriptList.SelectedItem -eq "Grab Previous Audit Logs"){
		$Req10Output.Clear()
		$Req10Output.AppendText("E")
	}elseif($Req10ScriptList.SelectedItem -eq "Everything in Requirement Ten"){
		$Req10Output.Clear()
		$Req10Output.AppendText("Everything in Requirement Ten")
	}else{
		$Req10Output.Clear()
		$Req10Output.AppendText("F")
	}
}

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')