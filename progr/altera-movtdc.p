{admcab.i new}

def var vetbcod as integer.
def var vnumero as integer.
def var vmovtdc as integer.

update vetbcod vnumero.

for each plani where plani.etbcod = vetbcod
                 and plani.numero = vnumero
                 and plani.serie = "1"
                 and plani.pladat >= 06/01/2012
                 and plani.pladat <= 06/30/2012
                   no-lock,

    each movim where movim.etbcod = plani.etbcod
                 and movim.placod = plani.placod
                 and movim.movtdc = 0
                 and movim.movdat = plani.pladat
                    exclusive-lock.
                    
    assign movim.movtdc = plani.movtdc.
    assign vmovtdc = movim.movtdc.                    
                   
end.                   

message "Alterado para " vmovtdc view-as alert-box.
