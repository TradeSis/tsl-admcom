{admcab.i}
def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
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
def var v08 as dec.
def var v09 as dec.
def var v10 as char format "x(21)".
def var v11 as dec.
def var v12 as dec.
def var v13 as dec.
def var v14 as char format "x(21)".

def var v15 as dec.
def var v16 as dec.
def var v17 as dec.

def var v18 as dec.
def var v19 as dec.
def var v20 as dec.

def var v21 as dec.
def var v22 as char format "x(18)".
def var v23 as dec.

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
    for each warquivo:
        delete warquivo.
    end.
    update vetbcod with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.

    dos silent dir value("..\import\" + string(vetbcod,">>9") + "*.cup") /s/b >
        ..\import\arq.

    input from ..\import\arq.
    repeat:
        create warquivo.
        import warq.
        dos silent i:\dlc\bin\quoter
            value(warq) > value(substring(warq,1,(length(warq) - 1)) +
                                 "c").
    end.
    input close.

    for each warquivo:
        delete warquivo.
    end.

    dos silent dir value("..\import\" + string(vetbcod,">>9") + "*.cuc") /s/b >
        ..\import\arq.


    input from ..\import\arq.
    repeat:
        create warquivo.
        import warq.
        assign warquivo.wetb = substring(warq,18,2)
               warquivo.wcxa = substring(warq,20,2)
               warquivo.wdia = substring(warq,22,2)
               warquivo.wmes = substring(warq,24,2).
    end.

    varquivo = "i:\admcom\relat\cu" + string(vetbcod,">>9") +
                               string(day(vdti),"99") +
                               string(month(vdtf),"99").

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""IMPCUP""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}



    xx = 0.

    for each warquivo where warquivo.warq <> "" :
        vok = no.
        vdata = date( int(warquivo.wmes),
                      int(warquivo.wdia),
                      year(today)).
        if vdata >= vdti and
           vdata <= vdtf
        then.
        else delete warquivo.


    end.
        /*
        input from value(warq).
        repeat:
            import vlinha.
            if vlinha = ""
                then do:
                end.
        end.
        input close.
        if vok = yes
        then delete warquivo.
        input close.
        */

    for each warquivo where warquivo.warq <> "" break by warquivo.wcxa
                                                      by warquivo.wmes
                                                      by warquivo.wdia:
        vdata = date( int(warquivo.wmes),
                      int(warquivo.wdia),
                      year(today)).
        input from value(warq).
        vcont = 0.
        repeat:
            import vlinha.
            vcont = vcont + 1.
            /* if vcont = 1
            then v01 = string(vlinha,"99"). */
            if vcont = 01
            then v02 = string(vlinha,"x(08)").
            if vcont = 02
            then v03 = string(vlinha,"x(10)").
            if vcont = 03
            then v04 = string(vlinha,"x(04)").
            if vcont = 04
            then v05 = string(vlinha,"x(05)").
            if vcont = 05
            then v06 = string(vlinha,"x(05)").
            if vcont = 06
            then v07 = string(vlinha,"x(05)").
            if vcont = 07
            then v08 = dec(vlinha).
            if vcont = 08
            then v09 = dec(vlinha).
            if vcont = 09
            then v10 = string(vlinha,"x(21)").
            if vcont = 11
            then v11 = dec(vlinha).
            if vcont = 12
            then v12 = dec(vlinha).
            if vcont = 13
            then v13 = dec(vlinha).
            if vcont = 14
            then v14 = string(vlinha,"x(21)").
            if vcont = 15
            then v15 = dec(vlinha).
            if vcont = 16
            then v16 = dec(vlinha).
            if vcont = 17
            then v17 = dec(vlinha).
            if vcont = 18
            then v18 = dec(vlinha).
            if vcont = 19
            then v19 = dec(vlinha).
            if vcont = 20
            then v20 = dec(vlinha).
            if vcont = 21
            then v21 = dec(vlinha).
            if vcont = 22
            then v22 = string(vlinha,"x(18)").
            if vcont = 23
            then v23 = dec(vlinha).
            if vcont = 24
            then v24 = string(vlinha,"x(05)").
            if vcont = 24
            then v25 = string(vlinha,"x(18)").
            if vcont = 25
            then v26 = string(vlinha,"x(18)").
            if vcont = 26
            then v27 = string(vlinha,"x(05)").
            if vcont = 27
            then v28 = string(vlinha,"x(18)").
            if vcont = 28
            then v29 = string(vlinha,"x(18)").
            if vcont = 29
            then v30 = string(vlinha,"x(05)").
            if vcont = 30
            then v31 = string(vlinha,"x(18)").
            if vcont = 31
            then v32 = string(vlinha,"x(18)").
            if vcont = 32
            then v33 = string(vlinha,"x(05)").
            if vcont = 33
            then v34 = string(vlinha,"x(18)").
            if vcont = 34
            then v35 = string(vlinha,"x(18)").
            if vcont = 35
            then v36 = string(vlinha,"x(05)").
            if vcont = 36
            then v37 = string(vlinha,"x(18)").
            if vcont = 37
            then v38 = string(vlinha,"x(18)").
            if vcont = 38
            then v39 = string(vlinha,"x(05)").
            if vcont = 39
            then v40 = string(vlinha,"x(18)").
            if vcont = 40
            then v41 = string(vlinha,"x(18)").
            if vcont = 41
            then v42 = string(vlinha,"x(05)").
            if vcont = 42
            then v43 = string(vlinha,"x(18)").
            if vcont = 43
            then v44 = string(vlinha,"x(18)").
            if vcont = 44
            then v45 = string(vlinha,"x(06)").
            if vcont = 45
            then v46 = string(vlinha,"x(06)").
            if vcont = 46
            then v47 = string(vlinha,"x(06)").
            if vcont = 47
            then v48 = string(vlinha,"x(18)").
            if vcont = 48
            then v49 = string(vlinha,"x(18)").
            if vcont = 49
            then v50 = string(vlinha,"x(18)").
            if vcont = 50
            then v51 = string(vlinha,"x(18)").
            if vcont = 51
            then v52 = string(vlinha,"x(18)").
            if vcont = 52
            then v53 = string(vlinha,"x(18)").
            if vcont = 53
            then v54 = string(vlinha,"x(18)").
            if vcont = 54
            then v55 = string(vlinha,"x(09)").
            if vcont = 55
            then v56 = string(vlinha,"x(09)").

        end.
        input close.
        
        
        if v02 = ""
        then next.
        if first-of(warquivo.wcxa)
        then do:
            t01 = 0.
            t02 = 0.
            t03 = 0.
            t04 = 0.
            t05 = 0.
            t06 = 0.
            t07 = 0.
            t08 = 0.
            xx = xx + 1.

            if xx > 1
            then put skip(3).
            put "CAIXA  "  at 50 warquivo.wcxa skip.
            put "DATA       RED.       VDA.12%    VDA.17%    SUBST    TOTAL VDA"
                "     BC.12%     BC.17%     ISENTOS     ICMS.17%" skip
                 fill("-",150) format "x(150)" skip.
        end.

        if v18 > 10000
        then v18 = v18 / 100.
        else if v18 > 1000
             then v18 = v18 / 10.
             else if v18 < 1000
                  then v18 = v18 * 1000.

        if v15 > 10000
        then v15 = v15 / 100.
        else if v15 > 1000
             then v15 = v15 / 10.
             else if v15 < 10
                  then v15 = v15 * 1000.
                  else if v15 < 100
                       then v15 = v15 * 100.
                       else if v15 < 1000
                            then v15 = v15 / 100.


        if v21 > 10000
        then v21 = v21 / 100.
        else if v21 > 1000
             then v21 = v21 / 10.
             else if v21 < 10
                  then v21 = v21 * 1000.
                  else if v21 < 100
                       then v21 = v21 * 100.
                       else if v21 < 1000
                            then v21 = v21 / 100.


        if v19 > 10000
        then v19 = v19 / 100.
        else if v19 > 1000
             then v19 = v19 / 100.
             else if v19 < 100
                  then v19 = v19 * 1000.
             else if v19 < 1000
                  then v19 = v19 * 100.

        v11 = v11 / 100.    /* subst   */
        v12 = v12 / 100.    /* isentos */
        v19 = dec(v18) * 0.705889.
        v15 = v15 + v21.


        vred = int(v02).
        if vred = 0
        then next.
        valcon = dec(v18) + dec(v15) + v11.
        valicm = (dec(v19) + dec(v15)) * 0.17.
        v12 = v12 + (dec(v18) - dec(v19)).
        t01 = t01 + v18.
        t02 = t02 + v15.
        t03 = t03 + v11.
        t04 = t04 + valcon.
        t05 = t05 + v19.
        t06 = t06 + v15.
        t07 = t07 + v12.
        t08 = t08 + valicm.



        put v03
            vred format ">99"          to 14
            v18  format ">>,>>9.99"    to 29
            v15  format ">>,>>9.99"    to 40
            v11  format ">>,>>9.99"     to 49
            valcon format ">>>,>>9.99"  to 62
            v19  format ">>,>>9.99"      to 73
            v15  format ">>,>>9.99"     to 84
            v12  format ">>,>>9.99"     to 96
            valicm  format ">>,>>9.99"  to 109.
        put skip.
        if last-of(warquivo.wcxa)
        then do:
            put fill("-",150) format "x(150)" skip
            "Totais... " t01 format ">>>,>>9.99" to 29
                         t02 format ">>>,>>9.99" to 40
                         t03 format ">>,>>9.99" to 49
                         t04 format ">>>,>>9.99" to 62
                         t05 format ">>>,>>9.99" to 73
                         t06 format ">>>,>>9.99" to 84
                         t07 format ">>>,>>9.99" to 96
                         t08 format ">>>,>>9.99" to 109 skip.
            put fill("-",150) format "x(150)" skip.
        end.

    end.
    output close.
    dos silent value("type " + varquivo + "> prn"). 

end.
