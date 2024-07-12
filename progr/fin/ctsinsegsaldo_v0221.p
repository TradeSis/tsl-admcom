{admcab.i}                         

def temp-table tt-arqimp no-undo
    field segurado as char       format "x(30)"
    field cpf as char            format "x(11)"
    field certificado as char    format "x(20)"
    field cobertura as char      format "x(10)"
    field ocorrencia as char     format "x(10)"
    field saldo                  as char format "x(12)"
    field tipo as char           format "x(40)"
    field observacao as char     format "x(40)"
    field saldo-devedor           as dec format ">>>>9.99" column-label "Devedor"
    field sit as char
    field tpseguro                  like vndseguro.tpseguro
    field certifi                   like vndseguro.certifi
    field etbcod                    like contrato.etbcod
    field clicod                    like contrato.clicod
    field contnum                   like contrato.contnum format ">>>>>>>>>9"
    index i1 is unique primary certificado asc.


def var vdir-recebe as char.
def var vdir-envia  as char.
def var vdir-baixa  as char.
def var vdir-bkprecebe as char.
def var vdir-bkpenvia  as char.
def var vdir-bkpbaixa  as char.
def var varq-recebe as char format "x(20)".
def var varq-envia  as char format "x(20)".
def var varq-baixa  as char format "x(20)".

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
disp replace(vdir-recebe,"/admcom","l:")
        label "Arquivo csv" format "x(26)" space(0)  with frame f1.
update varq-recebe no-label 
help "Informar o nome do arquivo extens�o csv"
with frame f1 1 down width 75 side-label.

varquivo = vdir-recebe + varq-recebe + ".csv".
if search(varquivo) = ?
then do:
    message color red/with
    "Arquivo n�o encontrado."
    view-as alert-box.
    return.
end.
def var vok-arq as log.
vok-arq = no. 
input from value(varquivo)
    no-convert.
repeat:
    import unformatted vlinha.
    vok-arq = yes.
    if num-entries(vlinha,";") <> 8
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
    do vi = 1 to 20:
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
        end. 
    end.
    else delete tt-arqimp.
end.

disp ">>>>>>>>>> PROCESSANDO AGUARDE <<<<<<<<<<<"
    with frame ff1  centered row 15 no-box color message.
    
for each tt-arqimp:
    if tt-arqimp.cpf = "CPF" or
       tt-arqimp.cpf = ""
    then delete tt-arqimp.
    else do:
        /**assign
        tt-arqimp.saldo = string(0,">>>,>>9.99")
        */
        tt-arqimp.saldo = replace(tt-arqimp.saldo,".",",").
        
        tt-arqimp.cpf = replace(tt-arqimp.cpf,"-","").
        find clien where clien.ciccgc = tt-arqimp.cpf no-lock no-error.
        if not avail clien
        then next.
        
        for each contrato where contrato.clicod = clien.clicod no-lock:
               find first vndseguro where 
                     vndseguro.contnum = contrato.contnum and
                     vndseguro.certifi = substr(tt-arqimp.certificado,5)
                     no-lock no-error.
            if not avail vndseguro
            then 
          find first vndseguro where 
                     vndseguro.contnum = contrato.contnum and
                     vndseguro.certifi = substr(tt-arqimp.certificado,10)
                     no-lock no-error.
        
            if avail vndseguro 
            then do:
                tt-arqimp.TpSeguro = vndseguro.TpSeguro.
                tt-arqimp.etbcod   = contrato.etbcod.
                tt-arqimp.certifi  = vndseguro.certifi.
                tt-arqimp.contnum  = vndseguro.contnum.
                tt-arqimp.clicod   = vndseguro.clicod.
                
                if vndseguro.dtcanc <> ?
                then do:
                    tt-arqimp.sit = "CANCELADO".
                end.
            
            end.
        end.
        /*
        create btt-arqimp.
        buffer-copy tt-arqimp to btt-arqimp.
        */
        find contrato where contrato.contnum = tt-arqimp.contnum no-lock no-error.
        if avail contrato
        then do:
            if contrato.modcod begins "CP"
            then tt-arqimp.tipo = "PROTECAO CP".
            else do:
                for each contnf where 
                     contnf.etbcod  = contrato.etbcod and
                     contnf.contnum = contrato.contnum
                     no-lock.
                 
                    for each plani where plani.etbcod = contnf.etbcod and
                                     plani.placod = contnf.placod and
                                     plani.pladat = contrato.dtinicial and
                                     plani.serie = contnf.notaser
                                     no-lock.
                        for each movim where
                                 movim.etbcod = plani.etbcod and
                                 movim.placod = plani.placod and
                                 movim.movtdc = plani.movtdc
                                 no-lock:
                            if movim.procod = 579359
                            then do:
                                tt-arqimp.tipo = "PROTECAO MOVEIS".
                                leave.
                            end.    
                            else if movim.procod = 578790
                            then do:
                                tt-arqimp.tipo = "PROTECAO MOVEIS NOVOS".
                                leave.
                            end.    
                            else if movim.procod = 559911
                            then do:
                                tt-arqimp.tipo = "PROTECAO MODA".
                                leave.
                            end.    
                        end.
                    end.
                end.
            end.
                    if tt-arqimp.cobertura = "DESEMPREGO" and
                       date(tt-arqimp.ocorrencia) - contrato.dtinicial < 30
                    then tt-arqimp.sit = "CARENCIA".
                    else   
                    for each titulo where 
                            titulo.clifor = contrato.clicod and
                            titulo.titnum = string(contrato.contnum) and
                            titulo.titdtven >= date(tt-arqimp.ocorrencia) and
                            (titulo.titparger = 0 or
                             titulo.titparger > 99)
                            no-lock by titpar:
                        /*if titulo.titsit = "PAG"
                        then*/ do: 
                            if titulo.titsit = "PAG" and
                               titulo.moecod = "NOV"
                            then tt-arqimp.sit = "RENEGOCIADO".   
                            if tt-arqimp.cobertura = "DESEMPREGO" and
                               /*titulo.titsit = "LIB" and*/
                               titulo.titdtven - 
                                date(tt-arqimp.ocorrencia) < 15
                            then tt-arqimp.sit = "FRANQUIA".
                            else tt-arqimp.saldo-devedor =
                                tt-arqimp.saldo-devedor + titulo.titvlcob.
                        end.
                    end.        
            
        end.
        else tt-arqimp.tipo = "NAO IDENTIFICADO CONTRATO".
    end.
    if tt-arqimp.saldo-devedor <> 0
    then do:
        assign
        tt-arqimp.saldo = string(tt-arqimp.saldo-devedor,">>>,>>9.99")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,",","#")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,".",",")
        tt-arqimp.saldo = replace(tt-arqimp.saldo,"#",".").
    end.
end.

/*
unix silent value("cp " + varquivo + " " + vdir-bkprecebe).
*/
hide frame ff1 no-pause.

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
    initial ["  Consulta","  Validar", "  Gera arquivo",""].
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


form tt-arqimp.certificado
     tt-arqimp.cpf
     tt-arqimp.ocorrencia
     tt-arqimp.cobertura
     tt-arqimp.saldo
     skip
     space(60) 
     tt-arqimp.sit
     tt-arqimp.contnum
     with frame f-linha 7 down color with/cyan /*no-box*/
     width 81 no-box row 4.
                                                                         
                                                                                
def buffer btbcntgen for tbcntgen.                            
def var i as int.
/*
run saldo-devedor.
*/
l1: repeat:
    clear frame f-com1 all.
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    color display message esqcom1[esqpos1] with frame f-com1.
    {sklclstb.i  
        &color = with/cyan
        &file = tt-arqimp  
        &cfield = tt-arqimp.certificado
        &noncharacter = /* 
        &ofield = " tt-arqimp.cpf
                    tt-arqimp.ocorrencia
                    tt-arqimp.saldo
                    tt-arqimp.sit
                    tt-arqimp.cobertura
                    tt-arqimp.contnum
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
        &locktype = " "
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
    if esqcom1[esqpos1] = "  Consulta"
    THEN DO on error undo:
        disp tt-arqimp /*except saldo-devedor*/
                with frame f-con overlay 1 column
                row 7 title " Consulta "
                width 60 centered.
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

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

def temp-table tt-validar
    field campo as char format "x(75)"
    field valor as char format "x(75)"
    .
    
procedure validar-dados:
    for each tt-validar. delete tt-validar. end.
    for each tt-arqimp:
        find first clien where clien.ciccgc = tt-arqimp.cpf no-lock no-error.
        if not avail clien 
        then do:
            create tt-validar.
            tt-validar.campo = "Seguradora-" +
                               tt-arqimp.cpf + "-" + tt-arqimp.segurado.
            tt-validar.valor = "Admcom-" + "Cliente n�o encontrado " .    
        end.            
        else do:
            if trim(clien.clinom) <> trim(tt-arqimp.segurado)
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
        find vndseguro where
            vndseguro.tpseguro = tt-arqimp.tpseguro and
            vndseguro.etbcod   = tt-arqimp.etbcod and
            vndseguro.certifi  = tt-arqimp.certifi
            no-lock no-error.
        
        if not avail vndseguro
        then do:
            create tt-validar.
            tt-validar.campo = "Seguradora-" + tt-arqimp.certifi.
            tt-validar.valor = "Admcom-" + "Certificado nao encontrado.".
        end.
    end.

    for each tt-validar.
        disp tt-validar with no-label.
    end.    
end procedure.


procedure gerar-arquivo:

    message "Nome do arquivo de envio:" update varq-envia .
    output to value(vdir-envia + varq-envia).
    
    put "Segurado;CPF;Certificado;Cobertura;Ocorrencia;Saldo;Tipo;Observacao;Situacao;Filial;Cliente;Contrato" skip.
    
    for each tt-arqimp no-lock:
        
        put unformatted 
        tt-arqimp.segurado  /*      format "x(30)" */
        ";"
        tt-arqimp.cpf       /*      format "x(14)" */
        ";"
        tt-arqimp.certificado  /*   format "x(21)" */
        ";"
        tt-arqimp.cobertura    /*   format "x(13)" */
        ";"
        tt-arqimp.ocorrencia   /*   format "x(10)" */
        ";"
        trim(tt-arqimp.saldo)       /*    format "x(15)"   */
        ";"
        tt-arqimp.tipo        /*    format "x(40)" */
        ";"
        tt-arqimp.observacao   /*   format "x(40)"*/
        ";"
        tt-arqimp.sit          /*   format "x(15)"*/
        ";"
        tt-arqimp.etbcod          
        ";"
        tt-arqimp.clicod
        ";"
        tt-arqimp.contnum
        skip

        .

    end.
    output close.
    
    message color red/with
    "Arquivo gerado." skip
    replace(vdir-envia,"/admcom","l:") + varq-envia
    view-as alert-box.

    
end procedure.