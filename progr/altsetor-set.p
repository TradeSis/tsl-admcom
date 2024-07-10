def var vmodcod like fin.modal.modcod.
def var vsetcod like setaut.setcod.
def var nsetcod like setaut.setcod.
def var vdti as date.
def var vdtf as date.
form with frame f-disp.
repeat:
update vmodcod at 1 label "  Modalidade"
       vsetcod at 1  label " Do   Setor"
       nsetcod       label " Para Setor"
       vdti at 1     label " Periodo de" format "99/99/9999"
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
                                  fin.titulo.titsit   =   "PAG"
                                  :

    disp "Alterando....  " fin.titulo.titdtpag fin.titulo.titnum
    with frame f-disp 1 down centered no-label row 10 no-box
    color message.
    pause 0.
    if fin.titulo.titbanpag = vsetcod
    then fin.titulo.titbanpag = nsetcod.
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
    if banfin.titulo.titbanpag = vsetcod
    then banfin.titulo.titbanpag = nsetcod.
end.
for each titudesp where titudesp.empcod = 19 and
                        titudesp.titnat = yes  and
                        titudesp.modcod = vmodcod and
             titudesp.titdtpag >= vdti and
             titudesp.titdtpag <= vdtf and
             titudesp.titsit   =   "PAG".

    disp "Alterando....  " titudesp.titdtpag titudesp.titnum
    with frame f-disp 1 down centered no-label row 10 no-box
    color message.
    pause 0.
    if titudesp.titbanpag = vsetcod
    then titudesp.titbanpag = nsetcod.
end.


hide frame f-disp.
clear frame f-disp all.
end.
