{admcab.i}

def var vvisu as log format "Impressora/Tela".
def var recimp   as   recid.
def var varquivo as   char.
def var fila     as   char.

def var vopecod like wmsoper.opecod.

def var vendpavf-l as log format "Sim/Nao".
def var vendpavf like wmsplani.endpav.
def var vetbcod like estab.etbcod.
def var vdata1 as date format "99/99/9999" init today.
def var vdata2 as date format "99/99/9999" init today.
def var vdata as date format "99/99/9999".

def temp-table tt-tar
    field procod like wmsmovim.procod format ">>>>>>>>>9"
    field pronom like produ.pronom
    field numero like wmsplani.numero
    field movsep like wmsmovim.movsep
    field movqtm like wmsmovim.movqtm
    field vencod like wmsplani.vencod
    field endpav like wmsplani.endpav
    field pladat like wmsplani.pladat
    field desti  like wmsplani.desti.
    

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

    update skip
           vopecod    label "Operador............"
           with frame f-dados.
           
    update skip
           vendpavf-l label "Filtrar por Pavilhao"
           with frame f-dados width 80 side-labels overlay. 

    if vendpavf-l
    then update vendpavf   no-label
                with frame f-dados.

    vvisu = no.
    update skip vvisu     label "Visualizacao........"
           help " [I] Impressora [T] Tela "
           with frame f-dados.
    
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
            assign fila = string(impress.dfimp). 
        end.    
        end.
    end.
    else assign fila = "". 
    
    do vdata = vdata1 to vdata2:
    
      disp vdata with frame f-cont row 10
                      centered no-label 1 down. pause 0.
      
      for each wmsplani where wmsplani.movtdc  = 1  
                          and (wmsplani.etbcod = 993 or wmsplani.etbcod  = 900)
                          and wmsplani.pladat  = vdata /*
                          and wmsplani.plasit  = "F" 
                          and wmsplani.desti   = (if vetbcod <> 0
                                                  then vetbcod
                                                  else wmsplani.desti)
                          and wmsplani.endpav  = (if vendpavf-l
                                                  then vendpavf
                                                  else wmsplani.endpav)*/
                          no-lock:
                    
        if wmsplani.plasit <> "F"
        then next.
    
        if vopecod <> 0
        then 
            if wmsplani.vencod <> vopecod 
            then next.
            
        if vetbcod <> 0
        then
            if wmsplani.desti <> vetbcod
            then next.
                                    
        if vendpavf-l
        then
            if wmsplani.endpav <> vendpavf 
            then next.            

        if wmsplani.desti = 0
        then next.

        for each wmsmovim of wmsplani no-lock:
    
            if wmsmovim.movsep > wmsmovim.movqtm
            then do:
        
                find produ where 
                     produ.procod = wmsmovim.procod no-lock no-error. 

                create tt-tar.
                assign tt-tar.procod = wmsmovim.procod
                       tt-tar.pronom = produ.pronom
                       tt-tar.numero = wmsplani.numero
                       tt-tar.movsep = wmsmovim.movsep 
                       tt-tar.movqtm = wmsmovim.movqtm 
                       tt-tar.vencod = wmsplani.vencod 
                       tt-tar.endpav = wmsplani.endpav 
                       tt-tar.pladat = wmsplani.pladat 
                       tt-tar.desti  = wmsplani.desti.
                
            end.

        end.

      end.
    end.
    
    hide frame f-cont no-pause.
    
    varquivo = "/admcom/relat/rfalpro1." + string(time).

    {mdadmcab.i &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "100" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rfalpro1"" 
                &Nom-Sis   = """WMS """ 
                &Tit-Rel   = """RELATORIO DE FALTA DE PRODUTOS"""
                &Width     = "100" 
                &Form      = "frame f-cabcab"}

    
    for each tt-tar break by tt-tar.pronom:

        find wmsoper where wmsoper.opecod = tt-tar.vencod no-lock no-error.
            
        disp
             tt-tar.procod  column-label "Produto" format ">>>>>>>>9"
             tt-tar.pronom  column-label "Descricao" format "x(31)"
             tt-tar.numero  column-label "Numero!Tarefa" format ">>>>>>>9"
             tt-tar.pladat  column-label "Data" format "99/99/9999"
             tt-tar.endpav  column-label "Pav" format ">>9"
             tt-tar.desti   column-label "Loja!Desti" format ">>>9"
             tt-tar.movsep  column-label "Pedido" format ">>>>>9"
             tt-tar.movqtm  column-label "Entregue" format ">>>>>9"
             wmsoper.openom column-label "Operador" format "x(10)"
             with frame f-p width 100 down.
             
    end.
    
    output close.
    
    if opsys = "unix"
    then do:

        if vvisu
        then os-command silent lpr value(fila + " " + varquivo).
        else run visurel.p (input varquivo, input "").
        
    end.        
    
    
    
end.    
