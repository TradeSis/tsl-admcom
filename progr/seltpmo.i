def var d-tipo as char extent 8 format "x(30)".
def var dd-tipo as char format "x(30)" extent 8.
def var vt as int.
vt = 1.
IF "{1}" = "DESPESA" 
THEN assign
        d-tipo[vt] = "DESPESA"
        dd-tipo[vt] = "DESPESA" 
        vt = vt + 1.
if "{2}" = "PREMIO"
THEN assign
    d-tipo[vt] = "PREMIO VENDEDOR"
    dd-tipo[vt]= "VENDEDOR"
    vt = vt + 1
    d-tipo[vt] = "PREMIO GERENTE"
    dd-tipo[vt]= "GERENTE"
    vt = vt + 1    
    d-tipo[vt] = "PREMIO PROMOTOR"
    dd-tipo[vt]= "PROMOTOR"
    vt = vt + 1
    d-tipo[vt] = "PREMIO CREDIARISTA"
    dd-tipo[vt]= "CREDIARISTA"
    vt = vt + 1
    d-tipo[vt] = "PREMIO TREINEE CREDIARIO"
    dd-tipo[vt]= "TREINEE CREDIARIO"
    vt = vt + 1
    d-tipo[vt] = "PREMIO TREINEE CONFECCAO"
    dd-tipo[vt]= "TREINEE CONFECCAO"
    vt = vt + 1
    d-tipo[vt] = "PREMIO CREDIARISTA PLANO BIS"
    dd-tipo[vt]= "CREDIARISTA PLANO BIS"
     .

def var dm-tipo as char format "x" extent 8.
def var v-tipodes as char format "x(30)".

procedure d-tipo-sel:

    def var vi as in init 0.
    def var va as int init 0.

    format skip(1)
          d-tipo[1] skip
          d-tipo[2] skip
          d-tipo[3] skip
          d-tipo[4] skip
          D-TIPO[5] SKIP
          D-TIPO[6] SKIP
          D-TIPO[7] SKIP
          D-TIPO[8]
          with frame fd-tipo
                   1 down  column 45 no-label row 8 overlay
                    width 35 title " Tipo Despesa/Premio ".

    dm-tipo = "".
    disp    dm-tipo
            d-tipo 
            with frame fd-tipo   .
    pause 0.    

    va = 1.
    choose field d-tipo with frame fd-tipo.
    dm-tipo[va] = "".
    dm-tipo[frame-index] = "*".
    va = frame-index.
    disp dm-tipo no-label with frame fd-tipo.
    pause 0.
    v-tipodes = "".
    v-tipodes = dd-tipo[va].


    hide frame fd-tipo no-pause.
    hide message no-pause.
    
end procedure.

procedure d-tipo-sel-m:

    def var vi as in init 0.
    def var va as int init 0.
    
    dm-tipo = "".
    v-tipodes = "".
    
    format skip(1)
          dm-tipo[1] format "x" d-tipo[1] skip
          dm-tipo[2] format "x" d-tipo[2] skip
          dm-tipo[3] format "x" d-tipo[3] skip
          dm-tipo[4] format "x" d-tipo[4] skip
          dm-tipo[5] format "x" D-TIPO[5] SKIP
          dm-tipo[6] format "x" D-TIPO[6] SKIP
          dm-tipo[7] format "x" D-TIPO[7] SKIP
          dm-tipo[8] format "x" D-TIPO[8]
          with frame fd-tipo1
                   1 down  column 35 no-label row 8 overlay
                    width 45 title " Tipo Despesa/Premio ".

    dm-tipo = "".
    disp    dm-tipo
            d-tipo
            with frame fd-tipo1   .
    pause 0.    

    va = 1.
    repeat with frame fd-tipo1:
        choose field d-tipo with frame fd-tipo1.
        va = frame-index.
        if dm-tipo[va] = "*"
        then dm-tipo[va] = "".
        else dm-tipo[va] = "*".
 
        disp  dm-tipo no-label with frame fd-tipo1.
        pause 0.
        /*
        v-tipodes = "".
        v-tipodes = dd-tipo[va].
        */
    end.

    hide frame fd-tipo no-pause.
    hide message no-pause.
    
end procedure.


