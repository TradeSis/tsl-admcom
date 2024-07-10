/***************************************************************************
** Programa        : impmatb4.p
** Objetivo        : Importacao de Dados do CPD
** Ultima Alteracao: 22/07/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpMatMz.p
****************************************************************************/
{admcab.i}
def new shared frame fperiodo.
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
def temp-table tt-liped like liped.
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
     "Pedidos             :" conta1 skip
     "Produtos            :" conta2 skip
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

if not sresp 
then leave.
conta1 = 0.
conta2 = 0.
                 
if search("..\pedido\pedid.d") <> ?
then do:
    pause 0.
    input from l:\pedido\pedid.d no-echo.
    repeat:
        create pedid.
        import pedid.
        
        conta1 = conta1 + 1.
        display stream tela conta1 with frame fmostra.
            
    end.
    input close.
end.
                 
if search("..\pedido\liped.d") <> ?
then do:
    pause 0.
    input from l:\pedido\liped.d no-echo.
    repeat:
        for each tt-liped:
            delete tt-liped.
        end.
        create tt-liped.
        import tt-liped.

        find liped where liped.pedtdc = tt-liped.pedtdc and
                         liped.etbcod = tt-liped.etbcod and
                         liped.pednum = tt-liped.pednum and
                         liped.procod = tt-liped.procod and
                         liped.predt  = tt-liped.predt  and
                         liped.lipcor = tt-liped.lipcor no-error.
        if not avail liped
        then do:
            create liped.
            ASSIGN liped.pedtdc   = tt-liped.pedtdc
                   liped.pednum   = tt-liped.pednum
                   liped.procod   = tt-liped.procod
                   liped.lipqtd   = tt-liped.lipqtd
                   liped.lippreco = tt-liped.lippreco
                   liped.lipsit   = tt-liped.lipsit
                   liped.lipent   = tt-liped.lipent
                   liped.predtf   = tt-liped.predtf
                   liped.predt    = tt-liped.predt
                   liped.lipcor   = tt-liped.lipcor
                   liped.etbcod   = tt-liped.etbcod.
            find produ where produ.procod = tt-liped.procod no-lock no-error.
            if avail produ
            then do:
                if produ.catcod = 31 or
                   produ.catcod = 35
                then liped.protip = "M".
                else liped.protip = "C".
            end.
        end.
        
        conta2 = conta2 + 1.
        display stream tela conta2 with frame fmostra.
    
    end.
    input close.
end. 
output stream tela close.
         
     
