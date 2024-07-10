DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     vok as char no-undo.
vok = "".

DEFINE var lcJsonsaida      AS LONGCHAR.

def var vestvenda as dec.
{/admcom/barramento/functions.i}

{/admcom/barramento/async/estacao_01.i}

/* LE ENTRADA */
lokJSON = hestacaoEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

def var vetccod like estac.etccod.
for each ttestacao.

    /* 09.06.2020 depara de ADMCOM para SAP, para os codigos ate 6. */
    vetccod =      if int(ttestacao.codigoEstacao) = 1000 then 1
              else if int(ttestacao.codigoEstacao) = 2000 then 2
              else if int(ttestacao.codigoEstacao) = 3000 then 3
              else if int(ttestacao.codigoEstacao) = 4000 then 4
              else if int(ttestacao.codigoEstacao) = 5000 then 5
              else if int(ttestacao.codigoEstacao) = 6000 then 6
              else int(ttestacao.codigoEstacao).

    find estac where estac.etccod = vetccod
        exclusive no-wait no-error.
    if not avail estac
    then do: 
        if locked estac
        then do:
            vok = "locado".
            return.
        end.
        create estac.
        estac.etccod = vetccod.
    end.
    if trim(estac.etcnom) <> trim(ttestacao.descricaoEstacao)
    then estac.etcnom = ttestacao.descricaoEstacao.          

    find first temporada where temporada.temp-cod = int(ttestacao.codigoColecao)
        exclusive no-wait no-error.
    if not avail temporada
    then do: 
        if locked temporada
        then do:
            vok = "locado".
            return.
        end.
        create temporada.
        temporada.temp-cod = int(ttestacao.codigoColecao).
        temporada.DtInclu  = today.
    end.

    temporada.tempnom  = descricaoColecao.
    temporada.dtini    = aaaa-mm-dd_todate(dataInicio).
    temporada.dtfim    = aaaa-mm-dd_todate(dataFim).

    temporada.datexp   = today.

end.    



