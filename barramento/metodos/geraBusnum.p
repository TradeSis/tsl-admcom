DEFINE INPUT PARAMETER lcJsonEntrada 		  AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida 	    AS LONGCHAR.

DEFINE VARIABLE par-num                   AS INTEGER.
DEFINE VARIABLE vtitcod                   AS DECIMAL.

DEFINE VARIABLE lLeuJSON 			            AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada 	        AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-titcodEntrada NO-UNDO SERIALIZE-NAME "titcodEntrada"
    FIELD etbcod LIKE plani.etbcod.

DEFINE TEMP-TABLE tt-titcodSaida NO-UNDO SERIALIZE-NAME "titcodSaida"
    FIELD etbcod AS CHARACTER
    FIELD titcod AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-titcodEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-titcodSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-titcodEntrada:
  RUN /admcom/barramento/busnum.p ("TITULO", tt-titcodEntrada.etbcod, output vtitcod).

  CREATE tt-titcodSaida.
  tt-titcodSaida.etbcod = STRING(tt-titcodEntrada.etbcod).
  tt-titcodSaida.titcod = STRING(vtitcod).

  vtitcod = 0.
END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
