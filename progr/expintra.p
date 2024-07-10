def var vdir as char init "/var/www/drebes/intranet/estoques/".
def var vdata as date.
def var varquivo as char.
def var vproduto as int.
def var vpromo as dec.

vproduto = int(SESSION:PARAMETER).

for each produ where produ.procod = vproduto no-lock:
   
    varquivo = vdir + "est" + string(produ.procod) + ".txt".
    output to value(varquivo).
    for each estoq where estoq.procod = produ.procod no-lock:
    
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
               vpromo format "->>>>>9.99" skip
            .
    end.
    output close.
end.    

