/*  relband.p                1                                             */
/*  Helio Alves - 12/2017                                              */

{admcab.i}
def input param par-agrupamento as char.
def input param par-tipodata    as char.
def input param par-tiposaida   as char.

def var vp as char init ";".

{filtro-estab.def}
{filtro-moeda.def}

def var varquivo as char.
def var vdata as date.
def var vdata1 as date init today.
def var vdata2 as date init today.  

def var vsintetico as log format "Sintetico/Analitico".
def var vpordia    as log format "Sim/Nao".

def var par-operacao as char format "x(20)" extent 4
    init [" Geral ", " Venda " , " Pagamento Prestacao "," Entrada "].

if par-tiposaida = "CSV"
then do:
    vsintetico = no.
    vpordia    = no.
end.

form
    vEstab   colon 31 label "Todos Estabelecimentos.."
    cestab   no-label
    vmoeda  colon 31  label "Todos as Moedas........."
    cmoeda  no-label skip (1)
    par-tipodata colon 31 label "Tipo de Periodo"
    skip (1)
    vdata1   colon 31 label "Periodo"
    vdata2   label "ate"  skip(1)
    vsintetico colon 31 label "Sintetico/Analitico"
    vpordia    colon 31 label "Total por dia?"
    
    par-operacao[1]  no-label  format "x(10)" at 10
    par-operacao[2]  no-label  format "x(10)"
    par-operacao[3]  no-label  format "x(22)"
    par-operacao[4]  no-label  format "x(10)"

    
    with frame fopcoes row 3 side-label width 80
    title " Cartoes de Credito  - " + par-agrupamento + " - " +
            par-tipodata + " - " + par-tiposaida.


do on error undo.
    vestab  = yes.
    {filtro-estab.i}
    do on error undo.
        vmoeda = yes.
        {filtro-moeda_tef.i} 
        do on error undo.
            disp par-tipodata with frame fopcoes.
            update vdata1 vdata2 with frame fopcoes.
            disp vsintetico
                 vpordia
                with frame fopcoes.
            update vsintetico when par-tiposaida <> "CSV"
                with frame fopcoes.
                
            update vpordia when par-tiposaida <> "CSV"
                            with frame fopcoes.
            do on error undo.
                display par-operacao
                        with frame fopcoes.
                choose field par-operacao with frame fopcoes.
            end.
        end.
    end.
end.

def temp-table wfrel no-undo
    field rec as recid
    field etbcod like titbsmoe.etbcod
    field mevcod like moeband.mevcod
    field data   like titbsmoe.titdtemi
    field titnum like titbsmoe.titnum
    field titpar like titbsmoe.titpar
    field operacao as char
    field titvlmer as dec
    field taxa  like moetaxa.taxa
    field vlrtaxa as dec format "->>,>>9.99" decimals 2
    field vlrliquido as dec
    index x etbcod asc data asc titnum asc titpar asc
    index y mevcod asc data asc titnum asc titpar asc.

    
def var voperacao   as char.

for each wfrel.
    delete wfrel.
end.    
def temp-table ttresumo no-undo
    field etbcod   like titbsmoe.etbcod  
    field data     like titbsmoe.titdtemi  
    field mevcod   like moeband.mevcod 
    field meboper  like moeband.meboper
    field moecod   like titbsmoe.moecod  
    field titvlcob like titbsmoe.titvlcob 
    field titvlmer as dec
    field titvljur like titbsmoe.titvljur format "->>,>>9.99"
    field vlrtaxa  as dec label "Vlr Taxa"
        format "->>,>>9.99" decimals 2
    field vlrliquido  as dec label "Vl Liquido"
    index x is unique primary
        etbcod asc
        data   asc
        mevcod  asc
        meboper asc
        moecod  asc.
    
for each ttresumo.
    delete ttresumo.
end.
hide message no-pause.
message "Aguarde....".
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
    for each wfmoeda.
        
        do vdata = vdata1 to vdata2.
        
            if par-tipodata = "EMISSAO"
            then  for each titbsmoe where
                titbsmoe.empcod  = 19 and
                titbsmoe.titnat = no and
                titbsmoe.modcod     = "CAR" and
                titbsmoe.etbcod     = estab.etbcod and
                titbsmoe.titdtemi   = vdata and
                titbsmoe.moecod     = wfmoeda.moecod
                no-lock.
                
                find first moeband where 
                        moeband.moecod = titbsmoe.moecod no-lock.
                
                voperacao = "Venda".    
                find first pdvmoeda of titbsmoe no-lock no-error.
                if avail pdvmoeda
                then do:
                    find first pdvmov of pdvmoeda no-lock no-error.
                    if avail pdvmov
                    then do:
                        find first pdvdoc of pdvmov no-lock no-error.
                        if avail pdvdoc
                        then do:
                            if pdvdoc.titcod <> ?
                            then voperacao = "Pagamento Prestacao".
                            else do:
                                if pdvdoc.crecod = 2
                                then voperacao = "Entrada".
                                else voperacao = "Venda".
                            end.      
                        end.
                    end.
                end.                 
                
                if frame-index = 1
                then .
                else do.
                    if frame-index = 2 and
                       voperacao <> "Venda"
                    then next.   
                    if frame-index = 3 and
                        voperacao <> "Pagamento Prestacao"
                    then next.   
                    if frame-index = 4 and
                        voperacao <> "Entrada"
                    then next.   
                end.
        
                create wfrel.
                assign wfrel.rec = recid(titbsmoe).
                assign
                    wfrel.mevcod = moeband.mevcod
                    wfrel.etbcod = titbsmoe.etbcod
                    wfrel.data   = titbsmoe.titdtemi
                    wfrel.titnum = titbsmoe.titnum
                    wfrel.titpar = titbsmoe.titpar.
                wfrel.operacao   = voperacao.
            end.
            if par-tipodata = "VENCIMENTO"
            then  for each titbsmoe where
                titbsmoe.empcod  = 19 and
                titbsmoe.titnat = no and
                titbsmoe.modcod     = "CAR" and
                titbsmoe.etbcod     = estab.etbcod and
                titbsmoe.titdtven   = vdata and
                titbsmoe.moecod     = wfmoeda.moecod
                no-lock.
                
                find first moeband where
                    moeband.moecod = titbsmoe.moecod no-lock.
                    
                voperacao = "Venda".    
                find first pdvmoeda of titbsmoe no-lock no-error.
                if avail pdvmoeda
                then do:
                    find first pdvmov of pdvmoeda no-lock no-error.
                    if avail pdvmov
                    then do:
                        find first pdvdoc of pdvmov no-lock no-error.
                        if avail pdvdoc
                        then do:
                            if pdvdoc.titcod <> ?
                            then voperacao = "Pagamento Prestacao".
                            else do:
                                if pdvdoc.crecod = 2
                                then voperacao = "Entrada".
                                else voperacao = "Venda".
                            end.      
                        end.
                    end.
                end.                 
                
                if frame-index = 1
                then .
                else do.
                    if frame-index = 2 and
                       voperacao <> "Venda"
                    then next.   
                    if frame-index = 3 and
                        voperacao <> "Pagamento Prestacao"
                    then next.   
                    if frame-index = 4 and
                        voperacao <> "Entrada"
                    then next.   
                end.
        
                create wfrel.
                assign wfrel.rec = recid(titbsmoe).
                assign
                    wfrel.mevcod = moeband.mevcod
                    wfrel.etbcod = titbsmoe.etbcod
                    wfrel.data   = titbsmoe.titdtven
                    wfrel.titnum = titbsmoe.titnum
                    wfrel.titpar = titbsmoe.titpar.
                wfrel.operacao   = voperacao.
            end.
        end.
    end.
end.

hide message no-pause.
message "Calculando...".

for each wfrel.  
    find titbsmoe where recid(titbsmoe) = wfrel.rec no-lock.
    find moeband where moeband.moecod = titbsmoe.moecod no-lock.
    
    wfrel.titvlmer = titbsmoe.titvlcob - titbsmoe.titvljur.
    find last moetaxa where 
                        moetaxa.moecod = titbsmoe.moecod and
                        moetaxa.qtd_parcelas <= titbsmoe.qtd_parcelas and
                        moetaxa.dativig <= titbsmoe.titdtemi
                        no-lock no-error.
    wfrel.taxa = if not avail moetaxa
                             then 2
                             else moetaxa.taxa.
                wfrel.vlrtaxa = 
                    round(titbsmoe.titvlcob * wfrel.taxa / 100,2).
                wfrel.vlrliquido = titbsmoe.titvlcob - wfrel.vlrtaxa.                 
    if par-agrupamento = "ESTAB"
    then do:                 
                find first ttresumo where ttresumo.etbcod   = titbsmoe.etbcod
                                      and ttresumo.data = wfrel.data
                                      and ttresumo.mevcod = moeband.mevcod
                                      and ttresumo.meboper = moeband.meboper
                                      and ttresumo.moecod   = titbsmoe.moecod
                                          no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcod   = titbsmoe.etbcod 
                       ttresumo.data = wfrel.data 
                       ttresumo.mevcod  = moeband.mevcod
                       ttresumo.meboper = moeband.meboper
                       ttresumo.moecod   = titbsmoe.moecod 
                       ttresumo.titvlcob = ttresumo.titvlcob + 
                                        titbsmoe.titvlcob.
                       ttresumo.titvlmer = ttresumo.titvlmer + 
                                        wfrel.titvlmer.
                       ttresumo.titvljur = ttresumo.titvljur + 
                                        titbsmoe.titvljur.
                       ttresumo.vlrtaxa = ttresumo.vlrtaxa + 
                                        wfrel.vlrtaxa.
                       ttresumo.vlrliquido = ttresumo.vlrliquido + 
                                        wfrel.vlrliquido.

                  
                find first ttresumo where ttresumo.etbcod   = titbsmoe.etbcod
                                      and ttresumo.data = ?
                                      and ttresumo.mevcod   = moeband.mevcod
                                      and ttresumo.meboper  = moeband.meboper
                                      and ttresumo.moecod   = titbsmoe.moecod
                                          no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcod   = titbsmoe.etbcod 
                       ttresumo.data = ?
                       ttresumo.mevcod   = moeband.mevcod 
                       ttresumo.meboper  = moeband.meboper
                       ttresumo.moecod   = titbsmoe.moecod 
                       ttresumo.titvlcob = ttresumo.titvlcob + 
                                        titbsmoe.titvlcob.
                       ttresumo.titvlmer = ttresumo.titvlmer + 
                                        wfrel.titvlmer.
                                        
                       ttresumo.titvljur = ttresumo.titvljur + 
                                        titbsmoe.titvljur.
                       ttresumo.vlrtaxa = ttresumo.vlrtaxa + 
                                        wfrel.vlrtaxa.
                       ttresumo.vlrliquido = ttresumo.vlrliquido + 
                                        wfrel.vlrliquido.

    end.
    if par-agrupamento = "VAN"
    then do:
   
                find first ttresumo where ttresumo.etbcod   = 0
                                      and ttresumo.data = wfrel.data
                                      and ttresumo.mevcod = moeband.mevcod
                                      and ttresumo.meboper = moeband.meboper
                                      and ttresumo.moecod   = titbsmoe.moecod
                                          no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcod   = 0
                       ttresumo.data = wfrel.data 
                       ttresumo.mevcod  = moeband.mevcod
                       ttresumo.meboper = moeband.meboper
                       ttresumo.moecod   = titbsmoe.moecod 
                       ttresumo.titvlcob = ttresumo.titvlcob + 
                                        titbsmoe.titvlcob.
                       ttresumo.titvlmer = ttresumo.titvlmer + 
                                        wfrel.titvlmer.
                       ttresumo.titvljur = ttresumo.titvljur + 
                                        titbsmoe.titvljur.
                       ttresumo.vlrtaxa = ttresumo.vlrtaxa + 
                                        wfrel.vlrtaxa.
                       ttresumo.vlrliquido = ttresumo.vlrliquido + 
                                        wfrel.vlrliquido.

                       find first ttresumo where ttresumo.etbcod   = 0
                                      and ttresumo.data = ?
                                      and ttresumo.mevcod = moeband.mevcod
                                      and ttresumo.meboper = moeband.meboper
                                      and ttresumo.moecod   = titbsmoe.moecod
                                          no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcod   = 0
                       ttresumo.data = ?
                       ttresumo.mevcod  = moeband.mevcod
                       ttresumo.meboper = moeband.meboper
                       ttresumo.moecod   = titbsmoe.moecod 
                       ttresumo.titvlcob = ttresumo.titvlcob + 
                                        titbsmoe.titvlcob.
                       ttresumo.titvlmer = ttresumo.titvlmer + 
                                        wfrel.titvlmer.
                       ttresumo.titvljur = ttresumo.titvljur + 
                                        titbsmoe.titvljur.
                       ttresumo.vlrtaxa = ttresumo.vlrtaxa + 
                                        wfrel.vlrtaxa.
                       ttresumo.vlrliquido = ttresumo.vlrliquido + 
                                        wfrel.vlrliquido.

                   
    
    end.
    
                find first ttresumo where ttresumo.etbcod   = 0 
                                      and ttresumo.data = ? 
                                      and ttresumo.mevcod = moeband.mevcod
                                      and ttresumo.meboper = moeband.meboper
                                      and ttresumo.moecod   = ""
                                          no-error.
                if not avail ttresumo 
                then create ttresumo. 
                assign ttresumo.etbcod   = 0
                       ttresumo.data = ?
                       ttresumo.mevcod   = moeband.mevcod
                       ttresumo.meboper  = moeband.meboper
                       ttresumo.moecod   = ""
                       ttresumo.titvlcob = ttresumo.titvlcob + 
                            titbsmoe.titvlcob.             
                       ttresumo.titvlmer = ttresumo.titvlmer + 
                                        wfrel.titvlmer.
                       ttresumo.titvljur = ttresumo.titvljur + 
                                        titbsmoe.titvljur.
                       ttresumo.vlrtaxa = ttresumo.vlrtaxa + 
                                        wfrel.vlrtaxa.
                       ttresumo.vlrliquido = ttresumo.vlrliquido + 
                                        wfrel.vlrliquido.
            
end.
 


def var tot_estab   like titbsmoe.titvlcob.
def var tot_total   like titbsmoe.titvlcob.
def var tot_dia     like titbsmoe.titvlcob.

if par-tiposaida = "RELAT"
then do:

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relband" + 
                                string(today,"999999") + "_" +
                                string(time) + ".txt".
    else varquivo = "..~\relat~\relband" + 
                                string(today,"999999") + "_" +
                                string(time) + ".txt".

    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "0"  
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RELBAND"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
        &Tit-Rel   = """ CARTOES DE CREDITO - POR "" + 
                string(PAR-agrupamento) + "" - "" +
                string(par-tipodata)  
                        + "" DE: "" +
                        string(vdata1,""99/99/9999"") + 
                      "" ATE "" + string(vdata2,""99/99/9999"") " 

                &Width     = "150"
                &Form      = "frame f-cabcab"}
    disp
        vEstab   colon 31 label "Todos Estabelecimentos.."
        cestab   no-label
        vmoeda  colon 31  label "Todos as Moedas........."
        cmoeda  no-label skip 
        par-tipodata 
            colon 31 label "Tipo de Relatorio"
        skip
        vdata1   colon 31 label "Periodo"
        vdata2   label "ate"  skip
        par-operacao[frame-index]  no-label  format "x(20)" at 10
        
        with frame fparaopcoes side-label width 80.


    if par-agrupamento = "ESTAB"
    then run porestab.

    if par-agrupamento = "VAN"
    then run porvan.


    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end. /* POR SAIDA = RELAT */

if par-tiposaida = "CSV"
then do:


    if opsys = "UNIX"
    then varquivo = "/admcom/relat/relband" + 
                                string(today,"999999") + "_" +
                                string(time) + ".csv".
    else varquivo = "..~\relat~\relband" + 
                                string(today,"999999") + "_" +
                                string(time) + ".csv".
    
    hide message no-pause.
 
    output to value(varquivo).
    
    if par-agrupamento = "ESTAB"
    then run csvporestab.

    if par-agrupamento = "VAN"
    then run csvporvan.

    output close.
    
    message "Gerado arquivo " varquivo.
    pause 2.
    

end.



procedure porestab.

for each wfrel,
    titbsmoe where recid(titbsmoe) = wfrel.rec no-lock
                        break by wfrel.etbcod
                              by wfrel.data
                              by wfrel.titnum
                              by wfrel.titpar.

    if first-of(wfrel.etbcod) 
    then do.
        find estab where estab.etbcod = wfrel.etbcod no-lock
            no-error.
        display titbsmoe.etbcod label "Estabelecimento"
                estab.etbnom when avail estab no-label
                with frame flin_estab side-label.
    end. 
    find moeda of titbsmoe no-lock.
    find moeband of moeda no-lock no-error.
    find clien where clien.clicod = titbsmoe.clifor no-lock no-error.
    if vsintetico = no
    then
    display 
         wfrel.data when first-of(wfrel.titnum)
                            column-label "Data"
         wfrel.etbcod when first-of(wfrel.titnum)
                                column-label "Estab"


         titbsmoe.clifor when first-of(wfrel.titnum)
         clien.clinom format "x(18)" when avail clien
         wfrel.operacao  label "Operacao" format "x(15)"
            (if titbsmoe.titpar > 0
             then trim(titbsmoe.titnum) + "/" +
                 string(titbsmoe.titpar) 
             else trim(titbsmoe.titnum))
             +
            (if titbsmoe.qtd_parcelas > 0
             then "_" + string(titbsmoe.qtd_parcelas)
             else "" )
                @ titbsmoe.titnum column-label "Cartao"
         titbsmoe.titdtven            
         titbsmoe.moecod column-label "Moe"
                    moeband.mevcod when avail moeband
                    moeband.mebcod when avail moeband
                    moeband.meboper when avail  moeband                        
                    wfrel.titvlmer   column-label "Merc"
                    titbsmoe.titvljur column-label "Juro"   
                        format "->>,>>9.99"
                    titbsmoe.titvlcob column-label "Valor" 
                    wfrel.vlrtaxa  column-label "Taxa"  
                    wfrel.vlrLiquido column-label "Liquido" 
         
         with frame flin width 200 down.
    down with frame flin.
    tot_estab = tot_estab + titbsmoe.titvlcob.
    tot_dia   = tot_dia   + titbsmoe.titvlcob.
    tot_total = tot_total + titbsmoe.titvlcob.
    
    if last-of(wfrel.data) and vpordia
    then do.
        tot_dia = 0.
        put unformatted skip(1)
            "*******  T O T A L  D O   D I A  " at 27 wfrel.data
                                            "*******" 
            skip.
        for each ttresumo where ttresumo.etbcod   = wfrel.etbcod and
                                ttresumo.data     = wfrel.data   and
                                ttresumo.moecod <> "".
            find moeda of ttresumo no-lock.
            find moeband of moeda no-lock no-error.
            display ttresumo.moecod  at 27
                    ttresumo.mevcod 
                    moeband.mebcod when avail moeband
                    ttresumo.meboper 
                    ttresumo.titvlmer column-label "Merc" (total)
                    ttresumo.titvljur column-label "Juro" 
                        format "->>,>>9.99" (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    with frame fresumodia down width 240.
            down with frame fresumodia. 
        end.
    end.
    if last-of(wfrel.etbcod)
    then do.
        tot_estab = 0.
        find estab where estab.etbcod = wfrel.etbcod no-lock no-error.
        
        if vsintetico and vpordia = no
        then.
        else  put unformatted skip(1)
            "*******  FILIAL  " at 5 (if avail estab
                                            then estab.etbnom 
                                            else string(wfrel.etbcod))
                       "**********************************************" 
            skip.
        for each ttresumo where ttresumo.etbcod = wfrel.etbcod and
                                ttresumo.data = ? and
                                ttresumo.moecod <> "".
            find moeda of ttresumo no-lock.
            find moeband of moeda no-lock no-error.
            display ttresumo.etbcod at 5
                    ttresumo.moecod 
                    ttresumo.mevcod 
                    moeband.mebcod when avail moeband
                    ttresumo.meboper
                    ttresumo.titvlmer column-label "Merc" (total)
                    
                    ttresumo.titvljur column-label "Juro"  
                        format "->>,>>9.99"
                        (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    with frame fresumo down width 210.
            down with frame fresumo. 
        end.
    end.
    if last(wfrel.etbcod)
    then do.
        put skip(3)
"*************************************************************************" at 1
"*************************************************************************" at 1
            
            "           R E S U M O   G E R A L  " at 1
"*************************************************************************" at 1
            skip.
        for each ttresumo where ttresumo.etbcod = 0 and
                                ttresumo.data   = ? and
                                ttresumo.moecod = "".
            display 
                    ttresumo.mevcod  at 1
                    ttresumo.meboper 
                    ttresumo.titvlmer column-label "Merc" (total)
                    ttresumo.titvljur column-label "Juro"  
                        format "->>,>>9.99"
                    (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    
                    with frame fresumogeral down width 210.
            down with frame fresumogeral. 
        end.

    end.


end.
end procedure.



procedure porvan.

for each wfrel,
    titbsmoe where recid(titbsmoe) = wfrel.rec no-lock
                        break by wfrel.mevcod
                              by wfrel.data
                              by wfrel.titnum
                              by wfrel.titpar.

    if first-of(wfrel.mevcod) 
    then do.
        display wfrel.mevcod label "VAN"
                with frame flin_estab side-label.
    end. 
    find moeda of titbsmoe no-lock.
    find moeband of moeda no-lock no-error.
    find clien where clien.clicod = titbsmoe.clifor no-lock no-error.
    if vsintetico = no
    then
    display 
         wfrel.data when first-of(wfrel.titnum)
                            column-label "Data"
         wfrel.etbcod when first-of(wfrel.titnum)
                                column-label "Estab"


         titbsmoe.clifor when first-of(wfrel.titnum)
         clien.clinom format "x(18)" when avail clien
         wfrel.operacao  label "Operacao" format "x(15)"
            (if titbsmoe.titpar > 0
             then trim(titbsmoe.titnum) + "/" +
                 string(titbsmoe.titpar) 
             else trim(titbsmoe.titnum))
             +
            (if titbsmoe.qtd_parcelas > 0
             then "_" + string(titbsmoe.qtd_parcelas)
             else "" )
                @ titbsmoe.titnum column-label "Cartao"
         titbsmoe.titdtven            
         titbsmoe.moecod column-label "Moe"
                    moeband.mevcod when avail moeband
                    moeband.mebcod when avail moeband
                    moeband.meboper when avail  moeband                        
                    wfrel.titvlmer   column-label "Merc"
                    titbsmoe.titvljur column-label "Juro"   
                        format "->>,>>9.99"
                    titbsmoe.titvlcob column-label "Valor" 
                    wfrel.vlrtaxa  column-label "Taxa"  
                    wfrel.vlrLiquido column-label "Liquido" 
         
         with frame flin width 200 down.
    down with frame flin.
    tot_estab = tot_estab + titbsmoe.titvlcob.
    tot_dia   = tot_dia   + titbsmoe.titvlcob.
    tot_total = tot_total + titbsmoe.titvlcob.
    
    if last-of(wfrel.data) and vpordia
    then do.
        tot_dia = 0.
        put unformatted skip(1)
            "*******  T O T A L  D O   D I A  " at 27 wfrel.data
                                            "*******" 
            skip.
        for each ttresumo where ttresumo.etbcod = 0 and
                                ttresumo.mevcod   = wfrel.mevcod and
                                ttresumo.data     = wfrel.data and
                                ttresumo.moecod <> "".
            find moeda of ttresumo no-lock.
            find moeband of moeda no-lock no-error.
            display ttresumo.moecod  at 27
                    ttresumo.mevcod 
                    moeband.mebcod when avail moeband
                    ttresumo.meboper 
      ttresumo.titvlmer column-label "Merc" (total)
                    ttresumo.titvljur column-label "Juro" 
                        format "->>,>>9.99"
                        (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    with frame fresumodia down width 240.
            down with frame fresumodia. 
        end.
    end.
    if last-of(wfrel.mevcod)
    then do.
        tot_estab = 0.

        /*find estab where estab.etbcod = wfrel.etbcod no-lock no-error.
        */
        
        if vsintetico and vpordia = no
        then.
        else  put unformatted skip(1)
            "*******  VAN  " at 5 wfrel.mevcod
                       "**********************************************" 
            skip.
        for each ttresumo where ttresumo.mevcod = wfrel.mevcod and
                                ttresumo.etbcod = 0 and
                                ttresumo.data = ? and
                                ttresumo.moecod <> "".
            find moeda of ttresumo no-lock.
            find moeband of moeda no-lock no-error.
            display ttresumo.etbcod at 5 when ttresumo.etbcod <> 0
                    ttresumo.moecod 
                    ttresumo.mevcod 
                    moeband.mebcod when avail moeband
                    ttresumo.meboper 
                    ttresumo.titvlmer column-label "Merc" (total)
                    
                    ttresumo.titvljur column-label "Juro"  
                        format "->>,>>9.99"
                    (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    with frame fresumo down width 210.
            down with frame fresumo. 
        end.
    end.
    if last(wfrel.mevcod)
    then do.
        put skip(3)
"*************************************************************************" at 1
"*************************************************************************" at 1
            
            "           R E S U M O   G E R A L  " at 1
"*************************************************************************" at 1
            skip.
        for each ttresumo where ttresumo.etbcod = 0 and
                                ttresumo.data   = ? and
                                ttresumo.moecod = "" .
            display 
                    ttresumo.mevcod  at 1
                    ttresumo.meboper
                   ttresumo.titvlmer column-label "Merc" (total)
                ttresumo.titvljur column-label "Juro" 
                    format "->>,>>9.99"
                 (total)
                    ttresumo.titvlcob column-label "Valor" (total)
                    ttresumo.vlrtaxa  column-label "Taxa"  (total)
                    ttresumo.vlrLiquido column-label "Liquido" (total)
                    
                    with frame fresumogeral down width 210.
            down with frame fresumogeral. 
        end.

    end.


end.
end procedure.


procedure csvporestab.


    put unformatted
         "Data" vp
         "Estab" vp
         "Clifor" vp
         "Nome" vp
         "Operacao" vp
         "Cartao" vp
         "parcela" vp
         "QtdParcelas" vp
         "Vencimento" vp
         "Moeda" vp
         "Van" vp
         "Bandeira" vp
         "TipoCartao" vp
         "Vlr Mercadoria" vp
         "Vlr Juro Venda" vp
         "Vlr Cobrado" vp
         "Vlr Taxa" vp
         "Vlr Liquido" 
         skip.


for each wfrel,
    titbsmoe where recid(titbsmoe) = wfrel.rec no-lock
                        break by wfrel.etbcod
                              by wfrel.data
                              by wfrel.titnum
                              by wfrel.titpar.

    find moeda of titbsmoe no-lock.
    find moeband of moeda no-lock no-error.
    find clien where clien.clicod = titbsmoe.clifor no-lock no-error.
    put unformatted
         wfrel.data   vp
         wfrel.etbcod  vp
                  titbsmoe.clifor vp
         (if avail clien
          then clien.clinom 
          else "") vp
         wfrel.operacao vp
         titbsmoe.titnum vp
         titbsmoe.titpar vp
                  titbsmoe.qtd_parcelas vp
         titbsmoe.titdtven            vp
         titbsmoe.moecod vp
         moeband.mevcod vp
         moeband.mebcod vp
         moeband.meboper vp
         wfrel.titvlmer vp
         titbsmoe.titvljur vp
         titbsmoe.titvlcob vp
         wfrel.vlrtaxa  vp
         wfrel.vlrLiquido vp
         skip.
     end.
end procedure.



procedure csvporvan.

    put unformatted
         "Data" vp
         "Estab" vp
         "Clifor" vp
         "Nome" vp
         "Operacao" vp
         "Cartao" vp
         "parcela" vp
         "QtdParcelas" vp
         "Vencimento" vp
         "Moeda" vp
         "Van" vp
         "Bandeira" vp
         "TipoCartao" vp
         "Vlr Mercadoria" vp
         "Vlr Juro Venda" vp
         "Vlr Cobrado" vp
         "Vlr Taxa" vp
         "Vlr Liquido" 
         skip.

for each wfrel,
    titbsmoe where recid(titbsmoe) = wfrel.rec no-lock
                        break by wfrel.etbcod
                              by wfrel.data
                              by wfrel.titnum
                              by wfrel.titpar.

    find moeda of titbsmoe no-lock.
    find moeband of moeda no-lock no-error.
    find clien where clien.clicod = titbsmoe.clifor no-lock no-error.
         put unformatted
         wfrel.data   vp
         wfrel.etbcod  vp
                  titbsmoe.clifor vp
         (if avail clien
          then clien.clinom 
          else "") vp
         wfrel.operacao vp
         titbsmoe.titnum vp
         titbsmoe.titpar vp
                  titbsmoe.qtd_parcelas vp
         titbsmoe.titdtven            vp
         titbsmoe.moecod vp
         moeband.mevcod vp
         moeband.mebcod vp
         moeband.meboper vp
         wfrel.titvlmer vp
         titbsmoe.titvljur vp
         titbsmoe.titvlcob vp
         wfrel.vlrtaxa  vp
         wfrel.vlrLiquido vp
         skip.
     end.
end procedure.

