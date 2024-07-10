/*
*
*    banocorr.p    -    Esqueleto de Programacao    com esqvazio


            substituir    banocorr
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
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de banocorr ",
             " Alteracao da banocorr ",
             " Exclusao  da banocorr ",
             " Consulta  da banocorr ",
             " Listagem  Geral de banocorr "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{cabec.i}
def input param par-rec as recid.
 
find banco where recid(banco) = par-rec no-lock.

def buffer bbanocorr       for banocorr.


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

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        if esqascend
        then
            find first banocorr where
                                    of banco
                                        no-lock no-error.
        else
            find last banocorr where
                                    of banco
                                        no-lock no-error.
    else
        find banocorr where recid(banocorr) = recatu1 no-lock.
    if not available banocorr
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        display banocorr.ocbtipo
                banocorr.ocbcod
                banocorr.ocbnom
                banocorr.ocbbaixa
                banocorr.ocbliquida
                with frame frame-a 11 down centered row 5
                title "Ocorrencias Banco " + banco.banfan.
    end.

    recatu1 = recid(banocorr).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next banocorr where
                                    of banco
                                        no-lock.
        else
            find prev banocorr where
                                    of banco
                                        no-lock.
        if not available banocorr
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        display
                 banocorr.ocbtipo
                banocorr.ocbcod
                banocorr.ocbnom
                banocorr.ocbbaixa
                banocorr.ocbliquida
                with frame frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find banocorr where recid(banocorr) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(banocorr.ocbcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(banocorr.ocbcod)
                                        else "".
            color display message 
             banocorr.ocbtipo
                banocorr.ocbcod
                banocorr.ocbnom
                banocorr.ocbbaixa
                banocorr.ocbliquida

                                      with frame frame-a.
            choose field banocorr.ocbcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
            color display normal  
 banocorr.ocbtipo
                banocorr.ocbcod
                banocorr.ocbnom
                banocorr.ocbbaixa
                banocorr.ocbliquida

                                    with frame frame-a.

            status default "".

        end.
        {esquema.i &tabela = "banocorr"
                   &campo  = "banocorr.ocbcod"
                   &where  = "of banco"
                   &frame  = "frame-a"}

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do on error undo, retry on endkey undo, leave:
            form
                 with frame f-banocorr color black/cyan
                      centered side-label row 5 1 column.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-banocorr on error undo.
                    create banocorr.
                    assign banocorr.bancod = banco.bancod.
                    display banocorr.bancod.
                    update  banocorr.ocbtipo
                            banocorr.ocbcod
                            banocorr.ocbnom.
                    update banocorr.ocbliquida.
                    update banocorr.ocbbaixa.
                    recatu1 = recid(banocorr).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-banocorr.
                    display banocorr.ocbcod.
                    display banocorr.ocbnom.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-banocorr.
                    find banocorr where recid(banocorr) = recatu1.
                    update banocorr.ocbnom.
                    update banocorr.ocbliquida.
                    update banocorr.ocbbaixa.

                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered.
                    message "Confirma Exclusao de" banocorr.ocbcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next banocorr where of banco no-error.
                    if not available banocorr
                    then do:
                        find banocorr where recid(banocorr) = recatu1.
                        find prev banocorr where of banco no-error.
                    end.
                    recatu2 = if available banocorr
                              then recid(banocorr)
                              else ?.
                    find banocorr where recid(banocorr) = recatu1.
                    delete banocorr.
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
                    then run lbanocorr.p (input 0).
                    else run lbanocorr.p (input banocorr.ocbcod).
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
            display
 banocorr.ocbtipo
                banocorr.ocbcod
                banocorr.ocbnom
                banocorr.ocbbaixa
                banocorr.ocbliquida

                    with frame frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(banocorr).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
