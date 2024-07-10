/*
*   telcli.p
*/
def buffer bclien for clien.
def new global shared var tetbcod like estab.etbcod.
def new global shared var tfuncod like func.funcod.
def var vetbcod like estab.etbcod .
tetbcod = 0.
tfuncod = 0. 

def var vrgccod     like rgcobra.rgccod.
def var vclicod     like clien.clicod.
def var vmodcod like modal.modcod init "geral".
def var vdiasini       as int format ">>>9" label "Dias Atraso".
/*def var vdiasfin       as int format ">>>9" label "ate".*/

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esq-periodo     as log initial no.
def var esqcom1         as   char format "x(12)" extent 6
      initial [" Titulos "," Acoes Cob "," Dados ",
                        " Cliente ", ""].
def var esqhel1         as char format "x(80)" extent 5
    initial [" Inclusao  de clilig ",
             " Alteracao da clilig ",
             " Exclusao  da clilig ",
             " Consulta  da clilig ",
             " Listagem  Geral de clilig "].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

{admcab.i new}
def var vendereco     as char format "x(60)"  .
def var vdesfone        as   char.
def var vspc            as   log format "SIM/NAO".
def var vdescricao      as   char.

def var vtoday as date format "99/99/9999".
vtoday = today.
def var vtelobs         as   char extent 4 format "x(60)".
                  
find first clilig where clilig.DtProxLig = vtoday no-lock no-error.
if not avail clilig
then do on error undo.
    message "Processo para selecionar as Ligacoes deve ser processado."
            " ****  AVISAR O SETOR DE TI ****"
            view-as alert-box.
    return.            
end.
find first clilig no-lock no-error.
if not avail clilig
then do on error undo.
    message "Processo para selecionar as Ligacoes deve ser processado."
            " ****  AVISAR O SETOR DE TI ****"
            view-as alert-box.
    return.            
end.                
def var vsenha like func.senha.
vsenha = "".
do on error undo, return on endkey undo, retry:
    if keyfunction(lastkey) = "END-ERROR"
    then return.
    vsenha = "".
    update tetbcod label "Estab"
           tfuncod label "Matricula"
           vsenha blank with frame f-senh side-label centered row 10.
    find first func where func.funcod = tfuncod and
                          func.etbcod = tetbcod and
                          func.senha  = vsenha no-lock no-error.
    if not avail func
    then do:
        message "Funcionario Invalido.".
        undo, retry.
    end.
    else assign tetbcod = func.etbcod
                tfuncod = func.funcod.
end.
hide frame f-senh no-pause.


def buffer bclilig       for clilig.
def var vclilig         like clilig.clicod.
def var vdivida         like titulo.titvlcob format "->>,>>>,>>9.99".
def var vnumdias        as   int    format   ">,>>9"    column-label "Dias".
def var vdatahora as char init "". 
def var vtitle as char.
def var vvalini        like titulo.titvlcob.
def var vvalfin        like titulo.titvlcob.
def var vagendadas as log format "Agendados/Nao realizadas".


def var vtipos as char   format "x(30)" extent 6
    init [" 1)  11 A 11 DIAS ", 
          " 2)  25 A 25 DIAS ",
          " 3)  40 A 40 DIAS ",
          " 4)  55 A 55 DIAS ",
          " 5)  AGENDADOS    ",
          " 6)  PERIODO LIVRE " 
          /*
          " 7)  FEITAS NO DIA ",
          " 8)  NAO FEITAS DIA ANTERIOR ",
          " 9)  POR DATA "
          */
          ].
form
    clien.clicod     colon 12 format ">>>>>>>9"
    clien.clinom     no-label format    "x(40)"
    vdivida           label "Divida"
    clien.ciins      label "Identidade" colon 11
    clien.ciccgc
    with frame fclien row 14 title " Cliente " color white/cyan width 80
                       side-labels.

form clien.clicod format ">>>>>>>9"
     clien.clinom no-label format "x(40)"
     clien.endereco[1] label "End"
     clien.fone format "x(15)"
/*     cpfis.fone         label "Tl.Cel" 
     cpfis.fonepes      label "Tl.Res"   */
     with frame f-cliente
        width 80 no-box row 3 side-labels color messages.

   assign
      vdiasini = 1
      /*vdiasfin = 0*/ .


repeat with frame f-filtro side-labels  no-box row 3.
    assign esqregua = yes esqpos1  = 1 esqpos2  = 1 recatu1  = ?.
    vetbcod = tetbcod.
    display vetbcod.
    find estrgcobra where estrgcobra.etbcod = vetbcod no-lock no-error.
    vrgccod = if avail estrgcobra
              then estrgcobra.rgccod
              else 1.
    update vetbcod .
    find estab where estab.etbcod = vetbcod no-lock no-error.
    disp if avail estab
         then estab.etbnom
         else "GERAL" @ estab.etbnom no-label.
    if avail estab
    then vrgccod = 0.
    else do on error undo.  
        display vrgccod.
        update vrgccod. 
        if vrgccod <> 0 
        then do: 
            find rgcobra where rgcobra.rgccod = vrgccod no-lock no-error. 
            if not avail rgcobra 
            then do: 
                message "Regiao invalida". 
                undo. 
            end. 
        end. 
    end.    
    display vrgccod.
    
    vvalini = 0. vvalfin = 9999999.
    update vvalini  label "Valor maior que".
/*    update vprofcod label "Profissao".*/

    /*
    def var tmodcod like modal.modcod extent 2
                     init ["GERAL",
                           "CRE"].
    def var tmodnom like modal.modnom extent 2.
    def var x as int.
    do x = 2 to 2.
        find modal where modal.modcod = tmodcod[x] no-lock.
        tmodnom[x] = modal.modnom.
    end.
    
    repeat.
        DISPLAY tmodcod[1] tmodnom[1]  skip 
                tmodcod[2] tmodnom[2]  skip 
                /*
                tmodcod[3] tmodnom[3]  skip 
                tmodcod[4] tmodnom[4]  skip 
                tmodcod[5] tmodnom[5]  skip 
                tmodcod[6] tmodnom[6]  skip 
                tmodcod[7] tmodnom[7]  SKIP
                tmodcod[8] tmodnom[8]  skip
                tmodcod[9] tmodnom[9]  */ 
                
                WITH FRAME Fmmodal 
                        NO-LABEL row 6 
                            title " Modalidades ". 
        CHOOSE field tmodcod auto-return with frame fmmodal .
            
        vmodcod = tmodcod[frame-index].
        leave.
    end.    
    */
    vmodcod = "CRE".
    repeat.
    DISPLAY VTIPOS[1] skip 
            vtipos[2] skip 
            vtipos[3] skip 
            vtipos[4] skip 
            vtipos[5] skip 
            vtipos[6]  /*skip 
            vtipos[7] SKIP
            vtipos[8] skip
            vtipos[9]*/
            WITH FRAME FTIPOS 
                    NO-LABEL row 6 column 40
                        title " Filtros ". 
        CHOOSE field vtipos auto-return with frame ftipos .
        def var ctipos as char.
        
    ctipos = vtipos[frame-index].

    if ctipos = "" 
    then next.
    else leave.
    end.    
    def var vlivre as log.
    def var vdodia as log.
    def var vdiaanterior as log init no.
    
    def var v-faixa-datas as log init no no-undo.
    def var dt-ini        as date format "99/99/9999" no-undo.
    def var dt-fim        as date format "99/99/9999" no-undo.
    
    vdiaanterior = no.
    vlivre = no.
    hide frame ftipos no-pause.
    hide frame f-data-aux no-pause.
    vagendadas = ?.
    esq-periodo = ?.
    vlivre = ?.
    vdodia = no.
    if frame-index = 1
    then assign vdiasini = 11
                /*vdiasfin = 11 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 2
    then assign vdiasini = 25
                /*vdiasfin = 25 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 3
    then assign vdiasini = 40
                /*vdiasfin = 40 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 4
    then assign vdiasini = 55
                /*vdiasfin = 55 */
                esq-periodo = yes
                vagendadas = no.        
    else
    if frame-index = 5
    then assign vdiasini = 0
                /*vdiasfin = 0 */
                esq-periodo = no
                vagendadas   = yes.        
    else
    if frame-index = 6
    then do:
        update vdiasini validate(vdiasini >= 10,"Atraso maior que 9 dias")
               /*vdiasfin*/ with frame ffff  row 5 side-label
                            no-box .
        esq-periodo = yes .
        vlivre = yes.
        vagendadas   = no.
    end.             
    else
    if frame-index = 7
    then assign vdiasini = ?
                /*vdiasfin = ? */
                vdodia = yes
                vagendadas   = ?.        
    else
    if frame-index = 8
    then assign vdiasini = ?
                /*vdiasfin = ? */
                vdiaanterior = yes
                vagendadas   = ?.        
           
    if frame-index = 9 /*por faixa de datas*/
    then do:
       assign dt-ini = vtoday
              dt-fim = vtoday.
       
       disp dt-ini label "Data inicial" 
            " a "
            dt-fim label "Data Final"
            with frame f-data-aux.
                  
       update dt-ini 
              dt-fim 
              with frame f-data-aux.
              
       if dt-ini > dt-fim
       then do:
          message "Data Inválida!" view-as alert-box.
          undo.
       end.   
       else do:
       
           assign v-faixa-datas = yes
                  vdiasini      = ?
                  /*vdiasfin      = ?*/
                  vagendadas    = ?
                  vdiaanterior  = ?.
              
           hide frame f-data-aux no-pause.
          
       end.
      
       
    end.      


    def var vdtini as date.
    def var vdtfin as date.
    vdtini = vtoday - vdiasini.
/*    vdtfin = vtoday - vdiasini.*/

recatu1 = ?.
recatu2 = ?.



Form
     esqcom1
     with frame f-com1 row 6 no-box no-labels side-labels column 1.
     
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

def var vqtd as int.
vqtd = 0.
if  esq-periodo   
then  do.
    for each clilig where clilig.dtven    = vdtini  and
                                clilig.dtacor    = ?      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig2
                                                no-lock.
        vqtd = vqtd + 1.
    end.
end. 
else  do.
    for each clilig  where 
                                clilig.dtacor    < vtoday      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig3
                                                 no-lock.
        vqtd = vqtd + 1.
    end.
end.



vtitle = "Etb=" + string(vetbcod) +
         " Rg="  + string(vrgccod)  +
         " MODAL=" + vmodcod + " " +
                ctipos  + "QDT CLIENTES = " + string(vqtd).



bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find clilig where recid(clilig) = recatu1 no-lock.
    if not available clilig
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do on endkey undo.
        message "Nenhum registro selecionado neste filtro"
                    view-as alert-box.
        leave.        
    end.

    recatu1 = recid(clilig).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available clilig
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
            find clilig where recid(clilig) = recatu1 no-lock.
            find clien where
                    clien.clicod = clilig.clicod no-lock.
            vclicod = clien.clicod.
    
            assign vtelobs = "".
    
            find last clitel where clitel.clicod = clien.clicod
                               no-lock no-error.
            if avail clitel 
            then do:
               find tipcont of clitel no-lock no-error.
               vtelobs[1] = substr(string(clitel.teldat,"99/99/99"),1,5) + " " 
                                +
                            string(clitel.telhor,"HH:MM") + " " + 
                            string(clitel.codcont) + " - " + 
                        (if avail tipcont then tipcont.desccont else "").
               vtelobs[1] = vtelobs[1] + " -OBS:" +  clitel.telobs[1] + " " +
                            clitel.telobs[2] + " "  +  clitel.telobs[3].
            end.
            def var i as int.
            do i = 2 to 4:
               find prev clitel where clitel.clicod = clien.clicod
                               no-lock no-error.
               if avail clitel
               then do:
                  find tipcont of clitel no-lock no-error.
                  vtelobs[i] = substr(string(clitel.teldat,"99/99/99"),1,5) + 
                                " "  +
                               string(clitel.telhor,"HH:MM") + " " + 
                           string(clitel.codcont) + " - " + 
                           (if avail tipcont then tipcont.desccont else "").
                  vtelobs[i] = vtelobs[i] + " -OBS:" + clitel.telobs[1] + 
                            " " +
                           clitel.telobs[2] + " " + clitel.telobs[3].
               end.
            end.
            display vtelobs[1] format "x(78)" skip
                    vtelobs[2] format "x(78)"
                    vtelobs[3] format "x(78)"
                    vtelobs[4] format "x(78)"
                    with frame telobs with row 19
                    no-labels 1 col no-box color messages width 80.
            status default "H - Consulta Historicos de Ligacoes".

            choose field clilig.clicod help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) .

            status default "".

        end.
            if keyfunction(lastkey) = "TAB"
            then do:
                if esqregua
                then do:
                    color display normal esqcom1[esqpos1] with frame f-com1.
                end.
                else do:
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
                    esqpos2 = if esqpos2 = 5 then 5 else esqpos2 + 1.
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
                    esqpos2 = if esqpos2 = 1 then 1 else esqpos2 - 1.
                end.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail clilig
                    then leave.
                    recatu1 = recid(clilig).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail clilig
                    then leave.
                    recatu1 = recid(clilig).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail clilig
                then next.
                color display white/red clilig.clicod with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail clilig
                then next.
                color display white/red clilig.clicod with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form clilig
                 with frame f-clilig color black/cyan
                      centered side-label row 5 .
            if esqcom1[esqpos1] <> " Cliente "
            then do:
                clear frame ftitulo all.
                clear frame fpag1 all.
                /*
                hide  frame frame-a no-pause.
                */
            end.

            if esqregua
            then do:
                pause 0.
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                pause 0.
                if esqcom1[esqpos1] = " Cliente  "
                then do on error undo:
                    update vclicod
                            with frame fcliented
                                    centered row 10
                                            side-label.
                    find bclien where bclien.clicod = vclicod
                                        no-lock no-error.
                    if avail bclien
                    then do:
                        /*
                        vtitcod = ?.
                        for first titulo where titulo.titnat = no and
                              titulo.clifor = vclicod and
                              titulo.titdtpag = ? and
                              titulo.titdtven < vtoday
                                        no-lock by titulo.titdtven.
                            vtitcod = titulo.titcod.
                        end.
                        */
                        find clilig where clilig.clicod = vclicod no-lock
                                                    no-error.
                        if not avail clilig
                        then do.
                            create clilig.
                            clilig.clicod = vclicod.
                        end.
                        recatu1 = recid(clilig).
                        leave.
                    end.
                    else do.
                        message "Cliente Invalido".
                        pause 3 no-message.
                    end.
                end.
                if esqcom1[esqpos1] = " Titulos  "
                then do on error undo:
                   hide frame f-com1 no-pause.
                   hide frame telobs no-pause.
                   hide frame frame-a no-pause.
                   find clien where clien.clicod = vclicod exclusive
                            no-wait no-error.
                   if not avail clien
                   then do on endkey undo.
                       bell. bell.
                       message "LIGACAO SENDO FEITA POR OUTRO COBRADOR"
                           view-as alert-box.
                       next bl-princ.    
                   end. 
                   run bsfqtitag.p (clien.clicod).
                   pause 0.
                   view frame frame-a.
                   view frame f-com1.
                   view frame telobs.
                   pause 0.
                end.
                
                if esqcom1[esqpos1] = " Dados "
                then do on error undo:
                   hide frame f-com1 no-pause.
                   hide frame telobs no-pause.
                   hide frame frame-a no-pause.
                   pause 0.
                    run clidis.p (input recid(clien)) .         
                    pause 0.
                   view frame frame-a.   pause 0.
                   view frame f-com1.    pause 0.
                   view frame telobs.    pause 0.
                end.

                if esqcom1[esqpos1] = " Acoes Cob "
                then do on error undo:
                   find clien where clien.clicod = vclicod exclusive
                            no-wait no-error.
                   if not avail clien
                   then do:
                       bell. bell.
                       message "LIGACAO SENDO FEITA POR OUTRO COBRADOR"
                           view-as alert-box.
                   end.
                   else do:
                        hide frame ftitulo no-pause.
                        hide frame frame-a no-pause.
                        hide frame telobs no-pause.

                        /*
                        if not avail cpfis
                        then do on error undo:
                            create cpfis.
                            assign cpfis.clicod = clien.clicod.
                        end.
                        */

                        vendereco =
                           trim(trim(clien.endereco[1]) + "," + 
                           trim(string(clien.numero[1]))      + " " +
                           trim(clien.compl[1])  + " " +
                           trim(clien.cidade[1]) + " " +
                                clien.ufecod[1] ).

/*                        if avail cpfis
                        then vendcom = trim(cpfis.endcom + ","
                            + cpfis.numcob + " - " + cpfis.complcob + " " +
                            cpfis.bairro + " " + cpfis.munic).
                        else*/ /*vendcom = ""*/ .

/*                        if avail cpfis
                        then vconjend = trim(cpfis.conjend /**+ ","
                        + string(cpfis.conjnumero) + " - " +
                          cpfis.conjcomplemento + " "
                          + cpfis.conjbairro + " " + cpfis.conjcidade**/) .

                        if (avail cpfis and cpfis.spcdtin <> ? and
                           cpfis.spcdtin >= cpfis.spcdtfi) or
                           (cpfis.spcdtfi = ? and cpfis.spcdtin <> ?)
                        then vspc = yes.
                        else vspc = no.
                         */
             /***************tela nova para telefornar*************/

                     disp clien.clicod format ">>>>>>>9"
                             clien.clinom no-label format "x(30)"
                             /*cpfis.mtbcod label "Sit. C/C"*/
                             /*cpfis.sitspc label "SPC"*/
                             vspc label "SPC"
                             /*cpfis.assecod label "Asses."*/
                                    with frame f-cliente2
                            width 80 no-box row 4 side-labels color 
messages.               
                         vdescricao = " ".

                        disp vendereco          label "End."  skip
                             clien.fone format "x(15)"
                             /*cpfis.fone         label "Tl.Cel"
                             cpfis.fonepes      label "Tl.Res"*/
/*                             cpfis.estado-fone label "Tipo"*/
                             vdescricao no-label
                             with frame f-res side-labels
                             width 80 row 5 overlay no-box.

                        run bscrclitel.p ( input recid(clien),
                                         input recid(clilig)).
                        find last clitel where 
                                clitel.clicod = clilig.clicod 
                                    no-lock no-error.
                        if avail clitel and
                           cliTEL.teldat = vtoday
                        then do:
                            find clilig where recid(clilig) = recatu1.
                            recatu1 = ?.
                            clilig.dtultlig = today.
                            /*
                            if time - ini-time > 7200 
                            then do.
                                /*
                                hide message no-pause.
                                message "Arquivo de Ligacoes feitas a mais de"
                                            string(time - ini-time,"HH:MM:SS")
                                        ". Refazendo Arquivo para ligacoes".    
                                pause 4 no-message.
                                run cria-tt.   
                                hide message no-pause.
                                */
                            end.
                            */
                            recatu1 = ?. 
                            leave.
                        end.
                    end.
                    leave.
                end.


            end.
            else do:
            end.
        end.
        if not esqvazio
        then do:
            run frame-a.
        end.
        if esqregua
        then display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(clilig).
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
end.

procedure frame-a.

    vdivida = 0.
    for each titulo where titulo.titnat = no and
                          titulo.clifor = clilig.clicod and
                          titulo.modcod  = "CRE" and
                          titulo.titsit = "LIB" and
                          titulo.titdtven < vtoday
                    no-lock.
        vdivida = vdivida + titulo.titvlcob - titulo.titvlpag.
    end.
    vnumdias = vtoday - clilig.dtven.

    find last clitel where clitel.clicod = clilig.clicod /*and
               clitel.teldat > clilig.dtven and
              (clitel.dtpagcont < vtoday or clitel.dtpagcont = ?)*/
                 no-lock no-error.

    def var vdlig as int format "->>>9".
    vdlig = 0.
    vdatahora = "".
    def var vdataprom as date.
    vdataprom = ?.
    if avail clitel then do:
       vdatahora = (if cliTEL.teldat = vtoday
                   then "  HOJE  "
                   else string(clitel.teldat,"99/99/99")) + " " + 
                   string(clitel.telhor,"HH:MM").
        vdlig = vtoday - clitel.teldat.
        vdataprom = clitel.dtpagcont.
    end.
    def buffer bclitel for clitel.
    for each bclitel of clilig where bclitel.dtpagcont  <> ? no-lock.
         
         vdataprom = bclitel.dtpagcont.  
    end.
                
    find func of clitel no-lock no-error.
    find clien of clilig no-lock no-error.
    display
       clilig.clicod column-label "Conta"
       clilig.dtven format "99/99/99"   column-label "Maior!Atraso"
       vnumdias
       vdivida column-label "Sld Aberto" format "->>>,>>9.99"
       clitel.funcod when avail clitel column-label "- U L!Func."
                     format ">>>>>9"
       func.funnom   when avail func   column-label "T I M A  L!Nome" 
                     format "x(10)"
       vdatahora  column-label "I G A C A O -! Data  Hora" format "x(14)"
       vdataprom   column-label "Promessa" when vdataprom <> ?
          with frame frame-a 7 down centered
            row 7 title vtitle.
find clien where clien.clicod = clilig.clicod no-lock.
        display clien.clicod 
                clien.clinom 
                clien.fone   
                  trim(trim(clien.endereco[1]) + "," + 
                      trim(string(clien.numero[1]))      + " " +
                       trim(clien.compl[1])  + " " +
                       trim(clien.cidade[1]) + " " +
                            clien.ufecod[1] ) @  clien.endereco[1] 
                               
            with frame f-cliente.

end procedure.


procedure frame-asss.
display clilig.clicod 
        dtven
        with frame frame-asss 11 down centered color white/red row 5.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esq-periodo  
    then  
        find first clilig where clilig.dtven    = vdtini  and
                                clilig.dtacor    = ?      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig2
                                                no-lock no-error.

    else  
        find last clilig  where 
                                clilig.dtacor    <= vtoday - 1     and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig3
                                                 no-lock no-error.
                                             



if par-tipo = "seg" or par-tipo = "down" 
then  
    if esq-periodo  
    then  
        find next clilig  where  clilig.dtven    = vdtini and 
                                clilig.dtacor    = ?      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                use-index clilig2
                                                no-lock no-error.
    else  
        find prev clilig   where  clilig.dtacor    <= vtoday - 1     and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig3
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esq-periodo   
    then   
        find prev clilig where   clilig.dtven    = vdtini and 
                                clilig.dtacor    = ?      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                use-index clilig2  
                                        no-lock no-error.
    else   
        find next clilig where  clilig.dtacor    <= vtoday - 1      and
                                clilig.DtUltLig  < vtoday  and
                                clilig.titvlcob >= vvalini     and
                                
                                (if vetbcod = 0
                                 then true
                                 else clilig.etbcod = vetbcod) and
                                (if vrgccod = 0
                                 then true
                                 else clilig.rgccod = vrgccod) and
                                (if vmodcod = "GERAL"
                                 then true
                                 else clilig.modcod = vmodcod)
                                
                                use-index clilig3 
                                        no-lock no-error.
        
end procedure.
         
