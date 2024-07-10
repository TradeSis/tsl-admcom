def var temcomportamento as int.
def var temcadastro as int.
def var cestcivil as char.
def var vaux as int.
def var grauinstrucao as char.
def var graucompleto as char.
 def var valorlimite as dec.
  def var valorlimiteep as dec.
  def var vencimentolimite as date.
  
  
                    
   def var maiordiadeatrasoep as int.
  def var maiordiadeatrasocdc as int.
  

  def var dtfuturo as date.
  

  dtfuturo = 10/31/2041.
  
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
                                 
                       def var diasdeatraso as int.          
                                 
                                
                                 
                                 
                                 
               

def var varquivo2 as character.   
def var dtini as date format "99/99/9999" initial today.
def var dtfim as date format "99/99/9999" initial today.

 update dtini colon 15 label "Cliente de" 
               dtfim label "ate".
       

varquivo2 = "/admcom/import/cdlpoa/CLI-behaviour-"
+ string(month(dtini))
+ string(year(dtini))
+ string(month(dtfim))
+ string(year(dtfim))
+  "-" + string(time) + ".csv".


display "Gerando Arquivo...".

output to value(varquivo2).

                 
                 
     put  "CPF;
DATA_CADASTRO;
VISAO;
CEP;
CEP1;
CEP2;
CEP3;
CEP4;
RENDA_INFORMADA;
ESTADO_CIVIL;
ESCOLARIDADE;
PROFISSAO;
TEMPO_CLIENTE;
SEXO;
DATA_NASCIMENTO ;
NUMERO_DEPENDENTES;
LIMITE_ATUAL_CLIENTE_CDC;
LIMITE_ATUAL_CLIENTE_EP;
LOJA (FILIAL DO CADASTRO);
MAIOR DIA DE ATRASO EP;
MAIOR DIA DE ATRASO CDC;
" skip.


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
                                                                  






















tempocliente =0.

tempocliente = today - dtcad.

find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

if not avail cpclien then next.

grauinstrucao = "NAO INFORMADO".
graucompleto = " ".


temcomportamento = 0.
temcadastro = 0.

  
         find first neuclien where neuclien.Clicod = clien.clicod no-lock no-error.

if not avail neuclien then do:
valorlimite = 0.
valorlimiteep = 0.
end.
else do:
valorlimite = VlrLimite.
vencimentolimite = neuclien.VctoLimite.

if vencimentolimite < today then do:
valorlimite = 0.
end.

if valorlimite >= 3500 then do:
valorlimiteep = 3500.
end.
else do:
valorlimiteep = valorlimite.
end.




end.


      
             
                                          




                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "". 
                                           

   do vaux = 1 to 5:
        if aux-instrucao[vaux] = acha("INSTRUCAO",cpclien.var-char8)
        then grauinstrucao = acha("INSTRUCAO",cpclien.var-char8).
    end.
         
        

  if cpclien.var-log8 = yes then do:
  graucompleto = "COMPLETO".
  end.
  else do:
  graucompleto = "INCOMPLETO".
  end.
  
  
  if grauinstrucao = "NAO INFORMADO" then do:
  graucompleto = " ".
  end.
  
  


                           pause 0.
                                                                        
                                       
   maiordiadeatrasoep = 0.
  maiordiadeatrasocdc = 0.
diasdeatraso = 0.

   for each titulo use-index iclicod where titulo.clifor = clien.clicod and
     titulo.titnat = no and
   ( titulo.modcod = "CP1" OR titulo.modcod = "CP0" 
    OR titulo.modcod = "CRE" ) and titdtven >=  dtini  and titdtven <=  dtfuturo
        and titdtemi >=  dtini  and titdtemi <=  dtfim



        no-lock.
      
          
          
          if titsit = "PAG" then do:
          
             if titulo.titdtpag = ? then next.
          
          
          
           diasdeatraso = titdtpag - titdtven.
                 
                         
                                              
      if maiordiadeatrasoep < diasdeatraso and titulo.modcod begins "CP" then do:
                     maiordiadeatrasoep = diasdeatraso.
                end.
                                                               
  if maiordiadeatrasocdc < diasdeatraso and titulo.modcod = "CRE" then do:
                    maiordiadeatrasocdc = diasdeatraso.
               end.                      
                           
                           
                           
          
          
          
          end.
          else do:
          
          
            if titulo.titsit <> "LIB" then next.
          
            if titulo.titdtpag <> ? then next.
          
          
          
           diasdeatraso = today - titdtven.
                 
                         
                                              
      if maiordiadeatrasoep < diasdeatraso and titulo.modcod begins "CP" then do:
                     maiordiadeatrasoep = diasdeatraso.
                end.
                                                               
  if maiordiadeatrasocdc < diasdeatraso and titulo.modcod = "CRE" then do:
                    maiordiadeatrasocdc = diasdeatraso.
               end.                      
                           
          
          
          
          
          
          
          
          
          end.
          
          
          
          
          
          
          
          
          
          
          
          
          end.


                                                                           
                                


  put clien.ciccgc format "x(20)" ";"
      clien.dtcad format "99/99/9999"  ";"
       today format "99/99/9999"  ";"
        replace(clien.cep[1], ";", " ")  ";"
        replace(clien.cep[1], ";", " ") format "x(1)" ";"
        replace(clien.cep[1], ";", " ") format "x(2)" ";"
        replace(clien.cep[1], ";", " ") format "x(3)" ";"
        replace(clien.cep[1], ";", " ") format "x(4)" ";"
        clien.prorenda[1] format ">>>>>>>>9" ";"         
           cestcivil format "x(15)" ";"
                   grauinstrucao format "x(15)" " " graucompleto format "x(15)" ";"
                     replace(clien.proprof[1], ";", " ") format "x(100)" ";"
                           tempocliente format ">>>>9" ";"
                                         clien.sexo ";"
                                               clien.dtnasc format "99/99/9999" ";"
                                           clien.numdep format ">>>>>>9" ";"
                                             valorlimite format "->>>>>>>>>>9" ";"
                                                 valorlimiteep format "->>>>>>>>>>9" ";"
                                        clien.etbcad format ">>>>>>9" ";"
                                        maiordiadeatrasoep format ">>>>>>9" ";"
                                        maiordiadeatrasocdc format ">>>>>>9" ";"
                   skip.                
       
         
end.
output close.



message "Arquivo gerado: " varquivo2.
pause.


