
{admcab.i}

/*
def var /* input parameter */ vopc      as log format "Fechamento/Mensal".
                                vopc = no.
*/                             
   
def buffer cmovim for movim.
def input parameter vopc      as log format "Fechamento/Mensal".

def var varquivo as char.
def var vdti    as date format "99/99/9999".
def var vdtf    as date format "99/99/9999".
def var vetbi   like estab.etbcod.
def var vcatcod     like produ.catcod.
def var vicms      as dec label "%ICMS".
def var vpis       as dec label "%PIS".
def var vcofins    as dec label "%COFINS".
def var vanalitico as log label "Analitico/Sintetico"
                   format "Analitico/Sintetico" init yes.
def var vsoma     as char format "x(1)" initial "N"
                         label "Opcao ICMS". 

def var vmovqt-5 like estoq.estatual.
def var vmovpc-5 like estoq.estcusto.
def var vmovqt-4 like estoq.estatual.
def var vmovpc-4 like estoq.estcusto.
def var vmovqt-12 like estoq.estatual.
def var vmovpc-12 like estoq.estcusto.
def var vmovqt-13 like estoq.estatual.
def var vmovpc-13 like estoq.estcusto.

def var vmes like hiest.hiemes.
def var vano like hiest.hieano.
def var v-desc as char.

def var v-i as int.

def var aux-custo as dec. 
def var aux-icms  as dec.
def var aux-liq  as dec. 
def var aux-pis  as dec.  
def var aux-cofins  as dec.
def var aux-econt   as dec.

def var tetb-custo as dec. 
def var tetb-icms  as dec.
def var tetb-liq  as dec. 
def var tetb-pis  as dec.  
def var tetb-cofins  as dec.
def var tetb-econt   as dec.

def var tmov-custo as dec. 
def var tmov-icms  as dec.
def var tmov-liq  as dec. 
def var tmov-pis  as dec.  
def var tmov-cofins  as dec.
def var tmov-econt   as dec.

def var vmapicm     as dec.
def var vmapvda     as dec.
def var vlimicm     as dec.
def var vlimvda    as dec.
def var vfim5     as log .
def var vmap12   as dec.
def var vend12   as dec.
def var vmapsub as dec.
def var vendsub as dec.
def var aux-uf as char.


def var vpronom like produ.pronom.

def buffer bmovim for movim.

def temp-table tt-custo     
    field movtdc as int 
    field etbcod as int COLUMN-Label "FIL"
    field estcusto like estoq.estcusto   COLUMN-Label "CUSTO"
    field alipis as dec 
    field cusicm      like estoq.estcusto  COLUMN-Label "ICMS"
    field cusliq like estoq.estcusto      COLUMN-Label "CUSTO LIQ"
    field cuspis like estoq.estcusto      COLUMN-Label "PIS"
    field cuscofins like estoq.estcusto    COLUMN-Label "COFINS"
    field cuscont  like estoq.estcusto    COLUMN-Label "EST.CONTABIL"
    field procod    like estoq.procod   
    field estatual  like estoq.estatual
    index ind1 is primary unique
        etbcod
        procod
        movtdc
        alipis.

def temp-table tt-estab
       field etbcod as int
       index ind1 etbcod.

def stream stela.        

def var vmovtdc like tipmov.movtdc.
def buffer btipmov for tipmov.
form                   
    skip(1)
    vetbi  label   "Filial"  colon 20
    v-desc no-label format "x(25)"
    vmes  label     "Mes"    colon 20
    vano  label     "Ano"    colon 20
    vmovtdc label "Tipo de movimento" colon 20
    btipmov.movtnom no-label
    vanalitico colon 20
    vsoma      colon 20 "A=Somar; D=Subtrair; N=Nenhum"
    with frame f-etb centered 1 down side-labels title "Dados Iniciais" 
                     color white/bronw row 3  width 70.
    
find first tt-custo no-lock NO-ERROR.
form tt-custo.etbcod format ">>9" column-label "Fil"
     tt-custo.estatual format "->>>>>,>>9"
     tt-custo.procod format ">>>>>>>9" column-label "PRODUTO"
     vpronom column-label "PRODUTO"  format "x(20)"
     tt-custo.alipis no-label format ">>9.99"
     aux-custo    format "->>>,>>>,>>9.99" column-label "CUSTO"
     aux-icms    format "->,>>>,>>9.99"   column-label "ICMS"
     aux-liq      format "->>>,>>>,>>9.99" column-label "CUSTO S/ICMS"
     aux-pis      format "->,>>>,>>9.99"   column-label "PIS"
     aux-cofins   format "->,>>>,>>9.99"   column-label "COFINS"
     aux-econt    format "->>>,>>>,>>9.99" column-label "EST.CONTABIL"  
             with frame f-imp width 168 down.

vetbi = 1.

vmes = month(today).
vano = year(today).

if vopc 
then assign vetbi = 1
            vmes = month(today)
            vano = year(today).
else assign vetbi = 900
            vmes = month(today)
            vano = year(today).

def var vconsolidado as log format "Sim/Nao".

def temp-table tt-produ 
    field procod like produ.procod
    index i1 procod.

repeat:
    for each tt-custo:
        delete tt-custo.
    end.
    release tt-custo.
    
    update vetbi
           with frame f-etb.
    if vetbi = 0
    then v-desc = "Geral".
    else do:
         find estab where estab.etbcod = vetbi no-lock no-error.
         if not avail estab then next.
         v-desc = estab.etbnom.
         
    end.
    disp v-desc 
         vmes
         vano with frame f-etb. 
    
    
    if vetbi = 0
    then vanalitico = no.
    else vanalitico = yes. 
         
    if vopc = no
    then do on error undo. 
         update vmes
                vano with frame f-etb.
         if vmes = 0 or vmes > 12 or vano = 0
         then do:
              message "Mes/Ano tem informação obrigatória".
              pause 3.
           undo, retry.
        end.
    end.
    do on error undo:
        update vmovtdc with frame f-etb.
        if vmovtdc > 0
        then find btipmov where btipmov.movtdc = vmovtdc no-lock.
    end.
   update vanalitico
          vsoma with frame f-etb.

   if not vanalitico
   then do:
        vconsolidado = no.
        message "Relatorio consolidado? " update vconsolidado.
        
   end.     
   assign vdti = date(vmes,1,vano)
          vdtf = date(month(date(month(vdti),
                      5,
                    year(vdti)) + 30),1,year(date(month(vdti),5,year(vdti))
                         + 30)) - 1. 
  if vopc = no
  then assign vpis = 1.65
              vcofins = 7.6.
  else assign vpis = .65
              vcofins = 3. 

  output stream stela to terminal.

  for each tt-estab: delete tt-estab. end.
   
  for each estab  where if vetbi = 0 
                         then true
                     else (estab.etbcod = vetbi) 
                     no-lock:
        if vetbi =  0
        then . /* if estab.etbcod = 22 or 
                estab.etbcod > 995 then next.
                */
                     
        create tt-estab.
        assign tt-estab.etbcod = estab.etbcod.             
   end.

  assign v-i =  0
         vmapicm = 0
         vmapvda = 0
         vlimicm = 0
         vlimvda = 0
         vmap12 = 0
         vmapsub = 0
         vend12 = 0
         vfim5 = no.
    
   if vmovtdc = 0 or
      vmovtdc = 5
   then   
   for each tt-estab no-lock,
       each mapctb where mapctb.etbcod = tt-estab.etbcod and
                         mapctb.datmov >= vdti        and
                         mapctb.datmov <= vdtf        and
                         mapctb.ch2 <> "E" 
                         no-lock:

        assign vmapicm = vmapicm  + 
                    ( ( (mapctb.t02 * 0.705889) + 
                        (mapctb.t01)) * 0.17 +
                         mapctb.t03 * 0.07)
               vmap12 = vmap12 + mapctb.t02 + mapctb.t03 
               vmapsub = vmapsub + mapctb.vlsub
               vmapvda = vmapvda + (mapctb.t01 + 
                                   mapctb.t02 +
                                   mapctb.t03 +
                                   mapctb.vlsub ) .
    end.

    for each tt-produ: delete tt-produ. end.
    if vmovtdc > 0
    then run sel-produto.
    for each produ no-lock:
       if vmovtdc > 0 and
                 not can-find(tt-produ where tt-produ.procod = produ.procod)
       then next.          
       
       /*
       if vmovtdc > 0 and
          not can-find(cmovim use-index datsai
                       where    cmovim.procod = produ.procod and
                                cmovim.etbcod = tt-estab.etbcod and
                                cmovim.movtdc = vmovtdc and
                                cmovim.movdat >= vdti   and
                                cmovim.movdat <= vdtf
                                )
       then next.
       */                     
       v-i = v-i + 1 .   /* if v-i > 10000 then leave. */

       run busca-ali.

       find last movim where movim.procod = produ.procod
                               and movim.movtdc = 4
                               and movim.movdat <= vdtf
                            no-lock no-error.
      
       if v-i modulo 100 = 0
       then do: 
            disp /* stream stela */ produ.procod  format ">>>>>>>>>>9" 
                  v-i format ">>>>>>9" Label "Lidos"
                    with frame fffpla 
                 centered color white/red.
            pause 0.

       end. 
      
       if vopc = yes
       then do:
            for each tt-estab no-lock,
              first  estoq fields (estatual estcusto)
                           where estoq.procod = produ.procod
                             and estoq.etbcod = tt-estab.etbcod
                             NO-LOCK .
               if avail estoq and estoq.estatual > 0
               then run p-grava-tt(input 0,
                               input estoq.estatual, 
                               input estoq.estcusto).
            end.                   
       end.
       else do:
                assign vmovqt-4 = 0
                       vmovqt-5 = 0
                       vmovqt-12 = 0
                       vmovqt-13 = 0
                       vmovpc-4 = 0 
                       vmovpc-5 = 0
                       vmovpc-12 = 0
                       vmovpc-13 = 0
                       aux-uf = "".

                for each tipmov no-lock:
                    if tipmov.movtdc <> 5 and
                       tipmov.movtdc <> 12 /* and tipmov.movtdc <> 13 */
                    then next.
                    
                    if vmovtdc > 0 and
                       tipmov.movtdc <> vmovtdc
                    then next.   

                    for each bmovim use-index datsai
                                where bmovim.procod = produ.procod 
                                  and bmovim.movtdc = tipmov.movtdc
                                  and bmovim.movdat >= vdti 
                                  and bmovim.movdat <= vdtf
                            no-lock,
                    first tt-estab where 
                          tt-estab.etbcod = bmovim.etbcod no-lock :
                    assign
                    vmovqt-4 = 0
                       vmovqt-5 = 0
                       vmovqt-12 = 0
                       vmovqt-13 = 0
                       vmovpc-4 = 0 
                       vmovpc-5 = 0
                       vmovpc-12 = 0
                       vmovpc-13 = 0
                       aux-uf = "".
   
                    if bmovim.movtdc = 5 or bmovim.movtdc = 12
                    or bmovim.movtdc = 13
                    then assign vicms = bmovim.MovAlICMS.
                    else do:
                         find plani where plani.etbcod = bmovim.etbcod
                                      and plani.movtdc = bmovim.movtdc
                                      and plani.placod = bmovim.placod
                                      and plani.pladat = bmovim.movdat
                                      no-lock no-error.
                         IF not AVAIL plani
                         then next.
                         if plani.modcod = "CAN"
                         then next.
                         if plani.opccod <> 2102 and
                            plani.opccod <> 1102
                         then next.
                           
                         if plani.numero = 0
                         then next.
                    
                         if plani.emite = 5027
                         then next.
                         
                         find forne where forne.forcod = plani.emit 
                                    no-lock no-error.  
                         if avail forne  
                         then if aux-uf <> "AM"
                              then assign aux-uf = forne.ufecod.  

                         /* if not avail forne or
                            forne.ufecod = "RS" */
                            
                         if aux-uf = "RS"    
                         then vicms = 17.
                         else vicms = 12.

                         assign vmovqt-4 = vmovqt-4 + bmovim.movqt
                                vmovpc-4 = vmovpc-4 + 
                                          (bmovim.movpc * bmovim.movqt).
                    end.
                    if bmovim.movtdc = 12 /* "Devolucao */
                    then assign vmovqt-12 = vmovqt-12 + bmovim.movqt
                                vmovpc-12 = vmovpc-12 + 
                                           (bmovim.movpc * bmovim.movqt).
                                           
                    if bmovim.movtdc = 13 /* "Devolucao compra */
                    then assign vmovqt-13 = vmovqt-13 + bmovim.movqt
                                vmovpc-13 = vmovpc-13 + 
                                           (bmovim.movpc * bmovim.movqt).
                                           
                    if bmovim.movtdc = 5  /* saida */
                    then assign vmovqt-5 = vmovqt-5 + bmovim.movqt
                                vmovpc-5 = vmovpc-5 + 
                                          (bmovim.movpc * bmovim.movqt).
                if vmovqt-12 > 0
                then run p-grava-tt(input 12,
                                    input vmovqt-12, 
                                    input vmovpc-12).
                if vmovqt-13 > 0
                then run p-grava-tt(input 13,
                                    input vmovqt-13, 
                                    input vmovpc-13).
                                    
                if vmovqt-5 > 0
                then  run p-grava-tt(input 5,
                                         input vmovqt-5, 
                                         input vmovpc-5).
                if vmovqt-4 > 0
                then run p-grava-tt(input 4,
                                    input vmovqt-4, 
                                    input vmovpc-4).
                end.
                end.
        end. 
  end.
  def var vtotpro like plani.platot.
  def var aux-movpc as dec. 
  def var vliga as log .
  if vopc = no
  then do:
       DEF VAR VXY AS DEC.
       def var xxx as dec.

       /* devolução de compra */

       if vmovtdc = 13
       then
       for each tt-estab no-lock,  
            each plani where plani.etbcod = tt-estab.etbcod and
                             plani.emite  = tt-estab.etbcod and
                             plani.movtdc = 13 and
                             plani.datexp >= vdti and
                             plani.datexp <= vdtf no-lock:
               
               if plani.modcod = "CAN"
               then next.              
               vtotpro = 0.
               for each bmovim where bmovim.etbcod = plani.etbcod
                            and bmovim.placod = plani.placod
                            and bmovim.movtdc = plani.movtdc
                            and bmovim.movdat = plani.pladat
                            no-lock.
                            
                     find first produ where produ.procod = bmovim.procod
                                no-lock no-error.
                     if not avail produ 
                     then find first produ where produ.procod = 360
                                no-lock no-error.

                     assign vmovqt-13 = bmovim.movqt
                            vmovpc-13 = (bmovim.movpc * bmovim.movqt)
                            vicms = bmovim.movalicm.

                     assign vtotpro = vtotpro + vmovpc-13
                            aux-movpc = bmovim.movpc.
      
                     if vtotpro > plani.platot
                     then assign vmovpc-13 = vmovpc-13 - 
                                          (vtotpro - plani.platot).
                  
                     run p-grava-tt(input 13,
                                   input vmovqt-13, 
                                   input vmovpc-13).
                     
                     if vtotpro > plani.platot
                     then leave.
                         
               end. 
               if vtotpro < plani.platot
               then do:
                   if aux-movpc = 0 then aux-movpc = 1.
                   vmovqt-13 = round((plani.platot - vtotpro) / aux-movpc,0).
                   vmovpc-13 = (plani.platot - vtotpro).
 
                   if not avail produ 
                   then find first produ where produ.procod = 360
                                no-lock no-error.
                   
                  run p-grava-tt(input 13,
                                   input vmovqt-13, 
                                   input vmovpc-13).
               end.                  
        end.
       /* entradas */
       if vmovtdc = 4
       then
       for each tipmov where movtdc = 4 no-lock:
           for each tt-estab,
               each fiscal where fiscal.desti = tt-estab.etbcod   and
                              fiscal.movtdc = tipmov.movtdc and  
                              fiscal.plarec >= vdti    and
                              fiscal.plarec <= vdtf no-lock:
                              
               if fiscal.opfcod <> 2101 and
                  fiscal.opfcod <> 1101 and 
                  fiscal.opfcod <> 2102 and 
                  fiscal.opfcod <> 1102 
                  then next.   
                          
               find first plani where plani.etbcod = fiscal.dest
                            and plani.emite  = fiscal.emite   
                            and plani.movtdc = tipmov.movtdc  
                            and plani.serie  = fiscal.serie   
                            and plani.numero = fiscal.numero 
                            no-lock no-error.
               if not avail plani
               then find first plani where plani.etbcod = fiscal.dest
                            and plani.emite  = fiscal.emite 
                            and plani.movtdc = 28 
                            and plani.serie  = fiscal.serie 
                            and plani.numero = fiscal.numero 
                             no-lock no-error.
               if not avail plani  
               then find first plani where plani.etbcod = fiscal.dest 
                                     and plani.emite  = fiscal.emite 
                                     and plani.movtdc = 15 
                                     and plani.serie  = fiscal.serie 
                                     and plani.numero = fiscal.numero 
                                             no-lock no-error.
               if not avail plani
               then find first plani where plani.etbcod = fiscal.dest 
                            and plani.emite  = fiscal.emite 
                            and plani.movtdc = 23 
                            and plani.serie  = fiscal.serie 
                            and plani.numero = fiscal.numero 
                             no-lock no-error.
                             

               if not avail plani
               then do:
             /*     disp "Nao existe:"
                       fiscal.platot (total) fiscal.emite fiscal.serie 
                           fiscal.numero fiscal.dest.
               */            
                  next. 

               end.

               if plani.modcod = "CAN"
               then next.
                VXY = VXY + pLANI.PLATOT.
                /*             
                disp plani.etbcod plani.pladat plani.dtinclu 
                     vxy format ">>>,>>>,>>9.99" with frame fx1. pause 0.
                  */        
                if plani.numero = 0
                then next.
                    
                if plani.emite = 5027
                then next. 
                         
                find forne where forne.forcod = plani.emit 
                                    no-lock no-error.  
                IF PLANI.MOVTDC <> 13
                then do:
                         if avail forne  
                         then /* if aux-uf <> "AM"
                              then */ assign aux-uf = forne.ufecod.  

                         if aux-uf = "RS"    
                         then vicms = 17.
                         else vicms = 12.
                end.


               assign vtotpro = 0
                      vliga = no.
              
               for each bmovim where bmovim.etbcod = plani.etbcod
                            and bmovim.placod = plani.placod
                            and bmovim.movtdc = plani.movtdc
                            and bmovim.movdat = plani.pladat

                            no-lock.
                            
                     find first produ where produ.procod = bmovim.procod
                                no-lock no-error.
                     if not avail produ 
                     then find first produ where produ.procod = 360
                                no-lock no-error.

                     assign vmovqt-4 = bmovim.movqt
                            vmovpc-4 = (bmovim.movpc * bmovim.movqt)
                                       /*  - (bmovim.movdes * bmovim.movqtm)
                                       */
                                       .
                     assign vtotpro = vtotpro + vmovpc-4
                            aux-movpc = bmovim.movpc.
      
                     if vtotpro > plani.platot
                     then assign vmovpc-4 = vmovpc-4 - (vtotpro - plani.platot).
                  
                     run p-grava-tt(input (if plani.movtdc = 13 then 13
                                        else 4),
                                   input vmovqt-4, 
                                   input vmovpc-4).
                    
                     xxx = xxx + vmovpc-4.               
                     
                     if vtotpro > plani.platot
                     then leave.
                         
               end. 
               if vtotpro < plani.platot
               then do:
                   if aux-movpc = 0 then aux-movpc = 1.
                   vmovqt-4 = round((plani.platot - vtotpro) / aux-movpc,0).
                   vmovpc-4 = (plani.platot - vtotpro).
 
                   if not avail produ 
                   then find first produ where produ.procod = 360
                                no-lock no-error.
                   
                  run p-grava-tt(input (if plani.movtdc = 13 then 13 else 4),
                                   input vmovqt-4, 
                                   input vmovpc-4).
                                   
                 xxx = xxx + vmovpc-4.               
                                   
               end.     

           end.
       end. 
   end.
   hide frame fx1 no-pause.
   hide frame fffpla no-pause.

    /*
   output to /admcom/custom/desenv/est-31122012.
   for each tt-custo.
    export tt-custo.
   end.
   output close.
   */
   
   if opsys = "UNIX"
   then varquivo = "/admcom/relat/livroinv" + string(time).
   else varquivo = "l:~\relat~\livroinv" + string(time).

    {mdad.i
            &Saida     = "value(varquivo)"
            &Page-Size = "64"
            &Cond-Var  = "154"
            &Page-Line = "66"
            &Nom-Rel   = ""LIVROINV""
            &Nom-Sis   = """SISTEMA DE ESTOQUE"""
            &Tit-Rel   = """APURACAO ESTOQUE LUCRO REAL - Opcao: "" 
                            + string(vopc,""Fechamento/Mensal"")
                            + ""   -  Mes/Ano "" 
                            + string(vmes,""99"") + ""/""
                            + string(vano,""9999"")
                            + ""     "" + vsoma "
            &Width     = "154"
            &Form      = "frame f-cabcab"}
/*
disp xxx format ">>>,>>>,>>9.99"
    vxy format ">>>,>>>,>>9.99".
  */
   assign tetb-custo  = 0
          tetb-icms   = 0
          tetb-liq   = 0
          tetb-pis   = 0
          tetb-cofins = 0
          tetb-econt   = 0.

   assign tmov-custo  = 0
          tmov-icms   = 0
          tmov-liq   = 0
          tmov-pis   = 0
          tmov-cofins = 0
          tmov-econt   = 0.
          
   assign aux-custo  = 0
          aux-icms   = 0
          aux-liq   = 0
          aux-pis   = 0
          aux-cofins = 0
          aux-econt   = 0.

   for each tt-custo 
                     break
                      by tt-custo.etbcod
                      by tt-custo.movtdc
                      by tt-custo.alipis
                      by tt-custo.procod:
        
        if tt-custo.procod > 0
        then find produ where produ.procod = tt-custo.procod 
                               no-lock no-error.
        else release produ. 

        assign vpronom = (if avail produ then produ.pronom else "").

        if first-of(tt-custo.etbcod) and vanalitico
        then do:
             if tt-custo.etbcod = 0
             then put unformat skIp(2) "TOTAL GERAL" at 01 skip(1).
             else do:
                  find estab where estab.etbcod = tt-custo.etbcod
                                 no-lock no-error.
                  put unformat skip(1) 
                       "ESTABELECIMENTO " 
                       tt-custo.etbcod " - "
                       (if avail estab then estab.etbnom else "").             
             end.
        end.
        if first-of(tt-custo.etbcod) and vanalitico = no
        then do:
             if vetbi <> 0 
             then do:
                  find estab where estab.etbcod = tt-custo.etbcod 
                                   no-lock no-error.
                  put unformat skip(1) 
                       "ESTABELECIMENTO " 
                       vetbi " - "
                       (if avail estab then estab.etbnom else "").             
             end.
        end.

        
        if first-of(tt-custo.movtdc) and vanalitico and vopc = no
        then do:
             find tipmov where tipmov.movtdc = tt-custo.movtdc
                                       no-lock no-error.
             PUT unformat skip(1) "MOVIMENTACAO: " Tipmov.movtnom skip(1).
     
              assign tmov-custo  = 0
                     tmov-icms   = 0
                     tmov-liq   = 0
                     tmov-pis   = 0
                     tmov-cofins = 0
                     tmov-econt   = 0.
        end.

       if tt-custo.movtdc = 5 or tt-custo.movtdc = 13
       then      
         assign
            tetb-custo = tetb-custo - tt-custo.estcusto
            tetb-icms = tetb-icms - tt-custo.cusicm
            tetb-liq = tetb-liq - tt-custo.cusliq
            tetb-pis = tetb-pis - tt-custo.cuspis
            tetb-cofins = tetb-cofins - tt-custo.cuscofins
            tetb-econt = tetb-econt - tt-custo.cuscont
            aux-custo = aux-custo - tt-custo.estcusto
            aux-icms = aux-icms - tt-custo.cusicm
            aux-liq = aux-liq - tt-custo.cusliq
            aux-pis = aux-pis - tt-custo.cuspis
            aux-cofins = aux-cofins - tt-custo.cuscofins
            aux-econt = aux-econt - tt-custo.cuscont.
       else
          assign
            tetb-custo = tetb-custo + tt-custo.estcusto
            tetb-icms = tetb-icms + tt-custo.cusicm
            tetb-liq = tetb-liq + tt-custo.cusliq
            tetb-pis = tetb-pis + tt-custo.cuspis
            tetb-cofins = tetb-cofins + tt-custo.cuscofins
            tetb-econt = tetb-econt + tt-custo.cuscont
            aux-custo = aux-custo +  tt-custo.estcusto
            aux-icms = aux-icms +  tt-custo.cusicm
            aux-liq = aux-liq +  tt-custo.cusliq
            aux-pis = aux-pis + tt-custo.cuspis
            aux-cofins = aux-cofins + tt-custo.cuscofins
            aux-econt = aux-econt + tt-custo.cuscont.

       assign     
            tmov-custo = tmov-custo +  tt-custo.estcusto
            tmov-icms = tmov-icms +  tt-custo.cusicm
            tmov-liq = tmov-liq +  tt-custo.cusliq
            tmov-pis = tmov-pis + tt-custo.cuspis
            tmov-cofins = tmov-cofins + tt-custo.cuscofins
            tmov-econt = tmov-econt + tt-custo.cuscont.
     
        
        if vanalitico 
        then disp tt-custo.estatual
                  tt-custo.procod
                  vpronom
                  tt-custo.estcusto  @ aux-custo
                  tt-custo.cusicm   @ aux-icms
                  tt-custo.cusliq   @ aux-liq     
                  tt-custo.cuspis   @ aux-pis
                  tt-custo.cuscofins @  aux-cofins
                  tt-custo.cuscont   @ aux-econt
             with frame f-imp.
        down 1 with frame f-imp.     
     
        if first-of(tt-custo.movtdc) and vopc = no
        then do:
             find tipmov where tipmov.movtdc = tt-custo.movtdc
                                       no-lock no-error.
            down 1 with frame f-imp.     
             disp tt-custo.etbcod when tt-custo.etbcod <> 0
                         with frame f-imp.
        
                           
             disp "TOTAL: " +
                  Tipmov.movtnom @ vpronom
                  with frame f-imp.
        end.

        if last-of(tt-custo.alipis) and vopc = no 
        then do:
            disp  tt-custo.alipis no-label
                  tmov-custo  @ aux-custo
                  tmov-icms   @ aux-icms
                  tmov-liq   @ aux-liq     
                  tmov-pis   @ aux-pis
                  tmov-cofins @  aux-cofins
                  tmov-econt   @ aux-econt
                with frame f-imp.
              down 1 with frame f-imp.     
     
              assign tmov-custo  = 0
                     tmov-icms   = 0
                     tmov-liq   = 0
                     tmov-pis   = 0
                     tmov-cofins = 0
                     tmov-econt   = 0.

        end.

        /*
        if last-of(tt-custo.movtdc) and vopc = no 
        then do:
             find tipmov where tipmov.movtdc = tt-custo.movtdc
                                       no-lock no-error.
            down 1 with frame f-imp.     
             disp tt-custo.etbcod when tt-custo.etbcod <> 0
                         with frame f-imp.
                           
             disp "TOTAL: " +
                  Tipmov.movtnom @ vpronom
                  tmov-custo  @ aux-custo
                  tmov-icms   @ aux-icms
                  tmov-liq   @ aux-liq     
                  tmov-pis   @ aux-pis
                  tmov-cofins @  aux-cofins
                  tmov-econt   @ aux-econt
                with frame f-imp.
              down 1 with frame f-imp.     
     
              assign tmov-custo  = 0
                     tmov-icms   = 0
                     tmov-liq   = 0
                     tmov-pis   = 0
                     tmov-cofins = 0
                     tmov-econt   = 0.

        end.
        **/
        
        if last-of(tt-custo.etbcod)  and vanalitico  
        then do:
             down 1 with frame f-imp.     
             disp "Total Estabelecimento " + string(tt-custo.etbcod)
                                @   vpronom
                  tetb-custo  @ aux-custo
                  tetb-icms   @ aux-icms
                  tetb-liq   @ aux-liq     
                  tetb-pis   @ aux-pis
                  tetb-cofins @  aux-cofins
                  tetb-econt   @ aux-econt
                with frame f-imp.
              down 1 with frame f-imp.     
     
              assign tetb-custo  = 0
                     tetb-icms   = 0
                     tetb-liq   = 0
                     tetb-pis   = 0
                     tetb-cofins = 0
                     tetb-econt   = 0.
     
        end.
    end.
    
     down 1 with frame f-imp.
     disp "TOTAL GERAL" @ VPRONOM
            aux-custo
            aux-icms
            aux-liq
            aux-pis
            aux-cofins
            aux-econt   WITH frame f-imp.
   
     put skip(3).
    

    output stream stela close.
    output close.     

 if opsys = "UNIX"
 then do:
     run visurel.p(input varquivo, input "").
 end.
 else do:
     {mrod.i} 
 end. 
end.

procedure p-grava-tt.
    def input parameter vmovtdc    as int.
    def input parameter vestatual like estoq.estatual.
    def input parameter vestcusto like estoq.estcusto.
          
    if (vopc = yes and avail movim and movim.movalicms <> ?)
    then assign vicms = movim.MovAlICMS.
    
    if vopc = yes
    then assign vpis = 0.65  
                vcofins = 3.0.
    else do:           
        if vmovtdc = 4 and aux-uf = "AM"
        then assign vpis    = 1
                    vcofins = 4.6.     
        else if produ.codfis = 0
             then assign vpis = 1.65
                         vcofins = 7.6.  
             else do:
                  find clafis where clafis.codfis = produ.codfis 
                        no-lock no-error.
                  if not avail clafis
                  then assign vpis = 0
                              vcofins = 0.
                  else do:
                       if vmovtdc <> 5
                       then assign vpis    = clafis.pisent
                                   vcofins = clafis.cofinsent.
                       else assign vpis    = clafis.pissai
                                   vcofins = clafis.cofinssai.
                  end.                 
             end.
        end.
      
      /*** Tatamento para Monofásico ***/
        
            if substr(string(produ.codfis),1,4) = "4013"
            then assign vpis = 0 vcofins = 0.
            if substr(string(produ.codfis),1,5) = "85272"
            then assign vpis = 0 vcofins = 0.
            if produ.codfis = 85071000
            then assign vpis = 0 vcofins = 0.

            if avail clafis and clafis.log1 /* Monofasico */
            then assign vpis = 0 vcofins = 0. 
      
      /*****************/
           
      if vpis = 0 then vcofins = 0.
      
      if vmovtdc = 5 and vicms <> 17 
      then do:
           if vmapsub > vendsub and vicms = 0
           then do:
                if vmapsub < (vendsub + vestcusto)
                then vestcusto = (vmapsub - vendsub).
                vendsub = vendsub + vestcusto.    
                
           end.
           else do:
               if vmap12 > vend12 and vicms > 0
               then if vmap12 < (vend12 + vestcusto)
                    then vestcusto = (vmap12 - vend12).
                    else.
               else vicms = 17.

               vend12 = vend12 + vestcusto.
           end.
      end.
           
      assign aux-custo = (if vopc = no then vestcusto
                          else ((if avail movim then movim.movpc 
                                 else vestcusto) *  vestatual))
             aux-icms  = trunc(aux-custo * (vicms / 100),2).   
             
      if vmovtdc = 5 and 
         (vmapicm < (vlimicm + (aux-custo * (vicms / 100))) or
          vmapvda < (vlimvda + aux-custo))
      then do:
           assign aux-icms  = (vmapicm - vlimicm) 
                  aux-custo = vmapvda - vlimvda.
           if aux-custo > (vestcusto * 3)
           then assign aux-icms = 0 
                       vicms = 0
                       aux-custo = (vestcusto * 1.5).
                  
       end.

       assign aux-liq  = aux-custo - aux-icms
              aux-pis  = ((if vopc then aux-liq else aux-custo)
                             * (vpis / 100))
              aux-cofins = ((if vopc then aux-liq else aux-custo) 
                                 * (vcofins / 100)).

       if (vmovtdc = 5 and vmapicm >= (vlimicm + aux-icms)
           and aux-custo > 0)
       or vmovtdc <> 5
       then do:
     
            if vmovtdc = 5
            then assign vlimicm = vlimicm + aux-icms
                        vlimvda = vlimvda + aux-custo.

            if vanalitico = no 
            then do:
                if vconsolidado
                then  find first tt-custo where tt-custo.etbcod = 0 
                                       and tt-custo.procod = 0
                                       and tt-custo.movtdc = vmovtdc
                                       and tt-custo.alipis = vpis
                            no-error.
                else  find first tt-custo where tt-custo.etbcod = 
                                                    tt-estab.etbcod 
                                       and tt-custo.procod = 0
                                       and tt-custo.movtdc = vmovtdc
                            no-error.
            end.
            else find first tt-custo where tt-custo.etbcod = /*vetbi*/                                                               tt-estab.etbcod 
                                       and tt-custo.procod = produ.procod
                                       and tt-custo.movtdc = vmovtdc
                            no-error.
            if not avail tt-custo
            then do:
                 create tt-custo.
                 if vanalitico = NO 
                 then do:
                    if vconsolidado
                    then assign tt-custo.etbcod = 0
                             tt-custo.procod = 0
                             tt-custo.movtdc = vmovtdc
                             tt-custo.alipis = vpis.
                    else assign tt-custo.etbcod = tt-estab.etbcod
                                tt-custo.procod = 0
                             tt-custo.movtdc = vmovtdc.
                end.
                else assign tt-custo.etbcod = tt-estab.etbcod /*vetbi*/
                             tt-custo.procod = produ.procod 
                             tt-custo.movtdc = vmovtdc.            
            
            end.
            
            assign 
                   tt-custo.estatual = tt-custo.estatual + vestatual
                   tt-custo.estcusto = tt-custo.estcusto + aux-custo +
                                      (if vsoma = "A" then aux-icms
                                       else if vsoma = "D" 
                                            then (aux-icms * -1)
                                            else 0)
                   tt-custo.cusicm  = tt-custo.cusicm + aux-icms
                   tt-custo.cusliq  = tt-custo.cusliq + aux-liq
                   tt-custo.cuspis  = tt-custo.cuspis + aux-pis
                   tt-custo.cuscofins = tt-custo.cuscofins + aux-cofins
                   tt-custo.cuscont  = tt-custo.cuscont 
                                     + (aux-custo - aux-icms - 
                                       aux-pis - aux-cofins)
                                    + (if vsoma = "A" then aux-icms 
                                      else if vsoma = "D" then (aux-icms * -1)
                                           else  0).
      end.                                     

end procedure.

procedure busca-ali:
   /*** copia do gerpla.p (grava-ali) */

       def var vali as char.
        
       if produ.proipiper = 17 or
          produ.proipiper = 0
       then vali = "01".
       if produ.proipiper = 12.00 or
          produ.pronom begins "Computa"
       then vali = "FF".
       if produ.pronom begins "Pneu" or
          produ.proipiper = 999
       then vali = "FF".
       if produ.proseq = 1
          then vali = "03".
    
        if vali = "01"
        then vicms = 17.
        else if vali = "02"
             then vicms = 12.
             else if vali = "03"
                  then vicms = 7.
                  else if vali = "04"
                       then vicms = 25.
                       else vicms = 0.
                                    
end procedure.

procedure sel-produto:
    for each tt-produ: delete tt-produ. end.
    
    for each tt-estab no-lock:
    for each cmovim 
                                where cmovim.etbcod = tt-estab.etbcod 
                                  and cmovim.movtdc = vmovtdc
                                  and cmovim.movdat >= vdti 
                                  and cmovim.movdat <= vdtf 
                                  no-lock:
        find first tt-produ where tt-produ.procod = cmovim.procod no-error.
        if not avail tt-produ
        then do:
            create tt-produ.
            tt-produ.procod = cmovim.procod.
        end.    
    end.
    end.
     
end.
