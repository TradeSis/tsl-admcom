
def var vdtini as date format "99/99/9999" initial today.
def var vdtfin as date format "99/99/9999" initial today.

def var varq as char.
def var codigo-conta  as char format "x(15)".
def var nome-conta    as char format "x(30)".
def var data-diario   as date format "99/99/9999".
def var saldo-inicial as dec format ">>>,>>>,>>9.99".
def var saldo-final   as dec format ">>>,>>>,>>9.99".
def var valor-debito  as dec format ">>>,>>>,>>9.99".
def var valor-credito as dec format ">>>,>>>,>>9.99".
def var vsaldo        as dec format ">>>,>>>,>>9.99".


def var vdia          as int.
def var vmes          as int.
def var vano          as int.

 

    
    unix silent 
    /usr/dlc/bin/quoter -d % /admcom/relato/drebes/CONT2001/DEVE2001.TXT > 
                    /ctb-dados/deve2001.arq.

 
    
    input from /ctb-dados/deve2001.arq.
    repeat:
        import varq.
    
        codigo-conta = substring(varq,1,15).
        nome-conta   = substring(varq,16,30).
        vdia = int(substring(varq,46,2)).
        vmes = int(substring(varq,48,2)).
        vano = int(substring(varq,50,4)).
    
        data-diario   = date(vmes,vdia,vano).
        saldo-inicial = dec(substring(varq,54,14)) / 100.
        valor-debito  = dec(substring(varq,68,14)) / 100.
        valor-credito = dec(substring(varq,82,14)) / 100.
        saldo-final   = dec(substring(varq,96,14)) / 100.   
      
    
        display data-diario
                saldo-inicial
                valor-debito
                valor-credito
                saldo-final with frame f2 down width 80.

        pause 0.
        
        find diario where diario.data = data-diario no-error.
        if not avail diario
        then do:
        
            create diario.
            assign diario.data         = data-diario.
        end.  
        assign diario.venda        = valor-debito 
               diario.pagamento    = valor-credito. 
        
        
    end.
    input close.


