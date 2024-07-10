{admcab.i}

def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vdata as date format "99/99/9999".
def var vcxacod like plani.cxacod.

repeat:
    assign vetbcod = 0 vcxacod = 0 vdata = ?.
    
    update vetbcod label "Filial"
           vcxacod label "Caixa"
           vdata   label "Dia"
           with frame f-dados width 80 side-labels.

    if opsys = "UNIX"
    then varquivo = "../relat/rdinmao." + string(time).
    else varquivo = "..\relat\rdinmao." + string(time).
 
    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "63"
        &Cond-Var  = "130"
        &Page-Line = "66"
        &Nom-Rel   = ""rdinmao""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM - PROMOCAO DINHEIRO NA MAO - ""
                   + string(vdata,""99/99/9999"") + "" CAIXA: "" 
                   + string(vcxacod,""99"")"
        &Width     = "130"
        &Form      = "frame f-cabcab"}


    for each plani use-index pladat 
                   where plani.movtdc = 5 
                     and plani.etbcod = vetbcod
                     and plani.pladat = vdata no-lock. 
        if vcxacod <> 0
        then if plani.cxacod <> vcxacod then next.
        if (plani.pedcod = 15 or 
            plani.pedcod = 17 or 
            plani.pedcod = 19 or  
            plani.pedcod = 89) 
        then do: 
            find first contnf where contnf.etbcod = plani.etbcod 
                                and contnf.placod = plani.placod 
                                no-lock no-error. 
            if avail contnf 
            then do:  
                find first titulo where titulo.empcod = 19
                                    and titulo.titnat = no 
                                    and titulo.modcod = "CRE" 
                                    and titulo.etbcod = plani.etbcod
                                    and titulo.clifor = plani.desti 
                                    and titulo.titnum = string(contnf.contnum)
                                    no-lock no-error. 
                if avail titulo 
                then do:  
               
                   disp titulo.titnum titulo.titdtven
                    titulo.titvlcob (total)
                    titulo.titvlpag (total)
                    titulo.titpar plani.pedcod
                    column-label "Plano".
               
                end.
            end.
        end.
    end.

    output close. 

    if opsys = "UNIX" 
    then do:  
        run visurel.p (input varquivo,
                           input "").
    end.                       
    else do:
        {mrod.i}.
    end.
end.
