/***************************** rellan01.p *****************/
{admcab.i}
def var totdeb like lancxa.vallan.
def var totcre like lancxa.vallan.
def var desdup like plani.platot.
def var desalu like plani.platot.
def var totfor like plani.platot.
def var totjur like plani.platot.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.

def var vresp as l format "C/R" initial yes.
def var varquivo as char.

def temp-table tt-titulo like titulo.

for each estab no-lock:
    for each modal no-lock:
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = modal.modcod and
                 titulo.etbcod = estab.etbcod and
                 titulo.titdtven = 03/11/14  and
                 titulo.titdtpag = 03/11/14
                 no-lock:
            if titulo.modcod = "BON" or
                       titulo.modcod = "DEV" or
                                  titulo.modcod = "CHP" then next.
    
            create tt-titulo.
            buffer-copy titulo tot tt-titulo.
        end.
    end.
end.             
            
repeat:

    update vdti label "Periodo" 
           vdtf no-label with frame f1 width 80 side-label.
    
    if opsys = "UNIX"
   then varquivo = "../relat/lan" + STRING(day(today)) + string(day(vdti),"99")
        + string(time).
   else varquivo = "..\relat\lan" + STRING(day(today)) + string(day(vdti),"99").
     
    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""rellan01""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """LANCAMENTOS DE CAIXA  "" +
                          "" DE "" + string(vdti,""99/99/9999"") + "" ATE "" +
                                     string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    
    totfor = 0.
    totjur = 0.
    desalu = 0.
    desdup = 0.
    totdeb = 0.
    totcre = 0.

    for each tt-titulo no-lock,
        first forne where forne.forcod = titulo.clifor 
        no-lopck break by fornom:
        if first of(forne.fornom)
        then disp forne.forcod forne.fornom format "x(30)"
            with frame f-disp.
            
        disp tt-titulo.titnum
             tt-titulo.titpar
             tt-titulo.titdtemi
             tt-titulo.titdtven
             tt-titulo.titdtpag
             tt-titulo.titvlcob(total)
             tt-titulo.titvljur(total)
             tt-titulo.titvldes(total)
             tt-titulo.titvlpag(total)
             with frame f-disp down width 150
              .
        down with frame f-disp.      
        totfor = totfor + tt-titulo.titvlpag.
        totjur = totjur + tt-titulo.titvljur.
        totdes = totdes + tt-titulo.titvldes.
        
    end.

    /****
    for each lancxa use-index ind-3 where lancxa.cxacod <> 0 and
                                          lancxa.datlan >= vdti and
                                          lancxa.datlan <= vdtf and
                                          lancxa.lantip <> "X"
                                          no-lock
                                            break by lancxa.lantip:

        find tablan where tablan.lancod = lancxa.lancod no-lock no-error.
        find forne where forne.forcod   = lancxa.forcod no-lock no-error.

        if lancxa.lantip <> "D"
        then do:
            if lancxa.lanhis = 12 then next.
            if lancxa.lanhis = 13 then next.
        end.
        /*
        if lancxa.lanhis = 1
        then lancxa.comhis = lancxa.titnum + " " + forne.fornom.
          */
        
        if lancxa.lancod = 110
        then do:
            totjur = totjur + lancxa.vallan.
        end.
        
        if lancxa.lancod = 111
        then do:
            if forne.forcod = 100090
            then desalu = desalu + lancxa.vallan.
            else desdup = desdup + lancxa.vallan.
        end.

        if avail tablan and tablan.landeb = 30003
        then totfor = totfor + lancxa.vallan.
        
        display 
                "Juros " when lancxa.lancod = 110
                lancxa.lancod
                lancxa.lantip
                tablan.landeb column-label "Debito" when avail tablan
                tablan.lancre column-label "Credito" when avail tablan
                lancxa.lanhis 
                lancxa.comhis format "x(47)"
                forne.fornom when avail forne format "x(30)"
                lancxa.vallan with frame f2 down width 200.
        
        if lantip = "C" or lantip = ""
        then totcre = totcre + lancxa.vallan.
        else totdeb = totdeb + lancxa.vallan.
        
        if last-of(lancxa.lantip) 
        then do:
            put skip(1).
            if lancxa.lantip = "C"
            then put  totcre format "->,>>>,>>9.99" at 122 "   TOTAL " skip(2).
            else put  totdeb format "->,>>>,>>9.99"  
                                    at 122 "   TOTAL " skip(2).   
        end.
                        
    end.

    put (totcre - totdeb) format "->,>>>,>>9.99"
            at 122 "   DIFERENCA" skip(1).       

    
    display totfor format "->,>>>,>>9.99" label "Total Fornecedores" at 20
            totjur format "->,>>>,>>9.99" label "Total Juros       " at 20
            desdup format "->,>>>,>>9.99" label "Desconto Dup.     " at 20
            desalu format "->,>>>,>>9.99" label "Desconto Aluguel  " at 20
                with frame f-tot side-label width 200.


    output close.
    
    /*
    message "Consulta ou Relatorio" update vresp.
    if vresp
    then dos silent value("ved " + varquivo + " > prn").  
    else dos silent value("type " + varquivo + " > prn").  
    */
    ******/
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.


/***
def var vtotal as dec.
def var vpag as dec.
def var vlan as dec.
def temp-table tt-titulo like titulo.
for each estab no-lock:
    for each modal no-lock:
        for each titulo where
                 titulo.empcod = 19 and
                 titulo.titnat = yes and
                 titulo.modcod = modal.modcod and
                 titulo.etbcod = estab.etbcod and
                 titulo.titdtven = 03/11/14  and
                 titulo.titdtpag = 03/11/14
                 no-lock:

            vtotal = vtotal + titulo.titvlpag.
            if titsit = "PAG"
            then vpag = vpag + titulo.titvlpag.
            find first lancxa where
                       lancxa.datlan = 03/11/14 and
                       lancxa.titnum = titulo.titnum and
                       lancxa.forcod = titulo.clifor
                       no-lock no-error.
            if not avail lancxa
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                vlan = vlan + titulo.titvlpag.
            end.
                       
        end.
    end.
end.                  
               
disp vtotal format ">>>,>>>,>>9.99"     
     vpag   format ">>>,>>>,>>9.99"
     vtotal - vpag format ">>>,>>>,>>9.99"
     vlan format ">>>,>>>,>>9.99"
     .
          
output to /admcom/custom/Claudir/titulo-n-lanctb.csv.
for each tt-titulo no-lock.
find forne where forne.forcod = tt-titulo.clifor.
put tt-titulo.titnum  format "x(15)"
    ";"
     tt-titulo.titdtemi 
    ";" 
     tt-titulo.titdtven
    ";" 
     tt-titulo.titdtpag 
    ";"
     tt-titulo.titvlpag
    ";"
    forne.forcod
    ";"
    forne.fornom
     skip.
end.
output close.
*****/
