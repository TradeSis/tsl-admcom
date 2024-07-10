{admcab.i}
def input parameter p-recid as recid.
def output parameter p-novacao as log.
def output parameter p-financiado as dec.
def output parameter p-clientes as dec.
def output parameter p-principal as dec.
def output parameter p-acrescimo as dec.
def output parameter p-seguro as dec.
def output parameter p-crepes as dec.

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
/*
def shared temp-table tit-novado like fin.titulo.
*/
def var vi as int.
def var vplatot as dec.
def var vbiss as dec.
def var vvlserv as dec.
def var vdescprod as dec.
def var vchepres as dec.

def var vtot-nov as dec.

def var val-voucher as dec.
def var val-black as dec.
        
def buffer btitulo for fin.titulo.
for each tt-titulo: delete tt-titulo. end.
p-novacao = no.
p-crepes = 0.
find fin.contrato where recid(fin.contrato) = p-recid no-lock no-error.
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
                  titulo.titpar = 31
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
                  
        find first fin.contnf where contnf.etbcod = fin.contrato.etbcod and
                      contnf.contnum = fin.contrato.contnum
                      no-lock no-error.
        if not avail contnf
        then return.
        
        find first com.plani where plani.etbcod = fin.contrato.etbcod and
                         plani.placod = contnf.placod and
                         plani.movtdc = 5
                         no-lock no-error.
        if not avail plani
        then return.
        assign
            vplatot = plani.platot - plani.seguro
            vbiss   = plani.biss
            vvlserv = plani.vlserv 
            p-seguro = plani.seguro                   
            vdescprod = plani.descprod
            .

        if vbiss < fin.contrato.vltotal
        then do:
            for each com.movim where movim.etbcod = plani.etbcod and
                      movim.placod = plani.placod and
                      movim.movtdc = plani.movtdc
                      no-lock.
                 find produ where produ.procod = movim.procod no-lock.
                 if produ.pronom matches "*recarga*"
                 then next.
                 if produ.procod = 559910 or produ.procod = 559911
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
        assign val-voucher = 0 val-black = 0 vchepres = 0.
        
        run valor-abate-principal.
        
        assign
            tt-venda.principal = vplatot - 
            (vvlserv + vdescprod + vchepres + val-voucher + val-black)
            tt-venda.acrescimo = vbiss - tt-venda.principal
            p-principal = vplatot - 
                (vvlserv + vdescprod + vchepres + val-voucher + val-black)
            p-acrescimo = vbiss - p-principal
            .
            
        if p-principal = ?
        then assign
                p-principal = vbiss
                p-acrescimo = 0
            .
    end.
    else do:
        vtot-nov = 0.
        for each tt-titnum: delete tt-titnum. end.
        for each fin.titulo where
                 fin.titulo.etbcobra = fin.contrato.etbcod and
                 fin.titulo.titdtpag = fin.contrato.dtinicial and
                 fin.titulo.clifor = fin.contrato.clicod and
                 fin.titulo.moecod = "NOV" 
             no-lock.
             /*
             find first tit-novado of fin.titulo no-error.
             if avail tit-novado then next.
             */
             vtot-nov = vtot-nov +  fin.titulo.titvlcob. 

             find first tt-titulo of fin.titulo no-lock no-error.
             if not avail tt-titulo
             then do:
                 create tt-titulo.
                 buffer-copy fin.titulo to tt-titulo.
             end.
        end.
        if vtot-nov > fin.contrato.vltotal
        then do:
            for each tt-titulo :
                delete tt-titulo.
            end.
        end.
        p-financiado = 0.
        p-clientes = 0.
        if p-novacao and
           (p-principal > fin.contrato.vltotal or
            p-principal = 0)
        then p-principal = fin.contrato.vltotal.    

        if p-principal > 0 and p-principal <> ? and
            fin.contrato.vltotal - p-principal >= 0
        then assign
                tt-venda.principal = p-principal
                tt-venda.acrescimo = fin.contrato.vltotal  - p-principal
                p-acrescimo = fin.contrato.vltotal - p-principal
                .
        else p-principal = 0.
        
        if  p-principal <> ? and 
            p-financiado > p-principal
        then assign
                    p-financiado = p-principal
                    p-clientes = 0.
        if p-clientes > 0
        then p-clientes = p-principal - p-financiado.
        
    end.
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
     
end. 