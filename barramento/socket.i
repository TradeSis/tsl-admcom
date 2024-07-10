def var pConfig as char.
if pHost = "" or pHost = ?
then do:
    if search("/admcom/barramento/config.ini") <> ?
    then do:
        input from /admcom/barramento/config.ini no-echo.
        import unformatted pConfig.
        input close.
        pHost = entry(1,pConfig) no-error.
    end.    
    if pHost = ? or pHost = ""
    then do:
        pHost = "localhost".
    end.
    if pPorta = 0 or pPorta = ?
    then do:
        if num-entries(pConfig) = 2
        then pPorta = int(entry(2,pConfig)) no-error.
    end.        
end.
if pPorta = 0 or pPorta = ?
then do:
    pHost  = "localhost".
    pPorta = 23454.
end.


FUNCTION acha& returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"&"). 
        if num-entries( entry(vx,par-onde,"&"),"=") = 2 and
           entry(1,entry(vx,par-onde,"&"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"&"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.


procedure lerSocket.
    def input  parameter pSocket  as handle.
    def input  parameter pBytes   as int.
    def output parameter pRetorno as char.

    def var mDados as memptr.
    def var iBytes as int. 
    if pSocket:GET-BYTES-AVAILABLE() < pBytes
    then pBytes = pSocket:GET-BYTES-AVAILABLE().
        iBytes = if pBytes = 0
                 then psocket:GET-BYTES-AVAILABLE()
                 else pBytes.   
        SET-SIZE(mDados)       = 0 .
        SET-SIZE(mDados)       = iBytes .
        if pBytes = 0
        then SET-BYTE-ORDER(mDados) = BIG-ENDIAN  .
        else SET-BYTE-ORDER(mDados) = LITTLE-ENDIAN  .

        psocket:READ(mDados,1,iBytes,READ-EXACT-NUM).        
        pRetorno = GET-STRING(mDados,1)  .

        SET-SIZE(mDados) = 0.    
    
end.

procedure lerSocketLong.
    def input  parameter pSocket  as handle.
    def input  parameter pBytes   as int.
    def output parameter pRetorno as LongChar.

    def var iPonteiro as int init 1.
    def var mDados as memptr.
    def var iBytes as int. 
    if pBytes > 0
    then do:
        SET-SIZE(mDados)       = pBytes .
        SET-BYTE-ORDER(mDados) = LITTLE-ENDIAN /*BIG-ENDIAN*/  .
        do while true:   
            IF iPonteiro > pBytes
            THEN DO:  
                LEAVE.  
            END.  
            IF pSocket:GET-BYTES-AVAILABLE() > 0  
            THEN DO:  
                iBytes = psocket:GET-BYTES-AVAILABLE().   
                psocket:READ(mdados,iPonteiro,iBytes,READ-EXACT-NUM). 
                iPonteiro = iPonteiro + iBytes.
            end.
        end. 
    end.
    else do:
        iBytes = psocket:GET-BYTES-AVAILABLE().   
        SET-SIZE(mDados)       = iBytes .
        SET-BYTE-ORDER(mDados) = BIG-ENDIAN .
        psocket:READ(mdados,iPonteiro,iBytes,READ-EXACT-NUM). 
    end.
            
  FIX-CODEPAGE (pRetorno) = 'utf-8'.  
  COPY-LOB FROM OBJECT mDados TO pRetorno
        CONVERT SOURCE CODEPAGE 'utf-8'.  
    
    SET-SIZE(mDados) = 0.    
    
end.

procedure escreverSocket. 
    def input parameter pSocket  as handle.
    def input parameter pBytes   as int.
    def input parameter pEnvio   as char.

    def var mDados as memptr.
    def var iBytes as int. 
    if pBytes = 0
    then pBytes = length(pEnvio).
        
    SET-SIZE(mDados)            = 0. 
    SET-SIZE(mDados)            = pBytes /*LENGTH(pEnvio)*/ + 1 . 
    SET-BYTE-ORDER(mDados)      = BIG-ENDIAN.  
    PUT-STRING(mDados,1)        = pEnvio.  
    pSocket:WRITE(mDados, 1, pBytes /*LENGTH(pEnvio)*/ ). 
    
    SET-SIZE(mDados)   = 0.

end procedure.

procedure escreverSocketLong. 
    def input parameter pSocket  as handle.
    def input parameter pEnvio   as LongChar.

    def var mDados as memptr.
    def var iBytes as int. 

    copy-lob pEnvio to mDados convert target codepage "utf-8". 
    pSocket:WRITE(mDados,1, GET-SIZE(mDados)).
    
    SET-SIZE(mDados)   = 0.

end procedure.

procedure escreverSocketHeaderLong. 
    def input parameter pSocket  as handle.
    def input parameter pHeader  as char.
    def input parameter pEnvio   as LongChar.

    def var mDados as memptr.
    def var mAux   as memptr.
    
    def var iBytes as int. 

    copy-lob pEnvio to mAux convert target codepage "utf-8". 

    ASSIGN 
    SET-BYTE-ORDER(mDados) = LITTLE-ENDIAN 
    SET-SIZE(mDados)       = get-size(mAux) + 128 
    PUT-STRING(mdados, 1)  = pHeader 
    PUT-BYTES(mDados ,129)  = mAux.
              
    pSocket:WRITE(mDados,1, GET-SIZE(mDados)).
    
    SET-SIZE(mDados)   = 0.
    SET-SIZE(mAux)   = 0.

end procedure.
