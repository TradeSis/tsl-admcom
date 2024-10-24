/*26022021 helio*/

{admcab.i}

def var pfiltro as char.

def input param pcontnum like ctbposhiscart.contnum.
def input param pcobcod  like ctbposhiscart.cobcod.

def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              
def shared temp-table tt-modalidade-selec 
    field modcod as char.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial ["<Parcela>",""," "," "," "].
form
    esqcom1
    with frame f-com1 row 5 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/**if poperacao = "NOVACAO"
then esqcom1[3] = "<Novacao>".
**/

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


def new shared temp-table ttnovacao no-undo
    field tipo      as char
    field contnum   like contrato.contnum format ">>>>>>>>>>9"
    field valor     like contrato.vltotal
    index idx is unique primary tipo desc contnum asc.


def  temp-table ttcontrato no-undo
    field prec as recid
    index contnum   is unique primary
        prec asc.
        
def buffer bttcontrato for ttcontrato.
        
def var vfiltro as char.

    vfiltro = "-". /*caps(poperacao) + "/" + caps(pstatus).*/
    
disp
    vfiltro no-label format "x(50)"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        ctbposhiscart.titpar   
        titulo.titdtven
        titulo.titvlcob  column-label "valor" 
                                     format ">>>>>9.99"
        ctbposhiscart.valor column-label "saldo" format ">>>>>9.99" 
        titulo.titdtpag column-label "Dt Liq"
        
        with frame frame-a 9 down centered row 7
        no-box.

run montatt.


/**disp 
    space(32)
    vtitvlcob    no-label          format   "-zzzzzzz9.99"
    vjuros       no-label           format     "-zzzzz9.99"
    vdescontos   no-label        format     "-zzzzz9.99"
    vtotal       no-label          format   "-zzzzzzz9.99"
        with frame ftot
            side-labels
            row screen-lines - 1
            width 80
            no-box.
**/


bl-princ:
repeat:


/**disp
    vtitvlcob
    vjuros
    vdescontos
    vtotal   

        with frame ftot.
**/

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcontrato where recid(ttcontrato) = recatu1 no-lock.
    if not available ttcontrato
    then do.
        message "nenhum registro encontrato".
        pause.
        return.
        /*
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
        */
        
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttcontrato).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcontrato
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcontrato where recid(ttcontrato) = recatu1 no-lock.

        status default "".
        
                        
        /**                        
        esqcom1[1] = if ttcontrato.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttcontrato.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttcontrato.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttcontrato.carteira = ? or
                        ttcontrato.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttcontrato.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttcontrato.cobcod = ?
                     then "Propriedade"
                     else "".
        **/
                     
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 6.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 6.
            esqcom1[vx] = "".
        end.     
        
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field contrato.contnum
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                run color-normal.
        pause 0. 

                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 6 then 6 else esqpos1 + 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "cursor-left"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 1 then 1 else esqpos1 - 1.
                color display messages esqcom1[esqpos1] with frame f-com1.
                next.
            end.
            if keyfunction(lastkey) = "page-down"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "down").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcontrato
                    then leave.
                    recatu1 = recid(ttcontrato).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcontrato
                then next.
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcontrato
                then next.
                color display white/red contrato.contnum with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then do:
            
            if esqcom1[esqpos1] = "<parcela>"
            then do:
                find ctbposhiscart where recid(ctbposhiscart) = ttcontrato.prec no-lock.
                find contrato where contrato.contnum = ctbposhiscart.contnum no-lock.    
                find first titulo where titulo.empcod = 19 and titulo.titnat = no and
                        titulo.etbcod = contrato.etbcod and
                        titulo.modcod = contrato.modcod and
                        titulo.clifor = contrato.clicod and
                        titulo.titnum = string(contrato.contnum) and
                        titulo.titpar = ctbposhiscart.titpar and
                        recid(titulo) = trecid 
                            no-lock no-error.
                if avail titulo
                then run bsfqtitulo.p (recid(titulo)).
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcontrato).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    find ctbposhiscart where recid(ctbposhiscart) = ttcontrato.prec no-lock.
    find contrato where contrato.contnum = ctbposhiscart.contnum no-lock.    
    find first titulo where titulo.empcod = 19 and titulo.titnat = no and
            titulo.etbcod = contrato.etbcod and
            titulo.modcod = contrato.modcod and
            titulo.clifor = contrato.clicod and
            titulo.titnum = string(contrato.contnum) and
            titulo.titpar = ctbposhiscart.titpar and
            recid(titulo) = trecid
            no-lock no-error.
    display  
        contrato.etbcod column-label "Fil"
        contrato.contnum format ">>>>>>>>>9"
        titulo.modcod
        titulo.tpcontrato
        titulo.cobcod
        ctbposhiscart.titpar   
        titulo.titdtven when avail titulo format "999999" column-label "Venc"
        titulo.titvlcob  column-label "valor"  format ">>>>>9.99" when avail titulo
        ctbposhiscart.valor column-label "saldo" format ">>>>>9.99" 
        titulo.titdtpag column-label "Dt Liq" when avail titulo
        ctbposhiscart.dtref format "999999" column-label "DtRef"
            ctbposhiscart.dtrefsai format "999999" column-label "RefSai"
            ctbposhiscart.valor
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttcontrato where
            no-lock no-error.
    end.
    else do:
        find first ttcontrato
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttcontrato where
            no-lock no-error.
    end.
    else do:
        find next ttcontrato
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttcontrato  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttcontrato where
            no-lock no-error.
    end.
    else do:
        find prev ttcontrato
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure montatt.
def var vtpcontrato like contrato.tpcontrato.
hide message no-pause.
message color normal "fazendo calculos... aguarde..." pcontnum vdtini.
def var vtp as int.
def var ctp as char extent 4 init ["F","N","L"," "].

for each ttcontrato.
    delete ttcontrato.
end.

                for each ctbposhiscart where
                        ctbposhiscart.contnum = pcontnum and
                        (ctbposhiscart.dtrefSAIDA = ? or ctbposhiscart.dtrefSAIDA > vdtini) and
                        ctbposhiscart.dtref      <= vdtini
                        no-lock .
                    if ctbposhiscart.cobcod <> pcobcod
                        then next.
                    find first ttcontrato where ttcontrato.prec = recid(ctbposhiscart) no-error.
                    if not avail ttcontrato
                    then do:                        
                        create ttcontrato.
                        ttcontrato.prec = recid(ctbposhiscart).
                    end.
                end.

hide message no-pause.
           
end procedure.

