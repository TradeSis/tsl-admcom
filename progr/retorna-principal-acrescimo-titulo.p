{admcab.i}
def input parameter p-recid as recid.
def output parameter p-principal as dec.
def output parameter p-acrescimo as dec.
def output parameter p-seguro as dec.
def output parameter p-crepes as dec.

def var vi as int.
def var vplatot as dec.
def var vbiss as dec.
def var vvlserv as dec.
def var vdescprod as dec.
def var q-parcela as int.
q-parcela = 0.
def var vchepres as dec.
def var val-voucher as dec.
def var val-black as dec.
def var vcrecod like fin.contrato.crecod.
 
def buffer btitulo for fin.titulo.
find fin.titulo where recid(titulo) = p-recid no-lock no-error.
if avail titulo and titulo.modcod = "CRE"
then do:
    find fin.contrato where fin.contrato.contnum = int(titulo.titnum) 
                no-lock no-error.
    if not avail fin.contrato
    then assign
            p-principal = titulo.titvlcob
            p-seguro = titulo.titdes
            p-acrescimo = 0.

    else do:            
        vcrecod = fin.contrato.crecod.        
        find first fin.contnf where contnf.etbcod = fin.contrato.etbcod and
                      contnf.contnum = fin.contrato.contnum
                      no-lock no-error.
        if avail contnf  and titulo.titpar > 0
        then do:

            find first com.plani where plani.etbcod = fin.contrato.etbcod and
                         plani.placod = contnf.placod and
                         plani.serie  = contnf.notaser and
                         plani.movtdc = 5
                         no-lock no-error.
            if avail plani
            then do:
                assign
                vplatot = plani.platot
                p-seguro = plani.seguro
                vbiss   = plani.biss
                vvlserv = plani.vlserv
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
                        vplatot = vplatot + (movim.movpc * movim.movqtm).
                    end.
                    vbiss   = fin.contrato.vltotal.
                end.  
                
                if fin.contrato.vltotal < vbiss
                then do:
                    vbiss = 0.
                    for each btitulo where
                        btitulo.empcod = 19 and
                        btitulo.titnat = no and
                        btitulo.modcod = "CRE" and
                        btitulo.etbcod = fin.contrato.etbcod and
                        btitulo.clifor = fin.contrato.clicod and
                        btitulo.titnum = string(fin.contrato.contnum)
                        no-lock.
                        vbiss = vbiss + btitulo.titvlcob.    
                    end.
                end.
                assign
                    vchepres = 0 val-voucher = 0 val-black = 0.

                run valor-abate-principal.

                assign
                    p-principal = vplatot - 
                     (vvlserv + vdescprod + vchepres + val-voucher + val-black)
                    p-acrescimo = vbiss - p-principal
                    .

                if vcrecod <> plani.pedcod
                then vcrecod = plani.pedcod.
            end.
            find fin.finan where finan.fincod = vcrecod no-lock no-error.
            if avail finan
            then q-parcela = finan.finnpc.
            else q-parcela = 1.
            if titulo.titdtven - titulo.titdtemi < 28
            then assign
                    p-principal = titulo.titvlcob 
                    p-seguro = titulo.titdes
                    p-acrescimo = 0.
            else assign
                p-principal = p-principal / q-parcela
                p-acrescimo = p-acrescimo / q-parcela
                p-seguro = p-seguro / q-parcela.

            if p-acrescimo = 0 and
                titulo.titvlcob > p-principal
            then p-principal = titulo.titvlcob.    
            if p-principal = titulo.titvlcob
            then p-acrescimo = 0.
            if (p-principal + p-acrescimo) > titulo.titvlcob
             and
               ((fin.contrato.vltotal - fin.contrato.vlentra) / q-parcela) 
                            = titulo.titvlcob   
            then p-acrescimo = titulo.titvlcob - p-principal.
            if p-principal > titulo.titvlcob and
               p-acrescimo <= 0
            then assign
                    p-principal = titulo.titvlcob
                    p-seguro = titulo.titdes
                    p-acrescimo = 0.   
            if (p-principal + p-acrescimo) < titulo.titvlcob
             and
                    (p-principal + p-acrescimo) - titulo.titvlcob >= 1.00
            then assign
                     p-principal = titulo.titvlcob
                     p-seguro = titulo.titdes
                     p-acrescimo = 0.
            if (p-principal + p-acrescimo) > titulo.titvlcob  
            then assign
                     p-acrescimo = titulo.titvlcob - p-principal 
                     .  
            if (p-principal + p-acrescimo) < titulo.titvlcob
            then assign
                     p-principal = titulo.titvlcob
                     p-seguro = titulo.titdes
                     p-acrescimo = 0.

        end.
        else assign
                p-principal = titulo.titvlcob
                p-seguro = titulo.titdes
                p-acrescimo = 0.

        if p-principal = ?
        then assign
                p-principal = titulo.titvlcob
                p-seguro = titulo.titdes
                p-acrescimo = 0.
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
