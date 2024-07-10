/*
#1 TP 28796133 - 11.01.2019
*/
{admcab.i}

def new shared temp-table tt-tit
    field rec     as recid 
    field dias    as int
    field etbcod  like titulo.etbcod
    field juro    like titulo.titvlcob
    field vtot    like titulo.titvlcob
    field vacu    like titulo.titvlcob
    field vord    as int
        index ind-1 vord.
    
def input parameter par-rec as recid.

def var ii as int.
def var vtotal  like titulo.titvlcob.
def var vjuro   like titulo.titvlcob.
def var vacum   like titulo.titvlcob.
def var vdias   as   int.
                          
find clien where recid(clien) = par-rec no-lock no-error.

ii = 0.
for each titulo use-index iclicod where
                titulo.clifor     = clien.clicod and
                titulo.titnat     = no           no-lock by titulo.titdtven
                                                         by titulo.titnum
                                                         by titulo.titpar.
    if titulo.titsit = "PAG" or titulo.titsit = "EXC"
    then next.
    if titulo.titpar = 0 and
       titulo.titdtemi = titulo.titdtven
    then do:
        find contrato where contrato.contnum = int(titulo.titnum)
                    no-lock no-error.
        if not avail contrato
        then next.
    end.
    
    vtotal = 0.
    vjuro = 0.
    vdias = 0.

    if titulo.titdtven < today
    then do:
        /* #1 */
        run juro_titulo.p (if clien.etbcad = 0 then titulo.etbcod else clien.etbcad, /* mesmo que novelesel.p */
                    /* helio 07112020 0,*/ 
                            titulo.titdtven, titulo.titvlcob,
                           output vjuro).

        assign
           vtotal = titulo.titvlcob + vjuro
           vdias  = today - titulo.titdtven.
    end.
    else vtotal = titulo.titvlcob.
    vacum = vacum + vtotal.

    find first tt-tit where tt-tit.rec = recid(titulo) no-error.
    if not avail tt-tit
    then do:
        ii = ii + 1.
        create tt-tit.
        assign tt-tit.rec    = recid(titulo)
               tt-tit.dias   = vdias
               tt-tit.juro   = vjuro
               tt-tit.etbcod = titulo.etbcod
               tt-tit.vtot   = vtotal
               tt-tit.vacu   = vacum
               tt-tit.vord   = ii.
    end.           
    /*
    display titulo.etbcod column-label "Fl." format ">>9"
            titulo.titnum format "x(10)"
            titulo.titpar column-label "Pr" format ">99" 
            titulo.titdtven format "99/99/9999"
            vdias      when vdias > 0 column-label "Atr" format ">>9"
            titulo.titvlcob(total) column-label "Principal" format ">>,>>9.99"
            vjuro(total)  column-label "Juro" format ">,>>9.99"
            vtotal(total) column-label "Total" format ">>,>>9.99"
            vacum         column-label "Acum" format ">>,>>9.99"
                with frame flin down width 80.
    */
end.
run extrato4.p.

