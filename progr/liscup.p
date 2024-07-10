{admcab.i}
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

def var v15 as char format "x(05)".
def var v16 as char format "x(18)".
def var v17 as dec.

def var v18 as char format "x(05)".
def var v19 as char format "x(18)".
def var v20 as dec.

def var v21 as char format "x(05)".
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
def var vdti as date.
def var vdtf as date.
def var vdata as date.
repeat:
    for each warquivo:
        delete warquivo.
    end.

    message "Confirma Listagem" update sresp.
    if not sresp
    then return.

    for each estab no-lock.

        dos silent dir value("..\import\" + string(estab.etbcod,">>9") +
                            "*.cup") /s/b > ..\import\arq.

        input from ..\import\arq.
        repeat:
            create warquivo.
            import warq.
            dos  silent quoter
                value(warq) > value(substring(warq,1,(length(warq) - 1)) +
                                     "c").
        end.
        input close.

        dos silent dir value("..\import\" + string(estab.etbcod,">>9") +
                             "*.cuc") /s/b > ..\import\arq.

        input from ..\import\arq.
        repeat:
            create warquivo.
            import warq.
            assign warquivo.wetb = substring(warq,18,2)
                   warquivo.wcxa = substring(warq,20,2)
                   warquivo.wdia = substring(warq,22,2)
                   warquivo.wmes = substring(warq,24,2).
        end.
        input close.
    end.


    varquivo = "i:\admcom\relat\cu" + string(vetbcod,">>9").

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
        for each warquivo where warquivo.warq <> "" and
                                warquivo.wdia <> "" break by warquivo.wetb
                                                          by warquivo.wdia:

            vdata = date( int(warquivo.wmes),
                          int(warquivo.wdia),
                          year(today)).

            if first-of(warquivo.wetb)
            then do:
                find estab where estab.etbcod = int(wetb) no-lock.
                display estab.etbnom with frame f-cad side-label.
            end.
            if first-of(warquivo.wdia)
            then put vdata  skip.
        end.
        output close.
        dos silent value("type " + varquivo + "> prn").
end.
