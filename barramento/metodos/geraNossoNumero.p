DEFINE INPUT PARAMETER lcJsonEntrada      AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida       AS LONGCHAR.

DEFINE VARIABLE vnossonumero              LIKE bancarteira.nossonumeroatual.

DEFINE VARIABLE lLeuJSON                  AS LOGICAL.
DEFINE VARIABLE lGravouJSON               AS LOGICAL.
DEFINE VARIABLE hConteudoEntrada          AS handle  NO-UNDO.
DEFINE VARIABLE hConteudoSaida            AS handle  NO-UNDO.

DEFINE TEMP-TABLE tt-nossoNumeroEntrada NO-UNDO SERIALIZE-NAME "nossoNumeroEntrada"
    FIELD bancart LIKE bancarteira.bancart.

DEFINE TEMP-TABLE tt-nossoNumeroSaida NO-UNDO SERIALIZE-NAME "nossoNumeroSaida"
    FIELD vstatus AS CHARACTER
    FIELD vmensagem AS CHARACTER
    FIELD nossonumero AS CHARACTER.

DEFINE DATASET conteudoEntrada FOR tt-nossoNumeroEntrada.
hConteudoEntrada = DATASET conteudoEntrada:HANDLE.

DEFINE DATASET conteudoSaida FOR tt-nossoNumeroSaida.
hConteudoSaida = DATASET conteudoSaida:HANDLE.

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-nossoNumeroEntrada:
  
        CREATE tt-nossoNumeroSaida.
  
        do on error undo:
                find bancarteira where bancart = tt-nossoNumeroEntrada.bancart
                        exclusive no-error.
                        if not avail bancarteira
                        then do:
                                tt-nossoNumeroSaida.vstatus = "404".
                                tt-nossoNumeroSaida.vmensagem = "bancarteira nao encontrada".
                        end.
                        else do:
                                vnossonumero = bancarteira.nossonumeroatual + 1.
                                bancarteira.nossonumeroatual = vnossonumero.
                                
                                tt-nossoNumeroSaida.nossonumero = STRING(vnossonumero,"99999999").
                                tt-nossoNumeroSaida.vstatus = "200".
                                tt-nossoNumeroSaida.vmensagem = "OK".
                        end.
        end.
        
        LEAVE.
  
END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).    

