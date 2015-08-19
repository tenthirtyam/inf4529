<#

.NOTES

Based on Brian Graf’s RenewVMCACertificates script

Add this script to your vSphere PowerActions repository with a "Cluster" [Target Type]. .

To renew certificates, right-click on the target cluster, select [PowerCLI] > [Execute Script] and select this script.

#>

param
(
   [Parameter(Mandatory=$true)]
   [VMware.VimAutomation.ViCore.Types.V1.Inventory.Cluster]
   $vParam
);

$Cluster = $vParam

if ($Cluster -ne $null) {
                  $Hosts = $Cluster | Get-VMHost
            }
            if ($Vmhost -ne $null) {
                  $Hosts = $Vmhost
            }

            foreach ($esx in $Hosts) {
                  if ($esx.ConnectionState -eq "Connected" -and $esx.PowerState -eq "PoweredOn") {
                        $hostid = $esx | Get-View
                        Write-Host "Renewing Certificate on $($esx.name)" -ForegroundColor Green
                        $hostParam = New-Object VMware.Vim.ManagedObjectReference[] (1)
                        $hostParam[0] = New-Object VMware.Vim.ManagedObjectReference
                        $hostParam[0].value = $hostid.moref.value
                        $hostParam[0].type = 'HostSystem'
                        $_this = Get-View -Id 'CertificateManager-certificateManager'
                        $mytask = $_this.CertMgrRefreshCertificates_Task($hostParam)
                        $task = Get-Task -Id $mytask | select Id, Name, State
                        Write-Host "Task = $($task.Id), Name = $($task.Name), State = $($task.State)"
                        Write-Host ""
                  } else {
                  Write-Warning "$($esx.Name) is either not Powered On or is Not Connected and will not have it's certificate refreshed"
                  Continue
                  }
            }
