/* helio 15082023 - 499799 - SEPARAÇÃO DE DATA DE ÚLTIMA COMPRA E DE ÚLTIMA NOVAÇÃO INTEGRAÇÃO PMWEB E 513689 - DATA NOVAÇÃO */
/* helio 03102022 - melhoria - Chamado 149970 - Entender limite zerado. */ 
/* helio 20072022 ID 139086 - ERRO no adm */
/* helio 23022022 - iepro */
/* HUBSEG 19/10/2021 */

{cabec.i}
def input param par-clicod like clien.clicod init ?.
def input param par-menu as char.
def var vhostname as char.
def var xetbcod as int.
input through hostname.
import vhostname.
input close.

def var vvlrlimite as dec.
def var vvctolimite as date.
def var vvlrlimiteEP as dec.
def var vcomprometido as dec.
def var vcomprometido-principal as dec.

def var vcomprometido-hubseg as dec.

def var vsaldoLimite as dec.
def var vcomprometidoEP as dec.
def var vcomprometido-principalEP as dec.

def var vsaldoLimiteEP as dec.

{neuro/achahash.i}
{neuro/varcomportamento.i}
def var regua1      as char format "x(13)" extent /*8*/ 7
    initial ["Historico","Posicao","Comportamento","" /*"Cadastro"*/ ].


if par-menu = "NOVACAO" 
then do:
    regua1[4] = "Novacoes".

    /* helio 20092022 - Acordo Online -
        retirado
    regua1[4] = if setbcod = 999 /* helio chamado 51443 20112020 */
                then "Acordo"
                else " ".
    */
    
    regua1[5] = "Ac Matriz".
    regua1[6] = "Ac IEPRO".
    regua1[7] = "Ac Online".
end.
else do:
    regua1[4] = "Novacoes". /* #03102022 */
end.
form regua1[1] format "x(9)"  "|" 
regua1[2] format "x(7)"  "|" 
regua1[3] format "x(7)"  "|" 
regua1[4] format "x(8)"  "|" 
regua1[5] format "x(9)"  "|" 
regua1[6] format "x(8)"  "|" 
regua1[7] format "x(9)"

 
with frame f-regua1
          row 19 no-labels side-labels column 1 centered title "Operacoes".

def var vDTULTCPA as date format "99/99/9999".
def var vDTULTNOV as date format "99/99/9999".

def var vQTDECONT   as int format ">>>>9".
def var vPARCPAG    as int format ">>>>9".
def var vPARCABERT  as int format ">>>>9".
def var vMEDIACONT  as dec.
def var vMAIORACUM  as dec.
def var vDTMAIORACUM    as char.
def var vPARCMEDIA  as dec.
def var vSALDOTOTNOV   as dec.
def var vLSTCOMPROMET   as char.
def var vATRASOATUAL as int.
def var vDTMAIORATRASO as date.
def var vMAIORATRASO    as int.
def var vVLRPARCVENC    as dec.

def var vcheque_devolvido as dec.
def var vcheque as dec.
def var vloop as int.
def var vrepar       as log format "Sim/Nao".
def var vproximo-mes like clien.limcrd.

def var qtd-15       as int format ">>>>9".
def var qtd-45       as int format ">>>>9".
def var qtd-46       as int format ">>>>9".
def var perc-15      as dec format ">>9.99%".
def var perc-45      as dec format ">>9.99%".
def var perc-46      as dec format ">>9.99%".


def var vdtultpagto as date.
def var vspc_lebes as log.
def var vclicod like clien.clicod.


repeat
    with frame fcli row 3 side-labels 
        title "Conta do Cliente" 1 down.
        
    if par-clicod = ?
    then update vclicod label "Conta"
        with frame fcli.
    else do:
        if keyfunction(lastkey) = "END-ERROR"
        then leave.
        vclicod = par-clicod.
        disp vclicod with frame fcli.
    end.    
    find clien where clien.clicod = vclicod no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    
    disp clien.clinom no-label format "x(35)"
         neuclien.cpf format "zzzzzzzzzzzzzzz" no-label when avail neuclien  
         clien.dtcad no-label format "99/99/99"
         with frame fcli.
    
    
    vvlrlimite = 0.
    vvctolimite = ?.
    vdtultpagto = ?.
    vcomprometido = 0.
    
    vsaldoLimite = 0.
    vspc_lebes  = no.
    vrepar = no.
    vvctolimite = if avail neuclien then neuclien.vctolimite else ?.
    /* #03102022 */
    vvlrlimite = if avail neuclien then neuclien.vlrlimite else 0.
    
    vcomprometido-hubseg = 0.    
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    
    run neuro/comportamento.p (clien.clicod,?,output var-propriedades).
    
    /* helio 20072022 ID 139086 - ERRO no adm */
    perc-15 = 0.
    perc-45 = 0.
    perc-46 = 0.
    qtd-15 = 0.
    qtd-45 = 0.
    qtd-46 = 0.
        
    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).
        /* #03102022 if vcampo = "LIMITE"    then vvlrlimite = dec(r1). */
        if vcampo = "LIMITEEP"  then vvlrlimiteEP = dec(r1).
        
        if vcampo = "LIMITETOMPR" then vcomprometido-principal = dec(r1).
        if vcampo = "LIMITETOMHUBSEG" then vcomprometido-hubseg = dec(r1).
        
        if vcampo = "LIMITETOMPREP" then vcomprometido-principalEP = dec(r1).
        
        if vcampo = "LIMITETOM"  then vcomprometido = dec(r1). 
        if vcampo = "LIMITETOMEP"        then vcomprometidoEP = dec(r1).
        
        if vcampo = "DTULTPAGTO"
        then  vdtultpagto = date(r1).
        
        if vcampo = "DTULTCPA" then vDTULTCPA = date(r1).
        if vcampo = "DTULTNOV" then vDTULTNOV = date(r1).
        
        if vcampo = "QTDECONT"
        then vQTDECONT = int(r1).
        if vcampo = "PARCPAG"
        then vPARCPAG = int(r1).
         if vcampo = "PARCABERT"
        then vPARCABERT = int(r1).
        if vcampo = "ATRASOPARC"
        then do:

            r1 = replace(r1,"%","").
            if num-entries(r1,"|") = 3 /* helio 20072022 ID 139086 - ERRO no adm */
            then do:
                qtd-15 = int(entry(1,r1,"|")).
                qtd-45 = int(entry(2,r1,"|")).
                qtd-46 = int(entry(3,r1,"|")).
            end.    
        end.
        if vcampo = "ATRASOPARCPERC"
        then do:
            
            r1 = replace(r1,"%",""). /* helio 20072022 ID 139086 - ERRO no adm */
            if num-entries(r1,"|") = 3
            then do:
                perc-15 = dec(entry(1,r1,"|")).
                perc-45 = dec(entry(2,r1,"|")).
                perc-46 = dec(entry(3,r1,"|")).
            end.    
        end.
        if vcampo = "MEDIACONT"
        then vMEDIACONT = dec(r1).
        if vcampo = "MAIORACUM"
        then vMAIORACUM = dec(r1).
        if vcampo = "DTMAIORACUM"
        then vDTMAIORACUM = r1.
        if vcampo = "PARCMEDIA"
        then vPARCMEDIA = dec(r1).
        if vcampo = "SALDOTOTNOV"
        then do:
            vSALDOTOTNOV  = dec(r1).
            vrepar     = vSALDOTOTNOV > 0.
        end.
        if vcampo = "LSTCOMPROMET"
        then  vproximo-mes = dec(entry(2,r1,"|")).   
        if vcampo = "ATRASOATUAL"
        then vATRASOATUAL = int(r1).
        if vcampo = "DTMAIORATRASO"
        then vDTMAIORATRASO = date(r1).
        if vcampo = "MAIORATRASO"
        then vMAIORATRASO = int(r1).
        if vcampo = "VLRPARCVENC"
        then vVLRPARCVENC = dec(r1).        
        if vcampo = "VALORCHDEVOLV"
        then do:
            do vloop = 1 to num-entries(r1,"|"):
                vcheque = dec(entry(vloop,r1,"|")) no-error.
                if vcheque <> ?
                then vcheque_devolvido = vcheque_devolvido + vcheque. 
            end.
        end.
           
    end.
    vcomprometido-principal = vcomprometido-principal - vcomprometido-hubseg.
    vsaldoLimite = vvlrlimite - (vcomprometido-principal).

    vsaldoLimiteEP = vvlrlimiteEP - vcomprometido-principalEP.
    
    if (vvctolimite < today or vvctolimite = ? )
        /* #03102022 */
        and setbcod <> 999
    then do:
        vvlrlimite   = 0.
        vsaldoLimite = 0.
    end.     
    if (vvctolimite < today or vvctolimite = ? )
        /* #03102022 */
        and setbcod <> 999
    then do:
        vsaldoLimiteEP = 0. 
        vvlrlimiteep = 0.
    end.    
    
    
    pause 0.
    disp "CR"
         vvlrLimite  label "Credito" format "->>>>9.99"
       /*  vvctoLimite label "Venc" */        
         vcomprometido   label "Abert"   format "->>>>>9.99"
         vcomprometido-principal   label "Princ" format "->>>>>9.99"

         vsaldoLimite label "Dispo" format "->>>>>9.99"

         with frame f1.
    
    disp skip "EP"
         vvlrLimiteEP  label "Credito" format "->>>>9.99"

         vcomprometidoEP   label "Abert" format "->>>>>9.99"

         vcomprometido-principalEP   label "Princ" format "->>>>>9.99"

         
         vsaldoLimiteEP label "Dispo" format "->>>>>9.99"

         
            with frame f1 side-label width 80
title "C R E D I T O   --   VCTO LIMITE = " + if vvctoLimite = ? then "" else string(vvctoLimite,"99/99/9999") row 5 overlay.                     

    pause 0.
    disp vDTULTCPA       label "Ult. Compra "
         
         vQTDECONT       label "Contratos"
         
         vPARCPAG    label "    Pagas "
         vPARCABERT  label "Abertas"
         skip
        vDTULTNOV       label "Ult. Novacao"
         
         
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " 
                row 8 overlay.

def var v-mes as int format "99".
def var v-ano as int format "9999".


    disp 
         qtd-15       label "(ate 15 dias)"  COLON 20
         perc-15       format ">>9.99%" no-label
         vMEDIACONT label "Media por Contrato" format ">,>>9.99"
         qtd-45       label "(16 ate 45 dias)"  COLON 20
         perc-45      format ">>9.99%" no-label
         vMAIORACUM          label "Maior Acum. "
         vDTMAIORACUM       label "Mes/Ano" format "x(7)" 
         qtd-46       label "(acima de 45 dias)" COLON 20
         perc-46 format ">>9.99%" no-label
         vPARCMEDIA    label "Prest. Media"
         vrepar       label "Reparcelamento " colon 20
         vproximo-mes  label "Proximo Mes " colon 48
         
            with frame f4 side-label width 80 row 12
         title "A T R A S O               P A R C E L A S                    ".
         

    disp
        
        "Atraso-> Atual: " space(0)  
         vATRASOATUAL    no-label format ">>>>9"
         space(0)
         " (" space(0)  vDTMAIORATRASO    no-label space(0) ")"
         /*space(0) " Maior: " space (0)
         vMAIORATRASO    no-label format ">>>9 dias" */
        
         vVLRPARCVENC     label "Vencidas" 
         vcheque_devolvido label "Chq Devol"
         
            with frame f5 color white/red side-label no-box width 80.

    
    display regua1 with frame f-regua1.
        choose field regua1
               go-on(F4 PF4 h H)
               with frame f-regua1.

    if frame-index = 1 /*Historico*/
    then do:
    
        hide frame f-regua1 no-pause.
        /*if clien.clicod > 1
        then do:
            sresp = no.
            run mensagem.p (input-output sresp,
                            input "Para consultar o Historico o sistema fara   ~                                 uma nova busca de Informacoes na Matriz, 
                                   esta operacao podera levar alguns minutos   ~                                ."      + "!!" + "          VOCE CONFIRMA ? ",
                                  input "",
                                  input "    Sim",
                                  input "    Nao").
            if sresp then */   run conpreco.p(input estab.etbcod,
                                            input recid(clien)).
        /* end.
            view frame fcli . pause 0.*/
    end.

    if frame-index = 2 /*Historico*/
    then do:
    
        hide frame f-regua1 no-pause.
                hide frame f-regua1 no-pause.
        hide frame f1 no-pause.
        hide frame f2 no-pause.
        hide frame f3 no-pause.
        hide frame f4 no-pause.
        hide frame f5 no-pause.

        /*if clien.clicod > 1
        then do:
            sresp = no.
            run mensagem.p (input-output sresp,
                            input "Para consultar o Historico o sistema fara   ~                                 uma nova busca de Informacoes na Matriz, 
                                   esta operacao podera levar alguns minutos   ~                                ."      + "!!" + "          VOCE CONFIRMA ? ",
                                  input "",
                                  input "    Sim",
                                  input "    Nao").
            if sresp then */   
            run fin/bsfqtitag.p(input 0,
                                input clien.clicod).
        /* end.
            view frame fcli . pause 0.*/
    end.
    
    if frame-index = 3 /*and par-menu <> "novacao"*/
    then do:
        run neuro/compctr.p (clien.clicod).
    end.
    
    if frame-index = 4 /*and par-menu = "novacao"*/ and regua1[frame-index] <> ""
    then do:
        xetbcod = setbcod.
        if vhostname = "SV-CA-DB-DEV" or
           vhostname = "SV-CA-DB-QA"
        then message vhostname "Altera a Filial para Simular" update setbcod.
        
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
             + "-" + trim(if avail func then func.funnom else "")
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.

        hide frame f-regua1 no-pause.
        hide frame f1 no-pause.
        hide frame f2 no-pause.
        hide frame f3 no-pause.
        hide frame f4 no-pause.
        hide frame f5 no-pause.

        run fin/novorigemcli.p (clien.clicod).
        setbcod = xetbcod.
        
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
 
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.
        
    end.

    /* antigo acordo - helio 20092022 - acordo online - desabilitado 
    if frame-index = 4 and setbcod = 999 /* helio 20112020 */ 
    then do:
        xetbcod = setbcod.
        if vhostname = "SV-CA-DB-DEV" or
           vhostname = "SV-CA-DB-QA"
        then message vhostname "Altera a Filial para Simular" update setbcod.
        
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
             + "-" + trim(if avail func then func.funnom else "")
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


    *    run cob/novacao33.p (clien.clicod).
        setbcod = xetbcod.
        
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
 
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.

                
    end.
    */
    
    if frame-index = 5 /* novo Acordo - Acordo Matriz*/ and regua1[frame-index] <> ""

    then do:
        xetbcod = setbcod.

        if vhostname = "SV-CA-DB-DEV" or
           vhostname = "SV-CA-DB-QA"
        then message vhostname "Altera a Filial para Simular" update setbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        hide frame f-regua1 no-pause.
        hide frame f1 no-pause.
        hide frame f2 no-pause.
        hide frame f3 no-pause.
        hide frame f4 no-pause.
        hide frame f5 no-pause.
        
        run fin/novelesel.p (clien.clicod).
        
        setbcod = xetbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
 
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        
    end.
    
    
    if frame-index = 6 /* negociacao protesto - acordo iepro */ /* helio 23022022 - iepro */
        and regua1[frame-index] <> ""

    then do:
        xetbcod = setbcod.

        if vhostname = "SV-CA-DB-DEV" or
           vhostname = "SV-CA-DB-QA"
        then message vhostname "Altera a Filial para Simular" update setbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        hide frame f-regua1 no-pause.
        hide frame f1 no-pause.
        hide frame f2 no-pause.
        hide frame f3 no-pause.
        hide frame f4 no-pause.
        hide frame f5 no-pause.
        
        run iep/novnegocia.p (clien.clicod).
        
        setbcod = xetbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
 
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        
    end.

    if frame-index = 7 /* helio 20092022 - acordo online */
        and regua1[frame-index] <> ""

    then do:
        xetbcod = setbcod.

        if vhostname = "SV-CA-DB-DEV" or
           vhostname = "SV-CA-DB-QA"
        then message vhostname "Altera a Filial para Simular" update setbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        hide frame f-regua1 no-pause.
        hide frame f1 no-pause.
        hide frame f2 no-pause.
        hide frame f3 no-pause.
        hide frame f4 no-pause.
        hide frame f5 no-pause.
        
        run aco/tacoini.p ("ACORDO ONLINE", clien.clicod).
        
        setbcod = xetbcod.
        find estab where estab.etbcod = setbcod no-lock.
        pause 0.
        display trim(caps(wempre.emprazsoc)) + " / " + trim(caps(estab.etbnom))
         + "-" + trim(if avail func then func.funnom else "")
 
                    @  wempre.emprazsoc
                    wdata with frame fc1.
        pause 0.


        
    end.
 
    
    
end.


