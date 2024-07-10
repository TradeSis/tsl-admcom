{admcab.i}

def input parameter par-wms as char.

def var vcp as char init ";".

def var bwms         as char format "x(18)" extent 4
    initial ["MOVEIS",
             "MODA",   
             "VEX",
             "ESPECIAL"].
def var vwms         as char format "x(18)" extent 4
    initial [""].
             
def var iwms as int.
def var cwms    as char extent 4
    initial ["ALCIS_MOVEIS",
             "ALCIS_MODA",
             "ALCIS_VEX",
             "ALCIS_ESP"].


def var bvisu as char extent 4 format "x(12)" init [" Excel CSV","  Tela","  Email","Impressora"].
def var vvisu as char extent 4 format "x(12)" init [" Excel CSV","  Tela","  Email","Impressora"].
def var ivisu as int.
def var cvisu as char.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char format "x(50)".
def var par-etbcod     as int.
def var vqtdcortes as int.
def var vhrcorte    as char format "x(05)".
def var vhrconf     as char format "x(05)".

def var vdtini  as date format "99/99/9999".
def var vdtfim  as date format "99/99/9999".
def var vpendentes  as log.

def var vfilcortes     as log.

vdtini = today - 1.
vdtfim = today.
    vwms = "".
    do iwms = 1 to 4.
        if cwms[iwms] = par-wms
        then do:
            vwms[iwms] = bwms[iwms].
            leave.
        end.    
    end.
    
    disp skip " "
        vwms no-label
        skip(1)
        with frame f-dados.


    update vpendentes label "Apenas Pendentes...." format "Sim/Nao" skip
        with frame f-dados.
    if vpendentes = no
    then vfilcortes = yes.

    disp vfilcortes      label "Filtra os Cortes...." format "Sim/Nao"    
        with frame f-dados.
    /*
    update vfilcortes when vfilcortes = no 
        with frame f-dados.
    */
    if vfilcortes
    then do:
        update vdtini label "Data Inicial"
               vdtfim label "Data Final"
               skip
           with frame f-dados  width 80 side-labels overlay.
    end.
    
    do on error undo:
    
        update par-etbcod label "Destino - Filial...."
               with frame f-dados.
    
        if par-etbcod <> 0
        then do:
            find estab where estab.etbcod = par-etbcod no-lock no-error.
            if not avail estab
            then do:
                message "Filial nao cadastrada".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-dados.
        end.
        else disp "Geral" @ estab.etbnom with frame f-dados.

    end.
    disp
        "Tipo de Relatorio...: "
        with frame f-dados.
    vvisu = bvisu.
    disp
        vvisu no-label
            with frame f-dados.
    choose field vvisu
            with frame f-dados.    
    ivisu = frame-index.         
    cvisu = trim(vvisu[ivisu]).             

    if cvisu = "EMAIL"
    then update skip
     vdestino label "       Destino......"
               with frame f-dados.
   
    if cvisu = "EXCEL CSV"
    then do:
        vdestino = "/Relat_Neo/rperformance_" +  
                    string(today,"999999") + 
                    replace(string(time,"HH:MM"),":","") + ".csv".

        update vdestino
            with frame f-dados.
    end.
    def var fila as char.    
    if opsys = "unix" 
    then do: 
        if cvisu = "Impressora"
        then do:
            find first impress where impress.codimp = setbcod no-lock no-error. 
            if avail impress
            then do:
                def var recimp as recid.
                run acha_imp.p (input  recid(impress), 
                                output recimp).
                find impress where recid(impress) = recimp no-lock no-error.
                if avail impress
                then assign fila = string(impress.dfimp). 
            end.    
        end.
    end.
    else assign fila = "". 
    

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
    where abaswms.wms = par-wms
    no-lock 
    on error undo, leave:
    
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

            if par-etbcod <> 0
            then if abastransf.etbcod <> par-etbcod
                 then next.

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
    if vfilcortes
    then for each abascorte
        where abascorte.wms         = abaswms.wms       and
              abascorte.interface   = abaswms.interface and
              abascorte.etbcd       = abaswms.etbcd     
                and
              abascorte.datareal    >= vdtini and
              abascorte.datareal    <= vdtfim  
                
        no-lock:
        
            if par-etbcod <> 0
            then if abascorte.etbcod <> par-etbcod
                 then next.

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
message "Gerando Relatorio " vvisu[ivisu].

if cvisu = "EXCEL CSV"
then varquivo = vdestino.
else varquivo = "/admcom/relat/rperformance_" +  string(today,"999999") + 
                    replace(string(time,"HH:MM"),":","") + ".txt".

vassunto = "PERFORMANCE DE CORTES " +
           vwms[iwms] + "      ..." 
        + string(today,"999999") + replace(string(time,"HH:MM:SS"),":","").

if cvisu = "TELA" or
   cvisu = "Impressora"
then do:
    {mdadmcab.i &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rper1"" 
                &Nom-Sis   = """WMS """ 
                &Tit-Rel   = " vassunto "
                &Width     = "120" 
                &Form      = "frame f-cabcab"}
    
end.
if cvisu = "EMAIL"
then do:
    
    output to value(varquivo).
    
    put unformatted skip 
    " 
    <HTML>" skip
    "    <meta charset=\"utf-8\">" skip
    "<h2>" vassunto "</h2>" skip.
    
    put unformatted
        "<PRE>" skip.
end.
if cvisu = "EXCEL CSV"
then do:


    output to value(varquivo).
        put unformatted skip
            "LOJA" vcp
            "NF VENDA" vcp 
            "PRODUTO" vcp
            "DT PEDIDO" vcp
            "TIPO"  vcp
            "PEDIDO"   vcp
            "QTD PEDIDO" vcp
            "QTD NF EMITIDA" vcp
            "%%"    vcp
            "QTD PENDENTE" vcp.

    find first tt-abascortes no-error.
    if avail tt-abascortes
    then put unformatted
                "CORTE"   vcp
                "DT CORTE" vcp   
                "HR CORTE" vcp
                "QTD DISPONIVEL" vcp
                "DT CONFER"    vcp
                "HR CONFER" vcp
                "QTD CONFER NO WMS"      vcp
                "QTD NF EMITIDA"   vcp
                "%%" .
    put unformatted        
             skip.
    
end.

    vvisu = "".
    vvisu[ivisu] = bvisu[ivisu].    
    
if cvisu <> "EXCEL CSV"
then    do:
    disp vvisu
         with frame f-dados.   
    disp 
        with frame f-dados.
end.

for each tt-abastransf
    break 
        by tt-abastransf.etbcod
        by tt-abastransf.dttransf
        by tt-abastransf.abtcod
    on error undo, return        
    with frame fcortes
        width 200:

        
    find abastransf where
        abastransf.etbcod = tt-abastransf.etbcod and
        abastransf.abtcod = tt-abastransf.abtcod
        no-lock.
        
        
    find plani where plani.etbcod = abastransf.orietbcod and
                         plani.placod = abastransf.oriplacod
                   no-lock no-error.

    vperccarga = tt-abastransf.qtdcarga / tt-abastransf.abtqtd * 100.
    
    if cvisu = "EXCEL CSV"
    then do:
   
        put unformatted skip
            abastransf.etbcod vcp
            trim((if avail plani
             then  string(plani.numero,">>>>>>>>>>>")
             else  "")) vcp 
            abastransf.procod vcp
            abastransf.dttransf vcp
            abastransf.abatipo  vcp
            abastransf.abtcod   vcp
            tt-abastransf.abtqtd vcp
            tt-abastransf.qtdcarga vcp
            vperccarga      vcp
            tt-abastransf.qtdPEND vcp.
        vqtdcortes = 0.
        for each tt-abascortes where
                    tt-abascortes.etbcod = tt-abastransf.etbcod and
                    tt-abascortes.abtcod = tt-abastransf.abtcod
            with frame fcortes:

            vperccorte = tt-abascortes.qtdcarga / tt-abascortes.qtdcorte * 100.

            find abascorte where abascorte.dcbcod = tt-abascortes.dcbcod no-lock. 
            vqtdcortes = vqtdcortes + 1.
            if vqtdcortes > 1
            then put unformatted skip
                abastransf.etbcod vcp
                trim((if avail plani
                 then  string(plani.numero,">>>>>>>>>>>")
                 else  "")) vcp 
                abastransf.procod vcp
                abastransf.dttransf vcp
                abastransf.abatipo  vcp
                abastransf.abtcod   vcp
                tt-abastransf.abtqtd vcp
                tt-abastransf.qtdcarga vcp
                vperccarga      vcp
                tt-abastransf.qtdPEND vcp.

            put unformatted
                tt-abascortes.dcbcod    vcp
                abascorte.datareal      vcp   
                string(abascorte.horareal,"HH:MM")  vcp
                tt-abascortes.qtdcorte  vcp
                abascorte.dtconfer          vcp
                string(abascorte.hrconfer,"HH:MM") vcp
                tt-abascortes.qtdconf       vcp
                tt-abascortes.qtdcarga      vcp
                vperccorte skip.
        end.
        if vqtdcortes = 0
        then put skip.

        
    end.
    else do:

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
        disp plani.numero format ">>>>>>>>9" when avail plani column-label "NF.Venda".                               
        disp  abastransf.procod.
        disp "|". 
        disp  
            abastransf.dttransf format "999999"
            abastransf.abatipo 
        /*    abastransf.abtcod column-label "Pedido"
            abastransf.abtsit.     */ .
        /*disp abastransf.candt.*/
        disp "|".
        disp tt-abastransf.abtqtd column-label "QTD!PEDIDO"
             tt-abastransf.qtdcarga column-label "QTD!NF!EMITIDA"
             vperccarga
             tt-abastransf.qtdPEND column-label "QTD!PEND".
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
                tt-abascortes.qtdcorte column-label "QTD!DISPO"
                "|"
                abascorte.dtconfer  format "999999"
                string(abascorte.hrconfer,"HH:MM") @ vhrconfer column-label "Hr"
                tt-abascortes.qtdconf column-label "QTD!CONFER!NO WMS"
                "|"
                tt-abascortes.qtdcarga column-label "QTD!NF EMITIDA"
                vperccorte.
            down with frame fcortes.
        end.
        down with frame fcortes.
    end.
        
end.    

if cvisu <> "EXCEL CSV"
then put skip fill("_",120) format "x(120)" skip.
    
if cvisu = "EMAIL"
then do:
    put unformatted 
        "</HTML>".
end.

        
output close.    

hide message no-pause.

    if opsys = "unix"
    then do:

        if cvisu = "Impressora"
        then os-command silent lpr value(fila + " " + varquivo).
        if cvisu = "Tela"
        then run visurel.p (input varquivo, input "").
        if cvisu = "EMAIL"
        then do:
                assign
                    varqmail = "/admcom/progr/mail.sh " +
                        " ~"" + vassunto + "~"" +
                        " ~"" + varquivo + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"" + vdestino + "~"" +
                        " ~"text/html~" 2>&1 " +
                        " >" + varquivo + "x.txt". 
                    unix silent value(varqmail).
             end.
    end. 
    
hide message no-pause.


do on endkey undo, retry:
    hide message no-pause.
    message "Gerado Relatorio em " vvisu[ivisu] vdestino.
    pause.
end.

return.
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
            find abasintegracao of abascargaprod no-lock no-error.
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
                tt-cortes.numero   = if avail abasintegracao
                                     then abasintegracao.ncarga
                                     else 0.
                tt-cortes.datareal = if avail abasintegracao
                                     then abasintegracao.datareal
                                     else ?.
                tt-cortes.horareal = if avail abasintegracao
                                     then abasintegracao.horareal
                                     else ?.
                tt-cortes.qtd      = abasconfprod.qtdcarga.

                

            if avail abasintegracao and
               ( abasintegracao.dtfim <> ? and
               (abasintegracao.placod <> 0 and
                abasintegracao.placod <> ?) )
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
     

