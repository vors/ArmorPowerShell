function Get-ArmorAccountAddress {
    <#
        .SYNOPSIS
        Displays the address for the specified Armor account accessible to the current user.

        .DESCRIPTION
        { required: more detailed description of the function's purpose }

        .NOTES
        Troy Lindsay
        Twitter: @troylindsay42
        GitHub: tlindsay42

        .INPUTS
        None
            You cannot pipe objects to Get-ArmorAccount.

        .OUTPUTS
        System.Collections.Hashtable

        .LINK
        https://github.com/tlindsay42/ArmorPowerShell

        .LINK
        https://docs.armor.com/display/KBSS/Armor+API+Guide

        .LINK
        https://developer.armor.com/

        .EXAMPLE
        {required: show one or more examples using the function}
    #>

    [CmdletBinding()]
    param (
        <#
        Specifies the ID of the Armor account with the desired address details.
        #>
        [Parameter( Position = 0 )]
        [ValidateRange( 1, 65535 )]
        [UInt16] $ID = $Global:ArmorSession.GetAccountContext().ID,

        <#
        Specifies the API version for this request.
        #>
        [ValidateSet( 'v1.0' )]
        [String] $ApiVersion = $Global:ArmorSession.ApiVersion
    )

    begin {
        $function = $MyInvocation.MyCommand.Name

        Write-Verbose -Message ( 'Beginning {0}.' -f $function )

        Test-ArmorSession
    } # End of begin

    process {
        $return = $null
        $headers = $Global:ArmorSession.Headers.Clone()
        $headers.( $Global:ArmorSession.AccountContextHeader ) = $ID

        $resources = Get-ArmorApiData -Endpoint $function -ApiVersion $ApiVersion

        $uri = New-ArmorApiUriString -Endpoints $resources.Uri -IDs $ID

        if ( $ID -gt 0 ) {
            Write-Verbose 'Implementing workaround for specific account query bug.'
        }

        $uri = New-ArmorApiUriQueryString -QueryKeys $resources.Query.Keys -Parameters ( Get-Command -Name $function ).Parameters.Values -Uri $uri

        $results = Submit-ArmorApiRequest -Uri $uri -Headers $headers -Method $resources.Method -Description $resources.Description

        $results = Select-ArmorApiResult -Results $results -Filter $resources.Filter

        if ( $results.Count -eq 0 ) {
            Write-Host -Object 'Armor account not found.'
        }
        else {
            $return = [ArmorAccountAddress] $results
        }

        $return
    } # End of process

    end {
        Write-Verbose -Message ( 'Ending {0}.' -f $function )
    } # End of end
} # End of function
