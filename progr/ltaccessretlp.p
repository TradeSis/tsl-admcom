def input param par-lotcre as recid.
def input param par-titnum as int.
def input-output param par-ok as int.
def input param vestab as int.
def input param vdataacordo as char.
def input param vdescri as char.
def input param vdataagenda as char.

find lotcre where recid(lotcre) = par-lotcre no-lock.
                    
/* Percorre os titulos do lote banco D */
for each lotcretit where int(lotcretit.titnum) = par-titnum and 
                             lotcretit.etbcod  = vestab     and
                             lotcretit.ltcrecod = lotcre.ltcrecod
                             exclusive break by lotcretit.titnum.

    find d.titulo where titulo.empcod = 19
            and d.titulo.titnat = no
            and d.titulo.modcod = lotcretit.modcod
            and d.titulo.etbcod = lotcretit.etbcod
            and d.titulo.clifor = lotcretit.clfcod
            and d.titulo.titnum = lotcretit.titnum
            and d.titulo.titpar = lotcretit.titpar
            exclusive no-error.  
        
    if not avail d.titulo then next.
        
    if avail d.titulo 
    then do:
        find d.cobra where d.cobra.cobnom = "ACCESS" no-lock.
        assign
            d.titulo.cobcod = cobra.cobcod
            lotcretit.spcretorno = "acionamento de cobranca".

                            
        if first-of(lotcretit.titnum)
        then do:

                create acordocob.
                assign  
                acordocob.clfcod   = titulo.clifor
                acordocob.titnum   = string(par-titnum)
                acordocob.etbcod   = vestab
                acordocob.dtacordo = date(vdataacordo) 
                acordocob.descr    = vdescri
                acordocob.dtagend  = date(vdataagenda).
                par-ok = par-ok + 1.
        end.    
                
    end.    
end. /*lotcretit D*/
            
 