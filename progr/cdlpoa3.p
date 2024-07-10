{admcab.i new}

def buffer btitulo for titulo.

def var cestcivil as char.
def var tiporeceita as char.
def var jurosdivida as dec.
def var totaldivida as dec.
def var fatorusar as dec.
         def var diasdeatraso as int.
    def var parcelafinal as dec.
    def var i-real    as int no-undo.
    def var d-centavo as dec decimals 2 no-undo.
                    
    def var i-novoreal    as int no-undo.
    def var d-novocentavo as dec decimals 2 no-undo.
                                                    
    def var d-novaparcela like estoq.estven.
    def var d-novototal   like estoq.estven.

def var statuscli as char.
def var statusmoecod like titulo.moecod.

def var varquivo        as character.
def var varquivo2 as character.                               
def var varquivo3 as character.

def var numeronovocontrato as char.
def var statusnovocontrato as char.
def var datanovocontrato as date.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.



 update vdtini colon 15 label "Contratos emitidos de" 
               vdtfim label "ate".
       

varquivo2 = "/admcom/import/cdlpoa/cdlpoa-CRE-libcontratos-"
+ string(month(vdtini))
+ string(year(vdtini))
+ string(month(vdtfim))
+ string(year(vdtfim))
+  "-" + string(time) + ".csv".


display "Gerando Arquivos Aberto".

output to value(varquivo2).




put "cpf;tipocliente;codigocliente;nome;datanasc;pai;mae;email;rg;
estadocivil;;conjuge;endereco;numero;compl;bairro;cep;cidade;estado;celular;telfixo;tel
aux1 ;telaux2;telaux3;telaux4;telaux5;contrato;modalidade;numparcela;dividaor 
iginal;dividaatualizada;datavencimento;situacao;datapagamento;;;;juros;empresa;
  convenio;tpcontrato;" skip.









for each clien where clien.clicod > 10  no-lock.
                 pause 0.


     def var vdatabasica as date.
     vdatabasica =  today.
     vdatabasica  = vdatabasica - 60.
               /*
     find first titulo use-index iclicod
             where titulo.clifor = clien.clicod and 
                   titulo.modcod begins "CRE" and 
                   titulo.titsit = "LIB" and
                   titulo.titdtpag = ? and
                   titulo.titdtemi >= vdtini and 
                                   titulo.titdtemi <= vdtfim
                          no-lock no-error. 

        if not avail titulo then next.
  */  
  
  
                find first contrato use-index iconcli where contrato.clicod = clien.clicod and
                        contrato.modcod begins "CRE" and 
                                                contrato.dtinicial >= vdtini and
                                            contrato.dtinicial <= vdtfim no-lock no-error. 
                
                  if not avail contrato then next.
                
                
              
              
              

 if length(clien.ciccgc) = 11 then do:
      tiporeceita = "PF".
       end.
        else do:
       tiporeceita = "CNPJ".
        end.




                
            cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "". 
                                                                       








               

    for each contrato use-index iconcli where contrato.clicod = clien.clicod and
                        contrato.modcod begins "CRE" and 
                                                contrato.dtinicial >= vdtini and
                                            contrato.dtinicial <= vdtfim
                                                
                                                no-lock.
         /*
          disp clien.ciccgc clien.clicod contrato.contnum format ">>>>>>>>>9" contrato.modcod.       
           */        pause 0.
           
            find first titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod  and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titsit = "LIB" and
                       titulo.titdtpag = ? 
                        no-lock no-error.




                      if avail titulo then do:





                for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum) and
                          titulo.titsit = "LIB" and
                          titulo.titdtpag = ?
                           no-lock.
                          
                            pause 0.
                            
                      diasdeatraso = today - titdtven.
                      
                                                              
          find first tabjur where tabjur.nrdias = diasdeatraso and
          tabjur.etbcod = titulo.etbcod no-lock no-error.
                            
                if not avail tabjur then do:
                        fatorusar = 10.
                                end.
                        else do:
                        fatorusar = fator.
                                end.
                      
          parcelafinal = titvlcob * fatorusar.
                                      
                                                     
                  i-real = truncate(parcelafinal,0).
                  d-centavo = parcelafinal - i-real.
                                             
                                                                        
                                                                                                   
            d-novocentavo = d-centavo.
                                                                                     i-novoreal = i-real.
                           
          if (d-centavo >= 0.01 and d-centavo <= 0.10) then do:
d-novocentavo = 0.10.
i-novoreal = i-real.
end.


if (d-centavo >= 0.11 and d-centavo <= 0.20) then do:
d-novocentavo = 0.20.
i-novoreal = i-real.
end.


if (d-centavo >= 0.21 and d-centavo <= 0.30) then do:
d-novocentavo = 0.30.
i-novoreal = i-real.
end.
                      
if (d-centavo >= 0.31 and d-centavo <= 0.40) then do:
                      d-novocentavo = 0.40.
                      i-novoreal = i-real.
                      end.
                      
                      if (d-centavo >= 0.41 and d-centavo <= 0.50) then do:
                      d-novocentavo = 0.50.
                      i-novoreal = i-real.
                      end.
                      
                      if (d-centavo >= 0.51 and d-centavo <= 0.60) then do:
                      d-novocentavo = 0.60.
                      i-novoreal = i-real.
                      end.
                      
                      if (d-centavo >= 0.61 and d-centavo <= 0.70) then do:
                      d-novocentavo = 0.70.
                      i-novoreal = i-real.
                      end.
                      
                      
                      if (d-centavo >= 0.71 and d-centavo <= 0.80) then do:
                      d-novocentavo = 0.80.
                      i-novoreal = i-real.
                      end.
                      
                      if (d-centavo >= 0.81 and d-centavo <= 0.90) then do:
                      d-novocentavo = 0.90.
                      i-novoreal = i-real.
                      end.
                      
                      if (d-centavo >= 0.91 and d-centavo <= 0.99) then do:
                      d-novocentavo = 0.00.
                      i-novoreal = i-real + 1.
                      end.
                      
                      
                                                                                           
                                                                                        d-novaparcela = i-novoreal + d-novocentavo.
                      
                      
                      
                if diasdeatraso >= 1 then do:
                        totaldivida = d-novaparcela.
                        jurosdivida = d-novaparcela - titvlcob.
                      end.
                      else do:
                        totaldivida = titvlcob.
                        jurosdivida = 0.
                      end.
                      
                      
     
                      
                     
                      
                      
                  /*    
                  put "cpf;tipocliente;codigocliente;nome;datanasc;pai;mae;email;rg;estado civi      l;conjuge;endereco;numero;compl;bairro;cep;cidade;estado;celular;telfixo;tel aux1;telaux2;telaux3;telaux4;telaux5;contrato;modalidade;numparcela;dividaorigina
l;dividaatualizada;datavencimento;situacao;datapagamento;;;;juros;empresa;conve
nio;" skip.put "cpf;tipocliente;codigocliente;nome;datanasc;pai;mae;email;rg;estado civil;conjuge;endereco;numero;compl;bairro;cep;cidade;estado;celular;telfixo;t   el au~x1 ;telaux2;telaux3;telaux4;telaux5;contrato;modalidade;numparcela;dividaor iginal ;dividaatualizada;datavencimento;situacao;datapagamento;;;;juros;empresa;  conven io;" skip.
                   */
                      
               put clien.ciccgc ";"
                tiporeceita ";"
                titulo.clifor ";"
                replace(clien.clinom, ";", " ") format "x(40)" ";"
                clien.dtnasc format "99/99/9999" ";"
                replace(clien.pai, ";", " ") format "x(40)" ";"
                replace(clien.mae, ";", " ") format "x(40)" ";"
                replace(clien.zona, ";", " ") format "x(60)" ";"
                clien.ciinsc format "x(20)" ";"
                cestcivil format "x(10)" ";"
                replace(clien.conjuge, ";", " ") format "x(40)" ";"
                ";"
                 replace(clien.endereco[1], ";", " ") format "x(40)"  ";"
                 replace(string(clien.numero[1]), ";", " ")  ";"
                 replace(clien.compl[1], ";", " ") format "x(12)" ";"
                 replace(clien.bairro[1], ";", " ") format "x(40)"  ";"
                 replace(clien.cep[1], ";", " ")  ";" 
                 replace(clien.cidade[1], ";", " ") format "x(40)"  ";"
                replace(clien.uf[1], ";", " ") format "x(2)"  ";" 
                replace(clien.fax, ";", " ") format "x(15)"  ";"  
                replace(clien.fone, ";", " ") format "x(15)" ";"
                replace(clien.protel[1], ";", " ") format "x(15)" ";"
                replace(clien.protel[2], ";", " ") format "x(15)" ";"
                replace(clien.cobfone, ";", " ") format "x(15)" ";"
                replace(refctel[1], ";", " ") format "x(15)" ";"
                replace(refctel[2], ";", " ") format "x(15)" ";"
                titulo.titnum ";" 
                titulo.modcod ";"
                titulo.titpar ";"
                titulo.titvlcob format "->>>>>>>>9.99" ";"
                totaldivida   format "->>>>>>>>9.99"   ";"
                titulo.titdtven format "99/99/9999" ";"
                titulo.titsit ";"
                titulo.titdtpag ";" 
                ";"
                ";"
                ";"
                jurosdivida format "->>>>>>>>>9.99" ";LEBES;FINANCEIRA;"
                titulo.tpcontrato format "x(1)" ";"
                 skip.


                                            
        end. 
        end.


              end.


              
                  




end.
       output close.

message "Arquivo gerado: " varquivo.
pause.




















