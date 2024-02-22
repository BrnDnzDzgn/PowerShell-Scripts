function findFile($fileName)
{

    #Get-ChildrenItem retrieves the items in the specified location
    #-Recurese not only list the items in the specified path but also to navigate into and list the items
    #in all subdirectories, recursively.
    #-Force allows to retrieve items that are normally hidden from the user
    $foundFiles = Get-ChildItem -Path C:\* -Recurse -Force -ErrorAction SilentlyContinue -Filter $fileName

    return $foundFiles
}

# Form configuration
$Form = New-Object System.Windows.Forms.Form
$Form.StartPosition = 'CenterScreen'
$Form.Size = New-Object System.Drawing.Size(230, 200) # Adjust size as needed

# FlowLayoutPanel configuration
$flowLayoutPanel = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutPanel.AutoScroll = $true

# Create labels
$labelMain = New-Object System.Windows.Forms.Label
$labelMain.Text = "Ulaşmak istediğiniz dosyayı giriniz. Örneğin: user.txt"
$labelMain.AutoSize = $true
$labelMain.Font = New-Object System.Drawing.Font($labelMain.Font.FontFamily, 11, [System.Drawing.FontStyle]::Bold)

$labelItems = New-Object System.Windows.Forms.Label
$labelItems.Text = "Bulunan dosyalar: "
$labelItems.AutoSize = $true

$labelMessage = New-Object System.Windows.Forms.Label
$labelMessage.Text = ""
$labelMessage.AutoSize = $true

# Create controls
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Width = 200

$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Width = 200
$comboBox.Text = "Seçiniz"

$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Dosyayı ara"

$buttonOpen = New-Object System.Windows.Forms.Button
$buttonOpen.Text = "Dosyayı aç"

# Add controls to FlowLayoutPanel
$flowLayoutPanel.Controls.Add($labelMain)
$flowLayoutPanel.Controls.Add($textBox)
$flowLayoutPanel.Controls.Add($labelItems)
$flowLayoutPanel.Controls.Add($comboBox)
$flowLayoutPanel.Controls.Add($buttonSearch)
$flowLayoutPanel.Controls.Add($buttonOpen)
$flowLayoutPanel.Controls.Add($labelMessage)

# Add FlowLayoutPanel to Form
$Form.Controls.Add($flowLayoutPanel)


# Handle the KeyPress event to make comboBox read-only
$comboBox.add_KeyPress({
    [System.Windows.Forms.KeyPressEventArgs]$e = $_
    # Suppress any key press
    $e.Handled = $true
})

#eventHandlers

$buttonSearch_event=
{

    $labelMessage.Text = "Dosyayı arıyor..."

    $Form.Refresh()
    
    $files = findFile -fileName $textBox.Text
    
    $comboBox.Items.Clear()

    if ($files.Count -gt 0) 
    {
        foreach ($file in $files) 
        {
            $comboBox.Items.Add($file)
        }

        # Update the label based on the number of files found
        if ($files.Count -gt 1) 
        {
            $labelMessage.Text = "$($files.Count) dosya bulundu."
        } 
        else 
        {
            $labelMessage.Text = "Bir dosya bulundu."
        }
    } 
    else 
    {
        $labelMessage.Text = "Dosya bulunamadı!"
    }

    $Form.Refresh()

}

$buttonOpen.Enabled = $false
$buttonSearch.Enabled = $false
$textBox_event=
{
    if ($textBox.Text -ne $null -and $textBox.Text -ne "" -and $textBox.Text -like "*?.?*") {
        $buttonSearch.Enabled = $true
    } else {
        $buttonSearch.Enabled = $false
    }
}

$comboBox_event=
{
    if($comboBox.SelectedItem -ne $null)
    {
        $buttonOpen.Enabled = $true
    }
    else{$buttonOpen.Enabled = $false}
}


$buttonOpen_event=
{

    if ($comboBox.SelectedItem -ne $null) 
    {
        $selectedFile = $comboBox.SelectedItem.FullName
        try 
        {
            Start-Process -FilePath $selectedFile
        } 
        catch 
        {
            [System.Windows.Forms.MessageBox]::Show("Unable to open file: `n$selectedFile", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    } 
}

$textBox.Add_TextChanged($textBox_event)

$buttonSearch.Add_Click($buttonSearch_event)

$comboBox.Add_SelectedIndexChanged($comboBox_event)

$buttonOpen.Add_Click($buttonOpen_event)

# Display the Form
$Form.ShowDialog()

#examples to try for
#redirectPolicy.js
#redirectPolicy.d.ts
#EmreTask3.ps1
