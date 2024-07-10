output to value("/admcom/custom/laureano/lista-categorias-fiscais-ecom.csv").

def var vcha-ncm as char.

put unformatted
    "PROCOD;PRODUTO;COD NCM;NCM;% ICMS;% IPI;SIT. TRIB.;% PIS ENTRADA;% PIS SAIDA;% COFINS ~ ENTRADA;% COFINS SAIDA;COD.ABACOS;Sit.Trib.PIS/COFINS;COD CAT FIS KPL" skip.

def var vcont as integer.

for each produ no-lock,
 
    each produaux where produaux.procod = produ.procod
                    and produaux.nome_campo = "exporta-e-com"
                    and produaux.valor_campo = "yes" no-lock,
                    
    first prodecom where prodecom.procod = produ.procod no-lock,                                      
    first clafis where clafis.codfis = produ.codfis no-lock .                               
    assign vcha-ncm = "".
                          
    assign vcha-ncm = clafis.desfis.

    do vcont = 1 to 10.

        if substring(vcha-ncm,1,1) = "="
        then assign vcha-ncm = substring(vcha-ncm,2,length(vcha-ncm)).
    
        if substring(vcha-ncm,1,1) = "-"
        then assign vcha-ncm = substring(vcha-ncm,2,length(vcha-ncm)).
        
        if substring(vcha-ncm,1,1) = "~""
        then assign vcha-ncm = substring(vcha-ncm,2,length(vcha-ncm)).

        assign vcha-ncm = replace(vcha-ncm,"~"","").
     
    end.                     
    
    put unformatted
    produ.procod
    ";"
    produ.pronom
    ";"
    clafis.codfis  
    ";"
    vcha-ncm format "x(80)"    
    ";"
    pericm   
    ";"
    peripi   
    ";"
    sittri   
    ";"
    pisent   
    ";"
    pissai    
    ";"
    cofinsent
    ";"
    cofinssai
    ";"
    int1     
    ";"
    int2     
    ";"
    prodecom.codcatfisKPL skip
    .
                    
end.                    
