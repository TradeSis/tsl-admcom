/*
* Projeto Juros Cartoes
*    moeband.p    -    Esqueleto de Programacao    com esqvazio
*
* 22.02.2018 Helio - Ajuste para opcao Exclusao registro bandeira
*
*/
{admcab.i}

def var vmatataxa as log.
def buffer bmoeband for moeband.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Taxas "," Consulta "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" Exclusao "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de moeband ",
             " Alteracao da moeband ",
             " Exclusao  da moeband ",
             " Consulta  da moeband ",
             " "].
def var esqhel2         as char format "x(12)" extent 5.

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
        run leitura (input "pri").
    else
        find moeband where recid(moeband) = recatu1 no-lock.
    if not available moeband
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(moeband).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available moeband
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find moeband where recid(moeband) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(moeband.mebcod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(moeband.mebcod)
                                        else "".
            run color-message.
            choose field moeband.mevcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail moeband
                    then leave.
                    recatu1 = recid(moeband).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail moeband
                    then leave.
                    recatu1 = recid(moeband).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail moeband
                then next.
                color display white/red moeband.mevcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail moeband
                then next.
                color display white/red moeband.mevcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form moeband
                 with frame f-moeband color black/cyan
                      centered side-label row 5 with 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-moeband on error undo.
                    create moeband.
                    update moeband.
                    recatu1 = recid(moeband).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Situacao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-moeband.
                    disp moeband.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-moeband on error undo.
                    find moeband where recid(moeband) = recatu1 exclusive.
                    update moeband except mevcod.
                end.
                if esqcom1[esqpos1] = " Taxas "
                then do.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    hide frame frame-a no-pause.
                    run moetaxa.p (moeband.moecod).
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
                    then run lmoeband.p (input 0).
                    else run lmoeband.p (input moeband.mevcod).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Exclusao "
                then do on error undo:
                
                    find current moeband exclusive.
                    vmatataxa = yes.
                    find moeda of moeband no-lock.
                    find first moetaxa of moeda no-lock no-error.
                    if avail moetaxa
                    then do:
                        find first bmoeband where
                            bmoeband.moecod = moeband.moecod and
                            recid(bmoeband) <> recid(moeband)
                            no-lock no-error.
                        if avail bmoeband
                        then vmatataxa = no.
                    end.
                    
                    message "Confirma Exclusao?" update sresp.
                    if sresp
                    then do:
                        if vmatataxa = yes
                        then do:
                            find moeda of moeband no-lock.
                            for each moetaxa of moeda.
                                delete moetaxa.
                            end.
                        end.
                        delete moeband.    
                        hide message no-pause.
                        recatu1 = ?.
                    end.
                    
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(moeband).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.


procedure frame-a.
display moeband 
        with frame frame-a 11 down centered color white/red row 5.
find moeda of moeband no-lock no-error.
disp moeda.moenom when avail moeda
    with frame frame-a.
end procedure.


procedure color-message.
color display message
        moeband.mevcod
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        moeband.mevcod
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first moeband where true
                                                no-lock no-error.
    else  
        find last moeband  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next moeband  where true
                                                no-lock no-error.
    else  
        find prev moeband   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev moeband where true  
                                        no-lock no-error.
    else   
        find next moeband where true 
                                        no-lock no-error.
        
end procedure.
         
