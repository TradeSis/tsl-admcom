def var vbatch as log.
vbatch = session:batch-mode.
{admcab.i}


def input param  par-wms as char.

def var vporloja    as log format "Sim/Nao" init yes.
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

def var vdata as date.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char format "x(50)".
def var par-etbcod     as int.
def var vqtdcarga   as int.
def var vqtdcortes as int.
def var vhrcorte    as char format "x(05)".
def var vhrconf     as char format "x(05)".

def var vdtini  as date format "99/99/9999".
def var vdtfim  as date format "99/99/9999".

def buffer traplani for plani.
def var vhorareal   as char format "x(05)" column-label "Hr".
def var vhrconfer   as char format "x(05)" column-label "Hr".
def var vperccorte  as dec format ">>9%" column-label "%%". 
def var vperccarga  as dec format ">>9%" column-label "%%".

def var vseq as int.    

def var vqtdatend like abastransf.qtdatend.
def var vqtdemwms like abastransf.qtdemwms.
def var vconta as int.
def new shared temp-table tt-cortes no-undo
    field rec       as recid
    field etbcod    like abascorteprod.etbcod
    field abtcod    like abascorteprod.abtcod
    field seq       as int format ">>>>9"
    field Oper      as char
    field datareal  like abascorte.datareal
    field horareal  like abascorte.horareal
    field dcbcod    like abascorte.dcbcod   format ">>>>>>>"
    field numero    as   int                format ">>>>>>>"
    field qtd       as int format ">>>>9"
    field qtdemWMS  like abastransf.qtdemwms
    field qtdatend  like abastransf.qtdatend 
    field qtdPEND   as int format "->>>>9"
    field abtsit    like abastransf.abtsit
    field traetbcod like plani.etbcod
    field traplacod like plani.placod
    index sequencia is unique primary etbcod asc abtcod asc dcbcod asc seq  asc.


def temp-table tt-datas no-undo
    field data  as date
    field qtdcarga  as int
    index idx is unique primary data asc.


def temp-table tt-abascortes no-undo
    field etbcod    like abastransf.etbcod
    field procod    like abastransf.procod
    field dtcorte   like abascorte.datareal
    field dtcarga   as   date extent 5 format "999999"
    field qtdcorte  like abascorteprod.qtdcorte format ">>>>9"
    field qtdcarga  like abasconfprod.qtdcarga extent 5 format ">>>>>>>9"
    field perccarga as   dec format ">>9.99%"  extent 5
    field qtdPEND   like abastransf.abtqtd column-label "Pend" format "->>>>9"

    field percpend  as   dec format ">>>9.99%"  
    
    index idx is unique primary 
                                etbcod  asc
                                procod  asc
                                dtcorte asc.

def buffer btt-abascortes for tt-abascortes.

def var cabtsit as char extent 3
    init ["AC","IN","SE"].


vdtini = today - 1.
vdtfim = today - 1.
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
        with frame f-dados
            with title " Performance do CD ".

    if vBATCH = yes
    then do:
        vporloja = no.
        disp vporloja
            label "Aberto Por Loja....." skip
                with frame f-dados.
        vdtini = today - 30.
        vdtfim = today - 1.
        
        disp vdtini label "Data Inicial........"
               vdtfim label "Data Final"
               skip
           with frame f-dados  width 80 side-labels overlay.
    end.
    else do:
        update vporloja
            with frame f-dados.
            
        update vdtini 
               vdtfim 
           with frame f-dados  width 80 side-labels overlay.
    end.    
    if vbatch = yes or vporloja = no
    then do:
        par-etbcod = 0.
        disp par-etbcod label "Destino - Filial...."
               with frame f-dados.
        disp "Geral" @ estab.etbnom with frame f-dados.
    end.
    else  do on error undo:
    
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
    vvisu[1] = bvisu[1].
    vvisu[2] = bvisu[2].
    vvisu[3] = bvisu[3].
    vvisu[4] = bvisu[4].
    
    if vbatch = yes
    then do:
        ivisu = 3.
        cvisu = trim(vvisu[ivisu]).             
        disp vvisu
            with frame f-dados.
        
        vdestino = "relatorios.cd@lebes.com.br;michele.michelsen@lebes.com.br".
       
        disp skip
         vdestino label "       Destino......"
               with frame f-dados.
            
    end.    
    else do:
        disp
            vvisu no-label
                with frame f-dados.
    
        choose field vvisu
                with frame f-dados.    
        ivisu = frame-index.         
        cvisu = trim(vvisu[ivisu]).             

        if cvisu = "EMAIL"
        then update vdestino 
               with frame f-dados.
    
    end.
    
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
    


pause 0  before-hide.
message "Aguarde..." today string(time,"HH:MM:SS").

for each abaswms
    where abaswms.wms = par-wms
    no-lock 
    on error undo, leave:
    
    /* PENDENTES SEM CORTES */

    
    for each abascorte
        where abascorte.wms         = abaswms.wms       and
              abascorte.interface   = abaswms.interface and
              abascorte.etbcd       = abaswms.etbcd      and
              abascorte.datareal    >= vdtini and
              abascorte.datareal    <= vdtfim  
                
        no-lock:
        
            if par-etbcod <> 0
            then if abascorte.etbcod <> par-etbcod
                 then next.

        for each abascorteprod of abascorte 
                        no-lock:
                
            find abastransf of abascorteprod no-lock no-error.
            if not avail abastransf
            then next.
            
                                    
            run abas/transfqtdsit.p (recid(abastransf), no).
            
            find first tt-abascortes where
                tt-abascortes.etbcod = abastransf.etbcod and
                (if cvisu = "EXCEL CSV"
                 then tt-abascortes.procod = abastransf.procod 
                 else tt-abascortes.procod = 0 ) and
                tt-abascortes.dtcorte = abascorte.datareal
                 no-error.
            if not avail tt-abascortes
            then do:
                create tt-abascortes.
                tt-abascortes.etbcod = abastransf.etbcod.
                if cvisu = "EXCEL CSV"
                then tt-abascortes.procod = abastransf.procod .
                else tt-abascortes.procod = 0 .
                tt-abascortes.dtcorte = abascorte.datareal.
            end.
            tt-abascortes.qtdcorte = tt-abascortes.qtdcorte + abascorteprod.qtdcorte.
            tt-abascortes.qtdpend  = tt-abascortes.qtdpend  + abascorteprod.qtdcorte.


            vconta = 0.
            for each tt-datas.
                delete tt-datas.
            end.    
            
            for each tt-cortes where  
                tt-cortes.etbcod = abastransf.etbcod and 
                tt-cortes.abtcod = abastransf.abtcod and 
                tt-cortes.oper = "NOTA" and  
                tt-cortes.dcbcod = abascorteprod.dcbcod 
                by tt-cortes.datareal
                by tt-cortes.horareal.
                find first tt-datas where
                    tt-datas.data = tt-cortes.datareal
                    no-error.
                if not avail tt-datas
                then do:
                    create tt-datas.
                    tt-datas.data = tt-cortes.datareal.
                end.    
                tt-datas.qtdcarga = tt-datas.qtdcarga + tt-cortes.qtd.
                tt-abascortes.qtdpend = tt-abascortes.qtdpend - tt-cortes.qtd.
                if tt-abascortes.qtdpend < 0 
                then tt-abascortes.qtdpend = 0.
            end.
            vconta = 0.      
            do vdata = tt-abascortes.dtcorte to tt-abascortes.dtcorte + 4.
                vconta = vconta + 1.
                if vconta <= 4
                then do:
                    for each tt-datas where tt-datas.data = vdata.
                        tt-abascortes.dtcarga [vconta] = tt-datas.data.
                        tt-abascortes.qtdcarga[vconta] = tt-abascortes.qtdcarga[vconta] + tt-datas.qtdcarga.
                    end.
                end.
                else do:
                    for each tt-datas where tt-datas.data >= vdata.
                        tt-abascortes.dtcarga [vconta] = vdata.
                        tt-abascortes.qtdcarga[5] = tt-abascortes.qtdcarga[5] + tt-datas.qtdcarga.
                    end.
                end.
            end.     
            
        end.
    end.
        
end.    


        if cvisu <> "EXCEL CSV"
        then do:
            for each tt-abascortes:
                find first btt-abascortes where
                        btt-abascortes.etbcod = 0 and
                    btt-abascortes.procod = 0 and
                    btt-abascortes.dtcorte = tt-abascortes.dtcorte
                 no-error.
                if not avail btt-abascortes
                then do:
                    create btt-abascortes.
                    btt-abascortes.etbcod = 0 .
                    btt-abascortes.procod = 0 .
                    btt-abascortes.dtcorte = tt-abascortes.dtcorte.
                end.
                btt-abascortes.qtdcorte = btt-abascortes.qtdcorte   + tt-abascortes.qtdcorte.
                btt-abascortes.qtdpend  = btt-abascortes.qtdpend    + tt-abascortes.qtdpend.
                btt-abascortes.qtdcarga[1] = btt-abascortes.qtdcarga[1] + tt-abascortes.qtdcarga[1].
                btt-abascortes.qtdcarga[2] = btt-abascortes.qtdcarga[2] + tt-abascortes.qtdcarga[2].
                btt-abascortes.qtdcarga[3] = btt-abascortes.qtdcarga[3] + tt-abascortes.qtdcarga[3].
                btt-abascortes.qtdcarga[4] = btt-abascortes.qtdcarga[4] + tt-abascortes.qtdcarga[4].
                btt-abascortes.qtdcarga[5] = btt-abascortes.qtdcarga[5] + tt-abascortes.qtdcarga[5].
                
                find first btt-abascortes where
                        btt-abascortes.etbcod = 0 and
                    btt-abascortes.procod = 0 and
                    btt-abascortes.dtcorte = 01/01/1980
                 no-error.
                if not avail btt-abascortes
                then do:
                    create btt-abascortes.
                    btt-abascortes.etbcod = 0 .
                    btt-abascortes.procod = 0 .
                    btt-abascortes.dtcorte = 01/01/1980.
                end.
                btt-abascortes.qtdcorte = btt-abascortes.qtdcorte   + tt-abascortes.qtdcorte.
                btt-abascortes.qtdpend  = btt-abascortes.qtdpend    + tt-abascortes.qtdpend.
                btt-abascortes.qtdcarga[1] = btt-abascortes.qtdcarga[1] + tt-abascortes.qtdcarga[1].
                btt-abascortes.qtdcarga[2] = btt-abascortes.qtdcarga[2] + tt-abascortes.qtdcarga[2].
                btt-abascortes.qtdcarga[3] = btt-abascortes.qtdcarga[3] + tt-abascortes.qtdcarga[3].
                btt-abascortes.qtdcarga[4] = btt-abascortes.qtdcarga[4] + tt-abascortes.qtdcarga[4].
                btt-abascortes.qtdcarga[5] = btt-abascortes.qtdcarga[5] + tt-abascortes.qtdcarga[5].
                
                
            end.
       end.
       
/* Relatorio */
pause before-hide.
message "Gerando Relatorio " vvisu[ivisu] today string(time,"HH:MM:SS").

if cvisu = "EXCEL CSV"
then varquivo = vdestino.
else varquivo = "/admcom/relat/rperformance_" +  string(today,"999999") + 
                    replace(string(time,"HH:MM"),":","") + ".txt".

vassunto = "PERFORMANCE DE CORTES " +
           vwms[iwms] + "      ..." + string(vbatch," automatico/") 
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
    
end.
if cvisu = "EXCEL CSV"
then do:


    output to value(varquivo).

        put unformatted skip
            "DT CORTE" vcp
            "LOJA" vcp
            "CODIGO" vcp
            "PRODUTO" vcp
            "QTD PEDIDO" vcp
            "D 0" vcp
            "%%" vcp
            "D+1" vcp
            "%%" vcp
            "D+2" vcp
            "%%" vcp
            "D+3" vcp
            "%%"  vcp
            "D+4 (ou mais)" 
            "%%" vcp.
        
        /**for each tt-abascortes
            break 
                by tt-abascortes.dtcorte
                by tt-abascortes.etbcod
                by tt-abascortes.procod.
            if first-of(tt-abascortes.dtcorte)
            then do:
                vconta = 0.
                do vdata = tt-abascortes.dtcorte to tt-abascortes.dtcorte + 4.
                    vconta = vconta + 1. 
                    if vconta = 5
                    then do:
                        put unformatted "D+4 (OU MAIS)" vcp
                                        "%%"  vcp.
                    end.
                    else do:
                        put unformatted vdata vcp
                                        "%%"  vcp.

                    end.
                end.
            end.
        end.*/
            
        put unformatted    
            "QTD PENDENTE" vcp.
    put unformatted        
             skip.
    
end.

    vvisu = "".
    vvisu[ivisu] = bvisu[ivisu].    
    
if cvisu <> "EXCEL CSV"
then    do:

    def var vqtdcorte   as int.
    vconta = 0.
    vqtdcarga = 0.
    vqtdcorte = 0. 
    for each tt-abascortes where tt-abascortes.etbcod = 0 and tt-abascortes.dtcorte > 01/01/1980.
        vconta = 0.
            vqtdcorte = vqtdcorte + tt-abascortes.qtdcorte.
        
        do vconta = 1 to 5.
            vqtdcarga = vqtdcarga + tt-abascortes.qtdcarga[vconta].
            /*
            vperccarga = vqtdcarga / tt-abascortes.qtdcorte * 100.
            */
        end.
    end.        

    vperccarga = vqtdcarga / vqtdcorte * 100.

    if cvisu = "EMAIL"
    then do:
        put unformatted
            "<PRE>" skip.
    end.
            
    disp vvisu
         with frame f-dados.   
    disp 
        with frame f-dados.

    if cvisu = "EMAIL"
    then do:
        put unformatted
            "</PRE>" skip.
    end.             
    if cvisu = "EMAIL"
    then do:
    
        put unformatted skip 
        "<h2>" "Performance CD " vwms[iwms] "   " vperccarga format ">>9.99%"  "</h2>" skip.
    
        put unformatted
            "<PRE>" skip.
    end.
    else do.
        put unformatted
            skip(2)
            "Performance CD " vwms[iwms] "    " vperccarga format ">>9.99%"
                 skip.
    
    end.

end.
    form
     tt-abascortes.dtcorte column-label "Dt Corte"
         tt-abascortes.etbcod 
         tt-abascortes.qtdcorte column-label "Qtd!Pedido" format ">>>>>9"
         tt-abascortes.qtdcarga[1] column-label "D 0" 
         tt-abascortes.perccarga[1] column-label "%%0"
         tt-abascortes.qtdcarga[2] column-label "D+1"
         tt-abascortes.perccarga[2] column-label "%%1"
         tt-abascortes.qtdcarga[3] column-label "D+2"
         tt-abascortes.perccarga[3] column-label "%%2"
         tt-abascortes.qtdcarga[4] column-label "D+3"
         tt-abascortes.perccarga[4] column-label "%%3"
         tt-abascortes.qtdcarga[5] column-label "D+4 (ou mais)" 
         tt-abascortes.perccarga[5] column-label "%%4+"
         tt-abascortes.qtdpend column-label "Qtd!Pendente" format "->>>>>"
         tt-abascortes.percpend  column-label "%%P"

         with frame fcortes width 200 down.

for each tt-abascortes where
    (if vporloja
     then true
     else tt-abascortes.etbcod = 0)
    break 
        by tt-abascortes.dtcorte 
        by tt-abascortes.etbcod
        by tt-abascortes.procod
    on error undo, return        
    with frame fcortes
        width 200.

  
    if cvisu <> "EXCEL CSV"
    then    do:

        /*disp  tt-abascortes.dtcorte.*/
        
        if vporloja = no or
           tt-abascortes.dtcorte = 01/01/1980 
        then do:
            if tt-abascortes.dtcorte = 01/01/1980
            then disp "TOTAL" @ tt-abascortes.dtcorte.
            else disp tt-abascortes.dtcorte.
        end.    
        else do:
            if first-of(tt-abascortes.dtcorte)
            then do:
                
                if not first(tt-abascortes.dtcorte)
                then down 1.
        
                /*disp tt-abascortes.dtcorte.
                */
                vconta = 0.
                do vdata = tt-abascortes.dtcorte to tt-abascortes.dtcorte + 4.
                    vconta = vconta + 1. 
                    disp vdata @ tt-abascortes.qtdcarga[vconta].
                end.
                
                down.
                
            end.
        end.      
    end.      
    vconta = 0.
    vqtdcarga = 0.
    do vconta = 1 to 5.
        vqtdcarga = vqtdcarga + tt-abascortes.qtdcarga[vconta].
        tt-abascortes.perccarga[vconta] = vqtdcarga / tt-abascortes.qtdcorte * 100.
    end.
    tt-abascortes.percpend = tt-abascortes.qtdpend / tt-abascortes.qtdcorte * 100.

    if cvisu <> "EXCEL CSV"
    then    do:
    
        disp tt-abascortes.dtcorte when first-of(tt-abascortes.dtcorte) and
                                        tt-abascortes.dtcorte <> 01/01/1980
            (if tt-abascortes.etbcod <> 0
             then string(tt-abascortes.etbcod,">>9")
             else if tt-abascortes.dtcorte = 01/01/1980 or vporloja = no
                  then "  "
                  else "TOT") @ tt-abascortes.etbcod
                /*             tt-abascortes.etbcod    when tt-abascortes.etbcod <> 0*/
             /*tt-abascortes.procod*/
             tt-abascortes.qtdcorte
             tt-abascortes.qtdpend
             tt-abascortes.qtdcarga[1]  when tt-abascortes.qtdcarga[1] <> 0
             tt-abascortes.perccarga[1] when tt-abascortes.qtdcarga[1] <> 0
             tt-abascortes.qtdcarga[2]  when tt-abascortes.qtdcarga[2] <> 0
             tt-abascortes.perccarga[2] when tt-abascortes.qtdcarga[2] <> 0
             tt-abascortes.qtdcarga[3]  when tt-abascortes.qtdcarga[3] <> 0
             tt-abascortes.perccarga[3] when tt-abascortes.qtdcarga[3] <> 0
             tt-abascortes.qtdcarga[4]  when tt-abascortes.qtdcarga[4] <> 0
             tt-abascortes.perccarga[4] when tt-abascortes.qtdcarga[4] <> 0
             tt-abascortes.qtdcarga[5]  when tt-abascortes.qtdcarga[5] <> 0
             tt-abascortes.perccarga[5] when tt-abascortes.qtdcarga[5] <> 0
             tt-abascortes.percpend when tt-abascortes.qtdpend <> 0.
             
        if tt-abascortes.etbcod = 0 and vporloja
        then down 1.
        else if tt-abascortes.dtcorte = 01/01/1980
             then down 2.
             else down.    
    end.
    else do:
     
        find produ where produ.procod = tt-abascortes.procod no-lock.

        put unformatted
            tt-abascortes.dtcorte   vcp
             tt-abascortes.etbcod   vcp
             tt-abascortes.procod   vcp
             produ.pronom           vcp
             tt-abascortes.qtdcorte vcp
             tt-abascortes.qtdcarga[1]  vcp
             tt-abascortes.perccarga[1] vcp
             tt-abascortes.qtdcarga[2]  vcp
             tt-abascortes.perccarga[2] vcp
             tt-abascortes.qtdcarga[3]  vcp
             tt-abascortes.perccarga[3] vcp
             tt-abascortes.qtdcarga[4]  vcp
             tt-abascortes.perccarga[4] vcp
             tt-abascortes.qtdcarga[5]  vcp
             tt-abascortes.perccarga[5] vcp
             tt-abascortes.qtdpend vcp
             tt-abascortes.percpend vcp
             skip.
    
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
    


do on endkey undo, retry:
    hide message no-pause.
    message "Gerado Relatorio em " vvisu[ivisu] vdestino.
    if vbatch = no
    then pause.
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
     

