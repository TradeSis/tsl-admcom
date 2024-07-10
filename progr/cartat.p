{admcab.i}
def var vdtini  as date.
def var vdtfin  as date.

def temp-table wftotal
    field etbcod    like estab.etbcod       column-label "Estab"
    field cart      like titulo.titvlcob    column-label "Carteira"
    field reali     like titulo.titvlcob    column-label "Realizado"
    field cartger   like titulo.titvlcob    column-label "Cart/Geral"
    field atraso    like titulo.titvlcob    column-label "Atr Atual".

def var vtotcart    like wftotal.cart.
def var vtotreali   like wftotal.reali.
def var vtotcartger like wftotal.cartger.
def var vtotatraso  like wftotal.atraso.
def var vpct1       as   dec format ">>9.99" decimals 2.
def var vpct2       as   dec format ">>9.99" decimals 2.
def var vlin1       as   char.
def var vlin2       as   char.

update vdtini   colon 15 label "Data Inicial"
       vdtfin   colon 15 label "Data Final"
       with frame f1
            row 4 width 80 side-label.

for each estab no-lock.
    pause 0.
    display "Processando Loja" estab.etbcod
            with centered row 10 frame festab no-label.
        for each titulo use-index titnum
                where titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.etbcod = estab.etbcod
                              no-lock.
            find first wftotal where wftotal.etbcod = estab.etbcod no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = estab.etbcod.
            end.
            if titulo.titdtven  < vdtini and
               (titulo.titdtpag >= vdtini or
                titulo.titvlpag = 0)
            then
                wftotal.cart = wftotal.cart + titulo.titvlcob.

            if (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)      and
                titulo.titdtven <  vdtini
            then
                wftotal.reali = wftotal.reali + titulo.titvlcob.

            if titulo.titvlpag = 0 or
               titulo.titvlpag = ?
            then
                wftotal.cartger = wftotal.cartger + titulo.titvlcob.

            if (titulo.titvlpag = 0 or
                titulo.titvlpag = ?)    and
               titulo.titdtven <= vdtfin
            then
                wftotal.atraso = wftotal.atraso + titulo.titvlcob.

        end.
end.

output to ..\relat\cartat.rel page-size 64.
{ini17cpp.i}

for each wftotal break by wftotal.etbcod with frame flin.
    form header wempre.emprazsoc
         space(6) "CARTAT"  at 112
         "Pag.: " at 123 page-number format ">>9" skip
         "CONTROLE DA CARTEIRA DO ATRASO "
         "PERIODO DE " string(vdtini) " A " string(vdtfin)
         today format "99/99/9999" at 112
         string(time,"hh:mm:ss") at 125
         skip fill("-",132) format "x(132)" skip
         with frame fcab no-label page-top no-box width 132.
    view frame fcab.
    assign
        vtotcart    = vtotcart    + wftotal.cart
        vtotreali   = vtotreali   + wftotal.reali
        vtotcartger = vtotcartger + wftotal.cartger
        vtotatraso  = vtotatraso  + wftotal.atraso    .
    display wftotal.etbcod
            wftotal.cart
            wftotal.reali
            ((wftotal.reali / wftotal.cart) * 100) @ vpct1  column-label "%"
            "_____"          @ vlin1                      column-label "Coloc"
            wftotal.cartger
            wftotal.atraso
            ((wftotal.atraso / wftotal.cartger) * 100) @
            vpct2                                       column-label "% Geral"
            "_____"           @ vlin2                     column-label "Geral"
            with frame flin
                no-box width 137.
    down with frame flin.
    if last(wftotal.etbcod)
    then do:
        display
                "------------------"            @ wftotal.cart
                "------------------"            @ wftotal.reali
                "------------------"            @ vpct1
                "---------"                     @ vlin1
                "------------------"            @ wftotal.cartger
                "------------------"            @ wftotal.atraso
                "------------"                  @ vpct2
                "---------"                     @ vlin2
                with frame flin.
        down with frame flin.
        display "TOTAL"                      @ wftotal.etbcod
                vtotcart                     @ wftotal.cart
                vtotreali                    @ wftotal.reali
                ((vtotreali / vtotcart) * 100) @ vpct1      column-label "%"
                "_____"                      @ vlin1      column-label "Coloc"
                vtotcartger                  @ wftotal.cartger
                vtotatraso                   @ wftotal.atraso
               ((vtotatraso / vtotcartger) * 100) @ vpct2 column-label "% Geral"
                "_____"                 @ vlin2           column-label "Geral"
                with frame flin.
    end.

end.
{fin17cpp.i}
output close.


dos silent value("type ..\relat\cartat.rel > prn").
