/* *******************************      
*****************************************
*  Progrma...: crm20-metr.p
*  Funcao....: Metrica Geral
***********************************************************************  */ 

{admcab.i}

def input        parameter p-acao   as integer.
def input-output parameter p-fabcod as integer.

/*def var p-acao as int initial 47578.*/

def stream str-csv1.
def stream str-csv2.

if opsys = "UNIX"
then do:

    output stream str-csv1
            to value("/admcom/relat/crm20-par-" + string(time) + ".csv").
    output stream str-csv2
            to value("/admcom/relat/crm20-des-" + string(time) + ".csv").

end.
else do:

    output stream str-csv1
            to value("l:\relat\crm20-par-" + string(time) + ".csv").
    output stream str-csv2
            to value("l:\relat\crm20-des-" + string(time) + ".csv").

end.


def var varquivo as char.
def var vbonus as dec.
def var vqtd   as int.
def var val_fin as int.
def var val_des as int.
def var val_dev as int.
def var val_acr as int.
def var val_com as int.
def var v-valor as dec.
def var vquant as int.
def var vpartic as int.
def var vpartret as int.
def var vvenda as int.
def var vvendadesc as int.
def var vbonusm as int.
def var vfilial as int.

def var vrentab like acao.valor.
def var vcusto like acao.valor.
def var selfil as logical initial no format "Sim/Nao".
def var vetbcod like setbcod.

def var vdia as int.
def var vacum-valor as dec.      
def var vtotal-cli as int format ">>>>>9".
def var vperc-acum as dec format ">>>9.99".

def var vtotval like acao.valor.
def var vtotqtd as int format ">>>>>>>>9".
def var vparti  as int format ">>>>>9".

def var vint-conta-partic as integer   no-undo.
def var vcha-cod-cli-aux  as character no-undo.

def temp-table tt-metrica
    field acaocod   like acao.acaocod
    field d         as   int format ">>9"
    field dia       as   date format "99/99/9999"
    field parti     as   int format ">>>>>>9"
    field qtd       as   int format ">>>>>>9"
    field valor     like acao.valor
    field valor-plani like acao.valor
    field acum-valor like acao.valor
    field perc-dia  as   dec format ">>9.99"
    field perc-acum as   dec format ">>>9.99"
    field estcusto  like estoq.estcusto
    field etbcod like estab.etbcod 
    index ipri is primary unique acaocod dia 
    index idia dia asc.
    
def temp-table tt-excel 
    field etbcod like estab.etbcod
    field partic as int format "->>>>>>9"
    field de     as date
    field ate    as date
    field partret as int format ">>>>>>9"
    field venda   like acao.valor
    field vendadesc as dec
    field bonusm    as dec
    field bonust    as dec
    field bonusv    as dec
    field vfilial   as dec
    field partcbv   as dec
    index idx etbcod.

def temp-table tt-totalcli
    field etbcod like estab.etbcod
    field qtd    as int.

def temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.

def temp-table tt-partic-retorno
    field clicod as integer
    index idx01 clicod.
    
def var vperc as dec format ">>9.99%".

def buffer bf-plani   for plani.
def buffer bf-acao    for acao.

def buffer bf1-movim  for movim.
def buffer bf1-produ  for produ.

def var vlog-encontrou-fab as logical no-undo.


form p-fabcod label "Fabricante"
with frame f-update-fab width 40 row 10
              title " Filtro por fabricante "
                     OVERLAY side-labels centered  color black/cyan.

/* ------------------------------------------------------------------------ */

find acao where acao.acaocod = p-acao no-lock no-error.
if not avail acao then leave.

def new shared temp-table tt-campanha like campanha.
sresp = no.
message "Usar parametros EMBRACE ?" update sresp.
if sresp
then do:
    run campanha.p.
end.
hide message.

selfil = no.
vetbcod = setbcod.
message "Seleciona Filial ?" update selfil.
if selfil
then do:
    message "Informe Filial a Selecionar : " update vetbcod.
    find first estab where estab.etbcod = vetbcod no-lock no-error.
    if not avail estab 
    then do:
        message "Estabelecimento Invalido" view-as alert-box.
            undo, retry.
    end.
end.
hide message.


message "Aguarde, gerando consulta ...".


put stream str-csv1 
    "Estabelecimento"
    ";"              
    "Numero"         
    ";"              
    "Cod Cliente"    
    ";"              
    "Data"           
    ";"              
    "Cod Produto"    
    ";"             
    "Nome Produto"   
    ";"              
    "Cod Fabricante" 
  skip  .                
    
put stream str-csv2
    "Estabelecimento"
    ";"
    "Numero"
    ";"
    "Cod Cliente"
    ";"
    "Data"
    ";"
    "Cod Produto"
    ";"
    "Nome Produto"
    ";"
    "Cod Fabricante"
    skip.
    
for each acao-cli where acao-cli.acaocod = acao.acaocod no-lock.
    find first tt-campanha where
               tt-campanha.clicod = acao-cli.clicod no-error.
    if sresp and not avail tt-campanha
    then next.            
    
    /* antonio - filtra estab */

    if selfil
    then do:

        find first crm.rfvcli where
                   crm.rfvcli.clicod = acao-cli.clicod
              and  crm.rfvcli.setor  = 0
                         no-lock no-error.

        if avail crm.rfvcli then do:        
            if crm.rfvcli.etbcod <> vetbcod then next.
        end.
    end.
    
    vtotal-cli = vtotal-cli + 1.
    
end.

if sfuncod = 101
then do:

    message "Debug Custom antes plani ".

end.


for each acao-cli where 
         acao-cli.acaocod = acao.acaocod no-lock,
    each plani where plani.movtdc  = 5 
                 and plani.desti   = acao-cli.clicod 
                 and plani.pladat >= acao.dtini 
                 and plani.pladat <= acao.dtfin
                 no-lock break by plani.desti:
                 
    if sfuncod = 101
    then do:
                 
        message "Debug Custom dentro plani "  plani.numero.
        pause.

    end.
                 

    /* antonio - filtra estab */
    if selfil            
    then do:
            find first crm.rfvcli where
                       crm.rfvcli.clicod = acao-cli.clicod 
                   and crm.rfvcli.setor  = 0    
                    no-lock no-error.
            if avail crm.rfvcli then do:        
                if crm.rfvcli.etbcod <> vetbcod then next.        
            end.

             
    end.
    
    if sresp then do:
        find first tt-campanha where
                   tt-campanha.clicod = acao-cli.clicod no-error.
        if sresp and not avail tt-campanha
        then next. 
    end.
   
    if p-fabcod > 0
    then do:

        assign vlog-encontrou-fab = no.

        bloco_procura_fab:
        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock,

           first produ where produ.procod = movim.procod
                         and produ.fabcod = p-fabcod    no-lock:
                         
           if sfuncod = 101
           then do:
               
               message "Debug Custom dentro movim "  movim.procod.                         
           end.              

           assign vlog-encontrou-fab = yes.


            put stream str-csv1
                 plani.etbcod  format ">>>>>>>9"
                 ";"
                 plani.numero  format ">>>>>>>9"
                 ";"
                 plani.desti   format ">>>>>>>9"
                 ";"
                 plani.pladat  format "99/99/9999"
                 ";"
                 produ.procod  format ">>>>>>>9"
                 ";"
                 produ.pronom  format "x(40)"
                 ";"
                 produ.fabcod  format ">>>>>>>9"
                 skip.

           leave bloco_procura_fab.

        end.

        if not vlog-encontrou-fab
        then do:


        put stream str-csv2
             plani.etbcod format ">>>>>>>9"
             ";"
             plani.numero format ">>>>>>>9"
             ";"
             plani.desti  format ">>>>>>>9"
             ";"
             plani.pladat format "99/99/9999"
             ";"
             ";"
             ";"
             skip.

             next.
        end.

    end.

      
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 1.5 "  plani.numero.
         pause.
        
     end.
 

     for each  titulo where                                    
               titulo.clifor = acao-cli.clicod and
               titulo.modcod = "BON"
                        no-lock use-index iclicod:        
                                                               
~        if titulo.modcod = "BON" and                          
           titulo.titobs[1] = string(acao.acaocod)             
        then do:                                               
            assign vbonus = vbonus  + titulo.titvlcob          
                   vqtd   = vqtd + 1.                          
        end.                                                   
     end.                                                      

 
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 1.6 "  plani.numero.
         pause.
        
     end.
 

 



    /*vtotal-cli = vtotal-cli + 1.*/
    if not selfil then do:
        find first tt-totalcli where tt-totalcli.etbcod = plani.etbcod no-lock         no-error.
        if not avail tt-totalcli then do:
            create tt-totalcli.
            assign tt-totalcli.etbcod = plani.etbcod
                   tt-totalcli.qtd = tt-totalcli.qtd + 1.
        end.
        else do:
            assign tt-totalcli.qtd = tt-totalcli.qtd + 1.
        end.
     end.

 
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 1.7 "  plani.numero.
         pause.
        
     end.
 

 
     
        find tt-metrica where 
             tt-metrica.acaocod = acao.acaocod and
             tt-metrica.dia = plani.pladat no-error.
        if not avail tt-metrica
        then do:
            create tt-metrica.
            assign tt-metrica.acaocod = acao.acaocod
                   tt-metrica.dia     = plani.pladat
                   tt-metrica.etbcod  = plani.etbcod.
        end.
        
 
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 1.8 "  plani.numero.
         pause.
        
     end.
 

 

        for each movim where movim.etbcod = plani.etbcod
                         and movim.placod = plani.placod
                         and movim.movtdc = plani.movtdc
                         and movim.movdat = plani.pladat no-lock.
        
            find estoq where estoq.etbcod = movim.etbcod
                         and estoq.procod = movim.procod no-lock no-error.
            tt-metrica.estcusto = tt-metrica.estcusto +
                    (movim.movqtm * estoq.estcusto).
            
            tt-metrica.valor = tt-metrica.valor +
                    (movim.movpc * movim.movqtm).


             val_fin = 0.                   
             val_des = 0.  
             val_dev = 0.  
             val_acr = 0. 
                         
             val_acr =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.acfprod.
             val_des =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.descprod.
             val_dev =  ((movim.movpc * movim.movqtm) / plani.platot) * 
                            plani.vlserv.
    
             if (plani.platot - plani.vlserv - plani.descprod) < plani.biss
                then
             val_fin =  ((((movim.movpc * movim.movqtm) - val_dev - val_des)/
                            (plani.platot - plani.vlserv - plani.descprod))
                            * plani.biss) - ((movim.movpc * movim.movqtm) - 
                            val_dev - val_des).

             val_com = (movim.movpc * movim.movqtm) - val_dev - val_des +
              val_acr + val_fin. 

                
             v-valor = val_com.
                
             vquant = movim.movqtm.
                
             find first ttvend where ttvend.etbcod = plani.etbcod
                                 and ttvend.funcod = plani.vencod
                                 no-error.
             if not avail ttvend
             then do:
                 create ttvend.
                 assign 
                     ttvend.funcod = plani.vencod
                     ttvend.etbcod = plani.etbcod.
             end. 
                     ttvend.platot = ttvend.platot + v-valor. 
                     ttvend.qtd    = ttvend.qtd + vquant. 
             /*if plani.pladat = vdtf 
                then ttvend.pladia = ttvend.pladia + v-valor.*/
                
             find first ttvend where ttvend.etbcod = 999
                                 and ttvend.funcod = plani.vencod
                                     no-error.
             if not avail ttvend
             then do:
                 create ttvend.
                 assign 
                     ttvend.funcod = plani.vencod
                     ttvend.etbcod = 999.
             end. 
             ttvend.platot = ttvend.platot + v-valor. 
             ttvend.qtd    = ttvend.qtd + vquant. 
             /*if plani.pladat = vdtf 
                then ttvend.pladia = ttvend.pladia + v-valor.*/
        end.
        
        /*
        for each bf-plani where
                 bf-plani.etbcod     = plani.etbcod   and
                 bf-plani.placod     = plani.placod   and
                 bf-plani.serie      = plani.serie    no-lock
                 break /*by bf-plani.etbcod 
                       by bf-plani.placod 
                       by bf-plani.serie*/
                       by bf-plani.desti:
                 
          if first-of(bf-plani.desti)
          then do:
                  assign tt-metrica.parti = tt-metrica.parti + 1.
          end.
                  
        end.
        */
        
        /* 28/05/2010 -  Laureano - Como o next foi usado antes, não se deve                                         usar o first-of neste bloco. 
        if first-of(plani.desti)
        then do:
                assign tt-metrica.parti = tt-metrica.parti + 1.
        end.
        */

 
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 1.9 "  plani.numero.
         pause.
        
     end.
 

 
        
        if not can-find (first tt-partic-retorno
                         where tt-partic-retorno.clicod = plani.desti)
        then do:
                         
            assign tt-metrica.parti = tt-metrica.parti + 1.             
            
            create tt-partic-retorno.
            assign tt-partic-retorno.clicod = plani.desti.
                         
        end.                 
        
        assign vtotqtd = vtotqtd + 1
               vtotval = vtotval + (if plani.biss > 0 
                                    then plani.biss 
                                    else plani.platot)
               tt-metrica.qtd = tt-metrica.qtd + 1
               tt-metrica.valor-plani = 
                    tt-metrica.valor-plani + (if plani.biss > 0
                                              then plani.biss
                                              else plani.platot).
    
      
     if sfuncod = 101
     then do:
                                                      
         message "Debug Custom dentro plani 2 "  plani.numero.
         pause.
        
     end.
                                              
end.


hide message no-pause.
find first tt-metrica no-lock no-error.
if not avail tt-metrica
then do:
    message "Nenhum retorno nesta acao.".
    assign p-fabcod = 0.

    pause 5 no-message. leave.
    
end.

vcusto = 0.
vperc-acum = 0.
vacum-valor = 0.
vdia = 0.
vparti = 0.

for each tt-metrica:
    vdia = vdia + 1.
    vparti = vparti + tt-metrica.parti.
    tt-metrica.d = vdia.
    tt-metrica.perc-dia  =  ((tt-metrica.parti * 100) / vtotal-cli).
    vperc-acum = vperc-acum + tt-metrica.perc-dia.
    tt-metrica.perc-acum =  tt-metrica.perc-acum + vperc-acum.
    
    vacum-valor = vacum-valor + tt-metrica.valor-plani.
    tt-metrica.acum-valor = tt-metrica.acum-valor + vacum-valor.

    tt-metrica.valor = tt-metrica.valor +
                    (tt-metrica.valor-plani - tt-metrica.valor).
    vcusto = vcusto + tt-metrica.estcusto.
    
    if selfil then do:
        find tt-excel where tt-excel.etbcod = vetbcod no-lock no-error.
        if avail tt-excel then do:
            assign tt-excel.partret = tt-excel.partret + tt-metrica.parti.
        end.
        else do:
        
            find bf-acao where bf-acao.acaocod = p-acao no-lock no-error.

            create tt-excel.
            assign tt-excel.etbcod  = vetbcod
                   tt-excel.de      = bf-acao.dtini
                   tt-excel.ate     = bf-acao.dtfin
                   tt-excel.vendadesc = tt-metrica.valor-plani
                   tt-excel.partic   = tt-metrica.parti.
            
                                
            if tt-metrica.etbcod = vetbcod then
              assign tt-excel.partret = tt-excel.partret + tt-metrica.parti.
              
            if vbonus <> 0 then  
            assign tt-excel.bonusm   = (vbonus / qtd)
                   tt-excel.bonust   = tt-excel.bonusm * tt-excel.partret
                   tt-excel.bonusv   = ((tt-excel.bonust / tt-excel.partret) / 100).
            
            assign tt-excel.venda = tt-excel.bonust + tt-excel.vendadesc.
            
            find first ttvend where ttvend.etbcod = vetbcod no-lock no-error.
            if avail ttvend then
                   assign tt-excel.vfilial = ttvend.platot
                          tt-excel.partcbv = ((tt-excel.venda / tt-excel.vfilial) / 100). 
  
        end.
    end.
    else do:
        find tt-excel where tt-excel.etbcod = tt-metrica.etbcod no-lock no-error.
        if avail tt-excel then do:
            assign tt-excel.partret = tt-excel.partret + tt-metrica.parti.
        end.
        else do:
        
            find bf-acao where bf-acao.acaocod = p-acao no-lock no-error.
            find first tt-totalcli where tt-totalcli.etbcod = tt-metrica.etbcod no-lock no-error.
            create tt-excel.
            assign tt-excel.etbcod  = tt-metrica.etbcod
                   tt-excel.de      = bf-acao.dtini
                   tt-excel.ate     = bf-acao.dtfin
                   tt-excel.partret = tt-excel.partret + tt-metrica.parti
                   tt-excel.vendadesc = tt-metrica.valor-plani
                   tt-excel.partic    = tt-metrica.parti.            
                          
       /*if avail tt-totalcli then tt-totalcli.qtd else 0.*/
             if vbonus <> 0 then
             assign tt-excel.bonusm   = (vbonus / vqtd)
                    tt-excel.bonust   = tt-excel.bonusm * tt-excel.partret
                    tt-excel.bonusv   = ((tt-excel.bonust / tt-excel.partret) 
                                        / 100).
                    
                    
            assign tt-excel.venda = tt-excel.bonust + tt-excel.vendadesc.
            
            find first ttvend where ttvend.etbcod = tt-metrica.etbcod no-lock no-error.
            if avail ttvend then do:
            
                   assign tt-excel.vfilial = ttvend.platot
                          tt-excel.partcbv = ((tt-excel.venda / tt-excel.vfilial) / 100).       
            end.
        end.
    end.
end.

hide message no-pause.

def buffer btt-metrica for tt-metrica.

def var recatu1         as recid.
def var recatu2         as recid.
def var reccont         as int.
def var esqpos1         as int.
def var esqpos2         as int.
def var esqregua        as log.
def var esqvazio        as log.
def var esqascend     as log initial yes.
def var esqcom1         as char format "x(15)" extent 5
    initial [""," EXCEL"," Filtrar Fabric.","",""].
def var esqcom2         as char format "x(12)" extent 5
            initial [" "," ","","",""].
def var esqhel1         as char format "x(80)" extent 5
    initial ["",
             "",
             "",
             "",
             ""].
def var esqhel2         as char format "x(12)" extent 5
   initial ["  ",
            " ",
            " ",
            " ",
            " "].

form
    esqcom1
    with frame f-com1
                 row 3 no-box no-labels side-labels column 1 centered.
form
    esqcom2
    with frame f-com2
                 row screen-lines no-box no-labels side-labels column 1
                 centered.
assign
    esqregua = yes
    esqpos1  = 1
    esqpos2  = 1.

bl-princ:
repeat:

    disp esqcom1 with frame f-com1.
    disp esqcom2 with frame f-com2.
    if recatu1 = ?
    then
        run leitura (input "pri").
    else
        find tt-metrica where recid(tt-metrica) = recatu1 no-lock.
    if not available tt-metrica
    then esqvazio = yes.
    else esqvazio = no.
    clear frame frame-a all no-pause.
    if not esqvazio
    then do:
        run frame-a.
    end.

    recatu1 = recid(tt-metrica).
    if esqregua
    then color display message esqcom1[esqpos1] with frame f-com1.
    else color display message esqcom2[esqpos2] with frame f-com2.
    if not esqvazio
    then repeat:
        run leitura (input "seg").
        if not available tt-metrica
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
            find tt-metrica where recid(tt-metrica) = recatu1 no-lock.

            status default
                if esqregua
                then esqhel1[esqpos1] + if esqpos1 > 1 and
                                           esqhel1[esqpos1] <> ""
                                        then ""
                                        else ""
                else esqhel2[esqpos2] + if esqhel2[esqpos2] <> ""
                                        then ""
                                        else "".
            pause 0. run p-total. pause 0.
            run color-message.
            choose field tt-metrica.d
                         tt-metrica.dia 
                         tt-metrica.parti
                         tt-metrica.perc-dia
                         tt-metrica.perc-acum
                         tt-metrica.qtd
                         tt-metrica.valor
                         tt-metrica.acum-valor
                         help ""
                go-on(cursor-down cursor-up
                      cursor-left cursor-right
                      page-down   page-up
                      tab PF4 F4 ESC return) /*color white/black*/.
            run color-normal.
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
                    run leitura (input "down").
                    if not avail tt-metrica
                    then leave.
                    recatu1 = recid(tt-metrica).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "page-up"
            then do:
                do reccont = 1 to frame-down(frame-a):
                    run leitura (input "up").
                    if not avail tt-metrica
                    then leave.
                    recatu1 = recid(tt-metrica).
                end.
                leave.
            end.
            if keyfunction(lastkey) = "cursor-down"
            then do:
                run leitura (input "down").
                if not avail tt-metrica
                then next.
                color display white/red tt-metrica.d
                                        tt-metrica.dia  
                                        tt-metrica.parti
                                        tt-metrica.perc-dia 
                                        tt-metrica.perc-acum
                                        tt-metrica.qtd
                                        tt-metrica.valor 
                                        tt-metrica.acum-valor
                                        with frame frame-a.
                if frame-line(frame-a) = frame-down(frame-a)
                then scroll with frame frame-a.
                else down with frame frame-a.
            end.
            if keyfunction(lastkey) = "cursor-up"
            then do:
                run leitura (input "up").
                if not avail tt-metrica
                then next.
                color display white/red tt-metrica.d
                                        tt-metrica.dia  
                                        tt-metrica.parti
                                        tt-metrica.perc-dia 
                                        tt-metrica.perc-acum
                                        tt-metrica.qtd 
                                        tt-metrica.valor 
                                        tt-metrica.acum-valor
                                        with frame frame-a.
                                        
                if frame-line(frame-a) = 1
                then scroll down with frame frame-a.
                else up with frame frame-a.
            end.
 
        if keyfunction(lastkey) = "end-error"
        then do:
            leave bl-princ.
        end.            

        if keyfunction(lastkey) = "return" or esqvazio
        then do:
            if esqregua
            then do:
                display caps(esqcom1[esqpos1]) @ esqcom1[esqpos1]
                        with frame f-com1.

                if esqcom1[esqpos1] = " EXCEL"
                then do:
                    hide frame f-com1  no-pause.
                    hide frame f-com2  no-pause.
                    run p-excel.
                    view frame f-com1.
                    view frame f-com2.
                end.
 
                if esqcom1[esqpos1] = " Filtrar Fabric."
                then do:
                    
                    pause 0.
                    
                    update p-fabcod
                       WITH frame f-update-fab OVERLAY SIDE-LABELS.
                    
                    pause 0.

                    return.
                    
                end.
                
                leave.
            end.
            else do:
                display caps(esqcom2[esqpos2]) @ esqcom2[esqpos2]
                        with frame f-com2.
                if esqcom2[esqpos2] = " "
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
        else display esqcom2[esqpos2] with frame f-com2.
        recatu1 = recid(tt-metrica).
    end.
    if keyfunction(lastkey) = "end-error"
    then do:
    
        assign p-fabcod = 0.
    
        find first tt-metrica where tt-metrica.acaocod = 0.
        if avail tt-metrica
        then
            delete tt-metrica.
        recatu1 = ?.    
            
        view frame fc1.
        view frame fc2.
    end.
end.
hide frame f-com1  no-pause.
hide frame f-com2  no-pause.
hide frame frame-a no-pause.

procedure frame-a.
    display tt-metrica.d         no-label
            tt-metrica.dia       column-label "Dia"   format "99/99/9999"
            tt-metrica.parti     column-label "Partic" format ">>>>>>9"
            tt-metrica.perc-dia  column-label "% Dia"
            tt-metrica.perc-acum column-label "% Acum"        
            tt-metrica.qtd       column-label "Qtd NF"   format ">>>>>9"
            tt-metrica.valor     column-label "Valor"
            tt-metrica.acum-valor column-label "Val.Acum"
            with frame frame-a 10 down column 3 color white/red row 4
                                 title " Metrica " .
end procedure.

procedure color-message.
    color display message
            tt-metrica.d         no-label
            tt-metrica.dia       column-label "Dia"  format "99/99/9999"
            tt-metrica.parti     column-label "Partic" format ">>>>>>9"
            tt-metrica.perc-dia  column-label "% Dia"
            tt-metrica.perc-acum column-label "% Acum"        
            tt-metrica.qtd       column-label "Qtd NF"  format ">>>>>9"
            tt-metrica.valor     column-label "Valor"
            tt-metrica.acum-valor column-label "Val.Acum"
            with frame frame-a.
end procedure.
procedure color-normal.
    color display normal
        tt-metrica.d         no-label
        tt-metrica.dia       column-label "Dia"  format "99/99/9999"
        tt-metrica.parti     column-label "Partic" format ">>>>>>9"
        tt-metrica.perc-dia  column-label "% Dia"
        tt-metrica.perc-acum column-label "% Acum"        
        tt-metrica.qtd       column-label "Qtd NF"  format ">>>>>9"
        tt-metrica.valor     column-label "Valor"
        tt-metrica.acum-valor column-label "Val.Acum"
        with frame frame-a.
end procedure.

procedure leitura. 
def input parameter par-tipo as char.
        
if par-tipo = "pri" 
then  
    if esqascend  
    then  
        find first tt-metrica where true
                                                no-lock no-error.
    else  
        find last tt-metrica  where true
                                                 no-lock no-error.
                                             
if par-tipo = "seg" or par-tipo = "down" 
then  
    if esqascend  
    then  
        find next tt-metrica  where true
                                                no-lock no-error.
    else  
        find prev tt-metrica   where true
                                                no-lock no-error.
             
if par-tipo = "up" 
then                  
    if esqascend   
    then   
        find prev tt-metrica where true  
                                        no-lock no-error.
    else   
        find next tt-metrica where true 
                                        no-lock no-error.
        
end procedure.
         

procedure p-total.
    vrentab = (vtotval - (vcusto + acao.valor)).
    vperc = ((vparti * 100) / vtotal-cli).
    
    disp
         "TOTAL VENDA   |->" vtotval    no-label skip
         "TOTAL CUSTO   |->" vcusto     no-label skip
         "CUSTO DA ACAO |->" acao.valor no-label skip
         "RENTABILIDADE |->" vrentab    no-label
         with frame f-tot col 4  no-box. pause 0.

    disp
         "PARTIC. DA ACAO |->" vtotal-cli no-label "/ 100.00%" 
         "PARTIC. RETORNO |->" vparti no-label "/"
         vperc no-label
         with frame f-tot2 col 37 no-box. pause 0.

end procedure.

procedure p-excel:

    /*varquivo = "/admcom/custom/adriana/teste.txt".*/
    
    if opsys = "UNIX"
    then assign
            varquivo = "/admcom/relat/crm20-conacao" + 
                            string(time) + ".xls".
    else assign
            varquivo = "l:\relat\crm20-conacao" +
                            string(time) + ".xls".

    output to value(varquivo) page-size 0.
        
    put unformatted     "Filial" + ";" +     "Periodo" + ";" + "" + ";" + 
        "Participantes" + ";" + "Retorno" + ";" + ";" 
        "Metrica" + ";" + "" + ";" + "" + ";" + "" + ";" +
        "Parametro" + ";" + "Venda Filial" + ";" + "Partic Bonus X Venda" skip.
    
    put unformatted "" + ";" + "De" + ";" + "Ate" + ";" + "Selecionados" + 
        ";" +  "Geral" +     ";" + "% Retorno" + ";" + "Venda" + ";" + 
        "Venda /desc." + ";" + "Bonus medio" + ";" + "Bonus Total" + ";" +              "Bonus/Vendas" skip.
    
    for each tt-excel no-lock
             break by tt-excel.etbcod:
        
        put unformatted  string(tt-excel.etbcod,">>>9") + ";" +                                         string(tt-excel.de,"99/99/9999") + ";" +                 ~                     string(tt-excel.ate,"99/99/9999") + ";" +                 ~                      string(tt-excel.partic,">>>>9")   + ";" +                 ~                      string(tt-excel.partret,">>>99") + ";" +
                       string(((tt-excel.partret / tt-excel.partic) * 100),">>9,99")   + ";" +
                         string(tt-excel.venda,"->>>,>>9.99")  + ";" +                                    string(tt-excel.vendadesc,"->>>,>>9.99") + ";"  +
                         string(tt-excel.bonusm,"->>9.99") +  ";" +                        ~              string(tt-excel.bonust,"->>9.99") + ";" +                                   ~   string(tt-excel.bonusv,"->>9.99") + "%"  + ";" + 
                         string(tt-excel.vfilial,"->>>,>>9.99")  + ";" +
                         string(tt-excel.partcbv,">>9,99") + "%" 
                         skip.

    assign vpartic = vpartic + tt-excel.partic
           vpartret = vpartret + tt-excel.partret
           vvenda   = vvenda + tt-excel.venda
           vvendadesc = vvendadesc + tt-excel.vendadesc
           vbonusm  = vbonusm + tt-excel.bonusm
           vfilial  = vfilial + tt-excel.vfilial. 
           
    
    if last(tt-excel.etbcod) then do:
        put unformatted ";" + ";" + "Total" + ";" + 
            string(vtotal-cli,"->>>,>>9.99") +  ";" +
            string(vpartret,"->>>,>>9.99") + ";" + 
            string((vpartret / vpartic),"->>>,>>9.99") + ";" +
            string(vvenda,"->>>,>>9.99") + ";" +
            string(vvendadesc,"->>>,>>9.99") + ";" +
            string(vbonusm,"->>>,>>9.99") + ";" +
            string((vpartret * vbonusm),"->>>,>>9.99") + ";" +
            string(((vpartret * vbonusm) / vvenda),"->>>,>>9.99") + ";" +
            string(vfilial,"->>>,>>9.99") + ";" +
            string(((vvenda / vfilial) / 100),"->>>,>>9.99") skip.
    end. 

end.

    output close.
    
    if opsys = "UNIX"
    then do:
        message color red/with
        "Arquivo para EXCEL gerado l:~\relat~\crm20-conacao.xls"
        view-as alert-box.
        
       /* run visurel.p(input varquivo, input "").*/
    end.
    else do:
        os-command silent start value(varquivo).
    end.        
end.

output close.
