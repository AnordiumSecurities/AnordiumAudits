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
	$Global:GPODumpExe = gpresult.exe /SCOPE COMPUTER /Z
	$Global:GPODump = $Global:GPODumpExe | Format-Table -Autosize | Out-String -Width 1200
	$Global:GPODumpHTML = $Global:GPODumpExe | ConvertTo-Html -As List -Fragment -PreContent "<h2>GPO Dump</h2>"

	if([string]::IsNullOrEmpty($global:GPODump)){
		$Global:GPODump = "Error"
		$Global:GPODumpHTML = $Global:GPODump | ConvertTo-Html -As Table -Fragment -PreContent "<h2>GPO Dump</h2>"
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
$EverythingToggle = $false
$Global:SectionHeader = "`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n"
$Global:SectionBreak = "`n`n---------------------------------------------------------------------------------------------------------`n`n"

$AllScriptList_ListUpdate = {
	if($AllScriptList.SelectedItem -eq "Everything"){
		$AllOutput.Clear()
		$EverythingToggle = $true
		# Getting Ready
			$AllOutput.AppendText("Gathering Infomation for Everything.`nBe patient and do not tab away. This may take awhile. `n")
			$AllOutput.AppendText($Global:SectionBreak)
		#Call Requirement Two Functions
			$AllOutput.AppendText("Everything in Requirement Two `n")
			Req2SampleDefaultPasswords
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningProcesses
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningServices
			$AllOutput.AppendText($Global:SectionHeader)
			Req2ListeningServices
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabInstalledSoftware
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Four Functions
			$AllOutput.AppendText("Everything in Requirement Four `n")
			Req4WifiScan
			$AllOutput.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Five Functions
			$AllOutput.AppendText("Everything in Requirement Five `n")
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Seven Functions
			$AllOutput.AppendText("Everything in Requirement Seven `n")
			Req7FolderInput
			Req7FolderPrems
			$AllOutput.AppendText($Global:SectionHeader)
			Req7DenyAll
			$AllOutput.AppendText($Global:SectionHeader)
			Req7UserPriviledges
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Eight Functions
			Req8DomainPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8LocalPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpActiveADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpDisabledADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpInactiveADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabCurrentUser
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabLocalAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabDomainAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUsersPasswordExpiry
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUserLastPassChange
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabScreensaverSettings
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabRDPSettings
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Ten Functions

	}else{
		$AllOutput.Clear()
		$AllOutput.AppendText("You must select an object from the script list.")
	}
}

# Requirement Two Tab
	#Sample Services for Default Vendor Passwords
	Function Req2SampleDefaultPasswords{
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("Sample Services for Default Vendor Passwords:`n")
		}else{
			$AllOutput.AppendText("Sample Services for Default Vendor Passwords:`n")
		}
	}

	#List of Runnning Processes
	Function Req2RunningProcesses{
		try{
			$Req2ProcessList = Get-Process | Select-Object name, Path | Sort-Object name
			$Req2ProcessListRTB = $Req2ProcessList  | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2ProcessListHTML = $Req2ProcessList | ConvertTo-Html -As Table -Property name,Path -Fragment -PreContent "<h2>List of Running Processes</h2>"
		}catch{
			$Req2ProcessListRTB = "Unable to List Running Processes."
			$Global:Req2ProcessListHTML = $Req2ProcessListRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>List of Running Processes</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("List of Running Processes:`n")
			$Req2Output.AppendText($Req2ProcessListRTB)
		}else{
			$AllOutput.AppendText("List of Running Processes:`n")
			$AllOutput.AppendText($Req2ProcessListRTB)
		}
	}

	#List of Running Services
	Function Req2RunningServices{
		try{
			$Req2SvcListRunning = Get-Service | Where-Object Status -eq "Running" | Sort-Object Name 
			$Req2SvcListRunningRTB = $Req2SvcListRunning | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SvcListRunningHTML = $Req2SvcListRunning | ConvertTo-Html -As Table -Property Status,Name,DisplayName -Fragment -PreContent "<h2>List of Running Services</h2>"
				
		}catch{
			$Req2SvcListRunningRTB = "Unable to List Running Serivces."
			$Global:Req2SvcListRunningHTML = $Req2SvcListRunningRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>List of Running Services</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("List of Running Services:`n")
			$Req2Output.AppendText($Req2SvcListRunningRTB)
		}else{
			$AllOutput.AppendText("List of Running Services:`n")
			$AllOutput.AppendText($Req2SvcListRunningRTB)
		}
	}

	#Grab Listening Services
	Function Req2ListeningServices{
		try{
			$Req2SvcListListening = Get-NetTCPConnection | Sort-Object LocalPort,LocalAddress 
			$Req2SvcListListeningRTB = $Req2SvcListListening | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SvcListListeningHTML = $Req2SvcListListening | ConvertTo-Html -As Table -Property LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess -Fragment -PreContent "<h2>Grab Listening Services</h2>"
		}catch{
			$Req2SvcListListeningRTB = "Unable to Grab Listening Services."
			$Global:Req2SvcListListeningHTML = $Req2SvcListListeningRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>Grab Listening Services</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("List of Listening Services:`n")
			$Req2Output.AppendText($Req2SvcListListeningRTB)
		}else{
			$AllOutput.AppendText("List of Listening Services:`n")
			$AllOutput.AppendText($Req2SvcListListeningRTB)
		}
	}

	#Grab Installed Software
	Function Req2GrabInstalledSoftware{
		try{
			$Req2SoftwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName 
			$Req2SoftwareListRTB = $Req2SoftwareList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SoftwareListHTML = $Req2SoftwareList | ConvertTo-Html -As Table -Property DisplayName, DisplayVersion, Publisher, InstallDate -Fragment -PreContent "<h2>Grab Installed Software</h2>"
		}catch{
			$Req2SoftwareListRTB = "Unable to Grab Installed Software."
			$Global:Req2SoftwareListHTML = $Req2SoftwareListRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>Grab Installed Software</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("List of Installed Software:`n")
			$Req2Output.AppendText($Req2SoftwareListRTB)
		}else{
			$AllOutput.AppendText("List of Installed Software:`n")
			$AllOutput.AppendText($Req2SoftwareListRTB)
		}
	}

	#Grab Installed Features
	Function Req2GrabInstalledFeatures{
		try{
			$Req2FeatureList = Get-WindowsFeature | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2FeatureListHTML = Get-WindowsFeature | ConvertTo-Html -As Table -Property DisplayName,Name,InstallState,FeatureType -Fragment -PreContent "<h2>List of Installed Windows Features</h2>"
		}catch{
			$Req2FeatureList = "Unable to Grab Installed Features."
			$Global:Req2FeatureListHTML = $Req2FeatureList | ConvertTo-Html -As List -Fragment -PreContent "<h2>List of Installed Windows Features</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("List of Installed Windows Features:`n")
			$Req2Output.AppendText($Req2FeatureList)
		}else{
			$AllOutput.AppendText("List of Installed Windows Features:`n")
			$AllOutput.AppendText($Req2FeatureList)
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
			$Req2Output.AppendText($Global:SectionHeader)
			Req2RunningProcesses
			$Req2Output.AppendText($Global:SectionHeader)
			Req2RunningServices
			$Req2Output.AppendText($Global:SectionHeader)
			Req2ListeningServices
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledSoftware
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
		}else{
			$Req2Output.Clear()
			$Req2Output.AppendText("You must select an object from the script list.")
		}
	}

	#Requirement Two Report Export
	Function Req2ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Requirement2Report = ConvertTo-HTML -Body "$ReportComputerName $Global:Req2ProcessListHTML $Global:Req2SvcListRunningHTML $Global:Req2SvcListListeningHTML $Global:Req2SoftwareListHTML $Global:Req2FeatureListHTML" -Title "PCI DSS Requirement Two Report" -PostContent "<p>Creation Date: $(Get-Date)<p>"
		$Requirement2Report | Out-File C:\Users\M.Chen\source\repos\AnordiumAudits\AnordiumAudits\bin\Release\PCI-DSS-Requirement-Two-Report.html
		$Req2Output.AppendText("Requirement Two Report Exported")
	}
	$Req2ExportReport = {
			$Req2Output.Clear()
			$Req2Output.AppendText("Writing Report for the Following`n`n")
			Req2RunningProcesses
			$Req2Output.AppendText($Global:SectionHeader)
			Req2RunningServices
			$Req2Output.AppendText($Global:SectionHeader)
			Req2ListeningServices
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledSoftware
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			Req2ExportReportFunction
	}

# Requirement Four Tab
	# Analyse Wi-Fi Envrioment
	Function Req4WifiScan {
		try{
			$Req4WifiList = netsh wlan show networks mode=Bssid | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req4WifiListHTML = $Req4WifiList | ConvertTo-Html -As Table -Property DisplayName, DisplayVersion, Publisher, InstallDate -Fragment -PreContent "<h2>Analyse Wi-Fi Envrioment</h2>"
		}catch{
			$Req4WifiList = "Unable to find Wi-Fi Networks"
			$Global:Req4WifiListHTML = $Req4WifiList | ConvertTo-Html -As Table -Property @{ l='Name'; e={ $_ } } -Fragment -PreContent "<h2>Analyse Wi-Fi Envrioment</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req4Output.AppendText("List of Wi-Fi Networks:`n")
			$Req4Output.AppendText($Req4WifiList)
		}else{
			$AllOutput.AppendText("List of Wi-Fi Networks:`n")
			$AllOutput.AppendText($Req4WifiList)
		}
	}

	# Analyse Keys and Certificates
	Function Req4GetKeysAndCerts{
		try{
			$Req4LocalMachineCerts = Get-ChildItem -Recurse -path cert:\LocalMachine
			$Req4CurrentUserCerts = Get-ChildItem -Recurse -path cert:\CurrentUser
			$Req4LocalMachineCertsRTB = $Req4LocalMachineCerts | Format-List | Out-String
			$Req4CurrentUserCertsRTB = $Req4CurrentUserCerts | Format-List | Out-String
			$Global:Req4LocalMachineCertsHTML = $Req4LocalMachineCerts | ConvertTo-Html -As List -Fragment -PreContent "<h2>List of Keys and Certificates</h2><h3>Local Machine Certificates</h3>"
			$Global:Req4CurrentUserCertsHTML = $Req4CurrentUserCerts | ConvertTo-Html -As List -Fragment -PreContent "<h2>Current User Certificates</h2>"
		}catch{
			$Req4LocalMachineCertsRTB = "Something went wrong, Could not get keys or certs."
			$Req4CurrentUserCertsRTB = "Something went wrong, Could not get keys or certs."
			$Global:Req4LocalMachineCertsHTML = $Req4LocalMachineCertsRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>List of Keys and Certificates</h2><h3>Local Machine Certificates</h3>"
			$Global:Req4CurrentUserCertsHTML = $Req4CurrentUserCertsRTB | ConvertTo-Html -As List -Fragment -PreContent "<h2>Current User Certificates</h2>"
		}

		if($EverythingToggle -eq $false){
			$Req4Output.AppendText("`nList of Keys and Certificates:`nLocal Machine Certificates:`n")
			$Req4Output.AppendText($Req4LocalMachineCertsRTB)
			$Req4Output.AppendText($Global:SectionHeader)
			$Req4Output.AppendText("Current User Certificates:`n")
			$Req4Output.AppendText($Req4CurrentUserCertsRTB)
		}else{
			$AllOutput.AppendText("List of Keys and Certificates:`nLocal Machine Certificates:`n")
			$AllOutput.AppendText($Req4LocalMachineCertsRTB)
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("Current User Certificates:`n")
			$AllOutput.AppendText($Req4CurrentUserCertsRTB)
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
			$Req4Output.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
		}else{
			$Req4Output.Clear()
			$Req4Output.AppendText("You must select an object from the script list.")
		}
	}

	#Requirement Four Report Export
	Function Req4ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Requirement4Report = ConvertTo-HTML -Body "$ReportComputerName $Global:Req4WifiListHTML $Global:Req4LocalMachineCertsHTML $Global:Req4CurrentUserCertsHTML" -Title "PCI DSS Requirement Four Report" -PostContent "<p>Creation Date: $(Get-Date)<p>"
		$Requirement4Report | Out-File C:\Users\M.Chen\source\repos\AnordiumAudits\AnordiumAudits\bin\Release\PCI-DSS-Requirement-Four-Report.html
		$Req4Output.AppendText("Requirement Four Report Exported")
	}
	$Req4ExportReport = {
			$Req4Output.Clear()
			$Req4Output.AppendText("Writing Report for the Following`n`n")
			Req4WifiScan
			$Req4Output.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			Req4ExportReportFunction
	}

# Requirement Five Tab
	$Global:Req5AllSwitch = $false 
	# Antivirus Program and GPO Analysis
	Function Req5AVSettingsAndGPO {
		if($EverythingToggle -eq $false){
			$Req5Output.AppendText("List of Anti-Virus Programs Detected. This may take a while.`n")
		}else{
			$AllOutput.AppendText("List of Anti-Virus Programs Detected. This may take a while.`n")
		}

		try{
			$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version | Where-Object {($_.Vendor -like "*Avira*") -or ($_.Vendor -like "*Avast*") -or ($_.Vendor -like "*AVG*") -or ($_.Vendor -like "*Bitdefender*") -or ($_.Vendor -like "*ESET*") -or ($_.Vendor -like "*Kaspersky*") -or ($_.Vendor -like "*Malwarebytes*") -or ($_.Vendor -like "*McAfee*") -or ($_.Vendor -like "*NortonLifeLock*") -or ($_.Vendor -like "*Sophos*") -or ($_.Vendor -like "*Symantec*") -or ($_.Vendor -like "*Trend Micro*")} | Sort-Object Vendor,Name
			$AVProgramQueryRTB = $AVProgramQuery | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req5AVProgramQueryHTML = $AVProgramQuery | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Antivirus Program and GPO Analysis</h2><h3>List of Anti-Virus Programs Detected</h3>"

			if([string]::IsNullOrEmpty($AVProgramQuery)){
				$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version,InstallDate | Sort-Object Vendor,Name
				$AVProgramQueryRTB = $AVProgramQuery | Format-Table -Autosize | Out-String -Width 1200
				$Global:Req5AVProgramQueryHTML = $AVProgramQuery | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Antivirus Program and GPO Analysis</h2><h3>No Anti-Virus detected, Here is the list of all programs detected</h3>"

				if($EverythingToggle -eq $false){
					$Req5Output.AppendText("No Anti-Virus detected, Here is the list of all programs detected and a GPO Dump for futher analysis:`n")
					$Req5Output.AppendText($AVProgramQueryRTB)
					$Req5Output.AppendText($Global:SectionHeader)
					$Req5Output.AppendText("Check GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
				}else{
					$AllOutput.AppendText("No AntiVirus detected, Here is the list of all programs detected and check the GPO Dump section for futher analysis.`n")
					$AllOutput.AppendText($AVProgramQueryRTB)
				}
			}else{
				if($EverythingToggle -eq $false){
					$Req5Output.AppendText($AVProgramQueryRTB)
				}else{
					$AllOutput.AppendText($AVProgramQueryRTB)
				}
			}
		}catch{
			if($EverythingToggle -eq $false){
				$Req5Output.AppendText("List of Anti-Virus Programs Failed. Something went wrong.`n")
			}else{
				$AllOutput.AppendText("List of Anti-Virus Programs Failed. Something went wrong.`n")
			}
		}

		# Req 5 Everything Switch
		if(($EverythingToggle -ne $true) -and ($Global:Req5AllSwitch -eq $true)){
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5SoftwareDeploymentString = "Check GPO Dump for Software Deployment Settings in Organization"
			$Req5Output.AppendText($Req5SoftwareDeploymentString)
			$Global:Req5SoftwareDeploymentHTML = $Req5SoftwareDeploymentString | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Grab Software Deployment Settings in Organization</h2>"
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5AVPermsString = "Check end user permissions to modify antivirus software in GPO"
			$Req5Output.AppendText($Req5AVPermsString)
			$Global:Req5AVPermsHTML = $Req5AVPermsString | ConvertTo-Html -As Table -Fragment -PreContent "<h2>Check end user permissions to modify antivirus software</h2>"
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($Global:GPODump)
			$Global:Req5AllSwitch = $false
		}elseif(($EverythingToggle -ne $false) -and ($Global:Req5AllSwitch -eq $true)){
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("Check GPO Dump for Software Deployment Settings in Organization")
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("Check end user permissions to modify antivirus software in GPO")
			$AllOutput.AppendText($Global:SectionHeader)
		}else{
			$Req5Output.AppendText($Global:SectionHeader)
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
		$Req5Output.AppendText("Check end user permissions to modify antivirus software in GPO Dump`n")
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
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
		}else{
			$Req5Output.Clear()
			$Req5Output.AppendText("You must select an object from the script list.")
		}
	}

	#Requirement Five Report Export
	Function Req5ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Requirement5Report = ConvertTo-HTML -Body "$ReportComputerName $Global:Req5AVProgramQueryHTML $Global:Req5SoftwareDeploymentHTML $Global:Req5AVPermsHTML $Global:GPODumpHTML" -Title "PCI DSS Requirement Five Report" -PostContent "<p>Creation Date: $(Get-Date)<p>"
		$Requirement5Report | Out-File C:\Users\M.Chen\source\repos\AnordiumAudits\AnordiumAudits\bin\Release\PCI-DSS-Requirement-Five-Report.html
		$Req5Output.AppendText("`nRequirement Five Report Exported")
	}
	$Req5ExportReport = {
			$Req5Output.Clear()
			$Req5Output.AppendText("Writing Report for the Following`n`n")
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
			$Req5Output.AppendText($Global:SectionHeader)
			Req5SoftwareDeployment
			$Req5Output.AppendText($Global:SectionHeader)
			Req5AVPermissions
			Req5ExportReportFunction
	}

# Requirement Seven Tab
	#Folder Input
	Function Req7FolderInput {
		$FilePopupTmp = $AuxiliaryForm.Req7FolderBrowserDialog.ShowDialog()
		if($FilePopupTmp -eq "OK"){    
			$Global:FilePathFilePopupTmp = $Req7FolderBrowserDialog.SelectedPath
		}
	}

	#Grab and analyse folder permissions that hold sensitive data
	Function Req7FolderPrems {
		if(-not([string]::IsNullOrEmpty($Global:FilePathFilePopupTmp))){
			# Write Header Text
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$Req7Output.AppendText("`nFolder Selected: " + $Global:FilePathFilePopupTmp)
			}else{
				$AllOutput.AppendText("Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$AllOutput.AppendText("`nFolder Selected: " + $Global:FilePathFilePopupTmp)
			}
			# Take user input/file path and get permissions
			try{
				$LocalFolderPrems = (Get-Acl -Path $Global:FilePathFilePopupTmp).Access | Sort-Object IsInherited, Identity-Reference | Select-Object IdentityReference, FileSystemRights, IsInherited| Format-List IdentityReference, FileSystemRights, IsInherited | Out-String
			}catch{
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("Error")
				}else{
					$AllOutput.AppendText("Error")
				}
			}
			# Append outputs
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText($LocalFolderPrems)
			}else{
				$AllOutput.AppendText($LocalFolderPrems)
			}
			# Find network folder premissions/samba share on selected folder
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("`nNetwork folder permissions...`n")
			}else{
				$AllOutput.AppendText("`nNetwork folder permissions...`n")
			}
			# Create Data Array with Samba Shares
			$SharesArray = New-Object System.Collections.ArrayList
			$SambaShare = (Get-SmbShare).Path
			$SambaSwitch = $false
			# Loop and check if any Samba share paths are the same as the user selection
			foreach($SambaPath in $SambaShare){
				$SharesArray.Add($SambaPath.Name)
				if($SambaPath -eq $Global:FilePathFilePopupTmp){
					$SambaSwitch = $true
				}
			}
			# Found Samba Share residing on the same user selection 
			if($SambaSwitch -eq $true){
				$SambaShareName = (Get-SMBShare | Where-Object -Property Path -eq $Global:FilePathFilePopupTmp).Name
				$SambaShareStatus = Get-SmbShareAccess $SambaShareName | Out-String
				# Output to user selected tab
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText($Global:FilePathFilePopupTmp + " exists as a Samba Share")
					$Req7Output.AppendText($SambaShareStatus)
				}else{
					$AllOutput.AppendText($Global:FilePathFilePopupTmp + " exists as a Samba Share")
					$AllOutput.AppendText($SambaShareStatus)
				}
			# No Samba Share Found
			}else{
				# Output to user selected tab
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText($Global:FilePathFilePopupTmp + " Does not exist as a Samba Share")
				}else{
					$AllOutput.AppendText($Global:FilePathFilePopupTmp + " Does not exist as a Samba Share")
				}
			}
		# Find Edge-Case if user input is empty
		}else{
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$Req7Output.AppendText("`nInvalid Folder Selected`n")
			}else{
				$AllOutput.AppendText("Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$AllOutput.AppendText("`nInvalid Folder Selected`n")
			}
		}
	}
	
	# Check for deny all permissions
	Function Req7DenyAll {
		if(-not([string]::IsNullOrEmpty($Global:FilePathFilePopupTmp))){
			# Write Header
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Check for deny all permissions`n")
			}else{
				$AllOutput.AppendText("Check for deny all permissions`n")
			}
			# Find premissions for user selected path
			try{
				$Req7FolderPerms = Get-ChildItem -Path $Global:FilePathFilePopupTmp | Get-Acl | Format-List | Out-String
				# Edge case for child objects
				if([string]::IsNullOrEmpty($Req7FolderPerms)){
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText("No Child Objects Found, Select Root Object that contains a Child Object.")
					}else{
						$AllOutput.AppendText("No Child Objects Found, Select Root Object that contains a Child Object.")
					}
				}else{
					# Output Data
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText($Req7FolderPerms)
					}else{
						$AllOutput.AppendText($Req7FolderPerms)
					}
				}
			}catch{
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`nSomething went wrong...`n")
				}else{
					$AllOutput.AppendText("`nSomething went wrong...`n")
				}
			}
		# Find Edge-Case if user input is empty
		}else{
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Check for deny all permissions`n")
				$Req7Output.AppendText("`nInvalid Folder Selected`n")
			}else{
				$AllOutput.AppendText("Check for deny all permissions`n")
				$AllOutput.AppendText("`nInvalid Folder Selected`n")
			}
		}
	}

	# Grab User Privileges
	Function Req7UserPriviledges {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req7Output.AppendText("Grab User Privileges`nThis may take a while`n")
			Start-Sleep -Seconds 0.5
		}else{
			$AllOutput.AppendText("Grab User Privileges`nThis may take a while`n")
			Start-Sleep -Seconds 0.5
		}
		# Query AD
		try{
			$ActiveDirectoryGroups = (Get-ADGroup -Filter *).Name
			foreach ($Group in $ActiveDirectoryGroups){
			$GroupMembership = Get-ADGroupMember -Identity $Group | Select-Object Name,SamaccountName,objectClass,distinguishedName | Sort-Object Name,objectClass | Format-Table | Out-String
			if([string]::IsNullOrEmpty($GroupMembership)){
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`nNo Users in " + $Group + "`n")
				}else{
					$AllOutput.AppendText("`nNo Users in " + $Group + "`n")
				}
			}else{
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`nHere are the Users in " + $Group)
					$Req7Output.AppendText($GroupMembership)
				}else{
					$AllOutput.AppendText("`nHere are the Users in " + $Group)
					$AllOutput.AppendText($GroupMembership)
					}
				}
			}
		}catch{
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}else{
				$AllOutput.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}
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
				$Req7Output.AppendText($Global:SectionHeader)
				Req7DenyAll
				$Req7Output.AppendText($Global:SectionHeader)
				Req7UserPriviledges
				$Req7Output.AppendText($Global:SectionHeader)
		}else{
			$Req7Output.Clear()
			$Req7Output.AppendText("You must select an object from the script list.")
		}
	}

# Requirement Eight Tab
	#Grab Domain Password Policy Settings
	Function Req8DomainPasswordPolicy{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Current Domain Password Policy Settings:")
		}else{
			$AllOutput.AppendText("Current Domain Password Policy Settings:")
		}
		# Data Gathering
		try{
			$CurrentDomainPolicies = (Get-ADForest -Current LoggedOnUser).Domains | %{ Get-ADDefaultDomainPasswordPolicy -Identity $_ } | Out-String
			# Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($CurrentDomainPolicies)
			}else{
				$AllOutput.AppendText($CurrentDomainPolicies)
			}
		# Edge case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Grab Local Password Policy Settings
	Function Req8LocalPasswordPolicy{
		# Data Output
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Grab Local Password Policy Settings:`nCheck GPO Dump for Local GPO Policies.")
			$Req8Output.AppendText($global:GPODump)
		}else{
			$AllOutput.AppendText("Grab Local Password Policy Settings:`nCheck GPO Dump for Local GPO Policies.")
			# Don't Dump GPO in all output but instead have a dedicated function for that later on.
			# $AllOutput.AppendText($global:GPODump)
		}
	}

	#Dump of Active Directory Users
	Function Req8DumpActiveADUsers{
		# Write Header 
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Dump of All AD Users:")
		}else{
			$AllOutput.AppendText("Dump of All AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListAll = Get-ADUser -Filter * | Select-Object GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName |Sort-Object GivenName,Surname | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListAll)
			}else{
				$AllOutput.AppendText($ADUserListAll)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Dump of Disabled AD Users
	Function Req8DumpDisabledADUsers{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Dump of All Disabled AD Users:")
		}else{
			$AllOutput.AppendText("Dump of All Disabled AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListDisabled = Get-ADUser -Filter * | Where-Object Enabled -eq "False" | Select-Object GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName |Sort-Object GivenName,Surname | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListDisabled)
			}else{
				$AllOutput.AppendText($ADUserListDisabled)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Dump of Inactive AD Users
	Function Req8DumpInactiveADUsers{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Dump of All Inactive AD Users:")
		}else{
			$AllOutput.AppendText("Dump of All Inactive AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListInactiveADUsers = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90 | ?{$_.enabled -eq $True} | Select-Object Name,SamAccountName,UserPrincipalName,DistinguishedName,LastLogonDate |Sort-Object Name | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListInactiveADUsers)
			}else{
				$AllOutput.AppendText($ADUserListInactiveADUsers)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Grab Current User
	Function Req8GrabCurrentUser{
		# Data Output
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Current Logged-In User:`n")
			$Req8Output.AppendText("Username: " + $env:UserName + "`nDomain: " + $env:UserDomain + "`nComputer: " + $env:ComputerName)
		}else{
			$AllOutput.AppendText("Current Logged-In User:`n")
			$AllOutput.AppendText("Username: " + $env:UserName + "`nDomain: " + $env:UserDomain + "`nComputer: " + $env:ComputerName)
		}
	}

	#Grab Local Administrator Accounts
	Function Req8GrabLocalAdmins{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Grab Local Administrators:`n")
		}else{
			$AllOutput.AppendText("Grab Local Administrators:`n")
		}
		# Data Gathering
		try{
			$LocalAdminList = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($LocalAdminList)
			}else{
				$AllOutput.AppendText($LocalAdminList)
			}
		# Edge Case (1)
		}catch [Microsoft.PowerShell.Commands.GroupNotFoundException]{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Something went wrong. There are no Local Administrator Accounts.")
			}else{
				$AllOutput.AppendText("`nError, Something went wrong. There are no Local Administrator Accounts.")
			}
		# Edge Case (2)
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Something Unexpected went wrong.")
			}else{
				$AllOutput.AppendText("`nError, Something Unexpected went wrong.")
			}
		}
	}

	#Grab Domain Administrator Accounts
	Function Req8GrabDomainAdmins{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Grab Domain & Enterprise Administrators:`n")
		}else{
			$AllOutput.AppendText("Grab Domain & Enterprise Administrators:`n")
		}
		# Data Gathering
		try{
			$ADDomainAdminList = Get-ADGroupMember -Identity "Domain Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			$ADEnterpriseAdminList = Get-ADGroupMember -Identity "Enterprise Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("Domain Admins:`n" + $ADDomainAdminList)
				$Req8Output.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminList)
			}else{
				$AllOutput.AppendText("Domain Admins:`n" + $ADDomainAdminList)
				$AllOutput.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminList)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Dump of Users whose Password Never Expire
	Function Req8DumpADUsersPasswordExpiry{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Dump of Users whose Password Never Expires:`n")
		}else{
			$AllOutput.AppendText("Dump of Users whose Password Never Expires:`n")
		}
		# Data Gathering
		try{
			$ADUserPasswordExpiryList = Search-ADAccount -PasswordNeverExpires -UsersOnly | Select-Object Name, SamAccountName, DistinguishedName, PasswordNeverExpires | Format-Table -AutoSize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserPasswordExpiryList)
			}else{
				$AllOutput.AppendText($ADUserPasswordExpiryList)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Dump of Users and Their Last Password Change
	Function Req8DumpADUserLastPassChange{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Dump of All AD Users and Their Last Password Change:`n")
		}else{
			$AllOutput.AppendText("Dump of All AD Users and Their Last Password Change:`n")
		}
		# Data Gathering
		try{
			$ADUserPasswordLastChangeList = Get-aduser -filter * -properties PasswordLastSet, PasswordNeverExpires | Select-Object Name, SamAccountName, DistinguishedName, PasswordLastSet, PasswordNeverExpires | Sort-Object PasswordLastSet,PasswordNeverExpires | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserPasswordLastChangeList)
			}else{
				$AllOutput.AppendText($ADUserPasswordLastChangeList)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nError, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	#Grab the Screensaver Settings
	Function Req8GrabScreensaverSettings{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("Grab of Screensaver Settings:`n")
		}else{
			$AllOutput.AppendText("Grab of Screensaver Settings:`n")
		}
		# Data Gathering
		try{
			$ScreensaverSettings = Get-Wmiobject win32_desktop | Where-Object Name -match $env:USERNAME | Format-Table -Autosize | Out-String -Width 1200
			# Data Output
			if($EverythingToggle -eq $false){
			 $Req8Output.AppendText($ScreensaverSettings)
			}else{
				$AllOutput.AppendText($ScreensaverSettings)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
			 $Req8Output.AppendText("`nError, Screensaver Settings not found.")
			}else{
				$AllOutput.AppendText("`nError, Screensaver Settings not found.")
			}
		}	
	}

	#Grab RDP Encryption and Idle Settings
	Function Req8GrabRDPSettings{
		# Write Header
		if($EverythingToggle -eq $false){
		 $Req8Output.AppendText("Grab RDP Encryption and Idle Settings:")
		}else{
			$AllOutput.AppendText("Grab RDP Encryption and Idle Settings:")
		}
		# Data Gathering - RDP Settings
		try{
			$RDPSettings = Get-WmiObject -Class 'Win32_TSGeneralSetting' -Namespace 'root/CIMV2/TerminalServices' | Select-Object PSComputerName,TerminalName,TerminalProtocol,Certifcates,CertificateName,MinEncryptionLevel,PolicySourceMinEncryptionLevel,PolicySourceSecurityLayer,SecurityLayer | Format-List | Out-String
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($RDPSettings)
			}else{
				$AllOutput.AppendText($RDPSettings)
			}
		# Edge Case - RDP Settings
		}catch{
			$Req8Output.AppendText("Error - No RDP Settings Found")
		}
		# Data Gathering - PowerPlans
		try{
			# Write Header
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("Power Plans:`n")
			}else{
				$AllOutput.AppendText("Power Plans:`n")
			}
			#
			$PowerPlanSettings = Get-WmiObject -Namespace root\cimv2\power -Class win32_PowerPlan -ErrorAction Stop | Select-Object -Property ElementName, IsActive | Format-Table -Autosize | Out-String -Width 1200 
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($PowerPlanSettings)
			}else{
				$AllOutput.AppendText($PowerPlanSettings)
			}
		# Edge Case
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
				$Req8Output.AppendText($Global:SectionHeader)
				Req8LocalPasswordPolicy
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpActiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpDisabledADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpInactiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabCurrentUser
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabLocalAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabDomainAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpADUsersPasswordExpiry
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpADUserLastPassChange
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabScreensaverSettings
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabRDPSettings
				$Req8Output.AppendText($Global:SectionHeader)
				Req8CheckForMFA
				$Req8Output.AppendText($Global:SectionHeader)
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
		$Req10Output.AppendText($Global:SectionHeader)
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
			$Req10Output.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$Req10Output.AppendText($Global:SectionHeader)
			Req10NTPSettingsMultipleDevices
			$Req10Output.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$Req10Output.AppendText($Global:SectionHeader)
			Req10PastAuditLogs
			$Req10Output.AppendText($Global:SectionHeader)
		}else{
			$Req10Output.Clear()
			$Req10Output.AppendText("You must select an object from the script list.")
		}
	}

# Diagnostics Tab
	#Grab System Information
	Function DiagSysInfo{
		$DiagOutput.AppendText("Grab System Information`n")
		try{
			$SystemInfoData = systeminfo | Out-String
			$DiagOutput.AppendText($SystemInfoData)
		}catch{
			$DiagOutput.AppendText("Unable to Grab System Infomation`n")
		}
	}

	#Grab Installed Software Patches
	Function DiagInstalledUpdates {
		$DiagOutput.AppendText("Grab Installed Software Patches`n")
		try{
			$UpdateData = Get-HotFix | Out-String
			$DiagOutput.AppendText($UpdateData)
		}catch{
			$DiagOutput.AppendText("Unable to Grab Installed Software Patches`n")
		}
	}

	#Grab IP Config
	Function DiagIPConfig {
		$DiagOutput.AppendText("Grab IP Config`n")
		try{
			$IPConfigData = ipconfig /all | Out-String 
			$DiagOutput.AppendText($IPConfigData)
		}catch{
			$DiagOutput.AppendText("Unable to Grab IP Config`n")
		}
	}

	#Check TCP Connectivity
	Function DiagTCPConnectivity {
		$DiagOutput.AppendText("Check TCP Connectivity`nThis may take awhile.`n`n")
		try{
			$PingTest = ping "www.google.com" | Out-String
			$TraceRouteTest = tracert "www.google.com" | Out-String
			$DiagOutput.AppendText("Ping & Trace Route to www.google.com `n" + $PingTest + "`n" + $TraceRouteTest)
		}catch{
			$DiagOutput.AppendText("Unable to Check TCP Connectivity`n")
		}
	}

	#Dedicated GPO Dump
	Function DiagGPODump {
		$DiagOutput.AppendText("GPO Dump")
		$DiagOutput.AppendText($global:GPODump)
	}

	#onClick Event Handler
	$DiagScriptList_ListUpdate = {
		if($DiagScriptList.SelectedItem -eq "Grab System Information"){
			$DiagOutput.Clear()
			DiagSysInfo
		}elseif($DiagScriptList.SelectedItem -eq "Grab Installed Software Patches"){
			$DiagOutput.Clear()
			DiagInstalledUpdates
		}elseif($DiagScriptList.SelectedItem -eq "Grab IP Config"){
			$DiagOutput.Clear()
			DiagIPConfig
		}elseif($DiagScriptList.SelectedItem -eq "Check TCP Connectivity"){
			$DiagOutput.Clear()
			DiagTCPConnectivity
		}elseif($DiagScriptList.SelectedItem -eq "GPO Dump"){
			$DiagOutput.Clear()
			DiagGPODump
		}elseif($DiagScriptList.SelectedItem -eq "Everything in Diagnostics"){
			$DiagOutput.Clear()
			$DiagOutput.AppendText("Everything in Diagnostics`n")
			DiagSysInfo
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagInstalledUpdates
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagIPConfig
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagTCPConnectivity
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagGPODump
			$DiagOutput.AppendText($Global:SectionHeader)
		}else{
			$DiagOutput.Clear()
			$DiagOutput.AppendText("You must select an object from the script list.")
		}
	}

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')