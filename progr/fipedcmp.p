/*  fipedcmp.p              */
/* Projeto Melhorias Mix - Luciano                                      */
/* alterado em 26/11 para ajustar a quantidade de conjunto              */ 

{admcab.i}

def var vprocod like produ.procod.
def var vpednum like pedid.pednum.
def var vetbcod like estab.etbcod.
def var vdata like pedid.peddat.
def var vdiretorio  as char format "x(40)"  label "Diretorio" init "/admcom/ped_comerc/".
def var par-arquivo    as char format "x(40)"  label "Arquivo" init ".csv".

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

def var vlipcor like liped.lipcor.
def var vlipqtd like liped.lipqtd format ">>>>9".

def var funcao          as char format "x(20)".
def var parametro       as char format "x(20)".
def var v-status        as char.

def var vmovqtm as dec.
def var val-conjunto as dec.

def temp-table cri-pedidos
    field rec_ped as recid.


def var vsenha as char format "x(10)".
def var fun-senha as char.

find func where func.funcod = sfuncod and
                func.etbcod = setbcod
                no-lock no-error.
if avail func
then fun-senha = func.senha.

/****
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
****/

def var vtipo as char extent 2 format "x(24)"
                init [" Inclusao Manual ", " Inclusao Por Arquivo "].
display vtipo
        with centered  frame fescolha no-label.
choose field vtipo
        with centered  frame fescolha no-label
                row 6.
if frame-index = 2
then do on error undo.
    run por_arquivo .
    leave.
end.

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
if vetbcod = 25
or vetbcod = 28
or vetbcod = 41
or vetbcod = 42
or vetbcod = 46
or vetbcod = 55
or vetbcod = 61
or vetbcod = 98
or vetbcod = 115
or vetbcod = 134
or vetbcod = 116
or vetbcod = 11
or vetbcod = 131
or vetbcod = 126
or vetbcod = 105
or vetbcod = 83
or vetbcod = 59
or vetbcod = 65
or vetbcod = 48
or vetbcod = 45
or vetbcod = 40
or vetbcod = 1
or vetbcod = 7
or vetbcod = 82
or vetbcod = 150
or vetbcod = 139
or vetbcod = 141
or vetbcod = 10
or vetbcod = 306
or vetbcod = 39
or vetbcod = 72
or vetbcod = 5
or vetbcod = 37
or vetbcod = 97
or vetbcod = 100
or vetbcod = 66
or vetbcod = 89
or vetbcod = 68
or vetbcod = 64
or vetbcod = 80
or vetbcod = 103
or vetbcod = 143
or vetbcod = 104
or vetbcod = 138
or vetbcod = 6
or vetbcod = 27
or vetbcod = 137
or vetbcod = 110
or vetbcod = 81
or vetbcod = 309
or vetbcod = 164
or vetbcod = 38
or vetbcod = 70
or vetbcod = 44
or vetbcod = 47

or(vetbcod =112 and today >= 07/15/2019)
or(vetbcod =111 and today >= 07/15/2019)
or(vetbcod =93 and today >= 07/15/2019)
or(vetbcod =117 and today >= 07/15/2019)
or(vetbcod =43 and today >= 07/15/2019)
or(vetbcod =124 and today >= 07/15/2019)
or(vetbcod =12 and today >= 07/15/2019)
or(vetbcod =74 and today >= 07/15/2019)
or(vetbcod =56 and today >= 07/15/2019)

or(vetbcod =13 and today >= 07/16/2019)
or(vetbcod =8 and today  >= 07/16/2019)
or(vetbcod =20 and today >= 07/16/2019)
or(vetbcod =60 and today >= 07/16/2019)
or(vetbcod =57 and today >= 07/16/2019)
or(vetbcod =33 and today >= 07/16/2019)
or(vetbcod =85 and today >= 07/16/2019)
or(vetbcod =91 and today >= 07/16/2019)
or(vetbcod =34 and today >= 07/16/2019)
or(vetbcod =15 and today >= 07/16/2019)

or(vetbcod =113 and today >= 07/17/2019)
or(vetbcod =108 and today >= 07/17/2019)
or(vetbcod =52 and today >= 07/17/2019)
or(vetbcod =119 and today >= 07/17/2019)
or(vetbcod =54 and today >= 07/17/2019)
or(vetbcod =129 and today >= 07/17/2019)
or(vetbcod =35 and today >= 07/17/2019)
or(vetbcod =9 and today >= 07/17/2019)
or(vetbcod =14 and today >= 07/17/2019)
or(vetbcod =2 and today >= 07/17/2019)
or(vetbcod =4 and today >= 07/17/2019)
or(vetbcod =67 and today >= 07/17/2019)
or(vetbcod =32 and today >= 07/17/2019)
or(vetbcod =26 and today >= 07/17/2019)
or(vetbcod =136 and today >= 07/17/2019)
or(vetbcod =76 and today >= 07/17/2019)
or(vetbcod =92 and today >= 07/17/2019)
or(vetbcod =96 and today >= 07/17/2019)
or(vetbcod =162 and today >= 07/17/2019)
or(vetbcod =140 and today >= 07/17/2019)


or(vetbcod =69 and today >= 07/18/2019)
or(vetbcod =73 and today >= 07/18/2019)
or(vetbcod =17 and today >= 07/18/2019)
or(vetbcod =63 and today >= 07/18/2019)
or(vetbcod =79 and today >= 07/18/2019)
or(vetbcod =121 and today >= 07/18/2019)
or(vetbcod =99 and today >= 07/18/2019)
or(vetbcod =21 and today >= 07/18/2019)
or(vetbcod =50 and today >= 07/18/2019)

or(vetbcod =87 and today >= 07/22/2019)
or(vetbcod =49 and today >= 07/22/2019)
or(vetbcod =106 and today >= 07/22/2019)
or(vetbcod =51 and today >= 07/22/2019)
or(vetbcod =29 and today >= 07/22/2019)
or(vetbcod =127 and today >= 07/22/2019)
or(vetbcod =75 and today >= 07/22/2019)
or(vetbcod =53 and today >= 07/22/2019)
or(vetbcod =62 and today >= 07/22/2019)
or(vetbcod =163 and today >= 07/22/2019)
or(vetbcod =71 and today >= 07/22/2019)
or(vetbcod =135 and today >= 07/22/2019)
or(vetbcod =24 and today >= 07/22/2019)
or(vetbcod =125 and today >= 07/22/2019)
or(vetbcod =142 and today >= 07/22/2019)
or(vetbcod =160 and today >= 07/22/2019)
or(vetbcod =161 and today >= 07/22/2019)
or(vetbcod =78 and today >= 07/22/2019)

or(vetbcod =101 and today >= 07/23/2019)
or(vetbcod =301 and today >= 07/23/2019)
or(vetbcod =303 and today >= 07/23/2019)
or(vetbcod =304 and today >= 07/23/2019)
or(vetbcod =305 and today >= 07/23/2019)
or(vetbcod =122 and today >= 07/23/2019)
or(vetbcod =133 and today >= 07/23/2019)
or(vetbcod =86 and today >= 07/23/2019)
or(vetbcod =94 and today >= 07/23/2019)
or(vetbcod =84 and today >= 07/23/2019)
or(vetbcod =77 and today >= 07/23/2019)
or(vetbcod =114 and today >= 07/23/2019)
or(vetbcod =144 and today >= 07/23/2019)
or(vetbcod =102 and today >= 07/23/2019)
or(vetbcod =130 and today >= 07/23/2019)
or(vetbcod =120 and today >= 07/23/2019)
or(vetbcod =109 and today >= 07/23/2019)

or(vetbcod =88 and today >= 07/25/2019)
or(vetbcod =132 and today >= 07/25/2019)
or(vetbcod =123 and today >= 07/25/2019)
or(vetbcod =36 and today >= 07/25/2019)
or(vetbcod =58 and today >= 07/25/2019)
or(vetbcod =165 and today >= 07/25/2019)
or(vetbcod =30 and today >= 07/25/2019)
or(vetbcod =31 and today >= 07/25/2019)
or(vetbcod =118 and today >= 07/25/2019)
or(vetbcod =95 and today >= 07/25/2019)
or(vetbcod =90 and today >= 07/25/2019)
or(vetbcod =18 and today >= 07/25/2019)
or(vetbcod =3 and today >= 07/25/2019)
or(vetbcod =19 and today >= 07/25/2019)
or(vetbcod =23 and today >= 07/25/2019)
or(vetbcod =16 and today >= 07/25/2019)


then do:
message "Loja Neogrid. Utilizar menu novo".
undo.
end.
    display estab.etbnom no-label skip with frame f1.
    update vdata colon 18 skip with frame f1.
    
    find last pedid where
              pedid.pedtdc = 3 and
              pedid.etbcod = vetbcod  and
              pedid.pednum < 100000 no-lock no-error.
    
    if avail pedid
    then vpednum = pedid.pednum + 1.
    else vpednum = 1.
    
    create tt-pedid.
    assign tt-pedid.pedtdc    = 3 
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
        if produ.catcod = 41
        then do:
            message color red/with
            "Produto de MODA inclusao nao permitida"
            view-as alert-box.
            next.
        end.
        find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                                  and tt-liped.pedtdc = tt-pedid.pedtdc 
                                  and tt-liped.pednum = tt-pedid.pednum 
                                  and tt-liped.procod = produ.procod no-error.
         if avail tt-liped
         then do:
            message "Porduto ja incluido.".
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
         find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = vetbcod no-lock.
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
        if val-conjunto = 0
        then do.
            find first tbcntgen where
                       tbcntgen.tipcon = 5 and
                       tbcntgen.etbcod = 0 and
                       tbcntgen.numfim = string(produ.procod)  no-error.
            if avail tbcntgen and tbcntgen.quantidade > 0
            then
                val-conjunto = tbcntgen.quantidade.
        end.
        
        
        setbcod = vsetbcod.
        /***
        if (vqtdsug = 1 and
           sresp = no) or
           vqtdsug = 0
        then do:
            find last qliped   where 
                      qliped.pedtdc = 3 and 
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
                estoq.estatual format "->>9" column-label "Est."
                int(sretorno) format ">>9" column-label "Cob."
                vmovqtm format ">>9" column-label "Venda!30dias"
        with frame f2.
        vqtdsug = 1.
        do on error undo:
            vlipqtd = vqtdsug.
            update vlipqtd column-label "Qtd"
                with frame f2 down centered color blank/cyan.
            if  vlipqtd = 0 /*or
                vlipqtd > vqtdsug + 1 */
            then do:
                message color red/with
                    "Quantidade nao permitida."
                    view-as alert-box.
                undo.    
            end.
            else do.
                /*****************
                if val-conjunto > 0 
                then do:
                    message color red/with 
                        " PRODUTO" skip "CONJUNTO de " 
                                val-conjunto
                       /* " Quntidade pedida " vlipqtd "sera enviada." */
                        view-as alert-box title "".
                end.
                ****************/

                if val-conjunto > 0
                then do.
                   if vlipqtd >= val-conjunto   and
                     int(substr(string(vlipqtd / val-conjunto,"->>>>>>>9.99"),
                            11,2)) = 0
                   then do:
                     /***********
                     message color red/with 
                        " PRODUTO DE CONJUNTO " SKIP(1)
                        " Quantidade pedida " vlipqtd "sera enviada."
                        view-as alert-box title "".
                    ***************/
                   end.
                   else do:
                      message color red/with
                      "Quantidade nao permitida." skip
                      "PRODUTO DE CONJUNTO" SKIP
                      "QUANTIDADE DEVE SER MULTIPLA DE " VAL-CONJUNTO
                         view-as alert-box.
                      undo.
                   end.     
                end.
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
                   tt-liped.protip = string(time).
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
                      pedid.pedtdc = 3 and
                      pedid.etbcod = vetbcod  and
                      pedid.pednum < 100000 no-lock no-error.
    
            if avail pedid
            then vpednum = pedid.pednum + 1.
            else vpednum = 1.
    
            create pedid.
            assign pedid.pedtdc    = 3
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
        then do on endkey undo:
            hide message no-pause.
            message color red/with
                "Pedido gerado: " pedid.pednum.
            pause 5 .
        end.         
    end.
    leave.
end.

def temp-table ttpro
    field procod    like produ.procod format ">>>>>>>>>>>>"
    field etbcod    like estab.etbcod format ">>>>>>>>>>>>>"
    field qtd       like estoq.estatual format ">>>>>>>>>>>".    

procedure por_arquivo.

for each cri-pedidos.
    delete cri-pedidos.
end.    
do on error undo.
    update vdiretorio   colon 20
           par-arquivo     colon 20
           with frame fparametros centered row 6
                side-label width 80.
    if search(vdiretorio + par-arquivo) = ? and
       search(vdiretorio + "/" +  par-arquivo) = ? 
    then do.
        message "Arquivo nao encontrado".
        undo.
    end.
    for each ttpro. 
        delete ttpro.
    end.
    def var warquivo as char.
    if search(vdiretorio + par-arquivo) <> ?
    then warquivo = search(vdiretorio + par-arquivo).
    if search(vdiretorio + "/" +  par-arquivo) <> ?
    then warquivo = search(vdiretorio + "/" +  par-arquivo).

    find first pedid where pedid.pedobs[5]  = warquivo and
                           pedid.pedtdc     = 3  no-lock
                           no-error.
    if avail pedid 
    then do. 
        message "Arquivo Ja importado"
                view-as alert-box.
        undo.        
    end.
    
    input from value(warquivo).
    repeat transaction.
        create ttpro.
        import delimiter ";" ttpro.
    end.
    input close.
    def var vok as log.
    vok = yes. 
    for each ttpro.
        find produ where produ.procod = ttpro.procod no-lock no-error.
        if not avail produ
        then vok = no.
        if produ.catcod = 41
        then do:
            message color red/with
            "Produto(" string(produ.procod) ") MODA"
            view-as alert-box.
            vok = no.
        end.
        find estab where estab.etbcod = ttpro.etbcod no-lock no-error.
        if not avail estab
        then vok = no.
    end.
    if vok = no
    then do.
        message "Arquivo com inconsistencias. Gerando relatorio".
        pause 3 no-message.
        run inconsistencias.
        undo.
    end.
    hide message no-pause.
    message "Confirma a importacao do arquivo ?" update sresp .
    update vdata colon 18 skip with frame f1.
end.
def var rec as recid.
for each ttpro break by ttpro.etbcod.

    if first-of(ttpro.etbcod)
    then do on error undo.
        find estab where estab.etbcod = ttpro.etbcod no-lock.
        vetbcod = estab.etbcod.
        find last pedid where
              pedid.pedtdc = 3 and
              pedid.etbcod = vetbcod  and
              pedid.pednum < 100000 no-lock no-error.
        if avail pedid
        then vpednum = pedid.pednum + 1.
        else vpednum = 1.        
        create tt-pedid.
        rec = recid(tt-pedid).
        assign tt-pedid.pedtdc    = 3 
               tt-pedid.pednum    = vpednum 
               tt-pedid.regcod    = estab.regcod 
               tt-pedid.peddat    = vdata 
               tt-pedid.pedsit    = yes 
               tt-pedid.sitped    = "E" 
               tt-pedid.modcod    = "PEDC" 
               tt-pedid.etbcod    = vetbcod.
    end.
    find tt-pedid where recid(tt-pedid) = rec no-lock.
    do on error undo.
        find produ of ttpro no-lock.
        find first tt-liped where tt-liped.etbcod = tt-pedid.etbcod 
                              and tt-liped.pedtdc = tt-pedid.pedtdc 
                              and tt-liped.pednum = tt-pedid.pednum 
                              and tt-liped.procod = produ.procod no-error.
        if avail tt-liped
        then do:
            next.
        end.
        find estoq where estoq.procod = produ.procod and
                         estoq.etbcod = vetbcod no-lock no-error.
        vlipqtd = ttpro.qtd.
        vlipcor = "".
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
                   tt-liped.protip = string(time).
        end.
    end.
    if last-of(ttpro.etbcod)
    then do.
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
            then do on error undo:
                find last pedid where
                          pedid.pedtdc = 3 and
                          pedid.etbcod = vetbcod  and
                          pedid.pednum < 100000 no-lock no-error.
            
                if avail pedid
                then vpednum = pedid.pednum + 1.
                else vpednum = 1.
    
                create pedid.
                assign pedid.pedtdc    = 3
                   pedid.pednum    = vpednum
                   pedid.regcod    = estab.regcod
                   pedid.peddat    = vdata
                   pedid.pedsit    = yes
                   pedid.sitped    = "E"
                   pedid.modcod    = "PEDC"
                   pedid.etbcod    = vetbcod
                   pedid.pedobs[5] = warquivo .
                create cri-pedidos.
                cri-pedidos.rec_ped = recid(pedid).
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
            message color red/with
                "Pedido gerado: " pedid.pednum pedid.etbcod.
            pause 0.
        end. 
        for each tt-liped.
            delete tt-liped.
        end.    
        for each tt-pedid.
            delete tt-pedid.
        end.
    end.
end.

run cri-pedidos.




end procedure.

def var varquivo  as char.

procedure inconsistencias.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/fipedcmp." + string(time).
    else varquivo = "..~\relat~\fipedcmp." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""fipedcmp"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ IMPORTACAO ARQUIVO PEDIDOS PARA FILIAIS - "" 
                            + par-arquivo " 
                &Width     = "120"
                &Form      = "frame f-cabcab"}
    
    for each ttpro with width 200.
        display ttpro.
        find produ where produ.procod = ttpro.procod no-lock no-error.
        if not avail produ
        then display "** PRODUTO SEM CADASTRO **".
        find estab where estab.etbcod = ttpro.etbcod no-lock no-error.
        if not avail estab
        then display "** ESTABELECIMENTO SEM CADASTRO **".
    end.


    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.



end procedure.


procedure cri-pedidos.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/relat/fipedcmp." + string(time).
    else varquivo = "..~\relat~\fipedcmp." + string(time).
    
    {mdadmcab.i &Saida     = "value(varquivo)"   
                &Page-Size = "64"  
                &Cond-Var  = "120" 
                &Page-Line = "66" 
                &Nom-Rel   = ""fipedcmp"" 
                &Nom-Sis   = """SISTEMA COMERCIAL""" 
                &Tit-Rel   = """ IMPORTACAO ARQUIVO PEDIDOS PARA FILIAIS - "" 
                            + par-arquivo " 
                &Width     = "120"
                &Form      = "frame f-cabcabb"}
    
    for each cri-pedidos,
        pedid where recid(pedid) = cri-pedidos.rec_ped no-lock
                            by pedid.etbcod.
        def var vqtd    as int.
        def var vcont   as int.
        vqtd = 0.
        vcont = 0.
        for each liped of pedid no-lock.
            vcont = vcont + 1.
            vqtd  = vqtd  + liped.lipqtd.
        end.
        display pedid.etbcod
                pedid.pednum
                pedid.peddat
                pedid.modcod no-label format "xxxx"
                vcont   label "Tot Itens"  (count total)
                vqtd    label "Quantidade" (count total)
                with frame fflflflflf down 
                        width 200.
    end.

    
    output close.

    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.



end procedure.

