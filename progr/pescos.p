/*----------------------------------------------------------------------------*/
/* /usr/admcom/es/pesco.p                                  Posicao de Estoque */
/*                                                                            */
/* Data     Autor   Caracteristica                                            */
/* -------- ------- ------------------                                        */
/* 27/02/92 Miguel  Criacao                                                   */
/*----------------------------------------------------------------------------*/
{admcab.i}
def buffer bestoq for estoq.
def temp-table wpro
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field prounven like produ.prounven
    field estvenda like estoq.estvenda
    field estatual like estoq.estatual.

define variable wcod as integer format "999999".
repeat with side-labels width 80 frame f1 title " Produto ":
    for each wpro:
        delete wpro.
    end.
    prompt-for skip(1) produ.procod colon 12 with no-validate.
    find produ using produ.procod no-lock.
    find last bestoq where bestoq.procod = produ.procod no-lock.
    display bestoq.estcusto
            bestoq.estvenda .
    find fabri of produ no-lock.
    display produ.pronom + "-" + fabri.fabfant format "x(64)" label "Descricao"
                                   colon 12 skip(1).
    message "Todas filiais: " update sresp.
    for each estab no-lock by estab.etbnom:
        if not sresp
        then do:
        if estab.etbcod <> 01 and
           estab.etbcod <> 03 and
           estab.etbcod <> 04 and
           estab.etbcod <> 05 and
           estab.etbcod <> 06 and
           estab.etbcod <> 07 and
           estab.etbcod <> 08 and
           estab.etbcod <> 09 and
           estab.etbcod <> 13 and
           estab.etbcod <> 14 and
           estab.etbcod <> 15 and
           estab.etbcod <> 16 and
           estab.etbcod <> 18 and
           estab.etbcod <> 12 and
           estab.etbcod <> 23 and
           estab.etbcod <> 25 and
           estab.etbcod <> 26 and
           estab.etbcod <> 27 and
           estab.etbcod <> 28 and
           estab.etbcod <> 29 and
           estab.etbcod <> 30 and
           estab.etbcod <> 31 and
           estab.etbcod <> 32 and
           estab.etbcod <> 33 and
           estab.etbcod <> 34 and
           estab.etbcod <> 35 and
           estab.etbcod <> 36 and
           estab.etbcod <> 37 and
           estab.etbcod <> 996 and
           estab.etbcod <> 997 and
           estab.etbcod <> 998 and
           estab.etbcod <> 999
        then next.
        end.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        create wpro.
        assign wpro.etbcod = estab.etbcod
               wpro.etbnom = estab.etbnom
               wpro.prounven = produ.prounven
               wpro.estvenda = estoq.estvenda
               wpro.estatual = estoq.estatual.

        display space(1) estab.etbcod
                space(1) estab.etbnom
                space(1) produ.prounven
                space(1) estoq.estvenda
                space(1) estoq.estatual FORMAT "->>>,>>9" (total)
                     with width 80 frame f3 title " Estoque " down.
    end.
    message "Confirma impressao da consulta" update sresp.
    if sresp
    then do:
        {mdadmcab.i
            &Saida     = "printer"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """SALDO DE PRODUTO"""
            &Width     = "130"
            &Form      = "frame f-cabcab"}
        display produ.procod
                produ.pronom with frame f-pro side-label width 80.
        for each wpro by wpro.etbcod:

            display space(1) wpro.etbcod
                    space(1) wpro.etbnom
                    space(1) wpro.prounven
                    space(1) wpro.estvenda
                    space(1) wpro.estatual FORMAT "->>>,>>9" (total)
                            with width 80 frame f4 down.
        end.
     END.
     OUTPUT CLOSE.

end.
