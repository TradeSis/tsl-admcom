
  def var vetbcod   as char.
  def var vetbnom   as char.
  def var vufecod   as char.
  def var vetbinsc  as char.
  def var vetbcgc   as char.
  def var vendereco as char.
  def var vetbtofne as char.
  def var vetbtoffe  as char.
  def var vmunic     as char.
  def var vetbserie as char.
  def var vmovndcfim as char.
  def var vetbfluxo  as char.
  def var vestcota  as char.
  def var vvencota  as char.
  def var vRegCod   as char.
  def var vetbmov   as char.
  def var vetbcon   as char.
  def var vprazo    as char.
  def var vvista    as char.
delete from estab.
input from ..\work\estab.d.
repeat:
    import  vetbcod
            vetbnom
            vufecod
            vetbinsc
            vetbcgc
            vendereco
            vetbtofne
            vetbtoffe
            vmunic
            vetbserie
            vmovndcfim
            vetbfluxo
            vestcota
            vvencota
            vRegCod
            vetbmov
            vetbcon
            vprazo
            vvista.
     create estab.
    ASSIGN estab.RegCod    = int(vRegCod)
           estab.etbcod    = int(vetbcod)
           estab.etbnom    = vetbnom
           estab.ufecod    = vufecod
           estab.etbinsc   = vetbinsc
           estab.etbcgc    = vetbcgc
           estab.endereco  = vendereco
           estab.munic     = vmunic
           estab.etbserie  = vetbserie
           estab.prazo     = vprazo
           estab.vista     = vvista.
end.
input close.
