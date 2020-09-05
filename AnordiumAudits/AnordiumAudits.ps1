#Anordium Audits#
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

#Global GPO Result Function
Function GPResults{
	$global:GPODump = gpresult.exe /SCOPE COMPUTER /Z | Format-Table -Autosize | Out-String -Width 1200
	if([string]::IsNullOrEmpty($global:GPODump)){
		$global:GPODump = "Error"
	}
}

# Menu Nav
$WelcomeSubmitButton_Click = {
	$MainForm.Hide()
	$MainFormXYLoc = $MainForm.Location
	$AuxiliaryForm.Location = $MainFormXYLoc
	GPResults
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
		$AllOutput.AppendText("You must select an object from the script list.")
	}
}

# Requirement Two Tab
	#Sample Services for Default Vendor Passwords
	Function Req2SampleDefaultPasswords{
		$Req2Output.AppendText("Sample Services for Default Vendor Passwords:`n")

	}

	#List of Runnning Processes
	Function Req2RunningProcesses{
		$Req2Output.AppendText("List of Running Processes:`n")
		try{
			$Req2ProcessList = Get-Process | Select-Object name, Path | Sort-Object name | Format-Table -Autosize | Out-String -Width 1200
			$Req2Output.AppendText($Req2ProcessList)
		}catch{
			$Req2Output.AppendText("Unable to List Running Processes.")
		}
	}

	#List of Running Services
	Function Req2RunningServices{
		$Req2Output.AppendText("List of Running Services:`n")
		try{
			$Req2SvcListRunning = Get-Service | Where-Object Status -eq "Running" | Sort-Object Name | Format-Table -Autosize | Out-String -Width 1200
			$Req2Output.AppendText($Req2SvcListRunning)
		}catch{
			$Req2Output.AppendText("Unable to List Running Serivces.")
		}
	}

	#Grab Listening Services
	Function Req2ListeningServices{
		$Req2Output.AppendText("List of Listening Services:`n")
		try{
			$Req2SvcListListening = Get-NetTCPConnection | Sort-Object LocalPort,LocalAddress | Format-Table -Autosize | Out-String -Width 1200
			$Req2Output.AppendText($Req2SvcListListening)
		}catch{
			$Req2Output.AppendText("Unable to Grab Listening Services.")
		}
	}

	#Grab Installed Software
	Function Req2GrabInstalledSoftware{
		$Req2Output.AppendText("List of Installed Software:`n")
		try{
			$Req2SoftwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName | Format-Table -Autosize | Out-String -Width 1200
			$Req2Output.AppendText($Req2SoftwareList)
		}catch{
			$Req2Output.AppendText("Unable to Grab Installed Software.")
		}
	}

	#Grab Installed Features
	Function Req2GrabInstalledFeatures{
		$Req2Output.AppendText("List of Installed Windows Features:`n")
		try{
			$Req2FeatureList = Get-WindowsFeature | Format-Table -Autosize | Out-String -Width 1200
			$Req2Output.AppendText($Req2FeatureList)
		}catch{
			$Req2Output.AppendText("Unable to Grab Installed Features.")
		}
	}

	#onClick Event Handler
	$Req2ScriptList_ListUpdate = {
		if($Req2ScriptList.SelectedItem -eq "Sample Services for Default Vendor Passwords"){
			$Req2Output.Clear()
			Req2SampleDefaultPasswords
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Running Processes"){
			$Req2Output.Clear()
			Req2RunningProcesses
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Running Services"){
			$Req2Output.Clear()
			Req2RunningServices
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Listening Services"){
			$Req2Output.Clear()
			Req2ListeningServices
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Installed Software"){
			$Req2Output.Clear()
			Req2GrabInstalledSoftware
		}elseif($Req2ScriptList.SelectedItem -eq "Grab Installed Windows Features"){
			$Req2Output.Clear()
			Req2GrabInstalledFeatures
		}elseif($Req2ScriptList.SelectedItem -eq "Everything in Requirement Two"){
			$Req2Output.Clear()
			$Req2Output.AppendText("Everything in Requirement Two `n")
			Req2SampleDefaultPasswords
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2RunningProcesses
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2RunningServices
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2ListeningServices
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2GrabInstalledSoftware
			$Req2Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req2GrabInstalledFeatures
		}else{
			$Req2Output.Clear()
			$Req2Output.AppendText("You must select an object from the script list.")
		}
	}

# Requirement Four Tab
	# Analyse Wi-Fi Envrioment
	Function Req4WifiScan {
		$Req4Output.AppendText("List of Wi-Fi Networks:`n")
		try{
			$Req4WifiList = netsh wlan show networks mode=Bssid | Format-Table -Autosize | Out-String -Width 1200
			$Req4Output.AppendText($Req4WifiList)
		}catch{
			$Req4Output.AppendText("Unable to find Wi-Fi Networks")
		}
	}

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
			Req4WifiScan
		}elseif($Req4ScriptList.SelectedItem -eq "Analyse Keys and Certificates"){
			$Req4Output.Clear()
			Req4GetKeysAndCerts
		}elseif($Req4ScriptList.SelectedItem -eq "Everything in Requirement Four"){
			$Req4Output.Clear()
			$Req4Output.AppendText("Everything in Requirement Four`n")
			Req4WifiScan
			$Req4Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req4GetKeysAndCerts
		}else{
			$Req4Output.Clear()
			$Req4Output.AppendText("You must select an object from the script list.")
		}
	}

# Requirement Five Tab
	$Global:Req5Switch = $false 
	# Antivirus Program and GPO Analysis
	Function Req5AVSettingsAndGPO {
		$Req5Output.AppendText("List of AV Programs Detected. (This may take a while):`n")
		$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version | Where-Object {($_.Vendor -like "*Avira*") -or ($_.Vendor -like "*Avast*") -or ($_.Vendor -like "*AVG*") -or ($_.Vendor -like "*Bitdefender*") -or ($_.Vendor -like "*ESET*") -or ($_.Vendor -like "*Kaspersky*") -or ($_.Vendor -like "*Malwarebytes*") -or ($_.Vendor -like "*McAfee*") -or ($_.Vendor -like "*NortonLifeLock*") -or ($_.Vendor -like "*Sophos*") -or ($_.Vendor -like "*Symantec*") -or ($_.Vendor -like "*Trend Micro*")} | Sort-Object Vendor,Name | Format-Table -Autosize | Out-String -Width 1200
			if([string]::IsNullOrEmpty($AVProgramQuery)){
				$Req5Output.AppendText("No AV detected, Here is the list of all programs detected and a GPO Dump for futher analysis. (This may take a while):`n")
				$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version,InstallDate | Sort-Object Vendor,Name | Format-Table -Autosize | Out-String -Width 1200
				$Req5Output.AppendText($AVProgramQuery)
			}else{
				$Req5Output.AppendText($AVProgramQuery)
			}
		$Req5Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
		$Req5Output.AppendText("Check GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
		
		if($global:Req5Switch -eq $true){
			$Req5Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			$Req5Output.AppendText("Check GPO Dump for Software Deployment Settings in Organization")
			$Req5Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			$Req5Output.AppendText("Check end user permissions to modify antivirus software")
			$global:Req5Switch = $false
			$Req5Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($global:GPODump)
		}else{
			$Req5Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($global:GPODump)
		}
	}
	
	# Grab Software Deployment Settings in Organization
	Function Req5SoftwareDeployment {
		$Req5Output.AppendText("Check GPO Dump for Software Deployment Settings in Organization`n")
		$Req5Output.AppendText($global:GPODump)
	}

	# Check end user permissions to modify antivirus software
	Function Req5AVPermissions {
		$Req5Output.AppendText("Check end user permissions to modify antivirus software`n")
		$Req5Output.AppendText($global:GPODump)
	}

# onClick Event Handler
$Req5ScriptList_ListUpdate = {
	if($Req5ScriptList.SelectedItem -eq "Antivirus Program and GPO Analysis"){
		$Req5Output.Clear()
		Req5AVSettingsAndGPO
	}elseif($Req5ScriptList.SelectedItem -eq "Grab Software Deployment Settings in Organization"){
		$Req5Output.Clear()
		Req5SoftwareDeployment
	}elseif($Req5ScriptList.SelectedItem -eq "Check end user permissions to modify antivirus software"){
		$Req5Output.Clear()
		$Req5Output.AppendText("Check end user permissions to modify antivirus software")
		Req5AVPermissions
	}elseif($Req5ScriptList.SelectedItem -eq "Everything in Requirement Five"){
		$Req5Output.Clear()
		$Req5Output.AppendText("Everything in Requirement Five`n")
		$Global:Req5Switch = $true
		Req5AVSettingsAndGPO
	}else{
		$Req5Output.Clear()
		$Req5Output.AppendText("You must select an object from the script list.")
	}
}

# Requirement Seven Tab
	#Folder Input
	Function Req7FolderInput {
		$FilePopupTmp = $AuxiliaryForm.Req7FolderBrowserDialog.ShowDialog()
			if($FilePopupTmp -eq "OK"){    
				$Global:FilePathFilePopupTmp = $Req7FolderBrowserDialog.SelectedPath
			}else{
				$Req7Output.AppendText("`nInvalid Folder Selected`n")
			}
		}

	#Grab and analyse folder permissions that hold sensitive data
	Function Req7FolderPrems {
		$Req7Output.AppendText("Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
		$Req7Output.AppendText("`nFolder Selected: " + $Global:FilePathFilePopupTmp)
			try{
				$LocalFolderPrems = (Get-Acl -Path $Global:FilePathFilePopupTmp).Access | Sort-Object IsInherited, Identity-Reference | Select-Object IdentityReference, FileSystemRights, IsInherited| Format-List IdentityReference, FileSystemRights, IsInherited | Out-String
				$Req7Output.AppendText($LocalFolderPrems)
			}catch{
					$Req7Output.AppendText("Error")
			}

		$Req7Output.AppendText("`nNetwork folder permissions...`n")
		$SharesArray = New-Object System.Collections.ArrayList
		$SambaShare = (Get-SmbShare).Path

		$SambaSwitch = $false

			foreach($SambaPath in $SambaShare){
				$SharesArray.Add($SambaPath.Name)
				if($SambaPath -eq $Global:FilePathFilePopupTmp){
					$SambaSwitch = $true
				}
			}
			if($SambaSwitch -eq $true){
				$SambaShareName = (Get-SMBShare | Where-Object -Property Path -eq $Global:FilePathFilePopupTmp).Name
				$SambaShareStatus = Get-SmbShareAccess $SambaShareName | Out-String
				$Req7Output.AppendText($Global:FilePathFilePopupTmp + " exists as a Samba Share")
				$Req7Output.AppendText($SambaShareStatus)
			}else{
				$Req7Output.AppendText($Global:FilePathFilePopupTmp + " Does not exist as a Samba Share")
			}
		}
	
	# Check for deny all permissions
	Function Req7DenyAll {
		$Req7Output.AppendText("Check for deny all permissions`n")
		try{
			$Req7FolderPerms = Get-ChildItem -Path $Global:FilePathFilePopupTmp | Get-Acl | Format-List | Out-String
			if([string]::IsNullOrEmpty($Req7FolderPerms)){
				$Req7Output.AppendText("No Child Objects Found, Select Root Object that contains a Child Object.")
			}else{
				$Req7Output.AppendText($Req7FolderPerms)
			}
		}catch{
			$Req7Output.AppendText("`nSomething went wrong...`n")
		}
	}

	# Grab User Privileges
	Function Req7UserPriviledges {
		$Req7Output.AppendText("Grab User Privileges`nThis may take a while`n")
		Start-Sleep -Seconds 0.5
		try{
			$ActiveDirectoryGroups = (Get-ADGroup -Filter *).Name
			foreach ($Group in $ActiveDirectoryGroups){
				$GroupMembership = Get-ADGroupMember -Identity $Group | Select-Object Name,SamaccountName,objectClass,distinguishedName | Sort-Object Name,objectClass | Format-Table | Out-String
				if([string]::IsNullOrEmpty($GroupMembership)){
					$Req7Output.AppendText("`nNo Users in " + $Group + "`n")
				}else{
					$Req7Output.AppendText("`nHere are the Users in " + $Group)
					$Req7Output.AppendText($GroupMembership)
				}
			}
		}catch{
			$Req7Output.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
		}
	}

	#onClick event handler
	$Req7ScriptList_ListUpdate = {
		if($Req7ScriptList.SelectedItem -eq "Grab and analyse folder permissions that hold sensitive data"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7FolderPrems
		}elseif($Req7ScriptList.SelectedItem -eq "Check for deny all permissions"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7DenyAll
		}elseif($Req7ScriptList.SelectedItem -eq "Grab User Privileges"){
			$Req7Output.Clear()
			Req7UserPriviledges
		}elseif($Req7ScriptList.SelectedItem -eq "Everything in Requirement Seven"){
			$Req7Output.Clear()
			$Req7Output.AppendText("Everything in Requirement Seven`n")
				Req7FolderInput
				Req7FolderPrems
				$Req7Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
				Req7DenyAll
				$Req7Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
				Req7UserPriviledges
				$Req7Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
		}else{
			$Req7Output.Clear()
			$Req7Output.AppendText("You must select an object from the script list.")
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
		$Req8Output.AppendText("Username: " + $env:UserName + "`nDomain: " + $env:UserDomain + "`nComputer: " + $env:ComputerName)
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
		$Req8Output.AppendText("Grab RDP Encryption and Idle Settings:")
		try{
			$RDPSettings = Get-WmiObject -Class 'Win32_TSGeneralSetting' -Namespace 'root/CIMV2/TerminalServices' | Select-Object PSComputerName,TerminalName,TerminalProtocol,Certifcates,CertificateName,MinEncryptionLevel,PolicySourceMinEncryptionLevel,PolicySourceSecurityLayer,SecurityLayer | Format-List | Out-String
			$Req8Output.AppendText($RDPSettings)	
		}catch{
			$Req8Output.AppendText("Error - No RDP Settings Found")
		}
		try{
			$Req8Output.AppendText("Power Plans:`n")
			$PowerPlanSettings = Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan -ErrorAction Stop | Select-Object -Property ElementName, IsActive | Format-Table -Autosize | Out-String -Width 1200 
			$Req8Output.AppendText($PowerPlanSettings)
		}catch{
			$Req8Output.AppendText("Error - Unable to find Power Plans, Ensure script is run in Administrator Mode.")
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
				$Req8Output.AppendText("You must select an object from the script list.")
			}
		}

# Requirement Ten Tab
	# Dump of Audit Category Settings
	Function Req10AuditSettings {
		$Req10Output.AppendText("Dump of Audit Category Settings`n")
		try{
			$Req10AuditList = auditpol.exe /get /category:* | Format-Table -Autosize | Out-String -Width 1200
			$Req10Output.AppendText($Req10AuditList)
		}catch{
			$Req10Output.AppendText("Unable to find Audit settings.")
		}
	}

	# Grab NTP Settings
	Function Req10NTPSettings {
		$Req10Output.AppendText("Grab NTP Settings for Current Device`n")
		try{
			$Req10NTPSettings = w32tm /query /status | Format-Table -Autosize | Out-String -Width 1200
			$Req10Output.AppendText($Req10NTPSettings)
		}catch{
			$Req10Output.AppendText("Unable to find NTP settings.")
		}
	}

	# Grab NTP Settings on Multiple Devices
	Function Req10NTPSettingsMultipleDevices {
		$Req10Output.AppendText("Check NTP Settings on Multiple Devices`nThis may take a while.`n")
		try{
			$ComputerList = Get-ADComputer -Filter * | Select-Object Name
			$ComputerArray = New-Object System.Collections.ArrayList
			foreach($Computer in $ComputerList){
				$ComputerArray.Add($Computer.Name)
			}
			$ShuffledComputerArray = $ComputerArray | Sort-Object {Get-Random}
			$Req10Counter = 0
			foreach($RandomComputer in $ShuffledComputerArray){
				$Req10Counter++
				if($Req10Counter -eq 5){
					break
				}else{
					try{
						$Req10NTPSettingsTesting = w32tm /query /status /computer:$RandomComputer | Format-Table -Autosize | Out-String -Width 1200
						$Req10Output.AppendText("`nNTP Settings for: " + $RandomComputer + "`n" + $Req10NTPSettingsTesting)
					}catch{
						$Req10Output.AppendText("Unable to find NTP settings.")
					}
				}
			}
		}catch{
			$Req10Output.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
		}
	}

	# Check Audit Log Permissions
	Function Req10AuditLogPrems {
		$Req10Output.AppendText("Check Audit Log Permissions`n")
		$Req10Output.AppendText("Listed below are the Domain & Enterprise Administrators:`n")
		try{
			$ADDomainAdminList = Get-ADGroupMember -Identity "Domain Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			$ADEnterpriseAdminList = Get-ADGroupMember -Identity "Enterprise Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			$Req10Output.AppendText("Domain Admins:`n" + $ADDomainAdminList)
			$Req10Output.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminList)
		}catch{
			$Req10Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
		}
		$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
		$Req10Output.AppendText("GPO Dump")
		$Req10Output.AppendText($global:GPODump)
	}

	# Grab Previous Audit Logs
	Function Req10PastAuditLogs {
		$Req10Output.AppendText("Grabbing Previous Audit Logs for the past three months`nThis may take a while`n")
		$AuditLogsBegin = (Get-Date).AddDays(-90)
		$AuditLogsEnd = Get-Date
		Start-Sleep -Seconds 0.5
		try{
			$AuditLogs = Get-EventLog -LogName Security -Source "*auditing*" -After $AuditLogsBegin -Before $AuditLogsEnd | Select-Object Index,Time,EntryType,InstanceID,Message | Format-Table -AutoSize | Out-String # -Width 10000
			$Req10Output.AppendText($AuditLogs)
		}catch{
			$Req10Output.AppendText("No Audit Logs Found.")
		}
	}

	#onClick event handler
	$Req10ScriptList_ListUpdate = {
		if($Req10ScriptList.SelectedItem -eq "Dump of Audit Category Settings"){
			$Req10Output.Clear()
			Req10AuditSettings
		}elseif($Req10ScriptList.SelectedItem -eq "Grab NTP Settings"){
			$Req10Output.Clear()
			Req10NTPSettings
		}elseif($Req10ScriptList.SelectedItem -eq "Check NTP Settings on Multiple Devices"){
			$Req10Output.Clear()
			Req10NTPSettingsMultipleDevices
		}elseif($Req10ScriptList.SelectedItem -eq "Check Audit Log Permissions"){
			$Req10Output.Clear()
			Req10AuditLogPrems
		}elseif($Req10ScriptList.SelectedItem -eq "Grab Previous Audit Logs"){
			$Req10Output.Clear()
			Req10PastAuditLogs
		}elseif($Req10ScriptList.SelectedItem -eq "Everything in Requirement Ten"){
			$Req10Output.Clear()
			$Req10Output.AppendText("Everything in Requirement Ten`n")
			Req10AuditSettings
			$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req10NTPSettings
			$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req10NTPSettingsMultipleDevices
			$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req10AuditLogPrems
			$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
			Req10PastAuditLogs
			$Req10Output.AppendText("`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n")
		}else{
			$Req10Output.Clear()
			$Req10Output.AppendText("You must select an object from the script list.")
		}
	}

# Extras Tab
	#System Infomation

	#Installed Updates

	#IP Config

	#TCP Connectivity

	#onClick Event Handler

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')