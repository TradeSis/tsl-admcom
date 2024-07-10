{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".
vdti = 12/01/2009.
def var varquivo as char format "x(60)".

def stream stela.

update vdti label "Periodo de"
       vdtf label "Ate"
       with frame f1.
varquivo = "/admcom/financeira/contratos-"
            + string(vdti,"99999999") + "-" 
            + string(vdtf,"99999999") + ".csv".
update varquivo at 1 label "Arquivo"
       with frame f1 side-label width 80.

output stream stela to terminal.    
output to value(varquivo).
do vdata = vdti to vdtf:
    disp stream stela vdata label "Data" with side-label.
    pause 0.
    for each contrato where contrato.dtinicial = vdata
         no-lock:
        find first envfinan where
               envfinan.empcod = 19 and
               envfinan.titnat = no and
               envfinan.modcod = contrato.modcod and
               envfinan.etbcod = contrato.etbcod and
               envfinan.clifor = contrato.clicod and
               envfinan.titnum = string(contrato.contnum) and
               (envfinan.envsit = "ENV" or
               envfinan.envsit = "PAG")
               no-lock no-error.
        if avail envfinan
        then do:
            put contrato.contnum format ">>>>>>>>>9"
            skip.               
        end.
    end.
end.
output close.
output stream stela close.

message color red/with
    "Arquivo gerado" skip
    varquivo
    view-as alert-box.
