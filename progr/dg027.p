def var vlimite as dec.
def var assunto as char.
def var vaspas as char format "x".
vaspas = chr(34).
def var varquivo as char.
{/admcom/progr/cntgendf.i}
find first tbcntgen where tbcntgen.etbcod = 27 no-lock no-error.
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
   if {conv_igual.i estab.etbcod} then next.

    for each plani where plani.movtdc = 5
        and plani.pladat = today
        and plani.etbcod = estab.etbcod 
        and plani.serie = "V" no-lock
        :
        if plani.desti = 1
        then next.
        find first bplani where bplani.etbcod = plani.etbcod and
                                bplani.placod = plani.placod and
                                bplani.movtdc = plani.movtdc and
                                bplani.serie = "V"
                                exclusive no-wait no-error.
        if not avail bplani then next.
        
        if plani.nottran > 26
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
        bplani.nottran = 27.
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

        varquivo = "/admcom/work/arquivodg027.txt".
        
        output to value(varquivo).
        
        put unformatted
        "COMPROU FICOU SALDO > " vsaldo-lim " <BR>" skip
        "---------------------------------------------- <BR>" skip
        "__Filial: " plani.etbcod  "<BR>" skip
        "_Cliente:" clien.clinom + " (" + string(clien.clicod) + "( <BR>" skip
        "Vl.Saldo:" vsaldo-cli "<BR>" skip
        "NF.Venda:" plani.numero "<BR>" skip
        "Dt.Venda:" plani.pladat "<BR>" skip
        "Vl.Venda:" valvenda     "<BR>" skip
        "Vendedor:" func.funnom "<BR>" skip
        "---------------------------------------------- <BR>" skip
        .        
        output close.
        
        run /admcom/progr/envia_dg.p("27",varquivo).
    end.
end procedure.
