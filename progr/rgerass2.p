propath = "/admcom/progr,/usr/dlc".
    
    
{/admcom/progr/admcab-batch.i new}

def var vfilial as char.
def var /*input  parameter*/ p-parametros as char.
def var /*output parameter*/ p-arquivo as char.

p-parametros = SESSION:PARAMETER.

def var vdatexp as date format "99/99/9999".
def var fila as char.
def var varquivo    as char format "X(20)". 
def var vtotal-geral as int format ">>>>>>>>>9".

def var vetbcod  like estab.etbcod.

def var vdia-i   as int extent 5 format ">>>>9".
def var vdia-f   as int extent 5 format ">>>>9".

def var vdti     as   date format "99/99/9999".
def var vdtf     as   date format "99/99/9999".
def var vdata    as   date format "99/99/9999".

def buffer bestab for estab.

def temp-table tas
    field t-col      as   integer
    field etbcod   like estab.etbcod
    field etbnom   like estab.etbnom
    field oscod    like adm.asstec.oscod
    field forcod   like ger.forne.forcod
    field fornom   like ger.forne.fornom
    field procod   like com.produ.procod
    field pronom   like com.produ.pronom format "x(40)"
    field datexp   as   date  format "99/99/9999"
    field dtenvfil as   date  format "99/99/9999"
    field dtentdep as   date  format "99/99/9999"
    field dtenvass as   date  format "99/99/9999".

def var vcol as int.

def temp-table tos
    field etbcod  like estab.etbcod
    field dias  as   integer format ">>>>>>>>>9" extent 5.

def var vtotdias as integer format ">>>>>>>>>9" extent 5.

def var cab-sint as char format "x(13)" extent 6.

def var vtotal-etb as int.
def var vtotal-for as int.
def var vtotal-col as int.
def var  vtipo as log format "Analitico/Sintetico" init no.


/*******/

vetbcod = int(acha("ETBCOD",p-parametros)).

if (acha("TIPO",p-parametros)) = "NO"
then vtipo = no.
else vtipo = yes.
        
vdia-i[1] = int((acha("DATAI1",p-parametros))).
vdia-i[2] = int((acha("DATAI2",p-parametros))).
vdia-i[3] = int((acha("DATAI3",p-parametros))).
vdia-i[4] = int((acha("DATAI4",p-parametros))).
vdia-i[5] = int((acha("DATAI5",p-parametros))).

vdia-f[1] = int((acha("DATAF1",p-parametros))).
vdia-f[2] = int((acha("DATAF2",p-parametros))).
vdia-f[3] = int((acha("DATAF3",p-parametros))).
vdia-f[4] = int((acha("DATAF4",p-parametros))).
vdia-f[5] = int((acha("DATAF5",p-parametros))).



/*******/

form 
    vetbcod label "Estabelecimento"
    estab.etbnom no-label
    vtipo no-label
    with frame f-os width 80 side-labels.
        
/*repeat:*/
    for each tas.
        delete tas.
    end.        
    for each tos.
        delete tos.
    end.
    
    assign vtotal-geral = 0 
           vtotal-col   = 0 
           cab-sint     = "".
           
    /*do on error undo:*/
        /*update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-os.*/
    /*    vetbcod = setbcod.
        disp vetbcod with frame f-os.       
        if vetbcod = 0
        then disp "TODOS" @ estab.etbnom with frame f-os.
        else do:
            find estab where estab.etbcod = vetbcod no-lock no-error.
            if not avail estab
            then do:
                message "Estabelecimento nao cadastrado".
                undo.
            end.
            else disp estab.etbnom no-label with frame f-os.
        end. */   
    /*end.*/
               /*
    update vtipo no-label with frame f-os.
                 */ /*
    update vdia-i[1] label "(1)Periodo Inicial"
           vdia-f[1] label "(1)Periodo Final" skip
           with frame f-os1 centered side-labels.
    
    /*vdia-i[2] = vdia-f[1] + 1.*/
    
    update vdia-i[2] label "(2)Periodo Inicial"
           vdia-f[2] label "(2)Periodo Final" skip
           with frame f-os1 centered side-labels.

    /*vdia-i[3] = vdia-f[2] + 1.*/
    
    update vdia-i[3] label "(3)Periodo Inicial"
           vdia-f[3] label "(3)Periodo Final" skip
           with frame f-os1 centered side-labels.
           
    /*vdia-i[4] = vdia-f[3] + 1.*/
    
    update vdia-i[4] label "(4)Periodo Inicial"
           vdia-f[4] label "(4)Periodo Final" skip
           with frame f-os1 centered side-labels.

    /*vdia-i[5] = vdia-f[4] + 1.*/
    
    update vdia-i[5] label "(5)Periodo Inicial"
           vdia-f[5] label "(5)Periodo Final"
           with frame f-os1 centered side-labels.
                      */
    hide frame f-os1 no-pause.
       
    assign cab-sint[1] = "Filial"
           cab-sint[2] = string(vdia-i[1]) + " a " + string(vdia-f[1])
           cab-sint[3] = string(vdia-i[2]) + " a " + string(vdia-f[2])
           cab-sint[4] = string(vdia-i[3]) + " a " + string(vdia-f[3])
           cab-sint[5] = string(vdia-i[4]) + " a " + string(vdia-f[4])
           cab-sint[6] = string(vdia-i[5]) + " a " + string(vdia-f[5]).
           
    for each estab where estab.etbcod = (if vetbcod <> 0
                                         then vetbcod
                                         else estab.etbcod) no-lock,
        each asstec where adm.asstec.etbcod = estab.etbcod no-lock:

        if adm.asstec.dtenvfil <> ?
        then next.

        find tos where tos.etbcod = adm.asstec.etbcod no-error.
        if not avail tos
        then do:
            create tos.
            assign tos.etbcod = adm.asstec.etbcod.
        end.
        
        vdatexp = adm.asstec.datexp.

        if vdatexp = ?
        then vdatexp = adm.asstec.dtentdep.
        
        vcol = 0.
        
        if (today - vdatexp) >= vdia-i[1] and
           (today - vdatexp) <= vdia-f[1]
        then assign vcol = 1
                    tos.dias[1] = tos.dias[1] + 1.
        else
        if (today - vdatexp) >= vdia-i[2] and
           (today - vdatexp) <= vdia-f[2]
        then assign vcol = 2
                    tos.dias[2] = tos.dias[2] + 1.
        else
        if (today - vdatexp) >= vdia-i[3] and
           (today - vdatexp) <= vdia-f[3]
        then assign vcol = 3
                    tos.dias[3] = tos.dias[3] + 1.
        else
        if (today - vdatexp) >= vdia-i[4] and
           (today - vdatexp) <= vdia-f[4]
        then assign vcol = 4
                    tos.dias[4] = tos.dias[4] + 1.
        else        
        if (today - vdatexp) >= vdia-i[5] and
           (today - vdatexp) <= vdia-f[5]
        then assign vcol = 5
                    tos.dias[5] = tos.dias[5] + 1.
        else
        assign vcol = 1
               tos.dias[1] = tos.dias[1] + 1.            

        if vtipo
        then do:
            find tas where tas.etbcod = estab.etbcod
                       and tas.forcod = adm.asstec.forcod
                       and tas.oscod  = adm.asstec.oscod no-error.
            if not avail tas
            then do:
                find ger.forne where
                     ger.forne.forcod = adm.asstec.forcod
                                              no-lock no-error.
                find com.produ where
                     com.produ.procod = adm.asstec.procod 
                                              no-lock no-error.
                
                create tas.
                assign tas.etbcod   = adm.asstec.etbcod
                       tas.etbnom   = estab.etbnom
                       tas.forcod   = adm.asstec.forcod
                       tas.oscod    = adm.asstec.oscod
                       tas.dtentdep = adm.asstec.dtentdep
                       tas.dtenvfil = adm.asstec.dtenvfil
                       tas.dtenvass = adm.asstec.dtenvass
                       tas.datexp   = adm.asstec.datexp
                       tas.t-col      = vcol
                       tas.fornom   = (if avail forne 
                                       then ger.forne.fornom
                                       else "NAO CADASTRADO")
                       tas.procod  = com.produ.procod
                       tas.pronom  = com.produ.pronom.

            end.
        end.
        
        vtotal-geral = vtotal-geral + 1.
    end.

    
    varquivo = "/admcom/connect/retorna-rel/rgerass_" + string(vetbcod,"999") 
             + ".rel".
    
    p-arquivo = varquivo.

    
    if vtipo /*Analitico*/
    then do:
    
    {/admcom/progr/mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "64" 
        &Cond-Var  = "120"  
        &Page-Line = "66"
        &Nom-Rel   = ""rgerass2""  
        &Nom-Sis   = """ADMCOM"""  
        &Tit-Rel   = """ASSISTENCIA TECNICA - TEMPO DE PENDENCIA DAS OS's ""
                     + ""- ANALITICO"""
        &Width     = "100"
        &Form      = "frame f-cabcab-a"}

            disp vtotal-geral label "Total OS Pendentes"
                 skip(2)
                 with frame f-osc1 centered side-labels.
            
            for each tas break by tas.etbcod
                               by tas.t-col
                               by tas.oscod:

                if first-of(tas.etbcod)
                then do:

                    vtotal-etb = 0.
                    disp tas.etbcod " - "
                         tas.etbnom no-label skip
                         with frame f-etb side-labels.
                      
                end.
            
                if first-of(tas.t-col)
                then do:
                    vtotal-col = 0.
                    disp skip(1) "DE "
                         cab-sint[tas.t-col + 1] 
                         " DIAS"
                         skip(1)
                         with frame f-colz no-box no-labels.
                end.

                disp 
                     tas.oscod    column-label "Num. OS"
                     tas.procod   column-label "Produto"
                     tas.pronom   column-label "Descricao" format "x(30)"
                     tas.forcod   column-label "Fornec"
                     tas.dtentdep column-label "Dt.Entr.!Dep"
                     tas.dtenvass column-label "Dt.Envio!Ass"
                     tas.dtenvfil column-label "Dt.Envio!Fil"
                     tas.datexp   column-label "Dt.Incl"
                     with frame f-tas width 100 down.
            
                assign vtotal-for   = vtotal-for + 1
                       vtotal-etb   = vtotal-etb + 1
                       vtotal-col   = vtotal-col + 1.
            
                if last-of(tas.t-col)
                then put skip(1) space(6) "Total de " cab-sint[tas.t-col + 1]
                                       " --> " vtotal-col skip. 
            
                if last-of(tas.etbcod)
                then put skip space(6) "Total por Filial --------> "
                         vtotal-etb skip.

                     
            end.

        
            put skip skip(1) space(6) "Total Geral      --------> "
                     vtotal-geral skip.
 


    end.
    else do:
        {/admcom/progr/mdadmcab.i 
            &Saida     = "value(varquivo)" 
            &Page-Size = "64" 
            &Cond-Var  = "80"  
            &Page-Line = "66"
            &Nom-Rel   = ""rgerass2""  
            &Nom-Sis   = """ADMCOM"""  
            &Tit-Rel   = """ASSISTENCIA TECNICA - TEMPO DE PENDENCIA "" +
                         ""DAS OS's """
            &Width     = "80"
            &Form      = "frame f-cabcab-s"}
            
            if vetbcod <> 0
            then find bestab where bestab.etbcod = vetbcod no-lock no-error.

            if vetbcod <> 0
            then disp 
                    bestab.etbcod label "Estabelecimento..."
                    bestab.etbnom no-label
                    with frame f-osc.
            else disp
                    "0" @ bestab.etbcod
                    "TODOS" @ bestab.etbnom
                    with frame f-osc.
                                
                 
            disp
                 skip(2)
                 vtotal-geral label "Total OS Pendentes"
                 skip(2)
                 with frame f-osc centered side-labels.
            vtotdias = 0.        
            put unformatted /*cab-sint[1] to 08*/
                            cab-sint[2] to 22
                            cab-sint[3] to 36
                            cab-sint[4] to 50
                            cab-sint[5] to 64
                            cab-sint[6] to 78
                            skip
                            /*fill("-",06) format "x(06)" to 08*/
                            fill("-",13) format "x(13)" to 22
                            fill("-",13) format "x(13)" to 36
                            fill("-",13) format "x(13)" to 50
                            fill("-",13) format "x(13)" to 64
                            fill("-",13) format "x(13)" to 78.

            for each tos /* break by tos.etbcod*/.
                                     /*
                disp /*tos.etbcod  to 08*/
                     tos.dias[1] to 22 (total)
                     tos.dias[2] to 36 (total)
                     tos.dias[3] to 50 (total)
                     tos.dias[4] to 64 (total)
                     tos.dias[5] to 78 (total) 
                     with frame f-tos down no-labels width 100.
                                       */
                assign vtotdias[1] = vtotdias[1] + tos.dias[1]
                       vtotdias[2] = vtotdias[2] + tos.dias[2]
                       vtotdias[3] = vtotdias[3] + tos.dias[3]
                       vtotdias[4] = vtotdias[4] + tos.dias[4]
                       vtotdias[5] = vtotdias[5] + tos.dias[5].
            end.
            
            disp /*tos.etbcod  to 08*/
                     vtotdias[1] to 22
                     vtotdias[2] to 36
                     vtotdias[3] to 50
                     vtotdias[4] to 64
                     vtotdias[5] to 78
                     with frame f-tos down no-labels width 100.

            
    end.

    output close.
    
vfilial = "filial" + string(vetbcod,"999").

os-command silent
   /home/drebes/scripts/job-rel value(varquivo) value(vfilial) " & ".

    
    
    /*run visurel.p (input varquivo,
                   input "").*/

    /* os-command silent /fiscal/lp value(varquivo).
      */

/*END.*/
