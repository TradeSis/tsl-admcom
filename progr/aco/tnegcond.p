/*               to
*                                 R
*
*/

{admcab.i}

def input param par-negcod  like aconegoc.negcod.
def input param par-clicod  like clien.clicod.

def var vperc as char format "x(05)" init "%Desc".
def var vvlr_entrada as dec.

/*def var vqtd_parcvencida as int.
def var vqtd_parcvencer  as int.

*/
def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(11)" extent 6
    initial [" ajusta ","  ",""].
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

def var ptpnegociacao as char.

def var vmessage as log.
vmessage = yes.
        

{aco/acordo.i}

def buffer bttcontrato for ttcontrato.
def buffer cttcontrato for ttcontrato.
       

 
def buffer bttnegociacao for ttnegociacao.
        form  
/*        aconegoc.negnom */ space(12)
        ttnegociacao.qtd format ">>>>"    column-label "qtd"  
        ttnegociacao.vlr_aberto     format    ">>>>>>9.99" column-label "aberto"
        ttnegociacao.vlr_divida     format    ">>>>>>9.99" column-label "divida"
        /*
        ttnegociacao.dt_venc  column-label "venc"     format    "999999"
        ttnegociacao.dias_atraso column-label "dias"     format    "->>>9"
        */
        ttnegociacao.qtd_selecionado format ">>>>"    column-label "sel"  
        ttnegociacao.vlr_selaberto   format    ">>>>>>9.99" column-label "sel aberto"

        ttnegociacao.vlr_selecionado format    ">>>>>>9.99" column-label "sel total"
        
        with frame frame-b 1 down centered row 5 overlay no-underline title aconegoc.negnom.

    form  
        ttcondicoes.placod column-label "ID" format ">9" 
        ttcondicoes.planom     column-label "plano" format "x(10)"
        acoplanos.perc_desc  no-label format "->>" space(0) vperc no-label space(0)
        acoplanos.perc_acres    no-label format ">>" space(0) "%ac" 
        acoplanos.calc_juro   
        ttcondicoes.vlr_acordo   column-label "acordo"       format   ">>>>>9.99"
        acoplanos.perc_min_entrada   column-label "ent % " format ">>9.99" space(0) "%" space(0) 
        ttcondicoes.vlr_entrada  column-label "entrada"       format   ">>>>9.99"
        
        acoplanos.qtd_vezes       no-label format ">>>" space(0) "x" space(0)
        ttcondicoes.vlr_parcela  column-label "parc"     format  ">>>9.99"   space(0)
        ttcondicoes.especial format "*/ " column-label ""
        ttcondicoes.dtvenc1  column-label "venc"     format    "99/99/99"
        acoplanos.dias_max_primeira format ">>" no-label
        with frame frame-a 6 down centered row 11 no-box.



find ttnegociacao where ttnegociacao.negcod = par-negcod no-lock.
find aconegoc of ttnegociacao no-lock.
ptpnegociacao = aconegoc.tpnegociacao.


    display  
        ttnegociacao.qtd 
        ttnegociacao.vlr_aberto    
        ttnegociacao.vlr_divida

        ttnegociacao.qtd_selecionado
        
        ttnegociacao.vlr_selaberto 
  

        ttnegociacao.vlr_selecionado
        with frame frame-b.
        
run montacondicoes (input par-negcod, ?).




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
                find acoplanos where 
                        acoplanos.negcod  = par-negcod and
                        acoplanos.placod  = ttcondicoes.placod
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
                find first acoplanparcel of acoplanos no-lock no-error.
                if not avail acoplanparcel
                then do:
                    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
                    ttcondicoes.vlr_parcela = ttcondicoes.vlr_acordo / acoplanos.qtd_vezes.
                    ttcondicoes.vlr_acordo  = ttcondicoes.vlr_acordo + ttcondicoes.vlr_entrada.
                    disp 
                        ttcondicoes.vlr_parcela.
                end.
                
           
                run pparcelas (input recid(ttcondicoes)).
                   find first ttparcelas of ttcondicoes where
                        ttparcelas.titpar = 1
                    no-lock no-error.
                    if avail ttparcelas
                    then do:
                        vvlr_parcela = round(ttcondicoes.vlr_acordo / acoplanos.qtd_vezes,2).
                        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo  - ttcondicoes.vlr_entrada ) * ttparcelas.perc_parcel / 100,2). 
                        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.
                    end.
                disp 
                        ttcondicoes.vlr_parcela ttcondicoes.especial.
                update 
                    ttcondicoes.dtvenc.
                if ttcondicoes.dtvenc > today + acoplanos.dias_max_primeira or
                   ttcondicoes.dtven <= today
                then do:
                    ttcondicoes.dtvenc =  today + acoplanos.dias_max_primeira .
                    disp ttcondicoes.dtvenc.
                    message "primeiro vencimento maximo para " acoplanos.dias_max_primeira "dias".
                    undo.
                end.
                
                run aco/tnegcondparcel.p (recid(ttcondicoes))).

                   find first ttparcelas of ttcondicoes where
                        ttparcelas.titpar = 1
                    no-lock no-error.
                    if avail ttparcelas
                    then do:
                        vvlr_parcela = round(ttcondicoes.vlr_acordo / acoplanos.qtd_vezes,2).
                        ttcondicoes.vlr_parcela = round((ttcondicoes.vlr_acordo  - ttcondicoes.vlr_entrada ) * ttparcelas.perc_parcel / 100,2). 
                        ttcondicoes.especial    = vvlr_parcela <> ttcondicoes.vlr_parcela.
                    end.
    
                 view frame frame-b.
                                    
            end.
            /*                 
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
            */
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


    find acoplanos where 
                        acoplanos.negcod  = par-negcod and
                        acoplanos.placod  = ttcondicoes.placod
                        no-lock.

    display  
    ttcondicoes.placod
        ttcondicoes.planom
        acoplanos.perc_min_entrada
        ttcondicoes.vlr_entrada 
        vperc when acoplanos.perc_desc <> 0
        acoplanos.perc_desc when acoplanos.perc_desc <> 0
        acoplanos.perc_acres when acoplanos.perc_acres <> 0
        acoplanos.calc_juro
        ttcondicoes.vlr_acordo  
        acoplanos.qtd_vezes
        ttcondicoes.vlr_parcela    ttcondicoes.especial
            ttcondicoes.dtvenc1 
        acoplanos.dias_max_primeira
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
    ttcondicoes.placod
        ttcondicoes.planom
        ttcondicoes.vlr_entrada 
        ttcondicoes.vlr_acordo  
        ttcondicoes.vlr_parcela  ttcondicoes.especial
        ttcondicoes.dtvenc1 
                    
        with frame frame-a.
end procedure.


procedure color-input.
    color display input
    ttcondicoes.placod
        ttcondicoes.planom
        ttcondicoes.vlr_entrada 
        ttcondicoes.vlr_acordo  
        ttcondicoes.vlr_parcela ttcondicoes.especial
        ttcondicoes.dtvenc1 
        with frame frame-a.
end procedure.


procedure color-normal.
    color display normal
    ttcondicoes.placod
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









procedure geraAcordo.

find current ttcondicoes.
    find acoplanos where 
                        acoplanos.negcod  = par-negcod and
                        acoplanos.placod = ttcondicoes.placod
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
        
        novacordo.valor_ori         = ttnegociacao.vlr_selaberto.
        novacordo.valor_acordo      = ttcondicoes.vlr_acordo.
        novacordo.valor_entrada     = ttcondicoes.vlr_entrada.
        novacordo.valor_liquido     = ttcondicoes.vlr_acordo - ttcondicoes.vlr_entrada.
        novacordo.qtd_parcelas      = acoplanos.qtd_vezes.
        novacordo.dtvalidade        = ttcondicoes.dtvenc1.
        
/*        novacordo.char1 = vchar1.*/
        novacordo.destino = 10.
/*        novacordo.motivo1 = vtitobs*/
        novacordo.Motivo5 = "JUROATRASO=" + string(ttnegociacao.vlr_selecionado - ttnegociacao.vlr_selaberto) +
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
    
    
    
    do vi = 1 to (acoplanos.qtd_vezes): 
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
    
    for each ttcontrato where ttcontrato.negcod = par-negcod and
                              ttcontrato.marca  = yes. 
        find contrato where contrato.contnum = ttcontrato.contnum no-lock.

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
                        if aconegoc.parcvencidaqtd = 0 or
                           vqtd_parcvencida <= aconegoc.parcvencidaqtd 
                        then do:    
                            run ptitulo.
                        end.
                    end.
                    else do:
                        if aconegoc.parcvencidaso = no and (aconegoc.parcvencerqtd = 0 or vqtd_parcvencer <= aconegoc.parcvencerqtd) 
                        then do: 
                            run ptitulo.
                        end.    
                    end.
                end.
        
        end.
    
    end.
    
    
end.    



end procedure.



