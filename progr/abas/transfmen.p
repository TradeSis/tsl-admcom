/* #1 15.07.19 - retirada menu vex , vai normal para moda */  

{cabec.i}
def input parameter par-acao    as char.

def var vwms         as char format "x(17)" extent 4
    initial ["MOVEIS",
             "MODA",   
             /*#1 "VEX"*/ "",
             "ESPECIAL"].
def var iwms as int.
def var cwms    as char extent 4
    initial ["ALCIS_MOVEIS",
             "ALCIS_MODA",
             /*#1 "ALCIS_VEX"*/ "",
             "ALCIS_ESP"].
             
def var vope as char format "x(17)" extent 4
    init ["Corte","Consultas","Relatorios",""].
def var iope as int.    

def var vrel as char format "x(17)" extent 3
    init ["Performance do CD","Pedidos em Aberto",""].
def var irel as int.    


if par-acao = "CONS"
then vope[1] = "Manutencao".

repeat on error undo.

    if par-acao = "CONS"
    then do:
        display 
            "           C O N S U L T A S   E    M A N U T E N C O E S "
            with frame fporx1 centered width 81 no-box color message
            row 3 overlay.
    end.
    else do:
        display 
            "                   M E N U  D E  D I S T R I B U I C A O "
            with frame fpor1 centered width 81 no-box color message
            row 3 overlay.

    end.
    disp vwms with frame fpor centered no-labels row 4 
        title " DEPOSITO WMS". 
    choose field vwms with frame fpor.
    iwms = frame-index.
    if vwms[iwms] = ""
    then undo.

    rePEAT.
        if par-acao = "CONS"
         then view frame fporx1.
         else view frame fpor1.
         
        VIEW FRAME fpor.
        
        display 
            "             O P E R A C A O"
            with frame fsit1 centered width 40 col 40  no-box color message
            row 8 overlay.

        disp vope with frame fsit centered no-labels row 9 no-box. 
        choose field vope with frame fsit.
        iope = frame-index.
   
        if trim(vope[iope]) <> "Relatorios"
        then do:
            hide frame fpor  no-pause.
            hide frame fpor1 no-pause.
            hide frame fsit1  no-pause.
            hide frame fsit no-pause.
        end.
        if trim(vope[iope]) = "Corte"
        then do:
            run abas/transfman.p (cwms[iwms] + ",AC,CORTE").
        end.    
        else
        if trim(vope[iope]) = "Manutencao"
        then do:
            run abas/transfman.p (cwms[iwms] + ",AC,CONS").
        end.    
        else
        if trim(vope[iope]) = "Consultas"
        then do:
            run abas/cortesmen.p (cwms[iwms]).
        end.
        else
        if trim(vope[iope]) = "Relatorios"
        then do:

            disp vrel with frame frel centered no-labels row 12 
                title " R E L A T O R I O S ".
                
            choose field vrel with frame frel.
            irel = frame-index.

            hide frame fpor  no-pause.
            hide frame fpor1 no-pause.
            hide frame fsit1  no-pause.
            hide frame fsit no-pause.
            hide frame frel no-pause.
            if irel = 1
            then do:
                run abas/rper1.p (cwms[iwms]).
            end.
            if irel = 2
            then do:
                run abas/rabe1.p (cwms[iwms]).
            end.    
        end.
        
    END.           
    
    
end.

