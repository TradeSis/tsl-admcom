{admcab.i}

    def input  parameter par-rec     as recid.
    def output parameter vlipqtd     like liped.lipqtd init 0.
    def output parameter vpreqtent   like liped.lipent init 0.
    def output parameter vlipqtdcanc like liped.lipqtdcanc init 0.

    def buffer blipedpai for lipedpai.

    find blipedpai where recid(blipedpai) = par-rec no-lock.
    for each liped where liped.etbcod = blipedpai.etbcod
                     and liped.pedtdc = blipedpai.pedtdc
                     and liped.pednum = blipedpai.pednum
                     and liped.lipcor = string(blipedpai.paccod)
                   no-lock.
        assign
            vlipqtd     = vlipqtd     + liped.lipqtd
            vpreqtent   = vpreqtent   + liped.lipent
            vlipqtdcanc = vlipqtdcanc + liped.lipqtdcanc.
    end.

/***
find pedid where recid(pedid) = par-recid-pedid no-lock.
    
    /* Busca quantidades do liped dos filhos */
    for each produ where
            produ.itecod = par-itecod
            no-lock.
        for each liped of pedid where
                    liped.procod = produ.procod
                    no-lock.
            for each proenoc of liped no-lock.
                vlipqtd     = vlipqtd       + proenoc.qtdmerca.        
                vpreqtent   = vpreqtent     + proenoc.qtdmercaent.
                vlipqtdcanc = vlipqtdcanc   + proenoc.qtdmercacanc.
            end.
        end.                    
    end.            
***/

