{admcab.i new}

def temp-table tt-estoq
    field etbcod like estoq.etbcod
    field est41  like estoq.estatual
    field est31  like estoq.estatual
    field est31-1 like estoq.estatual
    field est35  like estoq.estatual
    field med41  like estoq.estatual
    field med31  like estoq.estatual
    field med31-1 like estoq.estatual
    field med35  like estoq.estatual.
 
def var vi as int.
def var vv as int.
def var ac  as i.
def var tot as i.
def var de  as i.
def var vetbcod like estab.etbcod.
def var vmes as int format "99".
def var vano as int format "9999".
def var varquivo as char.
def var vindex as int.
def var vcusto like ctbhie.ctbcus.
def var tip-custo as char extent 2  FORMAT "x(20)"
        initial["CUSTO NOTA","CUSTO MEDIO"].
def var tipo-rel as char extent 2 FORMAT "x(20)"
        initial[" SINTETICO "," ANALITICO "].

def var vndx-rel as int.

def buffer bctbhie for ctbhie.

def var vetbi   like estab.etbcod.
def var vetbf   like estab.etbcod.

def var vtotal as dec format ">>>,>>>,>>9.99".

def var vindx-rel as int.

def temp-table tt-clase like clase.
run gera-ttclase.
def var vsetor as char format "x(15)".

def temp-table tt-ger
    field procod like produ.procod
    field pronom like produ.pronom
    field setor  as char format "x(15)"
    field qtd    as dec
    field ctomed as dec
    field ctonot as dec
    index i1 procod.

def var vultimo-custo as dec.
def var vdatref as date.

repeat:

    for each tt-estoq: delete tt-estoq. end.
    
    update vetbi label "Filial Inicial"
           vetbf label "Filial Final"
           with frame f1 centered color blue/cyan side-labels
                    width 80.
        
    if vetbi = 0 or vetbf = 0 or
       vetbi > vetbf
    then undo.
    
    /*
    find last ctbhie where ctbhie.etbcod = vetbcod no-lock no-error.
    if avail ctbhie
    then assign
            vmes = ctbhie.ctbmes
            vano = ctbhie.ctbano
            .
    */
    
    update skip
           vmes label "Mes..........."
           vano label "  Ano........."
           with frame f1.
 
    vindex = 2.
    vindx-rel = 1.
    disp tipo-rel no-label with frame f-trel 1 down centered.
    choose field tipo-rel with frame f-trel.
    vindx-rel = frame-index.
    
    vdatref = date(if vmes = 12 then 1 else vmes + 1,01,
                   if vmes = 12 then vano + 1 else vano) - 1.
    message vdatref.               
    /****
    {confir.i 1 "Listagem de inventario"}
    
    varquivo = "/admcom/relat/inv_" + string(vmes,"99") +
                "_" + string(vano,"9999") + "_" + string(vetbcod,"999")
                + "." + string(time).
            
    {mdad_l.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = """."""
        &Nom-Sis   = """."""
        &Tit-Rel   = """SALDO DE ESTOQUE  "" + 
                        "" EM "" + string(vmes,""99"") +
                        ""/"" + string(vano,""9999"")"
        &Width     = "160"
        &Form      = "frame f-cab"}
        
    ***/
    /***
    do vv = 1 to 125:
        put "" skip.
    end.    
    ***/
    disp with frame f1.
    pause 0.
    vtotal = 0.
    if vindx-rel = 2
    then do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:

            if estab.etbcod = 22 then next.
            for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano
                          no-lock:   
        
                find produ where produ.procod = ctbhie.procod no-lock no-error.
                if not avail produ
                then next.
 
                /*************************
                /*if ctbhie.ctbest < 1
                then next.*/
                if ctbhie.ctbcus <= 0
                then next.
                find produ where produ.procod = ctbhie.procod no-lock no-error.
                if not avail produ
                then next.
                if ctbhie.ctbmed > 0
                then vcusto = ctbhie.ctbmed.
                else vcusto = ctbhie.ctbcus.
                
                find last bctbhie where
                 bctbhie.etbcod = 0 and
                 bctbhie.procod = produ.procod and
                 bctbhie.ctbano = vano and
                 bctbhie.ctbmes <= vmes 
                 no-lock no-error.
                if not avail bctbhie
                then do vi = 1 to 10:
                find last bctbhie use-index ind-2 where
                     bctbhie.etbcod = 0 and
                     bctbhie.procod = produ.procod and
                     bctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail bctbhie
                then do:
                    leave.
                end.
                end.     
                if avail bctbhie and bctbhie.ctbcus <> ?
                then vcusto = bctbhie.ctbcus.
                else vcusto = 0.
            
                
                if vcusto = ?
                then vcusto = 0.      

                if vcusto = 0 then next.

                vtotal = vtotal + (vcusto * ctbhie.ctbest).
                
                def var vultimo-custo as dec.
                
                run ultimo-custo.
                if vcusto = 0
                then vcusto = vultimo-custo.
                if vultimo-custo = 0
                then vultimo-custo = vcusto.
                ************/
                
                vcusto = 0.
                vultimo-custo = 0.
                
                find last mvcusto where 
                          mvcusto.procod = produ.procod and
                          mvcusto.dativig <= vdatref
                          no-lock no-error.
                if avail mvcusto
                then assign
                         vcusto = mvcusto.valctomedio
                         vultimo-custo = mvcusto.valctonota
                         .
                
                if vultimo-custo <= 0
                then run ultimo-custo.
                
                if vcusto <= 0
                then do:
                    find last bctbhie where
                 bctbhie.etbcod = 0 and
                 bctbhie.procod = produ.procod and
                 bctbhie.ctbano = vano and
                 bctbhie.ctbmes <= vmes 
                 no-lock no-error.
                if not avail bctbhie
                then do vi = 1 to 10:
                find last bctbhie use-index ind-2 where
                     bctbhie.etbcod = 0 and
                     bctbhie.procod = produ.procod and
                     bctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail bctbhie
                then do:
                    leave.
                end.
                end.     
                if avail bctbhie and bctbhie.ctbcus <> ?
                then vcusto = bctbhie.ctbcus.
                else vcusto = 0.
            
 
                end.    
                      
                if vcusto <= 0 or vultimo-custo <= 0
                then next.
                       
                vsetor = "".
                vsetor = "OUTROS".
                if produ.catcod = 31
                then do:
                    find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                    if avail tt-clase
                    then vsetor = "ELETRO".
                    else vsetor = "MOVEIS".
                end.
                else if produ.catcod = 41
                then vsetor = "MODA".
                
                find first  tt-ger where 
                            tt-ger.procod = produ.procod
                            no-error.
                if not avail tt-ger
                then do:
                    create tt-ger.
                    assign
                        tt-ger.procod = produ.procod
                        tt-ger.pronom = produ.pronom
                        tt-ger.setor = vsetor
                        .
                end.

                tt-ger.qtd = tt-ger.qtd + ctbhie.ctbest.
                tt-ger.ctomed = vcusto.
                tt-ger.ctonot = vultimo-custo.
                
                /*
                if tt-ger.ctomed < vcusto
                then tt-ger.ctomed = vcusto.
                if tt-ger.ctonot < vultimo-custo
                then tt-ger.ctonot = vultimo-custo.
                */
                
                /********
                display 
                    estab.etbcod column-label "Fil"
                    produ.procod column-label "Codigo" 
                    produ.pronom FORMAT "x(50)"
                    vsetor       column-label "Grupo"
                    ctbhie.ctbest format ">>>>>>9"
                    vcusto column-label "Custo!Medido" format ">>,>>9.99"
                    (vcusto * ctbhie.ctbest)(total)
                        column-label "Subtotal!CMedido" format ">>,>>>,>>9.99"
                    vultimo-custo column-label "Ultimo!Custo" 
                                    format ">>,>>9.99"
                    (vultimo-custo * ctbhie.ctbest)(total)
                            column-label "Subtotal!UCusto"
                            format ">>,>>>,>>9.99"
                    with frame f2 down width 160.
                down with frame f2.
                *************/
            end.
        end.  
        
        output to /admcom/relat/relinv_1217.csv.
        put unformatted
        "Codigo;;Setor;Quant;CtoMed;;CtoNota;"
        skip.
        
        for each tt-ger no-lock:
            put unformatted
            tt-ger.procod ";"
            tt-ger.pronom ";"
            tt-ger.setor ";"
            tt-ger.qtd ";"
            tt-ger.ctomed ";"
            (tt-ger.ctomed * tt-ger.qtd) format ">>>>>>>>9.99"
            ";"
            tt-ger.ctonot
            ";"
            (tt-ger.ctonot * tt-ger.qtd) format ">>>>>>>>9.99"
            skip.
        end.
        output close.
            
        /******
        for each tt-ger no-lock:
            disp  
                    tt-ger.procod column-label "Codigo" 
                    tt-ger.pronom FORMAT "x(50)"
                    tt-ger.setor  column-label "Setor"
                    tt-ger.qtd format ">>>>>>9"
                    tt-ger.ctomed column-label "Custo!Medido" format ">>,>>9.99"
                    (tt-ger.ctomed * tt-ger.qtd)(total)
                        column-label "Subtotal!CMedido" format ">>,>>>,>>9.99"
                    tt-ger.ctonot column-label "Ultimo!Custo" 
                                    format ">>,>>9.99"
                    (tt-ger.ctonot * tt-ger.qtd)(total)
                            column-label "Subtotal!UCusto"
                            format ">>,>>>,>>9.99"
                    with frame f2 down width 160.
            down with frame f2.
        end.   
        ********/
        
    end.
    else if vindx-rel = 1
    then do:
        for each estab where estab.etbcod >= vetbi and
                             estab.etbcod <= vetbf
                             no-lock:
                                 
        if estab.etbcod = 22 then next.
        
        for each ctbhie where ctbhie.etbcod = estab.etbcod and
                          ctbhie.ctbmes = vmes    and
                          ctbhie.ctbano = vano    no-lock:
        
            /*if ctbhie.ctbest < 1
            then next.*/
            if ctbhie.ctbcus <= 0
            then next.
            find produ where produ.procod = ctbhie.procod no-lock no-error.
            if not avail produ
            then next.
            if ctbhie.ctbmed > 0
            then vcusto = ctbhie.ctbmed.
            else vcusto = ctbhie.ctbcus.

            find last bctbhie where
                 bctbhie.etbcod = 0 and
                 bctbhie.procod = produ.procod and
                 bctbhie.ctbano = vano and
                 bctbhie.ctbmes <= vmes 
                 no-lock no-error.
                if not avail bctbhie
                then do vi = 1 to 10:
                find last bctbhie use-index ind-2 where
                     bctbhie.etbcod = 0 and
                     bctbhie.procod = produ.procod and
                     bctbhie.ctbano = vano - vi 
                     no-lock no-error.
                if avail bctbhie
                then do:
                    leave.
                end.
                end.     
                if avail bctbhie and bctbhie.ctbcus <> ?
                then vcusto = bctbhie.ctbcus.
                else vcusto = 0.

            find first tt-estoq where tt-estoq.etbcod = ctbhie.etbcod no-error.
            if not avail tt-estoq
            then do:
                create  tt-estoq.
                assign  tt-estoq.etbcod = ctbhie.etbcod.
            end.
            
            if produ.catcod = 31
            then do:
                find first tt-clase where
                           tt-clase.clacod = produ.clacod no-lock no-error.
                if avail tt-clase
                then assign
                    tt-estoq.est31-1 = tt-estoq.est31-1 
                                        + (vcusto * ctbhie.ctbest)
                    tt-estoq.med31-1 = tt-estoq.med31-1 
                                        + (vcusto * ctbhie.ctbest)
                    .
                else assign
                    tt-estoq.est31 = tt-estoq.est31 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med31 = tt-estoq.med31 + (vcusto * ctbhie.ctbest)
                    .      
            end.                           
            if produ.catcod = 41
            then assign
                    tt-estoq.est41 = tt-estoq.est41 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med41 = tt-estoq.med41 + (vcusto * ctbhie.ctbest)
                    .

            if produ.catcod <> 31 and
               produ.catcod <> 41
            then assign
                    tt-estoq.est35 = tt-estoq.est35 + (vcusto * ctbhie.ctbest)
                    tt-estoq.med35 = tt-estoq.med35 + (vcusto * ctbhie.ctbest)
                    .
        end.
        end.

    for each tt-estoq by tt-estoq.etbcod:
        disp "Filial - " 
             tt-estoq.etbcod column-label "Filial" 
             tt-estoq.med31(total) column-label "CtoMedio Moveis" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med31-1(total) column-label "CtoMedio Eletro"
                                             format "->>,>>>,>>9.99"
             tt-estoq.med41(total) column-label "CtoMedio Confeccoes" 
                                format "->>,>>>,>>9.99" 
             tt-estoq.med35(total) column-label "CtoMedio Outros"
                                format "->>,>>>,>>9.99"    
             (tt-estoq.med31 + tt-estoq.med31-1 +
                tt-estoq.med41 + tt-estoq.med35)(total) 
                            column-label "CtoMedio Total" 
                         format "->>,>>>,>>9.99"                
             with frame f-imp width 130 down.
 
    end.
    end.
    /*output close. 

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    */
end. 

procedure ultimo-custo:
    vultimo-custo = 0.
    find last hiest where hiest.etbcod = 900 and
                          hiest.hieano = ctbhie.ctbano and
                          hiest.procod = ctbhie.procod
                          no-lock no-error.
    if not avail hiest
    then find last hiest where hiest.etbcod = 900 and
                               hiest.hieano < ctbhie.ctbano and 
                               hiest.procod = ctbhie.procod
                               no-lock no-error.
    
    if not avail hiest
    then for each estab no-lock:
            find last hiest where hiest.etbcod = estab.etbcod and
                               hiest.hieano <= ctbhie.ctbano and
                               hiest.procod = ctbhie.procod
                               no-lock no-error. 
            if avail hiest
            then do:
                vultimo-custo = hiest.hiepcf.
                leave.
            end.    
            
         end.
    else vultimo-custo = hiest.hiepcf.        
end procedure.

procedure gera-ttclase:
    def buffer grupo for clase.
    def buffer sub-clase for clase.
    for each grupo where grupo.clasup = 103000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.
    for each grupo where grupo.clasup = 114000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 128000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 129000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end. 
    for each grupo where grupo.clasup = 130000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.
    for each grupo where grupo.clasup = 140000000 no-lock.
        for each clase where clase.clasup = grupo.clacod no-lock:
            for each sub-clase where sub-clase.clasup = clase.clacod no-lock.
                create tt-clase.
                buffer-copy sub-clase to tt-clase.
            end.
        end.
    end.              
end procedure.
