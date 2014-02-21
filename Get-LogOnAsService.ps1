function Get-LogOnAsService{
    
    #Get list of currently used SIDs 
    secedit /export /cfg tempexport.inf 
    $curSIDs = Select-String .\tempexport.inf -Pattern "SeServiceLogonRight" 
    $Sids = $curSIDs.line 

    del ".\secedit.sdb" -force 
    del ".\tempexport.inf" -force

    return $Sids

}