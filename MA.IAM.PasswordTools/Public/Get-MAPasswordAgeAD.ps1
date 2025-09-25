function Get-MAPasswordAgeAD-Test1 {
    [CmdletBinding(DefaultParameterSetName="All")]
    param(
        [Parameter(ParameterSetName="All")]
        [switch]$All,

        [Parameter(ParameterSetName="User")]
        [string]$SamAccountName,

        [Parameter(ParameterSetName="OU")]
        [string]$OU
    )

    Import-Module ActiveDirectory -ErrorAction Stop

    switch ($PSCmdlet.ParameterSetName) {
        "All" {
            $users = Get-ADUser -Filter * -Properties Name,SamAccountName,UserPrincipalName,Mail,PasswordLastSet,pwdLastSet,Sid
        }
        "User" {
            $users = Get-ADUser -Identity $SamAccountName -Properties Name,SamAccountName,UserPrincipalName,Mail,PasswordLastSet,pwdLastSet,Sid
        }
        "OU" {
            $users = Get-ADUser -Filter * -SearchBase $OU -Properties Name,SamAccountName,UserPrincipalName,Mail,PasswordLastSet,pwdLastSet,Sid
        }
    }

    $results = foreach ($u in $users) {
        if ($u.PasswordLastSet) {
            $age = (New-TimeSpan -Start $u.PasswordLastSet -End (Get-Date)).Days
        } else {
            $age = $null
        }

        $mustChangePassword = ($u.pwdLastSet -eq 0)

        [PSCustomObject]@{
            Name = $u.Name
            SamAccountName = $u.SamAccountName
            UserPrincipalName = $u.UserPrincipalName
            Mail = $u.Mail
            PasswordAgeInDays = $age
            MustChangePasswordAtNextLogon = $mustChangePassword
            SID = $u.Sid
        }
    }

    return $results
}
