
def var vpropath as char.
input from /admcom/linux/propath no-echo.  /* Seta Propath */
import vpropath.
input close.

propath = vpropath.

message "FASE2".
run abas/fase2expneogrid.p.

return.
