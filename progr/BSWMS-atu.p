/*
connect bswms -N tcp -S 1922 -H server.dep93
*/

for each com.produ where com.produ.datexp >= today - 30 
                no-lock.
   /* disp produ.procod. pause 0.*/
    find com.clase of com.produ no-lock no-error.
    if avail com.clase and com.clase.clacod <> 0
    then do.
        find wbsclapav where wbsclapav.clacod = com.clase.clacod no-error.
        if not avail wbsclapav
        then do.
            create wbsclapav.
            wbsclapav.clacod = com.clase.clacod.
            wbsclapav.clanom = com.clase.clanom.
        end.
    end.
    find wbsprodu where wbsprodu.procod = produ.procod no-error.
    if not avail wbsprodu 
    then do:
    create wbsprodu.
    find com.fabri of com.produ no-lock no-error.
    ASSIGN wbsprodu.procod            = com.produ.procod 
           wbsprodu.pronom            = com.produ.pronom 
           wbsprodu.cod-externo       = string(com.produ.procod)
           wbsprodu.fabnom            = if avail com.fabri
                                        then com.fabri.fabnom 
                                        else "".
    ASSIGN wbsprodu.clacod            = com.produ.clacod.
    end.
end.

