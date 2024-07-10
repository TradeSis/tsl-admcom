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
    index ch-etbcod  etbcod
    index ch-funcod  funcod.

def temp-table tt-venda     no-undo
    field etbcod     like estab.etbcod
    field venda      like plani.platot
    index ch-etbcod  is primary is unique etbcod.

def var i_seq   as inte      init 0.

run pi-consulta.

assign d_totvlrven = 0
       d_totvlrfun = 0.

find first cadmetas where 
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then do:
     for each tt-cons where
              tt-cons.campocod  = cadmetas.codmeta no-lock:
         for each plani where
                  plani.movtdc = 5                   and
                  plani.etbcod = tt-cons.campoest    and
                  plani.pladat >= t_perini           and
                  plani.pladat <= t_perfin           no-lock
                  break by plani.etbcod
                        by plani.vencod:
             for each movim where
                      movim.etbcod = plani.etbcod  and
                      movim.placod = plani.placod  no-lock:
                 find produ where
                      produ.procod = movim.procod no-lock no-error.
                 if avail produ
                 then do:
                        assign d_totvlrven = (d_totvlrven + 
                               (movim.movpc * movim.movqtm) - movim.movdes).

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
                        
                        assign d_totvlrfun = (d_totvlrfun + 
                               (movim.movpc * movim.movqtm) - movdes).
                        
                        find first tt-rel where
                                   tt-rel.etbcod = movim.etbcod  and
                                   tt-rel.funcod = plani.vencod  
                                   exclusive-lock no-error.
                        if not avail tt-rel
                        then do:
                                create tt-rel.
                                assign tt-rel.codmeta = tt-cons.campocod
                                       tt-rel.etbcod  = plani.etbcod
                                       tt-rel.funcod  = plani.vencod
                                       tt-rel.perven  = d_perven
                                       tt-rel.vlrven  = d_totvlrfun
                                       tt-rel.vlrmet  = d_vlrmet.
                                assign d_totvlrfun    = 0
                                       d_perven       = 0.       
                        end.           
                 end.
             end.
         end.
     end.         
end.
                 
hide frame f-1.

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
         break by tt-rel.etbcod
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
                       skip(1).
            end.
                 
    end. 
    
    if last-of(tt-rel.funcod)
    then do:
            if tt-rel.vlrven >= d_vlrmet
            then do:
                disp tt-rel.funcod      column-label "Funcionario"
                     c_funnom           no-label     form "x(20)"
                     ((tt-rel.vlrven / tt-venda.venda) * 100)
                     column-label "% Venda"
                     tt-rel.vlrven      column-label "Vlr Venda"
                     with down centered width 130.
            end.         
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

assign c_msg = "PROCESSANDO - 1.".
run pi-msg.

for each tt-cons:
    delete tt-cons.
end.    
    
find first cadmetas where
           cadmetas.codmeta = i_codmeta no-lock no-error.
if avail cadmetas
then do:    

    disp "Processando registros" no-label
         with side-label 1 col 1 down
              row 6 col 16
              frame f-pros.

    pause 0 no-message.

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

hide frame f-pros.

end procedure.

procedure pi-msg:

     disp c_msg no-label
          with frame f-msg width 45
               side-label 1 col 1 down
               row 15 col 15
               overlay no-box.

end procedure.
