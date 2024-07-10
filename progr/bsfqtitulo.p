def input parameter par-rec as recid.

run fin/bsfqtitulo.p (par-rec).

/**VERUS
/*
        bsfqtitulo.p
*/
{admcab.i}
{fqrecbanco.i}

def input parameter par-rec as recid.

def var vpossui_boleto as log.
def var vpossui_ted    as log.
def var recatu2        as recid.

def var par-dtini as date.
def NEW shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def NEW shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

pause 0.
def buffer xestab for estab.

find titulo where recid(titulo) = par-rec no-lock.
find xestab where xestab.etbcod = setbcod no-lock.

def var esqcom1         as char format "x(14)" extent 5
            initial [" Historicos ",
                     " Impressao  ",
                     " Notas Fiscais ","" ].
esqcom1 = "".
esqcom1[1] = " Historicos ".

run receb_banco (titulo.titnum, titulo.titpar,
                 output vpossui_boleto, output vpossui_ted, output recatu2).

if titulo.titnat = no and
   titulo.titsit = "PAG" and
   not vpossui_boleto and
   not vpossui_ted
then esqcom1[2] = " Caixa P2k ".

if titulo.titnat = no and
   titulo.titsit = "PAG" and
   vpossui_boleto
then esqcom1[2] = " Boleto ".

if titulo.titnat = no and
   titulo.titsit = "PAG" and
   vpossui_ted
then esqcom1[2] = " TED ".

def var vhistorico as char extent 5 format "x(20)"
    init [ "1.Pagamentos",
           ""
           /***"2.Movimentacao", 
           "3.Cobranca", 
           ***/  
         ].

def var vprog as char extent 5 format "x(12)" 
    init [ "fqtitpag",
           ""
            /***"fqcmmov", 
            "histico", 
            "obititpag", 
            "fqtitpagcob" 
            ***/
         ].


{bsfqtitulo.i}
                                          
if not xestab.etbnom begins "DREBES-FIL"
then assign
        vhistorico[2] = "2.Alteracoes"
        vprog[2]      = "fqtitulolog".

if titulo.titnat = no
then assign
        vhistorico[3] = "3.Financeira/FIDC"
        vprog[3]      = "fqfdic".

FORM
            SPACE(3)
            SKIP(9)
            WITH FRAME fborder ROW 13 column 17
                                WIDTH 26 NO-BOX OVERLAY COLOR MESSAGES.

def var esqpos1 as int.

form
    esqcom1
    with frame f-com2 row screen-lines no-labels column 1 centered no-box.
repeat:
    pause 0.
    hide frame fborder  no-pause.
    hide frame feschis no-pause.
    pause 0.
    display esqcom1 with frame f-com2.

    choose field esqcom1 with frame f-com2.
    esqpos1 = frame-index.
                if esqcom1[esqpos1] = " Impressao "
                then do:
                    sresp = no.
                    message "Impressao em Formulario BRANCO ?" update sresp.
                    if sresp
                    then run emidupbr.p (input recid(titulo)).
                    else run emidup.p   (input recid(titulo)).
                end.
                if esqcom1[esqpos1] = " Guia Transf. "
                then do:
                    run imptitpg.p   (input recid(titulo)).
                end.
                if esqcom1[esqpos1] = " Notas Fiscais "
                then do.
                    run fqnottit.p (input recid(titulo)).
                    view frame fclifor.
                    view frame ftitulo.
                    view frame f-com2.
                end.

    if esqcom1[esqpos1] = " Historicos "
    then do.
        hide frame fborder  no-pause.
        hide frame feschis no-pause.
        view frame fborder.
        pause 0.
        display vhistorico
                with frame feschis no-label 1 column
                                    column 19 row 14 overlay.
        choose field vhistorico with frame feschis.
        if vprog[frame-index] = ""
        then undo.
        hide frame fborder  no-pause.
        hide frame feschis no-pause.
        hide frame fclifor no-pause.
        hide frame ftitulo no-pause.
        hide frame f-com2       no-pause.
        run value(vprog[frame-index] + ".p") (input recid(titulo)).
    end.

    if esqcom1[esqpos1] = " Caixa P2k "
    then do.
        run busca_caixa.
    end.
    if esqcom1[esqpos1] = " Boleto"
    then do.
        run bol/banboletoman_v1701.p (input-output recatu2).
    end.
    if esqcom1[esqpos1] = " TED"
    then do.
        run bol/banavisopagman_v1701.p (input-output recatu2).
    end.

    if esqpos1 > 0
    then do.
        view frame fclifor.
        view frame ftitulo.
        view frame f-com2.
    end.
end.
hide frame fclifor      no-pause.
hide frame ftitulo      no-pause.
hide frame f-com2       no-pause.
hide frame fborder      no-pause.
hide frame feschis      no-pause.


procedure busca_caixa.

    find first cmon where cmon.etbcod = titulo.etbcobra
                      and cmon.cxacod = titulo.cxacod
                    no-lock no-error.
    if not avail cmon
    then do.
        message "Caixa nao e´ P2K" view-as alert-box.
        return.
    end.

    if (titulo.modcod = "CRE" or titulo.modcod begins "CP") and
       titulo.titdtpag <> ? and
       titulo.titpar > 0
    then do.
        find first pdvdoc where pdvdoc.etbcod  = titulo.etbcobra
                            and pdvdoc.cmocod  = cmon.cmocod
                            and pdvdoc.datamov = titulo.titdtpag
                            and pdvdoc.clifor  = titulo.clifor
                            and pdvdoc.modcod  = titulo.modcod
                            and pdvdoc.contnum = titulo.titnum
                            and pdvdoc.titpar  = titulo.titpar
                            and pdvdoc.titdtven = titulo.titdtven
                         no-lock no-error.
        if not avail pdvdoc
        then do.
            find first pdvdoc where pdvdoc.etbcod  = titulo.etbcobra
                                and pdvdoc.cmocod  = cmon.cmocod
                                and pdvdoc.datamov = titulo.titdtpag
                                /* and pdvdoc.clifor  = titulo.clifor */
                                and pdvdoc.modcod  = titulo.modcod
                                and pdvdoc.contnum = titulo.titnum
                                and pdvdoc.titpar  = titulo.titpar
                                /*and pdvdoc.titdtven = titulo.titdtven */
                              no-lock no-error.
            if not avail pdvdoc
            then do.
                pause.
                next.
            end.
        end.
    end.
    else if titulo.titpar = 0
    then do.
        find first pdvdoc where pdvdoc.etbcod  = titulo.etbcobra
                            and pdvdoc.cmocod  = cmon.cmocod
                            and pdvdoc.datamov = titulo.titdtpag
                            and pdvdoc.clifor  = titulo.clifor
                                /*and pdvdoc.modcod  = titulo.modcod */
                            and pdvdoc.contnum = titulo.titnum
                                /*and pdvdoc.titpar  = titulo.titpar */
                                /*and pdvdoc.titdtven = titulo.titdtven */
                          no-lock no-error.
    end.
    else do.
        find first titbsmoe of titulo NO-LOCK no-error.
        if not avail titbsmoe
        then next.
        find first pdvdoc where pdvdoc.xxtitcod = titbsmoe.titcod
                no-lock no-error.
        if not avail pdvdoc
        then next.
    end.

    find pdvmov of pdvdoc no-lock.
    run dpdv/pdvcope.p (recid(pdvmov)).

end procedure.
**/
