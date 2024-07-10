/*
Consumir o WS BRINKS
*/

def input parameter par-cofre as char.
def input parameter par-data as date.
  
def var vmetodo as char.
def var vcofre as char init "CSBR09083".

def var vdtic as char.
def var vdtfc as char.

def var vusuario as char init "ERIKAMULLER".
def var vsenha as char init "Menezes.26".
def var par-leretorno as log init yes.

assign
    vdtfc = string(par-data,"99/99/9999")
    vdtic = string(par-data,"99/99/9999")
    vcofre = par-cofre
    vmetodo = "listarDepositosCofre".

def var leretorno as log.

def new shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    field reg as int
     .

def var vtime   as int.
def var vretorno as char.

def var vcab1   as char.
def var vlf     as char. /* line feed */
def var sh      as handle NO-UNDO.
def var sb      as memptr.
def var vb      as memptr.
def var vtam    as int.
def var vpause  as int.
def var vip     as char init "189.2.104.30". 

vlf   = chr(10).
vtime = time.
empty temp-table tt-xmlretorno.

def var vxml as char.

vxml = "<?xml version=~"1.0~" encoding=~"utf-8~"?>
<soap:Envelope xmlns:xsi=~"http://www.w3.org/2001/XMLSchema-instance~" 
xmlns:xsd=~"http://www.w3.org/2001/XMLShema~" 
xmlns:soap=~"http://schemas.xmlsoap.org/soap/envelope/~">
<soap:Body><listarDepositosCofre xmlns=~"http://wwws.brinks.com.br/cwc~">
<strNumeroSerial>" + vcofre + "</strNumeroSerial>
<strDataIni>" + vdtic + "</strDataIni>
<strDataFim>" + vdtfc + "</strDataFim>
<strUsuario>" + vusuario + "</strUsuario>
<strSenha>" + vsenha + "</strSenha>
</listarDepositosCofre>
</soap:Body>
</soap:Envelope>"
.

def var clientephp as char.
def var varquivo as char.

clientephp = "http://sv-ca-ac/wsadm/wsbrinks/clientebrinks.php".
varquivo = "/admcom/relat/wsretorno-brinks." + string(time) + ".xml".

/*****
output to ./wsarqxml.txt.
put unformatted vxml.
output close.

vip = "wwws.brinks.com.br".
message "Conectando WS BRINKS ..." vip.
create socket sh no-error.
if sh:connect("-H " + vip + " -S 80" )
then do.
    message "Conectado WS BRINKS...".
    pause 0.
    
    set-size(sb) = 100000.
    set-size(vb) = 100000.

    vcab1 = 
        "POST /wsCompusafeReceive/service.asmx" +
        " HTTP/1.1" + vlf +
        "Host: wwws.brinks.com.br" + vlf +
        "Content-Type: text/xml; charset=utf-8" + vlf +
        "Content-Length: " + string(length(vxml)) + vlf +
        "SOAPAction: ~"http://wwws.brinks.com.br/cwc/listarDepositosCofre~""
         + vlf + vlf
        .
    
    output to wsenvio.txt.
    put unformatted vcab1 + vxml.
    output close.
    
    message "Enviando Solicitacao WS BRINKS ..." length(vcab1).
    assign
        put-string(sb, 1) = vcab1 + vxml.
    sh:write(sb, 1, length(vcab1 + vxml)).
                    
    vpause = 0.
    repeat.
        vpause = vpause + 1.
        pause 2 no-message.
        vtam = sh:GET-BYTES-AVAILABLE().
        message "Aguardando retorno... (" vpause ")" vtam.
        if vtam > 0 or vpause > 20
        then leave.
    end.
    if vpause > 20
    then do.
        message "Problema no retorno WS BRINKS" view-as alert-box.
        return.
    end.
        
    pause 1 no-message.
    
    sh:read(vb , 1, vtam).
                    
    output to value(varquivo).
    put unformatted get-string(vb,1).
    output close.

    run le-retorno.

end.
else do.
    message "Falha ao conectar ao servidor" view-as alert-box.
    return.
end.
sh:disconnect().
hide message.
Delete Object sh.
******/
/***
vxml = "method=RetornarMovimentosCofreXML" +
       " ccofre=" + string(vcofre) +
       " dconsulta=" + vdti +
       " dini=" + vdti +
       " dfim=" + vdtf +
       " ceven=31" + 
       " arqxml=" + varquivo
       .
***/

def var vdtcons as char.
vdtcons = string(today,"99/99/9999").

vxml = "method=listarDepositosCofre" +
       " ccofre=" + string(vcofre) +
       " dconsulta=" + vdtcons +
       " dini=" + vdtic +
       " dfim=" + vdtfc +
       " ceven=31" + 
       " arqxml=" + varquivo
       .

unix silent value("/admcom/progr/WSbrinks.py " + vxml).

pause 1 no-message.

unix silent value("chmod 777 " + varquivo).
/**
def var varq-quo as char.
varq-quo = varquivo + ".quo".
unix silent value("quoter -d ""<"" " +  varquivo  + " > " + varq-quo).
**/

run le-retorno.

def var vid as int.

def temp-table tt-depcofre like depcofre.

pause 0.

def var vcodcofre as int.

for each tt-xmlretorno break by tt-xmlretorno.reg:
    if first-of(tt-xmlretorno.reg)
    then do:
        create tt-depcofre.
        tt-depcofre.empresa_cofre = "BRINKS".
    end.
    if tt-xmlretorno.tag = "ID"
    then tt-depcofre.id = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "CODIGOCOFRE"
    then tt-depcofre.CODIGOCOFRE = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "NOME_FUNC"
    then tt-depcofre.NOME_FUNC = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "NUM_RECIBO"
    then tt-depcofre.NUM_RECIBO = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "NUMEROLOCAL"
    then tt-depcofre.NUMEROLOCAL = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "VALOR"
    then tt-depcofre.VALOR = dec(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "MOEDA"
    then tt-depcofre.MOEDA = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "TIPO_DEPOSITO"
    then tt-depcofre.TIPO_DEPOSITO = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "NUMEROSERIAL"
    then tt-depcofre.NUMEROSERIAL = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "DATA_DEPOSITO"
    then tt-depcofre.DATA_DEPOSITO = date(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "HORA_DEPOSITO"
    then tt-depcofre.HORA_DEPOSITO = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "COD_GTV"
    then tt-depcofre.COD_GTV = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "DATA_COLETA"
    then tt-depcofre.DATA_COLETA = date(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "HORA_COLETA"
    then tt-depcofre.HORA_COLETA = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "DATA_CONFERENCIA"
    then tt-depcofre.DATA_CONFERENCIA = date(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "HORA_CONFERENCIA"
    then tt-depcofre.HORA_CONFERENCIA = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "VIA_LEITORA_DE_NOTAS"
    then tt-depcofre.VIA_LEITORA_DE_NOTAS = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "DATA/HORA_DEPOSITO"
    then tt-depcofre.DATA_HORA_DEPOSITO = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "SELO_CASSETE"
    then tt-depcofre.SELO_CASSETE = tt-xmlretorno.valor.
    else if tt-xmlretorno.tag = "ID_DEPOSITO_LEITORA"
    then tt-depcofre.ID_DEPOSITO_LEITORA = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "ID_DEPOSITO_ENVELOPE"
    then tt-depcofre.ID_DEPOSITO_ENVELOPE = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "ID_FECHAMENTO_DO"
    then tt-depcofre.ID_FECHAMENTO_DO = int(tt-xmlretorno.valor).
    else if tt-xmlretorno.tag = "DT_MOVIMENTO_FIM"
    then tt-depcofre.DT_MOVIMENTO_FIM = date(tt-xmlretorno.valor).
end.

for each tt-depcofre:
    find depcofre where 
         depcofre.id = tt-depcofre.id and
         depcofre.codigocofre = tt-depcofre.codigocofre and
         depcofre.data_deposito = tt-depcofre.data_deposito and
         depcofre.hora_deposito = tt-depcofre.hora_deposito
         no-lock no-error  . 
    if not avail depcofre
    then do:     
        create depcofre.
        buffer-copy tt-depcofre to depcofre.
    end.
end.      

def temp-table tt-arqre
    field qlinha as int
    field dlinha as char
    index i1 qlinha
     .

procedure le-retorno.
    def var vmens as char.
    def var Hdoc  as handle.
    def var Hroot as handle.
    def var va as char.
    def var dlinha as char.
    def var ql as int.
    
    for each tt-arqre: delete tt-arqre. end.
    /***
    input from value(varq-quo).
    repeat:
        import unformatted dlinha.
        do:
            ql = ql + 1.
            create tt-arqre.
            assign
                tt-arqre.qlinha = ql
                tt-arqre.dlinha = dlinha.
        end.
    end.
    input close.
    
    find first tt-arqre no-error.
    if not avail tt-arqre
    then return.
     
    for each tt-arqre:    
        vretorno = tt-arqre.dlinha.
        vretorno = replace(vretorno, "&lt;", "<").
        vretorno = replace(vretorno, "lt;", "<").
        vretorno = replace(vretorno, "&gt;", ">").
        vretorno = replace(vretorno, "&amp;","&").
        vretorno = replace(vretorno, "&#xD;","").
        vretorno = replace(vretorno, "324D","").
        vretorno = replace(vretorno, "$^M","").
        vretorno = replace(vretorno, "^M","").
        vretorno = replace(vretorno, "DFE","").
        tt-arqre.dlinha = vretorno.
    end.
    ****/
    
    def var varq-ret as char.
    varq-ret = varquivo + ".txt".
    
    
    def var vlinha as char.
    def var vq as int.
    vq = 1.
    
    input from value(varq-ret).
    repeat:
        import unformatted vlinha.
        num-entries(vlinha,";").

        if num-entries(vlinha,";") <> 5
        then do:
            message color red/with
                "Problema ao importar XML"
                view-as alert-box.
        end.

        create tt-xmlretorno.
        tt-xmlretorno.tag = "ID".
        tt-xmlretorno.valor = entry(1,vlinha,";").
        tt-xmlretorno.reg = vq.

        create tt-xmlretorno.
        tt-xmlretorno.tag = "CODIGOCOFRE".
        tt-xmlretorno.valor = entry(2,vlinha,";").
        tt-xmlretorno.reg = vq.

        create tt-xmlretorno.
        tt-xmlretorno.tag = "NUM_RECIBO".
        tt-xmlretorno.valor = entry(3,vlinha,";").
        tt-xmlretorno.reg = vq.
 
        create tt-xmlretorno.
        tt-xmlretorno.tag = "DATA_DEPOSITO".
        tt-xmlretorno.valor = entry(5,vlinha,";").
        tt-xmlretorno.reg = vq.
        
        create tt-xmlretorno.
        tt-xmlretorno.tag = "VALOR".
        tt-xmlretorno.valor = entry(4,vlinha,";").
        tt-xmlretorno.reg = vq.
        vq = vq + 1.
        

        /*
        if vlinha matches "*Retorno xmlns=*"
        then do:
            vmens = entry(7,vlinha,">").
            vmens = entry(1,vmens,".").
            
            hide message no-pause.
                message "BRINKS " par-cofre " " vdti.
                message vmens. pause 50.
        end. 
        else if trim(entry(1,vlinha,">")) = "<CODIGOCOFRE"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "CODIGOCOFRE".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<NUM_RECIBO"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "NUM_RECIBO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<ID"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "ID".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.    
        else if trim(entry(1,vlinha,">")) = "<VALOR"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "VALOR".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
            vq = vq + 1.
        end.
        else if trim(entry(1,vlinha,">")) = "<DATA_DEPOSITO"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "DATA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"").
            tt-xmlretorno.reg = vq.
            create tt-xmlretorno.
        end.
        else if trim(entry(1,vlinha,">")) = "<HORA_DEPOSITO"
        then do:
            tt-xmlretorno.tag = "HORA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(2,tt-xmlretorno.valor,"").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end. 
        ***/
    end.  
    input close. 
    
end procedure.


procedure retorno.

    def var Hdoc  as handle.
    def var Hroot as handle.

    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").

    put-string(vb, 1) = vretorno.

    /*
    output to value("../relat/notamax-rec." + par-metodo + string(vtime)).
    put unformatted vretorno.
    output close.
    */
    
    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 
      
    run obtemnode ("", input hroot).

end procedure.


procedure obtemnode.

    def input parameter p-root  as char.
    def input parameter vh      as handle.

    def var hc   as handle.
    def var loop as int.
    
    create x-noderef hc.
    /* A partir daqui monta o retorno */
    do loop = 1 to vh:num-children: /*faz o loop até o numero total de filhos*/
        vh:get-child(hc,loop).
        run obtemnode (vh:name, input hc:handle).
        if trim(hc:node-value) <> ""
        then do.
            create tt-xmlretorno.
            tt-xmlretorno.root  = p-root.
            tt-xmlretorno.tag   = vh:name. /* nomes das tags */
            tt-xmlretorno.valor = trim(hc:node-value).
        end.    
    end.                       

end procedure.

procedure grv-arquivo:
    
end procedure.
