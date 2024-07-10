{admcab.i}
def var total-lp like plani.platot.
def var varquivo as char format "x(20)".

def var vdtini      like plani.pladat label "Data Inicial".
def var vdtfim      like plani.pladat label "Data Final".
def var vatraso     as log.
def var vetbcod like estab.etbcod.
repeat:


    update vetbcod label "Filial" colon 20
             with width 80 color white/cyan side-labels row 4.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label.
    update vdtini colon 20
           vdtfim colon 60.

    if opsys = "UNIX"
    then varquivo = "/admcom/relat/venatr" + string(time).
    else varquivo = "..\relat\venatr" + string(time).


    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "137"
        &Page-Line = "66"
        &Nom-Rel   = """VENATR"""
        &Nom-Sis   = """SISTEMA CREDIARIO"""
        &Tit-Rel   = """VENDA COM PARCELAS ATRASADAS "" +
                      ""LOJA "" + string(estab.etbcod)
                        + "" - ""
                        + estab.etbnom + "" DE "" + string(vdtini) + "" A "" +
                                                    string(vdtfim) "
        &Width     = "137"
        &Form      = "frame f-cab"}

    for each fin.contrato use-index mala where
                fin.contrato.etbcod    = estab.etbcod and
                fin.contrato.dtinicial >= vdtini and
                fin.contrato.dtinicial <= vdtfim no-lock.

        find clien where clien.clicod = fin.contrato.clicod no-lock no-error.
        if not avail clien 
        then next. 
        vatraso = yes.

        total-lp = 0.
        for each d.titulo where d.titulo.clifor = fin.contrato.clicod no-lock:
                

            if d.titulo.titsit = "lib" 
            then total-lp = total-lp + d.titulo.titvlcob.
            
                
        end.     
                    
        
        for each fin.titulo where 
                        fin.titulo.clifor = fin.contrato.clicod no-lock.

            if fin.titulo.titnum = string(fin.contrato.contnum)
            then next.

            if fin.titulo.titdtven > fin.contrato.dtinicial
            then next.

            if fin.titulo.titsit  = "PAG"
            then next.

            if fin.titulo.titnat = yes
            then next.

            if vatraso
            then do:
               
                vatraso = no.
                find clien where clien.clicod = fin.titulo.clifor no-lock.
                display 
                    fin.titulo.etbcod
                    clien.clinom format "x(30)"
                    clien.clicod format ">>>>>>>>>9"
                    fin.contrato.contnum  format ">>>>>>>>>9"
                    fin.contrato.dtinicial  format "99/99/9999" 
                    fin.contrato.vltotal
                    fin.contrato.vlent
                    fin.contrato.vltotal - fin.contrato.vlent 
                                format ">>>,>>9.99"
                        with frame f-cont2 width 137 no-labels no-box.

                display total-lp label "Saldo aberto na LP"
                            with frame f-lp side-label.
    
                        
            end.
            display
                fin.titulo.titnum column-label "Contrato"  at 59
                fin.titulo.titpar
                fin.titulo.etbcod
                fin.titulo.titdtemi
                fin.titulo.titdtven
                fin.titulo.titvlcob
                fin.contrato.dtinicial - fin.titulo.titdtven format "->>9"
                            column-label "Dias Atraso"
                     with width 150 no-box.
        end.
        if vatraso and total-lp > 0
        then do:
            find first fin.titulo where 
                                fin.titulo.clifor = fin.contrato.clicod and
                                fin.titulo.titsit = "lib" no-lock no-error.
            if avail fin.titulo
            then do:
                display 
                    fin.contrato.etbcod
                    clien.clinom format "x(30)"
                    clien.clicod format ">>>>>>>>>9"
                    fin.contrato.contnum format ">>>>>>>>>9"
                    fin.contrato.dtinicial  format "99/99/9999" 
                    fin.contrato.vltotal
                    fin.contrato.vlent
                    fin.contrato.vltotal - fin.contrato.vlent 
                                format ">>>,>>9.99"
                         with frame f-cont3 width 137 no-labels no-box.
            
                 display total-lp label "Saldo aberto na LP"
                            with frame f-lp2 side-label.

            end.

        end.    
                                
        
    end.
    /***
    output close.
    {mrod.i}
    ***/
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
        


end.

