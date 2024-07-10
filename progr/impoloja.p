def var vetbcod like estab.etbcod.
def var vcaminho as char format "x(45)" label "Diretorio/Caminho".
def var varqsai as char.
disable triggers for load of titulo.
disable triggers for load of plani.
disable triggers for load of movim.
disable triggers for load of contrato.
form
    vcaminho
    with frame f-dados
        centered 1 down side-labels title " DADOS INICIAIS ". 

repeat :

    update 
        vcaminho 
        with frame f-dados.

    varqsai = vcaminho + "/" + "plani.d".
    
    disp " Aguarde, Gerando NOTAS FISCAIS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat :
        create plani.
        import plani.
    end.
    input close.
    
    varqsai = vcaminho + "/" + "movim.d".

    disp " Aguarde, Importando MOVIMENTOS  ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat :
        create movim.
        import movim.
    end.
    input close.

    varqsai = vcaminho + "/" + "titulo.d".

    disp " Aguarde, Importando TITULOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat:
        create titulo.
        import titulo.
    end.    
    input close.

    varqsai = vcaminho + "/" + "contrato.d". 

    disp " Aguarde, Importando CONTRATOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat :
        create contrato.
        import contrato.
    end.
    input close.
    
    varqsai = vcaminho + "/" + "estoq.d". 

    disp " Aguarde, Importando ESTOQUES ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat :
        create estoq.
        import estoq.
    end.
    input close.

    varqsai = vcaminho + "/" + "produ.d". 

    disp " Aguarde, Importando PRODUTOS ....." with frame f-mmm
        centered 1 down no-labels no-box color messages. pause 0.

    input from value(varqsai).
    repeat :
        create produ.
        import produ.
    end.
    output close.

    message "Arquivos Importados com Sucesso" . pause.

end.
