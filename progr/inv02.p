/*
*
*    Esqueletao de Programacao
*
*/
{admcab.i}

def var vestacao like produ.etccod.

def new shared temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.
def buffer scalse for clase.

def var vclacod like clase.clacod.
def var vcla-cod like clase.clacod.


def var vcatcod         like categoria.catcod.
def var vdec            as int.
def var vacr            as int.
def var vqtd            as int.
def var vtotest         as int.
def var vtotqtd         as int.
def var vtotacr         as int.
def var vtotdec         as int.
def var vvaldec         like plani.platot format "zzz,zzz,zz9.99".
def var vvalacr         like plani.platot format "zzz,zzz,zz9.99".
def var vdif            as char.
def var vest            like estoq.estatual.
def var vetbcod         like estab.etbcod.
def var vdata           like plani.pladat.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 5
            initial ["Inclusao","Alteracao","Exclusao","Procura","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].


def buffer bcoletor     for coletor.
def var vprocod         like coletor.procod.


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
    
def new shared temp-table tt-coletor like coletor.

repeat:

    vtotqtd = 0.
    vtotest = 0.

    update vetbcod label "Filial"
           vdata   label "Data Confronto" 
           vcatcod label "Departamento"
                with frame f1 side-label width 80.

    update vestacao at 1 label "Estacao" with frame f1 .
    if vestacao <> 0
    then do:
            find first estac where estac.etccod = vestacao no-lock no-error.
            if not avail estac
            then do:
                message "Estacao Invalida" view-as alert-box.
                undo, retry.
            end.
            else disp estac.etcnom no-label with frame f1.
    end.
    else disp "Geral" @ estac.etcnom with frame f1.

    update vcla-cod label "Classe" with frame f1.
    vclacod = vcla-cod.
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
        find first bclase where bclase.clasup = vclacod no-lock no-error. 
        if avail bclase 
        then do:
            message "Montando Tabela Temporaria de Classes...".
            pause 2 no-message.
            for each tt-clase.
                delete tt-clase.
            end.    
            run cria-tt-clase. 
            hide message no-pause.
        end. 
        else do:
            create tt-clase.
            assign tt-clase.clacod = clase.clacod
                   tt-clase.clanom = clase.clanom.
        end.

    end.
    else disp "Todas" @ clase.clanom with frame f1.
 
    for each tt-coletor: delete tt-coletor. end.
    
    for each coletor where coletor.etbcod  = vetbcod and
                           coletor.coldat  = vdata   and
                           coletor.catcod  = vcatcod no-lock.
        find produ where produ.procod = coletor.procod no-lock.
        
        if vestacao > 0 and
           produ.etccod <> vestacao
            then next.
               
        if vclacod > 0 
        then do:
            find first tt-clase where
                       tt-clase.clacod = produ.clacod
                       no-error.
            if not avail tt-clase
            then next.                        
        end.
        
        if coletor.estatual <> 0
        then do:
            vtotqtd = vtotqtd + coletor.colqtd.
            vtotest = vtotest + coletor.estatual.
            vtotacr = vtotacr + coletor.colacr.
            vtotdec = vtotdec + coletor.coldec.
        end.
        
        if coletor.estcusto > 0 and coletor.estatual <> 0
        then assign
                vvalacr = vvalacr + (coletor.colacr * coletor.estcusto)
                vvaldec = vvaldec + (coletor.coldec * coletor.estcusto).
        if coletor.estatual <> 0
        then do:
        create tt-coletor.
        buffer-copy coletor to tt-coletor.
        if tt-coletor.pronom = ""
        then tt-coletor.pronom = produ.pronom.
        end.
    end.
    
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-coletor use-index coletor3 
                           where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0   or
                                  tt-coletor.colqtd <> 0) no-error.
    else
        find tt-coletor where recid(tt-coletor) = recatu1.
    vinicio = yes.
    if not available tt-coletor
    then do:
        message "Nenhum coletor para esta filial".
        pause .
        undo, retry.
    end.
    clear frame frame-a all no-pause.
    
    find produ where produ.procod = tt-coletor.procod no-lock.
    


    if tt-coletor.estatual > tt-coletor.colqtd
    then vdif = "Falta " + string(tt-coletor.coldec).
    else if tt-coletor.estatual < tt-coletor.colqtd
         then vdif = "Sobra " + string(tt-coletor.colacr).
         else vdif = "".
    
    
    
    pause 0.
    display "TOTAIS...."
            vtotest no-label  to 42 format "-zzzzzz9"
            vtotqtd no-label  to 51 /*49*/ format "zzzzzzz9"
            vtotacr no-label  to 60 /*56*/ format "zzzzzz9"
            vtotdec no-label  to 68 /*63*/ format "zzzzzz9"
                with frame f-tot 
                    side-label color 
                        message row 21 no-box width 74 centered.
   
    display vvalacr label "Val.Acrescimo" at 10
            vvaldec label "Val.Decrescimo" at 45
                    with frame f-val side-label row 22 no-box .
                          
     
    display tt-coletor.procod column-label "Codigo"
            produ.pronom format "x(30)"
            tt-coletor.estatual column-label "Qtd." format "->>>>9"
            tt-coletor.colqtd column-label "Dig." format "->>>>9"
            tt-coletor.colacr format ">>>>>9"
                        when tt-coletor.colacr > 0 column-label "Acr."
            tt-coletor.coldec format ">>>>>9"
                        when tt-coletor.coldec > 0 column-label "Dec."
            vdif column-label "Dif" format "x(11)"           
                with frame frame-a 13 down centered row 4.

    
    
    recatu1 = recid(tt-coletor).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-coletor use-index coletor3 
              where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0    or
                                  tt-coletor.colqtd <> 0) no-error.
        if not available tt-coletor
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down
            with frame frame-a.
        find produ where produ.procod = tt-coletor.procod no-lock.
        
        if tt-coletor.estatual > tt-coletor.colqtd
        then vdif = "Falta " + string(tt-coletor.coldec).
        else if tt-coletor.estatual < tt-coletor.colqtd
             then vdif = "Sobra " + string(tt-coletor.colacr).
             else vdif = "".
    
        
        display vtotest 
                vtotqtd 
                vtotacr
                vtotdec with frame f-tot. 
     
   
        display vvalacr 
                vvaldec with frame f-val.
             
        display tt-coletor.procod
                produ.pronom 
                tt-coletor.estatual  
                tt-coletor.colqtd 
                tt-coletor.colacr when tt-coletor.colacr > 0  
                tt-coletor.coldec when tt-coletor.coldec > 0
                vdif
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find tt-coletor where recid(tt-coletor) = recatu1.

        choose field tt-coletor.procod
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
                find next tt-coletor use-index coletor3
                      where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0    or
                                  tt-coletor.colqtd   <> 0) no-error.
                
                if not avail tt-coletor
                then leave.
                recatu1 = recid(tt-coletor).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-coletor use-index coletor3 
                      where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0    or
                                  tt-coletor.colqtd   <> 0) no-error.
                if not avail tt-coletor
                then leave.
                recatu1 = recid(tt-coletor).
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
            find next tt-coletor use-index coletor3
                  where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0    or
                                  tt-coletor.colqtd   <> 0) no-error.
            if not avail tt-coletor
            then next.
            color display normal
                tt-coletor.procod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-coletor use-index coletor3
                  where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                (tt-coletor.estatual <> 0    or
                                 tt-coletor.colqtd <> 0) no-error.
            if not avail tt-coletor
            then next.
            color display normal
                tt-coletor.procod.
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
                create tt-coletor.
                update tt-coletor.pronom
                       tt-coletor.procod.
                recatu1 = recid(tt-coletor).
                create coletor.
                buffer-copy tt-coletor to coletor.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 1 column centered.
            
                find coletor of tt-coletor.
                
                vqtd = tt-coletor.colqtd.
                vacr = tt-coletor.colacr.
                vdec = tt-coletor.coldec.
                
                update tt-coletor.colqtd label "Digitado" format "->>>>>9"
                     with frame f-altera no-validate.
                
                if tt-coletor.estatual > tt-coletor.colqtd
                then tt-coletor.coldec = tt-coletor.estatual - tt-coletor.colqtd.

                if tt-coletor.estatual < tt-coletor.colqtd
                then tt-coletor.colacr = tt-coletor.colqtd - tt-coletor.estatual.
                
                if tt-coletor.estatual = tt-coletor.colqtd
                then assign tt-coletor.coldec = 0
                            tt-coletor.colacr = 0.
            

                vtotqtd = vtotqtd - vqtd + tt-coletor.colqtd.
                vtotacr = vtotacr - vacr + tt-coletor.colacr.
                vtotdec = vtotdec - vdec + tt-coletor.coldec.
                if tt-coletor.estcusto > 0
                then assign
                vvalacr = vvalacr  - (vacr * tt-coletor.estcusto)
                                  + (tt-coletor.colacr * tt-coletor.estcusto)
                vvaldec = vvaldec - (vdec * tt-coletor.estcusto)
                                  + (tt-coletor.coldec * tt-coletor.estcusto).
                buffer-copy tt-coletor to coletor.
                  
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-procura overlay row 6 1 column centered.
                update vprocod label "Produto".
                find tt-coletor where tt-coletor.etbcod = vetbcod and
                                   tt-coletor.coldat = vdata   and
                                   tt-coletor.catcod = vcatcod and
                                   tt-coletor.procod = vprocod no-lock no-error.
                if not avail tt-coletor
                then do:
                    message "Produto nao encontrado".
                    pause.
                end.
                else recatu1 = recid(tt-coletor).
                disp tt-coletor with frame f-consulta no-validate.
            end.
            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                message "Confirma Exclusao de" produ.pronom update sresp.
                if not sresp
                then.
                else do:
                find next tt-coletor use-index coletor3
                           where tt-coletor.etbcod = vetbcod and
                                 tt-coletor.coldat = vdata   and
                                 tt-coletor.catcod = vcatcod and
                                 (tt-coletor.estatual <> 0    or
                                  tt-coletor.colqtd <> 0) no-error.
                if not available tt-coletor
                then do:
                    find tt-coletor where recid(tt-coletor) = recatu1.
                    find prev tt-coletor use-index coletor3
                              where tt-coletor.etbcod = vetbcod and
                                    tt-coletor.coldat = vdata   and
                                    tt-coletor.catcod = vcatcod and
                                    (tt-coletor.estatual <> 0   or
                                     tt-coletor.colqtd <> 0) no-error.
                end.
                recatu2 = if available tt-coletor
                          then recid(tt-coletor)
                          else ?.
                find tt-coletor where recid(tt-coletor) = recatu1.
                find coletor of tt-coletor.
                delete coletor.
                delete tt-coletor.
                recatu1 = recatu2.
                end.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do with frame f-Lista overlay row 6 1 column centered.
                message "Confirma Impressao" update sresp.
                if not sresp
                then leave.

                run inv04.p (input tt-coletor.etbcod,
                             input tt-coletor.coldat,
                             input tt-coletor.catcod
                             ).
                             
            end.
    
          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
          end.
          view frame frame-a .
          next bl-princ.
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.
        find produ where produ.procod = tt-coletor.procod no-lock.
        


        if tt-coletor.estatual > tt-coletor.colqtd 
        then vdif = "Falta " + string(tt-coletor.coldec). 
        else if tt-coletor.estatual < tt-coletor.colqtd
             then vdif = "Sobra " + string(tt-coletor.colacr).
             else vdif = "".
    

         
        display vtotest 
                vtotqtd 
                vtotacr
                vtotdec with frame f-tot. 
     
   
        display vvalacr 
                vvaldec with frame f-val.
         
        
        
        
        display tt-coletor.procod 
                produ.pronom  
                tt-coletor.estatual   
                tt-coletor.colqtd when tt-coletor.colqtd > 0 
                tt-coletor.colacr when tt-coletor.colacr > 0   
                tt-coletor.coldec when tt-coletor.coldec > 0  
                vdif 
                    with frame frame-a.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-coletor).
   end.
end.
end.

procedure cria-tt-clase.
 for each clase where clase.clasup = vclacod no-lock:
   find first bclase where bclase.clasup = clase.clacod no-lock no-error.
   if not avail bclase
   then do: 
     find tt-clase where tt-clase.clacod = clase.clacod no-error. 
     if not avail tt-clase 
     then do: 
       create tt-clase. 
       assign tt-clase.clacod = clase.clacod 
              tt-clase.clanom = clase.clanom.
     end.
   end.
   else do: 
     for each bclase where bclase.clasup = clase.clacod no-lock: 
         find first cclase where cclase.clasup = bclase.clacod no-lock no-error.
         if not avail cclase
         then do: 
           find tt-clase where tt-clase.clacod = bclase.clacod no-error. 
           if not avail tt-clase 
           then do: 
             create tt-clase. 
             assign tt-clase.clacod = bclase.clacod 
                    tt-clase.clanom = bclase.clanom.
           end.
         end.
         else do: 
           for each cclase where cclase.clasup = bclase.clacod no-lock: 
             find first dclase where dclase.clasup = cclase.clacod 
                                                     no-lock no-error. 
             if not avail dclase 
             then do: 
               find tt-clase where tt-clase.clacod = cclase.clacod no-error. 
               if not avail tt-clase 
               then do: 
                 create tt-clase. 
                 assign tt-clase.clacod = cclase.clacod 
                        tt-clase.clanom = cclase.clanom.
               end.                          
             end.
             else do: 
               for each dclase where dclase.clasup = cclase.clacod no-lock: 
                 find first eclase where eclase.clasup = dclase.clacod 
                                                         no-lock no-error. 
                 if not avail eclase 
                 then do: 
                   find tt-clase where tt-clase.clacod = dclase.clacod no-error.
                   if not avail tt-clase 
                   then do: 
                     create tt-clase. 
                     assign tt-clase.clacod = dclase.clacod 
                            tt-clase.clanom = dclase.clanom. 
                   end.       
                 end. 
                 else do:  
                   for each eclase where eclase.clasup = dclase.clacod no-lock:
                     find first fclase where fclase.clasup = eclase.clacod 
                                                             no-lock no-error.
                     if not avail fclase 
                     then do: 
                       find tt-clase where tt-clase.clacod = eclase.clacod
                                                             no-error.
                       if not avail tt-clase 
                       then do: 
                         create tt-clase. 
                         assign tt-clase.clacod = eclase.clacod 
                                tt-clase.clanom = eclase.clanom.
                       end.
                     end.
                     else do:
                     
                       for each fclase where fclase.clasup = eclase.clacod
                                    no-lock:
                         find first gclase where gclase.clasup = fclase.clacod 
                                                             no-lock no-error.
                         if not avail gclase 
                         then do: 
                           find tt-clase where tt-clase.clacod = fclase.clacod
                                                                 no-error.
                           if not avail tt-clase 
                           then do: 
                             create tt-clase. 
                             assign tt-clase.clacod = fclase.clacod 
                                    tt-clase.clanom = fclase.clanom.
                           end.
                         end.
                         else do:
                             find tt-clase where 
                                   tt-clase.clacod = gclase.clacod 
                                                        no-error.
                             if not avail tt-clase
                             then do:
                             
                                 create tt-clase. 
                                 assign tt-clase.clacod = gclase.clacod 
                                        tt-clase.clanom = gclase.clanom.
                                        
                             end.  
                         end.
                       end.
                     end.
                   end.
                 end.
               end.
             end.
           end.                                  
         end.
     end.
   end.
 end.
end procedure.


