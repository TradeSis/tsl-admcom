/* Busca os pagamentos dos titulos lp */
def input-output parameter par-lotcre as recid.
def input param par-estab as int.
def input param par-dtini as date.
def input param par-dtfin as date.

def var vselecao as char.    
    
disp "Estabelecimento LP:" par-estab no-label
with frame f4 row 11 centered.
pause 0.


vselecao = string(par-dtini) + " a " + string(par-dtfin) .
find lotcretp where lotcretp.ltcretcod = "ACCESS" no-lock.

for each d.titulo where 
         d.titulo.empcod = 19
         and d.titulo.titnat = lotcretp.titnat
         and d.titulo.modcod = "CRE"
         and d.titulo.titdtpag >= par-dtini
         and d.titulo.titdtpag <= par-dtfin
         and d.titulo.etbcod = par-estab 
         and d.titulo.cobcod = 11 /*ACCESS*/
         no-lock.


         find first d.contnf where contnf.etbcod = d.titulo.etbcod and                   d.contnf.contnum = int(d.titulo.titnum) no-lock no-error.        
            
         /* mandar as novacoes com parcela acima de 31 */
         if not avail d.contnf and d.titulo.titpar < 31
         then next.                                                 
            
         if par-lotcre = ?
         then do.
            run lotcria.p (input recid(lotcretp),
                           output par-lotcre).
            do on error undo.
                find lotcre where recid(lotcre) = par-lotcre exclusive.
                lotcre.ltselecao = vselecao.
            end.
            find current lotcre no-lock.
         end.
         else find lotcre where recid(lotcre) = par-lotcre no-lock no-error.
            
         do on error undo.
            find lotcreag where lotcreag.ltcrecod = lotcre.ltcrecod
            and lotcreag.clfcod   = d.titulo.clifor no-error.
            if not avail lotcreag
            then do:
                create lotcreag.
                assign
                    lotcreag.ltcrecod = lotcre.ltcrecod
                    lotcreag.clfcod   = d.titulo.clifor.
            end.
         end.
            
         find lotcretit where lotcretit.ltcrecod = lotcre.ltcrecod
                 and lotcretit.clfcod   = d.titulo.clifor
                 and lotcretit.modcod   = d.titulo.modcod
                 and lotcretit.etbcod   = d.titulo.etbcod
                 and lotcretit.titnum   = d.titulo.titnum
                 and lotcretit.titpar   = d.titulo.titpar
                 no-lock no-error.

         if not avail lotcretit
         then do on error undo:
            create lotcretit.
            assign
                lotcretit.ltcrecod  = lotcre.ltcrecod
                lotcretit.clfcod    = d.titulo.clifor
                lotcretit.modcod    = d.titulo.modcod
                lotcretit.etbcod    = d.titulo.etbcod
                lotcretit.titnum    = d.titulo.titnum
                lotcretit.titpar    = d.titulo.titpar
                lotcretit.lottitpag = ?
                lotcretit.numero    = d.titulo.titnum.
         end.
end. /*d.titulo*/
