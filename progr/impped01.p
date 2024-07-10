/***************************************************************************
** Programa        : impped00.p
****************************************************************************/
{admcab.i}

def temp-table tt-pedid like pedid.
def temp-table tt-liped like liped.
def var vlog as l.
def temp-table tt-func like func.
def temp-table wtit like titulo.
def temp-table wtitulo
    field wdata like titulo.titdtemi
    field wvalor like titulo.titvlcob.



def var vetbi like estab.etbcod format ">>9".
def var vetbf like estab.etbcod format ">>9".

def var i as int.
def var vprog as char format "x(30)".
def var vdir as char format "x(30)".


def var recpla as recid.
def var recmov as recid.
def temp-table tt-plani like plani.
def temp-table tt-movim like movim.
def var ii as int.
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
def var v-dtini     as date format "99/99/9999" init today no-undo.
def var v-dtfin     as date format "99/99/9999" init today no-undo.
def var vdata       as date format "99/99/9999" no-undo.
def var vdata1      as date format "99/99/9999" initial today  no-undo.
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
/*
def stream tela.
def stream stela.
*/
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
     "Filial              :" estab.etbnom no-label skip
     "Pedido              :" conta1 skip
     "Produtos            :" conta2 skip
         with frame fmostra row 8 centered color blue/cyan no-label
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


def var vi as int.
def var vmarcado as dec format ">>>,>>>,>>>,>>9 Bytes" .
def var vtotal   as dec format ">>>,>>>,>>>,>>9 Bytes".
def var vCOPIADO as dec format ">>>,>>>,>>>,>>9 Bytes".
DEF VAR vunida-origem  AS CHAR INITIAL ".." label "Unidade Origem".
DEF VAR vunida-destino AS CHAR INITIAL "A:" label "Unidade Destino".
def var vaux as char.
def var vokdos  as log.
DEF VAR A AS CHAR FORMAT "X(40)".

/*
message "Confirma Importacao de Pedidos ? " update sresp.
if not sresp 
then return.
 */
 sresp = yes.

i = 0.
pause 0 before-hide.

do i = 1 to 99:

    if search("..\pedido\exp" + string(i,"99") + ".zip") = ?
    then if search("..\pedido\ped" + string(i,"99") + ".zip") = ?
         then next.
         
    if search("..\pedido\exp" + string(i,"99") + ".zip") <> ?
    then do:
        dos silent pkunzip -do value("..\pedido\exp" + string(i,"99") + ".zip")
                       ..\pedido.
    end.
    else do:
        dos silent pkunzip -do value("..\pedido\ped" + string(i,"99") + ".zip")
                       ..\pedido.
    end.
    
    conta1 = 0.
    conta2 = 0.
    conta3 = 0.
    find estab where estab.etbcod = i no-lock.
    display estab.etbnom no-label with frame fmostra.
    
    /*
    view stream tela frame fmostra.
    view stream tela frame f1.
    view stream tela frame f-periodo.
    */                  
    if search("..\pedido\pedid.d") <> ?
    then do:
        pause 0.
        input from l:\pedido\pedid.d no-echo.
        repeat:
            for each tt-pedid.
                delete tt-pedid.
            end.
            create tt-pedid.
            import tt-pedid.
            find pedid where pedid.etbcod = tt-pedid.etbcod and
                             pedid.pedtdc = tt-pedid.pedtdc and
                             pedid.pednum = tt-pedid.pednum no-error.
            if not avail pedid
            then do:
                create pedid.
                assign pedid.pedtdc    = tt-pedid.pedtdc
                       pedid.pednum    = tt-pedid.pednum
                       pedid.regcod    = tt-pedid.regcod
                       pedid.peddat    = tt-pedid.peddat
                       pedid.comcod    = tt-pedid.comcod
                       pedid.pedsit    = tt-pedid.pedsit
                       pedid.fobcif    = tt-pedid.fobcif
                       pedid.nfdes     = tt-pedid.nfdes
                       pedid.ipides    = tt-pedid.ipides
                       pedid.dupdes    = tt-pedid.dupdes
                       pedid.cusefe    = tt-pedid.cusefe
                       pedid.condes    = tt-pedid.condes
                       pedid.condat    = tt-pedid.condat
                       pedid.crecod    = tt-pedid.crecod
                       pedid.peddti    = tt-pedid.peddti
                       pedid.peddtf    = tt-pedid.peddtf
                       pedid.acrfin    = tt-pedid.acrfin
                       pedid.sitped    = tt-pedid.sitped
                       pedid.vencod    = tt-pedid.vencod
                       pedid.frecod    = tt-pedid.frecod.
        
                assign pedid.modcod    = tt-pedid.modcod
                       pedid.etbcod    = tt-pedid.etbcod
                       pedid.pedtot    = tt-pedid.pedtot
                       pedid.clfcod    = tt-pedid.clfcod
                       pedid.pedobs[1] = tt-pedid.pedobs[1]
                       pedid.pedobs[2] = tt-pedid.pedobs[2]
                       pedid.pedobs[3] = tt-pedid.pedobs[3]
                       pedid.pedobs[4] = tt-pedid.pedobs[4]
                       pedid.pedobs[5] = tt-pedid.pedobs[5].
            end.

            conta1 = conta1 + 1.
          /*  display stream tela conta1 with frame fmostra. */
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
                find produ where produ.procod = tt-liped.procod 
                                                        no-lock no-error.
                if avail produ
                then do:
                    if produ.catcod = 31 or
                       produ.catcod = 35
                    then liped.protip = "M".
                    else liped.protip = "C".
                end.
            end.
        
            conta2 = conta2 + 1.
        /*    display stream tela conta2 with frame fmostra.  */
    
        end.
        input close.
    end. 
end.
dos silent del l:\pedido\*.d.
dos silent del l:\pedido\*.zip.
