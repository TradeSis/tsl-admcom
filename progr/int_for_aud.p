/* não colocar admcab.i */

def var sresp as log format "Sim/Nao".
def var sparam as char.
sparam = SESSION:PARAMETER.
if num-entries(sparam,";") > 1
then sparam = entry(2,sparam,";").
 
if opsys = "unix" and sparam = "AniTA"
then do:
    sresp = no.
    message "Confirma gerar arquivo de FORNECEDORES/CLIENTES?" update sresp.
    if not sresp then return.
end. 

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
vdtf = today - 1.
vdti = vdtf  - 60.

def var varq-lista       as char.

def new shared var vimporta-lista   as log format "Sim/Nao".

def var vcod as char format "x(18)".
def var varq as char.


def new shared temp-table tt-imp
    field cod as char
        index idx01 cod.

def var vlinha           as char.

if opsys = "unix" and sparam = "AniTA"
then varq = "/admcom/decision/forne_" + string(today,"99999999") + ".txt".
else varq = "/file_server/forne.txt".

if opsys = "unix" and sparam = "AniTA"
then do:
    assign varq-lista = "/admcom/decision/".
            
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
        then repeat:
        
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
def var vachou as log.

def temp-table tt-forne like forne
    index i1 forcod.

output to value(varq).

for each tipmov where tipmov.tipemite = no or
                          tipmov.movtdc = 27 or
                          tipmov.movtdc = 14
            or can-find (first tipmovaux where
                            tipmovaux.movtdc = tipmov.movtdc and
                            tipmovaux.nome_campo = "PROGRAMA-NF" AND
                            tipmovaux.valor_campo = "nfentall")
            no-lock :
    for each estab no-lock:            
        for each  plani where  plani.movtdc = tipmov.movtdc and
                               plani.etbcod = estab.etbcod and
                               plani.pladat > vdti  
                               no-lock:
            find forne where forne.forcod = plani.emite no-lock no-error.
            if avail forne
            then do:
                find first tt-forne where
                           tt-forne.forcod = forne.forcod no-error.
                if not avail tt-forne
                then do:           
                    create tt-forne.
                    buffer-copy forne to tt-forne.
                end.
            end.
        end.
    end.
end.
for each tipmov where tipmov.tipemite = yes and
                          (tipmov.movtdc = 14 or
                           tipmov.movtdc = 16 or
                           tipmov.movtdc = 26 or
                           tipmov.movtdc = 46 or
                           tipmov.movtdc = 75)
            no-lock :
    for each estab no-lock:            
        for each  plani where  plani.movtdc = tipmov.movtdc and
                               plani.etbcod = estab.etbcod and
                               plani.pladat > vdti  
                               no-lock:
            find forne where forne.forcod = plani.desti no-lock no-error.
            if avail forne
            then do:
                find first tt-forne where
                           tt-forne.forcod = forne.forcod no-error.
                if not avail tt-forne
                then do:           
                    create tt-forne.
                    buffer-copy forne to tt-forne.
                end.
            end.
        end.
    end.
end.

def buffer ba01_infnfe for a01_infnfe.
for each tipmov where tipmov.tipemite or
                      tipmov.movtdc = 27 no-lock:
    if tipmov.movtdc = 30 or
       tipmov.movtdc = 4  or
       tipmov.movtdc = 5  or
       tipmov.movtdc  = 6  or
       tipmov.movtdc  = 18 or
       tipmov.movtdc < 4
    then next.   
    for each estab no-lock:
        for each placon where placon.etbcod = estab.etbcod  and
                      placon.movtdc =  tipmov.movtdc and
                      placon.pladat > vdti,
                first ba01_infnfe where ba01_infnfe.etbcod = placon.etbcod
                                    and ba01_infnfe.placod = placon.placod
                                    and ba01_infnfe.situacao = "inutilizada"
                                  no-lock.
                
            find forne where forne.forcod = placon.desti no-lock no-error.
            if avail forne
            then do:
                find first tt-forne where
                           tt-forne.forcod = forne.forcod no-error.
                if not avail tt-forne
                then do:           
                    create tt-forne.
                    buffer-copy forne to tt-forne.
                end.
            end.
        end.
    end.
end.

for each tt-imp.
    if substr(string(tt-imp.cod),1,1) = "F"
    then do:
        create tt-forne.
        tt-forne.forcod = int(substr(string(tt-imp.cod),2,9)).
    end.
end. 

for each frete where frete.forcod > 0 no-lock,
    first forne where forne.forcod = frete.forcod no-lock:

    find first tt-forne where
               tt-forne.forcod = frete.forcod  no-lock no-error.
    if not avail tt-forne
    then do:
        create tt-forne.
        buffer-copy forne to tt-forne.
    end.           
end.

for each tt-forne no-lock,
    first forne where forne.forcod = tt-forne.forcod no-lock:    
                            

    if forne.forcgc = ""
    then next.
                                               
    find first frete where frete.forcod = forne.forcod no-lock no-error.
    if avail frete
    then vcod = "T" + string(forne.forcod,"9999999999") + "       ". 
    else vcod = "F" + string(forne.forcod,"9999999999") + "       ". 

    /***
    if vimporta-lista
    then do:
        if not can-find(first tt-imp
                        where tt-imp.cod = vcod)
                    and not can-find(first tt-imp
                             where tt-imp.cod = string(forne.forcod))
                then next.                                     
    end.
    ***/
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

def var varq-cli as char.

if opsys = "unix"
then.
else message "Exportacao de Fornecedores completa, iniciando exportacao de Clientes".

if connected ("ecommerce")
then disconnect ecommerce.
                                             
connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tcp -ld ecommerce
                                no-error.

pause 0.
                  
run /admcom/progr/int_cli_aud.p(output varq-cli).
  
if connected ("ecommerce")
then disconnect ecommerce.
              
if opsys = "unix" and sparam = "AniTA"
then do:
    message color red/with
        "Arquivos gerados:" skip
        varq skip
        varq-cli
        view-as alert-box.
end.        
