{admcab.i}
def var vescolha as char format "x(15)"
extent 2 init["   CLIENTE","   CONTRATO"].
disp vescolha with frame f-escolha no-label centered .
choose field vescolha with frame f-escolha.
if frame-index = 1
then do:
    run clasopercred.p.
end.
else do:
    run clasopercred-contrato.p.
end.
