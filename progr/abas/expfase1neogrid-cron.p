
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

message "FASE1".
run abas/fase1expneogrid.p.

return.
