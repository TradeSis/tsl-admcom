/* */
def new shared temp-table tt-browse
    field marca  as    char form "x(1)" column-label "Marca"
    field etbcod like estab.etbcod      column-label "Estabelecimento"
    index ch-etbcod   etbcod.

def query qbrowse for tt-browse
    fields(tt-browse.marca tt-browse.etbcod).

def browse bbrowse query qbrowse no-lock
    display tt-browse.marca  
            tt-browse.etbcod 
    enable  tt-browse.marca 
    with width 25 3 down no-row-markers.

def var ietbcod  like estab.etbcod.

def frame f-browse
    ietbcod label "Estabelecimento "
    skip
    bbrowse                                          at 25
    "<Insert - Inclui>"                              at 01
    "<F11 - Exclui>"                                 at 20
    "<F12 - Todos>"                                  at 36
    "<F1 - Atualiza>"                                at 51
    "<F4 - Sair>"                                    at 68 
    with side-labels width 80 col 1 row 10. 

           repeat on endkey undo, leave with frame f-browse: 
               
               assign ietbcod:visible = no. 
               
               if  keyfunction(lastkey) = "copy"
               then do:
                       status input "Selecione tecle barra de espaco para apaga~~r e <F1>".                         update bbrowse with frame f-browse.
                       for each tt-browse where
                                tt-browse.marca = "":
                                 delete tt-browse.
                       end.
                       open query qbrowse for each tt-browse.
                       disp bbrowse with frame f-browse.
               end.
               if  keyfunction(lastkey) = "insert-mode"
               then do:
                        assign ietbcod = 0.
                        assign ietbcod:visible = yes. 
                        update ietbcod with frame f-browse.
                        if ietbcod = 0
                        then do:
                                leave.
                        end.        
                        find first estab where
                                   estab.etbcod = ietbcod no-lock no-error.
                        if not avail estab
                        then do:
                                message "Estabelecimento nao encontrado!"
                                        view-as alert-box.
                                undo, retry.
                        end.   
                        create tt-browse.
                        assign tt-browse.etbcod = ietbcod
                               tt-browse.marca  = "*".
                        open query qbrowse for each tt-browse.
                        disp bbrowse with frame f-browse.
                        assign ietbcod:visible = no.
               end.
               if keyfunction(lastkey) = "end-error"
               then leave.
               if keyfunction(lastkey) = "paste"
               then do:
                       for each estab no-lock:
                           find first tt-browse where
                                      tt-browse.etbcod = estab.etbcod
                                      exclusive-lock no-error.
                           if not avail tt-browse
                           then do:           
                                   create tt-browse.
                                   assign tt-browse.marca = "*"
                                          tt-browse.etbcod = estab.etbcod.
                                   open query qbrowse for each tt-browse.
                                   assign ietbcod:visible = no.
                           end.
                       end.
                       update bbrowse with frame f-browse.
               end.
               disp bbrowse with frame f-browse.
            
            end.
    hide frame f-browse.
 