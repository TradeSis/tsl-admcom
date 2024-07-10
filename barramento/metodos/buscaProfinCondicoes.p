/* 10 - DESATIVO A ESCRITA NO DIRETORIO MONTADO DO AC DEVIDO A TRAVAMENTOS */

DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.


pause 0 before-hide.
def var vnossonumero as int.
    
def var vetbcod as int.    
{/admcom/barramento/metodos/buscaProfinCondicoes.i}

/* LE ENTRADA */
lokJSON = hconteudoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

create ttstatus.
ttstatus.situacao = "".


find first ttProfinCondicoesEntrada no-error.
if not avail ttProfinCondicoesEntrada
then do:
    ttstatus.situacao = "SEM INFORMACAO DE ENTRADA".
end.
else do:
    vetbcod = int(ttProfinCondicoesEntrada.codigofilial) no-error.
    if vetbcod = ? 
    then do:
        ttstatus.situacao = "FILIAL INVALIDA " + ttProfinCondicoesEntrada.codigofilial.
    end.
    else do:
        ttstatus.chave  = ttProfinCondicoesEntrada.codigofilial.

        find estab where estab.etbcod = int(ttProfinCondicoesEntrada.codigofilial) no-lock no-error.
        if not avail estab and int(ttProfinCondicoesEntrada.codigofilial) <> 0 
        then do:
            ttstatus.situacao = "ESTABE NAO CADASTRADO".
        end.    
    end.
end.    
if ttstatus.situacao = "" and avail ttProfinCondicoesEntrada
then do:

    ttstatus.situacao = "".
    find profin where profin.fincod = int(ttprofincondicoesentrada.codigoProfin)
        no-lock no-error.
    if not avail profin then ttstatus.situacao = "Produto Financeiro Nao Encontrado".
    ttstatus.codigoProfin =  ttprofincondicoesentrada.codigoProfin.
    
    for each profin where profin.fincod = int(ttprofincondicoesentrada.codigoProfin)
        no-lock.
        if vetbcod <> 0
        then do:
            for each  profincond where profincond.pfincod  = profin.fincod
                                   and profincond.etbcod  = vetbcod
                                   and (profincond.dtfinal = ? or
                                        profincond.dtfinal > today)
                                  no-lock .
                find finan of profincond no-lock.
                create ttprofincond.
                ttprofincond.chave      = ttstatus.chave.
                ttprofincond.pfincod    = string(profin.fincod).
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
                ttprofincond.chave      = ttstatus.chave.
                ttprofincond.pfincod    = string(profin.fincod).
                ttprofincond.fincod    = string(profincond.fincod).
                ttprofincond.finnom     = trim(finan.finnom).
                ttprofincond.finfat     = trim(string(finan.finfat,">>>>>9.9999")).
                ttprofincond.finnpc     = trim(string(finan.finnpc,">>>>>9")).
                ttprofincond.favorito   = trim(string(profincond.favorito,"SIM/NAO")).
                
                ttprofincond.txjurosmes  = trim(string(finan.txjurosmes,">>>9.99")).
                
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
