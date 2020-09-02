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
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$MainTabControl = (New-Object -TypeName System.Windows.Forms.TabControl)
$AllTab = (New-Object -TypeName System.Windows.Forms.TabPage)
$AllBack = (New-Object -TypeName System.Windows.Forms.Button)
$AllExport = (New-Object -TypeName System.Windows.Forms.Button)
$AllRefresh = (New-Object -TypeName System.Windows.Forms.Button)
$AllScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$AllOutput = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab2 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req2Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req2ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req2Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req2Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req2Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab4 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req4Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req4Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req4Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req4ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req4Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab5 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req5Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req5Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req5Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req5ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req5Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab7 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req7Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req7Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req7Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req7ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req7Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab8 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req8Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req8Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req8Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req8ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req8Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$ReqTab10 = (New-Object -TypeName System.Windows.Forms.TabPage)
$Req10Back = (New-Object -TypeName System.Windows.Forms.Button)
$Req10Export = (New-Object -TypeName System.Windows.Forms.Button)
$Req10Refresh = (New-Object -TypeName System.Windows.Forms.Button)
$Req10ScriptList = (New-Object -TypeName System.Windows.Forms.ListBox)
$Req10Output = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$MainTabControl.SuspendLayout()
$AllTab.SuspendLayout()
$ReqTab2.SuspendLayout()
$ReqTab4.SuspendLayout()
$ReqTab5.SuspendLayout()
$ReqTab7.SuspendLayout()
$ReqTab8.SuspendLayout()
$ReqTab10.SuspendLayout()
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
$MainTabControl.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
$MainTabControl.Name = [System.String]'MainTabControl'
$MainTabControl.SelectedIndex = [System.Int32]0
$MainTabControl.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1580,[System.Int32]860))
$MainTabControl.TabIndex = [System.Int32]0
#
#AllTab
#
$AllTab.Controls.Add($AllBack)
$AllTab.Controls.Add($AllExport)
$AllTab.Controls.Add($AllRefresh)
$AllTab.Controls.Add($AllScriptList)
$AllTab.Controls.Add($AllOutput)
$AllTab.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$AllTab.Name = [System.String]'AllTab'
$AllTab.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$AllTab.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$AllTab.TabIndex = [System.Int32]0
$AllTab.Text = [System.String]'All'
$AllTab.UseVisualStyleBackColor = $true
#
#AllBack
#
$AllBack.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$AllBack.Name = [System.String]'AllBack'
$AllBack.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$AllBack.TabIndex = [System.Int32]7
$AllBack.Text = [System.String]'Change Network Variables'
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
$AllOutput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$AllOutput.TabIndex = [System.Int32]1
$AllOutput.Text = [System.String]''
#
#ReqTab2
#
$ReqTab2.Controls.Add($Req2Back)
$ReqTab2.Controls.Add($Req2ScriptList)
$ReqTab2.Controls.Add($Req2Refresh)
$ReqTab2.Controls.Add($Req2Export)
$ReqTab2.Controls.Add($Req2Output)
$ReqTab2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab2.Name = [System.String]'ReqTab2'
$ReqTab2.Padding = (New-Object -TypeName System.Windows.Forms.Padding -ArgumentList @([System.Int32]3))
$ReqTab2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab2.TabIndex = [System.Int32]1
$ReqTab2.Text = [System.String]'Requirement 2'
$ReqTab2.UseVisualStyleBackColor = $true
#
#Req2Back
#
$Req2Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req2Back.Name = [System.String]'Req2Back'
$Req2Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req2Back.TabIndex = [System.Int32]5
$Req2Back.Text = [System.String]'Change Network Variables'
$Req2Back.UseVisualStyleBackColor = $true
$Req2Back.add_Click($AuxiliaryBack_Click)
#
#Req2ScriptList
#
$Req2ScriptList.FormattingEnabled = $true
$Req2ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Two',[System.String]'Sample Services for Default Vendor Passwords',[System.String]'Grab Running Services',[System.String]'Grab Listening Services',[System.String]'Grab Installed Software'))
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
$Req2Export.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1370,[System.Int32]787))
$Req2Export.Name = [System.String]'Req2Export'
$Req2Export.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req2Export.TabIndex = [System.Int32]1
$Req2Export.Text = [System.String]'Export'
$Req2Export.UseVisualStyleBackColor = $true
#
#Req2Output
#
$Req2Output.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Lucida Console',[System.Single]9.75,[System.Drawing.FontStyle]::Regular,[System.Drawing.GraphicsUnit]::Point,([System.Byte][System.Byte]0)))
$Req2Output.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]356,[System.Int32]40))
$Req2Output.Name = [System.String]'Req2Output'
$Req2Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req2Output.TabIndex = [System.Int32]0
$Req2Output.Text = [System.String]''
#
#ReqTab4
#
$ReqTab4.Controls.Add($Req4Back)
$ReqTab4.Controls.Add($Req4Export)
$ReqTab4.Controls.Add($Req4Refresh)
$ReqTab4.Controls.Add($Req4ScriptList)
$ReqTab4.Controls.Add($Req4Output)
$ReqTab4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab4.Name = [System.String]'ReqTab4'
$ReqTab4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab4.TabIndex = [System.Int32]2
$ReqTab4.Text = [System.String]'Requirement 4'
$ReqTab4.UseVisualStyleBackColor = $true
#
#Req4Back
#
$Req4Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req4Back.Name = [System.String]'Req4Back'
$Req4Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req4Back.TabIndex = [System.Int32]7
$Req4Back.Text = [System.String]'Change Network Variables'
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
$Req4ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Four',[System.String]'Analyse Wi-Fi Environment',[System.String]'Analyse Keys and Certificates'))
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
$Req4Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req4Output.TabIndex = [System.Int32]1
$Req4Output.Text = [System.String]''
#
#ReqTab5
#
$ReqTab5.Controls.Add($Req5Back)
$ReqTab5.Controls.Add($Req5Export)
$ReqTab5.Controls.Add($Req5Refresh)
$ReqTab5.Controls.Add($Req5ScriptList)
$ReqTab5.Controls.Add($Req5Output)
$ReqTab5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab5.Name = [System.String]'ReqTab5'
$ReqTab5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab5.TabIndex = [System.Int32]3
$ReqTab5.Text = [System.String]'Requirement 5'
$ReqTab5.UseVisualStyleBackColor = $true
#
#Req5Back
#
$Req5Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req5Back.Name = [System.String]'Req5Back'
$Req5Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req5Back.TabIndex = [System.Int32]9
$Req5Back.Text = [System.String]'Change Network Variables'
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
$Req5ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Five',[System.String]'Antivirus Program and GPO Analysis',[System.String]'Grab Software Deployment Settings in Organization',[System.String]'Check end user permissions to modify antivirus software'))
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
$Req5Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req5Output.TabIndex = [System.Int32]2
$Req5Output.Text = [System.String]''
#
#ReqTab7
#
$ReqTab7.Controls.Add($Req7Back)
$ReqTab7.Controls.Add($Req7Export)
$ReqTab7.Controls.Add($Req7Refresh)
$ReqTab7.Controls.Add($Req7ScriptList)
$ReqTab7.Controls.Add($Req7Output)
$ReqTab7.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab7.Name = [System.String]'ReqTab7'
$ReqTab7.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab7.TabIndex = [System.Int32]4
$ReqTab7.Text = [System.String]'Requirement 7'
$ReqTab7.UseVisualStyleBackColor = $true
#
#Req7Back
#
$Req7Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req7Back.Name = [System.String]'Req7Back'
$Req7Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req7Back.TabIndex = [System.Int32]11
$Req7Back.Text = [System.String]'Change Network Variables'
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
$Req7ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Seven',[System.String]'Grab folder permissions that hold sensitive data',[System.String]'Analyse folder permissions',[System.String]'Check for deny all permissions',[System.String]'Grab User Privileges'))
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
$Req7Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req7Output.TabIndex = [System.Int32]3
$Req7Output.Text = [System.String]''
#
#ReqTab8
#
$ReqTab8.Controls.Add($Req8Back)
$ReqTab8.Controls.Add($Req8Export)
$ReqTab8.Controls.Add($Req8Refresh)
$ReqTab8.Controls.Add($Req8ScriptList)
$ReqTab8.Controls.Add($Req8Output)
$ReqTab8.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab8.Name = [System.String]'ReqTab8'
$ReqTab8.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab8.TabIndex = [System.Int32]5
$ReqTab8.Text = [System.String]'Requirement 8'
$ReqTab8.UseVisualStyleBackColor = $true
#
#Req8Back
#
$Req8Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req8Back.Name = [System.String]'Req8Back'
$Req8Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req8Back.TabIndex = [System.Int32]13
$Req8Back.Text = [System.String]'Change Network Variables'
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
$Req8ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Eight',[System.String]'Grab Domain Password Policy Settings',[System.String]'Grab Local Password Policy Settings',[System.String]'Dump of Active Active Directory Users',[System.String]'Dump of Disabled Active Directory Users',[System.String]'Dump of Inactive Active Directory Users',[System.String]'Grab Current User',[System.String]'Grab Local Administrator Accounts',[System.String]'Grab Domain Administrator Accounts',[System.String]'Dump of Users whose Password Never Expire',[System.String]'Dump of Users and Their Last Password Change',[System.String]'Grab the Screensaver Settings',[System.String]'Grab RDP Encryption and Idle Settings',[System.String]'Check for MFA'))
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
$Req8Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req8Output.TabIndex = [System.Int32]4
$Req8Output.Text = [System.String]''
#
#ReqTab10
#
$ReqTab10.Controls.Add($Req10Back)
$ReqTab10.Controls.Add($Req10Export)
$ReqTab10.Controls.Add($Req10Refresh)
$ReqTab10.Controls.Add($Req10ScriptList)
$ReqTab10.Controls.Add($Req10Output)
$ReqTab10.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]4,[System.Int32]22))
$ReqTab10.Name = [System.String]'ReqTab10'
$ReqTab10.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1572,[System.Int32]834))
$ReqTab10.TabIndex = [System.Int32]6
$ReqTab10.Text = [System.String]'Requirement 10'
$ReqTab10.UseVisualStyleBackColor = $true
#
#Req10Back
#
$Req10Back.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]21,[System.Int32]787))
$Req10Back.Name = [System.String]'Req10Back'
$Req10Back.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]40))
$Req10Back.TabIndex = [System.Int32]15
$Req10Back.Text = [System.String]'Change Network Variables'
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
$Req10ScriptList.Items.AddRange([System.Object[]]@([System.String]'Everything in Requirement Ten',[System.String]'Dump of Audit Category Settings from GPO',[System.String]'Grab NTP Settings',[System.String]'Check NTP Settings on Multiple Devices',[System.String]'Check Audit Log Permissions',[System.String]'Grab Previous Audit Logs'))
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
$Req10Output.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1200,[System.Int32]745))
$Req10Output.TabIndex = [System.Int32]5
$Req10Output.Text = [System.String]''
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
$ReqTab2.ResumeLayout($false)
$ReqTab4.ResumeLayout($false)
$ReqTab5.ResumeLayout($false)
$ReqTab7.ResumeLayout($false)
$ReqTab8.ResumeLayout($false)
$ReqTab10.ResumeLayout($false)
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
Add-Member -InputObject $AuxiliaryForm -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
