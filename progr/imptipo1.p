
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
   
    
    output to /ctb-dados/custom.pag.
    for each lanfor no-lock:
        
        if tipope = "P"
        then.
        else next.
        

        vtot = vtot + lanfor.valope.
        


        find first tt-dia where tt-dia.data = lanfor.datope no-error.
        if not avail tt-dia
        then do:
            create tt-dia.
            assign tt-dia.data = datope.
        end.
            
        assign tt-dia.tot = tt-dia.tot + valope.

        
        
        display datope format "99/99/9999"
                histo  column-label "Historico"
                numdoc column-label "Numero"
                valope column-label "Valor"
                vtot       column-label "Total Acum."
                    with frame f1 down width 130.
                    
        
       
      
        
    end.
    input close.
    output close.

    output to /ctb-dados/cusdia.pag.
    for each tt-dia.
        disp tt-dia.
    end.
    output close.        
    

    
