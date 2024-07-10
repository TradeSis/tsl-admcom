/*
*   cmdtit.p
*/
def var primeiro as log.
def var vbusca          like titulo.titnum.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(13)" extent 5
    initial [" Seleciona "," Liq. Total "," Liq. Parcial ", " Consulta ",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Seleciona o titulo ",
             " Consulta do titulo ",
             " Coloca Juros ou Desconto no titulo ",""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
{cabec.i}
def input parameter par-pdvmov-recid   as recid.
def input parameter par-openat          as log.
def input parameter par-titnat          as log.
def input parameter par-operacao        as char.

def buffer xcmon    for cmon.
def var vcont as int.
def var vtitpar like titulo.titpar.
def var vtot-titulos        like titulo.titvlcob column-label "Total".
def var vtot-selecionados   like titulo.titvlcob column-label "Selecionados".
def var vtotdesc            like vtot-selecionados.
def var vtotjuro             like vtot-selecionados.

def var vcmopedesc as char.
/*def var vsaldo like titulo.titvlcob label "Saldo" column-label "Saldo"
                            format ">>>,>>9.99".*/

def shared temp-table wfselecao no-undo
    field marcados as log initial no
    field rec as recid
    field rec-cmontit as recid.
def buffer bwfselecao for wfselecao.
form
    esqcom1 skip(1)
    with frame f-com1 centered 
                 row 21 no-box no-labels side-labels column 1
                    overlay width 80.
/*
form
    esqcom2
    with frame f-com2
                 row screen-lines - 2 no-box no-labels side-labels column 1
                 centered overlay.
*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

find pdvmov where recid(pdvmov) = par-pdvmov-recid.
find pdvtmov     of pdvmov no-lock.
find cmon       of pdvmov    no-lock.
find cmtipo     of cmon no-lock.

assign vtot-titulos      = 0
       vtot-selecionados = 0.
vtotdesc = 0.
vtotjuro  = 0.
for each pdvdoc of pdvmov 
                     no-lock.
    vtotdesc = vtotdesc + pdvdoc.desconto.
    vtotjuro = vtotjuro + pdvdoc.valor_encargo.
end.
/*
for each wfselecao.
    vtot-titulos = vtot-titulos + vsaldo.
    if wfselecao.marcados
    then vtot-selecionados = vtot-selecionados + vsaldo.
end.
**/
vtot-selecionados = vtot-selecionados - vtotdesc + vtotjuro.
display vtot-titulos        colon 20 label "Total"
        vtot-selecionados   colon 60 label "Selecionado"
        with frame fselecao
                color message row 20 overlay width 81 no-box side-label.

pause 0.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    /*
    disp esqcom2 with frame f-com2.
    */
    if recatu1 = ?
    then
        if esqascend
        then
            find first wfselecao
                                        no-lock no-error.
        else
            find last wfselecao
                                        no-lock no-error.
    else
        find wfselecao where recid(wfselecao) = recatu1 no-lock.
    if not available wfselecao
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        find titulo where recid(titulo) = wfselecao.rec no-lock.
        find clien where clien.clicod = titulo.clifor no-lock.
        /*vsaldo = titulo.titvlcob - titulo.titvlpag.*/
        display
            wfselecao.marcados format "*/" no-label
            space(0)
            clien.clicod
            clien.clinom      column-label "Cliente" format "x(12)"
            titulo.etbcod      format ">>9" column-label "Etb"
            {titnum.i}
            titulo.modcod
            titulo.titdtven     format "99/99/99" column-label "Vencim."
            titulo.titvlcob
            with frame frame-a 10 down centered color white/red row 5 overlay
                    width 80
                title " Contas a " + string(par-titnat,
                                                "Pagar/Receber") + " ".
    end.
    else do on endkey undo:
        message "Nenhum titulo Nesta Selecao".
        pause.
        leave.
    end.
    recatu1 = recid(wfselecao).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*
    else color display message esqcom2[esqpos2] with frame f-com2.
    */
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next wfselecao
                    no-lock no-error.
        else
            find prev wfselecao
                    no-lock no-error.
        if not available wfselecao
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        find titulo where recid(titulo) = wfselecao.rec no-lock.
        find clien where clien.clicod = titulo.clifor no-lock.
       /* vsaldo = titulo.titvlcob - titulo.titvlpag.*/
        display
            wfselecao.marcados 
            clien.clicod
            clien.clinom     
            titulo.etbcod 
            {titnum.i}
            titulo.modcod
            titulo.titdtven  
            titulo.titvlcob

                with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        if not esqvazio
        then do:
            find wfselecao where recid(wfselecao) = recatu1 no-lock.
            find titulo where recid(titulo) = wfselecao.rec no-lock.
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then ""
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then ""
                                        else "".
            color display message wfselecao.marcados
                                  clien.clicod
                                  clien.clinom
                                  titulo.etbcod
                                  titulo.titnum
                                  titulo.modcod
                                  titulo.titdtven
                                  titulo.titvlcob
                                  with frame frame-a.

            choose field titulo.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                    1 2 3 4 5 6 7 8 9 0
                    q w e r t y u i o p l k j h g f d s a z x c v b n m
                    Q W E R T Y U I O P L K J H G F D S A Z X C V B N M
                      PF4 F4 ESC return) color white/black.
            status default "".
            color display normal  wfselecao.marcados
                                  clien.clicod
                                  clien.clinom
                                  titulo.etbcod
                                  titulo.titnum
                                  titulo.modcod
                                  titulo.titdtven
                                  titulo.titvlcob
                                  with frame frame-a.
        end.
        if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
           keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
           keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
           keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
           keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" or
           keyfunction(lastkey) = "q" or keyfunction(lastkey) = "w" or
           keyfunction(lastkey) = "e" or keyfunction(lastkey) = "r" or
           keyfunction(lastkey) = "t" or keyfunction(lastkey) = "y" or
           keyfunction(lastkey) = "u" or keyfunction(lastkey) = "i" or
           keyfunction(lastkey) = "o" or keyfunction(lastkey) = "p" or
           keyfunction(lastkey) = "a" or keyfunction(lastkey) = "s" or
           keyfunction(lastkey) = "d" or keyfunction(lastkey) = "f" or
           keyfunction(lastkey) = "g" or keyfunction(lastkey) = "h" or
           keyfunction(lastkey) = "j" or keyfunction(lastkey) = "k" or
           keyfunction(lastkey) = "l" or keyfunction(lastkey) = "z" or
           keyfunction(lastkey) = "x" or keyfunction(lastkey) = "c" or
           keyfunction(lastkey) = "v" or keyfunction(lastkey) = "b" or
           keyfunction(lastkey) = "n" or keyfunction(lastkey) = "m" or
           keyfunction(lastkey) = "Q" or keyfunction(lastkey) = "W" or
           keyfunction(lastkey) = "E" or keyfunction(lastkey) = "R" or
           keyfunction(lastkey) = "T" or keyfunction(lastkey) = "Y" or
           keyfunction(lastkey) = "U" or keyfunction(lastkey) = "I" or
           keyfunction(lastkey) = "O" or keyfunction(lastkey) = "P" or
           keyfunction(lastkey) = "A" or keyfunction(lastkey) = "S" or
           keyfunction(lastkey) = "D" or keyfunction(lastkey) = "F" or
           keyfunction(lastkey) = "G" or keyfunction(lastkey) = "H" or
           keyfunction(lastkey) = "J" or keyfunction(lastkey) = "K" or
           keyfunction(lastkey) = "L" or keyfunction(lastkey) = "Z" or
           keyfunction(lastkey) = "X" or keyfunction(lastkey) = "C" or
           keyfunction(lastkey) = "V" or keyfunction(lastkey) = "B" or
           keyfunction(lastkey) = "N" or keyfunction(lastkey) = "M"
        then do with centered row 8 color message
                                frame f-procura side-label overlay.
            vbusca = keyfunction(lastkey).
            pause 0.
            primeiro = yes.
            vtitpar = 0.
            update vbusca vtitpar label "Parcela"
                editing:
                    if primeiro
                    then do:
                        apply keycode("cursor-right").
                        primeiro = no.
                    end.
                readkey.
                apply lastkey.
            end.
            recatu2 = recatu1.
            recatu1 = ?.
            for each bwfselecao.
                find titulo where recid(titulo) = bwfselecao.rec no-lock.
                if titulo.titnum = vbusca
                then do:
                    if vtitpar entered
                    then if titulo.titpar = vtitpar
                         then recatu1 = recid(bwfselecao).
                         else.
                    else recatu1 = recid(bwfselecao).
                end.
            end.
            if recatu1 = ?
            then do:
                recatu1 = recatu2.
                hide message no-pause.
                message "titulo nao encontrado nesta Selecao".
            end.
            hide frame f-procura.
            leave.
        end.
        hide frame f-procura.
        {esquema.i &tabela = "wfselecao"
                   &campo  = "titulo.titnum"
                   &where  = "true"
                   &frame  = "frame-a"}
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            if esqcom1[esqpos1] = " Consulta "
            then
                hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Seleciona "
                then do on error undo.
                    find titulo where recid(titulo) = wfselecao.rec no-lock.
                        
                    assign
                        wfselecao.marcados = not wfselecao.marcados.
                    if wfselecao.marcados = no
                    then do:
                        /**find pdvdoc of pdvmov where
                                pdvdoc.contnum = string(titulo.contnum) and
                                pdvdoc.titpar  = titulo.titpar
                                  no-error.
                        if avail pdvdoc
                        then delete pdvdoc.
                        */
                    end.
                    vtot-selecionados = 0.
                    vtotdesc = 0.
                    vtotjuro  = 0.
                    for each pdvdoc of pdvmov
                                  no-lock.
                        vtotdesc = vtotdesc + pdvdoc.desconto.
                        vtotjuro = vtotjuro + pdvdoc.valor_encargo.
                    end.
                    for each bwfselecao where marcados.
                        find titulo where recid(titulo) =
                                            bwfselecao.rec no-lock.
                        /*vsaldo = titulo.titvlcob - titulo.titvlpag.*/
                        vtot-selecionados = vtot-selecionados + titulo.titvlcob.
                    end.
                    vtot-selecionados = vtot-selecionados + vtotjuro -
                                                            vtotdesc.
                    display vtot-titulos
                            vtot-selecionados
                            with frame fselecao.

                end.
/***/
                if esqcom1[esqpos1] = " Todos "
                then do on error undo.
                    vtot-selecionados = 0.
                    vtotdesc = 0.
                    vtotjuro = 0.
                    for each pdvdoc of pdvmov
                                  no-lock.
                        vtotdesc = vtotdesc + pdvdoc.desconto.
                        vtotjuro = vtotjuro + pdvdoc.valor_encargo.
                    end.
                    for each wfselecao.

                    find titulo where recid(titulo) = wfselecao.rec
                        no-lock no-error.
                    if not avail titulo
                    then next.
                    
                    find titulo where recid(titulo) = wfselecao.rec 
                        no-lock.
                    assign
                        wfselecao.marcados = yes.
                        /*vsaldo = titulo.titvlcob - titulo.titvlpag. */
                        vtot-selecionados = vtot-selecionados + titulo.titvlcob.
                    end.
                    vtot-selecionados = vtot-selecionados + vtotjuro -
                                                            vtotdesc.
                    display vtot-titulos
                            vtot-selecionados
                            with frame fselecao.
                    leave.
                end.
/***/
                
                
                if esqcom1[esqpos1] = " Liq. Parcial " or
                   esqcom1[esqpos1] = " liq. Total "
                then do on error undo.
                    if esqcom1[esqpos1] = " Liq. Total "
                    then do:
                        vcont = 0.
                        for each bwfselecao where bwfselecao.marcados = yes.
                            vcont = vcont + 1.
                            if vcont > 1
                            then leave.
                        end.
                        if vcont = 0
                        then do:
                            find titulo where recid(titulo) = wfselecao.rec
                                                    no-lock.
                            assign
                                wfselecao.marcados = yes.
                        end.
                    end.
                    clear frame frame-a all no-pause.
                    hide frame frame-a no-pause.
                    for each wfselecao where
                            wfselecao.marcados = yes.
                        find titulo where recid(titulo) =
                                        wfselecao.rec no-lock.
                        find pdvdoc of pdvmov where
                                pdvdoc.contnum = string(titulo.contnum) and
                                pdvdoc.titpar  = titulo.titpar no-lock
                                                               no-error.
                        run fin/cmdman.p (input recid(pdvmov),
                                       input if avail pdvdoc
                                             then recid(pdvdoc)
                                             else ?,
                                       input recid(titulo),
                                       input par-openat,
                                       input esqcom1[esqpos1]).
                    end.
                    return.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do:
                    run fin/bsfqtitulo.p (input wfselecao.rec).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                leave.
            end.
        end.
        find titulo where recid(titulo) = wfselecao.rec no-lock.
        find clien where clien.clicod = titulo.clifor no-lock.
/*        vsaldo = titulo.titvlcob - titulo.titvlpag.*/
        display
                wfselecao.marcados
                clien.clicod
                clien.clinom
                titulo.etbcod
                {titnum.i}
                titulo.modcod
                titulo.titdtven
                titulo.titvlcob
                with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        /*
        else display esqcom2[esqpos2] with frame f-com2.
        */
        recatu1 = recid(wfselecao).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
/*
hide frame f-com2  no-pause.
*/
hide frame frame-a no-pause.




