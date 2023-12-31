### 引入图片
- 在res.s里导入资源文件的二进制，方法直接见`res.s`里面的注释。
  - 这样导入得到的是图片的二进制、也就是jpg/png等编码生成后的结果，不能够直接用于绘制纹理。
- 使用decode_image将图片解码为RGBA行优先的矩阵：  
  - 参数： r0 图片二进制地址； r1 字节数
  - 返回： r0 转换后的RGBA矩阵的二进制地址； r1 图片的宽； r2 图片的高
  - 示例：
```asm
  ldr   r0, =_img_example // 把图片地址放进r0
  ldr   r1, =_img_example_size // 把图片文件的大小放进r1
  blx   decode_image // 调用decode_image函数
  // 函数返回后，r0中时RGBA矩阵的地址、可以直接用于创建纹理，r1和r2分别是图片的长和宽
```

### 直接画矩形
- 使用_draw_square函数。
  - 用法：参数与Draw系统调用相同，除了只需要传三个角上的点、而不需要传第四个点。
  - 详见函数体内的注释