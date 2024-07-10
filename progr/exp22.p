/***************************************************************************
** Programa        : Expmatb4.p
** Objetivo        : Exportacao de Dados para a Loja
** Ultima Alteracao: 24/06/96
** Programador     :
****************************************************************************/
{admcab.i}
def buffer bestab for estab.
def var vdt as date format "99/99/9999".
def stream tela.
def var vdata as date format "99/99/9999" initial today.

def new shared frame fmostra.
def new shared var conta1       as integer.
def new shared var conta2       as integer.
def new shared var conta3       as integer.
def new shared var conta4       as integer.
def new shared var conta5       as integer.
def new shared var conta6       as integer.

def var varq                    as char                     no-undo.
def var vachou                  as log                      no-undo.
def var v-dtini                 as date format "99/99/9999" init today  no-undo.
def var v-dtfin                 as date format "99/99/9999" init today  no-undo.
def var v-etbcod                like estab.etbcod           no-undo.
def var i-cont                  as integer init 0           no-undo.
def var vmodcod                 like titulo.modcod.
def var verro                   as log.
def var funcao                  as char.
def var parametro               as char.
def var vetbcod                 like estab.etbcod.

output stream tela  to terminal.

pause 0 before-hide.
form v-dtini         colon 16 label "Data Inicial"
     v-dtfin         label "Data Final"
     with overlay row 5 side-labels frame f-selecao centered color white/cyan
     title " PERIODO ".

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0.

form skip(1)
     "*** ATENCAO :  Saldo do Caixa nao fechou "
     "               com o Saldo Exportado !!"
     skip(1)
     with centered  color blink/red title " ERRO DE EXPORTACAO " 1 column
     no-label row 8 frame faviso.

form skip(1)
     "Produtos            :" conta1 skip
     "Estoque             :" conta2 skip
     "Notas               :" conta3 skip
     "Movimentos          :" conta4 skip
     skip(1)
     with frame fmostra row 9 column 18 color blue/cyan no-label
     title " EXPORTACAO DE DADOS - CPD ".

form skip(01)
     conta2 skip
     conta1 skip
     skip(04)
     with frame flimpa row 9 column 52 color blue/cyan no-label
     title " LIMPA ".


view stream tela frame flimpa.
view stream tela frame fmostra.

update v-dtini
       v-dtfin
       with frame f-selecao.

input from ..\gener\admcom.ini no-echo.
repeat:
    set funcao parametro.
    if funcao = "ESTAB"
    then setbcod = int(parametro).
end.
input close.


output to ..\export\cpd22\produ.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:

    conta1 = conta1 + 1.
    display stream tela conta1 with frame fmostra.
    export produ.
end.
output close.

output to ..\export\cpd22\propg.d.
for each propg where propg.prpdata >= v-dtini and
                     propg.prpdata <= v-dtfin no-lock:

    export propg.
end.
output close.

output to ..\export\cpd22\estoq.d.
for each produ where produ.datexp >= v-dtini and
                     produ.datexp <= v-dtfin no-lock:
    for each estoq where estoq.procod = produ.procod and
                         estoq.etbcod = 22 no-lock:
        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
        export estoq.
    end.
end.
output close.


output to ..\export\cpd22\tabmen.d.
for each tabmen where tabmen.datexp >= v-dtini and
                      tabmen.datexp <= v-dtfin no-lock:
    export tabmen.
end.
output close.

output to ..\export\cpd22\plani.d.
do vdt = v-dtini to v-dtfin:
   for each plani use-index datexp where plani.datexp = vdt no-lock:
        if plani.etbcod = 22 or
           plani.desti  = 22
        then export plani.
        conta3 = conta3 + 1.
        display stream tela conta3 with frame fmostra.
   end.
end.
output close.

    output to ..\export\cpd22\movim.d.
    do vdt = v-dtini to v-dtfin:
        for each plani use-index datexp where plani.datexp = vdt no-lock:
                if plani.etbcod = 22 or
                   plani.desti  = 22
                then do:
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                        conta4 = conta4 + 1.
                        display stream tela conta4 with frame fmostra.
                        export movim.
                    end.
                end.
        end.
    end.
    output close.
