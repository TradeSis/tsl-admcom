{admcab.i}
def input parameter par-wms as char.
def input parameter par-title as char.

def var vabtqtd     like abastransf.abtqtd format ">>>9".
def shared temp-table tt-abastransf no-undo
    field box           like tab_box.box
    field dttransf      like abastransf.dttransf
    field abatpri       like abastipo.abatpri
    field dtinclu       like abastransf.dtinclu
    field hrinclu       like abastransf.hrinclu
    field etbcod        like abastransf.etbcod    
    field abtcod        like abastransf.abtcod
    field rec    as recid
    index chave is unique primary 
            dttransf asc 
            abatpri asc 
            dtinclu asc
            hrinclu asc
            abtcod asc
            etbcod asc.

def var vcp as char init ";".

def var bvisu as char extent 3 format "x(12)" init ["  Tela","  Email","Impressora"].
def var vvisu as char extent 3 format "x(12)" init ["  Tela","  Email","Impressora"].
def var ivisu as int.
def var cvisu as char.

    def var varqmail as char.
    def var vassunto as char.
    def var varquivo as char.
    def var vdestino as char format "x(50)".
def var vqtdcortes as int.
def var vhrcorte    as char format "x(05)".
def var vhrconf     as char format "x(05)".



    pause 0.    
    disp skip " "
        par-wms format "x(40)" no-label
        skip
        with frame f-dados.
    
    disp
        par-title  no-label format "x(78)" skip(2)
        "Tipo de Relatorio...: "
           with frame f-dados  width 80  side-labels overlay
           row 5.
        
    vvisu[1] = bvisu[1].
    vvisu[2] = bvisu[2].
    vvisu[3] = bvisu[3].

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
     skip(2)
               with frame f-dados.
   
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

/* Relatorio */
pause before-hide.
hide message no-pause.
message "Gerando Relatorio " vvisu[ivisu].

varquivo = "/admcom/relat/rpedidos_" +  string(today,"999999") + 
                    replace(string(time,"HH:MM"),":","") + ".txt".

vassunto = "LISTAGEM DE PEDIDOS".

if cvisu = "TELA" or
   cvisu = "Impressora"
then do:
    {mdadmcab.i &Saida     = "value(varquivo)" 
                &Page-Size = "64" 
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""rimp1"" 
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
    /*break 
        by tt-abastransf.etbcod
        by tt-abastransf.dttransf
        by tt-abastransf.abtcod
        */
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

    

   find abastransf where recid(abastransf) = tt-abastransf.rec no-lock.
   find produ of abastransf no-lock.
   find abastipo of abastransf no-lock no-error.


                if abastransf.abtsit = "EL" or 
                   abastransf.abtsit = "CA" or
                   abastransf.abtsit = "NE" 
                then vabtqtd = abastransf.abtqtd.
                else vabtqtd = abastransf.abtqtd - abastransf.qtdatend.

   
   display 
        abastransf.abtcod column-label "Pedido"
        abastransf.dttransf  format "99/99/9999" column-label "Data"
        abastipo.abatpri when avail abastipo
        abastransf.abatipo
        (if abastransf.pedexterno <> ? or not avail abastipo
         then if num-entries(abastransf.pedexterno,"_") > 1
              then entry(1,abastransf.pedexterno,"_")
              else abastransf.pedexterno
         else abastipo.abatnom)  @ abastipo.abatnom format "x(10)" column-label "Tipo/Numero"
        tt-abastransf.box column-label "Box"
        abastransf.etbcod
        abastransf.procod
        produ.pronom format "x(32)" column-label ""
        vabtqtd format ">>>9" (total count)

        abastransf.abtsit.
        
        
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

if cvisu <> "impressora" and cvisu <> "tela" 
then do on endkey undo, retry:
    hide message no-pause.
    message "Gerado Relatorio em " vvisu[ivisu] vdestino.
    pause.
end.

return.
     

