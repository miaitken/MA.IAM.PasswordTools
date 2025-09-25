<#
.SYNOPSIS
Generates a random password with a specified length and number of special characters.

.PARAMETER Length
Total length of the password.

.PARAMETER SpecChar
Number of special characters to include.

.EXAMPLE
Generate-MAPassword -Length 12 -SpecChar 4
#>

function Generate-MAPassword {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Length,

        [Parameter(Mandatory=$true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$SpecChar
    )

    if ($SpecChar -gt $Length) {
        throw "The number of special characters cannot exceed the total password length."
    }

    Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Linq;
public class PasswordGenerator {
    public static string Generate(int length, int nonAlphanumericChars) {
        const string alphanumerics = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        const string nonAlphanumerics = "!@#$%^*()_-+=?";
        Random random = new Random();
        StringBuilder password = new StringBuilder();
        for (int i = 0; i < length - nonAlphanumericChars; i++) {
            password.Append(alphanumerics[random.Next(alphanumerics.Length)]);
        }
        for (int i = 0; i < nonAlphanumericChars; i++) {
            password.Append(nonAlphanumerics[random.Next(nonAlphanumerics.Length)]);
        }
        return new string(password.ToString().OrderBy(c => random.Next()).ToArray());
    }
}
"@

    return [PasswordGenerator]::Generate($Length,$SpecChar)
}