{admcab.i}

def var vfil  like estab.etbcod.
def var vsenha-calculada as char.
def var vsenha-cal as char.
def var val-quem as char.
def var vi as int.

update vfil label "          Filial"
        with frame f-fil 1 down width 80 side-label.
find estab where estab.etbcod = vfil no-lock.
disp estab.etbnom no-label with frame f-fil.        

val-quem = string(int(vfil),"999").

def var valida-tempo as int.
def var valida-data as date init today.

update valida-tempo at 1 label "Validade minutos"
        with frame f-fil .
if valida-tempo = 0
then update valida-data at 1 format "99/99/9999" 
        label "   Validade data"
         with frame f-fil.
 
vsenha-calculada = val-quem +
                    string(day(today) +
                        month(today) + year(today) +
                        int(substr(string(time,"hh:mm"),1,2)) +
                int(substr(string(time,"hh:mm"),4,2))
                + int(val-quem)).

vsenha-cal = substr(vsenha-calculada,1,3).

do vi = 1 to length(vsenha-calculada):
    if vi = length(vsenha-calculada) - 2
    then leave.
    vsenha-cal = vsenha-cal +
        substr(vsenha-calculada,
            (length(vsenha-calculada) + 1) - vi,1).
end.

find first tbcntgen where
           tbcntgen.tipcon = 8 and 
           tbcntgen.etbcod = vfil and
           tbcntgen.numini = "" and
           tbcntgen.numfim = ""
           no-error.
if not avail tbcntgen
then do:
    create tbcntgen.
    assign
        tbcntgen.tipcon = 8
        tbcntgen.etbcod = vfil
        .
end.
assign
    tbcntgen.dtexp = today
    tbcntgen.quantidade = valida-tempo
    tbcntgen.validade = valida-data
    tbcntgen.valor = 0
    tbcntgen.campo1[1] = vsenha-cal
    .        
if valida-tempo > 0
then tbcntgen.valor = time + (valida-tempo * 60).

release tbcntgen.

message color red/with
        "   " skip
        vsenha-cal
        view-as alert-box title "   Senha  ".

  