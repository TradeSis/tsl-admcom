/*----------------------------------------------------------------------------*/
/* previli.p                                     Titulo Previsao - Listagem   */
/*                                                                            */
/*----------------------------------------------------------------------------*/
{admcab.i}

def var varquivo as char.
def var vdtref like plani.pladat.
def var vtot   like titulo.titvlcob format "zz,zzz,zz9.99".
def var vpag   like titulo.titvlpag format "zz,zzz,zz9.99".
def var vent   like titulo.titvlcob format "zz,zzz,zz9.99".
def var vsal   like titulo.titvlcob format "zz,zzz,zz9.99".


def var vano as int.
def var z as i.
def var x as i.
def var vche  like titulo.titvlcob.
def var vtot1 like titulo.titvlcob.
def var vtot2 like titulo.titvlcob.
def var vcon  like titulo.titvlcob.
DEF VAR TOTMES AS DEC FORMAT ">>>,>>>,>>9.99" EXTENT 99.
DEF VAR TOTCHE AS DEC FORMAT ">>>,>>>,>>9.99" EXTENT 99.
DEF VAR TOTdia AS DEC FORMAT ">>>,>>>,>>9.99".
DEF VAR totge AS DEC FORMAT ">>>,>>>,>>9.99".
def var vm  as int extent 3.
def var vi  as int.

def var vmes as i.
def var vdata like titulo.titdtven.
def var    wdti like titulo.titdtven label "Periodo".
def var    wdtf like titulo.titdtven.

def temp-table wtit
    field wmes  as int
    field wdia  as int
    field wano  as int
    field wdata as date format "99/99/9999"
    field wtot  as dec format ">,>>>,>>9.99"
    field wche  as dec format ">,>>>,>>9.99"
    field wcon  as dec format ">,>>>,>>9.99".
form wdti          colon 18  " A"
     wdtf          colon 35  no-label
                   with side-labels width 80 frame f1.

wdti = today.
wdtf = today.
repeat with frame f1:
    clear frame f1 all.
    for each wtit.
        delete wtit.
    end.
    update wdti validate(input wdti <> ?,
                        "Data deve ser Informada")
                         with frame f1.

    update wdtf with frame f1.

    vdtref = today - 1.
    update vdtref label "Data Referencia" with frame f1.

    {confir.i 1 "Listagem Previsao"}

    if opsys = "UNIX"
    then varquivo = "../relat/prev." + string(time).
    else varquivo = "..\relat\prev." + string(time).
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "140"  
        &Page-Line = "66"
        &Nom-Rel   = ""PREV""  
        &Nom-Sis   = """SISTEMA FINANCEIRO"""
        &Tit-Rel   = """PREVISAO FINANCEIRA - PERIODO DE ""
                   + string(wdti,""99/99/9999"") 
                   + "" A "" 
                   + string(wdtf,""99/99/9999"") "
        &Width     = "120"
        &Form      = "frame f-cabcab"}


    vtot  = 0.
    vm = 0.

    vano  = year(wdti).
    vmes  = month(wdti).

    if vmes >= 10
    then do:
        if vmes = 10
        then assign vmes = 1
                    vano = vano + 1.
        if vmes = 11
        then assign vmes = 2
                    vano = vano + 1.
        if vmes = 12
        then assign vmes = 3
                    vano = vano + 1.
    end.
    else vmes = month(wdti) + 3.

    vdata = date(vmes,1,vano) - 1.

    for each titulo where empcod = 19                   and
                          titnat = yes                  and
                          titdtven >= input wdti        and
                          titdtven <= vdata             and
                          titulo.modcod = "DUP"         and
                          (titsit   = "LIB"  or
                           titsit   = "CON") no-lock:

        find first wtit where wtit.wmes = month(titulo.titdtven) and
                              wtit.wdia = day(titulo.titdtven) no-error.
        if not avail wtit
        then do:
            create wtit.
            assign wtit.wmes = month(titulo.titdtven)
                   wtit.wdia = day(titulo.titdtven)
                   wtit.wano = year(titulo.titdtven)
                   wtit.wdata = titulo.titdtven.
        end.
        if titulo.titsit = "LIB"
        then wtit.wtot = wtit.wtot + (titulo.titvlcob + titulo.titvljur).
        if titulo.titsit = "CON"
        then wtit.wcon = wtit.wcon + (titulo.titvlcob + titulo.titvljur).
    end.
    
    vi = 0.
    for each wtit break by wano
                        by wmes:
        if first-of(wtit.wmes)
        then do:
            vi = vi + 1.
            vm[vi] = wtit.wmes.
        end.
    end.

    for each cheque where cheque.chesit = "LIB" and
                          cheque.cheetb = 990    and
                          cheque.cheven >= input wdti and
                          cheque.cheven <= vdata no-lock:

        find first wtit where wtit.wmes = month(cheque.cheven) and
                              wtit.wdia = day(cheque.cheven) no-error.
        if not avail wtit
        then do:
            create wtit.
            assign wtit.wmes = month(cheque.cheven)
                   wtit.wdia = day(cheque.cheven)
                   wtit.wano = year(cheque.cheven)
                   wtit.wdata = cheque.cheven.
        end.
        wtit.wche = wtit.wche + cheque.cheval.
    end.


    totdia = 0.
    totge  = 0.
    for each wtit WHERE WTIT.wdata >= wdti and
                        wtit.wdata <= wdtf:
        TOTDIA = TOTdia + wtit.wtot + wtit.wche + wtit.wcon.
        TOTGE = TOTGE + wtit.wtot + wtit.wcon.
    end.
put
"  VENCIMENTO           CONF          LIBER      TOTAL DIA  "
        " DUPLICATA " AT 85 skip.
    vtot1 = 0.
    vche  = 0.
    vcon  = 0.
    vtot2 = 0.
    x     = 0.
    z     = 0.
    
    run sal_ant.p (input  vdtref,
                   output vtot,
                   output vpag,
                   output vent,
                   output vsal).
     
    
    for each wtit WHERE WTIT.wmes = MONTH(input wdti) break by wtit.wdia:

        put space(2) wtit.wdata
            space(2) wtit.wcon  format ">>,>>>,>>9.99"
            space(2) wtit.wtot  format ">>,>>>,>>9.99"
            space(2) (wtit.wtot + wtit.wcon) format ">>,>>>,>>9.99"
            /*space(4) wtit.wche*/.
        vtot1 = vtot1 + wtit.wtot.
        vche  = vche  + wtit.wche.
        vcon  = vcon  + wtit.wcon.
        vtot2 = vtot2 + (wtit.wcon + wtit.wtot).
        if last-of(wtit.wdia)
        then do:
            z = z + 1.
            if wtit.wdia = day(wdti)
            then put "|______________________|" at 65 " " totdia skip.
            else
            put "|______________________|_______________________|" at 65.
            
            
            put skip.
            
        
        end.
    end.
    put "Total......" vcon
                      space(2) vtot1 format ">>,>>>,>>9.99"
                      space(2) vtot2  format ">>,>>>,>>9.99"
                      /*vche*/.

    run sal_ant.p (input  vdtref,
                   output vtot,
                   output vpag,
                   output vent,
                   output vsal).
                
                
    do x = z + 1 to 28:

        put "|______________________|_______________________|" at 65.
        

        put skip.

    end.

    put "Sal.Anterior: " at 75 vsal   skip
        "- Pagamento : " at 75 vpag   skip
        "+ Entradas  : " at 75 vent   skip
        "Saldo Atual : " at 75 vtot   skip.
 
    put skip(1)
    "VENCIMENTO          CONF           LIBER     TOTAL DIA "
    "VENCIMENTO          CONF           LIBER     TOTAL DIA "
    at 65 skip.

    if vm[2] > vm[3]
    then do:
    for each wtit where wtit.wmes <> vm[1] break by wtit.wdia
                                                 by wtit.wmes desc:

        TOTMES[WTIT.WMES] = TOTMES[WTIT.WMES] + WTIT.WTOT + wtit.wcon.
        TOTCHE[WTIT.WMES] = TOTCHE[WTIT.WMES] + WTIT.WCHE.
        if last-of(wtit.wdia) and
           wtit.wmes = vm[3]
        then put wtit.wdata at 65
                 space(4) wtit.wcon
                 space(2) wtit.wtot   
                 space(2) (wtit.wcon + wtit.wtot) format ">,>>>,>>9.99"
                 /*space(2) wtit.wche*/.
        else
        put wtit.wdata at 1
            space(4) wtit.wcon
            space(2) wtit.wtot
            space(2) (wtit.wcon + wtit.wtot) format ">,>>>,>>9.99"
            /*space(2) wtit.wche*/.
        if last-of(wtit.wdia)
        then put skip.

    end.
    end.
    else do:
    for each wtit where wtit.wmes <> vm[1] break by wtit.wdia
                                                 by wtit.wmes:

        TOTMES[WTIT.WMES] = TOTMES[WTIT.WMES] + WTIT.WTOT + wtit.wcon.
        TOTCHE[WTIT.WMES] = TOTCHE[WTIT.WMES] + WTIT.WCHE.

        if last-of(wtit.wdia) and
           wtit.wmes = vm[3]
        then put wtit.wdata at 65
                 space(4) wtit.wcon
                 space(2) wtit.wtot
                 space(2) (wtit.wcon + wtit.wtot) format ">,>>>,>>9.99"
                 /*space(2) wtit.wche*/.
        else
        put wtit.wdata at 1
            space(4) wtit.wcon
            space(2) wtit.wtot
            space(2) (wtit.wcon + wtit.wtot) format ">,>>>,>>9.99"
            /*space(2) wtit.wche*/.
        if last-of(wtit.wdia)
        then put skip.

    end.

    end.
    put skip
        "TOTAL.....................              " totmes[vm[2]]
                                                   /*totche[vm[2]] space(56)*/
                                                   totmes[vm[3]]
                                                   /*totche[vm[3]]*/.
    output close.
    if opsys = "UNIX"
    then do:
            run visurel.p(varquivo,"").
    end.
    else do:
            {mrod.i}
    end.
end.
