{admcab.i}
def var qtd_cheque      as int.
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

def new shared temp-table tt-che
    field rec  as recid
    field cmc7 as char format "x(60)"
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
    field rec     as   recid
    field banco   like chq.banco
    field agencia like chq.agencia
    field conta   like chq.conta
    field numero  like chq.numero
    field etbcod  like chqtit.etbcod
    field valor   like chq.valor
    field marca   as char format "x(01)"
    field vstatus  as char format "x(10)"
    field cmc7 as char format "x(60)"
        index ind-1 valor.

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
def var vi as int.

def var qlido       as dec.
def var qliod       as dec.
def var vlido       as dec.
def var qlido-ne    as dec.
def var qinformado  as dec.
def var vinformado  as dec.
def var qencontrado as dec.
def var vencontrado as dec.
def var qnaolido    as dec.
def var vnaolido    as dec.
def var qlido-je    as dec.
def var qlido-tn    as dec.
def var qlido-nc    as dec.
def var qlido-cd    as dec.
def var nlido-je    as dec.

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

do on error undo, return:
    update vdata  validate(vdata <> ?,"")  label "Data Cheque" /*at 01*/
           data_arq validate(data_arq <> ?,"") label "Data do Dia" /*at 01*/
                with frame f1 width 80 side-label overlay
                color with/cyan row 3.
end.
l0:
repeat:                   
    view frame f1 .
    disp vdata data_arq with frame f1.
    pause 0.
    for each tt-data: delete tt-data. end.
    
    for each tt-chq: delete tt-chq. end.
    
    for each tt-dif: delete tt-dif. end.
    
    for each tt-qtd: delete tt-qtd. end.     

    vtipo = yes.
    
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
                           tt-chq.cmc7 = substr(vreg,32,35)
                           tt-chq.vmarca = "IN" /*INFORMADO*/.
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
                    assign 
                        tt-dif.cmc7 = substr(vreg,32,35)
                        tt-dif.banco   = int(vbanco)      
                        tt-dif.agencia = int(vagencia)        
                        tt-dif.conta   = vconta  
                        tt-dif.numero  = vnumero
                        tt-dif.etbcod  = 0
                        tt-dif.vstatus  = "INNE" /*INFORMADO NAO ENCONTRADO*/
                        .
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
    qlido-ne = 0.
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
            assign vbanco   = substring(vreg,2,3)
                   vagencia = substring(vreg,5,4)
                   vconta   = substring(vreg,23,10)
                   vnumero  = substring(vreg,14,6).
                   
            vi = 0.
            repeat on error undo :
                vi = vi + 1.
                disp with frame ff1 row 20. pause 0.
                if vi = 2
                then do:
                    update vbanco    label "Banco"
                           vagencia  label "Agencia"
                           vconta    label "Conta"
                           vnumero   label "Numero"
                           with frame f-errochar1
                           1 down  row 20 side-label.     
                    vi = 1.
                    hide frame f-errochar no-pause.
                end.
                assign
                    cl-banco = int(vbanco)
                    cl-agencia = int(vagencia).    
                leave.
            end. 
                    
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
                           tt-chq.vmarca = "LI" /*LIDO*/.
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
                               tt-chq.vmarca = "LI" /*LIDO*/.
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
                                   tt-chq.vmarca = "LI" /*LIDO*/.
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
                           assign tt-dif.cmc7    = vreg
                                  tt-dif.banco   = int(vbanco)      
                                  tt-dif.agencia = int(vagencia)        
                                  tt-dif.conta   = vconta  
                                  tt-dif.numero  = vnumero
                                  tt-dif.etbcod  = 0
                                  tt-dif.vstatus = "LINE" /*NAO ENCONTRADO*/.
                       end.
                    end.
                end.
            end.
        end.
        input close.
    end.
    /**
    for each tt-chq where tt-chq.cmc7 <> "" :
        create tt-che.
        tt-che.rec = tt-chq.rec.
        tt-che.cmc7 = tt-chq.cmc7.
    end.    
   
    message "aqui1". pause.
    run /admcom/Claudir/arq_044.p .
    */
    ii = 0.
    for each chq use-index chqdata 
                 where chq.data = vdata no-lock:
        
        find first chqtit use-index ind-1
                          where chqtit.banco   = chq.banco    and
                                chqtit.agencia = chq.agencia  and
                                chqtit.conta   = chq.conta    and
                                chqtit.numero  = chq.numero no-lock no-error.
        if not avail chqtit
        then next.
        find deposito where deposito.etbcod = chqtit.etbcod and
                            deposito.datmov = chq.datemi no-lock no-error.
        if avail deposito and 
        deposito.datcon <> ? 
        then. 
        else next.
        if chq.datemi = chq.data
        then next.
        find first tt-data where tt-data.datmov = vdata no-error.
        if not avail tt-data
        then do:
            create tt-data.
            assign tt-data.datmov = vdata.
        end.
        assign tt-data.chedre = tt-data.chedre + chq.valor.
        find first tt-chq where tt-chq.rec = recid(chq) no-error.
        if not avail tt-chq
        then do:
            find chqenv where chqenv.recenv = int(recid(chq)) and
                        chqenv.chaenv = ""
                    no-lock no-error.
            if not avail chqenv
            then find chqenv where chqenv.banco = chq.banco and
                           chqenv.agencia = chq.agencia and
                           chqenv.conta = chq.conta and
                           chqenv.numero = chq.numero and
                           chqenv.chaenv = ""
                           no-error.
 
            /*if avail chqenv
            then do:
                run criadif ( input "NLJE" ).
            end.
            else do:*/
                run criadif ( input "NAO LIDO" ).
                qnaolido = qnaolido + 1.
            /*end.*/
        END.
        ii = ii + 1.
        display "Processando CHEQUES ...... >> " 
                tt-data.datmov
                tt-data.etbcod
                ii with frame f-pro 1 down no-label no-box.
        pause 0.
    end.

    for each tt-chq where tt-chq.vmarca = "LI".
        find chq where recid(chq) = tt-chq.rec no-lock.
        find chqenv where chqenv.recenv = int(recid(chq)) 
            and chqenv.chaenv = "" no-lock no-error.
        if not avail chqenv
        then find chqenv where chqenv.banco = chq.banco and
                           chqenv.agencia = chq.agencia and
                           chqenv.conta = chq.conta and
                           chqenv.numero = chq.numero and
                           chqenv.chaenv = ""
                           no-error.

        if avail chqenv
        then do:
            /*run criadif ( input "LIJE" ). /*LIDO JA ENVIADO*/
            delete tt-chq.
            next.*/
        end.
        if chq.data <> vdata
        then do:
            run criadif ( input "LIOD" ). /*LIDO CHEQUE OUTRA DATA*/
            delete tt-chq.
            next.
        end.
        find first chqtit of chq no-lock no-error.  
        if not avail chqtit  
        then DO:
            run criadif ( input "LITN" ). /*LIDO TITULO NAO ENCONTRADO*/
            delete tt-chq.
            next.
        END.
        find deposito where deposito.etbcod = chqtit.etbcod and
                            deposito.datmov = chq.datemi no-lock no-error.
        if avail deposito and 
        deposito.datcon <> ? 
        then. 
        else DO:
            run criadif ( input "LINC" ). /*LIDO NAO CONFIRMADO*/
            delete tt-chq.
            next.
        END.
        if chq.datemi = chq.data  
        then do: 
            run criadif ( input "LICD" ). /*LIDO CHEQUE DIA*/
            delete tt-chq.
            next.
        end. 
        if chq.data <> vdata
        then do:
            run criadif ( input "LICD" ). /*LIDO CHEQUE DIA*/
            delete tt-chq.
            next.

        end.
    end.
    hide frame f-pro no-pause.
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
            vtotal = vtotal + chq.valor
            qtd_cheque = qtd_cheque + 1.
    end. 
    assign
        qlido-ne = 0 qlido-je = 0 qlido-tn = 0 qlido-nc = 0
        qlido-cd = 0 qnaolido = 0 qliod = 0.
    for each tt-dif:
        if tt-dif.vstatus = "LINE"
        then qlido-ne = qlido-ne + 1. 
        else if tt-dif.vstatus = "LIJE"
            then qlido-je = qlido-je + 1.
        else if tt-dif.vstatus = "NLJE"
            then nlido-je = nlido-je + 1.
        else if tt-dif.vstatus = "LITN"
            then qlido-tn = qlido-tn + 1.
        else if tt-dif.vstatus = "LINC"
            then qlido-nc = qlido-nc + 1.
        else if tt-dif.vstatus = "LICD"
            then qlido-cd = qlido-cd + 1.
        else if tt-dif.vstatus = "NAO LIDO"
            then qnaolido = qnaolido + 1.
        else if tt-dif.vstatus = "LIOD"
            then qliod = qliod + 1.
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
        tt-qtd.seq  = 3.5
        tt-qtd.des  = "LIDOS - DE OUTRA DATA"
        tt-qtd.dif  = "LIOD"
        tt-qtd.qtd  = qliod.
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
        tt-qtd.seq  = -1
        tt-qtd.des  = "NAO LIDOS - JA ENVIADO"
        tt-qtd.dif  = "NLJE"
        tt-qtd.qtd  = nlido-je.
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
    create tt-qtd.
    assign
        tt-qtd.seq  = 7
        tt-qtd.des  = "LIDOS - CHEQUE DIA"
        tt-qtd.dif  = "LICD"
        tt-qtd.qtd  = qlido-cd.
    create tt-qtd.
    assign
        tt-qtd.seq  = 9
        tt-qtd.des  = "====== TOTAL DIVERGENCIA ======"
        tt-qtd.dif  = "TODI"
        tt-qtd.qtd  = qlido-cd + qlido-nc + qlido-ne + qlido-je + qlido-tn
                + qliod
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
                        /*if tt-qtd.dif = ""NAO LIDO""
                        then next l0.
                        else next l1.*/
                        next l0.
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
    find first tt-dif where tt-dif.vstatus <> "NAO LIDO" and
                            tt-dif.vstatus <> "NLJE"
                    NO-ERROR.
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
        
        display qtd_cheque label "Qtd" format ">>9"
                vtotal label "Encontrado"
                p-pre   label "Pre"
                p-dia   label "Dia"
                (p-pre + p-dia) label "Total"
                    with frame f-tot 
                        side-label centered overlay.
        

        do on error undo, leave on endkey undo, retry:

            sresp = yes.
            message color red/with
                "Nenhuma diferenca encontrada" skip
                 "Gerar Arquivo?"
                view-as alert-box buttons yes-no
                update sresp.
            if sresp = no
            then leave.
            
            for each tt-chq:
        
                find chq where recid(chq) = tt-chq.rec /*no-lock*/.
                /**
                message "Gerando arquivo....".
                    
                display chq.banco
                        chq.numero
                        chq.valor(total)
                        with 1 down centered. pause 0.
                            
                **/            
                find tt-che where tt-che.rec = recid(chq) no-error.
                if not avail tt-che
                then do:
                    create tt-che.
                    assign 
                        tt-che.rec = recid(chq)
                        tt-che.cmc7 = tt-chq.cmc7.
                end.
                /*    
                vtexto = string(chq.numero).
                run verif11.p ( input vtexto , 
                                output v-dig).

                if v-dig <> chq.controle3
                then chq.controle3 = v-dig.
                */
            end.
        end.      
         
        run arq_044.p.

    end. 
    else do:
    
        sresp = no.
        message color red/with
            "Divergencias encontradas" skip 
            "Gerar Arquivo?" 
            view-as alert-box buttons yes-no update sresp.
        if sresp
        then do:
            
            for each tt-che:
                delete tt-che.
            end.
            
            for each tt-chq:
        
                find chq where recid(chq) = tt-chq.rec /*no-lock*/.

                message "Gerando arquivo....".
                    
                display chq.banco
                        chq.numero
                        chq.valor(total)
                        with frame ff2 1 down centered. pause 0.
                            
                            
                find tt-che where tt-che.rec = recid(chq) no-error.
                if not avail tt-che
                then do:
                    create tt-che.
                    assign tt-che.rec = recid(chq).
                end.
                    
                vtexto = string(chq.numero).
                run verif11.p ( input vtexto , 
                                output v-dig).

                if v-dig <> chq.controle3
                then chq.controle3 = v-dig.
        
            end.
            run arq_044.p.
        end.
        else do:
        
            clear frame f1 all no-pause.
            run dif_chp4.p(input qtd_cheque,
                          input vtotal,
                          input data_arq).
                          
        end.
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
                assign tt-dif.rec     = recid(chq)
                       tt-dif.banco   = chq.banco       
                       tt-dif.agencia = chq.agencia         
                       tt-dif.conta   = chq.conta 
                       tt-dif.numero  = chq.numero 
                       tt-dif.etbcod  = if avail chqtit
                                        then chqtit.etbcod else 0
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
                find first chqtit of chq no-lock no-error.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = if avail chqtit
                                then chqtit.etbcod else 0
                    tt-lischq.valor   = chq.valor
                    .
            end.
        end.    
        else do:
            for each tt-chq where tt-chq.vmarca = p-lista:
                find chq where recid(chq) = tt-chq.rec no-lock.
                find first chqtit of chq no-lock no-error.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = if avail chqtit
                            then chqtit.etbcod else 0
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
            if tt-dif.rec = ?
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
                find chq where recid(chq) = tt-dif.rec no-lock.
                find first chqtit of chq no-lock no-error.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = if avail chqtit
                            then chqtit.etbcod  else 0
                    tt-lischq.valor   = chq.valor
                .
            end.
            end.
        end.
        else do:
            for each tt-dif where tt-dif.vstatus = p-lista:
            if tt-dif.rec = ?
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
                find chq where recid(chq) = tt-dif.rec no-lock.
                find first chqtit of chq no-lock no-error.
                create tt-lischq.
                assign
                    tt-lischq.rec     = recid(chq)
                    tt-lischq.banco   = chq.banco
                    tt-lischq.agencia = chq.agencia
                    tt-lischq.conta   = chq.conta
                    tt-lischq.numero  = chq.numero
                    tt-lischq.etbcod  = if avail chqtit
                                then chqtit.etbcod  else 0
                    tt-lischq.valor   = chq.valor
                .
            end.
            end.
        end.    
    END.
    if p-lista = "NAO LIDO"
    THEN DO:
        run dif_chp4.p(input qtd_cheque,
                          input vtotal,
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
         
    ll: repeat:
        assign a-seeid = -1 a-recid = -1 a-seerec = ?.
     .
        {sklcls.i
            &help = "                     ENTER=Seleciona I=Imprime"
            &file = tt-lischq
            &cfield = tt-lischq.valor
            &noncharacter = /*
            &ofield = " tt-lischq.banco
                    tt-lischq.agencia
                    tt-lischq.conta
                    tt-lischq.numero
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
    find first proc-chq no-error.
    if avail proc-chq
    then do:
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
                            update  chq.agencia
                                    chq.conta 
                                    chq.numero with frame f-procchq.
                            if avail chqtit
                            then assign
                                    chqtit.conta = chq.conta
                                    chqtit.agencia = chq.agencia
                                    chqtit.numero = chq.numero
                                    .
                            p-conta = chq.conta.
                            next keys-loop.
                        end.
                      "
        &form = "  frame f-procchq "
     }  
        leave l1.              
    end.
    end. 
end procedure.
