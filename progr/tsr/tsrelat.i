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
        if NUM-ENTRIES(pdata,"-") = 3 
        then do:
            vdata  = DATE(INT(ENTRY(2,pdata,"-")),       
                          INT(ENTRY(3,pdata,"-")),
                          INT(ENTRY(1,pdata,"-"))).
        end.
        ELSE vdata   = DATE(pdata).
    RETURN vdata.
END FUNCTION.    
        
function calculadata RETURNS DATE
    (INPUT ptipoparam AS char,
     INPUT ptoday  AS DATE):
DEF VAR vdata AS DATE INIT TODAY.    
DEF VAR vdia AS INT.
DEF VAR vmes AS INT.
DEF VAR vano AS INT.

        if ptipoparam = "#DIAPRIMES"
        then do:
            if day(ptoday) = 1
            then vdata = ptoday - 1.
            else vdata = ptoday.
            vdata = date(month(vdata),01,year(vdata)).
        end.
        if ptipoparam BEGINS "#DIAULTMES-"
        then do:
            vmes = INT(substring(ENTRY(2,ptipoparam,"-"),1,2)) NO-ERROR.
            if vmes = ? THEN vmes = MONTH(ptoday).
            vano = INT(substring(ENTRY(2,ptipoparam,"-"),3)) NO-ERROR.
            if vano = ? THEN vano = YEAR(ptoday).
            vmes = vmes + 1.
            if vmes = 13 THEN vano = vano + 1.
            vdata = DATE(vmes,01,vano) - 1.
        end.

        if ptipoparam = "#DIAULTMES"
        then do:
            vdata = ptoday - 1.
        end.

        if ptipoparam = "#HOJE"
        then do:
            vdata = ptoday.
        end.
         if ptipoparam BEGINS "#HOJE-" // #HOJE-5
        then do:
            vdia  = INT(substring(ENTRY(2,ptipoparam,"-"),1)) NO-ERROR.
            if vdia = ? THEN vdia = 0.
            vdata = ptoday - vdia.
        end.

        RETURN vdata.
        
END FUNCTION.
