{admcab.i}
disable triggers for load of finloja.titulo.


/******************** TITULO ABERTOS *************************/
for each finloja.titulo where finloja.titulo.clifor = 01:
                                
    display "Deletando titulos a vista...."
                 finloja.titulo.clifor
                 finloja.titulo.titdtven format "99/99/9999" no-label
                        with frame f2 1 down centered.
    pause 0.         

    if finloja.titulo.titsit = "PAG" and
       finloja.titulo.titdtemi < today - 30
    then do transaction:
        delete finloja.titulo.
    end.

end.



    



         

                       
