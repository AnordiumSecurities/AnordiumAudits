[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$AuxiliaryForm = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.TabPage]$AllTab = $null
[System.Windows.Forms.TabPage]$ReqTab2 = $null
[System.Windows.Forms.Button]$Req2Refresh = $null
[System.Windows.Forms.Button]$Req2Export = $null
[System.Windows.Forms.RichTextBox]$Req2Output = $null
[System.Windows.Forms.TabPage]$ReqTab4 = $null
[System.Windows.Forms.TabPage]$ReqTab5 = $null
[System.Windows.Forms.TabPage]$ReqTab7 = $null
[System.Windows.Forms.TabPage]$ReqTab8 = $null
[System.Windows.Forms.TabPage]$ReqTab10 = $null
[System.Windows.Forms.ListBox]$Req2ScriptList = $null
[System.Windows.Forms.TabControl]$MainTabControl = $null
[System.Windows.Forms.Button]$AllExport = $null
[System.Windows.Forms.Button]$AllRefresh = $null
[System.Windows.Forms.ListBox]$AllScriptList = $null
[System.Windows.Forms.RichTextBox]$AllOutput = $null
[System.Windows.Forms.Button]$Req4Export = $null
[System.Windows.Forms.Button]$Req4Refresh = $null
[System.Windows.Forms.ListBox]$Req4ScriptList = $null
[System.Windows.Forms.RichTextBox]$Req4Output = $null
[System.Windows.Forms.Button]$Req5Export = $null
[System.Windows.Forms.Button]$Req5Refresh = $null
[System.Windows.Forms.ListBox]$Req5ScriptList = $null
[System.Windows.Forms.RichTextBox]$Req5Output = $null
[System.Windows.Forms.Button]$Req7Export = $null
[System.Windows.Forms.Button]$Req7Refresh = $null
[System.Windows.Forms.ListBox]$Req7ScriptList = $null
[System.Windows.Forms.RichTextBox]$Req7Output = $null
[System.Windows.Forms.Button]$Req8Export = $null
[System.Windows.Forms.Button]$Req8Refresh = $null
[System.Windows.Forms.ListBox]$Req8ScriptList = $null
[System.Windows.Forms.RichTextBox]$Req8Output = $null
[System.Windows.Forms.Button]$Req10Export = $null
[System.Windows.Forms.Button]$Req10Refresh = $null
[System.Windows.Forms.ListBox]$Req10ScriptList = $null
[System.Windows.Forms.RichTextBox]$Req10Output = $null
[System.Windows.Forms.Button]$AllBack = $null
[System.Windows.Forms.Button]$Req2Back = $null
[System.Windows.Forms.Button]$Req4Back = $null
[System.Windows.Forms.Button]$Req5Back = $null
[System.Windows.Forms.Button]$Req7Back = $null
[System.Windows.Forms.Button]$Req8Back = $null
[System.Windows.Forms.Button]$Req10Back = $null
[System.Windows.Forms.FolderBrowserDialog]$Req7FolderBrowserDialog = $null
[System.Windows.Forms.Button]$DiagBack = $null
[System.Windows.Forms.Button]$DiagExport = $null
[System.Windows.Forms.Button]$DiagRefresh = $null
[System.Windows.Forms.ListBox]$DiagScriptList = $null
[System.Windows.Forms.TabPage]$DiagTab = $null
[System.Windows.Forms.Label]$AllScriptOutputLabel = $null
[System.Windows.Forms.Label]$AllScriptListLabel = $null
[System.Windows.Forms.Label]$Req2OutputLabel = $null
[System.Windows.Forms.Label]$Req2ListLabel = $null
[System.Windows.Forms.Label]$Req4OutputLabel = $null
[System.Windows.Forms.Label]$Req4ListLabel = $null
[System.Windows.Forms.Label]$Req5OutputLabel = $null
[System.Windows.Forms.Label]$Req5ListLabel = $null
[System.Windows.Forms.Label]$Req7OutputLabel = $null
[System.Windows.Forms.Label]$Req7ListLabel = $null
[System.Windows.Forms.Label]$Req8ListLabel = $null
[System.Windows.Forms.Label]$Req8OutputLabel = $null
[System.Windows.Forms.Label]$Req10OutputLabel = $null
[System.Windows.Forms.Label]$Req10ListLabel = $null
[System.Windows.Forms.Label]$DiagOutputLabel = $null
[System.Windows.Forms.Label]$DiagListLabel = $null
[System.Windows.Forms.RichTextBox]$DiagOutput = $null
function InitializeComponent
{
$MainTabControl = (New-Object -TypeName System.Windows.Forms.TabControl)
$AllTab = (New-Object -TypeName System.Windows.Forms.TabPage)
$AllScriptOutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$AllScriptListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$AllBack = (New-Object -TypeName System.Windows.Forms.Button)
$AllExport = (New-Object -TypeName System.Windows.Forms.Button)
$AllRefresh = (New-Object -TypeName System.Windows.Forms.Button)
$AllScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$AllOutput = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab2 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req2OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req2ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req2Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req2ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req2Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req2Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req2Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab4 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req4OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req4ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req4Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req4Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req4Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req4ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req4Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab5 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req5OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req5ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req5Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req5Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req5Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req5ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req5Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab7 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req7OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req7ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req7Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req7Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req7Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req7ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req7Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab8 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req8OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req8ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req8Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req8Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req8Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req8ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req8Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab10 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req10OutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req10ListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$Req10Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req10Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req10Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req10ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req10Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$DiagTab = (New-Object -TypeName System.Windows.Forms.TabPage)
$DiagOutputLabel = (New-Object -TypeName System.Windows.Forms.Label)
$DiagListLabel = (New-Object -TypeName System.Windows.Forms.Label)
$DiagBack = (New-Object -TypeName System.Windows.Forms.Button)
$DiagExport = (New-Object -TypeName System.Windows.Forms.Button)
$DiagRefresh = (New-Object -TypeName System.Windows.Forms.Button)
$DiagScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$DiagOutput = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$Req7FolderBrowserDialog = (New-Object -TypeName System.Windows.Forms.FolderBrowserDialog)
$MainTabControl.SuspendLayout()
$AllTab.SuspendLayout()
$ReqTab2.SuspendLayout()
$ReqTab4.SuspendLayout()
$ReqTab5.SuspendLayout()
$ReqTab7.SuspendLayout()
$ReqTab8.SuspendLayout()
$ReqTab10.SuspendLayout()
$DiagTab.SuspendLayout()
$AuxiliaryForm.SuspendLayout()
#
#MainTabControl
#
$MainTabControl.Controls.Add($AllTab)
$MainTabControl.Controls.Add($ReqTab2)
$MainTabControl.Controls.Add($ReqTab4)
$MainTabControl.Controls.Add($ReqTab5)
$MainTabControl.Controls.Add($ReqTab7)
$MainTabControl.Controls.Add($ReqTab8)
$MainTabControl.Controls.Add($ReqTab10)
$MainTabControl.Controls.Add($DiagTab)
$MainTabControl.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
$MainTabControl.Name = [System.String]'MainTabControl'
$MainTabControl.SelectedIndex = [System.Int32]0
$MainTabControl.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1585,[System.Int32]862))
$MainTabControl.TabIndex = [System.Int32]0
$MainTabControl.add_Selected($MainTabControl_IndexChanged)
#
#AllTab
#
$AllTab.Controls.Add($AllScriptOutputLabel)
$AllTab.Controls.Add($AllScriptListLabel)
$AllTab.Controls.Add($AllBack)
$AllTab.Controls.Add($AllExport)
$AllTab.Controls.Add($AllRefresh)
$AllTab.Controls.Add($AllScriptList)
$AllTab.Controls.Add($AllOutput)
$AllTab.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$AllTab.Name = [System.String]'AllTab'
$AllTab.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$AllTab.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$AllTab.TabIndex = [System.Int32]0
$AllTab.Text = [System.String]'All'
$AllTab.UseVisualStyleBackColor = $true
#
#AllScriptOutputLabel
#
$AllScriptOutputLabel.AutoSize = $true
$AllScriptOutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$AllScriptOutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$AllScriptOutputLabel.Name = [System.String]'AllScriptOutputLabel'
$AllScriptOutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$AllScriptOutputLabel.TabIndex = [System.Int32]9
$AllScriptOutputLabel.Text = [System.String]'Output:'
#
#AllScriptListLabel
#
$AllScriptListLabel.AutoSize = $true
$AllScriptListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$AllScriptListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$AllScriptListLabel.Name = [System.String]'AllScriptListLabel'
$AllScriptListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$AllScriptListLabel.TabIndex = [System.Int32]8
$AllScriptListLabel.Text = [System.String]'List of Scripts:'
#
#AllBack
#
$AllBack.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$AllBack.Name = [System.String]'AllBack'
$AllBack.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$AllBack.TabIndex = [System.Int32]7
$AllBack.Text = [System.String]'Back'
$AllBack.UseVisualStyleBackColor = $true
$AllBack.add_Click($AuxiliaryBack_Click)
#
#AllExport
#
$AllExport.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$AllExport.Name = [System.String]'AllExport'
$AllExport.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$AllExport.TabIndex = [System.Int32]6
$AllExport.Text = [System.String]'Export'
$AllExport.UseVisualStyleBackColor = $true
$AllExport.add_Click($AllExportReport)
#
#AllRefresh
#
$AllRefresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$AllRefresh.Name = [System.String]'AllRefresh'
$AllRefresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$AllRefresh.TabIndex = [System.Int32]5
$AllRefresh.Text = [System.String]'Refresh'
$AllRefresh.UseVisualStyleBackColor = $true
$AllRefresh.add_Click($AllScriptList_ListUpdate)
#
#AllScriptList
#
$AllScriptList.FormattingEnabled = $true
$AllScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything'))
$AllScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$AllScriptList.Name = [System.String]'AllScriptList'
$AllScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$AllScriptList.TabIndex = [System.Int32]4
$AllScriptList.add_SelectedIndexChanged($AllScriptList_ListUpdate)
#
#AllOutput
#
$AllOutput.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$AllOutput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$AllOutput.Name = [System.String]'AllOutput'
$AllOutput.ReadOnly = $true
$AllOutput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$AllOutput.TabIndex = [System.Int32]1
$AllOutput.Text = [System.String]''
#
#ReqTab2
#
$ReqTab2.Controls.Add($Req2OutputLabel)
$ReqTab2.Controls.Add($Req2ListLabel)
$ReqTab2.Controls.Add($Req2Back)
$ReqTab2.Controls.Add($Req2ScriptList)
$ReqTab2.Controls.Add($Req2Refresh)
$ReqTab2.Controls.Add($Req2Export)
$ReqTab2.Controls.Add($Req2Output)
$ReqTab2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab2.Name = [System.String]'ReqTab2'
$ReqTab2.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$ReqTab2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab2.TabIndex = [System.Int32]1
$ReqTab2.Text = [System.String]'Requirement 2'
$ReqTab2.UseVisualStyleBackColor = $true
#
#Req2OutputLabel
#
$Req2OutputLabel.AutoSize = $true
$Req2OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req2OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req2OutputLabel.Name = [System.String]'Req2OutputLabel'
$Req2OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req2OutputLabel.TabIndex = [System.Int32]11
$Req2OutputLabel.Text = [System.String]'Output:'
#
#Req2ListLabel
#
$Req2ListLabel.AutoSize = $true
$Req2ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req2ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req2ListLabel.Name = [System.String]'Req2ListLabel'
$Req2ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req2ListLabel.TabIndex = [System.Int32]10
$Req2ListLabel.Text = [System.String]'List of Scripts:'
#
#Req2Back
#
$Req2Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req2Back.Name = [System.String]'Req2Back'
$Req2Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req2Back.TabIndex = [System.Int32]5
$Req2Back.Text = [System.String]'Back'
$Req2Back.UseVisualStyleBackColor = $true
$Req2Back.add_Click($AuxiliaryBack_Click)
#
#Req2ScriptList
#
$Req2ScriptList.FormattingEnabled = $true
$Req2ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Two',[System.String]'2.2.1 - Grab Installed Windows Features',[System.String]'2.2.2 - Grab Running Processes',[System.String]'2.2.2 - Grab Running Services',[System.String]'2.2.2 - Grab Established Network Connections',[System.String]'2.2.2 - Grab Installed Software',[System.String]'2.4 - Grab All Computer Objects from Active Directory'))
$Req2ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req2ScriptList.Name = [System.String]'Req2ScriptList'
$Req2ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req2ScriptList.TabIndex = [System.Int32]3
$Req2ScriptList.add_SelectedIndexChanged($Req2ScriptList_ListUpdate)
#
#Req2Refresh
#
$Req2Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req2Refresh.Name = [System.String]'Req2Refresh'
$Req2Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req2Refresh.TabIndex = [System.Int32]2
$Req2Refresh.Text = [System.String]'Refresh'
$Req2Refresh.UseVisualStyleBackColor = $true
$Req2Refresh.add_Click($Req2ScriptList_ListUpdate)
#
#Req2Export
#
$Req2Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req2Export.Name = [System.String]'Req2Export'
$Req2Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req2Export.TabIndex = [System.Int32]1
$Req2Export.Text = [System.String]'Export'
$Req2Export.UseVisualStyleBackColor = $true
$Req2Export.add_Click($Req2ExportReport)
#
#Req2Output
#
$Req2Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req2Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req2Output.Name = [System.String]'Req2Output'
$Req2Output.ReadOnly = $true
$Req2Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req2Output.TabIndex = [System.Int32]0
$Req2Output.Text = [System.String]''
#
#ReqTab4
#
$ReqTab4.Controls.Add($Req4OutputLabel)
$ReqTab4.Controls.Add($Req4ListLabel)
$ReqTab4.Controls.Add($Req4Back)
$ReqTab4.Controls.Add($Req4Export)
$ReqTab4.Controls.Add($Req4Refresh)
$ReqTab4.Controls.Add($Req4ScriptList)
$ReqTab4.Controls.Add($Req4Output)
$ReqTab4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab4.Name = [System.String]'ReqTab4'
$ReqTab4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab4.TabIndex = [System.Int32]2
$ReqTab4.Text = [System.String]'Requirement 4'
$ReqTab4.UseVisualStyleBackColor = $true
#
#Req4OutputLabel
#
$Req4OutputLabel.AutoSize = $true
$Req4OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req4OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req4OutputLabel.Name = [System.String]'Req4OutputLabel'
$Req4OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req4OutputLabel.TabIndex = [System.Int32]11
$Req4OutputLabel.Text = [System.String]'Output:'
#
#Req4ListLabel
#
$Req4ListLabel.AutoSize = $true
$Req4ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req4ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req4ListLabel.Name = [System.String]'Req4ListLabel'
$Req4ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req4ListLabel.TabIndex = [System.Int32]10
$Req4ListLabel.Text = [System.String]'List of Scripts:'
#
#Req4Back
#
$Req4Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req4Back.Name = [System.String]'Req4Back'
$Req4Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req4Back.TabIndex = [System.Int32]7
$Req4Back.Text = [System.String]'Back'
$Req4Back.UseVisualStyleBackColor = $true
$Req4Back.add_Click($AuxiliaryBack_Click)
#
#Req4Export
#
$Req4Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req4Export.Name = [System.String]'Req4Export'
$Req4Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req4Export.TabIndex = [System.Int32]6
$Req4Export.Text = [System.String]'Export'
$Req4Export.UseVisualStyleBackColor = $true
$Req4Export.add_Click($Req4ExportReport)
#
#Req4Refresh
#
$Req4Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req4Refresh.Name = [System.String]'Req4Refresh'
$Req4Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req4Refresh.TabIndex = [System.Int32]5
$Req4Refresh.Text = [System.String]'Refresh'
$Req4Refresh.UseVisualStyleBackColor = $true
$Req4Refresh.add_Click($Req4ScriptList_ListUpdate)
#
#Req4ScriptList
#
$Req4ScriptList.FormattingEnabled = $true
$Req4ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Four',[System.String]'4.1 - Analyse Wi-Fi Environment',[System.String]'4.1 - Analyse Keys and Certificates'))
$Req4ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req4ScriptList.Name = [System.String]'Req4ScriptList'
$Req4ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req4ScriptList.TabIndex = [System.Int32]4
$Req4ScriptList.add_SelectedIndexChanged($Req4ScriptList_ListUpdate)
#
#Req4Output
#
$Req4Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req4Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req4Output.Name = [System.String]'Req4Output'
$Req4Output.ReadOnly = $true
$Req4Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req4Output.TabIndex = [System.Int32]1
$Req4Output.Text = [System.String]''
#
#ReqTab5
#
$ReqTab5.Controls.Add($Req5OutputLabel)
$ReqTab5.Controls.Add($Req5ListLabel)
$ReqTab5.Controls.Add($Req5Back)
$ReqTab5.Controls.Add($Req5Export)
$ReqTab5.Controls.Add($Req5Refresh)
$ReqTab5.Controls.Add($Req5ScriptList)
$ReqTab5.Controls.Add($Req5Output)
$ReqTab5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab5.Name = [System.String]'ReqTab5'
$ReqTab5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab5.TabIndex = [System.Int32]3
$ReqTab5.Text = [System.String]'Requirement 5'
$ReqTab5.UseVisualStyleBackColor = $true
#
#Req5OutputLabel
#
$Req5OutputLabel.AutoSize = $true
$Req5OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req5OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req5OutputLabel.Name = [System.String]'Req5OutputLabel'
$Req5OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req5OutputLabel.TabIndex = [System.Int32]11
$Req5OutputLabel.Text = [System.String]'Output:'
#
#Req5ListLabel
#
$Req5ListLabel.AutoSize = $true
$Req5ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req5ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req5ListLabel.Name = [System.String]'Req5ListLabel'
$Req5ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req5ListLabel.TabIndex = [System.Int32]10
$Req5ListLabel.Text = [System.String]'List of Scripts:'
#
#Req5Back
#
$Req5Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req5Back.Name = [System.String]'Req5Back'
$Req5Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req5Back.TabIndex = [System.Int32]9
$Req5Back.Text = [System.String]'Back'
$Req5Back.UseVisualStyleBackColor = $true
$Req5Back.add_Click($AuxiliaryBack_Click)
#
#Req5Export
#
$Req5Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req5Export.Name = [System.String]'Req5Export'
$Req5Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req5Export.TabIndex = [System.Int32]8
$Req5Export.Text = [System.String]'Export'
$Req5Export.UseVisualStyleBackColor = $true
$Req5Export.add_Click($Req5ExportReport)
#
#Req5Refresh
#
$Req5Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req5Refresh.Name = [System.String]'Req5Refresh'
$Req5Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req5Refresh.TabIndex = [System.Int32]7
$Req5Refresh.Text = [System.String]'Refresh'
$Req5Refresh.UseVisualStyleBackColor = $true
$Req5Refresh.add_Click($Req5ScriptList_ListUpdate)
#
#Req5ScriptList
#
$Req5ScriptList.FormattingEnabled = $true
$Req5ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Five',[System.String]'5.1 - Antivirus Program and GPO Analysis',[System.String]'5.1 - Grab Software Deployment Settings in Organization',[System.String]'5.3 - Check end user permissions to modify antivirus software'))
$Req5ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req5ScriptList.Name = [System.String]'Req5ScriptList'
$Req5ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req5ScriptList.TabIndex = [System.Int32]5
$Req5ScriptList.add_SelectedIndexChanged($Req5ScriptList_ListUpdate)
#
#Req5Output
#
$Req5Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req5Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req5Output.Name = [System.String]'Req5Output'
$Req5Output.ReadOnly = $true
$Req5Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req5Output.TabIndex = [System.Int32]2
$Req5Output.Text = [System.String]''
#
#ReqTab7
#
$ReqTab7.Controls.Add($Req7OutputLabel)
$ReqTab7.Controls.Add($Req7ListLabel)
$ReqTab7.Controls.Add($Req7Back)
$ReqTab7.Controls.Add($Req7Export)
$ReqTab7.Controls.Add($Req7Refresh)
$ReqTab7.Controls.Add($Req7ScriptList)
$ReqTab7.Controls.Add($Req7Output)
$ReqTab7.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab7.Name = [System.String]'ReqTab7'
$ReqTab7.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab7.TabIndex = [System.Int32]4
$ReqTab7.Text = [System.String]'Requirement 7'
$ReqTab7.UseVisualStyleBackColor = $true
#
#Req7OutputLabel
#
$Req7OutputLabel.AutoSize = $true
$Req7OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req7OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req7OutputLabel.Name = [System.String]'Req7OutputLabel'
$Req7OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req7OutputLabel.TabIndex = [System.Int32]13
$Req7OutputLabel.Text = [System.String]'Output:'
#
#Req7ListLabel
#
$Req7ListLabel.AutoSize = $true
$Req7ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req7ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req7ListLabel.Name = [System.String]'Req7ListLabel'
$Req7ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req7ListLabel.TabIndex = [System.Int32]12
$Req7ListLabel.Text = [System.String]'List of Scripts:'
#
#Req7Back
#
$Req7Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req7Back.Name = [System.String]'Req7Back'
$Req7Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req7Back.TabIndex = [System.Int32]11
$Req7Back.Text = [System.String]'Back'
$Req7Back.UseVisualStyleBackColor = $true
$Req7Back.add_Click($AuxiliaryBack_Click)
#
#Req7Export
#
$Req7Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req7Export.Name = [System.String]'Req7Export'
$Req7Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req7Export.TabIndex = [System.Int32]10
$Req7Export.Text = [System.String]'Export'
$Req7Export.UseVisualStyleBackColor = $true
$Req7Export.add_Click($Req7ExportReport)
#
#Req7Refresh
#
$Req7Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req7Refresh.Name = [System.String]'Req7Refresh'
$Req7Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req7Refresh.TabIndex = [System.Int32]9
$Req7Refresh.Text = [System.String]'Refresh'
$Req7Refresh.UseVisualStyleBackColor = $true
$Req7Refresh.add_Click($Req7ScriptList_ListUpdate)
#
#Req7ScriptList
#
$Req7ScriptList.FormattingEnabled = $true
$Req7ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Seven',[System.String]'7.1 - Grab and analyse folder permissions that hold sensitive data',[System.String]'7.2 - Check for deny all permissions',[System.String]'7.1.2 - Grab User Privileges'))
$Req7ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req7ScriptList.Name = [System.String]'Req7ScriptList'
$Req7ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req7ScriptList.TabIndex = [System.Int32]6
$Req7ScriptList.add_SelectedIndexChanged($Req7ScriptList_ListUpdate)
#
#Req7Output
#
$Req7Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req7Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req7Output.Name = [System.String]'Req7Output'
$Req7Output.ReadOnly = $true
$Req7Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req7Output.TabIndex = [System.Int32]3
$Req7Output.Text = [System.String]''
#
#ReqTab8
#
$ReqTab8.Controls.Add($Req8OutputLabel)
$ReqTab8.Controls.Add($Req8ListLabel)
$ReqTab8.Controls.Add($Req8Back)
$ReqTab8.Controls.Add($Req8Export)
$ReqTab8.Controls.Add($Req8Refresh)
$ReqTab8.Controls.Add($Req8ScriptList)
$ReqTab8.Controls.Add($Req8Output)
$ReqTab8.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab8.Name = [System.String]'ReqTab8'
$ReqTab8.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab8.TabIndex = [System.Int32]5
$ReqTab8.Text = [System.String]'Requirement 8'
$ReqTab8.UseVisualStyleBackColor = $true
#
#Req8OutputLabel
#
$Req8OutputLabel.AutoSize = $true
$Req8OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req8OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req8OutputLabel.Name = [System.String]'Req8OutputLabel'
$Req8OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req8OutputLabel.TabIndex = [System.Int32]15
$Req8OutputLabel.Text = [System.String]'Output:'
#
#Req8ListLabel
#
$Req8ListLabel.AutoSize = $true
$Req8ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req8ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req8ListLabel.Name = [System.String]'Req8ListLabel'
$Req8ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req8ListLabel.TabIndex = [System.Int32]14
$Req8ListLabel.Text = [System.String]'List of Scripts:'
#
#Req8Back
#
$Req8Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req8Back.Name = [System.String]'Req8Back'
$Req8Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req8Back.TabIndex = [System.Int32]13
$Req8Back.Text = [System.String]'Back'
$Req8Back.UseVisualStyleBackColor = $true
$Req8Back.add_Click($AuxiliaryBack_Click)
#
#Req8Export
#
$Req8Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req8Export.Name = [System.String]'Req8Export'
$Req8Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req8Export.TabIndex = [System.Int32]12
$Req8Export.Text = [System.String]'Export'
$Req8Export.UseVisualStyleBackColor = $true
$Req8Export.add_Click($Req8ExportReport)
#
#Req8Refresh
#
$Req8Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req8Refresh.Name = [System.String]'Req8Refresh'
$Req8Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req8Refresh.TabIndex = [System.Int32]11
$Req8Refresh.Text = [System.String]'Refresh'
$Req8Refresh.UseVisualStyleBackColor = $true
$Req8Refresh.add_Click($Req8ScriptList_ListUpdate)
#
#Req8ScriptList
#
$Req8ScriptList.FormattingEnabled = $true
$Req8ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Eight',[System.String]'Grab Domain Password Policy Settings',[System.String]'Grab Local Password Policy Settings',[System.String]'Dump of Active Active Directory Users',[System.String]'Dump of Disabled Active Directory Users',[System.String]'Dump of Inactive Active Directory Users',[System.String]'Grab Current User',[System.String]'Grab Local Administrator Accounts',[System.String]'Grab Domain Administrator Accounts',[System.String]'Dump of Users whose Password Never Expire',[System.String]'Dump of Users and Their Last Password Change',[System.String]'Grab the Screensaver Settings',[System.String]'Grab RDP Encryption and Idle Settings'))
$Req8ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req8ScriptList.Name = [System.String]'Req8ScriptList'
$Req8ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req8ScriptList.TabIndex = [System.Int32]7
$Req8ScriptList.add_SelectedIndexChanged($Req8ScriptList_ListUpdate)
#
#Req8Output
#
$Req8Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req8Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req8Output.Name = [System.String]'Req8Output'
$Req8Output.ReadOnly = $true
$Req8Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req8Output.TabIndex = [System.Int32]4
$Req8Output.Text = [System.String]''
#
#ReqTab10
#
$ReqTab10.Controls.Add($Req10OutputLabel)
$ReqTab10.Controls.Add($Req10ListLabel)
$ReqTab10.Controls.Add($Req10Back)
$ReqTab10.Controls.Add($Req10Export)
$ReqTab10.Controls.Add($Req10Refresh)
$ReqTab10.Controls.Add($Req10ScriptList)
$ReqTab10.Controls.Add($Req10Output)
$ReqTab10.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab10.Name = [System.String]'ReqTab10'
$ReqTab10.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$ReqTab10.TabIndex = [System.Int32]6
$ReqTab10.Text = [System.String]'Requirement 10'
$ReqTab10.UseVisualStyleBackColor = $true
#
#Req10OutputLabel
#
$Req10OutputLabel.AutoSize = $true
$Req10OutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req10OutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$Req10OutputLabel.Name = [System.String]'Req10OutputLabel'
$Req10OutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$Req10OutputLabel.TabIndex = [System.Int32]17
$Req10OutputLabel.Text = [System.String]'Output:'
#
#Req10ListLabel
#
$Req10ListLabel.AutoSize = $true
$Req10ListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$Req10ListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$Req10ListLabel.Name = [System.String]'Req10ListLabel'
$Req10ListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$Req10ListLabel.TabIndex = [System.Int32]16
$Req10ListLabel.Text = [System.String]'List of Scripts:'
#
#Req10Back
#
$Req10Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req10Back.Name = [System.String]'Req10Back'
$Req10Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req10Back.TabIndex = [System.Int32]15
$Req10Back.Text = [System.String]'Back'
$Req10Back.UseVisualStyleBackColor = $true
$Req10Back.add_Click($AuxiliaryBack_Click)
#
#Req10Export
#
$Req10Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$Req10Export.Name = [System.String]'Req10Export'
$Req10Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req10Export.TabIndex = [System.Int32]14
$Req10Export.Text = [System.String]'Export'
$Req10Export.UseVisualStyleBackColor = $true
$Req10Export.add_Click($Req10ExportReport)
#
#Req10Refresh
#
$Req10Refresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$Req10Refresh.Name = [System.String]'Req10Refresh'
$Req10Refresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req10Refresh.TabIndex = [System.Int32]13
$Req10Refresh.Text = [System.String]'Refresh'
$Req10Refresh.UseVisualStyleBackColor = $true
$Req10Refresh.add_Click($Req10ScriptList_ListUpdate)
#
#Req10ScriptList
#
$Req10ScriptList.FormattingEnabled = $true
$Req10ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Ten',[System.String]'10.2 - Dump of Audit Category Settings',[System.String]'10.4 - Grab NTP Settings',[System.String]'10.4 - Check NTP Settings on Multiple Devices',[System.String]'10.5 - Check Audit Log Permissions',[System.String]'10.7 - Grab Previous Audit Logs'))
$Req10ScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$Req10ScriptList.Name = [System.String]'Req10ScriptList'
$Req10ScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$Req10ScriptList.TabIndex = [System.Int32]8
$Req10ScriptList.add_SelectedIndexChanged($Req10ScriptList_ListUpdate)
#
#Req10Output
#
$Req10Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req10Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req10Output.Name = [System.String]'Req10Output'
$Req10Output.ReadOnly = $true
$Req10Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req10Output.TabIndex = [System.Int32]5
$Req10Output.Text = [System.String]'`'
#
#DiagTab
#
$DiagTab.Controls.Add($DiagOutputLabel)
$DiagTab.Controls.Add($DiagListLabel)
$DiagTab.Controls.Add($DiagBack)
$DiagTab.Controls.Add($DiagExport)
$DiagTab.Controls.Add($DiagRefresh)
$DiagTab.Controls.Add($DiagScriptList)
$DiagTab.Controls.Add($DiagOutput)
$DiagTab.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$DiagTab.Name = [System.String]'DiagTab'
$DiagTab.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1577,[System.Int32]836))
$DiagTab.TabIndex = [System.Int32]7
$DiagTab.Text = [System.String]'Diagnostics'
$DiagTab.UseVisualStyleBackColor = $true
#
#DiagOutputLabel
#
$DiagOutputLabel.AutoSize = $true
$DiagOutputLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$DiagOutputLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]14))
$DiagOutputLabel.Name = [System.String]'DiagOutputLabel'
$DiagOutputLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]62,[System.Int32]17))
$DiagOutputLabel.TabIndex = [System.Int32]22
$DiagOutputLabel.Text = [System.String]'Output:'
#
#DiagListLabel
#
$DiagListLabel.AutoSize = $true
$DiagListLabel.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10,[System.Drawing.FontStyle]::Bold))
$DiagListLabel.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]14))
$DiagListLabel.Name = [System.String]'DiagListLabel'
$DiagListLabel.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]113,[System.Int32]17))
$DiagListLabel.TabIndex = [System.Int32]21
$DiagListLabel.Text = [System.String]'List of Scripts:'
#
#DiagBack
#
$DiagBack.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$DiagBack.Name = [System.String]'DiagBack'
$DiagBack.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$DiagBack.TabIndex = [System.Int32]20
$DiagBack.Text = [System.String]'Back'
$DiagBack.UseVisualStyleBackColor = $true
$DiagBack.add_Click($AuxiliaryBack_Click)
#
#DiagExport
#
$DiagExport.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1376,[System.Int32]787))
$DiagExport.Name = [System.String]'DiagExport'
$DiagExport.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$DiagExport.TabIndex = [System.Int32]19
$DiagExport.Text = [System.String]'Export'
$DiagExport.UseVisualStyleBackColor = $true
$DiagExport.add_Click($DiagExportReport)
#
#DiagRefresh
#
$DiagRefresh.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]787))
$DiagRefresh.Name = [System.String]'DiagRefresh'
$DiagRefresh.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$DiagRefresh.TabIndex = [System.Int32]18
$DiagRefresh.Text = [System.String]'Refresh'
$DiagRefresh.UseVisualStyleBackColor = $true
$DiagRefresh.add_Click($DiagScriptList_ListUpdate)
#
#DiagScriptList
#
$DiagScriptList.FormattingEnabled = $true
$DiagScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Diagnostics',[System.String]'Grab System Information',[System.String]'Grab Installed Software Patches',[System.String]'Grab IP Config',[System.String]'Check TCP Connectivity',[System.String]'GPO Dump'))
$DiagScriptList.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]40))
$DiagScriptList.Name = [System.String]'DiagScriptList'
$DiagScriptList.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]320,[System.Int32]745))
$DiagScriptList.TabIndex = [System.Int32]17
$DiagScriptList.add_SelectedIndexChanged($DiagScriptList_ListUpdate)
#
#DiagOutput
#
$DiagOutput.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$DiagOutput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$DiagOutput.Name = [System.String]'DiagOutput'
$DiagOutput.ReadOnly = $true
$DiagOutput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$DiagOutput.TabIndex = [System.Int32]16
$DiagOutput.Text = [System.String]''
#
#AuxiliaryForm
#
$AuxiliaryForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1584,[System.Int32]861))
$AuxiliaryForm.Controls.Add($MainTabControl)
$AuxiliaryForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$AuxiliaryForm.MaximizeBox = $false
$AuxiliaryForm.Name = [System.String]'AuxiliaryForm'
$AuxiliaryForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$AuxiliaryForm.Text = [System.String]'Anordium Audits'
$MainTabControl.ResumeLayout($false)
$AllTab.ResumeLayout($false)
$AllTab.PerformLayout()
$ReqTab2.ResumeLayout($false)
$ReqTab2.PerformLayout()
$ReqTab4.ResumeLayout($false)
$ReqTab4.PerformLayout()
$ReqTab5.ResumeLayout($false)
$ReqTab5.PerformLayout()
$ReqTab7.ResumeLayout($false)
$ReqTab7.PerformLayout()
$ReqTab8.ResumeLayout($false)
$ReqTab8.PerformLayout()
$ReqTab10.ResumeLayout($false)
$ReqTab10.PerformLayout()
$DiagTab.ResumeLayout($false)
$DiagTab.PerformLayout()
$AuxiliaryForm.ResumeLayout($false)
Add-Member -InputObject $AuxiliaryForm -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllTab -Value $AllTab -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab2 -Value $ReqTab2 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2Refresh -Value $Req2Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2Export -Value $Req2Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2Output -Value $Req2Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab4 -Value $ReqTab4 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab5 -Value $ReqTab5 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab7 -Value $ReqTab7 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab8 -Value $ReqTab8 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name ReqTab10 -Value $ReqTab10 -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2ScriptList -Value $Req2ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name MainTabControl -Value $MainTabControl -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllExport -Value $AllExport -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllRefresh -Value $AllRefresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllScriptList -Value $AllScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllOutput -Value $AllOutput -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4Export -Value $Req4Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4Refresh -Value $Req4Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4ScriptList -Value $Req4ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4Output -Value $Req4Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5Export -Value $Req5Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5Refresh -Value $Req5Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5ScriptList -Value $Req5ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5Output -Value $Req5Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7Export -Value $Req7Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7Refresh -Value $Req7Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7ScriptList -Value $Req7ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7Output -Value $Req7Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8Export -Value $Req8Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8Refresh -Value $Req8Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8ScriptList -Value $Req8ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8Output -Value $Req8Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10Export -Value $Req10Export -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10Refresh -Value $Req10Refresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10ScriptList -Value $Req10ScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10Output -Value $Req10Output -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllBack -Value $AllBack -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2Back -Value $Req2Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4Back -Value $Req4Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5Back -Value $Req5Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7Back -Value $Req7Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8Back -Value $Req8Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10Back -Value $Req10Back -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7FolderBrowserDialog -Value $Req7FolderBrowserDialog -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagBack -Value $DiagBack -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagExport -Value $DiagExport -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagRefresh -Value $DiagRefresh -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagScriptList -Value $DiagScriptList -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagTab -Value $DiagTab -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllScriptOutputLabel -Value $AllScriptOutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name AllScriptListLabel -Value $AllScriptListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2OutputLabel -Value $Req2OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req2ListLabel -Value $Req2ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4OutputLabel -Value $Req4OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req4ListLabel -Value $Req4ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5OutputLabel -Value $Req5OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req5ListLabel -Value $Req5ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7OutputLabel -Value $Req7OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req7ListLabel -Value $Req7ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8ListLabel -Value $Req8ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req8OutputLabel -Value $Req8OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10OutputLabel -Value $Req10OutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name Req10ListLabel -Value $Req10ListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagOutputLabel -Value $DiagOutputLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagListLabel -Value $DiagListLabel -MemberType NoteProperty
Add-Member -InputObject $AuxiliaryForm -Name DiagOutput -Value $DiagOutput -MemberType NoteProperty
}
. InitializeComponent
