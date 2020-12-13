# Anordium Audits #
# Add Required Dot Net Assemblies
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing, System.DirectoryServices.AccountManagement

# Internal Testing Switch, Predefine Export Folder and Skip Main Window
#$TestingSwitch = $true
$TestingSwitch = $false
# Predefined Export Path, Only if $TestingSwitch = $true
if($TestingSwitch -eq $true){
	$UserInputPath = "Z:\Release"
	Write-Host "Debug Mode Enabled, Exporting to $UserInputPath"
}

#Join Path for CSS Code in the Report, Required for HTML Exporting
. (Join-Path $PSScriptRoot 'CSSReport.ps1')

# Check Script Rights & Ensure is in Administrator Mode
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
	# Relaunch as an elevated process:
	Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
	exit
}

# Test Connection
try{
	$CurrentDomain = Get-ADDomainController -ErrorAction Stop
	$PSHostInfo = Get-Host
	Write-Host "Current DC:"$CurrentDomain.Name
	Write-Host "Domain:"$CurrentDomain.Domain
	Write-Host "Forest:"$CurrentDomain.Forest
	Write-Host "Installed PowerShell Version:" $PSHostInfo.Version
	Write-Host ""
	$Global:TestDCConnection = $true
}catch{
	$PSHostInfo = Get-Host
	Write-Host "Warning: No Active Directory Domain Detected, Unsupported Configuration!!!"
	Write-Host "Installed PowerShell Version:" $PSHostInfo.Version
	$Global:TestDCConnection = $false
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
		$Global:GPOExportPathLocation = $Global:ExportPathLocation + "\GPO-Report.html"
		gpresult.exe /SCOPE COMPUTER /f /h $Global:GPOExportPathLocation
		$AllOutput.AppendText("GPO Report Exported to: " + $Global:ExportPathLocation + "\GPO-Report.html")
		$Global:GPOExportReportStatus = $true
	}catch{
		$Global:GPOExportReportStatus = $false
	}
	# Global System Settings
	try{
		$Global:SecExportPathLocation = $Global:ExportPathLocation + "\Secpol.cfg"
		SecEdit.exe /export /cfg $Global:SecExportPathLocation
		$Global:SecDump = Get-Content -Path $Global:SecExportPathLocation
		$AllOutput.AppendText("`nLocal Security Policy Exported to: " + $Global:SecExportPathLocation)
		$Global:SecPolExportStatus = $true
	}catch{
		$Global:SecPolExportStatus = $false
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
	if($TestingSwitch -eq $false){
		$UserInputPath = $MainForm.MainUserInput.Text
	}
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
	$MainFormOutput.AppendText("Created by Team Anordium Securities - Cianaa Technologies Research Internees and is composed of;`n")
	$MainFormOutput.AppendText("`nMatthew Westlake - west356@manukaumail.com`nMicheal Chen - Email: anordium@chencorp.co.nz`nRahnuma Khan`nRyan Alpay - Email: ryanmatthew.alpay@mail.com`nTim Sun - Email: timsun90@gmail.com`n")
	$MainFormOutput.AppendText("`nAnordium Audits Version " + $Global:ProgramVersionCode + " - " + $Global:ProgramVersionDate +"`n")
	$MainFormOutput.AppendText("`nSpecial Thanks to Dan from Adam the Automator for the CSS table design, W3Schools for the Scroll to Top Feature, Tips and Tricks HQ for the Table of Contents Design and Brian Clanton & Max Kozlov from PowerShell.org for the Deny All Example Code.")
	$MainFormOutput.AppendText("`n`nhttps://adamtheautomator.com/powershell-convertto-html/`nhttps://www.w3schools.com/howto/howto_js_scroll_to_top.asp`nhttps://www.tipsandtricks-hq.com/simple-table-of-contents-toc-using-pure-html-and-css-code-9217`nhttps://powershell.org/forums/topic/find-deny-rights-on-a-list-of-folders/")
	$MainFormOutput.AppendText("`n`n-------------------------------------------------------------------------------------------------------------------------------------------------`n`nMIT License`n`nCopyright (c) 2020 Anordium Securities`n`nPermission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the `"Software`"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:`n`nThe above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.`n`nTHE SOFTWARE IS PROVIDED `"AS IS`", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.")
}
# HTML Credits
$CreditsForHTML = "Team Anordium Securities - Cianaa Technologies Research Internees<br>Special Thanks to <a href='https://adamtheautomator.com/powershell-convertto-html/'>Dan</a> from Adam the Automator for the CSS table design, <a href='https://www.w3schools.com/howto/howto_js_scroll_to_top.asp'>W3Schools</a> for the Scroll to Top Feature, <a href='https://www.tipsandtricks-hq.com/simple-table-of-contents-toc-using-pure-html-and-css-code-9217'>Tips and Tricks HQ</a> for the Table of Contents Design and <a href='https://powershell.org/forums/topic/find-deny-rights-on-a-list-of-folders/'>Brian Clanton & Max Kozlov</a> for the Deny All Example Code."
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
$EverythingExportingSwitch = $false
$Req2EverythingSwitch = $false
$Req2ExportingSwitch = $false
$Global:SectionHeader = "`n`n-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-`n`n"
$Global:SectionBreak = "`n`n---------------------------------------------------------------------------------------------------------`n`n"

# Version Number and Release Date
$Global:ProgramVersionCode = "1.9.0"
$Global:ProgramVersionDate = "13th December 2020"

$AllScriptList_ListUpdate = {
	if($AllScriptList.SelectedItem -eq "Everything"){
		$AllOutput.Clear()
		$EverythingToggle = $true
		# Getting Ready
			$AllOutput.AppendText("Gathering Information for Everything.`nBe patient and do not tab away. This may take A While. `n")
			$AllOutput.AppendText($Global:SectionBreak)
		#Call Requirement Two Functions
			$AllOutput.AppendText("Everything in Requirement Two `n")
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Two... Total Progress... 0%"
			$AllScriptOutputLabel.Refresh()
			Req2ComplianceChecker
			$AllOutput.AppendText($Global:SectionHeader)
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
			Req7UserPrivileges
			$AllOutput.AppendText($Global:SectionHeader)
			Req7UserRightsAssessment
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
			Req8PasswordChecker
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
			Req10AuditLogsCompliance
			$AllOutput.AppendText($Global:SectionHeader)
			Req10InvalidLoginsAttempts
			$AllOutput.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Ten... Grabbing NTP Settings on Multiple Devices, This Will Take A While. Total Progress... 80%"
			$AllScriptOutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$AllOutput.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Gathering Data for Requirement Ten... Total Progress... 85%"
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
			$EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Script Completed Successfully","Script Completed Successfully","OK","Information")
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
		$Global:ReportRequirementTwoName = "<h1 id='Req2'>PCI DSS Requirement Two</h1>"
		$Global:ReportRequirementFourName = "<h1 id='Req4'>PCI DSS Requirement Four</h1>"
		$Global:ReportRequirementFiveName = "<h1 id='Req5'>PCI DSS Requirement Five</h1>"
		$Global:ReportRequirementSevenName = "<h1 id='Req7'>PCI DSS Requirement Seven</h1>"
		$Global:ReportRequirementEightName = "<h1 id='Req8'>PCI DSS Requirement Eight</h1>"
		$Global:ReportRequirementTenName = "<h1 id='Req10'>PCI DSS Requirement Ten</h1>"
		$Global:ReportDiagRequirementName = "<h1 id='ReqDiag'>PCI DSS Diagnostics Report</h1>"
		$Global:ToCHTML = "<div id=`"toc_container`"`><p class=`"toc_title`">Contents</p><li><a href=`"#Req2`">PCI DSS Requirement Two</a></li><li><a href=`"#Req4`">PCI DSS Requirement Four</a></li><li><a href=`"#Req5`">PCI DSS Requirement Five</a></li><li><a href=`"#Req7`">PCI DSS Requirement Seven</a></li><li><a href=`"#Req8`">PCI DSS Requirement Eight</a></li><li><a href=`"#Req10`">PCI DSS Requirement Ten</a></li><li><a href=`"#ReqDiag`">PCI DSS Diagnostics Report</a></li></ul></div>"
		$RequirementAllReport = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $ReportAllName $ReportComputerName $Global:ToCHTML $Global:ReportRequirementTwoName $Global:Req2PCIDSSComplianceResultHTML $Global:Req2CISComplianceResultHTMLFinal $Global:Req2UserCredentialResult $Global:Req2FeatureListHTML $Global:Req2ProcessListHTML $Global:Req2SvcListRunningHTML $Global:Req2SvcListListeningHTML $Global:Req2UDPListHTML $Global:Req2SoftwareList32BitHTML $Global:Req2SoftwareList64BitHTML $Global:Req2LocalDrivesHTML $Global:Req2LocalDrivesExtraHTML $Global:Req2LocalNetworkSharesHTML $Global:Req2ADComputerListAll $Global:Req2IPV4AdaptersHTML $Global:Req2IPV4NeighborsHTML $Global:Req2IPV6AdaptersHTML $Global:Req2IPV6NeighborsHTML $Global:ReportRequirementFourName $Global:Req4WifiListHTML $Global:Req4LocalMachineCertsHTML $Global:Req4CurrentUserCertsHTML $Global:ReportRequirementFiveName $Global:Req5AVProgramQueryHTML $Global:Req5SoftwareDeploymentHTML $Global:Req5AVPermsHTML $Global:ReportRequirementSevenName $Global:Req7LocalFolderPermsHTML $Global:Req7SambaShareStatusHTML $Global:Req7FolderPermsHTML $Global:Req7GroupMembershipListHTML $Global:Req7UserRightsHTML $Global:ReportRequirementEightName $Global:Req8CurrentUserHTML $Global:Req8LocalAdminListHTML $Global:Req8ADDomainAdminListHTML $Global:Req8ADEnterpriseAdminListHTML $Global:Req8ADUserListAllHTML $Global:Req8ADUserListDisabledHTML $Global:Req8ADUserListInactiveADUsersHTML $Global:Req8ScreensaverSettingsHTML $Global:Req8CurrentDomainPoliciesHTML $Global:Req8LocalPolicyHTML $Global:Req8PCIDSSPassCheckResultHTML $Global:PCIDSSPassCheckToalResultHTML $Global:Req8ADUserPasswordExpiryListHTML $Global:Req8RDPSettingsHTML $Global:Req8RDPComplianceHTML $Global:Req8PowerPlanSettingsHTML $Global:ReportRequirementTenName $Global:Req10AuditListHTML $Global:Req10PCIPSSComplianceResultHTML $Global:Req10UserLoginFailureResult $Global:Req10NTPSettings $Global:Req10NTPSettingsAllDevices $Global:Req10ADDomainAdminListHTML $Global:Req10ADEnterpriseAdminListHTML $Global:Req10AllAuditLogs $Global:ReportDiagRequirementName $Global:DiagSystemInfoDataHTML $Global:DiagInstalledUpdatesDataHTML $Global:DiagIPConfigHTML $Global:DiagPingTestHTML $Global:DiagTraceRouteHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS All Requirements Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$RequirementAllReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html"
		$RequirementAllReport | Out-File $RequirementAllReportPath
		$AllOutput.AppendText("`nAll PCI-DSS Requirements Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html")
		# Alert User
		$Req10EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("All PCI-DSS Requirements Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-All-Report.html","All PCI-DSS Requirements Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$AllExportReport = {
			$AllOutput.Clear()
			$AllOutput.AppendText("Writing Report for the Following`n`nBe patient and do not tab away. This may take A While.")
			$EverythingToggle = $true
			$EverythingExportingSwitch = $true
			$AllOutput.AppendText($Global:SectionBreak)
		#Call Requirement Two Functions
			$AllOutput.AppendText("Everything in Requirement Two `n")
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Two... Total Progress... 0%"
			$AllScriptOutputLabel.Refresh()
			Req2ComplianceChecker
			$AllOutput.AppendText($Global:SectionHeader)
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
			#Req2GrabSysConfig
			#$AllOutput.AppendText($Global:SectionHeader)
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
			Req7UserPrivileges
			$AllOutput.AppendText($Global:SectionHeader)
			Req7UserRightsAssessment
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
			Req8PasswordChecker
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
			Req10AuditLogsCompliance
			$AllOutput.AppendText($Global:SectionHeader)
			Req10InvalidLoginsAttempts
			$AllOutput.AppendText($Global:SectionHeader)
			Req10NTPSettings
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Ten, Grabbing NTP Settings on Multiple Devices, This Will Take A While.... Total Progress... 80%"
			$AllScriptOutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$AllOutput.AppendText($Global:SectionHeader)
			Req10AuditLogPrems
			$AllOutput.AppendText($Global:SectionHeader)
			$AllScriptOutputLabel.Text = "Output: Data Export in Progress. Working on Requirement Ten... Total Progress... 85%"
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
			$EverythingExportingSwitch = $false
	}

# Requirement Two Tab #
	# Requirement Two Compliance Check
	Function Req2ComplianceChecker {
		# Run All Functions To Gather Data
			if($EverythingToggle -eq $false){
				if(($Req2EverythingSwitch -eq $false) -and ($Req2ExportingSwitch -eq $false)){
					$Req2Output.AppendText("Gathering Compliance in Requirement Two `n")
					$Req2OutputLabel.Text = "Output: Progressing... 1%"
					$Req2OutputLabel.Refresh()
					Req2TestDefaultAccounts
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabInstalledFeatures
					$Req2Output.AppendText($Global:SectionHeader)
					$Req2OutputLabel.Text = "Output: Progressing... 3%"
					$Req2OutputLabel.Refresh()
					Req2RunningProcesses
					$Req2Output.AppendText($Global:SectionHeader)
					$Req2OutputLabel.Text = "Output: Progressing... 5%"
					$Req2OutputLabel.Refresh()
					Req2RunningServices
					$Req2Output.AppendText($Global:SectionHeader)
					$Req2OutputLabel.Text = "Output: Progressing... 7%"
					$Req2OutputLabel.Refresh()
					Req2GrabInstalledSoftware
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabDrivesAndShares
					$Req2OutputLabel.Text = "Output: Progressing... 9%"
					$Req2OutputLabel.Refresh()
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabADComputers
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabSysConfig
					$Req2OutputLabel.Text = "Output:"
					$Req2OutputLabel.Refresh()
					$Req2Output.Clear()
				}else{
					$Req2Output.AppendText("Gathering Compliance in Requirement Two `n")
					Req2TestDefaultAccounts
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabInstalledFeatures
					$Req2Output.AppendText($Global:SectionHeader)
					Req2RunningProcesses
					$Req2Output.AppendText($Global:SectionHeader)
					Req2RunningServices
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabInstalledSoftware
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabDrivesAndShares
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabADComputers
					$Req2Output.AppendText($Global:SectionHeader)
					Req2GrabSysConfig
					$Req2Output.Clear()
				}
			}else{
				$AllOutput.AppendText("Gathering Compliance in Requirement Two `n")
				$AllScriptOutputLabel.Text = "Output: Progressing... 1%"
				$AllScriptOutputLabel.Refresh()
				Req2TestDefaultAccounts
				$AllOutput.AppendText($Global:SectionHeader)
				Req2GrabInstalledFeatures
				$AllOutput.AppendText($Global:SectionHeader)
				$AllScriptOutputLabel.Text = "Output: Progressing... 3%"
				$AllScriptOutputLabel.Refresh()
				Req2RunningProcesses
				$AllOutput.AppendText($Global:SectionHeader)
				$AllScriptOutputLabel.Text = "Output: Progressing... 5%"
				$AllScriptOutputLabel.Refresh()
				Req2RunningServices
				$AllOutput.AppendText($Global:SectionHeader)
				$AllScriptOutputLabel.Text = "Output: Progressing... 7%"
				$AllScriptOutputLabel.Refresh()
				Req2GrabInstalledSoftware
				$AllOutput.AppendText($Global:SectionHeader)
				Req2GrabDrivesAndShares
				$AllScriptOutputLabel.Text = "Output: Progressing... 9%"
				$AllScriptOutputLabel.Refresh()
				$AllOutput.AppendText($Global:SectionHeader)
				Req2GrabADComputers
				$AllOutput.AppendText($Global:SectionHeader)
				Req2GrabSysConfig
				$AuxiliaryForm.AllOutput.Clear()
			}
		# Write Header and Results
		if($EverythingToggle -eq $false){
			if(($Req2EverythingSwitch -eq $true) -and ($Req2ExportingSwitch -eq $false)){
				$Req2Output.AppendText("Everything in Requirement Two `n")
				$Req2Output.AppendText("Requirement Two Compliance Check.`n`n")
			}elseif($Req2ExportingSwitch -eq $true){
				$Req2Output.AppendText("Writing Report for the Following:`n`nEverything in Requirement Two `n")
				$Req2Output.AppendText("Requirement Two Compliance Check.`n`n")
			}else{
				$Req2Output.AppendText("Requirement Two Compliance Check.`n`n")
			}
			$Req2Output.AppendText($Global:Req2VendorPassResult)
			$Req2Output.AppendText($Global:Req2FeatureResult)
			$Req2Output.AppendText($Global:Req2FeatureResultTotal)
			$Req2Output.AppendText($Global:RunningProcessesResult)
			$Req2Output.AppendText($Global:RunningServicesResult)
			$Req2Output.AppendText($Global:32BitAppsResult)
			$Req2Output.AppendText($Global:64BitAppsResult)
			$Req2Output.AppendText("`n2.2.4 - Audit System Security Policy`nThe Following Sub-Sections are directly from the CIS Benchmarks`n")
			#2.2.4 (CIS)
			# 1.1 Password Policy
			$Req2Output.AppendText("`n1.1 Password Policy`n")
			$Req2Output.AppendText($Global:Req2EnforcePasswordHistoryResult)
			$Req2Output.AppendText($Global:Req2MaximumPasswordAgeResult)
			$Req2Output.AppendText($Global:Req2MinimumPasswordAgeResult)
			$Req2Output.AppendText($Global:Req2MinimumPasswordLengthResult)
			$Req2Output.AppendText($Global:Req2PasswordComplexityReqsResult)
			$Req2Output.AppendText($Global:Req2ClearTextPasswordSettingResult)
			# 1.2 Account Lockout Policy
			$Req2Output.AppendText("`n1.2 Account Lockout Policy`n")
			$Req2Output.AppendText($Global:Req2AccountLockoutDurationResult)
			$Req2Output.AppendText($Global:Req2AccountLockoutThresholdResult)
			$Req2Output.AppendText($Global:Req2ResetAccountLockoutCounterResult)
			# 2.3.1 - Accounts
			$Req2Output.AppendText("`n2.3.1 Accounts`n")
			$Req2Output.AppendText($Global:Req2DisabledAdminResult)
			$Req2Output.AppendText($Global:Req2BlockMSAccountsResult)
			$Req2Output.AppendText($Global:Req2DisabledGuestResult)
			$Req2Output.AppendText($Global:Req2LimitBlankPassUseResult)
			$Req2Output.AppendText($Global:Req2RenameAdminResult)
			$Req2Output.AppendText($Global:Req2RenameGuestResult)
			# 2.3.2 Audits
			$Req2Output.AppendText("`n2.3.2 Audits`n")
			$Req2Output.AppendText($Global:Req2ForceAuditPolicyOverrideResult)
			$Req2Output.AppendText($Global:Req2ShutdownAuditSettingsResult)
			# 2.3.4 - Devices
			$Req2Output.AppendText("`n2.3.4 Devices`n")
			$Req2Output.AppendText($Global:Req2RestrictUserUndockingResult)
			$Req2Output.AppendText($Global:Req2RestrictCDRomsResult)
			$Req2Output.AppendText($Global:Req2RestrictFloppiesResult)
			$Req2Output.AppendText($Global:Req2LimitRemoveableMediaResult)
			$Req2Output.AppendText($Global:Req2LimitPrinterDriversResult)
			# 2.3.5 Domain controller
			$Req2Output.AppendText("`n2.3.5 Domain controller`n")
			$Req2Output.AppendText($Global:Req2ServerOpsScheduleTasksResult)
			$Req2Output.AppendText($Global:Req2DCRefuseMachineAccountChangesResult)
			# 2.3.6 - Domain Member
			$Req2Output.AppendText("`n2.3.6 Domain Member`n")
			$Req2Output.AppendText($Global:Req2DigitalEncryptSignResult)
			$Req2Output.AppendText($Global:Req2DigitalSecureChannel)
			$Req2Output.AppendText($Global:Req2DigitalSecureChannelSigned)
			$Req2Output.AppendText($Global:Req2DisableMachinePassChangeResult)
			$Req2Output.AppendText($Global:Req2MaxMachinePassAgeResult)
			$Req2Output.AppendText($Global:Req2StrongSessionKeyResult)
			# 2.3.7 - Interactive Login
			$Req2Output.AppendText("`n2.3.7 Interactive Login`n")
			$Req2Output.AppendText($Global:Req2LoginCntlAltDelStatusResult)
			$Req2Output.AppendText($Global:Req2DontDisplayLastUser)
			$Req2Output.AppendText($Global:Req2MachineAFKLimitResult)
			$Req2Output.AppendText($Global:Req2LegalNoticeTextResult)
			$Req2Output.AppendText($Global:Req2LegalNoticeCaptionResult)
			$Req2Output.AppendText($Global:Req2PreviousCachedLogonsResult)
			$Req2Output.AppendText($Global:Req2PassExpiryWarningResult)
			$Req2Output.AppendText($Global:Req2DCAuthUnlockResult)
			$Req2Output.AppendText($Global:Req2SmartCardRemovalResult)
			# 2.3.8 Microsoft Network Client
			$Req2Output.AppendText("`n2.3.8 Microsoft Network Client`n")
			$Req2Output.AppendText($Global:Req2DigitallySignAlwaysResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsServerResult)
			$Req2Output.AppendText($Global:Req2EnablePlainTextResult)
			# 2.3.9 Microsoft network server
			$Req2Output.AppendText("`n2.3.9 Microsoft network server`n")
			$Req2Output.AppendText($Global:Req2SuspendingSessionIdleTimeResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsForcedResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsClientResult)
			$Req2Output.AppendText($Global:Req2ForcedClientLogoffResult)
			# 2.3.10 Network access
			$Req2Output.AppendText("`n2.3.10 Network access`n")
			$Req2Output.AppendText($Global:Req2SIDNameLookupResult)
			$Req2Output.AppendText($Global:Req2RestrictAnonymousSAMResult)
			$Req2Output.AppendText($Global:Req2AnonymousEmuerationAccountsResult)
			$Req2Output.AppendText($Global:Req2StorageOfPasswordsResult)
			$Req2Output.AppendText($Global:Req2AllIncludesPoliciesResult)
			$Req2Output.AppendText($Global:Req2AnonymousNamedPipesResult)
			$Req2Output.AppendText($Global:Req2AllowedExactPathsResult)
			$Req2Output.AppendText($Global:Req2RestrictAnnonymousAccessSessionsResult)
			$Req2Output.AppendText($Global:Req2NullSessionShares)
			$Req2Output.AppendText($Global:Req2SharingAndSecModelLocalAccountsResult)
			# 2.3.11 Network Security
			$Req2Output.AppendText("`n2.3.11 Network Security`n")
			$Req2Output.AppendText($Global:Req2LocalSystemNTLMResult)
			$Req2Output.AppendText($Global:Req2LocalSystemNULLSessionResult)
			$Req2Output.AppendText($Global:Req2PKU2UOnlineIdentitiesResult)
			$Req2Output.AppendText($Global:Req2KerberosEncryptionTypesResult)
			$Req2Output.AppendText($Global:Req2LanManagerHashResult)
			$Req2Output.AppendText($Global:Req2ForceLogoffAfterHoursExpireResult)
			$Req2Output.AppendText($Global:Req2LanManagerAuthLevelResult)
			$Req2Output.AppendText($Global:Req2LDAPClientSigningReqsResult)
			$Req2Output.AppendText($Global:Req2NTLMMinClientResults)
			$Req2Output.AppendText($Global:Req2NTLMMinServerResults)
			# 2.3.12 Recovery Console
			$Req2Output.AppendText("`n2.3.12 Recovery Console`n")
			$Req2Output.AppendText($Global:Req2AutoAdminLogonResult)
			$Req2Output.AppendText($Global:Req2AllowFloppyAccessResult)
			# 2.3.13 Shutdown
			$Req2Output.AppendText("`n2.3.13 Shutdown`n")
			$Req2Output.AppendText($Global:Req2ShutdownWithoutLoggingInResult)
			# 2.3.14 System Cryptography
			$Req2Output.AppendText("`n2.3.14 System Cryptography`n")
			$Req2Output.AppendText($Global:Req2FipsPolicyResults)
			$Req2Output.AppendText($Global:Req2UserKeyProtectionResult)
			# 2.3.15 System objects
			$Req2Output.AppendText("`n2.3.15 System objects`n")
			$Req2Output.AppendText($Global:Req2CaseInsensitivityResult)
			$Req2Output.AppendText($Global:Req2StrengthenPermissionsResult)
			# 2.3.17 User Account Control
			$Req2Output.AppendText("`n2.3.17 User Account Control`n")
			$Req2Output.AppendText($Global:Req2AdminApprovalModeResult)
			$Req2Output.AppendText($Global:Req2BehaviorforAdminResult)
			$Req2Output.AppendText($Global:Req2BehaviorforStandardResult)
			$Req2Output.AppendText($Global:Req2InstallerDetectionResult)
			$Req2Output.AppendText($Global:Req2UIAccessSecureLocationsResult)
			$Req2Output.AppendText($Global:Req2RunAllAdminsModeResult)
			$Req2Output.AppendText($Global:Req2SwitchSecureDesktopResult)
			$Req2Output.AppendText($Global:Req2VitualFileLocationsResult)
			$Req2Output.AppendText($Global:CISBenchmarkToalResult)
			$Req2Output.AppendText("`nEnd of 2.2.4`n`n")
			# Others
			$Req2Output.AppendText($Global:LocalDrivesResult)
			$Req2Output.AppendText($Global:SMBSharesResult)
			$Req2Output.AppendText($Global:ADComputersResult)
		}else{
			if(($EverythingToggle -eq $true) -and ($EverythingExportingSwitch -eq $true)){
				$AllOutput.AppendText("Writing Report for the Following:`n`nGathering Information for Everything.`nBe patient and do not tab away. This may take A While.`n" + $Global:SectionBreak + "Everything in Requirement Two`nRequirement Two Compliance Check.`n`n")
			}else{
				$AllOutput.AppendText("Gathering Information for Everything.`nBe patient and do not tab away. This may take A While.`n" + $Global:SectionBreak + "Everything in Requirement Two`nRequirement Two Compliance Check.`n`n")
			}

			$AllOutput.AppendText($Global:Req2VendorPassResult)
			$AllOutput.AppendText($Global:Req2FeatureResult)
			$AllOutput.AppendText($Global:Req2FeatureResultTotal)
			$AllOutput.AppendText($Global:RunningProcessesResult)
			$AllOutput.AppendText($Global:RunningServicesResult)
			$AllOutput.AppendText($Global:32BitAppsResult)
			$AllOutput.AppendText($Global:64BitAppsResult)
			$AllOutput.AppendText("`n2.2.4 - Audit System Security Policy`nThe Following Sub-Sections are directly from the CIS Benchmarks`n")
			#2.2.4 (CIS)
			# 1.1 Password Policy
			$AllOutput.AppendText("`n1.1 Password Policy`n")
			$AllOutput.AppendText($Global:Req2EnforcePasswordHistoryResult)
			$AllOutput.AppendText($Global:Req2MaximumPasswordAgeResult)
			$AllOutput.AppendText($Global:Req2MinimumPasswordAgeResult)
			$AllOutput.AppendText($Global:Req2MinimumPasswordLengthResult)
			$AllOutput.AppendText($Global:Req2PasswordComplexityReqsResult)
			$AllOutput.AppendText($Global:Req2ClearTextPasswordSettingResult)
			# 1.2 Account Lockout Policy
			$AllOutput.AppendText("`n1.2 Account Lockout Policy`n")
			$AllOutput.AppendText($Global:Req2AccountLockoutDurationResult)
			$AllOutput.AppendText($Global:Req2AccountLockoutThresholdResult)
			$AllOutput.AppendText($Global:Req2ResetAccountLockoutCounterResult)
			# 2.3.1 - Accounts
			$AllOutput.AppendText("`n2.3.1 Accounts`n")
			$AllOutput.AppendText($Global:Req2DisabledAdminResult)
			$AllOutput.AppendText($Global:Req2BlockMSAccountsResult)
			$AllOutput.AppendText($Global:Req2DisabledGuestResult)
			$AllOutput.AppendText($Global:Req2LimitBlankPassUseResult)
			$AllOutput.AppendText($Global:Req2RenameAdminResult)
			$AllOutput.AppendText($Global:Req2RenameGuestResult)
			# 2.3.2 Audits
			$AllOutput.AppendText("`n2.3.2 Audits`n")
			$AllOutput.AppendText($Global:Req2ForceAuditPolicyOverrideResult)
			$AllOutput.AppendText($Global:Req2ShutdownAuditSettingsResult)
			# 2.3.4 - Devices
			$AllOutput.AppendText("`n2.3.4 Devices`n")
			$AllOutput.AppendText($Global:Req2RestrictUserUndockingResult)
			$AllOutput.AppendText($Global:Req2RestrictCDRomsResult)
			$AllOutput.AppendText($Global:Req2RestrictFloppiesResult)
			$AllOutput.AppendText($Global:Req2LimitRemoveableMediaResult)
			$AllOutput.AppendText($Global:Req2LimitPrinterDriversResult)
			# 2.3.5 Domain controller
			$AllOutput.AppendText("`n2.3.5 Domain controller`n")
			$AllOutput.AppendText($Global:Req2ServerOpsScheduleTasksResult)
			$AllOutput.AppendText($Global:Req2DCRefuseMachineAccountChangesResult)
			# 2.3.6 - Domain Member
			$AllOutput.AppendText("`n2.3.6 Domain Member`n")
			$AllOutput.AppendText($Global:Req2DigitalEncryptSignResult)
			$AllOutput.AppendText($Global:Req2DigitalSecureChannel)
			$AllOutput.AppendText($Global:Req2DigitalSecureChannelSigned)
			$AllOutput.AppendText($Global:Req2DisableMachinePassChangeResult)
			$AllOutput.AppendText($Global:Req2MaxMachinePassAgeResult)
			$AllOutput.AppendText($Global:Req2StrongSessionKeyResult)
			# 2.3.7 - Interactive Login
			$AllOutput.AppendText("`n2.3.7 Interactive Login`n")
			$AllOutput.AppendText($Global:Req2LoginCntlAltDelStatusResult)
			$AllOutput.AppendText($Global:Req2DontDisplayLastUser)
			$AllOutput.AppendText($Global:Req2MachineAFKLimitResult)
			$AllOutput.AppendText($Global:Req2LegalNoticeTextResult)
			$AllOutput.AppendText($Global:Req2LegalNoticeCaptionResult)
			$AllOutput.AppendText($Global:Req2PreviousCachedLogonsResult)
			$AllOutput.AppendText($Global:Req2PassExpiryWarningResult)
			$AllOutput.AppendText($Global:Req2DCAuthUnlockResult)
			$AllOutput.AppendText($Global:Req2SmartCardRemovalResult)
			# 2.3.8 Microsoft Network Client
			$AllOutput.AppendText("`n2.3.8 Microsoft Network Client`n")
			$AllOutput.AppendText($Global:Req2DigitallySignAlwaysResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsServerResult)
			$AllOutput.AppendText($Global:Req2EnablePlainTextResult)
			# 2.3.9 Microsoft network server
			$AllOutput.AppendText("`n2.3.9 Microsoft network server`n")
			$AllOutput.AppendText($Global:Req2SuspendingSessionIdleTimeResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsForcedResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsClientResult)
			$AllOutput.AppendText($Global:Req2ForcedClientLogoffResult)
			# 2.3.10 Network access
			$AllOutput.AppendText("`n2.3.10 Network access`n")
			$AllOutput.AppendText($Global:Req2SIDNameLookupResult)
			$AllOutput.AppendText($Global:Req2RestrictAnonymousSAMResult)
			$AllOutput.AppendText($Global:Req2AnonymousEmuerationAccountsResult)
			$AllOutput.AppendText($Global:Req2StorageOfPasswordsResult)
			$AllOutput.AppendText($Global:Req2AllIncludesPoliciesResult)
			$AllOutput.AppendText($Global:Req2AnonymousNamedPipesResult)
			$AllOutput.AppendText($Global:Req2AllowedExactPathsResult)
			$AllOutput.AppendText($Global:Req2RestrictAnnonymousAccessSessionsResult)
			$AllOutput.AppendText($Global:Req2NullSessionShares)
			$AllOutput.AppendText($Global:Req2SharingAndSecModelLocalAccountsResult)
			# 2.3.11 Network Security
			$AllOutput.AppendText("`n2.3.11 Network Security`n")
			$AllOutput.AppendText($Global:Req2LocalSystemNTLMResult)
			$AllOutput.AppendText($Global:Req2LocalSystemNULLSessionResult)
			$AllOutput.AppendText($Global:Req2PKU2UOnlineIdentitiesResult)
			$AllOutput.AppendText($Global:Req2KerberosEncryptionTypesResult)
			$AllOutput.AppendText($Global:Req2LanManagerHashResult)
			$AllOutput.AppendText($Global:Req2ForceLogoffAfterHoursExpireResult)
			$AllOutput.AppendText($Global:Req2LanManagerAuthLevelResult)
			$AllOutput.AppendText($Global:Req2LDAPClientSigningReqsResult)
			$AllOutput.AppendText($Global:Req2NTLMMinClientResults)
			$AllOutput.AppendText($Global:Req2NTLMMinServerResults)
			# 2.3.12 Recovery Console
			$AllOutput.AppendText("`n2.3.12 Recovery Console`n")
			$AllOutput.AppendText($Global:Req2AutoAdminLogonResult)
			$AllOutput.AppendText($Global:Req2AllowFloppyAccessResult)
			# 2.3.13 Shutdown
			$AllOutput.AppendText("`n2.3.13 Shutdown`n")
			$AllOutput.AppendText($Global:Req2ShutdownWithoutLoggingInResult)
			# 2.3.14 System Cryptography
			$AllOutput.AppendText("`n2.3.14 System Cryptography`n")
			$AllOutput.AppendText($Global:Req2FipsPolicyResults)
			$AllOutput.AppendText($Global:Req2UserKeyProtectionResult)
			# 2.3.15 System objects
			$AllOutput.AppendText("`n2.3.15 System objects`n")
			$AllOutput.AppendText($Global:Req2CaseInsensitivityResult)
			$AllOutput.AppendText($Global:Req2StrengthenPermissionsResult)
			# 2.3.17 User Account Control
			$AllOutput.AppendText("`n2.3.17 User Account Control`n")
			$AllOutput.AppendText($Global:Req2AdminApprovalModeResult)
			$AllOutput.AppendText($Global:Req2BehaviorforAdminResult)
			$AllOutput.AppendText($Global:Req2BehaviorforStandardResult)
			$AllOutput.AppendText($Global:Req2InstallerDetectionResult)
			$AllOutput.AppendText($Global:Req2UIAccessSecureLocationsResult)
			$AllOutput.AppendText($Global:Req2RunAllAdminsModeResult)
			$AllOutput.AppendText($Global:Req2SwitchSecureDesktopResult)
			$AllOutput.AppendText($Global:Req2VitualFileLocationsResult)
			$AllOutput.AppendText($Global:CISBenchmarkToalResult)
			$AllOutput.AppendText("`nEnd of 2.2.4`n`n")
			# Others
			$AllOutput.AppendText($Global:LocalDrivesResult)
			$AllOutput.AppendText($Global:SMBSharesResult)
			$AllOutput.AppendText($Global:ADComputersResult)
		}
	}

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
		if($Global:TestDCConnection -eq $true){
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
			# Compliance Result
			if($DSResult -eq $true){
				$Global:Req2VendorPassResult = "2.1       - [FAILED] - Default Credentials Have Access in The Network.`n"
				$Global:Req2VendorPassResultHTML = "2.1       - <span id=`"CISFailedStatus`">[FAILED]</span> - Default Credentials Have Access in The Network.`n"
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("2.1       - [FAILED] - Default Credentials Have Access in The Network.`n")
				}else{
					$AllOutput.AppendText("2.1       - [FAILED] - Default Credentials Have Access in The Network.`n")
				}
			}else{
				$Global:Req2VendorPassResult = "2.1       - [PASS] - Default Credentials Do Not Have Access in The Network. PCI-DSS Compliant.`n"
				$Global:Req2VendorPassResultHTML = "2.1       - <span id=`"CISPassStatus`">[PASS]</span> - Default Credentials Do Not Have Access in The Network. PCI-DSS Compliant.`n"
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("2.1       - [PASS] - Default Credentials Do Not Have Access in The Network. PCI-DSS Compliant.`n")
				}else{
					$AllOutput.AppendText("2.1       - [PASS] - Default Credentials Do Not Have Access in The Network. PCI-DSS Compliant.`n")
				}
			}
			# Create HTML
			$CovertedTable = $ResultTable | ForEach {[PSCustomObject]$_}
			$CovertedTable | Sort-Object Username,Result
			$Global:Req2UserCredentialResult = $CovertedTable | ConvertTo-Html -As Table -Fragment -Property Username,Password,Result -PreContent "<h2>2.1 - Test Vendor Default Credentials in AD</h2>"
			$Global:Req2UserCredentialResult = $Global:Req2UserCredentialResult -replace '<td>Unsuccesful</td>','<td class="InstalledStatus">Unsuccesful</td>'
			$Global:Req2UserCredentialResult = $Global:Req2UserCredentialResult -replace '<td>Succesful</td>','<td class="RemovedStatus">Succesful</td>'
		# Edge Case No Connection to Domain
		}else{
			$Global:Req2VendorPassResult = "2.1       - [ERROR] - Unable to Test Credentials in The Network. Not Connected to Domain.`n"
			$Global:Req2VendorPassResultHTML = "2.1       - <span id=`"CISFailedStatus`">[ERROR]</span> - Unable to Test Credentials in The Network. Not Connected to Domain.`n"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("Unable to Test Default Accounts, Not Connected to Domain`n")
			}else{
				$AllOutput.AppendText("Unable to Test Default Accounts, Not Connected to Domain`n")
			}
		}
	}

	# 2.2.1 Grab Installed Roles and Features
	Function Req2GrabInstalledFeatures{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.1 - List of Installed Windows Roles and Features:`n")
		}else{
			$AllOutput.AppendText("2.2.1 - List of Installed Windows Roles and Features:`n")
		}
		# Data Gathering
		try{
			$Req2FeatureList = Get-WindowsFeature | Where-Object InstallState -EQ Installed | Format-Table -Autosize | Out-String -Width 1200
			# HTML Report and Adding Colour Classes to Table Output
			$Global:Req2FeatureListHTML = Get-WindowsFeature | Where-Object InstallState -EQ Installed | ConvertTo-Html -As Table -Property DisplayName,Name,InstallState,FeatureType -Fragment -PreContent "<h2>2.2.1 - List of Installed Windows Roles and Features</h2>"
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Available</td>','<td class="AvailableStatus">Available</td>' 
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Installed</td>','<td class="InstalledStatus">Installed</td>'
			$Global:Req2FeatureListHTML = $Global:Req2FeatureListHTML -replace '<td>Removed</td>','<td class="RemovedStatus">Removed</td>'
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($Req2FeatureList)
			}else{
				$AllOutput.AppendText($Req2FeatureList)
			}		
			# Check Compliance
			# Filter Out Server 2019 Features and Installed Only
			$Req2ListOfAllFeatures = Get-WindowsFeature | Where-Object {($_.Name -ne "FileAndStorage-Services" -and $_.Name -ne "Storage-Services" -and $_.Name -ne "NET-Framework-45-Features" -and $_.Name -ne "NET-Framework-45-Core" -and $_.Name -ne "NET-WCF-Services45" -and $_.Name -ne "NET-WCF-TCP-PortSharing45" -and $_.Name -ne "System-DataArchiver" -and $_.Name -ne "Windows-Defender" -and $_.Name -ne "PowerShellRoot" -and $_.Name -ne "PowerShell" -and $_.Name -ne "PowerShell-ISE" -and $_.Name -ne "WoW64-Support" -and $_.Name -ne "XPS-Viewer" -and $_.Name -ne "FS-SMB1" -and $_.Name -ne "Windows-Defender-Features" -and $_.Name -ne "Windows-Defender-Gui" -and $_.Name -ne "User-Interfaces-Infra" -and $_.Name -ne "Server-Gui-Mgmt-Infra" -and $_.Name -ne "Server-Gui-Shell")} | Where-Object {($_.InstallState -eq "Installed")}
			$Req2ListOfAllFeaturesRTB = $Req2ListOfAllFeatures | Format-Table -Autosize | Out-String -Width 1200
			$FeatureCounter = 0
			foreach($FeatureRole in $Req2ListOfAllFeatures){
				$FeatureCounter++
			}
			if($FeatureCounter -gt 1){
				$Global:Req2FeatureResult = "2.2.1     - [FAILED] - Detected More Than One Role or Feature Installed.`n"
				$Global:Req2FeatureResultHTML = "2.2.1     - <span id=`"CISFailedStatus`">[FAILED]</span> - Detected More Than One Role or Feature Installed.`n"
				$Global:Req2FeatureResultTotal = "2.2.1     - [INFORMATION] - Detected $FeatureCounter Role(s) or Feature(s).`n"
				$Global:Req2FeatureResultTotalHTML = "2.2.1     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $FeatureCounter Role(s) or Feature(s).`n"
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("2.2.1     - [FAILED] - Detected More Than One Role or Feature or Role Installed.`nDetected $FeatureCounter Role(s) or Feature(s).`nCheck List Below and Analyze The Roles and Features.`nList Below Contains No Default Roles or Features.`n")
					$Req2Output.AppendText($Req2ListOfAllFeaturesRTB)
				}else{
					$AllOutput.AppendText("2.2.1     - [FAILED] - Detected More Than One Role or Feature or Role Installed.`nDetected $FeatureCounter Role(s) or Feature(s).`nCheck List Below and Analyze The Roles and Features.`nList Below Contains No Default Roles or Features.`n")
					$AllOutput.AppendText($Req2ListOfAllFeaturesRTB)
				}
			}else{
				$Global:Req2FeatureResult = "2.2.1     - [PASS] - Only Detected One Role or Feature Installed. PCI-DSS Compliant.`n"
				$Global:Req2FeatureResultHTML = "2.2.1     - <span id=`"CISPassStatus`">[PASS]</span> - Only Detected One Role or Feature Installed. PCI-DSS Compliant.`n"
				$Global:Req2FeatureResultTotal = ""
				# Output
				if($EverythingToggle -eq $false){
					$Req2Output.AppendText("2.2.1     - [PASS] - Only Detected One Role or Feature Installed. PCI-DSS Compliant.`n")
					$Req2Output.AppendText($Req2ListOfAllFeaturesRTB)
				}else{
					$AllOutput.AppendText("2.2.1     - [PASS] - Only Detected One Role or Feature Installed. PCI-DSS Compliant.`n")
					$AllOutput.AppendText($Req2ListOfAllFeaturesRTB)
				}
			}
		# Edge Case
		}catch{
			# Data Output
			$Global:Req2FeatureListHTML = "<h2>2.2.1 - List of Installed Windows Roles and Features</h2><p>Unable to Grab Installed Roles or Features.</p>"
			$Global:Req2FeatureResult = "2.2.1     - [ERROR] - List of Installed Windows Roles and Features`nUnable to Grab Installed Roles or Features.`n"
			$Global:Req2FeatureResultHTML = "2.2.1     - <span id=`"CISFailedStatus`">[ERROR]</span> - List of Installed Windows Roles and Features`nUnable to Grab Installed Roles or Features.`n"
			$Global:Req2FeatureResultTotal = ""
			$Req2FeatureList = "Unable to Grab Installed Features."
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to Grab Installed Roles or Features.")
			}else{
				$AllOutput.AppendText("`nUnable to Grab Installed Roles or Features.")
			}	
		}
	}

	# 2.2.2 - List of Runnning Processes
	Function Req2RunningProcesses{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - List of Running Processes:`n")
		}else{
			$AllOutput.AppendText("2.2.2 - List of Running Processes:`n")
		}
		# Data Gathering
		try{
			$Req2ProcessList = Get-Process | Select-Object name, Path | Sort-Object name
			$Req2ProcessListRTB = $Req2ProcessList | Format-Table -Autosize | Out-String -Width 1200
			# HTML Report
			$Global:Req2ProcessListHTML = Get-Process | ConvertTo-Html -As Table -Property Name,Id,ProductVersion,Company,StartTime,Path -Fragment -PreContent "<h2>2.2.2 - List of Running Processes</h2>" 
			# Count Processes
			$ProcessesCounter = 0
			foreach($Process in $Req2ProcessList){
				$ProcessesCounter++
			}
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($Req2ProcessListRTB)
				$Req2Output.AppendText("`n2.2.2 - Detected $ProcessesCounter Running Processes.`n")
			}else{
				$AllOutput.AppendText($Req2ProcessListRTB)
				$AllOutput.AppendText("`n2.2.2 - Detected $ProcessesCounter Running Processes.`n")
			}
			# Total Processes
			$Global:RunningProcessesResult = "2.2.2     - [INFORMATION] - Detected $ProcessesCounter Running Processes.`n"
			$Global:RunningProcessesResultHTML = "2.2.2     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $ProcessesCounter Running Processes.`n"
		# Edge Case
		}catch{
			$Global:Req2ProcessListHTML = "<h2>2.2.2 - List of Running Processes</h2><p>Unable to List Running Processes.<p>"
			$Global:RunningProcessesResult = "`n2.2.2     - [ERROR] - List of Running Processes`nUnable to List Running Processes."
			$Global:RunningProcessesResultHTML = "`n2.2.2     - <span id=`"CISFailedStatus`">[ERROR]</span> - List of Running Processes`nUnable to List Running Processes."
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List Running Processes.")
			}else{
				$AllOutput.AppendText("`nUnable to List Running Processes.")
			}
		}
	}

	# 2.2.2 - List of Running Services
	Function Req2RunningServices{
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - List of Running Services:`n")
		}else{
			$AllOutput.AppendText("2.2.2 - List of Running Services:`n")
		}
		# Data Gathering
		try{
			$Req2SvcListRunning = Get-Service | Where-Object Status -eq "Running" | Sort-Object Name 
			$Req2SvcListRunningRTB = $Req2SvcListRunning | Format-Table -Autosize | Out-String -Width 1200
			# HTML Report
			$Global:Req2SvcListRunningHTML = $Req2SvcListRunning | ConvertTo-Html -As Table -Property Status,Name,DisplayName -Fragment -PreContent "<h2>2.2.2 - List of Running Services</h2>"
			# Count Services
			$ServicesCounter = 0
			foreach($Service in $Req2SvcListRunning){
				$ServicesCounter++
			}
			# Total Processes
			$Global:RunningServicesResult = "2.2.2     - [INFORMATION] - Detected $ServicesCounter Running Services.`n"
			$Global:RunningServicesResultHTML = "2.2.2     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $ServicesCounter Running Services.`n"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($Req2SvcListRunningRTB)
				$Req2Output.AppendText("`n2.2.2 - Detected $ServicesCounter Running Services.`n")
			}else{
				$AllOutput.AppendText($Req2SvcListRunningRTB)
				$AllOutput.AppendText("`n2.2.2 - Detected $ServicesCounter Running Services.`n")
			}
		# Edge Case
		}catch{
			$Global:Req2SvcListRunningHTML = "<h2>2.2.2 - List of Running Services</h2><p>Unable to List Running Serivces.</p>"
			$Global:RunningServicesResult = "`n2.2.2     - [ERROR] - List of Running Services`n - Unable to List Running Serivces."
			$Global:RunningServicesResultHTML = "`n2.2.2     - <span id=`"CISFailedStatus`">[ERROR]</span> - List of Running Services`n - Unable to List Running Serivces."
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("Unable to List Running Serivces.`n")
			}else{
				$AllOutput.AppendText("Unable to List Running Serivces.`n")
			}
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
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.2 - Grab Installed Software:`n`n32-Bit Apps:")
		}else{
			$AllOutput.AppendText("2.2.2 - Grab Installed Software:`n`n32-Bit Apps:")
		}
		# Data Gathering 32 Bit Apps
		try{
			$Req2SoftwareList32Bit = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, PSChildName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName
			$Req2SoftwareList32BitRTB = $Req2SoftwareList32Bit | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SoftwareList32BitHTML = $Req2SoftwareList32Bit | ConvertTo-Html -As Table -Property DisplayName, PSChildName, Publisher, InstallDate, DisplayVersion -Fragment -PreContent "<h2>2.2.2 - Grab Installed Software</h2><h3>32-Bit Apps</h3>"
			# 32 Bit Apps Counter
			$32BitAppsCounter = 0
			foreach($App in $Req2SoftwareList32Bit){
				$32BitAppsCounter++
			}
			# Total Processes
			$Global:32BitAppsResult = "2.2.2     - [INFORMATION] - Detected $32BitAppsCounter 32-Bit Apps Installed.`n"
			$Global:32BitAppsResultHTML = "2.2.2     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $32BitAppsCounter 32-Bit Apps Installed.`n"

			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($Req2SoftwareList32BitRTB)
				$Req2Output.AppendText("2.2.2     - [INFORMATION] - Detected " + $32BitAppsCounter + " 32-Bit Apps Installed.`n")
			}else{
				$AllOutput.AppendText($Req2SoftwareList32BitRTB)
				$AllOutput.AppendText("2.2.2     - [INFORMATION] - Detected " + $32BitAppsCounter + " 32-Bit Apps Installed.`n")
			}
		# Edge Case
		}catch{
			$Global:Req2SoftwareList32BitHTML = "<h2>2.2.2 - Grab Installed Software</h2><h3>32-Bit Apps</h3><p>Unable to Grab Installed Software.</p>"
			$Global:32BitAppsResult = "2.2.2     - [ERROR] - Unable to Find Any 32-Bit Apps Installed.`n"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("Unable to Grab Installed Software - 32 Bit Apps.")
			}else{
				$AllOutput.AppendText("Unable to Grab Installed Software - 32 Bit Apps.")
			}
		}
		# Data Gathering 64 Bit Apps
		try{
			$Req2SoftwareList64Bit = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName, PSChildName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName
			$Req2SoftwareList64BitRTB = $Req2SoftwareList64Bit | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req2SoftwareList64BitHTML = $Req2SoftwareList64Bit | ConvertTo-Html -As Table -Property DisplayName, PSChildName, Publisher, InstallDate, DisplayVersion -Fragment -PreContent "<h3>64-Bit Apps</h3>"
			# 64 Bit Apps Counter
			$64BitAppsCounter = 0
			foreach($App in $Req2SoftwareList64Bit){
				$64BitAppsCounter++
			}
			# Total Processes
			$Global:64BitAppsResult = "2.2.2     - [INFORMATION] - Detected $64BitAppsCounter 64-Bit Apps Installed.`n"
			$Global:64BitAppsResultHTML = "2.2.2     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $64BitAppsCounter 64-Bit Apps Installed.`n"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`n64-Bit Apps:")
				$Req2Output.AppendText($Req2SoftwareList64BitRTB)
				$Req2Output.AppendText("2.2.2     - [INFORMATION] - Detected " + $64BitAppsCounter + " 64-Bit Apps Installed.`n")
			}else{
				$AllOutput.AppendText("`n64-Bit Apps:")
				$AllOutput.AppendText($Req2SoftwareList64BitRTB)
				$AllOutput.AppendText("2.2.2     - [INFORMATION] - Detected " + $64BitAppsCounter + " 64-Bit Apps Installed.`n")
			}
		# Edge Case
		}catch{
			$Global:Req2SoftwareList64BitHTML = "<h3>64-Bit Apps</h3><p>Unable to Grab Installed Software.</p>"
			$Global:64BitAppsResult = "2.2.2     - [ERROR] - Unable to Find Any 64-Bit Apps Installed.`n"
			$Global:64BitAppsResultHTML = "2.2.2     - <span id=`"CISFailedStatus`">[ERROR]</span> - Unable to Find Any 64-Bit Apps Installed.`n"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("Unable to Grab Installed Software - 64 Bit Apps.")
			}else{
				$AllOutput.AppendText("Unable to Grab Installed Software - 64 Bit Apps.")
			}
		}
	}

	# 2.2.4 - Grab System Security Configuration
	Function Req2GrabSysConfig {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("2.2.4 - Grab System Security Configuration:`n")
		}else{
			$AllOutput.AppendText("2.2.4 - Grab System Security Configuration`n")
		}
		# Set Counters
		$CISPassCounter = 0
		$CISFailCounter = 0
		# Data Gathering
			# 1.1 Password Policy
			# 1.1.1 (L1) Ensure 'Enforce password history' is set to '24 or more password(s)' (Scored)
			$EnforcePasswordHistory = $Global:SecDump | Select-String -SimpleMatch 'PasswordHistorySize' | Out-String
			$EnforcePasswordHistoryResult = $EnforcePasswordHistory.split(' ')[2]
			$EnforcePasswordHistoryResult = $EnforcePasswordHistoryResult -as [int]
			if(-not([string]::IsNullOrEmpty($EnforcePasswordHistory))){
				if($EnforcePasswordHistoryResult -ge "24"){
					$Global:Req2EnforcePasswordHistoryResult = "1.1.1     - [PASS] - 'Enforce Password History' is set to '24 or more password(s)'. Current Value: $EnforcePasswordHistoryResult. CIS Compliant.`n"
					$Global:Req2EnforcePasswordHistoryResultHTML = "1.1.1     - <span id=`"CISPassStatus`">[PASS]</span> - 'Enforce Password History' is set to '24 or more password(s)'. Current Value: $EnforcePasswordHistoryResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2EnforcePasswordHistoryResult = "1.1.1     - [FAILED] - 'Enforce Password History' is Not set to '24 or more password(s)'. Current Value: $EnforcePasswordHistoryResult.`n"
					$Global:Req2EnforcePasswordHistoryResultHTML = "1.1.1     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Enforce Password History' is Not set to '24 or more password(s)'. Current Value: $EnforcePasswordHistoryResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2EnforcePasswordHistoryResult = "1.1.1     - [FAILED] - 'Enforce Password History' is Not Configured.`n"
				$Global:Req2EnforcePasswordHistoryResultHTML = "1.1.1     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Enforce Password History' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.1.2 (L1) Ensure 'Maximum password age' is set to '60 or fewer days, but not 0' (Scored)
			$MaximumPasswordAge = $Global:SecDump | Select-String -SimpleMatch 'MaximumPasswordAge =' | Out-String
			$MaximumPasswordAgeResult = $MaximumPasswordAge.split(' ')[2]
			$MaximumPasswordAgeResult = $MaximumPasswordAgeResult -as [int]
			if(-not([string]::IsNullOrEmpty($MaximumPasswordAge))){
				if(($MaximumPasswordAgeResult -le "60") -and ($MaximumPasswordAgeResult -ne "0")){
					$Global:Req2MaximumPasswordAgeResult = "1.1.2     - [PASS] - 'Maximum Password Age' is set to '60 or fewer days, and not 0'. Current Value: $MaximumPasswordAgeResult. CIS Compliant.`n"
					$Global:Req2MaximumPasswordAgeResultHTML = "1.1.2     - <span id=`"CISPassStatus`">[PASS]</span> - 'Maximum Password Age' is set to '60 or fewer days, and not 0'. Current Value: $MaximumPasswordAgeResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2MaximumPasswordAgeResult = "1.1.2     - [FAILED] - 'Maximum Password Age' is Not set to '60 or fewer days, or is set to 0'. Current Value: $MaximumPasswordAgeResult.`n"
					$Global:Req2MaximumPasswordAgeResultHTML = "1.1.2     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Maximum Password Age' is Not set to '60 or fewer days, or is set to 0'. Current Value: $MaximumPasswordAgeResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2MaximumPasswordAgeResult = "1.1.2     - [FAILED] - 'Maximum Password Age' is Not Configured.`n"
				$Global:Req2MaximumPasswordAgeResultHTML = "1.1.2     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Maximum Password Age' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.1.3 (L1) Ensure 'Minimum password age' is set to '1 or more day(s)' (Scored)
			$MinimumPasswordAge = $Global:SecDump | Select-String -SimpleMatch 'MinimumPasswordAge' | Out-String
			$MinimumPasswordAgeResult = $MinimumPasswordAge.split(' ')[2]
			$MinimumPasswordAgeResult = $MinimumPasswordAgeResult -as [int]
			if(-not([string]::IsNullOrEmpty($MinimumPasswordAge))){
				if($MinimumPasswordAgeResult -ge "1"){
					$Global:Req2MinimumPasswordAgeResult = "1.1.3     - [PASS] - 'Minimum Password Age' is set to '1 or more day(s)'. Current Value: $MinimumPasswordAgeResult. CIS Compliant.`n"
					$Global:Req2MinimumPasswordAgeResultHTML = "1.1.3     - <span id=`"CISPassStatus`">[PASS]</span> - 'Minimum Password Age' is set to '1 or more day(s)'. Current Value: $MinimumPasswordAgeResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2MinimumPasswordAgeResult = "1.1.3     - [FAILED] - 'Minimum Password Age' is Not set to '1 or more day(s)'. Current Value: $MinimumPasswordAgeResult.`n"
					$Global:Req2MinimumPasswordAgeResultHTML = "1.1.3     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Minimum Password Age' is Not set to '1 or more day(s)'. Current Value: $MinimumPasswordAgeResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2MinimumPasswordAgeResult = "1.1.3     - [FAILED] - 'Minimum Password Age' is Not Configured.`n"
				$Global:Req2MinimumPasswordAgeResultHTML = "1.1.3     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Minimum Password Age' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.1.4 (L1) Ensure 'Minimum password length' is set to '14 or more character(s)' (Scored)
			$MinimumPasswordLength = $Global:SecDump | Select-String -SimpleMatch 'MinimumPasswordLength' | Out-String
			$MinimumPasswordLengthResult = $MinimumPasswordLength.split(' ')[2]
			$MinimumPasswordLengthResult = $MinimumPasswordLengthResult -as [int]
			if(-not([string]::IsNullOrEmpty($MinimumPasswordLength))){
				if($MinimumPasswordLengthResult -ge "14"){
					$Global:Req2MinimumPasswordLengthResult = "1.1.4     - [PASS] - 'Minimum Password Length' is set to '14 or more character(s)'. Current Value: $MinimumPasswordLengthResult. CIS Compliant.`n"
					$Global:Req2MinimumPasswordLengthResultHTML = "1.1.4     - <span id=`"CISPassStatus`">[PASS]</span> - 'Minimum Password Length' is set to '14 or more character(s)'. Current Value: $MinimumPasswordLengthResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2MinimumPasswordLengthResult = "1.1.4     - [FAILED] - 'Minimum Password Length' is Not set to '14 or more character(s)'. Current Value: $MinimumPasswordLengthResult.`n"
					$Global:Req2MinimumPasswordLengthResultHTML = "1.1.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Minimum Password Length' is Not set to '14 or more character(s)'. Current Value: $MinimumPasswordLengthResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2MinimumPasswordLengthResult = "1.1.4     - [FAILED] - 'Minimum Password Length' is Not Configured.`n"
				$Global:Req2MinimumPasswordLengthResultHTML = "1.1.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Minimum Password Length' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.1.5 (L1) Ensure 'Password must meet complexity requirements' is set to 'Enabled' (Scored)
			$PasswordComplexityReqs = $Global:SecDump | Select-String -SimpleMatch 'ClearTextPassword' | Out-String
			$PasswordComplexityReqsResult = $PasswordComplexityReqs.split(' ')[2]
			$PasswordComplexityReqsResult = $PasswordComplexityReqsResult -as [int]
			if(-not([string]::IsNullOrEmpty($PasswordComplexityReqs))){
				if($PasswordComplexityReqsResult -eq "0"){
					$Global:Req2PasswordComplexityReqsResult = "1.1.5     - [PASS] - 'Password must meet complexity requirements' is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2PasswordComplexityReqsResultHTML = "1.1.5     - <span id=`"CISPassStatus`">[PASS]</span> - 'Password must meet complexity requirements' is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2PasswordComplexityReqsResult = "1.1.5     - [FAILED] - 'Password must meet complexity requirements' is set to 'Disabled'.`n"
					$Global:Req2PasswordComplexityReqsResultHTML = "1.1.5     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Password must meet complexity requirements' is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2PasswordComplexityReqsResult = "1.1.5     - [FAILED] - 'Password must meet complexity requirements' is Not Configured.`n"
				$Global:Req2PasswordComplexityReqsResultHTML = "1.1.5     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Password must meet complexity requirements' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.1.6 (L1) Ensure 'Store passwords using reversible encryption' is set to 'Disabled' (Scored)
			$ClearTextPasswordSetting = $Global:SecDump | Select-String -SimpleMatch 'PasswordComplexity' | Out-String
			$ClearTextPasswordSettingResult = $ClearTextPasswordSetting.split(' ')[2]
			$ClearTextPasswordSettingResult = $ClearTextPasswordSettingResult -as [int]
			if(-not([string]::IsNullOrEmpty($ClearTextPasswordSetting))){
				if($ClearTextPasswordSettingResult -eq "1"){
					$Global:Req2ClearTextPasswordSettingResult = "1.1.6     - [PASS] - 'Store passwords using reversible encryption' is set to 'Disabled'. CIS Compliant.`n"
					$Global:Req2ClearTextPasswordSettingResultHTML = "1.1.6     - <span id=`"CISPassStatus`">[PASS]</span> - 'Store passwords using reversible encryption' is set to 'Disabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ClearTextPasswordSettingResult = "1.1.6     - [FAILED] - 'Store passwords using reversible encryption' is set to 'Enabled'.`n"
					$Global:Req2ClearTextPasswordSettingResultHTML = "1.1.6     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Store passwords using reversible encryption' is set to 'Enabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ClearTextPasswordSettingResult = "1.1.6     - [FAILED] - 'Store passwords using reversible encryption' is Not Configured.`n"
				$Global:Req2ClearTextPasswordSettingResultHTML = "1.1.6     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Store passwords using reversible encryption' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.2 Account Lockout Policy
			# 1.2.1 (L1) Ensure 'Account lockout duration' is set to '15 or more minute(s)' (Scored)
			$AccountLockoutDuration = $Global:SecDump | Select-String -SimpleMatch 'LockoutDuration' | Out-String
			$AccountLockoutDurationResult = $AccountLockoutDuration.split(' ')[2]
			$AccountLockoutDurationResult = $AccountLockoutDurationResult -as [int]
			if(-not([string]::IsNullOrEmpty($AccountLockoutDuration))){
				if($AccountLockoutDurationResult -ge "15"){
					$Global:Req2AccountLockoutDurationResult = "1.2.1     - [PASS] - 'Account lockout duration' is set to '15 or more minute(s)'. Current Value: $AccountLockoutDurationResult. CIS Compliant.`n"
					$Global:Req2AccountLockoutDurationResultHTML = "1.2.1     - <span id=`"CISPassStatus`">[PASS]</span> - 'Account lockout duration' is set to '15 or more minute(s)'. Current Value: $AccountLockoutDurationResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AccountLockoutDurationResult = "1.2.1     - [FAILED] - 'Account lockout duration' is set to 'less than 14 minute(s)'. Current Value: $AccountLockoutDurationResult.`n"
					$Global:Req2AccountLockoutDurationResultHTML = "1.2.1     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Account lockout duration' is set to 'less than 15 minute(s)'. Current Value: $AccountLockoutDurationResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AccountLockoutDurationResult = "1.2.1     - [FAILED] - 'Account lockout duration' is Not Configured.`n"
				$Global:Req2AccountLockoutDurationResultHTML = "1.2.1     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Account lockout duration' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.2.2 (L1) Ensure 'Account lockout threshold' is set to '10 or fewer invalid logon attempt(s), but not 0' (Scored)
			$AccountLockoutThreshold = $Global:SecDump | Select-String -SimpleMatch 'LockoutBadCount' | Out-String
			$AccountLockoutThresholdResult = $AccountLockoutThreshold.split(' ')[2]
			$AccountLockoutThresholdResult = $AccountLockoutThresholdResult -as [int]
			if(-not([string]::IsNullOrEmpty($AccountLockoutThreshold))){
				if(($AccountLockoutThresholdResult -le "10") -and ($AccountLockoutThresholdResult -ne "0")){
					$Global:Req2AccountLockoutThresholdResult = "1.2.2     - [PASS] - 'Account lockout threshold' is Set to '10 or fewer invalid logon attempt(s), but not 0'. Current Value: $AccountLockoutThresholdResult. CIS Compliant.`n"
					$Global:Req2AccountLockoutThresholdResultHTML = "1.2.2     - <span id=`"CISPassStatus`">[PASS]</span> - 'Account lockout threshold' is Set to '10 or fewer invalid logon attempt(s), but not 0'. Current Value: $AccountLockoutThresholdResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AccountLockoutThresholdResult = "1.2.2     - [FAILED] - 'Account lockout threshold' is Not set to '10 or fewer invalid logon attempt(s), or is Set to 0. Current Value: $AccountLockoutThresholdResult.`n"
					$Global:Req2AccountLockoutThresholdResultHTML = "1.2.2     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Account lockout threshold' is Not set to '10 or fewer invalid logon attempt(s), or is Set to 0. Current Value: $AccountLockoutThresholdResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AccountLockoutThresholdResult = "1.2.2     - [FAILED] - 'Account lockout threshold' is Not Configured.`n"
				$Global:Req2AccountLockoutThresholdResultHTML = "1.2.2     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Account lockout threshold' is Not Configured.`n"
				$CISFailCounter++
			}

			# 1.2.3 (L1) Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)' (Scored)
			$ResetAccountLockoutCounter = $Global:SecDump | Select-String -SimpleMatch 'ResetLockoutCount' | Out-String
			$ResetAccountLockoutCounterResult = $ResetAccountLockoutCounter.split(' ')[2]
			$ResetAccountLockoutCounterResult = $ResetAccountLockoutCounterResult -as [int]
			if(-not([string]::IsNullOrEmpty($ResetAccountLockoutCounter))){
				if($ResetAccountLockoutCounterResult -ge "15"){
					$Global:Req2ResetAccountLockoutCounterResult = "1.2.3     - [PASS] - 'Reset account lockout counter after' is set to 15 or more minute(s). Current Value: $ResetAccountLockoutCounterResult. CIS Compliant.`n"
					$Global:Req2ResetAccountLockoutCounterResultHTML = "1.2.3     - <span id=`"CISPassStatus`">[PASS]</span> - 'Reset account lockout counter after' is set to '15 or more minute(s). Current Value: $ResetAccountLockoutCounterResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ResetAccountLockoutCounterResult = "1.2.3     - [FAILED] - 'Reset account lockout counter after' is set to 14 or less minute(s). Current Value: $ResetAccountLockoutCounterResult.`n"
					$Global:Req2ResetAccountLockoutCounterResultHTML = "1.2.3     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Reset account lockout counter after' is set to 14 or less minute(s). Current Value: $ResetAccountLockoutCounterResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ResetAccountLockoutCounterResult = "1.2.3     - [FAILED] - 'Reset account lockout counter after' is Not Configured.`n"
				$Global:Req2ResetAccountLockoutCounterResultHTML = "1.2.3     - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Reset account lockout counter after' is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.1 - Accounts
			# 2.3.1.1 (L1) Ensure 'Accounts: Administrator account status' is set to 'Disabled' (MS only) (Scored)
			$AdminAccountStatus = $Global:SecDump | Select-String -SimpleMatch 'EnableAdminAccount' | Out-String
			$AdminAccountStatusResult = $AdminAccountStatus.split(' ')[2]
			$AdminAccountStatusResult = $AdminAccountStatusResult -as [int]
			if($AdminAccountStatusResult -eq "1"){
				$Global:Req2DisabledAdminResult = "2.3.1.1   - [FAILED] - Administrator Account Is Enabled.`n"
				$Global:Req2DisabledAdminResultHTML = "2.3.1.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Administrator Account Is Enabled.`n"
				$CISFailCounter++
			}else{
				$Global:Req2DisabledAdminResult = "2.3.1.1   - [PASS] - Administrator Account Is Disabled. CIS Compliant.`n"
				$Global:Req2DisabledAdminResultHTML = "2.3.1.1   - <span id=`"CISPassStatus`">[PASS]</span> - Administrator Account Is Disabled. CIS Compliant.`n"
				$CISPassCounter++
			}

			# 2.3.1.2 (L1) Ensure 'Accounts: Block Microsoft accounts' is set to 'Users can't add or log on with Microsoft accounts' (Scored) - "NoConnectedUser" WIP
			$BlockMSAccounts = $Global:SecDump | Select-String -SimpleMatch 'NoConnectedUser' | Out-String
			$BlockMSAccountsResult = $BlockMSAccounts.split(',')[1]
			$BlockMSAccountsResult = $BlockMSAccountsResult -as [int]
			if(-not([string]::IsNullOrEmpty($BlockMSAccounts))){
				if($BlockMSAccountsResult -eq "3"){
					$Global:Req2BlockMSAccountsResult = "2.3.1.2   - [PASS] - Microsoft accounts is blocked correctly. Users can't add or log-in with Microsoft accounts. CIS Compliant.`n"
					$Global:Req2BlockMSAccountsResultHTML = "2.3.1.2   - <span id=`"CISPassStatus`">[PASS]</span> - Microsoft accounts is blocked correctly. Users can't add or log-in with Microsoft accounts. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2BlockMSAccountsResult = "2.3.1.2   - [FAILED] - Microsoft accounts is blocked incorrectly. Users can add or log-in with Microsoft accounts.`n"
					$Global:Req2BlockMSAccountsResultHTML = "2.3.1.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Microsoft accounts is blocked incorrectly. Users can add or log-in with Microsoft accounts.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2BlockMSAccountsResult = "2.3.1.2   - [FAILED] - Microsoft accounts policy is Not Configured.`n"
				$Global:Req2BlockMSAccountsResultHTML = "2.3.1.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Microsoft accounts policy is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.1.3 (L1) Ensure 'Accounts: Guest account status' is set to 'Disabled' (MS only) (Scored)
			$GuestAccountStatus = $Global:SecDump | Select-String -SimpleMatch 'EnableGuestAccount' | Out-String
			$GuestAccountStatusResult = $GuestAccountStatus.split(' ')[2]
			$GuestAccountStatusResult = $GuestAccountStatusResult -as [int]
			if($GuestAccountStatusResult -eq "1"){
				$Global:Req2DisabledGuestResult = "2.3.1.3   - [FAILED] - Guest Account Is Enabled.`n"
				$Global:Req2DisabledGuestResultHTML = "2.3.1.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Guest Account Is Enabled.`n"
				$CISFailCounter++
			}else{
				$Global:Req2DisabledGuestResult = "2.3.1.3   - [PASS] - Guest Account Is Disabled. CIS Compliant.`n"
				$Global:Req2DisabledGuestResultHTML = "2.3.1.3   - <span id=`"CISPassStatus`">[PASS]</span> - Guest Account Is Disabled. CIS Compliant.`n"
				$CISPassCounter++
			}

			# 2.3.1.4 (L1) Ensure 'Accounts: Limit local account use of blank passwords to console logon only' is set to 'Enabled' (Scored)
			$LimitBlankPassUse = $Global:SecDump | Select-String -SimpleMatch 'LimitBlankPasswordUse' | Out-String
			$LimitBlankPassUseResult = $LimitBlankPassUse.split(',')[1]
			$LimitBlankPassUseResult = $LimitBlankPassUseResult -as [int]
			if($LimitBlankPassUseResult -eq "1"){
				$Global:Req2LimitBlankPassUseResult = "2.3.1.4   - [PASS] - Limit Blank Password Use Is Enabled. CIS Compliant.`n"
				$Global:Req2LimitBlankPassUseResultHTML = "2.3.1.4   - <span id=`"CISPassStatus`">[PASS]</span> - Limit Blank Password Use Is Enabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2LimitBlankPassUseResult = "2.3.1.4   - [FAILED] - Limit Blank Password Use Is Disabled.`n"
				$Global:Req2LimitBlankPassUseResultHTML = "2.3.1.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Limit Blank Password Use Is Disabled.`n"
				$CISFailCounter++
			}

			# 2.3.1.5 (L1) Configure 'Accounts: Rename administrator account' (Scored)
			$RenameLocalAdmin = $Global:SecDump | Select-String -SimpleMatch 'NewAdministratorName' | Out-String
			$RenameLocalAdminResult = $RenameLocalAdmin.split('"')[1]
			if($RenameLocalAdminResult -eq "Administrator"){
				$Global:Req2RenameAdminResult = "2.3.1.5   - [FAILED] - Administrator Account Not Renamed.`n"
				$Global:Req2RenameAdminResultHTML = "2.3.1.5   - <span id=`"CISFailedStatus`">[FAILED]</span> - Administrator Account Not Renamed.`n"
				$CISFailCounter++
			}else{
				$Global:Req2RenameAdminResult = "2.3.1.5   - [PASS] - Administrator Account Renamed to " + $RenameLocalAdminResult + ". CIS Compliant.`n"
				$Global:Req2RenameAdminResultHTML = "2.3.1.5   - <span id=`"CISPassStatus`">[PASS]</span> - Administrator Account Renamed to " + $RenameLocalAdminResult + ". CIS Compliant.`n"
				$CISPassCounter++
			}

			# 2.3.1.6 (L1) Configure 'Accounts: Rename guest account' (Scored)
			$RenameLocalGuest = $Global:SecDump | Select-String -SimpleMatch 'NewGuestName' | Out-String
			$RenameLocalGuestResult = $RenameLocalGuest.split('"')[1]
			if($RenameLocalGuestResult -eq "Guest"){
				$Global:Req2RenameGuestResult = "2.3.1.6   - [FAILED] - Guest Account Not Renamed.`n"
				$Global:Req2RenameGuestResultHTML = "2.3.1.6   - <span id=`"CISFailedStatus`">[FAILED]</span> - Guest Account Not Renamed.`n"
				$CISFailCounter++
			}else{
				$Global:Req2RenameGuestResult = "2.3.1.6   - [PASS] - Guest Account Renamed to " + $RenameLocalGuestResult + ". CIS Compliant.`n"
				$Global:Req2RenameGuestResultHTML = "2.3.1.6   - <span id=`"CISPassStatus`">[PASS]</span> - Guest Account Renamed to " + $RenameLocalGuestResult + ". CIS Compliant.`n"
				$CISPassCounter++
			}

			# 2.3.2 Audits
			# 2.3.2.1 (L1) Ensure 'Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' is set to 'Enabled' (Scored)
			$ForceAuditPolicyOverride = $Global:SecDump | Select-String -SimpleMatch 'SCENoApplyLegacyAuditPolicy' | Out-String
			$ForceAuditPolicyOverrideResult = $ForceAuditPolicyOverride.split(',')[1]
			$ForceAuditPolicyOverrideResult = $ForceAuditPolicyOverrideResult -as [int]
			if(-not([string]::IsNullOrEmpty($ForceAuditPolicyOverride))){
				if($ForceAuditPolicyOverrideResult -eq "1"){
					$Global:Req2ForceAuditPolicyOverrideResult = "2.3.2.1   - [PASS] - Force audit policy subcategory settings to override audit policy category settings is Enabled. CIS Compliant.`n"
					$Global:Req2ForceAuditPolicyOverrideResultHTML = "2.3.2.1   - <span id=`"CISPassStatus`">[PASS]</span> - Force audit policy subcategory settings to override audit policy category settings is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ForceAuditPolicyOverrideResult = "2.3.2.1   - [FAILED] - Force audit policy subcategory settings to override audit policy category settings is Disabled.`n"
					$Global:Req2ForceAuditPolicyOverrideResultHTML = "2.3.2.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Force audit policy subcategory settings to override audit policy category settings is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ForceAuditPolicyOverrideResult = "2.3.2.1   - [FAILED] - Force audit policy subcategory settings to override audit policy category settings is Not Configured.`n"
				$Global:Req2ForceAuditPolicyOverrideResultHTML = "2.3.2.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Force audit policy subcategory settings to override audit policy category settings is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.2.2 (L1) Ensure 'Audit: Shut down system immediately if unable to log security audits' is set to 'Disabled' (Scored)
			$ShutdownAuditSettings = $Global:SecDump | Select-String -SimpleMatch 'CrashOnAuditFail' | Out-String
			$ShutdownAuditSettingsResult = $ShutdownAuditSettings.split(',')[1]
			$ShutdownAuditSettingsResult = $ShutdownAuditSettingsResult -as [int]
			if(-not([string]::IsNullOrEmpty($ShutdownAuditSettings))){
				if($ShutdownAuditSettingsResult -eq "0"){
					$Global:Req2ShutdownAuditSettingsResult = "2.3.2.2   - [PASS] - Shut down system immediately if unable to log security audits is Disabled. CIS Compliant.`n"
					$Global:Req2ShutdownAuditSettingsResultHTML = "2.3.2.2   - <span id=`"CISPassStatus`">[PASS]</span> - Shut down system immediately if unable to log security audits is Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ShutdownAuditSettingsResult = "2.3.2.2   - [FAILED] - Shut down system immediately if unable to log security audits is Enabled.`n"
					$Global:Req2ShutdownAuditSettingsResultHTML = "2.3.2.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Shut down system immediately if unable to log security audits is Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ShutdownAuditSettingsResult = "2.3.2.2   - [FAILED] - Shut down system immediately if unable to log security audits is Not Configured.`n"
				$Global:Req2ShutdownAuditSettingsResultHTML = "2.3.2.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Shut down system immediately if unable to log security audits is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.4 - Devices
			# 2.3.4 - Devices: Allow Undock without having to log-in (Disable)
			$RestrictUserUndocking = $Global:SecDump | Select-String -SimpleMatch 'UndockWithoutLogon' | Out-String
			$RestrictUserUndockingResult = $RestrictUserUndocking.split(',')[1]
			$RestrictUserUndockingResult = $RestrictUserUndockingResult -as [int]
			if(-not([string]::IsNullOrEmpty($RestrictUserUndocking))){
				if($RestrictUserUndockingResult -eq "0"){
					$Global:Req2RestrictUserUndockingResult = "2.3.4     - [PASS] - The system must be logged in before removing from a docking system. CIS Compliant.`n"
					$Global:Req2RestrictUserUndockingResultHTML = "2.3.4     - <span id=`"CISPassStatus`">[PASS]</span> - The system must be logged in before removing from a docking system. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RestrictUserUndockingResult = "2.3.4     - [FAILED] - The system can be removed from a docking station without User Logging In.`n"
					$Global:Req2RestrictUserUndockingResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - The system can be removed from a docking station without User Logging In.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RestrictUserUndockingResult = "2.3.4     - [FAILED] - System undocking policy is Not Defined.`n"
				$Global:Req2RestrictUserUndockingResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - System undocking policy is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.4 - Devices: Restrict CD-ROM access to locally logged-on user only
			$RestrictCDRoms = $Global:SecDump | Select-String -SimpleMatch 'AllocateCDRoms' | Out-String
			$RestrictCDRomsResult = $RestrictCDRoms.split('"')[1]
			$RestrictCDRomsResult = $RestrictCDRomsResult -as [int]
			if(-not([string]::IsNullOrEmpty($RestrictCDRoms))){
				if($RestrictCDRomsResult -eq "1"){
					$Global:Req2RestrictCDRomsResult = "2.3.4     - [PASS] - CD-ROM is Restricted to Locally Logged-on User Only. CIS Compliant.`n"
					$Global:Req2RestrictCDRomsResultHTML = "2.3.4     - <span id=`"CISPassStatus`">[PASS]</span> - CD-ROM is Restricted to Locally Logged-on User Only. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RestrictCDRomsResult = "2.3.4     - [FAILED] - CD-ROM is Not Restricted to Locally Logged-on User Only.`n"
					$Global:Req2RestrictCDRomsResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - CD-ROM is Not Restricted to Locally Logged-on User Only.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RestrictCDRomsResult = "2.3.4     - [FAILED] - Restricting CD-ROM to Locally Logged-on User Only Not Defined.`n"
				$Global:Req2RestrictCDRomsResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - Restricting CD-ROM to Locally Logged-on User Only Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.4 - Devices: Restrict floppy access to locally logged-on user only” is not set to “Disabled”
			$RestrictFloppies = $Global:SecDump | Select-String -SimpleMatch 'AllocateFloppies' | Out-String
			$RestrictFloppiesResult = $RestrictFloppies.split('"')[1]
			$RestrictFloppiesResult = $RestrictFloppiesResult -as [int]
			if(-not([string]::IsNullOrEmpty($RestrictFloppies))){
				if($RestrictFloppiesResult -eq "1"){
					$Global:Req2RestrictFloppiesResult = "2.3.4     - [PASS] - Floppy Access is restricted to Locally Logged-on User Only. CIS Compliant.`n"
					$Global:Req2RestrictFloppiesResultHTML = "2.3.4     - <span id=`"CISPassStatus`">[PASS]</span> - Floppy Access is restricted to Locally Logged-on User Only. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RestrictFloppiesResult = "2.3.4     - [FAILED] - Floppy Access is not restricted to Locally Logged-on User Only.`n"
					$Global:Req2RestrictFloppiesResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - Floppy Access is not restricted to Locally Logged-on User Only.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RestrictFloppiesResult = "2.3.4     - [FAILED] - Restrict Floppy Access to Locally Logged-on User Only Not Defined.`n"
				$Global:Req2RestrictFloppiesResultHTML = "2.3.4     - <span id=`"CISFailedStatus`">[FAILED]</span> - Restrict Floppy Access to Locally Logged-on User Only Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.4.1 (L1) Ensure 'Devices: Allowed to format and eject removable media' is set to 'Administrators' (Scored)
			$LimitRemoveableMedia = $Global:SecDump | Select-String -SimpleMatch 'AllocateDASD' | Out-String
			$LimitRemoveableMediaResult = $LimitRemoveableMedia.split('"')[1]
			$LimitRemoveableMediaResult = $LimitRemoveableMediaResult -as [int]
			if(-not([string]::IsNullOrEmpty($LimitRemoveableMedia))){
				if($LimitRemoveableMediaResult -eq "0"){
					$Global:Req2LimitRemoveableMediaResult = "2.3.4.1   - [PASS] - Format and Eject Removable Media Policy Configured to Administrators. CIS Compliant.`n"
					$Global:Req2LimitRemoveableMediaResultHTML = "2.3.4.1   - <span id=`"CISPassStatus`">[PASS]</span> - Format and Eject Removable Media Policy Configured to Administrators. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LimitRemoveableMediaResult = "2.3.4.1   - [FAILED] - Format and Eject Removable Media Policy Not Configured to Administrator.`n"
					$Global:Req2LimitRemoveableMediaResultHTML = "2.3.4.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Format and Eject Removable Media Policy Not Configured to Administrator.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LimitRemoveableMediaResult = "2.3.4.1   - [FAILED] - Format and Eject Removable Media Policy Not Configured.`n"
				$Global:Req2LimitRemoveableMediaResultHTML = "2.3.4.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Format and Eject Removable Media Policy Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.4.2 (L1) Ensure 'Devices: Prevent users from installing printer drivers' is set to 'Enabled' (Scored)
			$LimitPrinterDrivers = $Global:SecDump | Select-String -SimpleMatch 'AddPrinterDrivers' | Out-String
			$LimitPrinterDriversResult = $LimitPrinterDrivers.split(',')[1]
			$LimitPrinterDriversResult = $LimitPrinterDriversResult -as [int]
			if(-not([string]::IsNullOrEmpty($LimitPrinterDrivers))){
				if($LimitRemoveableMediaResult -eq "0"){
					$Global:Req2LimitPrinterDriversResult = "2.3.4.2   - [PASS] - Prevent users from installing printer drivers is Enabled. CIS Compliant.`n"
					$Global:Req2LimitPrinterDriversResultHTML = "2.3.4.2   - <span id=`"CISPassStatus`">[PASS]</span> - Prevent users from installing printer drivers is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LimitPrinterDriversResult = "2.3.4.2   - [FAILED] - Prevent users from installing printer drivers is Disabled.`n"
					$Global:Req2LimitPrinterDriversResultHTML = "2.3.4.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Prevent users from installing printer drivers is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LimitPrinterDriversResult = "2.3.4.2   - [FAILED] - Prevent users from installing printer drivers is Not Configured.`n"
				$Global:Req2LimitPrinterDriversResultHTML = "2.3.4.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Prevent users from installing printer drivers is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.5 Domain controller
			# 2.3.5.1 (L1) Ensure 'Domain controller: Allow server operators to schedule tasks' is set to 'Disabled' (DC only) (Scored)
			$ServerOpsScheduleTasks = $Global:SecDump | Select-String -SimpleMatch 'SubmitControl' | Out-String
			$ServerOpsScheduleTasksResult = $ServerOpsScheduleTasks.split(',')[1]
			$ServerOpsScheduleTasksResult = $ServerOpsScheduleTasksResult -as [int]
			if(-not([string]::IsNullOrEmpty($ServerOpsScheduleTasks))){
				if($ServerOpsScheduleTasksResult -eq "0"){
					$Global:Req2ServerOpsScheduleTasksResult = "2.3.5.1   - [PASS] - Server Operators are not allowed to submit jobs by means of the AT schedule facility. CIS Compliant.`n"
					$Global:Req2ServerOpsScheduleTasksResultHTML = "2.3.5.1   - <span id=`"CISPassStatus`">[PASS]</span> - Server Operators are not allowed to submit jobs by means of the AT schedule facility. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ServerOpsScheduleTasksResult = "2.3.5.1   - [FAILED] - Server Operators are allowed to submit jobs by means of the AT schedule facility.`n"
					$Global:Req2ServerOpsScheduleTasksResultHTML = "2.3.5.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Server Operators are allowed to submit jobs by means of the AT schedule facility.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ServerOpsScheduleTasksResult = "2.3.5.1   - [FAILED] - Server Operators do not have configured permissions for submitting jobs.`n"
				$Global:Req2ServerOpsScheduleTasksResultHTML = "2.3.5.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Server Operators do not have configured permissions for submitting jobs.`n"
				$CISFailCounter++
			}

			# 2.3.5.3 (L1) Ensure 'Domain controller: Refuse machine account password changes' is set to 'Disabled' (DC only) (Scored)
			$DCRefuseMachineAccountChanges = $Global:SecDump | Select-String -SimpleMatch 'RefusePasswordChange' | Out-String
			$DCRefuseMachineAccountChangesResult = $DCRefuseMachineAccountChanges.split(',')[1]
			$DCRefuseMachineAccountChangesResult = $DCRefuseMachineAccountChangesResult -as [int]
			if(-not([string]::IsNullOrEmpty($DCRefuseMachineAccountChanges))){
				if($DCRefuseMachineAccountChangesResult -eq "0"){
					$Global:Req2DCRefuseMachineAccountChangesResult = "2.3.5.3   - [PASS] - Refuse Machine Account Password Change Policy is set to Disabled. CIS Compliant.`n"
					$Global:Req2DCRefuseMachineAccountChangesResultHTML = "2.3.5.3   - <span id=`"CISPassStatus`">[PASS]</span> - Refuse Machine Account Password Change Policy is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DCRefuseMachineAccountChangesResult = "2.3.5.3   - [FAILED] - Refuse Machine Account Password Change Policy is set to Enabled.`n"
					$Global:Req2DCRefuseMachineAccountChangesResultHTML = "2.3.5.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Refuse Machine Account Password Change Policy is set to Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DCRefuseMachineAccountChangesResult = "2.3.5.3   - [FAILED] - Refuse Machine Account Password Change Policy is Not Defined.`n"
				$Global:Req2DCRefuseMachineAccountChangesResultHTML = "2.3.5.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Refuse Machine Account Password Change Policy is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.6 - Domain Member
			# 2.3.6.1 (L1) Ensure 'Domain member: Digitally encrypt or sign secure channel data (always)' is set to 'Enabled' (Scored)
			$DigitalEncryptSign = $Global:SecDump | Select-String -SimpleMatch "RequireSignOrSeal" | Out-String
			$DigitalEncryptSignResult = $DigitalEncryptSign.split(",")[1]
			$DigitalEncryptSignResult = $DigitalEncryptSignResult -as [int]
			if(-not([string]::IsNullOrEmpty($DigitalEncryptSign))){
				if($DigitalEncryptSignResult -eq "1"){
					$Global:Req2DigitalEncryptSignResult = "2.3.6.1   - [PASS] - Digitally encrypt or sign secure channel data (always)' is Enabled. CIS Compliant.`n"
					$Global:Req2DigitalEncryptSignResultHTML = "2.3.6.1   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally encrypt or sign secure channel data (always)' is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DigitalEncryptSignResult = "2.3.6.1   - [FAILED] - Digitally encrypt or sign secure channel data (always)' is Disabled.`n"
					$Global:Req2DigitalEncryptSignResultHTML = "2.3.6.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally encrypt or sign secure channel data (always)' is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DigitalEncryptSignResult = "2.3.6.1   - [FAILED] - Digitally encrypt or sign secure channel data (always)' is Not Defined.`n"
				$Global:Req2DigitalEncryptSignResultHTML = "2.3.6.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally encrypt or sign secure channel data (always)' is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.6.2 (L1) Ensure 'Domain member: Digitally encrypt secure channel data (when possible)' is set to 'Enabled' (Scored)
			$DigitalSecureChannel = $Global:SecDump | Select-String -SimpleMatch "SealSecureChannel" | Out-String
			$DigitalSecureChannelResult = $DigitalSecureChannel.Split(",")[1]
			$DigitalSecureChannelResult = $DigitalSecureChannelResult -as [int]
			if($DigitalSecureChannelResult -eq "1"){
				$Global:Req2DigitalSecureChannel = "2.3.6.2   - [PASS] - Digitally encrypt secure channel data (when possible) is Enabled. CIS Compliant.`n"
				$Global:Req2DigitalSecureChannelHTML = "2.3.6.2   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally encrypt secure channel data (when possible) is Enabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2DigitalSecureChannel = "2.3.6.2   - [FAILED] - Digitally encrypt secure channel data (when possible) is Disabled.`n"
				$Global:Req2DigitalSecureChannelHTML = "2.3.6.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally encrypt secure channel data (when possible) is Disabled.`n"
				$CISFailCounter++
			}

			# 2.3.6.3 (L1) Ensure 'Domain member: Digitally sign secure channel data (when possible)' is set to 'Enabled' (Scored)
			$DigitalSecureChannelSigned = $Global:SecDump | Select-String -SimpleMatch "SignSecureChannel" | Out-String
			$DigitalSecureChannelSignedResult = $DigitalSecureChannelSigned.Split(",")[1]
			$DigitalSecureChannelSignedResult = $DigitalSecureChannelResult -as [int]
			if($DigitalSecureChannelSignedResult -eq "1"){
				$Global:Req2DigitalSecureChannelSigned = "2.3.6.3   - [PASS] - Digitally sign secure channel data (when possible) is Enabled. CIS Compliant.`n"
				$Global:Req2DigitalSecureChannelSignedHTML = "2.3.6.3   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally sign secure channel data (when possible) is Enabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2DigitalSecureChannelSigned = "2.3.6.3   - [FAILED] - Digitally sign secure channel data (when possible) is Disabled.`n"
				$Global:Req2DigitalSecureChannelSignedHTML = "2.3.6.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally sign secure channel data (when possible) is Disabled.`n"
				$CISFailCounter++
			}

			# 2.3.6.4 (L1) Ensure 'Domain member: Disable machine account password changes' is set to 'Disabled' (Scored)
			$DisableMachinePassChange = $Global:SecDump | Select-String -SimpleMatch 'DisablePasswordChange' | Out-String
			$DisableMachinePassChangeResult = $DisableMachinePassChange.split(',')[1]
			$DisableMachinePassChangeResult = $DisableMachinePassChangeResult -as [int]
			if(-not([string]::IsNullOrEmpty($DisableMachinePassChange))){
				if($DisableMachinePassChangeResult -eq "0"){
					$Global:Req2DisableMachinePassChangeResult = "2.3.6.4   - [PASS] - Machine Account Password Changes is set to Disabled. CIS Compliant.`n"
					$Global:Req2DisableMachinePassChangeResultHTML = "2.3.6.4   - <span id=`"CISPassStatus`">[PASS]</span> - Machine Account Password Changes is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DisableMachinePassChangeResult = "2.3.6.4   - [FAILED] - Machine Account Password Changes is set to Enabled.`n"
					$Global:Req2DisableMachinePassChangeResultHTML = "2.3.6.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine Account Password Changes is set to Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DisableMachinePassChangeResult = "2.3.6.4   - [FAILED] - Machine Account Password Changes is not Not Defined.`n"
				$Global:Req2DisableMachinePassChangeResultHTML = "2.3.6.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine Account Password Changes is not Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.6.5 (L1) Ensure 'Domain member: Maximum machine account password age' is set to '30 or fewer days, but not 0' (Scored)
			$MaxMachinePassAge = $Global:SecDump | Select-String -SimpleMatch 'Parameters\MaximumPasswordAge' | Out-String
			$MaxMachinePassAgeResult = $MaxMachinePassAge.split(',')[1]
			$MaxMachinePassAgeResult = $MaxMachinePassAgeResult -as [int]
			if(-not([string]::IsNullOrEmpty($MaxMachinePassAge))){
				if(($MaxMachinePassAgeResult -le "30") -and ($MaxMachinePassAgeResult -ne "0")){
					$Global:Req2MaxMachinePassAgeResult = "2.3.6.5   - [PASS] - Maximum Machine Account Password Age is set to between 1 and 30 Days. The current setting is $MaxMachinePassAgeResult Days. CIS Compliant.`n"
					$Global:Req2MaxMachinePassAgeResultHTML = "2.3.6.5   - <span id=`"CISPassStatus`">[PASS]</span> - Maximum Machine Account Password Age is set to between 1 and 30 Days. The current setting is $MaxMachinePassAgeResult Days. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2MaxMachinePassAgeResult = "2.3.6.5   - [FAILED] - Maximum Machine Account Password Age is set to 0 Days.`n"
					$Global:Req2MaxMachinePassAgeResultHTML = "2.3.6.5   - <span id=`"CISFailedStatus`">[FAILED]</span> - Maximum Machine Account Password Age is set to 0 Days.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2MaxMachinePassAgeResult = "2.3.6.5   - [FAILED] - Maximum Machine Account Password Age is set to Greater than 30 Days.`n"
				$Global:Req2MaxMachinePassAgeResultHTML = "2.3.6.5   - <span id=`"CISFailedStatus`">[FAILED]</span> - Maximum Machine Account Password Age is set to Greater than 30 Days.`n"
				$CISFailCounter++
			}

			# 2.3.6.6 (L1) Ensure 'Domain member: Require strong (Windows 2000 or later) session key' is set to 'Enabled' (Scored)
			$StrongSessionKey = $Global:SecDump | Select-String -SimpleMatch 'RequireStrongKey' | Out-String
			$StrongSessionKeyResult = $StrongSessionKey.split(',')[1]
			$StrongSessionKeyResult = $StrongSessionKeyResult -as [int]
			if(-not([string]::IsNullOrEmpty($StrongSessionKey))){
				if($LimitRemoveableMediaResult -eq "0"){
					$Global:Req2StrongSessionKeyResult = "2.3.6.6   - [PASS] - Require Strong Session Key for Windows Server 2000 is Enabled. CIS Compliant.`n"
					$Global:Req2StrongSessionKeyResultHTML = "2.3.6.6   - <span id=`"CISPassStatus`">[PASS]</span> - Require Strong Session Key for Windows Server 2000 is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2StrongSessionKeyResult = "2.3.6.6   - [FAILED] - Require Strong Session Key for Windows Server 2000 is Disabled.`n"
					$Global:Req2StrongSessionKeyResultHTML = "2.3.6.6   - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Strong Session Key for Windows Server 2000 is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2StrongSessionKeyResult = "2.3.6.6   - [FAILED] - Require Strong Session Key for Windows Server 2000 is Not Configured.`n"
				$Global:Req2StrongSessionKeyResultHTML = "2.3.6.6   - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Strong Session Key for Windows Server 2000 is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.7 - Interactive Login
			# 2.3.7.1 (L1) Ensure 'Interactive logon: Do not require CTRL+ALT+DEL' is set to 'Disabled' (Scored)
			$LoginCntlAltDelStatus = $Global:SecDump | Select-String -SimpleMatch 'DisableCAD' | Out-String
			$LoginCntlAltDelStatusResult = $LoginCntlAltDelStatus.split(',')[1]
			$LoginCntlAltDelStatusResult = $LoginCntlAltDelStatusResult -as [int]
			if(-not([string]::IsNullOrEmpty($LoginCntlAltDelStatus))){
				if($LoginCntlAltDelStatusResult -eq "0"){
					$Global:Req2LoginCntlAltDelStatusResult = "2.3.7.1   - [PASS] - Policy for Do not require CTRL+ALT+DEL on the Login page is set to Disabled. CIS Compliant.`n"
					$Global:Req2LoginCntlAltDelStatusResultHTML = "2.3.7.1   - <span id=`"CISPassStatus`">[PASS]</span> - Policy for Do not require CTRL+ALT+DEL on the Login page is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LoginCntlAltDelStatusResult = "2.3.7.1   - [FAILED] - Policy for Do not require CTRL+ALT+DEL on the Login page is set to Enabled.`n"
					$Global:Req2LoginCntlAltDelStatusResultHTML = "2.3.7.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Policy for Do not require CTRL+ALT+DEL on the Login page is set to Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LoginCntlAltDelStatusResult = "2.3.7.1   - [FAILED] - Policy for Do not require CTRL+ALT+DEL on the Login page is Not Configured.`n"
				$Global:Req2LoginCntlAltDelStatusResultHTML = "2.3.7.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Policy for Do not require CTRL+ALT+DEL on the Login page is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.7.2 (L1) Ensure 'Interactive logon: Don't display last signed-in' is set to 'Enabled' (Scored)
			$DontDisplayLastUser = $Global:SecDump | Select-String -SimpleMatch "DontDisplayLastUserName" | Out-String
			$DontDisplayLastUserResult = $DontDisplayLastUser.Split(",")[1]
			$DontDisplayLastUserResult = $DontDisplayLastUserResult -as [int]
			if($DontDisplayLastUserResult -eq "1"){
				$Global:Req2DontDisplayLastUser = "2.3.7.2   - [PASS] - Policy of Not Displaying the Last Logged-in Username is set to Enabled. CIS Compliant.`n"
				$Global:Req2DontDisplayLastUserHTML = "2.3.7.2   - <span id=`"CISPassStatus`">[PASS]</span> - Policy of Not Displaying the Last Logged-in Username is set to Enabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2DontDisplayLastUser = "2.3.7.2   - [FAILED] - Policy of Not Displaying the Last Logged-in Username is set to Disabled.`n"
				$Global:Req2DontDisplayLastUserHTML = "2.3.7.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Policy of Not Displaying the Last Logged-in Username is set to Disabled.`n"
				$CISFailCounter++
			}

			# 2.3.7.3 (L1) Ensure 'Interactive logon: Machine inactivity limit' is set to '900 or fewer second(s), but not 0' (Scored)
			# "InactivityTimeoutSecs"
			$MachineAFKLimit = $Global:SecDump | Select-String -SimpleMatch 'InactivityTimeoutSecs' | Out-String
			$MachineAFKLimitResult = $MachineAFKLimit.split(',')[1]
			$MachineAFKLimitResult = $MachineAFKLimitResult -as [int]
			if(-not([string]::IsNullOrEmpty($MachineAFKLimit))){
				if(($MachineAFKLimitResult -le "900") -and ($MachineAFKLimitResult -ne "0")){
					$Global:Req2MachineAFKLimitResult = "2.3.7.3   - [PASS] - Machine inactivity limit is set between 1 and 900 seconds. The current setting is $MachineAFKLimitResult seconds. CIS Compliant.`n"
					$Global:Req2MachineAFKLimitResultHTML = "2.3.7.3   - <span id=`"CISPassStatus`">[PASS]</span> - Machine inactivity limit is set between 1 and 900 seconds. The current setting is $MachineAFKLimitResult seconds. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2MachineAFKLimitResult = "2.3.7.3   - [FAILED] - Machine inactivity limit is set at 0 or greater than 900 seconds. The current setting is $MachineAFKLimitResult seconds.`n"
					$Global:Req2MachineAFKLimitResultHTML = "2.3.7.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine inactivity limit is set at 0 or greater than 900 seconds. The current setting is $MachineAFKLimitResult seconds.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2MachineAFKLimitResult = "2.3.7.3   - [FAILED] - Machine inactivity limit is not defined.`n"
				$Global:Req2MachineAFKLimitResultHTML = "2.3.7.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine inactivity limit is not defined.`n"
				$CISFailCounter++
			}

			# 2.3.7.4 (L1) Configure 'Interactive logon: Message text for users attempting to log on' (Scored)
			$LegalNoticeText = $Global:SecDump | Select-String -SimpleMatch "LegalNoticeText" | Out-String
			$LegalNoticeTextResult = $LegalNoticeText.split(',')[1]
			if(-not([string]::IsNullOrWhiteSpace($LegalNoticeTextResult))){
				$Global:Req2LegalNoticeTextResult = "2.3.7.4   - [PASS] - Message Text for User Log-in Attempt is defined. CIS Compliant.`n"
				$Global:Req2LegalNoticeTextResultHTML = "2.3.7.4   - <span id=`"CISPassStatus`">[PASS]</span> - Message Text for User Log-in Attempt is defined. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2LegalNoticeTextResult = "2.3.7.4   - [FAILED] - Message Text for User Log-in Attempt is not defined.`n"
				$Global:Req2LegalNoticeTextResultHTML = "2.3.7.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Message Text for User Log-in Attempt is not defined.`n"
				$CISFailCounter++
			}

			# 2.3.7.5 (L1) Configure 'Interactive logon: Message title for users attempting to log on' (Scored)
			$LegalNoticeCaption = $Global:SecDump | Select-String -SimpleMatch "LegalNoticeCaption" | Out-String
			$LegalNoticeCaptionResult = $LegalNoticeCaption.split('"')[1]
			$LegalNoticeCaptionResult2 = $LegalNoticeCaptionResult.split('"')[0]
			if(-not([string]::IsNullOrEmpty($LegalNoticeCaptionResult2))){
				$Global:Req2LegalNoticeCaptionResult = "2.3.7.5   - [PASS] - Message Title for User Log in Attempt is defined. CIS Compliant.`n"
				$Global:Req2LegalNoticeCaptionResultHTML = "2.3.7.5   - <span id=`"CISPassStatus`">[PASS]</span> - Message Title for User Log in Attempt is defined. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2LegalNoticeCaptionResult = "2.3.7.5   - [FAILED] - Message Title for User Log in Attempt is not defined.`n"
				$Global:Req2LegalNoticeCaptionResultHTML = "2.3.7.5   - <span id=`"CISFailedStatus`">[FAILED]</span> - Message Title for User Log in Attempt is not defined.`n"
				$CISFailCounter++
			}

			# 2.3.7.6 (L2) Ensure 'Interactive logon: Number of previous logons to cache (in case domain controller is not available)' is set to '4 or fewer logon(s)' (MS only) (Scored)
			$PreviousCachedLogons = $Global:SecDump | Select-String -SimpleMatch 'CachedLogonsCount' | Out-String
			$PreviousCachedLogonsResult = $PreviousCachedLogons.split('"')[1]
			$PreviousCachedLogonsResult = $PreviousCachedLogonsResult -as [int]
			if(-not([string]::IsNullOrEmpty($PreviousCachedLogons))){
				if($PreviousCachedLogonsResult -le "4"){
					$Global:Req2PreviousCachedLogonsResult = "2.3.7.6   - [PASS] - Number of Previous Logons to Cache is set to Four or Fewer Logons. The current value is set to $PreviousCachedLogonsResult. CIS Compliant.`n"
					$Global:Req2PreviousCachedLogonsResultHTML = "2.3.7.6   - <span id=`"CISPassStatus`">[PASS]</span> - Number of Previous Logons to Cache is set to Four or Fewer Logons. The current value is set to $PreviousCachedLogonsResult. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2PreviousCachedLogonsResult = "2.3.7.6   - [FAILED] - Number of Previous Logons to Cache is set Higher than Four Logons. The current value is set to $PreviousCachedLogonsResult.`n"
					$Global:Req2PreviousCachedLogonsResultHTML = "2.3.7.6   - <span id=`"CISFailedStatus`">[FAILED]</span> - Number of Previous Logons to Cache is set Higher than Four Logons. The current value is set to $PreviousCachedLogonsResult.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2PreviousCachedLogonsResult = "2.3.7.6   - [FAILED] - Number of Previous Logons to Cache is Not Defined.`n"
				$Global:Req2PreviousCachedLogonsResultHTML = "2.3.7.6   - <span id=`"CISFailedStatus`">[FAILED]</span> - Number of Previous Logons to Cache is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.7.7 (L1) Ensure 'Interactive logon: Prompt user to change password before expiration' is set to 'between 5 and 14 days' (Scored)
			$PassExpiryWarning = $Global:SecDump | Select-String -SimpleMatch 'PasswordExpiryWarning' | Out-String
			$PassExpiryWarningResult = $PassExpiryWarning.split(',')[1]
			$PassExpiryWarningResult = $PassExpiryWarningResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassExpiryWarning))){
				if(($PassExpiryWarningResult -le 14) -and ($PassExpiryWarningResult -ge 5)){
					$Global:Req2PassExpiryWarningResult = "2.3.7.7   - [PASS] - Prompt User to Change Password Before Expiration is set between 5 and 14 Days. It's set to $PassExpiryWarningResult Days. CIS Compliant.`n"
					$Global:Req2PassExpiryWarningResultHTML = "2.3.7.7   - <span id=`"CISPassStatus`">[PASS]</span> - Prompt User to Change Password Before Expiration is set between 5 and 14 Days. It's set to $PassExpiryWarningResult Days. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2PassExpiryWarningResult = "2.3.7.7   - [FAILED] - Prompt User to Change Password Before Expiration is set greater than 14 Days. It's set to $PassExpiryWarningResult Days.`n"
					$Global:Req2PassExpiryWarningResultHTML = "2.3.7.7   - <span id=`"CISFailedStatus`">[FAILED]</span> - Prompt User to Change Password Before Expiration is set greater than 14 Days. It's set to $PassExpiryWarningResult Days.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2PassExpiryWarningResult = "2.3.7.7   - [FAILED] - Prompt User to Change Password Before Expiration is set to less than 5 Days.`n"
				$Global:Req2PassExpiryWarningResultHTML = "2.3.7.7   - <span id=`"CISFailedStatus`">[FAILED]</span> - Prompt User to Change Password Before Expiration is set to less than 5 Days.`n"
				$CISFailCounter++
			}

			# 2.3.7.8 (L1) Ensure 'Interactive logon: Require Domain Controller Authentication to unlock workstation' is set to 'Enabled' (MS only) (Scored)
			$DCAuthUnlock = $Global:SecDump | Select-String -SimpleMatch 'ForceUnlockLogon' | Out-String
			$DCAuthUnlockResult = $DCAuthUnlock.split(',')[1]
			$DCAuthUnlockResult = $DCAuthUnlockResult -as [int]
			if(-not([string]::IsNullOrEmpty($DCAuthUnlock))){
				if($DCAuthUnlockResult -eq "1"){
					$Global:Req2DCAuthUnlockResult = "2.3.7.8   - [PASS] - Require Domain Controller Authentication to Unlock Workstation is Enabled. CIS Compliant.`n"
					$Global:Req2DCAuthUnlockResultHTML = "2.3.7.8   - <span id=`"CISPassStatus`">[PASS]</span> - Require Domain Controller Authentication to Unlock Workstation is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DCAuthUnlockResult = "2.3.7.8   - [FAILED] - Require Domain Controller Authentication to Unlock Workstation is Disabled.`n"
					$Global:Req2DCAuthUnlockResultHTML = "2.3.7.8   - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Domain Controller Authentication to Unlock Workstation is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DCAuthUnlockResult = "2.3.7.8   - [FAILED] - Require Domain Controller Authentication to Unlock Workstation is Not Configured.`n"
				$Global:Req2DCAuthUnlockResultHTML = "2.3.7.8   - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Domain Controller Authentication to Unlock Workstation is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.7.9 (L1) Ensure 'Interactive logon: Smart card removal behavior' is set to 'Lock Workstation' or higher (Scored
			$SmartCardRemoval = $Global:SecDump | Select-String -SimpleMatch 'ScRemoveOption' | Out-String
			$SmartCardRemovalResult = $SmartCardRemoval.split('"')[1]
			$SmartCardRemovalResult = $SmartCardRemovalResult -as [int]
			if(-not([string]::IsNullOrEmpty($SmartCardRemoval))){
				if($SmartCardRemovalResult -ge "1"){
					$Global:Req2SmartCardRemovalResult = "2.3.7.9   - [PASS] - Smart Card Removal Behaviour is set to 'Lock Workstation' or higher. CIS Compliant.`n"
					$Global:Req2SmartCardRemovalResultHTML = "2.3.7.9   - <span id=`"CISPassStatus`">[PASS]</span> - Smart Card Removal Behaviour is set to 'Lock Workstation' or higher. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2SmartCardRemovalResult = "2.3.7.9   - [FAILED] - Smart Card Removal Behaviour is set lower than 'Lock Workstation'.`n"
					$Global:Req2SmartCardRemovalResultHTML = "2.3.7.9   - <span id=`"CISFailedStatus`">[FAILED]</span> - Smart Card Removal Behaviour is set lower than 'Lock Workstation'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2SmartCardRemovalResult = "2.3.7.9   - [FAILED] - Smart Card Removal Behaviour is Not Configured.`n"
				$Global:Req2SmartCardRemovalResultHTML = "2.3.7.9   - <span id=`"CISFailedStatus`">[FAILED]</span> - Smart Card Removal Behaviour is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.8 Microsoft Network Client
			# 2.3.8.1 (L1) Ensure 'Microsoft network client: Digitally sign communications (always)' is set to 'Enabled' (Scored)
			$DigitallySignAlways = $Global:SecDump | Select-String -SimpleMatch 'LanmanWorkstation\Parameters\RequireSecuritySignature' | Out-String
			$DigitallySignAlwaysResult = $DigitallySignAlways.split(',')[1]
			$DigitallySignAlwaysResult = $DigitallySignAlwaysResult -as [int]
			if(-not([string]::IsNullOrEmpty($DigitallySignAlways))){
				if($DigitallySignAlwaysResult -eq "1"){
					$Global:Req2DigitallySignAlwaysResult = "2.3.8.1   - [PASS] - Digitally Sign Communication (Always) is Enabled. CIS Compliant.`n"
					$Global:Req2DigitallySignAlwaysResultHTML = "2.3.8.1   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally Sign Communication (Always) is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DigitallySignAlwaysResult = "2.3.8.1   - [FAILED] - Digitally Sign Communication (Always) is Disabled.`n"
					$Global:Req2DigitallySignAlwaysResultHTML = "2.3.8.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Communication (Always) is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DigitallySignAlwaysResult = "2.3.8.1   - [FAILED] - Digitally Sign Commuications (Always) is Not Configured.`n"
				$Global:Req2DigitallySignAlwaysResultHTML = "2.3.8.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (Always) is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.8.2 (L1) Ensure 'Microsoft network client: Digitally sign communications (if server agrees)' is set to 'Enabled' (Scored)
			$DigitallySignComsServer = $Global:SecDump | Select-String -SimpleMatch 'LanmanWorkstation\Parameters\EnableSecuritySignature' | Out-String
			$DigitallySignComsServerResult = $DigitallySignComsServer.split(',')[1]
			$DigitallySignComsServerResult = $DigitallySignComsServerResult -as [int]
			if(-not([string]::IsNullOrEmpty($DigitallySignComsServer))){
				if($DigitallySignComsServerResult -eq "1"){
					$Global:Req2DigitallySignComsServerResult = "2.3.8.2   - [PASS] - Digitally Sign Commuications (if server agrees) is Enabled. CIS Compliant.`n"
					$Global:Req2DigitallySignComsServerResultHTML = "2.3.8.2   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally Sign Commuications (if server agrees) is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DigitallySignComsServerResult = "2.3.8.2   - [FAILED] - Digitally Sign Commuications (if server agrees) is Disabled.`n"
					$Global:Req2DigitallySignComsServerResultHTML = "2.3.8.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (if server agrees) is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DigitallySignComsServerResult = "2.3.8.2   - [FAILED] - Digitally Sign Commuications (if server agrees) is Not Configured.`n"
				$Global:Req2DigitallySignComsServerResultHTML = "2.3.8.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (if server agrees) is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.8.3 (L1) Ensure 'Microsoft network client: Send unencrypted password to third-party SMB servers' is set to 'Disabled' (Scored)
			$EnabledPlainText = $Global:SecDump | Select-String -SimpleMatch "EnablePlainTextPassword" | Out-String
			$EnabledPlainTextResult = $EnabledPlainText.split(',')[1]
			$EnabledPlainTextResult = $EnabledPlainTextResult -as [int]
			if($EnabledPlainTextResult -eq "0"){
				$Global:Req2EnablePlainTextResult = "2.3.8.3   - [PASS] - Sending Unencrypted Passwords to SMB server policy is disabled. CIS Compliant.`n"
				$Global:Req2EnablePlainTextResultHTML = "2.3.8.3   - <span id=`"CISPassStatus`">[PASS]</span> - Sending Unencrypted Passwords to SMB server policy is disabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2EnablePlainTextResult = "2.3.8.3   - [FAILED] - Sending Unencrypted Passwords to SMB server policy is enabled.`n"
				$Global:Req2EnablePlainTextResultHTML = "2.3.8.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Sending Unencrypted Passwords to SMB server policy is enabled.`n"
				$CISFailCounter++
			}

			# 2.3.9 Microsoft network server
			# 2.3.9.1 (L1) Ensure 'Microsoft network server: Amount of idle time required before suspending session' is set to '15 or fewer minute(s)' (Scored)
			$SuspendingSessionIdleTime = $Global:SecDump | Select-String -SimpleMatch 'AutoDisconnect' | Out-String
			$SuspendingSessionIdleTimeResult = $SuspendingSessionIdleTime.split(',')[1]
			$SuspendingSessionIdleTimeResult = $SuspendingSessionIdleTimeResult -as [int]
			if(-not([string]::IsNullOrEmpty($SuspendingSessionIdleTime))){
				if($SuspendingSessionIdleTimeResult -le "15"){
					$Global:Req2SuspendingSessionIdleTimeResult = "2.3.9.1   - [PASS] - Amount of Idle Time Required before Suspending Session is set to 15 mins or less. Current Value: $SuspendingSessionIdleTimeResult mins. CIS Compliant.`n"
					$Global:Req2SuspendingSessionIdleTimeResultHTML = "2.3.9.1   - <span id=`"CISPassStatus`">[PASS]</span> - Amount of Idle Time Required before Suspending Session is set to 15 mins or less. Current Value: $SuspendingSessionIdleTimeResult mins. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2SuspendingSessionIdleTimeResult = "2.3.9.1   - [FAILED] - Amount of Idle Time Required before Suspending Session is set higher than 15 mins. Current Value: $SuspendingSessionIdleTimeResult mins.`n"
					$Global:Req2SuspendingSessionIdleTimeResultHTML = "2.3.9.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Amount of Idle Time Required before Suspending Session is set higher than 15 mins. Current Value: $SuspendingSessionIdleTimeResult mins.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2SuspendingSessionIdleTimeResult = "2.3.9.1   - [FAILED] - Amount of Idle Time Required before Suspending Session is Not Defined.`n"
				$Global:Req2SuspendingSessionIdleTimeResultHTML = "2.3.9.1   - <span id=`"CISFailedStatus`">[FAILED]</span> - Amount of Idle Time Required before Suspending Session is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.9.2 (L1) Ensure 'Microsoft network server: Digitally sign communications (always)' is set to 'Enabled' (Scored)
			$DigitallySignComsForced = $Global:SecDump | Select-String -SimpleMatch 'LanManServer\Parameters\RequireSecuritySignature' | Out-String
			$DigitallySignComsForcedResult = $DigitallySignComsForced.split(',')[1]
			$DigitallySignComsForcedResult = $DigitallySignComsForcedResult -as [int]
			if(-not([string]::IsNullOrEmpty($DigitallySignComsForced))){
				if($DigitallySignComsForcedResult -eq "1"){
					$Global:Req2DigitallySignComsForcedResult = "2.3.9.2   - [PASS] - Digitally Sign Commuications (always) is Enabled. CIS Compliant.`n"
					$Global:Req2DigitallySignComsForcedResultHTML = "2.3.9.2   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally Sign Commuications (always) is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DigitallySignComsForcedResult = "2.3.9.2   - [FAILED] - Digitally Sign Commuications (always) is Disabled.`n"
					$Global:Req2DigitallySignComsForcedResultHTML = "2.3.9.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (always) is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DigitallySignComsForcedResult = "2.3.9.2   - [FAILED] - Digitally Sign Commuications (always) is Not Configured.`n"
				$Global:Req2DigitallySignComsForcedResultHTML = "2.3.9.2   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (always) is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.9.3 (L1) Ensure 'Microsoft network server: Digitally sign communications (if client agrees)' is set to 'Enabled' (Scored)
			$DigitallySignComsClient = $Global:SecDump | Select-String -SimpleMatch 'LanManServer\Parameters\EnableSecuritySignature' | Out-String
			$DigitallySignComsClientResult = $DigitallySignComsClient.split(',')[1]
			$DigitallySignComsClientResult = $DigitallySignComsClientResult -as [int]
			if(-not([string]::IsNullOrEmpty($DigitallySignComsClient))){
				if($DigitallySignComsClientResult -eq "1"){
					$Global:Req2DigitallySignComsClientResult = "2.3.9.3   - [PASS] - Digitally Sign Commuications (if client agrees) is Enabled. CIS Compliant.`n"
					$Global:Req2DigitallySignComsClientResultHTML = "2.3.9.3   - <span id=`"CISPassStatus`">[PASS]</span> - Digitally Sign Commuications (if client agrees) is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2DigitallySignComsClientResult = "2.3.9.3   - [FAILED] - Digitally Sign Commuications (if client agrees) is Disabled.`n"
					$Global:Req2DigitallySignComsClientResultHTML = "2.3.9.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (if client agrees) is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2DigitallySignComsClientResult = "2.3.9.3   - [FAILED] - Digitally Sign Commuications (if client agrees) is Not Configured.`n"
				$Global:Req2DigitallySignComsClientResultHTML = "2.3.9.3   - <span id=`"CISFailedStatus`">[FAILED]</span> - Digitally Sign Commuications (if client agrees) is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.9.4 (L1) Ensure 'Microsoft network server: Disconnect clients when logon hours expire' is set to 'Enabled' (Scored)
			$ForcedClientLogoff = $Global:SecDump | Select-String -SimpleMatch 'EnableForcedLogoff' | Out-String
			$ForcedClientLogoffResult = $ForcedClientLogoff.split(',')[1]
			$ForcedClientLogoffResult = $ForcedClientLogoffResult -as [int]
			if(-not([string]::IsNullOrEmpty($ForcedClientLogoff))){
				if($ForcedClientLogoffResult -eq "1"){
					$Global:Req2ForcedClientLogoffResult = "2.3.9.4   - [PASS] - Clients are Disconnected when Logon Hours Expire. CIS Compliant.`n"
					$Global:Req2ForcedClientLogoffResultHTML = "2.3.9.4   - <span id=`"CISPassStatus`">[PASS]</span> - Clients are Disconnected when Logon Hours Expire. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ForcedClientLogoffResult = "2.3.9.4   - [FAILED] - Clients are Not Disconnected when Logon Hours Expire.`n"
					$Global:Req2ForcedClientLogoffResultHTML = "2.3.9.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Clients are Not Disconnected when Logon Hours Expire.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ForcedClientLogoffResult = "2.3.9.4   - [FAILED] - Disconnect Clients when Logon Hours Expire is Not Defined.`n"
				$Global:Req2ForcedClientLogoffResultHTML = "2.3.9.4   - <span id=`"CISFailedStatus`">[FAILED]</span> - Disconnect Clients when Logon Hours Expire is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.10 Network access
			# 2.3.10.1 (L1) Ensure 'Network access: Allow anonymous SID/Name translation' is set to 'Disabled' (Scored)
			$SIDNameLookup = $Global:SecDump | Select-String -SimpleMatch 'LSAAnonymousNameLookup' | Out-String
			$SIDNameLookupResult = $SIDNameLookup.split(' ')[2]
			$SIDNameLookupResult = $SIDNameLookupResult -as [int]
			if($SIDNameLookupResult -eq "0"){
				$Global:Req2SIDNameLookupResult = "2.3.10.1  - [PASS] - Allowing SID/Name Translation Policy is disbled. CIS Compliant.`n"
				$Global:Req2SIDNameLookupResultHTML = "2.3.10.1  - <span id=`"CISPassStatus`">[PASS]</span> - Allowing SID/Name Translation Policy is disbled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2SIDNameLookupResult = "2.3.10.1  - [FAILED] - Allowing SID/Name Transaltion Policy is enabled.`n"
				$Global:Req2SIDNameLookupResultHTML = "2.3.10.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allowing SID/Name Transaltion Policy is enabled.`n"
				$CISFailCounter++
			}
			
			# 2.3.10.2 (L1) Ensure 'Network access: Do not allow anonymous enumeration of SAM accounts' is set to 'Enabled' (MS only) (Scored)
			$RestrictAnonymousSAM = $Global:SecDump | Select-String -SimpleMatch 'RestrictAnonymousSAM' | Out-String
			$RestrictAnonymousSAMResult = $RestrictAnonymousSAM.split(',')[1]
			$RestrictAnonymousSAMResult = $RestrictAnonymousSAMResult -as [int]
			if(-not([string]::IsNullOrEmpty($RestrictAnonymousSAM))){
				if($RestrictAnonymousSAMResult -eq "1"){
					$Global:Req2RestrictAnonymousSAMResult = "2.3.10.2  - [PASS] - Do not allow Anonymous Enumeration of SAM Accounts is Enabled. (MS Only) CIS Compliant.`n"
					$Global:Req2RestrictAnonymousSAMResultHTML = "2.3.10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Do not allow Anonymous Enumeration of SAM Accounts is Enabled. (MS Only) CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RestrictAnonymousSAMResult = "2.3.10.2  - [FAILED] - Do not allow Anonymous Enumeration of SAM Accounts is Disabled. (MS Only)`n"
					$Global:Req2RestrictAnonymousSAMResultHTML = "2.3.10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow Anonymous Enumeration of SAM Accounts is Disabled. (MS Only)`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RestrictAnonymousSAMResult = "2.3.10.2  - [FAILED] - Do not allow Anonymous Enumeration of SAM Accounts is Not Configured. (MS Only)`n"
				$Global:Req2RestrictAnonymousSAMResultHTML = "2.3.10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow Anonymous Enumeration of SAM Accounts is Not Configured. (MS Only)`n"
				$CISFailCounter++
			}

			# 2.3.10.3 (L1) Ensure 'Network access: Do not allow anonymous enumeration of SAM accounts and shares' is set to 'Enabled' (MS only) (Scored)
			$AnonymousEmuerationAccounts = $Global:SecDump | Select-String -SimpleMatch 'RestrictAnonymous=' | Out-String
			$AnonymousEmuerationAccountsResult = $AnonymousEmuerationAccounts.split(',')[1]
			$AnonymousEmuerationAccountsResult = $AnonymousEmuerationAccountsResult -as [int]
			if(-not([string]::IsNullOrEmpty($AnonymousEmuerationAccounts))){
				if($AnonymousEmuerationAccountsResult -eq "1"){
					$Global:Req2AnonymousEmuerationAccountsResult = "2.3.10.3  - [PASS] - Do not allow Anonymous Enueration of SAM Accounts and Shares is Enabled. (MS Only) CIS Compliant.`n"
					$Global:Req2AnonymousEmuerationAccountsResultHTML = "2.3.10.3  - <span id=`"CISPassStatus`">[PASS]</span> - Do not allow Anonymous Enueration of SAM Accounts and Shares is Enabled. (MS Only) CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AnonymousEmuerationAccountsResult = "2.3.10.3  - [FAILED] - Do not allow Anonymous Enueration of SAM Accounts and Shares is Disabled. (MS Only)`n"
					$Global:Req2AnonymousEmuerationAccountsResultHTML = "2.3.10.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow Anonymous Enueration of SAM Accounts and Shares is Disabled. (MS Only)`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AnonymousEmuerationAccountsResult = "2.3.10.3  - [FAILED] - Do not allow Anonymous Enueration of SAM Accounts and Shares is Not Configured. (MS Only)`n"
				$Global:Req2AnonymousEmuerationAccountsResultHTML = "2.3.10.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow Anonymous Enueration of SAM Accounts and Shares is Not Configured. (MS Only)`n"
				$CISFailCounter++
			}

			# 2.3.10.4 (L2) Ensure 'Network access: Do not allow storage of passwords and credentials for network authentication' is set to 'Enabled' (Scored)
			$StorageOfPasswords = $Global:SecDump | Select-String -SimpleMatch 'DisableDomainCreds' | Out-String
			$StorageOfPasswordsResult = $StorageOfPasswords.split(',')[1]
			$StorageOfPasswordsResult = $StorageOfPasswordsResult -as [int]
			if(-not([string]::IsNullOrEmpty($StorageOfPasswords))){
				if($StorageOfPasswordsResult -eq "1"){
					$Global:Req2StorageOfPasswordsResult = "2.3.10.4  - [PASS] - Do not allow storage of passwords and credentials for network authentication is Enabled. CIS Compliant.`n"
					$Global:Req2StorageOfPasswordsResultHTML = "2.3.10.4  - <span id=`"CISPassStatus`">[PASS]</span> - Do not allow storage of passwords and credentials for network authentication is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2StorageOfPasswordsResult = "2.3.10.4  - [FAILED] - Do not allow storage of passwords and credentials for network authentication is Disabled.`n"
					$Global:Req2StorageOfPasswordsResultHTML = "2.3.10.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow storage of passwords and credentials for network authentication is Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2StorageOfPasswordsResult = "2.3.10.4  - [FAILED] - Do not allow storage of passwords and credentials for network authentication is Not Configured. (MS Only)`n"
				$Global:Req2StorageOfPasswordsResultHTML = "2.3.10.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Do not allow storage of passwords and credentials for network authentication is Not Configured. (MS Only)`n"
				$CISFailCounter++
			}

			# 2.3.10.5 (L1) Ensure 'Network access: Let Everyone permissions apply to anonymous users' is set to 'Disabled' (Scored)
			$AllIncludesPolicies = $Global:SecDump | Select-String -SimpleMatch 'EveryoneIncludesAnonymous' | Out-String
			$AllIncludesPoliciesResult = $AllIncludesPolicies.split(',')[1]
			$AllIncludesPoliciesResult = $AllIncludesPoliciesResult -as [int]
			if($AllIncludesPoliciesResult -eq "0"){
				$Global:Req2AllIncludesPoliciesResult = "2.3.10.5  - [PASS] - Let Everyone Permission Apply to Anonymous Users Policy is disabled. CIS Compliant.`n"
				$Global:Req2AllIncludesPoliciesResultHTML = "2.3.10.5  - <span id=`"CISPassStatus`">[PASS]</span> - Let Everyone Permission Apply to Anonymous Users Policy is disabled. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2AllIncludesPoliciesResult = "2.3.10.5  - [FAILED] - Let Everyone Permission Apply to Anonymous Users Policy is enabled.`n"
				$Global:Req2AllIncludesPoliciesResultHTML = "2.3.10.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - Let Everyone Permission Apply to Anonymous Users Policy is enabled.`n"
				$CISFailCounter++
			}

			# 2.3.10.6 (L1) Configure 'Network access: Named Pipes that can be accessed anonymously' (DC only) (Scored)
			$AnonymousNamedPipes = $Global:SecDump | Select-String -SimpleMatch 'NullSessionPipes' | Out-String
			if(-not([string]::IsNullOrEmpty($AnonymousNamedPipes))){
				$ProcessedNamedPipes = $AnonymousNamedPipes -replace '`n|`r|"| ',""
				$CharCount = ($ProcessedNamedPipes.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
				$CharArray = $ProcessedNamedPipes.Split(",")
				#Counters
				$ResultCounter = 0
				# Check Array
				foreach($Pipe in $CharArray){
					$Pipe = $Pipe.ToLower()
					$Pipe = $Pipe.Replace("`n","")
					$Pipe = $Pipe.Replace("`r","")
					if(($Pipe -eq "netlogon") -or ($Pipe -eq "samr") -or ($Pipe -eq "lsarpc")){
						$ResultCounter++
					}
				}
				# Check Data
				if($ResultCounter -eq "3"){
					$Global:Req2AnonymousNamedPipesResult = "2.3.10.6  - [PASS] - Named Pipes that are Accessed Anonymously are Configured Correctly. CIS Compliant.`n"
					$Global:Req2AnonymousNamedPipesResultHTML = "2.3.10.6  - <span id=`"CISPassStatus`">[PASS]</span> - Named Pipes that are Accessed Anonymously are Configured Correctly. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AnonymousNamedPipesResult = "2.3.10.6  - [FAILED] - Named Pipes that are Accessed Anonymously are Not Configured Correctly.`n"
					$Global:Req2AnonymousNamedPipesResultHTML = "2.3.10.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - Named Pipes that are Accessed Anonymously are Not Configured Correctly.`n"
					$CISFailCounter++
				}
			# Edge Case
			}else{
				$Global:Req2AnonymousNamedPipesResult = "2.3.10.6  - [FAILED] - Named Pipes that are Accessed Anonymously are Not Defined.`n"
				$Global:Req2AnonymousNamedPipesResultHTML = "2.3.10.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - Named Pipes that are Accessed Anonymously are Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.10.8 (L1) Configure 'Network access: Remotely accessible registry paths' (Scored)
			$AllowedExactPaths = $Global:SecDump | Select-String -SimpleMatch 'AllowedExactPaths\Machine' | Out-String
			if(-not([string]::IsNullOrEmpty($AllowedExactPaths))){
				$ProcessedExactPaths = $AllowedExactPaths -replace '`n|`r|"| ',""
				$CharCountPaths = ($ProcessedExactPaths.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
				$CharArrayPaths = $ProcessedExactPaths.Split(",")
				#Counters
				$ResultCounterPaths = 0
				# Check Array
				foreach($PathPipe in $CharArrayPaths){
					$PathPipe = $PathPipe.ToLower()
					$PathPipe = $PathPipe.Replace("`n","")
					$PathPipe = $PathPipe.Replace("`r","")
					if(($PathPipe -eq "system\currentcontrolset\control\productoptions") -or ($PathPipe -eq "system\currentcontrolset\control\serverapplications") -or ($PathPipe -eq "software\microsoft\windowsnt\currentversion")){
						$ResultCounterPaths++
					}
				}
				# Check Data
				if($ResultCounterPaths -eq "3"){
					$Global:Req2AllowedExactPathsResult = "2.3.10.8  - [PASS] - Remotely accessible Registry Paths are Matched. CIS Compliant.`n"
					$Global:Req2AllowedExactPathsResultHTML = "2.3.10.8  - <span id=`"CISPassStatus`">[PASS]</span> - Remotely accessible Registry Paths are Matched. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AllowedExactPathsResult = "2.3.10.8  - [FAILED] - Remotely accessible Registry Paths are not Matched.`n"
					$Global:Req2AllowedExactPathsResultHTML = "2.3.10.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - Remotely accessible Registry Paths are not Matched.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AllowedExactPathsResult = "2.3.10.8  - [FAILED] - Remotely accessible Registry Paths are not defined.`n"
				$Global:Req2AllowedExactPathsResultHTML = "2.3.10.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - Remotely accessible Registry Paths are not defined.`n"
				$CISFailCounter++
			}

			# 2.3.10.10 (L1) Ensure 'Network access: Restrict anonymous access to Named Pipes and Shares' is set to 'Enabled' (Scored)
			$RestrictAnnonymousAccessSessions = $Global:SecDump | Select-String -SimpleMatch 'RestrictNullSessAccess' | Out-String
			$RestrictAnnonymousAccessSessionsResult = $RestrictAnnonymousAccessSessions.split(',')[1]
			$RestrictAnnonymousAccessSessionsResult = $RestrictAnnonymousAccessSessionsResult -as [int]
			if(-not([string]::IsNullOrEmpty($RestrictAnnonymousAccessSessions))){
				if($RestrictAnnonymousAccessSessionsResult -eq "1"){
					$Global:Req2RestrictAnnonymousAccessSessionsResult = "2.3.10.10 - [PASS] - Restrict anonymous access to Named Pipes and Shares is Enabled. CIS Compliant.`n"
					$Global:Req2RestrictAnnonymousAccessSessionsResultHTML = "2.3.10.10 - <span id=`"CISPassStatus`">[PASS]</span> - Restrict anonymous access to Named Pipes and Shares is Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RestrictAnnonymousAccessSessionsResult = "2.3.10.10 - [FAILED] - Restrict anonymous access to Named Pipes and Shares is Enabled.`n"
					$Global:Req2RestrictAnnonymousAccessSessionsResultHTML = "2.3.10.10 - <span id=`"CISFailedStatus`">[FAILED]</span> - Restrict anonymous access to Named Pipes and Shares is Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RestrictAnnonymousAccessSessionsResult = "2.3.10.10 - [FAILED] - Restrict anonymous access to Named Pipes and Shares is Enabled is Not Configured.`n"
				$Global:Req2RestrictAnnonymousAccessSessionsResultHTML = "2.3.10.10 - <span id=`"CISFailedStatus`">[FAILED]</span> - Restrict anonymous access to Named Pipes and Shares is Enabled is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.10.12 (L1) Ensure 'Network access: Shares that can be accessed anonymously' is set to 'None' (Scored)
			$NullSessionShares = $Global:SecDump | Select-String -SimpleMatch 'NullSessionShares' | Out-String
			$NullSessionSharesResult = $NullSessionShares.split(',')[1]
			if([string]::IsNullOrWhiteSpace($NullSessionSharesResult)){
				$Global:Req2NullSessionShares = "2.3.10.12 - [PASS] - Shares that can be accessed Anonymously is empty. CIS Compliant.`n"
				$Global:Req2NullSessionSharesHTML = "2.3.10.12 - <span id=`"CISPassStatus`">[PASS]</span> - Shares that can be accessed Anonymously is empty. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2NullSessionShares = "2.3.10.12 - [FAILED] - Shares that can be accessed Anonymously is defined.`n"
				$Global:Req2NullSessionSharesHTML = "2.3.10.12 - <span id=`"CISFailedStatus`">[FAILED]</span> - Shares that can be accessed Anonymously is defined.`n"
				$CISFailCounter++
			}

			# 2.3.10.13 (L1) Ensure 'Network access: Sharing and security model for local accounts' is set to 'Classic - local users authenticate as themselves' (Scored)
			$SharingAndSecModelLocalAccounts = $Global:SecDump | Select-String -SimpleMatch 'ForceGuest' | Out-String
			$SharingAndSecModelLocalAccountsResult = $SharingAndSecModelLocalAccounts.split(',')[1]
			$SharingAndSecModelLocalAccountsResult = $SharingAndSecModelLocalAccountsResult -as [int]
			if(-not([string]::IsNullOrEmpty($SharingAndSecModelLocalAccounts))){
				if($SharingAndSecModelLocalAccountsResult -eq "0"){
					$Global:Req2SharingAndSecModelLocalAccountsResult = "2.3.10.13 - [PASS] - Sharing and security model for local accounts is set to Classic - local users authenticate as themselves. CIS Compliant.`n"
					$Global:Req2SharingAndSecModelLocalAccountsResultHTML = "2.3.10.13 - <span id=`"CISPassStatus`">[PASS]</span> - Sharing and security model for local accounts is set to Classic - local users authenticate as themselves. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2SharingAndSecModelLocalAccountsResult = "2.3.10.13 - [FAILED] - Sharing and security model for local accounts is not set to Classic - local users authenticate as themselves.`n"
					$Global:Req2SharingAndSecModelLocalAccountsResultHTML = "2.3.10.13 - <span id=`"CISFailedStatus`">[FAILED]</span> - Sharing and security model for local accounts is not set to Classic - local users authenticate as themselves.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2SharingAndSecModelLocalAccountsResult = "2.3.10.13 - [FAILED] - Sharing and security model for local accounts is Not Configured.`n"
				$Global:Req2SharingAndSecModelLocalAccountsResultHTML = "2.3.10.13 - <span id=`"CISFailedStatus`">[FAILED]</span> - Sharing and security model for local accounts is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.11 Network Security
			# 2.3.11.1 (L1) Ensure 'Network security: Allow Local System to use computer identity for NTLM' is set to 'Enabled' (Scored) !!
			$LocalSystemNTLM = $Global:SecDump | Select-String -SimpleMatch 'UseMachineId' | Out-String
			$LocalSystemNTLMResult = $LocalSystemNTLM.split(',')[1]
			$LocalSystemNTLMResult = $LocalSystemNTLMResult -as [int]
			if(-not([string]::IsNullOrEmpty($LocalSystemNTLM))){
				if($LocalSystemNTLMResult -eq "1"){
					$Global:Req2LocalSystemNTLMResult = "2.3.11.1  - [PASS] - Allow Local System to use Computer Identity for NTLM is set to Enabled. CIS Compliant.`n"
					$Global:Req2LocalSystemNTLMResultHTML = "2.3.11.1  - <span id=`"CISPassStatus`">[PASS]</span> - Allow Local System to use Computer Identity for NTLM is set to Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LocalSystemNTLMResult = "2.3.11.1  - [FAILED] - Allow Local System to use Computer Identity for NTLM is Not Enabled.`n"
					$Global:Req2LocalSystemNTLMResultHTML = "2.3.11.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow Local System to use Computer Identity for NTLM is Not Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LocalSystemNTLMResult = "2.3.11.1  - [FAILED] - Allow Local System to use Computer Identity for NTLM is Not Defined.`n"
				$Global:Req2LocalSystemNTLMResultHTML = "2.3.11.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow Local System to use Computer Identity for NTLM is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.11.2 (L1) Ensure 'Network security: Allow LocalSystem NULL session fallback' is set to 'Disabled' (Scored) !!
			$LocalSystemNULLSession = $Global:SecDump | Select-String -SimpleMatch 'AllowNullSessionFallback' | Out-String
			$LocalSystemNULLSessionResult = $LocalSystemNULLSession.split(',')[1]
			$LocalSystemNULLSessionResult = $LocalSystemNULLSessionResult -as [int]
			if(-not([string]::IsNullOrEmpty($LocalSystemNULLSession))){
				if($LocalSystemNULLSessionResult -eq "0"){
					$Global:Req2LocalSystemNULLSessionResult = "2.3.11.2  - [PASS] - Allow Local System NULL Session is set to Disabled. CIS Compliant.`n"
					$Global:Req2LocalSystemNULLSessionResultHTML = "2.3.11.2  - <span id=`"CISPassStatus`">[PASS]</span> - Allow Local System NULL Session is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LocalSystemNULLSessionResult = "2.3.11.2  - [FAILED] - Allow Local System NULL Session is Not Disabled.`n"
					$Global:Req2LocalSystemNULLSessionResultHTML = "2.3.11.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow Local System NULL Session is Not Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LocalSystemNULLSessionResult = "2.3.11.2  - [FAILED] - Allow Local System NULL Session is Not Defined.`n"
				$Global:Req2LocalSystemNULLSessionResultHTML = "2.3.11.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow Local System NULL Session is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.11.3 (L1) Ensure 'Network Security: Allow PKU2U authentication requests to this computer to use online identities' is set to 'Disabled' (Scored) !!
			$PKU2UOnlineIdentities = $Global:SecDump | Select-String -SimpleMatch 'AllowOnlineID' | Out-String
			$PKU2UOnlineIdentitiesResult = $PKU2UOnlineIdentities.split(',')[1]
			$PKU2UOnlineIdentitiesResult = $PKU2UOnlineIdentitiesResult -as [int]
			if(-not([string]::IsNullOrEmpty($PKU2UOnlineIdentities))){
				if($PKU2UOnlineIdentitiesResult -eq "0"){
					$Global:Req2PKU2UOnlineIdentitiesResult = "2.3.11.3  - [PASS] - Allow PKU2U Authentication Requests to this Computer to use Online Identities is set to Disabled. CIS Compliant.`n"
					$Global:Req2PKU2UOnlineIdentitiesResultHTML = "2.3.11.3  - <span id=`"CISPassStatus`">[PASS]</span> - Allow PKU2U Authentication Requests to this Computer to use Online Identities is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2PKU2UOnlineIdentitiesResult = "2.3.11.3  - [FAILED] - Allow PKU2U Authentication Requests to this Computer to use Online Identities is Not Disabled.`n"
					$Global:Req2PKU2UOnlineIdentitiesResultHTML = "2.3.11.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow PKU2U Authentication Requests to this Computer to use Online Identities is Not Disabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2PKU2UOnlineIdentitiesResult = "2.3.11.3  - [FAILED] - Allow PKU2U Authentication Requests to this Computer to use Online Identities is Not Defined.`n"
				$Global:Req2PKU2UOnlineIdentitiesResultHTML = "2.3.11.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow PKU2U Authentication Requests to this Computer to use Online Identities is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.11.4 (L1) Ensure 'Network security: Configure encryption types allowed for Kerberos' is set to 'AES128_HMAC_SHA1,AES256_HMAC_SHA1, Future encryption types' (Scored) !!
			$KerberosEncryptionTypes = $Global:SecDump | Select-String -SimpleMatch 'SupportedEncryptionTypes' | Out-String
			$ProcessedNamedPipesKerberos = $KerberosEncryptionTypes -replace "`n|`r",""
			$KerberosEncryptionTypesResult = $ProcessedNamedPipesKerberos.split(',')[1]
			if(-not([string]::IsNullOrEmpty($KerberosEncryptionTypes))){
				if($KerberosEncryptionTypesResult -eq "2147483640"){
					$Global:Req2KerberosEncryptionTypesResult = "2.3.11.4  - [PASS] - Encryption types allowed for Kerberos is set to AES128_HMAC_SHA1, AES256_HMAC_SHA1 and Future encryption types. CIS Compliant.`n"
					$Global:Req2KerberosEncryptionTypesResultHTML = "2.3.11.4  - <span id=`"CISPassStatus`">[PASS]</span> - Encryption types allowed for Kerberos is set to AES128_HMAC_SHA1, AES256_HMAC_SHA1 and Future encryption types. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2KerberosEncryptionTypesResult = "2.3.11.4  - [FAILED] - Encryption types allowed for Kerberos is Not set to AES128_HMAC_SHA1, AES256_HMAC_SHA1 and Future encryption types.`n"
					$Global:Req2KerberosEncryptionTypesResultHTML = "2.3.11.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Encryption types allowed for Kerberos is Not set to AES128_HMAC_SHA1, AES256_HMAC_SHA1 and Future encryption types.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2KerberosEncryptionTypesResult = "2.3.11.4  - [FAILED] - Encryption types allowed for Kerberos is Not Defined.`n"
				$Global:Req2KerberosEncryptionTypesResultHTML = "2.3.11.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Encryption types allowed for Kerberos is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.11.5 (L1) Ensure 'Network security: Do not store LAN Manager hash value on next password change' is set to 'Enabled' (Scored)
			$LanManagerHash = $Global:SecDump | Select-String -SimpleMatch 'NoLMHash' | Out-String
			$LanManagerHashResult = $LanManagerHash.split(',')[1]
			$LanManagerHashResult = $LanManagerHashResult -as [int]
			if(-not([string]::IsNullOrEmpty($LanManagerHash))){
				if($LanManagerHashResult -eq "1"){
					$Global:Req2LanManagerHashResult = "2.3.11.5  - [PASS] - LAN Manager Hash Value is Not Stored on Next Password Change. CIS Compliant.`n"
					$Global:Req2LanManagerHashResultHTML = "2.3.11.5  - <span id=`"CISPassStatus`">[PASS]</span> - LAN Manager Hash Value is Not Stored on Next Password Change. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LanManagerHashResult = "2.3.11.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - LAN Manager Hash Value is Stored on Next Password Change.`n"
					$Global:Req2LanManagerHashResultHTML = "2.3.11.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - LAN Manager Hash Value is Stored on Next Password Change.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LanManagerHashResult = "2.3.11.5  - [FAILED] - LAN Manager Hash Value is Not Defined.`n"
				$Global:Req2LanManagerHashResultHTML = "2.3.11.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - LAN Manager Hash Value is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.11.6 (L1) Ensure 'Network security: Force logoff when logon hours expire' is set to 'Enabled' (Not Scored) - Needs more testing
			$ForceLogoffAfterHoursExpire = $Global:SecDump | Select-String -SimpleMatch 'ForceLogoffWhenHourExpire' | Out-String
			$ForceLogoffAfterHoursExpireResult = $ForceLogoffAfterHoursExpire.split(' ')[2]
			$ForceLogoffAfterHoursExpireResult = $ForceLogoffAfterHoursExpireResult -as [int]
			if(-not([string]::IsNullOrEmpty($ForceLogoffAfterHoursExpire))){
				if($ForceLogoffAfterHoursExpireResult -eq "1"){
					$Global:Req2ForceLogoffAfterHoursExpireResult = "2.3.11.6  - [PASS] - Users are forced to Logoff when Logon Hours Expire. CIS Compliant.`n"
					$Global:Req2ForceLogoffAfterHoursExpireResultHTML = "2.3.11.6  - <span id=`"CISPassStatus`">[PASS]</span> - Users are forced to Logoff when Logon Hours Expire. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ForceLogoffAfterHoursExpireResult = "2.3.11.6  - [FAILED] - Users are not forced to Logoff when Logon Hours Expire.`n"
					$Global:Req2ForceLogoffAfterHoursExpireResultHTML = "2.3.11.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - Users are not forced to Logoff when Logon Hours Expire.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ForceLogoffAfterHoursExpireResult = "2.3.11.6  - [FAILED] - User Configuration for Forcing Users to Logoff after Logon hours expires is Not Configured.`n"
				$Global:Req2ForceLogoffAfterHoursExpireResultHTML = "2.3.11.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - User Configuration for Forcing Users to Logoff after Logon hours expires is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.11.7 (L1) Ensure 'Network security: LAN Manager authentication level' is set to 'Send NTLMv2 response only. Refuse LM & NTLM' (Scored)
			$LanManagerAuthLevel = $Global:SecDump | Select-String -SimpleMatch 'LmCompatibilityLevel' | Out-String
			$LanManagerAuthLevelResult = $LanManagerAuthLevel.split(',')[1]
			$LanManagerAuthLevelResult = $LanManagerAuthLevelResult -as [int]
			if(-not([string]::IsNullOrEmpty($LanManagerAuthLevel))){
				if($LanManagerAuthLevelResult -eq "5"){
					$Global:Req2LanManagerAuthLevelResult = "2.3.11.7  - [PASS] - LAN Manager Authentication Level is set to 'Send NTLMv2 response only. Refuse LM & NTLM'. CIS Compliant.`n"
					$Global:Req2LanManagerAuthLevelResultHTML = "2.3.11.7  - <span id=`"CISPassStatus`">[PASS]</span> - LAN Manager Authentication Level is set to 'Send NTLMv2 response only. Refuse LM & NTLM'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LanManagerAuthLevelResult = "2.3.11.7  - [FAILED] - LAN Manager Authentication Level is Not set to 'Send NTLMv2 response only. Refuse LM & NTLM'.`n"
					$Global:Req2LanManagerAuthLevelResultHTML = "2.3.11.7  - <span id=`"CISFailedStatus`">[FAILED]</span> - LAN Manager Authentication Level is Not set to 'Send NTLMv2 response only. Refuse LM & NTLM'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LanManagerAuthLevelResult = "2.3.11.7  - [FAILED] - LAN Manager Authentication Level is Not Configured.`n"
				$Global:Req2LanManagerAuthLevelResultHTML = "2.3.11.7  - <span id=`"CISFailedStatus`">[FAILED]</span> - LAN Manager Authentication Level is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.11.8 (L1) Ensure 'Network security: LDAP client signing requirements' is set to 'Negotiate signing' or higher (Scored)
			$LDAPClientSigningReqs = $Global:SecDump | Select-String -SimpleMatch 'LDAPClientIntegrity' | Out-String
			$LDAPClientSigningReqsResult = $LDAPClientSigningReqs.split(',')[1]
			$LDAPClientSigningReqsResult = $LDAPClientSigningReqsResult -as [int]
			if(-not([string]::IsNullOrEmpty($LDAPClientSigningReqs))){
				if($LDAPClientSigningReqsResult -ge "1"){
					$Global:Req2LDAPClientSigningReqsResult = "2.3.11.8  - [PASS] - LDAP Client Signing Requirements is set to 'Negotidate Signing' or Higher. CIS Compliant.`n"
					$Global:Req2LDAPClientSigningReqsResultHTML = "2.3.11.8  - <span id=`"CISPassStatus`">[PASS]</span> - LDAP Client Signing Requirements is set to 'Negotidate Signing' or Higher. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2LDAPClientSigningReqsResult = "2.3.11.8  - [FAILED] - LDAP Client Signing Requirements is set to 'None'.`n"
					$Global:Req2LDAPClientSigningReqsResultHTML = "2.3.11.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - LDAP Client Signing Requirements is set to 'None'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2LDAPClientSigningReqsResult = "2.3.11.8  - [FAILED] - LDAP Client Signing Requirements is Not Configured.`n"
				$Global:Req2LDAPClientSigningReqsResultHTML = "2.3.11.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - LDAP Client Signing Requirements is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.11.9 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based (including secure RPC) clients' is set to 'Require NTLMv2 session security, Require 128-bit encryption' (Scored)
			$NTLMMinClient = $Global:SecDump | Select-String -SimpleMatch "NTLMMinClientSec" | Out-String
			$NTLMMinClientResults = $NTLMMinClient.split(',')[1]
			$NTLMMinClientResults = $NTLMMinClientResults -as [int]
			if($NTLMMinClientResults -eq "537395200"){
				$Global:Req2NTLMMinClientResults = "2.3.11.9  - [PASS] - Minimum Session Security for NTLM SSP based Clients is following the recommended settings. CIS Compliant.`n"
				$Global:Req2NTLMMinClientResultsHTML = "2.3.11.9  - <span id=`"CISPassStatus`">[PASS]</span> - Minimum Session Security for NTLM SSP based Clients is following the recommended settings. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2NTLMMinClientResults = "2.3.11.9  - [FAILED] - Minimum Session Security of NTLMv2 Sessions Security & 128-bit encryption is Not Enabled for NTLM SSP based Clients.`n"
				$Global:Req2NTLMMinClientResultsHTML = "2.3.11.9  - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Session Security of NTLMv2 Sessions Security & 128-bit encryption is Not Enabled for NTLM SSP based Clients.`n"
				$CISFailCounter++
			}

			# 2.3.11.10 (L1) Ensure 'Network security: Minimum session security for NTLM SSP based (including secure RPC) servers' is set to 'Require NTLMv2 session security, Require 128-bit encryption' (Scored)
			$NTLMMinServer = $Global:SecDump | Select-String -SimpleMatch "NTLMMinServerSec" | Out-String
			$NTLMMinServerResults = $NTLMMinServer.split(',')[1]
			$NTLMMinServerResults = $NTLMMinServerResults -as [int]
			if($NTLMMinServerResults -eq "537395200"){
				$Global:Req2NTLMMinServerResults = "2.3.11.10 - [PASS] - Minimum Session Security for NTLM SSP based Servers is following the recommended setting. CIS Compliant.`n"
				$Global:Req2NTLMMinServerResultsHTML = "2.3.11.10 - <span id=`"CISPassStatus`">[PASS]</span> - Minimum Session Security for NTLM SSP based Servers is following the recommended setting. CIS Compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2NTLMMinServerResults = "2.3.11.10 - [FAILED] - Minimum Sessions Security for NTLM SSP Based Servers does not have both NTLMv2 and 128-bit encryption enabled.`n"
				$Global:Req2NTLMMinServerResultsHTML = "2.3.11.10 - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Sessions Security for NTLM SSP Based Servers does not have both NTLMv2 and 128-bit encryption enabled.`n"
				$CISFailCounter++
			}

			# 2.3.12 Recovery Console
			# 2.3.12 Recovery console: Allow automatic administrative logon
			$AutoAdminLogon = $Global:SecDump | Select-String -SimpleMatch 'SecurityLevel' | Out-String
			$AutoAdminLogonResult = $AutoAdminLogon.split(',')[1]
			$AutoAdminLogonResult = $AutoAdminLogonResult -as [int]
			if(-not([string]::IsNullOrEmpty($AutoAdminLogon))){
				if($AutoAdminLogonResult -eq "0"){
					$Global:Req2AutoAdminLogonResult = "2.3.12    - [PASS] - Automatic Administrative Logon is Not Allowed. CIS Compliant.`n"
					$Global:Req2AutoAdminLogonResultHTML = "2.3.12    - <span id=`"CISPassStatus`">[PASS]</span> - Automatic Administrative Logon is Not Allowed. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AutoAdminLogonResult = "2.3.12    - [FAILED] - Automatic Administrative Logon is Allowed.`n"
					$Global:Req2AutoAdminLogonResultHTML = "2.3.12    - <span id=`"CISFailedStatus`">[FAILED]</span> - Automatic Administrative Logon is Allowed.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AutoAdminLogonResult = "2.3.12    - [FAILED] - Automatic Administrative Logon is Not Defined.`n"
				$Global:Req2AutoAdminLogonResultHTML = "2.3.12    - <span id=`"CISFailedStatus`">[FAILED]</span> - Automatic Administrative Logon is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.12 Recovery console: Allow floppy copy and access to all drives and all folders
			$AllowFloppyAccess = $Global:SecDump | Select-String -SimpleMatch 'SetCommand' | Out-String
			$AllowFloppyAccessResult = $AllowFloppyAccess.split(',')[1]
			$AllowFloppyAccessResult = $AllowFloppyAccessResult -as [int]
			if(-not([string]::IsNullOrEmpty($AllowFloppyAccess))){
				if($AllowFloppyAccessResult -eq "0"){
					$Global:Req2AllowFloppyAccessResult = "2.3.12    - [PASS] - Allow Floppy Copy and Access to all Drives and all Folders is Not Allowed. CIS Compliant.`n"
					$Global:Req2AllowFloppyAccessResultHTML = "2.3.12    - <span id=`"CISPassStatus`">[PASS]</span> - Allow Floppy Copy and Access to all Drives and all Folders is Not Allowed. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AllowFloppyAccessResult = "2.3.12    - [FAILED] - Allow Floppy Copy and Access to all Drives and all Folders is Allowed.`n"
					$Global:Req2AllowFloppyAccessResultHTML = "2.3.12    - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow Floppy Copy and Access to all Drives and all Folders is Allowed.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AllowFloppyAccessResult = "2.3.12    - [FAILED] - Floppy Copy and Access to all Drives and all Folders is Not Defined.`n"
				$Global:Req2AllowFloppyAccessResultHTML = "2.3.12    - <span id=`"CISFailedStatus`">[FAILED]</span> - Floppy Copy and Access to all Drives and all Folders is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.13 Shutdown
			# 2.3.13.1 (L1) Ensure 'Shutdown: Allow system to be shut down without having to log on' is set to 'Disabled' (Scored)
			$ShutdownWithoutLoggingIn = $Global:SecDump | Select-String -SimpleMatch 'ShutDownWithoutLogon' | Out-String
			$ShutdownWithoutLoggingInResult = $ShutdownWithoutLoggingIn.split(',')[1]
			$ShutdownWithoutLoggingInResult = $ShutdownWithoutLoggingInResult -as [int]
			if(-not([string]::IsNullOrEmpty($ShutdownWithoutLoggingIn))){
				if($ShutdownWithoutLoggingInResult -eq "0"){
					$Global:Req2ShutdownWithoutLoggingInResult = "2.3.13.1  - [PASS] - Allow system to be shut down without having to log on is set to Disabled. CIS Compliant.`n"
					$Global:Req2ShutdownWithoutLoggingInResultHTML = "2.3.13.1  - <span id=`"CISPassStatus`">[PASS]</span> - Allow system to be shut down without having to log on is set to Disabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2ShutdownWithoutLoggingInResult = "2.3.13.1  - [FAILED] - Allow system to be shut down without having to log on is set to Enabled.`n"
					$Global:Req2ShutdownWithoutLoggingInResultHTML = "2.3.13.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow system to be shut down without having to log on is set to Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2ShutdownWithoutLoggingInResult = "2.3.13.1  - [FAILED] - Allow system to be shut down without having to log on is Not Configured.`n"
				$Global:Req2ShutdownWithoutLoggingInResultHTML = "2.3.13.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Allow system to be shut down without having to log on is Not Configured.`n"
				$CISFailCounter++
			}

			# 2.3.14 System Cryptography
			# 2.3.14 System cryptography: Use FIPS compliant algorithms for encryption, hashing, and signing
			$FIPSPolicy = $Global:SecDump | Select-String -SimpleMatch "FIPSAlgorithmPolicy\Enabled" | Out-String
			$FIPSPolicyResults = $FIPSPolicy.split(',')[1]
			$FIPSPolicyResults = $FIPSPolicyResults -as [int]
			if($FIPSPolicyResults -eq "1"){
				$Global:Req2FipsPolicyResults = "2.3.14    - [PASS] - FIPS Algorithm for encryption, hashing and signing Policy is enabled. CIS compliant.`n"
				$Global:Req2FipsPolicyResultsHTML = "2.3.14    - <span id=`"CISPassStatus`">[PASS]</span> - FIPS Algorithm for encryption, hashing and signing Policy is enabled. CIS compliant.`n"
				$CISPassCounter++
			}else{
				$Global:Req2FipsPolicyResults = "2.3.14    - [FAILED] - FIPS Algorithm for encryption, hashing and signing Policy is disabled.`n"
				$Global:Req2FipsPolicyResultsHTML = "2.3.14    - <span id=`"CISFailedStatus`">[FAILED]</span> - FIPS Algorithm for encryption, hashing and signing Policy is disabled.`n"
				$CISFailCounter++
			}

			# 2.3.14 System cryptography: Force strong key protection for user keys stored on the computer "ForceKeyProtection"
			$UserKeyProtection = $Global:SecDump | Select-String -SimpleMatch 'ForceKeyProtection' | Out-String
			$UserKeyProtectionResult = $UserKeyProtection.split(',')[1]
			$UserKeyProtectionResult = $UserKeyProtectionResult -as [int]
			if(-not([string]::IsNullOrEmpty($UserKeyProtection))){
				if($UserKeyProtectionResult -eq "1"){
					$Global:Req2UserKeyProtectionResult = "2.3.14    - [PASS] - Strong Key Protection is Enforced for User Keys stored on this Computer. Current Value: `"User is prompted when the key is first used`". CIS Compliant.`n"
					$Global:Req2UserKeyProtectionResultHTML = "2.3.14    - <span id=`"CISPassStatus`">[PASS]</span> - Strong Key Protection is Enforced for User Keys stored on this Computer. Current Value: `"User is prompted when the key is first used`". CIS Compliant.`n"
					$CISPassCounter++
				}elseif($UserKeyProtectionResult -eq "2"){
					$Global:Req2UserKeyProtectionResult = "2.3.14    - [PASS] - Strong Key Protection is Enforced for User Keys stored on this Computer. Current Value: `"User must enter a password each time they use a key`". CIS Compliant.`n"
					$Global:Req2UserKeyProtectionResultHTML = "2.3.14    - <span id=`"CISPassStatus`">[PASS]</span> - Strong Key Protection is Enforced for User Keys stored on this Computer. Current Value: `"User must enter a password each time they use a key`". CIS Compliant.`n"
					$CISPassCounter++
				}elseif($UserKeyProtectionResult -eq "0"){
					$Global:Req2UserKeyProtectionResult = "2.3.14    - [FAILED] - Strong Key Protection is Not Enforced for User Keys stored on this Computer. Current Value: `"User input is not required when new keys are stored and used`".`n"
					$Global:Req2UserKeyProtectionResultHTML = "2.3.14    - <span id=`"CISFailedStatus`">[FAILED]</span> - Strong Key Protection is Not Enforced for User Keys stored on this Computer. Current Value: `"User input is not required when new keys are stored and used`".`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2UserKeyProtectionResult = "2.3.14    - [FAILED] - Strong Key Protection for User Keys stored on this Computer is Not Defined.`n"
				$Global:Req2UserKeyProtectionResultHTML = "2.3.14    - <span id=`"CISFailedStatus`">[FAILED]</span> - Strong Key Protection for User Keys stored on this Computer is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.15 System objects
			# 2.3.15.1 (L1) Ensure 'System objects: Require case insensitivity for nonWindows subsystems' is set to 'Enabled' (Scored) !!
			$CaseInsensitivity = $Global:SecDump | Select-String -SimpleMatch 'ObCaseInsensitive' | Out-String
			$CaseInsensitivityResult = $CaseInsensitivity.split(',')[1]
			$CaseInsensitivityResult = $CaseInsensitivityResult -as [int]
			if(-not([string]::IsNullOrEmpty($CaseInsensitivity))){
				if($CaseInsensitivityResult -eq "1"){
					$Global:Req2CaseInsensitivityResult = "2.3.15.1  - [PASS] - Require Case Insensitivity for non-Windows Subsystem is set to Enabled. CIS Compliant.`n"
					$Global:Req2CaseInsensitivityResultHTML = "2.3.15.1  - <span id=`"CISPassStatus`">[PASS]</span> - Require Case Insensitivity for non-Windows Subsystem is set to Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2CaseInsensitivityResult = "2.3.15.1  - [FAILED] - Require Case Insensitivity for non-Windows Subsystem is Not Enabled.`n"
					$Global:Req2CaseInsensitivityResult = "2.3.15.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Case Insensitivity for non-Windows Subsystem is Not Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2CaseInsensitivityResult = "2.3.15.1  - [FAILED] - Require Case Insensitivity for non-Windows Subsystem is Not Defined.`n"
				$Global:Req2CaseInsensitivityResult = "2.3.15.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Require Case Insensitivity for non-Windows Subsystem is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.15.2 (L1) Ensure 'System objects: Strengthen default permissions of internal system objects (e.g. Symbolic Links)' is set to 'Enabled' (Scored) !!
			$StrengthenPermissions = $Global:SecDump | Select-String -SimpleMatch 'ProtectionMode' | Out-String
			$StrengthenPermissionsResult = $StrengthenPermissions.split(',')[1]
			$StrengthenPermissionsResult = $StrengthenPermissionsResult -as [int]
			if(-not([string]::IsNullOrEmpty($StrengthenPermissions))){
				if($StrengthenPermissionsResult -eq "1"){
					$Global:Req2StrengthenPermissionsResult = "2.3.15.2  - [PASS] - Strengthen Default Permissions of Internal System Objects is set to Enabled. CIS Compliant.`n"
					$Global:Req2StrengthenPermissionsResultHTML = "2.3.15.2  - <span id=`"CISPassStatus`">[PASS]</span> - Strengthen Default Permissions of Internal System Objects is set to Enabled. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2StrengthenPermissionsResult = "2.3.15.2  - [FAILED] - Strengthen Default Permissions of Internal System Objects is Not Enabled.`n"
					$Global:Req2StrengthenPermissionsResultHTML = "2.3.15.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Strengthen Default Permissions of Internal System Objects is Not Enabled.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2StrengthenPermissionsResult = "2.3.15.2  - [FAILED] - Strengthen Default Permissions of Internal System Objects is Not Defined.`n"
				$Global:Req2StrengthenPermissionsResultHTML = "2.3.15.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Strengthen Default Permissions of Internal System Objects is Not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17 User Account Control
			# 2.3.17.1 (L1) Ensure 'User Account Control: Admin Approval Mode for the Built-in Administrator account' is set to 'Enabled' "FilterAdministratorToken" (Scored)
			$AdminApprovalMode = $Global:SecDump | Select-String -SimpleMatch 'FilterAdministratorToken' | Out-String
			$AdminApprovalModeResult = $AdminApprovalMode.split(',')[1]
			$AdminApprovalModeResult = $AdminApprovalModeResult -as [int]
			if(-not([string]::IsNullOrEmpty($AdminApprovalMode))){
				if($AdminApprovalModeResult -eq "1"){
					$Global:Req2AdminApprovalModeResult = "2.3.17.1  - [PASS] - Admin Approval Mode for the Built-in Administrator account' is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2AdminApprovalModeResultHTML = "2.3.17.1  - <span id=`"CISPassStatus`">[PASS]</span> - Admin Approval Mode for the Built-in Administrator account' is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2AdminApprovalModeResult = "2.3.17.1  - [FAILED] - Admin Approval Mode for the Built-in Administrator account' is set to 'Disabled'.`n"
					$Global:Req2AdminApprovalModeResultHTML = "2.3.17.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Admin Approval Mode for the Built-in Administrator account' is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2AdminApprovalModeResult = "2.3.17.1  - [FAILED] - Admin Approval Mode for the Built-in Administrator account' is not defined.`n"
				$Global:Req2AdminApprovalModeResultHTML = "2.3.17.1  - <span id=`"CISFailedStatus`">[FAILED]</span> - Admin Approval Mode for the Built-in Administrator account' is not defined.`n"
				$CISFailCounter++
			}
			
			# 2.3.17.2 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for administrators in Admin Approval Mode' is set to 'Prompt for consent on the secure desktop' "ConsentPromptBehaviorAdmin" (Scored)
		    $BehaviorforAdmin = $Global:SecDump | Select-String -SimpleMatch 'ConsentPromptBehaviorAdmin' | Out-String
			$BehaviorforAdminResult = $BehaviorforAdmin.split(',')[1]
			$BehaviorforAdminResult = $BehaviorforAdminResult -as [int]
			if(-not([string]::IsNullOrEmpty($BehaviorforAdmin))){
				if($BehaviorforAdminResult -eq "2"){
					$Global:Req2BehaviorforAdminResult = "2.3.17.2  - [PASS] - Elevation Prompt for Admins in Admin Approval Mode' is set to 'Prompt for consent on the secure desktop'. CIS Compliant.`n"
					$Global:Req2BehaviorforAdminResultHTML = "2.3.17.2  - <span id=`"CISPassStatus`">[PASS]</span> - Elevation Prompt for Admins in Admin Approval Mode' is set to 'Prompt for consent on the secure desktop'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2BehaviorforAdminResult = "2.3.17.2  - [FAILED] - Elevation Prompt for Admins in Admin Approval Mode is not set to 'Prompt for consent on the secure desktop'.`n"
					$Global:Req2BehaviorforAdminResultHTML = "2.3.17.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Elevation Prompt for Admins in Admin Approval Mode is not set to 'Prompt for consent on the secure desktop'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2BehaviorforAdminResult = "2.3.17.2    - [FAILED] - Elevation Prompt for Admins in Admin Approval Mode is not Defined.`n"
				$Global:Req2BehaviorforAdminResultHTML = "2.3.17.2    - <span id=`"CISFailedStatus`">[FAILED]</span> - Elevation Prompt for Admins in Admin Approval Mode is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.3 (L1) Ensure 'User Account Control: Behavior of the elevation prompt for standard users' is set to 'Automatically deny elevation requests' "ConsentPromptBehaviorUser" (Scored)
			$BehaviorforStandard = $Global:SecDump | Select-String -SimpleMatch 'ConsentPromptBehaviorUser' | Out-String
			$BehaviorforStandardResult = $BehaviorforStandard.split(',')[1]
			$BehaviorforStandardResult = $BehaviorforStandardResult -as [int]
			if(-not([string]::IsNullOrEmpty($BehaviorforStandard))){
				if($BehaviorforStandardResult -eq "0"){
					$Global:Req2BehaviorforStandardResult = "2.3.17.3  - [PASS] - Behavior of the Elevation Prompt for Standard Users is set to 'Automatically Deny Elevation Requests'. CIS Compliant.`n"
					$Global:Req2BehaviorforStandardResultHTML = "2.3.17.3  - <span id=`"CISPassStatus`">[PASS]</span> - Behavior of the Elevation Prompt for Standard Users is set to 'Automatically Deny Elevation Requests'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2BehaviorforStandardResult = "2.3.17.3  - [FAILED] - Behavior of the Elevation prompt for Standard Users is not set to 'Automatically Deny Elevation Requests'.`n"
					$Global:Req2BehaviorforStandardResultHTML = "2.3.17.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Behavior of the Elevation prompt for Standard Users is not set to 'Automatically Deny Elevation Requests'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2BehaviorforStandardResult = "2.3.17.3  - [FAILED] - Behavior of the Elevation Prompt for Standard Users is not Defined.`n"
				$Global:Req2BehaviorforStandardResultHTML = "2.3.17.3  - <span id=`"CISFailedStatus`">[FAILED]</span> - Behavior of the Elevation Prompt for Standard Users is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.4 (L1) Ensure 'User Account Control: Detect application installations and prompt for elevation' is set to 'Enabled' "EnableInstallerDetection" (Scored)
			$InstallerDetection = $Global:SecDump | Select-String -SimpleMatch 'EnableInstallerDetection' | Out-String
			$InstallerDetectionResult = $InstallerDetection.split(',')[1]
			$InstallerDetectionResult = $InstallerDetectionResult -as [int]
			if(-not([string]::IsNullOrEmpty($InstallerDetection))){
				if($InstallerDetectionResult -eq "1"){
					$Global:Req2InstallerDetectionResult = "2.3.17.4  - [PASS] - Detect Application Installations and Prompt for Elevation is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2InstallerDetectionResultHTML = "2.3.17.4  - <span id=`"CISPassStatus`">[PASS]</span> - Detect Application Installations and Prompt for Elevation is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2InstallerDetectionResult = "2.3.17.4  - [FAILED] - Detect Application Installations and Prompt for Elevation is set to 'Disabled'.`n"
					$Global:Req2InstallerDetectionResultHTML = "2.3.17.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Detect Application Installations and Prompt for Elevation is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2InstallerDetectionResult = "2.3.17.4  - [FAILED] - Detect Application Installations and Prompt for Elevation' is not Defined.`n"
				$Global:Req2InstallerDetectionResultHTML = "2.3.17.4  - <span id=`"CISFailedStatus`">[FAILED]</span> - Detect Application Installations and Prompt for Elevation' is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.5 (L1) Ensure 'User Account Control: Only elevate UIAccess applications that are installed in secure locations' is set to 'Enabled' "EnableSecureUIAPaths" (Scored)
			$UIAccessSecureLocations = $Global:SecDump | Select-String -SimpleMatch 'EnableSecureUIAPaths' | Out-String
			$UIAccessSecureLocationsResult = $UIAccessSecureLocations.split(',')[1]
			$UIAccessSecureLocationsResult = $UIAccessSecureLocationsResult -as [int]
			if(-not([string]::IsNullOrEmpty($UIAccessSecureLocations))){
				if($UIAccessSecureLocationsResult -eq "1"){
					$Global:Req2UIAccessSecureLocationsResult = "2.3.17.5  - [PASS] - Only Elevate UIAccess Applications that are Installed in Secure Locations' is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2UIAccessSecureLocationsResultHTML = "2.3.17.5  - <span id=`"CISPassStatus`">[PASS]</span> - Only Elevate UIAccess Applications that are Installed in Secure Locations' is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2UIAccessSecureLocationsResult = "2.3.17.5  - [FAILED] - Only Elevate UIAccess Applications that are Installed in Secure Locations' is set to 'Disabled'.`n"
					$Global:Req2UIAccessSecureLocationsResultHTML = "2.3.17.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - Only Elevate UIAccess Applications that are Installed in Secure Locations' is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2UIAccessSecureLocationsResult = "2.3.17.5  - [FAILED] - Only Elevate UIAccess Applications that are Installed in Secure Locations' is not Defined.`n"
				$Global:Req2UIAccessSecureLocationsResultHTML = "2.3.17.5  - <span id=`"CISFailedStatus`">[FAILED]</span> - Only Elevate UIAccess Applications that are Installed in Secure Locations' is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.6 (L1) Ensure 'User Account Control: Run all administrators in Admin Approval Mode' is set to 'Enabled' "EnableLUA" (Scored)
			$RunAllAdminsMode = $Global:SecDump | Select-String -SimpleMatch 'EnableLUA' | Out-String
			$RunAllAdminsModeResult = $RunAllAdminsMode.split(',')[1]
			$RunAllAdminsModeResult = $RunAllAdminsModeResult -as [int]
			if(-not([string]::IsNullOrEmpty($RunAllAdminsMode))){
				if($RunAllAdminsModeResult -eq "1"){
					$Global:Req2RunAllAdminsModeResult = "2.3.17.6  - [PASS] - Run All Administrators in Admin Approval Mode is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2RunAllAdminsModeResultHTML = "2.3.17.6  - <span id=`"CISPassStatus`">[PASS]</span> - Run All Administrators in Admin Approval Mode is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2RunAllAdminsModeResult = "2.3.17.6  - [FAILED] - Run All Administrators in Admin Approval Mode is set to 'Disabled'.`n"
					$Global:Req2RunAllAdminsModeResultHTML = "2.3.17.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - Run All Administrators in Admin Approval Mode is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2RunAllAdminsModeResult = "2.3.17.6  - [FAILED] - Run All Administrators in Admin Approval Mode is not Defined.`n"
				$Global:Req2RunAllAdminsModeResultHTML = "2.3.17.6  - <span id=`"CISFailedStatus`">[FAILED]</span> - Run All Administrators in Admin Approval Mode is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.7 (L1) Ensure 'User Account Control: Switch to the secure desktop when prompting for elevation' is set to 'Enabled' "PromptOnSecureDesktop" (Scored)
			$SwitchSecureDesktop = $Global:SecDump | Select-String -SimpleMatch 'PromptOnSecureDesktop' | Out-String
			$SwitchSecureDesktopResult = $SwitchSecureDesktop.split(',')[1]
			$SwitchSecureDesktopResult = $SwitchSecureDesktopResult -as [int]
			if(-not([string]::IsNullOrEmpty($SwitchSecureDesktop))){
				if($SwitchSecureDesktopResult -eq "1"){
					$Global:Req2SwitchSecureDesktopResult = "2.3.17.7  - [PASS] - Switch to the Secure Desktop when Prompting for Elevation' is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2SwitchSecureDesktopResultHTML = "2.3.17.7  - <span id=`"CISPassStatus`">[PASS]</span> - Switch to the Secure Desktop when Prompting for Elevation' is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2SwitchSecureDesktopResult = "2.3.17.7  - [FAILED] - Switch to the Secure Desktop when Prompting for Elevation' is set to 'Disabled'.`n"
					$Global:Req2SwitchSecureDesktopResultHTML = "2.3.17.7  - <span id=`"CISFailedStatus`">[FAILED]</span> - Switch to the Secure Desktop when Prompting for Elevation' is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2SwitchSecureDesktopResult = "2.3.17.7  - [FAILED] - Switch to the Secure Desktop when Prompting for Elevation' is not Defined.`n"
				$Global:Req2SwitchSecureDesktopResultHTML = "2.3.17.7  - <span id=`"CISFailedStatus`">[FAILED]</span> - Switch to the Secure Desktop when Prompting for Elevation' is not Defined.`n"
				$CISFailCounter++
			}

			# 2.3.17.8 (L1) Ensure 'User Account Control: Virtualize file and registry write failures to per-user locations' is set to 'Enabled' "EnableVirtualization" (Scored)
			$VitualFileLocations = $Global:SecDump | Select-String -SimpleMatch 'EnableVirtualization' | Out-String
			$VitualFileLocationsResult = $VitualFileLocations.split(',')[1]
			$VitualFileLocationsResult = $VitualFileLocationsResult -as [int]
			if(-not([string]::IsNullOrEmpty($VitualFileLocations))){
				if($VitualFileLocationsResult -eq "1"){
					$Global:Req2VitualFileLocationsResult = "2.3.17.8  - [PASS] - Virtualize File and Registry Write Failures to Per-user Locations' is set to 'Enabled'. CIS Compliant.`n"
					$Global:Req2VitualFileLocationsResultHTML = "2.3.17.8  - <span id=`"CISPassStatus`">[PASS]</span> - Virtualize File and Registry Write Failures to Per-user Locations' is set to 'Enabled'. CIS Compliant.`n"
					$CISPassCounter++
				}else{
					$Global:Req2VitualFileLocationsResult = "2.3.17.8  - [FAILED] - Virtualize File and Registry Write Failures to Per-user Locations' is set to 'Disabled'.`n"
					$Global:Req2VitualFileLocationsResultHTML = "2.3.17.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - Virtualize File and Registry Write Failures to Per-user Locations' is set to 'Disabled'.`n"
					$CISFailCounter++
				}
			}else{
				$Global:Req2VitualFileLocationsResult = "2.3.17.8  - [FAILED] - Virtualize File and Registry Write Failures to Per-user Locations' is not Defined.`n"
				$Global:Req2VitualFileLocationsResultHTML = "2.3.17.8  - <span id=`"CISFailedStatus`">[FAILED]</span> - Virtualize File and Registry Write Failures to Per-user Locations' is not Defined.`n"
				$CISFailCounter++
			}

		# Data Output
		$CISTotalCounter = $CISPassCounter + $CISFailCounter
		$Global:CISBenchmarkToalResult = "`nCIS Benchmarks Result:`n" + $CISPassCounter + " PASS Results.`n" + $CISFailCounter + " FAILED Results.`nTotal Benchmarks Tested: " + $CISTotalCounter + "`n"
		$Global:CISBenchmarkToalResultHTML = "<h3>CIS Benchmarks Result</h3><p>PASS Results:" + $CISPassCounter + "<br>FAILED Results: " + $CISFailCounter + "<br>Total Benchmarks Tested: " + $CISTotalCounter + "</p>"
		# HTML Report
		$Global:Req2PCIDSSComplianceResultHTML = "<h2>Requirement Two Compliance Check (PCI-DSS)</h2><p>" + $Global:Req2VendorPassResultHTML + "<br>" + $Global:Req2FeatureResultHTML + "<br>" + $Global:Req2FeatureResultTotalHTML + "<br>" + $Global:RunningProcessesResultHTML + "<br>" + $Global:RunningServicesResultHTML + "<br>" + $Global:32BitAppsResultHTML + "<br>" + $Global:64BitAppsResultHTML + "<br>" + $Global:LocalDrivesResultHTML + "<br>" + $Global:SMBSharesResultHTML + "<br>" + $Global:ADComputersResultHTML + "<br>" + $Global:CISBenchmarkToalResultHTML + "</p>"
		$Global:Req2CISComplianceResultHTMLFinal = "<h2>2.4 - CIS Compliance Check</h2><h3>1.1 Password Policy</h3><p>" + $Global:Req2EnforcePasswordHistoryResultHTML + "<br>" + $Global:Req2MaximumPasswordAgeResultHTML + "<br>" + $Global:Req2MinimumPasswordAgeResultHTML + "<br>" + $Global:Req2MinimumPasswordLengthResultHTML + "<br>" + $Global:Req2PasswordComplexityReqsResultHTML + "<br>" + $Global:Req2ClearTextPasswordSettingResultHTML + "</p><h3>1.2 Account Lockout Policy</h3><p>" + $Global:Req2AccountLockoutDurationResultHTML + "<br>" + $Global:Req2AccountLockoutThresholdResultHTML + "<br>" + $Global:Req2ResetAccountLockoutCounterResultHTML + "</p><h3>2.3.1 Accounts</h3><p>" + $Global:Req2DisabledAdminResultHTML + "<br>" + $Global:Req2BlockMSAccountsResultHTML + "<br>" + $Global:Req2DisabledGuestResultHTML + "<br>" + $Global:Req2LimitBlankPassUseResultHTML + "<br>" + $Global:Req2RenameAdminResultHTML + "<br>" + $Global:Req2RenameGuestResultHTML + "</p><h3>2.3.2 Audits</h3><p>" + $Global:Req2ForceAuditPolicyOverrideResultHTML + "<br>" + $Global:Req2ShutdownAuditSettingsResultHTML + "</p><h3>2.3.4 Devices</h3><p>" + $Global:Req2RestrictUserUndockingResultHTML + "<br>" + $Global:Req2RestrictCDRomsResultHTML + "<br>" + $Global:Req2RestrictFloppiesResultHTML + "<br>" + $Global:Req2LimitRemoveableMediaResultHTML + "<br>" + $Global:Req2LimitPrinterDriversResultHTML + "</p><h3>2.3.5 Domain controller</h3><p>" + $Global:Req2ServerOpsScheduleTasksResultHTML + "<br>" + $Global:Req2DCRefuseMachineAccountChangesResultHTML + "</p><h3>2.3.6 Domain Member</h3><p>" + $Global:Req2DigitalEncryptSignResultHTML + "<br>" + $Global:Req2DigitalSecureChannelHTML + "<br>" + $Global:Req2DigitalSecureChannelSignedHTML + "<br>" + $Global:Req2DisableMachinePassChangeResultHTML + "<br>" + $Global:Req2MaxMachinePassAgeResultHTML + "<br>" + $Global:Req2StrongSessionKeyResultHTML + "</p><h3>2.3.7 Interactive Login</h3><p>" + $Global:Req2LoginCntlAltDelStatusResultHTML + "<br>" + $Global:Req2DontDisplayLastUserHTML + "<br>" + $Global:Req2MachineAFKLimitResultHTML + "<br>" + $Global:Req2LegalNoticeTextResultHTML + "<br>" + $Global:Req2LegalNoticeCaptionResultHTML + "<br>" + $Global:Req2PreviousCachedLogonsResultHTML + "<br>" + $Global:Req2PassExpiryWarningResultHTML + "<br>" + $Global:Req2DCAuthUnlockResultHTML + "<br>" + $Global:Req2SmartCardRemovalResultHTML + "</p><h3>2.3.8 Microsoft Network Client</h3><p>" + $Global:Req2DigitallySignAlwaysResultHTML + "<br>" + $Global:Req2DigitallySignComsServerResultHTML + "<br>" + $Global:Req2EnablePlainTextResultHTML + "</p><h3>2.3.9 Microsoft network server</h3><p>" + $Global:Req2SuspendingSessionIdleTimeResultHTML + "<br>" + $Global:Req2DigitallySignComsForcedResultHTML + "<br>" + $Global:Req2DigitallySignComsClientResultHTML + "<br>" + $Global:Req2ForcedClientLogoffResultHTML + "</p><h3>2.3.10 Network access</h3><p>" + $Global:Req2SIDNameLookupResultHTML + "<br>" + $Global:Req2RestrictAnonymousSAMResultHTML + "<br>" + $Global:Req2AnonymousEmuerationAccountsResultHTML + "<br>" + $Global:Req2StorageOfPasswordsResultHTML + "<br>" + $Global:Req2AllIncludesPoliciesResultHTML + "<br>" + $Global:Req2AnonymousNamedPipesResultHTML + "<br>" + $Global:Req2AllowedExactPathsResultHTML + "<br>" + $Global:Req2RestrictAnnonymousAccessSessionsResultHTML + "<br>" + $Global:Req2NullSessionSharesHTML + "<br>" + $Global:Req2SharingAndSecModelLocalAccountsResultHTML + "</p><h3>2.3.11 Network Security</h3><p>" + $Global:Req2LocalSystemNTLMResultHTML + "<br>" + $Global:Req2LocalSystemNULLSessionResultHTML + "<br>" + $Global:Req2PKU2UOnlineIdentitiesResultHTML + "<br>" + $Global:Req2KerberosEncryptionTypesResultHTML + "<br>" + $Global:Req2LanManagerHashResultHTML + "<br>" + $Global:Req2ForceLogoffAfterHoursExpireResultHTML + "<br>" + $Global:Req2LanManagerAuthLevelResultHTML + "<br>" + $Global:Req2LDAPClientSigningReqsResultHTML + "<br>" + $Global:Req2NTLMMinClientResultsHTML + "<br>" + $Global:Req2NTLMMinServerResultsHTML + "</p><h3>2.3.12 Recovery Console</h3><p>" + $Global:Req2AutoAdminLogonResultHTML + "<br>" + $Global:Req2AllowFloppyAccessResultHTML + "</p><h3>2.3.13 Shutdown</h3><p>" + $Global:Req2ShutdownWithoutLoggingInResultHTML + "</p><h3>2.3.14 System Cryptography</h3><p>" + $Global:Req2FipsPolicyResultsHTML + "<br>" + $Global:Req2UserKeyProtectionResultHTML + "</p><h3>2.3.15 System objects</h3><p>" + $Global:Req2CaseInsensitivityResultHTML + "<br>" + $Global:Req2StrengthenPermissionsResultHTML + "</p><h3>2.3.17 User Account Control</h3><p>" + $Global:Req2AdminApprovalModeResultHTML + "<br>" + $Global:Req2BehaviorforAdminResultHTML + "<br>" + $Global:Req2BehaviorforStandardResultHTML + "<br>" + $Global:Req2InstallerDetectionResultHTML + "<br>" + $Global:Req2UIAccessSecureLocationsResultHTML + "<br>" + $Global:Req2RunAllAdminsModeResultHTML + "<br>" + $Global:Req2SwitchSecureDesktopResultHTML + "<br>" + $Global:Req2VitualFileLocationsResultHTML + "</p>"

		# Rich Text Boxes
		if($EverythingToggle -eq $false){
			$Req2Output.AppendText("The Following Sub-Sections are directly from the CIS Benchmarks`n")
			# 1.1 Password Policy
			$Req2Output.AppendText("`n1.1 Password Policy`n")
			$Req2Output.AppendText($Global:Req2EnforcePasswordHistoryResult)
			$Req2Output.AppendText($Global:Req2MaximumPasswordAgeResult)
			$Req2Output.AppendText($Global:Req2MinimumPasswordAgeResult)
			$Req2Output.AppendText($Global:Req2MinimumPasswordLengthResult)
			$Req2Output.AppendText($Global:Req2PasswordComplexityReqsResult)
			$Req2Output.AppendText($Global:Req2ClearTextPasswordSettingResult)
			# 1.2 Account Lockout Policy
			$Req2Output.AppendText("`n1.2 Account Lockout Policy`n")
			$Req2Output.AppendText($Global:Req2AccountLockoutDurationResult)
			$Req2Output.AppendText($Global:Req2AccountLockoutThresholdResult)
			$Req2Output.AppendText($Global:Req2ResetAccountLockoutCounterResult)
			# 2.3.1 - Accounts
			$Req2Output.AppendText("`n2.3.1 Accounts`n")
			$Req2Output.AppendText($Global:Req2DisabledAdminResult)
			$Req2Output.AppendText($Global:Req2BlockMSAccountsResult)
			$Req2Output.AppendText($Global:Req2DisabledGuestResult)
			$Req2Output.AppendText($Global:Req2LimitBlankPassUseResult)
			$Req2Output.AppendText($Global:Req2RenameAdminResult)
			$Req2Output.AppendText($Global:Req2RenameGuestResult)
			# 2.3.2 Audits
			$Req2Output.AppendText("`n2.3.2 Audits`n")
			$Req2Output.AppendText($Global:Req2ForceAuditPolicyOverrideResult)
			$Req2Output.AppendText($Global:Req2ShutdownAuditSettingsResult)
			# 2.3.4 - Devices
			$Req2Output.AppendText("`n2.3.4 Devices`n")
			$Req2Output.AppendText($Global:Req2RestrictUserUndockingResult)
			$Req2Output.AppendText($Global:Req2RestrictCDRomsResult)
			$Req2Output.AppendText($Global:Req2RestrictFloppiesResult)
			$Req2Output.AppendText($Global:Req2LimitRemoveableMediaResult)
			$Req2Output.AppendText($Global:Req2LimitPrinterDriversResult)
			# 2.3.5 Domain controller
			$Req2Output.AppendText("`n2.3.5 Domain controller`n")
			$Req2Output.AppendText($Global:Req2ServerOpsScheduleTasksResult)
			$Req2Output.AppendText($Global:Req2DCRefuseMachineAccountChangesResult)
			# 2.3.6 - Domain Member
			$Req2Output.AppendText("`n2.3.6 Domain Member`n")
			$Req2Output.AppendText($Global:Req2DigitalEncryptSignResult)
			$Req2Output.AppendText($Global:Req2DigitalSecureChannel)
			$Req2Output.AppendText($Global:Req2DigitalSecureChannelSigned)
			$Req2Output.AppendText($Global:Req2DisableMachinePassChangeResult)
			$Req2Output.AppendText($Global:Req2MaxMachinePassAgeResult)
			$Req2Output.AppendText($Global:Req2StrongSessionKeyResult)
			# 2.3.7 - Interactive Login
			$Req2Output.AppendText("`n2.3.7 Interactive Login`n")
			$Req2Output.AppendText($Global:Req2LoginCntlAltDelStatusResult)
			$Req2Output.AppendText($Global:Req2DontDisplayLastUser)
			$Req2Output.AppendText($Global:Req2MachineAFKLimitResult)
			$Req2Output.AppendText($Global:Req2LegalNoticeTextResult)
			$Req2Output.AppendText($Global:Req2LegalNoticeCaptionResult)
			$Req2Output.AppendText($Global:Req2PreviousCachedLogonsResult)
			$Req2Output.AppendText($Global:Req2PassExpiryWarningResult)
			$Req2Output.AppendText($Global:Req2DCAuthUnlockResult)
			$Req2Output.AppendText($Global:Req2SmartCardRemovalResult)
			# 2.3.8 Microsoft Network Client
			$Req2Output.AppendText("`n2.3.8 Microsoft Network Client`n")
			$Req2Output.AppendText($Global:Req2DigitallySignAlwaysResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsServerResult)
			$Req2Output.AppendText($Global:Req2EnablePlainTextResult)
			# 2.3.9 Microsoft network server
			$Req2Output.AppendText("`n2.3.9 Microsoft network server`n")
			$Req2Output.AppendText($Global:Req2SuspendingSessionIdleTimeResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsForcedResult)
			$Req2Output.AppendText($Global:Req2DigitallySignComsClientResult)
			$Req2Output.AppendText($Global:Req2ForcedClientLogoffResult)
			# 2.3.10 Network access
			$Req2Output.AppendText("`n2.3.10 Network access`n")
			$Req2Output.AppendText($Global:Req2SIDNameLookupResult)
			$Req2Output.AppendText($Global:Req2RestrictAnonymousSAMResult)
			$Req2Output.AppendText($Global:Req2AnonymousEmuerationAccountsResult)
			$Req2Output.AppendText($Global:Req2StorageOfPasswordsResult)
			$Req2Output.AppendText($Global:Req2AllIncludesPoliciesResult)
			$Req2Output.AppendText($Global:Req2AnonymousNamedPipesResult)
			$Req2Output.AppendText($Global:Req2AllowedExactPathsResult)
			$Req2Output.AppendText($Global:Req2RestrictAnnonymousAccessSessionsResult)
			$Req2Output.AppendText($Global:Req2NullSessionShares)
			$Req2Output.AppendText($Global:Req2SharingAndSecModelLocalAccountsResult)
			# 2.3.11 Network Security
			$Req2Output.AppendText("`n2.3.11 Network Security`n")
			$Req2Output.AppendText($Global:Req2LocalSystemNTLMResult)
			$Req2Output.AppendText($Global:Req2LocalSystemNULLSessionResult)
			$Req2Output.AppendText($Global:Req2PKU2UOnlineIdentitiesResult)
			$Req2Output.AppendText($Global:Req2KerberosEncryptionTypesResult)
			$Req2Output.AppendText($Global:Req2LanManagerHashResult)
			$Req2Output.AppendText($Global:Req2ForceLogoffAfterHoursExpireResult)
			$Req2Output.AppendText($Global:Req2LanManagerAuthLevelResult)
			$Req2Output.AppendText($Global:Req2LDAPClientSigningReqsResult)
			$Req2Output.AppendText($Global:Req2NTLMMinClientResults)
			$Req2Output.AppendText($Global:Req2NTLMMinServerResults)
			# 2.3.12 Recovery Console
			$Req2Output.AppendText("`n2.3.12 Recovery Console`n")
			$Req2Output.AppendText($Global:Req2AutoAdminLogonResult)
			$Req2Output.AppendText($Global:Req2AllowFloppyAccessResult)
			# 2.3.13 Shutdown
			$Req2Output.AppendText("`n2.3.13 Shutdown`n")
			$Req2Output.AppendText($Global:Req2ShutdownWithoutLoggingInResult)
			# 2.3.14 System Cryptography
			$Req2Output.AppendText("`n2.3.14 System Cryptography`n")
			$Req2Output.AppendText($Global:Req2FipsPolicyResults)
			$Req2Output.AppendText($Global:Req2UserKeyProtectionResult)
			# 2.3.15 System objects
			$Req2Output.AppendText("`n2.3.15 System objects`n")
			$Req2Output.AppendText($Global:Req2CaseInsensitivityResult)
			$Req2Output.AppendText($Global:Req2StrengthenPermissionsResult)
			# 2.3.17 User Account Control
			$Req2Output.AppendText("`n2.3.17 User Account Control`n")
			$Req2Output.AppendText($Global:Req2AdminApprovalModeResult)
			$Req2Output.AppendText($Global:Req2BehaviorforAdminResult)
			$Req2Output.AppendText($Global:Req2BehaviorforStandardResult)
			$Req2Output.AppendText($Global:Req2InstallerDetectionResult)
			$Req2Output.AppendText($Global:Req2UIAccessSecureLocationsResult)
			$Req2Output.AppendText($Global:Req2RunAllAdminsModeResult)
			$Req2Output.AppendText($Global:Req2SwitchSecureDesktopResult)
			$Req2Output.AppendText($Global:Req2VitualFileLocationsResult)
		}else{
			$AllOutput.AppendText("The Following Sub-Sections are directly from the CIS Benchmarks`n")
			# 1.1 Password Policy
			$AllOutput.AppendText("`n1.1 Password Policy`n")
			$AllOutput.AppendText($Global:Req2EnforcePasswordHistoryResult)
			$AllOutput.AppendText($Global:Req2MaximumPasswordAgeResult)
			$AllOutput.AppendText($Global:Req2MinimumPasswordAgeResult)
			$AllOutput.AppendText($Global:Req2MinimumPasswordLengthResult)
			$AllOutput.AppendText($Global:Req2PasswordComplexityReqsResult)
			$AllOutput.AppendText($Global:Req2ClearTextPasswordSettingResult)
			# 1.2 Account Lockout Policy
			$AllOutput.AppendText("`n1.2 Account Lockout Policy`n")
			$AllOutput.AppendText($Global:Req2AccountLockoutDurationResult)
			$AllOutput.AppendText($Global:Req2AccountLockoutThresholdResult)
			$AllOutput.AppendText($Global:Req2ResetAccountLockoutCounterResult)
			# 2.3.1 - Accounts
			$AllOutput.AppendText("`n2.3.1 Accounts`n")
			$AllOutput.AppendText($Global:Req2DisabledAdminResult)
			$AllOutput.AppendText($Global:Req2BlockMSAccountsResult)
			$AllOutput.AppendText($Global:Req2DisabledGuestResult)
			$AllOutput.AppendText($Global:Req2LimitBlankPassUseResult)
			$AllOutput.AppendText($Global:Req2RenameAdminResult)
			$AllOutput.AppendText($Global:Req2RenameGuestResult)
			# 2.3.2 Audits
			$AllOutput.AppendText("`n2.3.2 Audits`n")
			$AllOutput.AppendText($Global:Req2ForceAuditPolicyOverrideResult)
			$AllOutput.AppendText($Global:Req2ShutdownAuditSettingsResult)
			# 2.3.4 - Devices
			$AllOutput.AppendText("`n2.3.4 Devices`n")
			$AllOutput.AppendText($Global:Req2RestrictUserUndockingResult)
			$AllOutput.AppendText($Global:Req2RestrictCDRomsResult)
			$AllOutput.AppendText($Global:Req2RestrictFloppiesResult)
			$AllOutput.AppendText($Global:Req2LimitRemoveableMediaResult)
			$AllOutput.AppendText($Global:Req2LimitPrinterDriversResult)
			# 2.3.5 Domain controller
			$AllOutput.AppendText("`n2.3.5 Domain controller`n")
			$AllOutput.AppendText($Global:Req2ServerOpsScheduleTasksResult)
			$AllOutput.AppendText($Global:Req2DCRefuseMachineAccountChangesResult)
			# 2.3.6 - Domain Member
			$AllOutput.AppendText("`n2.3.6 Domain Member`n")
			$AllOutput.AppendText($Global:Req2DigitalEncryptSignResult)
			$AllOutput.AppendText($Global:Req2DigitalSecureChannel)
			$AllOutput.AppendText($Global:Req2DigitalSecureChannelSigned)
			$AllOutput.AppendText($Global:Req2DisableMachinePassChangeResult)
			$AllOutput.AppendText($Global:Req2MaxMachinePassAgeResult)
			$AllOutput.AppendText($Global:Req2StrongSessionKeyResult)
			# 2.3.7 - Interactive Login
			$AllOutput.AppendText("`n2.3.7 Interactive Login`n")
			$AllOutput.AppendText($Global:Req2LoginCntlAltDelStatusResult)
			$AllOutput.AppendText($Global:Req2DontDisplayLastUser)
			$AllOutput.AppendText($Global:Req2MachineAFKLimitResult)
			$AllOutput.AppendText($Global:Req2LegalNoticeTextResult)
			$AllOutput.AppendText($Global:Req2LegalNoticeCaptionResult)
			$AllOutput.AppendText($Global:Req2PreviousCachedLogonsResult)
			$AllOutput.AppendText($Global:Req2PassExpiryWarningResult)
			$AllOutput.AppendText($Global:Req2DCAuthUnlockResult)
			$AllOutput.AppendText($Global:Req2SmartCardRemovalResult)
			# 2.3.8 Microsoft Network Client
			$AllOutput.AppendText("`n2.3.8 Microsoft Network Client`n")
			$AllOutput.AppendText($Global:Req2DigitallySignAlwaysResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsServerResult)
			$AllOutput.AppendText($Global:Req2EnablePlainTextResult)
			# 2.3.9 Microsoft network server
			$AllOutput.AppendText("`n2.3.9 Microsoft network server`n")
			$AllOutput.AppendText($Global:Req2SuspendingSessionIdleTimeResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsForcedResult)
			$AllOutput.AppendText($Global:Req2DigitallySignComsClientResult)
			$AllOutput.AppendText($Global:Req2ForcedClientLogoffResult)
			# 2.3.10 Network access
			$AllOutput.AppendText("`n2.3.10 Network access`n")
			$AllOutput.AppendText($Global:Req2SIDNameLookupResult)
			$AllOutput.AppendText($Global:Req2RestrictAnonymousSAMResult)
			$AllOutput.AppendText($Global:Req2AnonymousEmuerationAccountsResult)
			$AllOutput.AppendText($Global:Req2StorageOfPasswordsResult)
			$AllOutput.AppendText($Global:Req2AllIncludesPoliciesResult)
			$AllOutput.AppendText($Global:Req2AnonymousNamedPipesResult)
			$AllOutput.AppendText($Global:Req2AllowedExactPathsResult)
			$AllOutput.AppendText($Global:Req2RestrictAnnonymousAccessSessionsResult)
			$AllOutput.AppendText($Global:Req2NullSessionShares)
			$AllOutput.AppendText($Global:Req2SharingAndSecModelLocalAccountsResult)
			# 2.3.11 Network Security
			$AllOutput.AppendText("`n2.3.11 Network Security`n")
			$AllOutput.AppendText($Global:Req2LocalSystemNTLMResult)
			$AllOutput.AppendText($Global:Req2LocalSystemNULLSessionResult)
			$AllOutput.AppendText($Global:Req2PKU2UOnlineIdentitiesResult)
			$AllOutput.AppendText($Global:Req2KerberosEncryptionTypesResult)
			$AllOutput.AppendText($Global:Req2LanManagerHashResult)
			$AllOutput.AppendText($Global:Req2ForceLogoffAfterHoursExpireResult)
			$AllOutput.AppendText($Global:Req2LanManagerAuthLevelResult)
			$AllOutput.AppendText($Global:Req2LDAPClientSigningReqsResult)
			$AllOutput.AppendText($Global:Req2NTLMMinClientResults)
			$AllOutput.AppendText($Global:Req2NTLMMinServerResults)
			# 2.3.12 Recovery Console
			$AllOutput.AppendText("`n2.3.12 Recovery Console`n")
			$AllOutput.AppendText($Global:Req2AutoAdminLogonResult)
			$AllOutput.AppendText($Global:Req2AllowFloppyAccessResult)
			# 2.3.13 Shutdown
			$AllOutput.AppendText("`n2.3.13 Shutdown`n")
			$AllOutput.AppendText($Global:Req2ShutdownWithoutLoggingInResult)
			# 2.3.14 System Cryptography
			$AllOutput.AppendText("`n2.3.14 System Cryptography`n")
			$AllOutput.AppendText($Global:Req2FipsPolicyResults)
			$AllOutput.AppendText($Global:Req2UserKeyProtectionResult)
			# 2.3.15 System objects
			$AllOutput.AppendText("`n2.3.15 System objects`n")
			$AllOutput.AppendText($Global:Req2CaseInsensitivityResult)
			$AllOutput.AppendText($Global:Req2StrengthenPermissionsResult)
			# 2.3.17 User Account Control
			$AllOutput.AppendText("`n2.3.17 User Account Control`n")
			$AllOutput.AppendText($Global:Req2AdminApprovalModeResult)
			$AllOutput.AppendText($Global:Req2BehaviorforAdminResult)
			$AllOutput.AppendText($Global:Req2BehaviorforStandardResult)
			$AllOutput.AppendText($Global:Req2InstallerDetectionResult)
			$AllOutput.AppendText($Global:Req2UIAccessSecureLocationsResult)
			$AllOutput.AppendText($Global:Req2RunAllAdminsModeResult)
			$AllOutput.AppendText($Global:Req2SwitchSecureDesktopResult)
			$AllOutput.AppendText($Global:Req2VitualFileLocationsResult)
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
			$Global:Req2LocalDrivesExtraHTML = $LocalDrivesExtra | ConvertTo-Html -As Table -Fragment -Property Name,DriveType,DriveFormat,IsReady,VolumeLabel -PreContent "<h3>Extra Drive Information</h3>"
			# Network Share
			$LocalNetworkShares = Get-SmbShare | Select-Object Name,ScopeName,Path,Description,CurrentUsers,Special
			$LocalNetworkSharesRTB = $LocalNetworkShares | Format-Table | Out-String
			$Global:Req2LocalNetworkSharesHTML = $LocalNetworkShares | ConvertTo-Html -As Table -Fragment -Property Name,ScopeName,Path,Description,CurrentUsers,Special -PreContent "<h3>Network Shares</h3>"
			# Counters for Local Drives and Network Drives
			$LocalDriveCounter = 0
			foreach($LocalDrive in $LocalDrives){
				$LocalDriveCounter++
			}
			$NetworkDriveCounter  = 0
			foreach($SMBShare in $LocalNetworkShares){
				$NetworkDriveCounter++
			}
			# Totals
			$Global:LocalDrivesResult = "2.2.5     - [INFORMATION] - Detected $LocalDriveCounter Local Drives.`n"
			$Global:LocalDrivesResultHTML = "2.2.5     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $LocalDriveCounter Local Drives.`n"
			$Global:SMBSharesResult = "2.2.5     - [INFORMATION] - Detected $NetworkDriveCounter Network Shares.`n"
			$Global:SMBSharesResultHTML = "2.2.5     - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $NetworkDriveCounter Network Shares.`n"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($LocalDrivesRTB + "`nExtra Drive Information`n" + $LocalDrivesExtraRTB + "`nNetwork Shares`n" + $LocalNetworkSharesRTB)
				$Req2Output.AppendText("2.2.5     - [INFORMATION] - Detected " + $LocalDriveCounter + " Local Drives.`n")
				$Req2Output.AppendText("2.2.5     - [INFORMATION] - Detected " + $NetworkDriveCounter + " Network Shares.`n")
			}else{
				$AllOutput.AppendText($LocalDrivesRTB + "`nExtra Drive Information`n" + $LocalDrivesExtraRTB + "`nNetwork Shares`n" + $LocalNetworkSharesRTB)
				$AllOutput.AppendText("2.2.5     - [INFORMATION] - Detected " + $LocalDriveCounter + " Local Drives.`n")
				$AllOutput.AppendText("2.2.5     - [INFORMATION] - Detected " + $NetworkDriveCounter + " Network Shares.`n")
			}
		# Edge Case
		}catch{
			$Global:Req2LocalDrivesHTML = "<h2>2.2.5 - Grab Local Drives and Network Shares</h2><p>Error - Could Not Grab Local Drives or Network Shares.</p>"
			$Global:Req2LocalDrivesExtraHTML = ""
			$Global:Req2LocalNetworkSharesHTML = "<h3>Network Shares</h3><p>Error</p>"
			$Global:LocalDrivesResult = "2.2.5     - [ERROR] - Could Not Grab Local Drives.`n"
			$Global:SMBSharesResult = "2.2.5     - [ERROR] - Could Not Grab Network Shares.`n"
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
			# Counters for Computer Objects
			$ADComputerCounter = 0
			foreach($Computer in $ADComputerListAll){
				$ADComputerCounter++
			}
			#Totals
			$Global:ADComputersResult = "2.4       - [INFORMATION] - Detected $ADComputerCounter Active Directory Computer Objects.`n"
			$Global:ADComputersResultHTML = "2.4       - <span id=`"CISInfoStatus`">[INFORMATION]</span> - Detected $ADComputerCounter Active Directory Computer Objects.`n"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText($ADComputerListAllRTB)
				$Req2Output.AppendText("2.4       - [INFORMATION] - Detected " + $ADComputerCounter + " Active Directory Computer Objects.`n")
			}else{
				$AllOutput.AppendText($ADComputerListAllRTB)
				$AllOutput.AppendText("2.4       - [INFORMATION] - Detected " + $ADComputerCounter + " Active Directory Computer Objects.`n")
			}
		# Edge Case
		}catch{
			$Global:Req2ADComputerListAll = "<h2>2.4 - Grab All Computer Objects from Active Directory</h2><p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			$Global:ADComputersResult = "2.4       - [ERROR] - Unable to contact Active Directory, Ensure Script is run on a Domain Controller.`n"
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
		# IPV4 Adapters Function
		try{
			# Data Gathering
			$IPV4Adapters = Get-NetIPAddress | Select-Object InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState | Where-Object AddressFamily -eq IPv4 | Sort-Object InterfaceIndex,InterfaceAlias
			$IPV4AdaptersRTB = $IPV4Adapters | Format-Table | Out-String
			$Global:Req2IPV4AdaptersHTML = $IPV4Adapters | ConvertTo-Html -As Table -Property InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState -Fragment -PreContent "<h3>IPV4 Adapters</h3>"
			# Data Output for IPV4 Adapters
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV4 Adapters`n")
				$Req2Output.AppendText($IPV4AdaptersRTB)
			}else{
				$AllOutput.AppendText("IPV4 Adapters`n")
				$AllOutput.AppendText($IPV4AdaptersRTB)
			}
		# Edge Case for IPV4 Adapters
		}catch{
			$Global:Req2IPV4AdaptersHTML = "<h3>IPV4 Adapters</h3><p>Unable to List IPV4 Adapters.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List IPV4 Adapters.`n")
			}else{
				$AllOutput.AppendText("`nUnable to List IPV4 Adapters.`n")
			}
		}
		# IPV4 Neighbors Function
		try{
			# Data Gathering
			$IPV4Neighbors = Get-NetNeighbor -AddressFamily IPv4 -ErrorAction Stop | Where-Object State -ne Unreachable | Sort-Object ifIndex,IPAddress
			$IPV4NeighborsRTB = $IPV4Neighbors | Format-Table | Out-String
			$Global:Req2IPV4NeighborsHTML = $IPV4Neighbors | ConvertTo-Html -As Table -Property ifIndex,InterfaceAlias,IPAddress,LinkLayerAddress,State,PolicyStore -Fragment -PreContent "<h3>IPV4 Neighbors</h3>"
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Stale</td>','<td class="AvailableStatus">Stale</td>' 
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Reachable</td>','<td class="InstalledStatus">Reachable</td>'
			$Global:Req2IPV4NeighborsHTML = $Global:Req2IPV4NeighborsHTML -replace '<td>Permanent</td>','<td class="RemovedStatus">Permanent</td>'
			# Data Output for IPV4
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV4 Neighbors`n")
				$Req2Output.AppendText($IPV4NeighborsRTB)
			}else{
				$AllOutput.AppendText("IPV4 Neighbors`n")
				$AllOutput.AppendText($IPV4NeighborsRTB)
			}
		# Edge Case IPV4 Neighbors
		}catch{
			$Global:Req2IPV4NeighborsHTML = "<h3>IPV4 Neighbors</h3><p>Unable to List IPV4 Neighboring Devices.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List IPV4 Neighboring Devices.`n")
			}else{
				$AllOutput.AppendText("`nUnable to List IPV4 Neighboring Devices.`n")
			}
		}

		# Data Gathering for IPV6
		# IPV6 Adapters Function
		try{
			# Data Gathering
			$IPV6Adapters = Get-NetIPAddress | Select-Object InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState | Where-Object AddressFamily -eq IPv6 | Sort-Object InterfaceIndex,InterfaceAlias
			$IPV6AdaptersRTB = $IPV6Adapters | Format-Table | Out-String
			$Global:Req2IPV6AdaptersHTML = $IPV6Adapters | ConvertTo-Html -As Table -Property InterfaceIndex,InterfaceAlias,IPAddress,PrefixLength,AddressFamily,PrefixOrigin,SuffixOrigin,AddressState -Fragment -PreContent "<h3>IPV6 Adapters</h3>"
			# Data Output for IPV6 Adapters
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV6 Adapters`n")
				$Req2Output.AppendText($IPV6AdaptersRTB)
			}else{
				$AllOutput.AppendText("IPV6 Adapters`n")
				$AllOutput.AppendText($IPV6AdaptersRTB)
			}
		# Edge Case for IPV6 Adapters
		}catch{
			$Global:Req2IPV6AdaptersHTML = "<h3>IPV6 Adapters</h3><p>Unable to List IPV6 Adapters.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nUnable to List IPV6 Adapters.`n")
			}else{
				$AllOutput.AppendText("`nUnable to List IPV6 Adapters.`n")
			}
		}
		# IPV6 Neighbors Function
		try{
			# Data Gathering
			$IPV6Neighbors = Get-NetNeighbor -AddressFamily IPv6 -ErrorAction Stop | Where-Object State -ne Unreachable | Sort-Object ifIndex,IPAddress
			$IPV6NeighborsRTB = $IPV6Neighbors | Format-Table | Out-String
			$Global:Req2IPV6NeighborsHTML = $IPV6Neighbors | ConvertTo-Html -As Table -Property ifIndex,InterfaceAlias,IPAddress,LinkLayerAddress,State,PolicyStore -Fragment -PreContent "<h3>IPV6 Neighbors</h3>"
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Stale</td>','<td class="AvailableStatus">Stale</td>' 
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Reachable</td>','<td class="InstalledStatus">Reachable</td>'
			$Global:Req2IPV6NeighborsHTML = $Global:Req2IPV6NeighborsHTML -replace '<td>Permanent</td>','<td class="RemovedStatus">Permanent</td>'
			# Data Output for IPV6
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("IPV6 Neighbors`n")
				$Req2Output.AppendText($IPV6NeighborsRTB)
			}else{
				$AllOutput.AppendText("IPV6 Neighbors`n")
				$AllOutput.AppendText($IPV6NeighborsRTB)
			}
		# Edge Case IPV6 Neighbors
		}catch{
			$Global:Req2IPV6NeighborsHTML = "<h3>IPV6 Neighbors</h3><p>Unable to List IPV6 Neighboring Devices.</p>"
			if($EverythingToggle -eq $false){
				$Req2Output.AppendText("`nIPV6 Neighbors`nUnable to List IPV6 Neighboring Devices.`n`n")
			}else{
				$AllOutput.AppendText("`nIPV6 Neighbors`nUnable to List IPV6 Neighboring Devices.`n`n")
			}
		}
	}

	# onClick Event Handler - Requirement Two
	$Req2ScriptList_ListUpdate = {
		if($Req2ScriptList.SelectedItem -eq "2.1 - Test Vendor Default Credentials in AD"){
			$Req2Output.Clear()
			Req2TestDefaultAccounts
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.1 - Grab Installed Windows Roles and Features"){
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
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.4 - Grab System Security Policy Configuration"){
			$Req2Output.Clear()
			Req2GrabSysConfig
		}elseif($Req2ScriptList.SelectedItem -eq "2.2.5 - Grab Local Drives and Network Shares"){
			$Req2Output.Clear()
			Req2GrabDrivesAndShares
		}elseif($Req2ScriptList.SelectedItem -eq "2.4 - Grab All Computer Objects from Active Directory"){
			$Req2Output.Clear()
			Req2GrabADComputers
		}elseif($Req2ScriptList.SelectedItem -eq "2.4 - Map Neighboring Devices"){
			$Req2Output.Clear()
			Req2MapNeighboringDevices
		}elseif($Req2ScriptList.SelectedItem -eq "Requirement Two Compliance Check"){
			$Req2Output.Clear()
			Req2ComplianceChecker
		}elseif($Req2ScriptList.SelectedItem -eq "Everything in Requirement Two"){
			$Req2EverythingSwitch = $true
			$Req2Output.Clear()
			$Req2Output.AppendText("Everything in Requirement Two `n")
			$Req2OutputLabel.Text = "Output: Progressing... 10%"
			$Req2OutputLabel.Refresh()
			Req2ComplianceChecker
			$Req2Output.AppendText($Global:SectionHeader)
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
			#Req2GrabSysConfig
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
			$Req2OutputLabel.Refresh()
			$Req2EverythingSwitch = $false
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
		$Requirement2Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementTwoName $ReportComputerName $Global:Req2PCIDSSComplianceResultHTML $Global:Req2CISComplianceResultHTMLFinal $Global:Req2UserCredentialResult $Global:Req2FeatureListHTML $Global:Req2ProcessListHTML $Global:Req2SvcListRunningHTML $Global:Req2SvcListListeningHTML $Global:Req2UDPListHTML $Global:Req2SoftwareList32BitHTML $Global:Req2SoftwareList64BitHTML $Global:Req2LocalDrivesHTML $Global:Req2LocalDrivesExtraHTML $Global:Req2LocalNetworkSharesHTML $Global:Req2ADComputerListAll $Global:Req2IPV4AdaptersHTML $Global:Req2IPV4NeighborsHTML $Global:Req2IPV6AdaptersHTML $Global:Req2IPV6NeighborsHTML" -Head $CSSHeader -Title "PCI DSS Requirement Two Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement2ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html"
		$Requirement2Report | Out-File $Requirement2ReportPath
		$Req2Output.AppendText("Requirement Two Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html")
		$Req2EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Two Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Two-Report.html","Requirement Two Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$Req2ExportReport = {
			$Req2Output.Clear()
			$Req2Output.AppendText("Writing Report for the Following`n`n")
			$Req2OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req2OutputLabel.Refresh()
			$Req2ExportingSwitch = $true
			Req2ComplianceChecker
			$Req2Output.AppendText($Global:SectionHeader)
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
			#Req2GrabSysConfig
			#$Req2Output.AppendText($Global:SectionHeader)
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
			$Req2OutputLabel.Refresh()
			$Req2ExportingSwitch = $false
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
			$Global:Req4CurrentUserCertsHTML = "<h3>Current User Certificates</h3><pre>" + $Req4CurrentUserCertsRTB + "</pre>"
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
		$Requirement4Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementFourName $ReportRequirementName $ReportComputerName $Global:Req4WifiListHTML $Global:Req4LocalMachineCertsHTML $Global:Req4CurrentUserCertsHTML" -Head $CSSHeader -Title "PCI DSS Requirement Four Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement4ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html"
		$Requirement4Report | Out-File $Requirement4ReportPath
		$Req4Output.AppendText("Requirement Four Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html")
		$Req4EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Four Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Four-Report.html","Requirement Four Report Exported Successfully","OK","Information")
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
		# Progress Bar
		$Req5OutputLabel.Text = "Output: Progressing... 10%"
		$Req5OutputLabel.Refresh()
		# Data Gathering
		try{
			# Reg Paths to Check, 32 Bit and then 64 Bit
			$paths=@('HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\')
			# Initialize Empty Arrays & Counter
			$AppArray = @()
			$AppPubArray = @()
			$AppCorrectCounter = 0
			$TotalCombinedAppCounter = 0
			# Grab All (32bit,64bit) Apps and Add to New Array
			foreach($path in $paths){
				$AppArray += Get-ChildItem -Path $path | Get-ItemProperty | Select-Object DisplayName, PSChildName, Publisher, InstallDate, DisplayVersion
			}
			# Loop New Array and Check Total Array for Anti-Virus Apps
			foreach($App in $AppArray){
				# Check Publisher for Match
				if(($App.Publisher -like "*Avira*") -or ($App.Publisher -like "*Avast*") -or ($App.Publisher -like "*AVG*") -or ($App.Publisher -like "*Bitdefender*") -or ($App.Publisher -like "*ESET*") -or ($App.Publisher -like "*Kaspersky*") -or ($App.Publisher -like "*Malwarebytes*") -or ($App.Publisher -like "*McAfee*") -or ($App.Publisher -like "*NortonLifeLock*") -or ($App.Publisher -like "*Sophos*") -or ($App.Publisher -like "*Symantec*") -or ($App.Publisher -like "*Trend Micro*")){
					$AppPubArray += $App
					$AppCorrectCounter++
				}
				# Increase Total App Count
				$TotalCombinedAppCounter++
			}
			# Progress Bar
			$Req5OutputLabel.Text = "Output: Progressing... 50%"
			$Req5OutputLabel.Refresh()

			# Checker Counter, Display Results
			if($AppCorrectCounter -gt 0){
				# Convert to HTML
				$SortAppPubArray = $AppPubArray | Sort-Object DisplayName,PSChildName
				$Global:Req5AVProgramQueryHTML = $SortAppPubArray | ConvertTo-Html -Fragment -As Table -PreContent "<h2>5.1 - Antivirus Program and GPO Analysis</h2><h3>List of Anti-Virus Programs Detected</h3>" -PostContent "<p>Total Apps: $AppCorrectCounter</p>"
				# Data Output
				$AVProgramQueryRTB = $AppPubArray | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName | Format-Table | Out-String
				# Write Output
				if($EverythingToggle -eq $false){
					$Req5Output.AppendText($AVProgramQueryRTB + "Total Apps: " + $AppCorrectCounter)
				}else{
					$AllOutput.AppendText($AVProgramQueryRTB + "Total Apps: " + $AppCorrectCounter)
				}
			# Edge Case No Anti-Virus Found
			}else{
				# Convert to HTML
				$SortAppArray = $AppArray | Sort-Object DisplayName,PSChildName
				$Global:Req5AVProgramQueryHTML = $SortAppArray | ConvertTo-Html -Fragment -As Table -PreContent "<h2>5.1 - Antivirus Program and GPO Analysis</h2><h3>No Anti-Virus detected, Here is the list of all programs detected</h3>"  -PostContent "<p>Total Apps: $TotalCombinedAppCounter</p>"
				# Data Output
				$AVProgramQueryRTB = $AppArray | Select-Object DisplayName, Publisher, InstallDate, DisplayVersion | Sort-Object DisplayName | Format-Table | Out-String
				# Write Output
				if($EverythingToggle -eq $false){
					$Req5Output.AppendText("No Anti-Virus detected, Here is the list of all programs detected and a GPO Dump for futher analysis:`n")
					$Req5Output.AppendText($AVProgramQueryRTB + "Total Apps: " + $TotalCombinedAppCounter)
					$Req5Output.AppendText("`nCheck GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
				}else{
					$AllOutput.AppendText("No AntiVirus detected, Here is the list of all programs detected and check the GPO Dump section for futher analysis.`n")
					$AllOutput.AppendText($AVProgramQueryRTB + "Total Apps: " + $TotalCombinedAppCounter)
					$AllOutput.AppendText("`nCheck GPO Dump for Windows Defender Settings, if the anti-virus policy is not there, requirement has failed.`n")
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
		# Progress Bar
		$Req5OutputLabel.Text = "Output: Progressing... 90%"
		$Req5OutputLabel.Refresh()

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
			# Progress Bar
			$Req5OutputLabel.Text = "Output:"
			$Req5OutputLabel.Refresh()
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
			# Progress Bar
			$Req5OutputLabel.Text = "Output:"
			$Req5OutputLabel.Refresh()
		# If the switch has not been switch then just output the GPO Dump for only after the Anti-Virus Programs/List of Programs.
		}else{
			$Req5Output.AppendText($Global:SectionHeader)
			$Req5Output.AppendText("GPO Dump")
			$Req5Output.AppendText($global:GPODump)
			# Progress Bar
			$Req5OutputLabel.Text = "Output:"
			$Req5OutputLabel.Refresh()
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
		$Requirement5Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementFiveName $ReportComputerName $Global:Req5AVProgramQueryHTML $Global:Req5SoftwareDeploymentHTML $Global:Req5AVPermsHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Five Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement5ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html"
		$Requirement5Report | Out-File $Requirement5ReportPath
		$Req5Output.AppendText("Requirement Five Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html")
		$Req5EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Five Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Five-Report.html","Requirement Five Report Exported Successfully","OK","Information")
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
		$UserFolderInputMessageBox = [System.Windows.Forms.MessageBox]::Show("When this Warning Message is Closed, You will be prompted to select a folder for analysis.","Warning","OK","Information")
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
	
	# 7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions
	# Some Code is taken from Brian Clanton & Max Kozlov from PowerShell.org - https://powershell.org/forums/topic/find-deny-rights-on-a-list-of-folders/
	Function Req7DenyAll {
		if(-not([string]::IsNullOrEmpty($Global:FilePathFilePopupTmp))){
			# Write Header
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions`nParent Folder Selected: " + $Global:FilePathFilePopupTmp + "`n`n")
			}else{
				$AllOutput.AppendText("7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions`nParent Folder Selected: " + $Global:FilePathFilePopupTmp + "`n`n")
			}
			# Find premissions for user selected path
			try{
				$Req7FolderPerms = Get-ChildItem -Path $Global:FilePathFilePopupTmp | Get-Acl
				#$Req7FolderPermsRTB = $Req7FolderPerms | Format-List | Out-String
				# Edge Case for child objects
				if([string]::IsNullOrEmpty($Req7FolderPerms)){
					$Global:Req7FolderPermsHTML = "<h2>7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions</h2><p>No Child Objects Found, Select Root Object that contains a Child Object.<br>Path Selected: $Global:FilePathFilePopupTmp</p>"
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText("No Child Objects Found, Select Root Object that contains a Child Object. Path Selected: " + $Global:FilePathFilePopupTmp)
					}else{
						$AllOutput.AppendText("No Child Objects Found, Select Root Object that contains a Child Object. Path Selected: " + $Global:FilePathFilePopupTmp)
					}
				# Data Processing Phase
				}else{
					# Iterate through Each ACL
					foreach ($acl in $Req7FolderPerms){
						# Define Deny Flag
						$NoDeny = $true
						# Define Path 
						$ConvertedPath = Convert-Path $acl.Path
						# Iterate through each ACS's access control and test for any 'Deny' Right.
						foreach ($access in $acl.Access){
							if ($access.AccessControlType -eq "Deny"){
								# If a Deny is found, Write Output of Result
								# Define Outputs
								$TempVarOutstring1 = $access.FileSystemRights | Out-String
								$TempVarOutstring2 = $access.IdentityReference.value | Out-String
								$TempOutput = $TempVarOutstring1 + " is set to Deny for " + $TempVarOutstring2 + " at " + $ConvertedPath
								$TempOutput = $TempOutput  -replace "`n|`r",""
								$TempOutput2 = $TempOutput + "`n"
								# Write Outputs
								if($EverythingToggle -eq $false){
									$Req7Output.AppendText($TempOutput2)
								}else{
									$AllOutput.AppendText($TempOutput2)
								}
								# Append to HTML Temp Var
								$Req7DenyAll += $TempOutput2 + "<br>"
								# Set flag
								$NoDeny = $false
							}
						}
						# Print Output & Check Flag
						if ($NoDeny) {  # check flag
							if($EverythingToggle -eq $false){
								$Req7Output.AppendText("No deny at all for: " + $ConvertedPath + "`n")
							}else{
								$AllOutput.AppendText("No deny at all for: " + $ConvertedPath + "`n")
							}
							# Append to HTML Temp Var
							$Req7DenyAll += "No deny at all for: " + $ConvertedPath + "<br>"
						}
					}
					# Define HTML Header
					$Global:Req7FolderPermsHTML = "<h2>7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions</h2>" + "<p>" + $Req7DenyAll + "</p>"
				}
			# Edge Case
			}catch{
				$Global:Req7FolderPermsHTML = "<h2>7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions</h2><p>An Error Has Occurred...</p>"
				if($EverythingToggle -eq $false){
					$Req7Output.AppendText("`An Error Has Occurred...`n")
				}else{
					$AllOutput.AppendText("`An Error Has Occurred...`n")
				}
			}
		# Find Edge-Case if user input is empty
		}else{
			$Global:Req7FolderPermsHTML = "<h2>7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions</h2><p>Invalid Folder Selected</p>"
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
	Function Req7UserPrivileges {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req7Output.AppendText("7.1.2 - Grab User Privileges`nThis may take a while`n`n")
			Start-Sleep -Seconds 0.5
		}else{
			$AllOutput.AppendText("7.1.2 - Grab User Privileges`nThis may take a while`n`n")
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
				$GroupMembership = Get-ADGroupMember -Identity $Group | Select-Object Name,SamaccountName,objectClass,distinguishedName,SID | Sort-Object Name,objectClass
				$GroupMembershipRTB = $GroupMembership | Format-Table -Autosize | Out-String -Width 1200
				$GroupINFORMATION = Get-ADGroup -Identity $Group
				$GroupINFORMATIONRTB = $GroupINFORMATION | Format-List | Out-String
				# HTML Info Stuff
				$Req7FormatGroupInfoHTML = $GroupINFORMATION | ConvertTo-Html -As Table -Property DistinguishedName,GroupCategory,GroupScope,Name,ObjectClass,ObjectGUID,SamAccountName,SID -Fragment -PreContent "<h3>$Group Group Details</h3>"
				# Data Output/Append
				if([string]::IsNullOrEmpty($GroupMembership)){
					# Add to HTML List 
					$Req7GroupMembershipList += $Req7FormatGroupInfoHTML + "<h3>No Users in $Group</h3><p>$Global:SectionBreak</p>"
					# Data Output
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText($Group + " Group Details:`n" + $GroupINFORMATIONRTB + "`nNo Users in " + $Group + "`n")
						$Req7Output.AppendText($Global:SectionBreak)
					}else{
						$AllOutput.AppendText($Group + " Group Details:`n" + $GroupINFORMATIONRTB + "`nNo Users in " + $Group + "`n")
						$AllOutput.AppendText($Global:SectionBreak)
					}
				}else{
					# Add to HTML List
					$Req7FormatGroupListHTML = $GroupMembership | ConvertTo-Html -As Table -Property Name,SamaccountName,objectClass,distinguishedName,SID -Fragment -PreContent "<h3>Here are the Users in $Group</h3>" -PostContent "<p>$Global:SectionBreak</p>"
					$Req7GroupMembershipList += $Req7FormatGroupInfoHTML + $Req7FormatGroupListHTML
					# Data Output
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText($Group + " Group Details:`n" + $GroupINFORMATIONRTB + "`nHere are the Users in " + $Group + "`n" + $GroupMembershipRTB)
						$Req7Output.AppendText($Global:SectionBreak)
					}else{
						$AllOutput.AppendText($Group + " Group Details:`n" + $GroupINFORMATIONRTB + "`nHere are the Users in " + $Group + "`n" + $GroupMembershipRTB)
						$AllOutput.AppendText($Global:SectionBreak)
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

	# 7.1.2 - Grab User Rights Assessment
	Function Req7UserRightsAssessment {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req7Output.AppendText("7.1.2 - Grab User Rights Assessment:`n")
		}else{
			$AllOutput.AppendText("7.1.2 - Grab User Rights Assessment:`n")
		}
		# Data Gathering Function
		Function PrivilegeRights ($TempVarPassThru){
			$NamedStringMatched = $Global:SecDump | Select-String -SimpleMatch $TempVarPassThru
			$NamedStringMatched = $NamedStringMatched -replace '`n|`r| ',""
			$NameStringSplit = $NamedStringMatched.split('=')[1]
			$CharCountSIDComma = ($NameStringSplit.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
			# Define Empty Array
			$SIDArray = @()
			# Edge Case Incase Only One SID/Account
			if($CharCountSIDComma -eq 0){
				$NameStringSplitStar = $NamedStringMatched.split('*')[1]
				$SIDObjectName = Get-ADObject -Filter "objectsid -eq '$NameStringSplitStar'"
				# SID Lookup, Edge Case Incase can't find SID in AD
				if(-not([string]::IsNullOrEmpty($SIDObjectName))){
					$SIDArray += @{'Object Type'=$SIDObjectName.ObjectClass;'Name'=$SIDObjectName.Name;'SID'=$NameStringSplitStar}
				}else{
					$SIDArray += @{'Object Type'='Undefined';'Name'='Unknown';'SID'=$NameStringSplitStar}
				}
			# Else Statement for More SIDS/Accounts
			}else{
				# Remove Stars from SID to Lookup
				$NameStringSplit = $NameStringSplit.replace("*","")
				$CharCountSID = ($NameStringSplit.ToCharArray() | Where-Object {$_ -eq ','} | Measure-Object).Count
				# For Loop, Loop based on commas counted, start from 0 until all commas accounted for.
				for ($loop_index = 0; $loop_index -le $CharCountSID; $loop_index++){ 
					$SplitNamedString = $NameStringSplit.split(',')[$loop_index]
					$SIDObjectName = Get-ADObject -Filter "objectsid -eq '$SplitNamedString'"
					# Add Object If Found
					if(-not([string]::IsNullOrEmpty($SIDObjectName))){
						$SIDArray += @{'Object Type'=$SIDObjectName.ObjectClass;'Name'=$SIDObjectName.Name;'SID'=$SplitNamedString}
					# Edge Case If Not Found
					}else{
						# Check SAM Account Name, Edgecase for manual entry.
						$SIDObjectName2 = Get-ADObject -Filter "SamAccountName -eq '$SplitNamedString'" -properties *
						if(-not([string]::IsNullOrEmpty($SIDObjectName2))){
							$SIDArray += @{'Object Type'=$SIDObjectName2.ObjectClass;'Name'=$SIDObjectName2.Name;'SID'=$SIDObjectName2.objectSid}
						# Edge case for Everyone and Unknown SIDs
						}else{
							if($SplitNamedString -eq "S-1-1-0"){
								$SIDArray += @{'Object Type'='Undefined';'Name'='Everyone';'SID'=$SplitNamedString}
							}else{
								$SIDArray += @{'Object Type'='Undefined';'Name'='Unknown';'SID'=$SplitNamedString}
							}
						}
					}
				}
			}
			# Data Processing, Return Formatted Table
			$CovertedSIDTable = $SIDArray | ForEach {[PSCustomObject]$_}
			Return $CovertedSIDTable
		}

		# Define Data Class
		class PrivilegeMessage {
			[string]$Key
			[string]$Name
		}

		# Data Array to Process in Loop
		$PrivilegeArray = @([PrivilegeMessage]@{Key='SeNetworkLogonRight';Name="Access this computer from the network Privilege"}
		[PrivilegeMessage]@{Key='SeMachineAccountPrivilege';Name="Add workstations to domain Privilege"}
		[PrivilegeMessage]@{Key='SeBackupPrivilege';Name="Back up files and directories Privilege"}
		[PrivilegeMessage]@{Key='SeChangeNotifyPrivilege';Name="Bypass traverse checking Privilege"}
		[PrivilegeMessage]@{Key='SeSystemtimePrivilege';Name="Change the system time Privilege"}
		[PrivilegeMessage]@{Key='SeCreatePagefilePrivilege';Name="Create a pagefile Privilege"}
		[PrivilegeMessage]@{Key='SeDebugPrivilege';Name="Debug programs Privilege"}
		[PrivilegeMessage]@{Key='SeRemoteShutdownPrivilege';Name="Force shutdown from a remote system Privilege"}
		[PrivilegeMessage]@{Key='SeAuditPrivilege';Name="Generate security audits Privilege"}
		[PrivilegeMessage]@{Key='SeIncreaseQuotaPrivilege';Name="Adjust memory quotas for a process Privilege"}
		[PrivilegeMessage]@{Key='SeIncreaseBasePriorityPrivilege';Name="Increase scheduling priority Privilege"}
		[PrivilegeMessage]@{Key='SeLoadDriverPrivilege';Name="Load and unload device drivers Privilege"}
		[PrivilegeMessage]@{Key='SeBatchLogonRight';Name="Log on as a batch job Privilege"}
		[PrivilegeMessage]@{Key='SeServiceLogonRight';Name="Log on as a service Privilege"}
		[PrivilegeMessage]@{Key='SeInteractiveLogonRight';Name="Allow log on locally Privilege"}
		[PrivilegeMessage]@{Key='SeSecurityPrivilege';Name="Manage auditing and security log Privilege"}
		[PrivilegeMessage]@{Key='SeSystemEnvironmentPrivilege';Name="Modify firmware environment values Privilege"}
		[PrivilegeMessage]@{Key='SeProfileSingleProcessPrivilege';Name="Profile single process Privilege"}
		[PrivilegeMessage]@{Key='SeSystemProfilePrivilege';Name="Profile system performance Privilege"}
		[PrivilegeMessage]@{Key='SeAssignPrimaryTokenPrivilege';Name="Replace a process level token Privilege"}
		[PrivilegeMessage]@{Key='SeRestorePrivilege';Name="Restore files and directories Privilege"}
		[PrivilegeMessage]@{Key='SeShutdownPrivilege';Name="Shut down the system Privilege"}
		[PrivilegeMessage]@{Key='SeTakeOwnershipPrivilege';Name="Take ownership of files or other objects Privilege"}
		[PrivilegeMessage]@{Key='SeUndockPrivilege';Name="Remove computer from docking station Privilege"}
		[PrivilegeMessage]@{Key='SeEnableDelegationPrivilege';Name="Enable computer and user accounts to be trusted for delegation Privilege"}
		[PrivilegeMessage]@{Key='SeManageVolumePrivilege';Name="Perform volume maintenance tasks Privilege"}
		[PrivilegeMessage]@{Key='SeRemoteInteractiveLogonRight';Name="Allow log on through Remote Desktop Services Privilege"}
		[PrivilegeMessage]@{Key='SeImpersonatePrivilege';Name="Impersonate a client after authentication Privilege"}
		[PrivilegeMessage]@{Key='SeCreateGlobalPrivilege';Name="Create global objects Privilege"}
		[PrivilegeMessage]@{Key='SeIncreaseWorkingSetPrivilege';Name="Increase a process working set Privilege"}
		[PrivilegeMessage]@{Key='SeTimeZonePrivilege';Name="Change the time zone Privilege"}
		[PrivilegeMessage]@{Key='SeCreateSymbolicLinkPrivilege';Name="Create symbolic links Privilege"}
		[PrivilegeMessage]@{Key='SeDelegateSessionUserImpersonatePrivilege';Name="Obtain an impersonation token for another user in the same session Privilege"})

		# Define HTML Report Header
		$Global:Req7UserRightsHTML = "<h2>7.1.2 - Grab User Rights Assessment</h2>"

		# Define OS Build and Catch Edge Case in 2012, (Missing Key "SeDelegateSessionUserImpersonatePrivilege")
		$OSVersion = [string][environment]::OSVersion.Version.major + '.' + [environment]::OSVersion.Version.minor

		# Loop And Gather Data and Output Data
		if($Global:TestDCConnection -eq $true){
			foreach($Row in $PrivilegeArray){
				# Break on Edge Case for Server 2012 and Below
				if(("6.3" -le $OSVersion) -and ($Row.Key -eq "SeDelegateSessionUserImpersonatePrivilege")){
					break
				}else{
					$DataRow = PrivilegeRights -TempVarPassThru $Row.Key
					$CovertedSIDTableRTB = $DataRow | Select-Object 'Object Type','Name','SID' | Sort-Object 'Object Type','Name','SID' | Format-Table -AutoSize | Out-String
					# HTML Report
					$H3RowHeader = $Row.Name
					$CovertedSIDTableHTML = $DataRow | ConvertTo-Html -As Table -Property 'Object Type','Name','SID' -Fragment -PreContent "<h3>$H3RowHeader</h3>"
					$Global:Req7UserRightsHTML += $CovertedSIDTableHTML
					# Data Output
					if($EverythingToggle -eq $false){
						$Req7Output.AppendText($Row.Name + "`n" + $CovertedSIDTableRTB + "`n------------------------------------------------------`n")
					}else{
						$AllOutput.AppendText($Row.Name + "`n" + $CovertedSIDTableRTB + "`n-----------------------------------------------------`n")
					}
				}
			}
		# Edge Case - Non DC
		}else{
			# HTML Report
			$Global:Req7UserRightsHTML += "<p>Unable to contact Active Directory, Ensure Script is run on a Domain Controller.</p>"
			# Write Output
			if($EverythingToggle -eq $false){
				$Req7Output.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n`n")
			}else{
				$AllOutput.AppendText("`nUnable to contact Active Directory, Ensure Script is run on a Domain Controller.`n`n")
			}

		}
	}

	# onClick event handler
	$Req7ScriptList_ListUpdate = {
		if($Req7ScriptList.SelectedItem -eq "7.1 - Grab and analyse folder permissions that hold sensitive data"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7FolderPerms
		}elseif($Req7ScriptList.SelectedItem -eq "7.2 - Check Sub-Folders and Sub-Files for Deny All Permissions"){
			$Req7Output.Clear()
			Req7FolderInput
			Req7DenyAll
		}elseif($Req7ScriptList.SelectedItem -eq "7.1.2 - Grab User Privileges"){
			$Req7Output.Clear()
			Req7UserPrivileges
		}elseif($Req7ScriptList.SelectedItem -eq "7.1.2 - Grab User Rights Assessment"){
			$Req7Output.Clear()
			Req7UserRightsAssessment
		}elseif($Req7ScriptList.SelectedItem -eq "Everything in Requirement Seven"){
			$Req7Output.Clear()
			$Req7Output.AppendText("Everything in Requirement Seven`n")
				$Req7OutputLabel.Text = "Output: Progressing... Waiting for User Input. 0%"
				$Req7OutputLabel.Refresh()
				Req7FolderInput
				$Req7OutputLabel.Text = "Output: Progressing... 10%"
				$Req7OutputLabel.Refresh()
				Req7FolderPerms
				$Req7Output.AppendText($Global:SectionHeader)
				$Req7OutputLabel.Text = "Output: Progressing... 40%"
				$Req7OutputLabel.Refresh()
				Req7DenyAll
				$Req7Output.AppendText($Global:SectionHeader)
				$Req7OutputLabel.Text = "Output: Progressing... 60%"
				$Req7OutputLabel.Refresh()
				Req7UserPrivileges
				$Req7Output.AppendText($Global:SectionHeader)
				$Req7OutputLabel.Text = "Output: Progressing... 80%"
				$Req7OutputLabel.Refresh()
				Req7UserRightsAssessment
				$Req7Output.AppendText($Global:SectionHeader)
				$Req7OutputLabel.Text = "Output:"
				$Req7OutputLabel.Refresh()
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
		$Requirement7Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementSevenName $ReportComputerName $Global:Req7LocalFolderPermsHTML $Global:Req7SambaShareStatusHTML $Global:Req7FolderPermsHTML $Global:Req7GroupMembershipListHTML $Global:Req7UserRightsHTML" -Head $CSSHeader -Title "PCI DSS Requirement Seven Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement7ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html"
		$Requirement7Report | Out-File $Requirement7ReportPath
		$Req7Output.AppendText("Requirement Seven Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html")
		$Req7EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Seven Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Seven-Report.html","Requirement Seven Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$Req7ExportReport = {
			$Req7Output.Clear()
			$Req7Output.AppendText("Writing Report for the Following`n`n")
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress. Waiting for User Input... 0%"
			$Req7OutputLabel.Refresh()
			Req7FolderInput
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req7OutputLabel.Refresh()
			Req7FolderPerms
			$Req7Output.AppendText($Global:SectionHeader)
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress... 40%"
			$Req7OutputLabel.Refresh()
			Req7DenyAll
			$Req7Output.AppendText($Global:SectionHeader)
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress... 60%"
			$Req7OutputLabel.Refresh()
			Req7UserPrivileges
			$Req7Output.AppendText($Global:SectionHeader)
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress... 80%"
			$Req7OutputLabel.Refresh()
			Req7UserRightsAssessment
			$Req7OutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$Req7OutputLabel.Refresh()
			Req7ExportReportFunction
			$Req7OutputLabel.Text = "Output:"
			$Req7OutputLabel.Refresh()
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

	# 8.2 - Password Policy Checker for PCI-DSS
	Function Req8PasswordChecker{
	# Write Header
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText("8.2 - Password Policy Checker for PCI-DSS:`n`n")
		}else{
			$AllOutput.AppendText("8.2 - Password Policy Checker for PCI-DSS:`n`n")
		}
		# Set Counters
		$PCIDSSPassCounter = 0
		$PCIDSSFailCounter = 0
		# Data Gathering
			# Limit repeated access attempts by locking out the user ID after not more than six attempts.
			$PassCheckAcctLockoutThreshold = $Global:SecDump | Select-String -SimpleMatch 'LockoutBadCount' | Out-String
			$PassCheckAcctLockoutThresholdResult = $PassCheckAcctLockoutThreshold.split(' ')[2]
			$PassCheckAcctLockoutThresholdResult = $PassCheckAcctLockoutThresholdResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckAcctLockoutThreshold))){
				if(($PassCheckAcctLockoutThresholdResult -le "6") -and ($PassCheckAcctLockoutThresholdResult -ne "0")){
					$Global:Req8PassCheckAcctLockoutThresholdResult = "8.1.6 - [PASS] - Account lockout threshold is Set to 6 or fewer invalid logon attempts, and not 0. Current Value: $PassCheckAcctLockoutThresholdResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckAcctLockoutThresholdResultHTML = "8.1.6 - <span id=`"CISPassStatus`">[PASS]</span> - Account lockout threshold is Set to 6 or fewer invalid logon attempts, and not 0. Current Value: $PassCheckAcctLockoutThresholdResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckAcctLockoutThresholdResult = "8.1.6 - [FAILED] - Account lockout threshold is Not set to 6 or fewer invalid logon attempts, or is Set to 0. Current Value: $PassCheckAcctLockoutThresholdResult.`n"
					$Global:Req8PassCheckAcctLockoutThresholdResultHTML = "8.1.6 - <span id=`"CISFailedStatus`">[FAILED]</span> - Account lockout threshold is Not set to 6 or fewer invalid logon attempts, or is Set to 0. Current Value: $PassCheckAcctLockoutThresholdResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckAcctLockoutThresholdResult = "8.1.6 - [FAILED] - Account lockout threshold is Not Configured.`n"
				$Global:Req8PassCheckAcctLockoutThresholdResultHTML = "8.1.6 - <span id=`"CISFailedStatus`">[FAILED]</span> - Account lockout threshold is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Set the lockout duration to a minimum of 30 minutes or until an administrator enables the user ID.
			$PassCheckAcctLockoutDuration = $Global:SecDump | Select-String -SimpleMatch 'LockoutDuration' | Out-String
			$PassCheckAcctLockoutDurationResult = $PassCheckAcctLockoutDuration.split(' ')[2]
			$PassCheckAcctLockoutDurationResult = $PassCheckAcctLockoutDurationResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckAcctLockoutDuration))){
				if($PassCheckAcctLockoutDurationResult -ge "30"){
					$Global:Req8PassCheckAcctLockoutDurationResult = "8.1.7 - [PASS] - Account lockout duration is set to 30 or more minutes. Current Value: $PassCheckAcctLockoutDurationResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckAcctLockoutDurationResultHTML = "8.1.7 - <span id=`"CISPassStatus`">[PASS]</span> - Account lockout duration is set to 30 or more minutes. Current Value: $PassCheckAcctLockoutDurationResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckAcctLockoutDurationResult = "8.1.7 - [FAILED] - Account lockout duration is set to less than 30 minutes. Current Value: $PassCheckAcctLockoutDurationResult.`n"
					$Global:Req8PassCheckAcctLockoutDurationResultHTML = "8.1.7 - <span id=`"CISFailedStatus`">[FAILED]</span> - Account lockout duration is set to less than 30 minutes. Current Value: $PassCheckAcctLockoutDurationResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckAcctLockoutDurationResult = "8.1.7 - [FAILED] - Account lockout duration is Not Configured.`n"
				$Global:Req8PassCheckAcctLockoutDurationResultHTML = "8.1.7 - <span id=`"CISFailedStatus`">[FAILED]</span> - Account lockout duration is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Set the lockout duration to a minimum of 30 minutes or until an administrator enables the user ID.
			$PassCheckResetAcctLockoutCounter = $Global:SecDump | Select-String -SimpleMatch 'ResetLockoutCount' | Out-String
			$PassCheckResetAcctLockoutCounterResult = $PassCheckResetAcctLockoutCounter.split(' ')[2]
			$PassCheckResetAcctLockoutCounterResult = $PassCheckResetAcctLockoutCounterResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckResetAcctLockoutCounter))){
				if($PassCheckResetAcctLockoutCounterResult -ge "30"){
					$Global:Req8PassCheckResetAcctLockoutCounterResult = "8.1.7 - [PASS] - Reset account lockout counter is set to 30 or more minutes. Current Value: $PassCheckResetAcctLockoutCounterResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckResetAcctLockoutCounterResultHTML = "8.1.7 - <span id=`"CISPassStatus`">[PASS]</span> - Reset account lockout counter is set to 30 or more minutes. Current Value: $PassCheckResetAcctLockoutCounterResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckResetAcctLockoutCounterResult = "8.1.7 - [FAILED] - Reset account lockout counter is set to 29 or less minutes. Current Value: $PassCheckResetAcctLockoutCounterResult.`n"
					$Global:Req8PassCheckResetAcctLockoutCounterResultHTML = "8.1.7 - <span id=`"CISFailedStatus`">[FAILED]</span> - Reset account lockout counter is set to 29 or less minutes. Current Value: $PassCheckResetAcctLockoutCounterResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckResetAcctLockoutCounterResult = "8.1.7 - [FAILED] - Reset account lockout counter is Not Configured.`n"
				$Global:Req8PassCheckResetAcctLockoutCounterResultHTML = "8.1.7 - <span id=`"CISFailedStatus`">[FAILED]</span> - Reset account lockout counter is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# If a session has been idle for more than 15 minutes, require the user to re-authenticate to re-activate the terminal or session.
			$PassCheckMachineAFKLimit = $Global:SecDump | Select-String -SimpleMatch 'InactivityTimeoutSecs' | Out-String
			$PassCheckMachineAFKLimitResult = $PassCheckMachineAFKLimit.split(',')[1]
			$PassCheckMachineAFKLimitResult = $PassCheckMachineAFKLimitResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckMachineAFKLimit))){
				if(($PassCheckMachineAFKLimitResult -le "900") -and ($PassCheckMachineAFKLimitResult -ne "0")){
					$Global:Req8PassCheckMachineAFKLimitResult = "8.1.8 - [PASS] - Machine inactivity limit is set between 1 and 900 seconds. The current setting is $PassCheckMachineAFKLimitResult seconds. PCI DSS Compliant.`n"
					$Global:Req8PassCheckMachineAFKLimitResultHTML = "8.1.8 - <span id=`"CISPassStatus`">[PASS]</span> - Machine inactivity limit is set between 1 and 900 seconds. The current setting is $PassCheckMachineAFKLimitResult seconds. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckMachineAFKLimitResult = "8.1.8 - [FAILED] - Machine inactivity limit is set at 0 or greater than 900 seconds. The current setting is $PassCheckMachineAFKLimitResult seconds.`n"
					$Global:Req8PassCheckMachineAFKLimitResultHTML = "8.1.8 - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine inactivity limit is set at 0 or greater than 900 seconds. The current setting is $PassCheckMachineAFKLimitResult seconds.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckMachineAFKLimitResult = "8.1.8 - [FAILED] - Machine inactivity limit is Not Configured.`n"
				$Global:Req8PassCheckMachineAFKLimitResultHTML = "8.1.8 - <span id=`"CISFailedStatus`">[FAILED]</span> - Machine inactivity limit is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Using strong cryptography, render all authentication credentials (such as passwords/phrases) unreadable during transmission and storage on all system components.
			$PassCheckClearTxtPasswordSet = $Global:SecDump | Select-String -SimpleMatch 'PasswordComplexity' | Out-String
			$PassCheckClearTxtPasswordSetResult = $PassCheckClearTxtPasswordSet.split(' ')[2]
			$PassCheckClearTxtPasswordSetResult = $PassCheckClearTxtPasswordSetResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckClearTxtPasswordSet))){
				if($PassCheckClearTxtPasswordSetResult -eq "1"){
					$Global:Req8PassCheckClearTxtPasswordSetResult = "8.2.1 - [PASS] - Storing passwords using reversible encryption is set to Disabled. PCI DSS Compliant.`n"
					$Global:Req8PassCheckClearTxtPasswordSetResultHTML = "8.2.1 - <span id=`"CISPassStatus`">[PASS]</span> - Storing passwords using reversible encryption is set to Disabled. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckClearTxtPasswordSetResult = "8.2.1 - [FAILED] - Storing passwords using reversible encryption is set to Enabled.`n"
					$Global:Req8PassCheckClearTxtPasswordSetResultHTML = "8.2.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - Storing passwords using reversible encryption is set to Enabled.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckClearTxtPasswordSetResult = "8.2.1 - [FAILED] - Storing passwords using reversible encryption is Not Configured.`n"
				$Global:Req8PassCheckClearTxtPasswordSetResultHTML = "8.2.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - Storing passwords using reversible encryption is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Passwords/passphrases must meet the following: Require a minimum length of at least seven characters.
			$PassCheckMinPasswordLength = $Global:SecDump | Select-String -SimpleMatch 'MinimumPasswordLength' | Out-String
			$PassCheckMinPasswordLengthResult = $PassCheckMinPasswordLength.split(' ')[2]
			$PassCheckMinPasswordLengthResult = $PassCheckMinPasswordLengthResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckMinPasswordLength))){
				if($PassCheckMinPasswordLengthResult -ge "7"){
					$Global:Req8PassCheckMinPasswordLengthResult = "8.2.3 - [PASS] - Minimum Password Length is set to 7 or more character(s). Current Value: $PassCheckMinPasswordLengthResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckMinPasswordLengthResultHTML = "8.2.3 - <span id=`"CISPassStatus`">[PASS]</span> - Minimum Password Length is set to 7 or more character(s). Current Value: $PassCheckMinPasswordLengthResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckMinPasswordLengthResult = "8.2.3 - [FAILED] - Minimum Password Length is Not set to 7 or more character(s). Current Value: $PassCheckMinPasswordLengthResult.`n"
					$Global:Req8PassCheckMinPasswordLengthResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Password Length is Not set to 7 or more character(s). Current Value: $PassCheckMinPasswordLengthResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckMinPasswordLengthResult = "8.2.3 - [FAILED] - Minimum Password Length is Not Configured.`n"
				$Global:Req8PassCheckMinPasswordLengthResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Password Length is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Passwords/passphrases must meet the following: Require a minimum length of at least seven characters. Contain both numeric and alphabetic characters. Alternatively, the passwords/ passphrases must have complexity and strength at least equivalent to the parameters specified above.
			$PassCheckPasswordComplexReqs = $Global:SecDump | Select-String -SimpleMatch 'ClearTextPassword' | Out-String
			$PassCheckPasswordComplexReqsResult = $PassCheckPasswordComplexReqs.split(' ')[2]
			$PassCheckPasswordComplexReqsResult = $PassCheckPasswordComplexReqsResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckPasswordComplexReqs))){
				if($PassCheckPasswordComplexReqsResult -eq "0"){
					$Global:Req8PassCheckPasswordComplexReqsResult = "8.2.3 - [PASS] - Password complexity requirements is set to Enabled. PCI DSS Compliant.`n"
					$Global:Req8PassCheckPasswordComplexReqsResultHTML = "8.2.3 - <span id=`"CISPassStatus`">[PASS]</span> - Password complexity requirements is set to Enabled. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckPasswordComplexReqsResult = "8.2.3 - [FAILED] - Password complexity requirements is set to Disabled.`n"
					$Global:Req8PassCheckPasswordComplexReqsResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Password complexity requirements is set to Disabled.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckPasswordComplexReqsResult = "8.2.3 - [FAILED] - Password complexity requirements is Not Configured.`n"
				$Global:Req8PassCheckPasswordComplexReqsResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Password complexity requirements is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Set passwords/passphrases for a minimum of 1 day or more.
			$PassCheckMinPasswordAge = $Global:SecDump | Select-String -SimpleMatch 'MinimumPasswordAge' | Out-String
			$PassCheckMinPasswordAgeResult = $PassCheckMinPasswordAge.split(' ')[2]
			$PassCheckMinPasswordAgeResult = $PassCheckMinPasswordAgeResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckMinPasswordAge))){
				if($PassCheckMinPasswordAgeResult -ge "1"){
					$Global:Req8PassCheckMinPasswordAgeResult = "8.2.3 - [PASS] - Minimum Password Age is set to 1 or more days. Current Value: $PassCheckMinPasswordAgeResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckMinPasswordAgeResultHTML = "8.2.3 - <span id=`"CISPassStatus`">[PASS]</span> - Minimum Password Age is set to 1 or more days. Current Value: $PassCheckMinPasswordAgeResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckMinPasswordAgeResult = "8.2.3 - [FAILED] - Minimum Password Age is Not set to 1 or more days. Current Value: $PassCheckMinPasswordAgeResult.`n"
					$Global:Req8PassCheckMinPasswordAgeResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Password Age is Not set to 1 or more days. Current Value: $PassCheckMinPasswordAgeResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckMinPasswordAgeResult = "8.2.3 - [FAILED] - Minimum Password Age is Not Configured.`n"
				$Global:Req8PassCheckMinPasswordAgeResultHTML = "8.2.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - Minimum Password Age is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Change user passwords/passphrases at least once every 90 days.
			$PassCheckMaxPasswordAge = $Global:SecDump | Select-String -SimpleMatch 'MaximumPasswordAge =' | Out-String
			$PassCheckMaxPasswordAgeResult = $PassCheckMaxPasswordAge.split(' ')[2]
			$PassCheckMaxPasswordAgeResult = $PassCheckMaxPasswordAgeResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckMaxPasswordAge))){
				if(($PassCheckMaxPasswordAgeResult -le "90") -and ($PassCheckMaxPasswordAgeResult -ne "0")){
					$Global:Req8PassCheckMaxPasswordAgeResult = "8.2.4 - [PASS] - Maximum Password Age is Set 90 or fewer days, and not 0. Current Value: $PassCheckMaxPasswordAgeResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckMaxPasswordAgeResultHTML = "8.2.4 - <span id=`"CISPassStatus`">[PASS]</span> - Maximum Password Age is Set 90 or fewer days, and not 0. Current Value: $PassCheckMaxPasswordAgeResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckMaxPasswordAgeResult = "8.2.4 - [FAILED] - Maximum Password Age is Not set to 90 or fewer days, or is set to 0. Current Value: $PassCheckMaxPasswordAgeResult.`n"
					$Global:Req8PassCheckMaxPasswordAgeResultHTML = "8.2.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - Maximum Password Age is Not set to 90 or fewer days, or is set to 0. Current Value: $PassCheckMaxPasswordAgeResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckMaxPasswordAgeResult = "8.2.4 - [FAILED] - Maximum Password Age is Not Configured.`n"
				$Global:Req8PassCheckMaxPasswordAgeResultHTML = "8.2.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - Maximum Password Age is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Change user passwords/passphrases at least once every 90 days.
			$PassCheckPassExpiryWarning = $Global:SecDump | Select-String -SimpleMatch 'PasswordExpiryWarning' | Out-String
			$PassCheckPassExpiryWarningResult = $PassCheckPassExpiryWarning.split(',')[1]
			$PassCheckPassExpiryWarningResult = $PassCheckPassExpiryWarningResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckPassExpiryWarning))){
				if(($PassCheckPassExpiryWarningResult -le 14) -and ($PassCheckPassExpiryWarningResult -ge 5)){
					$Global:Req8PassCheckPassExpiryWarningResult = "8.2.4 - [PASS] - Prompt User to Change Password Before Expiration is set between 5 and 14 Days. It's set to $PassCheckPassExpiryWarningResult Days. PCI DSS Compliant.`n"
					$Global:Req8PassCheckPassExpiryWarningResultHTML = "8.2.4 - <span id=`"CISPassStatus`">[PASS]</span> - Prompt User to Change Password Before Expiration is set between 5 and 14 Days. It's set to $PassCheckPassExpiryWarningResult Days. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckPassExpiryWarningResult = "8.2.4 - [FAILED] - Prompt User to Change Password Before Expiration is Not set between 5 and 14 Days. It's set to $PassCheckPassExpiryWarningResult Days.`n"
					$Global:Req8PassCheckPassExpiryWarningResultHTML = "8.2.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - Prompt User to Change Password Before Expiration is Not set between 5 and 14 Days. It's set to $PassCheckPassExpiryWarningResult Days.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckPassExpiryWarningResult = "8.2.4 - [FAILED] - Prompt User to Change Password Before Expiration is Not Configured.`n"
				$Global:Req8PassCheckPassExpiryWarningResultHTML = "8.2.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - Prompt User to Change Password Before Expiration is Not Configured.`n"
				$PCIDSSFailCounter++
			}

			# Do not allow an individual to submit a new password/passphrase that is the same as any of the last four passwords/passphrases he or she has used.
			$PassCheckPasswordHistory = $Global:SecDump | Select-String -SimpleMatch 'PasswordHistorySize' | Out-String
			$PassCheckPasswordHistoryResult = $PassCheckPasswordHistory.split(' ')[2]
			$PassCheckPasswordHistoryResult = $PassCheckPasswordHistoryResult -as [int]
			if(-not([string]::IsNullOrEmpty($PassCheckPasswordHistory))){
				if($PassCheckPasswordHistoryResult -ge "4"){
					$Global:Req8PassCheckPasswordHistoryResult = "8.2.5 - [PASS] - Password History is Set to 4 Passwords or Higher. Current Value: $PassCheckPasswordHistoryResult. PCI DSS Compliant.`n"
					$Global:Req8PassCheckPasswordHistoryResultHTML = "8.2.5 - <span id=`"CISPassStatus`">[PASS]</span> - Password History is Set to 4 Passwords or Higher. Current Value: $PassCheckPasswordHistoryResult. PCI DSS Compliant.`n"
					$PCIDSSPassCounter++
				}else{
					$Global:Req8PassCheckPasswordHistoryResult = "8.2.5 - [FAILED] - Password History is Not set to 4 Passwords. Current Value: $PassCheckPasswordHistoryResult.`n"
					$Global:Req8PassCheckPasswordHistoryResultHTML = "8.2.5 - <span id=`"CISFailedStatus`">[FAILED]</span> - Password History is Not set to 4 Passwords. Current Value: $PassCheckPasswordHistoryResult.`n"
					$PCIDSSFailCounter++
				}
			}else{
				$Global:Req8PassCheckPasswordHistoryResult = "8.2.5 - [FAILED] - Password History is Not Configured.`n"
				$Global:Req8PassCheckPasswordHistoryResultHTML = "8.2.5 - <span id=`"CISFailedStatus`">[FAILED]</span> - Password History is Not Configured.`n"
				$PCIDSSFailCounter++
			}

		# Data Output
		$PCIDSSTotalCounter = $PCIDSSPassCounter + $PCIDSSFailCounter
		$Global:PCIDSSPassCheckToalResult = "`nPCI DSS Password Policy Check Result:`n" + $PCIDSSPassCounter + " PASS Results.`n" + $PCIDSSFailCounter + " FAILED Results.`nTotal Benchmarks Tested: " + $PCIDSSTotalCounter + "`n"
		$Global:PCIDSSPassCheckToalResultHTML = "<h3>PCI DSS Password Policy Check Result</h3><p>PASS Results:" + $PCIDSSPassCounter + "<br>FAILED Results: " + $PCIDSSFailCounter + "<br>Total Benchmarks Tested: " + $PCIDSSTotalCounter + "</p>"

		# HTML Report
		$Global:Req8PCIDSSPassCheckResultHTML = "<h2>8.2 - Password Policy Check for PCI-DSS</h2><p>" + $Global:Req8PassCheckAcctLockoutThresholdResultHTML + "<br>" + $Global:Req8PassCheckAcctLockoutDurationResultHTML + "<br>" + $Global:Req8PassCheckResetAcctLockoutCounterResultHTML + "<br>" + $Global:Req8PassCheckMachineAFKLimitResultHTML + "<br>" + $Global:Req8PassCheckClearTxtPasswordSetResultHTML + "<br>" + $Global:Req8PassCheckMinPasswordLengthResultHTML + "<br>" + $Global:Req8PassCheckPasswordComplexReqsResultHTML + "<br>" + $Global:Req8PassCheckMinPasswordAgeResultHTML + "<br>" + $Global:Req8PassCheckMaxPasswordAgeResultHTML + "<br>" + $Global:Req8PassCheckPassExpiryWarningResultHTML + "<br>" + $Global:Req8PassCheckPasswordHistoryResultHTML + "</p>"

		# Rich Text Boxes
		if($EverythingToggle -eq $false){
			$Req8Output.AppendText($Global:Req8PassCheckAcctLockoutThresholdResult)
			$Req8Output.AppendText($Global:Req8PassCheckAcctLockoutDurationResult)
			$Req8Output.AppendText($Global:Req8PassCheckResetAcctLockoutCounterResult)
			$Req8Output.AppendText($Global:Req8PassCheckMachineAFKLimitResult)
			$Req8Output.AppendText($Global:Req8PassCheckClearTxtPasswordSetResult)
			$Req8Output.AppendText($Global:Req8PassCheckMinPasswordLengthResult)
			$Req8Output.AppendText($Global:Req8PassCheckPasswordComplexReqsResult)
			$Req8Output.AppendText($Global:Req8PassCheckMinPasswordAgeResult)
			$Req8Output.AppendText($Global:Req8PassCheckMaxPasswordAgeResult)
			$Req8Output.AppendText($Global:Req8PassCheckPassExpiryWarningResult)
			$Req8Output.AppendText($Global:Req8PassCheckPasswordHistoryResult)
			$Req8Output.AppendText($Global:PCIDSSPassCheckToalResult)
		}else{
			$AllOutput.AppendText($Global:Req8PassCheckAcctLockoutThresholdResult)
			$AllOutput.AppendText($Global:Req8PassCheckAcctLockoutDurationResult)
			$AllOutput.AppendText($Global:Req8PassCheckResetAcctLockoutCounterResult)
			$AllOutput.AppendText($Global:Req8PassCheckMachineAFKLimitResult)
			$AllOutput.AppendText($Global:Req8PassCheckClearTxtPasswordSetResult)
			$AllOutput.AppendText($Global:Req8PassCheckMinPasswordLengthResult)
			$AllOutput.AppendText($Global:Req8PassCheckPasswordComplexReqsResult)
			$AllOutput.AppendText($Global:Req8PassCheckMinPasswordAgeResult)
			$AllOutput.AppendText($Global:Req8PassCheckMaxPasswordAgeResult)
			$AllOutput.AppendText($Global:Req8PassCheckPassExpiryWarningResult)
			$AllOutput.AppendText($Global:Req8PassCheckPasswordHistoryResult)
			$AllOutput.AppendText($Global:PCIDSSPassCheckToalResult)
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
			$ADUserListDisabledRTB = $ADUserListDisabled | Format-Table -Autosize | Out-String -Width 1200
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
				$Req8Output.AppendText($LocalAdminListRTB)
			}else{
				$AllOutput.AppendText($LocalAdminListRTB)
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
			$ADUserPasswordLastChangeListRTB = $ADUserPasswordLastChangeList | Format-Table -Autosize | Out-String -Width 1200
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
			$RDPSettings = Get-WmiObject -Class 'Win32_TSGeneralSetting' -Namespace 'root/CIMV2/TerminalServices' | Format-List | Out-String
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

		## RDP Compliance Check Starts ##
		# Write Header
		if($EverythingToggle -eq $false){
		 $Req8Output.AppendText("RDP Compliance Check:`n")
		}else{
			$AllOutput.AppendText("RDP Compliance Check:`n")
		}

		# Define Data Class (Array)
		class RDPInfo {
			[string]$Key
			[string]$ResultMatch
			[string]$PassRTB
			[string]$PassHTML
			[string]$FailRTB
			[string]$FailHTML
			[string]$UndefinedRTB
			[string]$UndefinedHTML
		}

		# Data Array to Process in Loop
		$RDPSettingsArray = @([RDPInfo]@{Key='DisablePasswordSaving';ResultMatch="1";PassRTB="18.9.59.2.2 - [PASS] - 'Do not allow passwords to be saved' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.2.2 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not allow passwords to be saved' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.2.2 - [FAILED] - 'Do not allow passwords to be saved' is set to 'Disabled'.`n";FailHTML="18.9.59.2.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow passwords to be saved' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.2.2 - [FAILED] - 'Do not allow passwords to be saved' is Not Configured.`n";UndefinedHTML="18.9.59.2.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow passwords to be saved' is Not Configured.<br>"}
		[RDPInfo]@{Key='fSingleSessionPerUser';ResultMatch="1";PassRTB="18.9.59.3.2.1 - [PASS] - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.2.1 - <span id=`"CISPassStatus`">[PASS]</span> - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is set to 'Enabled'. CIS Compliant<br>";FailRTB="18.9.59.3.2.1 - [FAILED] - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is set to 'Disabled'.`n";FailHTML="18.9.59.3.2.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.2.1 - [FAILED] - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is Not Configured.`n";UndefinedHTML="18.9.59.3.2.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Restrict Remote Desktop Services users to a single Remote Desktop Services session' is Not Configured.<br>"}
		[RDPInfo]@{Key='fDisableCcm';ResultMatch="1";PassRTB="18.9.59.3.3.1 - [PASS] - 'Do not allow COM port redirection' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.3.1 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not allow COM port redirection' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.3.1 - [FAILED] - 'Do not allow COM port redirection' is set to 'Disabled'.`n";FailHTML="18.9.59.3.3.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow COM port redirection' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.3.1 - [FAILED] - 'Do not allow COM port redirection' is Not Configured.`n";UndefinedHTML="18.9.59.3.3.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow COM port redirection' is Not Configured.<br>"}
		[RDPInfo]@{Key='fDisableCdm';ResultMatch="1";PassRTB="18.9.59.3.3.2 - [PASS] - 'Do not allow drive redirection' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.3.2 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not allow drive redirection' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.3.2 - [FAILED] - 'Do not allow drive redirection' is set to 'Disabled'.`n";FailHTML="18.9.59.3.3.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow drive redirection' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.3.2 - [FAILED] - 'Do not allow drive redirection' is Not Configured.`n";UndefinedHTML="18.9.59.3.3.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow drive redirection' is Not Configured.<br>"}
		[RDPInfo]@{Key='fDisableLPT';ResultMatch="1";PassRTB="18.9.59.3.3.3 - [PASS] - 'Do not allow LPT port redirection' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.3.3 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not allow LPT port redirection' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.3.3 - [FAILED] - 'Do not allow LPT port redirection' is set to 'Disabled'.`n";FailHTML="18.9.59.3.3.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow LPT port redirection' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.3.3 - [FAILED] - 'Do not allow LPT port redirection' is Not Configured.`n";UndefinedHTML="18.9.59.3.3.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow LPT port redirection' is Not Configured.<br>"}
		[RDPInfo]@{Key='fDisablePNPRedir';ResultMatch="1";PassRTB="18.9.59.3.3.4 - [PASS] - 'Do not allow supported Plug and Play device redirection' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.3.4 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not allow supported Plug and Play device redirection' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.3.4 - [FAILED] - 'Do not allow supported Plug and Play device redirection' is set to 'Disabled'.`n";FailHTML="18.9.59.3.3.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow supported Plug and Play device redirection' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.3.4 - [FAILED] - 'Do not allow supported Plug and Play device redirection' is Not Configured.`n";UndefinedHTML="18.9.59.3.3.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not allow supported Plug and Play device redirection' is Not Configured.<br>"}
		[RDPInfo]@{Key='fPromptForPassword';ResultMatch="1";PassRTB="18.9.59.3.9.1 - [PASS] - 'Always prompt for password upon connection' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.9.1 - <span id=`"CISPassStatus`">[PASS]</span> - 'Always prompt for password upon connection' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.9.1 - [FAILED] - 'Always prompt for password upon connection' is set to 'Disabled'.`n";FailHTML="18.9.59.3.9.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Always prompt for password upon connection' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.9.1 - [FAILED] - 'Always prompt for password upon connection' is Not Configured.`n";UndefinedHTML="18.9.59.3.9.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Always prompt for password upon connection' is Not Configured.<br>"}
		[RDPInfo]@{Key='fEncryptRPCTraffic';ResultMatch="1";PassRTB="18.9.59.3.9.2 - [PASS] - 'Require secure RPC communication' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.9.2 - <span id=`"CISPassStatus`">[PASS]</span> - 'Require secure RPC communication' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.9.2 - [FAILED] - 'Require secure RPC communication' is set to 'Disabled'.`n";FailHTML="18.9.59.3.9.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require secure RPC communication' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.9.2 - [FAILED] - 'Require secure RPC communication' is Not Configured.`n";UndefinedHTML="18.9.59.3.9.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require secure RPC communication' is Not Configured.<br>"}
		[RDPInfo]@{Key='SecurityLayer';ResultMatch="2";PassRTB="18.9.59.3.9.3 - [PASS] - 'Require use of specific security layer for remote (RDP) connections' is set to 'Enabled: SSL'. CIS Compliant.`n";PassHTML="18.9.59.3.9.3 - <span id=`"CISPassStatus`">[PASS]</span> - 'Require use of specific security layer for remote (RDP) connections' is set to 'Enabled: SSL'. CIS Compliant.<br>";FailRTB="18.9.59.3.9.3 - [FAILED] - 'Require use of specific security layer for remote (RDP) connections' is Not set to 'Enabled: SSL' or is 'Disabled'.`n";FailHTML="18.9.59.3.9.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require use of specific security layer for remote (RDP) connections' is Not set to 'Enabled: SSL' or is 'Disabled'.<br>";UndefinedRTB="18.9.59.3.9.3 - [FAILED] - 'Require use of specific security layer for remote (RDP) connections' is Not Configured or is Disabled`n";UndefinedHTML="18.9.59.3.9.3 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require use of specific security layer for remote (RDP) connection' is Not Configured or is Disabled.<br>"}
		[RDPInfo]@{Key='UserAuthentication';ResultMatch="1";PassRTB="18.9.59.3.9.4 - [PASS] - 'Require user authentication for remote connections by using Network Level Authentication' is set to 'Enabled'. CIS Compliant.`n";PassHTML="18.9.59.3.9.4 - <span id=`"CISPassStatus`">[PASS]</span> - 'Require user authentication for remote connections by using Network Level Authentication' is set to 'Enabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.9.4 - [FAILED] - 'Require user authentication for remote connections by using Network Level Authentication' is set to 'Disabled'`n";FailHTML="18.9.59.3.9.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require user authentication for remote connections by using Network Level Authentication' is set to 'Disabled'.<br>";UndefinedRTB="18.9.59.3.9.4 - [FAILED] - 'Require user authentication for remote connections by using Network Level Authentication' is Not Configured`n";UndefinedHTML="18.9.59.3.9.4 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Require user authentication for remote connections by using Network Level Authentication' is Not Configured.<br>"}
		[RDPInfo]@{Key='MinEncryptionLevel';ResultMatch="3";PassRTB="18.9.59.3.9.5 - [PASS] - 'Set client connection encryption level' is set to 'Enabled: High Level'. CIS Compliant.`n";PassHTML="18.9.59.3.9.5 - <span id=`"CISPassStatus`">[PASS]</span> - 'Set client connection encryption level' is set to 'Enabled: High Level'. CIS Compliant.<br>";FailRTB="18.9.59.3.9.5 - [FAILED] - 'Set client connection encryption level' is Not set to 'Enabled: High Level' or is 'Disabled'.`n";FailHTML="18.9.59.3.9.5 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set client connection encryption level' is Not set to 'Enabled: High Level' or is 'Disabled'.<br>";UndefinedRTB="18.9.59.3.9.5 - [FAILED] - 'Set client connection encryption level' is Not Configured or is Disabled.`n";UndefinedHTML="18.9.59.3.9.5 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set client connection encryption level' is Not Configured or is Disabled.<br>"}
		[RDPInfo]@{Key='MaxIdleTime';ResultMatch="900000";PassRTB="18.9.59.3.10.1 - [PASS] - 'Set time limit for active but idle Remote Desktop Services sessions' is set to 'Enabled: 15 minutes or less'. CIS Compliant.`n";PassHTML="18.9.59.3.10.1 - <span id=`"CISPassStatus`">[PASS]</span> - 'Set time limit for active but idle Remote Desktop Services sessions' is set to 'Enabled: 15 minutes or less'. CIS Compliant.<br>";FailRTB="18.9.59.3.10.1 - [FAILED] - 'Set time limit for active but idle Remote Desktop Services sessions' is Not set to 'Enabled: 15 minutes or less' or is Set to 'Enabled: Never' or is 'Disabled'.`n";FailHTML="18.9.59.3.10.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set time limit for active but idle Remote Desktop Services sessions' is Not set to 'Enabled: 15 minutes or less' or is Set to 'Enabled: Never' or is 'Disabled'.<br>";UndefinedRTB="18.9.59.3.10.1 - [FAILED] - 'Set time limit for active but idle Remote Desktop Services sessions' is Not Configured or is Disabled.`n";UndefinedHTML="18.9.59.3.10.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set time limit for active but idle Remote Desktop Services sessions' is Not Configured or is Disabled.<br>"}
		[RDPInfo]@{Key='MaxDisconnectionTime';ResultMatch="60000";PassRTB="18.9.59.3.10.2 - [PASS] - 'Set time limit for disconnected sessions' is set to 'Enabled: 1 minute'. CIS Compliant.`n";PassHTML="18.9.59.3.10.2 - <span id=`"CISPassStatus`">[PASS]</span> - 'Set time limit for disconnected sessions' is set to 'Enabled: 1 minute'. CIS Compliant.<br>";FailRTB="18.9.59.3.10.2 - [FAILED] - 'Set time limit for disconnected sessions' is Not set to 'Enabled: 1 minute' or is 'Disabled'.`n";FailHTML="18.9.59.3.10.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set time limit for disconnected sessions' is Not set to 'Enabled: 1 minute' or is 'Disabled'.<br>";UndefinedRTB="18.9.59.3.10.2 - [FAILED] - 'Set time limit for disconnected sessions' is Not Configured or is Disabled.`n";UndefinedHTML="18.9.59.3.10.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Set time limit for disconnected sessions' is Not Configured or is Disabled.<br>"}
		[RDPInfo]@{Key='DeleteTempDirsOnExit';ResultMatch="1";PassRTB="18.9.59.3.11.1 - [PASS] - 'Do not delete temp folders upon exit' is set to 'Disabled'. CIS Compliant.`n";PassHTML="18.9.59.3.11.1 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not delete temp folders upon exit' is set to 'Disabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.11.1 - [FAILED] - 'Do not delete temp folders upon exit' is set to 'Enabled'.`n";FailHTML="18.9.59.3.11.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not delete temp folders upon exit' is set to 'Enabled'.<br>";UndefinedRTB="18.9.59.3.11.1 - [FAILED] - 'Do not delete temp folders upon exit' is Not Configured.`n";UndefinedHTML="18.9.59.3.11.1 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not delete temp folders upon exit' is Not Configured.<br>"}
		[RDPInfo]@{Key='PerSessionTempDir';ResultMatch="1";PassRTB="18.9.59.3.11.2 - [PASS] - 'Do not use temporary folders per session' is set to 'Disabled'. CIS Compliant.`n`n";PassHTML="18.9.59.3.11.2 - <span id=`"CISPassStatus`">[PASS]</span> - 'Do not use temporary folders per session' is set to 'Disabled'. CIS Compliant.<br>";FailRTB="18.9.59.3.11.2 - [FAILED] - 'Do not use temporary folders per session' is set to 'Enabled'.`n`n";FailHTML="18.9.59.3.11.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not use temporary folders per session' is set to 'Enabled'.<br>";UndefinedRTB="18.9.59.3.11.2 - [FAILED] - 'Do not use temporary folders per session' is Not Configured.`n`n";UndefinedHTML="18.9.59.3.11.2 - <span id=`"CISFailedStatus`">[FAILED]</span> - 'Do not use temporary folders per session' is Not Configured.<br>"})

		# Data Gathering - RDP Compliance Check
		# Function to Loop
		Function RDPSettings ($KeyPassThru) {
			# Define RDP String and RDP Key to Match
			$HKLM_Software_RDP_Key = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services'
			$RDPResultOutput = ($HKLM_Software_RDP_Key).$KeyPassThru
			Return $RDPResultOutput
		}

		# Define Total Variables
		$Global:Req8RDPComplianceHTML = "<h3>RDP Compliance Check</h3><p>"
		$Global:Req8RDPComplianceRTB = ""
		# Loop And Gather Data and Output Data
		try{
			foreach($Row in $RDPSettingsArray){
				$RowKeyData = $Row.Key
				$RDPResultFinalOutput = RDPSettings -KeyPassThru $RowKeyData

				# Edge Case for Max Idle Time, Requires Less Than Equal instead of Equals Too
				if($Row.Key -ne "MaxIdleTime"){
					if(-not([string]::IsNullOrEmpty($RDPResultFinalOutput))){
						if($RDPResultFinalOutput -eq $Row.ResultMatch){
							$RDPSettingsResultRTB = $Row.PassRTB
							$RDPSettingsResultHTML = $Row.PassHTML
						}else{
							$RDPSettingsResultRTB = $Row.FailRTB
							$RDPSettingsResultHTML = $Row.FailHTML
						}
					}else{
						$RDPSettingsResultRTB = $Row.UndefinedRTB
						$RDPSettingsResultHTML = $Row.UndefinedHTML
					}
				# Edge Case
				}else{
					if(-not([string]::IsNullOrEmpty($RDPResultFinalOutput))){
						if(($RDPResultFinalOutput -le $Row.ResultMatch) -and ($RDPResultFinalOutput -ne "0")){
							$RDPSettingsResultRTB = $Row.PassRTB
							$RDPSettingsResultHTML = $Row.PassHTML
						}else{
							$RDPSettingsResultRTB = $Row.FailRTB
							$RDPSettingsResultHTML = $Row.FailHTML
						}
					}else{
						$RDPSettingsResultRTB = $Row.UndefinedRTB
						$RDPSettingsResultHTML = $Row.UndefinedHTML
					}
				}
				# Append Results to Totals
				$Global:Req8RDPComplianceRTB += $RDPSettingsResultRTB
				$Global:Req8RDPComplianceHTML += $RDPSettingsResultHTML
			}
		# Edge Case
		}catch{
			# Append Results to Totals
			$Global:Req8RDPComplianceRTB += "An Unexpected Error Has Occurred"
			$Global:Req8RDPComplianceHTML += "An Unexpected Error Has Occurred."
		# Data Output into Console
		}finally{
			$Global:Req8RDPComplianceHTML += "</p>"
			if($EverythingToggle -eq $false){
				$Req8Output.AppendText($Global:Req8RDPComplianceRTB)
			}else{
				$AllOutput.AppendText($Global:Req8RDPComplianceRTB)
			}
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
			}elseif($Req8ScriptList.SelectedItem -eq "8.2 - Password Policy Checker for PCI-DSS"){
				$Req8Output.Clear()
				Req8PasswordChecker
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
				$Req8OutputLabel.Text = "Output: Progressing... 5%"
				$Req8OutputLabel.Refresh()
				Req8GrabCurrentUser
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 10%"
				$Req8OutputLabel.Refresh()
				Req8GrabDomainAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 20%"
				$Req8OutputLabel.Refresh()
				Req8GrabLocalAdmins
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 25%"
				$Req8OutputLabel.Refresh()
				Req8DumpActiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 30%"
				$Req8OutputLabel.Refresh()
				Req8DumpDisabledADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 40%"
				$Req8OutputLabel.Refresh()
				Req8DumpInactiveADUsers
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 50%"
				$Req8OutputLabel.Refresh()
				Req8GrabScreensaverSettings
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 55%"
				$Req8OutputLabel.Refresh()
				Req8DomainPasswordPolicy
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 60%"
				$Req8OutputLabel.Refresh()
				Req8LocalPasswordPolicy
				$Req8Output.AppendText($Global:SectionHeader)
				Req8PasswordChecker
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 70%"
				$Req8OutputLabel.Refresh()
				Req8DumpADUsersPasswordExpiry
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 80%"
				$Req8OutputLabel.Refresh()
				Req8DumpADUserLastPassChange
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output: Progressing... 90%"
				$Req8OutputLabel.Refresh()
				Req8GrabRDPSettings
				$Req8Output.AppendText($Global:SectionHeader)
				$Req8OutputLabel.Text = "Output:"
				$Req8OutputLabel.Refresh()
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
		$Requirement8Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementEightName $ReportComputerName $Global:Req8CurrentUserHTML $Global:Req8LocalAdminListHTML $Global:Req8ADDomainAdminListHTML $Global:Req8ADEnterpriseAdminListHTML $Global:Req8ADUserListAllHTML $Global:Req8ADUserListDisabledHTML $Global:Req8ADUserListInactiveADUsersHTML $Global:Req8ScreensaverSettingsHTML $Global:Req8CurrentDomainPoliciesHTML $Global:Req8LocalPolicyHTML $Global:Req8PCIDSSPassCheckResultHTML $Global:PCIDSSPassCheckToalResultHTML $Global:Req8ADUserPasswordExpiryListHTML $Global:Req8RDPSettingsHTML $Global:Req8RDPComplianceHTML $Global:Req8PowerPlanSettingsHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Eight Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement8ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html"
		$Requirement8Report | Out-File $Requirement8ReportPath
		$Req8Output.AppendText("Requirement Eight Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html")
		$Req8EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Eight Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Eight-Report.html","Requirement Eight Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$Req8ExportReport = {
			$Req8Output.Clear()
			$Req8Output.AppendText("Writing Report for the Following`n`n")
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 5%"
			$Req8OutputLabel.Refresh()
			Req8GrabCurrentUser
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req8OutputLabel.Refresh()
			Req8GrabDomainAdmins
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 20%"
			$Req8OutputLabel.Refresh()
			Req8GrabLocalAdmins
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 25%"
			$Req8OutputLabel.Refresh()
			Req8DumpActiveADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 30%"
			$Req8OutputLabel.Refresh()
			Req8DumpDisabledADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 40%"
			$Req8OutputLabel.Refresh()
			Req8DumpInactiveADUsers
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 50%"
			$Req8OutputLabel.Refresh()
			Req8GrabScreensaverSettings
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 55%"
			$Req8OutputLabel.Refresh()
			Req8DomainPasswordPolicy
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 60%"
			$Req8OutputLabel.Refresh()
			Req8LocalPasswordPolicy
			$Req8Output.AppendText($Global:SectionHeader)
			Req8PasswordChecker
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 70%"
			$Req8OutputLabel.Refresh()
			Req8DumpADUsersPasswordExpiry
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 80%"
			$Req8OutputLabel.Refresh()
			Req8DumpADUserLastPassChange
			$Req8Output.AppendText($Global:SectionHeader)
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 90%"
			$Req8OutputLabel.Refresh()
			Req8GrabRDPSettings
			$Req8OutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$Req8OutputLabel.Refresh()
			Req8ExportReportFunction
			$Req8OutputLabel.Text = "Output:"
			$Req2OutputLabel.Refresh()
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

	# 10.2 - Grab Audit Log Retention Policy
	Function Req10AuditLogsCompliance {
		# Data Gathering Phase
		# 10.2 PCI DSS - Audit System Events
		$AuditSysEvents = $Global:SecDump | Select-String -SimpleMatch 'AuditSystemEvents' | Out-String
		$AuditSysEventsResult = $AuditSysEvents.split(' ')[2]
		$AuditSysEventsResult = $AuditSysEventsResult -as [int]
		if($AuditSysEventsResult -eq "3"){
			$Global:Req10AuditSysEventsResult = "10.2  - [PASS] - Audit System Events is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditSysEventsResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit System Events is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditSysEventsResult -eq "2"){
			$Global:Req10AuditSysEventsResult = "10.2  - [FAILED] - Audit System Events is set to Failure.`n"
			$Global:Req10AuditSysEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit System Events is set to Failure.`n"
		}elseif($AuditSysEventsResult -eq "1"){
			$Global:Req10AuditSysEventsResult = "10.2  - [FAILED] - Audit System Events is set to Success.`n"
			$Global:Req10AuditSysEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit System Events is set to Success.`n"
		}elseif($AuditSysEventsResult -eq "0"){
			$Global:Req10AuditSysEventsResult = "10.2  - [FAILED] - Audit System Events is set to No Auditing.`n"
			$Global:Req10AuditSysEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit System Events is set to No Auditing.`n"
		}else{
			$Global:Req10AuditSysEventsResult = "10.2  - [FAILED] - Audit System Events is Not Defined.`n"
			$Global:Req10AuditSysEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit System Events is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Logon Events
		$AuditLogonEvents = $Global:SecDump | Select-String -SimpleMatch 'AuditLogonEvents' | Out-String
		$AuditLogonEventsResult = $AuditLogonEvents.split(' ')[2]
		$AuditLogonEventsResult = $AuditLogonEventsResult -as [int]
		if($AuditLogonEventsResult -eq "3"){
			$Global:Req10AuditLogonEventsResult = "10.2  - [PASS] - Audit Logon Events is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditLogonEventsResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Logon Events is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditLogonEventsResult -eq "2"){
			$Global:Req10AuditLogonEventsResult = "10.2  - [FAILED] - Audit Logon Events is set to Failure.`n"
			$Global:Req10AuditLogonEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Logon Events is set to Failure.`n"
		}elseif($AuditLogonEventsResult -eq "1"){
			$Global:Req10AuditLogonEventsResult = "10.2  - [FAILED] - Audit Logon Events is set to Success.`n"
			$Global:Req10AuditLogonEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Logon Events is set to Success.`n"
		}elseif($AuditLogonEventsResult -eq "0"){
			$Global:Req10AuditLogonEventsResult = "10.2  - [FAILED] - Audit Logon Events is set to No Auditing.`n"
			$Global:Req10AuditLogonEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Logon Events is set to No Auditing.`n"
		}else{
			$Global:Req10AuditLogonEventsResult = "10.2  - [FAILED] - Audit Logon Events is Not Defined.`n"
			$Global:Req10AuditLogonEventsResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Logon Events is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Object Access
		$AuditObjectAccess = $Global:SecDump | Select-String -SimpleMatch 'AuditObjectAccess' | Out-String
		$AuditObjectAccessResult = $AuditObjectAccess.split(' ')[2]
		$AuditObjectAccessResult = $AuditObjectAccessResult -as [int]
		if($AuditObjectAccessResult -eq "3"){
			$Global:Req10AuditObjectAccessResult = "10.2  - [PASS] - Audit Object Access is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditObjectAccessResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Object Access is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditObjectAccessResult -eq "2"){
			$Global:Req10AuditObjectAccessResult = "10.2  - [FAILED] - Audit Object Access is set to Failure.`n"
			$Global:Req10AuditObjectAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Object Access is set to Failure.`n"
		}elseif($AuditObjectAccessResult -eq "1"){
			$Global:Req10AuditObjectAccessResult = "10.2  - [FAILED] - Audit Object Access is set to Success.`n"
			$Global:Req10AuditObjectAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Object Access is set to Success.`n"
		}elseif($AuditObjectAccessResult -eq "0"){
			$Global:Req10AuditObjectAccessResult = "10.2  - [FAILED] - Audit Object Access is set to No Auditing.`n"
			$Global:Req10AuditObjectAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Object Access is set to No Auditing.`n"
		}else{
			$Global:Req10AuditObjectAccessResult = "10.2  - [FAILED] - Audit Object Access is Not Defined.`n"
			$Global:Req10AuditObjectAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Object Access is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Privilege Use
		$AuditPrivilegeUse = $Global:SecDump | Select-String -SimpleMatch 'AuditPrivilegeUse' | Out-String
		$AuditPrivilegeUseResult = $AuditPrivilegeUse.split(' ')[2]
		$AuditPrivilegeUseResult = $AuditPrivilegeUseResult -as [int]
		if($AuditPrivilegeUseResult -eq "3"){
			$Global:Req10AuditPrivilegeUseResult = "10.2  - [PASS] - Audit Privilege Use is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditPrivilegeUseResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Privilege Use is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditPrivilegeUseResult -eq "2"){
			$Global:Req10AuditPrivilegeUseResult = "10.2  - [FAILED] - Audit Privilege Use is set to Failure.`n"
			$Global:Req10AuditPrivilegeUseResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Privilege Use is set to Failure.`n"
		}elseif($AuditPrivilegeUseResult -eq "1"){
			$Global:Req10AuditPrivilegeUseResult = "10.2  - [FAILED] - Audit Privilege Use is set to Success.`n"
			$Global:Req10AuditPrivilegeUseResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Privilege Use is set to Success.`n"
		}elseif($AuditPrivilegeUseResult -eq "0"){
			$Global:Req10AuditPrivilegeUseResult = "10.2  - [FAILED] - Audit Privilege Use is set to No Auditing.`n"
			$Global:Req10AuditPrivilegeUseResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Privilege Use is set to No Auditing.`n"
		}else{
			$Global:Req10AuditPrivilegeUseResult = "10.2  - [FAILED] - Audit Privilege Use is Not Defined.`n"
			$Global:Req10AuditPrivilegeUseResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Privilege Use is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Policy Change
		$AuditPolicyChange = $Global:SecDump | Select-String -SimpleMatch 'AuditPolicyChange' | Out-String
		$AuditPolicyChangeResult = $AuditPolicyChange.split(' ')[2]
		$AuditPolicyChangeResult = $AuditPolicyChangeResult -as [int]
		if($AuditPolicyChangeResult -eq "3"){
			$Global:Req10AuditPolicyChangeResult = "10.2  - [PASS] - Audit Policy Change is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditPolicyChangeResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Policy Change is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditPolicyChangeResult -eq "2"){
			$Global:Req10AuditPolicyChangeResult = "10.2  - [FAILED] - Audit Policy Change is set to Failure.`n"
			$Global:Req10AuditPolicyChangeResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Policy Change is set to Failure.`n"
		}elseif($AuditPolicyChangeResult -eq "1"){
			$Global:Req10AuditPolicyChangeResult = "10.2  - [FAILED] - Audit Policy Change is set to Success.`n"
			$Global:Req10AuditPolicyChangeResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Policy Change is set to Success.`n"
		}elseif($AuditPolicyChangeResult -eq "0"){
			$Global:Req10AuditPolicyChangeResult = "10.2  - [FAILED] - Audit Policy Change is set to No Auditing.`n"
			$Global:Req10AuditPolicyChangeResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Policy Change is set to No Auditing.`n"
		}else{
			$Global:Req10AuditPolicyChangeResult = "10.2  - [FAILED] - Audit Policy Change is Not Defined.`n"
			$Global:Req10AuditPolicyChangeResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Policy Change is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Account Management
		$AuditAccountManage = $Global:SecDump | Select-String -SimpleMatch 'AuditAccountManage' | Out-String
		$AuditAccountManageResult = $AuditAccountManage.split(' ')[2]
		$AuditAccountManageResult = $AuditAccountManageResult -as [int]
		if($AuditAccountManageResult -eq "3"){
			$Global:Req10AuditAccountManageResult = "10.2  - [PASS] - Audit Account Management is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditAccountManageResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Account Management is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditAccountManageResult -eq "2"){
			$Global:Req10AuditAccountManageResult = "10.2  - [FAILED] - Audit Account Management is set to Failure.`n"
			$Global:Req10AuditAccountManageResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Management is set to Failure.`n"
		}elseif($AuditAccountManageResult -eq "1"){
			$Global:Req10AuditAccountManageResult = "10.2  - [FAILED] - Audit Account Management is set to Success.`n"
			$Global:Req10AuditAccountManageResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Management is set to Success.`n"
		}elseif($AuditAccountManageResult -eq "0"){
			$Global:Req10AuditAccountManageResult = "10.2  - [FAILED] - Audit Account Management is set to No Auditing.`n"
			$Global:Req10AuditAccountManageResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Management is set to No Auditing.`n"
		}else{
			$Global:Req10AuditAccountManageResult = "10.2  - [FAILED] - Audit Account Management is Not Defined.`n"
			$Global:Req10AuditAccountManageResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Management is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Process Tracking
		$AuditProcessTracking = $Global:SecDump | Select-String -SimpleMatch 'AuditProcessTracking' | Out-String
		$AuditProcessTrackingResult = $AuditProcessTracking.split(' ')[2]
		$AuditProcessTrackingResult = $AuditProcessTrackingResult -as [int]
		if($AuditProcessTrackingResult -eq "3"){
			$Global:Req10AuditProcessTrackingResult = "10.2  - [PASS] - Audit Process Tracking is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditProcessTrackingResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Process Tracking is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditProcessTrackingResult -eq "2"){
			$Global:Req10AuditProcessTrackingResult = "10.2  - [FAILED] - Audit Process Tracking is set to Failure.`n"
			$Global:Req10AuditProcessTrackingResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Process Tracking is set to Failure.`n"
		}elseif($AuditProcessTrackingResult -eq "1"){
			$Global:Req10AuditProcessTrackingResult = "10.2  - [FAILED] - Audit Process Tracking is set to Success.`n"
			$Global:Req10AuditProcessTrackingResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Process Tracking is set to Success.`n"
		}elseif($AuditProcessTrackingResult -eq "0"){
			$Global:Req10AuditProcessTrackingResult = "10.2  - [FAILED] - Audit Process Tracking is set to No Auditing.`n"
			$Global:Req10AuditProcessTrackingResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Process Tracking is set to No Auditing.`n"
		}else{
			$Global:Req10AuditProcessTrackingResult = "10.2  - [FAILED] - Audit Process Tracking is Not Defined.`n"
			$Global:Req10AuditProcessTrackingResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Process Tracking is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Directory Services Access
		$AuditDSAccess = $Global:SecDump | Select-String -SimpleMatch 'AuditDSAccess' | Out-String
		$AuditDSAccessResult = $AuditDSAccess.split(' ')[2]
		$AuditDSAccessResult = $AuditDSAccessResult -as [int]
		if($AuditDSAccessResult -eq "3"){
			$Global:Req10AuditDSAccessResult = "10.2  - [PASS] - Audit Directory Services Access is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditDSAccessResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Directory Services Access is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditDSAccessResult -eq "2"){
			$Global:Req10AuditDSAccessResult = "10.2  - [FAILED] - Audit Directory Services Access is set to Failure.`n"
			$Global:Req10AuditDSAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Directory Services Access is set to Failure.`n"
		}elseif($AuditDSAccessResult -eq "1"){
			$Global:Req10AuditDSAccessResult = "10.2  - [FAILED] - Audit Directory Services Access is set to Success.`n"
			$Global:Req10AuditDSAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Directory Services Access is set to Success.`n"
		}elseif($AuditDSAccessResult -eq "0"){
			$Global:Req10AuditDSAccessResult = "10.2  - [FAILED] - Audit Directory Services Access is set to No Auditing.`n"
			$Global:Req10AuditDSAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Directory Services Access is set to No Auditing.`n"
		}else{
			$Global:Req10AuditDSAccessResult = "10.2  - [FAILED] - Audit Directory Services Access is Not Defined.`n"
			$Global:Req10AuditDSAccessResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Directory Services Access is Not Defined.`n"
		}

		# 10.2 PCI DSS - Audit Account Logon Events
		$AuditAccountLogon = $Global:SecDump | Select-String -SimpleMatch 'AuditAccountLogon' | Out-String
		$AuditAccountLogonResult = $AuditAccountLogon.split(' ')[2]
		$AuditAccountLogonResult = $AuditAccountLogonResult -as [int]
		if($AuditAccountLogonResult -eq "3"){
			$Global:Req10AuditAccountLogonResult = "10.2  - [PASS] - Audit Account Logon Events is set to Success and Failure. PCI DSS Compliant.`n"
			$Global:Req10AuditAccountLogonResultHTML = "10.2  - <span id=`"CISPassStatus`">[PASS]</span> - Audit Account Logon Events is set to Success and Failure. PCI DSS Compliant.`n"
		}elseif($AuditAccountLogonResult -eq "2"){
			$Global:Req10AuditAccountLogonResult = "10.2  - [FAILED] - Audit Account Logon Events is set to Failure.`n"
			$Global:Req10AuditAccountLogonResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Logon Events is set to Failure.`n"
		}elseif($AuditAccountLogonResult -eq "1"){
			$Global:Req10AuditAccountLogonResult = "10.2  - [FAILED] - Audit Account Logon Events is set to Success.`n"
			$Global:Req10AuditAccountLogonResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Logon Events is set to Success.`n"
		}elseif($AuditAccountLogonResult -eq "0"){
			$Global:Req10AuditAccountLogonResult = "10.2  - [FAILED] - Audit Account Logon Events is set to No Auditing.`n"
			$Global:Req10AuditAccountLogonResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Logon Events is set to No Auditing.`n"
		}else{
			$Global:Req10AuditAccountLogonResult = "10.2  - [FAILED] - Audit Account Logon Events is Not Defined.`n"
			$Global:Req10AuditAccountLogonResultHTML = "10.2  - <span id=`"CISFailedStatus`">[FAILED]</span> - Audit Account Logon Events is Not Defined.`n"
		}

		# Data Output
		# HTML Report
		$Global:Req10PCIPSSComplianceResultHTML = "<h2>10.2 - Grab Audit Log Retention Policy</h2><p>" + $Global:Req10AuditSysEventsResultHTML + "<br>" + $Global:Req10AuditLogonEventsResultHTML + "<br>" + $Global:Req10AuditObjectAccessResultHTML + "<br>" + $Global:Req10AuditPrivilegeUseResultHTML + "<br>" + $Global:Req10AuditPolicyChangeResultHTML + "<br>" + $Global:Req10AuditAccountManageResultHTML + "<br>" + $Global:Req10AuditProcessTrackingResultHTML + "<br>" + $Global:Req10AuditDSAccessResultHTML + "<br>" + $Global:Req10AuditAccountLogonResultHTML + "</p>"

		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.2 - Grab Audit Log Retention Policy:`n`n")
			$Req10Output.AppendText($Global:Req10AuditSysEventsResult)
			$Req10Output.AppendText($Global:Req10AuditLogonEventsResult)
			$Req10Output.AppendText($Global:Req10AuditObjectAccessResult)
			$Req10Output.AppendText($Global:Req10AuditPrivilegeUseResult)
			$Req10Output.AppendText($Global:Req10AuditPolicyChangeResult)
			$Req10Output.AppendText($Global:Req10AuditAccountManageResult)
			$Req10Output.AppendText($Global:Req10AuditProcessTrackingResult)
			$Req10Output.AppendText($Global:Req10AuditDSAccessResult)
			$Req10Output.AppendText($Global:Req10AuditAccountLogonResult)
		}else{
			$AllOutput.AppendText("10.2 - Grab Audit Log Retention Policy:`n`n")
			$AllOutput.AppendText($Global:Req10AuditSysEventsResult)
			$AllOutput.AppendText($Global:Req10AuditLogonEventsResult)
			$AllOutput.AppendText($Global:Req10AuditObjectAccessResult)
			$AllOutput.AppendText($Global:Req10AuditPrivilegeUseResult)
			$AllOutput.AppendText($Global:Req10AuditPolicyChangeResult)
			$AllOutput.AppendText($Global:Req10AuditAccountManageResult)
			$AllOutput.AppendText($Global:Req10AuditProcessTrackingResult)
			$AllOutput.AppendText($Global:Req10AuditDSAccessResult)
			$AllOutput.AppendText($Global:Req10AuditAccountLogonResult)
		}
	}

	# 10.2 - Grab Invalid Login Attempts
	Function Req10InvalidLoginsAttempts {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.2 - Grab Invalid Login Attempts.`n`n")
		}else{
			$AllOutput.AppendText("10.2 - Grab Invalid Login Attempts.`n`n")
		}
		# Create Array
		$AccountLoginResultTable = @()
		# Data Gathering
		try{
			$AccountLoginFailEvents = Get-WinEvent -FilterHashtable @{LogName='Security';ID='4625'} -ErrorAction Stop
			# Loop HashTable
			$AccountFailLoop_index = 0
			foreach ($User in $AccountLoginFailEvents){
				$AccountLoginTime = $AccountLoginFailEvents[$AccountFailLoop_index].TimeCreated
				$AccountLoginTargetAccount = $AccountLoginFailEvents[$AccountFailLoop_index].Properties.Value[5]
				$AccountLoginTargetDomain = $AccountLoginFailEvents[$AccountFailLoop_index].Properties.Value[6]
				$AccountLoginWorkstationName = $AccountLoginFailEvents[$AccountFailLoop_index].Properties.Value[13]
				$AccountLoginNetworkAddress = $AccountLoginFailEvents[$AccountFailLoop_index].Properties.Value[19]
				$AccountFailLoop_index++
				$AccountLoginResultTable += @{'Login Time'=$AccountLoginTime;'Target Account'=$AccountLoginTargetAccount;'Target Domain'=$AccountLoginTargetDomain;'Origin Computer'=$AccountLoginWorkstationName;'Origin IP Address'=$AccountLoginNetworkAddress}
			}
			# Convert Table
			$AccountCovertedTable = $AccountLoginResultTable | ForEach {[PSCustomObject]$_}
			$AccountCovertedTable | Sort-Object 'Account Login Time'
			$AccountCovertedTableRTB = $AccountCovertedTable | Select-Object 'Login Time','Target Account','Target Domain','Origin Computer','Origin IP Address' | Format-Table -Autosize | Out-String
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText($AccountCovertedTableRTB + "Total Invaild Login Attempts: " + $AccountFailLoop_index)
			}else{
				$AllOutput.AppendText($AccountCovertedTableRTB + "Total Invaild Login Attempts: " + $AccountFailLoop_index)
			}
			# HTML Report
			$Global:Req10UserLoginFailureResult = $AccountCovertedTable | ConvertTo-Html -As Table -Fragment -Property 'Login Time','Target Account','Target Domain','Origin Workstation','Origin IP Address' -PreContent "<h2>10.2 - Grab Invalid Login Attempts</h2>" -PostContent "<p>Total Invaild Login Attempts: $AccountFailLoop_index</p>"
		# Edge Case
		}catch{
			# HTML Report
			$Global:Req10UserLoginFailureResult = "<h2>10.2 - Grab Invalid Login Attempts</h2><p>Unable to Grab Invalid Login Attempts, Configuration is not in accordance with PCI-DSS.</p>"
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("Unable to Grab Invalid Login Attempts, Configuration is not in accordance with PCI-DSS.")
			}else{
				$AllOutput.AppendText("Unable to Grab Invalid Login Attempts, Configuration is not in accordance with PCI-DSS.")
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
				if($Req10Counter -eq 5){
					break
				# If counter is not reached do query below in else statement
				}else{
					# Test Connection Before Checking for NTP Settings
					try{
						Test-Connection $RandomComputer -Count 1 -ErrorAction Stop
						# Successful Ping, Check NTP Settings
						try{
							$Req10NTPSettingsTesting = w32tm /query /status /computer:$RandomComputer | Format-Table -Autosize | Out-String -Width 1200
							# Increase Counter
							$Req10Counter++
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
					}catch{
						# For Debugging
						#Write-Host $Req10Counter
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
			$ADEnterpriseAdminListRTB = $ADEnterpriseAdminList | Format-Table -Autosize | Out-String -Width 1200
			$Global:Req10ADDomainAdminListHTML = $ADDomainAdminList | ConvertTo-Html -As Table -Property Name, Enabled -Fragment -PreContent "<h2>10.5 - Check Audit Log Permissions</h2><p>Listed below are the Domain & Enterprise Administrators. Check GPO Dump for more Information.</p><h3>Domain Administrators</h3>"
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
			$Global:Req10ADDomainAdminListHTML = "<h2>10.5 - Check Audit Log Permissions</h2><h3>Domain Administrators</h3><p>Unable to contact Active Directory, Ensure the script is run on a DC.</p>"
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

	# 10.7 - Grab Audit Retention Log Configuration
	Function Req10PastAuditLogs {
		# Write Header
		if($EverythingToggle -eq $false){
			$Req10Output.AppendText("10.7 - Grabbing Audit Retention Log Configuration`n")
		}else{
			$AllOutput.AppendText("10.7 - Grabbing Audit Retention Log Configuration`n")
		}
		# Data Gathering
		$AuditLogsBegin = (Get-Date).AddDays(-365)
		$AuditLogsEnd = (Get-Date).AddDays(-364)
		try{
			$AuditLogs = Get-EventLog -LogName Security -Source "*auditing*" -After $AuditLogsBegin -Before $AuditLogsEnd -Newest 1 | Format-List | Out-String
			if(-not([string]::IsNullOrEmpty($AuditLogs))){
				$AuditLogsResult = "Audit Logs from 1 Year Ago Found, Retention Configuration is in accordance with PCI-DSS.`n`n"
			}else{
				$AuditLogsResult = "Audit Logs from 1 Year Ago Not Found, Retention Configuration is not in accordance with PCI-DSS.`n`n"
			}
			# Data Output
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText($AuditLogsResult + $AuditLogs)
			}else{
				$AllOutput.AppendText($AuditLogsResult + $AuditLogs)
			}
			# HTML Report
			$Global:Req10AllAuditLogs = "<h2>10.7 - Grabbing Audit Retention Log Configuration</h2><p>$AuditLogsResult</p><br><pre>" + $AuditLogs + "</pre>"
		# Edge Case
		}catch{
			$Global:Req10AllAuditLogs = "<h2>10.7 - Grabbing Audit Retention Log Configuration</h2><p>An Error Has Occurred, No Audit Retention Log Configuration Found.</p>"
			if($EverythingToggle -eq $false){
				$Req10Output.AppendText("An Error Has Occurred, No Audit Retention Log Configuration Found.")
			}else{
				$AllOutput.AppendText("An Error Has Occurred, No Audit Retention Log Configuration Found.")
			}
		}
	}

	#onClick event handler
	$Req10ScriptList_ListUpdate = {
		if($Req10ScriptList.SelectedItem -eq "10.2 - Dump of Audit Category Settings"){
			$Req10Output.Clear()
			Req10AuditSettings
		}elseif($Req10ScriptList.SelectedItem -eq "10.2 - Grab Audit Log Retention Policy"){
			$Req10Output.Clear()
			Req10AuditLogsCompliance
		}elseif($Req10ScriptList.SelectedItem -eq "10.2 - Grab Invalid Login Attempts"){
			$Req10Output.Clear()
			Req10InvalidLoginsAttempts 
		}elseif($Req10ScriptList.SelectedItem -eq "10.4 - Grab NTP Settings"){
			$Req10Output.Clear()
			Req10NTPSettings
		}elseif($Req10ScriptList.SelectedItem -eq "10.4 - Check NTP Settings on Multiple Devices"){
			$Req10Output.Clear()
			Req10NTPSettingsMultipleDevices
		}elseif($Req10ScriptList.SelectedItem -eq "10.5 - Check Audit Log Permissions"){
			$Req10Output.Clear()
			Req10AuditLogPrems
		}elseif($Req10ScriptList.SelectedItem -eq "10.7 - Grab Audit Retention Log Configuration"){
			$Req10Output.Clear()
			Req10PastAuditLogs
		}elseif($Req10ScriptList.SelectedItem -eq "Everything in Requirement Ten"){
			$Req10Output.Clear()
			$Req10Output.AppendText("Everything in Requirement Ten`n")
			$Req10OutputLabel.Text = "Output: Progressing... 10%"
			$Req10OutputLabel.Refresh()
			Req10AuditSettings
			$Req10Output.AppendText($Global:SectionHeader)
			Req10AuditLogsCompliance
			$Req10Output.AppendText($Global:SectionHeader)
			Req10InvalidLoginsAttempts
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Progressing... 20%"
			$Req10OutputLabel.Refresh()
			Req10NTPSettings
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Checking NTP Settings on Multiple Devices, This may take a while. Progressing... 40%"
			$Req10OutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Progressing... 70%"
			$Req10OutputLabel.Refresh()
			Req10AuditLogPrems
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Progressing... 90%"
			$Req10OutputLabel.Refresh()
			Req10PastAuditLogs
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output:"
			$Req10OutputLabel.Refresh()
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
		$Requirement10Report = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportRequirementTenName $ReportComputerName $Global:Req10AuditListHTML $Global:Req10PCIPSSComplianceResultHTML $Global:Req10UserLoginFailureResult $Global:Req10NTPSettings $Global:Req10NTPSettingsAllDevices $Global:Req10ADDomainAdminListHTML $Global:Req10ADEnterpriseAdminListHTML $Global:Req10AllAuditLogs $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Ten Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$Requirement10ReportPath = $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Report.html"
		$Requirement10Report | Out-File $Requirement10ReportPath
		# Write Output
		$Req10Output.AppendText("Requirement Ten Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Requirement-Ten-Report.html")
		$Req10EndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Requirement Ten Report Exported to: " + $Requirement10ReportPath,"Requirement Ten Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$Req10ExportReport = {
			$Req10Output.Clear()
			$Req10Output.AppendText("Writing Report for the Following`n`n")
			$Req10OutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$Req10OutputLabel.Refresh()
			Req10AuditSettings
			$Req10Output.AppendText($Global:SectionHeader)
			Req10AuditLogsCompliance
			$Req10Output.AppendText($Global:SectionHeader)
			Req10InvalidLoginsAttempts
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Data Exporting in Progress... 20%"
			$Req10OutputLabel.Refresh()
			Req10NTPSettings
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Checking NTP Settings on Multiple Devices, This may take a while. Data Export in Progressing... 40%"
			$Req10OutputLabel.Refresh()
			Req10NTPSettingsMultipleDevices
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Data Exporting in Progress... 70%"
			$Req10OutputLabel.Refresh()
			Req10AuditLogPrems
			$Req10Output.AppendText($Global:SectionHeader)
			$Req10OutputLabel.Text = "Output: Data Export in Progressing... 90%"
			$Req10OutputLabel.Refresh()
			Req10PastAuditLogs
			$Req10OutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$Req10OutputLabel.Refresh()
			Req10ExportReportFunction
			$Req10OutputLabel.Text = "Output:"
			$Req10OutputLabel.Refresh()
	}

# Diagnostics Tab
	# Grab System Information
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
			$Global:DiagSystemInfoDataHTML = "<h2>Grab System Information</h2><p>Unable to Grab System Information</p>"
			if($EverythingToggle -eq $false){
				$DiagOutput.AppendText("Unable to Grab System Information`n")
			}else{
				$AllOutput.AppendText("Unable to Grab System Information`n")
			}
		}
	}

	# Grab Installed Software Patches
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

	# Grab IP Config
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

	# Check TCP Connectivity
	Function DiagTCPConnectivity {
		# Write Header
		if($EverythingToggle -eq $false){
			$DiagOutput.AppendText("Check TCP Connectivity`nThis may take A While.`n`n")
		}else{
			$AllOutput.AppendText("Check TCP Connectivity`nThis may take A While.`n`n")
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

	# Dedicated GPO Dump
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
			$DiagOutputLabel.Text = "Output: Progressing... 10%"
			$DiagOutputLabel.Refresh()
			DiagSysInfo
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Progressing... 30%"
			$DiagOutputLabel.Refresh()
			DiagInstalledUpdates
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Progressing... 50%"
			$DiagOutputLabel.Refresh()
			DiagIPConfig
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Progressing... 70%"
			$DiagOutputLabel.Refresh()
			DiagTCPConnectivity
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Progressing... 90%"
			$DiagOutputLabel.Refresh()
			DiagGPODump
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output:"
			$DiagOutputLabel.Refresh()
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
		$DiagReport = ConvertTo-HTML -Body "$GlobalBackToTop $ScrollTopScript $Global:ReportDiagRequirementName $ReportComputerName $Global:DiagSystemInfoDataHTML $Global:DiagInstalledUpdatesDataHTML $Global:DiagIPConfigHTML $Global:DiagPingTestHTML $Global:DiagTraceRouteHTML $Global:GPODumpHTML" -Head $CSSHeader -Title "PCI DSS Requirement Ten Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p><p>Report Generated Using Anordium Audits Version $Global:ProgramVersionCode.<br>$CreditsForHTML</p>"
		$DiagReportPath = $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html"
		$DiagReport | Out-File $DiagReportPath
		$DiagOutput.AppendText("`nDiagnostics Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html")
		$DiagEndOfScriptMsg = [System.Windows.Forms.MessageBox]::Show("Diagnostics Report Exported to: " + $Global:ExportPathLocation + "\PCI-DSS-Diagnostics-Report.html","Diagnostics Report Exported Successfully","OK","Information")
	}
	# onClick Event Handler to Gather Data for Report
	$DiagExportReport = {
			$DiagOutput.Clear()
			$DiagOutput.AppendText("Writing Report for the Following`n`n")
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 10%"
			$DiagOutputLabel.Refresh()
			DiagSysInfo
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 30%"
			$DiagOutputLabel.Refresh()
			DiagInstalledUpdates
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 50%"
			$DiagOutputLabel.Refresh()
			DiagIPConfig
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 70%"
			$DiagOutputLabel.Refresh()
			DiagTCPConnectivity
			$DiagOutput.AppendText($Global:SectionHeader)
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 90%"
			$DiagOutputLabel.Refresh()
			DiagGPODump
			$DiagOutputLabel.Text = "Output: Data Exporting in Progress... 99%"
			$DiagOutputLabel.Refresh()
			DiagExportReportFunction
			$DiagOutputLabel.Text = "Output:"
			$DiagOutputLabel.Refresh()
	}

#Join Path for Resources
$resources = . (Join-Path $PSScriptRoot 'Resources.ps1')

#Join Path for Designers
. (Join-Path $PSScriptRoot 'MainForm.designer.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.designer.ps1')

#Join Path for Forms
. (Join-Path $PSScriptRoot 'MainForm.ps1')
. (Join-Path $PSScriptRoot 'AuxiliaryForm.ps1')