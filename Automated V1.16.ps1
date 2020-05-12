Function Send-ReportEmail
{
    #Define the email header formatting using CSS
    $emailHeader = @"
    <style>
    TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
    TH {border-width: 2px; padding: 3px; border-style: solid; border-color: black; background-color: #b0afac;}
    TD {border-width: 2px; padding: 3px; border-style: solid; border-color: black;}
    </style>
"@
    #Instantiate the .Net MailMessage class and define parameters for the Email
    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = New-Object System.Net.Mail.MailAddress "some@email.com","Unresponsive IP Report" #Enter sender Email address
    $emailMessage.To.Add("some@email.com") # Enter recipient Email Address
    $emailMessage.Subject = "The Following Devices Are Offline or Unresponsive"
    $emailMessage.IsBodyHtml = $true
    $emailMessage.Body = @"
        $($report | ConvertTo-Html -Head $emailHeader)
"@

    #Instantiate the .Net SmtpClient class to authenticate and send the Email
    $emailSMTP = New-Object System.Net.Mail.SmtpClient
    $emailSMTP.Host = "smtp.server" #Enter SMTP Server
    $emailSMTP.EnableSsl = $true
    $emailSMTP.Credentials = New-Object System.Net.NetworkCredential ("enter-username", "enter-password"); #Enter username, password (usually email address and password)
    $emailSMTP.Send($emailMessage)
}

# Path to CSV containing IP Address information
$inputFile = "$ENV:USERPROFILE\Database.csv"
$date = Get-Date
#Path to directory where CSV output files will be stored
$logPath = "$ENV:USERPROFILE\Folder Path"
$fullPath = "$logPath\$(($date).Year)\$((Get-Culture).DateTimeFormat.GetMonthName(($date).Month))\$(Get-Date -Format "dd")"
$lastReport = (Get-ChildItem -Path $fullPath | Sort LastWriteTime | Select-Object -Last 1).FullName

# Creates Year->Month->Day Folder structure
if(!(Test-Path -Path $fullPath -PathType Container))
{
    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
}

# Cycles through IP's in .CSV file and tests if each one responds to ping
$report = Import-Csv -Path $inputFile | ForEach-Object {

    if(!(Test-Connection -ComputerName $_.IP -Quiet -Count 1))
    {
        New-Object PsObject -Property @{
            Hostname = $_.Hostname
            "IP Address" = $_.IP
            Location = $_.Location
            
        }
    }
}

if($report -ne $null)
{
    #Imports the last CSV report for comparison
    $lastReport = Import-Csv -Path $lastReport

    [System.Windows.Forms.MessageBox]::Show("Script successfully completed at $(Get-Date -Format "HH:mm:ss"). Some devices are offline or not responding.",'Device Connectivity','OK','Warning') | Out-Null

    #Exports the CSV to custom path
    $report | Export-Csv -Path "$fullPath\Unresponsive_IP_Addresses_$(Get-Date -Format "HH-mm-ss").csv" -Force -NoTypeInformation

    # Compares the current report to the last report. If they are different the report will be sent using Send-ReportEmail
    if((Compare-Object -ReferenceObject $report -DifferenceObject $lastReport) -ne $null) {
        Send-ReportEmail
    }
}
else
{
    [System.Windows.Forms.MessageBox]::Show("Script successfully completed at $(Get-Date -Format "HH:mm:ss"). All devices are online.",'Device Connectivity','OK','Information') | Out-Null
}