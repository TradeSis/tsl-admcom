{admcab.i}

def shared temp-table tt-contrato   like fin.contrato.
def shared temp-table tt-titulo     like fin.titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def shared temp-table tt-contnf     like fin.contnf.
def shared temp-table tt-movim      like movim.

def var ii as int.

def var ljuros  as l.
def var vnumdia as i.

def new shared temp-table tt-tit
    field rec     as recid 
    field dias    as int
    field etbcod  like tt-titulo.etbcod
    field juro    like tt-titulo.titvlcob
    field vtot    like tt-titulo.titvlcob
    field vacu    like tt-titulo.titvlcob
    field vord    as int
        index ind-1 vord.
    
    
def input parameter par-rec as recid.
def var vtotal  like tt-titulo.titvlcob.
def var vjuro   like tt-titulo.titvlcob.
def var vacum   like tt-titulo.titvlcob.
def var vdias   as   int.
                          
find clien where recid(clien) = par-rec no-lock no-error.
                          
                           
ii = 0.
for each tt-titulo use-index iclicod where
                tt-titulo.clifor     = clien.clicod and
                tt-titulo.titnat     = no           no-lock by tt-titulo.titdtven
                                                         by tt-titulo.titnum
                                                         by tt-titulo.titpar.
    if tt-titulo.titsit = "PAG"
    then next.
    vtotal = 0.
    vjuro = 0.
    vdias = 0.

    if tt-titulo.titdtven < today
    then do:
                /*  luciano  */
                ljuros = yes.
                if today - tt-titulo.titdtven = 2
                then do:
                    find fin.dtextra where exdata = today - 2 NO-LOCK no-error.
                    if weekday(today - 2) = 1 or avail dtextra
                    then do:
                        find dtextra where exdata = today - 1 NO-LOCK no-error.
                        if weekday(today - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.    
                end.
                else do:
                    if today - tt-titulo.titdtven = 1
                    then do:
                        find dtextra where exdata = today - 1 NO-LOCK no-error.
                        if weekday(today - 1) = 1 or avail dtextra
                        then ljuros = no.
                    end.
                end.
                vnumdia = if not ljuros 
                          then 0 
                          else today - tt-titulo.titdtven.
                if vnumdia > 1766
                then vnumdia = 1766.
                /*  luciano  */

        find tabjur where   tabjur.etbcod = 0 and
                            tabjur.nrdias = vnumdia /*  luciano  */
                            /*tabjur.nrdias = today - tt-titulo.titdtven*/
                         no-lock no-error.
        if  not avail tabjur
        then do:
            message "Fator para" vnumdia
                                 /*tabjur.nrdias = today - tt-titulo.titdtven*/
                    "dias de atraso, nao cadastrado".
            pause.
            undo.
        end.
        assign vjuro  = (tt-titulo.titvlcob * tabjur.fator) - tt-titulo.titvlcob
               vtotal = tt-titulo.titvlcob + vjuro
               vdias  = today - tt-titulo.titdtven.

                /*  luciano  */
                def var varred    like titulo.titvlcob.
                def var vtitvlpag like titulo.titvlpag.
                def var vtitvlp like fin.titulo.titvlcob.
                vtitvlp = 0.
                varred = 0.
                vtitvlpag = 0.
                vtitvlpag = tt-titulo.titvlcob * tabjur.fator.
                vtitvlp = vtitvlp + vtitvlpag.
                /*** copiado de opetitco.p ***/
                if ljuros
                then do:
                    varred = ( (int(vtitvlpag) -  vtitvlpag) )
                           - round( ( (int(vtitvlpag) - (vtitvlpag)) ), 1).
                    if varred < 0
                    then varred = 0.10 - (varred * -1).
                    vtitvlp = vtitvlp + varred.
                end.
                vjuro = vtitvlp - tt-titulo.titvlcob.
                vtotal = tt-titulo.titvlcob + vjuro.
                /*  luciano  */
                
    end.
    else vtotal = tt-titulo.titvlcob.
    vacum = vacum + vtotal.
    find first tt-tit where tt-tit.rec = recid(tt-titulo) no-error.
    if not avail tt-tit
    then do:
        ii = ii + 1.
        
        create tt-tit.
        assign tt-tit.rec    = recid(tt-titulo)
               tt-tit.dias   = vdias
               tt-tit.juro   = vjuro
               tt-tit.etbcod = tt-titulo.etbcod
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
run extrato41.p.
            
