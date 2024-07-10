/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def shared temp-table t-movim
    field rec as recid
    field dat like plani.pladat.
    
def var vmes as int format "99".
def var vano as int format "9999".
def var t-sai   like plani.platot.
def var t-ent   like plani.platot.
def var vdata   like plani.pladat.
def input parameter vetbcod like estab.etbcod.
def input parameter vprocod like produ.procod.
def var vtotdia like plani.platot.
def var vtot  like movim.movpc.
def var vtotg like movim.movpc.
def var vtotgeral like plani.platot.
def input parameter vdata1 like plani.pladat label "Data".
def input parameter vdata2 like plani.pladat label "Data".
def var vtotal like plani.platot.
def var vtoticm like plani.icms.
def var vtotmovim   like movim.movpc.
def var vmovtnom  like tipmov.movtnom.
def var vsalant   like estoq.estatual.
def var sal-ant   like estoq.estatual.
def var sal-atu   like estoq.estatual.
              /**** Campo usado para guardar o no. da planilha ****/


    vtotmovim = 0.
    vtotgeral = 0.
    sal-atu = 0.
    sal-ant = 0.
    vsalant = 0.

    find estab where estab.etbcod = vetbcod no-lock.
    find produ where produ.procod = vprocod no-lock.

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

    sal-atu = sal-ant.
    t-sai   = 0.
    t-ent   = 0.

 
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock no-error.

    
    for each t-movim by t-movim.dat: 
        find movim where recid(movim) = t-movim.rec no-lock no-error.

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat
                                                     no-lock no-error.

        if not avail plani
        then next.
        if plani.etbcod <> vetbcod and
           plani.desti  <> vetbcod
        then next.
        if plani.emite = 22
        then next.

        if plani.movtdc = 5 and
           plani.emite  <> estab.etbcod
        then next.

        find tipmov of movim no-lock.
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
           movim.movtdc = 12 or
           movim.movtdc = 15 or
           movim.movtdc = 17
        then sal-atu = sal-atu + movim.movqtm.

        if movim.movtdc = 6
        then do:
            if plani.etbcod = vetbcod
            then sal-atu = sal-atu - movim.movqtm.

            if plani.desti = vetbcod
            then sal-atu = sal-atu + movim.movqtm.
        end.
        vmovtnom = "".
        find tipmov of movim no-lock.
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
        if movim.movtdc = 6 and
           plani.etbcod = vetbcod
        then do:
            vmovtnom = "TRANSF.SAIDA".
            t-sai = t-sai + movim.movqtm.
        end.
        if movim.movtdc = 6 and
           plani.desti  = vetbcod
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

        display movim.datexp format "99/99/9999" column-label "Data Saida"
                VMOVTNOM column-label "Operacao" format "x(12)"
                plani.numero
                plani.serie column-label "SE" format "x(02)"
                plani.emite column-label "Emitente" format ">>>>>>"
                plani.DESTI column-label "Desti" format ">>>>>>>>"
                movim.movqtm format ">>>>>9" column-label "Quant"
                movim.movpc format ">,>>9.99" column-label "Valor"
             /*   (movim.movpc * movim.movqtm) column-label "Total" */
                sal-atu format "->>>>9" column-label "Saldo"
                           with frame f-val 10 down overlay
                                 ROW 9 CENTERED color white/gray.
                    color display red/gray movim.movqtm with frame f-val.
        down with frame f-val.
    end.
    disp sal-ant label "Saldo Anterior" format "->>>>9"
         t-ent   label "Ent" format ">>>>9"
         t-sai   label "Sai" format ">>>>9"
         estoq.estatual label "Saldo Atual" format "->>>>9"
                    with frame f-sal centered row 22 side-label no-box
                                        color white/red overlay.
