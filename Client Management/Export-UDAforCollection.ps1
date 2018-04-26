﻿<#
.Synopsis
   This script exports out specific collection UDA Relationships
   Run this script from the site server
.DESCRIPTION
.EXAMPLE
    Export - UDAforCollection.ps1 -DeviceCollectionName "All Systems" -OutPut C:\Scripts\Reports\UDA.csv -SiteCode PS1
.NOTES
    Developed by Kaido Järvemets, Coretech A/S
    Version 1.0
 
#>
Param(
    [Parameter(Mandatory=$True,HelpMessage="Please Enter ConfigMgr Collection Name",ParameterSetName='CSV')]
        $DeviceCollectionName,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter CSV file location",ParameterSetName='CSV')]
        $OutPut,
    [Parameter(Mandatory=$True,HelpMessage="Please Enter ConfigMgr site code",ParameterSetName='CSV')]
        $SiteCode
)

$CollectionQuery = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_Collection" -Filter "Name='$DeviceCollectionName' and CollectionType='2'"

$ResourcesInCollection = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_CollectionMember_a"  -Filter "CollectionID='$($CollectionQuery.CollectionID)'"

$UDARelationShips = @()
foreach($item in $ResourcesInCollection){

    $UDA = Get-CimInstance -Namespace "Root\SMS\Site_$SiteCode" -ClassName "SMS_UserMachineRelationship" -Filter "ResourceID='$($item.ResourceID)'"
    
    foreach($Rel in $UDA){
        
        Write-Progress -Activity "Exporting UDA information" -Status "Processing resource $($item.ResourceID)"

        $DObject = New-Object PSObject
            $DObject | Add-Member -MemberType NoteProperty -Name "RelationshipResourceID" -Value $Rel.RelationshipResourceID
            $DObject | Add-Member -MemberType NoteProperty -Name "Collection Name" -Value $DeviceCollectionName
            $DObject | Add-Member -MemberType NoteProperty -Name "Resource Name" -Value $Rel.ResourceName
            $DObject | Add-Member -MemberType NoteProperty -Name "ResourceID" -Value $Rel.ResourceID
            $DObject | Add-Member -MemberType NoteProperty -Name "UniqueUserName" -Value $Rel.UniqueUserName
            $DObject | Add-Member -MemberType NoteProperty -Name "CreationTime" -Value $Rel.CreationTime
            $DObject | Add-Member -MemberType NoteProperty -Name "IsActive" -Value $Rel.IsActive
        $UDARelationShips += $DObject
   }

}
$UDARelationShips | Sort-Object -Property "Resource Name" | Export-Csv -NoTypeInformation -UseCulture -Path $OutPut
