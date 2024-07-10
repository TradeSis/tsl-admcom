{admcab.i}
def var vok as l.
def var vcatcod  like produ.catcod.
def var vcatcod2 like produ.catcod.

def var vdata as date.
def var i as i.
def var vdtini  as date.
def var vdtfin  as date.
def var vtotal  like titulo.titvlcob column-label "Total".

def temp-table wftotal
 field etbcod like estab.etbcod    column-label "Estab"
 field data   like titulo.titdtpag column-label "Data"
field atras  like titulo.titvlcob column-label "Atrasados"
format ">>,>>>,>>9.99"
field pont1  like titulo.titvlcob column-label "Pontual 1"
format ">>,>>>,>>9.99"
field entra  like titulo.titvlcob column-label "Entrada"
format ">>,>>>,>>9.99"
field vista  like titulo.titvlcob column-label "A Vista"
format ">>,>>>,>>9.99"
field pont2  like titulo.titvlcob column-label "Pontual 2"
format ">>,>>>,>>9.99"
field antec  like titulo.titvlcob column-label "Antecipado"
format ">>,>>>,>>9.99" .

update vdtini   colon 15 label "Data Inicial"
       vdtfin   colon 15 label "Data Final"
       with frame f1 row 4 width 80 side-label.
update vcatcod  label "Departamento"     colon 20
       with frame f1 side-labels width 80 row 4 .
find categoria where categoria.catcod = vcatcod no-lock no-error.
display categoria.catnom no-label with frame  f1.

if vcatcod = 41
then vcatcod2 = 45.
if vcatcod = 31
then vcatcod2 = 35.

for each estab no-lock.
    pause 0.
    display "Processando Loja" estab.etbcod
            with centered row 10 frame festab no-label.
        do i = day(vdtini) to day(vdtfin):
        vdata = date(month(vdtini),i,year(vdtfin)).

        for each titulo where titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titsit = "PAG"         and
                              titulo.etbcod = estab.etbcod  and
                              titulo.titdtpag = vdata no-lock.
            if substring(string(titulo.titnum),1,1) = "M"
            then next.
            if substring(string(titulo.titnum),1,1) = "U"
            then next.
            if substring(string(titulo.titnum),1,1) = "D"
            then next.
            vok = yes.
            for each contnf where contnf.etbcod = titulo.etbcod and
                                  contnf.contnum = int(titulo.titnum) no-lock.
                find first plani where plani.etbcod = contnf.etbcod and
                                       plani.placod = contnf.placod
                                                    no-lock no-error.
                if not avail plani
                then do:
                    vok = no.
                    next.
                end.
                else vok = yes.
            end.
            if vok = no
            then next.
            vok = no.
            for each movim where movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc no-lock:
                find produ where produ.procod = movim.procod
                                                    no-lock no-error.
                if not avail produ
                then next.
                if produ.catcod <> vcatcod and
                   produ.catcod <> vcatcod2
                then do:
                    vok = no.
                    leave.
                end.
                else vok = yes.
            end.
            if vok = no
            then next.

            find first wftotal where wftotal.etbcod = estab.etbcod no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = estab.etbcod.
            end.
            if (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)      and
                titulo.titdtven < vdtini
            then
                wftotal.atras = wftotal.atras + titulo.titvlcob.

            if (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)      and
               month(titulo.titdtven) = month(vdtfin) and
                titulo.titdtemi < vdtini
            then
                wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.

            if month(titulo.titdtemi) = month(vdtfin) and
               month(titulo.titdtven) = month(vdtfin) and
               (titulo.titdtpag >= vdtini and
                titulo.titdtpag <= vdtfin)
            then do:

                if titulo.titpar = 0
                then wftotal.entra = wftotal.entra + titulo.titvlcob.

                if titulo.modcod = "VVI"
                then wftotal.vista = wftotal.vista + titulo.titvlcob.

                if titulo.titpar > 0 and
                   titulo.modcod = "CRE" and
                   titulo.clifor > 1
                then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.
            end.

            if titulo.titdtven >  vdtfin and
              (titulo.titdtpag >= vdtini and
               titulo.titdtpag <= vdtfin)
            then
                wftotal.antec = wftotal.antec + titulo.titvlcob.
        end.
        end.
end.

def var varq as char format "x(20)".
varq = "..\relat\r" + string(time) + ".rel".

output to value(varq) page-size 65.

for each wftotal break by wftotal.etbcod with width 127.
    form header wempre.emprazsoc
         space(6) "RESLIQ2"  at 107
         "Pag.: " at 118 page-number format ">>9" skip
         "RESUMO DAS LIQUIDACOES     " categoria.catnom   "    "
         "PERIODO DE " string(vdtini) " A " string(vdtfin)
         today format "99/99/9999" at 107
         string(time,"hh:mm:ss") at 120
         skip fill("-",127) format "x(127)" skip
         with frame fcab no-label page-top no-box width 127.
    view frame fcab.

    if first-of(wftotal.etbcod)
    then vtotal = 0.
    vtotal = wftotal.atras + wftotal.pont1 + wftotal.pont2 + wftotal.antec.
    display wftotal.etbcod
            wftotal.atras (TOTAL)
            wftotal.pont1 (TOTAL)
            wftotal.pont2 (TOTAL)
            wftotal.antec (TOTAL).
    display vtotal        (TOTAL).
end.
output close.
dos silent value("type " + varq + " > prn").
