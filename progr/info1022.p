{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 1022 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para INFORMATIVO nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vlista      as character.

assign vlista = "31,41". 

def var vcat-aux    as integer.

def var vcont       as integer.

do vcont = 1 to num-entries(vlista):

    assign vcat-aux = integer(entry(vcont,vlista)).

    if vcont = 2
    then do:
        
       message "Executando a segunda parte do Informativo, por favor aguarde.".
        pause 0.

    end.
    
    run /admcom/progr/info1022-proc.p (input vcat-aux) .

end.


