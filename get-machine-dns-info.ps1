#!/usr/bin/env pwsh
# Get machines that belong to a role and get dns info on them
# This was actually used built on pwsh on Linux

$ErrorActionPreference = "Stop";

$octopusURL = "<YOURURL>"
$octopusAPIKey = "<YOURAPIKEY>"
$header = @{ "X-Octopus-ApiKey" = $octopusAPIKey }
$spaceName = "<YOURSPACE>"
$userRoleName = "<YOURROLE>"

function get-dns-info($name, $uri){
  write-host "================================================="
  write-host $name
  $fqdn = ($uri).split(':')[1] -replace "/",''
  write-host "host fqdn: $fqdn"
  write-host "uri: $uri"
  $forward = $(host $fqdn)
  write-host "forward: $forward"
  $ip = $(dig +short $fqdn)
  write-host "ip: $ip"
  $names=$(dig +short -x $ip)  # reverse dns names (ptrs)
  write-host "reverse: $names"
}

$userRole = (Invoke-RestMethod -Method Get -Uri "$octopusURL/api/userroles/all" -Headers $header) | Where-Object {$_.Name -eq $userRoleName}

$machines = Invoke-RestMethod -Method Get -Uri "$octopusURL/api/$($space.Id)/machines/all" -Headers $header

$machineNames = @()
foreach ($machine in $machines)
{
  if ( $machine | Where-Object Roles -contains IFP){
    get-dns-info $machine.Name $machine.Uri
  }
}
