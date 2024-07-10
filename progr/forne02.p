{admcab.i}
/***
sfuncod = 101.

find func where 
func.etbcod = setbcod and
func.funcod = sfuncod no-lock.
****/
def var videstrangeiro as char format "x(20)".
def var email-nfe as char format "x(50)".
def var vcgc as char format "x(20)".
def var vforcodpai like forne.forcod.
def var vv as int.
def var cgc-admcom as char format "x(18)".

def var vpermissao-alteracao     as logical.

def var aux-aux-int      like munic.aux-int1.
def var vok as log.
def var reccont         as int.
def var vinicio         as log.
def var recatu1         as recid.
def var recatu2         as recid.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqcom1         as char format "x(12)" extent 6
 initial ["Inclusao","Alteracao","Exclusao","Consulta","Procura","Listagem"].
def var esqcom2         as char format "x(12)" extent 5
            initial ["","","","",""].

def buffer bforne       for forne.
def var vforcod         like forne.forcod.


    form
        esqcom1
            with frame f-com1
                 row 3 no-box no-labels side-labels column 1.
    form
        esqcom2
            with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1.
    esqregua  = yes.
    esqpos1  = 1.
    esqpos2  = 1.

    if func.funfunc = "CONTABILIDADE"
    then assign esqcom2[1] = "DATA NFE".

procedure le-cpforne:
   def INPUT parameter plock as log.
   def input parameter pforcod like forne.forcod.

   if plock = yes
   then find cpforne where cpforne.forcod = pforcod exclusive-lock no-error.
   else if plock = no
        then find cpforne where cpforne.forcod = pforcod no-lock no-error.
        else find cpforne where cpforne.forcod = pforcod no-error.
   if not avail cpforne and
      pforcod > 0 
    then do:
         create cpforne.
         assign cpforne.forcod = pforcod
                cpforne.funcod = sfuncod.
    end.
   
end procedure.   

form with frame f-inclui.

def var vfortipo like forne.fortipo.


def var nfe-desde as date format "99/99/9999" label "NFE Desde".
def var cod-suframa as char format "x(20)" label "Cod. SUFRAMA".

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        find first forne where forne.fortipo = "PE"
             no-error.
    else
        find forne where recid(forne) = recatu1.
        vinicio = yes.
    if not available forne
    then do:
        message "Cadastro de Fornecedores Vazio".
        message "Deseja Incluir " update sresp.
        if not sresp
        then undo.
        do with frame f-inclui  row 4  centered .
                create forne.
                update fornom.
                assign forfant = substr(fornom,1,13).
                UPDATE forfant.
                UPDATE forrua validate(forrua <> "","Endereco obrigatorio")
                       fornum
                       forcomp
                       forbairro.
                do on error undo, retry:          
                   update formunic
                          ufecod
                          forpais 
                          validate(can-find(first pais where
                          pais.paisnom = forne.forpais),"Cadastrar PAIS.")
                          .
                          
                   find first munic where munic.cidnom = forne.formunic
                                      and munic.ufecod = forne.ufecod
                                no-lock no-error.
                   if not avail munic 
                   then do:
                        message "Municio ou UF inexistente." 
                                "Informar corretamente"
                             view-as alert-box .
                        undo, retry.
                   end.             
                   assign aux-aux-int = munic.aux-int1.
                end.
                fortipo = "PE".        
                UPDATE fortipo format "x(2)"
                  help "[P]-Produtos [S]-Servicos [A]-Ambos [PE]-Estrangeiro" 
                       forfone
                       forfax
                       forcont with frame f-forne no-validate.
                if fortipo <> "PE"
                then do:
                do on error undo:
                    update forcgc label "CNPJ/CPF" with frame f-forne.
                    sresp = no.
                    run cgc.p(forcgc, output sresp).
                    if not sresp 
                    then do:
                        if length(forcgc) = 11
                        then  run cpf.p (forcgc, output sresp) .
                        if not sresp
                        then do:
                            bell.
                            message color red/with
                            "CNPJ/CPF invalido"
                            view-as alert-box.
                            undo.
                        end.    
                    end.
                end.
                update
                       forinest 
                       forne.foriesub label "IE Subst.Trib."  
                       fordtcad
                       forctfon
                       forcep  validate(forcep <> "", "Informar o CEP")
                       WITH frame f-forne OVERLAY 2 COLUMNS SIDE-LABELS.
                end.
                find last bforne use-index iforne
                        exclusive-lock no-error.
                if available bforne
                then assign vforcod = bforne.forcod + 1.
                else assign vforcod = 1.
                assign forne.forcod = vforcod.
                update forne.forcod with no-validate.
                find last bforne use-index livro
                        exclusive-lock no-error.
                if available bforne
                then do:
                    forne.livcod = bforne.livcod + 1.
                end.
                else assign forne.livcod = 1.
                
                run le-cpforne(yes, forne.forcod).
                assign cpforne.int-1 = aux-aux-int.
                
                update cpforne.edi
                       cpforne.char-1 label "SUFRAMA" 
                       with frame f-forne.
                       
         /***       do on error undo:
                   update cpforne.int-1 label "COD.CIDADE" format ">>>>>>>"
                                with frame f-forne.
                   if cpforne.int-1 > 0
                   then do:
                        find munic where munic.aux-int1 = cpforne.int-1
                                       no-lock no-error.
                        if not avail munic 
                        then do:
                             message "Codigo da munic invalido".
                             undo, retry.
                        end.
                        disp munic.cidnom no-label with frame f-forne.
                   end.
                end.
                ****/
                find fabri where fabri.fabcod = forne.forcod no-error.
                if not avail fabri
                then create fabri.
                assign fabri.fabcod = forne.forcod
                       fabri.fabnom = forne.fornom
                       fabri.fabfant = forne.fornom.

        vinicio = no.
        end.
    end.
    clear frame frame-a all no-pause.
    display
        forne.forcod
        forne.fornom
        forne.forfant
        forne.ativo 
            with frame frame-a 13 down centered.

    recatu1 = recid(forne).
    color display message
        esqcom1[esqpos1]
            with frame f-com1.
    repeat:
        find next forne where forne.fortipo = "PE".
        if not available forne
        then leave.
        run le-cpforne(?, forne.forcod).
        
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if vinicio
        then
        down
            with frame frame-a.
        display
            forne.forcod
            forne.fornom
            forne.forfant
            forne.ativo 
                with frame frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find forne where recid(forne) = recatu1.
        
        run le-cpforne(?, forne.forcod).

        choose field forne.forcod
            go-on(cursor-down cursor-up
                  cursor-left cursor-right
                  page-down page-up
                  tab PF4 F4 ESC return).
        if keyfunction(lastkey) = "TAB"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                color display message
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                color display message
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            esqregua = not esqregua.
        end.
        if keyfunction(lastkey) = "cursor-right"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 6
                          then 6
                          else esqpos1 + 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 5
                          then 5
                          else esqpos2 + 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.

        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next forne where true no-error.
                if not avail forne
                then leave.
                recatu1 = recid(forne).
                run le-cpforne(?, forne.forcod).

            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev forne where true no-error.
                if not avail forne
                then leave.
                recatu1 = recid(forne).
                run le-cpforne(?, forne.forcod).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "cursor-left"
        then do:
            if esqregua
            then do:
                color display normal
                    esqcom1[esqpos1]
                    with frame f-com1.
                esqpos1 = if esqpos1 = 1
                          then 1
                          else esqpos1 - 1.
                color display messages
                    esqcom1[esqpos1]
                    with frame f-com1.
            end.
            else do:
                color display normal
                    esqcom2[esqpos2]
                    with frame f-com2.
                esqpos2 = if esqpos2 = 1
                          then 1
                          else esqpos2 - 1.
                color display messages
                    esqcom2[esqpos2]
                    with frame f-com2.
            end.
            next.
        end.
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next forne where  forne.fortipo = "PE"
                 no-error.
            if not avail forne
            then next.
            run le-cpforne(?, forne.forcod).
            color display normal
                forne.forcod.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev forne where
                true no-error.
            if not avail forne
            then next.
    
            run le-cpforne(?, forne.forcod).

            color display normal
                forne.forcod.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
        hide frame frame-a no-pause.

          if esqregua
          then do:
            display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                with frame f-com1.

            if esqcom1[esqpos1] = "Inclusao"
            then do with frame f-inclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                        
                /* Liberar a inclusao        
                sresp = yes.
                run permissao.
                
                if not sresp
                then next bl-princ.
                */
                
                vcgc = "". 
                vfortipo = "PE".
                UPDATE vfortipo format "x(2)"
                help "[P]-Produtos [S]-Servicos [A]-Ambos [PE]-Estrangeiro"
                .
                
                if vfortipo <> "PE"
                then do:
                update 
                        vcgc label "CNPJ/CPF".
                
                 
                vok = no.
                        
                cgc-admcom = vcgc.   
                vv = 0. 
                do vv = 1 to 18:   
                    if substring(cgc-admcom,vv,1) = "-" or
                       substring(cgc-admcom,vv,1) = "." or                    
                       substring(cgc-admcom,vv,1) = "~\" or
                       substring(cgc-admcom,vv,1) = "/"
                    then substring(cgc-admcom,vv,1) = "".
                end.  
                run cgc.p (input cgc-admcom,
                           output vok).
                if cgc-admcom = "" or vok = no
                then do:
                    if length(cgc-admcom) = 11
                    then run cpf.p (cgc-admcom, output sresp).
                    if not sresp
                    then do:
                        message color red/with
                        "CNPJ/CPF Invalido" view-as alert-box. 
                        undo, retry.
                    end.
                end.
                    
                find first bforne where bforne.forcgc = vcgc no-lock no-error.
                if avail bforne 
                then do: 
                    message "Fornecedor ja cadastrado com este CGC".
                    pause. 
                    undo ,retry.
                end.
                end.
                       
                create forne.
                update forne.fornom.
                assign forne.forfant = substr(forne.fornom,1,13).
                UPDATE forne.forfant.

               do on error undo, retry:
                  UPDATE 
                       forne.forrua      format "x(40)"
                       forne.fornum
                       forne.forcomp     format "x(15)"
                       forne.forbairro
                       forne.formunic
                       forne.ufecod      format "x(10)"
                       forne.forpais
                       validate(can-find(first pais where
                          pais.paisnom = forne.forpais),"Cadastrar PAIS.")
                       .
                       
                  find first munic where munic.cidnom = forne.formunic
                                and munic.ufecod = forne.ufecod
                                no-lock no-error.
                  if not avail munic 
                  then do:
                       message "Municio ou UF inexistente." skip 
                              "Informar municipio e UF corretamente"
                            view-as alert-box .
                       undo, retry.
                  end.             
                  assign aux-aux-int = munic.aux-int1.
                   
                  if length(forne.forrua) < 2 or
                     length(forne.formunic) < 2
                  then do:
                       message "Endereco obrigatorio".
                       undo, retry.
                  end.
                       
                end.       
                FORNE.FORTIPO = vfortipo.

                UPDATE /*forne.fortipo*/
                       forne.forfone
                       forne.forfax
                       forne.forcont.
                if forne.fortipo <> "PE"
                then do:       
                do on error undo, retry:
                    update forne.forinest.
                    sresp = no.
                    /*if length(forne.forcgc) > 11
                    then*/
                    run val-ie.p(forne.ufecod, forne.forinest, output sresp).
                    /*else if length(forne.forcgc) = 11
                    then sresp = yes.*/
                    if forne.ufecod = "BA" and sresp = no
                    then sresp = yes.
                    if sresp = no OR forne.forinest = ""
                    then do:
                        bell.
                        message color red/with
                        "Inscricao Estadual invalida" view-as alert-box.
                        undo, retry.
                    end.
                end.    
                end.
                update
                       forne.foriesub label "IE Subst.Trib." 
                       forne.fordtcad
                       forne.forctfon
                       forne.forcep.
                find last bforne exclusive-lock no-error.
                if available bforne
                then assign vforcod = bforne.forcod + 1.
                else assign vforcod = 1.
                assign forne.forcod = vforcod.
                vforcodpai = 0.
                update forne.forcod 
                       vforcodpai label "Codigo Pai" with no-validate.
                
                forne.forpai = vforcodpai. 
                forne.forcgc = vcgc.
                
                find last bforne use-index livro
                        exclusive-lock no-error.
                if available bforne
                then do:
                    forne.livcod = bforne.livcod + 1.
                end.
                else assign forne.livcod = 1.

               
                if forne.forpai = 0
                then do:
                
                     find fabri where fabri.fabcod = forne.forcod no-error.
                     if not avail fabri
                     then create fabri.
                     assign fabri.fabcod = forne.forcod
                            fabri.fabnom = forne.fornom
                            fabri.fabfant = forne.fornom.
                     update fabri.repcod label "Repres".
                
                    find repre where repre.repcod = fabri.repcod 
                            no-lock no-error.
                    if avail repre
                    then display repre.repnom no-label format "x(20)".
                
                    forne.repcod = fabri.repcod.
                
                end.
                run criarepexporta.p ("FORNE",
                                      "INCLUSAO",
                                      recid(forne)).

                do on error undo :
                    update forne.email. 
                
                    run le-cpforne(yes, forne.forcod).
                    cpforne.int-1 = 0 /*aux-aux-int*/.
                
                    update cpforne.edi.

                    do on error undo:
                        update cpforne.int-1 label "COD.CIDADE" 
                                    format ">>>>>>>".
                        if cpforne.int-1 > 0
                        then do:
                            /*
                            find munic where munic.aux-int1 = cpforne.int-1
                                       no-lock no-error.
                            if not avail munic 
                            then do:
                                 message "Codigo da cidade invalido".
                                 undo, retry.
                            end. */
                            /*disp munic.cidnom. 
                            */
                        end.
                    end.
                    
                    assign cpforne.date-1 = string(today).
                    
                    update  cpforne.date-1 format "99/99/9999" 
                                label "NFE Desde"
                            HELP "Nota Fiscal Eletronica desde que data."
                            .
                    if forne.ufecod = "AM"
                    then
                    update  cpforne.char-1 format "x(20)"
                                label "Cod. SUFRAMA"
                            help "Codigo do SUFRAMA".
                end.
                /*
                find tabaux where 
                     tabaux.tabela = "FORNE-" + string(forne.forcod) and
                     tabaux.nome_campo = "EMAILNFE" no-lock no-error.
                if avail tabaux
                then email-nfe = tabaux.valor_campo.
                */
                update cpforne.char-2 label "Email-NFe"
                            format "x(50)".

                recatu1 = recid(forne).
                leave.
            end.
            if esqcom1[esqpos1] = "Alteracao"
            then do with frame f-altera
                        row 4 centered OVERLAY 2 COLUMNS SIDE-LABELS.
                
                sresp = yes.
                run permissao.

                assign vpermissao-alteracao = sresp.

                if vpermissao-alteracao
                then update forne.fornom.
                else display forne.fornom.
                
                /* assign forne.forfant = substr(forne.fornom,1,13). */
                UPDATE forne.forfant.
                UPDATE forne.forrua format "x(59)"
                                        validate(forrua <> "",
                                        "Endereco obrigatorio")
                       forne.fornum
                       forne.forcomp
                       forne.forbairro.
                       
               do on error undo, retry:        
                  update
                       forne.formunic
                       forne.ufecod format "x(10)".
                  
                  find first munic where munic.cidnom = forne.formunic
                                  and munic.ufecod = forne.ufecod
                                no-lock no-error.
                  if not avail munic 
                  then do:
                       message "Municio ou UF inexistente." 
                              "Informar corretamente"
                            view-as alert-box .
                       undo, retry.
                  end. 
                              
                  assign aux-aux-int = munic.aux-int1.
                  
                end.

                UPDATE forne.forpais
                       validate(can-find(first pais where
                          pais.paisnom = forne.forpais),"Cadastrar PAIS.") 
                       forne.fortipo format "x(2)"
                       forne.forfone
                       forne.forfax
                       forne.forcont with no-validate.
                
                if forne.fortipo = "PE"
                then do:
                    find first forneaux where
                               forneaux.forcod     = forne.forcod and
                               forneaux.nome_campo = "IdEstangeiro"
                                no-error.
                    if not avail forneaux
                    then do:
                        create forneaux.
                        assign
                        forneaux.forcod     = forne.forcod
                        forneaux.nome_campo = "IdEstangeiro"
                        .
                    end.
                    videstrangeiro = forneaux.valor_campo.
                    update videstrangeiro label "IDEstrangeiro".
                    if forneaux.valor_campo <> videstrangeiro
                    then forneaux.valor_campo = videstrangeiro. 
                end.
                else do:
                    vcgc = forne.forcgc.
                    if vpermissao-alteracao or
                        forne.forcgc = ?
                    then
                do on error undo, retry:
                    vok = no.
                    vcgc = forne.forcgc.
                    update vcgc label "CNPJ/CPF"    
                    cgc-admcom = vcgc.  
                    vv = 0.
                    do vv = 1 to 18:  
                        if substring(cgc-admcom,vv,1) = "-" or
                           substring(cgc-admcom,vv,1) = "." or
                           substring(cgc-admcom,vv,1) = "~\" or
                           substring(cgc-admcom,vv,1) = "/"
                        then substring(cgc-admcom,vv,1) = "".
                    end. 
                    run cgc.p (input cgc-admcom,
                               output vok).
                    
                    if cgc-admcom = "" or vok = no
                    then do:
                        if length(cgc-admcom) = 11
                        then run cpf.p (cgc-admcom, output sresp).
                        if not sresp
                        then do:
                            message color red/with
                            "CNPJ/CPF Invalido" view-as alert-box.
                            undo, retry.
                        end.
                    end. 
                    forne.forcgc = vcgc.
                end.
                if forne.fortipo <> "PE"
                then display vcgc.

                if vpermissao-alteracao or
                   forne.forinest = ?
                then 
                do on error undo, retry:
                    update forne.forinest.
                    sresp = no.
                    /*if length(forne.forcgc) > 11
                    then*/ 
                    run val-ie.p(forne.ufecod, forne.forinest, output sresp).
                    /*else if length(forne.forcgc) = 11
                    then sresp = yes.  */
                    if forne.ufecod = "BA" and sresp = no
                    then sresp = yes.
                    if sresp = no
                    then do:
                        bell.
                        message color red/with
                        "Inscricao Estadual invalida" view-as alert-box.
                        undo, retry.
                    end.
                end. 
                else display forne.forinest.
                end.
                
                update 
                       forne.foriesub label "IE Subst.Trib."  
                       forne.fordtcad
                       forne.forctfon
                       forne.forcep
                       forne.repcod label "Repres.".
  
               
                find repre where repre.repcod = forne.repcod no-lock no-error.
                if avail repre
                then display repre.repnom.
  
                vforcodpai = forne.forpai. 
                
                update forne.email.
                
                update forne.ativo
                       vforcodpai label "Codigo Pai".
                run le-cpforne(yes, forne.forcod).
                
                cpforne.int-1 = 0 /*aux-aux-int*/.
                
                update cpforne.edi.

                forne.forpai = vforcodpai.
                if forne.forpai = 0
                then do:
                
                    find fabri where fabri.fabcod = forne.forcod no-error.
                    if avail fabri
                    then assign fabri.fabnom = forne.fornom
                                fabri.fabfant = forne.fornom
                                fabri.repcod  = forne.repcod.
                end.
                run criarepexporta.p ("FORNE",
                                      "ALTERACAO",
                                      recid(forne)).                
                do on error undo :
                
                    run le-cpforne(yes, forne.forcod).
                    cpforne.int-1 = 0 /*aux-aux-int*/.
                
                    do on error undo:
                        update cpforne.int-1 label "COD.CIDADE"
                        format ">>>>>>>".
                        if cpforne.int-1 > 0
                        then do:
                            /*
                            find munic where munic.aux-int1 = cpforne.int-1
                                       no-lock no-error.
                            if not avail munic 
                            then do:
                                 message "Codigo da cidade invalido".
                                 undo, retry.
                            end. */
                            /*
                            disp munic.cidnom . 
                            */
                        end.
                    end.
                    update  cpforne.date-1 label "NFE Desde"
                            HELP "Nota Fiscal Eletronica desde que data."
                            .
                    if forne.ufecod = "AM"
                    then 
                    update cpforne.char-1 label "Cod. SUFRAMA"
                            .
                end.
                update cpforne.char-2 label "Email-NFe"
                            format "x(50)".
            end.
            if esqcom1[esqpos1] = "Consulta"
            then do with frame f-consulta
                        row 4 centered /* OVERLAY */ 2 COLUMNS 40 down
                                    SIDE-LABELS. 
                disp forne
                        with frame f-consulta no-validate.
                
                disp
                     cpforne.funcod 
                     cpforne.edi
                     cpforne.char-1 label "Cod SUFRAMA"
                     cpforne.date-1 label "NFE Desde"
                     cpforne.char-2 label "Email-NFe"
                            format "x(50)"
                     with frame f-consulta1
                     row 8 centered OVERLAY 2 COLUMNS width 75 
                                    SIDE-LABELS.                
                       
                pause.

            end.
            if esqcom1[esqpos1] = "*Exclusao"
            then do with frame f-exclui
                        row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.
                sresp = yes.
                run permissao.
                if not sresp
                then next bl-princ.
                
                message "Confirma Exclusao de" forne.fornom update sresp.
                if not sresp
                then leave.
                find next forne where forne.fortipo = "PE" no-error.
                if not available forne
                then do:
                    find forne where recid(forne) = recatu1.
                    find prev forne where true no-error.
                end.
                recatu2 = if available forne
                          then recid(forne)
                          else ?.
                find forne where recid(forne) = recatu1.

                run le-cpforne(yes, forne.forcod).
                
                delete cpforne.
                
                delete forne.
                recatu1 = recatu2.
                leave.
            end.
            if esqcom1[esqpos1] = "Procura"
            then do with frame f-Lista overlay row 6 1 column centered.
                update vforcod with frame f-for centered row 15 overlay.
                find forne where forne.forcod = vforcod no-lock.
                recatu1 = recid(forne).
                run le-cpforne(no, forne.forcod).
                leave.
            end.
            if esqcom1[esqpos1] = "Listagem"
            then do:
                output to printer page-size 0.
                /*    
                for each bforne no-lock by bforne.fornom:
                    display bforne.forcod
                            bforne.fornom space(3)
                            bforne.forfant space(3)
                            bforne.forcgc space(3)
                            bforne.forinest space(3)
                            bforne.ufecod
                                with frame f-list width 200 down.
                end.
                */
                disp forne with frame f-print 2 COLUMNS SIDE-LABELS.
                run le-cpforne(no, forne.forcod).
                disp cpforne.edi with frame f-print.

                output close.
                leave.
            end.

          end.
          else do:
            display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                with frame f-com2.
                
            /*     
            message esqregua esqpos2 esqcom2[esqpos2].
            pause.
            */
            
            if esqcom2[esqpos2] = "DATA NFE"
            then do with frame f-data-nfe:
            
                run le-cpforne(yes, forne.forcod).
            
                update cpforne.date-1
                             label "ALTERA DATA NFE" with no-validate
                                    overlay centered.
            
            end.
            
          end.
          view frame frame-a .
        end.
         if keyfunction(lastkey) = "end-error"
         then view frame frame-a.
        display
                forne.forcod
                forne.fornom
                forne.forfant
                forne.ativo 
                    with frame frame-a.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(forne).
   end.
end.
      
procedure permissao:
    sresp = yes.  
    find first func where func.etbcod = setbcod
                          and func.funcod = sfuncod no-lock no-error.
                    
        if  func.funfunc <> "CONTABILIDADE" /*or sfuncod = 101*/      
        then do:
            
            /****  Apenas bloqueia alguns campos como razao social, CNPJ, IE
            
            message color red/with
                    SKIP(1)
                    "USUÁRIO SEM PERMISSÃO PARA REALIZAR ESTA OPERAÇÃO" SKIP
                    "ENTRE EM CONTATO COM O SETOR FISCAL/CONTÁBIL"  
                    SKIP(1)    
                    VIEW-AS ALERT-BOX.

            ******/
            sresp = no.
        end.

end procedure.      
