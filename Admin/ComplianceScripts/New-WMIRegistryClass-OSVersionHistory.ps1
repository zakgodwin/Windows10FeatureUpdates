<#
.SYNOPSIS
   Create and populate WMI Class instances with Windows Source OS and CurrentVersion keys
.DESCRIPTION
   Use to create a custom WMI Class from a list of registry keys
.PARAMETER NameSpace
    WMI Namespace where new class will be created
.PARAMETER ClassName
    New WMI class name. Be sure to use a unique class since an existing class will be overwitten.
.PARAMETER CombineKeys
    Set this to True to merge all registry keys into a single WMI instance. Set to False to create new instances for each registry key
.PARAMETER RegistryKeyList
    A list of registry key paths that will be collected to be stored into a new instance of the class.
.PARAMETER ClassPropertyList
    An array of value names to be used as class properties.
.NOTES
  Version:        1.1
  Author:         Adam Gross - @AdamGrossTX
  GitHub:           https://www.github.com/AdamGrossTX
  WebSite:          https://www.asquaredozen.com
  Creation Date:  08/09/2019
  Purpose/Change:
   1.0 Initial Release
   1.1 Removed DateCollected. Updated to work on PowerShell 7 and remove WMI calls

#>
[cmdletbinding()]
Param (
   [Parameter()]
   [string]$NameSpace = "root\cimv2",

   [Parameter()]
   [string]$ClassName = "CM_OSVersionHistory",

   [Parameter()]
   [string[]]$RegistryKeyList = @(
      "HKLM:System\Setup\Source OS*",
      "HKLM:SOFTWARE\Microsoft\Windows NT\CurrentVersion"
   ),

   [Parameter()]
   [bool]$CombineKeys,

   [Parameter()]
   [hashtable]$ClassPropertyList = @{
      "KeyName"                   = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("key", "read")
      }
      "BaseBuildRevisionNumber"   = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
      "BuildBranch"               = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "BuildGUID"                 = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "BuildLab"                  = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "BuildLabEx"                = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "CompositionEditionID"      = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "CurrentBuild"              = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "CurrentBuildNumber"        = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "CurrentMajorVersionNumber" = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
      "CurrentMinorVersionNumber" = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
      "CurrentType"               = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "CurrentVersion"            = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      #Excluding these since they are binary keys and add little value
      #"DigitalProductId" = @{
      #   "type" = [System.Management.CimType]::String
      #   "qualifiers" = @("read")
      #}
      #"DigitalProductId4" = @{
      #   "type" = [System.Management.CimType]::String
      #   "qualifiers" = @("read")
      #}
      "EditionID"                 = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "EditionSubManufacturer"    = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "EditionSubstring"          = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "EditionSubVersion"         = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "InstallationType"          = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "InstallDate"               = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
      "InstallTime"               = @{
         "type"       = [System.Management.CimType]::UInt64
         "qualifiers" = @("read")
      }
      "MigrationScope"            = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
      "PathName"                  = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "ProductId"                 = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "ProductName"               = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "RegisteredOrganization"    = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "RegisteredOwner"           = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "ReleaseId"                 = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "SoftwareType"              = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "SystemRoot"                = @{
         "type"       = [System.Management.CimType]::String
         "qualifiers" = @("read")
      }
      "UBR"                       = @{
         "type"       = [System.Management.CimType]::UInt32
         "qualifiers" = @("read")
      }
   }
)

$Main = {
   Try {
      New-CustWMIClass -NameSpace $NameSpace -Class $ClassName -PropertyList $ClassPropertyList -RemoveExisting | Out-Null
      If ($CombineKeys) {
         $RegProperties = Get-RegistryProperties -RegistryKey $RegistryKeyList
         Set-CustWMIClass -NameSpace $NameSpace -Class $ClassName -Values $RegProperties -PropertyList $ClassPropertyList | Out-Null
      }
      Else {
         ForEach ($Key in $RegistryKeyList) {
            $RegKeys = Get-Item -Path $Key -ErrorAction SilentlyContinue
            ForEach ($RegKey in $RegKeys) {
               $RegProperties = Get-RegistryProperties -RegistryKey $RegKey
               $RegProperties["KeyName"] = $RegKey.PSChildName
               Set-CustWMIClass -NameSpace $NameSpace -Class $ClassName -Values $RegProperties -PropertyList $ClassPropertyList | Out-Null
            }
         }
      }
      Return $True
   }
   Catch {
      Return $_
   }
}

Function Remove-CustWMIInstance {
   [cmdletbinding()]
   Param (
      [String]$Namespace,
      [String]$Class
   )
   Try {
      $ExistingClass = Get-CIMClass -Namespace $NameSpace -ClassName $Class -ErrorAction SilentlyContinue
      If ($ExistingClass) {
         ([wmiclass]"$($Namespace):$($Class)").Delete()
      }
   }
   Catch {
      Throw $_
   }
}

Function New-CustWMIClass {
   [cmdletbinding()]
   Param (
      [String]$NameSpace,
      [String]$Class,
      $PropertyList,
      [Switch]$RemoveExisting
   )
   Try {
      If ($RemoveExisting.IsPresent) {
         Remove-CustWMIInstance -NameSpace $NameSpace -Class $Class
      }

      If (Get-CimClass -ClassName $Class -Namespace $NameSpace -ErrorAction SilentlyContinue) {
         Write-Verbose "WMI Class $Class Already Exists" | Out-Null
      }
      Else {
         Write-Verbose "Create WMI Class '$Class'" | Out-Null
         $NewClass = New-Object System.Management.ManagementClass($NameSpace, [String]::Empty, $Null);
         $NewClass['__CLASS'] = $Class
         $NewClass.Qualifiers.Add("Static", $true)

         ForEach ($key in $PropertyList.keys) {
            $NewClass.Properties.Add($key, $PropertyList[$key].Type, $false)
            ForEach ($Qualifier in $PropertyList[$Key].Qualifiers) {
               $NewClass.Properties[$key].Qualifiers.Add("$($Qualifier)", $true)
            }
         }
         $NewClass.Put() | Out-Null
      }
      Write-Verbose "End of trying to create an empty $Class to populate later" | Out-Null
   }
   Catch {
      Throw $_
   }
}

Function Set-CustWMIClass {
   [cmdletbinding()]
   Param (
      [String]$NameSpace,
      [String]$Class,
      [System.Collections.Specialized.OrderedDictionary]$Values,
      $PropertyList
   )
   Try {
      $ValueList = @{}
      ForEach ($Key in $PropertyList.Keys) {
         If ($Values[$key]) {
            If ($Values[$key] -is [int32]) {
               $ValueList[$Key] = ([uint32]$Values[$key])
            }
            ElseIf ($Values[$key] -is [int64]) {
               $ValueList[$Key] = ([uint64]$Values[$key])
            }
            Else {
               $ValueList[$Key] = $Values[$key]
            }
         }
      }
      $NewInstance = New-CimInstance -Namespace $NameSpace -ClassName $Class -Arguments $ValueList -ErrorAction Continue
      Return $NewInstance
   }
   Catch {
      Throw $_
   }
}

Function Get-RegistryProperties {
   [cmdletbinding()]
   Param (
      $RegistryKey
   )
   Try {
      [System.Collections.Specialized.OrderedDictionary]$PropertyList = [ordered]@{}
      If ($RegistryKey -is [string[]]) {
         ForEach ($Key in $RegistryKey) {
            $RegKey = Get-Item -Path "$($Key)" -ErrorAction SilentlyContinue
            If ($RegKey) {
               ForEach ($Prop in $RegKey.Property) {
                  $PropertyList[$Prop] = Get-ItemPropertyValue -Path $Key -Name $Prop
               }
            }
         }
      }
      Else {
         ForEach ($Prop in $RegistryKey.Property) {
            $PropertyList[$Prop] = $RegistryKey | Get-ItemPropertyValue -Name $Prop -ErrorAction SilentlyContinue
         }
      }
      Return $PropertyList
   }
   Catch {
      Throw $_
   }
}

& $Main