def var vdir     as char format "x(40)" init "". 
def var varquivo as char format "x(40)" init "XD_20190401_LIN_PED_LIBERADO.TXT".

def var pabccod like abascompra.abccod.

def temp-table tt-compra no-undo
    field pedido as char    format "x(20)"
    field procod as char    format "x(10)"
    field etbcod as char    format "x(10)"
    field dtprev as char    format "x(10)"
    field qtd    as char    format "x(12)"
    field forne  as char    format "x(18)"
    field dtprog as char    format "x(10)".

update vdir     label "Dir" colon 16
       varquivo label "Arq" colon 16
       with side-labels centered.

find abastipo where abastipo.abatipo = "NEO" no-lock.
       
input from value(vdir + "/" + varquivo).       
repeat.       
    create tt-compra.
    import delimiter ";" tt-compra.
    disp tt-compra.
    find first abascompra where
            abascompra.abatipo      = abastipo.abatipo and
            abascompra.pedexterno   = tt-compra.pedido
            no-lock no-error.
    if avail abascompra
    then next.
    
    run abas/compracreate.p (abastipo.abatipo, 
                             int(tt-compra.etbcod),
                             int(tt-compra.procod),
                             int(replace(tt-compra.qtd,",",".")),
                             "",
                             int(tt-compra.forne),
                             date(int(substring(tt-compra.dtprev,5,2)),
                                        int(substring(tt-compra.dtprev,7,2)),
                                        int(substring(tt-compra.dtprev,1,4))),
                             "EXTERNO=" + tt-compra.pedido,  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                             "Importacao Neogrid",
                             output pabccod).
        
        
end.    
input close.

