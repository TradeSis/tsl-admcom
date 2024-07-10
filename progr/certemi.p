def var varquivo2 as character.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.


  update vdtini colon 15 label "Certificados emitidos de"
                   vdtfim label "ate".
                   
varquivo2 = "/admcom/relat/certificados-"
 + string(month(vdtini))
  + string(year(vdtini))
   + string(month(vdtfim))
    + string(year(vdtfim))
     +  "-" + string(time) + ".csv".
     
      display "Gerando acordos...".
      
      output to value(varquivo2).
      


put "Nome;CPF;Certificado;Email;Celular;Profissao;SegPrestacao;
SegValor;Contrato;Parcelas;Data;CodProduto;NomeProduto;
NumeroSorte;Cep;Endereco;EndNumero;EndComplemento;Estado;Cidade;
vigIni;vigFim;" skip.

def var vsegproduto as char.

def var segparcela as dec.
def var qtdparcelas as int.

for each vndseguro where pladat >= vdtini and
                         pladat <= vdtfim no-lock.


   if vndseguro.contnum = 0 then next.
   
   
   segparcela = 0.
qtdparcelas = 0.

     find first produ where produ.procod = vndseguro.procod no-lock no-error.
     find first clien where clien.clicod = vndseguro.clicod no-lock no-error.

   find first contrato where contrato.contnum = vndseguro.contnum
                    and contrato.clicod = vndseguro.clicod no-lock no-error.
                    
             if avail contrato then do:
                    

          if contrato.nro_parcelas <> 0 then do:
            segparcela = vndseguro.PrSeguro / contrato.nro_parcelas.        
                      
                               qtdparcelas = contrato.nro_parcelas.          
                                         
                                         end.
                                         else do:
                                       
                                  qtdparcelas = 0.
                                         
                                         
                      
           for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum) no-lock. 
                      
                                                                                   
                                         
                               qtdparcelas = qtdparcelas + 1.          
                                         
                                         
                           end.              
                                         
           segparcela = vndseguro.PrSeguro / qtdparcelas.     
                                         
                                         
                                         end.

                                       end.
                                       else do:
                     segparcela = vndseguro.PrSeguro.                  
                                      end.
/*
  if vndseguro.procod = 579359 or
     vndseguro.procod = 559911 or
     vndseguro.procod = 578790 then next.
  */
  


    vsegproduto = if vndseguro.procod = 559911 then "9839" else "9840".

    if vndseguro.procod = 559911 then do:
           vsegproduto = "9839".
           end.
                
    if vndseguro.procod = 559910 then do:
           vsegproduto = "9840".
           end.
                                    
    if vndseguro.procod = 569131 then do:
           vsegproduto = "3610".
           end.
                                                    
                                                    
    if vndseguro.procod = 578790 then do:
           vsegproduto = "9839".
            end.


  if vndseguro.procod = 579359 then do:
             vsegproduto = "9839".
                         end.





   put 
       clien.clinom format "x(40)" ";"
       clien.ciccgc format "x(11)" ";"
       vsegproduto format "x(4)" Certifi  ";" 
  replace(clien.zona, ";", " ") format "x(70)" ";"
  clien.fax ";"
     clien.proprof[1] format "x(100)" ";"
    segparcela format "->>>>>>>>.99" ";"
  PrSeguro ";"
   vndseguro.contnum ";"
    qtdparcelas ";"
      pladat format "99/99/9999" ";"
      vndseguro.procod          ";"
       produ.pronom ";"
       vndseguro.NumeroSorte format "x(40)" ";"
         replace(clien.cep[1], ";", " ")  ";"
         replace(clien.endereco[1], ";", " ")  format "x(120)" ";"
         replace(string(clien.numero[1]), ";", " ")  ";"
         replace(clien.compl[1], ";", " ") format "x(40)"  ";"
         clien.ufecod[1] format "x(2)" ";"
          replace(clien.cidade[1], ";", " ") format "x(40)"  ";"         
         vndseguro.DtIVig format "99/99/9999" ";"
         vndseguro.DtFVig format "99/99/9999" ";"        
                    skip. 




end.
output close.
message varquivo2.
pause.