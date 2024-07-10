DEFINE INPUT PARAMETER lcJsonEntrada                 AS LONGCHAR.
DEFINE OUTPUT PARAMETER lcJsonSaida             AS LONGCHAR.

DEFINE VARIABLE vcertifi                                         as char.
DEFINE VARIABLE vstatus                            AS int.

{/admcom/barramento/metodos/geraSegnum.i}

lLeuJSON = hConteudoEntrada:READ-JSON("longchar", lcJsonEntrada, "EMPTY").

FOR EACH tt-segnumEntrada:
        
        vcertifi = "0".
        vstatus = 500.
        
        run /admcom/barramento/progr/buscacertificado.p ( input tt-segnumEntrada.etbcod,
                                                          input tt-segnumEntrada.codigoSeguro,
                                                         output vcertifi,
                                                         output vstatus).
                                                         

        
        CREATE tt-segnumSaida.
          tt-segnumSaida.etbcod = STRING(tt-segnumEntrada.etbcod).
          tt-segnumSaida.segnum = STRING(vcertifi).
          tt-segnumSaida.v-status = STRING(vstatus).
END.

ASSIGN
      lGravouJSON =  hConteudoSaida:WRITE-JSON("LONGCHAR", lcJsonSaida, true).
          
          


