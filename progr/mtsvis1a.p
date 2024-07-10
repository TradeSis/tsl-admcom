def input parameter r_recid as recid.

def var   i_codmeta     like cadmetas.codmeta.

find first cadmetas where
           recid(cadmetas) = r_recid no-lock no-error.
if avail cadmetas
then assign i_codmeta  = cadmetas.codmeta.

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

def var i_seq   as inte      init 0.

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

def query q_cons for tt-cons scrolling.

def browse b_cons query q_cons
   disp tt-cons.campocod   column-label "Meta"
        tt-cons.campoest   column-label "Estab"
        tt-cons.campofab   column-label "Fornec"
        tt-cons.campocat   column-label "Depto"
        tt-cons.campopro   column-label "Prod"
        tt-cons.campocla   column-label "Classe"
        tt-cons.campofue   column-label "Estab"
        tt-cons.campofuf   column-label "Func"
        with 06 down title "CONSULTA META".

def frame f-cons
    b_cons
    with side-labels at row 6 column 6
         overlay.

open query q_cons for each tt-cons where
                           tt-cons.campocod = 3 no-lock.
                           
update b_cons with frame f-cons.
                           
enable b_cons with frame f-cons.
                         
