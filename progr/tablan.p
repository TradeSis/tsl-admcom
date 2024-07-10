{admcab.i}
def var varquivo as char.
def var vlandeb like tablan.landeb.
def var vlancre like tablan.lancre.
def var vtabcod like tablan.lancod.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
 initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem","Procura"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer btablan       for tablan.
def var vlancod         like tablan.lancod.
def var vetbfixd as log format "S/N" init no.
def var vetbfixc as log format "S/N" init no.

    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tablan where
            true no-error.
    else
        find tablan where recid(tablan) = recatu1.
    vinicio = yes.
    if not available tablan
    then do:
        message "Tabela de Lancamentos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                vtabcod = 0.
                vlandeb = 0.
                vlancre = 0.
                find last btablan no-error.
                if not avail btablan
                then vlancod = 1.
                else vlancod = btablan.lancod + 1.
                create tablan.
                assign tablan.lancod = vlancod.

                update tablan.lancod
                       tablan.landes
                       vlandeb
                       vlancre.

                find first btablan where btablan.landeb = vlandeb and
                                         btablan.lancre = vlancre
                                                no-lock no-error.
                if avail btablan
                then do:
                    message "Tabela de lancamentos ja cadastrado".
                    undo, retry.
                end.

                assign tablan.landeb = vlandeb
                       tablan.lancre = vlancre.

                update tablan.lanhis  
                       tablan.lancomp 
                       tablan.lanexp.  

                vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display tablan.lancod  column-label "Cod"
            tablan.landes
            tablan.etbcod  column-label "Fil" 
            tablan.landeb column-label "Cta Deb" 
            tablan.lancre column-label "Cta Cre" 
            tablan.lanhis  
            tablan.codred column-label "Sispro"
            tablan.etbfixd      column-label "FD"
            tablan.etbfixc      column-label "FC"
                with frame frame-a 14 down centered.

    recatu1 = recid(tablan).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tablan where
                true.
        if not available tablan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
      
        display tablan.lancod
                tablan.landes  
                tablan.etbcod
                tablan.landeb  
                tablan.lancre  
                tablan.lanhis  
                tablan.etbcod 
                tablan.codred  
                tablan.etbfixd  
                tablan.etbfixc 
                    with frame frame-a 14 down centered.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tablan where recid(tablan) = recatu1.

        choose field tablan.lancod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
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
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 6
                          then 6
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
                find next tablan where true no-error.
                if not avail tablan
                then leave.
                recatu1 = recid(tablan).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tablan where true no-error.
                if not avail tablan
                then leave.
                recatu1 = recid(tablan).
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
            find next tablan where
                true no-error.
            if not avail tablan
            then next.
            color display normal
                tablan.lancod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tablan where
                true no-error.
            if not avail tablan
            then next.
            color display normal
                tablan.lancod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            slancod = tablan.lancod.
            frame-value = slancod.
            hide frame frame-a no-pause.
            leave bl-princ.
        end.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui overlay row 6 1 column centered.
              
                vlandeb = 0.
                vlancre = 0.
                find last btablan no-error.
                if not avail btablan
                then vlancod = 1.
                else vlancod = btablan.lancod + 1.
                create tablan.
                assign tablan.lancod = vlancod.

                update tablan.lancod
                       tablan.landes
                       vlandeb
                       vlancre.
                /*
                find first btablan where btablan.landeb = vlandeb and
                                         btablan.lancre = vlancre
                                                no-lock no-error.
                if avail btablan
                then do:
                    message "Tabela de lancamentos ja cadastrado".
                    undo, retry.
                end.
                */
                assign tablan.landeb = vlandeb
                       tablan.lancre = vlancre.

                update tablan.lanhis  
                       tablan.lancomp 
                       tablan.lanexp
                       tablan.codred label "Sispro".  

            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                
              update tablan.lancod
                     tablan.landes 
                     tablan.etbcod 
                     tablan.landeb  
                     tablan.lancre  
                     tablan.lanhis   
                     tablan.codred
                     tablan.etbfixd  
                     help "Informe se lancamento debito sera fixo p/ estab 01"
                     tablan.etbfixc  
                     help "Informe se lancamento credito sera fixo p/ estab 01"
                        with frame frame-a.
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp tablan with frame f-consulta no-validate.
            end.
            

            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" tablan.landes update sresp.
                if not sresp
                then leave.
                find next tablan where true no-error.
                if not available tablan
                then do:
                    find tablan where recid(tablan) = recatu1.
                    find prev tablan where true no-error.
                end.
                recatu2 = if available tablan
                          then recid(tablan)
                          else ?.
                find tablan where recid(tablan) = recatu1.
                delete tablan.
                recatu1 = recatu2.
                leave.
            end.
            
            if esqcom1[esqpos1] = "Procura"
            then do with frame fprocura overlay row 9 side-label
                                color white/cyan centered:
                update vlancod.
                find btablan where btablan.lancod = vlancod no-lock no-error.
                if not avail btablan
                then leave.
                recatu1 = recid(btablan).
                leave.
             end.

            if esqcom1[esqpos1] = "Listagem"
            then do:
             
                recatu2 = recatu1.
                
                varquivo = "l:\relat\tablan." + string(time).  
                
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "147" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""tablan"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """LISTAGEM PLANO DE CONTAS"""
                        &Width     = "147"  
                        &Form      = "frame f-cabcab"}
    
                
                for each tablan no-lock:
                    display tablan.lancod 
                            tablan.landes
                            tablan.etbcod   
                            tablan.landeb   
                            tablan.lancre   
                            tablan.lanhis   
                            tablan.etbcod  
                            tablan.codred  
                                with frame f-Lista down width 120.
                            
                end.


                output close.
                {mrod.i}
 
                recatu1 = recatu2.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
        end.
          if keyfunction(lastkey) = "end-error"
          then view frame frame-a.
        
        display tablan.lancod
                tablan.landes  
                tablan.etbcod
                tablan.landeb  
                tablan.lancre  
                tablan.lanhis  
                tablan.etbcod 
                tablan.codred  
                tablan.etbfixd
                tablan.etbfixc
                    with frame frame-a 14 down centered.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tablan).
   end.
end.
