/* #1 Helio 04.04.18 - Regra definida 
    TITOBS[1] contem FEIRAO = YES - NAO PERTENCE A CARTEIRA 
    ou
    TPCONTRATO = "L" - NAO PERTENCE A CARTEIRA
   #2 Claudir TP 27707948 igual resliq.p  
*/

{admcab.i}

def var i       as   int.
def var varq    as   char.
def var vdata   like plani.pladat.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vtotal  like titulo.titvlcob column-label "Total".
def var vdir    as char.

def temp-table wftotal
    field etbcod    like estab.etbcod       column-label "Estab"
    field data      like titulo.titdtpag    column-label "Data"
    field atras     like titulo.titvlcob    column-label "Atrasados"
    field pont1     like titulo.titvlcob    column-label "Pontual 1"
    field pont2     like titulo.titvlcob    column-label "Pontual 2"
    field antec     like titulo.titvlcob    column-label "Antecipado"
    field pagfil    like titulo.titvlcob    column-label "P.P!Filial".

def var vfil17 as char extent 2 format "x(15)"
    init["Nova","Antiga"].

def var vindex as int.

if setbcod > 0 and setbcod < 10 
    then vdir = "/admcom/relat-loja/filial00" + string(setbcod) + "/relat/resumo-liq-fl00" + string(setbcod) + "-" + string(time) + ".txt".

if setbcod > 9 and setbcod < 100 
    then vdir = "/admcom/relat-loja/filial0" + string(setbcod) + "/relat/resumo-liq-fl0" + string(setbcod) + "-" + string(time) + ".txt".

if setbcod > 99 
    then vdir = "/admcom/relat-loja/filial" + string(setbcod) + "/relat/resumo-liq-fl" + string(setbcod) + "-" + string(time) + ".txt".

do:

    /*prompt-for estab.etbcod colon 20
               with frame f1 .*/

    find estab where estab.etbcod = setbcod no-error.
    if not avail estab
    then do:
        message "Estabelecimento Invalido".
        undo.
    end.

    display estab.etbcod estab.etbnom no-label
            with frame f1.
    vindex = 0.
    if estab.etbcod = 17
    then do:
        /*disp vfil17 no-label with frame f-17 1 down row 10 centered
             side-label. 
        choose field vfil17  with frame f-17.*/
        vindex = frame-index.
    end.
    update vdtini   colon 20 label "Data Inicial"
           vdtfin   colon 20 label "Data Final"
           with frame f1
                row 4 width 80 side-label.

    

def var v-feirao-nome-limpo as log init no.
    
    i = 0.
    /*
    do i = day(vdtini) to day(vdtfin):
        vdata = date(month(vdtini),i,year(vdtfin)).
    */
    do vdata = vdtini to vdtfin:    
        if estab.etbcod = 17 and
            vindex = 2 and
            vdata >= 10/20/2010
        then next.


        for each titulo use-index titdtpag where
                              titulo.empcod = wempre.empcod and
                              titulo.titnat = no            and
                              titulo.modcod = "CRE"         and
                              titulo.titdtpag = vdata       and
                              titulo.etbcod = estab.etbcod no-lock.
            /*#2
            if titulo.titsit <> "PAG"
            then next.
            */
            if setbcod = 23 and
               estab.etbcod = 10 and
               titulo.titdtemi > 04/30/2011
            then next.

            if titulo.titpar = 0
            then next.
            if titulo.modcod = "VVI"
            then next.
            if titulo.clifor <= 1
            then next.
 
             /* #1 */
          /*  if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM" or
               titulo.tpcontrato = "L" 
            then next.*/

            {filtro-feiraonl.i}
            
            find first wftotal where wftotal.etbcod = estab.etbcod and
                                     wftotal.data   = titulo.titdtpag
                                     no-error.
            if not avail wftotal
            then do:

                create wftotal.
                assign wftotal.etbcod = estab.etbcod
                       wftotal.data   = titulo.titdtpag.
            end.

            /*************** #2
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
            then
                wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.

            if titulo.titdtven >  vdtfin and
              (titulo.titdtpag >= vdtini and
               titulo.titdtpag <= vdtfin)
            then wftotal.antec = wftotal.antec + titulo.titvlcob.
            ***********/
            
            if titulo.titdtven < vdtini
            then wftotal.atras = wftotal.atras + titulo.titvlcob.

            if month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin) and
               titulo.titdtemi < vdtini
            then wftotal.pont1 = wftotal.pont1 + titulo.titvlcob.

            if month(titulo.titdtemi) = month(vdtfin) and
               year(titulo.titdtemi) = year(vdtfin) and
               month(titulo.titdtven) = month(vdtfin) and
               year(titulo.titdtven) = year(vdtfin)
            then wftotal.pont2 = wftotal.pont2 + titulo.titvlcob.

            if titulo.titdtven >  vdtfin
            then wftotal.antec = wftotal.antec + titulo.titvlcob.
 

            
            if titulo.moecod = "nov" or
               titulo.clifor = 1 or
               titulo.titpar = 0 /* #1 or
               titulo.titpar >= 50 */
               or
               titulo.tpcontrato = "L"
            then next.
                        
            wftotal.pagfil = wftotal.pagfil + titulo.titvlcob.


        end.

    end.
end.

output to value(vdir).

    form header wempre.emprazsoc
             space(6) "RELQDTNOVO_040418" at 112
             "Pag.: " at 123 page-number format ">>9" skip
             "RESUMO DAS LIQUIDACOES DIARIO FL" setbcod
             "PERIODO DE " string(vdtini) " A " string(vdtfin)
             today format "99/99/9999" at 112
             string(time,"hh:mm:ss") at 125
             skip fill("-",132) format "x(132)" skip
             with frame fcab no-label page-top no-box width 132.

        view frame fcab.

    for each wftotal break by wftotal.etbcod
                     by wftotal.data  with width 132.

        if first-of(wftotal.etbcod) and
           first-of(wftotal.data)
        then vtotal = 0.
        vtotal = wftotal.atras + wftotal.pont1 + wftotal.pont2
                    + wftotal.antec.
        if vtotal > 0
        then do:
            disp wftotal.etbcod
                    wftotal.data
                    wftotal.atras (TOTAL)
                    wftotal.pont1 (TOTAL)
                    wftotal.pont2 (TOTAL)
                    .
                        pause 0.
            
        end.
    end.

output close.

message "Relatorio gerado com sucesso" view-as alert-box.
