{admcab.i new}

def var vlinha as char.

def var vforcod-aux as char.

def temp-table tt-imp 
    field nota      as integer format ">>>>>>>>>9"
    field data      as date
    field forcod    as integer format ">>>>>>>>>9".

def buffer bplani for plani.    
    
input from value("/admcom/audit/nf_dev_ipi.csv").

repeat:

    import vlinha.
    
    if num-entries(vlinha,";") >= 3    
    then do:
    
        assign vforcod-aux = entry(3,vlinha,";").
        
        assign vforcod-aux = replace(vforcod-aux,"F","").
        
        assign vforcod-aux = replace(vforcod-aux,"E","").

        create tt-imp.
        assign tt-imp.nota = integer(entry(1,vlinha,";"))
               tt-imp.data = date(entry(2,vlinha,";"))
               tt-imp.forcod = integer(vforcod-aux).
    
    end.

end.

for each tt-imp.

    find first plani where plani.etbcod = 993
                       and plani.numero = tt-imp.nota
                       and plani.desti = tt-imp.forcod no-lock no-error.
                  
    if avail plani
    then do:
        
        find first a01_infnfe where a01_infnfe.etbcod = plani.etbcod
                                and a01_infnfe.numero = plani.numero
                                and a01_infnfe.serie = "1"
                                            no-lock no-error.
        if avail a01_infnfe then do:
        
            find first B12_NFref of a01_infnfe no-lock no-error.
            /*
            if not avail B12_NFref
            then 
            message "Nao " view-as alert-box.
            else*/
            
            if avail B12_NFref
            then do:
             
                find first bplani where bplani.numero = B12_NFref.nnf
                                    and bplani.movtdc = 4
                                    and bplani.desti = tt-imp.forcod
                                               no-lock no-error.
                
                if avail bplani
                then do:
                    
                    display plani.numero (count) .
                    pause 0.
                            
                end.
            end.
        end.
    end.
end.





