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
    update vdifer vsinal
    help "Informe [+] para somar e [-] para subtrair"
    with frame f-aj
    .

    if vsinal <> "-" and
       vsinal <> "+"
    then return.   

    for each ctcartcl where ctcartcl.datref >= vdti and
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
        then
        ctcartcl.ecfvista = ctcartcl.ecfvista +
                        (vdifer * (ctcartcl.ecfvista / vtotal)).
                         
        vnovot = vnovot + ctcartcl.ecfvista.
    end.

    disp vnovot with frame f-aj.
 
end procedure. 

procedure aj-devolucao-a-vista:

    update vdifer vsinal
        help "Informe [+] para somar e [-] para subtrair"
        with frame f-aj
        .

    if vsinal <> "-" and
       vsinal <> "+"
    then return.
   

    for each ctcartcl where ctcartcl.datref >= vdti and
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
    update vdifer vsinal
    help "Informe [+] para somar e [-] para subtrair"
    with frame f-aj
    .

    if vsinal <> "-" and
       vsinal <> "+"
    then return.   

    def var tot-banri as dec.
    def var tot-master as dec.
    tot-banri = 0.
    tot-master = 0.
    vtotal = 0.
    for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0  
                        no-lock:
            tot-banri = tot-banri + ctcartcl.avista.
            tot-master = tot-master + ctcartcl.emissao.
            vtotal = vtotal + ctcartcl.avista + ctcartcl.emissao.
    end.

    disp vtotal with frame f-aj.

    find first ctcartcl where
               ctcartcl.etbcod = 0        and
               ctcartcl.datref = vdtf
               no-error .

    def var venda-banri as dec.
    def var venda-master as dec.
    venda-banri = vdifer * (tot-banri / ctcartcl.avista) .
    venda-master = vdifer - venda-banri.
 
    sresp = no.
    message "Confirma valor?" update sresp.
    if sresp
    then do:
    
        find first ctcartcl where
               ctcartcl.etbcod = 0        and
               ctcartcl.datref = vdtf
               no-error .
    
        if avail ctcartcl
        then do:
            if vsinal = "+"
            then assign
                     ctcartcl.avista = ctcartcl.avista + venda-banri
                     ctcartcl.emissao = ctcartcl.emissao + venda-master
                     .
            else if vsinal = "-"
            then assign
                     ctcartcl.avista = ctcartcl.avista - venda-banri
                     ctcartcl.emissao = ctcartcl.emissao - venda-master
                     .
 
        end.
        vnovot = vnovot + ctcartcl.avista + ctcartcl.emissao.
        
        /*
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0  
                        no-lock:
            tot-banri = tot-banri + ctcartcl.avista.
            tot-master = tot-master + ctcartcl.emissao.
        end.
        */
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ctcartcl.avista > 0
                        :
            if vsinal = "-"
            then ctcartcl.avista = ctcartcl.avista -
                     (venda-banri * (ctcartcl.avista / tot-banri)).
            else if vsinal = "+"
            then ctcartcl.avista = ctcartcl.avista +
                        (venda-banri * (ctcartcl.avista / tot-banri)).
                         
        end.
        for each ctcartcl where ctcartcl.datref >= vdti and
                        ctcartcl.datref <= vdtf AND
                        ETBCOD > 0 and
                        ctcartcl.emissao > 0
                        :
            if vsinal = "-"
            then ctcartcl.emissao = ctcartcl.emissao -
                     (venda-master * (ctcartcl.emissao / tot-master)).
            else if vsinal = "+"
            then ctcartcl.emissao = ctcartcl.emissao +
                        (venda-master * (ctcartcl.emissao / tot-master)).
                         
        end.
    end.
    disp vnovot with frame f-aj.
end procedure. 


