{admcab.i}
{setbrw.i}                                                                      

def new shared temp-table tt-cli
    
    field clicod like clien.clicod
    field clinom like clien.clinom
    
    index iclicod is primary unique clicod.

def var vdata-devol as date.
def var vdata-devolc as date.

def var marca-situacao as int.

def var vsituacao as char init "" .
def var vcodoper as int init 999.
def var vdig as int.
def var vclicod like clien.clicod init 0.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  Procura","  Inclui","",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["",
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

def var vdt-correio as date.
form 
     tbcartao.clicod      format ">>>>>>>>>9" 
     clien.clinom      format "x(20)"
     tbcartao.dtinclu  column-label "Dt.Pedido"
     vvia as char format "x(13)" column-label "Via"
     /*tbcartao.campochar[1] format "x(20)" no-label
     */
     vmotivo as char format "x(20)" column-label "Motivo"
     with frame f-linha 12 down color with/cyan /*no-box*/
     width 80.
                                                                         
disp "                          SOLICITACAO CARTAO LEBES       " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
    
def temp-table tt-tbcartao like tbcartao.
def buffer btbcartao  for tbcartao.
 
vcodoper = setbcod.
  
l1: repeat:
    clear frame f-com1.
    hide frame f-com1.
    clear frame f-com2.
    hide frame f-com2.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = tbcartao  
        &cfield = tbcartao.clicod
        &noncharacter = /* 
        &ofield = " tbcartao.clicod
                    clien.clinom
                    tbcartao.dtinclu
                    vvia
                    vmotivo
                    "  
      &aftfnd1 =  " 
                 find clien where clien.clicod = tbcartao.clicod no-lock. 
                 vvia = acha(""Solicita"",tbcartao.campochar[1]).
                 vmotivo = acha(""Motivo"",tbcartao.campochar[1]).
                 if vvia = ? then vvia = """".
                 if vmotivo = ? then vmotivo = """".
                 if vvia = """"
                 then vvia = tbcartao.campochar[1].
                 "
        &where  = " tbcartao.codoper = vcodoper and
                    tbcartao.situacao = """"
                  "
        &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                sresp = no.
                message  ""Nenhum registro encontrato. Incluir solicitacao? ""
                update sresp.
                if not sresp
                then leave l1.
                run inclui.
                next l1.
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
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo:
        run inclui.
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO:
        run altera.
    END.
    if esqcom1[esqpos1] = "  procura"
    THEN DO:
        update vclicod   format ">>>>>>>>>9" label "Conta"
                with frame f-filtro 1 down centered row 8 side-label
                color message title "Filtro" overlay
                .
        find first tbcartao where 
                   tbcartao.codoper = vcodoper and
                   tbcartao.clicod = vclicod and
                   tbcartao.situacao = ""
                   no-lock no-error.
        if not avail tbcartao
        then do:
            message color red/with
             "Nenhum registro encontrado."
             view-as alert-box.
        end.
        else a-recid = recid(tbcartao).            
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

procedure inclui:
    def var a as int.
    def var b as int.
    def var vindex as int.
    def var vmotivo as char extent 4 format "x(40)".
    def var vnome like clien.clinom.
    def var v-solicita as char init "PRIMEIRA VIA".
    def var vmot as char format "x(35)" extent 5
        init["NAO RECEBEU","PERDA OU ESTRAVIO","ROUBO OU ASSALTO",
                "ALTERACAO E OU ALTERAÇÃO DO NOME","OUTROS"]
        .
    def var vfenv as char no-undo format "x(20)" extent 2
        init ["CORREIO", "FILIAL"].
    def var vfenvInd as int no-undo.
    
    create tt-tbcartao.
    tt-tbcartao.dtinclu = today.
    
    disp tt-tbcartao.dtinclu at 1 label "Data Pedido"
        with frame f-inc.
    
    update  tt-tbcartao.clicod at 7 format ">>>>>>>>>9" 
            with frame f-inc 1 down centered row 5
            side-label width 80.
    
    find clien where clien.clicod = tt-tbcartao.clicod no-lock.
    
    disp clien.clinom no-label with frame f-inc.
    
    tt-tbcartao.hrinclu = time.
    tt-tbcartao.validade = ?.
    tt-tbcartao.datexp = today.
    
    find last btbcartao use-index indx2 where
              /*btbcartao.codoper = vcodoper and*/
              btbcartao.clicod  = tt-tbcartao.clicod
              no-lock no-error.
    
    if not avail btbcartao
    then tt-tbcartao.nrocartao = "10" + string(clien.clicod,"9999999999").
    else if btbcartao.situacao = "C"
    then do:
        if substr(btbcartao.nrocartao,1,1) = "0"
        then vdig = int(substr(btbcartao.nrocartao,2,2)).
        else vdig = int(substr(btbcartao.nrocartao,1,2)).
        tt-tbcartao.nrocartao = string(vdig + 10) + 
                                string(clien.clicod,"9999999999").
    end.
    else do:
        bell.
        disp 
           "Cliente " btbcartao.clicod " possui cartao " btbcartao.nrocartao
             " em situacao " btbcartao.situacao  skip
             with frame f-x no-box row 9.
             .
        if today - btbcartao.dtinclu > 45
        then v-solicita = "SEGUNDA VIA". 
        else do:
            v-solicita = "RETORNA".
            message color red/with
                    "Cartão ja solicitado nos últimos 45 dias."
                    view-as alert-box.
                      
        end. 
    end.
    if v-solicita = "RETORNA"
    then.
    else do:
        if tt-tbcartao.nrocartao = ""
        then do:
            if substr(btbcartao.nrocartao,1,1) = "0"
            then vdig = int(substr(btbcartao.nrocartao,2,2)).
            else vdig = int(substr(btbcartao.nrocartao,1,2)).
            tt-tbcartao.nrocartao = string(vdig + 10) + 
                                string(clien.clicod,"9999999999").

        end.

        tt-tbcartao.contacli = dec(tt-tbcartao.nrocartao).
        assign
            tt-tbcartao.codoper = setbcod
            tt-tbcartao.situacao = ""
            b = 0 
            a = 0
            vnome = ""
            b = num-entries(clien.clinom," ").
            
        if length(clien.clinom) > 26
        then do a = 1 to b:
            if a = 1
            then vnome = entry(1,clien.clinom," ").
            else if a = b
            then vnome = vnome + " " + entry(b,clien.clinom," ").
            else vnome = vnome + " " + 
                         substr(entry(a,clien.clinom," "),1,1).
        end.
        else vnome = clien.clinom.
    
        tt-tbcartao.clinom  =  vnome.

        if v-solicita = "SEGUNDA VIA"
        then disp "O CARTAO ATUAL SERA CONCELADO..." 
             with frame f-xx.
        sresp = no.
        disp "Confirma solicitacao da " 
             v-solicita no-label format "x(13)" " ? "
             with frame f-xx color message no-box row 12.
             update sresp no-label with frame f-xx.
        if sresp
        then do:
            if tt-tbcartao.codoper = 0 or
               tt-tbcartao.nrocartao = ""
            then do:
                message color red/with
                        "SOLICITAÇÃO CANCELADA POR FALTA DE DADOS."                                      view-as alert-box
                                .
            end.
            ELSE DO:
                tt-tbcartao.campochar[1] = "SOLICITA=" + v-solicita + "|".
                if v-solicita = "SEGUNDA VIA"
                THEN DO:
                    disp skip(1) 
                         vmot with frame f-mot no-label 1 column 
                         title "Motivo da solicitacao" row 14
                         column 1.
                            
                    choose field vmot with frame f-mot.
                    vmotivo = "".
                    vindex = frame-index.
    
                    if vmot[vindex] = 
                      "ALTERACAO E OU ALTERAÇÃO DO NOME"
                    then do:
                        bell.
                        message color red/with
                                "Atualizar o cadastro do cliente." skip
                                "Favor encaminhar o cliente ao crediário."
                                view-as alert-box.
                    end.
                    if vmot[vindex] = "OUTROS"
                    then do:
                        disp "Outros Motivos:" at 1 
                             no-label with frame f-motivo.
                        update  vmotivo[1] at 1 no-label
                                vmotivo[2] at 1 no-label
                                vmotivo[3] at 1 no-label
                                vmotivo[4] at 1 no-label
                                with frame f-motivo side-label
                                1 down no-box row 16 column 40
                                overlay.     
                        tt-tbcartao.campochar[1] = 
                            tt-tbcartao.campochar[1] +
                            "MOTIVO=" + vmot[vindex] + "|" +
                            "OUTROS=" + vmotivo[1] + " " +
                                        vmotivo[2] + " " +
                                        vmotivo[3] + " " +
                                        vmotivo[4] + "|".
                    end.                
                    else
                        tt-tbcartao.campochar[1] = tt-tbcartao.campochar[1] +
                                                "MOTIVO=" + vmot[vindex] + "|".

                    pause.
                END.
                
                /* forma de envio */
                disp skip(1)
                     vfenv with frame f-env no-label 1 column
                     title "Forma de envio" row 14
                     column 1.
                                                  
                choose field vfenv with frame f-env.
                vfenvInd = frame-index.
                
                if vfenv[vfenvInd] <> "" then
                   tt-tbcartao.ct-forenv = vfenv[vfenvInd].
                
                if sresp
                then do transaction:
                    if v-solicita = "SEGUNDA VIA"
                    then do:
                        find last btbcartao use-index indx2 where
                                  btbcartao.codoper = vcodoper and
                                  btbcartao.clicod  = tt-tbcartao.clicod
                                  no-error.
                        if avail btbcartao
                        then btbcartao.situacao = "C".
                    end.
                    /*
                    tt-tbcartao.campochar[1] = v-solicita.
                    */
                    do on error undo:   
                        create tbcartao.
                        buffer-copy tt-tbcartao to tbcartao.
                    end.
                end.    
                
                message color red/with
                        "SOLICITAÇÃO REALIZADA COM SUCESSO."
                        view-as alert-box.
            END.
        end.
        else do:
            message color red/with
                    "SOLICITAÇÃO CANCELADA."
                    view-as alert-box.
        end.
    end.
end procedure.

procedure altera:
    for each tt-tbcartao: delete tt-tbcartao. end.
    create tt-tbcartao.
    buffer-copy tbcartao to tt-tbcartao.
    vdt-correio = date(acha("DATA-CORREIO",tbcartao.trilha[5])).
    vdata-devolc =  date(acha("DEV-CORREIO",tbcartao.trilha[5])).
    disp tbcartao.clicod at 4 format ">>>>>>>>9" 
            with frame f-alt 1 down centered row 8
            side-label overlay color message.
    find clien where clien.clicod = tbcartao.clicod no-lock.
    disp clien.clinom no-label with frame f-alt.
    disp tbcartao.contacli at 3 label "Cartao" with frame f-alt.
    disp tbcartao.dtinclu at 1 label "Inclusao" with frame f-alt.
    disp tbcartao.validade at 1 with frame f-alt.
    if tbcartao.situacao = "L"
    then disp tbcartao.datexp at 1 label "Ativacao" with frame f-alt.
    disp vdt-correio at 1 label "Data Correio" format "99/99/9999"
        with frame f-alt.
    disp vdata-devolc at 1 label "Data Devolucao" format "99/99/9999"
            help "Informe a data de devolucao do correio"
                with frame f-alt.
    disp tbcartao.situacao at 1 with frame f-alt.
    if vdt-correio = ?
    then do:
        update vdt-correio with frame f-alt.
        if vdt-correio <> ?
        then do:
            tbcartao.trilha[5] = "DATA-CORREIO=" + 
                                string(vdt-correio,"99/99/9999") + "|".
            tbcartao.datexp = today.
        end.
    end.
    if vdata-devolc = ?
    then do:
        update vdata-devolc with frame f-alt.
        if vdata-devolc <> ?
        then do:
            tbcartao.trilha[5] = "DEV-CORREIO=" + 
                        string(vdata-devolc,"99/99/9999") 
                            + "|" + btbcartao.trilha[5].
            tbcartao.datexp = today.
            tbcartao.situacao = "D".
        end.
    end.

    /*
    update tbcartao.situacao
        help "E=Emissao  L=Liberado  B=Bloqueado  C=Cancelado"
     with frame f-alt.
    if tbcartao.situacao <> tt-tbcartao.situacao
    then tbcartao.datexp = today.  
    */
    hide frame f-alt.
end procedure.

