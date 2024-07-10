def output parameter varq as char.

def temp-table tt-clien 
    field clicod like clien.clicod
    field endereco as char
    field exportar as log init yes
    index i1 clicod.

def var vcod as char format "x(18)".
def var sresp as log format "Sim/Nao".

def var vdata       as date.

def var vdt-aux     as date.

def var v-tipo      as char.

def var vclicod     as char.

def var vclien as log.
def var vforne as log.

assign vdata = today - 60.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if opsys = "unix" and sparam = "AniTA"
then varq = "/admcom/decision/clientes_" + string(today,"99999999") + ".txt".
else varq = "/file_server/clientes.txt".

def var cod-ibge as char.

def shared var vimporta-lista   as log format "Sim/Nao".

def var vcod-aux    as char.

def var vdesti like plani.desti .

def shared temp-table tt-imp
    field cod as char
        index idx01 cod.

/***  Leitura de notas fiscais acobertada de venda  ***/
do vdt-aux = vdata to today:

    for each tipmov /*where (tipmov.movtnot = yes
                  and tipmov.movtdeb = yes)
                   or tipmov.movtdc = 26*/ no-lock.

        if /*tipmov.movtdc <> 12
            and*/ tipmov.movtdc <> 48
            and tipmov.movtdc <> 52
            and tipmov.movtdc <> 46
            and tipmov.movtdc <> 26
            and tipmov.movtdc <> 5
            and tipmov.movtdc <> 81
        then next.     

        for each estab where estab.etbcod < 400 or estab.etbcod = 200 
                or estab.etbcod = 988 no-lock, 
            each plani where plani.etbcod = estab.etbcod
                 and plani.emite = estab.etbcod
                 and plani.movtdc  = tipmov.movtdc
                 /*and plani.desti   > 3 */
                 and plani.plaDat  = vdt-aux no-lock,
            first clien where clien.clicod = plani.desti no-lock:
            
            if tipmov.movtdc = 5 and plani.emite <> 200 /*and
               clien.tippes                               */
            then next.
            
            assign vcod-aux = "C" + string(clien.clicod,"9999999999") .
            /*
            if vimporta-lista                
            then do:
                
                if not can-find(first tt-imp
                        where tt-imp.cod = vcod-aux)
                    and not can-find(first tt-imp
                             where tt-imp.cod = string(clien.clicod))
                then next.                  
                
            end.
            */
            release tt-clien.
            vclien = no.
            vforne = no.
            vdesti = plani.desti.
            run participantes.
            if vclien = yes
            then do:
                find first tt-clien where tt-clien.clicod = plani.desti
                        no-lock no-error.
                if not avail tt-clien
                then do:
                    create tt-clien.
                    assign tt-clien.clicod = plani.desti.
                end.
            end.
        end.
    end. /* For each tipmov no-lock. */
end.                 

for each tt-imp.
    if substr(string(tt-imp.cod),1,1) = "C"
    then do:
        create tt-clien.
        tt-clien.clicod = int(substr(string(tt-imp.cod),2,10)).
    end.
end.
def var vcep as char.
             
def var vn as char.
vn = "1;2;3;4;5;6;7;8;9;0".
def var vi as int.       
def var vc as log.          

/****
for each tt-clien,
   
    first clien where clien.clicod = tt-clien.clicod no-lock:

    if clien.ciccgc = "" then tt-clien.exportar = no.
    if clien.clinom = "" then tt-clien.exportar = no.
    vc = no.
    do vi = 1 to num-entries(vn,";"):
        if substr(clien.ciccgc,1,1) = entry(vi,vn,";")
        then do:
            vc = yes.
            leave.
        end.
    end.
    if vc = no then tt-clien.exportar = no.
    assign cod-ibge = "".

    if clien.endereco[1] = "" or clien.endereco[1] = ?
    then do:
    
        release cliecom.
        find first cliecom where cliecom.clicod = clien.clicod
                                no-lock no-error.
        
        if avail cliecom and cliecom.endereco <> ""
        then tt-clien.endereco = cliecom.endereco.
        else do:
        
            release pedid.
            find last pedid where pedid.etbcod = 200
                                and pedid.pedtdc = 3
                                and pedid.clfcod = tt-clien.clicod
                                            no-lock no-error.
        
            if avail pedid    
            then find last pedecom where pedecom.etbcod = pedid.etbcod
                                     and pedecom.pedtdc = pedid.pedtdc
                                     and pedecom.pednum = pedid.pednum
                                                no-lock no-error.
                                                
            if avail pedecom and pedecom.endereco <> ""
            then tt-clien.endereco = pedecom.endereco.
            else tt-clien.endereco = "".
 
            
        end.
        
    end.
    else tt-clien.endereco = clien.endereco[1].
    if tt-clien.endereco = ""
    then tt-clien.exportar = no.    
end.
***/

output to value(varq).

for each tt-clien where tt-clien.exportar = yes,
    first clien where clien.clicod = tt-clien.clicod no-lock:

    if clien.ciccgc = "" then next.
    if clien.clinom = "" then next.
    vc = no.
    do vi = 1 to num-entries(vn,";"):
        if substr(clien.ciccgc,1,1) = entry(vi,vn,";")
        then do:
            vc = yes.
            leave.
        end.
    end.
    if vc = no then next.
    assign cod-ibge = "".

    put unformatted
        "C"
        clien.clicod         format "9999999999"           /* 002-018 */
        clien.ciccgc         format "x(18)" at 19          /* 019-036 */
        " " /*clien.ciinsc*/ format "x(20)"                /* 037-056 */
        " "                  format "x(14)"                /* 057-070 */
        clien.clinom         format "x(70)"                /* 071-140 */
        " "                  format "x(70)"                /* 141-210 */ .
    
    if clien.endereco[1] = ""
        or clien.endereco[1] = ?
     /* or length(clien.endereco[1]) < 5 */
    then do:
    
        release cliecom.
        find first cliecom where cliecom.clicod = clien.clicod
                                no-lock no-error.
        
        if avail cliecom and cliecom.endereco <> ""
        then do:

            assign v-tipo = "E"
                   vcep = replace(cliecom.cep,",","") .
            
            release munic.
            find first munic where 
                       munic.cidnom = cliecom.cidade and
                       munic.ufecod = cliecom.ufecod
                                no-lock no-error.
            if avail munic
            then cod-ibge = string(munic.cidcod).
            else cod-ibge = "".        

            put unformatted
                cliecom.endereco       format "x(50)"        /* 211-280 */
                string(cliecom.numero) format "x(10)"       
                cliecom.compl          format "x(10)"       
                cliecom.bairro         format "x(20)"        /* 281-300 */
                cliecom.cidade         format "x(50)"        /* 301-350 */
                cliecom.ufecod         format "x(02)"        /* 351-352 */
                vcep            format "x(08)"        /* 353-360 */.
        
        end.
        else do:
        
            release pedid.
            find last pedid where pedid.etbcod = 200
                                and pedid.pedtdc = 3
                                and pedid.clfcod = tt-clien.clicod
                                            no-lock no-error.
        
            if avail pedid    
            then find last pedecom where pedecom.etbcod = pedid.etbcod
                                     and pedecom.pedtdc = pedid.pedtdc
                                     and pedecom.pednum = pedid.pednum
                                                no-lock no-error.
                                                
            if avail pedecom and pedecom.endereco <> ""
            then do:
            
                assign v-tipo = "P"
                       vcep = replace(pedecom.cep,",","")
                       .
            
                release munic.
                find first munic where 
                           munic.cidnom = pedecom.cidade and
                           munic.ufecod = pedecom.uf
                                no-lock no-error.
                if avail munic
                then cod-ibge = string(munic.cidcod).
                else cod-ibge = "".        
                 
                put unformatted
                pedecom.endereco       format "x(50)"        /* 211-280 */
                string(pedecom.numero) format "x(10)"       
                pedecom.compl          format "x(10)"       
                pedecom.bairro         format "x(20)"        /* 281-300 */
                pedecom.cidade         format "x(50)"        /* 301-350 */
                pedecom.uf             format "x(02)"        /* 351-352 */
                vcep            format "x(08)"        /* 353-360 */.
        
            end.
            else do:
 
                put unformatted
                " "       format "x(50)"        /* 211-280 */
                " "       format "x(10)"       
                " "       format "x(10)"       
                " "       format "x(20)"        /* 281-300 */
                " "       format "x(50)"        /* 301-350 */
                " "       format "x(02)"        /* 351-352 */
                " "       format "x(08)"        /* 353-360 */.
            
            end.
            
        end.
        
    end.
    else do:
    
        assign v-tipo = "C"
               vcep = replace(clien.cep[1],",","")
                    .
    
        release munic.
        find first munic where 
                   munic.cidnom = clien.cidade[1] and
                   munic.ufecod = clien.ufecod[1]
                    no-lock no-error.
        if avail munic
        then cod-ibge = string(munic.cidcod).
        else cod-ibge = "".        

        put unformatted
        clien.endereco[1]       format "x(50)"        /* 211-280 */
        string(clien.numero[1]) format "x(10)"       
        clien.compl[1]          format "x(10)"       
        clien.bairro[1]         format "x(20)"        /* 281-300 */
        clien.cidade[1]         format "x(50)"        /* 301-350 */
        clien.ufecod[1]         format "x(02)"        /* 351-352 */
        vcep            format "x(08)"        /* 353-360 */.
    
    end.

        put unformatted
        "BRASIL"             format "x(20)"        /* 361-380 */
        " "                  format "x(12)"        /* 381-392 */
        cod-ibge             format "x(07)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        " "                  format "x(02)"        /* 420-422 */
        v-tipo               format "x(01)"        /* 423-423 */
        skip.

end.
output close.
              
        
procedure participantes:
    if plani.movtdc =  6 or
       plani.movtdc = 22 or
       plani.movtdc = 60 or
       plani.movtdc = 61 or
       plani.movtdc = 62 or
       plani.movtdc = 63 or
       plani.movtdc = 64 or
       plani.movtdc = 51 or
       plani.movtdc = 53 or
       (plani.movtdc = 5 and plani.emite = 200)
    then vclien = yes.
    else if plani.movtdc = 9 or
            plani.movtdc = 59
        then vforne = yes.
        else if plani.movtdc = 48
            then do:
                find clien where clien.clicod = vdesti no-lock no-error.
                if avail clien
                then vclien = yes.
                else do:
                    find forne where forne.forcod = vdesti no-lock no-error.
                    if avail forne
                    then vforne = yes.
                end.    
            end.    
            else do: 
                find forne where forne.forcod = vdesti no-lock no-error.
                if avail forne and plani.movtdc <> 5 and plani.movtdc <> 48
                then vforne = yes.
                else find clien where clien.clicod = vdesti no-lock no-error.
                if avail clien
                then vclien = yes.
            end.
end procedure.               
