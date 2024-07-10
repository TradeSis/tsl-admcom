DEFINE INPUT  PARAMETER lcJsonEntrada      AS LONGCHAR.
def    output param     vok as log no-undo.
vok = no.

DEFINE var lcJsonsaida      AS LONGCHAR.


{/admcom/barramento/async/cliente_01.i}

/* LE ENTRADA */
lokJSON = hclienteEntrada:READ-JSON("longchar",lcJsonEntrada, "EMPTY").

/*
for each ttcliente.
    disp ttcliente.
end.    
*/

lokJson = hclienteEntrada:WRITE-JSON("LONGCHAR", lcJsonSaida, TRUE).

/*
create verusjsonout.
  ASSIGN
    verusjsonout.interface     = "cliente".
    verusjsonout.jsonStatus    = "NP".
    verusjsonout.dataIn        = today.
    verusjsonout.horaIn        = time.
    
    copy-lob from lcJsonSaida to verusjsonout.jsondados.
*/

  

vok = yes.
