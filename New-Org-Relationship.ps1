Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement; Get-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName slusebrink@titaniasolutionsgroup.com
New-OrganizationRelationship -Name "Organization Name Ltd." -DomainNames "your_domain.com","other_domain_to_associate.com" -FreeBusyAccessEnabled $true -FreeBusyAccessLevel LimitedDetails