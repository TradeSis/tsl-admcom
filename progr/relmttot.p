{admcab.i}

def var varquivo as   char.
def var fila     as   char.

def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".

def var vmontcod like adm.montador.montcod.
def var vetbcod  like estab.etbcod.

def var vtipo    as log format "Sim/Nao".

def var vtotcli  as dec format ">>,>>>,>>9.99"       no-undo.
def var vtotloj  as dec format ">>,>>>,>>9.99"       no-undo.  

def var vtogcli  as dec format ">>,>>>,>>9.99"       no-undo.    
def var vtogloj  as dec format ">>,>>>,>>9.99"       no-undo. 
    
def temp-table tt-monmov
    field etbcod  like adm.monmov.etbcod 
    field moncod  like adm.monmov.moncod
    field monnom  like adm.montagem.monnom
    field mondat  like adm.monmov.mondat
    field monnot  like adm.monmov.monnot
    field monser  like adm.monmov.monser 
    field montcod like adm.monmov.montcod
    field montnom like adm.montador.montnom
    field movpc   like adm.monmov.movpc
    field procod  like adm.monmov.procod.

def temp-table tt-resumo            no-undo
    field etbcod  like adm.monmov.etbcod
    field totloj  as  inte format ">>,>>>,>>9.99"
    field totcli  as  inte format ">>,>>>,>>9.99"
    index ch-etbcod  is primary unique etbcod. 

def var v-valor like adm.monmov.movpc.

repeat:

    for each tt-monmov.
        delete tt-monmov.
    end.

    assign vetbcod  = 0
           vmontcod = 0 
           vdata1   = today
           vdata2   = today.

    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-dados.
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-dados.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.    
    end.       
    
    do on error undo:
        update skip
               vmontcod label "Montador......."
               help "Informe o codigo do montador zero para todos"
               with frame f-dados.
        if vmontcod = 0
        then disp "TODOS" @ adm.montador.montnom with frame f-dados.
        else do:
            find adm.montador where
                 adm.montador.montcod = vmontcod no-lock no-error.
            if not avail adm.montador
            then do:
                message "Montador nao cadastrado".
                undo.
            end.
            else disp adm.montador.montnom no-label with frame f-dados.
        end.    
    end.   
        
    /*
    update vtipo label "Total Geral...."
           with frame f-dados side-labels width 80.
    */
    vtipo = yes.           
           
    update skip
           vdata1 label "Data Inicial..."
           vdata2 label "Data Final"
           with frame f-dados centered side-labels width 80. 
        
    if opsys = "UNIX"
    then do:                                    /*
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)*/  
                    varquivo = "/admcom/relat/relmont" + string(time).    
    
    end.
    else assign fila = ""
                varquivo = "l:\relat\relmont" + string(time).

    message "Gerando Relatorio...".
    
        for each estab where estab.etbcod = (if vetbcod <> 0
                                             then vetbcod
                                             else estab.etbcod) no-lock:
            do vdata = vdata1 to vdata2:
                for each adm.monmov where adm.monmov.etbcod = estab.etbcod
                                      and adm.monmov.mondat = vdata no-lock:
                    if vmontcod <> 0
                    then if adm.monmov.montcod <> vmontcod
                         then next.
                    find adm.montagem where
                         adm.montagem.moncod = adm.monmov.moncod
                                               no-lock no-error.
                    find adm.montador where
                         adm.montador.montcod = adm.monmov.montcod
                                                no-lock no-error.
                    create tt-monmov.
                    assign tt-monmov.etbcod  = adm.MonMov.EtbCod 
                           tt-monmov.moncod  = adm.MonMov.MonCod  
                           tt-monmov.monnom  = adm.montagem.monnom
                           tt-monmov.mondat  = adm.MonMov.MonDat 
                           tt-monmov.monnot  = adm.MonMov.MonNot
                           tt-monmov.monser  = adm.MonMov.MonSer 
                           tt-monmov.montcod = adm.MonMov.MontCod 
                           tt-monmov.montnom = adm.montador.montnom
                           tt-monmov.movpc   = adm.MonMov.MovPC 
                           tt-monmov.procod  = adm.MonMov.ProCod.

                end.        
            end.
                        
        end.

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""relmont""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ RELATORIO DE MONTAGENS ""
                   + string(vdata1,""99/99/9999"")
                   + "" A ""
                   + string(vdata2,""99/99/9999"")"
        &Width     = "120"
        &Form      = "frame f-cabcab"}

        assign vtogcli  = 0
               vtogloj  = 0.
               
        for each tt-resumo:
            delete tt-resumo.
        end.          

        for each tt-monmov break by tt-monmov.etbcod
                                 by tt-monmov.montcod
                                 by tt-monmov.mondat
                                 by tt-monmov.moncod.
            
            find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.                        
            if not avail adm.monper
            then next.
            
            v-valor = v-valor +
                    ((tt-monmov.movpc * adm.monper.monper) / 100).

            if first-of(tt-monmov.etbcod)
            then do:
                    assign vtotcli =  0
                           vtotloj =  0.
            end.
                        
            if tt-monmov.moncod = 1
            then assign vtotcli = vtotcli + tt-monmov.movpc.
             
            if tt-monmov.moncod = 2
            then assign vtotloj = vtotloj + tt-monmov.movpc. 
            
            if tt-monmov.moncod = 1 
            then assign vtogloj =  vtogloj + tt-monmov.movpc.
            
            if tt-monmov.moncod = 2 
            then assign vtogcli =  vtogcli + tt-monmov.movpc.
                              
            if last-of(tt-monmov.etbcod) and
               last-of(tt-monmov.moncod)
            then do:
                    create tt-resumo.
                    assign tt-resumo.etbcod = tt-monmov.etbcod
                           tt-resumo.totloj = vtotloj
                           tt-resumo.totcli = vtotcli.
            end.
        end.
        for each tt-resumo no-lock 
                           break by tt-resumo.etbcod:
        
            disp tt-resumo.etbcod    column-label "Estabelecimento"
                 tt-resumo.totloj    column-label "Montagem Interna"
                 tt-resumo.totcli    column-label "Montagem Externa"
                 with down width 100 frame f-reltot1.
                 down with frame f-relt~ot1.
            vtipo = yes.                 
            if vtipo = yes
            then do:     
                    if last(tt-resumo.etbcod)
                    then do:
                            disp vtogloj  column-label "Total Montagem Interna"
                                 vtogcli  column-label "Total Montagem Externa"
                                 with down width 100 frame f-reltot2.
                                 down with frame f-reltot2 centered. 
                    end.
            end.
        end.
    output close.
    
    hide message no-pause.
    
    if opsys = "UNIX"
    then do:

        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then /*os-command silent lpr value(fila + " " + varquivo).*/
             run visurel.p (input varquivo,
                            input "").
                       
    end.
    else do:
        {mrod.i}.
    end.
end.