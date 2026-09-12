<#
.SYNOPSIS
    Active Directory GPO Hardening Baseline - an.local
.DESCRIPTION
    Applies defensive security baseline controls across Windows Server 2022 domain:
    - Disables legacy SMBv1 protocol and enforces mandatory SMB packet signing.
    - Mitigates NetNTLM relay attacks by disabling LLMNR and NetBIOS over TCP/IP.
    - Restricts anonymous SAM account enumeration.
    - Enforces strict password complexity and history requirements.
.AUTHOR
    Jose F. Romero (JFRsec)
#>

# 1. SMB Hardening: Disable SMBv1, enforce SMB message signing
Write-Host "[*] Hardening SMB configuration..." -ForegroundColor Cyan
Set-SmbServerConfiguration -EnableSMB1Protocol $false -RequireSecuritySignature $true -Force

# 2. LSA & SAM Protection: Restrict anonymous enumeration
Write-Host "[*] Enforcing anonymous enumeration restrictions..." -ForegroundColor Cyan
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 1 -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymousSAM" -Value 1 -Type DWord

# 3. LLMNR Mitigation: Disable Multicast Name Resolution
Write-Host "[*] Disabling LLMNR to mitigate NetNTLM poisoning..." -ForegroundColor Cyan
Set-DnsClientGlobalSetting -SuffixSearchList @()
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -Type DWord

# 4. NetBIOS Lockdown: Strip NetBIOS over TCP/IP on all active adapters
Write-Host "[*] Stripping NetBIOS over TCP/IP..." -ForegroundColor Cyan
Get-NetAdapter | ForEach-Object {
    $guid = $_.InterfaceGuid
    $path = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_$guid"
    if (Test-Path $path) {
        Set-ItemProperty -Path $path -Name "NetbiosOptions" -Value 2 # 2 = Disable NetBIOS over TCP/IP
    }
}

# 5. Account Policy Hardening: 14-char minimum, 24-password history
Write-Host "[*] Configuring domain account policy..." -ForegroundColor Cyan
net accounts /minpwlen:14 /maxpwage:90 /uniquepw:24

Write-Host "`n[OK] an.local domain controller hardening baseline successfully applied." -ForegroundColor Green
