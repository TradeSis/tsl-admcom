{admcab.i}

def var vdti as date format "99/99/9999".
def var vdtf as date format "99/99/9999".
def var vqtd_cli as int.

def temp-table tt-ascii no-undo
    field codigo as int
    field valor  as char
    field codaux as int
    field tipo as char
    index i1 codigo
    index i2 valor
    .

def var vi as int.
def var vcont as int no-undo.

DO vcont = 1 TO 255:
       create tt-ascii.
       assign
            tt-ascii.codigo = vcont
            tt-ascii.valor  = CHR(vcont)
            .
    if vcont < 32 then tt-ascii.tipo = "NULL".
    else if vcont < 33 then tt-ascii.tipo = "CLTR".
    else if vcont < 48 then tt-ascii.tipo = "CESP".
    else if vcont < 58 then tt-ascii.tipo = "CNUM".
    else if vcont < 65 then tt-ascii.tipo = "CESP".
    else if vcont < 91 then tt-ascii.tipo = "CLTR".
    else if vcont < 97 then tt-ascii.tipo = "CESP".
    else if vcont < 123 then tt-ascii.tipo = "CLTR".
    else if vcont < 127 then tt-ascii.tipo = "CESP".
    else if vcont < 161 then tt-ascii.tipo = "NULL".
    else if vcont <= 255 then tt-ascii.tipo = "CESP".

end.
/*
for each tt-ascii.
    disp tt-ascii
           WITH no-labels  .
END.
*/
def var v-ok as log.

def var vciccgc as char.
def var vnome as char.
def var vcep as char.
def var v-retorno as char.
def var vendereco as char.
def var vconta as int.

def var vcampo as char extent 6 init["NOME","CPF/CNPJ"
    ,"CEP","CIDADE","LOGRADOURO","NUMERO"].
def var vvalor as char extent 6.

def temp-table tt-tipoh
    field seq as int
    field Campo as char format "x(15)"  
    field sel as char
    index i1 seq.

def var va as int.

for each tt-tipoh: delete tt-tipoh. end.

do va = 1 to 6:
    create tt-tipoh.
    assign
        tt-tipoh.seq = va
        tt-tipoh.campo = vcampo[va].
end.

form
     tt-tipoh.campo column-label "Campo validar"
     with frame f-sel down.


{setbrw.i}

l-sel:
repeat:
        assign
            a-seeid = -1
            a-seelst = "".

        {sklcls.i
            &help =  "ENTER=Seleciona F4=Retorna "
            &file         = tt-tipoh
            &cfield       = tt-tipoh.campo
            &ofield       = "
                         tt-tipoh.campo
                        "
            &where        = "true"
            &color        = withe
            &color1       = brown
            &usepick      = "*"
            &pickfld      = tt-tipoh.campo
            &pickfrm      = "x(15)"
            &locktype     = " no-lock "
            &aftselect1   = "
                 if not avail tt-tipoh then next.
                 if tt-tipoh.sel = """"
                 then tt-tipoh.sel = ""*"".
                 else tt-tipoh.sel = """".
                 "
            &naoexiste1   = " leave keys-loop. "
            &form         = " frame f-sel " }


        if keyfunction(lastkey) = "end-error"
        then leave l-sel.
end.
find first tt-tipoh where tt-tipoh.sel <> "" no-lock no-error.
if not avail tt-tipoh
then do:
    bell.
    message color red/with
        "Favor selecionar pelo menos um campo da lista."
        view-as alert-box.
    return.
end.

vdti = today - 1.
vdtf = today - 1.
vqtd_cli = 16.

form vdti at 1 label "Periodo de cadastro"
     vdtf no-label
     vqtd_cli  label "Quantidade de clientes selecionar"
     with frame f-s side-label column 25 row 8.

update vdti vdtf vqtd_cli with frame f-s.

if vdti = ? or vdtf = ? or
    vdti > vdtf
then do:
    bell.
    message color red/with
    "Periodo invalido para processamento."
    view-as alert-box.
    undo.
end.
    
if keyfunction(lastkey) = "end-error"
then return.

def temp-table tt-hig
    field conta as int
    field clicod like clien.clicod
    field clinom like clien.clinom
    field ciccgc like clien.ciccgc
    field campo as char extent 6
    field valor as char extent 6
    index i1 conta.

def var vhig as log.

sresp = no.
message "Confirma processamento com as informações acima?"
update sresp.
if not sresp then undo.

message "Em processamento... Aguarde!".

for each clien where (if vdti <> ?
                      then clien.dtcad >= vdti else true) and
                     (if vdtf <> ?
                      then clien.dtcad >= vdtf else true)
                     no-lock:

    vvalor = "".
    vhig = no.

    find first tt-tipoh where tt-tipoh.campo = vcampo[1] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.clinom <> ?
    then do:
        vnome = clien.clinom.
        /*if length(vnome) <= 5
        then assign
                vvalor[1] = clien.clinom
                vhig = yes.

        else*/ do:
            run val-char(vnome,"CLTR",output v-ok).
            if not v-ok
            then assign
                    vvalor[1] = clien.clinom
                    vhig = yes.
        end.
    end.

    find first tt-tipoh where tt-tipoh.campo = vcampo[2] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.ciccgc <> ?
    then do:
        vciccgc = clien.ciccgc.
        run val-char(vciccgc,"CNUM",output v-ok).
        if not v-ok
        then assign
                vvalor[2] = clien.ciccgc
                vhig = yes.
        else do:
            if length(vciccgc) <= 11
            then do:
                run cpf.p(input vciccgc, output v-ok).
                if not v-ok then assign
                                    vvalor[2] = clien.ciccgc
                                    vhig = yes.
            end.
            else do:
                run cgc.p(input vciccgc, output v-ok).
                if not v-ok then assign
                                    vvalor[2] = clien.ciccgc
                                    vhig = yes.
            end.
        end.
    end.


    /************
    def var vnome-mae as char.
    find first tt-tipoh where tt-tipoh.campo = vcampo[3] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.mae <> ?
    then do:
        vnome-mae = clien.mae.
        if length(vnome-mae) <= 8
        then assign
                vvalor[3] = clien.mae
                vhig = yes.
        else do:
            run val-char(vnome-mae,"CLTR",output v-ok).
            if not v-ok
            then assign
                    vvalor[3] = clien.mae
                    vhig = yes.
        end.
    end.
    def var vnome-pai as char.
    find first tt-tipoh where tt-tipoh.campo = vcampo[4] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.pai <> ?
    then do:
        vnome-pai = clien.pai.
        if length(vnome-pai) <= 8
        then assign
                 vvalor[4] = clien.pai
                 vhig = yes.
        else do:
            run val-char(vnome-pai,"CLTR",output v-ok).
            if not v-ok
            then assign
                     vvalor[4] = clien.pai
                     vhig = yes.
        end.
    end.
    ******/
    find first tt-tipoh where tt-tipoh.campo = vcampo[3] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.cep[1] <> ?
    then do:
        vcep = clien.cep[1].
        run val-char(vcep,"CNUM",output v-ok).
        if not v-ok
        then assign
                vvalor[3] = clien.cep[1]
                vhig = yes.
        /***
        else do:
            message vcep. pause.
            run /admcom/claudir/ViaCEP.p(vcep,output v-retorno).
            message v-retorno. pause.
            if acha("ERRO",v-retorno) <> ?
            then assign
                    vvalor[5] = clien.cep[1]
                    vhig = yes.
            else do:
                if clien.ufecod[1] <> acha("UF",v-retorno)
                then assign
                        vvalor[6] = clien.ufecod[1]
                        vhig = yes.
            end.
        end.
        **/
    end.
    def var vcidade as char format "x(30)".
    find first tt-tipoh where tt-tipoh.campo = vcampo[4] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.cidade[1] <> ?
    then do:
        vcidade = clien.cidade[1].
        run val-char(vcidade,"CLTR",output v-ok).
        if not v-ok
        then assign
                vvalor[4] = clien.cidade[1]
                vhig = yes.
        else do:
            find first munic where munic.cidnom = vcidade and
                             munic.ufecod = clien.ufecod[1]
                             no-lock no-error.
            if not avail munic
            then assign
                    vvalor[4]  = clien.cidade[1]
                    vhig = yes.
        end.
    end.
    find first tt-tipoh where tt-tipoh.campo = vcampo[5] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and clien.endereco[1] <> ?
    then do:
        vendereco = clien.endereco[1].
        run val-char(vendereco,"CLTR",output v-ok).
        if not v-ok
        then assign
                vvalor[5] = clien.endereco[1]
                vhig = yes.
    end.

    def var vnumero as char.
    find first tt-tipoh where tt-tipoh.campo = vcampo[6] and
                             tt-tipoh.sel   = "*"
                             no-lock no-error.
    if avail tt-tipoh and string(clien.numero[1]) <> ?
    then do:
        vnumero = string(clien.numero[1]).
        run val-char(vnumero,"CNUM",output v-ok).
        if not v-ok
        then assign
                vvalor[6] = string(clien.numero[1])
                vhig = yes.
    end.

    if vhig
    then do:
    do vi = 1 to 6:
        if vvalor[vi] <> ""
        then do:
            vconta = vconta + 1.
            create tt-hig.
            assign
                tt-hig.conta = vconta
                tt-hig.clicod = clien.clicod
                tt-hig.clinom = clien.clinom
                tt-hig.ciccgc = clien.ciccgc
                tt-hig.campo  = vcampo
                tt-hig.valor  = vvalor
                .
            leave.
        end.
    end.
    disp vconta no-label with frame f-s.
    pause 0.

    end.
    if vqtd_cli > 0 and
       vconta >= vqtd_cli then leave.

end.

procedure val-char:
    def input parameter p-texto as char.
    def input parameter p-tipo as char.
    def output parameter p-ok as log.

    def var v1 as char.
    def var v2 as char.

    p-ok = no.
    do vi = 1 to length(p-texto):
        v1 = substr(p-texto,vi,1).
        if v1 = " " and v2 = " "
        then do:
            p-ok = no.
            leave.
        end.
        find first tt-ascii where
               tt-ascii.codigo = ASC(v1) and
               tt-ascii.valor = v1
               no-error.
        /*message tt-ascii.codigo tt-ascii.valor tt-ascii.tipo.
        pause.*/
        if avail tt-ascii and tt-ascii.tipo = p-tipo
        then p-ok = yes.
        else do:
            p-ok = no.
            leave.
        end.
        v2 = v1.
    end.
end.

hide frame f-s no-pause.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","   CAMPOS","  RELATORIO","  ARQUIVO CSV",""].
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


form tt-hig.conta column-label "Seq." format ">>>,>>>"
     tt-hig.clicod column-label "Cod. Cliente"
     tt-hig.clinom column-label "NOME"
     tt-hig.ciccgc column-label "CPF/CNPJ"
     with frame f-linha down
     width 80 no-box row 4.


def buffer btbcntgen for tbcntgen.
def var i as int.
l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.
    {sklclstb.i
        &color = with/cyan
        &file = tt-hig
        &cfield = tt-hig.clicod
        &noncharacter = /*
        &ofield = " tt-hig.conta
                    tt-hig.clinom
                    tt-hig.ciccgc
                     "
        &aftfnd1 = " "
        &where  = " "
        &aftselect1 = "
                    if not avail tt-hig then next l1.
                    a-seeid = a-recid.
                    run aftselect.
                    a-seeid = -1.
                    a-seerec = ?.
                    next keys-loop.
                    "
        &go-on = TAB
        &naoexiste1 = " bell.
         message color red/with
         ""Nenhum registro encontrado.""
         view-as alert-box.
         leave l1.
         "
        &otherkeys1 = "
                        run controle. "
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
    if esqcom1[esqpos1] = "   CAMPOS"
    THEN DO on error undo:

        disp tt-hig.conta column-label "Seq." format ">>>,>>>"
     tt-hig.clicod column-label "Cod. Cliente"
     tt-hig.clinom column-label "NOME"
     tt-hig.ciccgc column-label "CPF/CNPJ"
     with frame f-linha2 1 down
     width 80 no-box row 4.
     pause 0.
        vvalor = tt-hig.valor.
        update tt-hig.valor[1] when tt-hig.valor[1] <> ""
                label "NOME"        format "x(50)"
             tt-hig.valor[2]   when tt-hig.valor[2] <> ""
                label "CPF/CNPJ"    format "x(50)"
             tt-hig.valor[3]   when tt-hig.valor[3] <> ""
                label "CEP"         format "x(50)"
             tt-hig.valor[4]   when tt-hig.valor[4] <> ""
                label "CIDADE"      format "x(50)"
             tt-hig.valor[5]   when tt-hig.valor[5] <> ""
                label "LOGRADOURO"  format "x(50)"
             tt-hig.valor[6]   when tt-hig.valor[6] <> ""
                label "NUMERO"      format "x(50)"
             with frame f-c side-label row 7 centered.

        if tt-hig.valor[1] <> vvalor[1] or
           tt-hig.valor[2] <> vvalor[2] or
           tt-hig.valor[3] <> vvalor[3] or
           tt-hig.valor[4] <> vvalor[4] or
           tt-hig.valor[5] <> vvalor[5] or
           tt-hig.valor[6] <> vvalor[6]
        then do:
            sresp = no.
            message "Confirma atualizar cliente?" update sresp.
            if sresp
            then do:
                find clien where clien.clicod = tt-hig.clicod no-error.
                if avail clien
                then do on error undo:
                    if tt-hig.valor[1] <> vvalor[1] and
                        clien.clinom = vvalor[1]
                    then clien.clinom = tt-hig.valor[1].
                    if tt-hig.valor[2] <> vvalor[2] and
                        clien.ciccgc = vvalor[2]
                    then clien.ciccgc = tt-hig.valor[2].
                    if tt-hig.valor[3] <> vvalor[3] and
                        clien.cep[1] = vvalor[3]
                    then clien.cep[1] = tt-hig.valor[3].
                    if tt-hig.valor[4] <> vvalor[4] and
                        clien.cidade[1]  = vvalor[4]
                    then clien.cidade[1] = tt-hig.valor[4].
                    if tt-hig.valor[5] <> vvalor[5] and
                        clien.endereco[1] = vvalor[5]
                    then clien.endereco[1] = tt-hig.valor[5].
                    if tt-hig.valor[6] <> vvalor[6] and
                        clien.numero[1] = int(vvalor[6])
                    then clien.numero[1] = int(tt-hig.valor[6]).
                end.
            end.
        end.
        a-recid = recid(tt-hig).
    END.
    if esqcom1[esqpos1] = "  RELATORIO"
    THEN DO:
        run relatorio.
    END.
    if esqcom1[esqpos1] = "  ARQUIVO CSV"
    THEN DO:
        run gerarqcsv.
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:

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

    varquivo = "/admcom/relat/selclihig." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"
                &Page-Size = "64"
                &Cond-Var  = "150"
                &Page-Line = "66"
                &Nom-Rel   = ""selclihig""
                &Nom-Sis   = """CREDITO COBRANCA"""
                &Tit-Rel   = """ CORRECAO CADASTRO DE CLIENTES """
                &Width     = "150"
                &Form      = "frame f-cabcab"}

    find first tt-hig.
    put unformatted "Codigo "
        tt-hig.campo[1] at 11
        tt-hig.campo[2] at 55
        tt-hig.campo[3] at 70
        tt-hig.campo[4] at 80
        tt-hig.campo[5] at 110
        tt-hig.campo[6] at 150
        skip.

    for each tt-hig no-lock:

        put unformatted
        tt-hig.clicod
        tt-hig.valor[1] at 11
        tt-hig.valor[2] at 55
        tt-hig.valor[3] at 70
        tt-hig.valor[4] at 80
        tt-hig.valor[5] at 110
        tt-hig.valor[6] at 150
        skip.

    end.
    output close.


    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure gerarqcsv:

    def var varquivo as char.

    varquivo = "/admcom/relat/selclihig-" + string(time) + ".csv".
    
    output to value(varquivo).

    find first tt-hig.
    put unformatted "Codigo;" 
        tt-hig.campo[1] ";"
        tt-hig.campo[2] ";"
        tt-hig.campo[3] ";"
        tt-hig.campo[4] ";"
        tt-hig.campo[5] ";"
        tt-hig.campo[6] 
        skip.

    for each tt-hig no-lock:

        put unformatted
        tt-hig.clicod   ";"
        tt-hig.valor[1] ";"
        tt-hig.valor[2] ";"
        tt-hig.valor[3] ";"
        tt-hig.valor[4] ";"
        tt-hig.valor[5] ";"
        tt-hig.valor[6] 
        skip.

    end.
    output close.

    varquivo = replace(varquivo,"/admcom","L:").
    varquivo = replace(varquivo,"/","~\").

    message color red/with
    "Arquivo gerado."
    varquivo
    view-as alert-box.
    
end procedure.


