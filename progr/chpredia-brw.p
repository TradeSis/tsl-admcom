def shared temp-table tt-data
    field etbcod like estab.etbcod
    field datmov like deposito.datmov
    field chedre like deposito.chedre
    field chedia like deposito.chedia
    field lote   like lotdep.lote.
 
def input parameter vpre like plani.platot.
def input parameter vdia like plani.platot.
def shared temp-table tt-chq like chq
    field lote like lotdep.lote.

def var varquivo as char.
def var vqtd     as int.

def shared var vtipo as log format "PRE/DIA".
def shared var vdata  as date format "99/99/9999".

def var vtot            like plani.platot.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Imprimir "," "," "," "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" ",
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

{admcab.i}

def buffer btt-chq       for tt-chq.
def var vtt-chq         like tt-chq.numero.



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
        find tt-chq where recid(tt-chq) = recatu1 no-lock.
    if not available tt-chq
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-chq).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-chq
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
            find tt-chq where recid(tt-chq) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-chq.numero)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-chq.numero)
                                        else "".
            run color-message.
            choose field 
                tt-chq.data
                tt-chq.banco
                tt-chq.agencia
                tt-chq.conta
                tt-chq.numero
                tt-chq.datemi
                tt-chq.valor
                tt-chq.lote
                help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) color white/black.
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
                    if not avail tt-chq
                    then leave.
                    recatu1 = recid(tt-chq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-chq
                    then leave.
                    recatu1 = recid(tt-chq).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-chq
                then next.
                color display white/red               
                    tt-chq.data    label "Data"
                    tt-chq.banco   label "Banco"
                    tt-chq.agencia label "Agencia"
                    tt-chq.conta   label "Conta" 
                    tt-chq.numero  label "Numero" 
                    tt-chq.datemi  label "Dt.Emissao"
                    tt-chq.valor   label "Valor"                
                    tt-chq.lote    label "Lote"
                with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-chq
                then next.
                color display white/red 
                    tt-chq.data    label "Data"
                    tt-chq.banco   label "Banco"
                    tt-chq.agencia label "Agencia"
                    tt-chq.conta   label "Conta" 
                    tt-chq.numero  label "Numero" 
                    tt-chq.datemi  label "Dt.Emissao"
                    tt-chq.valor   label "Valor"                
                    tt-chq.lote    label "Lote"
                with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-chq
                 with frame f-tt-chq color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-chq on error undo.
                    create tt-chq.
                    update tt-chq.
                    recatu1 = recid(tt-chq).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-chq.
                    disp tt-chq.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-chq on error undo.
                    find tt-chq where
                            recid(tt-chq) = recatu1 
                        exclusive.
                    update tt-chq.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-chq.numero
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-chq where true no-error.
                    if not available tt-chq
                    then do:
                        find tt-chq where recid(tt-chq) = recatu1.
                        find prev tt-chq where true no-error.
                    end.
                    recatu2 = if available tt-chq
                              then recid(tt-chq)
                              else ?.
                    find tt-chq where recid(tt-chq) = recatu1
                            exclusive.
                    delete tt-chq.
                    recatu1 = recatu2.
                    leave.
                end.
                
                vqtd = 0.
                if esqcom1[esqpos1] = " Imprimir "
                then do with frame f-Lista:



                    
                    vtot = 0.
                    vpre = 0.
                    vdia = 0.
                    for each tt-chq no-lock break by tt-chq.lote:

                        
                        vtot = vtot + tt-chq.valor.
                        
                        if first-of(tt-chq.lote)
                        then do:
                            
                            varquivo = "l:\relat\ch." + string(time) +
                                        string(tt-chq.lote).
                    
                            {mdadmcab.i
                                &Saida     = "value(varquivo)"
                                &Page-Size = "0" 
                                &Cond-Var  = "80" 
                                &Page-Line = "0" 
                                &Nom-Rel   = ""chpredia""
                                &Nom-Sis   = """SISTEMA FINANCEIRO"""
                                &Tit-Rel   = """LISTAGEM DE CHEQUES "" 
                                             + "" - "" +
                                             string(vtipo,""PRE/DIA"") + 
                                             "" DIA "" + 
                                             string(vdata,""99/99/9999"")"
                                &Width     = "80"
                                &Form      = "frame f-cabcab"}
                        
                        end.
                        
                        display 
                            tt-chq.data    column-label "Data"
                            tt-chq.banco   column-label "Banco"
                            tt-chq.agencia column-label "Agencia"
                            tt-chq.conta   column-label "Conta" 
                            tt-chq.numero  column-label "Numero" 
                            tt-chq.datemi  column-label "Dt.Emissao"
                            tt-chq.valor   column-label "Valor"
                            tt-chq.lote    column-label "Lote"
                                with frame f-imp width 80 down.
                                
                        vqtd = vqtd + 1.
                                
                                
                        if last-of(tt-chq.lote)
                        then do: 
                         
                            
                            put skip(1) "Total......" to 52 vtot.
                            
                            if vtipo
                            then do:
                                for each tt-data where 
                                         tt-data.lote = tt-chq.lote:
                                    vpre = vpre + tt-data.chedre. 
                                end.         

                                
                                put skip "Informado.." to 52 vpre skip
                                         "Diferenca.." to 52 (vpre - vtot)
                                            format "->>>,>>9.99".
                            end.
                            else do: 

                                for each tt-data where 
                                         tt-data.lote = tt-chq.lote:
                                    vdia = vdia + tt-data.chedia. 
                                end.         

                                put skip "Informado.." to 52 vdia skip
                                         "Diferenca.." to 52 (vdia - vtot)
                                            format "->>>,>>9.99".

                            
                            end.
                            put skip "Qtd.Cheques" to 52 vqtd.
                                                         
                     
                            vtot = 0.
                            vpre = 0.
                            vdia = 0.
                            vqtd = 0.
                            
                            output close. 
                            {mrod.i}    
                    
                        end.
                    
                    end.
                    
                    
                    
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
        recatu1 = recid(tt-chq).
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
display 
    tt-chq.data    column-label "Data"
    tt-chq.banco   column-label "Banco"
    tt-chq.agencia column-label "Agencia"
    tt-chq.conta   column-label "Conta" 
    tt-chq.numero  column-label "Numero" 
    tt-chq.datemi  column-label "Dt.Emissao"
    tt-chq.valor   column-label "Valor" 
    tt-chq.lote    column-label "Lote" 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
    tt-chq.data    column-label "Data"
    tt-chq.banco   column-label "Banco"
    tt-chq.agencia column-label "Agencia"
    tt-chq.conta   column-label "Conta" 
    tt-chq.numero  column-label "Numero" 
    tt-chq.datemi  column-label "Dt.Emissao"
    tt-chq.valor   column-label "Valor"
    tt-chq.lote    column-label "Lote"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
    tt-chq.data    column-label "Data"
    tt-chq.banco   column-label "Banco"
    tt-chq.agencia column-label "Agencia"
    tt-chq.conta   column-label "Conta" 
    tt-chq.numero  column-label "Numero" 
    tt-chq.datemi  column-label "Dt.Emissao"
    tt-chq.valor   column-label "Valor"
    tt-chq.lote    column-label "Lote"
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-chq where true
                                                no-lock no-error.
    else  
        find last tt-chq  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-chq  where true
                                                no-lock no-error.
    else  
        find prev tt-chq   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-chq where true  
                                        no-lock no-error.
    else   
        find next tt-chq where true 
                                        no-lock no-error.
        
end procedure.
         
