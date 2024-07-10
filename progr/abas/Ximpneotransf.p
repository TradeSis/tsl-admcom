def var vdir     as char format "x(40)" init "". 
def var varquivo as char format "x(40)" init "XD_AAAAMMDD_lin_ped_liberado_ transf.txt".

def var pabtcod like abastransf.abtcod.

def temp-table tt-transf no-undo
    field pedido as char    format "x(20)"
    field procod as char    format "x(10)"
    field etbcod as char    format "x(10)"
    field dttransf as char    format "x(10)"
    field qtd    as char    format "x(12)"

    field procodorigem as char    format "x(10)"

    field etbCD  as char    format "x(10)"
    field dtmov  as char    format "x(10)"

    field forne  as char    format "x(18)"
    field dtprog as char    format "x(10)".

update vdir     label "Dir" colon 16
       varquivo label "Arq" colon 16
       with side-labels centered.

find abastipo where abastipo.abatipo = "NEO" no-lock.
       
input from value(vdir + "/" + varquivo).       
repeat.       
    create tt-transf.
    import delimiter ";" tt-transf.

    find first abastransf where
            abastransf.abatipo      = abastipo.abatipo and
            abastransf.pedexterno   = tt-transf.pedido
            no-lock no-error.
    if avail abastransf
    then next.
    
     
    run abas/transfcreate.p (abastipo.abatipo, 
                             int(tt-transf.etbcod),
                             int(tt-transf.procod),
                             int(replace(tt-transf.qtd,",",".")),
                             "",
                             date(int(substring(tt-transf.dttransf,5,2)),
                                        int(substring(tt-transf.dttransf,7,2)),
                                        int(substring(tt-transf.dttransf,1,4))),
                             "EXTERNO=" + tt-transf.pedido,  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                             "Importacao Neogrid",
                             output pabtcod).

    
end.    
input close.

