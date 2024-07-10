{/admcom/progr/admcab.i new}
pause 0 before-hide.

def var vtoday   as date.
def var vpropath as char format "x(150)".

vtoday = date(SESSION:PARAMETER) no-error.
if vtoday = ?
then vtoday = today.

input from /admcom/linux/propath no-echo.  /* Seta Propath */
set vpropath with width 200 no-box frame ff.
input close.
propath = vpropath + ",\dlc".

message "CYBER - Integracao " today vtoday
        "INICIO:" string(time,"HH:MM:SS").

def new shared temp-table ttlote
    field rec as recid.

for each ttlote.
    delete ttlote. 
end.

message string(time,"HH:MM:SS") "Finan".
run cyber/leitura-regra.p (vtoday).

/***
message string(time,"HH:MM:SS") "Dragao".
run conecta_d.p.
run cyber/leitura-regra-dragao.p (vtoday).
disconnect d.
***/

message string(time,"HH:MM:SS") "Lotes".
run cyber/gera-lotes.p.

message "CYBER - Integracao " today 
        "FINAL :" string(time,"HH:MM:SS").

for each ttlote.
    find lotcre where recid(lotcre) = ttlote.rec no-lock.
    find lotcretp of lotcre no-lock.
    display
        lotcre.ltcrecod format ">>>>>>>>9"  label "Lote"
        lotcretp.LtCreTNom format "x(30)"
        lotcre.ltcredt
        string(lotcre.ltcrehr, "HH:MM:SS") @ lotcre.ltcrehr
        /*vtipo */
        lotcre.ltdtenvio
        lotcre.ltseqcyber column-label "Seq Cyber"
        ArqEnvio format "x(60)"
        with frame flinnn down width 350.
end.
