/*
*
*    pdvcons.p    -    Esqueleto de Programacao    com esqvazio


            substituir    pdvmov
                          <tab>
*
*/

def var vforma as char.
def var vctmseq as int.
def var vlistagem as log.
def var vvalor as dec.
def var vseq as int.
def buffer bfunc for func.
def var vfunape  like func.funape.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial no.
def var esqcom1         as char format "x(12)" extent 5
    initial [" Listagem "," ","", " "," "].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5.
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

def var crelatorios     as char format "x(30)" extent 5 initial
           [
            "Lancamento Contabil ",
            "Listagem ",
            "Recibo ",
            "Imp.Cheque",
            ""].

{admcab.i}

def input parameter  par-etbcod as int.
def input parameter  par-cmon-recid     as recid.
def input parameter  par-dtini           as date format "99/99/9999".
def input parameter  par-dtfim           as date.
def input parameter  par-ctmcod         as char.

def var vhora               as  char format "x(5)" label "Hora".
def var vcmopevlr   as dec.
def var vjurodesc   as dec format "(>>>>9.99)".
def var vestorno    as char.
def var vdt       as date format "99/99/9999".

/*
find CMon   where recid(CMon) = par-CMon-Recid no-lock no-error.
find cmtipo of cmon no-lock.
*/

def temp-table ttmoeda
    field ctmseq  as int
    field ctmcod  like pdvtmov.ctmcod  
    field seq as int 
    field descrctm as char format "x(12)"
    field pdvtfnom as char format "x(18)"
    FIELD valor   as dec  format "->>>,>>>,>>9.99"
    index x is unique primary  ctmseq asc ctmcod asc seq asc.
 
form            
    ttmoeda.descrctm
    ttmoeda.pdvtfnom
    ttmoeda.valor
     with frame frame-a 14 down row 5 
                  centered color messages
                 overlay.
 
form            
    ttmoeda.descrctm
    ttmoeda.pdvtfnom
    ttmoeda.valor
     with frame frame-b down.
     
                 
pause 0.
                  /*
def shared frame f-cmon.
                    */

    form cmon.etbcod    label "Etb" format ">>9"
         CMon.cxacod    label "CAIXA" format ">>9"
         CMon.cxanom             no-label
         par-dtini      label "Dt Ini"
         CMon.cxadt     format "99/99/9999" label "Data"
         with frame f-CMon row 3 width 81
                         side-labels no-box.
def shared frame f-banco.
    form
        CMon.bancod    colon 12    label "Bco/Age/Cta"
        CMon.agecod             no-label
        CMon.ccornum            no-label format "x(15)"
        CMon.cxanom              format "x(16)" no-label
        func.funape             format "x(10)" no-label
        CMon.cxadt          format "99/99/9999" no-label
         with frame f-banco row 3 width 81 /*color messages*/
                         side-labels no-box.

find cmon where recid(cmon) = par-cmon-recid no-lock no-error.

        display par-etbcod @ cmon.etbcod
                CMon.cxanom when avail cmon
                CMon.cxacod when avail cmon
                with frame f-CMon.
    if not avail cmon
    then disp "Geral" @ cmon.cxanom 
        with frame f-cmon.

    disp par-dtini when par-dtini <> par-dtfim
         par-dtfim @ cmon.cxadt
         with frame f-cmon.
                 /*
if par-data <> ?
then vdata = par-data.

        display vdata @ CMon.cxadt
                with frame f-CMon.
                   */
                   
form
    esqcom1
    with frame f-com1
                 row 21 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.


vseq = 0.   
for each estab where
    if par-etbcod = 0 then true
    else estab.etbcod = par-etbcod
    no-lock,
    each cmon where cmon.etbcod = estab.etbcod and
    (if par-cmon-recid = ?
     then true
     else recid(cmon) = par-cmon-recid)
     no-lock.

find cmtipo of cmon no-lock.

for each pdvmoe of cmon where 
                                        pdvmoe.datamov >= par-dtini and
                                        pdvmoe.datamov <= par-dtfim
                                        no-lock
        , first pdvforma of pdvmoe no-lock
        break by pdvmoe.ctmcod
              by pdvforma.pdvtfcod .
    find pdvmov of pdvmoe no-lock.
    if par-ctmcod <> ""
    then if pdvmoe.ctmcod <> par-ctmcod
         then next.   
        
    find pdvmov of pdvmoe no-lock.
    if pdvmov.statusoper = "CAN" then next.
                     
    find pdvtmov of pdvmoe no-lock.
    if true 
        /**pdvtmov.ctmcod = "VEN" or
       pdvtmov.ctmcod = "REC" or
       pdvtmov.ctmcod = "ORC"
       **/
    then assign
            /**vmoecod = pdvmoe.moecod**/
            vctmseq = 0.
    else if pdvtmov.ctmcod = "RCX"
         then assign
                /**vmoecod = ""**/
                vctmseq = 4.
         else assign
                /**vmoecod = ""**/
                vctmseq = 1.
       
    find first ttmoeda where 
            ttmoeda.ctmcod = pdvmoe.ctmcod and
            ttmoeda.ctmseq = vctmseq and
            ttmoeda.seq =  1 no-error.
    if not avail ttmoeda then do:
        vseq = vseq + 1. 
        create ttmoeda.
        ttmoeda.ctmseq  = vctmseq.
        ttmoeda.ctmcod  = pdvmoe.ctmcod.
        ttmoeda.seq     = 1.
/**        ttmoeda.moecod = "".**/
        ttmoeda.pdvtfnom = "".
        ttmoeda.descrctm = pdvtmov.ctmnom.
   end.

   find first pdvtforma of pdvforma no-lock no-error. 
   vforma = if avail pdvtforma 
            then pdvtforma.pdvtfnom 
            else pdvforma.pdvtfcod.

    find first ttmoeda where 
            ttmoeda.ctmcod = pdvmoe.ctmcod and
            ttmoeda.pdvtfnom = vforma
             /**and
            ttmoeda.moecod = vmoecod 
            **/
            no-error.
    if not avail ttmoeda then do:
        vseq = vseq + 1.
        create ttmoeda.
        ttmoeda.ctmseq  = vctmseq.
        
        ttmoeda.ctmcod  = pdvmoe.ctmcod.
        ttmoeda.seq = vseq.
/**        ttmoeda.moecod = vmoecod.**/
        ttmoeda.pdvtfnom = vforma.
   end.
   ttmoeda.valor = ttmoeda.valor + pdvmoe.valor.

/* Totalizacao */
    find first ttmoeda where 
            ttmoeda.ctmcod = "VENDAS LIQUIDAS" and
            ttmoeda.ctmseq = 0 and
            ttmoeda.seq =  1 no-error.
    if not avail ttmoeda then do:
        vseq = vseq + 1. 
        create ttmoeda.
        ttmoeda.ctmseq  = 0.
        ttmoeda.ctmcod  = "VENDAS LIQUIDAS".
        ttmoeda.seq     = 1.
/**        ttmoeda.moecod = "".**/
        ttmoeda.pdvtfnom = "".
        ttmoeda.descrctm = "VENDAS LIQUIDAS".
   end.
   if true
        /**pdvmoe.ctmcod = "VEN" or
      pdvmoe.ctmcod = "ORC"
      **/
   then do:   
    find first ttmoeda where 
            ttmoeda.ctmcod  = "VENDAS LIQUIDAS" and
            ttmoeda.pdvtfnom = "VENDAS" /**and
            ttmoeda.moecod  = "VEN" 
            **/ 
            no-error.
    if not avail ttmoeda then do:
        create ttmoeda.
        ttmoeda.ctmseq  = 0.
        
        ttmoeda.ctmcod  = "VENDAS LIQUIDAS".
        ttmoeda.seq = 2.
/**        ttmoeda.moecod = "VEN".**/
        ttmoeda.pdvtfnom = "VENDAS".
   end.
   ttmoeda.valor = ttmoeda.valor + pdvmoe.valor.
   end.
    find first ttmoeda where 
            ttmoeda.ctmcod = pdvmoe.ctmcod and
            ttmoeda.pdvtfnom = "              Total:" no-error.
    if not avail ttmoeda then do:
        create ttmoeda.
        ttmoeda.ctmseq  = vctmseq.
        
        ttmoeda.ctmcod  = pdvmoe.ctmcod.
        ttmoeda.seq = 99.
        ttmoeda.pdvtfnom = "              Total:".        
        
   end.
   ttmoeda.valor = ttmoeda.valor + pdvmoe.valor.

/* totalizadcao de vendas */
   if true
        /**pdvmoe.ctmcod = "VEN" or
      pdvmoe.ctmcod = "ORC"
      **/
   then do:   

    find first ttmoeda where 
            ttmoeda.ctmcod = "VENDAS LIQUIDAS" and
            ttmoeda.pdvtfnom = "            Liquida:" no-error.
    if not avail ttmoeda then do:
        create ttmoeda.
        ttmoeda.ctmseq  = 0.
        
        ttmoeda.ctmcod  = "VENDAS LIQUIDAS".
        ttmoeda.seq = 99.
        ttmoeda.pdvtfnom = "            Liquida:".        
        
   end.
   ttmoeda.valor = ttmoeda.valor + pdvmoe.valor.
    end.

    if par-ctmcod = "" and pdvtmov.ctmcod <> "SCX" 
    then do:
        
        find first ttmoeda where 
                ttmoeda.ctmcod = "ZSAL" and
                ttmoeda.pdvtfnom = "" no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 5.
            
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZSAL".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "Saldos".
/**            ttmoeda.moecod = "".**/
            ttmoeda.pdvtfnom = "".
         def var vsaldo-atual as dec.
       
        find first ttmoeda where 
                ttmoeda.ctmcod = "ZSAL" and
                ttmoeda.pdvtfnom = "Inicial" no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 5.
            
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZSAL".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "".
/**            ttmoeda.moecod = "". /*pdvmoe.modcod.*/**/
            ttmoeda.pdvtfnom = "Inicial".
            
       end.
       /***
         run cbmodsal.p (input cmtipo.modcod,
                        input cmon.cmocod,
                        input par-dtini - 1,
                        output vsaldo-atual,
                        output ttmoeda.valor).
        ***/
        vsaldo-atual = ttmoeda.valor.    
        vvalor = if pdvmov.entsai 
                 then pdvmoe.valor
                 else (pdvmoe.valor * -1).

     end.
/**/ if pdvmoe.moecod = "REA" or
        pdvmoe.moecod = "DIN"
     then do:
        
        find first ttmoeda where 
                ttmoeda.ctmcod = "ZSAL" and
                ttmoeda.pdvtfnom = if pdvmov.entsai
                                  then "Entradas"
                                  else "Sangrias" no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 5.
            
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZSAL".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "".
/**            ttmoeda.moecod = "". /*pdvmoe.modcod.*/**/
            ttmoeda.pdvtfnom = if pdvmov.entsai 
                              then "Entradas"
                                else "Sangrias" . /*pdvmoe.descrfp.*/
       end.
               
       ttmoeda.valor = ttmoeda.valor + pdvmoe.valor.
       vsaldo-atual = vsaldo-atual + if pdvmov.entsai
                                     then pdvmoe.valor
                                     else (pdvmoe.valor * -1).

        find first ttmoeda where 
                ttmoeda.ctmcod = "ZSAL" and
                ttmoeda.pdvtfnom = "                   Total:"
                no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 5.
            
            ttmoeda.ctmcod  = "ZSAL".
            ttmoeda.seq = 99.
/**            ttmoeda.moecod = "              Total:".**/
            ttmoeda.pdvtfnom = "                   Total:".
            ttmoeda.valor = vsaldo-atual.
       end.
        ttmoeda.valor = vsaldo-atual. /*ttmoeda.valor + vvalor.*/
      end.  
        /* recebimentos */
        
       vvalor = if pdvmov.entsai 
                 then pdvmoe.valor
                 else 0. /*(pdvmoe.valor * -1).*/
         find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.pdvtfnom = "" no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 3.
            
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "Entradas".
/**            ttmoeda.moecod = "".**/
            ttmoeda.pdvtfnom = "".
       end.
   find first pdvtforma of pdvforma no-lock no-error. 
   vforma = if avail pdvtforma 
            then pdvtforma.pdvtfnom 
            else pdvforma.pdvtfcod.

        
        find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.pdvtfnom = vforma no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 3.
            
            vseq = vseq + 1.
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = vseq.
            ttmoeda.descrctm = "".
/**            ttmoeda.moecod = "". /*pdvmoe.modcod.*/**/
            ttmoeda.pdvtfnom = vforma.
       end.
       ttmoeda.valor = ttmoeda.valor + vvalor.

        find first ttmoeda where 
                ttmoeda.ctmcod = "ZMOE" and
                ttmoeda.pdvtfnom = "                   Total:"
                no-error.
        if not avail ttmoeda then do:
            create ttmoeda.
            ttmoeda.ctmseq  = 3.
            
            ttmoeda.ctmcod  = "ZMOE".
            ttmoeda.seq = 99.
/**            ttmoeda.moecod = "              Total:".**/
            ttmoeda.pdvtfnom = "                   Total:".
       end.
        ttmoeda.valor = ttmoeda.valor + vvalor.
         
    end.

end.   
end. 

def var vcm as int.
def buffer bcmon for cmon.
vcm = 0.
if par-cmon-recid <> ?
then do:
    for each bcmon where bcmon.etbcod = par-etbcod and
                         bcmon.cmtcod = "PDV" no-lock.
        vcm = vcm + 1.
    end.    
end.

if par-cmon-recid = ? or
   vcm = 1
then do:
    for each estab where
        if par-etbcod = 0 then true
        else estab.etbcod = par-etbcod
        no-lock,
        each tipmov where
        tipmov.movtvenda = yes and
        tipmov.movtdev   = yes
        no-lock.
        for each plani where
            plani.dtinclu >= par-dtini and 
            plani.dtinclu <= par-dtfim and
            plani.etbcod = estab.etbcod and
            plani.movtdc = tipmov.movtdc and
            plani.notsit = no
            no-lock.
            /***
            for each nottit of plani no-lock.
                find titulo where
                    titulo.titcod = nottit.titcod no-lock no-error.
                if avail titulo
                then do:
    
                    find first ttmoeda where 
                        ttmoeda.ctmcod = "VENDAS LIQUIDAS" and
                        ttmoeda.descrfp = "DEVOLUCOES EMITIDAS" and
                        ttmoeda.modcod = titulo.modcod no-error.
                    if not avail ttmoeda then do:
                        vseq = vseq + 1.
                        create ttmoeda.
                        ttmoeda.ctmseq  = 0.
        
                        ttmoeda.ctmcod  = "VENDAS LIQUIDAS".
                        ttmoeda.seq = vseq.
                        ttmoeda.modcod = titulo.modcod.
                        ttmoeda.descrfp = "DEVOLUCOES EMITIDAS".
                    end.
                    ttmoeda.valor = ttmoeda.valor + titulo.titvlcob.


    find first ttmoeda where 
            ttmoeda.ctmcod = "VENDAS LIQUIDAS" and
            ttmoeda.modcod = "            Liquida:" no-error.
    if not avail ttmoeda then do:
        create ttmoeda.
        ttmoeda.ctmseq  = 0.
        
        ttmoeda.ctmcod  = "VENDAS LIQUIDAS".
        ttmoeda.seq = 99.
        ttmoeda.modcod = "            Liquida:".        
        ttmoeda.descrfp = "                    ".
        
   end.
   ttmoeda.valor = ttmoeda.valor - titulo.titvlcob.

                    
                end.    
            end.
            */
        end.
    end.    
end.
else do:
end.

for each ttmoeda where ttmoeda.ctmcod = "Zsal" and
                       ttmoeda.descrctm <> "Saldos" and
                       ttmoeda.seq <> 99
                       and ttmoeda.valor = 0.
    delete ttmoeda.
end.

        
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.
    esqascend = yes.
bl-princ:
repeat:
    hide frame frelatorios no-pause.
    hide frame fcolor      no-pause.
    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then
        if esqascend
        then
            find first ttmoeda 
                                        no-lock no-error.
        else
            find last ttmoeda
                                        no-lock no-error.
    else
        find ttmoeda where recid(ttmoeda) = recatu1 no-lock.
    if not available ttmoeda
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.
    else do:
        message "Nenhuma Movimento".
        pause 1 no-message.
        leave bl-princ.
    end.

    recatu1 = recid(ttmoeda).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    /*else color display message esqcom2[esqpos2] with frame f-com2.**/
    if not esqvazio
    then repeat:
        if esqascend
        then
            find next ttmoeda where true
                                        no-lock no-error.
        else
            find prev ttmoeda where true
                                        no-lock no-error.
        if not available ttmoeda
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
            find ttmoeda where recid(ttmoeda) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then  string(ttmoeda.pdvtfnom)
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then string(ttmoeda.pdvtfnom)
                                        else "".

            clear frame frame-esquerda all no-pause.
            clear frame frame-direita  all no-pause.
            hide frame frame-esquerda  no-pause.
            hide frame frame-direita   no-pause.
            
            display esqcom1
                    with frame f-com1.
            color disp normal
                ttmoeda.descrctm
/**                ttmoeda.moecod
                vmoenom **/
                ttmoeda.pdvtfnom
                ttmoeda.valor
                with frame frame-a.
                                choose field ttmoeda.pdvtfnom help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      /*tab*/ PF4 F4 ESC return) 
                      color normal.
            color disp messages
                ttmoeda.descrctm
/**                ttmoeda.moecod
                vmoenom **/
                ttmoeda.valor
                ttmoeda.pdvtfnom
                with frame frame-a.
                     
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
                    if esqascend
                    then
                        find next ttmoeda  where true
                                            no-lock no-error.
                    else
                        find prev ttmoeda  where true
                                            no-lock no-error.
                    if not avail ttmoeda
                    then leave.
                    recatu1 = recid(ttmoeda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    if esqascend
                    then
                        find prev ttmoeda  where true
                                        no-lock no-error.
                    else
                        find next ttmoeda  where true
                                        no-lock no-error.
                    if not avail ttmoeda
                    then leave.
                    recatu1 = recid(ttmoeda).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                if esqascend
                then
                    find next ttmoeda  where true
                                    no-lock no-error.
                else
                    find prev ttmoeda  where true
                                    no-lock no-error.
                if not avail ttmoeda
                then next.
                color display messages ttmoeda.pdvtfnom with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                if esqascend
                then
                    find prev ttmoeda  where true
                                    no-lock no-error.
                else
                    find next ttmoeda  where true
                                    no-lock no-error.
                if not avail ttmoeda
                then next.
                color display messages ttmoeda.pdvtfnom with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.


        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            form ttmoeda
                 with frame f-ttmoeda color black/cyan
                      centered side-label row 5 .
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.
                if esqcom1[esqpos1] = " Listagem "
                then do:
                    run listagem.
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
        /*else display esqcom2[esqpos2] with frame f-com2.*/
        recatu1 = recid(ttmoeda).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1           no-pause.
hide frame f-com2           no-pause.
hide frame frame-a          no-pause.
hide frame frame-esquerda   no-pause.
hide frame frame-direita    no-pause.
hide frame f-banco          no-pause.
hide frame f-cmon           no-pause.
hide frame separa           no-pause.
hide frame separa2          no-pause.
hide frame frelatorios      no-pause.
hide frame fcolor           no-pause.

PROCEDURE frame-a.
            
        /**
        find moeda of ttmoeda no-lock no-error.
        vmoenom = if avail moeda 
                  then moeda.moenom
                  else ttmoeda.moecod.
        **/
        if vlistagem
        then do:
        display
            ttmoeda.descrctm
/**            ttmoeda.moecod
            vmoenom**/
            ttmoeda.pdvtfnom
            ttmoeda.valor when ttmoeda.valor <> 0
                    with frame frame-b no-labels.
            down with frame frame-b.
        end.
        else
        display
            ttmoeda.descrctm
/**            ttmoeda.moecod
            vmoenom**/
            ttmoeda.pdvtfnom
            ttmoeda.valor when ttmoeda.valor <> 0
                    with frame frame-a no-labels.

end procedure.



procedure listagem.
/**
vlistagem = yes.
varqsai = "../impress/pdvtmoe." + string(time).
def var vtitle as char.                                         
vtitle = (if avail cmon                                          
          then string(cmon.etbcod) + " " + cmon.cxanom           
          else string(par-etbcod)  + " GERAL ")
          +
          if par-dtini <> par-dtfim
          then (" PERIODO " + string(par-dtini,"99/99/9999") + 
                " A "    + string(par-dtfim,"99/99/9999"))
          else (" DATA " + string(par-dtini,"99/99/9999")).
                                                                                  
{mdadmcab.i
    &Saida     = "value(varqsai)"
    &Page-Size = "64"
    &Cond-Var  = "80"
    &Page-Line = "66"
    &Nom-Rel   = ""pdvtmov""
    &Nom-Sis   = """BSSHOP"""
    &Tit-Rel   = " ""MOVIMENTOS - "" +
                    string(vtitle) "
    &Width     = "80"
    &Form      = "frame f-cabcab"}

for each ttmoeda where true.
    run frame-a.
end.

{mdadmrod.i
    &Saida     = "value(varqsai)"
    &NomRel    = """LISCMD"""
    &Page-Size = "64"
    &Width     = "80"
    &Traco     = "80"
    &Form      = "frame f-rod3"}.
vlistagem = no.
**/

end procedure.




