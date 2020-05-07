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

    $report = foreach($ip in $ipAddresses)
    {

        if((Test-NetConnection -ComputerName $ip.IP).PingSucceeded -eq $false)
        {
            Start-Sleep 10
            if((Test-NetConnection -ComputerName $ip.IP).PingSucceeded -eq $false)
            {
                $newRow = New-Object PsObject -Property @{
                    Hostname = $ip.Hostname
                    "IP Address" = $ip.IP
                    Location = $ip.Location
                }

                Write-Output $newRow
            }

        }
    }
        [System.Windows.Forms.MessageBox]::Show('Select where to save the compiled CSV report.', 'Choose File') | Out-Null
        $dialogBoxType = New-Object System.Windows.Forms.SaveFileDialog
        $exportFile = SaveLoad-File
        $report | Export-Csv -Path $exportFile -Force -NoClobber -NoTypeInformation
        Read-Host -Prompt "Processing finished, press Enter to exit"
}

Test-DeviceConnectivity