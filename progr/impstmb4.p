/***************************************************************************
** Programa        : impSTMb4.p
** Objetivo        : Importacao de Dados do CPD via Modem STM
** Ultima Alteracao: 10/10/96
** Programador     : Cristiano Borges Brasil
** Chama Programa  : ImpSTMmz.p
****************************************************************************/
{admcab.i}

def new shared frame fmostra.
def new shared frame fperiodo.
def new shared frame flimpa.
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
def new shared var vdire       as char format "x(20)".

def var vmiccod     like micro.miccod.
def var v-etbcod    like estab.etbcod                            no-undo.
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
def stream tela.

assign vhora  = time.

form v-dtini    label "Data Inicial"
     v-dtfin    label "Data Final"
     with side-label 2 column color white/cyan title " PERIODO A IMPORTAR "
     row 4 centered frame fperiodo.

form skip(1)
     "Arquivo de Saldos   :" conta1 skip
     "Arquivo de Controle :" conta2 skip
     "Integridade de Dados:" conta6 skip(1)
     "Titulos             :" conta3 skip
     "Contratos           :" conta4 skip
     "Clientes            :" conta5 skip
     with frame fmostra row 8 column 18 color blue/cyan no-label
     title " IMPORTACAO DE DADOS - CPD " overlay.

form skip(1)
     conta7 skip
     conta8
     skip(2)
     with frame flimpa row 8 column 52 color blue/cyan no-label
     title " LIMPA " overlay.

form skip
     vhora
     skip
     with frame fhora row 15 column 52 color blue/cyan no-label
     title " TEMPO " overlay.

form skip(1)
     "*** ATENCAO :  Arquivo de Controle"
     "               Danificado ou inexistente !!"
     skip(1)
     with centered  color blink/red title " ERRO DE IMPORTACAO " 1 column
     no-label row 8 frame faviso.
/*
run contimp.p.
*/

/*****************************************************************************
 EXECUTA O PROGRAMA DE LEITURA DO ARQUIVO .TXT RECEBIDO PELO STM-400 PARA
 DESCOBRIR A QUE LOJA PERTENCE E DEPOIS GUARDA-O EM SEU DIRETORIO
*****************************************************************************/
run letxt.p.
pause 0 before-hide.
output stream tela to terminal.

for each estab no-lock:
    if estab.etbcod = 990 or
       estab.etbcod = 999
    then next.
    dos silent value("md ..\import\loja" + string(estab.etbcod,"999")).
    pause 0.
end.

for each estab no-lock:

    assign conta1 = 0
           conta2 = 0
           conta3 = 0
           conta4 = 0
           conta5 = 0
           conta6 = 0
           conta7 = 0
           conta8 = 0.

    hide stream tela frame fmostra no-pause.
    hide stream tela frame flimpa  no-pause.

    display stream tela conta1
                        conta2
                        conta3
                        conta4
                        conta5
                        conta6 with frame fmostra.
    display stream tela conta7
                        conta8 with frame flimpa.

    if estab.etbcod = 999
    then next.
    vdire = "..\import\loja" + string(estab.etbcod,"99").
    message "Importando " + vdire.
    if search(vdire + "\export.d") <> ?
    then do:
        input from value(vdire + "\export.d") no-echo.
        repeat:
            set v-etbcod v-dtini v-dtfin.
        end.
    end.
    else do:
        bell.
        display skip(1)
                " LOJA "
                estab.etbcod no-label
                estab.etbnom no-label
                skip
                " NAO FOI IMPORTADA POR FALTA DE DADOS !!"
                skip(1)
                with side-label color blink/white row 10 centered
                title " ATENCAO !! " overlay frame fsem.
        pause.
        hide frame fsem no-pause.
        next.
    end.

    display v-dtini
            v-dtfin with frame fperiodo.

    display " LOJA "
        estab.etbcod no-label format "99"
        caps(estab.etbnom) no-label
        with centered row 19 width 46 color white/cyan
        title " IMPORTANDO LOJA " side-labels frame f1 overlay.

    for each salexporta:
        delete salexporta.
    end.

    input close.
    if search(vdire + "\salexpor.d") <> ?
    then do:
        input from value(vdire + "\salexpor.d") no-echo.
        repeat with frame fsal:
            prompt-for salexporta with no-validate with frame fsal.

            if input frame fsal salexporta.etbcod = 999
            then next.

            find salexporta where
                          salexporta.etbcod = input frame fsal salexporta.etbcod
                      and salexporta.cxacod = input frame fsal salexporta.cxacod
                      and salexporta.saldt  = input frame fsal salexporta.saldt
                      and salexporta.modcod = input frame fsal salexporta.modcod
                      and salexporta.moecod = input frame fsal salexporta.moecod
                                                    no-error.

            if not avail salexporta
            then create salexporta.

            assign salexporta.etbcod = input frame fsal salexporta.etbcod
               salexporta.cxacod = input frame fsal salexporta.cxacod
               salexporta.SalDt  = input frame fsal salexporta.SalDt
               salexporta.saldo  = input frame fsal salexporta.saldo
               salexporta.dtexp  = input frame fsal salexporta.dtexp
               salexporta.moecod = input frame fsal salexporta.moecod
               salexporta.modcod = input frame fsal salexporta.modcod
               salexporta.salqtd = input frame fsal salexporta.salqtd
               salexporta.salexp = input frame fsal salexporta.salexp
               salexporta.salimp = input frame fsal salexporta.salimp.

            conta1 = conta1 + 1.
            display conta1 with frame fmostra.
            display stream tela string((time - vhora),"HH:MM:SS")
                            @ vhora with frame fhora.
        end.
    end.
    else do:
        bell.
        leave.
    end.

    if search(vdire + "\titulo.d") <> ?
    then do:
        pause 0.
        input from value(vdire + "\titulo.d") no-echo.
        repeat with frame ftitexp:

            prompt-for
            ^
            titulo.modcod
            titulo.CliFor
            ^
            titulo.titpar
            ^
            ^
            ^
            ^
            titulo.titvlcob
            ^
            ^
            ^
            ^
            ^
            ^
            titulo.titdtpag
            titulo.titdesc
            titulo.titjuro
            titulo.titvlpag
            ^
            ^
            ^
            ^
  /* */     ^
            ^
            ^
            ^
            titulo.cxacod
            ^
            ^
            ^
            ^
            ^
            titulo.datexp
            titulo.moecod with no-validate with frame ftitexp.

            conta2 = conta2 + 1.
            display conta2 with frame fmostra.

        vmodcod = input frame ftitexp titulo.modcod.
        if input frame ftitexp titulo.titdtpag = ?
        then vmodcod = "VDP".

        if input frame ftitexp titulo.titpar    = 0 or
        input frame ftitexp titulo.clifor    = 1
        then do:
            if input frame ftitexp titulo.clifor = 1
            then vmodcod = "VDV".
            else vmodcod = "ENT".
        end.

        find first salexporta where salexporta.etbcod = v-etbcod
                        and salexporta.cxacod  =
                            input frame ftitexp titulo.cxacod
                        and salexporta.saldt   =
                            input frame ftitexp titulo.datexp
                        and salexporta.moecod  =
                            input frame ftitexp titulo.moecod
                        and salexporta.modcod  = vmodcod
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = v-etbcod
                salexporta.modcod = vmodcod
                salexporta.moecod = input frame ftitexp titulo.moecod
                salexporta.cxacod = input frame ftitexp titulo.cxacod
                salexporta.saldt  = input frame ftitexp titulo.datexp
                salexporta.salimp = salexporta.salimp +
                    input frame ftitexp titulo.titvlcob
                salexporta.dtexp  = today.

        find first salexporta where salexporta.etbcod   = v-etbcod
                        and salexporta.cxacod  =
                            input frame ftitexp titulo.cxacod
                        and salexporta.saldt   =
                            input frame ftitexp titulo.datexp
                        and salexporta.moecod  = ""
                        and salexporta.modcod  = "TOT"
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = v-etbcod
                salexporta.modcod = "TOT"
                salexporta.moecod = ""
                salexporta.cxacod = input frame ftitexp titulo.cxacod
                salexporta.saldt  = input frame ftitexp titulo.datexp
                salexporta.salimp = salexporta.salimp +
                    input frame ftitexp titulo.titvlpag.
                salexporta.dtexp  = today.
        if input frame ftitexp titulo.titjuro > 0
        then do:
            find first salexporta where salexporta.etbcod = v-etbcod
                        and salexporta.cxacod  =
                            input frame ftitexp titulo.cxacod
                        and salexporta.saldt   =
                            input frame ftitexp titulo.datexp
                        and salexporta.moecod  =
                            input frame ftitexp titulo.moecod
                        and salexporta.modcod  = "JUR"
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = v-etbcod
                salexporta.modcod = "JUR"
                salexporta.moecod = input frame ftitexp titulo.moecod
                salexporta.cxacod = input frame ftitexp titulo.cxacod
                salexporta.saldt  = input frame ftitexp titulo.datexp
                salexporta.salimp = salexporta.salimp +
                    input frame ftitexp titulo.titjuro.
                salexporta.dtexp  = today.
        end.
        if input frame ftitexp titulo.titdesc > 0
        then do:
            find first salexporta where salexporta.etbcod = v-etbcod
                        and salexporta.cxacod  =
                            input frame ftitexp titulo.cxacod
                        and salexporta.saldt   =
                            input frame ftitexp titulo.datexp
                        and salexporta.moecod  =
                            input frame ftitexp titulo.moecod
                        and salexporta.modcod  = "DES"
                            no-error.
            if not avail salexporta
            then create salexporta.
            assign
                salexporta.etbcod = v-etbcod
                salexporta.modcod = "DES"
                salexporta.moecod = input frame ftitexp titulo.moecod
                salexporta.cxacod = input frame ftitexp titulo.cxacod
                salexporta.saldt  = input frame ftitexp titulo.datexp
                salexporta.salimp = salexporta.salimp +
                    input frame ftitexp titulo.titdesc.
                salexporta.dtexp  = today.
            end.
            conta6 = conta6 + 1.
            display conta6 with frame fmostra.
            display stream tela string((time - vhora),"HH:MM:SS")
                            @ vhora with frame fhora.
        end.
    end.
    verro = no.
    for each salexporta where salexporta.saldt >= v-dtini and
                          salexporta.saldt <= v-dtfin.
        conta6 = conta6 + 1.
        display conta6 with frame fmostra.
        if salexporta.salimp <> salexporta.salexp
        then verro = yes.
    end.

    if verro
    then do:
        bell.
        bell.
        message "Erro".
        pause.
        view frame faviso. pause.
        hide frame faviso no-pause.
        run imprel.p ( input v-dtini,
                       input v-dtfin,
                       input v-etbcod).
        leave.
    end.

    run impSTMmz.p.

    do transaction:
        do vdata = v-dtini to v-dtfin:
        find importa where importa.etbcod  = v-etbcod and
                           importa.importa = vdata no-error.
        if not avail importa
        then create importa.
        assign importa.etbcod  = v-etbcod
               importa.importa = vdata.
        end.
    end.

    output to printer.
    view frame fmostra.
    output to close.

    run imprel.p ( input v-dtini,
                   input v-dtfin,
                   input v-etbcod).

/******************************************************************************
 ZERANDO OS ARQUIVOS DE CONTROLE
******************************************************************************/
    conta7 = 0.
    for each salexporta:
        delete salexporta.
        conta7 = conta7 + 1.
        display stream tela conta7 with frame flimpa.
    end.
end.
