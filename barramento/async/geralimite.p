def new global shared var scontador as int.

def input parameter par-rec as recid.

find neuclien where recid(neuclien) = par-rec no-lock.

def var vlcentrada as longchar. 
def var vlcsaida   as longchar. 
def var hentrada as handle.
def var lokJson as log.

def temp-table ttentrada no-undo serialize-name "clientes"
    field cpfCnpj as char.

hEntrada = temp-table ttentrada:HANDLE.

create ttentrada.
ttentrada.cpfCnpj = string(neuclien.cpf).

lokJson = hentrada:WRITE-JSON("LONGCHAR", vlcentrada, TRUE).
                                                                                                                                                      
                                                                                                                                                      
run /admcom/progr/lid/interflimites.p 
    (input vlcentrada, 
     output vlcsaida).


do on error undo:
       
      scontador = scontador + 1.
      create verusJsonLidia.
      ASSIGN
        verusJsonLidia.interface     = "limites".
        verusJsonLidia.jsonStatus    = "NP".
        verusJsonLidia.dataIn        = today.
        verusJsonLidia.horaIn        = scontador.
    
        copy-lob from vlcsaida to verusJsonLidia.jsondados.
        
/*
            output to value("./json/limites" + "_" + string(recid(verusJsonLidia)) + ".json") no-CONVERT.

            DISPLAY vlcsaida VIEW-AS EDITOR LARGE INNER-LINES 300 INNER-CHARS 300
              WITH FRAME x1 WIDTH 320 no-box no-labels.
            
            output close.  
        
*/
end.    
