  
{cabec.i}
def var vtipo         as char format "x(10)" extent 7
    initial [ /*"Todos",*/
                 ""].
                 
                 
                 
def var itipo as int init 0 /*1*/ .
for each abastipo where abastipo.tiposugcompra = yes no-lock.
    if abastipo.abatipo = "ESP"
    then next.
    itipo = itipo + 1.
    vtipo[itipo] = abastipo.abatnom. 
end.
itipo = 1.

repeat on error undo.
    display 
        "                   S O L I C I T A C O E S   D E   C O M P R A"
        with frame fpor1 centered width 81 no-box color message
        row 3 overlay.

            display 
                "             O R I G E M    "
              with frame ftipo1 centered width 40 col 40  no-box color message
              row 13 overlay.

            disp vtipo with frame ftipo centered no-labels row 14. 
            choose field vtipo with frame ftipo.
            itipo = frame-index.
             
   
            hide frame fpor  no-pause.
            hide frame fsit1  no-pause.
            hide frame fsit no-pause.
            hide frame ftipo1 no-pause.
            hide frame ftipo no-pause.

            message        
            "FILTRO-> "
                " Tipo de Origem:" 
                  trim(vtipo[itipo]).

            
            if substr(trim(vtipo[itipo]),1,3) = "ESP"
            then do:
                run abas/compraven.p
                    ( input "ESP,AB").
            end.
            else do:
                run abas/compraman.p
                    ( input  (if substr(trim(vtipo[itipo]),1,3) = "TOD"
                              then ""
                              else substr(trim(vtipo[itipo]),1,3)
                              + ",AB")).
            end.
        END.

