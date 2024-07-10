{admcab.i}
def var vdtref  as   date format "99/99/9999" .
def var vetbcod     like estab.etbcod.
def var vdisp   as   char format "x(8)".
def var vtotal  like titulo.titvlcob.
def var vmes    as   char format "x(3)" extent 12 initial
                        ["JAN","FEV","MAR","ABR","MAI","JUN",
                         "JUL","AGO","SET","OUT","NOV","DEZ"] .

def var vtot1   like titulo.titvlcob.
def var vtot2   like titulo.titvlcob.

def temp-table wf
    field vdt   as date
    field vencido like titulo.titvlcob label "Vencido"
    field vencer  like titulo.titvlcob label "Vencer".

prompt-for estab.etbcod label "Estabelecimento"  colon 20.
if input estab.etbcod <> ""
then do:
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label .
end.
else
    display "Geral" @ estab.etbnom.

vetbcod = input estab.etbcod.

update vdtref   label "Data Referencia"  colon 20
       with side-labels width 80 row 4 .

if input estab.etbcod = ""
then
for each titulo use-index titdtpag
         where titulo.empcod = WEMPRE.EMPCOD and
               titulo.titnat = no and
               titulo.modcod = "CRE" and
               titulo.titdtpag = ?:

    if titulo.titdtemi > vdtref
    then next.

    find first wf where wf.vdt = date(month(titulo.titdtven), 01,
                                      year(titulo.titdtven)) no-error.
    if not available wf
    then
        create wf.
    assign wf.vdt = date(month(titulo.titdtven), 01, year(titulo.titdtven)).

    if titulo.titdtven <= vdtref
    then
        wf.vencido = wf.vencido + titulo.titvlcob.
    else
        wf.vencer  = wf.vencer + titulo.titvlcob.
end.
else
for each titulo use-index titdtpag
         where titulo.empcod = WEMPRE.EMPCOD and
               titulo.titnat = no and
               titulo.modcod = "CRE" and
               titulo.titdtpag = ? and
               titulo.etbcod = input estab.etbcod no-lock:

    if titulo.titdtemi > vdtref
    then next.

    find first wf where wf.vdt = date(month(titulo.titdtven), 01,
                                      year(titulo.titdtven)) no-error.
    if not available wf
    then
        create wf.
    assign wf.vdt = date(month(titulo.titdtven), 01, year(titulo.titdtven)).

    if titulo.titdtven <= vdtref
    then
        wf.vencido = wf.vencido + titulo.titvlcob.
    else
        wf.vencer  = wf.vencer + titulo.titvlcob.
end.
message "Gerando o Relatorio ".

def var varq as char format "x(20)".
varq = "..\relat\REL" + string(time) + ".rel".

output to value(varq) page-size 65.
for each wf break by vdt.
    form header
        wempre.emprazsoc
        space(6) "POGER"   at 62
        "Pag.: " at 71 page-number format ">>9" skip
        "- POSICAO FIN. VENCIDAS/A VENCER - FILIAL -" string(vetbcod)
        today format "99/99/9999" at 62
        string(time,"hh:mm:ss") at 73 skip
        "DATA BASE:" string(vdtref)  skip
        fill("-",80) format "x(80)" skip
        with frame fcab no-label page-top no-box width 80.
    view frame fcab.
    vdisp = trim(string(vmes[int(month(wf.vdt))]) + "/" +
                 string(year(wf.vdt),"9999") ) .

    find carteira where carteira.carano = year(wf.vdt) and
                        carteira.titnat = no and
                        carteira.modcod = "CRE" and
                        carteira.etbcod = vetbcod
            no-error.

    disp vdisp          column-label "Mes/Ano"
         carteira.carval[month(wf.vdt)] column-label "Carteira"
            when wf.vencido > 0 and
                 available carteira
         wf.vencido     column-label "Vencido" (TOTAL)
         wf.vencido / carteira.carval[month(wf.vdt)] * 100 format "->>9.99"
                column-label "%"
            when wf.vencido > 0 and
                 available carteira

         wf.vencer      column-label "A Vencer" (TOTAL)
         with centered .

        vtot1  = vtot1  +  wf.vencido.

        vtot2  = vtot2  +  wf.vencer.

        vtotal = vtotal + (wf.vencer + wf.vencido).
end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.

    display vtotal label "Total Geral" at 40 with side-labels frame ftot.
output close.
dos silent value("type " + varq + " > prn").
