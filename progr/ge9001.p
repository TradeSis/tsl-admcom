/* ge9001.p */
def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.

def var vdg as char.

def var vlimite_moveis  as dec.
def var vlimite_moda    as dec.
def var assunto as char.
def var vaspas as char format "x".

def var vMOVEIS as log.

vaspas = chr(34).
{/admcom/progr/cntgendf.i}

find first tbcntgen where tbcntgen.tipcon = 9001 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vlimite_moveis = tbcntgen.valor.

find first tbcntgen where tbcntgen.tipcon = 9002 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.
vlimite_moda = tbcntgen.valor.



if vlimite_moveis = 0
then vlimite_moveis = 5000.
if vlimite_moda = 0
then vlimite_moda = 1250.

def var vsaldo-lim as dec init 4000.

def var vtot as dec.
def var p-clicod as int.
def var vsaldo-cli as dec.
def buffer bplani for plani.

for each estab where estab.etbcod <= 900 no-lock:
    if {/admcom/progr/conv_igual.i estab.etbcod} then next.
    for each plani where plani.movtdc = 5
        and plani.pladat >= par-dtini 
        and plani.pladat <= par-dtfim
        and plani.etbcod = estab.etbcod
        no-lock:
        find first clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.

        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.

        vsaldo-cli = 0.
        if plani.crecod = 2
        then do:
        end.
        
        find first movim where movim.etbcod = plani.etbcod
                           and movim.placod = plani.placod
                               no-lock no-error.     
        if not avail movim then next.
        find produ of movim no-lock no-error.
        if not avail produ then next.
        if produ.catcod = 31 
        then vMOVEIS = yes.
        else vmoveis = no.
        
        if vMOVEIS
        then do.
            if plani.biss <> 0
            then do:
                if plani.biss < vlimite_moveis
                then next.
            end.
            else do:
                if plani.platot < vlimite_moveis
                then next.
            end.
        end.
        else do.
            if plani.biss <> 0
            then do:
                if plani.biss < vlimite_moda
                then next.
            end.
            else do:
                if plani.platot < vlimite_moda
                then next.
            end.
        end.
        
        
        if plani.desti = 1
        then next.

        vtot = 0.
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod no-lock:
            vtot = vtot + (movim.movpc * movim.movqtm).
        end.
        /*
        if plani.biss <> 0
        then do:
            if vtot <> plani.biss then next.
        end.
        else do:
            if vtot <> plani.platot then next.
        end.            
        
        if plani.nottran > 0 then next.
        */

        if vMOVEIS 
        then vdg = "9001".
        else vdg = "9002".
        
        output to value(par-arquivo) append.
        put unformatted 
                plani.pladat    ";"
                vdg             ";"
                plani.pladat    "|" .

        if plani.biss <> 0 
        then 
            put unformatted plani.biss "|". 
        else 
            put unformatted plani.platot "|".
        def var vtipopagamento as char.        
        if plani.crecod = 1
        then vtipopagamento = "A Vista".
        else vtipopagamento = "Crediario".   
        find first tabaux where tabaux.tabela = "PLANOBIZ" and
                                tabaux.valor_campo = string(plani.pedcod)
                                no-lock no-error.
        if avail tabaux
        then vtipopagamento = "Plano Bi$".
        put unformatted 
            vtipopagamento  "|"
            plani.etbcod "|" clien.clicod "|" clien.clinom  skip.
        
        output close.
        do on error undo.
            find first repexporta where 
                                    repexporta.TABELA       = "PLANI"
                                and repexporta.Tabela-Recid = recid(plani)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = (if vMOVEIS
                                                               then "9001"
                                                               else "9002")
                                no-error.
            if not avail repexporta
            then do.
                create repexporta.
                ASSIGN repexporta.TABELA       = "PLANI"
                       repexporta.DATATRIG     = plani.pladat
                       repexporta.HORATRIG     = time
                       repexporta.EVENTO       = if vMOVEIS
                                                 then "9001"
                                                 else "9002"
                       repexporta.DATAEXP      = today
                       repexporta.HORAEXP      = time
                       repexporta.BASE         = "GESTAO_EXCECAO"
                       repexporta.Tabela-Recid = recid(plani).
            end.
        end.
    end.       
end.
