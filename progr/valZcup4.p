{admcab.i new}

def input parameter vetbcod like estab.etbcod.
def input parameter vdti as date.
def input parameter vcxacod as int.

def var voq as char extent 2 format "x(15)"
    init["  CUPOM ","  RED Z "].
    
def temp-table tt-linha
    field linha as char.

def temp-table tt-dados
    field numero-adm as int
    field coo-adm    as char
    field valor-adm as dec
    field numero-ecf as int
    field coo-ecf    as char
    field valor-ecf as dec
    field clfcod as int    .

def temp-table tt-redz
    field equipa as int
    field versao as char
    field nserie as char
    field dmovim as date
    field dreduc as date
    field datual as date
    field nreduc as int
    field val_17 as dec
    field val_12 as dec
    field val_07 as dec
    field val_st as dec
    field valise as dec
    field valacr as dec
    field valdes as dec
    field cancel as dec
    field sangri as dec
    field suprim as dec
    field valliq as dec
    field valbru as dec
    field gtotal as dec
    field coofin as char
    field cooini as char
    field nrocan as char
    .

def var valor as char   .
    
def new shared temp-table wf-plani like plani.
def new shared temp-table wf-movim like movim.

def var varqmfd as char.
def var varqret as char.
def var vini as char.
def var vfin as char.

def var vdtf as date.

do on error undo:
    disp vetbcod with frame f1 with width 80 1 down side-label.
    find estab where estab.etbcod = vetbcod no-lock .
    
    disp estab.etbnom no-label with frame f1.
    
    disp vdti AT 1 label "DATA" format "99/99/9999"
           WITH FRAME F1.
    VDTF = VDTI.
    if vdti = ? or
       vdtf = ? or
       vdti > vdtf
    then do:
       bell.
       message color red/with
       "Period invalido."
       view-as alert-box.
       undo. 
    end.
    disp vcxacod label "ECF"
      with frame f1.
end.                   

def var vindex as int.

disp voq with frame f-oq no-label.
choose field voq with frame f-oq.

vindex = frame-index.

def var varq as char format "x(50)".
def var varql as char format "x(50)".
if vindex = 1
then assign
        varq = "bemamfd" + string(vcxacod,"99") +
            string(day(vdti),"99") +
            string(month(vdti),"99") +
            substr(string(year(vdti),"9999"),3,2) + ".txt"
        varql = "bemamfd" + string(vetbcod,"999") + string(vcxacod,"99") +
            string(day(vdti),"99") +
            string(month(vdti),"99") +
            substr(string(year(vdti),"9999"),3,2) + ".txt"
            .

else assign
        varq = "bemamfd" + "_" + string(vcxacod,"99") + 
            string(month(vdti),"99") +
            substr(string(year(vdti),"9999"),3,2) + ".txt"
        varql = "bemamfd" + "_" + string(vetbcod,"999") + 
            string(vcxacod,"99") + 
            string(month(vdti),"99") +
            substr(string(year(vdti),"9999"),3,2) + ".txt"

            .
     
            
disp varq label "Arquivo" with side-label
width 80.

if varq = "" then undo.
def var vbuscar as log format "Sim/Nao".
vbuscar = no.
message "Buscar arquivo na filial?" update vbuscar.

assign
    varqmfd = varql + ".mfd"
    varqret = varql 
    vini = string(day(vdti),"99") + 
           string(month(vdti),"99") +
           substr(string(year(vdti),"9999"),3,2)
    vfin = string(day(vdtf),"99") + 
           string(month(vdtf),"99") +
           substr(string(year(vdtf),"9999"),3,2)
           .


if vbuscar
then do:

 
    unix  value("scp root@filial" + string(vetbcod,"999") +
        ":/usr/admcom/ecfinfo/" + varq + " /admcom/ecfinfo/" + varql +
        " ; exit").
        
end.

if search("/admcom/ecfinfo/" + varqret) <> ?
then do:
    input from value("/admcom/ecfinfo/" + varqret).
    repeat:
        create tt-linha.
        import unformatted tt-linha.
    end.
    input close.
end.
else return.

def var vcnpj as char.
def var vie as char.
def var vdata as date.
def var vhora as char.
def var vcoo as char.
def var vprocod like produ.procod.
def var vmovqtm like movim.movqtm.
def var vmovpc  like movim.movpc.
def var vmovalicms like movim.movalicms.
def var vcharicms as char. 
def var vcharmovpc as char.
def var vnumero like plani.numero.
def var vvencod like plani.vencod.
def var vnrofab as char.
def var vchartotal as char.
def var vtotal as dec.
def var qt-linha as int.
def var dt-linha as int.
def var it-linha as int.
def var qt-item as int.
def var ad-linha as int.
def var vclinom as char.
def var vcgccpf as char.
def var vtipo as char.
def var l-coo as int.

def var vini-l as char.
def var vval-i as char. 

def var v-ti as char.
def var v-qi as char.
def var v-vi as char.

if vindex = 1
then do:
for each tt-linha.

    if trim(linha) = "CUPOM FISCAL"
    THEN vtipo = "CUPOM FISCAL".

    l-coo = l-coo + 1.
    
    
    if substr(string(linha),1,4) = "CNPJ"
    then vcnpj = entry(2,linha,":").
    else if substr(string(linha),1,2) = "IE" 
    then assign
            vie = entry(2,linha,":")
            l-coo = 0.
    else if l-coo = 2 and 
            (substr(string(linha),1,1) = "0" or
             substr(string(linha),1,1) = "1" or
             substr(string(linha),1,1) = "2" or
             substr(string(linha),1,1) = "3") 
    then  do:
        assign
             vdata = date(substr(string(linha),1,10))
             vhora = substr(string(linha),12,8)
             vcoo  = if num-entries(linha,":") = 5
                    then entry(5,linha,":")  
                    else if num-entries(linha,":") = 4
                    then entry(4,linha,":") else ""
             .
    end.

    if vtipo = "CUPOM FISCAL" and
       substr(string(trim(linha)),1,1) <> "-"
    then do:
    
        qt-linha = qt-linha + 1.
        if substr(string(linha),1,5) = "ERIAL" or
           substr(string(linha),1,2) = "AL"
        then ad-linha = qt-linha + 1.
        else do:
            vini-l = trim(substr(string(linha),1,4)).
            vini-l = replace(vini-l," ","").
            
        if /*length(trim(substr(string(linha),1,4))) = 3 and*/
           length(trim(vini-l)) = 3 and
           ( substr(string(linha),3,1) = "0" or
             substr(string(linha),3,1) = "1" or
             substr(string(linha),3,1) = "2" or
             substr(string(linha),3,1) = "3" or
             substr(string(linha),3,1) = "4" or
             substr(string(linha),3,1) = "5" or
             substr(string(linha),3,1) = "6" or
             substr(string(linha),3,1) = "7" or
             substr(string(linha),3,1) = "8" or
             substr(string(linha),3,1) = "9")
        then do:     

            assign
                it-linha = qt-linha 
                qt-item  = 1.

            
            if int(length(linha)) = 48
            then do:
                assign
                    qt-item = int(substr(string(linha),1,3))
                    vprocod = int(substr(string(linha),5,13))
                    ad-linha = qt-linha + 1.
            end.
            else do:
                if linha matches "*%*"
                then do:
                    assign
                        qt-item = int(substr(string(linha),1,3))
                        vprocod = int(substr(string(linha),5,13))
                        vcharicms = substr(string(entry(1,linha,"%")
                            ),length(string(entry(1,linha,"%"))) - 8,10)
                        .
                     assign       
                        vmovqtm = dec(substr(string(vcharicms),1,2))
                        vcharicms = replace(vcharicms,",",".")
                        vmovalicms = dec(entry(2,vcharicms,"T"))    
                        vcharmovpc = entry(2,linha,"%")
                        vcharmovpc = replace(vcharmovpc,".",":")
                        vcharmovpc = replace(vcharmovpc,",",".")
                        vcharmovpc = replace(vcharmovpc,":",".")
                        vcharmovpc = replace(vcharmovpc,"G","")
                        vmovpc = dec(substr(string(vcharmovpc,"x(20)"),1,19))
                        ad-linha = qt-linha + 1
                        .
                end.
                else do:
                    if substr(string(linha),2,1) = ""
                    then assign
                        qt-item = int(substr(string(linha),1,1))
                        vprocod = int(substr(string(linha),3,13))
                        .
                    
                    else if substr(string(linha),3,1) = ""
                    then assign
                        qt-item = int(substr(string(linha),1,2))
                        vprocod = int(substr(string(linha),4,13))
                        .
                    else assign
                        qt-item = int(substr(string(linha),1,3))
                        vprocod = int(substr(string(linha),5,13))
                        .
                
                    vval-i = substr(string(linha),
                        length(linha) - 30,30).
                    vval-i = replace(vval-i," ",";").
                    
                    run val-i.

                    assign
                        vcharicms = v-ti
                        vmovqtm = dec(v-qi)
                        vcharmovpc = v-vi
                        .
                        
                    if vcharicms = "T1"
                    then vmovalicms = 17.
                    else vmovalicms = 0.
                    
                    assign    
                        /*
                        vmovqtm = dec(substr(string(vcharicms),1,2))
                            /*vcharicms = replace(vcharicms,",",".")*/
                        vmovalicms = 0 /*dec(entry(2,vcharicms,"T"))*/    
                        vcharmovpc = entry(2,linha,"F1")
                        */
                        
                        vcharmovpc = replace(vcharmovpc,".",":")
                        vcharmovpc = replace(vcharmovpc,",",".")
                        vcharmovpc = replace(vcharmovpc,":",".")
                        vcharmovpc = replace(vcharmovpc,"G","")
                        vmovpc = dec(vcharmovpc)
                           /*dec(substr(string(vcharmovpc,"x(14)"),2,12))*/
                            ad-linha = qt-linha + 1
                        . 
                end.
                run cria-movim.
        
                qt-item = qt-item + 1.
            end. 
        end. 
        else if qt-linha = ad-linha and
            substr(string(linha),1,7) <> "TOTAL R" and
            substr(string(linha),1,7) <> "TOTAL  " and
            substr(string(linha),1,7) <> "TOTAL I"
        then do:
            if linha matches "*%*"
            then do:
            assign    
                vcharicms = substr(string(entry(1,linha,"X")
                    ),length(string(entry(1,linha,"X"))) - 3,3)
                vcharicms = replace(vcharicms,"UN","")
                vmovqtm = dec(substr(string(vcharicms),1,3))
                vcharicms = substr(string(entry(1,linha,"%")
                    ),length(string(entry(1,linha,"%"))) - 8,10)
                vcharicms = replace(vcharicms,",",".")
                vmovalicms = dec(entry(2,vcharicms,"T"))    
                vcharmovpc = entry(2,linha,"%")
                vcharmovpc = replace(vcharmovpc,".",":")
                vcharmovpc = replace(vcharmovpc,",",".")
                vcharmovpc = replace(vcharmovpc,":",".")
                vcharmovpc = replace(vcharmovpc,"G","")
                vmovpc = dec(substr(string(vcharmovpc,"x(17)"),1,16))
                ad-linha = 0
                .
            end.
            else do:

                if substr(string(linha),1,1) <> ""
                then do:
                    if substr(string(linha),2,1) = ""
                    then assign
                        qt-item = int(substr(string(linha),1,1))
                        vprocod = int(substr(string(linha),3,13))
                        .
                    
                    else if substr(string(linha),3,1) = ""
                    then assign
                        qt-item = int(substr(string(linha),1,2))
                        vprocod = int(substr(string(linha),4,13))
                        .
                    else assign
                        qt-item = int(substr(string(linha),1,3))
                        vprocod = int(substr(string(linha),5,13))
                        .
                end.        
                
                if num-entries(linha,"F1") = 2 
                then
                        vcharicms = substr(string(entry(1,linha,"F1")
                            ),length(string(entry(1,linha,"F1"))) - 2,2)
                        .
                else if num-entries(linha,"T1") = 2 
                then 
                        vcharicms = substr(string(entry(1,linha,"T1")
                           ),length(string(entry(1,linha,"T1"))) - 2,2)
                           .
                
                else if num-entries(linha,"X") = 2
                then assign
                    vcharicms = substr(string(entry(1,linha,"X")
                     ),length(string(entry(1,linha,"X"))) - 3,3)
                    vcharicms = replace(vcharicms,"UN","")
                          .
                
                assign
                    vmovqtm = dec(substr(string(vcharicms),1,3))
                    vmovalicms = 0 /*dec(entry(2,vcharicms,"T"))*/    
                    vcharmovpc = entry(2,linha,"F1")
                    vcharmovpc = replace(vcharmovpc,".",":")
                    vcharmovpc = replace(vcharmovpc,",",".")
                    vcharmovpc = replace(vcharmovpc,":",".")
                    vcharmovpc = replace(vcharmovpc,"G","")
                    vmovpc = dec(substr(string(vcharmovpc,"x(20)"),4,16))
                    ad-linha = 0
                    .
            end.        
            run cria-movim.
            qt-item = qt-item + 1.

        end. 
        else if substr(string(linha),1,4) = "Nro:" 
        then do:
            run val-numero(input linha).
            assign
                /*vnumero = int(substr(string(entry(2,linha,":")),1,8))
                */
                vvencod = 0 /*if substr(string(entry(5,linha,":")),1,4) = " ???"
                          then 0 
                          else int(substr(string(entry(5,linha,":")),1,4))*/
                vcxacod = int(entry(6,linha,":"))
                .
            run cria-plani.
            vtipo = "".   
            qt-linha = 0. 
        end.
        else if substr(string(linha),1,4) = "FAB:" 
        then vnrofab = substr(string(linha),5,25).
        else if substr(string(linha),1,7) = "TOTAL R" or
                substr(string(linha),1,7) = "TOTAL  "
        then do:
            
            if num-entries(linha,"$") = 2
            then vchartotal = entry(2,linha,"$") .
            else  vchartotal = entry(3,linha,"$") .
                
            assign
                vchartotal = replace(vchartotal,".",":")
                vchartotal = replace(vchartotal,",",".")
                vchartotal = replace(vchartotal,".",",")
                vchartotal = replace(vchartotal,":","")
                .
              
                vtotal = dec(vchartotal)
                .
        end. 
        else if substr(string(linha),1,7) = "Cliente"
        then vclinom = substr(string(linha),10,40).
        else if substr(string(linha),1,7) = "CGC/CPF"
        then  vcgccpf = substr(string(linha),10,15).
        end.
    end.
    else do:
        if linha begins 
            "-------------CUPOM FISCAL CANCELADO"
        then do:
            vnumero = int(vcoo).
            run cria-plani.
            qt-linha = 0.
            vtipo = "".
            if avail wf-plani
            then do:
                assign
                    wf-plani.movtdc = 45
                    wf-plani.serie  = "V1".

                for each wf-movim where
                         wf-movim.etbcod = wf-plani.etbcod and
                         wf-movim.placod = wf-plani.placod
                         :
                    wf-movim.movtdc = 45.
                end.     

            end.
        end.
    end.
    if substr(string(linha),1,4) = "FAB:" and
        vnrofab = ""
    then do:    
        vnrofab = substr(string(linha),5,25).
        find first wf-plani no-error.
        if avail wf-plani
        then wf-plani.ufemi = vnrofab.
    end.
end.
/***
sresp = yes.
message "cupom cancelado?" update sresp.
if sresp
then for each wf-plani where wf-plani.movtdc <> 45:
    delete wf-plani.
end.
**/
find first wf-plani no-error.
if not avail plani then return.
    
def new shared var vlog as char.
vlog = "recddecf.log".
def var p-ok as log.

def var vred as log.
    
{setbrw.i}

a-seeid = -1.
a-recid = -1.
a-seerec = ?.


l1: repeat:

    {sklcls.i
    &file = wf-plani
    &cfield = wf-plani.numero
    &noncharacter = /*
    &ofield = "
       wf-plani.numero format "">>>>>>>>9""
       wf-plani.notped format ""x(15)""
       wf-plani.platot
       wf-plani.movtdc format "">>9""
       wf-plani.serie
       wf-plani.placod format "">>>>>>>>>9""
        ""*"" when avail plani
        "
    &aftfnd1 = "
        find first plani where plani.movtdc = wf-plani.movtdc and
                           plani.etbcod = wf-plani.etbcod and
                           plani.numero = wf-plani.numero and
                           plani.serie  = wf-plani.serie
                           no-lock no-error.
            "
    &where = true
    &aftselect1 = "
        for each wf-movim where
                 wf-movim.etbcod = wf-plani.etbcod and
                 wf-movim.placod = wf-plani.placod and
                 wf-movim.movtdc = wf-plani.movtdc
                 no-lock.
                 disp wf-movim.procod wf-movim.movpc
                 with frame f-1.
        end.  
        do: next l1. end.
        "       
    &otherkeys1 = "
        if keyfunction(lastkey) = ""GO""
        then do:
            leave keys-loop.
        end.
        "
    &form  = " frame f-linha down "
    }
    if keyfunction(lastkey) = "END-ERROR"
    then leave l1.
    if keyfunction(lastkey) = "GO"
    then do:
        SRESP = NO.
        message "Confirma gravar ?" UPDATE SRESP.
        IF SRESP
        THEN DO:
            run recddecf-grava.p .
        END.
    end.
end.    
end.
else do:
    do vdata = vdti to vdtf:
    vred = no.
    create tt-redz.
    assign 
           tt-redz.equipa = vcxacod
           tt-redz.dmovim = vdata
           tt-redz.dreduc = vdata
           tt-redz.datual = vdata
           .
    for each tt-linha.
        if vred = no  and
           substr(string(linha),1,10) = string(vdata,"99/99/9999") and
           num-entries(linha,":") = 4
        then do:
            tt-redz.coofin = string(int(entry(4,linha,":")) - 1,"999999").
        end.
        if linha = "MOVIMENTO DO DIA: " + string(vdata,"99/99/9999")
        then vred = yes.
        if vred = yes
        then do:
            if entry(1,linha,":") = "Contador de Reduções Z"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.nreduc = dec(valor).
            end.
            if entry(1,linha,":") = "TOTALIZADOR GERAL"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.gtotal = dec(valor).
            end.
            else if entry(1,linha,":") = "VENDA BRUTA DIÁRIA"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.valbru = dec(valor).
            end.
            else if entry(1,linha,":") = "Cupom Fiscal Cancelado"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.nrocan = valor.
            end.
            else if entry(1,linha,":") = "CANCELAMENTO ICMS"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.cancel = dec(valor).
            end.
            else if entry(1,linha,":") = "DESCONTO ICMS"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.valdes = dec(valor).
            end.
            else if entry(1,linha,":") = "VENDA LÍQUIDA"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.valliq = dec(valor).
            end.
            else if entry(1,linha,":") = "ACRÉSCIMO ICMS"
            then do:
                valor = entry(2,linha,":").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.valacr = dec(valor).
            end.
            else if entry(1,linha,"%") = "T17,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_17 = dec(valor).
            end.
            else if entry(1,linha,"%") = "01T17,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_17 = dec(valor).
            end.
            else if entry(1,linha,"%") = "T12,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_12 = dec(valor).
            end.
            else if entry(1,linha,"%") = "02T12,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_12 = dec(valor).
            end.
            else if entry(1,linha,"%") = "T07,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_07 = dec(valor).
            end.
            else if entry(1,linha,"%") = "03T07,00"
            then do:
                valor = trim(entry(2,linha,"%")).
                valor = entry(1,valor,"").
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_07 = dec(valor).
            end.
            else if entry(1,linha,"=") = "F1"
            then do:
                valor = trim(entry(2,linha,"=")).
                valor = replace(valor,".","").
                valor = replace(valor,",",".").
                tt-redz.val_st = dec(valor).
            end.
            else if entry(1,linha,":") = "VERSÃO"
            then do:
                valor = substr(string(trim(entry(2,linha,":"))),1,9).
                valor = replace(valor,".","").
                tt-redz.versao = valor.
            end.
            else if entry(1,linha,":") = "FAB"
            then do:
                valor = trim(entry(2,linha,":")).
                tt-redz.nserie = valor.
                vred = no.
                leave.
            end.

        end.
    end.        
end.
for each tt-redz:
    disp tt-redz with 2 column.
    
    find first mapcxa where mapcxa.etbcod = vetbcod and
                      mapcxa.cxacod = tt-redz.equipa and
                      mapcxa.datmov = tt-redz.dmovim no-error.
    if not avail mapcxa
    then do:
        create mapcxa.
        assign mapcxa.Etbcod = vetbcod
               mapcxa.cxacod = tt-redz.equipa
               mapcxa.datmov = tt-redz.dmovim
               mapcxa.nrored = tt-redz.nreduc
               mapcxa.de1    = dec(tt-redz.equipa)
               mapcxa.cooini = 0
               mapcxa.ch1    = tt-redz.nserie
               mapcxa.de2    = dec(tt-redz.versao)
               mapcxa.datatu = tt-redz.dmovim
               mapcxa.datred = tt-redz.dmovim
               mapcxa.nrofab = int(tt-redz.versao)
               mapcxa.nroseq = int(tt-redz.nrocan)
               mapcxa.coofin = int(tt-redz.coofin)
               mapcxa.nrocan = int(tt-redz.nrocan)
               mapcxa.nrored = tt-redz.nreduc
               mapcxa.gtotal = tt-redz.gtotal
               mapcxa.vlacr  = 0
               mapcxa.vldes  = 0
               mapcxa.vlcan  = tt-redz.cancel
               mapcxa.vlsub  = tt-redz.val_st
               mapcxa.valbru = tt-redz.valbru
               mapcxa.valliq = tt-redz.valliq
               mapcxa.t01    = tt-redz.val_17
               mapcxa.t02    = tt-redz.val_12
               mapcxa.t03    = tt-redz.val_07
               .
               
    end.
    else mapcxa.nrored = tt-redz.nreduc.
    
    find first mapcxa where mapcxa.etbcod = vetbcod and
                      mapcxa.cxacod = tt-redz.equipa and
                      mapcxa.datmov = tt-redz.dmovim no-error.
 
    find first mapctb where
               mapctb.etbcod = vetbcod and
               mapctb.cxacod = tt-redz.equipa and
               mapctb.datmov = tt-redz.dmovim and
               mapctb.nrored = tt-redz.nreduc
               no-error.
    if not avail mapctb
    then do:
        create mapctb.
        buffer-copy mapcxa to mapctb.
    end.     
    if avail mapctb
    then do:
        if mapctb.t01 < tt-redz.val_17
        then mapctb.t01 = tt-redz.val_17.
        if mapctb.t02 < tt-redz.val_12
        then mapctb.t02 = tt-redz.val_12.
        if mapctb.t03 < tt-redz.val_07
        then mapctb.t03 = tt-redz.val_07.
        if mapctb.vlcan < tt-redz.cancel
        then mapctb.vlcan = tt-redz.cancel.
        if mapctb.vlsub < tt-redz.val_st
        then mapctb.vlsub = tt-redz.val_st.  
        if mapctb.valbru < tt-redz.valbru
        then mapctb.valbru = tt-redz.valbru.
        if mapctb.valliq < tt-redz.valliq
        then mapctb.valliq = tt-redz.valliq.
        if mapctb.gtotal < tt-redz.gtotal
        then mapctb.gtotal = tt-redz.gtotal.
    end.      
end.    
end.

procedure cria-plani.
    def var vhor as int.
    def var vmin as int.
    def var vseg as int.
    def var vserie like plani.serie.
    vserie = "V".
    vhor = int(substr(string(vhora),1,2)).
    vmin = int(substr(string(vhora),4,2)).
    vseg = int(substr(string(vhora),7,2)).
    find first wf-plani where
               wf-plani.etbcod = vetbcod and
               wf-plani.emite  = vetbcod and
               wf-plani.numero = vnumero
               no-error.
    if avail wf-plani
    then assign
             vnumero = int(vcoo)
             vserie = "V1"
               .
    else do:
        find first plani where plani.movtdc = 5 and
                         plani.etbcod = vetbcod and
                         plani.emite  = vetbcod and
                         plani.serie  = vserie and
                         plani.numero = vnumero
                         no-lock no-error.
        if avail plani and
                 plani.platot <> vtotal / 100
        then assign 
                 vnumero = int(vcoo)
                 vserie = "V1"
                 .           
    end.
    create wf-plani.
    assign
        wf-plani.etbcod = vetbcod
        wf-plani.emite = vetbcod
        wf-plani.placod = int(string("213") + string(vnumero,"9999999"))
        wf-plani.pladat = vdata
        wf-plani.horincl = ((vhor * 60) * 60) + (vmin * 60) + vseg
        wf-plani.numero = vnumero
        wf-plani.vencod = vvencod
        wf-plani.cxacod = vcxacod
        wf-plani.dtinclu = vdata
        wf-plani.serie    = vserie
        wf-plani.movtdc   = 5
        wf-plani.platot = vtotal / 100
        wf-plani.ufemi = vnrofab
        wf-plani.notped = "C|" + string(int(vcoo)) + "|" + "|"
        .
    find first clien where clien.clinom begins vclinom
                no-lock no-error.
    if not avail clien
    then find first clien where clien.ciccgc = vcgccpf
                    no-lock no-error.
    if avail clien
    then wf-plani.desti = clien.clicod.            

    for each wf-movim where wf-movim.placod = int(vcoo):
        wf-movim.placod = wf-plani.placod.
    end.  
end procedure.

procedure cria-movim.

    def var vhor as int.
    def var vmin as int.
    def var vseg as int.

    vhor = int(substr(string(vhora),1,2)).
    vmin = int(substr(string(vhora),4,2)).
    vseg = int(substr(string(vhora),7,2)).
    /*
    message vprocod vhora. pause.
    */
    find first wf-movim where
               wf-movim.etbcod = vetbcod and
               wf-movim.placod = int(vcoo) 
               and wf-movim.procod = vprocod
               no-error.
    if not avail wf-movim
    then do:    
        if vmovpc = ? then vmovpc = 1.
        if vmovpc = 0 then vmovpc = 1.
        if vmovqtm = ? then vmovqtm = 1.
        if vmovqtm = 0 then vmovqtm = 1.
    create wf-movim.
    assign
        wf-movim.etbcod = vetbcod
        wf-movim.placod = int(vcoo)
        wf-movim.movtdc = 5
        wf-movim.movdat = vdata
        wf-movim.movhr  = ((vhor * 60) * 60) + (vmin * 60) + vseg
        wf-movim.movseq = qt-item 
        wf-movim.procod = vprocod 
        wf-movim.movqtm = vmovqtm
        wf-movim.movpc  = vmovpc / vmovqtm
        wf-movim.movalicms = vmovalicms
        .
    end.        
end procedure.

procedure val-numero:
    def input parameter linha as char.
    def var vn as char.
    def var vnu as char.
    def var vi as int.
    vn = substr(string(entry(2,linha,":")),1,8).
    do vi = 1 to 8:
        if substr(string(vn),vi,1) = "1" or
           substr(string(vn),vi,1) = "2" or
           substr(string(vn),vi,1) = "3" or
           substr(string(vn),vi,1) = "4" or
           substr(string(vn),vi,1) = "5" or
           substr(string(vn),vi,1) = "6" or
           substr(string(vn),vi,1) = "7" or
           substr(string(vn),vi,1) = "8" or
           substr(string(vn),vi,1) = "9" or
           substr(string(vn),vi,1) = "0" 
        then vnu = vnu + substr(string(vn),vi,1).

    end.
    vnumero = int(vnu).
end procedure.

procedure val-i:

    def var i as int.
    def var v as char extent 25.
    
    do i = 1 to num-entries(vval-i,";"):
        v[i] = entry(i,vval-i,";").
        if v[i] = "T1" or
           v[i] = "F1"
        then v-ti = v[i].
        if substr(string(v[i]),2,2) = "UN"
        then v-qi = substr(string(v[i]),1,1).
        if substr(string(v[i]),3,2) = "UN" 
        then v-qi = substr(string(v[i]),1,2).
    end.
    if v[25] <> "" then v-vi = v[25].
    else if v[24] <> "" then v-vi = v[24].
    else if v[23] <> "" then v-vi = v[23].
    else if v[22] <> "" then v-vi = v[22].
    else if v[21] <> "" then v-vi = v[21].
    else if v[20] <> "" then v-vi = v[20].
    else if v[19] <> "" then v-vi = v[19].
    else if v[18] <> "" then v-vi = v[18].
    else if v[17] <> "" then v-vi = v[17].
    else if v[16] <> "" then v-vi = v[16].
    else if v[15] <> "" then v-vi = v[15].
    else if v[14] <> "" then v-vi = v[14].
    else if v[13] <> "" then v-vi = v[13].
    else if v[12] <> "" then v-vi = v[12].
    else if v[11] <> "" then v-vi = v[11].
    else if v[10] <> "" then v-vi = v[10].
    else if v[9] <> "" then v-vi = v[9].
    else if v[8] <> "" then v-vi = v[8].
      
end procedure.
