{admcab.i}

def var vpdf as char no-undo.
def var varqaux as char no-undo.

varqaux = "/admcom/relat/extrato2-aux-" + string(time) + ".tmp".

def input parameter p-ord as int. /* 1- alfabetica, 2-vencimento, 3-bairro */
def var vndtven like titulo.titdtven.
def var vndia   as int.
def var vncond  as char format "x(40)" extent 5.
def var vnalor_cobrado as dec extent 5. 
def var vnalor_novacao as dec extent 5.

def var varquivo as char.

def shared temp-table tt-extrato 
    field rec      as recid
    field ord      as int
    field cidade as char
    field bairro   like clien.bairro[1]
    field clinom   like clien.clinom
    field titnum   like titulo.titnum
    field titdtven like titulo.titdtven
    field etbcod   like estab.etbcod
    index ind-1 ord
    index i-bairro bairro
    index i1 bairro cidade clinom titdtven
    index i-rec     rec.


def shared temp-table tt-bairro
    field cidade as char
    field bairro as char
    field marca as char
    field qtdcli as int
    index i1 bairro
    index i-cidbai cidade bairro.
    
def temp-table tt-imp
    field rec as recid
    field imp as log
    .
    
def var xx as int.
def var yy as int.
def var vtotal like titulo.titvlcob.
def var vjuro  like titulo.titvlcob.
def var vacum  like titulo.titvlcob.
def var vtotjuro  like titulo.titvlcob.
def var vtotcon   like titulo.titvlcob.
def var auxvtotal like titulo.titvlcob.
def var auxvjuro  like titulo.titvlcob.
def var vtitvlcob like titulo.titvlcob.
def var vdias  as   int.

def var i as int.
def var vclicod  like clien.clicod.
def var vsit as log format "PAGO/ABERTO".

def var v-auxtit like titulo.titnum.
def buffer b-titulo for titulo.
def stream stela.

def var vqtite as int.
for each tt-imp.
    delete tt-imp.
end.
for each tt-bairro where tt-bairro.bairro = "":
    delete tt-bairro.
end.    
{setbrw.i}    
form tt-bairro.marca no-label format "x"
     tt-bairro.bairro column-label "Bairro" format "x(30)"
     tt-bairro.cidade column-label "Cidade" format "x(30)"
     tt-bairro.qtdcli column-label "Clientes" format ">>>>9"
      with frame f-linha 9 down overlay row 8 
      title " selecione para imprimir "
       .
def var totclientes as int format ">>>>>>9".
def var totmarcados as int format ">>>>>>9".
procedure totalizar:
    totclientes = 0.
    totmarcados = 0.
    for each tt-bairro :
        if tt-bairro.marca <> ""
        then totmarcados = totmarcados + tt-bairro.qtdcli.
        totclientes = totclientes + tt-bairro.qtdcli.
    end. 
    disp "Marcados = " totmarcados  "      Clientes = " totclientes
        with frame f-rodape 1 down no-box column 20 no-label
           row 21.
end procedure.

varquivo = "/admcom/relat/extrato" + 
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + ".*" .
if search(varquivo) <> ?
then do:
    unix silent value(" rm " + varquivo).
end.
 
l1:      
repeat:
    if keyfunction(lastkey) <> "clear"
    then
    for each tt-bairro where tt-bairro.marca <> "".
        delete tt-bairro.
    end.    
    assign
        a-seeid = -1
        a-recid = -1
        a-seerec = ?
        .
    run totalizar.
           
    {sklcls.i
        &help = "ENTER=Marca/Desm F1=Confirma F4=Retorna F8=Marca/Desm tudo"
        &file = tt-bairro
        &cfield = tt-bairro.bairro
        &ofield = " marca tt-bairro.cidade tt-bairro.qtdcli"
        &where = " true "
        &naoexiste1 = "
            bell.
            message color red/with
                ""Nenhum registro para impressao""
                view-as alert-box.
            leave l1.
                 "
        &aftselect1 = "
            if keyfunction(lastkey) = ""RETURN""
            then do:
                find tt-bairro where recid(tt-bairro) = a-seerec[frame-line].
                if tt-bairro.marca <> """"
                then tt-bairro.marca = """".
                else tt-bairro.marca = ""*"".
                disp tt-bairro.marca with frame f-linha.
                run totalizar.
                next keys-loop.
            end.
            "
        &otherkeys1 = "
            if keyfunction(lastkey) = ""GO""
            then do:
                find first tt-bairro where 
                           tt-bairro.marca = ""*"" no-error.
                if not avail tt-bairro
                then do:
                    bell.
                    message color red/with
                        ""Nenhum item marcado, impossivel continuar.""
                         view-as alert-box.
                    next keys-loop.
                end.
                else leave keys-loop.
            end.
            if keyfunction(lastkey) = ""CLEAR""
            then do:
                find first tt-bairro where tt-bairro.marca = """" no-error.
                if avail tt-bairro
                then do:
                    for each tt-bairro where 
                             tt-bairro.marca = """":
                        tt-bairro.marca = ""*"".
                    end.             
                end.
                else do:
                    for each tt-bairro:
                        tt-bairro.marca = """".
                    end.    
                end.
                next l1.
            end.
            "
        &form  = "frame f-linha"
    }      
    
    if keyfunction(lastkey) = "end-error"
    then do:
        hide frame f-linha no-pause.
        leave l1.
    end.

    if keyfunction(lastkey) = "GO"
    then repeat:

        output stream stela to terminal.
        
        varquivo = "/admcom/relat/extrato" + 
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time).
        
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "137"
            &Page-Line = "66"
            &Nom-Rel   = """extrato2"""
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """EXTRATO DE CLIENTE"""
            &Width     = "137"
            &Form      = "frame f-cab"}
            
        case p-ord:
            when 1 then run p-alfa.
            when 2 then run p-vencto.
            when 3 then run p-bairro.
        end case.
    
        output close.
        output stream stela close.
        /*
        run visurel.p (varquivo,"").
        sresp = no.
        message "Deseja imprimir extratos? " update sresp.
        if sresp
        then os-command cat value(varquivo) > /dev/lp0 &.
        */
        run arq-imp.
        leave l1.
    end.    
end.    
/* * * * * * * * * * * * * * * * * * * * * * * * * * * 
** As procedures abaixo sao iguais, mudando apenas 
** a ordenacao da tt-extrato.
** * * * * * * * * * * * * * * * * * * * * * * * * * */

def temp-table tt-titulo like titulo
index i1 titnum titdtven  desc.

def temp-table tt-arq
    field arquivo as char.

procedure arq-imp.
    def var varquivo1 as char.
    def var varquivo2 as char.
    varquivo1 = "/admcom/relat/extrato" + 
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + ".*".
    varquivo2 = "/admcom/relat/extrato." + string(time).

    unix silent value("ls " + varquivo1 + " > " + varquivo2).
    for each tt-arq. delete tt-arq. end.
    input from value(varquivo2).
    repeat:
        create tt-arq.
        import tt-arq.
    end.
    input close.

    form  tt-arq.arquivo
        with frame f-linha1 down no-label centered
        title " O extrato agora é dividido em partes. Selecione o arquivo para geracao de PDF "
        .
    for each tt-arq where arquivo = "":
        delete tt-arq.
    end.
        
    cl1: repeat:
        assign
            a-seeid = -1
            a-recid = -1
            a-seerec = ?.
        hide frame f-linha1 no-pause.
        {sklcls.i
            &file = tt-arq
            &cfield = tt-arq.arquivo
            &ofield = " tt-arq.arquivo format ""x(50)"" "
            &where = true
            &aftselect1 = "
                if keyfunction(lastkey) = ""RETURN""
                then leave keys-loop.
                "
            &naoexiste1 = " leave cl1. "
            &form = " frame f-linha1 "
        }
        if keyfunction(lastkey) = "END-ERROR"
        THEN next.
        if keyfunction(lastkey) = "RETURN"
        then do:
            sresp = no.
            
            message "Confirma geracao de PDF? " update sresp.
            if sresp
            then do:
                
                run pdfout.p (input tt-arq.arquivo,
                              input "/admcom/kbase/pdfout/",
                              input "extrato2-" + string(time) + ".pdf",
                              input "Portrait",
                              input 7.0,
                              input 1,
                              output vpdf).

                message ("Arquivo " + vpdf + " gerado com sucesso!")
                    view-as alert-box.
                
                /* substituido pela geracao de PDF
                os-command cat value(arquivo) > /dev/lp0 &.
                message color red/with
                    "Aguarde o final da impressão de " arquivo skip
                    "para selecionar o proximo arquivo." 
                    view-as alert-box.
                */
                    
                delete tt-arq.
                next.
            end.
        end.
    end.    
    unix silent value("rm " + varquivo1 + " -f").
end procedure.

procedure p-alfa.
    def var vqtd as int.
    def var p-qtd as int init 0.
     disp stream stela "Aguarde.....!!" 
             with frame f-stream 
             centered 1 down no-label.
for each tt-bairro where tt-bairro.marca <> "":
for each tt-extrato use-index i1
 where tt-extrato.bairro = tt-bairro.bairro  and
                           tt-extrato.cidade = tt-bairro.cidade
  by tt-extrato.clinom 
  by tt-extrato.titdtven
  by tt-extrato.titnum:
  find first tt-imp where tt-imp.rec = tt-extrato.rec no-error.
  if avail tt-imp and tt-imp.imp = yes
  then next.
  
    find clien where recid(clien) = tt-extrato.rec no-lock no-error.
    if not avail clien then next.
    
    find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
    

    /* Simula novacao */
    run loj/novacaox.p (input  clien.clicod,
                    input  tt-extrato.etbcod,
                    output vndtven,
                    output vndia,
                    output vncond,
                    output vnalor_cobrado,
                    output vnalor_novacao).

    display stream stela clien.clicod with frame f-stream 1 down.
    pause 0.

    display
      clien.clicod      label "Cod.Cliente "     at 10
      clien.clinom      label "Nome        "     at 10
      clien.proemp[1]   label "Empresa     "     at 80
      clien.endereco[1] label "Rua         "     at 10 
      clien.protel[1]   label "Telefone    "     at 80
      clien.numero[1]   label "Numero      "     at 10
      clien.proprof[1]  label "Profissao   "     at 80
      clien.compl[1]    label "Compl.      "     at 10 
      clien.prorenda[1] label "Renda mensal"     at 80
      clien.bairro[1]   label "Bairro      "     at 10 
      clien.endereco[2] label "Rua         "     at 80
      clien.cidade[1]   label "Cidade      "     at 10
      clien.numero[2]   label "Numero      "     at 80
      clien.fone        label "Fone        "     at 10
      clien.compl[2]    label "Compl.      "     at 80
      clien.fax         label "Celular     "     at 10
      clien.bairro[2]   label "Bairro      "     at 80
      clien.cidade[2]   label "Cidade      "     at 80
      cpclien.var-char9 label "Ponto Referencia: " at 10
            format "x(55)" when avail cpclien
      with frame f02 width 200 no-box side-label.
     

    display 
      clien.refnome     label "Novas Referencias" at 10
      clien.conjuge     label "Nome Conjuge" when clien.estciv = 2   at 80
      clien.endereco[4] label "Rua         "                         at 10
      clien.proemp[2]   label "Empresa     " when clien.estciv = 2   at 80
      clien.numero[4]   label "Numero      "                         at 10
      clien.protel[2]   label "Telefone    " when clien.estciv = 2   at 80
      clien.compl[4]    label "Complemento "                         at 10
      clien.proprof[2]  label "Profissao   " when clien.estciv = 2   at 80
      clien.bairro[4]   label "Bairro      "                         at 10
      clien.endereco[3] label "Rua         " when clien.estciv = 2   at 80
      clien.cidade[4]   label "Cidade      "                         at 10
      clien.numero[3]   label "Numero      " when clien.estciv = 2   at 80
      clien.reftel      label "Telefone    "                         at 10
      clien.compl[3]    label "Complemento " when clien.estciv = 2   at 80
      clien.bairro[3]   label "Bairro      " when clien.estciv = 2   at 80 
      clien.cidade[3]   label "Cidade      " when clien.estciv = 2   at 80
      with  width 200 frame fpess side-label. 
    
    /* Referencias pessoais */
    disp
      "Referencias Pessoais "              at 10
      clien.entbairro[1] label "Nome"
        when clien.entbairro[1] <> ?       at 10
      clien.entcep[1]    label "Fone Comercial"
        when clien.entcep[1] <> ?          at 45
      clien.entcidade[1] label "Celular"
        when clien.entcidade[1] <> ?       at 80
      clien.entbairro[2] label "Nome"  
        when clien.entbairro[2] <> ?       at 10
      clien.entcep[2]    label "Fone Comercial" 
        when clien.entcep[2] <> ?          at 45
      clien.entcidade[2] label "Celular"
        when clien.entcidade[2] <> ?       at 80
      clien.entbairro[3] label "Nome" 
        when clien.entbairro[3] <> ?       at 10
      clien.entcep[3]    label "Fone Comercial"
        when clien.entcep[3] <> ?          at 45
      clien.entcidade[3] label "Celular"
        when clien.entcidade[3] <> ?       at 80
      with width 200 frame frefpes side-labels.

    disp
      clien.autoriza[1] label "Observacoes de cobranca" at 10
      clien.autoriza[2] no-label at 35
      clien.autoriza[3] no-label at 35
      clien.autoriza[4] no-label at 35
      clien.autoriza[5] no-label at 35
      skip
      with width 200 frame fpess9 side-label. 

    /* * * * * * Novo trecho - novacao * * * * */
    
    disp vndtven   label "Maior Atraso"   at 10 skip
         vndia     label "Dias de atraso" at 10 skip(1)
         vncond[1] label "Plano" at 10 
         vncond[2] label "Plano" at 65 skip
         vnalor_cobrado[1]       at 17 label "Valor Cobrado...."
         vnalor_novacao[2]       at 72 label "Novacao Calculada" skip 
         vnalor_novacao[1]       at 17 label "Novacao Calculada" skip(1)
         vncond[3] label "Plano" at 10 
         vncond[4] label "Plano" at 65 skip
         vnalor_novacao[3]       at 17 label "Novacao Calculada"
         vnalor_novacao[4]       at 72 label "Novacao Calculada" skip(1)
         vncond[5] label "Plano" at 10 
         vnalor_novacao[5]       at 17 label "Novacao Calculada"
         with width 200 frame f-plano side-label title "CONDICOES".

    /* * * * * */

    for each tt-titulo.
        delete tt-titulo.
    end.
    for each titulo use-index iclicod
             where titulo.clifor = clien.clicod no-lock:
        if titulo.titnat = no and
           titulo.titsit <> "PAG"
        then do:
            create tt-titulo.
            buffer-copy titulo to tt-titulo.         
        end.
    end.         
    
    
    for each tt-titulo use-index i1
        break by tt-titulo.titnum
              by tt-titulo.titdtven desc:
        assign
          vtotal = 0
          vjuro  = 0
          vdias  = 0
          vacum  = 0.

        if tt-titulo.titdtven < today
        then do:
            find fin.tabjur 
              where fin.tabjur.etbcod = setbcod and
                    fin.tabjur.nrdias = today - tt-titulo.titdtven
              no-lock no-error.
            if not avail fin.tabjur
            then do:
                message "Fator para" today - tt-titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            assign 
              vjuro  = (tt-titulo.titvlcob * fin.tabjur.fator) - 
                       tt-titulo.titvlcob
              vtotjuro = vtotjuro + vjuro
              vtotal = tt-titulo.titvlcob + vjuro
              vtotcon = vtotcon + vtotal
              vdias  = today - tt-titulo.titdtven.
        end.
        else 
          vtotal = tt-titulo.titvlcob.

        /* agora os totais devem ser acumulados fora da condicao "last-of" no display */
        assign
          vacum = vacum + vtotal
          vtitvlcob = vtitvlcob + tt-titulo.titvlcob
          auxvjuro  = auxvjuro + vjuro
          auxvtotal = auxvtotal + vtotal.

         /* Deve apacer apenas uma linha, da prestacao mais antiga (10201) */
         /* utilizado "last" em funcao dos totalizadores */
        if last-of (tt-titulo.titnum) then do:

          /* frescuras do usuario */
          find last b-titulo
            where b-titulo.empcod = tt-titulo.empcod
              and b-titulo.titnat = tt-titulo.titnat
              and b-titulo.modcod = tt-titulo.modcod
              and b-titulo.etbcod = tt-titulo.etbcod
              and b-titulo.CliFor = tt-titulo.CliFor
              and b-titulo.titnum = tt-titulo.titnum
              /* and b-tt-titulo.titpar = tt-titulo.titpar */
            no-lock no-error.

         display 
           tt-titulo.etbcod column-label "Fil"
           tt-titulo.titnum column-label "Contrato"
           trim(string(tt-titulo.titpar,">99")) + "/" + 
             if avail b-titulo then trim(string(b-titulo.titpar,">99")) else "" 
             column-label "PC/PL"
           tt-titulo.titdtven       format "99/99/9999"
           vdias when vdias > 0      column-label "Atraso"
           tt-titulo.titvlcob column-label "Prestacao"
           vtotjuro /*vjuro*/        column-label "Juro"     
           vtotcon /*vtotal*/        column-label "Total"    
           space(3)
           /* vacum column-label "Acumulador" */
           with frame flin down width 130 no-box.
         
          assign /* totais da coluna */
            vtotcon = 0 /* total de parcelas do contrato com os juros */
            vtotjuro = 0. /* total de juros do contrato */
        end.

    end. /* titulo */

    /* totais */
    display 
      "---------------- ---------------- ----------------" at 50 skip
      vtitvlcob no-label at 50
      auxvjuro  no-label at 67
      auxvtotal no-label at 84
      with frame flin2 down width 130 no-box.

    display
      skip
      "<page>"
      with frame flin2 down width 250 no-box.
    
    /* removido a pedido do usuario
    page. */

    assign
      vtitvlcob = 0
      auxvjuro  = 0
      auxvtotal = 0.

    create tt-imp.
    tt-imp.rec = tt-extrato.rec. 
    vqtd = vqtd + 1.
    if vqtd = vqtite
    then leave.
    p-qtd = p-qtd + 1.
    if p-qtd >= 100
    then do:
        output close.
        
        p-qtd = 0.

        varquivo = "/admcom/relat/extrato" + 
            string(day(today),"99") + string(month(today),"99") +
            string(year(today),"9999") + "." + string(time).
        
        /* cabecalho duplicado
        {mdadmcab.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "137"
            &Page-Line = "66"
            &Nom-Rel   = """extrato2"""
            &Nom-Sis   = """SISTEMA CREDIARIO"""
            &Tit-Rel   = """EXTRATO DE CLIENTE"""
            &Width     = "137"
            &Form      = "frame f-cab"}
        */

    end.
end. /* tt-extrato */
end.
for each tt-imp where tt-imp.imp = no:
    tt-imp.imp = yes.
end.    
end procedure.

/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-vencto:
      def var vqtd as int.
      def var p-qtd as int.
      disp stream stela "Aguarde.....!!" 
             with frame f-stream 
             centered 1 down no-label .
    
for each tt-bairro where tt-bairro.marca <> "":        
for each tt-extrato where tt-extrato.bairro = tt-bairro.bairro and
                          tt-extrato.cidade = tt-bairro.cidade
  by tt-extrato.titdtven
  by tt-extrato.clinom 
  by tt-extrato.titnum:

  find first tt-imp where tt-imp.rec = tt-extrato.rec no-error.
  if avail tt-imp and tt-imp.imp = yes
  then next.
  
    find clien where recid(clien) = tt-extrato.rec no-lock no-error.

    if not avail clien then next.

    /* Simula novacao */
    run loj/novacaox.p (input  clien.clicod,
                    input  tt-extrato.etbcod,
                    output vndtven,
                    output vndia,
                    output vncond,
                    output vnalor_cobrado,
                    output vnalor_novacao).

    display stream stela clien.clicod with frame f-stream 1 down.
    pause 0.

    display
      clien.clicod      label "Cod.Cliente "     at 10
      clien.clinom      label "Nome        "     at 10
      clien.proemp[1]   label "Empresa     "     at 80
      clien.endereco[1] label "Rua         "     at 10 
      clien.protel[1]   label "Telefone    "     at 80
      clien.numero[1]   label "Numero      "     at 10
      clien.proprof[1]  label "Profissao   "     at 80
      clien.compl[1]    label "Compl.      "     at 10 
      clien.prorenda[1] label "Renda mensal"     at 80
      clien.bairro[1]   label "Bairro      "     at 10 
      clien.endereco[2] label "Rua         "     at 80
      clien.cidade[1]   label "Cidade      "     at 10
      clien.numero[2]   label "Numero      "     at 80
      clien.fone        label "Fone        "     at 10
      clien.compl[2]    label "Compl.      "     at 80
      clien.fax         label "Celular     "     at 10
      clien.bairro[2]   label "Bairro      "     at 80
      "Novas Referencias: " at 10
      clien.cidade[2]   label "Cidade      "     at 80
      with frame f02 width 200 no-box side-label.
     

    display 
      clien.refnome     label "Novas Referencias" at 10
      clien.conjuge     label "Nome Conjuge" when clien.estciv = 2   at 80
      clien.endereco[4] label "Rua         "                         at 10
      clien.proemp[2]   label "Empresa     " when clien.estciv = 2   at 80
      clien.numero[4]   label "Numero      "                         at 10
      clien.protel[2]   label "Telefone    " when clien.estciv = 2   at 80
      clien.compl[4]    label "Complemento "                         at 10
      clien.proprof[2]  label "Profissao   " when clien.estciv = 2   at 80
      clien.bairro[4]   label "Bairro      "                         at 10
      clien.endereco[3] label "Rua         " when clien.estciv = 2   at 80
      clien.cidade[4]   label "Cidade      "                         at 10
      clien.numero[3]   label "Numero      " when clien.estciv = 2   at 80
      clien.reftel      label "Telefone    "                         at 10
      clien.compl[3]    label "Complemento " when clien.estciv = 2   at 80
      clien.bairro[3]   label "Bairro      " when clien.estciv = 2   at 80 
      clien.cidade[3]   label "Cidade      " when clien.estciv = 2   at 80
      with  width 200 frame fpess side-label. 
    
    /* Referencias pessoais */
    disp
      "Referencias Pessoais "              at 10
      clien.entbairro[1] label "Nome"
        when clien.entbairro[1] <> ?       at 10
      clien.entcep[1]    label "Fone Comercial"
        when clien.entcep[1] <> ?          at 45
      clien.entcidade[1] label "Celular"
        when clien.entcidade[1] <> ?       at 80
      clien.entbairro[2] label "Nome"  
        when clien.entbairro[2] <> ?       at 10
      clien.entcep[2]    label "Fone Comercial" 
        when clien.entcep[2] <> ?          at 45
      clien.entcidade[2] label "Celular"
        when clien.entcidade[2] <> ?       at 80
      clien.entbairro[3] label "Nome" 
        when clien.entbairro[3] <> ?       at 10
      clien.entcep[3]    label "Fone Comercial"
        when clien.entcep[3] <> ?          at 45
      clien.entcidade[3] label "Celular"
        when clien.entcidade[3] <> ?       at 80
      with width 200 frame frefpes side-labels.

    disp
      clien.autoriza[1] label "Observacoes de cobranca" at 10
      clien.autoriza[2] no-label at 35
      clien.autoriza[3] no-label at 35
      clien.autoriza[4] no-label at 35
      clien.autoriza[5] no-label at 35
      skip
      with width 200 frame fpess9 side-label. 

    /* * * * * * Novo trecho - novacao * * * * */
    
    disp vndtven   label "Maior Atraso"   at 10 skip
         vndia     label "Dias de atraso" at 10 skip(1)
         vncond[1] label "Plano" at 10 
         vncond[2] label "Plano" at 65 skip
         vnalor_cobrado[1]       at 17 label "Valor Cobrado...."
         vnalor_novacao[2]       at 72 label "Novacao Calculada" skip 
         vnalor_novacao[1]       at 17 label "Novacao Calculada" skip(1)
         vncond[3] label "Plano" at 10 
         vncond[4] label "Plano" at 65 skip
         vnalor_novacao[3]       at 17 label "Novacao Calculada"
         vnalor_novacao[4]       at 72 label "Novacao Calculada" skip(1)
         vncond[5] label "Plano"  at 10 
         vnalor_novacao[5]        at 17 label "Novacao Calculada"
         with width 200 frame f-plano side-label title "CONDICOES".

    /* * * * * */

    for each 
      titulo use-index iclicod
        where titulo.clifor  = clien.clicod 
          and titulo.titnat  = no 
          and titulo.titsit <> "PAG"
        no-lock
        break by titulo.titnum
              by titulo.titdtven desc:

        /* nao pode "next" dentro de break by
        if titulo.titsit = "PAG"
        then next.
        */
        assign
          vtotal = 0
          vjuro  = 0
          vdias  = 0
          vacum  = 0.

        if titulo.titdtven < today
        then do:
            find fin.tabjur 
              where fin.tabjur.etbcod = setbcod and
                    fin.tabjur.nrdias = today - titulo.titdtven
              no-lock no-error.
            if not avail fin.tabjur
            then do:
                message "Fator para" today - titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            assign 
              vjuro  = (titulo.titvlcob * fin.tabjur.fator) - 
                       titulo.titvlcob
              vtotjuro = vtotjuro + vjuro
              vtotal = titulo.titvlcob + vjuro
              vtotcon = vtotcon + vtotal
              vdias  = today - titulo.titdtven.
        end.
        else 
          vtotal = titulo.titvlcob.

        /* agora os totais devem ser acumulados fora da condicao "last-of" no display */
        assign
          vacum = vacum + vtotal
          vtitvlcob = vtitvlcob + titulo.titvlcob
          auxvjuro  = auxvjuro + vjuro
          auxvtotal = auxvtotal + vtotal.

         /* Deve apacer apenas uma linha, da prestacao mais antiga (10201) */
         /* utilizado "last" em funcao dos totalizadores */
        if last-of (titulo.titnum) then do:

          /* frescuras do usuario */
          find last b-titulo
            where b-titulo.empcod = titulo.empcod
              and b-titulo.titnat = titulo.titnat
              and b-titulo.modcod = titulo.modcod
              and b-titulo.etbcod = titulo.etbcod
              and b-titulo.CliFor = titulo.CliFor
              and b-titulo.titnum = titulo.titnum
              /* and b-titulo.titpar = titulo.titpar */
            no-lock no-error.

         display 
           titulo.etbcod column-label "Fil"
           titulo.titnum column-label "Contrato"
           trim(string(titulo.titpar,">99")) + "/" + 
             if avail b-titulo then trim(string(b-titulo.titpar,">99")) else "" 
             column-label "PC/PL"
           titulo.titdtven       format "99/99/9999"
           vdias when vdias > 0      column-label "Atraso"
           titulo.titvlcob column-label "Prestacao"
           vtotjuro /*vjuro*/        column-label "Juro"     
           vtotcon /*vtotal*/        column-label "Total"    
           space(3)
           /* vacum column-label "Acumulador" */
           with frame flin down width 130 no-box.
         
          assign /* totais da coluna */
            vtotcon = 0 /* total de parcelas do contrato com os juros */
            vtotjuro = 0. /* total de juros do contrato */
        end.

    end. /* titulo */

    /* totais */
    display 
      "---------------- ---------------- ----------------" at 50 skip
      vtitvlcob no-label at 50
      auxvjuro  no-label at 67
      auxvtotal no-label at 84
      with frame flin2 down width 130 no-box.

    /*
    display
      skip
      fill("=", 137) format "x(248)" skip
      with frame flin2 down width 250 no-box.
    */
                   
    display
        skip
        "<page>"
        with frame flin2 down width 250 no-box.
    
    /* removido a pedido do usuario
    page. */

    assign
      vtitvlcob = 0
      auxvjuro  = 0
      auxvtotal = 0.

    create tt-imp.
    tt-imp.rec = tt-extrato.rec. 
    vqtd = vqtd + 1.
    if vqtd = vqtite
    then leave.
end. /* tt-extrato */
end.
for each tt-imp where tt-imp.imp = no:
    tt-imp.imp = yes.
end. 

end procedure.

/* = = = = = = = = = = = = = = = = = = = = = */

procedure p-bairro:

def var vqtd as int.

disp stream stela "Aguarde.....!!" 
             with frame f-stream 
             centered 1 down no-label.

for each tt-bairro where tt-bairro.bairro <> "" and tt-bairro.marca = "*"
            and tt-bairro.bairro <> ? :
for each tt-extrato where tt-extrato.bairro = tt-bairro.bairro and
                          tt-extrato.cidade = tt-bairro.cidade
  by tt-extrato.bairro
  by tt-extrato.titdtven
  by tt-extrato.clinom 
  by tt-extrato.titnum:

    
    find first tt-imp where tt-imp.rec = tt-extrato.rec no-error.
    
    if avail tt-imp and tt-imp.imp = yes
    then next.

    find clien where recid(clien) = tt-extrato.rec no-lock no-error.

    if not avail clien then next.

    /*Seleciona por bairro -  Antonio */
    if clien.bairro[1] <> tt-bairro.bairro or
       clien.cidade[1] <> tt-bairro.cidade then next.
   /**/     
    
    /* Simula novacao */
    run loj/novacaox.p (input  clien.clicod,
                    input  tt-extrato.etbcod,
                    output vndtven,
                    output vndia,
                    output vncond,
                    output vnalor_cobrado,
                    output vnalor_novacao).

    display stream stela clien.clicod with frame f-stream 1 down.
    pause 0.

    display
      clien.clicod      label "Cod.Cliente "     at 10
      clien.clinom      label "Nome        "     at 10
      clien.proemp[1]   label "Empresa     "     at 80
      clien.endereco[1] label "Rua         "     at 10 
      clien.protel[1]   label "Telefone    "     at 80
      clien.numero[1]   label "Numero      "     at 10
      clien.proprof[1]  label "Profissao   "     at 80
      clien.compl[1]    label "Compl.      "     at 10 
      clien.prorenda[1] label "Renda mensal"     at 80
      clien.bairro[1]   label "Bairro      "     at 10 
      clien.endereco[2] label "Rua         "     at 80
      clien.cidade[1]   label "Cidade      "     at 10
      clien.numero[2]   label "Numero      "     at 80
      clien.fone        label "Fone        "     at 10
      clien.compl[2]    label "Compl.      "     at 80
      clien.fax         label "Celular     "     at 10
      clien.bairro[2]   label "Bairro      "     at 80
      "Novas Referencias: " at 10
      clien.cidade[2]   label "Cidade      "     at 80
      with frame f02 width 200 no-box side-label.
     

    display 
      clien.refnome     label "Novas Referencias" at 10
      clien.conjuge     label "Nome Conjuge" when clien.estciv = 2   at 80
      clien.endereco[4] label "Rua         "                         at 10
      clien.proemp[2]   label "Empresa     " when clien.estciv = 2   at 80
      clien.numero[4]   label "Numero      "                         at 10
      clien.protel[2]   label "Telefone    " when clien.estciv = 2   at 80
      clien.compl[4]    label "Complemento "                         at 10
      clien.proprof[2]  label "Profissao   " when clien.estciv = 2   at 80
      clien.bairro[4]   label "Bairro      "                         at 10
      clien.endereco[3] label "Rua         " when clien.estciv = 2   at 80
      clien.cidade[4]   label "Cidade      "                         at 10
      clien.numero[3]   label "Numero      " when clien.estciv = 2   at 80
      clien.reftel      label "Telefone    "                         at 10
      clien.compl[3]    label "Complemento " when clien.estciv = 2   at 80
      clien.bairro[3]   label "Bairro      " when clien.estciv = 2   at 80 
      clien.cidade[3]   label "Cidade      " when clien.estciv = 2   at 80
      with  width 200 frame fpess side-label. 
    
    /* Referencias pessoais */
    disp
      "Referencias Pessoais "              at 10
      clien.entbairro[1] label "Nome"
        when clien.entbairro[1] <> ?       at 10
      clien.entcep[1]    label "Fone Comercial"
        when clien.entcep[1] <> ?          at 45
      clien.entcidade[1] label "Celular"
        when clien.entcidade[1] <> ?       at 80
      clien.entbairro[2] label "Nome"  
        when clien.entbairro[2] <> ?       at 10
      clien.entcep[2]    label "Fone Comercial" 
        when clien.entcep[2] <> ?          at 45
      clien.entcidade[2] label "Celular"
        when clien.entcidade[2] <> ?       at 80
      clien.entbairro[3] label "Nome" 
        when clien.entbairro[3] <> ?       at 10
      clien.entcep[3]    label "Fone Comercial"
        when clien.entcep[3] <> ?          at 45
      clien.entcidade[3] label "Celular"
        when clien.entcidade[3] <> ?       at 80
      with width 200 frame frefpes side-labels.

    disp
      clien.autoriza[1] label "Observacoes de cobranca" at 10
      clien.autoriza[2] no-label at 35
      clien.autoriza[3] no-label at 35
      clien.autoriza[4] no-label at 35
      clien.autoriza[5] no-label at 35
      skip
      with width 200 frame fpess9 side-label. 

    /* * * * * * Novo trecho - novacao * * * * */
    
    disp vndtven   label "Maior Atraso"   at 10 skip
         vndia     label "Dias de atraso" at 10 skip(1)
         vncond[1] label "Plano" at 10 
         vncond[2] label "Plano" at 65 skip
         vnalor_cobrado[1]       at 17 label "Valor Cobrado...."
         vnalor_novacao[2]       at 72 label "Novacao Calculada" skip 
         vnalor_novacao[1]       at 17 label "Novacao Calculada" skip(1)
         vncond[3] label "Plano" at 10 
         vncond[4] label "Plano" at 65 skip
         vnalor_novacao[3]       at 17 label "Novacao Calculada"
         vnalor_novacao[4]       at 72 label "Novacao Calculada" skip(1)
         vncond[5] label "Plano" at 10 
         vnalor_novacao[5]       at 17 label "Novacao Calculada"
         with width 200 frame f-plano side-label title "CONDICOES".

    /* * * * * */

    for each 
      titulo use-index iclicod
        where titulo.clifor  = clien.clicod 
          and titulo.titnat  = no 
          and titulo.titsit <> "PAG"
        no-lock
        break by titulo.titnum
              by titulo.titdtven desc:

        /* nao pode "next" dentro de break by
        if titulo.titsit = "PAG"
        then next.
        */
        assign
          vtotal = 0
          vjuro  = 0
          vdias  = 0
          vacum  = 0.

        if titulo.titdtven < today
        then do:
            find fin.tabjur 
              where fin.tabjur.etbcod = setbcod and
                    fin.tabjur.nrdias = today - titulo.titdtven
              no-lock no-error.
            if not avail fin.tabjur
            then do:
                message "Fator para" today - titulo.titdtven
                        "dias de atraso, nao cadastrado".
                pause.
                undo.
            end.
            assign 
              vjuro  = (titulo.titvlcob * fin.tabjur.fator) - 
                       titulo.titvlcob
              vtotjuro = vtotjuro + vjuro
              vtotal = titulo.titvlcob + vjuro
              vtotcon = vtotcon + vtotal
              vdias  = today - titulo.titdtven.
        end.
        else 
          vtotal = titulo.titvlcob.

        /* agora os totais devem ser acumulados fora da condicao "last-of" no display */
        assign
          vacum = vacum + vtotal
          vtitvlcob = vtitvlcob + titulo.titvlcob
          auxvjuro  = auxvjuro + vjuro
          auxvtotal = auxvtotal + vtotal.

         /* Deve apacer apenas uma linha, da prestacao mais antiga (10201) */
         /* utilizado "last" em funcao dos totalizadores */
        if last-of (titulo.titnum) then do:

          /* frescuras do usuario */
          find last b-titulo
            where b-titulo.empcod = titulo.empcod
              and b-titulo.titnat = titulo.titnat
              and b-titulo.modcod = titulo.modcod
              and b-titulo.etbcod = titulo.etbcod
              and b-titulo.CliFor = titulo.CliFor
              and b-titulo.titnum = titulo.titnum
              /* and b-titulo.titpar = titulo.titpar */
            no-lock no-error.

         display 
           titulo.etbcod column-label "Fil"
           titulo.titnum column-label "Contrato"
           trim(string(titulo.titpar,">99")) + "/" + 
             if avail b-titulo then trim(string(b-titulo.titpar,">99")) else "" 
             column-label "PC/PL"
           titulo.titdtven       format "99/99/9999"
           vdias when vdias > 0      column-label "Atraso"
           titulo.titvlcob column-label "Prestacao"
           vtotjuro /*vjuro*/        column-label "Juro"     
           vtotcon /*vtotal*/        column-label "Total"    
           space(3)
           /* vacum column-label "Acumulador" */
           with frame flin down width 130 no-box.
         
          assign /* totais da coluna */
            vtotcon = 0 /* total de parcelas do contrato com os juros */
            vtotjuro = 0. /* total de juros do contrato */
        end.

    end. /* titulo */

    /* totais */
    display 
      "---------------- ---------------- ----------------" at 50 skip
      vtitvlcob no-label at 50
      auxvjuro  no-label at 67
      auxvtotal no-label at 84
      with frame flin2 down width 130 no-box.

    /*
    display
      skip
      fill("=", 137) format "x(248)" skip
      with frame flin2 down width 250 no-box.
    */
    
    display
        skip
        "<page>"
        with frame flin2 down width 250 no-box.
    
    /* removido a pedido do usuario
    page. */

    assign
      vtitvlcob = 0
      auxvjuro  = 0
      auxvtotal = 0.

    create tt-imp.
    tt-imp.rec = tt-extrato.rec. 
    vqtd = vqtd + 1.
    if vqtd = vqtite
    then leave.
end. /* tt-extrato */
end.
for each tt-imp where tt-imp.imp = no:
    tt-imp.imp = yes.
end. 

end procedure.

