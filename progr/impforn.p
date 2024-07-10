
def var vdtini as date format "99/99/9999" initial today.
def var vdtfin as date format "99/99/9999" initial today.

def var varq as char.
def var vtipo         as char format "x(01)".
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
def var xx            as int.

def var vdata         as date.
def var vdti as date.
def var vdtf as date. 
def var vetb as int.

    
    pause.
   
    
    input from /ctb-dados/forn01.arq.
    repeat:

        import varq.
    
        codigo-conta = substring(varq,1,15).
        vdia = int(substring(varq,43,2)).
        vmes = int(substring(varq,45,2)).
        vano = int(substring(varq,47,4)).
        nome-conta   = substring(varq,63,38).
        valor-credito = dec(substring(varq,101,17)) / 100.
        vtipo         =  substring(varq,179,1).

        
        

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
        
       
      
        
        xx = xx + 1.
        
        if xx mod 100 = 0
        then display xx 
                    with frame f2 1 down width 80.
        pause 0.            

        find first lanfor use-index ind-2
                    where lanfor.conta  = codigo-conta and
                                lanfor.datope = data-diario  and
                                lanfor.valope = valor-credito no-error.
                                    
        if not avail lanfor
        then next.
        
        
        
        if vtipo = "P"
        then assign lanfor.tipope = "P"    
                    lanfor.tipdoc = "DUP".

        if vtipo = "N"
        then assign lanfor.tipope = "C"    
                    lanfor.tipdoc = "NFF" .
                     
        
        
    end.
    input close.

    
