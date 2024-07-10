
def var varquivo2 as character.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
 
 def var vlpago as dec.
 
  update vdtini colon 15 label "Contratos emitidos de"
                 vdtfim label "ate".
                 
 
varquivo2 = "/admcom/relat/contratos_emi_"
 + string(month(vdtini))
 + string(year(vdtini))
 + string(month(vdtfim))
 + string(year(vdtfim))
 +  "-" + string(time) + ".csv".
 
 display "Gerando contratos e titulos...". 
  
output to value(varquivo2).

put "CONTA;	CPF;	CONTRATO;	DATA EMISSAO;	DATA VENCIMENTO;	DATA PAGAMENTO;	MODALIDADE (CDC/EP); LOJA; VALOR VENCIMENTO; VALOR PAGO; VALOR CONTRATO;" skip.


for each contrato where dtinicial >= vdtini and
                        dtinicial <= vdtfim     
  no-lock.

find first clien where clien.clicod = contrato.clicod no-lock no-error. 



                            pause 0.
                            



 for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum)                           
                           no-lock.
                           pause 0.

            /*
              disp titulo.titnum
                    titulo.titpar
                      titulo.titdtven
                      titulo.titvlcob
                        titulo.titsit.
              */
              
            if titulo.titvlpag <> ? then do:
            vlpago = titulo.titvlpag.
            end.
            else do:
            vlpago = 0.
            end.
           
       

          put
          clien.clicod format ">>>>>>>>>>>>9" ";" 
clien.ciccgc  format "x(17)" ";"
contrato.contnum format ">>>>>>>>>>>>9" ";"
contrato.dtinicial format "99/99/9999" ";"
 titulo.titdtven format "99/99/9999" ";"
 
 
  titulo.titdtpag format "99/99/9999" ";"
 
contrato.modcod ";"

contrato.etbcod ";"            
                   
                   titulo.titvlcob format ">>>>>>>>>>>>9.99" ";"
                   vlpago format ">>>>>>>>>>>>9.99" ";"
                   contrato.vltotal format ">>>>>>>>>>>>9.99" ";"
                   
                   
                   
                        skip  .
                                                
                                                
                                                end.

end.

output close.
message varquivo2.
pause.