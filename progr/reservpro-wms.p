/* reservpro.p */
/* Projeto Melhorias Mix - Luciano    */
{admcab.i}

def input parameter par-procod as char.

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

for each tt-reservas.
    delete tt-reservas.
end.

def var vprocod like produ.procod.
def var vestoq_depos    as int format "->>>>>9".
def var vreservas       as int format "->>>>>9".
def var vdisponivel     as int format "->>>>>9".
def var vhora           as char.
def var rec_liped as recid.
def new global shared var vreserv_ecom  like estoq.estatual format "->>>>9".

repeat.

pause 0.
for each tt-reservas.
    delete tt-reservas. 
end.
rec_liped = ?.
if par-procod = "MENU"
then update vprocod 
        with frame fcab overlay row 3 color message side-label width 80.
else do.
    vprocod     = int(acha("PROCOD"     ,par-procod)).
    rec_liped   = int(acha("RECID_LIPED",par-procod)).
end.
find produ where produ.procod = vprocod no-lock no-error. 
if not avail produ
then do.
    if par-procod = "MENU"
    then do.
        message "Produto invalido" .
        undo.
    end.
    else leave.
end.
run corte_disponivel_wms.p (input  produ.procod,
                        output vestoq_depos, 
                        output vreservas, 
                        output vdisponivel).

display vprocod no-label format "zzzzzzzzzz"
        vestoq_depos   @  vestoq_depos  format "->>>>>9" label "Depos"
        vreserv_ecom    label "ECOM"
        vreservas       label "Pedidos"    format ">>>>>9"
        (if vdisponivel < 0
         then vdisponivel * -1 
         else vdisponivel) @ vdisponivel     label "Disponvel   "
        with frame fcab overlay.

troca-label(vdisponivel:handle,
                         if vdisponivel >= 0
                         then "DISPONIVEL  "
                         else "INDISPONIVEL").

form
    esqcom1
    with frame f-com1 overlay row 6 no-box no-labels column 1 centered.

assign
    esqpos1 = 1
    recatu1 = ?.

recatu1 = ?.
if rec_liped <> ?
then do.
    find liped where recid(liped) = rec_liped no-lock no-error.
    if avail liped
    then do.
        find tt-reservas where tt-reservas.rec_liped = recid(com.liped) 
                            no-error.
        if avail tt-reservas
        then recatu1 = recid(tt-reservas).
    end.
end.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find tt-reservas where recid(tt-reservas) = recatu1 no-lock.
    if not available tt-reservas
    then do.
        message "Sem reservas".
        leave.
    end.

    clear frame frame-a all no-pause.
        run frame-a.

    recatu1 = recid(tt-reservas).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available tt-reservas
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

            find tt-reservas where recid(tt-reservas) = recatu1 no-lock.

            status default "".
            run color-message.
            choose field tt-reservas.prioridade help ""
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
                    if not avail tt-reservas
                    then leave.
                    recatu1 = recid(tt-reservas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-reservas
                    then leave.
                    recatu1 = recid(tt-reservas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-reservas
                then next.
                color display white/red tt-reservas.prioridade with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-reservas
                then next.
                color display white/red tt-reservas.prioridade with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:
            form tt-reservas
                 with frame f-tt-reservas color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-reservas.
                    disp tt-reservas.
                end.
        end.
            run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(tt-reservas).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

if par-procod <> "MENU"
then leave.

end.

def var ped-tipo as char. 
def var disponivel      like tt-reservas.dispo.
def var indisponivel    like tt-reservas.dispo.

procedure frame-a.

find liped where recid(liped) = tt-reservas.rec_liped no-lock.
find pedid of liped no-lock.
    if com.pedid.modcod = "PEDA"
    then ped-tipo = "Automatico".
    else if com.pedid.modcod = "PEDM"
        then ped-tipo = "Manual".
        else if com.pedid.modcod = "PEDR"
           then ped-tipo = "Reposicao".
           else if com.pedid.modcod = "PEDE"
               then ped-tipo = "Especial".
               else if com.pedid.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if com.pedid.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if com.pedid.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if com.pedid.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if com.pedid.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if com.pedid.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".

disponivel   = if tt-reservas.dispo > 0
               then tt-reservas.dispo 
               else 0.
indisponivel = if tt-reservas.dispo <= 0
               then tt-reservas.dispo * -1 
               else 0.
display tt-reservas.prioridade  format "->>>>" when tt-reservas.prioridade > 0
        ped-tipo format "x(13)" column-label "Tipo"
        pedid.pednum          
        pedid.etbcod        column-label "Etb"
        liped.predt         column-label "Dt.Pedido" format "99/99/9999"
        string(liped.prehr,"HH:MM") @ vhora column-label "Hora" format "xxxxx"
        pedid.sitped    column-label "S"
        liped.lipqtd            format ">>>>9"    column-label "Pedido"
        tt-reservas.atende      format ">>>>9"    column-label "Atende"
        disponivel              format ">>>>>"    column-label "Dispo"
        indisponivel            format ">>>>>"    column-label "Indispo"
        with frame frame-a 10 down centered color white/red row 7
                        overlay title " " + string(produ.procod) + " - " +
                                        produ.pronom + " ".
end procedure.

procedure color-message.
color display message
        tt-reservas.prioridade ped-tipo
        pedid.pednum
        pedid.etbcod
        liped.predt
        pedid.sitped    disponivel
        vhora                     indisponivel
        liped.lipqtd
        tt-reservas.atende
        with frame frame-a.
end procedure.

procedure color-normal.
color display normal
tt-reservas.prioridade
        pedid.pednum                   ped-tipo
        pedid.etbcod
        liped.predt 
        vhora
        pedid.sitped
        liped.lipqtd disponivel indisponivel
        tt-reservas.atende
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-reservas where true use-index sequencia 
                                                no-lock no-error.
    else  
        find last tt-reservas  where true use-index sequencia
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-reservas  where true use-index sequencia
                                                no-lock no-error.
    else  
        find prev tt-reservas   where true use-index sequencia
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-reservas where true  use-index sequencia
                                        no-lock no-error.
    else   
        find next tt-reservas where true use-index sequencia
                                        no-lock no-error.
        
end procedure.
         
