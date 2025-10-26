<#
.SYNOPSIS
Generates a random password with a specified length and number of special characters.
    Take Length parameter to determine overall length
    Take SpecChar parameter to define number of special characters
        Number of alphanumerics is equal to Length minus SpecChar
            All alphanumerics and special characters selected from Alphanumerics and SpecialCharacters privates classes using RandomNumberGenerator
    Scramble order of generated characters using RandomNumberGenerator
    Outputs generated string

.PARAMETER Length
Total length of the password.

.PARAMETER SpecChar
Number of special characters to include.

.EXAMPLE
Generate-MAPassword -Length 12 -SpecChar 4
#>

function Generate-Password {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Length,

        [Parameter(Mandatory = $true)]
        [ValidateRange(0, [int]::MaxValue)]
        [int]$SpecChar
    )

    if ($SpecChar -gt $Length) {
        throw "The number of special characters cannot exceed the total password length."
    }

    Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Security.Cryptography;
using System.Linq;

public class PasswordGenerator {
    private static readonly char[] Alphanumerics = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".ToCharArray();
    private static readonly char[] SpecialCharacters = "!@#$%^*()_-+=?".ToCharArray();

    public static string Generate(int length, int nonAlphanumericChars) {
        if (nonAlphanumericChars > length) throw new ArgumentException("Too many special characters requested.");
        var chars = new char[length];
        int i = 0;
        for (; i < length - nonAlphanumericChars; i++) {
            chars[i] = Alphanumerics[RandomNumberGenerator.GetInt32(Alphanumerics.Length)];
        }
        for (; i < length; i++) {
            chars[i] = SpecialCharacters[RandomNumberGenerator.GetInt32(SpecialCharacters.Length)];
        }
        return new string(chars.OrderBy(c => RandomNumberGenerator.GetInt32(int.MaxValue)).ToArray());
    }
}
"@

    return [PasswordGenerator]::Generate($Length, $SpecChar)
}