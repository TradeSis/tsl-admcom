{admcab.i}
def var vdtini  as date.
def var vdtfin  as date.
def var vday    as int.
def var vmes    as int.
def var vano    as int.
def var vdtseg  as date.

def temp-table wftotal
    field etbcod    like estab.etbcod       column-label "Estab"
    field cart      like titulo.titvlcob    column-label "Carteira"
    field reali     like titulo.titvlcob    column-label "Realizado"
    field germes    like titulo.titvlcob    column-label "Geral do Mes"
    field saldo     like titulo.titvlcob    column-label "Saldo"
    field proxmes   like titulo.titvlcob    column-label "Proximo Mes".

def var vtotcart    like wftotal.cart.
def var vtotreali   like wftotal.reali.
def var vtotgermes  like wftotal.germes.
def var vtotproxmes like wftotal.proxmes.
def var vtotsaldo   as dec format "->>,>>>,>>>,>>9.99" decimals 2.

def var vpct1       as   dec format "->>9.99" decimals 2.
def var vpct2       as   dec format "->>9.99" decimals 2.
def var vlin1       as   char format "xxxx".
def var vlin2       as   char format "xxxx".
update vdtini   colon 15 label "Data Inicial"
       vdtfin   colon 15 label "Data Final"
       with frame f1
            row 4 width 80 side-label.

assign vday = day   (vdtfin)  .
       vmes = month (vdtfin) + 1.
       vano = year  (vdtfin).
if vmes = 13
then assign vano = vano + 1
            vmes = 1 .
vdtseg = date(vmes,
              vday,
              vano).

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
            if (titulo.titdtven >= vdtini and
                titulo.titdtven <= vdtfin)   and
                titulo.titdtemi <  vdtini
            then
                if titulo.titdtpag >= vdtini or
                   titulo.titvlpag  = 0
                then
                    wftotal.cart = wftotal.cart + titulo.titvlcob .

            if (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)      and
               month(titulo.titdtven) = month(vdtfin) and
                titulo.titdtemi < vdtini
            then
                wftotal.reali = wftotal.reali + titulo.titvlcob.


            if (titulo.titdtven >= vdtini and
                titulo.titdtven <= vdtfin)
            then
                wftotal.germes = wftotal.germes + titulo.titvlcob.

            if (titulo.titdtven >= vdtini and
                titulo.titdtven <= vdtfin) and
                titulo.titdtpag = ?
            then
                wftotal.saldo = wftotal.saldo + titulo.titvlcob.

            if month(titulo.titdtven) = month(vdtseg) and
                     titulo.titdtpag  = ?
            then
                wftotal.proxmes = wftotal.proxmes + titulo.titvlcob.
        end.
end.

def var varq as char format "x(20)".
varq = "..\relat\ctrcar" + string(time) + ".rel".

output to value(varq) page-size 65.

{ini17cpp.i}

for each wftotal break by wftotal.etbcod with frame flin.
    form header wempre.emprazsoc
         space(6) "CTRCAR"  at 112
         "Pag.: " at 123 page-number format ">>9" skip
         "CONTROLE DA CARTEIRA "
         "PERIODO DE " string(vdtini) " A " string(vdtfin)
         today format "99/99/9999" at 112
         string(time,"hh:mm:ss") at 125
         skip fill("-",132) format "x(132)" skip
         with frame fcab no-label page-top no-box width 132.
    view frame fcab.

    display wftotal.etbcod
            wftotal.cart
            wftotal.reali
           ((wftotal.reali / wftotal.cart) * 100)   @ vpct1    column-label "%"
            wftotal.germes
            wftotal.saldo    @ vtotsaldo     column-label "Saldo"
           (((wftotal.saldo) / wftotal.germes) * 100) @ vpct2
                                                     column-label "% In/Mes"
            "____"                          @ vlin1  column-label "Coloc"
            wftotal.proxmes
            with frame flin
                no-box width 137.
    down with frame flin.

    assign
        vtotcart    = vtotcart    + wftotal.cart
        vtotreali   = vtotreali   + wftotal.reali
        vtotgermes  = vtotgermes  + wftotal.germes
        vtotproxmes = vtotproxmes + wftotal.proxmes
        vtotsaldo   = vtotsaldo   + wftotal.saldo .

    if last(wftotal.etbcod)
    then do:
        display
                "----------------"                 @ wftotal.cart
                "----------------"                 @ wftotal.reali
                "------"                                 @ vpct1
                "----------------"                 @ wftotal.germes
                "----------------"                 @ vtotsaldo
                "--------"                                 @ vpct2
                "------"                            @ vlin1
                "----------------"                 @ wftotal.proxmes
                with frame flin.
        down with frame flin.
        display "TOTAL"                                 @ wftotal.etbcod
                vtotcart                                @ wftotal.cart
                vtotreali                               @ wftotal.reali
                ((vtotreali / vtotcart) * 100)            @ vpct1
                vtotgermes                              @ wftotal.germes
                vtotsaldo                               @ vtotsaldo
                ((vtotsaldo / vtotgermes) * 100)          @ vpct2
                "____"                                  @ vlin1
                vtotproxmes                             @ wftotal.proxmes
                with frame flin.
    end.
end.
{fin17cpp.i}
output close.

dos silent value("type " + varq + " > prn").
