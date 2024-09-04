DEF INPUT  PARAM    lcJsonEntrada AS LONGCHAR.
DEF OUTPUT PARAM    varquivo2          AS CHAR.

{tsr/tsrelat.i}

{admcab-batch.i}
DEF VAR hentrada AS HANDLE.

def temp-table ttparametros no-undo serialize-name "parametros"
    field dataInicial   as char
    field dataFinal     as char.
                        
hEntrada = temp-table ttparametros:HANDLE.

hentrada:READ-JSON("longchar",lcjsonentrada, "EMPTY").
                        
find first ttparametros no-error.
if NOT AVAIL ttparametros THEN RETURN.    

def var dividaanterior as dec.
def var dividanova as dec.
def var dividanovapaga as dec.
 
def var valorreceber as dec.
def var valorpago as dec.
def var valorjuros as dec.
def var valoraberto as dec.
def var valornovado as dec.

def var qtdanterior as int.
def var qtdaberto as int.
def var qtdreceber as int.
def var qtdpago as int.
def var qtdnovado as int. 
def var datamaisatraso as date.
def var qtdmaisatraso as int.
def var ultimotitulo like titulo.titnum.
def var atrasooriginal as int.


def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
 
def buffer xcontrato for contrato. 
 
    /* parametrois vem do ttparametros */
    if ttparametros.dataFinal BEGINS "#" then do:
        vdtfim = calculadata(ttparametros.dataFinal,TODAY).
    end.
    ELSE DO:
        vdtfim =convertedata(ttparametros.dataFinal).
    END.
    if ttparametros.dataInicial BEGINS "#" then do:
        vdtini = calculadata(ttparametros.dataInicial,TODAY).
    end.
    ELSE DO:
        vdtini  = convertedata(ttparametros.dataInicial).
    END.

varquivo2 = "/admcom/import/cdlpoa/acordos_contratos-"
    + string(month(vdtini))
    + string(year(vdtini))
    + string(month(vdtfim))
    + string(year(vdtfim))
    +  "-" + string(time) + ".csv".

output to value(varquivo2).


def var tinhanovacao as char. 

put "cpf;nome;codigocliente;contratonovo;modalidade;dataacordo;estabacordo;
valordivida;qtdparcelasdividaanterior;dtmaisatrasada;qtddiasmaisatraso;vlnovocontrato;qtdparcelasnovo;vlaberto;qtdaberto;vlpagoprincipal;vlpagototal;qtdpagos;valornovado;qtdnovado;contatooriginal;parcelaoriginal;vencimentooriginal;valororiginal;diasatraso;idacordo;juroscontrato;tinhanovacao;Entrada;TxJuros;".

put "v1;p1;vl1;v2;p2;vl2;v3;p3;vl3;v4;p4;vl4;v5;p5;vl5;v6;p6;vl6;v7;p7;vl7;v8;p8;vl8;v9;p9;vl9;v10;p10;vl10;".

put "v11;p11;vl11;v12;p12;vl12;v13;p13;vl13;v14;p14;vl14;v15;p15;vl15;".
put "v16;p16;vl16;v17;p17;vl17;v18;p18;vl18;v19;p19;vl19;v20;p20;vl20;". 
 
  
put  skip.

def var juroscontrato as dec.
juroscontrato = 0.



for each contrato where dtinicial >= vdtini and
                        dtinicial <= vdtfim     
  no-lock.


         juroscontrato = 0.

find first clien where clien.clicod = contrato.clicod no-lock no-error. 

dividaanterior = 0.
dividanova = 0.
dividanovapaga = 0.
qtdanterior = 0.
valorreceber = 0.
qtdreceber = 0.
valorpago = 0.
qtdpago = 0.
valoraberto = 0.
qtdaberto = 0.
valornovado = 0.
qtdnovado = 0.
valorjuros = 0.
datamaisatraso = today.
qtdmaisatraso = 0.
ultimotitulo = ?.

if (contrato.modcod = "CRE") or
   (contrato.modcod = "CPN") THEN DO:
   end.
   else do:
   next.
   end.
   

if contrato.modcod = "CRE" and contrato.tpcontrato <> "N" then do:

   find first titulo where titulo.empcod = 19 and
                      titulo.titnat = no and
                      titulo.modcod = contrato.modcod and
                      titulo.etbcod = contrato.etbcod and
                      titulo.clifor = contrato.clicod  and
                      titulo.titnum = string(contrato.contnum)                                   no-lock no-error.
                           
             if not avail titulo then next.
             
             if titulo.tpcontrato = "N" then do:
             
             end.
             else do:
                 next.
             end.




end.





                 
                juroscontrato = contrato.vlf_acrescimo. 

                                
                            pause 0.
                            



  for each tit_novacao where
  tit_novacao.Ger_contnum = int(contrato.contnum) and
      ori_CliFor = contrato.clicod
      no-lock.

                  ultimotitulo = tit_novacao.ori_titnum. 

                  if (tit_novacao.ori_titdtven < datamaisatraso) then do:
                    datamaisatraso = tit_novacao.ori_titdtven.
                    qtdmaisatraso = tit_novacao.DtNovacao - datamaisatraso.
                  end.

                   qtdanterior = qtdanterior + 1.
                   dividaanterior = dividaanterior + ori_titvlcob.
                
            

    end.


 for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum)                           
                           no-lock.
                           pause 0.

              
            valorreceber = valorreceber + titulo.titvlcob.
            qtdreceber = qtdreceber + 1. 

            if titulo.titsit = "PAG" then do:
                  valorjuros = valorjuros + titvlpag.
                  valorpago = valorpago + titvlcob.
                  qtdpago = qtdpago + 1. 
            end.
            
            if titulo.titsit = "LIB" then do:
                  valoraberto = valoraberto + titvlcob.
                  qtdaberto = qtdaberto + 1.
            end.
            
            if titulo.titsit = "NOV" then do:
                  valornovado = valornovado + titvlpag.
                  qtdnovado = qtdnovado + 1.
            end.





                        end.








                                            pause 0.


                                                                                        for each tit_novacao where
  tit_novacao.Ger_contnum = int(contrato.contnum) and
      ori_CliFor = contrato.clicod
      no-lock.
          
          atrasooriginal = 0.
          
          atrasooriginal = tit_novacao.DtNovacao - tit_novacao.ori_titdtven.
          






          put
clien.ciccgc  format "x(17)" ";"
clien.clinom format "x(40)" ";"
clien.clicod format ">>>>>>>>>>>>9" ";" 
contrato.contnum format "->>>>>>>>>>>>9" ";"
contrato.modcod ";"
contrato.dtinicial format "99/99/9999" ";"
contrato.etbcod ";".

pause 0.




    find first xcontrato where 
                   xcontrato.contnum = int(tit_novacao.ori_titnum) and
                   xcontrato.clicod = tit_novacao.ori_Clifor and
                   xcontrato.etbcod = tit_novacao.ori_etbcod and
                   xcontrato.modcod = tit_novacao.ori_modcod no-lock no-error.
                   
                   
             if avail xcontrato then do:

                if xcontrato.modcod = "CPN" or
                   xcontrato.tpcontrato = "N" then do:
                tinhanovacao = "N".   
                    end.
                    else do:
                tinhanovacao = "".    
                    end.
                                            
                 
                 end.
                 else do:
                 tinhanovacao = "".
                 end.




          
               put dividaanterior format "->>>>>>>>>9.99" ";"
                  
                    qtdanterior format "->>>>9" ";"
                    datamaisatraso format "99/99/9999" ";"
                    qtdmaisatraso format "->>>>9" ";"
                    valorreceber format "->>>>>>>>>9.99" ";"
                    qtdreceber format "->>>>9" ";"
                     valoraberto  format "->>>>>>>>>9.99" ";"
                     qtdaberto format "->>>>>9" ";"
                     valorjuros format "->>>>>>>>>9.99" ";"
                      valorpago format "->>>>>>>>>9.99" ";"
                      qtdpago format "->>>>>9" ";"
                       valornovado format "->>>>>>>>>9.99" ";"
                       qtdnovado format "->>>>>9" ";" 
                                           tit_novacao.ori_titnum  format "x(16)" ";"
                                           tit_novacao.ori_titpar format "->>>>>9" ";" 
                                           tit_novacao.ori_titdtven format "99/99/9999" ";"
                                           tit_novacao.ori_titvlcob format "->>>>>>>>>9.99" ";"
                                           atrasooriginal format "->>>>>9" ";" 
                                           Id_Acordo ";" 
                                        juroscontrato ";"
                                           tinhanovacao ";"
                                        contrato.vlentra format "->>>>>>>>.99" ";"
   contrato.TxJuros format ">>>>>>>>.9999"  ";".

    for each titulo where titulo.empcod = 19 and
              titulo.titnat = no and
              titulo.modcod = contrato.modcod and
              titulo.etbcod = contrato.etbcod and
              titulo.clifor = contrato.clicod  and
             titulo.titnum = string(contrato.contnum)      

                           no-lock.
                                                      pause 0.
                                                      
            put titulo.titdtven format "99/99/9999" ";".
            
                if titulo.titdtpag <> ? then do:
                       

                       put titulo.titdtpag format "99/99/9999"  ";".     
                       put titulo.titvlpag format ">>>>>>>>>>>>.99" ";".
                               
                               end.
                               else do:
                            put ";;".  
                               end.


   
        end.
   
   
   
   
   
   
   
   
   
   
   
               put         skip  .
                                                
                                                
                                                end.

end.

output close.
