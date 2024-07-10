{admcab.i}

def new shared temp-table tpb-contrato like fin.contrato.
def new shared temp-table tpb-contnf
        field etbcod  like fin.contnf.etbcod
        field placod  like fin.contnf.placod
        field contnum like fin.contnf.contnum
        field marca   as   char format "x". 

def new shared temp-table tt-dados
    field parametro as char
    field valor     as dec
    field valoralt  as dec
    field percent   as dec
    field vcalclim  as dec
    field operacao  as char format "x(1)" column-label ""
    field numseq    as int
    index dado1 numseq.
    
def var vetbcod like estab.etbcod.  
def var v-arquivo as char.
def var vmens as char.
def var v-conecta as log.
def var vsaldoa as dec.
def var vlimite as dec.
def var vsaldod as dec.

def var v-imp as char.
def var vsaida              as      log format "Impressora/Tela".

def var vcont as int.
def var vmes as int format "99".
def var vsit as char format "XXX".
def var vtitulo as char.
def var varquivo as char.
def var vtotcli as int.
def var vtotbon as int.
def var vacaocod like acao.acaocod.

def var vcalclim as dec.
def var vpardias as dec.
def var vdisponivel as dec.
                                                
def temp-table tt-digita    no-undo
    field acaocod   like acao.acaocod
    field descri    like acao.descri.

def temp-table tt-rel
    field clifor   like fin.titulo.clifor
    field clinom   like clien.clinom
    field titvlcob like fin.titulo.titvlcob
    field fone     like clien.fone
    field fax      like clien.fax
    field dtnasc   like clien.dtnasc
    field dianasc  as int
    field vendedor like func.funnom
    field limite-d as dec
    field descri   as char format "x(30)"  
    index i1 vendedor dianasc
    .
def var vclicod like clien.clicod.
def var slimite as log format "Sim/Nao".    
    
repeat:
    for each tt-rel: delete tt-rel. end.
    assign vetbcod = 0
           vmes    = 0
           vsit    = ""
           vtotcli = 0
           vtotbon = 0.
         
    repeat:
           
        update vacaocod label "Acao....." at 10
               help "Informe o número das ações e pressione F4 para Confirmar"
               vetbcod  label "Filial..." at 10
               help "Informe a Filial , 0 p/todas"
               with frame f-dados 
                    centered side-labels overlay row 3
                    width 80.
        
        if input vacaocod <> 0
        then do:                                                    
            find tt-digita where 
                 tt-digita.acaocod = vacaocod no-error.
            if not avail tt-digita
            then do:
                create tt-digita.
                assign tt-digita.acaocod = vacaocod.
                find first acao where acao.acaocod = vacaocod no-lock no-error.
                if avail acao then assign tt-digita.descri = acao.descri.
            end.

        end.
        else do:
                message "Informe os numeros das acoes.".
                next.
                /*for each acao no-lock:
                
                    create tt-digita.
                    assign  tt-digita.acaocod = acao.acaocod
                            tt-digita.descri = acao.descri.
                end.*/
        end.
        
        clear frame f-digita all.
        hide frame f-digita no-pause.

        if input vacaocod <> 0
        then do:
            for each tt-digita:
                disp tt-digita.acaocod column-label "Acao"
                     with frame f-digita centered 8 down row 10
                                title " Acoes Selecionadas ".
                down with frame f-digita.
            end.
        end.
        if vetbcod <> 0
        then do:
            find first estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado" view-as alert-box.
                undo, retry.
            end.
            else disp estab.etbnom with frame f-dados no-label.
        end.
        else disp "Todas" @ estab.etbnom with frame f-dados.
    end.
    if vacaocod = 0 then return.
hide frame f-digita no-pause.


    find first tt-digita no-lock no-error.
    if avail tt-digita
    then do:
            assign vacaocod:screen-value in frame f-dados = "".   
    end.      
           
    update vmes label "Mes......"
           skip
           vsit label "Situacao."
           "(PAG = Utilizado  LIB = Em Aberto  EXC = Nao Utilizado)"
           with frame f-dados-n width 80 side-labels.

    if vsit <> "" and vsit <> "PAG" and vsit <> "LIB" and vsit <> "EXC"
    then undo, retry.
    
    if vsit = "PAG"
    then vtitulo = "UTILIZADOS".
    if vsit = "LIB"
    then vtitulo = "EM ABERTO".
    if vsit = "EXC"
    then vtitulo = "NAO UTILIZADOS".
    
    /*
    vsaida = yes.
    update vsaida  label "Saida"
           help " [ I ]   Impressora     [ T ]   Tela       "
           with frame f-dados-nn centered side-labels.

    if vsaida 
    then v-imp = "IMP".
    else v-imp = "TELA".
    */
    slimite = no.
    message "Com limite desponivel? " update slimite.

    if slimite
    then connect dragao -H "erp.lebes.com.br" -S sdragao -N tcp no-error.
    
    for each tt-digita no-lock,
        first acao where acao.acaocod = tt-digita.acaocod no-lock:
    disp "Processando....>>> "
        acao.acaocod with frame f1 1 down centered no-box no-label
        row 15.
    pause 0.
    vcont = 0.

    for each acao-cli where acao-cli.acaocod = acao.acaocod no-lock:
        find first com.plani where plani.movtdc  = 5
                and plani.desti   = acao-cli.clicod
                and plani.pladat >= acao.dtini
                and plani.pladat <= acao.dtfin
                no-lock no-error .
                
        if not avail com.plani
        then next.
        
        find first crm.rfvcli where
                   crm.rfvcli.clicod = acao-cli.clicod
                   and  crm.rfvcli.setor  = 0
                   no-lock no-error.
        if vetbcod > 0 and
            avail crm.rfvcli and
                crm.rfvcli.etbcod <> vetbcod 
        then next.
        if avail com.plani
        then vcont = vcont + 1.
        
        for each  fin.titulo where
                  titulo.clifor = acao-cli.clicod no-lock:

            if fin.titulo.modcod <> "BON" 
            then next.
            if vsit <> ""
             and  fin.titulo.titsit <> vsit
            then next.
        
            if vsit <> "PAG" and
                fin.titulo.titdtpag <> ?
            then next.

            if vmes <> 0
               and month(fin.titulo.titdtemi) <> vmes
            then next.
            
            disp fin.titulo.titnum with frame f1.
            pause 0.
            find clien where clien.clicod = fin.titulo.clifor 
                    no-lock no-error.
            if not avail clien then next.
            find first tt-rel where 
                       tt-rel.clifor = fin.titulo.clifor
                       no-error.
            if not avail tt-rel
            then create tt-rel.
            assign
            tt-rel.clifor = fin.titulo.clifor
            tt-rel.clinom = if avail clien then clien.clinom else "" 
            tt-rel.titvlcob = fin.titulo.titvlcob
            tt-rel.fone     = if avail clien then clien.fone  else ?
            tt-rel.fax      = if avail clien then clien.fax else ?
            tt-rel.dtnasc   = if avail clien then clien.dtnasc else ?
            tt-rel.dianasc  = if avail clien then day(clien.dtnasc) else ?
            tt-rel.descri   = acao.descri when avail acao.
            .

            find func where func.etbcod = com.plani.etbcod and
                            func.funcod = com.plani.vencod
                            no-lock no-error.
            if avail func and func.funnom <> ""
            then tt-rel.vendedor = func.funnom.
            else tt-rel.vendedor =  string(com.plani.etbcod) + " - " +
                                    string(com.plani.vencod).
                                                
            if avail func
            then tt-rel.vendedor = func.funnom.
            vclicod = clien.clicod.   
            
            if slimite
            then do:
                run /admcom/progr/calccredscore.p (input "",
                        input recid(clien),
                        output vcalclim,
                        output vpardias,
                        output vdisponivel).

                tt-rel.limite-d = vdisponivel.

                vsaldoa = 0.
                /*
                for each    titulo where 
                            titulo.clifor = clien.clicod 
                            no-lock:
                    if     titulo.modcod <> "CHQ"
                       and titulo.modcod <> "DEV"
                       and titulo.modcod <> "BON"
                       and titulo.titsit = "LIB"
                    then.
                    else next.   
                    vsaldoa = vsaldoa + titulo.titvlcob.
                end.
                */
                if vlimite - vsaldoa > 0
                then tt-rel.limite-d = vlimite - vsaldoa.
                else tt-rel.limite-d = 0.
            end.         
        end.
    end.
    end.
    varquivo = "/admcom/relat/lisbon01." + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)"
        &Page-Size = "64"
        &Cond-Var  = "175"
        &Page-Line = "66"
        &Nom-Rel   = ""lisbon01""
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO SAO JERONIMO"""  
        &Tit-Rel   = """LISTAGEM DE BONUS - "" 
                   + vtitulo
                   + "" - MES: ""
                   + string(vmes) "
        &Width     = "175"
        &Form      = "frame f-cabcab"}
      vtotbon = 0. 
      vtotcli = 0.
    for each tt-rel use-index i1:            
        vtotcli = vtotcli + 1.
        vtotbon = vtotbon + tt-rel.titvlcob.
        
        disp tt-rel.clifor          column-label "Codigo"
             tt-rel.clinom   format "x(30)"  column-label "Cliente"
             tt-rel.titvlcob format ">>,>>9.99"  column-label "Valor!Bonus"
             tt-rel.fone                       column-label "Fone"
             tt-rel.fax                        column-label "Celular"
             tt-rel.dtnasc                     column-label "Dt.nasc"
                        format "99/99/9999"
             tt-rel.vendedor column-label "Vendedor" format "x(20)"
             tt-rel.limite-d     column-label "Limite!Disponivel"
                format ">>>,>>9.99"
             tt-rel.descri       column-label "Acao" format "x(30)"
             with frame f-mostra width 175 down.
        down with frame f-mostra.

    end.
    
    put skip(1)
        "QUANTIDADE DE CLIENTES RETORNARAM.: " vcont  
        /*skip
        "QUANTIDADE DE BONUS USADOS .......: " vtotcli
        skip
        "VALOR TOTAL DE BONUS USADOS ......: " vtotbon
        */ skip.
        
    output close.
    pause 0.
    /*
    if opsys = "UNIX"
    then do:
        if v-imp = "IMP"
        then os-command silent /fiscal/lp value(varquivo).
        else run visurel.p (input varquivo, input "").
    end.
    if connected("dragao")
    then */
    
    disconnect dragao.

    if opsys = "UNIX"
    then do:
        
        sresp = yes.
        run mensagem.p (input-output sresp,
                        input "A opcao ENVIAR enviara o arquivo " +
                         entry(3,varquivo,"/") + 
                         " para sua filial para ser visualizado" +
                         " ou impresso via PORTA RELATORIOS"
                         + "!!" 
                         + "         O QUE DESEJA FAZER ? ",
                        input "",
                        input "Visualizar",
                        input "Enviar ").
        if sresp = yes
        then do:
            run visurel.p(input varquivo, input "").
        end.
        else do:
            unix silent value("sudo scp -p " + varquivo + /*".z" +*/
                              " filial" + string(setbcod,"999") +
                              ":/usr/admcom/porta-relat").
            message "ARQUIVO ENVIADO... " VARQUIVO. PAUSE. 
        end.
        
    end. 
end.

/*
procedure ag-busca-clien:
        if vclicod > 1 
                then do:
                    /*
                    vclicod = clien.clicod.
                    */
                    v-conecta = yes. 
                    run le_link.p(output v-conecta).  
                    
                    if v-conecta 
                    then  DO ON ERROR UNDO,LEAVE ON ENDKEY UNDO, retry:
                        /*vmens = " Buscando Informacoes...". 
                        message vmens.
                        */
                        for each tp-plani. delete tp-plani. end.
                        for each tp-movim. delete tp-movim. end.
                        for each tpb-contnf. delete tpb-contnf. end.
                        for each tpb-contrato. delete tpb-contrato. end.
                        for each tp-clien: delete tp-clien. end.
                        for each tp-cpclien: delete tp-cpclien. end.
                        for each tp-carro: delete tp-carro. end.
                        for each tp-titulo: delete tp-titulo. end.
                        v-arquivo = "/usr/admcom/connect/retorna3/01" 
                          + string(vclicod). 
                        os-command silent rm -f value(v-arquivo).
                        do transaction:
                        run busconne2.p(input vclicod, input 1, "").
                        
                        end.

                        if keyfunction(lastkey) = "end-error" 
                        then do: 
                            message "F4 bloqueado...". 
                            pause 2 no-message. 
                            undo. 
                        end.
                        v-arquivo = "/usr/admcom/connect/retorna3/01"
                              + string(vclicod).
                        os-command silent rm -f value(v-arquivo).
    
                    END.
                    else do: 

                        run msg2.p
                        (input-output sresp,
                        input "                FILIAL SEM CONEXAO!" 
                        + " !" 
                        + "  NAO SERA POSSIVEL ALTERAR CADASTRO DO CLIENTE "
                        + "!     PRESSIONE ENTER PARA CONTINUAR ..." ,
                        input " *** ATENCAO *** ",
                        input "    OK").
                    end.
                end.
end procedure.

*/
