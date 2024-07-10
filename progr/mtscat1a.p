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
def var i_catcod        like categoria.catcod.


/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 4
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "].

/* regua de baixo*/

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
            
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  Categoria ",
             " Alteracao Categoria ",
             " Exclusao  Categoria ",
             " Consulta  Categoria ",
             " Listagem  Geral categoria "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer bcadmetascategoria      for cadmetascategoria.
def var vcadmetascategoria         like cadmetascategoria.codmeta.


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
        find cadmetascategoria where recid(cadmetascategoria) = recatu1 no-lock.
    if not available cadmetascategoria
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetascategoria).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetascategoria
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
            find cadmetascategoria where recid(cadmetascategoria) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetascategoria.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetascategoria.codmeta)
                                        else "".
            run color-message.
            choose field cadmetascategoria.codmeta help ""
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
                    if not avail cadmetascategoria
                    then leave.
                    recatu1 = recid(cadmetascategoria).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetascategoria
                    then leave.
                    recatu1 = recid(cadmetascategoria).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetascategoria
                then next.
                color display white/red cadmetascategoria.codmeta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetascategoria
                then next.
                color display white/red cadmetascategoria.codmeta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form cadmetascategoria.codmeta
                 cadmetascategoria.catcod column-label "Departamento"
                 with frame f-cadmetascategoria color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetascategoria.codmeta
                 i_catcod column-label "Departamento"
                 with frame f-cadmetascategoriaal color black/cyan
                      centered side-label row 5 width 80.

            form cadmetascategoria.codmeta
                 cadmetascategoria.catcod column-label "Departamento"
                 with frame f-cadmetascategoriaco color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetascategoria.codmeta
                 cadmetascategoria.catcod column-label "Departamento"
                 with frame f-cadmetascategoriaex color black/cyan
                      centered side-label row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cadmetascategoria on error undo.

                    run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetascategoria).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetascategoria.
                    disp cadmetascategoria.codmeta
                         cadmetascategoria.catcod column-label "Departamento"
                         with side-labels 1 col.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetascategoriaal.
                    disp cadmetascategoria.codmeta
                         i_catcod column-label "Departamento".
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetascategoriaal on error undo.

                    find cadmetascategoria where
                            recid(cadmetascategoria) = recatu1 exclusive.
                   
                    assign i_catcod  = cadmetascategoria.catcod
                           i_codaux1 = cadmetascategoria.codmeta
                           i_codaux2 = cadmetascategoria.catcod.
                    
                    update i_catcod column-label "Departamento"
                           with side-label 1 col.

                    find first bcadmetascategoria where
                               bcadmetascategoria.codmeta = i_codmeta and 
                               bcadmetascategoria.catcod  = i_catcod
                               no-lock no-error.
                    if avail bcadmetascategoria
                    then do:           
                            message "Departamento ja existe, favor" skip
                                    "digitar outro!"
                                    view-as alert-box.
                            undo, retry.
                    end.     

                    find first categoria where
                               categoria.catcod = i_catcod no-lock no-error.
                    if not avail categoria
                    then do:
                            message "Departamento nao encontrada!"
                                    view-as alert-box.
                            undo, retry.        
                    end.

                    assign cadmetascategoria.catcod = input i_catcod.

                    leave.
                             
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de " cadmetascategoria.catcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetascategoria where 
                              cadmetascategoria.codmeta = p_codmeta no-error.
                    if not available cadmetascategoria
                    then do:
                        find cadmetascategoria where recid(cadmetascategoria) = recatu1.
                        find prev cadmetascategoria where 
                                 cadmetascategoria.codmeta = p_codmeta no-error.
                    end.
                    recatu2 = if available cadmetascategoria
                              then recid(cadmetascategoria)
                              else ?.
                    find cadmetascategoria where recid(cadmetascategoria) = recatu1
                            exclusive.
                    assign i_codaux1 = cadmetascategoria.codmeta
                           i_codaux2 = cadmetascategoria.catcod.
                    delete cadmetascategoria.
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
                    then run lcadmetascategoria.p (input 0).
                    else run lcadmetascategoria.p (input cadmetascategoria.codmeta).
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
        recatu1 = recid(cadmetascategoria).
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
display cadmetascategoria 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        cadmetascategoria.codmeta
        cadmetascategoria.catcod column-label "Departamento"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cadmetascategoria.codmeta
        cadmetascategoria.catcod column-label "Departamento"
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetascategoria where 
                   cadmetascategoria.codmeta = p_codmeta   
                                                no-lock no-error.
    else  
        find last cadmetascategoria  where 
                  cadmetascategoria.codmeta = p_codmeta 
                                                no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetascategoria  where 
                  cadmetascategoria.codmeta = p_codmeta
                                                no-lock no-error.
    else  
        find prev cadmetascategoria   where 
                  cadmetascategoria.codmeta = p_codmeta
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetascategoria where 
                  cadmetascategoria.codmeta = p_codmeta       
                                        no-lock no-error.
    else   
        find next cadmetascategoria where 
                  cadmetascategoria.codmeta = p_codmeta
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var c_nomMeta   like cadmetas.nommeta.
   def var i_catcod    like categoria.catcod.
   def var c_catnom    like categoria.catnom.

   def frame f-inc 
       i_codmeta       at 12        label "Meta"            form ">>>>>>>9"
       c_nommeta       at 27        no-label                form "x(30)"   
       skip
       i_catcod        at 01        label "Departamento"
       c_catnom        at 27        no-label                form "x(22)"
       with side-labels  1 down width 80
            overlay title "INCLUSAO".
   
   disp i_codmeta
        c_nomMeta
        i_catcod
        c_catnom
        with frame f-inc.
        
   find first cadmetas where
              cadmetas.codmeta = i_codmeta no-lock no-error.
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
  
   update i_catcod
          with frame f-inc.

   find first cadmetascategoria where
              cadmetascategoria.codmeta = i_codmeta and
              cadmetascategoria.catcod  = i_catcod no-lock no-error.
   if avail cadmetascategoria
   then do:
           message "Meta ja existe com o Departamento!"
                   view-as alert-box.
           undo, retry.                    
   end.

   find first categoria where
              categoria.catcod = i_catcod no-lock no-error.
   if not avail categoria
   then do:
           message "Departamento não encontrado!"
                   view-as alert-box.
           undo, retry.        
   end.

   assign c_catnom = categoria.catnom.
   disp c_catnom with frame f-inc. 

   create cadmetascategoria.
   assign cadmetascategoria.codmeta = i_codmeta
          cadmetascategoria.catcod  = i_catcod.

   pause 0 no-message.
   

end procedure.
