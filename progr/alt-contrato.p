{admcab.i}

def input parameter p-contnum like contrato.contnum.

def var valor-ori as dec.
def var valor-par as dec.

if p-contnum = ?
then do:
    update p-contnum format ">>>>>>>>>9"
    with frame f-c 1 down side-label width 80.
end.
disp p-contnum with frame f-c.

find first contrato where 
           contrato.contnum = p-contnum
           no-lock no-error.
if not avail contrato
then do:
    bell.
    message color red/with
    "Contrato " p-contnum
    "nao encontrato na base"
    view-as alert-box.
    undo.
end.

find clien where clien.clicod = contrato.clicod no-lock no-error.
find estab where estab.etbcod = contrato.etbcod no-lock no-error.
find finan where finan.fincod = contrato.crecod no-lock no-error.

disp 
     contrato.etbcod
     estab.etbnom no-label
     contrato.clicod  at 2 label "Cliente"
     clien.clinom no-label when avail clien
     contrato.dtinicial  at 1
     contrato.vltotal  format ">,>>>,>>9.99"
     contrato.vlentra  format ">,>>>,>>9.99"
     contrato.crecod   at 1
     finan.finnom no-label
     with frame f-c
     .

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
    initial ["====>>>>"," ALTERA VENCTO"," ALTERA PLANO ","",""].
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
                 row 9 no-box no-labels 
                 .
/*
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
*/

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

form 
     with frame f-linha 8 down color with/cyan /*no-box*/
     centered .
                                                                         
def buffer btbcntgen for tbcntgen.                            
def var i as int.
def var p-pago as log.
def var p-emis as log.

p-pago = no.
p-emis = no.
def buffer btitulo for titulo.
for each btitulo where btitulo.empcod = 19 and
                        btitulo.titnat = no and
                        btitulo.modcod = "CRE" and
                        btitulo.etbcod = contrato.etbcod and
                        btitulo.clifor = contrato.clicod and
                        btitulo.titnum = string(contrato.contnum) and
                        btitulo.titpar > 0
                        no-lock.
    if btitulo.titdtpag <> ?
    then p-pago = yes.
    if today - btitulo.titdtven > 30
    then p-emis = yes.
end.    
if p-emis
then do:
    bell.
    message color red/with
    "Contrato emitido a mais de 30 dias impossivel alterar"
    view-as alert-box.
    return.
end.

if p-pago
then do:
    bell.
    message color red/with
    "Contrato com parcela(s) paga(s) impossivel alterar)"
    view-as alert-box.
    return.
end.

def var vline as int.
l1: repeat:
    disp esqcom1 with frame f-com1.
    /*
    disp esqcom2 with frame f-com2.
    */
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1
        esqregua = yes. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = titulo  
        &cfield = titulo.titdtven
        &noncharacter = /* 
        &ofield = " titulo.titdtven
                    titulo.titnum
                    titulo.titpar
                    titulo.titdtven
                    titulo.titvlcob
                    "  
        &aftfnd1 = " "
        &where  = " titulo.empcod = 19 and
                    titulo.titnat = no and
                    titulo.modcod = ""CRE"" and
                    titulo.etbcod = contrato.etbcod and
                    titulo.clifor = contrato.clicod and
                    titulo.titnum = string(contrato.contnum)
                    "
        &aftselect1 = " vline = frame-row .
                        run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom2[esqpos2] = ""  CLASSE""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = "  " 
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
    def buffer bdtitulo for titulo.
    def var vtitdtven as date format "99/99/9999".
    if esqcom1[esqpos1] = " ALTERA VENCTO"
    THEN DO :
        color disp message 
            titulo.titdtven
                    titulo.titnum
                    titulo.titpar
                    titulo.titdtven
                    titulo.titvlcob
                    with frame f-linha.
                    
        repeat on error undo:
            update vtitdtven column-label "Novo!Vencimento"
            with frame f-linha1 no-validate
            column 1 row vline  no-box.
            if vtitdtven = ? or
               vtitdtven <= titulo.titdtven
            then do:
                bell.
                message color red/with
                 "Nova vencimento tem que ser maior que o vencimento atual." 
                 view-as alert-box.
                 undo.
            end.    
            find first bdtitulo where bdtitulo.empcod = titulo.empcod and
                                      bdtitulo.titnat = titulo.titnat and
                                      bdtitulo.modcod = titulo.modcod and
                                      bdtitulo.etbcod = titulo.etbcod and
                                      bdtitulo.clifor = titulo.clifor and
                                      bdtitulo.titnum = titulo.titnum and
                                      bdtitulo.titpar = titulo.titpar + 1 and
                                      bdtitulo.titdtemi = titulo.titdtemi
                                      no-lock no-error.
            if avail bdtitulo and
                vtitdtven >= bdtitulo.titdtven
            then do:
                message color red/with
                "Novo vencimento tem que sre menor que vencimento da proxima parcela."  view-as alert-box.
                undo.
            end.
            
            sresp = no.
            message "Confirma nova data de vencimento?"  update sresp.
            if sresp
            then do on error undo:
                find current titulo exclusive-lock.
                find first  tit_novacao where
                            tit_novacao.tipo = "REPACTUACAO" and
                            tit_novacao.ori_empcod = titulo.empcod and
                            tit_novacao.ori_titnat = titulo.titnat and
                            tit_novacao.ori_modcod = titulo.modcod and
                            tit_novacao.ori_etbcod = titulo.etbcod and
                            tit_novacao.ori_clifor = titulo.clifor and
                            tit_novacao.ori_titnum = titulo.titnum and
                            tit_novacao.ori_titpar = titulo.titpar and
                            tit_novacao.ori_titdtemi = titulo.titdtemi
                            no-error.
                if not avail tit_novacao
                then create tit_novacao.
                assign
                    tit_novacao.tipo = "REPACTUACAO"
                    tit_novacao.ger_contnum = contrato.contnum
                    tit_novacao.ori_empcod = titulo.empcod
                    tit_novacao.ori_titnat = titulo.titnat
                    tit_novacao.ori_modcod = titulo.modcod
                    tit_novacao.ori_etbcod = titulo.etbcod
                    tit_novacao.ori_clifor = titulo.clifor
                    tit_novacao.ori_titnum = titulo.titnum
                    tit_novacao.ori_titpar = titulo.titpar
                    tit_novacao.ori_titdtemi = titulo.titdtemi
                    tit_novacao.ori_titdtven = titulo.titdtven
                    tit_novacao.ori_titvlcob = titulo.titvlcob
                    tit_novacao.dtnovacao   = today
                    tit_novacao.hrnovacao   = time
                    tit_novacao.funcod      = sfuncod
                    tit_novacao.datexp      = today
                    tit_novacao.exportado   = no
                    .

                assign
                    titulo.titdtven = vtitdtven
                    titulo.datexp = today
                    titulo.exportado = yes
                    .

            end.
            else next.
            leave.
            
        end.
        hide frame f-linha1 no-pause.
        clear frame f-linha1 all.
        
    END.
    if esqcom1[esqpos1] = " ALTERA PLANO "
    THEN DO:
        def var vprim-ven as date format "99/99/9999". 
        def var vfincod like finan.fincod.
        def var vd-parcela as char format "x(20)".
        find finan where finan.fincod = contrato.crecod no-lock.
        vd-parcela = string(finan.finnpc) + " X " +
            string((contrato.vltotal - contrato.vlentra) 
                / finan.finnpc,">>,>>9.99") + " = ". 
        disp finan.fincod label "Plano"
             finan.finnom no-label  skip
             vd-parcela no-label
             contrato.vltotal  no-label
             with frame f-altplano side-label
             title " PLANO ATUAL " column 30.

        repeat:
            update vfincod with frame f-altplano1 side-label
                        title " NOVO PLANO " column 30.
            find finan where finan.fincod = vfincod no-lock no-error.
            if not avail finan then next.
            
            valor-ori = 0.
            valor-par = 0.
            run recalculo-novocontrato.
            
            disp finan.finnom no-label skip with frame f-altplano1.
             vd-parcela = string(finan.finnpc) + " X " +
             string(valor-par,">>,>>9.99")
            /*string((contrato.vltotal - contrato.vlentra) 
                / finan.finnpc,">>,>>9.99") + " = "*/. 
            
            disp vd-parcela  no-label
                 (valor-par * finan.finnpc) no-label
                 with frame f-altplano1.
            update vprim-ven label "Primeiro vencimento"
                with frame f-altplano1.
            sresp = no.
            message "Confirma alterar plano ?" update sresp.
            if sresp 
            then do:
                run atualiza-contrato-titulos(input valor-par,
                            input vprim-ven).
            end.
        end.
    
    END.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
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
                /*
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                */
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
                /*
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                    color display messages esqcom2[esqpos2] with frame f-com2.
                end.
                */
                next.
            end.
end procedure.

procedure recalculo-novocontrato:
    find first contnf where contnf.etbcod = contrato.etbcod and
                            contnf.contnum = contrato.contnum
                            no-lock no-error.
    if avail contnf
    then do:
        find plani where plani.etbcod = contnf.etbcod and
                         plani.placod = contnf.placod and
                         plani.movtdc = 5
                         no-lock no-error.
        if avail plani
        then do:
            valor-ori = plani.platot - plani.vlserv.
            valor-par = valor-ori * finan.finfat.
        end.
    end.        
end procedure.

procedure atualiza-contrato-titulos:
    def input parameter valor-par as dec.
    def input parameter vprim-ven as date.
    find current contrato exclusive-lock no-error.
    if avail contrato
    then do on error undo:
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum)
                              no-lock:
            create tit_novacao.
            assign
                tit_novacao.tipo = "REPACTUACAO"
                tit_novacao.ger_contnum = contrato.contnum
                tit_novacao.ori_empcod = titulo.empcod
                tit_novacao.ori_titnat = titulo.titnat
                tit_novacao.ori_modcod = titulo.modcod
                tit_novacao.ori_etbcod = titulo.etbcod
                tit_novacao.ori_clifor = titulo.clifor
                tit_novacao.ori_titnum = titulo.titnum
                tit_novacao.ori_titpar = titulo.titpar
                tit_novacao.ori_titdtemi = titulo.titdtemi
                tit_novacao.ori_titdtven = titulo.titdtven
                tit_novacao.ori_titvlcob = titulo.titvlcob
                tit_novacao.dtnovacao   = today
                tit_novacao.hrnovacao   = time
                tit_novacao.funcod      = sfuncod
                tit_novacao.datexp      = today
                tit_novacao.exportado   = no
                .
        end. 
        assign
            contrato.vltotal = valor-par * finan.finnpc
            contrato.crecod  = finan.fincod
            .
        do i = 1 to finan.finnpc:
            find first  titulo where 
                        titulo.empcod = 19 and
                        titulo.titnat = no and
                        titulo.modcod = "CRE" and
                        titulo.etbcod = contrato.etbcod and
                        titulo.clifor = contrato.clicod and
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titpar = i and
                        titulo.titdtemi = contrato.dtinicial
                        no-error.
            if avail titulo
            then do:
                assign
                    titulo.titdtven = vprim-ven
                    titulo.titvlcob = valor-par
                    .
            end.                        
        end.
        for each titulo where titulo.empcod = 19 and
                              titulo.titnat = no and
                              titulo.modcod = "CRE" and
                              titulo.etbcod = contrato.etbcod and
                              titulo.clifor = contrato.clicod and
                              titulo.titnum = string(contrato.contnum) and
                              titulo.titpar > finan.finnpc   and
                              titulo.titdtemi = contrato.dtinicial
                              exclusive-lock:
            titulo.titsit = "EXC".
        end.                                  
     end.            
end.
