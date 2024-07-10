{admcab.i}


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

def var datadivida as date.
def var valordivida as dec.
 


 def var tempago as int.
 def var temaberto as int.
 def var datapago as date.

def var varquivo        as character.
def var varquivo2 as character.


varquivo = "/admcom/import/serasa/serasa-lib-"
+ string(day(today))
+ string(month(today))
+ string(year(today))
+  "-" + string(time) + ".csv".


varquivo2 = "/admcom/import/serasa/serasa-pag-"
+ string(day(today))
+ string(month(today))
+ string(year(today))
+  "-" + string(time) + ".csv".





display "Gerando Arquivos Abertos - Serasa" skip.
















output to value(varquivo).



for each clien where clien.clicod > 10 no-lock.

tempago = 0.
temaberto = 0.

pause 0.
                                 
if length(clien.ciccgc) <> 11 then next.
if clien.clinom = "" then next.
if clien.ciccgc = "" then next.
if clien.estciv = 6 then next.



             
   find first titulo use-index iclicod
             where titulo.clifor = clien.clicod and 
                   titulo.modcod begins "CP" and 
                   titulo.titsit = "LIB" and
                   titulo.titdtpag = ? and
                   titulo.titdtven < (today - 30) no-lock no-error. 


        if not avail titulo then next.
              


        

    for each contrato where contrato.clicod = clien.clicod and
                        contrato.modcod begins "CP" no-lock.
                                                
                                                

pause 0.
           
            find first titulo where titulo.empcod = 19 and
                                    titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod  and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titsit = "LIB" and
                       titulo.titdtven < (today - 30) and
                       titulo.titdtpag = ? 
                        no-lock no-error.




                      if avail titulo then do:


                        datadivida = titulo.titdtven.
                        valordivida = 0.

                for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum) and
                          titulo.titsit = "LIB" and
                          titulo.titdtpag = ? and
                          titulo.titdtven < today 
                           no-lock.
                          
                            pause 0.
                            
                      diasdeatraso = today - titdtven.
                          
                          if titulo.titdtven < datadivida then do:
                                datadivida = titulo.titdtven.
                          end.
                         
                          
                          valordivida = valordivida + titvlcob.
                          
                          
                          
                          
                          
                          
                          end.
   
                    put
                contrato.contnum format ">>>>>>>>>>>>9" ";"
                "11271860000186" ";"
             clien.ciccgc format "x(11)" ";"
            year(datadivida)  format "9999" "-"
           month(datadivida) format "99" "-"
             day(datadivida)   format "99" ";"
           "CREDITO PESSOAL" ";"
           valordivida format ">>>>>>>>>>9.99" ";" skip.


                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          end.
                          
                                                
                       
                          
                          
                          end.
                          
                          
                          
                          
                          
                          
                          
                    

end.
output close.




           display "Gerando Arquivos Pagos - Serasa".
           
           



output to value(varquivo2).


for each clien where clien.clicod > 10 no-lock.

                 pause 0.
                                 
if length(clien.ciccgc) <> 11 then next.
if clien.clinom = "" then next.
if clien.ciccgc = "" then next.
if clien.estciv = 6 then next.




     find first titulo use-index iclicod
             where titulo.clifor = clien.clicod and 
                   titulo.modcod begins "CP" and 
                   titulo.titsit = "PAG" and
                                   titulo.titdtpag >= (today - 7) and
                   titulo.titdtpag <= today no-lock no-error. 


        if not avail titulo then next.
                
                
                

    for each contrato where contrato.clicod = clien.clicod and
                        contrato.modcod begins "CP" no-lock.
                                                
                                                

                pause 0.
           
            find first titulo where titulo.empcod = 19 and
                       titulo.titnat = no and
                       titulo.modcod = contrato.modcod and
                       titulo.etbcod = contrato.etbcod and
                       titulo.clifor = contrato.clicod  and
                       titulo.titnum = string(contrato.contnum) and
                       titulo.titsit = "PAG" and
                       titulo.titdtven < (today - 30) and
                       titulo.titdtpag >= (today - 7)
                        no-lock no-error.

                

                      if avail titulo then do:
                      tempago = 1.
                      datapago = titulo.titdtpag.
                      end.
                      else do:
                      tempago = 0.
                      datapago = ?.
                      end.

   find first titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod  and
                      titulo.titnum = string(contrato.contnum) and
                      titulo.titsit = "LIB" and
                      titulo.titdtven < (today - 30) no-lock no-error.
                                               

                           if avail titulo then do:
                                     temaberto = 1.
                                end.
                                else do:
                                   temaberto = 0.
                                 end.
                                                         











                        if (tempago = 1 and temaberto = 0) then do:


                                          
                    put
                contrato.contnum format ">>>>>>>>>>>>9" ";"
                "11271860000186" ";"
             clien.ciccgc format "x(11)" ";"
            year(datapago)   format "9999" "-"
           month(datapago)   format "99" "-"
             day(datapago)   format "99" ";" skip.

                                          
                                          
                                          
                                          
                                          
                                          
                                          end.
                
                
                


end. 





end.
output close.



                                                  pause.













