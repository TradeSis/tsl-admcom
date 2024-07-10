{cabec.i}

def input parameter par-etbcod  like estab.etbcod.
def input parameter par-procod  like produ.procod.
def input parameter par-abcsit  like abascompra.abcsit.
def input parameter par-abatipo like abascompra.abatipo.

def var aux-forcod as int.
def temp-table ttforne    no-undo
    field forcod    like forne.forcod
    field fornom    like forne.fornom format "x(20)"
    field nro    as   int  column-label "Nro"  format ">>>>9"
    field abcqtd    like abascompra.abcqtd column-label "Qtde" 
                format ">>>>>9"
    field qtdoc    like abascompra.abcqtd column-label "Qtde!OC" 
                    format ">>>>>9"
    
    field tot    as   dec  column-label "Total" format ">>>>>>>9.99"
     

    index fab is primary unique forcod.
    
aux-forcod = ?.

run cria. 

def var recatu1         as recid.
def var reccont         as int.
def var esqvazio        as log.

bl-princ:
repeat:
    find estab where estab.etbcod = par-etbcod no-lock no-error.
    disp par-etbcod
         estab.etbnom no-label when avail estab
         with frame f-estab row 3 no-box color message side-label centered.

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttforne where recid(ttforne) = recatu1 no-lock.
    if not available ttforne
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttforne).
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttforne
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
            find ttforne where recid(ttforne) = recatu1 no-lock.

            status default "F3 inclui Fornecedor".

            choose field ttforne.forcod help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF3 F3
                      PF4 F4 ESC return).
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttforne
                    then leave.
                    recatu1 = recid(ttforne).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttforne
                    then leave.
                    recatu1 = recid(ttforne).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttforne
                then next.
                color display white/red ttforne.forcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttforne
                then next.
                color display white/red ttforne.forcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "enter-menubar"
        then do.
                hide frame frame-a no-pause.
                hide frame f-estab no-pause.
                run abas/comprainc.p (par-etbcod,
                                      0,
                                      par-abatipo).

             run cria.
             leave.
        end.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            aux-forcod = ?.
            if esqvazio
            then do.
                hide frame frame-a no-pause.
                hide frame f-estab no-pause.
                run abas/comprainc.p (par-etbcod,
                                      0,
                                      par-abatipo).
                run cria.
            end.
            else do.
                hide frame frame-a no-pause.
                aux-forcod = ttforne.forcod.
                run abas/compraman.p (par-etbcod, ttforne.forcod, par-procod,
                        par-abcsit, par-abatipo).

                run cria.
            end.
            leave.
        end.
            run frame-a.
        recatu1 = recid(ttforne).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.
hide frame f-estab no-pause.

procedure frame-a.
display ttforne 
        with frame frame-a 10 down centered  row 5
        title "POR FORNECEDOR".
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first ttforne where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttforne  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttforne where true  no-lock no-error.
        
end procedure.


procedure cria.

    recatu1 = ?.
    empty temp-table ttforne.

    for each estab where
        if par-etbcod <> 0
        then estab.etbcod = par-etbcod 
        else true
        no-lock.
        for each abastipo where
            if par-abatipo = "" or par-abatipo begins "TOD"
            then true
            else abastipo.abatipo = par-abatipo
            no-lock.
            
            for each abascompra where 
                    abascompra.etbcod  = estab.etbcod and 
                    abascompra.abatipo = abastipo.abatipo and 
                    (if par-abcsit = ""
                     then true
                     else abascompra.abcsit  = par-abcsit)
                            no-lock.

                if par-procod <> 0
                then if abascompra.procod <> par-procod
                     then next.
                            
                find produ of abascompra no-lock.
                find forne where forne.forcod = abascompra.forcod
                    no-lock no-error.
                find ttforne where ttforne.forcod = abascompra.forcod no-error.
                if not avail ttforne
                then do.
                    create ttforne. 
                    ttforne.forcod  = abascompra.forcod. 
                    ttforne.fornom  = if avail forne
                                      then forne.fornom
                                      else "".
                end.
                ttforne.nro = ttforne.nro + 1.

                ttforne.abcqtd = ttforne.abcqtd + abascompra.abcqtd.
                ttforne.qtdoc = ttforne.qtdoc + abascompra.qtdoc.


                ttforne.tot = ttforne.tot + ( (if abascompra.qtdoc > 0
                                               then abascompra.qtdoc
                                               else abascompra.abcqtd)
                                             * abascompra.lippreco).
            end.
        end.
    end.

    find first ttforne where ttforne.forcod = aux-forcod no-lock no-error.
    if avail ttforne
    then recatu1 = recid(ttforne).

end procedure.

procedure fornecante.

    def var vforcod like forne.forcod.
    do on error undo.
        update vforcod with frame f-sel side-labe.
        find forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do.
            message "fornecante nao encontrado" view-as alert-box.
            undo.
        end.
        run abas/compraman.p (par-etbcod, vforcod, par-procod, par-abcsit, par-abatipo).
        recatu1 = ?.
    end.
end procedure.
