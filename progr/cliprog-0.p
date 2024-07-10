connect ninja -H db2 -S sdrebninja -N tcp.
run cliprog0.p.

if connected("ninja")
then disconnect "ninja".

