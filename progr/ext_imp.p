/******************************************************************************
* Programa  - confdev1.p                                                      *
*                                                                             *
* Funcao    - relatorio de conferencia das notas de devolucao de vendas       *
*                                                                             *
* Data       Autor          Caracteristica                                    *
* ---------  -------------  ------------------------------------------------- *
*******************************************************************************/

{admcab.i}
def var varquivo as char format "x(30)".
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
            with frame f-pro centered width 80  row 4 side-label.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom no-label with frame f-pro.

    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock no-error.

    sal-atu = estoq.estatual.
    sal-ant = estoq.estatual.
    t-sai   = 0.
    t-ent   = 0.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/ex" + string(time).
    else varquivo = "l:~\relat~\ex" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "80"
        &Page-Line = "66"
        &Nom-Rel   = ""EXT_IMP""
        &Nom-Sis   = """SISTEMA DE ESTOQUE    "" + estab.etbnom"
        &Tit-Rel   = """LISTAGEM DE PRODUTO"""
        &Width     = "80"
        &Form      = "frame f-cabcab"}

        display produ.procod
                produ.pronom  no-label
                vdata1 label "Data Inicial"
                vdata2 label "Data Final" with frame ff side-label.

        for each movim where movim.procod = produ.procod and
                             movim.datexp >= vdata1 no-lock by movim.datexp:

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
               /* plani.serie = "m1" */
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
               then do:
                   if movim.datexp > vdata2
                   then sal-atu = sal-atu + movim.movqtm.
                   if movim.datexp >= vdata1
                   then sal-ant = sal-ant + movim.movqtm.
               end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                if movim.datexp > vdata2
                then sal-atu = sal-atu - movim.movqtm.
                if movim.datexp >= vdata1
                then sal-ant = sal-ant - movim.movqtm.
            end.

            if movim.movtdc = 6
            then do:
                if plani.etbcod = vetbcod
                then do:
                    if movim.datexp > vdata2
                    then sal-atu = sal-atu + movim.movqtm.
                    if movim.datexp >= vdata1
                    then sal-ant = sal-ant + movim.movqtm.
                end.
                if plani.desti = vetbcod
                then do:
                    if movim.datexp > vdata2
                    then sal-atu = sal-atu - movim.movqtm.
                    if movim.datexp >= vdata1
                    then sal-ant = sal-ant - movim.movqtm.
                end.
            end.
            vmovtnom = "".
            find tipmov of movim no-lock.
            if movim.movtdc = 1
            then assign vmovtnom = "ORCAMENTO DE ENTRADA"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 4
            then assign vmovtnom = "ENTRADA"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 5
            then assign vmovtnom = "VENDA"
                        t-sai = t-sai + movim.movqtm.
            if movim.movtdc = 12
            then assign vmovtnom = "DEV.VENDA"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 13
            then assign vmovtnom = "DEV.FORN."
                        t-sai = t-sai + movim.movqtm.
            if movim.movtdc = 15
            then assign vmovtnom = "ENT.CONSERTO"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 16
            then assign vmovtnom = "REM.CONSERTO"
                        t-sai = t-sai + movim.movqtm.
            if movim.movtdc = 7
            then assign vmovtnom = "BAL.AJUS.ACR"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 8
            then assign vmovtnom = "BAL.AJUS.DEC"
                        t-sai = t-sai + movim.movqtm.
            if movim.movtdc = 6 and
            plani.etbcod = vetbcod
            then assign vmovtnom = "TRANSF.SAIDA"
                        t-sai = t-sai + movim.movqtm.
            if movim.movtdc = 6 and
            plani.desti  = vetbcod
            then assign vmovtnom = "TRANSF.ENTRA"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 17
            then assign vmovtnom = "TROCA DE ENTRADA"
                        t-ent = t-ent + movim.movqtm.
            if movim.movtdc = 18
            then assign vmovtnom = "TROCA DE SAIDA"
                        t-sai = t-sai + movim.movqtm.

            if movim.datexp >= vdata1 and movim.datexp <= vdata2
            then display movim.datexp format "99/99/9999"
                         VMOVTNOM column-label "Operacao" format "x(12)"
                         plani.numero
                         plani.emite column-label "Emitente" format ">>>>>>"
                         plani.DESTI column-label "Desti" format ">>>>>>>>"
                         movim.movqtm format ">>>>>9" column-label "Quant"
                         movim.movpc format ">,>>9.99" column-label "Valor"
                        (movim.movpc * movim.movqtm) column-label "Total"
                                with frame f-val 10 down overlay
                                    ROW 8 CENTERED.
            down with frame f-val.
        end.
    disp sal-ant label "Saldo Anterior" format "->>,>>9"
         sal-atu label "Saldo Atual" format "->>,>>9"
         t-ent   label "Ent" format ">>>>9"
         t-sai   label "Sai" format ">>>>9"
         with frame f-sal centered row 22 side-label overlay.
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i} .
    end.

    /*  Antigo - Imprimia direto na impressora
    dos  value("ved " + varquivo).
    message "Deseja Imprimir " update sresp.
    if sresp
    then dos silent value("type " + varquivo + "  > prn").
    */

end.
