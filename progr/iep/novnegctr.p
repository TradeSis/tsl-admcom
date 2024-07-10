/*               to
*                                 R
*
*/

{admcab.i}
def input param par-camcod  like novcampanha.camcod.
def var vtotal as dec.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" marca"," todos"," consulta "," "," "].
form
    esqcom1
    with frame f-com1 row 9 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.

/*if poperacao = "NOVACAO"
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

       
{fin/novcamp.i}
        
def buffer bttcontrato for ttcontrato.
def buffer cttcontrato for ttcontrato.


def buffer bttcampanha for ttcampanha.

def var ptitle as char.
find ttcampanha where ttcampanha.camcod = par-camcod no-lock.
find novcampanha of ttcampanha no-lock.


ptitle =  if novcampanha.tpcampanha = "PRO"
          then "NEGOCIACAO PROTESTO - " + novcampanha.camnom
          else novcampanha.camnom.

        form  
        
        with frame frame-b 1 down centered row 5 overlay no-underline title ptitle.


    form  
        ttcontrato.marca format "*/ " column-label "*"
        contrato.etbcod column-label "fil"
        contrato.contnum format ">>>>>>>>>9" column-label "contrato"
        contrato.modcod        column-label "mod" 
        ttcontrato.tpcontrato  column-label "t" format "x"  
        
        ttcontrato.vlr_aberto  column-label "aberto"       format ">>>>>9.99"
        ttcontrato.vlr_divida  column-label "divida"       format ">>>>>9.99"
        ttcontrato.vlr_custas  column-label "custas"       format ">>>>>9.99"

        vtotal                  column-label "total"    format ">>>>>9.99"        
        
        with frame frame-a 6 down centered row 11 no-box.



    display  
        novcampanha.camnom no-label
        ttcampanha.qtd_selecionado format ">>>>"    column-label "sel"  
        
        ttcampanha.vlr_selaberto   format    ">>>>>9.99" column-label "aberto"
        ttcampanha.vlr_seldivida   format    ">>>>>9.99" column-label "divida"
        ttcampanha.vlr_selcustas   format    ">>>>9.99" column-label "custas"

        ttcampanha.vlr_selecionado format    ">>>>>9.99" column-label "total"

        with frame frame-b.






bl-princ:
repeat:



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

                /**if ttcontrato.marca = no
                then**/  run color-normal.
                /**                else run color-input. **/
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
            if esqcom1[esqpos1] = " consulta"
            then do:
                run conco_v1701.p (string(ttcontrato.contnum)).
                run ajustacampanha.
                
            end.
            
            
            if esqcom1[esqpos1] = " marca"
            then do:
                ttcontrato.marca = not ttcontrato.marca.
                run ajustacampanha.
                disp ttcontrato.marca with frame frame-a. 
                next.
            end.
            if esqcom1[esqpos1] = " todos"
            then do:
                def var vmarca as log.
                recatu2 = recatu1.
                vmarca = ttcontrato.marca.
                for each bttcontrato where bttcontrato.camcod = par-camcod.
                    bttcontrato.marca = not vmarca.
                end.
                run ajustacampanha.
                leave.
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
    find contrato of ttcontrato no-lock.    
    vtotal = ttcontrato.vlr_divida + ttcontrato.vlr_custas.
    display  
        ttcontrato.marca 
        contrato.etbcod
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato 
        ttcontrato.vlr_divida
        ttcontrato.vlr_custas
        ttcontrato.vlr_aberto
        vtotal

        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttcontrato.marca 
        contrato.etbcod
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato 
        ttcontrato.vlr_divida
        ttcontrato.vlr_custas
        ttcontrato.vlr_aberto
            vtotal                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcontrato.marca 
        contrato.etbcod
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato 
        ttcontrato.vlr_divida
        ttcontrato.vlr_custas
        ttcontrato.vlr_aberto
        vtotal
                    
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcontrato.marca 
        contrato.etbcod
        contrato.contnum
        contrato.modcod
        ttcontrato.tpcontrato 
        ttcontrato.vlr_divida
        ttcontrato.vlr_custas
        ttcontrato.vlr_aberto
vtotal
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttcontrato  where ttcontrato.camcod = par-camcod
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttcontrato  where  ttcontrato.camcod = par-camcod
                no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ttcontrato  where  ttcontrato.camcod = par-camcod
                no-lock no-error.

end.    
        
end procedure.




procedure ajustacampanha.
        
        find current ttcampanha.
        ttcampanha.vlr_selecionado = 0.
        ttcampanha.vlr_selaberto   = 0.
        ttcampanha.qtd_selecionado = 0.
        ttcampanha.vlr_seldivida   = 0.
        ttcampanha.vlr_selcustas   = 0.        
        for each cttcontrato where cttcontrato.camcod = ttcampanha.camcod.    
            find contrato where contrato.contnum = cttcontrato.contnum no-lock. 
                if cttcontrato.marca
                then do:
                    ttcampanha.vlr_selecionado = ttcampanha.vlr_selecionado + cttcontrato.vlr_divida + cttcontrato.vlr_custas. 
                    ttcampanha.vlr_selaberto   = ttcampanha.vlr_selaberto + cttcontrato.vlr_aberto. 
                    ttcampanha.vlr_selcustas   = ttcampanha.vlr_selcustas + cttcontrato.vlr_custas. 
                    ttcampanha.vlr_seldivida   = ttcampanha.vlr_seldivida + cttcontrato.vlr_divida. 
                    
                    
                    ttcampanha.qtd_selecionado = ttcampanha.qtd_selecionado + 1.
                end.    
        end.             
     display  
        novcampanha.camnom 
        ttcampanha.qtd_selecionado
        
        ttcampanha.vlr_selaberto  
        ttcampanha.vlr_seldivida 
        ttcampanha.vlr_selcustas  

        ttcampanha.vlr_selecionado 
        with frame frame-b.

   
end procedure.

