{admcab.i}

def input parameter r_recid as recid.
def input param     p_codmeta as inte.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.

def var i_codaux1       as inte.
def var i_codaux2       as inte.

def var i_codmeta       like cadmetas.codmeta.
def var i_fabcod        like fabri.fabcod.


/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 4
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "].

/* regua de baixo*/

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
            
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  fabrielecimento ",
             " Alteracao fabrielecimento ",
             " Exclusao  fabrielecimento ",
             " Consulta  fabrielecimento ",
             " Listagem  Geral fabrielecimento "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer bcadmetasfabri      for cadmetasfabr.
def var vcadmetasfabri         like cadmetasfabri.codmeta.


form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.

find first cadmetas where
           recid(cadmetas) = r_recid no-lock no-error.
if not avail cadmetas
then do:
        message "Parametro de meta não foi encontrado!"
                view-as alert-box.
        undo, retry.           
end.
else do:
        assign i_codmeta = cadmetas.codmeta.
end.

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
        find cadmetasfabri where recid(cadmetasfabri) = recatu1 no-lock.
    if not available cadmetasfabri
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetasfabri).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetasfabri
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
            find cadmetasfabri where recid(cadmetasfabri) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetasfabri.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetasfabri.codmeta)
                                        else "".
            run color-message.
            choose field cadmetasfabri.codmeta help ""
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
                    if not avail cadmetasfabri
                    then leave.
                    recatu1 = recid(cadmetasfabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetasfabri
                    then leave.
                    recatu1 = recid(cadmetasfabri).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetasfabri
                then next.
                color display white/red cadmetasfabri.codmeta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetasfabri
                then next.
                color display white/red cadmetasfabri.codmeta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form cadmetasfabri.codmeta
                 cadmetasfabri.fabcod column-label "Fornecedor"
                 with frame f-cadmetasfabri color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasfabri.codmeta
                 i_fabcod column-label "Fornecedor"
                 with frame f-cadmetasfabrial color black/cyan
                      centered side-label row 5 width 80.

            form cadmetasfabri.codmeta
                 cadmetasfabri.fabcod column-label "Fornecedor"
                 with frame f-cadmetasfabrico color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasfabri.codmeta
                 cadmetasfabri.fabcod column-label "Fornecedor"
                 with frame f-cadmetasfabriex color black/cyan
                      centered side-label row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cadmetasfabri on error undo.

                    run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetasfabri).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetasfabri.
                    disp cadmetasfabri.codmeta
                         cadmetasfabri.fabcod column-label "Fornecedor"
                         with side-labels 1 col.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasfabrial.
                    disp cadmetasfabri.codmeta
                         i_fabcod column-label "Fornecedor".
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasfabrial on error undo.

                    find cadmetasfabri where
                            recid(cadmetasfabri) = recatu1 exclusive.
                   
                    assign i_fabcod  = cadmetasfabri.fabcod
                           i_codaux1 = cadmetasfabri.codmeta
                           i_codaux2 = cadmetasfabri.fabcod.
                    
                    update i_fabcod column-label "Fornecedor"
                           with side-label 1 col.

                    find first bcadmetasfabri where
                               bcadmetasfabri.codmeta = i_codmeta and
                               bcadmetasfabri.fabcod  = i_fabcod
                               no-lock no-error.
                    if avail bcadmetasfabri
                    then do:           
                            message "Fornecedor ja existe, favor" skip
                                    "digitar outro!"
                                    view-as alert-box.
                            undo, retry.
                    end.     

                    assign cadmetasfabri.fabcod = input i_fabcod.

                    leave.
                             
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" cadmetasfabri.fabcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetasfabri where 
                              cadmetasfabri.codmeta = p_codmeta no-error.
                    if not available cadmetasfabri
                    then do:
                        find cadmetasfabri where recid(cadmetasfabri) = recatu1.
                        find prev cadmetasfabri where 
                                  cadmetasfabri.codmeta = p_codmeta no-error.
                    end.
                    recatu2 = if available cadmetasfabri
                              then recid(cadmetasfabri)
                              else ?.                          
                    find cadmetasfabri where recid(cadmetasfabri) = recatu1
                            exclusive.
                    assign i_codaux1 = cadmetasfabri.codmeta
                           i_codaux2 = cadmetasfabri.fabcod.
                    delete cadmetasfabri.
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
                    then run lcadmetasfabri.p (input 0).
                    else run lcadmetasfabri.p (input cadmetasfabri.codmeta).
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " x "
                then do:

                    message "x" view-as alert-box.
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
        recatu1 = recid(cadmetasfabri).
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
display cadmetasfabri 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        cadmetasfabri.codmeta
        cadmetasfabri.fabcod column-label "Fornecedor"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cadmetasfabri.codmeta
        cadmetasfabri.fabcod column-label "Fornecedor"
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.

if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetasfabri where cadmetasfabri.codmeta = p_codmeta  
                                                no-lock no-error.
    else   
        find last cadmetasfabri  where cadmetasfabri.codmeta = p_codmeta  
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetasfabri  where cadmetasfabri.codmeta = p_codmeta  
                                                no-lock no-error.
    else  
        find prev cadmetasfabri   where cadmetasfabri.codmeta = p_codmeta  
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetasfabri where cadmetasfabri.codmeta = p_codmeta 
                                        no-lock no-error.
    else   
        find next cadmetasfabri where cadmetasfabri.codmeta = p_codmeta  
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var c_nomMeta   like cadmetas.nommeta.
   def var i_fabcod    like fabri.fabcod.
   def var c_fabnom    like fabri.fabnom.

   def frame f-inc 
       i_codmeta       at 12        label "Meta"            form ">>>>>>>9"
       c_nommeta       at 27        no-label                form "x(30)"   
       skip
       i_fabcod        at 01        label "Fornecedor"
       c_fabnom        at 27        no-label                form "x(22)"
       with side-labels  1 down width 80
            overlay title "INCLUSAO".
   
   disp i_codmeta
        c_nomMeta
        i_fabcod
        c_fabnom
        with frame f-inc.
        
   find first cadmetas where
              cadmetas.codmeta = p_codmeta no-lock no-error.
   if not avail cadmetas
   then do:
           assign c_nommeta =  "Meta não encontrada!".
           disp c_nommeta with frame f-inc.
           undo, retry. 
   end.
   else do:
           assign c_nommeta = cadmetas.nommeta.
           disp c_nommeta with frame f-inc.
   end.
  
   update i_fabcod
          with frame f-inc.

   find first cadmetasfabri where
              cadmetasfabri.codmeta = i_codmeta and
              cadmetasfabri.fabcod  = i_fabcod no-lock no-error.
   if avail cadmetasfabri
   then do:
           message "Meta ja existe com o Fornecedor!"
                   view-as alert-box.
           undo, retry.                    
   end.

   find first fabri where
              fabri.fabcod = i_fabcod no-lock no-error.
   if not avail fabri
   then do:
           message "Fornecedor não encontrado!"
                   view-as alert-box.
           undo, retry.        
   end.

   assign c_fabnom = fabri.fabnom.
   disp c_fabnom with frame f-inc. 

   create cadmetasfabri.
   assign cadmetasfabri.codmeta = i_codmeta
          cadmetasfabri.fabcod  = i_fabcod.

  pause 0 no-message.
  
end procedure.
