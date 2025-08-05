$DomainName = $env:DOMAIN_NAME
$SafeModePassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools
Install-ADDSForest 
    -DomainName $DomainName 
    -SafeModeAdministratorPassword $SafeModePassword 
    -InstallDNS
    -Force