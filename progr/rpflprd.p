/************************************
*
*  rpflprd  - Produtos Faltantes 
*  Antonio Maranghello 28/06/2009
*
************************************/
 
{admcab.i}

def var recimp as recid.

def var reserva like estoq.estatual.
def var fila as char.
def var v-estoq-cd as dec.                                      
def var v-dispo-cd as dec.                                      
def var vetbcod like estab.etbcod.
def var vreserva like estoq.estatual.
def var vespecial like estoq.estatual.
def var varquivo as char.
def var vdata as date format "99/99/9999".
def var vdata1 as date format "99/99/9999".
def var vdata2 as date format "99/99/9999".
def var vforcod like forne.forcod.
def var vsubcod like clase.clacod.
def var vclacod like clase.clacod.
def var vest like estoq.estatual.
def temp-table tt-pro
    field etbcod like estab.etbcod
    field numero like pedid.pednum
    field data   like pedid.peddat
    field modcod like pedid.modcod
    field subcla like clase.clacod
    field clase  like clase.clacod 
    field procod like produ.procod
    field pronom like produ.pronom
    field fabcod like fabri.fabcod
    field fabnom like fabri.fabnom
    field estoq-cd     as int
    field dispo-cd     as int
    field lipqtd as   integer format "->>>,>>9"
    field lipsep as   integer format "->>>,>>9"
    index ipro etbcod
               numero
               modcod
               procod.

def buffer bclase for clase.
def buffer sclase for clase.

def var vexcel as log format "Sim/Nao".
def var ped-tipo as char.

do on error undo:

    for each tt-pro: 
        delete tt-pro. 
    end.
    
    assign vdata1 = today - 1
           vdata2 = today - 1 .
    update vetbcod at 2 label "Depositos" with frame f1 .
    if vetbcod <> 0
    then do:
        if vetbcod < 900 and vetbcod <> 0 and
            {conv_difer.i vetbcod} 
        then do:
            message "Deposito Invalido" view-as alert-box.
            undo, retry.
        end.
        find estab where estab.etbcod = vetbcod no-lock no-error.
        if avail estab then display estab.etbnom no-label with frame f1.
    end.
    else do:
        find first estab no-lock no-error.
        disp "Todos" @ estab.etbnom no-label with frame f1.
   end.
    update vforcod
           at 2 label "Fabricante" with frame f1 side-label width 80.

    if /*vfabcod*/ vforcod <> 0
    then do:
        find forne where forne.forcod = vforcod no-lock.
        
        find fabri where fabri.fabcod = forne.forcod no-lock.
        display fabri.fabnom format "x(20)" no-label with frame f1.
        
    end.
    else disp "Todos" @ fabri.fabnom format "x(20)" with frame f1.

    update vsubcod at 2 label "Sub-Classe" with frame f1.
    if vclacod <> 0
    then do:
        find sclase where sclase.clacod = vsubcod no-lock no-error.
        display sclase.clanom format "x(20)" no-label with frame f1.
    end.
    else disp "Todas" @ sclase.clanom with frame f1.
    
    update vclacod at 2 label "Classe" with frame f1.
    if vclacod <> 0
    then do:
        find clase where clase.clacod = vclacod no-lock no-error.
        display clase.clanom format "x(20)" no-label with frame f1.
    end.
    else disp "Todas" @ clase.clanom with frame f1.
 
    update vdata1 at 2 label "Data Inicial"
           vdata2 label "Data Final"
           with frame f1 side-labels width 80.

    if opsys = "unix" 
    then do: 
        varquivo = "/admcom/relat/rpflprd" + string(time).
        find first impress where impress.codimp = setbcod no-lock no-error. 
        if avail impress
        then do:
            run acha_imp.p (input recid(impress), 
                            output recimp).
            find impress where recid(impress) = recimp no-lock no-error.
            assign fila = string(impress.dfimp). 
        end.    
    end.
    else assign fila = ""
                varquivo = "l:\relat\rpflprd" + string(time).

    do vdata = vdata1 to vdata2 with frame fproces:
       
        for each pedid use-index 
                                pedsit where pedid.pedtdc = 3 and
                                pedid.sitped = "F" and
                                pedid.peddat = vdata                                                          no-lock:
                         
            disp    vdata no-label
                    pedid.pednum no-label with frame ff-proc centered .
            pause 0.
            
            for each liped of pedid 
                            where liped.etbcod = pedid.etbcod
                            and liped.pednum = pedid.pednum no-lock:


                if vetbcod <> 0 and vetbcod <> 993 and pedid.etbcod <> vetbcod  ~                then next.
                if vetbcod = 993 and liped.pedtdc <> 3 then next.
                                 
                find produ where produ.procod = liped.procod no-lock no-error.
                if not avail produ
                then next.

                if  vforcod <> 0 and produ.fabcod <> vforcod  then next.
                if  vsubcod <> 0 and produ.clacod <> vsubcod  then next.
                if  vclacod <> 0
                then do:
                  find first sclase where sclase.clacod = produ.clacod no-lock                                     no-error.
                  find first clase where clase.clacod = sclase.clasup no-lock
                                    no-error.
                  if avail clase and clase.clacod <> vclacod then next.                   
                end.

                /*
                if produ.catcod = 31 or
                   produ.catcod = 35 then.
                else next.
                */   
                
               find first tt-pro where  tt-pro.etbcod = pedid.etbcod and
                                        tt-pro.numero = pedid.pednum and
                                        tt-pro.modcod = pedid.modcod and
                                        tt-pro.procod = liped.procod 
                                         no-error.
                if not avail tt-pro
                then do:
                    create tt-pro.
                    assign 
                        tt-pro.etbcod = pedid.etbcod 
                        tt-pro.numero = pedid.pednum 
                        tt-pro.modcod = pedid.modcod 
                        tt-pro.data   = pedid.peddat
                        tt-pro.clase  = clase.clacod when avail clase
                        tt-pro.subcla = sclase.clacod when avail sclase
                        tt-pro.procod = liped.procod. 
                        
                    find forne where
                             forne.forcod = produ.fabcod no-lock no-error.
                
                    assign tt-pro.pronom = (if avail produ
                                            then produ.pronom
                                            else "").
                                            
                           tt-pro.fabcod = (if avail /*fabri*/ forne
                                            then /*fabri.fabcod*/
                                                 forne.forcod
                                            else 0).

                           tt-pro.fabnom = (if avail /*fabri*/ forne
                                            then forne.forfant 
                                            /*fabri.fabfant*/
                                            else "").
                 
                end.

                assign  
                    tt-pro.lipqtd = tt-pro.lipqtd + liped.lipqtd
                    tt-pro.lipsep = tt-pro.lipsep + liped.lipent.
                     
                v-estoq-cd = int(acha("ESTOQUE",liped.lipcor)).                                v-dispo-cd = int(acha("DISPONIVEL",liped.lipcor)).              
                if v-estoq-cd <> ? 
                then assign tt-pro.estoq-cd =  v-estoq-cd.
                else assign tt-pro.estoq-cd = 0.
 
                if v-dispo-cd <> ? 
                then assign tt-pro.dispo-cd =  v-dispo-cd.
                else assign tt-pro.dispo-cd = 0.

                /***    
                if pedid.pednum > 100000
                then tt-pro.autom = tt-pro.autom + liped.lipqtd.
                else tt-pro.manual = tt-pro.manual + liped.lipqtd. 
                ***/                      
                                      
            end. 
        end.
    end.
    
    vexcel = no.
    /*
    message "Arquivo para EXCEL ? " update vexcel.
    */
    find first tt-pro no-error.
    if not avail tt-pro
    then do :
        message "Nada Gerado com os Parametros informados" view-as alert-box.
        leave.
    end.

    disp "Gerando ....." with frame f-procf centered no-box.
    pause 0.
    if vexcel = no
    then do:
    {mdad.i
        &Saida     = "value(varquivo)"
        &Page-Size = "00 "
        &Cond-Var  = "170"
        &Page-Line = "00"
        &Nom-Rel   = ""rpflprd""
        &Nom-Sis   = """SISTEMA DE ESTOQUE"""
        &Tit-Rel   = """RELATORIO DE PRODUTOS FALTANTES -""
                        + "" PERIODO DE "" +
                         string(vdata1,""99/99/9999"") + "" A "" +
                         string(vdata2,""99/99/9999"") "
        &Width     = "170"
        &Form      = "frame f-cabcab"}

    for each tt-pro no-lock,
        first produ where produ.procod   = tt-pro.procod no-lock, 
        first sclase where sclase.clacod = produ.clacod no-lock,
        first clase where clase.clacod   = sclase.clasup no-lock
            break by clase.clacod
                  by sclase.clacod
                  by tt-pro.modcod :

        /* Calculo de estoques em Depositos */
        do :
                assign  vest = 0 .
                for each estoq where estoq.procod = tt-pro.procod
                                      no-lock:
                    if vetbcod <> 0 and estoq.etbcod <> vetbcod then next.
                    
                    /* novo igual pesco.p */
                    if (estoq.etbcod < 900 and {conv_difer.i estoq.etbcod})
                       or
                       (estoq.etbcod >= 900 and estoq.etbcod <> 990) 
                    then.
                    else next.
                    if estoq.etbcod = 990 then next.   
                    /**/

                    vest = vest + estoq.estatual.                        
                
                    /* antonio */
                    if estoq.etbcod = 993
                    then do:
                         assign vespecial = 0
                                vreserva  = 0.
                         do vdata = (vdata1 - 40)  to vdata2 :
                          /* anterior vdata1 to vdata2 */
                            for each liped where liped.pedtdc = 3
                                  and liped.procod = tt-pro.procod 
                                 and liped.predt  = vdata
                                 no-lock,
                                 first pedid where 
                                       pedid.etbcod = liped.etbcod and
                                       pedid.pedtdc = liped.pedtdc and
                                       pedid.pednum = liped.pednum :
                     
                                /** antonio **/                   
                                if pedid.sitped <> "E" and pedi.sitped <> "L" 
                                then next.
                                vreserva = vreserva   + liped.lipqtd.
                            end.
                            /* pedido especial */
                            for each liped where liped.pedtdc = 6 
                                 and liped.predt  = vdata
                                 and liped.procod = tt-pro.procod no-lock,
                                 first pedid where 
                                    pedid.etbcod = liped.etbcod and
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
                                     
                        vreserva = vreserva + vespecial .

                    end. /* estab = 993 */
                end. /* bloco estoq. */ 

                ped-tipo = "".
                if tt-pro.modcod = "PEDA"
                then ped-tipo = "Automatico".
                else if tt-pro.modcod = "PEDM"
                then ped-tipo = "Manual".
                else if tt-pro.modcod = "PEDR"
                then ped-tipo = "Reposicao".
                else if tt-pro.modcod = "PEDE"
                then ped-tipo = "Especial".
                else if tt-pro.modcod = "PEDP"
                   then ped-tipo = "Pendente".
                   else if tt-pro.modcod = "PEDO"
                       then ped-tipo = "Outra Filial".
                       else if tt-pro.modcod = "PEDF"
                          then ped-tipo = "Entrega Futura".
                          else if tt-pro.modcod = "PEDC"
                            then ped-tipo = "Comercial".
                            else if tt-pro.modcod = "PEDI"
                              then ped-tipo = "Ajuste Minimo".
                              else if tt-pro.modcod = "PEDX"
                                then ped-tipo = "Ajuste Mix".
 
                display tt-pro.data         column-label "Data"
                                            format "99/99/9999"
                        tt-pro.etbcod       column-label "Loja"
                                            format ">>9"
                        tt-pro.numero  column-label "N.Pedido"
                                             format ">>>>>>9"
                        ped-tipo             column-label "Tp.Pedido"
                                                        FORMAT "x(12)"
                        clase.clanom         column-label "Classe"
                                                        format "x(12)"
                        sclase.clanom        column-label "Sub-Clase"
                                                        format "x(12)"
                        tt-pro.procod        column-label "Produto"
                        tt-pro.pronom        column-label "Descricao"
                                                        format "x(30)"
                        tt-pro.fabnom  column-label "Fabricante" 
                                                        format "x(12)"
                        tt-pro.lipqtd   column-label "Qt.Pedida"   
                                        format "->>>>>9"
                             (total by sclase.clacod by clase.clacod)
                        tt-pro.lipsep   column-label "Qt.Separada"
                                        format "->>>>>9"
                             (total by sclase.clacod by clase.clacod)
                        (tt-pro.lipqtd - tt-pro.lipsep) column-label "Faltou" 
                                        format "->>>>9"
                             (total by sclase.clacod by clase.clacod)
                        tt-pro.estoq-cd  column-label "Estq CD"
                                        format "->>>>>>9"
                             (total by sclase.clacod by clase.clacod)
                         tt-pro.dispo-cd  column-label "Disp. CD"
                                        format "->>>>>>9"
                             (total by sclase.clacod by clase.clacod)
                        /* vest column-label "Est.Dep." 
                                         format "->>>>>>9" */
                        
                        /* (vest - vreserva) column-label "Est.CD "
                                        format "->>>>>>9" */
                        with frame f-pro width 170 down.
            end.

            if last-of(clase.clacod)
            then do:
                put skip(2).
            end.
        end.
     
    output close.
    
    if opsys = "UNIX"
    then do:
        run visurel.p(varquivo,"").
    end.
    else do:
        {mrod.i}
    end.    
    
    end.
    
end.


