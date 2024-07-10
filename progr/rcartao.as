        if keyfunction(lastkey) = "return"
                    then do:
                        update
                            reccar.datrec 
                            reccar.lote
                            reccar.numres 
                            reccar.numpar
                            reccar.titdtven
                            reccar.titvlcob
                            reccar.titvldes
                            reccar.titvlpag
                            with frame f-consulta.
                        assign
                            v-totvl = 0 v-totdesc = 0 v-totliq = 0.
                        for each    reccar where   
                                    reccar.etbcod  = estab.etbcod and
                                    reccar.rede    = vindex
                                    no-lock :
                            assign
                                v-totdesc = v-totdesc + reccar.titvldes
                                v-totliq = v-totliq + reccar.titvlpag
                                v-totvl = v-totvl + reccar.titvlcob.
                        end.        
                        disp
                            v-totvl
                            v-totdesc
                            v-totliq  
                            with frame f-totais.

                        next keys-loop.
                    end. 

{rcartao.ok}