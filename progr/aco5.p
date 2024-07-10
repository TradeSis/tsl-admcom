
def var varquivo2 as character.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
 
 
 
  update vdtini colon 15 label "Contratos emitidos de"
                 vdtfim label "ate".
                 
 
varquivo2 = "/admcom/import/cdlpoa/entradaacordos_contratos-"
 + string(month(vdtini))
 + string(year(vdtini))
 + string(month(vdtfim))
 + string(year(vdtfim))
 +  "-" + string(time) + ".csv".
 
 display "Gerando acordos...". 
  
output to value(varquivo2).

put "Contrato;Cliente;Parcela1;Vencimento;Valor;Situacao;Datapagamento;ValorPago;Parcela2;Vencimento;Valor;Situacao;Datapagamento;ValorPago;". 
put skip.

for each contrato where dtinicial >= vdtini and
                        dtinicial <= vdtfim     
  no-lock.

find first clien where clien.clicod = contrato.clicod no-lock no-error. 



if (contrato.modcod = "CRE" AND contrato.tpcontrato = "N") or
   (contrato.modcod = "CPN") THEN DO:
   end.
   else do:
   next.
   end.
   
                          
put contrato.contnum format ">>>>>>>>>>>>>9" ";" clien.clicod format ">>>>>>>>>>>>>9" ";". 

 for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum)                           
                           no-lock.
                           pause 0.
                           
                           
                      if titulo.titpar >= 3 then next.     
                           

         put
                    titulo.titpar ";"
                    titulo.titdtven format "99/99/9999" ";"
                    titulo.titvlcob format ">>>>>>>>>>>>>9.99" ";"
                    titulo.titsit ";" 
                    titulo.titdtpag format "99/99/9999" ";" 
                    titulo.titvlpag format ">>>>>>>>>>>>>9.99" ";". 
           
              
end.

put skip.

end.

output close.
message varquivo2.
pause.