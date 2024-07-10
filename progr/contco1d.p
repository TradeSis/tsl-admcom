
def input parameter par-clicod like clien.clicod.

def shared temp-table tt-contrato   like fin.contrato.
def shared temp-table tt-titulo     like fin.titulo
use-index cxmdat
use-index datexp
use-index etbcod
use-index exportado
use-index iclicod
use-index titdtpag
use-index titdtven
use-index titnum
use-index titsit
.
def shared temp-table tt-contnf     like fin.contnf.
def shared temp-table tt-movim      like movim.

    find clien where clien.clicod = par-clicod no-lock.

    for each d.contrato where d.contrato.clicod = clien.clicod no-lock.    
        find tt-contrato where tt-contrato.contnum = d.contrato.contnum
                no-lock no-error.
        if not avail tt-contrato
        then do:
            create tt-contrato.
            buffer-copy d.contrato to tt-contrato. 
        end.
        for each d.titulo where d.titulo.empcod = 19
                          and d.titulo.titnum = string(d.contrato.contnum)  
                          and d.titulo.titnat = no                        
                          and d.titulo.etbcod = d.contrato.etbcod           
                          and d.titulo.clifor = d.contrato.clicod          
                          and d.titulo.modcod = "CRE" no-lock by titulo.titpar.  
            find first tt-titulo where tt-titulo.empcod = d.titulo.empcod
                                   and tt-titulo.titnat = d.titulo.titnat
                                   and tt-titulo.modcod = d.titulo.modcod
                                   and tt-titulo.etbcod = d.titulo.etbcod
                                   and tt-titulo.clifor = d.titulo.clifor
                                   and tt-titulo.titnum = d.titulo.titnum
                                   and tt-titulo.titpar = d.titulo.titpar
                                    no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy d.titulo to tt-titulo.
            end.
        end.
        for each d.contnf where d.contnf.etbcod  = d.contrato.etbcod 
                          and d.contnf.contnum = d.contrato.contnum 
                              no-lock:
            create tt-contnf.
            buffer-copy d.contnf to tt-contnf.
            /***
            for each d.plani where d.plani.etbcod = d.contrato.etbcod
                             and d.plani.placod = d.contnf.placod
                             and d.plani.serie = "V"
                                 no-lock.
                create tt-plani.
                buffer-copy d.plani to tt-plani.
                for each d.movim where d.movim.etbcod = d.plani.etbcod
                                 and d.movim.placod = d.plani.placod
                                 and d.movim.movtdc = d.plani.movtdc 
                                 and d.movim.movdat = d.plani.pladat
                                     no-lock:
                    create tt-movim.
                    buffer-copy d.movim to tt-movim.
                end.                          
            end.
            ***/
        end.
    end.
    for each fin.contrato where fin.contrato.clicod = clien.clicod no-lock.    
        find first tt-contrato where tt-contrato.contnum = fin.contrato.contnum
                no-lock no-error.
        if not avail tt-contrato
        then do:
            create tt-contrato.
            buffer-copy fin.contrato to tt-contrato. 
        end.
        for each d.titulo where d.titulo.empcod = 19
                          and d.titulo.titnum = string(fin.contrato.contnum)  
                          and d.titulo.titnat = no                        
                          and d.titulo.etbcod = fin.contrato.etbcod           
                          and d.titulo.clifor = fin.contrato.clicod          
                          and d.titulo.modcod = "CRE" 
                          no-lock by d.titulo.titpar.  
            find first tt-titulo where tt-titulo.empcod = d.titulo.empcod
                                   and tt-titulo.titnat = d.titulo.titnat
                                   and tt-titulo.modcod = d.titulo.modcod
                                   and tt-titulo.etbcod = d.titulo.etbcod
                                   and tt-titulo.clifor = d.titulo.clifor
                                   and tt-titulo.titnum = d.titulo.titnum
                                   and tt-titulo.titpar = d.titulo.titpar
                                    no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy d.titulo to tt-titulo.
            end.
        end.
        for each fin.contnf where fin.contnf.etbcod  = fin.contrato.etbcod 
                          and fin.contnf.contnum = fin.contrato.contnum 
                              no-lock:
            find first tt-contnf where
                       tt-contnf.etbcod = fin.contnf.etbcod and
                       tt-contnf.contnum = fin.contnf.contnum
                       no-error.
            if not avail tt-contnf
            then do:           
                create tt-contnf.
                buffer-copy fin.contnf to tt-contnf.
            end.
            /***
            for each d.plani where d.plani.etbcod = d.contrato.etbcod
                             and d.plani.placod = d.contnf.placod
                             and d.plani.serie = "V"
                                 no-lock.
                create tt-plani.
                buffer-copy d.plani to tt-plani.
                for each d.movim where d.movim.etbcod = d.plani.etbcod
                                 and d.movim.placod = d.plani.placod
                                 and d.movim.movtdc = d.plani.movtdc 
                                 and d.movim.movdat = d.plani.pladat
                                     no-lock:
                    create tt-movim.
                    buffer-copy d.movim to tt-movim.
                end.                          
            end.
            ***/
        end.
    end.