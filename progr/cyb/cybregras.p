{cabec.i}
def var eCybRegras as char format "x(19)" extent 8.
def var iCybRegras as int.
def var eOpcao as char format "x(14)" extent 5.
def var iOpcao as int.
def var vr as int.
def var caux as char.
def var petbcod like estab.etbcod.

def temp-table ttparam no-undo
    field REGRA         as char format "x(20)"
    field OPCAO         as char format "x(10)"
    field PARAMETRO     as char format "x(16)"
    field PROGRAMA      as char format "x(12)".

input from /admcom/progr/cyb/parametro.ini.
repeat transaction on error undo , leave.
    create ttparam.
    import delimiter "," ttparam.
    if ttparam.regra = "" then delete ttparam.
end.    

for each ttparam.
    if ttparam.regra = "REGRA" or 
       ttparam.regra = "" or 
       ttparam.regra = ?
    then delete ttparam. 
end. 

vr = 1.
eCybRegras[1] = "Filiais".
cAux = "".
for each ttparam.
    if cAux <> ttparam.regra
    then vr = vr + 1.
    cAux = ttparam.regra.
    eCybRegras[vr] = ttparam.regra.
end.          

repeat:
    disp eCybRegras
        with frame fCybRegras
        side-labels width 81 no-labels no-box row 4.
    choose field eCybRegras
        with frame fCybRegras.
    
    iCybRegras = frame-index    .
    
    
    form
        eOpcao
            with frame fOpcao
        side-labels centered no-labels
        title eCybRegras[iCybRegras].

    eOpcao = "".
    iOpcao = 1.
    eOpcao[1] = "Consultas".
    for each ttparam where ttparam.regra = ecybRegras[iCybRegras].
        iOpcao = iOpcao + 1.
        eOpcao[iOpcao] = ttparam.opcao.
    end.
    iOpcao = 1.
    repeat:
        disp eCybRegras
            with frame fCybRegras.
        if icybregras > 1
        then do: 
            disp
                eOpcao
                    with frame fOpcao
                title eCybRegras[iCybRegras].
            choose field
                eOpcao with frame fOpcao.        
            iOpcao = frame-index.      
        end.    
        find first ttparam where ttparam.regra = ecybRegras[iCybRegras] and
                                 ttparam.opcao = eOpcao[iOpcao]
                                 no-error.
        if avail ttparam
        then run value(ttparam.programa) (ttparam.parametro).
        else do:
            petbcod = 0.
            message "Qual Filial? [zero p/ todas]" update petbcod.
            run cyb/regras_filiais.p 
                (if iCybRegras = 1 then ""
                  else ecybRegras[iCybRegras], petbcod).
            leave.      
        end.
    end.
    
end.

