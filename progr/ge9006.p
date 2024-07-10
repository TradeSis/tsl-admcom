def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9006 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vtotal as dec.
def var d as date.
def var vi as date.
def var vf as date.

def temp-table t
    field pedtdc as int
    index t is primary unique pedtdc.
           
def var v as int. 
do v = 1 to 200.
    create t.
    assign t.pedtdc = v.
end.
def var vdata as date.
def var sresponsavel as char.

for each forne where forne.fordtcad > today - (30 * 6) no-lock.
    find first repexporta where repexporta.TABELA       = "FORNE" 
                            and repexporta.Tabela-Recid = recid(forne)
                            and repexporta.BASE         = "GESTAO_EXCECAO"
                            and repexporta.EVENTO       = "9006"
                                no-lock no-error.
    if avail repexporta  
    then next. 
    vdata = ?. 
    for each t,
            each estab where etbcod > 900 no-lock, 
            first pedid where pedid.pedtdc = t.pedtdc and
                                       pedid.etbcod = estab.etbcod and
                                       pedid.clfcod = forne.forcod 
                                       no-lock by pedid.peddat.
            vdata = pedid.peddat.
            sresponsavel = string(pedid.comcod).
            leave.
    end.   
    if vdata = ? then next. 
    def var vcont as int. 
    vcont = 0. 
    for each produ where produ.fabcod = forne.forcod no-lock. 
        vcont = vcont + 1. 
        leave.
    end. 
    if vcont = 0 then next. 
    find first forneaux where 
               forneaux.forcod     = forne.forcod and 
               forneaux.Nome_Campo = "RESPONSAVEL" no-lock NO-ERROR.
    if not avail forneaux
    then do on error undo.
        create forneaux.
        forneaux.forcod      = forne.forcod.
        forneaux.Nome_Campo  = "RESPONSAVEL".
        forneaux.valor_Campo = sresponsavel.
    end.
    find first repexporta where repexporta.TABELA       = "FORNE" 
                            and repexporta.Tabela-Recid = recid(forne)
                            and repexporta.BASE         = "GESTAO_EXCECAO"
                            and repexporta.EVENTO       = "9006"
                                no-lock no-error.
    if not avail repexporta  
    then do on error undo. 
        create repexporta. 
        ASSIGN repexporta.TABELA       = "FORNE" 
               repexporta.DATATRIG     = vdata 
               repexporta.HORATRIG     = time 
               repexporta.EVENTO       = "9006" 
               repexporta.DATAEXP      = ?  
               repexporta.HORAEXP      = ? 
               repexporta.BASE         = "GESTAO_EXCECAO"
               repexporta.Tabela-Recid = recid(forne).
    end.
end.
def var vprodutos as char.



do:
    for each repexporta where 
                repexporta.TABELA       = "FORNE"           and
                repexporta.EVENTO       = "9006"            and
                repexporta.BASE         = "GESTAO_EXCECAO"  and
                repexporta.DATATRIG    >= par-dtini         and
                repexporta.DATATRIG    <= par-dtfim
                 .
        find forne where recid(forne) = repexporta.tabela-recid 
                                                            no-lock no-error.
                                        
        if not avail forne 
        then next.
        vdg = "9006".
        vprodutos = "".        
        for each produ where produ.fabcod = forne.forcod no-lock. 
            if vprodutos <> ""
            then vprodutos = vprodutos + "-" + 
                             produ.pronom + " " + string(produ.procod).
            else vprodutos = produ.pronom + " " + string(produ.procod).
        end.    
        find first forneaux where 
               forneaux.forcod     = forne.forcod and 
               forneaux.Nome_Campo = "RESPONSAVEL" no-lock NO-ERROR.

        output to value(par-arquivo) append.
        put unformatted
            forne.fordtcad ";"
            vdg ";"
            forne.forcod    "|" 
            forne.fornom    "|" 
           (if avail forneaux
            then forneaux.valor_Campo
            else  "")  skip. 
        output close.
        repexporta.DATAEXP      = today.   
        repexporta.HORAEXP      = time.        
    end.
end.
