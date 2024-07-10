/*
*
*    solmov.p    -    Esqueleto de Programacao    com esqvazio


            substituir    solmov
                          <tab>
*
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [ " Consulta ", " Inclusao "," Alteracao "," Exclusao ", " "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Movimento ",
             " Alteracao doMovimento ",
             " Exclusao  doMovimento ",
             " Consulta  doMovimento ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
def new global shared var sfuncod   as int.
def var sresp   as log format "Sim/Nao".
def buffer bsolmov       for solmov.
def var vsolmov         like solmov.servcod.
def var vhrmov          as char format "x(5)".
def input parameter par-rec as recid.
def var i as int.
def var vast    as char.
find segur where segur.cntcod = 9999      and
                 segur.usucod = sfuncod       no-lock no-error.

if not avail segur 
then esqcom1 = "".
esqcom1[1] = " Consulta ".

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

find suporte.solic where recid(solic) = par-rec no-lock.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first solmov where
                                    of solic
                                        no-lock no-error.
        else
            find last solmov where
                                    of solic
                                        no-lock no-error.
    else
        find solmov where recid(solmov) = recatu1 no-lock.
    if not available solmov
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        vast = "".
        do i = 2 to 10:
            if solmov.descricao[i] <> ""
            then
                vast = "+".
        end.
        display
            solmov.dtmov
            string(solmov.hrmov,"HH:MM") @ vhrmov column-label "Hora"
            solmov.descricao[1]         column-label "Descricao"
            vast                    no-label format "x"
                with frame frame-a 11 down centered color white/red row 5.
    end.
    else
        if not avail segur
        then do:
            message "Nenhum Registro de Acompanhamento".
            pause .
            return.
        end.
        else
            if solic.dtfim <> ?
            then do:
                message "Nenhum Registro de Acompanhamento".
                pause .
                return.
            end.

    recatu1 = recid(solmov).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next solmov where
                                    of solic
                                        no-lock.
        else
            find prev solmov where
                                    of solic
                                        no-lock.
        if not available solmov
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        vast = "".
        do i = 2 to 10:
            if solmov.descricao[i] <> ""
            then
                vast = "+".
        end.
        display
            solmov.dtmov
            string(solmov.hrmov,"HH:MM") @ vhrmov
            solmov.descricao[1]
            vast
                with frame frame-a title " Acompanhamento da Solicitacao " +
                                    string(solic.servcod) + " ".
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find solmov where recid(solmov) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(solmov.servcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(solmov.servcod)
                                        else "".

            choose field solmov.dtmov help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.

            status default "".

        end.
        {esquema.i &tabela = "solmov"
                   &campo  = "solmov.dtmov"
                   &where  = "of solic"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form solmov.servcod colon 15
                 solmov.dtmov   colon 15
                 vhrmov   no-label
                 solmov.descricao[01]    colon 15 label "Descricao"
                 solmov.descricao[02]    colon 15 label ""
                 solmov.descricao[03]    colon 15 label ""
                 solmov.descricao[04]    colon 15 label ""
                 solmov.descricao[05]    colon 15 label ""
                 solmov.descricao[06]    colon 15 label ""
                 solmov.descricao[07]    colon 15 label ""
                 solmov.descricao[08]    colon 15 label ""
                 solmov.descricao[09]    colon 15 label ""
                 solmov.descricao[10]    colon 15 label ""
                 with frame f-solmov color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                pause 0.
                if (esqcom1[esqpos1] = " Inclusao " or esqvazio) and
                    (avail segur)
                then do with frame f-solmov on error undo.
                    create solmov.
                    assign solmov.servcod = solic.servcod
                           solmov.cliente = solic.cliente
                           solmov.dtmov   = today
                           solmov.hrmov   = time.
                    display solmov.servcod
                            solmov.dtmov
                            string(solmov.hrmov,"HH:MM") @ vhrmov.
                    update text(solmov.descricao).
                    solmov.descricao[01] = caps(solmov.descricao[01]).
                    solmov.descricao[02] = caps(solmov.descricao[02]).
                    solmov.descricao[03] = caps(solmov.descricao[03]).
                    solmov.descricao[04] = caps(solmov.descricao[04]).
                    solmov.descricao[05] = caps(solmov.descricao[05]).
                    solmov.descricao[06] = caps(solmov.descricao[06]).
                    solmov.descricao[07] = caps(solmov.descricao[07]).
                    solmov.descricao[08] = caps(solmov.descricao[08]).
                    solmov.descricao[09] = caps(solmov.descricao[09]).
                    solmov.descricao[10] = caps(solmov.descricao[10]).
                    recatu1 = recid(solmov).
                    leave.
                end.
                pause 0.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-solmov.
                    display solmov.servcod
                            solmov.dtmov
                            string(solmov.hrmov,"HH:MM") @ vhrmov
                            solmov.descricao.
                end.
                if esqcom1[esqpos1] = " Alteracao " and
                    (avail segur) and
                  solic.dtfim = ?
                then do with frame f-solmov.
                    find solmov where recid(solmov) = recatu1.
                    update text(solmov.descricao).
                    solmov.descricao[01] = caps(solmov.descricao[01]).
                    solmov.descricao[02] = caps(solmov.descricao[02]).
                    solmov.descricao[03] = caps(solmov.descricao[03]).
                    solmov.descricao[04] = caps(solmov.descricao[04]).
                    solmov.descricao[05] = caps(solmov.descricao[05]).
                    solmov.descricao[06] = caps(solmov.descricao[06]).
                    solmov.descricao[07] = caps(solmov.descricao[07]).
                    solmov.descricao[08] = caps(solmov.descricao[08]).
                    solmov.descricao[09] = caps(solmov.descricao[09]).
                    solmov.descricao[10] = caps(solmov.descricao[10]).
                end.
                if esqcom1[esqpos1] = " Exclusao " and
                    (avail segur)   and
                  solic.dtfim = ?
                then do with frame f-exclui  row 5 1 column centered.
                    find solmov where recid(solmov) = recatu1.
                    message "Confirma Exclusao de" solmov.servcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next solmov where of solic no-error.
                    if not available solmov
                    then do:
                        find solmov where recid(solmov) = recatu1.
                        find prev solmov where of solic no-error.
                    end.
                    recatu2 = if available solmov
                              then recid(solmov)
                              else ?.
                    find solmov where recid(solmov) = recatu1.
                    delete solmov.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            vast = "".
            do i = 2 to 10:
                if solmov.descricao[i] <> ""
                then
                    vast = "+".
            end.
            display
                solmov.dtmov
                string(solmov.hrmov,"HH:MM") @ vhrmov
                solmov.descricao[1]
                vast
                    with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(solmov).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        /*
        view frame fc1.
        view frame fc2.
        */
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.
hide frame f-solmov no-pause.
pause 0.
