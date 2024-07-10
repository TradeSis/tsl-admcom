/* filtrando notas dos ultimos 30 meses conforme solicitacao 
   Gerson */

{admcab.i}

def shared var vtitulo as char.

def input parameter par-clicod like clien.clicod.
def shared var vetbcod like estab.etbcod.

/*def var par-clicod like clien.clicod init 10002804.*/

def new shared var vtotqtd as int format ">>>>>>>>9".
def new shared var vtotval as dec format ">>,>>9.99".

def shared var vri as date format "99/99/9999" extent 5.
def shared var vrf as date format "99/99/9999" extent 5.

def new shared temp-table tt-plani 
    field etbcod like estab.etbcod
    field placod like plani.placod
    field pladat like plani.pladat
    field movtdc like plani.movtdc
    field numero like plani.numero
    field valor  like plani.platot   
    index irecencia pladat descending
    index ivalor    valor  descending.

def var vdata  as date format "99/99/99999".

/*do vdata = vri[1] to vrf[5]:*/
  for each plani use-index plasai
           where plani.movtdc = 5 
             and plani.desti  = par-clicod /*
             and plani.pladat = vdata*/ no-lock:

    /*if vetbcod <> 0
    then if plani.etbcod <> vetbcod
         then next.
    */     

    if plani.pladat < vri[1] or
       plani.pladat > vrf[5]
    then next.

    if plani.pladat < today - 900
    then next.

    find first tt-plani where tt-plani.etbcod = plani.etbcod
                          and tt-plani.placod = plani.placod
                          and tt-plani.movtdc = plani.movtdc
                          and tt-plani.pladat = plani.pladat no-error.
    if not avail tt-plani
    then do:
        create tt-plani.
        assign tt-plani.etbcod = plani.etbcod
               tt-plani.placod = plani.placod
               tt-plani.movtdc = plani.movtdc
               tt-plani.pladat = plani.pladat
               tt-plani.numero = plani.numero
               tt-plani.valor  = (if plani.biss > 0
                                  then plani.biss
                                  else plani.platot)
               vtotqtd = vtotqtd + 1
               vtotval = vtotval + (if plani.biss > 0
                                  then plani.biss
                                  else plani.platot) .
        
    end.
  end.
/*end.*/

find first tt-plani no-error.
if not avail tt-plani
then do:
    message "Nenhum registro encontrado.".
    pause 3 no-message.
    undo.
end.    


def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.

def var vordem as char extent 2 format "x(15)"
                init["1. Recencia   ",
                     "2. Valor      "].
                     

def var vordenar as integer.

def var esqcom1         as char format "x(14)" extent 5
    initial [" Produtos "," Ordenacao "," ", " "," "].

def var esqcom2         as char format "x(14)" extent 5
            initial [" "," ","","",""].


def buffer btt-plani       for tt-plani.


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
    
    if vordenar = 0 
    then vordenar = 1.
    
    if recatu1 = ?
    then
        run leitura (input "pri").
    else do:
        if vordenar = 1
        then find tt-plani use-index irecencia
                              where recid(tt-plani) = recatu1 no-error. 
        else 
        if vordenar = 2 
        then find tt-plani use-index ivalor 
                              where recid(tt-plani) = recatu1  no-error. 
    end.
        
    if not available tt-plani
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-plani).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
    
        if not available tt-plani
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
             if vordenar = 1
             then find tt-plani use-index irecencia
                                   where recid(tt-plani) = recatu1
                                    no-error.
             else
             if vordenar = 2
             then find tt-plani use-index ivalor
                                   where recid(tt-plani) = recatu1
                                    no-error.

            run mostra-totais.
            run color-message.
            
            choose field tt-plani.etbcod 
                         tt-plani.numero
                         tt-plani.pladat
                         tt-plani.valor   
                         help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).

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
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-plani
                    then leave.
                    recatu1 = recid(tt-plani).
                end.
                leave.
            end.
    
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-plani
                then next.
                color display white/red 
                              tt-plani.etbcod
                              tt-plani.numero
                              tt-plani.pladat
                              tt-plani.valor
                              with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-plani
                then next.
                color display white/red tt-plani.etbcod
                                        tt-plani.numero
                                        tt-plani.pladat
                                        tt-plani.valor
                                        with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do:

            if esqregua
            then do:
            
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Ordenacao "
                then do with frame f-ordem on error undo.

                    view frame frame-a. pause 0.
            
                    disp  vordem[1] skip   
                          vordem[2] skip 
                          with frame f-esc title "Ordenar por" row 7
                             centered color with/black no-label overlay. 
    
                    choose field vordem auto-return with frame f-esc.
                    vordenar = frame-index.

                    clear frame f-esc no-pause.
                    hide frame f-esc no-pause.
                    
                    recatu1 = ?.
                    next bl-princ.
                 
                end.
                
                if esqcom1[esqpos1] = " Produtos "
                then do with frame f-pro on error undo.

                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    hide frame f-tot   no-pause.
                    hide frame frame-a no-pause.
                    hide message no-pause.
                    
                    run crm20-consp.p.

                    view frame f-tot.  pause 0.
                    view frame f-com1. pause 0.
                    view frame f-com2. pause 0.

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
        recatu1 = recid(tt-plani).
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

    display tt-plani.etbcod     column-label "Loja"
            tt-plani.numero     column-label "Numero" format ">>>>>>>>9"
            tt-plani.pladat     column-label "Emissao"
            tt-plani.valor      column-label "Valor"
            with frame frame-a 11 down col 5 color white/red row 5
                    title vtitulo.
            
end procedure.

procedure color-message.
    color display message 
            tt-plani.etbcod     column-label "Loja"
            tt-plani.numero     column-label "Numero"
            tt-plani.pladat   column-label "Emissao"
            tt-plani.valor      column-label "Valor"
            with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
            tt-plani.etbcod     column-label "Loja"
            tt-plani.numero     column-label "Numero"
            tt-plani.pladat   column-label "Emissao"
            tt-plani.valor      column-label "Valor"
            with frame frame-a.
end procedure.

procedure leitura.

    def input parameter par-tipo as char.
        
    if par-tipo = "pri"
    then do: 
        if esqascend
        then do:
             if vordenar = 1
             then find first tt-plani use-index irecencia
                                    where true  no-error.
             else
             if vordenar = 2
             then find first tt-plani use-index ivalor
                                    where true  no-error.
        end.     
        else do: 
             if vordenar = 1
             then find last tt-plani use-index irecencia
                                   where true  no-error.
             else
             if vordenar = 2
             then find last tt-plani use-index ivalor
                                   where true  no-error.
        end.
    end.                                         
                                             
    if par-tipo = "seg" or par-tipo = "down" 
    then do:
        if esqascend  
        then do:
             if vordenar = 1
             then find next tt-plani use-index irecencia 
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-plani use-index ivalor
                                   where true  no-error.
        end.            
        else do: 
             if vordenar = 1
             then find prev tt-plani use-index irecencia
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-plani use-index ivalor
                                   where true  no-error.
        end.            
    end.
             
             
    if par-tipo = "up" 
    then do:
        if esqascend   
        then do:  
             if vordenar = 1
             then find prev tt-plani use-index irecencia
                                   where true  no-error.
             else
             if vordenar = 2
             then find prev tt-plani use-index ivalor
                                   where true  no-error.
        end.
        else do:
             if vordenar = 1
             then find next tt-plani use-index irecencia
                                   where true  no-error.
             else
             if vordenar = 2
             then find next tt-plani use-index ivalor
                                   where true  no-error.
        end.
    end.        
        
end procedure.

procedure mostra-totais.
    disp skip(3)
         "TOTAIS " skip(1)
         "Qtd. Notas  |->" vtotqtd no-label skip
         "Valor Total |->" vtotval no-label
         with frame f-tot col 45 no-box.
end procedure.

