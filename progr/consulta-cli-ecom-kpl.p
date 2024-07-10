/*

*
*    tt-cliecom.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-cliecom
                          cli
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
    initial [" "," Integrar "," ","  "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-cliecom ",
             " Alteracao da tt-cliecom ",
             " Exclusao  da tt-cliecom ",
             " Consulta  da tt-cliecom ",
             " Listagem  Geral de tt-cliecom "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def temp-table tt-cliecom like cliecom.

def new shared temp-table tt-clien like cliecom
    field tppes     as char
    field protocolo as char
    index idx01 is primary unique cpfcgc.

def buffer btt-cliecom       for tt-cliecom.
def var vtt-cliecom         like tt-cliecom.clicod.

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

message "Aguarde enquanto a lista de clientes é carregada".

pause 0.

run p-carrega-tt-cliecom.

hide message.

pause 0.

if not can-find (first tt-cliecom)
then do:

    sresp = no.
    message "Nenhum cliente foi encontrado, Deseja realizar a Busca do Abacos?"
                update sresp.
                
    if sresp then run p-busca-clientes.                

end.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-cliecom where recid(tt-cliecom) = recatu1 no-lock.
    if not available tt-cliecom
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-cliecom).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-cliecom
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
            find tt-cliecom where recid(tt-cliecom) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-cliecom.clinom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-cliecom.clinom)
                                        else "".
            run color-message.
            choose field tt-cliecom.clicod help ""
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
                    if not avail tt-cliecom
                    then leave.
                    recatu1 = recid(tt-cliecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cliecom
                    then leave.
                    recatu1 = recid(tt-cliecom).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cliecom
                then next.
                color display white/red tt-cliecom.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cliecom
                then next.
                color display white/red tt-cliecom.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-cliecom
                 with frame f-tt-cliecom color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-cliecom on error undo.
                    create tt-cliecom.
                    update tt-cliecom.
                    recatu1 = recid(tt-cliecom).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-cliecom.
                    disp tt-cliecom.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-cliecom on error undo.
                    find tt-cliecom where
                            recid(tt-cliecom) = recatu1 
                        exclusive.
                    update tt-cliecom.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-cliecom.clinom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-cliecom where true no-error.
                    if not available tt-cliecom
                    then do:
                        find tt-cliecom where recid(tt-cliecom) = recatu1.
                        find prev tt-cliecom where true no-error.
                    end.
                    recatu2 = if available tt-cliecom
                              then recid(tt-cliecom)
                              else ?.
                    find tt-cliecom where recid(tt-cliecom) = recatu1
                            exclusive.
                    delete tt-cliecom.
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
                    then run ltt-cliecom.p (input 0).
                    else run ltt-cliecom.p (input tt-cliecom.clicod).
                    leave.
                end.
                if esqcom1[esqpos1] = " Integrar "
                then do with frame f-integrar:

                    hide message.

                    sresp = no.
                    message "Deseja buscar novos Clientes no Abacos?"
                    update sresp.
                    
                    if sresp
                    then run p-busca-clientes. 
                    
                    leave.
                    
                end.
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
        recatu1 = recid(tt-cliecom).
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
display tt-cliecom.clicod
        tt-cliecom.clinom
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-cliecom.clicod
        tt-cliecom.clinom
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-cliecom.clicod
        tt-cliecom.clinom
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-cliecom where true
                                                no-lock no-error.
    else  
        find last tt-cliecom  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-cliecom  where true
                                                no-lock no-error.
    else  
        find prev tt-cliecom   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-cliecom where true  
                                        no-lock no-error.
    else   
        find next tt-cliecom where true 
                                        no-lock no-error.
        
end procedure.
         
procedure p-carrega-tt-cliecom:
         
    for each cliecom no-lock:

        find first clien where clien.clicod = cliecom.clicod no-lock no-error.
        
        find first cpclien of clien no-lock no-error.
                                             
        if not avail cpclien or acha("ProtocoloCliFor",cpclien.var-char12) = ?
        then next.
              
        find first tt-cliecom where tt-cliecom.clicod = cliecom.clicod
                                    no-lock no-error.
                        
        if not avail tt-cliecom
        then do:
         
            create tt-cliecom.
            buffer-copy cliecom to tt-cliecom.
            
        end.
         
    end.     
         
end procedure.
         
procedure p-busca-clientes:
         
    run /admcom/web/progr_e/busca_clifor_disp.p.         
         
    message "Integração Concluída!" skip
            "Aguarde nova busca no cadastro" view-as alert-box.

    pause 0.
    
    run p-carrega-tt-cliecom.
    

end procedure.