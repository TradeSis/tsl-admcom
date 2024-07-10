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
def var qdigitado   as int.
def var qlido       as int.
def var qencontrado as int.

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
    field vmarca as char
    field cmc7   as char.
    
def new shared temp-table tt-dif
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)"
    field vstatus  as char format "x(10)".

def new shared temp-table tt-lischq
    field rec     as   recid
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)"
    field vstatus  as char format "x(10)"
        index ind-1 valor.

def temp-table proc-chq
    field rec-chq as recid
    field banco like chq.banco
    index banco banco.
 
def var cl-banco as int.
def var cl-agencia as int.

def var vlido       as dec.
def var qlido-ne    as dec.
def var qinformado  as dec.
def var vinformado  as dec.
def var vencontrado as dec.
def var qnaolido    as dec.
def var vnaolido    as dec.
def var qlido-je    as dec.
def var qlido-tn    as dec.
def var qlido-nc    as dec.
def var qlido-cd    as dec.
def var qlido-cp    as dec.

def temp-table tt-qtd
    field seq as int
    field des as char
    field qtd as int
    field val as dec
    field dif as char
    index i1 seq.

form tt-qtd.des format "x(30)"
     tt-qtd.qtd 
     tt-qtd.val 
     with frame f-qtd down no-label
     centered color with/red.

{setbrw.i}

do on error undo:
    vdata = data_arq.
    
    update vdata    label "Data Confirmacao"
           data_arq label "     Data do Dia"
           vlote_1  label "Lote" colon 15
           vlote_2  
           vtipo    label "Cheque"
                with frame f1 width 80 side-label color with/cyan.
 
end.
l0:
repeat:

    for each tt-qtd: delete tt-qtd. end.
    
    for each tt-data: delete tt-data. end.
    
    for each tt-chq: delete tt-chq. end.
    
    for each tt-dif: delete tt-dif. end.
    
    ii = 0.

    if opsys = "UNIX"
    then varq2 = "../work/" + 
             string(year(data_arq),"9999") +
             string(month(data_arq),"99")  + 
             string(day(data_arq),"99") + ".dig".
    else varq2 = "..~\work~\" + 
             string(year(data_arq),"9999") +
             string(month(data_arq),"99")  + 
             string(day(data_arq),"99") + ".dig".
         
    qdigitado = 0.
    if search(varq2) <> ?
    then do:
        input from value(varq2).
        repeat:
                       
            import vreg.
            assign vbanco   = substring(vreg,8,3)
                   vagencia = substring(vreg,11,4)
                   vconta   = substring(vreg,15,10)
                   vnumero  = substring(vreg,25,6).
  
            vi = 0.
            repeat on error undo :
                vi = vi + 1.
                disp with frame ff row 20. pause 0.
                if vi = 2
                then do:
                    update vbanco    label "Banco"
                           vagencia  label "Agencia"
                           vconta    label "Conta"
                           vnumero   label "Numero"
                           with frame f-errochar
                           1 down  row 20 side-label.     
                    vi = 1.
                    hide frame f-errochar no-pause.
                end.
                assign
                    cl-banco = int(vbanco)
                    cl-agencia = int(vagencia).    
                leave.
            end. 
                   
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
                           tt-chq.vmarca = "IN"
                           tt-chq.cmc7 = vreg.

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
                           tt-dif.etbcod  = 0
                           tt-dif.vstatus  = "INNE".
                           
                end.
            end.
        end.
        input close.
    end.

    if opsys = "UNIX"
    then varq = "../work/" + 
           string(year(data_arq),"9999") +
           string(month(data_arq),"99")  + 
           string(day(data_arq),"99") + ".txt".
    else varq = "..~\work~\" + 
           string(year(data_arq),"9999") +
           string(month(data_arq),"99")  + 
           string(day(data_arq),"99") + ".txt".

    qlido = 0.
    if search(varq) = ?
    then do:
        message color red/with
                "Arquivo nao encontrado " varq
            view-as alert-box.
        undo, retry.
    end.    
    else do:
        input from value(varq).
        repeat:
            import vreg.
            
            assign vbanco   = substring(vreg,2,3)
                   vagencia = substring(vreg,5,4)
                   vconta   = substring(vreg,23,10)
                   vnumero  = substring(vreg,14,6).
                   
            vi = 0.
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
                    
            if vbanco = "001" 
            then assign vconta =  string(int(substring(vreg,25,8))).
            
            if vbanco = "341" 
            then assign vconta =  substring(vreg,27,6).
            
            if vbanco = "237" 
            then assign vconta = substring(vreg,26,6).
            
            if vbanco = "389" 
            then assign vconta = substring(vreg,24,9).
            
            if vbanco = "409" or
               vbanco = "356" or
               vbanco = "237"
            then assign vconta = substring(vreg,26,7).

            
            if vbanco = "008" 
            then vconta = substring(vreg,24,9).

            
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
                           tt-chq.vmarca = "LI"
                           tt-chq.cmc7 = vreg.
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
                               tt-chq.vmarca = "LI" 
                               tt-chq.cmc7 = vreg.
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
                                   tt-chq.vmarca = "LI"
                                   tt-chq.cmc7 = vreg.
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
                                  tt-dif.etbcod  = 0
                                  tt-dif.vstatus  = "LINE".
                           
                       end.
            
                    end.
 
                end.
            end.
        end.
        input close.
    end.
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
        
    for each tt-chq where tt-chq.vmarca = "LI".
      
        find chq where recid(chq) = tt-chq.rec no-lock.
        
        find first chqtit of chq no-lock no-error.  
        if not avail chqtit  
        then DO:
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
                        tt-dif.vstatus  = "LITN".
                delete TT-CHQ.
             end.
        end.
        else do:
            if vtipo 
            then do: 
                if chq.datemi = chq.data 
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
                           tt-dif.vstatus  = "LICD".
                        
                    end.
      
                    delete tt-chq.
                end.
            end. 
            else do: 
                if chq.datemi <> chq.data 
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
                           tt-dif.vstatus  = "LICP".
                        
                    end.             
                    delete tt-chq.
                
                end.
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
            else do:
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
    /*
    for each tt-chq:
    
        find chq where recid(chq) = tt-chq.rec.
        
        assign
            vv = vv + 1
            qencontrado = qencontrado + 1
            vtotal = vtotal + chq.valor.
        
    end.
    */
    assign qinformado = 0 vinformado = 0 
           qencontrado = 0 vencontrado = 0
           qlido = 0 vlido = 0 vv = 0 vtotal = 0.
    for each tt-chq:
        find chq where recid(chq) = tt-chq.rec no-lock.
        if tt-chq.vmarca = "IN"
        then assign
                qinformado = qinformado + 1
                vinformado = vinformado + chq.valor.
        else if tt-chq.vmarca = "LI"
            then assign
                     qlido = qlido + 1
                     vlido = vlido + chq.valor.   
        assign
            vv = vv + 1
            vtotal = vtotal + chq.valor.
    end. 
    assign
        qlido-ne = 0 qlido-je = 0 qlido-tn = 0 qlido-nc = 0
        qlido-cd = 0 qnaolido = 0 qlido-cp = 0.
    for each tt-dif:
        if tt-dif.vstatus = "LINE"
        then qlido-ne = qlido-ne + 1. 
        else if tt-dif.vstatus = "LIJE"
            then qlido-je = qlido-je + 1.
        else if tt-dif.vstatus = "LITN"
            then qlido-tn = qlido-tn + 1.
        else if tt-dif.vstatus = "LINC"
            then qlido-nc = qlido-nc + 1.
        else if tt-dif.vstatus = "LICD"
            then qlido-cd = qlido-cd + 1.
        else if tt-dif.vstatus = "LICP"
            then qlido-cp = qlido-cp + 1.
        else if tt-dif.vstatus = "NAO LIDO"
            then qnaolido = qnaolido + 1.
    end.   
    create tt-qtd.
    assign
        tt-qtd.seq  = 1
        tt-qtd.des  = "CHEQUES LIDOS ENCONTRADOS"
        tt-qtd.dif  = "LI"
        tt-qtd.qtd  = qlido.
        tt-qtd.val  = vlido.
    create tt-qtd. 
    assign
        tt-qtd.seq  = 2
        tt-qtd.des  = "CHEQUES INFORMADOS"
        tt-qtd.dif  = "IN"
        tt-qtd.qtd  = qinformado.
        tt-qtd.val  = vinformado.
    create tt-qtd.
    assign
        tt-qtd.seq  = 3
        tt-qtd.des  = "======= CHEQUES VALIDOS ======="
        tt-qtd.dif  = "LI+IN"
        tt-qtd.qtd  = qinformado + qlido.
        tt-qtd.val  = vinformado + vlido.

    create tt-qtd.
    assign
        tt-qtd.seq  = 4
        tt-qtd.des  = "LIDOS - CHQ NAO ENCONTRADO"
        tt-qtd.dif  = "LINE"
        tt-qtd.qtd  = qlido-ne.
    create tt-qtd.
    assign
        tt-qtd.seq  = 0
        tt-qtd.des  = "====== CHEQUES NAO LIDO ======"
        tt-qtd.dif  = "NAO LIDO"
        tt-qtd.qtd  = qnaolido.
    create tt-qtd.
    assign
        tt-qtd.seq  = 8
        tt-qtd.des  = "LIDOS - JA ENVIADO"
        tt-qtd.dif  = "LIJE"
        tt-qtd.qtd  = qlido-je.
    create tt-qtd.
    assign
        tt-qtd.seq  = 5
        tt-qtd.des  = "LIDOS - TIT NAO ENCONTRADO"
        tt-qtd.dif  = "LITN"
        tt-qtd.qtd  = qlido-tn.
    create tt-qtd.
    assign
        tt-qtd.seq  = 6
        tt-qtd.des  = "LIDOS - NAO CONFIRMADO"
        tt-qtd.dif  = "LINC"
        tt-qtd.qtd  = qlido-nc.
    if vtipo
    then do:
    create tt-qtd.
    assign
        tt-qtd.seq  = 7
        tt-qtd.des  = "LIDOS - CHEQUE DIA"
        tt-qtd.dif  = "LICD"
        tt-qtd.qtd  = qlido-cd.
    end.
    else do:
    create tt-qtd.
    assign
        tt-qtd.seq  = 7
        tt-qtd.des  = "LIDOS - CHEQUE PRE"
        tt-qtd.dif  = "LICP"
        tt-qtd.qtd  = qlido-cp.
    end.
    create tt-qtd.
    assign
        tt-qtd.seq  = 9
        tt-qtd.des  = "====== TOTAL DIVERGENCIA ======"
        tt-qtd.dif  = "TODI"
        tt-qtd.qtd  = qlido-cd + qlido-nc + qlido-ne + qlido-je + qlido-tn
                        + qlido-cp
        .
    create tt-qtd.
    assign
        tt-qtd.seq  = 10.
    create tt-qtd.
    assign
        tt-qtd.seq  = 11
        tt-qtd.des  = "<<<<<< CONFIRMA >>>>>>"
        tt-qtd.qtd  = qinformado + qlido
        tt-qtd.val  = vinformado + vlido
        .   
    l1: repeat:
        a-seeid = -1 . a-recid = -1. a-seerec = ?. 
        {sklcls.i
            &help = "                   F4=Retorna"
            &file = tt-qtd
            &cfield = tt-qtd.des
            &ofield = " tt-qtd.qtd when tt-qtd.qtd <> 0
                        tt-qtd.val when tt-qtd.val <> 0 "
            &where  = " true use-index i1 "
            &aftselect1 = "
                    if keyfunction(lastkey) = ""return""
                    then do:
                        IF tt-qtd.seq = 11
                        then leave keys-loop.
                        run chqlist ( input tt-qtd.dif, input tt-qtd.qtd ).
                        if tt-qtd.dif = ""NAO LIDO""
                        then next l0.
                        else next l1.
                    end.
                    next keys-loop.
                    "
            &form   = " frame f-qtd "
        }
        if keyfunction(lastkey) = "end-error"
        then do:
            hide frame f-qtd no-pause.
            leave l0.
        end.
        if tt-qtd.seq = 11
        then do:
            hide frame f-qtd no-pause.
            leave l1.
        end.
    end.     
        
    find first tt-dif where tt-dif.vstatus <> "NAO LIDO" no-error.
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

        do on error undo, leave on endkey undo, retry:

            sresp = yes.
            message color red/with
                "Nenhuma diferenca encontrada. Gerar Arquivo?"
                view-as alert-box buttons yes-no
            update sresp.
            if sresp = no
            then leave.
            for each tt-chq:

                find chq where recid(chq) = tt-chq.rec /*no-lock*/.

                find tt-che where tt-che.rec = recid(chq) no-error.
                if not avail tt-che
                then do:
                    create tt-che.
                    assign tt-che.rec  = recid(chq)
                           tt-che.cmc7 = tt-chq.cmc7.
                end.
                    
                vtexto = string(chq.numero).
                run verif11.p ( input vtexto , 
                                output v-dig).


                if v-dig <> chq.controle3
                then chq.controle3 = v-dig.
        
             end.
        end.       
        run arq041.p.

    end. 
    else do:
    
        clear frame f1 all no-pause.
        run tt-dif1.p(input vtotal,
                     input data_arq).
    
    end.   
    leave l0.
end.
procedure  criadif:  
        def input parameter p-status as char.
        find first tt-dif where 
                           tt-dif.banco   = chq.banco          and
                           tt-dif.agencia = chq.agencia        and
                           tt-dif.conta   = chq.conta          and  
                           tt-dif.numero  = chq.numero no-lock no-error.
                 
            if not avail tt-dif  
            then do:
                   
                create tt-dif. 
                assign 
                       tt-dif.banco   = chq.banco       
                       tt-dif.agencia = chq.agencia         
                       tt-dif.conta   = chq.conta 
                       tt-dif.numero  = chq.numero 
                       tt-dif.etbcod  = chqtit.etbcod 
                       tt-dif.valor   = chq.valor 
                       tt-dif.vstatus  = p-status.
                        
            end.
end procedure.
def var vtitle as char.
def var p-conta as char.
procedure chqlist:
    def input parameter p-lista as char.
    def input parameter p-qtd as char.
    vtitle = " " + tt-qtd.des + " " + string(p-qtd) + " ".
    for each tt-lischq: delete tt-lischq. end.
    if p-lista = "IN" or
       p-lista = "LI" or
       p-lista = "LI+IN"
    THEN DO:
        if p-lista = "LI+IN"
        then do: 
            for each tt-chq:
                find chq where recid(chq) = tt-chq.rec no-lock.
                find first chqtit of chq no-lock.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = chqtit.etbcod
                    tt-lischq.valor   = chq.valor
                    .
            end.
        end.    
        else do:
            for each tt-chq where tt-chq.vmarca = p-lista:
                find chq where recid(chq) = tt-chq.rec no-lock.
                find first chqtit of chq no-lock.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = chqtit.etbcod
                    tt-lischq.valor   = chq.valor
                    .
            end.
        end.
    END.
    if p-lista <> "NAO LIDO"
    then do:
        if p-lista = "TODI"
        then do:
            for each tt-dif where tt-dif.vstatus <> "NAO LIDO":
            if tt-dif.valor = 0
            then do:
                create tt-lischq.
                assign
                    tt-lischq.banco   = tt-dif.banco
                    tt-lischq.agencia = tt-dif.agencia
                    tt-lischq.conta   = tt-dif.conta
                    tt-lischq.numero  = tt-dif.numero
                    .
            end.
            else do:        
                find chq where chq.banco = tt-dif.banco    and
                               chq.agencia = tt-dif.agencia and
                               chq.conta   = tt-dif.conta   and
                               chq.numero = tt-dif.numero 
                               no-lock.
                find first chqtit of chq no-lock.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = chqtit.etbcod
                    tt-lischq.valor   = chq.valor
                .
            end.
            end.
        end.
        else do:
            for each tt-dif where tt-dif.vstatus = p-lista:
            if tt-dif.valor = 0
            then do:
                create tt-lischq.
                assign
                    tt-lischq.banco   = tt-dif.banco
                    tt-lischq.agencia = tt-dif.agencia
                    tt-lischq.conta   = tt-dif.conta
                    tt-lischq.numero  = tt-dif.numero
                    .
            end.
            else do:        
                find chq where chq.banco = tt-dif.banco    and
                               chq.agencia = tt-dif.agencia and
                               chq.conta   = tt-dif.conta   and
                               chq.numero = tt-dif.numero 
                               no-lock.
                find first chqtit of chq no-lock.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = chqtit.etbcod
                    tt-lischq.valor   = chq.valor
                .
            end.
            end.
        end.    
    END.
    if p-lista = "NAO LIDO"
    THEN DO:
        clear frame f1 all no-pause.
        run tt-dif.p(input vtotal,
                     input data_arq).
    END.
    else do:
    form tt-lischq.banco     column-label "BANCO"
         tt-lischq.agencia   column-label "AGENCIA"
         tt-lischq.conta     column-label "CONTA"    format "x(12)" 
         tt-lischq.numero    column-label "NUMERO"
         tt-lischq.etbcod    column-label "FIL"
         tt-lischq.valor     column-label "VALOR"
         with frame f-lista  down CENTERED title vtitle.
         
    a-seeid = -1. a-recid = -1. a-seerec = ?.
    ll: repeat:
        a-seeid = -1. a-recid = -1. a-seerec = ?.
 
        {sklcls.i
            &help = "                     ENTER=Seleciona I=Imprime"
            &file = tt-lischq
            &cfield = tt-lischq.valor
            &noncharacter = /*
            &ofield = " tt-lischq.banco
                    tt-lischq.agencia
                    tt-lischq.conta
                    tt-lischq.numero
                    tt-lischq.etbcod
                  "
            &where = true
            &naoexiste1 = " leave ll. "
            &aftselect1 = "
                    if keyfunction(lastkey) = ""RETURN""
                    then do:
                        i-seeid = a-recid.
                        i-recid = recid(tt-lischq).
                        p-conta = tt-lischq.conta.
                        run procura-che ( tt-lischq.banco,
                              tt-lischq.agencia,
                              input-output p-conta,
                              tt-lischq.numero).
                        if p-conta <> tt-lischq.conta
                        then delete tt-lischq.
                        next ll.
                        a-recid = i-recid.
                        a-seeid = i-seeid.
                        next keys-loop.
                    end.
                    "
            &otherkeys1 = " if keyfunction(lastkey) = ""I"" or
                               keyfunction(lastkey) = ""i"" 
                            then leave keys-loop.
                          "  
            &form  = " frame f-lista "
        }
        if keyfunction(lastkey) = "end-error"
        then do:
            leave ll.
        end.
        if keyfunction(lastkey) = "I" or
           keyfunction(lastkey) = "i" 
        then do:
            def var varquivo as char.
            if opsys = "UNIX"
            then varquivo = "/admcom/relat/le_chp1" + string(time).
            else varquivo = "l:\relat\le_chp1" + string(time).
    
            {mdad.i
                &Saida     = "value(varquivo)"
                &Page-Size = "0"
                &Cond-Var  = "100"
                &Page-Line = "0"
                &Nom-Rel   = ""le_chp1""
                &Nom-Sis   = """SISTEMA FINANCEIRO"""
                &Tit-Rel   = """CONTROLE DE CHEQUES"""
                &Width     = "100"
                &Form      = "frame f-cabcab"}

            put skip
                vtitle format "x(80)"
                skip.

            for each tt-lischq :
                disp
                tt-lischq.banco     column-label "BANCO"
                tt-lischq.agencia   column-label "AGENCIA"
                tt-lischq.conta     column-label "CONTA"    format "x(12)" 
                tt-lischq.numero    column-label "NUMERO"
                tt-lischq.etbcod    column-label "FIL"
                tt-lischq.valor     column-label "VALOR"
                with frame f-lista1  down.
                down with frame f-lista1.
                 
            end.
            output close.
        
            if opsys = "UNIX"
            then do:
                run visurel.p (input varquivo, input "").
            end.
            else do:
                {mrod.i}.
            end.

        end.        
    end.
    end.
end procedure.

def var v-title as char.
procedure procura-che:
    def input parameter p-banco as int.
    def input parameter p-agencia as int.
    def input-output parameter p-conta as char.
    def input parameter p-numero as char.
    v-title = "(B)" + string(p-banco) + " (A)" + string(p-agencia) 
                + " (C)" + p-conta + " (N)" + p-numero.

    form chq.banco     column-label "BANCO"
         chq.agencia   column-label "AGENCIA"
         chq.conta     column-label "CONTA"    format "x(12)" 
         chq.numero    column-label "NUMERO"
         chq.valor     column-label "VALOR"
         chq.datemi    column-label "EMISSAO"
         chq.data      column-labeL "B/PARA"
         chqtit.etbcod column-label "FIL"
         with frame f-procchq down CENTERED title v-title
         color with/black.
    for each proc-chq:
        delete proc-chq.
    end.    
    for each chq where chq.banco   = p-banco and
                       chq.agencia = p-agencia and
                       chq.conta   = p-conta 
                       no-lock:
        find first proc-chq where 
            proc-chq.rec-chq = recid(chq) no-error.
        if not avail proc-chq
        then do:
            create proc-chq.
            proc-chq.rec-chq = recid(chq).
            proc-chq.banco = chq.banco.
        end.    
    end.
    for each chq where chq.banco   = p-banco and
                       chq.agencia = p-agencia and
                       chq.numero   = p-numero 
                       no-lock:
        find first proc-chq where 
            proc-chq.rec-chq = recid(chq) no-error.
        if not avail proc-chq
        then do:
            create proc-chq.
            proc-chq.rec-chq = recid(chq).
            proc-chq.banco = chq.banco.
        end.    
    end.                    
    form proc-chq.banco     column-label "BANCO"
         chq.agencia   column-label "AGENCIA"
         chq.conta     column-label "CONTA"    format "x(12)" 
         chq.numero    column-label "NUMERO"
         chq.valor     column-label "VALOR"
         chq.datemi    column-label "EMISSAO"
         chq.data      column-labeL "B/PARA"
         chqtit.etbcod column-label "FIL"
         with frame f-procchq down CENTERED title v-title
         color with/black.
    l1: repeat:
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?.
        
    {sklcls.i
        &help = "                    F1=Altera CONTA    F4=Retorna"
        &file = proc-chq
        &cfield = proc-chq.banco
        &noncharacter = /*
        &ofield = " chq.agencia
                    chq.conta  
                    chq.numero
                    chq.valor
                    chq.datemi 
                    chq.data   
                    chqtit.etbcod  when avail chqtit
                    "
        &where     = " true use-index banco "
        &aftfnd1   = "  find chq where recid(chq) = proc-chq.rec-chq 
                                no-lock.
                        find first chqtit of chq no-lock no-error. 
                     "
        &naoexite1 = " bell.
                       message color red/with
                            "" Nenhum Registro encontrado! ""
                            view-as alert-box .
                      " 
        &aftselect1 = "
                        if keyfunction(lastkey) = ""GO""
                        then do:
                            find chq where recid(chq) = proc-chq.rec-chq
                                    no-error.
                            find first chqtit of chq  no-error.
                            update chq.conta with frame f-procchq.
                            if avail chqtit
                            then chqtit.conta = chq.conta.
                            p-conta = chq.conta.
                            next keys-loop.
                        end.
                      "
        &form = "  frame f-procchq "
     }  
        leave l1.              
    end.                   
end procedure.


    
    
