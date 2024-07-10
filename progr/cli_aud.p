def temp-table tt-clien 
    field clicod like clien.clicod
    index i1 clicod.

def var vcod as char format "x(18)".
def var varq as char.
def var sresp as log format "Sim/Nao".

def var vdata       as date.

def var vdt-aux     as date.

def var v-tipo      as char.

def var vclicod     as char.

assign vdata = today - 60.

if opsys = "unix" 
then varq = "/admcom/audit/clientes.txt".
else varq = "l:~\audit~\clientes.txt".

def var cod-ibge as char.

def shared var vimporta-lista   as log format "Sim/Nao".
def var vcod-aux    as char.

def shared temp-table tt-imp
    field cod as char
        index idx01 cod.



/*********
for each clien where clien.dtcad = today no-lock.
    find first tt-clien where
               tt-clien.clicod = clien.clicod 
               no-error.
    if not avail tt-clien
    then do:
        create tt-clien.
        tt-clien.clicod = clien.clicod.
    end.
end. 
for each cpclien where
         cpclien.datalt = today no-lock:
    find clien of cpclien no-lock no-error.
    if not avail clien then next.         

    find first tt-clien where
               tt-clien.clicod = clien.clicod 
               no-error.
    if not avail tt-clien
    then do:
        create tt-clien.
        tt-clien.clicod = clien.clicod.
    end.
end.
********/

/***  Leitura de notas fiscais acobertada de venda  ***/
do vdt-aux = vdata to today:

for each tipmov where (tipmov.movtnot = yes
                  and tipmov.movtdeb = yes)
                   or tipmov.movtdc = 26 no-lock.

    if tipmov.movtdc <> 5
        and tipmov.movtdc <> 12
         and tipmov.movtdc <> 48
         and tipmov.movtdc <> 52
         and tipmov.movtdc <> 26
    then next.     

for each estab where estab.etbcod < 189 or estab.etbcod = 200 
                or estab.etbcod = 988 no-lock, 
    each plani where plani.etbcod = estab.etbcod
                 and plani.emite = estab.etbcod
                 and plani.movtdc  = tipmov.movtdc
                 and plani.desti   > 3 
                 and plani.plaDat  = vdt-aux no-lock,
    /*
    first planiaux where planiaux.movtdc      = plani.movtdc
                     and planiaux.etbcod      = plani.etbcod
                     and planiaux.placod      = plani.placod
                     and planiaux.emite       = plani.emite
                     and planiaux.numero      = plani.numero
                     and planiaux.serie       = plani.serie
                     and planiaux.nome_campo  = "NOTA-ACOBERTADA"
                              no-lock:  */


    first clien where clien.clicod = plani.desti no-lock:


    assign vcod-aux = "C" + string(clien.clicod,"9999999999") .

    if vimporta-lista                
    then do:
                
        if not can-find(first tt-imp
                        where tt-imp.cod = vcod-aux)
            and not can-find(first tt-imp
                             where tt-imp.cod = string(clien.clicod))
        then next.                  
                
    end.
    
    release tt-clien.
    find first tt-clien where tt-clien.clicod = plani.desti
                        no-lock no-error.
    if not avail tt-clien
    then do:
        
        create tt-clien.
        assign tt-clien.clicod = plani.desti.                          
        
    end.

end.                

end. /* For each tipmov no-lock. */

/*
/***  Leitura de notas fiscais eletronicas de devolucao  ***/
for each estab where estab.etbcod < 189 no-lock,

    each plani where plani.etbcod = estab.etbcod 
                 and plani.emite = estab.etbcod
                 and plani.movtdc  = 12
                 and plani.desti > 3  
                 and plani.plaDat = vdt-aux no-lock,
                 
    first clien where clien.clicod = plani.desti no-lock:
    

    if plani.desti < 10 and plani.desti > 2
            then display "Dev " plani.etbcod plani.pladat plani.desti plani.platot clien.clinom  format  "x(25)".
            
            
    /*
    display "Devo " plani.pladat " Estab " estab.etbcod.
    pause 0.
    */    
    
    release tt-clien.
    find first tt-clien where tt-clien.clicod = plani.desti
                                no-lock no-error.
    if not avail tt-clien
    then do:
        
        create tt-clien.
        assign tt-clien.clicod = plani.desti.                          
        
    end.
    
end.                
*/
end.                 
                 
output to value(varq).

for each tt-clien,
   
    first clien where clien.clicod = tt-clien.clicod no-lock:

    if clien.ciccgc = ""
    then next.

    assign cod-ibge = "".

    put unformatted
        "C"
        clien.clicod         format "9999999999"           /* 002-018 */
        clien.ciccgc         format "x(18)" at 19          /* 019-036 */
        clien.ciinsc         format "x(20)"                /* 037-056 */
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
            
            assign v-tipo = "E".
            
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
                cliecom.cep            format "x(08)"        /* 353-360 */.
        
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
            
                assign v-tipo = "P".
            
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
                pedecom.cep            format "x(08)"        /* 353-360 */.
        
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
    
        assign v-tipo = "C".
    
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
        clien.cep[1]            format "x(08)"        /* 353-360 */.
    
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
              
               
