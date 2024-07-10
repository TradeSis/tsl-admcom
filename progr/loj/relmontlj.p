{admcab.i}

def var vpdf    as char no-undo.
def var vauxCol as int  no-undo.
def var vCabAux as char no-undo.
def var vCabLin as char no-undo.

def var varquivo as   char.

def var vtotcli  as inte form ">>>>9"       no-undo.
def var vtotloj  as inte form ">>>>9"       no-undo.  
def var vtotgcli  as inte form ">>>>9"       no-undo.    
def var vtotgloj  as inte form ">>>>9"       no-undo. 

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
    
def temp-table tt-linha
    field etbcod1  like adm.monmov.etbcod
    field moncod1  like adm.monmov.moncod
    field monnom1  like adm.montagem.monnom
    field mondat1  like adm.monmov.mondat
    field monnot1  like adm.monmov.monnot
    field monser1  like adm.monmov.monser
    field montcod1 like adm.monmov.montcod
    field montnom1 like adm.montador.montnom
    field movpc1   like adm.monmov.movpc
    field procod1  like adm.monmov.procod
    field t-valor1 like adm.monmov.movpc
    
    field etbcod2  like adm.monmov.etbcod
    field moncod2  like adm.monmov.moncod
    field monnom2  like adm.montagem.monnom
    field mondat2  like adm.monmov.mondat
    field monnot2  like adm.monmov.monnot
    field monser2  like adm.monmov.monser
    field montcod2 like adm.monmov.montcod
    field montnom2 like adm.montador.montnom
    field movpc2   like adm.monmov.movpc
    field procod2  like adm.monmov.procod
    field t-valor2 like adm.monmov.movpc
    
    field t-fil-int    as int
    field t-fil-ext    as int .

def buffer b-tt-linha for tt-linha.

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

            vetbcod = setbcod.
            disp vetbcod with frame f-dados.
             
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
    
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
    
    varquivo = "/admcom/relat/relmont" + string(mtime).
    
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
        &Page-Size = "0" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""relmont""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ RELATORIO DE MONTAGENS ""
                   + string(vdata1) + "" A "" + string(vdata2)"
        &Width     = "160"
        &Form      = "frame f-cabcab"}

    if vtipo
    then do:
        vauxCol = 0.
        
        /**** usar para debug
        create tt-monmov.
        assign tt-monmov.montcod = 90
               tt-monmov.montnom = "teste"
               tt-monmov.movpc   = 1
               tt-monmov.etbcod = 189
               tt-monmov.monnot = 12345.
                       
        create tt-monmov.
        assign tt-monmov.montcod = 91
               tt-monmov.montnom = "teste1"
               tt-monmov.movpc   = 1
               tt-monmov.etbcod = 189
               tt-monmov.monnot = 123456.
                              
        create tt-monmov.
        assign tt-monmov.montcod = 92
               tt-monmov.montnom = "teste2"
               tt-monmov.movpc   = 1
               tt-monmov.etbcod = 189
               tt-monmov.monnot = 1234567.
        ****/
        
        for each tt-monmov break by tt-monmov.etbcod
                                 by tt-monmov.montcod
                                 by tt-monmov.mondat.
            
            vauxCol = vauxCol + 1.
            
            if first-of(tt-monmov.etbcod)
            then do:
                 assign vtotcli =  0
                        vtotloj =  0.
            end.
                        
            if tt-monmov.moncod = 1
            then assign vtotcli = vtotcli + 1.
             
            if tt-monmov.moncod = 2
            then assign vtotloj = vtotloj + 1. 
            
            if tt-monmov.moncod = 1 then assign vtotgloj =  vtotgloj + 1.
            if tt-monmov.moncod = 2 then assign vtotgcli =  vtotgcli + 1.

            if first-of(tt-monmov.etbcod) 
            then do: 
                /***
                find estab where 
                     estab.etbcod = tt-monmov.etbcod no-lock no-error.
                     
                disp /* tt-monmov.montcod */
                     tt-monmov.etbcod  label "Filial"
                     estab.etbnom      no-label
                     with frame f-monmov-etb side-labels.
                ***/
            end. 
            
            if first-of(tt-monmov.montcod)
            then do:
                /***
                disp /*space(2)*/
                     tt-monmov.montcod label "Montador"
                     tt-monmov.montnom no-label
                     with frame f-monmov side-labels.
                ***/
                
                create tt-linha.
                vauxCol = 1.
            end.
            find produ where produ.procod = adm.monmov.procod no-lock no-error.

            find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.
            
            if not avail adm.monper
            then next.
                        
            /*********
            disp /*space(4)*/             /*
                 tt-monmov.etbcod column-label "Fil" format ">>9"*/
                 tt-monmov.mondat column-label "Dt.Mont." format "99/99/9999"
                 substring(tt-monmov.monnom,10,7) 
                                  column-label "Montagem" format "x(7)"
                 tt-monmov.monnot column-label "Num. NF"
                 tt-monmov.monser column-label "Serie"
                 tt-monmov.procod column-label "Produto" /*
                 produ.pronom     column-label "Descricao" format "x(20)"
                                  when avail produ         */
                                  /*
                 tt-monmov.movpc  column-label "Valor"  format ">>,>>9.99"
                                  (total by tt-monmov.montcod)
                                  */
                 ((tt-monmov.movpc * adm.monper.monper) / 100)
                                  when avail adm.monper
                                  column-label /*"Valor!Liquido"*/
                                  "Receber"
                                  format ">,>>9.99"

                                  (total by tt-monmov.montcod)
                 with frame fx width 160 down.
                 
                 down with frame fx.
             *********/
            
            if vauxCol mod 2 = 0 then do:
                assign tt-linha.montcod2 = tt-monmov.montcod
                       tt-linha.montnom2 = tt-monmov.montnom
                       tt-linha.mondat2  = tt-monmov.mondat
                       tt-linha.monnom2  = tt-monmov.monnom
                       tt-linha.monnot2  = tt-monmov.monnot
                       tt-linha.monser2  = tt-monmov.monser
                       tt-linha.procod2  = tt-monmov.procod
                       tt-linha.etbcod2  = tt-monmov.etbcod.
                       
                if avail adm.monper then
                    tt-linha.t-valor2 = 
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
             
                 create tt-linha.
            end.
            else do:
                 assign tt-linha.montcod1 = tt-monmov.montcod
                        tt-linha.montnom1 = tt-monmov.montnom    
                        tt-linha.mondat1  = tt-monmov.mondat
                        tt-linha.monnom1  = tt-monmov.monnom
                        tt-linha.monnot1  = tt-monmov.monnot
                        tt-linha.monser1  = tt-monmov.monser
                        tt-linha.procod1  = tt-monmov.procod
                        tt-linha.etbcod1  = tt-monmov.etbcod.

                if avail adm.monper then
                   tt-linha.t-valor1 =
                        ((tt-monmov.movpc * adm.monper.monper) / 100).
            end.                    
                    
            if last-of(tt-monmov.etbcod) 
            then do: 
                             
                assign tt-linha.t-fil-int = vtotgloj
                       tt-linha.t-fil-ext = vtotgcli.

                for each b-tt-linha where b-tt-linha.etbcod1 = tt-monmov.etbcod
                                      and recid(b-tt-linha) <> recid(tt-linha)
                                          exclusive-lock:
                    assign b-tt-linha.t-fil-int = vtotgloj
                           b-tt-linha.t-fil-ext = vtotgcli.
                end.

                /***
                put skip(1) /*space(4)*/ .
                put "Total Montagem Interna Filial:" vtotgloj
                    space(5)
                    "Total Montagem Externa Filial:" vtotgcli.
            
                put skip(1).
                ***/
            end.
        end.
        
        /* escreve no relatorio */
        for each tt-linha where tt-linha.montcod1 <> 0
                                no-lock break by tt-linha.etbcod1
                                              by tt-linha.montcod1
                                              by tt-linha.mondat1:
            
            if first-of(tt-linha.etbcod1)
            then do:
                find estab where estab.etbcod = tt-linha.etbcod1
                                 no-lock no-error.

                disp tt-linha.etbcod1 label "Filial"
                     estab.etbnom      no-label
                     with frame f-monmov-etb side-labels.
            end.
            
            if first-of(tt-linha.montcod1)
            then do:
                 disp tt-linha.montcod1 label "Montador"
                      tt-linha.montnom1 no-label
                      with frame f-monmov side-labels.
            end.
            
            disp tt-linha.mondat1 column-label "Dt.Mont."
                 format "99/99/9999"
                 substring(tt-linha.monnom1,10,7) column-label "Montagem"
                 format "x(7)"
                 tt-linha.monnot1 column-label "Num. NF"
                 tt-linha.monser1 column-label "Serie"
                 tt-linha.procod1 column-label "Produto"
                 tt-linha.t-valor1 column-label "Receber"
                 format ">,>>9.99"
                 (total by tt-linha.montcod1)

                 space(28)
                     
                 tt-linha.mondat2 column-label "Dt.Mont."
                 format "99/99/9999" when tt-linha.montcod2 <> 0
                 substring(tt-linha.monnom2,10,7) column-label "Montagem"
                 format "x(7)" when tt-linha.montcod2 <> 0
                 tt-linha.monnot2 column-label "Num. NF" 
                 when tt-linha.montcod2 <> 0
                 tt-linha.monser2 column-label "Serie"
                 when tt-linha.montcod2 <> 0
                 tt-linha.procod2 column-label "Produto"
                 when tt-linha.montcod2 <> 0
                 tt-linha.t-valor2 column-label "Receber"
                 format ">,>>9.99"
                 (total by tt-linha.montcod1)
                 when tt-linha.montcod2 <> 0
                 with frame fx width 160 down.
                     
                 down with frame fx.
            
            if last-of(tt-linha.etbcod1)
            then do:
                        
                 put skip(1).
                 put "Total Montagem Interna Filial:" tt-linha.t-fil-int
                 space(39)
                 "Total Montagem Externa Filial:" tt-linha.t-fil-ext.
                 put skip(1).
            end.
        end.
        
        for each tt-linha exclusive-lock:
            delete tt-linha.
        end.
                 
    end.
    else do:
        vauxCol = 0.
        
        /**** usar debug
        create tt-monmov.
        assign tt-monmov.montcod = 90
               tt-monmov.montnom = "teste"
               tt-monmov.movpc   = 1.
               
        create tt-monmov.        
        assign tt-monmov.montcod = 91
               tt-monmov.montnom = "teste1"
               tt-monmov.movpc   = 1.
                                                     
        create tt-monmov.
        assign tt-monmov.montcod = 92
               tt-monmov.montnom = "teste2"
               tt-monmov.movpc   = 1.
        ****/
        
        if can-find(first tt-monmov) then
            create tt-linha.
        
        for each tt-monmov break by tt-monmov.montcod
                                 by tt-monmov.mondat.
            
            vauxCol = vauxCol + 1.
            
            find adm.monper where adm.monper.etbcod = tt-monmov.etbcod
                              and adm.monper.moncod = tt-monmov.moncod
                              no-lock no-error.
            if not avail adm.monper
            then next.
            
            v-valor = v-valor +
                    ((tt-monmov.movpc * adm.monper.monper) / 100).

            if last-of(tt-monmov.montcod)
            then do:
                    /*
                    disp tt-monmov.montcod column-label "Codigo"
                         tt-monmov.montnom column-label "Montador" 
                         format "x(40)"
                         v-valor           column-label "Receber" (total)
                         with frame f-monmov2 down width 80.
                    down with frame f-monmov2.
                    v-valor = 0.
                    */
                
                if vauxCol mod 2 = 0
                then do:
                    assign tt-linha.montcod2 = tt-monmov.montcod
                           tt-linha.montnom2 = tt-monmov.montnom
                           tt-linha.t-valor2 = v-valor.
                           
                    create tt-linha.
                end.
                else
                    assign tt-linha.montcod1 = tt-monmov.montcod
                           tt-linha.montnom1 = tt-monmov.montnom
                           tt-linha.t-valor1 = v-valor.
                
                v-valor = 0.
            end.
        end.
                    
        /* escrever relatorio */
        for each tt-linha where tt-linha.montcod1 <> 0 no-lock:
            disp tt-linha.montcod1 column-label "Codigo"
                 tt-linha.montnom1 column-label "Montador" format "x(40)"
                 tt-linha.t-valor1 column-label "Receber" (total)
                 space(20)
                 tt-linha.montcod2 when tt-linha.montcod2 <> 0
                 column-label "Codigo"
                 tt-linha.montnom2 when tt-linha.montcod2 <> 0
                 column-label "Montador" format "x(40)"
                 tt-linha.t-valor2 when tt-linha.montcod2 <> 0
                 column-label "Receber" (total)
                 with frame f-monmov2 down width 160.
            down with frame f-monmov2.                        
        end.
        
        for each tt-linha exclusive-lock:
            delete tt-linha.
        end.
    end.            

    output close.
    
    hide message no-pause.
    
            run pdfout.p (input varquivo,
                          input "/admcom/kbase/pdfout/",
                          input "relmontlj-" + string(mtime) + ".pdf",
                          input "Portrait",
                          input 6.0,
                          input 1,
                          output vpdf).
end.
