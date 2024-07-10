{admcab.i}
def input parameter rec-plani as recid.
def input parameter rec-contrato as recid.
def output parameter p-novacao as log.
def output parameter p-financiado as dec.
def output parameter p-clientes as dec.
def output parameter p-principal as dec.
def output parameter p-acrescimo as dec.
def output parameter p-entrada as dec.
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
/*
def shared temp-table tit-novado like fin.titulo.
*/
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
        /*p-entrada = contrato.vlentra*/
        p-principal = (vplatot /*+ val-combo*/) - 
                    (vvlserv + vdescprod + vchepres + val-voucher + val-black
                     + p-seguro - p-entrada)
        p-acrescimo = vbiss - p-principal /*- p-entrada*/
        p-abate = (vvlserv /*- val-combo*/) + vdescprod + 
                   vchepres + val-voucher + val-black
                   .  
            
    if p-principal = ? or p-principal <= 0
    then assign
                p-principal = vbiss /*- p-entrada*/
                p-acrescimo = 0
            .
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
                      .  
            
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