{admcab.i }
def var varquivo as char.
def var ii as int.

ii = 36000.

def temp-table tt-forne
    field forcod like forne.forcod
    field livcod like forne.livcod.
    
    
for each tt-forne.
    delete tt-forne.
end.

message "deseja exportar o cadastro de fornecedores" update sresp.
if not sresp
then return.



    
varquivo = string("l:\work\filial.exp").

output to value(varquivo).

for each estab no-lock.


    put ii   format "99999"
        estab.etbnom   format "x(40)"
        estab.endereco format "x(30)"
        estab.munic format "x(30)"
        "96700000"     format "x(08)"
        estab.ufecod   format "x(02)"
        estab.etbcgc   format "x(18)"
        estab.etbinsc  format "x(18)"
        "0000000"      format "x(07)"
        "0"
        "000000"
        "S"
        "               " format "x(15)"
        "00000000000"  format "x(11)" skip.   
    ii = ii + 1.
    
end.     
output close.
 

ii = 36000.        
output to l:\work\estab.122.

for each estab no-lock by estab.etbcod.

    put estab.etbcod " "
        ii format "99999" skip.

    ii = ii + 1.
end.
input close.
