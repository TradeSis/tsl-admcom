def var vdir as char init "/var/www/drebes/publi/php/".
def var vdata as date.
def var varquivo as char.
def var vproduto as int.
def var vpromo as dec.
def var p42 as dec.
def var p43 as dec.
def var p87 as dec.

def buffer bfinan for finan.
def buffer cfinan for finan.
find finan where finan.fincod = 42 no-lock no-error.
find bfinan where bfinan.fincod = 43 no-lock no-error.
find cfinan where cfinan.fincod = 87 no-lock no-error.
vproduto = int(SESSION:PARAMETER).

for each produ where produ.procod = vproduto no-lock:
    
    varquivo = vdir + "preco.txt".
    output to value(varquivo).
    for each estoq where estoq.procod = produ.procod no-lock:
    
        assign
            p42 = (estoq.estvenda * finan.finfat)
            p43 = (estoq.estvenda * bfinan.finfat)
            p87 = (estoq.estvenda * cfinan.finfat).
    
        vdata = today.
        if estoq.estprodat >= today
        then vpromo = estoq.estproper.
        else vpromo = 0.               
        put    estoq.etbcod   ";"
               estoq.procod format ">>>>>>99" ";"
               estoq.estatual format "->>>>>9.99" ";"
               estoq.estvenda ";"
               vdata format("99/99/9999") ";"
               string(time,"hh:mm:ss") ";"
               estoq.estcusto ";"
               vpromo format "->>>>>9.99" ";"
               p42    format "->>>>>9.99" ";"
               p43    format "->>>>>9.99" ";"
               p87    format "->>>>>9.99" skip
            .
    end.
    output close.
end.    

