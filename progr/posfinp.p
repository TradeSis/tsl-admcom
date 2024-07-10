{admcab.i}
def var k as l.
def var vtitnum like contnf.contnum.
def var vok as l.
def var vcatcod  like produ.catcod.
def var vcatcod2 like produ.catcod.
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

def temp-table wfano
    field vano    as i format "9999"
    field vencidoano like titulo.titvlcob label "Vencido"
    field vencerano  like titulo.titvlcob label "Vencer"
    field cartano    like titulo.titvlcob label "Carteira".

def var wvencidoano like titulo.titvlcob label "Vencido".
def var wvencerano  like titulo.titvlcob label "Vencer".
def var wcartano    like titulo.titvlcob label "Carteira".

prompt-for estab.etbcod label "Estabelecimento"  colon 20 with frame ff.
if input estab.etbcod <> ""
then do:
    find estab where estab.etbcod = input estab.etbcod no-lock no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label with frame ff.
end.
else
    display "Geral" @ estab.etbnom.

vetbcod = input estab.etbcod.

update vdtref   label "Data Referencia"  colon 20
       vcatcod  label "Departamento"     colon 20
       with frame ff side-labels width 80 row 4 .
find categoria where categoria.catcod = vcatcod no-lock no-error.
display categoria.catnom no-label with frame  ff.
if vcatcod = 41
then vcatcod2 = 45.
if vcatcod = 31
then vcatcod2 = 35.


for each titulo use-index titdtpag
         where titulo.empcod = WEMPRE.EMPCOD and
               titulo.titnat = no and
               titulo.modcod = "CRE" and
               titulo.titdtpag = ? and
               titulo.etbcod = input estab.etbcod no-lock:

    if titulo.titdtemi > vdtref
    then next.
    disp titulo.etbcod titulo.titnum titulo.titdtemi vtitnum with 1 down.
    pause 0.
    k = no.
    for each contnf where contnf.etbcod = titulo.etbcod and
                          contnf.contnum = int(titulo.titnum) no-lock.
        find first plani where plani.etbcod = contnf.etbcod and
                               plani.placod = contnf.placod
                                            no-lock no-error.
        if not avail plani
        then do:
           message "Nao encontrei nota" titulo.titnum. pause 0.
           next.
        end.
        vok = no.
        for each movim where movim.etbcod = plani.etbcod and
                             movim.placod = plani.placod and
                             movim.movtdc = plani.movtdc no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ
            then next.
            if produ.catcod <> vcatcod and
               produ.catcod <> vcatcod2
            then vok = no.
            else vok = yes.
        end.
        if vok = no
        then next.

        find first wf where wf.vdt = date(month(titulo.titdtven), 01,
                                          year(titulo.titdtven)) no-error.
        if not available wf
        then create wf.
        assign wf.vdt = date(month(titulo.titdtven), 01, year(titulo.titdtven)).

        if titulo.titdtven <= vdtref
        then wf.vencido = wf.vencido + titulo.titvlcob.
        else wf.vencer  = wf.vencer + titulo.titvlcob.
    end.
end.

for each wf where year(wf.vdt) < (year(vdtref) - 1) break by wf.vdt
                                                       by year(wf.vdt):


    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if not avail wfano
    then do:
        create wfano.
        assign wfano.vano = year(wf.vdt).
    end.

    wfano.vencidoano = wfano.vencidoano + wf.vencido.
    wfano.vencerano  = wfano.vencerano  + wf.vencer.

    find carteira where carteira.carano = year(wf.vdt) and
                        carteira.titnat = no and
                        carteira.modcod = "CRE" and
                        carteira.etbcod = vetbcod
    no-error.

    if avail carteira
    then do:

        wcartano = wcartano + carteira.carval[month(wf.vdt)].

    end.

end.

for each wf where year(wf.vdt) > (year(vdtref) + 1) break by wf.vdt
                                                       by year(wf.vdt):


    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if not avail wfano
    then do:
        create wfano.
        assign wfano.vano = year(wf.vdt).
    end.

    wfano.vencidoano = wfano.vencidoano + wf.vencido.
    wfano.vencerano  = wfano.vencerano  + wf.vencer.

    find carteira where carteira.carano = year(wf.vdt) and
                        carteira.titnat = no and
                        carteira.modcod = "CRE" and
                        carteira.etbcod = vetbcod
    no-error.

    if avail carteira
    then do:

        wcartano = wcartano + carteira.carval[month(wf.vdt)].

    end.

end.

for each wf:
    find first wfano where wfano.vano = year(wf.vdt) no-error.
    if avail wfano
    then delete wf.
end.

message "Gerando o Relatorio ".

def var varq as char format "x(20)".
varq = "..\relat\REL" + string(time) + ".rel".

output to value(varq) page-size 65.
form header
     wempre.emprazsoc
     space(6) "POSFINP"   at 62
     "Pag.: " at 71 page-number format ">>9" skip
     "- POSICAO FIN. VENCIDAS/A VENCER - FILIAL -" string(vetbcod)
     today format "99/99/9999" at 62
     string(time,"hh:mm:ss") at 73 skip
     "DATA BASE:" string(vdtref)  "     " categoria.catnom skip
     fill("-",80) format "x(80)" skip
     with frame fcab no-label page-top no-box width 80.
view frame fcab.


for each wfano where vano < (year(vdtref) - 1) break by vano:

    vdisp = string(vano,"9999") .

    disp vdisp          column-label "Ano"
         wfano.cartano  column-label "Carteira"
         wfano.vencidoano     column-label "Vencido" (TOTAL)
         wfano.vencidoano / wfano.cartano * 100 format "->>9.99"
                column-label "%"
         wfano.vencerano      column-label "A Vencer" (TOTAL)
         with centered .

        vtot1  = vtot1  +  wfano.vencidoano.

        vtot2  = vtot2  +  wfano.vencerano.

        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).

end.

for each wf break by vdt.

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

for each wfano where vano > (year(vdtref) + 1) break by vano:

    vdisp = string(vano,"9999") .

    disp vdisp          column-label "Ano"
         wfano.cartano  column-label "Carteira"
         wfano.vencidoano     column-label "Vencido" (TOTAL)
         wfano.vencidoano / wfano.cartano * 100 format "->>9.99"
                column-label "%"
         wfano.vencerano      column-label "A Vencer" (TOTAL)
         with centered .

        vtot1  = vtot1  +  wfano.vencidoano.

        vtot2  = vtot2  +  wfano.vencerano.

        vtotal = vtotal + (wfano.vencerano + wfano.vencidoano).

end.

    display ((vtot1 / vtotal) * 100) format ">>9.99 %" at 39
            ((vtot2 / vtotal) * 100) format ">>9.99 %" at 64 skip(1)
            with frame fsub.


    display vtot1 label "Total Vencido" at 10
            vtot2 label "Total Vencer"  at 30
            vtotal label "Total Geral"  at 50 with side-labels frame ftot.
output close.
dos silent value("type " + varq + " > prn").
