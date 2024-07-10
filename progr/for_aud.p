/*
{admcab.i}

message "Gerar arquivo de fornecedore" update sresp.
if not sresp
then return.
*/

def var varq-lista       as char.

def new shared var vimporta-lista   as log format "Sim/Nao".

def var vcod as char format "x(18)".
def var varq as char.
def var sresp as log format "Sim/Nao".


def new shared temp-table tt-imp
    field cod as char
        index idx01 cod.

def var vlinha           as char.

def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").

if opsys = "unix" and sparam <> "AniTA"
then varq = "/admcom/audit/forne.txt".
else do:
    if opsys = "UNIX"
    then varq = "/admcom/audit/forne.txt".
    else varq = "l:\audit\forne.txt".

    message "Confirma exportacao de fornecedores" update sresp.
    if sresp = no
    then return.
end.    

if opsys = "unix" and sparam = "AniTA"
then do:
    assign varq-lista = "/admcom/audit/".
            
    vimporta-lista = no.
    
    message "Deseja importar uma lista com os clientes ou fornecedores?"
                    update vimporta-lista.
    
    if vimporta-lista
    then do:
                
        update varq-lista format "x(50)" label "Arquivo"
                      with frame f05 side-labels
                title "Informe o caminho do arquivo com a lista de clientes".
           
        if search(varq-lista) = ?
        then do:
                    
            message "Arquivo Não encontrado!"
                       view-as alert-box.
                            
            undo, retry.        
                    
        end.
                
    end.
    else do:
    
        message "Deseja informar o codigo manualmente?"
        update vimporta-lista.
        
        if vimporta-lista
        then do:
        
            create tt-imp.
            update tt-imp.cod format "x(25)" label "Cod."
                        with frame f-manual overlay centered side-labels.
        
        end.
    
    end.
 
end.

    if vimporta-lista
    then do:
    
        input from value(varq-lista).
        
        repeat:
            
            import vlinha.
                    
            if num-entries(vlinha,";") >= 1
            then do:
                                    
                find first tt-imp
                     where tt-imp.cod = entry(1,vlinha,";")
                                  no-lock no-error.
                                                       
                if not avail tt-imp
                then do:
                                    
                    create tt-imp.
                    assign tt-imp.cod = entry(1,vlinha,";").
                       
                end.   
                
            end.
                           
        end.

    end.
    

    for each tt-imp.
    
        display tt-imp.cod format "x(30)".
    
    end.
def var cod-ibge as char.
output to value(varq).
for each forne no-lock:

    if forne.forcgc = ""
    then next.
                                               
    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcod = "T" + string(forne.forcod,"9999999999") + "       ". 
    else vcod = "F" + string(forne.forcod,"9999999999") + "       ". 

    if vimporta-lista
    then do:
        
        if not can-find(first tt-imp
                        where tt-imp.cod = vcod)
        then next.
                                   
    end.

    find first munic where 
            munic.cidnom = forne.formunic and
            munic.ufecod = forne.ufecod
            no-lock no-error.
    if avail munic
    then cod-ibge = string(munic.cidcod).
    else cod-ibge = "".        
    put unformatted
        vcod                 format "x(18)"        /* 001-018 */
        forne.forcgc         format "x(18)"        /* 019-036 */
        forne.forinest       format "x(20)"        /* 037-056 */
        " "                  format "x(14)"        /* 057-070 */
        forne.fornom         format "x(70)"        /* 071-140 */
        forne.forfant        format "x(70)"        /* 141-210 */
        forne.forrua         format "x(50)"        /* 211-280 */
        string(forne.fornum) format "x(10)"       
        forne.forcomp        format "x(10)"       
        forne.forbairro      format "x(20)"        /* 281-300 */
        forne.formunic       format "x(50)"        /* 301-350 */
        forne.ufecod         format "x(02)"        /* 351-352 */
        forne.forcep         format "x(08)"        /* 353-360 */
        forne.forpais        format "x(20)"        /* 361-380 */
        " "                  format "x(12)"        /* 381-392 */
        cod-ibge             format "x(07)"        /* 393-397 */
        " "                  format "x(10)"        /* 398-407 */
        " "                  format "x(10)"        /* 408-417 */
        " "                  format "x(02)"        /* 418-419 */
        skip.
             
             
end.
output close.
if opsys = "unix"
then.
else message "Exportacao de Fornecedores completa, iniciando exportacao de Clientes".

if connected ("ecommerce")
then disconnect ecommerce.
                                             
connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecommerce
                                no-error.

pause 0.
                                                                                run cli_aud.p.
  
if connected ("ecommerce")
then disconnect ecommerce.
                                  
              
