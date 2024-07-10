{admcab.i}.


def stream stela.
def temp-table  tt-mag
    field etbcod like estab.etbcod
    field tipo   as logical format "Debito/Credito"
    field valor  as dec format ">>>,>>>,>>9.99".
    

def var vtotal  like plani.platot.
def var vdataini as date label "Dt.Inicial" format "99/99/9999".
def var vdatafin as date label "Dt.Final"   format "99/99/9999".
def var varquivo as char.

repeat:
    
    for each tt-mag.
        delete tt-mag.
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
            &Nom-Rel   = ""magfor""
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
        

        find first tt-mag where tt-mag.etbcod = lancxa.etbcod and
                                tt-mag.tipo   = yes no-error.
        if not avail tt-mag
        then do:
            create tt-mag.
            assign tt-mag.etbcod = lancxa.etbcod
                   tt-mag.tipo   = yes.
        end.
        tt-mag.valor = tt-mag.valor + lancxa.vallan.
                   
        
        vtotal = vtotal + lancxa.vallan.
        
    end.     
       
    display " C R E D I T O "
                    with frame f-title2 centered.
    
    for each estab no-lock,
        each fiscal where fiscal.movtdc = 04           and
                          fiscal.desti  = estab.etbcod and
                          fiscal.plarec >= vdataini    and
                          fiscal.plarec <= vdatafin no-lock:

        if fiscal.bicms = 0
        then next.
        find forne where forne.forcod = fiscal.emite no-lock no-error.
        
        find first tt-mag where tt-mag.etbcod = fiscal.desti and
                                tt-mag.tipo   = no no-error.
        if not avail tt-mag
        then do:
            create tt-mag.
            assign tt-mag.etbcod = fiscal.desti
                   tt-mag.tipo   = no.
        end.
        tt-mag.valor = tt-mag.valor + fiscal.platot.
        
         
        
        display fiscal.desti  
                fiscal.emite  
                forne.fornom when avail forne
                fiscal.plarec 
                fiscal.numero        format "9999999"
                fiscal.opfcod        format "9999"
                fiscal.platot(total)  format ">>>,>>>,>>9.99"
                        with frame f-fiscal down width 137.
    end.
    output stream stela to terminal.
    for each tt-mag where tt-mag.tipo = yes by tt-mag.etbcod.
    
        disp stream stela 
             tt-mag.etbcod column-label "Filial"
             tt-mag.valor(total) 
                with frame f01 down width 30 column 10 title "DEBITO".
    
    end.

    for each tt-mag where tt-mag.tipo = no by tt-mag.etbcod.
    
        disp stream stela 
             tt-mag.etbcod column-label "Filial"
             tt-mag.valor(total) 
                with frame f02 down width 30 column 40 title "CREDITO".
    
    end.

    output stream stela close.
    
    
    output close.
    message "Deseja Listar os lancamentos" update sresp.
    if sresp
    then do:
        {mrod_l.i} 
    end.
end.
    