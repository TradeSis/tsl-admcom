def var temcomportamento as int.
def var temcadastro as int.
def var cestcivil as char.
def var vaux as int.
def var grauinstrucao as char.
def var graucompleto as char.
def var statusparcela as char.
 def var valorlimite as dec.
  def var valorlimiteep as dec.
  def var vencimentolimite as date.
  def var juroscobrado as dec.
  def var tipoparcela as char.
  
  def var valortotalcontrato as dec.
  def var valorparcelas as dec.
  def var qtdparcelas as int.
   def var valorentradas as dec.
  
  
  def var diasdecontrato as int.
  
DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
 assign
        aux-instrucao[1] = "Fundamental"
        aux-instrucao[2] = "Primeiro grau"
        aux-instrucao[3] = "Segundo grau"
        aux-instrucao[4] = "Curso superior"
        aux-instrucao[5] = "Pos/Mestrado"    
        .
                   
FUNCTION acha returns character
    (input par-oque as char,
     input par-onde as char).
         
    def var vx as int.
    def var vret as char.  
    
    vret = ?.  
    
    do vx = 1 to num-entries(par-onde,"|"). 
        if entry(1,entry(vx,par-onde,"|"),"=") = par-oque 
        then do: 
            vret = entry(2,entry(vx,par-onde,"|"),"="). 
            leave. 
        end. 
    end.
    return vret. 
END FUNCTION.
def var tipoproduto as char.
         
                        def var tempocliente as int.         
                                 
                                 
                                 
                                
                                 def var datafinalcontrato as date.
                                 
                                 
                                 
def var varquivo2 as character.   
def var dtini as date format "99/99/9999" initial today.
def var dtfim as date format "99/99/9999" initial today.

 update dtini colon 15 label "Parcelas de" 
               dtfim label "ate".
       

varquivo2 = "/admcom/import/cdlpoa/PAR-behaviour-"
+ string(month(dtini))
+ string(year(dtini))
+ string(month(dtfim))
+ string(year(dtfim))
+  "-" + string(time) + ".csv".


display "Gerando Arquivo...".

output to value(varquivo2).


                 
                 
     put  "CODIGO_PARCELA;
DATA_VENCIMENTO;
DATA_PAGAMENTO;
VALOR_PARCELA;
VALOR_PAGO;
VALOR_MINIMO;
CODIGO_CONTRATO;
NUMERO_PARCELA;
FORMA_PAGAMENTO;
JUROS_PAGO;
DESCRICAO_PRODUTO;
CPF_CLIENTE;
STATUS_PARCELA;
LOJA CONTRATO;  " skip.


for each clien where clien.clicod > 10 no-lock.


 if length(clien.ciccgc) = 11 then do:
 end.
 else do:
     next.
 end.
  
  
  if clien.ciccgc = ? then next.
  if clien.clinom = "" then next.
  if clien.ciccgc = "" then next.
  if clien.estciv = 6 then next.
  



pause 0.


                                
                   
 find first titulo use-index iclicod where
                      titulo.clifor = clien.clicod and
                      titulo.titdtemi >= dtini and
                      titulo.titdtemi <= dtfim
                            no-lock no-error.
                                                
                                   
                      if avail titulo then do:
                             temcomportamento = 1.
                            end.
                            else do:
                             temcomportamento = 0.
                            end.
                                                        
                                                        
                        if clien.dtcad >= dtini and
                           clien.dtcad  <= dtfim then do:
                             temcadastro = 1.
                            end.
                            else do:
                             temcadastro = 0.
                            end.
                                  
                                                                  
                                                                  
             if   temcadastro = 1  or temcomportamento = 1 then do:

                                                        end.
                                                        else do:
                                                                next.
                                                        end.                                                        
                                                                 
  


                           pause 0.
                                                   
                                                    
                                                                                                
                                                                                                
           
           for each titulo use-index iclicod where titulo.empcod = 19 and
                       titulo.titnat = no and
                       (titulo.modcod = "CRE" OR titulo.modcod = "CP0" OR titulo.modcod = "CP1" OR titulo.modcod = "CP2")  and
                       titulo.clifor = clien.clicod  and
                       
					   (
					   (titulo.titdtemi >= dtini and  titulo.titdtemi <= dtfim)
					   or
					     (titulo.titdtven >= dtini and  titulo.titdtven <= dtfim)
						 or 
						  (titulo.titdtpag >= dtini and  titulo.titdtpag <= dtfim)
					   )
                        no-lock .
                                       
									   
				if titulo.titsit <> "PAG" and titulo.titsit <> "LIB" then next.
                        if titulo.moecod = "DEV" then next.                                
																	    
   
						
						if titulo.titsit = "PAG" then do:
						juroscobrado = titulo.titvlpag - titulo.titvlcob.
						end.
						
						if titulo.modcod = "CRE" then do:
								tipoproduto = "CDC".
						end.
						else do:
								tipoproduto = "EMPRESTIMO".
						end.
                                
						if (titsit = "PAG" and titdtpag <> ?) then do:
								tipoparcela = "PAGO".
						end.
						else do:
								tipoparcela = "ABERTO".
						end.
				
				
				if juroscobrado < 0 then do:
				juroscobrado = 0.
				end.
		
				
				
								
                                                                                                put titulo.etbcod "-" titulo.titnum "-" titulo.titpar  ";"
                                                                                               titulo.titdtven format "99/99/9999" ";"
                                                                                               titulo.titdtpag format "99/99/9999" ";"
                                                                                                titulo.titvlcob format "->>>>>>>9.99" ";"
                                                                                               titulo.titvlpag format "->>>>>>>9.99" ";"
                                                                                              titulo.titvlcob format "->>>>>>>9.99" ";"
                                                                                               titulo.titnum  ";"
																							  titulo.titpar format "->>>9" ";"
																								titulo.moecod  ";"
																								juroscobrado format "->>>>>>>9.99" ";"
																								tipoproduto format "x(10)" ";"
																								clien.ciccgc format "x(11)" ";"
																								tipoparcela  format "x(6)" ";"
																								titulo.etbcod ";" 
																							
																								
																								skip.
                                                                                                
																								
																								
                                                                                                
                                                                                                
                                                                                                end.
                                                                                                
                                                                                                
                    
                                                     
                                

         
end.
output close.



message "Arquivo gerado: " varquivo2.
pause.
