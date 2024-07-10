def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9018 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 10.
    return.
end.
def var percentual-altp as dec.
def var perc-min-divergencia-aux as char.

assign perc-min-divergencia-aux = string(tbcntgen.valor,">>9").

assign perc-min-divergencia-aux = trim(perc-min-divergencia-aux).

vdg = "9018".
output to value(par-arquivo) append. 
for each divpre where divpre.etbcod < 900
                  and divpre.divdat >= par-dtini
                  and divpre.divdat <= par-dtfim
                  and divpre.divjus = "DESC. SUPERVISOR" no-lock,
                  
    first produ where produ.procod = divpre.procod no-lock,
        
    first plani where plani.etbcod = divpre.etbcod
                  and plani.placod = divpre.placod
                  and plani.serie  = "v" no-lock,
                                  
    first func where func.etbcod = plani.etbcod
                 and func.funcod = plani.vencod no-lock:    
    
    assign percentual-altp = 0.
    assign percentual-altp =
            (((divpre.preven - divpre.premat) / divpre.premat ) * 100) * -1.

      
    if percentual-altp < tbcntgen.valor
    then next.
  
    put unformatted
        divpre.divdat ";"
        vdg ";"
        divpre.etbcod   "|"
        produ.procod    "|"
        plani.numero    "|"
        plani.pladat    "|"
        divpre.premat   "|"
        divpre.preven   "|"
        divpre.premat - divpre.preven "|"
        func.funape "|"
        ""
        skip.
    find first repexporta where repexporta.TABELA       = "PLANI" 
                            and repexporta.Tabela-Recid = recid(plani)
                            and repexporta.BASE         = "GESTAO_EXCECAO"
                            and repexporta.EVENTO       = "9018"
                            no-lock no-error.
    if avail repexporta 
    then do on error undo.
                create repexporta.
                ASSIGN repexporta.TABELA       = "PLANI"
                       repexporta.DATATRIG     = divpre.divdat
                       repexporta.HORATRIG     = time
                       repexporta.EVENTO       = "9018"
                       repexporta.DATAEXP      = today
                       repexporta.HORAEXP      = time
                       repexporta.BASE         = "GESTAO_EXCECAO"
                       repexporta.Tabela-Recid = recid(plani).
    end.
end.            
                
output close.
                       

