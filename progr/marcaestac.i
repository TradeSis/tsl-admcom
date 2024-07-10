def var vdes-estac as char extent 8 format "x(15)".
def var vq as int.
for each estac where estac.etccod > 0 no-lock:
    vdes-estac[estac.etccod] = string(estac.etccod,"99") + "-" +
                                    estac.etcnom.
    vq = estac.etccod.
end.

def var vmarca as char extent 10 format "x(3)" init "( )".
def var va as int.

do va = 1 to num-entries(vsel-estac,";"):
    if entry(va,vsel-estac,";") <> ""
    then vmarca[va] = "(*)".
    else vmarca[va] = "( )".
end.

/*status default "F1 = Sair".
*/
repeat on endkey undo, leave:
    disp vmarca[1] space(0) vdes-estac[1]
         skip
         vmarca[2] space(0) vdes-estac[2]
         skip   
         vmarca[3] space(0) vdes-estac[3]
         skip
         vmarca[4] space(0) vdes-estac[4]
         skip
         vmarca[5] space(0) vdes-estac[5]
         skip
         vmarca[6] space(0) vdes-estac[6]
         skip
         vmarca[7] space(0) vdes-estac[7]
         skip
         vmarca[8] space(0) vdes-estac[8]
         with frame f1  no-label title " F1 = SAIR " overlay  
         .                                    
                                    
    choose field vdes-estac GO-ON(F1 PF1) with frame f1.     
    if lastkey = keycode("F1") or
       lastkey = keycode("PF1")
    then leave.
    if vmarca[frame-index] = "( )"
    then vmarca[frame-index] = "(*)".
    else vmarca[frame-index] = "( )".
    disp vmarca[frame-index] with frame f1.
    pause 0.                               
end.
status default "".
def var vs as int.
vsel-estac = "".
do vs = 1 to vq:
    if vmarca[vs] = "(*)"
    then vsel-estac = vsel-estac + substr(vdes-estac[vs],1,2) + ";".    
    else vsel-estac = vsel-estac + ";".
end.

