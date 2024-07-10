def var vetbcod like estab.etbcod.

def temp-table tt-est
    field etbcod   like estoq.etbcod
    field procod   like estoq.procod
    field estideal like estoq.estideal.
    
update
      vetbcod.

message "Importando arquivo...".
input from /usr/admcom/progr/est-31.d.
    repeat:
        create tt-est.
        import tt-est.
    end.
input close.

def var vtotal as int format ">>>>>>>9".

message "Zerando estideal...".
for each estoq where estoq.etbcod = vetbcod:
    estoq.estideal = 0.
end.
hide message no-pause.
message "atualizando estideal...".
for each tt-est where tt-est.etbcod = vetbcod:

    find estoq where estoq.etbcod = tt-est.etbcod
                 and estoq.procod = tt-est.procod no-error.
    
    if avail estoq
    then                                            
        assign estoq.estideal = tt-est.estideal.
    
end.    
hide message no-pause.
message "Contando estideal...".
for each estoq where estoq.etbcod = vetbcod no-lock.
    if estoq.estideal <= 0 then next.
    vtotal = vtotal + estoq.estideal.
end.
hide message no-pause.
message "Atualizacao concluida... Total atualizado = " vtotal.
pause.
