{admcab.i new}

def var vetbcod like estab.etbcod.
def var vclifor as int format ">>>>>>>>>9".
def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vdata as date format "99/99/9999".

def temp-table tt-cli
    field clicod like clien.clicod
    index i1 clicod
    .
update vclifor at 4 label "Cliente"
       with frame f1 1 down side-label width 80.
if vclifor > 0
then do:
    find clien where clien.clicod = vclifor no-lock no-error.
    if avail clien
    then disp clien.clinom no-label with frame f1.
    else do:
        message color red/with
        "Cliente não encontrato."
        view-as alert-box.
        undo.
    end.
    /*for each contrato where
             contrato.clicod = vclifor /*and
             contrato.contnum = 51371315*/ no-lock.
    */
    do:
        run grava-principal-acrescimo.p(input vclifor,input ?).
    end.
end.
else do on error undo:
    update vetbcod at 5 label "Filial" with frame f1.
    if vetbcod > 0
    then do:
        find estab where estab.etbcod = vetbcod no-lock.
        disp estab.etbnom no-label with frame f1.
        find first contrato where contrato.etbcod = vetbcod no-lock no-error.
        if avail contrato
        then vdti = contrato.dtinicial.
    end.
    update vdti at 1 label "Periodo de"
       validate(vdti <> ?,"")
       vdtf label "Ate"
                            validate(vdtf <> ?,"")
       with frame f1.
    if vdti > vdtf then undo.

    do vdata = vdti to vdtf:
    disp "Processando >>> " vdata with no-label frame ff 1 down centered row 10.
    pause 0.
        for each estab where (if vetbcod > 0
                          then estab.etbcod = vetbcod else true)
                          no-lock:
            for each contrato where contrato.etbcod = estab.etbcod and
                                contrato.dtinicial = vdata
                            no-lock.
                find first tt-cli where
                           tt-cli.clicod = contrato.clicod
                           no-error.
                if not avail tt-cli
                then do:
                    create tt-cli.
                    tt-cli.clicod = contrato.clicod.
                end.           
                else next.
            
                run grava-principal-acrescimo.p(input contrato.clicod,
                                                input ?).
            end.
        end.
    end.
end.