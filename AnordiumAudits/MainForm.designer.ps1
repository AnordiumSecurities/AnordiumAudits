[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
$MainForm = New-Object -TypeName System.Windows.Forms.Form
[System.Windows.Forms.Label]$WelcomeLabel1 = $null
[System.Windows.Forms.Button]$WelcomeSubmitButton = $null
[System.Windows.Forms.TextBox]$MainUserInput = $null
[System.Windows.Forms.Button]$button1 = $null
function InitializeComponent
{
$WelcomeLabel1 = (New-Object -TypeName System.Windows.Forms.Label)
$WelcomeSubmitButton = (New-Object -TypeName System.Windows.Forms.Button)
$MainUserInput = (New-Object -TypeName System.Windows.Forms.TextBox)
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
$WelcomeSubmitButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]1383,[System.Int32]789))
$WelcomeSubmitButton.Name = [System.String]'WelcomeSubmitButton'
$WelcomeSubmitButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]180,[System.Int32]50))
$WelcomeSubmitButton.TabIndex = [System.Int32]1
$WelcomeSubmitButton.Text = [System.String]'Submit'
$WelcomeSubmitButton.UseVisualStyleBackColor = $true
$WelcomeSubmitButton.add_Click($WelcomeSubmitButton_Click)
#
#MainUserInput
#
$MainUserInput.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]16,[System.Int32]57))
$MainUserInput.Name = [System.String]'MainUserInput'
$MainUserInput.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]100,[System.Int32]20))
$MainUserInput.TabIndex = [System.Int32]2
#
#MainForm
#
$MainForm.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]1584,[System.Int32]861))
$MainForm.Controls.Add($MainUserInput)
$MainForm.Controls.Add($WelcomeSubmitButton)
$MainForm.Controls.Add($WelcomeLabel1)
$MainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
$MainForm.MaximizeBox = $false
$MainForm.Name = [System.String]'MainForm'
$MainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::Manual
$MainForm.Text = [System.String]'Anordium Audits'
$MainForm.ResumeLayout($false)
$MainForm.PerformLayout()
Add-Member -InputObject $MainForm -Name base -Value $base -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeLabel1 -Value $WelcomeLabel1 -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name WelcomeSubmitButton -Value $WelcomeSubmitButton -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name MainUserInput -Value $MainUserInput -MemberType NoteProperty
Add-Member -InputObject $MainForm -Name button1 -Value $button1 -MemberType NoteProperty
}
. InitializeComponent
