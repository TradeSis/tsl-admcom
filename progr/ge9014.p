def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9014 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

vdg = "9014".
output to value(par-arquivo) append.  
def var vprodutos as char.
def var quantidadedias as int.
for each estab 900 no-lock.
    for each plani where plani.movtdc = 4
                     and plani.etbcod = estab.etbcod
                     and plani.notsit = yes no-lock.
        if today - plani.dtincl < 3
        then next.
        vprodutos = "".
        quantidadedias = today - plani.dtincl.
        /*
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod no-lock.
            if vprodutos <> ""
            then vprodutos = vprodutos + "-" + string(movim.procod).
            else vprodutos = string(movim.procod).
        end.
        */
       find first forne where forne.forcod = plani.emite no-lock no-error.
        
        put unformatted
            par-dtini ";"
            vdg ";"
            plani.emite     "|"
            plani.numero    "|"
            plani.pladat    "|"
            plani.platot "|"
            forne.forfant "|"
            plani.dtincl "|"
            quantidadedias
            skip.
    end.
end.
output close. 
