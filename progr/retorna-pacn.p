{admcab.i}
def input parameter rec-plani as recid.
def input parameter rec-contrato as recid.
def output parameter p-novacao as log.
def output parameter p-financiado as dec.
def output parameter p-clientes as dec.
def output parameter p-principal as dec.
def output parameter p-acrescimo as dec.
def output parameter p-seguro as dec.
def output parameter p-crepes as dec.
def output parameter p-abate as dec.

def temp-table tt-venda
    field contnum   like fin.contrato.contnum
    field clicod    like fin.contrato.clicod
    field dtinicial like fin.contrato.dtinicial
    field principal as dec
    field acrescimo as dec
    index i1 contnum. 
    
def temp-table tt-titnum
    field etbcod like estab.etbcod
    field titnum like fin.titulo.titnum
    field valor as dec
    index i1 titnum
    .

def temp-table tt-titulo like fin.titulo.

def shared temp-table tit-novado like fin.titulo.

def var vi as int.
def var vplatot as dec.
def var vbiss as dec.
def var vvlserv as dec.
def var vdescprod as dec.
def var vchepres as dec.
def var val-combo as dec.

def var vtot-nov as dec.

def var val-voucher as dec.
def var val-black as dec.
        
def buffer btitulo for fin.titulo.
for each tt-titulo: delete tt-titulo. end.
p-novacao = no.
p-crepes = 0.
find fin.contrato where recid(fin.contrato) = rec-contrato no-lock no-error.
if avail fin.contrato and fin.contrato.modcod begins "CP"
then do:
    p-crepes = p-crepes + fin.contrato.vltotal.
end.
else if avail fin.contrato 
then do:
    create tt-venda.
    assign
        tt-venda.contnum = fin.contrato.contnum
        tt-venda.clicod  = fin.contrato.clicod
        tt-venda.dtinicial = fin.contrato.dtinicial
        .
    find first fin.titulo where
                  titulo.empcod = 19 and
                  titulo.titnat = no and
                  titulo.modcod = "CRE" and
                  titulo.etbcod = fin.contrato.etbcod and
                  titulo.clifor = fin.contrato.clicod and
                  titulo.titnum = string(fin.contrato.contnum) and
                  titulo.titpar > 30
                  no-lock no-error.
    if avail fin.titulo 
    then do:
        p-novacao = yes.
        if fin.titulo.titdes > 0
        then
        for each    fin.titulo where
                    titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = "CRE" and
                    titulo.etbcod = fin.contrato.etbcod and
                    titulo.clifor = fin.contrato.clicod and
                    titulo.titnum = string(fin.contrato.contnum) and
                    titulo.titpar > 30
                    no-lock.
            p-seguro = p-seguro + fin.titulo.titdes.
        end.    
    end.

    if p-novacao = no
    then do:
                  
        find plani where recid(plani) = rec-plani no-lock no-error.
        assign
            vplatot = plani.platot 
            vbiss   = plani.biss
            vvlserv = plani.vlserv 
            p-seguro = plani.seguro                   
            vdescprod = plani.descprod
            .

        /*****
        if vbiss < fin.contrato.vltotal
        then do:
            for each com.movim where movim.etbcod = plani.etbcod and
                      movim.placod = plani.placod and
                      movim.movtdc = plani.movtdc
                      no-lock.
                 find produ where produ.procod = movim.procod no-lock.
                 if produ.pronom matches "*recarga*"
                 then next.
                 if produ.procod = 559910 or
                    produ.procod = 559911 or
                    produ.procod = 578790 or
                    produ.procod = 579359
                 then next.
                 vplatot = vplatot + (movim.movpc * movim.movqtm).
            end.
            vbiss   = fin.contrato.vltotal - p-seguro.
        end.  
        if fin.contrato.vltotal < vbiss
        then do:
            vbiss = 0.
            for each fin.titulo where
                  fin.titulo.empcod = 19 and
                  fin.titulo.titnat = no and
                  fin.titulo.modcod = "CRE" and
                  fin.titulo.etbcod = fin.contrato.etbcod and
                  fin.titulo.clifor = fin.contrato.clicod and
                  fin.titulo.titnum = string(fin.contrato.contnum)
                  no-lock.
                /*if fin.titulo.titpar > 0 
                then*/ 
                vbiss = vbiss + fin.titulo.titvlcob 
                              - fin.titulo.titdes.      
            end.
        end.
        ***/
        
        assign 
            val-voucher = 0 
            val-black = 0 
            vchepres = 0
            val-combo = 0.
        
        run valor-abate-principal.
        
        assign
            p-principal = (vplatot + val-combo) - 
                    (vvlserv + vdescprod + vchepres + val-voucher + val-black
                     + p-seguro)
            p-acrescimo = vbiss - p-principal
            p-abate = (vvlserv - val-combo) + vdescprod + 
                      vchepres + val-voucher + val-black
                      /*+ p-seguro*/.  
            
        if p-principal = ? or p-principal <= 0
        then assign
                p-principal = vbiss
                p-acrescimo = 0
            .
    end.
    else do:
        assign
            vtot-nov = 0
            p-financiado = 0
            p-clientes = 0.

        for each tit_novacao where
                 tit_novacao.ger_contnum = fin.contrato.contnum
                 no-lock.
             
             vtot-nov = vtot-nov +  tit_novacao.ori_titvlcob. 

             find first envfinan where 
                           envfinan.empcod = 19
                       and envfinan.titnat = no
                       and envfinan.modcod = "CRE"
                       and envfinan.etbcod = tit_novacao.ori_etbcod 
                       and envfinan.clifor = tit_novacao.ori_clifor
                       and envfinan.titnum = tit_novacao.ori_titnum
                       and envfinan.titpar = tit_novacao.ori_titpar
                           no-lock no-error.
             if avail envfinan  
             then p-financiado = p-financiado + tit_novacao.ori_titvlcob.
             else p-clientes   = p-clientes + tit_novacao.ori_titvlcob.
        end.

        p-financiado = 0.
        p-clientes = 0.
        for each tt-titulo:
            if substr(string(fin.contrato.contnum,"9999999999"),9,2) = "00" and
               substr(string(int(tt-titulo.titnum),"9999999999"),9,2) <> "00"
               then next.
            
            run ver-financiado-tabdac.
            
        end.
        p-acrescimo = fin.contrato.vltotal - p-principal.
        if p-acrescimo < 0 then p-acrescimo = 0.
        
    end.
end.
else do:
    find plani where recid(plani) = rec-plani no-lock no-error.

    assign
        vplatot = plani.platot 
        vbiss   = plani.biss
        vvlserv = plani.vlserv 
        p-seguro = plani.seguro                   
        vdescprod = plani.descprod
        val-voucher = 0 
        val-black = 0 
        vchepres = 0
        val-combo = 0.
        
    run valor-abate-principal.
        
    assign
            p-principal = (vplatot + val-combo) - 
                    (vvlserv + vdescprod + vchepres + val-voucher + val-black
                     + p-seguro)
            p-acrescimo = vbiss - p-principal
            p-abate = (vvlserv - val-combo) + vdescprod + 
                      vchepres + val-voucher + val-black
                      /*+ p-seguro*/.  
            
    if p-principal = ? or p-principal <= 0
    then 
        assign
                p-principal = vbiss
                p-acrescimo = 0

            .

end.
procedure valor-abate-principal:
    val-voucher = 0.
    if acha("VOUCHER-TROCAFONE",plani.notobs[1]) <> ?
    then val-voucher = dec(acha("VOUCHER-TROCAFONE=",plani.notobs[1])).
    val-black = 0.
    if acha("BLACK-FRIDAY",plani.notobs[1]) <> ?
    then val-black = 
                 dec(entry(2,acha("BLACK-FRIDAY",plani.notobs[1]),";")).
    else if acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]) <> ?
    then val-black = dec(entry(3,
                        acha("BLACK-FRIDAY-DESCONTO",plani.notobs[1]),";")).
    vchepres = 0.
    if acha("QTDCHQUTILIZADO",plani.notobs[3]) <> ?
    then do vi = 1 to int(acha("QTDCHQUTILIZADO",plani.notobs[3])):
            vchepres = vchepres + 
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
end. 