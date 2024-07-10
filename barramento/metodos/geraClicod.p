DEFINE INPUT PARAMETER lcJsonEntrada                   AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida             AS LONGCHAR.

DEFINE VARIABLE p-gera                    AS INTEGER.

{/admcom/barramento/metodos/geraClicod.i}

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-clicodEntrada:
        p-gera = 0.

        RUN /admcom/barramento/progr/buscaclicod.p (input 999, 
                                                    output p-gera).

        CREATE tt-clicodSaida.
          tt-clicodSaida.etbcod = STRING(tt-clicodEntrada.etbcod).
          tt-clicodSaida.clicod = STRING(p-gera).

END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
