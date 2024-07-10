def stream str-csv.
def var vcont as integer.

def buffer bclien for clien.

def var sresp as logical.

output
stream str-csv to value("/admcom/lebesintel/carga_crm/cpf_dupl_lista.csv").


for each clien no-lock.

find first bclien where bclien.ciccgc = clien.ciccgc
                    and bclien.clicod <> clien.clicod  no-lock no-error.

if avail bclien
then do:
    
    put stream str-csv
    clien.ciccgc
    ";"
    bclien.ciccgc
    ";"
    clien.clicod
    ";"
    bclien.clicod
    ";"
    clien.clinom
    ";"
    bclien.clinom
    ";"    .

    
sresp = no.
    
    run cpf.p (input clien.ciccgc, output sresp) no-error.
    
    put stream str-csv
        sresp
                     ";" skip.
      
    
                             
end.                             

end.

  put stream str-csv
"Terminou com sucesso em " string(time,"HH:MM:SS")             skip.

output stream str-csv close.