{admcab.i}

def input parameter par-reclotcre  as recid.

/*
find lotcre where lotcre.ltcrecod = 999000709 no-lock.
par-reclotcre = recid(lotcre).
*/

def temp-table tt-titulo like titulo.

def var v-lancactb as log.

def var aux-forcod like forne.forcod.
def var aux-fornom like forne.fornom.
def var aux-cgccpf like forne.forcgc.

def var vdir        as char.
def var varq        as char.
def var vlinha      as char.
def var vtime       as int.
def var vct         as int.
def var vretorno    as char.
def var vcodbarras  as char.
def var varquivo as char.
def var vdata as date.
def var data-arq as char.
def var ano-arq as char.
def var mes-arq as char.
def var dia-arq as char.

FUNCTION datadoarquivo returns character
        (input par-oque as char).
    def var data-ret as char.
    def var varqdata as char.
    varqdata = varquivo + string(today,"99999999").
    unix silent value("date -r " + varquivo + " +%d%m%y > " + varqdata).
    input from value(varqdata).
    import data-ret.
    input close.
    unix silent value("rm -f " + varqdata).
    return data-ret.
END FUNCTION.

FUNCTION anoarq returns character
        (input par-oque as char).
    def var ano-ret as char.
    def var varqano as char.
    varqano = varquivo + string(today,"99999999").
    unix silent value("date -r " + varquivo + " +%y > " + varqano).
    input from value(varqano).
    import ano-ret.
    input close.
    unix silent value("rm -f " + varqano).
    return ano-ret.
END FUNCTION.

FUNCTION mesarq returns character
        (input par-oque as char).
    def var mes-ret as char.
    def var varqmes as char.
    varqmes = varquivo + string(today,"99999999").
    unix silent value("date -r " + varquivo + " +%m > " + varqmes).
    input from value(varqmes).
    import mes-ret.
    input close.
    return mes-ret.
END FUNCTION.
 
FUNCTION diaarq returns character
        (input par-oque as char).
    def var dia-ret as char.
    def var varqdia as char.
    varqdia = varquivo + string(today,"99999999").
    unix silent value("date -r " + varquivo + " +%d > " + varqdia).
    input from value(varqdia).
    import dia-ret.
    input close.
    return dia-ret.
END FUNCTION.
      
def temp-table tt-arquivo
    field i-registro as char
    field t-cpfcnpj  as char
    field n-cpfcnpj  as char
    field n-pagamento as char
    field n-documento as char
    field d-pagamento as date
    field d-vencimento as date
    field d-emissao    as date
    field v-documento  as dec
    field v-pagamento  as dec
    field v-desconto   as dec
    field v-acrescimo  as dec 
    field n-fatura    as char
    field m-pagamento  as int
    field t-movimento  as int
    field c-lancamento as int
    field t-retorno as char
    field marca as char
    field clifor like titulo.clifor
    field d-arquivo as date
    field n-arquivo as char
    field v-juro as dec
    field v-multa as dec
    index i1 n-cpfcnpj n-pagamento v-pagamento 
    index i2 marca clifor  
            .

def temp-table sl-arquivo
    field t-retorno as char
    field m-retorno as char
    field q-retorno as int
    field v-retorno as dec
    index i1 t-retorno.

vdir = "/admcom/brasil/titulos/".

find lotcre where recid(lotcre) = par-reclotcre no-lock.
vdata = lotcre.ltdtenvio.

def var vocor as char format "x(50)".
vocor = "Processando aguarde ...".

disp vdata label "Data Envio"      vocor no-label 
    with frame f1  width 80 side-label 1 down.

form with frame f-arq.
def var vi as int.
def var vdt-arq as date.
vdt-arq = vdata.
do /*vdt-arq = vdata to today*/:
varq = "REC390" + string(day(vdt-arq),"99") + string(month(vdt-arq),"99").
do /*vi = 0 to 20*/:
    varquivo = vdir + varq + string(vi,"99") + ".RET".
    update varquivo format "x(50)" label "Arquivo retorno"
    with frame f-arq side-label.
    if search(varquivo) <> ?
    then do:
        unix  silent value("quoter -d % "  + varquivo + " > " +
            varquivo + ".quo").
        if search(varquivo) <> ?
        then do:
            data-arq = datadoarquivo(input varquivo).
            /*if data-arq <> ? and
                year(date(data-arq)) = year(vdt-arq)
            then*/ do:


                run importa-dados-arquivo-retorno.
            
            end.    
        end.
    end.
end.
end.

/*
for each tt-arquivo:
     disp tt-arquivo.n-cpfcnpj 
          tt-arquivo.n-documento
          tt-arquivo.n-pagamento
          tt-arquivo.v-pagamento
          .
     pause.
end.
*/
find lotcre where recid(lotcre) = par-reclotcre no-lock.
find lotcretp of lotcre no-lock.

for each lotcretit of lotcre no-lock:
    find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-lock no-error.
    if not avail titulo 
    then  next.
    find forne where forne.forcod = titulo.clifor no-lock.
    find first titulo2 where
               titulo2.empcod = titulo.empcod and
               titulo2.titnat = titulo.titnat and
               titulo2.modcod = titulo.modcod and
               titulo2.etbcod = titulo.etbcod and
               titulo2.clifor = titulo.clifor and
               titulo2.titnum = titulo.titnum and
               titulo2.titpar = titulo.titpar and
               titulo2.titdtemi = titulo.titdtemi
               no-lock no-error.
    if not avail titulo2 then next.

    if titulo2.modpag = 3 or
       titulo2.modpag = 8
    then next.

    assign
        aux-forcod = forne.forcod
        aux-fornom = forne.fornom
        aux-cgccpf = forne.forcgc
        .
    find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
    if avail forconpg and lotcre.ltdtenvio >= 07/30/14 
    then assign
             aux-forcod = forconpg.forcod
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             aux-cgccpf = trim(aux-cgccpf)
             .
    else do:
        if acha("CGCCPF",titulo2.char1) <> ? and
           acha("NOMERZ",titulo2.char1) <> ? and
           titulo2.titbanpag > 0
        then assign
                 aux-fornom = acha("NOMERZ",titulo2.char1)
                 aux-cgccpf = acha("CGCCPF",titulo2.char1)
                 aux-cgccpf = trim(aux-cgccpf)
                 .
    end.

    for each tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = string(aux-cgccpf) and
               (if titulo2.dec1 = 0
                then*/ tt-arquivo.n-documento = titulo2.titnum
                /*else tt-arquivo.n-pagamento = string(titulo2.dec1))*/ and
               tt-arquivo.v-pagamento = titulo.titvlcob + titulo.titjuro -
                                        titulo.titvldes
               : 
        find first sl-arquivo where
               sl-arquivo.t-retorno = tt-arquivo.t-retorno
               no-error.
        if not avail sl-arquivo
        then create sl-arquivo.
        assign
            sl-arquivo.t-retorno = tt-arquivo.t-retorno
            sl-arquivo.q-retorno = sl-arquivo.q-retorno + 1
            sl-arquivo.v-retorno = sl-arquivo.v-retorno + 
                        tt-arquivo.v-pagamento
            .
        tt-arquivo.marca = "*".
        tt-arquivo.clifor = titulo.clifor.
    end.
end.

def temp-table tt-lotcretit
    field campo-rec as recid
    field titnum like titulo.titnum
    .
def temp-table tt-titulo2
    field campo-rec as recid
        .

def var lt as int.        
for each agtitbra where
             agtitbra.ltcrecod = lotcre.ltcrecod
             no-lock:
        do lt = 1 to int(num-entries(agtitbra.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitbra.char1,";")).
            tt-lotcretit.titnum = agtitbra.titnum.
        end.
        do lt = 1 to int(num-entries(agtitbra.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitbra.char2,";")).
        end.

                
        for each tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = agtitbra.cgccpf and*/
               tt-arquivo.n-documento = agtitbra.titnum and
               tt-arquivo.d-vencimento = agtitbra.titdtven and
               tt-arquivo.v-pagamento = agtitbra.valor-pago
               : 
            find first sl-arquivo where
               sl-arquivo.t-retorno = tt-arquivo.t-retorno
               no-error.
            if not avail sl-arquivo
            then create sl-arquivo.
            assign
                sl-arquivo.t-retorno = tt-arquivo.t-retorno
                sl-arquivo.q-retorno = sl-arquivo.q-retorno + 1
                sl-arquivo.v-retorno = sl-arquivo.v-retorno + 
                        tt-arquivo.v-pagamento
                .
            tt-arquivo.marca = "*".
            tt-arquivo.clifor = titulo.clifor.
        end.
end.
for each agtitfor where
             agtitfor.ltcrecod = lotcre.ltcrecod
             no-lock:
        do lt = 1 to int(num-entries(agtitfor.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitfor.char1,";")).
            tt-lotcretit.titnum = agtitfor.titnum.
        end.
        do lt = 1 to int(num-entries(agtitfor.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitfor.char2,";")).
        end.

                
        for each tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = agtitfor.cgccpf and*/
               tt-arquivo.n-documento = agtitfor.titnum and
               tt-arquivo.d-vencimento = agtitfor.titdtven and
               tt-arquivo.v-pagamento = agtitfor.valor-pago
               : 
            find first sl-arquivo where
               sl-arquivo.t-retorno = tt-arquivo.t-retorno
               no-error.
            if not avail sl-arquivo
            then create sl-arquivo.
            assign
                sl-arquivo.t-retorno = tt-arquivo.t-retorno
                sl-arquivo.q-retorno = sl-arquivo.q-retorno + 1
                sl-arquivo.v-retorno = sl-arquivo.v-retorno + 
                        tt-arquivo.v-pagamento
                .
            tt-arquivo.marca = "*".
            tt-arquivo.clifor = titulo.clifor.
        end.
end.
                      
clear frame f-arq all.
hide frame f-arq no-pause.

for each tt-arquivo:
    if tt-arquivo.marca = ""
    then delete tt-arquivo.
end.
def var t-total as dec format ">>,>>>,>>9.99".
    
def var vdesc as char format "x(40)".
for each sl-arquivo where
         sl-arquivo.t-retorno <> "" :
    find first tabaux where
              tabaux.tabela = "PAGFOR-OCORRENCIAS" and
              tabaux.nome_campo = sl-arquivo.t-retorno 
              no-lock no-error.
    if avail tabaux
    then
    vdesc = acha("MENSAGEM",tabaux.valor_campo).          
    else vdesc = sl-arquivo.t-retorno.
    sl-arquivo.m-retorno = vdesc.
    t-total = t-total + sl-arquivo.v-retorno.
end.

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
    initial ["","  Titulos","","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial [""," Processar","","",""].
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


form " " 
     " "
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered.
                       
vocor = "         OCORRENCIAS ARQUIVO RETORNO   "                                         .                                
                                                                                
disp vocor 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
                                                  
disp " " with frame f2 1 down width 80 color message no-box no-label            
    row 20.                                                                     
def buffer btbcntgen for tbcntgen.                            
def var i as int.

form sl-arquivo.t-retorno column-label "Ocor"
     sl-arquivo.m-retorno column-label "Descricao Ocor"
        format "x(40)"
     sl-arquivo.q-retorno column-label "Qt" format ">>>>9"
     sl-arquivo.v-retorno column-label "Valor Total"
     with frame f-linha down .
    
disp "T O T A L " to 40 t-total format ">>>,>>>,>>9.99"
     with frame f-totl row 19 overlay no-label no-box .
     pause 0.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = sl-arquivo  
        &cfield = sl-arquivo.m-retorno
        &noncharacter = /* */
        &ofield = " sl-arquivo.t-retorno
                    sl-arquivo.m-retorno
                    sl-arquivo.q-retorno
                    sl-arquivo.v-retorno format "">>>,>>>,>>9.99""
                  "
        &aftfnd1 = " "
        &where  = " true "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                        message color red/with
                        ""Nenhum registro processado.""
                        view-as alert-box.
                        leave l1.
                        " 
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
    if esqcom1[esqpos1] = "  Titulos"
    THEN DO on error undo:
        run relat-titulos.    
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = " Processar"
    THEN DO on error undo:
        run processa-retorno.
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

procedure relat-titulos:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/titulos" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\titulos" + string(setbcod) + "."
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

    /*
    for each agtitbra where
             agtitbra.ltcrecod = lotcre.ltcrecod
             no-lock:
        for each tt-lotcretit. delete tt-lotcretit. end.
        for each tt-titulo2. delete tt-titulo2. end.
        do lt = 1 to int(num-entries(agtitbra.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitbra.char1,";")).
            tt-lotcretit.titnum = agtitbra.titnum.
        end.
        do lt = 1 to int(num-entries(agtitbra.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitbra.char2,";")).
        end.
    */

    for each lotcretit where
                lotcretit.ltcrecod = lotcre.ltcrecod
                no-lock:
                
            find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-error.
            if not avail titulo then next.
            find first titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-lock no-error.
            if not avail titulo2 then next.
            find forne where forne.forcod = titulo.clifor no-lock.
            assign
                aux-forcod = forne.forcod
                aux-fornom = forne.fornom
                aux-cgccpf = forne.forcgc
                .
            find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
            if avail forconpg and lotcre.ltdtenvio >= 07/30/14
            then assign
             aux-forcod = forconpg.forcod
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             aux-cgccpf = trim(aux-cgccpf)
             .
 
            find first tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = string(aux-cgccpf) and*/
               tt-arquivo.n-documento = titulo2.titnum and 
               tt-arquivo.v-pagamento = titulo.titvlcob and
               tt-arquivo.clifor = titulo.clifor and
               /*tt-arquivo.t-retorno = sl-arquivo.t-retorno and*/
               tt-arquivo.marca = "*"
               no-error.                        
            if not avail tt-arquivo then next. 
        
            find first tt-titulo of titulo no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titvlpag = titulo.titvlcob - 
                    titulo.titvldes + titulo.titvljur.
                tt-titulo.titdtpag = tt-arquivo.d-pagamento.
            end.
    end.
    /********
    for each agtitfor where
             agtitfor.ltcrecod = lotcre.ltcrecod
             no-lock:
        for each tt-lotcretit. delete tt-lotcretit. end.
        for each tt-titulo2. delete tt-titulo2. end.
        do lt = 1 to int(num-entries(agtitfor.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitfor.char1,";")).
            tt-lotcretit.titnum = agtitfor.titnum.
        end.
        do lt = 1 to int(num-entries(agtitfor.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitfor.char2,";")).
        end.

        for each tt-lotcretit no-lock,
            first lotcretit where
                recid(lotcretit) = tt-lotcretit.campo-rec no-lock
                :
            find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-error.
            if not avail titulo then next.
            find first titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-lock no-error.
            if not avail titulo2 then next.
            find forne where forne.forcod = titulo.clifor no-lock.
            assign
                aux-forcod = forne.forcod
                aux-fornom = forne.fornom
                aux-cgccpf = forne.forcgc
                .
            find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
            if avail forconpg and lotcre.ltdtenvio >= 07/30/14
            then assign
             aux-forcod = forconpg.forcod
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             aux-cgccpf = trim(aux-cgccpf)
             .
 
            find first tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = string(aux-cgccpf) and*/
               tt-arquivo.n-documento = agtitfor.titnum and 
               tt-arquivo.v-pagamento = agtitfor.valor-pago and
               tt-arquivo.clifor = titulo.clifor and
               /*tt-arquivo.t-retorno = sl-arquivo.t-retorno and*/
               tt-arquivo.marca = "*"
               no-error.                        
            if not avail tt-arquivo then next. 
        
            find first tt-titulo of titulo no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titvlpag = titulo.titvlcob - 
                    titulo.titvldes + titulo.titvljur.
                tt-titulo.titdtpag = tt-arquivo.d-pagamento.
            end.
        end.
    end.
    *************/
    /*
    for each tt-arquivo use-index i2 where tt-arquivo.marca = "*"
        and tt-arquivo.t-retorno = sl-arquivo.t-retorno  and
            tt-arquivo.n-documento <> ""
                            no-lock,
        first forne where forne.forcod = tt-arquivo.clifor
                     no-lock by forne.fornom:

        find first tt-titulo of titulo no-lock no-error.
            if not avail tt-titulo
            then do:
                create tt-titulo.
                buffer-copy titulo to tt-titulo.
                tt-titulo.titdtpag = tt-arquivo.d-pagamento.
                tt-titulo.titvlpag = tt-arquivo.v-pagamento.
            end.
    end.
    */
    for each tt-titulo no-lock,
        first forne where forne.forcod = tt-titulo.clifor
                     no-lock .
        disp forne.forcod 
             forne.fornom
             tt-titulo.titnum  column-label "Numero"
             tt-titulo.titdtpag  column-label "Data CON"
             tt-titulo.titvlpag(total)   column-label "Valor"
             with frame f-disp down width 100.           
        down with frame f-disp.
                
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

procedure processa-retorno:
    def var lt as int.
    /*if sl-arquivo.t-retorno <> "BW"
    then do:
        message "Ocorrencia " sl-arquivo.t-retorno 
        "nao permite processamento de retorno."
        view-as alert-box.
        return.
    end.
    */
    sresp = no.
    message " Confirma processar o retorno  ?" update sresp.
    if sresp <> yes
    then return.

    def var reg-atu as int.
    def var dat-ret as date.
    def var arq-ret as char.
    
    for each lotcretit of lotcre :
        find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-error.
        if not avail titulo then next.
        find first titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-lock no-error.
        if not avail titulo2 then next.
        find forne where forne.forcod = titulo.clifor no-lock.
        assign
            aux-forcod = forne.forcod
            aux-fornom = forne.fornom
            aux-cgccpf = forne.forcgc
            .
        find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
        if avail forconpg and lotcre.ltdtenvio >= 07/30/14
        then assign
             aux-forcod = forconpg.forcod
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             aux-cgccpf = trim(aux-cgccpf)
             .
 
        find first tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = string(aux-cgccpf) and
               (if titulo2.dec1 = 0
                then*/ tt-arquivo.n-documento = titulo2.titnum
                /*else tt-arquivo.n-pagamento = string(titulo2.dec1))*/ and
               tt-arquivo.v-pagamento = (titulo.titvlcob + titulo.titjuro -
                                        titulo.titvldes) and
               tt-arquivo.clifor = titulo.clifor and
               /*tt-arquivo.t-retorno = sl-arquivo.t-retorno and*/
               tt-arquivo.marca = "*"
               no-error.                        
        if not avail tt-arquivo then next. 
        
        output to ./ltbradescoret-processa-pagamento.log.
        put lotcre.ltcrecod format ">>>>>>>>>9" skip.
            
            run processa-pagamento.

        output close.
        
        assign
            lotcretit.lottitpag  = tt-arquivo.d-pagamento
            dat-ret = tt-arquivo.d-arquivo
            arq-ret = tt-arquivo.n-arquivo
            .
        
        reg-atu = reg-atu + 1.        
                
    end.
    
    for each tt-lotcretit. delete tt-lotcretit. end.
    for each tt-titulo2. delete tt-titulo2. end.
    
    /***********
    for each agtitbra where
             agtitbra.ltcrecod = lotcre.ltcrecod
             no-lock:
        for each tt-lotcretit. delete tt-lotcretit. end.
        for each tt-titulo2. delete tt-titulo2. end.
        do lt = 1 to int(num-entries(agtitbra.char1,";")):
            create tt-lotcretit.
            tt-lotcretit.campo-rec = int(entry(lt,agtitbra.char1,";")).
            tt-lotcretit.titnum = agtitbra.titnum.
        end.
        do lt = 1 to int(num-entries(agtitbra.char2,";")):
            create tt-titulo2.
            tt-titulo2.campo-rec = int(entry(lt,agtitbra.char2,";")).
        end.

        for each tt-lotcretit no-lock,
            first lotcretit where
                recid(lotcretit) = tt-lotcretit.campo-rec no-lock
                :
            find first titulo where
               titulo.empcod = 19 and
               titulo.titnat = yes and
               titulo.modcod = lotcretit.modcod and
               titulo.etbcod = lotcretit.etbcod and
               titulo.clifor = lotcretit.clfcod and
               titulo.titnum = lotcretit.titnum and
               titulo.titpar = lotcretit.titpar
               no-error.
            if not avail titulo then next.
            find first titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-lock no-error.
            if not avail titulo2 then next.
            find forne where forne.forcod = titulo.clifor no-lock.
            assign
                aux-forcod = forne.forcod
                aux-fornom = forne.fornom
                aux-cgccpf = forne.forcgc
                .
            find first forconpg where
               forconpg.forcod = forne.forcod and
               forconpg.numban = titulo2.titbanpag and
               forconpg.numagen = entry(1,titulo2.titagepag,"-") and
               forconpg.numcon = entry(1,titulo2.titconpag,"-")
               no-lock no-error.
            if avail forconpg and lotcre.ltdtenvio >= 07/30/14
            then assign
             aux-forcod = forconpg.forcod
             aux-fornom = forconpg.rsnome
             aux-cgccpf = if forconpg.cpf <> ""
                          then forconpg.cpf else forconpg.cnpj
             aux-cgccpf = trim(aux-cgccpf)
             .
 
            find first tt-arquivo use-index i1 where
               /*tt-arquivo.n-cpfcnpj   = string(aux-cgccpf) and*/
               tt-arquivo.n-documento = agtitbra.titnum and
               tt-arquivo.v-pagamento = agtitbra.valor-pago and
               tt-arquivo.clifor = titulo.clifor and
               /*tt-arquivo.t-retorno = sl-arquivo.t-retorno and*/
               tt-arquivo.marca = "*"
               no-error.                        
            if not avail tt-arquivo then next. 
        
            output to ./ltbradescoret-processa-pagamento.log.
            put lotcre.ltcrecod format ">>>>>>>>>9" skip.
            
                run processa-pagamento.

            output close.
        
            assign
                lotcretit.lottitpag  = tt-arquivo.d-pagamento
                dat-ret = tt-arquivo.d-arquivo
                arq-ret = tt-arquivo.n-arquivo
                .
        
            reg-atu = reg-atu + 1.        
                
        end.
    end.
    *******/
    
    if dat-ret = ?
    then dat-ret = today.
    do on error undo.
        find lotcre where recid(lotcre) = par-reclotcre exclusive.
        assign
            lotcre.ltdtretorno = dat-ret
            lotcre.lthrretorno = vtime
            lotcre.ltfnretorno = sfuncod
            lotcre.arqretorno  = arq-ret
            .
        find current lotcre no-lock.
    end.
    
    message "Processamento realizado." skip
            "Registros atualizados: " reg-atu
        view-as alert-box.

end procedure.

procedure importa-dados-arquivo-retorno:
    input from value(varquivo).
    repeat:
        import unformatted vlinha.
        if substr(vlinha,1,1) = "G"
        then do:
        create tt-arquivo.
        assign
            tt-arquivo.i-registro       = substr(vlinha,1,1)
            tt-arquivo.t-cpfcnpj        = substr(vlinha,37,14)
            tt-arquivo.n-pagamento      = substr(vlinha,5,25)
            tt-arquivo.n-documento      = string(int(substr(vlinha,51,15)))
            tt-arquivo.d-vencimento     = date(int(substr(vlinha,131,2)),
                                               int(substr(vlinha,133,2)),
                                               int(substr(vlinha,127,4)))
            tt-arquivo.d-pagamento      = date(int(substr(vlinha,139,2)),
                                               int(substr(vlinha,141,2)),
                                               int(substr(vlinha,135,4)))
            tt-arquivo.t-retorno        = substr(vlinha,301,17)
            tt-arquivo.v-documento      = dec(int(substr(vlinha,72,11)) / 100)
            tt-arquivo.v-pagamento      = dec(int(substr(vlinha,116,11)) / 100)
            tt-arquivo.v-juro           = dec(int(substr(vlinha,94,11)) / 100)
            tt-arquivo.v-multa           = dec(int(substr(vlinha,105,11)) / 100)
            
            /*
            tt-arquivo.v-desconto       = dec(int(substr(vlinha,220,15)) / 100)
            tt-arquivo.v-acrescimo      = dec(int(substr(vlinha,235,15)) / 100)
            tt-arquivo.n-fatura        = substr(vlinha,252,10)
            tt-arquivo.m-pagamento      = int(substr(vlinha,264,2))
            tt-arquivo.t-movimento      = int(substr(vlinha,289,1))
            tt-arquivo.c-lancamento     = int(substr(vlinha,473,5))
            */
            tt-arquivo.d-arquivo        = date(data-arq)
            tt-arquivo.n-arquivo        = varquivo
            .
        end.
    end.
    input close.    
end procedure.

def var vl-juro as dec.
def var vl-desc as dec.
def var jur-titag as dec.
def var des-titag as dec.
def var qtd-titag as dec.
def var val-titag as dec.
def var vcompl as char.

procedure processa-pagamento:
    def var vtitvljur like titulo.titvljur.
    def var vtitvldes like titulo.titvldes. 
    def var vtitdtpag like titulo.titdtpag.
    def var vtitvlpag like titulo.titvlpag.
    def var vtotalpag like titulo.titvlpag.
    def var vformpaga as int.

    run desconto-antecipacao.
    
    assign
        vtitdtpag = tt-arquivo.d-pagamento
        vtitvljur = titulo.titvljur + vl-juro
        vtitvldes = titulo.titvldes + vl-desc
        vtotalpag = vtotalpag +
                  (titulo.titvlcob + vtitvljur - vtitvldes)
        .

    find first titulo2 where
                                titulo2.empcod = titulo.empcod and
                                titulo2.titnat = titulo.titnat and
                                titulo2.modcod = titulo.modcod and
                                titulo2.etbcod = titulo.etbcod and
                                titulo2.clifor = titulo.clifor and
                                titulo2.titnum = titulo.titnum and
                                titulo2.titpar = titulo.titpar and
                                titulo2.titdtemi = titulo.titdtemi
                                no-error.
    if avail titulo2
    then vformpaga =  titulo2.formpag.
    else vformpaga = 107.

    find first formpag where
               formpag.tipo   = "" and
               formpag.codigo = vformpaga
               no-lock.
               
    if titulo.titsit <> "PAG"
    then
    do on error undo:
        assign    
            titulo.titdtpag = vtitdtpag
            titulo.titvljur = vtitvljur
            titulo.titvldes = vtitvldes
            titulo.titvlpag = vtotalpag
            titulo.titsit = "PAG"
            .

        find first fatudesp where
                   /*fatudesp.etbcod = titulo.etbcod and*/
                   fatudesp.clicod   = titulo.clifor and
                   fatudesp.fatnum   = int(titulo.titnum) and
                   fatudesp.inclusao = titulo.titdtemi
                   no-lock no-error.
        if avail fatudesp
        then do:
            vcompl  = titulo.titnum + "-" + string(titulo.titnum)
                                    + " " + forne.fornom.
            run pag-tit-desp.
        end.
        else do:
            vcompl  = titulo.titnum + "-" + string(titulo.titnum)
                                    + " " + forne.fornom.
            run pag-titulo.
        end.           
    end.
end procedure.

procedure desconto-antecipacao:
    assign
        vl-juro = 0
        vl-desc = 0
        jur-titag = 0
        des-titag = 0
        qtd-titag = 0
        val-titag = 0
        .
    if acha("AGENDAR",titulo.titobs[2]) <> ? and
           titulo.titdtven <> date(acha("AGENDAR",titulo.titobs[2])) 
    then do:
        if acha("VALJURO",titulo.titobs[2]) <> "?"
        then vl-juro   = dec(acha("VALJURO",titulo.titobs[2])).
        else vl-juro   = 0.
        if acha("VALDESC",titulo.titobs[2]) <> "?"
        then vl-desc   = dec(acha("VALDESC",titulo.titobs[2])).
        else vl-desc = 0.
        if vl-juro = ? then vl-juro = 0.
        if vl-desc = ? then vl-desc = 0.
        if vl-juro <> ?
        then jur-titag = jur-titag + vl-juro + titulo.titvljur.
        if vl-desc <> ?
        then des-titag = des-titag + vl-desc + titulo.titvldes.
        qtd-titag = qtd-titag + 1.
        val-titag = val-titag + titulo.titvlcob.
    end.
end procedure.

procedure pag-tit-desp:
    
    run gera-titpag.
    
    for each tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi
             no-lock:
                
    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = tituctb.clifor and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = tituctb.modcod
                no-lock no-error.
    if avail lancactb
    then do:
        run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            tituctb.modcod,
                            titulo.titdtpag,
                            (tituctb.titvlcob + 
                            tituctb.titvljur -
                            tituctb.titvldes),
                            tituctb.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").
    end. 
    end.                           
end procedure. 

procedure pag-titulo:
              
    find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    if not avail lancactb
    then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    
    if avail lancactb
    then do:
        if titulo.agecod <> "FRETE"
        then
        run lan-contabil("CAIXA",
                            lancactb.contadeb,
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").

        if titulo.agecod = "FRETE"
        then
        run lan-contabil("CAIXA",
                            "559",
                            formpag.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvlpag,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            lancactb.int2,
                            vcompl,
                            "C").

        if titulo.titvljur > 0 
        then do:
            run lan-contabil("CAIXA",
                            228,
                            lancactb.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvljur,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            13,
                            vcompl,
                            "C").

        end.    
                        
        if titulo.titvldes > 0  
        then do:
            run lan-contabil("CAIXA",
                            235,
                            lancactb.contacre,
                            titulo.modcod,
                            titulo.titdtpag,
                            titulo.titvldes,
                            titulo.clifor,
                            titulo.titnum,
                            titulo.etbcod,
                            12,
                            vcompl,
                            "C").
        end.
    end.    
    run gera-titpag.
end procedure. 


procedure lan-contabil:
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like titulo.clifor.
    def input parameter l-titnum like titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.
    def input parameter l-lantipo as char.
    def var vnumlan as int. 
    def buffer blancxa for lancxa.
    def buffer elancxa for lancxa.
    /*
    if l-landeb = 448 and
       l-landeb = 447 and
       l-landeb = 362
    then l-hiscod = "262".
    */
           
    if l-tipo = "CAIXA"
    THEN
    do on error undo:

            find first elancxa where 
                       elancxa.cxacod = lancactb.contadeb and
                       elancxa.modcod = l-modcod and
                       elancxa.forcod = l-forcod and
                       elancxa.titnum = l-titnum and
                       elancxa.lantip = "X"
                        no-error.
            if avail elancxa 
            then do on error undo:
                if month(titulo.titdtpag) = month(titulo.titdtemi) and
                   year(titulo.titdtpag) = year(titulo.titdtemi)
                then delete elancxa.
                else if lancactb.contadeb > 0
                then l-landeb = elancxa.lancod.
            end.    
            else. /* l-landeb = lancactb.contadeb.*/
             
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = l-lantipo and
                       lancxa.comhis = l-hiscomp and
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do:            
            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            
            create lancxa.
            assign lancxa.cxacod = l-lancre
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-landeb
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = l-lantipo
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO ON ERROR UNDO:
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-lancre and
                       lancxa.lancod = l-landeb and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"      and
                       lancxa.comhis = l-hiscomp and
                       lancxa.etbcod = l-etbcod
                        no-error.
            if not avail lancxa
            then do: 
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
             
                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-lancre
                    lancxa.lancod = l-landeb
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
end procedure.
 
procedure gera-titpag:
    find first titpag where
               titpag.empcod = titulo.empcod and
               titpag.titnat = titulo.titnat and
               titpag.modcod = titulo.modcod and
               titpag.etbcod = titulo.etbcod and
               titpag.clifor = titulo.clifor and
               titpag.titnum = titulo.titnum and
               titpag.titpar = titulo.titpar and
               titpag.moecod = string(formpag.codigo)
               no-error.
    if not avail titpag
    then do:
        create titpag.
        assign
            titpag.empcod = titulo.empcod
            titpag.titnat = titulo.titnat
            titpag.modcod = titulo.modcod
            titpag.etbcod = titulo.etbcod
            titpag.clifor = titulo.clifor
            titpag.titnum = titulo.titnum
            titpag.titpar = titulo.titpar
            titpag.moecod = string(formpag.codigo)
            titpag.titvlpag = titulo.titvlpag 
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
    else do:
        assign
            titpag.titvlpag = titulo.titvlpag 
            titpag.moecod = string(formpag.codigo)
            titpag.cxacod = scxacod
            titpag.cxmdata = today
            titpag.cxmhora = string(time)
            titpag.datexp  = today
            titpag.exportado = no.
    end.
end procedure. 

procedure paga-titudesp.
    for each titudesp where
             titudesp.clifor = titulo.clifor and
             titudesp.titnum = titulo.titnum and
             titudesp.titpar = titulo.titpar and
             titudesp.titdtemi = titulo.titdtemi
             .
        assign
            titudesp.titdtpag = titulo.titdtpag
            titudesp.titvlpag = titudesp.titvlcob
            titudesp.titsit   = titulo.titsit
            .         
    end.
    for each tituctb where
             tituctb.clifor = titulo.clifor and
             tituctb.titnum = titulo.titnum and
             tituctb.titpar = titulo.titpar and
             tituctb.titdtemi = titulo.titdtemi
             .
        assign
            tituctb.titdtpag = titulo.titdtpag
            tituctb.titvlpag = tituctb.titvlcob
            tituctb.titsit   = titulo.titsit
            .         
    end.

                                        
end.

procedure ver-lancactb:
    v-lancactb = yes.
    
    find first fatudesp where 
               fatudesp.clicod = titulo.clifor and
               fatudesp.fatnum = int(titulo.titnum)
               no-lock no-error.
    if not avail fatudesp
    then do:           
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = titulo.etbcod and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = titulo.clifor and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = titulo.modcod
                no-lock no-error.
    
        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " titulo.modcod
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.

            v-lancactb = no.
        end.
    end.
    else do:
        find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = fatudesp.etbcod and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = fatudesp.clicod and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.
        if not avail lancactb
        then find first  lancactb where
                lancactb.id = 0  and
                lancactb.etbcod = 0 and
                lancactb.forcod = 0 and
                lancactb.modcod = fatudesp.modctb
                no-lock no-error.

        if not avail lancactb
        then do:
            bell.
            message color red/with
            "CONTA CONTABIL para modalidade " fatudesp.modctb
             " nao esta cadastrada." skip
            "Favor resolver com o SETOR DE CONTABILIDADE."
             view-as alert-box.
            v-lancactb = no.
        end.
    end.
end procedure.


