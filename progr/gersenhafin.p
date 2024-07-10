{admcab.i}

def var vtabela     as char.
def var vcha-hora   as character.
def var vcha-senha  as character.
def var vint-cont   as integer.

form
    with frame f-gera-senha centered row 11 side-label width 50
          title "Gerador de senha para lancamento de despesas".

form vcha-senha no-label
    with frame f-mostra-senha title "Senha Gerada!"
                     centered row 16.

def var vsetcod like setor.setcod.
def var vmodcod like modal.modcod.

do on error undo,retry with frame f-gera-senha:

    update vsetcod label "Setor" validate(vsetcod > 0, "").
    find first setaut where setaut.setcod = vsetcod no-lock.
    disp setaut.setnom no-label.

    update vmodcod validate(vmodcod <> "","").
    find modal where modal.modcod = vmodcod no-lock no-error.
    if not avail modal
    then do.
        message "Modalidade invalida" view-as alert-box.
        undo.
    end.
    disp modal.modnom no-label.
end.

assign vcha-hora = string(time).
assign vint-cont = length(vcha-hora).

/*****************   A senha será a concatenação ******************
******************  do setor e modalidade        ******************
******************  os últimos 3 dígitos da hora ******************/
assign vcha-senha = string(setbcod) + string(vsetcod) + vmodcod +
                    substring(vcha-hora,(vint-cont - 2),3).

do on error undo.    
    find first tabaux where tabaux.Tabela = 
                                    string(setbcod) + string(vsetcod) + vmodcod
                       exclusive-lock no-error.
    if not avail tabaux
    then do:
        create tabaux.
        assign tabaux.Tabela = string(setbcod) + string(vsetcod) + vmodcod.
    end.
    assign tabaux.Nome_Campo  = vcha-hora 
           tabaux.Valor_Campo = vcha-senha
           tabaux.datexp      = today. 
end.

display vcha-senha format "x(15)"
        with frame f-mostra-senha.
pause.        
