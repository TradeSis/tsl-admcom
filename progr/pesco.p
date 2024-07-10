/***************************************************************************** 
 * pesco.p                                                                   *
 *       2014 - Luciano.Alves - Projeto Melhorias Mix                        *
 * 03/04/2014 - criado campos DISPONIVEL e INDISPONIVEL                      * 
 * 09/04/2014 - emiminada da tela o display dos campos Disp900 e Disp995     *
 * 27/01/2015 - Luciano.Alves - Distribuicao versao 2                        *
 *                                                                           *
 *                                                                           *
 *****************************************************************************/
{admcab.i}

def new shared var vestatual    like estoq.estatual format "->>>>9".
def new shared var vestatual995  like estoq.estatual format "->>>>9".
def new shared var vdisponiv900  like estoq.estatual format "->>>>9".
def new shared var vdisponiv995  like estoq.estatual format "->>>>9".
def new shared var vdisponiv993  like estoq.estatual format "->>>>9".
def new shared var vreserv_ecom  like estoq.estatual format "->>>>9".
def new shared var vestatual900  like estoq.estatual format "->>>>9".
def new shared var vestatual988  like estoq.estatual format "->>>>9".
def new shared var vestatual500  like estoq.estatual format "->>>>9".
def new shared var vestatual981  like estoq.estatual format "->>>>9".
def new shared var vestatual993  like estoq.estatual format "->>>>9".
def var pedidos_900 as dec.

def var estoq-disponivel    like estoq.estatual format "->>>>9"
                        label "Estoque DISPONIVEL".
def var estoq-indisponivel    like estoq.estatual format "->>>>9"
                        label "INDISPONIVEL".


def var vreservado like estoq.estatual.

def var vest-outros-dep         like estoq.estatual format "->>>>9".
def new shared var vint-ped-abertos like estoq.estatual format "->>>>9".

def new shared var vprocod as dec format ">>>>>>>>>>>>9".
def var vvprocod like produ.procod.
def var v-icmsubst like plani.protot.
def var v-custotal like plani.platot.
def var vdata as date.

def var reserva like estoq.estatual.
def var varquivo as char.
def var fila as char.
def buffer bestoq for estoq.
def buffer bestoq-993 for estoq.
def buffer sclase for clase.
def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".

def new shared temp-table wpro
    field etbcod like estab.etbcod
    field etbnom like estab.etbnom
    field munic  like estab.munic format "x(20)"
    field prounven like produ.prounven
    field estvenda like estoq.estvenda
    field estcusto like estoq.estcusto 
    field estatual like estoq.estatual
    field wreserva like estoq.estatual
    field estproper like estoq.estproper
    field estprodat like estoq.estprodat
    .

def new global shared temp-table tt-reservas
    field sequencia    as dec
    field rec_liped     as recid
    field tipo          as char
    field atende        as int
    field dispo         as int 
    field prioridade    as int format "->>>>" label "Pri"
    field regra         as int
    index sequencia   is primary prioridade
    index rec_liped is unique rec_liped .

define variable wcod as integer format "999999".
def var vv as int.
def var vespecial as int.

def temp-table tt-estab
    field etbcod like estab.etbcod
    field ord    as int.
def buffer bctpromoc for ctpromoc.
def var vestvenda like estoq.estvenda.
def var vestcusto like estoq.estcusto.
def buffer cestab for estab.


repeat:

 /*with side-labels width 80 frame f1 title " Produto ":*/
    for each wpro:
        delete wpro.
    end.
    for each tt-estab:
        delete tt-estab.
    end.        
    
    clear frame f1 no-pause.
    /*vprocod = 0.*/
    vdisponiv900 = 0.
    vdisponiv995 = 0.
    vreserv_ecom = 0.
    vestatual900 = 0.
    vestatual995 = 0.
    vestatual988 = 0.
    vestatual500 = 0.
    vestatual981 = 0.
    vestatual993 = 0.
    vest-outros-dep = 0.
    vestcusto = 0.
    vestvenda = 0.
    
    update vprocod  label "Produto" 
           with side-labels width 81 frame f1 
                    /*title " Produto "*/ no-validate.

    find produ where produ.procod = int(vprocod) no-lock no-error.
    if not avail produ
    then do:
        find first produ where produ.proindice = string(vprocod) 
                    no-lock no-error.
        if not avail produ
        then do:
            message "Produto nao Cadastrado".
            undo, retry.
        end.
        else display produ.procod @ vprocod with frame f1.
    end.
    
        /* Antonio - Sol 26330 */
    assign vvprocod = int(vprocod).
    find estoq where estoq.etbcod = 900 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual900 = vestatual900 + estoq.estatual.

    find estoq where estoq.etbcod = 995 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual995 = vestatual995 + estoq.estatual.

    find estoq where estoq.etbcod = 988 and estoq.procod = vvprocod
        no-lock no-error.
    if avail estoq then assign vestatual988 = vestatual988 + estoq.estatual.

    find estoq where estoq.etbcod = 500 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual500 = vestatual500 + estoq.estatual.  

    find estoq where estoq.etbcod = 981 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual981 = vestatual981 + estoq.estatual.  
    find estoq where estoq.etbcod = 993 and estoq.procod = vvprocod           
        no-lock no-error.                                                     
    if avail estoq then assign vestatual993 = vestatual993 + estoq.estatual. 

    /*  Antonio  - Sol. 26330 */
    find first sclase 
             where sclase.clacod = produ.clacod no-lock no-error.
    /*
    find first clase 
             where clase.clacod = sclase.clasup no-lock no-error.
    */
    vestacao = "".
    find estac where
         estac.etccod = produ.etccod no-lock no-error.
    if avail estac
    then vestacao = estac.etcnom.
    else vestacao = "".
    vestilo = "".
    find first procaract 
            where procaract.procod = produ.procod no-lock no-error.
    if avail procaract
    then do:
            find first subcaract where
               /* subcaract.carcod = 2 and */
          /*     subcaract.subcar = procaract.subcod */
              subcaract.subcod = procaract.subcod
            no-lock no-error.
            if avail subcaract
            then vestilo = subcaract.subdes.            
    end.
    /***/
    vv = 0.
    for each estab where estab.etbcod < 400 /*and
                {conv_igual.i estab.etbcod}*/ no-lock.
        vv = vv + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod
               tt-estab.ord    = vv.
    end. 
    for each estab where estab.etbcod >= 400 no-lock.
        if estab.etbcod = 990
            then next.
    
        vv = vv + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.

        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod
               tt-estab.ord    = vv.
    end.   
    
    for each estab where estab.etbcod < 400 /*and
                    {conv_difer.i estab.etbcod}*/ no-lock.
    
        vv = vv + 1.
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        find first tt-estab where
                   tt-estab.etbcod = estab.etbcod no-error.
        if not avail estab
        then create tt-estab.
        assign tt-estab.etbcod = estab.etbcod
               tt-estab.ord    = vv.
    end.    
    run ve-est.
    
    find fabri of produ no-lock no-error.
    if not avail fabri
    then do:
        bell.
        message color red/with
        "Fabricante" string(produ.fabcod,">>>>>>>>9")
        "não encontrado na tabela fabri do Admcom."
        view-as alert-box.
        undo, retry.
    end.

    display produ.pronom no-label /*format "x(35)" */ skip
/*            produ.prodtcad  format "99/99/9999" label "Dt.Cad"*/
            fabri.fabcod format ">>>>>>>>9" label "Fornec." 
            fabri.fabfant no-label with frame f1.
                                  
    color display message produ.pronom vprocod
            with frame f1.
     
    disp produ.prodtcad  format "99/99/99" label "Dt.Cad" colon 52
         produ.datexp format "99/99/99"                 
            label "DatExp" colon 69 skip(1) with frame f1.
         
    find first bestoq where bestoq.procod = produ.procod 
            no-lock.
    vestvenda = bestoq.estvenda.
    
    find last  ctpromoc where
               ctpromoc.promocod  = 20     and
               ctpromoc.procod    = produ.procod 
               no-lock no-error.
    if avail ctpromoc
    then repeat:
    
        find bctpromoc where 
             bctpromoc.sequencia = ctpromoc.sequencia and
             bctpromoc.linha = 0
             no-lock no-error.
        if avail bctpromoc and 
                 bctpromoc.situacao = "L"
        then do:         
            vestvenda = ctpromoc.precosugerido.
            leave.
        end.
        find prev ctpromoc where
               ctpromoc.promocod  = 20     and
               ctpromoc.procod    = produ.procod 
               no-lock no-error.
        if not avail ctpromoc
        then leave.
    end.
    
    find categoria where categoria.catcod = produ.catcod no-lock.
    disp produ.catcod label "Dep"    
         categoria.catnom  format "x(12)" no-label with frame f1.

    find last movim where movim.procod = produ.procod and
                          movim.movtdc = 4
                          no-lock no-error.
                          
    find cestab where cestab.etbcod = setbcod and
                      cestab.etbnom begins "DREBES-FIL" and
                      cestab.etbcod <> 999 
                      no-lock no-error.
    if avail cestab
    then vestcusto = 0.
    else vestcusto = /*if avail movim then movim.movpc else*/ bestoq.estcusto.

    /*
    /* antonio - Custo da Substituicao Tributaria */
    assign v-icmsubst = 0
           v-custotal = 0.
    run Pi-acha-icm-substitu(output v-icmsubst).   
    assign vestcusto = vestcusto + v-icmsubst.
    /**/
    */
    def var par-bloq as dec.
    run bloq995.p (input  produ.procod,
                   output par-bloq ). 
    vdisponiv995 = vestatual995 - par-bloq.
    par-bloq = 0.
    run bloq900.p (input  produ.procod,
                       output par-bloq ).
    vdisponiv900 = vestatual900 - par-bloq.                   
    run reserv_ecom.p (input  produ.procod,
                       output vreserv_ecom).
    vdisponiv900 = vdisponiv900 - vreserv_ecom.
    
    if vdisponiv995 < 0 then vdisponiv995 = 0.
    if vdisponiv993 < 0 then vdisponiv993 = 0.
    display vestcusto when vestcusto > 0 
                            label "B.Custo"  format ">>,>>9.99" 
            bestoq.estvenda label "P.Venda"
            vestacao label "Estac."  
            sclase.clacod label "Sub-Classe" when avail sclase
            subcaract.carcod label "Carac" at 1    
            when avail subcaract
            vestilo          label "SubCarac" format "x(20)" 
  (vestatual  - vestatual900 - /*vestatual995 -*/ vestatual988 - vestatual500 
     - vest-outros-dep - vestatual981 - vestatual993)
                             label "Estloja" format "->>>>9"  colon 8
            vestatual993      label "Est993"
            pedidos_900      label "Pedidos" format "->>>>9"
            /*vestatual995      label "Est995" colon 54*/
            vestatual900      label "Est900" colon 54
            vreserv_ecom      label "Res ECOM"
            vestatual500      label "Est500" colon 8  
            vestatual988      label "Est988"
            vestatual981      label "Est981"
            vest-outros-dep   label "Out.Dep"
            vestatual         label "EstTotal"
             with frame f1 no-box.
    pause 0.    
    def var vestoq_depos like estoq.estatual.
    def var vreservas as dec.
    def var vdisponivel like vdisponiv900.
    run corte_disponivel.p (input  produ.procod,
                            output vestoq_depos, 
                            output vreservas, 
                            output vdisponivel).
    pedidos_900 = vreservas.
    vdisponiv900 = vdisponivel.
    estoq-indisponivel = 0.
    estoq-disponivel = 0.
    if vdisponiv900 < 0
    then estoq-indisponivel = vdisponiv900 * -1.
    else estoq-disponivel   = vdisponiv900.

    if produ.ind_vex
            then disp "VEX" to 4 with frame fdisponivel.
            
    display 
            estoq-disponivel colon 30
            estoq-indisponivel
            with frame fdisponivel color message side-label
                        width 80 no-box row 11 overlay.
                 
    if produ.ind_vex
            then disp "VEX" to 79 with frame fdisponivel.
            
 
    /*
    message "Todas filiais: " update sresp.
    */
    /*  Antonio  - Sol. 26330 */
    sresp = yes.
    for each tt-estab:
        assign tt-estab.ord = tt-estab.etbcod.
    end.
    /**/
        
    for each tt-estab,
        each estab where estab.etbcod = tt-estab.etbcod 
                         no-lock by tt-estab.ord:
        
        if not sresp
        then do:
            if estab.etbcod <> 01 and
               estab.etbcod <> 02 and
               estab.etbcod <> 03 and
               estab.etbcod <> 04 and
               estab.etbcod <> 06 and
               estab.etbcod <> 07 and
               estab.etbcod <> 08 and
               estab.etbcod <> 09 and
               estab.etbcod <> 13 and
               estab.etbcod <> 11 and
               estab.etbcod <> 12 and
               estab.etbcod <> 14 and
               estab.etbcod <> 16 and
               estab.etbcod <> 18 and
               estab.etbcod <> 19 and
               estab.etbcod <> 21 and 
               estab.etbcod <> 23 and
               estab.etbcod <> 25 and
               estab.etbcod <> 26 and
               estab.etbcod <> 27 and
               estab.etbcod <> 28 and
               estab.etbcod <> 29 and
               estab.etbcod <> 30 and
               estab.etbcod <> 31 and
               estab.etbcod <> 32 and
               estab.etbcod <> 33 and
               estab.etbcod <> 34 and
               estab.etbcod <> 35 and
               estab.etbcod <> 36 and
               estab.etbcod <> 37 and
               estab.etbcod <> 38 and
               estab.etbcod <> 39 and
               estab.etbcod <> 40 and
               estab.etbcod <> 41 and
               estab.etbcod <> 43 and
               estab.etbcod <> 44 and
               estab.etbcod <> 45 and
               estab.etbcod <> 46 and
               estab.etbcod <> 47 and
               estab.etbcod <> 49 and
               estab.etbcod <> 50 and
               estab.etbcod <> 51 and
               estab.etbcod <> 52 and
               estab.etbcod <> 53 and 
               estab.etbcod <> 54 and 
               estab.etbcod <> 55 and
               estab.etbcod <> 56 and
               estab.etbcod <> 57 and
               estab.etbcod <> 58 and
               estab.etbcod <> 59 and
               estab.etbcod <> 60 and
               estab.etbcod <> 61 and
               estab.etbcod <> 62 and
               estab.etbcod <> 63 and
               estab.etbcod <> 64 and
               estab.etbcod <> 65 and
               estab.etbcod <> 66 and
               estab.etbcod <> 67 and
               estab.etbcod <> 68 and
               estab.etbcod <> 69 and
               estab.etbcod <> 70 and
               estab.etbcod <> 71 and
               estab.etbcod <> 72 and
               estab.etbcod <> 73 and
               estab.etbcod <> 74 and
               estab.etbcod <> 75 and
               estab.etbcod <> 76 and
               estab.etbcod <> 77 and
               estab.etbcod <> 78 and
               estab.etbcod <> 79 and
               estab.etbcod <> 80 and
               estab.etbcod <> 81 and
               estab.etbcod <> 82 and
               estab.etbcod <> 96
            then next.
        end.
        
        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estab.etbcod = 900
        then do:
            reserva = 0. 
            vespecial = 0.  
            do vdata = today - 40 to today.
            for each liped where liped.pedtdc = 3
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                reserva = reserva + liped.lipqtd.
            end.

            /* pedido especial */

            for each liped where liped.pedtdc = 6 
                             and liped.predt  = vdata
                             and liped.procod = produ.procod no-lock,
                first pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum and
                                 pedid.pedsit = yes    and
                                 pedid.sitped = "P"
                                 no-lock.
                
                vespecial = vespecial + liped.lipqtd.
               end.
            end.
            
            if (estoq.estatual - vespecial) < 0
            then vespecial = 0.

            /*for each liped where liped.pedtdc = 3 and
                                 liped.procod = produ.procod and
                                 liped.lipsit = "A" no-lock.
                            
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.
                                                
                            
                if pedid.sitped = "R"
                then next.
                            
                reserva = reserva + liped.lipqtd.
            end.*/

            /****  antonio - sol 26212 - Reservas futuras *****/
                       assign vdata = today + 1.
            for each liped where liped.pedtdc = 3
                             and liped.predt  > vdata
                             and liped.procod = produ.procod no-lock:
                                         
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                reserva = reserva + liped.lipqtd.
            end.
            
            /*********** Reservas do E-Commerce **********/
            for each liped where liped.pedtdc = 8
                             and liped.predt  = today
                             and liped.procod = produ.procod no-lock:
  
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid
                then next.
                                                                 
                reserva = reserva + liped.lipqtd.
            end.
            /*** fim de reservas futuras - sol 26212 ***/    

            run disponivel.p (produ.procod, output vreservado).
            reserva = reserva + vreservado.
        end.           
         
        if estab.etbcod = 990 and
           estoq.estatual = 0
        then next.
        
        
        create wpro.
        assign wpro.etbcod = estab.etbcod
               wpro.etbnom = estab.etbnom
               wpro.munic  = estab.munic
               wpro.prounven = produ.prounven
               wpro.estvenda = estoq.estvenda
               wpro.estcusto = estoq.estcusto
               wpro.estatual = estoq.estatual
               wpro.estproper = estoq.estproper
               wpro.estprodat = estoq.estprodat.
    
        if wpro.etbcod = 995
        then do.
            run bloq995.p (input  produ.procod,
                           output wpro.wreserva ).
        end.
        else if wpro.etbcod = 900
        then do:
            run bloq900.p (input  produ.procod,
                            output wpro.wreserva ).
        end.
        else

            if wpro.etbcod = 900
            then wpro.wreserva = reserva + vespecial.
    end.

    find first wpro where wpro.etbcod = 900
                     no-lock no-error.
                    
    assign vdisponiv900 =  vestatual900 - (if avail wpro then wpro.wreserva 
                                                        else 0).

    disp vestatual900        
         pedidos_900
         vestatual993
         vestatual500
         vestatual988
       with frame f1.
    pause 0.    
    run corte_disponivel.p (input  produ.procod,
                            output vestoq_depos, 
                            output vreservas, 
                            output vdisponivel).
                            
    pedidos_900 = vreservas.
    vdisponiv900 = vdisponivel.
    vdisponiv900 = vdisponiv900 + vdisponiv993.
    estoq-indisponivel = 0.
    estoq-disponivel = 0.
    if vdisponiv900 < 0
    then estoq-indisponivel = vdisponiv900 * -1.
    else estoq-disponivel   = vdisponiv900.
    pause 0.
    display 
            estoq-disponivel colon 30
            estoq-indisponivel
            with frame fdisponivel color message side-label
                        width 80 no-box row 11 overlay.
    
    for each wpro.
        wpro.wreserva = 0.
    end.
    
    for each tt-reservas.
        find liped where recid(liped) = tt-reservas.rec_liped no-lock.
        find pedid of liped no-lock.
        find first wpro where wpro.etbcod = pedid.etbcod no-error.
        if avail wpro
        then wpro.wreserva = wpro.wreserva + liped.lipqtd.
    end.
    run pescoa.p.
end.

procedure ve-est:
    assign vestatual        = 0
           vest-outros-dep  = 0
           vint-ped-abertos = 0.

    for each estab no-lock:

        find estoq where estoq.etbcod = estab.etbcod and
                         estoq.procod = produ.procod no-lock no-error.
        if not avail estoq
        then next.
        
        if estab.etbcod = 900
        then do:
            /****************
            for each liped where liped.pedtdc = 3
                             and liped.procod = produ.procod no-lock:
                                         
                /**find first pedid use-index pedid2 
                           where pedid.pedtdc = liped.pedtdc and
                                 pedid.etbcod = liped.etbcod 
                                 no-lock no-error.**/
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                                 
                if not avail pedid 
                then next.

                if pedid.sitped <> "E" and
                   pedid.sitped <> "L"
                then next.
                
                /*                                                     
                vestatual = vestatual - liped.lipqtd.                  
                */                                                     
              
                vint-ped-abertos = vint-ped-abertos + liped.lipqtd.    
            
            end.
            ********************/
            /*for each liped where liped.pedtdc = 3 and
                                 liped.procod = produ.procod and
                                 liped.lipsit = "A" no-lock.
                            
                find pedid where pedid.etbcod = liped.etbcod and
                                 pedid.pedtdc = liped.pedtdc and
                                 pedid.pednum = liped.pednum no-lock no-error.
                if not avail pedid 
                then next.
                            
                if pedid.sitped = "R"
                then next.
                            
                vestatual = vestatual - liped.lipqtd.            
             /*   vestatual = vestatual +  vestatual500.*/                                
            end.
            */
        end.               

        

        /* Chamado 29901 Descontar depositos 991, 996 e 500 no estoque das lojas  */ 
    
        if estab.etbcod = 991 or
           estab.etbcod = 996 or
           estab.etbcod = 980 /* or
           estab.etbcod = 500   */
        then vest-outros-dep = vest-outros-dep + estoq.estatual.
        
        vestatual = vestatual + estoq.estatual.
        
        end.
           /*
        if estab.etbcod = 500 then
           vestatual = vestatual + estoq.estatual.
             */


end procedure.

Procedure Pi-acha-icm-substitu.

def output parameter p-icm-subst like plani.platot.
def var v-item like plani.protot.

find last movim where movim.movtdc = 4 and
                      movim.procod = produ.procod no-lock no-error.
if not avail movim then leave.

find first plani where plani.etbcod = movim.etbcod and
                       plani.placod = movim.placod and
                       plani.movtdc = movim.movtdc and
                       plani.pladat = movim.movdat
                       no-lock no-error.
if not avail plani then leave.

v-item = movim.movpc * movim.movqtm.
 
p-icm-subst = (v-item * plani.icmssubst) / plani.protot.

p-icm-subst = p-icm-subst / movim.movqtm.

end. 
