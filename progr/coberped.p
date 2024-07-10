{admcab.i}

def buffer con-liped for liped.
def buffer con-forne for forne.
def buffer con-pedid for pedid.
def buffer con-crepl for crepl.
def buffer con-bestab for estab.
def buffer con-compr for compr.
def buffer con-repre for repre.
def buffer con-produ for produ.


def var vpreco like liped.lippreco.
def var vsemipi like liped.lippreco.
def var totger like pedid.pedtot.
def var totpen like pedid.pedtot.

    form con-forne.forcod      colon 18 label "Fornecedor"
         con-forne.fornom      no-label format "x(30)"
         con-forne.forcgc      colon 18
         con-forne.forinest    colon 50 label "I.E" format "x(17)"
         con-forne.forrua      colon 18 label "Endereco"
         con-forne.fornum
         con-forne.forcomp no-label
         con-forne.formunic   colon 18 label "Cidade"
         con-forne.ufecod   label "UF"
         con-forne.forcep      label "Cep"
         con-forne.forfone        colon 18 label "Fone"
         con-pedid.regcod    colon 18 label "Local Entrega"
         con-bestab.etbnom   no-label
         con-pedid.vencod    colon 18
         con-repre.repnom    no-label
         con-repre.fone      label "Fone"
         con-pedid.condat    colon 18
         con-pedid.peddti    colon 18 
                label "Prazo de Entrega" format "99/99/9999"
         con-pedid.peddtf    label "A"                         
                format "99/99/9999"
         con-pedid.crecod    colon 18 label "Prazo de Pagto" format "9999"
         con-crepl.crenom    no-label
         con-pedid.comcod    colon 18 label "Comprador"
         con-compr.comnom                 no-label
         con-pedid.frecod    label "Transport." colon 18
         con-pedid.fobcif
         con-pedid.condes       label "Frete" 
         con-pedid.nfdes        colon 18 label "Desc.Nota"
         con-pedid.dupdes       label "Desc.Duplicata"
         con-pedid.ipides       label "% IPI" format ">9.99 %"
         con-pedid.acrfin       label "Acres. Financ." colon 18
          with frame f-dialogo color 
          white/cyan overlay row 5 title " Dados "  side-labels centered.
    form
        con-pedid.pedobs[1] at 1
        con-pedid.pedobs[2] at 1
        con-pedid.pedobs[3] at 1
        con-pedid.pedobs[4] at 1
        con-pedid.pedobs[5] at 1 
        with frame fobs color white/cyan overlay 
        row 12 no-labels centered title "Observacoes".

def temp-table tt-ped 
    field pednum like pedid.pednum 
    field peddat like pedid.peddat
    field dtent  like pedid.peddtf
    field qtd    like liped.lipqtd
    field qtdent like liped.lipent
    field saldo as int
    field etbcod like estab.etbcod
    field pedtdc like pedid.pedtdc.

form
    tt-ped.pednum column-label "Número!Pedido"
    tt-ped.peddat column-label  "Data!Pedido"    format "99/99/9999"
    tt-ped.dtent column-label "Previsão!Entrega" format "99/99/9999"
    tt-ped.qtd column-label "Qtd.!Pedido"
    tt-ped.qtdent column-label "Qtd.!Entregue"
    tt-ped.saldo column-label "Saldo"
    with frame frame-a1 row 13 4 down overlay centered 
    title " Pedidos de Compra ".
     
 def input parameter p-procod like produ.procod.
def var vdata as date format "99/99/9999".

for each tt-ped.
    delete tt-ped.
end.

           do vdata = today - 365 to today:
                for each liped where liped.pedtdc = 1
                                 and liped.procod = p-procod
                                 and liped.predt  = vdata no-lock:
                    find pedid of liped no-lock  no-error.             

                    if pedid.sitped = "F" then next.

                    disp pedid.pednum pedid.peddat                
                        with centered side-labels 1 down. pause 0.
                    
                    find tt-ped where tt-ped.pednum = pedid.pednum no-error.
                    if not avail tt-ped
                    then do:
                        create tt-ped.
                        assign tt-ped.pednum = pedid.pednum
                               tt-ped.peddat = pedid.peddat
                               tt-ped.dtent  = pedid.peddtf
                               tt-ped.qtd = liped.lipqtd
                               tt-ped.qtdent = liped.lipent
                               tt-ped.saldo = (liped.lipqtd - liped.lipent)
                               tt-ped.etbcod = pedid.etbcod
                               tt-ped.pedtdc = pedid.pedtdc.
                    end.            
                    
                end.
            end.                 



def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Consulta "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["  ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

for each tt-ped where tt-ped.saldo <= 0:
    delete tt-ped.
end.
    
def buffer btt-ped       for tt-ped.
def var vtt-ped         like tt-ped.pednum.


form
    esqcom1
    with frame f-com1
                 row 9 no-box no-labels side-labels column 1 centered.
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
        find tt-ped where recid(tt-ped) = recatu1 no-lock.
    if not available tt-ped
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a1 all no-pause.
    if not esqvazio
    then do:
        run frame-a1.
    end.

    recatu1 = recid(tt-ped).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-ped
        then leave.
        if frame-line(frame-a1) = frame-down(frame-a1)
        then leave.
        down
            with frame frame-a1.
        run frame-a1.
    end.
    if not esqvazio
    then up frame-line(frame-a1) - 1 with frame frame-a1.

    repeat with frame frame-a1:

        if not esqvazio
        then do:
            find tt-ped where recid(tt-ped) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-ped.pednum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-ped.pednum)
                                        else "".
            run color-message.

            choose field tt-ped.pednum help ""
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
                do reccont = 1 to frame-down(frame-a1):
                    run leitura (input "down").
                    if not avail tt-ped
                    then leave.
                    recatu1 = recid(tt-ped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a1):
                    run leitura (input "up").
                    if not avail tt-ped
                    then leave.
                    recatu1 = recid(tt-ped).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-ped
                then next.
                color display white/blue tt-ped.pednum with frame frame-a1.
                if frame-line(frame-a1) = frame-down(frame-a1)
                then scroll with frame frame-a1.
                else down with frame frame-a1.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-ped
                then next.
                color display white/blue tt-ped.pednum with frame frame-a1.
                if frame-line(frame-a1) = 1
                then scroll down with frame frame-a1.
                else up with frame frame-a1.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-ped
                 with frame f-tt-ped color black/cyan
                      centered side-label row 5 .
            hide frame frame-a1 no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Estoque " or esqvazio
                then do with frame f-tt-ped on error undo.

                   
                end.
                
                if esqcom1[esqpos1] = " Consulta "
                then do:
                    hide frame f-senha no-pause.
                    hide frame f-com1 no-pause.
                    hide frame f-com2 no-pause.

                    find con-pedid where
                         con-pedid.etbcod = tt-ped.etbcod and
                         con-pedid.pedtdc = tt-ped.pedtdc and
                         con-pedid.pednum = tt-ped.pednum no-lock.
                         
                    find con-forne where
                         con-forne.forcod = con-pedid.clfcod no-lock.
                         
                    find con-crepl where 
                         con-crepl.crecod = con-pedid.crecod no-lock.
                         
                    find con-bestab where 
                         con-bestab.etbcod = con-pedid.regcod no-lock.
                    find con-compr where 
                         con-compr.comcod = con-pedid.comcod no-lock.
                    find con-repre where 
                         con-repre.repcod = con-pedid.vencod no-lock.

                    disp con-forne.forcod
                         con-forne.fornom
                         con-forne.forcgc
                         con-forne.forinest
                         con-forne.forrua
                         con-forne.fornum
                         con-forne.forcomp
                         con-forne.formunic
                         con-forne.ufecod
                         con-forne.forcep
                         con-forne.forfone
                         con-pedid.regcod
                         con-bestab.etbnom
                         con-pedid.vencod
                         con-repre.repnom
                         con-repre.fone
                         con-pedid.condat format "99/99/9999"
                         con-pedid.peddti format "99/99/9999"
                         con-pedid.peddtf format "99/99/9999"
                         con-pedid.crecod format "9999"
                         con-crepl.crenom
                         con-pedid.comcod
                         con-compr.comnom
                         con-pedid.frecod
                         con-pedid.fobcif
                         con-pedid.condes
                         con-pedid.nfdes
                         con-pedid.dupdes
                         con-pedid.ipides
                         con-pedid.acrfin
      with frame f-dialogo color white/cyan overlay 
        row 5 side-labels centered.
                    display con-pedid.pedobs[1]
                            con-pedid.pedobs[2]
                            con-pedid.pedobs[3]
                            con-pedid.pedobs[4]
                            con-pedid.pedobs[5]
                            with frame fobs color white/cyan overlay row 12
                                        no-labels centered title "Observacoes".
        
                    totpen = 0.
                    totger = 0.
                    for each con-liped of con-pedid,
                        each con-produ where con-produ.procod = con-liped.procod
                                no-lock by con-produ.pronom.
                    
                        vsemipi = 0.
                        vpreco = 0.
                        vsemipi = (con-liped.lippreco - 
                               (con-liped.lippreco * (con-pedid.nfdes / 100))).
                    
                        vpreco = (con-liped.lippreco - 
                               (con-liped.lippreco * (con-pedid.nfdes / 100))).

                        vpreco = (vpreco + 
                                  (vpreco * (con-pedid.ipides / 100))).
                    
                        disp con-liped.procod
                             con-produ.pronom format "x(35)" 
                                    when avail con-produ
                             con-produ.proindice format "x(13)" 
                                            column-label "Cod.Barras"
                             vpreco format ">,>>9.99" column-label "Preco"
                             con-liped.lipqtd column-label "Qtd!Ped" 
                             format ">>>>9"
                             con-liped.lipent 
                             column-label "Qtd!Ent" format ">>>>9"
                                    with frame f-con 7 down row 10
                                            color black/cyan title " Produtos "
                                            width 80 overlay.
                    totpen = totpen + ((con-liped.lipqtd - con-liped.lipent) *
                                            vpreco).
                        totger = totger + (con-liped.lipqtd * vpreco).
                    end.
                    display totger
                            totpen label "Total Pendente" format "->>>,>>9.99"
                            with frame f-tot row 22 side-label centered
                                                color black/cyan no-box.
    
                    pause.
                    hide frame f-senha no-pause.

                    hide frame f-tot no-pause.
                    hide frame f-dialogo no-pause.
                    hide frame fobs no-pause.
                    leave.
                
                end.

                if esqcom1[esqpos1] = " Pedidos "
                then do with frame f-tt-ped on error undo.

                
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-ped.pednum
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-ped where true no-error.
                    if not available tt-ped
                    then do:
                        find tt-ped where recid(tt-ped) = recatu1.
                        find prev tt-ped where true no-error.
                    end.
                    recatu2 = if available tt-ped
                              then recid(tt-ped)
                              else ?.
                    find tt-ped where recid(tt-ped) = recatu1
                            exclusive.
                    delete tt-ped.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir todas ou a selecionada "
                           sresp format "Todas/Selecionada"
                                 help "Todas/Selecionadas"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp
                    then run ltt-ped.p (input 0).
                    else run ltt-ped.p (input tt-ped.pednum).
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
            run frame-a1.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-ped).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a1 no-pause.


procedure frame-a1.
pause 0.
display 
        tt-ped.pednum
        tt-ped.peddat
        tt-ped.dtent
        tt-ped.qtd
        tt-ped.qtdent
        tt-ped.saldo
        with frame frame-a1 .
end procedure.
procedure color-message.
color display message
        tt-ped.pednum
        tt-ped.peddat
        tt-ped.dtent
        tt-ped.qtd
        tt-ped.qtdent
        tt-ped.saldo
        with frame frame-a1.
end procedure.
procedure color-normal.
color display normal
        tt-ped.pednum
        tt-ped.peddat
        tt-ped.dtent
        tt-ped.qtd
        tt-ped.qtdent
        tt-ped.saldo
        with frame frame-a1.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-ped where true
                                                no-lock no-error.
    else  
        find last tt-ped  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-ped  where true
                                                no-lock no-error.
    else  
        find prev tt-ped   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-ped where true  
                                        no-lock no-error.
    else   
        find next tt-ped where true 
                                        no-lock no-error.
        
end procedure.
    