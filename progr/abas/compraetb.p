/***    retpreped.p          ***/

def var recatu1         as recid.
def var reccont         as int.
def var esqvazio        as log.

def var primeiro as log.
def var vbusca  like titulo.titnum label "Estab".

{cabec.i}
def input param par-por     as char.
def input param par-abcsit  as char.
def input param par-abatipo as char.
def var par-procod  like produ.procod. 

def temp-table ttestab no-undo 
    field etbcod    like estab.etbcod
    field etbnom    like estab.etbnom format "x(20)"
    
    field comreg    as log
    field nro    as   int  column-label "Nro"  format ">>>>>"
    field abcqtd    like abascompra.abcqtd column-label "Qtde" 
                format ">>>>>>"
    field qtdoc    like abascompra.abcqtd column-label "Qtde!OC" 
                    format ">>>>>>"
    
    field tot    as   dec  column-label "Total" format ">>>>>>>9.99"
    
    index etb is primary unique etbcod
    index comreg comreg desc etbcod asc.
    
if par-por begins "FOR" or par-por begins "FAB"
then do: 
    run abas/comprafor.p (0, par-procod,
                      par-abcsit, 
                      par-abatipo).  
    return.
end.

par-procod = 0.
if par-por begins "PRO"
then do:
    update par-procod
        with frame fproduto
        row 3 centered width 80 no-box side-labels
        color messages.
end.

run cria.

find first ttestab no-lock no-error.
if not avail ttestab
then do.
    /**if westab.tipoLoja = "NORMAL" 
    then**/ do.
        create ttestab.
        assign ttestab.etbcod = setbcod
               ttestab.etbnom = westab.etbnom. 
    end.
end.

def buffer bttestab       for ttestab.
def var vttestab         like ttestab.etbcod.

bl-princ:
repeat:
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttestab where recid(ttestab) = recatu1 no-lock.
    if not available ttestab
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do.
        message "Sem Mini Pedidos cadastrados".
        leave.
    end.

    recatu1 = recid(ttestab).

    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttestab
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
            find ttestab where recid(ttestab) = recatu1 no-lock.

            status default "".

            choose field ttestab.etbcod help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      1 2 3 4 5 6 7 8 9 0 
                      PF4 F4 ESC return).
            

            if keyfunction(lastkey) = "0" or keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or keyfunction(lastkey) = "7" or
               keyfunction(lastkey) = "8" or keyfunction(lastkey) = "9" 
            then do with centered row 8 color message
                                frame f-procura side-label overlay.
                vbusca = keyfunction(lastkey).
                pause 0.
                primeiro = yes.
                update vbusca
                    editing:
                        if primeiro
                        then do:
                            apply keycode("cursor-right").
                            primeiro = no.
                        end.
                    readkey.
                    apply lastkey.
                end. 
                def buffer xttestab for ttestab.
                def var recatu2 like recatu1.
                recatu2  = recatu1. 
                 
                find first xttestab where xttestab.etbcod >= int(vbusca)
                                        no-lock no-error.
                if avail xttestab
                then recatu1 = recid(xttestab).
                else recatu1 = recatu2.
                leave.
            end.
        
        
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttestab
                    then leave.
                    recatu1 = recid(ttestab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttestab
                    then leave.
                    recatu1 = recid(ttestab).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttestab
                then next.
                color display white/red ttestab.etbcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttestab
                then next.
                color display white/red ttestab.etbcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            run abas/comprafor.p (ttestab.etbcod, par-procod,
                              par-abcsit,
                              par-abatipo).  
            
            run cria.
            next bl-princ.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(ttestab).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a.
display ttestab except comreg
        with frame frame-a 10 down centered row 5
        title "POR LOJA".
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first ttestab use-index comreg where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttestab  use-index comreg where true no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttestab  use-index comreg  where true no-lock no-error.
        
end procedure.
         



procedure cria.

empty  temp-table ttestab.
recatu1 = ?.

message "Aguarde...".
for each estab no-lock.

            find ttestab where ttestab.etbcod = estab.etbcod no-error.
            if not avail ttestab
            then create ttestab. 
            ttestab.etbcod  = estab.etbcod. 
            ttestab.etbnom  = estab.etbnom.
            ttestab.comreg  = no.
            
    for each abastipo where
        if par-abatipo = "" 
        then true
        else abastipo.abatipo = par-abatipo
        no-lock.
        for each abascompra where 
                abascompra.etbcod = estab.etbcod    and 
                abascompra.abatipo = abastipo.abatipo and 
                (if par-abcsit = ""
                 then true
                 else abascompra.abcsit = par-abcsit)
                            no-lock.
            if par-procod <> 0
            then if abascompra.procod <> par-procod
                 then next.
                 
            find ttestab where ttestab.etbcod = estab.etbcod no-error.
            if not avail ttestab
            then create ttestab. 
            ttestab.etbcod  = estab.etbcod. 
            ttestab.etbnom  = estab.etbnom.
        
            ttestab.comreg = yes.
            ttestab.nro = ttestab.nro + 1.

            ttestab.abcqtd = ttestab.abcqtd + abascompra.abcqtd.
            ttestab.qtdoc = ttestab.qtdoc + abascompra.qtdoc.


            ttestab.tot = ttestab.tot + ( (if abascompra.qtdoc > 0
                                           then abascompra.qtdoc
                                           else abascompra.abcqtd)
                                         * abascompra.lippreco).
        end.
    end.
end.
hide message no-pause.

    find first ttestab no-error.
    if not avail ttestab
    then do:
        hide message no-pause.
        message "Nenhum Encontrada" 
            " -> Situacao:" 
            par-abcsit
            " - Tipo de Origem:" 
            par-abatipo.
                  
        for each estab no-lock.
            create ttestab.
            ttestab.etbcod = estab.etbcod.
            ttestab.etbnom = estab.etbnom.
        end.
    end.
    
end procedure.


