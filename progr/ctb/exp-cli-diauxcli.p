/*
connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecom
merce no-error.
*/

def shared var varqpar as char.

def shared temp-table tt-clien
    field clicod like clien.clicod
    index i1 clicod.
    
def var v-tipo      as char.
def var cod-ibge as char.
def var vcharcli as char.

def var vq as int.
def var vcep as char.
def var vc as log.
def var vi as int.
def var vn as char.
vn = "1;2;3;4;5;6;7;8;9;0".

output to value(varqpar).

for each tt-clien where tt-clien.clicod <> 0.
    find clien where clien.clicod = tt-clien.clicod
                            no-lock no-error.

    vc = no.
    do vi = 1 to num-entries(vn,";"):
        if substr(clien.ciccgc,1,1) = entry(vi,vn,";")
        then do:
            vc = yes.
            leave.
        end.
    end.
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
    then do:
    
        release cliecom.
        find first cliecom where cliecom.clicod = clien.clicod
                                no-lock no-error.
        
        if avail cliecom and cliecom.endereco <> ""
        then do:

            assign v-tipo = "E"
                   vcep = replace(cliecom.cep,",","") .
            if vcep = ?
            then vcep = "".
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
                                and pedid.clfcod = clien.clicod
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
                if vcep = ?
                then vcep = "".
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
    
        if vcep = ?
        then vcep = "".
        
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

    vq = vq + 1.
end.
output close.
 
