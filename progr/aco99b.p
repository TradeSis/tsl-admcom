

def var varquivo2 as character.

def var datainicio as date.
def var datafim as date.
def var tematraso as int.
def var atrasoatehoje as int.        
def var temrecente as int.        
def var statuscliente as char.
def var tipoproduto as char.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
 

 
  update vdtini colon 15 label "Contratos emitidos de"
                 vdtfim label "ate".
                 
 
varquivo2 = "/admcom/import/cdlpoa/relatorio-"
 + string(day(vdtini))
 + string(month(vdtini))
 + string(year(vdtini))
  + string(day(vdtfim))
 + string(month(vdtfim))
 + string(year(vdtfim))
 +  "-" + string(time) + ".csv".
 

 display "Gerando contratos...". 
  
output to value(varquivo2).
                                       
                                              
 for each contrato use-index por_dtinicial_modcod 
                  where contrato.dtinicial >= vdtini  and
                         contrato.dtinicial <= vdtfim and
                   (  contrato.modcod = "CRE" or
                     contrato.modcod begins "CP"
                   ) 
 no-lock:
 

   
  
       find first clien where clien.clicod = contrato.clicod no-lock no-error.
       if not avail clien then next.                   
              
 if (length(clien.ciccgc) <> 11) then next.
  

  if clien.ciccgc = ? then next.
  if clien.clinom = "" then next.
  if clien.ciccgc = "" then next.
  if clien.estciv = 6 then next.
 
                                                                                                    
                    tematraso = 0.
                    atrasoatehoje = 0.
                    temrecente = 0.
                    statuscliente = "B".
                                                                                                   
if (contrato.tpcontrato = "N") then next. 
if (contrato.modcod = "CPN")  then next.
                                  
                                                             
                           
                  find first titulo use-index iclicod where titulo.empcod = 19 and                                             titulo.titnat = no and
                             titulo.modcod = contrato.modcod and       
                             titulo.etbcod = contrato.etbcod and                                              titulo.clifor = contrato.clicod  and
                             titulo.titnum = string(contrato.contnum) no-lock no-error.
                               
         
                     
                     if not avail titulo then next.
                     
                                    
            for each titulo use-index iclicod where empcod = 19 and titnat = no 
                     and  titulo.modcod = contrato.modcod
                     and titulo.clifor = contrato.clicod
                     and titulo.etbcod = contrato.etbcod 
                     and titulo.titnum = string(contrato.contnum) no-lock:
              
            
                         
             if titulo.titsit <> "LIB" and titulo.titsit <> "PAG" then next.
                         
                                                
							/*
												
                         if titulo.titdtven >= today then do:
                              temrecente = 1.
                         end.
                        
                                                
                         
                         if temrecente = 1 then next.
                         
                        */
                                                  
         
                      if( ( (titulo.titdtpag - titulo.titdtven) >= 60) and titulo.titsit = "PAG") then do:
                         tematraso = 1.
                         end.
                        
                        
                    if (((today - titulo.titdtven) >= 60) and titulo.titsit = "LIB")  then do:
                           atrasoatehoje = 1.
                         end.
                         
          
                  if atrasoatehoje = 1 or tematraso = 1 then do:
                       statuscliente = "M".
                  end.
                  
                           
                                                   
       pause 0.                   

end.

pause 0.



                          if contrato.modcod = "CRE" then do:
                                         tipoproduto = "CDC".
                                           end.
                                            else do:
                                                 tipoproduto = "CPE".
                                            end.
                          
                    pause 0.
                     
                                         
                                              if temrecente = 0 then do:
                                         
                  put 
                           contrato.dtinicial format "99/99/9999" ";"
                           clien.ciccgc  format "x(11)"   ";"
                           contrato.contnum format ">>>>>>>>>>>>>>>9" ";"
                           tipoproduto format "x(3)" ";"
                           statuscliente format "x(1)" ";"
                       contrato.vltotal format "->>>>>>>>>>>>>>>9" ";"
                 clien.prorenda[1] format ">>>>>>>>9" ";"
                    skip. 
                                        
                                        end.
                           
                                                
                                          
                     
end.                


output close.
message varquivo2.
pause.


