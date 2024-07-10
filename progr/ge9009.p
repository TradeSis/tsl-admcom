def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9009 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vdados as log.
vdados = no.
vdg = "9009".

    for each lgaltcus where lgaltcus.datalt >= par-dtini and
                            lgaltcus.datalt <= par-dtfim and
                            lgaltcus.cusant > 0
                                no-lock :

        
find produ where produ.procod = lgaltcus.procod no-lock no-error.
        if not avail produ
        then next.
        
        output to value(par-arquivo) append.

       if lgaltcus.cusant = 0 then next.  

        put unformatted
            lgaltcus.datalt ";"
            vdg ";"
            lgaltcus.datalt     "|"
            produ.procod        "|"
            produ.pronom        "|"
            lgaltcus.cusant     "|"
            lgaltcus.cusalt skip.
        output close. 
        find first repexporta where repexporta.TABELA       = "LGALTCUS"
                                and repexporta.Tabela-Recid = recid(lgaltcus)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9009"
                                no-lock no-error.
        if not avail repexporta
        then do on error undo.
            create repexporta.
            ASSIGN repexporta.TABELA       = "lgaltcus"
                   repexporta.DATATRIG     = lgaltcus.datalt
                   repexporta.HORATRIG     = time
                   repexporta.EVENTO       = "9009"
                   repexporta.DATAEXP      = today
                   repexporta.HORAEXP      = time
                   repexporta.BASE         = "GESTAO_EXCECAO"
                   repexporta.Tabela-Recid = recid(lgaltcus).
        end.
    end. 
