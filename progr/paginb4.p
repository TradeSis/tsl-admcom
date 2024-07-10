/***************************************************************************
** Programa        : paginb4.p
** Objetivo        : Inclusao de Pagamentos Especifico Drebes
** Ultima Alteracao: 21/05/96
**                 : Luciano
****************************************************************************/
{admcab.i}

def var i-sen           as int.
def var vsenha          as char format "x(6)".
def var vsenha1         like vsenha.

define variable vdate as date.
define variable wtitvlcob like titulo.titvlcob.
define variable wtitdtven like titulo.titdtven.
define variable wpar like titulo.titpar format ">>9".
define variable wpar1 like titulo.titpar format ">>9".
define variable wcon like contrato.contnum.
define variable rsp as logical format "Sim/Nao" initial yes.
define variable wenc as logical.
def var vdtpag  like titulo.titdtpag.
def var vtitvlpag   like titulo.titvlpag.
def var vpag    as log.
def var vetbcobra   like titulo.etbcobra initial 0.
def var vetbcod     like estab.etbcod.
def var vclifor     like titulo.clifor.
def var vtitnum     like titulo.titnum.
def var vetbcont    like titulo.etbcod.

def buffer btitulo for titulo.
def buffer ctitulo for titulo.

def buffer bestab for  estab.

repeat with frame f1 row 4 .
    form                        /*
        titulo.titvlcob     colon 15
        titulo.titdtpag     colon 15  */
        vtitvlpag validate (vtitvlpag > 0, "Valor Invalido") colon 15
        titulo.titjuro      colon 15
        titulo.titdesc      colon 15
        with frame flado column 42 side-label
             title " Pagamento " color white/cyan width 38 row 11.



    update vetbcobra COLON 20
           help "Informe o Codigo do Estabelecimento".
    find estab where estab.etbcod = vetbcobra no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    disp estab.etbnom NO-LABEL.
    if vetbcobra = 990
    then do:
        input from ../gener/paulo.d no-echo.
        set vsenha with frame f.
        input close.
        vsenha1 = "".
        update vsenha1 label "Senha" blank
        with frame fsenha overlay centered row 10 color
                            black/red side-label.
        hide frame fsenha no-pause.
        if vsenha <> vsenha1
        then do:
            message "Senha Invalida".
            undo.
        end.
    end.
    VETBCONT = VETBCOBRA.
    UPDATE vetbcont label "Loja Contrato"
                   help "Informe a Loja onde foi efetuada a compra"
                COLON 20.

    find bestab where bestab.etbcod = vetbcont no-lock no-error.
    if not avail bestab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.

    update vdtpag colon 20 label "Data Pagamento" skip(1).
    if year(vdtpag) <> year(today)
    then do:
        bell.
        bell.
        message "Confirma o ano de pagamento".
        bell.
        bell.
    end.
    repeat with SIDE-LABEL width 80 frame f1 title " Cliente ":
        hide frame f2    no-pause.
        hide frame flado no-pause.
        clear frame  flado all.
        prompt-for clien.clicod COLON 20.
        find clien using clien.clicod no-error.
        if not avail clien
        then do:
            message "Cliente Invalido".
            undo.
        end.
        display clien.clinom no-label.

    l-1:
    do on endkey undo , leave with 1 column width 39 frame f2 title " Titulo "
                        row 11:
        prompt-for contrato.contnum.
        find contrato where contnum = input contrato.contnum no-error.
        if not available contrato
        then do:
            message "Contrato inexistente, tente novamente.".
           /*ndo,retry.*/
        end.
        if avail contrato and
           contrato.clicod <> clien.clicod
        then do:
            bell.
            message "Este Contrato nao pertence a este Cliente.".
            message "Efetuar o pagamento em MANUTENCAO DE PARCELAS".
            pause 10 no-message.
            undo,retry.
        end.
        prompt-for titulo.titpar format ">>9".
        assign
            vetbcod = if avail contrato
                     then contrato.etbcod
                     else input vetbcont
            vclifor = if avail contrato
                      then contrato.clicod
                      else clien.clicod
            vtitnum = if avail contrato
                      then string(contrato.contnum)
                      else string(input contrato.contnum) .
        find titulo use-index titnum where
             titulo.empcod = wempre.empcod                          and
             titulo.titnat = no                                     and
             titulo.modcod = "CRE"                                  and
             titulo.etbcod = vetbcod and
             titulo.clifor = vclifor and
             titulo.titnum = vtitnum and
             titulo.titpar = input titulo.titpar
                        no-error .
        if not avail titulo
        then do:
            message "Titulo nao Encontrado".
            undo.
        end.

        display titulo.titnum
                titulo.titpar format ">>9"
                titulo.titdtemi
                titulo.titdtven.
        if titulo.titsit =  "PAG"
        then do:
            message "Titulo Com Situacao Ilegal Para Pagamento," titulo.titsit.
            pause.
            undo.
        end .

        vpag = no.

        /*************
        for each btitulo use-index titnum where
                        btitulo.empcod = wempre.empcod  and
                        btitulo.titnat = no             and
                        btitulo.modcod = "CRE"          and
                        btitulo.etbcod = vetbcod        and
                        btitulo.clifor = vclifor        and
                        btitulo.titnum = vtitnum        and
                        btitulo.titpar < input titulo.titpar no-lock.

            if btitulo.titsit <> "PAG"
            then do:
                bell.
                message "Contrato possui Parcelas Anteriores nao Pagas".
                vpag = yes.
                leave.
            end.
        end.
        *******/

        if vpag
        then
            undo l-1.
                         /*
        display titulo.titvlcob
                with frame flado.*/
        assign titulo.titdtpag = vdtpag
               titulo.datexp   = today
               titulo.cxmdat   = today
               titulo.cxacod   = 999.
        /*
        display titulo.titdtpag
               with frame flado.*/
        vdtpag = titulo.titdtpag.
        vdate = titulo.titdtpag.
        /*
        if titulo.titdtpag > titulo.titdtven
        then
            assign titulo.titvlpag = titulo.titvlcob + (titulo.titvljur *
                                     (titulo.titdtpag - titulo.titdtven)).
        else
            assign titulo.titvlpag = titulo.titvlcob.
        */
        l-pag:
        do on endkey undo l-1, leave l-1
           on error  undo:
        vtitvlpag = 0.
        update vtitvlpag validate
              (vtitvlpag > 0,
              "Valor Invalido")
               colon 15
               with frame flado .
        if  vtitvlpag > titulo.titvlcob then do:
            bell.
            message "Valor de Pagamento Invalido".
            undo l-pag, retry l-pag.
        end.
        end.
        titulo.cobcod = 2.
        if  vtitvlpag >= titulo.titvlcob then
            titulo.titjuro = vtitvlpag - titulo.titvlcob.
        else do:
            assign sresp = yes.
            display "  Confirma PAGAMENTO PARCIAL ?"
                                with frame fpag color messages
                                width 40 overlay row 10 centered.
            update sresp no-label with frame fpag.
            hide frame fpag no-pause.

            if sresp = no
            then do:
                bell.
                display " A opcao PAG PARCIAL foi negada, para sua seguranca "
                        skip
                        " Confirma PAGAMENTO PARCIAL ??? "
                                with frame fpag2 color messages
                                centered overlay row 10.
                update sresp no-label with frame fpag2.
                hide frame fpag2 no-pause.
            end.

            if  sresp then do:
                find last btitulo use-index titnum where
                          btitulo.empcod   = wempre.empcod and
                          btitulo.titnat   = titulo.titnat and
                          btitulo.modcod   = titulo.modcod and
                          btitulo.etbcod   = titulo.etbcod and
                          btitulo.clifor   = titulo.clifor and
                          btitulo.titnum   = titulo.titnum.
                create ctitulo.
                assign ctitulo.empcod = btitulo.empcod
                       ctitulo.modcod = btitulo.modcod
                       ctitulo.clifor = btitulo.clifor
                       ctitulo.titnat = btitulo.titnat
                       ctitulo.etbcod = btitulo.etbcod
                       ctitulo.titnum = btitulo.titnum
                       ctitulo.cobcod = titulo.cobcod
                       ctitulo.titpar   = btitulo.titpar + 1
                       ctitulo.titdtemi = titulo.titdtemi
                       ctitulo.titdtven = titulo.titdtven
                       ctitulo.titvlcob = titulo.titvlcob - vtitvlpag
                       ctitulo.titnumger = titulo.titnum
                       ctitulo.titparger = titulo.titpar
                       ctitulo.titsit    = "IMP"
                       ctitulo.datexp    = today
                        titulo.titnumger = ctitulo.titnum
                        titulo.titparger = ctitulo.titpar.
                do on endkey undo, leave:
                display ctitulo.titnum
                        ctitulo.titpar format ">>9"
                        ctitulo.titdtemi
                        ctitulo.titdtven
                        ctitulo.titvlcob
                        with frame fmos width 40 1 column
                             title " Titulo Gerado " overlay
                                              column 41 row 10.
                end.
            end.
            else titulo.titdesc = titulo.titvlcob - vtitvlpag.
        end.
        update titulo.titjuro
               with frame flado.
        l-desc:
        do on endkey undo with frame flado:
            if keyfunction(lastkey) = "end-error"
            then undo l-1.
            update titulo.titdesc
                   with frame flado.
            if titulo.titdesc >= titulo.titvlcob
            then do:
                message "Desconto maior que valor da prestacao".
                undo l-desc.
            end.
        end.
        assign titulo.titvlpag = vtitvlpag + titulo.titjuro.
        assign titulo.titvlpag = titulo.titvlpag - titulo.titdesc.
        assign titulo.titsit = "PAG"
               titulo.datexp = today
               titulo.cxmdat = today
               titulo.cxacod = 99.
        assign titulo.etbcobra = vetbcobra .
    end.
    message "Pagamento efetuado.".
    end.
end.
