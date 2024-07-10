{admdisparo.i}

def shared temp-table tt-clien         like ger.clien.
def shared temp-table tt-deposito      like ger.deposito.
def shared temp-table tt-func          like ger.func.
def shared temp-table tt-glopre        like ger.glopre.
def shared temp-table tt-serial        like ger.serial.

def buffer xestab for ger.estab.
def buffer btitcli for germatriz.titcli.
def buffer bclien  for germatriz.clien.
def var vdata-flag as date format "99/99/9999".                
def var vcliant    like germatriz.titcli.clicod.
def var i as int.
def var cont as int.
def var vlog1 as char.

vlog1 = "/usr/admcom/work/log." + string(day(today)) + string(month(today)).

def temp-table ttclicod
    field clicod like ger.clien.clicod
    index clien clicod.

def var vlog as char.
def var vdata as date.
def var vweek as i.

vweek = int(weekday(today)).
if vweek = 2 
then vdata = today - 3.
else vdata = today - 2.

vlog = "/usr/admcom/work/atuger" + string(time) + ".log".

find first ger.estab where ger.estab.etbcod = setbcod no-lock no-error.

for each ger.clien where ger.clien.datexp >= (vdata) 
                     and ger.clien.datexp <> ? no-lock :
    i = i + 1.
    create ttclicod.
    ttclicod.clicod = ger.clien.clicod.
end.

if ger.estab.datatu = ?
then do for xestab transaction.
    find xestab where recid(xestab) = recid(ger.estab) exclusive.
    xestab.datatu = 01/01/2001.
    vdata = vdata - 30.
end.

find current ger.estab no-lock.    

if ger.estab.datatu < today
then do:

    output to value(vlog1) append.
        put "Atuger.p - Im ClienteMatriz " + 
            string(time,"hh:mm:ss") skip.
    output close.
    cont = 0.

    /** ATUALIZA A TABELA DE CLIENTES DA LOJA A PARTIR DA MATRIZ:
        - MODIFICACOES DE REGISTROS E/OU CRIACAO DE NOVOS REGISTROS ****/
    for each germatriz.clien where 
             germatriz.clien.datexp <> ? and
             germatriz.clien.datexp >= (vdata) and 
             not can-find (first ttclicod where 
                           ttclicod.clicod = germatriz.clien.clicod) 
                no-lock : 
        
        cont = cont + 1.
        do transaction : 
            find first ger.clien where
                 ger.clien.clicod = germatriz.clien.clicod no-error.
            if not avail ger.clien
            then create ger.clien.
            else do:
                if ger.clien.datexp <> ? and
                   ger.clien.datexp > germatriz.clien.datexp
                then next.
            end.
        
            i = i + 1.
        
            output to value(vlog) append.
            put today format "99/99/9999" space(1) vdata
                " Import Cliente Matriz --> Loja ." 
                space(1)
                germatriz.clien.clicod
                space(1)
                germatriz.clien.clinom
                skip.
            output close.        

            {tt-clien.i ger.clien germatriz.clien}
            ger.clien.exportado = yes.
            
            find germatriz.carro where 
                    germatriz.carro.clicod = germatriz.clien.clicod 
                            no-lock no-error.
            if avail germatriz.carro
            then do:
                find ger.carro where ger.carro.clicod = germatriz.carro.clicod
                                                no-error.
                if not avail ger.carro
                then do:
                    create ger.carro.
                    assign ger.carro.clicod = germatriz.carro.clicod.
                end.
                assign ger.carro.carsit = germatriz.carro.carsit
                       ger.carro.datexp = germatriz.carro.datexp
                       ger.carro.carsit = germatriz.carro.carsit
                       ger.carro.modelo = germatriz.carro.modelo
                       ger.carro.marca  = germatriz.carro.marca
                       ger.carro.ano    = germatriz.carro.ano.
            end.           
            
            
        end.
    end.
    
    output to value(vlog1) append.
        put "Atuger.p - ClienteMatriz " cont  
            skip
            "Atuger.p - Im. Flag " 
            string(time,"hh:mm:ss") 
            skip. 
    output close.
    cont = 0.

    /**** ATIVAR CLIEN.FLAG DAS LOJAS
        SE EXISTIR TITULOS EM OUTRAS FILIAIS *****/
    vcliant = 0.
    for each germatriz.titcli where 
             germatriz.titcli.flag   = yes and 
             germatriz.titcli.dtexp >= vdata
             no-lock by germatriz.titcli.clicod:
        if vcliant = germatriz.titcli.clicod and vcliant <> 0 
        then next.
        cont = cont + 1.
        output to value(vlog) append.
        put today format "99/99/9999" space(1) vdata
            " Atualiz Flag do Cliente .... " 
            space(1)
            germatriz.titcli.clicod
            space(1)
            germatriz.titcli.etbcod
            skip.
        output close.        
        
        if germatriz.titcli.etbcod = setbcod
        then do:
            find first btitcli where 
                       btitcli.etbcod <> setbcod and 
                       btitcli.clicod = germatriz.titcli.clicod and
                       btitcli.flag   = yes no-lock no-error.
            if avail btitcli
            then do transaction : 
                find first ger.clien where 
                           ger.clien.clicod = germatriz.titcli.clicod 
                           no-error.
                ger.clien.flag = yes.
                vcliant = germatriz.titcli.clicod.
            end.
            else do transaction : 
                find first ger.clien where 
                           ger.clien.clicod = germatriz.titcli.clicod 
                           no-error.
                ger.clien.flag = no.
                vcliant = germatriz.titcli.clicod.
            end.   
        end.
        else do transaction :
            find first ger.clien where 
                       ger.clien.clicod = germatriz.titcli.clicod 
                       no-error.
            ger.clien.flag = yes.
            vcliant = germatriz.titcli.clicod.
        end.                  
    end.
    /********** Atualiza os Clientes que nao tem mais Titcli *********/
    
    if search("/usr/admcom/progr/clien.flag") <> ?
    then do:
        input from /usr/admcom/progr/clien.flag no-echo.
        set vdata-flag.
        input close.
    end.
    else do:
        output to /usr/admcom/progr/clien.flag.
        put today - 1 format "99/99/9999".
        output close.
        vdata-flag = today - 1.
    end.
    if vdata-flag <> today
    then do:
        for each ger.clien where ger.clien.flag = yes 
            use-index flag :
             cont = cont + 1.
            find first germatriz.titcli where 
                       germatriz.titcli.clicod = ger.clien.clicod
                       no-lock no-error.
            if not avail germatriz.titcli
            then do transaction : 
                ger.clien.flag = no.
            end.
        end.
        output to /usr/admcom/progr/clien.flag.
        put today.
        output close.
    end.
    for each germatriz.flag where germatriz.flag.datexp1 >= vdata no-lock .
    
        find first ger.flag where ger.flag.clicod = germatriz.flag.clicod
                            no-error.
        if not avail ger.flag
        then do :
            create ger.flag.
            ger.flag.clicod = germatriz.flag.clicod.
            ger.flag.flag1 = germatriz.flag.flag1.
            ger.flag.datexp1 = germatriz.flag.datexp1.
        end.
        else do :
            ger.flag.flag1 = germatriz.flag.flag1.
            ger.flag.datexp1 = germatriz.flag.datexp1.
        end.
    end.

    output to value(vlog1) append.
        put "Atuger.p - Flag " cont  
            skip
            "Atuger.p - Im. Func " 
            string(time,"hh:mm:ss") 
            skip.
    output close.

    cont = 0.
    for each germatriz.func where germatriz.func.fundtcad >= vdata 
                            no-lock .
    
        find first ger.func where ger.func.funcod = germatriz.func.funcod
                              and ger.func.etbcod = germatriz.func.etbcod
                            no-error.
        if not avail ger.func
        then do :
            create ger.func.
        end.
        cont = cont + 1.
        {tt-func.i ger.func germatriz.func}.
    end.
    output to value(vlog1) append.
        put "Atuger - Funcionario "  cont 
            skip
            "Atuger.p - Im. Glopre" 
            string(time,"hh:mm:ss") skip.
    output close.

    do for xestab transaction.
        find xestab where recid(xestab) = recid(ger.estab) exclusive.
        xestab.datatu = today.
    end.

end.
cont = 0.

do /*transaction*/ :
    for each tt-glopre:
       do transaction:
 
        find germatriz.glopre where 
                              germatriz.glopre.etbcod  = tt-glopre.etbcod and
                              germatriz.glopre.clicod  = tt-glopre.clicod and
                              germatriz.glopre.numero  = tt-glopre.numero and
                              germatriz.glopre.parcela = tt-glopre.parcela
                                                            no-error.
        if not avail germatriz.glopre
        then do:
            create germatriz.glopre.
            {tt-glopre.i germatriz.glopre tt-glopre}
        end.
        else do:
            if tt-glopre.glosit = "PAG"
            then assign germatriz.glopre.glosit = tt-glopre.glosit
                        germatriz.glopre.datexp = tt-glopre.datexp
                        germatriz.glopre.dtpag  = tt-glopre.dtpag.
        end.
        cont = cont + 1.
       end.
       delete tt-glopre.
    end.
end.

do /*transaction*/ :

    for each germatriz.glopre where germatriz.glopre.datexp = today no-lock:
       do transaction:
        find ger.glopre where ger.glopre.etbcod  = germatriz.glopre.etbcod and
                              ger.glopre.clicod  = germatriz.glopre.clicod and
                              ger.glopre.numero  = germatriz.glopre.numero and
                              ger.glopre.parcela = germatriz.glopre.parcela
                                                            no-error.
        if not avail ger.glopre
        then do:
            create ger.glopre.
            {tt-glopre.i ger.glopre germatriz.glopre}
        end.
        else do:
           if germatriz.glopre.glosit = "PAG"
           then assign ger.glopre.glosit = germatriz.glopre.glosit
                       ger.glopre.datexp = germatriz.glopre.datexp
                       ger.glopre.dtpag  = germatriz.glopre.dtpag.
        end.    
       end.
    end.
end.

output to value(vlog1) append.
    put "Atuger.p - GloPre " cont 
        skip
        "Atuger.p - Im. TabMen " 
        string(time,"hh:mm:ss") 
        skip.
output close.

cont = 0.

do transaction :
    for each germatriz.tabmen where germatriz.tabmen.datexp >= vdata
                    no-lock :
        cont = cont + 1.
        find first ger.tabmen where 
                   ger.tabmen.etbcod = germatriz.tabmen.etbcod and 
                   ger.tabmen.datexp = germatriz.tabmen.datexp 
                   no-error.
        if not avail ger.tabmen
        then do :
            create ger.tabmen.
        end.
        raw-transfer germatriz.tabmen to ger.tabmen.
        output to value(vlog) append.
            put today format "99/99/9999" space(1) vdata
                " Atualiz TabMen Matriz --> Loja ." 
                space(1)
                germatriz.tabmen.etbcod
                skip.
        output close.  
    end.
end.
output to value(vlog1) append.
    put "Atuger.p - Tabmen " cont 
        skip 
        "Atuger.p - Im. Serial " 
        string(time,"hh:mm:ss") 
        skip.
output close.
cont = 0.

do transaction :
    for each tt-serial :
        cont = cont + 1.
        find first germatriz.serial where
                   germatriz.serial.etbcod = tt-serial.etbcod and 
                   germatriz.serial.cxacod = tt-serial.cxacod and
                   germatriz.serial.redcod = tt-serial.redcod 
                   no-error.
        if not avail germatriz.serial
        then do:
            create germatriz.serial.
            {tt-serial.i germatriz.serial tt-serial}.
        end.
    end.
end.

output to value(vlog1) append.
    put "Atuger.p - Serial" cont 
        skip
        "Atuger.p - Im. Deposito " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

do transaction :
    for each tt-deposito :
        cont = cont + 1.
        find first germatriz.deposito where
                   germatriz.deposito.etbcod = tt-deposito.etbcod and 
                   germatriz.deposito.datmov = tt-deposito.datmov
                   no-error.
        if not avail germatriz.deposito
        then do:
            create germatriz.deposito.
            {tt-deposito.i germatriz.deposito tt-deposito}.
        end.
    end.
end.

output to value(vlog1) append.
    put "Atuger.p - Deposito " cont 
        skip
        "Atuger.p - Im. Cliente " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

for each tt-clien:
    do transaction:
        find first germatriz.clien where
             germatriz.clien.clicod = tt-clien.clicod no-error.
        if not avail germatriz.clien
        then create germatriz.clien.
        else do:
            if germatriz.clien.datexp <> ? and
               germatriz.clien.datexp > tt-clien.datexp
            then do:
                delete tt-clien.
                next.
            end.
        end.
    
        cont = cont + 1.
        {tt-clien.i germatriz.clien tt-clien}
        
        /************ carro *************/
        
        find ger.carro where ger.carro.clicod = tt-clien.clicod 
                            no-lock no-error.
        if avail ger.carro
        then do:
            find germatriz.carro where 
                    germatriz.carro.clicod = ger.carro.clicod no-error.
            if not avail germatriz.carro
            then do: 
                create germatriz.carro.
                assign germatriz.carro.clicod = ger.carro.clicod.
            end.
            assign germatriz.carro.carsit = ger.carro.carsit
                   germatriz.carro.datexp = ger.carro.datexp
                   germatriz.carro.carsit = ger.carro.carsit
                   germatriz.carro.modelo = ger.carro.modelo
                   germatriz.carro.marca  = ger.carro.marca
                   germatriz.carro.ano    = ger.carro.ano.
        end.           
            
        
        /*******************************/
        
    
        find first ger.clien where
             ger.clien.clicod = tt-clien.clicod no-error.
        ger.clien.exportado = yes.

        output to value(vlog) append.
            put today format "99/99/9999" space(1)
                " Atualiz Cliente Loja --> Matriz ." 
                space(1)
                tt-clien.clicod
                space(1)
                tt-clien.clinom
                skip.
        output close.        
        delete tt-clien.
    end.
end.

output to value(vlog1) append.
    put "Atuger.p - Cliente " cont 
        skip
        "Atuger.p - Finalizando " 
        string(time,"hh:mm:ss") skip.
output close.
cont = 0.

output to /usr/admcom/ultimo.ini.
    put time.
output close
