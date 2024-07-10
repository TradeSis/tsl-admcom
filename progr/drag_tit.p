def input parameter vetbcod like titulo.etbcod.
def input parameter vcobcod like cobranca.cobcod.
def var i as int.
            repeat:
             
                message "Conectando.....D .".
                connect dragao -H erp.lebes.com.br -S sdragao -N tcp -ld d
                                            no-error.
       
                if not connected ("d")
                then do:
                    if i = 1 
                    then leave.
                    i = i + 1.
                    next.
               end. 
               else leave.
            end.
            for each cobranca where cobranca.etbcod = vetbcod and
                            cobranca.cobcod = vcobcod
                            no-lock.
                run busdra02.p(cobranca.clicod).
            end.
            disconnect d.
            hide message no-pause.
            pause 2 message "Desconectando......".

