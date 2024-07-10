def buffer bbestoq for estoq.

def shared temp-table tt-curva
  field pos    like curva.pos
  field cod    like curva.cod
  field pronom like produ.pronom format "x(32)"
  field qtdcom like curva.qtdven
  field valven like curva.valven
  field qtdven like curva.qtdven
  field valcus like curva.valcus
  field qtdest like curva.qtdest
  field estcus like curva.estcus
  field estven like curva.estven
  field giro   like curva.giro
  index icurva valven desc.

def shared var v-q as dec format ">>,>>9".
def shared var v-v as dec format ">>>>,>>9".
def shared var v-c as dec format ">>>>,>>9".
def shared var v-e as dec format "->>>,>>9".

def var v-imagem as char.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Imagem "," "," "," "," "].
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

{admcab.i}

def buffer btt-curva for  tt-curva.
def var vtt-curva    like tt-curva.cod.

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row 
         screen-lines no-box no-labels side-labels column 1 centered.

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
        find tt-curva where recid(tt-curva) = recatu1 no-lock.
    if not available tt-curva
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-curva).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-curva
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
            find tt-curva where recid(tt-curva) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-curva.cod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-curva.cod)
                                        else "".
            run color-message.
            choose field tt-curva.cod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
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
                    if not avail tt-curva
                    then leave.
                    recatu1 = recid(tt-curva).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-curva
                    then leave.
                    recatu1 = recid(tt-curva).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-curva
                then next.
                color display white/red
             tt-curva.cod
             tt-curva.pronom tt-curva.qtdcom
             tt-curva.qtdven
             tt-curva.valcus
             tt-curva.valven
             tt-curva.qtdest
             tt-curva.giro        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-curva
                then next.
                color display white/red 
                     tt-curva.cod
                     tt-curva.pronom tt-curva.qtdcom
                     tt-curva.qtdven
                     tt-curva.valcus
                     tt-curva.valven
                     tt-curva.qtdest
                     tt-curva.giro  with frame frame-a.
             
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-curva
                 with frame f-tt-curva color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-curva on error undo.
                    create tt-curva.
                    update tt-curva.
                    recatu1 = recid(tt-curva).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-curva.
                    disp tt-curva.
                end.
                if esqcom1[esqpos1] = " Imagem "
                then do .
                     if opsys = "UNIX"
                     then do:
                         message "Opcao nao habilitada para Linux".
                         pause 2 no-message.
                         leave.
                     end.
                      
                      
                     /*if opsys = "UNIX"
                     then v-imagem = "/admcom/pro_im/" +
                                trim(string(tt-pro.procod)) +
                                ".jpg".

                     else*/ 
                                 
                     v-imagem = "l:~\pro_im~\" + 
                                trim(string(tt-curva.cod)) +
                                ".jpg".

                     if search(v-imagem) = ?
                     then do:
    
                        message "Imagem nao Encontrada".
                        pause 2 no-message.
                        
                     end.
                     else
                         os-command silent start value(v-imagem).
                       
                
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-curva.cod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next tt-curva where true no-error.
                    if not available tt-curva
                    then do:
                        find tt-curva where recid(tt-curva) = recatu1.
                        find prev tt-curva where true no-error.
                    end.
                    recatu2 = if available tt-curva
                              then recid(tt-curva)
                              else ?.
                    find tt-curva where recid(tt-curva) = recatu1
                            exclusive.
                    delete tt-curva.
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
                    then run ltt-curva.p (input 0).
                    else run ltt-curva.p (input tt-curva.cod).
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
        recatu1 = recid(tt-curva).
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
    find first bbestoq where bbestoq.procod = tt-curva.cod no-lock no-error.
    
    display
             tt-curva.cod format ">>>>>9" column-label "Codigo"
             tt-curva.pronom format "x(26)" column-label "Nome"
             tt-curva.qtdcom format ">>,>>9" column-label "Qtd.!Comp"

             tt-curva.qtdven format ">>,>>9" column-label "Qtd.V"
             tt-curva.valcus format ">>>>,>>9" column-label "Val.C."
             tt-curva.valven format ">>>>,>>9" column-label "Val.V."
             tt-curva.qtdest format "->>,>>9"    column-label "Qtd.E"
             tt-curva.giro when tt-curva.giro > 0 format ">99" column-label "Gr"
        with frame frame-a 10 down centered color white/red row 5.
    
    if avail bbestoq then
    message tt-curva.pronom " Pc. Custo:R$ " bbestoq.estcusto 
            " Pc.Venda:R$ " bbestoq.estvenda.
    
    hide frame f-ddd no-pause.
    hide message no-pause.
    
end procedure.

procedure color-message.

    find first bbestoq where bbestoq.procod = tt-curva.cod no-lock no-error.

    color display message
             tt-curva.cod format ">>>>>9" column-label "Codigo"

             tt-curva.pronom format "x(26)" column-label "Nome"
             tt-curva.qtdcom format ">>,>>9" column-label "Qtd.!Comp"
             
             /*tt-curva.pronom format "x(32)" column-label "Nome"*/
             tt-curva.qtdven format ">>,>>9" column-label "Qtd.V"
             tt-curva.valcus format ">>>>,>>9" column-label "Val.C."
             tt-curva.valven format ">>>>,>>9" column-label "Val.V."
             tt-curva.qtdest format "->>,>>9"    column-label "Qtd.E"
             tt-curva.giro when tt-curva.giro > 0 format ">99" column-label "Gr"
            with frame frame-a.


    /*message "                             "
            v-q "  " v-v "  " v-c "  " v-e.*/

   disp "Totais ->" at 2
        v-q no-label format ">>,>>9"    to 49
        v-c no-label format ">>>>,>>9"  to 59
        v-v no-label format ">>>>,>>9"  to 68        
        v-e no-label format "->>>,>>9"  to 77
        with frame f-ddd no-box side-labels.
    /*message tt-curva.pronom.        */
    if avail bbestoq then
        message tt-curva.pronom " Pc. Custo:R$ " bbestoq.estcusto 
            " Pc.Venda:R$ " bbestoq.estvenda.
    

end procedure.
procedure color-normal.
    find first bbestoq where bbestoq.procod = tt-curva.cod no-lock no-error.

    color display normal
             tt-curva.cod format ">>>>>9" column-label "Codigo"
             tt-curva.pronom format "x(26)" column-label "Nome"
             tt-curva.qtdcom format ">>,>>9" column-label "Qtd.!Comp"
             tt-curva.qtdven format ">>,>>9" column-label "Qtd.V"
             tt-curva.valcus format ">>>>,>>9" column-label "Val.C."
             tt-curva.valven format ">>>>,>>9" column-label "Val.V."
             tt-curva.qtdest format "->>,>>9"    column-label "Qtd.E"
             tt-curva.giro when tt-curva.giro > 0 format ">99" column-label "Gr"

        with frame frame-a.
    /*message tt-curva.pronom.        */
    if avail bbestoq then
    message tt-curva.pronom " Pc. Custo:R$ " bbestoq.estcusto 
            " Pc.Venda:R$ " bbestoq.estvenda.
    

hide frame f-ddd no-pause.
hide message no-pause.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-curva where true
                                                no-lock no-error.
    else  
        find last tt-curva  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-curva  where true
                                                no-lock no-error.
    else  
        find prev tt-curva   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-curva where true  
                                        no-lock no-error.
    else   
        find next tt-curva where true 
                                        no-lock no-error.
        
end procedure.
         
