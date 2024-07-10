{admcab.i}
def shared temp-table tt-campanha like campanha.

form vsegmentacao  as int label " Segmentacao"  format "zzzzzzzz"
     vpublico      as int label "     Publico"  format "zzzzzzzz"
     vperfil       as int label "      Perfil"  format "zzzzzzzz"
     vdepartamento as int label "Departamento"  format "zzzzzzzz"
     vsetor        as int label "       Setor"  format "zzzzzzzz"
     vproduto      as int label "     Produto"  format "zzzzzzzz"
     vapelo        as int label "       Apelo"  format "zzzzzzzz"
     vcanal        as int label "       Canal"  format "zzzzzzzz"
     with frame f-campanha 1 down centered
     side-label 1 column overlay row 6 color message.
     
do on error undo, retry with frame f-campanha: 
update  vsegmentacao 
        validate(vsegmentacao = 0 or
        can-find(first segmentacao where segmentacao.codigo = vsegmentacao),
        "Codigo para SEGMENTACAO nao encontrado")
        .
update  vpublico
        validate(vpublico = 0 or
        can-find(first publico where publico.codigo = vpublico),
        "Codigo para PUBLICO nao encontrado")
        .
update  vperfil
        validate(vperfil = 0 or
        can-find(first perfil where perfil.codigo = vperfil),
        "Codigo para PERFIL nao encontrado")
        .
update  vdepartamento
        validate(vdepartamento = 0 or
        can-find(first categoria where categoria.catcod = vdepartamento),
        "Codigo para DEPARTAMENTO nao encontrado")
        .
update  vsetor
        validate(vsetor = 0 or
        can-find(first setor where setor.setcod = vsetor),
        "Codigo para SETOR nao encontrado")
        .
update  vproduto
        validate(vproduto = 0 or
        can-find(first produ where produ.procod = vproduto),
        "Codigo para PRODUTO nao encontrado")
        .
update  vapelo 
        validate(vapelo = 0 or
        can-find(first apelo where apelo.codigo = vapelo),
        "Codigo para APELO nao encontrado")
        .
update  vcanal
        validate(vcanal = 0 or
        can-find(first canal where canal.codigo = vcanal),
        "Codigo para CANAL nao encontrado")
        .

end.        
if keyfunction(lastkey) = "end-error"
then return.
if vsegmentacao = 0  and  vpublico = 0 and
   vperfil = 0 and vdepartamento = 0 and
   vsetor = 0 and vproduto = 0 and
   vapelo = 0 and vcanal = 0
then .
else    
for each campanha no-lock:
    if vsegmentacao > 0 and vsegmentacao <> campanha.segmentacao
    then next.
    if vpublico > 0 and vpublico <> campanha.publico
    then next.
    if vperfil > 0 and vperfil <> campanha.perfil   
    then next.
    if vdepartamento > 0 and vdepartamento <> campanha.departamento
    then next.
    if vsetor > 0 and vsetor <> campanha.setor
    then next.
    if vproduto > 0 and vproduto <> campanha.produto
    then next.
    if vapelo > 0 and vapelo <> campanha.apelo
    then next.
    if vcanal > 0 and vcanal <> campanha.canal
    then next.
    create tt-campanha.
    buffer-copy campanha to tt-campanha.
end.
