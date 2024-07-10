{admcab.i}
def input parameter p-etbcod like estab.etbcod.
def input parameter p-procod like produ.procod.
def input parameter p-custo  like estoq.estcusto.
def input parameter p-venda  like estoq.estvenda.
def input parameter p-promo  like estoq.estproper.
def input parameter vtime as int.

def buffer bprodu for produ.
def buffer bestoq for estoq.

find func where func.etbcod = setbcod and
                func.funcod = sfuncod no-lock.
def var vmenpro like admprog.menpro .
def buffer cprodu for produ.
def buffer cestoq for estoq.
def buffer destoq for estoq.

find produ where produ.procod = p-procod  no-lock no-error.
if avail produ and
    (p-custo <> 0 or
     p-venda <> 0)
then do :
    find first cestoq where cestoq.procod = produ.procod and
                           cestoq.etbcod > 0 no-lock.

        vmenpro = string(year(today),"9999") +
                  string(month(today),"99")  +
                  string(day(today),"99") +
                  string(produ.procod,"999999999") +
                  string(vtime)  .
        find first admprog where
                   admprog.menpro = vmenpro no-lock no-error.
        if not avail admprog
        then do:
            run p-cria-admprog.
        end.

        find hispre where hispre.procod   = produ.procod
                          and hispre.dtalt    = today
                          and hispre.hora-inc = vtime
                          and hispre.funcod   = func.funcod 
                          no-lock no-error.
        if not avail hispre
        then do:
           run p-cria-hispre. 
        end.
         
        for each estoq where estoq.procod = produ.procod and
                             (if p-etbcod > 0 
                                then estoq.etbcod = p-etbcod else true)
                                 no-lock:

            run p-atu-hiest.               
 
                /*
                find current hiest no-lock.
                */
        end.
 
        run p-atu-cprodu.

end.        



procedure p-cria-admprog:                                                   
    do transaction:                                                         
        create admprog.                                                     
        assign admprog.menpro = vmenpro .                                                       admprog.progtipo = string(string(produ.procod,"999999") + " " +                                           string(func.funnom,"x(10)") + " " +                                              string(today) +  " CUSTO " +                                                     string(cestoq.estcusto,">,>>9.99") +                                       "/" + string(p-custo,">,>>9.99") +        
                                   "   VENDA " +                                                                  string(cestoq.estvenda,">,>>9.99") +                                       "/" + string(p-venda,">,>>9.99"),"x(78)"). 
    end.                                                                    
                          
end procedure.                                                              
                                                                                                  
procedure p-cria-hispre:

        do transaction :
            create hispre.
            assign hispre.procod       = produ.procod
                   hispre.dtalt        = today
                   hispre.hora-inc     = vtime
                   hispre.funcod       = func.funcod
                   .
            if p-custo > 0
            then assign
                   hispre.estcusto-ant = cestoq.estcusto
                   hispre.estcusto-nov = p-custo .
            else assign
                      hispre.estcusto-ant = cestoq.estcusto
                      hispre.estcusto-nov = cestoq.estcusto .
            if p-venda > 0
            then assign
                    hispre.estvenda-ant = cestoq.estvenda
                    hispre.estvenda-nov = p-venda.
            else assign
                    hispre.estvenda-ant = cestoq.estvenda
                    hispre.estvenda-nov = cestoq.estvenda.
            if p-promo > 0
            then assign
                    hispre.estvenda-ant = cestoq.estvenda
                    hispre.estvenda-nov = cestoq.estvenda
                    hispre.estpromo-nov = p-promo.
    end.

end procedure.      

procedure p-atu-hiest:

    find hiest where hiest.etbcod = estoq.etbcod        and  
                     hiest.procod = estoq.procod        and  
                     hiest.hiemes = month(today) and         
                     hiest.hieano =  year(today) no-error.   
    if not avail hiest                                       
    then do transaction:                                     
        create hiest.                                        
        assign hiest.etbcod = estoq.etbcod                   
               hiest.procod = estoq.procod                   
               hiest.hiemes = month(today)                   
               hiest.hieano =  year(today).                  
    end.                                                     
    find first destoq where destoq.etbcod = estoq.etbcod and 
        destoq.procod = estoq.procod no-error.               
    if avail destoq                                          
    then do transaction:                                     
        if p-venda > 0                                       
        then hiest.hiepvf = p-venda.                         
        if p-custo > 0                                       
        then hiest.hiepcf = p-custo.                         
        destoq.datexp = today.                               
        if p-venda > 0                                       
        then assign destoq.estvenda = p-venda
                    destoq.DtAltPreco = today
                    .                      
        if p-custo > 0                                       
        then destoq.estcusto = p-custo.                      
        hiest.hiestf = destoq.estatual.                      
    end.                                                    

end procedure.

procedure p-atu-cprodu:

     do transaction:
        find cprodu where cprodu.procod = p-procod no-error.
        cprodu.datexp = today.
     end.

end procedure. 
