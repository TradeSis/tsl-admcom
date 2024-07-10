
{admcab.i}

def var varquivo as char format "x(20)".
def var vdti as date.
def var vdtf as date.

def var vtitrel     as char format "x(50)".

def temp-table tt-titulo like titulo.

def var vtitvlcob as dec.
def var wtot as dec.
def buffer wmodal for modal.
def buffer wevent for event.
def var vnome like forne.fornom. 

repeat with  side-labels 1 down width 80 row 4 frame f1:

    update vdti label "Perirodo" format "99/99/9999"
           vdtf no-label format "99/99/9999"
           .
           
    for each modal no-lock:
        disp "Aguarde processamento... " modal.modcod 
                with frame f-cb no-label 1 down row 10.
        pause 0.
        if  modal.modcod = "BON" or
                            modal.modcod = "DEV" or
                            modal.modcod = "CHP" then next.

        for each estab no-lock:
            disp estab.etbcod with frame f-cb.
            pause 0.

            /*for each forne no-lock:
                disp forne.forcod with frame f-cb.
                pause 0.*/
                for each titulo use-index titdtven where titulo.empcod = 19 and
                                      titulo.titnat = yes and
                                      titulo.modcod = modal.modcod and
                                      titulo.etbcod = estab.etbcod and
                                      titulo.titdtven >= vdti and
                                      titulo.titdtven <= vdtf /*and
                                      titulo.clifor = forne.forcod and
                                      (titulo.titsit = "LIB" or
                                      titulo.titsit = "CON")   */      
                                      no-lock:

                        create tt-titulo.
                        buffer-copy titulo to tt-titulo.
                end.
            /*end.*/               
        end.
    end.

    varquivo = "/admcom/relat/rforvencer" + string(time).
        
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "180"  
        &Page-Line = "66"
        &Nom-Rel   = ""rforvencer""  
        &Nom-Sis   = """SISTEMA ADMCOM FINANCEIRO"""
        &Tit-Rel   = """RELATORIO DE FORNECEDORES A VENDER"""
        &Width     = "180"
        &Form      = "frame f-cabcab"}

    disp with frame f1.
        
    for each wmodal where wmodal.modcod <> "CHP"
                              and wmodal.modcod <> "BON",
                each tt-titulo where tt-titulo.empcod = wempre.empcod and
                                  tt-titulo.titnat   =   yes  and
                                  tt-titulo.modcod = wmodal.modcod 
                                     break by tt-titulo.titdtven
                                           by tt-titulo.modcod
                                           by tt-titulo.titnum:
                find forne where forne.forcod = tt-titulo.clifor
                                no-lock no-error.

                if avail forne 
                then vnome = forne.fornom.
                else vnome = "".
                
                find first wevent where 
                        wevent.evecod = tt-titulo.evecod no-error.
                if not avail wevent
                then next.

                find cobra of tt-titulo no-lock no-error.
                wtot = wtot + (tt-titulo.titvlcob + tt-titulo.titvljur).
                vtitvlcob = (tt-titulo.titvlcob + tt-titulo.titvljur - 
                             tt-titulo.titvldes).

                
                if first-of(tt-titulo.titdtven)
                then display tt-titulo.titdtven 
                    with frame ff2 side-label.
                
                
                display 
                        tt-titulo.clifor 
                        column-label "Forne" format "999999" 
                        vnome         column-label "Ag.Comercial"
                                      format "x(30)"
                        tt-titulo.modcod column-label "Mod"
                        tt-titulo.titnum 
                        tt-titulo.titpar format ">>>>>9"
                        cobra.cobnom  when avail cobra
                            column-label "Cobranca" format "x(08)"
                        tt-titulo.etbcod column-label "Fl." format ">99" 
                        tt-titulo.titvlcob(total by tt-titulo.titdtven) 
                                column-label "Valor!Total" 
                                        format ">>>,>>>,>>9.99"
                        tt-titulo.titvljur format ">,>>>,>>9.99" 
                                column-label "Vl.Juros"
                        tt-titulo.titvldes format ">,>>>,>>9.99" 
                                column-label "Vl.Desc"
                        (tt-titulo.titvlcob + tt-titulo.titvljur - 
                         tt-titulo.titvldes)(total by tt-titulo.titdtven) 
                         format ">>>,>>>,>>9.99"  column-label "Valor!Cobrado"
                        tt-titulo.evecod column-label "Ev." format ">9"
                        tt-titulo.titsit with frame f2 width 190 down.
                down with frame f2.
                
                /****
    for each tt-titulo no-lock break by tt-titulo.titdtven:  
        find forne where forne.forcod = tt-titulo.clifor no-lock no-error.  
        display 
           tt-titulo.clifor column-label "Forne" format ">>>>>>>>>9" 
           forne.fornom  column-label "Ag.Comercial" format "x(30)"
           tt-titulo.modcod column-label "Mod"
           tt-titulo.titnum    format "x(15)"
           tt-titulo.titdtemi
           tt-titulo.titdtven
           tt-titulo.titpar    format ">>>>>9"
           tt-titulo.etbcod column-label "Fl." format ">>9" 
           tt-titulo.titvlcob(total by tt-titulo.titdtven) 
                                column-label "Valor!Total" 
                                        format ">>>,>>>,>>9.99"
           tt-titulo.titvljur format ">,>>>,>>9.99" 
                                column-label "Vl.Juros"
           tt-titulo.titvldes format ">,>>>,>>9.99" 
                                column-label "Vl.Desc"
           (tt-titulo.titvlcob + tt-titulo.titvljur - 
                         tt-titulo.titvldes)(total by tt-titulo.titdtven) 
                         format ">>>,>>>,>>9.99"  column-label "Valor!Cobrado"
           tt-titulo.titdtpag
           tt-titulo.titvlpag format ">>>,>>>,>>9.99"
                (total by tt-titulo.titdtven) column-label "Valor!Pago"
            with frame f2 width 190 down.
        down with frame f2.
        **/
 
    end.    
    output close.
        
    run visurel.p(varquivo,"").
    
    leave.
end.
