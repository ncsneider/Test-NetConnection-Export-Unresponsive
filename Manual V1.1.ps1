[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

Function SaveLoad-File{
    $SaveLoadFileDialog = $dialogBoxType
    $SaveLoadFileDialog.filter = “CSV files (*.csv)|*.csv|All files (*.*)|*.*”
    $SaveLoadFileDialog.ShowDialog() | Out-Null
    $SaveLoadFileDialog.FileName
}

Function Test-DeviceConnectivity
{
    $report = @()
    [System.Windows.Forms.MessageBox]::Show('Load CSV containing Hostname, IP and Location entries.', 'Choose File') | Out-Null
    $dialogBoxType = New-Object System.Windows.Forms.OpenFileDialog
    $inputFile = SaveLoad-File
    $ipAddresses = Import-CSV $inputFile

   # Cycles through IP's in .CSV file and
    $report = Import-Csv -Path $inputFile | ForEach-Object {

    if(!(test-connection -computername $_.IP -quiet -count 1))
    {
        New-Object PsObject -Property @{
            Hostname = $_.Hostname
            "IP Address" = $_.IP
            Location = $_.Location
            }
        }

    }
        [System.Windows.Forms.MessageBox]::Show('Select where to save the compiled CSV report.', 'Choose File') | Out-Null
        $dialogBoxType = New-Object System.Windows.Forms.SaveFileDialog
        $exportFile = SaveLoad-File
        $report | Export-Csv -Path $exportFile -Force -NoTypeInformation
        Read-Host -Prompt "Processing finished, press Enter to exit"
}

Test-DeviceConnectivity
