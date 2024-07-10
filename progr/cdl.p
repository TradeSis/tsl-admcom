{admcab.i}


def shared temp-table tt-cli 
    field clicod like clien.clicod
    field titnum like titulo.titnum
    field divida like titulo.titvlcob
    field etbcod like estab.etbcod
    field titdtven like titulo.titdtven.
 
def stream sarq.
def var vjuro like titulo.titvlcob.
def var i as i.
def var tot1 as dec format ">>>,>>>,>>9.99".
def var tot2 as dec format ">>>,>>>,>>9.99".
def var tot3 as dec format ">>>,>>>,>>9.99".
def var vsaldo like plani.platot.
def var vcaminho as char format "x(59)" label "Diretorio/Caminho".
def var varquivo as char.
if opsys = "UNIX"
then varquivo = "/admcom/relat/cdl" + string(time) + ".cdl".
else varquivo = "l:\relat\cli.cdl".

output stream sarq to value(varquivo).

vcaminho = "/admcom/import/cdl/".
update vcaminho with frame f1 side-label width 80.

    
    output to value(vcaminho).
    for each tt-cli:
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if not avail clien
        then next.
     
        
        if clien.clinom      = "" or
           clien.endereco[1] = "" or
           clien.endereco[1] = ?  or
           clien.cidade[1]   = "" or
           clien.cidade[1]   = ?  or
           clien.cep[1]      = ?  
        then do:
            
            display stream sarq
                    clien.clicod
                    clien.clinom with frame f-cli down.
                    
            next.
            
        end.
        
        
        put "|" clien.clinom    "|"
                 "Rua "  
                  clien.endereco[1] " "  
                  clien.numero[1] " "
                  clien.compl[1]  "|"
                  clien.bairro[1] "|" 
                  clien.cidade[1] "|"
                  clien.ufecod[1] "|"
                  clien.cep[1]    "|" 
                  tt-cli.etbcod   format "99" "|" skip.
        
    end.
    output close.
    output stream sarq close.
    
    message "imprimir clientes com dados incompletos" update sresp.
    if sresp
    then do:
        if opsys = "UNIX"
        then do:
            run visurel.p(varquivo,"").
        end.
        else do:
            {mrod.i}
            /*
            os-command silent type l:\relat\cli.cdl > prn.
            */
        end.
    end.
    
    

 
