{admcab.i}

def var vsen-controle  as integer format ">>>9".
def var vsenha-calculada as char.

update vsen-controle label "Numero de Controle informado pela Filial"
        with frame f-fil 1 down width 80 side-label.

/*** algoritmo de senha igual ao programa senha_u.p da filial ****/

vsenha-calculada = string((day(today) + 8159) +
                        (month(today) + 71175) + (year(today) + 850) +
                        (integer(vsen-controle) * 2175)).
                        
vsenha-calculada = substring(vsenha-calculada,3,5).

message color red/with
        "   " skip
        vsenha-calculada
        view-as alert-box title "   Senha  ".
        
