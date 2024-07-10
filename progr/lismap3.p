{admcab.i}
def buffer bmapcxa for mapcxa.
def var vcx like plani.cxacod.
def var vv as char format "x(01)".
def buffer bmapctb for mapctb.
def buffer cmapctb for mapctb.
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
    field etbcod like estab.etbcod
    field cxacod like serial.cxacod
    field tot    like plani.platot.


def var vqt as int.
def var ven07 as dec.
def var ven12 as dec.
def var ven17  as dec.
def var vensub as dec.
def var totven as dec.
def var bas12  as dec.
def var bas17  as dec.
def var icm17  as dec. 


def var i as i.


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

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".

def var vetbcod like estab.etbcod.


def temp-table tt-map
    field t-datmov like mapctb.datmov
    field t-redz like mapctb.nrored
    field t-ven07 as dec
    field t-ven12 as dec
    field t-ven17 as dec
    field t-vensub as dec
    field t-totven as dec
    field t-vlise  as dec
    field t-bas17  as dec
    field t-icm17  as dec
    field t-sit    as char format "x(01)"
    field t-etbcod like estab.etbcod
    field t-cxacod like mapctb.de1
    field t-equipa like mapcxa.cxacod.
         

repeat:

            
    for each tt-map:
        delete tt-map.
    end.        
    
    vdti = today.
    vdtf = today.
    
    vetbcod = 0.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then display "TODAS" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Filial nao cadastrada".
            pause.
            undo, retry.
        end.
        display estab.etbnom no-label with frame f1.
            
    end.
 
    update vdti label "Periodo" 
           vdtf no-label with frame f1.
     
    for each tt-caixa:
        delete tt-caixa.
    end.
    

    if opsys = "unix"
    then
        varquivo = "/admcom/relat/mapux" + string(day(vdti),"99") +
                                string(month(vdtf),"99").
    else
        varquivo = "l:\relat\map" + string(day(vdti),"99") +
                                string(month(vdtf),"99").
                                
                                

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "150"
        &Page-Line = "66"
        &Nom-Rel   = ""rel_map""
        &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
        &Tit-Rel   = """MOVIMENTACOES DO CUPOM FISCAL - PERIODO DE "" +
                        string(vdti,""99/99/9999"") + "" A "" +
                        string(vdtf,""99/99/9999"") "
        &Width     = "150"
        &Form      = "frame f-cabcab"}



    xx = 0.

    tot = 0.

    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each mapctb where mapctb.etbcod = estab.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf:
                           
        if mapctb.ch2 = "E" 
        then next.
                     
        do transaction:
            if mapctb.vlcan > 100000
            then mapctb.vlcan = 0.
        end.
        
        find first tt-caixa where tt-caixa.etbcod = mapctb.etbcod and
                                  tt-caixa.cxacod = mapctb.cxacod no-error.
        if not avail tt-caixa
        then do:
            create tt-caixa.
            assign tt-caixa.etbcod = mapctb.etbcod
                   tt-caixa.cxacod = mapctb.cxacod.
        end.
        tt-caixa.tot = tt-caixa.tot + (mapctb.t01 + 
                                       mapctb.t02 +  
                                       mapctb.t03 +  
                                       mapctb.t04 +  
                                       mapctb.t05 +  
                                       mapctb.vlsub).
    end.

             
    for each tt-caixa:
        if tt-caixa.tot = 0
        then delete tt-caixa.
    end.    
    
    

    for each tt-caixa,
        each mapctb where mapctb.etbcod = tt-caixa.etbcod and
                          mapctb.datmov >= vdti        and
                          mapctb.datmov <= vdtf        and
                          mapctb.cxacod = tt-caixa.cxacod 
                                    break by mapctb.etbcod
                                          by mapctb.cxacod:
       
        if mapctb.ch2 = "E" 
        then next.
             
        
        assign ven07  = mapctb.t03
               ven12  = mapctb.t02
               ven17  = mapctb.t01
               vensub = mapctb.vlsub
               totven = mapctb.t01 +
                        mapctb.t02 + 
                        mapctb.t03 + 
                        mapctb.vlsub
               bas12  = mapctb.t02 * 0.705889
               bas17  = mapctb.t01 + bas12 + (ven07 * 0.411764)
               icm17  = bas17 * 0.17.
         
        
        i = 0.

        if mapctb.ch1 = ""
        then find last bmapctb use-index ind-2 
                        where bmapctb.etbcod = mapctb.etbcod and
                              bmapctb.cxacod = mapctb.cxacod and
                              bmapctb.ch2 <> "E"             and 
                              bmapctb.datmov < mapctb.datmov
                                        no-lock no-error.
                                        
        else find last bmapctb use-index ind-1 
                        where bmapctb.ch1    = mapctb.ch1 and 
                              bmapctb.ch2 <> "E"          and    
                              bmapctb.datmov < mapctb.datmov 
                                     no-lock no-error.
                                        
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
                             mapctb.vlsub
        then vv = "*". 
        if vv = ""
        then next.

        /*       
        if int(mapctb.nrofab) > 0 
        then redz = mapctb.nrored + 1. 
        else 
        */
        redz = mapctb.nrored.

        create tt-map.
        assign tt-map.t-datmov = mapctb.datmov 
               tt-map.t-redz   = redz
               tt-map.t-ven07  = ven07  
               tt-map.t-ven12  = ven12
               tt-map.t-ven17  = ven17
               tt-map.t-vensub = vensub
               tt-map.t-totven = totven
               tt-map.t-vlise  = mapctb.vlise
               tt-map.t-bas17  = bas17
               tt-map.t-icm17  = icm17
               tt-map.t-sit    = vv
               tt-map.t-etbcod = mapctb.etbcod
               tt-map.t-cxacod = mapctb.de1
               tt-map.t-equipa = mapctb.cxacod.
    end.

    def var vnrored like mapctb.nrored. 
           
    do vdata = vdti to vdtf:

        for each estab where if vetbcod <> 0
                             then estab.etbcod = vetbcod
                             else true no-lock:
                             
            find first plani where plani.etbcod = estab.etbcod and
                                   plani.movtdc = 05           and
                                   plani.pladat = vdata
                                        no-lock no-error.
            if avail plani
            then do: 
                vqt = 0.
                vnrored = 0.
                for each mapctb where mapctb.etbcod = plani.etbcod and
                                        mapctb.datmov = plani.pladat and
                                        mapctb.de1    = dec(plani.cxacod)
                                            no-lock .
                     if mapctb.nrored = 0
                     then next.
                     if mapctb.nrored = vnrored
                     then vqt = vqt + 1.
                     if vqt = 1
                     then vnrored = mapctb.nrored.
                end.
                              
                find first mapctb where mapctb.etbcod = plani.etbcod and
                                        mapctb.datmov = plani.pladat and
                                        mapctb.de1    = dec(plani.cxacod)
                                            no-lock no-error.
                if not avail mapctb
                then do:   
                    vcx = 0. 
                    find first tabecf 
                               where tabecf.etbcod = plani.etbcod and
                                     tabecf.de1    = plani.cxacod and
                                     tabecf.datini <= plani.pladat and
                                     tabecf.datfin >= plani.pladat 
                                            no-lock no-error.
                    if avail tabecf
                    then vcx = tabecf.equipa.
                    else vcx = 0 . /*next.*/
                                            

                    find first tt-map where tt-map.t-etbcod = estab.etbcod and
                                            tt-map.t-datmov = vdata and
                                            tt-map.t-cxacod = plani.cxacod
                                                no-error.
                    if not avail tt-map
                    then do:
                   
                     
                        create tt-map.
                        assign tt-map.t-etbcod = estab.etbcod
                               tt-map.t-datmov = vdata
                               tt-map.t-cxacod = plani.cxacod
                               tt-map.t-equipa = vcx
                               tt-map.t-sit    = "T".

                        find first tt-caixa where 
                                   tt-caixa.etbcod = estab.etbcod and
                                   tt-caixa.cxacod = plani.cxacod no-error.
                        if not avail tt-caixa 
                        then do: 
                            create tt-caixa. 
                            assign tt-caixa.etbcod = estab.etbcod 
                                   tt-caixa.cxacod = plani.cxacod.
                        end.


                           
                    end.
                    
                end.
                else if vqt > 1
                then do:
                    
                    for each mapctb where mapctb.etbcod = plani.etbcod and
                                        mapctb.datmov = plani.pladat and
                                        mapctb.de1    = dec(plani.cxacod)
                                            no-lock .
                              
                    if mapctb.nrored <> vnrored
                    then next.
                    vcx = 0. 
                    find first tabecf 
                               where tabecf.etbcod = plani.etbcod and
                                     tabecf.de1    = plani.cxacod and
                                     tabecf.datini <= plani.pladat and
                                     tabecf.datfin >= plani.pladat 
                                            no-lock no-error.
                    if avail tabecf
                    then vcx = tabecf.equipa.
                    else next. /* vcx = plani.cxacod. */
                                            

                    find first tt-map where tt-map.t-etbcod = estab.etbcod and
                                            tt-map.t-datmov = vdata and
                                            tt-map.t-cxacod = plani.cxacod
                                                no-error.
                    if not avail tt-map
                    then do:
                   
                     
                        create tt-map.
                        assign tt-map.t-etbcod = estab.etbcod
                               tt-map.t-datmov = vdata
                               tt-map.t-cxacod = plani.cxacod
                               tt-map.t-equipa = vcx
                               tt-map.t-sit    = "D".

                        find first tt-caixa where 
                                   tt-caixa.etbcod = estab.etbcod and
                                   tt-caixa.cxacod = plani.cxacod no-error.
                        if not avail tt-caixa 
                        then do: 
                            create tt-caixa. 
                            assign tt-caixa.etbcod = estab.etbcod 
                                   tt-caixa.cxacod = plani.cxacod.
                        end.


                           
                    end.
                    end.

                end.
            end.
        end.                                
           
    end.       
    

    
    

 
    put "      DATA     RED.    VDA.07%   VDA.12%"
                "       VDA.17%        SUBST  TOTAL VDA"
                "     ISENTO        BASE      VAL.ICMS       FL  EQ CXA" skip
                 fill("-",120) format "x(120)" skip.

                
    for each tt-caixa,
        each tt-map where tt-map.t-etbcod = tt-caixa.etbcod and
                          tt-map.t-datmov >= vdti        and
                          tt-map.t-datmov <= vdtf        and
                          tt-map.t-cxacod = tt-caixa.cxacod and
                          tt-map.t-equipa > 0
                                    break by tt-map.t-etbcod
                                          by tt-map.t-cxacod:
     
        
         
        put tt-map.t-datmov
            tt-map.t-redz   format ">>>>>>99"            to 19
            tt-map.t-ven07  format ">>>,>>9.99"          to 30
            tt-map.t-ven12  format ">>>,>>9.99"          to 40
            tt-map.t-ven17  format ">>>,>>9.99"          to 54
            tt-map.t-vensub format ">>>,>>9.99"          to 67
            tt-map.t-totven format ">>>,>>9.99"          to 78
            tt-map.t-vlise  format ">>>,>>9.99"          to 89
            tt-map.t-bas17  format ">>>,>>9.99"          to 101
            tt-map.t-icm17  format ">>>,>>9.99"          to 115
            tt-map.t-sit                                 to 120 
            tt-map.t-etbcod                              to 124
            tt-map.t-cxacod    format ">9"                          to 128 
            tt-map.t-equipa skip.
         
         
    end.
   
    output close.
    if opsys = "unix"
    then do:
        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i} 
    end.     
       
end.    
