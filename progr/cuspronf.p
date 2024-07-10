/* cuspronf.p      -  Luciano e Trojack
le produtos do fabcod NEW FREE e mostra os que que tem
custo zerado, deixando alterar o custo */

{admcab.i}

def var todos as log init no.
def var vprocod like produ.procod.

def temp-table ttprodu
    field procod    like produ.procod
    field semcusto  as log 

    index procod is unique procod.

def var recatu1         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Procura ","Consulta"," Sem Custo "," Alteracao ",""].

for each produ where produ.fabcod = 5027 /*and
                     produ.prodtcad >= 01/01/2012*/ no-lock.
/***
    vnext = no.
    for each estab no-lock.
        find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = estab.etbcod and
                         estoq.estcusto <> 0
                      no-lock no-error.
        if avail estoq
        then do.
            vnext = yes.
            leave.
        end.
    end.
***/
    find first estoq where estoq.procod = produ.procod
                       and estoq.estcusto <> 0
                     no-lock no-error.

        create ttprodu.
        ttprodu.procod   = produ.procod.
        ttprodu.semcusto = not avail estoq /*vnext*/.
end.

def buffer bttprodu       for ttprodu.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels column 1 centered.
assign
    esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttprodu where recid(ttprodu) = recatu1 no-lock.
    if not available ttprodu
    then do.
        message "Sem registros" view-as alert-box.
        leave.
    end.
    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(ttprodu).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttprodu
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find ttprodu where recid(ttprodu) = recatu1 no-lock.
            
            esqcom1[3] = if todos
                         then " Sem Custo "
                         else " Todos" .
            display esqcom1
                    with frame f-com1.
            run color-message.
            choose field ttprodu.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return).
            run color-normal.
            status default "".

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
                    if not avail ttprodu
                    then leave.
                    recatu1 = recid(ttprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttprodu
                    then leave.
                    recatu1 = recid(ttprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttprodu
                then next.
                color display white/red ttprodu.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttprodu
                then next.
                color display white/red ttprodu.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if  esqcom1[esqpos1] = " Alteracao " and ttprodu.semcusto
                then do.
                        run altcusto (ttprodu.procod).
                        recatu1 = ?.
                        next bl-princ.
                end.
                if esqcom1[esqpos1] = " Todos " or
                   esqcom1[esqpos1] = " Sem Custo "
                then do.
                    todos = not todos.
                    recatu1 = ?.
                    leave.
                end.
                if esqcom1[esqpos1] = " Procura "
                then do.
                    update vprocod   
                            with frame fprpoc centered row 8 overlay.
                            
                    find first bttprodu where bttprodu.procod = 
                                        vprocod no-lock no-error.
                    if avail bttprodu
                    then recatu1 = recid(bttprodu).
                    leave.
                end.

                if esqcom1[esqpos1] = "Consulta" 
                then do.
                    find produ of ttprodu no-lock.
                    vprocod = produ.procod.
                    run cad_produman.p ("Con",
                                    produ.catcod,
                                    0,
                                    0,
                                    0,
                                    0,
                                    input-output vprocod).
                    pause.
                    for each estoq of produ NO-LOCK:
                        disp
                            estoq.etbcod
                                estatual  (total) format "->>,>>9.99"
                                estpedcom (total)
                                estpedven (total)
                                estpedcom + estatual - estpedven
                                        column-label "Disponiv" (total)
                                estcusto  column-label "CUSTO"
                                estvenda  column-label "PV"
                                with centered overlay row 5 9 down
                                        title "Armazenagem " + produ.pronom
                                                color white/cyan.
                    end.
                    pause 0.
                    leave.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttprodu).
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
find produ of ttprodu no-lock.
display ttprodu.procod 
        produ.pronom 
        produ.prodtcad label "Cadastro" format "99/99/99"
        semcusto format "*****/" column-label "Sem!Custo"
        with frame frame-a 10 down  color white/red row 5 
        centered.
end procedure.

procedure color-message.
color display message
        ttprodu.procod
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        ttprodu.procod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
        find first ttprodu where (if todos
                                  then true
                                  else ttprodu.semcusto)
                                                no-lock no-error.

if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttprodu  where (if todos
                                  then true
                                  else ttprodu.semcusto)
                                                no-lock no-error.

if par-tipo = "up" 
then                  
        find prev ttprodu where (if todos
                                  then true
                                  else ttprodu.semcusto)
                                        no-lock no-error.
end procedure.
         

procedure altcusto.

def input parameter par-procod like produ.procod.
def var vestmgoper like estoq.estmgoper.
def var vestmgluc  like estoq.estmgluc.
def var vestcusto  like estoq.estcusto.
def var vestvenda  like estoq.estvenda.
def var vtime as int.

    find produ where produ.procod = par-procod no-lock.
    
    do with frame fpre2 centered overlay color white/red side-labels row 15.
        assign
            vestmgoper = wempre.empmgoper
            vestmgluc  = wempre.empmgluc.
        update
            vestcusto  colon 20
            vestmgoper colon 20
            vestmgluc  colon 20.
         vestvenda = (vestcusto * (vestmgoper / 100 + 1)) * 
                    (vestmgluc / 100 + 1).
         update vestvenda colon 20.
    end.
    do on error undo.
        if vestcusto > 0
        then do.
            find current ttprodu.
            ttprodu.semcusto = no.
        end.
        find current produ.    
        produ.pronom = caps(produ.pronom).
            
        vtime = time.

        find lgaltcus where lgaltcus.procod = produ.procod
                        and lgaltcus.datalt = today
                        and lgaltcus.horalt = vtime no-error.
        if not avail lgaltcus 
        then do:
            create lgaltcus.
            assign
                lgaltcus.procod = produ.procod
                lgaltcus.datalt = today
                lgaltcus.horalt = vtime
                lgaltcus.cusant = 0
                lgaltcus.cusalt = vestcusto.
        end.
        for each estab no-lock:
            find estoq where estoq.etbcod    = estab.etbcod and
                             estoq.procod    = produ.procod
                       no-error.
            if not avail estoq
            then create estoq.
            assign
                estoq.etbcod    = estab.etbcod
                estoq.procod    = produ.procod
                estoq.estcusto  = vestcusto
                estoq.estdtcus  = (if vestcusto <> estoq.estcusto
                                   then today
                                   else estoq.estdtcus)
                estoq.estvenda  = vestvenda
                estoq.estdtven  = (if vestvenda <> estoq.estvenda
                                   then today
                                   else estoq.estdtven)
                estoq.estideal = -1
                estoq.datexp    = today.
        end.
    end.

end procedure.
