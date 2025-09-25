function Get-MAPasswordAgeEntra-TEST1 {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (
        [Parameter(ParameterSetName = 'Top')]
        [int]$Top,

        [Parameter(ParameterSetName = 'Id')]
        [string]$Id,

        [Parameter(ParameterSetName = 'UPN')]
        [string]$UserPrincipalName
    )

    if (-not (Get-MgContext)) {
        throw "Connection to Entra not found. Connect using Connect-MgGraph."
    }

    switch ($PSCmdlet.ParameterSetName) {
        'All' {
            $users = Get-MgUser -All -Property Id,DisplayName,UserPrincipalName,Mail,LastPasswordChangeDateTime
        }
        'Top' {
            $users = Get-MgUser -Top $Top -Property Id,DisplayName,UserPrincipalName,Mail,LastPasswordChangeDateTime
        }
        'Id' {
            $users = Get-MgUser -UserId $Id -Property Id,DisplayName,UserPrincipalName,Mail,LastPasswordChangeDateTime
        }
        'UPN' {
            $users = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -Property Id,DisplayName,UserPrincipalName,Mail,LastPasswordChangeDateTime
        }
    }

    $users | Select-Object Id, DisplayName, UserPrincipalName, Mail, @{
        Name='PasswordAge';
        Expression={
            if ($_.LastPasswordChangeDateTime) {
                ((Get-Date) - $_.LastPasswordChangeDateTime).Days
            } else {
                'Never Changed'
            }
        }
    }, @{
        Name='ForceChangeNextLogin';
        Expression={
            if ($_.LastPasswordChangeDateTime) {
                $passwordAge = ((Get-Date) - $_.LastPasswordChangeDateTime).Days
                if ($passwordAge -gt 15000) { $true } else { $false }
            } else {
                $false
            }
        }
    }
}