def var vlinha    as character.
def var varquivo  as character.
def var vcodfis   as integer.

def var vmva_estado1  as character.
def var vmva_oestado1 as character.

def var dmva_estado1  as decimal format "->>>,>99.99". 
def var dmva_oestado1 as decimal format "->>>,>99.99".

assign varquivo = "/admcom/import/mva.csv".

                /*
unix silent
   value("/usr/dlc/bin/quoter /admcom/import/mva.csv
                                            > /admcom/import/mva2.csv").
                  */
input from value(varquivo).

repeat:

    import vlinha.
    
    if trim(vlinha) = ";"
    then next.
    
    if num-entries(vlinha,";") < 3
    then next.
    
    assign vcodfis = integer(entry(2,vlinha,";")).
                                      
    assign vmva_estado1 = entry(3,vlinha,";")
           vmva_oestado1 = entry(4,vlinha,";").

    release clafis.
    
    find first clafis where clafis.codfis = vcodfis no-lock no-error.
    
    if avail clafis
    then do:
         
        /*                        
        assign clafis.mva_estado1 = decimal(vmva_estado1)
               clafis.mva_oestado1 = decimal(vmva_oestado1) . 
                                  
        */
        
        display clafis.codfis clafis.mva_estado1  decimal(vmva_estado1)
                       clafis.mva_oestado1 decimal(vmva_oestado1) .
        
    end.
    else next.
                      
end.




