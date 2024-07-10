def input param vdtini  as date.
def input param vdtfim as date.

{seg/segprest.i}
for each ttcontrato.
    delete ttcontrato.
end.    

def var vqtdpar as int.
for each contrato where contrato.dtinicial >= vdtini and dtinicial <= vdtfim
    no-lock.

    if contrato.etbcod < 500
    then.
    else next.
  
    /* Helio, 05122023 - Seleciona todos *** if contrato.vlseguro <= 0 then next. **/
    
    vqtdpar = 0.
    for each titulo where titnat = no and 
        titulo.clifor = contrato.clicod and
        titulo.titnum = string(contrato.contnum) no-lock.
        if titulo.titpar = 0 then next.
        vqtdpar = vqtdpar + 1.        
    end.
    
    if vqtdpar = 0
    then next.
    
    
    
    
    
    create ttcontrato.
    ttcontrato.contnum      = contrato.contnum.
    ttcontrato.rec         = recid(contrato).
    ttcontrato.tpseguro = 1.
    if contrato.modcod = "CP1" or contrato.modcod = "CP0"
    then do:
        ttcontrato.catnom = "EMPRESTIMO".
        ttcontrato.tpseguro = 3.
    end.    

    /**/
    
    if contrato.tpcontrato = "N" or contrato.modcod = "CPN"
    then do:    
        ttcontrato.catnom = "NOVACAO".
        /*ttcontrato.valortotal   = contrato.vltotal. */
    end. 
    /*else ttcontrato.valortotal   = 0.            */

    ttcontrato.prseguro = 0.
    for each vndseguro where vndseguro.contnum = contrato.contnum and
                             vndseguro.tpseguro = ttcontrato.tpseguro no-lock.
        ttcontrato.certifi  = 
            substring(vndseguro.certifi,length(vndseguro.certifi) - 10).   
        ttcontrato.SeguroPrestamistaAutomatico = 
                        vndseguro.SeguroPrestamistaAutomatico.
        ttcontrato.codigoSeguro = vndseguro.procod.
        ttcontrato.prseguro     = vndseguro.prseguro.
    end.

    if ttcontrato.prseguro = 0 
    then do:
        delete ttcontrato.
        next.
    end.
    if contrato.vlseguro > 0 and ttcontrato.SeguroPrestamistaAutomatico = no
    then do:
        delete ttcontrato.
        next.
    end.
        
        for each contnf where contnf.etbcod = contrato.etbcod and
                              contnf.contnum = contrato.contnum no-lock.
            find first plani where plani.etbcod = contnf.etbcod and
                                   plani.placod = contnf.placod
                                     no-lock no-error.
            if avail plani
            then do:
                for each movim where movim.etbcod = plani.etbcod and
                                    movim.placod  = plani.placod
                                    no-lock .
                    find produ of movim no-lock no-error.
                    if avail produ
                    then do:
                        find categoria of produ no-lock no-error.
                        if avail categoria
                        then do:
                            if produ.catcod = 31 or produ.catcod = 41
                            then do:
                                if ttcontrato.catnom = ""
                                then ttcontrato.catnom = trim(categoria.catnom).
                            end.    
                            if produ.procod = 8011 or produ.procod = 8015 or produ.procod = 8012
                            then do:
                            end.
                        end.
                    end.         
                end.                                    
            end.
        end.        
    
/*    
    /* helio 24112022 - correcoes */
    if (ttcontrato.catnom = "NOVACAO" or
        ttcontrato.catnom = "MOVEIS"  or
        ttcontrato.catnom = "MODA" or
        ttcontrato.catnom = "EMPRESTIMO") 
    then.
    else delete ttcontrato.
    /**/
*/
end.



