/*  relmoetef.p                                                             */
/*  Helio Alves - 26/06/2015                                              */
{admcab.i }
{filtro-estab.def}
{filtro-moeda.def}


/**/
def var vframe-index as int init 1.
def var ntitdtven as date.
def var vparcelas as int.
def var vvalortot as dec.
def var vtitvlcob as dec.
def var vtotal as dec.
def var vultima as dec.
def var vtitdtven as date.
def var vdia as int.
def var vmes as int.
def var vano as int.

def var vi as int.

def var varquivo as char.
def var vdata as date.
def var vdata1 as date init today.
def var vdata2 as date init today.  

def var par-operacao as char format "x(20)" extent 4
    init [" GERAL ", " Venda " , " Pagamento Prestacao "," Entrada "].


form
    vEstab   colon 31 label "Todos Estabelecimentos.."
    cestab   no-label
    vmoeda  colon 31  label "Todos as Moedas........."
    cmoeda  no-label skip (1)
    vdata1   colon 31 label "Vencimentos"
    vdata2   label "ate"  skip(1)
    par-operacao[1]  no-label  format "x(10)" at 10
    par-operacao[2]  no-label  format "x(10)"
    par-operacao[3]  no-label  format "x(22)"
    par-operacao[4]  no-label  format "x(10)"
    
    with frame fopcoes row 3 side-label width 80.
def var vx as int.
form
    vx
    titulo.etbcobra
    with frame fmostra
        1 down row 16 centered no-box no-labels.
        
do on error undo.
    vestab  = yes.
    {filtro-estab.i}
    do on error undo.
        vmoeda = yes.
        {filtro-moeda_tef.i} 
        do on error undo.
            update vdata1 vdata2 with frame fopcoes.
            do on error undo.
                display par-operacao
                        with frame fopcoes.
                choose field par-operacao with frame fopcoes.
                vframe-index = frame-index. 
            end.
        end.
    end.
end.

def temp-table wfrel
    field rec_titulo as recid
    field rec_titpag as recid
    field titpar     like titpag.titpar
    field titdtven   like titulo.titdtven
    field titvlcob   like titulo.titvlcob
    index par is unique primary rec_titulo rec_titpag titpar.
    
def var voperacao   as char.

for each wfrel.
    delete wfrel.
end.    
def temp-table ttresumo
    field etbcobra like titulo.etbcobra  
    field titdtven like titulo.titdtven  
    field Ano      as int format "9999"
    field Mes      as int format "99"
    field moecod   like titpag.moecod  
    field titvlcob like wfrel.titvlcob 
    index res is unique primary etbcobra moecod titdtven ano mes.
def buffer bttresumo for ttresumo.
    
for each ttresumo.
    delete ttresumo.
end.

def var vanalitico as log format "Analitico/Sintetico".
/*
message "Relatorio Analitico ou Sintetico (A/S) ?" update vanalitico.
*/
vanalitico = no.

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
    /*do vdata = vdata1 to vdata2.*/
    vx = 0.
    do vdata = 06/01/2015 to today.
    
        for each titulo where titulo.etbcobra = estab.etbcod and
                              titulo.titdtpag = vdata
                              no-lock.
                              
            voperacao = if titulo.titpar = 0
                        then "Entrada"
                        else 
                        if titulo.modcod = "VVI"
                        then "Venda"
                        else "Pagamento Prestacao".
            if vframe-index = 1
            then .
            else do.
                if vframe-index = 2 and
                   voperacao <> "Venda"
                then next.   
                if vframe-index = 3 and
                   voperacao <> "Pagamento Prestacao"
                then next.   
                if vframe-index = 4 and
                   voperacao <> "Entrada"
                then next.   
            end.
            for each titpag where titpag.empcod = titulo.empcod and
                                  titpag.titnat = titulo.titnat and
                                  titpag.modcod = titulo.modcod and
                                  titpag.etbcod = titulo.etbcod and
                                  titpag.clifor = titulo.clifor and
                                  titpag.titnum = titulo.titnum and
                                  titpag.titpar = titulo.titpar no-lock.
       
                pause 0 .
                vx = vx + 1.
                disp    
                        vx
                        titulo.etbcobra
                        with frame fmostra.
                
                find first wfmoeda where wfmoeda.moecod = titpag.moecod
                                        no-error.
                if not avail wfmoeda
                then next.

                vparcelas = int(acha("PARCELASCARTAO",TITPAG.TITOBS[1])).
                
                if vparcelas = ? then vparcelas = 1.
                vvalortot = titpag.titvlpag.
                vtitvlcob = round(vvalortot / vparcelas,2).
                
                vtotal = round(vtitvlcob * vparcelas,2).
                if vvalortot > vtotal 
                then vultima = vtitvlcob + (vvalortot - vtotal).
                else vultima = vtitvlcob - (vtotal - vvalortot).
                vdia = day(titulo.titdtven).
                vtitdtven = titulo.titdtven.
                                
                do vi = 1 to vparcelas:
 
                    vmes = month(vtitdtven) + vi.
                    if vmes > 12 
                    then assign
                                vmes = vmes - 12
                                vano = year(vtitdtven) + 1.
                    else assign
                                vano = year(vtitdtven).
                    if vdia = 31 and (vmes = 2 or
                                      vmes = 4 or
                                      vmes = 6 or
                                      vmes = 9 or
                                      vmes = 11)
                    then vdia = 30.
                    if vdia > 28 and vmes = 2 then vdia = 28.
                    
                    ntitdtven = date(vmes,vdia,vano).
                    if titpag.moecod = "TDB" and
                       weekday(ntitdtven) = 7
                    then ntitdtven = ntitdtven + 2.
                    
                    if titpag.moecod = "TDB" and
                       weekday(ntitdtven) = 8
                    then ntitdtven = ntitdtven + 1.
                    
                    if ntitdtven < vdata1 or
                       ntitdtven > vdata2
                    then next.      
                        
                    find first wfrel where
                            wfrel.rec_titulo = recid(titulo) and
                            wfrel.rec_titpag = recid(titpag) and
                            wfrel.titpar     = vi
                        no-error.
                    if not avail wfrel
                    then do:    
                        create wfrel.
                        assign wfrel.rec_titpag = recid(titpag)
                               wfrel.rec_titulo = recid(titulo)
                               wfrel.titpar     = vi.
                    end.                            
                    wfrel.titdtven = ntitdtven.
                    vano = year(ntitdtven).
                    vmes = month(ntitdtven).
                        
                    if vi = vparcelas
                    then wfrel.titvlcob = vultima.
                    else wfrel.titvlcob = vtitvlcob.
                    
                    
                    find first ttresumo where 
                                    ttresumo.etbcobra = titulo.etbcobra
                                and ttresumo.titdtven = wfrel.titdtven
                                and ttresumo.ano = vano
                                and ttresumo.mes = vmes
                                and ttresumo.moecod   = titpag.moecod
                                          no-error.
                    if not avail ttresumo 
                    then do:
                        create ttresumo. 
                        assign ttresumo.etbcobra = titulo.etbcobra 
                               ttresumo.titdtven     = wfrel.titdtven 
                               ttresumo.ano = vano
                               ttresumo.mes = vmes
                               ttresumo.moecod   = titpag.moecod .
                    end.                               
                    ttresumo.titvlcob = ttresumo.titvlcob + wfrel.titvlcob.

                    find first ttresumo where 
                                            ttresumo.etbcobra = titulo.etbcobra
                                          and ttresumo.titdtven     = ?
                                          and ttresumo.ano = vano
                                          and ttresumo.mes = vmes
                                          and ttresumo.moecod   = titpag.moecod
                                              no-error.
                    if not avail ttresumo 
                    then do:
                        create ttresumo. 
                        assign ttresumo.etbcobra = titulo.etbcobra.
                               ttresumo.titdtven     = ?.
                               ttresumo.ano = vano.
                               ttresumo.mes = vmes.
                               ttresumo.moecod   = titpag.moecod .
                    end.                               
                    ttresumo.titvlcob = ttresumo.titvlcob + wfrel.titvlcob.     
                    find first ttresumo where ttresumo.etbcobra = 0
                                          and ttresumo.titdtven     = ?
                                          and ttresumo.ano = vano
                                          and ttresumo.mes = vmes
                                          and ttresumo.moecod   = titpag.moecod
                                              no-error.
                    if not avail ttresumo 
                    then do:
                        create ttresumo. 
                        assign ttresumo.etbcobra = 0
                               ttresumo.titdtven     = ?
                               ttresumo.ano = vano
                               ttresumo.mes = vmes
                               ttresumo.moecod   = titpag.moecod .
                    end.                               
                    ttresumo.titvlcob = ttresumo.titvlcob + wfrel.titvlcob.                    end.         
            
            end.
        end.
    end.
end.

def var tot_estab   like titpag.titvlpag.
def var tot_total   like titpag.titvlpag.
def var tot_dia     like titpag.titvlpag.

if opsys = "UNIX"
then varquivo = "/admcom/relat/relventef." + string(time).
else varquivo = "..~\relat~\relventef." + string(time).
    
{mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "150" 
                &Page-Line = "66" 
                &Nom-Rel   = ""RELVENTEF"" 
                &Nom-Sis   = """SISTEMA FINANCEIRO""" 
                &Tit-Rel   = """ relatorio de bandeiras por VENCIMENTO """ 
                &Width     = "150"
                &Form      = "frame f-cabcab"}
disp
    vEstab   colon 31 label "Todos Estabelecimentos.."
    cestab   no-label
    vmoeda  colon 31  label "Todos as Moedas........."
    cmoeda  no-label skip 
    vdata1   colon 31 label "Vencimentos"
    vdata2   label "ate"  skip
    par-operacao[vframe-index]  no-label  format "x(20)" at 10
    
    with frame fparaopcoes side-label width 80.

if vanalitico
then do:

for each wfrel,
    titulo where recid(titulo) = wfrel.rec_titulo no-lock,
    titpag where recid(titpag) = wfrel.rec_titpag no-lock
                        break by titulo.etbcobra
                              by wfrel.titdtven
                              by wfrel.rec_titulo
                              by titulo.titpar .

    if first-of(titulo.etbcobra)
    then do.
        find estab where estab.etbcod = titulo.etbcobra no-lock.
        display estab.etbcod label "Estabelecimento"
                estab.etbnom no-label
                with frame flin_estab side-label.
    end. 
    find moeda of titpag no-lock.
    find clien where clien.clicod = titulo.clifor no-lock no-error.
    voperacao = if titulo.titpar = 0
                then "Entrada"
                else 
                if titulo.modcod = "VVI"
                then "Venda"
                else "Pagamento Prestacao".
    display 
         wfrel.titdtven when first-of(wfrel.titdtven)
                            column-label "Data Vencimento"
         titulo.etbcod when first-of(wfrel.rec_titulo)
                                column-label "Estab"
         titulo.titdtemi                       
         if first-of(wfrel.rec_titulo)
         then trim(titulo.titnum + "/" + string(wfrel.titpar)) 
         else "" @ titulo.titnum
                                format "x(15)"
/*         titulo.modcod when first-of(wfrel.rec_titulo)*/
         titulo.clifor when first-of(wfrel.rec_titulo)
         clien.clinom when avail clien
         titpag.moecod 
         moeda.moenom
         wfrel.titvlcob column-label "Valor Recebiveis"
         voperacao  label "Operacao" format "x(20)"
         with frame flin width 200 down.
    down with frame flin.
    tot_estab = tot_estab + wfrel.titvlcob.
    tot_dia   = tot_dia   + wfrel.titvlcob.
    tot_total = tot_total + wfrel.titvlcob.
    if last-of(wfrel.titdtven)
    then do.
        tot_dia = 0.
        put skip(1)
            "*******  R E S U M O   " at 50 wfrel.titdtven
                                            "*******" 
            skip.
        for each ttresumo where ttresumo.etbcobra = titulo.etbcobra and
                                ttresumo.titdtven = wfrel.titdtven.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlcob column-label "Valor Recebiveis " (total)
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
        for each ttresumo where ttresumo.etbcobra = titulo.etbcobra
                             and ttresumo.titdtven = ?.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlcob column-label "Valor Recebiveis" (total)
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
        for each ttresumo where ttresumo.etbcobra = 0 and
                                ttresumo.titdtven = ?.
            find moeda of ttresumo no-lock.
            display ttresumo.moecod  at 50
                    moeda.moenom
                    ttresumo.titvlcob column-label "Valor Recebiveis" (total)
                    with frame fresumogeral down width 200.
            down with frame fresumogeral. 
        end.

    end.


end.
end.

else do: /* sintetico*/

/*
for each ttresumo where ttresumo.etbcobra <> 0
                    and ttresumo.titdtven <> ?
        break by ttresumo.etbcobra
              by ttresumo.moecod
              by ttresumo.ano
              by ttresumo.mes
              by ttresumo.titdtven.

    if first-of(ttresumo.etbcobra)
    then do.
        find estab where estab.etbcod = ttresumo.etbcobra no-lock.
        display estab.etbcod label "Estabelecimento"
                estab.etbnom no-label
                with frame flin_estab2 side-label.
    end. 

            find moeda of ttresumo no-lock.
            display 
                    ttresumo.moecod  at 10 when first-of(ttresumo.moecod)
                    moeda.moenom when first-of(ttresumo.moecod)
                    /*
                    ttresumo.ano 
                    ttresumo.mes
                    */
                    ttresumo.titdtven
                    ttresumo.titvlcob column-label "Valor Recebiveis " 
                            (total by ttresumo.moecod)
                    with frame fresumodia2 down width 200.
            down with frame fresumodia2. 

    if last-of(ttresumo.etbcobra)
    then do.
        find estab where estab.etbcod = ttresumo.etbcobra no-lock.
        tot_estab = 0.
        put skip(1)
            "*******  R E S U M O   " at 10 estab.etbnom 
                                            "*******" 
            skip.
        for each bttresumo where bttresumo.etbcobra = ttresumo.etbcobra
                             and bttresumo.titdtven = ?
                             break by bttresumo.moecod
                                   by bttresumo.ano
                                   by bttresumo.mes.
            find moeda of bttresumo no-lock.
            display 
                    bttresumo.moecod 
                            at 10
                            when first-of(bttresumo.moecod)
                    moeda.moenom when first-of(bttresumo.moecod)
            
                    bttresumo.ano  
                    bttresumo.mes
                    bttresumo.titvlcob column-label "Valor Recebiveis" 
                        (total by bttresumo.moecod)
                    with frame fresumo2 down width 200.
            down with frame fresumo2. 
        end.
    
    end.

end.
*/

        put skip(1)
            "*******  R E S U M O   GERAL " at 10 
                                            "*******" 
            skip.

for each ttresumo where ttresumo.etbcobra = 0
                    and ttresumo.titdtven = ?
        break by ttresumo.etbcobra
              by ttresumo.moecod
              by ttresumo.ano
              by ttresumo.mes
              by ttresumo.titdtven.

            find moeda of ttresumo no-lock.
            display 
                    ttresumo.moecod  at 10
                        when first-of(ttresumo.moecod)
                    moeda.moenom when first-of(ttresumo.moecod)
            
                    ttresumo.ano  
                    ttresumo.mes
                    ttresumo.titvlcob column-label "Valor Recebiveis" 
                        (total by ttresumo.moecod)
                    with frame fresumo3 down width 200.
            down with frame fresumo3. 

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


