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
        $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
        if($Sids -notcontains $strSID -and $sids -notcontains $user){
            $returnValue = $false
        }
    }
 
    del ".\secedit.sdb" -force 
    del ".\tempexport.inf" -force

    return $returnValue

}