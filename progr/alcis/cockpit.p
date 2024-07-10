/*
*
*    ttarq.p    -    Esqueleto de Programacao    com esqvazio


            substituir    ttarq
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
    initial [" Acao "," Consulta ","  "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.
{admcab.i}

{alcis/tpalcis.i}

def temp-table ttarq
    field Arquivo   as char format "x(25)"
    field tm        like tipo-alcis.tm format "x(45)" label "Tipo".

def buffer bttarq       for ttarq.
def var vttarq         like ttarq.Arquivo.


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

run diretorio.    

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttarq where recid(ttarq) = recatu1 no-lock.
    if not available ttarq
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(ttarq).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttarq
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
            find ttarq where recid(ttarq) = recatu1 no-lock.

            esqcom1[1] = " ".
            esqcom1[2] = " ".
            find tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) 
                            no-error.
            if avail tipo-alcis and search(tipo-alcis.acao) <> ?
            then esqcom1[1] = " Acao ".
            if avail tipo-alcis and search(tipo-alcis.consulta) <> ?
            then esqcom1[1] = " Consulta ".
            
            display esqcom1
                    with frame f-com1.            
            
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttarq.Arquivo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttarq.Arquivo)
                                        else "".
            run color-message.
            choose field ttarq.Arquivo 
                help "Refresh de 10 segundos"
                pause 10
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            pause 0. 
            if lastkey = -1 
            then do:  
                hide frame frame-a no-pause.
                run diretorio.
                
                recatu1 = ?.
                next bl-princ. 
            end.
                                                                
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
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttarq
                    then leave.
                    recatu1 = recid(ttarq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttarq
                then next.
                color display white/red ttarq.Arquivo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttarq
                 with frame f-ttarq color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[1] = " Acao "
                then do.
                    run value(tipo-alcis.acao) (ttarq.arquivo).
                end.
                if esqcom1[1] = " Consulta "
                then do.
                    run value(tipo-alcis.consulta) (ttarq.arquivo).
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
        recatu1 = recid(ttarq).
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
display ttarq 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        ttarq.Arquivo
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        ttarq.Arquivo
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first ttarq where true
                                                no-lock no-error.
    else  
        find last ttarq  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next ttarq  where true
                                                no-lock no-error.
    else  
        find prev ttarq   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev ttarq where true  
                                        no-lock no-error.
    else   
        find next ttarq where true 
                                        no-lock no-error.
        
end procedure.
         



procedure diretorio.

unix silent value(
"ls " + alcis-diretorio + " > le.le.le.alcis ; chmod 777 le.le.le.alcis").
for each ttarq.
    delete ttarq.
end.
input from ./le.le.le.alcis.
repeat transaction.
    create ttarq.
    import ttarq.
    find tipo-alcis where tipo-alcis.tp = substr(ttarq.arquivo,1,4) no-error.
    if not avail tipo-alcis
    then ttarq.tm = "*** Arquivo fora do padrao ***".
    else ttarq.tm = tipo-alcis.tm.
end.
input close.
find first ttarq no-error.
if not avail ttarq
then  do.
    create ttarq.
    assign ttarq.arquivo = "Nenhum Arquivo".
end.


end procedure.
