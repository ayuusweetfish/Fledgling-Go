.include "map.i"

title   "Stray Toy's Adventure!!"
audio   "Stray Toy's Adventure_0.875.ogg"
#audio   "silence.ogg"

tempo   224.0
offset  1.336
#tempo   60.0
#offset  1.5

.rept 0 #200
lead  2
seq   u..d..f..
lead  3
seq   u..d..f..
.endr


# Theme A
lead  2
seq   u...d...u...duuu
seq   d...u...d...uddd
seq   .u.d.d.u.u.d.d.u
seq   .d.u.d
lead  3
seq         ..f.......

# Intro "Now loading..."
lead  3
seq   ................
seq   f.............dd

# Verse
lead  1
seq   .d.u.d.u.d.u.d.u
seq   .d.u.d.u.d.u.duu
seq   .d.u.d.u.d.u.duu
seq   d
lead  2
seq    ...f
lead  3
seq        ...f..f..uu

# Pre-chorus
seq   d...
lead  2
seq       ....u.d.d.u.
seq   u.......d.u.d.d.
seq   d...u...d...d.
lead  1
seq                 ..
seq   .d.u.d.u.d.u.d.u
seq   .u.d.u.d
lead  2
seq           .u.d.u.d
lead  3
seq   ..f..f.f..f..f.f
seq   ..f..f.fffff.dd.

# Interlude
seq   f
lead  2
seq    u.d.u.d.u.d.u.f
seq   fd
lead  1
seq     .u.d.u.d
lead  2
seq             .u.fff
seq   .f
lead  1
seq     .d.u.d.u
lead  2
seq             .d.u.f
seq   fd
lead  1
seq     .u.d.u.d.u.d.u
seq   ....
lead  2
seq       .....f....dd

# Theme B
lead  3
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
lead  3
seq   u...ddu.dduff...uuuu
seq   .d.u.d.uf...f...f.f..f..
lead  4
seq   ..

seq_end

# Rainbow at the end of Theme A
decor -1,x=56,y=0,w=1
decor -2,x=57,y=0,w=1
decor -3,x=58,y=0,w=1
decor -4,x=59,y=0,w=1
decor -5,x=60,y=0,w=20
decor -6,x=80,y=0,w=0.3
decor -7,x=80.3,y=0,w=0.3
decor -8,x=80.6,y=0,w=0.3
decor -9,x=80.9,y=0,w=0.3
decor 4,x=67,y=-1.7,w=3,h=0.9

# Rainbow at the end of Pre-chorus
decor -1,x=264,y=0,w=1
decor -2,x=265,y=0,w=1
decor -3,x=266,y=0,w=1
decor -4,x=267,y=0,w=1
decor -5,x=268,y=0,w=4
decor -6,x=272,y=0,w=0.3
decor -7,x=272.3,y=0,w=0.3
decor -8,x=272.6,y=0,w=0.3
decor -9,x=272.9,y=0,w=0.3

# Rainbow flash at end of Interlude (bars 85-86)
decor -1,x=343.0,y=0,w=0.1
decor -2,x=343.1,y=0,w=0.1
decor -3,x=343.2,y=0,w=0.1
decor -4,x=343.3,y=0,w=0.1
decor -5,x=343.4,y=0,w=0.1
decor -6,x=343.5,y=0,w=0.1
decor -7,x=343.6,y=0,w=0.1
decor -8,x=343.7,y=0,w=0.1
decor -9,x=343.8,y=0,w=0.1
decor -1,x=344.0,y=0,w=0.1
decor -2,x=344.1,y=0,w=0.1
decor -3,x=344.2,y=0,w=0.1
decor -4,x=344.3,y=0,w=0.1
decor -5,x=344.4,y=0,w=0.1
decor -6,x=344.5,y=0,w=0.1
decor -7,x=344.6,y=0,w=0.1
decor -8,x=344.7,y=0,w=0.1
decor -9,x=344.8,y=0,w=0.1

decor 1,3.8459,0.0724,0,0.9809,0.9809
decor 2,5.2635,3.6321,0,0.6472,0.6472
decor 1,5.9234,-3.2827,0,0.7418,0.7418
decor 3,6.3936,3.9429,0,1.6833,0.9203
decor 1,7.6898,-2.2332,0,1.7383,1.7383
decor 2,8.5890,-3.5979,0,1.4627,0.7920
decor 3,9.9376,-1.9387,0,1.2464,1.2464
decor 1,10.1713,2.1318,0,0.8398,0.8398
decor 3,11.3708,-3.6026,0,1.0540,1.0540
decor 0,12.5696,1.9070,0,0.8443,0.8443
decor 1,13.2532,1.8393,0,0.8562,0.7410
decor 2,13.4655,-2.2364,0,0.7012,0.7012
decor 3,14.3909,2.9843,0,0.6866,0.6866
decor 0,14.7335,-3.9224,0,0.6960,0.6960
decor 1,15.2758,3.3378,0,0.7787,0.6770
decor 3,15.8767,-1.3936,0,0.9050,0.8117
decor 3,16.0885,-2.6844,0,1.0751,1.0751
decor 1,17.7615,3.1736,0,0.7519,0.7519
decor 1,18.8535,-3.1862,0,1.1829,0.7523
decor 3,20.5168,2.9343,0,0.9274,0.7435
decor 2,20.7432,-1.5287,0,0.9385,0.6998
decor 3,21.9452,-1.3592,0,1.0290,1.0290
decor 0,23.5296,-2.5532,0,1.7602,0.7389
decor 2,24.9028,-2.8967,0,1.5642,1.5642
decor 3,25.5549,3.9820,0,1.4371,1.2674
decor 3,26.5559,2.5852,0,1.5785,1.3762
decor 2,28.5213,-3.0796,0,1.0583,1.0041
decor 3,29.1808,1.5526,0,0.9594,0.7391
decor 0,29.7414,-2.5742,0,0.6640,0.6640
decor 2,31.0979,1.0402,0,0.6182,0.6182
decor 3,31.1373,-1.8578,0,0.6527,0.6425
decor 0,32.7486,3.5784,0,0.9102,0.9102
decor 2,33.5867,2.8417,0,1.3547,1.0206
decor 2,34.1563,2.7474,0,0.8284,0.6278
decor 3,34.1986,-0.8840,0,0.8260,0.8260
decor 2,35.0664,1.4433,0,1.6565,1.6565
decor 1,36.4001,-0.5483,0,0.8141,0.8141
decor 3,37.7798,-1.3367,0,1.3718,0.9943
decor 0,39.5648,3.8353,0,1.2285,1.0956
decor 0,40.7221,-0.8693,0,1.0073,1.0073
decor 3,41.4643,2.2573,0,0.8507,0.8507
decor 3,42.1922,-0.4041,0,0.8325,0.8325
decor 0,43.8219,2.7686,0,1.1527,1.1527
decor 0,45.2250,1.3408,0,0.6667,0.6667
decor 1,45.8116,-1.8271,0,0.6441,0.6441
decor 1,46.9582,1.9698,0,1.4050,1.1142
decor 0,48.2022,2.4121,0,1.0772,1.0772
decor 2,49.5343,0.0999,0,1.4327,0.8804
decor 2,51.1552,-1.9517,0,0.7564,0.7564
decor 0,52.4621,0.4279,0,0.8751,0.8124
decor 1,52.4644,-0.7534,0,0.6728,0.6728
decor 1,53.6922,-2.5677,0,1.2669,0.9885
decor 3,54.7295,0.2102,0,0.7006,0.7006
decor 1,54.8544,-3.8752,0,0.8733,0.8733
decor 0,56.0645,3.5441,0,0.9765,0.7481
decor 0,56.1424,-1.0770,0,0.9558,0.7224
decor 1,56.2782,-1.0869,0,1.4282,0.8408
decor 3,57.8639,-2.3005,0,0.8313,0.8313
decor 1,59.2168,3.7649,0,0.6521,0.6521
decor 0,59.7787,-0.3556,0,0.7764,0.6313
decor 2,61.0931,3.8213,0,0.7393,0.7393
#decor 2,61.5729,-1.3359,0,0.8220,0.8220
#decor 0,62.2100,0.5942,0,1.5249,1.5249
#decor 1,63.8244,-0.9582,0,1.2837,0.9019
#decor 1,65.6946,1.7349,0,1.7172,1.1297
#decor 0,66.1608,2.0368,0,0.9177,0.8345
#decor 3,66.2876,-2.9945,0,0.6037,0.6037
#decor 0,68.1307,-1.6456,0,0.9370,0.9370
#decor 0,70.0377,3.2101,0,0.9410,0.6450
#decor 0,70.7867,-0.2892,0,0.9418,0.9034
#decor 2,70.8331,1.7525,0,1.5732,1.2786
#decor 0,71.8663,1.9233,0,1.6962,1.1010
#decor 1,72.8730,-0.9018,0,1.1587,0.7358
#decor 1,73.9933,-2.7179,0,1.2187,0.7778
#decor 3,74.9670,-2.7765,0,0.7162,0.7162
##decor 2,75.8543,-1.7558,0,0.9001,0.9001
#decor 1,77.4248,-3.4985,0,0.8708,0.8708
#decor 2,78.0665,-3.4713,0,1.7354,1.6359
#decor 3,79.5548,3.4635,0,1.6141,1.3766
#decor 1,80.5243,0.5734,0,0.8356,0.8356
#decor 3,81.0873,2.2168,0,0.8777,0.6994
#decor 3,81.6637,-1.4524,0,0.8470,0.7172
#decor 2,82.0874,3.8386,0,0.7062,0.7062
decor 0,82.8839,-1.7575,0,0.8063,0.7376
decor 2,83.5690,3.9297,0,0.7661,0.7661
decor 2,83.9626,-2.9552,0,0.8035,0.8035
decor 1,84.5533,1.6112,0,0.9129,0.9129
decor 2,85.2449,2.3060,0,1.8293,0.9546
decor 2,86.9144,-2.0660,0,0.7983,0.7983
decor 2,87.4812,-3.2575,0,0.7889,0.7889
decor 3,88.8566,1.5195,0,0.9852,0.9852
decor 3,89.5556,1.2929,0,0.6164,0.6164
decor 0,89.5972,-0.3489,0,0.6958,0.6958
decor 1,91.4659,-1.5081,0,1.2924,1.1837
decor 0,93.3834,-2.1022,0,1.6160,1.4166
decor 0,95.1465,2.2439,0,0.9199,0.7511
decor 3,95.7620,-1.4557,0,0.7058,0.7058
decor 1,97.0657,1.0440,0,1.1667,1.1667
decor 0,98.9915,0.7799,0,1.0349,0.9771
decor 0,99.0717,1.2262,0,0.9544,0.9544
decor 1,99.7133,-3.1856,0,0.6298,0.6298
decor 2,100.1954,0.0941,0,0.7670,0.6322
decor 1,100.3155,-3.2532,0,0.7079,0.7079
decor 1,101.0557,1.2413,0,0.7914,0.7103
decor 0,101.2873,-0.2223,0,0.9407,0.7278
decor 3,103.1467,3.4370,0,0.8662,0.7639
decor 3,103.4773,-1.2712,0,0.6093,0.6093
decor 2,104.9397,1.8264,0,0.7939,0.7000
decor 1,105.2500,1.6628,0,0.7707,0.7707
decor 0,105.9920,-2.8005,0,0.7146,0.7146
decor 1,107.2301,0.4978,0,1.2018,1.2018
decor 1,108.0403,3.7485,0,0.6612,0.6612
decor 2,108.4204,-3.1272,0,0.9204,0.7148
decor 0,108.7611,-3.6867,0,1.6187,0.7476
decor 3,109.2041,-2.4247,0,1.6084,1.6084
decor 2,110.0238,-0.9338,0,1.4095,1.4095
decor 3,111.4407,2.9042,0,0.6064,0.6064
decor 1,111.6923,-1.1937,0,0.7409,0.7409
decor 2,113.4736,-0.2001,0,1.2221,0.9086
decor 2,114.4057,0.9877,0,0.8853,0.6105
decor 0,114.7476,-0.5029,0,0.9162,0.6867
decor 0,115.3179,2.3348,0,0.7927,0.7406
decor 1,115.3940,-1.7412,0,0.6496,0.6105
decor 3,117.3553,0.4656,0,0.9899,0.8167
decor 1,118.7246,-3.1031,0,1.6282,1.5569
decor 0,120.0875,-1.1311,0,0.8896,0.8896
decor 3,121.8853,3.5399,0,1.7141,0.7751
decor 1,123.2379,-3.9631,0,0.8699,0.7719
decor 0,124.4272,-2.7688,0,1.0418,1.0418
decor 2,126.0454,2.8512,0,0.9190,0.7502
decor 3,127.6166,-2.2425,0,1.7847,0.9278
decor 3,129.2995,0.9004,0,0.7912,0.6547
decor 3,129.9933,-1.0833,0,0.9368,0.6861
decor 2,130.6752,0.0327,0,0.9408,0.9408
decor 1,131.6307,0.6923,0,1.6225,1.6225
decor 0,133.4252,0.3639,0,1.7031,1.3155
decor 2,134.0401,-1.5089,0,1.2931,1.2931
decor 0,135.3355,2.4838,0,0.6881,0.6881
decor 1,135.6656,-3.6253,0,0.6812,0.6812
decor 3,136.6920,-2.2916,0,1.6952,1.4980
decor 0,137.0129,0.7012,0,1.7163,0.7819
decor 3,138.3130,-3.8995,0,1.0418,1.0418
decor 0,140.1387,0.3332,0,1.3404,0.7240
decor 2,141.3605,3.1097,0,0.7504,0.7467
decor 1,141.9451,-2.7303,0,0.7850,0.7850
decor 0,142.0748,2.8460,0,0.9954,0.9954
decor 1,143.0380,2.2581,0,0.7056,0.7056
decor 2,143.7732,-3.9573,0,0.8827,0.7751
decor 2,145.0806,2.8585,0,0.6800,0.6070
decor 3,145.7235,-3.9078,0,0.8779,0.7906
decor 3,146.7995,-1.3568,0,1.0383,0.8312
decor 3,148.6436,0.8429,0,0.9721,0.9168
decor 3,148.7627,-2.3387,0,0.8182,0.7520
decor 3,150.4274,0.3390,0,0.7158,0.7158
decor 2,150.6893,-0.2259,0,0.6062,0.6019
decor 2,152.4338,1.1868,0,0.7778,0.6048
decor 1,152.8438,-0.7932,0,0.8884,0.8884
decor 2,154.7534,0.6406,0,1.1233,1.1233
decor 1,155.6700,0.7687,0,0.8507,0.8507
decor 1,157.6103,2.5800,0,1.4285,1.3687
decor 0,158.5379,2.8223,0,1.4392,1.1392
decor 0,159.4286,2.8668,0,0.9436,0.6461
decor 0,159.4708,-0.6040,0,0.8708,0.8382
decor 3,160.9434,-2.5659,0,1.5720,0.7344
decor 1,161.5320,3.2796,0,1.2177,1.2177
decor 2,162.1768,-1.6053,0,1.0730,1.0730
decor 1,163.6130,0.7982,0,0.7862,0.7862
decor 1,163.8109,-1.9994,0,0.7302,0.7302
decor 0,165.1107,1.2193,0,0.9687,0.8781
decor 3,165.1714,-1.2549,0,0.8536,0.7381
decor 0,166.8174,2.9088,0,1.2599,0.7824
decor 2,167.8103,-1.8148,0,1.3031,0.8844
decor 1,168.6226,3.8437,0,1.5812,1.5812
decor 2,169.9240,-0.2051,0,1.0944,0.7381
decor 2,170.7661,2.7348,0,0.7416,0.7416
decor 2,172.4020,3.5619,0,0.9592,0.9592
decor 1,173.3941,-0.7611,0,1.3145,1.2254
decor 3,175.0108,0.0360,0,0.8530,0.8530
decor 2,176.8706,-2.5171,0,1.8325,0.8069
decor 3,177.9039,2.7301,0,0.7053,0.7053
decor 2,178.2091,2.8877,0,0.9674,0.8765
decor 0,178.7606,-2.4815,0,0.8595,0.8595
decor 3,180.0943,-1.5167,0,1.2617,1.2572
decor 3,181.8595,1.3393,0,0.9246,0.9246
decor 3,183.8205,0.8911,0,0.8041,0.6988
decor 3,183.9537,-0.3477,0,0.6853,0.6853
decor 3,184.4801,-2.1328,0,1.1340,0.8006
decor 0,185.8352,-1.8203,0,1.4832,0.7604
decor 3,186.3980,3.8956,0,1.8207,1.4017
decor 0,187.7487,0.5166,0,1.7049,1.3201
decor 2,188.3500,1.4003,0,1.0776,1.0776
decor 1,189.6145,-3.1073,0,0.8944,0.8944
decor 1,190.2179,1.9655,0,0.8541,0.8541
decor 0,190.2521,-3.7455,0,0.7258,0.6291
decor 1,191.2626,-3.7762,0,1.5363,0.8026
decor 0,192.3896,-0.2007,0,1.6836,1.5923
decor 2,193.8639,-2.1815,0,0.9220,0.9220
decor 2,195.4248,3.1724,0,0.7625,0.7625
decor 1,195.9013,-1.1863,0,0.8781,0.8781
decor 2,197.1178,3.3424,0,1.2009,1.2009
decor 1,198.1279,-2.7064,0,1.3834,1.3834
decor 0,199.7136,3.4194,0,1.5627,1.0195
decor 0,201.1643,2.7563,0,0.7121,0.6416
decor 1,201.6863,-1.6053,0,0.8309,0.8073
decor 1,203.3419,1.7914,0,1.5549,1.1041
decor 1,204.0927,-1.7618,0,1.3420,1.2664
decor 0,205.5456,2.3962,0,1.2335,1.2335
decor 3,206.3663,-1.6533,0,1.0702,1.0702
decor 0,208.1600,1.0319,0,0.9475,0.6683
decor 0,208.6106,-3.2225,0,0.6675,0.6675
decor 3,209.5038,1.0729,0,0.8594,0.8594
decor 0,209.8765,-2.3448,0,0.8472,0.8472
decor 1,210.8487,-0.8995,0,1.5590,1.5590
decor 1,211.8549,-0.6803,0,1.5641,1.4858
decor 2,213.3391,-3.1909,0,1.5483,1.1292
decor 3,214.3022,-2.2498,0,1.4566,1.4566
decor 0,215.3755,1.1485,0,1.6490,0.9543
decor 2,216.6058,1.4083,0,1.5187,1.3275
decor 1,217.0845,1.9118,0,0.9427,0.9427
decor 2,217.1742,-3.8185,0,0.7943,0.6790
decor 1,217.6351,2.8927,0,1.6276,1.0373
decor 0,218.8016,3.2507,0,0.7203,0.7203
decor 2,220.1121,-3.2071,0,1.6580,1.5083
decor 3,221.4341,1.6572,0,0.8845,0.8845
decor 1,222.6047,3.0565,0,1.6140,1.6140
decor 1,223.3992,0.8219,0,1.2269,0.7237
decor 0,224.6614,3.1765,0,1.5865,1.1487
decor 0,226.4003,2.0483,0,0.6343,0.6343
decor 0,226.4890,-1.0734,0,0.6063,0.6063
decor 2,226.7686,-0.7775,0,0.8001,0.8001
decor 1,227.2524,2.8032,0,0.8228,0.6871
decor 0,227.6437,-0.5690,0,0.7841,0.7841
decor 0,228.5909,3.0612,0,1.4410,1.4410
decor 2,230.3044,2.9646,0,1.7116,1.7116
decor 2,231.5803,0.3287,0,0.8189,0.8189
decor 0,232.5526,2.3549,0,1.0600,1.0600
decor 1,234.5409,2.7885,0,0.6040,0.6040
decor 1,234.8273,-1.1134,0,0.6615,0.6615
decor 0,235.3809,-0.3858,0,1.0173,1.0173
decor 1,236.6925,-0.2256,0,1.3229,1.3229
decor 0,237.0658,3.7087,0,0.8984,0.7127
decor 1,237.6126,-2.7627,0,0.7037,0.7037
decor 2,238.2542,1.6549,0,1.0446,1.0446
decor 1,239.5234,-2.2807,0,0.8785,0.8785
decor 2,240.1600,-1.2245,0,0.9867,0.9867
decor 3,241.9101,-0.0678,0,1.1598,1.1598
decor 3,242.4959,1.1412,0,0.9193,0.9193
decor 3,242.9606,-0.3903,0,0.9561,0.7073
decor 0,244.3138,-1.7983,0,0.8680,0.8680
decor 2,245.9274,1.4040,0,0.7566,0.7566
decor 3,247.6137,2.5903,0,1.6183,1.5370
decor 3,249.0342,-2.2488,0,1.4550,0.7002
decor 2,250.6959,-0.5009,0,0.9643,0.9643
decor 3,252.2133,1.3162,0,0.9358,0.6650
decor 1,252.3506,-1.1084,0,0.9206,0.7729
decor 2,253.9309,-1.8320,0,1.7125,1.7125
decor 0,254.3378,3.0512,0,1.4702,0.9566
decor 2,256.1221,-3.1830,0,1.0609,0.7549
decor 1,257.1594,1.0237,0,1.3562,1.3562
decor 2,258.2056,-3.2509,0,1.2729,0.9852
decor 1,259.9108,3.4733,0,1.0828,1.0828
decor 2,260.3173,1.6704,0,0.6856,0.6288
decor 2,260.3656,-0.0875,0,0.7921,0.7921
decor 1,260.8009,3.1098,0,1.1808,1.1808
decor 1,260.8009,-3.3336,0,1.6644,0.7617
decor 1,261.5980,3.0290,0,1.1438,0.8634
decor 2,262.6347,1.9903,0,0.7868,0.7868
decor 0,262.7594,-0.2747,0,0.7449,0.7449
decor 2,262.8201,0.1916,0,1.6102,1.1498
decor 3,263.4702,-3.2284,0,0.9741,0.9741
decor 0,265.3082,2.8257,0,0.7620,0.7620
decor 1,265.7623,-0.7182,0,0.7402,0.7402
decor 0,266.1283,2.3648,0,0.9434,0.6827
decor 1,266.7545,-1.5785,0,0.7390,0.7390
decor 1,268.4210,-0.5515,0,1.0973,0.7258
decor 2,270.2862,-2.8739,0,1.0085,1.0085
decor 0,272.2378,-2.3304,0,1.4246,1.2591
decor 1,273.3117,-1.7112,0,0.8635,0.8635
decor 3,274.4422,-1.0896,0,1.2847,1.2847
decor 0,275.6117,1.3630,0,1.8062,1.2566
decor 0,277.3179,-1.3468,0,1.5698,1.4194
decor 2,278.9848,0.9588,0,1.6756,1.2652
decor 0,279.2569,3.8161,0,0.8789,0.8417
decor 2,279.8811,-3.2857,0,0.8715,0.6153
decor 0,280.7302,-0.6984,0,1.0689,1.0689
decor 0,282.3516,1.4414,0,0.7148,0.7148
decor 1,282.9513,-1.5990,0,0.9203,0.8185
decor 2,283.5020,3.2013,0,0.6277,0.6216
decor 3,283.7358,-3.6225,0,0.7562,0.7562
decor 2,285.0740,3.5750,0,0.7444,0.7444
decor 2,286.4149,-3.3570,0,0.9877,0.9139
decor 2,287.4933,3.7842,0,0.8212,0.8212
decor 1,289.2628,0.7358,0,0.7286,0.7250
decor 1,289.8827,-3.2276,0,0.8883,0.6531
decor 3,290.5967,-1.5874,0,0.8560,0.8560
decor 1,292.3089,2.5559,0,0.6665,0.6665
decor 1,292.7306,-1.8555,0,0.7797,0.7797
decor 0,293.2431,3.9543,0,0.6380,0.6380
decor 0,293.9505,-0.5682,0,0.7569,0.7319
decor 2,295.0478,2.5545,0,0.6991,0.6991
decor 2,295.8602,-0.5373,0,0.8065,0.6337
decor 1,296.5041,-2.2115,0,1.4966,1.4966
decor 2,297.6540,0.2131,0,0.9681,0.7264
decor 1,297.8643,-3.6757,0,0.6752,0.6752
decor 0,298.1502,0.2794,0,0.9627,0.7772
decor 1,298.3261,-1.9377,0,0.7977,0.7648
decor 0,299.0741,2.4708,0,0.9112,0.8311
decor 2,300.6089,3.2879,0,0.8022,0.7222
decor 0,300.9335,-1.5712,0,0.9084,0.7469
decor 2,302.7633,2.1920,0,1.2421,0.8421
decor 3,304.1523,2.9125,0,0.7317,0.7317
decor 0,304.3374,-1.0925,0,0.8312,0.8312
decor 0,304.6442,-3.0123,0,1.5354,1.5354
decor 2,306.5609,2.3264,0,0.7064,0.7064
decor 2,307.7987,-2.9172,0,1.3641,0.9057
decor 2,309.1597,-2.8944,0,0.9215,0.9215
decor 2,311.0493,2.2011,0,0.9636,0.7794
decor 1,311.1491,-2.7978,0,0.7364,0.7364
decor 1,311.3484,1.0324,0,0.7524,0.7524
decor 2,312.5506,1.8627,0,0.6225,0.6225
decor 3,312.7623,-0.3048,0,0.6587,0.6587
decor 1,313.3630,-0.3080,0,1.6550,0.9701
decor 3,314.5108,1.0539,0,0.8684,0.8684
decor 3,314.6990,-0.7244,0,0.7905,0.7375
decor 1,315.4338,-0.2607,0,1.8014,1.6023
decor 0,316.8909,-1.7932,0,1.4494,1.4494
decor 2,317.4862,0.9285,0,0.9641,0.9641
decor 0,318.1198,1.0928,0,1.6375,1.4712
decor 3,319.0893,0.5419,0,0.7648,0.7648
decor 2,319.6581,-0.2190,0,0.8040,0.8040
decor 0,320.3264,0.1147,0,0.8160,0.8160
decor 1,320.7507,-1.0035,0,0.6579,0.6306
decor 2,321.2960,0.7391,0,0.8506,0.8506
decor 2,322.1966,3.8217,0,0.6174,0.6174
decor 2,322.4090,-0.7168,0,0.9363,0.7008
decor 2,323.4934,3.1060,0,0.7098,0.7098
decor 0,323.7305,-0.6549,0,0.7063,0.7063
decor 1,325.1391,1.1695,0,0.8120,0.7527
decor 2,325.6475,-0.6601,0,0.8780,0.8780
decor 0,326.0500,3.6353,0,0.7365,0.6269
decor 0,326.0961,-1.3206,0,0.7389,0.7389
decor 0,327.0221,3.6516,0,0.6123,0.6123
decor 3,327.3661,-0.9423,0,0.9393,0.8212
decor 3,329.2544,0.9000,0,1.0584,1.0584
decor 0,331.0587,2.0225,0,1.7588,0.7782
decor 3,332.0942,2.6230,0,1.6107,1.2295
decor 2,333.5487,3.2947,0,1.0656,1.0656
decor 1,335.4920,0.4348,0,1.3367,1.1384
decor 2,336.0424,1.6412,0,0.9738,0.6933
decor 1,336.6212,-1.1826,0,0.8568,0.6575
decor 2,337.8292,3.1259,0,1.5790,1.5061
decor 0,339.4012,2.4968,0,1.2444,0.9768
decor 3,341.3484,0.5946,0,1.4965,1.4951
decor 2,343.2809,-1.1720,0,0.9164,0.8761
decor 2,345.0717,-1.4560,0,0.9679,0.9679
decor 2,346.9468,2.1317,0,1.2036,1.2036
decor 2,348.2999,3.4632,0,1.3070,1.3070
decor 3,349.0856,2.5672,0,0.8202,0.8202
decor 0,349.8600,-0.7235,0,0.7649,0.7649
decor 3,350.0912,-0.8481,0,1.3427,1.3427
decor 3,351.4777,3.5690,0,1.1711,0.7619
decor 1,352.1020,2.7222,0,1.3947,1.3947
decor 0,353.2346,-3.1921,0,0.9554,0.9554
decor 3,354.0148,-3.1551,0,1.3682,1.3682
decor 2,355.7633,-1.6828,0,0.7215,0.7215
decor 0,357.7463,-0.7200,0,1.1018,1.1018
decor 3,358.3311,1.1709,0,0.6951,0.6951
decor 0,358.9014,-0.2538,0,0.9604,0.8672
decor 1,359.8848,-3.4099,0,1.1746,1.1632
decor 0,360.5852,2.5907,0,1.4204,1.0415
decor 1,361.4860,3.7407,0,1.0762,1.0762
decor 3,363.2505,-0.8625,0,1.0934,1.0934
decor 1,364.5777,1.3003,0,1.2600,0.9292
decor 1,366.5339,-2.4551,0,1.4032,1.4032
decor 1,367.2128,1.2098,0,0.8060,0.8060
decor 0,367.2356,-1.1955,0,0.7491,0.7265
decor 1,368.1812,1.7732,0,0.9012,0.6330
decor 0,368.2487,-1.9565,0,0.9353,0.7432
decor 2,369.3724,0.5969,0,0.7996,0.7029
decor 1,371.3055,1.6373,0,0.7710,0.6972
decor 1,371.5272,-2.0699,0,0.8808,0.8808
decor 2,371.6733,0.7180,0,0.8312,0.7768
decor 0,371.6733,2.7714,0,1.5795,1.5795
decor 3,373.6825,-0.3484,0,1.6844,1.5272
decor 0,375.4429,2.4970,0,0.8706,0.7953
decor 0,375.5252,-3.9931,0,0.9298,0.9298
decor 0,377.5237,0.1602,0,0.8327,0.8327
decor 1,378.5239,-2.6792,0,1.2667,1.2667
decor 3,379.2394,1.6669,0,0.6699,0.6699
decor 0,379.7900,-3.3213,0,0.8208,0.8208
decor 0,379.9350,-3.7964,0,0.8784,0.8784
decor 1,381.6300,1.1284,0,1.5431,0.8438
decor 2,382.9750,2.3435,0,0.8893,0.8893
decor 3,384.9549,2.9456,0,0.9759,0.9204
decor 2,386.0406,-2.6735,0,1.4275,1.4275
decor 2,387.6038,2.5729,0,1.5070,1.4534
decor 3,388.9871,2.0965,0,0.6990,0.6990
decor 0,388.9909,-2.2928,0,0.6973,0.6973
decor 2,389.4233,-2.6323,0,1.5742,1.1364
decor 0,391.1482,3.6625,0,0.7289,0.7289
decor 2,391.8364,-2.1659,0,0.6383,0.6155
decor 2,392.5311,3.6474,0,0.6129,0.6129
decor 0,392.8759,-3.4367,0,0.6581,0.6581
decor 2,393.3429,3.6486,0,0.6519,0.6519
decor 2,393.7855,-0.4046,0,0.7806,0.7542
decor 0,394.4310,2.6019,0,0.7725,0.6234
decor 1,394.7140,-0.3278,0,0.7015,0.7015
decor 2,395.7196,1.5997,0,0.8911,0.8911
decor 3,397.2142,0.0538,0,1.0673,0.7086
decor 1,398.4754,3.9253,0,0.7506,0.7126
decor 2,398.7288,-3.0298,0,0.7223,0.6773
decor 2,400.7287,3.8225,0,0.7668,0.7668
decor 0,401.9529,3.6919,0,1.0489,0.7016
decor 3,402.6952,1.1820,0,1.3918,1.3918
decor 0,404.6008,0.2248,0,1.4508,1.0707
decor 0,406.2753,0.4480,0,0.9358,0.6626
decor 3,406.7676,-1.6557,0,0.6943,0.6943
decor 0,406.9527,1.6675,0,1.2432,1.2021
decor 2,407.7947,-3.5572,0,1.0562,0.8327
decor 3,409.1450,-2.1050,0,1.2495,1.2495
decor 1,410.8344,-1.2068,0,1.0158,1.0158
decor 1,411.4143,1.9788,0,0.6428,0.6428
decor 1,411.8510,-3.1925,0,0.6301,0.6301
decor 0,412.6908,2.4532,0,0.7793,0.7793
decor 3,414.0531,2.8423,0,0.8707,0.8334
decor 0,414.0894,-2.0141,0,0.9670,0.6560
decor 1,415.0060,1.5673,0,0.8617,0.8447
decor 2,415.7127,-2.0352,0,0.7914,0.7914
decor 3,416.4991,3.6730,0,0.7594,0.7594
decor 1,416.8112,-0.6878,0,0.6535,0.6535
decor 3,417.9996,1.9496,0,0.7087,0.7087
decor 1,419.2865,3.9889,0,0.9512,0.7138
decor 1,419.8773,-0.5300,0,0.6312,0.6312
decor 0,421.0931,1.5120,0,0.7052,0.7052
decor 1,421.9799,-0.6869,0,0.9319,0.9202
decor 2,423.1590,-0.7901,0,1.0381,1.0381
decor 3,424.4439,-2.3155,0,1.1198,1.1198
decor 0,425.8843,1.7999,0,1.5713,0.7188
decor 1,426.5658,2.9228,0,1.6633,0.9985
decor 0,427.4388,-1.8594,0,1.0786,1.0786
decor 0,428.7475,0.4823,0,1.1675,1.1467
decor 2,429.0320,2.9843,0,0.8791,0.8791
decor 1,430.0351,0.7603,0,0.7047,0.7047
decor 3,431.6649,-2.4627,0,0.8995,0.8995
decor 0,432.7123,2.2690,0,1.8356,1.7797
decor 1,434.3297,3.5323,0,0.8927,0.7715
decor 1,435.3651,2.9282,0,1.7661,1.7661
decor 2,436.4679,-0.2265,0,0.7355,0.7355
decor 0,437.6831,3.5334,0,0.7570,0.7570
decor 0,439.1754,-2.9896,0,1.7532,0.9709
decor 3,440.0587,-1.4826,0,0.9340,0.7199
decor 2,441.0732,0.9675,0,0.8546,0.8546
decor 0,442.3474,1.5849,0,1.2132,0.7282
decor 2,443.6299,3.9107,0,1.2855,1.2855
decor 3,444.9500,-1.7814,0,1.5498,1.2054
decor 2,445.8268,1.3166,0,0.7882,0.7882
decor 3,447.6803,-1.0503,0,1.3332,1.2154
decor 3,448.5774,0.7928,0,1.8034,1.2454
decor 1,450.0793,-1.3687,0,0.9900,0.9900
decor 0,451.5889,3.1628,0,0.9634,0.7280
decor 1,453.0037,1.6288,0,0.7794,0.7794
decor 2,453.9421,-3.3202,0,0.9579,0.8039
decor 3,455.1846,3.4371,0,0.7080,0.7080
decor 0,455.2313,-1.6691,0,0.8445,0.8445
decor 2,456.2162,0.0541,0,0.8301,0.8301
decor 2,456.9503,-0.5381,0,0.8803,0.6053
decor 2,457.3414,1.7504,0,0.7372,0.7372
decor 3,458.0659,3.7920,0,0.7287,0.7287
decor 3,458.5816,-2.9652,0,0.7300,0.6742
decor 3,459.0229,1.9752,0,0.8568,0.8568
decor 0,459.9680,-1.1477,0,0.6976,0.6976
decor 2,460.5163,-2.5891,0,0.8024,0.8024
decor 0,462.3837,0.3900,0,0.7299,0.7299
decor 3,463.7413,2.2947,0,1.2432,1.2432
decor 2,464.1651,0.6032,0,0.9696,0.9696
decor 2,464.4887,-0.8912,0,0.7654,0.6740
decor 0,465.5458,-2.8371,0,1.3925,1.3925
decor 0,466.4051,-0.9204,0,1.4663,0.9908
decor 3,468.1541,1.6043,0,1.4160,0.9150
decor 2,469.2802,-3.9139,0,1.2654,1.2654
decor 2,471.2770,2.9312,0,1.5736,0.8406
decor 0,472.6537,0.8775,0,1.4276,1.4276
decor 0,473.9028,3.6203,0,1.2152,1.0462
decor 0,475.0987,-0.7199,0,1.2081,1.2081
decor 2,476.2891,0.1223,0,1.5993,1.1598
decor 2,477.5184,0.1817,0,1.4141,0.7494
decor 0,479.2284,0.6486,0,0.9255,0.9255
decor 1,480.5184,-0.7710,0,1.7642,1.5001
decor 2,481.2232,3.5574,0,1.0247,1.0247
decor 0,482.7854,-3.5015,0,0.7094,0.7094
decor 3,483.4559,0.8435,0,0.9157,0.9157
decor 3,484.4696,-1.9870,0,1.5559,1.1980
decor 2,485.6583,0.5685,0,0.7929,0.7929
decor 2,487.2201,2.0530,0,0.9563,0.7324
decor 1,487.5832,-3.5765,0,0.6606,0.6057
decor 3,488.7915,-3.9441,0,1.2516,0.8794
decor 2,489.5707,1.9978,0,0.9196,0.7652
decor 2,489.8013,-2.3129,0,0.8001,0.6022
decor 0,491.7336,-0.5586,0,1.1677,1.1677
decor 1,493.6035,3.3421,0,1.7318,1.0731
decor 3,494.6379,1.8786,0,0.7500,0.7500
decor 2,494.6610,-1.2072,0,0.7639,0.7639
decor 1,496.0396,3.3750,0,0.6755,0.6755
decor 1,496.8287,-1.3675,0,0.8790,0.8790
decor 0,498.5963,3.1679,0,1.6853,1.2943
decor 1,500.5475,-3.6631,0,0.8549,0.8549
decor 3,502.4945,3.9478,0,1.8258,1.3572
decor 3,504.1255,-0.2470,0,1.3282,1.1677
decor 1,505.9277,-0.8869,0,1.7361,1.1148
decor 1,506.4914,3.6488,0,1.4840,1.4692
decor 2,507.1103,-0.2845,0,0.8601,0.8601
decor 0,508.8063,0.8864,0,0.9380,0.9380
decor 2,509.6557,0.1226,0,1.6795,1.4932
decor 0,510.1287,3.4875,0,0.9101,0.8080
decor 1,510.2001,-1.7283,0,0.8041,0.8041
decor 3,510.8213,-2.1547,0,1.1165,1.1165
decor 1,511.9475,3.9334,0,0.9279,0.9279
decor 2,513.7313,0.5433,0,1.1550,1.1550
decor 2,514.2893,-3.9409,0,1.7080,0.8864
decor 1,515.0481,0.6941,0,0.7901,0.7901
decor 3,515.2754,-3.0720,0,0.7285,0.7285
decor 3,516.7264,-0.9040,0,0.9944,0.9944
decor 0,517.6239,-2.5950,0,1.4975,1.4975
decor 0,519.1016,-2.9604,0,0.7943,0.7943
decor 2,520.5391,-2.3666,0,0.9164,0.7903
decor 0,521.8364,-1.7876,0,1.0494,1.0494
decor 1,522.7081,-3.7221,0,1.4452,1.1909
decor 2,523.3313,2.1438,0,0.6867,0.6867
decor 2,523.9120,-0.7870,0,0.9461,0.8604
decor 1,523.9650,0.7398,0,1.3320,1.3320
decor 1,524.8402,0.5882,0,1.6573,1.1243
decor 1,526.3948,3.4834,0,0.6607,0.6607
decor 0,526.6132,-1.0450,0,0.8813,0.6858
decor 3,528.1564,1.2005,0,0.9439,0.8988
decor 3,528.8229,-0.8700,0,0.8486,0.6528
decor 1,529.9963,3.2278,0,1.6044,1.4442
decor 1,530.4466,3.2785,0,1.0200,0.8179
decor 3,531.9951,-1.8519,0,0.8799,0.8799
decor 0,533.3795,0.9885,0,0.8249,0.8249
decor 1,534.6403,-0.9231,0,1.2843,1.2682
decor 3,535.9940,-1.9174,0,1.6140,1.5986
decor 1,536.2990,-1.7422,0,1.7256,0.8150
decor 3,537.7038,1.9360,0,1.2120,1.2120
decor 3,539.4059,3.1657,0,0.9157,0.7496
decor 2,539.4387,-0.7439,0,0.9689,0.7417
decor 0,540.6547,0.2141,0,1.2702,0.9900
decor 2,542.6265,2.7355,0,0.7374,0.7374
decor 1,543.9075,-1.8126,0,1.5203,1.2071
decor 3,544.1135,3.0902,0,0.8675,0.7735
decor 2,544.7821,-1.9286,0,0.7782,0.7293
decor 3,544.7831,1.1434,0,1.2765,0.7214
decor 0,545.7270,0.1390,0,1.6416,1.5648
decor 2,547.0858,2.0990,0,0.6738,0.6738
decor 3,547.5351,-3.0626,0,0.8650,0.6275
decor 2,548.2514,1.4685,0,0.6626,0.6626
decor 3,548.3466,-0.3975,0,0.9190,0.7704
decor 0,548.3655,-2.7601,0,1.2483,1.2483
decor 1,549.5383,1.8120,0,0.9093,0.9093
decor 0,550.3043,3.9109,0,1.2409,0.7234
decor 0,551.2751,-3.1600,0,1.0776,1.0776
decor 0,552.6197,-1.7244,0,1.4902,1.4902
decor 2,553.7900,-3.0341,0,1.8196,1.8114
decor 2,554.7191,2.3287,0,1.0607,0.8419
decor 1,555.4183,-1.9068,0,1.5900,1.4739
decor 2,556.1973,0.3340,0,0.6847,0.6847
decor 0,556.3401,-1.3534,0,0.7333,0.6564
decor 3,557.5298,-3.0927,0,1.5125,0.9182
decor 0,559.2485,1.0119,0,1.5259,1.0747
decor 1,560.4266,0.3915,0,0.8866,0.8866
decor 3,560.7789,-2.6629,0,0.8615,0.6857
decor 1,561.3498,-2.6115,0,1.7759,1.3483
decor 0,562.2419,3.8258,0,0.7958,0.7958
decor 2,563.5129,-3.2483,0,1.3557,0.9367
decor 1,564.9223,1.1019,0,0.9769,0.9769
decor 0,565.6817,-2.4217,0,1.7113,1.0612
decor 3,567.6320,1.4433,0,1.4132,1.3137
decor 1,568.5377,2.6754,0,1.4234,1.2244
decor 3,570.5209,0.5029,0,0.8325,0.8325
decor 3,571.7170,2.3073,0,1.2269,1.2269
decor 0,573.3337,-0.2088,0,1.3788,0.7443
decor 0,575.0894,-0.3979,0,0.7912,0.7107
decor 3,576.8864,0.0812,0,1.8419,0.8700
decor 1,577.4532,0.7168,0,0.6068,0.6068
decor 3,577.7849,-1.2090,0,0.7200,0.7200
decor 2,579.0992,-1.7037,0,0.7794,0.7660
decor 0,580.1513,3.1735,0,0.7360,0.6742
decor 2,580.4406,-2.0498,0,0.6245,0.6245
decor 3,582.1564,3.9425,0,0.7225,0.7225
decor 0,582.4333,-2.3456,0,0.6106,0.6106
decor 1,583.1081,1.0073,0,0.9065,0.9065
decor 3,583.6482,-3.5247,0,0.6136,0.6136
decor 2,585.1362,0.8749,0,0.6804,0.6804
decor 3,585.4779,-1.6636,0,0.6980,0.6261
decor 3,586.3952,3.3649,0,0.7208,0.7208
decor 1,586.4490,-0.1329,0,0.9707,0.8781
decor 1,588.1222,-3.5586,0,1.0821,1.0821
decor 0,589.7798,0.9804,0,1.4260,1.4260
decor 3,590.1531,1.8705,0,0.8070,0.7557
decor 0,590.9355,-3.3460,0,0.6473,0.6473
decor 3,591.1291,2.3594,0,0.6965,0.6965
decor 1,591.8010,-1.7093,0,0.9635,0.8454
decor 3,593.3163,0.6296,0,1.2101,1.2101
decor 1,594.8916,3.5128,0,1.7825,1.6497
decor 3,595.1272,2.3269,0,1.1155,1.1155
decor 3,596.4629,-0.0777,0,1.2716,1.2716
decor 1,597.9276,-3.9407,0,0.8973,0.8973

decor_end
