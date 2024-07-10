/*                   
*
*    Esqueletao de Programacao
*
*/

{admcab.i}
{setbrw.i}

def var vopecod like operadoras.opecod.
def var vtipviv like plaviv.tipviv.
def var vcodviv like plaviv.codviv.
def var vprocod like plaviv.procod.

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Consulta","Listagem","Procura"].

def var esqcom2         as char format "x(25)" extent 3 /*5*/
            initial ["Altera Situacao" , ""
                    ,"  " /*,"",""*/].


def buffer bplaviv       for plaviv.

def var v-ativa  as   log format "Ativar/Desativar".
def var v-conf   as   log format "Sim/Nao" init no.

def var v-tipviv like plaviv.tipviv.
def var v-codviv like plaviv.codviv.

def var v-seleciona-filiais as logical format "Sim/Nao".

def var v-todas-as-filiais as logical format "Sim/Nao".

def temp-table tt-plaviv like plaviv.

def new shared temp-table tt-lj  like estab.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
                 
    form v-seleciona-filiais label "Fil"
            with frame f-sel-filiais.
                 
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first plaviv where plaviv.exportado = yes
                            and plaviv.dtfin >= today
                             no-error.
    else
        find plaviv where recid(plaviv) = recatu1.

    vinicio = yes.
    
    if not available plaviv
    then do:
        message "Cadastro de Planos Vivo Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6  centered side-labels.
            create plaviv.
                update plaviv.tipviv    label "Serviço.." format ">>>9".
                find promoviv where
                     promoviv.tipviv = plaviv.tipviv no-lock no-error.
                disp promoviv.provivnom no-label when avail promoviv at 21 skip.
                
                update plaviv.codviv    label "Plano...." format ">>>9".
                find planoviv where
                     planoviv.codviv = plaviv.codviv no-lock no-error.
                disp planoviv.planomviv no-label when avail planoviv at 21 skip.
                
                
                update plaviv.procod    label "Produto.." .
                find produ where produ.procod = plaviv.procod no-lock no-error.
                disp produ.pronom no-label when avail produ at 21 skip.
                
                plaviv.exportado = yes.
                
                update
                       plaviv.prepro    label "Pc.Prom.." skip
                       plaviv.dtini     label "Dt.Inicio" skip
                       plaviv.dtfin     label "Dt.Final." skip
                       plaviv.exportado label "Situacao."
                        format "Ativo/Inativo". 
                              
            vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find produ where produ.procod = plaviv.procod no-lock no-error.
    display plaviv.procod 
            produ.pronom format "x(32)" when avail produ
                column-label "Descricao"
            plaviv.tipviv column-label "Serv" format ">>>9"
            plaviv.codviv column-label "Plan" format ">>>9"
            plaviv.prepro format ">,>>9.99" column-label "Pc.Prom." 
            plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"
                with frame frame-a 13 down centered.

    recatu1 = recid(plaviv).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next plaviv where plaviv.exportado = yes
                                    and plaviv.dtfin >= today.
        if not available plaviv
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find produ where produ.procod = plaviv.procod no-lock no-error.
        display plaviv.procod 
                produ.pronom when avail produ
                plaviv.tipviv   format ">>>9"
                plaviv.codviv   format ">>>9"
                plaviv.prepro
                plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"

                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find plaviv where recid(plaviv) = recatu1.

        run color-message.
        choose field plaviv.tipviv plaviv.codviv plaviv.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next plaviv where plaviv.exportado = yes
                                   and plaviv.dtfin >= today
                                           no-error.
                if not avail plaviv
                then leave.
                recatu1 = recid(plaviv).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev plaviv where plaviv.exportado = yes
                                   and plaviv.dtfin >= today
                                             no-error.
                if not avail plaviv
                then leave.
                recatu1 = recid(plaviv).
            end.
            leave.
        end.


        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next plaviv where plaviv.exportado = yes
                               and plaviv.dtfin >= today
                                     no-error.
            if not avail plaviv
            then next.
            color display normal
                plaviv.tipviv plaviv.codviv plaviv.procod .
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev plaviv where plaviv.exportado = yes
                               and plaviv.dtfin >= today                                                             no-error.
            if not avail plaviv
            then next.
            color display normal
                   plaviv.tipviv plaviv.codviv plaviv.procod .
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 side-labels centered.
                
              create tt-plaviv.

              update tt-plaviv.tipviv label "Serviço..........." format ">>>9".
              find promoviv where
                   promoviv.tipviv = tt-plaviv.tipviv no-lock no-error.
              disp promoviv.provivnom no-label when avail promoviv skip.
                
              update tt-plaviv.codviv label "Plano............." format ">>>9".
              find planoviv where
                   planoviv.codviv = tt-plaviv.codviv no-lock no-error.
              disp planoviv.planomviv no-label when avail planoviv skip.
              
              update tt-plaviv.procod label "Produto..........." .
              find produ where produ.procod = tt-plaviv.procod no-lock no-error.
              disp produ.pronom format "x(25)" no-label when avail produ skip.
              
              tt-plaviv.exportado = yes.
              
              update
                tt-plaviv.prepro    label "Pc.Prom..........." skip
                tt-plaviv.dtini     label "Dt.Inicio........." skip
                tt-plaviv.dtfin     label "Dt.Final.........." skip
                tt-plaviv.exportado label "Situacao.........."
                 format "Ativo/Inativo" skip. 
              
              assign sresp = false.
              
              update sresp label "Seleciona Filiais?"
       help "Sim = Abre seleção de Filiais | Não = Seleciona TODAS as filiais.".

              if sresp
              then do:

                  bl_sel_filiais:
                  repeat:
                    
                      hide frame f-inclui. 

                      run sel_plaviv_etb.p (input tt-plaviv.tipviv,
                                            input tt-plaviv.codviv,
                                            input tt-plaviv.procod).
                       if keyfunction(lastkey) = "end-error"
                      then leave bl_sel_filiais.
                       release plaviv_filial.
                      find first plaviv_filial
                           where plaviv_filial.tipviv = tt-plaviv.tipviv
                             and plaviv_filial.codviv = tt-plaviv.codviv
                             and plaviv_filial.procod = tt-plaviv.procod
                                     no-lock no-error.
                                 
                      if not avail plaviv_filial
                      then do:
                          bell.
                          message color red/with
                         "Nenuma filial selecionada para o plano." skip
                         "Serviço nao sera cadastrado."
                          view-as alert-box.
                       end.
                       else release plaviv_filial.

                    end.

                end.
                else do:

                    for each  plaviv_filial
                        where plaviv_filial.tipviv = tt-plaviv.tipviv
                          and plaviv_filial.codviv = tt-plaviv.codviv
                          and plaviv_filial.procod = tt-plaviv.procod
                                                        no-lock.
                    
                        run deleta_plaviv_filial.p
                                        (input plaviv_filial.tipviv,
                                         input plaviv_filial.codviv,
                                         input plaviv_filial.procod,
                                         input plaviv_filial.etbcod)
                                          no-error.

                    end.          
                    
                    run cria_plaviv_filial.p (input tt-plaviv.tipviv,
                                              input tt-plaviv.codviv,
                                              input tt-plaviv.procod,
                                              input 0) no-error.
                    release plaviv_filial.          
                end.
 
               assign sresp = true.
                
              find first bplaviv where bplaviv.procod = tt-plaviv.procod
                                   and bplaviv.codviv = tt-plaviv.codviv
                                   and bplaviv.tipviv = tt-plaviv.tipviv
                                        no-error.
                                        
              if avail bplaviv
              then do:
              
                  display "A promoção abaixo com o mesmo Produto, Operadora e"
                          "Plano será substituída." skip 
                          "Pc.Prom " bplaviv.prepro  no-label  skip
                          "Dt.Inicio " bplaviv.dtini no-label  skip
                          "Dt.Final " bplaviv.dtfin  no-label  skip
                          "Deseja continuar? " 
                             with frame f-msg overlay row 15.
              
                  update sresp no-label with frame f-msg overlay.
              
                  if not sresp
                  then undo,retry.
                  else do:
                  
                     buffer-copy tt-plaviv to bplaviv.
                     recatu1 = recid(bplaviv).

                  end.

                  hide frame f-msg.  

              end.
              else do:
                
                  sresp = no.
                  message "Deseja confirmar a inclusão? " update sresp.
                
                  if not sresp then do:
                  
                     for each  plaviv_filial
                         where plaviv_filial.tipviv = tt-plaviv.tipviv
                           and plaviv_filial.codviv = tt-plaviv.codviv
                           and plaviv_filial.procod = tt-plaviv.procod
                                                        no-lock.
                    
                         run deleta_plaviv_filial.p
                                        (input plaviv_filial.tipviv,
                                         input plaviv_filial.codviv,
                                         input plaviv_filial.procod,
                                         input plaviv_filial.etbcod)
                                          no-error.

                     end.          

                     undo, retry.
                    
                  end.
                  
                  create plaviv.
                  buffer-copy tt-plaviv to plaviv.

                  recatu1 = recid(plaviv).
                  
              end.    
            
              leave.

            end.

            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 centered side-labels.

                find promoviv where
                     promoviv.tipviv = plaviv.tipviv no-lock no-error.
                disp plaviv.tipviv  label "Serviço..........." format ">>>9"
                     promoviv.provivnom no-label when avail promoviv
                      skip.
                find planoviv where 
                     planoviv.codviv = plaviv.codviv no-lock no-error.
                disp plaviv.codviv  label "Plano............." format ">>>9"
                     planoviv.planomviv no-label when avail planoviv 
                     skip.
                find produ where produ.procod = plaviv.procod no-lock no-error.
                disp plaviv.procod  label "Produto..........."
                     produ.pronom no-label when avail produ  format "x(30)"
                     skip.
                disp 
                     plaviv.prepro    label "Pc.Prom..........." skip
                     plaviv.dtini     label "Dt.Inicio........." skip
                     plaviv.dtfin     label "Dt.Final.........." skip
                     plaviv.exportado label "Situacao.........."
                        format "Ativo/Inativo".
                 

                /***
                update plaviv.tipviv    label "Serviço.." .
                find promoviv where
                     promoviv.tipviv = plaviv.tipviv no-lock no-error.
                disp promoviv.provivnom no-label when avail promoviv skip.
                
                update plaviv.codviv    label "Plano...." .
                find planoviv where
                     planoviv.codviv = plaviv.codviv no-lock no-error.
                disp planoviv.planomviv no-label when avail planoviv skip.

                update plaviv.procod    label "Produto.." .
                find produ where produ.procod = plaviv.procod no-lock no-error.
                disp produ.pronom no-label when avail produ skip.
                
                ***/
                       
                update        
                       plaviv.prepro    label "Pc.Prom..........." skip
                       plaviv.dtini     label "Dt.Inicio........." skip
                       plaviv.dtfin     label "Dt.Final.........." skip
                       plaviv.exportado label "Situacao.........."
                        format "Ativo/Inativo"
                            help "[A] Ativo  [I] Inativo"
                            with frame f-altera no-validate.
                            
                assign sresp = false.
                
                display with frame f-altera.

                update sresp label "Seleciona Filiais?"
       help "Sim = Abre seleção de Filiais | Não = Seleciona TODAS as filiais.".

                if sresp
                then do:

                    bl_sel_filiais:
                    repeat:
                    
                        hide frame f-altera. 

                        run sel_plaviv_etb.p (input plaviv.tipviv,
                                              input plaviv.codviv,
                                              input plaviv.procod).

                        if keyfunction(lastkey) = "end-error"
                        then leave bl_sel_filiais.

                        release plaviv_filial.
                        find first plaviv_filial
                             where plaviv_filial.tipviv = plaviv.tipviv
                               and plaviv_filial.codviv = plaviv.codviv
                               and plaviv_filial.procod = plaviv.procod
                                       no-lock no-error.
                                   
                        if not avail plaviv_filial
                        then do:
                            bell.
                            message color red/with
                           "Nenuma filial selecionada para o plano." skip
                           "Serviço nao sera cadastrado."
                            view-as alert-box.
                        end.
                        else release plaviv_filial.

                    end.

                end.
                else do:

                    for each  plaviv_filial
                        where plaviv_filial.tipviv = plaviv.tipviv
                          and plaviv_filial.codviv = plaviv.codviv
                          and plaviv_filial.procod = plaviv.procod
                                                        no-lock.
                    
                        run deleta_plaviv_filial.p
                                        (input plaviv_filial.tipviv,
                                         input plaviv_filial.codviv,
                                         input plaviv_filial.procod,
                                         input plaviv_filial.etbcod)
                                         no-error.

                    end.          
                    
                    run cria_plaviv_filial.p (input plaviv.tipviv,
                                              input plaviv.codviv,
                                              input plaviv.procod,
                                              input 0) no-error.
                              
                end.
                
                sresp = yes.
                message "Deseja confirmar as alterações? " update sresp.
  
                if not sresp
                then undo, retry.

            end.

            
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 centered side-labels.
                find promoviv where
                     promoviv.tipviv = plaviv.tipviv no-lock no-error.
                disp plaviv.tipviv  label "Serviço.." format ">>>9"
                     promoviv.provivnom no-label when avail promoviv
                     at 21 skip.
                find planoviv where 
                     planoviv.codviv = plaviv.codviv no-lock no-error.
                disp plaviv.codviv  label "Plano...." format ">>>9"
                     planoviv.planomviv no-label when avail planoviv 
                     at 21 skip.
                find produ where produ.procod = plaviv.procod no-lock no-error.
                disp plaviv.procod  label "Produto.."
                     produ.pronom no-label when avail produ 
                     at 21 skip.
                disp 
                     plaviv.prepro    label "Pc.Prom.." skip
                     plaviv.dtini     label "Dt.Inicio" skip
                     plaviv.dtfin     label "Dt.Final." skip
                     plaviv.exportado label "Situacao."
                        format "Ativo/Inativo" skip with frame f-consulta.
                                       
                release plaviv_filial.
                find first plaviv_filial
                     where plaviv_filial.tipviv = plaviv.tipviv
                       and plaviv_filial.codviv = plaviv.codviv
                       and plaviv_filial.procod = plaviv.procod
                       and plaviv_filial.etbcod = 0
                                      no-lock no-error.
                                       
                if avail plaviv_filial
                then do:
                
                    Display "Filiais..: TODAS as Filiais selecionadas"
                            with frame f-consulta.
                
                end.
                else run p-lista-fil (input plaviv.tipviv,
                                      input plaviv.codviv,
                                      input plaviv.procod).
                                       
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" plaviv.procod update sresp.
                if not sresp
                then leave.
                find next plaviv where true no-error.
                if not available plaviv
                then do:
                    find plaviv where recid(plaviv) = recatu1.
                    find prev plaviv where true no-error.
                end.
                recatu2 = if available plaviv
                          then recid(plaviv)
                          else ?.
                find plaviv where recid(plaviv) = recatu1.
                
                for each  plaviv_filial
                    where plaviv_filial.tipviv = plaviv.tipviv
                      and plaviv_filial.codviv = plaviv.codviv
                      and plaviv_filial.procod = plaviv.procod.
                
                    delete plaviv_filial.

                end.

                delete plaviv.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered.
                 view frame frame-a. pause 0.
                 assign vtipviv = 0
                        vcodviv = 0
                        vprocod = 0
                        vopecod = 0.

                 update vopecod label "Operadora." format ">9" skip
                        vtipviv label "Serviço..." format ">>>9" skip
                        vcodviv label "Plano....." format ">>>9" skip
                        vprocod label "Produto..."
                        with frame f-proc centered side-labels overlay row 10.
                        
                 if vopecod = 0
                 then do:
                     find first bplaviv where
                                (if vtipviv <> 0
                                 then bplaviv.tipviv = vtipviv
                                 else true) and
                                (if vcodviv <> 0
                                 then bplaviv.codviv = vcodviv
                                 else true) and
                                (if vprocod <> 0
                                 then bplaviv.procod = vprocod
                                 else true) no-lock no-error.
                 end.
                 else do:

                    if vopecod = 1
                    then do:
                         find first bplaviv where
                                    (if vtipviv <> 0
                                     then bplaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then bplaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then bplaviv.procod = vprocod
                                     else true) and
                                     
                                     (bplaviv.tipviv <> 1001 and
                                      bplaviv.tipviv <> 1002 and
                                      bplaviv.tipviv <> 1072)
                                     
                                     no-lock no-error.
                    end.
                    else if vopecod = 3
                    then do:
                    
                         find first bplaviv where
                                    (if vtipviv <> 0
                                     then bplaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then bplaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then bplaviv.procod = vprocod
                                     else true) and
                                     
                                    (bplaviv.tipviv = 1001 or
                                     bplaviv.tipviv = 1002 or
                                     bplaviv.tipviv = 1072)

                                     
                                     no-lock no-error.
                    
                    
                    end.
                    else do:
                            find first bplaviv where
                                    (if vtipviv <> 0
                                     then bplaviv.tipviv = vtipviv
                                     else true) and
                                    (if vcodviv <> 0
                                     then bplaviv.codviv = vcodviv
                                     else true) and
                                    (if vprocod <> 0
                                     then bplaviv.procod = vprocod
                                     else true) and
                                     
                                    (bplaviv.tipviv = 2001 or
                                     bplaviv.tipviv = 2002)

                            no-lock no-error.
                    end.
                 end.
        
                 if not avail bplaviv
                 then do:
                    recatu1 = ?.
                    leave.
                 end.    
                 
                 recatu1 = recid(bplaviv). 
                 leave.
                
            end.
            
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de plavividades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each plaviv:
                    display plaviv.
                end.
                output close.
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            /*message esqregua esqpos2 esqcom2[esqpos2].*/

            if esqcom2[esqpos2] = "Altera Situacao"
            then do:

                    do on error undo:
                        v-tipviv = 0.
                        update v-tipviv label "Serviço" format ">>>9"
                            with frame f-alsit overlay
                                centered side-labels.
                        
                        if v-tipviv = 0
                        then undo.
                        
                        find promoviv where 
                             promoviv.tipviv = v-tipviv no-lock no-error.
                        if not avail promoviv
                        then do:
                            message "Serviço não cadastrado".
                            undo.
                        end.
                        else disp promoviv.provivnom no-label
                                  skip
                                  with frame f-alsit.
                    end.
                        
                    do on error undo:
                        v-codviv = 0.
                        update v-codviv label "Plano..." format ">>>9"
                            with frame f-alsit.
                        
                        if v-codviv = 0
                        then undo.
                        
                        find planoviv where
                             planoviv.codviv = v-codviv no-lock no-error.
                        if not avail planoviv
                        then do:
                            message "Plano nao cadastrado".
                            undo.
                        end.
                        else disp planoviv.planomviv no-label 
                                  with frame f-alsit.
                    end.
                    
                    v-ativa = no.
                    update skip v-ativa label "Situacao" with frame f-alsit.

                    v-conf = no.
                    update skip v-conf  label "Confirma" with frame f-alsit.
                    
                    if not v-conf
                    then leave.
                    else do:
                        for each plaviv where plaviv.tipviv = v-tipviv
                                          and plaviv.codviv = v-codviv:
                            assign plaviv.exportado = v-ativa.
                        end.
                    end.
                    
                    hide frame f-alsit no-pause.    
                    hide message no-pause.
            
            end.
                        
            if esqcom2[esqpos2] = "Atualiza Pc.Tabela"
            then do:               /*
                message "Atualizando...".
                for each bplaviv:
                    find first estoq where
                               estoq.procod = bplaviv.procod no-lock no-error.
                    if avail estoq
                    then do transaction:
                        if bplaviv.tipviv = 3
                        then
                            bplaviv.prepro = estoq.estvenda.
                            
                        bplaviv.pretab = estoq.estvenda.
                    end.
                end.
                hide message no-pause.*/
            end.
                                                 /*
            if esqcom2[esqpos2] = "Pc.Promocao = Pc.Tabela"
            then do on error undo:
                view frame frame-a. pause 0.

                update vopecod label "Operadora" format ">>>9"
                       help "Informe o codigo da Operadora ou zero para todas."
                       with frame f-at.
                
                if vopecod <> 0
                then do:
                    find operadoras where 
                         operadoras.opecod = vopecod no-lock no-error.
                    if not avail operadoras
                    then do:
                        message "Operadora nao cadastrada.".
                        undo.
                    end.
                    else disp operadoras.openom no-label with frame f-at.
                end.
                else disp "TODOS" @ operadoras.openom with frame f-at.
                       
                update skip
                       vtipviv label "Serviço." format ">>>9"
                       help "Informe o codigo do Serviço ou zero para todas."
                       with frame f-at centered side-labels overlay
                                       row 10 color white/red.
                if vtipviv <> 0
                then do:
                    find promoviv where 
                         promoviv.tipviv = vtipviv no-lock no-error.
                    if not avail promoviv
                    then do:
                        message "Serviço nao cadastrado.".
                        undo.
                    end.
                    else disp promoviv.provivnom no-label with frame f-at.
                end.
                else disp "TODOS" @ promoviv.provivnom with frame f-at.
                
                update skip
                       vcodviv label "Plano...." format ">>>9"
                       help "Informe o codigo do plano ou zero para todos."
                       with frame f-at.
                       
                if vcodviv <> 0
                then do:
                    find planoviv where 
                         planoviv.codviv = vcodviv no-lock no-error.
                    if not avail planoviv
                    then do:
                        message "Plano nao cadastrado.".
                        undo.
                    end.
                    else disp planoviv.planomviv no-label with frame f-at.
                end.
                else disp "TODOS" @ planoviv.planomviv with frame f-at.

                sresp = no.
                message "Confirma a atualizacao de precos?" update sresp.
                if sresp
                then do:
                    for each bplaviv where 
                             bplaviv.tipviv = (if vtipviv <> 0 
                                               then vtipviv 
                                               else bplaviv.tipviv) and
                             bplaviv.codviv = (if vcodviv <> 0  
                                               then vcodviv
                                               else bplaviv.codviv):
                    
                        if vopecod <> 0
                        then do:
                        
                            find promoviv where 
                                 promoviv.opecod = vopecod and
                                 promoviv.tipviv = bplaviv.tipviv   
                                 no-lock no-error.
                            if not avail promoviv
                            then next.

                        end.
                        
                        find first estoq where
                                   estoq.procod = bplaviv.procod 
                                                  no-lock no-error.
                        if avail estoq
                        then 
                             bplaviv.prepro = estoq.estvenda.
                    end.
                    
                    
                end.
                
                hide message no-pause.
            end.
                                                   */
            
            /**pause.**/
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        find produ where produ.procod = plaviv.procod no-lock no-error.
        display plaviv.tipviv format ">>>9"
                plaviv.codviv format ">>>9"
                plaviv.procod 
                produ.pronom when avail produ 
                plaviv.prepro  
                plaviv.exportado column-label "Situacao"
                        format "Ativo/Inativo"
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(plaviv).
   end.
end.

procedure color-message.
color display message
        plaviv.procod
        produ.pronom column-label "Descricao"
        plaviv.tipviv format ">>>9"
        plaviv.codviv format ">>>9"
        plaviv.prepro  
        plaviv.exportado column-label "Situacao"  format "Ativo/Inativo"
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        plaviv.procod
        produ.pronom column-label "Descricao"
        plaviv.tipviv format ">>>9"
        plaviv.codviv format ">>>9"
        plaviv.prepro
        plaviv.exportado column-label "Situacao" format "Ativo/Inativo"
        with frame frame-a.
end procedure.




procedure p-lista-fil:

def input parameter par-tipviv as integer.
def input parameter par-codviv as integer.
def input parameter par-procod as integer.

def var v-cod as int.
def var v-cont as int.

form
    a-seelst format "x" column-label "*"
    estab.etbcod
    estab.etbnom
    with frame f-nome
        centered down title "LOJAS"
        color withe/red overlay.

def buffer bestab for estab.

assign 
    a-seeid = -1 a-recid = -1 a-seerec = ? a-seelst = "".

empty temp-table tt-lj.

for each plaviv_filial where plaviv_filial.tipviv = par-tipviv 
                         and plaviv_filial.codviv = par-codviv 
                         and plaviv_filial.procod = par-procod no-lock.
        
    create tt-lj.
    assign tt-lj.etbcod = plaviv_filial.etbcod.

end.

for each tt-lj no-lock.
    
    assign a-seelst = a-seelst + "," + string(tt-lj.etbcod,"99999").
            
end.

empty temp-table tt-lj.
            
    
{sklcls_consulta.i
    &File   = estab
    &help   = "           TELA DE CONSULTA - PRESSIONE ENTER PARA SAIR   "
    &CField = estab.etbnom    
    &Ofield = " estab.etbcod"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &UsePick = "*"          
    &PickFld = "estab.etbcod" 
    &PickFrm = "99999" 
    &Form = " frame f-nome overlay row 5 centered"  
}. 

hide frame f-nome.


end procedure.

