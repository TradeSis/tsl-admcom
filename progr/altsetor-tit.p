def var vmodcod like fin.modal.modcod.
def var vsetcod like setaut.setcod.
def var vdti as date.
def var vdtf as date.
form with frame f-disp.
repeat:
update vmodcod at 1 label "Modalidade"
       vsetcod at 1  label "     Setor"
       vdti at 1     label "Periodo de" format "99/99/9999"
       vdtf label "ate" format "99/99/9999"
       with frame f-modset
       1 down width 80 side-label.

find fin.modal where fin.modal.modcod = vmodcod no-lock.
find setaut where setaut.setcod = vsetcod no-lock.
if vdti = ? or vdtf = ? or vdti > vdtf
then undo.
for each fin.titulo where fin.titulo.empcod = 19 and
                                      fin.titulo.titnat = yes  and
                               fin.titulo.modcod = vmodcod and
             fin.titulo.titdtpag >= vdti and
             fin.titulo.titdtpag <= vdtf and
                                  fin.titulo.titsit   =   "PAG".

    disp "Alterando....  " fin.titulo.titdtpag fin.titulo.titnum
    with frame f-disp 1 down centered no-label row 10 no-box
    color message.
    pause 0.
    if fin.titulo.titbanpag <> vsetcod
    then do:
        fin.titulo.titbanpag = vsetcod.
    end.
    for each titudesp where titudesp.empcod = titulo.empcod and
                            titudesp.titnat = titulo.titnat and
                            titudesp.modcod = titulo.modcod and
                            titudesp.clifor = titulo.clifor and
                            titudesp.titnum = titulo.titnum and
                            titudesp.titpar = titulo.titpar
                            :
            titudesp.titbanpag = vsetcod.
            titudesp.modcod = fin.titulo.modcod.
    end.
end.

for each banfin.titulo where banfin.titulo.empcod = 19 and
                                      banfin.titulo.titnat = yes  and
                               banfin.titulo.modcod = vmodcod and
             banfin.titulo.titdtpag >= vdti and
             banfin.titulo.titdtpag <= vdtf and
                                  banfin.titulo.titsit   =   "PAG".

    disp "Alterando....  " banfin.titulo.titdtpag banfin.titulo.titnum
    with frame f-disp 1 down centered no-label row 10 no-box
    color message.
    pause 0.
    if banfin.titulo.titbanpag <> vsetcod
    then do:
        banfin.titulo.titbanpag = vsetcod.
    end.
    for each titudesp where titudesp.empcod = banfin.titulo.empcod and
                            titudesp.titnat = banfin.titulo.titnat and
                            titudesp.modcod = banfin.titulo.modcod and
                            titudesp.clifor = banfin.titulo.clifor and
                            titudesp.titnum = banfin.titulo.titnum and
                            titudesp.titpar = banfin.titulo.titpar
                            :
            titudesp.titbanpag = vsetcod.
            titudesp.modcod = banfin.titulo.modcod.
    end.
end.
end.


