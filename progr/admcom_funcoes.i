/***
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
         
FUNCTION sel-arq01 returns character .
    
    DEFINE VARIABLE procname AS CHARACTER NO-UNDO.
    DEFINE VARIABLE OKpressed AS LOGICAL INITIAL TRUE.

    def var varquivo as char.
    Main: 
    REPEAT:
        SYSTEM-DIALOG GET-FILE procname
            TITLE      "Selecione o arquivo ..."
            FILTERS  "txt"  "*.txt" ,
                 "csv"  "*.csv"
            MUST-EXIST
            USE-FILENAME
            UPDATE OKpressed.
      
        IF OKpressed = TRUE THEN
            varquivo = procname.
        /*ELSE*/      
            LEAVE Main.
    END.     
    return varquivo. 
END FUNCTION.
**/
FUNCTION venda-liquida-item return decimal
    (input rec-movim as recid).
    def var val_fin as dec init 0.
    def var val_des as dec init 0.
    def var val_dev as dec init 0.
    def var val_acr as dec init 0.
    def var val_com as dec init 0.
    assign
        val_fin = 0                   
        val_des = 0   
        val_dev = 0   
        val_acr = 0
        val_com = 0. 
                         
    find movim where recid(movim) = rec-movim no-lock no-error.
    if avail movim
    then do:
        find first plani where plani.etbcod = movim.etbcod and
                           plani.placod = movim.placod and
                           plani.movtdc = movim.movtdc and
                           plani.pladat = movim.movdat
                           no-lock no-error.
        if avail plani
        then do:                       
            
            val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.acfprod.
            if val_acr = ? then val_acr = 0.
            
            val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.descprod.
            if val_des = ? then val_des = 0.
        
            val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                        plani.vlserv.
            if val_dev = ? then val_dev = 0.
        
            if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
            then val_fin =  
                ((((movim.movpc * movim.movqtm) - val_dev - val_des)
                         / (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).
            if val_fin = ? then val_fin = 0.
            
            val_com = (movim.movpc * movim.movqtm) - val_dev - val_des + 
                        val_acr +  val_fin. 

            if val_com = ? then val_com = 0.
             
        end.
    end.
    return val_com.
END FUNCTION.
FUNCTION hispreco-venda return decimal
    ( input p-procod as int,
      input p-data   as date ).
    def var vpreco as dec.  
    find last hispre where
              hispre.procod = p-procod and
              hispre.dtalt  <= p-data
              no-lock no-error.
    if avail hispre
    then vpreco = hispre.estvenda-nov.
    else vpreco = 0.
    return vpreco.   
end function.
FUNCTION limite-cred-scor return decimal
     ( input rec-clien as recid )   .
    def var vcalclim as dec.
    def var vpardias as dec.
    run callim-cred-scor.p(input rec-clien,
                           output vcalclim).
 
    return vcalclim.
end function. 
FUNCTION saldo-aberto-cliente return decimal
     ( input rec-clien as recid )   .
    def var vsaldo-aberto as dec.
    def var vpardias as dec.
    run saldo-aberto-cliente.p(input rec-clien,
                           output vsaldo-aberto).
 
    return vsaldo-aberto.
end function. 
FUNCTION troca-padrao-separador return character
     ( input val-dec as dec )   .
    def var val-cha as char.
    def var val-nov as char.
    def var v1 as int.
    def var v2 as int.

    val-cha = string(val-dec,">>>,>>>,>>>,>>9.99").

    do v1 = 1 to num-entries(val-cha,".").
        val-nov = val-nov + entry(v1,val-cha,".") .
        if num-entries(val-cha,".") = v1
        then.
        else val-nov = val-nov + ";".
    end.     
    val-cha = val-nov.
    val-nov = "".
    do v1 = 1 to num-entries(val-cha,",").
        val-nov = val-nov + entry(v1,val-cha,",") .
        if num-entries(val-cha,",") = v1
        then.
        else val-nov = val-nov + ".".
    end.
    val-cha = val-nov.
    val-nov = "".
    do v1 = 1 to num-entries(val-cha,";").
        val-nov = val-nov + entry(v1,val-cha,";") .
        if num-entries(val-cha,";") = v1
        then.
        else val-nov = val-nov + ",".
    end.  
    val-nov = trim(val-nov).
    return val-nov. 
end function.     
FUNCTION hispreco-venda-ant return decimal
    ( input p-procod as int,
      input p-data   as date ).
    def var vpreco as dec.  
    find first hispre where
              hispre.procod = p-procod and
              hispre.dtalt  >= p-data
              no-lock no-error.
    if avail hispre
    then vpreco = hispre.estvenda-ant.
    else vpreco = 0.
    return vpreco.   
end function.

