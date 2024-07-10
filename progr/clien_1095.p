/*by Leote*/

{admcab.i}

def var varquivo as char.
def var conta as int.

message "CADASTROS NAO ALTERADOS A MAIS DE 1095 DIAS!" view-as alert-box.

message "Gerando relatorio...".
                                                         
/* Inicia o gerenciador de Impressao*/
     
if opsys = "UNIX"
 then
  varquivo = "/admcom/relat/clien_1095." + string(time).
 else
  varquivo = "l:\relat\clien_1095" + string(day(today)).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""clien_1095""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """CADASTROS A MAIS DE 1095 DIAS"""
        &Width     = "135"
        &Form      = "frame f-cabcab"
    }
 

for each clien where datexp >= today - 1095 no-lock by datexp desc.
                     conta = conta + 1.
disp clicod(count) clinom ciccgc datexp format "99/99/9999" with width 200.     
end.

output close.
   if opsys = "UNIX"
    then do:
     run visurel.p (input varquivo, input "CADASTROS A MAIS DE 1095 DIAS").
    end.
     else do:
      {mrod.i}
     end.
   
/* Finaliza o gerenciador de Impressao */      

