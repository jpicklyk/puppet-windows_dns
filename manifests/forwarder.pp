define windows_dns::forwarder (
  $ensure        = present, # add or remove forwarders
  $ipaddress     = $ipaddress, # Array of ip addresses
  $enablereorder = true,) {
  validate_re($ensure, '^(present|absent)$', 'Valid values for ensure are \'present\' or \'absent\'')
  if ($kernelversion =~ /^6\.2|^6\.3/) {
    if ($enablereorder) {
      $flag = '$true'
    } else {
      $flag = '$false'
    }
  
    if ($ensure == 'present') {
      exec { "Set DNS Forwarder":
        command  => "Set-DnsServerForwarder -IPAddress ${ipaddress} -EnableReordering $flag",
        onlyif   => "\$forwarder = Get-DnsServerForwarder;if( @(Compare-Object $ipaddress \$forwarder.IPAddress | where {\$_.sideindicator -eq '<='}).Count -ige 1){}else{exit 1}",
        provider => powershell,
      }
  
    } else {
      exec { "Remove DNS Forwarder":
        command  => "Remove-DnsServerForwarder -IPAddress ${ipaddress} -Force",
        onlyif   => "\$forwarder = Get-DnsServerForwarder;if( @(Compare-Object $ipaddress \$forwarder.IPAddress | where {\$_.sideindicator -eq '<='}).Count -ige 1){exit 1}else{}",
        provider => powershell,
      }
  
    }
  
  } else {
    fail('Only Windows 2012 and 2012 R2 are currently supported')
  }
}