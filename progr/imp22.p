/***************************************************************************
** Programa        : impmatb4.p
** Objetivo        : Importacao de Dados do CPD
** Ultima Alteracao: 22/07/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpMatMz.p
****************************************************************************/
{admcab.i}
/* def new shared frame fmostra. */
def new shared frame fperiodo.
/* def new shared frame flimpa.  */
def new shared frame fhora.
def new shared var conta1      as integer.
def new shared var conta2      as integer.
def new shared var conta3      as integer.
def new shared var conta4      as integer.
def new shared var conta5      as integer.
def new shared var conta6      as integer.
def new shared var conta7      as integer.
def new shared var conta8      as integer.
def new shared var vhora       as integer.
def new shared var v-etbcod    like estab.etbcod.

def var varq        as char                                      no-undo.
def var vmiccod     like micro.miccod.
def var v-dtini     as date init today                           no-undo.
def var v-dtfin     as date init today                           no-undo.
def var vdata       as date                                      no-undo.
def var vtotcli     as   int.
def var vtotcont    as   int.
def var vtitpg      as   int.
def var vtotparc    as   int.
def var vtotpag     like titulo.titvlpag.
def var vtotvl      like contrato.vltotal.
def var vtitsit     like titulo.titsit.
def var vtitdtpag   like titulo.titdtpag.
def var vmodcod     like titulo.modcod.
def var verro       as log.
def buffer vestab   for estab.
def stream tela.

assign conta1 = 0
       conta2 = 0
       conta3 = 0
       conta4 = 0
       conta5 = 0
       conta6 = 0
       conta7 = 0
       conta8 = 0
       vhora  = time.

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.

form skip(1)
     "Notas               :" conta1 skip
     "Movimentos          :" conta2 skip
     "Contas a Pagar      :" conta3 skip
     with frame fmostra row 8 column 18 color blue/cyan no-label
     title " IMPORTACAO DE DADOS - CPD ".

form skip
     vhora
     skip
     with frame fhora row 10 column 52 color blue/cyan no-label
     title " TEMPO ".

form skip(1)
     "*** ATENCAO :  Arquivo de Controle"
     "               Danificado ou inexistente !!"
     skip(1)
     with centered  color blink/red title " ERRO DE IMPORTACAO " 1 column
     no-label row 8 frame faviso.

pause 0 before-hide.

output stream tela to terminal.

view stream tela frame fmostra.

message "Confirma Importacao de Dados ? " update sresp.

if not sresp then leave.


if search("..\import\plani.d") <> ?
then do:
    pause 0.
    input from ..\import\plani.d no-echo.
    repeat:
        create plani.
        import plani.
        conta1 = conta1 + 1.
        display stream tela conta1 with frame fmostra.
    end.
    input close.
end.

if search("..\import\movim.d") <> ?
then do:
    pause 0.
    input from ..\import\movim.d no-echo.
    repeat:
        create movim.
        import movim.
        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
        /*
        run atuest.p (input recid(movim),
                      input "I",
                      input 0).
        */
    end.
    input close.
end.

if search("..\import\produ.d") <> ?
then do:
    pause 0.
    input from ..\import\produ.d no-echo.
    repeat:
        create produ.
        import produ.
        conta3 = conta3 + 1.
        display stream tela conta3 with frame fmostra.
    end.
    input close.
end.

if search("..\import\estoq.d") <> ?
then do:
    pause 0.
    input from ..\import\estoq.d no-echo.
    repeat:
        create estoq.
        import estoq.
        conta3 = conta3 + 1.
        display stream tela conta3 with frame fmostra.
    end.
    input close.
end.
