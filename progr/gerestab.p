{admcab.i}
def var vetbcod like estab.etbcod.
def temp-table tt-forne
    field forcod like forne.forcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

message "Deseja Gerar estabelecimentos para Winlivros" update sresp.
if not sresp  
then return.


    output to m:\livros\estab.exp.

 
    for each estab no-lock.
    
        put estab.etbcod      format "99999"
            estab.etbnom      format "x(40)"
            estab.endereco    format "x(30)"
            estab.munic       format "x(30)"
            "90000000"        format "x(08)"
            estab.ufecod      format "x(02)"
            estab.etbcgc      format "x(18)"
            estab.etbinsc     format "x(18)"
            "00000000"  
            "       "   
            "                          " skip.
     end.
     output close.
     
    message "**** m:\livros\estab.exp. ****    Gerado. "  
            
