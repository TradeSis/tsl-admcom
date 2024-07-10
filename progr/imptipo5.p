{admcab_l.i}

def var vdtini as date format "99/99/9999" initial today.
def var vdtfin as date format "99/99/9999" initial today.

def var varq as char.
def var vtipo         as char format "x(01)".
def var codigo-conta  as char format "x(15)".
def var nome-conta    as char format "x(50)".
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
def var vdata         as date format "99/99/9999".
def var vdti as date.
def var vdtf as date. 
def var vetb as int.
def var vtot as dec format ">>>,>>>,>>9.99".
def var totmes as dec format ">>>,>>>,>>9.99".
def temp-table tt-dia
    field data as date format "99/99/9999"
    field tot  as dec  format ">>>,>>>,>>9.99"
    field num  like lanfor.numdoc
    field nome like lanfor.histo.

def var vt as char format "x(01)".
def var vsis as log format "Simy/Custom".
def var varquivo as char.

repeat:


    for each tt-dia:
        delete tt-dia.
    end.
        
    vt = "n".

    update vdata label "Data"
           vt label "Tipo"
           vsis label "Sistema"
                with frame f1 side-label width 80.

    
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

        
        if vtipo = vt
        then.
        else next. 
        
        
        data-diario   = date(vmes,vdia,vano).
        

        if data-diario = vdata
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
        
        
        create tt-dia. 
        assign tt-dia.data = data-diario 
               tt-dia.tot = valor-credito
               tt-dia.nome = nome-conta
               tt-dia.num  = vnumero.
        
                
    end.
    input close.
    
    
    
    if vsis 
    then do: 
    
        varquivo = "l:\simy\arq.ctb". 

    
        {mdad.i &Saida     = "value(varquivo)" 
                &Page-Size = "64"
                &Cond-Var  = "130"
                &Page-Line = "66"
                &Nom-Rel   = ""imptipo5""
                &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                &Tit-Rel   = """.""" 
                &Width     = "130"
                &Form      = "frame f-cabcab"}



        put vdata  
            vt     
            vsis  skip(01).
               
               
        for each tt-dia by tt-dia.tot:
    
            display tt-dia.data format "99/99/9999"
                    tt-dia.nome column-label "Historico"
                    tt-dia.num(count)  column-label "Numero"
                    tt-dia.tot(total) column-label "Valor" format ">>>,>>>,>>9.99"
                        with frame f2 down width 130.
                    
        end.  
 
        output close. 
    
        {mrod.i}
    
    end.
    else do:
    
                                               

        varquivo = "l:\simy\arq.inf".
                                                 
    
        {mdad.i &Saida     = "value(varquivo)" 
                &Page-Size = "64"
                &Cond-Var  = "130"
                &Page-Line = "66"
                &Nom-Rel   = ""imptipo5""
                &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
                &Tit-Rel   = """.""" 
                &Width     = "130"
                &Form      = "frame f-cabcab"}



        put vdata  
            vt     
            vsis  skip(01).
               
    
        if vt = "n"
        then vt = "c".
    
        for each lanfor where lanfor.datope = vdata no-lock by lanfor.valope:
    
            
            if vt = lanfor.tipope
            then.
            else next.
        
            display datope format "99/99/9999"
                    histo column-label "Historico"
                    numdoc(count)   column-label "Numero"
                    valope(total) column-label "Valor" format ">>>,>>>,>>9.99"
                        with frame f3 down width 130.
                        

    
    
        end.    
        output close.
        {mrod.i}
    end.
    
end.    
