{admcab.i}
{setbrw.i}
def var v-primeiro as logical init no.
def  var vsetcod like setaut.setcod.
def var vnumtit  as   char.
def  var vtipo-documento as int.
def  var vempcod         like titulo.empcod initial 19.
def  var vetbcod         like titulo.etbcod.
def  var vmodcod         like titulo.modcod initial "DIV".
def  var vtitnat         like titulo.titnat initial no.
def var vcliforlab      as char format "x(12)".
def var vclifornom      as char format "x(30)".
def  var vclifor         like titulo.clifor.
def var vforcod like forne.forcod.
def var vlp as log.
def var recatu1 as recid.

def temp-table tt-titluc like titluc
    index i1 titdtven descending.

form vetbcod label "Filial "estab.etbnom no-label  skip
     vsetcod setaut.setnom no-label skip
     vmodcod modal.modnom no-label  skip
     vtitnat   skip
     vforcod   forne.fornom format "x(35)"
     with frame ff1 centered title "Creditos Administrativos" side-labels
     width 70.

def var vqtd-lj as int. 

def var esqcom1         as char format "x(15)" extent 5
    initial [ "INCLUI", "ALTERA", "EXCLUI", "    "].
def var esqcom2         as char format "x(15)" extent 5
            initial ["F4- Retorna","F1- Confirma","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial [" ",
            " ",
            " ",
            " ",
            " "].
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend       as log initial yes.
def buffer btt-titluc   for tt-titluc.
form
    esqcom1
    with frame f-com1
                 row 10 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row 20 no-box no-labels side-labels column 1
                 centered.

assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


form " " 
     " "
     with frame f-linha 2 down color with/cyan /*no-box*/
     centered.                              

                                                 
disp " " with frame f2 1 down width 80 color message 
        no-box no-label                row 20.             


repeat:
    clear frame ff1 all.
    hide frame f-com1 no-pause.
    hide frame f-com2 no-pause.
    /********
    {selestab.i vetbcod "ff1"}
    vqtd-lj = 0.
    for each tt-lj where
             tt-lj.etbcod > 0 no-lock:
        vqtd-lj = vqtd-lj + 1.
    end.        
    if vqtd-lj = 1
    then do:
        find first tt-lj where tt-lj.etbcod > 0 no-error.
        vetbcod = tt-lj.etbcod.
        disp vetbcod with frame ff1.
        find estab where estab.etbcod = vetbcod.
        display estab.etbnom no-label with frame ff1.
    end.
    else do:
        disp "SELECIONADAS " + STRING(VQTD-LJ,">>9") + 
                " FILIAIS PARA RATEIO" FORMAT "X(50)"
                @ ESTAB.ETBNOM 
                with frame ff1.
    end.            
    *******/

    do on error undo with frame ff1:
        clear frame ff1 no-pause.
        update vetbcod with frame ff1.
        find first estab where estab.etbcod = vetbcod no-lock no-error.
        if not avail estab
        then do:
            message "Estabelecimento Invalido".
            undo, retry.
        end.
        disp estab.etbnom with frame ff1.                      
        update vsetcod with frame ff1. 
        find first setaut where setaut.setcod = vsetcod no-lock no-error.
        if not avail setaut
        then do:
            message "Setor Invalido".
            undo, retry.
        end.
        disp setaut.setnom with frame ff1.
        update  vmodcod  with frame ff1.
        find first modal where modal.modcod = vmodcod no-lock no-error.
        if not avail modal
        then do:
            message "Modalidade Invalida".
            undo, retry.
        end.
        display modal.modnom no-label with frame ff1.

        if modcod = "CRE"
        then do:
            message "modalidade invalida".
            undo, retry.
        end.
        vtitnat = no.
        disp vtitnat skip with frame ff1.
        /* update vtitnat skip with frame ff1.*/
        update vforcod  with frame ff1.
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


for each tt-titluc:
  delete tt-titluc.
end.

for each titluc where
                    titluc.etbcod = vetbcod and
                    titluc.empcod = vempcod and
                    titluc.modcod = vmodcod and
                    titluc.clifor = vclifor and
                    titluc.titnat = vtitnat and
                    titluc.titbanpag = vsetcod and
                    titluc.titpar = 1 
                    and titluc.evecod = 8 no-lock:
    if titluc.titsit = "CAN" then next.
    
    create tt-titluc.
    buffer-copy titluc to tt-titluc. 
end.
  
l1: repeat:
    
    for each tt-titluc:
  delete tt-titluc.
end.

for each titluc where
                    titluc.etbcod = vetbcod and
                    titluc.empcod = vempcod and
                    titluc.modcod = vmodcod and
                    titluc.clifor = vclifor and
                    titluc.titnat = vtitnat and
                    titluc.titbanpag = vsetcod and
                    titluc.titpar = 1 
                    and titluc.evecod = 8 no-lock:
    if titluc.titsit = "CAN" then next.
    
    create tt-titluc.
    buffer-copy titluc to tt-titluc. 
end.

    clear frame f-com1 all.
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1  esqpos2 = 1 . 
    disp esqcom1 with frame f-com1. 
    disp esqcom2 with frame f-com2. 
    find first tt-titluc no-error.
    hide frame f-linha no-pause.
    clear frame f-linha all.  
    hide frame f-linha no-pause.
    clear frame f-linha all.
    pause 0.
    {sklclstb.i  
        &color = with/cyan
        &file  =  tt-titluc 
        &cfield = tt-titluc.titnum
        &noncharacter = /* 
        &ofield = "tt-titluc.titpar tt-titluc.titvlcob 
                   tt-titluc.titdtemi tt-titluc.titdtven 
                   tt-titluc.titdtpag tt-titluc.titsit tt-titluc.titobs[1]
                   column-label ""    Observacoes"""
        &aftfnd1 = " "
        &where   = " tt-titluc.titnum <> """" "
        &aftselect1 = " 
                        run aftselect.
                        a-seeid = -1. 
                        /* */
                        if esqcom1[esqpos1] = ""INCLUI"" or 
                           esqcom1[esqpos1] = ""EXCLUI"" or
                           esqcom1[esqpos1] = ""ALTERA""
                        then do:
                            next l1.
                        end.
                        else
                        /* */
                        if keyfunction(lastkey) = ""end-error""  then leave l1.
                        next keys-loop. "
        &naoexiste1 = " 
                        run aftselect. 
        if keyfunction(lastkey) = ""end-error""  then leave l1.  "
        &otherkeys1 = "  run controle. "
        &locktype = "  "
        &form   = " frame f-linha overlay"
    }   
    if  keyfunction(lastkey) = "insert-mode" or
       keyfunction(lastkey) = "GO"
    then do:
         run pi-Atualiza-Titluc.
         leave l1.
    end.
    if keyfunction(lastkey) = "end-error"
     then DO:
        clear frame f-linha all.
        leave l1.       
    END.
end.
 hide frame f-com1 no-pause.
 hide frame f-com2 no-pause.
 hide frame f10 no-pause.
 hide frame ff2 no-pause.
 hide frame f-linha no-pause.
 if keyfunction(lastkey) = "end-error" then leave.
end.
                                                        
procedure Pi-Atualiza-Titluc.

for each tt-titluc : 

    find first titluc where titluc.titnum = tt-titluc.titnum and
                            titluc.etbcod = tt-titluc.etbcod and
                            titluc.empcod = tt-titluc.empcod and
                            titluc.modcod = tt-titluc.modcod and
                            titluc.clifor = tt-titluc.clifor and
                            titluc.titnat = tt-titluc.titnat and
                            titluc.titbanpag = vsetcod and
                            titluc.titpar = 1  exclusive no-error.
    
    if tt-titluc.titnum = "" or tt-titluc.titvlcob <= 0 then next.

    if tt-titluc.titdtpag <> ? and tt-titluc.titsit <> "CAN"
    then do:
        assign tt-titluc.titvlpag = tt-titluc.titvlcob
               tt-titluc.titsit   = "PAG".
    end.
    
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
     /*
     if tt-titluc.titsit = "CAN" then delete tt-titluc.
     */
end.

end procedure.

procedure Aftselect.

def var v-recid-aux as recid.
  
  if esqcom1[esqpos1] = "INCLUI"
  then do on error undo with frame f-linha:
      
        clear frame f-linha all.
        /*
        esqpos1 = 1.
        color display message esqcom1[esqpos1] with frame f-com1.
        */
        create tt-titluc.
        tt-titluc.evecod = 8.
        assign tt-titluc.titnum = "".
        assign v-recid-aux = recid(tt-titluc).
        /**
        update  tt-titluc.titvlcob 
                tt-titluc.titdtemi 
                tt-titluc.titdtven 
                tt-titluc.titdtpag
                tt-titluc.titobs[1]. 
        if tt-titluc.titdtpag <> ? then assign tt-titluc.titsit = "PAG".
        **/
        run gera-titnum.p(output tt-titluc.titnum).
        /*
        tt-titluc.titnum = string(day(tt-titluc.titdtpag)) +
                               string(month(tt-titluc.titdtpag)) +
                               string(year(tt-titluc.titdtpag)).
        */
        disp tt-titluc.titnum with frame f-linha. 
        if keyfunction(lastkey) = "end-error"  then return.
        find first  tt-titluc where
                    tt-titluc.titnum = input frame f-linha tt-titluc.titnum and
                    tt-titluc.etbcod = vetbcod and
                    tt-titluc.empcod = vempcod and
                    tt-titluc.modcod = vmodcod and
                    tt-titluc.clifor = vclifor and
                    tt-titluc.titnat = vtitnat and
                    tt-titluc.titbanpag = vsetcod and
                    tt-titluc.titpar = 1 
                    exclusive no-error.
                    
        if avail tt-titluc and tt-titluc.titnum <> "" 
        then do:
            message "Ja exite Titulo com este numero".
            undo, retry.
        end.
        else do:
            create  tt-titluc.
            assign  tt-titluc.empcod = vempcod
                    tt-titluc.etbcod = vetbcod
                    tt-titluc.modcod = vmodcod
                    tt-titluc.clifor = vclifor
                    tt-titluc.titnat = vtitnat
                    tt-titluc.titbanpag = vsetcod
                    tt-titluc.titpar = 1
                    tt-titluc.titnum = input frame f-linha tt-titluc.titnum. 
                disp tt-titluc.titpar with frame f-linha.
        end.
        /* */
        update  tt-titluc.titvlcob 
                tt-titluc.titdtemi 
                tt-titluc.titdtven 
                tt-titluc.titdtpag
                tt-titluc.titobs[1]. 
        if tt-titluc.titdtpag <> ? then assign tt-titluc.titsit = "PAG".
        /* */
        disp tt-titluc.titsit with frame f-linha.
        pause 0.
        if tt-titluc.titvlcob = 0 or tt-titluc.titdtemi = ? or
           tt-titluc.titdtven = ?
        then do:
                undo, retry.
         end.  
         
         find first tt-titluc where recid(tt-titluc) = v-recid-aux
                  no-error.
         if avail tt-titluc then delete tt-titluc.
         
         clear frame f-linha all.
  end.
  if esqcom1[esqpos1] = "ALTERA"
  then do on error undo with frame f-linha:
       find tt-titluc where recid(tt-titluc) =  a-seeid no-error.
       if avail tt-titluc
       then 
       update  tt-titluc.titvlcob 
               tt-titluc.titdtemi 
               tt-titluc.titdtven
               tt-titluc.titdtpag
               tt-titluc.titobs[1]
               with frame f-linha.
   end.
    
  if esqcom1[esqpos1] = "EXCLUI"
  then do on error undo with frame f-linha:
        find first tt-titluc where recid(tt-titluc) =  a-seeid no-error.
        if avail tt-titluc then do:
                assign tt-titluc.titsit = "CAN".
                disp  "" @ tt-titluc.titnum
                      "" @ tt-titluc.titdtpag
                      "" @ tt-titluc.titdtven
                      "" @ tt-titluc.titsit
                      "" @ tt-titluc.titobs[1] 
                      "" @ tt-titluc.titpar
                      "" @ tt-titluc.titvlcob
                      "" @ tt-titluc.titdtemi
                      with frame f-linha.
        end. 
  end.

  run Pi-Atualiza-Titluc.
  
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


