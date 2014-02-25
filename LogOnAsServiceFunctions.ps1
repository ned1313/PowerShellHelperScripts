function Grant-LogOnAsService{
param(
    [string[]] $users
    )
    

    #Get list of currently used SIDs 
    secedit /export /cfg tempexport.inf 
    $curSIDs = Select-String .\tempexport.inf -Pattern "SeServiceLogonRight" 
    $Sids = $curSIDs.line 
    $sidstring = ""
    foreach($user in $users){
        $objUser = New-Object System.Security.Principal.NTAccount($user)
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        if(!$Sids.Contains($strSID) -and !$sids.Contains($user)){
            $sidstring += ",*$strSID"
        }
    }
    if($sidstring){
        $newSids = $sids + $sidstring
        Write-Host "New Sids: $newSids"
        $tempinf = Get-Content tempexport.inf
        $tempinf = $tempinf.Replace($Sids,$newSids)
        Add-Content -Path tempimport.inf -Value $tempinf
        secedit /import /db secedit.sdb /cfg ".\tempimport.inf" 
        secedit /configure /db secedit.sdb 
 
        gpupdate /force 
    }
    else{
        Write-Host "No new sids"
    }
 
    
 
    del ".\tempimport.inf" -force -ErrorAction SilentlyContinue
    del ".\secedit.sdb" -force -ErrorAction SilentlyContinue
    del ".\tempexport.inf" -force

}

function Test-LogOnAsService{
param(
    [string[]] $users
    )
    
    $returnValue = $true
    #Get list of currently used SIDs 
    secedit /export /cfg tempexport.inf 
    $curSIDs = Select-String .\tempexport.inf -Pattern "SeServiceLogonRight" 
    $Sids = $curSIDs.line 
    foreach($user in $users){
        $objUser = New-Object System.Security.Principal.NTAccount($user)
        try{
            $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        }
        catch{
            Write-Verbose $Error[0]
            Write-Host "No SID found for user $user"
            $returnValue = $false
        }
        if(!$Sids.Contains($strSID) -and !$sids.Contains($user)){
            Write-Host "$user or $strSID not found"
            $returnValue = $false
        }
    }
 
    del ".\secedit.sdb" -force -ErrorAction SilentlyContinue
    del ".\tempexport.inf" -force

    return $returnValue

}

function Get-LogOnAsService{
    
    #Get list of currently used SIDs 
    secedit /export /cfg tempexport.inf 
    $curSIDs = Select-String .\tempexport.inf -Pattern "SeServiceLogonRight" 
    $Sids = $curSIDs.line 

    del ".\secedit.sdb" -force -ErrorAction SilentlyContinue
    del ".\tempexport.inf" -force

    return $Sids

}