.include "map.i"

title   "Stray Toy's Adventure!!"
#audio   "Stray Toy's Adventure.ogg"
audio   "Stray Toy's Adventure_0.875.ogg"

#tempo   256.0
#offset  1.169
tempo   112.0
offset  1.336

# Theme A
lead  2
seq   u...d...u...duuu
seq   d...u...d...uddd
lead  1
seq   .u.d.d.u.u.d.d.u
seq   .d.u.d.ufffff...

# Intro "Now loading..."
lead  2
seq   ................
seq   f.......
lead  1
seq           ......dd

# Verse
lead  1
seq   .d.u.d.u.d.u.d.u
seq   .d.u.d.u.d.u.duu
seq   .d.u.d.u.d.u.duu
seq   d
lead  2
seq    ...f...f.
lead  1
seq             .f..uu

# Pre-chorus
seq   d...
lead  2
seq       ....u.d.d.u.
seq   u.......d.u.d.d.
seq   d...u...d...d...
lead  1
seq   .d.u.d.u.d.u.d.u
seq   .u.d.u.d.u.d.u.d
seq   ..f..f.f..f..f.f
seq   ..f..f.fffff.dd.

# Interlude
seq   fu.d.u.d.u.d.u.f
seq   fd.u.d.u.d.u.fff
seq   .f.d.u.d.u.d.u.f
seq   fd.u.d.u.d.u.d.u
seq   .........f..
lead  2
seq               ..dd

# Theme B
lead  1
seq   .u.u.d.u.u.u.d.u
seq   .f.f.f.ff....u..
seq   .u.u.d.u.u.u.d.d
seq   f.u.ddu.ffff..f.
seq   .d.u..f..d.u..f.
seq   .u.u.d.u.d.d.u.d
seq   fd.u.u.d.d.u.d.u
seq   f...f...f.f...f.

# Theme A
lead  2
.rept 2
seq   u...d...u...duuu
seq   d...u...d...uddd
.endr
lead  1
seq   u...ddu.dduff...uuuu
seq   .d.u.d.uf...f...f.f..f..

seq_end

decor 1, 2, 3, 4, 5, 6
decor 1, 12, 3, 4, 5, 6
decor 1, 22, 5, 4, 5, 6
decor 1, 32, 5, 4, 5, 6
decor 1, 42, 3, 4, 5, 6
decor 2, x=7, y=8, w=4
decor_end
