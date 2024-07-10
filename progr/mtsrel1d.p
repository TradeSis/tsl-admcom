{admcab.i}


def input parameter r_recid as recid.

def var vfer as int.
def var ii as i.
def var vv as date.
def var vdia as int format ">9".

def var   i_codmeta     like cadmetas.codmeta.
def var   d_vlrmet      like cadmetas.vlrmeta.
def var   t_perini      like cadmetas.perini.
def var   t_perfin      like cadmetas.perfin.
def var   c_funnom      like func.funnom.
def var   d_totvlrven   like plani.platot.
def var   d_totvlrfun   like plani.platot.
def var   d_difil       like plani.platot.
def var   d_pefil       as deci form "->>>9.99 %".

def var   d_perven      as deci form ">>9.99".

def var   c_msg         as char.
def var   c_filtro      as char.
def var   i_regis       as inte                 init 0.

def var   varquivo      as char.
def var   h_temin       as char.
def var   h_temfi       as char.
def var   c_label       as char.
def var   l_existe      as logi init no.
def var   c_data        as char form "x(20)".
def var   t_dt          as int.
def var   t_dtdia       as int.
def var   t_dtformula   as int.

def var   d_metProFil   like plani.platot.
def var   d_vdaAteFil   like plani.platot.
def var   d_difereFil   like plani.platot.
def var   d_percenFil   like plani.plades.
def var   d_metProVen   like plani.platot.
def var   d_vdaAteVen   like plani.platot.
def var   d_difereVen   like plani.platot.
def var   d_percenVen   like plani.plades.
def var   i_salta       as inte init 0.
def var   i_qtd_vdloja  as inte init 0.
def var   d_vlr_vdloja  like plani.platot.

def stream st_tela.
def stream st_rela.

assign h_temin = string(time,"HH:MM:SS").

if opsys = "UNIX"
then varquivo = "/admcom/relat/mtsrel2a" + string(time) + ".txt" .
else varquivo = "..\relat\mtsrel2a" + string(time) + ".txt".

/* -------------------------------------------------------------------*/       
find first cadmetas where
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then do:
        assign i_codmeta  = cadmetas.codmeta
               d_vlrmet   = cadmetas.vlrmeta
               t_perini   = cadmetas.perini
               t_perfin   = cadmetas.perfin.
end.

def temp-table tt-cons    
    field camposeq    as inte
    field campocod    like cadmetas.codmeta
    field campoest    like estab.etbcod
    field campofab    like fabri.fabcod
    field campocat    like categoria.catcod
    field campopro    like produ.procod
    field campocla    like clase.clacod
    field campofue    like estab.etbcod
    field campofuf    like func.funcod
    index campocod    is primary campocod.

def temp-table tt-rel    no-undo
    field codmeta    like cadmetas.codmeta
    field etbcod     like estab.etbcod
    field funcod     like func.funcod
    field perven     as deci form ">>9.99"
    field vlrven     as deci form ">>,>>>,>>9.99"
    field vlrmet     as deci form ">>,>>>,>>9.99"
    field etbseq     as inte form ">>>>>>>9"
    field funseq     as inte form ">>>>>>>9"
    field qtdmov     as inte form ">>>9"
    index pri-seq    is primary etbseq funseq
    index chave      etbcod funcod
    index ch-etbcod  etbcod
    index ch-funcod  funcod.

def temp-table tt-venda     no-undo
    field etbcod     like estab.etbcod
    field venda      like plani.platot
    field vlrmest    like cadmetasest.vlrmest   
    field qtdmov     as inte form ">>>9"
    field qtdvdlj    as inte form ">>>9"
    field vlrvdlj    like plani.platot
    index ch-etbcod  is primary is unique etbcod
    index ch-venda   venda.

def new shared temp-table tt-filtro    
    field codmeta    like cadmetas.codmeta
    field etbcod     like estab.etbcod
    field procod     like produ.procod
    field fabcod     like fabri.fabcod
    field catcod     like categoria.catcod
    field clacod     like clase.clacod
    field funcod     like func.funcod
    field mostra     as char form "x(01)" init ""
    index ch_procod  procod
    index ch_etbcod  etbcod
    index ch_funcod  funcod
    index ch_func    etbcod funcod
    index ch_pri     etbcod procod.

def temp-table tt-calven     no-undo
    field etbcod     like estab.etbcod
    field venda      like plani.platot
    field vlrmest    like cadmetasest.vlrmest   
    field funcod     like func.funcod
    field movpc  like movim.movpc
    field numero like plani.numero
    field movdat like movim.movdat
    field qtdmov     as inte form ">>>9"
    index ch-etbcod  is primary etbcod funcod
    index ch-venda   venda.

def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
def new shared      var p-loja      like estab.etbcod.

def new shared temp-table ttvenpro
    field platot    like plani.platot
    field funcod    like plani.vencod 
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field procod    like produ.procod
    field etbcod    like plani.etbcod
    index valor     platot desc.

def new shared temp-table ttvend
    field platot    like plani.platot
    field funcod    like plani.vencod
    field pladia    like plani.platot
    field qtd       like movim.movqtm
    field numseq    like movim.movseq
    field etbcod    like plani.etbcod
    index valor     platot desc.

def var i_seq   as inte      init 0.
def buffer bf-cons  for tt-cons.
def buffer bf-cadmetasprodu for cadmetasprodu.

for each tt-filtro:
    delete tt-filtro.
end.    
for each tt-venda:
    delete tt-venda.
end.    
for each tt-rel:
    delete tt-rel.
end.    
for each tt-calven:
    delete tt-calven.
end.    

run pi-consulta.

assign d_totvlrven = 0
       d_totvlrfun = 0.

def var t_movfin as date.

if today <= t_perfin
then t_movfin = today - 1.
else t_movfin = t_perfin.

/*
message t_perini t_movfin. pause.
*/
run pi-calcuvenda.

assign d_totvlrfun = 0.

hide frame f-msg.

assign i_regis = 0.

hide frame f-1.

assign i_regis = 9999999.

for each tt-venda no-lock break by tt-venda.venda:

    for each tt-rel where
             tt-rel.etbcod = tt-venda.etbcod
             exclusive-lock:
        assign tt-rel.etbseq = i_regis.
    end.
    
    assign i_regis = i_regis - 1.         
             
end.

assign i_regis = 9999999.

for each tt-rel no-lock
         break by tt-rel.etbcod
               by tt-rel.vlrven:
               
         assign tt-rel.funseq = i_regis.
                    
         assign i_regis = i_regis - 1.           
end.               

assign c_filtro = "Meta: " + string(i_codmeta) + 
                  " Periodo:  " + 
                  string(t_perini,"99/99/9999") + " ate " +
                  string(t_perfin,"99/99/9999").

assign i_regis     = 0
       d_totvlrven = 0
       c_label     = "Venda ate " + string("99/99/99").
/**
def var t_movfin as date.

if today <= t_perfin
then t_movfin = today - 1.
else t_movfin = t_perfin.
**/
c_data = string(t_movfin).

/*
{mdadmcab.i
     &Saida     = "value(varquivo)"
     &Page-Size = "64"
     &Cond-Var  = "110"
     &Page-Line = "66"
     &Nom-Rel   = ""MTSREL1A.P""
     &Nom-Sis   = """SISTEMA COMPRAS"""
     &Tit-Rel   = """RELATORIO DE METAS FILIAL VENDEDOR  "" +
                  c_filtro"
     &Width     = "110"
     &Form      = "frame f-rel01"}
*/

output to value(varquivo).

for each tt-rel no-lock
         break by tt-rel.etbseq
               by tt-rel.etbcod
               by tt-rel.vlrven descending
               by tt-rel.funcod:
   
    find first func where
               func.etbcod = tt-rel.etbcod  and
               func.funcod = tt-rel.funcod  no-lock no-error.
    if avail func
    then assign c_funnom = func.funnom.
    else assign c_funnom = "".

    assign d_totvlrven = d_totvlrven + tt-rel.vlrven.

    if first-of(tt-rel.etbcod)
    then do:
            /*put tt-rel.etbcod.*/
            find first tt-venda where
                       tt-venda.etbcod = tt-rel.etbcod no-lock no-error.
            if avail tt-venda
            then do:    

                  /* dias uteis */
                  /*
                  ii = 0. 
                  vfer = 0. 
                  vdia = 0.  
                  
                  do vv = t_perini to t_perfin: 
                      if weekday(vv) = 1 
                      then ii = ii + 1. 
                    
                      find dtextra where dtextra.exdata  = vv no-lock no-error. 
                      if avail dtextra 
                      then vfer = vfer + 1. 
                    
                      find dtesp where dtesp.datesp = vv 
                                   and dtesp.etbcod = tt-rel.etbcod
                                   no-lock no-error.
                      if avail dtesp
                      then vfer = vfer + 1.
                  end.
        
                  vdia = int(day(t_perfin)) - ii - vfer.
                  
                  t_dt = vdia.  
                  */
                  /**************/

                   assign d_metProFil = 0
                          d_vdaAteFil = 0
                          d_difereFil = 0
                          d_percenFil = 0.
                          
                  /*******************************************************/
                   run p_dias.
                   run p_periodo.
                   if t_dtdia > t_dtformula
                   then t_dtdia = t_dtformula.
                   
                   assign d_difil = tt-venda.venda - 
                                    ((tt-venda.vlrmest / t_dtformula) * 
                                      t_dtdia).  /* Diferenca filial */

                   assign d_metProFil = ((tt-venda.vlrmest / t_dtformula) *
                                          t_dtdia). /* Meta Proposta Filial */                   
                   assign d_pefil = (d_difil / d_metProFil) * 100. 
                                    /* Percentual */
                           
                   disp 
                       tt-venda.etbcod    column-label "Filial"
                       "          " no-label
                       tt-venda.vlrmest   
                       form "->>>,>>9.99" column-label "Meta Mes Filial"
                       (t_dtformula) form ">>9"  column-label "Dia do Mes" 
                       /*
                       ((tt-venda.vlrmest / t_dtformula) * t_dtdia)
                       */
                       d_metProFil
                       form "->>>,>>9.99" column-label "Meta Dia Proposta"
                       tt-venda.venda     
                       form "->>>,>>9.99" column-label "Venda ate         "
                       tt-venda.qtdmov column-label "Qtde"
                       /*
                       tt-venda.venda - tt-venda.vlrmest /* / 
                                         t_dtformula) * t_dtdia */
                       */
                       d_difil                  
                       form "->>>,>>9.99" column-label "Diferenca"
                       /*
                       ((tt-venda.venda - tt-venda.vlrmest) /
                       (tt-venda.vlrmest)) * 100 
                       */
                       d_pefil
                       form "->>>,>>9.99 %" column-label "Percentual"
                       with frame f-1 width 120.
                       
                   put "Vendedor" 
                       space(17)
                       "Meta Mes"
                       space(01)
                       "Dia do Mes"
                       space(01)
                       "Meta Dia Proposta"
                       space(01)
                       "Venda ate " trim(c_data)
                       space(03)
                       "Qtde"
                       space(03)
                       "Diferenca"
                       space(04)
                       "Percentual"
                       skip
                       fill("-",114) form "x(114)"
                       skip.
                       
            end.
                 
    end. 

    if last-of(tt-rel.funcod)
    then do:
            assign d_metProVen  = 0
                   d_vdaAteVen  = 0
                   d_difereVen  = 0
                   d_percenVen  = 0.
    end.               
    if last-of(tt-rel.funcod)
    then do:
                  /* dias uteis */
                  /*
                  ii = 0. 
                  vfer = 0. 
                  vdia = 0.  
                  
                  do vv = t_perini to t_perfin: 
                      if weekday(vv) = 1 
                      then ii = ii + 1. 
                    
                      find dtextra where dtextra.exdata  = vv no-error. 
                      if avail dtextra 
                      then vfer = vfer + 1. 
                    
                      find dtesp where dtesp.datesp = vv 
                                   and dtesp.etbcod = tt-rel.etbcod
                                   no-lock no-error.
                      if avail dtesp
                      then vfer = vfer + 1.
                  end.
        
                  vdia = int(day(t_perfin)) - ii - vfer.
                  
                  t_dt = vdia.
                 */ 
                  
                  /**************/
            run p_dias.
            run p_periodo.
            if t_dtdia > t_dtformula
            then t_dtdia = t_dtformula.

            put  tt-rel.funcod form ">>>9" 
                 space(01)
                 c_funnom      form "x(16)"
                 space(01) 
                 if tt-rel.vlrmet <> 0
                 then tt-rel.vlrmet
                 else tt-venda.vlrvdlj     
                 form "->>>,>>9.99"
                 space(08) 
                 t_dtformula
                 form ">>9"
                 space(07) 
                 (if tt-rel.vlrmet <> 0
                   then ((tt-rel.vlrmet / (t_dtformula)) * (t_dtdia))
                   else ((tt-venda.vlrvdlj / ( t_dtformula))* (t_dtdia)))
                 form "->>>,>>9.99"
                 space(08) 
                 tt-rel.vlrven      
                 form "->>>,>>9.99"
                 space(01)
                 tt-rel.qtdmov
                 space(01)
                 /*
                 tt-rel.vlrven - (if tt-rel.vlrmet <> 0
                                    then tt-rel.vlrmet 
                                    else tt-venda.vlrvdlj)                  
                 */                   
                 
                 (tt-rel.vlrven - if tt-rel.vlrmet <> 0
                                  then (tt-rel.vlrmet /
                                         t_dtformula) * t_dtdia
                                  else (tt-venda.vlrvdlj / 
                                        t_dtformula) * t_dtdia)
                                    
                 form "->>>,>>9.99"
                 space(01)  
                 ((tt-rel.vlrven - if tt-rel.vlrmet <> 0
                                   then (tt-rel.vlrmet /
                                          t_dtformula) * t_dtdia
                                   else (tt-venda.vlrvdlj /
                                         t_dtformula) * t_dtdia) /
                  (if tt-rel.vlrmet <> 0
                  then ((tt-rel.vlrmet / (t_dtformula)) * (t_dtdia))
                  else ((tt-venda.vlrvdlj / ( t_dtformula))* (t_dtdia)))
                                          * 100)
                 /*                         
                 if tt-rel.vlrmet <> 0
                  then ((tt-rel.vlrmet / (t_dtformula)) * (t_dtdia))
                  /*then tt-rel.vlrmet*/
                  else ((tt-venda.vlrvdlj / ( t_dtformula)) * (t_dtdia)) * 100)
                  /* else tt-venda.vlrvdlj)) * 100 */
                  */
                 form "->>>,>>9.99 %"
                 skip.
                 
            assign d_totvlrven = 0.
    end.
end.

assign h_temfi = string(time,"HH:MM:SS").

output close.

if opsys = "UNIX"
then run visurel.p(input varquivo, input "").
else do:
        {mrod.i}
end.

/* ----------------------------------------------------------------- */

procedure pi-consulta:

def var i_nseq   as inte init 0.

for each tt-cons:
    delete tt-cons.
end.    
    
find first cadmetas where
           cadmetas.codmeta = i_codmeta no-lock no-error.
if avail cadmetas
then do:    
    
       assign i_seq  = 0.

       find first cadmetasprodu where
                  cadmetasprodu.codmeta = cadmetas.codmeta no-lock no-error.
       if not avail cadmetasprodu
       then do:
           for each produ no-lock:

               assign i_seq  = i_seq + 1.


               assign c_msg = "" 
                      c_msg = "PROCESSANDO - 1. > " + string(i_seq).
               run pi-msg.


               create tt-cons.
               assign tt-cons.camposeq = i_seq
                      tt-cons.campocod = cadmetas.codmeta
                      tt-cons.campopro = produ.procod.
           end.    
       end.
       else do:
          for each bf-cadmetasprodu where
                   bf-cadmetasprodu.codmeta = cadmetas.codmeta no-lock:
                   
           for each produ where
                    produ.procod = bf-cadmetasprodu.procod no-lock:

               assign i_seq  = i_seq + 1.

               assign c_msg = "" 
                      c_msg = "PROCESSANDO - 1. > " + string(i_seq).
               run pi-msg.

               create tt-cons.
               assign tt-cons.camposeq = i_seq
                      tt-cons.campocod = cadmetas.codmeta
                      tt-cons.campopro = produ.procod.
           end.
          end.     
       end. 
       
end.

hide frame f-pros.
end procedure.

procedure pi-msg:
          
     disp c_msg no-label form "x(70)"
          with frame f-msg width 90
               side-label 1 col 1 down
               row 15 col 05
               overlay no-box.

     pause 0 no-message.

end procedure.

/*
procedure pi-calven:

    run mtsvnd1a.p (input 0).

end procedure.
*/

procedure pi-calcuvenda:

def var vdti       as date form "99/99/9999" init 03/30/2007.
def var vdtf       as date form "99/99/9999" init 04/30/2007.
def var i_etbcod   like estab.etbcod.
def var d_venda    like plani.platot.
def var d_vdafil   like plani.platot.
def var i_qtd      as inte. 
def var i_qtdvend  as inte. 

def var val_acr like plani.platot.
def var val_des like plani.platot.
def var val_dev like plani.platot.
def var val_com like plani.platot.
def var val_fin like plani.platot.

find first cadmetas where 
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then do:
     for each cadmetasest where
              cadmetasest.codmeta = cadmetas.codmeta no-lock:

          for each cadmetasprodu where
                   cadmetasprodu.codmeta = cadmetasest.codmeta   
                   no-lock:
        
            for each produ where 
                     produ.procod = cadmetasprodu.procod no-lock:
                for each estab where 
                         estab.etbcod = cadmetasest.etbcod no-lock:
                        for each movim where movim.procod = produ.procod and
                                             movim.movtdc = 5            and
                                             movim.etbcod = estab.etbcod and
                                             movim.movdat >= t_perini    and
                                             movim.movdat <= t_movfin /*
                                             movim.movdat <= t_perfin  */
                                             /*(today - 1)*/ 
                                             /*t_perfin*/ no-lock:
        
                            find plani where plani.movtdc = 5            and
                                             plani.placod = movim.placod and
                                             plani.etbcod = movim.etbcod and
                                             plani.pladat = movim.movdat 
                                                     no-lock no-error.
                            if not avail plani
                            then next.
                            
                            disp plani.etbcod
                                 plani.vencod with frame f-2 side-label
                                                   1 col 1 down col 15 row 6.
                            pause 0 no-message.                        

                                create tt-calven.
                                assign tt-calven.etbcod = plani.etbcod
                                       tt-calven.funcod = plani.vencod
                                       tt-calven.qtdmov = movim.movqtm.
                         
                                       
                         /*** Formula substituida pela Venda(2) ****
                                       tt-calven.movpc  
                                          = (movim.movpc * movim.movqtm) .

                                if plani.biss > 0 and /* vacr and */
                                   (plani.platot - plani.vlserv - 
                                   plani.descprod + plani.acfprod) >= 1
                   
                                then assign tt-calven.movpc = 
                                            tt-calven.movpc * (plani.biss / 
                                            ( plani.platot - plani.vlserv - 
                                              plani.descprod + plani.acfprod)).
                                              
                         ****  Final da substituicao  *****/
                         
                            val_fin = 0.
                            val_des = 0.
                            val_dev = 0.
                            val_acr = 0.
                            val_com = 0.
                            val_acr =  ((movim.movpc * movim.movqtm) /                                          plani.platot) * plani.acfprod.
                            if val_acr = ? then val_acr = 0.
                            
                            val_des =  ((movim.movpc * movim.movqtm) /                                          plani.platot) * plani.descprod.
                            if val_des = ? then val_des = 0.

                            val_dev =  ((movim.movpc * movim.movqtm) /                                          plani.platot) * plani.vlserv.
                            if val_dev = ? then val_dev = 0.
            
                            if (plani.platot - plani.vlserv - plani.descprod) <                                 plani.biss
                            then
                                val_fin =  ((((movim.movpc * movim.movqtm) -                                             val_dev - val_des) /
                                (plani.platot - plani.vlserv - plani.descprod))
                                 * plani.biss) - ((movim.movpc * movim.movqtm) -
                                           val_dev - val_des).
                  
                            if val_fin = ? then val_fin = 0.
                            
                            val_com = (movim.movpc * movim.movqtm) - val_dev -                                        val_des + val_acr + val_fin.
                          
                            if val_com = ? then val_com = 0.

                            assign tt-calven.movpc = val_com.

                        end.
                end.
            end.
          end.
     end.
end.

assign i_qtd        = 0
       i_qtdvend    = 0
       i_qtd_vdloja = 0.

for each tt-calven no-lock 
         break by tt-calven.etbcod 
               by tt-calven.funcod:


    assign d_venda      = d_venda       + tt-calven.movpc
           d_vdafil     = d_vdafil      + tt-calven.movpc.
    assign i_qtd        = i_qtd         + tt-calven.qtdmov
           i_qtdvend    = i_qtdvend     + tt-calven.qtdmov.
           
    if first-of(tt-calven.funcod)
    then do:
           assign i_qtd_vdloja = i_qtd_vdloja  + 1.
    end. 
           
    if last-of(tt-calven.etbcod)
    then do:
            find first cadmetas where 
                       cadmetas.codmeta  = i_codmeta no-lock no-error.
            if avail cadmetas
            then do:
                     for each cadmetasest where
                              cadmetasest.codmeta = cadmetas.codmeta and
                              cadmetasest.etbcod  = tt-calven.etbcod
                              no-lock:
                              
                        create tt-venda.
                        assign tt-venda.etbcod = tt-calven.etbcod
                               tt-venda.venda  = d_vdafil
                               tt-venda.qtdmov = i_qtd.

                        if cadmetasest.vlrmest > 0
                        then assign tt-venda.vlrmest =
                                    cadmetasest.vlrmest.
                        else assign tt-venda.vlrmest =
                                    cadmetas.vlrmest.

                        assign tt-venda.vlrvdlj = (tt-venda.vlrmest / 
                                                  i_qtd_vdloja)
                               tt-venda.qtdvdlj = i_qtd_vdloja.
                               /* Didide meta da loja por qtd de vendores */ 

                     end.
            end.
            assign d_vdafil     = 0
                   i_qtd        = 0
                   i_qtd_vdloja = 0.
    end.
    
    if last-of(tt-calven.funcod)
    then do:
            /*
            if d_venda < d_vlrmet  or d_venda = ?  
            then next. 
            */
            create tt-rel. 
            assign tt-rel.codmeta  = i_codmeta 
                   tt-rel.etbcod   = tt-calven.etbcod 
                   tt-rel.funcod   = tt-calven.funcod 
                   tt-rel.perven   = 0 
                   tt-rel.vlrven   = d_venda  
                   tt-rel.vlrmet   = d_vlrmet
                   tt-rel.qtdmov   = i_qtdvend.
            assign d_venda   = 0
                   i_qtdvend = 0.
    end.
   
end.

end procedure.


procedure p_dias:

  /* dias uteis */

  ii = 0. 
  vfer = 0. 
  vdia = 0.  
                  
  do vv = t_perini to today: 
     if weekday(vv) = 1 
     then ii = ii + 1. 
                    
     find dtextra where dtextra.exdata  = vv no-lock no-error. 
     if avail dtextra 
     then vfer = vfer + 1. 
                    
     find dtesp where dtesp.datesp = vv 
          and dtesp.etbcod = tt-venda.etbcod
          no-lock no-error.
     if avail dtesp
     then vfer = vfer + 1.
    end.
        
    vdia = int(day(t_perfin)) - ii - vfer.
                  
    /*t_dt = vdia.*/
    /*
    message ii skip
           vdia skip
           string(today - t_perini) skip
           ii view-as alert-box.
   */

   t_dtdia = (today - t_perini) - ii - vfer.

end procedure.

procedure p_periodo:

  /* dias uteis */

  ii = 0. 
  vfer = 0. 
  vdia = 0.  
                  
  do vv = t_perini to t_perfin: 
     if weekday(vv) = 1 
     then ii = ii + 1. 
                    
     find dtextra where dtextra.exdata  = vv no-lock no-error. 
     if avail dtextra 
     then vfer = vfer + 1. 
                    
     find dtesp where dtesp.datesp = vv 
          and dtesp.etbcod = tt-venda.etbcod
          no-lock no-error.
     if avail dtesp
     then vfer = vfer + 1.
    end.
        
    vdia = int(day(t_perfin)) - ii - vfer.
                  
    /*t_dt = vdia.*/
    
   t_dt = (t_perfin - t_perini) - ii.
   
   t_dtformula = ((t_perfin + 1) - t_perini) - ii - vfer.
               /*
    message ii skip
           vdia skip
           string(t_perfin - t_perini) skip
           ii skip
           vv skip
           t_dtformula view-as alert-box.
                 */
end procedure.
