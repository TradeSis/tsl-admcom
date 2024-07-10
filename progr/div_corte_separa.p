/***
#1 TP 24120378 - 10.04.18
***/

{admcab.i}

def var vvisu as log format "Impressora/Tela".
def var recimp   as   recid.
def var varquivo as   char.
def var fila     as   char.
def var vetbcod like estab.etbcod.
def var vdata1 as date format "99/99/9999" init today.
def var vdata2 as date format "99/99/9999" init today.
def var vdata as date format "99/99/9999".
def var vqtdcont as int.

def temp-table tt-tar
    field procod like produ.procod format ">>>>>>>>>9"
    field pronom like produ.pronom
    field numero as int
    field movsep as dec
    field movqtm as dec
    field vencod as int
    field endpav as int
    field pladat as date
    field desti  as int
    field dtconfirma as char
    field hrconfirma as char
    field dtcarga    as char
    field hrcarga    as char.

def var vmovhr as char.
def var vdtcon as date.

repeat:
    for each tt-tar:
        delete tt-tar.
    end.
    
    update vdata1 label "Data Inicial........"
           vdata2 label "Data Final"
           skip
           with frame f-dados.

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

    vvisu = no.
    update skip vvisu     label "Visualizacao........"
           help " [I] Impressora [T] Tela "
           with frame f-dados width 80 side-labels overlay.
    
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
            then
            assign fila = string(impress.dfimp). 
        end.    
        end.
    end.
    else assign fila = "". 

    sresp = yes.
    message "Somente dvergencias?" update sresp.
    
    do vdata = vdata1 to vdata2:
    
        disp vdata with frame f-cont row 10
                      centered no-label 1 down. pause 0.
 
        for each tdocbase where tdocbase.tdcbcod = "ROM" 
                            and tdocbase.dtenv = vdata
                            and tdocbase.dtrettar <> ?
                          no-lock.
           if vetbcod > 0 and
               vetbcod <> tdocbase.etbdes
           then next.   

           for each tdocbpro of tdocbase no-lock:
                find produ where produ.procod = tdocbpro.procod 
                            no-lock no-error.
                if not avail produ then next.
                
                assign 
                    vmovhr = ? 
                    vdtcon = ?
                    vqtdcont = 0.
                
                if tdocbpro.qtdcont = 0 and
                   tdocbase.plani-placod <> ? and
                   tdocbase.plani-placod <> 0
                then do:
             
                    find first movim where
                              movim.etbcod = tdocbase.plani-etbcod and
                              movim.placod = tdocbase.plani-placod and
                              movim.movtdc = 6 and
                              movim.procod = produ.procod and
                              movim.desti  = tdocbase.etbdes
                             no-lock no-error.
                    if avail movim 
                    then do:
                        if movim.movqtm <= tdocbpro.movqtm 
                        then vqtdcont = movim.movqtm.
                        else do:
                            vqtdcont = tdocbpro.movqtm.
                            /*if tdocbpro.qtdcont = 0
                            then vqtdcont = movim.movqtm.
                            */
                        end.    
                        vmovhr = string(movim.movhr,"hh:mm:ss").
                        vdtcon = movim.movdat.
                    end.
                    else do:
                        vqtdcont = 0.

                    end.
                end.
                else do:
                    if tdocbpro.qtdcont > 0
                    then assign
                            vqtdcont = tdocbpro.qtdcont
                            vdtcon   = tdocbase.dtrettar
                            vmovhr = acha("HORARETORNOCONFIRMAWMS",
                            tdocbase.campo_char2)
                            .    
                end.        
                if tdocbpro.movqtm = vqtdcont 
                    and sresp
                then next.

                do:
                    create tt-tar.
                    assign tt-tar.procod = produ.procod
                       tt-tar.pronom = produ.pronom
                       tt-tar.numero = tdocbpro.dcbcod
                       tt-tar.movsep = vqtdcont
                       tt-tar.movqtm = tdocbpro.movqtm
                       tt-tar.endpav = tdocbpro.endpav 
                       tt-tar.pladat = tdocbase.dtenv
                       tt-tar.desti  = tdocbase.etbdes
                       tt-tar.dtconfirma = string(vdtcon)
                       tt-tar.hrconfirma = vmovhr
                       .
                end.
           end.
        end.
    end.
    hide frame f-cont no-pause.
    
    varquivo = "/admcom/relat/div_corte_separa." + string(time).

    {mdadmcab.i &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""div_corte_separa"" 
                &Nom-Sis   = """WMS """ 
                &Tit-Rel   = """RELATORIO DE FALTA DE PRODUTOS"""
                &Width     = "100" 
                &Form      = "frame f-cabcab"}
    
    disp with frame f-dados.
    
    for each tt-tar break by tt-tar.pronom:

        disp
             tt-tar.procod  column-label "Produto" format ">>>>>>>>9"
             tt-tar.pronom  column-label "Descricao" format "x(25)"
             tt-tar.numero  column-label "Numero!Corte" format ">>>>>>9"
             tt-tar.pladat  column-label "Data!Corte" format "99/99/9999"
             tt-tar.desti   column-label "Desti" format ">>>9"
             tt-tar.movqtm  column-label "Quant!Separar"  format ">>>>>9"
             tt-tar.movsep  column-label "Quant!Separada" format ">>>>>9"
             tt-tar.dtconfirma  column-label "Data!Confirma"
             tt-tar.hrconfirma  column-label "Hora!Confirma"
             if tt-tar.movqtm > tt-tar.movsep then "*" else ""
             with frame f-p width 150 down.
    end.
    
    output close.
    
    if opsys = "unix"
    then do:

        if vvisu
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p (input varquivo, input "").
        
    end. 
end.

