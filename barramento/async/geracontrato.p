def new global shared var scontador as int.

def input param par-tabela as char.
def input param par-rec as recid.

def var vlcentrada as longchar. 
def var vlcsaida   as longchar. 
def var hentrada as handle.
def var lokJson as log.


run /admcom/progr/lid/interfcontrato.p 
            (input par-tabela,
             input par-rec,
             output vlcsaida).


do on error undo:
       
      scontador = scontador + 1.
      create verusJsonLidia.
      ASSIGN
        verusJsonLidia.interface     = "contrato".
        verusJsonLidia.jsonStatus    = "NP".
        verusJsonLidia.dataIn        = today.
        verusJsonLidia.horaIn        = scontador.
    
        copy-lob from vlcsaida to verusJsonLidia.jsondados.
       /* 
            output to value("./json/contrato" + "_" + string(recid(verusJsonLidia)) + ".json") no-CONVERT.

            DISPLAY vlcsaida VIEW-AS EDITOR LARGE INNER-LINES 300 INNER-CHARS 300
              WITH FRAME x1 WIDTH 320 no-box no-labels.
            
            output close.  
*/
        
end.    
