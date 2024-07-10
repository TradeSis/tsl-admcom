/*
{admcab.i} 
*/
def input parameter vetbcod like estab.etbcod.
def input parameter vprocod like produ.procod.
def input parameter vdata1 as date.
def input parameter vdata2 as date.
 
def var datasai  like plani.pladat.
def var vdt like plani.pladat.
def var vnumero as char format "x(12)".
def var vmovqtm like movim.movqtm.
def var vmes as int format "99".
def var vano as int format "9999".
def var t-sai   like plani.platot.
def var t-ent   like plani.platot.
def var vdata   like plani.pladat.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
def var sal-ant   like estoq.estatual.
def var sal-atu   like estoq.estatual.
   
def var vdesti like movim.desti.

def shared temp-table tt-movest
    field etbcod like estab.etbcod
    field procod like produ.procod
    field data as date
    field movtdc like tipmov.movtdc
    field tipmov as char
    field numero as char format "x(12)"
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-atu as dec
    index i1 procod.
   
def new shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-med as dec
    field ano-cto as int
    index i1 etbcod procod
    .
     
/**
def shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    .
**/
    
repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    find produ where produ.procod = vprocod no-lock.
    
    vdt = vdata1.
    
    for each movdat where movdat.procod = produ.procod no-lock.
    
        find movim where movim.procod = movdat.procod and
                         movim.etbcod = movdat.etbcod and
                         movim.placod = movdat.placod no-lock no-error.
                         
        if not avail movim
        then next.
        
        if movim.etbcod = vetbcod or
           movim.desti  = vetbcod 
        then do:
            if vdt > movim.movdat
            then vdt = movim.movdat.
        end.
        
    end.    
    
    find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes < month(vdata1) and
                          hiest.hieano = year(vdata1) no-lock no-error.
    if not avail hiest
    then do:
        
        find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = year(vdata1) - 1 no-lock no-error.
        if not avail hiest
        then do:
            find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano = year(vdata1) - 2
                                        no-lock no-error.
            if not avail hiest
            then do:
                
                find last hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod             and
                          hiest.hiemes = month(vdata1)             and
                          hiest.hieano = year(vdata1) no-lock no-error.
                if not avail hiest
                then assign sal-ant = 0
                            vmes    = month(vdata1) 
                            vano    = year(vdata1).
            
                else assign sal-ant = 0 /* hiest.hiestf */
                            vmes    = hiest.hiemes - 1
                            vano    = hiest.hieano.

            end.

            else assign sal-ant = hiest.hiestf
                        vmes    = hiest.hiemes
                        vano    = hiest.hieano.
        end.
        else assign sal-ant = hiest.hiestf
                    vmes    = hiest.hiemes
                    vano    = hiest.hieano.
    end.
    else assign sal-ant = hiest.hiestf
                vmes    = hiest.hiemes
                vano    = hiest.hieano.

    sal-atu = sal-ant.
    t-sai   = 0.
    t-ent   = 0.

    find estoq where estoq.etbcod = vetbcod and
                     estoq.procod = produ.procod no-lock no-error.
    if not avail estoq then leave.
          /* movimentações antes do dia da data inicial */
    do vdata = date(month(vdata1),1,year(vdata1)) to vdata1: 
        for each movim where movim.procod = produ.procod and
                             movim.emite  = vetbcod      and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next. 
                if substr(string(plani.notped),1,1) = "C" 
                   and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                
                /* if plani.emite = 22 and plani.desti = 996
                then next. */
            end.
            else vnumero = "PROBL.".
            
            if movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then. 
            else next.
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.


            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 11 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.

            vmovtnom = "".
            if movim.movtdc = 1
            then do:
                vmovtnom = "ORCAMENTO DE ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 4
            then do:
                vmovtnom = "ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 5
            then do:
                vmovtnom = "VENDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 12
            then do:
                vmovtnom = "DEV.VENDA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 13
            then do:
                vmovtnom = "DEV.FORN.".
                t-sai = t-sai + movim.movqtm.
            end.

            if movim.movtdc = 14
            then do:
                vmovtnom = "SIMPLES.REM.".
                t-sai = t-sai + movim.movqtm.
            end. 
            

            if movim.movtdc = 11
            then do:
                vmovtnom = "OUTRAS ENTRADAS".
                t-ent = t-ent + movim.movqtm.
            end.    
 
            

            if movim.movtdc = 15
            then do:
                vmovtnom = "ENT.CONSERTO".
                t-ent = t-ent + movim.movqtm.
            end.    
            if movim.movtdc = 16
            then do:
                vmovtnom = "REM.CONSERTO".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.etbcod = vetbcod
            then do:
                vmovtnom = "TRANSF.SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
               movim.desti  = vetbcod
            then do:
                vmovtnom = "TRANSF.ENTRA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 17
            then do:
                 vmovtnom = "TROCA DE ENTRADA".
                 t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 18
            then do:
                vmovtnom = "TROCA DE SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.

            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
            
            
            datasai = movim.datexp.
                        
            
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next.
                if substr(string(plani.notped),1,1) = "C"
                    and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                
                /* if plani.emite = 22 and plani.desti = 996
                then next. */
                
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 07 or
               movim.movtdc = 08 or
               movim.movtdc = 09 
            then next.
            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.

            if movim.movtdc = 4  or
               movim.movtdc = 1  or
               movim.movtdc = 7  or
               movim.movtdc = 11 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.
            vmovtnom = "".
            if movim.movtdc = 1
            then do:
                vmovtnom = "ORCAMENTO DE ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 4
            then do:
                vmovtnom = "ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 5
            then do:
                vmovtnom = "VENDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 12
            then do:
                vmovtnom = "DEV.VENDA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 13
            then do:
                vmovtnom = "DEV.FORN.".
                t-sai = t-sai + movim.movqtm.
            end.

            if movim.movtdc = 14
            then do:
                vmovtnom = "SIMPLES.REM.".
                t-sai = t-sai + movim.movqtm.
            end.
            
            if movim.movtdc = 11
            then do:
                vmovtnom = "OUTRAS ENTRADAS".
                t-ent = t-ent + movim.movqtm.
            end.    
 
            if movim.movtdc = 15
            then do:
                vmovtnom = "ENT.CONSERTO".
                t-ent = t-ent + movim.movqtm.
            end.    
            if movim.movtdc = 16
            then do:
                vmovtnom = "REM.CONSERTO".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.etbcod = vetbcod
            then do:
                vmovtnom = "TRANSF.SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.desti  = vetbcod
            then do:
                vmovtnom = "TRANSF.ENTRA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 17
            then do:
                 vmovtnom = "TROCA DE ENTRADA".
                 t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 18
            then do:
                vmovtnom = "TROCA DE SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
             
            vmovqtm = movim.movqtm.
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
            
            datasai = movim.datexp.
            
        end. 
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.movdat = vdata no-lock:
            
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next .
                if substr(string(plani.notped),1,1) = "C"
                    and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                
                /* 
                if plani.emite = 22 and plani.desti = 996
                then next.
                */
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 7  or 
               movim.movtdc = 8 
            then.
            else next.
            

            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 8  
            then sal-atu = sal-atu - movim.movqtm.
            if movim.movtdc = 7  
            then sal-atu = sal-atu + movim.movqtm.

            
            vmovtnom = "".
            
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
             
            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            /*
            if month(movim.movdat) <> month(movim.datexp)
            then do:
                if movim.movtdc = 7  
                then assign sal-atu = sal-atu - movim.movqtm
                            t-ent = t-ent + movim.movqtm.
            end.
            */
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.movdat.

        end.            
            
 
    end.
    
    sal-ant = sal-ant + t-ent - t-sai.
    sal-atu = sal-ant.
   
    t-sai = 0.
    t-ent = 0.
    


    do vdata = vdata1  /**date(month(vdata1),1,year(vdata1))**/ to vdata2: 
        for each movim where movim.procod = produ.procod and
                             movim.emite  = vetbcod      and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next. 
                if substr(string(plani.notped),1,1) = "C"
                    and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                /*
                if plani.emite = 22 and plani.desti = 996
                then next. 
                */
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 5  or
               movim.movtdc = 3  or
               movim.movtdc = 6  or
               movim.movtdc = 12 or
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 
            then. 
            else next.
            


            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.


            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 11 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.

            vmovtnom = "".
            if movim.movtdc = 1
            then do:
                vmovtnom = "ORCAMENTO DE ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 4
            then do:
                vmovtnom = "ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 5
            then do:
                vmovtnom = "VENDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 12
            then do:
                vmovtnom = "DEV.VENDA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 13
            then do:
                vmovtnom = "DEV.FORN.".
                t-sai = t-sai + movim.movqtm.
            end.

            if movim.movtdc = 14
            then do:
                vmovtnom = "SIMPLES.REM.".
                t-sai = t-sai + movim.movqtm.
            end.
            
            if movim.movtdc = 11
            then do:
                vmovtnom = "OUTRAS ENTRADAS".
                t-ent = t-ent + movim.movqtm.
            end.    
 
 

            if movim.movtdc = 15
            then do:
                vmovtnom = "ENT.CONSERTO".
                t-ent = t-ent + movim.movqtm.
            end.    
            if movim.movtdc = 16
            then do:
                vmovtnom = "REM.CONSERTO".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.etbcod = vetbcod
            then do:
                vmovtnom = "TRANSF.SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
               movim.desti  = vetbcod
            then do:
                vmovtnom = "TRANSF.ENTRA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 17
            then do:
                 vmovtnom = "TROCA DE ENTRADA".
                 t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 18
            then do:
                vmovtnom = "TROCA DE SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.

            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.datexp.
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.            
            if vmovqtm > 0
            then do:
            create tt-movest.
            assign tt-movest.etbcod = vetbcod
                   tt-movest.procod = produ.procod
                   tt-movest.data = datasai 
                   tt-movest.tipmov = vmovtnom
                   tt-movest.numero = vnumero
                   tt-movest.serie = if avail plani then plani.serie else ""
                   tt-movest.emite = movim.emite
                   tt-movest.desti = movim.desti
                   tt-movest.movqtm = vmovqtm
                   tt-movest.movpc = movim.movpc
                   tt-movest.sal-atu = sal-atu
                   .

            end.
        end.
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.datexp = vdata no-lock by movim.datexp
                                                          by movim.movtdc desc:
            
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.
            
            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next.
                
                if substr(string(plani.notped),1,1) = "C"
                    and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                
                /*
                if plani.emite = 22 and plani.desti = 996
                then next.
                */
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 5  or 
               movim.movtdc = 12 or 
               movim.movtdc = 13 or 
               movim.movtdc = 14 or 
               movim.movtdc = 16 or
               movim.movtdc = 07 or
               movim.movtdc = 08 or
               movim.movtdc = 09 
            then next.
            

            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then sal-atu = sal-atu - movim.movqtm.


            if movim.movtdc = 4  or
               movim.movtdc = 1  or
               movim.movtdc = 7  or
               movim.movtdc = 11 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then sal-atu = sal-atu + movim.movqtm.

            if movim.movtdc = 6 or
               movim.movtdc = 3
            then do:
                if movim.etbcod = vetbcod
                then sal-atu = sal-atu - movim.movqtm.
            
                if movim.desti = vetbcod
                then sal-atu = sal-atu + movim.movqtm.
            end.
            vmovtnom = "".
            if movim.movtdc = 1
            then do:
                vmovtnom = "ORCAMENTO DE ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 4
            then do:
                vmovtnom = "ENTRADA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 5
            then do:
                vmovtnom = "VENDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 12
            then do:
                vmovtnom = "DEV.VENDA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 13
            then do:
                vmovtnom = "DEV.FORN.".
                t-sai = t-sai + movim.movqtm.
            end.

            if movim.movtdc = 14
            then do:
                vmovtnom = "SIMPLES.REM.".
                t-sai = t-sai + movim.movqtm.
            end.
            
            if movim.movtdc = 11
            then do:
                vmovtnom = "OUTRAS ENTRADAS".
                t-ent = t-ent + movim.movqtm.
            end.    
 
            if movim.movtdc = 15
            then do:
                vmovtnom = "ENT.CONSERTO".
                t-ent = t-ent + movim.movqtm.
            end.    
            if movim.movtdc = 16
            then do:
                vmovtnom = "REM.CONSERTO".
                t-sai = t-sai + movim.movqtm.
            end.
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.etbcod = vetbcod
            then do:
                vmovtnom = "TRANSF.SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
            if (movim.movtdc = 6 or
                movim.movtdc = 3) and
                movim.desti  = vetbcod
            then do:
                vmovtnom = "TRANSF.ENTRA".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 17
            then do:
                 vmovtnom = "TROCA DE ENTRADA".
                 t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 18
            then do:
                vmovtnom = "TROCA DE SAIDA".
                t-sai = t-sai + movim.movqtm.
            end.
             
            vmovqtm = movim.movqtm.
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.datexp.
            
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.
            if vmovqtm > 0
            then do:
            create tt-movest.
            assign tt-movest.etbcod = vetbcod
                   tt-movest.procod = produ.procod
                   tt-movest.data = datasai 
                   tt-movest.tipmov = vmovtnom
                   tt-movest.numero = vnumero
                   tt-movest.serie = if avail plani then plani.serie else ""
                   tt-movest.emite = movim.emite
                   tt-movest.desti = movim.desti
                   tt-movest.movqtm = vmovqtm
                   tt-movest.movpc = movim.movpc
                   tt-movest.sal-atu = sal-atu
                   .
           end.
        end. 
        
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.movdat = vdata no-lock:
            
            if movim.movtdc = 22 or movim.movtdc = 30 or
               movim.movtdc = 50
            then next.

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock no-error.
            
            if avail plani
            then do:
                if  plani.movtdc = 4 and
                    plani.notsit = yes
                then next.
                if substr(string(plani.notped),1,1) = "C"
                    and num-entries(plani.notped,"|") > 1
                then vnumero = entry(2,plani.notped,"|").
                else vnumero = string(plani.numero,"999999999").
                
                /*
                if plani.emite = 22 and plani.desti = 996
                then next.
                */
            end.
            else vnumero = "PROBL.".
            
            if avail plani and plani.modcod = "CAN"
            then next.
            if avail plani and plani.serie = "VC"
            then next.

            if movim.movtdc = 7  or 
               movim.movtdc = 8 
            then.
            else next.
            

            
            find tipmov of movim no-lock no-error.
            if not avail tipmov then next.
            
            if movim.movtdc = 8  
            then sal-atu = sal-atu - movim.movqtm.
            if movim.movtdc = 7  
            then sal-atu = sal-atu + movim.movqtm.

            
            vmovtnom = "".
            
            if movim.movtdc = 7
            then do:
                vmovtnom = "BAL.AJUS.ACR".
                t-ent = t-ent + movim.movqtm.
            end.
            if movim.movtdc = 8
            then do:
                vmovtnom = "BAL.AJUS.DEC".
                t-sai = t-sai + movim.movqtm.
            end.
             
            vmovqtm = movim.movqtm.
            
            if movim.movtdc = 21
            then assign vmovtnom = "BALANCO ESTOQUE"
                        vmovqtm  = movim.movqtm - sal-atu
                        sal-atu  = sal-atu + vmovqtm.
            
            /*
            if month(movim.movdat) <> month(movim.datexp)
            then do:
                if movim.movtdc = 7  
                then assign sal-atu = sal-atu - movim.movqtm
                            t-ent = t-ent + movim.movqtm.
            end.
            */
            if avail plani and 
               plani.notobs[2] <> "" and
               (plani.movtdc = 7 or
                plani.movtdc = 8)
            then vmovtnom = plani.notobs[2].
             datasai = movim.movdat.
 
            if movim.movtdc = 12
            then vdesti = movim.ocnum[7].
            else vdesti = movim.desti.
            if vmovqtm > 0
            then do:
            create tt-movest.
            assign tt-movest.etbcod = vetbcod
                   tt-movest.procod = produ.procod
                   tt-movest.data = datasai 
                   tt-movest.tipmov = vmovtnom
                   tt-movest.numero = vnumero
                   tt-movest.serie = if avail plani then plani.serie else ""
                   tt-movest.emite = movim.emite
                   tt-movest.desti = movim.desti
                   tt-movest.movqtm = vmovqtm
                   tt-movest.movpc = movim.movpc
                   tt-movest.sal-atu = sal-atu
                   .
             end.
        end. 
 
    end.
    
    if sal-ant < 0
    then sal-ant = 0.
    
    create tt-saldo.
    assign
        tt-saldo.etbcod = vetbcod
        tt-saldo.procod = vprocod
        tt-saldo.codfis = produ.codfis
        tt-saldo.sal-ant = sal-ant
        tt-saldo.qtd-ent = t-ent
        tt-saldo.qtd-sai = t-sai
        .
    tt-saldo.sal-atu = sal-ant + t-ent - t-sai.
    if tt-saldo.sal-atu < 0
    then tt-saldo.sal-atu = 0.        

    leave.
    
end.

