
#From: http://www.toddklindt.com/blog/Lists/Posts/Post.aspx?ID=368

Import-module servermanager]
Add-WindowsFeature AD-Domain-Services

Install-addsforest -domainname qqontoso.com -safemodeadministratorpassword (convertto-securestring "Admin4Domain!" -asplaintext -force) -domainmode Win2012 -domainnetbiosname contoso -forestmode Win2012
Add-windowsfeature rsat-adds -includeallsubfeature
Set-ADDefaultDomainPasswordPolicy qqontoso.com -ComplexityEnabled $false -MaxPasswordAge "3650" -PasswordHistoryCount 0 -MinPasswordAge 0
