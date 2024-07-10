
DEFINE VARIABLE lLeuJSON                                     AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada                 AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-clicodEntrada NO-UNDO SERIALIZE-NAME "clicodEntrada"
    FIELD etbcod LIKE plani.etbcod.

DEFINE TEMP-TABLE tt-clicodSaida NO-UNDO SERIALIZE-NAME "clicodSaida"
    FIELD etbcod AS CHARACTER
    FIELD clicod AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-clicodEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-clicodSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.
