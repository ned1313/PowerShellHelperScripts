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
        if($Sids -notcontains $strSID -and $sids -notcontains $user){
            $sidstring += ",*$strSID"
        }
    }
    if($sidstring){
        $newSids = $sids + $sidstring
        Write-Host "New Sids: $newSids"
        $tempinf = Get-Content tempexport.inf
        $tempinf = $tempinf.Replace($Sids,$newSids)
        Add-Content -Path tempimport.inf -Value $tempinf
    }
    else{
        Write-Host "No new sids"
    }
 
    secedit /import /db secedit.sdb /cfg ".\tempimport.inf" 
    secedit /configure /db secedit.sdb 
 
    gpupdate /force 
 
    del ".\tempimport.inf" -force 
    del ".\secedit.sdb" -force 
    del ".\tempexport.inf" -force

}