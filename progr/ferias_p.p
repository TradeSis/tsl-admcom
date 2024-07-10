{admcab.i}

def var vaux-valor as char.

def var vmes as int format "99".
def var vano as int format "9999".
def var varquivo as char format "x(15)".
def var vip as char.
def var varq as char.
def var vetbcod like estab.etbcod.
def var vfuncod like func.funcod.
def var vfunnom like func.funnom.
def var vdtven  like titluc.titdtven.
def var vvalor  like titluc.titvlcob.
def var vtitnum like titluc.titnum.

def var vetb like estab.etbcod.                    

def temp-table tt-folha
    field etbcod like estab.etbcod
    field funcod like func.funcod
    field funnom like func.funnom
    field titdtven like titluc.titdtven
    field titvlcob like titluc.titvlcob
    field titnum   like titluc.titnum
    field clifor like titluc.clifor
    field titsit like titluc.titsit.
        
def temp-table tt-estab
    field etbcod like estab.etbcod
        index ind-1 etbcod.
                    
def temp-table tt-erro
    field etbcod like estab.etbcod.

def var vfor-cod like forne.forcod.
def var vsit like titluc.titsit.   
l1:
repeat:
    
    vetb = 0.
    update vetb at 1 label "Filial" with frame f1 side-label width 80
        title " Importa arquivo de FERIAS modalidade FER "
          .
    if vetb = 0
    then display "Geral" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetb no-lock no-error.
        display estab.etbnom no-label with frame f1.
    end.
    vmes = month(today).
    vano = year(today).
    
    update vmes label "Mes"
           vano label "Ano"
                with frame f1.
          
    if opsys = "UNIX"
    then varquivo = "/admcom/folha/fer" + string(vmes,"99") +            
                         string(vano,"9999") + ".txt".
    else varquivo = "l:\folha\fer" +  string(vmes,"99") + 
               string(vano,"9999") + ".txt".
    
    update varquivo label "Arquivo importar"  format "x(50)"
        with frame f1.
    
    if search(varquivo) = "" 
    then do:
        message "Arquivo nao encontrado".
        pause.
        undo, retry.
    end.
           
    for each tt-estab:
        delete tt-estab.
    end.
        
    for each tt-erro:
        delete tt-erro.
    end.
        
    for each tt-folha:
        delete tt-folha.
    end.        

    message "Importar arquivo: "  varquivo  update sresp.
    if not sresp
    then return.
   
    if opsys = "unix"
    then unix  
    value("quoter -d % " + varquivo + " > " + varquivo + ".rh").
    else dos silent 
    value("c:\dlc\bin\quoter -d % " + varquivo + " > " + varquivo + ".rh").

    varquivo = varquivo + ".rh".
    
    input from value(varquivo) no-echo.
    repeat:   
        
        import varq.

        if varq <> ""
        then do:
        vetbcod = int((substring(varq,1,3))).
        vfuncod = int((substring(varq,4,6))).
        vfunnom = substring(varq,10,29). 

        def var i-dtven as int.
        def var c-dtven as char.
        i-dtven = int(substring(varq,40,8)).
        
        c-dtven = string(i-dtven,"99999999").
        vdtven  = date(int((substring(c-dtven,3,2))),
                       int((substring(c-dtven,1,2))),
                       int((substring(c-dtven,5,4)))). 
                                              
        vtitnum = string(  day(vdtven),"99") + 
                  string(month(vdtven),"99") + 
                  string(year(vdtven),"9999").
    
        vaux-valor = "".
        vaux-valor = replace(substring(varq,49,9),",",".").
        vvalor = dec(trim(vaux-valor)).
        vfor-cod = int(substr(varq,58,6)).
        vsit = substr(varq,68,3).

        find first foraut where
                   foraut.forcod = vfor-cod no-lock no-error.
        if not avail foraut
        then do: 
            bell.
            message color red/with
            "Fornecedor para despesa" vfor-cod
            " nao cadastrado."
            view-as alert-box.
            leave l1.
        end.
                   
        create tt-folha.
        assign tt-folha.etbcod = vetbcod 
               tt-folha.funcod = vfuncod  
               tt-folha.funnom = vfunnom 
               tt-folha.titdtven = vdtven
               tt-folha.titvlcob = vvalor
               tt-folha.titnum   = vtitnum
               tt-folha.clifor   = vfor-cod
               tt-folha.titsit   = vsit.
        end.
        varq = "".
    end.    
    input close.

    for each tt-folha:
        if vetb = 0
        then.
        else if tt-folha.etbcod = vetb
             then.
             else delete tt-folha.
    end.

    find first tt-folha no-error.
    if not avail tt-folha
    then do:
        message "Nenhum registro encontrado". 
        pause.
        undo, retry.
    end.        

    for each tt-folha:
        find first tt-estab 
             where tt-estab.etbcod = tt-folha.etbcod no-error.
        if not avail tt-estab
        then do:
            create tt-estab.
            assign tt-estab.etbcod = tt-folha.etbcod.
        end.
        display tt-folha.etbcod
                tt-folha.funcod
                tt-folha.funnom
                tt-folha.titdtven
                tt-folha.titvlcob
                tt-folha.titnum.
    end.

    for each tt-estab:

        if connected ("banfin")
        then disconnect banfin.
        connect banfin -H erp.lebes.com.br -S sbanfin -N tcp -ld banfin 
                        no-error.
        
        find first tt-erro where tt-erro.etbcod = tt-estab.etbcod no-error.
        if not avail tt-erro
        then do:

            for each tt-folha where tt-folha.etbcod = tt-estab.etbcod:
                if tt-folha.clifor = 0 or
                   tt-folha.clifor = ?
                then next.
                find fin.titluc where titluc.empcod = 19    and
                                  titluc.titnat = yes   and
                                  titluc.modcod = "FER" and 
                                  titluc.etbcod = tt-folha.etbcod and
                                  titluc.clifor = tt-folha.clifor and
                                  titluc.titnum = tt-folha.titnum and
                                  titluc.titpar = tt-folha.funcod no-error.
                                  
                if not avail fin.titluc                  
                then do transaction: 
                    
                    create fin.titluc.  
                    assign fin.titluc.empcod = 19 
                           fin.titluc.modcod = "FER"
                           fin.titluc.clifor = tt-folha.clifor
                           fin.titluc.etbcod = tt-folha.etbcod   
                           fin.titluc.titnat = yes  
                           fin.titluc.titsit = tt-folha.titsit  
                           fin.titluc.titdtemi = today  
                           fin.titluc.titdtven = tt-folha.titdtven  
                           fin.titluc.titvlcob = tt-folha.titvlcob  
                           fin.titluc.cxacod   = 1  
                           fin.titluc.cobcod   = 1  
                           fin.titluc.evecod   = 10  
                           fin.titluc.datexp   = today  
                           fin.titluc.titobs[1] = tt-folha.funnom
                           fin.titluc.titnum = tt-folha.titnum
                           fin.titluc.titpar = tt-folha.funcod.
        
                    if tt-folha.clifor > 0 and
                       tt-folha.clifor <> ?
                    then titluc.clifor = tt-folha.clifor.
                    if tt-folha.titsit <> ""
                    then titluc.titsit = tt-folha.titsit.
                    if titluc.titsit = "PAG"
                    then assign
                        fin.titluc.titdtpag = fin.titluc.titdtven
                        fin.titluc.titvlpag = fin.titluc.titvlcob.
                    if fin.titluc.titsit = "PAG"
                    then do:
                        run paga-titluc.p(recid(fin.titluc)).
                    end.  
                end.
            end.
        end.
        if connected ("banfin")
        then disconnect banfin.
                
        pause 0.
    end.
    
    find first tt-erro no-error.
    if not avail tt-erro
    then message "Registros gerados com sucesso".
    else do:
        for each tt-erro:
            disp tt-erro with frame f-erro down
                            title "Filiais com problema de conexao".
        end.
    end.

end.