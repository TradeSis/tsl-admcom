def var vdir     as char format "x(40)" init "". 
def var varquivo as char format "x(40)" init "XD_20190401_LIN_PED_LIBERADO.TXT".

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
    pause.
    find first abascompra where
            abascompra.abatipo      = abastipo.abatipo and
            abascompra.pedexterno   = tt-compra.pedido
            no-lock no-error.
    if avail abascompra
    then next.
    
    create abascompra.    
    ASSIGN
        abascompra.AbCCod        = next-value(seq-abastransf).
        abascompra.EtbCod        = int(tt-compra.etbcod).
        abascompra.procod        = int(tt-compra.procod).
        abascompra.AbcQtd        = dec(replace(tt-compra.qtd,",",".")).
        abascompra.AbCSit        = "ABE".
        abascompra.forcod        = int(tt-compra.forne).
        abascompra.DtPrevEntrega = date(int(substring(tt-compra.dtprev,5,2)),
                                        int(substring(tt-compra.dtprev,7,2)),
                                        int(substring(tt-compra.dtprev,1,4))).
                                        
        abascompra.abatipo       = abastipo.abatipo.
        abascompra.AbcObs        = "NEOGRID".
end.    
input close.

