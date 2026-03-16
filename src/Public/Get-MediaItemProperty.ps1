function Get-MediaItemProperty {
<#
.NOTES
    This function requires that the TagLibSharp library has been imported into the current PowerShell AppDomain.

    To Import the library, use the command: `[System.Reflection.Assembly]::LoadFrom('TagLibSharp.dll')`
.LINK
    https://www.nuget.org/packages/TagLibSharp
.LINK
    https://github.com/mono/taglib-sharp
#>
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([TagLib.File])]
    [OutputType([PSCustomObject])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'Path')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath', 'LP')]
        [String]$LiteralPath,

        [Parameter()]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [Alias('PSProperty')]
        [String[]]$Name,

        [Parameter()]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String]$Filter,

        [Parameter()]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Include,

        [Parameter()]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String[]]$Exclude
    )

    begin {

    } process {
        [Hashtable]$gmiParams = $PSBoundParameters

        if ($gmiParams.ContainsKey('Name')) {
            $gmiParams.Remove('Name')
        }

        [TagLib.File[]]$tagFiles = Get-MediaItem @gmiParams

        if (-not $PSBoundParameters.ContainsKey('Name')) {
            return $tagFiles
        }

        foreach ($tagFile in $tagFiles) {
            [Hashtable]$retObj = @{
                PSPath = "Microsoft.PowerShell.Core\FileSystem::$($tagFile.Name)"
            }

            foreach ($property in $tagFile.Tag.PSObject.Properties.Name) {
                foreach ($nameProperty in $Name) {
                    if ($property -like $nameProperty) {
                        $retObj[$property] = $tagFile.Tag.$property
                    }
                }
            }

            $PSCmdlet.WriteObject(([PSCustomObject]$retObj))
        }
    }
}