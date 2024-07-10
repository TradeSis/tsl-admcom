{admcab.i}
def var vmovtnom like tipmov.movtnom.
def var vdt     as date.
def var vetbcod like estab.etbcod.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vprocod like produ.procod.
def var vmes as int.
def var vano as int.
def var vest like estoq.estatual.
def var vant like estoq.estatual.

repeat:
    update vetbcod colon 16 with frame f1 side-label centered.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final  " colon 16 with frame f1.
    update vprocod colon 16 with frame f1.
    find produ where produ.procod = vprocod no-lock.
    disp produ.pronom no-label with frame f1.
    find estoq where estoq.etbcod = estab.etbcod and
                     estoq.procod = produ.procod no-lock no-error.
    display estoq.estatual label "Qtd" format "->>,>>9.99" colon 16
            estoq.estcusto with frame f1.

    for each movim where movim.procod = produ.procod and
                         movim.etbcod = estab.etbcod and
                        (movim.movtdc = 4            or
                         movim.movtdc = 1)           and
                         movim.datexp >= vdti        and
                         movim.datexp <= vdtf no-lock:

        find first plani where plani.etbcod = movim.etbcod and
                               plani.placod = movim.placod and
                               plani.movtdc = movim.movtdc and
                               plani.pladat = movim.movdat no-lock no-error.

        if not avail plani
        then next.

        find tipmov of movim no-lock.

        if plani.etbcod = vetbcod or
           plani.desti  = vetbcod

        then do:
            if movim.movtdc = 5 or
               movim.movtdc = 13 or
               movim.movtdc = 14 or
               movim.movtdc = 16 or
               movim.movtdc = 8  or
               movim.movtdc = 18
            then do:
                vest = vest - movim.movqtm.
                if movim.movdat < vdti
                then vant = vant - movim.movqtm.
            end.

            if movim.movtdc = 4 or
               movim.movtdc = 1 or
               movim.movtdc = 7 or
               movim.movtdc = 12 or
               movim.movtdc = 15 or
               movim.movtdc = 17
            then do:
                vest = vest + movim.movqtm.
                if movim.movdat < vdti
                then vant = vant + movim.movqtm.
            end.
            if movim.movtdc = 6
            then do:
                if plani.etbcod = estab.etbcod
                then do:
                    vest = vest - movim.movqtm.
                    if movim.movdat < vdti
                    then vant = vant - movim.movqtm.
                end.

                if plani.desti  = estab.etbcod
                then do:
                    vest = vest + movim.movqtm.
                    if movim.movdat < vdti
                    then vant = vant + movim.movqtm.
                end.
            end.
            vmovtnom = "".
            find tipmov of movim no-lock.
            if movim.movtdc = 1
            then vmovtnom = "ORCAMENTO DE ENTRADA".
            if movim.movtdc = 4
            then vmovtnom = "ENTRADA".
            if movim.movtdc = 5
            then vmovtnom = "VENDA".
            if movim.movtdc = 12
            then vmovtnom = "DEV.VENDA".
            if movim.movtdc = 13
            then vmovtnom = "DEV.FORN.".
            if movim.movtdc = 15
            then vmovtnom = "ENT.CONSERTO".
            if movim.movtdc = 16
            then vmovtnom = "REM.CONSERTO".
            if movim.movtdc = 7
            then vmovtnom = "BAL.AJUS.ACR".
            if movim.movtdc = 8
            then vmovtnom = "BAL.AJUS.DEC".
            if movim.movtdc = 6 and
            plani.etbcod = vetbcod
            then vmovtnom = "TRANSF.SAIDA".
            if movim.movtdc = 6 and
            plani.desti  = vetbcod
            then vmovtnom = "TRANSF.ENTRA".
            if movim.movtdc = 17
            then vmovtnom = "TROCA DE ENTRADA".
            if movim.movtdc = 18
            then vmovtnom = "TROCA DE SAIDA".

        if movim.movdat >= vdti and
           movim.movdat <= vdtf
        then
            display movim.datexp format "99/99/9999" column-label "Data"
                     VMOVTNOM column-label "Operacao" format "x(15)"
                     plani.numero format ">>>>>>9"
                     plani.emite column-label "Emite" format ">>>>>>>"
                     plani.DESTI column-label "Desti" format ">>>>>>>>"
                     movim.movqtm format ">>>>>9" column-label "Quant"
                     movim.movpc format ">,>>9.99" column-label "Valor"
                     (movim.movpc * movim.movqtm) column-label "Total"
                         with frame f-val 9 down
                                    ROW 10 CENTERED color white/gray no-box.
        end.

    end.
end.
