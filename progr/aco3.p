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

def var varquivo2 as character.

def var vdtini as date format "99/99/9999" initial today.
def var vdtfim as date format "99/99/9999" initial today.
 
 
 
  update vdtini colon 15 label "Contratos emitidos de"
                 vdtfim label "ate".
                 
 
varquivo2 = "/admcom/import/cdlpoa/acordos_contratos-"
 + string(month(vdtini))
 + string(year(vdtini))
 + string(month(vdtfim))
 + string(year(vdtfim))
 +  "-" + string(time) + ".csv".
 
 display "Gerando acordos...". 
  
output to value(varquivo2).

put "cpf;nome;codigocliente;contratonovo;modalidade;dataacordo;estabacordo;
valordivida;qtdparcelasdividaanterior;dtmaisatrasada;qtddiasmaisatraso;vlnovocontrato;qtdparcelasnovo;vlaberto;qtdaberto;vlpagoprincipal;vlpagototal;qtdpagos;valornovado;qtdnovado;contatooriginal;parcelaoriginal;vencimentooriginal;valororiginal;diasatraso;idacordo;" skip.


for each contrato where dtinicial >= vdtini and
                        dtinicial <= vdtfim     
  no-lock.

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

if (contrato.modcod = "CRE" AND contrato.tpcontrato = "N") or
   (contrato.modcod = "CPN") THEN DO:
   end.
   else do:
   next.
   end.
   
                              /*
   find first tit_novacao use-index ger_contnum where int(tit_novacao.Ger_contnum) = contrato.contnum and
  EtbNovacao = contrato.etbcod and
  ori_CliFor = contrato.clicod
no-lock no-error.
                                */
                                
                            pause 0.
                            



  for each tit_novacao where
  tit_novacao.Ger_contnum = int(contrato.contnum) and
    EtbNovacao = contrato.etbcod and
      ori_CliFor = contrato.clicod
      no-lock.

                  ultimotitulo = tit_novacao.ori_titnum. 

                  if (tit_novacao.ori_titdtven < datamaisatraso) then do:
                    datamaisatraso = tit_novacao.ori_titdtven.
                    qtdmaisatraso = tit_novacao.DtNovacao - datamaisatraso.
                  end.

                   qtdanterior = qtdanterior + 1.
                   dividaanterior = dividaanterior + ori_titvlcob.
                
                /*
                     disp Id_Acordo ori_titnum ori_titpar ori_titvlcob.
                */

    end.


 for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = contrato.modcod and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod  and
                          titulo.titnum = string(contrato.contnum)                           
                           no-lock.
                           pause 0.

            /*
              disp titulo.titnum
                    titulo.titpar
                      titulo.titdtven
                      titulo.titvlcob
                        titulo.titsit.
              */
              
              
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
    EtbNovacao = contrato.etbcod and
      ori_CliFor = contrato.clicod
      no-lock.
          
          atrasooriginal = 0.
          
          atrasooriginal = tit_novacao.DtNovacao - tit_novacao.ori_titdtven.
          
          put
clien.ciccgc  format "x(17)" ";"
clien.clinom format "x(40)" ";"
clien.clicod format ">>>>>>>>>>>>9" ";" 
contrato.contnum format ">>>>>>>>>>>>9" ";"
contrato.modcod ";"
contrato.dtinicial format "99/99/9999" ";"
contrato.etbcod ";".
          
               put dividaanterior format "->>>>>>>>>9.99" ";"
                  
                    qtdanterior format ">>>>9" ";"
                    datamaisatraso format "99/99/9999" ";"
                    qtdmaisatraso format ">>>>9" ";"
                    valorreceber format "->>>>>>>>>9.99" ";"
                    qtdreceber format ">>>>9" ";"
                     valoraberto  format "->>>>>>>>>9.99" ";"
                     qtdaberto format ">>>>>9" ";"
                     valorjuros format "->>>>>>>>>9.99" ";"
                      valorpago format "->>>>>>>>>9.99" ";"
                      qtdpago format ">>>>>9" ";"
                       valornovado format "->>>>>>>>>9.99" ";"
                       qtdnovado format ">>>>>9" ";" 
                                           tit_novacao.ori_titnum  format "x(16)" ";"
                                           tit_novacao.ori_titpar format ">>>>>9" ";" 
                                           tit_novacao.ori_titdtven format "99/99/9999" ";"
                                           tit_novacao.ori_titvlcob format "->>>>>>>>>9.99" ";"
                                           atrasooriginal format "->>>>>9" ";" 
                                           Id_Acordo ";" 
                                           
                                           
                        skip  .
                                                
                                                
                                                end.

end.

output close.
message varquivo2.
pause.