{admcab.i}

def var varquivo as   char.
def var fila     as   char.

def var vtotcli   as dec format ">>,>>>,>>9.99" no-undo.
def var vtotloj   as dec format ">>,>>>,>>9.99" no-undo.  
def var vtotgcli  as dec format ">>,>>>,>>9.99" no-undo.    
def var vtotgloj  as dec format ">>,>>>,>>9.99" no-undo. 

def var vdata1   as   date format "99/99/9999".
def var vdata2   as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".

def var vmontcod like adm.montador.montcod.
def var vetbcod  like estab.etbcod.

def var vtipo    as log format "Analitico/Sintetico".

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

def temp-table tt-despf
    field etbcod  like adm.monmov.etbcod 
    field moncod  like adm.monmov.moncod
    field monnom  like adm.montagem.monnom
    field valor as dec
    index i1 etbcod moncod
    .
    
def var v-valor like adm.monmov.movpc.

repeat:

    for each tt-monmov.
        delete tt-monmov.
    end.

    assign vetbcod  = 0
           vmontcod = 0 
           vdata1   = today
           vdata2   = today
           vtotcli  = 0
           vtotloj  = 0
           vtotgcli = 0
           vtotgloj = 0.

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

    update skip
           vdata1 label "Data Inicial..."
           vdata2 label "Data Final"
           with frame f-dados centered side-labels width 80. 

    update vtipo no-label
           with frame f-dados.
    
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
    hide message no-pause.
    if vtipo = no
    then do:
        sresp = no.
        message "GERAR DESPESAS FINANCEIRAS ?  " update sresp.
        if sresp 
        then do:
            v-valor = 0.
            for each tt-monmov no-lock break 
                                 by tt-monmov.etbcod       
                                 by tt-monmov.montcod
                                 by tt-monmov.mondat.
            
                find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.
                if not avail adm.monper
                then next.

                v-valor = v-valor +
                    ((tt-monmov.movpc * adm.monper.monper) / 100).

                if last-of(tt-monmov.montcod)
                then do:
                    disp "GERANDO DESPESA FINANCEIRA" skip "Montador: "
                    tt-monmov.montnom  format "x(40)" "  Valor: " v-valor
                    with frame fcdisp 1 down centered row 10 no-label
                     no-box side-label color message.
                     pause 0.
                    run cria-desp.
                    v-valor = 0.     
                end.
            end.
            output close.
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

    if vtipo
    then do:
        for each tt-monmov break by tt-monmov.etbcod
                                 by tt-monmov.montcod
                                 by tt-monmov.mondat.
            
            find produ where produ.procod = adm.monmov.procod no-lock no-error.

            find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.
            if not avail adm.monper
            then next.
            
            
            if first-of(tt-monmov.montcod)
            then do:
                    assign vtotgcli =  0
                           vtotgloj =  0.
            end.
                        
            if tt-monmov.moncod = 1
            then assign vtotcli = vtotcli + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
             
            if tt-monmov.moncod = 2
            then assign vtotloj = vtotloj + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
            
            if tt-monmov.moncod = 1 
            then assign vtotgloj =  vtotgloj + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
            
            if tt-monmov.moncod = 2 
            then assign vtotgcli =  vtotgcli + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).

            if first-of(tt-monmov.etbcod) 
            then do: 
                find estab where 
                     estab.etbcod = tt-monmov.etbcod no-lock no-error.
                     
                disp tt-monmov.montcod label "Filial"
                     estab.etbnom      no-label
                     with frame f-monmov-etb side-labels.

            end. 
            
            if first-of(tt-monmov.montcod)
            then do:
                disp space(3)
                     tt-monmov.montcod label "Montador"
                     tt-monmov.montnom no-label
                     with frame f-monmov side-labels.
            end.
            
             
                        
            disp space(6)             
                 tt-monmov.etbcod column-label "Fil" format ">>9"
                 tt-monmov.mondat column-label "Dt.Mont." format "99/99/9999"
                 substring(tt-monmov.monnom,10,7) 
                                  column-label "Montagem" format "x(7)"
                 tt-monmov.monnot column-label "Num. NF"
                 tt-monmov.monser column-label "Serie"
                 tt-monmov.procod column-label "Produto"  /*
                 produ.pronom     column-label "Descricao" format "x(26)"
                                  when avail produ          */

                 tt-monmov.movpc  column-label "Valor"  format ">,>>>,>>9.99"
                                  (total by tt-monmov.montcod)

                ((tt-monmov.movpc * adm.monper.monper) / 100)
                                  when avail adm.monper
                                  column-label "Valor!Liquido"
/*                                  "Receber"*/
                                  format ">,>>>,>>9.99"

                                  (total by tt-monmov.montcod)
                 with frame fx width 120 down.
                    down with frame fx.
                    
            if last-of(tt-monmov.montcod) 
            then do: 

                put skip(1) space(3) .
                put "Total Montagem Cliente:" vtotgloj
                    space(5)
                    "Total Montagem Loja:" vtotgcli.
            
                put skip(1).
            end.
     

        end.
    end.
    else do:
        for each tt-monmov break by tt-monmov.montcod
                                 by tt-monmov.mondat.
            
            find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.
            if not avail adm.monper
            then next.
            
            /***/
            
            if first-of(tt-monmov.montcod)
            then do:
                    assign vtotgcli =  0
                           vtotgloj =  0.
            end.
                        
            if tt-monmov.moncod = 1
            then assign vtotcli = vtotcli + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
             
            if tt-monmov.moncod = 2
            then assign vtotloj = vtotloj + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
            
            if tt-monmov.moncod = 1 
            then assign vtotgloj =  vtotgloj + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
            
            if tt-monmov.moncod = 2 
            then assign vtotgcli =  vtotgcli + /*tt-monmov.movpc.*/
                        ((tt-monmov.movpc * adm.monper.monper) / 100).

            /***/
            
            v-valor = v-valor +
                    ((tt-monmov.movpc * adm.monper.monper) / 100).

            if last-of(tt-monmov.montcod)
            then do:
                disp tt-monmov.montcod column-label "Codigo"
                     tt-monmov.montnom column-label "Montador" format "x(40)"
                     v-valor           column-label "Receber" (total)
                     with frame f-monmov2 down width 120.
                down with frame f-monmov2.     
                v-valor = 0.     
            end.
            
            if last-of(tt-monmov.montcod) 
            then do: 

                put skip(1) space(3) .
                put "Total Montagem Cliente:" vtotgloj
                    space(5)
                    "Total Montagem Loja:" vtotgcli.
            
                put skip(1).
            end.
            
            
        end.
    end.            

    output close.
    
    hide message no-pause.
    
    if opsys = "UNIX"
    then do:
        /*
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        then os-command silent lpr value(fila + " " + varquivo).*/
             run visurel.p (input varquivo,
                            input "").
                       
    end.
    else do:
        {mrod.i}.
    end.
end.

procedure cria-desp:
    def var vtitnum as int.
    def var vip as char.
    find first foraut where 
               foraut.forcod = 100330 no-lock. 
    create titluc. 
    assign titluc.empcod = 19 
           titluc.modcod = foraut.modcod 
           titluc.clifor = foraut.forcod 
           titluc.titpar = 1 
           titluc.etbcod = tt-monmov.etbcod 
           titluc.titnat = yes 
           titluc.titsit = "AUT"  /* "LIB" */
           titluc.titdtemi = today 
           titluc.titdtven = today 
           titluc.titvlcob = v-valor 
           titluc.cxacod   = 1 
           titluc.cobcod   = 1 
           titluc.evecod   = 4 /* 1 */
           titluc.datexp   = today 
           titluc.titobs[1] = "Codigo=" + string(tt-monmov.montcod) + " |" +
                              "Montador=" + tt-monmov.montnom + " |".
           titluc.titobs[2] = "".

    /****
    find last numaut where numaut.etbcod = 999 no-error.  
    if avail numaut    
    then do:
        numaut.titnum = numaut.titnum + 1.    
    end.
    else do: 
        create numaut. 
        assign numaut.titnum = 1000000.
    end.    
    ***/

    vtitnum = 0.
    pause 1 no-message.
    run gera-titnum.p(output vtitnum).              
    titluc.titnum = string(vtitnum).
    
    find last numaut where numaut.etbcod = 999 no-lock no-error.
    
    find first estab where estab.etbcod = tt-monmov.etbcod no-lock no-error.
         
    /*** Proc. 334      
    if avail estab
        and estab.etbcod < 900 and
            estab.etbcod <> 22 
    then do: 
         vip = "filial" + string(tt-monmov.etbcod,"999").
         message "Criando despesa na loja.....".
         connect fin -H value(vip) -S sdrebfin -N tcp -ld 
                                        finloja no-error.
         if not connected ("finloja")  
         then do:  
             message "Filial nao conectada".  
             pause.  
         end. 
         else do:

            run cria-titluc.p (recid(titluc)). 
            disconnect finloja.
                    
            hide message no-pause.        
        end. 
    end.
    ***/
end procedure.        
