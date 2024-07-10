{admcab.i}
def var vv as char format "x(01)".
def buffer bmapctb for mapctb.
def var redz    like mapctb.nrored.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vativo  as log.
def var vprocod like produ.procod.
def var total_inicial like plani.platot.
 
def var val07 as dec.
def var icm07 as dec.

def var tot as dec.
def temp-table tt-caixa
    field cxacod like serial.cxacod.

def var ven07 as dec.
def var ven12 as dec.
def var ven17  as dec.
def var ven18 as dec.
def var vensub as dec.
def var totven as dec.
def var bas12  as dec.
def var bas17  as dec.
def var icm17  as dec. 
def var bas18 as dec.
def var icm18 as dec.


def var i as i.


def var t01 like plani.platot.
def var t02 like plani.platot.
def var t03 like plani.platot.
def var t04 like plani.platot.
def var t05 like plani.platot.
def var t06 like plani.platot.
def var t07 like plani.platot.
def var t08 like plani.platot.
def var t09 like plani.platot.
def var t18 like plani.platot.
def var i18 like plani.platot.

def var tg01 like plani.platot.
def var tg02 like plani.platot.
def var tg03 like plani.platot.
def var tg04 like plani.platot.
def var tg05 like plani.platot.
def var tg06 like plani.platot.
def var tg07 like plani.platot.
def var tg08 like plani.platot.
def var tg09 like plani.platot.
def var tg18 like plani.platot.
def var ig18 like plani.platot.


def var vok as l.
def var xx as i.
def var vred as int.
def var valcon as dec.
def var valicm as dec.
def var varquivo as char format "x(20)".
def var vlinha as char format "x(25)".
def  var vcont as int.
def var vcxacod like caixa.cxacod.
def var vdia    as int format "99".
def var vmes    as int format "99".

def input parameter vetbcod like estab.etbcod.
def input parameter vdti as date format "99/99/9999".
def input parameter vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
    

    for each tt-caixa:
        delete tt-caixa.
    end.
    /*
    update vetbcod with frame f1 side-label width 80.
    */
    
    find estab where estab.etbcod = vetbcod no-lock.
    /*
    display estab.etbnom no-label with frame f1.
   
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    */

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cu" + string(vetbcod,"999") +
                            string(day(vdti),"99") +
                            string(month(vdtf),"99") +
                            "." + string(time)
                            .
                            
    else
    varquivo = "..\relat\cu" + string(vetbcod,"999") +
                               string(day(vdti),"99") +
                               string(month(vdtf),"99").

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_map""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE  FILIAL - ""
                        + string(vetbcod,"">>9"")"
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}



    xx = 0.

    tot = 0.

    
    for each mapctb where mapctb.etbcod = estab.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf        and
                          mapctb.ch2 <> "E"  no-lock 
                                    break by mapctb.cxacod:
        
                     
        tot = tot + (mapctb.t01 + 
                     mapctb.t02 + 
                     mapctb.t03 + 
                     mapctb.t04 + 
                     mapctb.t05 + 
                     mapctb.vlsub).
        if last-of(mapctb.cxacod)
        then do:
            if tot <> 0 
            then do:
                create tt-caixa.
                assign tt-caixa.cxacod = mapctb.cxacod.
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
        each mapctb where mapctb.etbcod = estab.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf        and
                          mapctb.cxacod = tt-caixa.cxacod  and
                          mapctb.ch2 <> "E" 
                                    break by mapctb.cxacod:
        
       
        if first-of(mapctb.cxacod)
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
            put "Equipamento:  "  at 50 mapctb.cxacod format ">>9"
                "    Caixa: " int(mapctb.de1) format ">9" skip(1).
            put "      DATA     RED.    VDA.07%   VDA.12%"
                "       VDA.17%       VDA.18%      SUBST   TOTAL VDA"
                "    ISENTO       BASE  VAL.ICMS" skip
                 fill("-",150) format "x(150)" skip.
        end.

        
        i = 0.

        
        assign ven07  = mapctb.t03
               ven12  = mapctb.t02
               ven17  = mapctb.t01
               ven18  = mapctb.t05
               vensub = mapctb.vlsub
               totven = mapctb.t01 +
                        mapctb.t02 + 
                        mapctb.t03 + 
                        mapctb.t05 +
                        mapctb.vlsub
               bas12  = mapctb.t02 * 0.705889
               bas17  = mapctb.t01 + bas12 + (ven07 * 0.411764)
               icm17  = bas17 * 0.17.
               bas18  = mapctb.t05.
               icm18  = bas18 * 0.18.
                 
        
        
        if mapctb.ch1 = ""
        then do:
            find last bmapctb use-index ind-2 
                        where bmapctb.etbcod = mapctb.etbcod and
                              bmapctb.cxacod = mapctb.cxacod and 
                              bmapctb.ch2 <> "E"              and
                              bmapctb.datmov = mapctb.datmov  and
                              bmapctb.nrored < mapctb.nrored
                                        no-lock no-error.
            if not avail bmapctb
            then find last bmapctb use-index ind-2 
                        where bmapctb.etbcod = mapctb.etbcod and
                              bmapctb.cxacod = mapctb.cxacod and 
                              bmapctb.ch2 <> "E"              and
                              bmapctb.datmov < mapctb.datmov  
                                        no-lock no-error.


        end.
        else do:
            find last bmapctb use-index ind-1 
                        where bmapctb.ch1    = mapctb.ch1    and
                              bmapctb.datmov = mapctb.datmov and
                              bmapctb.ch2 <> "E"         and
                              bmapctb.nrored < mapctb.nrored
                                        no-lock no-error.
            if not avail bmapctb
            then find last bmapctb use-index ind-1 
                        where bmapctb.ch1    = mapctb.ch1    and
                              bmapctb.datmov < mapctb.datmov and
                              bmapctb.ch2 <> "E" 
                                        no-lock no-error.
 
         end.
        if avail bmapctb  
        then total_inicial = bmapctb.gtotal.  
        else total_inicial = mapctb.gtotal - 
                             totven -  
                             mapctb.vlcan +  
                             mapctb.vlacr.

             
        vv = "".
        if (mapctb.gtotal - 
            total_inicial - 
            mapctb.vlcan  +  
            mapctb.vlacr) <> mapctb.t01 + 
                             mapctb.t02 + 
                             mapctb.t03 + 
                             mapctb.t05 +
                             mapctb.vlsub
        then do:
            
            /*
            message  mapctb.cxacod mapctb.gtotal total_inicial
            mapctb.vlcan mapctb.vlacr
            (mapctb.gtotal - total_inicial - mapctb.vlcan  +  
                                   mapctb.vlacr)
                    (mapctb.t01 + mapctb.t02 + mapctb.t03 + mapctb.vlsub)
                                  .
                                  pause.
            */
            
            vv = "*". 
        end.

         
        
        
        
        
        /*if int(mapctb.nrofab) > 0 
        then redz = mapctb.nrored + 1. 
        else*/ redz = mapctb.nrored.

         
        t01 = t01 + ven07.
        t02 = t02 + ven12.
        t03 = t03 + ven17.
        t04 = t04 + vensub.
        t05 = t05 + totven.
        t06 = t06 + bas12.
        t07 = t07 + bas17.
        t08 = t08 + mapctb.vlise.
        t09 = t09 + icm17.
        t18 = t18 + ven18.
        i18 = i18 + icm18.
 
        tg01 = tg01 + ven07.
        tg02 = tg02 + ven12.
        tg03 = tg03 + ven17.
        tg04 = tg04 + vensub.
        tg05 = tg05 + totven.
        tg06 = tg06 + bas12.
        tg07 = tg07 + bas17.
        tg08 = tg08 + mapctb.vlise.
        tg09 = tg09 + icm17.
        tg18 = tg18 + bas18.
        ig18 = ig18 + icm18.



        put mapctb.datmov
            redz   format ">>>>>>99"            to 19
            ven07  format ">>>,>>9.99"          to 30
            ven12  format ">>>,>>9.99"          to 40
            ven17  format ">>>,>>9.99"          to 54
            ven18  format ">>>>,>>9.99"          to 68
            vensub format ">>>>,>>9.99"          to 79
            totven format ">>>>,>>9.99"          to 91
            mapctb.vlise format ">>>,>>9.99"     to 101
            bas17  format ">>>,>>9.99"          to 112
            icm17  format ">>>,>>9.99"          to 122
            vv                                  to 132.
        put skip.
        if last-of(mapctb.cxacod)
        then do:
            put fill("-",150) format "x(150)" skip
            "Totais... " t01 format ">>>,>>9.99" to 30
                         t02 format ">>>,>>9.99" to 40
                         t03 format ">>>,>>9.99" to 54
                         t18 format ">>>>,>>9.99" to 68
                         t04 format ">>>>,>>9.99"  to 79
                         t05 format ">>>>,>>9.99" to 91
                         t08 format ">>>,>>9.99" to 101
                         t07 format ">>>,>>9.99" to 112
                         t09 format ">>>,>>9.99" to 122 skip.
            put fill("-",150) format "x(150)" skip.
        end.


    end.
    put skip(2)
        fill("-",150) format "x(150)" skip
            " Geral... " tg01 format ">>>,>>9.99" to 30
                         tg02 format ">>>,>>9.99" to 40
                         tg03 format ">>>,>>9.99" to 54
                         tg18 format ">>>>,>>9.99" to 68
                         tg04 format ">>>>,>>9.99"  to 79
                         tg05 format ">>>>,>>9.99" to 91
                         tg08 format ">>>,>>9.99" to 101
                         tg07 format ">>>,>>9.99" to 112
                         tg09 format ">>>,>>9.99" to 122 skip.
            put fill("-",150) format "x(150)" skip.

    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:    
    {mrod.i}
    end.
    
