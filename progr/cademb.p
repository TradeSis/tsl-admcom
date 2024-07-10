{admcab.i}

def buffer bprodu for produ.

def var vprocod like embalagem.procod.
def var vembcod like embalagem.embcod.
def var vembqtd like embalagem.embqtd.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Exclusao "," Consulta "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de Embalagem ",
             " Alteracao de Embalagem ",
             " Exclusao  de Embalagem ",
             " Consulta  de Embalagem ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer bembalagem       for  embalagem.
def var    vembalagem       like embalagem.procod.


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
        find embalagem where recid(embalagem) = recatu1 no-lock.
    
    if not available embalagem
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(embalagem).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available embalagem
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
            find embalagem where recid(embalagem) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(embalagem.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(embalagem.procod)
                                        else "".
            run color-message.
    
            choose field embalagem.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

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
                    if not avail embalagem
                    then leave.
                    recatu1 = recid(embalagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail embalagem
                    then leave.
                    recatu1 = recid(embalagem).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail embalagem
                then next.
                color display white/red embalagem.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail embalagem
                then next.
                color display white/red embalagem.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form embalagem
                 with frame f-embalagem color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-embalagem on error undo.

                    run p-inclusao.
                    
                    recatu1 = recid(embalagem).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " 
                then do:

                    find produ where
                         produ.procod = embalagem.procod no-lock no-error.
                    
                    for each embalagem where 
                             embalagem.procod = produ.procod no-lock:
                             
                        display 
                          embalagem.procod column-label "Produto"
                          produ.pronom  column-label "Descricao"
                            when avail produ
                          embalagem.embcod format "x(13)"
                                column-label "Embalagem"
                        embalagem.embqtd format ">>>9" column-label "Qtd.!Emb."
                        with frame f-consulta 6 down centered row 7.
                    end.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-embalagem on error undo.
                    /*
                     find embalagem where
                            recid(embalagem) = recatu1 
                        exclusive.
                    update embalagem.
                    */
                    run p-alteracao.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do:
                    find produ where
                         produ.procod = embalagem.procod no-lock no-error.
                    
                    display embalagem.procod column-label "Produto"
                        produ.pronom    column-label "Descricao"
                            when avail produ
                        embalagem.embcod format "x(13)"
                                column-label "Embalagem"
                        embalagem.embqtd format ">>>9" column-label "Qtd.!Emb."
                        with frame f-exclui 1 down centered row 8.
                               
                    message "Confirma Exclusao deste registro? "
                            update sresp.
                    hide frame f-exclui no-pause.
                    
                    if not sresp
                    then undo, leave.
                    find next embalagem where true no-error.
                    if not available embalagem
                    then do:
                        find embalagem where recid(embalagem) = recatu1.
                        find prev embalagem where true no-error.
                    end.
                    recatu2 = if available embalagem
                              then recid(embalagem)
                              else ?.
                    find embalagem where recid(embalagem) = recatu1
                            exclusive.
                    delete embalagem.
                    recatu1 = recatu2.
                    leave.
                end.
                /*if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run lembalagem.p (input 0).
                    else run lembalagem.p (input embalagem.procod).
                    leave.
                end.*/
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
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
        recatu1 = recid(embalagem).
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
    find produ where produ.procod = embalagem.procod no-lock no-error.
    
    display embalagem.procod                       column-label "Produto"
            produ.pronom       column-label "Descricao"
                when avail produ
            embalagem.embcod    format "x(13)"  column-label "Embalagem"
            embalagem.embqtd    format ">>>9"      column-label "Qtd.!Emb."
            with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    find produ where produ.procod = embalagem.procod no-lock no-error.
 
    color display message
            embalagem.procod
            produ.pronom
                when avail produ
            embalagem.embcod
            embalagem.embqtd
            with frame frame-a.
end procedure.

procedure color-normal.
    find produ where produ.procod = embalagem.procod no-lock no-error.
 
    color display normal
            embalagem.procod
            produ.pronom
                when avail produ
            embalagem.embcod
            embalagem.embqtd
            with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first embalagem where true no-lock no-error.
    else  
        find last embalagem  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then   
        find next embalagem  where true no-lock no-error.
    else  
        find prev embalagem   where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev embalagem where true no-lock no-error.
    else   
        find next embalagem where true no-lock no-error.
        
end procedure.

procedure p-inclusao:
    assign vprocod = 0 vembcod = "" vembqtd = 0.
    
    do on error undo:         
        update vprocod label "Produto..."
               with frame f-inc side-labels centered row 6.
               
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao cadastrado.".
            undo, retry.
        end.
        else disp produ.pronom no-label with frame f-inc.
    end.
    
    do on error undo:         
        update vembcod label "Embalagem."
               with frame f-inc side-labels centered row 6.
        if vembcod = ""
        then do:
            message "Informe o Codigo da Embalagem.".
            undo, retry.
        end.
    end.
    
    find embalagem where embalagem.procod = vprocod 
                     and embalagem.embcod = vembcod no-error. 
    if avail embalagem 
    then do: 
        message "Embalagem ja cadastrado". 
        undo, retry. 
    end.
 
    do on error undo:

        update vembqtd label "Quantidade"
               with frame f-inc.
        if vembqtd = 0
        then do:
            message "Quantidade Invalida.".
            undo, retry.
        end.
        
    end.
    
    if vprocod <> 0 and vembcod <> "" and vembqtd <> 0
    then do:
        find embalagem where embalagem.procod = vprocod
                         and embalagem.embcod = vembcod no-error.
        if not avail embalagem
        then do:
            create embalagem.
            assign embalagem.procod = vprocod
                   embalagem.embcod = vembcod
                   embalagem.embqtd = vembqtd.
        end.
        else do:
            message "embalagem ja cadastrado".
            undo, retry.
        end.
    end.
end procedure.
