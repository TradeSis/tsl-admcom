if not connected("wms")
then do.
    connect -db wms   -N tcp -S sdrebwms -H server.dep93.
end.
if connected("wms")
then do.
    run /admcom/progr/41248.p .
end.
if connected("wms")
then do.
    disconnect wms.
end.

