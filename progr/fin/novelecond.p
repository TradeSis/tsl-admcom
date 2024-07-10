/*               to
*                                 R
*
*/

{admcab.i}

def input param par-camcod  like novcampanha.camcod.
def input param par-clicod  like clien.clicod.


def var vqtd_parcvencida as int.
def var vqtd_parcvencer  as int.

def var vperc as char format "x(05)" init "%Desc".
def var vvlr_entrada as dec.
def var vvlr_parcela as dec.
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" ajusta "," efetiva ",""].
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

def new shared temp-table ttcondicoes no-undo
    field planom        like novplanos.planom
    field plaord        like novplanos.plaord
    field vlr_entrada   as dec
    field min_entrada    as dec
    field vlr_acordo    as dec
    field vlr_juroacordo as dec
    field dtvenc1       as date
    field vlr_parcela   as dec
    field especial as log
    index idx is unique primary plaord asc planom asc.

def new shared temp-table ttparcelas no-undo
    field planom        like novplanos.planom
    field plaord        like novplanos.plaord
    field titpar        as int format ">>9" label "parc"
    field perc_parcela  as dec decimals 6 format ">>>9.999999%" label "perc"
    field vlr_parcela   as dec format ">>>>>9.99" label "vlr parcela"
    index idx is unique primary  plaord asc planom asc titpar asc.
    

        
        form  
        novcampanha.camnom no-label
        ttcampanha.qtd_selecionado format ">>>>"    column-label "sel"  
        
        ttcampanha.vlr_selaberto   format    ">>>>>9.99" column-label "aberto"
        ttcampanha.vlr_seldivida   format    ">>>>>9.99" column-label "divida"
        ttcampanha.vlr_selcustas   format    ">>>>9.99" column-label "custas"

        ttcampanha.vlr_selecionado format    ">>>>>9.99" column-label "total"

        
        with frame frame-b 1 down centered row 5 overlay  no-underline title novcampanha.camnom.


    form  
        ttcondicoes.planom     column-label "plano" format "x(12)"
        novplanos.perc_desc  no-label format "->>" space(0) vperc no-label space(0)
        novplanos.perc_acres    no-label format ">>" space(0) "%ac" 
        novplanos.calc_juro   
        ttcondicoes.vlr_acordo   column-label "acordo"       format   ">>>>9.99"
        novplanos.perc_min_entrada   column-label "Min" format ">>9.99" space(0) "%" space(0) 
        ttcondicoes.vlr_entrada  column-label "entrada"       format   ">>>9.99"
        
        novplanos.qtd_vezes       no-label format ">>>" space(0) "x" space(0)
        ttcondicoes.vlr_parcela  column-label "parc"     format  ">>>9.99"   space(0)
        ttcondicoes.especial format "*/ " column-label ""
        ttcondicoes.dtvenc1  column-label "venc"     format    "99/99/9999"
        novplanos.dias_max_primeira format ">>" no-label
        with frame frame-a 6 down centered row 11 no-box.



find ttcampanha where ttcampanha.camcod = par-camcod no-lock.
find novcampanha of ttcampanha no-lock.
    display  
        novcampanha.camnom 
        ttcampanha.qtd_selecionado
        
        ttcampanha.vlr_selaberto 
        ttcampanha.vlr_seldivida when novcampanha.tpcampanha = "PRO"
  
        ttcampanha.vlr_selcustas when novcampanha.tpcampanha = "PRO"

        ttcampanha.vlr_selecionado


        with frame frame-b.

run montacondicoes.




bl-princ:
repeat:



    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttcondicoes where recid(ttcondicoes) = recatu1 no-lock.
    if not available ttcondicoes
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

    recatu1 = recid(ttcondicoes).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttcondicoes
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttcondicoes where recid(ttcondicoes) = recatu1 no-lock.

        status default "".
        
                        
        /**                        
        esqcom1[1] = if ttcondicoes.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttcondicoes.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttcondicoes.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttcondicoes.carteira = ? or
                        ttcondicoes.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttcondicoes.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttcondicoes.cobcod = ?
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

        choose field ttcondicoes.planom
/*            help "Pressione L para Listar" */

                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      L l
                      tab PF4 F4 ESC return).

                /**if ttcondicoes.marca = no
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
                    if not avail ttcondicoes
                    then leave.
                    recatu1 = recid(ttcondicoes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttcondicoes
                    then leave.
                    recatu1 = recid(ttcondicoes).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttcondicoes
                then next.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttcondicoes
                then next.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.
                
                
        if keyfunction(lastkey) = "return"
        then   do:
            
            if esqcom1[esqpos1] = " Ajusta "
            then do on error undo:
                find novplanos where 
                        novplanos.camcod  = par-camcod and
                        novplanos.planom  = ttcondicoes.planom
                        no-lock.
                
                    vvlr_entrada = ttcondicoes.vlr_entrada.        
                    update 
                        ttcondicoes.vlr_entrada.
                    if ttcondicoes.vlr_entrada < ttcondicoes.min_entrada
                    then do:
                        ttcondicoes.vlr_entrada = vvlr_entrada.
                        message "Entrada Minima " ttcondicoes.min_entrada.
                        undo.
                    end.
                    if ttcondicoes.vlr_entrada entered
                    then do:
                        for each ttparcelas. delete ttparcelas. end.
                    end.
                find first novplanparcel of novplanos no-lock no-error.
                if not avail novplanparcel
                then do:
                    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
                    ttcondicoes.vlr_parcela = ttcondicoes.vlr_acordo / novplanos.qtd_vezes.
                    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo + ttcondicoes.vlr_entrada.
                    disp 
                        ttcondicoes.vlr_parcela.
                end.
                
           
                run pparcelas.
                   find first ttparcelas of ttcondicoes where
                        ttparcelas.titpar = 1
                    no-lock no-error.
                    if avail ttparcelas
                    then do:
                        vvlr_parcela = round(ttcondicoes.vlr_acordo / novplanos.qtd_vezes,2).
                        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo  - ttcondicoes.vlr_entrada ) * ttparcelas.perc_parcel / 100,2). 
                        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.
                    end.
                disp 
                        ttcondicoes.vlr_parcela ttcondicoes.especial.
                update 
                    ttcondicoes.dtvenc.
                if ttcondicoes.dtvenc > today + novplanos.dias_max_primeira or
                   ttcondicoes.dtven <= today
                then do:
                    ttcondicoes.dtvenc =  today + novplanos.dias_max_primeira .
                    disp ttcondicoes.dtvenc.
                    message "primeiro vencimento maximo para " novplanos.dias_max_primeira "dias".
                    undo.
                end.
                
                /* helio 20062024 iddemaqnda 1077 - desativar
                *                run fin/novcondparcel.p (recid(ttcondicoes))).
                */
                   find first ttparcelas of ttcondicoes where
                        ttparcelas.titpar = 1
                    no-lock no-error.
                    if avail ttparcelas
                    then do:
                        vvlr_parcela = round(ttcondicoes.vlr_acordo / novplanos.qtd_vezes,2).
                        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo  - ttcondicoes.vlr_entrada ) * ttparcelas.perc_parcel / 100,2). 
                        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.
                    end.
    
                 view frame frame-b.
                                    
            end.
             
            if esqcom1[esqpos1] = " efetiva "
            then do on error undo:
                message "confirma?" update sresp.
                if sresp 
                then do:
                    run pparcelas.
                    run  geraAcordo.
                    run cob/mostraacordo.p(input par-clicod, input "PENDENTE").
                    
                    recatu1 =  ?.
                    return.
                end.
            end.
        end.
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttcondicoes).
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


    find novplanos where 
                        novplanos.camcod  = par-camcod and
                        novplanos.planom  = ttcondicoes.planom
                        no-lock.

    display  
        ttcondicoes.planom
        novplanos.perc_min_entrada
        ttcondicoes.vlr_entrada 
        vperc when novplanos.perc_desc <> 0
        novplanos.perc_desc when novplanos.perc_desc <> 0
        novplanos.perc_acres when novplanos.perc_acres <> 0
        novplanos.calc_juro
        ttcondicoes.vlr_acordo  
        novplanos.qtd_vezes
        ttcondicoes.vlr_parcela    ttcondicoes.especial
            ttcondicoes.dtvenc1 
        novplanos.dias_max_primeira
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
        ttcondicoes.planom
        ttcondicoes.vlr_entrada 
        ttcondicoes.vlr_acordo  
        ttcondicoes.vlr_parcela  ttcondicoes.especial
        ttcondicoes.dtvenc1 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
        ttcondicoes.planom
        ttcondicoes.vlr_entrada 
        ttcondicoes.vlr_acordo  
        ttcondicoes.vlr_parcela ttcondicoes.especial
        ttcondicoes.dtvenc1 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
        ttcondicoes.planom
        ttcondicoes.vlr_entrada 
        ttcondicoes.vlr_acordo  
        ttcondicoes.vlr_parcela ttcondicoes.especial
        ttcondicoes.dtvenc1 

        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
        find first ttcondicoes  
                no-lock no-error.
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
        find next ttcondicoes 
                no-lock no-error.
end.    
             
if par-tipo = "up" 
then do:
        find prev ttcondicoes  
                no-lock no-error.

end.    
        
end procedure.




procedure montacondicoes.
def var vvlr_entrada as dec.

        find current ttcampanha.
        
     display  
        novcampanha.camnom 
        ttcampanha.qtd_selecionado
        
        ttcampanha.vlr_selaberto 
        ttcampanha.vlr_seldivida  when novcampanha.tpcampanha = "PRO"

        ttcampanha.vlr_selcustas  when novcampanha.tpcampanha = "PRO"

        ttcampanha.vlr_selecionado 


        with frame frame-b.

for each ttcondicoes.
    delete ttcondicoes.
end.
    
for each novplanos where novplanos.camcod = par-camcod no-lock.

    create ttcondicoes.
    ttcondicoes.plaord  = novplanos.plaord.
    ttcondicoes.planom  = novplanos.planom.

    
    if novplanos.perc_desconto > 0 or
       novplanos.valor_desc > 0
    then do:
        if novplanos.calc_juro
        then do: 
            if novplanos.perc_desc > 0
            then
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selecionado - (ttcampanha.vlr_selecionado * novplanos.perc_desconto / 100).
            else             
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selecionado - (
                            novplanos.valor_desc ).

        end.    
        else do:
        
            if novplanos.perc_desc > 0
            then
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selaberto   - (ttcampanha.vlr_selaberto   * novplanos.perc_desconto / 100).
            else 
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selaberto   - (
                            novplanos.valor_desc ).

        end.    
    end.    
    else do:
        if novplanos.calc_juro
        then do:
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selecionado. 
        end.    
        else do:
            ttcondicoes.vlr_acordo =  ttcampanha.vlr_selaberto. 
        end.    
    end.        
    
    if novplanos.perc_acres > 0
    then do:
        ttcondicoes.vlr_juroacordo = (ttcondicoes.vlr_acordo * (novplanos.perc_acres) / 100).
        ttcondicoes.vlr_acordo     =  ttcondicoes.vlr_acordo + ttcondicoes.vlr_juroacordo.
    end.    
    else
        if novplanos.valor_acres > 0
        then do:
            ttcondicoes.vlr_juroacordo =  novplanos.valor_acres.
            ttcondicoes.vlr_acordo     =  ttcondicoes.vlr_acordo + ttcondicoes.vlr_juroacordo.
        end.    
    
    
    vvlr_entrada = 0.
    ttcondicoes.min_entrada = 0.
    ttcondicoes.vlr_entrada = 0.
    if novplanos.com_entrada
    then do:
        vvlr_entrada            = round(ttcondicoes.vlr_acordo / (novplanos.qtd_vezes + 1),2).
        ttcondicoes.min_entrada = round(ttcondicoes.vlr_acordo * novplanos.perc_min_entrada / 100,2). 
        if ttcondicoes.min_entrada > 0 /* helio 12/11/2021 ajuste erro calculo entrada ID 97282 - Tela de campanha */
        then  ttcondicoes.vlr_entrada = ttcondicoes.min_entrada.
        else  ttcondicoes.vlr_entrada = vvlr_entrada.
    end.
    
    ttcondicoes.dtvenc1     = today + novplanos.dias_max_primeira.
    
    
    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
    
    find first novplanparcel of novplanos where
                novplanparcel.titpar = 1
                no-lock no-error.
    if avail novplanparcel
    then do:
        vvlr_parcela = round(ttcondicoes.vlr_acordo / novplanos.qtd_vezes,2).

        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo) * novplanparcel.perc_parcel / 100,2). 
        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.

    end.
    else do:
        ttcondicoes.vlr_parcela = ttcondicoes.vlr_acordo / novplanos.qtd_vezes.
    end.

    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo + ttcondicoes.vlr_entrada.
     
end.
   
end procedure.








procedure geraAcordo.

find current ttcondicoes.
    find novplanos where 
                        novplanos.camcod  = par-camcod and
                        novplanos.planom  = ttcondicoes.planom
                        no-lock.

def var vday as int.
def var vmes as int.
def var vano as int.
def var vi as int.
def var vtitdtven as date.

def var vtotal as dec init 0.
 
def var vid_acordo as dec.
def var vint as int.
vint = 1.
repeat:
    vid_acordo = dec(string(vint,"9") + 
                string(today - 08/05/1985,"99999") +
                string(int(replace(string(time,"HH:MM"),":","")),"9999") +
            string(par-clicod,"9999999999"))
            .
    find novacordo where novacordo.id_acordo = vid_acordo no-lock no-error.
    if avail novacordo
    then do:
        vint = vint + 1.
        pause 1 no-message.
    end.    
    else leave.            
     
end.

do on error undo:
    create novacordo.
    assign
        novacordo.etb_acordo        = setbcod
        novacordo.clicod            = par-clicod
        novacordo.id_acordo         = vid_acordo
        novacordo.dtinclu           = today
        novacordo.user_inclu = sfuncod
        novacordo.horinclu = time
        novacordo.situacao = "PENDENTE".
        
        novacordo.valor_ori         = ttcampanha.vlr_selaberto.
        novacordo.valor_acordo      = ttcondicoes.vlr_acordo.
        novacordo.valor_entrada     = ttcondicoes.vlr_entrada.
        novacordo.valor_liquido     = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
        novacordo.qtd_parcelas      = novplanos.qtd_vezes.
        novacordo.dtvalidade        = ttcondicoes.dtvenc1.
        
/*        novacordo.char1 = vchar1.*/
        novacordo.destino = 10.
/*        novacordo.motivo1 = vtitobs*/
        novacordo.Motivo5 = "JUROATRASO=" + string(ttcampanha.vlr_selecionado - ttcampanha.vlr_selaberto) +
                            "|JUROACORDO=" + string(ttcondicoes.vlr_juroacordo) + 
                            "|VALORPARCELA=" + string(ttcondicoes.vlr_parcela) + "|".
                            
        novacordo.tipnova = 31.
    if ttcondicoes.vlr_entrada > 0
    then do:
        create tit_acordo.
        tit_acordo.id_acordo = novacordo.id_acordo.
        tit_acordo.titpar    = 0.
        tit_acordo.titdtven  = today.
        tit_acordo.titvlcob  = ttcondicoes.vlr_entrada.
/*    tit_acordo.titobs    = vtitobs.*/
        tit_acordo.tpcontrato = "N".
        tit_acordo.modcod    = "CRE".
    end.
         
    vday = day(ttcondicoes.dtvenc).
    vmes = month(ttcondicoes.dtvenc).
    vano = year(ttcondicoes.dtvenc).
    
    
    
    do vi = 1 to (novplanos.qtd_vezes): 
        vtitdtven = date(vmes, 
                         IF VMES = 2 
                         THEN IF VDAY > 28 
                              THEN 28 
                              ELSE VDAY 
                         ELSE if VDAY > 30 
                              then 30 
                              else vday, 
                         vano).
        find first ttparcelas of ttcondicoes where ttparcelas.titpar = vi no-error.
        
        create tit_acordo.
        tit_acordo.id_acordo = novacordo.id_acordo.
        tit_acordo.titpar    = vi.
        tit_acordo.titdtven  = vtitdtven.
        tit_acordo.titvlcob  = if avail ttparcelas
                               then ttparcelas.vlr_parcela
                               else ttcondicoes.vlr_parcela.

/*        tit_acordo.titobs    = vtitobs.*/
        tit_acordo.tpcontrato = "N".
        tit_acordo.modcod    = "CRE".
        
        vtotal = vtotal + tit_acordo.titvlcob.

        vmes = vmes + 1.
        if vmes > 12 
        then assign vano = vano + 1
                    vmes = 1.
        
        
    end.
    if vtotal < novacordo.valor_liquido
    then do:
        find tit_acordo of novacordo where tit_acordo.titpar = 1 no-error.
        if not avail tit_acordo
        then find first tit_acordo of novacordo.
        tit_acordo.titvlcob = tit_acordo.titvlcob + (novacordo.valor_liquido - vtotal).
    end.
    
    for each ttcontrato where ttcontrato.camcod = par-camcod and
                              ttcontrato.marca  = yes. 
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.

        if novcampanha.tpcampanha = "PRO"
        then do:
            find titprotesto where recid(titprotesto) = ttcontrato.trectitprotesto exclusive.
            if avail titprotesto
            then titprotesto.pagacustas = ttcontrato.pagacustas.
            
        end. 
        do: 
        
                vqtd_parcvencida = 0.
                vqtd_parcvencer  = 0. 
                for each titulo where
                            titulo.empcod     = 19 and
                            titulo.titnat     = no and
                            titulo.modcod     = contrato.modcod and
                            titulo.etbcod     = contrato.etbcod and
                            titulo.clifor     = contrato.clicod and
                            titulo.titnum     = string(contrato.contnum) 
                            no-lock
                            by titulo.titpar.
                    if titulo.titpar = 0 then next.
                    if titulo.titsit = "LIB" 
                    then. 
                    else next.
                    if titulo.titdtven < today then vqtd_parcvencida = vqtd_parcvencida + 1.
                                               else vqtd_parcvencer  = vqtd_parcvencer  + 1.

                    if titulo.titdtven < today
                    then do:        
                        if novcampanha.parcvencidaqtd = 0 or
                           vqtd_parcvencida <= novcampanha.parcvencidaqtd 
                        then do:    
                            run ptitulo.
                        end.
                    end.
                    else do:
                        if novcampanha.parcvencidaso = no and (novcampanha.parcvencerqtd = 0 or vqtd_parcvencer <= novcampanha.parcvencerqtd) 
                        then do: 
                            run ptitulo.
                        end.    
                    end.
                end.
        
        end.
    
    end.
    
    
end.    



end procedure.


procedure ptitulo.
def var vtitvlcob as dec.
do on error undo:

   find current novplanos no-lock.
    if novplanos.calc_juro_titulo
    then do:
        vtitvlcob = 0. /* calcula juros na ponta ConsultaAcordo_07.p */
    end.
    else do:
        vtitvlcob = titulo.titvlcob.
    end.
    
             create tit_novacao.
             assign
                 tit_novacao.tipo = ""
                 tit_novacao.ger_contnum = ?
                 tit_novacao.id_acordo = string(novacordo.id_acordo)
                 tit_novacao.ori_empcod = titulo.empcod
                 tit_novacao.ori_titnat = titulo.titnat
                 tit_novacao.ori_modcod = titulo.modcod
                 tit_novacao.ori_etbcod = titulo.etbcod
                 tit_novacao.ori_clifor = titulo.clifor
                 tit_novacao.ori_titnum = titulo.titnum
                 tit_novacao.ori_titpar = titulo.titpar
                 tit_novacao.ori_titdtemi = titulo.titdtemi
                 tit_novacao.ori_titvlcob = vtitvlcob
                 tit_novacao.ori_titdtpag = titulo.titdtpag
                 tit_novacao.ori_titdtven = titulo.titdtven
                 tit_novacao.dtnovacao = ?
                 tit_novacao.hrnovacao = ?
                 tit_novacao.etbnovacao = ?
                 tit_novacao.funcod = ?        .

end.

end procedure.



procedure pparcelas.


    find current ttcondicoes.
    find current novplanos no-lock.
    for each novplanparcel of novplanos no-lock.
        find first ttparcelas where
             ttparcelas.planom = novplanos.planom and 
             ttparcelas.plaord = ttcondicoes.plaord and 
             ttparcelas.titpar = novplanparcel.titpar
             no-error.
        if avail ttparcelas then next.                     
        create ttparcelas.
        ttparcelas.planom = novplanos.planom.
        ttparcelas.plaord = ttcondicoes.plaord.
        ttparcelas.titpar = novplanparcel.titpar.
        ttparcelas.perc_parcela = novplanparcel.perc_parcel.
        ttparcelas.vlr_parcela = round((ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada) * novplanparcel.perc_parcel / 100,2). 
    end.
    


end procedure.

