def input param par-interface   as char.
def input param par-arquivo     as char.

def input param par-dcbcod      like abascorte.dcbcod.
def input param par-dcbpseq     like abascorteprod.dcbpseq.
def input param par-procod      like abascorteprod.procod.
def input param par-qtdconf     like abasconfprod.qtdconf.

def new shared temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format ">>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.

    find abascorte where abascorte.dcbcod = par-dcbcod no-lock no-error.
    if not avail abascorte
    then next.
    

                find abasintegracao where abasintegracao.interface = par-interface and
                                abasintegracao.arquivo = par-arquivo no-lock no-error.
    
                find abasconfprod where
                        abasconfprod.dcbcod    = par-dcbcod and
                        abasconfprod.dcbpseq   = par-dcbpseq
                     exclusive no-error.
                if not avail abasconfprod
                then do:                  
                    create abasCONFprod.
                    abasconfprod.dcbcod             = par-dcbcod.
                    abasconfprod.dcbpseq            = par-dcbpseq.
                end.            
                abasconfprod.datareal = if avail abasintegracao 
                                        then abasintegracao.datareal
                                        else today.
                abasconfprod.horareal = if avail abasintegracao 
                                        then abasintegracao.horareal
                                        else time.
                                        
                abasconfprod.interface          = par-interface.
                abasconfprod.arquivo            = par-arquivo.

                abasconfprod.procod             = par-procod.
                if par-interface = "CONF"
                then do:
                    abasconfprod.qtdconf            =  par-qtdconf.
                end.
                else do:
                    abasconfprod.qtdconf            =  par-qtdconf.
                end.    
               
                    
                find abasCORTEprod where 
                        abascorteprod.dcbcod = abasconfprod.dcbcod and
                        abascorteprod.dcbpseq = abasconfprod.dcbpseq
                    exclusive no-error.
                if not avail abascorteprod
                then do:
                    create abascorteprod.
                    ASSIGN
                        abascorteprod.etbcod   = abascorte.etbcod
                        abascorteprod.dcbcod   = abasconfprod.dcbcod
                        abascorteprod.dcbpseq  = abasconfprod.dcbpseq
                        abascorteprod.abtcod   = ?
                        abascorteprod.qtdCorte = 0.
                        abascorteprod.procod   = abasconfprod.procod.
                end. 

                abascorteprod.procod = abasconfprod.procod.
                    
                if abascorteprod.abtcod <> ? /*and
                   par-interface = "CONF"      */
                then do:
                    find abastransf of abascorteprod exclusive no-error.

                    if avail abastransf 
                    then do:

                        if    abastransf.abtsit = "CA" /* Cancelado... */
                           or abastransf.abtsit = "EL" /* Eliminado... */
                           or abastransf.abtsit = "NE" 
                        then. /* Nao mexe nos cancelados */
                        else do:   

                            run abas/transfqtdsit.p (recid(abastransf),yes).
                                  
                        end.                    
                    end.    
                    
                end.
