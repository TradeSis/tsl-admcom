/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def new shared temp-table t-movim 
    field rec as recid
    field dat like plani.pladat.
    
def var vmes as int format "99".
def var vano as int format "9999".
def var t-sai   like plani.platot.
def var t-ent   like plani.platot.
def var vdata   like plani.pladat.
def var vetbcod like estab.etbcod.
def var vprocod like produ.procod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def var vdata1 like plani.pladat label "Data".
def var vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
def var sal-ant   like estoq.estatual.
def var sal-atu   like estoq.estatual.
              /**** Campo usado para guardar o no. da planilha ****/

repeat:

    for each t-movim:
        delete t-movim.
    end.
    
    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.
    update vetbcod label " Filial" with frame f-pro.
    find estab where estab.etbcod = vetbcod no-lock.
    disp estab.etbnom no-label with frame f-pro.
    update vdata1 label "Periodo" colon 55
           vdata2 no-label with frame f-pro.

    update vprocod
            with frame f-pro centered width 80 color blue/cyan row 4 side-label.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom no-label with frame f-pro.

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
    /*
    if vmes = 1
    then assign vmes = 12 
                vano = vano - 1.
    
    if vmes = month(today)
    then assign vmes = vmes - 1
                sal-ant = 0.
    */
    sal-atu = sal-ant.
    t-sai   = 0.
    t-ent   = 0.

 
    disp vmes label "Mes" colon 08
         vano label "Ano"
         sal-ant label "Saldo" format "->>>>99"
            with frame f-pro.
    
    
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock no-error.

    do vdata = date(month(vdata1),1,year(vdata1)) to today: 

        for each movim where movim.procod = produ.procod and
                             movim.emite  = vetbcod      and
                             movim.datexp = vdata no-lock:  

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock.
            if not avail plani
            then next.
            if movim.emite = 22
            then next.

            if (movim.movtdc = 4 or
                movim.movtdc = 1) and
                movim.emite  < 90
            then next.


            find first t-movim where t-movim.rec = recid(movim) no-error.
            if not avail t-movim
            then do:
                create t-movim.
                assign t-movim.rec = recid(movim)
                       t-movim.dat = movim.datexp.
            end.
                   

        end.
  
        for each movim where movim.procod = produ.procod and
                             movim.desti  = vetbcod      and
                             movim.datexp = vdata no-lock:  

            find first plani where plani.etbcod = movim.etbcod and
                                   plani.placod = movim.placod and
                                   plani.movtdc = movim.movtdc and
                                   plani.pladat = movim.movdat no-lock.
            if not avail plani
            then next.
            if movim.emite = 22
            then next.

            if  movim.movtdc = 13 and
                movim.desti  < 90
            then next.
            
            find first t-movim where t-movim.rec = recid(movim) no-error.
            if not avail t-movim
            then do:
                create t-movim.
                assign t-movim.rec = recid(movim)
                       t-movim.dat = movim.datexp.
            end.
        end.
    end.
    run ext2003.p(input vetbcod,
                  input vprocod,
                  input vdata1,
                  input vdata2).
end.
