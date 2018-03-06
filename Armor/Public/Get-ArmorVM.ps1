function Get-ArmorVM {
    <#
        .SYNOPSIS
        This cmdlet retrieves the virtual machines in your Armor account.

        .DESCRIPTION
        This cmdlet retrieves details about the virtual machines in the
        Armor Anywhere or Armor Complete account in context.  Returns a set of
        virtual machines that correspond to the filter criteria provided by the
        cmdlet parameters.

        .INPUTS
        System.UInt16

        System.String

        .NOTES
        Troy Lindsay
        Twitter: @troylindsay42
        GitHub: tlindsay42

        .EXAMPLE
        Get-ArmorVM


        Description
        -----------
        Returns all VMs in the Armor account that currently has context.

        .EXAMPLE
        Get-ArmorVM -Name ARMO25VML01-gen4


        Description
        -----------
        Returns the specified VM in the Armor account that currently has context.

        .EXAMPLE
        Get-ArmorVM -Name *-gen4


        Description
        -----------
        Returns all VMs in the Armor account that currently has context that have a name that ends with '-gen4'.

        .EXAMPLE
        Get-ArmorVM -Name *hacked*


        Description
        -----------
        Returns null.

        .LINK
        http://armorpowershell.readthedocs.io/en/latest/cmd_get.html#get-armorvm

        .LINK
        https://github.com/tlindsay42/ArmorPowerShell

        .LINK
        https://docs.armor.com/display/KBSS/Get+VMs

        .LINK
        https://docs.armor.com/display/KBSS/Get+VM+Detail

        .LINK
        https://developer.armor.com/#!/Infrastructure/Vm_GetVmList

        .LINK
        https://developer.armor.com/#!/Infrastructure/Vm_GetVmDetail
    #>

    [CmdletBinding( DefaultParameterSetName = 'ID' )]
    [OutputType( [PSCustomObject[]] )]
    param (
        <#
        Specifies the IDs of the virtual machines that you want to retrieve.
        #>
        [Parameter(
            ParameterSetName = 'ID',
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateRange( 1, 65535 )]
        [UInt16]
        $ID = 0,

        <#
        Specifies the names of the virtual machines that you want to retrieve.
        Wildcard matches are supported.
        #>
        [Parameter(
            ParameterSetName = 'Name',
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [AllowEmptyString()]
        [String]
        $Name = '',

        <#
        Specifies the API version for this request.
        #>
        [Parameter( Position = 1 )]
        [ValidateSet( 'v1.0' )]
        [String]
        $ApiVersion = $Global:ArmorSession.ApiVersion
    )

    begin {
        $function = $MyInvocation.MyCommand.Name

        Write-Verbose -Message "Beginning: '${function}'."

        Test-ArmorSession
    } # End of begin

    process {
        [PSCustomObject[]] $return = $null

        $resources = Get-ArmorApiData -FunctionName $function -ApiVersion $ApiVersion

        if ( $PsCmdlet.ParameterSetName -and $ID -gt 0 ) {
            $uri = New-ArmorApiUri -Endpoints $resources.Endpoints -IDs $ID
        }
        else {
            $uri = New-ArmorApiUri -Endpoints $resources.Endpoints
        }

        $keys = ( $resources.Query | Get-Member -MemberType 'NoteProperty' ).Name
        $parameters = ( Get-Command -Name $function ).Parameters.Values
        $uri = New-ArmorApiUriQuery -Keys $keys -Parameters $parameters -Uri $uri

        $results = Submit-ArmorApiRequest -Uri $uri -Method $resources.Method -Description $resources.Description

        $results = Select-ArmorApiResult -Results $results -Filter $resources.Filter

        if ( $results.Count -eq 0 ) {
            Write-Host -Object 'Armor VM not found.'
        }
        else {
            $return = $results
        }

        $return
    } # End of process

    end {
        Write-Verbose -Message "Ending: '${function}'."
    } # End of end
} # End of function
