{admcab.i}

def input parameter padrao-origem as int.
def input parameter p-clasup like clase.clacod.
def input parameter p-clacod like clase.clacod.

def var padrao-destino as int.

def temp-table tt-tabmix like tabmix.

def shared temp-table tt-produ 
    field procod like produ.procod .
 
def buffer b-tabmix for tabmix.
def buffer c-tabmix for tabmix.
def buffer d-tabmix for tabmix.
def var s-p as log format "Sim/Nao".
def var s-c as log format "Sim/Nao".
form padrao-origem  at 2 format ">>9" label "Padrao Origem"
     tabmix.descmix no-label
     padrao-destino at 1 format ">>9" label "Padrao Destino"
     b-tabmix.descmix no-label
     with frame f-cp 1 down centered side-label
     .


do on error undo, retry:
    disp padrao-origem with frame f-cp.
    find tabmix where tabmix.tipomix = "M" and
                      tabmix.codmix  = padrao-origem
                      no-lock no-error.
    if not avail tabmix
    then do:
        message color red/with
            "Padrao origem " padrao-origem " nao encontrado."
            view-as alert-box.
        undo.
    end.
    disp tabmix.descmix with frame f-cp. 
    find FIRST d-tabmix where d-tabmix.tipomix = "P" and
                      d-tabmix.codmix  = padrao-origem
                      no-lock no-error.
    if not avail d-tabmix
    then do:
        find FIRST d-tabmix where d-tabmix.tipomix = "C" and
                      d-tabmix.codmix  = padrao-origem
                      no-lock no-error.
        if not avail d-tabmix
        then do:
            message color red/with
                "Padrao origem" padrao-origem 
                " nao possui informacao de produtos ou classes."
                view-as alert-box.
            undo.
        end.
    end.
       
    
    do on error undo, retry:
        update padrao-destino with frame f-cp.
        find b-tabmix where b-tabmix.tipomix = "M" and
                      b-tabmix.codmix  = padrao-destino
                      no-lock no-error.
        if not avail b-tabmix
        then do:
            message color red/with
                "Padrao destino" padrao-destino " nao encontrado."
                view-as alert-box.
            undo.
        end.
        disp b-tabmix.descmix with frame f-cp.  
        s-p = no.
        find FIRST c-tabmix where c-tabmix.tipomix = "P" and
                      c-tabmix.codmix  = padrao-destino
                      no-lock no-error.
        if avail c-tabmix
        then do:
            message color red/with
                "Padrao destino" padrao-destino 
                " possui informacao de produtos." .
            message "Deseja sobscrever ? " update s-p.
        end.
        s-c = no.
        find FIRST c-tabmix where c-tabmix.tipomix = "C" and
                      c-tabmix.codmix  = padrao-destino
                      no-lock no-error.
        if avail c-tabmix
        then do:
            message color red/with
                "Padrao destino" padrao-destino 
                " possui informacao de classes.".
            message "Deseja sobscrever ? " update s-c.
        end.
    end.
end.

if padrao-origem > 0 and
   padrao-destino > 0
then.
else return.
   
sresp = no.
message "Confirma copiar produtos do MIX ?" update sresp. 
if sresp 
then.
else return.

def var vsobscrever as log.


def buffer p-tabmix for tabmix.

disp "Copiando... AGUARDE! " 
    with frame f-disp 1 down centered no-label no-box 
    row 10.

def buffer iclasse for clase.
if s-p = yes
then do:
    for each p-tabmix where p-tabmix.tipomix = "P" and
                        p-tabmix.codmix  = padrao-destino
                        .
        /*
        find first tt-produ where
               tt-produ.procod = p-tabmix.promix
               no-lock no-error.
        if avail tt-produ
        then do:
            delete p-tabmix.  
        end.
        else do: */
            find produ where produ.procod = p-tabmix.promix no-lock no-error.
            if avail produ
            then do:
                find clase where clase.clacod = produ.clacod no-lock no-error.
                if avail clase
                then do:
                    if p-clacod > 0
                    then do:
                        if clase.clacod = p-clacod
                        then delete p-tabmix.
                    end.           
                    else do:
                        if clase.clasup = p-clasup
                        then delete p-tabmix. 
                    end.
                end.
            /*end.*/
        end.             
    end.
end.
for each c-tabmix where
         c-tabmix.tipomix = "P" and
         c-tabmix.codmix  = padrao-origem 
         no-lock:
    find first tt-produ where
               tt-produ.procod = c-tabmix.promix
               no-lock no-error.
    if not avail tt-produ
    then next.           
    disp c-tabmix.promix with frame f-disp.
    pause 0.  
    find p-tabmix where p-tabmix.tipomix = c-tabmix.tipomix and
                        p-tabmix.codmix  = padrao-destino and
                        p-tabmix.etbcod  = c-tabmix.etbcod and
                        p-tabmix.promix  = c-tabmix.promix
                        no-lock no-error.
    if not avail p-tabmix or s-p = yes
    then do:
        create tt-tabmix.
        buffer-copy c-tabmix to tt-tabmix.
    end.
end.         
if s-c = yes
then do:
    for each p-tabmix where p-tabmix.tipomix = "C" and
                        p-tabmix.codmix  = padrao-destino 
                        :
        delete p-tabmix.
    end. 
end.    
for each c-tabmix where
         c-tabmix.tipomix = "C" and
         c-tabmix.codmix  = padrao-origem 
         no-lock:
    disp c-tabmix.promix with frame f-disp.
    pause 0. 
    find p-tabmix where p-tabmix.tipomix = c-tabmix.tipomix and
                        p-tabmix.codmix  = padrao-destino and
                        p-tabmix.etbcod  = c-tabmix.etbcod and
                        p-tabmix.promix  = c-tabmix.promix
                        no-lock no-error.
    if not avail p-tabmix or s-c = yes
    then do:
        create tt-tabmix.
        buffer-copy c-tabmix to tt-tabmix.
    end.
end. 
for each tt-tabmix where tt-tabmix.promix > 0.
    
    tt-tabmix.codmix = padrao-destino.
    find d-tabmix where d-tabmix.tipomix = tt-tabmix.tipomix and
                        d-tabmix.codmix  = padrao-destino and
                        d-tabmix.etbcod  = tt-tabmix.etbcod and
                        d-tabmix.promix  = tt-tabmix.promix
                        no-error.
    if not avail d-tabmix
    then create d-tabmix.
    
    buffer-copy tt-tabmix to d-tabmix.
    
    delete tt-tabmix.
    
    disp d-tabmix.promix with frame f-disp.
    pause 0. 
end.

message color red/with      SKIP
    "      COPIA FINALIZADA      " SKIP
        VIEW-AS ALERT-BOX.
        
        
