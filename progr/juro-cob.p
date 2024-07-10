{admcab.i}
def var vv as int.
def var ljuros as l. 
def var varquivo as char.
def temp-table tt-tit
    field vini as int
    field vfin as int
    field qtdpar as int
    field valpar like titulo.titvlcob
    field jurcal like titulo.titvlcob
    field jurcob like titulo.titvlcob format "->>>,>>9.99".

def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat initial today.
def var vdtf    like plani.pladat initial today.
def var vdias   as int.

repeat:

    for each tt-tit:
        delete tt-tit.
    end.
    vetbcod = 0.
    update vetbcod label "Filial" with frame f1 side-label width 80.
    if vetbcod = 0
    then disp "GERAL" @ estab.etbnom with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    update vdti label "Periodo"
           vdtf no-label with frame f1.
           
    create tt-tit.
    assign tt-tit.vini = -30
           tt-tit.vfin = 0.
           
    do vv = 1 to 30:
        create tt-tit.
        assign tt-tit.vini = vv
               tt-tit.vfin = vv.
    end.           
               
    create tt-tit.
    assign tt-tit.vini = 31
           tt-tit.vfin = 40.
           
            
    create tt-tit.
    assign tt-tit.vini = 41
           tt-tit.vfin = 50.
           
            
    create tt-tit.
    assign tt-tit.vini = 51
           tt-tit.vfin = 60.
           
            
    create tt-tit.
    assign tt-tit.vini = 61
           tt-tit.vfin = 90.
           
            
    create tt-tit.
    assign tt-tit.vini = 91
           tt-tit.vfin = 120.
           
            
    create tt-tit.
    assign tt-tit.vini = 121
           tt-tit.vfin = 150.
           
            
    create tt-tit.
    assign tt-tit.vini = 151
           tt-tit.vfin = 1000.
           
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each titulo use-index titdtpag where
             titulo.empcod    =  wempre.empcod       and
             titulo.titnat    =  no                  and
             titulo.modcod    =  "CRE"               and
             titulo.etbcobra  = estab.etbcod         and
             titulo.titdtpag >=  vdti                and
             titulo.titdtpag <=  vdtf no-lock:
        
        if titulo.titpar = 0
        then next.
        if titulo.clifor = 1
        then next.
        
        vdias = titulo.titdtpag - titulo.titdtven.

        if titulo.titdtpag > titulo.titdtven
        then do:
            ljuros = yes.
            if titulo.titdtpag - titulo.titdtven = 2
            then do:
                find dtextra where exdata = titulo.titdtpag - 2 no-error.
                if weekday(titulo.titdtpag - 2) = 1 or avail dtextra
                then do:
                    find dtextra where exdata = titulo.titdtpag - 1 no-error.
                    if weekday(titulo.titdtpag - 1) = 1 or avail dtextra
                    then ljuros = no.
                end.
            end.
            else do:
                if titulo.titdtpag - titulo.titdtven = 1
                then do:
                    find dtextra where exdata = titulo.titdtpag - 1 no-error.
                    if weekday(titulo.titdtpag - 1) = 1 or avail dtextra
                    then ljuros = no.
                end.
            end.
            vdias = if not ljuros
                    then 0
                    else titulo.titdtpag - titulo.titdtven.
        end.
        else vdias = 0.

        
        
        find first tt-tit where tt-tit.vini <= vdias and
                                tt-tit.vfin >= vdias no-error.
        if not avail tt-tit
        then next.
                                
        assign tt-tit.qtdpar = tt-tit.qtdpar + 1
               tt-tit.valpar = tt-tit.valpar + titulo.titvlcob
               tt-tit.jurcob = tt-tit.jurcob + (titulo.titvlpag - 
                                                titulo.titvlcob).
        if vdias > 0 
        then do:
             find tabjur where tabjur.nrdias = vdias no-lock no-error.
             if avail tabjur 
             then assign tt-tit.jurcal = tt-tit.jurcal +  
                     ((titulo.titvlcob * tabjur.fator) - titulo.titvlcob).
        end.
                                         
        
        display vdias titulo.titdtpag with frame f2 side-label centered.
        pause 0.
    
    end.

    varquivo = "l:\relat\juro" + string(vetbcod).
  
    {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "160"
            &Page-Line = "66"
            &Nom-Rel   = ""juro-cob""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """ESTATISTICA DO RECEBIMENTO "" + 
                           ""  FILIAL: "" + string(vetbcod) + "" PERIODO "" + 
                           string(vdti,""99/99/9999"") + "" ATE "" + 
                           string(vdtf,""99/99/9999"")"
            &Width     = "160"
            &Form      = "frame f-cabcab"}

 
    for each tt-tit:
        display trim(string(tt-tit.vini,"->99") + " A " + 
                     string(tt-tit.vfin,">>>9")  +  " Dias") format "x(15)" 
                      column-label "Faixa de Atraso"
                tt-tit.qtdpar(total) column-label "Quant.!Parcelas"
                tt-tit.valpar(total) column-label "Valor!Prest."
                tt-tit.jurcal(total) column-label "Juro!Calc."
                ((tt-tit.jurcal / tt-tit.valpar) * 100) when tt-tit.valpar > 0
                            format "->>9.99%" column-label " % "
                tt-tit.jurcob(total) column-label "Juro!Cobrado"             
                ((tt-tit.jurcob / tt-tit.valpar) * 100) when tt-tit.valpar > 0
                            format "->>9.99%" column-label " % "
                                with frame f3 width 200 down.
    end.

    output close.     
    dos silent value("type " + varquivo + " > prn"). 
    
           
end.
