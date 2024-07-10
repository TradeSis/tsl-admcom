{cabec.i}

def input parameter par-wms     like abaswms.wms.
def input parameter par-catcod  like abaswms.catcod.
def input parameter par-abatipo like abastransf.abatipo.
/*def input parameter par-etbcod  like estab.etbcod.*/
def input parameter par-procod  like produ.procod.
def input parameter par-abtsit  like abastransf.abtsit.

def var vbox as int.
def var vetbcod as int.
def var aux-forcod as int.
def temp-table ttbox    no-undo
    field wms    like abaswms.wms
    field catcod like abaswms.catcod
    field box    like tab_box.box
    field etbcod like abastransf.etbcod
    field comreg as log
    field nro    as   int  column-label "Nro"  format ">>>>9"
    field qtd    like abastransf.abtqtd column-label "Qtde" 
                format ">>>>>9"

    index box is primary unique wms asc catcod asc box asc etbcod asc
    index comreg comreg desc wms asc catcod asc box asc etbcod asc.
    
aux-forcod = ?.

    find categoria where categoria.catcod = par-catcod no-lock no-error.
        
    disp par-wms par-catcod categoria.catnom no-label when avail categoria
         with frame f-estab row 3 no-box color message side-label centered.

run cria. 

def var recatu1         as recid.
def var reccont         as int.
def var esqvazio        as log.

bl-princ:
repeat:

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttbox where recid(ttbox) = recatu1 no-lock.
    if not available ttbox
    then esqvazio = yes.
    else esqvazio = no.

    clear frame frame-a all no-pause.
    if not esqvazio
    then run frame-a.

    recatu1 = recid(ttbox).
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttbox
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
            find ttbox where recid(ttbox) = recatu1 no-lock.

            status default "F3 inclui Fornecedor".

            choose field ttbox.box help ""
                go-on(cursor-down cursor-up
                      page-down   page-up
                      PF3 F3
                      PF4 F4 ESC return).
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttbox
                    then leave.
                    recatu1 = recid(ttbox).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttbox
                    then leave.
                    recatu1 = recid(ttbox).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttbox
                then next.
                color display white/red ttbox.box with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttbox
                then next.
                color display white/red ttbox.box with frame frame-a.
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
                /*
                run abas/transfinc.p (par-etbcod,
                                      0,
                                      par-abatipo).
                  */
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
                /*
                run abas/transfinc.p (par-etbcod,
                                      0,
                                      par-abatipo).
                */
                run cria.
            end.
            else do.
                hide frame frame-a no-pause.
                aux-forcod = ttbox.box.
                /*
                run abas/transfman.p (par-etbcod, ttbox.box, par-procod,
                        par-abtsit, par-abatipo).
                  */
                run cria.
            end.
            leave.
        end.
            run frame-a.
        recatu1 = recid(ttbox).
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
display ttbox 
        with frame frame-a 10 down centered  row 5
        title "POR BOX".
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first ttbox where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttbox  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttbox where true  no-lock no-error.
        
end procedure.


procedure cria.

    recatu1 = ?.
    empty temp-table ttbox.

    for each abaswms where
        (if par-wms = ""
         then true
         else abaswms.wms = par-wms) and
        (if par-catcod = 0
         then true
         else abaswms.catcod = par-catcod) 
         no-lock.
        /*
        if abaswms.usabox
        then do:
            for each tab_box no-lock.
                find first ttbox where
                    ttbox.wms = abaswms.wms and
                    ttbox.catcod = abaswms.catcod and
                    ttbox.box  = tab_box.box and
                    ttbox.etbcod = 0
                    no-error.
                if not avail ttbox
                then do:
                    create ttbox.
                    ttbox.wms = abaswms.wms.
                    ttbox.catcod = abaswms.catcod.
                    ttbox.box  = tab_box.box.
                    ttbox.etbcod = 0.
                    ttbox.comreg = no.
                end.                    
            end.
        end.
        else do:
            for each estab no-lock.
                find first ttbox where
                    ttbox.wms = abaswms.wms and
                    ttbox.catcod = abaswms.catcod and
                    ttbox.box  = 0 and
                    ttbox.etbcod = estab.etbcod
                    no-error.
                if not avail ttbox
                then do:
                    create ttbox.
                    ttbox.wms = abaswms.wms.
                    ttbox.catcod = abaswms.catcod.
                    ttbox.box   = 0.
                    ttbox.etbcod = estab.etbcod.
                    ttbox.comreg = no.
                end.                    
            end.
        end.
        */
        
        find abastipo of abaswms no-lock. 
        
        for each abastransf where  
                abastransf.abatipo = abastipo.abatipo and  
                abastransf.catcod  = abaswms.catcod and
                    (if par-abtsit = "" 
                    then true 
                    else abastransf.abtsit = par-abtsit) 
                no-lock. 
                 
            vbox = 0.
            vetbcod = abastransf.etbcod.
            if abaswms.usabox
            then do: 
                vetbcod = 0.
                find first tab_box where tab_box.etbcod = abastransf.etbcod no-lock no-error.
                if avail tab_box
                then vbox = tab_box.box.
            end.
        

            if par-procod <> 0
            then if abastransf.procod <> par-procod
                 then next.
                 
            find first ttbox where ttbox.wms    = abaswms.wms and
                                   ttbox.catcod = abaswms.catcod and
                                   ttbox.box    = vbox and
                                   ttbox.etbcod = vetbcod
                    no-error.
            if not avail ttbox
            then do:
                create ttbox.
                ttbox.wms    = abaswms.wms.
                ttbox.catcod = abaswms.catcod.
                ttbox.box   = vbox.
                ttbox.etbcod = vetbcod.
            end.                             
            ttbox.comreg = yes.
            ttbox.nro = ttbox.nro + 1.
            ttbox.qtd = ttbox.qtd + abastransf.abtqtd.
        end.
    end.


end procedure.
