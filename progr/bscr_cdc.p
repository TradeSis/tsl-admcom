def var temcomportamento as int.
def var temcadastro as int.
def var cestcivil as char.
def var vaux as int.
def var grauinstrucao as char.
def var graucompleto as char.
 def var valorlimite as dec.
  def var valorlimiteep as dec.
  def var vencimentolimite as date.
  
  
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
         
                        def var tempocliente as int.         
                                 
                                 
                                 
                                
                                 def var datafinalcontrato as date.
                                 
                                              
                                 
def var varquivo2 as character.   
def var dtini as date format "99/99/9999" initial today.
def var dtfim as date format "99/99/9999" initial today.

 update dtini colon 15 label "CDC de" 
               dtfim label "ate".
       

varquivo2 = "/admcom/import/cdlpoa/CDC-behaviour-"
+ string(month(dtini))
+ string(year(dtini))
+ string(month(dtfim))
+ string(year(dtfim))
+  "-" + string(time) + ".csv".


display "Gerando Arquivo...".

output to value(varquivo2).

                 
                 
     put  "CODIGO_CONTRATO;
DATA_INICIO_CONTRATO;
DATA_VENCIMENTO_CONTRATO;
VALOR_ORIGINAL_CONTRATO;
QTD_PARCELAS ;
VALOR_PARCELAS ;
CPF_CLIENTE;
PRAZO_CONTRATO_DIAS;
DESCRICAO_PRODUTO;
VALOR_ENTRADA;
LOJA ( do contrato);  " skip.


for each clien where clien.clicod > 10  no-lock.


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
                                                   
                                                    
                                                          

    for each contrato use-index iconcli where contrato.clicod = clien.clicod and
                        (contrato.modcod begins "CRE" )
                                                and 
                                                contrato.dtinicial >= dtini and
                                            contrato.dtinicial <= dtfim
                                                
                                                no-lock.
                                                                                                
                                                                                                
                                                                                                if contrato.tpcontrato = "N" then next.
                                                       

diasdecontrato = 0.
                                                                                                           
                                                                                                
  valortotalcontrato = 0.
  valorparcelas=0.
  qtdparcelas=0.
  
                         valorentradas=0.                                                                       
                                                                                
datafinalcontrato = contrato.dtinicial.                                                                        
                                                                                                
           
           for each titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod  and
                       titulo.titnum = string(contrato.contnum) 
                        no-lock .
                                                                                                
                                                                                                
                                                                        datafinalcontrato = titulo.titdtven.                        
                                                                                                
                                                                                                valortotalcontrato = valortotalcontrato + titvlcob.
                                                                                                qtdparcelas = qtdparcelas + 1.
                                                                                                                                                                                                diasdecontrato  =  titulo.titdtven - contrato.dtinicial.  

                                                                        if titulo.titdtven = contrato.dtinicial then do:
                                                                                        valorentradas = valorentradas + titulo.titvlcob.
                                                                        end.


                                                                                                                                                                                                
                                                                                                
                                                                                                end.
                                                                                                
                                                                                                
               valorparcelas =   valortotalcontrato / qtdparcelas.                 
                                                                                        
                                                                                        
                                                                                        
 
                                                                                                                                                                                        
                                                                                                
                                                                                                put contrato.contnum  format ">>>>>>>>>>>>>>9" ";"
                                                                                                contrato.dtinicial format "99/99/9999" ";"
                                                                                                datafinalcontrato format "99/99/9999" ";"
                                                                                                valortotalcontrato format ">>>>>>>9.99" ";"
                                                                                                qtdparcelas format ">>9" ";"
                                                                                                valorparcelas format ">>>>>>9.99" ";" 
                                                                                                                                                                                                clien.ciccgc format "x(11)" ";"
                                                                                                                                                                                                diasdecontrato format ">>>>>9" ";"
                                                                                                                                                                                                "EMPRESTIMO" ";"
                                                                                                                                                                                                valorentradas  format ">>>>>>9.99" ";" 
                                                                                                                                                                                                contrato.etbcod  format ">>>>9" ";"
                                                                                                                                                                                         contrato.vlf_principal  format ">>>>>>9.99" ";" 
                                                                                                                                                                                        
                                                                                                                                                                                                
                                                                                                                                                                                                skip.
                                                                                                
                                                                                                
                                                                                                
                                                                                                end.
                                                                                                
                                                                                                
                    
                                                     
                                

         
end.
output close.



message "Arquivo gerado: " varquivo2.
pause.
