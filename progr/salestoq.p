/*
{admcab.i} 
*/
def input parameter vetbcod like estab.etbcod.
def input parameter vprocod like produ.procod.
def input parameter vdata1 as date.
def input parameter vdata2 as date.
 
def var datasai  like plani.pladat.
def var vdt like plani.pladat.
def var vnumero as char format "x(07)".
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
    field numero as char
    field serie like plani.serie
    field emite like plani.emite
    field desti like plani.desti
    field movqtm like movim.movqtm
    field movpc like movim.movpc
    field sal-atu as dec
    index i1 procod.
     
def shared temp-table tt-saldo
    field etbcod like estab.etbcod 
    field procod like produ.procod
    field codfis as int
    field sal-ant as dec
    field qtd-ent as dec
    field qtd-sai as dec
    field sal-atu as dec
    field cto-mes as dec
    field ano-cto as int
    index i1 etbcod procod
    .
    
repeat:
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
 
    find produ where produ.procod = vprocod no-lock.
    
    vdt = vdata1.
    
    find hiest where hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes = month(vdata2) and
                          hiest.hieano = year(vdata2) no-lock no-error.
    if not avail hiest 
    then do:
        if vetbcod <> 98 and
           vetbcod <> 106 and
           vetbcod <> 108 and
           vetbcod <> 110 and
           vetbcod <> 112 and
           vetbcod <> 200 and
           vetbcod <> 996 
        then do:   
        find hiest where  hiest.etbcod = vetbcod      and
                          hiest.procod = produ.procod and
                          hiest.hiemes < month(vdata2) and
                          hiest.hieano = year(vdata2) no-lock no-error.
        if not avail hiest
        then do:

            find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod and
                              hiest.hieano = year(vdata2) - 1 no-lock no-error.
            if not avail hiest
            then do:
                find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano = year(vdata2) - 2
                                        no-lock no-error.
                if not avail hiest
                then do:
                    find last hiest where hiest.etbcod = vetbcod      and
                                  hiest.procod = produ.procod and
                                  hiest.hieano < year(vdata2) - 2
                                        no-lock no-error.
                    if not avail hiest
                    then do:
                        find last hiest where hiest.etbcod = vetbcod      and
                              hiest.procod = produ.procod             and
                              hiest.hiemes = month(vdata2)             and
                              hiest.hieano = year(vdata2) no-lock no-error.
                        if not avail hiest
                        then assign sal-ant = 0
                            vmes    = month(vdata2) 
                            vano    = year(vdata2).
            
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
        end.
        else assign sal-ant = hiest.hiestf
                vmes    = hiest.hiemes
                vano    = hiest.hieano.
        end.
    end.
    else assign sal-ant = hiest.hiestf
                vmes    = hiest.hiemes
                vano    = hiest.hieano.
 
    /******
    if vetbcod = 98
    then do:
        if sal-ant > 5
        then sal-ant = sal-ant - 2.
        if sal-ant > 10
        then sal-ant = sal-ant - 3.
        if sal-ant > 20
        then sal-ant = sal-ant - 3.
    end.
    if vetbcod = 106
    then do:
        if sal-ant > 1
        then sal-ant = sal-ant - 1.
        if sal-ant > 3
        then sal-ant = sal-ant - 2.
        if sal-ant > 5
        then sal-ant = sal-ant - 3.
        if sal-ant > 10
        then sal-ant = sal-ant - 6.
        if sal-ant > 15
        then sal-ant = sal-ant - 11.
        if sal-ant > 20
        then sal-ant = sal-ant - 14.
        if sal-ant > 30
        then sal-ant = sal-ant - 18.
        if sal-ant > 40
        then sal-ant = sal-ant - 24.
     end.
     if vetbcod = 108
    then do:
        if sal-ant > 5
        then sal-ant = sal-ant - 2.
        if sal-ant > 10
        then sal-ant = sal-ant - 6.
        if sal-ant > 20
        then sal-ant = sal-ant - 9.
    end.
    if vetbcod = 110
    then do:
        if sal-ant > 5
        then sal-ant = sal-ant - 2.
        if sal-ant > 10
        then sal-ant = sal-ant - 3.
        if sal-ant > 20
        then sal-ant = sal-ant - 3.
    end.
    if vetbcod = 112
    then do:
        if sal-ant > 5
        then sal-ant = sal-ant - 2.
        if sal-ant > 10
        then sal-ant = sal-ant - 5.
        if sal-ant > 20
        then sal-ant = sal-ant - 8.
    end.
    if vetbcod = 200
    then do:
        
        if sal-ant > 4
        then sal-ant = sal-ant - 2.
        if sal-ant > 5
        then sal-ant = sal-ant - 3.
        if sal-ant > 10
        then sal-ant = sal-ant - 8.
        if sal-ant > 20
        then sal-ant = sal-ant - 15
        .
    end.
    if vetbcod = 996
    then do:
        if sal-ant > 5
        then sal-ant = sal-ant - 2.
        if sal-ant > 10
        then sal-ant = sal-ant - 3.
        if sal-ant > 20
        then sal-ant = sal-ant - 3.
    end.
    *****/
    
    sal-atu = sal-ant.
    t-sai   = 0.
    t-ent   = 0.

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