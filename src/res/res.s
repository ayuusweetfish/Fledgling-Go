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
  res cloud_0_png, cloud00-00.png
  res cloud_1_png, cloud00-01.png
  res cloud_2_png, cloud01-00.png
  res cloud_3_png, cloud10-01.png
  res cloud_in_you_png, in_you.png
  res mebird_png, Normal.png
  #res Mali_Regular_ttf, Mali-Regular.ttf

  res stray_bin, ../../map/stray.bin

  res upset_0_png, Upset.png
  res bump_0_png, Bump.png
  res great_flap_0_png, great_flap00.png
  res great_flap_1_png, great_flap01.png
  res perfect_flap_0_png, perfect_flap00.png
  res perfect_flap_1_png, perfect_flap01.png
  res flap_ready_0_png, Normal.png
  res lean_0_png, Look.png

  res upreminder_png, feather01.png
  res downreminder_png, feather10.png
  res flapreminder_png, feather00.png

  res sfx_perfect_ogg, sfx_perfect.ogg
  res sfx_great_ogg, sfx_great.ogg
  res sfx_bump_ogg, sfx_bump.ogg
  res sfx_upset_ogg, sfx_upset.ogg
  res sfx_flap_ogg, sfx_flap.ogg

  res perfectanim_0_png, Perfect1.png
  res perfectanim_1_png, Perfect2.png
  res greatanim_0_png, xingxing01.png
  res greatanim_1_png, xingxing10.png
  res greatanim_2_png, xingxing11.png

  res otherbirds_0_png, otherbird01.png
  res otherbirds_1_png, otherbird10.png
  res otherbirds_2_png, otherbird11.png
  res normal_0_png, Normal.png
  res normal_1_png, NormalA01.png

  res bg_png, background.png
  res bg_rainbow_0_png, rainbow_0.png
  res bg_rainbow_1_png, rainbow_1.png
  res bg_rainbow_2_png, rainbow_2.png
  res bg_rainbow_3_png, rainbow_3.png
  res bg_rainbow_4_png, rainbow_4.png
  res bg_rainbow_5_png, rainbow_5.png
  res bg_rainbow_6_png, rainbow_6.png
  res bg_rainbow_7_png, rainbow_7.png
  res bg_rainbow_8_png, rainbow_8.png

  res score_combo_png, score_combo.png
  res digits_png, digits.png


