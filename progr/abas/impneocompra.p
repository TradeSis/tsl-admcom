{/admcom/progr/admbatch.i}

def var pabccod like abascompra.abccod.

def shared temp-table ttarq no-undo
    field arq as char format "x(50)"
    field interface     as char 
    field Arquivo       as char initial ?
    field diretorio     as char
    index idx is unique primary interface asc Arquivo asc.

def temp-table tt-compra no-undo
    field pedido as char    format "x(20)"
    field procod as char    format "x(10)"
    field etbcod as char    format "x(10)"
    field dtprev as char    format "x(10)"
    field qtd    as char    format "x(12)"
    field forne  as char    format "x(18)"
    field dtprog as char    format "x(10)".


def var vconta as int.
def var vlinha as char.

def var vhora as int.
def var vminu as int.
def var vdeletaarquivo as log.

    find abastipo where abastipo.abatipo = "NEO" no-lock.

    for each ttarq where ttarq.interface = "XD*lin_ped_compras" and 
                /* Esta interface */
                         ttarq.arq <> "".

        vDeletaArquivo = yes.

            
            vconta = 0. 
            input from value(ttarq.arq) no-echo.
            repeat.
                vconta = vconta + 1.

                create tt-compra.
                import delimiter ";" tt-compra.

                find first abascompra where
                        abascompra.abatipo      = abastipo.abatipo and
                        abascompra.pedexterno   = tt-compra.pedido
                        no-lock no-error.
                if avail abascompra
                then next.
                

                find estoq where estoq.etbcod = 900 and 
                                 estoq.procod = int(tt-compra.procod)
                    no-lock no-error.
                                  
                run abas/compracreate.p (abastipo.abatipo, 
                             int(tt-compra.etbcod),
                             int(tt-compra.procod),
                             dec(replace(tt-compra.qtd,",",".")),
                             "",
                             if avail estoq
                             then estoq.estcusto
                             else 0,
                             int(tt-compra.forne),
                             date(int(substring(tt-compra.dtprev,5,2)),
                                        int(substring(tt-compra.dtprev,7,2)),
                                        int(substring(tt-compra.dtprev,1,4))),
                             "EXTERNO=" + tt-compra.pedido,  /* ORIGEM DIGITADO,MOVIM,EXTERNO*/
                             "Importacao Neogrid",
                             output pabccod).
                             

                delete tt-compra.                                
            end.
            input close.

        if vDeletaArquivo
        then unix silent value("mv -f " + ttarq.arq + " " + 
                                ttarq.diretorio + "/" + "OK_" + ttarq.arquivo).

    end.              

