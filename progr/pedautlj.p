/*  pedautlj.p          */
/* Projeto Melhorias Mix - Luciano       */

/*neo_piloto - 17.06.2019 - nao gerar para lojas no piloto*/
{/admcom/progr/abas/neo_piloto.i}


{admcab.i new}
 
message "A Consulta de pedidos gerados apos o dia 24/06 deve ser realizada no SAP2" view-as alert-box.
 return.
 
/* 
def var vtitle as char.
/* #1 */ def buffer xestab for estab.

def  var vprocod like produ.procod init 0. /* #1 */

def var dcb-cod like tdocbase.dcbcod.
def var tot-pedido      like liped.lipqtd    .
def var tot-atendido    like liped.lipqtd.
def var vbusca as char format "x(15)" label "Pedido".
def var primeiro    as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var varquivo as char.
def var esqascend     as log initial no.

/* #1 */
def var esqcom1         as char format "x(15)" extent 5
    initial [" Consulta ", " Filtro tipo"," Filtro produto"," Numero WMS"," "].
def var esqcom2         as char format "x(19)" extent 4
    initial ["Manutencao pendente","","",""].
def var fun-senha like func.senha.
def var vsenha like func.senha.
def var vetbcod like estab.etbcod.

if setbcod <> 999
then do:
    esqcom2[2] = "".
    if setbcod = 100
    then assign
        esqcom2[1] = "Altera quantidade"
        esqcom2[2] = "Cancela pedido"
        .
end.
else do:
    
    assign
        esqcom2[1] = "Altera quantidade"
        esqcom2[2] = "Cancela pedido"
        .

    update vetbcod label "Filial"
        with frame f-es 1 down width 80 side-label.
        
    find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
    if avail func
    then fun-senha = func.senha.

    update vsenha blank label "Senha"
           with frame f-senha centered side-labels. 
           
    hide frame f-senha no-pause.

    if vsenha <> "" and
        (vsenha = fun-senha   or
        vsenha = "1360") 
    then.
    else do:
        message color red/with
        "Informe a senha corretamente"
        view-as alert-box.
        return.
    end.

end.

def var xetbcod as int.
                     /*neo_piloto*/
                    find first ttpiloto where ttpiloto.etbcod  = (if vetbcod = 0
                                                                  then setbcod
                                                                  else vetbcod)  and
                                          ttpiloto.dtini  <= today
                        no-error.
                    if today >= wfilvirada or 
                       avail ttpiloto  
                    then do:
                        xetbcod = 0.
                        if vetbcod <> 0
                        then do:
                            xetbcod = setbcod.
                            setbcod = vetbcod.
                        end.    
                        run abas/transfloj.p.
                        if xetbcod <> 0
                        then do:
                            setbcod = xetbcod.
                        end.    
                        leave.
                    end.    

def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def new shared temp-table tp-pro like com.produ.

def new shared temp-table tpb-pedid like com.pedid
    field rec as recid
    
    .
def new shared temp-table tpb-liped like com.liped.

def var v-arquivo as char.
def var vclicod as int.

def var v-mod as char extent 11.
def var v-desmod as char format "x(15)" extent 11.
def var v-index as int init 1. 

assign
    v-mod[1]    = "PED"
    v-desmod[1] = "Todos"
    v-mod[2]    = "PEDA"
    v-desmod[2] = "Automatico"
    v-mod[3]    = "PEDM"
    v-desmod[3] = "Manual"
    v-mod[4]    = "PEDR"
    v-desmod[4] = "Reposicao"
    v-mod[5]    = "PAEI"
    v-desmod[5] = "PAEI" 
    v-mod[5]    = "PEDP"
    v-desmod[5] = "Pendente"
    v-mod[6]    = "PEDC"
    v-desmod[6] = "Comercial"
    v-mod[7]    = "PEDO"
    v-desmod[7] = "Outra Filial"
    v-mod[8]    = "PEDF"
    v-desmod[8] = "Entrega Futura"
    v-mod[9]    = "PEDI"
    v-desmod[9] = "Ajuste Minimo"
    v-mod[10]    = "PEDX"
    v-desmod[10] = "Ajuste Mix"
    v-mod[11]    = "VEXM"
    v-desmod[11] = "VEX Moda" 
     .
     
if vetbcod = 0
then vetbcod = setbcod.
def var vok-p as log. 

def var dias-ped as int.

procedure sel-pedidos:

for each tpb-pedid: delete tpb-pedid. end.
for each tpb-liped: delete tpb-liped. end.

def var vdata as date.

/* #1 */
do vdata = today - 180 to today + 120.
hide message no-pause.
message "processando " vdata v-index v-mod[v-index] v-desmod[v-index]
    " produto " vprocod.

for each com.pedid 
        use-index pedid3
            where com.pedid.pedtdc = 3
              and com.pedid.etbcod = vetbcod 
              and com.pedid.peddat = vdata /* #1 */
              no-lock:
 
    if v-index > 1 /* #1 */
    then  if com.pedid.modcod <> v-mod[v-index]
          then next.
    
    if com.pedid.sitped = "C"
    then do.  pause 0. next. end.

    if com.pedid.sitped = "F" and
           com.pedid.peddat <= today - dias-ped
    then do:
        if sfuncod = 656 and sfuncod = 553
            and com.pedid.peddat <= today - 180
        then.
        else do. pause 0. next. end.
    end.
    
    if sfuncod = 656 and sfuncod = 553
       and com.pedid.peddat <= today - 180
    then do. pause 0. next. end.
    else if sfuncod <> 656 and sfuncod <> 553 and 
        com.pedid.peddat <= today - 90
    then do. pause 0. next. end.

    if vprocod > 0 /* #1 */
    then do     :
        if not can-find(first liped where
                                      liped.etbcod = pedid.etbcod and
                                      liped.pedtdc = pedid.pedtdc and
                                      liped.pednum = pedid.pednum and
                                      liped.procod = vprocod)
        then next.                                         
    end.
    vok-p = no.
    for each com.liped of com.pedid no-lock:
        if com.liped.lipsit <> "C"
        then do:
            vok-p = yes.  
            create tpb-liped.
            buffer-copy liped to tpb-liped.
        end.
    end.
    if vok-p = no
    then next.
    create tpb-pedid.
    buffer-copy pedid to tpb-pedid.
    tpb-pedid.rec = recid(pedid).
    if tpb-pedid.modcod = "PEDA"
    then tpb-pedid.pedobs[5] = "Automatico".
    else if tpb-pedid.modcod = "PEDM"
        then tpb-pedid.pedobs[5] = "Manual".
        else if tpb-pedid.modcod = "PEDR"
           then tpb-pedid.pedobs[5] = "Reposicao".
           else if tpb-pedid.modcod = "PEDE"
               then tpb-pedid.pedobs[5] = "Especial".
               else if tpb-pedid.modcod = "PEDP"
                   then tpb-pedid.pedobs[5] = "Pendente".
                   else if tpb-pedid.modcod = "PEDO"
                       then tpb-pedid.pedobs[5] = "Outra Filial".
                       else if tpb-pedid.modcod = "PEDF"
                          then tpb-pedid.pedobs[5] = "Entrega Futura".
                          else if tpb-pedid.modcod = "PEDC"
                            then tpb-pedid.pedobs[5] = "Comercial".
                            else if tpb-pedid.modcod = "PEDI"
                              then tpb-pedid.pedobs[5] = "Ajuste Minimo".
                              else if tpb-pedid.modcod = "PEDX"
                                then tpb-pedid.pedobs[5] = "Ajuste Mix".
                                else if tpb-pedid.modcod = "PAEI"
                                then tpb-pedid.pedobs[5] = "PAEI".
                                else if tpb-pedid.modcod = "VEXM"
                                then tpb-pedid.pedobs[5] = "VEX Moda"
                                .
 
end.

/* #1 */
for each xestab where xestab.etbcod <> vetbcod no-lock.
for each com.pedid 
            use-index pedid3
            where com.pedid.pedtdc = 3
                              and com.pedid.vencod = vetbcod 
                              and com.pedid.etbcod = xestab.etbcod
                              and com.pedid.peddat = vdata
                               no-lock :

 
    if v-index > 1 /* #1 */
    then if com.pedid.modcod <> v-mod[v-index]
         then next.
     
    if com.pedid.sitped = "C"
    then next.
    if com.pedid.sitped = "F" and
           com.pedid.peddat <= today - dias-ped
    then do:
        if sfuncod = 656 or sfuncod = 553
            and com.pedid.peddat <= today - 180
        then.
        else next.
    end.

    if sfuncod = 656 or sfuncod = 553
       and com.pedid.peddat <= today - 180
    then next.
    else if sfuncod <> 656 and sfuncod <> 553
            and com.pedid.peddat <= today - 30
    then next.

    if vprocod > 0         /* #1 */
    then do :    
        if not can-find(first liped where
                                      liped.etbcod = pedid.etbcod and
                                      liped.pedtdc = pedid.pedtdc and
                                      liped.pednum = pedid.pednum and
                                      liped.procod = vprocod)
        then next.                                         
    end.

    vok-p = no.
    for each com.liped of com.pedid no-lock:
        if com.liped.lipsit <> "C"
        then do:
            vok-p = yes.  
            create tpb-liped.
            buffer-copy liped to tpb-liped.
        end.
    end.
    if vok-p = no
    then next.
    
    create tpb-pedid.
    buffer-copy pedid to tpb-pedid.
    tpb-pedid.rec = recid(pedid).
    if tpb-pedid.modcod = "PEDA"
    then tpb-pedid.pedobs[5] = "Automatico".
    else if tpb-pedid.modcod = "PEDM"
        then tpb-pedid.pedobs[5] = "Manual".
        else if tpb-pedid.modcod = "PEDR"
           then tpb-pedid.pedobs[5] = "Reposicao".
           else if tpb-pedid.modcod = "PEDE"
               then tpb-pedid.pedobs[5] = "Especial".
               else if tpb-pedid.modcod = "PEDP"
                   then tpb-pedid.pedobs[5] = "Pendente".
                   else if tpb-pedid.modcod = "PEDO"
                       then tpb-pedid.pedobs[5] = "Outra Filial".
                       else if tpb-pedid.modcod = "PEDF"
                          then tpb-pedid.pedobs[5] = "Entrega Futura".
                          else if tpb-pedid.modcod = "PEDC"
                            then tpb-pedid.pedobs[5] = "Comercial".
                            else if tpb-pedid.modcod = "PEDI"
                              then tpb-pedid.pedobs[5] = "Ajuste Minimo".
                              else if tpb-pedid.modcod = "PEDX"
                                then tpb-pedid.pedobs[5] = "Ajuste Mix".
                                else if tpb-pedid.modcod = "PAEI"
                                then tpb-pedid.pedobs[5] = "PAEI".
                                else if tpb-pedid.modcod = "VEXM"
                                then tpb-pedid.pedobs[5] = "VEX Moda".
  
end.
end. /* #1 xestab */
end. /* #1 data */


end procedure.

dias-ped = 90.
run sel-pedidos.

find first tpb-pedid no-lock no-error.
if not avail tpb-pedid
then do:
    message "Nenhum registro encontrado...".
    pause 2 no-message. leave.
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

    status default "Situacao [E]mitido [L]istado [F]echado".
    pause 0. 
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tpb-pedid where recid(tpb-pedid) = recatu1 no-lock.

    if not available tpb-pedid
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tpb-pedid).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tpb-pedid
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
            find tpb-pedid where recid(tpb-pedid) = recatu1 no-lock.


            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tpb-pedid.pednum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tpb-pedid.pednum)
                                        else "".
            run color-message.
            status default "Situacao [E]mitido [L]istado [F]echado".
            choose field tpb-pedid.peddat help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      1 2 3 4 5 6 7 8 9 0 
                      page-down   page-up
                      tab PF4 F4 ESC return).
            run color-normal.
            status default "".
            hide message no-pause. /* #1 */
            
            if keyfunction(lastkey) = "1" or  
               keyfunction(lastkey) = "2" or  
               keyfunction(lastkey) = "3" or  
               keyfunction(lastkey) = "4" or  
               keyfunction(lastkey) = "5" or
               keyfunction(lastkey) = "6" or  
               keyfunction(lastkey) = "7" or  
               keyfunction(lastkey) = "8" or  
               keyfunction(lastkey) = "9" or  
               keyfunction(lastkey) = "0" or
               keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do with centered row 8 color message no-label
                                frame f-procura side-label overlay:
                if keyfunction(lastkey) <> "HELP" and
                   keyfunction(lastkey) <> "P" and
                   keyfunction(lastkey) <> "p"
                then assign
                        vbusca = keyfunction(lastkey)
                        primeiro = yes.
                pause 0.
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
                do on error undo with frame f-procura.
                    
    if vprocod > 0
    then do:
        if esqascend  
        then  
            find first tpb-pedid where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
                 and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                 and tpb-pedid.pednum = int(vbusca)                      
                                                no-lock no-error.
        else  
            find last tpb-pedid  where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                   and tpb-pedid.pednum = int(vbusca)                                                 no-lock no-error.
    end.
    else do:
        if esqascend  
        then  
            find first tpb-pedid where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
                    and tpb-pedid.pednum = int(vbusca)
                                                no-lock no-error.
        else  
            find last tpb-pedid  where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                    and tpb-pedid.pednum = int(vbusca)
                                                 no-lock no-error.
 
    end.
                    
                    if avail tpb-pedid
                    then recatu1 = recid(tpb-pedid).
                    else recatu1 = recatu2.
                end.
                next bl-princ.
            end.

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
                    if not avail tpb-pedid
                    then leave.
                    recatu1 = recid(tpb-pedid).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tpb-pedid
                    then leave.
                    recatu1 = recid(tpb-pedid).
                end.
                leave.
            end.
            
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tpb-pedid
                then next.

                color display white/red tpb-pedid.peddat with frame frame-a.
                
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tpb-pedid
                then next.

                color display white/red tpb-pedid.peddat with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tpb-pedid
                 with frame f-tpb-pedid color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do:
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.
                    pause 0.
                    find pedid where recid(pedid) = tpb-pedid.rec no-lock.
                    if pedid.sitped = "F"
                    then run pedid_atend.p (recid(pedid)). 
                    else run wmscorte2_consulta.p (recid(pedid)).
                    hide message no-pause.
                        
                    leave.
                end.
                
            if esqcom1[esqpos1] = " Pendencia "
            then do:
                hide frame frame-a no-pause.
                 hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                /*
                repeat:
                display tpb-pedid.etbcod
                        tpb-pedid.pednum with frame f-tit
                                    centered side-label 
                                        color black/cyan row 4.

                for each tpb-liped of tpb-pedid no-lock.
                    find produ where 
                         produ.procod = tpb-liped.procod no-lock no-error.

                    disp tpb-liped.procod
                         produ.pronom format "x(30)" when avail produ
                         tpb-liped.lippreco
                         tpb-liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         tpb-liped.lipent column-label "Qtd.Ent" format ">>>9"
                                with frame f-con 10 down row 7 centered
                                        color black/cyan title " Produtos ".
                end.
                pause.
                leave.
                end.
                */
                find pedid where recid(pedid) = tpb-pedid.rec no-lock.
                run pedautlj_consulta.p (recid(pedid)).
                
                leave.
            end.
            if esqcom1[esqpos1] = " Filtro tipo "
            then do:
                pause 0.
                repeat on error undo:
                    disp v-desmod with frame f-filtro
                        1 down row 5 no-label 1 column overlay.
                    choose field v-desmod with frame f-filtro. 
                    v-index = frame-index. 
                    leave.
                end.
                
                dias-ped = 90.
                run sel-pedidos.

                recatu1 = ?.  
                next bl-princ.
            end.
            if esqcom1[esqpos1] = " Filtro produto"
            then do:
                pause 0. 
                update vprocod label "Produto"
                    with frame f-produ  1 down side-label.

                /* #1 */
                dias-ped = 90.
                run sel-pedidos.
                hide frame f-produ no-pause.
                recatu1 = ?.  
                next bl-princ.
            end.
            if esqcom1[esqpos1] = " Numero WMS" /* #1 */
            then do:
                hide message no-pause.
                message "Aguarde...".

find first tpb-liped of tpb-pedid where tpb-liped.dtcorte <> ?
                            no-lock no-error.
dcb-cod = 0.
/**/
for each tdocbpro where
               /*tdocbpro.etbdes = liped.etbcod and*/
               tdocbpro.procod = tpb-liped.procod and
               tdocbpro.pednum = tpb-pedid.pednum
               no-lock,
    first tdocbase where
          tdocbase.dcbcod = tdocbpro.dcbcod and
          tdocbase.etbdes = tpb-liped.etbcod
          no-lock:    
    dcb-cod = tdocbase.dcbcod.           
end.                
/**/

            hide message no-pause.
            pause 0.
            disp dcb-cod label "Numero WMS"
              with frame f-produ  .
            message "Numero WMS" dcb-cod.
              
            pause 2 no-message.      
            hide message no-pause.
            message "Numero WMS" dcb-cod.
            
        end.

             if esqcom1[esqpos1] = " Imprime "
            then do:
                sresp = no.
                message "Confirma Impressao do pedido?" update sresp .
                if not sresp then leave.
                hide frame f-com1 no-pause.
                hide frame f-com2 no-pause.
                
                varquivo = "/usr/admcom/relat/pedautom" + string(time).
                {mdadmcab.i &Saida = "value(varquivo)"
                    &Page-Size = "64" 
                    &Cond-Var  = "80" 
                    &Page-Line = "66" 
                    &Nom-Rel   = ""pedauton-ag3"" 
                    &Nom-Sis   = """SISTEMA COMERCIAL""" 
                    &Tit-Rel   = """ PEDIDO AUTOMATICO """
                    &Width     = "80"
                    &Form      = "frame f-cabc2"}

                 display tpb-pedid.etbcod
                        tpb-pedid.pednum with frame f-tit1
                                    centered side-label.

                for each tpb-liped of tpb-pedid no-lock.
                    find produ where 
                         produ.procod = tpb-liped.procod no-lock no-error.

                    disp tpb-liped.procod
                         produ.pronom format "x(30)" when avail produ
                         tpb-liped.lippreco
                         tpb-liped.lipqtd column-label "Qtd.Ped" format ">>>9"
                         tpb-liped.lipent column-label "Qtd.Ent" format ">>>9"
                                with frame f-con1 down.
                end.
                output close.
                /*
                run visurel.p(varquivo,"").
                */
                os-command silent /fiscal/lp value(varquivo). 
                leave.
            end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "Manutencao pendente"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame frame-a no-pause.
                    run manpeaut.p.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
                end.
                if esqcom2[esqpos2] = "Altera quantidade"
                then do:
                    if tpb-pedid.sitped = "E"
                    then do: 
                        hide frame f-com1  no-pause.
                        hide frame f-com2  no-pause.
                        hide frame frame-a no-pause.
                        find pedid where pedid.etbcod = tpb-pedid.etbcod and
                                         pedid.pedtdc = tpb-pedid.pedtdc and
                                         pedid.pednum = tpb-pedid.pednum
                                         no-lock.
                        run manqtdpe.p(recid(pedid)).
                        find pedid where pedid.etbcod = tpb-pedid.etbcod and
                                         pedid.pedtdc = tpb-pedid.pedtdc and
                                         pedid.pednum = tpb-pedid.pednum
                                         no-lock.
                        tpb-pedid.sitped = pedid.sitped.
                        view frame f-com1.
                        view frame f-com2.
                        next bl-princ.
                    end.
                    else do:
                        message color red/with
                            "Situacao do pedido nao permite alteracao"
                            view-as alert-box.
                    end.
                end.
                if esqcom2[esqpos2] = "Cancela pedido"
                then do on error undo: /* #1 */

                    if tpb-pedid.sitped <> "E"
                    then do.
                        message color red/with
                                "Situacao do pedido nao permite cancelamento"
                                view-as alert-box.
                            next bl-princ.

                    end.
                    
                    if tpb-pedid.sitped <> "E" and
                       tpb-pedid.sitped <> "L"
                    then do:
                         if tpb-pedid.sitped = "F" and
                            tpb-pedid.modcod = "PEDOooooo" and
                            tpb-pedid.peddtf = ? 
                         then.
                         else do:   
                            message color red/with
                                "Situacao do pedido nao permite cancelamento"
                                view-as alert-box.
                            next bl-princ.
                         end.
                    end.
                    /*else*/ do:
                    sresp = no.
                    message "Confirma cancelamento do PEDIDO "
                        string(tpb-pedid.pednum) update sresp.
                    if sresp
                    then do on error undo:     /* #1 */                                                find pedid where pedid.etbcod = tpb-pedid.etbcod and
                                     pedid.pedtdc = tpb-pedid.pedtdc and
                                     pedid.pednum = tpb-pedid.pednum
                                     no-error.
                        if avail pedid
                        then do:            
                            for each liped of pedid :                 
                                liped.lipsit = "C".
                            end.

                        pedid.pedobs[3] = pedid.pedobs[3]
                               + "|DATA_EXCLUSAO=" + string(today,"99/99/9999")
                               + "|HORA_EXCLUSAO=" + string(time,"HH:MM:SS")
                               + "|ETB_EXCLUSAO="  + string(setbcod)
                               + "|USUARIO_EXCLUSAO=" + string(sfuncod)
                               + "|PROG_EXCLUSAO=" + program-name(1)
                               + "|".

                        pedid.sitped = "C".
                        end. /* #1 */
                        recatu1 = ?. /* #1 */
                     end.
                    end.        
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
        recatu1 = recid(tpb-pedid).
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
    def var vwms as char.
 
procedure frame-a.
    find com.pedid where recid(com.pedid) = tpb-pedid.rec no-lock.    
    tot-pedido   = 0.
    tot-atendido = 0.
    def var nf-emitida as log.
    nf-emitida = no.
    for each liped of com.pedid no-lock.
        tot-pedido   = tot-pedido   + com.liped.lipqtd.
        tot-atendido = tot-atendido + com.liped.lipent.
        if liped.transf-placod <> 0
        then nf-emitida = yes.
    end.
    vwms = "".
    if com.pedid.sitped = "L" 
    then vwms = "Em Separacao".
    if com.pedid.sitped = "F" and nf-emitida = yes
    then vwms = "NF Emitida".
    if com.pedid.sitped = "R" 
    then vwms = "Excluido".

    /* #1 */
    vtitle = (if v-index > 1 
             then "Filtro Tipo "
             else "")
             +
             (if v-index >  1
             then v-mod[v-index]
             else "")
             +
             (if vprocod > 0
              then " Produto "
              else "")
             +
             (if vprocod > 0
             then string(vprocod)
             else "").
              
        if vtitle = "" then vtitle = "GERAL".
         
display tpb-pedid.etbcod  column-label "Fil" format ">>9"
        liped.dtcorte when avail liped column-label "Corte"
                    format "99/99/99"
        tpb-pedid.pednum  column-label "Pedido" format ">>>>>>9"
        tpb-pedid.peddat  column-label "Data Ped" format "99/99/99"
        com.pedid.sitped  column-label "S" 
        tpb-pedid.pedobs[5] format "x(15)" column-label "Tipo"
        tpb-pedid.vencod  when tpb-pedid.vencod > 0
            format ">>9" column-label "Fil!Ori"
        /*
        tot-atendido / tot-pedido * 100 format ">>9%" label "%%%%"
                                when com.pedid.sitped = "F" 
        */
        com.pedid.pendente format "Pend/" no-label
                            when com.pedid.sitped <> "F"
        vwms format "x(13)" label "Status CD"
        /** /* #1 */
                dcb-cod    column-label "Numero!WMS"
                        when dcb-cod > 0 format ">>>>>9"
            **/                        
        with frame frame-a 11 down row 5 width 80
        title vtitle.

end procedure.
procedure color-message.
color display message
        tpb-pedid.etbcod com.pedid.pendente vwms 
        tpb-pedid.pednum  tpb-pedid.pedobs[5]
        tpb-pedid.peddat 
        com.pedid.sitped
        tpb-pedid.vencod
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tpb-pedid.etbcod 
        tpb-pedid.pednum com.pedid.pendente vwms
        tpb-pedid.peddat tpb-pedid.pedobs[5]
        com.pedid.sitped tpb-pedid.vencod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then do: 
    if vprocod > 0
    then do:
        if esqascend  
        then  
            find first tpb-pedid use-index pedid3 where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
                 and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                                no-lock no-error.
        else  
            find last tpb-pedid use-index pedid3  where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                                 no-lock no-error.
    end.
    else do:
        if esqascend  
        then  
            find first tpb-pedid use-index pedid3 where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
                                                no-lock no-error.
        else  
            find last tpb-pedid use-index pedid3 where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                                                 no-lock no-error.
 
    end.
end.                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:  
    if vprocod > 0
    then do:
        if esqascend  
        then  
            find next tpb-pedid use-index pedid3  where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
              and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                                no-lock no-error.
        else  
            find prev tpb-pedid use-index pedid3  where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
              and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                                no-lock no-error.
    end.
    else do:
        if esqascend  
        then  
            find next tpb-pedid use-index pedid3 
                        /* #1 */
                    /**where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                    **/
                                                no-lock no-error.
        else  
            find prev tpb-pedid use-index pedid3  
                        /**where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true) 
                    **/
                                                no-lock no-error.

    end.
end.             
if par-tipo = "up" 
then do:                 
    if vprocod > 0
    then do:
        if esqascend   
        then   
            find prev tpb-pedid use-index pedid3 where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
               and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                        no-lock no-error.
        else   
            find next tpb-pedid use-index pedid3 where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
              and   can-find(first tpb-liped where
                                      tpb-liped.etbcod = tpb-pedid.etbcod and
                                      tpb-liped.pedtdc = tpb-pedid.pedtdc and
                                      tpb-liped.pednum = tpb-pedid.pednum and
                                      tpb-liped.procod = vprocod)
                                        no-lock no-error.
    end.
    else do:
        if esqascend   
        then   
            find prev tpb-pedid use-index pedid3 
                    /**
                    where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                    **/
                                        no-lock no-error.
        else   
            find next tpb-pedid use-index pedid3 
                    /**
                    where (if v-index > 1
                    then tpb-pedid.modcod = v-mod[v-index]
                    else true)
                    **/
                                        no-lock no-error.
 
    end.
end.
end procedure.
*/
         
