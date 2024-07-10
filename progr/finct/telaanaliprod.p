/* 04082021 helio - ficou sem przmed, foi tem tela direto pra isto agora*/


{admcab.i}
def var vproduto as char.
def var vaux as int64.
def var vnome as char. 
def input param ppagamento  as char.
def input param vtitle     as char.
def input param poldfiltro as char.
def input param pfiltro    as char.
def input param poldctmcod  as char.
def input param poldcarteira as log.
def input param poldmodcod   as char.
def input param poldtpcontrato as char.
def input param poldetbcod  as int. 
def input param poldcobcod  as int.
def shared var vetbcod like estab.etbcod.
def shared var vdtini as date format "99/99/9999" label "De".
def shared var vdtfin as date format "99/99/9999" label "Ate".              

def var vtitvlcob as dec.
def var vjuros as dec.
def var vdescontos as dec.
def var vtotal  as dec.

def var recatu1         as recid.
def var recatu2     as reci.
def var reccont         as int.
def var esqpos1         as int.
def var esqcom1         as char format "x(09)" extent 7
    initial [""].

form
    esqcom1
    with frame f-com1 row 6 no-box no-labels column 1 centered.

assign
    esqpos1  = 1.


def temp-table ttmovimdoc no-undo
    field pagamento  as char
    field filtro     as char
    /**
    field ctmcod     like pdvdoc.ctmcod   
    field carteira  as log
    field modcod    like poscart.modcod
    field tpcontrato    like poscart.tpcontrato
    field etbcod    like poscart.etbcod
    field cobcod    like poscart.cobcod
    **/
    field produto as char
    
    field titvlcob  like pdvdoc.titvlcob    format "->>>>>>>9.99" column-label "vlr nominal"
    field encargo   like pdvdoc.valor_encargo format "->>>>>9.99" column-label "juros"
    field desconto  like pdvdoc.desconto format      "->>>>>9.99" column-label "descontos"
    field valor     like pdvdoc.valor format       "->>>>>>>9.99" column-label "total"

    index idx is unique primary 
        pagamento asc
        filtro asc 
        /**
        ctmcod asc carteira asc
        modcod asc
        tpcontrato asc 
        etbcod asc
        cobcod asc
        **/
        produto asc.

def buffer bttmovimdoc for ttmovimdoc.
        
def var vfiltro as char.

    find pdvtmov where pdvtmov.ctmcod = poldctmcod no-lock no-error.
    if avail pdvtmov
    then vfiltro = pdvtmov.ctmnom.
    else vfiltro = ppagamento.
    vfiltro = vfiltro + if poldcarteira <> ?
            then "/" + string(poldcarteira,"CART/OUTR")
            else "".
    vfiltro = vfiltro + 
            if poldmodcod <> ?
            then "/" + poldmodcod
            else "".
    vfiltro = vfiltro + 
            if poldtpcontrato <> ?
            then "/" + if poldtpcontrato = "F"
                 then "FEI"
                 else if poldtpcontrato = "N"
                      then "NOV"
                      else if poldtpcontrato = "L"
                           then "LP "
                           else "   "
            else "".

    find cobra where cobra.cobcod = poldcobcod no-lock no-error.
    vfiltro = vfiltro + 
            (if poldcobcod <> ?
             then "/" + string(poldcobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").


disp
    vfiltro no-label format "x(50)"
        poldetbcod when poldetbcod <> ?
            label "Fil" format ">>>>"

    with frame fcab
    row 4 no-box
        side-labels
        width 80
        color underline.

    form  
        vnome format "x(18)" column-label ""
        /**ttmovimdoc.etbcod  column-label "Fil" format ">>>"**/
        ttmovimdoc.titvlcob
        ttmovimdoc.encargo
        ttmovimdoc.desconto
        ttmovimdoc.valor        
        with frame frame-a 9 down centered row 7
        title vtitle.
run gravaposicao /** (poldfiltro,
                  poldctmcod,
                  poldcarteira,
                  poldmodcod,
                  poldtpcontrato,
                  poldetbcod,
                  poldcobcod)**/ .


disp 
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



bl-princ:
repeat:


disp
    vtitvlcob
    vjuros
    vdescontos
    vtotal   

        with frame ftot.

    disp esqcom1 with frame f-com1.
    if recatu1 = ?
    then run leitura (input "pri").
    else find ttmovimdoc where recid(ttmovimdoc) = recatu1 no-lock.
    if not available ttmovimdoc
    then do.
        if pfiltro = ""
        then do: 
            return.
        end.    
        pfiltro = "".
        recatu1 = ?.
        next.
    end.
    clear frame frame-a all no-pause.
    run frame-a.

    recatu1 = recid(ttmovimdoc).
    color display message esqcom1[esqpos1] with frame f-com1.
    repeat:
        run leitura (input "seg").
        if not available ttmovimdoc
        then leave.
        if frame-line(frame-a) = frame-down(frame-a)
        then leave.
        down with frame frame-a.
        run frame-a.
    end.
    up frame-line(frame-a) - 1 with frame frame-a.

    repeat with frame frame-a:

        find ttmovimdoc where recid(ttmovimdoc) = recatu1 no-lock.

        status default "".
            
        /**
        esqcom1[1] = if ttmovimdoc.ctmcod = ?
                            then "Operacao"
                            else "".

        esqcom1[2] = if pfiltro = "TpContrato"
                     then ""
                     else if ttmovimdoc.carteira = ?
                            then "Carteira"
                            else "".
        esqcom1[3] = if ttmovimdoc.modcod = ?
                     then "Modalidade"
                     else "".
        esqcom1[4] = if ttmovimdoc.carteira = ? or
                        ttmovimdoc.tpcontrato = ?
                     then "TpContrato"
                     else "".
        esqcom1[5] = if ttmovimdoc.etbcod = ?
                     then if vetbcod = 0
                          then "Filial"
                          else ""
                     else "".
        esqcom1[6] = if ttmovimdoc.cobcod = ?
                     then "Propriedade"
                     else "".
        
        esqcom1[7] = "Produto".
        
        def var vx as int.
        def var va as int.
        va = 1.
        do vx = 1 to 7.
            if esqcom1[vx] = ""
            then next.
            esqcom1[va] = esqcom1[vx].
            va = va + 1.  
        end.
        vx = va.
        do vx = va to 7.
            esqcom1[vx] = "".
        end.     
        */
        
        
        disp esqcom1 with frame f-com1.
        
        run color-message.

        choose field vnome 

                help  "digite [C] para contratos,   [E] para exportar para csv"
            
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      E e C c
                      tab PF4 F4 ESC return).
                      
                       run color-normal.
        pause 0. 

            if keyfunction(lastkey) = "E"
            then do:
                run geracsv.
                leave.
            end.
            
                                                                
            if keyfunction(lastkey) = "cursor-right"
            then do:
                color display normal esqcom1[esqpos1] with frame f-com1.
                esqpos1 = if esqpos1 = 7 then 7 else esqpos1 + 1.
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
                    if not avail ttmovimdoc
                    then leave.
                    recatu1 = recid(ttmovimdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail ttmovimdoc
                    then leave.
                    recatu1 = recid(ttmovimdoc).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail ttmovimdoc
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail ttmovimdoc
                then next.
                color display white/red vnome with frame frame-a.
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then leave bl-princ.

            if keyfunction(lastkey) = "C" or
               keyfunction(lastkey) = "c"
            then do:
                hide frame fcab no-pause.
                hide frame f-com1 no-pause.
                hide frame frame-a no-pause.                
                find pdvtmov where pdvtmov.ctmcod = poldctmcod no-lock no-error.
                
                if (avail pdvtmov and pdvtmov.novacao) or ttmovimdoc.pagamento = "NOVACOES"
                then run finct/telaanadocnovproduto.p
                 (   vtitle + "/" + pfiltro,
                            ttmovimdoc.produto,
                            poldfiltro, 
                            pfiltro,
                            poldctmcod,
                            poldmodcod,
                            poldtpcontrato,
                            poldetbcod,
                            poldcobcod,
                            ?).
                else do:
                    if ppagamento = "VENDAS" or ppagamento = "VENDAS SITE"
                    then do:
                        run finct/telaanaemictrproduto.p (input ppagamento,
                                                            input ttmovimdoc.produto,
                                                                 input poldcobcod,
                                                                 input poldctmcod,
                                                                 input poldmodcod,
                                                                 input poldtpcontrato,
                                                                 input poldetbcod).
                        
                    end.
                    else  do:
                        run finct/telaanadocrecproduto.p
                            (   vtitle + "/" + pfiltro,
                                ttmovimdoc.produto,
                                poldfiltro, 
                                pfiltro,
                                poldctmcod,
                                poldmodcod,
                                poldtpcontrato,
                                poldetbcod,
                                poldcobcod).
                    end.
                end.
                leave.
            end.


        /**    
        **/
        run frame-a.
        display esqcom1[esqpos1] with frame f-com1.
        recatu1 = recid(ttmovimdoc).
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
    /**
    find pdvtmov where pdvtmov.ctmcod = ttmovimdoc.ctmcod no-lock no-error.
    vnome = if avail pdvtmov and poldctmcod = ?
                 then pdvtmov.ctmnom 
                 else if pfiltro = "Geral"
                      then ttmovimdoc.pagamento
                      else "-".
    vnome = vnome +  if ttmovimdoc.carteira <> ?
            then string(ttmovimdoc.carteira,"CART/OUTR")
            else "".
    vnome = vnome + " " +
            if ttmovimdoc.modcod <> ?
            then ttmovimdoc.modcod
            else "".
    vnome = vnome + " " +
            if ttmovimdoc.tpcontrato <> ?
            then if ttmovimdoc.tpcontrato = "F"
                 then "FEI"
                 else if ttmovimdoc.tpcontrato = "N"
                      then "NOV"
                      else if ttmovimdoc.tpcontrato = "L"
                           then "LP "
                           else "   "
            else "".
    find cobra where cobra.cobcod = ttmovimdoc.cobcod no-lock no-error.
    vnome = vnome + " " +
            (if ttmovimdoc.cobcod <> ?
             then string(ttmovimdoc.cobcod) + if avail cobra 
                                       then ("-" + cobra.cobnom)
                                       else ""
             else "").

    **/
    vnome = trim(caps(ttmovimdoc.produto)).
    display  
        vnome
        /*ttmovimdoc.etbcod when ttmovimdoc.etbcod <> ?*/
        ttmovimdoc.titvlcob
        ttmovimdoc.encargo
        ttmovimdoc.desconto
        ttmovimdoc.valor
        with frame frame-a.


end procedure.

procedure color-message.
    color display message
                    vnome 
        with frame frame-a.
end procedure.

procedure color-normal.
    color display normal

                    
                    vnome 
        with frame frame-a.
end procedure.

procedure leitura . 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find first ttmovimdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find first ttmovimdoc where
            no-lock no-error.
    end.
    else do:
        find first ttmovimdoc
            no-lock no-error.
    end.    
    
            
end.    
                                             
if par-tipo = "seg" or par-tipo = "down" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find next ttmovimdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find next ttmovimdoc where
            no-lock no-error.
    end.
    else do:
        find next ttmovimdoc
            no-lock no-error.
    end.    

end.    
             
if par-tipo = "up" 
then do:
    if pfiltro = "ComBoleto"
    then do:
        find prev ttmovimdoc  where
                no-lock no-error.
    end.
    else
    if pfiltro = "SemBoleto"
    then do:
        find prev ttmovimdoc where
            no-lock no-error.
    end.
    else do:
        find prev ttmovimdoc
            no-lock no-error.
    end.    

end.    
        
end procedure.


procedure gravaposicao.
/**
def input param poldfiltro as char.
def input param poldctmcod  as char.
def input param poldcarteira like ttmovimdoc.carteira.
def input param poldmodcod   like ttmovimdoc.modcod.
def input param poldtpcontrato like ttmovimdoc.tpcontrato.
def input param poldetbcod   like ttmovimdoc.etbcod.
def input param poldcobcod   like ttmovimdoc.cobcod.
**/


def var pmodcod   like poldmodcod.
def var pctmcod   like poldctmcod.
def var petbcod   like poldetbcod.
def var pcobcod   like poldcobcod.

def var ptpcontrato like  poldtpcontrato.
def var pcarteira like poldcarteira.

def var vdtref  as date.
vdtref = vdtini. 

def var vconta as int init 0.
def var vtime as int.
vtime = time. 
hide message no-pause.
message color normal "fazendo calculos... aguarde...".


for each ttmovimdoc.
    delete ttmovimdoc.
end.

if pfiltro = "Geral" or (pfiltro <> "Geral" and ppagamento = "Recebimentos" or ppagamento = "Novacoes")
then
for each pdvtmov where pdvtmov.pagamento = yes no-lock.
            if poldctmcod <> "" and poldctmcod <> ?
            then if pdvtmov.ctmcod <> poldctmcod
                 then next.
    if pfiltro = "Geral"
    then do:
        if pdvtmov.novacao 
        then ppagamento = "Novacoes".
        else ppagamento = "Recebimentos".
    end. 
    else do:
        if (ppagamento = "Novacoes" and pdvtmov.novacao) or 
           (ppagamento = "Recebimentos" and pdvtmov.novacao = no)
        then.
        else next. 
    end.

for each estab 
    where if vetbcod = 0
          then true
          else estab.etbcod = vetbcod
    no-lock.
        if not poldfiltro = "geral"
        then if poldetbcod <> ?
             then if estab.etbcod <> poldetbcod
                  then next.
       
        hide message no-pause.
        message color normal "fazendo calculos... aguarde..." "  processando:" string(time - vtime, "HH:MM:SS")
                estab.etbcod pdvtmov.ctmnom .
        
        for each pdvdoc use-index pagamentos where 
                pdvdoc.ctmcod = pdvtmov.ctmcod and
                pdvdoc.pstatus = yes and
                pdvdoc.etbcod = estab.etbcod and 
                pdvdoc.datamov >= vdtini and
                pdvdoc.datamov <= vdtfin no-lock.
            if pdvdoc.valor <> 0 and pdvdoc.placod = 0
            then.
            else next.
           vconta = vconta +  1. 
            if vconta mod 10000 = 0 or vconta < 10
            then do: 
            hide message no-pause.
            message color normal "fazendo calculos... aguarde..." "  processando:" string(time - vtime, "HH:MM:SS")
            estab.etbcod
                pdvtmov.ctmnom vconta.
            end.                
            vaux = int64(pdvdoc.contnum) no-error.
            
            if vaux = 0 or vaux = ? then next.
            
            release titulo.
            
            find titulo where titulo.contnum = vaux  and
                                  titulo.titpar  = pdvdoc.titpar
                                  no-lock no-error.
            if not avail titulo
            then do:                           
                find contrato where contrato.contnum = vaux no-lock no-error.
                if avail contrato
                then do: 
                    find titulo where
                            titulo.empcod = 19 and
                            titulo.titnat = no and
                            titulo.etbcod = contrato.etbcod and
                            titulo.clifor = contrato.clicod and
                            titulo.modcod = contrato.modcod and
                            titulo.titnum = pdvdoc.contnum and
                            titulo.titpar = pdvdoc.titpar and
                            titulo.titdtemi = contrato.dtinicial
                        no-lock no-error.
                end.
            end.                                                   
            
            if pfiltro = "geral"
            then do:
                
                petbcod     = ?.
                pctmcod     = ?.
                pmodcod     = ?.
                pcarteira   = ?.
                ptpcontrato = ?.
                pcobcod     = ?.
            end.                 
            else do:
                pctmcod   = poldctmcod. 
                pcarteira = poldcarteira.
                pmodcod   = poldmodcod.
                petbcod   = poldetbcod.
                ptpcontrato = poldtpcontrato.
                pcobcod     = poldcobcod.
            end.
            if pfiltro = "carteira" 
            then do:
                pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.
            end. 
            else do:
                if poldcarteira = yes
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N")) 
                               or not avail titulo
                     then.
                     else next.
                if poldcarteira = no
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                     then next.
            end.
            
            if pfiltro = "tpcontrato"
            then do:
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.
            end.                
            else do:
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                if poldtpcontrato <> ?
                then if ( if avail titulo then titulo.tpcontrato else "") <> poldtpcontrato
                     then next.
            end.
            
            if pfiltro = "modalidade"
            then pmodcod = if avail titulo then titulo.modcod else "".
            else do:
                if poldmodcod <> ?
                then if avail titulo and titulo.modcod <> poldmodcod
                     then next.
            end.
            
            if pfiltro = "Filial"
            then petbcod = pdvdoc.etbcod.
            else do:
                if poldetbcod <> ?
                then if pdvdoc.etbcod <> poldetbcod
                     then next.
            end.
            if pfiltro = "Propriedade"
            then pcobcod = if avail titulo then titulo.cobcod else 0.
            else do:
                if poldcobcod <> ?
                then if (if avail titulo then titulo.cobcod else 0) <> poldcobcod
                     then next.
            end.
            if pfiltro = "Operacao"
            then pctmcod = pdvdoc.ctmcod.
            else do:
                if poldctmcod <> ?
                then if pdvdoc.ctmcod <> poldctmcod
                     then next.
            end.
            
            
            run pegaproduto (int(titulo.titnum)).

                find first ttmovimdoc where
                    ttmovimdoc.pagamento = ppagamento and
                    ttmovimdoc.filtro   = pfiltro and
                    ttmovimdoc.produto  = vproduto
                    /*
                    ttmovimdoc.ctmcod   = pctmcod and
                    ttmovimdoc.carteira = pcarteira and
                    ttmovimdoc.modcod   = pmodcod  and
                    ttmovimdoc.etbcod   = petbcod and
                    ttmovimdoc.tpcontrato = ptpcontrato and
                    ttmovimdoc.cobcod   = pcobcod 
                    **/
                    no-error.
                if not avail ttmovimdoc
                then do:
                    create ttmovimdoc.
                    ttmovimdoc.pagamento = ppagamento.
                    ttmovimdoc.filtro = pfiltro.
                    ttmovimdoc.produto = vproduto.
                    /**
                    ttmovimdoc.ctmcod = pctmcod.
                    ttmovimdoc.carteira = pcarteira.
                    ttmovimdoc.modcod   = pmodcod.
                    ttmovimdoc.etbcod   = petbcod.
                    ttmovimdoc.tpcontrato = ptpcontrato.
                    ttmovimdoc.cobcod   = pcobcod.
                    **/
                end.

                    
                assign
                    ttmovimdoc.titvlcob = ttmovimdoc.titvlcob + pdvdoc.titvlcob
                    ttmovimdoc.encargo  = ttmovimdoc.encargo  + pdvdoc.valor_encargo
                    ttmovimdoc.desconto = ttmovimdoc.desconto + pdvdoc.desconto
                    ttmovimdoc.valor    = ttmovimdoc.valor    + pdvdoc.valor.

                
                vtitvlcob = vtitvlcob + pdvdoc.titvlcob.
                vjuros = vjuros + pdvdoc.valor_encargo.
                vdescontos = vdescontos + pdvdoc.desconto.
                vtotal = vtotal + pdvdoc.valor.
      
        end.        
        end.
end.            
hide message no-pause.

           
           
           /* vendas */

    if pfiltro = "Geral"
    then do:
        ppagamento = "Vendas".
    end. 
           
if pfiltro = "Geral" or (pfiltro <> "Geral" and ppagamento = "Vendas")
then
 
for each estab 
    where if vetbcod = 0
          then true
          else estab.etbcod = vetbcod
    no-lock.
        if not poldfiltro = "geral"
        then if poldetbcod <> ?
             then if estab.etbcod <> poldetbcod
                  then next.
    
        for each contrsite where contrsite.etbcod = estab.etbcod and
                                 contrsite.datatransacao >= vdtini and
                                 contrsite.datatransacao <= vdtfin
                                 no-lock.
            find contrato where contrato.contnum = contrsite.contnum no-lock no-error.
            if not avail contrato then next.
            
            run pegaproduto (contrato.contnum).
            
                find first ttmovimdoc where
                    ttmovimdoc.pagamento = "Vendas Site" and
                    ttmovimdoc.filtro   = pfiltro and
                    ttmovimdoc.produto  = vproduto
                    /**
                    ttmovimdoc.ctmcod   = "SITE" and
                    ttmovimdoc.carteira = pcarteira and
                    ttmovimdoc.modcod   = pmodcod  and
                    ttmovimdoc.etbcod   = petbcod and
                    ttmovimdoc.tpcontrato = ptpcontrato and
                    ttmovimdoc.cobcod   = pcobcod 
                    **/
                    no-error.
                if not avail ttmovimdoc
                then do:
                    create ttmovimdoc.
                    ttmovimdoc.pagamento = "Vendas Site".
                    ttmovimdoc.filtro = pfiltro.
                    ttmovimdoc.produto = vproduto.
                    /**
                    ttmovimdoc.ctmcod = "SITE".
                    ttmovimdoc.carteira = pcarteira.
                    ttmovimdoc.modcod   = pmodcod.
                    ttmovimdoc.etbcod   = petbcod.
                    ttmovimdoc.tpcontrato = ptpcontrato.
                    ttmovimdoc.cobcod   = pcobcod.
                    **/
                end.

                assign
                    /*
                    ttmovimdoc.titvlcob = ttmovimdoc.titvlcob + pdvdoc.titvlcob
                    ttmovimdoc.encargo  = ttmovimdoc.encargo  + pdvdoc.valor_encargo
                    ttmovimdoc.desconto = ttmovimdoc.desconto + pdvdoc.desconto
                    */
                    ttmovimdoc.valor    = ttmovimdoc.valor    + contrato.vltotal.
            
        end.

for each pdvtmov where pdvtmov.pagamento = no no-lock.

            if poldctmcod <> "" and poldctmcod <> ?
            then if pdvtmov.ctmcod <> poldctmcod
                 then next.

       
        hide message no-pause.
        message color normal "fazendo calculos... aguarde..." estab.etbcod
            pdvtmov.ctmnom "  processando:" string(time - vtime, "HH:MM:SS").
.
        
        for each pdvdoc use-index pagamentos where 
                pdvdoc.ctmcod = pdvtmov.ctmcod and
                pdvdoc.pstatus = yes and
                pdvdoc.etbcod = estab.etbcod and 
                pdvdoc.datamov >= vdtini and
                pdvdoc.datamov <= vdtfin no-lock.
            if pdvdoc.valor <> 0 and pdvdoc.placod <> 0
            then.
            else next.
           vconta = vconta +  1. 
            if vconta mod 10000 = 0 or vconta < 10
            then do: 
            hide message no-pause.
            message color normal "fazendo calculos... aguarde..." estab.etbcod
                pdvtmov.ctmnom vconta "  processando:" string(time - vtime, "HH:MM:SS").
            end.      
            vaux = int64(pdvdoc.contnum) no-error.
            
            if vaux = 0 or vaux = ? then next.          
            
            release contrato.
            
                find contrato where contrato.contnum = int64(pdvdoc.contnum) no-lock no-error.
                if not avail contrato
                then next.

            find first titulo where titulo.contnum = contrato.contnum and
                                    titulo.titpar = 1
                    no-lock no-error.
            if not avail titulo
            then next.
            
            if pfiltro = "geral"
            then do:
                
                petbcod     = ?.
                pctmcod     = ?.
                pmodcod     = ?.
                pcarteira   = ?.
                ptpcontrato = ?.
                pcobcod     = ?.
            end.                 
            else do:
                pctmcod   = poldctmcod. 
                pcarteira = poldcarteira.
                pmodcod   = poldmodcod.
                petbcod   = poldetbcod.
                ptpcontrato = poldtpcontrato.
                pcobcod     = poldcobcod.
            end.
            
            if pfiltro = "carteira" 
            then do:
                pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.
            end. 
            else do:
                if poldcarteira = yes
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N")) 
                               or not avail titulo
                     then.
                     else next.
                if poldcarteira = no
                then if  (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                     then next.
            end.
            
            if pfiltro = "tpcontrato"
            then do:
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                pcarteira   = if (avail titulo and (titulo.tpcontrato = "" or titulo.tpcontrato = "N") )
                               or not avail titulo
                              then true
                              else false.
            end.                
            else do:
                    /*
                ptpcontrato = if avail titulo then titulo.tpcontrato else "".
                */
                if poldtpcontrato <> ?
                then if ( if avail titulo then titulo.tpcontrato else "") <> poldtpcontrato
                     then next.
            end.
            
            if pfiltro = "modalidade"
            then pmodcod = if avail titulo then titulo.modcod else "".
            else do:
                if poldmodcod <> ?
                then if avail titulo and titulo.modcod <> poldmodcod
                     then next.
            end.
            
            if pfiltro = "Filial"
            then petbcod = pdvdoc.etbcod.
            else do:
                if poldetbcod <> ?
                then if pdvdoc.etbcod <> poldetbcod
                     then next.
            end.
            if pfiltro = "Propriedade"
            then pcobcod = if avail titulo then titulo.cobcod else 0.
            else do:
                if poldcobcod <> ?
                then if (if avail titulo then titulo.cobcod else 0) <> poldcobcod
                     then next.
            end.
            if pfiltro = "Operacao"
            then pctmcod = pdvdoc.ctmcod.
            else do:
                if poldctmcod <> ?
                then if pdvdoc.ctmcod <> poldctmcod
                     then next.
            end.
            
            
            /*if pfiltro = "vencimento"
            then do:
                pdtvenc = poscart.dtvenc.
            end.  
            else do:
                if polddtvenc <> ?
                then if poscart.dtvenc <> polddtvenc
                     then next.
            end.
            **/     

            
            run pegaproduto (contrato.contnum).
            
                find first ttmovimdoc where
                    ttmovimdoc.pagamento = ppagamento and
                    ttmovimdoc.filtro   = pfiltro and
                    ttmovimdoc.produto  = vproduto
                    /**
                    ttmovimdoc.ctmcod   = pctmcod and
                    ttmovimdoc.carteira = pcarteira and
                    ttmovimdoc.modcod   = pmodcod  and
                    ttmovimdoc.etbcod   = petbcod and
                    ttmovimdoc.tpcontrato = ptpcontrato and
                    ttmovimdoc.cobcod   = pcobcod 
                    **/
                    no-error.
                if not avail ttmovimdoc
                then do:
                    create ttmovimdoc.
                    ttmovimdoc.pagamento = ppagamento.
                    ttmovimdoc.filtro = pfiltro.
                    ttmovimdoc.produto = vproduto.
                    /**
                    ttmovimdoc.ctmcod = pctmcod.
                    ttmovimdoc.carteira = pcarteira.
                    ttmovimdoc.modcod   = pmodcod.
                    ttmovimdoc.etbcod   = petbcod.
                    ttmovimdoc.tpcontrato = ptpcontrato.
                    ttmovimdoc.cobcod   = pcobcod.
                    **/
                    
                end.

                assign
                    /*
                    ttmovimdoc.titvlcob = ttmovimdoc.titvlcob + pdvdoc.titvlcob
                    ttmovimdoc.encargo  = ttmovimdoc.encargo  + pdvdoc.valor_encargo
                    ttmovimdoc.desconto = ttmovimdoc.desconto + pdvdoc.desconto
                    */
                    ttmovimdoc.valor    = ttmovimdoc.valor    + contrato.vltotal.

                /*
                vtitvlcob = vtitvlcob + pdvdoc.titvlcob.
                vjuros = vjuros + pdvdoc.valor_encargo.
                vdescontos = vdescontos + pdvdoc.desconto.
                */
        end.        
        end.
end.            
hide message no-pause.
            
end procedure.



procedure pegaproduto.
def input param par-contnum as int.
    
    find ctbpostitprod where ctbpostitprod.contnum = par-contnum no-l~ock no-error.
    if avail ctbpostitprod
    then do:
        vproduto = ctbpostitprod.produto.
        return.
    end.
        
    vproduto = "DESCONHECIDO".
    def var vcatcod as int.        
    
    find contrato where contrato.contnum = par-contnum no-lock no-err~or.
    if avail contrato
    then do:
        find contrsite where contrsite.contnum = contrato.contnum 
            no-lock no-error.
        if avail contrsite
        then do:
            vproduto = "Cre Digital".
        end.
        else do:
            if contrato.modcod begins "CP"
            then do:
                vproduto = "Emprestimos".
            end.
            else do:    
                find first contnf where 
                    contnf.etbcod = contrato.etbcod and
                    contnf.contnum = contrato.contnum 
                    no-lock no-error.
                if avail contnf 
                then do:
                    find first plani where
                        plani.etbcod = contnf.etbcod and
                        plani.placod = contnf.placod 
                        no-lock no-error. 
                    if avail plani
                    then do:
                        vcatcod = 0.
                        for each movim where movim.etbcod = plani.etbcod and
                                             movim.placod = plani.placod
                                             no-lock.
                            find produ of movim no-lock no-error.
                            if avail produ
                            then do:                    
                                if produ.catcod = 31 or produ.catcod = 41
                                then do:
                                    find categoria of produ no-lock.
                                    vproduto = caps(categoria.catnom).
                                    leave.
                                end.
                                else vcatcod = produ.catcod. 
                            end.
                        end.
                        if vproduto = "DESCONHECIDO"
                        then do:
                            find categoria where categoria.catcod = vcatcod no-~lock no-error.
                            if avail categoria
                            then do:
                                vproduto = caps(categoria.catnom).
                            end.     
                        end.        
                    end.                                   
                end.          
            end.
        end.                     
    end.    
    if not avail ctbpostitprod
    then do on error undo:
        create ctbpostitprod.
        ctbpostitprod.contnum = par-contnum.
        ctbpostitprod.produto = vproduto.
    end.    
    
end procedure.    



procedure geracsv.

   def var varq as char format "x(76)".
   def var vcp  as char init ";".
   varq = "/admcom/tmp/ctb/produto" + ( if vetbcod = 0 then "ger" else string(vetbcod)) + 
                             "_"   + string(today,"999999")  + replace(string(time,"HH:MM:SS"),":","") +
                             ".csv" .
                               
    pause 0.
    update skip(2) varq skip(2)
        with
        centered 
        overlay
        color messages
        no-labels
        row 8
        title "arquivo de saida".
        
    output to value(varq).    
        put unformatted 
            vfiltro skip.
            
        put unformatted

            "Produto" vcp
            "Valor Nominal" vcp
            "Encargos" vcp
            "Desconto" vcp
            "Valor Total" vcp
        
            skip.        
    
    for each ttmovimdoc.

        put unformatted
            trim(caps(ttmovimdoc.produto)) vcp
            ttmovimdoc.titvlcob vcp
            ttmovimdoc.encargo vcp
            ttmovimdoc.desconto vcp
            ttmovimdoc.valor vcp
            skip.

    end.
    
    output close.
    message varq "gerado com sucesso.".
    pause 2 no-message.

end procedure.



