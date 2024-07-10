{admcab.i}

def input parameter p-sequencia as int.

form vetbcod like estab.etbcod at 5 label "Filial"
     estab.etbnom no-label
     /*
     vdti as date at 1 label "Periodo de" format "99/99/9999"
     vdtf as date label "Ate" format "99/99/9999"
     vcatcod as int at 6 label "Setor"
     categoria.catnom no-label
     */
     with frame f1 width 80 side-label.

{selestab.i vetbcod f1}

/**
update vdti vdtf with frame f1.
if vdtf = ? or vdtf = ? or
vdti > vdtf
then undo.
vcatcod = 31.
disp vcatcod with frame f1.
find categoria where categoria.catcod = vcatcod no-lock.
disp categoria.catnom with frame f1.
**/

def var vetqest as log format "Sim/Nao".
def var vdirarq as char format "x(40)".
def var vmix    as log format "Sim/Nao".
if opsys = "UNIX"
then vdirarq = "/admcom/relat/".
else vdirarq = "l:~\relat~\".
do on error undo:
    update vdirarq label "Local para gerar os arquivos "
           vetqest label "Qtd. Etiqueta  = Qtd Estoque?" 
           vmix    label "Mix Loja"
        with frame f1 1 down width 80 side-label
        .
    if vdirarq = ""
    then undo.
end.

def temp-table tt-preco
    field etbcod like estab.etbcod
    field procod like produ.procod
    field preco as dec
    field plano as int
    field parcela as dec
    index i1 etbcod procod.
    
def var vpromo as dec.
def var vvenda as dec.
def var vdata as date.
def var vfincod like finan.fincod.
def var vliqui as dec.
def var vparce as dec.
def var ventra as dec.
def buffer bclase for clase.
def buffer cclase for clase.
def buffer dclase for clase.
def buffer btabmix for tabmix.

for each ctpromoc where
         ctpromoc.sequencia = p-sequencia and
         ctpromoc.linha > 0 and
         ctpromoc.procod <> 0
         no-lock:
    
    find produ where produ.procod = ctpromoc.procod
                no-lock no-error.
    if not avail produ then next.
                
    vfincod = 87.

    find clase where clase.clacod = produ.clacod no-lock no-error.
    if not avail clase then next.
    if clase.clasup <> 90
    then do:
        find bclase where 
                 bclase.clacod = clase.clasup no-lock  no-error.
        if bclase.clasup <> 90
        then do:
            find cclase where 
                     cclase.clacod = bclase.clasup no-lock  no-error.
            if cclase.clasup <> 90
            then.
            else vfincod = 88. 
        end.
        else vfincod = 88.     
    end.
    else vfincod = 88.

    for each tt-lj:
        find estab where estab.etbcod = tt-lj.etbcod and
                        estab.etbnom begins "DREBES-FIL"
                        NO-LOCK NO-ERROR.
        if not avail estab then next. 
        assign
            vliqui = 0
            ventra = 0
            vparce = 0
            vdata = today
            vpromo = ctpromoc.precosugerido.

        find finan where finan.fincod = vfincod no-lock.
        run gercpg1.p( input finan.fincod,
                       input vpromo,
                       input 0,
                       input 0,
                       output vliqui,
                       output ventra,
                       output vparce).
            
        find first tt-preco where tt-preco.etbcod = estab.etbcod and
                                  tt-preco.procod = produ.procod
                                  no-error.
        if not avail tt-preco
        then do:
                create tt-preco.
                assign
                    tt-preco.etbcod = estab.etbcod
                    tt-preco.procod = produ.procod
                    tt-preco.preco  = vpromo
                    tt-preco.parcela = vparce
                    tt-preco.plano = vfincod
                    .
        end.        
    end.
end.

def var vqtd as int.
def var vi as int.
def var varquivo as char.
def var vpag as int.
def var vpro as int.
for each tt-lj no-lock:
    find first tt-preco where tt-preco.etbcod = tt-lj.etbcod
                no-error.
    if not avail tt-preco then next.

    vpag = 0.      
    vpro = 0.      
    
    for each tt-preco where
             tt-preco.etbcod = tt-lj.etbcod use-index i1:
        
        vqtd = 0.
        
        if vetqest = no
        then vqtd = 1.
        else do:
            find estoq where estoq.etbcod = tt-preco.etbcod and
                             estoq.procod = tt-preco.procod
                             no-lock no-error.
            if avail estoq and
               estoq.estatual > 0
            then vqtd = estoq.estatual.
            else vqtd = 1.                 
        end.
        do vi = 1 to vqtd:
        if vpro = 0
        then do:
            vpag = vpag + 1.
            if opsys = "UNIX"
            then varquivo = vdirarq + string(tt-lj.etbcod,"999") 
                            + "_" + string(vpag) + ".txt" .
            else varquivo = "l:~\relat~\" + string(tt-lj.etbcod,"999") 
                        + "_" + string(vpag) + ".txt" .
      
        end.

        /*************************38501**********************/

        if vmix
        then do:
            release btabmix.
            find first btabmix where btabmix.tipomix = "M"
                                 and btabmix.etbcod = tt-preco.etbcod
                                        no-lock no-error.
                                                        
            if not avail btabmix
            then next.

            release tabmix.
            find first tabmix where tabmix.codmix = btabmix.codmix 
                                and tabmix.promix = tt-preco.procod
                                and tabmix.tipomix = "P"
                                    no-lock no-error.

            if not avail tabmix then next.
        
        end.
        
        /****************************************************/


        output to value(varquivo) append.
            put  tt-preco.etbcod format "999"   ";"
                 vpag format ">>>9" ";"
                 tt-preco.procod format ">>>>>>99" ";"
                 tt-preco.plano format ">>>9" ";"
                 tt-preco.parcela format ">>,>>9.99" ";"
                 tt-preco.preco   format ">>,>>9.99"
                 skip.
        output close.
        vpro = vpro + 1.
        if vpro = 10
        then vpro = 0.
        end.
    end. 
end.

message color red/with
    "Arquivos para etiquetas gerados em " vdirarq
    view-as alert-box.
    
hide frame f1 no-pause.
