def var vdir as char init "l:\joao\".
def var varquivo as char.
def var vcliente as char.


vcliente = "00624882012".
varquivo = vdir + "cliente.txt".

find first clien where clien.ciccgc = vcliente no-lock.
    
    output to value(varquivo).
                                      
        put    clien.clicod ";"
               clien.clinom ";"
               clien.clicod ";"
               clien.sexo ";"
               clien.tippes ";"
               clien.dtnasc format "99/99/9999" ";"
               clien.estciv ";"
               clien.pai ";"
               clien.mae ";"
               clien.ciinsc skip.
    
    output close.



message varquivo.


