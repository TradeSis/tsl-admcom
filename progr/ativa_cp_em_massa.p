/* BY LEOTE */

{admcab.i}

def var i as dec format ">>>>>>>9".
def var cpini as dec format ">>>>>>>9".
def var cpfim as dec format ">>>>>>>9".
def var valorcp like titulo.titvlcob.
def var dtini like titulo.titdtdes format "99/99/9999".
def var dtfim like titulo.titdtven format "99/99/9999".
def var total as int init 0.

update cpini label "CP inicial"
       cpfim label "CP final"
       valorcp label "Valor CP"
       dtini label "Validade inicial"
       dtfim label "Validade final"
with frame f01 title "Informe os dados abaixo:" with 1 col width 80.

do i = cpini to cpfim:
        for each titulo where empcod = 19
                             and titnat = yes
                             and modcod = "CHP"
                             and etbcod = 999
                             and clifor = 110165
                             and titnum = string(i).
        /*disp titnum titvlcob titdtdes titdtven titsit skip.*/
        
        titvlcob = valorcp.
        titdtdes = dtini.
        titdtven = dtfim.
        titsit = "LIB".
        
        /*pause.*/
        total = total + 1.
        end.
end.

message "FIM! Total de cartoes" total.

pause.