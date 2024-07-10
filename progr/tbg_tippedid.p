/* Projeto Melhorias Mix - Luciano       */
/* tbg_tippedid.p                                */
/* tabela generica que contem o tipo de pedido e prioridades */

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
   initial [" Alteracao ",
            " ",
            " ",
            " ",
            " "].

def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}

def temp-table prio like tbgenerica
    field rec as recid
    index tgint tgint.

def buffer bprio       for prio.

run cria.

procedure cria.
    for each prio.
        delete prio.
    end.
    recatu1 = ?.
    def var t as int.
    t = 0.
    for each tbgenerica where tbgenerica.TGTabela = "TP_PEDID" NO-LOCK by 
                                                tbgenerica.tgint.
/*        if tbgenerica.TGCodigo = "PEDP" then next.*/
        create prio.                                       
        buffer-copy tbgenerica to prio.
        t = t + 1.
        prio.tgint = t.
        prio.rec = recid(tbgenerica).
    end.
end procedure.


form
 prio.TGCodigo
        tbgenerica.tgdescricao
        prio.tgint  column-label "Prioridade" 
        tbgenerica.tglog column-label "Gera Pendente" format "Sim/Nao"
        tbgenerica.tgint column-label "Prioridade!Interna"
        with frame frame-a 11 down centered color white/red row 5.


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
        find prio where recid(prio) = recatu1 no-lock.
    if not available prio
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(prio).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prio
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
            find prio where recid(prio) = recatu1 no-lock.
            find tbgenerica where recid(tbgenerica) = prio.rec no-lock.
            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prio.tgcodigo)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prio.tgcodigo)
                                        else "".
            run color-message.
            choose field prio.tgcodigo help ""
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
                    if not avail prio
                    then leave.
                    recatu1 = recid(prio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prio
                    then leave.
                    recatu1 = recid(prio).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prio
                then next.
                color display white/red prio.tgcodigo with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prio
                then next.
                color display white/red prio.tgcodigo with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prio
                 with frame f-prio color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame frame-b on error undo.
                    create tbgenerica.
                    tbgenerica.TGTabela = "TP_PEDID".
                    update tbgenerica.tgcodigo
                           tbgenerica.tgdescricao 
                           tbgenerica.tgint. 
                    run cria.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tbgenerica.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame frame-a on error undo.
                    find prio where
                            recid(prio) = recatu1 
                        exclusive.
                  find tbgenerica where recid(tbgenerica) = prio.rec.
                  update 
                           tbgenerica.tglog when tbgenerica.TGCodigo <> "PEDX"
                           tbgenerica.tgint
                           .                 
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
        recatu1 = recid(prio).
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

procedure  frame-a.
find tbgenerica where recid(tbgenerica) = prio.rec no-lock.
display prio.TGCodigo
        tbgenerica.tgdescricao
        prio.tgint  
        tbgenerica.tglog 
        tbgenerica.tgint
        with frame frame-a.
end procedure.
procedure color-message.
color display message
        prio.tgcodigo
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        prio.tgcodigo
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prio where prio.TGTabela = "TP_PEDID"
                                                no-lock no-error.
    else  
        find last prio  where prio.TGTabela = "TP_PEDID"
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prio  where prio.TGTabela = "TP_PEDID"
                                                no-lock no-error.
    else  
        find prev prio   where prio.TGTabela = "TP_PEDID"
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prio where prio.TGTabela = "TP_PEDID"  
                                        no-lock no-error.
    else   
        find next prio where prio.TGTabela = "TP_PEDID" 
                                        no-lock no-error.
        
end procedure.
         
