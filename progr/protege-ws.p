/*
Consumir o WS PROTEGE
*/

def input parameter par-cofre as char.
def input parameter par-dti as date.
def input parameter par-dtf as date.

def var vmetodo as char.
def var vcofre as char.
def var vdti as char.
def var vdtf as char.
def var vusuario as char init "drebes.financ".
def var vsenha as char init "1234".
def var vdtm as char.
 
assign
    vdtm = string(year(today),"9999") + "-" +
           string(month(today),"99") + "-" +
           string(day(today),"99") 
    vdti = string(year(par-dti),"9999") + "-" +
           string(month(par-dti),"99") + "-" +
           string(day(par-dti),"99")
    vdtf = string(year(par-dtf),"9999") + "-" +
           string(month(par-dtf),"99") + "-" +
           string(day(par-dtf),"99") 
    vcofre = par-cofre
    vmetodo = "MovimentosCofre".

def var leretorno as log.
def var varquivo as char.

def new shared temp-table tt-xmlretorno
    field root       as char format "x(15)"
    field tag        as char format "x(20)"
    field valor      as char format "x(20)"
    field reg as int
     .

def var vtime   as int.
def var vretorno as longchar.
def var vretorno1 as char.

def var vcab1   as char.
def var vlf     as char. /* line feed */
def var sh      as handle NO-UNDO.
def var sb      as memptr.
def var vb      as memptr.
def var vtam    as int.
def var vpause  as int.
def var vip     as char init "177.11.253.55". 

vlf   = chr(10).
vtime = time.
empty temp-table tt-xmlretorno.

varquivo = "/admcom/relat/protege" + vmetodo + string(vtime).

def var vxml as char.
/***********************
vxml = "<?xml version=~"1.0~" encoding=~"utf-8~"?>" +
"<s:Envelope xmlns:s=~"http://schemas.xmlsoap.org/soap/envelope/~"><s:Body>
<RetornarMovimentosCofreXML xmlns=~"http://tempuri.org/~">
<xmlEnvio>&lt;?xml version=~"1.0~" encoding=~"utf-8~"?&gt;&#xD;
&lt;movimentos dataConsulta=~"" + vdtm +
"~"&gt;&lt;login&gt;&lt;usuario&gt;drebes.financ&lt;/usuario&gt;&lt;s" +
"enha&gt;1234&lt;/senha&gt;&lt;/login&gt;&lt;fi~ltros&gt;&lt;codCofre&gt;" + string(vcofre) +
"&lt;/codCofre&gt;&lt;dtaDe&gt;" + vdti + "&lt;/dtaDe&gt;&lt;dtaAte&gt;"
+ vdtf + "&lt;/dtaAte&gt;&lt;tipEvento&gt;31&lt;/tipEvento&gt" +
";&lt;/filtros&gt;&lt;/movimentos&gt;</xmlEnvio></RetornarMovimentosCofreXML>
</s~:Body></s:Envelope>".

vip = "177.11.253.55".
message "Conectando WS PROTEGE ..." vip.
create socket sh no-error.
if sh:connect("-H " + vip + " -S 8755")
then do.
    
    message "Conectado WS PROTEGE...".
    pause 0.
    set-size(sb) = 300000.
    set-size(vb) = 300000.

      vcab1 = 
        "POST /MovimentosCofre/ HTTP/1.1" + vlf +
        "Host: 177.11.253.55:8755" + vlf + 
        "Content-Type: text/xml" + vlf +
        "Content-Length: " + string(length(vxml)) + vlf +
        "SOAPAction: " +
"~"http://tempuri.org/IMovimentosCofre/RetornarMovimentosCofreXML~"" 
             + vlf +
        "Expect: 100-continue" + vlf +
        "Accept-Encoding: gzip, deflate" + vlf +
        "Cache-Control: no-cache" 
        + vlf + vlf     
        .

    
    output to xmlprotegeenvio.xml.
    put unformatted vcab1 skip.
    put unformatted vxml skip.
    output close.
    

    message "Enviando Solicitacao WS PROTEGE ..." length(vcab1).
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
        message "Problema no retorno WSPROTEGE" view-as alert-box.
        return.
    end.

    pause 0.
        
    sh:read(vb , 1, vtam).
    vretorno = get-string(vb,1).
    /*
    output to value(varquivo).
        put unformatted  get-string(vb,1).
    output close.
    */
    
    run le-retorno.

end.
else do.
    message "Falha ao conectar ao servidor" view-as alert-box.
    return.
end.
sh:disconnect().
hide message.
Delete Object sh.

set-size(sb) = 0.
set-size(vb) = 0.
    
******/

vxml = "method=RetornarMovimentosCofreXML" +
       " ccofre=" + string(vcofre) +
       " dconsulta=" + vdti +
       " dini=" + vdti +
       " dfim=" + vdtf +
       " ceven=31" + 
       " arqxml=" + varquivo
       .

unix silent value("/admcom/progr/WSprotege.py " + vxml).
            
pause 1 no-message.
                    
run le-retorno.

def var vid as int.

def temp-table tt-depcofre like depcofre.

def buffer btt-xmlretorno for tt-xmlretorno.

pause 0.

def var vcodcofre as int.

for each tt-xmlretorno break by tt-xmlretorno.reg:
    if first-of(tt-xmlretorno.reg)
    then do:
        if tt-xmlretorno.tag = "CODIGOCOFRE"
        then vcodcofre = int(tt-xmlretorno.valor).
        create tt-depcofre.
        tt-depcofre.CODIGOCOFRE = vcodcofre.
        tt-depcofre.empresa_cofre = "PROTEGE".
    end.
    if tt-xmlretorno.tag = "ID"
    then tt-depcofre.id = int(tt-xmlretorno.valor).
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
    
    input from value(varquivo).
    repeat:
        import unformatted dlinha.
        if dlinha <> ""
        then do:
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
        /*
        vretorno = substr(vretorno, index(vretorno, "<") ).
        */
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

    /*
    put-string(vb, 1) = vretorno.
    */

    def var varq-ret as char.
    varq-ret = "/admcom/relat/protege-rec." + vmetodo + string(vtime).
    output to value(varq-ret).
    for each tt-arqre:
        put unformatted tt-arqre.dlinha skip.
    end.    
    output close.
    
    def var vlinha as char.
    def var vq as int.
    vq = 1.
    input from value(varq-ret).
    repeat:
        import unformatted vlinha.
        if length(vlinha) > 20 and trim(entry(1,vlinha,">")) = "<mensagem"
        then do:
            vmens = entry(2,vlinha,">").
            vmens = entry(1,vmens,"<").
            if length(vmens) > 20
            then do:
                hide message no-pause.
                message "PROTEGE " par-cofre .
                message vmens. pause 5 no-message.
            end.
        end.
        else if trim(entry(1,vlinha,">")) = "<codCofre"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "CODIGOCOFRE".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<numTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "NUM_RECIBO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<idtMovimento"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "ID".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.    
        else if trim(entry(1,vlinha,">")) = "<vlrTotalTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "VALOR".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
            vq = vq + 1.
        end.
        else if trim(entry(1,vlinha,">")) = "<dtaTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "DATA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"").
            tt-xmlretorno.reg = vq.
            create tt-xmlretorno.
            tt-xmlretorno.tag = "HORA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(2,tt-xmlretorno.valor,"").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end. 
    end.        
    input close.               
end procedure.

/****
procedure retorno.
    def var vmens as char.
    def var Hdoc  as handle.
    def var Hroot as handle.
    def var va as char.
    
    if index(vretorno, "<") = 0
    then return.

    vretorno = substr(vretorno, index(vretorno, "<") ).
    vretorno = replace(vretorno, "&lt;", "<").
    vretorno = replace(vretorno, "lt;", "<").
    /*if vretorno matches "/**/&gt*"
    then do:
        va = entry(1,vretorno,"").
        va = replace(va,"<","").
        vretorno = "<" + va + ">" + "<" + "/" + va + ">".
    end.*/
    /*vretorno = replace(vretorno, " /&gt;", "></>").
    */
    vretorno = replace(vretorno, "&gt;", ">").
    vretorno = replace(vretorno, "&amp;","&").
    vretorno = replace(vretorno, "&#xD;","").
    vretorno = replace(vretorno, "324D","").
    vretorno = replace(vretorno, "$^M","").
    vretorno = replace(vretorno, "^M","").
    vretorno = replace(vretorno, "DFE","").

    /*message vretorno. pause.*/
    
    put-string(vb, 1) = vretorno.

    def var varq-ret as char.
    varq-ret = "/admcom/work/protege-rec." + vmetodo + string(vtime).
    output to value(varq-ret).
    put unformatted vretorno.
    output close.
    
    
    /*
    create x-document HDoc.
    Hdoc:load("MEMPTR", vb, false). /* load do XML */
    create x-noderef hroot.
    hDoc:get-document-element(hroot). 
      
    run obtemnode ("", input hroot).
    */
    def var vlinha as char.
    def var vq as int.
    vq = 1.
    input from value(varq-ret).
    repeat:
        import unformatted vlinha.
        /*message vlinha . pause.

        message entry(1,vlinha,">"). pause.
        */
        if length(vlinha) > 20 and trim(entry(1,vlinha,">")) = "<mensagem"
        then do:
            vmens = entry(2,vlinha,">").
            vmens = entry(1,vmens,"<").
            if length(vmens) > 20
            then do:
                hide message no-pause.
                message "PROTEGE " par-cofre .
                message vmens. pause 5 no-message.
            end.
        end.
        else if trim(entry(1,vlinha,">")) = "<idtMovimento"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "ID".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.    
        else if trim(entry(1,vlinha,">")) = "<codCofre"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "CODIGOCOFRE".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<numTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "NUM_RECIBO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end.
        else if trim(entry(1,vlinha,">")) = "<vlrTotalTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "VALOR".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
            vq = vq + 1.
        end.
        else if trim(entry(1,vlinha,">")) = "<dtaTransacao"
        then do:
            create tt-xmlretorno.
            tt-xmlretorno.tag = "DATA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"").
            tt-xmlretorno.reg = vq.
            create tt-xmlretorno.
            tt-xmlretorno.tag = "HORA_DEPOSITO".
            tt-xmlretorno.valor = entry(2,vlinha,">").
            tt-xmlretorno.valor = entry(2,tt-xmlretorno.valor,"").
            tt-xmlretorno.valor = entry(1,tt-xmlretorno.valor,"<").
            tt-xmlretorno.reg = vq.
        end. 
                
        /***
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
    */
    end. 
    input close.
end procedure.
*/

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

