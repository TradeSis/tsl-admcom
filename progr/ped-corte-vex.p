/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}

/** 16/05/2017 - #1 Projeto Moda no ecommerce **/
/** 30/05/2017 - #2 Projeto moda no ecommerce, nao validar ws */
/** 31/05/2017 - #3 Projeto Moda no ecommerce, se for ecommerce, rodara interface para moda, e dentro da interface somente ira exportar produtos nmoda. a interface para moveis nao ira exportar produtos moda. */
/** 19/01/2018 - #4 Vex Moda */
/** 23/10/2018 - #5 Quantidade conjunto alteração para quantidade de itens */

{admcab.i} 

def var vmoda_ecommerce as log . /* #1 */
setbcod = 900.

def buffer xprodu for produ.
def new shared var vALCIS-ARQ-ORDVH   as int.
def buffer fliped for com.liped. 
def buffer fpedid for com.pedid.
def var par-pednum like pedid.pednum.

def temp-table ttconj
         field procod   like produ.procod
         field qtd      as   dec
         field conj-qtd like conjunto.qtd
         index pro is primary unique procod.

def temp-table tt-pav
    field etbcod like tdocbase.etbdes
    field desti  like tdocbase.etbdes
    field endpav like  tdocbpro.endpav
    index ipav is primary unique etbcod desti endpav.

def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int
    field prioridade    as int format "->>>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .

def temp-table tt_pend
    field rec as recid.            

def var vprocod like produ.procod.
def var vestoq_depos    as int format "->>>>>9".
def var vreservas       as int format "->>>>>9".
def var vdisponivel     as int format "->>>>>9".
def var tot-pedido      like liped.lipqtd    .
def var tot-atendido    like liped.lipqtd.

def temp-table ttsit
    field rec               as recid
    field Est_deposito      like vestoq_depos 
    field Est_reserv        like vreservas
    field Est_disponivel    like vdisponivel
    field Est_atende        like tt-reservas.atende
    field prioridade        like tt-reservas.prioridade
    field dtcorte           as date
    field hrcorte           as int
    .
    
def var v-box like tab_box.box.

def var vbox-num like tab_box.box.
def new shared temp-table tt-estab
    field etbcod    like ger.estab.etbcod
    field Ordem     as int
    field sim       as log init yes
    index ordem ordem asc.

def buffer btdocbase for tdocbase. 
def var vnumero like tdocbase.dcbnum.
def var vdcbcod like tdocbase.dcbcod. 
def var vmovseq as int. 
def var recpla  as recid. 
def var recmov  as recid.
 
def buffer bbliped for com.liped.

def temp-table tt-ped
    field etbcod like com.pedid.etbcod
    field pedtdc like com.pedid.pedtdc
    field pednum like com.pedid.pednum
    field peddat like com.pedid.peddat
    index i-pu-etb-tdc-num is primary unique etbcod
                                             pedtdc
                                             pednum.

def var wdisp       as int.
def buffer cpedid for com.pedid.
def buffer xliped for com.liped.
def buffer bestab for ger.estab.
/*def var wreserva  like com.estoq.estatual.*/
def buffer xpedid for com.pedid.
def var vmanual as log.
def var vpedtdc like com.pedid.pedtdc.
def var vetbped like ger.estab.etbcod.
def var vnumped like com.pedid.pednum.
def var vsitped like com.pedid.sitped.
def var vproped like com.liped.procod.
def var vetbcod like ger.estab.etbcod.

def var vtty as char format "x(40)". 
unix silent value("tty > log.tty" ). 
input from ./log.tty. 
repeat. 
    import vtty. 
end. 
input close.

def var west like com.estoq.estatual format "->>>,>>9".

def var vqtdped as int.

def temp-table wroma
    field pednum  like com.liped.pednum
    field procod  like com.produ.procod
/*    field reserva like com.estoq.estatual*/
    field pronom  like com.produ.pronom
    field lipcor  like com.liped.lipcor
    field west    like com.estoq.estatual format "->>>,>>9"
    field wped    like com.estoq.estatual
    field setcod  like setdep.setcod
    field setnom  like setdep.setnom
    field ordimp  like setdep.ordimp
    
    field desti   like com.plani.desti
    field etbcod  like com.plani.etbcod
    /*field endpav  like wbsender.endpav 
    field endrua  like wbsender.endrua 
    field endnum  like wbsender.endnum 
    field endand  like wbsender.endand
    */
    field rec-liped as recid
    index i1 procod desti pednum rec-liped
    .
    
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [   " Procura ",
                "Tarefa Box",
                " Tarefa ",
                " Consulta ",
                " Filtrar "].

def var esqcom2         as char format "x(12)" extent 5
            initial ["  "," ","","",""].

def buffer bpedid       for com.pedid.

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

def temp-table tt-pendente like com.liped
        field modcod like com.pedid.modcod
        field vencod like com.pedid.vencod.

def var v-etbcod like estab.etbcod.
def var v-pednum like pedid.pednum.

bl-princ:
repeat:
    assign vpedtdc = 95.
    status default "Situacao [E]mitido [L]istado [F]echado".
    pause 0. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find com.pedid where recid(pedid) = recatu1 no-lock.
        
    if not available com.pedid
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(pedid).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available com.pedid
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
            find com.pedid where recid(pedid) = recatu1 no-lock.

            /*status default*/

            run color-message.
            
            choose field com.pedid.pednum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
                      
            run color-normal.
            
            /*status default "".*/

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
                    if not avail com.pedid
                    then leave.
                    recatu1 = recid(pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail com.pedid
                    then leave.
                    recatu1 = recid(pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail com.pedid
                then next.
                color display white/red com.pedid.pednum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail com.pedid
                then next.
                color display white/red com.pedid.pednum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form com.pedid
                 with frame f-pedid color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = "Tarefa Box"
                then do:

                    view frame frame-a. pause 0.

                    sresp = yes. 
                    if not sresp
                    then leave. 
                    vmanual = no.
                    par-pednum = 0.
                    /***
                    Voutput to /admcom/logs/log-corte-cnt-mix.log.
                    put "#INICIO;" string(today) ";" string(time) ";" skip.
                    put "#FILIAL;0;" skip. 
                    output close.
                    ***/
                    
                    run p-gera-tarefa-box (vmanual).
                    
                    /***
                    output to /admcom/logs/log-corte-cnt-mix.log append.
                    put "#FIM;" string(today) ";" string(time) ";" skip.
                    output close.
                    ***/
                    leave bl-princ.

                end.

                if esqcom1[esqpos1] = " Procura "
                then do:
                    view frame frame-a. pause 0.
                    run p-procura.                  
                    leave.
                end.

                if esqcom1[esqpos1] = " Tarefa "
                then do:
                    view frame frame-a. pause 0.
                    /*
                    update v-box label "Box" 
                           with frame f-imp-box2 centered row 8 side-labels
                           overlay.
                    
                    update v-etbcod label "Filial"
                           v-pednum label "Pedido"
                           with frame f-imp-box2 
                           .
                    */       
                    
                    sresp = yes.
                    message "Confirma a geracao das tarefas do pedido "
                            pedid.pednum " ? " update sresp.
                    if not sresp
                    then leave.

                    if pedid.pednum < 100000 
                    then vmanual = yes. 
                    else vmanual = no.

                    /* solicitacao 30191  possibilidade de 
                        corte somente de um pedido */
                    vmanual = yes.
                    
                    par-pednum = pedid.pednum.
                    v-pednum = pedid.pednum.
                    v-etbcod  = pedid.etbcod.
                    /***
                    output to /admcom/logs/log-corte-cnt-mix.log.
                    put "#INICIO;" string(today) ";" string(time) ";" skip.
                    put "#FILIAL;" string(pedid.etbcod) ";" skip.
                    output close.
                    ***/
                    run p-gera-tarefa-box (vmanual).
                    
                    v-pednum = 0.
                    v-etbcod = 0.
                    
                    /***
                    message "Tarefa gerada com sucesso.".
                    pause 3 no-message. 
                    hide message no-pause.

                    output to /admcom/logs/log-corte-cnt-mix.log append.
                    put "#FIM;" string(today) ";" string(time) ";" skip.
                    output close.
                    ***/
                    
                    leave bl-princ.
                end.

                if esqcom1[esqpos1] = " Consulta "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
        
                    run wmscorte2_consulta_wms.p (recid(pedid)).

                    leave.
                end.
                
                if esqcom1[esqpos1] = " Filtrar "
                then do:
                    view frame frame-a. pause 0.

                    run p-filtro.
                    
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.
                end.
                leave.

                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Exclusao "
                then do: 
                    /*hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.*/
                    view frame frame-a. pause 0.

                        run p-exclui.

                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0. 
                    
                    leave.
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
        recatu1 = recid(pedid).
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

    def var vhora as char format "x(5)".
    def var ped-tipo as char. 

def temp-table tt-docbase like tdocbase.

for each tt-estab:
    for each tdocbase where 
         tdocbase.tdcbcod = "ROM" and
         tdocbase.situacao = "A" and
         tdocbase.etbdes = tt-estab.etbcod
         :
        find first tdocbpro of tdocbase no-lock no-error.
        if not avail tdocbpro 
        then do on error undo:
            delete tdocbase.
        end.
        else do:
            create tt-docbase.
            buffer-copy tdocbase to tt-docbase.
        end.
    end.
end.

for each tt-docbase :
    find tdocbase where tdocbase.dcbcod = tt-docbase.dcbcod no-error.
    if avail tdocbase
    then do:
        /* #3 */ 
       
        /**
        find estab where estab.etbcod = tdocbase.etbdes no-lock.
        if estab.tipo = "E-commerce"
        then do:
            run dstrh-moda.p  (recid(tdocbase)).
        end.    
        run ordvh-moveis.p(recid(tdocbase), "NORM").
        **/
        run ordvh-moveis-vexm.p(recid(tdocbase), "VEXM").
        /* #3 */
    end.        
    delete tt-docbase.
end. 

  
procedure frame-a.
    def var v-tgint as int.
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
                                else if com.pedid.modcod = "VEXM"
                                  then ped-tipo = "VEX Moda".  
    find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                          tbgenerica.TGCodigo = com.pedid.modcod
                          no-lock no-error.
    if avail tbgenerica
    then assign
            ped-tipo = tbgenerica.tgdescricao
            v-tgint  = tbgenerica.tgint.

    tot-pedido   = 0.
    tot-atendido = 0.
    for each liped of pedid no-lock.
        find produ where produ.procod = liped.procod no-lock no-error.
        if not avail produ then next.                                                
        if produ.proipiper = 98 then next.                               
                         
        tot-pedido = tot-pedido + com.liped.lipqtd.
    
    end.
    find first tab_box where tab_box.etbcod = pedid.etbcod    no-lock no-error.
    find first liped of pedid no-lock no-error. 
    vhora = "".
    if avail liped
    then vhora = string(liped.prehr,"HH:MM").
    display tab_box.box when avail tab_box
            com.pedid.etbcod column-label "Etb"
            com.pedid.pednum 
            com.pedid.peddat 
            vhora  label "Hora"
            com.pedid.sitped column-label "S"
            ped-tipo format "x(20)" column-label "Tipo"
            com.pedid.pendente format "Pend/" no-label
            tot-pedido     format ">>>>>>"  column-label "Qtd Total"
            /*tbgenerica.tgint*/ v-tgint / 10
             format ">>>" label "Pri"
                              when v-tgint  <> 9999
            with frame frame-a 11 down centered color white/red row 5
                                  overlay.
end procedure.
procedure color-message.
    color display message com.pedid.etbcod 
                          com.pedid.pednum vhora
                          com.pedid.peddat ped-tipo   tab_box.box
                          com.pedid.sitped  com.pedid.pendente tot-pedido
                          with frame frame-a.
end procedure.
procedure color-normal.
    color display normal com.pedid.etbcod   com.pedid.pendente tot-pedido
                         com.pedid.pednum       vhora
                         com.pedid.peddat ped-tipo
                         com.pedid.sitped   tab_box.box
                         with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  do:
    if esqascend  
    then  do:
        if vsitped = "" and
           vetbped = 0 and
           vproped = 0
        then
            find first com.pedid where com.pedid.pedtdc = vpedtdc 
                               and com.pedid.sitped <> "R" 
                               and com.pedid.sitped <> "F"
                               and com.pedid.sitped <> "C" 
                               and com.pedid.peddat > today - 45
                               and com.pedid.modcod = "VEXM"
                               no-lock no-error.
        else 
            find first com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VEXM"
                             no-lock no-error.
        
    end.    
    else do: 

        if vsitped = "" and
           vetbped = 0 and
           vproped = 0
        then
            find last com.pedid where com.pedid.pedtdc = vpedtdc 
                              and com.pedid.sitped <> "R" 
                              and com.pedid.sitped <> "F" 
                              and com.pedid.sitped <> "C" 
                              and com.pedid.peddat > today - 45
                              and com.pedid.modcod = "VEXM"
                              no-lock no-error.
        else
            find last com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VEXM"
                             no-lock no-error.
        
    end.
end.    
                                         
                                         
if par-tipo = "seg" or par-tipo = "down" 
then  do:
    if esqascend  
    then do:
      
        if vsitped = "" and vetbped = 0 and vproped = 0
        then
            find next com.pedid where com.pedid.pedtdc = vpedtdc 
                              and com.pedid.sitped <> "R" 
                              and com.pedid.sitped <> "F" 
                              and com.pedid.sitped <> "C" 
                              and com.pedid.peddat > today - 45
                              and com.pedid.modcod = "VEXM"
                              no-lock no-error.
        else
            find next com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VRXM"
                             no-lock no-error.
    end.        
    else  do:
    
        if vsitped = "" and vetbped = 0 and vproped = 0
        then
            find prev com.pedid where com.pedid.pedtdc = vpedtdc 
                              and com.pedid.sitped <> "R" 
                              and com.pedid.sitped <> "F" 
                              and com.pedid.sitped <> "C" 
                              and com.pedid.peddat > today - 45
                              and com.pedid.modcod = "VEXM"
                              no-lock no-error.
        else
            find prev com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VEXM"
                             no-lock no-error.
    end.
            
end.             

if par-tipo = "up" 
then do:
    if esqascend   
    then do:  
        
        if vsitped = "" and vetbped = 0 and vproped = 0
        then
            find prev com.pedid where com.pedid.pedtdc = vpedtdc 
                              and com.pedid.sitped <> "R" 
                              and com.pedid.sitped <> "F" 
                              and com.pedid.sitped <> "C" 
                              and com.pedid.peddat > today - 45
                              and com.pedid.modcod = "VEXM"
                              no-lock no-error.
        else
            find prev com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VEXM"
                             no-lock no-error.
    end.        
    else do:  
        
        if vsitped = "" and vetbped = 0 and vproped = 0
        then
            find next com.pedid where com.pedid.pedtdc = vpedtdc 
                              and com.pedid.sitped <> "R" 
                              and com.pedid.sitped <> "F" 
                              and com.pedid.sitped <> "C" 
                              and com.pedid.peddat > today - 45
                              and com.pedid.modcod = "VEXM"
                              no-lock no-error.
        else
            find next com.pedid where com.pedid.pedtdc = vpedtdc
                        and (if vsitped <> ""
                             then com.pedid.sitped = vsitped else true)
                             and com.pedid.peddat > today - 45
                             and com.pedid.modcod = "VEXM"
                             no-lock no-error.
    end.        

end.
        
end procedure.

procedure p-filtro: 
    
    update skip(1)
           /*space(3) vetbped label "Filial"   space(3)
           space(3) vnumped label "Pedido"   space(3)*/
           space(3) vsitped at 2 label "Situacao" space(3)
           /*space(3) vproped at 3 label "Produto" space(3)*/
           skip(1)
           with frame f-sit side-labels overlay centered row 8
                        title " Filtro ".
           
    if vsitped = "R" 
    then vsitped = "".  
    
    recatu1 = ?.
    
end procedure.

procedure p-procura: 
    def var p-pednum like pedid.pednum.
    p-pednum = 0.
    update skip(1)
           space(3) vetbcod label "Filial" space(3)
           skip(1)
           skip(1)
           space(3) p-pednum label "Pedido" space(3)
           skip(1)
           with frame f-procura side-label centered overlay 
                                row 8 title " Procura ". 
    
    if vsitped = "" 
    then find first com.pedid where com.pedid.pedtdc = vpedtdc 
                            and com.pedid.sitped <> "R"    
                            and com.pedid.sitped <> "F"
                            and com.pedid.sitped <> "C"
                            and com.pedid.etbcod = vetbcod 
                            and (if p-pednum <> 0
                                 then com.pedid.pednum = p-pednum
                                 else true)
                            no-lock no-error.
    else find first com.pedid where com.pedid.pedtdc = vpedtdc 
                            and com.pedid.sitped = vsitped 
                            and com.pedid.etbcod = vetbcod 
                            and (if p-pednum <> 0
                                 then com.pedid.pednum = p-pednum
                                 else true)
                            no-lock no-error.
                                      
    if avail com.pedid 
    then recatu1 = recid(pedid).
    else recatu1 = ?.
    
end procedure.

procedure p-exclui:  
    
    message "Confirma Exclusao de" com.pedid.pednum update sresp. 
    if not sresp 
    then leave.
    
    find next com.pedid where com.pedid.pedtdc = vpedtdc 
                               and com.pedid.sitped <> "R" 
                               and com.pedid.sitped <> "F"
                               and com.pedid.sitped <> "C" no-error. 
    
    if not available com.pedid 
    then do: 
        find com.pedid where recid(pedid) = recatu1. 
        find prev com.pedid where com.pedid.pedtdc = vpedtdc 
                               and com.pedid.sitped <> "R" 
                               and com.pedid.sitped <> "F"
                               and com.pedid.sitped <> "C" no-error. 
    end. 
    
    recatu2 = if available com.pedid 
              then recid(pedid) 
              else ?. 
    
    find com.pedid where recid(pedid) = recatu1.
                    
    for each com.liped of com.pedid where com.liped.predt = com.pedid.peddat:
        com.liped.lipsit = "R". 
        if com.pedid.pednum >= 500000 
        then do: 
            find com.estoq where com.estoq.etbcod = setbcod 
                         and com.estoq.procod = com.liped.procod. 
                 com.estoq.estpedcom = com.estoq.estpedcom - com.liped.lipqtd. 
        end. 
    end.
    
    com.pedid.sitped = "R". 
    recatu1 = recatu2. 
    leave.

end procedure.

procedure p-consulta:  
    
    display com.pedid.etbcod 
            com.pedid.pednum with frame f-tit centered side-label 
                                    color black/cyan row 4.

    for each com.liped of com.pedid where 
                          com.liped.predt = com.pedid.peddat no-lock:
        find com.produ where com.produ.procod = com.liped.procod no-lock. 
        if produ.proipiper = 98 then next.
        disp com.liped.procod 
             com.produ.pronom format "x(25)" 
             com.liped.lipcor format "x(15)" 
             com.liped.lipqtd column-label "Qtd.P" format ">>>9" 
             com.liped.lipent column-label "Qtd.E" format ">>>9" 
             com.liped.lipsit 
             with frame f-con 10 down row 7 centered 
                              color black/cyan title " com.produtos ".
    end. 
    pause.

end procedure.
form
    with centered frame fcorte down.

def temp-table tt-tipoped no-undo
    field marca as char
    field codigo as char
    field nome   as char
    index i1 codigo.

procedure p-gera-tarefa-box:
def input parameter vmanual as log.

def var p-produtos as char.

form
    with centered frame fcorte.
for each tt-estab.
      delete tt-estab.
end.
def buffer bx-pedido for pedid.
/*          
if v-etbcod > 0 
then do:     
    find first tab_box where
               tab_box.etbcod = v-etbcod no-lock no-error.
    if not avail tab_box
    then undo.
    vbox-num = tab_box.box.
    create tt-estab.
    assign
        tt-estab.etbcod = tab_box.etbcod
        tt-estab.ordem  = tab_box.ordem
        tt-estab.sim = yes.           
end.
else*/ do:      
    vbox-num = 99.
    update vbox-num label "Box" 
           with frame f-imp-box centered row 8 side-labels overlay.
                       
    if vbox-num = 0
    then return.

    for each bx-pedido where
             bx-pedido.pedtdc = 95 and
             bx-pedido.sitped = "E" and
             bx-pedido.modcod = "VEXM" and
             (if par-pednum > 0
              then bx-pedido.pednum = par-pednum else true)
             no-lock:
      find first tt-estab where
                 tt-estab.etbcod = bx-pedido.etbcod
                 no-error.
      if not avail tt-estab
      then do:           
        create tt-estab. 
        assign tt-estab.etbcod = bx-pedido.etbcod 
             tt-estab.ordem  = 1
             tt-estab.sim = yes. 
      end.
    end.
      /*
    run wbsseletb.p .

    for each tt-estab.
        if tt-estab.sim = no
        then do.
            delete tt-estab.
            next.
        end.
        disp tt-estab except sim.
    end.
    */
    find first tt-estab where tt-estab.sim = yes no-error.
    /*
    if avail tt-estab 
    then do:
        {seltipoped.i f-linha down row 7 column 30}.
    end.    
    for each tt-tipoped where tt-tipoped.marca = "".
        delete tt-tipoped.
    end.    
    */

    for each tbgenerica where tbgenerica.TGTabela = "TP_PEDID" 
                        and tbgenerica.tgcodigo = "VEXM"
                        no-lock:
        create tt-tipoped.
        assign
            tt-tipoped.marca  = "*"
            tt-tipoped.codigo = tbgenerica.TGCodigo
            tt-tipoped.nome   = tbgenerica.tgdescricao
            .
    end.
    find first tt-tipoped where tt-tipoped.marca = "*"  no-error.
    if not avail tt-tipoped then leave.
end.
  

find first tt-estab where tt-estab.sim = yes no-error.
if not avail tt-estab then leave.                     

  def var log-qtd-registros as int.
  log-qtd-registros = 0.
  
  def var log-inicio as int.
  log-inicio = time.

  output to /admcom/logs/log-corte-WMS2.log append. 
  put unformatted 
    "
    
    #TERMINAL;" string(VTTY) ";" SKIP.
  put unformatted 
    "#INICIO;" string(today) ";" string(log-inicio,"HH:MM:SS") ";" skip .
  put unformatted 
    "#FILIAL;" .
  for each tt-estab no-lock break by tt-estab.ordem.
    put unformatted 
        tt-estab.etbcod ";" .
  end.
  put skip.
  put unformatted 
"------------------------------------------------------------------------------"     skip(1).
  output close.

/***LOG BLOQUEIO PEDIDO AUTOMATICO***/
output to /admcom/logs/log-corte-cnt-mix.log.
put "#INICIO;" string(today) ";" string(time) ";" skip.
put "#FILIAL;0;" skip. 
output close.
/***             ***/
  
  def var vqt as int.
  
  pause 0.   
  def var p-conecta as log.
  for each tt-estab no-lock break by tt-estab.ordem:
     hide message no-pause.
     for each tt-ped. delete tt-ped. end.
     for each wroma. delete wroma. end.
     for each tt-pendente: delete tt-pendente. end.

     find ger.estab where ger.estab.etbcod = tt-estab.etbcod no-lock no-error.
     disp tt-estab.etbcod 
          ger.estab.etbnom format "x(20)"
          string(time,"hh:mm:ss")
            with  frame fcorte .
                
     pause 0.
     vqt = 0.
     do:
            def var par-numcod as int.
            /*
            par-numcod = next-value(SeqDocbase).
            */
            run tdocbase-dcbcod.p(output par-numcod).
            
            def var rec1 as recid.
            def var rec_981 as recid.
            do on error undo.
                create  tdocbase.
                ASSIGN  tdocbase.dcbcod    = par-numcod
                        
                        tdocbase.geraraut   = no
                        
                        tdocbase.dcbnum    = par-numcod
                        tdocbase.tdcbcod   = "ROM"
                        tdocbase.chave-ext = ? 
                        tdocbase.DtDoc     = today
                        tdocbase.DtEnv     = today
                        tdocbase.HrEnv     = time
                        tdocbase.Etbdes    = tt-estab.etbcod
                        tdocbase.plani-etbcod = ?
                        tdocbase.box  = vbox-num
                        tdocbase.RomExterno     = no
                        tdocbase.ordem = tt-estab.ordem
                        tdocbase.plani-placod = ?.

                
                /*  gravar o tty do usuário    */  
                tdocbase.cod_barra_nf = string(tdocbase.dcbnum) + "_" +
                                          string(sfuncod)           + "_" +
                                          vtty.  
                if tt-estab.etbcod = 200 
                then do. 
                    tdocbase.Ecommerce = yes.
                    tdocbase.clfcod    = ?.
                end.                
                vmovseq = 0. 
                rec1 = recid(tdocbase).
            end.
            
     end.     
       
         
     p-conecta = yes.
     for each xpedid where xpedid.etbcod = ger.estab.etbcod 
                       and xpedid.pedtdc = com.pedid.pedtdc 
                       and xpedid.sitped = "E" 
                       and xpedid.peddat >= today - 45 
                       and xpedid.peddat <= today 
                       and xpedid.modcod = "VEXM"
                       no-lock:

        if vmanual   
        then if xpedid.pednum <> par-pednum  
             then next.

        if not vmanual 
        then do:  
            find first tt-tipoped where
                       tt-tipoped.codigo = xpedid.modcod
                       no-error.
            if not avail tt-tipoped
            then next.           
        end.

         def var cont as int.
         cont = 0.
         p-produtos = "".
         for each com.liped of xpedid no-lock.
            find xprodu where xprodu.procod = liped.procod no-lock no-error.
            if not avail produ then next.
            
            if xpedid.etbcod = 200 and
               xprodu.proipival = 1
            then next.   
            /* #2 #4 */
            if xprodu.catcod = 41 and not xprodu.ind_vex 
            then next.
            /* #2 #4 */
            
            cont = cont + 1.
            
            if p-produtos = ""
            then p-produtos = string(com.liped.procod).
            else p-produtos = p-produtos + ";" + string(com.liped.procod).
         end.
         if cont = 0 then next.
         
         sresp = yes.
         if p-produtos <> "" and p-conecta /*and pedid.etbcod <> 189*/
         then do:
            /****
            run WS_Alsis_produto.p(input setbcod,
                                    input xpedid.pednum,
                                    input p-produtos,
                                    output p-conecta,
                                    output sresp).
            ****/
         end.
         if not sresp then do:
            next.
         end.
         for each com.liped where com.liped.pedtdc = xpedid.pedtdc 
                          and com.liped.etbcod = xpedid.etbcod 
                          and com.liped.pednum = xpedid.pednum 
                          and com.liped.predt  = xpedid.peddat no-lock:

             find com.produ where com.produ.procod = com.liped.procod 
                                                no-lock no-error.

             if produ.proipiper = 98 or
                (xpedid.etbcod = 200 and
                 produ.proipival = 1)
             then do:
                next.
             end.
             
             {tbcntgen6.i xpedid.peddat}
             if avail tbcntgen
             then do:
                next.
             end.             
             
             west = 0. 
             
             find com.estoq where com.estoq.etbcod = setbcod 
                                   and com.estoq.procod = com.produ.procod
                                       no-lock no-error.
             if avail com.estoq 
             then west = com.estoq.estatual. 
             
             for each tt-reservas.
                delete tt-reservas.
             end.
             vqt = vqt + 1.
             run corte_disponivel_vexm.p (input  produ.procod, 
                                     output vestoq_depos, 
                                     output vreservas,  
                                     output vdisponivel). 
             
             find first tt-reservas where 
                        tt-reservas.rec_liped = recid(com.liped)
                                        no-error.

             if com.liped.etbcod = 200 and
                tt-reservas.atende > com.liped.lipqtd 
             then tt-reservas.atende = com.liped.lipqtd.

             if vestoq_depos <= 0 and com.liped.etbcod <> 200
             then tt-reservas.atende = 0.

             create ttsit.
             assign ttsit.rec               = recid(com.liped)
                    ttsit.Est_deposito      = vestoq_depos
                    ttsit.Est_reserv        = vreservas
                    ttsit.Est_disponivel    = vdisponivel
                    ttsit.Est_atende        = if avail tt-reservas
                                              then tt-reservas.atende
                                              else 0
                    ttsit.prioridade        = if avail tt-reservas
                                              then tt-reservas.prioridade
                                              else ? 
                    ttsit.dtcorte           = today
                    ttsit.hrcorte           = time          .
                    
             if not avail tt-reservas
             then do:
                next.
             end.   

             if (tt-reservas.atende = 0 and cont = 1) 
             then do on error undo. 
                create tt_pend.
                assign tt_pend.rec = recid(com.liped). 
                next.
             end.   
             
                 find first tt-ped where tt-ped.etbcod = com.liped.etbcod
                               and tt-ped.pedtdc = com.liped.pedtdc
                               and tt-ped.pednum = com.liped.pednum no-error.
                 if not avail tt-ped
                 then do:
                     create tt-ped.
                     assign tt-ped.etbcod = com.liped.etbcod
                            tt-ped.pedtdc = com.liped.pedtdc
                            tt-ped.pednum = com.liped.pednum
                            tt-ped.peddat = com.liped.predt.
                 end.
                 
                 find com.produ where 
                    com.produ.procod = com.liped.procod no-lock no-error.

                 find first wroma where wroma.procod = com.produ.procod 
                                    and wroma.desti  = com.liped.etbcod 
                                    and wroma.pednum = com.liped.pednum 
                                    /* ecommerce */
                                    and wroma.rec-liped =
                                            (if com.liped.etbcod = 200
                                             then recid(com.liped)
                                             else recid(com.liped))   
                                                       no-error.
                 if not avail wroma 
                 then do:  
                     create wroma. 
                     assign wroma.procod  = com.produ.procod 
                            wroma.desti   = com.liped.etbcod

                            /* ecommerce */
                            wroma.rec-liped =
                                            (if com.liped.etbcod = 200
                                             then recid(com.liped)
                                             else recid(com.liped))

                            wroma.pronom  = com.produ.pronom 
                            wroma.pednum  = com.liped.pednum 
                            wroma.lipcor  = string(liped.lipcor,"x(30)") 
                            wroma.wped    = if wdisp >= com.liped.lipqtd
                                            then com.liped.lipqtd  
                                            else wdisp
                            wroma.west    = west
                            wroma.wped = tt-reservas.atende.
                    
                 end. 
                 else do: 
                     
                     assign wroma.wped = wroma.wped + 
                                            (if wdisp >= com.liped.lipqtd
                                             then com.liped.lipqtd 
                                             else wdisp)
                            wroma.west = wroma.west + west
                            wroma.wped = tt-reservas.atende.
                     
             end.
                 
             find first bbliped where bbliped.etbcod = com.liped.etbcod
                            and bbliped.pedtdc = com.liped.pedtdc 
                            and bbliped.pednum = com.liped.pednum 
                            and bbliped.procod = com.liped.procod 
                            and bbliped.lipcor = string(liped.lipcor,"x(30)") 
                            and bbliped.predt  = com.liped.predt no-error.
             if avail bbliped 
             then do:  
                assign bbliped.lipent = if wdisp >= com.liped.lipqtd
                                        then com.liped.lipqtd  
                                        else wdisp.
                       /* alterado em 08/11/2013 */
                       bbliped.lipent  = tt-reservas.atende.

             end.
         end.
     end.
     for each tt-pav:  
         delete tt-pav.
     end.
     
     for each wroma where wroma.wped > 0 no-lock by wroma.etbcod
                                                  by wroma.desti 
                                                  /*by wroma.endpav*/:
     
        find first tt-pav where tt-pav.etbcod = wroma.etbcod
                      and tt-pav.desti  = wroma.desti 
                      no-error.
        if not avail tt-pav
        then do:
            create tt-pav.
            assign tt-pav.etbcod = wroma.etbcod
                   tt-pav.desti  = wroma.desti 
                     .
        end.

     end.
     
     for each wroma where wroma.wped > 0
                    break by wroma.pednum.
        find tdocbase where recid(tdocbase) = rec1 no-lock.
        
        find first conjunto where 
             conjunto.procod = wroma.procod no-lock no-error.
        if avail conjunto
        then wroma.wped = wroma.wped /**#5 * conjunto.qtd #5**/.

        /*if avail conjunto and conjunto.qtd > 1 and
                tdocbase.ecommerce = no
        then do.
            find first tdocbpro of tdocbase where
                        tdocbpro.procod  = wroma.procod 
                            no-error.
            if not avail tdocbpro
            then do.
                create  tdocbpro.
                log-qtd-registros = log-qtd-registros + 1.
                vmovseq = vmovseq + 1.
                tdocbpro.dcbcod  = tdocbase.dcbcod .
                tdocbpro.dcbpseq = vmovseq. 
                tdocbpro.etbdes  = tdocbase.etbdes.         
            end.
        end.
        else*/ do:
            create  tdocbpro.
            log-qtd-registros = log-qtd-registros + 1.
            vmovseq = vmovseq + 1.
            tdocbpro.dcbcod  = tdocbase.dcbcod. 
            tdocbpro.dcbpseq = vmovseq.          
            tdocbpro.etbdes  = tdocbase.etbdes.
        end.

        ASSIGN  
                tdocbpro.predt   = today
                tdocbpro.campo_int3 = wroma.desti  /* estab do pedido */
                tdocbpro.procod  = wroma.procod 
                tdocbpro.movqtm  = /*#5 if avail conjunto and conjunto.qtd > 1
                                            and tdocbase.ecommerce = no
                                     then tdocbpro.movqtm + wroma.wped
                                     else #5*/ wroma.wped
                /*tdocbpro.endpav = if avail wbsprodu
                                    then wbsprodu.endpav
                                    else ?*/
                tdocbpro.pednum  = /*#5 if avail conjunto and conjunto.qtd > 1
                                     then ? 
                                     else#5*/ wroma.pednum.
        if tdocbpro.movqtm > 0
        then do on error undo.
            find fliped where recid(fliped) = wroma.rec-liped .
            find fpedid of fliped .
            fliped.lipsit = "L". 
            fpedid.sitped = "L".
        end.
        pause 0.
        pause 0.
        if tdocbase.ecommerce
        then do.
            find fliped where recid(fliped) = wroma.rec-liped .
            find fpedid of fliped .
            tdocbpro.Ecommerce     = yes.
            tdocbpro.pednum        = wroma.pednum.
            tdocbpro.clfcod        = fpedid.clfcod.
            tdocbpro.pedtdc        = fpedid.pedtdc.
            tdocbpro.tipofrete     = "CIF".
            tdocbpro.frecod        = fpedid.frecod. 
            tdocbpro.predt         = fliped.predt.
            tdocbpro.Obriga-imei   = no.
            fliped.lipsit = "L".
            fpedid.sitped = "L".
            def var vreserv_ecom as dec.
            vreserv_ecom = 0.
            for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.tipo          = "ECOM"        and
                     prodistr.procod        = tdocbpro.procod and
                     prodistr.predt        <= today         and 
                     prodistr.SimbEntregue >= today no-lock.
                vreserv_ecom = vreserv_ecom + 
                            (prodistr.lipqtd - prodistr.preqtent).
            end.
            if vreserv_ecom > 0
            then do.
                for each prodistr where 
                         prodistr.etbabast      = 200           and
                         prodistr.tipo          = "ECOM"        and
                         prodistr.procod        = tdocbpro.procod and
                         prodistr.predt        <= today         and 
                         prodistr.SimbEntregue >= today and
                         prodistr.lipqtd - prodistr.preqtent > 0
                         .
                    prodistr.preqtent = prodistr.preqtent + tdocbpro.movqtm.
                    if prodistr.preqtent > prodistr.lipqtd
                    then prodistr.preqtent = prodistr.lipqtd.
                    /* historico */
                    create hprodistr.
                    ASSIGN hprodistr.data     = today
                           hprodistr.hora     = time
                           hprodistr.procod   = prodistr.procod
                           hprodistr.lipqtd   = prodistr.lipqtd
                           hprodistr.lipsit   = prodistr.lipsit
                           hprodistr.preqtent = tdocbpro.movqtm
                           hprodistr.etbcod   = prodistr.etbcod
                           hprodistr.numero   = fpedid.pednum
                           hprodistr.etbabast = prodistr.etbabast
                           hprodistr.predt    = fpedid.peddat
                           hprodistr.lipseq   = prodistr.lipseq
                           hprodistr.Tipo     = prodistr.Tipo
                           hprodistr.EtbOri   = prodistr.EtbOri
                           hprodistr.movpc    = prodistr.movpc
                           hprodistr.proposta = "Pedido : " +
                                                    string(fpedid.pednum)
                           hprodistr.funcod   = prodistr.funcod.
                        pause 1 no-message.
                end.    
            end.
            else do:
                vreserv_ecom = 0.
                for each prodistr where 
                     prodistr.etbabast      = 200           and
                     prodistr.tipo          = "ECMA"        and
                     prodistr.procod        = tdocbpro.procod and
                     prodistr.predt        <= today         and 
                     prodistr.SimbEntregue >= today no-lock.
                    vreserv_ecom = vreserv_ecom + 
                            (prodistr.lipqtd - prodistr.preqtent).
                end.
                if vreserv_ecom > 0
                then do.
                for each prodistr where 
                         prodistr.etbabast      = 200           and
                         prodistr.tipo          = "ECMA"        and
                         prodistr.procod        = tdocbpro.procod and
                         prodistr.predt        <= today         and 
                         prodistr.SimbEntregue >= today and
                         prodistr.lipqtd - prodistr.preqtent > 0
                         .
                    prodistr.preqtent = prodistr.preqtent + tdocbpro.movqtm.
                    if prodistr.preqtent > prodistr.lipqtd
                    then prodistr.preqtent = prodistr.lipqtd.
                    /* historico */
                    create hprodistr.
                    ASSIGN hprodistr.data     = today
                           hprodistr.hora     = time
                           hprodistr.procod   = prodistr.procod
                           hprodistr.lipqtd   = prodistr.lipqtd
                           hprodistr.lipsit   = prodistr.lipsit
                           hprodistr.preqtent = tdocbpro.movqtm
                           hprodistr.etbcod   = prodistr.etbcod
                           hprodistr.numero   = fpedid.pednum
                           hprodistr.etbabast = prodistr.etbabast
                           hprodistr.predt    = fpedid.peddat
                           hprodistr.lipseq   = prodistr.lipseq
                           hprodistr.Tipo     = prodistr.Tipo
                           hprodistr.EtbOri   = prodistr.EtbOri
                           hprodistr.movpc    = prodistr.movpc
                           hprodistr.proposta = "Pedido : " +
                                                    string(fpedid.pednum)
                           hprodistr.funcod   = prodistr.funcod.
                        pause 1 no-message.
                end.    
                end.
            end.
            
            
            /* verifica produtos que precisam pedir IMEI na
               separacao por cliente */
            find produ of fliped no-lock no-error.
            if avail produ 
            then do.
                if produ.corcod = "PED" or 
                   produ.corcod = "CUP"    
                then do.   
                    if produ.pronom matches "*CHIP*"
                    then.
                    else do.
                        find first plaviv where plaviv.procod    = produ.procod
                                            and plaviv.exportado = yes
                                                no-lock no-error.
                        if avail plaviv
                        then do.  
                            tdocbpro.Obriga-imei   = yes.
                        end.
                    end.
                end.
            end.
        end.        
        
        find first peddocbpro where peddocbpro.dcbcod  = tdocbpro.dcbcod and
                                 peddocbpro.procod  = tdocbpro.procod and
                                 peddocbpro.etbdes  = tdocbase.Etbdes and
                                 peddocbpro.pednum  = wroma.pednum
                                 no-error.
        if not avail peddocbpro
        then create peddocbpro.
        ASSIGN peddocbpro.dcbcod  = tdocbpro.dcbcod 
               peddocbpro.procod  = tdocbpro.procod 
               peddocbpro.pednum  = wroma.pednum
               peddocbpro.movqtm  = wroma.wped
               peddocbpro.QtdCont = 0
               peddocbpro.etbdes  = tdocbase.Etbdes.
               
        find first nffped where nffped.forcod = setbcod               and 
                                  nffped.movndc = tdocbase.dcbcod     and 
                                  nffped.movsdc = string(tdocbase.Etbdes) and
                                  nffped.pednum = wroma.pednum
                                      no-lock no-error.  
        if not avail nffped  
        then do:     
            create nffped.                
            nffped.forcod = setbcod           . 
            nffped.movndc = tdocbase.dcbcod . 
            nffped.movsdc = string(tdocbase.Etbdes). 
            nffped.pednum = wroma.pednum      .
        end.
    end.

    for each ttconj.
        delete ttconj.
    end.        
    
    def var i-docbase as int.
    
    do i-docbase = 1 to 1 /*2*/:  /* i-docbase */
        if i-docbase = 1
        then find tdocbase where recid(tdocbase) = rec1    no-lock.
        else find tdocbase where recid(tdocbase) = rec_981 no-lock.
     
        /**** #5
        /* acumula produtos conjuntos */
        if tdocbase.ecommerce = no
        then do.
            for each tdocbpro of tdocbase no-lock,
                first conjunto where conjunto.procod = tdocbpro.procod no-lock.
                if avail conjunto and conjunto.qtd > 1 
                then do.
                    find first  ttconj where 
                                ttconj.procod = tdocbpro.procod no-error.
                    if not avail ttconj
                    then create ttconj.
                    assign ttconj.procod   = tdocbpro.procod
                       ttconj.qtd      = ttconj.qtd + tdocbpro.movqtm
                       ttconj.conj-qtd = conjunto.qtd.
                end.
            end.
         /* quando a quantidade for menor que a qtd conjunto envia o conjunto*/
            for each ttconj where ttconj.qtd < ttconj.conj-qtd.
                for each tdocbpro of tdocbase where
                        tdocbpro.procod = ttconj.procod.
                    for each peddocbpro of tdocbpro no-lock.
                        find com.pedid where pedid.etbcod = peddocbpro.etbdes
                                     and pedid.pedtdc = 95
                                     and pedid.pednum = peddocbpro.pednum 
                                     no-error.                    
                        find liped of pedid where 
                                liped.procod = tdocbpro.procod no-error.
                        if avail liped
                        then liped.lipent = ttconj.conj-qtd.
                    end.
                    tdocbpro.movqtm = ttconj.conj-qtd.
                end.
            end.
         
            def var ddec as dec.
            def var vai as dec.
            def var sobra as dec.     
            for each ttconj where ttconj.qtd > ttconj.conj-qtd.
                ddec    = truncate(ttconj.qtd / ttconj.conj-qtd,0).
                vai     = truncate(ttconj.qtd / ttconj.conj-qtd,0) *
                                    ttconj.conj-qtd.
                sobra   = ttconj.qtd - 
                        (truncate(ttconj.qtd / ttconj.conj-qtd,0) *
                                     ttconj.conj-qtd) .
                find first tdocbpro of tdocbase where
                            tdocbpro.procod = ttconj.procod no-error.        
                if avail tdocbpro
                then do.
                    tdocbpro.movqtm = vai.
                    for each peddocbpro of tdocbpro no-lock.
                        find com.pedid where pedid.etbcod = peddocbpro.etbdes
                                     and pedid.pedtdc = 95
                                     and pedid.pednum = peddocbpro.pednum 
                                     no-error.                    
                        find liped of pedid where 
                                liped.procod = tdocbpro.procod no-error.
                        if avail liped
                        then do.
                            sobra = sobra - liped.lipent.
                            liped.lipent = 0.
                        end.
                        if sobra <= 0 then leave.
                    end.
                end.
            end.
        end.
        #5 *****/
        
        def var recatu11 as recid.
        recatu11 = recid(tdocbase).
        find first tdocbpro of tdocbase no-lock no-error.
        if not avail tdocbpro and avail tdocbase
        then  do on error undo.
            find current tdocbase.
            delete tdocbase.
            recatu11 = ?.
        end.
        log-qtd-registros = 0.
        if avail tdocbase
        then 
            for each tdocbpro of tdocbase no-lock.
                log-qtd-registros = log-qtd-registros + 1.
            end.

        /*****
        if recatu11 <> ?
        then do.
            find tdocbase where recid(tdocbase) = recatu11 no-lock no-error.
            if avail tdocbase
            then run wbspavilhao.p (recatu11).
        end.
        ******/
     end.               /* i-docbase */
     
     for each tt-ped:
     
        find cpedid where cpedid.etbcod = tt-ped.etbcod  
                       and cpedid.pedtdc = tt-ped.pedtdc 
                       and cpedid.pednum = tt-ped.pednum no-error.
        if not avail cpedid then next.  
        
        for each com.liped of cpedid no-lock: 
        if com.liped.lipent < com.liped.lipqtd
        then do:
            find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                      tbgenerica.TGCodigo = cpedid.modcod 
                                      no-lock no-error.
            if tbgenerica.tglog
            then do.
                    create tt-pendente.
                    assign
                        tt-pendente.etbcod   = com.liped.etbcod 
                        tt-pendente.vencod   = cpedid.vencod
                        tt-pendente.pedtdc   = com.liped.pedtdc
                        tt-pendente.pednum   = com.liped.pednum
                        tt-pendente.procod   = com.liped.procod
                        tt-pendente.lipcor   = string(liped.lipcor,"x(30)")
                        tt-pendente.predt    = cpedid.peddat  /*today*/
                        tt-pendente.prehr    = com.liped.prehr
                        tt-pendente.lipqtd   = com.liped.lipqtd - 
                                                com.liped.lipent
                        tt-pendente.lippreco = com.liped.lippreco
                        tt-pendente.venda-placod = com.liped.venda-placod
                        tt-pendente.modcod   = cpedid.modcod.
             end.
         end.
         end.   
     end.
     for each ttsit.
        find liped where recid(liped) = ttsit.rec. 
        assign liped.Est_deposito   = ttsit.Est_deposito
               liped.Est_reserv     = ttsit.Est_reserv
               liped.Est_disponivel = ttsit.Est_disponivel
               liped.Est_atende     = ttsit.Est_atende
               liped.Prioridade     = ttsit.Prioridade
               liped.dtcorte        = ttsit.dtcorte
               liped.hrcorte        = ttsit.hrcorte .
        delete ttsit.
     end.
     for each tt_pend.
        find liped where recid(liped) = tt_pend.rec.  
        find pedid of liped no-lock.
        find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                              tbgenerica.TGCodigo = pedid.modcod 
                              no-lock no-error. 
        if tbgenerica.tglog
        then do on error undo:
            run criarepexporta.p ("LIPED_PENDENTE", 
                                  "INCLUSAO",   
                                  recid(liped)). 
            liped.pendente    = yes. 
            liped.PendMotivo  = "Produto sem estoque no CD para atender". 
            liped.lip_status  = "Ficou Pendente " + "[" +
                                                string(liped.pednum)
                                                + "]". 
            /*liped.lipsit = "F".
            */
        end.
        /*
        find first liped of pedid where liped.lipsit = "L" 
                            no-lock no-error.
        if not avail liped
        then do on error undo:
            find current pedid.
            pedid.sitped = "F".                    
        end.
        */
        delete tt_pend.

     end. 
     
     if today >= 10/13/2008
     then do:
        run cria-novo-pedido.
     end.
     disp string(time,"hh:mm:ss")
          vqt column-label "Itens!Proces"  
            with  frame fcorte .
     down with frame fcorte .    
end.
/***FIM LOG BLOQUEIO PEDIDO AUTOMATICO***/
output to /admcom/logs/log-corte-cnt-mix.log append.
put "#FIM;" string(today) ";" string(time) ";" skip.
output close.
/***            ***/

  def var vtty as char format "x(40)".
  unix silent value("tty > log.tty" ).
  input from ./log.tty.
  repeat.
      import vtty.
  end.
  input close.
  
  output to /admcom/logs/log-corte-WMS2.log append. 
  put unformatted 
    "#TERMINAL;" string(VTTY) ";" SKIP.
  put unformatted 
    "#INICIO;" string(today) ";" string(log-inicio,"HH:MM:SS") ";" skip .
  put unformatted 
    "#FINAL ;" string(today) ";" string(time,"HH:MM:SS") ";" skip .
  put unformatted
    "#TOTAL ;" string(time - log-inicio,"HH:MM:SS") skip.
  put unformatted 
    "#FILIAL;" .
  for each tt-estab no-lock break by tt-estab.ordem.
    put unformatted 
        tt-estab.etbcod ";" .
  end.
  put skip.
  put unformatted 
    "#QUANTIDADE DE REGISTROS;" + string(log-qtd-registros) ";" skip.
  put unformatted 
"#############################################################################" 
    skip(2).
  output close.

    message "Tarefa por Box gerada com sucesso.".
    pause 3 no-message.
    hide message no-pause.

end procedure.

procedure cria-novo-pedido:
    def var vpednum like com.pedid.pednum.
    def buffer btt-pendente for tt-pendente.
    def buffer bpedid for com.pedid.
    def buffer bliped for com.liped.
    def buffer nprodu for com.produ.
    def var v-pendente as log init no.
    for each tt-ped no-lock:
        v-pendente = no.
        for each tt-pendente where
                   tt-pendente.etbcod = tt-ped.etbcod and
                   tt-pendente.pedtdc = tt-ped.pedtdc and
                   tt-pendente.pednum = tt-ped.pednum and
                   tt-pendente.lipqtd > 0
                   no-lock .
            find first nprodu where
                       nprodu.procod = tt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then next.
            if nprodu.pronom matches "*RECARGA*" 
            then next.
            if nprodu.pronom matches "*FRETEIRO*" 
            then next.
            if nprodu.pronom begins "*" 
            then next.
            if nprodu.proipival = 1 
            then next.
            if nprodu.clacod = 182 
            then next.
            if nprodu.clacod = 3068 
            then next.
            if nprodu.clacod = 96
            then next.                                                             
            v-pendente = yes.
            leave.
        end.           
        if v-pendente = no 
        then next.
        
        if v-pendente = yes
        then do:            
            /* nao cria mais um pedido pendente por corte 
            find last bpedid where bpedid.pedtdc = 95 and
                                   bpedid.etbcod = tt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            
            create com.pedid.
            assign com.pedid.etbcod = tt-pendente.etbcod 
                   com.pedid.pedtdc = 95
                   com.pedid.modcod = "PEDP"
                   com.pedid.peddat = tt-ped.peddat
                   com.pedid.pednum = vpednum
                   com.pedid.sitped = "E"
                   com.pedid.pedsit = yes.
            */
        end.
        else next.
        
        for each btt-pendente where
                 btt-pendente.etbcod = tt-ped.etbcod and
                 btt-pendente.pedtdc = tt-ped.pedtdc and
                 btt-pendente.pednum = tt-ped.pednum
                 no-lock:
            find first nprodu where
                       nprodu.procod = btt-pendente.procod 
                       no-lock no-error.
                
            if not avail nprodu 
            then next.
            if nprodu.pronom matches "*RECARGA*" 
            then next.
            if nprodu.pronom matches "*FRETEIRO*" 
            then next.
            if nprodu.pronom begins "*" 
            then next.
            if nprodu.proipival = 1  
            then next.
            if btt-pendente.lipqtd = 0
            then next.
            
            /* um pedid para cada pendente */
            find last bpedid where bpedid.pedtdc = 95 and
                                   bpedid.etbcod = btt-pendente.etbcod  and
                                   bpedid.pednum >= 100000 no-error.
            if avail bpedid
            then vpednum = bpedid.pednum + 1.
            else vpednum = 100000.
            
            find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                  tbgenerica.TGCodigo = btt-pendente.modcod 
                                  no-lock no-error.            
            if not avail tbgenerica
            then next.
            if tbgenerica.tglog = no
            then next.
            
            if btt-pendente.etbcod <> 200
            then do.            
                def buffer PEDO-pedid for pedid.
                find PEDO-pedid where PEDO-pedid.etbcod = btt-pendente.etbcod
                                  and PEDO-pedid.pedtdc = btt-pendente.pedtdc
                                  and PEDO-pedid.pednum = btt-pendente.pednum
                                      no-lock no-error.
                create com.pedid.
                assign com.pedid.etbcod = btt-pendente.etbcod 
                       com.pedid.vencod = btt-pendente.vencod
                       com.pedid.pedtdc = 95
                       com.pedid.modcod = btt-pendente.modcod
                       com.pedid.peddat = btt-pendente.predt
                       com.pedid.pednum = vpednum
                       com.pedid.sitped = "E"
                       com.pedid.pedsit = yes
                       com.pedid.pendente = yes.

                /*neo_piloto*/
                find first ttpiloto where ttpiloto.etbcod  = com.pedid.etbcod  and
                                          ttpiloto.dtini  <= today
                    no-error.
                if today >= wfilvirada
                   or avail ttpiloto  /* Troca a Situacao para  Lojas Piloto */
                then com.pedid.sitped = "N".   
                /*neo_piloto*/
                       
                if avail PEDO-pedid
                then do on error undo. 
                    com.pedid.vencod = PEDO-pedid.vencod.
                    com.pedid.clfcod = PEDO-pedid.clfcod.
                    com.pedid.condat = PEDO-pedid.condat.
                    com.pedid.peddtf = PEDO-pedid.peddtf.
                    if PEDO-pedid.modcod = "PEDO"
                    then do.
                        find PEDO-pedid where 
                                    PEDO-pedid.etbcod = btt-pendente.etbcod and 
                                    PEDO-pedid.pedtdc = btt-pendente.pedtdc and 
                                    PEDO-pedid.pednum = btt-pendente.pednum.
                        PEDO-pedid.sitped = "C".
                        PEDO-pedid.pedobs[5] = PEDO-pedid.pedobs[5] +
                                        "Cancelado pelo Pendente gerado " +
                                         string(com.pedid.pednum).
                    end.
                end.
                create pedpend.
                ASSIGN pedpend.etbcod-ori = btt-pendente.etbcod
                       pedpend.pedtdc-ori = btt-pendente.pedtdc
                       pedpend.pednum-ori = btt-pendente.pednum
                       pedpend.etbcod-des = com.pedid.etbcod 
                       pedpend.pednum-des = com.pedid.pednum 
                       pedpend.pedtdc-des = com.pedid.pedtdc. 
            end.      
            def buffer xxliped for liped.
            find first xxliped where xxliped.etbcod = btt-pendente.etbcod and
                                     xxliped.pedtdc = btt-pendente.pedtdc and
                                     xxliped.pednum = btt-pendente.pednum and
                                     xxliped.procod = btt-pendente.procod
                                     no-error.
            if avail xxliped
            then do.
                def buffer xxpedid for pedid.
                find xxpedid of xxliped no-lock.
                find tbgenerica where tbgenerica.TGTabela = "TP_PEDID" and
                                      tbgenerica.TGCodigo = xxpedid.modcod 
                                      no-lock no-error. 
                if tbgenerica.tglog
                then do.
                    run criarepexporta.p ("LIPED_PENDENTE",
                                          "INCLUSAO",  
                                          recid(xxliped)).
                    xxliped.pendente    = yes.
                    xxliped.PendMotivo  = 
                                    "Produto sem estoque no CD para atender".
                    if btt-pendente.etbcod <> 200
                    then xxliped.lip_status  =   trim(
                                        "Gerou Pendente " +
                                            "[" +
                                                string(com.pedid.pednum)
                                                + "]" ).
                end.
            
            end.
            /*******************************/
            if btt-pendente.etbcod <> 200
            then do.
                find first  com.liped where 
                        com.liped.etbcod = com.pedid.etbcod and
                        com.liped.pedtdc = com.pedid.pedtdc and
                        com.liped.pednum = com.pedid.pednum and
                        com.liped.procod = btt-pendente.procod no-error.
                if not avail com.liped
                then do:
                    create com.liped.
                    assign 
                        com.liped.pedtdc    = com.pedid.pedtdc
                        com.liped.pednum    = com.pedid.pednum
                        com.liped.procod    = btt-pendente.procod
                        com.liped.lippreco  = btt-pendente.lippreco
                        com.liped.lipsit    = "Z"
                        com.liped.predtf    = com.pedid.peddat
                        com.liped.predt     = com.pedid.peddat
                        com.liped.etbcod    = com.pedid.etbcod
                        com.liped.lipcor    = 
                        string(btt-pendente.lipcor,"x(30)")
                        com.liped.protip    = string(time)
                        com.liped.prehr     = btt-pendente.prehr
                        com.liped.venda-placod = tt-pendente.venda-placod 
                        com.liped.pendente  = yes .
                end.
                com.liped.lipqtd = com.liped.lipqtd + btt-pendente.lipqtd.
            end.
        end.
    end.        
end procedure.



