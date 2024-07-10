
/**** VARIAVEIS USADAS *******

def var vvldesc as dec.
def var vvlacre as dec.
def var vvalor as dec.
def var vcatcod as int.
def var vignora as log.
def buffer bmovim for movim.
def var vcat as int.
def var wacr as dec.
def var acum-m as dec. /*** Totaliza Moveis ***/
def var acum-c as dec. /*** Totaliza Confecção ***/
def var vdtimp as date.
def var dia-m as dec.
def var dia-c as dec.
def var vj as int.
***************************/


         ASSIGN
            vvldesc = 0
            vvlacre = 0
            vvalor = 0.

                
                if vcatcod > 0
                then
                for each movim where movim.etbcod = plani.etbcod and
                                     movim.placod = plani.placod and
                                     movim.movtdc = plani.movtdc and
                                     movim.movdat = plani.pladat
                                     no-lock:
                       find first produ where produ.procod = movim.procod
                            no-lock no-error.
                       if avail produ
                       then do:
                       
                        find clase where clase.clacod = produ.clacod no-lock.
                        if /*metven.clacod = 100 or
                           metven.clacod = 190 or
                           metven.clacod = 200*/
                           clase.clasup = 129000000                            
                        then do:
                            acum-p = acum-p + (movim.movpc * movim.movqtm)
                                   - movim.movdes.
                        end.                       
                        else do:
                        
                            if vcatcod <> 31 
                            then if produ.catcod <> vcatcod 
                                 then vignora = yes.
                            if vcatcod = 31 
                            then if produ.catcod = vcatcod or
                                    produ.procod = 88888
                                 then vignora = no. /* pelo menos 1 movel */
                        end.                                 
                       end.
                end.
                if vignora = yes then next.
                

                for each bmovim where bmovim.etbcod = plani.etbcod and
                                      bmovim.placod = plani.placod and
                                      bmovim.movtdc = plani.movtdc and
                                      bmovim.movdat = plani.pladat
                                      no-lock:

                    find first produ where produ.procod = bmovim.procod
                                                        no-lock no-error.
                    if avail produ
                    then do:
                        if produ.procod = 88888
                        then vcat = 31.
                        else vcat = produ.catcod.
                        
                    end.
                    find estoq where estoq.etbcod = plani.etbcod and
                                     estoq.procod = produ.procod
                                                no-lock no-error.
                    if not avail estoq
                    then next.
                end.
                
                wacr = 0.
                if plani.crecod >= 1
                then do:
                    if plani.biss > (plani.platot - plani.vlserv)
                    then assign wacr = plani.biss - 
                                      (plani.platot - plani.vlserv).
                    else wacr = plani.acfprod.

                    if wacr < 0 or wacr = ?
                    then wacr = 0.

                    assign vvldesc  = vvldesc  + plani.descprod
                           vvlacre  = vvlacre  + wacr.
                end.
                if (vcatcod = 31 or
                    vcatcod = 35 or
                    vcatcod = 50)
                then do:
                    assign acum-m = acum-m + (plani.platot - /* plani.vlserv -*/
                                               vvldesc + vvlacre).
                                               
                    if plani.pladat = vdtimp
                    then dia-m = dia-m + /*vvalor.*/
                          (plani.platot - /*plani.vlserv -*/ vvldesc + vvlacre).
                end.
                else if vcatcod <> 88
                then do:
                     assign
                        acum-c = acum-c + (plani.platot /* - plani.vlserv */
                                    - vvldesc + vvlacre) .
                     if plani.pladat = vdtimp
                        then dia-c = dia-c + /*vvalor.*/
                        (plani.platot - /*plani.vlserv -*/ vvldesc + vvlacre).

                end.
