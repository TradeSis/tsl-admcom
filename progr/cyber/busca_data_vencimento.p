/*  cyber/busca_data_vencimento.p           */

def input  parameter vdata   as date.
def output parameter vdtven  as date.
def buffer cCyber_regras for Cyber_regras.

find ccyber_regras where 
     ccyber_regras.Cyber_Mes = month(vdata) no-lock no-error.
if not avail cCyber_regras
then vdtven = ?.
else do.
    if cCyber_regras.Cyber_DiaVecto = 99 /* ultimo dia mes */
    then do.
        def var vmes as int.
        def var vano as int.
        def var vdtf as date.
        def var vanofim as int.
        def var vmesfim as int.
        vmes = month(vdata).
        vano = year(vdata).
        vanofim      = vano + if vmes = 12
                              then 1 
                              else 0. 
        vmesfim      = if vmes = 12 
                       then 1 
                       else vmes + 1.
        vdtf         = date(vmesfim,01,vanofim) - 1.
        vdtven = vdtf.
    end.
    else do.             
        vdtven = date(cCyber_regras.Cyber_MesVecto,
                      cCyber_regras.Cyber_DiaVecto,
                      year(vdata) + cCyber_regras.Cyber_AnoVecto
                        ).
    end.
end.
