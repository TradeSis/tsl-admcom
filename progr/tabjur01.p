/*
*
*    tabjur.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vetbcod like estab.etbcod.
def var vetbcod1 like estab.etbcod.
def var c-etbcod like estab.etbcod.
def buffer bestab for estab.
def buffer cestab for estab.
def buffer btabjur for tabjur.
def buffer ctabjur for tabjur.

def temp-table tt-estab
    field etbcod like estab.etbcod.

update vetbcod label "Filial"
    with frame f-cb side-label width 80 no-box.
if vetbcod > 0
then do:
    find bestab where bestab.etbcod = vetbcod no-lock no-error.
    disp bestab.etbnom no-label when avail bestab
         with frame f-cb.
end.
pause 0.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def var esqcom1         as char format "x(14)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem"].
def var esqcom2         as char format "x(14)" extent 5
    initial [""," Envia Filial "," Clonar ","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tabjur ",
             " Alteracao da tabjur ",
             " Exclusao  da tabjur ",
             " Consulta  da tabjur ",
             " Listagem  Geral de tabjur "].
def var esqhel2         as char format "x(12)" extent 5.

form
    esqcom1
    with frame f-com1 row 4 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tabjur where recid(tabjur) = recatu1 no-lock.
    if not available tabjur
    then do.
        if keyfunction(lastkey) = "END-ERROR"
        THEN leave bl-princ.
        
        sresp = no.
        run mensagem.p(input-output sresp,
           input "!Tabela de juros para filial" + string(vetbcod) +
                 "não encontrada." +
                 "!Deseja copiar de outra filial?",
                    input " Atenção ",
                    input "   SIM",
                    input "   NAO").
        if sresp
        then do:
            update vetbcod1 label "Filial copiar"
                with frame f-cp 1 down
                side-label row 19 centered.
            for each tabjur where tabjur.etbcod = vetbcod1 no-lock:
                create btabjur.
                assign
                    btabjur.etbcod = vetbcod
                    btabjur.nrdias = tabjur.nrdias
                    btabjur.fator  = tabjur.fator.
            end.
            next bl-princ.        
        end.     

        esqvazio = yes.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(tabjur).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tabjur
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find tabjur where recid(tabjur) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tabjur.fator)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tabjur.fator)
                                        else "".
            run color-message.
            choose field tabjur.nrdias help ""
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
                    if not avail tabjur
                    then leave.
                    recatu1 = recid(tabjur).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tabjur
                    then leave.
                    recatu1 = recid(tabjur).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tabjur
                then next.
                color display white/red tabjur.nrdias with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tabjur
                then next.
                color display white/red tabjur.nrdias with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tabjur
                 with frame f-tabjur color black/cyan
                      centered side-label row 5 1 col.
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tabjur on error undo.
                    create tabjur.
                    tabjur.etbcod = vetbcod.
                    disp tabjur.etbcod format ">>>9".
                    update tabjur.nrdias
                           tabjur.fator.
                    recatu1 = recid(tabjur).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao "
                then do with frame f-tabjur.
                    disp tabjur.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find tabjur where recid(tabjur) = recatu1 exclusive.
                    update tabjur.nrdias
                           tabjur.fator.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tabjur.fator "?"
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tabjur where tabjur.etbcod = vetbcod
                              no-lock no-error.
                    if not available tabjur
                    then do:
                        find tabjur where recid(tabjur) = recatu1 no-lock.
                        find prev tabjur where tabjur.etbcod = vetbcod
                                  no-lock no-error.
                    end.
                    recatu2 = if available tabjur
                              then recid(tabjur)
                              else ?.
                    find tabjur where recid(tabjur) = recatu1 exclusive.
                    delete tabjur.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    message "Confirma Impressao - Tab. de juros?" update sresp.
                    if not sresp
                    then leave.
                    recatu2 = recatu1.
                    output to printer.
                    for each tabjur where tabjur.etbcod = vetbcod no-lock:
                        display tabjur.
                    end.
                    output close.
                    recatu1 = recatu2.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.

                if esqcom2[esqpos2] = " Envia Filial "
                then do:
                    sresp = no.
                    run mensagem.p(input-output sresp,
                        input "!Confirma evio da Tabela de Juros " +
                              "!para Filial " + string(vetbcod),
                        input " Confirmação ",
                        input "   SIM",
                        input "   NAO").
                    if sresp
                    then do:
                        run envia-filial.
                    end.                
                end.
                if esqcom2[esqpos2] = " Clonar "
                then do:
                    for each tt-estab: delete tt-estab. end.
                    repeat:
                        c-etbcod = 0.
                        update c-etbcod label "Filial"
                            with frame f-clone centered row 7 
                                10 down overlay .
                        find cestab where cestab.etbcod = c-etbcod no-lock.
                        disp cestab.etbnom no-label with frame f-clone.
                        down with frame f-clone.
                    
                        create tt-estab.
                        tt-estab.etbcod = c-etbcod.
                    end.
                    find first tt-estab where tt-estab.etbcod > 0 no-error.  
                    if not avail tt-estab
                    then next.

                    sresp = no.
                    message "Confirma clonar de" + string(vetbcod) + "?"
                            update sresp.
                    if sresp
                    then
                        for each tt-estab where tt-estab.etbcod > 0 no-lock.
                            for each btabjur where btabjur.etbcod = vetbcod
                                     no-lock:
                                find first ctabjur where
                                           ctabjur.etbcod = tt-estab.etbcod and
                                           ctabjur.nrdias = btabjur.nrdias
                                           no-error.
                                if not avail ctabjur
                                then do:
                                    create ctabjur.
                                    assign
                                        ctabjur.etbcod = tt-estab.etbcod
                                        ctabjur.nrdias = btabjur.nrdias.
                                end.
                                assign
                                    ctabjur.fator = btabjur.fator
                                    ctabjur.percentual = btabjur.percentual
                                    ctabjur.datexp = today
                                    ctabjur.exportar = no.
                            end.
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
        recatu1 = recid(tabjur).
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
    display
        tabjur.etbcod format ">>>9"
        tabjur.nrdias
        tabjur.fator
        with frame frame-a 11 down centered color white/red row 5.
end procedure.


procedure color-message.
color display message
        tabjur.nrdias
        with frame frame-a.
end procedure.


procedure color-normal.
color display normal
        tabjur.nrdias
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  find first tabjur where tabjur.etbcod = vetbcod no-lock no-error.
    else  find last tabjur  where tabjur.etbcod = vetbcod no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  find next tabjur  where tabjur.etbcod = vetbcod no-lock no-error.
    else  find prev tabjur  where tabjur.etbcod = vetbcod no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then  find prev tabjur where tabjur.etbcod = vetbcod  no-lock no-error.
    else  find next tabjur where tabjur.etbcod = vetbcod  no-lock no-error.
        
end procedure.


procedure envia-filial:
    def var v-ip as char.
    v-ip = "filial" + string(vetbcod,"999").
    
    if connected ("finloja")
    then disconnect finloja.
    
    message "Conectando Filial " vetbcod " IP= " v-ip.
    connect fin -H value(v-ip) -S sdrebfin -N tcp -ld finloja no-error.
    
    if not connected ("finloja")
    then message "Banco nao conectado" view-as alert-box.
    else do:
        message "Conectado".
        run atu-tabela-juros-filial.p (vetbcod).
        disconnect finloja.
    end.
    hide message no-pause.

end procedure.

