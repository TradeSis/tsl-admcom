def var vlocked       as logical.
def var vtime-aux     as integer.
def var vdata-aux     as char.

def var varquivo      as char.

def buffer ba01_infnfe for a01_infnfe.

assign vlocked = no.

assign vdata-aux = string(today,"99/99/9999").

assign vdata-aux = replace(vdata-aux,"/","_").

assign varquivo = "/admcom/nfe/logs/ver-by-root__"
                    + vdata-aux
                    + ".log".

repeat:

    pause 0.5 no-message.

    output to value(varquivo) append.

    find last a01_infnfe where a01_infnfe.emite = 993
                           and a01_infnfe.serie = "1"
                                exclusive-lock no-wait no-error.
                           
    if locked a01_infnfe and vlocked = no
    then do:

        assign vtime-aux = time
               vlocked   = yes.    

        find last ba01_infnfe where ba01_infnfe.emite = 993
                                and ba01_infnfe.serie = "1"
                                    no-lock no-error.

        put unformatted
        string(today,"99/99/9999")
        "  -  By Root detectado em " string(time,"HH:MM:SS")
        " NF: " ba01_infnfe.numero.

    
    end.
    else if avail a01_infnfe and vlocked = yes
    then do:
    
        assign vlocked = no.
        
        put unformatted
        " Liberado em: " string(time,"HH:MM:SS")
        " Duracao: " string(time - vtime-aux,"HH:MM:SS") skip.

        assign vtime-aux = 0.    

        pause 0.
        
    end.        

    output close.

end.

