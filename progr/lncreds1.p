/*          
*
*    tt-titluc.p    -    Esqueleto de Programacao    com esqvazio


            substituir    tt-titluc
                          <tab>
*
*/

def var varquivo as char.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Inclusao "," Alteracao "," Exclusao "," Consulta "," Listagem "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de tt-titluc ",
             " Alteracao da tt-titluc ",
             " Exclusao  da tt-titluc ",
             " Consulta  da tt-titluc ",
             " Listagem  Geral de tt-titluc "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].
                         
{admcab.i}

def var v-primeiro as logical init no.
def  var vsetcod like setaut.setcod.
def var vnumtit  as   char.
def  var vtipo-documento as int.
def  var vempcod         like titulo.empcod initial 19.
def  var vetbcod         like titulo.etbcod.
def  var vmodcod         as char initial "" format "x(3)".
def  var vtitnat         like titulo.titnat initial no.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def  var vclifor         like titulo.clifor.
def var vforcod like forne.forcod.
def var vlp as log.

def temp-table tt-titluc like titluc
    index i1 titdtven descending.

form vetbcod label "Filial "estab.etbnom no-label  skip
     vsetcod setaut.setnom no-label skip
     vmodcod modal.modnom no-label  skip
     vtitnat   skip
     vforcod   forne.fornom format "x(35)"
     with frame ff1 centered title "Creditos Administrativos" side-labels
     width 70.
     
def var vdtveni as date.
def var vdtvenf as date.

def var vqtd-lj as int. 

def buffer btt-titluc       for tt-titluc.
def var vtt-titluc         like tt-titluc.titnum.


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


    do on error undo with frame ff1:
        clear frame ff1 no-pause.
        update vetbcod with frame ff1.
        find first estab where estab.etbcod = vetbcod no-lock no-error.
        if vetbcod <> 0
        then do:
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            undo, retry.
        end.
        disp estab.etbnom with frame ff1.                      
        end.
        else disp "Todos" @ vsetcod with frame ff1.
        update vsetcod with frame ff1. 
        if vsetcod <> 0
        then do:
        find first setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor Invalido".
            undo, retry.
        end.
        disp setaut.setnom with frame ff1.
        end.
        else disp "Todos" @ setaut.setnom with frame ff1.
        update  vmodcod  label "Modalidade" with frame ff1.
        if vmodcod <> ""
        then do:
        find first modal where modal.modcod = vmodcod no-lock no-error.
        if not avail modal
        then do:
            message "Modalidade Invalida".
            undo, retry.
        end.
        if modcod = "CRE"
        then do:
            message "modalidade invalida".
            undo, retry.
        end.        
        display modal.modnom no-label with frame ff1.
        end.
        else disp "Todas" @ modal.modnom with frame ff1.


        vtitnat = no.
        disp vtitnat skip with frame ff1.
         update vtitnat skip with frame ff1.
        update vforcod  with frame ff1.
        if vforcod <> 0
        then do:
        find first forne where forne.forcod = vforcod no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor Invalido".
            undo, retry.
        end.                                                  
        assign vclifor = vforcod.
        display forne.fornom no-label with frame ff1.
        find first foraut where foraut.forcod = forne.forcod no-lock no-error.
        end.
        else disp "Todos" @ forne.fornom with frame ff1.
        
        
        update vdtveni label "Periodo" vdtvenf no-label with frame ff1.
        
        
    end.                                


for each tt-titluc:
  delete tt-titluc.
end.
                                    
for each titluc where
                    (if vetbcod <> 0
                     then titluc.etbcod = vetbcod
                     else true) and
                    (if vempcod <> 0
                     then titluc.empcod = vempcod
                      else true) and
                    (if vmodcod <> ""
                     then titluc.modcod = vmodcod
                      else true) and
                      /*
                    (if vclifor <> 0
                    then titluc.clifor = vclifor
                     else true) and */
                    titluc.titnat = vtitnat and
                    (if vsetcod <> 0
                     then titluc.titbanpag = vsetcod
                     else true) and
                    titluc.titpar = 1 and 
                   /* and titluc.evecod = 8  and */
                    titluc.titdtven >= vdtveni and
                    titluc.titdtven <= vdtvenf no-lock:
    if titluc.titsit = "CAN" then next.
    if vclifor <> ? and titluc.clifor <> vclifor
    then next.
    create tt-titluc.
    buffer-copy titluc to tt-titluc. 
    
    hide message no-pause.
    message "Aguarde !!! Carregando..." tt-titluc.titnum tt-titluc.titpar vclifor titluc.clifor.
end.

pause 0.

bl-princ:
repeat:

    for each tt-titluc where tt-titluc.titvlcob = 0
                         and tt-titluc.titnum = "".
        delete tt-titluc.
    end.

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-titluc where recid(tt-titluc) = recatu1 no-lock.
   
    if not available tt-titluc
    then esqvazio = yes.
    else esqvazio = no.
    
    clear frame frame-a all no-pause.

    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-titluc).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-titluc
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
            find tt-titluc where recid(tt-titluc) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(tt-titluc.titnum)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(tt-titluc.titnum)
                                        else "".
            run color-message.
            choose field tt-titluc.titnum help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return).
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
                    if not avail tt-titluc
                    then leave.
                    recatu1 = recid(tt-titluc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-titluc
                    then leave.
                    recatu1 = recid(tt-titluc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-titluc
                then next.
                color display white/red tt-titluc.titnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-titluc
                then next.
                color display white/red tt-titluc.titnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form tt-titluc.etbcod label "Filial"
                 tt-titluc.modcod label "Modalidade"
                 skip
                 tt-titluc.clifor label "Fornecedor"
                 skip
                 tt-titluc.titnum label "Titulo"
                 skip
                 tt-titluc.titvlcob label "Valor"
                 tt-titluc.titdtemi label "Emissao"
                 tt-titluc.titdtven label "Vencimento"
                 tt-titluc.titdtpag label "Pagamento"
                    tt-titluc.titobs[1] format "x(45)"
                 tt-titluc.titsit label "Situacao"
                 with frame f-tt-titluc color black/cyan
                      centered side-label row 5 .
            hide frame frame-a no-pause.
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

/***
                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                  then do on error undo with frame f-tt-titluc:
      
        clear frame f-tt-titluc all.
***/
        
        /*
        esqpos1 = 1.
        color display message esqcom1[esqpos1] with frame f-com1.
        */
         
        if keyfunction(lastkey) = "end-error"  then leave bl-princ.

                if esqcom1[esqpos1] = " Inclusao " or esqvazio
                then do with frame f-tt-titluc on error undo.

        create tt-titluc.
        if vetbcod <> 0
        then tt-titluc.etbcod = vetbcod.
        update tt-titluc.etbcod.
        find first estab where estab.etbcod = tt-titluc.etbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            undo, retry.
        end.
        if vempcod <> 0
        then tt-titluc.empcod = vempcod.
        update tt-titluc.empcod.
        if vmodcod <> ""
        then tt-titluc.modcod = vmodcod.
        if vclifor <> 0
        then tt-titluc.clifor = vclifor.
        update tt-titluc.clifor.
        find first forne where forne.forcod = tt-titluc.clifor no-lock no-error.
        if not avail forne
        then do:
            message "Fornecedor Invalido".
            undo, retry.
        end.
        else vforcod = vclifor.
        tt-titluc.titnat = vtitnat.
        disp tt-titluc.titnat.
        if vsetcod <> 0
        then tt-titluc.titbanpag = vsetcod.
        update tt-titluc.titbanpag.
        tt-titluc.titpar = 1.
        disp tt-titluc.titpar.
       /* tt-titluc.evecod = 8.
        disp tt-titluc.evecod.*/
        update tt-titluc.evecod.
        assign tt-titluc.titnum = "".
        assign recatu1 = recid(tt-titluc).
        run gera-titnum.p(output tt-titluc.titnum).
        disp tt-titluc.titnum with frame f-tt-titluc.
        run Pi-Atualiza-Titluc.
        /***end.             ***/
                    
                    recatu1 = recid(tt-titluc).
                    leave.
                end.                
                
                if esqcom1[esqpos1] = " Consulta " or
                   esqcom1[esqpos1] = " Exclusao " or
                   esqcom1[esqpos1] = " Alteracao "
                then do with frame f-tt-titluc.
                disp tt-titluc.etbcod label "Filial"
                 tt-titluc.modcod label "Modalidade"
                 skip
                 tt-titluc.clifor label "Fornecedor"
                 skip
                 tt-titluc.titnum label "Titulo"
                 skip
                 tt-titluc.titvlcob label "Valor"
                 tt-titluc.titdtemi label "Emissao"
                 tt-titluc.titdtven label "Vencimento"
                 tt-titluc.titdtpag label "Pagamento"
                 tt-titluc.titobs[1]
                 tt-titluc.titsit label "Situacao"
                 with frame f-tt-titluc color black/cyan
                      centered side-label row 5 .                
                end.
                
                if esqcom1[esqpos1] = " Alteracao "
                then do on error undo with frame f-tt-titluc:
                    find tt-titluc where recid(tt-titluc) = recatu1 no-error.
                    if avail tt-titluc
                       then 
                   update  tt-titluc.titvlcob 
                           tt-titluc.titdtemi 
                           tt-titluc.titdtven
                           tt-titluc.titdtpag
                           tt-titluc.titobs[1]
                           with frame f-tt-titluc.
                    recatu1 = recid(tt-titluc).

                     run Pi-Atualiza-Titluc.                          
                     leave.
                end.
                if esqcom1[esqpos1] = " Exclusao "
                then do with frame f-exclui  row 5 1 column centered
                        on error undo.
                    message "Confirma Exclusao de" tt-titluc.titnum
                            update sresp.
                    if not sresp
                    then undo, leave.

                    
        find first tt-titluc where recid(tt-titluc) =  recatu1 no-error.
        if avail tt-titluc then do:
                assign tt-titluc.titsit = "CAN".
                disp  "" @ tt-titluc.titnum
                      "" @ tt-titluc.titdtpag
                      "" @ tt-titluc.titdtven
                      "" @ tt-titluc.titsit
/*                      "" @ tt-titluc.titobs[1] */
                      "" @ tt-titluc.titpar
                      "" @ tt-titluc.titvlcob
                      "" @ tt-titluc.titdtemi
                      with frame f-tt-titluc.
        end.                     
                    
                     run Pi-Atualiza-Titluc.
                    recatu1 = recatu2.
                    leave.
                end.
                if esqcom1[esqpos1] = " Listagem "
                then do with frame f-Lista:
                    update "Deseja Imprimir Listagem ? "
                           sresp format "Sim/Nao"
                                 help "Sim/Nao"
                           with frame f-lista row 15 centered color black/cyan
                                 no-label.
                    if sresp = yes
                    then do:
                        run p-listagem.
                    end.
                    leave.
                end.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = "  "
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    /* run programa de relacionamento.p (input ). */
                    view frame f-com1.
                    view frame f-com2.
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
        recatu1 = recid(tt-titluc).
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
display tt-titluc.etbcod
                 tt-titluc.modcod
                 tt-titluc.clifor
                 tt-titluc.titnum
                 tt-titluc.titvlcob 
                 tt-titluc.titdtemi 
                 tt-titluc.titdtven 
/*                 tt-titluc.titdtpag*/
                /* tt-titluc.titobs[1]*/
/*                 tt-titluc.titsit*/
        with frame frame-a 11 down centered color white/red row 5.
end procedure.
procedure color-message.
color display message
        tt-titluc.titnum
        with frame frame-a.
end procedure.
procedure color-normal.
color display normal
        tt-titluc.titnum
        with frame frame-a.
end procedure.




procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-titluc where true
                                                no-lock no-error.
    else  
        find last tt-titluc  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-titluc  where true
                                                no-lock no-error.
    else  
        find prev tt-titluc   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-titluc where true  
                                        no-lock no-error.
    else   
        find next tt-titluc where true 
                                        no-lock no-error.
        
end procedure.
        
         
procedure Pi-Atualiza-Titluc.

for each tt-titluc : 
disp tt-titluc.titnum. pause.

    if tt-titluc.titnum = "" or tt-titluc.titvlcob <= 0 then next.

    if tt-titluc.titdtpag <> ? and tt-titluc.titsit <> "CAN"
    then do:
        assign tt-titluc.titvlpag = tt-titluc.titvlcob
               tt-titluc.titsit   = "PAG".
    end.

    find first titluc where titluc.titnum = tt-titluc.titnum and
                            titluc.etbcod = tt-titluc.etbcod and
                            titluc.empcod = tt-titluc.empcod and
                            titluc.modcod = tt-titluc.modcod and
                            titluc.clifor = tt-titluc.clifor and
                            titluc.titnat = tt-titluc.titnat and
                            titluc.titbanpag = vsetcod and
                            titluc.titpar = 1  exclusive no-error.
    
    if not avail titluc 
    then do:
        create titluc.
        assign titluc.titnum = tt-titluc.titnum 
                            titluc.etbcod = tt-titluc.etbcod
                            titluc.empcod = tt-titluc.empcod
                            titluc.modcod = tt-titluc.modcod
                            titluc.clifor = tt-titluc.clifor
                            titluc.titnat = tt-titluc.titnat
                            titluc.titbanpag = vsetcod
                            titluc.titpar = 1 
                            titluc.titdtemi = tt-titluc.titdtemi
                            titluc.titdtpag = tt-titluc.titdtpag
                            titluc.titdtven = tt-titluc.titdtven
                            titluc.titvlcob = tt-titluc.titvlcob
                            titluc.titsit   = tt-titluc.titsit
                            titluc.titobs[1] = tt-titluc.titobs[1]
                            titluc.titvlpag = tt-titluc.titvlpag.
            titluc.evecod = 8.
    end.
    else do:
         assign     titluc.titdtemi = tt-titluc.titdtemi
                    titluc.titdtpag = tt-titluc.titdtpag
                    titluc.titdtven = tt-titluc.titdtven
                    titluc.titvlcob = tt-titluc.titvlcob
                    titluc.titsit   = tt-titluc.titsit
                    titluc.titobs[1] = tt-titluc.titobs[1]
                    titluc.titvlpag = tt-titluc.titvlpag.
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
                    do ve = 1 to 5:
                    color display normal esqcom1[ve] with frame f-com1.
                    end.
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

procedure p-listagem.
varquivo = "./lncredsp." + string(time).
    
        {mdad_l.i
            &Saida     = "value(varquivo)"
            &Page-Size = "0"
            &Cond-Var  = "150"
            &Page-Line = "66"
            &Nom-Rel   = ""GERAL""
            &Nom-Sis   = """CREDITOS FINANCEIROS"""
            &Tit-Rel   = """POSICAO EM "" + string(today) "
            &Width     = "150"
            &Form      = "frame f-cabcab"}

for each tt-titluc.
    display tt-titluc.etbcod
                 tt-titluc.modcod
                 tt-titluc.clifor
                 tt-titluc.titnum
                 tt-titluc.titvlcob 
                 tt-titluc.titdtemi 
                 tt-titluc.titdtven.
end.
output close.
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
end procedure.
