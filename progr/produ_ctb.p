/*by Leote*/

{admcab.i}

message "Gerando relatorio...".

def var varquivo as char.
             
/* Inicia o gerenciador de Impressao*/
     
if opsys = "UNIX"
 then
  varquivo = "/admcom/relat/produ_ctb." + string(time).
 else
  varquivo = "l:\relat\produ_ctb" + string(day(today)).

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "135"
        &Page-Line = "66"
        &Nom-Rel   = ""produ_ctb""
        &Nom-Sis   = """SISTEMA GERENCIAL"""
        &Tit-Rel   = """PRODUTOS"""
        &Width     = "135"
        &Form      = "frame f-cabcab"
    }
 
for each produ no-lock.                                                        
                                                                               
find clafis where clafis.codfis = produ.codfis no-lock no-error.

if not avail clafis then next.
                                                                               
disp produ.procod format ">>>>>>>>>>>>>>>>9" produ.pronom produ.codfis format ">>>>>>>>>>>>>>>>>9"
clafis.pericm clafis.pisent clafis.pissai clafis.cofinsent clafis.cofinssai    
clafis.perred clafis.persub clafis.sittri clafis.mva_estado1                   
clafis.mva_estado2 clafis.mva_estado3 clafis.mva_oestado1                      
clafis.mva_oestado2 clafis.mva_oesatdo3 with frame f down width 300.
down with frame f.                           
end.

output close.
if opsys = "UNIX"
then do:
run visurel.p (input varquivo, input "PRODUTOS").

end.

else do:
{mrod.i}

end.
   
/* Finaliza o gerenciador de Impressao */
