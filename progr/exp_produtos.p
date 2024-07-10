/* exp_produtos.p        */
{admcab.i}
def var vdiretorio as char format "x(40)" init "/admcom/relat".
def var varquivo   as char format "x(40)".


def var  vdepto as char format "x(50)" extent 3
init ["31 - Gerar o csv de produtos de MOVEIS",
      "41 - Gerar o csv de produtos de MODA",
      "0  - Gerar o csv de produtos de MOVEIS e MODA"].  
      
      
display vdepto at 15 
        with no-label centered row 3 width 80
                    frame farq.
choose field vdepto with frame farq.
def var vindex as int.
vindex = frame-index.

update skip(1) vdiretorio   label "Diretorio Geracao"   colon 25
       with frame farq  side-label.
       
update varquivo     label "Nome Arquivo"     colon 25
       with frame farq side-label width 80.

def var mini_pedido as log format "Pedido Especial/Pedido Normal".
def buffer sclase   for clase.
def buffer grupo    for clase.
def buffer setclase for clase.
def buffer depto    for clase.

def var fornecedor like produ.fabcod.
def var comprador  like func.funcod.
def var vsit_subclasse as char.

output to value(vdiretorio + "/" + varquivo + ".csv").

for each produ no-lock.

    if produ.catcod <> 31 and
       produ.catcod <> 41 
    then next.    
    
    vsit_subclasse = "".
    
    if vindex = 1 and produ.catcod <> 31
    then next.
    if vindex = 2 and produ.catcod <> 41
    then next.

    fornecedor = produ.fabcod.
    comprador  = 0.
    if produ.proipival = 1
    then mini_pedido = yes.
    else mini_pedido = no.

    find sClase     where sClase.clacod   = produ.clacod    no-lock no-error.
    if not avail sClase 
    then do on error undo.  
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.        
    if vsit_subclasse = "" then do.
        find Clase where Clase.clacod    = sClase.clasup   no-lock no-error.
        if not avail clase 
        then do on error undo.
            vsit_subclasse = "ERRO SUB-CLASSE".
        end.
    end.
    if vsit_subclasse = "" then do.
        find grupo where grupo.clacod    = Clase.clasup    no-lock no-error.
        if not avail grupo 
        then do on error undo.
            vsit_subclasse = "ERRO SUB-CLASSE".
        end.
    end.
    if vsit_subclasse = "" then do.
        find setClase where setClase.clacod = grupo.clasup no-lock no-error.  
        if not avail setclase 
        then do on error undo.
            vsit_subclasse = "ERRO SUB-CLASSE".
        end.
    end.
    if vsit_subclasse = "" then do.
        find depto where depto.clacod = setclase.clasup no-lock no-error.   
        if not avail depto 
        then do on error undo.
            vsit_subclasse = "ERRO SUB-CLASSE".
        end.        
    end.
        
    if avail setClase and setClase.clacod = 0 
    then do on error undo.
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.
    if avail grupo and grupo.clacod = 0 
    then do on error undo.
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.
    if avail depto and depto.clacod = 0 
    then do on error undo.
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.
    if avail clase and Clase.clacod = 0 
    then do on error undo.
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.
    if avail sclase and sClase.clacod = 0 
    then do on error undo.
        vsit_subclasse = "ERRO SUB-CLASSE".
    end.

    find fabri of produ no-lock no-error.
    
    find last liped where liped.procod = produ.procod   and 
                          liped.pedtdc = 1              
                          use-index liped2 no-lock no-error.
    if avail liped
    then do.
        find pedid of liped no-lock no-error.
        if avail pedid
        then assign fornecedor = pedid.clfcod
                    comprador  = pedid.comcod.
    end.

put unformatted 
    produ.procod            ";"       
    produ.pronom            ";"
   (if avail setClase
    then setClase.clacod
    else 0)                 ";"
   (if avail setClase
    then setClase.clanom
    else "")                ";"
   (if avail grupo
    then grupo.clacod
    else 0)                 ";"
   (if avail grupo
    then grupo.clanom
    else "")                ";"
   (if avail clase
    then clase.clacod
    else 0)                 ";"
   (if avail clase
    then clase.clanom 
    else "")                ";"
   (if avail sclase
    then sclase.clacod
    else "")                ";"
   (if avail sclase
    then sclase.clanom
    else "")                ";"
    fornecedor              ";"
    comprador               ";"
   (if mini_pedido
    then "Pedido Especial"
    else "Pedido Normal")   ";"  
    produ.fabcod            ";" 
   (if avail fabri
    then fabri.fabfan
    else "")                ";"
    vsit_subclasse            
    skip. 


end.

output close.

message "Arquivo " vdiretorio + "/" + varquivo + ".csv" " gerado"
        view-as alert-box.
