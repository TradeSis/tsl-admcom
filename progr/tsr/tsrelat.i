/* INCLUDE COM AS VARIAVEIS PADRAO, ALEM DA ROTINA MARCA */
DEF VAR vtoday AS DATE.
def var vpropath as char.
def var pidrelat as int64.
DEF VAR vdirweb AS CHAR.
DEF VAR vdir     AS CHAR.
def var varquivo as char.

vdir    = "/admcom/relat/".
vdirweb = "/relatorios/".

pidrelat = int(entry(1,SESSION:PARAMETER,",")) no-error.

if pidrelat <> ? AND pidrelat <> 0
then do:
   
    FIND tsrelat where tsrelat.idrelat = pidrelat no-lock no-error.
    if not avail tsrelat
    then do:
        message "TS/Relat " pidrelat "Nao Encontrado".
        return.
    end.    
    copy-lob FROM parametrosJSON to lcjsonentrada.
    
    
    input from /admcom/linux/propath no-echo.  /* Seta Propath */
    import vpropath.
    input close.
    propath = vpropath.

END.

procedure marcatsrelat.
    def input param varquivo    as char.
    message "marcando" varquivo.
    find current tsrelat exclusive.
    if varquivo = "INICIO"
    then do:
        tsrelat.dtproc = today.
        tsrelat.hrinic = time.
        tsrelat.nomeArquivo = "PROCESSANDO...".
    end.    
    else do:
        tsrelat.nomeArquivo = varquivo.
        tsrelat.hrproc      = time.
    end.        
end procedure.


FUNCTION convertedata RETURNS DATE
    (INPUT pdata  AS CHAR):
DEF VAR vdata AS DATE.
        vdata = ?.
        if NUM-ENTRIES(pdata,"-") = 3 
        then do:
            vdata  = DATE(INT(ENTRY(2,pdata,"-")),       
                          INT(ENTRY(3,pdata,"-")),
                          INT(ENTRY(1,pdata,"-"))) no-error.
        end.
        ELSE vdata   = DATE(pdata) no-error.
    
    RETURN vdata.
END FUNCTION.    
        
function calculadata RETURNS DATE
    (INPUT ptipoparam AS char,
     INPUT ptoday  AS DATE):
DEF VAR vdata AS DATE INIT TODAY.    
DEF VAR vdia AS INT.
DEF VAR vmes AS INT.
DEF VAR vano AS INT.
def var vmenos as int.

        if ptipoparam BEGINS "#DIAPRIMES"
        then do:
            vmenos = 0.
            if num-entries(ptipoparam,"-") = 2
            then vmenos = INT(ENTRY(2,ptipoparam,"-")) NO-ERROR.
            if vmenos = ? then vmenos = 0.

            if day(ptoday) = 1
            then ptoday = ptoday - 1.
            
            vmes = month(ptoday) - vmenos.
            vano = year(ptoday).
            if vmes <= 0
            then do:
                vano = vano - 1.
                vmes = 12 - (vmes * -1).
                if vmes <= 0
                then do:
                    vano = vano - 1.
                    vmes = 12 - (vmes * -1).
                end.
            end.
            vdata = date(vmes,01,vano).               
        end.

        if ptipoparam = "#DIAULTMES"
        then do:
            vdata = ptoday - 1.
        end.

        if ptipoparam BEGINS "#DIAULTMES-"
        then do:
            vmenos = 0.
            if num-entries(ptipoparam,"-") = 2
            then vmenos = INT(ENTRY(2,ptipoparam,"-")) NO-ERROR.
            if vmenos = ? then vmenos = 0.
            if day(ptoday) = 1
            then ptoday = ptoday - 1.

            vmes = month(ptoday) + 1 - vmenos.
            vano = year(ptoday).
            if vmes = 13
            then do:
                vmes = 1.    
                vano = vano + 1.
            end.

            if vmes <= 0
            then do:
                vano = vano - 1.
                vmes = 12 - (vmes * -1).
                if vmes <= 0
                then do:
                    vano = vano - 1.
                    vmes = 12 - (vmes * -1).
                end.
            end.
            vdata = date(vmes,01,vano) - 1.               

        end.


        if ptipoparam = "#HOJE"
        then do:
            vdata = ptoday.
        end.
         if ptipoparam BEGINS "#HOJE-" 
        then do:
            vdia  = INT(substring(ENTRY(2,ptipoparam,"-"),1)) NO-ERROR.
            if vdia = ? THEN vdia = 0.
            vdata = ptoday - vdia.
        end.

        RETURN vdata.
        
END FUNCTION.
