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
def new shared temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999" 
    field valdep    like depban.valdep 
    field datexp    like depban.datexp
    field extrato as char
    field arquivo as char
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

def var vdir-extrato as char.
def var vdir-extrato-banco as char.
vdir-extrato = "/admcom/extrato/".

def stream stela.

/****
    hide message no-pause.
    message "Importando Extratos dos Bancos. Aguarde ...".
    run le-extratos. 
    run le-extratos-bb.
    hide message no-pause.
****/


def temp-table tt-arqrel no-undo
    field etbcod like estab.etbcod
    field deposito as dec
    field pladat as date
    field aster as char format "x(13)"
    field bancod like depban.bancod
    field numban like banco.numban
    field banfan like banco.banfan
    field dephora like depban.dephora format "9999999"
    field valdep like depban.valdep
    .

def temp-table tt-estab
    field etbcod like estab.etbcod
    .
def var vdtaux as date.

def var vsel as char extent 3 format "x(15)"
    init["DEPOSITOS","  COFRES","  GERAL"].
    
def var vindex as int.

repeat:
    
    update vdt1 label "Periodo" colon 15
           " Ate "
           vdt2 no-label 
           vetb1 label "Filial" colon 15 format ">>9"
           "       Ate "
           vetb2 no-label format ">>9"
           vopcao label "Listagem Geral" format "Sim/Nao"
           vfec   label "Fechados"
            with frame f-data centered color blue/cyan side-label width 80.
        
    vindex = 0.        
    disp vsel with frame f-sel no-label 1 down
        centered.
    choose field vsel with frame f-sel.

    vindex = frame-index.
        
    for each tt-dep: delete tt-dep. end.
    for each tt-banco: delete tt-banco. end.
    for each tt-arq: delete tt-arq. end.
        
    if vindex = 1 or vindex = 3
    then
    do vdt = vdt1 - 20 to vdt2 + 20:
        
        vdir-extrato-banco = vdir-extrato + "itau/"
                + "itau" + string(vdt,"999999") + ".txt" .
        run le-extratos-itau.
        
        vdir-extrato-banco = vdir-extrato + "bradesco/"
                + "bradesco" + string(vdt,"999999") + ".txt" .
        run le-extratos-bradesco.
        
        vdir-extrato-banco = vdir-extrato + "sicredi/"
                + "sicredi" + string(vdt,"999999") + ".csv" .
        run le-extratos-sicredi.

        vdir-extrato-banco = vdir-extrato + "banrisul/"
                + "banrisul" + string(vdt,"999999") + ".txt" .
        run le-extratos-banrisul.

        vdir-extrato-banco = vdir-extrato + "cef/"
                + "cef" + string(vdt,"999999") + ".txt" .
        run le-extratos-CEF.
        /*run cicoob-cef.p(vdt). 
        */
        vdir-extrato-banco = vdir-extrato + "bb/"
                + "bb" + string(vdt,"999999") + ".txt" .
        run le-extratos-bb.
        
    end.
    if vindex = 2 or
       vindex = 3
    then do:   
        run ws-brinks.
        run ws-protege.
    end.
        
    for each estab where estab.etbcod >= vetb1 and
                         estab.etbcod <= vetb2 no-lock:
                         
        if estab.etbcod >= 900 or estab.etbcod = 22
        or {conv_igual.i estab.etbcod} 
        then next.
     
        if vindex = 2
        then do:
            find first tt-estab where tt-estab.etbcod = estab.etbcod no-error.
            if not avail tt-estab
            then next.
        end.
        do vdata = vdt1 to vdt2:

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
                    if vindex = 2 and
                       depban.bancod <> 41
                    then next.              
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


    message "Deseja imprimir relatorio" update sresp.
    if sresp
    then do:
               
        varquivo = "/admcom/relat/dep" + string(time).
        
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
         
            display tt-dep.deposito format ">>>,999.99"
                    tt-dep.pladat column-label "Data Dep."
                        with frame f2 centered down width 200.
                
            create tt-arqrel .
            assign  
                    tt-arqrel.etbcod = tt-dep.etbcod
                    tt-arqrel.deposito = tt-dep.deposito
                    tt-arqrel.pladat = tt-dep.pladat
                    .
            
            for each depban where depban.etbcod = tt-dep.etbcod and
                                  depban.datmov = tt-dep.pladat 
                                        no-lock break by depban.etbcod
                                                  by depban.datmov.

                if vindex = 2 and
                   depban.bancod <> 41
                then next. 
                vaster = " ".
                find first tt-arq where 
                           tt-arq.dephora = depban.dephora and
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
                               bdepban.dephora = depban.dephora and
                               recid(bdepban) <> recid(depban) no-lock no-error.
                    if avail bdepban and bdepban.datmov > today - 30
                    then vaster = " " + string(bdepban.datmov,"99/99/9999") +
                                  " #". 
                    else do:
                        vaster = "            *". 
                
                        /*****/
                        find confdepb where 
                                confdepb.etbcod  = depban.etbcod and
                                confdepb.dephora = depban.dephora and
                                confdepb.datexp  = depban.datexp
                                no-lock no-error.
                        if not avail confdepb
                        then do:        
                        create confdepb.
                        assign
                            confdepb.etbcod = depban.etbcod
                            confdepb.bancod = depban.banco
                            confdepb.valdep = depban.valdep
                            confdepb.datexp = depban.datexp
                            confdepb.datmov = depban.datmov
                            confdepb.dephora = depban.dephora
                            confdepb.moecod = depban.moecod
                            confdepb.campo1 = depban.campo1
                            confdepb.campo2 = depban.campo2
                            confdepb.campo3 = depban.campo3
                            confdepb.compo4 = depban.compo4
                            confdepb.arquivo = tt-arq.arquivo
                            confdepb.extrato = tt-arq.extrato
                            confdepb.datconf = today
                            confdepb.horconf = time
                            .
                        
                        end.
                        /*********/
                    end.    
                end.
                else do:
                    find confdepb where
                         confdepb.etbcod  = depban.etbcod and
                         confdepb.dephora = depban.dephora and
                         confdepb.datexp  = depban.datexp
                         no-lock no-error.
                    if avail confdepb
                    then vaster = "            *".
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
                  
                create tt-arqrel .
                assign  
                    tt-arqrel.etbcod = tt-dep.etbcod
                    tt-arqrel.deposito = tt-dep.deposito
                    tt-arqrel.pladat = tt-dep.pladat
                    tt-arqrel.aster = vaster
                    tt-arqrel.bancod = depban.bancod
                    tt-arqrel.numban = banco.numban
                    tt-arqrel.banfan = banco.banfan
                    tt-arqrel.dephora = depban.dephora
                    tt-arqrel.valdep = depban.valdep
                    .
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
        /*
        if opsys = "unix"
        then os-command silent lpr value(fila + " " + varquivo).
        else os-command silent type value(varquivo) > prn.
        */
    end.
        
        varquivo = "/admcom/relat/confdep-" + string(time) + ".csv".
        output to value(varquivo) no-echo.
        put ";;;;Documento;Valor" skip.
        for each tt-arqrel where tt-arqrel.etbcod > 0 no-lock
                    by tt-arqrel.etbcod by tt-arqrel.pladat:
            put unformatted
                    tt-arqrel.etbcod
                    ";"
                    replace(string(tt-arqrel.deposito,">>>>>>>9.99"),".",",")
                    ";"
                    tt-arqrel.pladat
                    ";" 
                    tt-arqrel.aster 
                    ";"
                    tt-arqrel.bancod 
                    ";"
                    tt-arqrel.numban 
                    ";"
                    tt-arqrel.banfan 
                    ";"
                    tt-arqrel.dephora
                    ";" 
                    replace(string(tt-arqrel.valdep,">>>>>>>>9.99"),".",",")
                    skip.
        end.
        put "Banco;;;Valor" skip.
        for each tt-banco use-index i1:
            find first banco where
                       banco.bancod = tt-banco.banco
                       no-lock no-error.
            put tt-banco.banco
                ";"
                banco.numban
                ";"
                banco.banfan
                ";"
                replace(string(tt-banco.valor,">>>>>>>>9.99"),".",",")
                skip
                .
                
        end.
 
        output close.

        varquivo = "l:~\relat~\confdep-" + string(time) + ".csv".
        
        message color red/with
        "Arquivo CSV gerado:" skip
        varquivo
        view-as alert-box.
        
        return.
        
end.

def temp-table tt-base
    field arquivo as char.

procedure le-extratos-CEF.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    def var varq-aux as char.
    def var varq as char.
    def var vdt as date.
    def var vlinha as char.
    
    for each tt-base: delete tt-base. end.
    if search(vdir-extrato-banco) = ?
    then.
    else do:
        create tt-base.
        tt-base.arquivo = vdir-extrato-banco.
    
        for each tt-base.
            if search(tt-base.arquivo) = ?
            then next.
            input from value(tt-base.arquivo).
            repeat:
                import unformatted vlinha.
                if length(vlinha) = 29
                then do:
                    assign
                        vdatmov  = substr(vlinha,1,10)
                        vdephora = substr(vlinha,12,6) 
                        vvalor   = substr(vlinha,18,12)
                        vd = vdatmov.

                    if vdephora <> "" 
                    then do:
                        create tt-arq.
                        assign
                            tt-arq.datmov   = date(vd)
                            tt-arq.dephora   = int(vdephora)
                            tt-arq.valdep    = int(vvalor) / 100
                            tt-arq.extrato   = vlinha
                            tt-arq.arquivo   = vdir-extrato-banco
                            .
                    end.
                end.
                else do:
                    bell.
                    message color red/with
                    "Arquivo CEF com problema de layout." skip
                    "Verificar formato do arquivo."
                    view-as alert-box.
                    leave.
                end.
                
                /****
                if substr(vlinha,1,1) = "1"
                then do:
                    assign
                        vdatmov  = substr(vlinha,111,6)
                        vdephora = substr(vlinha,66,8) 
                        vvalor   = substr(vlinha,153,13)
                        vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,2).
                    if vdephora <> "" and 
                        (substr(string(vdephora),1,1) = "0" or
                         substr(string(vdephora),1,1) = "1")
                    then do:
                        create tt-arq.
                        assign
                            tt-arq.datmov   = date(vd)
                            tt-arq.dephora   = int(vdephora)
                            tt-arq.valdep    = int(vvalor) / 100
                            tt-arq.extrato   = vlinha
                            tt-arq.arquivo   = vdir-extrato-banco
                            .
                    end.
                end.
                *****/
                
            end.
            input close.
        end.
    end.
end procedure.

procedure le-extratos-bb.
    def var vdigitos as int.
    def var vaux-arq as char.
    def var varquivo as char.
    if search(vdir-extrato-banco) = ?
    then.
    else do:
        input from value(vdir-extrato-banco) no-echo.
        bl_import:
        repeat: 
                    
            assign vdatmov = ""
                               vdephora = ""
                               vvalor   = "".

            import unformatted vlinhabb.
            vlinhabb = trim(vlinhabb).
            if  substring(vlinhabb,58,3) = "830" and
                substring(vlinhabb,128,1) = "C"
            then do:
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,99,13)
                       vvalor   = substring(vlinhabb,119,8)
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
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato   = vlinhabb
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end.          
            else if  substring(vlinhabb,58,3) = "631" and
                substring(vlinhabb,128,1) = "C"       
            then do:
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,99,13)
                       vvalor   = substring(vlinhabb,119,8)
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
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato   = vlinhabb
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end.
            else if  substring(vlinhabb,58,3) = "910" and
                substring(vlinhabb,128,1) = "C"       
            then do:
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,99,13)
                       vvalor   = substring(vlinhabb,119,8)
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
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato   = vlinhabb
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end.
            else if  substring(vlinhabb,58,3) = "911" and
                substring(vlinhabb,128,1) = "C"       
            then do:
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,99,13)
                       vvalor   = substring(vlinhabb,119,8)
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
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato   = vlinhabb
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end.                  
            else if  substring(vlinhabb,58,3) = "912" and
                substring(vlinhabb,128,1) = "C"       
            then do:
                assign vdatmov = trim(substring(vlinhabb,1,15))
                       vdephora = substring(vlinhabb,99,13)
                       vvalor   = substring(vlinhabb,119,8)
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
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato   = vlinhabb
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end. 
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
    
    if  search(vdir-extrato-banco) = ?
    then.
    else do:
        /***
        if opsys = "UNIX"
        then unix silent 
            value("/usr/dlc/bin/quoter -d % " + varquivo + " > " + varquivo1).
        else dos silent 
            value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varquivo1).
        ***/
        input from value(vdir-extrato-banco) no-echo.
        repeat: 
            import unformatted vlinha.
            
            if substr(vlinha,1,1)  = "1" and
               substr(vlinha,42,1) = "1" and
               substr(vlinha,105,1) = "C"
            then do:   
                vdatmov  = substr(vlinha,81,6).
                vdephora = substr(vlinha,75,8).
                vdephora = substr(string(int(vdephora),"99999999"),1,6).
                vvalor   = substr(vlinha,87,18).
                vd = substr(vdatmov,5,2) + "/" +
                substr(vdatmov,3,2) + "/" +
                substr(vdatmov,1,2). 
 
                create tt-arq.
                assign 
                    tt-arq.datmov   = date(vd)
                    tt-arq.dephora   = int(vdephora)
                    tt-arq.valdep    = int(vvalor) / 100 
                    tt-arq.extrato = vlinha
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
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
       
    if  search(vdir-extrato-banco) = ?
    then.
    else do:
        
        def var vlinha as char.
        input from value(vdir-extrato-banco).
        repeat: 
                        import unformatted vlinha.
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
                                 tt-arq.valdep    = int(vvalor) / 100 
                                 tt-arq.extrato = vlinha
                                 tt-arq.arquivo   = vdir-extrato-banco
                                 .
                            end.     
                        end.
                        if substr(vlinha,1,1)  = "3" and
                           substr(vlinha,177,3)  = "CEI" and
                           substr(vlinha,109,2) = "DP" and
                           substr(vlinha,169,1) = "C"
                        then do:   
                            vdatmov  = substr(vlinha,143,8).
                            vdephora = substr(vlinha,185,6) .
                            vvalor   = substr(vlinha,151,18).
                            vd = vdatmov.
                            
                            if vdephora <> "" and (
                             substr(string(vdephora),1,1) = "0" or
                             substr(string(vdephora),1,1) = "1" or
                             substr(string(vdephora),1,1) = "2" or
                             substr(string(vdephora),1,1) = "3" or
                             substr(string(vdephora),1,1) = "4" or
                             substr(string(vdephora),1,1) = "5" or
                             substr(string(vdephora),1,1) = "6" or
                             substr(string(vdephora),1,1) = "7" or
                             substr(string(vdephora),1,1) = "8" or
                             substr(string(vdephora),1,1) = "9" 
                              )
                            then do:
                              create tt-arq.
                              assign 
                                 tt-arq.datmov   = date(vd)
                                 tt-arq.dephora   = int(vdephora)
                                 tt-arq.valdep    = int(vvalor) / 100 
                                 tt-arq.extrato = vlinha
                                 tt-arq.arquivo   = vdir-extrato-banco
                                 .
                            end.     
                        end.

        end.
        input close.
    end.

end procedure.

procedure le-extratos-bradesco.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
       
    if  search(vdir-extrato-banco) = ?
    then.
    else do:
        
        def var vlinha as char.
        input from value(vdir-extrato-banco) no-echo.
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
                        else if substr(vlinha,169,1) = "C" and
                                substr(vlinha,225,3) = "seq"
                        then do:
                            vdatmov  = substr(vlinha,135,8).
                            vdephora = substr(vlinha,228,5).
                            vvalor   = substr(vlinha,151,18).
                            vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,4). 
                            
                              
                            do on error undo:  
                                create tt-arq.
                                assign 
                                    tt-arq.datmov   = date(vd)
                                    tt-arq.dephora   = int(vdephora)
                                    tt-arq.valdep    = 
                                            int(vvalor) / 100 
                                    tt-arq.extrato = vlinha
                                    tt-arq.arquivo   = vdir-extrato-banco
                                            .
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
    def var varquivo  as char.
    def var varquivo2 as char.
    def var vseq as int.
    def var vi as int.
    
       
    if  search(vdir-extrato-banco) = ?
    then.
    else do:

        def var vlinha as char.
        input from value(vdir-extrato-banco) no-echo.
        repeat:
            import unformatted vlinha.
            if length(vlinha) > 70 and num-entries(vlinha,";") > 2
            then do:
                vdephora = entry(3,vlinha,";").
                if length(vdephora) > 7
                then vdephora = substr(vdephora,3,7).
                
                if substr(vdephora,1,1) <> "0" and
                   substr(vdephora,1,1) <> "1" and
                   substr(vdephora,1,1) <> "2" and
                   substr(vdephora,1,1) <> "3" and
                   substr(vdephora,1,1) <> "4" and
                   substr(vdephora,1,1) <> "5" and
                   substr(vdephora,1,1) <> "6" and
                   substr(vdephora,1,1) <> "7" and
                   substr(vdephora,1,1) <> "8" and
                   substr(vdephora,1,1) <> "9" 
                then next.
                   
                vvalor = entry(4,vlinha,";").
                vvalor = replace(vvalor,".","").
                vvalor = replace(vvalor,",",".").

                create tt-arq.
                assign 
                    tt-arq.datmov   = date(string(vdt))
                    tt-arq.dephora  = int(vdephora)
                    tt-arq.valdep    = dec(vvalor)
                    tt-arq.extrato = vlinha
                    tt-arq.arquivo   = vdir-extrato-banco
                    .
            end.
            else if num-entries(vlinha,";") < 3
                then do:
                    bell.
                    message color red/with
                    "Arquivo SICREDI com problema de layout." skip
                    "Verificar formato do arquivo." skip
                    vdir-extrato-banco
                    view-as alert-box.
                    leave.
                end.
        end.
    end.    
    
         /**********************
                    def var vlinha as char.
                    input from value(vdir-extrato-banco) no-echo.
                    vi = 0.
                    bl_import_sicredi:
                    repeat: 
                        vi = vi + 1.
                        if vi = 1
                        then import unformatted vlinha.
                        else if vi > 1
                        then do:
                        import vseq vdatmov vvalor vdephora.
                        
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
                               tt-arq.valdep    = dec(vvalor)
                               tt-arq.extrato = vlinha
                               tt-arq.arquivo   = vdir-extrato-banco
                                 .
                               
                        end. 
                    end.
                    input close.
                end.
        ****/
end procedure.


procedure p-converte-valor:

   def input  parameter ipcha-campo as character.
   def output parameter opcha-retorno as character.
        
   assign opcha-retorno = trim(ipcha-campo).
            
   assign opcha-retorno = replace(opcha-retorno,".","@").
                
   assign opcha-retorno = replace(opcha-retorno,",",".").
                    
   assign opcha-retorno = replace(opcha-retorno,"@",",").
                        
end procedure.
 
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






