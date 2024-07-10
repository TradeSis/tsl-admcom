/*
*
*    banCarteira.p    -    Esqueleto de Programacao    com esqvazio


            substituir    banCarteira
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
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de",
             " Alteracao do",
             " Exclusao  do",
             " Consulta  do",
             " "].
def var esqhel2         as char format "x(12)" extent 5
    initial [" Historico Cart. ",
            " ",
            " ",
            " ",
            " "].

{cabec.i}

def buffer bbanCarteira       for banCarteira.

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

def input param par-rec as recid.

find banco where recid(banco) = par-rec no-lock.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first banCarteira where
                                    of banco
                                        no-lock no-error.
        else
            find last banCarteira where
                                    of banco
                                        no-lock no-error.
    else
        find banCarteira where recid(banCarteira) = recatu1 no-lock.
    if not available banCarteira
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        display
                banCarteira.agencia
                banCarteira.contacor
                bancarteira.bancart
                bancarteira.nossonumeroatual
                with frame frame-a 5 down centered row 6
                        title " Carteiras de Cobranca no Banco " +
                                        banco.banfan + " ".
    end.

    recatu1 = recid(banCarteira).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next banCarteira where
                                    of banco
                                        no-lock.
        else
            find prev banCarteira where
                                    of banco
                                        no-lock.
        if not available banCarteira
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
                banCarteira.agencia
                banCarteira.contacor
                bancarteira.bancart
                bancarteira.nossonumeroatual

                with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find banCarteira where recid(banCarteira) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(banCarteira.agencia)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(banCarteira.agencia)
                                        else "".

            choose field banCarteira.agencia help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
        {esquema.i &tabela = "banCarteira"
                   &campo  = "banCarteira.agencia"
                   &where  = "of banco"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form
                 with frame f-banCarteira color black/cyan
                      centered side-label row 6 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-banCarteira on error undo.
                    create banCarteira.
                    assign banCarteira.bancod = banco.bancod.
                    find banco of banCarteira no-lock.
                    display banCarteira.bancod colon 20
                            banco.banfan no-label.
                    update  bancarteira.agencia
                            bancarteira.contacor.
                    update  bancarteira.bancart.
                    update  bancarteira.nossonumeroatual
                    recatu1 = recid(banCarteira).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-banCarteira.
                    find banco of banCarteira no-lock.
                    display banCarteira.bancod
                            banco.banfan.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-banCarteira.
                    find banCarteira where recid(banCarteira) = recatu1.
                    find banco of banCarteira no-lock.
                    display banCarteira.bancod
                            banco.banfan.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered.
                    message "Confirma Exclusao de" banCarteira.agencia
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next banCarteira where of banco no-error.
                    if not available banCarteira
                    then do:
                        find banCarteira where recid(banCarteira) = recatu1.
                        find prev banCarteira where of banco no-error.
                    end.
                    recatu2 = if available banCarteira
                              then recid(banCarteira)
                              else ?.
                    find banCarteira where recid(banCarteira) = recatu1.
                    delete banCarteira.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lbanCarteira.p (input 0).
                    else run lbanCarteira.p (input banCarteira.agencia).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = " Historico "
                then do with frame f-teste:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run banhcar.p (input recid(banCarteira)).
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            display
                banCarteira.agencia
                banCarteira.contacor
                bancarteira.bancart
                bancarteira.nossonumeroatual

                    with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(banCarteira).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
