if "{1}" = "titulo" or
   "{1}" = "contrato" or
   "{1}" = "cliente" 
then do:
    find first ttcontrole where ttcontrole.nome = "{1}" no-error.
    if not avail ttcontrole
    then do :
        create ttcontrole.
        ttcontrole.nome = "{1}".
    end.
    ttcontrole.qtd = ttcontrole.qtd + 1.
end.    
