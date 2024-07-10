{admcab.i}

pause 0 no-message.

def input parameter r_recid as recid.

def var   i_codmeta     like cadmetas.codmeta.
def var   d_vlrmet      like cadmetas.vlrmeta.
def var   t_perini      like cadmetas.perini.
def var   t_perfin      like cadmetas.perfin.
def var   c_funnom      like func.funnom.
def var   d_totvlrven   like plani.platot.
def var   d_totvlrfun   like plani.platot.

def var   d_perven      as deci form ">>9.99".

def var   c_msg         as char.
def var   c_filtro      as char.
def var   i_regis       as inte                 init 0.

def var   varquivo      as char.

def stream st_tela.
def stream st_rela.

if opsys = "UNIX"
then varquivo = "/admcom/relat/mtsrel1a." + string(time).
else varquivo = "..\relat\mtsrel1a." + string(time).

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
    field campofuf    like func.funcod.

def temp-table tt-rel    no-undo
    field codmeta    like cadmetas.codmeta
    field etbcod     like estab.etbcod
    field funcod     like func.funcod
    field perven     as deci form ">>9.99"
    field vlrven     as deci form ">>,>>>,>>9.99"
    field vlrmet     as deci form ">>,>>>,>>9.99"
    field etbseq     as inte form ">>>>>>>9"
    field funseq     as inte form ">>>>>>>9"
    index pri-seq    is primary etbseq funseq
    index chave      etbcod funcod
    index ch-etbcod  etbcod
    index ch-funcod  funcod.

def temp-table tt-venda     no-undo
    field etbcod     like estab.etbcod
    field venda      like plani.platot
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
    index ch_etbcod  etbcod
    index ch_funcod  funcod
    index ch_func    etbcod funcod.

def new shared      var vdti        as date format "99/99/9999" no-undo.
def new shared      var vdtf        as date format "99/99/9999" no-undo.
def new shared var p-loja      like estab.etbcod.

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


run pi-consulta.

assign d_totvlrven = 0
       d_totvlrfun = 0.

for each tt-filtro:
   delete tt-filtro.
end.
   
find first cadmetas where 
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then do:
     for each tt-cons where
              tt-cons.campocod  = cadmetas.codmeta no-lock:
              
         for each plani where
                  plani.movtdc = 5                           and
                  plani.etbcod = tt-cons.campoest            and
                  plani.pladat >= t_perini                   and
                  plani.pladat <= t_perfin                   no-lock
                  break by plani.etbcod
                        by plani.vencod:

             /*
             if plani.biss > 0
             then assign d_totvlrven = d_totvlrven + plani.biss.
             else assign d_totvlrven = d_totvlrven + plani.platot.
             */

             if plani.biss > 0
             then d_totvlrven = d_totvlrven + plani.biss.
             else d_totvlrven = d_totvlrven +
                                (plani.platot - plani.vlserv ).
                                        
             if last-of(plani.etbcod)
             then do:
                     find first tt-venda where
                                tt-venda.etbcod = plani.etbcod 
                                exclusive-lock no-error.
                     if not avail tt-venda
                     then do:           
                             create tt-venda.
                             assign tt-venda.etbcod = plani.etbcod
                                    tt-venda.venda  = d_totvlrven.
                             assign d_totvlrven     = 0.
                     end.
             end.

             for each movim where
                      movim.etbcod = plani.etbcod  and
                      movim.placod = plani.placod  no-lock:
                      
                 find produ where
                      produ.procod = movim.procod no-lock no-error.
                 if avail produ
                 then do:
                       create  tt-filtro.
                       assign  tt-filtro.codmeta = cadmetas.codmeta
                               tt-filtro.etbcod  = movim.etbcod
                               tt-filtro.procod  = movim.procod
                               tt-filtro.fabcod  = produ.fabcod
                               tt-filtro.catcod  = produ.catcod
                               tt-filtro.clacod  = produ.clacod
                               tt-filtro.funcod  = plani.vencod
                               tt-filtro.mostra  = "".
                 end.
             end.
         end.
     end.         
end.

assign c_msg = "" 
       c_msg = "PROCESSANDO - 2.".
run pi-msg.

/*
for each cadmetasest no-lock:

   find first tt-filtro where
              tt-filtro.etbcod = cadmetasest.etbcod
              exclusive-lock no-error.
   if avail tt-filtro
   then assign tt-filtro.mostra = "S".

end.
for each cadmetasfabri no-lock:

   find first tt-filtro where
              tt-filtro.fabcod = cadmetasfabri.fabcod
              exclusive-lock no-error.
   if avail tt-filtro
   then assign tt-filtro.mostra = "S".

end.
for each cadmetascategoria no-lock:

   find first tt-filtro where
              tt-filtro.catcod = cadmetascategoria.catcod
              exclusive-lock no-error.
   if avail tt-filtro
   then assign tt-filtro.mostra = "S".

end.
for each cadmetasprodu no-lock:

   find first tt-filtro where
              tt-filtro.procod = cadmetasprodu.procod
              exclusive-lock no-error.
   if avail tt-filtro
   then assign tt-filtro.mostra = "S".

end.
for each cadmetasclasse no-lock:

   find first tt-filtro where
              tt-filtro.clacod = cadmetasclasse.clacod
              exclusive-lock no-error.
   if avail tt-filtro
   then assign tt-filtro.mostra = "S".

end.
*/

for each tt-filtro exclusive-lock:

    find first cadmetasest where
               cadmetasest.etbcod = tt-filtro.etbcod 
               no-lock no-error.
    if avail cadmetasest
    then assign tt-filtro.mostra = "S".

    find first cadmetasfabr where
               cadmetasfabr.fabcod = tt-filtro.fabcod
               no-lock no-error.
    if avail cadmetasfabr
    then assign tt-filtro.mostra = "S".
               
    find first cadmetascategoria where
               cadmetascategoria.catcod = tt-filtro.catcod
               no-lock no-error.
    if avail cadmetascategoria
    then assign tt-filtro.mostra = "S".
                
    find first cadmetasprodu where
               cadmetasprodu.procod = tt-filtro.procod
               no-lock no-error.
    if avail cadmetasprodu
    then assign tt-filtro.mostra = "S".
                 
    find first cadmetasclasse where
               cadmetasclasse.clacod = tt-filtro.clacod
               no-lock no-error.
    if avail cadmetasclasse
    then assign tt-filtro.mostra = "S".
                  
    find first cadmetasfunc where
               cadmetasfunc.etbcod = tt-filtro.etbcod  and
               cadmetasfunc.funcod = tt-filtro.funcod
               no-lock no-error.
    if avail cadmetasfunc
    then assign tt-filtro.mostra = "S".

end.

assign d_totvlrfun = 0.

hide frame f-msg.

assign i_regis = 0.

for each ttvend:
    delete ttvend.
end.    

for each tt-filtro where
       /*  tt-filtro.mostra = "" or */
         tt-filtro.mostra = "S"  no-lock 
         break by tt-filtro.etbcod
               by tt-filtro.funcod:

    assign vdti   = t_perini
           vdtf   = t_perfin
           p-loja = tt-filtro.etbcod.

    run mtsvnd1a.p (input 0).

            assign i_regis = i_regis + 1.
            assign c_msg = "" 
                   c_msg = "PROCESSANDO - 3. => " +  
                           string(tt-filtro.procod) + " - " +
                           string(tt-filtro.etbcod) + " - " +
                           string(i_regis).
            run pi-msg.

     find first ttvend where
                ttvend.etbcod = tt-filtro.etbcod  and
                ttvend.funcod = tt-filtro.funcod no-lock no-error.
     if avail ttvend
     then do:
             if ttvend.platot < d_vlrmet  or
                ttvend.platot = ? 
             then next. 
             create tt-rel.
             assign tt-rel.codmeta  = tt-filtro.codmeta
                    tt-rel.etbcod   = ttvend.etbcod
                    tt-rel.funcod   = ttvend.funcod
                    tt-rel.perven   = 0
                    tt-rel.vlrven   = ttvend.platot 
                    tt-rel.vlrmet   = d_vlrmet.
     end.           
end.

hide frame f-1.

assign i_regis = 9999999.

for each tt-venda  no-lock
         break by tt-venda.etbcod
               by tt-venda.venda:

    for each tt-rel where
             tt-rel.etbcod = tt-venda.etbcod
             exclusive-lock:
        assign tt-rel.etbseq = i_regis.
    end.
    
    if last-of(tt-venda.etbcod)
    then assign i_regis = i_regis - 1.         
             
end.

assign i_regis = 9999999.

for each tt-rel no-lock
         break by tt-rel.etbcod
               by tt-rel.funcod
               by tt-rel.vlrven descending:
               
         assign tt-rel.funseq = i_regis.
                    
         assign i_regis = i_regis - 1.           
end.               


assign c_filtro = string(t_perini,"99/99/9999") + " ate " +
                  string(t_perfin,"99/99/9999").

{mdadmcab.i
    &Saida     = "value(varquivo)"
    &Page-Size = "64"
    &Cond-Var  = "130"
    &Page-Line = "66"
    &Nom-Rel   = ""mtsrel1a""
    &Nom-Sis   = """SISTEMA GERENCIAL"""
    &Tit-Rel   = """RELATORIO DE METAS  "" +
                 c_filtro"
    &Width     = "130"
    &Form      = "frame f-rel01"}

assign i_regis     = 0
       d_totvlrven = 0.

for each tt-rel no-lock
         break by tt-rel.etbseq
               by tt-rel.etbcod
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
            put skip(1)
                "Estabelecimento: "
                tt-rel.etbcod
                skip.
            find first tt-venda where
                       tt-venda.etbcod = tt-rel.etbcod no-lock no-error.
            if avail tt-venda
            then do:    
                   put "Valor Venda.. R$ "
                       tt-venda.venda  form ">>>,>>>,>>9.99"
                       skip
                       "Valor Meta... R$ "
                       tt-rel.vlrmet   form ">>>,>>>,>>9.99" 
                       space(02)
                       t_perini
                       " ate "
                       t_perfin 
                       skip.
                   find first cadmetas where
                              cadmetas.codmeta = tt-rel.codmeta
                              no-lock no-error.
                   if avail cadmetas
                   then put cadmetas.nommeta           
                        skip(1).
                   else put skip(1).     
            end.
                 
    end. 
    
    if last-of(tt-rel.funcod)
    then do:
            disp tt-rel.funcod      column-label "Funcionario"
                 c_funnom           no-label     form "x(20)"
                 ((tt-rel.vlrven / tt-venda.venda) * 100)
                 column-label "% Venda"
                 tt-rel.vlrven      column-label "Vlr Venda"
                 with down centered width 130 frame f-pro.
                 down with frame f-pro.
            assign d_totvlrven = 0.
    end.

end.

output close.
    
if opsys = "UNIX"
then do:
        run visurel.p(input varquivo, input "").
end.        
else do:
        {mrod.i} 
end.

/* ----------------------------------------------------------------- */
procedure pi-valida:


end procedure.

procedure pi-consulta:

assign c_msg = "" 
       c_msg = "PROCESSANDO - 1.".
run pi-msg.

for each tt-cons:
    delete tt-cons.
end.    
    
find first cadmetas where
           cadmetas.codmeta = i_codmeta no-lock no-error.
if avail cadmetas
then do:    

    for each cadmetasest where
             cadmetasest.codmeta = cadmetas.codmeta no-lock:
        assign i_seq  = i_seq + 1.
        create tt-cons.
        assign tt-cons.camposeq = i_seq 
               tt-cons.campocod = cadmetasest.codmeta
               tt-cons.campoest = cadmetasest.etbcod.
    end.

    assign i_seq = 0.
    
    for each cadmetasfabr where
             cadmetasfabr.codmeta = cadmetas.codmeta no-lock:
        
        assign i_seq = i_seq + 1.     
             
        find first tt-cons where
                   tt-cons.camposeq = i_seq                and  
                   tt-cons.campocod = cadmetasfabr.codmeta
                   exclusive-lock no-error.
        if avail tt-cons
        then do:
                assign tt-cons.campocod = cadmetasfabr.codmeta
                       tt-cons.campofab = cadmetasfabr.fabcod.
        end.
        else do:
                create tt-cons.
                assign tt-cons.camposeq = i_seq
                       tt-cons.campocod = cadmetasfabr.codmeta
                       tt-cons.campofab = cadmetasfabr.fabcod.
        end.               
    end.

    assign i_seq = 0.
    
    for each cadmetascategoria where
             cadmetascategoria.codmeta = cadmetas.codmeta no-lock:
    
        assign i_seq = i_seq + 1.     
             
        find first tt-cons where
                   tt-cons.camposeq = i_seq                     and
                   tt-cons.campocod = cadmetascategoria.codmeta
                   exclusive-lock no-error.
        if avail tt-cons
        then do:
                assign tt-cons.campocod = cadmetascategoria.codmeta
                       tt-cons.campocat = cadmetascategoria.catcod.
        end.
        else do:
                create tt-cons.
                assign tt-cons.camposeq = i_seq
                       tt-cons.campocod = cadmetascategoria.codmeta
                       tt-cons.campocat = cadmetascategoria.catcod.
        end.               
    end.
    
    assign i_seq = 0.
    
    for each cadmetasprodu where
             cadmetasprodu.codmeta = cadmetas.codmeta no-lock:
    
        assign i_seq = i_seq + 1.     
             
        find first tt-cons where
                   tt-cons.camposeq = i_seq                     and
                   tt-cons.campocod = cadmetasprodu.codmeta
                   exclusive-lock no-error.
        if avail tt-cons
        then do:
                assign tt-cons.campocod = cadmetasprodu.codmeta
                       tt-cons.campopro = cadmetasprodu.procod.
        end.
        else do:
                create tt-cons.
                assign tt-cons.camposeq = i_seq
                       tt-cons.campocod = cadmetasprodu.codmeta
                       tt-cons.campopro = cadmetasprodu.procod.
        end.               
    end.

    assign i_seq = 0.
    
    for each cadmetasclasse where
             cadmetasclasse.codmeta = cadmetas.codmeta no-lock:
    
        assign i_seq = i_seq + 1.     
             
        find first tt-cons where
                   tt-cons.camposeq = i_seq                     and
                   tt-cons.campocod = cadmetasclasse.codmeta
                   exclusive-lock no-error.
        if avail tt-cons
        then do:
                assign tt-cons.campocod = cadmetasclasse.codmeta
                       tt-cons.campocla = cadmetasclasse.clacod.
        end.
        else do:
                create tt-cons.
                assign tt-cons.camposeq = i_seq
                       tt-cons.campocod = cadmetasclasse.codmeta
                       tt-cons.campocla = cadmetasclasse.clacod.
        end.               
    end.

    assign i_seq = 0.
    
    for each cadmetasfunc where
             cadmetasfunc.codmeta = cadmetas.codmeta no-lock:
    
        assign i_seq = i_seq + 1.     
             
        find first tt-cons where
                   tt-cons.camposeq = i_seq                     and
                   tt-cons.campocod = cadmetasfunc.codmeta
                   exclusive-lock no-error.
        if avail tt-cons
        then do:
                assign tt-cons.campocod = cadmetasfunc.codmeta
                       tt-cons.campofue = cadmetasfunc.etbcod
                       tt-cons.campofuf = cadmetasfunc.funcod. 
        end.
        else do:
                create tt-cons.
                assign tt-cons.camposeq = i_seq
                       tt-cons.campocod = cadmetasfunc.codmeta
                       tt-cons.campofue = cadmetasfunc.etbcod
                       tt-cons.campofuf = cadmetasfunc.funcod.
        end.               
    end.
     
end.   
 
find first tt-cons where
           tt-cons.campoest >= 1  and
           tt-cons.campoest <= 9999
           exclusive-lock no-error.
if not avail tt-cons
then do:
        message "Nenhum estabelecimento foi informado" skip
                "favor informar!"
                view-as alert-box.
        leave.        
end.

hide frame f-pros.

end procedure.

procedure pi-msg:

     disp c_msg no-label form "x(60)"
          with frame f-msg width 80
               side-label 1 col 1 down
               row 15 col 15
               overlay no-box.

     pause 0 no-message.

end procedure.


procedure pi-calven:

    run mtsvnd1a.p (input 0).

end procedure.
