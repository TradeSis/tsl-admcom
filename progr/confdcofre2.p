{admcab.i}

def var vopcao   as log .
def var vtotconf like plani.platot.
def buffer bdepban for depban.
def var vaster as char format "x(13)".

def var vfec as log format "Sim/Nao".
def var vdt  like plani.pladat.    
def var vv as char.
def var varq as char format "x(23)".

def var vdatmov  as char.
def var vdephora as char.
def var vvalor   as char.

def var vlinhabb  as char.
def var vint-cont   as integer.

def var fila as char.
def var varquivo as char.
def stream stela.
def var vetb1 like estab.etbcod.
def var vetb2 like estab.etbcod.
def temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999" 
    field valdep    like depban.valdep 
    field datexp    like depban.datexp
    index tt-arq  is primary    dephora asc
                                valdep asc.

def var vreg1               as   char   format "x(200)".
def var vregistro           as   char   format "x(400)".
def var i-cont              as   int.
def var vdtarq              as   char   format "999999".

def temp-table tt-dep
   field  deprec      as recid
   field  Etbcod      like estab.Etbcod
   field  pladat      like plani.pladat
   field  cheque-dia  like plani.platot
   field  cheque-pre  like plani.platot
   field  cheque-glo  like plani.platot
   field  pagam       like plani.platot
   field  deposito    like plani.platot
   field  situacao    as l format "Sim/Nao"
   field  altera      as l format "Sim/Nao"
   field  datcon      like deposito.datcon.

def temp-table tt-banco
    field banco as int
    field valor as dec
    index i1 banco.
    
def var vdt1     as date format "99/99/9999".
def var vdt2     as date format "99/99/9999".
def var vdata    as date.

def stream stela.

def var vdtaux as date.

def temp-table tt-estab like estab.

repeat:

    vdt1 = today - 1.
    vdt2 = today - 1.
    update vdt1 label "Periodo" colon 15
           " Ate "
           vdt2 no-label 
           vetb1 label "Filial" colon 15 format ">>9"
           "       Ate "
           vetb2 no-label format ">>9"
           vopcao label "Listagem Geral" format "Sim/Nao"
           vfec   label "Fechados"
            with frame f-data centered color blue/cyan side-label width 80.
            
    if vdt1 > today or vdt2 > today then next.
    
    for each tt-dep:
        delete tt-dep.
    end.
    for each tt-banco:
        delete tt-banco.
    end.    
    for each tt-estab: delete tt-estab. end.
    
    run ws-brinks.
    run ws-protege.
    
    for each tt-estab where tt-estab.etbcod >= vetb1 and
                            tt-estab.etbcod <= vetb2 no-lock:
    
        do vdata = vdt1 to vdt2:

            find deposito where deposito.etbcod = tt-estab.etbcod  and
                                deposito.datmov = vdata no-lock no-error.
            if not avail deposito   
            then do:
                create tt-dep.
                assign tt-dep.deprec      = ?
                       tt-dep.pladat      = vdata
                       tt-dep.etbcod      = tt-estab.etbcod.
            end.
            
            else do:
                create tt-dep.
                assign tt-dep.deprec      = recid(deposito)
                       tt-dep.pladat      = deposito.datmov
                       tt-dep.etbcod      = deposito.etbcod
                       tt-dep.deposito    = deposito.depdep
                       tt-dep.cheque-dia  = deposito.chedia
                       tt-dep.cheque-pre  = deposito.chedre
                       tt-dep.cheque-glo  = deposito.cheglo
                       tt-dep.pagam       = deposito.deppag
                       tt-dep.situacao    = deposito.depsit
                       tt-dep.datcon      = deposito.datcon.
                 if deposito.depalt = "SIM"
                 then tt-dep.altera  = yes.
                 else tt-dep.altera  = no.
            end.
                
            if vopcao = no
            then do:
                vtotconf = 0.

                for each depban where depban.etbcod = tt-dep.etbcod and
                                      depban.datmov = tt-dep.pladat no-lock: 
                    
                
                    find first tt-arq where 
                               tt-arq.dephora = depban.dephora and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if not avail tt-arq
                    then  find first tt-arq where 
                               tt-arq.dephora = 0 and
                               tt-arq.valdep  = depban.valdep  no-error.
                    if not avail tt-arq
                    then  leave.
                    
                    find first bdepban where 
                               bdepban.etbcod = depban.etbcod   and
                               bdepban.dephora = depban.dephora and
                               recid(bdepban) <> recid(depban) 
                                    no-lock no-error.
                
                    if avail bdepban
                    then leave.

                    vtotconf = vtotconf + depban.valdep.

                end.
          
                
                if int(vtotconf - 0.50) = int(tt-dep.deposito - 0.50) and
                   tt-dep.deprec <> ?
                then delete tt-dep.
                
            end.
                
        end.
    end.

    /*
    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then*/ do:
               
        if opsys = "unix"
        then do:
            /*
            find first impress where impress.codimp = setbcod no-lock no-error.
            if avail impress
            then assign fila = string(impress.dfimp) 
            */
                        assign fila = ""
                        varquivo = "/admcom/relat/dep" + string(time).
        end.                    
        else assign fila = "" 
                    varquivo = "l:\relat\dep" + string(time).

        
        {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "63"
            &Cond-Var  = "120"
            &Page-Line = "66"
            &Nom-Rel   = ""confdep2""
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""
            &Tit-Rel   = """CONFERENCIA DOS DEPOSITOS BANCARIOS "" +
                        ""FILIAL "" + string(vetb1,""999"") + "" A "" +
                         string(vetb2,""999"") +   
                        ""  - Data: "" + string(vdt1) + "" A "" +
                            string(vdt2)"
            &Width     = "120"
            &Form      = "frame f-cabcab"}

        for each tt-dep break by tt-dep.etbcod
                              by tt-dep.pladat:
    
            if first-of(tt-dep.etbcod)
            then display "FILIAL - " 
                         tt-dep.etbcod no-label format "999"
                                with frame f2.
         
            display tt-dep.deposito format ">>,999.99"
                    tt-dep.pladat column-label "Data Dep."
                        with frame f2 centered down width 200.
                
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat 
                                        no-lock break by depban.etbcod
                                                  by depban.datmov.
                vaster = " ".
                
                find first tt-arq where 
                           tt-arq.dephora = int(depban.dephora) and
                           tt-arq.valdep  = depban.valdep  no-error.
                if not avail tt-arq
                then find first tt-arq where 
                           tt-arq.dephora = 0 and
                           tt-arq.valdep  = depban.valdep and
                           tt-arq.datmov  = depban.datexp  no-error.
 
                if avail tt-arq /*and depban.bancod <> 86*/
                then do:
                    find first bdepban where 
                               bdepban.etbcod = depban.etbcod and
                               bdepban.dephora = int(depban.dephora) and
                               recid(bdepban) <> recid(depban) no-lock no-error.
                    if avail bdepban
                    then vaster = " " + string(bdepban.datmov,"99/99/9999") +
                                  " #". 
                    else vaster = "            *". 
                end.
                    
                
                if vfec
                then do:
                    if vaster matches "*#*" or
                       vaster = "" 
                    then next.
                end.
                else do:
                    if vaster matches "*#*" or
                       vaster = ""
                    then.
                    else next.
                end.
                find banco where
                     banco.bancod = depban.bancod no-lock no-error.

                display vaster format "x(13)" no-label
                        depban.bancod
                        banco.numban when avail banco
                        banco.banfan when avail banco
                        depban.dephora format "9999999" 
                                column-label "Documento"
                        depban.valdep (total by depban.datmov) 
                                format ">>>,>>>,>>9.99" with down frame f2. 
            
                down with frame f2.  
                find first tt-banco where 
                           tt-banco.banco = depban.bancod
                           no-error.
                if not avail tt-banco
                then do:
                    create tt-banco.
                    tt-banco.banco = depban.bancod.
                end.
                tt-banco.valor = tt-banco.valor + depban.valdep.           
            
            end.
        
        end.          
        for each tt-banco use-index i1:
            find first banco where
                       banco.bancod = tt-banco.banco
                       no-lock no-error.
            disp tt-banco.banco column-label "Banco"
                 banco.numban when avail banco
                 banco.banfan when avail banco
                 tt-banco.valor(total) 
                 column-label "Valor" format ">>>,>>>,>>9.99"
                 with frame f-total down.
            down with frame f-total.
                 
        end.
        output close.
        if opsys = "unix" 
        then do:
            run visurel.p (input varquivo, input "").
        end.
        else do:
         {mrod.i} .
        end.
        
        return.
        
    end.
    
end.


procedure ws-brinks:
    def var vdata1 as date.
    for each tabcofre where
             tabcofre.empresa matches "*BRINKS*" and
             tabcofre.etbcod >= vetb1 and
             tabcofre.etbcod <= vetb2
              no-lock:
        do vdata = vdt1 to vdt2:
            run brinks-ws.p(input serial_cofre, input vdata).
            for each depcofre where
                 depcofre.codigocofre   = tabcofre.codigo_cofre and
                 depcofre.data_deposito = vdata
                 no-lock.
                create tt-arq.
                assign tt-arq.datmov    = depcofre.data_deposito
                   tt-arq.dephora   = depcofre.num_recibo
                   tt-arq.valdep    = depcofre.valor.  
            end. 
            find first tt-estab where 
                       tt-estab.etbcod = tabcofre.etbcod no-error.
            if not avail tt-estab
            then do:           
                create tt-estab.
                tt-estab.etbcod = tabcofre.etbcod.    
            end.    
        end.
    end.
end procedure.

procedure ws-protege:
    def var vdata1 as date.

    for each tabcofre where
             tabcofre.empresa matches "*PROTEGE*" and
             tabcofre.etbcod >= vetb1 and
             tabcofre.etbcod <= vetb2
              no-lock:

        do vdata = vdt1 to vdt2:
            vdata1 = vdata + 1.
            run protege-ws.p(input tabcofre.codigo_cofre, 
                        input vdata, input vdata1).
            for each depcofre where
                 depcofre.codigocofre   = tabcofre.codigo_cofre and
                 depcofre.data_deposito = vdata
                 no-lock.
                create tt-arq.
                assign tt-arq.datmov    = depcofre.data_deposito
                   tt-arq.dephora   = depcofre.num_recibo
                   tt-arq.valdep    = depcofre.valor.  
            end.
        end.             
        
        find first tt-estab where 
                       tt-estab.etbcod = tabcofre.etbcod no-error.
        if not avail tt-estab
        then do:           
            create tt-estab.
            tt-estab.etbcod = tabcofre.etbcod.    
        end.    
    end.
end procedure.



