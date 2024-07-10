{admcab.i new}

def var vmenuecom as char extent 15 format "x(40)" initial
    ["Exportar produtos", 
     ""].
def var vexececom as char extent 15 format "x(40)" initial
    ["ecom/expprodu.p",
     ""].

message "Conectando ao banco ECommerce...". 
connect ecommerce -H "erp.lebes.com.br" -S sdrebecommerce -N tc~p -ld                                                     ecommerce no-error.
repeat.
    disp vmenuecom with frame fmenu row 3 centered 1 col no-labels.
    choose field vmenuecom with frame fmenu.
    if search (vexececom[frame-index]) <> ?
    then do:
        hide frame fmenu no-pause.
        run value(vexececom[frame-index]).
    end.
end.

if connected ("ecommerce")
then disconnect ecommerce.
