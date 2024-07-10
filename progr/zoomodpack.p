def var vtam as char format "x(30)" label "Tamanhos".
form with frame f-linha down row 10  
          title " Modelos de Packs " color yellow/blue overlay. 

{setbrw.i}
{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = modpack
    &cfield     = modpack.modpnom
    &ofield     = "modpack.modpcod vtam"
    &where      = "true use-index nome"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &AftFnd1    = "vtam = """".
                   find grade of modpack no-lock.
                   for each gratam of grade no-lock use-index graord.
                   vtam = vtam + string(gratam.tamcod) + "" "".
                   end."
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                   leave keys-loop."
    &aftselect1 = "frame-value = string(modpack.modpcod).
                   leave keys-loop." 
    &form       = "frame f-linha"}

hide frame f-linha no-pause.
