# vim: set ft=asm:

.macro  res name: req, path: req
  .align 4
  .global \name
  \name: .incbin "res/\path"
  .global \name\()_size
  .equ \name\()_size, (. - \name)
  .byte 0
.endm

// 使用res宏指令导入资源，例如：
//     res _img_example, res/32573493.png
// 表示导入文件"res/32573493.png"，并命名为"_img_example".
//
// 建议约定，资源一律以下划线和表示类型的前缀开头，例如"_img_xxx", "_sound_xxx"。特殊类型的资源也可直接使用"_res_xxx"。
//
// 导入之后，在汇编代码中即可像普通的标签一样轻松地使用，并且用_size后缀可以获取其大小。示例：
//     ldr   r0, =_img_example //通过 = 即可得到资源的二进制的地址
//     ldr   r1, =_img_example_size // xxx_size是个立即数，因此建议通过ldr r, =xxx_size比较方便
.section .rodata
  res _32573480_png, 32573480.png
  res _32573481_png, 32573481.png
  res _32573487_png, 32573487.png
  res _32573491_png, 32573491.png
  res _32573493_png, 32573493.png
  res _32573496_png, 32573496.png
  res _32573498_png, 32573498.png
  res _32573499_png, 32573499.png
  res _32573502_png, 32573502.png
  res _32573503_png, 32573503.png
  res npcbird_png, Otherbirds.png
  res mebird_png, Normal.png
  res Mali_Regular_ttf, Mali-Regular.ttf

  res stray_bin, ../../map/stray.bin

  res upset_0_png, Upset.png
  res bump_0_png, Bump.png
  res great_flap_0_png, great_flap00.png
  res great_flap_1_png, great_flap01.png
  res perfect_flap_0_png, perfect_flap00.png
  res perfect_flap_1_png, perfect_flap01.png
  res flap_ready_0_png, Normal.png
  res lean_0_png, Look.png

  res upreminder_png, 32573491.png
  res downreminder_png, 32573496.png
  res flapreminder_png, 32573498.png

  res sfx_perfect_ogg, sfx_perfect.ogg
  res sfx_great_ogg, sfx_great.ogg
  res sfx_bump_ogg, sfx_bump.ogg
  res sfx_upset_ogg, sfx_upset.ogg
  res sfx_flap_ogg, sfx_flap.ogg

  res perfectanim_0_png, Perfect1.png
  res perfectanim_1_png, Perfect2.png
  res greatanim_0_png, great1.png
  res greatanim_1_png, great2.png

  res otherbirds_0_png, otherbirdA01.png
  res otherbirds_1_png, otherbirdA10.png
  res normal_0_png, Normal.png
  res normal_1_png, NormalA01.png

  res bg_png, background.png


