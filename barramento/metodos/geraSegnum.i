
DEFINE VARIABLE lLeuJSON                                 AS LOGICAL.
DEFINE VARIABLE lGravouJSON                       AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada                 AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida                    AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-segnumEntrada NO-UNDO SERIALIZE-NAME "segnumEntrada"
    FIELD etbcod LIKE plani.etbcod
        FIELD codigoSeguro AS CHARACTER.

DEFINE TEMP-TABLE tt-segnumSaida NO-UNDO SERIALIZE-NAME "segnumSaida"
    FIELD etbcod AS CHARACTER
    FIELD segnum AS CHARACTER
        FIELD v-status AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-segnumEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-segnumSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

          
          


