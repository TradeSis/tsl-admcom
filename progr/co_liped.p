/* liped.p manutencao no liped */

{admcab.i}

def var par-rec as recid.
def input parameter par-recid-pedid as recid no-undo.
def input parameter par-recid-liped as recid no-undo.
def input parameter par-opc         as char.

def buffer          bliped      for liped.

def new shared temp-table ttliped  
    field recliped     as recid
    field lippreco     like liped.lippreco
    field lipqtd       like liped.lipqtd.

def var vlipqtd     like liped.lipqtd.
def var vperc       as   dec.
def var vtotal      like liped.lippreco label "Total".
def var vlippreco   like liped.lippreco.
/*def var vdescricao  like liped.descricao.*/
def var vlipdes     like liped.lipdes.
/*def var vlipacf     like liped.lipacf.
def var valiqipi    like produ.aliqipi.
def var vlipipi     like liped.lipipi.
def var vlipsubst   like liped.lipsubst.
def var vlipoutros  like liped.lipout.
def var vlipfrete   like liped.lipfrete.
def var vlipvrbpubl like liped.lipvrbpubl.*/
def var vlippercpub as dec format ">>9.99%".
def var vlippercdes as dec format ">>9.99%".
def var valifrete   as dec format ">>9.99%".
def var vi          as int.
def var vtipos      as char.
def var vpeddescricao as log init no.
def buffer sclase for clase.
def var vestilo  as char format "x(30)".
def var vestacao as char format "x(15)".

find pedid where recid(pedid) = par-recid-pedid no-lock.

find categoria of pedid no-lock no-error.
/*find tipped of pedid  no-lock.*/
find forne where forne.forcod = pedid.clfcod no-lock.

/***
/* Verificar quais tipo de pedidos pedem pedem descricao */ 
vtipos = paramsis("TIPPEDDESCRICAO").
if vtipos <> "?" then  do:
   do vi = 1 to num-entries(vtipos).
      if tipped.pedtdc = int(entry(vi, vtipos)) then do:
         vpeddescricao = yes.
         leave.
      end.   
   end.
end.      
***/

    form           
/*                vmercacod          colon 12*/
                  produ.procod    colon 12
                  produ.pronom     no-label format "x(26)"
                  produ.proindice  no-label
                  /*
                  produ.refer      no-label
                    */                   
                  sclase.clacod label "Sub-Clase" colon 12
                  sclase.clanom no-label
                  vestacao label "Estacao" colon 12
                  subcaract.carcod label "Cod.Carac." colon 12
                  vestilo label "Sub-Carac."              
                  skip(1)
                  vlipqtd          colon 12
                  vlippreco        colon 36
                  
/***
                  vlippercdes      colon 19 label "Perc.Desc"
                  vlipdes          colon 36
***/
                  vtotal           colon 61
                  skip(1)
/***
                  valifrete        colon 12 label "Aliq.Frete"
                  vlipfrete        colon 36
                  vlipacf          colon 61 label "Acr Fin"***/
                  vtotal           colon 61
                  skip(1)
/***
                  valiqipi         colon 12
                  vlipipi          colon 61
                  vlipoutros       colon 12
                  vlipsubst        colon 61
                  skip(1)
                  vlippercpub      colon 18 label "Verba Publicidade"
                  vlipvrbpubl      no-label
***/
       with frame f-liped centered row 10
                         width 78 down side-labels overlay.

/***
if par-recid-liped = ? /* Inclusao */
then do:
    hide frame f-liped no-pause.
    do with frame f-liped on error undo.
        update vmercacod
            help "ENTER - Cadastra".
      /*
        {validame.i vmercacod}
      */
     
    if vmercacod = "0" or vmercacod = ""
    then do:   
        run cad_produman.p (input "INC",
                                    input tipped.tprocod,
                                    input 0,
                                    input pedid.clfcod,
                                    0,
                                    input-output par-rec). 
        find produ where recid(produ) = par-rec no-lock no-error.
        if not avail produ then next.
        vmercacod = produ.refer.
        disp produ.refer @ vmercacod.
    end.

        /*************************INFORMA€OES DO PROGRAMA******************************
***** Nome do Programa             : validame.i
***** Diretorio                    : gener
***** Autor                        : Claudir Santolin
***** Descri‡ao Abreviada da Funcao: Validacao de input do Codigo do produto
***** Data de Criacao              : 14/09/2000

                                ALTERACOES
***** 1) Autor     :
***** 1) Descricao : 
***** 1) Data      :

***** 2) Autor     :
***** 2) Descricao : 
***** 2) Data      :

***** 3) Autor     :
***** 3) Descricao : 
***** 3) Data      :
*****************************************************************************/

if length(vmercacod) > 10 
then do:
    
    find first produ where 
               produ.proean = vmercacod no-lock no-error.
    if  avail produ
    then.
    else do:
        find first produ where
                   produ.proean2 = vmercacod no-lock no-error.
        if avail produ
        then.
        else do:
            find first produ where
                       produ.proean3 = vmercacod no-lock no-error.
            if avail produ
            then.
            else do: 
                find first produ where 
                           produ.proant = vmercacod  no-lock no-error.
                if avail produ 
                then.
                else do:
                    bell. 
                    message color red/withe
                    "Produto " vmercacod " nao cadastrado "
                    view-as alert-box title " Atencao!! ".
                    next.
                end.
            end. 
        end.
    end.              
end.
else do:
    find first produ where
               produ.procod = int(vmercacod) no-lock no-error.
    if avail produ 
    then.
    else do: 
        find first produ where 
                   produ.proant = vmercacod  no-lock no-error.
        if avail produ 
        then.
        else do:
            bell. 
            message color red/withe
            "Produto " vmercacod " nao cadastrado "
            view-as alert-box title " Atencao!! ".
            next.
        end.
    end. 
end.    
if avail produ and produ.prosit = no
then do:
     bell. 
     message color red/withe
            "Produto " vmercacod " esta desativado "
            view-as alert-box title " Atencao!! ".
     if paramsis("USAPRODUTODESATIVADO") = "N" then
        next.
end.
        
        /*
        prompt-for produ.procod .
        /*{buspro.i f-liped} */
        find produ where produ.procod = input produ.procod no-lock no-error.
        if not avail produ
        then undo.
        */
        
        find tprodu of produ no-lock.
        if produ.tprocod <> tipped.tprocod then do:
           message "Tipo do produto e´ de " tprodu.tpronom
                   view-as alert-box.
           undo.
        end.
        disp produ.procod 
             produ.pronom
             /*
             produ.refer format "x(10)"
             */
             /*produ.loccod*/ .
        
        find first bliped of pedid where 
                bliped.procod = produ.procod
                no-lock no-error.
        if avail bliped
        then do:
            sresp = no.
            message "Produto Ja Consta na Ordem.".
            if not sresp
            then undo.
        end.

        if true
        then do:
            if produ.gracod = 0 then 
               update vlipqtd validate(vlipqtd <> 0,
                            "Quantidade digitada nao pode ser ZERO").
            else
               disp vlipqtd. 

            assign
               vtotal = vlipqtd * vlippreco            
               vlippreco = produ.ctonota
               valiqipi = produ.aliqipi.
              
            disp vtotal .
            
            update vlippreco validate(vlippreco <> 0,
                        "Preco digitado nao pode ser ZERO ").
            
            hide message no-pause.
            /*
            run gerprom.p (input recid(produ),
                           input 26,
                           input today,
                           output vperc).
            */

            do on error undo.
                update  vlippercdes
                        validate(vlippercdes < 100,"Percentual Invalido"). 
                vlipdes = ((vlippreco * vlipqtd)) * 
                              (vlippercdes / 100).                
                update vlipdes validate(vlipdes < vlipqtd * vlippreco,
                "Desconto deve ser menor que " + string(vlipqtd * vlippreco,
                                ">>>,>>9.99") ). 
            end.
            vtotal = (vlipqtd * vlippreco) - vlipdes.
            disp vtotal.
 
            if not vpeddescricao then do.
               update valifrete.
               if valifrete entered then
                  vlipfrete = ((vlippreco * vlipqtd) - vlipdes) * 
                              (valifrete / 100).

                update vlipfrete vlipacf valiqipi.
                if valiqipi > 0 and vlipipi = 0 or valiqipi entered
                then
                    vlipipi = ((vlippreco * vlipqtd) - vlipdes) *
                                    (valiqipi / 100).
                update vlipipi
                       vlipoutros
                       vlipsubst.
                do on error undo.
                    update vlippercpub                                                     validate(vlippercpub < 100,"Percentual Invalido").
                    vlipvrbpubl = ((vlippreco * vlipqtd) - vlipdes ) * 
                                  (vlippercpub / 100).
                    update vlipvrbpubl.
                end.
            end.
            
            if vpeddescricao then
               update text(vdescricao) with no-label frame f-descricao 
               title " Descricao do servico "  row 15 overlay.
        end.
        create liped.
        assign
            liped.etbped    = pedid.etbped
            liped.pedtdc    = tipped.pedtdc
            liped.procod    = produ.procod
            liped.lipsit    = "A"
            liped.pednum    = pedid.pednum
            liped.lipqtd    = vlipqtd
            liped.lippreco  = vlippreco
            liped.lipipi    = vlipipi
            liped.lipdes    = vlipdes
            liped.lipacfin  = vlipacf
            liped.lipsubst  = vlipsubst
            liped.lipout    = vlipoutros
            liped.lipfrete  = vlipfrete
            liped.lipvrbpubl   = vlipvrbpubl
            liped.descricao[1] = vdescricao[1]
            liped.descricao[2] = vdescricao[2]
            liped.descricao[3] = vdescricao[3]. 
        sretorno = string(recid(liped)).    
        
    end.
    hide frame f-liped no-pause.
    run co/oclipprg.p (input recid(liped)).
end.
***/

if par-recid-liped <> ? /* alteracao/consulta */
then do with frame f-liped on error undo.
    find liped where recid(liped) = par-recid-liped no-lock.
    find produ of liped no-lock.

    vestacao = "".
    vestilo  = "".
    find first sclase where sclase.clacod = produ.clacod no-lock no-error.
    if avail sclase
    then find first clase where clase.clacod = sclase.clasup no-lock no-error.

    find estac where estac.etccod = produ.etccod no-lock no-error.
    if avail estac
    then vestacao = estac.etcnom.

    find first procaract where procaract.procod = produ.procod
        no-lock no-error.
    if avail procaract
    then do:
        find first subcaract where subcaract.subcod = procaract.subcod
                                no-lock no-error.
        if avail subcaract
        then vestilo = subcaract.subdes.
    end.

        disp produ.procod 
             produ.pronom
             produ.proindice
             /***produ.refer @ vmercacod***/
             sclase.clacod when avail sclase
             sclase.clanom when avail sclase
             vestacao
             subcaract.carcod column-label "Cod.Carac." when avail subcaract
             vestilo  column-label "Sub-Carac.".

        assign
           vlipqtd    = liped.lipqtd
           vlippreco  = liped.lippreco
           vlippreco  = liped.lippreco
/***           vlipipi    = liped.lipipi***/
           vlipdes    = liped.lipdes
           vtotal     = (vlipqtd * vlippreco) - vlipdes
/***           vlipacf    = liped.lipacfin
           vlipsubst  = liped.lipsubst
           vlipoutros = liped.lipout
           valifrete  = if liped.lipfrete > 0
                        then liped.lipfrete * 100 / 
                             ((vlippreco * vlipqtd) - vlipdes)
                        else 0
/* perc desc */
           vlippercdes = if liped.lipdes > 0
                         then liped.lipdes * 100 / 
                              ((vlippreco * vlipqtd))
                         else 0***/

/**/
/* perc vb publi */                       
/***           vlippercpub = if liped.lipvrbpubl > 0
                         then liped.lipvrbpubl * 100 / 
                              ((vlippreco * vlipqtd) - vlipdes)
                         else 0
/**/
           vlipfrete  = liped.lipfrete
           vlipvrbpubl   = liped.lipvrbpubl
           vdescricao[1] = liped.descricao[1]
           vdescricao[2] = liped.descricao[2]
           vdescricao[3] = liped.descricao[3]***/.
              
/***        valiqipi = vlipipi / vtotal * 100.***/

        disp vlipqtd
             vlippreco
           /***  valiqipi
             vlipipi
             vlipdes    vlippercdes
             vlipacf
             vlipsubst
             vlipoutros
             valifrete
             vlipfrete***/
             vtotal 
/***             vlipvrbpubl vlippercpub***/.

/***
        if liped.funcod-can > 0
        then do.
            find func where func.funcod = liped.funcod-can no-lock no-error.
            pause 0.
            disp liped.funcod-can colon 13 func.funape no-label 
                 liped.data-can  
                 string(liped.hora-can, "hh:mm") no-label
                 with frame f-canc width 78 no-box row 21 side-labels 
                            overlay  centered.
***/
        end.

        if par-opc = "Con"
        then do:
            pause.
            leave.
        end.

        update vlippreco validate(vlippreco <> 0,
                        "Preco digitado nao pode ser ZERO ").
            
        hide message no-pause.
            do on error undo.
                update  vlippercdes
                        validate(vlippercdes < 100,"Percentual Invalido"). 
                vlipdes = ((vlippreco * vlipqtd)) * 
                              (vlippercdes / 100).                
                update  vlipdes validate(vlipdes < vlipqtd * vlippreco,
                   "Desconto deve ser menor que " + string(vlipqtd * vlippreco,
                                ">>>,>>9.99") ). 
            end.
            vtotal = (vlipqtd * vlippreco) - vlipdes.
            disp vtotal.
 
/***
            if not vpeddescricao
            then do.
               update valifrete.
               if valifrete entered then
                  vlipfrete = ((vlippreco * vlipqtd) - vlipdes) * 
                              (valifrete / 100).

                update vlipfrete vlipacf valiqipi.
                if valiqipi entered
                then
                    vlipipi = ((vlippreco * vlipqtd) - vlipdes) *
                                    (valiqipi / 100).
                update vlipipi
                       vlipoutros
                       vlipsubst.
                do on error undo.
                    update vlippercpub                                                                     validate(vlippercpub < 100,"Percentual Invalido").
                    vlipvrbpubl = ((vlippreco * vlipqtd) - vlipdes ) * 
                                  (vlippercpub / 100).
                    update vlipvrbpubl.
                end.
            end.
            
            if vpeddescricao then
               update text(vdescricao) with no-label frame f-descricao 
               title " Descricao do servico " col 15.
***/

         find liped where recid(liped) = par-recid-liped exclusive.
         assign
            liped.lippreco  = vlippreco
/***            liped.lipipi    = vlipipi***/
            liped.lipdes    = vlipdes
/***            liped.lipacfin  = vlipacf
            liped.lipsubst  = vlipsubst
            liped.lipout    = vlipoutros
            liped.lipfrete  = vlipfrete
            liped.lipvrbpubl   = vlipvrbpubl
            liped.descricao[1] = vdescricao[1]
            liped.descricao[2] = vdescricao[2]
            liped.descricao[3] = vdescricao[3]***/.
/*    end.*/
/*end.*/
hide  frame f-liped no-pause.
hide  frame f-descricao no-pause.
