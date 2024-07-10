def var vtam as char format "x(30)" label "Tamanhos".
form with frame f-linha down row 10  
          title " Grades " color yellow/blue overlay. 

{setbrw.i}
{sklcls.i
    &help       = "ENTER=Seleciona F4=Retorna"
    &file       = grade
    &cfield     = grade.granom
    &ofield     = "grade.gracod vtam"
    &where      = "true use-index granom"
    &locktype   = "no-lock"
    &color      = yellow
    &color1     = blue
    &AftFnd1    = "vtam = """".
                   for each gratam of grade no-lock use-index graord.
                   vtam = vtam + string(gratam.tamcod) + "" "".
                   end."
    &naoexiste1 = "message ""Nenhum registro encontrado"" view-as alert-box.
                   leave keys-loop."
    &aftselect1 = "frame-value = string(grade.gracod).
                   leave keys-loop." 
    &form       = "frame f-linha"}

hide frame f-linha no-pause.
