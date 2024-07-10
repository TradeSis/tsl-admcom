{admcab-batch.i}

def var vlancod like lanaut.lancod.
def var vcxacod like lancxa.cxacod.
def var vcomhis as char.
def var v-nomes as char extent 12
    init["JANEIRO","FEVEREIRO","MARCO","ABRIL","MAIO","JUNHO","JULHO",
    "AGOSTO","SETEMBRO","OUTUBRO","NOVEMBRO","DEZEMBRO"].

def input parameter vrec as recid.

find fin.titluc where recid(fin.titluc) = vrec no-lock.

def var vlanhis like lanaut.lanhis.
def var vmes as int.
def var vano as int.

vcomhis = "".
vmes = 0.
vano = 0.

find foraut where foraut.forcod = fin.titluc.clifor no-lock no-error.
if not avail foraut then return.

do on error undo:
    vmes = month(titluc.titdtven).
    vano = year(titluc.titdtven).
    
    if vmes = 1
    then assign
            vmes = 12
            vano = vano - 1.
    else vmes = vmes - 1.

    vlanhis = 21.
    vcomhis = foraut.fornom + "-" +
        v-nomes[vmes] + "-" + string(vano,"9999"). 


    run lanca-titluc.

    find current fin.titulo no-lock.
    
end.    
   
procedure lanca-titluc:
   find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = fin.titluc.clifor and
                lancactb.modcod = fin.titluc.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = fin.titluc.modcod
                no-lock no-error.
    
    if avail lancactb
    then do:
        run lan-contabil("CAIXA",
                            lancactb.contacre,
                            formpag.contacre,
                            fin.titluc.modcod,
                            fin.titluc.titdtpag,
                            fin.titluc.titvlpag,
                            fin.titluc.clifor,
                            fin.titluc.titnum,
                            fin.titluc.etbcod,
                            lancactb.int1,
                            vcomhis,
                            "C").

        if fin.titluc.titvljur > 0 
        then do:
            run lan-contabil("CAIXA",
                            228,
                            formpag.contacre,
                            fin.titluc.modcod,
                            fin.titluc.titdtpag,
                            fin.titluc.titvljur,
                            fin.titluc.clifor,
                            fin.titluc.titnum,
                            fin.titluc.etbcod,
                            13,
                            vcomhis,
                            "C").

        end.    
                        
        if fin.titluc.titvldes > 0 
        then do:
            run lan-contabil("CAIXA",
                            235,
                            formpag.contacre,
                            fin.titluc.modcod,
                            fin.titluc.titdtpag,
                            fin.titluc.titvljur,
                            fin.titluc.clifor,
                            fin.titluc.titnum,
                            fin.titluc.etbcod,
                            12,
                            vcomhis,
                            "D").
        end.
    end. 
    
end procedure.    
