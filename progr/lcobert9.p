{admcab.i}

def var fila as char.
def var varquivo    as char format "X(20)". 
def var vestdep like estoq.estatual.

def var vestass like estoq.estatual.     

def var vprocod like produ.procod.
def var vclacod like clase.clacod.
def var vqtd    like movim.movqtm.
def var vqtdest like movim.movqtm.
def var vqtdtot like movim.movqtm.
def var totven  like movim.movqtm.
def var totpcven like movim.movpc.

def var vdata   like plani.pladat.
def var totper  like estoq.estatual.
def var totdis  like estoq.estatual.
def var totdisest like estoq.estatual.

def shared temp-table tt-pro
    field procod  like produ.procod
    field pronom  like produ.pronom
    field fabcod  like fabri.fabcod
    field fabnom  like fabri.fabnom
    field estdep  like vestdep
    field totven  like totven

    field totpcven  like totpcven
    
    field cober     as   int
    field cober-dep-loj as int
    field pcvenda like estoq.estvenda
    field pccusto like estoq.estcusto

    field totpccusto like totpcven
    
    field qtdest  as int
    field qtdped  as int
    
    /**field pcped   like liped.lippreco**/
    
    field comp-val like movim.movpc
    field comp-qtd like movim.movqtm
    field estgeral like estoq.estatual
    
    index icober cober asc
    index icober-dep-loj cober-dep-loj asc 
    index ipronom pronom
    index iprocod procod
    index ifabnom fabnom
    index iqven totven desc
    index ipven /*pcvenda*/ totpcven desc
    index iedep estdep desc
    index ieloj qtdest desc
    index iqped qtdped desc.
 
define            variable vmes  as char format "x(05)" extent 13 initial
    ["  JAN","  FEV","  MAR","  ABR","  MAI","  JUN",
     "  JUL","  AGO","  SET","  OUT","  NOV","  DEZ", "TOTAL"].
     
form
    with frame f-comp centered overlay row 19 no-box.

def var vmes2 as char format "x(05)" extent 13.

def var vaux        as int.
def var vano        as int.
def var vnummes as int format ">>>" extent 12.
def var vnumano as int format ">>>>" extent 12.
def var vtotcomp    like himov.himqtm extent 13.

def var vqtdped as int.
def var i as int.
def var vcobertura as int format ">>>9" label "Cobertura".

if opsys = "UNIX"
then varquivo = "/admcom/relat/lcobert9" + string(time).    
else varquivo = "l:\relat\lcobert9" + string(time).

    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "63" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""lcobert9""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO """  
        &Tit-Rel   = """FERRAMENTA DE APOIO A COMPRAS """
        &Width     = "120"
        &Form      = "frame f-cabcab"}

    for each tt-pro break by tt-pro.cober-dep-loj:

        assign vestass = 0.
        find estoq where estoq.procod = tt-pro.procod
                     and estoq.etbcod = 988
                   no-lock no-error. /* Diego Lau Somente AT */       
        if avail estoq
        then vestass = estoq.estatual. 

        disp tt-pro.procod                label "Codigo" format ">>>>>9"
             tt-pro.pronom format "x(45)" label "Produto"
             tt-pro.fabnom format "x(17)" label "Fabricante"
             tt-pro.totven                column-label "Q.Ven"  format ">>>>9"
             /*tt-pro.pcvenda*/
             tt-pro.totpcven column-label /*"P.Ven"*/ "T.Ven" format ">>>>>>9"
             tt-pro.estdep                column-label "E.Dep" format "->>>9"
             vestass                      column-label "E.AT"  format "->>>9"
             tt-pro.cober                 column-label "Cober" format "->>>9"
             /*tt-pro.pccusto             column-label "P.Cus" format ">,>>9"*/
             tt-pro.qtdest                column-label "E.Loj" format "->>>9"
             tt-pro.cober-dep-loj         column-label "Cob.T" format "->>>9"
             tt-pro.qtdped                column-label "Q.Ped" format ">>>>9"
             with frame frame-lis down overlay no-box width 120.
        down with frame frame-lis.
    
    end.
    put skip(1).
    run compras.
    output close.
    if opsys = "UNIX"
    then do: 
        run visurel.p (input varquivo, input "").    
    end. 
    else do: 
        {mrod.i}. 
    end.

procedure compras.

    vaux = 0. vano = 0. i = 0.
    vaux    = month(today).
    vano    = year(today).
    vaux = vaux + 1.
    do i = 1 to 12:
        vaux = vaux - 1.
        if vaux = 0
        then do:
            vmes2[i] = "DEZ".
            vaux = 12.
            vano = vano - 1.
        end.
        vmes2[i] = vmes[vaux].
        vnummes[i] = vaux.
        vnumano[i] = vano.
    end.
    vmes2[13] = "TOTAL".       
    disp
        vmes2[1] no-label space(1)
        vmes2[2] no-label space(1)
        vmes2[3] no-label space(1)
        vmes2[4] no-label space(1)
        vmes2[5] no-label space(1)
        vmes2[6] no-label space(1)
        vmes2[7] no-label space(1)
        vmes2[8] no-label space(1)
        vmes2[9] no-label space(1)
        vmes2[10] no-label space(1)
        vmes2[11] no-label space(1)
        vmes2[12] no-label space(1) 
        vmes2[13] no-label space(1)
        with frame f-comp
        /*title     " C O M P R A  M E S E S  A N T E R I O R E S "*/.

    for each produ where produ.procod = tt-pro.procod no-lock:
    vtotcomp[13] = 0.
    do i = 1 to 12: 
        vtotcomp[i] = 0.
    
        for each estab where estab.etbcod >= 993
                          or estab.etbcod = 900 no-lock:
            find himov where himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 4            and
                             himov.himmes = vnummes[i]  and
                             himov.himano = vnumano[i] no-lock no-error.
            if not avail himov
            then next.
            vtotcomp[i] = vtotcomp[i] + himov.himqtm.
            vtotcomp[13] = vtotcomp[13] + himov.himqtm.
        end.
        
        find estab where estab.etbcod = 22 no-lock. 
        find himov where     himov.etbcod = estab.etbcod and
                             himov.procod = produ.procod and
                             himov.movtdc = 6            and
                             himov.himmes = vnummes[i]  and
                             himov.himano = vnumano[i] no-lock no-error.
        if not avail himov
        then next.
        vtotcomp[i] = vtotcomp[i] + himov.himqtm.
        vtotcomp[13] = vtotcomp[13] + himov.himqtm.
        

    end.

    disp
        vtotcomp[1] format ">>>>9" no-label
        vtotcomp[2] format ">>>>9" no-label
        vtotcomp[3] format ">>>>9" no-label
        vtotcomp[4] format ">>>>9" no-label
        vtotcomp[5] format ">>>>9" no-label
        vtotcomp[6] format ">>>>9" no-label
        vtotcomp[7] format ">>>>9" no-label
        vtotcomp[8] format ">>>>9"  no-label
        vtotcomp[9] format ">>>>9"  no-label
        vtotcomp[10] format ">>>>9" no-label
        vtotcomp[11] format ">>>>9" no-label
        vtotcomp[12] format ">>>>9" no-label 
        vtotcomp[13] format ">>>>9" no-label with frame f-comp.
   
   
   
   end.
   /*do on endkey undo.
       if keyfunction(lastkey) = "end-error"
       then do:
            hide frame f-comp no-pause.
            next.
       end.
       pause.
       hide frame f-comp no-pause.
       next .
   end.
     */
end procedure.


