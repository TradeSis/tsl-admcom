/* alcis_pedordvh.p   */
{admcab.i}
setbcod = 900.
if setbcod <> 900 then leave.

def new shared var vALCIS-ARQ-ORDVH   as int.

def var vprocod like produ.procod.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata like pedid.peddat.

def var vsetbcod like setbcod.

def buffer bpedid for pedid.
def buffer qliped for liped.
def temp-table tt-pedid like pedid.
def temp-table tt-liped like liped.

def new shared temp-table atu-pedid         like com.pedid.
def new shared temp-table atu-liped         like com.liped.
def new shared var qtd-mix as dec.
def new shared var tem-mix as log.
def new shared var pro-mix as log.

def var vlipcor like liped.lipcor format "x(5)".
def var vlipqtd like liped.lipqtd format ">>>>9".

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".
def var v-status        as char.

def var vmovqtm as dec.
def var val-conjunto as dec.


/*def var vsenha as char format "x(10)".*/
/*def var fun-senha as char.*/
/*
find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
if avail func
then fun-senha = func.senha.

update vsenha blank label "Senha"
       with frame f-senha centered side-labels. 
hide frame f-senha no-pause.

if vsenha = fun-senha   or
   vsenha = "1360" 
then.
else do:
    message color red/with
    "Informe a senha corretamente"
    view-as alert-box.
    return.
end.    

*/

repeat:

    for each tt-liped.
        delete tt-liped.
    end.
    
    for each tt-pedid.
        delete tt-pedid.
    end.
    
    vetbcod = 0.
    vdata   = today.
    update vetbcod colon 18 with frame f1 side-label row 4
                centered color white/red.
    find estab where estab.etbcod = vetbcod no-lock.
    display estab.etbnom no-label skip with frame f1.
    update vdata colon 18 skip with frame f1.
    
    find last pedid where
              pedid.pedtdc = 95 and
              pedid.etbcod = vetbcod  and
              pedid.pednum < 100000 no-lock no-error.
    
    if avail pedid
    then vpednum = pedid.pednum + 1.
    else vpednum = 1.
    
    create tt-pedid.
    assign tt-pedid.pedtdc    = 95 
           tt-pedid.pednum    = vpednum 
           tt-pedid.regcod    = estab.regcod 
           tt-pedid.peddat    = vdata 
           tt-pedid.pedsit    = yes 
           tt-pedid.sitped    = "E" 
           tt-pedid.modcod    = "PEDC" 
           tt-pedid.etbcod    = vetbcod.
    
    display tt-pedid.pednum colon 18 with frame f1.
    repeat:

        vlipcor = "".
        vlipqtd = 0.
        
        update vprocod   column-label "Codigo"
            with no-validate frame f2.
        find produ where produ.procod = vprocod no-lock no-error.
        if not avail produ
        then do:
            message "produto nao cadastrado.".
            pause. 
            undo.
        end.
        find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                                  and tt-liped.pedtdc = tt-pedid.pedtdc 
                                  and tt-liped.pednum = tt-pedid.pednum 
                                  and tt-liped.procod = produ.procod no-error.
         if avail tt-liped
         then do:
            message "Produto ja incluido.".
            pause.
            undo.
         end.
         /***
         {tbcntgen6.i today}
         if avail tbcntgen
         then do:
            bell.
            message color red/with
                "Produto bloqueado para distribuicao."
                view-as alert-box.
            undo.    
         end.
         ***/
        def buffer loj-estoq   for estoq.
        def buffer dep-estoq   for estoq.
        find loj-estoq where loj-estoq.procod = produ.procod and
                        loj-estoq.etbcod = vetbcod no-lock.
        find dep-estoq where dep-estoq.procod = produ.procod and
                             dep-estoq.etbcod = setbcod no-lock.
        def var par-bloq as dec.
        def var vestatual995  like estoq.estatual format "->>>>9".
        def var vdisponiv995  like estoq.estatual format "->>>>9".
        vestatual995 = dep-estoq.estatual.
        /*run bloq995.p (input  produ.procod,
                       output par-bloq ).  */
        run bloq900.p (input  produ.procod,
                       output par-bloq ). 
 
        vdisponiv995 = vestatual995 - par-bloq.
        if vdisponiv995 < 0 then vdisponiv995 = 0.        
        def var vqtdsug as int.
        sretorno = "".
        vsetbcod = setbcod.
        setbcod = vetbcod.
        run vercobertura.p(input produ.procod,
                           input 0,
                           output sresp,
                           output vqtdsug,
                           output vmovqtm,
                           output val-conjunto).
        setbcod = vsetbcod.
        /***
        if (vqtdsug = 1 and
           sresp = no) or
           vqtdsug = 0
        then do:
            find last qliped   where 
                      qliped.pedtdc = 95 and 
                      qliped.etbcod = vetbcod and 
                      qliped.procod = produ.procod and
                      qliped.pednum < 100000
                      no-lock no-error.
            if avail qliped and
                      qliped.predt >= vdata
            then do:
                message color red/with
                    "Produto " produ.procod produ.pronom skip
                    "ja possui pedido na data " today
                    view-as alert-box.
                next.    
            end.          
        end.
        ***/
        display produ.pronom format "x(30)" 
                loj-estoq.estatual format "->>9" column-label "Est!Loja"
                dep-estoq.estatual format "->>9" column-label "Est!Depo"
                vdisponiv995       format "->>9" column-label "Dispo"
                int(sretorno) format ">>9" column-label "Cob."
                vmovqtm format ">>9" column-label "Venda!30dias"
        with frame f2.
        vqtdsug = 1.
        do on error undo:
            vlipqtd = vqtdsug.
            update vlipqtd column-label "Qtd"
                with frame f2 down centered color blank/cyan.
            if  vlipqtd = 0 or
                vdisponiv995 < vlipqtd
            then do:
                message color red/with
                    "Quantidade nao permitida. Disponivel = " vdisponiv995
                    view-as alert-box.
                undo.    
            end.
            else if val-conjunto > 0
            then do:
                message color red/with 
                    " PRODUTO DE CONJUNTO " SKIP(1)
                   /* " Quntidade pedida " vlipqtd "sera enviada." */
                    view-as alert-box title "".
            end.
        end.         
        /**
        if produ.procod = 406723 or
           produ.procod = 406724
        then do: 
            if vlipqtd > 1 
            then do:
                message "Quantidade Maxima do Produto excedida. ".
                undo.
            end.

            find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                                  and tt-liped.pedtdc = tt-pedid.pedtdc 
                                  and tt-liped.pednum = tt-pedid.pednum 
                                  and tt-liped.procod = produ.procod no-error.
            if avail tt-liped
            then do:
                if tt-liped.lipqtd >= 1
                then do:
                    message "Quantidade Maxima do Produto excedida.".
                    undo.
                end.
            end.
        end.
        ***/
        update vlipcor column-label "Cor" with frame f2.
        
        find tt-liped where tt-liped.etbcod = tt-pedid.etbcod and
                            tt-liped.pedtdc = tt-pedid.pedtdc and
                            tt-liped.pednum = tt-pedid.pednum and
                            tt-liped.procod = produ.procod    and
                            tt-liped.lipcor = vlipcor         and
                            tt-liped.predt  = tt-pedid.peddat no-error.
        if avail tt-liped
        then tt-liped.lipqtd = tt-liped.lipqtd + vlipqtd.
        else do:
            create tt-liped.
            assign tt-liped.pednum = tt-pedid.pednum
                   tt-liped.pedtdc = tt-pedid.pedtdc
                   tt-liped.predt  = tt-pedid.peddat
                   tt-liped.etbcod = tt-pedid.etbcod
                   tt-liped.procod = produ.procod
                   tt-liped.lipqtd = vlipqtd
                   tt-liped.lipcor = vlipcor
                   tt-liped.protip = "A".
        end.
    end.
    

    message "Confirma inclusao do pedido " update sresp.
    if sresp
    then do:
        do transaction:
        for each atu-pedid.
            delete atu-pedid.
        end.
        for each atu-liped.
            delete atu-liped.
        end.

        find first tt-liped where
                   tt-liped.procod > 0 and
                   tt-liped.lipqtd > 0
                   no-error.
        if avail tt-liped
        then do:
            find last pedid where
                      pedid.pedtdc = 95 and
                      pedid.etbcod = vetbcod  and
                      pedid.pednum < 100000 no-lock no-error.
    
            if avail pedid
            then vpednum = pedid.pednum + 1.
            else vpednum = 1.
    
            create pedid.
            assign pedid.pedtdc    = 95
               pedid.pednum    = vpednum
               pedid.regcod    = estab.regcod
               pedid.peddat    = vdata
               pedid.pedsit    = yes
               pedid.sitped    = "E"
               pedid.modcod    = "PEDC"
               pedid.etbcod    = vetbcod.

    
            for each tt-liped:
                create liped.
                assign liped.pednum = pedid.pednum
                   liped.pedtdc = tt-liped.pedtdc
                   liped.predt  = tt-liped.predt
                   liped.etbcod = tt-liped.etbcod
                   liped.procod = tt-liped.procod
                   liped.lipqtd = tt-liped.lipqtd
                   liped.lipcor = tt-liped.lipcor
                   liped.protip = tt-liped.protip.
            end.
        end.
        end.
        find current pedid no-lock no-error.
        if avail pedid
        then do:
            /*
            run alcis/ordvh.p (input recid(pedid)).
            */
            run alcis/ordvh-900.p (input recid(pedid)).
            message color red/with
                "Pedido gerado: " pedid.pednum
                view-as alert-box.
        end.         
    end.
end.
