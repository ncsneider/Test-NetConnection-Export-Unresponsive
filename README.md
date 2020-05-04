# Test-NetConnection-Export-Unresponsive
This script is designed to ping a list of IP addresses referencing a .csv file and output another .csv file highlighting the IP's that 
didn't respond. Eventually want to have this function loop every hour and send out notificaitons based on the unresponsive IP's addresses but need to work through these Resolve-DnsName errors before progressing to the automation aspect.

*disclaimer* I did not write a majority of this script but have tweaked it and am the one interested in the progression. Most if not all
credit should go to /u/TheD4rkSide on reddit as he kicked this thing off!

As of 5/4/20 I'm currently struggling to understand why I'm getting this string of errors:

Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:313 char:74
+ ... ctionResult.DNSOnlyRecords = @( Resolve-DnsName $ComputerName -DnsOnl ...
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
 
Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:314 char:79
+ ... Result.LLMNRNetbiosRecords = @( Resolve-DnsName $ComputerName -LlmnrN ...
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
 
Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:315 char:78
+ ... nResult.BasicNameResolution = @(Resolve-DnsName $ComputerName -ErrorA ...
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
 
Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:313 char:74
 ... ctionResult.DNSOnlyRecords = @( Resolve-DnsName $ComputerName -DnsOnl ...
                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
 
Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:314 char:79
+ ... Result.LLMNRNetbiosRecords = @( Resolve-DnsName $ComputerName -LlmnrN ...
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
 
Resolve-DnsName : Cannot validate argument on parameter 'Name'. The argument is null or empty. Provide an argument that is not null or empty, and then try 
the command again.
At C:\Windows\system32\WindowsPowerShell\v1.0\Modules\NetTCPIP\Test-NetConnection.psm1:315 char:78
+ ... nResult.BasicNameResolution = @(Resolve-DnsName $ComputerName -ErrorA ...
+                                                     ~~~~~~~~~~~~~
    + CategoryInfo          : InvalidData: (:) [Resolve-DnsName], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationError,Microsoft.DnsClient.Commands.ResolveDnsName
    
  
 
