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
		$AllOutput.AppendText("A`n")
		$abc = Get-Service | Sort-Object Status,Name | Format-Table -Autosize | Out-String -Width 1200

		$AllOutput.AppendText($abc)

	}else{
		$AllOutput.Clear()
		$AllOutput.AppendText("F")
	}
}

# Requirement Two Tab
	#Sample Services for Default Vendor Passwords
	Function A{
		$Req2Output.AppendText("A`n")
	}

	#List of Running Services
	Function Req2RunningServices{
		$Req2Output.AppendText("List of Running Services:`n")
		$Req2SvcListRunning = Get-Service | Where-Object Status -eq "Running" | Sort-Object Name | Format-Table -Autosize | Out-String -Width 1200
		$Req2Output.AppendText($Req2SvcListRunning)
	}

	#Grab Listening Services
	Function Req2ListeningServices{
		$Req2Output.AppendText("List of Listening Services:`n")
		$Req2SvcListListening = Get-NetTCPConnection | Sort-Object LocalPort,LocalAddress | Format-Table -Autosize | Out-String -Width 1200
		$Req2Output.AppendText($Req2SvcListListening)
	}

	#Grab Installed Software
	Function Req2GrabInstalledSoftware{
		$Req2Output.AppendText("List of Installed Software:`n")
		$Req2SoftwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -Autosize | Out-String -Width 1200
		$Req2Output.AppendText($Req2SoftwareList)
	}

	#onClick Event Handler
	$Req2ScriptList_ListUpdate = {
		if($Req2ScriptList.SelectedItem -eq "Sample Services for Default Vendor Passwords"){
			$Req2Output.Clear()
			A
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Running Services"){
			$Req2Output.Clear()
			Req2RunningServices
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Listening Services"){
			$Req2Output.Clear()
			Req2ListeningServices
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Installed Software"){
			$Req2Output.Clear()
			Req2GrabInstalledSoftware
		}elseif($Req2ScriptList.SelectedItem -eq "Everything in Requirement Two"){
			$Req2Output.Clear()
			$Req2Output.AppendText("Everything in Requirement Two `n")
			Req2RunningServices
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2ListeningServices
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2GrabInstalledSoftware
		}else{
			$Req2Output.Clear()
			$Req2Output.AppendText("F")
		}
	}

# Requirement Four Tab
	# Analyse Keys and Certificates
	Function Req4GetKeysAndCerts{
		try{
			$Req4LocalMachineCerts = Get-ChildItem -Recurse -path cert:\LocalMachine | Format-List | Out-String
			$Req4CurrentUserCerts = Get-ChildItem -Recurse -path cert:\CurrentUser | Format-List | Out-String
			$Req4Output.AppendText("List of Keys and Certificates:`nLocal Machine Certificates:`n")
			$Req4Output.AppendText($Req4LocalMachineCerts)
			$Req4Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			$Req4Output.AppendText("Current User Certificates:`n")
			$Req4Output.AppendText($Req4CurrentUserCerts)
		}catch{
			$Req4Output.AppendText("Something went wrong, Could not get keys or certs.")
		}

	}

	#onClick Event Handler
	$Req4ScriptList_ListUpdate = {
		if($Req4ScriptList.SelectedItem -eq "Analyse Wi-Fi Environment"){
			$Req4Output.Clear()
			$Req4Output.AppendText("A")
		}elseif($Req4ScriptList.SelectedItem -eq "Analyse Keys and Certificates"){
			$Req4Output.Clear()
			Req4GetKeysAndCerts
		}elseif($Req4ScriptList.SelectedItem -eq "Everything in Requirement Four"){
			$Req4Output.Clear()
			$Req4Output.AppendText("Everything in Requirement Four`n")
			Req4GetKeysAndCerts
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
	#Grab Domain Password Policy Settings
	Function Req8DomainPasswordPolicy{
		$Req8Output.AppendText("Current Domain Password Policy Settings:")
		try{
			$CurrentDomainPolicies = (Get-ADForest -Current LoggedOnUser).Domains | %{ Get-ADDefaultDomainPasswordPolicy -Identity $_ } | Out-String
			$Req8Output.AppendText($CurrentDomainPolicies)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Grab Local Password Policy Settings
	Function Req8LocalPasswordPolicy{
		$Req8Output.AppendText("Grab Local Password Policy Settings:`nPlaceholder")
		
	}

	#Dump of Active Directory Users
	Function Req8DumpActiveADUsers{
		$Req8Output.AppendText("Dump of All AD Users:")
		try{
			$ADUserListAll = Get-ADUser -Filter * | Select-Object GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName |Sort-Object GivenName,Surname | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($ADUserListAll)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Dump of Disabled AD Users
	Function Req8DumpDisabledADUsers{
		$Req8Output.AppendText("Dump of All Disabled AD Users:")
		try{
			$ADUserListDisabled = Get-ADUser -Filter * | Where-Object Enabled -eq "False" | Select-Object GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName |Sort-Object GivenName,Surname | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($ADUserListDisabled)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Dump of Inactive AD Users
	Function Req8DumpInactiveADUsers{
		$Req8Output.AppendText("Dump of All Inactive AD Users:")
		try{
			$ADUserListInactiveADUsers = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90 | ?{$_.enabled -eq $True} | Select-Object Name,SamAccountName,UserPrincipalName,DistinguishedName,LastLogonDate |Sort-Object Name | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($ADUserListInactiveADUsers)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Grab Current User
	Function Req8GrabCurrentUser{
		$Req8Output.AppendText("Current Logged-In User:`n")
		$Req8Output.AppendText("Username: " + $env:UserName + "`nDomain:" + $env:UserDomain + "`nComputer: " + $env:ComputerName)
	}

	#Grab Local Administrator Accounts
	Function Req8GrabLocalAdmins{
		$Req8Output.AppendText("Grab Local Administrators:`n")
		try{
			$LocalAdminList = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($LocalAdminList)
		}catch [Microsoft.PowerShell.Commands.GroupNotFoundException]{
			$Req8Output.AppendText("`nError, Something went wrong. There are no Local Administrator Accounts.")
		}catch{
			$Req8Output.AppendText("`nError, Something Unexpected went wrong.")
		}
	}

	#Grab Domain Administrator Accounts
	Function Req8GrabDomainAdmins{
		$Req8Output.AppendText("Grab Domain & Enterprise Administrators:`n")
		try{
			$ADDomainAdminList = Get-ADGroupMember -Identity "Domain Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			$ADEnterpriseAdminList = Get-ADGroupMember -Identity "Enterprise Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText("Domain Admins:`n" + $ADDomainAdminList)
			$Req8Output.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminList)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Dump of Users whose Password Never Expire
	Function Req8DumpADUsersPasswordExpiry{
		$Req8Output.AppendText("Dump of Users whose Password Never Expires:`n")
		try{
			$ADUserPasswordExpiryList = Search-ADAccount -PasswordNeverExpires -UsersOnly | Select-Object Name, SamAccountName, DistinguishedName, PasswordNeverExpires | Format-Table -AutoSize | Out-String -Width 1200
			$Req8Output.AppendText($ADUserPasswordExpiryList)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Dump of Users and Their Last Password Change
	Function Req8DumpADUserLastPassChange{
		$Req8Output.AppendText("Dump of All AD Users and Their Last Password Change:`n")
		try{
			$ADUserPasswordLastChangeList = Get-aduser -filter * -properties PasswordLastSet, PasswordNeverExpires | Select-Object Name, SamAccountName, DistinguishedName, PasswordLastSet, PasswordNeverExpires | Sort-Object PasswordLastSet,PasswordNeverExpires | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($ADUserPasswordLastChangeList)
		}catch{
			$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
	}

	#Grab the Screensaver Settings
	Function Req8GrabScreensaverSettings{
		$Req8Output.AppendText("Grab of Screensaver Settings:`n")
		try{
			$ScreensaverSettings = Get-Wmiobject win32_desktop | Where-Object Name -match $env:USERNAME | Format-Table -Autosize | Out-String -Width 1200
			$Req8Output.AppendText($ScreensaverSettings)
		}catch{
			$Req8Output.AppendText("`nError, Screensaver Settings not found.")
		}	
	}

	#Grab RDP Encryption and Idle Settings
	Function Req8GrabRDPSettings{
		$Req8Output.AppendText("Grab RDP Encryption and Idle Settings:`nPlaceholder")
		try{

		}catch{

		}
	}
	#Check for MFA
	Function Req8CheckForMFA{
		$Req8Output.AppendText("Checking Domain for MFA Configs:`nPlaceholder")
	}

#onClick Event Handler
	$Req8ScriptList_ListUpdate = {
		if($Req8ScriptList.SelectedItem -eq "Grab Domain Password Policy Settings"){
			$Req8Output.Clear()
			Req8DomainPasswordPolicy
		}elseif($Req8ScriptList.SelectedItem -eq "Grab Local Password Policy Settings"){
			$Req8Output.Clear()
			Req8LocalPasswordPolicy
		}elseif($Req8ScriptList.SelectedItem -eq "Dump of Active Active Directory Users"){
			$Req8Output.Clear()
			Req8DumpActiveADUsers
		}elseif($Req8ScriptList.SelectedItem -eq "Dump of Disabled Active Directory Users"){
			$Req8Output.Clear()
			Req8DumpDisabledADUsers
		}elseif($Req8ScriptList.SelectedItem -eq "Dump of Inactive Active Directory Users"){
			$Req8Output.Clear()
			Req8DumpInactiveADUsers
		}elseif($Req8ScriptList.SelectedItem -eq "Grab Current User"){
			$Req8Output.Clear()
			Req8GrabCurrentUser
		}elseif($Req8ScriptList.SelectedItem -eq "Grab Local Administrator Accounts"){
			$Req8Output.Clear()
			Req8GrabLocalAdmins
		}elseif($Req8ScriptList.SelectedItem -eq "Grab Domain Administrator Accounts"){
			$Req8Output.Clear()
			Req8GrabDomainAdmins
		}elseif($Req8ScriptList.SelectedItem -eq "Dump of Users whose Password Never Expire"){
			$Req8Output.Clear()
			Req8DumpADUsersPasswordExpiry
		}elseif($Req8ScriptList.SelectedItem -eq "Dump of Users and Their Last Password Change"){
			$Req8Output.Clear()
			Req8DumpADUserLastPassChange
		}elseif($Req8ScriptList.SelectedItem -eq "Grab the Screensaver Settings"){
			$Req8Output.Clear()
			Req8GrabScreensaverSettings
		}elseif($Req8ScriptList.SelectedItem -eq "Grab RDP Encryption and Idle Settings"){
			$Req8Output.Clear()
			Req8GrabRDPSettings
		}elseif($Req8ScriptList.SelectedItem -eq "Check for MFA"){
			$Req8Output.Clear()
			Req8CheckForMFA
		}elseif($Req8ScriptList.SelectedItem -eq "Everything in Requirement Eight"){
			$Req8Output.Clear()
			$Req8Output.AppendText("Everything in Requirement Eight`n")
			Req8DomainPasswordPolicy
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8LocalPasswordPolicy
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8DumpActiveADUsers
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8DumpDisabledADUsers
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8DumpInactiveADUsers
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8GrabCurrentUser
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8GrabLocalAdmins
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8GrabDomainAdmins
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8DumpADUsersPasswordExpiry
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8DumpADUserLastPassChange
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8GrabScreensaverSettings
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8GrabRDPSettings
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req8CheckForMFA
			$Req8Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
		}else{
			$Req8Output.Clear()
			$Req8Output.AppendText("Error")
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