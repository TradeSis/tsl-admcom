{admcab.i}

def var fre    as int.
def var val    as dec.

def var vdesc as char format "x(30)".
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
    initial [" ",
             " ",
             " ",
             " ",
             " "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer brfvparam       for rfvparam.
def temp-table tt-rfvparam like rfvparam.

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
        find rfvparam where recid(rfvparam) = recatu1 no-lock.
        
    if not available rfvparam
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(rfvparam).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available rfvparam
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
            find rfvparam where recid(rfvparam) = recatu1 /*no-lock*/.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(rfvparam.setor)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(rfvparam.setor)
                                        else "".
            run color-message.
            choose field rfvparam.setor vdesc help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/ .
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
                    if not avail rfvparam
                    then leave.
                    recatu1 = recid(rfvparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail rfvparam
                    then leave.
                    recatu1 = recid(rfvparam).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail rfvparam
                then next.
                color display white/red rfvparam.setor 
                    vdesc with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail rfvparam
                then next.
                color display white/red 
                    rfvparam.setor vdesc 
                    
                    with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-con:
                
                    for each tt-rfvparam. delete tt-rfvparam. end.
                    create tt-rfvparam. 
                    buffer-copy rfvparam to tt-rfvparam.
                    
                    run p-mostra.

                end.
                
                if esqcom1[esqpos1] = " Atualizar "
                then do:
                     
                     find rfvparam where recid(rfvparam) = recatu1.

                     run p-atualiza-recencia.
                     
                     message "Calcular Frequência e Valor ?"
                             update sresp.
                     if sresp
                     then do:
                        run p-media(input rfvparam.recencia-i[1],
                                    input rfvparam.recencia-f[5],
                                    input rfvparam.setor,
                                    output fre,
                                    output val).
                        run p-atu-fre-val.
                     end.
                         
                     run p-atualiza-frequencia.
                     run p-atualiza-valor.
                     
                     find rfvparam where recid(rfvparam) = recatu1 no-lock.
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
        recatu1 = recid(rfvparam).
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

    find categoria where categoria.catcod = rfvparam.setor no-lock no-error.
    if avail categoria
    then vdesc = categoria.catnom.
    else vdesc = "".

    if rfvparam.setor = 0 then vdesc = "G E R A L".
    
    display rfvparam.setor column-label "Código"
            vdesc          column-label "Setor"
            with frame frame-a 11 down centered color white/red row 5.

end procedure.
procedure color-message.
color display message
        rfvparam.setor vdesc
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        rfvparam.setor vdesc
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first rfvparam where true
                                                no-lock no-error.
    else  
        find last rfvparam  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next rfvparam  where true
                                                no-lock no-error.
    else  
        find prev rfvparam   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev rfvparam where true  
                                        no-lock no-error.
    else   
        find next rfvparam where true 
                                        no-lock no-error.
        
end procedure.
         



procedure p-atualiza-recencia:

    /*
    do on error undo:
        update skip
               rfvparam.setor label "Setor.........." format ">>>9"
               with frame f-etbset centered side-labels.

        if rfvparam.setor <> 0
        then do:
            find categoria where
                 categoria.catcod = rfvparam.setor no-lock no-error.
            if not avail categoria
            then do:
                message "Setor nao Cadastrado.".
                undo.
            end.
            else disp categoria.catnom no-label with frame f-etbset.
        end.    
        else disp "Todos" @ categoria.catnom with frame f-etbset.
    end.
    */
            
    do on error undo:
        update  rfvparam.recencia-i[1] label "1) Recência Inicial"
                rfvparam.recencia-f[1] label "Recência Final" skip
                rfvparam.recencia-i[2] label "2) Recência Inicial"
                rfvparam.recencia-f[2] label "Recência Final" skip
                rfvparam.recencia-i[3] label "3) Recência Inicial"
                rfvparam.recencia-f[3] label "Recência Final" skip
                rfvparam.recencia-i[4] label "4) Recência Inicial"
                rfvparam.recencia-f[4] label "Recência Final" skip        
                rfvparam.recencia-i[5] label "5) Recência Inicial"
                rfvparam.recencia-f[5] label "Recência Final" skip
                with frame f-r centered side-labels
                                title " Recência ".
    end.
end procedure.
    
procedure p-atualiza-frequencia:
    
    do on error undo:
        update  rfvparam.frequencia-i[1] label "1) Frequência Inicial"
                rfvparam.frequencia-f[1] label "Frequência Final" skip
                rfvparam.frequencia-i[2] label "2) Frequência Inicial"
                rfvparam.frequencia-f[2] label "Frequência Final" skip
                rfvparam.frequencia-i[3] label "3) Frequência Inicial"
                rfvparam.frequencia-f[3] label "Frequência Final" skip
                rfvparam.frequencia-i[4] label "4) Frequência Inicial"
                rfvparam.frequencia-f[4] label "Frequência Final" skip
                rfvparam.frequencia-i[5] label "5) Frequência Inicial"
                rfvparam.frequencia-f[5] label "Frequência Final" skip
                with frame f-f centered side-labels
                                title " Frequência ".
    end.
end procedure.
    
procedure p-atualiza-valor:    
    do on error undo:
        update  rfvparam.valor-i[1] label "1) Valor Inicial"
                rfvparam.valor-f[1] label "Valor Final" skip
                rfvparam.valor-i[2] label "2) Valor Inicial"
                rfvparam.valor-f[2] label "Valor Final" skip
                rfvparam.valor-i[3] label "3) Valor Inicial"
                rfvparam.valor-f[3] label "Valor Final" skip
                rfvparam.valor-i[4] label "4) Valor Inicial"
                rfvparam.valor-f[4] label "Valor Final" skip
                rfvparam.valor-i[5] label "5) Valor Inicial"
                rfvparam.valor-f[5] label "Valor Final" skip
                with frame f-v centered side-labels
                                title " Valor ".
    end.                                

end procedure.    



procedure p-mostra:

        find categoria where
             categoria.catcod = tt-rfvparam.setor no-lock no-error.

        disp skip
             tt-rfvparam.setor label "Setor.........." format ">>>9"
             categoria.catnom no-label when avail categoria
             with frame f-etbset centered side-labels.
             
        disp   tt-rfvparam.recencia-i[1] label "1) Recência Inicial"
                tt-rfvparam.recencia-f[1] label "Recência Final" skip
                tt-rfvparam.recencia-i[2] label "2) Recência Inicial"
                tt-rfvparam.recencia-f[2] label "Recência Final" skip
                tt-rfvparam.recencia-i[3] label "3) Recência Inicial"
                tt-rfvparam.recencia-f[3] label "Recência Final" skip
                tt-rfvparam.recencia-i[4] label "4) Recência Inicial"
                tt-rfvparam.recencia-f[4] label "Recência Final" skip        
                tt-rfvparam.recencia-i[5] label "5) Recência Inicial"
                tt-rfvparam.recencia-f[5] label "Recência Final" skip
                with frame f-mostra-r centered side-labels
                                title " Recência ".
    
        disp  tt-rfvparam.frequencia-i[1] label "1) Frequência Inicial"
              tt-rfvparam.frequencia-f[1] label "Frequência Final" skip
              tt-rfvparam.frequencia-i[2] label "2) Frequência Inicial"
              tt-rfvparam.frequencia-f[2] label "Frequência Final" skip
              tt-rfvparam.frequencia-i[3] label "3) Frequência Inicial"
              tt-rfvparam.frequencia-f[3] label "Frequência Final" skip
              tt-rfvparam.frequencia-i[4] label "4) Frequência Inicial"
              tt-rfvparam.frequencia-f[4] label "Frequência Final" skip
              tt-rfvparam.frequencia-i[5] label "5) Frequência Inicial"
              tt-rfvparam.frequencia-f[5] label "Frequência Final" skip
              with frame f-mostra-f centered side-labels
                                title " Frequência ".
    

        
        disp  tt-rfvparam.valor-i[1] label "1) Valor Inicial"
                tt-rfvparam.valor-f[1] label "Valor Final" skip
                tt-rfvparam.valor-i[2] label "2) Valor Inicial"
                tt-rfvparam.valor-f[2] label "Valor Final" skip
                tt-rfvparam.valor-i[3] label "3) Valor Inicial"
                tt-rfvparam.valor-f[3] label "Valor Final" skip
                tt-rfvparam.valor-i[4] label "4) Valor Inicial"
                tt-rfvparam.valor-f[4] label "Valor Final" skip
                tt-rfvparam.valor-i[5] label "5) Valor Inicial"
                tt-rfvparam.valor-f[5] label "Valor Final" skip
                with frame f-mostra-v centered side-labels   row 12
                                title " Valor ".

end procedure.


procedure p-media:

    def input parameter p-data1 as date format "99/99/9999".
    def input parameter p-data2 as date format "99/99/9999".
    def input parameter p-setor as int.
    
    def output parameter p-media-fre as int.
    def output parameter p-media-val as int.
    
    def var v-qtd-not as dec.
    def var v-qtd-cli as dec.
    def var v-valor like plani.platot.
    
    def var vconta as int.
    def var vloop as int.
    def var vmens2 as char.
    def var vtime as int.
  
    vmens2 =
    "  C A L C U L A N D O     *    *    *    *    *    *    *    *    *"
        + "   *    *".

    vtime = time.
    vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .

    for each estab no-lock:
        for each plani use-index pladat
                           where plani.movtdc = 5
                             and plani.etbcod = estab.etbcod
                             and plani.pladat >= rfvparam.recencia-i[1]
                             and plani.pladat <= rfvparam.recencia-f[5]
                             no-lock break by plani.desti:

            vloop = vloop + 1. 

            if vloop > 199
            then do: 
                put screen color normal    row 16  column 1 vmens2.
                put screen color messages  row 17  column 20 /*15*/
                " Decorridos : " + string(time - vtime,"HH:MM:SS") 
                + " Minutos    ".
             
                vmens2 = substring(vmens2,2,78) + substring(vmens2,1,1).
                vloop = 0.
            end.
 
            if plani.desti = 1
            then next.

            find first clien where 
                       clien.clicod = plani.desti no-lock no-error.
            if not avail clien
            then next.
            
            if p-setor <> 0
            then do:
            
                find first movim use-index movim
                             where movim.etbcod = plani.etbcod and
                                   movim.placod = plani.placod and
                                   movim.movtdc = plani.movtdc and
                                   movim.movdat = plani.pladat
                                   no-lock no-error.

                if not avail movim
                then next.
    
                find produ where produ.procod = movim.procod no-lock no-error.
                if not avail produ
                then next.
    
                if produ.catcod <> p-setor
                then next.
            
            end.
            
            assign v-qtd-not = v-qtd-not + 1.
                   v-valor = v-valor +(if plani.biss > 0
                                          then plani.biss
                                          else plani.platot).

            if first-of(plani.desti)
            then v-qtd-cli = v-qtd-cli + 1.
        end.
    end.

    assign p-media-fre = (v-qtd-not / v-qtd-cli)
           p-media-val = (v-valor   / v-qtd-cli).
           
end procedure.
    
procedure p-atu-fre-val:

    assign rfvparam.frequencia-i[1] = 0 
           rfvparam.frequencia-i[2] = (((fre * 2) * 20) / 100) 
           rfvparam.frequencia-i[3] = (((fre * 2) * 40) / 100) 
           rfvparam.frequencia-i[4] = (((fre * 2) * 60) / 100) 
           rfvparam.frequencia-i[5] = (((fre * 2) * 80) / 100)    
           
           rfvparam.frequencia-f[1] = rfvparam.frequencia-i[2] - 1 
           rfvparam.frequencia-f[2] = rfvparam.frequencia-i[3] - 1 
           rfvparam.frequencia-f[3] = rfvparam.frequencia-i[4] - 1 
           rfvparam.frequencia-f[4] = rfvparam.frequencia-i[5] - 1 
           rfvparam.frequencia-f[5] = 99999999.
 
    assign rfvparam.valor-i[1] = 0 
           rfvparam.valor-i[2] = (((val * 2) * 20) / 100) 
           rfvparam.valor-i[3] = (((val * 2) * 40) / 100) 
           rfvparam.valor-i[4] = (((val * 2) * 60) / 100) 
           rfvparam.valor-i[5] = (((val * 2) * 80) / 100) 
           
           rfvparam.valor-f[1] = rfvparam.valor-i[2] - 0.01 
           rfvparam.valor-f[2] = rfvparam.valor-i[3] - 0.01 
           rfvparam.valor-f[3] = rfvparam.valor-i[4] - 0.01 
           rfvparam.valor-f[4] = rfvparam.valor-i[5] - 0.01 
           rfvparam.valor-f[5] = 999999.99.


end procedure.