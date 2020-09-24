# Anordium Audits #
# Add Required Dot Net Assemblies
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing, System.DirectoryServices.AccountManagement

#Join Path for CSS Code in the Report, Required for HTML Exporting
. (Join-Path $PSScriptRoot 'CSSReport.ps1')

# Check Script Rights & Ensure is in Administrator Mode
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  exit
}

# Check for Dot Net Framework Version and Print to Console
	$NetFrameworkReleaseKey = (Get-ItemProperty "HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full").Release
	# Data Gathering
	if($NetFrameworkReleaseKey -ge 528040){
		$DotNetVersion = "4.8 or later"
		$DotNetCorrect = $true
	}elseif($NetFrameworkReleaseKey -ge 461808){
		$DotNetVersion = "4.7.2"
		$DotNetCorrect = $true
	}elseif($NetFrameworkReleaseKey -ge 461308){
		$DotNetVersion = "4.7.1"
		$DotNetCorrect = $true
	}elseif($NetFrameworkReleaseKey -ge 460798){
		$DotNetVersion = "4.7"
		$DotNetCorrect = $true
	}elseif($NetFrameworkReleaseKey -ge 394802){
		$DotNetVersion = "4.6.2"
		$DotNetCorrect = $true
	}elseif($NetFrameworkReleaseKey -ge 394254){
		$DotNetVersion = "4.6.1"
		$DotNetCorrect = $false
	}elseif($NetFrameworkReleaseKey -ge 393295){
		$DotNetVersion = "4.6"
		$DotNetCorrect = $false
	}elseif($NetFrameworkReleaseKey -ge 379893){
		$DotNetVersion = "4.5.2"
		$DotNetCorrect = $false
	}elseif($NetFrameworkReleaseKey -ge 378675){
		$DotNetVersion = "4.5.1"
		$DotNetCorrect = $false
	}elseif($NetFrameworkReleaseKey -ge 378389){
		$DotNetVersion = "4.5"
		$DotNetCorrect = $false
	}else{
		$DotNetVersion = "N/A - Dot Net Framework 4.5 or later not detected. Please Install Dot Net Framework 4.6.2 or Later."
		$DotNetCorrect = $false
	}
	# Print Dot Net Framework Version to Console
	Write-Host "Detected Dot Net Framework: $DotNetVersion"
	if($DotNetVersion -eq $false){
		Write-Host "Dot Net Framework Not Supported. Please Install Dot Net Framework 4.6.2 or Later."
	}else{
		Write-Host "Dot Net Framework Supported."
	}

# Global GPO Result Function. Gather GPO Data
Function GPResults{
	$Global:GPODump = gpresult.exe /SCOPE COMPUTER /Z | Format-Table -Autosize | Out-String -Width 1200
	$Global:GPODumpHTML = "<h2>GPO Dump</h2><pre>"+$Global:GPODump+"</pre>"
	# Edge Case
	if([string]::IsNullOrEmpty($global:GPODump)){
		$Global:GPODump = "`nAn error occurred.`nUnable to query GPO."
		$Global:GPODumpHTML = "<h2>GPO Dump</h2><p>An error occurred.<br>Unable to query GPO.</p>"
	}
	# Dedicated HTML GPO Report Export
	try{
		$Global:GPOExportPathLocation =  $Global:ExportPathLocation + "\GPO-Report.html"
		gpresult.exe /SCOPE COMPUTER /f /h $Global:GPOExportPathLocation
		$AllOutput.AppendText("GPO Report Exported to: " + $Global:ExportPathLocation + "\GPO-Report.html")
		$Global:GPOExportReportStatus = $true
	}catch{
		$Global:GPOExportReportStatus = $false
	}
}

# Menu Navigation
# Submit Button on Main Form
$WelcomeSubmitButton_Click = {
	# Clear Output
	$MainForm.MainFormOutput.Clear()
	# Form Navigation
	$MainFormXYLoc = $MainForm.Location
	$AuxiliaryForm.Location = $MainFormXYLoc
	# Check User Input
	$UserInputPath = $MainForm.MainUserInput.Text
	try{
		$UserInputTestingPath = Test-Path -Path $UserInputPath
		if($UserInputTestingPath -eq $true){
			if([string]::IsNullOrEmpty($Global:FilePathExportPopup)){
				$FinalExportPath = $UserInputPath.Trimend("\")
			}else{
				$FinalExportPath = $Global:FilePathExportPopup.Trimend("\")
			}
			$MainForm.MainFormOutput.AppendText("Vaild folder selected. Continuing...`n" + $FinalExportPath)
			$Global:ExportPathLocation = $FinalExportPath
			$MainForm.MainFormOutput.AppendText("`n`nGathering Information from GPO. Please Standby.")
			GPResults
			# Edge Case Incorrect Dot Net Framework
			if($DotNetCorrect -eq $true){
				$MainForm.Hide()
				$AuxiliaryForm.ShowDialog()
			}else{
					$MainForm.MainFormOutput.AppendText("`n`nERROR - Unsupported Dot Net Framework Detected.`n Please Install Dot Net Framework 4.6.2 or Greater.")
			}
		}else{
			$MainForm.MainFormOutput.Clear()
			$MainForm.MainFormOutput.AppendText("Invalid Folder Location.`n")
		}
	}catch{
		$MainForm.MainFormOutput.Clear()
		$MainForm.MainFormOutput.AppendText("Folder not selected. Invalid Location.`n")
	}
}
# Back Button from Auxiliary Form
$AuxiliaryBack_Click = {
	$AuxiliaryForm.Hide()
	$AuxiliaryFormXYLoc = $AuxiliaryForm.Location
	$MainForm.Location = $AuxiliaryFormXYLoc
	$Global:FilePathExportPopup = $null
	$MainForm.MainUserInput.Clear()
	$MainForm.MainFormOutput.Clear()
	$AuxiliaryForm.AllOutput.Clear()
	$AllOutput.Clear()
	$Req2Output.Clear()
	$Req4Output.Clear()
	$Req5Output.Clear()
	$Req7Output.Clear()
	$Req8Output.Clear()
	$Req10Output.Clear()
	$DiagOutput.Clear()
	$MainForm.Show()
}
# Credits Button on Main Form
$CreditsButton = {
	$MainFormOutput.Clear()
	$MainFormOutput.AppendText("BDT Industry Project Q3-Q4 2020`n")
	$MainFormOutput.AppendText("This was made by Team Anordium Securities and is composed of;`n`n")
	$MainFormOutput.AppendText("`nMatthew Westlake - west356@manukaumail.com`nMicheal Chen - Email: anordium@chencorp.co.nz`nRahnuma Khan`nRyan Alpay - Email: ryanmatthew.alpay@mail.com`nTim Sun - Email: timsun90@gmail.com`n")
	$MainFormOutput.AppendText("`nAnordium Securities Version " + $Global:ProgramVersionCode + " - " + $Global:ProgramVersionDate +"`n")
	$MainFormOutput.AppendText("`n`nSpecial Thanks to Dan from Adam the Automator for the CSS table design.")
	$MainFormOutput.AppendText("`n`nhttps://adamtheautomator.com/powershell-convertto-html/")
}

# Browse Button on Main Form
$UserInputBrowse = {
	$MainForm.MainUserInput.Clear()
	$UserBrowsePopup = $MainForm.MainExportFolderBrowse.ShowDialog()
	if($UserBrowsePopup -eq "OK"){    
		$Global:FilePathExportPopup = $MainExportFolderBrowse.SelectedPath
		$MainForm.MainUserInput.Clear()
		$MainForm.MainFormOutput.Clear()
		$MainForm.MainUserInput.AppendText($Global:FilePathExportPopup)
		$MainForm.MainFormOutput.AppendText("Export Folder Path Selected: " + $Global:FilePathExportPopup)
	}else{
		$MainForm.MainUserInput.Clear()
		$MainForm.MainFormOutput.Clear()
		$MainForm.MainFormOutput.AppendText("Folder not selected. Invalid Location.")
	}
}

# Everything Tab # 
# Initialize Switch & Headers
$EverythingToggle = $false
$Global:SectionHeader = "`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n"
$Global:SectionBreak = "`n`n---------------------------------------------------------------------------------------------------------`n`n"
$Global:ProgramVersionCode = "1.1.0"
$Global:ProgramVersionDate = "18th September 2020"

$AllScriptList_ListUpdate = {
	if($AllScriptList.SelectedItem -eq "Everything"){
		$AllOutput.Clear()
		$EverythingToggle = $true
		# Getting Ready
			$AllOutput.AppendText("Gathering Infomation for Everything.`nBe patient and do not tab away. This may take awhile. `n")
			$AllOutput.AppendText($Global:SectionBreak)
		#Call Requirement Two Functions
			$AllOutput.AppendText("Everything in Requirement Two `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Two... Total Progress... 0%"
			$AllScriptOutputLabel.Refresh()
			Req2TestDefaultAccounts
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningProcesses
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningServices
			$AllOutput.AppendText($Global:SectionHeader)
			Req2ListeningServices
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Two... Total Progress... 10%"
			$AllScriptOutputLabel.Refresh()
			Req2GrabInstalledSoftware		
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabDrivesAndShares
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabADComputers
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Two... Total Progress... 15%"
			$AllScriptOutputLabel.Refresh()
			Req2MapNeighboringDevices
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Four Functions
			$AllOutput.AppendText("Everything in Requirement Four `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Four... Total Progress... 20%"
			$AllScriptOutputLabel.Refresh()
			Req4WifiScan
			$AllOutput.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Five Functions
			$AllOutput.AppendText("Everything in Requirement Five `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Five... Total Progress... 30%"
			$AllScriptOutputLabel.Refresh()
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Seven Functions
			$AllOutput.AppendText("Everything in Requirement Seven `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Seven... Waiting for User Input. Total Progress... 40%"
			$AllScriptOutputLabel.Refresh()
			# Alert User for Input
			Req7FolderInput
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Seven... Total Progress... 45%"
			$AllScriptOutputLabel.Refresh()
			Req7FolderPerms
			$AllOutput.AppendText($Global:SectionHeader)
			Req7DenyAll
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Seven... Total Progress... 50%"
			$AllScriptOutputLabel.Refresh()
			Req7UserPriviledges
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Eight Functions
			$AllOutput.AppendText("Everything in Requirement Eight `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Eight... Total Progress... 55%"
			$AllScriptOutputLabel.Refresh()
			Req8GrabCurrentUser
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabDomainAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabLocalAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpActiveADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpDisabledADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpInactiveADUsers
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Eight... Total Progress... 60%"
			$AllScriptOutputLabel.Refresh()
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabScreensaverSettings
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DomainPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8LocalPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUsersPasswordExpiry
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUserLastPassChange
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Eight... Total Progress... 70%"
			$AllScriptOutputLabel.Refresh()
			Req8GrabRDPSettings
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Ten Functions
			$AllOutput.AppendText("Everything in Requirement Ten `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Ten... Total Progress... 75%"
			$AllScriptOutputLabel.Refresh()
			Req10AuditSettings
			$AllOutput.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Ten... Grabbing NTP Settings on Multiple Devices, This Will Take Awhile. Total Progress... 80%"
			$AllScriptOutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$AllOutput.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Ten... Gathering Past Audit Logs, This Will Take Awhile. Total Progress... 85%"
			$AllScriptOutputLabel.Refresh()
			Req10PastAuditLogs
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Diagnosis Functions
			$AllOutput.AppendText("Everything in Diagnostics`n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Diagnosis... Total Progress... 90%"
			$AllScriptOutputLabel.Refresh()
			DiagSysInfo
			$AllOutput.AppendText($Global:SectionHeader)
			DiagInstalledUpdates
			$AllOutput.AppendText($Global:SectionHeader)
			DiagIPConfig
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Diagnosis... Total Progress... 95%"
			$AllScriptOutputLabel.Refresh()
			$AllOutput.AppendText($Global:SectionHeader)
			DiagTCPConnectivity
			$AllOutput.AppendText($Global:SectionHeader)
			DiagGPODump
			$AllOutput.AppendText($Global:SectionBreak)
			$AllScriptOutputLabel.Text = "Output:"
			$AllScriptOutputLabel.Refresh()
		# Print End of Script Stuff
			$AllOutput.AppendText("Script Completed Successfully.`n")
			# Message Box Popup
			$EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Script Completed Successfully","Script Completed Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)	
	}else{
		$AllOutput.Clear()
		$AllOutput.AppendText("You must select an object from the script list.")
	}
}

	# All Requirements Report Export
	# Build Report Function
	Function AllExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$ReportAllName = "<h1 class='TopRequirementHeader'>All PCI-DSS Requirements Report</h1>"
		$Global:ReportRequirementTwoName = "<h1 id='RequirementHeader'>PCI DSS Requirement Two</h1>"
		$Global:ReportRequirementFourName = "<h1 id='RequirementHeader'>PCI DSS Requirement Four</h1>"
		$Global:ReportRequirementFiveName = "<h1 id='RequirementHeader'>PCI DSS Requirement Five</h1>"
		$Global:ReportRequirementSevenName = "<h1 id='RequirementHeader'>PCI DSS Requirement Seven</h1>"
		$Global:ReportRequirementEightName = "<h1 id='RequirementHeader'>PCI DSS Requirement Eight</h1>"
		$Global:ReportRequirementTenName = "<h1 id='RequirementHeader'>PCI DSS Requirement Ten</h1>"
		$Global:ReportDiagRequirementName = "<h1 id='RequirementHeader'>PCI DSS Diagnostics Report</h1>"
		$RequirementAllReport = ConvertTo-HTML -Body "$ReportAllName $ReportComputerName $Global:ReportRequirementTwoName $Global:Req2UserCredentialResult $Global:Req2FeatureListHTML $Global:Req2ProcessListHTML $Global:Req2SvcListRunningHTML $Global:Req2SvcListListeningHTML $Global:Req2UDPListHTML $Global:Req2SoftwareListHTML $Global:Req2LocalDrivesHTML $Global:Req2LocalDrivesExtraHTML $Global:Req2LocalNetworkSharesHTML $Global:Req2ADComputerListAll $Global:Req2IPV4AdaptersHTML $Global:Req2IPV4NeighborsHTML $Global:Req2IPV6AdaptersHTML $Global:Req2IPV6NeighborsHTML $Global:ReportRequirementFourName $Global:Req4WifiListHTML $Global:Req4LocalMachineCertsHTML $Global:Req4CurrentUserCertsHTML $Global:ReportRequirementFiveName $Global:Req5AVProgramQueryHTML $Global:Req5SoftwareDeploymentHTML $Global:Req5AVPermsHTML $Global:ReportRequirementSevenName $Global:Req7LocalFolderPermsHTML $Global:Req7SambaShareStatusHTML $Global:Req7FolderPermsHTML $Global:Req7GroupMembershipListHTML $Global:ReportRequirementEightName $Global:Req8CurrentUserHTML $Global:Req8LocalAdminListHTML $Global:Req8ADDomainAdminListHTML $Global:Req8ADEnterpriseAdminListHTML $Global:Req8ADUserListAllHTML $Global:Req8ADUserListDisabledHTML $Global:Req8ADUserListInactiveADUsersHTML $Global:Req8ScreensaverSettingsHTML $Global:Req8CurrentDomainPoliciesHTML $Global:Req8LocalPolicyHTML $Global:Req8ADUserPasswordExpiryListHTML $Global:Req8RDPSettingsHTML $Global:Req8PowerPlanSettingsHTML $Global:ReportRequirementTenName $Global:Req10AuditListHTML $Global:Req10NTPSettings $Global:Req10NTPSettingsAllDevices $Global:Req10ADDomainAdminListHTML $Global:Req10ADEnterpriseAdminListHTML $Global:Req10AllAuditLogs $Global:ReportDiagRequirementName $Global:DiagSystemInfoDataHTML $Global:DiagInstalledUpdatesDataHTML $Global:DiagIPConfigHTML $Global:DiagPingTestHTML $Global:DiagTraceRouteHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS All Requirements Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$RequirementAllReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html"
		$RequirementAllReport | Out-File $RequirementAllReportPath
		$AllOutput.AppendText("`nAll PCI-DSS Requirements Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html")
		$AllOutput.AppendText("`nRequirement Ten Audit Logs Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Audit-Logs.txt")
		# Audit Logs Text File
		$AllAuditLogs = "Grabbing Previous Audit Logs for the Past Three Months.`n" + $Global:AuditLogs 
		$Requirement10ReportPathLogs = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Audit-Logs.txt"
		$AllAuditLogs | Out-File $Requirement10ReportPathLogs
		# Alert User
		$Req10EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("All PCI-DSS Requirements Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html`n`nRequirement Ten Audit Logs Exported to: " + $Requirement10ReportPathLogs,"All PCI-DSS Requirements Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$AllExportReport = {
			$AllOutput.Clear()
			$AllOutput.AppendText("Writing Report for the Following`n`nBe patient and do not tab away. This may take awhile.")
			$EverythingToggle = $true
			$AllOutput.AppendText($Global:SectionBreak)
		#Call Requirement Two Functions
			$AllOutput.AppendText("Everything in Requirement Two `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Two... Total Progress... 0%"
			$AllScriptOutputLabel.Refresh()
			Req2TestDefaultAccounts
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningProcesses
			$AllOutput.AppendText($Global:SectionHeader)
			Req2RunningServices
			$AllOutput.AppendText($Global:SectionHeader)
			Req2ListeningServices
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Two... Total Progress... 10%"
			$AllScriptOutputLabel.Refresh()
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabInstalledSoftware
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabDrivesAndShares
			$AllOutput.AppendText($Global:SectionHeader)
			Req2GrabADComputers
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Two... Total Progress... 15%"
			$AllScriptOutputLabel.Refresh()
			Req2MapNeighboringDevices
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Four Functions
			$AllOutput.AppendText("Everything in Requirement Four `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Four... Total Progress... 20%"
			$AllScriptOutputLabel.Refresh()
			Req4WifiScan
			$AllOutput.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Five Functions
			$AllOutput.AppendText("Everything in Requirement Five `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Five... Total Progress... 30%"
			$AllScriptOutputLabel.Refresh()
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Seven Functions
			$AllOutput.AppendText("Everything in Requirement Seven `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Waiting for User Input for Requirement Seven... Total Progress... 40%"
			$AllScriptOutputLabel.Refresh()
			Req7FolderInput
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Seven... Total Progress... 45%"
			$AllScriptOutputLabel.Refresh()
			Req7FolderPerms
			$AllOutput.AppendText($Global:SectionHeader)
			Req7DenyAll
			$AllOutput.AppendText($Global:SectionHeader)
			Req7UserPriviledges
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Eight Functions
			$AllOutput.AppendText("Everything in Requirement Eight `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Eight... Total Progress... 50%"
			$AllScriptOutputLabel.Refresh()
			Req8GrabCurrentUser
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabDomainAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8GrabLocalAdmins
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpActiveADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpDisabledADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpInactiveADUsers
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Eight... Total Progress... 60%"
			$AllScriptOutputLabel.Refresh()
			Req8GrabScreensaverSettings
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DomainPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8LocalPasswordPolicy
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUsersPasswordExpiry
			$AllOutput.AppendText($Global:SectionHeader)
			Req8DumpADUserLastPassChange
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Eight... Total Progress... 70%"
			$AllScriptOutputLabel.Refresh()
			Req8GrabRDPSettings
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Ten Functions
			$AllOutput.AppendText("Everything in Requirement Ten `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Ten... Total Progress... 75%"
			$AllScriptOutputLabel.Refresh()
			Req10AuditSettings
			$AllOutput.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Ten, Grabbing NTP Settings on Multiple Devices, This Will Take Awhile.... Total Progress... 80%"
			$AllScriptOutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$AllOutput.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Ten, Grabbing Past Audit Logs, This Will Take Awhile... Total Progress... 85%"
			$AllScriptOutputLabel.Refresh()
			Req10PastAuditLogs
			$AllOutput.AppendText($Global:SectionBreak)
		# Call Requirement Diagnosis Functions
			$AllOutput.AppendText("Everything in Diagnostics`n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Diagnosis... Total Progress... 90%"
			$AllScriptOutputLabel.Refresh()
			DiagSysInfo
			$AllOutput.AppendText($Global:SectionHeader)
			DiagInstalledUpdates
			$AllOutput.AppendText($Global:SectionHeader)
			DiagIPConfig
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Diagnosis... Total Progress... 95%"
			$AllScriptOutputLabel.Refresh()
			DiagTCPConnectivity
			$AllOutput.AppendText($Global:SectionHeader)
			DiagGPODump
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Diagnosis... Total Progress... 99%"
			$AllScriptOutputLabel.Refresh()
			AllExportReportFunction
			$AllScriptOutputLabel.Text = "Output:"
			$AllScriptOutputLabel.Refresh()
	}

# Requirement Two Tab #
	# 2.1 - Test Vendor Default Credentials in AD
	Function Req2TestDefaultAccounts {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.1 - Test Vendor Default Credentials in AD.`n`n")
		}else{
			$AllOutput.AppendText("2.1 - Test Vendor Default Credentials in AD.`n`n")
		}
		# Usernames and Password Arrays 
		$UsernameToTest = @("LDAP_Anonymous","","Administrator","Administrator","Guest","Guest","IS_$Env:COMPUTERNAME","User","free user","Mail")
		$PasswordToTest = @("LdapPassword_1","","Administrator","","Guest","","IS_$Env:COMPUTERNAME","User","user","")
		$MaxLength = [Math]::Max($UsernameToTest.Length, $PasswordToTest.Length)
		$ResultTable = @()
		# Data Gathering
		for ($loop_index = 0; $loop_index -lt $MaxLength; $loop_index++){ 
			$DS = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('Domain')
			$DSResult = $DS.ValidateCredentials($UsernameToTest[$loop_index],$PasswordToTest[$loop_index])
			# Check Boolean Switch, Check if Password is vaild
			if($DSResult -eq $true){
				$ResultTable += @{Username=$UsernameToTest[$loop_index];Password=$PasswordToTest[$loop_index];Result="Succesful"}
				# Data Output
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("Tested Username: '" + $UsernameToTest[$loop_index] + "' with Password: '" + $PasswordToTest[$loop_index] + "' - Login was SUCCESSFUL. PLEASE CHANGE OR DISABLE ACCOUNT`n`n")
				}else{
					$AllOutput.AppendText("Tested Username: '" + $UsernameToTest[$loop_index] + "' with Password: '" + $PasswordToTest[$loop_index] + "' - Login was SUCCESSFUL. PLEASE CHANGE OR DISABLE ACCOUNT`n`n")
				}
			# Check Boolean Switch, Password is not vaild.
			}else{
				$ResultTable += @{Username=$UsernameToTest[$loop_index];Password=$PasswordToTest[$loop_index];Result="Unsuccesful"}
				# Data Output
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("Tested Username: '" + $UsernameToTest[$loop_index] + "' with Password: '" + $PasswordToTest[$loop_index] + "' - Login was UNSUCCESSFUL.`n`n")
				}else{
					$AllOutput.AppendText("Tested Username: '" + $UsernameToTest[$loop_index] + "' with Password: '" + $PasswordToTest[$loop_index] + "' - Login was UNSUCCESSFUL.`n`n")
				}
			}
		}
		# Create HTML
        $CovertedTable = $ResultTable | ForEach {[PSCustomObject]$_}
		$CovertedTable | Sort-Object Username,Result
		$Global:Req2UserCredentialResult = $CovertedTable | ConvertTo-Html -As Table -Fragment -Property Username,Password,Result -PreContent "<h2>2.1 - Test Vendor Default Credentials in AD</h2>"
		$Global:Req2UserCredentialResult = $Global:Req2UserCredentialResult -replace '<td>Unsuccesful</td>','<td class="InstalledStatus">Unsuccesful</td>'
		$Global:Req2UserCredentialResult = $Global:Req2UserCredentialResult -replace '<td>Succesful</td>','<td class="RemovedStatus">Succesful</td>'
	}

	# 2.2.1 Grab Installed Features
	Function Req2GrabInstalledFeatures{
		# Data Gathering
		try{
			$Req2FeatureList = Get-WindowsFeature | Where-Object InstallState -EQ Installed | Format-Table -Autosize | Out-String -Width 1200
			# HTML Report and Adding Colour Classes to Table Output
			$Global:Req2FeatureListHTML = Get-WindowsFeature | Where-Object InstallState -EQ Installed | ConvertTo-Html -As Table -Property DisplayName,Name,InstallState,FeatureType -Fragment -PreContent "<h2>2.2.1 - List of Installed Windows Features</h2>"
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Available</td>','<td class="AvailableStatus">Available</td>' 
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Installed</td>','<td class="InstalledStatus">Installed</td>'
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Removed</td>','<td class="RemovedStatus">Removed</td>'
		# Edge Case
		}catch{
			$Req2FeatureList = "Unable to Grab Installed Features."
			$Global:Req2FeatureListHTML = "<h2>2.2.1 - List of Installed Windows Features</h2><p>Unable to Grab Installed Features.</p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.1 - List of Installed Windows Features:`n")
			$Req2Output.AppendText($Req2FeatureList)
		}else{
			$AllOutput.AppendText("2.2.1 - List of Installed Windows Features:`n")
			$AllOutput.AppendText($Req2FeatureList)
		}
	}

	# 2.2.2 - List of Runnning Processes
	Function Req2RunningProcesses{
		# Data Gathering
		try{
			$Req2ProcessList = Get-Process | Select-Object name, Path | Sort-Object name
			$Req2ProcessListRTB = $Req2ProcessList  | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2ProcessListHTML = Get-Process | ConvertTo-Html -As Table -Property Name,Id,ProductVersion,Company,StartTime,Path -Fragment -PreContent "<h2>2.2.2 - List of Running Processes</h2>" 
		# Edge Case
		}catch{
			$Req2ProcessListRTB = "Unable to List Running Processes."
			$Global:Req2ProcessListHTML = "<h2>2.2.2 - List of Running Processes</h2><p>Unable to List Running Processes.<p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - List of Running Processes:`n")
			$Req2Output.AppendText($Req2ProcessListRTB)
		}else{
			$AllOutput.AppendText("2.2.2 - List of Running Processes:`n")
			$AllOutput.AppendText($Req2ProcessListRTB)
		}
	}

	# 2.2.2 - List of Running Services
	Function Req2RunningServices{
		# Data Gathering
		try{
			$Req2SvcListRunning = Get-Service | Where-Object Status -eq "Running" | Sort-Object Name 
			$Req2SvcListRunningRTB = $Req2SvcListRunning | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SvcListRunningHTML = $Req2SvcListRunning | ConvertTo-Html -As Table -Property Status,Name,DisplayName -Fragment -PreContent "<h2>2.2.2 - List of Running Services</h2>"
		# Edge Case
		}catch{
			$Req2SvcListRunningRTB = "Unable to List Running Serivces."
			$Global:Req2SvcListRunningHTML = "<h2>2.2.2 - List of Running Services</h2><p>Unable to List Running Serivces.</p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - List of Running Services:`n")
			$Req2Output.AppendText($Req2SvcListRunningRTB)
		}else{
			$AllOutput.AppendText("2.2.2 - List of Running Services:`n")
			$AllOutput.AppendText($Req2SvcListRunningRTB)
		}
	}

	# 2.2.2 - Established Network Connections
	Function Req2ListeningServices{
		# Data Gathering
		try{
			$Req2SvcListListening = Get-NetTCPConnection | Where-Object State -eq "Established" | Sort-Object LocalPort,LocalAddress 
			$Req2UDPList = Get-NetUDPEndpoint | Sort-Object LocalPort,LocalAddress
			$Req2SvcListListeningRTB = $Req2SvcListListening | Format-Table -Autosize | Out-String -Width 1200
			$Req2UDPListRTB = $Req2UDPList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SvcListListeningHTML = $Req2SvcListListening | ConvertTo-Html -As Table -Property LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess -Fragment -PreContent "<h2>2.2.2 - Established Network Connections</h2><h3>TCP Connections</h3>"
			$Global:Req2UDPListHTML = $Req2UDPList | ConvertTo-Html -As Table -Property LocalAddress,LocalPort -Fragment -PreContent "<h3>UDP Connections</h3>"
		# Edge Case
		}catch{
			$Req2SvcListListeningRTB = "Unable to Grab Established Network Connections."
			$Global:Req2SvcListListeningHTML = "<h2>2.2.2 - Established Network Connections</h2><p>Unable to Grab Established Network Connections.</p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - Established Network Connections:`nTCP Connections`n")
			$Req2Output.AppendText($Req2SvcListListeningRTB)
			$Req2Output.AppendText("`nUDP Connections`n")
			$Req2Output.AppendText($Req2UDPListRTB)
		}else{
			$AllOutput.AppendText("2.2.2 - Established Network Connections:`n")
			$AllOutput.AppendText($Req2SvcListListeningRTB)
			$AllOutput.AppendText("`nUDP Connections`n")
			$AllOutput.AppendText($Req2UDPListRTB)
		}
	}

	# 2.2.2 - Grab Installed Software
	Function Req2GrabInstalledSoftware{
		# Data Gathering
		try{
			$Req2SoftwareList = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, DisplayVersion, Publisher, InstallDate | Sort-Object DisplayName 
			$Req2SoftwareListRTB = $Req2SoftwareList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SoftwareListHTML = $Req2SoftwareList | ConvertTo-Html -As Table -Property DisplayName, DisplayVersion, Publisher, InstallDate -Fragment -PreContent "<h2>2.2.2 - Grab Installed Software</h2>"
		# Edge Case
		}catch{
			$Req2SoftwareListRTB = "Unable to Grab Installed Software."
			$Global:Req2SoftwareListHTML = "<h2>2.2.2 - Grab Installed Software</h2><p>Unable to Grab Installed Software.</p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - Grab Installed Software:`n")
			$Req2Output.AppendText($Req2SoftwareListRTB)
		}else{
			$AllOutput.AppendText("2.2.2 - Grab Installed Software:`n")
			$AllOutput.AppendText($Req2SoftwareListRTB)
		}
	}

	# 2.2.5 - Grab Local Drives and Network Shares
	Function Req2GrabDrivesAndShares {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.5 - Grab Local Drives and Network Shares:`n")
		}else{
			$AllOutput.AppendText("2.2.5 - Grab Local Drives and Network Shares:`n")
		}
		# Data Gathering
		try{
			# Local Drives
			$LocalDrives = Get-PSDrive -PSProvider FileSystem | Select-Object Name,Used,Free,Root,Description,DisplayRoot
			$LocalDrivesRTB = $LocalDrives | Format-Table | Out-String
			$Global:Req2LocalDrivesHTML = $LocalDrives | ConvertTo-Html -As Table -Fragment -Property Name,Used,Free,Root,Description,DisplayRoot -PreContent "<h2>2.2.5 - Grab Local Drives and Network Shares</h2>"
			# Local Drives Extra
			$LocalDrivesExtra = [System.IO.DriveInfo]::GetDrives() | Select-Object Name,DriveType,DriveFormat,IsReady,VolumeLabel
			$LocalDrivesExtraRTB = $LocalDrivesExtra | Format-Table | Out-String
			$Global:Req2LocalDrivesExtraHTML = $LocalDrivesExtra | ConvertTo-Html -As Table -Fragment -Property Name,DriveType,DriveFormat,IsReady,VolumeLabel -PreContent "<h3>Extra Drive Infomation</h3>"
			# Network Share
			$LocalNetworkShares = Get-SmbShare | Select-Object Name,ScopeName,Path,Description,CurrentUsers,Special
			$LocalNetworkSharesRTB = $LocalNetworkShares | Format-Table | Out-String
			$Global:Req2LocalNetworkSharesHTML = $LocalNetworkShares | ConvertTo-Html -As Table -Fragment -Property Name,ScopeName,Path,Description,CurrentUsers,Special -PreContent "<h3>Network Shares</h3>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($LocalDrivesRTB + "`nExtra Drive Infomation`n" + $LocalDrivesExtraRTB + "`nNetwork Shares`n" + $LocalNetworkSharesRTB)
			}else{
				$AllOutput.AppendText($LocalDrivesRTB + "`nExtra Drive Infomation`n" + $LocalDrivesExtraRTB + "`nNetwork Shares`n" + $LocalNetworkSharesRTB)
			}
		# Edge Case
		}catch{
			$Global:Req2LocalDrivesHTML = "<h2>2.2.5 - Grab Local Drives and Network Shares</h2><p>Error - Could Not Grab Local Drives or Network Shares.</p>"
			$Global:Req2LocalDrivesExtraHTML = ""
			$Global:Req2LocalNetworkSharesHTML = "<h3>Network Shares</h3><p>Error</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("Error - Could Not Grab Local Drives or Network Shares.`n")
			}else{
				$AllOutput.AppendText("Could Not Grab Local Drives or Network Shares.`n")
			}
		}
	}

	# 2.4 - Grab All Computer Objects from Active Directory
	Function Req2GrabADComputers{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.4 - Grab All Computer Objects from Active Directory:`n")
		}else{
			$AllOutput.AppendText("2.4 - Grab All Computer Objects from Active Directory:`n")
		}
		# Data Gathering
		try{
			$ADComputerListAll = Get-ADComputer -Filter * | Select-Object Name, Enabled, DNSHostName, DistinguishedName |Sort-Object Name,Enabled
			$ADComputerListAllRTB = $ADComputerListAll | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2ADComputerListAll = $ADComputerListAll | ConvertTo-Html -As Table -Property Name, Enabled, DNSHostName, DistinguishedName -Fragment -PreContent "<h2>2.4 - Grab All Computer Objects from Active Directory</h2>"
			$Global:Req2ADComputerListAll = $Global:Req2ADComputerListAll -replace '<td>True</td>','<td class="EnabledStatus">True</td>'
			$Global:Req2ADComputerListAll = $Global:Req2ADComputerListAll -replace '<td>False</td>','<td class="DisabledStatus">False</td>'
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($ADComputerListAllRTB)
			}else{
				$AllOutput.AppendText($ADComputerListAllRTB)
			}
		# Edge Case
		}catch{
			$Global:Req2ADComputerListAll = "<h2>2.4 - Grab All Computer Objects from Active Directory</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n")
			}
		}
	}

	# 2.4 - Map Neighboring Devices
	Function Req2MapNeighboringDevices {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.4 - List of Neighboring Devices.`n")
		}else{
			$AllOutput.AppendText("2.4 - List of Neighboring Devices.`n")
		}
		# Data Gathering for IPV4
		try{
			# IPV4 Adapters
			$IPV4Adapters = Get-NetIPAddress | Select-Object InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState | Where-Object AddressFamily -eq IPv4 | Sort-Object InterfaceIndex,InterfaceAlias
			$IPV4AdaptersRTB = $IPV4Adapters | Format-Table | Out-String
			$Global:Req2IPV4AdaptersHTML = $IPV4Adapters | ConvertTo-Html -As Table -Property InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState -Fragment -PreContent "<h2>2.4 - Map Neighboring Devices</h2><h3>IPV4 Adapters</h3>"
			# IPV4 Neighbors
			$IPV4Neighbors = Get-NetNeighbor -AddressFamily IPv4 | Where-Object State -ne Unreachable | Sort-Object ifIndex,IPAddress
			$IPV4NeighborsRTB = $IPV4Neighbors | Format-Table | Out-String
			$Global:Req2IPV4NeighborsHTML = $IPV4Neighbors | ConvertTo-Html -As Table -Property ifIndex,InterfaceAlias,IPAddress,LinkLayerAddress,State,PolicyStore -Fragment -PreContent "<h3>IPV4 Neighbors</h3>"
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Stale</td>','<td class="AvailableStatus">Stale</td>' 
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Reachable</td>','<td class="InstalledStatus">Reachable</td>'
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Permanent</td>','<td class="RemovedStatus">Permanent</td>'
			# Data Output for IPV4
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV4 Adapters`n")
				$Req2Output.AppendText($IPV4AdaptersRTB)
				$Req2Output.AppendText("IPV4 Neighbors`n")
				$Req2Output.AppendText($IPV4NeighborsRTB)
			}else{
				$AllOutput.AppendText("IPV4 Adapters`n")
				$AllOutput.AppendText($IPV4AdaptersRTB)
				$AllOutput.AppendText("IPV4 Neighbors`n")
				$AllOutput.AppendText($IPV4NeighborsRTB)
			}
		# Edge Case IPV4
		}catch{
			$Global:Req2IPV4AdaptersHTML = "<h2>2.4 - Map Neighboring Devices</h2><h3>IPV4 Adapters</h3><p>Unable to List IPV6 Adapters.</p>"
			$Global:Req2IPV4NeighborsHTML = "<h3>IPV4 Neighbors</h3><p>Unable to List Neighboring Devices.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List Neighboring Devices.`n")
			}else{
				$AllOutput.AppendText("`nUnable to List Neighboring Devices.`n")
			}
		}
		# Data Gathering for IPV6
		try{
			# IPV6 Adapters
			$IPV6Adapters = Get-NetIPAddress | Select-Object InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState | Where-Object AddressFamily -eq IPv6 | Sort-Object InterfaceIndex,InterfaceAlias
			$IPV6AdaptersRTB = $IPV6Adapters | Format-Table | Out-String
			$Global:Req2IPV6AdaptersHTML = $IPV6Adapters | ConvertTo-Html -As Table -Property InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState -Fragment -PreContent "<h3>IPV6 Adapters</h3>"
			# IPV6 Neighbors
			$IPV6Neighbors = Get-NetNeighbor -AddressFamily IPv6 | Where-Object State -ne Unreachable | Sort-Object ifIndex,IPAddress
			$IPV6NeighborsRTB = $IPV6Neighbors | Format-Table | Out-String
			$Global:Req2IPV6NeighborsHTML = $IPV6Neighbors | ConvertTo-Html -As Table -Property ifIndex,InterfaceAlias,IPAddress,LinkLayerAddress,State,PolicyStore -Fragment -PreContent "<h3>IPV6 Neighbors</h3>"
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Stale</td>','<td class="AvailableStatus">Stale</td>' 
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Reachable</td>','<td class="InstalledStatus">Reachable</td>'
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Permanent</td>','<td class="RemovedStatus">Permanent</td>'
			# Data Output for IPV6
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV6 Adapters`n")
				$Req2Output.AppendText($IPV6AdaptersRTB)
				$Req2Output.AppendText("IPV6 Neighbors`n")
				$Req2Output.AppendText($IPV6NeighborsRTB)
			}else{
				$AllOutput.AppendText("IPV6 Adapters`n")
				$AllOutput.AppendText($IPV6AdaptersRTB)
				$AllOutput.AppendText("IPV6 Neighbors`n")
				$AllOutput.AppendText($IPV6NeighborsRTB)
			}
		# Edge Case IPV6
		}catch{
			$Global:Req2IPV6AdaptersHTML = "<h3>IPV6 Adapters</h3><p>Unable to List IPV6 Adapters.</p>"
			$Global:Req2IPV6NeighborsHTML = "<h3>IPV6 Neighbors</h3><p>Unable to List Neighboring Devices.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List Neighboring Devices.`n")
			}else{
				$AllOutput.AppendText("`nUnable to List Neighboring Devices.`n")
			}
		}
	}

	# onClick Event Handler - Requirement Two
	$Req2ScriptList_ListUpdate = {
		if($Req2ScriptList.SelectedItem -eq "2.1 - Test Vendor Default Credentials in AD"){
			$Req2Output.Clear()
			Req2TestDefaultAccounts
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.1 - Grab Installed Windows Features"){
			$Req2Output.Clear()
			Req2GrabInstalledFeatures
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.2 - Grab Running Processes"){
			$Req2Output.Clear()
			Req2RunningProcesses
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.2 - Grab Running Services"){
			$Req2Output.Clear()
			Req2RunningServices
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.2 - Grab Established Network Connections"){
			$Req2Output.Clear()
			Req2ListeningServices
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.2 - Grab Installed Software"){
			$Req2Output.Clear()
			Req2GrabInstalledSoftware
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.5 - Grab Local Drives and Network Shares"){
			$Req2Output.Clear()
			Req2GrabDrivesAndShares
		}elseif($Req2ScriptList.SelectedItem -eq "2.4 - Grab All Computer Objects from Active Directory"){
			$Req2Output.Clear()
			Req2GrabADComputers
		}elseif($Req2ScriptList.SelectedItem -eq "2.4 - Map Neighboring Devices"){
			$Req2Output.Clear()
			Req2MapNeighboringDevices
		}elseif($Req2ScriptList.SelectedItem -eq "Everything in Requirement Two"){
			$Req2Output.Clear()
			$Req2Output.AppendText("Everything in Requirement Two `n")
			$Req2OutputLabel.Text = "Output: Progressing... 10%"
			$Req2OutputLabel.Refresh()
			Req2TestDefaultAccounts
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 20%"
			$Req2OutputLabel.Refresh()
			Req2RunningProcesses
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 40%"
			$Req2OutputLabel.Refresh()
			Req2RunningServices
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 50%"
			$Req2OutputLabel.Refresh()
			Req2ListeningServices
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 60%"
			$Req2OutputLabel.Refresh()
			Req2GrabInstalledSoftware
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 80%"
			$Req2OutputLabel.Refresh()
			Req2GrabDrivesAndShares
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Progressing... 90%"
			$Req2OutputLabel.Refresh()
			Req2GrabADComputers
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Refresh()
			Req2MapNeighboringDevices
			$Req2OutputLabel.Text = "Output:"
		}else{
			$Req2Output.Clear()
			$Req2Output.AppendText("You must select an object from the script list.")
		}
	}

	# Requirement Two Report Export
	# Build Report Function 
	Function Req2ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementTwoName = "<h1 id='RequirementHeader'>PCI DSS Requirement Two Report</h1>"
		$Requirement2Report = ConvertTo-HTML -Body "$Global:ReportRequirementTwoName $ReportComputerName $Global:Req2UserCredentialResult $Global:Req2FeatureListHTML $Global:Req2ProcessListHTML $Global:Req2SvcListRunningHTML $Global:Req2SvcListListeningHTML $Global:Req2UDPListHTML $Global:Req2SoftwareListHTML $Global:Req2LocalDrivesHTML $Global:Req2LocalDrivesExtraHTML $Global:Req2LocalNetworkSharesHTML $Global:Req2ADComputerListAll $Global:Req2IPV4AdaptersHTML $Global:Req2IPV4NeighborsHTML $Global:Req2IPV6AdaptersHTML $Global:Req2IPV6NeighborsHTML" -Head $CSSHeader -Title "PCI DSS Requirement Two Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement2ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html"
		$Requirement2Report | Out-File $Requirement2ReportPath
		$Req2Output.AppendText("Requirement Two Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html")
		$Req2EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Two Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html","Requirement Two Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)    
	}
	# onClick Event Handler to Gather Data for Report
	$Req2ExportReport = {
			$Req2Output.Clear()
			$Req2Output.AppendText("Writing Report for the Following`n`n")
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req2OutputLabel.Refresh()
			Req2TestDefaultAccounts
			$Req2Output.AppendText($Global:SectionHeader)
			Req2GrabInstalledFeatures
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 20%"
			$Req2OutputLabel.Refresh()
			Req2RunningProcesses
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 40%"
			$Req2OutputLabel.Refresh()
			Req2RunningServices
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 50%"
			$Req2OutputLabel.Refresh()
			Req2ListeningServices
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 60%"
			$Req2OutputLabel.Refresh()
			Req2GrabInstalledSoftware
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 80%"
			$Req2OutputLabel.Refresh()
			Req2GrabDrivesAndShares
			$Req2Output.AppendText($Global:SectionHeader)
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 90%"
			$Req2OutputLabel.Refresh()
			Req2GrabADComputers
			$Req2Output.AppendText($Global:SectionHeader)
			Req2MapNeighboringDevices
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$Req2OutputLabel.Refresh()
			Req2ExportReportFunction
			$Req2OutputLabel.Text = "Output:"
	}

# Requirement Four Tab # 
	# 4.1 - Analyse Wi-Fi Envrioment
	Function Req4WifiScan {
		# Data Gathering
		try{
			$Req4WifiList = netsh wlan show networks mode=Bssid | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req4WifiListHTML = "<h2>4.1 - Analyse Wi-Fi Envrioment</h2><pre>" + $Req4WifiList + "</pre>"
		# Edge Case
		}catch{
			$Req4WifiList = "Unable to find Wi-Fi Networks"
			$Global:Req4WifiListHTML = "<h2>4.1 - Analyse Wi-Fi Envrioment</h2><p>Unable to find Wi-Fi Networks</p>"
		}
		# Data Ouput
		if($EverythingToggle -eq $false){
			$Req4Output.AppendText("4.1 - List of Wi-Fi Networks:`n")
			$Req4Output.AppendText($Req4WifiList)
		}else{
			$AllOutput.AppendText("4.1 - List of Wi-Fi Networks:`n")
			$AllOutput.AppendText($Req4WifiList)
		}
	}

	# 4.1 - Analyse Keys and Certificates
	Function Req4GetKeysAndCerts{
		# Data Gathering
		try{
			$Req4LocalMachineCerts = Get-ChildItem -Recurse -path cert:\LocalMachine
			$Req4CurrentUserCerts = Get-ChildItem -Recurse -path cert:\CurrentUser
			$Req4LocalMachineCertsRTB = $Req4LocalMachineCerts | Format-List | Out-String
			$Req4CurrentUserCertsRTB = $Req4CurrentUserCerts | Format-List | Out-String
			$Global:Req4LocalMachineCertsHTML = "<h2>4.1 - List of Keys and Certificates</h2><h3>Local Machine Certificates</h3><pre>" + $Req4LocalMachineCertsRTB + "</pre>"
			$Global:Req4CurrentUserCertsHTML =  "<h3>Current User Certificates</h3><pre>" + $Req4CurrentUserCertsRTB + "</pre>"
		# Edge Case
		}catch{
			$Req4LocalMachineCertsRTB = "Something went wrong, Could not get keys or certs."
			$Req4CurrentUserCertsRTB = "Something went wrong, Could not get keys or certs."
			$Global:Req4LocalMachineCertsHTML = "<h2>4.1 - List of Keys and Certificates</h2><h3>Local Machine Certificates</h3><p>Something went wrong, Could not get keys or certs.</p>"
			$Global:Req4CurrentUserCertsHTML = "<h3>Current User Certificates</h3><p>Something went wrong, Could not get keys or certs.</p>"
		}
		# Data Output
		if($EverythingToggle -eq $false){
			$Req4Output.AppendText("`n4.1 - List of Keys and Certificates:`nLocal Machine Certificates:`n")
			$Req4Output.AppendText($Req4LocalMachineCertsRTB)
			$Req4Output.AppendText($Global:SectionHeader)
			$Req4Output.AppendText("Current User Certificates:`n")
			$Req4Output.AppendText($Req4CurrentUserCertsRTB)
		}else{
			$AllOutput.AppendText("4.1 - List of Keys and Certificates:`nLocal Machine Certificates:`n")
			$AllOutput.AppendText($Req4LocalMachineCertsRTB)
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("Current User Certificates:`n")
			$AllOutput.AppendText($Req4CurrentUserCertsRTB)
		}
	}

	# onClick Event Handler for Requirement Four
	$Req4ScriptList_ListUpdate = {
		if($Req4ScriptList.SelectedItem -eq "4.1 - Analyse Wi-Fi Environment"){
			$Req4Output.Clear()
			Req4WifiScan
		}elseif($Req4ScriptList.SelectedItem -eq "4.1 - Analyse Keys and Certificates"){
			$Req4Output.Clear()
			Req4GetKeysAndCerts
		}elseif($Req4ScriptList.SelectedItem -eq "Everything in Requirement Four"){
			$Req4Output.Clear()
			$Req4Output.AppendText("Everything in Requirement Four`n")
			$Req4OutputLabel.Text = "Output: Progressing... 10%"
			$Req4OutputLabel.Refresh()
			Req4WifiScan
			$Req4OutputLabel.Text = "Output: Progressing... 50%"
			$Req4OutputLabel.Refresh()
			$Req4Output.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			$Req4OutputLabel.Text = "Output:"
			$Req4OutputLabel.Refresh()
		}else{
			$Req4Output.Clear()
			$Req4Output.AppendText("You must select an object from the script list.")
		}
	}

	# Requirement Four Report Export
	# Build Report Function
	Function Req4ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementFourName = "<h1 id='RequirementHeader'>PCI DSS Requirement Four</h1>"
		$Requirement4Report = ConvertTo-HTML -Body "$Global:ReportRequirementFourName $ReportRequirementName $ReportComputerName $Global:Req4WifiListHTML $Global:Req4LocalMachineCertsHTML $Global:Req4CurrentUserCertsHTML" -Head $CSSHeader -Title "PCI DSS Requirement Four Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement4ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html"
		$Requirement4Report | Out-File $Requirement4ReportPath
		$Req4Output.AppendText("Requirement Four Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html")
		$Req4EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Four Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html","Requirement Four Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$Req4ExportReport = {
			$Req4Output.Clear()
			$Req4Output.AppendText("Writing Report for the Following`n`n")
			$Req4OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req4OutputLabel.Refresh()
			Req4WifiScan
			$Req4OutputLabel.Text = "Output: Data Exporting in Progress... 50%"
			$Req4OutputLabel.Refresh()
			$Req4Output.AppendText($Global:SectionHeader)
			Req4GetKeysAndCerts
			$Req4OutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$Req4OutputLabel.Refresh()
			Req4ExportReportFunction
			$Req4OutputLabel.Text = "Output:"
	}

# Requirement Five Tab #
	# Initialize Switch
	$Global:Req5AllSwitch = $false

	# 5.1 - Antivirus Program and GPO Analysis
	Function Req5AVSettingsAndGPO {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req5Output.AppendText("5.1 - List of Anti-Virus Programs Detected. This may take a while.`n")
		}else{
			$AllOutput.AppendText("5.1 - List of Anti-Virus Programs Detected. This may take a while.`n")
		}
		# Data Gathering
		try{
			$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version | Where-Object {($_.Vendor -like "*Avira*") -or ($_.Vendor -like "*Avast*") -or ($_.Vendor -like "*AVG*") -or ($_.Vendor -like "*Bitdefender*") -or ($_.Vendor -like "*ESET*") -or ($_.Vendor -like "*Kaspersky*") -or ($_.Vendor -like "*Malwarebytes*") -or ($_.Vendor -like "*McAfee*") -or ($_.Vendor -like "*NortonLifeLock*") -or ($_.Vendor -like "*Sophos*") -or ($_.Vendor -like "*Symantec*") -or ($_.Vendor -like "*Trend Micro*")} | Sort-Object Vendor,Name
			$AVProgramQueryRTB = $AVProgramQuery | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req5AVProgramQueryHTML = $AVProgramQuery | ConvertTo-Html -As Table -Fragment -PreContent "<h2>5.1 - Antivirus Program and GPO Analysis</h2><h3>List of Anti-Virus Programs Detected</h3>"
			# Edge Case incase No Anti-Virus Programs are Found
			if([string]::IsNullOrEmpty($AVProgramQuery)){
				$AVProgramQuery = Get-WmiObject -Class Win32_Product | Select-Object Name,Vendor,Version,InstallDate | Sort-Object Vendor,Name
				$AVProgramQueryRTB = $AVProgramQuery | Format-Table -Autosize | Out-String -Width 1200
				$Global:Req5AVProgramQueryHTML = $AVProgramQuery | ConvertTo-Html -As Table -Fragment -PreContent "<h2>5.1 - Antivirus Program and GPO Analysis</h2><h3>No Anti-Virus detected, Here is the list of all programs detected</h3>"
				# Data Output for when there is No Anti-Virus Programs
				if($EverythingToggle -eq $false){
					$Req5Output.AppendText("No Anti-Virus detected, Here is the list of all programs detected and a GPO Dump for futher analysis:`n")
					$Req5Output.AppendText($AVProgramQueryRTB)
					$Req5Output.AppendText("`nCheck GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
				}else{
					$AllOutput.AppendText("No AntiVirus detected, Here is the list of all programs detected and check the GPO Dump section for futher analysis.`n")
					$AllOutput.AppendText($AVProgramQueryRTB)
					$AllOutput.AppendText("`nCheck GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
				}
			# Data Output for when there is an anti-virus program detected
			}else{
				if($EverythingToggle -eq $false){
					$Req5Output.AppendText($AVProgramQueryRTB)
				}else{
					$AllOutput.AppendText($AVProgramQueryRTB)
				}
			}
		# Edge Case for when something goes wrong. Should never happen but you never know.
		}catch{
			if($EverythingToggle -eq $false){
				$Req5Output.AppendText("List of Anti-Virus Programs Failed. An unexpected error has occurred.`n")
			}else{
				$AllOutput.AppendText("List of Anti-Virus Programs Failed. An unexpected error has occurred.`n")
			}
			$Global:Req5AVProgramQueryHTML = "<h2>Antivirus Program and GPO Analysis</h2><p>List of Anti-Virus Programs Failed. An unexpected error has occurred.</p>"
		}

		# Requirement Five Everything Switch. This is because all of the remaining stuff in Requirement Five is telling the user to check GPO dump. This Function is called inplace of calling all the Requirement Five Functions.
		# Data Output Inside Requirement Five Tab
		if(($EverythingToggle -ne $true) -and ($Global:Req5AllSwitch -eq $true)){
			# 5.1 - Data Output for Software Deployment Settings
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("5.1 - Check GPO Dump for Software Deployment Settings in Organization")
			$Global:Req5SoftwareDeploymentHTML = "<h2>5.1 - Grab Software Deployment Settings in Organization</h2><p>Check GPO Dump for Software Deployment Settings in Organization</p>"
			# 5.3 - Data Output for End User Permissions
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("5.3 - Check end user permissions to modify Anti-Virus software in GPO Dump")
			$Global:Req5AVPermsHTML = "<h2>5.3 - Check end user permissions to modify antivirus software</h2><p>Check end user permissions to modify Anti-Virus software in GPO Dump</p>"
			# Data Output and Append GPO Dump for Requirement Five (Everything in Requirement Five Item in List)
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($Global:GPODump)
			# Set Switch to False
			$Global:Req5AllSwitch = $false
		# Data Output In All Tab
		}elseif(($EverythingToggle -ne $false) -and ($Global:Req5AllSwitch -eq $true)){
			# 5.1 - Data Output for Software Deployment Settings
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("5.1 - Check GPO Dump for Software Deployment Settings in Organization")
			$Global:Req5SoftwareDeploymentHTML = "<h2>5.1 - Grab Software Deployment Settings in Organization</h2><p>Check GPO Dump for Software Deployment Settings in Organization</p>"
			# 5.1 - Data Output for End User Permissions
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("5.3 - Check end user permissions to modify Anti-Virus software in GPO Dump")
			$Global:Req5AVPermsHTML = "<h2>5.3 - Check end user permissions to modify antivirus software</h2><p>Check end user permissions to modify Anti-Virus software in GPO Dump</p>"
			# No need to append GPO Dump here but instead append it in the dedicated function
		# If the switch has not been switch then just output the GPO Dump for only after the Anti-Virus Programs/List of Programs.
		}else{
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($global:GPODump)
		}
	}
	
	# 5.1 - Grab Software Deployment Settings in Organization
	Function Req5SoftwareDeployment {
		$Req5Output.AppendText("5.1 - Check GPO Dump for Software Deployment Settings in Organization`n")
		$Req5Output.AppendText($global:GPODump)
	}

	# 5.3 - Check end user permissions to modify antivirus software
	Function Req5AVPermissions {
		$Req5Output.AppendText("5.3 - Check end user permissions to modify antivirus software in GPO Dump`n")
		$Req5Output.AppendText($global:GPODump)
	}

	# onClick Event Handler
	$Req5ScriptList_ListUpdate = {
		if($Req5ScriptList.SelectedItem -eq "5.1 - Antivirus Program and GPO Analysis"){
			$Req5Output.Clear()
			Req5AVSettingsAndGPO
		}elseif($Req5ScriptList.SelectedItem -eq "5.1 - Grab Software Deployment Settings in Organization"){
			$Req5Output.Clear()
			Req5SoftwareDeployment
		}elseif($Req5ScriptList.SelectedItem -eq "5.3 - Check end user permissions to modify antivirus software"){
			$Req5Output.Clear()
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
	# Build Report Function
	Function Req5ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementFiveName = "<h1 id='RequirementHeader'>PCI DSS Requirement Five</h1>"
		$Requirement5Report = ConvertTo-HTML -Body "$Global:ReportRequirementFiveName $ReportComputerName $Global:Req5AVProgramQueryHTML $Global:Req5SoftwareDeploymentHTML $Global:Req5AVPermsHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Five Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement5ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html"
		$Requirement5Report | Out-File $Requirement5ReportPath
		$Req5Output.AppendText("Requirement Five Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html")
		$Req5EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Five Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html","Requirement Five Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$Req5ExportReport = {
			$Req5Output.Clear()
			$Req5Output.AppendText("Writing Report for the Following`n`n")
			$Global:Req5AllSwitch = $true
			Req5AVSettingsAndGPO
			Req5ExportReportFunction
	}

# Requirement Seven Tab
	# User Folder Input
	Function Req7FolderInput {
		$UserFolderInputMessageBox = [System.Windows.Forms.MessageBox]::Show("When this Warning Message is Closed, You will be prompted to select a folder for analysis.","Warning",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
		$FilePopupTmp = $AuxiliaryForm.Req7FolderBrowserDialog.ShowDialog()
		if($FilePopupTmp -eq "OK"){    
			$Global:FilePathFilePopupTmp = $Req7FolderBrowserDialog.SelectedPath
		}
	}

	# 7.1 - Grab and analyse folder permissions that hold sensitive data
	Function Req7FolderPerms {
		# Data Gathering
		if(-not([string]::IsNullOrEmpty($Global:FilePathFilePopupTmp))){
			# Write Header
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("7.1 - Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$Req7Output.AppendText("`nFolder Selected: " + $Global:FilePathFilePopupTmp)
			}else{
				$AllOutput.AppendText("7.1 - Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$AllOutput.AppendText("`nFolder Selected: " + $Global:FilePathFilePopupTmp)
			}
			# Take user input/file path and get permissions
			try{
				$LocalFolderPerms = (Get-Acl -Path $Global:FilePathFilePopupTmp).Access | Sort-Object IsInherited, Identity-Reference | Select-Object IdentityReference, FileSystemRights, IsInherited
				$LocalFolderPermsRTB = $LocalFolderPerms | Format-Table IdentityReference, FileSystemRights, IsInherited | Out-String
				$Global:Req7LocalFolderPermsHTML = $LocalFolderPerms | ConvertTo-Html -As Table -Fragment -PreContent "<h2>7.1 - Grab and analyse folder permissions that hold sensitive data</h2><h3>Local folder premissions</h3><p>Folder Selected: $Global:FilePathFilePopupTmp</p>"
				# Data Output
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText($LocalFolderPermsRTB)
				}else{
					$AllOutput.AppendText($LocalFolderPermsRTB)
				}
			# Edge Case 
			}catch{
				$Global:Req7LocalFolderPermsHTML = "<h2>7.1 - Grab and analyse folder permissions that hold sensitive data</h2><h3>Local folder premissions</h3><p>An Unexpected Error Has Occurred<br>Folder Selected: $Global:FilePathFilePopupTmp</p>"
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("An Unexpected Error Has Occurred")
				}else{
					$AllOutput.AppendText("An Unexpected Error Has Occurred")
				}
			}
			# Find network folder premissions/samba share on selected folder
			# Write Header
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
				$SambaShareStatus = Get-SmbShareAccess $SambaShareName 
				$SambaShareStatusRTB = $SambaShareStatus | Out-String
				$Global:Req7SambaShareStatusHTML = $SambaShareStatus | ConvertTo-Html -As Table -Fragment -PreContent "<h3>Network folder permissions</h3>"
				# Output to user selected tab
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText($Global:FilePathFilePopupTmp + " exists as a Samba Share")
					$Req7Output.AppendText($SambaShareStatusRTB)
				}else{
					$AllOutput.AppendText($Global:FilePathFilePopupTmp + " exists as a Samba Share")
					$AllOutput.AppendText($SambaShareStatusRTB)
				}
			# No Samba Share Found
			}else{
				# Output to user selected tab
				$Global:Req7SambaShareStatusHTML = "<h3>Network folder permissions</h3><p>$Global:FilePathFilePopupTmp Does not exist as a Samba Share</p>"
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText($Global:FilePathFilePopupTmp + " Does not exist as a Samba Share")
				}else{
					$AllOutput.AppendText($Global:FilePathFilePopupTmp + " Does not exist as a Samba Share")
				}
			}
		# Find Edge-Case if user input is empty
		}else{
			$Global:Req7LocalFolderPermsHTML = "<h2>7.1 - Grab and analyse folder permissions that hold sensitive data</h2><h3>Local folder premissions</h3><p>Invalid Folder Selected</p>"
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("7.1 - Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$Req7Output.AppendText("`nInvalid Folder Selected`n")
			}else{
				$AllOutput.AppendText("7.1 - Grab and analyse folder permissions that hold sensitive data`n`nLocal folder premissions...")
				$AllOutput.AppendText("`nInvalid Folder Selected`n")
			}
		}
	}
	
	# 7.2 - Check for deny all permissions
	Function Req7DenyAll {
		if(-not([string]::IsNullOrEmpty($Global:FilePathFilePopupTmp))){
			# Write Header
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("7.2 - Check for deny all permissions`n")
			}else{
				$AllOutput.AppendText("7.2 - Check for deny all permissions`n")
			}
			# Find premissions for user selected path
			try{
				$Req7FolderPerms = Get-ChildItem -Path $Global:FilePathFilePopupTmp | Get-Acl
				$Req7FolderPermsRTB = $Req7FolderPerms | Format-List | Out-String
				# Edge Case for child objects
				if([string]::IsNullOrEmpty($Req7FolderPerms)){
					$Global:Req7FolderPermsHTML = "<h2>7.2 - Check for deny all permissions</h2><p>No Child Objects Found, Select Root Object that contains a Child Object.<br>Path Selected: $Global:FilePathFilePopupTmp</p>"
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText("No Child Objects Found, Select Root Object that contains a Child Object. Path Selected: " + $Global:FilePathFilePopupTmp)
					}else{
						$AllOutput.AppendText("No Child Objects Found, Select Root Object that contains a Child Object. Path Selected: " + $Global:FilePathFilePopupTmp)
					}
				}else{
					$Global:Req7FolderPermsHTML = $Req7FolderPerms | ConvertTo-Html -As List -Fragment -PreContent "<h2>Check for deny all permissions</h2>"
					# Output Data
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText($Req7FolderPermsRTB)
					}else{
						$AllOutput.AppendText($Req7FolderPermsRTB)
					}
				}
			# Edge Case
			}catch{
				$Global:Req7FolderPermsHTML = "<h2>7.2 - Check for deny all permissions</h2><p>An Error Has Occurred...</p>"
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`An Error Has Occurred...`n")
				}else{
					$AllOutput.AppendText("`An Error Has Occurred...`n")
				}
			}
		# Find Edge-Case if user input is empty
		}else{
			$Global:Req7FolderPermsHTML = "<h2>7.2 - Check for deny all permissions</h2><p>Invalid Folder Selected</p>"
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("Check for deny all permissions`n")
				$Req7Output.AppendText("`nInvalid Folder Selected`n")
			}else{
				$AllOutput.AppendText("Check for deny all permissions`n")
				$AllOutput.AppendText("`nInvalid Folder Selected`n")
			}
		}
	}

	# 7.1.2 - Grab User Privileges
	Function Req7UserPriviledges {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req7Output.AppendText("7.1.2 - Grab User Privileges`nThis may take a while`n")
			Start-Sleep -Seconds 0.5
		}else{
			$AllOutput.AppendText("7.1.2 - Grab User Privileges`nThis may take a while`n")
			Start-Sleep -Seconds 0.5
		}
		# Query AD
		# Initialize Variable to Store Data for HTML Report
		$Req7GroupMembershipList = $null
		# Data Gathering
		try{
			$ActiveDirectoryGroups = (Get-ADGroup -Filter *).Name
			# Loop
			foreach ($Group in $ActiveDirectoryGroups){
			$GroupMembership = Get-ADGroupMember -Identity $Group | Select-Object Name,SamaccountName,objectClass,distinguishedName | Sort-Object Name,objectClass | Format-Table | Out-String
			if([string]::IsNullOrEmpty($GroupMembership)){
				# Add to HTML List 
				$Req7GroupMembershipList += "`nNo Users in " + $Group + "`n"
				# Data Output
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`nNo Users in " + $Group + "`n")
				}else{
					$AllOutput.AppendText("`nNo Users in " + $Group + "`n")
				}
			}else{
				# Add to HTML List 
				$Req7GroupMembershipList += "`nHere are the Users in " + $Group + "`n" + $GroupMembership
				# Data Output
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`nHere are the Users in " + $Group)
					$Req7Output.AppendText($GroupMembership)
				}else{
					$AllOutput.AppendText("`nHere are the Users in " + $Group)
					$AllOutput.AppendText($GroupMembership)
					}
				}
			}
			# After Looping Print to HTML
			$Global:Req7GroupMembershipListHTML = "<h2>7.1.2 - Grab User Privileges</h2><pre>" + $Req7GroupMembershipList + "</pre>"
		# Edge Case
		}catch{
			$Global:Req7GroupMembershipListHTML = "<h2>7.1.2 - Grab User Privileges</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n")
			}
		}
	}

	# onClick event handler
	$Req7ScriptList_ListUpdate = {
		if($Req7ScriptList.SelectedItem -eq "7.1 - Grab and analyse folder permissions that hold sensitive data"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7FolderPerms
		}elseif($Req7ScriptList.SelectedItem -eq "7.2 - Check for deny all permissions"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7DenyAll
		}elseif($Req7ScriptList.SelectedItem -eq "7.1.2 - Grab User Privileges"){
			$Req7Output.Clear()
			Req7UserPriviledges
		}elseif($Req7ScriptList.SelectedItem -eq "Everything in Requirement Seven"){
			$Req7Output.Clear()
			$Req7Output.AppendText("Everything in Requirement Seven`n")
				Req7FolderInput
				Req7FolderPerms
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

	# Requirement Seven Report Export
	# Build Report Function
	Function Req7ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementSevenName = "<h1 id='RequirementHeader'>PCI DSS Requirement Seven</h1>"
		$Requirement7Report = ConvertTo-HTML -Body "$Global:ReportRequirementSevenName $ReportComputerName $Global:Req7LocalFolderPermsHTML $Global:Req7SambaShareStatusHTML $Global:Req7FolderPermsHTML $Global:Req7GroupMembershipListHTML" -Head $CSSHeader -Title "PCI DSS Requirement Seven Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement7ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html"
		$Requirement7Report | Out-File $Requirement7ReportPath
		$Req7Output.AppendText("Requirement Seven Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html")
		$Req7EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Seven Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html","Requirement Seven Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$Req7ExportReport = {
			$Req7Output.Clear()
			$Req7Output.AppendText("Writing Report for the Following`n`n")
			Req7FolderInput
			Req7FolderPerms
			$Req7Output.AppendText($Global:SectionHeader)
			Req7DenyAll
			$Req7Output.AppendText($Global:SectionHeader)
			Req7UserPriviledges
			Req7ExportReportFunction
	}

# Requirement Eight Tab #
	# 8.2 - Grab Domain Password Policy Settings
	Function Req8DomainPasswordPolicy{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.2 - Current Domain Password Policy Settings:")
		}else{
			$AllOutput.AppendText("8.2 - Current Domain Password Policy Settings:")
		}
		# Data Gathering
		try{
			$CurrentDomainPolicies = (Get-ADForest -Current LoggedOnUser).Domains | %{ Get-ADDefaultDomainPasswordPolicy -Identity $_ } | Out-String
			$Global:Req8CurrentDomainPoliciesHTML = "<h2>8.2 - Current Domain Password Policy Settings</h2><pre>" + $CurrentDomainPolicies + "</pre>"
			# Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($CurrentDomainPolicies)
			}else{
				$AllOutput.AppendText($CurrentDomainPolicies)
			}
		# Edge case
		}catch{
			$Global:Req8CurrentDomainPoliciesHTML = "<h2>8.2 - Current Domain Password Policy Settings</h2><pre>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</pre>"
			# Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.2 - Grab Local Password Policy Settings
	Function Req8LocalPasswordPolicy{
		$Global:Req8LocalPolicyHTML = "<h2>8.2 - Local Password Policy Settings</h2><p>Check GPO Dump for Local GPO Policies.</p>"
		# Data Output
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.2 - Grab Local Password Policy Settings:`nCheck GPO Dump for Local GPO Policies.`n")
			$Req8Output.AppendText($global:GPODump)
		}else{
			$AllOutput.AppendText("8.2 - Grab Local Password Policy Settings:`nCheck GPO Dump for Local GPO Policies.`n")
			# Don't Dump GPO in all output but instead have a dedicated function for that later on.
			# $AllOutput.AppendText($global:GPODump)
		}
	}

	# 8.1.1 - Dump of All Active Directory Users
	Function Req8DumpActiveADUsers{
		# Write Header 
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1.1 - Dump of All Enabled AD Users:")
		}else{
			$AllOutput.AppendText("8.1.1 - Dump of All Enabled AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListAll = Get-ADUser -Filter * | Select-Object GivenName, Surname, Enabled, SamAccountName, UserPrincipalName, DistinguishedName |Sort-Object GivenName,Surname | Where-Object Enabled -eq Enabled
			$ADUserListAllRTB = $ADUserListAll | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8ADUserListAllHTML = $ADUserListAll | ConvertTo-Html -As Table -Property GivenName, Surname, Enabled, SamAccountName, UserPrincipalName, DistinguishedName -Fragment -PreContent "<h2>8.1.1 - Dump of All Enabled Active Directory Users</h2>"
			$Global:Req8ADUserListAllHTML = $Global:Req8ADUserListAllHTML -replace '<td>True</td>','<td class="EnabledStatus">True</td>'
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListAllRTB)
			}else{
				$AllOutput.AppendText($ADUserListAllRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ADUserListAllHTML = "<h2>8.1.1 - Dump of All Enabled Active AD Users</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.1.3 - Dump of Disabled AD Users
	Function Req8DumpDisabledADUsers{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1.3 - Dump of All Disabled AD Users:")
		}else{
			$AllOutput.AppendText("8.1.3 - Dump of All Disabled AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListDisabled = Get-ADUser -Filter 'Enabled -eq $false' | Select-Object GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName |Sort-Object GivenName,Surname
			$ADUserListDisabledRTB = $ADUserListDisabled  | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8ADUserListDisabledHTML = $ADUserListDisabled | ConvertTo-Html -As Table -Property GivenName,Surname,Enabled,SamAccountName,UserPrincipalName,DistinguishedName -Fragment -PreContent "<h2>8.1.3 - Dump of All Disabled AD Users</h2>"
			$Global:Req8ADUserListDisabledHTML = $Global:Req8ADUserListDisabledHTML -replace '<td>False</td>','<td class="DisabledStatus">False</td>'
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListDisabledRTB)
			}else{
				$AllOutput.AppendText($ADUserListDisabledRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ADUserListDisabledHTML = "<h2>8.1.3 - Dump of All Disabled AD Users</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.1.3 - Dump of Inactive AD Users
	Function Req8DumpInactiveADUsers{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1.3 - Dump of All Inactive AD Users:")
		}else{
			$AllOutput.AppendText("8.1.3 - Dump of All Inactive AD Users:")
		}
		# Data Gathering
		try{
			$ADUserListInactiveADUsers = Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90 | ?{$_.enabled -eq $True} | Select-Object Name,SamAccountName,UserPrincipalName,DistinguishedName,LastLogonDate |Sort-Object Name
			$ADUserListInactiveADUsersRTB = $ADUserListInactiveADUsers | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8ADUserListInactiveADUsersHTML = $ADUserListInactiveADUsers | ConvertTo-Html -As Table -Property Name,SamAccountName,UserPrincipalName,DistinguishedName,LastLogonDate -Fragment -PreContent "<h2>8.1.3 - Dump of Inactive AD Users</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserListInactiveADUsersRTB)
			}else{
				$AllOutput.AppendText($ADUserListInactiveADUsersRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ADUserListInactiveADUsersHTML = "<h2>8.1.3 - Dump of Inactive AD Users</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.1 - Grab Current User
	Function Req8GrabCurrentUser{
		try{
			$Global:Req8CurrentUserHTML = "<h2>8.1 - Current Logged-In User</h2><p>Username: " + $env:UserName + "<br>Domain: " + $env:UserDNSDomain + "<br>Computer: " + $env:ComputerName + "</p>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("8.1 - Current Logged-In User:`n")
				$Req8Output.AppendText("Username: " + $env:UserName + "`nDomain: " + $env:UserDNSDomain + "`nComputer: " + $env:ComputerName)
			}else{
				$AllOutput.AppendText("8.1 - Current Logged-In User:`n")
				$AllOutput.AppendText("Username: " + $env:UserName + "`nDomain: " + $env:UserDNSDomain + "`nComputer: " + $env:ComputerName)
			}
		# Edge case that should never happen but you never know.
		}catch{
			$Global:Req8CurrentUserHTML = "<h2>8.1 - Current Logged-In User</h2><p>An Unexpected Error Has Occurred</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nAn Unexpected Error Has Occurred.")
			}else{
				$AllOutput.AppendText("`nAn Unexpected Error Has Occurred.")
			}
		}
	}

	# 8.1 - Grab Local Administrator Accounts
	Function Req8GrabLocalAdmins{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1 - Grab Local Administrators:`n")
		}else{
			$AllOutput.AppendText("8.1 - Grab Local Administrators:`n")
		}
		# Data Gathering
		try{
			$LocalAdminList = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
			$LocalAdminListRTB = $LocalAdminList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8LocalAdminListHTML = $LocalAdminList | ConvertTo-Html -As Table -Fragment -PreContent "<h2>8.1 - Grab Local Administrators</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($LocalAdminList)
			}else{
				$AllOutput.AppendText($LocalAdminList)
			}
		# Edge Case (1)
		}catch [Microsoft.PowerShell.Commands.GroupNotFoundException]{
			$Global:Req8LocalAdminListHTML = "<h2>8.1 - Grab Local Administrators</h2><p>Error, Something went wrong. There are no Local Administrator Accounts</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Something went wrong. There are no Local Administrator Accounts.")
			}else{
				$AllOutput.AppendText("`nError, Something went wrong. There are no Local Administrator Accounts.")
			}
		# Edge Case (2)
		}catch{
			$Global:Req8LocalAdminListHTML = "<h2>8.1 - Grab Local Administrators</h2><p>Error, Something went wrong. There are no Local Administrator Accounts</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nError, Something Unexpected went wrong.")
			}else{
				$AllOutput.AppendText("`nError, Something Unexpected went wrong.")
			}
		}
	}

	# 8.1 - Grab Domain Administrator Accounts
	Function Req8GrabDomainAdmins{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1 - Grab Domain & Enterprise Administrators:`n")
		}else{
			$AllOutput.AppendText("8.1 - Grab Domain & Enterprise Administrators:`n")
		}
		# Data Gathering
		try{
			$ADDomainAdminList = Get-ADGroupMember -Identity "Domain Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select-Object Name, Enabled
			$ADEnterpriseAdminList = Get-ADGroupMember -Identity "Enterprise Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select-Object Name, Enabled
			$ADDomainAdminListRTB = $ADDomainAdminList | Format-Table -Autosize | Out-String -Width 1200
			$ADEnterpriseAdminListRTB = $ADEnterpriseAdminList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8ADDomainAdminListHTML = $ADDomainAdminList | ConvertTo-Html -As Table -Property Name, Enabled -Fragment -PreContent "<h2>8.1 - Grab Domain & Enterprise Administrators</h2><h3>Domain Administrators</h3>"
			$Global:Req8ADEnterpriseAdminListHTML = $ADEnterpriseAdminList | ConvertTo-Html -As Table -Property Name, Enabled -Fragment -PreContent "<h3>Enterprise Administrators</h3>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("Domain Administrators:`n" + $ADDomainAdminListRTB)
				$Req8Output.AppendText("Enterprise Administrators:`n" + $ADDomainAdminListRTB)
			}else{
				$AllOutput.AppendText("Domain Administrators:`n" + $ADEnterpriseAdminListRTB)
				$AllOutput.AppendText("Enterprise Administrators:`n" + $ADEnterpriseAdminListRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ADDomainAdminListHTML = "<h2>8.1 - Grab Domain & Enterprise Administrators</h2><h3>Domain Administrators</h3><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			$Global:Req8ADEnterpriseAdminListHTML = "<h3>Enterprise Administrators</h3><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.2.4 - Dump of Users whose Password Never Expire
	Function Req8DumpADUsersPasswordExpiry{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.2.4 - Dump of Users whose Password Never Expires:`n")
		}else{
			$AllOutput.AppendText("8.2.4 - Dump of Users whose Password Never Expires:`n")
		}
		# Data Gathering
		try{
			$ADUserPasswordExpiryList = Search-ADAccount -PasswordNeverExpires -UsersOnly | Select-Object Name, SamAccountName, DistinguishedName, PasswordNeverExpires
			$ADUserPasswordExpiryListRTB = $ADUserPasswordExpiryList | Format-Table -AutoSize | Out-String -Width 1200
			$Global:Req8ADUserPasswordExpiryListHTML = $ADUserPasswordExpiryList | ConvertTo-Html -As Table -Property Name, SamAccountName, DistinguishedName, PasswordNeverExpires -Fragment -PreContent "<h2>8.2.4 - Dump of Users whose Password Never Expires</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserPasswordExpiryListRTB)
			}else{
				$AllOutput.AppendText($ADUserPasswordExpiryListRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ADUserPasswordExpiryListHTML = "<h2>8.2.4 - Dump of Users whose Password Never Expires</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.2.4 - Dump of Users and Their Last Password Change
	Function Req8DumpADUserLastPassChange{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.2.4 - Dump of All AD Users and Their Last Password Change:`n")
		}else{
			$AllOutput.AppendText("8.2.4 - Dump of All AD Users and Their Last Password Change:`n")
		}
		# Data Gathering
		try{
			$ADUserPasswordLastChangeList = Get-aduser -filter * -properties PasswordLastSet, PasswordNeverExpires | Select-Object Name, SamAccountName, DistinguishedName, PasswordLastSet, PasswordNeverExpires | Sort-Object PasswordLastSet,PasswordNeverExpires
			$ADUserPasswordLastChangeListRTB = $ADUserPasswordLastChangeList  | Format-Table -Autosize | Out-String -Width 1200
			$Global:ADUserPasswordLastChangeListHTML = $ADUserPasswordLastChangeList | ConvertTo-Html -As Table -Fragment -PreContent "<h2>8.2.4 - Dump of All AD Users and Their Last Password Change</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($ADUserPasswordLastChangeListRTB)
			}else{
				$AllOutput.AppendText($ADUserPasswordLastChangeListRTB)
			}
		# Edge Case
		}catch{
			$Global:ADUserPasswordLastChangeListHTML = "<h2>8.2.4 - Dump of All AD Users and Their Last Password Change</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.")
			}
		}
	}

	# 8.1.8 - Grab the Screensaver Settings
	Function Req8GrabScreensaverSettings{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.1.8 - Grab of Screensaver Settings:`n")
		}else{
			$AllOutput.AppendText("8.1.8 - Grab of Screensaver Settings:`n")
		}
		# Data Gathering
		try{
			$ScreensaverSettings = Get-Wmiobject win32_desktop | Where-Object Name -match $env:USERNAME
			$ScreensaverSettingsRTB = $ScreensaverSettings | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req8ScreensaverSettingsHTML = $ScreensaverSettings | ConvertTo-Html -As Table -Property Name, ScreenSaverActive, ScreenSaverSecure, ScreenSaverTimeout, SettingID -Fragment -PreContent "<h2>8.1.8 - Grab of Screensaver Settings</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
			 $Req8Output.AppendText($ScreensaverSettingsRTB)
			}else{
				$AllOutput.AppendText($ScreensaverSettingsRTB)
			}
		# Edge Case
		}catch{
			$Global:Req8ScreensaverSettingsHTML = "<h2>8.1.8 - Grab of Screensaver Settings</h2><p>Error, Screensaver Settings not found.</p>"
			if($EverythingToggle -eq $false){
				 $Req8Output.AppendText("`nError, Screensaver Settings not found.")
			}else{
				$AllOutput.AppendText("`nError, Screensaver Settings not found.")
			}
		}	
	}

	# 8.4 - Grab RDP Encryption and Idle Settings
	Function Req8GrabRDPSettings{
		# Write Header
		if($EverythingToggle -eq $false){
		 $Req8Output.AppendText("8.4 - Grab RDP Encryption and Idle Settings:")
		}else{
			$AllOutput.AppendText("8.4 - Grab RDP Encryption and Idle Settings:")
		}
		# Data Gathering - RDP Settings
		try{
			$RDPSettings = Get-WmiObject -Class 'Win32_TSGeneralSetting' -Namespace 'root/CIMV2/TerminalServices' | Select-Object PSComputerName,TerminalName,TerminalProtocol,Certifcates,CertificateName,MinEncryptionLevel,PolicySourceMinEncryptionLevel,PolicySourceSecurityLayer,SecurityLayer | Format-List | Out-String
			$Global:Req8RDPSettingsHTML = "<h2>8.4 - Grab RDP Encryption and Idle Settings</h2><h3>RDP Encryption</h3><pre>" + $RDPSettings + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($RDPSettings)
			}else{
				$AllOutput.AppendText($RDPSettings)
			}
		# Edge Case - RDP Settings
		}catch{
			$Global:Req8RDPSettingsHTML = "<h2>8.4 - Grab RDP Encryption and Idle Settings</h2><p>Error - No RDP Settings Found</p>"
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
			$Global:Req8PowerPlanSettingsHTML = "<h3>Power Plans</h3><pre>" + $PowerPlanSettings + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($PowerPlanSettings)
			}else{
				$AllOutput.AppendText($PowerPlanSettings)
			}
		# Edge Case
		}catch{
			$Global:Req8PowerPlanSettingsHTML = "<h3>Power Plans</h3><p>Error - Unable to find Power Plans, Ensure script is run in Administrator Mode.</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText("Error - Unable to find Power Plans, Ensure script is run in Administrator Mode.")
			}else{
				$AllOutput.AppendText("Error - Unable to find Power Plans, Ensure script is run in Administrator Mode.")
			}
		}
	}

	# onClick Event Handler
		$Req8ScriptList_ListUpdate = {
			if($Req8ScriptList.SelectedItem -eq "8.2 - Grab Domain Password Policy Settings"){
				$Req8Output.Clear()
				Req8DomainPasswordPolicy
			}elseif($Req8ScriptList.SelectedItem -eq "8.2 - Grab Local Password Policy Settings"){
				$Req8Output.Clear()
				Req8LocalPasswordPolicy
			}elseif($Req8ScriptList.SelectedItem -eq "8.1.1 - Dump of Enabled Active Directory Users"){
				$Req8Output.Clear()
				Req8DumpActiveADUsers
			}elseif($Req8ScriptList.SelectedItem -eq "8.1.3 - Dump of Disabled Active Directory Users"){
				$Req8Output.Clear()
				Req8DumpDisabledADUsers
			}elseif($Req8ScriptList.SelectedItem -eq "8.1.4 - Dump of Inactive Active Directory Users"){
				$Req8Output.Clear()
				Req8DumpInactiveADUsers
			}elseif($Req8ScriptList.SelectedItem -eq "8.1 - Grab Current User"){
				$Req8Output.Clear()
				Req8GrabCurrentUser
			}elseif($Req8ScriptList.SelectedItem -eq "8.1 - Grab Local Administrator Accounts"){
				$Req8Output.Clear()
				Req8GrabLocalAdmins
			}elseif($Req8ScriptList.SelectedItem -eq "8.1 - Grab Domain Administrator Accounts"){
				$Req8Output.Clear()
				Req8GrabDomainAdmins
			}elseif($Req8ScriptList.SelectedItem -eq "8.2.4 - Dump of Users whose Password Never Expire"){
				$Req8Output.Clear()
				Req8DumpADUsersPasswordExpiry
			}elseif($Req8ScriptList.SelectedItem -eq "8.2.4 - Dump of Users and Their Last Password Change"){
				$Req8Output.Clear()
				Req8DumpADUserLastPassChange
			}elseif($Req8ScriptList.SelectedItem -eq "8.1.8 - Grab the Screensaver Settings"){
				$Req8Output.Clear()
				Req8GrabScreensaverSettings
			}elseif($Req8ScriptList.SelectedItem -eq "8.4 - Grab RDP Encryption and Idle Settings"){
				$Req8Output.Clear()
				Req8GrabRDPSettings
			}elseif($Req8ScriptList.SelectedItem -eq "Everything in Requirement Eight"){
				$Req8Output.Clear()
				$Req8Output.AppendText("Everything in Requirement Eight`n")
				Req8GrabCurrentUser
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabDomainAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabLocalAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpActiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpDisabledADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpInactiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabScreensaverSettings
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DomainPasswordPolicy
				$Req8Output.AppendText($Global:SectionHeader)
				Req8LocalPasswordPolicy
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpADUsersPasswordExpiry
				$Req8Output.AppendText($Global:SectionHeader)
				Req8DumpADUserLastPassChange
				$Req8Output.AppendText($Global:SectionHeader)
				Req8GrabRDPSettings
				$Req8Output.AppendText($Global:SectionHeader)
			}else{
				$Req8Output.Clear()
				$Req8Output.AppendText("You must select an object from the script list.")
			}
		}

	# Requirement Eight Report Export
	# Build Report Function
	Function Req8ExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementEightName = "<h1 id='RequirementHeader'>PCI DSS Requirement Eight</h1>"
		$Requirement8Report = ConvertTo-HTML -Body "$Global:ReportRequirementEightName $ReportComputerName $Global:Req8CurrentUserHTML $Global:Req8LocalAdminListHTML $Global:Req8ADDomainAdminListHTML $Global:Req8ADEnterpriseAdminListHTML $Global:Req8ADUserListAllHTML $Global:Req8ADUserListDisabledHTML $Global:Req8ADUserListInactiveADUsersHTML $Global:Req8ScreensaverSettingsHTML $Global:Req8CurrentDomainPoliciesHTML $Global:Req8LocalPolicyHTML $Global:Req8ADUserPasswordExpiryListHTML $Global:Req8RDPSettingsHTML $Global:Req8PowerPlanSettingsHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Eight Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement8ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html"
		$Requirement8Report | Out-File $Requirement8ReportPath
		$Req8Output.AppendText("Requirement Eight Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html")
		$Req8EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Eight Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html","Requirement Eight Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$Req8ExportReport = {
			$Req8Output.Clear()
			$Req8Output.AppendText("Writing Report for the Following`n`n")
			Req8GrabCurrentUser
			$Req8Output.AppendText($Global:SectionHeader)
			Req8GrabDomainAdmins
			$Req8Output.AppendText($Global:SectionHeader)
			Req8GrabLocalAdmins
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DumpActiveADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DumpDisabledADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DumpInactiveADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			Req8GrabScreensaverSettings
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DomainPasswordPolicy
			$Req8Output.AppendText($Global:SectionHeader)
			Req8LocalPasswordPolicy
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DumpADUsersPasswordExpiry
			$Req8Output.AppendText($Global:SectionHeader)
			Req8DumpADUserLastPassChange
			$Req8Output.AppendText($Global:SectionHeader)
			Req8GrabRDPSettings
			Req8ExportReportFunction
	}

# Requirement Ten Tab
	# 10.2 - Dump of Audit Category Settings
	Function Req10AuditSettings {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.2 - Dump of Audit Category Settings`n`n")
		}else{
			$AllOutput.AppendText("10.2 - Dump of Audit Category Settings`n`n")
		}
		# Data Gathering
		try{
			$Req10AuditList = auditpol.exe /get /category:* | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req10AuditListHTML = "<h2>10.2 - Dump of Audit Category Settings</h2><pre>"+$Req10AuditList+"</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText($Req10AuditList)
			}else{
				$AllOutput.AppendText($Req10AuditList)
			}
		#Edge Case
		}catch{
			$Global:Req10AuditListHTML = "<h2>10.2 - Dump of Audit Category Settings</h2><p>An Error Has Occurred, Unable to find Audit Category Settings</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("`nAn Error Has Occurred, Unable to find Audit Settings.")
			}else{
				$AllOutput.AppendText("`nAn Error Has Occurred, Unable to find Audit Category Settings.")
			}
		}
	}

	# 10.4 - Grab NTP Settings
	Function Req10NTPSettings {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.4 - Grab NTP Settings for Current Device`n")
		}else{
			$AllOutput.AppendText("10.4 - Grab NTP Settings for Current Device`n")
		}
		# Data Gathering
		try{
			$Req10NTPSettings = w32tm /query /status | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req10NTPSettings = "<h2>10.4 - Grab NTP Settings for Current Device</h2><pre>"+$Req10NTPSettings+"</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText($Req10NTPSettings)
			}else{
				$AllOutput.AppendText($Req10NTPSettings)
			}
		#Edge Case
		}catch{
			$Global:Req10NTPSettings = "<h2>10.4 - Grab NTP Settings for Current Device</h2><p>An Error Has Occurred, Unable to find NTP settings.</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("An Error Has Occurred, Unable to find NTP settings.")
			}else{
				$AllOutput.AppendText("An Error Has Occurred, Unable to find NTP settings.")
			}
		}
	}

	# 10.4 - Grab NTP Settings on Multiple Devices
	Function Req10NTPSettingsMultipleDevices {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.4 - Check NTP Settings on Multiple Devices`nThis may take a while.`n")
		}else{
			$AllOutput.AppendText("10.4 - Check NTP Settings on Multiple Devices`nThis may take a while.`n")
		}
		# Data Gathering
		try{
			# Create Data Array
			$ComputerList = Get-ADComputer -Filter * | Select-Object Name
			$ComputerArray = New-Object System.Collections.ArrayList
			foreach($Computer in $ComputerList){
				$ComputerArray.Add($Computer.Name)
			}
			$ShuffledComputerArray = $ComputerArray | Sort-Object {Get-Random}
			# Implement Counter and Test Four Random Computers in AD
			$Req10Counter = 0
			$Req10NTPSettingsAllStrings = $null
			# Data Gathering
			foreach($RandomComputer in $ShuffledComputerArray){
				$Req10Counter++
				if($Req10Counter -eq 5){
					break
				# If counter is not reached do query below in else statement
				}else{
					try{
						$Req10NTPSettingsTesting = w32tm /query /status /computer:$RandomComputer | Format-Table -Autosize | Out-String -Width 1200
						# Data Output
						$Req10NTPSettingsAllStrings += "<h3>NTP Settings for: " + $RandomComputer + "</h3><pre>" + $Req10NTPSettingsTesting + "</pre>"
						if($EverythingToggle -eq $false){
							$Req10Output.AppendText("`nNTP Settings for: " + $RandomComputer + "`n" + $Req10NTPSettingsTesting)
						}else{
							$AllOutput.AppendText("`nNTP Settings for: " + $RandomComputer + "`n" + $Req10NTPSettingsTesting)
						}
					# Edge Case
					}catch{
						$Req10NTPSettingsAllStrings += "<h3>NTP Settings for: " + $RandomComputer + "</h3><p>Unable to find NTP settings</p>"
						if($EverythingToggle -eq $false){
							$Req10Output.AppendText("Unable to find NTP settings.")
						}else{
							$AllOutput.AppendText("Unable to find NTP settings.")
						}
					}
				}
			}
			# Output for HTML
			$Global:Req10NTPSettingsAllDevices = "<h2>10.4 - Check NTP Settings on Multiple Devices</h2>" + $Req10NTPSettingsAllStrings
		# Edge Case (Non-DC)
		}catch{
			$Global:Req10NTPSettingsAllDevices = "<h2>10.4 - Check NTP Settings on Multiple Devices</h2><p>Unable to contact Active Directory, Ensure the script is run on a DC.</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}else{
				$AllOutput.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}
		}
	}

	# 10.5 - Check Audit Log Permissions
	Function Req10AuditLogPrems {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.5 - Check Audit Log Permissions`nListed below are the Domain & Enterprise Administrators:`n")
		}else{
			$AllOutput.AppendText("10.5 - Check Audit Log Permissions`nListed below are the Domain & Enterprise Administrators:`n")
		}
		# Data Gathering
		try{
			$ADDomainAdminList = Get-ADGroupMember -Identity "Domain Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled
			$ADEnterpriseAdminList = Get-ADGroupMember -Identity "Enterprise Admins" -Recursive | %{Get-ADUser -Identity $_.distinguishedName} | Select Name, Enabled
			$ADDomainAdminListRTB = $ADDomainAdminList | Format-Table -Autosize | Out-String -Width 1200
			$ADEnterpriseAdminListRTB = $ADEnterpriseAdminList |  Format-Table -Autosize | Out-String -Width 1200
			$Global:Req10ADDomainAdminListHTML = $ADDomainAdminList | ConvertTo-Html -As Table -Property Name, Enabled -Fragment -PreContent "<h2>10.5 - Check Audit Log Permissions</h2><p>Listed below are the Domain & Enterprise Administrators. Check GPO Dump for more infomation.</p><h3>Domain Administrators</h3>"
			$Global:Req10ADEnterpriseAdminListHTML = $ADEnterpriseAdminList | ConvertTo-Html -As Table -Property Name, Enabled -Fragment -PreContent "<h3>Enterprise Administrators</h3>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("Domain Admins:`n" + $ADDomainAdminListRTB)
				$Req10Output.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminListRTB)
			}else{
				$AllOutput.AppendText("Domain Admins:`n" + $ADDomainAdminListRTB)
				$AllOutput.AppendText("Enterprise Admins:`n" + $ADEnterpriseAdminListRTB)
			}
		# Edge Case (Non-DC)
		}catch{
			$Global:Req10ADDomainAdminListHTML =  "<h2>10.5 - Check Audit Log Permissions</h2><h3>Domain Administrators</h3><p>Unable to contact Active Directory, Ensure the script is run on a DC.</p>"
			$Global:Req10ADEnterpriseAdminListHTML = "<h3>Enterprise Administrators</h3><p>Unable to contact Active Directory, Ensure the script is run on a DC.</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}else{
				$AllOutput.AppendText("Unable to contact Active Directory, Ensure the script is run on a DC.")
			}
		}
		# GPO Dump Output, Only for Requirement 10, Extra for Audit Log Premissions. GPO dump in everything/all tab is included later on.
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10Output.AppendText("GPO Dump for further analysis.")
			$Req10Output.AppendText($global:GPODump)
		}else{
			$AllOutput.AppendText($Global:SectionHeader)
			$AllOutput.AppendText("Check GPO Dump for further analysis.")
		}
	}

	# 10.7 - Grab Previous Audit Logs
	Function Req10PastAuditLogs {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.7 - Grabbing Previous Audit Logs for the Past Three Months`nThis may take a while`n")
		}else{
			$AllOutput.AppendText("10.7 - Grabbing Previous Audit Logs for the Past Three Months`nThis may take a while`n")
		}
		# Data Gathering, Wait so Header is written.
		$AuditLogsBegin = (Get-Date).AddDays(-90)
		$AuditLogsEnd = Get-Date
		Start-Sleep -Seconds 0.5
		try{
			$Global:AuditLogs = Get-EventLog -LogName Security -Source "*auditing*" -After $AuditLogsBegin -Before $AuditLogsEnd | Select-Object Index,Time,EntryType,InstanceID,Message | Format-List | Out-String
			$AuditLogsRecent = Get-EventLog -LogName Security -Source "*auditing*" -Newest 1000 | Select-Object Index,Time,EntryType,InstanceID,Message | Format-List | Out-String
			$Global:Req10AllAuditLogs = "<h2>10.7 - Grabbing Previous Audit Logs for the Past Three Months</h2><h3>1000 Most Recent Entries Displayed</h3><p>View All Audit Log Entries for the Past Three Months in the Exported Text File " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Audit-Logs.txt" + "</p><br><pre>" + $AuditLogsRecent + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText($AuditLogsRecent)
			}else{
				$AllOutput.AppendText($AuditLogsRecent)
			}
		# Edge Case
		}catch{
			$Global:Req10AllAuditLogs = "<h2>10.7 - Grabbing Previous Audit Logs for the Past Three Months</h2><p>An Error Has Occurred, No Audit Logs Found.</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("An Error Has Occurred, No Audit Logs Found.")
			}else{
				$AllOutput.AppendText("An Error Has Occurred, No Audit Logs Found.")
			}
		}
	}

	#onClick event handler
	$Req10ScriptList_ListUpdate = {
		if($Req10ScriptList.SelectedItem -eq "10.2 - Dump of Audit Category Settings"){
			$Req10Output.Clear()
			Req10AuditSettings
		}elseif($Req10ScriptList.SelectedItem -eq "10.4 - Grab NTP Settings"){
			$Req10Output.Clear()
			Req10NTPSettings
		}elseif($Req10ScriptList.SelectedItem -eq "10.4 - Check NTP Settings on Multiple Devices"){
			$Req10Output.Clear()
			Req10NTPSettingsMultipleDevices
		}elseif($Req10ScriptList.SelectedItem -eq "10.5 - Check Audit Log Permissions"){
			$Req10Output.Clear()
			Req10AuditLogPrems
		}elseif($Req10ScriptList.SelectedItem -eq "10.7 - Grab Previous Audit Logs"){
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

	# Requirement Ten Report Export
	# Build Report Function
	Function Req10ExportReportFunction {
		# HTML Report
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportRequirementTenName = "<h1 id='RequirementHeader'>PCI DSS Requirement Ten</h1>"
		$Requirement10Report = ConvertTo-HTML -Body "$Global:ReportRequirementTenName $ReportComputerName $Global:Req10AuditListHTML $Global:Req10NTPSettings $Global:Req10NTPSettingsAllDevices $Global:Req10ADDomainAdminListHTML $Global:Req10ADEnterpriseAdminListHTML $Global:GPODumpHTML $Global:Req10AllAuditLogs" -Head $CSSHeader -Title "PCI DSS Requirement Ten Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$Requirement10ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Report.html"
		$Requirement10Report | Out-File $Requirement10ReportPath
		# Audit Logs Text File
		$AllAuditLogs = "Grabbing Previous Audit Logs for the Past Three Months.`n" + $Global:AuditLogs 
		$Requirement10ReportPathLogs = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Audit-Logs.txt"
		$AllAuditLogs | Out-File $Requirement10ReportPathLogs
		# Write Output
		$Req10Output.AppendText("Requirement Ten Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Report.html")
		$Req10Output.AppendText("Requirement Ten Audit Logs Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Audit-Logs.txt")
		$Req10EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Ten Report Exported to: " + $Requirement10ReportPath + "`n`nRequirement Ten Audit Logs Exported to: " + $Requirement10ReportPathLogs,"Requirement Ten Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$Req10ExportReport = {
			$Req10Output.Clear()
			$Req10Output.AppendText("Writing Report for the Following`n`n")
			Req10AuditSettings
			$Req10Output.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$Req10Output.AppendText($Global:SectionHeader)
			Req10NTPSettingsMultipleDevices
			$Req10Output.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$Req10Output.AppendText($Global:SectionHeader)
			Req10PastAuditLogs
			Req10ExportReportFunction
	}

# Diagnostics Tab
	#Grab System Information
	Function DiagSysInfo{
		# Write Header
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("Grab System Information`n")
		}else{
			$AllOutput.AppendText("Grab System Information`n")
		}
		# Data Gathering
		try{
			$SystemInfoData = systeminfo | Out-String
			$Global:DiagSystemInfoDataHTML = "<h2>Grab System Information</h2><pre>" + $SystemInfoData + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText($SystemInfoData)
			}else{
				$AllOutput.AppendText($SystemInfoData)
			}
		# Edge Case
		}catch{
			$Global:DiagSystemInfoDataHTML = "<h2>Grab System Information</h2><p>Unable to Grab System Infomation</p>"
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Unable to Grab System Infomation`n")
			}else{
				$AllOutput.AppendText("Unable to Grab System Infomation`n")
			}
		}
	}

	#Grab Installed Software Patches
	Function DiagInstalledUpdates {
		# Write Header
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("Grab Installed Software Patches`n")
		}else{
			$AllOutput.AppendText("Grab Installed Software Patches`n")
		}
		# Data Gathering
		try{
			$UpdateData = Get-HotFix
			$UpdateDataRTB = $UpdateData | Format-Table -AutoSize | Out-String
			$Global:DiagInstalledUpdatesDataHTML = $UpdateData | ConvertTo-Html -As Table -Property Source,Description,HotFixID,InstalledBy,InstalledOn -Fragment -PreContent "<h2>Grab Installed Software Patches</h2>"
			# Data Output
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText($UpdateDataRTB)
			}else{
				$AllOutput.AppendText($UpdateDataRTB)
			}
		# Edge Case
		}catch{
			$Global:DiagInstalledUpdatesDataHTML = "<h2>Grab Installed Software Patches</h2><p>Unable to Grab Installed Software Patches</p>"
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Unable to Grab Installed Software Patches`n")
			}else{
				$AllOutput.AppendText("Unable to Grab Installed Software Patches`n")
			}
		}
	}

	#Grab IP Config
	Function DiagIPConfig {
		# Write Header
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("Grab IP Config`n")
		}else{
			$AllOutput.AppendText("Grab IP Config`n")
		}
		# Data Gathering
		try{
			$IPConfigData = ipconfig /all | Out-String
			$Global:DiagIPConfigHTML = "<h2>Grab IP Config</h2><pre>" + $IPConfigData + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText($IPConfigData)
			}else{
				$AllOutput.AppendText($IPConfigData)
			}
		# Edge Case
		}catch{
			$Global:DiagIPConfigHTML = "<h2>Grab IP Config</h2><p>Unable to Grab IP Config</p>"
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Unable to Grab IP Config`n")
			}else{
				$AllOutput.AppendText("Unable to Grab IP Config`n")
			}
		}
	}

	#Check TCP Connectivity
	Function DiagTCPConnectivity {
		# Write Header
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("Check TCP Connectivity`nThis may take awhile.`n`n")
		}else{
			$AllOutput.AppendText("Check TCP Connectivity`nThis may take awhile.`n`n")
		}
		# Data Gathering
		try{
			$PingTest = ping "www.google.com" | Out-String
			$TraceRouteTest = tracert "www.google.com" | Out-String
			$Global:DiagPingTestHTML = "<h2>Check TCP Connectivity</h2><h3>Ping To www.google.com</h3><pre>" + $PingTest + "</pre>"
			$Global:DiagTraceRouteHTML = "<h3>Trace Route to www.google.com</h3><pre>" + $TraceRouteTest + "</pre>"
			# Data Output
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Ping & Trace Route to www.google.com `n" + $PingTest + "`n" + $TraceRouteTest)
			}else{
				$AllOutput.AppendText("Ping & Trace Route to www.google.com `n" + $PingTest + "`n" + $TraceRouteTest)
			}
		# Edge Case
		}catch{
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Unable to Check TCP Connectivity`n")
			}else{
				$AllOutput.AppendText("Unable to Check TCP Connectivity`n")
			}
		}
	}

	#Dedicated GPO Dump
	Function DiagGPODump {
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("GPO Dump")
			$DiagOutput.AppendText($global:GPODump)
		}else{
			$AllOutput.AppendText("GPO Dump")
			$AllOutput.AppendText($global:GPODump)
		}
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

	# Diagnostics Report Export
	# Build Report Function
	Function DiagExportReportFunction {
		$ReportComputerName = "<h1>Computer name: $env:computername</h1>"
		$Global:ReportDiagRequirementName = "<h1 id='RequirementHeader'>PCI DSS Diagnostics Report</h1>"
		$DiagReport = ConvertTo-HTML -Body "$Global:ReportDiagRequirementName $ReportComputerName $Global:DiagSystemInfoDataHTML $Global:DiagInstalledUpdatesDataHTML $Global:DiagIPConfigHTML $Global:DiagPingTestHTML $Global:DiagTraceRouteHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Ten Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Securities Version $Global:ProgramVersionCode.<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design.</p>"
		$DiagReportPath = $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html"
		$DiagReport | Out-File $DiagReportPath
		$DiagOutput.AppendText("`nDiagnostics Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html")
		$DiagEndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Diagnostics Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html","Diagnostics Report Exported Successfully",[System.Windows.MessageBoxButton]::OK,[System.Windows.MessageBoxImage]::Information)
	}
	# onClick Event Handler to Gather Data for Report
	$DiagExportReport = {
			$DiagOutput.Clear()
			$DiagOutput.AppendText("Writing Report for the Following`n`n")
			DiagSysInfo
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagInstalledUpdates
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagIPConfig
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagTCPConnectivity
			$DiagOutput.AppendText($Global:SectionHeader)
			DiagGPODump
			DiagExportReportFunction
	}

#Join Path for Resources
$resources = . (Join-Path $PSScriptRoot 'Resources.ps1')

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')