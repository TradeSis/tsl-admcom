{admcab_l.i}

def var varquivo as char.
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
    field com-g  as dec  format ">>>,>>>,>>9.99"
    field com-c  as dec  format ">>>,>>>,>>9.99"
    field pag-g  as dec  format ">>>,>>>,>>9.99"
    field pag-c  as dec  format ">>>,>>>,>>9.99".
    
repeat:
   
    update vdtini label "Periodo"
           vdtfin no-label with frame f1 side-label width 80.
           
    
    input from l:\simy\forn01.arq.
   
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
        
        data-diario  = date(vmes,vdia,vano).
        
        if data-diario >= vdtini and
           data-diario <= vdtfin
        then.
        else next.
           
        

        find first tt-dia where tt-dia.data = data-diario   no-error.
        if not avail tt-dia
        then do:
            create tt-dia.
            assign tt-dia.data = data-diario.
        end.  
             
        if vtipo = "P"
        then tt-dia.pag-g = tt-dia.pag-g + valor-credito.    
        else tt-dia.com-g = tt-dia.com-g + valor-credito.    




  
            
        
    end.
    input close.


 
    
    for each lanfor no-lock:
                          
        find first tt-dia where tt-dia.data = lanfor.datope no-error.
        if not avail tt-dia
        then do: 
            create tt-dia.  
            assign tt-dia.data = lanfor.datope.
        end.  
        
        if lanfor.datope >= vdtini and
           lanfor.datope <= vdtfin
        then.
        else next.
 
             
        if lanfor.tipope = "P"
        then tt-dia.pag-c = tt-dia.pag-c + lanfor.valope.
        else tt-dia.com-c = tt-dia.com-c + lanfor.valope.

    
    end. 
    
    varquivo = "l:\simy\dif.txt." .
    
    {mdad.i &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""imptipo4""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """PERIODO: "" +
                            string(vdtini,""99/99/9999"") + "" A "" +
                            string(vdtfin,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}




    
    for each tt-dia where tt-dia.data >= vdtini and
                          tt-dia.data <= vdtfin:
    
        
        display data  format "99/99/9999" 
                com-g column-label "Compra!CTB" format ">>>,>>>,>>9.99" 
                com-c column-label "Compra!INF" format ">>>,>>>,>>9.99" 
                (com-g - com-c) format "->>>,>>>,>>9.99"
                pag-g column-label "Pag!CTB" format ">>>,>>>,>>9.99" 
                pag-c column-label "Pag!INF" format ">>>,>>>,>>9.99"
                (pag-g - pag-c) format "->>>,>>>,>>9.99"
                    with frame f2 width 130 down.
  
        
    end.
    output close. 
    {mrod.i}
    
end.


    
    
        
        
