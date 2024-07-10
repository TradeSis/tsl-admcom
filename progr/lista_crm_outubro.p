def stream str-csv.
def var vcont as integer.

def var sresp as logical.

output stream str-csv to value("/admcom/lebesintel/carga_crm/plani_lista.csv").



for each estab no-lock,
    each plani where plani.etbcod = estab.etbcod
                 and pladat >= 01/01/2011
                 and movtdc = 5 no-lock.



    put stream str-csv unformatted
    plani.etbcod
    ";"
    plani.movtdc
    ";"
    plani.numero
    ";"
    plani.placod
    ";"
    plani.pladat
    ";"
    plani.desti
    ";"
    plani.pedcod
    ";"
    .

    vcont = 0.
    for each movim where
             movim.etbcod = plani.etbcod and
             movim.placod = plani.placod and
             movim.movdat = plani.pladat and
             movim.movtdc = plani.movtdc no-lock.
             
        assign vcont = vcont + 1.             
             
             
    end.
    
        put stream str-csv unformatted
        vcont
        ";".


    find first clien where clien.clicod = plani.desti no-lock no-error.
    if avail clien
    then do:
    
    put stream str-csv unformatted
    clien.ciccgc
    ";"
    clien.clinom
    ";"
    clien.zona
    ";"
    clien.fax
    ";"
    clien.endereco[1]
    ";"
    clien.numero[1]
    ";"
    clien.compl[1]
    ";"
    clien.bairro[1]
    ";"
    clien.cidade[1]
    ";"          
    clien.ufecod[1]
    ";"
    clien.cep[1]
    ";".

sresp = no.
    
    run cpf.p (input clien.ciccgc, output sresp) no-error.
    
    put stream str-csv
        sresp
                     ";".
    
    end.
    
    else
         put stream str-csv
         ";;;;;;;;;;;;".
        
             put stream str-csv
                             skip.

end.


  put stream str-csv
"Terminou com sucesso em " string(time,"HH:MM:SS")             skip.

output stream str-csv close.