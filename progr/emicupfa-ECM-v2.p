{admcab.i}

def var varquivo as char.
def var vetbcod like estab.etbcod.
def var vnumero like plani.numero format ">>>>>>>>9".
def var vcupfa as char.
def var vqtdcup as int.
def var vi as int.
def var vnumcup as int.
def var dnumcup as int.
def var vcatcod like produ.catcod.
def var senha-cal as int.
def var vsenaudi as int.

vnumero = 0.
vetbcod = 200.

disp vetbcod label "Filial       "
    with frame f1.

find estab where estab.etbcod = vetbcod no-lock.

disp estab.etbnom no-label with frame f1.

def var vdata as date.
def var vdti as date.
def var vdtf as date.

update vdti at 1 format "99/99/9999" label "Periodo Venda"
       vdtf format "99/99/9999" label "a"
       with frame f1 side-label width 80 row 4.

if vdti = ? or vdtf = ? or vdti > vdtf
then do:
    bell.
    message color red/with
    "FAVOR VERIFICAR O PERIODO INFORMADO."
     view-as alert-box.
    undo, retry. 
end.

if vdti < 11/01/18 or vdtf > 12/25/18 or vdti > vdtf
then do:
    bell.
    message color red/with
    "PERIODO INFORMADO FORA DA PROMOCAO."
     view-as alert-box.
    undo, retry. 
end.

def temp-table tt-campanha
    field marca as char forma "x"
    field numero like plani.numero
    field pladat like plani.pladat
    field platot like plani.platot   
    field ncupom as int
    field privia as log format "Sim/Nao"
    field segvia as log format "Sim/Nao"
    index i1 pladat numero
         .
 
do vdata = vdti to vdtf:

    if vdata < 11/01/18 or
       vdata > 12/25/18
    then next.   
    for each plani where plani.etbcod = 200 and
                     plani.movtdc = 5 and
                     plani.pladat = vdata 
                     no-lock:

        run regras-validacoes.
    end.
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
    initial [" Consulta"," Marca/Desmarca"," Marca Tudo"," Desmarca Tudo"," Marcados"].
def var esqcom2         as char format "x(15)" extent 5
            initial [""," Primeira via"," Segunda via",""," Parametros"].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["",
            "",
            "",
            "",
            ""].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var p-numero as int format ">>>>>>>>>".

form tt-campanha.marca no-label
     tt-campanha.numero column-label "Numero Venda"
     tt-campanha.pladat column-label "Data Venda"
     tt-campanha.platot column-label "Valor Venda"
     tt-campanha.ncupom column-label "Qtd. Cupons"
     tt-campanha.privia column-label "Primeira Via" 
     tt-campanha.segvia column-label "Segunda Via"
     with frame f-linha 12 down color with/cyan width 80 row 5
     centered title " Campanha Final de Ano do Filial "
      + STRING(vetbcod) + " Periodo " + string(vdti) + " a " + string(vdtf).
                                                                                
def var i as int.

def var vmarca as char.

color display message esqcom1[esqpos1] with frame f-com1.

l1: repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        /*esqpos1 = 1 esqpos2 = 1*/. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file  = tt-campanha  
        &cfield = tt-campanha.numero
        &noncharacter = /* 
        &ofield = " tt-campanha.marca
                    tt-campanha.pladat
                    tt-campanha.platot
                    tt-campanha.ncupom
                    tt-campanha.privia when tt-campanha.privia = yes
                    tt-campanha.segvia when tt-campanha.segvia = yes
                    "  
        &aftfnd1 = " "
        &where  = " if esqcom1[esqpos1] = "" Marcados"" and
                        vmarca = ""*""
                    then tt-campanha.marca = vmarca 
                    else true "
        &aftselect1 = " run aftselect.
                        if esqcom1[esqpos1] = "" Desmarca tudo"" or
                           esqcom1[esqpos1] = "" Marca tudo"" or
                           esqcom1[esqpos1] = "" Marcados ""  or
                           esqcom2[esqpos2] = "" Primeira Via"" or
                           esqcom2[esqpos2] = "" Segunda Via"" or
                           esqcom2[esqpos2] = "" Parametros""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " bell.
                    message color red/with
                    ""Nenhum registro encontrado.""
                    view-as alert-box. 
                    vmarca = """".
                    leave l1." 
        &otherkeys1 = " run controle.  "
        &locktype = " no-lock "
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
    if esqregua
    then do:
    if esqcom1[esqpos1] = " Consulta"
    then do:
        find first  plani where
                        plani.movtdc = 5       and
                        plani.etbcod = vetbcod and
                        plani.numero = tt-campanha.numero and
                        plani.pladat = tt-campanha.pladat
                        no-lock no-error.
        if avail plani and acha("PROMOCUPFA",plani.notobs[1]) <> ?
        then do:
            disp  plani.numero label "   Numero Venda"
                  acha("PROMOCUPFA",plani.notobs[1]) format "x(50)"
                  label "Cupons Emitidos"
                  acha("REIMP-PCF",plani.notobs[1]) format "x(50)"
                  Label "     Reemissoes"
            with frame f-cns overlay 1 column side-label row 9 
            centered.
        end.    
    end.
    if esqcom1[esqpos1] = " Marca/Desmarca"
    THEN DO on error undo:
        find current tt-campanha.
        /*if tt-campanha.privia = no then do:*/
            if tt-campanha.marca = "" then tt-campanha.marca = "*".
            else tt-campanha.marca = "".
            a-seeid = a-recid.
            a-recid = recid(tt-campanha).
            vmarca = "".
        /*end.*/
    END.
    if esqcom1[esqpos1] = " Marca tudo"
    THEN DO:
        for each tt-campanha where tt-campanha.privia = no:
            tt-campanha.marca = "*".
            vmarca = "".
        end.    
    END.
    if esqcom1[esqpos1] = " Desmarca tudo"
    THEN DO:
        for each tt-campanha:
            tt-campanha.marca = "".
            vmarca = "".
        end.    
    END.
    if esqcom1[esqpos1] = " Marcados"
    THEN DO:
        if vmarca = ""
        then vmarca = "*".
        else vmarca = "".
    END.
    end.
    else do:
    if esqcom2[esqpos2] = " Primeira via"
    THEN DO on error undo:
        find first tt-campanha where tt-campanha.marca = "*"
                no-error.
        if not avail tt-campanha
        then do:
            bell.
            message color red/with
            "Nenhuma venda marcada."
            view-as alert-box.  
        end.        
        else do:
            sresp = no.
            message "Confirma emitir cupons das vendas selecionadas?"
            update sresp.
            if sresp
            then run imprime-cupom ("primeira").
        end.
    END.
    if esqcom2[esqpos2] = " Segunda via"
    THEN DO on error undo:
        sresp = no.
        message "Confirma emitir SEGUNDA VIA de cupons das vendas selecionadas?"
        update sresp.
        if sresp
        then do:
            find current tt-campanha.
            tt-campanha.marca = "*".
            run imprime-cupom ("segunda").
        end.
    END.
    if esqcom2[esqpos2] = " Parametros"
    then do on error undo:
        find first tabaux where
                 tabaux.tabela = "CUPFA-SAIDA" 
                 no-error.
        if not avail tabaux
        then do on error undo:
            create tabaux.
            assign
                tabaux.tabela = "CUPFA-SAIDA"
                    .
        end.

        update  tabaux.nome_campo 
                 validate(tabaux.nome_campo = "TELA" or
                            tabaux.nome_campo = "IMPRESSORA","")
                label "Saida"
                help "Informat se saida Tela ou Impressora"
                tabaux.valor_campo label "Dispositivo"
                help "Informe o nome do dipositivo."
                with frame f-parametros 1 down centered side-label.

    end.
    end.
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
            if keyfunction(lastkey) = "P" or
               keyfunction(lastkey) = "p"
            then do:
                update p-numero with frame f-procura 1 down centered row 7
                side-label overlay.
                if p-numero > 0
                then do:
                    find first tt-campanha where 
                               tt-campanha.numero = p-numero
                                no-error.
                    if avail tt-campanha
                    then assign
                            a-seeid = -1
                            a-recid = recid(tt-campanha).
                end.                
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then 
    varquivo = "/admcom/relat/" + string(setbcod) + "."
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


procedure imprime-cupom: 
    def input parameter p-tipo as char.
    def var par-rec as recid.
    def var vseq-cupom-promo as char.
    def var vpromocupfa as char.
    def var vreimppcf as char.
    def var vnumcup as int.
    def var vqtd-cup as int.
    def var v-c as int.
    def var vfunnom as char.
    def var fila as char.
    def var recimp as recid.
    def buffer bestab for estab.
    fila = "".
    for each tt-campanha where tt-campanha.marca = "*" /*and
                               tt-campanha.privia = no   */
                               :
                               
        find first  plani where
                        plani.movtdc = 5       and
                        plani.etbcod = vetbcod and
                        plani.numero = tt-campanha.numero and
                        plani.pladat = tt-campanha.pladat
                        no-lock no-error.
        if not avail plani
        then next.

        vnumcup = 0.
        
        if acha("PROMOCUPFA",plani.notobs[1]) <> ? and
            p-tipo = "PRIMEIRA"
        then next.
        else if acha("PROMOCUPFA",plani.notobs[1]) <> ? and
            p-tipo = "SEGUNDA"
        then do:
            vpromocupfa = acha("PROMOCUPFA",plani.notobs[1]).
            vqtd-cup = int(entry(1,vpromocupfa,";")).
            vnumcup = int(substr(entry(2,vpromocupfa,";"),1,
            length(entry(2,vpromocupfa,";")) - 3)) - 1.
            if acha("REIMP-PCF",plani.notobs[1]) <> ?
            then do:
                vreimppcf = string(int(acha("REIMP-PCF",plani.notobs[1])) + 1).
            end.
            else vreimppcf = "1".
        end.

        find bestab where bestab.etbcod = plani.etbcod no-lock.
        par-rec = recid(plani).
        vpromocupfa = "".
        vqtd-cup = tt-campanha.ncupom.
        vseq-cupom-promo = "CUPFA" + string(plani.etbcod,"999").
        if vqtd-cup > 0
        then do:
            if p-tipo = "PRIMEIRA"
            then do:
            find tabaux where
                 tabaux.tabela = vseq-cupom-promo and
                 tabaux.nome_campo = "NUMERO"
                 no-error.
            if not avail tabaux
            then do on error undo:
                create tabaux.
                assign
                    tabaux.tabela = vseq-cupom-promo
                    tabaux.nome_campo = "NUMERO"
                    .
            end.
            vnumcup = int(tabaux.valor_campo).
            end.
                     
            vpromocupfa = string(vqtd-cup) + ";".
        
            varquivo = "/admcom/relat/" + 
                       "pfa_" + string(plani.etbcod,"999") + "_" +
                       string(year(today),"9999") + "_" +
                       string(plani.numero) + "." + string(time).
                
            find func where func.funcod = plani.vencod and 
                            func.etbcod = plani.etbcod no-lock no-error.
            if avail func
            then vfunnom = func.funnom.
            else vfunnom = "".
            output to value(varquivo).
            do v-c = 1 to vqtd-cup:
            
                vnumcup = vnumcup + 1.
            
                dnumcup = int(string(vnumcup) + string(plani.etbcod,"999")).
            
                vpromocupfa = vpromocupfa + string(dnumcup) + ";".

            /****
            varquivo = "/admcom/relat/" + 
                       "pfa_" + string(plani.etbcod,"999") + "_" +
                       string(year(today),"9999") + "_" +
                       string(plani.numero) + "." + string(dnumcup).
            
            output to value(varquivo).
            ***/

            put chr(29) + chr(33) + chr(0)  skip . /* tamanho da fonte */
            put chr(27) + chr(97) + chr(49)  .       /* centraliza */
            put chr(27) + chr(51) + chr(25)  . /* espaco 1/6 entre lin */
            put chr(27) + "!" + chr(48)   skip  . /* negrito */
            
            put "Lojas Lebes" skip(2) .
            
            put chr(27) + "!" + chr(8).
            
            put "Filial " trim(string(estab.etbcod) + " - " + estab.munic) format "x(50)" skip(2).
            
            /*put trim(bestab.endereco /*+ " " + bestab.munic*/) format "x(30)" 
            skip.*/
            /*put  bestab.munic format "x(30)" skip.*/
            /*if length(bestab.etbserie) > 2
            then put " Fone: " trim(bestab.etbserie) format "x(13)" skip.*/
            put "Cupom: " trim(string(dnumcup,">>>>>9999")) + "-" +
                        string(vcatcod) format "x(15)" skip.

            put chr(27) + chr(97) + chr(48) skip.    /* justifica esquerda */ 

            
            find cliecom where cliecom.clicod = plani.desti 
                        no-lock no-error.
            
            if avail cliecom and cliecom.clicod > 1
            then do:
            put /*"Filial/Cx: " string(bestab.etbcod,"999") +  " - " +
                string(plani.cxacod,"99") + 
                "Hora: " + string(time,"hh:mm") format "x(30)" skip*/
                "Cliente  : " cliecom.clinom format "x(30)" skip
                "CPF      : " cliecom.cpfcgc                       skip
                "RG       : " cliecom.ciinsc                       skip
                "Endereco : " cliecom.endereco format "x(30)"   skip
                "Numero   : " string(cliecom.numero) + " - " + cliecom.cidade 
                                format "x(30)" skip
                "E-mail   : " cliecom.email format "x(30)"    skip
                                "Consultor: " string(plani.vencod) + " - " + 
                                vfunnom format "x(30)" skip
                "NF.Venda : " string(plani.numero) + "/" + plani.serie + " - "
                     string(plani.pladat,"99/99/9999") format "x(30)" skip 
                "Telefone: " + cliecom.foneres  format "x(30)"
                                skip(2)
                "_________________________________________" skip(2)    
                
                "Qual a rede de lojas que podera" skip
                "realizar seu sonho de Natal?" skip
                "(X) Lojas Lebes (  ) Outras" skip(3)
                "   ___________________________________   " skip
                "          Assinatura do Cliente          " skip(2)
                
                "O regulamento completo estara" skip
                "disponibilizado nas Lojas Lebes." skip
                "Certificado de autorizacao SEAE" skip
                "numero 06.000542/2018 " skip.

                                                              
            end.
            else do:
            put "Filial/Cx: " string(plani.etbcod,"999") +  " - " +
                string(plani.cxacod,"99") + 
                   "  Hora: " + string(time,"hh:mm") format "x(30)" skip
                "Cliente  : ____________________________" skip
                "CPF      : ____________________________" skip
                "RG       : ____________________________" skip
                "Endereco : ____________________________" skip
                "Numero   : ____________________________" skip
                "E-mail   : ____________________________" skip
                                "Consultor: " string(plani.vencod) + " - " + 
                                vfunnom format "x(30)"  skip
                "NF.Venda : " string(plani.numero) + "/" + plani.serie + " - "
                     string(plani.pladat,"99/99/9999") format "x(30)" skip
                                "Telefone:________________________________" 
                                skip(2)
                "_________________________________________" skip(2)
                
                "Qual a rede de loja que voce" skip
                "ta podendo bater um bolao?" skip
                "(X) Lojas Lebes (  ) Outras" skip(3)
                "   ___________________________________   " skip
                "          Assinatura do Cliente          " skip(2)
                
                "O regulamento completo estara" skip
                "disponibilizado nas Lojas Lebes." skip
                "Certificado de autorizacao SEAE" skip
                "numero 02.000382/2018" skip

		"--------------------------------------------" skip
		"Premios de ate R$5.000,00 (cinco mil reais):" skip
		"( ) 01 Celular" skip
		"( ) 01 Viagem dentro do Brasil com acompanhante" skip
		"( ) 01 TV" skip
		"( ) Outro: Qual seu sonho de ate R$5.000,00?" skip
		"	    Escreva:_________________________" skip(2)
		
		"Premios de ate R$10.000,00 (dez mil reais):" skip
		"( ) 01 Vale reforma" skip
		"( ) 01 Mobilia para casa com produtos Lebes" skip
		"( ) 01 Moto (compra nas Lojas Lebes, modelo 50CC" skip
		"( ) Outro: Qual seu sono de ate R$10.000,00?" skip
		"	    Escreva:_________________________" skip.
                                                                 
            end.
            put chr(10)  skip  .  /* line feed */
            put chr(29) + chr(86) + chr(66)  skip  .      /* corta */ 

            /***
            output close.
            if scarne = "local"
            then unix silent /fiscal/lp value(varquivo).
            else unix silent /fiscal/lp value(varquivo) 1.
            ***/
            end.
            output close.
            
            if p-tipo = "PRIMEIRA"
            then do on error undo:
            tabaux.valor_campo = string(vnumcup).
            end.
            
            find first tabaux where tabaux.tabela = "CUPFA-SAIDA" 
                 no-lock no-error.
            if not avail tabaux
            then do:
                bell.
                message color red/with
                "Cadatrar dispositivo de saidas na aba PARAMETROS."
                view-as alert-box.
            end.
            else do:
                if tabaux.nome_campo = "TELA"
                then do:
                    run value(tabaux.valor_campo)(input varquivo, "").
                end.
                else if tabaux.nome_campo <> ""
                then do:
                    if tabaux.valor_campo <> ""
                    then do:
                        unix silent value(tabaux.valor_campo + " " +
                                        varquivo).
                    end.
                    else do:
                        if fila = ""
                        then do:
                        find first  impress where 
                                impress.codimp = setbcod no-lock no-error.
                        if avail impress
                        then do:
                            run acha_imp.p (input recid(impress),
                                        output recimp).
                            find impress where recid(impress) = recimp 
                                no-lock no-error.
                            if avail impress
                            then do:
                                fila = string(impress.dfimp).
                                os-command silent 
                                    value("lpr " + fila + " " + varquivo).
                            end.
                            else fila = "".
                        end.
                        end.
                        else do:
                            os-command silent 
                                value("lpr " + fila + " " + varquivo).
                        end.
                    end.
                end.
            end.
        end.
        find plani where recid(plani) = par-rec no-error.
        if avail plani
        then do :
            if p-tipo = "PRIMEIRA"
            then assign
                    plani.notobs[1] = plani.notobs[1] +
                        "|PROMOCUPFA=" + vpromocupfa 
                    tt-campanha.privia = yes.
            else assign
                    plani.notobs[1] = plani.notobs[1] +
                        "|REIMP-PCF=" + vreimppcf
                    tt-campanha.segvia = yes    
                        .
        
        end.
        release plani.

        tt-campanha.marca = "".
    end. 
end procedure.

procedure regras-validacoes:
    def var vtt-venda as dec.
    def var vcatcod as int.
    def var vqtd-cup as int.
    def var vqtd-tot as int.
    
    find clien where clien.clicod = plani.desti no-lock no-error.
    vtt-venda = plani.protot.
    vqtd-cup = 0.
    
    if vtt-venda >= 200 
    then do:
       
        vcatcod = 0.
        vtt-venda = 0.
        
        for each movim where movim.etbcod = plani.etbcod and
                         movim.placod = plani.placod and
                         movim.movtdc = plani.movtdc and
                         movim.movdat = plani.pladat
                         no-lock:
            find produ where produ.procod = movim.procod no-lock no-error.
            if not avail produ then next.
            vtt-venda = vtt-venda + (movim.movpc * movim.movqtm).
            if vcatcod = 0
            then vcatcod = produ.catcod.
            
            if vcatcod = 41 and
               produ.catcod = 31
            then vcatcod = produ.catcod. 

        end.           
        vqtd-tot = int(substr(string(vtt-venda / 200,">>>9.999"),1,4)).
        vqtd-cup = vqtd-tot.
    end. 

    if vqtd-cup > 0
    then do:
        create tt-campanha.
        assign
            tt-campanha.numero = plani.numero
            tt-campanha.pladat = plani.pladat
            tt-campanha.platot = plani.protot
            tt-campanha.ncupom = vqtd-cup
            tt-campanha.privia = no
            tt-campanha.segvia = no
            .

        if acha("PROMOCUPFA",plani.notobs[1]) <> ?
        then tt-campanha.privia = yes.
        if acha("REIMP-PCF",plani.notobs[1]) <> ?
        then tt-campanha.segvia = yes.
 
    end.
end procedure.
