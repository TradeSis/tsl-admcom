{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vv   as int.
def temp-table tt-nova
    field etbcod like estab.etbcod
    field qtd    as int
    field val    like plani.platot
    field vtotal like titulo.titvlcob
    field ventra like titulo.titvlcob
    field japlic like titulo.titvlcob
    field clifor like clien.clicod
    field origem as dec.

def var vesc as char format "x(15)" extent 2
        init["ANALITICO","SINTETICO"]. 
    
def temp-table tt-cli
    field clicod like clien.clicod
    field vltotal like contrato.vltotal
    field origem  as dec
    field entrada as dec
    .
    
def temp-table tt-cont
    field etbcod like estab.etbcod
    field contnum like contrato.contnum
    index i1 etbcod contnum
    .

def temp-table tt-titulo like titulo.
def temp-table tt-contrato like contrato.
def var varquivo as char.
def var t-entrada as dec.
def var t-total as dec.
def var vezes as int.
def var vparcela as dec.
def var val-juro as dec.
def var val-origem as dec.
def buffer btitulo for titulo.
def var vindex as int.
repeat:
    /*
    update vetbcod label "Filial" with frame f1 side-label width 80.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label with frame f1.
    */
    for each tt-nova.
        delete tt-nova.
    end.
    
    update vdti label "Data Inicial"
           vdtf label "Data Final " with frame f1 side-label width 80.
        
    do on error undo:
        message "Informe a Filial para analitico" update vetbcod.  
        if vetbcod > 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab then undo.
        end.     
    end.
    for each tt-contrato:
        delete tt-contrato.
    end.
    for each tt-titulo:
        delete tt-titulo.
    end.    
    IF VETBCOD = 0
    then do:
        disp vesc with frame f-esc 1 down no-label.
        choose field vesc with frame f-esc.
        vindex = frame-index.
        hide frame f-esc.
        message "AGUARDE PROCESSAMENTO... " VESC[vindex].
    end.

    run sel-contrato.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/lin." + string(time).
    else varquivo = "l:~\relat~\lin." + string(time).

    {mdadmcab.i &Saida = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "80"
                &Page-Line = "66"
                &Nom-Rel   = ""connov""
                &Nom-Sis   = """SISTEMA CREDIARIO"""
                &Tit-Rel   = """ LISTAGEM DE INCLUSOES DE NOVACAO ""  +
                            "" PERIODO "" + string(vdti) + "" ATE "" +
                            string(vdtf)"
                &Width     = "80"
                &Form      = "frame f-cabc1"}

    if vetbcod > 0
    then
    disp "Analitico da Filial: " vetbcod
        with frame ff-f 1 down no-label.
         
    for each contrato where contrato.datexp >= vdti    and
                            contrato.datexp <= vdtf no-lock:
        if vetbcod > 0 and
           contrato.etbcod <> vetbcod
        then next.                    
        find first titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = contrato.etbcod and
                          titulo.clifor = contrato.clicod and
                          titulo.titnum = string(contrato.contnum)  and
                          titulo.titpar = 31
                          no-lock no-error. 
        if avail titulo
        then do:       
                   
            find first tt-nova where tt-nova.etbcod = contrato.etbcod                                  no-error.
            if not avail tt-nova
            then do:
                create tt-nova.
                assign 
                    tt-nova.etbcod = contrato.etbcod
                    .
            end.
            assign tt-nova.qtd = tt-nova.qtd + 1
                   tt-nova.val = tt-nova.val + contrato.vltotal
                   .
            /*
            if vetbcod > 0
            then do:*/
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                create tt-contrato.
                buffer-copy contrato to tt-contrato.
            /*end.*/
        end.
    end.
    if vetbcod = 0 and vindex = 2
    then do:
        run por-filial.
        for each tt-nova break by tt-nova.etbcod.
            tt-nova.japlic = tt-nova.vtotal - tt-nova.origem.
            disp tt-nova.etbcod column-label "Filial"
                 tt-nova.qtd(total) column-label "Quant"
                 tt-nova.vtotal(total) column-label "Valor Total"
                 tt-nova.ventra(total) column-label "Valor Entrada"
                 tt-nova.origem(total) column-label "Valor Original"
                 tt-nova.japlic(total) column-label "Juro Aplicado"
                        format "->>,>>>,>>9.99"
                 with frame f2 down width 100.
        end.
    end.
    else 
    for each tt-contrato:
        find clien where clien.clicod = tt-contrato.clicod no-lock.
        t-entrada = tt-contrato.vlentra.
        if t-entrada = 0
        then do:
            find first        titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = tt-contrato.etbcod and
                          titulo.clifor = tt-contrato.clicod and
                          titulo.titnum = string(tt-contrato.contnum)  and
                          (titulo.titpar = 0 or
                           titulo.titpar = 31)
                          no-lock no-error.
            if avail titulo
            then t-entrada = titulo.titvlcob.
         end.                   

         t-total = 0.
         vezes = 0.
         vparcela = 0.
         for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = tt-contrato.etbcod and
                          titulo.clifor = tt-contrato.clicod and
                          titulo.titnum = string(tt-contrato.contnum)
                          no-lock:
            if vparcela = 0 and
               titulo.titpar > 31
            then vparcela = titulo.titvlcob.   
            if vezes < titulo.titpar
            then vezes = titulo.titpar.
            t-total = t-total + titulo.titvlcob.
        end.
        if tt-contrato.vlentra > 0
        then  vezes = vezes - 30.
        else vezes  = vezes - 31.
        val-origem = 0.
        for each btitulo where btitulo.empcod = 19 and
                               btitulo.titnat = no and
                               btitulo.modcod = "CRE" and
                               btitulo.titdtpag = tt-contrato.dtinicial and
                               btitulo.clifor = tt-contrato.clicod 
                               no-lock.
                               
            if btitulo.moecod = "NOV"
            then val-origem = val-origem + btitulo.titvlcob.
            
        end.
        find first  tt-cli where 
                    tt-cli.clicod = tt-contrato.clicod
                     no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod  = tt-contrato.clicod.
            tt-cli.origem  = tt-cli.origem + val-origem.
                    .
        end.
        tt-cli.vltotal = tt-cli.vltotal + tt-contrato.vltotal .
        tt-cli.entrada = tt-cli.entrada + t-entrada
        .
    end. 
    if vetbcod > 0 or vindex = 1
    then
    for each tt-cli:
        find clien where clien.clicod = tt-cli.clicod no-lock.
           
        val-juro = tt-cli.vltotal - tt-cli.origem.
        
        disp 
             clien.clicod
             clien.clinom format "x(30)"
             tt-cli.vltotal(total) column-label "Valor Total"
             tt-cli.entrada(total) column-label "Valor Entrada"
             tt-cli.origem(total) column-label "Valor Original"
             /*t-entrada(total) column-label "Entrada"
             /*t-total*/
             vparcela column-label "Parcela"
             vezes  column-label "Plano"
             */
             val-juro (total) column-label "Juro!Aplicado" 
             with frame f-cont down width 120.
    end.         
    /*
    for each tt-titulo.
        find clien where clien.clicod = tt-titulo.clifor no-lock. 
        disp tt-titulo.clifor
             clien.clinom
             tt-titulo.titnum
             tt-titulo.titvlcob(total)
             with frame f-tit down width 120.
    end.
    */         
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
    {mrod.i}
    end.
end.

procedure por-filial:
    for each tt-cli:
        delete tt-cli.
    end.    
    for each tt-contrato:
        find clien where clien.clicod = tt-contrato.clicod no-lock.
        t-entrada = tt-contrato.vlentra.
        if t-entrada = 0
        then do:
            find first        titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = tt-contrato.etbcod and
                          titulo.clifor = tt-contrato.clicod and
                          titulo.titnum = string(tt-contrato.contnum)  and
                          (titulo.titpar = 0 or
                           titulo.titpar = 31)
                          no-lock no-error.
            if avail titulo
            then t-entrada = titulo.titvlcob.
         end.                   

         t-total = 0.
         vezes = 0.
         vparcela = 0.
         for each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = tt-contrato.etbcod and
                          titulo.clifor = tt-contrato.clicod and
                          titulo.titnum = string(tt-contrato.contnum)
                          no-lock:
            if vparcela = 0 and
               titulo.titpar > 31
            then vparcela = titulo.titvlcob.   
            if vezes < titulo.titpar
            then vezes = titulo.titpar.
            t-total = t-total + titulo.titvlcob.
        end.
        if tt-contrato.vlentra > 0
        then  vezes = vezes - 30.
        else vezes  = vezes - 31.
        val-origem = 0.
        for each btitulo where btitulo.empcod = 19 and
                               btitulo.titnat = no and
                               btitulo.modcod = "CRE" and
                               btitulo.titdtpag = tt-contrato.dtinicial and
                               btitulo.clifor = tt-contrato.clicod
                               no-lock.
                               
            if btitulo.moecod = "NOV"
            then val-origem = val-origem + btitulo.titvlcob.
            
        end.
        val-juro = (tt-contrato.vltotal /*+ tt-contrato.vlentra*/) - val-origem.
        
        find first tt-nova where
                   tt-nova.etbcod = tt-contrato.etbcod 
                    no-error.
                    
        if not avail tt-nova
        then do:
            create tt-nova.
            tt-nova.etbcod = tt-contrato.etbcod.
        end.
        assign
            tt-nova.vtotal = tt-nova.vtotal + tt-contrato.vltotal
            tt-nova.ventra = tt-nova.ventra + t-entrada
            tt-nova.japlic = tt-nova.japlic + val-juro
            .
        find first  tt-cli where 
                    tt-cli.clicod = tt-contrato.clicod
                     no-error.
        if not avail tt-cli
        then do:
            create tt-cli.
            tt-cli.clicod  = tt-contrato.clicod.
            tt-cli.origem  = tt-cli.origem + val-origem.
            tt-nova.origem = tt-nova.origem + val-origem
                    .
        end.
    
    end.  
    
end procedure.

procedure sel-contrato.
    
    for each contrato where contrato.datexp >= vdti    and
                            contrato.datexp <= vdtf no-lock:
        if vetbcod > 0 and
           contrato.etbcod <> vetbcod
        then next. 
        create tt-cont.
        assign
            tt-cont.etbcod = contrato.etbcod 
            tt-cont.contnum = contrato.contnum
            .
    end.    
        
    for each titulo where
             titulo.datexp >= vdti and
             titulo.datexp <= vdtf and
             titulo.titpar = 31
             no-lock:
        if vetbcod > 0 and
            titulo.etbcod <> vetbcod
        then next.
        find first tt-cont where
                   tt-cont.etbcod = titulo.etbcod and
                   tt-cont.contnum = int(titulo.titnum)
                     no-error.
        if not avail tt-cont
        then do:             
            create tt-contrato.
            assign
                tt-contrato.etbcod = titulo.etbcod
                tt-contrato.contnum = int(titulo.titnum)
             .
        end.
    end.
                 
end procedure.