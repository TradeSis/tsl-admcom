DEFINE INPUT PARAMETER lcJsonEntrada 		  AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida 	    AS LONGCHAR.

DEFINE VARIABLE par-num                   AS INTEGER.
DEFINE VARIABLE vplacod                   LIKE plani.placod.

DEFINE VARIABLE lLeuJSON 			            AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada 	        AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-placodEntrada NO-UNDO SERIALIZE-NAME "placodEntrada"
    FIELD etbcod LIKE plani.etbcod.

DEFINE TEMP-TABLE tt-placodSaida NO-UNDO SERIALIZE-NAME "placodSaida"
    FIELD etbcod AS CHARACTER
    FIELD placod AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-placodEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-placodSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-placodEntrada:
  RUN /admcom/bs/bas/grplanum.p (tt-placodEntrada.etbcod, "", output vplacod, output par-num).

  CREATE tt-placodSaida.
  tt-placodSaida.etbcod = STRING(tt-placodEntrada.etbcod).
  tt-placodSaida.placod = STRING(vplacod).

  vplacod = 0.
END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
