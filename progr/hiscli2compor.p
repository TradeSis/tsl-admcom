/* helio 20072022 - ID 139086 - ERRO no adm 
    programa correto eh o cob/ hiscli2compor.p 
    */
    
run cob/hiscli2compor.p (?,""). 

/* descontinuado
*{cabec.i}

{neuro/achahash.i}
{neuro/varcomportamento.i}
def var regua1      as char format "x(10)" extent /*8*/ 2
    initial ["Historico","" /*"Cadastro"*/ ].
                 
form regua1 with frame f-regua1
          row 19 no-labels side-labels column 1 centered title "Operacoes".

def var vDTULTCPA as date format "99/99/9999".
def var vQTDECONT   as int format ">>>9".
def var vPARCPAG    as int format ">>>>9".
def var vPARCABERT  as int format ">>>>9".
def var vMEDIACONT  as dec.
def var vMAIORACUM  as dec.
def var vDTMAIORACUM    as char.
def var vPARCMEDIA  as dec.
def var vTOTALNOV   as dec.
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


def var vvlrlimite as dec.
def var vvctolimite as date.
def var vcomprometido as dec.
def var vcomprometido-principal as dec.
def var vsaldoLimite as dec.
def var vdtultpagto as date.
def var vspc_lebes as log.
def var vclicod like clien.clicod.


repeat
    with frame fcli row 3 side-labels 
        title "Conta do Cliente" 1 down.
    
    update vclicod label "Conta"
        with frame fcli.
    find clien where clien.clicod = vclicod no-lock.
    disp clien.clinom no-label format "x(49)"
         clien.dtcad no-label format "99/99/9999"
         with frame fcli.
    
    find clien where clien.clicod = vclicod no-lock.
    find neuclien where neuclien.clicod = clien.clicod no-lock no-error.
    
    vvlrlimite = 0.
    vvctolimite = ?.
    vdtultpagto = ?.
    vcomprometido = 0.
    vsaldoLimite = 0.
    vspc_lebes  = no.
    vrepar = no.
    
    if avail neuclien
    then do:
        vvlrlimite = neuclien.vlrlimite.
        vvctolimite = neuclien.vctolimite.
    end.
    

    def var c1 as char.
    def var r1 as char format "x(30)".
    def var il as int.
    def var vcampo as char format "x(20)". 

    var-propriedades = "".
    
    run neuro/comportamento.p (clien.clicod,?,output var-propriedades).

    do il = 1 to num-entries(var-propriedades,"#") with down.
    
        vcampo = entry(1,entry(il,var-propriedades,"#"),"=").
        if vcampo = "FIM"
        then next.
        r1 = pega_prop(vcampo).
        if vcampo = "LIMITETOMPR"
        then vcomprometido-principal = dec(r1).
        if vcampo = "LIMITETOM" 
        then vcomprometido = dec(r1).
        if vcampo = "DTULTPAGTO"
        then  vdtultpagto = date(r1).
        if vcampo = "DTULTCPA"
        then vDTULTCPA = date(r1).
        if vcampo = "QTDECONT"
        then vQTDECONT = int(r1).
        if vcampo = "PARCPAG"
        then vPARCPAG = int(r1).
         if vcampo = "PARCABERT"
        then vPARCABERT = int(r1).
        if vcampo = "ATRASOPARC"
        then do:
            qtd-15 = int(entry(1,r1,"|")).
            qtd-45 = int(entry(2,r1,"|")).
            qtd-46 = int(entry(3,r1,"|")).
        end.
        if vcampo = "ATRASOPARCPERC"
        then do:
            r1 = replace(r1,"%","").
            perc-15 = dec(entry(1,r1,"|")).
            perc-45 = dec(entry(2,r1,"|")).
            perc-46 = dec(entry(3,r1,"|")).
        end.
        if vcampo = "MEDIACONT"
        then vMEDIACONT = dec(r1).
        if vcampo = "MAIORACUM"
        then vMAIORACUM = dec(r1).
        if vcampo = "DTMAIORACUM"
        then vDTMAIORACUM = r1.
        if vcampo = "PARCMEDIA"
        then vPARCMEDIA = dec(r1).
        if vcampo = "TOTALNOV"
        then do:
            vTOTALNOV  = dec(r1).
            vrepar     = yes.
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
    
    vsaldoLimite = vvlrlimite - vcomprometido-principal.
    
    if vvctolimite < today or vvctolimite = ? or
        vsaldoLimite < 0
    then vsaldoLimite = 0. 
    
    disp vvlrLimite  label "Credito"
         vvctoLimite label "Venc"
         vcomprometido   label "Aberto"
         vsaldoLimite label "Calculado"
            with frame f1 side-label width 80
                    title "C R E D I T O" row 6.

    disp vDTULTCPA       label "Ult. Compra"
         
         vQTDECONT       label "Contratos"
         
         vPARCPAG    label "    Pagas "
         vPARCABERT  label "Abertas"
         
         
            with frame f2 side-label width 80
                title "  C O M P R A S              P R E S T A C O E S " row 9.

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
         vATRASOATUAL    no-label format ">>>9"
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
     
end.
desconmtinuado ***/

