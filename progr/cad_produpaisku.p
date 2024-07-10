/* cad/produsku.p  */
{admcab.i}

def new shared temp-table ttcores
    field corcod   like cor.corcod
    field marc  as log init no
    field perm  as log
    index cor   is primary unique corcod.

def input parameter par-rec as recid.

find produpai where recid(produpai) = par-rec no-lock.
find grade of produpai no-lock no-error.
find fabri of produpai no-lock.

def var vprocod as int.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
            initial [" Consulta "," Inclusao ", " Alteracao ",""].
           
def buffer bprodu       for produ.

form
    esqcom1
    with frame f-com1
                 row 8 no-box no-labels column 1 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find produ where recid(produ) = recatu1 no-lock.
    if not available produ
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(produ).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available produ
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
display
    produpai.itecod colon 11
    produpai.pronom no-label
    produpai.fabcod colon 11
    fabri.fabnom    no-label format "x(20)"
    produpai.gracod
    grade.granom    no-label format "x(20)" when avail grade
    with frame fcab side-label row 4 width 80 .

        if not esqvazio
        then do:
            find produ where recid(produ) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field produ.proindice help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail produ
                    then leave.
                    recatu1 = recid(produ).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail produ
                then next.
                color display white/red produ.proindice with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail produ
                then next.
                color display white/red produ.proindice with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form produ
                 with frame f-produ color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do.
                    run inclusao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-produ on error undo.
                    find produ where recid(produ) = recatu1 no-lock.
                    vprocod = produ.procod.
                    run cad_produman.p ("AltFilho",
                                    produ.catcod,
                                    produ.fabcod,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-produ on error undo.
                    find produ where recid(produ) = recatu1 no-lock.
                    vprocod = produ.procod.
                    run cad_produman.p ("ConFilho",
                                    produ.catcod,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" produ.proindice
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next produ where of produpai no-error.
                    if not available produ
                    then do:
                        find produ where recid(produ) = recatu1.
                        find prev produ where of produpai no-error.
                    end.
                    recatu2 = if available produ
                              then recid(produ)
                              else ?.
                    find produ where recid(produ) = recatu1
                            exclusive.
                    delete produ.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    leave.
                end.

        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(produ).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
find cor of produ no-lock.
display produ.procod  format ">>>>>>9"
        produ.proindice
        produ.pronom  format "x(30)"
        cor.cornom    column-label "Cor" format "x(12)"
        produ.protam  format "x(3)"
        with frame frame-a 7 down centered color white/red row 9.
end procedure.

procedure color-message.
color display message
        produ.proindice
        produ.procod
        produ.pronom
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        produ.proindice
        produ.procod
        produ.pronom
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first produ where of produpai no-lock no-error.
    else  
        find last produ  where of produpai no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next produ  where of produpai no-lock no-error.
    else  
        find prev produ   where of produpai no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev produ where of produpai   no-lock no-error.
    else   
        find next produ where of produpai  no-lock no-error.
        
end procedure.

procedure inclusao.

    def buffer bprodu for produ.
    def buffer bestoq for estoq.

    find grade of produpai no-lock no-error. 
    if not avail grade
    then do.
        message "Produto pai sem Grade Associada" view-as alert-box.
        leave.
    end.

    run cad_selcores.p (produpai.fabcod,
                        produpai.clacod,
                        produpai.temp-cod,
                        produpai.itecod).
    find first ttcores where ttcores.marc no-lock no-error.
    if not avail ttcores
    then return.
       
    sresp = no.
    message "Confirma criar produtos FILHOS?" update sresp.
    if not sresp
    then return.

    run cad_cr_produf.p (recid(produpai)).

    for each ttcores where ttcores.marc /* marcada */
                       and ttcores.perm /* nova */.
        for each produ of produpai
                       where produ.corcod = ttcores.corcod no-lock.
            disp "Criando estoque"
                 produ.procod
                 produ.corcod
                 produ.protam
                 with side-label.
            find first bprodu where bprodu.itecod = produpai.itecod
                                and bprodu.protam = produ.protam
                                and bprodu.corcod <> produ.corcod
                              no-lock.
            find first bestoq where bestoq.procod = bprodu.procod
                              no-lock.

            for each estab no-lock:
                create estoq.
                assign
                    estoq.etbcod    = estab.etbcod
                    estoq.procod    = produ.procod
                    estoq.estcusto  = bestoq.estcusto
                    estoq.estdtcus  = bestoq.estdtcus
                    estoq.estvenda  = bestoq.estvenda
                    estoq.estdtven  = bestoq.estdtven
                    estoq.dtaltpreco = bestoq.estdtven
                    estoq.estideal  = -1
                    estoq.datexp    = today.
            end.
        end.
    end.

end procedure.
