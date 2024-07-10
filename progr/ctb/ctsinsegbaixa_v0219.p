{admcab.i}

def temp-table tt-contsel
    field marca as char format "x"
    field clifor like clien.clicod format ">>>>>>>>>9"
    field contnum like contrato.contnum format ">>>>>>>>>9"
    field dtinicial like contrato.dtinicial
    field val-sal as dec
    .
def temp-table tt-titsel like titulo.
 
def temp-table tt-arqimp
    field segurado as char       format "x(30)"
    field cpf as char            format "x(15)"
    field certificado as char    format "x(21)"
    field saldo as char          format "x(15)"
    field pagamento as char          format "x(13)"
    field programado as char     format "x(10)"
    field estatus     as char     format "x(30)"
    field saldo-devedor as dec
    field valor-baixar as char
    field ocorrencia as char     format "x(10)"
    field tipo as char           format "x(15)"
    field observacao as char     format "x(30)"
    field sit as char            format "x(15)"
    field filial as char
    field cliente as char format "x(12)"
    field contrato as char format "x(12)"
    field valor-pago as dec
    field dif as dec
    index i1 sit dif
    .

def temp-table tt-validar
    field campo as char format "x(75)"
    field valor as char format "x(75)"
    .

def temp-table tt-titulo like titulo.
 
def var val-baixar as dec.
def var val-baixado as dec.
def var vdir-recebe as char.
def var vdir-envia  as char.
def var vdir-baixa  as char.
def var vdir-bkprecebe as char.
def var vdir-bkpenvia  as char.
def var vdir-bkpbaixa  as char.
def var varq-recebe as char format "x(15)".
def var varq-envia  as char format "x(15)".
def var varq-baixa  as char format "x(25)".

assign
    vdir-recebe = "/admcom/seguro/sinistro/recebe/"
    vdir-envia  = "/admcom/seguro/sinistro/envia/"
    vdir-baixa  = "/admcom/seguro/sinistro/baixa/"
    vdir-bkprecebe = "/admcom/seguro/sinistro/backup/bkprecebe/"
    vdir-bkpenvia  = "/admcom/seguro/sinistro/backup/bkpenvia/"
    vdir-bkpbaixa  = "/admcom/seguro/sinistro/backup/bkpbaixa/"
    .

def var vlinha as char.
def var varquivo as char format "x(60)".
disp replace(vdir-baixa,"/admcom","l:")
        label "Arquivo" format "x(25)" space(0)  with frame f1.
update varq-baixa no-label with frame f1 1 down width 75 side-label.

varquivo = vdir-baixa + varq-baixa + ".csv".

if search(varquivo) = ?
then do:
    message color red/with
    "Arquivo não encontrado."
    view-as alert-box.
    return.
end.
def var vok-arq as log.
vok-arq = no. 
input from value(varquivo).
repeat:
    import unformatted vlinha.
    vok-arq = yes.
    if num-entries(vlinha,";") <> 7
    then do:
        vok-arq = no.
        leave.
    end.
end.
input close.

if vok-arq = no
then do:
    message color red/with
    "Arquivo com problema no layout."
    view-as alert-box.
    return.
end.

input from value(varquivo).
repeat:
    create tt-arqimp.
    import delimiter ";" tt-arqimp.
end.
input close.
def var vi as int.
def var va as char format "x(20)".
for each tt-arqimp :
    va = "".
    do vi = 1 to 25:
        if substr(certificado,vi,1) = "0" or
             substr(certificado,vi,1) = "1" or
              substr(certificado,vi,1) = "2" or
               substr(certificado,vi,1) = "3" or
                substr(certificado,vi,1) = "4" or
                 substr(certificado,vi,1) = "5" or
                  substr(certificado,vi,1) = "6" or
                   substr(certificado,vi,1) = "7" or
                    substr(certificado,vi,1) = "8" or
                     substr(certificado,vi,1) = "9"
        then va = va + substr(certificado,vi,1).
    end.
    if va <> ""
    then do:
        certificado = va.
        if length(certificado) < 20
        then do:
            message color red/with
            "Problema no arquivo." skip
            "Certificado invalido: " certificado
            view-as alert-box.
            return.
        end. 
    end.
    else delete tt-arqimp.
end.


def var vtotal as dec.

for each tt-arqimp:
    if tt-arqimp.cpf = "CPF" or
       tt-arqimp.cpf = "" 
    then delete tt-arqimp.
    else do:
        assign
        /*tt-arqimp.saldo = string(0,">>>,>>9.99")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,".",",")*/
        tt-arqimp.certificado = 
        replace(tt-arqimp.certificado,"'","")
        tt-arqimp.valor-baixar = replace(tt-arqimp.pagamento,"R$ ","")
        tt-arqimp.valor-baixar = replace(tt-arqimp.valor-baixar,".","")
        tt-arqimp.valor-baixar = replace(tt-arqimp.valor-baixar,",",".")
        vtotal = vtotal + dec(tt-arqimp.valor-baixar)
        .
        vi = (11 - length(trim(tt-arqimp.cpf))).
        if vi > 0
        then repeat:
            tt-arqimp.cpf = "0" + tt-arqimp.cpf.
            vi = vi - 1.
            if vi = 0 then leave.
        end.
    end.
end.

unix silent value("cp " + varquivo + " " + vdir-bkpbaixa).

{setbrw.i}                                                                      

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["  Consulta","  Validar","  Baixa ","  Baixa Geral","  Sobras"].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form 
     tt-arqimp.sit no-label format "x"
     tt-arqimp.certificado
     tt-arqimp.cpf
     tt-arqimp.saldo      format "x(12)"
     tt-arqimp.pagamento
     tt-arqimp.programado format "x(10)"
     with frame f-linha 12 down color with/cyan /*no-box*/
     width 80.
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.

run saldo-devedor.

l1: repeat:
    clear frame f-com1 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    pause 0.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    color display message esqcom1[esqpos1] with frame f-com1.
    disp vtotal label "Total pagamento"
        with frame f-tot row 21 side-label no-box overlay.
    pause 0.    

    {sklclstb.i  
        &color = with/cyan
        &file = tt-arqimp  
        &cfield = tt-arqimp.certificado
        &noncharacter = /*                          */
        &ofield = " tt-arqimp.sit
                    tt-arqimp.cpf
                    tt-arqimp.saldo
                    tt-arqimp.pagamento
                    tt-arqimp.programado
                    "  
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        /*if esqcom1[esqpos1] = ""  Validar"" or
                           esqcom1[esqpos1] = ""  Saldo devedor"" or
                           esqcom1[esqpos1] = ""  Gera arquivo""
                        then do:
                            color display normal esqcom1[esqpos1] 
                            with frame f-com1.
                            next l1.
                        end.
                        else*/ do:
                            next keys-loop. 
                        end.    
                            "
        &go-on = TAB 
        &naoexiste1 = " leave l1. " 
        &otherkeys1 = " run controle. "
        &locktype = " use-index i1"
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    if esqcom1[esqpos1] = "  Validar"
    THEN DO on error undo:
        run validar-dados.
    END.
    if esqcom1[esqpos1] = "  Saldo devedor"
    THEN DO:
        run saldo-devedor.
    END.
    if esqcom1[esqpos1] = "  Gera arquivo"
    THEN DO:
        run gerar-arquivo.
    END.
    if esqcom1[esqpos1] = "  Baixa"
    THEN DO:
        if tt-arqimp.sit = "PROCESSADO"
        then do:
            message color red/with
            "Baixa ja foi processada."
            view-as alert-box.
        end.
        else    
        run baixa-contrato(input recid(tt-arqimp)).
        
    END.
    if esqcom1[esqpos1] = "  Baixa Geral"
    THEN DO:
        run baixa-contrato(input ?).
    END.
    
    if esqcom1[esqpos1] = "  Sobras"
    THEN DO:
        hide frame f-com1.
        hide frame f-com2.
        hide frame f-linha.
        run ctb/ctsinsegbaixasobra_v0119.p(input varq-baixa). 
        view frame f-linha.
        view frame f-com2.
        view frame f-com1.
        pause 0.
    END.


    if esqcom1[esqpos1] = "  Consulta"
    THEN DO on error undo:
        disp tt-arqimp except estatus ocorrencia tipo observacao 
                with frame f-con overlay 1 column
                column 24 row 4 title " Consulta ".
        disp skip(1) with frame f-con.
        pause.
    END.

end procedure.

procedure controle:
        def var ve as int.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    esqpos1 = 1.
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    do ve = 1 to 5:
                    color display normal esqcom2[ve] with frame f-com2.
                    end.
                    esqpos2 = 1.
                    color display message esqcom1[esqpos1] with frame f-com1.
                end.
                esqregua = not esqregua.
            end.
            if keyfunction(lastkey) = "cursor-right"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 5 then 5 else esqpos1 + 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                    color display messages esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                next.
            end.
end procedure.

procedure validar-dados:
    for each tt-validar. delete tt-validar. end.
    for each tt-arqimp:
        find first clien where clien.ciccgc = replace(tt-arqimp.cpf,"-","")
                    no-lock no-error.
        if not avail clien 
        then do:
            create tt-validar.
            tt-validar.campo = "Seguradora-" +
                               tt-arqimp.cpf + "-" + tt-arqimp.segurado.
            tt-validar.valor = "Admcom-" + "Cliente não encontrado " .    
        end.            
        else do:
            if clien.clinom <> tt-arqimp.segurado
            then do:
                create tt-validar.
                tt-validar.campo = "Seguradora-" +
                                   tt-arqimp.cpf + "-" + tt-arqimp.segurado.
                tt-validar.valor = "Admcom-" + clien.ciccgc + "-" +
                                    clien.clinom
                                    .

            end.
        end.
        def var vok-cert as log.
        vok-cert = no.
        for each contrato where contrato.clicod = clien.clicod no-lock:
            find first vndseguro where 
                     vndseguro.contnum = contrato.contnum and
                     vndseguro.certifi = substr(tt-arqimp.certificado,10,11)
                     no-lock no-error.
            if avail vndseguro
            then do:
                vok-cert = yes.
                
                /***************
                def var vv as dec.
                vv = 0.
                find contrato where contrato.contnum = vndseguro.contnum
                                    no-lock no-error.
                if avail contrato
                then do:
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum)
                            no-lock:
                        if etbcobra > 0 and
                           etbcobra < 900
                        then.
                        else   
                        vv = vv + titulo.titvlcob.
                        disp titulo.titpar titvlcob titsit etbcobra
                        tt-arqimp.saldo vv.
                    end.        
                end.                    
                *******/
                
                leave.

            end.    
        end.
        if vok-cert = no
        then do:
            create tt-validar.
            tt-validar.campo = "Seguradora-" + tt-arqimp.certificado.
            tt-validar.valor = "Admcom-" + "Certificado nao encontrado.".
        end.
    end.

    for each tt-validar.
        disp tt-validar with no-label.
    end.    
end procedure.

procedure baixa-contrato:
    def input parameter p-recid as recid.
    
    def buffer btitulo for titulo.
    def buffer btt-titulo for tt-titulo.
    for each tt-titsel: delete tt-titsel. end.
    for each tt-contsel: delete tt-contsel. end.
    /***
    for each tt-arqimp where
             (if p-recid = ? then true else recid(tt-arqimp) = p-recid)
              and
             tt-arqimp.saldo-devedor < dec(tt-arqimp.valor-baixar)
             and tt-arqimp.sit = "".
        disp tt-arqimp.certificado
             tt-arqimp.cpf
             tt-arqimp.saldo-devedor
             tt-arqimp.valor-baixar
             tt-arqimp.saldo-devedor - dec(tt-arqimp.valor-baixar)
             with frame f-saldo1 width 80
                     title "Saldo insuficiente"
             .   
        pause 0.

        run sel-contrato-baixar(tt-arqimp.cpf). 
    end.    
    
    for each tt-arqimp where
                 (if p-recid = ? then true else recid(tt-arqimp) = p-recid)
                               and
                 tt-arqimp.saldo-devedor < dec(tt-arqimp.valor-baixar)
                 and tt-arqimp.sit = ""
                 .

        disp tt-arqimp.certificado
             tt-arqimp.cpf
             tt-arqimp.saldo-devedor
             tt-arqimp.valor-baixar
             tt-arqimp.saldo-devedor - dec(tt-arqimp.valor-baixar)
             with frame f-saldo 10 down width 80
                     title "Saldo insuficiente"

             .   
                      
    end.
    ***/
    
    sresp = no.    
    message "Confirma executar baixa?" update sresp.
    if sresp 
    then do:
        for each tt-arqimp where 
            (if p-recid = ? then true else recid(tt-arqimp) = p-recid)
                          and
            tt-arqimp.saldo-devedor > 0 /*= dec(tt-arqimp.valor-baixar)*/ 
            and tt-arqimp.sit = ""
            :
            
            find first clien where clien.ciccgc = replace(tt-arqimp.cpf,"-","")
                    no-lock no-error.
            if not avail clien 
            then next.
            for each contrato where contrato.clicod = clien.clicod no-lock:
                find first vndseguro where 
                     vndseguro.contnum = contrato.contnum and
                     vndseguro.certifi = substr(tt-arqimp.certificado,10,11)
                     no-lock no-error.
                if avail vndseguro
                then do:

                    find tbsegpag where 
                         tbsegpag.certificado = tt-arqimp.certificado
                         no-error.
                    if not avail tbsegpag
                    then do:     
                        create tbsegpag.
                        assign
                            tbsegpag.segurado = varq-baixa
                            tbsegpag.cpf = tt-arqimp.cpf
                            tbsegpag.certificado = tt-arqimp.certificado
                            tbsegpag.valor_pagar = dec(tt-arqimp.valor-baixar)
                        tbsegpag.data_programado = date(tt-arqimp.programado)
                        tbsegpag.filial = int(tt-arqimp.filial)
                        tbsegpag.Cliente = int(tt-arqimp.cliente) 
                        tbsegpag.contrato = int(tt-arqimp.contrato)
                        tbsegpag.saldo_devedor_contrato = 
                                        tt-arqimp.saldo-devedor
                        .
                    end.
                    
                    assign
                        val-baixar = dec(tt-arqimp.valor-baixar)
                        val-baixado = 0.
                    
                    run executa-baixa-parcelas(input contrato.clicod,
                                               input string(contrato.contnum),
                                               input-output val-baixar,
                                               output val-baixado). 
                    
                    assign
                        tbsegpag.valor_pago = val-baixado
                        tbsegpag.valor_baixa_contrato = val-baixado
                        tbsegpag.valor_sobra = val-baixar
                        val-baixado = 0.
                    
                    /******
                    if val-baixar > 0
                    then do:
                        for each    tt-contsel where 
                                    tt-contsel.clifor = clien.clicod and
                                    tt-contsel.marca = "*":
                            for each tt-titsel where
                                tt-titsel.clifor = tt-contsel.clifor and
                                tt-titsel.titnum = string(tt-contsel.contnum)
                                by tt-titsel.titpar.
                                find tt-titulo of tt-titsel no-error.
                                if not avail tt-titulo
                                then do:
                                    create tt-titulo.
                                    buffer-copy tt-titsel to tt-titulo.
                                end.
                            end.
                            run executa-baixa-parcelas(input tt-contsel.clifor,
                                            input string(tt-contsel.contnum),
                                            input-output val-baixar,
                                            output val-baixado).
                            if val-baixar = 0
                            then leave.                
                        end.
                    end.     
                    ****/
                    
                    assign
                        tbsegpag.valor_pago = tbsegpag.valor_pago
                                        + val-baixado
                        tbsegpag.valor_baixa_sobra = val-baixado
                        tbsegpag.valor_indenizar_cliente = val-baixar.
                        
                end.
            end. 
            tt-arqimp.sit = "PROCESSADO".                                    
        end.
        message color red/with
        "Baixa finalizada."
        view-as alert-box.
    end.

end procedure.

/*****************************/


procedure saldo-devedor:
    for each tt-arqimp:
        tt-arqimp.saldo-devedor = 0.
        find first clien where clien.ciccgc = replace(tt-arqimp.cpf,"-","")
                    no-lock no-error.
        if not avail clien 
        then next.

        if tt-arqimp.contrato = ""
        then
        for each contrato where contrato.clicod = clien.clicod no-lock:
            find first vndseguro where 
                     vndseguro.contnum = contrato.contnum and
                     vndseguro.certifi = substr(tt-arqimp.certificado,10,11)
                     no-lock no-error.
            if avail vndseguro
            then do:
                tt-arqimp.contrato = string(vndseguro.contnum).
                tt-arqimp.filial   = string(vndseguro.etbcod).
                tt-arqimp.cliente  = string(vndseguro.clicod).

                find    tbsegpag where 
                        tbsegpag.certificado = tt-arqimp.certificado
                        no-lock no-error.
                if avail tbsegpag
                then do:
                    if tbsegpag.valor_indenizar_cliente > 0
                    then tt-arqimp.sit = "SOBRA".
                    else tt-arqimp.sit = "PROCESSADO".
                end.        
                else do:
                find first titulo where
                           titulo.clifor = vndseguro.clicod and
                           titulo.titnum = string(vndseguro.contnum) and
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado) 
                           no-lock no-error.
                if avail titulo
                then do:
                    for each titulo where
                           titulo.clifor = contrato.clicod and
                           /*titulo.titnum = string(contrato.contnum) and*/
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado)
                           no-lock:
                        if acha("BAIXA-SINISTRO",titulo.titobs[2]) =
                                tt-arqimp.certificado
                        then do:        
                            tt-arqimp.valor-pago = tt-arqimp.valor-pago +
                                titulo.titvlpag.
                            tt-arqimp.sit = "PROCESSADO".
                        end.    
                    end.
                    if tt-arqimp.sit = ""
                    then
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) /*and
                            (titulo.titparger = 0 or
                             titulo.titparger > 99)*/
                            no-lock:
                        if titulo.titsit = "LIB"
                        then do: 
                            tt-arqimp.saldo-devedor =
                                tt-arqimp.saldo-devedor + titulo.titvlcob.
                               create tt-titulo.
                               buffer-copy titulo to tt-titulo.
                        end.
                    end. 
                end.                    
                else do:
                    for each titulo where
                           titulo.clifor = vndseguro.clicod and
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado)
                           no-lock:
                        if acha("BAIXA-SINISTRO",titulo.titobs[2]) =
                                tt-arqimp.certificado
                        then do:        
                            tt-arqimp.valor-pago = tt-arqimp.valor-pago +
                                titulo.titvlpag.
                            tt-arqimp.sit = "PROCESSADO".
                        end.        
                    end.
                    if tt-arqimp.sit = ""
                    then
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) /*and
                            (titulo.titparger = 0 or
                             titulo.titparger > 99)*/
                            no-lock:
                        if titulo.titsit = "LIB"
                        then do: 
                            tt-arqimp.saldo-devedor =
                                tt-arqimp.saldo-devedor + titulo.titvlcob.
                               create tt-titulo.
                               buffer-copy titulo to tt-titulo.
                        end.
                    end.        
                end.                    
                end.
                leave.

            end.    
        end.
        else do:
            find contrato where contrato.contnum = int(tt-arqimp.contrato)
                                    no-lock no-error.
            if avail contrato 
            then do:
                find    tbsegpag where 
                        tbsegpag.certificado = tt-arqimp.certificado
                        no-lock no-error.
                if avail tbsegpag
                then do:
                    if tbsegpag.valor_indenizar_cliente > 0
                    then tt-arqimp.sit = "SOBRA".
                    else tt-arqimp.sit = "PROCESSADO".
                end.        
                else do:
                find first titulo where
                           titulo.clifor = contrato.clicod and
                           titulo.titnum = string(contrato.contnum) and
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado)
                           no-lock no-error.
                if avail titulo
                then do:
                    for each titulo where
                           titulo.clifor = contrato.clicod and
                           /*titulo.titnum = string(contrato.contnum) and*/
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado)
                           no-lock:
                        if acha("BAIXA-SINISTRO",titulo.titobs[2]) =
                                tt-arqimp.certificado
                        then do:        
                            tt-arqimp.valor-pago = tt-arqimp.valor-pago +
                                titulo.titvlpag.
                            tt-arqimp.sit = "PROCESSADO".
                        end. 
                    end.
                    if tt-arqimp.sit = ""
                    then
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) /*and
                            titulo.titdtven >= date(tt-arqimp.ocorrencia)*/ 
                            /*and
                            (titulo.titparger = 0 or
                             titulo.titparger > 99) */
                            no-lock by titulo.titpar:
                        if titulo.titsit = "LIB"
                        then do: 
                            tt-arqimp.saldo-devedor =
                                tt-arqimp.saldo-devedor + titulo.titvlcob.
                            find first tt-titulo 
                                where tt-titulo.titnat = titulo.titnat and
                                      tt-titulo.titnum = titulo.titnum and
                                      tt-titulo.titpar = titulo.titpar
                                no-lock no-error.
                            if not avail tt-titulo
                            then do:
                                create tt-titulo.
                               buffer-copy titulo to tt-titulo.
                            end.
                        end.
                    end.         
                end.
                else do:
                    for each titulo where
                           titulo.clifor = vndseguro.clicod and
                           titulo.moecod = "SEG" and
                           titulo.titdtpag = date(tt-arqimp.programado)
                           no-lock:
                        if acha("BAIXA-SINISTRO",titulo.titobs[2]) =
                                tt-arqimp.certificado
                        then do:        
                            tt-arqimp.valor-pago = tt-arqimp.valor-pago +
                                titulo.titvlpag.
                            tt-arqimp.sit = "PROCESSADO".
                        end.        
                    end.
                    if tt-arqimp.sit = ""
                    then
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) /*and
                            titulo.titdtven >= date(tt-arqimp.ocorrencia)*/ 
                            /*and
                            (titulo.titparger = 0 or
                             titulo.titparger > 99) */
                            no-lock by titulo.titpar:
                        if titulo.titsit = "LIB"
                        then do: 
                            tt-arqimp.saldo-devedor =
                                tt-arqimp.saldo-devedor + titulo.titvlcob.

                            find first tt-titulo 
                                where tt-titulo.titnat = titulo.titnat and
                                      tt-titulo.titnum = titulo.titnum and
                                      tt-titulo.titpar = titulo.titpar
                                no-lock no-error.

                            if not avail tt-titulo
                            then do:
                                create tt-titulo.
                               buffer-copy titulo to tt-titulo.
                            end.
                        end.
                    end.        
                end. 
                end.
            end.
        end.                
        if tt-arqimp.sit = "FRANQUIA" 
        then do:
            if tt-arqimp.saldo-devedor > 0
            then tt-arqimp.sit = "".
            else tt-arqimp.saldo = "FRANQUIA".
        end.    

        if tt-arqimp.saldo-devedor > 0 and
                tt-arqimp.saldo <> "RENEGOCIADO"
        then assign
        tt-arqimp.saldo = string(tt-arqimp.saldo-devedor,">>>,>>9.99")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,",","#")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,".",",")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,"#",".")
        .
        tt-arqimp.dif =  dec(tt-arqimp.valor-baixar)
                            - tt-arqimp.saldo-devedor
                            .
    end.
    
end procedure.

procedure sel-contrato-baixar:
    def input parameter par-cpf as char.
    def var vtotal-aberto as dec format ">>>,>>9.99".
    def var vtotal-marca as dec format ">>>,>>9.99".
    def buffer btt-arqimp for tt-arqimp.
    find clien where clien.ciccgc = par-cpf no-lock no-error.
    if avail clien
    then do:
        for each contrato where contrato.clicod = clien.clicod no-lock:
            find first btt-arqimp where
                       btt-arqimp.contrato = string(contrato.contnum)
                       no-lock no-error.
            if avail btt-arqimp then next.
            
            for each titulo where titulo.titnat = no and
                               titulo.titnum = string(contrato.contnum) and
                               titulo.titsit = "LIB"
                               no-lock:
                
                find first tt-contsel where
                           tt-contsel.contnum = contrato.contnum
                           no-lock no-error.
                if not avail tt-contsel
                then create tt-contsel.
                tt-contsel.clifor  = contrato.clicod.
                tt-contsel.contnum = contrato.contnum.
                tt-contsel.dtinicial = contrato.dtinicial.
                tt-contsel.val-sal = tt-contsel.val-sal + titulo.titvlcob.
                create tt-titsel.
                buffer-copy titulo to tt-titsel.    
                vtotal-aberto = vtotal-aberto + titulo.titvlcob.       
            end.
        end. 
        form with frame f-sel 9 down row 8 overlay
            title " Falta " +                 string(dec(tt-arqimp.valor-baixar) - tt-arqimp.saldo-devedor)
          width 80      .
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.

        disp vtotal-aberto label "Total aberto"
             vtotal-marca  label "Total marcado"
            with frame ftot 1 down no-box side-label row 21
            overlay.
            
        {sklcls2.i
            &file = tt-contsel  
            &cfield = tt-contsel.marca
            &noncharacter = /* 
            &ofield = " tt-contsel.clifor
                        tt-contsel.contnum
                        tt-contsel.dtinicial
                        tt-contsel.val-sal column-label ""Saldo"""  
            &aftfnd1 = " "
            &where  = " tt-contsel.clifor = clien.clicod "
            &aftselect1 = " 
                        if tt-contsel.marca <> """"
                        then do:
                            tt-contsel.marca = """" .
                            vtotal-marca = vtotal-marca - tt-contsel.val-sal.
                        end.
                        else do:
                            tt-contsel.marca = ""*"" .
                            vtotal-marca = vtotal-marca + tt-contsel.val-sal.
                        end.

                        disp tt-contsel.marca with frame f-sel.
                        disp vtotal-marca with frame ftot.
                        next keys-loop.
                        "
            &go-on = TAB 
            &naoexiste1 = " message color red/with
                            ""Cliente não possui saldo em outros contrtos.""
                            view-as alert-box.
                            leave keys-loop.
                            " 
            &otherkeys1 = " "
            &form   = " frame f-sel "
        } 
             
        for each tt-contsel where 
                 tt-contsel.clifor = clien.clicod and
                 tt-contsel.marca = "":
            for each tt-titsel where
                     tt-titsel.clifor = tt-contsel.clifor and
                     tt-titsel.titnum = string(tt-contsel.contnum)
                     :
                delete tt-titsel.
            end.  
            delete tt-contsel.                       
        end. 
        for each tt-contsel where
                 tt-contsel.clifor = clien.clicod
                 :
            tt-arqimp.saldo-devedor = tt-arqimp.saldo-devedor +
                          tt-contsel.val-sal.
        end.                  
    end.
end procedure.

procedure executa-baixa-parcelas:
    def input parameter p-clifor like titulo.clifor.
    def input parameter p-titnum like titulo.titnum.
    def input-output parameter val-baixar as dec.
    def output parameter val-baixado as dec.
    
    def buffer btitulo for titulo.
    def buffer btt-titulo for tt-titulo.
    
    for each tt-titulo where 
             tt-titulo.clifor = p-clifor and
             tt-titulo.titnum = p-titnum
             no-lock by tt-titulo.titpar:
        if tt-titulo.titvlcob <= val-baixar
        then do:
            assign
                tt-titulo.etbcobra = 992
                tt-titulo.cxacod   = 99
                tt-titulo.titdtpag = date(tt-arqimp.programado)
                tt-titulo.titvlpag = tt-titulo.titvlcob
                tt-titulo.titsit = "PAG"
                tt-titulo.moecod = "SEG"
                val-baixar = val-baixar - tt-titulo.titvlpag
                .

            find first titulo  
                    where titulo.titnat = tt-titulo.titnat and 
                          titulo.titnum = tt-titulo.titnum and                                             
                          titulo.titpar = tt-titulo.titpar
                                exclusive-lock no-error.
            
            if avail titulo
            then do on error undo:
                assign
                    titulo.etbcobra = tt-titulo.etbcobra
                    titulo.cxacod   = tt-titulo.cxacod 
                    titulo.titdtpag  = tt-titulo.titdtpag
                    titulo.titvlpag = tt-titulo.titvlpag
                    titulo.titsit = tt-titulo.titsit
                    titulo.moecod = tt-titulo.moecod
                    tt-arqimp.valor-pago = 
                        tt-arqimp.valor-pago + tt-titulo.titvlpag
                    titulo.titobs[2] = titulo.titobs[2] +
                                 "|BAIXA-SINISTRO=" + tt-arqimp.certificado +
                                 "|".
                val-baixado = val-baixado + titulo.titvlpag.
            end.
            if val-baixar = 0 then leave.
        end.
        else if val-baixar > 0
        then do:
            assign
                tt-titulo.etbcobra = 992
                tt-titulo.cxacod   = 99
                tt-titulo.titdtpag = date(tt-arqimp.programado)
                tt-titulo.titvlpag = val-baixar
                tt-titulo.titsit = "PAG"
                tt-titulo.moecod = "SEG"
                val-baixar = 0
                .

            find first titulo  
                    where titulo.titnat = tt-titulo.titnat and 
                          titulo.titnum = tt-titulo.titnum and                                             
                          titulo.titpar = tt-titulo.titpar
                                exclusive-lock no-error.

            if avail titulo
            then do on error undo:
                assign
                    titulo.etbcobra = tt-titulo.etbcobra
                    titulo.cxacod   = tt-titulo.cxacod
                    titulo.titdtpag  = tt-titulo.titdtpag
                    titulo.titvlpag = tt-titulo.titvlpag
                    titulo.titsit = tt-titulo.titsit
                    titulo.moecod = tt-titulo.moecod
                    tt-arqimp.valor-pago = tt-arqimp.valor-pago
                                      + tt-titulo.titvlpag
                    titulo.titobs[2] = titulo.titobs[2] +
                                    "|BAIXA-SINISTRO=" + tt-arqimp.certificado +
                                    "|".
                val-baixado = val-baixado + titulo.titvlpag.
            end.
            find last btitulo use-index titnum where
                  btitulo.empcod = tt-titulo.empcod and
                  btitulo.titnat = tt-titulo.titnat and
                  btitulo.modcod = tt-titulo.modcod and
                  btitulo.etbcod = tt-titulo.etbcod and
                  btitulo.clifor = tt-titulo.clifor and
                  btitulo.titnum = tt-titulo.titnum 
                  no-lock no-error.
            if avail btitulo
            then do on error undo:     
                create btt-titulo.
                assign
                    btt-titulo.empcod = btitulo.empcod
                    btt-titulo.cxacod = btitulo.cxacod
                    btt-titulo.titnat = btitulo.titnat
                    btt-titulo.modcod = btitulo.modcod
                    btt-titulo.etbcod = btitulo.etbcod
                    btt-titulo.clifor = btitulo.clifor
                    btt-titulo.titnum = btitulo.titnum
                    btt-titulo.titpar = btitulo.titpar + 1
                    btt-titulo.cobcod = btitulo.cobcod
                    btt-titulo.titsit = "LIB"
                    btt-titulo.titdtemi = titulo.titdtemi
                    btt-titulo.titdtven = titulo.titdtven
                    btt-titulo.datexp   = today
                    btt-titulo.titvlcob = titulo.titvlcob - titulo.titvlpag
                    btt-titulo.titnumger = titulo.titnum
                    btt-titulo.titparger = titulo.titpar
                    btt-titulo.tpcontrato = titulo.tpcontrato
                    btt-titulo.titobs[1] = "PARCIAL=SIM|DISPENSA-JURO=" + "|" 
                    .
                if acha("FEIRAO-NOME-LIMPO",titulo.titobs[1]) = "SIM"
                then btt-titulo.titobs[1] = btt-titulo.titobs[1] +
                                            "FEIRAO-NOME-LIMPO=SIM|".
                else if acha("FEIRAO-NOVO",titulo.titobs[1]) = "SIM"
                then btt-titulo.titobs[1] = btt-titulo.titobs[1] +
                                    "FEIRAO-NOVO=SIM|". 
                                    
                create titulo.
                buffer-copy  btt-titulo to titulo.
            end.
            if val-baixar = 0 then leave.
        end.
    end.
end procedure.

    

