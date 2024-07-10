/***    retpreped.p          ***/

def var recatu1         as recid.
def var reccont         as int.
def var esqvazio        as log.

def var primeiro as log.
def var vbusca  like titulo.titnum label "Estab".

{cabec.i}
def input param par-por     as char.
def input param par-abtsit  as char.
def input param par-abatipo as char.
def var par-procod  like produ.procod. 

def new shared temp-table ttwms no-undo
    field wms       like abaswms.wms
    field catcod    like abaswms.catcod
    field comreg    as log    
    field nro       as int format ">>,>>9"    column-label "Itens"
    field qtd       as int format ">>,>>9"   column-label "Qtd"
    index idx is unique primary wms asc catcod asc
    index comreg comreg desc wms asc catcod asc.

if par-por begins "BOX"
then do: 
    run abas/transfbox.p (0, par-procod,
                      par-abtsit, 
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

find first ttwms no-lock no-error.
if not avail ttwms
then do.
    return.
end.

def buffer bttwms       for ttwms.
def var vttwms          like ttwms.wms.

bl-princ:
repeat:
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find ttwms where recid(ttwms) = recatu1 no-lock.
    if not available ttwms
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

    recatu1 = recid(ttwms).

    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available ttwms
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
            find ttwms where recid(ttwms) = recatu1 no-lock.

            status default "".

            choose field ttwms.wms help ""
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
                def buffer xttwms for ttwms.
                def var recatu2 like recatu1.
                recatu2  = recatu1. 
                 
                find first xttwms where xttwms.wms >= (vbusca)
                                        no-lock no-error.
                if avail xttwms
                then recatu1 = recid(xttwms).
                else recatu1 = recatu2.
                leave.
            end.
        
        
        end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttwms
                    then leave.
                    recatu1 = recid(ttwms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttwms
                    then leave.
                    recatu1 = recid(ttwms).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttwms
                then next.
                color display white/red ttwms.wms with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttwms
                then next.
                color display white/red ttwms.wms with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            run abas/transfbox.p (ttwms.wms, ttwms.catcod, par-abatipo, par-procod,
                              par-abtsit).

            run cria.
            next bl-princ.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        recatu1 = recid(ttwms).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame frame-a no-pause.

procedure frame-a.
find categoria of ttwms no-lock.
display ttwms.wms
        ttwms.catcod
        categoria.catnom
        ttwms.nro
        ttwms.qtd
        with frame frame-a 10 down centered row 5
        title "POR WMS".
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
        find first ttwms use-index comreg where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
        find next ttwms  use-index comreg where true no-lock no-error.
             
if par-tipo = "up" 
then                  
        find prev ttwms  use-index comreg  where true no-lock no-error.
        
end procedure.
         



procedure cria.

empty  temp-table ttwms.
recatu1 = ?.

message "Aguarde...".
for each abaswms where
    if par-abatipo = "" then true 
    else abaswms.abatipo = par-abatipo
        no-lock.   
    find ttwms where 
            ttwms.wms       = abaswms.wms       and
            ttwms.catcod    = abaswms.catcod
        no-error. 
    if not avail ttwms 
    then create ttwms.  
    ttwms.wms     = abaswms.wms.
    ttwms.catcod  = abaswms.catcod.
    ttwms.comreg  = no. 
    find abastipo of abaswms no-lock.
    
    for each abastransf where  
        abastransf.abatipo = abastipo.abatipo and  
        abastransf.catcod  = abaswms.catcod and
            (if par-abtsit = "" 
            then true 
            else abastransf.abtsit = par-abtsit) 
        no-lock. 

        if par-procod <> 0
            then if abastransf.procod <> par-procod
                 then next.
        ttwms.comreg = yes.
        ttwms.nro = ttwms.nro + 1.
        ttwms.qtd = ttwms.qtd + abastransf.abtqtd.
    end.
end.
hide message no-pause.

    find first ttwms no-error.
    if not avail ttwms
    then do:
        hide message no-pause.
        message "Nenhum Encontrada" 
            " -> Situacao:" 
            par-abtsit
            " - Tipo de Origem:" 
            par-abatipo.
                  
/*
        for each estab no-lock.
            create ttwms.
            ttwms.wms = estab.etbcod.
            ttwms.etbnom = estab.etbnom.
        end.
    */
    end.
        
end procedure.


