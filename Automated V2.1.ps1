Function ConvertHtmlTableto-Array {
    [CmdLetBinding()]
    Param(
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeLine=$true)]
        [string]$HtmlFile
    )
    $inputHtml = (Get-Content -Path "$HtmlFile")
    $htmlTableData = foreach($line in $inputHtml) {
        if($line.StartsWith('<table><colgroup><col /><col /><col /><col /></colgroup><tr><th>')) {
            $line.Replace('<table><colgroup><col /><col /><col /><col /></colgroup><tr><th>Hostname</th><th>IP Address</th><th>Location</th><th>Device Status</th>','').Replace('<td>','').Replace('</td>',';').Replace('offline','').Replace('online','').Replace('</tr></table>','') -split '</tr><tr class="">'
        }
    }
    $htmlTableData | ForEach-Object {
        $_= $_ -split ';'
        [PsCustomObject] [ordered] @{
        Hostname        = $_[0]
        "IP Address"    = $_[1]
        Location        = $_[2]
        "Device Status" = $_[3]
        }
    }
}
Function Send-ReportEmail {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$From = "",
        
        [Parameter(Mandatory=$false)]
        [string]$To = "",

        [Parameter(Mandatory=$false)]
        [string]$SmtpServer = "",

        [Parameter(Mandatory=$false)]
        [string]$Username = "",

        [Parameter(Mandatory=$false)]
        [string]$Password = ""
    ) 
    #Instantiate the .Net MailMessage class and define parameters for the Email
    $emailMessage = New-Object System.Net.Mail.MailMessage
    $emailMessage.From = New-Object System.Net.Mail.MailAddress $From,"Unresponsive IP Report" #Enter sender Email address
    $emailMessage.To.Add($To) # Enter recipient Email Address
    $emailMessage.Subject = "The Following Devices Are Offline or Unresponsive"
    $emailMessage.IsBodyHtml = $true
    $emailMessage.Body = @"
        $($emailReport | ConvertTo-Html -Head $emailHead)
"@

    #Instantiate the .Net SmtpClient class to authenticate and send the Email
    $emailSMTP = New-Object System.Net.Mail.SmtpClient
    $emailSMTP.Host = $SmtpServer #Enter SMTP Server
    $emailSMTP.EnableSsl = $true
    $emailSMTP.Credentials = New-Object System.Net.NetworkCredential ($Username, $Password); #Enter username, password (usually email address and password)
    $emailSMTP.Send($emailMessage)
}
Function Set-FullPath{
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [Switch]$Today,

        [Parameter(Mandatory=$false)]
        [Switch]$Yesterday,

        [Parameter(Mandatory=$false)]
        [string]$LogFolder = "$ENV:USERPROFILE\DeviceConnectivity"
    )
    if($Today) {
        $date = Get-Date
    }
    elseif($Yesterday) {
        $date = ((Get-Date).AddDays(-1))
    }
    $script:fullPath ='{0}\{1}\{2}\{3}'-f $LogFolder,$date.Year,((Get-Culture).DateTimeFormat.GetMonthName(($date).Month)),(($date).ToShortDateString() -split '/')[0]

}
Function Create-PreviousReport {
    [CmdLetBinding()]
    Param(
        [Parameter(Mandatory=$false)]
        [string]$PreviousReportPath = $fullPath
    )
    $script:previousReport = ((Get-ChildItem -Path $PreviousReportPath | Sort LastWriteTime | Select-Object -Last 1).FullName) | ConvertHtmlTableto-Array -ErrorAction SilentlyContinue
}
Function Create-CurrentReport {
    $retry = $true
    $script:currentReport = Import-CSV -Path "$ENV:USERPROFILE\Database.csv" | ForEach-Object {
    $pingTest = Test-Connection -ComputerName $_.IP -Quiet -Count 1
        [PsCustomObject] [ordered] @{
            Hostname        = $_.Hostname
            "IP Address"    = $_."IP"
            Location        = $_.Location
            "Device Status" = if(($pingTest) -eq $true) {"Online"} else {
                Start-Sleep 10
                if((Test-Connection -ComputerName $_.IP -Quiet -Count 1) -eq $false) {"Offline"} else {"Online"}
               
            }
        }
    }
    #Cycles through the current report and assigns each table row a class depending on value of the last cell in that row
    [xml]$html = $currentReport | ConvertTo-Html -Fragment
    for($i=1;$i -le $html.table.tr.Count-1;$i++) {
            $class = $html.CreateAttribute("class")
            if(($html.table.tr[$i].td[-1] -as [string]) -like"*Offline") {
                $class.Value= "offline"
                $html.table.tr[$i].Attributes.Append($class) | Out-Null
            }
            elseif(($html.table.tr[$i].td[-1] -as [string]) -like"*Online") {
                $class.Value = "online"
                $html.table.tr[$i].Attributes.Append($class) | Out-Null
            }
    }
    $script:body = $($html.InnerXml)
}
$exportHead = @"
    <Title>Device Connectivity Report</Title>
    <style>
    table, th, td{
    padding: 3px;
    border-style: solid;
    border-color: black;
    }
    table{
    border-width: 1px;
    border-collapse: collapse;
    }
    th{
    background-color: #b0afac;
    }
    th, td{
    border-width: 2px;
    }
    .online{
    background-color: green;
    }
    .offline{
    background-color: red;
    }
    </style>
"@
$emailHead = @"
    <style>
    table, th, td{
    padding: 3px;
    border-style: solid;
    border-color: black;
    }
    table{
    border-width: 1px;
    border-collapse: collapse;
    }
    th{
    background-color: #b0afac;
    }
    th, td{
    border-width: 2px;
    }
    </style>
"@
Set-FullPath -Today
# Creates Year->Month->Day Folder structure
if(!(Test-Path -Path $fullPath -PathType Container)) {
    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
}
Create-CurrentReport
Create-PreviousReport
if($previousReport -eq $null) {
    Set-FullPath -Yesterday
    Create-PreviousReport
}
# Compares the current report to the last report. If any differences are found, they will be sent by Email using Send-ReportEmail.
$Results = Compare-Object -ReferenceObject $currentReport -DifferenceObject $previousReport -Property Hostname, "IP Address", Location, "Device Status" 
if(($Results) -ne $null) {
    #$Results = Compare-Object -ReferenceObject $currentReport -DifferenceObject $previousReport -Property Hostname, "IP Address", Location, "Device Status" 
    $emailReport = Foreach($R in $Results | Where-Object{$_.SideIndicator -eq "<="}) {
        [PsCustomObject] [Ordered] @{
                Hostname = $R.Hostname
                "IP Address" = $R."IP Address"
                Location = $R.Location
                "Current Status" = $R."Device Status"
                "Previous Status" = if($R.'Device Status' -eq "Online"){"Offline"}elseif($R.'Device Status' -ne "Online"){"Online"}
        }
    }
    if($emailReport -ne $null) {
        Send-ReportEmail
    }
}
Set-FullPath -Today
ConvertTo-Html -Head $exportHead -Body $body | Out-File -FilePath "$fullPath\Unresponsive_IP_Addresses_$(Get-Date -Format "HH-mm-ss").html" -Force