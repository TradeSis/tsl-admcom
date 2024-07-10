{admcab-batch.i}

def stream debug .

def var custo-ultimanota as dec.

def var vsp as char init ";".
def var vmovdes as dec.
def var vmovacf as dec.

def var vmovctm as dec.
def var vcodplano as int.

{ajusta-rateio-venda-def.i}

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

def var bonusprovisorio as dec.
def var valbonusfrente as dec.

    def var vperc          as decimal.

    def buffer btt-movim for tt-movim.
    def buffer ctt-movim for tt-movim.
    def buffer dtt-movim for tt-movim.

    def var vsoma-plani-aux like plani.platot.
    def var vsoma-movim-aux like plani.platot.

    assign vsoma-plani-aux = 0
           vsoma-movim-aux = 0.

if vdebug
then do:
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

end.

    for each tt-plani no-lock:

                         
        find first func  where func.etbcod = tt-plani.etbcod                                            and func.funcod = tt-plani.vencod
                                        no-lock no-error.
                           
        assign tt-plani.chpres =
               dec(acha("VALCHQPRESENTEUTILIZACAO1", tt-plani.notobs[3])).

        assign val_acr = 0
               val_des = 0
               v-valor = 0
               val_chpres = 0
               bonusprovisorio = 0
               val_bonus = 0.
            
               bonusprovisorio = tt-plani.bonus.
              
               
               
               if tt-plani.pladat >= 12/01/2016 then do:
                   bonusprovisorio = 0.
                 end.

                 if bonusprovisorio = ? then bonusprovisorio = 0.                     
                                                


        if tt-plani.serie = "3"
        then do:
            if tt-plani.biss > (tt-plani.platot - tt-plani.vlserv)
            then assign val_acr = tt-plani.biss -
                         (tt-plani.platot - tt-plani.vlserv - 
                                          bonusprovisorio).
            else val_acr = tt-plani.acfprod.
        end.
        else do:
            if tt-plani.biss > (tt-plani.platot)
            then assign val_acr = tt-plani.biss -
                         (tt-plani.platot - bonusprovisorio).
            else val_acr = tt-plani.acfprod.
        end.
        if val_acr < 0 or val_acr = ?
        then val_acr = 0.
                        
        assign val_des = tt-plani.descprod + bonusprovisorio.
                                   
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
                   valbonusfrente = 0.
                   bonusprovisorio = 0.
                   
            assign vmovdes = 0
                   vmovacf = 0. 
                       
             bonusprovisorio = tt-plani.bonus.  

               if bonusprovisorio = ? then bonusprovisorio = 0.  


            val_acr =  round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.acfprod,2).
            if val_acr = ? then val_acr = 0.
            
            val_des =  round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.descprod,2).
            if val_des = ? then val_des = 0.
            
            if tt-plani.chpres <> ? and tt-plani.chpres > 0
            then
            val_chpres = round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * tt-plani.chpres,2).
            if val_chpres = ? then val_chpres = 0.    
            
            if tt-plani.bonus <> ? and tt-plani.bonus > 0
            then val_bonus = round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * bonusprovisorio,2).
            if val_bonus = ? then val_bonus = 0.
           


            if tt-plani.bonus <> ? and tt-plani.bonus > 0
          then valbonusfrente = round(((tt-movim.movpc * tt-movim.movqtm)
                                / plani.platot) * bonusprovisorio,2).
                       if valbonusfrente = ? then valbonusfrente = 0.



            if tt-plani.pladat >= 12/01/2016 then do:
                 val_bonus = 0.
            end.

            if plani.serie = "3"
            then do:
            if (plani.platot - plani.vlserv - plani.descprod)
                        < plani.biss
            then val_fin = round(((((tt-movim.movpc * tt-movim.movqtm)
                            - val_dev - val_des - val_bonus) /
                      (plani.platot - plani.vlserv - plani.descprod))
                       * plani.biss) - ((tt-movim.movpc * tt-movim.movqtm) -
                        val_dev - val_des - val_bonus),2).

            end.
            else do:
            if (plani.platot - plani.descprod)
                        < plani.biss
            then val_fin = round(((((tt-movim.movpc * tt-movim.movqtm)
                            - val_dev - val_des - val_bonus) /
                      (plani.platot - plani.descprod))
                       * plani.biss) - ((tt-movim.movpc * tt-movim.movqtm) -
                        val_dev - val_des - val_bonus),2).

            end.
            if val_fin = ? then val_fin = 0.

            val_com = round((tt-movim.movpc * tt-movim.movqtm) - val_dev
                         - val_bonus - val_des + val_acr + val_fin,2). 
            
            if val_com < 0
            then val_com = 0. 
            
            if val_com = ?
            then val_com = 0.
            
            run custo-ultima-nota.
            
            vmovctm = custo-ultimanota.
            
            assign vcodplano = 0 
                   vcodplano = tt-plani.pedcod. 
                                                                                           if vcodplano = 0
            then do:
        
                /*Nede 06-02-2012*/
                find first fin.titulo use-index etbcod
                     where fin.titulo.etbcobra = tt-plani.etbcod
                       and fin.titulo.titdtpag = tt-plani.pladat
                       and fin.titulo.titsit = "PAG" 
                       and (fin.titulo.moecod = "CAR"
                        or fin.titulo.moecod = "PDM")                        
                       and fin.titulo.titdtemi = titulo.titdtpag
                       and fin.titulo.titnum = tt-plani.Serie
                                         + string(tt-plani.numero)
                                no-lock no-error.
                                                     
                if avail fin.titulo 
                then vcodplano = 999.
                else vcodplano = 0.                                    
                             
            end.   

            assign tt-movim.movtot = val_com
                   tt-movim.movctm = vmovctm
                   tt-movim.movdes = val_des
                   tt-movim.chpres = val_chpres
                   tt-movim.bonus  = valbonusfrente / tt-movim.movqtm
                   tt-movim.crecod = vcodplano
                   tt-movim.serie  = tt-plani.serie
                   tt-movim.tipmov = tt-plani.tipmov.

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
        
        if vdebug
        then do:
        put stream debug unformatted
        tt-plani.etbcod
        vsp
        tt-plani.placod
        vsp
        tt-plani.platot
        vsp
        .
        end.
        
        assign vsoma-plani-aux = vsoma-plani-aux + tt-plani.platot
               v-total-movims = 0.

        for each tt-movim where tt-movim.etbcod = tt-plani.etbcod
                            and tt-movim.placod = tt-plani.placod
                            :
           if tt-movim.movtot < 0
           then tt-movim.movtot = 0.  
    
           assign v-total-movims = v-total-movims + tt-movim.movtot
                  v-total-movqtm = v-total-movqtm + tt-movim.movqtm.
        end.
        assign v-total-movims = round(v-total-movims,2).
        
        if vdebug
        then do:
        put stream debug unformatted
        v-total-movims vsp.
        put stream debug unformatted
        v-total-movqtm vsp.
        end.

        if tt-plani.platot <> v-total-movims
        then do:
        
            assign v-diferenca     = tt-plani.platot - v-total-movims
                   v-diferenca-aux = tt-plani.platot - v-total-movims
                   vsoma-movim-aux = 0.
        
            for each btt-movim where btt-movim.etbcod = tt-plani.etbcod
                                 and btt-movim.placod = tt-plani.placod 
                       exclusive-lock:

              if btt-movim.movtot = 0 then next.                

              assign vperc = round((btt-movim.movtot * 100) / v-total-movims,2).
              
              /**
              if vperc = 0 or vperc = ?
              then vperc = 100.
              **/

              if vperc = ? then vperc = 0.
              if vperc = 0
              then  assign 
                    btt-movim.acr-fin =
                round(((vperc * tt-plani.platot) / 100),2) - btt-movim.movtot
                    btt-movim.movtot = round(((vperc * tt-plani.platot)
                                            / 100),2).
              else btt-movim.movtot = btt-movim.movpc * btt-movim.movqtm.                              
              if btt-movim.movtot = 0
              then btt-movim.movtot = btt-movim.movpc * btt-movim.movqtm.

              if btt-movim.movtot <> ?
              then   
              assign vsoma-movim-aux = vsoma-movim-aux + btt-movim.movtot. 

            end.
            
            if  vsoma-movim-aux > 0 and
                vsoma-movim-aux <> tt-plani.platot /*and v-diferenca-aux < 1*/
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

        assign v-total-movims = 0.

        for each dtt-movim where dtt-movim.etbcod = tt-plani.etbcod
                             and dtt-movim.placod = tt-plani.placod no-lock:

            assign v-total-movims = v-total-movims + dtt-movim.movtot.
            
        end.
        
        if vdebug 
        then do:
            put stream debug unformatted
                v-total-movims vsp .
        end.
        
        assign v-total-movims = round(v-total-movims,2).
        
        if vdebug
        then do:
        put stream debug unformatted
            v-total-movims skip.
        end.    
    end.

    output stream debug close.
        
procedure custo-ultima-nota:
 
    def buffer cmovim for movim.
    
    find last cmovim where cmovim.procod = tt-movim.procod and
                       cmovim.movtdc = 4 and
                       cmovim.movdat < tt-movim.movdat
                       no-lock no-error.
    if avail cmovim
    then custo-ultimanota = (cmovim.movpc + (cmovim.movdev / cmovim.movqtm)
                       - cmovim.movdes) + 
                      ((cmovim.movpc + (cmovim.movdev / cmovim.movqtm)
                       - cmovim.movdes) *
                        (cmovim.movalipi / 100)).
    else custo-ultimanota = 0.
    
    find produ where produ.procod = tt-movim.procod no-lock no-error.
    
    if custo-ultimanota = 0 or custo-ultimanota = ?
       or (avail produ 
            and (produ.fabcod = 120141
                 or produ.fabcod = 120785
                 or produ.fabcod = 120786
                 or produ.fabcod = 120814
                 or produ.fabcod = 120815
                 or produ.fabcod = 120818
                 or produ.fabcod = 120819
                 or produ.fabcod = 120820
                 or produ.fabcod = 120821
                 or produ.fabcod = 120822
                 or produ.fabcod = 120823
                 or produ.fabcod = 120935
                 or produ.fabcod = 120936
                 or produ.fabcod = 120937
                 or produ.fabcod = 121056
                 or produ.fabcod = 121055)
             )    
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
