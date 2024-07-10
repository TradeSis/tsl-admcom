/*************************INFORMA€OES DO PROGRAMA****************************** ***** Nome do Programa             : convgenw.p
*******************************************************************************/


{admcab.i}
{anset.i}.

def var vdt-aux as date format "99/99/9999".

def var vi as int.
def var aux-i as int.
def var aux-etbcod like estab.etbcod.

def var vcont as int.
def var vdiastot as int.
def new shared var vdiasatu as int.
def buffer bestab for estab.
 
def var vdia as int.
def var vmes as int format "99".
def var vano as int format "9999".
def var vmesfim as int.
def var vanofim as int.
def var vdiafim as int.

def var v-totcom    as dec.
DEF VAR v-totperc   AS DEC.
def var v-totalzao  as dec.
def var vhora       as char.
def var vok as logical.
def var vquant like movim.movqtm.
def var flgetb      as log.
def var vmovtdc     like tipmov.movtdc.
def var v-totaldia  as dec.
def var v-total     as dec.
def var v-totdia    as dec.
def var v-nome      like estab.etbnom.
def var d           as date.
def var i           as int.
def var v-qtd       as dec.
def var v-tot       as dec.
def var v-dif       as dec.
def var v-valor     as dec decimals 2.
def var vetbcod     like plani.etbcod           no-undo.
def var v-totger    as dec.

def new shared      var vdti        as date format "99/99/99" no-undo.
def new shared      var vdtf        as date format "99/99/99" no-undo.

def var p-vencod     like func.funcod.
def new shared var p-loja      like estab.etbcod.
def var p-setor     like setor.setcod.
def var p-grupo     like clase.clacod.
def var p-clase     like clase.clacod.
def var p-sclase    like clase.clacod.
def var v-titset    as char.
def var v-titgru    as char.
def var v-titcla    as char.
def var v-titscla   as char.
def var v-titvenpro as char.
def var v-titven    as char.
def var v-titpro    as char.
def var v-perdia    as dec label "% Dia".
def var v-perc      as dec label "% Acum".
def var v-percproj  as dec.
def var v-perdev    as dec label "% Dev" format ">9.99".

def buffer sclase   for clase.
def buffer grupo    for clase.

def new shared temp-table ttloja
    field etbcod        like estab.etbcod
    field nome          like estab.etbnom 
    field qtdmerca      as int /*like proenoc.qtdmerca*/
                column-label "Total"
    field qtdmercaent   as int /*like proenoc.qtdmercaent*/
                column-label "Entregue"
    field qtdsaldo      as int /*like proenoc.qtdmerca*/
                column-label "Saldo"
    field qtdatrasado   as int /*like proenoc.qtdmerca*/ column-label "Atrasado"
    field qtdposterior  as int /*like proenoc.qtdmerca*/
                column-label "Posterior"
    field vlrsaldo      as dec 
    field vlratrasado   as dec 
    
    index loja     is unique etbcod asc
    index totalqtd is primary qtdsaldo desc etbcod desc.

def new shared temp-table ttvendedor
    field vencod    like plani.vencod
    field etbcod    like estab.etbcod
    field nome      like estab.etbnom 
    field qtdmerca  as int /*like proenoc.qtdmerca*/
            column-label "Total"
    field qtdmercaent   as int /*like proenoc.qtdmercaent*/
            column-label "Entregue"
    field qtdsaldo  as int /*like proenoc.qtdmerca*/
            column-label "Saldo"
    field qtdatrasado   as int /*like proenoc.qtdmerca*/
            column-label "Atrasado"
    field qtdposterior  as int /*like proenoc.qtdmerca*/
            column-label "Posterior"
    field vlrsaldo     as dec 
    field vlratrasado     as dec 
 
    index loja     is unique etbcod asc vencod asc 
    index platot   is primary qtdsaldo desc.

        


form
    clase.clacod
    clase.clanom
        help " ENTER = Seleciona" 
    "clase.setcod"
    "setor.setnom"
    with frame f-consulta
        color yellow/blue centered down overlay title " CLASSES " .

form
    ttloja.nome  column-label "Estabel." 
        format "x(20)"
        help "ENTER=Seleciona F4=Encerra F8=Imprime F9-Detalhe" 
    ttloja.qtdmerca    column-label "Total!Qtd"  format ">>>>>>9" 
    ttloja.qtdmercaent column-label "Entra!Qtd"  format ">>>>9"
    ttloja.qtdsaldo column-label     "Saldo!Qtd"  format "->>>>,>>9" 
    ttloja.vlrsaldo column-label "Saldo!Valor"
                format "->>>>>>9.99"

    ttloja.qtdatrasado column-label  "Atraso!Qtd" format ">>>>>9"
    ttloja.vlratrasado column-label  "Atraso!Valor" format ">>>>>9,99"
    
    ttloja.qtdposterior column-label "Futuro!Qtd" format ">>>>>9"

     with frame f-lojas
        width 80
        centered
        15 down 
        row 4
        
        no-box
        overlay.
 
form                    
    ttvendedor.nome format "x(22)" column-label "Comprador." 
            help "ENTER=Seleciona F4=Encerra F8=Imprime" 
    ttloja.qtdmerca    column-label "Programada!Qtd"
    ttloja.qtdmercaent column-label "Entregue!Qtd"
    ttloja.qtdsaldo column-label "Pendente!Qtd"
    ttloja.vlrsaldo column-label "Valor"

    with frame f-vendedor
        width 80
        centered
        15 down 
        row 5
        no-box
        overlay.
  
form
    ttloja.nome      format "x(25)"
    ttloja.qtdmerca  format ">,>>9"
    with frame f-lojaimp
        width 180 
        centered
        down
        no-box.

form
    vetbcod  label  "Lj"
    estab.etbnom no-label format "x(12)" 
    vmes no-label space(0) "/" space(0) vano no-label
    vdti     label "De" format "99/99/9999"
    vdtf     label "A" format "99/99/9999"
/*    vhora    label "H" */
    vdiastot label "Dias Total" format "99"
    vdiasatu label "Atual" format "99"
    with frame f-etb
        centered
        1 down side-labels 
        row 3 width 80
        no-box.

def var v-opcao as char format "x(14)" extent 2 initial
    ["POR COMPRADOR","POR PRODUTOS"].
    
form
    v-opcao[1]  format "x(12)"
    v-opcao[2]  format "x(12)"
    with frame f-opcao
        centered 1 down no-labels overlay row 10 color white/green. 

{selestab.i vetbcod f-etb}

repeat:                         
    hide frame f-lojas no-pause.
    clear frame f-mat all.
    hide frame f-mat.
    /*
    for each ttvenpro : delete ttvenpro. end.
    for each ttvend : delete ttvend. end.
    for each ttprodu :  delete ttprodu. end.
    */

    for each ttloja :  delete ttloja. end.
    for each ttvendedor. delete ttvendedor. end.

    
    /*for each ttsetor : delete ttsetor. end.
    for each ttgrupo : delete ttgrupo. end.
    for each ttclase : delete ttclase. end. 
    for each ttsclase : delete ttsclase. end.*/
    
   
    /**
    update  vetbcod with frame f-etb.
    ***/        
    do :
        /*find first func where func.funcod = sfuncod no-lock.*/
       /* if func.etbcod <> vetbcod and func.etbcod <> 0 
        then do :
            bell. bell. bell.
            message "Funcionario nao Autorizado".
            pause. clear frame f-etb all.
            next.
        end. */
        /*
        if vetbcod = 0
        then do:
                disp "GERAL" @ bbestab.etbnom with frame f-etb.
        end.
        else do:
            find bbestab where bbestab.etbcod = vetbcod no-lock.
            disp bbestab.etbnom with frame f-etb.
        end.
        */
    end.    
    vmes = month(today).
    vano = year(today).

    update
        vmes vano with frame f-etb.
   
    assign vdti = date(vmes,01,vano)
           vdtf = today - 1. 

    vanofim      = vano + if vmes = 12                  
                          then 1                        
                          else 0.
    vmesfim      = if vmes = 12                         
                   then 1                               
                   else vmes + 1.                        
    vdtf         = date(vmesfim,01,vanofim) - 1.
    vdiafim      = day(vdtf).   
    /*
    if year(today) = year(vdtf) and
       month(today) = month(vdtf)
    then vdtf = today - 1.
    */
    update  vdti  vdtf   with frame f-etb.
    vdia = day(vdtf).
    vdiastot = 0.
    vdiasatu = 0.
    do vcont = 1 to vdiafim. 
        /*if temdtextra(vetbcod, date(vmes, vcont, vano))
        then next. verificar*/
        
/*
        if weekday(date(vmes,vcont,vano)) > 1 and /* Domingo */
           weekday(date(vmes,vcont,vano)) < 7     /* Sabado */       
        then do:                                                     
*/
            vDiasTot = vDiasTot + 1.                                 
            if vcont <= vdia
            then vdiasatu = vdiasatu + 1.                           
/*
         end.                                                         
*/
    end.                                                            
 
    disp vdiasatu vdiastot 
        with frame f-etb.

    run calcvnw2.

    hide frame f-mostr.
    repeat :
        
        assign  an-seeid = -1 an-recid = -1 
                an-seerec = ? v-totdia = 0. v-totger = 0.
        
        {anbrowse.i
            &File   = ttloja
            &CField = ttloja.nome
            &color  = write/cyan
            &Ofield = "ttloja.nome ttloja.qtdmerca 
                                   ttloja.qtdmercaent
                                   ttloja.qtdsaldo
                                   ttloja.vlrsaldo
                                   ttloja.qtdatrasado
                                   ttloja.vlratrasado
                                   ttloja.qtdposterior"
            &Where = "ttloja.etbcod  = (if vetbcod = 0
                                        then ttloja.etbcod
                                        else vetbcod)"
            &NonCharacter = /*
            &Aftfnd = "
                "
            &otherkeys1 = "perfentr.i"
            &AftSelect1 = "p-loja = ttloja.etbcod. 
                       leave keys-loop. "
            &LockType = "use-index totalqtd" 
            &Form = " frame f-lojas" 
        }.

        if keyfunction(lastkey) = "END-ERROR"
        then leave.

        hide frame border  no-pause. 
        hide frame fescpos no-pause. 
        FORM 
            SPACE(3) 
            SKIP(8) 
            WITH FRAME border 
            ROW 10 column 47 
            WIDTH 19 NO-BOX OVERLAY COLOR MESSAGES. 
        view frame border. 
        pause 0. 
        display v-opcao
            with frame fescpos no-label 1 column 
                column 49 row 11 overlay. 
        choose field v-opcao with frame fescpos. 
        hide frame f-opcao no-pause.
        if v-opcao[frame-index] = "" 
        then undo. 
        hide frame fesqpos no-pause.
        hide frame border no-pause.
        clear frame f-lojas all no-pause.
        display 
                ttloja.nome 
                ttloja.qtdmerca
                ttloja.qtdmercaent
                ttloja.qtdsaldo
                ttloja.vlrsaldo
                ttloja.qtdatrasado
                ttloja.vlratrasado
                ttloja.qtdposterior
                with frame f-lojas.
        pause 0.
        if frame-index = 2 
        then do :
            run perfentp.p (input ttloja.etbcod, 0).
        end.
        else do:
            run perfentc.p (recid(ttloja), 8).
        end.        
 
    end.        
end.    


PROCEDURE calcvnw2.

def var vmens as char.
def var vmens2 as char.
def var aux-i as int.

vmens  = "Sua selecao podera demorar".
vmens2 = " C U S T O M    *    *    *    *    *    *    *    *    *    *    *"
+ "   *    *".

if vdtf - vdti < 5
then vmens = vmens + " 1 Minuto +/- ".
else if vdtf - vdti < 10
     then vmens = vmens + " 2 Minutos +/- ".
     else if vdtf - vdti < 20
          then vmens = vmens + " 3 Minutos +/- ".
          else vmens = vmens + " 4 Minutos +/- ".
def var vtime  as int.
vtime = time.
vmens  = trim(vmens) + fill(" ",80 - length(vmens)).
vmens2 = fill(" ",80 - length(vmens2)) + trim(vmens2) .

def var vok as log.
def var vconta as int.
   for each bestab  /*where bestab.etbcod = 999*/ no-lock:
   
   /*for each proenoc where proenoc.sitproenoc = "P" and
                          proenoc.etbentrega = bestab.etbcod 
                no-lock.*/

   do vdt-aux = vdti to vdtf:
   for each pedid where pedid.pedtdc = 1
                    and pedid.etbcod = bestab.etbcod 
                    and pedid.peddat = vdt-aux no-lock.

    find compr where compr.comcod = pedid.comcod no-lock no-error.
   
    for each liped where liped.etbcod = bestab.etbcod and
                         liped.pedtdc = 1             and
                         liped.pednum = pedid.pednum no-lock:


      /*if (liped.lipqtd - liped.lipent) <= 0
      then next.   */
       
      aux-i = 0.    
      repeat.
         aux-i = aux-i + 1.
         if aux-i > 1 and
            vetbcod <> 0
         then leave.
         if aux-i > 2
         then leave.
         if aux-i = 1
         then aux-etbcod = /*proenoc.etbentrega*/ liped.etbcod.
         else aux-etbcod = 999.

        if not vok then do.
            find first ttloja where
                       ttloja.etbcod = aux-etbcod no-error.
            if not avail ttloja
            then do.
               if aux-etbcod <> 999 then
                  find estab where estab.etbcod = aux-etbcod no-lock.
               create ttloja.
               assign
                  ttloja.etbcod = aux-etbcod
                  ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                  else (string(estab.etbcod,"zz9") 
                                            + "-" + estab.etbnom).
            end.

            find first ttvendedor where 
                          ttvendedor.etbcod = aux-etbcod and
                          ttvendedor.vencod = pedid.comcod /*funcod*/
                        no-error.
            if not avail ttvendedor
            then do:
/*              find func where func.funcod = pedid.comcod /*funcod*/
                                            no-lock no-error.*/
                find compr where compr.comcod = pedid.comcod no-lock no-error.
                                            
              create ttvendedor.
              assign 
                 ttvendedor.etbcod = aux-etbcod
                 ttvendedor.vencod = pedid.comcod /*funcod*/
                 ttvendedor.nome   = if not avail /*func*/ compr
                                 then "COMPRADOR-" + string(pedid.comcod)
                                                    /*funcod).*/
                                 else compr.comnom /*FUNC.FUNNOM*/.
        end.  
        run totaliza.
                
        
        end.
      end.
    end.
   end.
   end.

   /*****************************/

   do vdt-aux =  /*vdti - 180 to vdtf + 365*/
                date(1,1,year(vdti)) to date(12,31,year(vdti)):

   for each pedid where pedid.etbcod = bestab.etbcod
                    and pedid.pedtdc = 1
                    and pedid.peddat = vdt-aux no-lock:

    if pedid.peddat >= vdti and
       pedid.peddat <= vdtf
    then next.

    find compr where compr.comcod = pedid.comcod no-lock no-error.
   
    for each liped where liped.etbcod = pedid.etbcod
                     and liped.pedtdc = 1
                     and liped.pednum = pedid.pednum no-lock:
                     
       
      /*if (liped.lipqtd - liped.lipent) <= 0
      then.   
      else next.*/
      
      disp liped.pednum liped.predt format "99/99/9999"
            with 1 down centered. pause 0.
      
      aux-i = 0.    
      repeat:
         aux-i = aux-i + 1.
         if aux-i > 1 and
            vetbcod <> 0
         then leave.
         if aux-i > 2
         then leave.
         if aux-i = 1
         then aux-etbcod = liped.etbcod /*proenoc.etbentrega*/.
         else aux-etbcod = 999.

         if not vok 
         then do:
            /*
              Cadastrar ocproen
            */
            find first ttloja where
                       ttloja.etbcod = aux-etbcod no-error.
            if not avail ttloja
            then do.
               if aux-etbcod <> 999 then
                  find estab where estab.etbcod = aux-etbcod no-lock.
               create ttloja.
               assign
                  ttloja.etbcod = aux-etbcod
                  ttloja.nome   = if aux-etbcod = 999 then "GERAL"
                                  else (string(estab.etbcod,"zz9") 
                                            + "-" + estab.etbnom).
            end.

            find first ttvendedor where 
                          ttvendedor.etbcod = aux-etbcod and
                          ttvendedor.vencod = pedid.comcod /*funcod*/
                        no-error.
            if not avail ttvendedor
            then do:
              /*find func where func.funcod = pedid.funcod no-lock no-error.*/
               find compr where compr.comcod = pedid.comcod no-lock no-error.

              create ttvendedor.
              assign 
                 ttvendedor.etbcod = aux-etbcod
                 ttvendedor.vencod = pedid.comcod /*funcod*/
                    ttvendedor.nome   = if not avail /*func*/ compr
                                 then "VENDEDOR-" + string(pedid.comcod)
                                                   /*funcod)*/
                                 else (string(pedid.comcod, ">>>>9") + "-" +
                            compr.comnom).
            end.
            run totaliza.
        
         end.
      end.
   end.
   end.
   end.
end.

   hide frame f-mostr no-pause.

        /* apaga mensagem na tela */
                                put screen color messages  row 17  column 15
                        " Decorridos : " + string(time - vtime,"HH:MM:SS")
                               + " Minutos    - Lidos " +
                               string(vconta,"zzzzz9") + " Registros ".

        pause 1 no-message.
        put screen row 15  column 1 fill(" ",80).
        put screen row 16  column 1 fill(" ",80).
        put screen row 17  column 1 fill(" ",80).

end procedure.


PROCEDURE totaliza.

        assign 
            ttloja.qtdatrasado   = ttloja.qtdatrasado +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega < vdti
                            then proenoc.qtdmerca - proenoc.qtdmercaent*/
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti 
                            then liped.lipqtd - liped.lipent
                            else 0

            ttloja.vlratrasado  = ttloja.vlratrasado +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega < vdti
                            then  (proenoc.qtdmerca - proenoc.qtdmercaent) *
                                            liped.lippreco*/
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0

            ttloja.qtdposterior  = ttloja.qtdposterior +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega > vdtf
                            then proenoc.qtdmerca - proenoc.qtdmercaent*/
                            
                            if (liped.lipqtd - liped.lipent) > 0 and
                               liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            else 0
                            
            ttloja.qtdmerca  = ttloja.qtdmerca + 
                            if /*proenoc.datentrega*/
                               liped.predt >= vdti and
                               /*proenoc.datentrega*/
                               liped.predt <= vdtf
                            then liped.lipqtd /* proenoc.qtdmerca*/
                            else 0


            ttloja.qtdmercaent   = ttloja.qtdmercaent + 
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            then /*proenoc.qtdmercaent*/ liped.lipent
                            else 0

            
            ttloja.qtdsaldo      = ttloja.qtdsaldo +
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            then /*proenoc.qtdmerca - proenoc.qtdmercaent*/
                                  liped.lipqtd - liped.lipent
                            else 0
                        
            ttloja.vlrsaldo      = ttloja.vlrsaldo +
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            /*then (proenoc.qtdmerca - proenoc.qtdmercaent) *
                                            liped.lippreco*/
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                            else 0.
                
        assign 
            ttvendedor.qtdatrasado   = ttvendedor.qtdatrasado +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega < vdti
                            then proenoc.qtdmerca - proenoc.qtdmercaent*/
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt < vdti
                            then (liped.lipqtd - liped.lipent)
                            
                            else 0

            
            
            ttvendedor.vlratrasado      = ttvendedor.vlratrasado +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega < vdti
                            then  (proenoc.qtdmerca - proenoc.qtdmercaent) *
                                            liped.lippreco*/
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt < vdti
                            then (liped.lipqtd - liped.lipent) *
                                 liped.lippreco           
                                            
                            else 0

            ttvendedor.qtdposterior  = ttvendedor.qtdposterior +
                            /*if proenoc.sitproenoc = "P" and
                               proenoc.datentrega > vdtf
                            then proenoc.qtdmerca - proenoc.qtdmercaent*/
                            if (liped.lipqtd - liped.lipent) > 0 and
                                liped.predt > vdtf
                            then (liped.lipqtd - liped.lipent)
                            
                            else 0
                            
            ttvendedor.qtdmerca      = ttvendedor.qtdmerca + 
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            then /*proenoc.qtdmerca*/ liped.lipqtd
                            else 0
                            
            ttvendedor.qtdmercaent   = ttvendedor.qtdmercaent + 
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            then liped.lipent /*proenoc.qtdmercaent*/
                            else 0
            ttvendedor.qtdsaldo      = ttvendedor.qtdsaldo +
                            if /*proenoc.datentrega*/ liped.predt >= vdti and
                               /*proenoc.datentrega*/ liped.predt <= vdtf
                            then /*proenoc.qtdmerca - proenoc.qtdmercaent*/
                                liped.lipqtd - liped.lipent
                            else 0
                        
            ttvendedor.vlrsaldo      = ttvendedor.vlrsaldo +
                            /*if proenoc.datentrega >= vdti and
                               proenoc.datentrega <= vdtf
                            then  (proenoc.qtdmerca - proenoc.qtdmercaent) *
                                            liped.lippreco */
                            if liped.predt >= vdti and
                               liped.predt <= vdtf
                            then (liped.lipqtd - liped.lipent) * liped.lippreco
                                            
                            else 0.
                
         

end procedure.

