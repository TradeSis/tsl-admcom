def var vchavep2k as char.
def var elegivel as dec.
def var inadimplente as dec.
def var percentual as dec.
def var vardatapagamento as date.
def var ultimodia as date.
def var inadimplenciahistorica as dec.
def var varquivo as char.
def var tipobanco as char.
               
def var numerodias as dec.      
def var selic as dec.           
def var taxamesaux as dec.      
                                      
selic = 0.075.                 
                                     
def var auxprimeira as dec.     
def var auxsegunda as dec.      
def var taxames as dec.         
def var taxadia as dec.         
def var valorselic as dec.      
def var juros as dec.
                  
                  
               auxprimeira = 1 + selic.                         
               auxsegunda  = 21 / 252.                          
                            
               taxames = exp(auxprimeira,auxsegunda) - 1.       
                 
               auxprimeira = 1 + (taxames).                     
               auxsegunda = 1 / 21.                             
                                                                   
               taxadia = exp(auxprimeira,auxsegunda) - 1.       
                      
                 auxprimeira = 1 + taxadia.        
                      
                      
                      
                        /*
output to "/admcom/lebesintel/bi_titulos.csv".
             
                        */
  
varquivo = "/admcom/lebesintel/titulos/bi_titulosdevenda.csv".                   
output to value(varquivo).        
                        
for each estab where etbcod <= 999 no-lock. 
                      
elegivel = 0.
inadimplente = 0.
percentual = 0.
/*
varquivo = "/admcom/lebesintel/titulos/" + string(estab.etbcod) + ".csv". 
*/

/* disp varquivo format "x(67)". */

  /* output to value(varquivo). */

   for each plani where movtdc = 5 and pladat >= 01/01/2014 
   and plani.etbcod = estab.etbcod no-lock.                                     
                                                                              
find first fin.contnf where fin.contnf.etbcod = plani.etbcod                       
          and fin.contnf.placod = plani.placod no-lock no-error. 
      
               if not avail fin.contnf                                           
                then next.                                                    
                

    /*08032021 helio - na exportacao cre, contratos digital não são exportados mais no arquivo normal */
    find first contrato where contrato.contnum = contnf.contnum no-lock no-error.
    if avail contrato           
    then do:
        find contrsite where contrsite.contnum = contrato.contnum no-lock no-error.
        if avail contrsite
        then next.
    end.
    /*08032021 helio*/
    
    vchavep2k = "".
    if plani.pladat >= 07/01/2020 /* sap */
    then do:
        find first pdvdoc where pdvdoc.etbcod = plani.etbcod and pdvdoc.placod = plani.placod no-lock no-error.
        if avail pdvdoc
        then do:

            /* 12/11/2020 https://trello.com/c/tgX4AQfB/189-altera%C3%A7%C3%A3o-chave-arquivo-bititulosdevendacsv

            vchavep2k = string(pdvdoc.etbcod) + string(plani.cxacod) + 
                        string(pdvdoc.sequencia) +
                        string(year(pdvdoc.datamov),"9999") + 
                        string(month(pdvdoc.datamov),"99") + 
                        string(day(pdvdoc.datamov),"99"). 
                      
                      Nova:
                                    
                                    codigoLoja = 0124
                                    numeroPDV = 033
                                    nsuTransacao = 0000000037
                                    dataTransacao = 2020-07-15
                                    
                                    saída da coluna = 0124033000000003720200715
                                    */
                                    
             vchavep2k = string(pdvdoc.etbcod,"9999") + string(plani.cxacod,"999") + 
                        string(pdvdoc.sequencia,"9999999999") +
                        string(year(pdvdoc.datamov),"9999") + 
                        string(month(pdvdoc.datamov),"99") + 
                        string(day(pdvdoc.datamov),"99"). 
                        
        end.
    end.
                    
                        for each fin.titulo where                                 
                                 fin.titulo.empcod = 19  and                      
                                fin.titulo.titnat = no and                     
                                 (fin.titulo.modcod = "CRE"
                                or fin.titulo.modcod = "CP0"
                                or fin.titulo.modcod = "CP1"
                                or fin.titulo.modcod = "CP2")  
                                                          and                                            fin.titulo.etbcod = plani.etbcod and             
                                 fin.titulo.clifor = plani.desti and              
                                 fin.titulo.titnum = string(contnf.contnum) and   
                                 (fin.titulo.titdtven >= 09/01/2016)         
                      no-lock.                   
                           
                                                             
                                                      pause 0.

    if fin.titulo.titvlcob < 0 then next.
                  
           tipobanco = "Lebes".
                                                                          
      find first fin.contrato where
                 fin.contrato.etbcod = fin.titulo.etbcod
             and fin.contrato.dtinicial >= 09/01/2016 
             and fin.contrato.clicod =  fin.titulo.clifor 
             and fin.contrato.contnum =  fin.contnf.contnum
             and fin.contrato.banco = 10 no-lock no-error.            
                                  
                                                                                                          if avail fin.contrato then do:
                                              tipobanco = "Financeira".   
                                                 end.
                                                 else do:
                                             tipobanco = "Lebes".    
                                                 end.
                                         
                                                         
                             if fin.titulo.modcod = "CP0"    
                                or fin.titulo.modcod = "CP1"    
                              or fin.titulo.modcod = "CP2" then do:
                                  tipobanco = "Financeira".
                                 end.
                                                         
                                                         

    put plani.placod format ">>>>>>>>>>>>9" ";" 
    plani.etbcod  ";" plani.Desti format ">>>>>>>>>>9" ";" fin.titulo.titnum ";" fin.titulo.titpar format ">>>9" ";" YEAR(fin.titulo.titdtven) format "9999" "-"
MONTH(fin.titulo.titdtven) format "99" "-"
DAY(fin.titulo.titdtven) format "99" ";"
fin.titulo.titvlcob format ">>>>>>>>>>>>.99" ";".

if fin.titulo.titdtpag = ? then do:
                put ";".
                   end.
                   else do:
                put 
                  YEAR(fin.titulo.titdtpag) format "9999" "-"    
                   MONTH(fin.titulo.titdtpag) format "99" "-"     
                   DAY(fin.titulo.titdtpag) format "99" ";".          
                   end.
                   

ultimodia =  add-interval( date( month( fin.titulo.titdtven ), 1, year( fin.titulo.titdtven )), 1, "month" ) - 1.                                                                


if ((fin.titulo.titsit = "LIB" and fin.titulo.titdtven < today)or
    (fin.titulo.titsit ="PAG" and fin.titulo.titdtpag > ultimodia))then do:
         inadimplenciahistorica = fin.titulo.titvlcob.
        end.
        else do:
         inadimplenciahistorica = 0.
            end. 
                         
                                                                              
   if (fin.titulo.titsit = "LIB" and fin.titulo.titdtven < today)                             then do:            
                           
             numerodias = today - fin.titulo.titdtven.
             numerodias = numerodias * 0.7142.
               
             juros = 0.
             juros = fin.titulo.titvlcob * (exp(auxprimeira,numerodias) - 1).               valorselic = fin.titulo.titvlcob + juros.                                         end.                                                                          else do:                                                                               valorselic = fin.titulo.titvlcob.  
               numerodias = 0.                                                                     end.                                                              
                                                                              
                     if fin.titulo.titsit = "LIB" then do:
                                  end.
                                  else do:
                                  valorselic = 0.
                                end.

                                              
                         
                         

put 
 fin.titulo.titvlpag format ">>>>>>>>>>.99" ";" fin.titulo.titsit ";" 
 
  YEAR(ultimodia) format "9999" "-"  
  MONTH(ultimodia) format "99" "-"  
  DAY(ultimodia) format "99" ";"   
  inadimplenciahistorica format ">>>>>>>>>>>.99" ";" tipobanco
    format "x(10)" ";" fin.titulo.moecod format "x(3)"  ";" valorselic format ">>>>>>>>>>>>>>.99" ";" numerodias format ">>>>>>>>>.99"  ";" fin.titulo.modcod 
    
    ";"   
    
    vchavep2k format "x(30)" ";"
    
    skip.
                                                     end.
                                                     

end.

/* output close.  */

end.           

                 
     output close.        
