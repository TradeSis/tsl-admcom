{admcab.i}

def var vsenha      like func.senha.
def var vestcusto  like estoqamx.estcusto.
def var vestmgoper like estoqamx.estmgoper.
def var vestmgluc  like estoqamx.estmgluc.
def var vtabcod    like estoqamx.tabcod.
def var vestvenda  like estoqamx.estvenda.
def var reccont         as int.
def var wetccod         like produsrv.etccod.
def var wprorefter      like produsrv.proindice.
def var wfabcod         like produsrv.fabcod.
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
def buffer bprodusrv       for produsrv.
def buffer cprodusrv       for produsrv.
def var vprocod         like produsrv.procod.
def var vitecod         like produsrv.itecod.
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

def var vcodservi like servicos.codigo.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.

    /* disp esqcom2 with frame f-com2. */
    if recatu1 = ?
    then find first produsrv where true no-error.
    else find produsrv where recid(produsrv) = recatu1.
    vinicio = yes.
    if not available produsrv
    then do:
        clear frame f-altera all.
        message "Cadastro de produtos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        
        do on error undo.
            
            create produsrv.
            vprocod = 900000001.
            
            /*{di.v 2 "vprocod"}.*/

            assign produsrv.procod    = vprocod
                   produsrv.proindice = string(vprocod)
                   produsrv.itecod    = vprocod.
            display produsrv.procod label "Codigo"   colon 15
                    format ">>>>>>>>>9"
                    with frame f-inc side-label centered.
            update produsrv.pronom label "Descricao" colon 15
                    with frame f-inc.
            vestcusto = 0.
            
            update vcodservi label "Cod. Servico" 
                colon 15 with frame f-inc no-validate.
            find servicos where servicos.codigo = vcodservi no-lock no-error.
            if not avail servicos
            then do:
                bell.
                message color red/with
                "Codigo de servico padrao nao cadastrado."
                view-as alert-box.
                undo.
            end.
            produsrv.proindice = vcodservi.
            
            /*
            update vestcusto label "Custo" colon 15 with frame f-inc.
            
            produsrv.procvcom = vestcusto.
            
            for each centro no-lock:
                create estoqamx.
                assign estoqamx.etbcod    = centro.etbcod
                       estoqamx.procod    = produsrv.procod
                       estoqamx.estcusto  = vestcusto
                       estoqamx.datexp    = today.
            end.
            */
        end.
    end.
    clear frame frame-a all no-pause.
  
    
    display produsrv.procod   format ">>>>>>>>9"
            produsrv.pronom   column-label "Descricao"
            produsrv.proindice   column-label "Cod. Servico"
            /*produsrv.procvcom column-label "Preco!Custo" format ">>,>>9.99"
            */    with frame frame-a 10 down row 5  color white/red
            width 80 no-validate.

    recatu1 = recid(produsrv).
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
        find next produsrv where true.
        if not available produsrv
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
 
        display produsrv.procod
                produsrv.pronom
                produsrv.proindice with frame frame-a no-validate.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.
    repeat with frame frame-a:
        find produsrv where recid(produsrv) = recatu1.
        choose field produsrv.pronom
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
                find next produsrv where true no-error.
                if not avail produsrv
                then leave.
                recatu1 = recid(produsrv).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev produsrv where true no-error.
                if not avail produsrv
                then leave.
                recatu1 = recid(produsrv).
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
            find next produsrv where
                true no-error.
            if not avail produsrv
            then next.
            color display white/red
                produsrv.pronom.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev produsrv where
                true no-error.
            if not avail produsrv
            then next.
            color display white/red
                produsrv.pronom.
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
                find last bprodusrv no-lock no-error.
                if avail bprodusrv
                then vprocod = bprodusrv.procod + 1.
                else vprocod = 0.
                
                create produsrv.
                /*
                {di.v 1 "vprocod"}.
                */
                assign produsrv.procod    = vprocod
                       produsrv.proindice = string(vprocod)
                       produsrv.itecod    = vprocod.
                display produsrv.procod label "Codigo"   colon 15
                        with frame f-inc side-label centered.
                update produsrv.pronom label "Descricao" colon 15 
                            with frame f-inc.
                
                update vcodservi label "Cod. Servico" 
                        colon 15 with frame f-inc no-validate.
                find servicos where servicos.codigo = vcodservi no-lock no-error.
            if not avail servicos
            then do:
                bell.
                message color red/with
                "Codigo de servico padrao nao cadastrado."
                view-as alert-box.
                undo.
            end.
                produsrv.proindice = vcodservi.
                
                /*
                vestcusto = 0.
                update vestcusto label "Custo" colon 15 with frame f-inc.
                produsrv.procvcom = vestcusto.
                for each centro no-lock:
                        create estoqamx.
                        assign estoqamx.etbcod    = centro.etbcod
                               estoqamx.procod    = produsrv.procod
                               estoqamx.estcusto  = vestcusto
                               estoqamx.datexp    = today.
                end.
                */


                leave.
            end.
            if esqcom1[esqpos1] = "Consulta" or
               esqcom1[esqpos1] = "Exclusao" or
               esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera centered OVERLAY SIDE-LABELS.
                if esqcom1[esqpos1] = "Consulta"
                then do:
                    /*
                    for each estoqamx of produsrv:
                        find centro of estoqamx no-lock.
                        disp estoqamx.etbcod
                             centro.etbnom column-label "Centro"
                             estoqamx.estcusto  column-label "CUSTO"
                                with centered overlay row 5 9 down
                                        title "Armazenagem " + produsrv.pronom
                                                color white/cyan.
                    end.
                    */
                end.

            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do:
                display produsrv.procod format ">>>>>>>>9" with frame f-inc2.
                vcodservi = produsrv.proindice.
                update produsrv.pronom
                       vcodservi label "Cod. Servico" 
                        with frame f-inc2 1 column.
                find servicos where servicos.codigo = vcodservi 
                            no-lock no-error.
            if not avail servicos
            then do:
                bell.
                message color red/with
                "Codigo de servico padrao nao cadastrado."
                view-as alert-box.
                undo.
            end.
                produsrv.proindice = vcodservi.
                 /*
                for each estoqamx where estoqamx.procod = produsrv.procod:
                    estoqamx.estcusto = produsrv.procvcom.
                end.
                */
                    
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui row 4  centered OVERLAY SIDE-LABELS.
                message "Confirma Exclusao de" produsrv.pronom update sresp.
                if not sresp
                then leave.
                find next produsrv where true no-error.
                if not available produsrv
                then do:
                    find produsrv where recid(produsrv) = recatu1.
                    find prev produsrv where true no-error.
                end.
                recatu2 = if available produsrv
                          then recid(produsrv)
                          else ?.
                find produsrv where recid(produsrv) = recatu1.
                /*
                for each estoqamx where estoqamx.procod = produsrv.procod:
                    delete estoqamx.
                end.
                */
                delete produsrv.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered
                    on endkey undo, next bl-princ:
                prompt-for produsrv.procod format ">>>>>>>>9" with no-validate.
                find produsrv using produsrv.procod.
                if not avail produsrv
                then do:
                    message "produsrvto Invalido".
                    undo.
                end.
                recatu1 = recid(produsrv).
                leave.
            end.
          end.
       end. 
       if keyfunction(lastkey) = "end-error"
       then view frame frame-a.
       
       display produsrv.procod
               produsrv.pronom
               produsrv.proindice with frame frame-a no-validate.
       if esqregua
       then display esqcom1[esqpos1] with frame f-com1.
       else display esqcom2[esqpos2] with frame f-com2.
       recatu1 = recid(produsrv).
   end.
end.
