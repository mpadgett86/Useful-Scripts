# This script will enforce SC-20 Secure Name / Address Resolution Service (Authoritative Source)
# DNS will be statically set to Google's 8.8.8.8 primary, 8.8.4.4 secondary for IPv4 and IPv6

# IPv4
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses ("8.8.8.8", "8.8.4.4")

# IPv6
Set-DnsClientServerAddress -InterfaceIndex 2 -ServerAddresses ("2001:4860:4860:0:0:0:0:8888", "2001:4860:4860:0:0:0:0:8844")