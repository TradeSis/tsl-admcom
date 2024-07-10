/*
*
*    forne.p    -    Esqueleto de Programacao    com esqvazio
*
*/
{admcab.i}

def var vcgc as char format "x(20)".
def var vforcodpai like forne.forcod.
def var vv as int.
def var cgc-admcom as char format "x(18)".
def var vok as log.
def var vpermissao-alteracao     as logical.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
          initial[" Inclusao"," Alteracao",""," Consulta", "Procura"].
def var esqcom2         as char format "x(12)" extent 5.
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5.

def buffer bforne       for forne.
def var vforcod         like forne.forcod.

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

procedure le-cpforne:
   def INPUT parameter plock as log.
   def input parameter pforcod like forne.forcod.

do on error undo.
    if plock = yes
    then find cpforne where cpforne.forcod = pforcod exclusive-lock no-error.
    else find cpforne where cpforne.forcod = pforcod no-lock no-error.
    if not avail cpforne and
       pforcod > 0 
    then do:
         create cpforne.
         assign cpforne.forcod = pforcod
                cpforne.funcod = sfuncod.
    end.
end.

end procedure.   


if func.funfunc = "CONTABILIDADE"
then assign esqcom2[1] = "DATA NFE".

bl-princ:
repeat:
    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find forne where recid(forne) = recatu1 no-lock.
    if not available forne
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(forne).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available forne
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down
            with frame frame-a.
        run frame-a.
    end.
    if not esqvazio
    then up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        if not esqvazio
        then do:
            find forne where recid(forne) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(forne.fornom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(forne.fornom)
                                        else "".
            run color-message.
            choose field forne.forcod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .
            run color-normal.
            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                    color display message esqcom2[esqpos2] with frame f-com2.
                end.
                else do:
                    color display normal esqcom2[esqpos2] with frame f-com2.
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
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail forne
                    then leave.
                    recatu1 = recid(forne).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail forne
                    then leave.
                    recatu1 = recid(forne).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail forne
                then next.
                color display white/red forne.forcod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail forne
                then next.
                color display white/red forne.forcod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form forne
                 with frame f-forne color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do.
                    run inclusao.
                    leave.
                end.
                if esqcom1[esqpos1] = " Consulta " 
/***
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
***/
                then do with frame f-consulta
                        row 4 centered /* OVERLAY */ 2 COLUMNS 40 down
                                    SIDE-LABELS. 
                    run le-cpforne(no, forne.forcod).
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
                if esqcom1[esqpos1] = " Alteracao "
                then do.
                    run alteracao.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" forne.fornom
                            update sresp.
                    if not sresp
                    then undo, leave.
                    find next forne where true no-error.
                    if not available forne
                    then do:
                        find forne where recid(forne) = recatu1.
                        find prev forne where true no-error.
                    end.
                    recatu2 = if available forne
                              then recid(forne)
                              else ?.
                    find forne where recid(forne) = recatu1
                            exclusive.
                    delete forne.
                    recatu1 = recatu2.
                    leave.
                end.

                if esqcom1[esqpos1] = "Procura"
                then do with frame f-Lista overlay row 6 1 column centered.
                    update vforcod with frame f-for centered row 15 overlay.
                    find bforne where bforne.forcod = vforcod no-lock no-error.
                    if avail bforne
                    then recatu1 = recid(bforne).
                    /*run le-cpforne(no, forne.forcod).*/
                    leave.
                end.
                if esqcom1[esqpos1] = "Listagem"
                then do:
                    output to printer page-size 0.
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

                if esqcom2[esqpos2] = "DATA NFE"
                then do on error undo with frame f-data-nfe:
                    run le-cpforne(yes, forne.forcod).
                    update cpforne.date-1
                             label "ALTERA DATA NFE" with no-validate
                                    overlay centered.
                end.
                leave.
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(forne).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display
        forne.forcod
        forne.fornom
        forne.forfant
        forne.ativo
        with frame frame-a 11 down centered color white/red row 5.
end procedure.

procedure color-message.
    color display message
        forne.forcod
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal
        forne.forcod
        with frame frame-a.
end procedure.


procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then find first forne where true no-lock no-error.
    else find last forne  where true no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then find next forne  where true no-lock no-error.
    else find prev forne  where true no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then find prev forne where true  no-lock no-error.
    else find next forne where true  no-lock no-error.
        
end procedure.

procedure inclusao.

    do with frame f-inclui row 4  centered OVERLAY 2 COLUMNS SIDE-LABELS.

                /* Liberar a inclusao        
                sresp = yes.
                run permissao.
                
                if not sresp
                then next bl-princ.
                */
                
                vcgc = "". 
                update vcgc label "CNPJ/CPF".
                 
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
                       
                create forne.
                update forne.fornom.
                assign forne.forfant = substr(forne.fornom,1,13).
                UPDATE forne.forfant.

               do on error undo, retry:
                  UPDATE 
                       forne.forrua
                       forne.fornum
                       forne.forcomp
                       forne.forbairro
                       forne.formunic
                       forne.ufecod
                       forne.forpais.
                       
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
                   
                  if length(forne.forrua) < 2 or
                     length(forne.formunic) < 2
                  then do:
                       message "Endereco obrigatorio".
                       undo, retry.
                  end.
                end.       
                FORNE.FORTIPO = "S".

                UPDATE forne.fortipo
                       forne.forfone
                       forne.forfax
                       forne.forcont.
                       
                do on error undo, retry:
                    update forne.forinest 
                      help "Informar a inscricao ou ISENTO ou NAO CONTRIBUINTE".
                    sresp = no.
                    run val-ie.p(forne.ufecod, forne.forinest, output sresp).
                    if forne.ufecod = "BA" and sresp = no
                    then sresp = yes.
                    if sresp = no
                    then do:
                        message "Inscricao Estadual invalida" view-as alert-box.
                        undo, retry.
                    end.
                end.    
                update forne.foriesub label "IE Subst.Trib." 
                       forne.fordtcad
                       forne.forctfon
                       forne.forcep.
                find last bforne no-lock no-error.
                if available bforne
                then assign vforcod = bforne.forcod + 1.
                else assign vforcod = 1.
                assign forne.forcod = vforcod.
                vforcodpai = 0.
                update forne.forcod 
                       vforcodpai label "Codigo Pai" with no-validate.
                
                forne.forpai = vforcodpai. 
                forne.forcgc = vcgc.
                
                find last bforne use-index livro no-lock no-error.
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
                        update cpforne.int-1 label "COD.CIDADE".
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
    end.
end procedure.

procedure alteracao.

    do with frame f-altera row 4 centered OVERLAY 2 COLUMNS SIDE-LABELS.
        find forne where recid(forne) = recatu1 exclusive.

                sresp = yes.
                run permissao.

                assign vpermissao-alteracao = sresp.

                find current forne EXCLUSIVE.

                if vpermissao-alteracao
                then update forne.fornom.
                else display forne.fornom.
                
                /* assign forne.forfant = substr(forne.fornom,1,13). */
                UPDATE forne.forfant.
                UPDATE forne.forrua format "x(59)"
                                  validate(forrua <> "","Endereco obrigatorio")
                       forne.fornum
                       forne.forcomp
                       forne.forbairro.
                       
               do on error undo, retry:        
                  update
                       forne.formunic
                       forne.ufecod.
                  /*
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
                  */
                end.

                UPDATE forne.forpais
                       forne.fortipo
                       forne.forfone
                       forne.forfax
                       forne.forcont.
                
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
                else display vcgc.

                if vpermissao-alteracao or
                   forne.forinest = ?
                then 
                do on error undo, retry:
                    update forne.forinest 
                      help "Informar a inscricao ou ISENTO ou NAO CONTRIBUINTE".
                    sresp = no.
                    run val-ie.p(forne.ufecod, forne.forinest, output sresp).
                    if forne.ufecod = "BA" and sresp = no
                    then sresp = yes.
                    if sresp = no
                    then do:
                        message color red/with
                        "Inscricao Estadual invalida" view-as alert-box.
                        undo, retry.
                    end.
                end. 
                else display forne.forinest.
                
                update forne.foriesub label "IE Subst.Trib."  
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
                        update cpforne.int-1 label "COD.CIDADE".
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
                    update cpforne.date-1 label "NFE Desde"
                            HELP "Nota Fiscal Eletronica desde que data".
                    if forne.ufecod = "AM"
                    then update cpforne.char-1 label "Cod. SUFRAMA".
                end.
                update cpforne.char-2 label "Email-NFe" format "x(50)".
    end.

end procedure.

procedure permissao:
    sresp = yes.  
    find first func where func.etbcod = setbcod
                      and func.funcod = sfuncod no-lock no-error.
                    
    if not avail func or func.funfunc <> "CONTABILIDADE"
    then sresp = no.

end procedure.      

