{admcab.i}
def var vetbcod like estab.etbcod.
def var vdti    like plani.pladat.
def var vdtf    like plani.pladat.
def temp-table tt-mes
    field clicod like clien.clicod
    field mes as int.

def var varquivo as char format "x(20)".
def var vqtd as int.

    
repeat:

    update vetbcod label "Filial" with frame f1.
    if vetbcod = 0
    then display "GERAL" @ estab.etbnom no-label with frame f1.
    else do:
        find estab where estab.etbcod = vetbcod no-lock.
        display estab.etbnom no-label with frame f1.
    end.
    
    
    update vdti label "Periodo"
           vdtf no-label with frame f1 side-label width 80.
    
    
    
    for each estab where if vetbcod = 0
                         then true
                         else estab.etbcod = vetbcod no-lock,
        each titulo where titulo.empcod = 19 and
                          titulo.titnat = no and
                          titulo.modcod = "CRE" and
                          titulo.etbcod = estab.etbcod and
                          titulo.titdtven >= vdti and
                          titulo.titdtven <= vdtf and
                          titulo.titsit = "LIB" no-lock:
                           
            find first tt-mes where 
                       tt-mes.clicod = titulo.clifor no-error. 
            if not avail tt-mes
            then do:
                create tt-mes.
                assign tt-mes.clicod = titulo.clifor.
            end.
            assign tt-mes.mes = month(titulo.titdtven).
                       
            disp titulo.clifor                    
                 titulo.titdtven with frame f2 1 down. pause 0.
                    
                    
    end.
 
    varquivo = "..\relat\clien" + STRING(day(today)).

    {mdad.i
            &Saida     = "value(varquivo)" 
            &Page-Size = "64"
            &Cond-Var  = "130"
            &Page-Line = "66"
            &Nom-Rel   = ""cli_abe.p""
            &Nom-Sis   = """SISTEMA DE CREDIARIO"""
            &Tit-Rel   = """FILIAL "" + string(vetbcod,"">>9"") +
                          "" DE "" + 
                             string(vdti,""99/99/9999"") + "" A "" +
                             string(vdtf,""99/99/9999"") "
            &Width     = "130"
            &Form      = "frame f-cabcab"}


    for each tt-mes no-lock break by tt-mes.mes:
    
        vqtd = vqtd + 1.
        
        if last-of(tt-mes.mes)
        then do:
            display tt-mes.mes column-label "Mes"
                    vqtd       column-label "Quantidade"
                        with frame f3 down width 120.
            vqtd = 0.            
                        
        end.
    end.
    
    {mrod.i}
    
 



end.
                                            



