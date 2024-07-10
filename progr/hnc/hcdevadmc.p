{admcab.i} 
 
def var vdevolvido as int.
def var p-emite    as log init no.

def var vescolha as char format "x(20)" extent 3
        initial [" 1. CLIENTE     ",
                 " 2. NOTA FISCAL ",
                 " 3. E-COMMERCE " ].


def var vcredito as char.

def var vclien like clien.clicod.
def var vrecarga as log.

def buffer destab for estab.
def buffer lestab for estab.
def buffer fplani for plani.
def buffer bclase for clase. 
def new shared temp-table tp-vndseguro like com.vndseguro.

def new shared temp-table tp-titulo like fin.titulo
    index dt-ven titdtven
        index titnum /*is primary unique*/ empcod
                                           titnat
                                                                              modcod
                                   etbcod
                                                                      clifor
                                                                                                         titnum
                                                            titpar.
                                                            
def new shared temp-table tt-devolver
    field procod like movim.procod
    field etbcod like movim.etbcod    
    field movtdc like plani.movtdc
    field placod like plani.placod
    field pladat like plani.pladat
    field movpc  like movim.movpc
    field movqtm like movim.movqtm
    field serie  like plani.serie
    field numero like plani.numero
    field notped like plani.notped
    field movdev like movim.movdev.

def new shared temp-table tt-titdev
    field marca as char format "x(1)"
    field empcod like titulo.empcod
    field titnat like titulo.titnat
    field modcod like titulo.modcod
    field etbcod like titulo.etbcod
    field clifor like titulo.clifor
    field titnum like titulo.titnum
    field titpar like titulo.titpar
    field titvlcob like titulo.titvlcob
    field titvlpag like titulo.titvlpag
    field titsit   like titulo.titsit
    field titdtemi like titulo.titdtemi
    field tipdev     as   char
    index i-tit is primary unique empcod 
                                  titnat 
                                  modcod 
                                  etbcod 
                                  clifor 
                                  titnum 
                                  titpar.


def new shared temp-table tt-pro-recibo
    field pronom like produ.pronom
    field procod like produ.procod
    field movqtm like movim.movqtm
    field movpc  like movim.movpc
    index iprocod is primary unique procod.
def var d-vista as log format "Sim/Nao".
def var vclicod     like clien.clicod format ">>>>>>>>>>9".

def new shared temp-table tp-plani like com.plani
    field devolver like plani.platot label "Devolver" column-label "Devolver"
    index ipladat-d pladat desc.

def new  shared temp-table tp-movim like com.movim.    
def new shared temp-table tp-pro like com.produ.
def new shared temp-table tpb-contnf
        field etbcod  like contnf.etbcod
        field placod  like contnf.placod
        field contnum like contnf.contnum
        field marca   as   char format "x".
def new shared temp-table tpb-contrato like contrato.
def new shared temp-table tp-tbprice like adm.tbprice.
def new shared temp-table tp-contnf like fin.contnf.
def new shared temp-table tp-contrato like fin.contrato.


def var vetbcod-nf like estab.etbcod.
def var vnumero-nf like plani.numero.
def var vserie-nf  as char initial "3".
def var vpladat-nf like plani.pladat.

 
bl-princ:
repeat with centered row 3 side-label width 80 1 down
       title " CONTA DO CLIENTE PARA DEVOLUCAO " frame fcli :

        update vclicod auto-return 
          label "Conta" .
        
        find first clien where clien.clicod = vclicod no-lock no-error.
        if not avail clien or vclicod = 0
        then do: 
            message  "Cliente digitado nao existe.".
            next.
        end.    
        disp vclicod
             clien.clinom format "x(30)" no-label.

        if clien.classe = 1
        then vcredito = "FACIL".
        else vcredito = "".

        disp vcredito no-label
            clien.dtcad no-label format "99/99/9999" to 78.

        
        

        
        
        def var vtipdev as char.

        for each tt-devolver. delete tt-devolver. end. 
        for each tt-titdev: delete tt-titdev. end.             
        for each tt-pro-recibo: delete tt-pro-recibo. end.

            d-vista = no.
            if vclicod = 1
            then d-vista = yes.
             
            if vclicod = 1 and d-vista = no
            then do:
                message "Opcao nao disponivel para o Cliente 1"
                    view-as alert-box.
                next.
            end.

            for each tt-devolver. delete tt-devolver. end. 

            vtipdev = "TROCA".
            
            display skip(1)
                    vescolha
                    skip(1)
                    with frame f-escolha no-label title " Troca/Devolucao ".
            choose field vescolha 
                         with frame f-escolha centered row 8 overlay. 
            hide frame f-escolha no-pause.

            if frame-index = 1 and d-vista
            then do:
                message "Opcao " vescolha[frame-index] " nao disponivel."
                    view-as alert-box.
                next.
            end.
                
                p-emite = no.
                vserie-nf = "3".
            
                if frame-index = 1 /*  1. CLIENTE */
                then do:
                    for each tp-plani. delete tp-plani. end.
                    for each tp-movim. delete tp-movim. end.
                    for each tp-pro. delete tp-pro. end.
                    for each tpb-contnf. delete tpb-contnf. end.
                    for each tpb-contrato. delete tpb-contrato. end.
                    
                    run atualiza-dados-nas-temps (vclicod,0). 

                    
                end.
                else 
                if frame-index = 2 /* 2. NOTA FISCAL */
                then do:
                    do on error undo: 
                        assign vetbcod-nf = setbcod 
                               vnumero-nf = 0
                               vpladat-nf = ?
                               vclien     = vclicod.
    
                        if d-vista then vclien = 1.

                        
                        disp
                            vetbcod-nf label "Filial"
                                validate(vetbcod-nf > 0,
                                   "Informe a filial de origem da nota fiscal")
                            vnumero-nf format ">>>>>>>>>9"
                                label "Numero da Venda"
                                validate (vnumero-nf > 0,
                                   "Informe a filial de origem da nota fiscal")
                            vserie-nf format "x(3)" label "Serie da Venda"
                            vpladat-nf label "Data da Venda"
                            with frame f-busca2 row 8 centered 
                                                   side-labels 1 col overlay.
                        
                        update
                            vetbcod-nf
                            vnumero-nf 
                            vserie-nf
                            vpladat-nf
                            with frame f-busca2.
                        

                        if vpladat-nf = ?
                        then do:
                            message "Informe a data de emissao da nota fiscal".
                            undo.
                        end.
                        if vetbcod-nf <> setbcod
                        then do:
                            find lestab where lestab.etbcod = setbcod no-lock.
                            find destab where destab.etbcod = vetbcod-nf
                                        no-lock no-error.
                            if avail destab and
                                     destab.ufecod <> lestab.ufecod
                            then do:
                                message color red/with
                                "Operação não permitida para venda de outra Uni~dade da Federação." view-as alert-box.
                                undo.
                            end.    
                        end.
                    end.


                    for each tp-plani. delete tp-plani. end.
                    for each tp-movim. delete tp-movim. end.
                    for each tp-pro. delete tp-pro. end.
                    for each tpb-contnf. delete tpb-contnf. end.
                    for each tpb-contrato. delete tpb-contrato. end.
                    for each tp-tbprice: delete tp-tbprice. end.
                    
                    run atualiza-dados-nas-temps (0,0). 


                end.
                else
                if frame-index = 3 /*  1. e-commerce filial 200 */
                then do:
                    for each tp-plani. delete tp-plani. end.
                    for each tp-movim. delete tp-movim. end.
                    for each tp-pro. delete tp-pro. end.
                    for each tpb-contnf. delete tpb-contnf. end.
                    for each tpb-contrato. delete tpb-contrato. end.
                   
                    p-emite = yes.
                    
                    vserie-nf = "1".
                    run atualiza-dados-nas-temps (vclicod,200). 

                    
                end.

                
                find first tp-plani no-lock no-error.
                if not avail tp-plani
                then do:
                    message "Nota Nao encontrada." view-as alert-box.
                    undo.
                end.
                
                /* bloquear recarga - inacio - chamado 22257 */  
                vrecarga = no.
                sresp = yes.    
                for each tp-movim no-lock,
                    first produ where produ.procod = tp-movim.procod no-lock.
                    if produ.pronom matches("*RECARGA*") 
                    then assign sresp = no
                                vrecarga = yes.
                end.
                if sresp = no
                then do:
                     message "Devolucao nao permitida para RECARGA."
                             view-as alert-box.
                     undo.
                end.
                
                for each tpb-contrato: delete tpb-contrato. end.
                for each tpb-contnf: delete tpb-contnf. end.
                for each tp-contrato no-lock:
                    create tpb-contrato.
                    buffer-copy tp-contrato to tpb-contrato.
                end.
                for each tp-contnf no-lock:
                    create tpb-contnf.
                    assign
                        tpb-contnf.etbcod = tp-contnf.etbcod
                        tpb-contnf.placod = tp-contnf.placod
                        tpb-contnf.contnum = tp-contnf.contnum.
                end.
                
                run hnc/hcdevol001.p(vclicod, vtipdev, output sresp).
                
                if sresp = no
                then undo.

                hide message no-pause.

                run hnc/hctitdevol.p(input  vclicod, 
                                     input  p-emite). /* Emite */
                               
                
        pause 0.
                        
end.                
    

 
procedure atualiza-dados-nas-temps.

def input parameter par-clicod as int.
def input parameter par-filial as int. 

if par-clicod = 0
then  do on error undo:
    find plani where 
        plani.movtdc    = 5 and
        plani.etbcod    = vetbcod-nf and
        plani.emite     = vetbcod-nf and
        plani.numero    = vnumero-nf and
        plani.serie     = vserie-nf  and
        plani.pladat    = vpladat-nf 
        no-lock no-error.
    if avail plani 
    then do:
        /*
        find first ctdevven where
            ctdevven.etbcod-ori = plani.etbcod and
            ctdevven.placod-ori = plani.placod
             no-lock no-error.
        if avail ctdevven
        then next.     
        **/
        
        create tp-plani.
        buffer-copy plani to tp-plani.
        vdevolvido = 0.
        for each movim use-index movim where 
            movim.etbcod = plani.etbcod and
            movim.placod = plani.placod
            no-lock.
            find produ where produ.procod = movim.procod no-lock.
            if produ.proipiper = 98
            then next.
            vdevolvido = 0.
            
            for each devmovim where
                devmovim.emite  = movim.etbcod and
                devmovim.notori = plani.numero and
                devmovim.procod = movim.procod
                no-lock.
                vdevolvido = vdevolvido + devmovim.movqtm.
            end.
            if vdevolvido = movim.movqtm 
            then next.
            create tp-movim.
            buffer-copy movim to tp-movim.

            tp-movim.movqtm = movim.movqtm - vdevolvido. 

        end.     
        find first tp-movim where tp-movim.etbcod = plani.etbcod and
                    tp-movim.placod = plani.placod
                    no-error.
        if not avail tp-movim
        then do:
            delete tp-plani.
            next.
        end.    
        
        run calc-devolver (recid(tp-plani)).
        
        
        
    end.
    
end.


if par-clicod <> 0
then  do on error undo:
    for each plani use-index plasai where 
        plani.movtdc    = 5 and
        plani.desti     = par-clicod and
        plani.serie     = vserie-nf
        no-lock.

        if par-filial <> 0
        then do:
            if plani.etbcod <> par-filial
            then next.
        end.
        /**
        find first ctdevven where
            ctdevven.etbcod-ori = plani.etbcod and
            ctdevven.placod-ori = plani.placod
             no-lock no-error.
        if avail ctdevven
        then next.     
        **/
        
        create tp-plani.
        buffer-copy plani to tp-plani.
        for each movim use-index movim where 
            movim.etbcod = plani.etbcod and
            movim.placod = plani.placod
            no-lock.
            find produ where produ.procod = movim.procod no-lock.
            if produ.proipiper = 98
            then next.
            vdevolvido = 0.
            for each devmovim where
                devmovim.emite  = movim.etbcod and
                devmovim.notori = plani.numero and
                devmovim.procod = movim.procod
                no-lock.
                vdevolvido = vdevolvido + devmovim.movqtm.
            end.
            if vdevolvido = movim.movqtm 
            then next.
            create tp-movim.
            buffer-copy movim to tp-movim.

            tp-movim.movqtm = movim.movqtm - vdevolvido. 
        end.     
        find first tp-movim where tp-movim.etbcod = plani.etbcod and
                    tp-movim.placod = plani.placod
                    no-error.
        if not avail tp-movim
        then do:
            delete tp-plani.
            next.
        end.    
                     
        run calc-devolver (recid(tp-plani)).
        
        find first tp-contnf where    
                tp-contnf.etbcod = tp-plani.etbcod and 
                tp-contnf.placod = tp-plani.placod 
                no-lock no-error. 
        if not avail tp-contnf            
        then do: 
            find first contnf where 
                contnf.etbcod = tp-plani.etbcod and 
                contnf.placod = tp-plani.placod 
                no-lock no-error. 
            if avail contnf 
            then do: 
                create tp-contnf. 
                buffer-copy contnf to tp-contnf. 
            end.
        end.        
        for each tp-contnf where  
                tp-contnf.etbcod = tp-plani.etbcod and 
                tp-contnf.placod = tp-plani.placod 
                no-lock. 
            find first tp-contrato where 
                tp-contrato.contnum = tp-contnf.contnum 
                no-lock no-error. 
            if avail tp-contrato 
            then sresp = yes. 
            else do: 
                find contrato where  
                    contrato.contnum = tp-contnf.contnum 
                    no-lock no-error. 
                if avail contrato 
                then do: 
                    create tp-contrato. 
                    buffer-copy contrato to tp-contrato. 
                    sresp = yes. 
                end.      
            end. 
        end.
    end.
    
                for each tp-contrato no-lock:
                    create tpb-contrato.
                    buffer-copy tp-contrato to tpb-contrato.
                end.
                for each tp-contnf no-lock:
                    create tpb-contnf.
                    assign
                        tpb-contnf.etbcod = tp-contnf.etbcod
                        tpb-contnf.placod = tp-contnf.placod
                        tpb-contnf.contnum = tp-contnf.contnum.
                end.
        
end.


end procedure.



procedure calc-devolver.
def input parameter par-recid as recid.

find tp-plani where recid(tp-plani) = par-recid.
if tp-plani.crecod = 1
then do:
    tp-plani.devolver = tp-plani.platot.
end.
else do:
    tp-plani.devolver = 0.
    for each contnf where contnf.etbcod = tp-plani.etbcod
                      and contnf.placod = tp-plani.placod
                    no-lock.
        find contrato of contnf no-lock no-error.
        if avail contrato
        then do:
            for each titulo where titulo.empcod = 19
                              and titulo.titnat = no
                              and titulo.modcod = tp-plani.modcod
                              and titulo.etbcod = tp-plani.etbcod
                              and titulo.clifor = tp-plani.desti
                              and titulo.titnum = string(contrato.contnum)
                            no-lock
                        by titulo.titdtpag.
                if titulo.titsit = "PAG"
                then tp-plani.devolver = tp-plani.devolver + titulo.titvlcob.
            end.
        end.
    end.
end.
end procedure.


