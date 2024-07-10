{admcab.i}.

def var vtotal  like plani.platot.
def var vdataini as date label "Dt.Inicial" format "99/99/9999".
def var vdatafin as date label "Dt.Final"   format "99/99/9999".
def var varquivo as char.
def temp-table tt-credito
    field etbcod like estab.etbcod
    field valor  like titulo.titvlcob.

repeat:
    for each tt-credito:
        delete tt-credito.
    end.
    
    update vdataini
           vdatafin with frame f-data
                    centered 1 down side-labels title "Datas".

    varquivo = "..\relat\forn" + string(time).
    
    {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "147"
            &Page-Line = "66"
            &Nom-Rel   = ""magfor1""
            &Nom-Sis   = """SISTEMA CONTABILIDADE"""
            &Tit-Rel   = """ARQUIVO MAGNETICO FORNECEDOR "" +
                        ""  - Data: "" + string(vdataini) + "" A "" +
                            string(vdatafin)"
            &Width     = "147"
            &Form      = "frame f-cabcab1"}


                                                 
    display " D E B I T O "
                    with frame f-title centered.
    
    vtotal = 0.
    for each lancxa where lancxa.datlan >= vdataini
                      and lancxa.datlan <= vdatafin no-lock:
                  
        if lancxa.lancod <> 100
        then next.
        display lancxa.forcod  
                lancxa.datlan
                lancxa.comhis format "x(50)"  
                lancxa.vallan(total) format ">>>,>>>,>>9.99"
                        with frame f1 down width 137.
        
        vtotal = vtotal + lancxa.vallan.
        
    end.                                           
       
    display " C R E D I T O "
                    with frame f-title2 centered.
    
    for each estab no-lock:
        for each fiscal where fiscal.movtdc = 04           and
                              fiscal.desti  = estab.etbcod and
                              fiscal.plarec >= vdataini    and
                              fiscal.plarec <= vdatafin no-lock:

            if fiscal.bicms = 0
            then next.
        
            find first tt-credito where tt-credito.etbcod = fiscal.desti
                                            no-error.
            if not avail tt-credito
            then do:
                create tt-credito.
                assign tt-credito.etbcod = fiscal.desti.
            end.
            tt-credito.valor = tt-credito.valor + fiscal.bicms.
            
            /*
            
            display fiscal.desti  
                    fiscal.emite  
                    fiscal.plaemi 
                    fiscal.plarec 
                    fiscal.numero        format "9999999"
                    fiscal.opfcod        format "9999"
                    fiscal.bicms(total by fiscal.desti)  
                        format ">>>,>>>,>>9.99"
                            with frame f-fiscal down width 137.
            */
        end.
        
        for each lancxa where lancxa.datlan >= vdataini and
                              lancxa.datlan <= vdatafin and
                              lancxa.etbcod = estab.etbcod 
                                    no-lock:
                  
            if lancxa.forcod = 533    or
               lancxa.forcod = 100071 or
               lancxa.forcod = 101998 or
               lancxa.forcod = 102044 or
               lancxa.forcod = 103114
            then do:
                /*
                display lancxa.forcod  
                        lancxa.datlan
                        lancxa.comhis format "x(50)"  
                        lancxa.vallan(total by lancxa.etbcod) 
                                format ">>>,>>>,>>9.99"
                            with frame f2 down width 137.
        
                */
                find first tt-credito where tt-credito.etbcod = lancxa.etbcod
                                            no-error.
                if not avail tt-credito
                then do:
                    create tt-credito.
                    assign tt-credito.etbcod = lancxa.etbcod.
                end.
                tt-credito.valor = tt-credito.valor + lancxa.vallan.
            
    
            end.
        end.     
    end.
    for each tt-credito:
        display tt-credito.etbcod
                tt-credito.valor(total) with frame f-credito down.
    end.            
    output close.
    {mrod_l.i}
end.
    