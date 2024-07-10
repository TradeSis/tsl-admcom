
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
def var vnumero       as char.
def var ii as int.

def var vdia          as int.
def var vmes          as int.
def var vano          as int.
def temp-table tt-forne
    field data as date format "99/99/9999" 
    field valori as dec format ">>>,>>>,>>9.99"
    field valimp as dec format ">>>,>>>,>>9.99"
        index ind-1 data.
    
 

    
    unix silent 
    /usr/dlc/bin/quoter -d % /admcom/relato/drebes/CONT2001/FONR2001.TXT > 
                    /ctb-dados/forn.arq.

 
    pause.
   
    
    input from /ctb-dados/forn.arq.
    repeat:

        import varq.
    
        codigo-conta = substring(varq,1,15).
        vdia = int(substring(varq,43,2)).
        vmes = int(substring(varq,45,2)).
        vano = int(substring(varq,47,4)).
        nome-conta   = substring(varq,63,38).
        valor-credito = dec(substring(varq,101,17)) / 100.

        
        

        ii = 0.
        vnumero = "".
        do ii = 1 to 15:

           if substring(nome-conta,ii,1) = "0" or
              substring(nome-conta,ii,1) = "1" or
              substring(nome-conta,ii,1) = "2" or 
              substring(nome-conta,ii,1) = "3" or 
              substring(nome-conta,ii,1) = "4" or 
              substring(nome-conta,ii,1) = "5" or 
              substring(nome-conta,ii,1) = "6" or 
              substring(nome-conta,ii,1) = "7" or 
              substring(nome-conta,ii,1) = "8" or 
              substring(nome-conta,ii,1) = "9"  
           then vnumero = vnumero + substring(nome-conta,ii,1).
           else leave.
              
        
        end.
        
        data-diario   = date(vmes,vdia,vano).
        
       
      
    
        display codigo-conta
                data-diario
                vnumero    
                nome-conta    
                valor-credito
                    with frame f2 1 down width 80.
        pause 0.            


        find first tt-forne where tt-forne.data = data-diario no-error.
        if not avail tt-forne
        then do:
            create tt-forne.
            assign tt-forne.data = data-diario.
        end.
        assign tt-forne.valori = tt-forne.valori + valor-credito.
    
    end.

    for each tt-forne by tt-forne.data:
    
        for each lanfor where lanfor.datope = tt-forne.data no-lock:
        
            tt-forne.valimp = tt-forne.valimp + lanfor.valope.
            
        end.

    end.    

    for each tt-forne:
        disp tt-forne.
    end.    
              
    
