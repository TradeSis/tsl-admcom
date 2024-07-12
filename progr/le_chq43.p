{admcab.i}
def var vi as int.
def var vtexto          as char format "x(30)".
def var v-dig           as int.

def var vtipo      as log format "Pre/Dia" initial no.
def var vlote_1    like lotdep.lote.
def var vlote_2    like lotdep.lote.
def var data_arq like plani.pladat.
def var p-dia like plani.platot.
def var p-pre like plani.platot.

def var vselect as char format "x(15)" extent 3
        init["  SAIR  ","   COFRE  ","   BIU   "].

def var vindex as int.

def var vtotal like plani.platot.
def var vdata like plani.pladat.
def var varq  as char.
def var varq2 as char.
def var vreg  as char.
def var ii    as int.
def var vv    as int.
def var vbanco   as char.
def var vagencia as char.
def var vconta   as char.
def var vnumero  as char.

def new shared temp-table tt-che
    field rec  as recid
    field cmc7 as char
    index rec is primary unique rec asc.


def new shared temp-table tt-data
    field etbcod like estab.etbcod
    field datmov like deposito.datmov
    field chedre like deposito.chedre
    field chedia like deposito.chedia.
    
def temp-table tt-chq
    field rec as recid
    field cmc7 as char
    field vmarca as char.
    
def new shared temp-table tt-dif
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)"
    field vstatus  as char format "x(10)"
    field cmc7 as char.

def var cl-banco as int.
def var cl-agencia as int.
repeat:


    for each tt-data:
        delete tt-data.
    end.
    
    for each tt-chq:
        delete tt-chq.
    end.
    
    for each tt-dif:
        delete tt-dif.
    end.
    
    vdata = data_arq.
    
    update vdata    label "Data Confirmacao"
           data_arq label "     Data do Dia"
           vlote_1  label "Lote" colon 15
           vlote_2  
           vtipo    label "Cheque"
                with frame f1 width 80 side-label.
    ii = 0.
    
    
    varq2 = "..~\work~\" + 
             string(year(data_arq),"9999") +
             string(month(data_arq),"99")  + 
             string(day(data_arq),"99") + ".dig".
    
             
    /*         
    varq2 = "/admcom/work/" + 
             string(year(data_arq),"9999") +
             string(month(data_arq),"99")  + 
             string(day(data_arq),"99") + ".dig".
             
    */
         
    
    if search(varq2) <> ?
    then do:
        input from value(varq2).
        repeat:

                       
            import vreg.
            ii = ii + 1.
            assign vbanco   = substring(vreg,8,3)
                   vagencia = substring(vreg,11,4)
                   vconta   = substring(vreg,15,10)
                   vnumero  = substring(vreg,25,6).
  
            vi = 0.
            find first chq where chq.banco       = int(vbanco)   and
                                 chq.agencia     = int(vagencia) and
                                 chq.conta       = vconta        and 
                                 chq.numero      = vnumero  no-lock no-error.
            if avail chq
            then do:
                find first tt-chq where tt-chq.rec = recid(chq) no-error.
                if not avail tt-chq
                then do:
                    create tt-chq.

                    assign tt-chq.rec = recid(chq)
                           tt-chq.cmc7 = substr(vreg,32,35)
                           tt-chq.vmarca = "X".

                end.    
            end. 
            else do:
                find first tt-dif where 
                           tt-dif.banco   = int(vbanco)          and
                           tt-dif.agencia = int(vagencia)        and
                           tt-dif.conta   = vconta               and  
                           tt-dif.numero  = vnumero no-lock no-error.
                 
                if not avail tt-dif  
                then do:  
                
                    create tt-dif.
                    assign tt-dif.cmc7    = substr(vreg,32,35)
                           tt-dif.banco   = int(vbanco)      
                           tt-dif.agencia = int(vagencia)        
                           tt-dif.conta   = vconta  
                           tt-dif.numero  = vnumero
                           tt-dif.etbcod  = 0.
                           
                end.
            
            end.
            
        end.
        input close.
   
    end.
    
    varq = "..~\work~\" + 
           string(year(data_arq),"9999") +
           string(month(data_arq),"99")  + 
           string(day(data_arq),"99") + ".txt".

    
    
    /*
    varq = "/admcom/work/" + 
           string(year(data_arq),"9999") +
           string(month(data_arq),"99")  + 
           string(day(data_arq),"99") + ".txt".

    */
    
    
    if search(varq) = ?
    then do:
        message "Arquivo nao encontrado".
        pause.
        undo, retry.
    end.    
    else do:
        input from value(varq).
        repeat:
            import vreg.
            
            ii = ii + 1.

            assign vbanco   = substring(vreg,2,3)
                   vagencia = substring(vreg,5,4)
                   vconta   = substring(vreg,23,10)
                   vnumero  = substring(vreg,14,6).
                   
            vi = 0.
            /*
            repeat on error undo :
                vi = vi + 1.
                disp with frame fff row 20. pause 0.
                if vi = 2
                then do:
                    update vbanco    label "Banco"
                           vagencia  label "Agencia"
                           vconta    label "Conta"
                           vnumero   label "Numero"
                           with frame f-errochar1
                           1 down  row 20 side-label.     
                    vi = 1.
                    hide frame f-errochar1 no-pause.
                end.
                assign
                    cl-banco = int(vbanco)
                    cl-agencia = int(vagencia).    
                leave.
            end. 
            */        
            if vbanco = "001" 
            then vconta =  string(int(substring(vreg,25,8))).
            
            if vbanco = "341" 
            then vconta =  substring(vreg,27,6).
            
            if vbanco = "237" 
            then vconta = substring(vreg,26,7).
            
            if vbanco = "389" 
            then vconta = substring(vreg,24,9).
            
            
            if vbanco = "409" or
               vbanco = "356" or
               vbanco = "237"
            then vconta = substring(vreg,26,7).

            
            if vbanco = "008" 
            then vconta = substring(vreg,25,8).

            
            if vbanco = "104" 
            then vconta = substring(vreg,24,9).

            if vbanco = "748" 
            then vconta = substring(vreg,27,6).

                   
            find chq where chq.banco   = int(vbanco)   and
                           chq.agencia = int(vagencia) and
                           chq.conta   = vconta        and
                           chq.numero  = vnumero no-lock no-error.
            if avail chq
            then do:
                find first tt-chq where tt-chq.rec = recid(chq) no-error.
                if not avail tt-chq
                then do:
                    create tt-chq.
                    assign tt-chq.rec = recid(chq)
                           tt-chq.cmc7 = vreg
                           .
                end.    
            end.    
            else do:
                find first chq where 
                           chq.banco   = int(vbanco)           and
                           chq.agencia = int(vagencia)         and
                           chq.conta   =  substring(vreg,26,6) and  
                           chq.numero  = vnumero no-lock no-error.
                if avail chq
                then do:
                    find first tt-chq where tt-chq.rec = recid(chq) no-error.
                    if not avail tt-chq
                    then do:
                        create tt-chq.
                        assign tt-chq.rec = recid(chq)
                               tt-chq.cmc7 = vreg 
                               .
                    end.    
                end.
                else do: 
                
                    find first chq where 
                               chq.banco   = int(vbanco)           and
                               chq.agencia = int(vagencia)         and
                               chq.conta   =  substring(vreg,27,5) and  
                               chq.numero  = vnumero no-lock no-error.
                 
                    if avail chq
                    then do:
                        find first tt-chq where tt-chq.rec = recid(chq) 
                                no-error.
                        if not avail tt-chq
                        then do:
                            create tt-chq.
                            assign tt-chq.rec = recid(chq)
                                   tt-chq.cmc7 = vreg 
                                   .
                        end.    
                    end.
                    else do:
                       find first tt-dif where 
                               tt-dif.banco   = int(vbanco)          and
                               tt-dif.agencia = int(vagencia)        and
                               tt-dif.conta   = vconta               and  
                               tt-dif.numero  = vnumero no-lock no-error.
                 
                       if not avail tt-dif  
                       then do:  
                
                           create tt-dif.
                           assign tt-dif.banco   = int(vbanco)      
                                  tt-dif.agencia = int(vagencia)        
                                  tt-dif.conta   = vconta  
                                  tt-dif.numero  = vnumero
                                  tt-dif.etbcod  = 0.
                           
                       end.
            
                    end.
 
                end.
            end.               
        end.
        input close.
        
    end.
    
    output to tt-dif.log.
    for each tt-dif:
        export tt-dif.
    end.    
    output close.

    output to tt-chq.log.
    for each tt-dif:
        export tt-dif.
    end.    
    output close.
 
    for each deposito where deposito.datcon = vdata no-lock: 
        
        find lotdep where lotdep.etbcod = deposito.etbcod and
                          lotdep.datcon = deposito.datmov no-lock no-error.
        if not avail lotdep
        then next.
        if lotdep.lote >= vlote_1 and
           lotdep.lote <= vlote_2
        then.
        else next.
        
        
        
        
        find first tt-data where tt-data.etbcod = deposito.etbcod and
                                 tt-data.datmov = deposito.datmov no-error.
        if not avail tt-data
        then do:
            create tt-data.
            assign tt-data.etbcod = deposito.etbcod 
                   tt-data.datmov = deposito.datmov.
        end.
        assign tt-data.chedre = tt-data.chedre + deposito.chedre
               tt-data.chedia = tt-data.chedia + deposito.chedia.
               
    end.
        
    for each tt-chq where tt-chq.vmarca = "".
      
        find chq where recid(chq) = tt-chq.rec no-lock.
        
        find first chqtit of chq no-lock no-error.  
        if not avail chqtit  
        then next.

        if vtipo 
        then do: 
            if chq.datemi = chq.data 
            then do:
                delete tt-chq. 
                find first tt-dif where 
                           tt-dif.banco   = chq.banco          and
                           tt-dif.agencia = chq.agencia        and
                           tt-dif.conta   = chq.conta          and  
                           tt-dif.numero  = chq.numero no-lock no-error.
                 
                if not avail tt-dif 
                then do:
                   
                    create tt-dif.
                    assign tt-dif.banco   = chq.banco      
                           tt-dif.agencia = chq.agencia        
                           tt-dif.conta   = chq.conta
                           tt-dif.numero  = chq.numero
                           tt-dif.etbcod  = chqtit.etbcod
                           tt-dif.valor   = chq.valor
                           tt-dif.vstatus  = "DIA".
                        
                end.
      
 
                next.
            end.
        end. 
        else do: 
            if chq.datemi <> chq.data 
            then do:
                /*delete tt-chq.*/ 
                find first tt-dif where 
                           tt-dif.banco   = chq.banco          and
                           tt-dif.agencia = chq.agencia        and
                           tt-dif.conta   = chq.conta          and  
                           tt-dif.numero  = chq.numero no-lock no-error.
                 
                if not avail tt-dif 
                then do:
                   
                    create tt-dif.
                    assign tt-dif.banco   = chq.banco      
                           tt-dif.agencia = chq.agencia        
                           tt-dif.conta   = chq.conta
                           tt-dif.numero  = chq.numero
                           tt-dif.etbcod  = chqtit.etbcod
                           tt-dif.valor   = chq.valor
                           tt-dif.vstatus  = "PRE".
                        
                end.             
                delete tt-chq.
                /*next.*/
            end.
        end.
    end.

    ii = 0.
    for each tt-data by tt-data.datmov
                     by tt-data.etbcod:
    
        
        for each chq where chq.datemi = tt-data.datmov no-lock.
        
            if vtipo
            then do:
                if chq.datemi = chq.data
                then next.
            end.
            else do:
                if chq.datemi <> chq.data
                then next.
            end.

            find first chqtit of chq no-lock no-error. 
            if not avail chqtit 
            then next.
            
            if chqtit.etbcod <> tt-data.etbcod
            then next.

            /*
            
            if string(chq.banco) matches "."   or
               string(chq.agencia) matches "." or
               string(chq.conta) matches "."
            then do:
                display chqtit.
                pause.
            end.
            
            */
            
            ii = ii + 1. 
            display tt-data.datmov
                    tt-data.etbcod
                    ii with 1 down. pause 0.

            find first tt-chq where tt-chq.rec = recid(chq) no-error.
            if avail tt-chq
            then do:
                
                if tt-chq.vmarca = "x"
                then next.
                
                if vtipo
                then do:
                    if chq.datemi = chq.data
                    then delete tt-chq.
                end.
                else do:
                    if chq.datemi <> chq.data
                    then delete tt-chq.
                end.

            
            end.
            

           
            find first tt-dif where 
                        int(tt-dif.banco)   = int(chq.banco)        and
                        int(tt-dif.agencia) = int(chq.agencia)      and
                        dec(tt-dif.conta)   = dec(chq.conta) and
                        int(tt-dif.numero)  = int(chq.numero)  no-error.
            if avail tt-dif
            then do:
            
                 delete tt-dif.

                 find first tt-chq where tt-chq.rec = recid(chq)  no-error.
                 if not avail tt-chq
                 then do:
                     create tt-chq.
                     assign tt-chq.rec = recid(chq).
                 end.    
                /*next. */ 
            end.
            else do:
                
                find first tt-dif where 
                            int(tt-dif.banco)  = int(chq.banco)      and
                            int(tt-dif.agencia) = int(chq.agencia)   and
                            dec(tt-dif.conta)  = dec(chq.conta)      and 
                            int(tt-dif.numero) = int(chq.numero)  no-error.
                if avail tt-dif
                then do:
            
                    delete tt-dif.

                    find first tt-chq where tt-chq.rec = recid(chq)  no-error.
                    if not avail tt-chq
                    then do:
                        create tt-chq.
                        assign tt-chq.rec = recid(chq).
                    end.    
                    /*
                    next. 
                     */
                end.
            end.
                                          
                        
            
            find first tt-chq where tt-chq.rec = recid(chq) no-error.
            if not avail tt-chq
            then do:
            
                find first tt-dif where 
                           tt-dif.banco   = chq.banco          and
                           tt-dif.agencia = chq.agencia        and
                           tt-dif.conta   = chq.conta          and  
                           tt-dif.numero  = chq.numero no-lock no-error.
                 
                if not avail tt-dif 
                then do:
                   
                    create tt-dif.
                    assign tt-dif.banco   = chq.banco      
                           tt-dif.agencia = chq.agencia        
                           tt-dif.conta   = chq.conta
                           tt-dif.numero  = chq.numero
                           tt-dif.etbcod  = chqtit.etbcod
                           tt-dif.valor   = chq.valor
                           tt-dif.vstatus  = "NAO LIDO".
                        
                end.
      
            end.
            
        end.
    end.
    
    
    
    vv = 0.
    vtotal = 0.
    for each tt-chq:
    
        find chq where recid(chq) = tt-chq.rec.
        vv = vv + 1.
           
        find first chqtit of chq no-lock no-error.
        if not avail chqtit
        then next.

        find lotdep where lotdep.etbcod = chqtit.etbcod and
                          lotdep.datcon = chq.datemi no-lock no-error.
        if not avail lotdep
        then next.
        if lotdep.lote >= vlote_1 and
           lotdep.lote <= vlote_2
        then.
        else next.
        
        vtotal = vtotal + chq.valor.
        
    end.    
        
            
    for each tt-dif where tt-dif.valor = 0.
        delete tt-dif.
    end.

  
    
    find first tt-dif no-error.
    if not avail tt-dif
    then do:
        
        p-pre = 0.
        p-dia = 0.
        
        for each tt-che:
            delete tt-che.
        end.
 
        for each tt-data:
        
            assign p-pre = p-pre + tt-data.chedre
                   p-dia = p-dia + tt-data.chedia.
                   
        end.



        vtotal = (p-pre + p-dia).
        
        display vtotal label "Encontrado"
                p-pre   label "Pre"
                p-dia   label "Dia"
                (p-pre + p-dia) label "Total"
                vv no-label
                    with frame f-tot 
                        side-label centered overlay.
        
        pause 0.
        vindex = 3.
        if vtipo
        then do:
        
            disp vselect with frame f-select 
                1 down no-label row 18 centered overlay.
            choose field vselect with frame f-select.
            vindex = frame-index.
        end.     

        if vindex = 1 then leave.
        else if vindex = 2
        then do:
            for each tt-chq:
        
                find chq where recid(chq) = tt-chq.rec no-lock.

                find chqenv where chqenv.recenv = int(recid(chq)) no-error.
                if not avail chqenv
                then find chqenv where chqenv.banco = chq.banco and
                           chqenv.agencia = chq.agencia and
                           chqenv.conta = chq.conta and
                           chqenv.numero = chq.numero 
                           no-error.
                if not avail chqenv  
                then do transaction:  
                    create chqenv. 
                    assign chqenv.recenv = int(recid(chq))
                           chqenv.banco = chq.banco
                           chqenv.agencia = chq.agencia
                           chqenv.conta = chq.conta
                           chqenv.numero = chq.numero 
                           chqenv.datenv = today
                           chqenv.chaenv = "COFRE"
                           .
                end.
                else do transaction:
                    if chqenv.chaenv = ""
                    then  chqenv.chaenv = "COFRE".
        
                    chqenv.datenv = today.
                end.

            end.
            leave.
        end.
        else if vindex = 3
        then do:
        do on error undo, leave on endkey undo, retry:

            sresp = yes.
            message "Nenhuma diferenca encontrada. Gerar Arquivo?"
            update sresp.
            if sresp = no
            then leave.
            
            for each tt-chq:
        
                find chq where recid(chq) = tt-chq.rec /*no-lock*/.
           
                find first chqtit of chq no-lock no-error.
                if not avail chqtit
                then next.

                find lotdep where lotdep.etbcod = chqtit.etbcod and
                                  lotdep.datcon = chq.datemi no-lock no-error.
                if not avail lotdep
                then next.
                if lotdep.lote >= vlote_1 and
                   lotdep.lote <= vlote_2
                then.
                else next.
        
                if vtipo 
                then do: 
                    if chq.datemi = chq.data 
                    then next.
                end. 
                else do: 
                    if chq.datemi <> chq.data 
                    then next.
                end.
                
                find first chqtit of chq no-lock no-error. 
                if not avail chqtit 
                then next.
                
                message "Gerando arquivo....".
                    
                display chq.banco
                        chq.numero
                        chq.valor(total)
                        with 1 down centered. pause 0.
                            
                            
                find tt-che where tt-che.rec = recid(chq) no-error.
                if not avail tt-che
                then do:
                    create tt-che.
                    assign tt-che.rec = recid(chq)
                           tt-che.cmc7 = tt-chq.cmc7
                           .
                end.
                /**    
                vtexto = string(chq.numero).
                run verif11.p ( input vtexto , 
                                output v-dig).

                if v-dig <> chq.controle3
                then chq.controle3 = v-dig.
                **/
            end.
        end.  
        run arq_043.p.
        end.
    end. 
    else do:
    
        clear frame f1 all no-pause.
        run tt-dif40.p(input vtotal,
                     input data_arq).
    
    end.   
    
    
    
end.
    
    