{admcab.i}
{setbrw.i}
assign
    a-seeid = -1
    a-recid = -1
    a-seerec = ?.
def temp-table tt-categoria like categoria
    field marca as char
    .
for each tt-categoria:
    delete tt-categoria.
end.
for each categoria.
    create tt-categoria.
    buffer-copy categoria to tt-categoria.
end.     
form tt-categoria.marca   no-label format "x"
     tt-categoria.catcod  label "Cod"
     tt-categoria.catnom
     with frame f-cate down centered.

{sklcls.i
    &help = "ENTER=Marca/Desmarca  F4=Retorna"
    &file = tt-categoria
    &cfield = tt-categoria.catnom
    &ofield = " tt-categoria.marca
                tt-categoria.catcod
              "
    &where = true
    &aftselect1 = "
        if keyfunction(lastkey) = ""RETURN""
        then do:
            if tt-categoria.marca = """"
            then tt-categoria.marca = ""*"".
            else tt-categoria.marca = """".
            disp tt-categoria.marca with frame f-cate.
            next.
        end."
    &form = " frame f-cate "
    }.
sretorno = "".
for each tt-categoria where marca <> "" no-lock:
    sretorno = sretorno + string(tt-categoria.catcod,">>9") + " ; " .
end.        
hide frame f-cate no-pause.