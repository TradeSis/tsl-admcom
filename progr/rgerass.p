{admcab.i}

def var vdatexp like asstec.datexp.
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
    field oscod    like asstec.oscod
    field forcod   like forne.forcod
    field fornom   like forne.fornom
    field procod   like produ.procod
    field pronom   like produ.pronom format "x(40)"
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

form 
    vetbcod label "Estabelecimento"
    estab.etbnom no-label
    vtipo no-label
    with frame f-os width 80 side-labels.
        
REPEAT:
    for each tas.
        delete tas.
    end.        
    for each tos.
        delete tos.
    end.
    
    assign vtotal-geral = 0 
           vtotal-col   = 0 
           cab-sint     = "".
           
    do on error undo:
        update vetbcod
               help "Informe o codigo do estabelecimento ou zero para todos"
               with frame f-os.
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
        end.    
    end.       

    update vtipo no-label with frame f-os.
    
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
        each asstec where asstec.etbcod = estab.etbcod no-lock:

        if asstec.dtenvfil <> ?
        then next.

        find tos where tos.etbcod = asstec.etbcod no-error.
        if not avail tos
        then do:
            create tos.
            assign tos.etbcod = asstec.etbcod.
        end.
        
        vdatexp = asstec.datexp.

        if vdatexp = ?
        then vdatexp = asstec.dtentdep.
        
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
                       and tas.forcod = asstec.forcod
                       and tas.oscod  = asstec.oscod no-error.
            if not avail tas
            then do:
                find forne where forne.forcod = asstec.forcod no-lock no-error.
                find produ where produ.procod = asstec.procod no-lock no-error.
                
                create tas.
                assign tas.etbcod   = asstec.etbcod
                       tas.etbnom   = estab.etbnom
                       tas.forcod   = asstec.forcod
                       tas.oscod    = asstec.oscod
                       tas.dtentdep = asstec.dtentdep
                       tas.dtenvfil = asstec.dtenvfil
                       tas.dtenvass = asstec.dtenvass
                       tas.datexp   = asstec.datexp
                       tas.t-col      = vcol
                       tas.fornom   = (if avail forne 
                                       then forne.fornom
                                       else "NAO CADASTRADO")
                       tas.procod  = asstec.procod
                       tas.pronom  = (if avail produ
                                      then produ.pronom
                                      else "NAO CADASTRADO").

            end.
        end.
        
        vtotal-geral = vtotal-geral + 1.
    end.

    if opsys = "UNIX"
    then do: 
        /*
        find first impress where impress.codimp = setbcod no-lock no-error.
        if avail impress
        then assign fila = string(impress.dfimp)
        */
        
        varquivo = "/admcom/relat/rgerass." + string(time).    
    
    end.
    else assign fila = ""
                varquivo = "l:\relat\rgerass." + string(time).


    if vtipo /*Analitico*/
    then do:
    
    {mdadmcab.i 
        &Saida     = "value(varquivo)" 
        &Page-Size = "0" 
        &Cond-Var  = "120"  
        &Page-Line = "0"
        &Nom-Rel   = ""rgerass""  
        &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
        &Tit-Rel   = """ASSISTENCIA TECNICA - TEMPO DE PENDENCIA DAS OS's ""
                     + ""- ANALITICO"""
        &Width     = "120"
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
                    disp skip(1) space(3)     "DE "
                         cab-sint[tas.t-col + 1] 
                         " DIAS"
                         skip(1)
                         with frame f-colz no-box no-labels.
                end.

                disp space(6)
                     tas.oscod    column-label "Num. OS"
                     tas.procod   column-label "Produto"
                     tas.pronom   column-label "Descricao"
                     tas.forcod   column-label "Fornecedor"
                     tas.dtentdep column-label "Dt.Entr.!Deposito"
                     tas.dtenvass column-label "Dt.Envio!Assistencia"
                     tas.dtenvfil column-label "Dt.Envio!Filial"
                     tas.datexp   column-label "Dt.Inclu"
                     with frame f-tas width 120 down.
            
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
        {mdadmcab.i 
            &Saida     = "value(varquivo)" 
            &Page-Size = "0" 
            &Cond-Var  = "80"  
            &Page-Line = "0"
            &Nom-Rel   = ""rgerass""  
            &Nom-Sis   = """SISTEMA ADMINISTRATIVO  SAO JERONIMO"""  
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
    
    if opsys = "UNIX"
    then do:
        
        message "Deseja imprimir relatorio" update sresp.
        if sresp
        
        then /*os-command silent lpr value(fila + " " + varquivo).
               */

        run visurel.p (input varquivo,
                       input "").
    end.
    else do:
        {mrod.i}.
    end.
    
END.
