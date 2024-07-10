{admcab.i}

def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var vprocod like produ.procod.
 
def temp-table tt-icms
    field procod like produ.procod
    field dtini  like plani.pladat
    field dtfin  like plani.pladat
    field ativo  as log
        index ind-1 procod.






def temp-table tt-07
    field etbcod like estab.etbcod
    field cxacod like plani.cxacod
    field data   like plani.pladat
    field valor  like plani.platot.
    

def var val07 as dec.
def var icm07 as dec.



def var tot as dec.
def temp-table tt-caixa
    field cxacod like serial.cxacod.
def var i as i.


def var val11 as dec.
def var val12 as dec.
def var val15 as dec.
def var val18 as dec.
def var val19 as dec.
def var val21 as dec.


def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
def var t09 like plani.platot.

def var tg01 like plani.platot.
def var tg02 like plani.platot.
def var tg03 like plani.platot.
def var tg04 like plani.platot.
def var tg05 like plani.platot.
def var tg06 like plani.platot.
def var tg07 like plani.platot.
def var tg08 like plani.platot.
def var tg09 like plani.platot.


def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var v01 as char format "x(2)".
def var v02 as char format "x(8)".
def var v03 as char format "x(10)".
def var v04 as char format "x(4)".
def var v05 as char format "x(5)".
def var v06 as char format "x(5)".
def var v07 as char format "x(5)".
def var v08 as char format "x(21)".
def var v09 as char format "x(21)".
def var v10 as char format "x(21)".
def var v11 as char format "x(21)".
def var v12 as char format "x(21)".
def var v13 as char format "x(21)".
def var v14 as char format "x(21)".

def var v15 as char format "x(21)".
def var v16 as char format "x(21)".
def var v17 as char format "x(21)".

def var v18 as char format "x(21)".
def var v19 as char format "x(21)".
def var v20 as char format "x(21)".

def var v21 as char format "x(21)".
def var v22 as char format "x(18)".
def var v23 as char format "x(21)".

def var v24 as char format "x(05)".
def var v25 as char format "x(18)".
def var v26 as char format "x(18)".

def var v27 as char format "x(05)".
def var v28 as char format "x(18)".
def var v29 as char format "x(18)".

def var v30 as char format "x(05)".
def var v31 as char format "x(18)".
def var v32 as char format "x(18)".

def var v33 as char format "x(05)".
def var v34 as char format "x(18)".
def var v35 as char format "x(18)".

def var v36 as char format "x(05)".
def var v37 as char format "x(18)".
def var v38 as char format "x(18)".

def var v39 as char format "x(05)".
def var v40 as char format "x(18)".
def var v41 as char format "x(18)".

def var v42 as char format "x(05)".
def var v43 as char format "x(18)".
def var v44 as char format "x(18)".

def var v45 as char format "x(06)".
def var v46 as char format "x(06)".
def var v47 as char format "x(06)".

def var v48 as char format "x(18)".
def var v49 as char format "x(18)".
def var v50 as char format "x(18)".
def var v51 as char format "x(18)".
def var v52 as char format "x(18)".
def var v53 as char format "x(18)".
def var v54 as char format "x(18)".

def var v55 as char format "x(09)".
def var v56 as char format "x(09)".
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".
def temp-table warquivo
    field warq as char format "x(50)"
    field wetb as c format ">>9"
    field wcxa as c format "99"
    field wmes as c format "99"
    field wdia as c format "99".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
repeat:

    
    for each tt-07.
        delete tt-07.
    end.
    
    
    for each tt-caixa:
        delete tt-caixa.
    end.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.

    varquivo = "..\relat\cu" + string(vetbcod,">>9") +
                               string(day(vdti),"99") +
                               string(month(vdtf),"99").

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""REL_ECF""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}



    xx = 0.

    tot = 0.

    for each tt-icms:
        delete tt-icms.
    end.
    
    input from ..\progr\icms.txt.
    repeat:
        import vprocod
               vdtini
               vdtfin
               vativo.
        find first tt-icms where tt-icms.procod = vprocod no-error.
        if not avail tt-icms
        then do:
               
        
            create tt-icms.
            assign tt-icms.procod = vprocod
                   tt-icms.dtini  = vdtini
                   tt-icms.dtfin  = vdtfin
                   tt-icms.ativo  = vativo.
                   
                   
            
        end.
        
    end.
    input close.

    for each tt-icms.

        find produ where produ.procod = tt-icms.procod no-lock no-error.
        if not avail produ
        then do:
            delete tt-icms.
            next.
        end.
    
    end.    
     
    for each tt-icms where tt-icms.dtini <= vdti and
                           tt-icms.dtfin >= vdtf:
                           
        for each movim where movim.etbcod = estab.etbcod and
                             movim.movtdc = 5            and
                             movim.movdat >= vdti        and
                             movim.movdat <= vdtf        and
                             movim.procod = tt-icms.procod no-lock.
                             
            find plani where plani.etbcod = movim.etbcod and
                             plani.placod = movim.placod and
                             plani.movtdc = movim.movtdc and
                             plani.pladat = movim.movdat no-lock no-error.
            if not avail plani
            then next.
            
            find first tt-07 where tt-07.etbcod = plani.etbcod and
                                   tt-07.cxacod = plani.cxacod and
                                   tt-07.data   = plani.pladat no-error.
            if not avail tt-07
            then do:
                create tt-07.
                assign tt-07.etbcod = plani.etbcod
                       tt-07.cxacod = plani.cxacod
                       tt-07.data   = plani.pladat.
            end.
            tt-07.valor = tt-07.valor + (movim.movpc * movim.movqtm).
        end.
    end.        
     
    
    
    
    
    for each serial where serial.etbcod = estab.etbcod and
                          serial.serdat >= vdti        and
                          serial.serdat <= vdtf no-lock 
                                    break by serial.cxacod:
        
        tot = tot + serial.icm17 + serial.icm12 + serial.sersub.
        if last-of(serial.cxacod)
        then do:
            if tot <> 0 
            then do:
                create tt-caixa.
                assign tt-caixa.cxacod = serial.cxacod.
                tot = 0.
            end.
        end.
    end.

             
    assign  tg01 = 0
            tg02 = 0
            tg03 = 0
            tg04 = 0
            tg05 = 0
            tg06 = 0
            tg07 = 0
            tg08 = 0
            tg09 = 0.

    for each tt-caixa,
        each serial where serial.etbcod = estab.etbcod and
                          serial.serdat >= vdti        and
                          serial.serdat <= vdtf        and
                          serial.cxacod = tt-caixa.cxacod and
                          serial.icm17  > 0 no-lock 
                                    break by serial.cxacod:
        
        find first tt-07 where tt-07.etbcod = serial.etbcod and
                               tt-07.cxacod = serial.cxacod and
                               tt-07.data   = serial.serdat no-error.
         
 
        if avail tt-07
        then icm07 = tt-07.valor.
        else icm07 = 0.
        
        if first-of(serial.cxacod)
        then do:
            t01 = 0.
            t02 = 0.
            t03 = 0.
            t04 = 0.
            t05 = 0.
            t06 = 0.
            t07 = 0.
            t08 = 0.
            t09 = 0.
            
            xx = xx + 1.

            if xx > 1
            then put skip(3).
            put "CAIXA  "  at 50 serial.cxacod skip.
            put "      DATA     RED.    VDA.07%   VDA.12%"
                "       VDA.17%        SUBST  TOTAL VDA"
                "     BC.12%      BC.17%      ISENTOS        ICMS.17%" skip
                 fill("-",150) format "x(150)" skip.
        end.

        
        i = 0.

        assign val18 = serial.icm12
               val15 = (serial.icm17 - icm07)
               val11 = serial.sersub
               val19 = val18 * 0.705889
               val07  = icm07
               valcon = val18 + val15 + val11 + val07
               valicm = ((val19 + val15) * 0.17) + (icm07 * 0.07)
               val12 = val18 - val19.
        
        
        t01 = t01 + val18.
        t02 = t02 + val15.
        t03 = t03 + val11.
        t04 = t04 + valcon.
        t05 = t05 + val19.
        t06 = t06 + val15.
        t07 = t07 + val12.
        t08 = t08 + valicm.
        t09 = t09 + val07.

 
        tg01 = tg01 + val18.
        tg02 = tg02 + val15.
        tg03 = tg03 + val11.
        tg04 = tg04 + valcon.
        tg05 = tg05 + val19.
        tg06 = tg06 + val15.
        tg07 = tg07 + val12.
        tg08 = tg08 + valicm.
        tg09 = tg09 + val07.




        put serial.serdat
            redcod format ">>>>>>99"     to 19
            val07  format ">>>,>>9.99"    to 30
            val18  format ">>>,>>9.99"    to 40
            val15  format ">>>,>>9.99"    to 54
            val11  format ">>>,>>9.99"    to 67
            valcon format ">>>,>>9.99"   to 78
            val19  format ">>>,>>9.99"    to 89
            val15  format ">>>,>>9.99"    to 101
            val12  format ">>>,>>9.99"    to 114
            valicm  format ">>>,>>9.99"   to 130.
        put skip.
        if last-of(serial.cxacod)
        then do:
            put fill("-",150) format "x(150)" skip
            "Totais... " t09 format ">>>,>>9.99" to 30
                         t01 format ">>>,>>9.99" to 40
                         t02 format ">>>,>>9.99" to 54
                         t03 format ">>>,>>9.99"  to 67
                         t04 format ">>>,>>9.99" to 78
                         t05 format ">>>,>>9.99" to 89
                         t06 format ">>>,>>9.99" to 101
                         t07 format ">>>,>>9.99" to 114
                         t08 format ">>>,>>9.99" to 130 skip.
            put fill("-",150) format "x(150)" skip.
        end.


    end.
    put skip(2)
        fill("-",150) format "x(150)" skip
            " Geral... " tg09 format ">>>,>>9.99" to 30
                         tg01 format ">>>,>>9.99" to 40
                         tg02 format ">>>,>>9.99" to 54
                         tg03 format ">>>,>>9.99"  to 67
                         tg04 format ">>>,>>9.99" to 78
                         tg05 format ">>>,>>9.99" to 89
                         tg06 format ">>>,>>9.99" to 101
                         tg07 format ">>>,>>9.99" to 114
                         tg08 format ">>>,>>9.99" to 130 skip.
            put fill("-",150) format "x(150)" skip.

    {mrod.i}
    /*
    output close.
    dos silent value("type " + varquivo + "> prn"). 
    */
end.
