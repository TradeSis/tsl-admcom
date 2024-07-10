{admcab.i}

def temp-table tt-tbprice like tbprice.
def var vindex as int.
def var vcam as char.
def var varq as char.
def var varq1 as char.
def var vcamarq as char.
def var vtipo as char extent 4 format "x(20)".
assign vtipo[1] = "ASSISTENCIA TECNICA".  /* antonio */

/*
vtipo[1] = "ASSISTENCIA TECNICA".
vtipo[2] = "     TIM".
vtipo[3] = "     CLARO".
vtipo[4] = "     NOKIA".
disp vtipo[1]
     help " SELECIONE A OPCAO"
     with frame f-tipo 1 down centered no-label
     /*1 column*/.
choose field vtipo[1] with frame f-tipo.
vindex = frame-index.
*/

vindex = 1.  /* antonio */
if opsys = "UNIX"
then varq = "/admcom/price/".
else varq = "l:~\price~\".
vcamarq = varq.
disp varq format "x(20)" label "Arquivo" with frame f-arq.
update varq label "Arquivo"  format "x(60)"
        with frame f-arq 1 down centered side-label.

              
vcamarq = vcam + varq.
if search(varq) = ?
then do:
    bell.
    message "Arquivo nao encontrado".
    pause.
    return.
end.

if opsys = "UNIX"
then varq1 = varq + "x.quo".
else varq1 = varq + "w.quo".

if opsys = "UNIX"
then unix silent value("quoter -d % " +  varq  + " > " + varq1).
else dos   value("c:\dlc\bin\quoter -d % " +  varq  + " > " + varq1).

if search(varq1) <> ?
then.
else return.

def var vlinha as char.
def var vv as int.
def var va as int.
def var vb as int.
def var vc as int.
def var vd as int.
def var vvalor as char extent 20.
def var v-leng as int.
input from value(varq1).
repeat:
    import vlinha.
    if substr(vlinha,1,30) = ""
    then leave.
    vb = 1.
    vc = 1.
    vd = 1.
    if vv > 1   and substr(vlinha,1,1) <> ";"
    then do:
        do va = 1 to 200:
            if substr(vlinha,va,1) = ";"   or
                (vd = 8 and substr(vlinha,va,1) = "")
            then do:
                vc = va - vb.
                vvalor[vd] = substr(vlinha,vb,vc).
                vb = va + 1.
                vd = vd + 1.
            end.
        end.
        if substr(trim(vvalor[5]),1,1) = "-"
        then next.
        /**
        output to ./teste2.tst append.
        disp trim(vtipo[vindex])
             int(substr(trim(vvalor[3]),1,6))
             trim(vvalor[1])
             date(trim(vvalor[4]))
             dec(trim(vvalor[5])) / 100
             dec(trim(vvalor[6])) / 100
             dec(trim(vvalor[7])) / 100
             dec(trim(vvalor[8])) / 100    
               with no-label.
         output close.
         **/
         find first tt-tbprice where
                   tt-tbprice.tipo = trim(vtipo[vindex]) and
                   tt-tbprice.serial = trim(vvalor[1])
                   no-error.
        if not avail tt-tbprice
        then do:
            do va = 1 to 20:
                if substr(vvalor[5],va,1) = "," 
                then do:
                    vc = int(length(substr(vvalor[5],va + 1,2))).
                    if vc = 0
                    then vvalor[5] = vvalor[5] + ",00".
                    else if vc = 1
                        then vvalor[5] = vvalor[5] + "0".
                    leave. 
                end.
            end.
            do va = 1 to 20:
                if substr(vvalor[6],va,1) = "," 
                then do:
                    vc = int(length(substr(vvalor[6],va + 1,2))).
                    if vc = 0
                    then vvalor[6] = vvalor[6] + ",00".
                    else if vc = 1
                        then vvalor[6] = vvalor[6] + "0".
                    leave. 
                end.
            end.
            do va = 1 to 20:
                if substr(vvalor[7],va,1) = "," 
                then do:
                    vc = int(length(substr(vvalor[7],va + 1,2))).
                    if vc = 0
                    then vvalor[7] = vvalor[7] + ",00".
                    else if vc = 1
                        then vvalor[7] = vvalor[7] + "0".
                    leave. 
                end.
            end.
            do va = 1 to 20:
                if substr(vvalor[8],va,1) = "," 
                then do:
                    vc = int(length(substr(vvalor[8],va + 1,2))).
                    if vc = 0
                    then vvalor[8] = vvalor[8] + ",00".
                    else if vc = 1
                        then vvalor[8] = vvalor[8] + "0".
                    leave. 
                end.
            end.
            create tt-tbprice.  
            assign
            tt-tbprice.etb_compra = 93
            tt-tbprice.tipo = trim(vtipo[vindex])
            tt-tbprice.nota_compra    = int(substr(trim(vvalor[3]),1,6))
            tt-tbprice.serial         = trim(vvalor[1])
            tt-tbprice.char1          = vvalor[2]
            tt-tbprice.data_compra    = date(trim(vvalor[4]))
            tt-tbprice.custo_original = dec(trim(vvalor[5])) / 100
            tt-tbprice.custo_venda    = dec(trim(vvalor[6])) / 100
            tt-tbprice.dec1           = dec(trim(vvalor[7])) / 100
            tt-tbprice.venda_sugerido = dec(trim(vvalor[8])) / 100
               .
            disp tt-tbprice.tipo
                tt-tbprice.nota_compra
                tt-tbprice.serial format "x(20)"
                tt-tbprice.data_compra
                tt-tbprice.custo_original
                with frame ff down no-label centered row 9
                 width 70 title "    importando arquivo     ".
            pause 0.
        end.
    end.                                 
    vv = vv + 1.
end. 
def buffer btbprice for tbprice.

message " GRVANDO DADO... AGUARDE! ".
for each tt-tbprice where tt-tbprice.tipo <> "":
    tt-tbprice.tipo = "".
    find tbprice where tbprice.tipo = tt-tbprice.tipo and
                       tbprice.serial = tt-tbprice.serial
                       no-error.
    if not avail tbprice
    then find first tbprice where tbprice.tipo <> tt-tbprice.tipo and
                       tbprice.serial = tt-tbprice.serial
                       no-error.
    if not avail tbprice
    then do:              
        create tbprice.
        buffer-copy tt-tbprice to tbprice.
    end.
    else do:
        tbprice.tipo = "ASSISTENCIA".
        create btbprice.
        buffer-copy tt-tbprice to btbprice.
        /***
        assign
            tbprice.tipo = ""
            tbprice.etb_venda = 0
            tbprice.nota_venda = 0
            tbprice.data_venda = ?
            tbprice.char1 = ""
            tbprice.char2 = ""
            .
        ****/    
        btbprice.char3 = "RETORNO-ASSITENCIA=SIM|" .
    end.
end.
