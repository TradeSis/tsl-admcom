
def input param p-pdvmovrec as recid.
{admcab.i}

def new shared var vetbcod like estab.etbcod.
def new shared var vdtini as date format "99/99/9999" label "De".
def new shared var vdtfin as date format "99/99/9999" label "Ate".              

def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    field saldoabe  like titulo.titvlcob  
    index idx is unique primary tipo desc contnum asc.

def new shared temp-table ttcontrato
    field contnum   like contrato.contnum
    index x is unique primary contnum asc.

find pdvmov where recid(pdvmov) = p-pdvmovrec no-lock. 

    run fin/montattnov.p (recid(pdvmov),NO).

                for each ttnovacao.
                    find first ttcontrato where ttcontrato.contnum = ttnovacao.contnum no-error.
                     if not avail ttcontrato
                     then do:
                        create ttcontrato.
                        ttcontrato.contnum = ttnovacao.contnum.
                    end.
                end.

    run fin/fqanadocorinov.p ("Origem",program-name(2) = "dpdv/pdvcope.p").

    
    /*            run fin/fqanadocnov.p   
                 (  "Novacao",
                            "", 
                            "",
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            p-pdvmovrec).*/

                            
                            
