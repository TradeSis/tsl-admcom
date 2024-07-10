/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */ 

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
def var vnossonumero as int.
    
def var vetbcod as int.    
{/admcom/barramento/metodos/buscaProfinParam.i}

/* LE ENTRADA */
lokJSON = hconteudoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

create ttstatus.
ttstatus.situacao = "".


find first ttbuscaProfinParamEntrada no-error.
if not avail ttbuscaProfinParamEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vetbcod = int(ttbuscaProfinParamEntrada.codigofilial) no-error.
    if vetbcod = ? 
    then do:
        ttstatus.situacao = "FILIAL INVALIDA " + ttbuscaProfinParamEntrada.codigofilial.
    end.
    else do:
        ttstatus.chave  = ttbuscaProfinParamEntrada.codigofilial.

        find estab where estab.etbcod = int(ttbuscaProfinParamEntrada.codigofilial) no-lock no-error.
        if not avail estab and vetbcod <> 0 
        then do:
            ttstatus.situacao = "ESTABE NAO CADASTRADO".
        end.    
    end.
end.    
if ttstatus.situacao = "" and avail ttbuscaProfinParamEntrada
then do:

    ttstatus.situacao = "Boleto nao Encontrado".
        
    for each profin where 
        profin.situacao = yes no-lock.
        
        create ttprofin.
        ttprofin.chave = ttstatus.chave.
        
        ttprofin.fincod     = string(profin.fincod).
        ttprofin.findesc    = profin.findesc.
        ttprofin.procod     = string(profin.procod).
        ttprofin.modcod     = profin.modcod.
        ttprofin.obrigaDeposito = profin.obrigadeposito.
        ttprofin.limiteToken    = string(profin.limite_Token).
        ttprofin.procodSeguro   = string(profin.procod_Seguro).
        ttprofin.codigoSicred = string(profin.codigo_Sicred).
        
        if vetbcod <> 0
        then do:
            find first profinparam where profinparam.fincod  = profin.fincod
                                     and profinparam.etbcod  = vetbcod
                                     and profinparam.dtinicial <= today
                                     and (profinparam.dtfinal = ? or
                                          profinparam.dtfinal > today)
                                  no-lock no-error.
            if not avail profinparam
            then find first profinparam where profinparam.fincod = profin.fincod
                                     and profinparam.etbcod  = 0
                                     and profinparam.dtinicial <= today
                                     and (profinparam.dtfinal = ? or
                                          profinparam.dtfinal > today)
                                  no-lock no-error.
            if avail profinparam
            then do:
                create ttprofinparam.
                ttprofinparam.chave     = ttprofin.chave.
                ttprofinparam.fincod    = ttprofin.fincod.
                ttprofinparam.etbcod    = trim(string(profinparam.etbcod)).
                ttprofinparam.DtInicial = trim(string(profinparam.DtInicial,"99/99/9999")).
                ttprofinparam.DtFinal   = trim(string(profinparam.Dtfinal,"99/99/9999")).
                ttprofinparam.VlMinimo  = trim(string(profinparam.VlMinimo,">>>>>>>>9.99")).
                ttprofinparam.VlMaximo  = trim(string(profinparam.VlMaximo,">>>>>>>>9.99")).
                ttprofinparam.PercLimite    = trim(string(profinparam.PercLimite,"999.99")).
                ttprofinparam.TempoRelac    = trim(string(profinparam.TempoRelac)).
                ttprofinparam.ParcPagas = trim(string(profinparam.ParcPagas)).
            end.
        end.
        else do:
            find first profinparam where profinparam.fincod = profin.fincod
                                     and profinparam.etbcod  = 0
                                     and profinparam.dtinicial <= today
                                     and (profinparam.dtfinal = ? or
                                          profinparam.dtfinal > today)
                                  no-lock no-error.
            if avail profinparam
            then do:
                create ttprofinparam.
                ttprofinparam.chave     = ttprofin.chave.
                ttprofinparam.fincod    = ttprofin.fincod.

                ttprofinparam.etbcod    = trim(string(profinparam.etbcod)).
                ttprofinparam.DtInicial = trim(string(profinparam.DtInicial,"99/99/9999")).
                ttprofinparam.DtFinal   = trim(string(profinparam.Dtfinal,"99/99/9999")).
                ttprofinparam.VlMinimo  = trim(string(profinparam.VlMinimo,">>>>>>>>9.99")).
                ttprofinparam.VlMaximo  = trim(string(profinparam.VlMaximo,">>>>>>>>9.99")).
                ttprofinparam.PercLimite    = trim(string(profinparam.PercLimite,"999.99")).
                ttprofinparam.TempoRelac    = trim(string(profinparam.TempoRelac)).
                ttprofinparam.ParcPagas = trim(string(profinparam.ParcPagas)).
                
            end.
            for each estab no-lock.
                find first profinparam where profinparam.fincod = profin.fincod
                                         and profinparam.etbcod  = estab.etbcod
                                         and profinparam.dtinicial <= today
                                         and (profinparam.dtfinal = ? or
                                              profinparam.dtfinal > today)
                                      no-lock no-error.
                if avail profinparam
                then do:
                    create ttprofinparam.
                    ttprofinparam.chave     = ttprofin.chave.
                    ttprofinparam.fincod    = ttprofin.fincod.
                    ttprofinparam.etbcod    = trim(string(profinparam.etbcod)).
                    ttprofinparam.DtInicial = trim(string(profinparam.DtInicial,"99/99/9999")).
                    ttprofinparam.DtFinal   = trim(string(profinparam.Dtfinal,"99/99/9999")).
                    ttprofinparam.VlMinimo  = trim(string(profinparam.VlMinimo,">>>>>>>>9.99")).
                    ttprofinparam.VlMaximo  = trim(string(profinparam.VlMaximo,">>>>>>>>9.99")).
                    ttprofinparam.PercLimite    = trim(string(profinparam.PercLimite,"999.99")).
                    ttprofinparam.TempoRelac    = trim(string(profinparam.TempoRelac)).
                    ttprofinparam.ParcPagas = trim(string(profinparam.ParcPagas)).
                    
                end.
            
            end.
        
        end.

        if vetbcod <> 0
        then do:
            for each  profincond where profincond.pfincod  = profin.fincod
                                   and profincond.etbcod  = vetbcod
                                   and (profincond.dtfinal = ? or
                                        profincond.dtfinal > today)
                                  no-lock .
                find finan of profincond no-lock.
                create ttprofincond.
                ttprofincond.chave      = ttprofin.chave.
                ttprofincond.pfincod    = ttprofin.fincod.
                ttprofincond.fincod    = string(profincond.fincod).
                ttprofincond.finnom     = trim(finan.finnom).
                ttprofincond.finfat     = trim(string(finan.finfat,">>>>>9.9999")).
                ttprofincond.finnpc     = trim(string(finan.finnpc,">>>>>9")).
                ttprofincond.favorito   = trim(string(profincond.favorito,"SIM/NAO")).
                
                ttprofincond.txjurosmes  = trim(string(finan.txjurosmes,">>>9.99")).
            end.                
            
        end.

        find first ttprofincond no-error.
        if vetbcod = 0 or not avail ttprofincond
        then do:
            for each profincond where profincond.pfincod = profin.fincod
                                     and profincond.etbcod  = 0
                                     and (profincond.dtfinal = ? or
                                          profincond.dtfinal > today)
                                  no-lock .
                find finan of profincond no-lock.
                create ttprofincond.
                ttprofincond.chave      = ttprofin.chave.
                ttprofincond.pfincod    = ttprofin.fincod.
                ttprofincond.fincod    = string(profincond.fincod).
                ttprofincond.finnom     = trim(finan.finnom).
                ttprofincond.finfat     = trim(string(finan.finfat,">>>>>9.9999")).
                ttprofincond.finnpc     = trim(string(finan.finnpc,">>>>>9")).
                ttprofincond.favorito   = trim(string(profincond.favorito,"SIM/NAO")).
                
                ttprofincond.txjurosmes  = trim(string(finan.txjurosmes,">>>9.99")).
                
            end.
        end.
        
        if vetbcod <> 0
        then do:
            for each  profintaxa where profintaxa.fincod  = profin.fincod
                                   and profintaxa.etbcod  = vetbcod
                                   and profintaxa.dtinicial <= today
                                   and (profintaxa.dtfinal = ? or
                                        profintaxa.dtfinal > today)
                                  no-lock .
                create ttprofintaxa.
                ttprofintaxa.chave      = ttprofin.chave.
                ttprofintaxa.fincod    = ttprofin.fincod.
                ttprofintaxa.vlminimo   = trim(string(profintaxa.vlminimo,">>>>>>>>>9.99")).
                ttprofintaxa.vlmaximo   = trim(string(profintaxa.vlmaximo,">>>>>>>>>9.99")).
                ttprofintaxa.vltaxa     = trim(string(profintaxa.vltaxa,">>>>>>>>>9.99")).
            end.                
            
        end.

        find first ttprofintaxa no-error.
        if vetbcod = 0 or not avail ttprofintaxa
        then do:
            for each profintaxa where profintaxa.fincod = profin.fincod
                                     and profintaxa.etbcod  = 0
                                   and profintaxa.dtinicial <= today
                                     and (profintaxa.dtfinal = ? or
                                          profintaxa.dtfinal > today)
                                  no-lock .
                create ttprofintaxa.
                ttprofintaxa.chave      = ttprofin.chave.
                ttprofintaxa.fincod    = ttprofin.fincod.
                ttprofintaxa.vlminimo   = trim(string(profintaxa.vlminimo,">>>>>>>>>9.99")).
                ttprofintaxa.vlmaximo   = trim(string(profintaxa.vlmaximo,">>>>>>>>>9.99")).
                ttprofintaxa.vltaxa     = trim(string(profintaxa.vltaxa,">>>>>>>>>9.99")).
            end.
        
        end.
            
        ttstatus.situacao = "Sucesso".
    end.

 
end.     
else do:
    message ttstatus.situacao.
end.


lokJson = hconteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).
/* 10
hconteudoSaida:WRITE-JSON("FILE","helio_profin.json", true).
*/
