[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$MainForm = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Label]$WelcomeLabel1 = $null
[System.Windows.Forms.Button]$WelcomeSubmitButton = $null
[System.Windows.Forms.TextBox]$MainUserInput = $null
[System.Windows.Forms.FolderBrowserDialog]$MainExportFolderBrowse = $null
[System.Windows.Forms.RichTextBox]$MainFormOutput = $null
[System.Windows.Forms.Button]$MainExportFolderBrowseButton = $null
[System.Windows.Forms.Label]$WelcomeLabel2 = $null
[System.Windows.Forms.Label]$WelcomeLabel3 = $null
[System.Windows.Forms.Button]$MainFormCredits = $null
[System.Windows.Forms.PictureBox]$MainFormLogo = $null
[System.Windows.Forms.Label]$WelcomeLabel4 = $null
[System.Windows.Forms.Label]$WelcomeLabel5 = $null
[System.Windows.Forms.Label]$WelcomeLabel6 = $null
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$WelcomeLabel1 = (New-Object -TypeName System.Windows.Forms.Label)
$WelcomeSubmitButton = (New-Object -TypeName System.Windows.Forms.Button)
$MainUserInput = (New-Object -TypeName System.Windows.Forms.TextBox)
$MainExportFolderBrowse = (New-Object -TypeName System.Windows.Forms.FolderBrowserDialog)
$MainFormOutput = (New-Object -TypeName System.Windows.Forms.RichTextBox)
$MainExportFolderBrowseButton = (New-Object -TypeName System.Windows.Forms.Button)
$WelcomeLabel2 = (New-Object -TypeName System.Windows.Forms.Label)
$WelcomeLabel3 = (New-Object -TypeName System.Windows.Forms.Label)
$MainFormCredits = (New-Object -TypeName System.Windows.Forms.Button)
$MainFormLogo = (New-Object -TypeName System.Windows.Forms.PictureBox)
$WelcomeLabel4 = (New-Object -TypeName System.Windows.Forms.Label)
$WelcomeLabel5 = (New-Object -TypeName System.Windows.Forms.Label)
$WelcomeLabel6 = (New-Object -TypeName System.Windows.Forms.Label)
([System.ComponentModel.ISupportInitialize]$MainFormLogo).BeginInit()
$MainForm.SuspendLayout()
#
#WelcomeLabel1
#
$WelcomeLabel1.AutoSize = $true
$WelcomeLabel1.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]10))
$WelcomeLabel1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]9))
$WelcomeLabel1.Name = [System.String]'WelcomeLabel1'
$WelcomeLabel1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]189,[System.Int32]17))
$WelcomeLabel1.TabIndex = [System.Int32]0
$WelcomeLabel1.Text = [System.String]'Welcome to Anordium Audits'
#
#WelcomeSubmitButton
#
$WelcomeSubmitButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]402,[System.Int32]361))
$WelcomeSubmitButton.Name = [System.String]'WelcomeSubmitButton'
$WelcomeSubmitButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$WelcomeSubmitButton.TabIndex = [System.Int32]1
$WelcomeSubmitButton.Text = [System.String]'Submit'
$WelcomeSubmitButton.UseVisualStyleBackColor = $true
$WelcomeSubmitButton.add_Click($WelcomeSubmitButton_Click)
#
#MainUserInput
#
$MainUserInput.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]15))
$MainUserInput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]99))
$MainUserInput.Name = [System.String]'MainUserInput'
$MainUserInput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]367,[System.Int32]30))
$MainUserInput.TabIndex = [System.Int32]2
#
#MainExportFolderBrowse
#
$MainExportFolderBrowse.RootFolder = [System.Environment+SpecialFolder]::MyComputer
#
#MainFormOutput
#
$MainFormOutput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]153))
$MainFormOutput.Name = [System.String]'MainFormOutput'
$MainFormOutput.ReadOnly = $true
$MainFormOutput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]461,[System.Int32]200))
$MainFormOutput.TabIndex = [System.Int32]3
$MainFormOutput.Text = [System.String]''
#
#MainExportFolderBrowseButton
#
$MainExportFolderBrowseButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]402,[System.Int32]99))
$MainExportFolderBrowseButton.Name = [System.String]'MainExportFolderBrowseButton'
$MainExportFolderBrowseButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$MainExportFolderBrowseButton.TabIndex = [System.Int32]4
$MainExportFolderBrowseButton.Text = [System.String]'Browse'
$MainExportFolderBrowseButton.UseVisualStyleBackColor = $true
$MainExportFolderBrowseButton.add_Click($UserInputBrowse)
#
#WelcomeLabel2
#
$WelcomeLabel2.AutoSize = $true
$WelcomeLabel2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]79))
$WelcomeLabel2.Name = [System.String]'WelcomeLabel2'
$WelcomeLabel2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]126,[System.Int32]13))
$WelcomeLabel2.TabIndex = [System.Int32]5
$WelcomeLabel2.Text = [System.String]'Path for exported reports:'
#
#WelcomeLabel3
#
$WelcomeLabel3.AutoSize = $true
$WelcomeLabel3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]136))
$WelcomeLabel3.Name = [System.String]'WelcomeLabel3'
$WelcomeLabel3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]42,[System.Int32]13))
$WelcomeLabel3.TabIndex = [System.Int32]6
$WelcomeLabel3.Text = [System.String]'Output:'
#
#MainFormCredits
#
$MainFormCredits.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]361))
$MainFormCredits.Name = [System.String]'MainFormCredits'
$MainFormCredits.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$MainFormCredits.TabIndex = [System.Int32]7
$MainFormCredits.Text = [System.String]'Credits'
$MainFormCredits.UseVisualStyleBackColor = $true
$MainFormCredits.add_Click($CreditsButton)
#
#MainFormLogo
#
$MainFormLogo.Image = ([System.Drawing.Image]$resources.'MainFormLogo.Image')
$MainFormLogo.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]523,[System.Int32]27))
$MainFormLogo.Name = [System.String]'MainFormLogo'
$MainFormLogo.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]249,[System.Int32]354))
$MainFormLogo.TabIndex = [System.Int32]8
$MainFormLogo.TabStop = $false
#
#WelcomeLabel4
#
$WelcomeLabel4.AutoSize = $true
$WelcomeLabel4.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]36))
$WelcomeLabel4.Name = [System.String]'WelcomeLabel4'
$WelcomeLabel4.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]458,[System.Int32]26))
$WelcomeLabel4.TabIndex = [System.Int32]9
$WelcomeLabel4.Text = [System.String]'This program will audit your network for compliance with requirements 2, 4, 5, 7, 8 and 10 of the 
Payment Card Industry Data Security Standard.'
#
#WelcomeLabel5
#
$WelcomeLabel5.AutoSize = $true
$WelcomeLabel5.ForeColor = [System.Drawing.Color]::Red
$WelcomeLabel5.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]172,[System.Int32]136))
$WelcomeLabel5.Name = [System.String]'WelcomeLabel5'
$WelcomeLabel5.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]50,[System.Int32]13))
$WelcomeLabel5.TabIndex = [System.Int32]10
$WelcomeLabel5.Text = [System.String]'Warning:'
#
#WelcomeLabel6
#
$WelcomeLabel6.AutoSize = $true
$WelcomeLabel6.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]217,[System.Int32]136))
$WelcomeLabel6.Name = [System.String]'WelcomeLabel6'
$WelcomeLabel6.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]256,[System.Int32]13))
$WelcomeLabel6.TabIndex = [System.Int32]11
$WelcomeLabel6.Text = [System.String]' Depending on the report, exporting may take a while'
#
#MainForm
#
$MainForm.Icon = ([System.Drawing.Icon]$resources.'$this.Icon')
$MainForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]411))
$MainForm.Controls.Add($WelcomeLabel6)
$MainForm.Controls.Add($WelcomeLabel5)
$MainForm.Controls.Add($WelcomeLabel4)
$MainForm.Controls.Add($MainFormLogo)
$MainForm.Controls.Add($MainFormCredits)
$MainForm.Controls.Add($WelcomeLabel3)
$MainForm.Controls.Add($WelcomeLabel2)
$MainForm.Controls.Add($MainExportFolderBrowseButton)
$MainForm.Controls.Add($MainFormOutput)
$MainForm.Controls.Add($MainUserInput)
$MainForm.Controls.Add($WelcomeSubmitButton)
$MainForm.Controls.Add($WelcomeLabel1)
$MainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$MainForm.MaximizeBox = $false
$MainForm.Name = [System.String]'MainForm'
$MainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$MainForm.Text = [System.String]'Anordium Audits'
([System.ComponentModel.ISupportInitialize]$MainFormLogo).EndInit()
$MainForm.ResumeLayout($false)
$MainForm.PerformLayout()
Add-Member -InputObject $MainForm -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel1 -Value $WelcomeLabel1 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeSubmitButton -Value $WelcomeSubmitButton -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainUserInput -Value $MainUserInput -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainExportFolderBrowse -Value $MainExportFolderBrowse -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainFormOutput -Value $MainFormOutput -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainExportFolderBrowseButton -Value $MainExportFolderBrowseButton -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel2 -Value $WelcomeLabel2 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel3 -Value $WelcomeLabel3 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainFormCredits -Value $MainFormCredits -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainFormLogo -Value $MainFormLogo -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel4 -Value $WelcomeLabel4 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel5 -Value $WelcomeLabel5 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel6 -Value $WelcomeLabel6 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
