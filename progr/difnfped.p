{admcab.i}

def input parameter vrec as recid.
def var vped as recid.

def shared workfile  wfped
    field rec       as rec.

def temp-table tt-difped
    field tipo as char
    field procod like produ.procod
    field pedido as dec
    field nota   as dec.

def shared temp-table w-movim 
    field wrec    as   recid 
    field codfis    like clafis.codfis 
    field sittri    like clafis.sittri
    field movqtm    like movim.movqtm 
    field movacfin  like movim.movacfin
    field subtotal  like movim.movpc format ">>>,>>9.99" column-label "Subtot" 
    field movpc     like movim.movpc format ">,>>9.99" 
    field movalicms like movim.movalicms initial 17 
    field valicms   like movim.movicms
    field movicms   like movim.movicms
    field movicms2  like movim.movicms
    field movalipi  like movim.movalipi 
    field movipi    like movim.movipi
    field movfre    like movim.movpc 
    field movdes    as dec format ">,>>9.9999"
    field valdes    as dec format ">,>>9.9999".
  
def var vpedval as dec.
def var vpedqtd as dec.
def var vdif as dec.
def var vpct as dec.

def var vpedidos as char init 0.

form     tt-difped.tipo       no-label  format "x(12)"
         tt-difped.procod     column-label "Codigo"       
         produ.pronom          column-label "Produto"  format "x(30)"
         tt-difped.pedido     column-label "Pedido"  format ">,>>>,>>9.99"
         tt-difped.nota       column-label "Nota"    format ">,>>>,>>9.99"
         with frame f-difqtd row 6
         9 down title " Divergencias Pedidos X Nota "
         width 80 overlay
         .

form     tt-difped.tipo       no-label  format "x(12)"
         tt-difped.procod     column-label "Codigo"       
         produ.pronom          column-label "Produto"  format "x(30)"
         tt-difped.pedido     column-label "Pedido"  format ">,>>>,>>9.99"
         tt-difped.nota       column-label "Nota"    format ">,>>>,>>9.99"
         with frame f-difqtd1
         down 
         width 80
         .


l1: repeat:

for each tt-difped:
    delete tt-difped.
end.    
for each w-movim:
    
        find produ where recid(produ) = w-movim.wrec no-lock no-error.
        if not avail produ
        then next.
        assign
            vpedval = 0
            vpedqtd = 0.
        for each wfped:
            find pedid where recid(pedid) = wfped.rec no-error.
            if avail pedid
            then do:
                find first liped where liped.pedtdc = pedid.pedtdc and
                                       liped.etbcod = pedid.etbcod and
                                       liped.procod = produ.procod and
                                       liped.pednum = pedid.pednum no-error.
                if avail liped
                then do:
                    if liped.lippreco <> w-movim.movpc
                    then vpedval = liped.lippreco.
                    vpedqtd = vpedqtd + (liped.lipqtd - liped.lipent).
                end.
            end.
        end.
        if w-movim.movpc <> vpedval
        then do:
            if w-movim.movpc > vpedval
            then do:
                vdif = w-movim.movpc - vpedval.
                vpct = (vdif / w-movim.movpc) * 100.
            end.
            else do:
                vdif = vpedval - w-movim.movpc .
                vpct = (vdif / vpedval) * 100.
            end.

            if vpct > 1
            then do:
                create tt-difped.
                assign
                    tt-difped.tipo   = "VALOR"
                    tt-difped.procod = produ.procod
                    tt-difped.pedido = vpedval
                    tt-difped.nota   = w-movim.movpc
                    .
            end.
        end.
        if w-movim.movqtm <> vpedqtd
        then do:
            create tt-difped.
            assign
                tt-difped.tipo   = "QUANTIDADE"
                tt-difped.procod = produ.procod
                tt-difped.pedido = vpedqtd
                tt-difped.nota   = w-movim.movqtm
                .
 
        end.  

end.

vpedidos = "".
for each wfped:
    find pedid where recid(pedid) = wfped.rec no-error.
    if avail pedid
    then do:
        vpedidos = vpedidos + "," + string(pedid.pednum).
    end.
end. 
form     tt-difped.tipo       no-label  format "x(12)"
         tt-difped.procod     column-label "Codigo"       
         produ.pronom          column-label "Produto"  format "x(30)"
         tt-difped.pedido     column-label "Pedido"  format ">,>>>,>>9.99"
         tt-difped.nota       column-label "Nota"    format ">,>>>,>>9.99"
         with frame f-difqtd row 6
         9 down title " Divergencias Pedidos X Nota "
         width 80 overlay
         .

form     tt-difped.tipo       no-label  format "x(12)"
         tt-difped.procod     column-label "Codigo"       
         produ.pronom          column-label "Produto"  format "x(30)"
         tt-difped.pedido     column-label "Pedido"  format ">,>>>,>>9.99"
         tt-difped.nota       column-label "Nota"    format ">,>>>,>>9.99"
         with frame f-difqtd1
         down 
         width 80
         .

disp vpedidos label "Pedidos" format "x(70)"
    with frame f-disped 1 down no-box side-label
    width 80 row 20.
{setbrw.i}
a-seeid = -1. a-recid = -1. a-seerec = ?.
{sklcls.i
    &help = "F1=Imprime F8=Continua F9=Pedidos"
    &file = tt-difped
    &cfield = tt-difped.procod
    &noncharacter = /*
    &ofield = " tt-difped.tipo
                produ.pronom when avail produ
                tt-difped.pedido
                tt-difped.nota              "
    &aftfnd1 = " find produ where 
                        produ.procod = tt-difped.procod 
                        no-lock no-error.
               "
    &where = " true "
    &naoexiste1 = " leave keys-loop. "
    &form  = " frame f-difqtd "
}                                    

if keyfunction(lastkey) = "clear"
then do:
    hide frame f-disped no-pause.
    hide frame f-difqtd no-pause.
    leave l1.
end.

if keyfunction(lastkey) = "NEW-LINE" OR
   KEYFUNCTION(LASTKEY) = "INSERT-MODE"
then do on error undo, retry:
    hide frame f-disped no-pause.
    run nffped.p (input vrec,
                  output vped).
    if vped = ?
    then do:
        message "Para continuar selecione pelo menos um pedido.".
        undo.
    end.  
end.   
if keyfunction(lastkey) = "GO"
then do:
    def var varquivo as char.
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/difnfped" + string(time).
    else varquivo = "l:\relat\difnfped" + string(time).
    
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "0"
        &Cond-Var  = "100"
        &Page-Line = "0"
        &Nom-Rel   = ""difnfped""
        &Nom-Sis   = """SISTEMA DE COMPRAS"""
        &Tit-Rel   = """ DIVERGENCIAS NOTA X PEDIDOS """
        &Width     = "100"
        &Form      = "frame f-cabcab"}

    disp vpedidos label "Pedidos" format "x(70)"
    with frame f-disped1 1 down no-box side-label
    width 80 .

    for each tt-difped:
        find produ where produ.procod = tt-difped.procod no-lock no-error.
        disp tt-difped.tipo
             tt-difped.procod
             produ.pronom when avail produ
             tt-difped.pedido
             tt-difped.nota
             with frame f-difqtd1. 
        down with frame f-difqtd1.     
    end.
    output close.
        
    if opsys = "UNIX"
    then do:
        run visurel.p (input varquivo, input "").
    end.
    else do:
        {mrod.i}.
    end.
     
end.
end.
