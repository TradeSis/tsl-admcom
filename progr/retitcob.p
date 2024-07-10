{admcab.i}
def var vdti as date.
def var vdtf as date.
def var vetbi like estab.etbcod.

update vetbi label "Filial" colon 20
                with frame f1 side-label width 80.
 
    do on error undo, retry:
          update vdti label "Periodo" colon 20
                 vdtf label "A"  with frame f1.
          if  vdti > vdtf
          then do:
                message "Data inválida".
                undo.
            end.
     end. 

def var vcob-ori like cobra.cobcod.
def var vcob-des like cobra.cobcod.
vcob-des = 2.
    vcob-ori = 0.
        update vcob-ori label "Cobranca origem" with frame fxz
        side-label row 10 centered.
        disp vcob-des label "Cobranca destino" with frame fxz.
        
        if vcob-ori > 0
        then do:
            find first cobra where cobra.cobcod = vcob-ori no-lock no-error.
            if not avail cobra then undo.
            sresp = no.
            message "Confirma retornar Contratos da cobranca" vcob-ori.
            message "Para cobranca" vcob-des " ?" update sresp.
            if sresp = no
            then undo.
            for each titulo where 
                         titulo.empcod = 19 and
                         titulo.titnat = no and
                         titulo.modcod = "CRE" and
                         titulo.etbcod = vetbi and
                         titulo.titdtemi >= vdti and
                         titulo.titdtemi <= vdtf and
                         titulo.cobcod = vcob-ori
                         :
                         
                 disp "Enviando contratos ... " 
                                titulo.titnum 
                                with frame fxa  1 down centered no-box
                                color message row 18.
                            pause 0.       
 
                    titulo.cobcod = vcob-des.
            end.
            message "CONTRATOS ENVIADOS...". 
            PAUSE.
        end.        
