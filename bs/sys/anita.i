    def var aux-anitai as int.
    def var aux-anita1 as char.
    def var aux-anita2 as char.
    def var aux-anita3 as char.
    
    aux-anita3 = "".
    
    do aux-anitai = 1 to num-entries({1},"@"):
        if aux-anitai = 1
        then aux-anita1 = entry(1,{1},"@").
        else aux-anita3 = aux-anita3 + entry(aux-anitai,{1},"@") + "@".
    end.    



    aux-anita2 = if num-entries(aux-anita1,"/") > 1
                 then entry(num-entries(aux-anita1,"/"),aux-anita1,"/")
                 else if num-entries(aux-anita1,"~\") > 1
                      then entry(num-entries(aux-anita1,"~\"),aux-anita1,"~\")
                      else aux-anita1.

    unix silent sh value("../bs/bin/lp-anita " +
                         aux-anita1 + " " +
                         aux-anita2 + " \"" +
                         aux-anita3 + "\"").
    


 