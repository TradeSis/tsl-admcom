{admcab.i new}

def var vtime     as   int.
def var vprocod   like produ.procod.
def var vestcusto like estoq.estcusto.
def var vcusant   like estoq.estcusto.

do on error undo:

    update vprocod format ">>>>>>>>>9" label "Produto......."
           with frame f-pro width 80 side-labels.

    find produ where produ.procod = vprocod no-lock no-error.
    
    if not avail produ
    then do:
        message "Produto nao cadastrado.".
        undo.
    end.
    else disp produ.pronom no-label with frame f-pro.

end.

find first estoq where estoq.procod = produ.procod no-lock no-error.
if not avail estoq
then do:
    message "Produto sem registro de estoque.".
    undo.
end.
else vcusant = estoq.estcusto.

disp skip estoq.estcusto label "Pc.Custo Atual"
     skip with frame f-pro.

do on error undo:

    update vestcusto label "Novo Pc.Custo."
           with frame f-pro.

    if vestcusto = 0       
    then do:
        message "Preco de Custo Invalido".
    end.
    
end.

vtime = 0.
vtime = time.

find lgaltcus where lgaltcus.procod = produ.procod
                and lgaltcus.datalt = today
                and lgaltcus.horalt = vtime no-error.
if not avail lgaltcus 
then do:
    create lgaltcus.
    assign lgaltcus.procod = produ.procod
           lgaltcus.datalt = today
           lgaltcus.horalt = vtime
           lgaltcus.cusant = vcusant
           lgaltcus.cusalt = vestcusto.
end.                

for each estoq where estoq.procod = produ.procod:
    assign estoq.estcusto = vestcusto
           estoq.datexp   = today.
end.
