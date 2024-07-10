/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vetbnom like estab.etbnom.
def new shared temp-table wf-lista
    field procod like produ.procod
    field numero like plani.numero
    field vencod like plani.vencod
    field etbcod like plani.etbcod
    field qtd    as int
    field pre    as dec.



def var vprocod like produ.procod.
def workfile wf-produ
    field procod like produ.procod.



def var varq as char.

def var vtot like plani.platot.

def temp-table tt-divpre
    field rec as recid
    field vencod like plani.vencod
    field funnom like func.funnom
    field pronom like produ.pronom
    index ind-1 vencod
                pronom.
                
                
def var vcatcod like produ.catcod.    
def var vdif like divpre.preven.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(13)" extent 3
            initial ["Observacao","Consulta","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bdivpre       for divpre.
def var vetbcod         like divpre.etbcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

    vdti = today - 2.
    vdtf = today - 1.

         
repeat:    
    clear frame f-com1 no-pause.
    recatu1 = ?.
        
        
    for each wf-lista:
        delete wf-lista.
    end.
    

    
    for each tt-divpre:
        delete tt-divpre.
    end.
    
    
    for each wf-produ:
        delete wf-produ.
    end.

    if opsys = "UNIX"
    then do:
        input from /admcom/work/kitpos.txt. 
        repeat:
            import vprocod.
            create wf-produ.
            assign wf-produ.procod = vprocod.
        end.
        input close.    
    end.
    else do:
        input from l:\work\kitpos.txt. 
        repeat:
            import vprocod.
            create wf-produ.
            assign wf-produ.procod = vprocod.
        end.
        input close.
    end.    

    
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final"
           vetbcod label "Filial"    colon 15
                with frame fdata side-label width 80 row 3.
    
    
    if vetbcod = 0
    then do:
        display "GERAL" @ estab.etbnom with frame fdata.
        vetbnom = "GERAL".
    end.    
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        display estab.etbnom no-label with frame fdata.
        vetbnom = estab.etbnom.
    end.     

    vtot = 0.
    
    for each wf-produ:
        for each estab where if vetbcod = 0
                             then true 
                             else estab.etbcod = vetbcod no-lock,
            each divpre where divpre.etbcod = estab.etbcod and
                              divpre.divdat >= vdti        and
                              divpre.divdat <= vdtf        and
                              divpre.procod = wf-produ.procod no-lock.
                          
            find produ where produ.procod = divpre.procod no-lock no-error.
            if not avail produ
            then next.
        
            if divpre.preven > divpre.prefil
            then.
            else next.
        
            find first tt-divpre where tt-divpre.rec = recid(divpre) no-error.
            if not avail tt-divpre
            then do:
                create tt-divpre.
                assign tt-divpre.rec = recid(divpre).
            end.
            find first plani where plani.etbcod = estab.etbcod and
                              plani.placod = divpre.placod no-lock no-error.
            if avail plani
            then do:
                find func where func.etbcod = plani.etbcod and
                                func.funcod = plani.vencod no-lock no-error.
                if avail func
                then tt-divpre.funnom = func.funnom.
                                
                tt-divpre.vencod = plani.vencod.
            
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat and
                                     movim.procod = produ.procod no-lock:
                    find first wf-lista where 
                            wf-lista.etbcod = plani.etbcod and
                            wf-lista.numero = plani.numero and
                            wf-lista.procod = produ.procod and
                            wf-lista.vencod = plani.vencod no-error.
                    if not avail wf-lista
                    then do:
                        create wf-lista.
                        assign
                            wf-lista.etbcod = plani.etbcod
                            wf-lista.numero = plani.numero
                            wf-lista.procod = produ.procod
                            wf-lista.vencod = plani.vencod.
                    end.
                    assign wf-lista.qtd = wf-lista.qtd + movim.movqtm
                           wf-lista.pre = wf-lista.pre + movim.movpc.
                
                end.
            end.

            assign tt-divpre.pronom = produ.pronom.
               
            vtot = vtot + (divpre.preven - divpre.prefil).
    
        end.
    
    end.
            
bl-princ:
repeat:


    pause 0.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then find first tt-divpre where true no-error.
    else find tt-divpre where recid(tt-divpre) = recatu1.
    if not available tt-divpre
    then do:
        message "Nao existe divergencia para este dia".
        pause.
        undo, retry.
    end.
    
    clear frame frame-a all no-pause.
    
    find divpre where recid(divpre) = tt-divpre.rec no-error.
    find produ where produ.procod = divpre.procod no-lock.
    
    vdif = (divpre.preven - divpre.prefil). 

    
    display vtot label "Dif.Preco    " format "->,>>9.9"
                        with frame ftot  no-box row 19 centered 
                        color message  side-label width 65.      
     
    display divpre.divjus label "Justificativa" 
                        with frame f-jus no-box row 20 centered
                                    color message side-label.
    display divpre.divobs label "Observacao   " 
                        with frame f-obs no-box row 21 centered
                                    color message side-label.

       
    
    display
        tt-divpre.vencod  column-label "Ve" format ">9" 
        tt-divpre.funnom  format "x(10)" 
        divpre.procod column-label "Codigo"
        produ.pronom  format "x(22)"
        divpre.premat column-label "Preco!Certo"   format ">,>>9.9" 
        divpre.preven column-label "Preco!Vendido" format ">,>>9.9"
        vdif column-label "Difer.!Preco"  format "->,>>9.9"
        divpre.fincod column-label "Pl" format "99"
            with frame frame-a 10 down centered 
                title trim(vetbnom + " -  Dia: " + 
                           string(vdti,"99/99/9999") + " - " + 
                           string(vdtf,"99/99/9999")).
    
    recatu1 = recid(tt-divpre).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.

    repeat:
        find next tt-divpre where true no-error.
        if not available tt-divpre
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        find divpre where recid(divpre) = tt-divpre.rec no-error.
        find produ where produ.procod = divpre.procod no-lock no-error.

        
        vdif =  (divpre.preven - divpre.prefil). 
        
        display divpre.divjus label "Justificativa" with frame f-jus.
        display divpre.divobs with frame f-obs.
           
             
        display
            tt-divpre.vencod 
            tt-divpre.funnom 
            divpre.procod
            produ.pronom 
            divpre.premat
            divpre.preven
            vdif
            divpre.fincod
            with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-divpre where recid(tt-divpre) = recatu1.

        find divpre where recid(divpre) = tt-divpre.rec no-error.

        find first plani where plani.etbcod = estab.etbcod and
                               plani.placod = divpre.placod no-lock no-error.

        display divpre.divjus with frame f-jus.
        display divpre.divobs with frame f-obs.

        choose field tt-divpre.vencod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
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
                esqpos1 = if esqpos1 = 3
                          then 3
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
            find next tt-divpre where true no-error.
            if not avail tt-divpre
            then next.
            find divpre where recid(divpre) = tt-divpre.rec no-error.
 
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.placod = divpre.placod 
                                                no-lock no-error.
 
            color display normal
                tt-divpre.vencod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-divpre where true no-error.
            if not avail tt-divpre
            then next.
            find divpre where recid(divpre) = tt-divpre.rec no-error.
 
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.placod = divpre.placod 
                                                no-lock no-error.
            color display normal
                tt-divpre.vencod.
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

            if esqcom1[esqpos1] = "Observacao"
            then do with frame f-inclui overlay row 6 1 column centered.
                find divpre where recid(divpre) = tt-divpre.rec no-error.
                update divpre.divobs.
                recatu1 = recid(tt-divpre).
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
            
                run kitpos_l.p.
                
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 1 column centered.

                vdif =  (divpre.preven - divpre.prefil). 


                display divpre.divjus label "Justificativa" with frame f-jus.
                display plani.pladat
                        plani.numero format ">>>>>>9"
                        plani.serie 
                        plani.vencod 
                        divpre.procod 
                        produ.pronom  
                        divpre.premat
                        divpre.prefil 
                        divpre.preven  
                        vdif label "Diferenca"
                        divpre.fincod with frame f-consulta.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" divpre.procod update sresp.
                if not sresp
                then undo.
                find next tt-divpre where true no-error.
                if not available tt-divpre
                then do:
                    find tt-divpre where recid(tt-divpre) = recatu1.
                    find prev tt-divpre where true no-error.
                end.
                recatu2 = if available tt-divpre
                          then recid(tt-divpre)
                          else ?.
                find tt-divpre where recid(tt-divpre) = recatu1.
                find divpre where recid(divpre) = tt-divpre.rec no-error.
                if avail divpre
                then delete divpre.
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
        find divpre where recid(divpre) = tt-divpre.rec no-error.
        find produ where produ.procod = divpre.procod no-lock no-error.  
        
        vdif =  (divpre.preven - divpre.prefil). 

        display divpre.divjus label "Justificativa" with frame f-jus.
        display divpre.divobs with frame f-obs.
  
    
        display tt-divpre.vencod 
                tt-divpre.funnom 
                divpre.procod
                produ.pronom 
                divpre.premat
                divpre.preven 
                vdif
                divpre.fincod with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-divpre).
   end.
end.
end.
