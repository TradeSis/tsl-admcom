def var vencimentolimite as date.
 def var verifica as dec.
 def var valorlimite as dec.

 
def var vlcre as dec.
def var vlcp as dec.
def var vlnov as dec.
def var vlcpn as dec.
def var parcelaprincipal as dec.    
 
 
def var clientesituacao as char. 
     def var abertototal as dec.
     def var abertoep as dec.
     def var abertocdc as dec.
     def var valorlimitedisponivel as dec.
          
     def var temnovo as int.
     def var temantigo as int.
     def var temtituloatraso as int.

     def var temnovocdc as int.
     def var temantigocdc as int.
     def var temtituloatrasocdc as int.
     
     def var temnovoavista as int.
     def var temantigoavista as int.
     
     
       def var pagozerocinco as int.
       def var pagoseisquinze as int.
       def var pagomaisquinze as int.
         def var pagogeral as int.
           

     def var temspc as int.

    def var jaep as int.
    def var jacdc as int.
    def var jaavista as int.

        def var cestcivil as char.
        
def var tiporeceita as char.

def var qtdcdc as int.        
def var qtdep as int.
def var qtddiasep as int.
def var qtdatrasoep as int.
def var qtdatrasoepmto as int.

def var qtdtitulos as int.
def var qtddias as int. 
def var qtdatraso as int.
def var qtdmtoatraso as int.

     def var totalcliente as int.
     
         
            def var totpar as int.
   def var totparcdc as int.
   def var totparglobal as int.

    def var fatorusar as dec. 
    def var totaldivida as dec.
    def var diasdeatraso as int.
    def var totaldividacdc as dec.
    def var diasdeatrasocdc as int.


    def var i-real    as int no-undo.
    def var d-centavo as dec decimals 2 no-undo.
            
    def var i-novoreal    as int no-undo.
    def var d-novocentavo as dec decimals 2 no-undo.
                        
    def var d-novaparcela like estoq.estven.
    def var d-novototal   like estoq.estven.
                                        
       def var maiordiadeatraso as int.                                 
       def var maiordiadeatrasocdc as int.                                 
       def var maiordiadeatrasoglobal as int.
                                        
               def var parcelafinal as dec.                         
         def var totaldividaglobal as dec.                               
                                        
         
         def var valortotal as dec.
         def var valorcdc as dec.
         def var valorep as dec.
         def var valorinclu as dec.
         
         def var clientenumerosorte as int.
         
		 

def var etb_ini as int initial 1.
def var etb_fim as int  initial 999.


  update etb_ini colon 15 label "Clientes das filiais "
                 etb_fim label "ate".

def var varquivo2 as character.    

varquivo2 = "/admcom/import/cdlpoa/dna-"
+ string(day(today))
+ string(month(today))
+ string(year(today))
+  "-" + string(time) + "-" + string(etb_ini) + "-" +  string(etb_fim) + ".csv".



 display "Gerando clientes...". 
  
output to value(varquivo2).
		 
		 
     put  "cpf;Tipo;jaep;jacdc;jaavista;temnovo;temantigo;temtituloatraso;temnovocdc;temantigocdc;temtituloatrasocdc;temnovoavista;temantigoavista;temspc;Codigo;totaldivida;
	 abertoep;maiordiadeatraso;totpar;totaldividacdc;abertocdc;maiordiadeatrasocdc;totparcdc;totaldividaglobal;abertototal;maiordiadeatrasoglobal;totparglobal;
               nome;datacadastro;dataultimaalteracao;clientesituacao;vencimentolimite;qtdtitulos;
           qtdcdc ;
           qtddias  ;
           qtdatraso  ;
           qtdmtoatraso ;
           qtdep format ;
           qtddiasep ;
           qtdatrasoep ;
           qtdatrasoepmto;
         rendacliente ;
          generocliente ;
         profissaocliente;
          cidadecliente;
         bairrocliente;datanasc;rg;cep;end;num;compl;estadocivil;conjuge;pai;mae;naturalidade;dependentes;tiporesidencia;
			temporesidencia;nacionalidade;email;celular;fone;tel1;tel2;tel3;tel4;tel5;tel6;tel7; valortotal ;
           valorcdc   ;
           valorep   ;
          LojaBase;     
                   valorlimite ;
                   valorlimitedisponivel ;
                   vlcre ;
                   vlnov ;
                     vlcp ;                     
                      vlcpn ;
                      pagogeral ;
                      pagozerocinco ;
                      pagoseisquinze ;
                      pagomaisquinze ;
                     clientenumerosorte;" skip.


for each clien where clien.clicod > 10 and (etbcad >= etb_ini and etbcad <= etb_fim) no-lock.




clientenumerosorte = clientenumerosorte + 1.

 if length(clien.ciccgc) = 11 then do:
     tiporeceita = "PF".
 end.
 else do:
     tiporeceita = "CNPJ".
 end.
  
  
  if clien.ciccgc = ? then next.
  if clien.clinom = "" then next.
  if clien.ciccgc = "" then next.
  if clien.estciv = 6 then next.
  







pause 0.


         find first neuclien where neuclien.Clicod = clien.clicod no-lock no-error.

if not avail neuclien then next.

/*
if neuclien.VctoLimite > today + 30 then  next.
*/
	
             
                                          

               totalcliente = totalcliente + 1.                       
                   
 find first titulo use-index iclicod where
                      titulo.clifor = clien.clicod and
                      titulo.titdtven >= (today - 365) and
                      titulo.modcod = "VVI"
                            no-lock no-error.
                                                
                                   
                      if avail titulo then do:
                             temnovoavista = 1.
                            end.
                            else do:
                             temnovoavista = 0.
                            end.
                                                             
     find first titulo use-index iclicod where
                         titulo.clifor = clien.clicod and
                         titulo.titdtven < (today - 365) and
                         titulo.modcod = "VVI"
                                    no-lock no-error.

                      if avail titulo then do:
                        temantigoavista = 1.
                           end.
                            else do:
                        temantigoavista = 0.
                           end.
     

















                                                         
    find first titulo use-index iclicod where
                     titulo.clifor = clien.clicod and
                         titulo.titdtven >= (today - 365) and 
                         titulo.modcod begins "CP" 
                       no-lock no-error.
                                                          
                                                     
                       if avail titulo then do:
                              temnovo = 1.                                                                end.
                           else do:
                              temnovo = 0.
                           end.
                           

  find first titulo use-index iclicod where
                       titulo.titnat = no and 
                       titulo.clifor = clien.clicod and
                       titulo.titdtven >= (today - 365) and
                       titulo.modcod = "CRE"
                                no-lock no-error.
                                                
                                                
                        if avail titulo then do:
                              temnovocdc = 1.
                            end.
                                else do:
                              temnovocdc = 0.
                            end.
                                                             
                                                             
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
       
                           
        find first titulo use-index iclicod where
                         titulo.titnat = no and
                         titulo.clifor = clien.clicod and
                         titulo.titdtven < (today - 365) and
                         titulo.modcod begins "CP"
                                             no-lock no-error.
                                                  
                             
                           if avail titulo then do:
                              temantigo = 1.
                                  end.
                                  else do:
                              temantigo = 0.
                                  end.
                                                             
                           
                    find first plani  where
                  plani.pladat < (today - 365) and
                  plani.movtdc = 5 and
                  plani.Desti = clien.clicod and
                  plani.modcod begins "CP"                   
                  no-lock no-error.

                                                                                            if avail plani then do:
                      temantigo = 1.
                  end.         
                           
                                              
       find first titulo use-index iclicod where
                           titulo.titnat = no and 
                           titulo.clifor = clien.clicod and
                           titulo.titdtven < (today  - 365) and
                           titulo.titsit = "LIB" and
                           titulo.modcod begins "CP"
                        no-lock no-error.
                            
                      if not avail titulo then do:
                         temtituloatraso = 0.
                            end.
                            else do:
                         temtituloatraso = 1.
                           end.
                           
                           

                    find first titulo use-index iclicod where
                         titulo.clifor = clien.clicod and
                         titulo.titdtven < (today - 365) and
                         titulo.modcod begins "CRE"
                              no-lock no-error.


                           if avail titulo then do:
                             temantigocdc = 1.
                                 end.
                                else do:
                             temantigocdc = 0.
                                  end.
                                  
                            find first plani  where
                  plani.pladat < (today - 365) and
                  plani.movtdc = 5 and
                  plani.Desti = clien.clicod and
                      plani.modcod = "CRE"
                                no-lock no-error.

                                                                                                                                                                          if avail plani then do:
                          temantigocdc = 1.
                            end.
                                                    
        find first titulo use-index iclicod where
                          titulo.clifor = clien.clicod and
                          titulo.titnat = no and 
                          titulo.titdtven < (today - 365) and
                          titulo.titsit = "LIB" and
                          titulo.modcod = "CRE"
                                   no-lock no-error.

                      if not avail titulo then do:
                                 temtituloatrasocdc = 0.
                               end.
                               else do:
                                 temtituloatrasocdc = 1.
                               end.
                                                                           
                                                                             
                 find first clispc where clispc.clicod = clien.clicod and
                        dtcanc = ? no-lock no-error.
                             
                            if avail clispc then do:
                                   temspc = 1.
                                 end.
                                 else do:
                                   temspc = 0.
                              end.
               
               
                                                                             
                                                                            
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                          
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
                                                                             
     if (temnovo = 1 or temantigo = 1) then do:
                 jaep = 1.                                                      
            end.
            else do:
                 jaep = 0.
            end.
   
                                                     
     if (temnovocdc = 1 or temantigocdc = 1) then do:
                 jacdc = 1.
            end.
            else do:
                 jacdc = 0.
            end.
                                                                           
                                                     
     if (temnovoavista = 1 or temantigoavista = 1) then do:
                 jaavista = 1.
            end.
            else do:
                 jaavista = 0.
            end.
                                                     
                          
                
                cestcivil = if clien.estciv = 1 then "Solteiro" else
                            if clien.estciv = 2 then "Casado"   else
                            if clien.estciv = 3 then "Viuvo"    else
                            if clien.estciv = 4 then "Desquitado" else
                            if clien.estciv = 5 then "Divorciado" else
                            if clien.estciv = 6 then "Falecido" else "". 
                                           
           
                                    
                                qtdtitulos = 0.
                                qtdcdc = 0.
                                qtddias = 0.
                                qtdatraso = 0.
                                qtdmtoatraso = 0.
                    
                                qtdep = 0.
                                qtddiasep = 0.
                                qtdatrasoep = 0.
                                qtdatrasoepmto = 0.
                                                            
                                    
                                    


pagogeral=0.
pagozerocinco=0.
pagoseisquinze = 0.
pagomaisquinze = 0.


         for each titulo use-index iclicod 
         where titulo.clifor = clien.clicod
          and titsit = "PAG"
          and titnat = no
          and (titulo.modcod = "CP1" or
               titulo.modcod = "CP0" or
               titulo.modcod = "CPN" or
               titulo.modcod = "CRE") 
              no-lock.             
          
                
                
                 
          if titulo.titdtpag = ? then next.
          if titulo.titdtven = ? then next.
                   
                   
                   
          qtdtitulos = qtdtitulos + 1.
          
         pagogeral = pagogeral + 1.
           
           if ((titdtpag - titdtven) <= 5) then do:
           pagozerocinco = pagozerocinco + 1.
           end.
           
            if ((titdtpag - titdtven) >= 6) and ((titdtpag - titdtven) <= 15)
             then do:
               pagoseisquinze = pagoseisquinze + 1.
           end.
           
            if ((titdtpag - titdtven) >= 16) then do:
             pagomaisquinze = pagomaisquinze + 1.
           end.
           
          
          
          
        if ((titdtpag - titdtven) > 5) then do:
          qtdatraso = qtdatraso + 1.
         end.
         else do:
          qtddias = qtddias + 1.
         end.

        if ((titdtpag - titdtven) >= 60) then do:
           qtdmtoatraso = qtdmtoatraso + 1.
        end.

     if (((titdtpag - titdtven) >= 60) and titulo.modcod begins "CP") then do:
           qtdatrasoepmto = qtdatrasoepmto + 1.
        end.


        if (((titdtpag - titdtven) > 5) and titulo.modcod begins "CP") then do:
                   qtdatrasoep = qtdatrasoep + 1.
                           end.
                           
        if (((titdtpag - titdtven) <= 5) and titulo.modcod begins "CP") then do:
                           qtddiasep = qtddiasep + 1.
                                end.
                                                      

                           
                           
        if (titulo.modcod = "CP0" or titulo.modcod = "CP1" or titulo.modcod = "CPN") then do:
            qtdep = qtdep + 1.
        end.


        if titulo.modcod = "CRE" then do:
            qtdcdc = qtdcdc + 1.
        end.

            


              end.








                          
                          
                          
                 totaldivida = 0.
         maiordiadeatraso = 0.
         totaldividacdc = 0.
         maiordiadeatrasocdc = 0.
         totaldividaglobal = 0.
         maiordiadeatrasoglobal = 0.
         totpar = 0.
         totparcdc = 0.
         totparglobal = 0.

        abertototal = 0.
        abertoep = 0.
        abertocdc = 0.

   for each titulo use-index iclicod where titulo.clifor = clien.clicod and
     titulo.titnat = no and
   ( titulo.modcod = "CP1" OR titulo.modcod = "CP0" OR titulo.modcod = "CPN"
    OR titulo.modcod = "CRE" ) 
      AND titdtven < today  and  titsit = "LIB"  no-lock.
      

     if titulo.titdtpag <> ? then next.



                       diasdeatraso = today - titdtven.
                 
                                
                                 
                                              
      if maiordiadeatraso < diasdeatraso and titulo.modcod begins "CP" then do:
                     maiordiadeatraso = diasdeatraso.
                end.
                                                               
  if maiordiadeatrasocdc < diasdeatraso and titulo.modcod = "CRE" then do:
                    maiordiadeatrasocdc = diasdeatraso.
               end.                                
                                                               
                                                               
                                                               
       find first tabjur where tabjur.nrdias = diasdeatraso and
          tabjur.etbcod = titulo.etbcod no-lock no-error.
                    
                     if not avail tabjur then do:
                           fatorusar = 10.
                                end.
                          else do:
                          fatorusar = fator.
                                  end.
                                            
                                                          
                                                                              
          /*                                                                                jurinhoep = jurinhoep + ((titvlcob * fatorusar) - titvlcob).
            */                                                                           
                               
                                                        
                                                                      
    /*                                                                                atrasoep = atrasoep + titvlcob.
      */    
          
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
    
    if titulo.modcod begins "CP" then do:
        totaldivida  = totaldivida + d-novaparcela.
         totpar = totpar + 1.
         abertoep = abertoep + titvlcob.
          end.
          else do:
        totaldividacdc = totaldividacdc + d-novaparcela.  
          totparcdc = totparcdc + 1.
          abertocdc = abertocdc + titvlcob.
          end.
                                 
                                 
     
    end. 
     
         abertototal = abertoep + abertocdc.
        totaldividaglobal = totaldivida + totaldividacdc.
         totparglobal = totpar + totparcdc.
        
        if maiordiadeatraso > maiordiadeatrasocdc then do:
     maiordiadeatrasoglobal = maiordiadeatraso.   
        end.
        else do:
      maiordiadeatrasoglobal = maiordiadeatrasocdc.  
        end.
     
    
         
         find first neuclien where neuclien.Clicod = clien.clicod no-lock no-error.

if not avail neuclien then do:
valorlimite = 0.
vencimentolimite = ?.
clientesituacao = " ".
end.
else do:
valorlimite = VlrLimite.
vencimentolimite = neuclien.VctoLimite.
clientesituacao = Sit_Credito.
end.



if vencimentolimite < today then do:
valorlimite = 0.
end.

                                   
         
           /*     
                   
         verifica = 0.
         
         for each titulo use-index iclicod where titulo.empcod = 19 and
         titulo.titnat = no and
         titulo.clifor = clien.clicod and
         titulo.titsit = "LIB" no-lock.
               
              verifica = verifica + titulo.titvlcob.
                
       
        end.

         */
         
         
vlcre = 0.
vlnov = 0.
vlcp = 0.                      
vlcpn = 0.
                 
                 

for each titulo use-index iclicod where titulo.clifor = clien.clicod
 and empcod = 19 and titnat = no and titulo.modcod = "CRE" 
 and titsit = "LIB" no-lock.
 
   

parcelaprincipal = 0.

  if (titulo.tpcontrato = "N" OR titulo.tpcontrato = "T"
  or titulo.tpcontrato = "L") then do:
     vlnov = vlnov + titvlcob.
     end.
     else do:


find first contrato where contrato.contnum = int(titulo.titnum)
 and contrato.etbcod = titulo.etbcod no-lock no-error.
 
  
 
 
   find first contnf where contnf.etbcod = contrato.etbcod and
                                  contnf.contnum = contrato.contnum
                                      no-lock no-error.

    

    

            find first plani where 
                  plani.etbcod = contrato.etbcod 
                                  and plani.placod = contnf.placod
                 and plani.dest = contrato.clicod
             
               and plani.movtdc = 5
                      
                      no-lock no-error.

                       
    
          if not avail plani then do:
                    parcelaprincipal = titvlcob.
                       end.
                       else do:
      parcelaprincipal = ((plani.platot * titulo.titvlcob) / contrato.vltotal).   
          end.     

                  
if parcelaprincipal = ? then do:
    parcelaprincipal = titulo.titvlcob.
    end.


     vlcre = vlcre + parcelaprincipal.

  end.
                                                         
    
 end.
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
                 
for each titulo use-index iclicod where titulo.clifor = clien.clicod
 and empcod = 19 and titnat = no and (titulo.modcod = "CP1" 
 or titulo.modcod = "CP0" or titulo.modcod = "CPN")
 and titsit = "LIB"
 no-lock.
   
   
      
     if titulo.modcod = "CPN" then do:
      vlcpn = vlcpn + titvlcob.
      end.                                                   
      else do:

find first contrato where contrato.contnum = int(titulo.titnum)
 and contrato.etbcod = titulo.etbcod no-lock no-error.
 
 
    find first contnf where contnf.etbcod = contrato.etbcod and
                 contnf.contnum = contrato.contnum
                          no-lock no-error.



            find first plani where  plani.etbcod = contrato.etbcod
                          and plani.placod = contnf.placod
                    and plani.dest = contrato.clicod
               and plani.movtdc = 5
                                     no-lock no-error.
                                     

       


                 if avail plani then do:
    parcelaprincipal = ((plani.platot * titulo.titvlcob) / contrato.vltotal).
                    end.
                    else do:
            parcelaprincipal = titulo.titvlcob.        
                    end.

                                        if parcelaprincipal = ? then do:
    parcelaprincipal = titulo.titvlcob.
    end.

                                        
                                        

      vlcp = vlcp + parcelaprincipal. 
      end.
      
   end.
                 
                
         
         valorlimitedisponivel = valorlimite - vlcre - vlnov - vlcp - vlcpn.
     


            valortotal = 0.
            valorcdc = 0.
            valorep = 0.
            valorinclu = 0.
            
                  for each plani  where
                       plani.pladat >= today - 365 and
                       plani.movtdc = 5 and
                       plani.Desti = clien.clicod
                        no-lock .

                        valorinclu = 0.


                        if (plani.biss > plani.platot) then do:
                        valorinclu = plani.biss.
                        end.
                        else do:
                        valorinclu = plani.platot.
                        end.


                        valortotal = valortotal + valorinclu.
                        
                        
                        if(plani.modcod = "CP1" or
                           plani.modcod = "CP0") then do:
                         valorep = valorep + valorinclu.     
                              end.
                              else do:
                         valorcdc = valorcdc + valorinclu.     
                              end.
                        
                        
                        


                       end.



                           pause 0.
                                                                        
                                                     
                                                                                   
       
     put clien.ciccgc format "x(20)" ";"
     tiporeceita format "x(2)" ";"
     jaep format "9" ";"
     jacdc format "9" ";"
     jaavista format "9" ";"
     temnovo format "9" ";"
     temantigo format "9" ";"
     temtituloatraso format "9"  ";"
     temnovocdc format "9" ";"
     temantigocdc format "9" ";"
     temtituloatrasocdc format "9" ";"
     temnovoavista format "9" ";"
     temantigoavista format "9" ";"
     temspc format "9" ";"
      clien.clicod format ">>>>>>>>>>>>>>>9" ";"
  totaldivida format "->>>>>>>>>9.99" ";"
  abertoep format "->>>>>>>>>>9.99" ";"
                maiordiadeatraso format ">>>>>>9" ";"
                totpar format ">>>>>>>9" ";"
                totaldividacdc format ">>>>>>>>>>9.99" ";"
                abertocdc format "->>>>>>>>>>9.99" ";"
               maiordiadeatrasocdc format ">>>>>>>9" ";"
                  totparcdc format ">>>>>>>9" ";"
                totaldividaglobal format ">>>>>>>>>>9.99" ";"
                abertototal format "->>>>>>>>>>9.99" ";"
                maiordiadeatrasoglobal format ">>>>>>>>9" ";" 
                 totparglobal format ">>>>>>>>9" ";"
                replace(clien.clinom, ";", " ") format "x(60)" ";"
              clien.dtcad format "99/99/9999"  ";"
          clien.datexp format "99/99/9999"  ";"
           clientesituacao format "x(1)" ";"
           vencimentolimite format "99/99/9999"  ";"
           qtdtitulos format ">>>>>>>9" ";"
           qtdcdc format ">>>>>>>9" ";"
           qtddias format ">>>>>>>9" ";"
           qtdatraso format ">>>>>>>9" ";"
           qtdmtoatraso format ">>>>>>>9" ";"
           qtdep format ">>>>>>>9" ";"
           qtddiasep format ">>>>>>>9" ";"
           qtdatrasoep format ">>>>>>>>9" ";"
           qtdatrasoepmto format ">>>>>>>>9" ";"
           clien.prorenda[1] format ">>>>>>>>9" ";"
           clien.sexo ";"
          replace(clien.proprof[1], ";", " ") format "x(100)" ";"
          replace(clien.cidade[1], ";", " ")  ";"
          replace(clien.bairro[1], ";", " ")  ";"  
           clien.dtnasc format "99/99/9999" ";"
           clien.ciinsc format "x(30)" ";"
  replace(clien.cep[1], ";", " ")  ";"
  replace(clien.endereco[1], ";", " ")  ";"
   replace(string(clien.numero[1]), ";", " ")  ";"
    replace(clien.compl[1], ";", " ")  ";"
           cestcivil format "x(10)" ";"
         replace(clien.conjuge, ";", " ") format "x(40)" ";"
           replace(clien.pai, ";", " ") format "x(40)" ";"
           replace(clien.mae, ";", " ") format "x(40)" ";"
           clien.natur  format "x(100)" ";"
           clien.numdep format ">>>>>>9" ";"
           clien.tipres ";"
           clien.temres format "999999" ";"
           clien.nacion format "x(30)" ";"  
         replace(clien.zona, ";", " ") format "x(70)" ";"
           clien.fax ";"
           clien.fone ";"
           clien.cobfone ";"
           clien.protel[1] ";"
           clien.protel[2] ";"
           clien.protel[2] ";"
           clien.refctel[1] ";"
           clien.refctel[2] ";"
           clien.refctel[3] ";" 
           valortotal format ">>>>>>>>>>9.99" ";"
           valorcdc   format ">>>>>>>>>>9.99" ";"
           valorep    format ">>>>>>>>>>9.99" ";" 
           clien.etbcad format ">>>>9" ";"     
                   valorlimite format "->>>>>>>>>>9.99" ";"
                   valorlimitedisponivel format "->>>>>>>>>>9.99" ";"
                   vlcre format "->>>>>>>>>>9.99" ";"
                   vlnov format "->>>>>>>>>>9.99" ";"
                     vlcp format "->>>>>>>>>>9.99" ";"                      
                      vlcpn format "->>>>>>>>>>9.99" ";"
                      pagogeral format ">>>>>>9" ";"
                      pagozerocinco format ">>>>>>9" ";"
                      pagoseisquinze format ">>>>>>9" ";"
                      pagomaisquinze format ">>>>>>9" ";"
                     clientenumerosorte format ">>>>>>>>>>>>>>9" ";"   ";"







                   
            skip.                                                                   
                    
                   
           
                    
                    
                                    
                      
 

end.
output close.

message totalcliente.
message varquivo2.
pause.

