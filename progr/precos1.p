{/var/www/drebes/progress/admcab.i new}
def var vdir as char init "/var/www/drebes/publi/php/".
def var vdata as date.
def var varquivo as char.
def var vproduto as int.
def var vpromo as dec.
def var p42 as dec.
def var p43 as dec.
def var p87 as dec.
def var p88 as dec.

def buffer bfinan for finan.
def buffer cfinan for finan.
def buffer dfinan for finan.
find finan where finan.fincod = 42 no-lock no-error.
find bfinan where bfinan.fincod = 43 no-lock no-error.
find cfinan where cfinan.fincod = 87 no-lock no-error.
find dfinan where dfinan.fincod = 88 no-lock no-error.


vproduto = int(SESSION:PARAMETER).

def var vliqui as dec.
def var ventra as dec.
def var vparce as dec.
def var vvenda like estoq.estvenda.
for each produ where produ.procod = vproduto no-lock:
    
    varquivo = vdir + "preco.txt".
   /* output to value(varquivo).*/
    
    for each estoq where estoq.procod = produ.procod no-lock:
        assign
            vliqui = 0
            ventra = 0
            vparce = 0
        vdata = today.
        vvenda = estoq.estvenda.
        if estoq.estprodat >= today
        then vpromo = estoq.estproper.
        else do:
            vpromo = estoq.estvenda.
            if num-entries(substr(produ.pronom,1,3),"*") = 2
            then vpromo = vpromo * .80.
            else if num-entries(substr(produ.pronom,1,3),"*") = 3
            then vpromo = vpromo * .60.
            else if num-entries(substr(produ.pronom,1,3),"*") = 4
            then vpromo = vpromo * .40.
            vvenda = vpromo.
        end.

        run /var/www/drebes/progress/gercpg1.p( input finan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).
        p42 = vparce.
        assign
            vliqui = 0
            ventra = 0
            vparce = 0.
        run /var/www/drebes/progress/gercpg1.p( input bfinan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).

        p43 = vparce.
        assign
            vliqui = 0
            ventra = 0
            vparce = 0.
        run /var/www/drebes/progress/gercpg1.p( input cfinan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).
        
        p87 = vparce.
         assign
            vliqui = 0
            ventra = 0
            vparce = 0.
        run /var/www/drebes/progress/gercpg1.p( input dfinan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).

        p88 = vparce.                                              



   
        vdata = today.
        if estoq.estprodat >= today
        then vpromo = estoq.estproper.
        else vpromo = 0.           
            
output to value(varquivo) append.
     put    estoq.etbcod   ";"
               estoq.procod format ">>>>>>99" ";"
               estoq.estatual format "->>>>
>9.99" ";"
               vvenda /*estoq.estvenda*/ ";"
               vdata format("99/99/9999") ";"
               string(time,"hh:mm:ss") ";"
               estoq.estcusto ";"
               vpromo format "->>>>>9.99" ";"
               p42    format "->>>>>9.99" ";"
               p43    format "->>>>>9.99" ";"
               p87    format "->>>>>9.99" ";"
               p88    format "->>>>>9.99" skip
            .
   output close.
    end.
  end.    

