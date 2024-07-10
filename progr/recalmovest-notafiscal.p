{admcab.i}

def var p-movtdc like plani.movtdc.
def var p-etbcod like plani.etbcod.
def var p-emite like plani.emite.
def var p-serie as char.
def var p-numero like plani.numero format ">>>>>>>>9".
def var p-relatorio as char format "!!!" init "NAO".
def var p-atualizar as char format "!!!" init "NAO".
def var p-confirmar as char format "!!!" init "NAO".
def var p-datinicio as date label "Data inicio processamento?".

update "Tipo de Movimento" at 1
       p-movtdc
       "     Filial da NF" at 1     
       p-etbcod
       "   Emitente da NF" at 1
       p-emite
       "      Serie da NF" at 1
       p-serie
       "     Numero da NF" at 1
       p-numero
       "   Gerar arquivo arquivo?" at 1
       p-relatorio
       " Atualizar base de dados?"  at 1
       p-atualizar
       "Confirmar para atualizar?"  at 1
       p-confirmar no-label
       with frame f-1 width 80 side-label no-label.
       
find plani where plani.movtdc = p-movtdc and
                 plani.etbcod = p-etbcod and
                 plani.emite = p-emite and
                 plani.serie = p-serie and 
                 plani.numero = p-numero
                 no-lock no-error.
if not avail plani 
then do:
    bell.
    message color red/with
    "Nenhum registro encontrato para NF."
    view-as alert-box.
    return.
end.                     
                 
sparam = "NOTAFISCAL=SIM" +
         "|MOVTDC=" + string(p-movtdc) +
         "|ETBCOD=" + string(p-etbcod) +
         "|EMITE=" + string(p-emite) +
         "|SERIE=" + string(p-serie) +
         "|NUMERO=" + string(p-numero) +
         "|RELATORIO=" + string(p-relatorio) +
         "|ATUALIZAR=" + string(p-atualizar) +
         "|CONFIRMAR=" + string(p-confirmar) +
         "|".
         
run removest20142.p.

sparam = "".

return.
