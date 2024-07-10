{admcab.i}
{setbrw.i}                          
                                            
def input parameter v-op as char. 
def input parameter p-etbcod like estab.etbcod.
def input parameter p-dti as date.
def input parameter p-dtf as date.
def input parameter vconecta-filial as logical.

def var tp-op as log.
def var vfunfunc like func.funfunc.

def buffer ba01_infnfe for a01_infnfe.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["Consulta","","","Parametros","Contingencia"].
def var esqcom2         as char format "x(15)" extent 5
    initial ["ReEnv_Email","Emitir_NFe","ReEnviar_NFe","ReImp_Danfe",
                "Cancelar_NFe"].

if v-op = "PROCESSADAS"
THEN ASSIGN
        esqcom1[2] = ""
        esqcom1[3] = ""
        esqcom1[4] = ""
        esqcom1[5] = ""
        esqcom2[2] = "ReEnv_Email"
        esqcom2[1] = ""
        esqcom2[3] = "ReImp_Danfe"
        esqcom2[4] = "Estorno_NFe"
        tp-op = yes.
else assign
        esqcom2[1] = ""
        esqcom2[4] = ""
        tp-op = no.

find func where func.etbcod = setbcod and
                func.funcod = sfuncod
          no-lock no-error.
if avail func
then vfunfunc = func.funfunc.

if vfunfunc <> "CONTABILIDADE" and
   sfuncod <> 101
then assign
         esqcom1[5] = ""
         esqcom2[5] = ""
         esqcom2[4] = ""
         esqcom2[2] = "".           

if (vfunfunc = "CONTABILIDADE" or sfuncod = 101)
    and v-op <> "PROCESSADAS"
then assign esqcom2[1] = "Atualiza_NFE".         
         
if sfuncod <> 101
then esqcom1[4] = "".

if sfuncod = 101
then assign
        esqcom1[2] = "Autoriza"
        esqcom1[3] = "Alteracao".

if vfunfunc = "CONTABILIDADE" and
   v-op <> "PROCESSADAS"
then assign esqcom1[3] = "Alteracao".

if vfunfunc = "CONTABILIDADE"
then assign esqcom1[2] = "Recall".

if vfunfunc = "CONTABILIDADE"
    and vconecta-filial = yes
then assign esqcom1[4] = "Marca RE-ENVIO" .             

form
    esqcom1
    with frame f-com1 row 3 no-box no-labels column 1 centered.
form
    esqcom2
    with frame f-com2 row screen-lines no-box no-labels column 1 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var v-solicitacao as char.
def var v-ultevento as char.
def var vcfop like placon.opccod.

form 
     A01_infnfe.etbcod format ">>9" column-label "Fil"
     A01_infnfe.numero format ">>>>>>>9"
     B01_IdeNFe.demi  column-label "Emissao" format "99/99/99"
     v-solicitacao    column-label "Solicitacao" format "x(13)"
    /*
     v-ultevento      column-label "Ult. Evento" format "x(13)"
     */
     A01_infnfe.solicitacao 
                column-label "Solicitacao" format "x(11)"
     A01_infnfe.aguardando  
                column-label "Aguardando"   format "x(24)"
     /*
     E01_Dest.xnome format "x(15)" column-label "Destinatario"
     */
     vcfop format ">>>9" column-label "CFOP"
     with frame f-linha 11 down color with/cyan /*no-box*/ width 80.

form 
     A01_infnfe.etbcod format ">>9" column-label "Fil"
     A01_infnfe.numero format ">>>>>>9"
     B01_IdeNFe.demi  column-label "Emissao"
     v-solicitacao    column-label "Solicitacao" format "x(17)"
     v-ultevento      column-label "Ult. Evento" format "x(17)"
     A01_infnfe.situacao column-label "Situacao" format "x(10)"
     /*
     E01_Dest.xnome format "x(20)" column-label "Destinatario"
     */
     vcfop format ">>>9" label "CFOP"
     with frame f-linha1 11 down color with/cyan /*no-box*/ width 80.
  
def var v-rodape as char.
def var i as int.
def var p-valor as char.
def var vdt-polling as date.
def var vhr-polling as int.

l1: repeat:
    find last tab_log where tab_log.etbcod = 0 and
                        tab_log.nome_campo = "NFe" and
                        tab_log.valor_campo = "polling"
                        no-lock no-error.
    if avail tab_log
    then assign
            vdt-polling = tab_log.dtinclu
            vhr-polling = int(tab_log.hrinclu).
    
    p-valor = "".
    run le_tabini.p (0 , 0, "NFE - AMBIENTE", OUTPUT p-valor) .

    disp "               MONITORAMENTO NOTA FISCAL ELETRONICA  -  " 
            + p-valor format "x(70)"
            with frame f1 1 down width 80                                       
            color message no-box no-label row 4.
          
    v-rodape = " EMISSAO NORMAL *** ".
    v-rodape = v-rodape + "Ultimo Polling do ADMCOM em " .
    v-rodape = v-rodape + string(day(vdt-polling),"99") + "/" + 
                      string(month(vdt-polling),"99") + " ".
    v-rodape = v-rodape + "as " + string(vhr-polling,"hh:mm:ss").

    disp v-rodape format "x(75)" with frame f2 1 
        down width 80 color message no-box no-label row 20. 
    pause 0.

    hide frame f-com1.
    hide frame f-com2.
    clear frame f-com1 all.
    clear frame f-com2 all.

    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.

    color display message esqcom1[esqpos1] with frame f-com1.
    hide frame f-linha no-pause.
    clear frame f-linha all.
    clear frame f-linha1 all.

    if tp-op
    then do:      
    {sklclstp.i  
        &color = with/cyan
        &file = A01_infnfe
        &cfield = A01_infnfe.numero
        &pause = 10
        &noncharacter = /* 
        &ofield = " 
            A01_infnfe.etbcod
            B01_IdeNFe.demi  when avail B01_IdeNFe
            v-solicitacao
            v-ultevento
            A01_infnfe.situacao
            vcfop  when vcfop <> 0 "  
        &aftfnd1 = " 
                find last placon where placon.etbcod = A01_infnfe.etbcod
                                   and placon.placod = A01_infnfe.placod
                                   and placon.serie  = A01_infnfe.serie
                                                  no-lock no-error.
                if not avail placon
                then find first I01_prod where
                                I01_prod.chave = A01_infnfe.chave
                                no-lock no-error.
                if avail placon
                then vcfop = placon.opccod.
                else if avail I01_prod
                    then vcfop = I01_prod.cfop.
                    else vcfop = 0.
                                
                find B01_IdeNFe of A01_infnfe no-lock no-error.
                find C01_Emit of A01_infnfe no-lock no-error.
                find E01_Dest of A01_infnfe no-lock no-error.
                v-solicitacao = """".
                v-ultevento = """".
                find first  tab_log where 
                            tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = ""NFe-Solicitacao"" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
                if avail tab_log
                then v-solicitacao = string(tab_log.dtinclu) + "" "" +
                            string(tab_log.hrinclu,""hh:mm:ss"").
                find first  tab_log where 
                            tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = ""NFe-UltimoEvento"" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
                if avail tab_log
                then v-ultevento = string(tab_log.dtinclu) + "" "" +
                            string(tab_log.hrinclu,""hh:mm:ss"").   "
        &where  = " A01_infnfe.situacao <> """"  and
                    (A01_infnfe.solicitacao = """" or
                     A01_infnfe.solicitacao = ""CANCELAMENTO"" or
                     A01_infnfe.solicitacao = ""AUTORIZACAO"") and
                    (if p-etbcod > 0
                     then A01_infnfe.etbcod = p-etbcod else true) and
                    can-find(first B01_IdeNFe of A01_infnfe where
                    (if p-dti <> ?
                     then B01_IdeNFe.demi >= p-dti else true) and
                    (if p-dtf <> ?
                     then B01_IdeNFe.demi <= p-dtf else true)) 
                     no-lock
                    use-index numero "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""parametros"" or
                           esqcom1[esqpos1] = ""autoriza"" or
                           esqcom1[esqpos1] = ""alteracao"" or
                           esqcom2[esqpos2] = ""  CLASSE"" or
                           esqcom2[esqpos2] = ""Emitir_NFe"" or
                           esqcom2[esqpos2] = ""Cancelar_NFe""  or
                           esqcom2[esqpos2] = ""ReImp_DANFE"" or
                           esqcom2[esqpos2] = ""Estorno_NFe"" or
                           esqcom2[esqpos2] = ""ReEnv_EMAIL"" 
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " message color red/with ""Nenhum registo encontrado.""
                        view-as alert-box.
                        leave l1. "
        &otherkeys1 = " run controle.
                        if keyfunction(lastkey) = """"
                        then next l1. "
        &locktype = " "
        &form   = " frame f-linha1 "
    }   
    end.
    else do:
    {sklclstp.i  
        &color = with/cyan
        &file = A01_infnfe
        &pause = 10
        &cfield = A01_infnfe.numero
        &noncharacter = /* 
        &ofield = " 
            A01_infnfe.etbcod
            B01_IdeNFe.demi  when avail B01_IdeNFe
            v-solicitacao
            A01_infnfe.solicitacao 
            A01_infnfe.aguardando 
            vcfop when vcfop <> 0 "  
        &aftfnd1 = " 
                find last placon where placon.etbcod = A01_infnfe.etbcod
                                   and placon.placod = A01_infnfe.placod
                                   and placon.serie  = A01_infnfe.serie
                                               no-lock no-error.
                if not avail placon
                then find first I01_prod where
                                I01_prod.chave = A01_infnfe.chave
                                no-lock no-error.
                if avail placon
                then vcfop = placon.opccod.
                else if avail I01_prod
                    then vcfop = I01_prod.cfop.
                    else vcfop = 0.
                    
                find B01_IdeNFe of A01_infnfe no-lock no-error.
                find C01_Emit of A01_infnfe no-lock no-error.
                find E01_Dest of A01_infnfe no-lock no-error.
                v-solicitacao = """".
                v-ultevento = """".
                find first  tab_log where 
                            tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = ""NFe-Solicitacao"" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
                if avail tab_log
                then v-solicitacao = string(day(tab_log.dtinclu),""99"") +
                             ""~/"" + string(month(tab_log.dtinclu),""99"")
                             + "" "" +
                            string(tab_log.hrinclu,""hh:mm:ss"").
                find first  tab_log where 
                            tab_log.etbcod = A01_InfNFe.etbcod and
                        tab_log.nome_campo = ""NFe-UltimoEvento"" and
                        tab_log.valor_campo = A01_InfNFe.chave
                        no-lock no-error.
                if avail tab_log
                then v-ultevento = string(day(tab_log.dtinclu),""99"") +
                             ""~/"" + string(month(tab_log.dtinclu),""99"")
                            + "" "" +
                            string(tab_log.hrinclu,""hh:mm:ss""). "
        &where  = " 
                (A01_infnfe.situacao = """" or
                A01_infnfe.solicitacao <> """")  and
                A01_infnfe.emite = p-etbcod
                    no-lock "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""parametros"" or
                           esqcom1[esqpos1] = ""autoriza"" or
                           esqcom1[esqpos1] = ""alteracao"" or
                           esqcom2[esqpos2] = ""  CLASSE"" or
                           esqcom2[esqpos2] = ""Emitir_NFe"" or
                           esqcom2[esqpos2] = ""Cancelar_NFe"" or
                           esqcom2[esqpos2] = ""ReImp_DANFE"" or
                           esqcom2[esqpos2] = ""Estorno_NFe"" or
                           esqcom2[esqpos2] = ""ReEnv_EMAIL""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB 
        &naoexiste1 = " esqpos2 = 2.
                        esqregua = no.
                        esqcom2[esqpos2] = ""Emitir_NFe"".
                        run aftselect. 
                        if keyfunction(lastkey) = ""END-ERROR""
                        THEN leave l1.  " 
        &otherkeys1 = " run controle. 
                        if keyfunction(lastkey) = """"
                        then next l1. "
        &locktype = " "
        &form   = " frame f-linha "
    }     
    end.
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
    if esqcom1[esqpos1] = "Consulta"
    THEN DO on error undo:
        /*
        message A01_infnfe.aguardando "Intervencao-Erro parse". pause.
        */
        message A01_infnfe.chave.
        if A01_infnfe.aguardando = "Intervencao-Erro parser" or
           A01_infnfe.aguardando = "Intervenção-Rejeição SEFAZ" or 
           A01_infnfe.sitnfe > 200
        then do:
            run errop_NFe.p(A01_infnfe.chave).
        end.
        else do:
            find B01_IdeNFe of A01_infnfe no-lock no-error.
            if avail B01_IdeNFe and
               B01_IdeNFe.temite <> ""
            then   
            message COLOR RED/WITH
            B01_IdeNFe.temite
            skip(1)
                "FAVOR ENTRAR EM CONTATO COM O SETOR FISCAL/CONTABIL"
                    view-as alert-box TITLE "  Erro na validacao da NF-e  ".

            run consulta_NFe.p(recid(A01_infnfe)).
        end.
    END.
    if esqcom1[esqpos1] = "Autoriza"  
    THEN DO:
        run autman_NFe.p(recid(A01_infnfe)).
    END.
    
    if esqcom1[esqpos1] = "Alteracao"  
    THEN DO:
        run altera_NFe.p(recid(A01_infnfe)).
    END.
    
    if esqcom1[esqpos1] = "contingencia"
    then do:
        run contingencia_nfe.p.
    end.
    if esqcom1[esqpos1] = "parametros"
    THEN DO:
        hide frame f-linha.
        run tab_ini.p("NFE").
        view frame f-linha.
    END.
    
    if esqcom1[esqpos1] = "Marca RE-ENVIO"  
    THEN DO:
        sresp = no.
        message "Tem certeza de que deseja marcar essa nota pra Re-Envio?"
        update sresp.
        
        if sresp
        then do:
            find first ba01_infnfe
                 where rowid(ba01_infnfe) = rowid(a01_infnfe) exclusive-lock.
    
            assign ba01_infnfe.solicitacao = "RE-ENVIO".
        end.
    END.
    
    if esqcom1[esqpos1] = "Recall"  
    THEN DO:
        sresp = no.
        message "Tem certeza de que deseja usar o Recall nesta nota?"
        update sresp.
        
        if sresp
        then do:
            run impnfe2.p (a01_infnfe.etbcod, a01_infnfe.numero).

            view frame f-com2.
        end.
    END.
    
    end.
    else do:
    if esqcom2[esqpos2] = ""
    then do:
    end.
    if esqcom2[esqpos2] = "Emitir_NFe"
    THEN DO :
        RUN emis_nfe.p.
    END.
    if esqcom2[esqpos2] = "Gerar_NFe"
    THEN DO :
        RUN gera_NFe.p.
    END.
    if esqcom2[esqpos2] = "ReEnviar_NFe"
    THEN DO :
        /*
        if A01_infnfe.aguardando = "Consulta" or
           A01_infnfe.aguardando = "Envio"
        then do:
            message color red/with
            "Situacao da NF-e nao permite re-envio."
            view-as alert-box.
        end. 
        else*/
        
        find first tab_log where tab_log.etbcod = A01_InfNFe.etbcod and
                                 tab_log.nome_campo = "NFe-Solicitacao" and
                                 tab_log.valor_campo = A01_InfNFe.chave
                                      no-lock no-error.
        if avail tab_log
            and tab_log.dtinclu = today
            and tab_log.hrinclu >= time - 120
        then do:
            message "A NF: " A01_InfNFe.numero " esta aguardando autorizacao!"
                    " Aguarde alguns minutos e verifique se"
                    "realmente é necessário reenvia-la. "
                           view-as alert-box.
        end.
        else do:  
            sresp = no.
            message "Confirma Re-enviar NFe" A01_infnfe.numero " ?" 
            update sresp.
            if sresp
            then do: 
                run reenv_NFe.p(recid(A01_infnfe)).
                tp-op = no.
            end.
        end.
    END.
    if esqcom2[esqpos2] = "Cancelar_NFe"
    THEN DO :
        sresp = no.
        message "Confirma cancelar NFe " A01_infnfe.numero " ?" 
        update sresp.
        if sresp
        then do:
            tp-op = no.
            
            p-valor = "".
            run le_tabini.p (A01_infnfe.emite, 0,
                   "NFE - TIPO DE ARQUIVO", OUTPUT p-valor) .
                   
            if p-valor = "TXT"
            then do:
                RUN canc_NFe.p(recid(A01_infnfe)).
            end.    
            else if p-valor = "XML"
            then do:
               RUN canc_NFe_xml.p(recid(A01_infnfe)).                     
            end.
        end.
    END.
    if esqcom2[esqpos2] = "Atualiza_NFE"
    then do:
         run atualiza_NFe.p(recid(A01_InfNFe)).
    end.
    
    if esqcom2[esqpos2] = "ReEnv_EMAIL"
    THEN DO :
        RUN email_xml_NFe.p(recid(A01_infnfe)).
    END.
    if esqcom2[esqpos2] = "ReImp_DANFE"
    THEN DO :
        sresp = no.
        message "Confirma Re-emprimir DANFE NFe " A01_infnfe.numero " ?" 
        update sresp.
        if sresp
        then do: 
            RUN danfe_NFe.p(recid(A01_infnfe)).
            /*
            tp-op = no.
            */
        end.
    END.
    if esqcom2[esqpos2] = "Estorno_NFe"
    THEN DO :
        if A01_infnfe.sitnfe = 91
        then do:
            find last B12_NFref where B12_NFref.refNFe = A01_infnfe.id
                                       no-lock no-error.
                                        
            find last ba01_infnfe where ba01_infnfe.chave = B12_NFref.chave
                                        no-lock no-error.
                                
            if not avail ba01_infnfe
            then message color red/with
                     "NFe " A01_infnfe.numero " ja estornada! "
                            view-as alert-box.
            else message color red/with
                     "NFe " A01_infnfe.numero " ja estornada pela nota "
                            ba01_infnfe.numero
                                view-as alert-box.
        end.
        else do:
            sresp = no.
            message "Confirma ESTORNAR NFe "  A01_infnfe.numero " ?"
            update sresp.
            if sresp
            then do:
                tp-op = no.
               /* RUN estorno_NFe.p(rowid(A01_infnfe)).*/
               RUN estorno_NFe_400.p(rowid(A01_infnfe)).

            end.
        end.
    END.
         
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
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "." + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "." + string(time).
    
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
