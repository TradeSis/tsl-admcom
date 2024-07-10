{admcab.i}
             
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer eclase for clase.
def buffer fclase for clase.
def buffer gclase for clase.

def var vetccod  as char format "x(03)".
def var vforcod  like forne.forcod.
def var vmes2    as int format ">9".
def var vano2    as int format "9999".
def var vimp     as log format "Sim/Nao" initial no.
def var vmes     as int format ">9".
def var vetbcod  like estab.etbcod.
def var vclacod  like clase.clacod.
def var vcarcod  like caract.carcod.
def var vsubcod  like subcaract.subcod.
def var vdti     like pedid.peddat.
def var vdtf     like pedid.peddat.
def var varquivo as char.

def temp-table wped
    field pednum like pedid.pednum
    field forcod like pedid.clfcod
    field wvalor like pedid.pedtot format "->>,>>>,>>9.99"
    field wabe   like pedid.pedtot format "->>,>>>,>>9.99".
    def var wacumabe as dec.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var vacum like pedid.pedtot.

def temp-table wcla
    field clacod like produ.clacod
    field clasup like clase.clasup
    field pednum like pedid.pednum
    field forcod like pedid.clfcod
    field wvalor like pedid.pedtot format "->>,>>>,>>9.99"
    field wabe   like pedid.pedtot format "->>,>>>,>>9.99".
    def var wacumabe1 as dec.

def var vacum1 like pedid.pedtot.
def var vano as int format "9999".

def var vcla-cod like clase.clacod.

repeat:
    for each tt-clase.
        delete tt-clase.
    end.

    for each wped.
        delete wped.
    end.
    
    assign vacum   = 0
           vforcod = 0.
          wacumabe = 0.

    for each wcla.
        delete wcla.
    end.
    
    vacum1 = 0.
 wacumabe1 = 0. 
    view frame f1.

    update vetbcod colon 16 with frame f1 side-label width 80 color white/cyan.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    
    do on error undo:
    
        update vforcod colon 16 with frame f1.
        if vforcod <> 0
        then do:
            find forne where forne.forcod = vforcod no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor nao Cadastrado.".
                undo.
            end.
            else disp forne.fornom no-label with frame f1.
        end.
        else disp "GERAL" @ forne.fornom with frame f1.
    end.
     
    
    
    update vcla-cod colon 16 with frame f1.
    vclacod = vcla-cod.
/***    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock.
        display clase.clanom no-label with frame f1.
    end.
    else display "GERAL" @ clase.clanom with frame f1.***/
    
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom no-label with frame f1.
    end.
    else disp "Todas" @ clase.clanom with frame f1.
    
    
    find first clase where clase.clasup = vclacod no-lock no-error.  
    if avail clase  
    then do: 
        run cria-tt-clase.  
        hide message no-pause.
    end.  
    else do: 
        find clase where clase.clacod = vclacod no-lock no-error. 
        if not avail clase 
        then do: 
            message "Classe nao Cadastrada". 
            undo.
        end.

        create tt-clase. 
        assign tt-clase.clacod = clase.clacod
               tt-clase.clanom = clase.clanom.

    end.
    
    do on error undo:
                                           
        update vetccod colon 16 label "Estacao" with frame f1.
        if vetccod = "" then vetccod = "G".
        if vetccod <> "G"
        then do:
            find estac where estac.etccod = int(vetccod) no-lock no-error.
            if not avail estac
            then do:
                message "Estacao nao Cadastrado.".
                undo.
            end.
            else disp estac.etcnom no-label with frame f1.
        end.
        else disp vetccod
                  "GERAL" @ estac.etcnom with frame f1.
    end.
    
    
    do on error undo:
        update vcarcod colon 16 with frame f1.
        if vcarcod <> 0
        then do:
            find caract where caract.carcod = vcarcod no-lock no-error.
            if not avail caract
            then do:
                message "Caracteristica nao Cadastrado.".
                undo.
            end.
            else disp caract.cardes no-label with frame f1.
        end.
        else disp "GERAL" @ caract.cardes with frame f1.
    end.
    
    do on error undo:
        update vsubcod label "Sub-Caract" colon 16 with frame f1.
        if vsubcod <> 0
        then do:
            find subcaract where 
                    subcaract.carcod = caract.carcod and
                    subcaract.subcar = vsubcod no-lock no-error.
            if not avail subcaract
            then do:
                message "Sub-Caracteristica nao Cadastrado.".
                undo.
            end.
            else disp subcaract.subdes no-label with frame f1.
            /**
            if vcarcod <> 0 
            then if vcarcod <> subcaract.carcod 
            then do: 
                message "Sub-caracteristica Invalida". 
                pause. 
                undo, retry.
            end.
             **/           
        end.
        else disp "GERAL" @ subcaract.subdes with frame f1.
    end.
    
    update vdti colon 16 label "Data Inicial"
           vdtf label "Data Final"
           vimp label "Deseja Imprimir ?" /* Solic 20797 - 25/04/08 */
           with frame f1.

           
    /*********    
    vano = year(today).
    vmes = month(today).
    vano2 = year(today).
    vmes2 = month(today).

    update vmes label "Mes Inicial" colon 16 format "99"
           "/"
           vano no-label   with frame f1.

    vdti = date(vmes,1,vano).
    
    update vmes2 label "Mes Final" /*colon 16*/ format "99"
           "/"
           vano2 no-label   with frame f1.
    

    if vmes2 = 12
    then vdtf = date(1,1,vano2 + 1) - 1.
    else vdtf = date((vmes2 + 1),1,vano2) - 1.
    ********/

    if vclacod <> 0
    then do:
        for each pedid where pedid.pedtdc = 1            and
                             pedid.etbcod = estab.etbcod and
                             pedid.peddti >= vdti         and
                             pedid.peddti <= vdtf         no-lock:
        
            for each liped of pedid no-lock.

                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
        
                if vetccod <> "G"
                then if produ.etccod <> int(vetccod)
                     then next.
                     
                if vforcod <> 0
                then if produ.fabcod <> vforcod
                     then next.
               

                if vcarcod = 0 and 
                   vsubcod = 0
                then.
                else do:
                    if vsubcod <> 0
                    then do:
                        find procaract where 
                             procaract.procod = produ.procod and
                             procaract.subcod = vsubcod      no-lock no-error.
                        if not avail procaract
                        then next.
                    end.   
                    else do:
                        find caract where caract.carcod = vcarcod no-lock.
                        for each subcaract where
                                 subcaract.carcod = caract.carcod no-lock:
                             find procaract where 
                                  procaract.procod = produ.procod and
                                  procaract.subcod = subcaract.subcod 
                                    no-lock no-error.
                             if not avail procaract
                             then next.
                        end.
                    end.
                end.
                
                     

                find first tt-clase where tt-clase.clacod = produ.clacod
                                no-lock no-error.
                if not avail tt-clase
                then next.
                
                find first wped where wped.pednum = liped.pednum no-error.
                if not avail wped
                then do:
                    create wped.
                    assign wped.pednum = liped.pednum
                           wped.forcod = pedid.clfcod.
                end.
                
                wped.wvalor = wped.wvalor + (liped.lipqtd * liped.lippreco) -
                (liped.lipqtd * liped.lippreco * (pedid.nfdes / 100)).
                 wped.wabe  = wped.wabe +
                    ((liped.lipqtd - liped.lipent) * liped.lippreco) -
                    ((liped.lipqtd - liped.lipent) * liped.lippreco *                                       (pedid.nfdes / 100)).
            end.
        end.  
        
        if vimp = yes    /* Solic 20797 - 25/04/08 */
        then do.
            if opsys = "UNIX"
            then varquivo = "../relat/geral" + string(time).
            else varquivo = "..\relat\geral" + string(time).

            {mdad_l.i
                &Saida     = "value(varquivo)"
                &Page-Size = "0"
                &Cond-Var  = "180"
                &Page-Line = "66"
                &Nom-Rel   = ""GERAL""
                &Nom-Sis   = """SISTEMA DE ESTOQUE"""
                &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
                &Width     = "180"
                &Form      = "frame f-cabcab"}

        end.            
        else do.
        /*** solic 19710 ***/
        for each wped:     
            assign
                wacumabe = wacumabe + wabe.
                vacum = vacum + wped.wvalor.                                                find forne where forne.forcod = wped.forcod no-lock no-error. 
                    end.                                                                  
             display "VALOR TOTAL" at 33 
                vacum  format ">>>,>>>,>>9.99"
                wacumabe at 60 format "->>,>>>,>>9.99"       
                  with frame f4 width 80 no-box no-label
                       row 21 color message. 
                               
        end.

        /*** solic 19710 ***/
        
        for each wped:
            vacum = vacum + wped.wvalor.
            wacumabe = wacumabe + wped.wabe.
            find forne where forne.forcod = wped.forcod no-lock no-error.
            
            display wped.pednum  column-label "Pedido"
                    forne.fornom when avail forne
                    wped.wvalor(total) column-label "Valor"
                    wped.wabe(total)   column-label "Em Aberto"
                                with frame f2 
                                            5 down width 80 row 12
                                            .
        end. 
        if vimp = yes    /* Solic 20797 - 25/04/08 */
        then do.
            output close.
            if opsys = "UNIX"
            then run visurel.p (input varquivo, input "").
            else do:
                {mrod.i}.
            end.
        end.
    end.
    else do:
        for each pedid where pedid.pedtdc = 1            and
                             pedid.etbcod = estab.etbcod and
                             pedid.peddti >= vdti         and
                             pedid.peddtf <= vdtf         no-lock:
            for each liped of pedid no-lock.
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
                find clase where clase.clacod = produ.clacod no-lock no-error.
                if not avail clase
                then next.
                
                if vetccod <> "G"
                then if produ.etccod <> int(vetccod)
                     then next.
                     
                if vforcod <> 0
                then if produ.fabcod <> vforcod
                     then next.
                                if vcarcod = 0 and 
                   vsubcod = 0
                then.
                else do:
                    if vsubcod <> 0
                    then do:
                        find procaract where 
                             procaract.procod = produ.procod and
                             procaract.subcod = vsubcod      no-lock no-error.
                        if not avail procaract
                        then next.
                    end.   
                    else do:
                        find caract where caract.carcod = vcarcod no-lock.
                        for each subcaract where
                                 subcaract.carcod = caract.carcod no-lock:
                             find procaract where 
                                  procaract.procod = produ.procod and
                                  procaract.subcod = subcaract.subcod 
                                    no-lock no-error.
                             if not avail procaract
                             then next.
                        end.
                    end.
                end.
                
                
                find first wcla where wcla.clacod = clase.clacod and
                                      wcla.clasup = clase.clasup and
                                      wcla.forcod = pedid.clfcod and
                                      wcla.pednum = liped.pednum no-error.
                if not avail wcla
                then do:
                    create wcla.
                    assign wcla.clacod = clase.clacod
                           wcla.clasup = clase.clasup
                           wcla.pednum = liped.pednum
                           wcla.forcod = pedid.clfcod.
                end.
                wcla.wvalor = wcla.wvalor + (liped.lipqtd * liped.lippreco)
                  - (liped.lipqtd * liped.lippreco * (pedid.nfdes / 100)).
                wcla.wabe  = 
                wcla.wabe + ((liped.lipqtd - liped.lipent) * liped.lippreco) - 
                            ((liped.lipqtd - liped.lipent) * liped.lippreco *
                             (pedid.nfdes / 100)).
            end.
        end. 
        if vimp = yes /* Solic 20797 - 25/04/08 */ 
        then do.
            if opsys = "UNIX"
            then varquivo = "../relat/geral" + string(time).
            else varquivo = "..\relat\geral" + string(time).

            {mdad_l.i
              &Saida     = "value(varquivo)"
             &Page-Size = "0"
             &Cond-Var  = "180"
             &Page-Line = "66"
             &Nom-Rel   = ""GERAL""
             &Nom-Sis   = """SISTEMA DE ESTOQUE"""
             &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
            &Width     = "180"
            &Form      = "frame f-cabcab"}
        end.
             
        else do.
        /*** solic 19710 ***/
        for each wcla:     
~               assign
                wacumabe1 = wacumabe1 + wcla.wabe.
                vacum = vacum + wcla.wvalor.                                            end.                                                                  
         display "VALOR TOTAL" at 37 
           vacum  format ">>>,>>>,>>9.99"
           wacumabe at 63 format "->>,>>>,>>9.99"       
                  with frame f6 width 80 no-box no-label
                       row 21 color message. 
        end.
            /*** solic 19710 ***/        
                                                  
        for each wcla break by wcla.clasup
                            by wcla.clacod
                            by wcla.pednum:
            if first-of(wcla.clacod)
            then do:
                find clase where clase.clacod = wcla.clacod no-lock.
                display clase.clacod column-label "Cod" format ">>>>>>>>9"
                        clase.clanom format "x(13)" with frame f3.
            end.
            vacum1 = vacum1 + wcla.wvalor.
            find forne where forne.forcod = wcla.forcod no-lock no-error.

            display wcla.pednum  column-label "Pedido" 
                    forne.fornom when avail forne format "x(20)"
                    wcla.wvalor(total by wcla.clacod) column-label "Valor"
                    wcla.wabe(total by wcla.clacod)   column-label "Em Aberto"
                                with frame f3 
                                            5 down width 180 row 12.
        end. 
        if vimp = yes    /* Solic 20797 - 25/04/08 */
        then do.
            output close.
            if opsys = "UNIX"
            then run visurel.p (input varquivo, input "").
            else do:
                {mrod.i}.
            end.
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
                             find tt-clase where tt-clase.clacod =
                                            gclase.clacod no-error.
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
