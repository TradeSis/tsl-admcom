/*  relmoetef.p                                                             */
/*  Luciano Alves - 26/06/2014                                              */
{admcab.i}
{filtro-estab.def}
{filtro-moeda.def}

def var varquivo as char.
def var vdata  as date.
def var vdata1 as date init today.
def var vdata2 as date init today.  
def var voperacao as char.
def var vdestino  as log format "Arquivo/Relatorio".

def var par-operacao as char format "x(20)" extent 4
    init [" GERAL ", " Venda " , " Pagamento Prestacao "," Entrada "].

form
    vEstab   colon 31 label "Todos Estabelecimentos.."
    cestab   no-label
    vmoeda  colon 31  label "Todos as Moedas........."
    cmoeda  no-label skip (1)
    vdata1   colon 31 label "Periodo"
    vdata2   label "ate"  skip(1)
    par-operacao[1]  no-label  format "x(10)" at 10
    par-operacao[2]  no-label  format "x(10)"
    par-operacao[3]  no-label  format "x(22)"
    par-operacao[4]  no-label  format "x(10)"
    vdestino colon 31 label "Destino" help "Arquivo ou Relatorio"
    with frame fopcoes row 3 side-label width 80.

do on error undo with frame fopcoes.
    vestab  = yes.
    {filtro-estab.i}
    do on error undo.
        vmoeda = yes.
        {filtro-moeda_tef.i} 
        do on error undo.
            update vdata1 vdata2 with frame fopcoes.
            do on error undo.
                display par-operacao.
                choose field par-operacao with frame fopcoes.
            end.
        end.
    end.

    update vdestino label "Destino".
end.

def temp-table wfrel
    field rec_titulo as recid
    field rec_titpag as recid
    field operacao   as char
    field carvan     as char
    field qtd_parcelas as int
    field titvlmer   as dec
    field taxa       like moetaxa.taxa
    field vlrtaxa    as dec format "->>>9.99" decimals 2
    field vlrliquido as dec.

def temp-table ttresumo
    field etbcobra like titulo.etbcobra  
    field data     like titpag.cxmdata  
    field moecod   like titpag.moecod  
    field titvlpag like titpag.titvlpag .
    
for each ttresumo.
    delete ttresumo.
end.

for each wfrel.
    delete wfrel.
end.

for each estab no-lock. 
    find first wfestab no-error.   
    if avail wfestab  
    then do: 
        if wfestab.etbcod = 0 
        then. 
        else do: 
            find first wfestab where wfestab.etbcod = estab.etbcod no-error. 
            if not avail wfestab 
            then next. 
        end. 
    end.    
    do vdata = vdata1 to vdata2.
        for each titulo where titulo.etbcobra = estab.etbcod and
                              titulo.titdtpag = vdata
                              no-lock.
            voperacao = if titulo.titpar = 0
                        then "Entrada"
                        else if titulo.modcod = "VVI"
                        then "Venda"
                        else "Pg Prestacao".

                if frame-index = 2 and
                   voperacao <> "Venda"
                then next.   
                if frame-index = 3 and
                   voperacao <> "Pg Prestacao"
                then next.   
                if frame-index = 4 and
                   voperacao <> "Entrada"
                then next.   

            /*** P2K ***/
            find first titbsmoe where
                titbsmoe.empcod = titulo.empcod and
                titbsmoe.titnat = titulo.titnat and
                titbsmoe.modcod = "CAR" and
                titbsmoe.etbcod = titulo.etbcod and
                titbsmoe.clifor = titulo.clifor and
                titbsmoe.titnum = titulo.titnum and
                titbsmoe.titpar = 0 and
                titbsmoe.titdtemi = titulo.titdtemi
                 no-lock no-error.
            
            for each titpag where titpag.empcod = titulo.empcod and
                                  titpag.titnat = titulo.titnat and
                                  titpag.modcod = titulo.modcod and
                                  titpag.etbcod = titulo.etbcod and
                                  titpag.clifor = titulo.clifor and
                                  titpag.titnum = titulo.titnum and
                                  titpag.titpar = titulo.titpar no-lock.
                find first wfmoeda where wfmoeda.moecod = titpag.moecod
                                    no-error.
                if not avail wfmoeda
                then next.

                create wfrel.
                assign wfrel.rec_titpag = recid(titpag)
                       wfrel.rec_titulo = recid(titulo)
                       wfrel.operacao   = voperacao.
                if avail titbsmoe
                then do.
                    assign
                        wfrel.carvan = titbsmoe.carvan
                        wfrel.qtd_parcelas = titbsmoe.qtd_parcelas.

                    wfrel.titvlmer = titbsmoe.titvlcob - titbsmoe.titvljur.
                    find last moetaxa where 
                        moetaxa.moecod = titbsmoe.moecod and
                        moetaxa.qtd_parcelas <= titbsmoe.qtd_parcelas and
                        moetaxa.dativig <= titbsmoe.titdtemi
                        no-lock no-error.
                    wfrel.taxa = if not avail moetaxa then 2 else moetaxa.taxa.
                    wfrel.vlrtaxa = round(titbsmoe.titvlcob * wfrel.taxa
                                          / 100,2).
                    wfrel.vlrliquido = titbsmoe.titvlcob - wfrel.vlrtaxa.
                end.

                find first ttresumo where ttresumo.etbcobra = titulo.etbcobra
                                      and ttresumo.data     = titpag.cxmdata
                                      and ttresumo.moecod   = titpag.moecod
                                    no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcobra = titulo.etbcobra 
                       ttresumo.data     = titpag.cxmdata 
                       ttresumo.moecod   = titpag.moecod 
                       ttresumo.titvlpag = ttresumo.titvlpag + titpag.titvlpag.

                find first ttresumo where ttresumo.etbcobra = 0
                                      and ttresumo.data     = ?
                                      and ttresumo.moecod   = titpag.moecod
                                    no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcobra = 0
                       ttresumo.data     = ?
                       ttresumo.moecod   = titpag.moecod 
                       ttresumo.titvlpag = ttresumo.titvlpag + titpag.titvlpag.
            end.
        end.
    end.
end.

if vdestino
then run arquivo.
else run relatorio.


procedure relatorio.

def var tot_estab   like titpag.titvlpag.
def var tot_total   like titpag.titvlpag.
def var tot_dia     like titpag.titvlpag.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relmoetef." + string(mtime).
else varquivo = "..~\relat~\relmoetef." + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
            &Page-Size = "64"  
            &Cond-Var  = "150" 
            &Page-Line = "66" 
            &Nom-Rel   = ""RELMOETEF"" 
            &Nom-Sis   = """SISTEMA FINANCEIRO""" 
            &Tit-Rel   = """ relatorio de bandeiras """ 
            &Width     = "150"
            &Form      = "frame f-cabcab"}
disp
    vEstab  colon 31 label "Todos Estabelecimentos.."
    cestab  no-label
    vmoeda  colon 31  label "Todos as Moedas........."
    cmoeda  no-label skip 
    vdata1  colon 31 label "Periodo"
    vdata2  label "ate"  skip
    par-operacao[frame-index]  no-label  format "x(20)" at 10    
    with frame fparaopcoes side-label width 80.

for each wfrel no-lock,
    titulo where recid(titulo) = wfrel.rec_titulo no-lock,
    titpag where recid(titpag) = wfrel.rec_titpag no-lock
                        break by titulo.etbcobra
                              by titpag.cxmdata
                              by wfrel.rec_titulo
                              by titulo.titpar.

    if first-of(titulo.etbcobra)
    then do.
        find estab where estab.etbcod = titulo.etbcobra no-lock.
        display estab.etbcod label "Estabelecimento"
                estab.etbnom no-label
                with frame flin_estab side-label.
    end. 
    find moeda of titpag no-lock.
    find clien where clien.clicod = titulo.clifor no-lock no-error.

    display 
        titpag.cxmdata when first-of(wfrel.rec_titulo) column-label "Data"
                        format "99/99/99"
        titulo.etbcod  when first-of(wfrel.rec_titulo) column-label "Etb"
                        format ">>9"
        if first-of(wfrel.rec_titulo)
        then trim(titulo.titnum + "/" + string(titulo.titpar)) 
        else "" @ titulo.titnum format "x(15)"
        titulo.clifor when first-of(wfrel.rec_titulo)
        clien.clinom  when avail clien
        titpag.moecod 
        moeda.moenom
        titpag.titvlpag column-label "Vlr Operacao" format ">>>,>>9.99"
        wfrel.operacao label "Operacao" format "x(12)"
        wfrel.carvan label "Van"
        wfrel.qtd_parcelas label "Parc" format ">>>9"
        wfrel.titvlmer   column-label "Merc"    format ">>>>>9.99"
        wfrel.vlrtaxa    column-label "Taxa"
        wfrel.vlrLiquido column-label "Liquido" format ">>>>>9.99"
        with frame flin width 200 down.
    down with frame flin.

    tot_estab = tot_estab + titpag.titvlpag.
    tot_dia   = tot_dia   + titpag.titvlpag.
    tot_total = tot_total + titpag.titvlpag.
    if last-of(titpag.cxmdata)
    then do.
        /*
        display "----------------" @ titpag.titvlpag
                with frame flin.
        down with frame flin.
        display "Total dia " + string(titpag.cxmdata)    @ clien.clinom
                tot_dia @ titpag.titvlpag
                with frame flin.
        down 2 with frame flin.
        */
        tot_dia = 0.
        put skip(1)
            "*******  R E S U M O   " at 50 titpag.cxmdata "*******" 
            skip.
        for each ttresumo where ttresumo.etbcobra = titulo.etbcobra and
                                ttresumo.data     = titpag.cxmdata.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlpag column-label "Valor Operacao" (total)
                    with frame fresumodia down width 200.
            down with frame fresumodia. 
        end.
    end.
    if last-of(titulo.etbcobra)
    then do.
        /*
        display "----------------" @ titpag.titvlpag
                with frame flin.
        down with frame flin.
        display "Total " + estab.etbnom    @ clien.clinom
                tot_estab @ titpag.titvlpag
                with frame flin.
        down with frame flin.*/
        tot_estab = 0.
        put skip(1)
            "*******  R E S U M O   " at 50 estab.etbnom 
                                            "*******" 
            skip.
        for each ttresumo where ttresumo.etbcobra = titulo.etbcobra.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlpag column-label "Valor Operacao" (total)
                    with frame fresumo down width 200.
            down with frame fresumo. 
        end.
    end.
    if last(titulo.etbcobra)
    then do.
        /*
        down 2 with frame flin.
        display 
                "----------------" @ titpag.titvlpag
                with frame flin.
        down with frame flin.
        display "Total Geral"      @ clien.clinom
                tot_total @ titpag.titvlpag
                with frame flin.
        down with frame flin.
        tot_estab = 0.
        */
        put skip(1)
            "*****************************************" at 50
            "*******  R E S U M O   G E R A L  " at 50
                                            "*******" 
            "*****************************************"   at 50
            skip.
        for each ttresumo where ttresumo.etbcobra = 0.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlpag column-label "Valor Operacao" (total)
                    with frame fresumogeral down width 200.
            down with frame fresumogeral. 
        end.
    end.
end.

output close.

if opsys = "UNIX"
then do:
    run visurel.p(varquivo,"").
end.
else do:
    {mrod.i}
end.

end procedure.


procedure arquivo.

    def var vp as char init ";".

    varquivo = "/admcom/relat/relmoetef" + string(today,"999999") + "_" +
               string(time) + ".csv".

    hide message no-pause.

    output to value(varquivo).

put unformatted
    "Data"
    vp "Estab"
    vp "Titulo"
    vp "Clifor"
    vp "Nome"
    vp "Codigo Moeda"
    vp "Nome Moeda"
    vp "Vlr Operacao"
    vp "Operacao"
    vp "Van"
    vp "Parc"
    vp "Merc"
    vp "Taxa"
    vp "Liquido"
    vp skip.

for each wfrel no-lock,
    titulo where recid(titulo) = wfrel.rec_titulo no-lock,
    titpag where recid(titpag) = wfrel.rec_titpag no-lock
                        break by titulo.etbcobra
                              by titpag.cxmdata
                              by wfrel.rec_titulo
                              by titulo.titpar.

    find moeda of titpag no-lock.
    find clien where clien.clicod = titulo.clifor no-lock no-error.

    put unformatted
        titpag.cxmdata
        vp titulo.etbcod
        vp trim(titulo.titnum + "/" + string(titulo.titpar)) 
        vp titulo.clifor
        vp if avail clien then clien.clinom else ""
        vp titpag.moecod 
        vp moeda.moenom
        vp titpag.titvlpag
        vp wfrel.operacao
        vp wfrel.carvan
        vp wfrel.qtd_parcelas
        vp wfrel.titvlmer
        vp wfrel.vlrtaxa
        vp wfrel.vlrLiquido
        vp skip.
end.

    output close.
    
    message "Gerado arquivo:" varquivo view-as alert-box.

end procedure.
