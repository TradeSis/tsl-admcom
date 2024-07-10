/* Projeto Melhorias Mix - Luciano       */

def buffer liped_pend for liped.
def buffer pedid_pend for pedid.
def var dcb-cod like tdocbase.dcbcod.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
        init [" Prioridades ", " ",""].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

{admcab.i}
def input parameter par-rec as recid.
find pedid where recid(pedid)  = par-rec no-lock.

def buffer bliped       for liped.
def var vliped         like liped.procod.
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


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find liped where recid(liped) = recatu1 no-lock.
    if not available liped
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(liped).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available liped
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
            find liped where recid(liped) = recatu1 no-lock.

        def var rec-pend as recid.
        rec-pend = ?.
        esqcom1[2] = "".
        find first pedpend where pedpend.etbcod-ori = liped.etbcod and
                                 pedpend.pedtdc-ori = liped.pedtdc and
                                 pedpend.pednum-ori = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-des and
                                  liped_pend.pedtdc = pedpend.pedtdc-des and
                                  liped_pend.pednum = pedpend.pednum-des and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then assign rec-pend = recid(liped_pend)
                        esqcom1[2] = " Gerado ".
                        .
        end.
        find first pedpend where pedpend.etbcod-des = liped.etbcod and
                                 pedpend.pedtdc-des = liped.pedtdc and
                                 pedpend.pednum-des = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-ori and
                                  liped_pend.pedtdc = pedpend.pedtdc-ori and
                                  liped_pend.pednum = pedpend.pednum-ori and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then assign rec-pend = recid(liped_pend)
                        esqcom1[2] = " Original ".
        end.
        esqcom1[3] = "".
        if liped.venda-placod <> ?
        then do.
            find plani where plani.etbcod = pedid.etbcod and
                             plani.placod = liped.venda-placod
                             no-lock no-error.
            if avail plani
            then esqcom1[3] = " Venda ".
        end.
        if pedid.frecod <> 0
        then do.
            find plani where plani.etbcod = pedid.etbcod and
                             plani.placod = pedid.frecod
                             no-lock no-error.
            if avail plani
            then esqcom1[3] = " Venda ".
        end.
        display esqcom1
                with frame f-com1.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(liped.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(liped.procod)
                                        else "".
            run color-message.
            choose field liped.procod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail liped
                    then leave.
                    recatu1 = recid(liped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail liped
                    then leave.
                    recatu1 = recid(liped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail liped
                then next.
                color display white/red liped.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail liped
                then next.
                color display white/red liped.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form liped
                 with frame f-liped color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Prioridades "
                then do with frame f-liped on error undo.
                    find produ where produ.procod = liped.procod no-lock.
                    pause 0.
                    run reservpro.p (input "PROCOD=" + string(produ.procod) +
                                     "|" + 
                                     "RECID_LIPED=" + string(recid(liped)) ).
                    recatu1 = recid(liped).
                    leave.
                end.
                if esqcom1[esqpos1] = " Venda "
                then do.
                    if liped.venda-placod <> ?
                    then do.
                        find plani where plani.etbcod = pedid.etbcod and
                                         plani.placod = liped.venda-placod
                                         no-lock no-error.
                    end.
                    if pedid.frecod <> 0
                    then do.
                        find plani where plani.etbcod = pedid.etbcod and
                                         plani.placod = pedid.frecod
                                         no-lock no-error.
                    end.
                    if avail plani
                    then do.
                        hide frame f-com1  no-pause.
                        hide frame f-com2  no-pause.
                        run not_consnota.p (recid(plani)).
                        view frame f-com1.
                        view frame f-com2.
                        leave.
                    end.
                end.
                if esqcom1[esqpos1] = " Original "
                then do with frame f-Lista:
                    run frame-pendente.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(liped).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.

def var vestoq_depos    as int format "->>>>>9".
def var vreservas       as int format "->>>>>9".
def var vdisponivel     as int format "->>>>>9".
find com.produ where com.produ.procod = com.liped.procod no-lock. 
for each tt-reservas.
    delete tt-reservas.
end.

run corte_disponivel.p (input  produ.procod,
                        output vestoq_depos, 
                        output vreservas, 
                        output vdisponivel).
find tt-reservas where tt-reservas.rec_liped = recid(com.liped) no-error.


        def var vpend as char format "x(13)".
        vpend = "".
        find first pedpend where pedpend.etbcod-ori = liped.etbcod and
                                 pedpend.pedtdc-ori = liped.pedtdc and
                                 pedpend.pednum-ori = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-des and
                                  liped_pend.pedtdc = pedpend.pedtdc-des and
                                  liped_pend.pednum = pedpend.pednum-des and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then vpend = "Gerado=" + string(pednum-des).
        end.
        find first pedpend where pedpend.etbcod-des = liped.etbcod and
                                 pedpend.pedtdc-des = liped.pedtdc and
                                 pedpend.pednum-des = liped.pednum
                                 no-lock no-error.
        if avail pedpend
        then do.
            find liped_pend where liped_pend.etbcod = pedpend.etbcod-ori and
                                  liped_pend.pedtdc = pedpend.pedtdc-ori and
                                  liped_pend.pednum = pedpend.pednum-ori and
                                  liped_pend.procod = liped.procod
                                  no-lock no-error.
            if avail liped_pend
            then vpend = "Orig=" + string(pednum-ori).
        end.
        /*
        find first tdocbpro where
               tdocbpro.etbdes = liped.etbcod and
               tdocbpro.procod = liped.procod and
               tdocbpro.pednum = pedid.pednum
               no-lock no-error.
        */
        dcb-cod = 0.
        run tdcb-cod. 
        disp com.liped.procod   column-label "Codigo"
             com.produ.pronom   format "x(10)" column-label "Produto"
             com.liped.lipqtd   column-label "Qtd!Pedido" format ">>>>9" 
             com.liped.lipent   column-label "Qtd!Entreg" format ">>>>9" 
             com.liped.lipsit   column-label "S" format "x"
             vestoq_depos       column-label "Estoq!Deposito"    
             vreservas          column-label "Pedidos"
             /*
             vdisponivel        column-label "Dispo"
             */
             tt-reservas.atende column-label "Atende"      format ">>>>9"
                                    when avail tt-reservas
             dcb-cod    column-label "Numero!WMS"
                             when dcb-cod > 0  format ">>>>>9"
        with frame frame-a 10 down centered color white/red row 5
                    width 80
                title " Pedido " + string(pedid.pednum) + " filial " +
                                    string(pedid.etbcod) + " ".
end procedure.
procedure color-message.
color display message
        liped.procod
        tt-reservas.atende
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        liped.procod
        tt-reservas.atende
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first liped where of pedid
                                                no-lock no-error.
    else  
        find last liped  where of pedid
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next liped  where of pedid
                                                no-lock no-error.
    else  
        find prev liped   where of pedid
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev liped where of pedid  
                                        no-lock no-error.
    else   
        find next liped where of pedid 
                                        no-lock no-error.
        
end procedure.
         




procedure frame-pendente.
find liped_pend where recid(liped_pend) = rec-pend no-lock. 
find pedid_pend of liped_pend no-lock.

def var tot-pedido      like liped.lipqtd    .
def var tot-atendido    like liped.lipqtd.

tot-pedido   = liped_pend.lipqtd.
tot-atendido = liped_pend.lipent.

    def var ped-tipo as char. 
    if pedid_pend.modcod = "PEDA"
    then ped-tipo = "Automatico".
    else if pedid_pend.modcod = "PEDM"
        then ped-tipo = "Manual".
        else if pedid_pend.modcod = "PEDR"
           then ped-tipo = "Reposicao".
           else if pedid_pend.modcod = "PEDE"
               then ped-tipo = "Especial".
               else if pedid_pend.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if pedid_pend.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if pedid_pend.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if pedid_pend.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if pedid_pend.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if pedid_pend.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".
    find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                          tbgenerica.TGCodigo = pedid_pend.modcod
                          no-lock no-error.
    display 
            pedid_pend.etbcod label "Etb"   colon 15
            pedid_pend.pednum               colon 15
            pedid_pend.peddat               colon 15
            pedid_pend.sitped label "Sit"   colon 15
            ped-tipo format "x(20)" label "Tipo" colon 15
            pedid_pend.pendente format "Pend/" no-label
            tot-pedido     format ">>>>>9"  label "Solic" colon 15
            tot-atendido   format ">>>>>9"  label "Atend" colon 15
            tot-atendido / tot-pedido * 100 format ">>9%" no-label 
            
            tbgenerica.tgint / 10 format ">>9" label "Prioridade"  colon 15
                              when tgint  <> 9999
            with frame frame-pendente centered color white/red row 5
                                  overlay side-label.
end procedure.

procedure tdcb-cod:
    dcb-cod = 0.
for each tdocbpro where
               /*tdocbpro.etbdes = liped.etbcod and*/
               tdocbpro.procod = liped.procod and
               tdocbpro.pednum = pedid.pednum
               no-lock,
    first tdocbase where
          tdocbase.dcbcod = tdocbpro.dcbcod and
          tdocbase.etbdes = liped.etbcod
          no-lock:    
    dcb-cod = tdocbase.dcbcod.           
end. 
end procedure.
