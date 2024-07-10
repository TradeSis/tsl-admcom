{admcab.i}
def var vdti like chq.datemi.
def var vdtf like chq.datemi.
def var varquivo as char.
def var vetbcod like estab.etbcod.
def var valor as dec.
def temp-table tt-estab like estab.
def temp-table tt-chq like chq
    index i1 valor.

repeat:
    vdti = today.
    vdtf = today.
    vetbcod = 0.
    for each tt-estab: delete tt-estab. end.
    for each tt-chq: delete tt-chq. end.
    update vetbcod label "Filial" with frame f1.
    if vetbcod <> 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then next.
        disp estab.etbnom no-label with frame f1.
        create tt-estab.
        buffer-copy estab to tt-estab.
    end.
    else do:
        for each estab no-lock:
            create tt-estab.
            buffer-copy estab to tt-estab.
        end.
    end.
    find first tt-estab no-error.
    if not avail tt-estab then next.
    
    update vdti at 1 label "Data Inicial" 
           vdtf label "Data Final"
                    with frame f1 
                        side-label width 80 .
    
    update valor at 1 validate(valor <> 0,"") 
            label "Valor inicial" with frame f1.
    
    for each chq where chq.datemi >= vdti and
                       chq.datemi <= vdtf no-lock:
                       
        if chq.valor < valor then next.
        
        if chq.datemi = chq.data
        then next.
        
        create tt-chq.
        buffer-copy chq to tt-chq.
    end.
     
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/cheval" + string(time).
    else varquivo = "l:~\relat~\cheval" + string(time).

    {mdadmcab.i
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "160"
        &Page-Line = "66"
        &Nom-Rel   = ""cfcheval""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO"""
        &Tit-Rel   = """LISTAGEM DE CHEQUES """
        &Width     = "160"
        &Form      = "frame f-cabcab"}

    disp with frame f1.
    put skip(1).
    
    for each tt-chq use-index i1 no-lock,
        first chqtit where chqtit.banco   = tt-chq.banco
                            and chqtit.agencia = tt-chq.agencia
                            and chqtit.conta   = tt-chq.conta
                            and chqtit.numero  = tt-chq.numero 
                            no-lock :
        
        find first tt-estab where tt-estab.etbcod = chqtit.etbcod no-error.
        if not avail tt-estab
        then next.
               
        find clien where clien.clicod = chqtit.clifor no-lock no-error.
                    
        display chqtit.etbcod column-label "Fil"
                chqtit.clifor column-label "Codigo"
                clien.clinom when avail clien 
                tt-chq.datemi column-label "Emissao"
                tt-chq.comp
                tt-chq.banco
                tt-chq.agencia format ">>>>>>9"
                tt-chq.controle1
                tt-chq.conta format "x(15)"
                tt-chq.controle2
                tt-chq.numero
                tt-chq.controle3
                tt-chq.data column-label "Vencimento"
                tt-chq.valor(total) 
                    with frame f3 down width 200.
    end.           
    
    output close.  

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
        /*
        sresp = no.
        message "Confirma impressao ?" update sresp.
        if sresp
        then os-command silent /fiscal/lp value(varquivo).  
        */
    end.
    else do:
        {mrod.i} .
    end.
        
end. 