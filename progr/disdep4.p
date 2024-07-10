{admcab.i}
def var totlote as int format ">>>>>9".
def var vlote    as int.
def var vdiminui as int.
def var xx as dec.
def var vsoma as int.
def var vprocod like produ.procod.
def var vqtd    like movim.movqtm.
def var vv as int.
def var vgrupo as int.
def var vtot as int extent 30 format ">>>>>>>>999".
def var vtotal as char format "x(120)".
def var vpro as char format "x(120)".
def temp-table tt-produ
    field procod like produ.procod extent 99
    field etbcod like estab.etbcod
    field distr  as int format "->>>>>>>>>99" extent 99
    field grupo as int
    field lote  as log initial no
    field orddec as dec.

def var varquivo as char format "x(20)".
def var ii as int. 
def var i as int.
def temp-table tt-estab
    field etbcod   like estab.etbcod
    field estatual like estoq.estatual
    field estdistr like estoq.estatual
    field estdif   like estoq.estatual
    field proper   like distr.proper.

def var vdif as int.
def var q as int.
def var e as int.
def var tot01 as int.

def var vest as int.
repeat:
    assign vqtd  = 0
           vlote = 0
           totlote = 0.
           
    update vprocod label "Produto" with frame f1 side-label width 80.
    find produ where produ.procod = vprocod no-lock.
    display produ.pronom no-label with frame f1.
    update vqtd    label "Quantidade" with frame f1.
    
        

    for each tt-produ:
        delete tt-produ.
    end.


    ii = 0.
    vpro = "".
    ii = ii + 1.

    for each tt-estab:
        delete tt-estab.
    end.

    e = 0.
    q = 0.
    vdif = 0.

    for each estab where estab.etbcod < 900 no-lock:
        if {conv_igual.i estab.etbcod} then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq or estoq.estatual <= 0
        then next.
        e = e + estoq.estatual.
    
    end.
    

    e = e + vqtd.
    vgrupo = 0.
   
    
    find clase where clase.clacod = produ.clacod no-lock.
    find tipdis where tipdis.tipcod = clase.clacod no-lock no-error.
    if avail tipdis 
    then vgrupo = clase.clacod.
    else do:
        
        find tipdis where tipdis.tipcod = clase.clasup no-lock no-error.
        if avail tipdis
        then vgrupo = clase.clasup.
        
    end.
    
       
    if vgrupo = 0
    then do:
        if vqtd > 150
        then vgrupo = 0.
        else do:
            if e >= 200
            then vgrupo = 0.
            else vgrupo = 99.
        end.
    end.
     
    update vgrupo label "Distribuicao" 
           vlote   label "Lote"   with frame f1.
           
    if vlote > 0
    then do:
        if vqtd mod vlote <> 0
        then do:
            message "Lote nao confere com quantidade informada".
            undo, retry.
        end.
    end.       
    
    
    vpro = "Dis=" + string(vgrupo,"999").
    if vlote > 0
    then vpro = vpro + " De" + string(vlote,">99").
    else vpro = vpro + "      ".
    vpro = vpro + "     " + string(produ.procod,">>>>99").
    

    
    
    
    for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
       
        if {conv_igual.i estab.etbcod} then next.

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
       
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = vgrupo no-lock no-error.
        if not avail distr
        then do: 
            e = e - estoq.estatual.
            next.
        end.


        if estoq.estatual <= 0
        then vest = 0.
        else vest = estoq.estatual.

        q = (( e * (distr.proper / 100))).
        if q < 0
        then q = 0.
        
        if vest >= q
        then assign e = e - ( vest - q).
        
    end.
    
    vdif = 0.
    
    for each estab where estab.etbcod < 900 and
                         estab.etbcod <> 22 no-lock:
        if {conv_igual.i estab.etbcod} then next.
        
        find distr where distr.etbcod = estab.etbcod and
                         distr.clacod = vgrupo no-lock no-error.
        if not avail distr
        then next.


        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then do transaction: 
           create estoq.
             assign estoq.etbcod = estab.etbcod
                    estoq.procod = produ.procod.
        end.
        
        if estoq.estatual <= 0
        then vest = 0.
        else vest = estoq.estatual.

        q = (( e * (distr.proper / 100))).
        if q < 0
        then q = 0.

        
        if vest >= q
        then next.

        
        create tt-estab.
        assign tt-estab.etbcod   = estab.etbcod
               tt-estab.estatual = vest
               tt-estab.estdistr = q
               tt-estab.proper   = distr.proper.
                              
                              
        vdif = vdif + (tt-estab.estdistr - tt-estab.estatual).
        
        

    end. 
    
    vdiminui = 0.
    vsoma    = 0.

    
    if vdif > vqtd
    then vdiminui = vdif - vqtd.

    
    if vdif < vqtd
    then vsoma = vqtd - vdif.
    
    
    repeat: 
        for each tt-estab by tt-estab.estdistr desc:
        
                                 
            if vsoma > 0  
            then do:
            
                tt-estab.estdistr = tt-estab.estdistr + 1.
                vsoma = vsoma - 1.
            
            end.
            
            
            if vdiminui > 0 
            then do:
                tt-estab.estdistr = tt-estab.estdistr - 1.
                vdiminui = vdiminui - 1.
            
                if (tt-estab.estdistr - tt-estab.estatual) <= 0 
                then assign tt-estab.estdistr = tt-estab.estdistr + 1
                            vdiminui = vdiminui + 1. 
            end.


            find first tt-produ where tt-produ.etbcod = tt-estab.etbcod 
                            no-error.
            if not avail tt-produ
            then do:
                create tt-produ.
                assign tt-produ.etbcod = tt-estab.etbcod.
            end.
            assign tt-produ.procod[ii] = produ.procod
                   tt-produ.distr[ii]  = 
                            (tt-estab.estdistr - tt-estab.estatual)
                   tt-produ.grupo      = vgrupo.

        
        end.
    
        if vsoma    = 0 and
           vdiminui = 0
        then leave.
    end.
    

    if vlote > 0
    then do:
        /*
        vv = 0.
        for each tt-produ by tt-produ.distr[ii] desc:
    
                
            find distr where distr.etbcod = tt-produ.etbcod and
                             distr.clacod = vgrupo no-lock no-error.
            if not avail distr
            then next.

            tt-produ.distr[ii] = vlote.  
 
        end.
        */
        
        vv = 0.
        for each tt-produ by tt-produ.distr[ii] desc:
    
                
            find distr where distr.etbcod = tt-produ.etbcod and
                             distr.clacod = vgrupo no-lock no-error.
            if not avail distr
            then next.
 
            
            /*
            display tt-produ.etbcod
                    tt-produ.distr[ii]
                    distr.proper.
            
            */
                      
            
            
            
            
            xx = int(((vqtd / vlote) * (distr.proper / 100))).

            
            tt-produ.distr[ii] = (xx * vlote).
            
            
            vv = vv + (tt-produ.distr[ii] / vlote). 
            
            
            
            tt-produ.orddec = (xx - (int(xx - 0.5))).
            
            
            tt-produ.lote = yes.

            /*
            display tt-produ.etbcod(count)
                    tt-produ.distr[ii](total)
                    distr.proper
                    tt-produ.orddec
                    xx(total)
                    vv(total).
            */
            
            
            if vv >= vqtd / vlote
            then do:

                leave.
                               
            end.
            
            
        end.
        
        assign vdiminui = 0
               vsoma    = 0.
        
        if vv > (vqtd / vlote)
        then vdiminui = vv - (vqtd / vlote).
        else vsoma    = (vqtd / vlote) - vv.
        
        
        
        repeat:
        for each tt-produ by tt-produ.distr[ii] desc:
    
                
            find distr where distr.etbcod = tt-produ.etbcod and
                             distr.clacod = vgrupo no-lock no-error.
            if not avail distr
            then next.
 
                                
            if vsoma > 0  
            then do:
            
                tt-produ.distr[ii] = tt-produ.distr[ii] + vlote.
                vsoma = vsoma - 1.
            
            end.
            
            
            if vdiminui > 0 
            then do:
                

                tt-produ.distr[ii] = tt-produ.distr[ii] - vlote.
                vdiminui = vdiminui - 1.
            
                
                
                if tt-produ.distr[ii] <= 0 
                then assign tt-produ.distr[ii] = tt-produ.distr[ii] + vlote
                            vdiminui = vdiminui + 1. 

            end.
        end.
        
        if vsoma    = 0 and
           vdiminui = 0
        then leave.
            
        end. 
    
    end.
    
        
    varquivo = "c:\temp\distr" + string(day(today)). 

    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""disdep4""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """DISTRIBUICAO DE MERCADORIA POR FILIAL""" 
        &Width     = "130"
        &Form      = "frame f-cabcab"}



    put skip "Filial   Lote     ".

    i = 0.
    do i = 1 to ii:
        put "Codigo    Perc     ".
        vtot[i] = 0.
    end.
    
    put skip.


    find first tt-produ no-error.
    if not avail tt-produ
    then next.
    i = 0.

    put vpro skip fill("-",120) format "x(120)" skip. 
    
    for each tt-produ by tt-produ.etbcod:
                       
        if vlote > 0
        then if tt-produ.lote = no
             then next. 
        
        
        find distr where distr.etbcod = tt-produ.etbcod and
                         distr.clacod = vgrupo no-lock no-error.
        if not avail distr
        then next.
        

        
        i = 0.
        put tt-produ.etbcod "     ".
          
        do i = 1 to ii:

           if vlote > 0
           then do:
               put (tt-produ.distr[i] / vlote) format ">>9".
               totlote = totlote + (tt-produ.distr[i] / vlote).
           end.     
           else put "   ".
           
           put tt-produ.distr[i] "  ".

           vtot[i] = vtot[i] + tt-produ.distr[i].
        
        end.

        put distr.proper "  ".
        
        put skip.

        i = 0.
   
    end.
    vtotal = "".
    do i = 1 to ii:
        vtotal = vtotal + string(vtot[i],">>>>>>>>>>99").
    end.
    
    put skip 
        fill("-",120) format "x(120)" skip
        "Total "
        totlote
        vtotal                        skip
        fill("-",120) format "x(120)" skip.

    output close.
    {mrod.i}
    
    
end.         

