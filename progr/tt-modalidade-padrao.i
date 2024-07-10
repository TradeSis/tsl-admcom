def {1} shared temp-table tt-modalidade-padrao
    field modcod as char
    index pk modcod.
 
create tt-modalidade-padrao.
assign tt-modalidade-padrao.modcod = "CRE".

for each profin no-lock.
    create tt-modalidade-padrao.
    assign tt-modalidade-padrao.modcod = profin.modcod.        
end.
