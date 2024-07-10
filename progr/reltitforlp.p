{admcab.i}

def new shared temp-table tt-plani like plani.
 
def new shared temp-table tt-titulo
    field titnum   like banfin.titulo.titnum format "x(7)"
    field titpar   like banfin.titulo.titpar format "99"
    field modcod   like banfin.titulo.modcod
    field titdtemi like banfin.titulo.titdtemi format "99/99/9999"
    field titdtven like banfin.titulo.titdtven format "99/99/9999"
    field titvlcob like banfin.titulo.titvlcob column-label "Vl.Cobrado"
                       format ">>>,>>9.99"
    field titvlpag like banfin.titulo.titvlpag format ">>>,>>9.99"
    field titdtpag like banfin.titulo.titdtpag format "99/99/9999"
    field titvljur like banfin.titulo.titvljur 
    field titvldes like banfin.titulo.titvldes
    field titsit   like banfin.titulo.titsit
    field etbcod   like banfin.titulo.etbcod column-label "FL" format ">>9"
    field clifor   like banfin.titulo.clifor
    field titbanpag like banfin.titulo.titbanpag
    field marca as char
    index ind-1 titdtemi desc.

def buffer bplani for plani.
def var i as i.
def var vcob like banfin.titulo.titvlcob.
def var vpag like banfin.titulo.titvlcob.
def var vforcod like forne.forcod.
def var i-serie as int.
def var vdti as date.
def var vdtf as date.

repeat:

    for each tt-titulo:
        delete tt-titulo.
    end.
    vcob = 0.
    vpag = 0.

    update vdti label "Periodo" format "99/99/9999"
           vdtf no-label format "99/99/9999"
            with frame f1.
    if vdti = ? or vdtf = ? or vdti > vdtf
    then undo.
    update vforcod at 1 with frame f1 side-label width 80 .
    if vforcod > 0
    then do:
    find forne where forne.forcod = vforcod no-lock no-error.
    if not avail forne
    then do:
        message "Fornecedor nao cadastrato".
        undo, retry.
    end.
    disp forne.fornom no-label with frame f1 width 80 .
    end.
    else disp "Geral" @ forne.fornom with frame f1.
    
    for each tt-plani: delete tt-plani. end.
    
    for each forne where (if vforcod > 0
            then forne.forcod = vforcod else true) no-lock:
        disp "Aguarde processamento... " forne.forcod 
                with frame f-cb no-label 1 down row 10.
        pause 0.
        for each banfin.titulo where 
                 banfin.titulo.clifor = forne.forcod and
                 banfin.titulo.titnat = yes and
                 banfin.titulo.titdtemi >= vdti and
                 banfin.titulo.titdtemi <= vdtf no-lock:
            
        if  titulo.modcod = "BON" or
            titulo.modcod = "DEV" or
            titulo.modcod = "CHP" then next.

        if banfin.titulo.titsit = "PAG"
        then.
        else next.
        
        find first fatudesp where
                   fatudesp.clicod = forne.forcod and
                   fatudesp.fatnum = int(banfin.titulo.titnum)
                   no-lock no-error.
                   
        create tt-titulo.
        assign tt-titulo.titnum   =  titulo.titnum 
               tt-titulo.titpar   =  titulo.titpar 
               tt-titulo.modcod   = titulo.modcod
               tt-titulo.titdtemi = titulo.titdtemi 
               tt-titulo.titdtven = titulo.titdtven 
               tt-titulo.titvlcob = titulo.titvlcob 
               tt-titulo.titvlpag = titulo.titvlpag 
               tt-titulo.titdtpag = titulo.titdtpag 
               tt-titulo.titsit   = titulo.titsit
               tt-titulo.etbcod   = titulo.etbcod
               tt-titulo.clifor   = titulo.clifor
               tt-titulo.titbanpag = titulo.titbanpag
               .

        if avail fatudesp
        then tt-titulo.marca = "*".       
        
        if titulo.titsit <> "pag"       
        then tt-titulo.titvlcob = (titulo.titvlcob + 
                                   titulo.titvljur -
                                   titulo.titvldes).
                        
                                  
        
        vcob = vcob + tt-titulo.titvlcob.
        vpag = vpag + titulo.titvlpag.
        end.
    end.
    run relatorio.    
    leave.
end.

procedure relatorio:

    def var varquivo as char.
    
    varquivo = "/admcom/relat/reltitforlp" + string(time) + ".txt".
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "140" 
                &Page-Line = "66" 
                &Nom-Rel   = ""reltitforlp"" 
                &Nom-Sis   = """SISTEMA ADMCOM FINANCEIRO""" 
                &Tit-Rel   = """RELATORIO DE TITULOS POR FORNECEDOR""" 
                &Width     = "140"
                &Form      = "frame f-cabcab"}

    
    disp with frame f1.
    
    for each tt-titulo no-lock break by tt-titulo.clifor:
        find forne where forne.forcod = tt-titulo.clifor no-lock no-error.
        disp tt-titulo.clifor
             forne.fornom when avail forne
             tt-titulo.titnum
             tt-titulo.titdtemi
             tt-titulo.titdtven
             tt-titulo.titvlcob(total by tt-titulo.clifor)
             format ">>>,>>>,>>9.99"
             tt-titulo.titvlpag(total by tt-titulo.clifor)
             format ">>>,>>>,>>9.99"
             tt-titulo.titdtpag
             /*tt-titulo.marca*/
             with frame f-disp down width 150.
        down with frame f-disp.     
    end.             
        
    output close.

    run visurel.p(varquivo,"").

end procedure.


