{admcab.i }

def input parameter p-procod                as integer.
def input parameter p-tipo-atrib            as char.

def var esqcom1         as char format "x(16)" extent 3
    initial [" Inclusao "," Alteracao "," Exclusao "].

def buffer buf9-produ for produ.

def var vtitulo-aux                         as char.

def temp-table tt-prodatrib like prodatrib
    field pronom   like produ.pronom
    field atribdes like atributo.atribdes
    field acao     as char.

find first buf9-produ where buf9-produ.procod = p-procod 
                               no-lock no-error.

for each prodatrib where prodatrib.procod = p-procod no-lock,

    first atributo where atributo.atribcod = prodatrib.atribcod
                     and atributo.tipo = p-tipo-atrib no-lock.
                     
    find first tt-prodatrib where tt-prodatrib.atribcod = prodatrib.atribcod
                              and tt-prodatrib.procod = prodatrib.procod
                                        no-lock no-error.
                                        
    if not avail tt-prodatrib
    then do:
    
       create tt-prodatrib.
        buffer-copy prodatrib to tt-prodatrib.
    
        assign tt-prodatrib.atribdes = atributo.atribdes
               tt-prodatrib.pronom   = buf9-produ.pronom.

    end.
                     
end.                     

/*
if vatrib-cod > 0
then do:
                
    find first atributo
         where atributo.atribcod = vatrib-cod
           and atributo.tipo = "capacidade" no-lock no-error.
                    
    if avail atributo
    then display atributo.atribdes no-label.

    update vatrib-val.
                    
    if vatrib-val > 0
    then do:
                    
        find first prodatrib
             where prodatrib.procod = dprodu.procod
               and can-find (first atributo
                             where atributo.atribcod = prodatrib.atribcod
                               and atributo.tipo = "capacidade")
                                       exclusive-lock no-error.
                                            
        if not avail prodatrib
        then do:
                      
            create prodatrib.
            assign prodatrib.atribcod = vatrib-cod
                   prodatrib.procod = dprodu.procod.
                     
        end.
                    
        assign prodatrib.atribcod = vatrib-cod
               prodatrib.valor = vatrib-val.

    end.
                
end.    
                else display vatrib-val  at 42 label "Atrib Valor".
                

*/


assign vtitulo-aux = trim(p-tipo-atrib)
                        + " do produto "
                        + trim(buf9-produ.pronom).

bl-princ:
repeat:

    if can-find (first tt-prodatrib)
    then 
    for each tt-prodatrib no-lock.

        display tt-prodatrib.

    end.
    
    else do:
        display skip(2)
                 "( Nenhum Atributo Cadatrado para o produto. )"
                 skip(2)
                with frame f02 title vtitulo-aux overlay .
                
        pause 0.
                                                      
        display "I=Incluir"         with frame f-rodape2
                    row screen-lines  centered overlay.
               
        choose field esqcom1 with frame f-rodape2.                                                        
                                                      
    end.                
                

    pause.

    if keyfunction(lastkey) = "i"
        or keyfunction(lastkey) = "I"
    then do:

        create tt-prodatrib.
    
        update tt-prodatrib.atribcod 
                with frame f01 title vtitulo-aux.


        find first prodatrib where prodatrib.atribcod = tt-prodatrib.atribcod
                               and prodatrib.procod = tt-prodatrib.procod
                                                no-lock no-error.
                                            
        if not avail prodatrib
        then do:
                                                
            create prodatrib.
            buffer-copy tt-prodatrib to prodatrib.
              
        end.                                        
    
    end.


    if keyfunction(lastkey) = "end-error"
            then undo, return .
            
    if keyfunction(lastkey) = "return"
                        then leave bl-princ .

end.
