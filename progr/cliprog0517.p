{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def var vtotal as dec format ">>,>>>,>>9.99".
def var vnovot as dec format ">>,>>>,>>9.99".
def var vdifer as dec format ">>,>>>,>>9.99".
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
    for each ninja.ctcartcl where
             ninja.ctcartcl.etbcod <> 0 and
             ninja.ctcartcl.datref >= vdti and
             ninja.ctcartcl.datref <= vdtf
             no-lock:
        vtotal-venda = vtotal-venda + ninja.ctcartcl.ecfvista.
    end.         

    find ninja.ctcartcl where
         ninja.ctcartcl.etbcod = 0 and
         ninja.ctcartcl.datref = vdtf
         no-lock no-error.
    if avail ninja.ctcartcl
    then vdifer = ninja.ctcartcl.ecfvista - vtotal-venda.     
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

    for each ninja.ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0  and
                        ecfvista > 0
                        no-lock:
        vtotal = vtotal + ecfvista.
    end.
    
    disp vtotal with frame f-aj.    
 
    sresp = no.
    message "Atualizar?" update sresp.
    if sresp
    then 
    for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ecfvista > 0
                        :
        if vsinal = "-"
        then
        ctcartcl.ecfvista = ctcartcl.ecfvista -
                        (vdifer * (ctcartcl.ecfvista / vtotal)).
        else if vsinal = "+"
        then do:
            if vdifer < 10
            then do:
                ctcartcl.ecfvista = ctcartcl.ecfvista + vdifer.
                vnovot = vnovot + ctcartcl.ecfvista.
                leave.
            end.
            else ctcartcl.ecfvista = ctcartcl.ecfvista +
                        (vdifer * (ctcartcl.ecfvista / vtotal)).
        end.                 
        vnovot = vnovot + ctcartcl.ecfvista.
    end.

    disp vnovot with frame f-aj.
 
end procedure. 

procedure aj-devolucao-a-vista:

    def var vtotal-devol as dec.
    for each ninja.ctcartcl where
             ninja.ctcartcl.etbcod <> 0 and
             ninja.ctcartcl.datref >= vdti and
             ninja.ctcartcl.datref <= vdtf
             no-lock:
        vtotal-devol = vtotal-devol + ninja.ctcartcl.devolucao.
    end.         

    find ninja.ctcartcl where
         ninja.ctcartcl.etbcod = 0 and
         ninja.ctcartcl.datref = vdtf
         no-lock no-error.
    if avail ninja.ctcartcl
    then vdifer = ninja.ctcartcl.devolucao - vtotal-devol.     
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
   

    for each ninja.ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0  and
                        devolucao > 0
                        no-lock:
        vtotal = vtotal + devolucao.
    end.
    
    disp vtotal with frame f-aj.    
    sresp = no.
    message "Atualizar?" update sresp.
    if sresp
    then 
    for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        devolucao > 0
                        :
        if vsinal = "+"
        then
            ctcartcl.devolucao = ctcartcl.devolucao +
                        (vdifer * (ctcartcl.devolucao / vtotal)).
        else if vsinal = "-"
        then
            ctcartcl.devolucao = ctcartcl.devolucao -
                        (vdifer * (ctcartcl.devolucao / vtotal)).
                    
                        
        vnovot = vnovot + ctcartcl.devolucao.
    
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

    for each ninja.ctcartcl where
             ninja.ctcartcl.etbcod <> 0 and
             ninja.ctcartcl.datref >= vdti and
             ninja.ctcartcl.datref <= vdtf
             no-lock:
        vtotal-banri = vtotal-banri + ninja.ctcartcl.avista.
        vtotal-master = vtotal-master + ninja.ctcartcl.emissao.
        vtotal-visa  = vtotal-visa + ninja.ctcartcl.aprazo.
    end.         

    find ninja.ctcartcl where
         ninja.ctcartcl.etbcod = 0 and
         ninja.ctcartcl.datref = vdtf
         no-lock no-error.
    if avail ninja.ctcartcl
    then assign
            vdifer-banri = ninja.ctcartcl.avista - vtotal-banri
            vdifer-master = ninja.ctcartcl.emissao - vtotal-master
            vdifer-visa = ninja.ctcartcl.aprazo - vtotal-visa
            
            .     
    else assign 
            vdifer-banri = 0
            vdifer-master = 0
            vdifer-visa = 0
            . 


    disp ninja.ctcartcl.avista label "Banri  "
         " - " no-label
         vtotal-banri no-label
         " = " no-label
         vdifer-banri no-label
         ninja.ctcartcl.aprazo label "Visa   "
         " - " no-label
         vtotal-visa no-label
         " = " no-label
         vdifer-visa no-label
         ninja.ctcartcl.emissao at 1 label "Master"
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
    
    for each ninja.ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0  
                        no-lock:
            tot-banri = tot-banri + ctcartcl.ecfvista.
            tot-master = tot-master + ctcartcl.ecfvista.
            tot-visa = tot-visa + ctcartcl.ecfvista.
            vtotal = vtotal + ctcartcl.avista + ctcartcl.emissao
                + ctcartcl.aprazo.
    end.
    find first ctcartcl where
               ctcartcl.etbcod = 0        and
               ctcartcl.datref = vdtf
               no-error .

    def var venda-banri as dec.
    def var venda-master as dec.
    def var venda-visa as dec.
    venda-banri = ctcartcl.avista.
    venda-master = ctcartcl.emissao.
    venda-visa = ctcartcl.aprazo.
 
    if vdifer-banri <> 0 or
       vdifer-master <> 0 or
       vdifer-visa <> 0
    then do:
        /******
        if vdifer < 0
        then vsinal = "-".
        else vsinal = "+".
        update vdifer vsinal
        help "Informe [+] para somar e [-] para subtrair"
        with frame f-aj title " Cartao Banri "
        .

        if vsinal <> "-" and
           vsinal <> "+"
        then.
        else do:   

        disp vtotal with frame f-aj.

        sresp = no.
        message "Confirma valor?" update sresp.
        if sresp
        then do:
    
        vnovot = vnovot + ctcartcl.avista + ctcartcl.emissao.
        ****/
        
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ctcartcl.ecfvista > 0
                        :
            /*
            if vsinal = "-"
            then ctcartcl.avista = ctcartcl.avista -
                     (venda-banri * (ctcartcl.avista / tot-banri)).
            else if vsinal = "+"
            then ctcartcl.avista = ctcartcl.avista +
                        (venda-banri * (ctcartcl.avista / tot-banri)).
            */
            ctcartcl.avista =
                         (venda-banri * (ctcartcl.ecfvista / tot-banri)).
        end.
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ctcartcl.ecfvista /*emissao*/ > 0
                        :
            /*
            if vsinal = "-"
            then ctcartcl.emissao = ctcartcl.emissao -
                     (venda-master * (ctcartcl.emissao / tot-master)).
            else if vsinal = "+"
            then ctcartcl.emissao = ctcartcl.emissao +
                        (venda-master * (ctcartcl.emissao / tot-master)).
            */
            ctcartcl.emissao =
                        (venda-master * (ctcartcl.ecfvista / tot-master)).
                               
        end.
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ctcartcl.ecfvista /*emissao*/ > 0
                        :
            ctcartcl.aprazo =
                        (venda-visa * (ctcartcl.ecfvista / tot-visa)).
                               
        end.
     end.
end procedure. 


