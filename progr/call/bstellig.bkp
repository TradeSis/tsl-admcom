/**************************************************************
newtelcli.p

 criar  indice no clien

   dtven                              2 + dtven
                                        + dtlig
*************************************************************/
/*
Felipe Mattos - 26/07/2007 - solic. 15254
incluída opção para ver as ligações por faixa de datas.
Felipe Mattos - 31/07/2007 - solic. 14982
ligações feitas 
*/

{admcab.i new }
def var varqsai as char .

def var vtoday as date format "99/99/9999".
vtoday = today.


/*
vtoday = today + 1.
  */
def var vmens as char.
def var vmens2 as char.
def var i-aux as int no-undo.
vmens  = "Aguarde a Selecao de Clientes....".
vmens2 = " Sistema BS  *    *    *    *    *    *    *    *    *"
+ "   *    *".
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).
vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .

def var vdata as date.
def var vconta as int.
def var vloop as int.

def var vqtd as int.
def var vmax as int.
def buffer btitulo for titulo.
def var par-clicod  like clien.clicod.
def buffer bclien for clien.

def temp-table tt-clien
    field clicod    like clien.clicod format ">>>>>>>9"
    field titdtven  like titulo.titdtven
    index clf   is unique primary clicod asc 
    index ven   titdtven desc
                clicod asc.

def var vetbcod     like estab.etbcod.
def var vrgccod     like rgcobra.rgccod.
def var vdiasini       as int format ">>>9" label "Dias Atraso de".
def var vdiasfin       as int format ">>>9" label "ate".
def var vvalini        like titulo.titvlcob.
def var vvalfin        like titulo.titvlcob.
def var vletra          as   char.
def var vdescricao      as   char.
def var vbusca          as   char label "DIAS".
def var vendereco       like clien.endereco format "x(60)".
def var vendcom         like cpfis.endcom    format "x(60)".
def var primeiro        as   log.
def var i               as   int.
def var vdesfone        as   char.
def var vspc            as   log format "SIM/NAO".
def var reccont         as   int.
def var vinicio         as   log initial no.
def var vdatahora as char init "".

def var recatu1         as   recid.
def var recatu2         as   recid.
def var esqpos1         as   int.
def var esqpos2         as   int.
def var esqregua        as   log.
def var esqcom1         as   char format "x(12)" extent 6
      initial [" Titulos "," Acoes Cob "," Dados ",
                        " Cliente ", ""].
def var esqcom2         as   char format "x(23)" extent 2
            initial [" ",""].
def buffer bmoeda       for  moeda.
def buffer ctitulo      for  titulo.
def buffer bestab       for  estab.
def var vclicod         like clien.clicod.
def var vdivida         like titulo.titvlcob format "->>,>>>,>>9.99".
def var vnumdias        as   int    format   ">,>>9"    column-label "Dias".
def var vi as int.
/*def var vagora          as   char format "x(5)"   column-label "Hora".*/
def var vtelobs         as   char extent 4 format "x(60)".

Form
     esqcom1
     with frame f-com1 row 6 no-box no-labels side-labels column 1.
Form
     esqcom2
     with frame f-com2 row 22 no-labels no-box.

form
    clien.clicod     colon 11 format ">>>>>>>9" label "Cliente"
    clien.clinom     no-label format    "x(40)"
    vdivida           label "Divida"
    clien.ciins      label "Identidade" colon 11
    clien.ciccgc
    with frame fclien row 14 title " Cliente " color white/cyan width 80
                       side-labels.

form clien.clicod format ">>>>>>>9"
     clien.clinom no-label format "x(40)"
     clien.endereco label "End"
     clien.fone format "x(15)"
     with frame f-cliente
        width 80 no-box row 3 side-labels color messages.
        
 form i-aux column-label "Verificando as ligações no período"
      with centered frame f-msg.

   assign
      vdiasini = 1
      vdiasfin = 0.

def var vagendadas as log format "Agendados/Nao realizadas".
def var vperiodo as log.
def var vtipos as char   format "x(30)" extent 3
    init [ /*
          " 1)  11 A 11 DIAS ", 
          " 2)  25 A 25 DIAS ",
          " 3)  40 A 40 DIAS ",
          " 4)  55 A 55 DIAS ",
          " 5)  AGENDADOS    ",
          " 6)  PERIODO LIVRE " ,  */
          "   FEITAS NO DIA ",
/*          " 2)  NAO FEITAS DIA ANTERIOR ",*/ "",
          "   POR DATA "
          ].

repeat with frame f-filtro side-labels  no-box row 3.
    assign esqregua = yes esqpos1  = 1 esqpos2  = 1 recatu1  = ?.
    vetbcod = 0. /*setbcod.*/
    find estrgcobra where estrgcobra.etbcod = vetbcod no-lock no-error.
    vrgccod = if avail estrgcobra
              then estrgcobra.rgccod
              else 1.
    vperiodo  = no.   
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
    update vvalini  label "Valor Inicial"
           vvalfin label "Final".
    DISPLAY VTIPOS[1] skip 
            vtipos[2] skip 
            vtipos[3] /*skip 
            vtipos[4] skip 
            vtipos[5] skip 
            vtipos[6] skip 
            vtipos[7] SKIP
            vtipos[8] skip
            vtipos[9]   */
            WITH FRAME FTIPOS 
                    NO-LABEL row 6 centered
                        title " Filtros ". 
        CHOOSE field vtipos auto-return with frame ftipos .
        def var vtitle as char.
        def var ctipos as char.
        
    ctipos = vtipos[frame-index].
    
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
    vperiodo = ?.
    vlivre = ?.
    vdodia = no.
    if frame-index = 10
    then assign vdiasini = 11
                vdiasfin = 11 
                vperiodo = yes
                vagendadas = no.        
    else
    if frame-index = 20
    then assign vdiasini = 25
                vdiasfin = 25 
                vperiodo = yes
                vagendadas = no.        
    else
    if frame-index = 30
    then assign vdiasini = 40
                vdiasfin = 40 
                vperiodo = yes
                vagendadas = no.        
    else
    if frame-index = 40
    then assign vdiasini = 55
                vdiasfin = 55 
                vperiodo = yes
                vagendadas = no.        
    else
    if frame-index = 50
    then assign vdiasini = 0
                vdiasfin = 0 
                vperiodo = no
                vagendadas   = yes.        
    else
    if frame-index = 60
    then do:
        update vdiasini
               vdiasfin with frame ffff  row 5 side-label
                            no-box .
        vlivre = yes.
        vagendadas   = no.
    end.             
    else
    if frame-index = 1   /* era 7 */
    then assign vdiasini = ?
                vdiasfin = ? 
                vdodia = yes
                vagendadas   = ?.        
    else
    if frame-index = 2       /* era 8 */
    then assign vdiasini = ?
                vdiasfin = ? 
                vdiaanterior = yes
                vagendadas   = ?.        
           
    if frame-index = 3 /*por faixa de datas*/     /* era 9 */
    then do:
       assign dt-ini = today
              dt-fim = today.
       
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
                  vdiasfin      = ?
                  vagendadas    = ?
                  vdiaanterior  = ?.
              
           hide frame f-data-aux no-pause.
          
       end.
      
       
    end.      
    hide frame f-data-aux no-pause.   
    hide frame f-filtro no-pause.
                
    if keyfunction(lastkey) = "end-error"
    then return.

    def var ini-time as int.       
            
    run cria-tt.
    
    hide frame f-msg no-pause.

bl-princ:
repeat :

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then find first tt-clien use-index ven     
                no-error.
    else find tt-clien where recid(tt-clien) = recatu1 no-lock.

    vinicio = no.
    if not available tt-clien
    then leave.
    clear frame frame-a all no-pause.
    clear frame telobs  all no-pause.

    run frame-a.

    find clien where clien.clicod = tt-clien.clicod no-lock.
    display clien.clicod clien.clinom clien.fone
              trim(trim(clien.endereco[1]) + "," + 
                  trim(string(clien.numero[1]))      + " " +
                       trim(clien.compl[1])  + " " +
                       trim(clien.cidade[1]) + " " +
                            clien.ufecod[1] ) @             clien.endereco[1]  
                            
            with frame f-cliente.

    recatu1 = recid(tt-clien).
    if esqregua
    then do:
        display esqcom1[esqpos1] with frame f-com1.
        color  display message esqcom1[esqpos1] with frame f-com1.
    end.
    else do:
        display esqcom2[esqpos2] with frame f-com2.
        color display message esqcom2[esqpos2] with frame f-com2.
    end.
    repeat:
        find next tt-clien 
                use-index ven
                no-error.
        if not available tt-clien
        then leave.

        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        if not vinicio
        then down with frame frame-a.

        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:
    

        find tt-clien where recid(tt-clien) = recatu1 no-lock.
        find clien where
                clien.clicod = tt-clien.clicod no-lock.
        vclicod = clien.clicod.

        assign vtelobs = "".

        find last clitel where clitel.clicod = clien.clicod
                           no-lock no-error.
        if avail clitel 
        then do:
           find tipcont of clitel no-lock no-error.
           vtelobs[1] = substr(string(clitel.teldat,"99/99/99"),1,5) + " " +
                        string(clitel.telhor,"HH:MM") + " " + 
                        string(clitel.codcont) + " - " + 
                        (if avail tipcont then tipcont.desccont else "").
           vtelobs[1] = vtelobs[1] + " -OBS:" +  clitel.telobs[1] + " " +
                        clitel.telobs[2] + " "  +  clitel.telobs[3].
        end.
        do i = 2 to 4:
           find prev clitel where clitel.clicod = clien.clicod
                           no-lock no-error.
           if avail clitel
           then do:
              find tipcont of clitel no-lock no-error.
              vtelobs[i] = substr(string(clitel.teldat,"99/99/99"),1,5) + " " +
                           string(clitel.telhor,"HH:MM") + " " + 
                           string(clitel.codcont) + " - " + 
                           (if avail tipcont then tipcont.desccont else "").
              vtelobs[i] = vtelobs[i] + " -OBS:" + clitel.telobs[1] + " " +
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
        if esqcom1[esqpos1] <> " Telefonando "
        then choose field tt-clien.clicod help ""
            go-on(cursor-down cursor-up cursor-left cursor-right
            page-down page-up F1 PF1 PF4 F4 ESC return 1 2 3 4 5 6 7 8 9 0 
                            h H).
        status default "".
        if lastkey =  401 /*-1*/
        then do:
            leave.
        end.
        if keyfunction(lastkey) = "H" or
           keyfunction(lastkey) = "h"
        then do.
            hide frame f-com1 no-pause. 
            run bscrclitel.p ( input recid(clien), 
                                  input recid(clilig)).
            view frame f-com1.
            next bl-princ.
        end.
        vletra = lc(keyfunction(lastkey)).
        if keyfunction(lastkey) = "0" or
           keyfunction(lastkey) = "1" or
           keyfunction(lastkey) = "2" or
           keyfunction(lastkey) = "3" or
           keyfunction(lastkey) = "4" or
           keyfunction(lastkey) = "5" or
           keyfunction(lastkey) = "6" or
           keyfunction(lastkey) = "7" or
           keyfunction(lastkey) = "8" or
           keyfunction(lastkey) = "9"
        then do with frame fbusca
                    centered color normal side-labels row 10 overlay:
            vbusca = keyfunction(lastkey).
            primeiro = yes.
            update vbusca
                editing:
                    if primeiro
                    then do:
                        apply keycode("cursor-right").
                        primeiro = no.
                    end.
                readkey.
                apply lastkey.
            end.
            /* update vbusca.*/
            find last tt-clien where 
                      tt-clien.titdtven <= vtoday - int(vbusca)  and
                      tt-clien.titdtven >  vtoday - 9999 
                                     no-lock no-error.
            if avail tt-clien
            then recatu1 = recid(tt-clien).
            else do on endkey undo:
                bell.
                message "Nao Existe Cliente com este atraso!!!".
                pause 5 message "Pressione Qualquer Tecle Para Continuar".
            end.
            leave.
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
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
            end.
            else do:
                color display normal esqcom2[esqpos2] with frame f-com2.
                esqpos2 = if esqpos2 = 2 then 2 else esqpos2 + 1.
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
        if keyfunction(lastkey) = "cursor-down"
        then do:
            find next tt-clien use-index ven no-error.
            if not avail tt-clien
            then next.
            if frame-line(frame-a) = frame-down(frame-a)
            then scroll with frame frame-a.
            else down with frame frame-a.
        end.
        if keyfunction(lastkey) = "cursor-up"
        then do:
            find prev tt-clien use-index ven no-error.
            if not avail tt-clien
            then next.
            if frame-line(frame-a) = 1
            then scroll down with frame frame-a.
            else up with frame frame-a.
        end.
        if keyfunction(lastkey) = "page-down"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find next tt-clien use-index ven no-error.
                if not avail tt-clien
                then leave.
                recatu1 = recid(tt-clien).
            end.
            leave.
        end.
        if keyfunction(lastkey) = "page-up"
        then do:
            do reccont = 1 to frame-down(frame-a):
                find prev tt-clien use-index ven no-error.
                if not avail tt-clien
                then leave.
                recatu1 = recid(tt-clien).
            end.
            leave.
        end.

        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return"
        then do on error undo, retry on endkey undo, leave.
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
            hide frame f-com2 no-pause.
          end.
          view frame frame-a .
        end.
        if keyfunction(lastkey) = "end-error"
        then view frame frame-a.

        run frame-a.
        recatu1 = recid(tt-clien).
   end.
end.
hide frame fclien no-pause.
hide frame fres    no-pause.
hide frame frame-a no-pause.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame f-cliente no-pause.
end.

/*
PROCEDURE cria-tt.
ini-time = time.
for each tt-clien.
   delete tt-clien.
end.
vqtd = 0. 

for each rgcobra where (if vrgccod = 0 
                        then true
                        else rgcobra.rgccod = vrgccod ) no-lock.
    if vetbcod = 0
    then  
        for each estrgcobra of rgcobra no-lock.
            /***********
            if setbcod >= 100 or setbcod = 37   or
               setbcod = 33   or setbcod = 40   or
               setbcod = 2    or setbcod = 44
            then.
            else              
                if estrgcobra.etbcod <> 42 and estrgcobra.etbcod <> 3  and 
                   estrgcobra.etbcod <> 2  and estrgcobra.etbcod <> 1  and
                   estrgcobra.etbcod <> 51 and estrgcobra.etbcod <> 25 and 
                   estrgcobra.etbcod <> 30 and estrgcobra.etbcod <> 34 and 
                   estrgcobra.etbcod <> 22 
                then next.
            if setbcod = 37 and estrgcobra.etbcod <> 37 then next.
            if setbcod = 33 and estrgcobra.etbcod <> 33 then next.
            if setbcod = 40 and estrgcobra.etbcod <> 40 then next.
            if setbcod = 2  and estrgcobra.etbcod <> 2  then next.
            if setbcod = 44 and estrgcobra.etbcod <> 44 then next.
            ********/
            message "Aguarde. Processando loja " estrgcobra.etbcod.

            run leitura-titulos.
        end.
    else
        for each estrgcobra where estrgcobra.etbcod = vetbcod no-lock.
            /*************
            if setbcod >= 100 or setbcod = 37   or
               setbcod = 33   or setbcod = 40   or
               setbcod = 2    or setbcod = 44
            then.
            else              
                if estrgcobra.etbcod <> 42 and estrgcobra.etbcod <> 3  and 
                   estrgcobra.etbcod <> 2  and estrgcobra.etbcod <> 1  and
                   estrgcobra.etbcod <> 51 and estrgcobra.etbcod <> 25 and 
                   estrgcobra.etbcod <> 30 and estrgcobra.etbcod <> 34 and 
                   estrgcobra.etbcod <> 22 
                then next.
            if setbcod = 37 and estrgcobra.etbcod <> 37 then next.
            if setbcod = 33 and estrgcobra.etbcod <> 33 then next.
            if setbcod = 40 and estrgcobra.etbcod <> 40 then next.
            if setbcod = 2  and estrgcobra.etbcod <> 2  then next.
            if setbcod = 44 and estrgcobra.etbcod <> 44 then next.            
            **************/
            message "Aguarde. Processando loja " estrgcobra.etbcod.
            run leitura-titulos.
        end.
end.
vtitle = ctipos  + "QDT CLIENTES = " + string(vqtd).
end procedure.
***/
 
procedure cria-tt.
vqtd = 0.
vmens  = "Aguarde a Selecao de Clientes....".
vmens2 = " Sistema BS  *    *    *    *    *    *    *    *    *"
+ "   *    *".
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).
vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .

for each tt-clien.
    delete tt-clien.
end.

if vlivre
then do.
    /*
    def var vdtini as date.
    def var vdtfin as date.
    
    vdtini = today - vdiasfin.
    vdtfin = today - vdiasini.
    
    def var d as date.        
        do d = vdtini to vdtfin.
            for each clilig where clilig.dtven = d no-lock.
                if vetbcod = 0
                then do.
                    if vrgccod = 0
                    then .
                    else do.
                       find estab where estab.etbcod = clilig.etbcod no-lock.
                       find  estrgcobra of estab no-lock.
                       if vrgccod <> estrgcobra.rgccod
                       then next.
                    end.
                end.
                else do.
                    find estab where estab.etbcod = clilig.etbcod no-lock.
                    if vetbcod <> estab.etbcod
                    then next.
                end.
        
                find titulo where titulo.titcod = clilig.titcod no-lock 
                    no-error.
                if avail titulo and
                   titulo.titdtpag <> ?
                then next. 
                if avail titulo 
                then do.  
                    if titulo.titvlpag >= titulo.titvlcob
                    then next.
                    
                    if titulo.titvlcob >= vvalini and  
                       titulo.titvlcob <= vvalfin  
                    then. 
                    else next. 
                end.
                if vetbcod = 0 
                then . 
                else if clilig.etbcod = vetbcod
                                    then .
                                    else next.
                find tt-clien where tt-clien.clicod = clilig.clicod no-error.
                if not avail tt-clien
                then do.
                    create tt-clien.                     
                    vqtd = vqtd + 1.
                end.            
                assign tt-clien.clicod = clilig.clicod  
                       tt-clien.titcod = if avail clilig
                                          then clilig.titcod
                                          else ?
                       tt-clien.titdtven = if avail clilig
                                            then clilig.dtven
                                            else ?.     
            end.
        end.
    */
end.
else
if vdiaanterior
then do.
    for each clilig where clilig.dtproxlig < vtoday no-lock
                            by dtven desc.
        if vetbcod = 0
        then do.
            if vrgccod = 0
            then .
            else do.
               find estab where estab.etbcod = clilig.etbcod no-lock.
               find  estrgcobra of estab no-lock.
               if vrgccod <> estrgcobra.rgccod
               then next.
            end.
        end.
        else do.
            find estab where estab.etbcod = clilig.etbcod no-lock.
            if vetbcod <> estab.etbcod
            then next.
        end.

        find titulo where titulo.clifor = clilig.clicod no-lock no-error.
        if avail titulo and
           titulo.titdtpag <> ?
        then next. 
        if avail titulo 
        then do.  
            if titulo.titvlpag >= titulo.titvlcob
            then next.
            
            if titulo.titvlcob >= vvalini and  
               titulo.titvlcob <= vvalfin  
            then. 
            else next. 
        end.
        if vetbcod = 0 
        then . 
        else if clilig.etbcod = vetbcod
                            then .
                            else next.
        find tt-clien where tt-clien.clicod = clilig.clicod no-error.
        if not avail tt-clien
        then do.
            create tt-clien.                     
            vqtd = vqtd + 1.
        end.            
        assign tt-clien.clicod = clilig.clicod  
               tt-clien.titdtven = if avail clilig
                                    then clilig.dtven
                                    else ?.     
    end.        
end.
else 
if vdodia
then do.
    
    for each clitel where clitel.teldat = vtoday no-lock.
        find clien of clitel no-lock.
        find clilig where clilig.clicod = clien.clicod no-lock no-error.
        if not avail clilig then next.
        /*
        find titulo where titulo.titcod = clilig.titcod no-lock no-error.
        if avail titulo
        then do. 
            if titulo.titvlpag >= titulo.titvlcob
            then next.
            
            if titulo.titvlcob >= vvalini and 
               titulo.titvlcob <= vvalfin 
            then.
            else next.
        end.
        */
        if vetbcod = 0
        then do.
            if vrgccod = 0
            then .
            else do.
               find estab where estab.etbcod = clilig.etbcod no-lock no-error.
               find  estrgcobra of estab no-lock.
               if vrgccod <> estrgcobra.rgccod
               then next.
            end.
        end.
        else do.
            find estab where estab.etbcod = titulo.etbcod no-lock.
            if vetbcod <> estab.etbcod
            then next.
        end.
        find tt-clien where tt-clien.clicod = clitel.clicod no-error.
        if not avail tt-clien
        then do.
            create tt-clien.                     
            vqtd = vqtd + 1.
        end.            
        assign tt-clien.clicod = clitel.clicod  
               tt-clien.titdtven = if avail clilig
                                    then clilig.dtven
                                    else ?.     
    end.
end.
else 
if v-faixa-datas
then do:
   assign i-aux = 0.
    for each clitel where 
             clitel.teldat >= dt-ini
         and clitel.teldat <= dt-fim
             no-lock:
          i-aux = i-aux + 1.   

          disp i-aux with frame f-msg.

        for first clien of clitel 
                  no-lock: end.
                  
        for first clilig where 
                  clilig.clicod = clien.clicod 
                  no-lock: end.

        if not avail clilig 
        then next.
        
        /*
        for first titulo where 
                  titulo.titcod     = clilig.titcod 
              and titulo.titvlcob  >= vvalini
              and titulo.titvlcob  <= vvalfin
              and titulo.titvlpag  <= titulo.titvlcob
                  no-lock: end.
                  
        if not avail titulo
        then next.
        */
        if vetbcod = 0
        then do:
        
            if vrgccod <> 0
            then do:
            
               for first estab where 
                         estab.etbcod = clilig.etbcod 
                         no-lock: end.

               for first estrgcobra of estab where
                         estrgcobra.rgccod = vrgccod
                         no-lock: end.
                         
               if not avail estrgcobra         
               then next.          
              
            end.
            
        end.
        
        else do:
        
            for first estab where 
                      estab.etbcod  = titulo.etbcod 
                 and  estab.etbcod  = vetbcod
                      no-lock: end.
                      
             if not avail estab
             then next.
        
        end.

        for first tt-clien where 
                  tt-clien.clicod = clitel.clicod 
                  no-lock: end.
             
        if not avail tt-clien
        then do.
            create tt-clien.                     
            assign vqtd = vqtd + 1.
        end. 
                   
        assign tt-clien.clicod   = clitel.clicod  
               tt-clien.titdtven = if avail clilig
                                    then clilig.dtven
                                    else ?.     
    end.

end.

else do.
/*
for each clilig where clilig.dtproxlig = vtoday no-lock.
        if vetbcod = 0
        then do.
            if vrgccod = 0
            then .
            else do.
               find estab where estab.etbcod = clilig.etbcod no-lock.
               find  estrgcobra of estab no-lock.
               if vrgccod <> estrgcobra.rgccod
               then next.
            end.
        end.
        else do.
            find estab where estab.etbcod = clilig.etbcod no-lock.
            if vetbcod <> estab.etbcod
            then next.
        end.
    
    find titulo where titulo.titcod = clilig.titcod no-lock no-error.
    if avail titulo and
       titulo.titdtpag <> ?
    then next. 
    if avail titulo 
    then do.   
    
        if titulo.titvlpag >= titulo.titvlcob 
        then next.
            
        if titulo.titvlcob >= vvalini and  
           titulo.titvlcob <= vvalfin  
        then. 
        else next. 
    end.
    if vetbcod = 0 
    then . 
    else if clilig.etbcod = vetbcod
                        then .
                        else next.
    if true /*vperiodo = yes*/
    then do.
        if vperiodo
        then
            if vtoday - clilig.dtven <>  vdiasini and
               vtoday - clilig.dtven <>  vdiasfin 
            then next.
        if vlivre 
        then do:
                          
             if vtoday - clilig.dtven >= vdiasini and   
                vtoday - clilig.dtven <= vdiasfin
             then.
             else next.   
         end.
        if true /*vagendadas = no*/
        then do.
   
            find last clitel where clitel.clicod = clilig.clicod and
                       clitel.teldat > clilig.dtven and
                      (clitel.dtpagcont < vtoday or clitel.dtpagcont = ?)
                         no-lock no-error.
                            
            def var vdlig as int format "->>>9".
            vdlig = 0.
            vdatahora = "".
            def var vdataprom as date.
            vdataprom = ?.
            if avail clitel then do: 
                vdataprom = clitel.dtpagcont.
            end.    
            if vagendadas = no
            then do. 
    
                if vdataprom <> ? 
                then next.
            end.
            else do.
                    
                if clilig.dtven >= vtoday - 11
                then next. 
                                
                if vdataprom <> ? and
                   vdataprom = vtoday - 1
                then.
                else if weekday(vtoday) = 2 and  /*sabado */
                        vdataprom <> ? and
                        vdataprom = vtoday - 2   
                     then.
                     else next.                        
                     
            end.
        end.
    end.       
    find last clitel where clitel.clicod = clilig.clicod /*and
              (clitel.dtpagcont < vtoday or clitel.dtpagcont = ?)*/
                 no-lock no-error.
                           
    if avail clitel
    then do:

        if clitel.codcont = 1 /*ocupado*/
        or clitel.codcont = 2 /*não atende*/
        then if clitel.teldat >= (vtoday - 3) 
             then next.
    
        if cliTEL.teldat = vtoday
        then next.  
     end.


    create tt-clien.                     
    assign tt-clien.clicod = clilig.clicod  
           tt-clien.titcod = clilig.titcod        
           tt-clien.titdtven = clilig.dtven.     
   
    vqtd = vqtd + 1.

                /* MENSAGEM NA TELA */
                    vloop = vloop + 1.
                    if vloop mod 50 = 0
                    then do:
                        put screen color messages  row 15  column 1 vmens.
                        vmens = substring(vmens,2,78) +
                                substring(vmens,1,1).

                    end.
                    if vloop > 50
                    then do:
                        put screen color normal    row 16  column 1 vmens2.
                        put screen color messages  row 17  column 15
                        " Decorridos : " + string(time - vtime,"HH:MM:SS")
                               + " Minutos    - Lidos " +
                               string(vqtd,"zzzzz9") + " Registros ".
                        
                        vmens2 = substring(vmens2,2,78) +
                                substring(vmens2,1,1).
                        vloop = 0.
                    end.



end. */
end.
vtitle = ctipos  + "QDT CLIENTES = " + string(vqtd).
    vmens  = "".
    vmens2 = "".
    put screen color normal    row 16  column 1 vmens2. 
    put screen color normal    row 15  column 1 vmens.
    put screen color normal    row 17  column 1 vmens.

end procedure.

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

/*
procedure p-imp.

    def var cTitRel as char.
    if opsys = "UNIX"
    then varqsai =  "../impress/telcli" + string(time).
    else varqsai =  "..~\impress~\telcli" + string(time).
    
    cTitRel = "REGISTRO DE TELEFONEMAS  ".

    {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "136"
        &Page-Line = "66"
        &Nom-Rel   = ""telcli""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = "cTitRel"
        &Width     = "136"
        &Form      = "frame f-cabcab"}

for each tt-clien.

    vdivida = 0.
    for each titulo where titulo.titnat = no and
                          titulo.clicod = tt-clien.clicod and
                          titulo.titdtpag = ? 
                    no-lock.
        vdivida = vdivida + titulo.titvlcob - titulo.titvlpag.
    end.
    vnumdias = vtoday - tt-clien.titdtven.

    find last clitel where clitel.clicod = tt-clien.clicod
                 no-lock no-error.
  
    vdatahora = "".
    if avail clitel then
       vdatahora = (if cliTEL.teldat = vtoday
                   then "  HOJE  "
                   else string(clitel.teldat,"99/99/99")) + " " + 
                   string(clitel.telhor,"HH:MM").

    find func of clitel no-lock no-error.
    find clien of tt-clien no-lock no-error.
    display
       tt-clien.clicod column-label "Conta" format ">>>>>>>9"
       clien.clinom
       clien.fone
       tt-clien.titdtven format "99/99/99"   column-label "Maior Atraso"
       vnumdias                 
       vdivida column-label "Divida Total"
       clitel.funcod when avail clitel column-label "- U L!Func."
                     format ">>>>>9"
       func.funnom   when avail func   column-label "T I M A  L!Nome" 
                     format "x(10)"
       vdatahora  column-label "I G A C A O -! Data  Hora" format "x(14)"
       with frame f-linha width 138 down.
end.

    {mdadmrod.i
        &copias = 1
        &Saida     = "value(varqsai)"}

end procedure.
*/
/*
procedure p-impficha.

   def input parameter par-clicod like clien.clicod.

   def var cTitRel as char.
   def var vsaldo           like titulo.titvlcob.
   def var vsaldoatualizado like titulo.titvlcob.
   def var vperc            as dec.
   def var vvalormulta      as dec.
   def var vatraso          as int.

   if opsys = "UNIX"
   then varqsai =  "../impress/telcli" + string(time).
   else varqsai =  "..~\impress~\telcli" + string(time).
    
   cTitRel = "FICHA DE COBRANCA  " .
   {mdadmcab.i
        &Saida     = "value(varqsai)"
        &Page-Size = "64"
        &Cond-Var  = "96"
        &Page-Line = "66"
        &Nom-Rel   = ""telcli""
        &Nom-Sis   = """BS"""
        &Tit-Rel   = "cTitRel"
        &Width     = "96"
        &Form      = "frame f-cabcab"}

   for each tt-clien where (if par-clicod > 0
                             then tt-clien.clicod = par-clicod
                             else true).
      find clien of tt-clien no-lock.
      put unformatted
          " Cliente: " clien.clicod " " clien.clinom  
          "  CPF/CNPJ: " clien.ciccgc skip
          "Endereco: " string(clien.endereco + " " + clien.numero + " " +
                              clien.compl, "x(50)") " "
                       clien.bairro " " clien.cep clien.ufecod skip
          skip.

      vdivida = 0.
      for each titulo where titulo.titnat = no and
                            titulo.clicod = tt-clien.clicod and
                            titulo.titdtpag = ? 
                      no-lock
                      break by titulo.etbcod
                            by titulo.titnum
                            by titulo.titpar.
         assign
            vsaldo           = titulo.titvlcob - titulo.titvlpag
            vsaldoatualizado = titulo.titvlcob - titulo.titvlpag
            vatraso          = 0.

         if vtoday > titulo.titdtven then do: 
            run fbjuro.p (input titulo.cobcod, 
                          input titulo.carcod, 
                          input titulo.titnat, 
                          input vsaldo, 
                          input titulo.titdtven, 
                          input vtoday, 
                          output vsaldoatualizado, 
                          output vperc) .

            run fbmulta.p (input titulo.cobcod,  
                           input titulo.carcod,  
                           input titulo.titnat,  
                           input titulo.titvlcob ,  
                           input titulo.titdtven,  
                           input vtoday,  
                           output vvalormulta) .
            vatraso = vtoday - titulo.titdtven.
         end.
         disp titulo.etbcod column-label "Etb" format ">>9"
              {titnum.i}
              titulo.titdtven format "99/99/99"
              vatraso column-label "Dias" format ">>>9" 
              titulo.titvlcob
              titulo.titvlpag
              vsaldo           column-label "Saldo" when vsaldo > 0
              vsaldoatualizado - vsaldo + vvalormulta column-label "Juro/Multa"
              format ">>>>>,>>9.99"
              vsaldoatualizado + vvalormulta column-label "Total"
              format ">>>>>,>>9.99"
              with frame f-ficha  down width 96 no-box.

         vdivida = vdivida + titulo.titvlcob - titulo.titvlpag.
      end.

      for each clitel where clitel.clicod = tt-clien.clicod
                 no-lock.

         vdatahora = substr(string(clitel.teldat,"99/99/99"),1,5) + " " +
                     string(clitel.telhor,"HH:MM").

         find tipcont of clitel no-lock no-error.
         disp vdatahora        column-label "Data" format "x(11)"
              clitel.funcod
              clitel.codcont   column-label "Tipo" format ">>>9"
              tipcont.desccont column-label "Historico" when avail tipcont
              clitel.dtpagcont column-label "Data" format "99/99/99"
              clitel.fonecont  column-label "Fone"  
              with frame f-relclitel down centered width 80.
      end.

      put
         skip(2)
         "Assinatura cliente: ________________________________________"
         skip(1)
         "Hora cobranca: ___:___     Cobrador: _______________________"
         skip(1)
         "Negociacao: ________________________________________________________"
         skip(1)
         "____________________________________________________________________"
         skip(1)
         .
      page.
   end.

   {mdadmrod.i
        &copias = 1
        &Saida     = "value(varqsai)"}

end procedure.
*/

/*
procedure leitura-titulos.
    def var vcont as int.
    vcont = 0.
    if vdiasini = ? and 
       vdiasfin = ? and 
       vagendadas   = ? 
    then do: 
        for each clitel  where clitel.teldat = vtoday no-lock.
            find first tt-clien where
                    tt-clien.clicod = clitel.clicod
                    no-error.
            if not avail tt-clien
            then do:
                vtitcod = ?. 
                for first titulo where titulo.titnat = no and
                              titulo.clicod = clitel.clicod and
                              titulo.titdtpag = ? and
                              titulo.titdtven < vtoday
                                        no-lock by titulo.titdtven.
                    vtitcod = titulo.titcod.
                end.                
                create tt-clien.
                assign
                    tt-clien.clicod = clitel.clicod
                    tt-clien.titcod = vtitcod
                    tt-clien.titdtven = vtoday.
                vqtd = vqtd + 1.
            end.                    
        end.
    end. 
    else do.
        for each titulo /*use-index por-dtpag-uo-modal*/
                            where
                        titulo.titnat = no and
                        (titulo.modcod = "CLI" or
                         titulo.modcod = "GE") and
                        titulo.etbcod = estrgcobra.etbcod and
                        titulo.titdtpag = ? and
                        
                        (if vagendadas = yes
                         then true
                         else titulo.titdtven <= vtoday - vdiasini) 
                        no-lock.
            find clien of titulo no-lock no-error.
            if not avail clien then next. 
            vmax = vtoday - titulo.titdtven.
            for each btitulo where
                btitulo.titnat = titulo.titnat and
                btitulo.etbcod = titulo.etbcod and
                btitulo.modcod = titulo.modcod and
                btitulo.clicod = titulo.clicod and
                btitulo.titnum = titulo.titnum and
                btitulo.titdtpag = ?
                no-lock.
                vmax = max(vmax,vtoday - titulo.titdtven).
            end.
                /* Luciane - 13/02/2007 - 13427 */
                if vmax >= 60 and vlivre = no
                  then next. /* solic 10339, helio */
            if vtoday - titulo.titdtven < 11
                then next. /* solic 10340 */
                
            vcont = vcont + 1.
            
            if vcont mod 1000 = 0
            then do:          /*
                hide message no-pause.
                message "Aguarde..." vcont. */
            end.
            
            if vagendadas = ?  /*  por faixa */
            then
                if vdiasfin > 0 and titulo.titdtven < vtoday - vdiasfin then
                   next.
            if vagendadas = no   /* ligacoes que  de ontem */
            then do:         /* que deveriam ser feitas */
                if vtoday - titulo.titdtven <> 12 and
                   vtoday - titulo.titdtven <> 26 and
                   vtoday - titulo.titdtven <> 41 and
                   vtoday - titulo.titdtven <> 56
                then next.   
                
                do:
                    find last clitel of clien 
                            where clitel.teldat = vtoday - 1
                                    no-lock no-error.
                    if avail clitel 
                    then next.
                end.
            end.
            if vagendadas = yes  /* acordo nao cumprido */
            or vagendadas = no
            then do:
            
                def var vdtacor as date format "99/99/9999".
                vdtacor = 01/01/0001.
                for each clitel of clien 
                    where clitel.teldat >= titulo.titdtven and
                          /* Luciane - 13/02/2007 - 10337 */
                          (clitel.dtpagcont < vtoday or 
                           clitel.dtpagcont = ?)
                        no-lock.
                        
                    find tipcont of clitel no-lock.
                    if tipcont.mdata = no then next.
                    vdtacor = max(vdtacor,clitel.dtpagcont).
                end.
                if vdtacor - titulo.titdtven < 11 then next.
                if vdtacor = 01/01/0001 then next.
                if vdtacor >= vtoday
                then next.
            end.
            find clien of titulo no-lock no-error.
            if not avail clien then next.
            if vprofcod <> 0 and clien.profcod <> vprofcod then next.
            if titulo.titvlcob >= vvalini and
               titulo.titvlcob <= vvalfin
            then.
            else next.
            find last clitel of clien  no-lock no-error.
            
            if avail clitel and
               cliTEL.teldat = vtoday 
               
               then.  /* next.*/
            /* aqui */
            if avail clitel
            then do:
                def var vdlig as int.
                vdlig = 0. 
                vdlig = vtoday - clitel.teldat.
                
                if vtoday - titulo.titdtven = 11 and
                   vdlig < 14
                then 
                    if ( clitel.teldat = vtoday and time - clitel.telhor > 7200
                        and clitel.codcont = 1  )
                     then. 
                     else next.
                
                if vtoday - titulo.titdtven = 25 and
                   vdlig < 15 
                then if ( clitel.teldat = vtoday and time - clitel.telhor > 7200
                        and clitel.codcont = 1  )
                     then. 
                     else next.   
                
                if vtoday - titulo.titdtven = 40 and
                   vdlig < 15 
                then if ( clitel.teldat = vtoday and time - clitel.telhor > 7200
                        and clitel.codcont = 1  )
                     then. 
                     else next.   
                
                if vtoday - titulo.titdtven = 55 and
                   vdlig < 15 
                then if ( clitel.teldat = vtoday and time - clitel.telhor > 7200
                        and clitel.codcont = 1  )
                     then. 
                     else next. 
            end.
            
            def var vcria as log.
            def buffer xtitulo for titulo.
            vcria = yes.
            if vlivre =no
            then
                for each xtitulo where xtitulo.titnat   = no              and
                                       xtitulo.clicod   = titulo.clicod   and
                                       xtitulo.titdtpag = ?               and
                                      (xtitulo.modcod   = "CLI" or
                                       xtitulo.modcod   = "GE")
                                        no-lock.
                    if vtoday - xtitulo.titdtven >= 60
                    then vcria = no. 
                end.
            if setbcod < 100 
            then do:
                run buscanova.p (input titulo.clicod,
                                 input-output vcria).
            end.
                       
            if vcria 
            then do:
                find first tt-clien where
                        tt-clien.clicod = titulo.clicod
                        no-error.
                if not avail tt-clien
                then do:
                    create tt-clien.
                    assign
                        tt-clien.clicod = titulo.clicod
                        tt-clien.titdtven = vtoday
                        tt-clien.titcod = titulo.titcod.
                    vqtd = vqtd + 1.
                end.                    
                tt-clien.titdtven = min(titulo.titdtven,tt-clien.titdtven).
            end.
        end.        
    end.       
    hide message no-pause.

end procedure.*/

