{admcab.i}    
def var vdti as date.
def var vdtf as date.
def var vvalor like lancxa.vallan format "->,>>>,>>9.99".
def var varquivo as char.
def var vv as char format "x".
def var vtipo as l format "Entrada/Saida" initial no.
def var vtitnum like titulo.titnum.
def var vforcod like forne.forcod.
def var vnumlan as int.
def var vdata   like plani.pladat.
def var vhis    like lancxa.comhis.
def var vtabcod like lancxa.lancod.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var vtit            as char.
def temp-table tt-lan
    field reclan as recid
    field forcod like lancxa.forcod
    field vallan like lancxa.vallan
        index ind-1 forcod
                    vallan.

def var esqcom1         as char format "x(12)" extent 6
            initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura","Marca"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["Listagem","","","",""].

def buffer blancxa       for lancxa.
def var vlancod         like lancxa.lancod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels 
                    centered width 80.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels 
                        centered width 80.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.
repeat:
    hide frame frame-a no-pause.
    recatu1 = ?.

    update vdti label "Periodo de"
           vdtf label "Ate"
           vtipo label "Movimento"
                with frame fdata side-label width 80 centered.
    hide frame f-data no-pause.

    if vtipo = yes
    then assign vv = "D"
                vtit = "Entradas".
    else assign vv = "C"
                vtit = "Saidas".
                
    for each tt-lan:
        delete tt-lan.
    end.
    do vdata = vdti to vdtf:
    for each lancxa where lancxa.cxacod <> 0 and 
                          lancxa.datlan = vdata and 
                          lancxa.lantip = vv no-lock:
        create tt-lan.
        assign tt-lan.reclan = recid(lancxa)
               tt-lan.forcod = lancxa.forcod
               tt-lan.vallan = lancxa.vallan.
                          
    end.
    end.    
                    

def var extra-cxa as log format "Sim/Nao".
def var extra-des as char format "x(50)".

procedure reg-disp:
     display lancxa.livre2 no-label format "x(01)"
            tt-lan.vallan
            lancxa.forcod column-label "Forne"
            lancxa.lancod column-label "Debito" when avail tablan
            lancxa.cxacod column-label "Credito" when avail tablan
            lancxa.lanhis 
            lancxa.comhis column-label "Complemento" format "x(25)"
            lancxa.lantip 
            lancxa.etbcod
            with frame frame-a 12 down centered 
                        title "Data: " +  string(vdti,"99/99/9999") + 
                              " a " + string(vdtf,"99/99/9999") + 
                               " - " + vtit.

end. 
bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first tt-lan where true.
    else
        find tt-lan where recid(tt-lan) = recatu1.
    vinicio = yes.
    if not available tt-lan
    then do:
        message "Tabela de Lancamentos Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui1  overlay row 6 1 column centered.
                vtabcod = 0.
                vforcod = 0.
                vtitnum = "".
                find last blancxa no-lock no-error.
                if not avail blancxa
                then vnumlan = 1.
                else vnumlan = blancxa.numlan + 1.
                create lancxa.
                ASSIGN lancxa.cxacod = 13
                       lancxa.numlan = vnumlan
                       lancxa.datlan = today.
             
                update lancxa.lancod
                       lancxa.datlan 
                       lancxa.vallan format "-999,999,999.99"
                       lancxa.lanhis
                       lancxa.comhis.

                update lancxa.titnum  
                       lancxa.forcod.

                lancxa.lantip = vv.

                vinicio = no.
                create tt-lan.
                assign tt-lan.reclan = recid(lancxa)
                       tt-lan.forcod = lancxa.forcod 
                       tt-lan.vallan = lancxa.vallan.
                       
                
        end.
    end.
    clear frame frame-a all no-pause.
    
    find lancxa where recid(lancxa) = tt-lan.reclan no-error.
    
    find tablan where tablan.lancod = lancxa.lancod no-lock no-error.

    run reg-disp.

    recatu1 = recid(tt-lan).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next tt-lan where true no-error.
        if not available tt-lan
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then down with frame frame-a.
      
        
        find lancxa where recid(lancxa) = tt-lan.reclan no-error.
        find tablan where tablan.lancod = lancxa.lancod no-lock no-error.


        vhis = substring(lancxa.comhis,1,12).


        run reg-disp.

    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

    
        find first tt-lan where recid(tt-lan) = recatu1.

        choose field tt-lan.vallan
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
                find next tt-lan where true no-error.
                if not avail tt-lan
                then leave.
                recatu1 = recid(tt-lan).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-lan where true no-error.
                if not avail tt-lan
                then leave.
                recatu1 = recid(tt-lan).
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
            find next tt-lan where true no-error.
            if not avail tt-lan
            then next.
            color display normal
                tt-lan.vallan.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-lan where true no-error.
            if not avail tt-lan
            then next.
            color display normal
                tt-lan.vallan.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then do:
            /* slancod = lancxa.lancod. 
            frame-value = slancod. */
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
                
                vtitnum = "".
                vforcod = 0.
                find last blancxa no-lock no-error.
                if not avail blancxa
                then vnumlan = 1.
                else vnumlan = blancxa.numlan + 1.
                create lancxa.
                ASSIGN lancxa.cxacod = 13
                       lancxa.numlan = vnumlan
                       lancxa.datlan = today.
                
                update lancxa.lancod
                       lancxa.datlan 
                       lancxa.vallan format "->>>,>>>,>>9.99"
                       lancxa.lanhis
                       lancxa.comhis.
               
                update lancxa.titnum  
                       lancxa.forcod.

                lancxa.lantip = vv.
                
                create tt-lan. 
                assign tt-lan.reclan = recid(lancxa) 
                       tt-lan.forcod = lancxa.forcod 
                       tt-lan.vallan = lancxa.vallan.


            end.
            
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera overlay row 6 centered.

                find lancxa where recid(lancxa) = tt-lan.reclan no-error.
                
                find tablan where tablan.lancod = lancxa.lancod
                                no-lock no-error.

                extra-cxa = no.
                run possui-extra-caixa.
                if extra-cxa = no
                then extra-des = "          NAO possui extra-caixa" .
                else if extra-cxa = yes
                then extra-des = "          SIM possui extra-caixa" . 
                
                display extra-des no-label
                        skip(1)
                        lancxa.lancod at 6
                        tablan.codred  label "Codigo Sispro" when avail tablan
                        lancxa.cxacod at 8 label "Paga"
                        lancxa.datlan at 2
                        lancxa.vallan at 7
                        lancxa.lanhis at 3
                        lancxa.comhis at 1
                        lancxa.titnum at 3
                        lancxa.forcod at 2
                        lancxa.lantip at 8
                            with frame f-altera no-validate
                            side-label.
 
                
                update lancxa.lancod
                       lancxa.cxacod   label "Paga"  format ">>>>>9"
                       lancxa.datlan 
                       lancxa.vallan  format "->>>,>>>,>>9.99"
                       lancxa.lanhis
                       lancxa.comhis
                       lancxa.titnum
                       lancxa.forcod
                       lancxa.lantip
                       with frame f-altera no-validate side-label.
                
                assign tt-lan.forcod = lancxa.forcod 
                       tt-lan.vallan = lancxa.vallan.
       
                       
            end.

            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta overlay row 6 centered.
            
                find lancxa where recid(lancxa) = tt-lan.reclan no-error.
                find tablan where tablan.lancod = lancxa.lancod
                                no-lock no-error.
                        
                extra-cxa = no.
                run possui-extra-caixa.
                if extra-cxa = no
                then extra-des = "          NAO possui extra-caixa" .
                else if extra-cxa = yes
                then extra-des = "          SIM possui extra-caixa" .           
                
                display extra-des no-label
                        skip(1)
                        lancxa.lancod at 6
                        lancxa.lancod label "Codigo Sispro" when avail tablan
                        lancxa.cxacod at 8 label "Paga"
                        lancxa.datlan at 2
                        lancxa.vallan at 7
                        lancxa.lanhis at 3
                        lancxa.comhis at 1
                        lancxa.titnum at 3
                        lancxa.forcod at 2
                        lancxa.lantip at 8
                            with frame f-consulta no-validate
                            side-label.
            end.
            

            if esqcom1[esqpos1] = "Exclusao"
            then do with frame f-exclui overlay row 6 1 column centered.
                find lancxa where recid(lancxa) = tt-lan.reclan no-error.

                message "Confirma Exclusao de" lancxa.titnum update sresp.
                if not sresp
                then leave.
                find next tt-lan where true no-error.
                if not available tt-lan
                then do:
                    find tt-lan where recid(tt-lan) = recatu1.
                    find prev tt-lan where true no-error.
                end.
                recatu2 = if available tt-lan
                          then recid(tt-lan)
                          else ?.
                find first tt-lan where recid(tt-lan) = recatu1.
                find lancxa where recid(lancxa) = tt-lan.reclan no-error.

                delete lancxa.
                delete tt-lan.
                
                recatu1 = recatu2.
                leave.
            end. 
            
            if esqcom1[esqpos1] = "Procura"
            then do:
                view frame frame-a.
                pause 0.
                
                vforcod = 0.
                vvalor  = 0. 
                update vvalor  label "Valor"
                       vforcod label "Fornecedor"
                            with frame f-procura side-label centered
                                            row 20 overlay color message no-box.
                
                if vvalor > 0 and
                   vforcod > 0
                then do:   
                    find first tt-lan where tt-lan.forcod = vforcod and
                                        (if vvalor > 0 then
                                        tt-lan.vallan = vvalor 
                                        else true) no-error.
                    if not avail tt-lan
                    then do:
                        find first tt-lan where 
                            tt-lan.forcod = vforcod no-error.
                        if not avail tt-lan
                        then do:
                             message "Lancamento nao encontrado".
                            pause.
                        end.    
                        else do:
                            recatu1 = recid(tt-lan).
                        end.    
                    end.
                    else recatu1 = recid(tt-lan).
                end.
                if vvalor > 0 and
                   vforcod = 0
                then do:
                    for each tt-lan: delete tt-lan. end.
                
                    do vdata = vdti to vdtf:
                    for each lancxa where lancxa.cxacod <> 0 and 
                          lancxa.datlan = vdata and 
                          lancxa.lantip = vv no-lock:
                        
                        if lancxa.vallan = vvalor
                        then.
                        else next.
                        
                        create tt-lan.
                        assign tt-lan.reclan = recid(lancxa)
                               tt-lan.forcod = lancxa.forcod
                               tt-lan.vallan = lancxa.vallan.
                    end.
                    end.
                    recatu1 = ?. 

                    find first tt-lan no-error.
                    if not avail tt-lan
                    then do:
                        bell.
                        message color red/with
                        "Nenum regidtro encontrato para VALOR " 
                        string(vvalor,">>,>>>,>>9.99")
                        view-as alert-box.
                        
                        assign
                            vvalor = 0
                            vforcod = 0
                            .
                    end.
                    
                end.   
                if vvalor = 0 and vforcod > 0
                then do:
                    for each tt-lan: delete tt-lan. end.
                    do vdata = vdti to vdtf:
                    for each lancxa where lancxa.cxacod <> 0 and 
                          lancxa.datlan = vdata and 
                          lancxa.lantip = vv no-lock:
                        
                        if lancxa.forcod = vforcod
                        then.
                        else next.
                        
                        create tt-lan.
                        assign tt-lan.reclan = recid(lancxa)
                               tt-lan.forcod = lancxa.forcod
                               tt-lan.vallan = lancxa.vallan.
                    end.
                    end.

                    recatu1 = ?.
                    
                    find first tt-lan no-error.
                    if not avail tt-lan
                    then do:
                        bell.
                        message color red/with
                        "Nenum regidtro encontrato para FORNECEDOR " vforcod
                        view-as alert-box.
                        

                        assign
                            vvalor = 0
                            vforcod = 0
                            .
                    end.
 
                end.
                if vvalor = 0 and vforcod = 0
                then do:
                    for each tt-lan: delete tt-lan. end.
                    do vdata = vdti to vdtf:
                    for each lancxa where lancxa.cxacod <> 0 and 
                          lancxa.datlan = vdata and 
                          lancxa.lantip = vv no-lock:
                        
                        create tt-lan.
                        assign tt-lan.reclan = recid(lancxa)
                               tt-lan.forcod = lancxa.forcod
                               tt-lan.vallan = lancxa.vallan.
                    end.
                    end.
                    recatu1 = ?.
 
                end.

                hide frame f-procura no-pause.
                leave.        

            end.
            
            if esqcom1[esqpos1] = "Marca"
            then do:

                find lancxa where recid(lancxa) = tt-lan.reclan no-error.
                if lancxa.livre2 = "*"
                then lancxa.livre2 = "".
                else lancxa.livre2 = "*". 
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
            if esqcom2[esqpos2] = "Listagem"
            then do: 
                if opsys = "unix" 
                then varquivo = "/admcom/relat/lancxa" + string(time).
                else varquivo = "l:\relat\lancxa." + string(time).
                                

                {mdad.i &Saida     = "value(varquivo)" 
                        &Page-Size = "64" 
                        &Cond-Var  = "150" 
                        &Page-Line = "66" 
                        &Nom-Rel   = ""lancxa"" 
                        &Nom-Sis   = """SISTEMA DE CONTABILIDADE""" 
                        &Tit-Rel   = """LANCAMENTOS DE CAIXA - DIA: "" +
                                     string(vdti,""99/99/9999"") +
                                     "" ate "" + string(vdtf,""99/99/9999"")"
                        &Width     = "150"
                        &Form      = "frame f-cabcab"}
               
                do vdata = vdti to vdtf:
                for each lancxa where lancxa.cxacod = 13 and
                                      lancxa.datlan = vdata and
                                      lancxa.lantip = vv and
                                      lancxa.livre2 = ""  no-lock: 
                
                    find tablan where tablan.lancod = lancxa.lancod no-lock no-error.
                    find forne where forne.forcod   = lancxa.forcod no-lock no-error.



                    display lancxa.datlan
                            lancxa.vallan 
                            lancxa.lancod 
                            lancxa.cxacod 
                            lancxa.lanhis  
                            lancxa.comhis    
                            forne.fornom when avail forne 
                            lancxa.lancod  
                            lancxa.lantip 
                            lancxa.etbcod
                                with frame flista width 140 down.
                        
                end.
                end. 
                output close. 
                if opsys = "unix" 
                then do: 
                    run visurel.p (input varquivo, 
                                   input "").
                end. 
                else do: 
                    {mrod.i}  
                end.     
                
                recatu1 = recatu2.
                leave.

            
            end.
    
            /*
            message esqregua esqpos2 esqcom2[esqpos2].
            pause. */
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error" 
        then view frame frame-a.
        
        

        find lancxa where recid(lancxa) = tt-lan.reclan no-error.
        find tablan where tablan.lancod = lancxa.lancod no-lock no-error.

        run reg-disp.

        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-lan).
   end.
end.
end.

procedure possui-extra-caixa:

    find first blancxa where
                           blancxa.forcod = lancxa.forcod and
                           blancxa.titnum = lancxa.titnum and
                           blancxa.lansit = "X"
                           no-lock no-error.
    if not avail blancxa
    then extra-cxa = no .
    else extra-cxa = yes .
    
    if extra-cxa = no
    then do:            
    find first fiscal where 
               fiscal.emite = lancxa.forcod and
               fiscal.movtdc = 4 and
               fiscal.numero = int(lancxa.titnum)
               no-lock no-error.
    
    if avail fiscal
    then do:
        if fiscal.emite = 5027
        then.
        else
        if fiscal.opfcod <> 1102 and
           fiscal.opfcod <> 2102 and
           fiscal.opfcod <> 1101 and
           fiscal.opfcod <> 2101
        then.
        else  if fiscal.emite = 533 or
           fiscal.emite = 100071
        then.
        else extra-cxa = yes.
    end.
    else extra-cxa = no.        
    end.
end procedure.


