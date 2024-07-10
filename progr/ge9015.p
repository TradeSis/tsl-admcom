def input parameter par-arquivo as char.
def input parameter par-dtini   as date.
def input parameter par-dtfim   as date.
def var vdg as char.

def var vlimite as dec.
def var assunto as char.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.tipcon = 9015 no-lock no-error.
if not avail tbcntgen  or 
    (tbcntgen.validade <> ? and
     tbcntgen.validade < today)
then do:
    message "Controle para DG nao cadastrado ou desativado".
    pause 0.
    return.
end.

def var vsaldo-lim as dec.

vsaldo-lim = tbcntgen.valor.

if vsaldo-lim  = 0
then vlimite = 4000.

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
        and plani.serie = "V" no-lock
        :
        if plani.desti = 1
        then next.
        
        find first clien where clien.clicod = plani.desti no-lock no-error.
        if not avail clien
        then next.

        find first func where func.funcod = plani.vencod no-lock no-error.
        if not avail func
        then next.

        vsaldo-cli = 0.
        if plani.crecod = 2
        then do:
            run dg027.
        end.
    end.       
end.

procedure dg027:
    def var valvenda as dec.
    vsaldo-cli = 0.
    for each titulo where titulo.clifor = plani.desti no-lock:
        if titulo.titsit = "LIB"  and
           titulo.modcod = "CRE" 
        then vsaldo-cli = vsaldo-cli + titulo.titvlcob.
    end.
    if vsaldo-cli > vsaldo-lim
    then do:
        if plani.biss <> 0
        then valvenda =  plani.biss.
        else valvenda = plani.platot.

        vdg = "9015".
        
        output to value(par-arquivo) append.
        put unformatted
            plani.pladat ";"
            vdg ";"
            plani.pladat        "|"
            plani.etbcod        "|"
            clien.clinom        "|"
            vsaldo-cli          "|"
            valvenda            "|"
            clien.clicod "|"
            clien.proprof[1]
            skip.
        output close. 
        find first repexporta where repexporta.TABELA       = "PLANI" 
                                and repexporta.Tabela-Recid = recid(plani)
                                and repexporta.BASE         = "GESTAO_EXCECAO"
                                and repexporta.EVENTO       = "9015"
                                no-lock no-error.
        if not avail repexporta 
        then   do on error undo.
                create repexporta.
                ASSIGN repexporta.TABELA       = "PLANI"
                       repexporta.DATATRIG     = plani.pladat
                       repexporta.HORATRIG     = time
                       repexporta.EVENTO       = "9015"
                       repexporta.DATAEXP      = today
                       repexporta.HORAEXP      = time
                       repexporta.BASE         = "GESTAO_EXCECAO"
                       repexporta.Tabela-Recid = recid(plani).
        end.
    end.
end procedure.
