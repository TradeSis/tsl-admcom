
{admcab.i}

def input parameter vprocod like produ.procod.
def input parameter vqtdpro as int.
def input parameter vqtdeti as int.

def var fila as char format "x(20)".

def var varquivo-etiq as char.
def var varquivo-etiq-sai-sob as char.
def var varquivo-etiq-sai as char.

def var westac like estac.etcnom format "x(20)".
def var vano as i format 99.
def var vmes as i format 99.
def var par-qtd as int.
def var vproant as char format "x(8)".
def var vlinha as int.
def var wcopias as int.
def var wvezes  as int.
def var wetique as int.
def var wsobra  as int.
def var vconta as int.
def var vpos   as int.
def var vnome1 as char .
def var vnome2 as char.
def var vdata as char format "x(4)".

def temp-table wfetq
    field linha as int
    field comando as char format "x(70)".

def var vdescricao as char.
def var vprocod1 as char.
def var recimp as recid.
def var vtime as int.
vtime = int(string(time)).
repeat:
    par-qtd = vqtdeti.
    if opsys = "UNIX"
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
    else fila = "".
    
    if opsys = "UNIX"
    then do:
        os-command silent /admcom/progr/cupszebra.sh  value(fila).
        os-command silent "lpr " value(fila) " /admcom/zebra/lebes.grf".
    end. 
    else do:  
       output to "c:\temp\lebes-grf.bat".
        
             put "c:\windows\command\mode com1:9600,e,7,2,r" skip
                      "copy l:\zebra\lebes.grf com1" skip.

       output close.
                      
       os-command silent etique.bat. 
    end.
    
    if opsys = "UNIX"
    then varquivo-etiq = "/admcom/zebra/pallet.Z".
    else varquivo-etiq = "l:\zebra\pallet.Z".
    
    input from value(varquivo-etiq) no-echo.
    
    vlinha = 0.
    
    repeat:
        create wfetq.
        import comando. 
        vlinha = vlinha + 1.
        wfetq.linha = vlinha.
    end.      
    input close.

    wcopias = par-qtd.
    vprocod1 = string(vqtdpro,"9999") + string(vprocod,"99999999").        
    
    find produ where produ.procod = vprocod no-lock no-error.
    if avail produ
    then vdescricao = produ.pronom.
    else vdescricao = "". 
    
    for each wfetq break by linha:
        if wfetq.linha = 5
        then vpos = 49.
        else if wfetq.linha = 3
             then vpos = 4.
             else if wfetq.linha = 6
                  then vpos = 29.
                  else if wfetq.linha = 7
                       then vpos = 35.
                       else vpos = 1.
        assign
            substring(wfetq.comando,vpos) = if wfetq.linha = 3
                                            then string(wcopias,"9999")
                                            else if wfetq.linha = 5
                                            then string(vdescricao,"x(40)")
                                            else if wfetq.linha = 6
                                            then string(today,"99/99/9999")
                                            else if wfetq.linha = 7
                                            then string(vprocod1,"x(12)")
                                            else substring(wfetq.comando,vpos).
    end.        
        if opsys = "UNIX"
        then varquivo-etiq-sai = "/admcom/zebra-fila/pallet"
                               + string(vprocod,"999999999999")
                               + string(vtime).
        else varquivo-etiq-sai = "l:\zebra-fila\pallet"
                               + string(produ.procod,"999999999999")
                               + string(vtime).
        
        output to value(varquivo-etiq-sai).
        
            for each wfetq break by linha.
                put unformatted wfetq.comando skip.
            end.

        output close.
        

        output to /admcom/relat/etique.bat append.
            put trim(" cat " + varquivo-etiq-sai + " > zebra") format "x(40)" skip.
        output close.
 
        leave.
end.    
