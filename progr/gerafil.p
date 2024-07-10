def var vetbcod like estab.etbcod.
def var vcaminho as char format "x(45)" label "Diretorio/Caminho".
def var varqsai as char.

form
    vetbcod 
    vcaminho
    with frame f-dados
        centered 1 down side-labels title " DADOS INICIAIS ". 

repeat :

    update 
        vetbcod 
        vcaminho 
        with frame f-dados.

    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab
    then do :
        bell. bell. bell. bell.
        message  "Codigo da Filial invalido".
        pause. clear frame f-dados all.
        next.
    end.

    varqsai = vcaminho + "/" + "plani.d".
    
    disp " Aguarde, Gerando NOTAS FISCAIS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each plani where plani.etbcod = vetbcod and
                         plani.datexp >= 03/10/2002 and
                         plani.datexp <= today no-lock :
        export plani.
    end.
    for each plani where plani.movtdc = 6 
                     and plani.desti = vetbcod and
                     plani.datexp >= 03/10/2002 and
                     plani.datexp <= today no-lock :
        export plani.
    end.
    output close.
    
    varqsai = vcaminho + "/" + "movim.d".

    disp " Aguarde, Gerando MOVIMENTOS  ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.
                                       
    output to value(varqsai).
    for each plani where plani.etbcod = vetbcod no-lock ,
        each movim where movim.etbcod = plani.etbcod
                     and movim.placod = plani.placod 
                     and movim.datexp >= 03/10/2002 and
                     movim.datexp <= today no-lock :
        export movim.
    end.
    output close.

    varqsai = vcaminho + "/" + "titulo.d".

    disp " Aguarde, Gerando TITULOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each titulo where titulo.etbcod = vetbcod
                      and titulo.titnat = no and
                      titulo.datexp >= 03/10/2002 and
                      titulo.datexp <= today no-lock :
        export titulo.
    end.
    output close.


    varqsai = vcaminho + "/" + "contrato.d". 

    disp " Aguarde, Gerando CONTRATOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    output to value(varqsai).
    for each contrato where contrato.etbcod = vetbcod 
                      and contrato.datexp >= 03/10/2002 and
                      contrato.datexp <= today no-lock :
        export contrato.
    end.
    output close.
    
    message "Arquivos Gerados com Sucesso" . pause.

end.
