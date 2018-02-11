function Expand-ArmorApiResult {
    <#
        .SYNOPSIS
        This cmdlet is used to remove any parent variables surrounding response
        data, such as encapsulating results in a "data" key.

        .DESCRIPTION
        { required: more detailed description of the function's purpose }

        .INPUTS
        System.Management.Automation.PSCustomObject[]

        .NOTES
        Troy Lindsay
        Twitter: @troylindsay42
        GitHub: tlindsay42

        .EXAMPLE
        {required: show one or more examples using the function}

        .LINK
        http://armorpowershell.readthedocs.io/en/latest/index.html

        .LINK
        https://github.com/tlindsay42/ArmorPowerShell

        .LINK
        https://docs.armor.com/display/KBSS/Armor+API+Guide

        .LINK
        https://developer.armor.com/
    #>

    [CmdletBinding()]
    [OutputType( [PSCustomObject[]] )]
    param (
        <#
        Specifies the unformatted API response content.
        #>
        [Parameter(
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [AllowEmptyCollection()]
        [PSCustomObject[]]
        $Results = @(),

        <#
        Specifies the key/value pair that contains the name of the key holding
        the response content's data.
        #>
        [Parameter( Position = 1 )]
        [ValidateNotNull()]
        [String]
        $Location = $null
    )

    begin {
        $function = $MyInvocation.MyCommand.Name

        Write-Verbose -Message ( 'Beginning {0}.' -f $function )
    } # End of begin

    process {
        [PSCustomObject[]] $return = @()

        foreach ( $result in $Results ) {
            if ( $Location -and $result.$Location -ne $null ) {
                <#
                The $Location check assumes that not all endpoints will require
                finding (and removing) a parent key if one does exist, this
                extracts the value so that the $result data is consistent
                across API versions.
                #>
                $return += $result.$Location
            }
        }

        $return
    } # End of process

    end {
        Write-Verbose -Message ( 'Ending {0}.' -f $function )
    } # End of end
} # End of function
