{admcab.i}
def input parameter par-parametro    as char. /* MENU | procod | recid(abastransf) */


def var par-consulta        as char.
def var par-recabastransf   as recid.
def var par-procod          like produ.procod.

par-procod = ?.

if num-entries(par-parametro,"|") = 3
then do:
    par-recabastransf = int(entry(3,par-parametro,"|")).
    par-procod        = int(entry(2,par-parametro,"|")).
    par-consulta      = entry(1,par-parametro,"|").
end.
if num-entries(par-parametro,"|") = 2
then do:
    par-recabastransf = ?.
    par-procod        = int(entry(2,par-parametro,"|")).
    par-consulta      = entry(1,par-parametro,"|").
end.
if num-entries(par-parametro,"|") = 1
then do:
    par-recabastransf = ?.
    par-procod        = ?.
    par-consulta      = entry(1,par-parametro,"|").
end.



function troca-label returns character
    (input par-handle as handle,
     input par-label  as char).
         
    if par-label = "NO-LABEL"
    then par-handle:label    = ?.
    else par-handle:label    = par-label.

end function.


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5.

def var vseq as int.    

def var vqtdatend like abastransf.qtdatend.
def var vqtdemwms like abastransf.qtdemwms.

def temp-table tt-transf no-undo
    field rec as recid.

def new shared temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format ">>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.


def var vhrinclu        as char format "x(04)".
def var vhoraReal        as char format "x(04)".
def var vhrsepara       as char format "x(04)".

repeat.

    pause 0.
    if par-procod = ?
    then do:
        update par-procod 
                with frame fcab overlay row 3 color message side-label width 80
                no-box.
    end.
    find produ where produ.procod = par-procod no-lock no-error. 
    if not avail produ
    then do.
        if par-consulta begins "MENU"
        then do.
            message "Produto invalido" .
            undo.
        end.
        else leave.
    end.
    
    run criatt.
    
    form
        tt-cortes.etbcod
        tt-cortes.abtcod column-label "Pedido"
                abastransf.abatipo
        tt-cortes.oper format "x(06)"
        
        tt-cortes.dataReal format "999999"
        vhoraReal 
                column-label "Hr"

        tt-cortes.dcbcod
        tt-cortes.Numero column-label "Numero"
        tt-cortes.qtd   column-label "Qtd!Oper"
        
        tt-cortes.QtdemWMS format ">>>>"
        tt-cortes.QtdAtend format ">>>>"
        tt-cortes.qtdpend format ">>>>"
        tt-cortes.abtsit

        with frame frame-a 10 down centered 
            width 80
        row 5
                        overlay no-box.

    recatu1 = ?.

    /*
    if par-recabastransf <> ?
    then do.
        find abastransf where recid(abastransf) = par-recabastransf no-lock no-error.
        if avail abastransf
        then do.
                find first tt-cortes where
                    tt-cortes.rectransf   = recid(abastransf) 
                    no-lock no-error.
                if avail tt-cortes
                then do:
                    recatu1 = recid(tt-cortes).
                    /*vatende = tt-cortes.atende.*/
                    
                end.    
        end.
    end.
    */
    
    if par-consulta = "CONSULTA"
    then return.

    
    do:
        display par-procod no-label 
                with frame fcab overlay.

    end.
    
    form
        esqcom1
        with frame f-com1 overlay row 4 no-box no-labels column 1 centered.

    assign
        esqpos1 = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-cortes where recid(tt-cortes) = recatu1 no-lock.
    if not available tt-cortes
    then do.
        if par-consulta = "MENU"
        then message "Sem reservas".
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-cortes).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-cortes
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-cortes where recid(tt-cortes) = recatu1 no-lock.

            esqcom1[1] = "".
            release plani.
            
            if tt-cortes.oper = "PEDIDO"
            then do:
                find abastransf where 
                        abastransf.etbcod = tt-cortes.etbcod and
                        abastransf.abtcod = tt-cortes.abtcod
                    no-lock no-error.
                if avail abastransf           
                then do:
                    find first plani where 
                            plani.etbcod = abastransf.orietbcod and 
                            plani.placod = abastransf.oriplacod
                            no-lock no-error.
                    if avail plani
                    then esqcom1[1] = "<  NF.Venda   >".
                end.
            end.     
            if tt-cortes.oper = "NOTA"
            then do:
                find plani where plani.etbcod = tt-cortes.traetbcod and
                                 plani.placod = tt-cortes.traplacod
                                 no-lock no-error.
                if avail plani
                then do: 
                    esqcom1[1] = "<  NF.Transf  >".
                end. 
            end.
            if  tt-cortes.oper     = "CORTE"
            then do: 
                find abascorteprod where recid(abascorteprod) = tt-cortes.rec no-lock no-error.
                if avail abascorteprod
                then do:
                    find abascorte of abascorteprod no-lock no-error.
                    if avail abascorte
                    then esqcom1[1] = "<  Cons.Corte >".
                end.
            end.    
            
            disp esqcom1 with frame f-com1.        
                 
            status default "".
            run color-message.
            choose field tt-cortes.oper help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      PF4 F4 ESC return) .
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
                    if not avail tt-cortes
                    then leave.
                    recatu1 = recid(tt-cortes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-cortes
                    then leave.
                    recatu1 = recid(tt-cortes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-cortes
                then next.
                color display white/red tt-cortes.dataReal with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-cortes
                then next.
                color display white/red tt-cortes.dataReal with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-cortes
                 with frame f-tt-cortes color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "<  NF.Venda   >"
                then do:
                    find abastransf where 
                            abastransf.etbcod = tt-cortes.etbcod and
                            abastransf.abtcod = tt-cortes.abtcod
                        no-lock no-error.
                    if avail abastransf           
                    then do:
                        find first plani where 
                                plani.etbcod = abastransf.orietbcod and 
                                plani.placod = abastransf.oriplacod
                                no-lock no-error.
                        if avail plani
                        then  run not_consnota.p (recid(plani)).
                    end.
                end.

                if esqcom1[esqpos1] = "<  NF.Transf  >"
                then do:
                    find first plani where 
                            plani.etbcod = tt-cortes.traetbcod and 
                            plani.placod = tt-cortes.traplacod
                            no-lock no-error.
                    if avail plani
                    then  run not_consnota.p (recid(plani)).
                end.
                if esqcom1[esqpos1] = "<  Cons.Corte >"
                then do:
                    find abascorteprod where recid(abascorteprod) = tt-cortes.rec no-lock no-error.
                    if avail abascorteprod
                    then do:
                        find abascorte of abascorteprod no-lock no-error.
                        if avail abascorte
                        then  run abas/cortescprod.p (recid(abascorte)).
                    end.
                end.       

        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-cortes).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
hide frame fcab no-pause.
if par-consulta <> "MENU"
then leave.


leave.

end.


procedure frame-a.

    find abastransf     where abastransf.etbcod = tt-cortes.etbcod and
                              abastransf.abtcod = tt-cortes.abtcod
                              no-lock.
    find abastipo of abastransf no-lock.
    
    disp
        
        tt-cortes.etbcod   when tt-cortes.seq = 1
        tt-cortes.abtcod   when tt-cortes.seq = 1
        abastransf.abatipo when tt-cortes.seq = 1
        tt-cortes.oper
        
        tt-cortes.dataReal format "999999"
        replace(string(tt-cortes.horaReal,"HH:MM"),":","") @ vhoraReal 
                column-label "Hr"
        tt-cortes.dcbcod when tt-cortes.oper <> "CORTE"

        tt-cortes.Numero
        tt-cortes.qtd   column-label "Qtd!Oper"
        
        tt-cortes.QtdemWMS
        tt-cortes.QtdAtend
        tt-cortes.qtdpend
        tt-cortes.abtsit

        with frame frame-a.

end procedure.

procedure color-message.
color display message
        tt-cortes.etbcod   when tt-cortes.seq = 1
        tt-cortes.abtcod   when tt-cortes.seq = 1
        abastransf.abatipo when tt-cortes.seq = 1
        tt-cortes.oper
        
        tt-cortes.dataReal
        vhoraReal 
        tt-cortes.Numero
        tt-cortes.qtd   
        
        tt-cortes.QtdemWMS
        tt-cortes.QtdAtend
        tt-cortes.qtdpend
        tt-cortes.abtsit

        tt-cortes.dataReal  
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        tt-cortes.etbcod   when tt-cortes.seq = 1
        tt-cortes.abtcod   when tt-cortes.seq = 1
        abastransf.abatipo when tt-cortes.seq = 1
        tt-cortes.oper
        
        tt-cortes.dataReal
        vhoraReal 
        tt-cortes.Numero
        tt-cortes.qtd   
        
        tt-cortes.QtdemWMS
        tt-cortes.QtdAtend
        tt-cortes.qtdpend
        tt-cortes.abtsit

        tt-cortes.dataReal  
        
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-cortes where true use-index sequencia 
                                                no-lock no-error.
    else  
        find last tt-cortes  where true use-index sequencia
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-cortes  where true use-index sequencia
                                                no-lock no-error.
    else  
        find prev tt-cortes   where true use-index sequencia
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-cortes where true  use-index sequencia
                                        no-lock no-error.
    else   
        find next tt-cortes where true use-index sequencia
                                        no-lock no-error.
        
end procedure.
         


procedure criatt.

for each tt-cortes.
    delete tt-cortes.
end.
for each tt-transf.
    delete tt-transf.
end.
if par-recabastransf <> ? 
then do: 
    create tt-transf. 
    tt-transf.rec = par-recabastransf.
end.
else do:
    for each abastransf where abastransf.procod = par-procod no-lock.
        create tt-transf.
        tt-transf.rec = recid(abastransf).
    end.
end.


    
for each tt-transf.

    find abastransf where recid(abastransf) = tt-transf.rec no-lock.

    run abas/transfqtdsit.p (recid(abastransf), no).
    
end.

        
end.            
 
