function Set-MediaItemProperty {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([TagLib.TagFile])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'Path')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [Alias('PSPath', 'LP')]
        [String]$LiteralPath,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [Alias('PSProperty')]
        [String]$Name,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [Object]$Value,

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
        [String[]]$Exclude,

        [Parameter()]
        [Switch]$PassThru
    )

    begin {

    } process {
        [Hashtable]$gmiParams = $PSBoundParameters

        $gmiParams.Remove('Name')
        $gmiParams.Remove('Value')

        [TagLib.File[]]$tagFiles = Get-MediaItem @gmiParams

        foreach ($tagFile in $tagFiles) {
            foreach ($property in $tagFile.Tag.PSObject.Properties) {
                if ($property.Name -like $Name -and $property.IsSettable) {
                    $tagFile.Tag.$($property.Name) = $Value
                }
            }

            $tagFile.Save()

            if ($PassThru) {
                $PSCmdlet.WriteObject($tagFile)
            }
        }
    }
}