{admcab.i}
def input parameter rec-plani as recid.
def input parameter rec-contrato as recid.

{retorna-pacnv.i}

def var vi as int.
def var val-chepres as dec.
def var val-combo   as dec.
def var val-voucher as dec.
def var val-black   as dec.

def buffer btitulo for titulo.

if rec-contrato <> ?
then do:
    find fin.contrato where 
            recid(fin.contrato) = rec-contrato no-lock no-error.
    if avail fin.contrato and fin.contrato.modcod begins "CP"
    then pacnv-crepes = pacnv-crepes + fin.contrato.vltotal.
    else if avail fin.contrato  
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
                   pacnv-renovacao = no
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
else do:
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

procedure val-plani-contrato:

    run valor-descontar.
    
    assign
        pacnv-entrada   = contrato.vlentra
        pacnv-aprazo    = contrato.vltotal - contrato.vlentra
        pacnv-seguro    = plani.seguro
        pacnv-troca     = plani.vlserv
        pacnv-abate     = plani.vlserv + val-chepres + val-voucher +
                          val-black + pacnv-seguro 
        pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada) 
        pacnv-acrescimo = pacnv-aprazo - pacnv-principal
        .

    /*****
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
    ******/
end procedure.

procedure val-plani-contnf:

    run valor-descontar.
    
    if plani.crecod = 2
    then do:
        find first titulo where titulo.clifor   = plani.desti and
                                titulo.titnum   = string(contnf.contnum) and
                                titulo.titdtemi = plani.pladat and
                                titulo.titpar = 0
                                no-lock no-error.
        if avail titulo
        then pacnv-entrada   = titulo.titvlcob.           
        assign
            pacnv-aprazo    = plani.biss - pacnv-entrada
            pacnv-seguro    = plani.seguro
            pacnv-troca     = plani.vlserv
            pacnv-abate     = plani.vlserv + val-chepres +  
                              val-voucher +  val-black + pacnv-seguro 
            pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada)
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

    end.
    else assign
            pacnv-avista = plani.platot.
    
    /**********
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
    ************/    
end procedure.

procedure val-plani:

    run valor-descontar.
    
    if plani.crecod = 2
    then do:
        find first titulo where
                   titulo.clifor = plani.desti and
                   titulo.titdtemi = plani.pladat and
                   titulo.titpar = 0
                   no-lock no-error.
        if avail titulo
        then pacnv-entrada   = titulo.titvlcob.           
        assign
            pacnv-aprazo    = plani.biss - pacnv-entrada
            pacnv-seguro    = plani.seguro
            pacnv-troca     = plani.vlserv
            pacnv-abate     = plani.vlserv + val-chepres + val-voucher + 
                                val-black + pacnv-seguro 
            pacnv-principal = plani.platot - (pacnv-abate + pacnv-entrada) 
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

    end.
    else assign
            pacnv-avista = plani.platot.
           
    /***********        
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
    ******/
end procedure.
procedure valor-novacao:
    find first titulo where 
               titulo.clifor = contrato.clicod and
               titulo.titnum = string(contrato.contnum) and
               titulo.titpar = 31 no-lock no-error.
    if avail titulo
    then do:
        /*message titulo.titobs[1]. pause.*/
        pacnv-novacao = yes.
        if acha("RENOVACAO",titulo.titobs[1]) = "SIM"
        then pacnv-renovacao = yes.
        if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
        then assign
                pacnv-feiraonl = yes
                pacnv-cpfautoriza = acha("CPF-AUTORIZA",titulo.titobs[1])
                .
        if pacnv-feiraonl = no
        then do:        
            if acha("JURO-ATU",titulo.titobs[1]) <> ?
            then pacnv-juroatu = dec(acha("JURO-ATU",titulo.titobs[1])).
            if acha("JURO-ACR",titulo.titobs[1]) <> ?
            then pacnv-juroacr = dec(acha("JURO-ACR",titulo.titobs[1])).
        end.
        for each tit_novacao where
                 tit_novacao.ger_contnum = contrato.contnum
                 no-lock:
            pacnv-principal = pacnv-principal + tit_novacao.ori_titvlcob.
        end.
        if titulo.titdes > 0
        then do:
            for each btitulo where 
                btitulo.clifor = contrato.clicod and
                btitulo.titnum = string(contrato.contnum) and
                btitulo.titpar >= 31 no-lock:
                pacnv-seguro = pacnv-seguro + btitulo.titdes.
            end.
        end.
    end.
    else do:
        find first titulo where 
               titulo.clifor = contrato.clicod and
               titulo.titnum = string(contrato.contnum) and
               titulo.titpar = 51 no-lock no-error.
        if avail titulo
        then do:
            pacnv-novacao = yes.
            if acha("RENOVACAO",titulo.titobs[1]) = "SIM"
            then pacnv-novacao = yes.
            if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
            then assign
                pacnv-feiraonl = yes
                pacnv-cpfautoriza = acha("CPF-AUTORIZA",titulo.titobs[1])
                .
            if pacnv-feiraonl = no
            then do:
                if acha("JURO-ATU",titulo.titobs[1]) <> ?
                then pacnv-juroatu = dec(acha("JURO-ATU",titulo.titobs[1])).
                if acha("JURO-ACR",titulo.titobs[1]) <> ?
                then pacnv-juroacr = dec(acha("JURO-ACR",titulo.titobs[1])).
            end.
            for each tit_novacao where
                 tit_novacao.ger_contnum = contrato.contnum
                 no-lock:
                pacnv-principal = pacnv-principal + tit_novacao.ori_titvlcob.
            end.
            if titulo.titdes > 0
            then do:
                for each btitulo where 
                    btitulo.clifor = contrato.clicod and
                    btitulo.titnum = string(contrato.contnum) and
                    btitulo.titpar >= 51 no-lock:
                    pacnv-seguro = pacnv-seguro + btitulo.titdes.
                end.
            end.
        end.
    end.
    
    assign
            pacnv-entrada   = contrato.vlentra
            pacnv-aprazo    = contrato.vltotal - contrato.vlentra
            pacnv-abate     = pacnv-seguro 
            pacnv-principal = pacnv-principal + pacnv-juroatu - pacnv-abate
            pacnv-acrescimo = pacnv-aprazo - pacnv-principal
            .

    if pacnv-feiraonl and pacnv-principal > pacnv-aprazo
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