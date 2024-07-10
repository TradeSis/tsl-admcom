def var pabtcod like abastransf.abtcod.
def var vestatual like estoq.estatual format "->>>>>>>>>9.99".
def var vcriado as log.
pause 0 before-hide.

for each estab no-lock.
    disp estab.etbcod.
    for each plani where 
        plani.movtdc = 5 and
        plani.etbcod = estab.etbcod and
        plani.pladat = today
        no-lock.
    
        disp plani.etbcod numero .
        
        
        for each movim where 
                movim.etbcod = plani.etbcod and 
                movim.placod = plani.placod
                no-lock.
            
            disp movim.procod movim.movqtm.
            
            find first abastransf where 
                        abastransf.orietbcod = movim.etbcod and
                        abastransf.oriplacod = movim.placod and
                        abastransf.procod    = movim.procod 
                 no-error.
            disp avail abastransf format "Criado/".
            
            if not avail abastransf
            then do.
                
                vcriado = no.
                    
                find first pdvdoc where pdvdoc.etbcod = plani.etbcod and
                                        pdvdoc.placod = plani.placod
                    no-lock no-error.
                if avail pdvdoc                                               
                then do:
                    find pdvmov of pdvdoc no-lock.
                    
                    find first pdvcab_pedido of pdvdoc
                        no-lock no-error.
                    if avail pdvcab_pedido
                    then do:
                        
                        disp pdvcab_pedido.loja_destino pdvcab_pedido.data_entrega pdvdoc.numero_pedido.
                        
                        if pdvmov.tipo_pedido = 2
                        then do:

                            find first abastipo where abastipo.abatipo = "OUT" and
                                                abastipo.origemvenda = yes no-lock.
                    
                            if avail abastipo
                            then do:
                                run abas/transfcreate.p 
                                        (abastipo.abatipo,  
                                         pdvcab_pedido.loja_destino,
                                         movim.procod,
                                         movim.movqtm,
                                         "",
                                         pdvcab_pedido.data_entrega - 1,
                                         "MOVIM=" + string(recid(movim)),
                                         "PEDIDO_P2K=" + string(pdvdoc.numero_pedido),
                                         output pabtcod).
                                disp pabtcod.
                            end.
                            
                        end.
                        vcriado = yes.
                    end.
                    else do:
                        find first pdvmovim of pdvmov where
                            pdvmovim.procod = movim.procod
                            no-lock no-error.
                        if avail pdvmovim
                        then do:    
                            if pdvmovim.dt_prevista_entrega <> ?
                            then do:
                               find first abastipo where abastipo.abatipo = "FUT" and
                                                    abastipo.origemvenda = yes no-lock.
                    
                                if avail abastipo
                                then do:
                                    run abas/transfcreate.p 
                                            (abastipo.abatipo,  
                                             movim.etbcod,
                                             movim.procod,
                                             movim.movqtm,
                                             "",
                                             pdvmovim.dt_prevista_entrega - 1,
                                             "MOVIM=" + string(recid(movim)),
                                             "",
                                             output pabtcod).
                                    disp pabtcod.
                                    vcriado = yes.
                                end.
 
                            end.
                            else do:
                                /**
                                if pdvmovim.dt_pedido_especial <> ?
                                then do:
                                    find first abastipo where abastipo.abatipo = "ESP" and
                                                        abastipo.origemvenda = yes no-lock.
                    
                                    if avail abastipo
                                    then do:
                                        find produ of movim no-lock.
                                        if produ.proipival = 1
                                        then do:
                                            run abas/transfcreate.p 
                                                    (abastipo.abatipo,  
                                                     movim.etbcod,
                                                     movim.procod,
                                                     movim.movqtm,
                                                     "",
                                                     pdvmovim.dt_pedido_especial,
                                                     "MOVIM=" + string(recid(movim)),
                                                     "PEDIDO=" + string(pdvdoc.numero_pedido),
                                                     output pabtcod).
                                            disp pabtcod.
                                            vcriado = yes.
                                        end.
                                    end.
                                end.
                                **/
                            end.
                        end.
                    
                    
                    end.

                end.
                        
                
                
                
                if vcriado = no
                then do:
                    find  estoq where estoq.etbcod = plani.etbcod and
                                      estoq.procod = movim.procod
                        no-lock no-error.
                    vestatual = if avail estoq then estoq.estatual else 0.
                    disp movim.procod movim.movqtm vestatual.

                    if vestatual < 0
                    then do:
                    
                        run abas/transfgera.p (recid(movim)).
                    end.
                end.
            
            end.
                            
        end.
    end.
end.

message "FIM".
pause 5.