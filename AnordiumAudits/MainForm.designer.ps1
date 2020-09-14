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
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$resources = . (Join-Path $PSScriptRoot 'MainForm.resources.ps1')
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
([System.ComponentModel.ISupportInitialize]$MainFormLogo).BeginInit()
$MainForm.SuspendLayout()
#
#WelcomeLabel1
#
$WelcomeLabel1.AutoSize = $true
$WelcomeLabel1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]24))
$WelcomeLabel1.Name = [System.String]'WelcomeLabel1'
$WelcomeLabel1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]143,[System.Int32]13))
$WelcomeLabel1.TabIndex = [System.Int32]0
$WelcomeLabel1.Text = [System.String]'Welcome to Anordium Audits'
#
#WelcomeSubmitButton
#
$WelcomeSubmitButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]402,[System.Int32]348))
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
$MainUserInput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]88))
$MainUserInput.Name = [System.String]'MainUserInput'
$MainUserInput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]367,[System.Int32]30))
$MainUserInput.TabIndex = [System.Int32]2
#
#MainFormOutput
#
$MainFormOutput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]142))
$MainFormOutput.Name = [System.String]'MainFormOutput'
$MainFormOutput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]367,[System.Int32]200))
$MainFormOutput.TabIndex = [System.Int32]3
$MainFormOutput.Text = [System.String]''
#
#MainExportFolderBrowseButton
#
$MainExportFolderBrowseButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]402,[System.Int32]88))
$MainExportFolderBrowseButton.Name = [System.String]'MainExportFolderBrowseButton'
$MainExportFolderBrowseButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$MainExportFolderBrowseButton.TabIndex = [System.Int32]4
$MainExportFolderBrowseButton.Text = [System.String]'Browse'
$MainExportFolderBrowseButton.UseVisualStyleBackColor = $true
$MainExportFolderBrowseButton.add_Click($button2_Click)
#
#WelcomeLabel2
#
$WelcomeLabel2.AutoSize = $true
$WelcomeLabel2.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]68))
$WelcomeLabel2.Name = [System.String]'WelcomeLabel2'
$WelcomeLabel2.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]183,[System.Int32]13))
$WelcomeLabel2.TabIndex = [System.Int32]5
$WelcomeLabel2.Text = [System.String]'Export path for all reports if applicable'
#
#WelcomeLabel3
#
$WelcomeLabel3.AutoSize = $true
$WelcomeLabel3.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]13,[System.Int32]125))
$WelcomeLabel3.Name = [System.String]'WelcomeLabel3'
$WelcomeLabel3.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]42,[System.Int32]13))
$WelcomeLabel3.TabIndex = [System.Int32]6
$WelcomeLabel3.Text = [System.String]'Output:'
#
#MainFormCredits
#
$MainFormCredits.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]348))
$MainFormCredits.Name = [System.String]'MainFormCredits'
$MainFormCredits.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
$MainFormCredits.TabIndex = [System.Int32]7
$MainFormCredits.Text = [System.String]'Credits'
$MainFormCredits.UseVisualStyleBackColor = $true
#
#MainFormLogo
#
$MainFormLogo.Image = ([System.Drawing.Image]$resources.'MainFormLogo.Image')
$MainFormLogo.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]523,[System.Int32]24))
$MainFormLogo.Name = [System.String]'MainFormLogo'
$MainFormLogo.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]249,[System.Int32]354))
$MainFormLogo.TabIndex = [System.Int32]8
$MainFormLogo.TabStop = $false
#
#MainForm
#
$MainForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]784,[System.Int32]411))
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
Add-Member -InputObject $MainForm -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
