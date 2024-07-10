def input parameter par-data as date.

if par-data = ?
then return.

def shared temp-table tt-arq
    field datmov   like depban.datmov
    field dephora  like depban.dephora  format "9999999"
    field valdep   like depban.valdep 
    field datexp   like depban.datexp
    index tt-arq   is primary dephora asc
                              valdep asc.

def temp-table tt-base
    field arquivo as char.

def var vlinha as char.
    
run le-extratos-CEF.
/*
for each tt-arq:
    disp tt-arq.
    pause.
end.
*/    
procedure le-extratos-CEF.
    def var vdatmov as char.
    def var vd as char.
    def var vdephora as char.
    def var vvalor as char.
    def var varquivo as char.
    def var varq-aux as char.
    def var varq as char.
    def var vdt as date.
    vdt = par-data.
    
    if opsys = "UNIX"
    then varquivo = "/admcom/caixa/COB" + string(day(vdt),"99") + 
                     string(month(vdt),"99") + "*.RET".
    else varquivo = "l:\caixa\B0" + string(day(vdt),"99") +
                     string(month(vdt),"99") + "*.RET".
    
  
    varq-aux = "/admcom/relat/cef." + string(time).
    
    output to value("/admcom/relat/cob_" + string(vdt,"99999999") + "." + string(time)).
    unix silent value("cd /admcom/caixa/; ls " + varquivo + " > " + varq-aux).
    output close.
    
    for each tt-base: delete tt-base. end.
    
    input from value(varq-aux).
    repeat:
        create tt-base.
        import arquivo.
    end.
    input close.
    
    for each tt-base.
        if search(tt-base.arquivo) = ?
        then next.
        input from value(tt-base.arquivo).
        repeat:
            import unformatted vlinha.
            if substr(vlinha,1,1) = "1"
            then do:
                assign
                    vdatmov  = substr(vlinha,111,6)
                    vdephora = substr(vlinha,66,8) 
                    vvalor   = substr(vlinha,153,13)
                    vd = substr(vdatmov,1,2) + "/" +
                                 substr(vdatmov,3,2) + "/" +
                                 substr(vdatmov,5,2).
                if vdephora <> "" and 
                        (substr(string(vdephora),1,1) = "0" or
                         substr(string(vdephora),1,1) = "1")
                then do:
                    create tt-arq.
                    assign
                        tt-arq.datmov   = date(vd)
                        tt-arq.dephora   = int(vdephora)
                        tt-arq.valdep    = int(vvalor) / 100.
                end.
            end.
        end.
        input close.
    end.
end procedure.
