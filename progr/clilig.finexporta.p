def new global shared var varq as char.

def var v as int.
def var vdel as int.

def var x as int.
pause 0 before-hide.

def var tot-clientes as int. 

def temp-table ttcli
    field clicod    like clien.clicod
    index clicod    is primary unique clicod.
def temp-table ttdeletar
    field rec    as recid
    field clicod like clien.clicod
    index clicod clicod.
    
for each ttcli.
    delete ttcli.
end.
FOR EACH ttdeletar.
    delete ttdeletar.
end.
def var vtoday as date.

do vtoday = today - 25 to today.
    for each finexporta where dataexp   = ?             and
                              datatrig  =     vtoday    and  
                              horatrig  = day(vtoday)   and
                              tabela    = "titulo"      
                              no-lock.
        find titulo where recid(titulo) = finexporta.tabela-recid 
                    no-lock no-error.
        if not avail titulo
        then do.
            create ttdeletar.
            ttdeletar.rec = recid(finexporta).
            next.
        end.
        find ttcli where ttcli.clicod = titulo.clifor no-error.
        if not avail ttcli
        then do.
            create ttcli.
            ttcli.clicod = titulo.clifor.
            tot-clientes = tot-clientes + 1.
        end.
        create ttdeletar. 
        ttdeletar.rec = recid(finexporta).       
        ttdeletar.clicod = titulo.clifor.
        x = x + 1.
        if x mod 10000 = 0
        then do.
            output to value(varq)  append .
            put unformatted     "criando  " 
                                datatrig " " 
                                x " "  
                                tot-clientes " "  
                                titulo.clifor " " 
                                string(time,"HH:MM:SS") skip.
            output close.
        end.
    end.                          
end.
output to value(varq)  append .
put unformatted     "Total = " 
                    x  " Clientes = " 
                    tot-Clientes  " " 
                    string(time,"HH:MM:SS")  
skip.
output close.


def var t as int.
for each ttcli.
    t = t + 1.
    def var ff as log.
    ff = no.
    if t mod 10000 = 0
    then      do.
        output to value(varq)  append .
         put unformatted 
                        "rodando por clientes "  
                        ttcli.clicod " "  
                        t " " 
                        string(time,"HH:MM:SS") " ".
        ff = yes.    
        output close.
    end.
    run /admcom/progr/clilig_porcliente.p (ttcli.clicod).
    for each ttdeletar where ttdeletar.clicod = ttcli.clicod. 
        find finexporta where recid(finexporta) = ttdeletar.rec no-error.
        vdel = vdel + 1.
        if avail finexporta
        then
        delete finexporta.
    end.
    if ff
    then      do.
        output to value(varq)  append .
         put unformatted
                    ttcli.clicod " " 
                    t " " 
                    string(time,"HH:MM:~SS")
                    " DEL " 
                    vdel " de " x " " vdel / x * 100 format ">>9.99%"
                    skip.
        output close.
    end.    
    delete ttcli.
end.
    
pause 3.
x = 0.              
for each ttdeletar. 
    find finexporta where recid(finexporta) = ttdeletar.rec no-error.
    x = x + 1.
    if x mod 10000 = 0 and avail finexporta
    then do.
        output to value(varq)  append .
         put unformatted "deletando " datatrig 
                                " " x " " string(time,"HH:MM:SS")  
                        skip.
        output close.
        if avail finexporta
        then
                delete finexporta.
    end.
end.
output to value(varq)  append . 
put unformatted x skip.
output close.

output to value(varq)  append .

put unformatted 
    skip(2)
    "TERMINOU " " " today format "99/99/9999"
            " " string(time,"HH:MM:~SS") skip(1).

output close.
