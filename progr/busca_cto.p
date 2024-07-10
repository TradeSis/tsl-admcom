/*by Leote, Trojack e Antunes */

{admcab.i}
def var cliente like titulo.clifor.                                     
def var varquivo as char.
                                                                        
/* Formulario */                                                        
form cliente label "Cod. Cliente"                                       
with frame f01 title "Informe o codigo do cliente:" with 1 col width 80.
                                                                        
/* Atualiza variavel */                                                 
update cliente with frame f01.                             
             
/* Inicia o gerenciador de Impressao*/
     
if opsys = "UNIX"
 then
  varquivo = "/admcom/relat/busca_cto." + string(time).
 else
  varquivo = "l:\relat\busca_cto" + string(day(today)).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""busca_cto""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CONTRATO POR CLIENTE"""
        &Width     = "135"
        &Form      = "frame f-cabcab"
    }
 

    for each titulo where titulo.clifor = cliente and titulo.titpar <= 1 and (titulo.modcod = "VVI" or titulo.modcod = "CRE") no-lock by titdtemi
desc.                                                                     
disp titulo.etbcod titulo.clifor titulo.titnum titulo.titpar titulo.titdtemi titulo.modcod with width 80.   
    end.

output close.
   if opsys = "UNIX"
    then do:
     run visurel.p (input varquivo, input "CONTRATO POR CLIENTE").
    end.
     else do:
      {mrod.i}
     end.
   
/* Finaliza o gerenciador de Impressao */      

