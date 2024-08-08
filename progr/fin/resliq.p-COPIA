/*
#1 - 31.08.2017 - Nova novacao - novo filtro de modaildades
*/
{admcab.i}


def temp-table tt-cli
    field clicod like clien.clicod.

def var vdata like plani.pladat.
def var i as i.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var v-feirao-nome-limpo as log format "Sim/Nao" initial no.
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
format ">>,>>>,>>9.99".

def var vmod-sel as char.

def NEW SHARED temp-table tt-modalidade-selec /* #1 */
    field modcod as char.


assign sresp = false.
update sresp label "Seleciona Modalidades?" colon 25
        help "Não = Modalidade CRE Padrão / Sim = Seleciona Modalidades"
        with side-label width 80 frame f1.
if sresp
then run selec-modal.p ("REC"). /* #1 */
else do:
    create tt-modalidade-selec.
    assign tt-modalidade-selec.modcod = "CRE".
end.
    
assign vmod-sel = "  ".
for each tt-modalidade-selec.
    assign vmod-sel = vmod-sel + tt-modalidade-selec.modcod + "  ".
end.        
display vmod-sel format "x(40)" no-label with frame f1.

update vdtini   colon 25 label "Data Inicial"
       vdtfin   colon 25 label "Data Final"
       with frame f1.

update v-feirao-nome-limpo label "Considerar apenas feirao" colon 25
       with frame f1.

if false /*vcre = no*/
then do:    
    for each tt-cli:
        delete tt-cli.
    end.
      
    for each clien where clien.classe = 1 no-lock:
        display clien.clicod
                clien.clinom
                clien.datexp format "99/99/9999" with 1 down. pause 0.
    
        create tt-cli.
        assign tt-cli.clicod = clien.clicod.
    end.
end.

def var etb-tit like titulo.etbcod.

for each estab no-lock.
    pause 0.
    do vdata = vdtini to vdtfin:
        if true /* vcre  */
        then do:
        for each tt-modalidade-selec,
        
            each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.etbcod = estab.etbcod no-lock:

            etb-tit = titulo.etbcod.
            if etb-tit = 10 and
                titulo.titdtemi < 01/01/2014
            then etb-tit = 23.
                
            display "Processando Loja" estab.etbcod vdata
                with centered row 10 frame festab no-label.
            pause 0 before-hide.
            if titulo.titpar = 0
            then next.
            if titulo.modcod = "VVI"
            then next.
            if titulo.clifor <= 1
            then next.
            /**
            {filtro-feiraonl.i}
            **/
            if titulo.titsit <> "PAG"
            then next.
            
            find first wftotal where wftotal.etbcod = etb-tit no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = etb-tit.
            end.
            
            if titulo.titdtven < date(month(vdtini),01,year(vdtini))
            then wftotal.atras = wftotal.atras + titulo.titvlcob.
            else
            if month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin) and
               titulo.titdtemi < vdtini
            then wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.
            else
            if month(titulo.titdtemi) = month(vdtfin) and
               year(titulo.titdtemi) = year(vdtfin) and
               month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin)
            then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.
            else
            wftotal.antec = wftotal.antec + titulo.titvlcob.
        end.
        end.
        /*
        else do:
        for each tt-cli,
            each tt-modalidade-selec,
            each titulo use-index iclicod where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = tt-modalidade-selec.modcod and
                              titulo.titdtpag = vdata and
                              titulo.clifor = tt-cli.clicod and
                              titulo.etbcod = estab.etbcod no-lock:

            etb-tit = titulo.etbcod.
            if etb-tit = 10 and
               titulo.titdtemi < 01/01/2014
            then etb-tit = 23.
               
            display "Processando Loja" estab.etbcod vdata
                with centered row 10 frame ffestab no-label.
            pause 0 before-hide.
            if titulo.titpar = 0
            then next.
            if titulo.modcod = "VVI"
            then next.
            if titulo.clifor <= 1
            then next.
            {filtro-feiraonl.i}

            find first wftotal where wftotal.etbcod = etb-tit no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = etb-tit.
            end.
            
            if titulo.titdtven < vdtini
            then wftotal.atras = wftotal.atras + titulo.titvlcob.
            else
            if month(titulo.titdtven) = month(vdtfin) and
               titulo.titdtemi < vdtini
            then wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.
            else
            if month(titulo.titdtemi) = month(vdtfin) and
               month(titulo.titdtven) = month(vdtfin)
            then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.
            else  
            wftotal.antec = wftotal.antec + titulo.titvlcob.
        end.
        end.
        **/
    end.
end.

def var varquivo as char format "x(20)".

if opsys = "UNIX"
then varquivo = "/admcom/relat/r" + string(time) + ".rel".
else varquivo = "..\relat\r" + string(time) + ".rel".

output to value(varquivo) page-size 65.

for each wftotal break by wftotal.etbcod with width 127.
    form header wempre.emprazsoc
         space(6) "RESLIQ"  at 107
         "Pag.: " at 118 page-number format ">>9" skip
         "RESUMO DAS LIQUIDACOES "
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
            wftotal.pont2 (TOTAL)   /******* tirar , colocar Prestacoes ****/
            wftotal.antec (TOTAL).
   display vtotal        (TOTAL).  /******* tirar ******/
end.
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

