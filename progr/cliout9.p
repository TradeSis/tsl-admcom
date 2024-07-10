/* helio 26072023 Otimização de Cadastro de Crédito V6 - restricoes admcom e ie */
/* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 */

{admcab.i}
/*****
cpclien.var-ext1 = cartao de loja
cpclien.var-ext6 = confirmado  - referencias comerciais
cpclien.var-ext2 = banco       - referencias bancarias
cpclien.var-ext3 = tipo conta  - referencias bancarias
cpclien.var-ext4 = tempo conta - referencias bancarias
cpclien.var-ext5 = confirmado  - referencias bancarias
cpclien.var-int  = Cartao de crédito
cpclien.var-int2 = 2-Nao procurado pelo correio 1-Corrigir endereco
cpclien.var-char1 = Cnpj do autonomo
cpclien.var-char2 = Cartao credito confirmado
cpclien.var-char3 = Carro 1
cpclien.var-char4 = Carro 2
cpclien.var-char5 = Carro 3
***/

def var v-ok-mail as logical no-undo.
def var motivo-corresp as char format "x(27)".
def input  parameter vrecid as recid.
def var    vcarro    like   carro.carsit.
def var    vclicod   like   clien.clicod.
def buffer bclien    for    clien.
form with frame fres.
def var i as int.
def var ventrefcom as date format "99/99/9999".

def var vcidade-aux             as char.
def var vuf-aux                 as char.

def var log-refban as log format "Sim/Nao" extent 5.
def var log-refcom as log format "Sim/Nao" extent 5.

/** dne
def var p-ufecod like unfed.ufecod.
def var p-locnum like munic.loc_num.
def var p-bainum like bairro.codbai.
def var p-lognum like ceplog.log_num.
def var p-cepnum as char.
*/

def var vcodprof   as integer extent 2.

def var xx as char.
def var auxcartao as char extent 7 format "x(20)" 
      init [" 1-Visa"," 2-Master"," 3-Banricompras"," 4-Hipercard",
      " 5-Cartoes de Lojas"," 6-American Express"," 7-Dinners"].

def var aux1cartao as char extent 7 format "x(20)" 
      init ["( )","( )","( )","( )","( )","( )","( )"].
def var vaux as int.      

DEF VAR AUX-BANCO AS CHAR EXTENT 4 FORMAT "X(30)".
DEF VAR MARCA-BANCO AS CHAR EXTENT 4 FORMAT "(X)" .

def var aux-endereco as char extent 7 format "X(30)".
def var marca-endereco as char extent 7 format "(X)".

DEF VAR auxcorresp as char extent 2 format "x(20)"
    init["CORRIGIR ENDERECO","NAO PROCURADO PELO CORREIO"].
     
def temp-table tclien like clien.
    
def temp-table tcpclien like cpclien.

def var dddok as log.

find clien where recid(clien) = vrecid no-lock.

/*** INDICAÇÃO DE CLIENTE ***/
pause 0.
if clien.dtcad = today
then do :
    run indicacl.p(input vrecid).
end.
find first indicacl where indicacl.clicod = clien.clicod no-lock no-error.
/*** FIM INDICAÇÃO ***/    
    
find cpclien where cpclien.clicod = clien.clicod no-lock no-error.

create tclien.
buffer-copy clien to tclien.

create tcpclien.
if not avail cpclien
then tcpclien.clicod = clien.clicod.
else buffer-copy cpclien to tcpclien.

if tclien.tippes
then do:

    assign
        tclien.nacion = "BRASILEIRA".
    
    /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
    *update tclien.sexo 
    */
    disp tclien.genero to 40 with frame f2 width 80 row 9
        title " Informacoes pessoais ".
    
    do on error undo:
    
        /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
        *update tclien.estciv*/
         disp tclien.estciv to 64
help "1.Solteiro 2.Casado 3.Viuvo 4.Desquitado 5.Divorciado 6.Falecido"
               with no-validate
               frame f2 width 80 row 9 overlay.

               
        if tclien.estciv < 1
        then do:
            message "numero informado invalido".
            undo.
        end.
        if tclien.estciv > 6
        then do:
            message "Numero informado invalido".
            undo.
        end.
        
    end.
               
    /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
    *update tclien.nacion */
     disp tclien.nacion to 30
        /*   tclien.natur   to 55 */
           with frame f2 width 80 row 9.
    

    
    bl_naturalidade:
    do on error undo, retry:
            
        /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
        *update tcpclien.var-char10 */
        disp tcpclien.var-char10 at 7  label "Naturalidade" format "x(40)"
               help "PRESSIONE F7 PARA ALTERAR"
                    with frame f2.
        
        if length(tcpclien.var-char10) > 6
        then do:                          
        
            assign
                vcidade-aux
              = substring(tcpclien.var-char10,1,length(tcpclien.var-char10) - 5)
      
                vuf-aux
             = substring(tcpclien.var-char10,length(tcpclien.var-char10) - 1,2).

            release munic.
            find first munic where munic.cidnom = vcidade-aux
                               and munic.ufecod = vuf-aux
                                            no-lock no-error.
                                            
        end.                                    
                                            
        if avail munic
        then do:
                                                      
            assign tclien.natur = tcpclien.var-char10.

        end.
        /*
        else do:
                
            message "Cidade Inválida! Pressione F7 e escolha uma Cidade."
                        view-as alert-box.
                          
            undo, retry.
                                       
        end.
        */                                       
    end.
                                                   
    
 

    do on error undo:
    
        /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
        *update tclien.dtnasc */
        disp tclien.dtnasc to 30 format "99/99/9999"
               with frame f2 width 80 row 9 
               .

        if ( year(today) - year(tclien.dtnasc)) < 13 or
           ( year(today) - year(tclien.dtnasc)) > 100
        then do:   
            if ( year(today) - year(clien.dtnasc)) < 13 
            then 
                message "Cliente deve ter no minimo 13 anos de idade.".

            if ( year(today) - year(clien.dtnasc)) > 100 
            then 
                message "Cliente deve ter no maximo 100 anos.".

            undo.
        end.
        
    end.

    /* antonio - sol 26210 */                        
    run Pi-cic-number(input-output tclien.ciccgc).    
    disp tclien.ciccgc with frame f2.
    /**/                                             
 
    /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
    *update tclien.ciinsc to 45 label "Identidade"
           tclien.ciccgc to 38 with frame f2 width 80 row 9 side-labels.
    */
    disp tclien.ciinsc to 45 label "Identidade"
           tclien.ciccgc to 38 with frame f2 width 80 row 9 side-labels.
           
    /* antonio - sol 26210 */                        
    run Pi-cic-number(input-output tclien.ciccgc).    
    disp tclien.ciccgc to 38 with frame f2.
    /**/                                             
    
    /* helio 13022023 - ID GLPI 156585 e 156556 Orquestra 456067 e 456058 
    *update tclien.pai  at 5    format "x(50)"
           tclien.mae  at 16   format "x(50)" */
     disp tclien.pai  at 5    format "x(50)"
          tclien.mae  at 16   format "x(50)"
           tclien.numdep to 22
           with frame f2 .
    do on error undo, retry:
       update tclien.zona to 60 label "E-mail" format "x(40)"
            with frame f2.
       /* antonio - sol 25912 */
       if tclien.zona <> ""
       then do:
            assign tclien.zona = lc(tclien.zona).
            disp tclien.zona with frame f2.
            run pfval_mail.p (input tclien.zona, output v-ok-mail).
            if v-ok-mail = no then undo, retry.
       end.
       /**/     
       if tclien.zona = ""
       then do:
            bell.
            tcpclien.tememail = yes.
            message "Cliente possui e-mail ? " update tcpclien.tememail .
            if tcpclien.tememail = yes
            then undo, retry.
            tcpclien.datexp = today.
       end.
       else do:
            tcpclien.tememail = yes.
            update tcpclien.emailpromocional to 41
                label "Deseja receber e-mail promocional ? "
            with frame f2.    
            tcpclien.datexp = today.
       end.
        
    end.
    run grau-instrucao.
    run plano-saude.
    run seguro.
 
end.
else
    update tclien.nacion
           tclien.ciinsc label "Insc.Estadual" format "x(12)"
           tclien.ciccgc
           with 1 column frame f3 width 80 .


/* * * * * * * * * * *
   trecho em manutencao * * * * */
   /* 
   p-cepnum = tclien.cep[1].
     */
    repeat on endkey undo:
        update tclien.cep[1]     at 8   label "CEP" 
           with frame fres.
        /* 
        if p-cepnum <> tclien.cep[1]
        then do:
            run inceplog.p(input tclien.cep[1],
                       output p-ufecod,
                       output p-locnum,
                       output p-bainum,
                       output p-lognum).
            find unfed where unfed.ufecod = p-ufecod no-lock no-error.
            if avail unfed and
                tclien.ufecod[1] <> unfed.ufecod
            then tclien.ufecod[1] = unfed.ufecod.
            find first munic where  munic.loc_num = p-locnum
                                no-lock no-error.
            if avail munic and
                tclien.cidade[1] <> munic.cidnom
            then    assign
                        tcpclien.cidcod = p-locnum
                        tclien.cidade[1] = munic.cidnom.
            find bairro where bairro.codbai = p-bainum no-lock no-error.
            if avail bairro and
                tclien.bairro[1] <> bairro.nome
            then    assign
                        tcpclien.baicod = p-bainum
                        tclien.bairro[1] = bairro.nome.
            find ceplog where ceplog.log_num = p-lognum no-lock no-error.
            if avail ceplog
            then do:
                if tclien.cep[1] <> ceplog.log_cep
                then tclien.cep[1] = ceplog.log_cep.
                if tclien.endereco[1] <> ceplog.log_no
                then    assign
                            tcpclien.ruacod = p-lognum
                            tclien.endereco[1] = ceplog.log_no.
            end.                        
        end. 
        ***/              
        leave.   
    end.        
    disp tclien.cep[1] with frame fres.
    pause 0.
    update  tclien.ufecod[1]   at 5  label "Estado" 
            tclien.cidade[1]   at 5  label "Cidade" 
            tclien.bairro[1]   at 5  label "Bairro"  format "x(20)"
            tclien.endereco[1] at 8  label "Rua"     format "x(40)"
            tclien.numero[1]   at 5  label "Numero" 
            tclien.compl[1]      label "Complemento" 
            tcpclien.var-char9 at 5  label "Ponto Referencia" format "x(40)"
            tclien.tipres      at 5
            tclien.temres      at 5  format "999999" 
            with side-label  width 80 frame fres 
              title " Informacoes Residenciais ".

    if tcpclien.correspondencia = no and
       (clien.endereco[1] <> tclien.endereco[1] or
        clien.numero[1] <> tclien.numero[1] or
        clien.compl[1] <> tclien.compl[1] or
        clien.bairro[1] <> tclien.bairro[1] or
        clien.cidade[1] <> tclien.cidade[1] or
        clien.ufecod[1] <> tclien.ufecod[1] or
        clien.cep[1] <> tclien.cep[1])
    then tcpclien.correspondencia = yes.
        
    update tcpclien.correspondencia at 5 label "Enviar correspondencia?"
           with frame fres.
    update tcpclien.var-log2 at 5 
                label "Corrigir endereco? "
                with frame fres.

    assign
        aux-endereco[1] = "Corrigir endereco"
        aux-endereco[2] = "Nao procurado pelo correio"
        aux-endereco[3] = "Mudou-se"
        aux-endereco[4] = "Desconhecido"
        aux-endereco[5] = "Recusado"
        aux-endereco[6] = "Insuficiente"
        aux-endereco[7] = "Numero nao existe"
        .
    
    do vaux = 1 to 7:
        if tcpclien.var-int2 = vaux
        then marca-endereco[vaux] = "X"  .
        else marca-endereco[vaux] = ""   .
    end.
    
    if tcpclien.var-log2 = yes
    then repeat on endkey undo:
        disp marca-endereco[1] at 1
             aux-endereco[1]
             marca-endereco[2] at 1
             aux-endereco[2]
             marca-endereco[3] at 1
             aux-endereco[3]
             marca-endereco[4] at 1
             aux-endereco[4]
             marca-endereco[5] at 1
             aux-endereco[5]
             marca-endereco[6] at 1
             aux-endereco[6]
             marca-endereco[7] at 1
             aux-endereco[7]
             with frame f-sitender 1 down row 8 column 40
                overlay no-label title " Atualizar endereco ".
             
        choose field  marca-endereco
                help "F1 para seguir..."
                with frame f-sitender.
        
        if keyfunction(lastkey) = "GO"
        then leave.
        vaux = frame-index.
        marca-endereco = "".
        marca-endereco[vaux] = "X".
        disp marca-endereco[vaux] with frame f-sitender.
        pause 0.
    end.
    else assign
            tcpclien.var-int2 = 0
            marca-endereco = "".
    do vaux = 1 to 7:
        if marca-endereco[vaux] = "X"
        then tcpclien.var-int2 = vaux.
    end.

    tcpclien.datexp = today.
            
    /* Nao deve permitir DDD invalido ou qq tipo de formatacao no n. do tel. */
    do on error undo:
      update
        tclien.fone format "(xx) xxxxxxxxx"  at 5 with frame fres.

      if tclien.fone <> ? and tclien.fone <> "" then do:
        dddok = no.
        run validaddd.p (input  tclien.ufecod[1],
                         input  tclien.fone,
                         input  1, /* 1- Convencional, 2- Celular */
                         output dddok).
        if not dddok then do: 
          message "Numero de telefone ou DDD invalido. Nao grave celular neste campo.".
          undo, retry.
        end.
      end.
    end.

    do on error undo:
      update
        tclien.fax   label "Celular" format "(xx) xxxxxxxxx" at 5
        with frame fres.

      if tclien.fax <> ? and tclien.fax <> ""
      then do:
        dddok = no.
        run validaddd.p (input  tclien.ufecod[1],
                         input  tclien.fax,
                         input  2, /* 1- Convencional, 2- Celular */
                         output dddok).
        if not dddok then do:
          message "Numero de telefone ou DDD invalido. Nao grave tel.convencional neste campo.".
          undo, retry.
        end.
      end.
    end.
      
   /* * * * * * * * * * * 
   fim do trecho em manutencao * * * * */


if tclien.tippes
then do:
    update tclien.proemp[1]   label "Empresa" format "x(50)" skip                         tclien.protel[1]   label "Telefone"               
           tclien.protel[1]   label "Telefone"             
                        format "(xx) xxxxxxxxxxxxxxx"        skip
           tclien.prodta[1]   label "Data Admissao"          skip
                 with 2 column width 80 frame finfpro
                     title " Informacoes Profissionais " color white/cyan.
      
    
    bl_profissao1:       
    do on error undo, retry:

        display tclien.proprof[1] format "x(20)" label "Profissao"
                  with 2 column frame finfpro 
                      title " Informacoes Profissionais " color white/cyan .
        PAUSE 0.     
        update tcpclien.var-int4 label "Cod Profissao" format ">>>>9"
                                help "PRESSIONE F7 PARA ALTERAR"
                 with 2 column frame finfpro
                     title " Informacoes Profissionais " color white/cyan.
                     
        find first profissao where profissao.codprof = tcpclien.var-int4
                                no-lock no-error.
        if avail profissao
        then do:
        
            assign tclien.proprof[1] = profissao.profdesc.
            
            display tclien.proprof[1] format "x(20)" label "Profissao"
                  with 2 column frame finfpro 
                      title " Informacoes Profissionais " color white/cyan .
                      
        end.              
        /*
        else do:
        
            message "Profissão Inválida! Pressione F7 e escolha uma profissão."
                           view-as alert-box.
        
            undo, retry.

        end.
        */             
    end.                 
    
        /*
        if replace(Tclien.proprof[1],"ô","o") begins "autonomo"
        then
        */ 
         update tcpclien.var-char1 format "x(18)" label "CNPJ" 
                   tclien.empresa_inscricaoEstadual
                   with 2 column width 80 frame finfpro
                    title " Informacoes Profissionais " color white/cyan.
        disp tclien.patrimonio
        with  frame finfpro.
    update
           tclien.prorenda[1] label "Soma das rendas"
           tclien.endereco[2] label "Rua"
           tclien.numero[2]   label "Numero"
           tclien.compl[2]    label "Complemento"
           tclien.bairro[2]   label "Bairro"
           tclien.cidade[2]   label "Cidade"
           tclien.ufecod[2]   label "Estado"
           tclien.cep[2]      label "CEP"
           with 2 column width 80 frame finfpro
                title " Informacoes Profissionais ".
end.
def var  vcpfconj               like clien.ciccgc.
def var  vnomconj               like clien.clinom.
def var  vnatconj               as char.
def var  vnatconj-var-char10    as char.

def var vok as log.

if tclien.estciv = 2 and tclien.tippes
then do:
    vnomconj = substr(tclien.conjuge,1,50).
    vcpfconj = substr(tclien.conjuge,51,20).
    vnatconj = substr(tclien.conjuge,71,40).
    
    update vnomconj with frame fconj.
    if vnomconj = ? then vnomconj = "".
    
    if vnomconj <> ""
    then do on error undo, retry:
        update vcpfconj format "x(11)" with frame fconj.
        /* corretiva 306840 */
        if vcpfconj entered
        then do.
            run cpf.p(input vcpfconj, output vok).
        end.
        else vok = yes.
        if vok = no 
        then do:
             message "Cpf Invalido". undo, retry.
        end.
    end.
    
    /*
    update vnatconj label "Natural de"
        format "x(20)" with frame fconj.
    */    
    
    assign vnatconj-var-char10 = vnatconj.
    
    if vnatconj-var-char10 = ?
    then assign vnatconj-var-char10 = "".
    
    bl_nat_conj:
    do on error undo, retry:
                
        update vnatconj-var-char10  label "Naturalidade" format "x(40)"
                 help "PRESSIONE F7 PARA ALTERAR"
                     with frame fconj.

         if vnatconj-var-char10 = ""
         then leave bl_nat_conj.
        
        if length(vnatconj-var-char10) > 6
        then do:
                                                   
            assign
                vcidade-aux
            = substring(tcpclien.var-char10,1,length(tcpclien.var-char10) - 5)

                vuf-aux
            = substring(tcpclien.var-char10,length(tcpclien.var-char10) - 1,2).

            release munic.
            find first munic where munic.cidnom = vcidade-aux
                               and munic.ufecod = vuf-aux
                                      no-lock no-error.
                                      
        end.
        
        /*                                                                       ~          if not avail munic
        then do:
                                        
            message "Cidade Inválida! Pressione F7 e escolha uma Cidade."
                         view-as alert-box.
                          
            undo, retry.
                                       
        end.
        */                                       
    end.
                                                   
    assign vnatconj = vnatconj-var-char10.
                                           
        if vnatconj = ? then vnatconj = "".    
    
        tclien.conjuge = string(vnomconj,"x(50)") + string(vcpfconj,"x(20)")
            + string(vnatconj,"x(40)").
            
    update tclien.nascon format "99/99/9999" with frame fconj.
            
    update tclien.conjpai   label "Filiacao:  Pai"
           tclien.conjmae   label "           Mae"
           tclien.proemp[2] label "Empresa"
           tclien.protel[2] label "Telefone"  format "(xx) xxxxxxxxx"
           tclien.prodta[2] label "Data Admissao" format "99/99/9999"
             with frame fconj.

    bl_profissao2:       
    do on error undo, retry:
        display tclien.proprof[2] format "x(20)" label "Profissao"
                                with frame fconj.
        pause 0.                        
        update tcpclien.var-int5 label "Cod Profissao" format ">>>>9"
                                help "PRESSIONE F7 PARA ALTERAR"
                 with frame fconj.
                     
        if tcpclien.var-int5 = 0
        then leave bl_profissao2.
                     
        find first profissao where profissao.codprof = tcpclien.var-int5
                                no-lock no-error.
        if avail profissao
        then do:
        
            assign tclien.proprof[2] = profissao.profdesc.
            
            display tclien.proprof[2] format "x(20)" label "Profissao"
                        with frame fconj.
                                              
        end.              
        /*
        else do:
        
            message "Profissão Inválida! Pressione F7 e escolha uma profissão."
                           view-as alert-box.
        
            undo, retry.

        end.
        */             
    end.                 
           
          
    update tclien.prorenda[2] label "Renda mensal"
                with frame fconj.
    /*
    if  tclien.prorenda[2] > 0 and
        tclien.prorenda[2] <> clien.prorenda[2]
    then run alerta-renda-conju.            
    */
    update tclien.endereco[3] label "Rua"
           tclien.numero[3] label "Numero"
           tclien.compl[3] label "Complemento"
           tclien.bairro[3] label "Bairro"
           tclien.cidade[3] label "Cidade"
           tclien.ufecod[3] label "Estado"
           tclien.cep[3] label "CEP"
           with 2 column width 80 frame fconj
                title " Informacoes do Conjuge ".

    hide frame fconj no-pause.
end.
    /**/
    def var auxcfcar as log extent 9 format "Sim/Nao".
    repeat vaux = 1 to 7:
        if int(tcpclien.var-int[vaux]) > 0
        then aux1cartao[vaux] = "(X)".
        else aux1cartao[vaux] = "( )".
       /* if acha(string(vaux),tcpclien.var-char2) = "Sim"
        then auxcfcar[vaux] = yes.
        else auxcfcar[vaux] = no. */
    end.    
    /**/
    repeat:
      display aux1cartao[1] no-label format "x(3)"
          auxcartao[1] no-label 
          "                 " no-label
          /*auxcfcar[1] no-label*/ skip 
          aux1cartao[2] no-label format "x(3)"
          auxcartao[2] no-label
          "                 " no-label
          /*auxcfcar[2] no-label*/ skip 
          aux1cartao[3] no-label format "x(3)"
          auxcartao[3] no-label 
          "                 " no-label
          /*auxcfcar[3] no-label*/ skip 
          aux1cartao[4] no-label format "x(3)"
          auxcartao[4] no-label 
          "                 " no-label
          /*auxcfcar[4] no-label*/ skip 
          aux1cartao[5] no-label format "x(3)"
          auxcartao[5] no-label 
          "                 " no-label
          /*auxcfcar[5] no-label*/ skip 
          aux1cartao[6] no-label format "x(3)"
          auxcartao[6] no-label 
          "                 " no-label
         /* auxcfcar[6] no-label*/ skip 
          aux1cartao[7] no-label format "x(3)"
          auxcartao[7] no-label 
          "                 " no-label
          /*auxcfcar[7] no-label skip 
          aux1cartao[8] no-label format "x(3)"
          auxcartao[8] no-label 
          "                 " no-label
          auxcfcar[8] no-label skip 
          aux1cartao[9] no-label format "x(3)"
          auxcartao[9] no-label 
          "                 " no-label 
          auxcfcar[9] no-label*/ skip 
         with frame f-cartao  title "Cartao de Credito"
        . 
    choose field aux1cartao
          help "F1 para seguir..."
         with frame f-cartao.
    if keyfunction(lastkey) = "GO"
    then leave.
    vaux = int(substring(auxcartao[frame-index],1,2)). 
    if frame-index > 0
    then do: 
        if aux1cartao[vaux] = "( )"
        then aux1cartao[vaux] = "(X)".
        else aux1cartao[vaux] = "( )".
        disp aux1cartao[vaux] with frame f-cartao. pause 0.
    end.
    /*update auxcfcar[vaux] with frame f-cartao.*/
  end.
    vaux = 0.
    tcpclien.var-char2 = "".
    repeat vaux = 1 to 7:
        if aux1cartao[vaux] <> "( )"
        then tcpclien.var-int[vaux] = string(vaux).
        else tcpclien.var-int[vaux] = "0".
        /*tcpclien.var-char2 = tcpclien.var-char2 +
        "|" + string(vaux) + "=".
        if auxcfcar[vaux] = yes
        then tcpclien.var-char2 = tcpclien.var-char2 + "Sim".
        else tcpclien.var-char2 = tcpclien.var-char2 + "Nao".
        */
    end.  
      /*
    if tcpclien.var-int[9] = "9"
    then assign tcpclien.var-int = ""
            tcpclien.var-int[9] = "9" .
        */
    /*****************  REFERENCIAS BANCARIAS  **************************/
    
    disp  "Banco"  no-label colon 5
          "Tipo Conta" no-label colon 37
          "Ano Conta" no-label colon 50
          /*"Confirmado" colon 65  */
          /*"---"  */
          "-----"  no-label colon 5
          "----------" no-label colon 37
          "-----------" no-label colon 50
          /*"----------" colon 65 */           
          with frame f-banco overlay row 14
          title " REFERENCIAS BANCARIAS ". 

        if tcpclien.var-ext5[1] = "SIM"
            then log-refban[1] = yes.
                else log-refban[1] = no.
                    if tcpclien.var-ext5[2] = "SIM"
                        then log-refban[2] = yes.
                            else log-refban[2] = no.
                                if tcpclien.var-ext5[3] = "SIM"
                                    then log-refban[3] = yes.
                                        else log-refban[3] = no.
                                            if tcpclien.var-ext5[4] = "SIM"
                                                then log-refban[4] = yes.
                                                    else log-refban[4] = no.
                  
    assign
        aux-banco[1] = "BANRISUL"
        aux-banco[2] = "CAIXA ECONOMICA FEDERAL"
        aux-banco[3] = "BANCO DO BRASIL"
        aux-banco[4] = "OUTROS"
        .
        
    if tcpclien.var-ext2[1] = "BANRISUL" or
       tcpclien.var-ext2[2] = "BANRISUL" or
       tcpclien.var-ext2[3] = "BANRISUL" or
       tcpclien.var-ext2[4] = "BANRISUL"
    THEN marca-banco[1] = "X".
    if tcpclien.var-ext2[1] = "CAIXA ECONOMICA FEDERAL" or
       tcpclien.var-ext2[2] = "CAIXA ECONOMICA FEDERAL" or
       tcpclien.var-ext2[3] = "CAIXA ECONOMICA FEDERAL" or
       tcpclien.var-ext2[4] = "CAIXA ECONOMICA FEDERAL"
    THEN marca-banco[2] = "X".
    if tcpclien.var-ext2[1] = "BANCO DO BRASIL" or
       tcpclien.var-ext2[2] = "BANCO DO BRASIL" or
       tcpclien.var-ext2[3] = "BANCO DO BRASIL" or
       tcpclien.var-ext2[4] = "BANCO DO BRASIL"
    THEN marca-banco[3] = "X".
    if tcpclien.var-ext2[1] = "OUTROS" or
       tcpclien.var-ext2[2] = "OUTROS" or
       tcpclien.var-ext2[3] = "OUTROS" or
       tcpclien.var-ext2[4] = "OUTROS"
    THEN marca-banco[4] = "X".
    vaux = 1.
    repeat:    
        disp marca-banco[1]    no-label   at 1
         aux-banco[1]  no-label colon 5  format "x(25)"
         tcpclien.var-ext3[1]  no-label colon 40 format "x(1)"
         tcpclien.var-ext4[1]  no-label format "x(4)" colon 55
         /*log-refban[1] no-label   colon 70*/       
         marca-banco[2] no-label    at 1
         aux-banco[2] no-label colon 5  format "x(25)"
         tcpclien.var-ext3[2]  no-label colon 40 format "x(1)"
         tcpclien.var-ext4[2]  no-label colon 55 format "x(4)"   
         /*log-refban[2] no-label   colon 70*/
         marca-banco[3]    no-label  at 1
         aux-banco[3]      no-label colon 5  format "x(25)"
         tcpclien.var-ext3[3]  no-label colon 40 format "x(1)"
         tcpclien.var-ext4[3]  no-label colon 55 format "x(4)"   
         /*log-refban[3] no-label   colon 70*/
         marca-banco[4]   no-label    at 1
         aux-banco[4]    no-label colon 5  format "x(25)"
         tcpclien.var-ext3[4]  no-label colon 40 format "x(1)"
         tcpclien.var-ext4[4] no-label colon 55 format "x(4)"   
         /*log-refban[4] no-label   colon 70   */
         with frame f-banco 
         .

        choose field marca-banco
          help "F1 para seguir..."
         with frame f-banco.
        if keyfunction(lastkey) = "GO"
        then leave.
        vaux = frame-index. 
        if frame-index > 0
        then do: 
            if marca-banco[vaux] = ""
            then do:
                marca-banco[vaux] = "X".
                disp marca-banco with frame f-banco.
                status input "[1] Conta Simples, [2] Conta Especial".
                do on error undo, retry:
                    tcpclien.var-ext3[vaux] = "1".
                    update tcpclien.var-ext3[vaux]
                        with frame f-banco.
                    if  tcpclien.var-ext3[vaux] = "" or
                        tcpclien.var-ext3[vaux] > "2"
                    then undo, retry.
                end.
                status input  
                    "Digite os dados ou pressione [F4] para encerrar.". 
                do on error undo, retry:
                    update  tcpclien.var-ext4[vaux]
                        with frame f-banco.
                    if tcpclien.var-ext4[vaux] = "" or
                       tcpclien.var-ext4[vaux] > string(year(today),"9999") or
                       length(tcpclien.var-ext4[vaux]) < 4 or
                       tcpclien.var-ext4[vaux] < "1950"
                    then undo, retry.   
                end.    
                /*
                update  log-refban[vaux]
                        with frame f-banco.
            */
            end.            
            else do:
                assign
                    marca-banco[vaux] = ""
                    tcpclien.var-ext3[vaux] = ""
                    tcpclien.var-ext4[vaux] = ""
                    log-refban[vaux] = no .
            end.
            disp marca-banco[vaux] 
                 tcpclien.var-ext3[vaux]
                 tcpclien.var-ext4[vaux]
                 /*log-refban[vaux]*/
                 with frame f-banco. pause 0.
        end.
    end.  
    do vaux = 1 to 4:
        if marca-banco[vaux] = "X"
        then tcpclien.var-ext2[vaux] = aux-banco[vaux].
        else tcpclien.var-ext2[vaux] = "".
        /*if log-refban[vaux] = yes
        then tcpclien.var-ext5[vaux] = "SIM".
        else tcpclien.var-ext5[vaux] = "NAO".
        */
    end.
    hide frame f-banco no-pause.
    
    /*****************  FIM REFERENCIAS BANCARIAS ****************/

    /*****************  REFERENCIAS COMERCIAIS  ****************/
    
    if tcpclien.var-ext6[1] = "SIM"
            then log-refcom[1] = yes.
                    else log-refcom[1] = no.
                            if tcpclien.var-ext6[2] = "SIM"
                                    then log-refcom[2] = yes.
                                            else log-refcom[2] = no.
                                                    if tcpclien.var-ext6[3] = "SIM"
        then log-refcom[3] = yes.
                else log-refcom[3] = no.
                        if tcpclien.var-ext6[4] = "SIM"
                                then log-refcom[4] = yes.
                                        else log-refcom[4] = no.
                                                if tcpclien.var-ext6[5] = "SIM"
                                                        then log-refcom[5] = yes.
        else log-refcom[5] = no.
        
    if tclien.refcom[1] = ?
             then tclien.refcom[1] = "".
                  if tclien.refcom[2] = ?
                       then tclien.refcom[2] = "".
                            if tclien.refcom[3] = ?
                                 then tclien.refcom[3] = "".
                                      if tclien.refcom[4] = ?
                                           then tclien.refcom[4] = "".
                                                if tclien.refcom[5] = ?
                                                     then tclien.refcom[5] = "".
                                                     
    update tclien.refcom[1] label "Ref.Comercial" colon 16  format "x(30)"
           tcpclien.var-ext1[1] validate(input tclien.refcom[1] = "" OR
                                          (tcpclien.var-ext1[1] >= "1" and 
                                           tcpclien.var-ext1[1] <= "3"),"")
                   label "Cartao" colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Nao apresentado, [3] Nao possui cartao" 
       /*log-refcom[1] label "Confirmado" */
       tclien.refcom[2] no-label  colon 16  format "x(30)"
       tcpclien.var-ext1[2] validate(input tclien.refcom[2] = "" OR
                                          (tcpclien.var-ext1[2] >= "1" and 
                                           tcpclien.var-ext1[2] <= "3"),"")
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Nao apresentado, [3] Nao possui cartao" 
        /*log-refcom[2] label "          "    */
       tclien.refcom[3] no-label  colon 16  format "x(30)"
       tcpclien.var-ext1[3] validate(input tclien.refcom[3] = "" OR
                                          (tcpclien.var-ext1[3] >= "1" and 
                                           tcpclien.var-ext1[3] <= "3"),"")
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Nao apresentado, [3] Nao possui cartao"
        /*log-refcom[3] label "          "      */
       tclien.refcom[4] no-label  colon 16  format "x(30)"
       tcpclien.var-ext1[4] validate(input tclien.refcom[4] = "" OR
                                          (tcpclien.var-ext1[4] >= "1" and 
                                           tcpclien.var-ext1[4] <= "3"),"")
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Nao apresentado, [3] Nao possui cartao"
        /*log-refcom[4] label "          " */
       tclien.refcom[5] no-label  colon 16  format "x(30)"
       tcpclien.var-ext1[5] validate(input tclien.refcom[5] = "" OR
                                          (tcpclien.var-ext1[5] >= "1" and 
                                           tcpclien.var-ext1[5] <= "3"),"")
                   no-label colon 55 format "x(1)"   
         help "[1] Apresentado, [2] Nao apresentado, [3] Nao possui cartao" 
        /*log-refcom[5] label "          "*/
         /*ip(2)*/ with width 80 side-label
            frame f4 title " Referencias Comerciais " color white/cyan.
      /*     
      update tcpclien.var-log1 Label "Referencias Confirmadas" 
                format "Sim/Nao"
             with width 80 side-label
            frame f4 title " Referencias Comerciais " color white/cyan.
       */

        /*
    if log-refcom[1] = yes
            then tcpclien.var-ext6[1] = "SIM".
                    else tcpclien.var-ext6[1] = "NAO".
                            if log-refcom[2] = yes
                                    then tcpclien.var-ext6[2] = "SIM".
                                            else tcpclien.var-ext6[2] = "NAO".
                                                    if log-refcom[3] = yes
                                                            then tcpclien.var-ext6[3] = "SIM".
        else tcpclien.var-ext6[3] = "NAO".
                if log-refcom[4] = yes
                        then tcpclien.var-ext6[4] = "SIM".
                                else tcpclien.var-ext6[4] = "NAO".
                                        if log-refcom[5] = yes
                                                then tcpclien.var-ext6[5] = "SIM".
        else tcpclien.var-ext6[5] = "NAO".
          */
/*******************  FIM REFERENCIAS COMERCIAIS  ***********/  


def var vconfirmado as log format "Sim/Nao".
find carro where carro.clicod = tclien.clicod no-lock no-error.            
if avail carro and carro.carsit = yes
then vcarro = yes.
else vcarro = no.

update vcarro label "Possui Carro" 
       with frame fcarro side-label title "C A R R O" 1 column centered.
        
if vcarro = yes
then do:
    find carro where carro.clicod = tclien.clicod no-error.
    if not avail carro
    then do:
        create carro.
        assign carro.clicod = tclien.clicod
               carro.carsit = yes
               carro.datexp = today.
    end.

    update carro.marca  label "Marca"
           carro.modelo label "Modelo"
           with frame fcarro.
    repeat on error undo:
           update
           carro.ano    label "Ano Fabricacao" 
                with frame fcarro.
           if carro.ano < 1900 or
              carro.ano > year(today) + 1
           then do:
            bell.
            message "Ano de fabricacao nao aceito."
            . 
            undo.
           end.
           leave.
    end.
    /*
    if acha("CONFIRMADO",cpclien.var-char3) = "SIM"
    then vconfirmado = yes.
    else vconfirmado = no.
    update vconfirmado label "Confirmado?" with frame fcarro.
    */
    tcpclien.var-char3 = "MARCA=" + carro.marca + "|" + 
                "MODELO=" + carro.modelo + "|" +
                "ANO=" + string(carro.ano,"9999") + "|" +
                "CONFIRMADO=" + STRING(vconfirmado,"Sim/Nao") + "|" .
    if keyfunction(lastkey) = "end-error"
    then undo, retry.
end.
else do:
    find carro where carro.clicod = tclien.clicod no-error.
    if avail carro
    then assign carro.carsit = yes
                carro.datexp = today
                carro.modelo = ""
                carro.marca  = ""
                carro.ano    = 0.
end.                
        
update tclien.autoriza[1]   colon 5 no-label format "x(70)"
       tclien.autoriza[2]   colon 5 no-label format "x(70)"
       tclien.autoriza[3]   colon 5 no-label format "x(70)"
       tclien.autoriza[4]   colon 5 no-label format "x(70)"
       tclien.autoriza[5]   colon 5 no-label format "x(70)"
       with width 80 side-label frame f5 title " Observacoes ".

/********/

    i = 0.
    do i = 1 to 3.
        if tclien.entbairro[i] = ? then tclien.entbairro[i] = "".
        if tclien.entcep[i]    = ? then tclien.entcep[i]    = "".
        if tclien.entcidade[i] = ? then tclien.entcidade[i] = "".
        if tclien.entcompl[i]  = ? then tclien.entcompl[i]  = "".
    end.
        
    update skip(1)
        tclien.entbairro[1] label "1) Nome..........." format "x(50)" skip
        tclien.entcep[1]    label "1) Fone Comercial." format "x(50)" skip
        tclien.entcidade[1] label "1) Celular........" format "(xx) xxxxxxxxx"
        skip
        tclien.entcompl[1]  label "1) Parentesco....." format "x(50)" skip(1)
        tclien.entbairro[2] label "2) Nome..........." format "x(50)" skip
        tclien.entcep[2]    label "2) Fone Comercial." format "x(50)" skip
        tclien.entcidade[2] label "2) Celular........" format "(xx) xxxxxxxxx"
        skip
        tclien.entcompl[2]  label "2) Parentesco....." format "x(50)" skip(1)
        tclien.entbairro[3] label "3) Nome..........." format "x(50)" skip
        tclien.entcep[3]    label "3) Fone Comercial." format "x(50)" skip
        tclien.entcidade[3] label "3) Celular........" format "(xx) xxxxxxxxx"
        skip
        tclien.entcompl[3]  label "3) Parentesco....." format "x(50)" skip(1)
           with width 80 frame fpess2 side-labels
            title " Referencias Pessoais "  color white/cyan.

    i = 0.
    do i = 1 to 4.
        if tclien.entendereco[i] = ?
        then tclien.entendereco[i] = "".
    end.

    update tclien.entendereco[1] format "x(78)" skip
           tclien.entendereco[2] format "x(78)" skip
           tclien.entendereco[3] format "x(78)" skip
           tclien.entendereco[4] format "x(78)" skip
           with frame fpess3 no-labels width 80
                color white/cyan title " Documentos Apresentados ".

    i = 0.
    do i = 1 to 5.
        if tclien.entrefcom[i] = ?
        then tclien.entrefcom[i] = "".
    end.

    run registros-spc.
    
    /*
    ventrefcom = date(tclien.entrefcom[1]).
    
    update ventrefcom label "Data" format "99/99/9999" skip
           tclien.entrefcom[2] label " OBS" format "x(72)" skip space(6)
           tclien.entrefcom[3] no-label format "x(72)" skip space(6)
           tclien.entrefcom[4] no-label format "x(72)" skip space(6)
           tclien.entrefcom[5] no-label format "x(72)"
           with frame fpess4 side-labels width 80
                       color white/cyan title "  S P C  ".
    tclien.entrefcom[1] = string(ventrefcom,"99/99/9999").
    */
    
    find current tcpclien exclusive.
    update tcpclien.var-int3 label "Nota" format ">9"
        with frame fpess5 side-labels width 20 centered
    color white/cyan title "    NOTA    ".

    /*
    find current cpclien no-lock.   
    */
/********/

run atu1. /*atualiza a tabela clien*/

procedure atu1:

    find clien where recid(clien) = vrecid no-error.

    
    if clien.endereco[1]    <> tclien.endereco[1]   or
       clien.numero[1]      <> tclien.numero[1]     or
       clien.compl[1]       <> tclien.compl[1]      or
       clien.bairro[1]      <> tclien.bairro[1]     or
       clien.cidade[1]      <> tclien.cidade[1]     or   
       clien.ufecod[1]      <> tclien.ufecod[1]     or
       clien.cep[1]         <> tclien.cep[1]        or
       clien.fone           <> tclien.fone          or
       clien.prorenda[1]    <> tclien.prorenda[1]   or
       clien.proprof[1]     <> tclien.proprof[1]    or
       clien.proprof[2]     <> tclien.proprof[2]    or
       clien.prorenda[2]    <> tclien.prorenda[2]
    then clien.ultimaAtualizacaoCadastral = today.
        
    assign clien.nacion = tclien.nacion 
           clien.natur  = tclien.natur.
    
    assign clien.genero   = tclien.genero.
    
    assign clien.estciv = tclien.estciv.
    
    assign clien.nacion = tclien.nacion
           clien.natur  = tclien.natur
           clien.dtnasc = tclien.dtnasc
           clien.ciinsc = tclien.ciinsc
           clien.ciccgc = tclien.ciccgc
           clien.pai    = tclien.pai
           clien.mae    = tclien.mae
           clien.numdep = tclien.numdep
           clien.zona   = tclien.zona.

    assign clien.endereco[1] = tclien.endereco[1]
           clien.numero[1]   = tclien.numero[1]
           clien.compl[1]    = tclien.compl[1]
           clien.bairro[1]   = tclien.bairro[1]
           clien.cidade[1]   = tclien.cidade[1]
           clien.ufecod[1]   = tclien.ufecod[1]
           clien.cep[1]      = tclien.cep[1]
           clien.fone        = tclien.fone
           clien.fax         = tclien.fax
           clien.tipres      = tclien.tipres
           clien.temres      = tclien.temres.

    assign clien.proemp[1]   = tclien.proemp[1]
           clien.protel[1]   = tclien.protel[1]
           clien.prodta[1]   = tclien.prodta[1]
           clien.proprof[1]  = tclien.proprof[1]
           clien.prorenda[1] = tclien.prorenda[1]
           clien.endereco[2] = tclien.endereco[2]
           clien.numero[2]   = tclien.numero[2]
           clien.compl[2]    = tclien.compl[2]
           clien.bairro[2]   = tclien.bairro[2]
           clien.cidade[2]   = tclien.cidade[2]
           clien.ufecod[2]   = tclien.ufecod[2]
           clien.cep[2]      = tclien.cep[2].

    assign clien.conjuge     = tclien.conjuge
           clien.nascon      = tclien.nascon
           clien.conjpai     = tclien.conjpai
           clien.conjmae     = tclien.conjmae
           clien.proemp[2]   = tclien.proemp[2]
           clien.protel[2]   = tclien.protel[2]
           clien.prodta[2]   = tclien.prodta[2]
           clien.proprof[2]  = tclien.proprof[2]
           clien.prorenda[2] = tclien.prorenda[2]
           clien.endereco[3] = tclien.endereco[3]
           clien.numero[3]   = tclien.numero[3]
           clien.compl[3]    = tclien.compl[3]
           clien.bairro[3]   = tclien.bairro[3]
           clien.cidade[3]   = tclien.cidade[3]
           clien.ufecod[3]   = tclien.ufecod[3]
           clien.cep[3]      = tclien.cep[3].
                             
    assign clien.refcom[1] = tclien.refcom[1] 
           clien.refcom[2] = tclien.refcom[2] 
           clien.refcom[3] = tclien.refcom[3] 
           clien.refcom[4] = tclien.refcom[4] 
           clien.refcom[5] = tclien.refcom[5].

    assign clien.autoriza[1] = tclien.autoriza[1] 
           clien.autoriza[2] = tclien.autoriza[2] 
           clien.autoriza[3] = tclien.autoriza[3]
           clien.autoriza[4] = tclien.autoriza[4] 
           clien.autoriza[5] = tclien.autoriza[5].

    assign clien.refnome     = tclien.refnome 
           clien.endereco[4] = tclien.endereco[4] 
           clien.numero[4]   = tclien.numero[4] 
           clien.compl[4]    = tclien.compl[4]
           clien.bairro[4]   = tclien.bairro[4]
           clien.cidade[4]   = tclien.cidade[4]
           clien.ufecod[4]   = tclien.ufecod[4]
           clien.cep[4]      = tclien.cep[4]
           clien.reftel      = tclien.reftel.

    /*******/
    
    assign clien.entbairro[1]   = tclien.entbairro[1]
           clien.entbairro[2]   = tclien.entbairro[2]
           clien.entbairro[3]   = tclien.entbairro[3]
           clien.entbairro[4]   = tclien.entbairro[4]
                               
           clien.entcep[1]      = tclien.entcep[1]
           clien.entcep[2]      = tclien.entcep[2]
           clien.entcep[3]      = tclien.entcep[3]
           clien.entcep[4]      = tclien.entcep[4]
           
           clien.entcidade[1]   = tclien.entcidade[1]
           clien.entcidade[2]   = tclien.entcidade[2]
           clien.entcidade[3]   = tclien.entcidade[3]
           clien.entcidade[4]   = tclien.entcidade[4]
           
           clien.entcompl[1]    = tclien.entcompl[1]
           clien.entcompl[2]    = tclien.entcompl[2]
           clien.entcompl[3]    = tclien.entcompl[3]
           clien.entcompl[4]    = tclien.entcompl[4]
           
           clien.entendereco[1] = tclien.entendereco[1]
           clien.entendereco[2] = tclien.entendereco[2]
           clien.entendereco[3] = tclien.entendereco[3]
           clien.entendereco[4] = tclien.entendereco[4]
        
           clien.entrefcom[1]   = tclien.entrefcom[1]
           clien.entrefcom[2]   = tclien.entrefcom[2]
           clien.entrefcom[3]   = tclien.entrefcom[3]
           clien.entrefcom[4]   = tclien.entrefcom[4]
           clien.entrefcom[5]   = tclien.entrefcom[5].

           clien.empresa_inscricaoEstadual = tclien.empresa_inscricaoEstadual.                
           clien.patrimonio   = tclien.patrimonio.
           
    assign clien.datexp      = today.

    find clien where recid(clien) = vrecid no-lock no-error.
    
    find cpclien where cpclien.clicod = clien.clicod no-error.
    buffer-copy tcpclien to cpclien.
    cpclien.var-char9 = tcpclien.var-char9.
    cpclien.exportado = no.
    cpclien.datalt = today.
    cpclien.horalt = time.
    cpclien.datexp = today.
    
    find cpclien where cpclien.clicod = clien.clicod no-lock no-error.
     
end procedure.

procedure seguro:
    DEF VAR AUX-seguro AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-seguro AS CHAR EXTENT 5 FORMAT "(X)" .
    assign
        aux-seguro[1] = "Nao Possui"
        aux-seguro[2] = "De Saude"
        aux-seguro[3] = "De Vida"
        aux-seguro[4] = "Residencial"
        aux-seguro[5] = "Automovel" 
         .
    
    if tcpclien.var-log6 = yes
    then do:
        if acha("De Saude",var-char6) <> ?
        then marca-seguro[2] = "X".
        if acha("De Vida",var-char6) <> ?
        then marca-seguro[3] = "X".
        if acha("Residencial",var-char6) <> ?
        then marca-seguro[4] = "X".
        if acha("Automovel",var-char6) <> ?
        then marca-seguro[5] = "X".
    end.
    else marca-seguro[1] = "X".       

    vaux = 1.
    repeat:    
         disp skip(1)
         marca-seguro[1]    no-label   at 1
         aux-seguro[1]  no-label   at 5
         marca-seguro[2] no-label    at 1
         aux-seguro[2] no-label        at 5
         marca-seguro[3]    no-label  at 1
         aux-seguro[3]      no-label     at 5
         marca-seguro[4]   no-label    at 1
         aux-seguro[4]    no-label       at 5
         marca-seguro[5]   no-label    at 1
         aux-seguro[5]    no-label       at 5
          with frame f-seguro  title "  Seguros  "   
         ROW 10 COLUMN 55
         .
         pause 0.
         choose field aux-seguro 
            help "F1 para seguir..."
            go-on(F1,PF1)
            with frame f-seguro.
         if keyfunction(lastkey) = "GO"
         then leave.
         vaux = frame-index. 

         if marca-seguro[vaux] = ""
         then marca-seguro[vaux] = "X".
         else marca-seguro[vaux] = "".   

         if marca-seguro[1] = "X"
         then do vaux = 2 to 5 :
            marca-seguro[vaux] = "".
         end.
         disp marca-seguro with frame f-seguro.
         pause 0.
    end.  
    if marca-seguro[1] = "X"
    then assign
            tcpclien.var-log6 = no
            tcpclien.var-char6 = "".
    else do vaux = 1 to 5:
        if vaux = 1
        then assign
                 tcpclien.var-log6 = yes 
                 tcpclien.var-char6 = "".
        else if marca-seguro[vaux] = "X"
            then tcpclien.var-char6 = tcpclien.var-char6 +
                  aux-seguro[vaux] + "=|".
    end.

end procedure.

procedure plano-saude:
    DEF VAR AUX-psaude AS CHAR EXTENT 4 FORMAT "X(20)".
    DEF VAR MARCA-psaude AS CHAR EXTENT 4 FORMAT "(X)" .
    assign
        aux-psaude[1] = "Nao Possui"
        aux-psaude[2] = "IPE"
        aux-psaude[3] = "UNIMED"
        aux-psaude[4] = "Outros" .
    
    if tcpclien.var-log7 = yes
    then do:
        if acha("IPE",var-char7) <> ?
        then marca-psaude[2] = "X".
        if acha("UNIMED",var-char7) <> ?
        then marca-psaude[3] = "X".
        if acha("Outros",var-char7) <> ?
        then marca-psaude[4] = "X".
    end.
    else marca-psaude[1] = "X".       

    vaux = 1.
    repeat:    
         disp skip(1)
            marca-psaude[1]    no-label   at 1
         aux-psaude[1]  no-label   at 5
         marca-psaude[2] no-label    at 1
         aux-psaude[2] no-label        at 5
         marca-psaude[3]    no-label  at 1
         aux-psaude[3]      no-label     at 5
         marca-psaude[4]   no-label    at 1
         aux-psaude[4]    no-label       at 5
         with frame f-psaude  title "  Planos de saude  "   
         ROW 10   COLUMN 28
         .
         pause 0.
         choose field aux-psaude 
            help "F1 para seguir..."
            go-on(F1,PF1)
            with frame f-psaude.
         if keyfunction(lastkey) = "GO"
         then leave.
         vaux = frame-index. 

         if marca-psaude[vaux] = ""
         then marca-psaude[vaux] = "X".
         else marca-psaude[vaux] = "".   

         if marca-psaude[1] = "X"
         then do vaux = 2 to 4 :
            marca-psaude[vaux] = "".
         end.
         disp marca-psaude with frame f-psaude.
         pause 0.
    end.  
    if marca-psaude[1] = "X"
    then assign
            tcpclien.var-log7 = no
            tcpclien.var-char7 = "".
    else do vaux = 1 to 4:
        if vaux = 1
        then assign
                 tcpclien.var-log7 = yes 
                 tcpclien.var-char7 = "".
        else if marca-psaude[vaux] = "X"
            then tcpclien.var-char7 = tcpclien.var-char7 +
                  aux-psaude[vaux] + "=|".
    end.

end procedure.

procedure grau-instrucao:
    DEF VAR AUX-instrucao AS CHAR EXTENT 5 FORMAT "X(20)".
    DEF VAR MARCA-instrucao AS CHAR EXTENT 5 FORMAT "(X)".
    def var v1 as int.
    def var vcompleto as log format "Sim/Nao".
    def var vincompleto as log format "Sim/Nao".
    assign
        aux-instrucao[1] = "Fundamental"
        aux-instrucao[2] = "Primeiro grau"
        aux-instrucao[3] = "Segundo grau"
        aux-instrucao[4] = "Curso superior"
        aux-instrucao[5] = "Pos/Mestrado"    
        .
    if tcpclien.var-log8 = yes
    then assign
             vcompleto = yes
             vincompleto = no.
    else assign
             vcompleto = no
             vincompleto = yes.   
    
    do vaux = 1 to 5:
        if aux-instrucao[vaux] = acha("INSTRUCAO",tcpclien.var-char8)
        then marca-instrucao[vaux] = "X".
    end.

    vaux = 1.
    repeat:    
         disp  skip(1)
         marca-instrucao[1]    no-label   at 1
         aux-instrucao[1]  no-label   at 5
         marca-instrucao[2] no-label    at 1
         aux-instrucao[2] no-label        at 5
         marca-instrucao[3]    no-label  at 1
         aux-instrucao[3]      no-label     at 5
         marca-instrucao[4]   no-label    at 1
         aux-instrucao[4]    no-label       at 5
         marca-instrucao[5]   no-label    at 1
         aux-instrucao[5]    no-label       at 5
         skip(1)
         "Completo?:" at 1 no-label vcompleto no-label 
         /*"   Incompleto:" no-label vincompleto no-label */
         with frame f-instrucao  title "  Grau de Instrucao  "   
         row 10 
         .
         pause 0.
         choose field aux-instrucao 
            help "F1 para seguir..."
            go-on(F1,PF1)
            with frame f-instrucao.
         if keyfunction(lastkey) = "GO"
         then leave.
         vaux = frame-index. 

         if marca-instrucao[vaux] = ""
         then marca-instrucao[vaux] = "X".
         else marca-instrucao[vaux] = "".   

         do v1 = 1 to 5:
            if v1 <> vaux
            then marca-instrucao[v1] = "".
         end.

         disp marca-instrucao with frame f-instrucao.
         pause 0.
         update vcompleto with frame f-instrucao.
         if vcompleto = yes
         then vincompleto = no.
         /*
         disp vincompleto with frame f-instrucao.
         update vincompleto when vcompleto = no
                     with frame f-instrucao.
          */
    end.  
    if vcompleto = yes
    then tcpclien.var-log8 = yes.
    else tcpclien.var-log8 = no.
    tcpclien.var-char8 = "".
    do vaux = 1 to 5:
        if marca-instrucao[vaux] = "X"
        then tcpclien.var-char8 = "INSTRUCAO=" +
                  aux-instrucao[vaux] + "|".
    end.

end procedure.

Procedure Pi-cic-number.                                                    
                                                                            
def input-output  parameter p-ciccgc  like clien.ciccgc.                    
def var v-ciccgc like clien.ciccgc.                                         
def var jj          as int.                                                 
def var ii          as int.                                                 
def var v-carac     as char format "x(1)".                                  
                                                                            
                                                                            assign v-ciccgc = "".                                                       
do ii = 1 to length(p-ciccgc):                                              
   assign v-carac = string(substr(p-ciccgc,ii,1)).                          
      do jj = 1 to 10:                                                         
        if string(jj - 1) = v-carac then assign v-ciccgc = v-ciccgc + v-carac.
      end.                                                                     
end.                                                                        
assign p-ciccgc = v-ciccgc.                                                 
end procedure.                                                              

procedure registros-spc:

    def var vmen-spc as char. 
    def var vdat-spc as date label "Data   consulta".
    def var vcpf-spc as char label "CPF    consulta".
    def var vnom-spc as char label "NOME   consulta".
    def var vreg-spc as log  label "CPF   Restricao" format "Sim/Nao".
    def var vcre-spc as char label "Reg. de credito".
    def var vche-spc as char label "Reg. de cheque ".
    def var vnac-spc as char label "Reg. nacional  ".
    def var vale-spc as char label "Reg. de alertas".
    def var vfil-spc as char label "Filial consulta".
    def var vcon-spc as char label "Quant. consulta".

    vdat-spc = date(tclien.entrefcom[1])     .
    vcpf-spc = acha("CPF",tclien.entrefcom[2]).
    vnom-spc = clien.clinom.
    
    if acha("ConsultaCpfConjuge",tclien.entrefcom[2]) <> ?  and
       date(acha("ConsultaCpfConjuge",tclien.entrefcom[2])) > vdat-spc
    then vdat-spc = date(acha("ConsultaCpfConjuge",tclien.entrefcom[2])).
    
    if acha("OK",tclien.entrefcom[2]) <> ?  and
       acha("OK",tclien.entrefcom[2]) = "NAO"
    then vreg-spc = yes.
    else vreg-spc = no.   
    
    assign
        vcre-spc = acha("credito",tclien.entrefcom[2])
        vche-spc = acha("cheques",tclien.entrefcom[2])
        vnac-spc = acha("nacional",tclien.entrefcom[2])
        vale-spc = acha("alertas",tclien.entrefcom[2])
        vfil-spc = acha("filial",tclien.entrefcom[2])
        vcon-spc = acha("consultas",tclien.entrefcom[2])
        .

    if vreg-spc
    then vmen-spc = "CLIENTE COM REGISTRO ".
    ELSE vmen-spc = "CLIENTE SEM REGISTRO ".

    disp vmen-spc format "x(50)"  no-label
       with frame fpess4 side-labels width 80
            color white/cyan title "  S P C  "
             down.

    disp   skip(1) 
        vcpf-spc  at 1         format "x(15)"
        vnom-spc  at 1         format "x(20)"
        vfil-spc  at 1  
        vdat-spc  at 1         format "99/99/9999"
        vcon-spc  at 1         
        vale-spc  at 1         when vreg-spc
        vcre-spc  at 40         when vreg-spc
        vche-spc  at 1         when vreg-spc                      
        vnac-spc  at 40         when vreg-spc
        with frame fpess4.
end procedure.
 
