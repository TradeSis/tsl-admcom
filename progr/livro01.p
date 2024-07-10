{admcab.i}
def var varquivo as char.
def var ii as int.

ii = 30000.

def temp-table tt-forne
    field forcod like forne.forcod
    field livcod like forne.livcod.
    
    
for each tt-forne.
    delete tt-forne.
end.

message "deseja exportar o cadastro de fornecedores" update sresp.
if not sresp
then return.



input from l:\work\forne.122.
repeat:
    create tt-forne.
    import tt-forne.
end.
input close.

for each tt-forne where tt-forne.forcod = 0:
    delete tt-forne.
end.


    
varquivo = string("m:\livros\emite1.exp").

output to value(varquivo).

for each tt-forne.

    find forne where forne.forcod = tt-forne.forcod no-lock no-error.

    put tt-forne.livcod   format "99999"
        forne.fornom   format "x(40)"
        forne.forrua   format "x(30)"
        forne.formunic format "x(30)"
        forne.forcep   format "x(08)"
        forne.ufecod   format "x(02)"
        forne.forcgc   format "x(18)"
        forne.forinest format "x(18)"
        "0000000"      format "x(07)"
        "0"
        "000000"
        "S"
        forne.forfone  format "x(15)"
        "00000000000"  format "x(11)" skip.   
end.     
output close.
 

        
       /*
output to l:\work\forne.122.

for each forne no-lock by forne.forcod.

    put forne.forcod " "
        ii format "99999" skip.

    ii = ii + 1.
end.
input close.
       */