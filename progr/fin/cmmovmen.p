/* helio #12092022 - https://trello.com/c/iw8Y42Zh/40-conta-para-fraude */
{cabec.i}


def input  parameter  par-CMon-Recid  as recid.
def input-output parameter par-transit as log.
def output parameter  sai-ctmcod     like  pdvtmov.ctmcod.
def output parameter  sai-operacao    as char.
    
find cmon where recid(cmon) = par-cmon-recid no-lock.
find cmtipo of cmon no-lock.
def var  vheader    as char format "x(77)".
if cmtipo.cmtcod = "EXT"
then vheader = "MOVIMENTACOES CREDIARIO".
else vheader =   
"   Recebimentos               Pagamentos                      Transferencias".


def shared var      l_souocmon      as log.
def buffer bcmon for cmon.

def var par-ctmcod     like pdvtmov.ctmcod.
def var vctmcod like pdvtmov.ctmcod extent 24 /* #12092022 */ .    
def var vpdvtmov as char extent 24 format "x(25)". /* #12092022 */
def var vi as int.
def var vescolha as int.


/**/
def new shared workfile wfcmonlan
    field data          as date     format "99/99/9999"
    field modcod        like modal.modcod
    field rec-cmonlan   as recid
    field tipo          as char.


def var vmodsaldo-anterior     like modsano.modsal label "Anterior".
def var vsaldo-anterior     like modsano.modsal label "Anterior".
def var vmodsaldo-atual        like modsano.modsal label "Atual".
def var vsaldo-atual        like modsano.modsal label "Atual".
def var vsaldo-geral        like modsano.modsal label "Geral".
def var vlimite             like modsano.modsal label "Limite".
def var vdisponivel         like modsano.modsal label "Disponivel".
def var vtotal-credito      like modsano.modsal label "Saidas".
def var vpre-debito         like modsano.modsal label "Pre Entrada".
def var vpre-Credito        like modsano.modsal label "Pre Saida".
def var vcon-debito         like modsano.modsal label "Conf Entrada".
def var vcon-Credito        like modsano.modsal label "Conf Saida".
def var vtotal-debito       like modsano.modsal label "Entradas".
def var vchar as char.

def var par-dtini as date.
def new shared frame f-cmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "PDV" format ">>9"
         CMon.cxanom    no-label
         par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def new shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.


def shared frame f-ecmon.
    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "CAIXA"
         CMon.cxanom             no-label
                  par-dtini          label "Dt Ini"
         CMon.cxadt         colon 65 format "99/99/9999" label "Data"
         with frame f-eCMon row 3 width 81 three-d
                         side-labels no-box.
    


/**/

def var esqcom1         as char format "x(14)" extent 5
            initial [" 1-Consultas",
                     " 2-Totais",
                     ""
                     /*
                     " 2-Consultas ",
                     " 3-Fechamentos ",
                     " 4-Relatorios ",
                     " 5-Operacoes "
                     */
                      ].
form
    esqcom1
    with frame f-com1 three-d
                 row 17 no-labels side-labels column 1
                 centered no-box.
disp esqcom1 with  frame f-com1.

def var esqpos2         as int.

def var esqcom2         as char format "x(41)" extent 6.

form                    
    esqcom2[1] skip(1)
    esqcom2[2] skip(1)
    esqcom2[3] skip(1)
    esqcom2[4] skip(1)
    esqcom2[5] skip(1)
    esqcom2[6]
    with frame f-com2 row screen-lines - 13 no-labels side-labels 
                                column 1 overlay.
esqpos2 = 1.

if cmtipo.cmtcod = "EXT"
then do:
    vi = 1.
    for each pdvtmov of cmtipo no-lock
        BY PDVTMOV.CTMnom.
        vpdvtmov[vi] = 
                        /*string(vi) +   "-" +  */
                        pdvtmov.ctmnom.
        vctmcod[vi] = pdvtmov.ctmcod.
        vi = vi + 1.
        
    end.
        
end.




    

        display 
             cmon.cxanom     
                with frame f-eCMon.




form header 
vheader
        with frame fchoose-pdvtmov.

form 
     vpdvtmov[1] vpdvtmov[2] vpdvtmov[3] skip
     vpdvtmov[4] vpdvtmov[5] vpdvtmov[6] skip
     vpdvtmov[7] vpdvtmov[8] vpdvtmov[9] skip
     vpdvtmov[10] vpdvtmov[11] vpdvtmov[12] skip
     vpdvtmov[13] vpdvtmov[14] vpdvtmov[15] skip
     vpdvtmov[16] vpdvtmov[17] vpdvtmov[18] skip
     vpdvtmov[19] vpdvtmov[20] vpdvtmov[21] skip
     vpdvtmov[22] vpdvtmov[23] vpdvtmov[24] skip


                with frame fchoose-pdvtmov row 5 col 5 no-label 
                    width 80
                        side-labels                centered three-d.
       
       
                           
       
 /******/      
 repeat:
    repeat.
        disp esqcom1 with frame f-com1.
        par-ctmcod = "".
       view frame f-tot. 
       view frame f-ecmon.
       disp
           vpdvtmov
                with frame fchoose-pdvtmov.
            choose field vpdvtmov auto-return go-on(1 2 3 4 5
                F4 PF4 RETURN)
                    with frame fchoose-pdvtmov.
            if keyfunction(lastkey) = "end-error"
            then leave.                  
            if keyfunction(lastkey) = "return"
            then do:
                par-ctmcod =  vctmcod[frame-index].
                leave.
            end. 
            if keyfunction(lastkey) = "1" or
               keyfunction(lastkey) = "2" or
               keyfunction(lastkey) = "3" or
               keyfunction(lastkey) = "4" or
               keyfunction(lastkey) = "5" 
            then do:
                vescolha = int(keyfunction(lastkey)). 
                    if vescolha = 1                  /* Movimentacoes    */
                    then do:
                        hide frame fchoose-pdvtmov no-pause.
                        hide frame f-com1 no-pause.
                    
                        display today @ cmon.cxadt
                                    with frame f-ecmon.
                        prompt-for cmon.cxadt
                                       with frame f-ecmon.

                        run dpdv/pdvcmov.p (input recid(cmon),
                                            input input frame f-ecmon cmon.cxadt)
                                            no-error.
                                            
     
                    end.
                    if vescolha = 2
                    then do:
                        hide frame   fchoose-pdvtmov no-pause.
                                                hide frame fchoose-pdvtmov no-pause.
                        hide frame f-com1 no-pause.

                            display today @ cmon.cxadt 
                                    with frame f-ecmon.
                            if par-dtini = ?
                                    then par-dtini = today.
                            update par-dtini
                                        with frame f-ecmon.
                            
                            prompt-for cmon.cxadt
                                       with frame f-ecmon.

                        run dpdv/pdvtmov.p (input frame f-ecmon cmon.etbcod,
                                       if avail cmon
                                       then recid(cmon)
                                       else ?,
                                       par-dtini,
                                       input frame f-ecmon cmon.cxadt,
                                       "").
                        
                    end.    
                    
                    view frame f-com1.
                    

            end.
            

    end.                        

    if par-ctmcod = ""
    then do:
           
hide frame frame-a no-pause.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame f-tot no-pause.
hide frame ftransf no-pause.
hide frame fconf no-pause.
hide frame fchoose-pdvtmov no-pause.
        return "".
    end.        
    
            

    hide frame frame-a no-pause.
    hide frame f-com1  no-pause.
    hide frame f-com2  no-pause.
    hide frame f-tot no-pause.
    hide frame ftransf no-pause.
    hide frame fconf no-pause.
    hide frame fchoose-pdvtmov no-pause.

    sai-ctmcod = par-ctmcod.    
    sai-operacao = "Movimento".
    leave.
end.    
    
    
                                                   
