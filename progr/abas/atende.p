{admcab.i}

def input parameter par-parametro    as char. /* MENU | procod | recid(abastransf) */
def var vreserv_ecom     like prodistr.lipqtd format ">>>>>9".
def var vestoq_depos    as int format "->>>>>9".
def var vestoq_liq      as int format "->>>>>9".

def var vtot_reserva       as int format "->>>>>9".
def var vtot_atende       as int.
def var vtot_disponivel    as int.
def var vreservas       as int format "->>>>>9".
def var vdisponivel     as int format "->>>>>9".
def var vatende         as int format "->>>>>9".

def var par-consulta        as char.
def var par-recabastransf   as recid.
def var par-procod          like produ.procod.

def var vold_reservas as int.
def var vold_ecom as int.
def var vold_atende   as int.
def var vold_estoq_depos as int.
def var vold_disponivel as int.


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

def new shared temp-table tt-pedtransf no-undo
    field prioridade    like abastipo.abatpri  
    field etbcod        like abastransf.etbcod
    field abtcod        like abastransf.abtcod
    field abtqtd        like abastransf.abtqtd    
    field atende        as int
    field reserv        as int
    field reservOPER    as char    
    field dispo         as int
    field indispo       as int
    index sequencia is unique primary prioridade asc
    index abt is unique etbcod asc abtcod asc.

def var vindisponivel    like tt-pedtransf.dispo.

def var vhora           as char.

repeat.

    pause 0.
    for each tt-pedtransf.
        delete tt-pedtransf. 
    end.
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
    
    run abas/atendcalc.p    (input produ.procod,
                             input ?,
                             output vestoq_depos, 
                             output vreserv_ecom,
                             output vreservas,
                             output vatende,
                             output vdisponivel).
    
def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int 
    field prioridade    as int format "->>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .
    

    vestoq_liq = vestoq_depos - vreserv_ecom.
    
    run corte_disponivel.p (input  produ.procod,
                        output vold_estoq_depos, 
                        output vold_reservas, 
                        output vold_disponivel).
    
    vold_atende   = 0.
    vold_reservas = 0.
    for each tt-reservas.
        vold_atende   = vold_atende   + tt-reservas.atende.
        find liped where recid(liped) = tt-reservas.rec no-lock.
        if liped.etbcod = 200 and vreserv_ecom >= liped.lipqtd
        then vold_ecom     = vold_ecom + liped.lipqtd.
        
        vold_reservas = vold_reservas + liped.lipqtd.
    end.
    
    /*vold_reservas = vold_reservas - vatende.     */
    vtot_atende   = vatende   + vold_atende.
    vtot_reserva  = vreservas + vold_reservas.
    
    vtot_disponivel = vdisponivel   - (vold_reservas - vold_ecom).
        
    recatu1 = ?.
    if par-recabastransf <> ?
    then do.
        find abastransf where recid(abastransf) = par-recabastransf no-lock no-error.
        if avail abastransf
        then do.
                find first tt-pedtransf where
                    tt-pedtransf.etbcod = abastransf.etbcod and
                    tt-pedtransf.abtcod = abastransf.abtcod
                    no-lock no-error.
                if avail tt-pedtransf
                then do:
                    recatu1 = recid(tt-pedtransf).
                    /*vatende = tt-pedtransf.atende.*/
                    
                end.    
        end.
    end.

    if par-consulta = "CONSULTA"
    then return.

    
    do:
        
        display par-procod no-label 
                vestoq_depos   @  vestoq_depos  format "-9999" label "Estoq"
                                    colon 14

                vreservas       label "Pedid"   format "-9999"
                vatende         label "Atend"   format "-9999"
                (if vdisponivel < 0
                 then vdisponivel * -1 
                 else vdisponivel) @ vdisponivel 
                            format "-9999"
                            label "            "
                vreserv_ecom  format "-9999" label "E-Com"
                                    colon 14
                            
                vold_reservas   label "Antig"  format "-9999"
                vold_atende     label "AntAt"  format "-9999"

                vestoq_liq      label "Liber"   format "-9999" 
                        colon 14
                
                vtot_reserva    label "Total"  format "-9999"    
                vtot_atende     label "Total"  format "-9999"    
                (if vtot_disponivel < 0
                 then vtot_disponivel * -1 
                 else vtot_disponivel) @                 
                vtot_disponivel label "            "  format "-9999"    
                

                
                with frame fcab overlay.

        troca-label(vdisponivel:handle,
                         if vdisponivel >= 0
                         then "  DISPONIVEL"
                         else "InDISPONIVEL").
        troca-label(vtot_disponivel:handle,
                         if vtot_disponivel >= 0
                         then "  DISPONIVEL"
                         else "InDISPONIVEL").
                         
    end.
    
    form
        esqcom1
        with frame f-com1 overlay row 6 no-box no-labels column 1 centered.

    assign
        esqpos1 = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-pedtransf where recid(tt-pedtransf) = recatu1 no-lock.
    if not available tt-pedtransf
    then do.
        if par-consulta = "MENU"
        then do:
            message "Sem reservas".
            par-procod = ?.
            pause.
        end.    
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-pedtransf).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-pedtransf
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-pedtransf where recid(tt-pedtransf) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-pedtransf.prioridade help ""
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
                    if not avail tt-pedtransf
                    then leave.
                    recatu1 = recid(tt-pedtransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-pedtransf
                    then leave.
                    recatu1 = recid(tt-pedtransf).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-pedtransf
                then next.
                color display white/red tt-pedtransf.prioridade with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-pedtransf
                then next.
                color display white/red tt-pedtransf.prioridade with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-pedtransf
                 with frame f-tt-pedtransf color black/cyan
                      centered side-label row 7 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-pedtransf.
                    disp tt-pedtransf.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-pedtransf).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.
if par-consulta <> "MENU"
then leave.
else par-procod = ?.


end.


procedure frame-a.

def var vfuturo as log.
    find abastransf where 
            abastransf.etbcod = tt-pedtransf.etbcod and
            abastransf.abtcod = tt-pedtransf.abtcod
                        no-lock.
    find abastipo of abastransf no-lock.

    vdisponivel   = /*if tt-pedtransf.dispo > 0
                   then*/ tt-pedtransf.dispo 
                   /*else 0*/ .
    vindisponivel = /*if tt-pedtransf.indispo > 0
                    then*/ tt-pedtransf.indispo
                    /*else 0*/ .
    
    vfuturo = abastransf.dttransf > today.
    
    display 
        tt-pedtransf.prioridade  format ">>>" column-label "Ord"
        abastipo.abatnom        format "x(06)"
        abastipo.abatpri        
        abastransf.etbcod
        abastransf.abtcod
        abastransf.dttransf format "999999"
        string(abastransf.hrinclu,"HH:MM") @ vhora column-label "Hora" format "xxxxx"
        abastransf.abtsit
        abastransf.abtqtd
        abastransf.qtdemwms + abastransf.qtdatend 
                @ abastransf.qtdatend column-label "Ja!Aten" format ">>>>"
        tt-pedtransf.abtqtd column-label "Soli"
        space(0)
        vfuturo format "*/ " column-label ""
        space(0)
        tt-pedtransf.reserv      format ">>>>"  column-label "Res"
        space(0)
        tt-pedtransf.reservOPER  format "x" column-label ""
        space(0)
        vdisponivel              format "->>>9"    column-label "Disp" 
        
        tt-pedtransf.atende column-label "Aten" format ">>>9"

        vindisponivel            format "->>>9"    column-label "Sld"

        

        with frame frame-a 10 down centered 
            width 80
        row 7
                        overlay title " " + string(produ.procod) + " - " +
                                        produ.pronom + " ".
end procedure.

procedure color-message.
color display message
        tt-pedtransf.prioridade  
        abastipo.abatnom
        abastransf.etbcod
        abastransf.abtcod
        abastransf.dttransf
        vhora  
        abastransf.abtsit
        tt-pedtransf.abtqtd
        vdisponivel       
        vindisponivel    
        tt-pedtransf.atende
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
        tt-pedtransf.prioridade  
        abastipo.abatnom
        abastransf.etbcod
        abastransf.abtcod
        abastransf.dttransf
        vhora 
        abastransf.abtsit
        tt-pedtransf.abtqtd
        vdisponivel       
        vindisponivel    
        tt-pedtransf.atende
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-pedtransf where true use-index sequencia 
                                                no-lock no-error.
    else  
        find last tt-pedtransf  where true use-index sequencia
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-pedtransf  where true use-index sequencia
                                                no-lock no-error.
    else  
        find prev tt-pedtransf   where true use-index sequencia
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-pedtransf where true  use-index sequencia
                                        no-lock no-error.
    else   
        find next tt-pedtransf where true use-index sequencia
                                        no-lock no-error.
        
end procedure.
         


