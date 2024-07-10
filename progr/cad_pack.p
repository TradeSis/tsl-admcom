/*
*
*    pack.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def input parameter par-rec as recid.
def input parameter par-ope as char.

find produpai where recid(produpai) = par-rec no-lock.
disp
    produpai.itecod
    produpai.pronom no-label
    with frame f-pai row 4 side-label no-box.

form
    packprod.procod
    produ.pronom column-label "Descricao" format "x(12)"
    produ.protam format "x(3)"
    produ.corcod
    cor.cornom no-label format "x(6)"
    packprod.qtde
    with frame freee screen-lines - 10 down column 39 row 6
         title " Itens do Pack ".

def var vtitulo         as char init " Pack ".
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Consulta "," Situacao ",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de pack ", ""].

form
    esqcom1
    with frame f-com1
                 row 5 no-box no-labels side-labels column 1 centered.
assign
    esqpos1  = 1.

if par-ope = "ZOOM" 
then
    assign
        vtitulo  = " Selecionar Pack "
        sretorno = ""
        esqascend  = no
        esqcom1[1] = " Seleciona "
        esqhel1[1] = " Seleciona o pack ".
pause 0.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find pack where recid(pack) = recatu1 no-lock.
    if not available pack
    then do.
        esqvazio = yes.
        if par-ope = "ZOOM"
        then do.
            message "Sem packs para o produto PAI" view-as alert-box.
            leave.
        end.
    end.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(pack).
    color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available pack
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
            find pack where recid(pack) = recatu1 no-lock.
            clear frame freee all no-pause.
            for each packprod of pack no-lock.
                find produ of packprod no-lock.
                find cor of produ no-lock.
                display
                    packprod.procod
                    produ.pronom
                    produ.protam
                    produ.corcod
                    cor.cornom
                    packprod.qtde
                    with frame freee.
                down with frame freee.                    
                pause 0.                    
            end.
            find modpack of pack no-lock.
            find grade of modpack no-lock.
            disp modpack.modpcod
                modpack.modpnom no-label
                modpack.gracod
                grade.granom no-label
                with frame f-sub row screen-lines no-box side-label.

            status default
                esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                   then  string(pack.paccod)
                                   else "".
            run color-message.
            choose field pack.paccod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".
        end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail pack
                    then leave.
                    recatu1 = recid(pack).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail pack
                    then leave.
                    recatu1 = recid(pack).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail pack
                then next.
                color display white/red pack.paccod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail pack
                then next.
                color display white/red pack.paccod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form pack
                 with frame f-pack color black/cyan
                      centered side-label row 6 1 col.
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Seleciona "
                then do with frame f-pv on error undo.
                    sretorno = string(pack.paccod).
                    leave bl-princ.
                end. 
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-pack on error undo.
                    hide frame f-com1  no-pause.
                    hide frame frame-a no-pause.
                    run cad_manpack.p (recid(produpai), output recatu2).
                    if recatu2 <> ?
                    then recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pack.
                    find modpack of pack no-lock.
                    disp pack.
                    disp modpack.modpnom.
                    if esqcom1[esqpos1] = " Consulta "
                    then pause.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-pack on error undo.
                    find pack where recid(pack) = recatu1 exclusive.
                    update pack.pacnom.
                end.
                if esqcom1[esqpos1] = " Situacao "
                then do with frame f-pack on error undo.
                    find pack where recid(pack) = recatu1 exclusive.
                    update pack.situacao.
                end.

/***
                if esqcom1[esqpos1] = " Exclusao "
                then do on error undo.
                    message "Confirma Exclusao de" pack.paccod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next pack where true no-error.
                    if not available pack
                    then do:
                        find pack where recid(pack) = recatu1.
                        find prev pack where true no-error.
                    end.
                    recatu2 = if available pack
                              then recid(pack)
                              else ?.
                    find pack where recid(pack) = recatu1
                            exclusive.
                    delete pack.
                    recatu1 = recatu2.
                    leave.
                end.
***/
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.
        end.
        if not esqvazio
        then run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(pack).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame freee   no-pause.
hide frame f-pai   no-pause.

procedure frame-a.
    display
        pack.paccod
        pack.pacnom format "x(17)"
        pack.cores
        pack.qtde   column-label "Qtd"  format ">>9"
        with frame frame-a screen-lines - 10 down color white/red row 6
            title vtitulo.
end procedure.

procedure color-message.
color display message
        pack.paccod
        pack.pacnom
        pack.cores
        pack.qtde
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        pack.paccod
        pack.pacnom
        pack.cores column-label "Cor"
        pack.qtde
        with frame frame-a.
end procedure.


procedure leitura.
def input parameter par-tipo as char.
/* esqascend = no = Zoom */        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first pack of produpai no-lock no-error.
    else find first pack of produpai where pack.situacao no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next pack  of produpai no-lock no-error.
    else find next pack  of produpai where pack.situacao no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev pack of produpai no-lock no-error.
    else find prev pack of produpai where pack.situacao no-lock no-error.
        
end procedure.
