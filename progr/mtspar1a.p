{admcab.i}

&scoped-define m-display cadmetas.codmeta cadmetas.nommeta cadmetas.vlrmeta cadmetas.perini cadmetas.perfin cadmetas.vlrmest

&scoped-define m-exceto cadmetas.nomusu cadmetas.dtausu cadmetas.hrausu cadmetas.char_1 cadmetas.char_2 cadmetas.char_3 cadmetas.deci_1 cadmetas.deci_2 cadmetas.deci_3 cadmetas.data_1 cadmetas.data_2 cadmetas.data_3 cadmetas.dtargmeta cadmetas.auxmeta


&scoped-define m-exchav cadmetas.codmeta cadmetas.nomusu cadmetas.dtausucadmetas.hrausu cadmetas.char_1 cadmetas.char_2 cadmetas.char_3 cadmetas.deci_1 cadmetas.deci_2 cadmetas.deci_3 cadmetas.data_1 cadmetas.data_2 cadmetas.data_3 cadmetas.dtargmeta cadmetas.auxmeta

pause 0.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log init yes.

def var i_codmeta       like cadmetas.codmeta.

def var l_conf          as log initial yes.
def var c_tabela        as char.

/* regua de cima*/
def var esqcom1         as char format "x(12)" extent 4
 initial  [" Inclusao  ",
           " Alteracao ",
           " Exclusao  ",
           " Relatorio "].

/* regua de baixo*/

def var esqcom2         as char format "x(10)" extent 2
            initial [" Filial  ",
                     " Produto "].
            
def var esqrela         as char form   "x(13)" extent 2
            initial ["  Relatorio  ",
                     "Arquivo Excel"].
            
def var esqhel1         as char format "x(80)" extent 4
    initial [" Inclusao  de Metas          ",
             " Alteracao de Metas          ",
             " Exclusao  de Metas          ",
             " Relatorio de Metas          "].

def var esqhel2         as char format "x(12)" extent 2
   initial [" Manutencao Metas X Filial  ",
            " Manutencao Metas X Produto "].

def buffer bcadmetas         for cadmetas.
def var vcadmetas            like cadmetas.codmeta.
def buffer bf-cadmetas       for cadmetas.

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

    disp esqcom1 with frame f-com1. pause 0.
    disp esqcom2 with frame f-com2. pause 0.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find cadmetas where recid(cadmetas) = recatu1 no-lock.
    if not available cadmetas
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(cadmetas).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available cadmetas
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
            find cadmetas where recid(cadmetas) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(cadmetas.codmeta)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(cadmetas.codmeta)
                                        else "".
            run color-message.
            choose field cadmetas.codmeta help ""
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
                    esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 2 then 2 else esqpos2 + 1.
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
                    if not avail cadmetas
                    then leave.
                    recatu1 = recid(cadmetas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail cadmetas
                    then leave.
                    recatu1 = recid(cadmetas).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail cadmetas
                then next.
                color display white/red cadmetas.codmeta with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail cadmetas
                then next.
                color display white/red cadmetas.codmeta with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
                
            form 
                 cadmetas.codmeta
                 cadmetas.nommeta
                 cadmetas.vlrmest label "Vlr Meta Filial" form ">>>,>>9.99"
                 cadmetas.vlrmeta label "Vlr Meta Vendedor"  form ">>>,>>9.99"
                 cadmetas.perini
                 cadmetas.perfin
                 with frame f-cadmetas color black/cyan
                      centered side-label row 5 width 80.
                             
            form 
                 cadmetas.nommeta label "Nome"  form "x(60)"
                 cadmetas.vlrmest label "Vlr Meta Filial" form ">>>,>>9.99"
                 cadmetas.vlrmeta label "Vlr Meta Vendedor"  form ">>>,>>9.99"
                 cadmetas.perini  label "Per. Inicial"
                 cadmetas.perfin  label "Final"
                 with frame f-cadmetasal color black/cyan
                      centered side-label 1 col row 5 width 80.

            form 
                 cadmetas.codmeta label "Codigo"
                 cadmetas.nommeta label "Nome"  form "x(60)"
                 cadmetas.vlrmest label "Vlr Meta Filial" form ">>>,>>9.99"
                 cadmetas.vlrmeta label "Vlr Meta Vendedor"  form ">>>,>>9.99"
                 cadmetas.perini  label "Per. Inicial"
                 cadmetas.perfin  label "Final"
                 with frame f-cadmetasex color black/cyan
                      centered side-label 1 col row 5 width 80.
                      
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-cadmetas on error undo.

                    run pi-inclui.

                    hide frame f-inc.
                    recatu1 = recid(cadmetas).
                    leave.
                end.
                /*
                if esqcom1[esqpos1] = " Consulta " 
                then do with frame  f-cadmetascon.

                    run pi-consulta.

                    hide frame f-con.
                    recatu1 = recid(cadmetas).
                    leave.
                end.
                */
                if esqcom1[esqpos1] = " Alteracao "
                then do with frame f-cadmetasal on error undo.
                
                    find cadmetas where
                         recid(cadmetas) = recatu1 exclusive-lock no-error.
                    if avail cadmetas
                    then update cadmetas except {&m-exceto} cadmetas.codmeta.  
                    else message "Registro não foi encontrado!"
                                 view-as alert-box.
                    hide frame f-cadmetasal.
                    leave.
                end.
                if esqcom1[esqpos1] = " Exclusao " 
                then do with frame f-cadmetasex.
                    disp cadmetas except {&m-exceto}. 
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" cadmetas.codmeta
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next cadmetas where true no-error.
                    if not available cadmetas
                    then do:
                        find cadmetas where recid(cadmetas) = recatu1.
                        find prev cadmetas where true no-error.
                    end.
                    recatu2 = if available cadmetas
                              then recid(cadmetas)
                              else ?.
                    find cadmetas where recid(cadmetas) = recatu1
                            exclusive.
                    assign i_codmeta = cadmetas.codmeta.        
                    run pi-filhos.
                            
                    delete cadmetas.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Relatorio"
                then do with frame f-Lista:

                    find cadmetas where 
                         recid(cadmetas) = recatu1
                         no-lock no-error.
                    assign i_codmeta = cadmetas.codmeta.

                    find first cadmetasprodu where
                               cadmetasprodu.codmeta = i_codmeta
                               no-lock no-error.
                    if not avail cadmetasprodu
                    then do:
                            message "Nenhum produto cadastrado!"
                                    view-as alert-box.
                            leave.        
                    end.
                    
                    find first cadmetasestab where
                               cadmetasestab.codmeta = i_codmeta
                               no-lock no-error.
                    if not avail cadmetasestab
                    then do:
                            message "Nenhum estabelecimento cadastrado"
                                    view-as alert-box.
                                    leave.
                    end.
                    
                    run pi-relato.
                    leave.
                end.
                if esqcom1[esqpos1] = "   Meta   "
                then do:

                        run mtsvis1a.p (input recatu1).
                                 
                        leave.
                end.                 
                
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " Filial "
                then do:

                        hide frame f-com2 no-pause.
                        run mtsest1a.p (input recatu1, 
                                        input cadmetas.codmeta).

                end.
                if esqcom2[esqpos2] = " Fornec "
                then do:
                        assign l_conf = no.
                        run pi-valida(input-output c_tabela,
                                       input recatu1,
                                       input-output l_conf).

                        if l_conf    = yes   and
                           c_tabela <> "forne"
                        then do:
                                message "Meta ja possui filtro! " + 
                                       c_tabela
                                       view-as alert-box.
                                leave.
                        end.
                        else do:
                                hide frame f-com2 no-pause.
                                run mtsfab1a.p (input recatu1, 
                                                input cadmetas.codmeta).
                        end.                        
                end.
                if esqcom2[esqpos2] = " Depto "
                then do:
                        assign l_conf = no.
                        run pi-valida(input-output c_tabela,
                                      input recatu1,
                                      input-output l_conf).

                        if l_conf = yes   and
                           c_tabela <> "depto"
                        then do:
                                message "Meta ja possui filtro! " + 
                                       c_tabela
                                       view-as alert-box.
                                leave.
                        end.
                        else do:
                                hide frame f-com2 no-pause.
                                run mtscat1a.p (input recatu1,
                                                input cadmetas.codmeta).
                        end.                        
                end.
                if esqcom2[esqpos2] = " Produto "
                then do:
                        /*
                        assign l_conf = no.
                        run pi-valida(input-output c_tabela,
                                      input recatu1,
                                      input-output l_conf).

                        if l_conf = yes   and
                           c_tabela <> "produ"
                        then do:
                                message "Meta ja possui filtro! " + 
                                       c_tabela
                                       view-as alert-box.
                                leave.
                        end.
                        else do:
                        */
                                hide frame f-com2 no-pause.
                                run mtspro1a.p (input recatu1,
                                                input cadmetas.codmeta).
                        /*
                        end.
                        */                        
                end.

                if esqcom2[esqpos2] = " Classe "
                then do:
                        assign l_conf = no.
                        run pi-valida(input-output c_tabela,
                                      input recatu1,
                                      input-output l_conf).

                        if l_conf = yes   and
                           c_tabela <> "class"
                        then do:
                                message "Meta ja possui filtro! " + 
                                       c_tabela
                                       view-as alert-box.
                                leave.
                        end.
                        else do:
                                hide frame f-com2 no-pause.
                                run mtscla1a.p (input recatu1,
                                                input cadmetas.codmeta).
                        end.                        
                end.
                 
                if esqcom2[esqpos2] = " Func "
                then do:
                        assign l_conf = no.
                        run pi-valida(input-output c_tabela,
                                      input recatu1,
                                      input-output l_conf).

                        if l_conf = yes   and
                           c_tabela <> "func"
                        then do:
                                message "Meta ja possui filtro! " + 
                                       c_tabela
                                       view-as alert-box.
                                leave.
                        end.
                        else do:
                                hide frame f-com2 no-pause.
                                run mtsfun1a.p (input recatu1,
                                                input cadmetas.codmeta).
                        end.                        
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
        recatu1 = recid(cadmetas).
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
display cadmetas except {&m-exceto} 
        with frame frame-a 11 down centered overlay color white/red row 6.

end procedure.
procedure color-message.
color display message
       cadmetas.codmeta
       cadmetas.nommeta form "x(25)"
       cadmetas.vlrmest form ">>>,>>9.99" column-label "Vlr Fil"
       cadmetas.vlrmeta form ">>>,>>9.99" column-label "Vlr Vend"
       cadmetas.perini column-label "P/Inicio"
       cadmetas.perfin column-label "P/Final"
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
      cadmetas.codmeta
      cadmetas.nommeta
      cadmetas.vlrmest
      cadmetas.vlrmeta
      cadmetas.perini
      cadmetas.perfin
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first cadmetas where true
                                                no-lock no-error.
    else  
        find last cadmetas  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next cadmetas  where true
                                                no-lock no-error.
    else  
        find prev cadmetas   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev cadmetas where true  
                                        no-lock no-error.
    else   
        find next cadmetas where true 
                                        no-lock no-error.
        
end procedure.
         

/* Procedures internas ----------------------------------------------------- */

procedure pi-inclui:

   def var i_codmeta   like cadmetas.codmeta.
   def var c_nomMeta   like cadmetas.nommeta.
   def var d_vlrmeta   like cadmetas.vlrmeta.
   def var d_vlrmest   like cadmetas.vlrmest.
   def var t_perini    like cadmetas.perini.
   def var t_perfin    like cadmetas.perfin.
   def var c_nomusu    like cadmetas.nomusu.
   def var t_dtausu    like cadmetas.dtausu.
   def var h_hrausu    like cadmetas.hrausu.
   def var c_auxmeta   like cadmetas.auxmeta. 
   def var i_deci_1    like cadmetas.deci_1.
   def var i_deci_2    like cadmetas.deci_2.
   
   def var l_confir    as logi init no.
   

   def frame f-inc 
       i_codmeta            label "Meta"       form ">>>>>>>9"
       skip 
       c_nommeta            label "Descricao"  form "x(45)"
       d_vlrmest            label "Vlr Mt Filial"      
       d_vlrmeta            label "Vlr Mt Vendedor"
       skip
       t_perini             label "Per. Inicio" 
       t_perfin             label "Final"   
       with side-labels 2 col  1 down width 80  
            overlay title "INCLUSAO".

   find last cadmetas no-lock no-error.
   if avail cadmetas
   then i_codmeta = cadmetas.codmeta + 1.
   else i_codmeta = i_codmeta + 1.
   
   disp i_codmeta
        c_nomMeta
        c_nommeta
        d_vlrmest
        d_vlrmeta
        t_perini
        t_perfin
        with frame f-inc.
        
   update i_codmeta
          with frame f-inc.    

   find first cadmetas where
              cadmetas.codmeta = i_codmeta no-lock no-error.
   if avail cadmetas 
   then do:
           message "Codigo já existe não pode ser criado!"
                   view-as alert-box.
           undo, retry.
   end.

   update c_nommeta
          d_vlrmest
          d_vlrmeta
          with frame f-inc.
   /*       
   if d_vlrmeta = ?  or
      d_vlrmeta < 1 /* or
      d_vlrmest = ?  or
      d_vlrmest < 1  */
   then do:
           message "Valor informado invalido favor verificar!"
                   view-as alert-box.
           undo, retry.
   end.   
   */
   /*
   if d_vlrmeta = ?  or
      d_vlrmeta < 1  or
      d_vlrmest = ?  or
      d_vlrmest < 1  
   then do:
           message "Deseja informar quantidades para meta?"
                   view-as alert-box buttons yes-no
                   title "QUANTIDADES"
                   update l_confir.
           if l_confir = yes
           then do:
                   update c_char_1 label "Qtd Filial"   form "x(9999"
                          c_char_2 label "Qtd Vendedor" form "9999"
                          with frame f-inc.
           end.        
   end.
   */
      
   assign t_perini = today
          t_perfin = today + 30.
   update t_perini
          t_perfin
          with frame f-inc.
   if t_perini = ? and
      t_perfin = ? or
      t_perini > t_perfin or
      t_perini = ? and
      t_perfin > t_perini
   then do:
           message "Favor verificar datas inconsistentes!"
                   view-as alert-box.
           undo, retry.        
   end.

   create cadmetas.
   assign cadmetas.codmeta      = i_codmeta
          cadmetas.nommeta      = caps(c_nommeta)
          cadmetas.vlrmest      = d_vlrmest
          cadmetas.vlrmeta      = d_vlrmeta
          cadmetas.perini       = t_perini
          cadmetas.perfin       = t_perfin
          cadmetas.nomusu       = ""
          cadmetas.dtausu       = today
          cadmetas.hrausu       = string(time,"HH:MM:SS")
          cadmetas.auxmeta      = ""
          cadmetas.dtargmeta    = today.

end procedure.

procedure pi-consulta:

   def frame f-con 
       bf-cadmetas.codmeta            column-label "Meta"      form ">>>>>>>9"
       bf-cadmetas.nommeta            column-label "Nome"      form "x(28)"   
       bf-cadmetas.vlrmest            column-label "V\Filial" 
       form ">>,>>9.99"
       bf-cadmetas.vlrmeta            column-label "V\Vendedor"
       form ">>,>>9.99"
       bf-cadmetas.perini             column-label "Inicio" form "99/99/99"
       bf-cadmetas.perfin             column-label "Final"  form "99/99/99"
       with 13 down width 80
            overlay title "CONSULTA".
   
   for each bf-cadmetas no-lock:
   
    disp bf-cadmetas.codmeta
         bf-cadmetas.nomMeta
         bf-cadmetas.vlrmest
         bf-cadmetas.vlrmeta
         bf-cadmetas.perini
         bf-cadmetas.perfin
         with frame f-con.
   end.
   
end.

/* -------------------------------------------------------------------- */

procedure pi-valida:

def input-output parameter c_tab       as char.
def input        parameter r_recid     as recid.
def input-output parameter l_valida    as logi.

def var          i_codmetaux like cadmetas.codmeta.

find first cadmetas where
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then do:
     assign i_codmetaux = cadmetas.codmeta.           
end.
else do: 
       message "Posicione em uma meta para iniciar"
               view-as alert-box.
       undo, retry.
end.

   assign l_valida = no
          c_tab    = "".
   
   find first cadmetasfabri where
              cadmetasfabri.codmeta = i_codmetaux no-lock no-error.
   if avail cadmetasfabri
   then assign l_valida = yes
               c_tab    = "forne".
   else assign l_valida = no.
   
   if l_valida <> yes
   then do:
       find first cadmetascategoria where
                  cadmetascategoria.codmeta = i_codmetaux no-lock no-error.
       if avail cadmetascategoria
       then assign l_valida = yes
                   c_tab    = "depto".
       else assign l_valida = no.
   end.
   /*
   if l_valida <> yes
   then do:
       find first cadmetasprodu where
                  cadmetasprodu.codmeta = i_codmetaux no-lock no-error.
       if avail cadmetasprodu
       then assign l_valida = yes
                   c_tab    = "produ".
       else assign l_valida = no.
   end.
   */
   if l_valida <> yes
   then do:
       find first cadmetasfunc where
                  cadmetasfunc.codmeta = i_codmetaux no-lock no-error.
       if avail cadmetasfunc
       then assign l_valida = yes
                   c_tab    = "funci".
       else assign l_valida = no.
   end.
   
end procedure.

procedure pi-filhos:

   for each cadmetasestab where
            cadmetasestab.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetasestab.
       
   end.
   for each cadmetasfabri where
            cadmetasfabri.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetasfabri.
       
   end.    
   for each cadmetascategoria where
            cadmetascategoria.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetascategoria.
       
   end.
   for each cadmetasprodu where
            cadmetasprodu.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetasprodu.
       
   end.
   for each cadmetasclasse where
            cadmetasclasse.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetasclasse.
       
   end.
   for each cadmetasfunc where
            cadmetasfunc.codmeta = i_codmeta exclusive-lock:
            
       delete cadmetasfunc.
       
   end.
   


end procedure.


procedure pi-relato:

  disp  skip(1)
        esqrela[1] skip
        esqrela[2] skip
        with frame f-escrela title "RELATORIOS" row 7
             centered color with/black no-label overlay.
               
  choose field esqrela auto-return with frame f-escrela.
                   
  clear frame f-escrela no-pause.
  hide frame f-escrela  no-pause.
                           
  if frame-index = 1
  then do:
          update "Confirma Impressao "
                 sresp format "Sim/Nao"
                 help "Sim/Nao"
                 with frame f-lista row 15 centered 
                      color black/cyan no-label.
          if sresp = yes
          then do:
                  hide frame f-lista.
                  
                  clear frame f-lista2.
                  
                  sresp = no.
                  
                  update "Usar relatorio que contempla Venda(2)?"
                         sresp format "Sim/Nao"
                         help "Sim/Nao"
                         with frame f-lista2 row 15 centered
                              color black/cyan no-label.
                              
                  hide frame f-lista2.            
                              
                  if sresp = yes
                  then do:
                      run mtsrel1d.p (input recatu1).
                      /****** Novo relatório com Venda(2) *******/
                  end.    
                  else do:
                      run mtsrel1a.p (input recatu1).
                  end.    
          end.       
  end.    
  if frame-index = 2
  then do:
          run mtsrel4a.p (input recatu1). 
  end.                            

end procedure.
