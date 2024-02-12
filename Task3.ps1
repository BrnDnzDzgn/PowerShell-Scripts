function choose-location
{
# Form Configuration

$Form1 = New-Object System.Windows.Forms.Form
$Form1.StartPosition = 'CenterScreen'
$Form1.MinimumSize = New-Object System.Drawing.Size(500, 200)
#$Form1.MaximumSize = New-Object System.Drawing.Size(3000, 550)
$Form1.ControlBox = $false

# Create Labels
$labelMain = New-Object System.Windows.Forms.Label
$labelMain.Text = "Kuruluma başlamadan önce lütfen konum(Ankara/İstanbul) ve konuma bağlı birim adını seçiniz."
$labelMain.Font = New-Object System.Drawing.Font($labelMain.Font.FontFamily, 11, [System.Drawing.FontStyle]::Bold)
$labelMain.Dock = 'Fill'
$labelMain.Margin = New-Object System.Windows.Forms.Padding(0, 20, 0, 0)

$labelLocation = New-Object System.Windows.Forms.Label
$labelLocation.Text = "Konum seçiniz :"
#$labelLocation.Dock = 'Fill'

$labelUnit = New-Object System.Windows.Forms.Label
$labelUnit.Text = "Birim seçiniz    :"

$labelInstallationType = New-Object System.Windows.Forms.Label
$labelInstallationType.Text ="Kurulum Tipi     :"
#$labelInstallationType.Dock = 'Fill'

# Create Controls
$comboBox1 = New-Object System.Windows.Forms.ComboBox
$comboBox1.Width = 200
$comboBox1.Dock = 'Fill'

$locationNames = @("Ankara","İstanbul")
$comboBox1.Text="Seçiniz"
foreach($location in $locationNames)
{
    $comboBox1.Items.add($location)
}

# Handle the KeyPress event to make comboBox1 read-only
$comboBox1.add_KeyPress({
    [System.Windows.Forms.KeyPressEventArgs]$e = $_
    # Suppress any key press
    $e.Handled = $true
})

$comboBox2 = New-Object System.Windows.Forms.ComboBox
$comboBox2.Width = 200
$comboBox2.Dock = 'Fill'

# Handle the KeyPress event to make comboBox2 read-only
$comboBox2.add_KeyPress({
    [System.Windows.Forms.KeyPressEventArgs]$e = $_
    # Suppress any key press
    $e.Handled = $true
})

$combobox2_event=
{
    if($comboBox1.SelectedItem -eq "Ankara")
    {
        $sorgu = "select * from birimler where lokasyon = 'AN'"
        $birimler =Get-Query -SQLText $sorgu
        $comboBox2.Items.Clear()
        $comboBox2.Text="Seçiniz"
        foreach($birim in $birimler)
        {
            $comboBox2.Items.add($birim.Kisa_ad.Trim())
        }
    }
    else
    {
        $sorgu = "select * from birimler where lokasyon = 'IS'"
        $birimler =Get-Query -SQLText $sorgu
        $comboBox2.Items.Clear()
        $comboBox2.Text="Seçiniz"
        foreach($birim in $birimler)
        {
            $comboBox2.Items.add($birim.Kisa_ad.Trim())
        }
    }       
}

$Button = New-Object System.Windows.Forms.Button
$Button.Text = "Devam"
$Button.Dock = 'Fill'

$checkbox1 = New-Object System.Windows.Forms.CheckBox
$checkbox1.Dock = 'Fill'
$checkbox1.Text = "İlk kurulum (Tüm Diskleri Formatlar)"
$checkbox1.Checked = $false

$checkbox2 = New-Object System.Windows.Forms.CheckBox
$checkbox2.Dock = 'Fill'
$checkbox2.Text = "Yeniden kurulum (Sadece İşletim sistemi diskini formatlar)"
$checkbox2.Checked = $false

# Create the TableLayoutPanel
$TableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$TableLayoutPanel.RowCount = 7
$TableLayoutPanel.ColumnCount = 2
$TableLayoutPanel.AutoSize = $true
$TableLayoutPanel.AutoSizeMode = 'GrowAndShrink'
$TableLayoutPanel.Dock = 'Fill'

# Set the column styles
$TableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$TableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))

$TableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 50)))

for ($i = 0; $i -lt $TableLayoutPanel.RowCount; $i++) {
    $TableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 40)))
}

# Add controls to the TableLayoutPanel, setting them in the appropriate row and column
$TableLayoutPanel.Controls.Add($labelMain, 0, 0)  # Span across both columns
$TableLayoutPanel.SetColumnSpan($labelMain, 2)
$TableLayoutPanel.SetRowSpan($labelMain, 2)
$TableLayoutPanel.Controls.Add($labelLocation, 0, 2)
$TableLayoutPanel.Controls.Add($comboBox1, 1, 2)
$TableLayoutPanel.Controls.Add($labelUnit, 0, 3)
$TableLayoutPanel.Controls.Add($comboBox2, 1, 3)
#$TableLayoutPanel.Controls.Add($labelComputerName, 0, 4)
#$TableLayoutPanel.Controls.Add($textBox1, 1, 4)
$TableLayoutPanel.Controls.Add($labelInstallationType, 0, 4)
$TableLayoutPanel.Controls.Add($checkbox1, 1, 4)
$TableLayoutPanel.Controls.Add($checkbox2, 1, 5)

$TableLayoutPanel.Controls.Add($Button, 0, 6)  # Add button control to the last row
$TableLayoutPanel.SetColumnSpan($Button, 2)  # Span across both columns

# Assume $combobox2_event is a previously defined script block
$comboBox1.add_TextChanged($combobox2_event)

# Add the TableLayoutPanel to the form
$Form1.Controls.Add($TableLayoutPanel)

# Event handler for when checkbox1 is checked or unchecked
$checkbox1_CheckedChanged = {
    if ($checkbox1.Checked) {
        $checkbox2.Checked = $false
    }
}

# Event handler for when checkbox2 is checked or unchecked
$checkbox2_CheckedChanged = {
    if ($checkbox2.Checked) {
        $checkbox1.Checked = $false
    }
}

$checkbox1.add_CheckedChanged($checkbox1_CheckedChanged)
$checkbox2.add_CheckedChanged($checkbox2_CheckedChanged)

$eventHandler1 =
{
    $location = $comboBox1.SelectedItem.ToString();
    $secilenbirim = $comboBox2.SelectedItem.ToString();
    #$computerName = $textBox1.Text.ToString();

    if($checkbox1.Checked)
    {
        $InstallationType = "İlk Kurulum"
    }else{$InstallationType = "Yeniden Kurulum"}

    $Form1.Hide()

    warning-box -location0 $location -domain0 $secilenbirim -InstallationType $InstallationType -FormToClose $Form1;

    
}

# Event handler to update the enabled state of the Devam button
function Update-DevamButtonState {
    $isLocationSelected = $comboBox1.SelectedItem -ne $null -and $comboBox1.SelectedItem.ToString() -ne "Seçiniz"
    $isUnitSelected = $comboBox2.SelectedItem -ne $null -and $comboBox2.SelectedItem.ToString() -ne "Seçiniz"
    $isInstallationTypeSelected = $checkbox1.Checked -or $checkbox2.Checked

    $Button.Enabled = $isLocationSelected -and $isUnitSelected -and $isInstallationTypeSelected
}

# Assign the event handler to the relevant events
$comboBox1.add_SelectedIndexChanged({ Update-DevamButtonState })
$comboBox2.add_SelectedIndexChanged({ Update-DevamButtonState })
$checkbox1.add_CheckedChanged({ Update-DevamButtonState })
$checkbox2.add_CheckedChanged({ Update-DevamButtonState })

# Initialize the button state
Update-DevamButtonState

$Button.Add_Click($eventHandler1)

[void]$Form1.showdialog()
}


function warning-box ($location0, $domain0, $InstallationType, $FormToClose)
{

# Form Configuration
$Form2 = New-Object System.Windows.Forms.Form
$Form2.StartPosition = 'CenterScreen'
$Form2.ControlBox = $false

# Create Labels
$valueLocation = New-Object System.Windows.Forms.Label
$valueLocation.Text = $location0
$valueLocation.Dock = 'Fill'

$valueUnit = New-Object System.Windows.Forms.Label
$valueUnit.Text = $domain0
$valueUnit.Dock = 'Fill'

$valueComputerName = New-Object System.Windows.Forms.Label
$valueComputerName.Text = ""
$valueComputerName.Dock = 'Fill'

$valueInstallationType = New-Object System.Windows.Forms.Label
$valueInstallationType.Text = $InstallationType
$valueInstallationType.Dock = 'Fill'

$labelMain = New-Object System.Windows.Forms.Label
$labelMain.Text = "Girdiğiniz bilgiler aşağıdaki gibidir.`n`rOnaylıyor musunuz?"
$labelMain.Font = New-Object System.Drawing.Font($labelMain.Font.FontFamily, 10, [System.Drawing.FontStyle]::Bold)
$labelMain.Dock = 'Fill'
$labelMain.Margin = New-Object System.Windows.Forms.Padding(0, 20, 0, 0)

$labelLocation = New-Object System.Windows.Forms.Label
$labelLocation.Text = "Teşkilat :"
#$labelLocation.Dock = 'Fill'

$labelUnit = New-Object System.Windows.Forms.Label
$labelUnit.Text = "Birim :"
#$labelUnit.Dock = 'Fill'

$labelComputerName = New-Object System.Windows.Forms.Label
$labelComputerName.Text ="Bilgisayar Adı :"
#$labelComputerName.Dock = 'Fill'

$labelInstallationType = New-Object System.Windows.Forms.Label
$labelInstallationType.Text ="Kurulum Tipi :"
#$labelInstallationType.Dock = 'Fill'

# Create Controls
$ButtonBack = New-Object System.Windows.Forms.Button
$ButtonBack.Text = "Geri Dön"
#$Button.Width = 100
#$Button.Height = 200
$ButtonBack.Dock = 'Fill'

$ButtonConfirm = New-Object System.Windows.Forms.Button
$ButtonConfirm.Text = "Onaylıyorum"
$ButtonConfirm.Dock = 'Fill'

# Create the TableLayoutPanel
$TableLayoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
$TableLayoutPanel.RowCount = 6
$TableLayoutPanel.ColumnCount = 2
$TableLayoutPanel.AutoSize = $true
$TableLayoutPanel.AutoSizeMode = 'GrowAndShrink'
$TableLayoutPanel.Dock = 'Fill'

# Set the column styles
$TableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::AutoSize)))
$TableLayoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))

$TableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 60)))
for ($i = 1; $i -lt $TableLayoutPanel.RowCount; $i++) {
    $TableLayoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::Percent, 40)))
}

# Add controls to the TableLayoutPanel, setting them in the appropriate row and column
$TableLayoutPanel.Controls.Add($labelMain, 0, 0)  # Span across both columns
$TableLayoutPanel.SetColumnSpan($labelMain, 2)

$TableLayoutPanel.Controls.Add($labelLocation, 0, 1)
$TableLayoutPanel.Controls.Add($valueLocation, 1, 1)

$TableLayoutPanel.Controls.Add($labelUnit, 0, 2)
$TableLayoutPanel.Controls.Add($valueUnit, 1, 2)

$TableLayoutPanel.Controls.Add($labelComputerName, 0, 3)
$TableLayoutPanel.Controls.Add($valueComputerName, 1, 3)

$TableLayoutPanel.Controls.Add($labelInstallationType, 0, 4)
$TableLayoutPanel.Controls.Add($valueInstallationType, 1, 4)

$TableLayoutPanel.Controls.Add($ButtonBack, 0, 5)  
$TableLayoutPanel.Controls.Add($ButtonConfirm, 1, 5)

# Add the TableLayoutPanel to the form
$Form2.Controls.Add($TableLayoutPanel)

$buttonPressCount = 0

$eventHandlerConfirm =
{   
    $global:buttonPressCount++

    # Check if the button has been pressed twice
    if ($global:buttonPressCount -eq 2) 
    {
        $ButtonConfirm.Text = "Onaylıyorum"
        $Form2.Close()
        $global:buttonPressCount = 0
    } 
    else 
    {
        $ButtonBack.Visible = $false
        $ButtonConfirm.Text = "Çıkış"
        $returnedComputerName = Find-Hostname -location1 $location0 -domain1 $domain0
        $valueComputerName.Text = $returnedComputerName
    }
};

$eventHandlerBack =
{
    $FormToClose.Show()
    $this.FindForm().Close()
    $global:buttonPressCount = 0
}

$ButtonBack.Add_Click($eventHandlerBack)

$ButtonConfirm.Add_Click($eventHandlerConfirm)

$Form2.showdialog()
}


Function Get-Query([string]$SQLText)

{
    $ConnectionString = "Server=WIN-19\SQLEXPRESS;Database=DAB_Kurulum;Trusted_Connection=yes;"

    $sqlConnection = new-object System.Data.SqlClient.SqlConnection $ConnectionString

    $sqlConnection.Open()

    #Create a command object

    $sqlCommand = $sqlConnection.CreateCommand()

    $sqlCommand.CommandText = $SQLText

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $sqlcommand

    $dataset = New-Object System.Data.DataSet

    $adapter.Fill($dataSet) | out-null

    # Close the database connection

    $sqlConnection.Close()

    $dataTable = new-object "System.Data.DataTable" "SQL"

    $dataTable = $dataSet.Tables[0]

    Return $DataTable

}


Function Set-Query([string]$SQLText)

{

    $ConnectionString = "Server=localhost\sqlexpress;Database=DAB_Kurulum;Trusted_Connection=yes;"

    $sqlConnection = new-object System.Data.SqlClient.SqlConnection $ConnectionString

    $sqlConnection.Open()

    #Create a command object

    $sqlCommand = $sqlConnection.CreateCommand()

    $sqlCommand.CommandText = $SQLText

    $sqlCommand.ExecuteReader()

    # Close the database connection

    $sqlConnection.Close()

       

}


Function Find-Hostname ($location1, $domain1)

{
$macaddress = (Get-WMIObject -Class Win32_NetworkAdapterConfiguration | where ipenabled -EQ $true | where dhcpenabled -EQ $true | where defaultipgateway -ne $null).MacAddress

$query = "select * from hostname where mac = '$macaddress'"
$getmacfromsql = Get-Query $query

if($getmacfromsql.mac -eq $macaddress)
{
    if ($location1 -eq "Ankara") {$a = "AN"}
    elseif($location1 -eq "İstanbul") {$a = "IS"}

    $c = $a + $domain1

    if ($getmacfromsql.hostname -match $c)
    {
        $osdcomputername = $getmacfromsql.hostname
    } else

    {

        ##delete mac

        $removequery = "delete from hostname where mac = '$macaddress'"

        Set-Query -SQLText $removequery

 

        if ($location1 -eq "Ankara")

        {$a = "AN"} elseif ($location1 -eq "İstanbul") {$a = "IS"}

        $c = $a + $domain1

        $d = "select * from hostname where hostname like '$c%' order by hostname"

        $e=Get-Query -SQLText $d

        if ($e.count -eq 0) {$g=1}

        elseif ($e.count -eq $null) {$g=2} 

        else 
        {
        $f = $e[$e.Count-1].Hostname.trim().tostring()
        $g =[int]$f.Substring($f.Length-2,2)+1 
        }

    

        $osdcomputername = $c + ('{0:d2}' -f $g).ToString()

 

        $insertcmd = "insert into hostname (hostname,mac) values ('$osdcomputername','$macaddress')"

        Set-Query -SQLText $insertcmd

    }

} else

{
    if ($location1 -eq "Ankara")

    {$a = "AN"} elseif ($location1 -eq "İstanbul") {$a = "IS"}

    $c = $a + $domain1

    $d = "select * from hostname where hostname like '$c%' order by hostname"

    $e=Get-Query -SQLText $d

 

    if ($e.count -eq 0) {$g=1}

    elseif ($e.count -eq $null) {$g=2} 
    
    else 
    {
        $f = $e[$e.Count-1].Hostname.trim().tostring()
        $g =[int]$f.Substring($f.Length-2,2)+1 
    }

    

    $osdcomputername = $c + ('{0:d2}' -f $g).ToString()

 

    $insertcmd = "insert into hostname (mac,hostname) values ('$macaddress','$osdcomputername')"

    Set-Query -SQLText $insertcmd
}

$TS1 = New-Object -ComObject "Microsoft.SMS.TSEnvironment"
$NewComputerName = $osdcomputername
$TS1.Value("OSDComputername") = $NewComputerName

return $osdcomputername
}


choose-location
