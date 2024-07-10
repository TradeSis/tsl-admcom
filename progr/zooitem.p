{setbrw.i}

form with frame f-linha down row 10  
          title " Produtos PAI " color yellow/blue overlay. 

{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = produpai
    &cfield     = produpai.pronom
    &ofield     = "produpai.itecod produpai.gracod produpai.fabcod"
    &where      = "true use-index produpai3"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                     leave keys-loop."
    &aftselect1 = "frame-value = string(produpai.itecod).
                   leave keys-loop." 
    &form       = "frame f-linha "}

hide frame f-linha no-pause.

