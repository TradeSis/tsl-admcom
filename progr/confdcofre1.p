{admcab.i}

def var vdt like plani.pladat.    
def var vv as char.
def var varq as char format "x(23)".
def var vtotconf  like plani.platot.
def buffer bdepban for depban.

def var vint-cont   as integer.

def var vlinhabb  as char.

def var vdatmov  as char.
def var vdephora as char.
def var vvalor   as char.


def new shared temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999"
    field valdep   like depban.valdep 
    field datexp   like depban.datexp
    index tt-arq   is primary dephora asc
                              valdep asc.

def var vreg1               as   char   format "x(200)".
def var vregistro           as   char   format "x(400)".
def var i-cont              as   int.
def var vdtarq              as   char   format "999999".

def new shared temp-table tt-dep
   field  deprec      as recid
   field  Etbcod      like estab.Etbcod
   field  pladat      like plani.pladat
   field  cheque-dia  like plani.platot
   field  cheque-pre  like plani.platot
   field  pagam       like plani.platot
   field  deposito    like plani.platot
   field  situacao    as l format "Sim/Nao"
   field  altera      like deposito.depalt format "x(03)"
   field  datcon      like deposito.datcon
   field  ok          as char format "x(01)".

def var varquivo as char format "x(30)".
def new shared var vdata   as date format "99/99/9999".
def stream stela.

def temp-table tt-estab like estab.

repeat:
    
    update vdata label "Data"
            with frame f-data centered color blue/cyan side-label width 80.
    
    for each tt-dep:
        delete tt-dep.
    end.
    for each tt-estab: delete tt-estab. end.
        
    run ws-brinks.
    run ws-protege.
    
    for each tt-estab where tt-estab.etbcod > 0 no-lock:
        
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
                   tt-dep.pagam       = deposito.deppag
                   tt-dep.situacao    = deposito.depsit
                   tt-dep.datcon      = deposito.datcon
                   tt-dep.altera      = deposito.depalt.
        end.
        if tt-dep.pladat <> ?
        then do:
            vtotconf = 0.
        
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat no-lock.
                
                if depban.bancod <> 991 and
                   depban.bancod <> 992
                then next.   
                find first  tt-arq where 
                    tt-arq.dephora = depban.dephora and
                    tt-arq.valdep  = depban.valdep   no-error.
                if not avail tt-arq
                then  find first tt-arq where 
                                 tt-arq.dephora = 0 and
                                 tt-arq.valdep  = depban.valdep and
                                 tt-arq.datmov  = depban.datexp 
                                                    no-error.
                
                if not avail tt-arq /*and depban.bancod <> 86*/
                then  leave. 

                find first bdepban where bdepban.etbcod  = depban.etbcod and
                                         bdepban.dephora = depban.dephora and
                                         recid(bdepban) <> recid(depban) 
                                               no-lock no-error.

                if avail bdepban
                then leave.
            
                vtotconf = vtotconf + depban.valdep.
    
            end.

            if int(vtotconf - 0.50) = int(tt-dep.deposito - 0.50) and
                  tt-dep.deprec <> ? 
            then tt-dep.ok = "*".
        end.
        
    end.
    

    run wdep1.p.

end.

procedure ws-brinks:
    for each tabcofre where
             tabcofre.empresa matches "*BRINKS*" 
              no-lock:
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

end procedure.

procedure ws-protege:
    def var vdata1 as date.
    vdata1 = vdata + 1.
    for each tabcofre where
             tabcofre.empresa matches "*PROTEGE*" 
              no-lock:
        run protege-ws.p(input codigo_cofre, input vdata, input vdata1).
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
end procedure.
         
