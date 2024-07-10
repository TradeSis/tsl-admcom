def input parameter p-recid as recid.

find tbparavp where recid(tbparavp) = p-recid no-lock no-error.
if not avail tbparavp
then return.

def var v-tipo as char init "CONTAS A RECEBER".

if tbparavp.natureza
then v-tipo = "CONTAS A PAGAR".
else v-tipo = "CONTAS A RECEBER".
 
{admcab.i}
{setbrw.i}                                                                      

on F7 help.
def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial ["","  INCLUI","  ALTERA","GERA LANCAMENTO",""].
def var esqcom2         as char format "x(15)" extent 5
            initial ["","","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["teste teste",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["teste teste  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 4 no-box no-labels side-labels column 1 centered.
/*
form

    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
*/
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.


def buffer bhispad for hispad.

form 
     lancactb.char1        column-label "Desc." format "x(15)"
     lancactb.contadeb     column-label "Conta Debito"
     lancactb.contacre     column-label "Conta Credito"
     /*lancactb.int1         column-label "His-1.Prov"
     format ">>>>9"*/
     lancactb.int2         column-label "Historico" 
     format ">>>>9"
     with frame f-linha 10 down color with/cyan /*no-box*/
     centered title " CONTABILIZAR AVP - " + v-tipo + " " + 
            string(tbparavp.datref,"99/99/9999") + " ".
                                                                         
def buffer btbcntgen for tbcntgen.                            
def var i as int.

def buffer blancactb for lancactb.
def temp-table tt-lancactb like lancactb.

if v-tipo = "CONTAS A RECEBER"
then 
l1: repeat:
    disp esqcom1 with frame f-com1.
    pause 0.
  /*  disp esqcom2 with frame f-com2.
    pause 0. */
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = lancactb  
        &cfield = lancactb.char1
        &noncharacter = /* 
        &ofield = " 
                    lancactb.contadeb
                    lancactb.contacre
                    /*lancactb.int1*/
                    lancactb.int2  
                    "  
        &aftfnd1 = " "
        &where  = " lancactb.id = 1 and 
                    lancactb.tipo = v-tipo "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  INCLUI""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB F7 PF7
        &naoexiste1 = " sresp = no.
                        Message ""Nenhum registro cadastrado"".
                        message ""Deseja incluir? "" update sresp.
                        if sresp
                        then do:
                            esqcom1[esqpos1] = ""  INCLUI"".
                            run aftselect.
                            esqcom1[esqpos1] = """".
                            next l1.
                        end.    
                        else leave l1.
                        
                        " 
        &otherkeys1 = "  run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.
else if v-tipo = "CONTAS A PAGAR"
then 
l1: repeat:
    disp esqcom1 with frame f-com1.
    pause 0.
  /*  disp esqcom2 with frame f-com2.
    pause 0. */
    assign
        a-seeid = -1 a-recid = -1 a-seerec = ?
        esqpos1 = 1 esqpos2 = 1. 
    hide frame f-linha no-pause.
    clear frame f-linha all.
    {sklclstb.i  
        &color = with/cyan
        &file = lancactb  
        &cfield = lancactb.char1
        &noncharacter = /* 
        &ofield = " 
                    lancactb.contadeb
                    lancactb.contacre
                    /*lancactb.int1*/
                    lancactb.int2  
                    "  
        &aftfnd1 = " "
        &where  = " lancactb.id = 1 and
                    lancactb.tipo = v-tipo "
        &aftselect1 = " run aftselect.
                        a-seeid = -1.
                        if esqcom1[esqpos1] = ""  EXCLUI"" or
                           esqcom1[esqpos1] = ""  INCLUI""
                        then do:
                            next l1.
                        end.
                        else next keys-loop. "
        &go-on = TAB F7 PF7
        &naoexiste1 = " sresp = no.
                        Message ""Nenhum registro cadastrado"".
                        message ""Deseja incluir? "" update sresp.
                        if sresp
                        then do:
                            esqcom1[esqpos1] = ""  INCLUI"".
                            run aftselect.
                            esqcom1[esqpos1] = """".
                            next l1.
                        end.    
                        else leave l1.
                        
                        " 
        &otherkeys1 = "  run controle. "
        &locktype = " "
        &form   = " frame f-linha "
    }   
    if keyfunction(lastkey) = "end-error"
    then DO:
        leave l1.       
    END.
end.

hide frame f1 no-pause.
hide frame f2 no-pause.
hide frame ff2 no-pause.
hide frame f-linha no-pause.
hide frame f-com1 no-pause.

procedure aftselect:
    clear frame f-linha1 all.
    for each tt-lancactb:  delete tt-lancactb. end.
    if esqcom1[esqpos1] = "  INCLUI"
    THEN DO on error undo with frame f-inclui centered row 10 1 down
                side-label:
        
        create tt-lancactb.
        assign
            tt-lancactb.id = 1
            tt-lancactb.etbcod = ?
            tt-lancactb.forcod = ?
            tt-lancactb.lancod = ?
            tt-lancactb.tipo = v-tipo
            .
        do on error undo:
            update tt-lancactb.char1 at 9 label "Desc.".
            update        
               tt-lancactb.contadeb at 1 label "Conta Debito."
               tt-lancactb.contacre at 1 label "Conta Credito"
               .
               
            /*do on error undo:
                update tt-lancactb.int1     at 1 label "Historico 1.." .
                find hispad where
                     hispad.hiscod = tt-lancactb.int1 no-lock no-error.
                disp hispad.hisdes no-label.
            end.*/
            do on error undo:     
                update tt-lancactb.int2     at 1 label "Historico 2.."  .
                find bhispad where
                     bhispad.hiscod = tt-lancactb.int2 no-lock no-error.
                disp bhispad.hisdes no-label.
            end.
               .
        
        end.

        if keyfunction(lastkey) = "RETURN"
        then do:
            create lancactb.
            buffer-copy tt-lancactb to lancactb.
        end.
            
    END.
    if esqcom1[esqpos1] = "  ALTERA"
    THEN DO on error undo with frame f-altera centered row 10 1 down
                    side-label:

        create tt-lancactb.
        buffer-copy lancactb to tt-lancactb.                
        do on error undo:
            disp tt-lancactb.char1 at 9 label "Desc.".

            find first hispad where
                       hispad.hiscod = tt-lancactb.int1 no-lock no-error.
 
            find first bhispad where
                       bhispad.hiscod = tt-lancactb.int2 no-lock no-error.
            
            disp tt-lancactb.contadeb at 1 label "Conta Debito."
               tt-lancactb.contacre at 1 label "Conta Credito"
               /*tt-lancactb.int1 at 1 label "Historico 1.."
               hispad.hisdes no-label*/
               tt-lancactb.int2 at 1 label "Historico 2.."
               bhispad.hisdes no-label 
               .
            update        
               tt-lancactb.contadeb at 1 label "Conta Debito."
               tt-lancactb.contacre at 1 label "Conta Credito"
               .
               
            /*do on error undo:
                update tt-lancactb.int1 at 1 label "Historico 1..".
                find hispad where
                     hispad.hiscod = tt-lancactb.int1 no-lock no-error.
                disp hispad.hisdes no-label.
            end.*/
            do on error undo:
                update tt-lancactb.int2 at 1 label "Historico 2..".
                find bhispad where
                     bhispad.hiscod = tt-lancactb.int2 no-lock no-error.
                disp bhispad.hisdes no-label.
            end.
               .
        
        end.

        if keyfunction(lastkey) = "RETURN"
        then do:
            find blancactb of lancactb .
            buffer-copy tt-lancactb to lancactb.
        end. 
    END.
    if esqcom1[esqpos1] = "GERA LANCAMENTO"
    then do:
        bell.
        sresp = no.    
        message "Confirma garar Lancamento" lancactb.char1 "?" update sresp.
        if sresp                                             
        then run gera-arquivo-ctb. 
    end.
    if esqcom1[esqpos1] = "  EXCLUI"
    THEN DO:
        
    END.
    if esqcom2[esqpos2] = "    "
    THEN DO on error undo:
    
    END.

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
            if keyfunction(lastkey) = "HELP"
            then do:
                sretorno = "".
                run zmodal-ctb.p.
                find lancactb where 
                     lancactb.modcod = sretorno no-lock no-error.
                if avail lancactb and sretorno <> ""
                then do:
                    a-recid = recid(lancactb).
                end.
                
            end.
end procedure.

procedure relatorio:

    def var varquivo as char.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/" + string(setbcod) + "."
                    + string(time).
    else varquivo = "..~\relat~\" + string(setbcod) + "."
                    + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "80" 
                &Page-Line = "66" 
                &Nom-Rel   = ""programa"" 
                &Nom-Sis   = """SISTEMA""" 
                &Tit-Rel   = """TITULO""" 
                &Width     = "80"
                &Form      = "frame f-cabcab"}

    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.
end procedure.

procedure gera-arquivo-ctb:
    
        
    run lan-contabil("CAIXA",lancactb.contadeb,lancactb.contacre,
                    "",today,tbparavp.val5_AVP,"","",
                    1,"","").

end procedure.    

procedure lan-contabil:
    def input parameter l-tipo as char.
    def input parameter l-landeb like lancactb.contadeb.
    def input parameter l-lancre like lancactb.contacre.
    def input parameter l-modcod like lancxa.modcod.
    def input parameter l-datlan as date.
    def input parameter l-vallan as dec.
    def input parameter l-forcod like titulo.clifor.
    def input parameter l-titnum like titulo.titnum.
    def input parameter l-etbcod like estab.etbcod.
    def input parameter l-hiscod as char.
    def input parameter l-hiscomp as char.

    def buffer blancxa for lancxa.
    
    def var vnumlan like lancxa.numlan.
    
    if l-tipo = "CAIXA"
    THEN
    do on error undo:
    
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "C"
                        no-error.
            if not avail lancxa
            then do:            
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
            create lancxa.
            assign lancxa.cxacod = l-landeb
                   lancxa.datlan = l-datlan
                   lancxa.lancod = l-lancre
                   lancxa.modcod = l-modcod
                   lancxa.numlan = vnumlan
                   lancxa.vallan = l-vallan
                   lancxa.comhis = l-hiscomp
                   lancxa.lantip = "C"
                   lancxa.forcod = l-forcod
                   lancxa.titnum = l-titnum
                   lancxa.etbcod = l-etbcod
                   lancxa.lanhis = int(l-hiscod).
            end.                    
    end.
    else if l-tipo = "EXTRA-CAIXA"
    THEN
    DO ON ERROR UNDO:
            
            find first lancxa where 
                       lancxa.datlan = l-datlan and
                       lancxa.cxacod = l-landeb and
                       lancxa.lancod = l-lancre and
                       lancxa.modcod = l-modcod and
                       lancxa.vallan = l-vallan and
                       lancxa.forcod = l-forcod and
                       lancxa.titnum = l-titnum and
                       lancxa.lantip = "X"
                        no-error.
            if not avail lancxa
            then do: 
            find last blancxa use-index ind-1
                where blancxa.numlan <> ? no-lock no-error.
            if not avail blancxa
            then vnumlan = 1.
            else vnumlan = blancxa.numlan + 1.
             
                create lancxa.
                assign
                    lancxa.numlan = blancxa.numlan + 1
                    lancxa.lansit = "F"
                    lancxa.datlan = l-datlan
                    lancxa.cxacod = l-landeb
                    lancxa.lancod = l-lancre
                    lancxa.modcod = l-modcod
                    lancxa.vallan = l-vallan
                    lancxa.lanhis = int(l-hiscod)
                    lancxa.forcod = l-forcod
                    lancxa.titnum = l-titnum
                    lancxa.etbcod = l-etbcod
                    lancxa.lantip = "X"
                    lancxa.livre1 = "" 
                    lancxa.comhis = l-hiscomp 
                    .
            end.
       end.
       message color red/with
        "GERADO OK" view-as alert-box.
        
 end procedure.

