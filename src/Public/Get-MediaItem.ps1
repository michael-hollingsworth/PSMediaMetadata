function Get-MediaItem {
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
        [Hashtable]$giParams = $PSBoundParameters

        if ($giParams.ContainsKey('Name')) {
            $giParams.Remove('Name')
        }

        [System.IO.FileSystemInfo[]]$files = Get-Item @giParams -Force

        foreach ($file in $files) {
            if ($file -isnot [IO.FileInfo]) {
                continue
            }

            try {
                $PSCmdlet.WriteObject(([TagLib.File]::Create($file.FullName)))
            } catch {
                $PSCmdlet.WriteWarning($_)
            }
        }
    }
}

#TODO: Make a PowerShell specific version of the TagLib.File class that returns PSPath, PSParentPath, PSChildName, PSDrive, and PSProvider
#TODO: Find a way to only allow the Path and LiteralPath parameters to recieve paths that are from the FileSystem provider.