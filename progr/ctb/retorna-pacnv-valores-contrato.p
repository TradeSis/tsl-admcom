/*
#1 - Seguro
*/
{admcab.i}
def input parameter rec-plani as recid.
def input parameter rec-contrato as recid.
def input parameter rec-titulo as recid.

{retorna-pacnv.i}

def var vi as int.
def var val-chepres as dec.
def var val-combo   as dec.
def var val-voucher as dec.
def var val-black   as dec.
def var vpar-novacao as int.

def buffer btitulo for titulo.
def buffer ctitulo for titulo.
def buffer dtitulo for titulo.
def buffer etitulo for titulo.
def buffer ntitulo for titulo.

def var vnumero as char.

if rec-contrato <> ?
then do:
    find fin.contrato where 
            recid(fin.contrato) = rec-contrato no-lock no-error.
    /*if avail fin.contrato and fin.contrato.modcod begins "CP"
    then pacnv-crepes = pacnv-crepes + fin.contrato.vltotal.
    else*/ if avail fin.contrato  
    then do:
        find last contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                               no-lock no-error.
        if avail contnf
        then do:
            find last plani where
                      plani.etbcod = contnf.etbcod and   
                      plani.placod = contnf.placod and
                      plani.serie  = contnf.notaser
                      no-lock no-error.
            if avail plani
            then run val-plani-contrato.
            else if rec-plani <> ?
                then do:
                    find plani where recid(plani) = rec-plani no-lock.
                    run val-plani-contrato.
                end.
                else do:
                    find last plani where plani.movtdc = 5 and
                                     plani.desti  = contrato.clicod and
                                     plani.pladat = contrato.dtinicial and
                                     plani.biss   = contrato.vltotal
                                     no-lock no-error.
                    if avail plani
                    then run val-plani-contrato.                  
                    else run valor-novacao.
                end.
        end.
        else do:
            if rec-plani <> ?
            then do:
                find plani where recid(plani) = rec-plani no-lock.
                run val-plani-contrato.
            end.
            else do:

                run valor-novacao.

                if pacnv-novacao = no and
                   pacnv-renovacao = no and
                   pacnv-feiraonl = no
                then do:               
                    find last plani where plani.movtdc = 5 and
                                      plani.desti  = contrato.clicod and
                                      plani.pladat = contrato.dtinicial and
                                      plani.biss   = contrato.vltotal
                                      no-lock no-error.
                    if avail plani
                    then run val-plani-contrato. 
                end.
            end.
        end.
    end.
    else do:
        if rec-plani <> ?
        then do:
            find plani where recid(plani) = rec-plani no-lock.
            run val-plani.
        end.
        else do:
            find last plani where plani.movtdc = 5 and
                             plani.desti  = contrato.clicod and
                             plani.pladat = contrato.dtinicial and
                             plani.biss   = contrato.vltotal
                             no-lock no-error.
            if avail plani
            then run val-plani. 
        end.
    end.
end.
else if rec-plani <> ?
then do:
    find plani where recid(plani) = rec-plani no-lock no-error.
    find last contnf where
              contnf.etbcod = plani.etbcod and
              contnf.placod = plani.placod and
              contnf.notaser = plani.serie
              no-lock no-error.
    if avail contnf
    then do:
        find last contrato where
                  contrato.contnum = contnf.contnum and
                  contrato.dtinicial = plani.pladat
                  no-lock no-error.
        if avail contrato
        then do:
            run val-plani-contrato.
        end.
        else run val-plani-contnf.
    end.
    else run val-plani.
end.
else if rec-titulo <> ?
then do:
    find titulo where recid(titulo) = rec-titulo no-lock.
    if titulo.vlf_principal > 0
    then assign
            pacnv-aprazo = titulo.titvlcob
            pacnv-principal = titulo.vlf_principal
            pacnv-acrescimo = titulo.vlf_acrescimo
            pacnv-seguro = titulo.titdesc.
    else do:
    if titulo.modcod = "VVI"
    then do:
        vnumero = "".
        for each plani use-index plasai 
                       where plani.movtdc = 5 and
                             plani.desti  = titulo.clifor and
                             plani.pladat = titulo.titdtemi and
                             plani.etbcod = titulo.etbcod and
                             plani.platot = titulo.titvlcob
                             no-lock:
            vnumero = plani.serie + string(plani.numero).
            if vnumero = titulo.titnum
            then do:
                    .
                if plani.biss > 0
                then assign
                    pacnv-aprazo = titulo.titvlcob
                    pacnv-principal = plani.platot
                    pacnv-acrescimo = titulo.titvlcob - plani.platot
                    pacnv-seguro = titulo.titdesc.

        
                leave.
            end.
            else vnumero = "".
        end. 
        if vnumero = ""
        then
        for each plani use-index plasai 
                       where plani.movtdc = 5 and
                             plani.desti  = titulo.clifor and
                             plani.pladat = titulo.titdtemi and
                             plani.etbcod = titulo.etbcod and
                             plani.biss = titulo.titvlcob
                             no-lock:
            vnumero = plani.serie + string(plani.numero).
            if vnumero = titulo.titnum
            then do:
                    .
                if plani.biss > 0
                then assign
                    pacnv-aprazo = titulo.titvlcob
                    pacnv-principal = plani.platot
                    pacnv-acrescimo = titulo.titvlcob - plani.platot
                    pacnv-seguro = titulo.titdesc.

        
                leave.
            end.
            else vnumero = "".
        end. 

        if pacnv-principal = 0
        then pacnv-principal = titulo.titvlcob.
    end.
    else do:
    find contrato where 
            contrato.contnum = int(titulo.titnum) no-lock no-error.
    if avail contrato
    then do:
        find last contnf where contnf.etbcod = contrato.etbcod and
                               contnf.contnum = contrato.contnum
                               no-lock no-error.
        if avail contnf
        then do:
            find last plani where
                      plani.etbcod = contnf.etbcod and   
                      plani.placod = contnf.placod and
                      plani.serie  = contnf.notaser
                      no-lock no-error.
            if avail plani
            then do:
                run val-plani-contrato.
                run pacnv-acrescimo-parcela.
            end.
            else if rec-plani <> ?
                then do:
                    find plani where recid(plani) = rec-plani 
                                no-lock no-error.
                    if avail plani
                    then do:            
                        run val-plani-contrato.
                        run pacnv-acrescimo-parcela.
                    end.
                end.
                else do:
                    find last plani where plani.movtdc = 5 and
                                     plani.desti  = contrato.clicod and
                                     plani.pladat = contrato.dtinicial and
                                     plani.biss   = contrato.vltotal
                                     no-lock no-error.
                    if avail plani
                    then do:
                        run val-plani-contrato.    
                        run pacnv-acrescimo-parcela.
                    end.                  
                end.
        end.
        else do:
            if rec-plani <> ?
            then do:
                find plani where recid(plani) = rec-plani no-lock no-error.
                if avail plani
                then do:
                    run val-plani-contrato.
                    run pacnv-acrescimo-parcela.
                end.
            end.
            else do:

                vpar-novacao = 0.
                run valor-novacao.
        
                if pacnv-novacao = no and
                   pacnv-renovacao = no and
                   pacnv-feiraonl = no
                then do:               
                    find last plani where plani.movtdc = 5 and
                                      plani.desti  = contrato.clicod and
                                      plani.pladat = contrato.dtinicial and
                                      plani.biss   = contrato.vltotal
                                      no-lock no-error.
                    if avail plani
                    then do:
                        run val-plani-contrato.
                        run pacnv-acrescimo-parcela.
                    end.
                end.
                else do:
                    if  pacnv-acrescimo > 0
                    then  pacnv-acrescimo = pacnv-acrescimo / vpar-novacao.
                end.
            end.
        end.
    end.
    else do:
        find last contnf where
                  contnf.etbcod = titulo.etbcod and
                  contnf.contnum = int(titulo.titnum)
                  no-lock no-error.
        if avail contnf
        then do:
            find last plani where
                      plani.etbcod = contnf.etbcod and   
                      plani.placod = contnf.placod and
                      plani.serie  = contnf.notaser
                      no-lock no-error.
            if avail plani
            then do:
                run val-plani-contrato.
                run pacnv-acrescimo-parcela.
            end.
            else if rec-plani <> ?
                then do:
                    find plani where recid(plani) = rec-plani no-lock
                            no-error.
                    if avail plani
                    then do:        
                        run val-plani-contrato.
                        run pacnv-acrescimo-parcela.
                    end.
                end.
                else do:
                    find last plani where plani.movtdc = 5 and
                                     plani.desti  = contrato.clicod and
                                     plani.pladat = contrato.dtinicial and
                                     plani.biss   = contrato.vltotal
                                     no-lock no-error.
                    if avail plani
                    then do:
                        run val-plani-contrato.    
                        run pacnv-acrescimo-parcela.
                    end.                  
                end.
        end.
    end. 
    end.
    assign
        pacnv-aprazo = titulo.titvlcob
        pacnv-principal = pacnv-aprazo - pacnv-acrescimo
        pacnv-seguro = titulo.titdesc
               .
    if pacnv-principal < 0
    then assign
            pacnv-principal = 0
            pacnv-acrescimo = 0
            pacnv-seguro = 0
            .
    else do:
        pacnv-principal = round(pacnv-principal,2).
        pacnv-acrescimo = round(pacnv-acrescimo,2).
        if pacnv-principal > titulo.titvlcob
        then assign
                pacnv-principal = titulo.titvlcob
                pacnv-acrescimo = 0.
        else if pacnv-principal + pacnv-acrescimo > titulo.titvlcob
        then pacnv-acrescimo = pacnv-acrescimo -
                   ((pacnv-principal + pacnv-acrescimo) - titulo.titvlcob).
        else if pacnv-principal + pacnv-acrescimo < titulo.titvlcob
        then assign
                 pacnv-principal = titulo.titvlcob
                 pacnv-acrescimo = 0.           
                
    end.
    end.
end.


procedure val-plani-contrato:
    run valor-descontar.
    
    pacnv-entrada   = contrato.vlentra.
    /*if pacnv-entrada = 0
    then*/ do:
        find first etitulo where
               etitulo.empcod = 19 and
               etitulo.titnat = no and
               etitulo.modcod = contrato.modcod and
               etitulo.etbcod = contrato.etbcod and 
               etitulo.clifor = contrato.clicod and
               etitulo.titnum = string(contrato.contnum) and
               etitulo.titpar = 0
               no-lock no-error.
        if avail etitulo 
        then pacnv-entrada   = etitulo.titvlcob.
        else pacnv-entrada   = 0.
    end.    
     
    assign
        pacnv-aprazo    = contrato.vltotal - pacnv-entrada
        pacnv-seguro    = plani.seguro
        pacnv-troca     = if plani.serie = "3" 
                          then plani.vlserv else 0
        pacnv-abate     = pacnv-troca + val-chepres + val-voucher +
                          val-black  
        pacnv-principal = plani.platot - 
                            (pacnv-abate + pacnv-entrada /*#1+ plani.seguro*/)
        pacnv-acrescimo = pacnv-aprazo - pacnv-principal
        .

    if pacnv-troca = pacnv-entrada or
       pacnv-abate  = pacnv-entrada 
    then assign
            pacnv-principal = pacnv-principal + pacnv-entrada
            pacnv-abate = pacnv-abate - pacnv-entrada
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .              
    
    if pacnv-principal < 0
    then assign
            pacnv-principal = pacnv-aprazo
            pacnv-seguro = 0
            pacnv-troca = plani.platot - pacnv-principal
            pacnv-abate = plani.platot - pacnv-principal
            pacnv-acrescimo = 0
            .
    if int(pacnv-entrada) = int(pacnv-abate)
    then pacnv-abate = 0.

    if pacnv-acrescimo < 0 and
       plani.seguro = (-1 * pacnv-acrescimo)
    then pacnv-acrescimo = 0.
       
end procedure.

procedure val-plani-contnf:

    run valor-descontar.

    if plani.crecod = 2
    then do:
        find first btitulo where btitulo.clifor   = plani.desti and
                                btitulo.titnum   = string(contnf.contnum) and
                                btitulo.titdtemi = plani.pladat and
                                btitulo.titpar = 0
                                no-lock no-error.
        if avail btitulo
        then pacnv-entrada   = btitulo.titvlcob.           
        assign
            pacnv-aprazo    = plani.biss - pacnv-entrada
            pacnv-seguro    = plani.seguro
            pacnv-troca     = if plani.serie = "3"
                              then plani.vlserv else 0
            pacnv-abate     = pacnv-troca + val-chepres +  
                              val-voucher +  val-black /*+ pacnv-seguro*/ 
            pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada)
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

        if pacnv-troca = pacnv-entrada
        then assign
            pacnv-principal = pacnv-principal + pacnv-entrada
            pacnv-abate = pacnv-abate - pacnv-entrada
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .   
    end.
    else do:
        assign
            pacnv-seguro    = plani.seguro
            pacnv-avista = plani.platot
            pacnv-troca     = if plani.serie = "3"
                              then plani.vlserv else 0
            pacnv-abate     = pacnv-troca + val-chepres +  
                              val-voucher +  val-black 
            pacnv-principal = pacnv-avista - pacnv-abate
            .
        if pacnv-principal < 0
        then pacnv-principal = 0.    
    end.

    if pacnv-acrescimo < 0 and
       plani.seguro = (-1 * pacnv-acrescimo)
    then pacnv-acrescimo = 0.

end procedure.

procedure val-plani:
    run valor-descontar.
    
    if plani.crecod = 2
    then do:
        find first btitulo where
                   btitulo.clifor = plani.desti and
                   btitulo.titdtemi = plani.pladat and
                   btitulo.titpar = 0
                   no-lock no-error.
        if avail btitulo
        then pacnv-entrada   = btitulo.titvlcob.           
        assign
            pacnv-aprazo    = plani.biss - pacnv-entrada
            pacnv-seguro    = plani.seguro
            pacnv-troca     = if plani.serie = "3" 
                              then plani.vlserv else 0
            pacnv-abate     = pacnv-troca + val-chepres + val-voucher + 
                                val-black /*+ pacnv-seguro*/ 
            pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada) 
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

        if pacnv-troca = pacnv-entrada
        then assign
            pacnv-principal = pacnv-principal + pacnv-entrada
            pacnv-abate = pacnv-abate - pacnv-entrada
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .   

        if pacnv-aprazo = 0 and plani.platot > 0
        then pacnv-avista = plani.platot.
        
    end.
    else do:
        assign
            pacnv-troca     = if plani.serie = "3" 
                              then plani.vlserv else 0
            pacnv-abate     = pacnv-troca + val-chepres + val-voucher + 
                                val-black /*+ pacnv-seguro*/ 
            pacnv-avista = plani.platot 
            pacnv-aprazo = plani.biss
            pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada)
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal.
            
        if pacnv-aprazo <= 0
        then pacnv-acrescimo = 0.
        if pacnv-principal < 0
        then pacnv-principal = 0.
    end.    
    
    if pacnv-aprazo = 0 and pacnv-avista <= 0
    then assign
            pacnv-principal = 0
            pacnv-acrescimo = 0
            pacnv-avista = 0
            .
    
    if pacnv-abate >= plani.platot
    then assign
             pacnv-principal = 0
             pacnv-acrescimo = 0
             pacnv-entrada   = 0
             pacnv-abate = plani.platot
             .

    if pacnv-acrescimo < 0 and
       plani.seguro = (-1 * pacnv-acrescimo)
    then pacnv-acrescimo = 0.
             
end procedure.
procedure valor-novacao:
    find first btitulo where 
               btitulo.empcod = 19 and
               btitulo.titnat = no and
               btitulo.modcod = contrato.modcod and
               btitulo.etbcod = contrato.etbcod and 
               btitulo.clifor = contrato.clicod and
               btitulo.titnum = string(contrato.contnum) and
               btitulo.titpar > 0
               no-lock no-error.
    if avail btitulo and           
       (btitulo.titpar = 31 or
        btitulo.tpcontrato = "N")
    then do:
        if acha("RENOVACAO",btitulo.titobs[1]) = "SIM"
        then pacnv-renovacao = yes.
        else pacnv-novacao = yes.
        if acha("FEIRAO-NOME-LIMPO",btitulo.titobs[1]) = "SIM"
        then assign
                pacnv-feiraonl = yes
                pacnv-cpfautoriza = acha("CPF-AUTORIZA",btitulo.titobs[1])
                .
        else if acha("FEIRAO-NOVO",btitulo.titobs[1]) = "SIM"    
            then assign
                    pacnv-feiraonl = yes
                    pacnv-cpfautoriza = acha("CPF-AUTORIZA",btitulo.titobs[1])
                    .
        
        if pacnv-feiraonl = no
        then do:        
            if acha("JURO-ATU",btitulo.titobs[1]) <> ?
            then pacnv-juroatu = dec(acha("JURO-ATU",btitulo.titobs[1])).
            if acha("JURO-ACR",btitulo.titobs[1]) <> ?
            then pacnv-juroacr = dec(acha("JURO-ACR",btitulo.titobs[1])).
        end.
        for each tit_novacao where
                 tit_novacao.ger_contnum = contrato.contnum
                 no-lock:
            pacnv-principal = pacnv-principal + tit_novacao.ori_titvlcob.
            find first ntitulo where
                           ntitulo.clifor = tit_novacao.ori_clifor and
                           ntitulo.titnum = tit_novacao.ori_titnum and
                           ntitulo.titpar = tit_novacao.ori_titpar
                           no-lock no-error.
            if avail ntitulo 
            then do: 
                if ntitulo.cobcod = 10
                then pacnv-orinf = pacnv-orinf + tit_novacao.ori_titvlcob. 
                else pacnv-orinl = pacnv-orinl + tit_novacao.ori_titvlcob.
            end.
        end.
        for each ctitulo where 
                ctitulo.clifor = contrato.clicod and
                ctitulo.titnum = string(contrato.contnum) and
                ctitulo.titpar > 0 no-lock:
                pacnv-seguro = pacnv-seguro + ctitulo.titdes.
                vpar-novacao = vpar-novacao + 1.
        end.
    end.
    else if avail btitulo and
           (btitulo.titpar = 51 or
            btitulo.tpcontrato = "L")
    then do:
            pacnv-novacao = yes.
            if acha("RENOVACAO",btitulo.titobs[1]) = "SIM"
            then pacnv-novacao = yes.
            if acha("FEIRAO-NOME-LIMPO",btitulo.titobs[1]) = "SIM"
            then assign
                pacnv-feiraonl = yes
                pacnv-cpfautoriza = acha("CPF-AUTORIZA",btitulo.titobs[1])
                .
            if pacnv-feiraonl = no
            then do:
                if acha("JURO-ATU",btitulo.titobs[1]) <> ?
                then pacnv-juroatu = dec(acha("JURO-ATU",btitulo.titobs[1])).
                if acha("JURO-ACR",btitulo.titobs[1]) <> ?
                then pacnv-juroacr = dec(acha("JURO-ACR",btitulo.titobs[1])).
            end.
            for each tit_novacao where
                 tit_novacao.ger_contnum = contrato.contnum
                 no-lock:
                pacnv-principal = pacnv-principal + tit_novacao.ori_titvlcob.
                find first ntitulo where
                           ntitulo.clifor = tit_novacao.ori_clifor and
                           ntitulo.titnum = tit_novacao.ori_titnum and
                           ntitulo.titpar = tit_novacao.ori_titpar
                           no-lock no-error.
                if avail ntitulo 
                then do: 
                    if ntitulo.cobcod = 10
                    then pacnv-orinf = pacnv-orinf + tit_novacao.ori_titvlcob. 
                    else pacnv-orinl = pacnv-orinl + tit_novacao.ori_titvlcob.
                end.
            end.
            for each ctitulo where 
                    ctitulo.clifor = contrato.clicod and
                    ctitulo.titnum = string(contrato.contnum) and
                    ctitulo.titpar > 0 no-lock:
                    pacnv-seguro = pacnv-seguro + ctitulo.titdes.
                    vpar-novacao = vpar-novacao + 1.
            end.
    end.
    
    pacnv-entrada   = contrato.vlentra.
    /*if pacnv-entrada = 0
    then*/ do:
        find first etitulo where
               etitulo.empcod = 19 and
               etitulo.titnat = no and
               etitulo.modcod = contrato.modcod and
               etitulo.etbcod = contrato.etbcod and 
               etitulo.clifor = contrato.clicod and
               etitulo.titnum = string(contrato.contnum) and
               etitulo.titpar = 0
               no-lock no-error.
        if avail etitulo 
        then pacnv-entrada   = etitulo.titvlcob.
        else pacnv-entrada   = 0.
    end. 
    assign
            pacnv-aprazo    = contrato.vltotal - pacnv-entrada
            pacnv-abate     = 0 /*pacnv-seguro*/ 
            pacnv-principal = pacnv-principal + pacnv-juroatu - pacnv-abate
                              - pacnv-entrada
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

    if pacnv-principal > pacnv-aprazo
    then assign
            pacnv-principal = pacnv-aprazo
            pacnv-principal = pacnv-principal - pacnv-abate
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

    if pacnv-principal = ? or pacnv-principal <= 0
    then assign
             pacnv-principal = pacnv-aprazo
             pacnv-principal = pacnv-principal - pacnv-abate
             pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .
end procedure.
procedure valor-descontar:

    assign
        val-voucher = 0 
        val-black   = 0 
        val-chepres = 0
        val-combo   = 0
        .

    if acha("VOUCHER-TROCAFONE",plani.notobs[1]) <> ?
    then val-voucher = dec(acha("VOUCHER-TROCAFONE=",plani.notobs[1])).
    if acha("BLACK-FRIDAY",plani.notobs[1]) <> ?
    then val-black = 
                 dec(entry(2,acha("BLACK-FRIDAY",plani.notobs[1]),";")).
    else if acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]) <> ?
    then val-black = dec(entry(3,
                        acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]),";")).
    if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
    then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
            val-chepres = val-chepres + 
            dec(acha("VALCHQPRESENTEUTILIZACAO" + string(vi),plani.notobs[3]))
            .
        end.
        
    /***
    if acha("COMBO",plani.notobs[1]) <> ? 
    then 
        for each movim where movim.etbcod = plani.etbcod and
                              movim.placod = plani.placod and
                              movim.movtdc = plani.movtdc and
                              movim.movdat = plani.pladat
                              no-lock:
            if acha("COMBO-" + string(movim.procod),plani.notobs[1]) <> ?
            then val-combo = val-combo +
                    dec(acha("COMBO-" + string(movim.procod),plani.notobs[1])).
                    
        end.                           
    ***/ 

    assign
        pacnv-voucher = val-voucher 
        pacnv-black   = val-black
        pacnv-chepres = val-chepres
        pacnv-combo   = val-combo
        .   
         
end.
procedure pacnv-acrescimo-parcela:
    def var vnumero-parcela as int.
    vnumero-parcela = 0.
    find finan where finan.fincod = plani.pedcod no-lock no-error.
    if avail finan then vnumero-parcela = finan.finnpc.
    if vnumero-parcela = 0
    then for each dtitulo where  dtitulo.clifor = titulo.clifor and
                                 dtitulo.titnum = titulo.titnum and
                                 dtitulo.titpar > 0
                                 no-lock:
            vnumero-parcela = vnumero-parcela + 1.
         end.                           
    if pacnv-acrescimo > 0
    then pacnv-acrescimo = pacnv-acrescimo / vnumero-parcela.
    else pacnv-acrescimo = 0.
end procedure.