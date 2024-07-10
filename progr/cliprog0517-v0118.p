{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def var vtotal as dec format "->>,>>>,>>9.99".
def var vnovot as dec format "->>,>>>,>>9.99".
def var vdifer as dec format "->>,>>>,>>9.99".
def var vsinal as char format "x".
def var vindex as int.

form vdifer label "Ajustar "
    vsinal  label "Tipo +/-"
    help "Informe [+] para somar e [-] para subtrair"
    vtotal label "Total Atual"
    vnovot label "Novo  Total"
    with frame f-aj
    1 column column 40
    .


def var vtp-ajuste as char extent 5 format "x(30)".
assign
    vtp-ajuste[1] = "AJUSTE - VENDA A VISTA"
    vtp-ajuste[2] = "AJUSTE - DEVOLUCAO A VISTA"
    vtp-ajuste[3] = "AJUSTE - VENDA CARTAO"
     .

disp vtp-ajuste
     with frame f-tp 1 column no-label column 40
      .
choose field vtp-ajuste with frame f-tp.
vindex = frame-index.      

HIDE FRAME F-TP.

form vdifer label "Ajustar "
    vsinal  label "Tipo +/-"
    help "Informe [+] para somar e [-] para subtrair"
    vtotal label "Total Atual"
    vnovot label "Novo  Total"
    with frame f-aj
    1 column column 40
    title " " + vtp-ajuste[vindex] + " "
    .

if vindex = 1
then run aj-venda-a-vista.
else if vindex = 2
    then run aj-devolucao-a-vista.
else if vindex = 3
    then run aj-venda-cartao.
    
procedure aj-venda-a-vista:
    def var vtotal-venda as dec.
    for each ct-cartcl where
             ct-cartcl.etbcod <> 0 and
             ct-cartcl.datref >= vdti and
             ct-cartcl.datref <= vdtf
             no-lock:
        vtotal-venda = vtotal-venda + ct-cartcl.avista.
    end.         

    find ct-cartcl where
         ct-cartcl.etbcod = 0 and
         ct-cartcl.datref = vdtf
         no-lock no-error.
    if avail ct-cartcl
    then vdifer = ct-cartcl.avista - vtotal-venda.     
    else vdifer = 0. 

    if vdifer < 0
    then vsinal = "-".
    else vsinal = "+".
    if vdifer < 0
    then vdifer = (-1) * vdifer.

    update vdifer vsinal
    help "Informe [+] para somar e [-] para subtrair"
    with frame f-aj
    .

    if vsinal <> "-" and
       vsinal <> "+"
    then return.   

    for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0  and
                        ct-cartcl.avista > 0
                        no-lock:
        vtotal = vtotal + ct-cartcl.avista.
    end.
    
    disp vtotal with frame f-aj.    
 
    sresp = no.
    message "Atualizar?" update sresp.
    if sresp
    then 
    for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0 and
                        ct-cartcl.avista > 0
                        :
        if vsinal = "-"
        then
        ct-cartcl.avista = ct-cartcl.avista -
                        (vdifer * (ct-cartcl.avista / vtotal)).
        else if vsinal = "+"
        then do:
            if vdifer < 10
            then do:
                ct-cartcl.avista = ct-cartcl.avista + vdifer.
                vnovot = vnovot + ct-cartcl.avista.
                leave.
            end.
            else ct-cartcl.avista = ct-cartcl.avista +
                        (vdifer * (ct-cartcl.avista / vtotal)).
        end.                 
        vnovot = vnovot + ct-cartcl.avista.
    end.

    disp vnovot with frame f-aj.
 
end procedure. 

procedure aj-devolucao-a-vista:

    def var vtotal-devol as dec.
    for each ct-cartcl where
             ct-cartcl.etbcod <> 0 and
             ct-cartcl.datref >= vdti and
             ct-cartcl.datref <= vdtf
             no-lock:
        vtotal-devol = vtotal-devol + ct-cartcl.devvista.
    end.         

    find ct-cartcl where
         ct-cartcl.etbcod = 0 and
         ct-cartcl.datref = vdtf
         no-lock no-error.
    if avail ct-cartcl
    then vdifer = ct-cartcl.devvista - vtotal-devol.     
    else vdifer = 0. 

    if vdifer < 0
    then vsinal = "-".
    else vsinal = "+".

    vdifer = (-1) * vdifer.
    update vdifer vsinal
        help "Informe [+] para somar e [-] para subtrair"
        with frame f-aj
        .

    if vsinal <> "-" and
       vsinal <> "+"
    then return.
   

    for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0  and
                        ct-cartcl.devvista > 0
                        no-lock:
        vtotal = vtotal + ct-cartcl.devvista.
    end.
    
    disp vtotal with frame f-aj.    
    sresp = no.
    message "Atualizar?" update sresp.
    if sresp
    then 
    for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0 and
                        ct-cartcl.devvista > 0
                        :
        if vsinal = "+"
        then
            ct-cartcl.devvista = ct-cartcl.devvista +
                        (vdifer * (ct-cartcl.devvista / vtotal)).
        else if vsinal = "-"
        then
            ct-cartcl.devvista = ct-cartcl.devvista -
                        (vdifer * (ct-cartcl.devvista / vtotal)).
                    
                        
        vnovot = vnovot + ct-cartcl.devvista.
    
    end.

    disp vnovot with frame f-aj.
 
end procedure.

procedure aj-venda-cartao:
    def var vtotal-banri as dec.
    def var vtotal-master as dec.
    def var vtotal-visa as dec.
    def var vdifer-banri as dec format "->>>,>>>,>>9.99".
    def var vdifer-master as dec format "->>>,>>>,>>9.99".
    def var vdifer-visa as dec format "->>>,>>>,>>9.99".

    for each ct-cartcl where
             ct-cartcl.etbcod <> 0 and
             ct-cartcl.datref >= vdti and
             ct-cartcl.datref <= vdtf
             no-lock:
        vtotal-banri = vtotal-banri + ct-cartcl.banri.
        vtotal-master = vtotal-master + ct-cartcl.master.
        vtotal-visa  = vtotal-visa + ct-cartcl.visa.
    end.         

    find ct-cartcl where
         ct-cartcl.etbcod = 0 and
         ct-cartcl.datref = vdtf
         no-lock no-error.
    if avail ct-cartcl
    then assign
            vdifer-banri = ct-cartcl.banri - vtotal-banri
            vdifer-master = ct-cartcl.master - vtotal-master
            vdifer-visa = ct-cartcl.visa - vtotal-visa
            
            .     
    else assign 
            vdifer-banri = 0
            vdifer-master = 0
            vdifer-visa = 0
            . 


    disp ct-cartcl.banri format ">,>>>,>>9.99" label "Banri  "
         " - " no-label
         vtotal-banri no-label
         " = " no-label
         vdifer-banri no-label
         ct-cartcl.visa format ">,>>>,>>9.99" label "Visa   "
         " - " no-label
         vtotal-visa no-label
         " = " no-label
         vdifer-visa no-label
         ct-cartcl.master format ">,>>>,>>9.99" at 1 label "Master"
         " - " no-label
         vtotal-master no-label
         " = " no-label
         vdifer-master  no-label
         with frame fdcar side-label 
         .
         
         
    def var tot-banri as dec.
    def var tot-master as dec.
    def var tot-visa as dec.
    tot-banri = 0.
    tot-master = 0.
    tot-visa = 0.
    vtotal = 0.
    
    for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0  
                        no-lock:
            tot-banri = tot-banri + ct-cartcl.avista.
            tot-master = tot-master + ct-cartcl.avista.
            tot-visa = tot-visa + ct-cartcl.avista.
            vtotal = vtotal + ct-cartcl.banri + ct-cartcl.master
                + ct-cartcl.visa.
    end.
    find first ct-cartcl where
               ct-cartcl.etbcod = 0        and
               ct-cartcl.datref = vdtf
               no-error .

    def var venda-banri as dec.
    def var venda-master as dec.
    def var venda-visa as dec.
    venda-banri = ct-cartcl.banri.
    venda-master = ct-cartcl.master.
    venda-visa = ct-cartcl.visa.
 
    if vdifer-banri <> 0 or
       vdifer-master <> 0 or
       vdifer-visa <> 0
    then do:
        
        for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0 and
                        ct-cartcl.avista > 0
                        :
            ct-cartcl.banri =
                         (venda-banri * (ct-cartcl.avista / tot-banri)).
        end.
        for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0 and
                        ct-cartcl.avista > 0
                        :
            ct-cartcl.master =
                        (venda-master * (ct-cartcl.avista / tot-master)).
                               
        end.
        for each ct-cartcl where ct-cartcl.datref >= vdti and
                        ct-cartcl.datref <= vdtf AND
                        ct-cartcl.etbcod > 0 and
                        ct-cartcl.avista  > 0
                        :
            ct-cartcl.visa =
                        (venda-visa * (ct-cartcl.avista / tot-visa)).
                               
        end.
     end.
end procedure. 


