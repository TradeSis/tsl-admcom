
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

def var vm as int.
def var vdata         as date.
def var vdti as date.
def var vdtf as date. 
def var vetb as int.
def var vtot as dec format ">>>,>>>,>>9.99".
def var totmes as dec format ">>>,>>>,>>9.99".
def temp-table tt-dia
    field data as date format "99/99/9999"
    field tot  as dec  format ">>>,>>>,>>9.99".
    
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

                    
        if vtipo = "N"
        then.
        else next.




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
        

        find first tt-dia where tt-dia.data = data-diario   and
                                tt-dia.tot  = valor-credito no-error.
        if not avail tt-dia
        then do:
            create tt-dia.
            assign tt-dia.data = data-diario
                   tt-dia.tot = valor-credito.    

        end.
            
        
        
        /*
        
        display data-diario format "99/99/9999"
                nome-conta column-label "Historico"
                vnumero    column-label "Numero"
                valor-credito column-label "Valor"
                vtot       column-label "Total Acum."
                    with frame f1 down width 130.
                    
        */
       
      
        
    end.
    input close.

    output to /admcom/simy/dif.com.
    for each tt-dia where tt-dia.data >= 01/01/2001 and
                          tt-dia.data <= 12/31/2001 
                          no-lock break by tt-dia.data:
                          
        find first lanfor where lanfor.datope = tt-dia.data and
                                lanfor.valope = tt-dia.tot  and
                                lanfor.tipope = "c" no-lock no-error.
        if not avail lanfor
        then do: 
            find first lanfor where lanfor.datope = tt-dia.data and
                                    lanfor.valope = tt-dia.tot  and 
                                    lanfor.tipope = "P" no-lock no-error.
            if avail lanfor
            then do:
                display lanfor.datope format "99/99/9999" 
                        lanfor.histo
                        lanfor.numdoc
                        lanfor.valope(total by tt-dia.data) 
                         format ">>>,>>>,>>9.99"
                            with frame ff down width 130.
            end.
                                

        end.
    
    end.    
    output close.

    
