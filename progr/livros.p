{admcab.i}
def var vdoc like lfent02.documento.
def var cgc-admcom as char format "x(18)".
def var vv as int.

repeat:
    
    update vdoc label "Documento" colon 15
        with frame f1 width 80 side-label.
    
    for each lfent02 where lfent02.documento = vdoc and
                           lfent02.nat-oper  = "2.12".
                           
                           
        find first lfcad where lfcad.empcod = 52 and
                               lfcad.codigo = lfent02.codigo no-lock.
        
             
        disp lfent02.entrada  colon 15    
             lfent02.codigo   colon 15
             lfcad.nome       no-label
             lfcad.cgc        colon 15 
             lfent02.referencia column-label "Lanc" colon 15
                     with frame f1.
             
        for each fiscal where fiscal.desti = 999    and
                              fiscal.numero = vdoc and
                              fiscal.movtdc = 4    and
                              fiscal.opfcod = 212 no-lock.
                              
            
            find first forne where forne.forcod = fiscal.emite no-lock no-error.
            if avail forne
            then do:
            
                cgc-admcom = "".
            

                vv = 0. 
                do vv = 1 to 18:  
        
                    if substring(forcgc,vv,1) = "-" or
                       substring(forcgc,vv,1) = "." or
                       substring(forcgc,vv,1) = "\" or
                       substring(forcgc,vv,1) = "/"
                    then.
                    else cgc-admcom = cgc-admcom + substring(forcgc,vv,1). 

                end.

            end.
            
               
                       
            disp forne.forcod when avail forne
                 forne.fornom when avail forne with frame f2 centered down.
                                        
        end.
    end.

    
end.    
                               

