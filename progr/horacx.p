{admcab.i}

def var ii as int.
def var vv as int.
def var vdtini  like plani.pladat.
def var vdtfin  like plani.pladat.
def var vhora   as int.
 
def temp-table tt-hora
    field etbcod like estab.etbcod
    field qtdpla as int extent 22 format ">>>>>9"
    field qtdtit as int extent 22.

def var varquivo as char format "x(20)".
def var vetbcod like estab.etbcod.
def var vcxacod like caixa.cxacod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.
def var vdata as date format "99/99/9999".
repeat:
 
    
    update vetbcod with frame f1 side-label width 80.
    if vetbcod = 0
    then display "Geral" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    
    update vdti label "Data Inicial" colon 16
           vdtf label "Data Final" with frame f1.
    
    for each tt-hora:
        delete tt-hora.
    end.

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each plani where plani.etbcod = estab.etbcod and
                         plani.movtdc = 05           and
                         plani.pladat >= vdti        and
                         plani.pladat <= vdtf   no-lock:

        find first tt-hora where tt-hora.etbcod = plani.etbcod 
                    no-error.
        if not avail tt-hora
        then do:
            create tt-hora.
            assign tt-hora.etbcod = plani.etbcod.
        end.
        
        vhora = int(substring(string((plani.horincl / 3600)),1,2)).
        if vhora = 0
        then next.
        if vhora <= 7
        then vhora = 8.
        if vhora > 22
        then vhora = 22. 

        tt-hora.qtdpla[vhora] = tt-hora.qtdpla[vhora] + 1.
    end.   

    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each titulo where titulo.etbcobra = estab.etbcod and 
                          titulo.titdtpag >= vdti        and  
                          titulo.titdtpag <= vdtf   no-lock:
                    
        if titulo.titnat = no
        then.
        else next.
        
        find first tt-hora where tt-hora.etbcod = titulo.etbcobra 
                    no-error.
        if not avail tt-hora
        then do:
            create tt-hora.
            assign tt-hora.etbcod = titulo.etbcobra.
        end.
        
        vhora = int(substring(string((int(titulo.cxmhora) / 3600)),1,2)).
        if vhora = 0
        then next.
        if vhora <= 7
        then vhora = 8.
        if vhora > 22
        then vhora = 22. 

        tt-hora.qtdpla[vhora] = tt-hora.qtdpla[vhora] + 1.
    end.                                                           
     

    for each tt-hora:
        vv = 0.
        do ii = 1 to 22:
        
            vv = vv + tt-hora.qtdpla[ii].
            
        end.
        if vv = 0
        then delete tt-hora.
    end.    
    
    if opsys = "unix"   
    then varquivo = "/admcom/relat/horacx" + string(time). 
    else varquivo = "l:\relat\horacx" + string(time).

    {mdad.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "130" 
        &Page-Line = "0" 
        &Nom-Rel   = ""horacx"" 
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO""" 
        &Tit-Rel   = """MOVIMENTO POR HORA NAS FILIAIS - "" +
                      ""PERIODO: "" + 
                      string(vdti,""99/99/9999"") + "" A "" + 
                      string(vdtf,""99/99/9999"")" 
        &Width     = "140" 
        &Form      = "frame f-cabcab"}
        
    put "Fil  08:00  09:00  10:00  11:00  12:00  13:00  14:00  15:00  16:00" 
        "  17:00  18:00  19:00  20:00  21:00  22:00" skip.          

    put fill("-",130) format "x(130)".

    for each tt-hora:

        display tt-hora.etbcod no-label format ">>9"
                tt-hora.qtdpla[08] no-label (total)
                tt-hora.qtdpla[09] no-label (total)
                tt-hora.qtdpla[10] no-label (total)
                tt-hora.qtdpla[11] no-label (total)
                tt-hora.qtdpla[12] no-label (total)
                tt-hora.qtdpla[13] no-label (total) 
                tt-hora.qtdpla[14] no-label (total)
                tt-hora.qtdpla[15] no-label (total)
                tt-hora.qtdpla[16] no-label (total)
                tt-hora.qtdpla[17] no-label (total)
                tt-hora.qtdpla[18] no-label (total)
                tt-hora.qtdpla[19] no-label (total)
                tt-hora.qtdpla[20] no-label (total)
                tt-hora.qtdpla[21] no-label (total)
                tt-hora.qtdpla[22] no-label (total) 
                with frame f-pla width 130 no-box.
                
    end.

    output close. 
    
    if opsys = "UNIX"  
    then do:  
        run visurel.p (input varquivo, input ""). 
    end.     
    else do:  
        {mrod.i}  
    end.    

end.
