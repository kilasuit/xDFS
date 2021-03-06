# If there is a .config.json file for these tests, read the test parameters from it.
$ConfigFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path,'json')
if (Test-Path -Path $ConfigFile)
{
     $TestConfig = Get-Content -Path $ConfigFile | ConvertFrom-Json
}
else
{
    # Example config parameters.
    $TestConfig = @{
        Username = 'CONTOSO.COM\Administrator'
        Password = 'MyP@ssw0rd!1'
        Members = @('Server1','Server1')
        Folders = @('TestFolder1','TestFolder2')
        ContentPaths = @("$(ENV:Temp)TestFolder1","$(ENV:Temp)TestFolder2")
    }
}
$TestPassword = New-Object -Type SecureString [char[]] $TestConfig.Password | % { $Password.AppendChar( $_ ) }
$ReplicationGroupConnection = @{
    GroupName               = 'IntegrationTestReplicationGroup'
    Folders                 = $TestConfig.Folders
    Members                 = $TestConfig.Members
    Ensure                  = 'Present'
    SourceComputerName      = $TestConfig.Members[0]
    DestinationComputerName = $TestConfig.Members[1]
    PSDSCRunAsCredential    = New-Object System.Management.Automation.PSCredential ($TestConfig.Username, $TestPassword)
}

Configuration MSFT_xDFSReplicationGroupConnection_Config {
    Import-DscResource -ModuleName xDFS
    node localhost {
        xDFSReplicationGroupConnection Integration_Test {
            GroupName                   = $ReplicationGroupConnection.GroupName
            Ensure                      = 'Present'
            SourceComputerName          = $ReplicationGroupConnection.SourceComputerName
            DestinationComputerName     = $ReplicationGroupConnection.DestinationComputerName
            PSDSCRunAsCredential        = $ReplicationGroupConnection.PSDSCRunAsCredential
        }
    }
}
