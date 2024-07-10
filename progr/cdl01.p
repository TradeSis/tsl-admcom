{admcab.i}


def var vv as int.
def var saldo1  like  plani.platot.
def var saldo2  like  plani.platot.
def shared temp-table tt-cli 
    field clicod like clien.clicod
    field titnum like titulo.titnum
    field divida like titulo.titvlcob
    field etbcod like estab.etbcod
    field titdtven like titulo.titdtven.
def var vdias as int.    
def var ventrada like plani.platot.
 
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
then varquivo = "/admcom/relat/cli" + string(time) + ".cdl".
else varquivo = "l:\relat\cli.cdl".

output stream sarq to value(varquivo).

update saldo1 label "Saldo inicial"
       saldo2 label "Saldo Final"
            with frame f1.
            
                
update vcaminho with frame f1 side-label width 80.

vv = 0.


    
    output to value(vcaminho).
    for each tt-cli:
    
        find clien where clien.clicod = tt-cli.clicod no-lock no-error.
        if not avail clien
        then next.
        
        vsaldo = 0.
        vjuro  = 0.
        vdias  = 0.
        
        for each titulo use-index iclicod  
                        where titulo.empcod = 19    and
                              titulo.titnat = no    and
                              titulo.modcod = "CRE" and
                              titulo.titsit = "lib" and
                              titulo.clifor = clien.clicod no-lock.

            vsaldo = vsaldo + titulo.titvlcob.
            if titulo.titdtven < today
            then do: 
                find tabjur where tabjur.nrdias = today - titulo.titdtven
                                                         no-lock no-error.
                if not avail tabjur                     
                then next.
                vjuro  = vjuro +
                    ( (titulo.titvlcob * tabjur.fator) - 
                       titulo.titvlcob).
            end.
            
            if vdias > (today - titulo.titdtven)
            then.
            else vdias = today - titulo.titdtven.
            
        end.
        
        if vdias <= 140 
        then vsaldo = vsaldo + vjuro.
        
        
        if vdias >= 141 and
           vdias <= 370
        then vsaldo = vsaldo + (vjuro / 2).
        
        
        if vdias >= 371 and
           vdias <= 700
        then vsaldo = vsaldo + (vjuro / 3).
        
        if vdias >= 701
        then vsaldo = vsaldo + (vjuro / 10).
        

        ventrada = vsaldo / 10.

        if vsaldo >= saldo1 and
           vsaldo <= saldo2
        then.
        else next.


        
    
        
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
        
        
        vv = vv + 1.
        
        put "|" clien.clinom    "|"
                 "Rua "  
                  clien.endereco[1] " "  
                  clien.numero[1] " "
                  clien.compl[1]  "|"
                  clien.bairro[1] "|" 
                  clien.cidade[1] "|"
                  clien.ufecod[1] "|"
                  clien.cep[1]    "|" 
                  tt-cli.etbcod   format ">>9" "|" 
                  ventrada        "|"
                  ventrada        "|" skip.
        
    end.
    output close.
    output stream sarq close.
    
    message "Total de clientes" vv.
    pause.
    
    
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
    
    

 
