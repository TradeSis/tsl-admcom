/* PROGRAMA DISPARADOR DO EXECUTOR DE RELATORIO */

/* DEVE CONTER O MESMO NOME QUE ESTÁ GRAVADO NA TABELA TSRELAT.PROGCOD */

{admbatch.i NEW}
DEF VAR lcjsonentrada AS LONGCHAR.
DEF VAR vpdf   AS CHAR. 
{tsr/tsrelat.i}
def temp-table ttparametros serialize-name "parametros"
    field dtini            as char     format "x(20)"
    field dtfin            AS char  format "x(20)"
    field etbcod           as int
    field tipooperacao     as char.

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/frrescart_v1801.p -> frrescart_v1801_run.p".

run marcatsrelat ("INICIO").
DEF VAR hentrada AS HANDLE.

hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
message "Lendo parametros " avail ttparametros.

if not avail ttparametros then return.

disp ttparametros with side-labels.

def new shared var vetbcod like estab.etbcod.
def new shared var vdtini as date format "99/99/9999" label "De".
def new shared var vdtfin as date format "99/99/9999" label "Ate".              


vetbcod = ttparametros.etbcod.
if ttparametros.dtfin BEGINS "#" then do:
    vdtfin = calculadata(ttparametros.dtfin,TODAY).
end.
ELSE DO:
    vdtfin = convertedata(ttparametros.dtfin).
END.
if ttparametros.dtini BEGINS "#" then do:
    vdtini = calculadata(ttparametros.dtini,TODAY).
end.
ELSE DO:
    vdtini  = convertedata(ttparametros.dtini).
END.

    
    if ttparametros.tipoOperacao = "RECEBIMENTOS"
    then do: 
        if AVAIL tsrelat then do:
            varquivo = "/admcom/tmp/ctb/" + replace(tsrelat.nomerel," ","") +
                "-ID" + STRING(tsrelat.idrelat) + "-" +  
                 STRING(TODAY,"99999999") +
                 replace(STRING(TIME,"HH:MM:SS"),":","") + ".csv" .
        end.
        ELSE DO:
            varquivo = "/admcom/tmp/ctb/conciliacao" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_baixas" + string(vdtini,"99999999") + "_" + string(vdtfin,"99999999")  + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
        end.
    
        run finct/telaanadocrec.p
                            (   "Geral" + "/" + "geral",
                                ?, 
                                "geral",
                                ?,
                                ?,
                                ?,
                                ?,
                                ?,
                                varquivo).
    end. 
    if ttparametros.tipoOperacao = "VENDAS" or ttparametros.tipoOperacao = "VENDAS SITE" or ttparametros.tipoOperacao = "VENDAS APP" 
    then do:
        if AVAIL tsrelat then do:
            varquivo = "/admcom/tmp/ctb/" + replace(tsrelat.nomerel," ","") +
                "-ID" + STRING(tsrelat.idrelat) + "-" +  
                 STRING(TODAY,"99999999") +
                 replace(STRING(TIME,"HH:MM:SS"),":","") + ".csv" .
        end.
        ELSE DO:
           varquivo = "/admcom/tmp/ctb/conciliacao" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_emissao" + string(vdtini,"99999999") + "_" + string(vdtfin,"99999999") + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .

        end.
        run finct/telaanaemictr.p (input ttparametros.tipoOperacao, 
                                   ?,
                                   ?,
                                   ?,
                                   ?,
                                   ?,
                                   varquivo).
    end.
    if ttparametros.tipoOperacao = "NOVACOES" 
    then do:
        if AVAIL tsrelat then do:
            varquivo = "/admcom/tmp/ctb/" + replace(tsrelat.nomerel," ","") +
                "-ID" + STRING(tsrelat.idrelat) + "-" +  
                 STRING(TODAY,"99999999") +
                 replace(STRING(TIME,"HH:MM:SS"),":","") + ".csv" .
        end.
        ELSE DO:
           varquivo = "/admcom/tmp/ctb/conciliacao" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_emissao" + string(vdtini,"99999999") + "_" + string(vdtfin,"99999999") + "_" +
                             string(today,"999999")  +  replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .

        end.
    
        run finct/telaanadocnov.p
                 (   "Geral/geral",
                            ?, 
                            "geral",
                            ?,
                            ?,
                            ?,
                            ?,
                            ?,
                            varquivo).

    end.
    
message "telaanaliini " ttparametros.tipoOperacao "FIM".

run marcatsrelat (varquivo).

message today string(time,"HH:MM:SS") "Disparando " pidrelat "tsrelat/telaanaliini.p -> " varquivo.


