function Remove-MediaItemProperty {
    [CmdletBinding(DefaultParameterSetName = 'Path')]
    [OutputType([TagLib.TagFile])]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Position = 0, ParameterSetName = 'Path')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [String]$Path,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'LiteralPath')]
        [ValidateNotNullOrEmpty()]
        [Validate]
        [Alias('PSPath', 'LP')]
        [String]$LiteralPath,

        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'LiteralPath')]
        [SupportsWildcards()]
        [ValidateNotNullOrEmpty()]
        [Alias('PSProperty')]
        [String]$Name,

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

    dynamicparam {
        [System.Management.Automation.RuntimeDefinedParameterDictionary]$paramDictionary = [System.Management.Automation.RuntimeDefinedParameterDictionary]::new()

        if (-not $PSBoundParameters.ContainsKey('TagTypes')) {
            $paramDictionary.Add('Name', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'Name', [String], $(
                    [System.Management.Automation.ParameterAttribute]@{
                        Mandatory = $true
                        ValueFromPipelineByPropertyName = $true
                        Position = 1
                        HelpMessage = ''
                    }
                    [System.Management.Automation.AliasAttribute]::new('PSProperty')
                    [System.Management.Automation.ValidateNotNullOrEmptyAttribute]::new()
                )
            ))
        }

        if (-not $PSBoundParameters.Containskey('Name')) {
            $paramDictionary.Add('TagTypes', [System.Management.Automation.RuntimeDefinedParameter]::new(
                'TagTypes', [TagLib.TagTypes], $(
                    [System.Management.Automation.ParameterAttribute]@{
                        Mandatory = $true
                        ValueFromPipelineByPropertyName = $true
                        HelpMessage = ''
                    }
                )
            ))
        }

        return $paramDictionary
    }

    begin {

    } process {
        [Hashtable]$gmiParams = $PSBoundParameters

        if ($gmiParams.ContainsKey('Name')) {
            $gmiParams.Remove('Name')
        } else {
            $gmiParams.Remove('TagTypes')
        }

        [TagLib.File[]]$tagFiles = Get-MediaItem @gmiParams

        foreach ($tagFile in $tagFiles) {
            if ($PSBoundParameters.ContainsKey('TagTypes')) {
                $tagFile.RemoveTags($TagTypes)
            } else {
                if ($Name.Trim() -eq '*') {
                    $tagFile.RemoveTags([TagLib.TagTypes]::AllTags)
                } else {
                    foreach ($property in $tagFile.Tag.PSObject.Properties) {
                        if ($property.Name -like $Name -and $property.IsSettable) {
                            $tagFile.Tag.$($property.Name) = $null
                        }
                    }
                }
            }

            $tagFile.Save()

            if ($PassThru) {
                $PSCmdlet.WriteObject($tagFile)
            }
        }
    }
}