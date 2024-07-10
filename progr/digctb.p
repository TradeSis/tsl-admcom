{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var varquivo as char.
repeat:
    update vetbcod label "Filial" colon 15
        with frame f1 side-label width 80.
        
    update vdti label "Data Inicial" colon 15
           vdtf label "Data Final"
                with frame f1.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + "digctbx.txt".
    else varquivo = "l:~\relat~\" + "digctb.txt".
    
    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""digctb""
            &Nom-Sis   = """SISTEMA DE CONTABILIDADE"""
            &Tit-Rel   = """NOTAS DIGITADAS - PERIODO DE "" +
                            string(vdti,""99/99/9999"") + "" A "" +
                            string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}
    
    for each fiscal where fiscal.desti  = vetbcod and
                          fiscal.movtdc = 04      and
                          fiscal.plarec >= vdti   and
                          fiscal.plarec <= vdtf  no-lock by plarec:

            
        if fiscal.opfcod = 1102 or 
           fiscal.opfcod = 2102 or
           fiscal.opfcod = 2949 or 
           fiscal.opfcod = 1949
        then.
        else next.
                                
        find plani where plani.etbcod = fiscal.desti  and
                         plani.emite  = fiscal.emite  and
                         plani.movtdc = fiscal.movtdc and
                         plani.numero = fiscal.numero and
                         plani.serie  = fiscal.serie no-lock no-error.
                     
                     
        if not avail plani
        then do:
        
            find plani where plani.etbcod = 998  and
                             plani.emite  = fiscal.emite  and
                             plani.movtdc = fiscal.movtdc and
                             plani.numero = fiscal.numero and
                             plani.serie  = fiscal.serie no-lock no-error.
            if not avail plani
            then do:
            
                
                     
         
                find forne where forne.forcod = fiscal.emite 
                            no-lock no-error.
        
                pause 0.
                display fiscal.plarec
                        fiscal.emite
                        forne.fornom when avail forne format "x(30)"
                        fiscal.numero
                        fiscal.platot(total)
                        fiscal.bicms(total)
                        fiscal.icms(total) with frame f2 down width 130.
            end.
        end.
    end.                
    output close.
    if opsys = "UNIX"
    then do:
        run visurel.p(input varquivo, input "").
    end.
    else do: 
        {mrod.i} 
    end. 
end.        
