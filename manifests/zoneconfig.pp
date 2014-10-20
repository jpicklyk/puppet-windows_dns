define windows_dns::zoneconfig (
  $zonename       = undef,
  $dynamicupdate  = 2,
  
) {
  
  validate_string($zonename)
  validate_re($dynamicupdate, '^[0-2]$', '$dynamicupdate must be a value of 0, 1, or 2')
  
  $type = $dynamicupdate ? {
    1       => 'NonsecureAndSecure',
    2       => 'Secure',
    default => 'None'
  }
  
  if ($kernel_ver =~ /^6\.2|^6\.3/) {
    
    exec { "Set dynamic update":
      command  => "Set-DnsServerPrimaryZone -Name '${zonename}' -DynamicUpdate '${type}'",
      onlyif   => "\$zone = Get-WmiObject -Namespace 'root\\MicrosoftDNS' -Class 'MicrosoftDNS_Server';if(\$zone.AllowUpdate -ne ${dynamicupdate}){} else{exit 1}",
      provider => powershell,
    }
   
  } else {
    fail('Only Windows 2012 and 2012 R2 are currently supported')
  }
}