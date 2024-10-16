{admcab.i}
{setbrw.i}                                                                      

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
    initial ["","  Consulta","  Filtro","  Situacao","  Novo Cartao"].

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
     tbcartao.contacli    format ">>>>>>>>>>>9"     column-label "Cartao"
     tbcartao.clicod      format ">>>>>>>>>9" 
     tbcartao.clinom      format "x(26)"
     tbcartao.dtinclu     format "99/99/9999" column-label "Emissao"
     /*tbcartao.validade    format "99/99/9999" column-label "Validade"
     */
     vdt-correio          format "99/99/9999" column-label "Data Correio"
     tbcartao.situacao    format "X" column-label "Sit"
     with frame f-linha 12 down color with/cyan /*no-box*/
     width 80.
                                                                         
def var vmotivo as int.
               
disp "                      C A R T A O  L E B E S      " 
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
    
def temp-table tt-tbcartao like tbcartao.
def buffer btbcartao  for tbcartao.

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
        &cfield = tbcartao.contacli
        &noncharacter = /* 
        &ofield = " tbcartao.clicod
                    tbcartao.clinom
                    tbcartao.dtinclu
                    vdt-correio
                    tbcartao.situacao
                    "  
        &aftfnd1 = " 
                    vdt-correio = 
                        date(acha(""DATA-CORREIO"",tbcartao.trilha[5])).
                "
        &where  = " tbcartao.codoper = vcodoper and
                    (if vclicod > 0
                     then tbcartao.clicod = vclicod else true) and
                    (if vsituacao <> """"
                     then tbcartao.situacao = vsituacao else true)
                     no-lock
                     "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE"" or
                           esqcom1[esqpos1] = ""  Novo cartao""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  bell.
                sresp = no.
                message  color red/with ""Nenhum registro encontrado."" 
                    VIEW-AS ALERT-BOX.
                vclicod = 0.
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
        /*run inclui.*/
    END.
    if esqcom1[esqpos1] = "  Consulta"
    THEN DO:
        run consulta.
    END.
    if esqcom1[esqpos1] = "  Filtro"
    THEN DO:
        update vclicod   format ">>>>>>>>>9" label "Conta"
               vsituacao format "!"   label "Situacao" 
                with frame f-filtro 1 down centered row 8 side-label
                color message title "Filtro" overlay
                .
    END.
    if esqcom1[esqpos1] = "  Situacao"
    THEN DO on error undo:
        run situacao.
    END.
    if esqcom1[esqpos1] = "  Novo Cartao"
    THEN DO on error undo:
        run pdcartao.p.
    END.
    if esqcom2[esqpos2] = " Data Correio"
    THEN DO:
        /*run data-correio. */
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
    def var vnome like clien.clinom.
    create tt-tbcartao.
    update tt-tbcartao.clicod at 4 format ">>>>>>>>9" 
            with frame f-inc 1 down centered row 8
            side-label overlay color message.
    find clien where clien.clicod = tt-tbcartao.clicod no-lock.
    disp clien.clinom no-label with frame f-inc.
    tt-tbcartao.dtinclu = today.
    tt-tbcartao.hrinclu = time.
    tt-tbcartao.validade = ?.
    tt-tbcartao.datexp = today.
    find last btbcartao use-index indx2 where
              btbcartao.codoper = vcodoper and
              btbcartao.clicod  = tt-tbcartao.clicod
              no-lock no-error.
    if not avail btbcartao
    then tt-tbcartao.nrocartao = "10" + string(clien.clicod,"999999999").          else do:
        vdig = int(substr(btbcartao.nrocartao,1,2)).
        tt-tbcartao.nrocartao = string(vdig + 10) + 
                                string(clien.clicod,"999999999").
    end. 
    tt-tbcartao.contacli = dec(tt-tbcartao.nrocartao).
    disp tt-tbcartao.contacli at 3 label "Cartao" with frame f-inc.
    disp tt-tbcartao.dtinclu at 1 label "Inclusao" with frame f-inc.
    tt-tbcartao.validade = date(month(tt-tbcartao.dtinclu),
                                day(tt-tbcartao.dtinclu),
                                year(tt-tbcartao.dtinclu) + 5).
    do on error undo:
        update tt-tbcartao.validade at 1 with frame f-inc.  
        if tt-tbcartao.validade <> ? and
           tt-tbcartao.validade < today
        then undo.
    end.
    assign
        tt-tbcartao.codoper = 999
        tt-tbcartao.situacao = "E"
        tt-tbcartao.trilha[1] = tt-tbcartao.nrocartao
        tt-tbcartao.trilha[2] = string(day(tt-tbcartao.validade),"99") +
                                string(month(tt-tbcartao.validade),"99") +
                                string(year(tt-tbcartao.validade),"9999") 
        tt-tbcartao.trilha[3] = string(tt-tbcartao.clicod).       
    b = 0 . a = 0.
    vnome = "".
    b = num-entries(clien.clinom," ").
    if length(clien.clinom) > 26
    then do a = 1 to b:
        if a = 1
        then vnome = entry(1,clien.clinom," ").
        else if a = b
            then vnome = vnome + " " + entry(b,clien.clinom," ").
            else vnome = vnome + " " + substr(entry(a,clien.clinom," "),1,1).
    end.
    else vnome = clien.clinom.
    
    tt-tbcartao.clinom  =  vnome.

    do transaction:
        create tbcartao.
        buffer-copy tt-tbcartao to tbcartao.
    end.    
end procedure.

procedure altera:
    for each tt-tbcartao: delete tt-tbcartao. end.
    create tt-tbcartao.
    buffer-copy tbcartao to tt-tbcartao.
    vdt-correio = date(acha("DATA-CORREIO",tbcartao.trilha[5])).

    disp tbcartao.clicod at 4 format ">>>>>>>>9" 
            with frame f-alt 1 down centered row 8
            side-label overlay color message.
    find clien where clien.clicod = tbcartao.clicod no-lock.
    disp clien.clinom no-label with frame f-alt.
    disp tbcartao.contacli at 3 label "Cartao" with frame f-alt.
    disp tbcartao.dtinclu at 1 label "Inclusao" with frame f-alt.
    disp tbcartao.validade at 1 with frame f-alt.
    disp vdt-correio at 1 label "Data Correio" format "99/99/9999"
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
    
    /*
    update tbcartao.situacao
        help "E=Emissao  L=Liberado  B=Bloqueado  C=Cancelado"
     with frame f-alt.
    if tbcartao.situacao <> tt-tbcartao.situacao
    then tbcartao.datexp = today.  
    */
end procedure.

procedure situacao:
    for each tt-tbcartao: delete tt-tbcartao. end.
    create tt-tbcartao.
    buffer-copy tbcartao to tt-tbcartao.
    
    def var vsel-sit1 as char format "x(15)" extent 4
          init["Emissao","Liberado","Bloqueado","Cancelado"].
    def var vmarca-sit1 as char format "x" extent 4.
    format skip(1)
           "[" space(0) vmarca-sit1[1] space(0) "]"  vsel-sit1[1]
           skip
           "[" space(0) vmarca-sit1[2] space(0) "]"  vsel-sit1[2]
           skip
           "[" space(0) vmarca-sit1[3] space(0) "]"  vsel-sit1[3]
           skip
           "[" space(0) vmarca-sit1[4] space(0) "]"  vsel-sit1[4]
           skip
           with frame f-sel-sit1
                   1 down  centered no-label row 6 overlay
                    width 30 title " Situacao cartao " 
                            + string(tbcartao.contacli).

        def var vi as in init 0.
        def var va as int init 0.

        vmarca-sit1 = "".
        if tbcartao.situacao = "E"
        then assign
                va = 1
                vmarca-sit1[1] = "*".
        else if tbcartao.situacao = "L"
        then assign
                va = 2
                vmarca-sit1[2] = "*".
        else if tbcartao.situacao = "B"
        then assign
                va = 3
                vmarca-sit1[3] = "*".    
        else if tbcartao.situacao = "C" 
        then assign
                va = 4
                vmarca-sit1[4] = "*".     
        
        marca-situacao = 0.
        disp     vmarca-sit1      
                 vsel-sit1 with frame f-sel-sit1.
        pause 0.    
        if va = 3 or va = 4
        then do:
            find first tbcntgen where tbcntgen.tipcon = 7 and
                        tbcntgen.etbcod = tbcartao.motcance
                        no-lock no-error.
            if avail tbcntgen
            then do:
                disp tbcntgen.campo1[1] 
                    with frame f-motivo 1 down overlay no-label
                    title "  Motivo  " centered .
                pause 0.
            end.            
        end.
        pause.
        /***
             choose field vsel-sit1 with frame f-sel-sit1.
            if frame-index < va or
               va = 3 
            then do:
                undo.
            end.    
            vmarca-sit1[va] = "".
            vmarca-sit1[frame-index] = "*".
            va = frame-index.
            disp vmarca-sit1 with frame f-sel-sit1.
            pause 0.
            marca-situacao = va.
        sresp = no.
        message "Confirma alterar situacao? " update sresp.
        if sresp
        then do:
            if marca-situacao = 3 or
               marca-situacao = 4
            then do:
                vmotivo = 0.
                run motivo-bloq.
                if keyfunction(lastkey) = "end-error"
                then undo.
                
            end.
            if marca-situacao < 3 or
               vmotivo > 0
            then do:    
                tbcartao.motcance = vmotivo.
                if marca-situacao = 1
                then tbcartao.situacao = "E".
                else if marca-situacao = 2       
                then tbcartao.situacao = "L".
                else if marca-situacao = 3   
                then tbcartao.situacao = "B".
                else if marca-situacao = 4   
                then tbcartao.situacao = "C".
            end.
        end. 
        ***/
    hide frame f-sel-sit1 no-pause.
    hide message no-pause.
    if tbcartao.situacao <> tt-tbcartao.situacao
    then tbcartao.datexp = today.
    hide frame f-motivo.
end procedure.

procedure motivo-bloq.
l1: repeat:

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?.

    {sklclstb.i  
        &color = with/cyan
        &file = tbcntgen  
        &cfield = tbcntgen.campo1[1]
        &noncharacter = /* 
        &ofield = " tbcntgen.campo1[1]  "  
        &aftfnd1 = " "
        &where  = " tbcntgen.tipcon = 7 no-lock "
        &aftselect1 = "  vmotivo = tbcntgen.etbcod.
                        leave l1. "
        &naoexiste1 = " leave l1. "
        &form   = " frame f-linha1 down overlay no-label
         title ""  Motivos  "" centered "
    }   
    if keyfunction(lastkey) = "end-error" or
       keyfunction(lastkey) = "return"
    then DO:
        leave l1.       
    END.
end.
hide frame f-linha1.
end procedure.

def var varq as char.

procedure data-correio:
    def var varqret as char.
    if opsys = "UNIX"
    then.
    else do:
        varqret = sel-arq01().
    end. 
    update varqret format "x(60)" label "Arquivo"
            with frame f-ret 1 down overlay
            side-label centered color message row 10.
    
    if search(varqret) = ?
    then do:
        message color red/with
        "Arquivo nao encontrado."
        view-as alert-box.
        undo.
    end.
    def var sconf as log format "Sim/Nao".
    sconf = no.
    message "Confirma importar arquivo ? " update sconf.
    if not sconf then undo.

    def var varquivo1 as char.
    varquivo1 = varqret + string(time).
    if opsys = "UNIX"
    then unix silent value("quoter -d % " +  varqret  + " > " + varquivo1).
    else dos   
        value("c:\dlc\bin\quoter -d % " +  varqret  + " > " + varquivo1).

    def var vlinha as char.
    def var vi as int.
    def var vj as int.
    def var vcoluna as char extent 20.
    input from value(varquivo1).
    repeat:
        import vlinha.
        do vi = 1 to num-entries(vlinha,";"):
        end.
        vj = 0.
        vcoluna = "".
        do vj = 1 to vi - 1.
            vcoluna[vj] = entry(vj,vlinha,";").    
        end.
        find tbcartao where tbcartao.codoper = 999 and
                            tbcartao.nrocartao = vcoluna[2] no-error.
        if avail tbcartao
        then do:
            tbcartao.trilha[5] = "DATA-CORREIO=" + vcoluna[4] + "|".
            tbcartao.datexp = today.
        end.
    end.
    input close.
end procedure.
procedure consulta:
    def var vdata-devolc as date.
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
    pause.
    hide frame f-alt.
end procedure.


