/*por Lucas Leote*/

{admcab.i}

def var dataini as date init today.
def var datafim as date init today.
def var varquivo as char.

/* Formulario */
form dataini label "Data inicial"
     datafim label "Data final"
                                        
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

/* Atualiza variaveis */
update dataini
       datafim 
with frame f01.

message "Gerando relatorio...".

/* Inicia o gerenciador de Impressao*/
if opsys = "UNIX"
 then
 varquivo = "/admcom/relat/notas_sc." + string(time).
 else
 varquivo = "l:\relat\notas_sc" + string(day(today)).
      
 {mdad.i
  &Saida     = "value(varquivo)"
  &Page-Size = "64"
  &Cond-Var  = "135"
  &Page-Line = "66"
  &Nom-Rel   = ""notas_sc""
  &Nom-Sis   = """SISTEMA GERENCIAL"""
  &Tit-Rel   = """NOTAS SC"""
  &Width     = "135"
  &Form      = "frame f-cabcab"
 }

for each tab_ini where tab_ini.parametro = "LOJA-COM-ECF" and
                       tab_ini.valor     = "SIM" and
                       tab_ini.etbcod    <> 0
                       no-lock,
    each plani where desti = tab_ini.etbcod
               and pladat >= dataini
               and pladat <= datafim
               and serie = "1"
               no-lock by pladat desc. 

find a01_infnfe where a01_infnfe.numero = plani.numero and a01_infnfe.etbcod = plani.etbcod no-lock.
                           
disp plani.etbcod(count) column-label "Emitente"     
     plani.desti column-label "Destinatario"  
     plani.numero column-label "Nro NF"       
     plani.serie column-label "Serie NF"      
     plani.pladat column-label "Data emissao" 
     plani.platot(total) column-label "Total NF"     
     plani.icms(total) column-label "ICMS"           
     plani.icmssubst(total) column-label "ICMS Subst"
         a01_infnfe.id column-label "Chave"
with width 200.   

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
