
def var varquivo2 as character.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.


  update vdtini colon 15 label "Contratos marcados FIDC emitidos de"
                     vdtfim label "ate".
                                        
                   varquivo2 = "/admcom/relat/contratos-fidc-"
   + string(day(vdtini))      
   + string(month(vdtini))
   + string(year(vdtini))
   + "a" 
   + string(day(vdtfim)) 
   + string(month(vdtfim))
   + string(year(vdtfim))
   +  "-" + string(time) + ".csv".
                    
                          display "Gerando listagem...".
                                
                                      output to value(varquivo2).
                                            
   put "Emissao;Contrato;Parcela;Loja;Valor;Situacao;Fidc;Cliente;"
                                                        skip.
                                                        
                                                                                                                
                                    
 

for each contrato where dtinicial >= vdtini
            and dtinicial <= vdtfim
 
 no-lock.
 

 for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum)                                                 no-lock.


    if titulo.cobcod <> 14 then next.

                                        pause 0.
     

    put 
        titulo.titdtemi ";"
        titulo.titnum ";"
        titulo.titpar ";"
        titulo.etbcod ";"
        titulo.titvlcob ";"
        titulo.titsit ";"
        titulo.cobcod ";"
        titulo.clifor ";"
        skip.
    
    end.


end.
output close.

message varquivo2.
pause.

