/* */
def button btn-inc label "INCLUI".  
def button btn-exc label "EXCLUI".  
def button btn-sai label "SAIR".
def button btn-tod label "TODOS".
def button btn-atu label "ATUALIZA".

def query qbrowse for tt-browse
    fields(tt-browse.marca tt-browse.procod tt-browse.pronom).

def browse bbrowse query qbrowse no-lock
    display tt-browse.marca  
            tt-browse.procod
            tt-browse.pronom
    enable  tt-browse.marca 
    with width 25 3 down no-row-markers.

def var iprocod  like produ.procod.

def frame f-browse
    iprocod label "Produto "
    skip
    bbrowse                                          at 25
    btn-inc                                          at 01
    btn-exc                                          at 20
    btn-tod                                          at 36
    "[F5 DELETE LINHA]"                              at 45
    btn-sai                                          at 68 
    with side-labels width 80 col 1 row 10. 

&scoped-define frame-name f-browse
&scoped-define open-query open query qbrowse for each tt-browse no-lock
&scoped-define list-1 btn-inc btn-exc btn-tod btn-sai 

/* ------------------------------------------------------------------------ */

assign iprocod:visible = no. 

on choose of btn-inc in frame {&frame-name} /* Insert */
do:
     assign iprocod = 0.
     assign iprocod:visible = yes. 
     update iprocod with frame f-browse.
     if iprocod = 0
     then do:
             leave.
     end.        
     find first produ where
                produ.procod = iprocod no-lock no-error.
     if not avail produ
     then do:
             message "Produto nao encontrado!"
                     view-as alert-box.
             undo, retry.
     end.   
         create tt-browse.
         assign tt-browse.procod = iprocod
                tt-browse.pronom = produ.pronom
                tt-browse.marca  = "*".
         open query qbrowse for each tt-browse.
         disp bbrowse with frame f-browse.
         assign iprocod:visible = no.

end. 

on F5 of bbrowse /* Delete */
do:
           find current tt-browse  exclusive-lock no-error.
           if avail tt-browse
           then do:
                   delete tt-browse.
                   open query qbrowse for each tt-browse.
                   enable bbrowse 
                          {&list-1} with frame {&frame-name}.
                   apply "entry" to browse bbrowse.

           end.  
 end.

on choose of btn-tod in frame {&frame-name} /* Todos */
do:
   for each produ no-lock:
       find first estoq where
                  estoq.etbcod = vetbcod no-lock no-error.
       if not avail estoq
       then next.              
       find first tt-browse where
                  tt-browse.procod = produ.procod exclusive-lock no-error.
      if not avail tt-browse
      then do:           
              create tt-browse.
              assign tt-browse.marca = "*"
                     tt-browse.procod = produ.procod
                     tt-browse.pronom = produ.pronom.
              open query qbrowse for each tt-browse.
              assign iprocod:visible = no.
      end.
   end.
end.

on choose of btn-sai in frame {&frame-name} /* Sair */
do:
     apply "window-close" to current-window.
end.

/* ------------- MAIN ------------------------------------------------------- */
     
{&open-query}.

assign iprocod:visible = no.
  
enable bbrowse 
       {&list-1} with frame {&frame-name}.
apply "value-changed" to browse bbrowse.

/* wait-for window-close of current-window. */
