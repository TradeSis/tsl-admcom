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

    hide message no-pause.
    message "Importando Extratos dos Bancos. Aguarde ...".
    pause 0.
    run le-extratos.
    run le-extratos-bb.
    hide message no-pause.
    
repeat:
    
    update vdata label "Data"
            with frame f-data centered color blue/cyan side-label width 80.
    
    for each tt-dep:
        delete tt-dep.
    end.
        
    do vdt = vdata - 20 to vdata + 5:
        
        run le-extratos-itau.

        run le-extratos-bradesco.

        run le-extratos-sicredi.

        run le-extratos-banrisul.

        run cicoob-cef.p(vdt). /*CICOOB CAIXA*/
         
        if opsys = "UNIX"
        then varq = "/admcom/caixa/CEF" + substring(string(vdt),7,2) 
                     + substring(string(vdt),4,2)
                     + substring(string(vdt),1,2) 
                     + ".txt".
        else varq = "l:\caixa\CEF" + substring(string(vdt),7,2) 
                     + substring(string(vdt),4,2)
                     + substring(string(vdt),1,2) 
                     + ".txt".

        if search(varq) <> ?
        then do:
           if opsys <> "UNIX"
           then dos silent 
                value("c:\dlc\bin\quoter -d ; "  + varq + " > cef.txt ").
           else unix  silent
                value("quoter -d % "  + varq + " > ./cef.txt ").

 
            input from ./cef.txt no-echo. 
            repeat:  
        
                import vv.
                
                create tt-arq.
                assign tt-arq.datmov   = date(int(substr(vv,4,2)),
                                              int(substr(vv,1,2)),
                                              int(substr(vv,7,4)))
                       tt-arq.dephora   = int(substr(vv,11,7))                 
                       tt-arq.valdep    = dec(substr(vv,18,12)) / 100.  
                 
            end.
            input close.
        
        end.
        
        
    end.
        
        
        /***/
    for each estab no-lock:
        if estab.etbcod >= 991 or estab.etbcod = 22
        then next.
        
        if {conv_igual.i estab.etbcod} then next.
     

        find deposito where deposito.etbcod = estab.etbcod  and
                            deposito.datmov = vdata no-lock no-error.
        if not avail deposito
        then do:
            create tt-dep.
            assign tt-dep.deprec      = ?
                   tt-dep.pladat      = vdata
                   tt-dep.etbcod      = estab.etbcod.
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
               /* tt-dep.deposito > 0 */   
                  tt-dep.deprec <> ? /* antonio - sol 25888 */
            then tt-dep.ok = "*".
        end.
        
    end.
    

    run wdep1.p.

end.


procedure le-extratos.

    def var vdigitos as int.
    def var vaux-arq as char.
    
    
                if opsys = "UNIX"
                    and search("../extrato/extrcc90948.bbt") = ?
                then return.    
        
                if opsys <> "UNIX"
                    and search("..\extrato\extrcc90948.bbt") = ?
                then return.
                
                if opsys = "UNIX"
                then do:
                    vaux-arq = "/admcom/relat/ext.bb" + string(time).
                    unix silent
                        value("/usr/dlc/bin/quoter ../extrato/extrcc90948.bbt 
                                    > " + vaux-arq).
                end.
                else do:    
                    vaux-arq = "l:\relat\ext.bb" + string(time).
                    dos silent 
                 value("c:\dlc\bin\quoter -d "";"" ..\extrato\extrcc90948.bbt
                                    > " + vaux-arq ).
 
                end.
                    for each tt-arq.
                        delete tt-arq.
                    end.
                    input from value(vaux-arq) no-echo.
                    bl_import:
                    repeat: 
                    
                        assign vdatmov = ""
                               vdephora = ""
                               vvalor   = "".

                        import vlinhabb.
                        
                        assign vdatmov = trim(substring(vlinhabb,1,15))
                               vdephora = substring(vlinhabb,56,19)
                               vvalor   = substring(vlinhabb,76,18).
                               
                        assign vdephora = trim(vdephora).

                        assign vdephora = replace(vdephora,".","").
                        
                        vdigitos = length(vdephora).
                        if vdigitos = 7
                        then.
                        else if vdigitos = 10
                        then vdephora = substring(vdephora,4,7).
                        else if vdigitos = 11
                        then vdephora = substring(vdephora,5,7).
                        else if vdigitos = 12
                        then vdephora = substring(vdephora,6,7).
                        else if vdigitos = 13
                        then vdephora = substring(vdephora,7,7).
                        else if vdigitos = 14
                        then vdephora = substring(vdephora,8,7).
                        else if vdigitos = 15
                        then vdephora = substring(vdephora,9,7).
                        else if vdigitos = 16
                        then vdephora = substring(vdephora,10,7).
                         
                        assign vvalor = replace(vvalor,".","").
                        
                        assign vvalor = replace(vvalor,",","").    
                        
                        assign vvalor = replace(vvalor,"C","").
                        
                        assign vvalor = replace(vvalor,"D","").
                        
                        assign vvalor = trim(vvalor).

                        if vdephora = "" or vvalor = ""
                        then next bl_import.
                        
                        do vint-cont = 1 to length(vdephora):
                                   
                            if substring(vdephora,vint-cont,1) <> "0"
                                and substring(vdephora,vint-cont,1) <> "1"
                                and substring(vdephora,vint-cont,1) <> "2"
                                and substring(vdephora,vint-cont,1) <> "3"
                                and substring(vdephora,vint-cont,1) <> "4"
                                and substring(vdephora,vint-cont,1) <> "5"
                                and substring(vdephora,vint-cont,1) <> "6"
                                and substring(vdephora,vint-cont,1) <> "7"
                                and substring(vdephora,vint-cont,1) <> "8"
                                and substring(vdephora,vint-cont,1) <> "9"
                            then next bl_import.    
                                   
                        end.       
                        
                               
                        do vint-cont = 1 to length(vvalor):
                                   
                            if substring(vvalor,vint-cont,1) <> "0"
                                and substring(vvalor,vint-cont,1) <> "1"
                                and substring(vvalor,vint-cont,1) <> "2"
                                and substring(vvalor,vint-cont,1) <> "3"
                                and substring(vvalor,vint-cont,1) <> "4"
                                and substring(vvalor,vint-cont,1) <> "5"
                                and substring(vvalor,vint-cont,1) <> "6"
                                and substring(vvalor,vint-cont,1) <> "7"
                                and substring(vvalor,vint-cont,1) <> "8"
                                and substring(vvalor,vint-cont,1) <> "9"
                            then next bl_import. 
                                   
                        end.       
                               
                        do vint-cont = 1 to length(vdatmov):
                                   
                            if substring(vdatmov,vint-cont,1) <> "0"
                                and substring(vdatmov,vint-cont,1) <> "1"
                                and substring(vdatmov,vint-cont,1) <> "2"
                                and substring(vdatmov,vint-cont,1) <> "3"
                                and substring(vdatmov,vint-cont,1) <> "4"
                                and substring(vdatmov,vint-cont,1) <> "5"
                                and substring(vdatmov,vint-cont,1) <> "6"
                                and substring(vdatmov,vint-cont,1) <> "7"
                                and substring(vdatmov,vint-cont,1) <> "8"
                                and substring(vdatmov,vint-cont,1) <> "9"
                                and substring(vdatmov,vint-cont,1) <> "/"
                            then next bl_import. 
                                   
                        end.       
                                 
                        create tt-arq.
                        assign tt-arq.datmov   = date(int(substr(vdatmov,4,2)),
                                                      int(substr(vdatmov,1,2)),
                                                      int(substr(vdatmov,7,4))) 
                               tt-arq.dephora   = int(vdephora)
                               tt-arq.valdep    = int(vvalor) / 100.

                               
                    end.
                    input close.
                
end procedure.              

procedure le-extratos-bb.
    def var vdigitos as int.
    def var vaux-arq as char.
    def var varquivo as char.
    varquivo = "/admcom/extrato/extrcc90948.bbt".
    if search(varquivo) = ?
    then.
    else do:
         vaux-arq = "/admcom/relat/ext.bb" + string(time).
         unix silent value("/usr/dlc/bin/quoter " + varquivo +
                                  " > " + vaux-arq). 
         for each tt-arq. delete tt-arq. end.
         input from value(vaux-arq) no-echo.
         bl_import:
         repeat: 
                    
                assign vdatmov = ""
                               vdephora = ""
                               vvalor   = "".

                import vlinhabb.
                vlinhabb = trim(vlinhabb).
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,90,25)
                       vvalor   = substring(vlinhabb,116,15)
                       vdephora = trim(vdephora)
                       vdephora = replace(vdephora,".","")
                       .

                vdigitos = length(vdephora).
                if vdigitos = 7
                then.
                else if vdigitos = 10
                then vdephora = substring(vdephora,4,7).
                else if vdigitos = 11
                then vdephora = substring(vdephora,5,7).
                else if vdigitos = 12
                then vdephora = substring(vdephora,6,7).
                else if vdigitos = 13
                then vdephora = substring(vdephora,7,7).
                else if vdigitos = 14
                then vdephora = substring(vdephora,8,7).
                else if vdigitos = 15
                then vdephora = substring(vdephora,9,7).
                else if vdigitos = 16
                then vdephora = substring(vdephora,10,7).
 
                assign 
                    vvalor = replace(vvalor,".","")
                    vvalor = replace(vvalor,",","")    
                    vvalor = replace(vvalor,"C","")
                    vvalor = replace(vvalor,"D","")
                    vvalor = trim(vvalor).

                if vdephora = "" or vvalor = ""
                then next bl_import.
                        
                assign vint-cont = 0.

                do vint-cont = 1 to length(vdephora):
                                   
                    if substring(vdephora,vint-cont,1) <> "0"
                                and substring(vdephora,vint-cont,1) <> "1"
                                and substring(vdephora,vint-cont,1) <> "2"
                                and substring(vdephora,vint-cont,1) <> "3"
                                and substring(vdephora,vint-cont,1) <> "4"
                                and substring(vdephora,vint-cont,1) <> "5"
                                and substring(vdephora,vint-cont,1) <> "6"
                                and substring(vdephora,vint-cont,1) <> "7"
                                and substring(vdephora,vint-cont,1) <> "8"
                                and substring(vdephora,vint-cont,1) <> "9"
                    then next bl_import.    
                                   
                end.       
                        
                               
                do vint-cont = 1 to length(vvalor):
                                   
                    if substring(vvalor,vint-cont,1) <> "0"
                                and substring(vvalor,vint-cont,1) <> "1"
                                and substring(vvalor,vint-cont,1) <> "2"
                                and substring(vvalor,vint-cont,1) <> "3"
                                and substring(vvalor,vint-cont,1) <> "4"
                                and substring(vvalor,vint-cont,1) <> "5"
                                and substring(vvalor,vint-cont,1) <> "6"
                                and substring(vvalor,vint-cont,1) <> "7"
                                and substring(vvalor,vint-cont,1) <> "8"
                                and substring(vvalor,vint-cont,1) <> "9"
                    then next bl_import. 
                                   
                end.       
                               
                do vint-cont = 1 to length(vdatmov):
                                   
                            if substring(vdatmov,vint-cont,1) <> "0"
                                and substring(vdatmov,vint-cont,1) <> "1"
                                and substring(vdatmov,vint-cont,1) <> "2"
                                and substring(vdatmov,vint-cont,1) <> "3"
                                and substring(vdatmov,vint-cont,1) <> "4"
                                and substring(vdatmov,vint-cont,1) <> "5"
                                and substring(vdatmov,vint-cont,1) <> "6"
                                and substring(vdatmov,vint-cont,1) <> "7"
                                and substring(vdatmov,vint-cont,1) <> "8"
                                and substring(vdatmov,vint-cont,1) <> "9"
                                and substring(vdatmov,vint-cont,1) <> "/"
                            then next bl_import. 
                                   
                end.       
                        
                create tt-arq.
                assign 
                    tt-arq.datmov   = date(int(substr(vdatmov,4,2)),
                                                      int(substr(vdatmov,1,2)),
                                                      int(substr(vdatmov,7,4))) 
                    tt-arq.dephora   = int(vdephora)
                    tt-arq.valdep    = int(vvalor) / 100.

                               
         end.
         input close.
    end. 
end procedure.

procedure le-extratos-banrisul.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    def var varquivo1 as char.
    def var vlinha as char.
    
    if opsys = "UNIX" 
    then varquivo = "/admcom/banrisul/EXTRATO_CC.BDP.D" 
                    + string(day(vdt),"99") + 
                     string(month(vdt),"99") 
                      .
    else varquivo = "l:\bradesco\EXTRATO_CC.BDP.D" 
                    + string(day(vdt),"99") +
                     string(month(vdt),"99")
                      .
    varquivo1 = varquivo + ".quo".
       
    if  search(varquivo) = ?
    then do:
        /*
        message color red/with
            "Nao existe arquivo " varquivo
            view-as alert-box.
        leave.
        */
    end.        
    else do:
        if opsys = "UNIX"
        then unix silent 
            value("/usr/dlc/bin/quoter -d % " + varquivo + " > " + varquivo1).
        else dos silent 
            value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varquivo1).

        input from value(varquivo1) no-echo.
        repeat: 
            import vlinha.
            
            if substr(vlinha,1,1)  = "1" and
               substr(vlinha,42,1) = "1" and
               substr(vlinha,105,1) = "C"
            then do:   
                vdatmov  = substr(vlinha,81,6).
                vdephora = substr(vlinha,75,6).
                vvalor   = substr(vlinha,87,18).
                vd = substr(vdatmov,5,2) + "/" +
                substr(vdatmov,3,2) + "/" +
                substr(vdatmov,1,2). 
 
                create tt-arq.
                assign 
                    tt-arq.datmov   = date(vd)
                    tt-arq.dephora   = int(vdephora)
                    tt-arq.valdep    = int(vvalor) / 100 no-error.
            end.
        end.
        input close.
    end.

end procedure.

procedure lancamento.
    def var vagencia    like agenc.agecod.
    def var vconta      like ccor.ccornum.
    def var vcateg      as   int format "999".
    def var vcodhist    as   char format "x(4)".
    def var vhistori    as   char format "x(25)".
    def var vnumlanc    like depban.dephora format "9999999".
    def var vdtlanc     as   date format "99/99/9999".
    def var vvllanc     as   dec  format ">>>,>>>,>>9.99" .
    vagencia = substr(vregistro,18,04).
    vconta   = substr(vregistro,29,13).
    vcateg   = int(substr(vregistro,43,03)).
    vcodhist = substr(vregistro,46,04).
    vhistori = substr(vregistro,50,25).
    vnumlanc = int(substr(vregistro,75,06)).
    vdtlanc  = date(int(substr(vregistro,83,02)),
                    int(substr(vregistro,85,02)),
                    int("20" + substr(vregistro,81,02)) ).  /* aammdd */
    vvllanc  = dec(substr(vregistro,87,18)) / 100.
    create tt-arq. 
    assign tt-arq.datmov   =  vdtlanc .       
           tt-arq.dephora  = int(vnumlanc).               
           tt-arq.valdep   = vvllanc .
end procedure.

procedure le-extratos-itau.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    def var varq-aux as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/itau/B0" + string(day(vdt),"99") + 
                     string(month(vdt),"99") + 
                     substr(string(year(vdt)),4,1) + "A.RET".
                     
    else varquivo = "l:\itau\B0" + string(day(vdt),"99") +
                     string(month(vdt),"99") + 
                     substr(string(year(vdt)),4,1) + "A.RET".
                     
     
                if  search(varquivo) = ?
                then do:
                    
                    /*
                    message "Nao existe arquivo ..\extrato\extrcc90948.bbt ".
                    pause 3 no-message.
                    leave.
                    */
                    
                end.
                else do:
                
                    if opsys = "UNIX"
                    then do:
                        varq-aux = varquivo + ".uq".
                        unix silent 
 value("/usr/dlc/bin/quoter -d % " + varquivo + " > " + varquivo + ".q").
                    end.
                    else do:
                        varq-aux = varquivo + ".wq".
                        dos silent 
 value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varquivo + ".q").
                    end.
                    def var vlinha as char.
                    if search(varq-aux) <> ?
                    then do:
                    input from value(varq-aux).
                    repeat: 
                        import vlinha.
                        message vlinha. pause.
                        if substr(vlinha,1,1)  = "1" and
                           substr(vlinha,42,1) = "1" and
                           substr(vlinha,46,2) = "DP" and
                           substr(vlinha,105,1) = "C"
                        then do:   
                            vdatmov  = substr(vlinha,81,6).
                            vdephora = substr(vlinha,58,6) .
                           
                           
                            vvalor   = substr(vlinha,87,18).
                            vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,2).
                            if vdephora <> "" and (
                                substr(string(vdephora),1,1) = "0" or
                                substr(string(vdephora),1,1) = "1" or
                                substr(string(vdephora),1,1) = "2"
                                                  )              
                            then do:
                                create tt-arq.
                                assign 
                                    tt-arq.datmov   = date(vd)
                                    tt-arq.dephora   = int(vdephora)
                                    tt-arq.valdep    = int(vvalor) / 100.
                                  /*  message "hora" int(vdephora). */
                            end.
                        end.
                    end.
                    input close.
                    
                    if opsys = "UNIX"
                    then unix silent value("rm " + varq-aux + " -f").
                    else dos silent value("delete " + varq-aux). 
                    end.
                end.

end procedure.

procedure le-extratos-bradesco.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/bradesco/CC" + string(day(vdt),"99") + 
                     string(month(vdt),"99") /*+
                     substr(string(year(vdt)),4,1)*/
                     + "A00.RET".
    else varquivo = "l:\bradesco\CC" + string(day(vdt),"99") +
                     string(month(vdt),"99") /*+
                     substr(string(year(vdt),"9999"),4,1)*/
                     + "A00.RET".
     
       
                if  search(varquivo) = ?
                then do:
                    /*
                    message "Nao existe arquivo ..\extrato\extrcc90948.bbt ".
                    pause 3 no-message.
                    leave.
                    */
                end.
                /*else if varquivo = "/admcom/bradesco/CC2910A00.RET"
                then*/
                else do:
                    if opsys = "UNIX"
                    then unix silent 
 value("/usr/dlc/bin/quoter -d % " + varquivo + " > ext.br ").
                    else dos silent 
 value("c:\dlc\bin\quoter -d % " + varquivo + " > ext.br ").

                    def var vlinha as char.
                    input from ext.br no-echo.
                    repeat: 
                        import unformatted vlinha.
                        if substr(vlinha,1,1)  = "1" and
                           substr(vlinha,42,1) = "1" and
                           substr(vlinha,105,1) = "C"
                        then do:   
                            
                            vdatmov  = substr(vlinha,81,6).
                            vdephora = substr(vlinha,125,5) .
                            vvalor   = substr(vlinha,87,18).
                            vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,2). 
                            create tt-arq.
                            assign 
                               tt-arq.datmov   = date(vd)
                               tt-arq.dephora   = int(vdephora)
                               tt-arq.valdep    = int(vvalor) / 100 no-error.
                        end.
                        else if substr(vlinha,170,1) = "C" and
                                substr(vlinha,226,3) = "seq"
                        then do:
                            vdatmov  = substr(vlinha,136,8).
                            vdephora = substr(vlinha,229,5).
                            vvalor   = substr(vlinha,152,18).
                            vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,4). 
                            
                              
                            do on error undo:  
                                create tt-arq.
                                assign 
                                    tt-arq.datmov   = date(vd)
                                    tt-arq.dephora   = int(vdephora)
                                    tt-arq.valdep    = 
                                            int(vvalor) / 100 no-error.
                            end.
                        end.
                    end.
                    input close.
                end.

end procedure.


procedure le-extratos-sicredi.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    def var varquivo2 as char.
    def var vseq as int.
    def var vi as int.
    
    if opsys = "UNIX"
    then assign
         varquivo = "/admcom/extrato/sicredi/lebes" + string(day(vdt),"99") + 
                     string(month(vdt),"99")
                     + ".prn"
         varquivo2 = "/admcom/extrato/sicredi/lebes" + string(day(vdt),"99") +
                     string(month(vdt),"99")
                     + ".prn.imp".
    else assign
         varquivo = "l:\extrato\sicredi\lebes" + string(day(vdt),"99") +
                     string(month(vdt),"99")
                     + ".prn"
         varquivo2 = "l:\extrato\sicredi\lebes" + string(day(vdt),"99") +
                     string(month(vdt),"99")
                     + ".prn.imp".
                     
                if  search(varquivo) = ?
                then do:
                    /*
                    message "Nao existe arquivo ..\extrato\extrcc90948.bbt ".
                    pause 3 no-message.
                    leave.
                    */
                end.
                else do:
                    
                    if opsys = "UNIX"
                    then unix silent 
 value("/usr/dlc/bin/quoter -d % " + varquivo + " > " + varquivo2).
                    else dos silent 
 value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varquivo2).
                    
                    def var vlinha as char.
                    input from value(varquivo) no-echo.
                    vi = 0.
                    bl_import_sicredi:
                    repeat: 
                        vi = vi + 1.
                        /*
                        import unformatted vlinha.
                        */
                        if vi = 1
                        then import unformatted vlinha.
                        else if vi > 1
                        then do:
                            
                            import vseq vdatmov vvalor vdephora.
                            
                            /*****
                            vdatmov  = substr(vlinha,3,10). 
                            vdephora = trim(substr(vlinha,27,14)). 
                            vvalor   = trim(substr(vlinha,16,10)). 
                            
                            vdephora = trim(substring(vdephora,3,7)).
                            
                            /*
                            vd = substr(vlinha,5,2) + "/" +
                                 substr(vlinha,8,2) + "/" +
                                 substr(vlinha,11,4). 
                             */
                            *****/ 

                            if length(vdephora) > 7
                            then vdephora = substr(vdephora,3,7). 
                        
                            run p-converte-valor (input vvalor,
                                                  output vvalor).

                            do vint-cont = 1 to length(vdephora):
                        
                                if substring(vdephora,vint-cont,1) <> "0"
                                    and substring(vdephora,vint-cont,1) <> "1"
                                    and substring(vdephora,vint-cont,1) <> "2"
                                    and substring(vdephora,vint-cont,1) <> "3"
                                    and substring(vdephora,vint-cont,1) <> "4"
                                    and substring(vdephora,vint-cont,1) <> "5"
                                    and substring(vdephora,vint-cont,1) <> "6"
                                    and substring(vdephora,vint-cont,1) <> "7"
                                    and substring(vdephora,vint-cont,1) <> "8"
                                    and substring(vdephora,vint-cont,1) <> "9"
                                then next bl_import_sicredi.

                            end.
                        

                            create tt-arq.
                            assign 
                               tt-arq.datmov   = date(string(vdt))
                               tt-arq.dephora  = int(vdephora) 
                               tt-arq.valdep    = dec(vvalor)  no-error.
                               
                        end. /*if vi*/
                    end.
                    input close.
                end.

end procedure.

procedure p-converte-valor:

   def input  parameter ipcha-campo as character.
   def output parameter opcha-retorno as character.
        
   assign opcha-retorno = trim(ipcha-campo).
            
   assign opcha-retorno = replace(opcha-retorno,".","@").
                
   assign opcha-retorno = replace(opcha-retorno,",",".").
                    
   assign opcha-retorno = replace(opcha-retorno,"@",",").
                        
end procedure.
                        
