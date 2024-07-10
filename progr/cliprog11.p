{admcab.i}
    
def shared var vdti as date.
def shared var vdtf as date.

def temp-table tt-financeira
    field etbcod like estab.etbcod
    field data as date
    field valor as dec
    index i1 etbcod data.
 
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


def var vtp-ajuste as char extent 5 format "x(35)".
assign
    vtp-ajuste[1] = "FINANCEIRA - VENDA"
    vtp-ajuste[2] = "FINANCEIRA - IMPORTA CANCELAMENTOS"
    vtp-ajuste[3] = "FINANCEIRA - IMPORTA ESTORNOS"
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
then run venda-financeira.
else if vindex = 2
    then run /admcom/work/imp-val-finan-cancela.bca.
else if vindex = 3
    then run /admcom/work/imp-val-finan-estorno.bca.
    
procedure venda-financeira:
    def var vetbcod like estab.etbcod.
    def var val-financeira as dec.
    def var vdata as date.
    def var vtotal as dec.
    def var t-financeira as dec init 0.
    def var vdtifin as date format "99/99/9999".
    def var vdtffin as date format "99/99/9999".
    def var rec-financeira as dec.
    rec-financeira = 0.
    
    val-financeira = 0.
    vtotal = 0.
    /*
    update vdtifin label "Periodo de"
           vdtffin label "Ate"
           with frame fdtf 1 down side-label centered
           row 7.
    */
    for each ctcartcl where
            ctcartcl.datref >= vdti and
            ctcartcl.datref <= vdtf and
            ctcartcl.etbcod = 0
            no-lock:
        val-financeira = val-financeira + ctcartcl.dif-ecf-contrato.
        rec-financeira  = rec-financeira + (ctcartcl.dec2 / 100).
    end.
    for each tt-financeira:
        delete tt-financeira.
    end.    
    if val-financeira > 0
    then
    for each estab no-lock:
        do vdata = vdti to vdtf:
        disp "Processando... " estab.etbcod vdata
        with frame f-find 1 down no-label color message no-box row 10
        centered.
        pause 0.
        t-financeira = 0.
        for each contrato where contrato.dtinicial = vdata and
                            contrato.etbcod = estab.etbcod no-lock:
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) and
                              titulo.cobcod = 10
                              no-lock:
            find envfinan of titulo no-lock no-error.
            if avail envfinan and
                vtotal + titulo.titvlcob <= val-financeira
            then do:
                vtotal = vtotal + titulo.titvlcob.
                t-financeira = t-financeira + titulo.titvlcob.
            end.
        end.
        end.
        find first tt-financeira where
                   tt-financeira.etbcod = estab.etbcod and
                   tt-financeira.data = vdata
                   no-error.
        if not avail tt-financeira
        then do:
            create tt-financeira.
            assign
                tt-financeira.etbcod = estab.etbcod 
                tt-financeira.data   = vdata.
                
        end.    
        tt-financeira.valor = t-financeira.       
        end.
    end.
    for each ctcartcl where ctcartcl.etbcod > 0 and
                             ctcartcl.datref >= vdti and
                             ctcartcl.datref <= vdtf
                             .
        ctcartcl.dif-ecf-contrato = 0.
    end.
                                 
    message vtotal val-financeira. pause.
    for each tt-financeira:
        find ctcartcl where ctcartcl.etbcod = tt-financeira.etbcod and
                            ctcartcl.datref = tt-financeira.data
                             no-error.
        if not avail ctcartcl
        then do:
            create ctcartcl.
            assign
                ctcartcl.etbcod = tt-financeira.etbcod
                ctcartcl.datref = tt-financeira.data.
        end.    
        ctcartcl.dif-ecf-contrato = tt-financeira.valor.
    end.
    if rec-financeira > 0
    then do:
        
        for each tt-financeira: delete tt-financeira. end.
        
        for each ctcartcl where ctcartcl.etbcod > 0 and
                             ctcartcl.datref >= vdti and
                             ctcartcl.datref <= vdtf and
                             ctcartcl.dif-ecf-contrato > 0
                             .
            find first tt-financeira where
                   tt-financeira.etbcod = ctcartcl.etbcod and
                   tt-financeira.data   = ctcartcl.datref
                   no-error.
            if not avail tt-financeira
            then do:
                create tt-financeira.
                assign
                    tt-financeira.etbcod = ctcartcl.etbcod 
                    tt-financeira.data   = ctcartcl.datref.
                
            end.    
            tt-financeira.valor = rec-financeira * 
                    (ctcartcl.dif-ecf-contrato / vtotal).   
        end.
    
        for each ctcartcl where ctcartcl.etbcod > 0 and
                             ctcartcl.datref >= vdti and
                             ctcartcl.datref <= vdtf
                             .
            ctcartcl.dec2 = 0.
        end.
        for each tt-financeira:
           find ctcartcl where ctcartcl.etbcod = tt-financeira.etbcod and
                                ctcartcl.datref = tt-financeira.data
                                 no-error.
            if not avail ctcartcl
            then do:
                create ctcartcl.
                assign
                    ctcartcl.etbcod = tt-financeira.etbcod
                    ctcartcl.datref = tt-financeira.data.
            end.    
            ctcartcl.dec2 = tt-financeira.valor * 100.
        end.
    end.

end procedure.    




