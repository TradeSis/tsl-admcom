{admcab.i}

def input parameter par-reclotcre  as recid.

def var par-numero as char format "x(60)".
def var par-dv10 as int.
def var aux-fornom as char.
def var aux-cgccpf as char.
def var v as int.

def temp-table tt-lotcretit
    field campo-rec as recid
    .

def temp-table tt-titulo2
    field campo-rec as recid
    .
    
def var vtitdtpag like titulo.titdtpag.

function digitomodulo11p2a7 returns integer
    (input par-numero as char,
     input-output par-dv10   as int).
   /*
   par-numero = replace(par-numero,"0","").
   */
   def var vct    as int.
   def var vparc  as int.
   def var vsoma  as int.
   def var vresto as int.
   def var vpeso as int.   

   def var vdd as char.
   def var c-tam as int.

   c-tam = int(length(par-numero)).
   vpeso = 2.
   do vct = c-tam to 1 by -1.
        vparc = (int(substr(par-numero,vct,1))).
        if vparc = 0 then .
        else do:
        vparc = vparc * vpeso.
        vdd = vdd + string(vparc) + "+".
        vsoma  = vsoma + vparc.
        end.
        vpeso = vpeso + 1.
        if vpeso = 7
        then vpeso = 2.
    end.        
    
    if vsoma < 11
    then vresto = vsoma.
    else vresto = vsoma modulo 11.

    if vresto = 0
    then return 0. 
    else do:
        if 11 - vresto = 0 or
           11 - vresto > 9
        then return 1.
        else return 11 - vresto.
    end.

end function.

def var vct      as int.
def var vseqarq  as int.
def var vcgc     as dec  init 96662168000131.
def var vcodconv as int  init 5348.
def var vagencia as int  init 878.          
def var vconta   as char init "0608896002". 
def var vlotenro as int.
def var vlotereg as int.
def var vlotevlr as dec.
def var vtotreg  as int.
def var varq     as char.
def var vbancod  as char.
def var vmoeda   as char.
def var vdac     as char.
def var vfatorv  as char.
def var vvalor   as char.
def var vlivre   as char.
def var vdv123   as char.
def var vbarcode as char.
def var vbancod2 as char.
def var vtime    as char.

find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.
vtitdtpag = lotcre.ltcreret.
vseqarq = lotcretp.ultimo + 1.
def var vi as int.
do vi = 1 to 99:
    varq = "/admcom/bradesco/titulos/PG" + 
                string(day(today),"99") + string(month(today),"99") +
                string(vi,"99") + ".REM".
    if search(varq) <> ?
    then.
    else leave.
end.
if search(varq) <> ?
then 
do vi = 1 to 9:    
    varq = "/admcom/bradesco/titulos/PG" +
                string(day(today),"99") + string(month(today),"99") +
                "A" + string(vi,"9") + ".REM".
    if search(varq) <> ?
    then.
    else leave.
end.
        
if search(varq) <> ?
then do:
    bell.
    message color red/with
    "ARQUIVO JA EXISTE " varq
    view-as alert-box.
    return.
end.    

disp
    varq    label "Arquivo"   colon 15 format "x(50)"
    vseqarq label "Sequencia" colon 15
    with side-label title "Remessa - " + lotcretp.ltcretnom.

/*
    Verificar o banco do boleto
*/
for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                     first  titulo2 where titulo2.empcod = wempre.empcod
                                   and titulo2.titnat = lotcretp.titnat
                                   and titulo2.modcod = lotcretit.modcod
                                   and titulo2.etbcod = lotcretit.etbcod
                                   and titulo2.clifor = lotcretit.clfcod
                                   and titulo2.titnum = lotcretit.titnum
                                   and titulo2.titpar = lotcretit.titpar
                                 no-lock.

    if acha("Bar", titulo2.codbarras) <> ?
    then do.
        vbarcode = acha("Bar", titulo2.codbarras).
        lotcretit.spcetbcod = int(substr(vbarcode,  1,  3)).
    end.
    else do.
        vbarcode = acha("Dig", titulo2.codbarras).
        lotcretit.spcetbcod = int(substr(vbarcode,  1,  3)).
    end.
    lotcretit.numero = titulo2.codbarras.
end.

def var num-seq-reg as int.
def var tipo-conta-for as int.
def var mod-pagamento as int.
def var seu-numero as char.
def var nosso-numero as char.
def var num-carteira as int.
def var num-pagamento as char.
def var digito-conta as char.
def var conta-forne as int.
def var digito-agencia as char.
def var agencia-forne as int.
def var banco-forne as int.
def var forne-forcep as int.
def var forne-forend as char.
def var forne-fornom as char.
def var forne-cgc-cpf as char.
def var tipo-insc-for as int.
def var num-lis-deb as int.
def var num-remessa as char.
def var cgc-cpf-pag as char.
def var raz-soc-pag as char.
def var cod-con-pag as int.
def var fator-vencimento as int.
def var qtd-registros as int.
def var tot-val-pag as dec.
def var for-cgc-cpf as char.
def var valor-documento as char.
def var valor-cobrado as char.
def var tipo-conta as int.
def var info-compl as char.
def var vtitvljur as char.
def var vtitvldes as char.
 
output to value(varq).
/*
    Header de arquivo
*/

vtime = string(time, "hh:mm:ss").

num-seq-reg = 1.
num-lis-deb = 0.
cgc-cpf-pag = "096662168000131".
raz-soc-pag = "DREBES E CIA LTDA".
cod-con-pag = 135478.
num-remessa = string(vseqarq,"99999").


put unformatted
    "0"                                   /*Id do registro*/
    cod-con-pag format "99999999"         /*Cod Comunica*/
    2           format "9"                /*Tipo InsEmpPag*/
    cgc-cpf-pag format "x(15)"            /*CNPJ Emp Pagadora*/
    raz-soc-pag format "x(40)"            /*Razao Social paga*/
    20          format "99"               /*Tipo Serviço"*/
    1           format "9"                /*Origem do arquivo*/
    num-remessa format "x(5)"             /*Numero remessa*/ 
    "00000"     format "99999"            /*Numero retorno*/
    year(today) format "9999"             /*Data gravação*/
    month(today) format "99"
    day(today)  format "99"
    substr(vtime, 1, 2)                   /*Hora gravação*/
    substr(vtime, 4, 2)
    substr(vtime, 7, 2)
    ""          format "x(5)"             /*Densidade gravação*/
    ""          format "x(3)"             /*Unidade da densidade*/
    ""          format "x(5)"             /*Ident modulo micro*/
    0           format "9"                /*Tipo processamento*/
    ""          format "x(74)"            /*Reservado empresa*/
    ""          format "x(80)"            /*Reservado banco*/
    ""          format "x(217)"           /*Reservado banco*/
    num-lis-deb format ">>>>>>>>>"        /*Numero lista debito*/
    ""          format "x(8)"             /*Reservado banco*/
    num-seq-reg format "999999"           /*Sequencial do registro*/
    skip.

qtd-registros = 1.
tot-val-pag = 0.
def var vtitvlcob as char.
def var vsaldo like titulo.titvlcob.
def var vchar as char.
def var vdatadesconto as char format "x(8)".

for each lotcretit of lotcre where lotcretit.ltsituacao = yes
                               and lotcretit.ltvalida   = ""
                             exclusive,
                      last titulo where titulo.empcod = wempre.empcod
                                  and titulo.titnat = lotcretp.titnat
                                  and titulo.modcod = lotcretit.modcod
                                  and titulo.etbcod = lotcretit.etbcod
                                  and titulo.clifor = lotcretit.clfcod
                                  and titulo.titnum = lotcretit.titnum
                                  and titulo.titpar = lotcretit.titpar
                                no-lock
                   break by lotcretit.spcetbcod /***titulo.etbcod***/
                         by titulo.clifor.

    find lotcreag of lotcretit no-lock.
    if lotcreag.ltsituacao <> yes /* desmarcado */ or
       lotcreag.ltvalida   <> ""  /* invalido */
    then next.

    find forne where forne.forcod = lotcretit.clfcod no-lock.
    find titulo2 of titulo no-lock.

    if titulo2.modpag = 31
    then do:
        if acha("Bar", titulo2.codbarras) <> ? 
        then do.
            vbarcode = acha("Bar", titulo2.codbarras).
            if length(vbarcode) = 44
            then do:
                assign
                    vbancod = substr(vbarcode,  1,  3)
                    vmoeda  = substr(vbarcode,  4,  1)
                    vdac    = substr(vbarcode,  5,  1)
                    vfatorv = substr(vbarcode,  6,  4)
                    vvalor  = substr(vbarcode, 10, 10)
                    vlivre  = substr(vbarcode, 20, 25)
                    vdv123  = ""
                    num-carteira = int(substr(vbarcode,24,2))
                    nosso-numero = 
                        string(dec(substr(vbarcode,26,11)),"999999999999")
                    .

                if vbancod = "237"
                then assign
                    banco-forne = int(vbancod)
                    agencia-forne = int(substr(vbarcode,20,4))
                    digito-agencia = 
                        string(digitomodulo11p2a7(string(agencia-forne),
                                           input-output par-dv10))
                    conta-forne = int(substr(vbarcode,37,7))
                    digito-conta = 
                        string(digitomodulo11p2a7(string(conta-forne),
                                           input-output par-dv10))
                    tipo-conta = 1
                    .
            end.
            else if length(vbarcode) = 47
            then do:
                assign
                    vbancod = substr(vbarcode,  1,  3)
                    vmoeda  = substr(vbarcode,  4,  1)
                    vdac    = substr(vbarcode, 33,  1)
                    vfatorv = substr(vbarcode, 34,  4)
                    vvalor  = substr(vbarcode, 38, 10)
                    vlivre  = substr(vbarcode,  5,  5) +
                        substr(vbarcode, 11, 10) +
                        substr(vbarcode, 22, 10)
                    vdv123  = substr(vbarcode, 10, 1) +
                        substr(vbarcode, 21, 1)+
                        substr(vbarcode, 32, 1)
                    num-carteira = int(substr(vbarcode,11,1))
                    nosso-numero = string(dec(substr(vbarcode,12,1) +
                    substr(vbarcode,22,2)),"999999999999")
                    .
                if vbancod = "237"
                then assign
                    banco-forne = int(vbancod)
                    agencia-forne = int(substr(vbarcode,5,4))
                    digito-agencia = 
                        string(digitomodulo11p2a7(string(agencia-forne),
                                           input-output par-dv10))
                    conta-forne = int(substr(vbarcode,24,7))
                    digito-conta = 
                        string(digitomodulo11p2a7(string(conta-forne),
                                           input-output par-dv10))
                    tipo-conta = 1
                    .
            end.
            else next.
        end.
        else if acha("Dig", titulo2.codbarras) <> ?
        then do:
            vbarcode = acha("Dig", titulo2.codbarras).
            
            if length(vbarcode) = 44
            then do:
                assign
                    vbancod = substr(vbarcode,  1,  3)
                    vmoeda  = substr(vbarcode,  4,  1)
                    vdac    = substr(vbarcode,  5,  1)
                    vfatorv = substr(vbarcode,  6,  4)
                    vvalor  = substr(vbarcode, 10, 10)
                    vlivre  = substr(vbarcode, 20, 25)
                    vdv123  = ""
                    num-carteira = int(substr(vbarcode,24,2))
                    nosso-numero = 
                        string(dec(substr(vbarcode,26,11)),"999999999999")
                    .

                if vbancod = "237"
                then assign
                    banco-forne = int(vbancod)
                    agencia-forne = int(substr(vbarcode,20,4))
                    digito-agencia = 
                        string(digitomodulo11p2a7(string(agencia-forne),
                                           input-output par-dv10))
                    conta-forne = int(substr(vbarcode,37,7))
                    digito-conta = 
                        string(digitomodulo11p2a7(string(conta-forne),
                                           input-output par-dv10))
                    tipo-conta = 1
                    .
            end.
            else if length(vbarcode) = 47
            then do:
                assign
                    vbancod = substr(vbarcode,  1,  3)
                    vmoeda  = substr(vbarcode,  4,  1)
                    vdac    = substr(vbarcode, 33,  1)
                    vfatorv = substr(vbarcode, 34,  4)
                    vvalor  = substr(vbarcode, 38, 10)
                    vlivre  = substr(vbarcode,  5,  5) +
                        substr(vbarcode, 11, 10) +
                        substr(vbarcode, 22, 10)
                    vdv123  = substr(vbarcode, 10, 1) +
                        substr(vbarcode, 21, 1)+
                        substr(vbarcode, 32, 1)
                    num-carteira = int(substr(vbarcode,11,1))
                    nosso-numero = string(dec(substr(vbarcode,12,1) +
                    substr(vbarcode,22,2)),"999999999999")
                    .
                if vbancod = "237"
                then assign
                    banco-forne = int(vbancod)
                    agencia-forne = int(substr(vbarcode,5,4))
                    digito-agencia = 
                        string(digitomodulo11p2a7(string(agencia-forne),
                                           input-output par-dv10))
                    conta-forne = int(substr(vbarcode,24,7))
                    digito-conta = 
                        string(digitomodulo11p2a7(string(conta-forne),
                                           input-output par-dv10))
                    tipo-conta = 1
                    .
            end.
            else next.
        end.
        else next.
    end.
    
    assign
        aux-fornom = ""
        aux-cgccpf = "" 
        tipo-conta = 0.
    find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
    if avail forconpg
    then assign
             banco-forne = forconpg.numban
             agencia-forne = int(forconpg.numagen)
             digito-agencia = forconpg.digitoagen
             conta-forne = int(forconpg.numcon)
             digito-conta = forconpg.digitocon
             tipo-conta = forconpg.tipoconta
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             .
    else do:
        if acha("CGCCPF",titulo2.char1) <> ? and
           acha("NOMERZ",titulo2.char1) <> ? and
           titulo2.titbanpag > 0
        then do: 
            assign
                 aux-fornom = acha("NOMERZ",titulo2.char1)
                 aux-cgccpf = acha("CGCCPF",titulo2.char1)
                 banco-forne = titulo2.titbanpag
                 agencia-forne = int(entry(1,titulo2.titagepag,"-"))
                 digito-agencia = entry(2,titulo2.titagepag,"-")
                 conta-forne = int(entry(1,titulo2.titconpag,"-"))
                 digito-conta = entry(2,titulo2.titconpag,"-")
                 tipo-conta = titulo2.int1
                 .
        end.
        else do:                                  
            banco-forne = int(vbancod).
            if banco-forne <> 237
            then 
            assign        
                aux-fornom = forne.fornom
                aux-cgccpf = forne.forcgc
                agencia-forne = 0 
                digito-agencia = ""
                conta-forne = 0 
                digito-conta = ""
                tipo-conta = 1
                .
        end.            
    end.         
    if banco-forne = 237
    then.
    else assign
            nosso-numero = "000000000000"
            num-carteira = 0
            .

    num-pagamento = titulo.titnum.
    fator-vencimento = int(vfatorv).
    
    mod-pagamento = 31.
    if titulo2.modpag <> 0 and titulo2.modpag <> 31
    then mod-pagamento = titulo2.modpag .
    
    valor-documento = vvalor.

    info-compl = vlivre + vdac + vmoeda.
    
    for-cgc-cpf = trim(forne.forcgc).
     
    if aux-fornom = "" 
    then aux-fornom = forne.fornom.
    if aux-cgccpf = ""
    then aux-cgccpf = trim(forne.forcgc).
    if aux-cgccpf <> "" and
        trim(aux-cgccpf) <> for-cgc-cpf
    then for-cgc-cpf = trim(aux-cgccpf).

    if titulo2.modpag = 8 or
       titulo2.modpag = 3 
    then do:
        run agrupa-doc-ted.
    end.
    else if titulo2.modpag = 31
    then do:
        run agrupa-boleto.
    end.
    else do:
    if titulo2.modpag = 8 or
       titulo2.modpag = 3 or
       titulo2.modpag = 1 or
       titulo2.modpag = 5  /*DOC ou TED ou CREDITO EM CONTA*/
    then assign
            valor-documento = "0000000000"
            fator-vencimento = 0
            info-compl = "C00000001" + string(tipo-conta,"99")
            nosso-numero = "000000000000"
            num-carteira = 0
             .
            
    if titulo2.modpag = 1 or
       titulo2.modpag = 5 /*CREDITO EM CONTA*/  
    then assign
            info-compl = ""
            tipo-conta-for = tipo-conta.
    
    vsaldo = (titulo.titvlcob + titulo.titvljur - titulo.titvldes)
                        - titulo.titvlpag.
    valor-cobrado = string(titulo.titvlcob,"99999999.99").
    valor-cobrado = replace(valor-cobrado,".","").                    
    vtitvlcob = string(vsaldo,"9999999999999.99").
    vtitvlcob = replace(vtitvlcob,".","").
    vtitvljur = string(titvljur,"9999999999999.99").
    vtitvljur = replace(vtitvljur,".","").
    vtitvldes = string(titvldes,"9999999999999.99").
    vtitvldes = replace(vtitvldes,".","").
 
    if  int(valor-documento) > 0 and
        valor-documento <> valor-cobrado
    then valor-documento = valor-cobrado.
    
    num-seq-reg = num-seq-reg + 1.
     
    num-pagamento = string(lotcre.ltcrecod) + string(num-seq-reg,"999999").
     
    for-cgc-cpf = trim(forne.forcgc).
     
    if aux-fornom = "" 
    then aux-fornom = forne.fornom.
    if aux-cgccpf <> "" and
        trim(aux-cgccpf) <> for-cgc-cpf
    then for-cgc-cpf = trim(aux-cgccpf).

    if length(for-cgc-cpf) = 14
    then 
        assign
            tipo-insc-for = 2
            for-cgc-cpf = "0" + for-cgc-cpf. 
    else if length(for-cgc-cpf) = 11
    then 
        assign
            tipo-insc-for = 1
            for-cgc-cpf = substr(for-cgc-cpf,1,9) + "0000" +
                          substr(for-cgc-cpf,10,2) .
    else next.
    
    if vtitdtpag = ?
    then vtitdtpag = titulo.titdtven.
    
    if int(vtitvldes) > 0
    then vdatadesconto = string(year(vtitdtpag),"9999") +
                         string(month(vtitdtpag),"99") +
                         string(day(vtitdtpag),"99")
                          .
    else vdatadesconto = "00000000".
                          
    put unformatted
        1               format "9"          /*Identificacao*/
        tipo-insc-for   format "9"          /*Tipo inscrição*/ 
        for-cgc-cpf     format "x(15)"      /*CNPJ/CPF"  */
        aux-fornom /*forne.fornom*/    format "x(30)"      /*Razao social*/
        forne.forrua    format "x(40)"      /*Endereço*/
        forne.forcep    format "99999999"   /*CEP fornecedor*/
        banco-forne     format "999"        /*Banco forne*/
        agencia-forne   format "99999"      /*Agencia forne*/
        digito-agencia  format "x"          /*Digito agencia*/
        conta-forne     format "9999999999999" /*conta forne*/
        digito-conta    format "xx"             /*digito conta*/
        num-pagamento   format "x(16)"        /*numero pagamento*/
        num-carteira    format "999"          /*carteira*/
        nosso-numero    format "x(12)"        /*Nosso numero*/
        seu-numero      format "x(15)"        /*seu numero*/
        year(titulo.titdtven) format "9999"   /*Data Vencimento*/
        month(titulo.titdtven) format "99"
        day(titulo.titdtven) format "99" 
        year(titulo.titdtemi) format "9999"   /*Data Emissao*/
        month(titulo.titdtemi) format "99"
        day(titulo.titdtemi) format "99"
        vdatadesconto        format "x(8)"   /*Data Limite para desconto*/
        "0"                   format "x"
        fator-vencimento      format "9999"   /*Fator Vencimento*/
        valor-documento       format "x(10)" /*Valor do documento*/
        vtitvlcob             format "x(15)"  /*Valor do pagamento*/
        vtitvldes
        /*"000000000000000"*/     format "x(15)"   /*Valor desconto*/
        vtitvljur
        /*"000000000000000"*/     format "x(15)"   /*Valor do acrescimo*/
        "01"                  format "x(2)"    /*Tipo de documento*/
        int(titulo.titnum)    format "9999999999"  /*Numero documento*/
        ""                    format "x(2)"        /*Serie*/
        mod-pagamento         format "99"         /*Modalidade pagamento*/
        year(vtitdtpag) format "9999"   /*Data efetivação pagamento*/
        month(vtitdtpag) format "99"
        day(vtitdtpag) format "99" 
        ""                    format "x(3)"       /*Moeda*/
        "01"                  format "x(2)"       /*Situaçao agendamento*/
        "          "          format "x(10)"      /*Brancos*/
        "0"                   format "x"          /*Tipo de movimento*/
        "00"                  format "xx"         /*Codigo do movimento*/
        ""                    format "x(4)"       /*horario consulta*/
        ""                    format "x(15)"      /*Saldo disponivel*/
        ""                    format "x(15)"      /*Valo taxa pre funding*/
        ""                    format "x(6)"       /*Reserva*/
        ""                    format "x(40)"      /*Sacador/avalista*/
        ""                    format "x"          /*Reserva*/
        ""                    format "x"          /*Nivel informação retorno*/
        info-compl            format "x(40)" /*Informações complementares*/
        "00"                  format "xx"       /*Codigo de area na empresa*/
        ""                    format "x(35)"    
        ""                    format "x(22)"    /*Reserva*/
        0                     format "99999"    /*Codigo de lançamento*/
        ""                    format "x"        /*Reserva*/
        tipo-conta-for        format "9"        /*Tipo conta fornecedor*/
        0090000               format "9999999"  /*Conta complementar*/
        ""                    format "x(8)"     /*Reserva*/
        num-seq-reg           format "999999"   /*Numero seqeuncia registro*/
        skip.

    /* identificar o arquivo que foi enviado */
    assign
        lotcretit.spcseqproc  = vlotenro /* Nro lote */
        lotcretit.spcseqtrans = vlotereg /* Reg no lote */
        tot-val-pag = tot-val-pag + vsaldo /*titulo.titvlcob*/.
        qtd-registros = qtd-registros + 1.
        vtotreg = vtotreg + 1.
    end.

end.        
    
run envia-agtitbra.
run envia-agtitfor.
        
/*
    Trailler de arquivo
*/

num-seq-reg = num-seq-reg + 1.
qtd-registros = qtd-registros + 1.

put unformatted
    "9"                                       /*Identificacao registro*/
    qtd-registros  format "999999"            /*Quantidade registros" */
    replace(string(tot-val-pag,"999999999999999.99"),".","")
                    format "x(17)"
    /*tot-val-pag    format "99999999999999999" /*Total valores pagamento*/
    */
    ""             format "x(470)"            /*numero sequencial*/
    num-seq-reg format "999999"
    skip.

output close.

do on error undo.
    find current lotcretp exclusive.
    lotcretp.ultimo = lotcretp.ultimo + 1.
    
    find lotcre where recid(lotcre) = par-reclotcre exclusive.
    assign
        lotcre.ltdtenvio = today
        lotcre.lthrenvio = time
        lotcre.ltfnenvio = sfuncod
        lotcre.arqenvio  = varq.
    find titulo2 of titulo exclusive.
    titulo2.dec1 = dec(num-pagamento).
end.
find lotcre where recid(lotcre) = par-reclotcre no-lock.

if opsys = "unix"
then do.
    unix silent unix2dos value(varq).
    unix silent chmod 777 value(varq).
end.

message "Registros gerados: " vtotreg " " varq view-as alert-box.

run ltbradesco-valida-arquivo.p (input recid(lotcre)).

procedure agrupa-doc-ted:
    def var vtipo as char.
    
    find first tabaux where
               tabaux.tabela = "MODALIDADE DE PAGAMENTO" and
               tabaux.nome_campo = string(titulo2.modpag,"99")
               no-lock no-error.
                          
    find first agtitbra where
               agtitbra.ltcrecod = lotcre.ltcrecod and
               agtitbra.clifor = titulo.clifor and
               agtitbra.titdtven = titulo.titdtven and
               agtitbra.modpag = string(titulo2.modpag) 
               no-error.
    if not avail agtitbra
    then do:
        create agtitbra.
        assign
            agtitbra.ltcrecod = lotcre.ltcrecod
            agtitbra.clifor   = titulo2.clifor
            agtitbra.titdtven = titulo.titdtven
            agtitbra.titdtemi = titulo.titdtemi
            agtitbra.modpag   = string(titulo2.modpag)
            agtitbra.codbar   = vbarcode
            agtitbra.bancod   = banco-forne
            agtitbra.agecod   = string(agencia-forne)
            agtitbra.digage   = digito-agencia
            agtitbra.concod   = string(conta-forne)
            agtitbra.digcon   = digito-conta
            agtitbra.tipcon   = string(tipo-conta)
            agtitbra.fornom   = aux-fornom
            agtitbra.cgccpf   = aux-cgccpf
            agtitbra.titnum   = titulo2.titnum
            .
    end.
    assign
        agtitbra.valor-cobrado = agtitbra.valor-cobrado + titulo.titvlcob
        agtitbra.valor-pago    = agtitbra.valor-pago + (titulo.titvlcob + 
                titulo.titvljur  - titulo.titvldes - titulo.titvlpag)
        agtitbra.titvljur      = agtitbra.titvljur + titulo.titvljur
        agtitbra.titvldes      = agtitbra.titvldes + titulo.titvldes
        agtitbra.titvlpag      = agtitbra.titvlpag + titulo.titvlpag
        agtitbra.char1 = agtitbra.char1 + string(recid(lotcretit)) + ";"
        agtitbra.char2 = agtitbra.char2 + string(recid(titulo)) + ";"
        .
            
end procedure.

procedure agrupa-boleto:
    def var vtipo as char.
    
    find first tabaux where
               tabaux.tabela = "MODALIDADE DE PAGAMENTO" and
               tabaux.nome_campo = string(titulo2.modpag,"99")
               no-lock no-error.
                          
    find first agtitfor where
               agtitfor.ltcrecod = lotcre.ltcrecod and
               agtitfor.clifor = titulo.clifor and
               agtitfor.modpag = string(titulo2.modpag) and
               agtitfor.codbar   = vbarcode
               no-error.
    if not avail agtitfor
    then do:
        create agtitfor.
        assign
            agtitfor.ltcrecod = lotcre.ltcrecod
            agtitfor.clifor   = titulo2.clifor
            agtitfor.titdtven = titulo.titdtven
            agtitfor.titdtemi = titulo.titdtemi
            agtitfor.modpag   = string(titulo2.modpag)
            agtitfor.codbar   = vbarcode /*titulo2.codbarras*/
            agtitfor.bancod   = banco-forne
            agtitfor.agecod   = string(agencia-forne)
            agtitfor.digage   = digito-agencia
            agtitfor.concod   = string(conta-forne)
            agtitfor.digcon   = digito-conta
            agtitfor.tipcon   = string(tipo-conta)
            agtitfor.fornom   = aux-fornom
            agtitfor.cgccpf   = aux-cgccpf
            agtitfor.titnum   = titulo2.titnum
            agtitfor.char3 = "FATOR-VENCIMENTO=" + string(fator-vencimento)
                             + "|" +
                             "INFO-COMPL=" + info-compl + "|" +
                             "NOSSO-NUMERO=" + nosso-numero + "|" +
                             "NUM-CARTEIRA=" + string(num-carteira) + "|" 
                             .
    end.
    assign
        agtitfor.cgccpf   = aux-cgccpf
        agtitfor.valor-cobrado = agtitfor.valor-cobrado + titulo.titvlcob
        agtitfor.valor-pago    = agtitfor.valor-pago + (titulo.titvlcob + 
                titulo.titvljur  - titulo.titvldes - titulo.titvlpag)
        agtitfor.titvljur      = agtitfor.titvljur + titulo.titvljur
        agtitfor.titvldes      = agtitfor.titvldes + titulo.titvldes
        agtitfor.titvlpag      = agtitfor.titvlpag + titulo.titvlpag
        agtitfor.char1 = agtitfor.char1 + string(recid(lotcretit)) + ";"
        agtitfor.char2 = agtitfor.char2 + string(recid(titulo)) + ";"
        .
               
    
            
end procedure.
                           
procedure envia-agtitbra:

    def var lt as int.
    for each agtitbra where
             agtitbra.ltcrecod = lotcre.ltcrecod
             no-lock:

        do lt = 1 to int(num-entries(agtitbra.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitbra.char1,";")).
        end.
        
        do lt = 1 to int(num-entries(agtitbra.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitbra.char2,";")).
        end.      
           
        assign          
            for-cgc-cpf = agtitbra.cgccpf
            aux-fornom  = agtitbra.fornom
            banco-forne = agtitbra.bancod
            agencia-forne = int(agtitbra.agecod)
            digito-agencia = agtitbra.digage
            conta-forne = int(agtitbra.concod)
            digito-conta = agtitbra.digcon
            tipo-conta = int(agtitbra.tipcon)
            valor-documento = "0000000000"
            fator-vencimento = 0
            info-compl = "C00000001" + string(tipo-conta,"99")
            nosso-numero = "000000000000"
            num-carteira = 0
            num-seq-reg = num-seq-reg + 1
            num-pagamento = string(lotcre.ltcrecod) + 
                    string(num-seq-reg,"999999")
            mod-pagamento = int(agtitbra.modpag)
            .
        
        if agtitbra.modpag = "31"
        then do:
            if acha("FATOR-VENCIMENTO",agtitbra.char3) <> ?
            then fator-vencimento =                     int(acha("FATOR-VENCIMENTO",agtitbra.char3)).
            if acha("INFO-COMPL",agtitbra.char3) <> ?
            then info-compl = acha("INFO-COMPL",agtitbra.char3).
            if acha("NOSSO-NUMERO",agtitbra.char3) <> ?
            then nosso-numero = acha("NOSSO-NUMERO",agtitbra.char3).
            if acha("NUM-CARTEIRA",agtitbra.char3) <> ?
            then num-carteira = int(acha("NUM-CARTEIRA",agtitbra.char3)).
        end.
        
        assign    
            vsaldo    = agtitbra.valor-pago
            valor-cobrado = string(agtitbra.valor-cobrado,"99999999.99")
            valor-cobrado = replace(valor-cobrado,".","")                    
            vtitvlcob = string(vsaldo,"9999999999999.99")
            vtitvlcob = replace(vtitvlcob,".","")
            vtitvljur = string(agtitbra.titvljur,"9999999999999.99")
            vtitvljur = replace(vtitvljur,".","")
            vtitvldes = string(agtitbra.titvldes,"9999999999999.99")
            vtitvldes = replace(vtitvldes,".","")
            seu-numero = agtitbra.titnum
            .
 
        if valor-documento <> valor-cobrado
        then valor-documento = valor-cobrado.
    
    
        if vtitdtpag = ?
        then vtitdtpag = agtitbra.titdtven.
    
        if int(vtitvldes) > 0
        then vdatadesconto = string(year(vtitdtpag),"9999") +
                         string(month(vtitdtpag),"99") +
                         string(day(vtitdtpag),"99")
                          .
        else vdatadesconto = "00000000".

        if length(for-cgc-cpf) = 14
        then  assign
            tipo-insc-for = 2
            for-cgc-cpf = "0" + for-cgc-cpf. 
        else if length(for-cgc-cpf) = 11
        then  assign
            tipo-insc-for = 1
            for-cgc-cpf = substr(for-cgc-cpf,1,9) + "0000" +
                          substr(for-cgc-cpf,10,2) .
        else next.
        
        find forne where forne.forcod = agtitbra.clifor no-lock no-error.
        if not avail forne then next.
                      
        put unformatted
        1               format "9"          /*Identificacao*/
        tipo-insc-for   format "9"          /*Tipo inscrição*/ 
        for-cgc-cpf     format "x(15)"      /*CNPJ/CPF"  */
        aux-fornom /*forne.fornom*/    format "x(30)"      /*Razao social*/
        forne.forrua    format "x(40)"      /*Endereço*/
        forne.forcep    format "99999999"   /*CEP fornecedor*/
        banco-forne     format "999"        /*Banco forne*/
        
        agencia-forne   format "99999"      /*Agencia forne*/
        digito-agencia  format "x"          /*Digito agencia*/
        conta-forne     format "9999999999999" /*conta forne*/
        digito-conta    format "xx"             /*digito conta*/
        num-pagamento   format "x(16)"        /*numero pagamento*/
        num-carteira    format "999"          /*carteira*/
        nosso-numero    format "x(12)"        /*Nosso numero*/
        seu-numero      format "x(15)"        /*seu numero*/
        year(agtitbra.titdtven) format "9999"   /*Data Vencimento*/
        month(agtitbra.titdtven) format "99"
        day(agtitbra.titdtven) format "99" 
        year(agtitbra.titdtemi) format "9999"   /*Data Emissao*/
        month(agtitbra.titdtemi) format "99"
        day(agtitbra.titdtemi) format "99"
        vdatadesconto        format "x(8)"   /*Data Limite para desconto*/
        "0"                   format "x"
        fator-vencimento      format "9999"   /*Fator Vencimento*/
        valor-documento       format "x(10)" /*Valor do documento*/
        vtitvlcob             format "x(15)"  /*Valor do pagamento*/
        vtitvldes
        /*"000000000000000"*/     format "x(15)"   /*Valor desconto*/
        vtitvljur
        /*"000000000000000"*/     format "x(15)"   /*Valor do acrescimo*/
        "01"                  format "x(2)"    /*Tipo de documento*/
        int(agtitbra.titnum)    format "9999999999"  /*Numero documento*/
        ""                    format "x(2)"        /*Serie*/
        mod-pagamento         format "99"         /*Modalidade pagamento*/
        year(vtitdtpag) format "9999"   /*Data efetivação pagamento*/
        month(vtitdtpag) format "99"
        day(vtitdtpag) format "99" 
        ""                    format "x(3)"       /*Moeda*/
        "01"                  format "x(2)"       /*Situaçao agendamento*/
        "          "          format "x(10)"      /*Brancos*/
        "0"                   format "x"          /*Tipo de movimento*/
        "00"                  format "xx"         /*Codigo do movimento*/
        ""                    format "x(4)"       /*horario consulta*/
        ""                    format "x(15)"      /*Saldo disponivel*/
        ""                    format "x(15)"      /*Valo taxa pre funding*/
        ""                    format "x(6)"       /*Reserva*/
        ""                    format "x(40)"      /*Sacador/avalista*/
        ""                    format "x"          /*Reserva*/
        ""                    format "x"          /*Nivel informação retorno*/
        info-compl            format "x(40)" /*Informações complementares*/
        "00"                  format "xx"       /*Codigo de area na empresa*/
        ""                    format "x(35)"    
        ""                    format "x(22)"    /*Reserva*/
        0                     format "99999"    /*Codigo de lançamento*/
        ""                    format "x"        /*Reserva*/
        tipo-conta-for        format "9"        /*Tipo conta fornecedor*/
        0090000               format "9999999"  /*Conta complementar*/
        ""                    format "x(8)"     /*Reserva*/
        num-seq-reg           format "999999"   /*Numero seqeuncia registro*/
        skip.

        /* identificar o arquivo que foi enviado */
    
        assign
            lotcretit.spcseqproc  = vlotenro /* Nro lote */
            lotcretit.spcseqtrans = vlotereg /* Reg no lote */
            tot-val-pag = tot-val-pag + vsaldo /*titulo.titvlcob*/.
            qtd-registros = qtd-registros + 1.
            vtotreg = vtotreg + 1.
    end.

end procedure.

procedure envia-agtitfor:

    def var lt as int.
    for each agtitfor where
             agtitfor.ltcrecod = lotcre.ltcrecod
             no-lock:

        do lt = 1 to int(num-entries(agtitfor.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitfor.char1,";")).
        end.
        
        do lt = 1 to int(num-entries(agtitfor.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitfor.char2,";")).
        end.      
           
        assign          
            for-cgc-cpf = agtitfor.cgccpf
            aux-fornom  = agtitfor.fornom
            banco-forne = agtitfor.bancod
            agencia-forne = int(agtitfor.agecod)
            digito-agencia = agtitfor.digage
            conta-forne = int(agtitfor.concod)
            digito-conta = agtitfor.digcon
            tipo-conta = int(agtitfor.tipcon)
            valor-documento = "0000000000"
            fator-vencimento = 0
            info-compl = "C00000001" + string(tipo-conta,"99")
            nosso-numero = "000000000000"
            num-carteira = 0
            num-seq-reg = num-seq-reg + 1
            num-pagamento = string(lotcre.ltcrecod) + 
                    string(num-seq-reg,"999999")
            mod-pagamento = int(agtitfor.modpag)
            .
        
        if agtitfor.modpag = "31"
        then do:
            if acha("FATOR-VENCIMENTO",agtitfor.char3) <> ?
            then fator-vencimento =                     int(acha("FATOR-VENCIME~NTO",agtitfor.char3)).
            if acha("INFO-COMPL",agtitfor.char3) <> ?
            then info-compl = acha("INFO-COMPL",agtitfor.char3).
            if acha("NOSSO-NUMERO",agtitfor.char3) <> ?
            then nosso-numero = acha("NOSSO-NUMERO",agtitfor.char3).
            if acha("NUM-CARTEIRA",agtitfor.char3) <> ?
            then num-carteira = int(acha("NUM-CARTEIRA",agtitfor.char3)).
        end.
        
        assign    
            vsaldo    = agtitfor.valor-pago
            valor-cobrado = string(agtitfor.valor-cobrado,"99999999.99")
            valor-cobrado = replace(valor-cobrado,".","")                    
            vtitvlcob = string(vsaldo,"9999999999999.99")
            vtitvlcob = replace(vtitvlcob,".","")
            vtitvljur = string(agtitfor.titvljur,"9999999999999.99")
            vtitvljur = replace(vtitvljur,".","")
            vtitvldes = string(agtitfor.titvldes,"9999999999999.99")
            vtitvldes = replace(vtitvldes,".","")
            seu-numero = agtitfor.titnum
            .
 
        if valor-documento <> valor-cobrado
        then valor-documento = valor-cobrado.
    
    
        if vtitdtpag = ?
        then vtitdtpag = agtitfor.titdtven.
    
        if int(vtitvldes) > 0
        then vdatadesconto = string(year(vtitdtpag),"9999") +
                         string(month(vtitdtpag),"99") +
                         string(day(vtitdtpag),"99")
                          .
        else vdatadesconto = "00000000".

        if length(for-cgc-cpf) = 14
        then  assign
            tipo-insc-for = 2
            for-cgc-cpf = "0" + for-cgc-cpf. 
        else if length(for-cgc-cpf) = 11
        then  assign
            tipo-insc-for = 1
            for-cgc-cpf = substr(for-cgc-cpf,1,9) + "0000" +
                          substr(for-cgc-cpf,10,2) .
        else next.
        
        find forne where forne.forcod = agtitfor.clifor no-lock no-error.
        if not avail forne then next.
                      
        put unformatted
        1               format "9"          /*Identificacao*/
        tipo-insc-for   format "9"          /*Tipo inscrição*/ 
        for-cgc-cpf     format "x(15)"      /*CNPJ/CPF"  */
        aux-fornom /*forne.fornom*/    format "x(30)"      /*Razao social*/
        forne.forrua    format "x(40)"      /*Endereço*/
        forne.forcep    format "99999999"   /*CEP fornecedor*/
        banco-forne     format "999"        /*Banco forne*/
        
        agencia-forne   format "99999"      /*Agencia forne*/
        digito-agencia  format "x"          /*Digito agencia*/
        conta-forne     format "9999999999999" /*conta forne*/
        digito-conta    format "xx"             /*digito conta*/
        num-pagamento   format "x(16)"        /*numero pagamento*/
        num-carteira    format "999"          /*carteira*/
        nosso-numero    format "x(12)"        /*Nosso numero*/
        seu-numero      format "x(15)"        /*seu numero*/
        year(agtitfor.titdtven) format "9999"   /*Data Vencimento*/
        month(agtitfor.titdtven) format "99"
        day(agtitfor.titdtven) format "99" 
        year(agtitfor.titdtemi) format "9999"   /*Data Emissao*/
        month(agtitfor.titdtemi) format "99"
        day(agtitfor.titdtemi) format "99"
        vdatadesconto        format "x(8)"   /*Data Limite para desconto*/
        "0"                   format "x"
        fator-vencimento      format "9999"   /*Fator Vencimento*/
        valor-documento       format "x(10)" /*Valor do documento*/
        vtitvlcob             format "x(15)"  /*Valor do pagamento*/
        vtitvldes
        /*"000000000000000"*/     format "x(15)"   /*Valor desconto*/
        vtitvljur
        /*"000000000000000"*/     format "x(15)"   /*Valor do acrescimo*/
        "01"                  format "x(2)"    /*Tipo de documento*/
        int(agtitfor.titnum)    format "9999999999"  /*Numero documento*/
        ""                    format "x(2)"        /*Serie*/
        mod-pagamento         format "99"         /*Modalidade pagamento*/
        year(vtitdtpag) format "9999"   /*Data efetivação pagamento*/
        month(vtitdtpag) format "99"
        day(vtitdtpag) format "99" 
        ""                    format "x(3)"       /*Moeda*/
        "01"                  format "x(2)"       /*Situaçao agendamento*/
        "          "          format "x(10)"      /*Brancos*/
        "0"                   format "x"          /*Tipo de movimento*/
        "00"                  format "xx"         /*Codigo do movimento*/
        ""                    format "x(4)"       /*horario consulta*/
        ""                    format "x(15)"      /*Saldo disponivel*/
        ""                    format "x(15)"      /*Valo taxa pre funding*/
        ""                    format "x(6)"       /*Reserva*/
        ""                    format "x(40)"      /*Sacador/avalista*/
        ""                    format "x"          /*Reserva*/
        ""                    format "x"          /*Nivel informação retorno*/
        info-compl            format "x(40)" /*Informações complementares*/
        "00"                  format "xx"       /*Codigo de area na empresa*/
        ""                    format "x(35)"    
        ""                    format "x(22)"    /*Reserva*/
        0                     format "99999"    /*Codigo de lançamento*/
        ""                    format "x"        /*Reserva*/
        tipo-conta-for        format "9"        /*Tipo conta fornecedor*/
        0090000               format "9999999"  /*Conta complementar*/
        ""                    format "x(8)"     /*Reserva*/
        num-seq-reg           format "999999"   /*Numero seqeuncia registro*/
        skip.

        /* identificar o arquivo que foi enviado */
    
        assign
            lotcretit.spcseqproc  = vlotenro /* Nro lote */
            lotcretit.spcseqtrans = vlotereg /* Reg no lote */
            tot-val-pag = tot-val-pag + vsaldo /*titulo.titvlcob*/.
            qtd-registros = qtd-registros + 1.
            vtotreg = vtotreg + 1.
    end.

end procedure.

