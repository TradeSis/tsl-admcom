{admcab.i}

def input parameter vforcod like forne.forcod.
def input parameter vetbcod like estab.etbcod.
def input parameter par-assist as log.

def var v-red like clafis.perred.
def var base_icms like plani.platot.
def var vnumant  like plani.numero.
def var vserant  as char format "x(02)".
def var vmovqtm  like movim.movqtm.
def var vmovpc   like movim.movpc.
def var per_icms like movim.movalicms.
def var per_ipi  like movim.movalipi.
def var desconto_item like movim.movdes.

def shared temp-table tt-for 
    field forcod like forne.forcod.
 
def shared temp-table tt-plani1
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
    field movalpis  as dec
    field movpis    as dec
    field movalcofins  as dec
    field movcofins    as dec
    field movcstpiscof as dec
    field movbpiscof   as dec
    field chave        as char
    field movcsticms   as char
    field movbicms     as dec
      index ind-1 procod.
 
form w-movim.redbas column-label "R" 
     w-movim.marca no-label 
     w-movim.numero column-label "Nota" format ">>>>>>>9"
     w-movim.procod column-label "Codigo" format ">>>>>9"
     produ.pronom   column-label "Produto" format "x(14)"
     w-movim.movqtm format ">>>>9" column-label "Qtd"
     w-movim.movpc  format ">>>>9.99" column-label "Val.Unit."
     w-movim.valdes format ">>>9.9999" column-label "Val.Desc"
     w-movim.movdes format ">9.9999" column-label "%Desc"
     w-movim.movalicms column-label "ICMS" format ">9.99"
     with frame frame-a row 10 8 down overlay
                    centered color white/cyan width 80.

def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqcom1         as char format "x(12)" extent 4
            initial ["Marca","Inclusao","NF Fiscal","Reducao Base"].

if par-assist
then assign
        esqcom1[3] = "".

def var vprocod         like w-movim.procod.

form esqcom1 with frame f-com1 row 9 no-box no-labels centered.

esqpos1  = 1.

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first w-movim where true no-error.
    else find w-movim where recid(w-movim) = recatu1.
    vinicio = yes.

    if not available w-movim
    then do:
        message "Nenhum produto encontrado".
        pause.
        return.
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
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        find next w-movim where true.
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

        if par-assist
        then assign
                esqcom1[2] = if produ.clacod = 128062101
                             then "Inclusao" else "".
        disp esqcom1 with frame f-com1.

        run color-message.
        choose field w-movim.procod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  PF4 F4 ESC return).
        run color-normal.
        
        if keyfunction(lastkey) = "cursor-right"
        then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 4 then 4 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
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
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next w-movim where true no-error.
            if not avail w-movim then next.
            color display normal w-movim.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev w-movim where true no-error.
            if not avail w-movim
            then next.
            color display normal w-movim.procod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Reducao Base"
            then do:
                
                if w-movim.redbas = ""
                then do:
                    w-movim.redbas = "*". 
                    if vforcod = 100725 or
                       vforcod = 110034
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
                    
                    w-movim.movipi  =
                        ((w-movim.movpc * w-movim.movqtm)
                                    * w-movim.MovAlIPI ) / 100.
                
                    update w-movim.movqtm
                           w-movim.movpc
                           w-movim.sittri format "999" column-label "CST"
                                with frame frame-a.

                    w-movim.valicms = w-movim.valicms * w-movim.movqtm.
                    
                    w-movim.movipi  =
                        ((w-movim.movpc * w-movim.movqtm)
                                    * w-movim.MovAlIPI ) / 100.
                    
                    if w-movim.movfre > 0
                    then
                    w-movim.movipi  = w-movim.movipi +
                        (((w-movim.movfre * w-movim.movqtm)
                                    * w-movim.MovAlIPI ) / 100).
                    
                    if w-movim.movdat >= 12/01/2005
                    then. 
                    else do:
                        update       
                               w-movim.valdes      
                               w-movim.movdes      
                               w-movim.movalicms     
                                    with frame frame-a.
                        
                        if vforcod = 111345
                        then w-movim.valicms = 
                                    ((w-movim.movpc - w-movim.valdes) 
                                           * w-movim.movqtm)
                                           * (12 / 100).
                        else
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
                       
                for each tt-for:
                find plani where plani.emite  = tt-for.forcod      and
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
                find first tt-plani1 where tt-plani1.numero = plani.numero 
                                                            no-error.
                if not avail tt-plani1
                then do:
                    create tt-plani1. 
                    assign tt-plani1.numero = plani.numero
                           tt-plani1.subst  = plani.icmssubst.
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
                                   w-movim.movbicms  = movim.movbicms
                                   .
                             recatu1 = recid(w-movim).
                        /* end. */
                    end.                  
                
                end.
                else do:
                    message "Nota ja selecionada".
                    pause.
                end.
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
                update per_icms validate(per_icms > 0,"Icms Invalido")  
                            label "Icms%" format ">9.99%"
                       base_icms label "Base Icms Item". 
                        
                update per_ipi label "IPI %" format ">9.99%".

                sresp = no.
                message "Confirma Produto?" update sresp.
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
                           w-movim.movbicms = base_icms / vmovqtm 
                           w-movim.valicms = 
                                (base_icms * (per_icms / 100)) / vmovqtm
                           w-movim.movalipi  = per_ipi
                           w-movim.movipi = 
                                        (vmovpc * vmovqtm) * (per_ipi / 100).
 
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
          view frame frame-a.

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
        display esqcom1[esqpos1] with frame f-com1.
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


