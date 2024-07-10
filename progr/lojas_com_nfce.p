/*por Lucas Leote*/

{admcab.i}

def var filialini as int init 1.
def var filialfim as int init 134.
def var varquivo as char.
def var vcxacodaux as int.                                                    
def var vetbcod as int.                                                    

vcxacodaux = 0.                                                               

/* Formulario */
form filialini label "Filial inicial"
     filialfim label "Filial final"

with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update filialini
       filialfim
with frame f01.                                                          

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/lojas_com_nfce." + string(time).
 else
 varquivo = "l:\relat\lojas_com_nfce" + string(day(today)).

 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""lojas_com_nfce""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """LOJAS COM NFCE"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 } 

for each estab where estab.etbcod >= filialini and estab.etbcod <= filialfim no-lock.
    do vcxacodaux = 1 to 25: 
	put skip.
	find last com.plani where plani.etbcod = estab.etbcod and              
                                         serie = "3" and                  
                                        movtdc = 5 and                    
                                        cxacod = vcxacodaux no-lock no-error.
        pause 0.    
        if not avail plani then next.
        disp plani.etbcod plani.cxacod.                                           
    end.
end.    

output close.

   if opsys = "UNIX"
        then do:
                run visurel.p (input varquivo, input "VENDAS NFCE").
        end.
        else do:
                {mrod.i}
        end.
/* Finaliza o gerenciador de Impressao */

message "RELATORIO GERADO!" view-as alert-box.