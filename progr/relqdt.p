{admcab.i}
def var i as i.
def var vdata   like plani.pladat.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vtotal  like titulo.titvlcob column-label "Total".

def temp-table wftotal
 field etbcod like estab.etbcod    column-label "Estab"
 field data   like titulo.titdtpag column-label "Data"
 field atras  like titulo.titvlcob column-label "Atrasados"  format ">>>,>>9.99"
 field pont1  like titulo.titvlcob column-label "Pontual 1"  format ">>>,>>9.99"
 field entra  like titulo.titvlcob column-label "Entrada"    format ">>>,>>9.99"
 field vista  like titulo.titvlcob column-label "A Vista"    format ">>>,>>9.99"
 field pont2  like titulo.titvlcob column-label "Pontual 2"  format ">>>,>>9.99"
 field antec  like titulo.titvlcob column-label "Antecipado" format ">>>,>>9.99"
 .

def var v-fil17 as char extent 2 format "x(15)"
    init ["Nova","Antiga"].
def var vindex as int.    

do:
    prompt-for estab.etbcod colon 20
               with frame f1 .
    find estab using estab.etbcod no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.
    display estab.etbnom no-label
            with frame f1.
    vindex = 0.
    if estab.etbcod = 17
    then do:
         disp v-fil17 with frame f-17 1 down centered row 10 
            no-label.
         choose field v-fil17 with frame f-17.
         vindex = frame-index.   
    end.
    update vdtini   colon 20 label "Data Inicial"
           vdtfin   colon 20 label "Data Final"
           with frame f1
                row 4 width 80 side-label.
    i = 0.
    do i = day(vdtini) to day(vdtfin):
        vdata = date(month(vdtini),i,year(vdtini)).
        if estab.etbcod = 17 and
           vindex = 2 and
           vdata >= 10/20/2010
        then next.  
        else if estab.etbcod = 17 and
            vindex = 1 and
            vdata < 10/20/2010
        then next.
        
        for each titulo  where titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titdtpag = vdata       and
                              titulo.titsit = "PAG"         and
                              titulo.etbcod = estab.etbcod
                              no-lock.
            find first wftotal where wftotal.etbcod = estab.etbcod and
                                     wftotal.data   = titulo.titdtpag
                                     no-error.
            if not avail wftotal
            then do:
                create wftotal.
                assign wftotal.etbcod = estab.etbcod
                       wftotal.data   = titulo.titdtpag.
            end.
            if (titulo.titdtpag >= vdtini  and
                titulo.titdtpag <= vdtfin) and
                titulo.titdtven < vdtini
            then
                wftotal.atras = wftotal.atras + titulo.titvlcob.

            if (titulo.titdtpag >= vdtini  and
                titulo.titdtpag <= vdtfin) and
               (titulo.titdtven >= vdtini  and
                titulo.titdtven <= vdtfin) and
                titulo.titdtemi < vdtini
            then
                wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.

            if (titulo.titdtemi >= vdtini  and
                titulo.titdtemi <= vdtfin) and
               (titulo.titdtven >= vdtini  and
                titulo.titdtven <= vdtfin) and
               (titulo.titdtpag >= vdtini  and
                titulo.titdtpag <= vdtfin)
            then do:

                if titulo.titpar = 0
                then wftotal.entra = wftotal.entra + titulo.titvlcob.

                if titulo.modcod = "VVI"
                then wftotal.vista = wftotal.vista + titulo.titvlcob.

                if titulo.titpar > 0 and
                   titulo.modcod = "CRE"
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
def var varquivo as char.
if opsys = "UNIX"
then varq = "../relat/qdtl" + string(time) + ".rel".
else varq = "..\relat\qdtw" + string(time) + ".rel".
varquivo = varq.

output to value(varq) page-size 65.
{ini17cpp.i}

for each wftotal break by wftotal.etbcod
                       by wftotal.data  with width 132.
    form header wempre.emprazsoc
         space(6) "RELQDT" at 112
         "Pag.: " at 123 page-number format ">>9" skip
         "RESUMO DAS LIQUIDACOES DIARIO "
         "PERIODO DE " string(vdtini) " A " string(vdtfin)
         today format "99/99/9999" at 112
         string(time,"hh:mm:ss") at 125
         skip fill("-",132) format "x(132)" skip
         with frame fcab no-label page-top no-box width 132.
    view frame fcab.

    if first-of(wftotal.etbcod) and
       first-of(wftotal.data)
    then vtotal = 0.
    vtotal = wftotal.atras + wftotal.pont1 + wftotal.pont2 + wftotal.antec.
    if vtotal > 0
    then do:
        display wftotal.etbcod
                wftotal.data
                wftotal.atras (TOTAL)
                wftotal.pont1 (TOTAL)
                wftotal.entra (TOTAL) /*** tirar ***/
                wftotal.vista (TOTAL) /*** tirar ***/
                wftotal.pont2 (TOTAL) /*** tirar ***/
                wftotal.antec (TOTAL). /*** tirar ***/
        display vtotal        (TOTAL).

    end.
end.
{fin17cpp.i}
output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
    /*dos silent value("type " + varq + " > prn").
    */
end.
