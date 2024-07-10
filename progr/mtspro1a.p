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
def var i_procod        like produ.procod.

def var i_fabcod        like fabri.fabcod label "Fornecedor".
def var i_catcod        like categoria.catcod label "Departamento".
def var i_clacod        like clase.clacod label "Classe".
def var vcla2-cod         like clase.clacod label "Grupo".
def var i_entravaz      as inte init 0.
def var l_confirma      as logi init no.

/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Exc/Prods"].

/* regua de baixo*/

def var esqcom2         as char format "x(18)" extent 3
            initial [" Fornecedor "," Departamento "," Classe "].
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  Produto ",
             " Alteracao Produto ",
             " Exclusao  Produto ",
             " Consulta  Produto ",
             " Exclusao de todos produtos "].
def var esqhel2         as char format "x(12)" extent 6
   initial [" ",
            " ",
            " ",
            " ",
            " "].

def var esqpro1         as char form   "x(13)" extent 7
        initial [" Produto      ",
                 " Fornecedor   ",
                 " Departamento ",
                 " Sub Classe       ",
                 " Grupo        ",
                 " Setor        ",
                 " Classe       "].

def buffer bcadmetasprodu      for cadmetasprodu.
def var vcadmetasprodu         like cadmetasprodu.codmeta.

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
        find cadmetasprodu where recid(cadmetasprodu) = recatu1 no-lock.
    if not available cadmetasprodu
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetasprodu).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetasprodu
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
            find cadmetasprodu where recid(cadmetasprodu) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetasprodu.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetasprodu.codmeta)
                                        else "".
            run color-message.
            choose field cadmetasprodu.codmeta help ""
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
                    esqpos2 = if esqpos2 = 3 then 3 else esqpos2 + 1.
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
                    if not avail cadmetasprodu
                    then leave.
                    recatu1 = recid(cadmetasprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetasprodu
                    then leave.
                    recatu1 = recid(cadmetasprodu).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetasprodu
                then next.
                color display white/red cadmetasprodu.codmeta with frame frame-~~a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetasprodu
                then next.
                color display white/red cadmetasprodu.codmeta with frame frame-~~a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio 
        then do:

            form cadmetasprodu.codmeta
                 cadmetasprodu.procod column-label "Produto"
                 with frame f-cadmetasprodu color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasprodu.codmeta
                 i_procod column-label "Produto"
                 with frame f-cadmetasprodual color black/cyan
                      centered side-label row 5 width 80.

            form cadmetasprodu.codmeta
                 cadmetasprodu.procod column-label "Produto"
                 with frame f-cadmetasproduco color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasprodu.codmeta
                 cadmetasprodu.procod column-label "Produto"
                 with frame f-cadmetasproduex color black/cyan
                      centered side-label row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                
                if esqcom1[esqpos1] = " Inclusao " or esqvazio 
                then do with frame f-cadmetasprodu on error undo.

                    if esqvazio = yes
                    then run pi-menu.
                    else run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetasprodu).
                    leave.
                end.
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetasprodu.
                    disp cadmetasprodu.codmeta
                         cadmetasprodu.procod column-label "Produto"
                         with side-labels 1 col.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasprodual.
                    disp cadmetasprodu.codmeta
                         i_procod column-label "Produto".
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasprodual on error undo.

                    find cadmetasprodu where
                            recid(cadmetasprodu) = recatu1 exclusive.
                   
                    assign i_procod  = cadmetasprodu.procod
                           i_codaux1 = cadmetasprodu.codmeta
                           i_codaux2 = cadmetasprodu.procod.
                    
                    update i_procod column-label "Produto"
                           with side-label 1 col.

                    find first bcadmetasprodu where
                               bcadmetasprodu.codmeta = i_codmeta and 
                               bcadmetasprodu.procod  = i_procod
                               no-lock no-error.
                    if avail bcadmetasprodu
                    then do:           
                            message "Produto ja existe, favor" skip
                                    "digitar outro!"
                                    view-as alert-box.
                            undo, retry.
                    end.     

                    find first produ where
                               produ.procod = i_procod no-lock no-error.
                    if not avail produ
                    then do:
                            message "Produto nao encontrado!"
                                    view-as alert-box.
                            undo, retry.        
                    end.

                    assign cadmetasprodu.procod = input i_procod.

                    leave.
                             
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de produto" cadmetasprodu.procod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetasprodu where true no-error.
                    if not available cadmetasprodu
                    then do:
                        find cadmetasprodu where recid(cadmetasprodu) = recatu1.
                        find prev cadmetasprodu where 
                                  cadmetasprodu.codmeta = p_codmeta no-error.
                    end.
                    recatu2 = if available cadmetasprodu
                              then recid(cadmetasprodu)
                              else ?.
                    find cadmetasprodu where recid(cadmetasprodu) = recatu1
                            exclusive.
                    assign i_codaux1 = cadmetasprodu.codmeta
                           i_codaux2 = cadmetasprodu.procod.
                    delete cadmetasprodu.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Exc/Prods "
                then do:
                  message "Confirma exclusao de todos produtos" skip
                          "Meta " cadmetasprodu.codmeta 
                          view-as alert-box buttons yes-no title "EXCLUIR"
                                  update l_confirma.

                  if l_confirma = yes
                  then do:
                          assign i_codaux1 = cadmetasprodu.codmeta.
                          for each cadmetasprodu where
                                   cadmetasprodu.codmeta = i_codaux1
                                   exclusive-lock:
                              delete cadmetasprodu.
                          end. 
                  end.
                  leave bl-princ.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Fornecedor "
                then do on error undo:

                       run pi-forne.
                       leave.    
                end.
                if esqcom2[esqpos2] = " Departamento "
                then do on error undo:

                     run pi-depto.
                     leave.
                end.
                if esqcom2[esqpos2] = " Classe "
                then do on error undo:

                      run pi-classe.
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
        recatu1 = recid(cadmetasprodu).
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

find first produ where
           produ.procod = cadmetasprodu.procod no-lock no-error.
if avail produ
then do:
    find first clase where
               clase.clacod = produ.clacod no-lock no-error.
    find first categoria where
               categoria.catcod = produ.catcod no-lock no-error. 
    find first fabri where
               fabri.fabcod = produ.fabcod no-lock no-error.
end.           

display cadmetasprodu.codmeta
        cadmetasprodu.procod
        when avail clase clase.clacod column-label "Codigo"
        when avail clase clase.clanom column-label "Descricao"  form "x(12)"
        when avail categoria categoria.catcod column-label "Dpto"
        when avail categoria categoria.catnom column-label "Nome" form "x(12)"
        when avail fabri fabri.fabcod column-label "Forn"
        when avail fabri fabri.fabnom column-label "Nome" form "x(12)"
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        cadmetasprodu.codmeta
        cadmetasprodu.procod column-label "Produto"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cadmetasprodu.codmeta
        cadmetasprodu.procod column-label "Produto"
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetasprodu where 
                   cadmetasprodu.codmeta = p_codmeta 
                                                no-lock no-error.
    else  
        find last cadmetasprodu  where 
                  cadmetasprodu.codmeta = p_codmeta
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetasprodu  where 
                  cadmetasprodu.codmeta = p_codmeta
                                                no-lock no-error.
    else  
        find prev cadmetasprodu   where 
                  cadmetasprodu.codmeta = p_codmeta
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetasprodu where 
                  cadmetasprodu.codmeta = p_codmeta
                                        no-lock no-error.
    else   
        find next cadmetasprodu where 
                  cadmetasprodu.codmeta = p_codmeta
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var c_nomMeta   like cadmetas.nommeta.
   def var i_procod    like produ.procod form ">>>>>>>>9".
   def var c_catnom    like produ.pronom.

   def frame f-inc 
       i_codmeta       at 12        label "Meta"            form ">>>>>>>9"
       c_nommeta       at 27        no-label                form "x(30)"   
       skip
       i_procod        at 01        label "Produto"
       c_catnom        at 27        no-label                form "x(22)"
       with side-labels  1 down width 80
            overlay title "INCLUSAO".
   
   disp i_codmeta
        c_nomMeta
        i_procod
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
  
   update i_procod
          with frame f-inc.

   find first cadmetasprodu where
              cadmetasprodu.codmeta = i_codmeta and
              cadmetasprodu.procod  = i_procod no-lock no-error.
   if avail cadmetasprodu
   then do:
           message "Meta ja existe com o Produto!"
                   view-as alert-box.
           undo, retry.                    
   end.

   find first produ where
              produ.procod = i_procod no-lock no-error.
   if not avail produ
   then do:
           message "Produto não encontrado!"
                   view-as alert-box.
           undo, retry.        
   end.

   assign c_catnom = produ.pronom.
   disp c_catnom with frame f-inc. 

   create cadmetasprodu.
   assign cadmetasprodu.codmeta = i_codmeta
          cadmetasprodu.procod  = i_procod.

   pause 0 no-message.

end procedure.


procedure pi-menu:

  disp  skip(1)
        esqpro1[1] skip
        esqpro1[2] skip
        esqpro1[3] skip
        esqpro1[4] skip
        esqpro1[5] skip
        esqpro1[6] skip 
        esqpro1[7] skip 
        with frame f-escpro title "OPCOES" row 7
             centered color with/black no-label overlay.
               
  choose field esqpro1 auto-return with frame f-escpro.
                   
  clear frame f-escpro no-pause.
  hide frame f-escpro  no-pause.
                           
  if frame-index = 1
  then do:
          run pi-inclui.
          hide frame f-escpro.
          leave.
  end.    
  if frame-index = 2
  then do:
          run pi-forne.
          hide frame f-escpro.
          leave.
  end.                            
  if frame-index = 3
  then do:
          run pi-depto.
          hide frame f-escpro.
          leave.
  end.                            
  if frame-index = 4
  then do:
          run pi-classe.
          hide frame f-escpro.
          leave.
  end.  
                            
  if frame-index = 5
  then do:
          run pi-grupo.
          hide frame f-escpro.
          leave.
                            
  end.           
  
  if frame-index = 6
  then do:
          run pi-setor.
          hide frame f-escpro.
          leave.
                            
  end.           
                  
  if frame-index = 7
  then do:
          run pi-classe7.
          hide frame f-escpro.
          leave.
                            
  end.           

end procedure.


procedure pi-depto:

   update i_catcod  label "Departamento"
          with frame f-cat col 6 row 6
               title "DEPARTAMENTO".
   find first categoria where
              categoria.catcod = i_catcod
              no-lock no-error.
   if not avail categoria
   then do:
           message "Departamento não encontrado!"
                   view-as alert-box.
                   undo, retry.        
   end.
   for each produ where
            produ.catcod = i_catcod no-lock:
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmeta and
                  cadmetasprodu.procod  = produ.procod
                  exclusive-lock no-error.
       if not avail cadmetasprodu
       then do:              
               create cadmetasprodu.
               assign cadmetasprodu.codmeta = i_codmeta
                      cadmetasprodu.procod  = produ.procod.
       end.             
   end.
   hide frame f-cat.
   leave.

end procedure.

procedure pi-forne:

 update i_fabcod  label "Fornecedor"
        with frame f-fab col 6 row 6
             title "FORNECEDOR".
 find first fabri where
            fabri.fabcod = i_fabcod
            no-lock no-error.
 if not avail fabri
 then do:
         message "Fornecedor não encontrado!"
                 view-as alert-box.
                 undo, retry.        
 end.
 for each produ where
          produ.fabcod = i_fabcod no-lock:
     find first cadmetasprodu where
                cadmetasprodu.codmeta = i_codmeta and
                cadmetasprodu.procod  = produ.procod
                exclusive-lock no-error.
     if not avail cadmetasprodu
     then do:              
             create cadmetasprodu.
             assign cadmetasprodu.codmeta = i_codmeta
                    cadmetasprodu.procod  = produ.procod.
     end.             
 end.
 hide frame f-fab.
 leave.

end procedure.

procedure pi-grupo:

def buffer aclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
    
    update vcla2-cod 
        with frame f-gru col 6 row 6
            title "GRUPO".
    
    find first clase where
              clase.clacod  = vcla2-cod /*and
              clase.clagrau = 2*/
              no-lock no-error.
              
              
   if not avail clase
   then do:                          
           message "Grupo  não encontrao!"
                   view-as alert-box.
           undo, retry.        
   end.
   /*
   find first produ where produ.clacod = clase.clacod no-lock no-error.
   if not avail produ
   then do:
    message color red/with 
        "Grupo não associavel a produtos."
                   view-as alert-box.
           undo, retry.  
   end.
   */

   for each produ where no-lock.

       find first aclase where aclase.clacod = produ.clacod  no-lock no-error.
       find first bclase where bclase.clacod = aclase.clasup no-lock no-error.
       find first cclase where cclase.clacod = bclase.clasup no-lock no-error.
       
       if not avail cclase then next.
       
       if cclase.clacod <> vcla2-cod then next.
       
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmeta and
                  cadmetasprodu.procod  = produ.procod
                  exclusive-lock no-error.
       if not avail cadmetasprodu
       then do:              
               create cadmetasprodu.
               assign cadmetasprodu.codmeta = i_codmeta
                      cadmetasprodu.procod  = produ.procod.
       end.
   end.

   hide frame f-cla.
   leave.


end.


procedure pi-classe:
   update i_clacod label "Sub Classe"
          with frame f-cla col 6 row 6
               title "SUB CLASSE".
   find first clase where
              clase.clacod = i_clacod
              no-lock no-error.
   if not avail clase
   then do:                          
           message "Classe não encontrada!"
                   view-as alert-box.
           undo, retry.        
   end.
   find first produ where produ.clacod = clase.clacod no-lock no-error.
   if not avail produ
   then do:
    message color red/with 
        "Sub Classe não associavel a produtos."
                   view-as alert-box.
           undo, retry.  
   end.

   for each produ where
            produ.clacod = i_clacod no-lock:
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmeta and
                  cadmetasprodu.procod  = produ.procod
                  exclusive-lock no-error.
       if not avail cadmetasprodu
       then do:              
               create cadmetasprodu.
               assign cadmetasprodu.codmeta = i_codmeta
                      cadmetasprodu.procod  = produ.procod.
       end.             
   end.
   hide frame f-cla.
   leave.

end procedure.

procedure pi-setor.


def buffer aclase for clase.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase. 
    
    update vcla2-cod 
        with frame f-gru col 6 row 6
            title "Setor".
    
    find first clase where
              clase.clacod  = vcla2-cod and
              clase.clagrau = 1
              no-lock no-error.
              
              
   if not avail clase
   then do:                          
           message "Setor  não encontrao!"
                   view-as alert-box.
           undo, retry.        
   end.
   /*
   find first produ where produ.clacod = clase.clacod no-lock no-error.
   if not avail produ
   then do:
    message color red/with 
        "Setor não associavel a produtos."
                   view-as alert-box.
           undo, retry.  
   end.
   */

   for each produ where no-lock.

       find first aclase where aclase.clacod = produ.clacod  no-lock no-error.
       find first bclase where bclase.clacod = aclase.clasup no-lock no-error.
       find first cclase where cclase.clacod = bclase.clasup no-lock no-error.
       find first dclase where dclase.clacod = cclase.clasup no-lock no-error.
       
       if not avail dclase then next.
       
       if dclase.clacod <> vcla2-cod then next.
       
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmeta and
                  cadmetasprodu.procod  = produ.procod
                  exclusive-lock no-error.
       if not avail cadmetasprodu
       then do:              
               create cadmetasprodu.
               assign cadmetasprodu.codmeta = i_codmeta
                      cadmetasprodu.procod  = produ.procod.
       end.
   end.

   hide frame f-cla.
   leave.


end procedure.


procedure pi-classe7.


def buffer aclase for clase.
def buffer bclase for clase.
    
    update vcla2-cod 
        with frame f-gru col 6 row 6
            title "Classe".
    
    find first clase where
              clase.clacod  = vcla2-cod and
              clase.clagrau = 3
              no-lock no-error.
              
              
   if not avail clase
   then do:                          
           message "Classe  não encontrao!"
                   view-as alert-box.
           undo, retry.        
   end.

   /*
   find first produ where produ.clacod = clase.clacod no-lock no-error.
   if not avail produ
   then do:
    message color red/with 
        "Classe não associavel a produtos."
                   view-as alert-box.
           undo, retry.  
   end.
   */

   for each produ where no-lock.

       find first aclase where aclase.clacod = produ.clacod  no-lock no-error.
       find first bclase where bclase.clacod = aclase.clasup no-lock no-error.
       
       if not avail bclase then next.
       
       if bclase.clacod <> vcla2-cod then next.
       
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmeta and
                  cadmetasprodu.procod  = produ.procod
                  exclusive-lock no-error.
       
       if not avail cadmetasprodu
       then do:              
               create cadmetasprodu.
               assign cadmetasprodu.codmeta = i_codmeta
                      cadmetasprodu.procod  = produ.procod.
       end.

   end.

   hide frame f-cla.
   leave.


end procedure.

