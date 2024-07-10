{admcab.i}


def input parameter vforcod like forne.forcod.
def input parameter vetbcod like estab.etbcod.
def var v-red like clafis.perred.
def var base_icms like plani.platot.
def var vnumant  like plani.numero.
def var vserant  as char format "x(02)".
def var vmovqtm  like movim.movqtm.
def var vmovpc   like movim.movpc.
def var per_icms like movim.movalicms.
def var per_ipi  like movim.movalipi.
def var desconto_item like movim.movdes.

def shared temp-table tt-planiref
    field numero like plani.numero
    field subst  like plani.platot.
    
def shared temp-table w-movim
    field redbas    as char format "x(01)"
    field movdat    like movim.movdat
    field numero    like plani.numero
    field marca     as char format "x(01)"
    field etbcod    like movim.etbcod
    field procod    like produ.procod
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999"
         index ind-1 procod.
 
     
form w-movim.redbas column-label "R" 
     w-movim.marca no-label 
     w-movim.numero column-label "Nota"
     w-movim.procod column-label "Codigo" format ">>>>>9"
     produ.pronom   column-label "Produto" format "x(17)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">>,>>9.99" column-label "Val.Unit."
     w-movim.valdes format ">>,>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
         with frame frame-a row 4 12 down overlay
                    centered color white/cyan width 80.




def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 4
            initial ["Marca","Inclusao","NF Fiscal","Reducao Base"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


assign
    esqcom1[1] = ""
    esqcom1[3] = ""
    esqcom1[4] = ""
    .
    
def buffer bw-movim       for w-movim.
def var vprocod         like w-movim.procod.


    form esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels centered.

    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

form with frame f-altera.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        find first w-movim where
            true no-error.
    else
        find w-movim where recid(w-movim) = recatu1.
    vinicio = yes.
    if not available w-movim
    then do:
        
        /**
        message "Nenhum produto encontrado".
        pause.
        return.
        **/
         do with frame f-altera overlay row 6 centered 1 column.
                vprocod = 0.
                update vprocod label "Codido".
                find produ where produ.procod = vprocod no-lock.
                display produ.pronom format "x(25)".
                update vmovqtm validate(vmovqtm > 0,"Quantidade invalida")
                               label "QTD" format ">>>>9".
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock.
                vmovpc = estoq.estcusto.                 
                update vmovpc validate( vmovpc > 0,
                                       "Custo invalido")
                              label "Val.Unit.".
                update desconto_item label "Desconto".
              
                base_icms = 0 /*(vmovpc - desconto_item) * vmovqtm*/.
                per_icms = 0.
                update per_icms /*validate(per_icms > 0,"Icms Invalido")*/  
                            label "Icms%" format ">9.99%"
                       base_icms label "Base Icms Item". 
                        
                update per_ipi label "IPI %" format ">9.99%".
                
                message "Confirma Produto" update sresp.
                if sresp
                then do:
                    create w-movim.
                    assign w-movim.procod = vprocod
                           w-movim.marca  = "*"
                           w-movim.numero = 0
                           w-movim.movdat = 01/01/2000
                           w-movim.movqtm = vmovqtm 
                           w-movim.movpc  = vmovpc  
                           w-movim.valdes = desconto_item 
                           w-movim.movdes = ((w-movim.valdes / w-movim.movpc) 
                                            * 100)
                           w-movim.movalicms = per_icms  
                           w-movim.valicms = base_icms * (per_icms / 100)
                           w-movim.movalipi  = per_ipi
                           w-movim.movipi = vmovpc * (per_ipi / 100).
 
                    recatu1 = recid(w-movim).
                    
                end.
                hide frame f-altera no-pause.
                next.       
            end.
    end.
    clear frame frame-a all no-pause.
    
    find produ where produ.procod = w-movim.procod no-lock.
            
    display w-movim.redbas
            w-movim.marca
            w-movim.numero
            w-movim.procod
            produ.pronom
            w-movim.movqtm 
            w-movim.movpc   
            w-movim.valdes  
            w-movim.movdes  
            w-movim.movalicms 
                with frame frame-a.

    recatu1 = recid(w-movim).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next w-movim where
                true.
        if not available w-movim
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
        find produ where produ.procod = w-movim.procod no-lock.
         
        display w-movim.redbas
                w-movim.marca
                w-movim.numero
                w-movim.procod
                produ.pronom
                w-movim.movqtm  
                w-movim.movpc    
                w-movim.valdes   
                w-movim.movdes   
                w-movim.movalicms  
                    with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find w-movim where recid(w-movim) = recatu1.
        find produ where produ.procod = w-movim.procod no-lock.


        run color-message.
        choose field w-movim.procod
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
                esqpos1 = if esqpos1 = 4
                          then 4
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
                find next w-movim where true no-error.
                if not avail w-movim
                then leave.
                recatu1 = recid(w-movim).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev w-movim where true no-error.
                if not avail w-movim
                then leave.
                recatu1 = recid(w-movim).
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
            find next w-movim where
                true no-error.
            if not avail w-movim
            then next.
            color display normal
                w-movim.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev w-movim where
                true no-error.
            if not avail w-movim
            then next.
            color display normal
                w-movim.procod.
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

            if esqcom1[esqpos1] = "Reducao Base"
            then do:

                if w-movim.redbas = ""
                then do:
                  
                    w-movim.redbas = "*". 
                    if vforcod = 100725
                    then
                    w-movim.valicms = ((w-movim.movqtm * 
                                       (w-movim.movpc - w-movim.valdes)) *
                                       (1 - (58.8230 / 100)) ) *
                                       (w-movim.movalicms / 100).
                    else
                    w-movim.valicms = ((w-movim.movqtm * 
                                       (w-movim.movpc - w-movim.valdes)) *
                                       (1 - (29.4117 / 100)) ) *
                                       (w-movim.movalicms / 100).
                                       

                end.    
                else do:
               
                    w-movim.redbas = "".
                    
                    w-movim.valicms = ((w-movim.movpc - w-movim.valdes) 
                                       * w-movim.movqtm)
                                       * (w-movim.movalicms / 100).

                end.
                                                     
                recatu1 = recid(w-movim).
                            
            end. 
            
            
            if esqcom1[esqpos1] = "Marca"
            then do:

                if w-movim.marca = ""
                then w-movim.marca = "*".
                else w-movim.marca = "".
                if w-movim.marca = "*"
                then do:
                    
                    
                    w-movim.valicms = w-movim.valicms / w-movim.movqtm.
                    w-movim.movipi  = w-movim.movipi / w-movim.movqtm.
                    
                
                    update w-movim.movqtm with frame frame-a.

                    w-movim.valicms = w-movim.valicms * w-movim.movqtm.
                    w-movim.movipi  = w-movim.movipi  * w-movim.movqtm.
                    
                    if w-movim.movdat >= 12/01/2005
                    then. 
                    else do:
            
                        update w-movim.movpc      
                               w-movim.valdes      
                               w-movim.movdes      
                               w-movim.movalicms     
                                    with frame frame-a.
                                    
                        
                        w-movim.valicms = ((w-movim.movpc - w-movim.valdes) 
                                           * w-movim.movqtm)
                                           * (w-movim.movalicms / 100).

                     
                    end.
                end.                       
                                                     
                recatu1 = recid(w-movim).
                            
            end. 
            if esqcom1[esqpos1] = "NF Fiscal"
            then do: 
                update vnumant 
                       vserant label "Serie" 
                            with frame f1 side-label centered row 10.
                       
                find plani where plani.emite  = vforcod      and
                                 plani.etbcod = vetbcod      and
                                 plani.movtdc = 4            and
                                 plani.serie  = vserant      and
                                 plani.numero = vnumant no-lock no-error.
                if not avail plani
                then do:
                    message "Nota Fiscal de Compra nao encontrada".
                    pause .
                    undo, retry.
                end.
                find first tt-planiref where tt-planiref.numero = plani.numero 
                                                            no-error.
                if not avail tt-planiref
                then do:
                    create tt-planiref. 
                    assign tt-planiref.numero = plani.numero
                           tt-planiref.subst  = plani.icmssubst.
                    for each movim where movim.etbcod = plani.etbcod and
                                         movim.placod = plani.placod and
                                         movim.movtdc = plani.movtdc and
                                         movim.movdat = plani.pladat no-lock:
                        /*                 
                        find first w-movim where 
                                   w-movim.etbcod = movim.etbcod and
                                   w-movim.procod = movim.procod no-error.
                        if not avail w-movim
                        then do:
                        */           
                            create w-movim.
                            assign w-movim.etbcod    = movim.etbcod
                                   w-movim.numero    = plani.numero
                                   w-movim.movdat    = movim.datexp 
                                   w-movim.procod    = movim.procod
                                   w-movim.movqtm    = movim.movqtm 
                                   w-movim.subtotal  = (movim.movpc * 
                                                        movim.movqtm) 
                                   w-movim.movpc     = movim.movpc 
                                   w-movim.movalicms = movim.movalicms  
                                   w-movim.valicms   = movim.movicms
                                   w-movim.movalipi  = movim.movalipi  
                                   w-movim.movipi    = movim.movipi
                                   w-movim.movdes    = movim.movpdes 
                                   w-movim.valdes    = movim.movdes.
                             recatu1 = recid(w-movim).
                        /* end. */
                    end.                  
                
                end.
                else do:
                    message "Nota ja selecionada".
                    pause.
                end.
                leave.                                
            end.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-altera overlay row 6 centered 1 column.
                vprocod = 0.
                update vprocod label "Codido".
                find produ where produ.procod = vprocod no-lock.
                display produ.pronom format "x(25)".
                update vmovqtm validate(vmovqtm > 0,"Quantidade invalida")
                               label "QTD" format ">>>>9".
                find estoq where estoq.etbcod = estab.etbcod and
                                 estoq.procod = produ.procod no-lock.
                vmovpc = estoq.estcusto.                 
                update vmovpc validate( vmovpc > 0,
                                       "Custo invalido")
                              label "Val.Unit.".
                update desconto_item label "Desconto".
              
                base_icms = (vmovpc - desconto_item) * vmovqtm.
                per_icms = 17.
                update per_icms /*validate(per_icms > 0,"Icms Invalido")*/  
                            label "Icms%" format ">9.99%"
                       base_icms label "Base Icms Item". 
                        
                update per_ipi label "IPI %" format ">9.99%".
                
                message "Confirma Produto" update sresp.
                if sresp
                then do:
                    create w-movim.
                    assign w-movim.procod = vprocod
                           w-movim.marca  = "*"
                           w-movim.numero = 0
                           w-movim.movdat = 01/01/2000
                           w-movim.movqtm = vmovqtm 
                           w-movim.movpc  = vmovpc  
                           w-movim.valdes = desconto_item 
                           w-movim.movdes = ((w-movim.valdes / w-movim.movpc) 
                                            * 100)
                           w-movim.movalicms = per_icms  
                           w-movim.valicms = base_icms * (per_icms / 100)
                           w-movim.movalipi  = per_ipi
                           w-movim.movipi = vmovpc * (per_ipi / 100).
 
                    recatu1 = recid(w-movim).
                    
                end.
                hide frame f-altera no-pause.
                leave.       
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.
                disp w-movim with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" w-movim.movqtm update sresp.
                if not sresp
                then leave.
                find next w-movim where true no-error.
                if not available w-movim
                then do:
                    find w-movim where recid(w-movim) = recatu1.
                    find prev w-movim where true no-error.
                end.
                recatu2 = if available w-movim
                          then recid(w-movim)
                          else ?.
                find w-movim where recid(w-movim) = recatu1.
                delete w-movim.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao de w-movimidades " update sresp.
                if not sresp
                then leave.
                recatu2 = recatu1.
                output to printer.
                for each w-movim:
                    display w-movim.
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
          view frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error" 
        then view frame frame-a.
        find produ where produ.procod = w-movim.procod no-lock. 
     
        display w-movim.redbas
                w-movim.marca
                w-movim.numero
                w-movim.procod
                produ.pronom
                w-movim.movqtm  
                w-movim.movpc    
                w-movim.valdes   
                w-movim.movdes   
                w-movim.movalicms  
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(w-movim).
   end.
end.


procedure color-message.
color display message
        w-movim.redbas
        w-movim.marca
        w-movim.numero
        w-movim.procod   
        produ.pronom
        w-movim.movqtm   
        w-movim.movpc     
        w-movim.valdes    
        w-movim.movdes    
        w-movim.movalicms   
            with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        w-movim.redbas
        w-movim.marca
        w-movim.numero
        w-movim.procod 
        produ.pronom
        w-movim.movqtm   
        w-movim.movpc     
        w-movim.valdes    
        w-movim.movdes    
        w-movim.movalicms   
            with frame frame-a.
end procedure.

