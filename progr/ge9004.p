/* ge9004.p     */
def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.
                                                  
def var vlimite as dec.
def var assunto as char.
def var vpreco  as dec.
def var vvalor  as dec.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9004 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vvalor = tbcntgen.valor.

if vvalor = 0
then vvalor = 10.

for each estab where estab.etbcod <= 900 no-lock :
    
    if {/admcom/progr/conv_igual.i estab.etbcod} then next.
    
    for each movim where 
                        movim.movdat >= par-dtini 
                    and movim.movdat <= par-dtfim
                    and movim.etbcod = estab.etbcod
                    and movim.movtdc = 5 
                    no-lock
                    use-index movdat  : 
                    
        find first produ where produ.procod = movim.procod no-lock no-error.
        find first estoq where estoq.etbcod = movim.etbcod
                           and estoq.procod = movim.procod no-lock.
        
        vpreco = 0.
        if estoq.estprodat >= today and estoq.estproper > 0
        then do :
            if movim.movpc >= estoq.estproper
            then next.
            vpreco = estoq.estproper.
        end.
        else do :
            if movim.movpc >= estoq.estvenda 
                         then next.
            vpreco = estoq.estvenda.
        end.
        
        if (vpreco - movim.movpc) <= (vpreco * (vvalor / 100))
        then next.

        find first plani where plani.etbcod = movim.etbcod
                           and plani.placod = movim.placod
                           and plani.pladat = movim.movdat
                         use-index plani no-lock.
                         
        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func then next.
        
        def var vperc as dec decimals 2.    
        def var difer as dec.
        difer = vpreco - movim.movpc.
        vperc = difer / vpreco * 100.
        vdg = "9004".
        output to value(par-arquivo) append.

           put unformatted 
                plani.pladat    ";"
                vdg             ";"
                plani.pladat "|"
                produ.procod "|"
                produ.pronom "|"
                vpreco       "|"
                movim.movpc  "|"
                vperc        "|"
                plani.etbcod "|"
                "" skip.
        output close.
        do on error undo. 
            find first repexporta where 
                                    repexporta.TABELA       = "MOVIM"
                                and repexporta.Tabela-Recid = recid(MOVIM)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9004"
                                no-lock no-error.
            if not avail repexporta
            then do.
                create repexporta.
                ASSIGN repexporta.TABELA       = "MOVIM"
                       repexporta.DATATRIG     = plani.pladat
                       repexporta.HORATRIG     = time
                       repexporta.EVENTO       = "9004"
                       repexporta.DATAEXP      = today
                       repexporta.HORAEXP      = time
                       repexporta.BASE         = "GESTAO_EXCECAO"
                       repexporta.Tabela-Recid = recid(MOVIM).
            end.
        end.
    end.
end.
