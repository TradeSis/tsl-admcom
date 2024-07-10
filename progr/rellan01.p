/***************************** rellan01.p *****************/
{admcab.i new}
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

    
    for each lancxa use-index ind-3 where lancxa.cxacod <> 0 and
                                          lancxa.datlan >= vdti and
                                          lancxa.datlan <= vdtf and
                                          lancxa.lantip <> "X"
                                          no-lock
                                            break by lancxa.lantip:

        /*if modcod <> "FON" then next.
        */
        find tablan where tablan.lancod = lancxa.lancod no-lock no-error.
        find forne where forne.forcod   = lancxa.forcod no-lock no-error.

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
                lancxa.lancod
                /*tablan.landeb*/ column-label "Debito" 
                /*when avail tablan*/
                lancxa.cxacod
                /*tablan.lancre*/ column-label "Credito" 
                /*when avail tablan*/
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
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end.



