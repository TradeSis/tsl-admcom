def var sresp as log format "Sim/Nao".
def var vprocod like produ.procod.
update vprocod with side-label.
find produ where produ.procod = vprocod no-lock no-error.
if not avail produ
then do:
    message color redwith
    "Produto não encotrado"
    view-as alert-box.
    undo.
end.
disp produ.pronom no-label.    
def buffer bproduaux for produaux.
find first produaux where produaux.nome_campo  = "exporta-e-com"
                    and produaux.Valor_Campo = "yes" 
                    and produaux.procod = vprocod
                    no-lock no-error.
if avail produaux
then do:
    sresp = no.
    message "Confirma liberar produto para integração com Abacos?"
    update sresp.
    if sresp
    then do:
                    
    do on error undo:
        find first bproduaux where bproduaux.nome_campo  = "exporta-e-com"
                    and bproduaux.Valor_Campo = "yes" 
                    and bproduaux.procod = vprocod
                    .
                    
        bproduaux.tipo_campo = "".
    end.
    message color red/with
    "Produto liberado para proxima integração."
    view-as alert-box.
    end.
end.
else do:
    message color red/with
    "Produto não exporta para e-commerce."
    view-as alert-box.
    undo.
end.