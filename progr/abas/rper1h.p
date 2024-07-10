def var vvisu as char extent 3 init ["Impressora","Tela","Email"].

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char.
def var vetbcod     as int.
def var vqtdcortes as int.
def var vhrcorte    as char format "x(05)".
def var vhrconf     as char format "x(05)".

def var vdtini  as date format "99/99/9999".
def var vdtfim  as date format "99/99/9999".
def var vpendentes  as log.

def var vcortes     as log.

vdtini = today - 1.
vdtfim = today.


    update vpendentes label "Lista os Pendentes.."
        with frame f-dados.
    if vpendentes = no
    then vcortes = yes.

    disp vcortes      label "Filtra os Cortes...."
        with frame f-dados.
    update vcortes when vcortes = no 
        with frame f-dados.
    if vcortes
    then do:
        update vdtini label "Data Inicial........"
               vdtfim label "Data Final"
               skip
           with frame f-dados  width 80 side-labels overlay.
    end.
    
    do on error undo:
    
        update vetbcod label "Destino - Filial...."
               with frame f-dados.
    
        if vetbcod <> 0
        then do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Geral" @ estab.etbnom with frame f-dados.

    end.

     

    /*
    if opsys = "unix" 
    then do: 
        if vvisu
        then do:
            find first impress where impress.codimp = setbcod no-lock no-error. 
            if avail impress
            then do:
                run acha_imp.p (input recid(impress), 
                                output recimp).
                find impress where recid(impress) = recimp no-lock no-error.
                if avail impress
                then assign fila = string(impress.dfimp). 
            end.    
        end.
    end.
    else assign fila = "". 
    */

def buffer traplani for plani.
def var vhorareal   as char format "x(05)" column-label "Hr".
def var vhrconfer   as char format "x(05)" column-label "Hr".
def var vperccorte  as dec format ">>9%" column-label "%%". 
def var vperccarga  as dec format ">>9%" column-label "%%".

def var vseq as int.    

def var vqtdatend like abastransf.qtdatend.
def var vqtdemwms like abastransf.qtdemwms.

def temp-table tt-abastransf no-undo
    field dttransf  like abastransf.dttransf
    field etbcod    like abastransf.etbcod
    field abtcod    like abastransf.abtcod
    field abtqtd    like abastransf.abtqtd    

    field qtdcarga  like abasconfprod.qtdcarga
    
    field qtdPEND   like abastransf.abtqtd column-label "Pend"
    index idx is unique primary dttransf asc
                                etbcod  asc
                                abtcod  asc.

def temp-table tt-abascortes no-undo
    field etbcod    like abastransf.etbcod
    field abtcod    like abastransf.abtcod
    field dcbcod    like abascorteprod.dcbcod
    field dtcorte   like abascorte.datareal
    field qtdcorte  like abascorteprod.qtdcorte
    field qtdconf   like abasconfprod.qtdconf
    field qtdcarga  like abasconfprod.qtdcarga
    
    field qtdPEND   like abastransf.abtqtd column-label "Pend"
    index idx is unique primary etbcod  asc
                                abtcod  asc
                                dtcorte asc
                                dcbcod  asc.
                                
def temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format ">>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.

def var vabtsit as int.
def var cabtsit as char extent 3
    init ["AC","IN","SE"].

pause 0 before-hide.
hide message no-pause.
message "FASE 1...".

for each abaswms
    where abaswms.wms = "ALCIS_MOVEIS"
    no-lock:
    
    /* PENDENTES SEM CORTES */

    
    if vpendentes
    then  do vabtsit = 1 to 3.
        hide message no-pause.
        message "FASE 1..." cabtsit[vabtsit] vabtsit.
        
        for each abastwms of abaswms no-lock:
            hide message no-pause.
            message "FASE 1..." cabtsit[vabtsit] vabtsit abastwms.abatipo.

            for each abastransf where abastransf.wms = abaswms.wms and
                          abastransf.abatipo = abastwms.abatipo and  
                          abastransf.abtsit = cabtsit[vabtsit] and
                          abastransf.dttransf <= today
                no-lock.

            /*
            find first abascorteprod of abastransf no-lock no-error.
            if avail abascorteprod
            then next.
            */

            find first tt-abastransf where
                    tt-abastransf.dttransf = abastransf.dttransf and
                    tt-abastransf.etbcod = abastransf.etbcod and
                    tt-abastransf.abtcod = abastransf.abtcod
                    no-error.
            if not avail tt-abastransf
            then do: 
                create tt-abastransf. 
                tt-abastransf.dttransf = abastransf.dttransf.
                tt-abastransf.etbcod = abastransf.etbcod. 
                tt-abastransf.abtcod = abastransf.abtcod. 
                tt-abastransf.abtqtd = abastransf.abtqtd. 
            end.
            for each abascorteprod of abastransf no-lock.
                find abascorte of abascorteprod no-lock.
                find first tt-abascortes where
                    tt-abascortes.etbcod = abastransf.etbcod and
                    tt-abascortes.abtcod = abastransf.abtcod and
                    tt-abascortes.dtcorte = abascorte.datareal and
                    tt-abascortes.dcbcod = abascorteprod.dcbcod
                    no-error.
                if not avail tt-abascortes
                then do:
                    create tt-abascortes.
                    tt-abascortes.etbcod = abastransf.etbcod.
                    tt-abascortes.abtcod = abastransf.abtcod. 
                    tt-abascortes.dtcorte = abascorte.datareal.
                    tt-abascortes.dcbcod = abascorteprod.dcbcod.
                end.
            end.  
        end.
        end.
        
    end.
    
    
    /* CORTES DO PERIODO */
    if vcortes
    then for each abascorte
        where abascorte.wms         = abaswms.wms       and
              abascorte.interface   = abaswms.interface and
              abascorte.etbcd       = abaswms.etbcd     
                and
              abascorte.datareal    >= vdtini and
              abascorte.datareal    <= vdtfim  
                
        no-lock:
        disp abascorte.
        for each abascorteprod of abascorte 
            /*where abascorteprod.abtcod = 531*/
                no-lock:
                
            find abastransf of abascorteprod no-lock.
            
            find first tt-abastransf where
                    tt-abastransf.dttransf = abastransf.dttransf and
                    tt-abastransf.etbcod = abastransf.etbcod and
                    tt-abastransf.abtcod = abastransf.abtcod
                    no-error.
            if not avail tt-abastransf
            then do:
                create tt-abastransf.
                tt-abastransf.dttransf = abastransf.dttransf.
                tt-abastransf.etbcod = abastransf.etbcod.
                tt-abastransf.abtcod = abastransf.abtcod.
                tt-abastransf.abtqtd = abastransf.abtqtd.
            end.

            find first tt-abascortes where
                    tt-abascortes.etbcod = abastransf.etbcod and
                    tt-abascortes.abtcod = abastransf.abtcod and
                    tt-abascortes.dtcorte = abascorte.datareal and
                    tt-abascortes.dcbcod = abascorteprod.dcbcod
                    no-error.
            if not avail tt-abascortes
            then do:
                create tt-abascortes.
                tt-abascortes.etbcod = abastransf.etbcod.
                tt-abascortes.abtcod = abastransf.abtcod. 
                tt-abascortes.dtcorte = abascorte.datareal. 
                tt-abascortes.dcbcod = abascorteprod.dcbcod.
            end.

            /**
            find first  abascargaprod where 
                    abascargaprod.dcbcod = abascorteprod.dcbcod and
                    abascargaprod.procod = abascorteprod.procod
                                no-lock no-error.
            if avail abascargaprod
            then do:                
                find abasintegracao of abascargaprod no-lock.
                        
                find traplani where
                    traplani.etbcod = abasintegracao.etbcd and
                    traplani.placod = abasintegracao.placod
                    no-lock no-error.
            end.                
            **/
        end.
    end.
        
end.    


hide message no-pause.
message "FASE 2...".
/* calcula cortes */
for each tt-abastransf.

    run criatt (tt-abastransf.etbcod,
                tt-abastransf.abtcod).    

    for each tt-abascortes where
            tt-abascortes.etbcod = tt-abastransf.etbcod and
            tt-abascortes.abtcod = tt-abastransf.abtcod .
        for each tt-cortes.
            if tt-cortes.oper = "PEDIDO" or
               tt-cortes.dcbcod = tt-abascortes.dcbcod
            then    tt-abascortes.qtdpend = tt-cortes.qtdpend + tt-cortes.qtdemwms .
            if tt-cortes.oper = "CORTE" and
               tt-cortes.dcbcod = tt-abascortes.dcbcod
            then    tt-abascortes.qtdcorte = tt-cortes.qtd.
            if tt-cortes.oper = "CONF" and
               tt-cortes.dcbcod = tt-abascortes.dcbcod
            then    tt-abascortes.qtdconf = tt-cortes.qtd.
            
            if tt-cortes.oper = "NOTA" and
               tt-cortes.dcbcod = tt-abascortes.dcbcod
            then do:
                tt-abascortes.qtdcarga = tt-abascortes.qtdcarga + tt-cortes.qtd.
                tt-abastransf.qtdcarga = tt-abastransf.qtdcarga + tt-cortes.qtd.
            end.
        end.
    end.
    /* Pendencia do Pedido */
    tt-abastransf.qtdpend = tt-abastransf.abtqtd - tt-abastransf.qtdcarga.
end.


/* Relatorio */
pause before-hide.
hide message no-pause.
message "FASE 3...".

varquivo = "/home/helio.neto/teste.html".

output to value(varquivo).

put unformatted skip 
" 
<HTML>" skip
"    <meta charset=\"utf-8\">" skip
"    <head>
        <style type=\"text/css\">
        .myOtherTable \{ background-color:#fff;border-collapse:separete;color:#000;font-size:15px;width:100%;font-family:'PT Sans',Tahoma \}
        .myOtherTable th \{ background-color:#d2e3ef;color:#4a4a4a; \}
        .myOtherTable td, .myOtherTable th \{ padding:2px;border:0;white-space:normal \}
        .myOtherTable td \{ border-bottom:1px dotted #BDB76B;color:#666 \}
        </style>
    </head> " skip
    
"    <h1>Performance de Entregas  - De " + string(vdtini) + " ate " + string(vdtfim) + "</h1>" skip
    
    "<h2>Analitico por pedidos </h2>" skip
    
    "<table class=\"myOtherTable\">" skip.
put unformatted
    "<PRE>" skip.
    
/****
put unformatted skip                
"<tr>".    
    put unformatted "<th></th>". 
    /*put unformatted "<th></th>". 
    put unformatted "<th colspan=4>Venda</th>". 
    */
    put unformatted "<th></th>". 
    put unformatted "<th colspan=5>Pedido</th>". 
    put unformatted "<th colspan=3>Entrega</th>". 
    put unformatted "<th colspan=4>Corte</th>". 
    put unformatted "<th colspan=5>Conferencia/Separacao</th>". 
    
put unformatted "</tr>" skip.


put unformatted skip                
"<tr>".    
    put unformatted "<th>Filial</th>". 
    /*
    put unformatted "<th>PedExterno</th>". 
    put unformatted "<th>Origem</th>". 
    put unformatted "<th>Data</th>". 
    put unformatted "<th>Ser</th>". 
    put unformatted "<th>NfVenda</th>". 
    */
    put unformatted "<th>Produto</th>". 
    put unformatted "<th>Dt Ped</th>". 
    put unformatted "<th>Tipo</th>". 
    put unformatted "<th>Numero</th>". 
    put unformatted "<th>Sit</th>". 
    put unformatted "<th>Qtd</th>". 
    put unformatted "<th>Carga</th>". 
    put unformatted "<th>%%</th>". 
    put unformatted "<th>Pend</th>". 

    put unformatted "<th>Corte</th>". 
    put unformatted "<th>DtCorte</th>". 
    put unformatted "<th>Hr</th>". 
    put unformatted "<th>Qtd</th>". 
    put unformatted "<th>DtConfer</th>". 
    put unformatted "<th>Hr</th>". 
    put unformatted "<th>Conf</th>". 
    put unformatted "<th>Carga</th>". 
    put unformatted "<th>%%</th>". 

put unformatted "</tr>" skip.
****/

for each tt-abastransf
    /*where tt-abastransf.qtdpend > 0*/
    break 
        by tt-abastransf.etbcod
        by tt-abastransf.dttransf
        by tt-abastransf.abtcod
    with frame fcortes:

        
    find abastransf where
        abastransf.etbcod = tt-abastransf.etbcod and
        abastransf.abtcod = tt-abastransf.abtcod
        no-lock.
        
        
    find plani where plani.etbcod = abastransf.orietbcod and
                         plani.placod = abastransf.oriplacod
                   no-lock no-error.

    /****
    put "<TR>".
    
    put unformatted "<td align='center'>" abastransf.etbcod      "</td>". 
    /*
    put unformatted "<td align='center'>" if abastransf.pedexterno = ? then "" else abastransf.pedexterno "</td>". 
    if avail plani
    then do:
        put unformatted "<td align='center'>" plani.etbcod  "</td>". 
        put unformatted "<td align='center'>" plani.pladat  "</td>". 
        put unformatted "<td align='center'>" plani.serie  "</td>". 
        put unformatted "<td align='center'>" plani.numero  "</td>". 
    end.
    else do:
        put unformatted "<td colspan=4 align='center' >"  "</td>". 
    end.                
    */
    put unformatted "<td align='center'>" abastransf.procod  "</td>". 

    put unformatted "<td align='center'>" abastransf.dttransf format "99/99/9999"  "</td>". 
    
    find abastipo of abastransf no-lock.
    put unformatted "<td align='center'>" abastipo.abatnom  "</td>". 
    put unformatted "<td align='center'>" abastransf.abtcod  "</td>". 
    put unformatted "<td align='center'>" abastransf.abtsit  "</td>". 

    vperccarga = tt-abastransf.qtdcarga / tt-abastransf.abtqtd * 100.

    put unformatted "<td align='center'>" tt-abastransf.abtqtd  "</td>". 
    if vperccarga <> 100
    then do:
        put unformatted "<td align='center'  bgcolor='F59393'>" tt-abastransf.qtdcarga  "</td>". 
        put unformatted "<td align='center'  bgcolor='F59393'>" vperccarga  "</td>". 
    end.        
    else do:
        put unformatted "<td align='center'>" tt-abastransf.qtdcarga  "</td>". 
        put unformatted "<td align='center'>" vperccarga  "</td>". 
    end.    
    put unformatted "<td align='center'>" tt-abastransf.qtdPEND  "</td>". 

    vqtdcortes = 0.
        for each tt-abascortes where
                    tt-abascortes.etbcod = tt-abastransf.etbcod and
                    tt-abascortes.abtcod = tt-abastransf.abtcod
            with frame fcortes:
            vqtdcortes = vqtdcortes + 1.
            if vqtdcortes > 1
            then do:
                put unformatted "<tr>".
                put unformatted "<td colspan=15>"  "</td>".            
            end.
            vperccorte = tt-abascortes.qtdcarga / tt-abascortes.qtdcorte * 100.

            find abascorte where abascorte.dcbcod = tt-abascortes.dcbcod no-lock. 
            
                put unformatted "<td align='center'>" tt-abascortes.dcbcod  "</td>".

                put unformatted "<td align='center'>" abascorte.datareal format "999999"  "</td>".
                put unformatted "<td align='center'>" string(abascorte.horareal,"HH:MM")  "</td>".
                put unformatted "<td align='center'>" tt-abascortes.qtdcorte  "</td>".
                put unformatted "<td align='center'>" abascorte.dtconfer  format "999999"  "</td>".
                put unformatted "<td align='center'>" string(abascorte.hrconfer,"HH:MM")  "</td>".
                put unformatted "<td align='center'>" tt-abascortes.qtdconf  "</td>".
                if vperccorte <> 100  
                then do:
                    put unformatted "<td align='center' bgcolor='F59393' >" tt-abascortes.qtdcarga  "</td>".
                    put unformatted "<td align='center' bgcolor='F59393' >" vperccorte  "</td>".
                end.
                else do:
                    put unformatted "<td align='center'>" tt-abascortes.qtdcarga  "</td>".
                    put unformatted "<td align='center'>" vperccorte  "</td>".
                end.
                put unformatted "</tr>" skip.
        end.

    ****/
    
    disp  
        abastransf.etbcod .
    /**    
    disp abastransf.pedexterno when abastransf.pedexterno <> ?. 
    disp plani.etbcod when avail plani and 
                            plani.etbcod <> abastransf.etbcod column-label "Origem"
    **/
    
    /**plani.pladat when avail plani   
    plani.serie  when avail plani column-label "Ser"
    **/
    disp
    plani.numero when avail plani column-label "NF.Venda".                               
    disp 
        abastransf.procod.
    
    disp "|". 
    disp  
        abastransf.dttransf format "999999"
        abastransf.abatipo 
    /*    abastransf.abtcod column-label "Pedido"
        abastransf.abtsit.     */ .
    /*disp abastransf.candt.*/
    disp "|".
    
    vperccarga = tt-abastransf.qtdcarga / tt-abastransf.abtqtd * 100.
    
    disp tt-abastransf.abtqtd
         tt-abastransf.qtdcarga
         vperccarga
         tt-abastransf.qtdPEND.

    disp "|".
    
        for each tt-abascortes where
                    tt-abascortes.etbcod = tt-abastransf.etbcod and
                    tt-abascortes.abtcod = tt-abastransf.abtcod
            with frame fcortes:

            vperccorte = tt-abascortes.qtdcarga / tt-abascortes.qtdcorte * 100.

            find abascorte where abascorte.dcbcod = tt-abascortes.dcbcod no-lock. 
            disp
                tt-abascortes.dcbcod
                abascorte.datareal format "999999"
                string(abascorte.horareal,"HH:MM") @ vhrcorte column-label "Hr"
                tt-abascortes.qtdcorte
                "|"
                abascorte.dtconfer  format "999999"
                string(abascorte.hrconfer,"HH:MM") @ vhrconfer column-label "Hr"
                tt-abascortes.qtdconf
                "|"
                tt-abascortes.qtdcarga
                vperccorte.
            down with frame fcortes.
        end.
    down with frame fcortes.
    
    /****if vqtdcortes = 0
    then put
        "</TR>" skip.
        ****/
        
end.    
    
put unformatted 
    "</table>
    </HTML>".
output close.    

    if opsys = "unix"
    then do:

        if vvisu
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p (input varquivo, input "").
        
    end. 

    assign
        vassunto = "Teste email" 
        vdestino = "helio.alves@lebes.com.br"
    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~" 2>&1". 
    unix silent value(varqmail) >x.txt.
    

procedure criatt.
def input parameter par-etbcod  like abastransf.etbcod.
def input parameter par-abtcod  like abastransf.abtcod.

for each tt-cortes.
    delete tt-cortes.
end.

    find abastransf where abastransf.etbcod = par-etbcod and
                          abastransf.abtcod = par-abtcod
         no-lock.

    find first abascorteprod of abastransf no-lock no-error.
    
    if not avail abascorteprod
    then next.
    
    vseq = 0. 
    for each abascorteprod of abastransf no-lock.
        
        find abascorte of abascorteprod no-lock.    
    
        find tt-cortes where tt-cortes.oper   = "PEDIDO" and
                      tt-cortes.etbcod = abastransf.etbcod and
                      tt-cortes.abtcod = abastransf.abtcod
                      no-error.
        if not avail tt-cortes then do:
            vseq = vseq + 1.
            create tt-cortes.
            tt-cortes.seq = vseq.
            tt-cortes.oper = "PEDIDO".
            tt-cortes.rec  = recid(abastransf).
            tt-cortes.etbcod = abastransf.etbcod.
            tt-cortes.abtcod = abastransf.abtcod.
            tt-cortes.qtd    = abastransf.abtqtd.
            tt-cortes.datareal = abastransf.dtinclu.
            tt-cortes.horareal = abastransf.hrinclu.
        end.
        
            vseq = vseq + 1.
            create tt-cortes.
            tt-cortes.seq      = vseq.
            tt-cortes.oper     = "CORTE".
            tt-cortes.rec      = recid(abascorteprod).
            tt-cortes.etbcod   = abastransf.etbcod.
            tt-cortes.abtcod   = abastransf.abtcod.
            tt-cortes.datareal = abascorte.datareal.
            tt-cortes.horareal = abascorte.horareal.
            tt-cortes.dcbcod   = abascorte.dcbcod. 
            tt-cortes.numero   = abascorteprod.dcbcod.
            tt-cortes.qtd      = abascorteprod.qtdcorte.
        
        for each abasconfprod of abascorteprod no-lock.

                vseq = vseq + 1.
                create tt-cortes.
                tt-cortes.seq      = vseq.
                tt-cortes.oper     = "CONF".
                tt-cortes.rec      = recid(abasconfprod).
                tt-cortes.etbcod   = abastransf.etbcod.
                tt-cortes.abtcod   = abastransf.abtcod.
                tt-cortes.datareal = abasconfprod.datareal.
                tt-cortes.horareal = abasconfprod.horareal.
                tt-cortes.dcbcod   = abascorte.dcbcod. 
                tt-cortes.numero   = abascorteprod.dcbcod.
                tt-cortes.qtd      = abasconfprod.qtdconf.

            
        end.
        for each abascargaprod of abascorte 
                where abascargaprod.procod = abascorteprod.procod no-lock.
            find abasintegracao of abascargaprod no-lock.
            find abasconfprod of abascorteprod no-lock no-error.
            if not avail abasconfprod
            then next.
            
            
                vseq = vseq + 1.
                create tt-cortes.
                tt-cortes.seq      = vseq.
                tt-cortes.oper     = "CARGA".
                tt-cortes.rec      = recid(abasconfprod).
                tt-cortes.etbcod   = abastransf.etbcod.
                tt-cortes.abtcod   = abastransf.abtcod.
                tt-cortes.dcbcod   = abascorte.dcbcod. 
                tt-cortes.numero   = abasintegracao.ncarga.
                tt-cortes.datareal = abasintegracao.datareal.
                tt-cortes.horareal = abasintegracao.horareal.
                tt-cortes.qtd      = abasconfprod.qtdcarga.

                

            if abasintegracao.dtfim <> ? and
               (abasintegracao.placod <> 0 and
                abasintegracao.placod <> ?)
            then do:

                    find plani where plani.etbcod = abasintegracao.etbcd and
                                     plani.placod = abasintegracao.placod
                                     no-lock no-error.
                    vseq = vseq + 1.
                    create tt-cortes.
                    tt-cortes.seq      = vseq.
                    tt-cortes.oper     = "NOTA".
                    tt-cortes.rec      = recid(abasconfprod).
                    tt-cortes.etbcod   = abastransf.etbcod.
                    tt-cortes.abtcod   = abastransf.abtcod.
                    tt-cortes.dcbcod   = abascorte.dcbcod. 
                    tt-cortes.numero   = if avail plani
                                         then plani.numero
                                         else abasintegracao.ncarga.
                    tt-cortes.datareal = abasintegracao.dtfim.
                    tt-cortes.horareal = abasintegracao.hrfim.
                    tt-cortes.qtd      = abasconfprod.qtdcarga.
                    tt-cortes.traetbcod = if avail plani
                                          then plani.etbcod
                                          else 0.
                    tt-cortes.traplacod = if avail plani
                                          then plani.placod
                                          else 0.
                                          
                                    
            
            end.
            
        end.
    end.


for each tt-cortes.
    if tt-cortes.oper = "PEDIDO"
    then do:
        vqtdatend = 0.
        vqtdemwms  = 0. 
        tt-cortes.qtdPEND  = tt-cortes.qtd.
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend.  
        tt-cortes.abtsit   = "AC".
    end.
    if tt-cortes.oper = "CORTE"
    then do: 
        find abascorteprod where recid(abascorteprod) = tt-cortes.rec no-lock. 
        find abastransf    of abascorteprod no-lock. 
        vqtdemwms   = vqtdemwms + abascorteprod.qtdcorte. 
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        tt-cortes.abtsit   = if tt-cortes.qtdpend > 0 
                             then "AC" 
                             else "IN".
    end.
    if tt-cortes.oper = "CONF"
    then do: 
        find abasconfprod where recid(abasconfprod) = tt-cortes.rec no-lock. 
        find abascorteprod of abasconfprod no-lock.
        find abastransf    of abascorteprod no-lock.
        
        vqtdemwms   = vqtdemwms - abascorteprod.qtdcorte. 
        vqtdemwms   = vqtdemwms + abasconfprod.qtdconf.   
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        
        tt-cortes.abtsit   = if tt-cortes.qtdpend > 0 
                             then "AC" 
                             else "SE".
    end.
    if tt-cortes.oper = "CARGA"
    then do: 
        find abasconfprod where recid(abasconfprod) = tt-cortes.rec no-lock.
        find abascorteprod of abasconfprod no-lock.
        find abastransf of abascorteprod no-lock.
        
        vqtdemwms   = vqtdemwms - abasconfprod.qtdconf. 
        vqtdemwms   = vqtdemwms + abasconfprod.qtdcarga.   
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        
        tt-cortes.abtsit   = if tt-cortes.qtdpend > 0 
                             then "AC"
                             else "SE".
    end.
    if tt-cortes.oper = "NOTA"
    then do: 
        find abasconfprod where recid(abasconfprod) = tt-cortes.rec no-lock.
        find abascorteprod of abasconfprod no-lock.
        find abastransf of abascorteprod no-lock.
        
        vqtdemwms   = vqtdemwms - abasconfprod.qtdcarga. 
        vqtdatend   = vqtdatend + abasconfprod.qtdcarga. 
        tt-cortes.qtdemwms = vqtdemwms. 
        tt-cortes.qtdatend = vqtdatend. 
        tt-cortes.qtdPEND  = abastransf.abtqtd - vqtdemwms - vqtdatend. 
        if tt-cortes.qtdpend < 0
        then tt-cortes.qtdpend = 0.
        
        tt-cortes.abtsit   = if tt-cortes.qtdpend > 0 
                             then "AC" 
                             else "NE".
    end.
    

end.


        
end procedure.            
     

