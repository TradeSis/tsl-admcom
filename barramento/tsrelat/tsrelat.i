/* INCLUDE COM AS VARIAVEIS PADRAO, ALEM DA ROTINA MARCA */

def var vpropath as char.
def var pidrelat as int64.
DEF VAR vdirweb AS CHAR.
DEF VAR vdir     AS CHAR.
def var varquivo as char.

vdir    = "/admcom/relat/".
vdirweb = "/relatorios/".

pidrelat = int(SESSION:PARAMETER) no-error.

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


