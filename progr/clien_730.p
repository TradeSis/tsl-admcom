/*by Leote*/

{admcab.i}

def var varquivo as char.
def var conta as int.

message "CADASTROS NAO ALTERADOS ENTRE 730 E 1095 DIAS!" view-as alert-box.

message "Gerando relatorio...".
                                                         
/* Inicia o gerenciador de Impressao*/
     
if opsys = "UNIX"
 then
  varquivo = "/admcom/relat/clien_730." + string(time).
 else
  varquivo = "l:\relat\clien_730" + string(day(today)).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""clien_365""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CADASTROS DE 730 a 1095"""
        &Width     = "135"
        &Form      = "frame f-cabcab"
    }
 

for each clien where datexp <= today - 730 and                        
                     datexp >= today - 1095 no-lock by datexp desc.
                     conta = conta + 1.
disp clicod(count) clinom ciccgc datexp format "99/99/9999" with width 200.     
end.

output close.
   if opsys = "UNIX"
    then do:
     run visurel.p (input varquivo, input "CADASTROS DE 730 a 1095").
    end.
     else do:
      {mrod.i}
     end.
   
/* Finaliza o gerenciador de Impressao */      

