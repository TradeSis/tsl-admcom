def var varquivo as char format "x(60)".
update varquivo label "Arquivo CSV"
    with frame f1 1 down side-label width 80.

def temp-table tt-dd
    field procod like produ.procod
    field codfis like produ.codfis format ">>>>>>>>>9"
    index i1 procod. 

def var vlinha as char.
def var sresp as log format "Sim/Nao".
input from value(varquivo).
repeat:
    import unformatted vlinha.
    if num-entries(vlinha,";") <> 2
    then do:
        message color red/with
        "Arquivo com problema de layout."
        view-as alert-box.
        return.
    end.
    create tt-dd.
    assign
        tt-dd.procod = int(entry(1,vlinha,";"))
        tt-dd.codfis = int(entry(2,vlinha,";")).

end. 
input close.

sresp = no.
message "Confirma importar o arquivo?" update sresp.

for each tt-dd.
    disp tt-dd with no-label.
    pause 0.
    find produ where produ.procod = tt-dd.procod no-error.
    if avail produ
    then do on error undo:
        produ.codfis = tt-dd.codfis.
        produ.datexp = today.
    end.
    find current produ no-lock.    
end.
