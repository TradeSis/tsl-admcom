{admcab.i}


def var vsenha      like func.senha.
def var vestcusto  like estoqamx.estcusto.
def var vestmgoper like estoqamx.estmgoper.
def var vestmgluc  like estoqamx.estmgluc.
def var vtabcod    like estoqamx.tabcod.
def var vestvenda  like estoqamx.estvenda.
def var reccont         as int.
def var wetccod         like produamx.etccod.
def var wprorefter      like produamx.proindice.
def var wfabcod         like produamx.fabcod.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(14)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura"].
def var esqcom2         as char format "x(14)" extent 5
            initial ["Armazena","Exclui","Custos","Promocao",""].
def buffer bproduamx       for produamx.
def buffer cproduamx       for produamx.
def var vprocod         like produamx.procod.
def var vitecod         like produamx.itecod.
def var witecod         like item.itecod.
def var vmarc           as char.
def buffer bestoqamx for estoqamx.
def buffer witem for item.
def var wrsp as l format "Sim/Nao".
    form esqcom1 with frame f-com1
                 row 4 no-box no-labels side-labels column 1.
    form esqcom2 with frame f-com2
                 row screen-lines - 2 title " Armazenagem "
                    no-labels side-labels column 1 width 80.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
bl-princ:
repeat:
    disp esqcom1 with frame f-com1.

    /* disp esqcom2 with frame f-com2. */
    if recatu1 = ?
    then find first produamx where true no-error.
    else find produamx where recid(produamx) = recatu1.
    vinicio = yes.
    if not available produamx
    then do:
        clear frame f-altera all.
        message "Cadastro de produtos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do on error undo.
            create produamx.
            {di.v 2 "vprocod"}.
            assign produamx.procod    = vprocod
                   produamx.proindice = string(vprocod)
                   produamx.itecod    = vprocod.
            display produamx.procod label "Codigo"   colon 15
                    with frame f-inc side-label centered.
            update produamx.pronom label "Descricao" colon 15
                    with frame f-inc.
            vestcusto = 0.
            update vestcusto label "Custo" colon 15 with frame f-inc.
            produamx.procvcom = vestcusto.
            
            for each centro no-lock:
                create estoqamx.
                assign estoqamx.etbcod    = centro.etbcod
                       estoqamx.procod    = produamx.procod
                       estoqamx.estcusto  = vestcusto
                       estoqamx.datexp    = today.
            end.
            
        end.
    end.
    clear frame frame-a all no-pause.
  
    display produamx.procod
            produamx.pronom   column-label "Descricao"
            produamx.procvcom column-label "Preco!Custo" format ">>,>>9.99"
                with frame frame-a 10 down row 5 centered color white/red.

    recatu1 = recid(produamx).
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next produamx where true.
        if not available produamx
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
 
        display produamx.procod
                produamx.pronom
                produamx.procvcom with frame frame-a.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find produamx where recid(produamx) = recatu1.
        choose field produamx.pronom
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up tab PF4 F4 ESC return).
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
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next produamx where true no-error.
                if not avail produamx
                then leave.
                recatu1 = recid(produamx).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev produamx where true no-error.
                if not avail produamx
                then leave.
                recatu1 = recid(produamx).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 5
                          then 5
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1] with frame f-com1.
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
            find next produamx where
                true no-error.
            if not avail produamx
            then next.
            color display white/red
                produamx.pronom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev produamx where
                true no-error.
            if not avail produamx
            then next.
            color display white/red
                produamx.pronom.
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
            then do:
                find last bproduamx no-lock no-error.
                if avail bproduamx
                then vprocod = bproduamx.procod.
                else vprocod = 0.
                
                create produamx.
                
                {di.v 1 "vprocod"}.
                assign produamx.procod    = vprocod
                       produamx.proindice = string(vprocod)
                       produamx.itecod    = vprocod.
                display produamx.procod label "Codigo"   colon 15
                        with frame f-inc side-label centered.
                update produamx.pronom label "Descricao" colon 15 
                            with frame f-inc.
                vestcusto = 0.
                update vestcusto label "Custo" colon 15 with frame f-inc.
                produamx.procvcom = vestcusto.
                
                for each centro no-lock:
                        create estoqamx.
                        assign estoqamx.etbcod    = centro.etbcod
                               estoqamx.procod    = produamx.procod
                               estoqamx.estcusto  = vestcusto
                               estoqamx.datexp    = today.
                end.
            


                leave.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera centered OVERLAY SIDE-LABELS.
                if esqcom1[esqpos1] = "Consulta"
                then do:
                    for each estoqamx of produamx:
                        find centro of estoqamx no-lock.
                        disp estoqamx.etbcod
                             centro.etbnom column-label "Centro"
                             estoqamx.estcusto  column-label "CUSTO"
                                with centered overlay row 5 9 down
                                        title "Armazenagem " + produamx.pronom
                                                color white/cyan.
                    end.
                end.

            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                display produamx.procod with frame f-inc2.
                update produamx.pronom
                       produamx.procvcom column-label "Custo" 
                                    format ">>,>>9.99"
                        with frame f-inc2 1 column.

                for each estoqamx where estoqamx.procod = produamx.procod:
                    estoqamx.estcusto = produamx.procvcom.
                end.

                    
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui row 4  centered OVERLAY SIDE-LABELS.
                message "Confirma Exclusao de" produamx.pronom update sresp.
                if not sresp
                then leave.
                find next produamx where true no-error.
                if not available produamx
                then do:
                    find produamx where recid(produamx) = recatu1.
                    find prev produamx where true no-error.
                end.
                recatu2 = if available produamx
                          then recid(produamx)
                          else ?.
                find produamx where recid(produamx) = recatu1.

                for each estoqamx where estoqamx.procod = produamx.procod:
                    delete estoqamx.
                end.
                delete produamx.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered
                    on endkey undo, retry:
                prompt-for produamx.procod with no-validate.
                find produamx using produamx.procod.
                if not avail produamx
                then do:
                    message "produamxto Invalido".
                    undo.
                end.
                recatu1 = recid(produamx).
                leave.
            end.
          end.
       end. 
       if keyfunction(lastkey) = "end-error"
       then view frame frame-a.
       
       display produamx.procod
               produamx.pronom
               produamx.procvcom with frame frame-a.
       if esqregua
       then display esqcom1[esqpos1] with frame f-com1.
       else display esqcom2[esqpos2] with frame f-com2.
       recatu1 = recid(produamx).
   end.
end.
