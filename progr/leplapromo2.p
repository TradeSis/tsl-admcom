
def input parameter p-rec as recid.
def input parameter p-procod like produ.procod.
def output parameter vpromo as log.
def output parameter vprecoliberado as log.

def var na-promocao as log.

def buffer bctpromoc for ctpromoc.

def shared temp-table tt-ctpromoc like ctpromoc.

def var vi as int.
def var v0 as int.
def var v1 as int.
def var v2 as int.
def var v3 as int.
def var v4 as int extent 20.

find plani where recid(plani) = p-rec no-lock no-error.
if avail plani and
    plani.usercod <> ""
then do:    
    
    assign
        v0 = 0 v1 = 0 v2 = 0 v3 = 1 v4 = 0 vi = 0.
    
    do v0 = 1 to 200:
        if substr(STRING(plani.usercod),v0,1) = ";"
        then do:
            v1 = v0 - v3.
            if substr(string(plani.usercod),v3,v1) = ""
            then leave.
            do vi = 1 to 20:
                if v4[vi] = 0
                then DO:
                    v4[vi] = int(substr(string(plani.usercod),v3,v1)). 
                    LEAve.
                END.
            end.
            v3 = v3 + v1 + 1.     
        end.
    end.
    vprecoliberado = no.
    vpromo = no.
    do vi = 1 to 20:
        if v4[vi] = 0
        then leave.
        find first ctpromoc where sequencia = v4[vi] no-lock no-error.
        if avail ctpromoc
        then do:
            na-promocao = no. 
            find produ where produ.procod = p-procod no-lock no-error.
            if avail produ
            then do:
                run find-pro-promo.
            end.
            if na-promocao 
            then do:
                if ctpromoc.precoliberado
                then vprecoliberado = yes.
                vpromo = yes.
            end.
        end.            
    end.
end.


if vpromo = no
then do:

    /*
    for each ctpromoc where ctpromoc.dtinicio <= plani.pladat
                        and ctpromoc.dtfim >= plani.pladat
                        and ctpromoc.linha = 0 no-lock,
                        
        first bctpromoc where bctpromoc.produtovendacasada = p-procod          
                          and bctpromoc.fincod > 0 no-lock:
                            
        vpromo = yes.
        leave.
                        
    end.                        
    */
    
    /*
    if can-find (first ctpromoc where ctpromoc.produtovendacasada = p-procod                                     and ctpromoc.linha > 0 
                                  and ctpromoc.fincod > 0
                                  and ctpromoc.sequencia > 0)
    then do:
    */
    
    for each tt-ctpromoc where tt-ctpromoc.produtovendacasada = p-procod
                           and tt-ctpromoc.linha > 0
                           and tt-ctpromoc.fincod > 0
                           and tt-ctpromoc.sequencia > 0
                           and tt-ctpromoc.dtinicio <= plani.pladat
                           and tt-ctpromoc.dtfim >= plani.pladat
                                     no-lock:
                
        /*                                          
        display tt-ctpromoc.sequencia
                tt-ctpromoc.linha
                tt-ctpromoc.fincod . pause.             */                                            
        
        vpromo = yes.
        leave.          
        
    end.
    
    /*
    end.
    */
    
end.

procedure find-pro-promo:
    
    na-promocao = no.
    def buffer fctpromoc for ctpromoc.
    
    release fctpromoc. 
     
    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase
        or produ.procod = 0
        or produ.clacod = 0
        or clase.clasup = 0
        or produ.catcod = 0
        or produ.fabcod = 0
    then.
    else do:

    find first fctpromoc where
               fctpromoc.sequenci = ctpromoc.sequencia and
               fctpromoc.procod = produ.procod
               no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = produ.clacod
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = clase.clasup
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = produ.catcod
                    no-lock no-error.
    if not avail fctpromoc
    then find first fctpromoc where
                    fctpromoc.sequenci = ctpromoc.sequencia and
                    fctpromoc.procod = 0 and
                    fctpromoc.clacod = 0 and
                    fctpromoc.setcod = 0 and
                    fctpromoc.fabcod = produ.fabcod
                    no-lock no-error.
    end.
    
    if avail fctpromoc
    then na-promocao = yes.
end procedure. 
