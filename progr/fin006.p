/***************************************************************************
** Programa        : fin006.p
** Objetivo        : Consulta de Titulos por Filial e por Data
** Ultima Alteracao:
**
****************************************************************************/

{admcab.i}

def var     i-cxa       like caixa.cxacod                           no-undo.
def var     i-vviqtd    as int  init 0  label "Venda a Vista "      no-undo.
def var     i-pprqtd    as int  init 0  label "Pgto. Prestac."      no-undo.
def var     i-jurqtd    as int  init 0  label "Juro          "      no-undo.
def var     i-przqtd    as int  init 0  label "Venda a Prazo "      no-undo.
def var     de-vvivl    as dec  init 0                              no-undo.
def var     de-pprvl    as dec  init 0                              no-undo.
def var     de-jurvl    as dec  init 0                              no-undo.
def var     de-przvl    as dec  init 0                              no-undo.
def var     da-dtini    as date init today                          no-undo.

form
     "Cod. Caixa :"  i-cxa          colon 16 skip
     "Data       :"  da-dtini       colon 16
     with overlay row 19 column 01 no-labels frame f-selecao.

form header wempre.emprazsoc no-label
            "Administrativo Financeiro" at 46 today at 110 skip
            "Listagem De Conferencia De Juros"      at 1
            "Pag." at 73 page-number format ">>9"           skip
            " Periodo : " at 35 da-dtini no-label skip
            fill("-",135) format "x(135)" skip
            with frame fcab page-top no-box width 135.

update i-cxa
       da-dtini
       with frame f-selecao.
hide frame f-selecao.
message "imprimindo...".

for each titulo where
         titulo.empcod      = 19       and
         titulo.titnat      = no       and
         titulo.modcod      = "CRE"    and
         titulo.datexp      = da-dtini no-lock:
    if  titulo.modcod = "VVI" then do:
        assign i-vviqtd = i-vviqtd + 1
               de-vvivl = de-vvivl + titulo.titvlcob.
    end.
    else
        if  titulo.modcod = "PPR" then do:
            assign i-pprqtd = i-pprqtd + 1
                   de-pprvl = de-pprvl + titulo.titvlcob + titulo.titjuro.
            if  titulo.titjuro > 0 then do:
                assign i-jurqtd = i-jurqtd + 1
                       de-jurvl = de-jurvl + titulo.titjuro.
            end.
        end.
    if  titulo.etbcod   =  1        and
        titulo.titdtemi =  da-dtini and
        titulo.modcod   <> "VVI"    then do:
        if  titulo.titpar = 0 then
            assign i-przqtd = i-przqtd + 1.
        assign de-przvl = de-przvl + titulo.titvlcob.
    end.
end.
output to printer page-size 60.
view frame fcab.
put
   skip(2)
   "Totais do Caixa:"           at 03 space(2)
   i-cxa                               skip(2)
   "Venda a Vista  :"           at 03 space(2)
   i-vviqtd                           space(5)
   de-vvivl                            skip(1)
   "Venda a Prazo  :"           at 03 space(2)
   i-przqtd                           space(5)
   de-przvl                            skip(1)
   "Pagto. Prestac.:"           at 03 space(2)
   i-pprqtd                           space(5)
   de-pprvl                            skip(1)
   "Juro           :"           at 03 space(2)
   i-jurqtd                           space(5)
   de-jurvl                            skip(1).
page.
output close.
hide message no-pause.
