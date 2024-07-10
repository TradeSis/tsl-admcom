{admcab.i}
def var varquivo as char.
def input parameter vforcod like lanaut.forcod.
def var vlancod like lanaut.lancod.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer blanaut       for lanaut.
def var vetbcod         like lanaut.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

bl-princ:
repeat:

    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first lanaut where lanaut.forcod = vforcod no-error.
    else find lanaut where recid(lanaut) = recatu1.
    
    vinicio = yes.
    if not available lanaut
    then do:
        message "Nao existe cod. contabil para este fornecedor".
        message "Deseja Incluir " update sresp.
        if not sresp
        then return.
        do with frame f-inclui1  overlay row 6 centered side-label.
            
            update vetbcod label "Filial" at 5.
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada".
                pause.
                undo, retry.
            end.
            display estab.etbnom no-label.
            
            update vlancod label "Cod. Contabil" at 5.
            find tablan where tablan.lancod = vlancod no-lock no-error.
            if not avail tablan
            then do:
                
                message "Codigo contabil nao cadastrado".
                pause.
                undo, retry.
                
            end.
            display tablan.landes no-label.
                    
            create lanaut. 
            assign lanaut.etbcod = estab.etbcod
                   lanaut.forcod = vforcod
                   lanaut.lancod = tablan.lancod
                   lanaut.lanhis = tablan.lanhis.
            
            vinicio = no.
            
        end.
    end.
    clear frame frame-a all no-pause.
    find tablan where tablan.lancod = lanaut.lancod no-lock no-error.
    
    display lanaut.etbcod column-label "Fl" 
            lanaut.lancod column-label "Cod.Cont."
            tablan.landes format "x(30)" when avail tablan
            lanaut.lanhis column-label "Hist" format ">>9"
            lanaut.comhis format "x(25)"
                with frame frame-a 14 down centered
                    title "Fornecedor: " + string(lanaut.forcod).

    recatu1 = recid(lanaut).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next lanaut where lanaut.forcod = vforcod.
        if not available lanaut
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find tablan where tablan.lancod = lanaut.lancod no-lock no-error.
        display lanaut.etbcod
                lanaut.lancod
                tablan.landes when avail tablan 
                lanaut.lanhis
                lanaut.comhis
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find lanaut where recid(lanaut) = recatu1.

        run color-message.
        choose field lanaut.etbcod
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
                find next lanaut where lanaut.forcod = vforcod no-error.
                if not avail lanaut
                then leave.
                recatu1 = recid(lanaut).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev lanaut where lanaut.forcod = vforcod no-error.
                if not avail lanaut
                then leave.
                recatu1 = recid(lanaut).
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
            find next lanaut where lanaut.forcod = vforcod no-error.
            if not avail lanaut
            then next.
            color display normal
                lanaut.etbcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev lanaut where lanaut.forcod = vforcod no-error.
            if not avail lanaut
            then next.
            color display normal
                lanaut.etbcod.
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
            then do with frame f-inclui overlay row 6 centered side-label.
            
                
                update vetbcod label "Filial" at 5.
                find estab where estab.etbcod = vetbcod no-lock no-error.
                if not avail estab
                then do:
                    message "Filial nao cadastrada".
                    pause.
                    undo, retry.
                end.
                display estab.etbnom no-label.
            
                update vlancod label "Cod. Contabil" at 5.
                find tablan where tablan.lancod = vlancod no-lock no-error.
                if not avail tablan
                then do:
                
                    message "Codigo contabil nao cadastrado".
                    pause.
                    undo, retry.
                
                end.
                display tablan.landes no-label.
                    
                create lanaut. 
                assign lanaut.etbcod = estab.etbcod
                       lanaut.forcod = vforcod
                       lanaut.lancod = tablan.lancod
                       lanaut.lanhis = tablan.lanhis.
            

                recatu1 = recid(lanaut).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame frame-a.
                update lanaut.etbcod 
                       lanaut.lancod.
                find tablan where tablan.lancod = lanaut.lancod 
                        no-lock no-error.
                if not avail tablan
                then do:
                    message "Conta Contabil nao Cadastrada".
                    pause.
                    undo, retry.
                end.
                display tablan.landes with frame frame-a.
                update lanaut.lanhis  
                       lanaut.comhis with frame frame-a.
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp lanaut with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" lanaut.forcod update sresp.
                if not sresp
                then leave.
                find next lanaut where lanaut.forcod = vforcod no-error.
                if not available lanaut
                then do:
                    find lanaut where recid(lanaut) = recatu1.
                    find prev lanaut where lanaut.forcod = vforcod no-error.
                end.
                recatu2 = if available lanaut
                          then recid(lanaut)
                          else ?.
                find lanaut where recid(lanaut) = recatu1.
                delete lanaut.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do: 
                
                recatu2 = recatu1.
                
                varquivo = "l:\relat\lanaut." + string(time).  
                
                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "0" 
                        &Cond-Var  = "147" 
                        &Page-Line = "0" 
                        &Nom-Rel   = ""lanaut"" 
                        &Nom-Sis   = """SISTEMA CONTABILIDADE""" 
                        &Tit-Rel   = """PLANO DE CONTAS"""
                        &Width     = "147"  
                        &Form      = "frame f-cabcab"}
    
                
                for each lanaut where lanaut.forcod = vforcod
                                        no-lock by lanaut.etbcod:
                     
                    find tablan where tablan.lancod = lanaut.lancod 
                            no-lock no-error.
  
                    
                    display lanaut.etbcod column-label "Fl" 
                            lanaut.lancod column-label "Cod.Cont."
                            tablan.landes format "x(30)"
                            lanaut.lanhis column-label "Hist" format ">>9"
                            lanaut.comhis format "x(25)"
                            with frame f-Lista down width 120
                                title "Fornecedor: " + string(lanaut.forcod).
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

        find tablan where tablan.lancod = lanaut.lancod no-lock no-error.
  
        display lanaut.etbcod
                lanaut.lancod
                tablan.landes 
                lanaut.lanhis
                lanaut.comhis
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(lanaut).
   end.
end.

procedure color-message.
color display message
        lanaut.etbcod
        lanaut.lancod
        tablan.landes 
        lanaut.lanhis 
        lanaut.comhis
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        lanaut.etbcod
        lanaut.lancod
        tablan.landes 
        lanaut.lanhis 
        lanaut.comhis
            with frame frame-a.
end procedure.

