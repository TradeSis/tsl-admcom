{admcab.i}

def temp-table tt-tbprice like tbprice.
def var vindex as int.
def var vcam as char.
def var varq as char.
def var varq1 as char.
def var vcamarq as char.
def var vtipo as char extent 18 format "x(14)".
vtipo[1] = "VIVO".
vtipo[2] = "TIM".
vtipo[3] = "CLARO".
vtipo[4] = "NOKIA".
vtipo[5] = "TOSHIBA".
vtipo[6] = "MOTOROLA".
vtipo[7] = "SAMSUNG".
vtipo[8] = "ALCATEL".
vtipo[9] = "LG".
vtipo[10] = "POSITIVO".
vtipo[11] = "ALLIED".
vtipo[12] = "RCELL".
vtipo[13] = "MULTILASER".
vtipo[14] = "SONY".
vtipo[15] = "BLU".
vtipo[16] = "DL".
vtipo[17] = "ASUS".
vtipo[18] = "INGRAN".

disp vtipo
     help " SELECIONE A OPERADORA "
     with frame f-tipo 1 down centered no-label
     1 column.
choose field vtipo with frame f-tipo.
vindex = frame-index.
hide frame f-tipo.
disp vtipo[vindex] with frame f-d
    1 down no-label no-box centered color message.

if opsys = "UNIX"
then varq = "/admcom/price/".
else varq = "l:~\price~\".
vcamarq = varq.
disp varq format "x(20)" label "Arquivo" with frame f-arq.
update varq no-label  format "x(50)"
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
            tt-tbprice.etb_compra = 900
            tt-tbprice.tipo = trim(vtipo[vindex]).
            
            if vindex = 7 /* Tipo Samsung pega só o inteiro da nota de compra */
            then assign
                   tt-tbprice.nota_compra = int(vvalor[3]).
            else assign
                   tt-tbprice.nota_compra = int(substr(trim(vvalor[3]),1,6)).

            assign
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
                /*tt-tbprice.custo_venda
                tt-tbprice.dec1
                tt-tbprice.venda_sugerido*/
                with frame ff down no-label centered row 9
                 width 70 title "    importando arquivo     ".
            pause 0.
        end.
    end.                                 
    vv = vv + 1.
end. 

message " GRAVANDO DADOS... AGUARDE! ".
pause.

def buffer btbprice for tbprice.
for each tt-tbprice where tt-tbprice.tipo <> "":
    tt-tbprice.tipo = "".
    find tbprice where tbprice.tipo = tt-tbprice.tipo and
                       tbprice.serial = tt-tbprice.serial
                       no-error.
    if not avail tbprice
    then do:                   
        create tbprice.
        buffer-copy tt-tbprice to tbprice.
    end.
    else do:
        if tbprice.serial = "89550655305001100000"
        then tbprice.nota_compra = tt-tbprice.nota_compra.
        else do:
            assign
                tbprice.nota_compra = tt-tbprice.nota_compra
                tbprice.data_compra = tt-tbprice.data_compra
                tbprice.custo_original = tt-tbprice.custo_original 
                tbprice.custo_venda = tt-tbprice.custo_venda
                tbprice.dec1 = tt-tbprice.dec1
                tbprice.venda_sugerido = tt-tbprice.venda_sugerido
                .
            if trim(vtipo[vindex]) = "SAMSUNG"
            THEN do:
                find btbprice where btbprice.tipo = "VIVO" and
                       btbprice.serial = tt-tbprice.serial
                       no-error.
                if avail  btbprice
                then do:
                    assign
                    btbprice.nota_compra = tt-tbprice.nota_compra
                    btbprice.data_compra = tt-tbprice.data_compra
                    btbprice.custo_original = tt-tbprice.custo_original 
                    btbprice.custo_venda = tt-tbprice.custo_venda
                    btbprice.dec1 = tt-tbprice.dec1
                    btbprice.venda_sugerido = tt-tbprice.venda_sugerido
                    .
                end.
            end.    
        end.
    end.
end.
