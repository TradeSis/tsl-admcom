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
    field wvalor like pedid.pedtot
    field wabe   like pedid.pedtot format "->>>,>>9.99"
    field qtde   as int.
    
def var wacumabe as dec.

def temp-table tt-clase
    field clacod like clase.clacod
    field clanom like clase.clanom
    index iclase is primary unique clacod.

def var vacum like pedid.pedtot.

def temp-table wcla
    /*
    field clacod like produ.clacod
    field clasup like clase.clasup
    */
    field prvenda like estoq.estvenda
    field pednum like pedid.pednum
    field forcod like pedid.clfcod
    field wvalor like pedid.pedtot
    field wabe   like pedid.pedtot format "->>>,>>9.99"
    field qtde   as int.
    
def var wacumabe1 as dec format "->>>,>>9.99".
def var vacum1 like pedid.pedtot format "->>>,>>9.99".
def var vacumqtd as int.
def var vacprvenda like estoq.estvenda.

def var vprvenda like estoq.estvenda.

def var vano as int format "9999".

repeat:
    for each tt-clase.
        delete tt-clase.
    end.

    for each wped.
        delete wped.
    end.
    
    assign vacum   = 0
           vforcod = 0
           wacumabe = 0
           vacumqtd = 0.

    for each wcla.
        delete wcla.
    end.
    
    vacum1 = 0.
    wacumabe1 = 0. 
    
    view frame f1.
    
    do on error undo:
        update vetbcod colon 16
            with frame f1 side-label width 80 color white/cyan.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento nao cadastrado" view-as alert-box.
            undo.
        end.
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom format "x(15)" no-label with frame f1.
    end.
    
    do on error undo:
        update vforcod /*colon 16*/ with frame f1.
        if vforcod <> 0
        then do:
            find forne where forne.forcod = vforcod no-lock no-error.
            if not avail forne
            then do:
                message "Fornecedor nao Cadastrado.".
                undo.
            end.
            else disp forne.fornom format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ forne.fornom with frame f1.
    end.
    
     
    do on error undo. 
        def var vcla-cod like clase.clacod.
        update vcla-cod colon 16 with frame f1.
        vclacod = vcla-cod.
        if vclacod <> 0
        then do:
            find clase where clase.clacod = vclacod no-lock no-error.
            if not avail clase
            then do:
                message "Classe nao cadastrada".
                undo.
            end.
            else display clase.clanom format "x(15)" no-label with frame f1.
        end.
        else disp "Todas" @ clase.clanom with frame f1.
    end.
    
    hide message no-pause.
    message "Aguarde... Filtrando Classes.".
    find first clase where clase.clasup = vclacod no-lock no-error.  
    if avail clase  
    then do: 
        run cria-tt-clase.
        hide message no-pause.
    end.  
    else do: 
        run cria-tt-clase.  
        hide message no-pause.
/*
        find clase where clase.clacod = vclacod no-lock no-error. 
        if not avail clase 
        then do: 
            message "Classe nao Cadastrada". 
            undo.
        end.
        create tt-clase. 
        assign tt-clase.clacod = clase.clacod
               tt-clase.clanom = clase.clanom.
*/               
    end.
    hide message no-pause.
    
    do on error undo:
        update vetccod /*colon 16*/ label "Estacao" with frame f1.
        if vetccod = ""
        then do:
            vetccod = "G".
            disp vetccod with frame f1.
        end.
        if vetccod <> "G"  
        then do:
            find estac where estac.etccod = int(vetccod) no-lock no-error.
            if not avail estac
            then do:
                message "Estacao nao Cadastrado.".
                undo.
            end.
            else disp estac.etcnom format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ estac.etcnom with frame f1.
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
            else disp caract.cardes format "x(15)" no-label with frame f1.
        end.
        else disp "GERAL" @ caract.cardes with frame f1.
    end.

    scopias = ?.
    do on error undo:
        if avail caract
        then scopias = caract.carcod.
        if scopias <> ?
        then do:
            update vsubcod label "Sub-Caract" /*colon 16*/ with frame f1.
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
                else disp subcaract.subdes format "x(15)" no-label with frame f1.
            end.
            else disp "GERAL" @ subcaract.subdes with frame f1.
        end.
        else do:
            vsubcod = 0.
            disp vsubcod with frame f1.
        end.
    end.
    
    update vdti colon 16 label "Data Inicial"
           vdtf label "Data Final"
           vimp label "Deseja Imprimir ?" /* Solic 20797 - 25/04/08 */
           with frame f1.

 /********* Luciane */
    /*** 
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

                find first wped where wped.pednum = liped.pednum
                                  no-error.
                if not avail wped
                then do:
                    create wped.
                    assign wped.pednum = liped.pednum
                           wped.forcod = pedid.clfcod.
                end.

                find estoq where estoq.etbcod = estab.etbcod
                             and estoq.procod = produ.procod no-lock no-error.
                vprvenda = if avail estoq then estoq.estvenda else 0.
                
                wped.wvalor = wped.wvalor + (liped.lipqtd * /*liped.lippreco*/ vprvenda ).
                wped.wabe  = wped.wabe +
                    ((liped.lipqtd - liped.lipent) * vprvenda /*liped.lippreco*/ ).
                wped.qtde   = wped.qtde + liped.lipqtd.
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
                &Cond-Var  = "130"
                &Page-Line = "66"
                &Nom-Rel   = ""GERAL""
                &Nom-Sis   = """SISTEMA DE ESTOQUE"""
                &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
                &Width     = "130"
                &Form      = "frame f-cabcab"}

        end.            
        else do.
        /*** solic 19710 ***/
        for each wped:
            assign
                wacumabe = wacumabe + wabe
                vacum = vacum + wped.wvalor
                vacumqtd = vacumqtd + wped.qtde.                                                find forne where forne.forcod = wped.forcod no-lock no-error.  
        end.                                                                  
/*        display "VALOR TOTAL" at 33 
        vacum  
        wacumabe at 59
        vacumqtd
*/
        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe at 64
            with frame f4 width 80 no-box no-label
                       row 21 color message.                   
        end.
        /*** solic 19710 ***/
        
        for each wped by wped.forcod:
            vacum = vacum + wped.wvalor.
            wacumabe = wacumabe + wped.wabe.
            find forne where forne.forcod = wped.forcod no-lock no-error.
            
            display wped.pednum  column-label "Pedido"
                    forne.fornom when avail forne
                    wped.qtde(total) column-label "Qtde"
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
    ***/
        for each pedid where pedid.pedtdc = 1            and
                             pedid.etbcod = estab.etbcod and
                             pedid.peddti >= vdti         and
                             pedid.peddtf <= vdtf         no-lock:
            for each liped of pedid no-lock.
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.
                /***
                find clase where clase.clacod = produ.clacod no-lock no-error.
                if not avail clase
                then next.
                ***/
                find first tt-clase where tt-clase.clacod = produ.clacod
                                no-lock no-error.
                if not avail tt-clase
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
                
                find estoq where estoq.etbcod = estab.etbcod
                             and estoq.procod = produ.procod no-lock no-error.
                vprvenda = if avail estoq then estoq.estvenda else 0.
                
                find first wcla where wcla.prvenda = vprvenda and
                                      /*clacod = clase.clacod and
                                      wcla.clasup = clase.clasup and*/
                                      wcla.pednum = pedid.pednum and
                                      wcla.forcod = pedid.clfcod no-error.
                if not avail wcla
                then do:
                    create wcla.
                    assign /*wcla.clacod = clase.clacod
                           wcla.clasup = clase.clasup*/
                           wcla.prvenda = vprvenda
                           wcla.pednum = pedid.pednum
                           wcla.forcod = pedid.clfcod.
                end.
                wcla.wvalor = wcla.wvalor + (liped.lipqtd * vprvenda).
                wcla.wabe  = wcla.wabe + ((liped.lipqtd - liped.lipent)
                                 * vprvenda).
                wcla.qtde = wcla.qtde + liped.lipqtd.
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
             &Cond-Var  = "130"
             &Page-Line = "66"
             &Nom-Rel   = ""GERAL""
             &Nom-Sis   = """SISTEMA DE ESTOQUE"""
             &Tit-Rel   = """MOVIMENTACAO GERAL FILIAL PERIODO DE """
            &Width     = "130"
            &Form      = "frame f-cabcab"}
        end.
             
        else do.
        /*** solic 19710 ***/
        for each wcla:     
               assign
                vacprvenda = vacprvenda + wcla.prvenda
                wacumabe1 = wacumabe1 + wcla.wabe.
                vacum = vacum + wcla.wvalor.                                   
                vacumqtd = vacumqtd + wcla.qtde.
        end.                                                                  
        display "VALOR TOTAL    " at 17
        vacprvenda
        vacumqtd format ">>>>>9"
        vacum 
        wacumabe1 at 64     
                with frame f6 width 80 no-box no-label
                       row 22 color message. 
        end.
            /*** solic 19710 ***/        
                                                  
        for each wcla break by wcla.forcod
                            by wcla.prvenda:
            /***                                
            if first-of(wcla.clacod)
            then do:
                find clase where clase.clacod = wcla.clacod no-lock.
                display clase.clacod column-label "Cod" format ">>>9"
                        clase.clanom format "x(15)" with frame f3.
            end.
            ***/
            if first-of(wcla.forcod)
            then do:
                find forne where forne.forcod = wcla.forcod no-lock.
                disp forne.forcod column-label "Cod" format ">>>>>>9"
                     forne.fornom format "x(15)" with frame f3.
            end.

            vacum1 = vacum1 + wcla.wvalor.

            display wcla.pednum  column-label "Pedido" 
                    wcla.prvenda (total by wcla.prvenda) column-label "Pr.Venda"
                    wcla.qtde(total by wcla.prvenda)
                        column-label "Qtde" format ">>>>>9"
                    wcla.wvalor(total by wcla.prvenda) column-label "Valor"
                    wcla.wabe(total by wcla.prvenda)   column-label "Em Aberto"
                                with frame f3 
                                            9 down width 100 row 8.5.
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
    /***        
    end.
    ***/
    /*********/
end.

procedure cria-tt-clase.

 for each clase where (if vclacod <> 0 then clase.clacod = vclacod
                                       else true) no-lock:
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

