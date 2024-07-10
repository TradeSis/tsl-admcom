{admcab.i}

def input parameter r_recid as recid.
def input param     p_codmeta as inte.

def temp-table cadmetasfunci
    field codmeta    like cadmetas.codmeta
    field etbcod     like estab.etbcod
    field funcod     like func.funcod
    index ch_prim    is primary is unique codmeta etbcod funcod.

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
def var i_codaux3       as inte.

def var i_codmeta       like cadmetas.codmeta.
def var i_etbcod        like estab.etbcod.
def var i_funcod        like func.funcod.


/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 4
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "].

/* regua de baixo*/

def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
            
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  Funcionario ",
             " Alteracao Funcionario ",
             " Exclusao  Funcionario ",
             " Consulta  Funcionario ",
             " Listagem  Geral Funcionario "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer bcadmetasfunci      for cadmetasfunc.
def var vcadmetasfunci         like cadmetasfunci.codmeta.


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
        find cadmetasfunci where recid(cadmetasfunci) = recatu1 no-lock.
    if not available cadmetasfunci
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetasfunci).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetasfunci
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
            find cadmetasfunci where recid(cadmetasfunci) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetasfunci.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetasfunci.codmeta)
                                        else "".
            run color-message.
            choose field cadmetasfunci.codmeta help ""
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
                    if not avail cadmetasfunci
                    then leave.
                    recatu1 = recid(cadmetasfunci).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetasfunci
                    then leave.
                    recatu1 = recid(cadmetasfunci).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetasfunci
                then next.
                color display white/red cadmetasfunci.codmeta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetasfunci
                then next.
                color display white/red cadmetasfunci.codmeta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form cadmetasfunci
                 with frame f-cadmetasfunci color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasfunci.codmeta
                 i_etbcod
                 with frame f-cadmetasfuncial color black/cyan
                      centered side-label row 5 width 80.

            form cadmetasfunci
                 with frame f-cadmetasfuncio color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasfunci
                 with frame f-cadmetasfunciex color black/cyan
                      centered side-label row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cadmetasfunci on error undo.

                    run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetasfunci).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetasfunci.
                    disp cadmetasfunci.codmeta
                         cadmetasfunci.etbcod
                         cadmetasfunci.funcod
                         with side-labels 1 col.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasfuncial.
                    disp cadmetasfunci.codmeta
                         i_etbcod 
                         i_funcod.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasfuncial on error undo.

                    find cadmetasfunci where
                            recid(cadmetasfunci) = recatu1 exclusive.
                   
                    assign i_etbcod  = cadmetasfunci.etbcod
                           i_funcod  = cadmetasfunci.funcod   
                           i_codaux1 = cadmetasfunci.codmeta
                           i_codaux2 = cadmetasfunci.etbcod
                           i_codaux3 = cadmetasfunci.funcod.
                    
                    update i_etbcod
                           i_funcod  
                           with side-label 1 col.

                    find first bcadmetasfunci where
                               bcadmetasfunci.codmeta = i_codmeta and
                               bcadmetasfunci.etbcod  = i_etbcod  and
                               bcadmetasfunci.funcod  = i_funcod
                               no-lock no-error.
                    if avail bcadmetasfunci
                    then do:           
                            message "Registro ja existe, favor" skip
                                    "digitar outro!"
                                    view-as alert-box.
                            undo, retry.
                    end.   
                      
                    find first func where
                               func.etbcod = i_etbcod   and
                               func.funcod = i_funcod   no-lock no-error.
                    if not avail func
                    then do:
                            message "Funcionario não encontrado!"
                                    view-as alert-box.
                            undo, retry.
                    end.

                    assign cadmetasfunci.etbcod = input i_etbcod
                           cadmetasfunci.funcod = input i_funcod.

                    leave.
                             
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" cadmetasfunci.funcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetasfunci where 
                              cadmetasfunci.codmeta = p_codmeta no-error.
                    if not available cadmetasfunci
                    then do:
                        find cadmetasfunci where recid(cadmetasfunci) = recatu1.
                        find prev cadmetasfunci where 
                                  cadmetasfunci.codmeta = p_codmeta no-error.
                    end.
                    recatu2 = if available cadmetasfunci
                              then recid(cadmetasfunci)
                              else ?.
                    find cadmetasfunci where recid(cadmetasfunci) = recatu1
                            exclusive.
                    assign i_codaux1 = cadmetasfunci.codmeta
                           i_codaux2 = cadmetasfunci.etbcod
                           i_codaux3 = cadmetasfunci.funcod.
                    delete cadmetasfunci.
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
                    then run lcadmetasfunci.p (input 0).
                    else run lcadmetasfunci.p (input cadmetasfunci.codmeta).
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
        recatu1 = recid(cadmetasfunci).
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
display cadmetasfunci 
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        cadmetasfunci.codmeta
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cadmetasfunci.codmeta
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetasfunci where true  
                                                no-lock no-error.
    else  
        find last cadmetasfunci  where true  
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetasfunci  where true  
                                                no-lock no-error.
    else  
        find prev cadmetasfunci   where true  
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetasfunci where true 
                                        no-lock no-error.
    else   
        find next cadmetasfunci where true  
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var c_nomMeta   like cadmetas.nommeta.
   def var i_etbcod    like estab.etbcod.
   def var c_etbnom    like estab.etbnom.
   def var i_funcod    like func.funcod.
   def var c_funnom    like func.funnom.

   def frame f-inc 
       i_codmeta       at 12        label "Meta"            form ">>>>>>>9"
       c_nommeta       at 27        no-label                form "x(30)"   
       skip
       i_etbcod        at 01        label "Estabelecimento"
       c_etbnom        at 27        no-label                form "x(22)"
       skip
       i_funcod        at 01        label "Funcionario"
       c_funnom        at 27        no-label
       with side-labels  1 down width 80
            overlay title "INCLUSAO".
   
   disp i_codmeta
        c_nomMeta
        i_etbcod
        c_etbnom
        i_funcod
        c_funnom
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
  
   update i_etbcod
          i_funcod
          with frame f-inc.

   find first cadmetasfunci where
              cadmetasfunci.codmeta = i_codmeta and
              cadmetasfunci.etbcod  = i_etbcod  and
              cadmetasfunci.funcod  = i_funcod  no-lock no-error.
   if avail cadmetasfunci
   then do:
           message "Meta ja existe com o estabelecimento!"
                   view-as alert-box.
           undo, retry.                    
   end.

   find first estab where
              estab.etbcod = i_etbcod no-lock no-error.
   if not avail estab
   then do:
           message "Estabelecimento não encontrado!"
                   view-as alert-box.
           undo, retry.        
   end.

   assign c_etbnom = estab.etbnom.
   disp c_etbnom with frame f-inc. 

   find first func where
              func.etbcod = i_etbcod and
              func.funcod = i_funcod no-lock no-error.
   if not avail func
   then do:
           message "Funcionario nao encontrado!"
                   view-as alert-box.
           undo, retry.        
   end.

   assign c_etbnom = estab.etbnom
          c_funnom = func.funnom.
   disp c_etbnom 
        c_funnom with frame f-inc. 

   create cadmetasfunci.
   assign cadmetasfunci.codmeta = i_codmeta
          cadmetasfunci.etbcod  = i_etbcod
          cadmetasfunci.funcod  = i_funcod.

   pause 0 no-message.

end procedure.
