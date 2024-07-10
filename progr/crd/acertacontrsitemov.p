def input param par-rec as recid.
find contrsite where recid(contrsite) = par-rec no-lock no-error.
if not avail contrsite then return.
find contrato where contrato.contnum = contrsite.contnum no-lock.

def shared temp-table ttcancela no-undo
    field prec as recid
    field operacao as char    
    field qtddevol as int
    field valordevol as dec.

def var vtotalproduto as dec.
def var vpercitem as dec.
def var vvalorFrete as dec.
def var vdevol as int.
def var vpeso as log.

                vvalorFrete   = 0.
                vtotalproduto = 0.
                vdevol = 0.
                for each contrsitem of contrsite no-lock.
                    vtotalproduto = vtotalproduto + contrsitem.valorTotal + contrsitem.valorFrete.
                    vvalorFrete   = vvalorFrete + contrsitem.valorFrete.
                    vdevol = vdevol + contrsitem.qtddevol.
                end.
                if vdevol = 0
                then do:
                    if vvalorFrete = 0 and contrsite.valorFrete > 0
                    then do:
                        for each contrsitem of contrsite.
                            vpercitem = contrsitem.valorTotal / vtotalproduto.
                            contrsitem.valorFrete = (contrsite.valorFrete * vpercitem).   
                        end.
                    end.
                    vpeso = no.
                    for each contrsitem of contrsite.
                        vpercitem = (contrsitem.valorTotal + contrsitem.valorFrete) / vtotalproduto.
                        contrsitem.valorPeso = (contrato.vltotal * vpercitem).   
                        vpeso = yes.
                        contrsitem.valorAcres = contrsitem.valorPeso - contrsitem.valorTotal - contrsitem.valorFrete.
                    end.
                    if vpeso
                    then do:
                        for each contrsitem of contrsite.
                            for each ttcancela where ttcancela.prec = recid(contrsitem). 
                                ttcancela.valordevol = round(ttcancela.qtddevol * (contrsitem.valorPeso / contrsitem.qtd) ,2).
                            end.    
                        end.
                    end.
                end.
                       
    for each contnf where contnf.etbcod = contrsite.etbcod and contnf.contnum = contrsite.contnum no-lock.
        find plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod
                         no-lock no-error.
        if avail plani
        then do:
            for each movim where movim.etbcod = plani.etbcod and 
                                 movim.placod = plani.placod no-lock.

                find first contrsitem of contrsite where
                        contrsitem.codigoProduto = movim.procod
                        no-error.
                if avail contrsitem
                then do:
                    find first contrsitmov where
                            contrsitmov.etbcod          = contrsitem.etbcod and
                            contrsitmov.codigoPedido    = contrsitem.codigoPedido and
                            contrsitmov.codigoProduto   = contrsitem.codigoProduto and
                            contrsitmov.placod          = movim.placod and
                            contrsitmov.movseq          = movim.movseq
                            no-lock no-error.
                    if not avail contrsitmov
                    then do:
                        create contrsitmov. 
                        contrsitmov.etbcod          = contrsitem.etbcod.
                        contrsitmov.codigoPedido    = contrsitem.codigoPedido.
                        contrsitmov.codigoProduto   = contrsitem.codigoProduto.
                        contrsitmov.placod          = movim.placod.
                        contrsitmov.movseq          = movim.movseq.
                        contrsitmov.qtd             = movim.movqtm.
                    end.                        
                end.                    
            end.
        end.
    end.
 