/*
        bsfqtitulo.p
*/

{admcab.i}
def input parameter par-rec as recid.
pause 0.
find titulo where recid(titulo) = par-rec no-lock.

    {bsfqtitulo.i}

def var esqcom1         as char format "x(14)" extent 5
            initial [" Historicos ",
                     " Impressao  ",
                    /* " Guia Transf. ",*/
                     "            ",
                     " Notas Fiscais ","" ].

esqcom1 = "".

if titulo.titnat = no
then
    esqcom1[3] = "".
/*******
if titulo.tdfcod = "CHE" and scliente = "OBI"
then do.
    def var vge as log.
    def buffer bcmonope for cmonope.
    def buffer btitulo for titulo.
    vge = no.
    for each cmonope of titulo no-lock.
        find cmondoc of cmonope no-lock no-error.
        if not avail cmondoc 
        then next.
        for each bcmonope of cmondoc no-lock.
            find btitulo of bcmonope no-lock no-error.
            if not avail btitulo
            then next.
            if btitulo.modcod = "GE"
            then vge = yes.
        end.
    end.
    if vge = yes
    then do.
        esqcom1[5] = " Reabre GE ".
    end.
end.
*/


def var vhistorico as char extent 5 format "x(15)" 
    init [ "1.Pagamentos", 
           "2.Movimentacao", 
           "3.Cobranca", 
           "4.OBINO ", 
           "5.Lotes GE " 
           ].
def var vprog as char extent 5 format "x(12)" 
    init [  "fqtitpag"  , 
            "fqcmmov", 
            "histico", 
            "obititpag", 
            "fqtitpagcob" 
            ].
                                          
if scliente <> "OBI"
then assign vhistorico[4] = ""  vprog[4] = "". 
if titulo.modcod <> "GE"
then assign vhistorico[5] = "" vprog[5] = "".

if setbcod >= 100
then assign vhistorico[4] = "" vprog[4] = "".
def var esqpos1 as int.

form
    esqcom1
    with frame f-com2
                 row screen-lines no-labels side-labels column 1
                 centered no-box.
repeat:
    pause 0.

                    hide frame fborder  no-pause.
                    hide frame feschis no-pause.
    pause 0.
    display esqcom1
            with frame f-com2.

    choose field esqcom1 with frame f-com2.
    esqpos1 = frame-index.
                if esqcom1[esqpos1] = " Impressao "
                then do:
                    sresp = no.
                    message "Impressao em Formulario BRANCO ?" update sresp.
                    if sresp
                    then
                        run emidupbr.p (input recid(titulo)).
                    else
                        run emidup.p   (input recid(titulo)).
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
                if esqcom1[esqpos1] = " Reabre GE "
                then do.
                    run obigeche.p (input recid(titulo)).
                    view frame fclifor.
                    view frame ftitulo.
                    view frame f-com2.
                end.
                if esqcom1[esqpos1] = " Historicos "
                then do.
                    hide frame fborder  no-pause.
                    hide frame feschis no-pause.
                    FORM
                    SPACE(3)
                    SKIP(9)
                        WITH FRAME fborder
                                ROW 13 column 17
                                WIDTH 21 NO-BOX OVERLAY COLOR MESSAGES.
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
                    view frame fclifor.
                    view frame ftitulo.
                    view frame f-com2.
                end.
end.
hide frame fclifor       no-pause.
hide frame ftitulo      no-pause.
hide frame f-com2       no-pause.
hide frame fborder      no-pause.
hide frame feschis      no-pause.
