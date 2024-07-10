{admcab.i}
def input parameter vprocod like produ.procod.
def input parameter vqtd like estoq.estatual.
def output parameter vok as log.

vok = yes.

            find estoq where estoq.etbcod = setbcod and
                             estoq.procod = vprocod
                       no-lock no-error.
            if  (estoq.estatual >= 0 and 
                 estoq.estatual - vqtd < 0) or 
                 estoq.estatual < 0
            then do:
                vok = no.
                display "Qtd Estoque : " at 5 estoq.estatual
                                         no-label format "->>>>9"
                        "Qtd Desejada: " at 5 vqtd
                                         no-label format "->>>>9"
                            with frame faviso row 10 overlay centered
                            title "Estoque nao possui esta quantidade".
                pause.
            end.
            hide frame faviso no-pause.

