/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i new}
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


def buffer bduplic       for duplic.
def var vfatnum         like duplic.fatnum.


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

def buffer btabaux for tabaux.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first duplic where
            true no-error.
    else
        find duplic where recid(duplic) = recatu1.
    vinicio = yes.
    if not available duplic
    then do:
        message "Cadastro de Metas Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                create duplic.
                update duppc label "Mes"
                       fatnum label "Estab" format "999"
                       dupjur label "Meta Moveis"
                       dupval label "Meta Confeccoes"
                       dupdia label "Dias"  format "99".
                dupven = today.
          vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    find first tabaux where
               tabaux.tabela = "META-VENDA" and
               tabaux.nome_campo = string(duplic.fatnum,"999") 
               no-lock no-error.

    disp duppc label "Mes"
         fatnum label "Estab" format "999"
         dupval label "Meta Confeccoes"
         dupjur label "Meta Moveis"
         dupdia label "dias" format "99"
         tabaux.valor_campo when avail tabaux
            format "x(3)" label "Vendedores"
            with frame frame-a 12 down centered.

    recatu1 = recid(duplic).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next duplic where
                true.
        if not available duplic
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.

        find first tabaux where
               tabaux.tabela = "META-VENDA" and
               tabaux.nome_campo = string(duplic.fatnum,"999") 
               no-lock no-error.
 
        disp duppc label "Mes"
             fatnum label "Estab" format "999"
             dupval label "Meta Confeccoes"
             dupjur label "Meta Moveis"
             dupdia label "Dias" 
             tabaux.valor_campo when avail tabaux
             format "x(3)" label "Vendedores"
              with frame frame-a 12 down centered.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find duplic where recid(duplic) = recatu1.

        choose field duplic.fatnum
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
                find next duplic where true no-error.
                if not avail duplic
                then leave.
                recatu1 = recid(duplic).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev duplic where true no-error.
                if not avail duplic
                then leave.
                recatu1 = recid(duplic).
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
            find next duplic where
                true no-error.
            if not avail duplic
            then next.
            color display normal
                duplic.fatnum.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev duplic where
                true no-error.
            if not avail duplic
            then next.
            color display normal
                duplic.fatnum.
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
            then do with frame f-inclui overlay row 6 1 column centered.
                create duplic.
                update duppc label "Mes"
                       fatnum label "Estab" format "999"
                       dupjur label "Meta Moveis" 
                       dupval label "Meta Confeccoes"
                       dupdia label "Dias" format "99"
                       .
                
                find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                if not avail tabaux
                then do:
                    create tabaux.
                    assign
                        tabaux.tabela = "META-VENDA-31"
                        tabaux.nome_campo = string(duplic.fatnum,"999")
                        tabaux.tipo_campo = "INT"
                        .
                end.        
                update tabaux.valor_campo label "Vend Moveis"
                                format "x(3)".

                find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                if not avail btabaux
                then do:
                    create btabaux.
                    assign
                        btabaux.tabela = "META-VENDA-41"
                        btabaux.nome_campo = string(duplic.fatnum,"999")
                        btabaux.tipo_campo = "INT"
                        .
                end.        
                update btabaux.valor_campo label "Vend Confeccoes"
                                format "x(3)".
 
                dupven = today.
                recatu1 = recid(duplic).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
                update duppc label "Mes"
                       fatnum label "Estab" format "999"
                       dupval label "Meta Confeccoes"
                       dupjur label "Meta Moveis"
                       dupdia label "Dias" format "99"
                            with frame f-altera no-validate.
                find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                if not avail tabaux
                then do:
                    create tabaux.
                    assign
                        tabaux.tabela = "META-VENDA-31"
                        tabaux.nome_campo = string(duplic.fatnum,"999")
                        tabaux.tipo_campo = "INT"
                        .
                end. 
                update tabaux.valor_campo label "Vend Moveis"
                                format "x(3)".

                find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                if not avail btabaux
                then do:
                    create btabaux.
                    assign
                        btabaux.tabela = "META-VENDA-41"
                        btabaux.nome_campo = string(duplic.fatnum,"999")
                        btabaux.tipo_campo = "INT"
                        .
                end. 
                update btabaux.valor_campo label "Vend Confeccoes"
                                format "x(3)".
 
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                find first tabaux where
                   tabaux.tabela = "META-VENDA-31" and
                   tabaux.nome_campo = string(duplic.fatnum,"999") 
                   no-lock no-error.
                find first btabaux where
                   btabaux.tabela = "META-VENDA-41" and
                   btabaux.nome_campo = string(duplic.fatnum,"999") 
                   no-lock no-error.
            
                display duppc label "Mes"
                       fatnum label "Estab" format "999"
                       dupjur label "Meta Moveis"
                       dupval label "Meta Confeccoes"
                       dupdia label "Dias" format "99"
                       tabaux.valor_campo when avail tabaux format "x(3)"
                        label "Vend Moveis"
                       btabaux.valor_campo when avail btabaux format "x(3)"
                        label "Vend Confeccoes"
                                with frame f-consulta no-validate.
                /*
                find first tabaux where
                      tabaux.tabela = "META-VENDA" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                
                disp tabaux.valor_campo label "Vendedor"
                                format "x(3)" with frame f-consulta.
                */
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" duplic.duppc update sresp.
                if not sresp
                then leave.
                find next duplic where true no-error.
                if not available duplic
                then do:
                    find duplic where recid(duplic) = recatu1.
                    find prev duplic where true no-error.
                end.
                recatu2 = if available duplic
                          then recid(duplic)
                          else ?.
                find duplic where recid(duplic) = recatu1.
                delete duplic.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de duplicidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each duplic:
                    display duppc column-label "Mes"
                           fatnum column-label "Estab" format "999"
                           dupjur column-label "Meta!Moveis"
                           dupval column-label "Meta!Confeccoes"
                           dupdia column-label "Dias"
                            with frame f-imp width 200 down.
                    find first tabaux where
                      tabaux.tabela = "META-VENDA-31" and
                      tabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                
                    disp tabaux.valor_campo  when avail tabaux
                        column-label "Vend!Moveis"
                                format "x(3)" with frame f-imp.
                    find first btabaux where
                      btabaux.tabela = "META-VENDA-41" and
                      btabaux.nome_campo = string(duplic.fatnum,"999") 
                       no-error.
                
                    disp btabaux.valor_campo  when avail btabaux
                        column-label "Vend!Confeccoes"
                                format "x(3)" with frame f-imp.

                end.
                output close.
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
       
        find first tabaux where
               tabaux.tabela = "META-VENDA-31" and
               tabaux.nome_campo = string(duplic.fatnum,"999") 
               no-lock no-error.
        find first btabaux where
               btabaux.tabela = "META-VENDA-41" and
               btabaux.nome_campo = string(duplic.fatnum,"999") 
               no-lock no-error.
         disp duppc label "Mes"
             fatnum label "Fil" format "999"
             dupjur column-label "Meta!Moveis"   
             dupval column-label "Meta!Confeccoes"
             dupdia label "Dias" 
             tabaux.valor_campo when avail tabaux
                       format "x(3)" column-label "Vend!Moveis"
             btabaux.valor_campo when avail btabaux
                       format "x(3)" column-label "Vend!Confeccoes"
              with frame frame-a 12 down centered.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(duplic).
   end.
end.
