{admcab.i}


def var vtitulo as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Procura "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de prodsite ",
             " Alteracao da prodsite ",
             " Exclusao  da prodsite ",
             " Consulta  da prodsite ",
             " Listagem  Geral de prodsite "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].


def buffer bprodsite       for prodsite.
def var vprodsite         like prodsite.procod.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
form
    with frame f-prodsite title vtitulo overlay side-labels row 9.
    
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
        find prodsite where recid(prodsite) = recatu1 no-lock.
  
    if not available prodsite
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.
    
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(prodsite).
    
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available prodsite
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
        hide frame  f-prodsite no-pause.
        view frame frame-a.
        if not esqvazio
        then do:
            find prodsite where recid(prodsite) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(prodsite.procod)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(prodsite.procod)
                                        else "".
            run color-message.
            choose field prodsite.procod help ""
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
                    if not avail prodsite
                    then leave.
                    recatu1 = recid(prodsite).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail prodsite
                    then leave.
                    recatu1 = recid(prodsite).
                end.
                leave.
            end.

            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail prodsite
                then next.
                color display white/red prodsite.procod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail prodsite
                then next.
                color display white/red prodsite.procod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form prodsite.procod
                 with frame f-prodsite centered.
                 
            /*hide frame frame-a no-pause.*/

            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-prodsite on error undo.
                    vtitulo = " Inclusao ".
                    pause 0.
                    
                    create prodsite.
                    
                    update prodsite.procod label "Produto......".
                    
                    find produ where 
                         produ.procod = prodsite.procod no-lock no-error.
                         
                    if not avail produ
                    then do:
                        message "Produto nao cadastrado.".
                        undo.
                    end.
                    else disp produ.pronom no-label with frame f-prodsite.
                    
                    prodsite.cc1 = produ.pronom.
                    
                    update prodsite.cc1      label "Nome Site...."
                           format "x(50)"
                           prodsite.visivel  label "Visivel......" 
                           format "Sim/Nao"
                           help "O produto sera visivel no site Sim/Nao"
                           skip
                           prodsite.exportar label "Exportar....." 
                           format "Sim/Nao"
                           help "Exporar o produto para o site Sim/Nao"
                           skip
                           prodsite.ci1 label "Ordem no Site".
                    
                    find current prodsite no-lock.
                    

                    os-command silent "l:\site\editor.exe " 
                                      value(string(prodsite.procod))
                                      " " value(produ.pronom).
                               
                    recatu1 = recid(prodsite).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta "
                then do with frame f-prodsite.
                    pause 0.
                    vtitulo = " Consulta ".
                    find produ where 
                         produ.procod = prodsite.procod no-lock no-error.
                         
                    disp prodsite.procod
                         produ.pronom when avail produ
                         
                         prodsite.cc1      label "Nome Site...." 
                         format "x(50)"
                         
                         prodsite.visivel
                         prodsite.exportar skip 
                         prodsite.ci1 label       "Ordem no Site" 
                         prodsite.cd1 label "Estoque minimo"
                         .
                end.

                if esqcom1[esqpos1] = " Procura "
                then do with frame f-procura 
                            overlay row 9 1 column centered:
                     pause 0.
                     prompt-for prodsite.procod format ">>>>>>>>>9" 
                                with no-validate.

                     find prodsite using prodsite.procod.
                     if not avail prodsite
                     then do:
                         message "Produto Invalido".
                         undo.
                     end.
                     
                     if avail prodsite
                     then recatu1 = recid(prodsite).
                     else recatu1 = ?.
                     
                     leave.
                
                end.
                
                if esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prodsite.
                    pause 0.
                    disp prodsite.procod.

                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-prodsite on error undo.
                    vtitulo = " Alteracao ".
                            pause 0.
                    find prodsite where
                            recid(prodsite) = recatu1 
                        exclusive.
                        
                    disp   prodsite.procod.

                    update prodsite.cc1
                           prodsite.visivel
                           prodsite.exportar
                           prodsite.ci1 label "Ordem no Site"
                           prodsite.cd1 label "Estoque minimo"
                           .
                                        find current prodsite no-lock.
                   
                    sresp = no.
                    message "Incluir descricao dos produtos ?" update sresp.
                    if sresp
                    then do:
                        find produ where 
                             produ.procod = prodsite.procod no-lock no-error.
                        
                        os-command silent "l:\site\editor.exe " 

                                          value(string(prodsite.procod))
                                          " " value(produ.pronom).
                    end.
                end.
                
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                        pause 0.
                    vtitulo = " Exclusao ".                        
                    message "Confirma Exclusao de" prodsite.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next prodsite where true no-error.
                    if not available prodsite
                    then do:
                        find prodsite where recid(prodsite) = recatu1.
                        find prev prodsite where true no-error.
                    end.
                    recatu2 = if available prodsite
                              then recid(prodsite)
                              else ?.
                    find prodsite where recid(prodsite) = recatu1
                            exclusive.
                    delete prodsite.
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
                    then run lprodsite.p (input 0).
                    else run lprodsite.p (input prodsite.procod).
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
        recatu1 = recid(prodsite).
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
    /*find produ where produ.procod = prodsite.procod no-lock no-error. */

    display prodsite.procod
            /*produ.pronom*/
            prodsite.cc1 /*when avail produ*/ format "x(42)"
            column-label "Nome Produto no Site"
            prodsite.visivel  format "Sim/Nao"
            prodsite.exportar format "Sim/Nao"
            prodsite.ci1       format ">>>9" column-label "Ordem!Site"
            with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
    /*find produ where produ.procod = prodsite.procod no-lock no-error. */

    color display message
            prodsite.procod
            /*produ.pronom when avail produ*/
            prodsite.cc1
            prodsite.visivel  format "Sim/Nao"
            prodsite.exportar format "Sim/Nao"
            prodsite.ci1       format ">>>9"
            with frame frame-a.
end procedure.
procedure color-normal.
    /*find produ where produ.procod = prodsite.procod no-lock no-error. */

    color display normal
            prodsite.procod
            prodsite.cc1 /*produ.pronom when avail produ*/
            prodsite.visivel  format "Sim/Nao"
            prodsite.exportar format "Sim/Nao"
            prodsite.ci1       format ">>>9"
            with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first prodsite where true
                                                no-lock no-error.
    else  
        find last prodsite  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next prodsite  where true
                                                no-lock no-error.
    else  
        find prev prodsite   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev prodsite where true  
                                        no-lock no-error.
    else   
        find next prodsite where true 
                                        no-lock no-error.
        
end procedure.
         
