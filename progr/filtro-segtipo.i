def var vtpseguro as int.
def var vtpnome   as char.

{setbrw.i}

form
   SegTipo.Descricao no-label
   with frame f-segtip centered 6 down title " Tipos de Seguro " 
       color withe/red overlay row 6.

{sklcls.i
    &File   = SegTipo
    &help   = "ENTER=Seleciona    F4=Retorna"
    &CField = SegTipo.Descricao
    &Ofield = " SegTipo.Descricao"
    &Where  = " if {1} = """" then true
                              else lookup(string(segtipo.tpseguro), {1}) >  0"
    &noncharacter = /*
    &LockType = "NO-LOCK"
    &PickFld = "SegTipo.TpSeguro"
    &Form   = "frame f-segtip" 
}
if keyfunction(lastkey) = "end-error"
then return.

vtpseguro = segtipo.tpseguro.
vtpnome   = segtipo.descricao.
