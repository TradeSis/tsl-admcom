
DEFINE VARIABLE lLeuJSON                                     AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada                 AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-contnumEntrada NO-UNDO SERIALIZE-NAME "contnumEntrada"
    FIELD etbcod LIKE plani.etbcod.

DEFINE TEMP-TABLE tt-contnumSaida NO-UNDO SERIALIZE-NAME "contnumSaida"
    FIELD etbcod AS CHARACTER
    FIELD contnum AS CHARACTER
        FIELD v-status AS CHARACTER. 

DEFINE DATASET conteudoEntrada FOR tt-contnumEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-contnumSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

          
          


