/*
*
*    tt-prodatrib.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-prodatrib
                          atrib
*
*/


def input parameter p-procod                as integer.
def input parameter p-tipo-atrib            as char.

/*
def var p-procod                as integer initial 12.
def var p-tipo-atrib            as char initial "Capacidade".
*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 3
    initial [" Inclusao "," Alteracao "," Exclusao "].
def var esqcom2         as char format "x(13)" extent 3
            initial [" "," ",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-prodatrib ",
             " Alteracao da tt-prodatrib ",
             " Exclusao  da tt-prodatrib ",
             " Consulta  da tt-prodatrib ",
             " Listagem  Geral de tt-prodatrib "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i}

def temp-table tt-prodatrib like prodatrib
    field pronom   like produ.pronom
    field atribdes like atributo.atribdes
    field acao     as char.

def buffer btt-prodatrib       for tt-prodatrib.
def var vtt-prodatrib         like tt-prodatrib.atribcod.

def var vtitulo-aux as char.

pause 0.

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

run p-carrega-tt-prodatrib.

find first produ where produ.procod = p-procod
                               no-lock no-error.
                          
assign vtitulo-aux = trim(p-tipo-atrib)
                      + " do produto "
                      + trim(produ.pronom).
                           
bl-princ:
repeat:

    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-prodatrib where recid(tt-prodatrib) = recatu1 no-lock.
    if not available tt-prodatrib
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    
    if esqvazio
    then do:
    
        sresp = no.
        message "O Produto Não possui o atributo " p-tipo-atrib
                "cadastrado, deseja incluir?"    update sresp.
    
        if not sresp then leave bl-princ.

    end.
    
    display vtitulo-aux format "x(50)"
        with frame f-titulo no-box no-label row 7 centered color message.
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-prodatrib).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-prodatrib
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
            find tt-prodatrib where recid(tt-prodatrib) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-prodatrib.atribdes)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-prodatrib.atribdes)
                                        else "".
            run color-message.
            choose field tt-prodatrib.atribcod help ""
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
                    esqpos1 = if esqpos1 = 3 then 3 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
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
                    if not avail tt-prodatrib
                    then leave.
                    recatu1 = recid(tt-prodatrib).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-prodatrib
                    then leave.
                    recatu1 = recid(tt-prodatrib).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-prodatrib
                then next.
                color display white/red tt-prodatrib.atribcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-prodatrib
                then next.
                color display white/red tt-prodatrib.atribcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-prodatrib.atribcod   format ">>>>>9"
                        help "Pressione F7 e escolha um atributo"
                 tt-prodatrib.atribdes format "x(30)" no-label      skip                          tt-prodatrib.valor
                 with frame f-tt-prodatrib-i color black/cyan
                      centered side-label row 9 width 60 overlay .
                      
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-prodatrib-i on error undo.
                    create tt-prodatrib.
                    
                    assign tt-prodatrib.procod = p-procod
                           tt-prodatrib.pronom = produ.pronom.
                            
                    update tt-prodatrib.atribcod
                            validate(can-find
                                    (first atributo
                         where atributo.atribcod = tt-prodatrib.atribcod
                           and atributo.tipo = "capacidade")
                       ,"Atributo Inválido! Pressione F7 e escolha uma opção").
                    
                    find first atributo
                         where atributo.atribcod = tt-prodatrib.atribcod
                                        no-lock no-error.
                    
                    if avail atributo
                    then do:
                        assign tt-prodatrib.atribdes = atributo.atribdes.
                        
                        display tt-prodatrib.atribdes.
                        
                    end.    
                           
                    update tt-prodatrib.valor.

                    find first prodatrib
                         where prodatrib.procod = tt-prodatrib.procod
                           and prodatrib.atribcod = tt-prodatrib.atribcod
                                            exclusive-lock no-error.
                                            
                    if not avail prodatrib
                    then create prodatrib.
                    
                    buffer-copy tt-prodatrib to prodatrib.
                    
                    recatu1 = recid(tt-prodatrib).
                    leave.
                    
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-prodatrib-i.
                    disp tt-prodatrib.atribcod
                         tt-prodatrib.valor.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-prodatrib-i on error undo.
                    find tt-prodatrib where
                            recid(tt-prodatrib) = recatu1 
                        exclusive.
                    display tt-prodatrib.atribcod.    
                    update tt-prodatrib.valor.
                           
                    find first prodatrib
                         where prodatrib.procod = tt-prodatrib.procod
                           and prodatrib.atribcod = tt-prodatrib.atribcod
                                            exclusive-lock no-error.
                                            
                    if not avail prodatrib
                    then create prodatrib.
                    
                    buffer-copy tt-prodatrib to prodatrib.
                    
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-prodatrib.atribdes
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-prodatrib where true no-error.
                    if not available tt-prodatrib
                    then do:
                        find tt-prodatrib where recid(tt-prodatrib) = recatu1.
                        find prev tt-prodatrib where true no-error.
                    end.
                    recatu2 = if available tt-prodatrib
                              then recid(tt-prodatrib)
                              else ?.
                    find tt-prodatrib where recid(tt-prodatrib) = recatu1
                            exclusive.
                           
                    find first prodatrib
                         where prodatrib.procod = tt-prodatrib.procod
                           and prodatrib.atribcod = tt-prodatrib.atribcod
                                            exclusive-lock no-error.
                                            
                    if avail prodatrib
                    then delete prodatrib.
                    
                    delete tt-prodatrib.
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
                    then run ltt-prodatrib.p (input 0).
                    else run ltt-prodatrib.p (input tt-prodatrib.atribcod).
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
        recatu1 = recid(tt-prodatrib).
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
hide frame f-titulo no-pause.
procedure frame-a.
display tt-prodatrib.atribcod
        tt-prodatrib.atribdes
        tt-prodatrib.valor
        with frame frame-a 7 down centered color white/red row 9.
end procedure.
procedure color-message.
color display message
        tt-prodatrib.atribcod
        tt-prodatrib.atribdes
        tt-prodatrib.valor
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-prodatrib.atribcod
        tt-prodatrib.atribdes
        tt-prodatrib.valor
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-prodatrib where true
                                                no-lock no-error.
    else  
        find last tt-prodatrib  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-prodatrib  where true
                                                no-lock no-error.
    else  
        find prev tt-prodatrib   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-prodatrib where true  
                                        no-lock no-error.
    else   
        find next tt-prodatrib where true 
                                        no-lock no-error.
        
end procedure.
         
procedure p-carrega-tt-prodatrib:
         
    for each prodatrib where prodatrib.procod = p-procod no-lock,
        
        first atributo where atributo.atribcod = prodatrib.atribcod
                         and atributo.tipo = p-tipo-atrib no-lock,
                         
        first produ where produ.procod = prodatrib.procod
                                                no-lock.
                     
        find first tt-prodatrib
             where tt-prodatrib.atribcod = prodatrib.atribcod
               and tt-prodatrib.procod = prodatrib.procod
                                   exclusive-lock no-error.
                                        
        if not avail tt-prodatrib
        then do:
    
            create tt-prodatrib.
            buffer-copy prodatrib to tt-prodatrib.
    
            assign tt-prodatrib.atribdes = atributo.atribdes
                   tt-prodatrib.pronom   = produ.pronom.

        end.
                     
    end.                     

end procedure.
         
         
         
