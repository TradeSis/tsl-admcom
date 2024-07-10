{admcab.i new}

def var varquivo as char format "x(60)".

update varquivo label "Arquivo"
    with frame f1 1 down side-label width 80.

if search(varquivo) = ?
then do:
    message color red/with
    "Arquivo nao encontrado."
    view-as alert-box.
    undo.
end.

def temp-table tt-produ 
    field procod like produ.procod.
input from value(varquivo).
repeat:
    create tt-produ.
    import tt-produ.
end.
input close.
for each tt-produ where tt-produ.procod > 0:
    find produ where produ.procod = tt-produ.procod no-lock no-error.
    if not avail produ then next.
    if produ.catcod = 41
    then next.
    disp produ.procod 
         produ.pronom with frame f2 1 down no-label row 10 centered no-box
         color message.
    pause 0.     
    find first produaux where
               produaux.procod = produ.procod and
               produaux.nome_campo = "Etiqueta-Preco" and
               produaux.valor_campo = "Sim"
               no-error.
    if not avail produaux
    then do:
        create produaux.
        produaux.procod = produ.procod.
        produaux.nome_campo = "Etiqueta-Preco".
        produaux.valor_campo = "Sim".
        produaux.datexp = ?.
    end.               
end.    
message "FIM DA IMPORTACAO..." .   
