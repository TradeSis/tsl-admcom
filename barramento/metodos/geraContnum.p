DEFINE INPUT PARAMETER lcJsonEntrada                   AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida             AS LONGCHAR.

DEFINE VARIABLE vcontnum                    like geranum.contnum.
DEFINE VARIABLE vstatus                    AS int.

{/admcom/barramento/metodos/geraContnum.i}

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-contnumEntrada:
        
        vcontnum = 0.
        vstatus = 500.
        
        run /admcom/barramento/progr/buscacontnum.p
                (input tt-contnumEntrada.etbcod,
                output vcontnum,
                output vstatus). 
        
        CREATE tt-contnumSaida.
          tt-contnumSaida.etbcod = STRING(tt-contnumEntrada.etbcod).
          tt-contnumSaida.contnum = STRING(vcontnum).
          tt-contnumSaida.v-status = STRING(vstatus).

END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
          
          


