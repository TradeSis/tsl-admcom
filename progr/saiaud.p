{admcab.i }
def var varq as char.
def var vetbcod like estab.etbcod.
def var vdti like plani.pladat.
def var vdtf like plani.pladat.


if opsys = "unix"
then do:

    input from /admcom/audit/audit.ini.
    repeat:
        import varq.
        vetbcod = int(substring(varq,1,2)).
        vdti    = date(int(substring(varq,5,2)),
                       int(substring(varq,3,2)),
                       int(substring(varq,7,4))).
        vdtf    = date(int(substring(varq,13,2)),
                       int(substring(varq,11,2)),
                       int(substring(varq,15,4))).
                       
    end.
    input close.
    disp vetbcod vdti vdtf.
    pause.
    
end.                           
