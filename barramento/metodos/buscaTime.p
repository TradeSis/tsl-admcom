DEFINE INPUT PARAMETER lcJsonEntrada 		  AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida 	    AS LONGCHAR.

DEFINE VARIABLE lLeuJSON 			            AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-timeSaida NO-UNDO SERIALIZE-NAME "timeSaida"
    FIELD vtime AS CHARACTER.

DEFINE DATASET conteudoSaida FOR tt-timeSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

  CREATE tt-timeSaida.
    tt-timeSaida.vtime = STRING(time).


ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
