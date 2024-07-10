{admcab.i}                                          

def input parameter r_recid as recid.
def input parameter p_codmeta as int.

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
def var i_codmetaux     like cadmetas.codmeta.

def var i_etbcod        like estab.etbcod.
def var d_nvalor        like cadmetasest.vlrmest.

find first cadmetas  where
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then i_codmetaux = cadmetas.codmeta.
else i_codmetaux = ?.

/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta ","   Todos  "].

/* regua de baixo*/

def var esqcom2         as char format "x(35)" extent 5
            initial ["Tecle [V] alterar para valor ",
                     "[S] Substituir todos valores ",
                     "",
                     "",
                     ""].
            
            
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  Filial ",
             " Alteracao Filial ",
             " Exclusao  Filial ",
             " Consulta  Filial ",
             " Listagem  Geral Filial "].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].


def buffer bcadmetasest      for cadmetasest.
def var vcadmetasest         like cadmetasest.codmeta.


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
        find cadmetasest where recid(cadmetasest) = recatu1 no-lock.
    if not available cadmetasest
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetasest).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetasest
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
            find cadmetasest where recid(cadmetasest) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetasest.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetasest.codmeta)
                                        else "".
            run color-message.
            choose field cadmetasest.codmeta help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return v V s S).
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
                    if not avail cadmetasest
                    then leave.
                    recatu1 = recid(cadmetasest).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetasest
                    then leave.
                    recatu1 = recid(cadmetasest).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetasest
                then next.
                color display white/red cadmetasest.codmeta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetasest
                then next.
                color display white/red cadmetasest.codmeta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
            
            if keyfunction(lastkey) = "v"   or
               keyfunction(lastkey) = "V"
            then do:
                    find first bcadmetasest where
                               bcadmetasest.codmeta = cadmetasest.codmeta and
                               bcadmetasest.etbcod  = cadmetasest.etbcod
                               exclusive-lock no-error.
                    if avail bcadmetasest
                    then do:
                      pause 0 no-message.          
                    
                      disp bcadmetasest.codmeta label "Meta"
                           bcadmetasest.etbcod  label "Estab"
                           with frame f-valor overlay width 60 1 col
                                centered row 6 col 6 title "ALTERA VALOR META".
                      update bcadmetasest.vlrmest label "Vlr. Meta"
                           with frame f-valor overlay.
                    end.      
                    hide frame f-valor.
                    leave.
            end.
            
            if keyfunction(lastkey) = "s"   or
               keyfunction(lastkey) = "S"
            then do:
                    find first bcadmetasest where
                               bcadmetasest.codmeta = cadmetasest.codmeta 
                               exclusive-lock no-error.
                    if avail bcadmetasest
                    then do:
                      pause 0 no-message.          
                    
                      disp bcadmetasest.codmeta label "Meta"
                           with frame f-valsub overlay width 60 1 col
                                centered row 6 col 6 title "ALTERA VALOR META".
                      update d_nvalor label "Vlr. Meta"
                           with frame f-valsub overlay.
                    end.      
                    for each bcadmetasest where
                             bcadmetasest.codmeta = cadmetasest.codmeta 
                             exclusive-lock:
                        assign bcadmetasest.vlrmest = d_nvalor.
                    end.
                    hide frame f-valor.
                    leave.
            end.
            
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:

            form cadmetasest
                 with frame f-cadmetasest color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasest.codmeta
                 i_etbcod
                 with frame f-cadmetasestal color black/cyan
                      centered side-label row 5 width 80.

            form cadmetasest
                 with frame f-cadmetasestco color black/cyan
                      centered side-label row 5 width 80.
                      
            form cadmetasest
                 with frame f-cadmetasestex color black/cyan
                      centered side-label row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cadmetasest on error undo.

                    run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetasest).
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetasest.
                    disp cadmetasest.codmeta
                         cadmetasest.etbcod
                         with side-labels 1 col.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasestal.
                    disp cadmetasest.codmeta
                         i_etbcod
                         cadmetasest.vlrmest.
                end.
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasestal on error undo.

                    find cadmetasest where
                            recid(cadmetasest) = recatu1 exclusive.
                   
                    assign i_etbcod  = cadmetasest.etbcod
                           i_codaux1 = cadmetasest.codmeta
                           i_codaux2 = cadmetasest.etbcod.
                    
                    update i_etbcod
                           with side-label 1 col.
                    /*
                    find first bcadmetasest where
                               bcadmetasest.codmeta = i_codmeta and
                               bcadmetasest.etbcod  = i_etbcod
                               no-lock no-error.
                    if avail bcadmetasest
                    then do:           
                            message "Estabelecimento ja existe, favor" skip
                                    "digitar outro!"
                                    view-as alert-box.
                            undo, retry.
                    end.     
                    */
                    update cadmetasest.vlrmest
                           with side-label 1 col.
                    
                    assign cadmetasest.etbcod = input i_etbcod.

                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de " cadmetasest.etbcod
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetasest where 
                              cadmetasest.codmeta = p_codmeta no-error.
                    if not available cadmetasest
                    then do:
                        find cadmetasest where recid(cadmetasest) = recatu1.
                        find prev cadmetasest where 
                                  cadmetasest.codmeta = p_codmeta no-error.
                    end.
                    recatu2 = if available cadmetasest
                              then recid(cadmetasest)
                              else ?.
                    find cadmetasest where recid(cadmetasest) = recatu1
                            exclusive.
                    assign i_codaux1 = cadmetasest.codmeta
                           i_codaux2 = cadmetasest.etbcod.
                    delete cadmetasest.
                    recatu1 = recatu2.
                    leave.
                end.

                if esqcom1[esqpos1] = "   Todos  "
                then do:

                        if i_codmetaux = ?
                        then do:
                                message "Codigo da meta invalido!"
                                view-as alert-box.
                                undo, retry.
                        end.
                
                        for each estab no-lock:

                            find first cadmetasest where
                                       cadmetasest.codmeta = i_codmetaux  and
                                       cadmetasest.etbcod  = estab.etbcod 
                                       exclusive-lock no-error.
                            if avail cadmetasest
                            then next.
                            else do:
                                    create cadmetasest.  
                                    assign  cadmetasest.codmeta = i_codmeta
                                            cadmetasest.etbcod  = estab.etbcod.
                            end.
                        end.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " x "
                then do:

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
        recatu1 = recid(cadmetasest).
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
display cadmetasest 
        with frame frame-a 11 down centered color white/red row 5 overlay.
end procedure.
procedure color-message.
color display message
        cadmetasest.codmeta
        cadmetasest.etbcod column-label "Filial"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        cadmetasest.codmeta
        cadmetasest.etbcod column-label "Filial"
        with frame frame-a.
end procedure.




procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetasest where cadmetasest.codmeta = p_codmeta
                                                no-lock no-error.
    else  
        find last cadmetasest  where cadmetasest.codmeta = p_codmeta
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetasest  where cadmetasest.codmeta = p_codmeta
                                                no-lock no-error.
    else  
        find prev cadmetasest   where cadmetasest.codmeta = p_codmeta
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetasest where cadmetasest.codmeta = p_codmeta
                                        no-lock no-error.
    else   
        find next cadmetasest where cadmetasest.codmeta = p_codmeta
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var c_nomMeta   like cadmetas.nommeta.
   def var i_etbcod    like estab.etbcod.
   def var c_etbnom    like estab.etbnom.

   def frame f-inc 
       i_codmeta       at 12        label "Meta"            form ">>>>>>>9"
       c_nommeta       at 27        no-label                form "x(30)"   
       skip
       i_etbcod        at 01        label "Estabelecimento"
       c_etbnom        at 27        no-label                form "x(22)"
       with side-labels  1 down width 80
            overlay title "INCLUSAO".
   
   disp i_codmeta
        c_nomMeta
        i_etbcod
        c_etbnom
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
          with frame f-inc.

   find first cadmetasest where
              cadmetasest.codmeta = i_codmeta and
              cadmetasest.etbcod  = i_etbcod no-lock no-error.
   if avail cadmetasest
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

   create cadmetasest.
   assign cadmetasest.codmeta = i_codmeta
          cadmetasest.etbcod  = i_etbcod.

   pause 0 no-message.
   
end procedure.
