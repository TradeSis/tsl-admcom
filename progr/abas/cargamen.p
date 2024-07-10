/* #1 15.07.19 - retirada menu vex , vai normal para moda */  
{cabec.i}

def var vwms         as char format "x(17)" extent 3
    initial ["MOVEIS",
             "MODA",
             /*#1 "VEXM"*/ ""].

def var iwms as int.
def var cwms    as char extent 3
    initial ["EBLJ",
             "FCGL",
             /*#1 "VEXM"*/ ""].
             
def var vope as char format "x(17)" extent 4
    init ["Emissao NFE","Consultas",""].
def var iope as int.    

repeat on error undo.
    display 
        "                   M E N U  D E  C A R R E G A M E N T O "
        with frame fpor1 centered width 81 no-box color message
        row 3 overlay.

    disp vwms with frame fpor centered no-labels row 4 
        title " DEPOSITO WMS". 
    choose field vwms with frame fpor.
    iwms = frame-index.
    
    /*
    rePEAT. 
        view frame fpor1.
        VIEW FRAME fpor.
        
        display 
            "             O P E R A C A O"
            with frame fsit1 centered width 40 col 40  no-box color message
            row 8 overlay.

        disp vope with frame fsit centered no-labels row 9 no-box. 
        choose field vope with frame fsit.
        iope = frame-index.
   
        
            hide frame fpor  no-pause.
            hide frame fpor1 no-pause.
            hide frame fsit1  no-pause.
            hide frame fsit no-pause.

        if trim(vope[iope]) = "Emissao NFE"
        then do:
            run abas/cockpitcarga.p (input cwms[iwms],
                                     input yes).
        end.    
        else
        if trim(vope[iope]) = "Consultas"
        then do:
            run abas/cockpitcarga.p (input cwms[iwms],
                                     input no).
        end.
        
    END.           
    **/ 
    
    if cwms[iwms] <> ""
    then
        run abas/cockpitcarga.p (input cwms[iwms], 
                                 input yes).
    
    
end.

