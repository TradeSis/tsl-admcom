{/admcom/progr/admcab-batch.i}

def stream debug .

def var custo-ultimanota as dec.

def var vsp as char init ";".
def var vmovdes as dec.
def var vmovacf as dec.

def var vmovctm as dec.
def var vcodplano as int.

def shared temp-table tt-planobiz
    field crecod as integer
        index idx01 crecod.

def shared temp-table tt-movim like movim
    field movtot    like plani.platot 
    field chpres    like plani.platot
    field bonus     like plani.platot
    field vencod    like func.funcod
    field vendedor  like func.funnom
    field acr-fin   as dec
    field tipmov    as char 
    field crecod    as integer
    field planobiz  as character
    field clicod    as integer
    field serie     as char
    field planumero as integer
      index idx01 etbcod                
      index idx02 etbcod procod
      index idx03 etbcod asc placod asc movtot desc
      index idx04 etbcod movdat
      index idx05 etbcod placod movdat movtdc
      index idx_pk is primary unique etbcod placod procod movdat tipmov.        

def shared temp-table tt-plani like plani
    field chpres like plani.platot
    field bonus  like plani.platot
    field tipmov as char   
    field clicod like plani.desti   
      index idx01 etbcod
      index idx_pk is primary unique etbcod placod serie
      index idx_chave_linx is unique etbcod numero pladat horincl.

def var val_fin    like plani.platot.                    
def var val_des    like plani.platot.   
def var val_dev    like plani.platot.   
def var val_acr    like plani.platot. 
def var val_com    like plani.platot.
def var val_chpres like plani.platot.
def var val_bonus  like plani.platot.

def var v-valor like plani.platot.

def var v-total-movqtm as dec.
def var v-total-movims   like plani.platot.
def var v-diferenca      like plani.platot.
def var v-diferenca-aux  like plani.platot.
def var v-diferenca-aux2 like plani.platot.

    def var vperc          as decimal.

    def buffer btt-movim for tt-movim.
    def buffer ctt-movim for tt-movim.
    def buffer dtt-movim for tt-movim.

    def var vsoma-plani-aux like plani.platot.
    def var vsoma-movim-aux like plani.platot.

    assign vsoma-plani-aux = 0
           vsoma-movim-aux = 0.

output stream debug to value(sretorno) append.


    put stream debug unformatted
        "====================================================================="
           skip
        "====================================================================="
           skip
        "====================================================================="
           skip
        "Procedure : p-ajusta-diferenca" string(time,"HH:MM:SS") skip
               .

    for each tt-plani no-lock:

                         
        find first func  where func.etbcod = tt-plani.etbcod                                            and func.funcod = tt-plani.vencod
                                        no-lock no-error.
                           
        assign tt-plani.chpres =
               dec(acha("VALCHQPRESENTEUTILIZACAO1", tt-plani.notobs[3])).

        assign val_acr = 0
               val_des = 0
               v-valor = 0
               val_chpres = 0
               val_bonus = 0.
            
        if tt-plani.biss > (tt-plani.platot - tt-plani.vlserv)
        then assign val_acr = tt-plani.biss -
                         (tt-plani.platot - tt-plani.vlserv - tt-plani.bonus).
        else val_acr = tt-plani.acfprod.

        if val_acr < 0 or val_acr = ?
        then val_acr = 0.
                        
        assign val_des = tt-plani.descprod + tt-plani.bonus.
                                   
        assign
               v-valor = (tt-plani.platot - /* tt-plani.vlserv -*/
                                    val_des + val_acr ).

        assign tt-plani.platot = v-valor.

    end.
    
    for each tt-plani no-lock:
        
        find first plani where plani.etbcod = tt-plani.etbcod and
                               plani.movtdc = tt-plani.movtdc and
                               plani.placod = tt-plani.placod and
                               plani.pladat = tt-plani.pladat
                               no-lock no-error.
        if not avail plani then next.                      
        
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            and tt-movim.movdat = tt-plani.pladat
                            and tt-movim.movtdc = tt-plani.movtdc 
                            no-lock:
            
            if tt-movim.movpc = 0
            then next.
            
            find first func where func.etbcod = plani.etbcod
                              and func.funcod = plani.vencod
                                    no-lock no-error.

            assign val_fin = 0.                   
                   val_des = 0.  
                   val_dev = 0.  
                   val_acr = 0. 
                   val_com = 0.
                   val_chpres = 0.
                   val_bonus = 0.
    
            assign vmovdes = 0
                   vmovacf = 0. 
                       
            val_acr =  round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.acfprod,2).
            if val_acr = ? then val_acr = 0.
            
            val_des =  round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.descprod,2).
            if val_des = ? then val_des = 0.
            
            /*
            val_dev =  round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.vlserv,2).
            if val_dev = ? then val_dev = 0.
            */
            
            if tt-plani.chpres <> ? and tt-plani.chpres > 0
            then
            val_chpres = round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.chpres,2).
            if val_chpres = ? then val_chpres = 0.    
            
            if tt-plani.bonus <> ? and tt-plani.bonus > 0
            then val_bonus = round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.bonus,2).
            if val_bonus = ? then val_bonus = 0.
           
  /*linha nova */

            /*if tt-plani.bonus > 0
            then

            val_des = val_des + val_bonus.
            */

             if (plani.platot - plani.vlserv - plani.descprod)
                        < plani.biss
            then
             val_fin = round(((((tt-movim.movpc * tt-movim.movqtm)
                            - val_dev - val_des - val_bonus) /
                      (plani.platot - plani.vlserv - plani.descprod))
                       * plani.biss) - ((tt-movim.movpc * tt-movim.movqtm) -
                        val_dev - val_des - val_bonus),2).

            if val_fin = ? then val_fin = 0.
            /*        
            message 
                tt-movim.movpc tt-movim.movqtm
                 val_dev
                 val_des val_acr  val_fin
                 .
            pause. */
            val_com = round((tt-movim.movpc * tt-movim.movqtm) - val_dev
                         - val_bonus - val_des + val_acr + val_fin,2). 
            
            if val_com < 0
            then val_com = 0 /*(tt-movim.movpc * tt-movim.movqtm)*/.
            
            if val_com = ?
            then val_com = 0.
            
            /***********                 
            if tt-movim.movctm = ? or tt-plani.etbcod = 200
            then do:
                find estoq where estoq.etbcod = tt-plani.etbcod and
                                 estoq.procod = tt-movim.procod
                                          no-lock no-error.
                                                
                if avail estoq
                then vmovctm = estoq.estcusto.
                else vmovctm = 0.
                                            
            end.
            else vmovctm = tt-movim.movctm.
            
            *************/
            
            run custo-ultima-nota.
            
            vmovctm = custo-ultimanota.
            
            assign vcodplano = 0. 

            assign vcodplano = tt-plani.pedcod. 
            /*
            if vcodplano = 0
            then do:
        
                /*Nede 06-02-2012*/
                find first titulo use-index etbcod
                     where titulo.etbcobra = tt-plani.etbcod
                       and titulo.titdtpag = tt-plani.pladat
                       and titulo.titsit = "PAG" 
                       and titulo.moecod = "CAR" 
                       and titulo.titdtemi = titulo.titdtpag
                       and titulo.titnum = "v"
                                         + string(tt-plani.numero)
                                no-lock no-error.
                                                     
                if avail titulo 
                then vcodplano = 999.
                else vcodplano = 0.                                    
                             
            end.   
            */
            assign tt-movim.movtot = val_com
                   tt-movim.movctm = vmovctm
                   tt-movim.movdes = val_des
                   tt-movim.chpres = val_chpres
                   tt-movim.bonus  = val_bonus
                   tt-movim.crecod = vcodplano
                   tt-movim.serie  = tt-plani.serie.

            if can-find(first tt-planobiz
                        where tt-planobiz.crecod = tt-movim.crecod)
            then assign tt-movim.planobiz = "Sim".
            else assign tt-movim.planobiz = "Não".
                                  
            if avail func                               
            then assign tt-movim.vendedor = func.funnom.
                                                                          
            assign                                      
                 tt-movim.clicod = tt-plani.desti.

        end.
    end.

    for each tt-plani no-lock:

                         
        find first func  where func.etbcod = tt-plani.etbcod                  
                           and func.funcod = tt-plani.vencod
                                        no-lock no-error.
     


        assign v-total-movims  = 0
               v-diferenca     = 0
               v-diferenca-aux = 0
               vperc           = 0.
        
        put stream debug unformatted
        tt-plani.etbcod
        vsp
        tt-plani.placod
        vsp
        tt-plani.platot
        vsp
        .

        
        assign vsoma-plani-aux = vsoma-plani-aux + tt-plani.platot.
        /*
        message "1.0".
        pause 0.
        */
        /*
        v-total-movqtm = 0.
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            and tt-movim.movdat = tt-plani.pladat
                            and tt-movim.movtdc = tt-plani.movtdc  no-lock:
             
    
           assign v-total-movims = v-total-movims + tt-movim.movtot
                  v-total-movqtm = v-total-movqtm + tt-movim.movqtm.
            
        end.
        
        assign v-total-movims = round(v-total-movims,2).

        put stream debug unformatted
        v-total-movims vsp.
        put stream debug unformatted
        v-total-movqtm vsp.
        
        */
        assign v-total-movims = 0.
        /*
        output to /admcom/lebesintel/rel-itens.csv append.
        */
        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            :
           if tt-movim.movtot < 0
           then tt-movim.movtot = 0.  
    
           assign v-total-movims = v-total-movims + tt-movim.movtot
                  v-total-movqtm = v-total-movqtm + tt-movim.movqtm.
            /*
            put tt-movim.etbcod vsp
                tt-movim.placod format ">>>>>>>>>9" vsp
                tt-movim.procod vsp
                tt-movim.movtot format "->>,>>>,>>9.99" vsp
                tt-movim.movqtm
                skip.
            */
        end.
        /*
        output close.
        */
        
        assign v-total-movims = round(v-total-movims,2).
        
        put stream debug unformatted
        v-total-movims vsp.
        put stream debug unformatted
        v-total-movqtm vsp.


        /*
        message "2.0".
        pause 0.
        */
        
        if tt-plani.platot <> v-total-movims
        then do:
        
            assign v-diferenca     = tt-plani.platot - v-total-movims
                   v-diferenca-aux = tt-plani.platot - v-total-movims
                   vsoma-movim-aux = 0.
        
            for each btt-movim where btt-movim.etbcod = tt-plani.etbcod
                                 and btt-movim.placod = tt-plani.placod                                                    exclusive-lock:

              assign vperc = round((btt-movim.movtot * 100) / v-total-movims,2).
              if vperc = 0 or vperc = ?
              then vperc = 100.

              assign btt-movim.acr-fin =
                round(((vperc * tt-plani.platot) / 100),2) - btt-movim.movtot.
             
          assign btt-movim.movtot = round(((vperc * tt-plani.platot)
                                            / 100),2).
                                            
              if btt-movim.movtot <> ?
              then   
              assign vsoma-movim-aux = vsoma-movim-aux + btt-movim.movtot. 
              
              /*
              assign v-diferenca-aux = round(v-diferenca -
                                        ((vperc * v-diferenca) / 100),2).
              */
              
            end.
            
            
            if vsoma-movim-aux <> tt-plani.platot /*and v-diferenca-aux < 1*/
            then do:
            
                assign v-diferenca-aux2 = 0.
                
                find first ctt-movim where ctt-movim.etbcod = tt-plani.etbcod
                                       and ctt-movim.placod = tt-plani.placod
                                    /*   and ctt-movim.movtot > 0 */
                                                    use-index idx03
                                                    exclusive-lock no-error .                  if avail ctt-movim then do:
                
                    if vsoma-movim-aux > tt-plani.platot
                    then do:
                       assign v-diferenca-aux2 = round(vsoma-movim-aux
                                                    - tt-plani.platot,2).
                        
                        assign ctt-movim.movtot = round(ctt-movim.movtot
                                      - (v-diferenca-aux2),2).
                                      
                    end.                  
                    else do:
                    
                        assign v-diferenca-aux2 = round(tt-plani.platot
                                                        - vsoma-movim-aux,2).
                    
                        assign ctt-movim.acr-fin = round(ctt-movim.acr-fin
                                                    + (v-diferenca-aux2),2).

                        assign ctt-movim.movtot = round(ctt-movim.movtot
                                                    + (v-diferenca-aux2),2).
                                     
                    end.
                    
                end.

            end.
            
        end.
        /*
        message "3.0".
        pause 0.
        */
        assign v-total-movims = 0.

        for each dtt-movim where dtt-movim.etbcod = tt-plani.etbcod
                             and dtt-movim.placod = tt-plani.placod no-lock:

            /*
            assign vsoma-movim-aux = vsoma-movim-aux + dtt-movim.movtot.
            */
            
            /*
            if dtt-movim.bonus > dtt-movim.movtot
            then dtt-movim.movtot = 0.
              */
              
            assign v-total-movims = v-total-movims + dtt-movim.movtot.
            
        end.
        
        put stream debug unformatted
          v-total-movims vsp .
        
        assign v-total-movims = round(v-total-movims,2).
        
        put stream debug unformatted
            v-total-movims skip.
        /*
        message "4.0".
        pause 0.
        */
    end.
/*
    message "Soma plani: " vsoma-plani-aux " Soma Movim " vsoma-movim-aux.
    pause.
*/



        output stream debug close.
        


procedure custo-ultima-nota:
 
    def buffer cmovim for movim.
    
    find last cmovim where cmovim.procod = tt-movim.procod and
                       cmovim.movtdc = 4 and
                       cmovim.movdat < tt-movim.movdat
                       no-lock no-error.
    if avail cmovim
    then custo-ultimanota = (cmovim.movpc + cmovim.movdev
                       - cmovim.movdes) + 
                      ((cmovim.movpc + cmovim.movdev
                       - cmovim.movdes) *
                        (cmovim.movalipi / 100)).
    else custo-ultimanota = 0.
    
    if custo-ultimanota = 0 or custo-ultimanota = ?
    then do:
    
        find estoq where estoq.etbcod = tt-movim.etbcod and
                         estoq.procod = tt-movim.procod 
                         no-lock no-error.
        if avail estoq
        then custo-ultimanota = estoq.estcusto.
                         
    end.                         

    if custo-ultimanota = ? then custo-ultimanota = 0.
    
    if custo-ultimanota = 0 and
       tt-movim.movctm <> ? and
       tt-movim.movctm > 0
    then custo-ultimanota = tt-movim.movctm.
    
end procedure. 
