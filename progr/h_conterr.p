disable triggers for load of contrato.

def var vi as int64 format ">>>>>>>>>>>>>>>>>>>9".
def var vt as int.
def var xx as log format "Sim/Nao".
message "Confirma?" update xx.
    if not xx then leave.
    
pause 0 before-hide.
for each titulo where titnat = no and titdtpag = ? no-lock
      by titulo.titnat   desc 
      by titulo.titdtpag desc 
      by titulo.titdtven desc.
      
    vi = vi + 1.

    if vi mod 10000 = 0 then disp titulo.titdtven vi. 
    if titulo.titdtven = ? then next.
    if titulo.modcod <> "CRE" then next.
    if titulo.titsit <> "LIB" then next.
    find contrato where contrato.contnum = int(titulo.titnum)
        no-lock no-error.
    if avail contrato then next.
    vt = vt + 1.
        
    disp titulo.etbcod 
    titulo.clifor
    titulo.titnum titulo.titpar titulo.tpcontrato titulo.titdtemi titulo.etbcod
    titulo.titsit titulo.titdtven titulo.titvlcob.
    find estab where estab.etbcod = titulo.etbcod no-lock.
    disp estab.usap2k.
    disp vt.

    if not avail contrato
    then do on error undo:
        create contrato. 
        ASSIGN 
            contrato.contnum   = int(titulo.titnum) 
            contrato.clicod    = titulo.clifor 
            contrato.dtinicial = titulo.titdtemi
            contrato.etbcod    = titulo.etbcod 
            contrato.modcod    = titulo.modcod .
    end.
end.
message vt vi.

