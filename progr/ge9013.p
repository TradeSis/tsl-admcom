def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9013 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 10.
    return.
end.

def var venvmail as log init no.

vdg = "9013".
output to value(par-arquivo) append. 
def var vcont as int.
def var vprodutos as char format "x(50)".

for each pedid where pedid.pedtdc = 3           and 
                     pedid.peddat >= par-dtini  and
                     pedid.peddat <= par-dtfim  and
                     pedid.pedsit  = yes        and
                     pedid.modcod  = "PEDM"     no-lock.
     
    vcont = 0.
    vprodutos = "".
    for each liped of pedid no-lock.
        vcont = vcont + 1.
        find produ of liped no-lock.
        if vprodutos <> "" 
        then vprodutos = vprodutos + "-" +
                            string(liped.procod) . 
        else vprodutos = string(liped.procod) .
    end.
    if vcont < 20
    then next.
    put unformatted
        pedid.peddat ";"
        vdg ";"
        pedid.etbcod    "|"
        pedid.pednum    "|"
        vprodutos
        skip.
    find first repexporta where repexporta.TABELA       = "PEDID"
                            and repexporta.Tabela-Recid = recid(pedid)
                            and repexporta.BASE         = "GESTAO_EXCECAO"
                            and repexporta.EVENTO       = "9013"
                            no-lock no-error.
    if avail repexporta
    then do on error undo.
            create repexporta.
            ASSIGN repexporta.TABELA       = "PEDID"
                   repexporta.DATATRIG     = pedid.peddat
                   repexporta.HORATRIG     = time
                   repexporta.EVENTO       = "9013"
                   repexporta.DATAEXP      = today
                   repexporta.HORAEXP      = time
                   repexporta.BASE         = "GESTAO_EXCECAO"
                   repexporta.Tabela-Recid = recid(pedid).
    end.    
end.            
output close. 

