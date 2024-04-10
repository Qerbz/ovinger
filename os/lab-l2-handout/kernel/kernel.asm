
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	b5010113          	addi	sp,sp,-1200 # 80008b50 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	9c070713          	addi	a4,a4,-1600 # 80008a10 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	04e78793          	addi	a5,a5,78 # 800060b0 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdc87f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:

//
// user write()s to the console go here.
//
int consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
    int i;

    for (i = 0; i < n; i++)
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    {
        char c;
        if (either_copyin(&c, user_src, src + i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	718080e7          	jalr	1816(ra) # 80002842 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
            break;
        uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
    for (i = 0; i < n; i++)
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
    }

    return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
    for (i = 0; i < n; i++)
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// copy (up to) a whole input line to dst.
// user_dist indicates whether dst is a user
// or kernel address.
//
int consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
    uint target;
    int c;
    char cbuf;

    target = n;
    80000180:	00060b1b          	sext.w	s6,a2
    acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	9cc50513          	addi	a0,a0,-1588 # 80010b50 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
    while (n > 0)
    {
        // wait until interrupt handler has put some
        // input into cons.buffer.
        while (cons.r == cons.w)
    80000194:	00011497          	auipc	s1,0x11
    80000198:	9bc48493          	addi	s1,s1,-1604 # 80010b50 <cons>
            if (killed(myproc()))
            {
                release(&cons.lock);
                return -1;
            }
            sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	a4c90913          	addi	s2,s2,-1460 # 80010be8 <cons+0x98>
    while (n > 0)
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
        while (cons.r == cons.w)
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
            if (killed(myproc()))
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	aa8080e7          	jalr	-1368(ra) # 80001c5c <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	4d0080e7          	jalr	1232(ra) # 8000268c <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
            sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	21a080e7          	jalr	538(ra) # 800023e4 <sleep>
        while (cons.r == cons.w)
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
        }

        c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	97270713          	addi	a4,a4,-1678 # 80010b50 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

        if (c == C('D'))
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
            }
            break;
        }

        // copy the input byte to the user-space buffer.
        cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
        if (either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	5dc080e7          	jalr	1500(ra) # 800027ec <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
            break;

        dst++;
    8000021e:	0a05                	addi	s4,s4,1
        --n;
    80000220:	39fd                	addiw	s3,s3,-1

        if (c == '\n')
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
            // a whole line has arrived, return to
            // the user-level read().
            break;
        }
    }
    release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	92850513          	addi	a0,a0,-1752 # 80010b50 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

    return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
                release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	91250513          	addi	a0,a0,-1774 # 80010b50 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
                return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
            if (n < target)
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
                cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	96f72d23          	sw	a5,-1670(a4) # 80010be8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
    if (c == BACKSPACE)
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
        uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
        uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
        uartputc_sync(' ');
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
        uartputc_sync('\b');
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// uartintr() calls this for input character.
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
    acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	88850513          	addi	a0,a0,-1912 # 80010b50 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

    switch (c)
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
    {
    case C('P'): // Print process list.
        procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	5aa080e7          	jalr	1450(ra) # 80002898 <procdump>
            }
        }
        break;
    }

    release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	85a50513          	addi	a0,a0,-1958 # 80010b50 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
    switch (c)
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	83670713          	addi	a4,a4,-1994 # 80010b50 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
            c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
            consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00011797          	auipc	a5,0x11
    80000348:	80c78793          	addi	a5,a5,-2036 # 80010b50 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
            if (c == '\n' || c == C('D') || cons.e - cons.r == INPUT_BUF_SIZE)
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	8767a783          	lw	a5,-1930(a5) # 80010be8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
        while (cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	7ca70713          	addi	a4,a4,1994 # 80010b50 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	7ba48493          	addi	s1,s1,1978 # 80010b50 <cons>
        while (cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
               cons.buf[(cons.e - 1) % INPUT_BUF_SIZE] != '\n')
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
        while (cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
            cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
            consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
        while (cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
        if (cons.e != cons.w)
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	77e70713          	addi	a4,a4,1918 # 80010b50 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
            cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	80f72423          	sw	a5,-2040(a4) # 80010bf0 <cons+0xa0>
            consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
        if (c != 0 && cons.e - cons.r < INPUT_BUF_SIZE)
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
            consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
            cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	74278793          	addi	a5,a5,1858 # 80010b50 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
                cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	7ac7ad23          	sw	a2,1978(a5) # 80010bec <cons+0x9c>
                wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	7ae50513          	addi	a0,a0,1966 # 80010be8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	006080e7          	jalr	6(ra) # 80002448 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
    initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	6f450513          	addi	a0,a0,1780 # 80010b50 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

    uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

    // connect read and write system calls
    // to consoleread and consolewrite.
    devsw[CONSOLE].read = consoleread;
    80000474:	00021797          	auipc	a5,0x21
    80000478:	97478793          	addi	a5,a5,-1676 # 80020de8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
    devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	6c07a423          	sw	zero,1736(a5) # 80010c10 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	44f72a23          	sw	a5,1108(a4) # 800089d0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	658dad83          	lw	s11,1624(s11) # 80010c10 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	60250513          	addi	a0,a0,1538 # 80010bf8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	4a450513          	addi	a0,a0,1188 # 80010bf8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	48848493          	addi	s1,s1,1160 # 80010bf8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	44850513          	addi	a0,a0,1096 # 80010c18 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	1d47a783          	lw	a5,468(a5) # 800089d0 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	1a47b783          	ld	a5,420(a5) # 800089d8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	1a473703          	ld	a4,420(a4) # 800089e0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	3baa0a13          	addi	s4,s4,954 # 80010c18 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	17248493          	addi	s1,s1,370 # 800089d8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	17298993          	addi	s3,s3,370 # 800089e0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	bb8080e7          	jalr	-1096(ra) # 80002448 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	34c50513          	addi	a0,a0,844 # 80010c18 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	0f47a783          	lw	a5,244(a5) # 800089d0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	0fa73703          	ld	a4,250(a4) # 800089e0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	0ea7b783          	ld	a5,234(a5) # 800089d8 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	31e98993          	addi	s3,s3,798 # 80010c18 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	0d648493          	addi	s1,s1,214 # 800089d8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	0d690913          	addi	s2,s2,214 # 800089e0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	aca080e7          	jalr	-1334(ra) # 800023e4 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	2e848493          	addi	s1,s1,744 # 80010c18 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	08e7be23          	sd	a4,156(a5) # 800089e0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	26248493          	addi	s1,s1,610 # 80010c18 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	58878793          	addi	a5,a5,1416 # 80021f80 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	23890913          	addi	s2,s2,568 # 80010c50 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	19a50513          	addi	a0,a0,410 # 80010c50 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	4b650513          	addi	a0,a0,1206 # 80021f80 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	16448493          	addi	s1,s1,356 # 80010c50 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	14c50513          	addi	a0,a0,332 # 80010c50 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	12050513          	addi	a0,a0,288 # 80010c50 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	0d4080e7          	jalr	212(ra) # 80001c40 <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	0a2080e7          	jalr	162(ra) # 80001c40 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	096080e7          	jalr	150(ra) # 80001c40 <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	07e080e7          	jalr	126(ra) # 80001c40 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	03e080e7          	jalr	62(ra) # 80001c40 <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	012080e7          	jalr	18(ra) # 80001c40 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd081>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	db6080e7          	jalr	-586(ra) # 80001c30 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	b6670713          	addi	a4,a4,-1178 # 800089e8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	d9a080e7          	jalr	-614(ra) # 80001c30 <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	c68080e7          	jalr	-920(ra) # 80002b20 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	230080e7          	jalr	560(ra) # 800060f0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	3da080e7          	jalr	986(ra) # 800022a2 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	c0e080e7          	jalr	-1010(ra) # 80001b36 <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	bc8080e7          	jalr	-1080(ra) # 80002af8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	be8080e7          	jalr	-1048(ra) # 80002b20 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	19a080e7          	jalr	410(ra) # 800060da <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	1a8080e7          	jalr	424(ra) # 800060f0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	3a0080e7          	jalr	928(ra) # 800032f0 <binit>
    iinit();         // inode table
    80000f58:	00003097          	auipc	ra,0x3
    80000f5c:	a3e080e7          	jalr	-1474(ra) # 80003996 <iinit>
    fileinit();      // file table
    80000f60:	00004097          	auipc	ra,0x4
    80000f64:	9b4080e7          	jalr	-1612(ra) # 80004914 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	290080e7          	jalr	656(ra) # 800061f8 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	fc4080e7          	jalr	-60(ra) # 80001f34 <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	a6f72523          	sw	a5,-1430(a4) # 800089e8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	a5e7b783          	ld	a5,-1442(a5) # 800089f0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd077>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00001097          	auipc	ra,0x1
    8000122c:	878080e7          	jalr	-1928(ra) # 80001aa0 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	7aa7b123          	sd	a0,1954(a5) # 800089f0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd080>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <rr_scheduler>:
        (*sched_pointer)();
    }
}

void rr_scheduler(void)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
  asm volatile("mv %0, tp" : "=r" (x) );
    80001844:	8792                	mv	a5,tp
    int id = r_tp();
    80001846:	2781                	sext.w	a5,a5
    struct proc *p;
    struct cpu *c = mycpu();

    c->proc = 0;
    80001848:	0000fa97          	auipc	s5,0xf
    8000184c:	428a8a93          	addi	s5,s5,1064 # 80010c70 <cpus>
    80001850:	00779713          	slli	a4,a5,0x7
    80001854:	00ea86b3          	add	a3,s5,a4
    80001858:	0006b023          	sd	zero,0(a3) # fffffffffffff000 <end+0xffffffff7ffdd080>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000185c:	100026f3          	csrr	a3,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001860:	0026e693          	ori	a3,a3,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001864:	10069073          	csrw	sstatus,a3
            // Switch to chosen process.  It is the process's job
            // to release its lock and then reacquire it
            // before jumping back to us.
            p->state = RUNNING;
            c->proc = p;
            swtch(&c->context, &p->context);
    80001868:	0721                	addi	a4,a4,8
    8000186a:	9aba                	add	s5,s5,a4
    for (p = proc; p < &proc[NPROC]; p++)
    8000186c:	00010497          	auipc	s1,0x10
    80001870:	93448493          	addi	s1,s1,-1740 # 800111a0 <proc>
        if (p->state == RUNNABLE)
    80001874:	498d                	li	s3,3
            p->state = RUNNING;
    80001876:	4b11                	li	s6,4
            c->proc = p;
    80001878:	079e                	slli	a5,a5,0x7
    8000187a:	0000fa17          	auipc	s4,0xf
    8000187e:	3f6a0a13          	addi	s4,s4,1014 # 80010c70 <cpus>
    80001882:	9a3e                	add	s4,s4,a5
    for (p = proc; p < &proc[NPROC]; p++)
    80001884:	00015917          	auipc	s2,0x15
    80001888:	31c90913          	addi	s2,s2,796 # 80016ba0 <tickslock>
    8000188c:	a811                	j	800018a0 <rr_scheduler+0x70>

            // Process is done running for now.
            // It should have changed its p->state before coming back.
            c->proc = 0;
        }
        release(&p->lock);
    8000188e:	8526                	mv	a0,s1
    80001890:	fffff097          	auipc	ra,0xfffff
    80001894:	3f6080e7          	jalr	1014(ra) # 80000c86 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001898:	16848493          	addi	s1,s1,360
    8000189c:	03248863          	beq	s1,s2,800018cc <rr_scheduler+0x9c>
        acquire(&p->lock);
    800018a0:	8526                	mv	a0,s1
    800018a2:	fffff097          	auipc	ra,0xfffff
    800018a6:	330080e7          	jalr	816(ra) # 80000bd2 <acquire>
        if (p->state == RUNNABLE)
    800018aa:	4c9c                	lw	a5,24(s1)
    800018ac:	ff3791e3          	bne	a5,s3,8000188e <rr_scheduler+0x5e>
            p->state = RUNNING;
    800018b0:	0164ac23          	sw	s6,24(s1)
            c->proc = p;
    800018b4:	009a3023          	sd	s1,0(s4)
            swtch(&c->context, &p->context);
    800018b8:	06048593          	addi	a1,s1,96
    800018bc:	8556                	mv	a0,s5
    800018be:	00001097          	auipc	ra,0x1
    800018c2:	1d0080e7          	jalr	464(ra) # 80002a8e <swtch>
            c->proc = 0;
    800018c6:	000a3023          	sd	zero,0(s4)
    800018ca:	b7d1                	j	8000188e <rr_scheduler+0x5e>
    }
    // In case a setsched happened, we will switch to the new scheduler after one
    // Round Robin round has completed.
}
    800018cc:	70e2                	ld	ra,56(sp)
    800018ce:	7442                	ld	s0,48(sp)
    800018d0:	74a2                	ld	s1,40(sp)
    800018d2:	7902                	ld	s2,32(sp)
    800018d4:	69e2                	ld	s3,24(sp)
    800018d6:	6a42                	ld	s4,16(sp)
    800018d8:	6aa2                	ld	s5,8(sp)
    800018da:	6b02                	ld	s6,0(sp)
    800018dc:	6121                	addi	sp,sp,64
    800018de:	8082                	ret

00000000800018e0 <mlfq_scheduler>:
        release(&p->lock);
    } while(p);
}*/

void mlfq_scheduler(void)
{
    800018e0:	7119                	addi	sp,sp,-128
    800018e2:	fc86                	sd	ra,120(sp)
    800018e4:	f8a2                	sd	s0,112(sp)
    800018e6:	f4a6                	sd	s1,104(sp)
    800018e8:	f0ca                	sd	s2,96(sp)
    800018ea:	ecce                	sd	s3,88(sp)
    800018ec:	e8d2                	sd	s4,80(sp)
    800018ee:	e4d6                	sd	s5,72(sp)
    800018f0:	e0da                	sd	s6,64(sp)
    800018f2:	fc5e                	sd	s7,56(sp)
    800018f4:	f862                	sd	s8,48(sp)
    800018f6:	f466                	sd	s9,40(sp)
    800018f8:	f06a                	sd	s10,32(sp)
    800018fa:	ec6e                	sd	s11,24(sp)
    800018fc:	0100                	addi	s0,sp,128
  asm volatile("mv %0, tp" : "=r" (x) );
    800018fe:	8792                	mv	a5,tp
    int id = r_tp();
    80001900:	2781                	sext.w	a5,a5
    80001902:	f8f43023          	sd	a5,-128(s0)

    /*
    * If a job uses up the entire allocated time slice, its priority is reduced 
    * (moved to a lower priority queue)
    */
    if(last_proc){
    80001906:	00007797          	auipc	a5,0x7
    8000190a:	0f67a783          	lw	a5,246(a5) # 800089fc <last_proc>
    8000190e:	cf91                	beqz	a5,8000192a <mlfq_scheduler+0x4a>
        priority_array[last_proc] = 2;
    80001910:	078a                	slli	a5,a5,0x2
    80001912:	0000f717          	auipc	a4,0xf
    80001916:	35e70713          	addi	a4,a4,862 # 80010c70 <cpus>
    8000191a:	97ba                	add	a5,a5,a4
    8000191c:	4709                	li	a4,2
    8000191e:	40e7a023          	sw	a4,1024(a5)
        last_proc = 0;
    80001922:	00007797          	auipc	a5,0x7
    80001926:	0c07ad23          	sw	zero,218(a5) # 800089fc <last_proc>
    }

    reset_counter++;
    8000192a:	00007717          	auipc	a4,0x7
    8000192e:	0ce70713          	addi	a4,a4,206 # 800089f8 <reset_counter>
    80001932:	431c                	lw	a5,0(a4)
    80001934:	2785                	addiw	a5,a5,1
    80001936:	0007869b          	sext.w	a3,a5
    8000193a:	c31c                	sw	a5,0(a4)
    
    //Every 100 scheduler interrupts move all programs to topmost queue
    if(reset_counter == 100)
    8000193c:	06400793          	li	a5,100
    80001940:	06f68063          	beq	a3,a5,800019a0 <mlfq_scheduler+0xc0>
        for (int i = 0; i<NPROC;i++)
            priority_array[i] = 1;

    c->proc = 0;
    80001944:	0000f697          	auipc	a3,0xf
    80001948:	32c68693          	addi	a3,a3,812 # 80010c70 <cpus>
    8000194c:	f8043603          	ld	a2,-128(s0)
    80001950:	00761793          	slli	a5,a2,0x7
    80001954:	00f68733          	add	a4,a3,a5
    80001958:	00073023          	sd	zero,0(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000195c:	10002773          	csrr	a4,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001960:	00276713          	ori	a4,a4,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001964:	10071073          	csrw	sstatus,a4
                // to release its lock and then reacquire it
                // before jumping back to us.
                last_proc = i;
                p->state = RUNNING;
                c->proc = p;
                swtch(&c->context, &p->context);
    80001968:	07a1                	addi	a5,a5,8
    8000196a:	97b6                	add	a5,a5,a3
    8000196c:	f8f43423          	sd	a5,-120(s0)
    80001970:	0000f997          	auipc	s3,0xf
    80001974:	70098993          	addi	s3,s3,1792 # 80011070 <priority_array>
    80001978:	00010497          	auipc	s1,0x10
    8000197c:	82848493          	addi	s1,s1,-2008 # 800111a0 <proc>
    80001980:	8aa6                	mv	s5,s1
    80001982:	8a4e                	mv	s4,s3
    for (int i = 0; i < NPROC; i++)
    80001984:	4901                	li	s2,0
        if(priority_array[i] == 1)
    80001986:	4b85                	li	s7,1
            if (p->state == RUNNABLE)
    80001988:	4c8d                	li	s9,3
                last_proc = i;
    8000198a:	00007d97          	auipc	s11,0x7
    8000198e:	072d8d93          	addi	s11,s11,114 # 800089fc <last_proc>
                c->proc = p;
    80001992:	00761793          	slli	a5,a2,0x7
    80001996:	00f68d33          	add	s10,a3,a5
    for (int i = 0; i < NPROC; i++)
    8000199a:	04000b13          	li	s6,64
    8000199e:	a815                	j	800019d2 <mlfq_scheduler+0xf2>
    800019a0:	0000f797          	auipc	a5,0xf
    800019a4:	6d078793          	addi	a5,a5,1744 # 80011070 <priority_array>
    800019a8:	0000f697          	auipc	a3,0xf
    800019ac:	7c868693          	addi	a3,a3,1992 # 80011170 <pid_lock>
            priority_array[i] = 1;
    800019b0:	4705                	li	a4,1
    800019b2:	c398                	sw	a4,0(a5)
        for (int i = 0; i<NPROC;i++)
    800019b4:	0791                	addi	a5,a5,4
    800019b6:	fed79ee3          	bne	a5,a3,800019b2 <mlfq_scheduler+0xd2>
    800019ba:	b769                	j	80001944 <mlfq_scheduler+0x64>
                // Process is done running for now.
                // It should have changed its p->state before coming back.
                c->proc = 0;
                last_proc = 0;
            }
            release(&p->lock);
    800019bc:	8562                	mv	a0,s8
    800019be:	fffff097          	auipc	ra,0xfffff
    800019c2:	2c8080e7          	jalr	712(ra) # 80000c86 <release>
    for (int i = 0; i < NPROC; i++)
    800019c6:	2905                	addiw	s2,s2,1
    800019c8:	0a11                	addi	s4,s4,4
    800019ca:	168a8a93          	addi	s5,s5,360
    800019ce:	05690463          	beq	s2,s6,80001a16 <mlfq_scheduler+0x136>
        if(priority_array[i] == 1)
    800019d2:	000a2783          	lw	a5,0(s4)
    800019d6:	ff7798e3          	bne	a5,s7,800019c6 <mlfq_scheduler+0xe6>
            p = &proc[i];
    800019da:	8c56                	mv	s8,s5
            acquire(&p->lock);
    800019dc:	8556                	mv	a0,s5
    800019de:	fffff097          	auipc	ra,0xfffff
    800019e2:	1f4080e7          	jalr	500(ra) # 80000bd2 <acquire>
            if (p->state == RUNNABLE)
    800019e6:	018aa783          	lw	a5,24(s5)
    800019ea:	fd9799e3          	bne	a5,s9,800019bc <mlfq_scheduler+0xdc>
                last_proc = i;
    800019ee:	012da023          	sw	s2,0(s11)
                p->state = RUNNING;
    800019f2:	4791                	li	a5,4
    800019f4:	00faac23          	sw	a5,24(s5)
                c->proc = p;
    800019f8:	015d3023          	sd	s5,0(s10)
                swtch(&c->context, &p->context);
    800019fc:	060a8593          	addi	a1,s5,96
    80001a00:	f8843503          	ld	a0,-120(s0)
    80001a04:	00001097          	auipc	ra,0x1
    80001a08:	08a080e7          	jalr	138(ra) # 80002a8e <swtch>
                c->proc = 0;
    80001a0c:	000d3023          	sd	zero,0(s10)
                last_proc = 0;
    80001a10:	000da023          	sw	zero,0(s11)
    80001a14:	b765                	j	800019bc <mlfq_scheduler+0xdc>
    80001a16:	6919                	lui	s2,0x6
    80001a18:	a0090913          	addi	s2,s2,-1536 # 5a00 <_entry-0x7fffa600>
    80001a1c:	9926                	add	s2,s2,s1
        }
    }

    for (int i = 0; i < NPROC; i++)
    {
        if(priority_array[i] == 2)
    80001a1e:	4a09                	li	s4,2
        {
            p = &proc[i];
            acquire(&p->lock);
            if (p->state == RUNNABLE)
    80001a20:	4b0d                	li	s6,3
            {
                // Switch to chosen process.  It is the process's job
                // to release its lock and then reacquire it
                // before jumping back to us.
                p->state = RUNNING;
    80001a22:	4b91                	li	s7,4
                c->proc = p;
    80001a24:	f8043783          	ld	a5,-128(s0)
    80001a28:	079e                	slli	a5,a5,0x7
    80001a2a:	0000fc17          	auipc	s8,0xf
    80001a2e:	246c0c13          	addi	s8,s8,582 # 80010c70 <cpus>
    80001a32:	9c3e                	add	s8,s8,a5
    80001a34:	a819                	j	80001a4a <mlfq_scheduler+0x16a>

                // Process is done running for now.
                // It should have changed its p->state before coming back.
                c->proc = 0;
            }
            release(&p->lock);
    80001a36:	8556                	mv	a0,s5
    80001a38:	fffff097          	auipc	ra,0xfffff
    80001a3c:	24e080e7          	jalr	590(ra) # 80000c86 <release>
    for (int i = 0; i < NPROC; i++)
    80001a40:	0991                	addi	s3,s3,4
    80001a42:	16848493          	addi	s1,s1,360
    80001a46:	03248e63          	beq	s1,s2,80001a82 <mlfq_scheduler+0x1a2>
        if(priority_array[i] == 2)
    80001a4a:	0009a783          	lw	a5,0(s3)
    80001a4e:	ff4799e3          	bne	a5,s4,80001a40 <mlfq_scheduler+0x160>
            p = &proc[i];
    80001a52:	8aa6                	mv	s5,s1
            acquire(&p->lock);
    80001a54:	8526                	mv	a0,s1
    80001a56:	fffff097          	auipc	ra,0xfffff
    80001a5a:	17c080e7          	jalr	380(ra) # 80000bd2 <acquire>
            if (p->state == RUNNABLE)
    80001a5e:	4c9c                	lw	a5,24(s1)
    80001a60:	fd679be3          	bne	a5,s6,80001a36 <mlfq_scheduler+0x156>
                p->state = RUNNING;
    80001a64:	0174ac23          	sw	s7,24(s1)
                c->proc = p;
    80001a68:	009c3023          	sd	s1,0(s8)
                swtch(&c->context, &p->context);
    80001a6c:	06048593          	addi	a1,s1,96
    80001a70:	f8843503          	ld	a0,-120(s0)
    80001a74:	00001097          	auipc	ra,0x1
    80001a78:	01a080e7          	jalr	26(ra) # 80002a8e <swtch>
                c->proc = 0;
    80001a7c:	000c3023          	sd	zero,0(s8)
    80001a80:	bf5d                	j	80001a36 <mlfq_scheduler+0x156>
        }
    }
    // In case a setsched happened, we will switch to the new scheduler after one
    // Round Robin round has completed.
}
    80001a82:	70e6                	ld	ra,120(sp)
    80001a84:	7446                	ld	s0,112(sp)
    80001a86:	74a6                	ld	s1,104(sp)
    80001a88:	7906                	ld	s2,96(sp)
    80001a8a:	69e6                	ld	s3,88(sp)
    80001a8c:	6a46                	ld	s4,80(sp)
    80001a8e:	6aa6                	ld	s5,72(sp)
    80001a90:	6b06                	ld	s6,64(sp)
    80001a92:	7be2                	ld	s7,56(sp)
    80001a94:	7c42                	ld	s8,48(sp)
    80001a96:	7ca2                	ld	s9,40(sp)
    80001a98:	7d02                	ld	s10,32(sp)
    80001a9a:	6de2                	ld	s11,24(sp)
    80001a9c:	6109                	addi	sp,sp,128
    80001a9e:	8082                	ret

0000000080001aa0 <proc_mapstacks>:
{
    80001aa0:	7139                	addi	sp,sp,-64
    80001aa2:	fc06                	sd	ra,56(sp)
    80001aa4:	f822                	sd	s0,48(sp)
    80001aa6:	f426                	sd	s1,40(sp)
    80001aa8:	f04a                	sd	s2,32(sp)
    80001aaa:	ec4e                	sd	s3,24(sp)
    80001aac:	e852                	sd	s4,16(sp)
    80001aae:	e456                	sd	s5,8(sp)
    80001ab0:	e05a                	sd	s6,0(sp)
    80001ab2:	0080                	addi	s0,sp,64
    80001ab4:	89aa                	mv	s3,a0
    for (p = proc; p < &proc[NPROC]; p++)
    80001ab6:	0000f497          	auipc	s1,0xf
    80001aba:	6ea48493          	addi	s1,s1,1770 # 800111a0 <proc>
        uint64 va = KSTACK((int)(p - proc));
    80001abe:	8b26                	mv	s6,s1
    80001ac0:	00006a97          	auipc	s5,0x6
    80001ac4:	540a8a93          	addi	s5,s5,1344 # 80008000 <etext>
    80001ac8:	04000937          	lui	s2,0x4000
    80001acc:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001ace:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001ad0:	00015a17          	auipc	s4,0x15
    80001ad4:	0d0a0a13          	addi	s4,s4,208 # 80016ba0 <tickslock>
        char *pa = kalloc();
    80001ad8:	fffff097          	auipc	ra,0xfffff
    80001adc:	00a080e7          	jalr	10(ra) # 80000ae2 <kalloc>
    80001ae0:	862a                	mv	a2,a0
        if (pa == 0)
    80001ae2:	c131                	beqz	a0,80001b26 <proc_mapstacks+0x86>
        uint64 va = KSTACK((int)(p - proc));
    80001ae4:	416485b3          	sub	a1,s1,s6
    80001ae8:	858d                	srai	a1,a1,0x3
    80001aea:	000ab783          	ld	a5,0(s5)
    80001aee:	02f585b3          	mul	a1,a1,a5
    80001af2:	2585                	addiw	a1,a1,1
    80001af4:	00d5959b          	slliw	a1,a1,0xd
        kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001af8:	4719                	li	a4,6
    80001afa:	6685                	lui	a3,0x1
    80001afc:	40b905b3          	sub	a1,s2,a1
    80001b00:	854e                	mv	a0,s3
    80001b02:	fffff097          	auipc	ra,0xfffff
    80001b06:	636080e7          	jalr	1590(ra) # 80001138 <kvmmap>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b0a:	16848493          	addi	s1,s1,360
    80001b0e:	fd4495e3          	bne	s1,s4,80001ad8 <proc_mapstacks+0x38>
}
    80001b12:	70e2                	ld	ra,56(sp)
    80001b14:	7442                	ld	s0,48(sp)
    80001b16:	74a2                	ld	s1,40(sp)
    80001b18:	7902                	ld	s2,32(sp)
    80001b1a:	69e2                	ld	s3,24(sp)
    80001b1c:	6a42                	ld	s4,16(sp)
    80001b1e:	6aa2                	ld	s5,8(sp)
    80001b20:	6b02                	ld	s6,0(sp)
    80001b22:	6121                	addi	sp,sp,64
    80001b24:	8082                	ret
            panic("kalloc");
    80001b26:	00006517          	auipc	a0,0x6
    80001b2a:	6b250513          	addi	a0,a0,1714 # 800081d8 <digits+0x198>
    80001b2e:	fffff097          	auipc	ra,0xfffff
    80001b32:	a0e080e7          	jalr	-1522(ra) # 8000053c <panic>

0000000080001b36 <procinit>:
{
    80001b36:	7139                	addi	sp,sp,-64
    80001b38:	fc06                	sd	ra,56(sp)
    80001b3a:	f822                	sd	s0,48(sp)
    80001b3c:	f426                	sd	s1,40(sp)
    80001b3e:	f04a                	sd	s2,32(sp)
    80001b40:	ec4e                	sd	s3,24(sp)
    80001b42:	e852                	sd	s4,16(sp)
    80001b44:	e456                	sd	s5,8(sp)
    80001b46:	e05a                	sd	s6,0(sp)
    80001b48:	0080                	addi	s0,sp,64
    for(int i=0; i<64; i++)
    80001b4a:	0000f797          	auipc	a5,0xf
    80001b4e:	52678793          	addi	a5,a5,1318 # 80011070 <priority_array>
    80001b52:	0000f697          	auipc	a3,0xf
    80001b56:	61e68693          	addi	a3,a3,1566 # 80011170 <pid_lock>
        priority_array[i] = 1;
    80001b5a:	4705                	li	a4,1
    80001b5c:	c398                	sw	a4,0(a5)
    for(int i=0; i<64; i++)
    80001b5e:	0791                	addi	a5,a5,4
    80001b60:	fed79ee3          	bne	a5,a3,80001b5c <procinit+0x26>
    reset_counter = 0;
    80001b64:	00007797          	auipc	a5,0x7
    80001b68:	e807aa23          	sw	zero,-364(a5) # 800089f8 <reset_counter>
    initlock(&pid_lock, "nextpid");
    80001b6c:	00006597          	auipc	a1,0x6
    80001b70:	67458593          	addi	a1,a1,1652 # 800081e0 <digits+0x1a0>
    80001b74:	0000f517          	auipc	a0,0xf
    80001b78:	5fc50513          	addi	a0,a0,1532 # 80011170 <pid_lock>
    80001b7c:	fffff097          	auipc	ra,0xfffff
    80001b80:	fc6080e7          	jalr	-58(ra) # 80000b42 <initlock>
    initlock(&wait_lock, "wait_lock");
    80001b84:	00006597          	auipc	a1,0x6
    80001b88:	66458593          	addi	a1,a1,1636 # 800081e8 <digits+0x1a8>
    80001b8c:	0000f517          	auipc	a0,0xf
    80001b90:	5fc50513          	addi	a0,a0,1532 # 80011188 <wait_lock>
    80001b94:	fffff097          	auipc	ra,0xfffff
    80001b98:	fae080e7          	jalr	-82(ra) # 80000b42 <initlock>
    for (p = proc; p < &proc[NPROC]; p++)
    80001b9c:	0000f497          	auipc	s1,0xf
    80001ba0:	60448493          	addi	s1,s1,1540 # 800111a0 <proc>
        initlock(&p->lock, "proc");
    80001ba4:	00006b17          	auipc	s6,0x6
    80001ba8:	654b0b13          	addi	s6,s6,1620 # 800081f8 <digits+0x1b8>
        p->kstack = KSTACK((int)(p - proc));
    80001bac:	8aa6                	mv	s5,s1
    80001bae:	00006a17          	auipc	s4,0x6
    80001bb2:	452a0a13          	addi	s4,s4,1106 # 80008000 <etext>
    80001bb6:	04000937          	lui	s2,0x4000
    80001bba:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001bbc:	0932                	slli	s2,s2,0xc
    for (p = proc; p < &proc[NPROC]; p++)
    80001bbe:	00015997          	auipc	s3,0x15
    80001bc2:	fe298993          	addi	s3,s3,-30 # 80016ba0 <tickslock>
        initlock(&p->lock, "proc");
    80001bc6:	85da                	mv	a1,s6
    80001bc8:	8526                	mv	a0,s1
    80001bca:	fffff097          	auipc	ra,0xfffff
    80001bce:	f78080e7          	jalr	-136(ra) # 80000b42 <initlock>
        p->state = UNUSED;
    80001bd2:	0004ac23          	sw	zero,24(s1)
        p->kstack = KSTACK((int)(p - proc));
    80001bd6:	415487b3          	sub	a5,s1,s5
    80001bda:	878d                	srai	a5,a5,0x3
    80001bdc:	000a3703          	ld	a4,0(s4)
    80001be0:	02e787b3          	mul	a5,a5,a4
    80001be4:	2785                	addiw	a5,a5,1
    80001be6:	00d7979b          	slliw	a5,a5,0xd
    80001bea:	40f907b3          	sub	a5,s2,a5
    80001bee:	e0bc                	sd	a5,64(s1)
    for (p = proc; p < &proc[NPROC]; p++)
    80001bf0:	16848493          	addi	s1,s1,360
    80001bf4:	fd3499e3          	bne	s1,s3,80001bc6 <procinit+0x90>
}
    80001bf8:	70e2                	ld	ra,56(sp)
    80001bfa:	7442                	ld	s0,48(sp)
    80001bfc:	74a2                	ld	s1,40(sp)
    80001bfe:	7902                	ld	s2,32(sp)
    80001c00:	69e2                	ld	s3,24(sp)
    80001c02:	6a42                	ld	s4,16(sp)
    80001c04:	6aa2                	ld	s5,8(sp)
    80001c06:	6b02                	ld	s6,0(sp)
    80001c08:	6121                	addi	sp,sp,64
    80001c0a:	8082                	ret

0000000080001c0c <copy_array>:
{
    80001c0c:	1141                	addi	sp,sp,-16
    80001c0e:	e422                	sd	s0,8(sp)
    80001c10:	0800                	addi	s0,sp,16
    for (int i = 0; i < len; i++)
    80001c12:	00c05c63          	blez	a2,80001c2a <copy_array+0x1e>
    80001c16:	87aa                	mv	a5,a0
    80001c18:	9532                	add	a0,a0,a2
        dst[i] = src[i];
    80001c1a:	0007c703          	lbu	a4,0(a5)
    80001c1e:	00e58023          	sb	a4,0(a1)
    for (int i = 0; i < len; i++)
    80001c22:	0785                	addi	a5,a5,1
    80001c24:	0585                	addi	a1,a1,1
    80001c26:	fea79ae3          	bne	a5,a0,80001c1a <copy_array+0xe>
}
    80001c2a:	6422                	ld	s0,8(sp)
    80001c2c:	0141                	addi	sp,sp,16
    80001c2e:	8082                	ret

0000000080001c30 <cpuid>:
{
    80001c30:	1141                	addi	sp,sp,-16
    80001c32:	e422                	sd	s0,8(sp)
    80001c34:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001c36:	8512                	mv	a0,tp
}
    80001c38:	2501                	sext.w	a0,a0
    80001c3a:	6422                	ld	s0,8(sp)
    80001c3c:	0141                	addi	sp,sp,16
    80001c3e:	8082                	ret

0000000080001c40 <mycpu>:
{
    80001c40:	1141                	addi	sp,sp,-16
    80001c42:	e422                	sd	s0,8(sp)
    80001c44:	0800                	addi	s0,sp,16
    80001c46:	8792                	mv	a5,tp
    struct cpu *c = &cpus[id];
    80001c48:	2781                	sext.w	a5,a5
    80001c4a:	079e                	slli	a5,a5,0x7
}
    80001c4c:	0000f517          	auipc	a0,0xf
    80001c50:	02450513          	addi	a0,a0,36 # 80010c70 <cpus>
    80001c54:	953e                	add	a0,a0,a5
    80001c56:	6422                	ld	s0,8(sp)
    80001c58:	0141                	addi	sp,sp,16
    80001c5a:	8082                	ret

0000000080001c5c <myproc>:
{
    80001c5c:	1101                	addi	sp,sp,-32
    80001c5e:	ec06                	sd	ra,24(sp)
    80001c60:	e822                	sd	s0,16(sp)
    80001c62:	e426                	sd	s1,8(sp)
    80001c64:	1000                	addi	s0,sp,32
    push_off();
    80001c66:	fffff097          	auipc	ra,0xfffff
    80001c6a:	f20080e7          	jalr	-224(ra) # 80000b86 <push_off>
    80001c6e:	8792                	mv	a5,tp
    struct proc *p = c->proc;
    80001c70:	2781                	sext.w	a5,a5
    80001c72:	079e                	slli	a5,a5,0x7
    80001c74:	0000f717          	auipc	a4,0xf
    80001c78:	ffc70713          	addi	a4,a4,-4 # 80010c70 <cpus>
    80001c7c:	97ba                	add	a5,a5,a4
    80001c7e:	6384                	ld	s1,0(a5)
    pop_off();
    80001c80:	fffff097          	auipc	ra,0xfffff
    80001c84:	fa6080e7          	jalr	-90(ra) # 80000c26 <pop_off>
}
    80001c88:	8526                	mv	a0,s1
    80001c8a:	60e2                	ld	ra,24(sp)
    80001c8c:	6442                	ld	s0,16(sp)
    80001c8e:	64a2                	ld	s1,8(sp)
    80001c90:	6105                	addi	sp,sp,32
    80001c92:	8082                	ret

0000000080001c94 <forkret>:
}

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void forkret(void)
{
    80001c94:	1141                	addi	sp,sp,-16
    80001c96:	e406                	sd	ra,8(sp)
    80001c98:	e022                	sd	s0,0(sp)
    80001c9a:	0800                	addi	s0,sp,16
    static int first = 1;

    // Still holding p->lock from scheduler.
    release(&myproc()->lock);
    80001c9c:	00000097          	auipc	ra,0x0
    80001ca0:	fc0080e7          	jalr	-64(ra) # 80001c5c <myproc>
    80001ca4:	fffff097          	auipc	ra,0xfffff
    80001ca8:	fe2080e7          	jalr	-30(ra) # 80000c86 <release>

    if (first)
    80001cac:	00007797          	auipc	a5,0x7
    80001cb0:	c847a783          	lw	a5,-892(a5) # 80008930 <first.1>
    80001cb4:	eb89                	bnez	a5,80001cc6 <forkret+0x32>
        // be run from main().
        first = 0;
        fsinit(ROOTDEV);
    }

    usertrapret();
    80001cb6:	00001097          	auipc	ra,0x1
    80001cba:	e82080e7          	jalr	-382(ra) # 80002b38 <usertrapret>
}
    80001cbe:	60a2                	ld	ra,8(sp)
    80001cc0:	6402                	ld	s0,0(sp)
    80001cc2:	0141                	addi	sp,sp,16
    80001cc4:	8082                	ret
        first = 0;
    80001cc6:	00007797          	auipc	a5,0x7
    80001cca:	c607a523          	sw	zero,-918(a5) # 80008930 <first.1>
        fsinit(ROOTDEV);
    80001cce:	4505                	li	a0,1
    80001cd0:	00002097          	auipc	ra,0x2
    80001cd4:	c46080e7          	jalr	-954(ra) # 80003916 <fsinit>
    80001cd8:	bff9                	j	80001cb6 <forkret+0x22>

0000000080001cda <allocpid>:
{
    80001cda:	1101                	addi	sp,sp,-32
    80001cdc:	ec06                	sd	ra,24(sp)
    80001cde:	e822                	sd	s0,16(sp)
    80001ce0:	e426                	sd	s1,8(sp)
    80001ce2:	e04a                	sd	s2,0(sp)
    80001ce4:	1000                	addi	s0,sp,32
    acquire(&pid_lock);
    80001ce6:	0000f917          	auipc	s2,0xf
    80001cea:	48a90913          	addi	s2,s2,1162 # 80011170 <pid_lock>
    80001cee:	854a                	mv	a0,s2
    80001cf0:	fffff097          	auipc	ra,0xfffff
    80001cf4:	ee2080e7          	jalr	-286(ra) # 80000bd2 <acquire>
    pid = nextpid;
    80001cf8:	00007797          	auipc	a5,0x7
    80001cfc:	c4878793          	addi	a5,a5,-952 # 80008940 <nextpid>
    80001d00:	4384                	lw	s1,0(a5)
    nextpid = nextpid + 1;
    80001d02:	0014871b          	addiw	a4,s1,1
    80001d06:	c398                	sw	a4,0(a5)
    release(&pid_lock);
    80001d08:	854a                	mv	a0,s2
    80001d0a:	fffff097          	auipc	ra,0xfffff
    80001d0e:	f7c080e7          	jalr	-132(ra) # 80000c86 <release>
}
    80001d12:	8526                	mv	a0,s1
    80001d14:	60e2                	ld	ra,24(sp)
    80001d16:	6442                	ld	s0,16(sp)
    80001d18:	64a2                	ld	s1,8(sp)
    80001d1a:	6902                	ld	s2,0(sp)
    80001d1c:	6105                	addi	sp,sp,32
    80001d1e:	8082                	ret

0000000080001d20 <proc_pagetable>:
{
    80001d20:	1101                	addi	sp,sp,-32
    80001d22:	ec06                	sd	ra,24(sp)
    80001d24:	e822                	sd	s0,16(sp)
    80001d26:	e426                	sd	s1,8(sp)
    80001d28:	e04a                	sd	s2,0(sp)
    80001d2a:	1000                	addi	s0,sp,32
    80001d2c:	892a                	mv	s2,a0
    pagetable = uvmcreate();
    80001d2e:	fffff097          	auipc	ra,0xfffff
    80001d32:	5f4080e7          	jalr	1524(ra) # 80001322 <uvmcreate>
    80001d36:	84aa                	mv	s1,a0
    if (pagetable == 0)
    80001d38:	c121                	beqz	a0,80001d78 <proc_pagetable+0x58>
    if (mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001d3a:	4729                	li	a4,10
    80001d3c:	00005697          	auipc	a3,0x5
    80001d40:	2c468693          	addi	a3,a3,708 # 80007000 <_trampoline>
    80001d44:	6605                	lui	a2,0x1
    80001d46:	040005b7          	lui	a1,0x4000
    80001d4a:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001d4c:	05b2                	slli	a1,a1,0xc
    80001d4e:	fffff097          	auipc	ra,0xfffff
    80001d52:	34a080e7          	jalr	842(ra) # 80001098 <mappages>
    80001d56:	02054863          	bltz	a0,80001d86 <proc_pagetable+0x66>
    if (mappages(pagetable, TRAPFRAME, PGSIZE,
    80001d5a:	4719                	li	a4,6
    80001d5c:	05893683          	ld	a3,88(s2)
    80001d60:	6605                	lui	a2,0x1
    80001d62:	020005b7          	lui	a1,0x2000
    80001d66:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001d68:	05b6                	slli	a1,a1,0xd
    80001d6a:	8526                	mv	a0,s1
    80001d6c:	fffff097          	auipc	ra,0xfffff
    80001d70:	32c080e7          	jalr	812(ra) # 80001098 <mappages>
    80001d74:	02054163          	bltz	a0,80001d96 <proc_pagetable+0x76>
}
    80001d78:	8526                	mv	a0,s1
    80001d7a:	60e2                	ld	ra,24(sp)
    80001d7c:	6442                	ld	s0,16(sp)
    80001d7e:	64a2                	ld	s1,8(sp)
    80001d80:	6902                	ld	s2,0(sp)
    80001d82:	6105                	addi	sp,sp,32
    80001d84:	8082                	ret
        uvmfree(pagetable, 0);
    80001d86:	4581                	li	a1,0
    80001d88:	8526                	mv	a0,s1
    80001d8a:	fffff097          	auipc	ra,0xfffff
    80001d8e:	79e080e7          	jalr	1950(ra) # 80001528 <uvmfree>
        return 0;
    80001d92:	4481                	li	s1,0
    80001d94:	b7d5                	j	80001d78 <proc_pagetable+0x58>
        uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001d96:	4681                	li	a3,0
    80001d98:	4605                	li	a2,1
    80001d9a:	040005b7          	lui	a1,0x4000
    80001d9e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001da0:	05b2                	slli	a1,a1,0xc
    80001da2:	8526                	mv	a0,s1
    80001da4:	fffff097          	auipc	ra,0xfffff
    80001da8:	4ba080e7          	jalr	1210(ra) # 8000125e <uvmunmap>
        uvmfree(pagetable, 0);
    80001dac:	4581                	li	a1,0
    80001dae:	8526                	mv	a0,s1
    80001db0:	fffff097          	auipc	ra,0xfffff
    80001db4:	778080e7          	jalr	1912(ra) # 80001528 <uvmfree>
        return 0;
    80001db8:	4481                	li	s1,0
    80001dba:	bf7d                	j	80001d78 <proc_pagetable+0x58>

0000000080001dbc <proc_freepagetable>:
{
    80001dbc:	1101                	addi	sp,sp,-32
    80001dbe:	ec06                	sd	ra,24(sp)
    80001dc0:	e822                	sd	s0,16(sp)
    80001dc2:	e426                	sd	s1,8(sp)
    80001dc4:	e04a                	sd	s2,0(sp)
    80001dc6:	1000                	addi	s0,sp,32
    80001dc8:	84aa                	mv	s1,a0
    80001dca:	892e                	mv	s2,a1
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001dcc:	4681                	li	a3,0
    80001dce:	4605                	li	a2,1
    80001dd0:	040005b7          	lui	a1,0x4000
    80001dd4:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001dd6:	05b2                	slli	a1,a1,0xc
    80001dd8:	fffff097          	auipc	ra,0xfffff
    80001ddc:	486080e7          	jalr	1158(ra) # 8000125e <uvmunmap>
    uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001de0:	4681                	li	a3,0
    80001de2:	4605                	li	a2,1
    80001de4:	020005b7          	lui	a1,0x2000
    80001de8:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001dea:	05b6                	slli	a1,a1,0xd
    80001dec:	8526                	mv	a0,s1
    80001dee:	fffff097          	auipc	ra,0xfffff
    80001df2:	470080e7          	jalr	1136(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, sz);
    80001df6:	85ca                	mv	a1,s2
    80001df8:	8526                	mv	a0,s1
    80001dfa:	fffff097          	auipc	ra,0xfffff
    80001dfe:	72e080e7          	jalr	1838(ra) # 80001528 <uvmfree>
}
    80001e02:	60e2                	ld	ra,24(sp)
    80001e04:	6442                	ld	s0,16(sp)
    80001e06:	64a2                	ld	s1,8(sp)
    80001e08:	6902                	ld	s2,0(sp)
    80001e0a:	6105                	addi	sp,sp,32
    80001e0c:	8082                	ret

0000000080001e0e <freeproc>:
{
    80001e0e:	1101                	addi	sp,sp,-32
    80001e10:	ec06                	sd	ra,24(sp)
    80001e12:	e822                	sd	s0,16(sp)
    80001e14:	e426                	sd	s1,8(sp)
    80001e16:	1000                	addi	s0,sp,32
    80001e18:	84aa                	mv	s1,a0
    if (p->trapframe)
    80001e1a:	6d28                	ld	a0,88(a0)
    80001e1c:	c509                	beqz	a0,80001e26 <freeproc+0x18>
        kfree((void *)p->trapframe);
    80001e1e:	fffff097          	auipc	ra,0xfffff
    80001e22:	bc6080e7          	jalr	-1082(ra) # 800009e4 <kfree>
    p->trapframe = 0;
    80001e26:	0404bc23          	sd	zero,88(s1)
    if (p->pagetable)
    80001e2a:	68a8                	ld	a0,80(s1)
    80001e2c:	c511                	beqz	a0,80001e38 <freeproc+0x2a>
        proc_freepagetable(p->pagetable, p->sz);
    80001e2e:	64ac                	ld	a1,72(s1)
    80001e30:	00000097          	auipc	ra,0x0
    80001e34:	f8c080e7          	jalr	-116(ra) # 80001dbc <proc_freepagetable>
    p->pagetable = 0;
    80001e38:	0404b823          	sd	zero,80(s1)
    p->sz = 0;
    80001e3c:	0404b423          	sd	zero,72(s1)
    p->pid = 0;
    80001e40:	0204a823          	sw	zero,48(s1)
    p->parent = 0;
    80001e44:	0204bc23          	sd	zero,56(s1)
    p->name[0] = 0;
    80001e48:	14048c23          	sb	zero,344(s1)
    p->chan = 0;
    80001e4c:	0204b023          	sd	zero,32(s1)
    p->killed = 0;
    80001e50:	0204a423          	sw	zero,40(s1)
    p->xstate = 0;
    80001e54:	0204a623          	sw	zero,44(s1)
    p->state = UNUSED;
    80001e58:	0004ac23          	sw	zero,24(s1)
}
    80001e5c:	60e2                	ld	ra,24(sp)
    80001e5e:	6442                	ld	s0,16(sp)
    80001e60:	64a2                	ld	s1,8(sp)
    80001e62:	6105                	addi	sp,sp,32
    80001e64:	8082                	ret

0000000080001e66 <allocproc>:
{
    80001e66:	1101                	addi	sp,sp,-32
    80001e68:	ec06                	sd	ra,24(sp)
    80001e6a:	e822                	sd	s0,16(sp)
    80001e6c:	e426                	sd	s1,8(sp)
    80001e6e:	e04a                	sd	s2,0(sp)
    80001e70:	1000                	addi	s0,sp,32
    for (p = proc; p < &proc[NPROC]; p++)
    80001e72:	0000f497          	auipc	s1,0xf
    80001e76:	32e48493          	addi	s1,s1,814 # 800111a0 <proc>
    80001e7a:	00015917          	auipc	s2,0x15
    80001e7e:	d2690913          	addi	s2,s2,-730 # 80016ba0 <tickslock>
        acquire(&p->lock);
    80001e82:	8526                	mv	a0,s1
    80001e84:	fffff097          	auipc	ra,0xfffff
    80001e88:	d4e080e7          	jalr	-690(ra) # 80000bd2 <acquire>
        if (p->state == UNUSED)
    80001e8c:	4c9c                	lw	a5,24(s1)
    80001e8e:	cf81                	beqz	a5,80001ea6 <allocproc+0x40>
            release(&p->lock);
    80001e90:	8526                	mv	a0,s1
    80001e92:	fffff097          	auipc	ra,0xfffff
    80001e96:	df4080e7          	jalr	-524(ra) # 80000c86 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80001e9a:	16848493          	addi	s1,s1,360
    80001e9e:	ff2492e3          	bne	s1,s2,80001e82 <allocproc+0x1c>
    return 0;
    80001ea2:	4481                	li	s1,0
    80001ea4:	a889                	j	80001ef6 <allocproc+0x90>
    p->pid = allocpid();
    80001ea6:	00000097          	auipc	ra,0x0
    80001eaa:	e34080e7          	jalr	-460(ra) # 80001cda <allocpid>
    80001eae:	d888                	sw	a0,48(s1)
    p->state = USED;
    80001eb0:	4785                	li	a5,1
    80001eb2:	cc9c                	sw	a5,24(s1)
    if ((p->trapframe = (struct trapframe *)kalloc()) == 0)
    80001eb4:	fffff097          	auipc	ra,0xfffff
    80001eb8:	c2e080e7          	jalr	-978(ra) # 80000ae2 <kalloc>
    80001ebc:	892a                	mv	s2,a0
    80001ebe:	eca8                	sd	a0,88(s1)
    80001ec0:	c131                	beqz	a0,80001f04 <allocproc+0x9e>
    p->pagetable = proc_pagetable(p);
    80001ec2:	8526                	mv	a0,s1
    80001ec4:	00000097          	auipc	ra,0x0
    80001ec8:	e5c080e7          	jalr	-420(ra) # 80001d20 <proc_pagetable>
    80001ecc:	892a                	mv	s2,a0
    80001ece:	e8a8                	sd	a0,80(s1)
    if (p->pagetable == 0)
    80001ed0:	c531                	beqz	a0,80001f1c <allocproc+0xb6>
    memset(&p->context, 0, sizeof(p->context));
    80001ed2:	07000613          	li	a2,112
    80001ed6:	4581                	li	a1,0
    80001ed8:	06048513          	addi	a0,s1,96
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	df2080e7          	jalr	-526(ra) # 80000cce <memset>
    p->context.ra = (uint64)forkret;
    80001ee4:	00000797          	auipc	a5,0x0
    80001ee8:	db078793          	addi	a5,a5,-592 # 80001c94 <forkret>
    80001eec:	f0bc                	sd	a5,96(s1)
    p->context.sp = p->kstack + PGSIZE;
    80001eee:	60bc                	ld	a5,64(s1)
    80001ef0:	6705                	lui	a4,0x1
    80001ef2:	97ba                	add	a5,a5,a4
    80001ef4:	f4bc                	sd	a5,104(s1)
}
    80001ef6:	8526                	mv	a0,s1
    80001ef8:	60e2                	ld	ra,24(sp)
    80001efa:	6442                	ld	s0,16(sp)
    80001efc:	64a2                	ld	s1,8(sp)
    80001efe:	6902                	ld	s2,0(sp)
    80001f00:	6105                	addi	sp,sp,32
    80001f02:	8082                	ret
        freeproc(p);
    80001f04:	8526                	mv	a0,s1
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	f08080e7          	jalr	-248(ra) # 80001e0e <freeproc>
        release(&p->lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d76080e7          	jalr	-650(ra) # 80000c86 <release>
        return 0;
    80001f18:	84ca                	mv	s1,s2
    80001f1a:	bff1                	j	80001ef6 <allocproc+0x90>
        freeproc(p);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	00000097          	auipc	ra,0x0
    80001f22:	ef0080e7          	jalr	-272(ra) # 80001e0e <freeproc>
        release(&p->lock);
    80001f26:	8526                	mv	a0,s1
    80001f28:	fffff097          	auipc	ra,0xfffff
    80001f2c:	d5e080e7          	jalr	-674(ra) # 80000c86 <release>
        return 0;
    80001f30:	84ca                	mv	s1,s2
    80001f32:	b7d1                	j	80001ef6 <allocproc+0x90>

0000000080001f34 <userinit>:
{
    80001f34:	1101                	addi	sp,sp,-32
    80001f36:	ec06                	sd	ra,24(sp)
    80001f38:	e822                	sd	s0,16(sp)
    80001f3a:	e426                	sd	s1,8(sp)
    80001f3c:	1000                	addi	s0,sp,32
    p = allocproc();
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	f28080e7          	jalr	-216(ra) # 80001e66 <allocproc>
    80001f46:	84aa                	mv	s1,a0
    initproc = p;
    80001f48:	00007797          	auipc	a5,0x7
    80001f4c:	aaa7bc23          	sd	a0,-1352(a5) # 80008a00 <initproc>
    uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001f50:	03400613          	li	a2,52
    80001f54:	00007597          	auipc	a1,0x7
    80001f58:	9fc58593          	addi	a1,a1,-1540 # 80008950 <initcode>
    80001f5c:	6928                	ld	a0,80(a0)
    80001f5e:	fffff097          	auipc	ra,0xfffff
    80001f62:	3f2080e7          	jalr	1010(ra) # 80001350 <uvmfirst>
    p->sz = PGSIZE;
    80001f66:	6785                	lui	a5,0x1
    80001f68:	e4bc                	sd	a5,72(s1)
    p->trapframe->epc = 0;     // user program counter
    80001f6a:	6cb8                	ld	a4,88(s1)
    80001f6c:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
    p->trapframe->sp = PGSIZE; // user stack pointer
    80001f70:	6cb8                	ld	a4,88(s1)
    80001f72:	fb1c                	sd	a5,48(a4)
    safestrcpy(p->name, "initcode", sizeof(p->name));
    80001f74:	4641                	li	a2,16
    80001f76:	00006597          	auipc	a1,0x6
    80001f7a:	28a58593          	addi	a1,a1,650 # 80008200 <digits+0x1c0>
    80001f7e:	15848513          	addi	a0,s1,344
    80001f82:	fffff097          	auipc	ra,0xfffff
    80001f86:	e94080e7          	jalr	-364(ra) # 80000e16 <safestrcpy>
    p->cwd = namei("/");
    80001f8a:	00006517          	auipc	a0,0x6
    80001f8e:	28650513          	addi	a0,a0,646 # 80008210 <digits+0x1d0>
    80001f92:	00002097          	auipc	ra,0x2
    80001f96:	3a2080e7          	jalr	930(ra) # 80004334 <namei>
    80001f9a:	14a4b823          	sd	a0,336(s1)
    p->state = RUNNABLE;
    80001f9e:	478d                	li	a5,3
    80001fa0:	cc9c                	sw	a5,24(s1)
    release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	ce2080e7          	jalr	-798(ra) # 80000c86 <release>
}
    80001fac:	60e2                	ld	ra,24(sp)
    80001fae:	6442                	ld	s0,16(sp)
    80001fb0:	64a2                	ld	s1,8(sp)
    80001fb2:	6105                	addi	sp,sp,32
    80001fb4:	8082                	ret

0000000080001fb6 <growproc>:
{
    80001fb6:	1101                	addi	sp,sp,-32
    80001fb8:	ec06                	sd	ra,24(sp)
    80001fba:	e822                	sd	s0,16(sp)
    80001fbc:	e426                	sd	s1,8(sp)
    80001fbe:	e04a                	sd	s2,0(sp)
    80001fc0:	1000                	addi	s0,sp,32
    80001fc2:	892a                	mv	s2,a0
    struct proc *p = myproc();
    80001fc4:	00000097          	auipc	ra,0x0
    80001fc8:	c98080e7          	jalr	-872(ra) # 80001c5c <myproc>
    80001fcc:	84aa                	mv	s1,a0
    sz = p->sz;
    80001fce:	652c                	ld	a1,72(a0)
    if (n > 0)
    80001fd0:	01204c63          	bgtz	s2,80001fe8 <growproc+0x32>
    else if (n < 0)
    80001fd4:	02094663          	bltz	s2,80002000 <growproc+0x4a>
    p->sz = sz;
    80001fd8:	e4ac                	sd	a1,72(s1)
    return 0;
    80001fda:	4501                	li	a0,0
}
    80001fdc:	60e2                	ld	ra,24(sp)
    80001fde:	6442                	ld	s0,16(sp)
    80001fe0:	64a2                	ld	s1,8(sp)
    80001fe2:	6902                	ld	s2,0(sp)
    80001fe4:	6105                	addi	sp,sp,32
    80001fe6:	8082                	ret
        if ((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0)
    80001fe8:	4691                	li	a3,4
    80001fea:	00b90633          	add	a2,s2,a1
    80001fee:	6928                	ld	a0,80(a0)
    80001ff0:	fffff097          	auipc	ra,0xfffff
    80001ff4:	41a080e7          	jalr	1050(ra) # 8000140a <uvmalloc>
    80001ff8:	85aa                	mv	a1,a0
    80001ffa:	fd79                	bnez	a0,80001fd8 <growproc+0x22>
            return -1;
    80001ffc:	557d                	li	a0,-1
    80001ffe:	bff9                	j	80001fdc <growproc+0x26>
        sz = uvmdealloc(p->pagetable, sz, sz + n);
    80002000:	00b90633          	add	a2,s2,a1
    80002004:	6928                	ld	a0,80(a0)
    80002006:	fffff097          	auipc	ra,0xfffff
    8000200a:	3bc080e7          	jalr	956(ra) # 800013c2 <uvmdealloc>
    8000200e:	85aa                	mv	a1,a0
    80002010:	b7e1                	j	80001fd8 <growproc+0x22>

0000000080002012 <ps>:
{
    80002012:	715d                	addi	sp,sp,-80
    80002014:	e486                	sd	ra,72(sp)
    80002016:	e0a2                	sd	s0,64(sp)
    80002018:	fc26                	sd	s1,56(sp)
    8000201a:	f84a                	sd	s2,48(sp)
    8000201c:	f44e                	sd	s3,40(sp)
    8000201e:	f052                	sd	s4,32(sp)
    80002020:	ec56                	sd	s5,24(sp)
    80002022:	e85a                	sd	s6,16(sp)
    80002024:	e45e                	sd	s7,8(sp)
    80002026:	e062                	sd	s8,0(sp)
    80002028:	0880                	addi	s0,sp,80
    8000202a:	84aa                	mv	s1,a0
    8000202c:	8bae                	mv	s7,a1
    void *result = (void *)myproc()->sz;
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	c2e080e7          	jalr	-978(ra) # 80001c5c <myproc>
    if (count == 0)
    80002036:	120b8063          	beqz	s7,80002156 <ps+0x144>
    void *result = (void *)myproc()->sz;
    8000203a:	04853b03          	ld	s6,72(a0)
    if (growproc(count * sizeof(struct user_proc)) < 0)
    8000203e:	003b951b          	slliw	a0,s7,0x3
    80002042:	0175053b          	addw	a0,a0,s7
    80002046:	0025151b          	slliw	a0,a0,0x2
    8000204a:	00000097          	auipc	ra,0x0
    8000204e:	f6c080e7          	jalr	-148(ra) # 80001fb6 <growproc>
    80002052:	10054463          	bltz	a0,8000215a <ps+0x148>
    struct user_proc loc_result[count];
    80002056:	003b9a13          	slli	s4,s7,0x3
    8000205a:	9a5e                	add	s4,s4,s7
    8000205c:	0a0a                	slli	s4,s4,0x2
    8000205e:	00fa0793          	addi	a5,s4,15
    80002062:	8391                	srli	a5,a5,0x4
    80002064:	0792                	slli	a5,a5,0x4
    80002066:	40f10133          	sub	sp,sp,a5
    8000206a:	8a8a                	mv	s5,sp
    struct proc *p = proc + (start * sizeof(proc));
    8000206c:	007e97b7          	lui	a5,0x7e9
    80002070:	02f484b3          	mul	s1,s1,a5
    80002074:	0000f797          	auipc	a5,0xf
    80002078:	12c78793          	addi	a5,a5,300 # 800111a0 <proc>
    8000207c:	94be                	add	s1,s1,a5
    if (p >= &proc[NPROC])
    8000207e:	00015797          	auipc	a5,0x15
    80002082:	b2278793          	addi	a5,a5,-1246 # 80016ba0 <tickslock>
    80002086:	0cf4fc63          	bgeu	s1,a5,8000215e <ps+0x14c>
        if (localCount == count)
    8000208a:	014a8913          	addi	s2,s5,20
    uint8 localCount = 0;
    8000208e:	4981                	li	s3,0
    for (; p < &proc[NPROC]; p++)
    80002090:	8c3e                	mv	s8,a5
    80002092:	a069                	j	8000211c <ps+0x10a>
            loc_result[localCount].state = UNUSED;
    80002094:	00399793          	slli	a5,s3,0x3
    80002098:	97ce                	add	a5,a5,s3
    8000209a:	078a                	slli	a5,a5,0x2
    8000209c:	97d6                	add	a5,a5,s5
    8000209e:	0007a023          	sw	zero,0(a5)
            release(&p->lock);
    800020a2:	8526                	mv	a0,s1
    800020a4:	fffff097          	auipc	ra,0xfffff
    800020a8:	be2080e7          	jalr	-1054(ra) # 80000c86 <release>
    if (localCount < count)
    800020ac:	0179f963          	bgeu	s3,s7,800020be <ps+0xac>
        loc_result[localCount].state = UNUSED; // if we reach the end of processes
    800020b0:	00399793          	slli	a5,s3,0x3
    800020b4:	97ce                	add	a5,a5,s3
    800020b6:	078a                	slli	a5,a5,0x2
    800020b8:	97d6                	add	a5,a5,s5
    800020ba:	0007a023          	sw	zero,0(a5)
    void *result = (void *)myproc()->sz;
    800020be:	84da                	mv	s1,s6
    copyout(myproc()->pagetable, (uint64)result, (void *)loc_result, count * sizeof(struct user_proc));
    800020c0:	00000097          	auipc	ra,0x0
    800020c4:	b9c080e7          	jalr	-1124(ra) # 80001c5c <myproc>
    800020c8:	86d2                	mv	a3,s4
    800020ca:	8656                	mv	a2,s5
    800020cc:	85da                	mv	a1,s6
    800020ce:	6928                	ld	a0,80(a0)
    800020d0:	fffff097          	auipc	ra,0xfffff
    800020d4:	596080e7          	jalr	1430(ra) # 80001666 <copyout>
}
    800020d8:	8526                	mv	a0,s1
    800020da:	fb040113          	addi	sp,s0,-80
    800020de:	60a6                	ld	ra,72(sp)
    800020e0:	6406                	ld	s0,64(sp)
    800020e2:	74e2                	ld	s1,56(sp)
    800020e4:	7942                	ld	s2,48(sp)
    800020e6:	79a2                	ld	s3,40(sp)
    800020e8:	7a02                	ld	s4,32(sp)
    800020ea:	6ae2                	ld	s5,24(sp)
    800020ec:	6b42                	ld	s6,16(sp)
    800020ee:	6ba2                	ld	s7,8(sp)
    800020f0:	6c02                	ld	s8,0(sp)
    800020f2:	6161                	addi	sp,sp,80
    800020f4:	8082                	ret
            loc_result[localCount].parent_id = p->parent->pid;
    800020f6:	5b9c                	lw	a5,48(a5)
    800020f8:	fef92e23          	sw	a5,-4(s2)
        release(&p->lock);
    800020fc:	8526                	mv	a0,s1
    800020fe:	fffff097          	auipc	ra,0xfffff
    80002102:	b88080e7          	jalr	-1144(ra) # 80000c86 <release>
        localCount++;
    80002106:	2985                	addiw	s3,s3,1
    80002108:	0ff9f993          	zext.b	s3,s3
    for (; p < &proc[NPROC]; p++)
    8000210c:	16848493          	addi	s1,s1,360
    80002110:	f984fee3          	bgeu	s1,s8,800020ac <ps+0x9a>
        if (localCount == count)
    80002114:	02490913          	addi	s2,s2,36
    80002118:	fb3b83e3          	beq	s7,s3,800020be <ps+0xac>
        acquire(&p->lock);
    8000211c:	8526                	mv	a0,s1
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	ab4080e7          	jalr	-1356(ra) # 80000bd2 <acquire>
        if (p->state == UNUSED)
    80002126:	4c9c                	lw	a5,24(s1)
    80002128:	d7b5                	beqz	a5,80002094 <ps+0x82>
        loc_result[localCount].state = p->state;
    8000212a:	fef92623          	sw	a5,-20(s2)
        loc_result[localCount].killed = p->killed;
    8000212e:	549c                	lw	a5,40(s1)
    80002130:	fef92823          	sw	a5,-16(s2)
        loc_result[localCount].xstate = p->xstate;
    80002134:	54dc                	lw	a5,44(s1)
    80002136:	fef92a23          	sw	a5,-12(s2)
        loc_result[localCount].pid = p->pid;
    8000213a:	589c                	lw	a5,48(s1)
    8000213c:	fef92c23          	sw	a5,-8(s2)
        copy_array(p->name, loc_result[localCount].name, 16);
    80002140:	4641                	li	a2,16
    80002142:	85ca                	mv	a1,s2
    80002144:	15848513          	addi	a0,s1,344
    80002148:	00000097          	auipc	ra,0x0
    8000214c:	ac4080e7          	jalr	-1340(ra) # 80001c0c <copy_array>
        if (p->parent != 0) // init
    80002150:	7c9c                	ld	a5,56(s1)
    80002152:	f3d5                	bnez	a5,800020f6 <ps+0xe4>
    80002154:	b765                	j	800020fc <ps+0xea>
        return result;
    80002156:	4481                	li	s1,0
    80002158:	b741                	j	800020d8 <ps+0xc6>
        return result;
    8000215a:	4481                	li	s1,0
    8000215c:	bfb5                	j	800020d8 <ps+0xc6>
        return result;
    8000215e:	4481                	li	s1,0
    80002160:	bfa5                	j	800020d8 <ps+0xc6>

0000000080002162 <fork>:
{
    80002162:	7139                	addi	sp,sp,-64
    80002164:	fc06                	sd	ra,56(sp)
    80002166:	f822                	sd	s0,48(sp)
    80002168:	f426                	sd	s1,40(sp)
    8000216a:	f04a                	sd	s2,32(sp)
    8000216c:	ec4e                	sd	s3,24(sp)
    8000216e:	e852                	sd	s4,16(sp)
    80002170:	e456                	sd	s5,8(sp)
    80002172:	0080                	addi	s0,sp,64
    struct proc *p = myproc();
    80002174:	00000097          	auipc	ra,0x0
    80002178:	ae8080e7          	jalr	-1304(ra) # 80001c5c <myproc>
    8000217c:	8aaa                	mv	s5,a0
    if ((np = allocproc()) == 0)
    8000217e:	00000097          	auipc	ra,0x0
    80002182:	ce8080e7          	jalr	-792(ra) # 80001e66 <allocproc>
    80002186:	10050c63          	beqz	a0,8000229e <fork+0x13c>
    8000218a:	8a2a                	mv	s4,a0
    if (uvmcopy(p->pagetable, np->pagetable, p->sz) < 0)
    8000218c:	048ab603          	ld	a2,72(s5)
    80002190:	692c                	ld	a1,80(a0)
    80002192:	050ab503          	ld	a0,80(s5)
    80002196:	fffff097          	auipc	ra,0xfffff
    8000219a:	3cc080e7          	jalr	972(ra) # 80001562 <uvmcopy>
    8000219e:	04054863          	bltz	a0,800021ee <fork+0x8c>
    np->sz = p->sz;
    800021a2:	048ab783          	ld	a5,72(s5)
    800021a6:	04fa3423          	sd	a5,72(s4)
    *(np->trapframe) = *(p->trapframe);
    800021aa:	058ab683          	ld	a3,88(s5)
    800021ae:	87b6                	mv	a5,a3
    800021b0:	058a3703          	ld	a4,88(s4)
    800021b4:	12068693          	addi	a3,a3,288
    800021b8:	0007b803          	ld	a6,0(a5)
    800021bc:	6788                	ld	a0,8(a5)
    800021be:	6b8c                	ld	a1,16(a5)
    800021c0:	6f90                	ld	a2,24(a5)
    800021c2:	01073023          	sd	a6,0(a4)
    800021c6:	e708                	sd	a0,8(a4)
    800021c8:	eb0c                	sd	a1,16(a4)
    800021ca:	ef10                	sd	a2,24(a4)
    800021cc:	02078793          	addi	a5,a5,32
    800021d0:	02070713          	addi	a4,a4,32
    800021d4:	fed792e3          	bne	a5,a3,800021b8 <fork+0x56>
    np->trapframe->a0 = 0;
    800021d8:	058a3783          	ld	a5,88(s4)
    800021dc:	0607b823          	sd	zero,112(a5)
    for (i = 0; i < NOFILE; i++)
    800021e0:	0d0a8493          	addi	s1,s5,208
    800021e4:	0d0a0913          	addi	s2,s4,208
    800021e8:	150a8993          	addi	s3,s5,336
    800021ec:	a00d                	j	8000220e <fork+0xac>
        freeproc(np);
    800021ee:	8552                	mv	a0,s4
    800021f0:	00000097          	auipc	ra,0x0
    800021f4:	c1e080e7          	jalr	-994(ra) # 80001e0e <freeproc>
        release(&np->lock);
    800021f8:	8552                	mv	a0,s4
    800021fa:	fffff097          	auipc	ra,0xfffff
    800021fe:	a8c080e7          	jalr	-1396(ra) # 80000c86 <release>
        return -1;
    80002202:	597d                	li	s2,-1
    80002204:	a059                	j	8000228a <fork+0x128>
    for (i = 0; i < NOFILE; i++)
    80002206:	04a1                	addi	s1,s1,8
    80002208:	0921                	addi	s2,s2,8
    8000220a:	01348b63          	beq	s1,s3,80002220 <fork+0xbe>
        if (p->ofile[i])
    8000220e:	6088                	ld	a0,0(s1)
    80002210:	d97d                	beqz	a0,80002206 <fork+0xa4>
            np->ofile[i] = filedup(p->ofile[i]);
    80002212:	00002097          	auipc	ra,0x2
    80002216:	794080e7          	jalr	1940(ra) # 800049a6 <filedup>
    8000221a:	00a93023          	sd	a0,0(s2)
    8000221e:	b7e5                	j	80002206 <fork+0xa4>
    np->cwd = idup(p->cwd);
    80002220:	150ab503          	ld	a0,336(s5)
    80002224:	00002097          	auipc	ra,0x2
    80002228:	92c080e7          	jalr	-1748(ra) # 80003b50 <idup>
    8000222c:	14aa3823          	sd	a0,336(s4)
    safestrcpy(np->name, p->name, sizeof(p->name));
    80002230:	4641                	li	a2,16
    80002232:	158a8593          	addi	a1,s5,344
    80002236:	158a0513          	addi	a0,s4,344
    8000223a:	fffff097          	auipc	ra,0xfffff
    8000223e:	bdc080e7          	jalr	-1060(ra) # 80000e16 <safestrcpy>
    pid = np->pid;
    80002242:	030a2903          	lw	s2,48(s4)
    release(&np->lock);
    80002246:	8552                	mv	a0,s4
    80002248:	fffff097          	auipc	ra,0xfffff
    8000224c:	a3e080e7          	jalr	-1474(ra) # 80000c86 <release>
    acquire(&wait_lock);
    80002250:	0000f497          	auipc	s1,0xf
    80002254:	f3848493          	addi	s1,s1,-200 # 80011188 <wait_lock>
    80002258:	8526                	mv	a0,s1
    8000225a:	fffff097          	auipc	ra,0xfffff
    8000225e:	978080e7          	jalr	-1672(ra) # 80000bd2 <acquire>
    np->parent = p;
    80002262:	035a3c23          	sd	s5,56(s4)
    release(&wait_lock);
    80002266:	8526                	mv	a0,s1
    80002268:	fffff097          	auipc	ra,0xfffff
    8000226c:	a1e080e7          	jalr	-1506(ra) # 80000c86 <release>
    acquire(&np->lock);
    80002270:	8552                	mv	a0,s4
    80002272:	fffff097          	auipc	ra,0xfffff
    80002276:	960080e7          	jalr	-1696(ra) # 80000bd2 <acquire>
    np->state = RUNNABLE;
    8000227a:	478d                	li	a5,3
    8000227c:	00fa2c23          	sw	a5,24(s4)
    release(&np->lock);
    80002280:	8552                	mv	a0,s4
    80002282:	fffff097          	auipc	ra,0xfffff
    80002286:	a04080e7          	jalr	-1532(ra) # 80000c86 <release>
}
    8000228a:	854a                	mv	a0,s2
    8000228c:	70e2                	ld	ra,56(sp)
    8000228e:	7442                	ld	s0,48(sp)
    80002290:	74a2                	ld	s1,40(sp)
    80002292:	7902                	ld	s2,32(sp)
    80002294:	69e2                	ld	s3,24(sp)
    80002296:	6a42                	ld	s4,16(sp)
    80002298:	6aa2                	ld	s5,8(sp)
    8000229a:	6121                	addi	sp,sp,64
    8000229c:	8082                	ret
        return -1;
    8000229e:	597d                	li	s2,-1
    800022a0:	b7ed                	j	8000228a <fork+0x128>

00000000800022a2 <scheduler>:
{
    800022a2:	1101                	addi	sp,sp,-32
    800022a4:	ec06                	sd	ra,24(sp)
    800022a6:	e822                	sd	s0,16(sp)
    800022a8:	e426                	sd	s1,8(sp)
    800022aa:	1000                	addi	s0,sp,32
        (*sched_pointer)();
    800022ac:	00006497          	auipc	s1,0x6
    800022b0:	68c48493          	addi	s1,s1,1676 # 80008938 <sched_pointer>
    800022b4:	609c                	ld	a5,0(s1)
    800022b6:	9782                	jalr	a5
    while (1)
    800022b8:	bff5                	j	800022b4 <scheduler+0x12>

00000000800022ba <delay>:
    if (i <= 0)
    800022ba:	00a05f63          	blez	a0,800022d8 <delay+0x1e>
{
    800022be:	1141                	addi	sp,sp,-16
    800022c0:	e406                	sd	ra,8(sp)
    800022c2:	e022                	sd	s0,0(sp)
    800022c4:	0800                	addi	s0,sp,16
    delay(i-1);  // give the decrement as 1 or 10 or 100 as convenient
    800022c6:	357d                	addiw	a0,a0,-1
    800022c8:	00000097          	auipc	ra,0x0
    800022cc:	ff2080e7          	jalr	-14(ra) # 800022ba <delay>
}
    800022d0:	60a2                	ld	ra,8(sp)
    800022d2:	6402                	ld	s0,0(sp)
    800022d4:	0141                	addi	sp,sp,16
    800022d6:	8082                	ret
    800022d8:	8082                	ret

00000000800022da <sched>:
{
    800022da:	7179                	addi	sp,sp,-48
    800022dc:	f406                	sd	ra,40(sp)
    800022de:	f022                	sd	s0,32(sp)
    800022e0:	ec26                	sd	s1,24(sp)
    800022e2:	e84a                	sd	s2,16(sp)
    800022e4:	e44e                	sd	s3,8(sp)
    800022e6:	1800                	addi	s0,sp,48
    struct proc *p = myproc();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	974080e7          	jalr	-1676(ra) # 80001c5c <myproc>
    800022f0:	84aa                	mv	s1,a0
    if (!holding(&p->lock))
    800022f2:	fffff097          	auipc	ra,0xfffff
    800022f6:	866080e7          	jalr	-1946(ra) # 80000b58 <holding>
    800022fa:	c53d                	beqz	a0,80002368 <sched+0x8e>
    800022fc:	8792                	mv	a5,tp
    if (mycpu()->noff != 1)
    800022fe:	2781                	sext.w	a5,a5
    80002300:	079e                	slli	a5,a5,0x7
    80002302:	0000f717          	auipc	a4,0xf
    80002306:	96e70713          	addi	a4,a4,-1682 # 80010c70 <cpus>
    8000230a:	97ba                	add	a5,a5,a4
    8000230c:	5fb8                	lw	a4,120(a5)
    8000230e:	4785                	li	a5,1
    80002310:	06f71463          	bne	a4,a5,80002378 <sched+0x9e>
    if (p->state == RUNNING)
    80002314:	4c98                	lw	a4,24(s1)
    80002316:	4791                	li	a5,4
    80002318:	06f70863          	beq	a4,a5,80002388 <sched+0xae>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000231c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002320:	8b89                	andi	a5,a5,2
    if (intr_get())
    80002322:	ebbd                	bnez	a5,80002398 <sched+0xbe>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002324:	8792                	mv	a5,tp
    intena = mycpu()->intena;
    80002326:	0000f917          	auipc	s2,0xf
    8000232a:	94a90913          	addi	s2,s2,-1718 # 80010c70 <cpus>
    8000232e:	2781                	sext.w	a5,a5
    80002330:	079e                	slli	a5,a5,0x7
    80002332:	97ca                	add	a5,a5,s2
    80002334:	07c7a983          	lw	s3,124(a5)
    80002338:	8592                	mv	a1,tp
    swtch(&p->context, &mycpu()->context);
    8000233a:	2581                	sext.w	a1,a1
    8000233c:	059e                	slli	a1,a1,0x7
    8000233e:	05a1                	addi	a1,a1,8
    80002340:	95ca                	add	a1,a1,s2
    80002342:	06048513          	addi	a0,s1,96
    80002346:	00000097          	auipc	ra,0x0
    8000234a:	748080e7          	jalr	1864(ra) # 80002a8e <swtch>
    8000234e:	8792                	mv	a5,tp
    mycpu()->intena = intena;
    80002350:	2781                	sext.w	a5,a5
    80002352:	079e                	slli	a5,a5,0x7
    80002354:	993e                	add	s2,s2,a5
    80002356:	07392e23          	sw	s3,124(s2)
}
    8000235a:	70a2                	ld	ra,40(sp)
    8000235c:	7402                	ld	s0,32(sp)
    8000235e:	64e2                	ld	s1,24(sp)
    80002360:	6942                	ld	s2,16(sp)
    80002362:	69a2                	ld	s3,8(sp)
    80002364:	6145                	addi	sp,sp,48
    80002366:	8082                	ret
        panic("sched p->lock");
    80002368:	00006517          	auipc	a0,0x6
    8000236c:	eb050513          	addi	a0,a0,-336 # 80008218 <digits+0x1d8>
    80002370:	ffffe097          	auipc	ra,0xffffe
    80002374:	1cc080e7          	jalr	460(ra) # 8000053c <panic>
        panic("sched locks");
    80002378:	00006517          	auipc	a0,0x6
    8000237c:	eb050513          	addi	a0,a0,-336 # 80008228 <digits+0x1e8>
    80002380:	ffffe097          	auipc	ra,0xffffe
    80002384:	1bc080e7          	jalr	444(ra) # 8000053c <panic>
        panic("sched running");
    80002388:	00006517          	auipc	a0,0x6
    8000238c:	eb050513          	addi	a0,a0,-336 # 80008238 <digits+0x1f8>
    80002390:	ffffe097          	auipc	ra,0xffffe
    80002394:	1ac080e7          	jalr	428(ra) # 8000053c <panic>
        panic("sched interruptible");
    80002398:	00006517          	auipc	a0,0x6
    8000239c:	eb050513          	addi	a0,a0,-336 # 80008248 <digits+0x208>
    800023a0:	ffffe097          	auipc	ra,0xffffe
    800023a4:	19c080e7          	jalr	412(ra) # 8000053c <panic>

00000000800023a8 <yield>:
{
    800023a8:	1101                	addi	sp,sp,-32
    800023aa:	ec06                	sd	ra,24(sp)
    800023ac:	e822                	sd	s0,16(sp)
    800023ae:	e426                	sd	s1,8(sp)
    800023b0:	1000                	addi	s0,sp,32
    struct proc *p = myproc();
    800023b2:	00000097          	auipc	ra,0x0
    800023b6:	8aa080e7          	jalr	-1878(ra) # 80001c5c <myproc>
    800023ba:	84aa                	mv	s1,a0
    acquire(&p->lock);
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	816080e7          	jalr	-2026(ra) # 80000bd2 <acquire>
    p->state = RUNNABLE;
    800023c4:	478d                	li	a5,3
    800023c6:	cc9c                	sw	a5,24(s1)
    sched();
    800023c8:	00000097          	auipc	ra,0x0
    800023cc:	f12080e7          	jalr	-238(ra) # 800022da <sched>
    release(&p->lock);
    800023d0:	8526                	mv	a0,s1
    800023d2:	fffff097          	auipc	ra,0xfffff
    800023d6:	8b4080e7          	jalr	-1868(ra) # 80000c86 <release>
}
    800023da:	60e2                	ld	ra,24(sp)
    800023dc:	6442                	ld	s0,16(sp)
    800023de:	64a2                	ld	s1,8(sp)
    800023e0:	6105                	addi	sp,sp,32
    800023e2:	8082                	ret

00000000800023e4 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void sleep(void *chan, struct spinlock *lk)
{
    800023e4:	7179                	addi	sp,sp,-48
    800023e6:	f406                	sd	ra,40(sp)
    800023e8:	f022                	sd	s0,32(sp)
    800023ea:	ec26                	sd	s1,24(sp)
    800023ec:	e84a                	sd	s2,16(sp)
    800023ee:	e44e                	sd	s3,8(sp)
    800023f0:	1800                	addi	s0,sp,48
    800023f2:	89aa                	mv	s3,a0
    800023f4:	892e                	mv	s2,a1
    struct proc *p = myproc();
    800023f6:	00000097          	auipc	ra,0x0
    800023fa:	866080e7          	jalr	-1946(ra) # 80001c5c <myproc>
    800023fe:	84aa                	mv	s1,a0
    // Once we hold p->lock, we can be
    // guaranteed that we won't miss any wakeup
    // (wakeup locks p->lock),
    // so it's okay to release lk.

    acquire(&p->lock); // DOC: sleeplock1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d2080e7          	jalr	2002(ra) # 80000bd2 <acquire>
    release(lk);
    80002408:	854a                	mv	a0,s2
    8000240a:	fffff097          	auipc	ra,0xfffff
    8000240e:	87c080e7          	jalr	-1924(ra) # 80000c86 <release>

    // Go to sleep.
    p->chan = chan;
    80002412:	0334b023          	sd	s3,32(s1)
    p->state = SLEEPING;
    80002416:	4789                	li	a5,2
    80002418:	cc9c                	sw	a5,24(s1)

    sched();
    8000241a:	00000097          	auipc	ra,0x0
    8000241e:	ec0080e7          	jalr	-320(ra) # 800022da <sched>

    // Tidy up.
    p->chan = 0;
    80002422:	0204b023          	sd	zero,32(s1)

    // Reacquire original lock.
    release(&p->lock);
    80002426:	8526                	mv	a0,s1
    80002428:	fffff097          	auipc	ra,0xfffff
    8000242c:	85e080e7          	jalr	-1954(ra) # 80000c86 <release>
    acquire(lk);
    80002430:	854a                	mv	a0,s2
    80002432:	ffffe097          	auipc	ra,0xffffe
    80002436:	7a0080e7          	jalr	1952(ra) # 80000bd2 <acquire>
}
    8000243a:	70a2                	ld	ra,40(sp)
    8000243c:	7402                	ld	s0,32(sp)
    8000243e:	64e2                	ld	s1,24(sp)
    80002440:	6942                	ld	s2,16(sp)
    80002442:	69a2                	ld	s3,8(sp)
    80002444:	6145                	addi	sp,sp,48
    80002446:	8082                	ret

0000000080002448 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void wakeup(void *chan)
{
    80002448:	7139                	addi	sp,sp,-64
    8000244a:	fc06                	sd	ra,56(sp)
    8000244c:	f822                	sd	s0,48(sp)
    8000244e:	f426                	sd	s1,40(sp)
    80002450:	f04a                	sd	s2,32(sp)
    80002452:	ec4e                	sd	s3,24(sp)
    80002454:	e852                	sd	s4,16(sp)
    80002456:	e456                	sd	s5,8(sp)
    80002458:	0080                	addi	s0,sp,64
    8000245a:	8a2a                	mv	s4,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    8000245c:	0000f497          	auipc	s1,0xf
    80002460:	d4448493          	addi	s1,s1,-700 # 800111a0 <proc>
    {
        if (p != myproc())
        {
            acquire(&p->lock);
            if (p->state == SLEEPING && p->chan == chan)
    80002464:	4989                	li	s3,2
            {
                p->state = RUNNABLE;
    80002466:	4a8d                	li	s5,3
    for (p = proc; p < &proc[NPROC]; p++)
    80002468:	00014917          	auipc	s2,0x14
    8000246c:	73890913          	addi	s2,s2,1848 # 80016ba0 <tickslock>
    80002470:	a811                	j	80002484 <wakeup+0x3c>
            }
            release(&p->lock);
    80002472:	8526                	mv	a0,s1
    80002474:	fffff097          	auipc	ra,0xfffff
    80002478:	812080e7          	jalr	-2030(ra) # 80000c86 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    8000247c:	16848493          	addi	s1,s1,360
    80002480:	03248663          	beq	s1,s2,800024ac <wakeup+0x64>
        if (p != myproc())
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	7d8080e7          	jalr	2008(ra) # 80001c5c <myproc>
    8000248c:	fea488e3          	beq	s1,a0,8000247c <wakeup+0x34>
            acquire(&p->lock);
    80002490:	8526                	mv	a0,s1
    80002492:	ffffe097          	auipc	ra,0xffffe
    80002496:	740080e7          	jalr	1856(ra) # 80000bd2 <acquire>
            if (p->state == SLEEPING && p->chan == chan)
    8000249a:	4c9c                	lw	a5,24(s1)
    8000249c:	fd379be3          	bne	a5,s3,80002472 <wakeup+0x2a>
    800024a0:	709c                	ld	a5,32(s1)
    800024a2:	fd4798e3          	bne	a5,s4,80002472 <wakeup+0x2a>
                p->state = RUNNABLE;
    800024a6:	0154ac23          	sw	s5,24(s1)
    800024aa:	b7e1                	j	80002472 <wakeup+0x2a>
        }
    }
}
    800024ac:	70e2                	ld	ra,56(sp)
    800024ae:	7442                	ld	s0,48(sp)
    800024b0:	74a2                	ld	s1,40(sp)
    800024b2:	7902                	ld	s2,32(sp)
    800024b4:	69e2                	ld	s3,24(sp)
    800024b6:	6a42                	ld	s4,16(sp)
    800024b8:	6aa2                	ld	s5,8(sp)
    800024ba:	6121                	addi	sp,sp,64
    800024bc:	8082                	ret

00000000800024be <reparent>:
{
    800024be:	7179                	addi	sp,sp,-48
    800024c0:	f406                	sd	ra,40(sp)
    800024c2:	f022                	sd	s0,32(sp)
    800024c4:	ec26                	sd	s1,24(sp)
    800024c6:	e84a                	sd	s2,16(sp)
    800024c8:	e44e                	sd	s3,8(sp)
    800024ca:	e052                	sd	s4,0(sp)
    800024cc:	1800                	addi	s0,sp,48
    800024ce:	892a                	mv	s2,a0
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024d0:	0000f497          	auipc	s1,0xf
    800024d4:	cd048493          	addi	s1,s1,-816 # 800111a0 <proc>
            pp->parent = initproc;
    800024d8:	00006a17          	auipc	s4,0x6
    800024dc:	528a0a13          	addi	s4,s4,1320 # 80008a00 <initproc>
    for (pp = proc; pp < &proc[NPROC]; pp++)
    800024e0:	00014997          	auipc	s3,0x14
    800024e4:	6c098993          	addi	s3,s3,1728 # 80016ba0 <tickslock>
    800024e8:	a029                	j	800024f2 <reparent+0x34>
    800024ea:	16848493          	addi	s1,s1,360
    800024ee:	01348d63          	beq	s1,s3,80002508 <reparent+0x4a>
        if (pp->parent == p)
    800024f2:	7c9c                	ld	a5,56(s1)
    800024f4:	ff279be3          	bne	a5,s2,800024ea <reparent+0x2c>
            pp->parent = initproc;
    800024f8:	000a3503          	ld	a0,0(s4)
    800024fc:	fc88                	sd	a0,56(s1)
            wakeup(initproc);
    800024fe:	00000097          	auipc	ra,0x0
    80002502:	f4a080e7          	jalr	-182(ra) # 80002448 <wakeup>
    80002506:	b7d5                	j	800024ea <reparent+0x2c>
}
    80002508:	70a2                	ld	ra,40(sp)
    8000250a:	7402                	ld	s0,32(sp)
    8000250c:	64e2                	ld	s1,24(sp)
    8000250e:	6942                	ld	s2,16(sp)
    80002510:	69a2                	ld	s3,8(sp)
    80002512:	6a02                	ld	s4,0(sp)
    80002514:	6145                	addi	sp,sp,48
    80002516:	8082                	ret

0000000080002518 <exit>:
{
    80002518:	7179                	addi	sp,sp,-48
    8000251a:	f406                	sd	ra,40(sp)
    8000251c:	f022                	sd	s0,32(sp)
    8000251e:	ec26                	sd	s1,24(sp)
    80002520:	e84a                	sd	s2,16(sp)
    80002522:	e44e                	sd	s3,8(sp)
    80002524:	e052                	sd	s4,0(sp)
    80002526:	1800                	addi	s0,sp,48
    80002528:	8a2a                	mv	s4,a0
    struct proc *p = myproc();
    8000252a:	fffff097          	auipc	ra,0xfffff
    8000252e:	732080e7          	jalr	1842(ra) # 80001c5c <myproc>
    80002532:	89aa                	mv	s3,a0
    if (p == initproc)
    80002534:	00006797          	auipc	a5,0x6
    80002538:	4cc7b783          	ld	a5,1228(a5) # 80008a00 <initproc>
    8000253c:	0d050493          	addi	s1,a0,208
    80002540:	15050913          	addi	s2,a0,336
    80002544:	02a79363          	bne	a5,a0,8000256a <exit+0x52>
        panic("init exiting");
    80002548:	00006517          	auipc	a0,0x6
    8000254c:	d1850513          	addi	a0,a0,-744 # 80008260 <digits+0x220>
    80002550:	ffffe097          	auipc	ra,0xffffe
    80002554:	fec080e7          	jalr	-20(ra) # 8000053c <panic>
            fileclose(f);
    80002558:	00002097          	auipc	ra,0x2
    8000255c:	4a0080e7          	jalr	1184(ra) # 800049f8 <fileclose>
            p->ofile[fd] = 0;
    80002560:	0004b023          	sd	zero,0(s1)
    for (int fd = 0; fd < NOFILE; fd++)
    80002564:	04a1                	addi	s1,s1,8
    80002566:	01248563          	beq	s1,s2,80002570 <exit+0x58>
        if (p->ofile[fd])
    8000256a:	6088                	ld	a0,0(s1)
    8000256c:	f575                	bnez	a0,80002558 <exit+0x40>
    8000256e:	bfdd                	j	80002564 <exit+0x4c>
    begin_op();
    80002570:	00002097          	auipc	ra,0x2
    80002574:	fc4080e7          	jalr	-60(ra) # 80004534 <begin_op>
    iput(p->cwd);
    80002578:	1509b503          	ld	a0,336(s3)
    8000257c:	00001097          	auipc	ra,0x1
    80002580:	7cc080e7          	jalr	1996(ra) # 80003d48 <iput>
    end_op();
    80002584:	00002097          	auipc	ra,0x2
    80002588:	02a080e7          	jalr	42(ra) # 800045ae <end_op>
    p->cwd = 0;
    8000258c:	1409b823          	sd	zero,336(s3)
    acquire(&wait_lock);
    80002590:	0000f497          	auipc	s1,0xf
    80002594:	bf848493          	addi	s1,s1,-1032 # 80011188 <wait_lock>
    80002598:	8526                	mv	a0,s1
    8000259a:	ffffe097          	auipc	ra,0xffffe
    8000259e:	638080e7          	jalr	1592(ra) # 80000bd2 <acquire>
    reparent(p);
    800025a2:	854e                	mv	a0,s3
    800025a4:	00000097          	auipc	ra,0x0
    800025a8:	f1a080e7          	jalr	-230(ra) # 800024be <reparent>
    wakeup(p->parent);
    800025ac:	0389b503          	ld	a0,56(s3)
    800025b0:	00000097          	auipc	ra,0x0
    800025b4:	e98080e7          	jalr	-360(ra) # 80002448 <wakeup>
    acquire(&p->lock);
    800025b8:	854e                	mv	a0,s3
    800025ba:	ffffe097          	auipc	ra,0xffffe
    800025be:	618080e7          	jalr	1560(ra) # 80000bd2 <acquire>
    p->xstate = status;
    800025c2:	0349a623          	sw	s4,44(s3)
    p->state = ZOMBIE;
    800025c6:	4795                	li	a5,5
    800025c8:	00f9ac23          	sw	a5,24(s3)
    release(&wait_lock);
    800025cc:	8526                	mv	a0,s1
    800025ce:	ffffe097          	auipc	ra,0xffffe
    800025d2:	6b8080e7          	jalr	1720(ra) # 80000c86 <release>
    sched();
    800025d6:	00000097          	auipc	ra,0x0
    800025da:	d04080e7          	jalr	-764(ra) # 800022da <sched>
    panic("zombie exit");
    800025de:	00006517          	auipc	a0,0x6
    800025e2:	c9250513          	addi	a0,a0,-878 # 80008270 <digits+0x230>
    800025e6:	ffffe097          	auipc	ra,0xffffe
    800025ea:	f56080e7          	jalr	-170(ra) # 8000053c <panic>

00000000800025ee <kill>:

// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int kill(int pid)
{
    800025ee:	7179                	addi	sp,sp,-48
    800025f0:	f406                	sd	ra,40(sp)
    800025f2:	f022                	sd	s0,32(sp)
    800025f4:	ec26                	sd	s1,24(sp)
    800025f6:	e84a                	sd	s2,16(sp)
    800025f8:	e44e                	sd	s3,8(sp)
    800025fa:	1800                	addi	s0,sp,48
    800025fc:	892a                	mv	s2,a0
    struct proc *p;

    for (p = proc; p < &proc[NPROC]; p++)
    800025fe:	0000f497          	auipc	s1,0xf
    80002602:	ba248493          	addi	s1,s1,-1118 # 800111a0 <proc>
    80002606:	00014997          	auipc	s3,0x14
    8000260a:	59a98993          	addi	s3,s3,1434 # 80016ba0 <tickslock>
    {
        acquire(&p->lock);
    8000260e:	8526                	mv	a0,s1
    80002610:	ffffe097          	auipc	ra,0xffffe
    80002614:	5c2080e7          	jalr	1474(ra) # 80000bd2 <acquire>
        if (p->pid == pid)
    80002618:	589c                	lw	a5,48(s1)
    8000261a:	01278d63          	beq	a5,s2,80002634 <kill+0x46>
                p->state = RUNNABLE;
            }
            release(&p->lock);
            return 0;
        }
        release(&p->lock);
    8000261e:	8526                	mv	a0,s1
    80002620:	ffffe097          	auipc	ra,0xffffe
    80002624:	666080e7          	jalr	1638(ra) # 80000c86 <release>
    for (p = proc; p < &proc[NPROC]; p++)
    80002628:	16848493          	addi	s1,s1,360
    8000262c:	ff3491e3          	bne	s1,s3,8000260e <kill+0x20>
    }
    return -1;
    80002630:	557d                	li	a0,-1
    80002632:	a829                	j	8000264c <kill+0x5e>
            p->killed = 1;
    80002634:	4785                	li	a5,1
    80002636:	d49c                	sw	a5,40(s1)
            if (p->state == SLEEPING)
    80002638:	4c98                	lw	a4,24(s1)
    8000263a:	4789                	li	a5,2
    8000263c:	00f70f63          	beq	a4,a5,8000265a <kill+0x6c>
            release(&p->lock);
    80002640:	8526                	mv	a0,s1
    80002642:	ffffe097          	auipc	ra,0xffffe
    80002646:	644080e7          	jalr	1604(ra) # 80000c86 <release>
            return 0;
    8000264a:	4501                	li	a0,0
}
    8000264c:	70a2                	ld	ra,40(sp)
    8000264e:	7402                	ld	s0,32(sp)
    80002650:	64e2                	ld	s1,24(sp)
    80002652:	6942                	ld	s2,16(sp)
    80002654:	69a2                	ld	s3,8(sp)
    80002656:	6145                	addi	sp,sp,48
    80002658:	8082                	ret
                p->state = RUNNABLE;
    8000265a:	478d                	li	a5,3
    8000265c:	cc9c                	sw	a5,24(s1)
    8000265e:	b7cd                	j	80002640 <kill+0x52>

0000000080002660 <setkilled>:

void setkilled(struct proc *p)
{
    80002660:	1101                	addi	sp,sp,-32
    80002662:	ec06                	sd	ra,24(sp)
    80002664:	e822                	sd	s0,16(sp)
    80002666:	e426                	sd	s1,8(sp)
    80002668:	1000                	addi	s0,sp,32
    8000266a:	84aa                	mv	s1,a0
    acquire(&p->lock);
    8000266c:	ffffe097          	auipc	ra,0xffffe
    80002670:	566080e7          	jalr	1382(ra) # 80000bd2 <acquire>
    p->killed = 1;
    80002674:	4785                	li	a5,1
    80002676:	d49c                	sw	a5,40(s1)
    release(&p->lock);
    80002678:	8526                	mv	a0,s1
    8000267a:	ffffe097          	auipc	ra,0xffffe
    8000267e:	60c080e7          	jalr	1548(ra) # 80000c86 <release>
}
    80002682:	60e2                	ld	ra,24(sp)
    80002684:	6442                	ld	s0,16(sp)
    80002686:	64a2                	ld	s1,8(sp)
    80002688:	6105                	addi	sp,sp,32
    8000268a:	8082                	ret

000000008000268c <killed>:

int killed(struct proc *p)
{
    8000268c:	1101                	addi	sp,sp,-32
    8000268e:	ec06                	sd	ra,24(sp)
    80002690:	e822                	sd	s0,16(sp)
    80002692:	e426                	sd	s1,8(sp)
    80002694:	e04a                	sd	s2,0(sp)
    80002696:	1000                	addi	s0,sp,32
    80002698:	84aa                	mv	s1,a0
    int k;

    acquire(&p->lock);
    8000269a:	ffffe097          	auipc	ra,0xffffe
    8000269e:	538080e7          	jalr	1336(ra) # 80000bd2 <acquire>
    k = p->killed;
    800026a2:	0284a903          	lw	s2,40(s1)
    release(&p->lock);
    800026a6:	8526                	mv	a0,s1
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	5de080e7          	jalr	1502(ra) # 80000c86 <release>
    return k;
}
    800026b0:	854a                	mv	a0,s2
    800026b2:	60e2                	ld	ra,24(sp)
    800026b4:	6442                	ld	s0,16(sp)
    800026b6:	64a2                	ld	s1,8(sp)
    800026b8:	6902                	ld	s2,0(sp)
    800026ba:	6105                	addi	sp,sp,32
    800026bc:	8082                	ret

00000000800026be <wait>:
{
    800026be:	715d                	addi	sp,sp,-80
    800026c0:	e486                	sd	ra,72(sp)
    800026c2:	e0a2                	sd	s0,64(sp)
    800026c4:	fc26                	sd	s1,56(sp)
    800026c6:	f84a                	sd	s2,48(sp)
    800026c8:	f44e                	sd	s3,40(sp)
    800026ca:	f052                	sd	s4,32(sp)
    800026cc:	ec56                	sd	s5,24(sp)
    800026ce:	e85a                	sd	s6,16(sp)
    800026d0:	e45e                	sd	s7,8(sp)
    800026d2:	e062                	sd	s8,0(sp)
    800026d4:	0880                	addi	s0,sp,80
    800026d6:	8b2a                	mv	s6,a0
    struct proc *p = myproc();
    800026d8:	fffff097          	auipc	ra,0xfffff
    800026dc:	584080e7          	jalr	1412(ra) # 80001c5c <myproc>
    800026e0:	892a                	mv	s2,a0
    acquire(&wait_lock);
    800026e2:	0000f517          	auipc	a0,0xf
    800026e6:	aa650513          	addi	a0,a0,-1370 # 80011188 <wait_lock>
    800026ea:	ffffe097          	auipc	ra,0xffffe
    800026ee:	4e8080e7          	jalr	1256(ra) # 80000bd2 <acquire>
        havekids = 0;
    800026f2:	4b81                	li	s7,0
                if (pp->state == ZOMBIE)
    800026f4:	4a15                	li	s4,5
                havekids = 1;
    800026f6:	4a85                	li	s5,1
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800026f8:	00014997          	auipc	s3,0x14
    800026fc:	4a898993          	addi	s3,s3,1192 # 80016ba0 <tickslock>
        sleep(p, &wait_lock); // DOC: wait-sleep
    80002700:	0000fc17          	auipc	s8,0xf
    80002704:	a88c0c13          	addi	s8,s8,-1400 # 80011188 <wait_lock>
    80002708:	a0d1                	j	800027cc <wait+0x10e>
                    pid = pp->pid;
    8000270a:	0304a983          	lw	s3,48(s1)
                    if (addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000270e:	000b0e63          	beqz	s6,8000272a <wait+0x6c>
    80002712:	4691                	li	a3,4
    80002714:	02c48613          	addi	a2,s1,44
    80002718:	85da                	mv	a1,s6
    8000271a:	05093503          	ld	a0,80(s2)
    8000271e:	fffff097          	auipc	ra,0xfffff
    80002722:	f48080e7          	jalr	-184(ra) # 80001666 <copyout>
    80002726:	04054163          	bltz	a0,80002768 <wait+0xaa>
                    freeproc(pp);
    8000272a:	8526                	mv	a0,s1
    8000272c:	fffff097          	auipc	ra,0xfffff
    80002730:	6e2080e7          	jalr	1762(ra) # 80001e0e <freeproc>
                    release(&pp->lock);
    80002734:	8526                	mv	a0,s1
    80002736:	ffffe097          	auipc	ra,0xffffe
    8000273a:	550080e7          	jalr	1360(ra) # 80000c86 <release>
                    release(&wait_lock);
    8000273e:	0000f517          	auipc	a0,0xf
    80002742:	a4a50513          	addi	a0,a0,-1462 # 80011188 <wait_lock>
    80002746:	ffffe097          	auipc	ra,0xffffe
    8000274a:	540080e7          	jalr	1344(ra) # 80000c86 <release>
}
    8000274e:	854e                	mv	a0,s3
    80002750:	60a6                	ld	ra,72(sp)
    80002752:	6406                	ld	s0,64(sp)
    80002754:	74e2                	ld	s1,56(sp)
    80002756:	7942                	ld	s2,48(sp)
    80002758:	79a2                	ld	s3,40(sp)
    8000275a:	7a02                	ld	s4,32(sp)
    8000275c:	6ae2                	ld	s5,24(sp)
    8000275e:	6b42                	ld	s6,16(sp)
    80002760:	6ba2                	ld	s7,8(sp)
    80002762:	6c02                	ld	s8,0(sp)
    80002764:	6161                	addi	sp,sp,80
    80002766:	8082                	ret
                        release(&pp->lock);
    80002768:	8526                	mv	a0,s1
    8000276a:	ffffe097          	auipc	ra,0xffffe
    8000276e:	51c080e7          	jalr	1308(ra) # 80000c86 <release>
                        release(&wait_lock);
    80002772:	0000f517          	auipc	a0,0xf
    80002776:	a1650513          	addi	a0,a0,-1514 # 80011188 <wait_lock>
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	50c080e7          	jalr	1292(ra) # 80000c86 <release>
                        return -1;
    80002782:	59fd                	li	s3,-1
    80002784:	b7e9                	j	8000274e <wait+0x90>
        for (pp = proc; pp < &proc[NPROC]; pp++)
    80002786:	16848493          	addi	s1,s1,360
    8000278a:	03348463          	beq	s1,s3,800027b2 <wait+0xf4>
            if (pp->parent == p)
    8000278e:	7c9c                	ld	a5,56(s1)
    80002790:	ff279be3          	bne	a5,s2,80002786 <wait+0xc8>
                acquire(&pp->lock);
    80002794:	8526                	mv	a0,s1
    80002796:	ffffe097          	auipc	ra,0xffffe
    8000279a:	43c080e7          	jalr	1084(ra) # 80000bd2 <acquire>
                if (pp->state == ZOMBIE)
    8000279e:	4c9c                	lw	a5,24(s1)
    800027a0:	f74785e3          	beq	a5,s4,8000270a <wait+0x4c>
                release(&pp->lock);
    800027a4:	8526                	mv	a0,s1
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	4e0080e7          	jalr	1248(ra) # 80000c86 <release>
                havekids = 1;
    800027ae:	8756                	mv	a4,s5
    800027b0:	bfd9                	j	80002786 <wait+0xc8>
        if (!havekids || killed(p))
    800027b2:	c31d                	beqz	a4,800027d8 <wait+0x11a>
    800027b4:	854a                	mv	a0,s2
    800027b6:	00000097          	auipc	ra,0x0
    800027ba:	ed6080e7          	jalr	-298(ra) # 8000268c <killed>
    800027be:	ed09                	bnez	a0,800027d8 <wait+0x11a>
        sleep(p, &wait_lock); // DOC: wait-sleep
    800027c0:	85e2                	mv	a1,s8
    800027c2:	854a                	mv	a0,s2
    800027c4:	00000097          	auipc	ra,0x0
    800027c8:	c20080e7          	jalr	-992(ra) # 800023e4 <sleep>
        havekids = 0;
    800027cc:	875e                	mv	a4,s7
        for (pp = proc; pp < &proc[NPROC]; pp++)
    800027ce:	0000f497          	auipc	s1,0xf
    800027d2:	9d248493          	addi	s1,s1,-1582 # 800111a0 <proc>
    800027d6:	bf65                	j	8000278e <wait+0xd0>
            release(&wait_lock);
    800027d8:	0000f517          	auipc	a0,0xf
    800027dc:	9b050513          	addi	a0,a0,-1616 # 80011188 <wait_lock>
    800027e0:	ffffe097          	auipc	ra,0xffffe
    800027e4:	4a6080e7          	jalr	1190(ra) # 80000c86 <release>
            return -1;
    800027e8:	59fd                	li	s3,-1
    800027ea:	b795                	j	8000274e <wait+0x90>

00000000800027ec <either_copyout>:

// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800027ec:	7179                	addi	sp,sp,-48
    800027ee:	f406                	sd	ra,40(sp)
    800027f0:	f022                	sd	s0,32(sp)
    800027f2:	ec26                	sd	s1,24(sp)
    800027f4:	e84a                	sd	s2,16(sp)
    800027f6:	e44e                	sd	s3,8(sp)
    800027f8:	e052                	sd	s4,0(sp)
    800027fa:	1800                	addi	s0,sp,48
    800027fc:	84aa                	mv	s1,a0
    800027fe:	892e                	mv	s2,a1
    80002800:	89b2                	mv	s3,a2
    80002802:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    80002804:	fffff097          	auipc	ra,0xfffff
    80002808:	458080e7          	jalr	1112(ra) # 80001c5c <myproc>
    if (user_dst)
    8000280c:	c08d                	beqz	s1,8000282e <either_copyout+0x42>
    {
        return copyout(p->pagetable, dst, src, len);
    8000280e:	86d2                	mv	a3,s4
    80002810:	864e                	mv	a2,s3
    80002812:	85ca                	mv	a1,s2
    80002814:	6928                	ld	a0,80(a0)
    80002816:	fffff097          	auipc	ra,0xfffff
    8000281a:	e50080e7          	jalr	-432(ra) # 80001666 <copyout>
    else
    {
        memmove((char *)dst, src, len);
        return 0;
    }
}
    8000281e:	70a2                	ld	ra,40(sp)
    80002820:	7402                	ld	s0,32(sp)
    80002822:	64e2                	ld	s1,24(sp)
    80002824:	6942                	ld	s2,16(sp)
    80002826:	69a2                	ld	s3,8(sp)
    80002828:	6a02                	ld	s4,0(sp)
    8000282a:	6145                	addi	sp,sp,48
    8000282c:	8082                	ret
        memmove((char *)dst, src, len);
    8000282e:	000a061b          	sext.w	a2,s4
    80002832:	85ce                	mv	a1,s3
    80002834:	854a                	mv	a0,s2
    80002836:	ffffe097          	auipc	ra,0xffffe
    8000283a:	4f4080e7          	jalr	1268(ra) # 80000d2a <memmove>
        return 0;
    8000283e:	8526                	mv	a0,s1
    80002840:	bff9                	j	8000281e <either_copyout+0x32>

0000000080002842 <either_copyin>:

// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002842:	7179                	addi	sp,sp,-48
    80002844:	f406                	sd	ra,40(sp)
    80002846:	f022                	sd	s0,32(sp)
    80002848:	ec26                	sd	s1,24(sp)
    8000284a:	e84a                	sd	s2,16(sp)
    8000284c:	e44e                	sd	s3,8(sp)
    8000284e:	e052                	sd	s4,0(sp)
    80002850:	1800                	addi	s0,sp,48
    80002852:	892a                	mv	s2,a0
    80002854:	84ae                	mv	s1,a1
    80002856:	89b2                	mv	s3,a2
    80002858:	8a36                	mv	s4,a3
    struct proc *p = myproc();
    8000285a:	fffff097          	auipc	ra,0xfffff
    8000285e:	402080e7          	jalr	1026(ra) # 80001c5c <myproc>
    if (user_src)
    80002862:	c08d                	beqz	s1,80002884 <either_copyin+0x42>
    {
        return copyin(p->pagetable, dst, src, len);
    80002864:	86d2                	mv	a3,s4
    80002866:	864e                	mv	a2,s3
    80002868:	85ca                	mv	a1,s2
    8000286a:	6928                	ld	a0,80(a0)
    8000286c:	fffff097          	auipc	ra,0xfffff
    80002870:	e86080e7          	jalr	-378(ra) # 800016f2 <copyin>
    else
    {
        memmove(dst, (char *)src, len);
        return 0;
    }
}
    80002874:	70a2                	ld	ra,40(sp)
    80002876:	7402                	ld	s0,32(sp)
    80002878:	64e2                	ld	s1,24(sp)
    8000287a:	6942                	ld	s2,16(sp)
    8000287c:	69a2                	ld	s3,8(sp)
    8000287e:	6a02                	ld	s4,0(sp)
    80002880:	6145                	addi	sp,sp,48
    80002882:	8082                	ret
        memmove(dst, (char *)src, len);
    80002884:	000a061b          	sext.w	a2,s4
    80002888:	85ce                	mv	a1,s3
    8000288a:	854a                	mv	a0,s2
    8000288c:	ffffe097          	auipc	ra,0xffffe
    80002890:	49e080e7          	jalr	1182(ra) # 80000d2a <memmove>
        return 0;
    80002894:	8526                	mv	a0,s1
    80002896:	bff9                	j	80002874 <either_copyin+0x32>

0000000080002898 <procdump>:

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void procdump(void)
{
    80002898:	715d                	addi	sp,sp,-80
    8000289a:	e486                	sd	ra,72(sp)
    8000289c:	e0a2                	sd	s0,64(sp)
    8000289e:	fc26                	sd	s1,56(sp)
    800028a0:	f84a                	sd	s2,48(sp)
    800028a2:	f44e                	sd	s3,40(sp)
    800028a4:	f052                	sd	s4,32(sp)
    800028a6:	ec56                	sd	s5,24(sp)
    800028a8:	e85a                	sd	s6,16(sp)
    800028aa:	e45e                	sd	s7,8(sp)
    800028ac:	0880                	addi	s0,sp,80
        [RUNNING] "run   ",
        [ZOMBIE] "zombie"};
    struct proc *p;
    char *state;

    printf("\n");
    800028ae:	00006517          	auipc	a0,0x6
    800028b2:	81a50513          	addi	a0,a0,-2022 # 800080c8 <digits+0x88>
    800028b6:	ffffe097          	auipc	ra,0xffffe
    800028ba:	cd0080e7          	jalr	-816(ra) # 80000586 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    800028be:	0000f497          	auipc	s1,0xf
    800028c2:	a3a48493          	addi	s1,s1,-1478 # 800112f8 <proc+0x158>
    800028c6:	00014917          	auipc	s2,0x14
    800028ca:	43290913          	addi	s2,s2,1074 # 80016cf8 <bcache+0x140>
    {
        if (p->state == UNUSED)
            continue;
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028ce:	4b15                	li	s6,5
            state = states[p->state];
        else
            state = "???";
    800028d0:	00006997          	auipc	s3,0x6
    800028d4:	9b098993          	addi	s3,s3,-1616 # 80008280 <digits+0x240>
        printf("%d <%s %s", p->pid, state, p->name);
    800028d8:	00006a97          	auipc	s5,0x6
    800028dc:	9b0a8a93          	addi	s5,s5,-1616 # 80008288 <digits+0x248>
        printf("\n");
    800028e0:	00005a17          	auipc	s4,0x5
    800028e4:	7e8a0a13          	addi	s4,s4,2024 # 800080c8 <digits+0x88>
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800028e8:	00006b97          	auipc	s7,0x6
    800028ec:	ab0b8b93          	addi	s7,s7,-1360 # 80008398 <states.0>
    800028f0:	a00d                	j	80002912 <procdump+0x7a>
        printf("%d <%s %s", p->pid, state, p->name);
    800028f2:	ed86a583          	lw	a1,-296(a3)
    800028f6:	8556                	mv	a0,s5
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	c8e080e7          	jalr	-882(ra) # 80000586 <printf>
        printf("\n");
    80002900:	8552                	mv	a0,s4
    80002902:	ffffe097          	auipc	ra,0xffffe
    80002906:	c84080e7          	jalr	-892(ra) # 80000586 <printf>
    for (p = proc; p < &proc[NPROC]; p++)
    8000290a:	16848493          	addi	s1,s1,360
    8000290e:	03248263          	beq	s1,s2,80002932 <procdump+0x9a>
        if (p->state == UNUSED)
    80002912:	86a6                	mv	a3,s1
    80002914:	ec04a783          	lw	a5,-320(s1)
    80002918:	dbed                	beqz	a5,8000290a <procdump+0x72>
            state = "???";
    8000291a:	864e                	mv	a2,s3
        if (p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000291c:	fcfb6be3          	bltu	s6,a5,800028f2 <procdump+0x5a>
    80002920:	02079713          	slli	a4,a5,0x20
    80002924:	01d75793          	srli	a5,a4,0x1d
    80002928:	97de                	add	a5,a5,s7
    8000292a:	6390                	ld	a2,0(a5)
    8000292c:	f279                	bnez	a2,800028f2 <procdump+0x5a>
            state = "???";
    8000292e:	864e                	mv	a2,s3
    80002930:	b7c9                	j	800028f2 <procdump+0x5a>
    }
}
    80002932:	60a6                	ld	ra,72(sp)
    80002934:	6406                	ld	s0,64(sp)
    80002936:	74e2                	ld	s1,56(sp)
    80002938:	7942                	ld	s2,48(sp)
    8000293a:	79a2                	ld	s3,40(sp)
    8000293c:	7a02                	ld	s4,32(sp)
    8000293e:	6ae2                	ld	s5,24(sp)
    80002940:	6b42                	ld	s6,16(sp)
    80002942:	6ba2                	ld	s7,8(sp)
    80002944:	6161                	addi	sp,sp,80
    80002946:	8082                	ret

0000000080002948 <schedls>:

void schedls()
{
    80002948:	1101                	addi	sp,sp,-32
    8000294a:	ec06                	sd	ra,24(sp)
    8000294c:	e822                	sd	s0,16(sp)
    8000294e:	e426                	sd	s1,8(sp)
    80002950:	1000                	addi	s0,sp,32
    printf("[ ]\tScheduler Name\tScheduler ID\n");
    80002952:	00006517          	auipc	a0,0x6
    80002956:	94650513          	addi	a0,a0,-1722 # 80008298 <digits+0x258>
    8000295a:	ffffe097          	auipc	ra,0xffffe
    8000295e:	c2c080e7          	jalr	-980(ra) # 80000586 <printf>
    printf("====================================\n");
    80002962:	00006517          	auipc	a0,0x6
    80002966:	95e50513          	addi	a0,a0,-1698 # 800082c0 <digits+0x280>
    8000296a:	ffffe097          	auipc	ra,0xffffe
    8000296e:	c1c080e7          	jalr	-996(ra) # 80000586 <printf>
    for (int i = 0; i < SCHEDC; i++)
    {
        if (available_schedulers[i].impl == sched_pointer)
    80002972:	00006717          	auipc	a4,0x6
    80002976:	02673703          	ld	a4,38(a4) # 80008998 <available_schedulers+0x10>
    8000297a:	00006797          	auipc	a5,0x6
    8000297e:	fbe7b783          	ld	a5,-66(a5) # 80008938 <sched_pointer>
    80002982:	08f70763          	beq	a4,a5,80002a10 <schedls+0xc8>
        {
            printf("[*]\t");
        }
        else
        {
            printf("   \t");
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	96250513          	addi	a0,a0,-1694 # 800082e8 <digits+0x2a8>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bf8080e7          	jalr	-1032(ra) # 80000586 <printf>
        }
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    80002996:	00006497          	auipc	s1,0x6
    8000299a:	fba48493          	addi	s1,s1,-70 # 80008950 <initcode>
    8000299e:	48b0                	lw	a2,80(s1)
    800029a0:	00006597          	auipc	a1,0x6
    800029a4:	fe858593          	addi	a1,a1,-24 # 80008988 <available_schedulers>
    800029a8:	00006517          	auipc	a0,0x6
    800029ac:	95050513          	addi	a0,a0,-1712 # 800082f8 <digits+0x2b8>
    800029b0:	ffffe097          	auipc	ra,0xffffe
    800029b4:	bd6080e7          	jalr	-1066(ra) # 80000586 <printf>
        if (available_schedulers[i].impl == sched_pointer)
    800029b8:	74b8                	ld	a4,104(s1)
    800029ba:	00006797          	auipc	a5,0x6
    800029be:	f7e7b783          	ld	a5,-130(a5) # 80008938 <sched_pointer>
    800029c2:	06f70063          	beq	a4,a5,80002a22 <schedls+0xda>
            printf("   \t");
    800029c6:	00006517          	auipc	a0,0x6
    800029ca:	92250513          	addi	a0,a0,-1758 # 800082e8 <digits+0x2a8>
    800029ce:	ffffe097          	auipc	ra,0xffffe
    800029d2:	bb8080e7          	jalr	-1096(ra) # 80000586 <printf>
        printf("%s\t%d\n", available_schedulers[i].name, available_schedulers[i].id);
    800029d6:	00006617          	auipc	a2,0x6
    800029da:	fea62603          	lw	a2,-22(a2) # 800089c0 <available_schedulers+0x38>
    800029de:	00006597          	auipc	a1,0x6
    800029e2:	fca58593          	addi	a1,a1,-54 # 800089a8 <available_schedulers+0x20>
    800029e6:	00006517          	auipc	a0,0x6
    800029ea:	91250513          	addi	a0,a0,-1774 # 800082f8 <digits+0x2b8>
    800029ee:	ffffe097          	auipc	ra,0xffffe
    800029f2:	b98080e7          	jalr	-1128(ra) # 80000586 <printf>
    }
    printf("\n*: current scheduler\n\n");
    800029f6:	00006517          	auipc	a0,0x6
    800029fa:	90a50513          	addi	a0,a0,-1782 # 80008300 <digits+0x2c0>
    800029fe:	ffffe097          	auipc	ra,0xffffe
    80002a02:	b88080e7          	jalr	-1144(ra) # 80000586 <printf>
}
    80002a06:	60e2                	ld	ra,24(sp)
    80002a08:	6442                	ld	s0,16(sp)
    80002a0a:	64a2                	ld	s1,8(sp)
    80002a0c:	6105                	addi	sp,sp,32
    80002a0e:	8082                	ret
            printf("[*]\t");
    80002a10:	00006517          	auipc	a0,0x6
    80002a14:	8e050513          	addi	a0,a0,-1824 # 800082f0 <digits+0x2b0>
    80002a18:	ffffe097          	auipc	ra,0xffffe
    80002a1c:	b6e080e7          	jalr	-1170(ra) # 80000586 <printf>
    80002a20:	bf9d                	j	80002996 <schedls+0x4e>
    80002a22:	00006517          	auipc	a0,0x6
    80002a26:	8ce50513          	addi	a0,a0,-1842 # 800082f0 <digits+0x2b0>
    80002a2a:	ffffe097          	auipc	ra,0xffffe
    80002a2e:	b5c080e7          	jalr	-1188(ra) # 80000586 <printf>
    80002a32:	b755                	j	800029d6 <schedls+0x8e>

0000000080002a34 <schedset>:

void schedset(int id)
{
    80002a34:	1141                	addi	sp,sp,-16
    80002a36:	e406                	sd	ra,8(sp)
    80002a38:	e022                	sd	s0,0(sp)
    80002a3a:	0800                	addi	s0,sp,16
    if (id < 0 || SCHEDC <= id)
    80002a3c:	4705                	li	a4,1
    80002a3e:	02a76f63          	bltu	a4,a0,80002a7c <schedset+0x48>
    {
        printf("Scheduler unchanged: ID out of range\n");
        return;
    }
    sched_pointer = available_schedulers[id].impl;
    80002a42:	00551793          	slli	a5,a0,0x5
    80002a46:	00006717          	auipc	a4,0x6
    80002a4a:	f0a70713          	addi	a4,a4,-246 # 80008950 <initcode>
    80002a4e:	973e                	add	a4,a4,a5
    80002a50:	6738                	ld	a4,72(a4)
    80002a52:	00006697          	auipc	a3,0x6
    80002a56:	eee6b323          	sd	a4,-282(a3) # 80008938 <sched_pointer>
    printf("Scheduler successfully changed to %s\n", available_schedulers[id].name);
    80002a5a:	00006597          	auipc	a1,0x6
    80002a5e:	f2e58593          	addi	a1,a1,-210 # 80008988 <available_schedulers>
    80002a62:	95be                	add	a1,a1,a5
    80002a64:	00006517          	auipc	a0,0x6
    80002a68:	8dc50513          	addi	a0,a0,-1828 # 80008340 <digits+0x300>
    80002a6c:	ffffe097          	auipc	ra,0xffffe
    80002a70:	b1a080e7          	jalr	-1254(ra) # 80000586 <printf>
    80002a74:	60a2                	ld	ra,8(sp)
    80002a76:	6402                	ld	s0,0(sp)
    80002a78:	0141                	addi	sp,sp,16
    80002a7a:	8082                	ret
        printf("Scheduler unchanged: ID out of range\n");
    80002a7c:	00006517          	auipc	a0,0x6
    80002a80:	89c50513          	addi	a0,a0,-1892 # 80008318 <digits+0x2d8>
    80002a84:	ffffe097          	auipc	ra,0xffffe
    80002a88:	b02080e7          	jalr	-1278(ra) # 80000586 <printf>
        return;
    80002a8c:	b7e5                	j	80002a74 <schedset+0x40>

0000000080002a8e <swtch>:
    80002a8e:	00153023          	sd	ra,0(a0)
    80002a92:	00253423          	sd	sp,8(a0)
    80002a96:	e900                	sd	s0,16(a0)
    80002a98:	ed04                	sd	s1,24(a0)
    80002a9a:	03253023          	sd	s2,32(a0)
    80002a9e:	03353423          	sd	s3,40(a0)
    80002aa2:	03453823          	sd	s4,48(a0)
    80002aa6:	03553c23          	sd	s5,56(a0)
    80002aaa:	05653023          	sd	s6,64(a0)
    80002aae:	05753423          	sd	s7,72(a0)
    80002ab2:	05853823          	sd	s8,80(a0)
    80002ab6:	05953c23          	sd	s9,88(a0)
    80002aba:	07a53023          	sd	s10,96(a0)
    80002abe:	07b53423          	sd	s11,104(a0)
    80002ac2:	0005b083          	ld	ra,0(a1)
    80002ac6:	0085b103          	ld	sp,8(a1)
    80002aca:	6980                	ld	s0,16(a1)
    80002acc:	6d84                	ld	s1,24(a1)
    80002ace:	0205b903          	ld	s2,32(a1)
    80002ad2:	0285b983          	ld	s3,40(a1)
    80002ad6:	0305ba03          	ld	s4,48(a1)
    80002ada:	0385ba83          	ld	s5,56(a1)
    80002ade:	0405bb03          	ld	s6,64(a1)
    80002ae2:	0485bb83          	ld	s7,72(a1)
    80002ae6:	0505bc03          	ld	s8,80(a1)
    80002aea:	0585bc83          	ld	s9,88(a1)
    80002aee:	0605bd03          	ld	s10,96(a1)
    80002af2:	0685bd83          	ld	s11,104(a1)
    80002af6:	8082                	ret

0000000080002af8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002af8:	1141                	addi	sp,sp,-16
    80002afa:	e406                	sd	ra,8(sp)
    80002afc:	e022                	sd	s0,0(sp)
    80002afe:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002b00:	00006597          	auipc	a1,0x6
    80002b04:	8c858593          	addi	a1,a1,-1848 # 800083c8 <states.0+0x30>
    80002b08:	00014517          	auipc	a0,0x14
    80002b0c:	09850513          	addi	a0,a0,152 # 80016ba0 <tickslock>
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	032080e7          	jalr	50(ra) # 80000b42 <initlock>
}
    80002b18:	60a2                	ld	ra,8(sp)
    80002b1a:	6402                	ld	s0,0(sp)
    80002b1c:	0141                	addi	sp,sp,16
    80002b1e:	8082                	ret

0000000080002b20 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002b20:	1141                	addi	sp,sp,-16
    80002b22:	e422                	sd	s0,8(sp)
    80002b24:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b26:	00003797          	auipc	a5,0x3
    80002b2a:	4fa78793          	addi	a5,a5,1274 # 80006020 <kernelvec>
    80002b2e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002b32:	6422                	ld	s0,8(sp)
    80002b34:	0141                	addi	sp,sp,16
    80002b36:	8082                	ret

0000000080002b38 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002b38:	1141                	addi	sp,sp,-16
    80002b3a:	e406                	sd	ra,8(sp)
    80002b3c:	e022                	sd	s0,0(sp)
    80002b3e:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002b40:	fffff097          	auipc	ra,0xfffff
    80002b44:	11c080e7          	jalr	284(ra) # 80001c5c <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b48:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002b4c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002b4e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002b52:	00004697          	auipc	a3,0x4
    80002b56:	4ae68693          	addi	a3,a3,1198 # 80007000 <_trampoline>
    80002b5a:	00004717          	auipc	a4,0x4
    80002b5e:	4a670713          	addi	a4,a4,1190 # 80007000 <_trampoline>
    80002b62:	8f15                	sub	a4,a4,a3
    80002b64:	040007b7          	lui	a5,0x4000
    80002b68:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002b6a:	07b2                	slli	a5,a5,0xc
    80002b6c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002b6e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002b72:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002b74:	18002673          	csrr	a2,satp
    80002b78:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80002b7a:	6d30                	ld	a2,88(a0)
    80002b7c:	6138                	ld	a4,64(a0)
    80002b7e:	6585                	lui	a1,0x1
    80002b80:	972e                	add	a4,a4,a1
    80002b82:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002b84:	6d38                	ld	a4,88(a0)
    80002b86:	00000617          	auipc	a2,0x0
    80002b8a:	13460613          	addi	a2,a2,308 # 80002cba <usertrap>
    80002b8e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002b90:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002b92:	8612                	mv	a2,tp
    80002b94:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002b96:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002b9a:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002b9e:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ba2:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002ba6:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ba8:	6f18                	ld	a4,24(a4)
    80002baa:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002bae:	6928                	ld	a0,80(a0)
    80002bb0:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002bb2:	00004717          	auipc	a4,0x4
    80002bb6:	4ea70713          	addi	a4,a4,1258 # 8000709c <userret>
    80002bba:	8f15                	sub	a4,a4,a3
    80002bbc:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002bbe:	577d                	li	a4,-1
    80002bc0:	177e                	slli	a4,a4,0x3f
    80002bc2:	8d59                	or	a0,a0,a4
    80002bc4:	9782                	jalr	a5
}
    80002bc6:	60a2                	ld	ra,8(sp)
    80002bc8:	6402                	ld	s0,0(sp)
    80002bca:	0141                	addi	sp,sp,16
    80002bcc:	8082                	ret

0000000080002bce <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002bce:	1101                	addi	sp,sp,-32
    80002bd0:	ec06                	sd	ra,24(sp)
    80002bd2:	e822                	sd	s0,16(sp)
    80002bd4:	e426                	sd	s1,8(sp)
    80002bd6:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002bd8:	00014497          	auipc	s1,0x14
    80002bdc:	fc848493          	addi	s1,s1,-56 # 80016ba0 <tickslock>
    80002be0:	8526                	mv	a0,s1
    80002be2:	ffffe097          	auipc	ra,0xffffe
    80002be6:	ff0080e7          	jalr	-16(ra) # 80000bd2 <acquire>
  ticks++;
    80002bea:	00006517          	auipc	a0,0x6
    80002bee:	e1e50513          	addi	a0,a0,-482 # 80008a08 <ticks>
    80002bf2:	411c                	lw	a5,0(a0)
    80002bf4:	2785                	addiw	a5,a5,1
    80002bf6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002bf8:	00000097          	auipc	ra,0x0
    80002bfc:	850080e7          	jalr	-1968(ra) # 80002448 <wakeup>
  release(&tickslock);
    80002c00:	8526                	mv	a0,s1
    80002c02:	ffffe097          	auipc	ra,0xffffe
    80002c06:	084080e7          	jalr	132(ra) # 80000c86 <release>
}
    80002c0a:	60e2                	ld	ra,24(sp)
    80002c0c:	6442                	ld	s0,16(sp)
    80002c0e:	64a2                	ld	s1,8(sp)
    80002c10:	6105                	addi	sp,sp,32
    80002c12:	8082                	ret

0000000080002c14 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002c14:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002c18:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002c1a:	0807df63          	bgez	a5,80002cb8 <devintr+0xa4>
{
    80002c1e:	1101                	addi	sp,sp,-32
    80002c20:	ec06                	sd	ra,24(sp)
    80002c22:	e822                	sd	s0,16(sp)
    80002c24:	e426                	sd	s1,8(sp)
    80002c26:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    80002c28:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002c2c:	46a5                	li	a3,9
    80002c2e:	00d70d63          	beq	a4,a3,80002c48 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002c32:	577d                	li	a4,-1
    80002c34:	177e                	slli	a4,a4,0x3f
    80002c36:	0705                	addi	a4,a4,1
    return 0;
    80002c38:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80002c3a:	04e78e63          	beq	a5,a4,80002c96 <devintr+0x82>
  }
}
    80002c3e:	60e2                	ld	ra,24(sp)
    80002c40:	6442                	ld	s0,16(sp)
    80002c42:	64a2                	ld	s1,8(sp)
    80002c44:	6105                	addi	sp,sp,32
    80002c46:	8082                	ret
    int irq = plic_claim();
    80002c48:	00003097          	auipc	ra,0x3
    80002c4c:	4e0080e7          	jalr	1248(ra) # 80006128 <plic_claim>
    80002c50:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002c52:	47a9                	li	a5,10
    80002c54:	02f50763          	beq	a0,a5,80002c82 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002c58:	4785                	li	a5,1
    80002c5a:	02f50963          	beq	a0,a5,80002c8c <devintr+0x78>
    return 1;
    80002c5e:	4505                	li	a0,1
    } else if(irq){
    80002c60:	dcf9                	beqz	s1,80002c3e <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002c62:	85a6                	mv	a1,s1
    80002c64:	00005517          	auipc	a0,0x5
    80002c68:	76c50513          	addi	a0,a0,1900 # 800083d0 <states.0+0x38>
    80002c6c:	ffffe097          	auipc	ra,0xffffe
    80002c70:	91a080e7          	jalr	-1766(ra) # 80000586 <printf>
      plic_complete(irq);
    80002c74:	8526                	mv	a0,s1
    80002c76:	00003097          	auipc	ra,0x3
    80002c7a:	4d6080e7          	jalr	1238(ra) # 8000614c <plic_complete>
    return 1;
    80002c7e:	4505                	li	a0,1
    80002c80:	bf7d                	j	80002c3e <devintr+0x2a>
      uartintr();
    80002c82:	ffffe097          	auipc	ra,0xffffe
    80002c86:	d12080e7          	jalr	-750(ra) # 80000994 <uartintr>
    if(irq)
    80002c8a:	b7ed                	j	80002c74 <devintr+0x60>
      virtio_disk_intr();
    80002c8c:	00004097          	auipc	ra,0x4
    80002c90:	986080e7          	jalr	-1658(ra) # 80006612 <virtio_disk_intr>
    if(irq)
    80002c94:	b7c5                	j	80002c74 <devintr+0x60>
    if(cpuid() == 0){
    80002c96:	fffff097          	auipc	ra,0xfffff
    80002c9a:	f9a080e7          	jalr	-102(ra) # 80001c30 <cpuid>
    80002c9e:	c901                	beqz	a0,80002cae <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002ca0:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002ca4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002ca6:	14479073          	csrw	sip,a5
    return 2;
    80002caa:	4509                	li	a0,2
    80002cac:	bf49                	j	80002c3e <devintr+0x2a>
      clockintr();
    80002cae:	00000097          	auipc	ra,0x0
    80002cb2:	f20080e7          	jalr	-224(ra) # 80002bce <clockintr>
    80002cb6:	b7ed                	j	80002ca0 <devintr+0x8c>
}
    80002cb8:	8082                	ret

0000000080002cba <usertrap>:
{
    80002cba:	1101                	addi	sp,sp,-32
    80002cbc:	ec06                	sd	ra,24(sp)
    80002cbe:	e822                	sd	s0,16(sp)
    80002cc0:	e426                	sd	s1,8(sp)
    80002cc2:	e04a                	sd	s2,0(sp)
    80002cc4:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002cc6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002cca:	1007f793          	andi	a5,a5,256
    80002cce:	e3b1                	bnez	a5,80002d12 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002cd0:	00003797          	auipc	a5,0x3
    80002cd4:	35078793          	addi	a5,a5,848 # 80006020 <kernelvec>
    80002cd8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002cdc:	fffff097          	auipc	ra,0xfffff
    80002ce0:	f80080e7          	jalr	-128(ra) # 80001c5c <myproc>
    80002ce4:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002ce6:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002ce8:	14102773          	csrr	a4,sepc
    80002cec:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002cee:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002cf2:	47a1                	li	a5,8
    80002cf4:	02f70763          	beq	a4,a5,80002d22 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    80002cf8:	00000097          	auipc	ra,0x0
    80002cfc:	f1c080e7          	jalr	-228(ra) # 80002c14 <devintr>
    80002d00:	892a                	mv	s2,a0
    80002d02:	c151                	beqz	a0,80002d86 <usertrap+0xcc>
  if(killed(p))
    80002d04:	8526                	mv	a0,s1
    80002d06:	00000097          	auipc	ra,0x0
    80002d0a:	986080e7          	jalr	-1658(ra) # 8000268c <killed>
    80002d0e:	c929                	beqz	a0,80002d60 <usertrap+0xa6>
    80002d10:	a099                	j	80002d56 <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002d12:	00005517          	auipc	a0,0x5
    80002d16:	6de50513          	addi	a0,a0,1758 # 800083f0 <states.0+0x58>
    80002d1a:	ffffe097          	auipc	ra,0xffffe
    80002d1e:	822080e7          	jalr	-2014(ra) # 8000053c <panic>
    if(killed(p))
    80002d22:	00000097          	auipc	ra,0x0
    80002d26:	96a080e7          	jalr	-1686(ra) # 8000268c <killed>
    80002d2a:	e921                	bnez	a0,80002d7a <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002d2c:	6cb8                	ld	a4,88(s1)
    80002d2e:	6f1c                	ld	a5,24(a4)
    80002d30:	0791                	addi	a5,a5,4
    80002d32:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002d34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002d38:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002d3c:	10079073          	csrw	sstatus,a5
    syscall();
    80002d40:	00000097          	auipc	ra,0x0
    80002d44:	2d4080e7          	jalr	724(ra) # 80003014 <syscall>
  if(killed(p))
    80002d48:	8526                	mv	a0,s1
    80002d4a:	00000097          	auipc	ra,0x0
    80002d4e:	942080e7          	jalr	-1726(ra) # 8000268c <killed>
    80002d52:	c911                	beqz	a0,80002d66 <usertrap+0xac>
    80002d54:	4901                	li	s2,0
    exit(-1);
    80002d56:	557d                	li	a0,-1
    80002d58:	fffff097          	auipc	ra,0xfffff
    80002d5c:	7c0080e7          	jalr	1984(ra) # 80002518 <exit>
  if(which_dev == 2)
    80002d60:	4789                	li	a5,2
    80002d62:	04f90f63          	beq	s2,a5,80002dc0 <usertrap+0x106>
  usertrapret();
    80002d66:	00000097          	auipc	ra,0x0
    80002d6a:	dd2080e7          	jalr	-558(ra) # 80002b38 <usertrapret>
}
    80002d6e:	60e2                	ld	ra,24(sp)
    80002d70:	6442                	ld	s0,16(sp)
    80002d72:	64a2                	ld	s1,8(sp)
    80002d74:	6902                	ld	s2,0(sp)
    80002d76:	6105                	addi	sp,sp,32
    80002d78:	8082                	ret
      exit(-1);
    80002d7a:	557d                	li	a0,-1
    80002d7c:	fffff097          	auipc	ra,0xfffff
    80002d80:	79c080e7          	jalr	1948(ra) # 80002518 <exit>
    80002d84:	b765                	j	80002d2c <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002d86:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002d8a:	5890                	lw	a2,48(s1)
    80002d8c:	00005517          	auipc	a0,0x5
    80002d90:	68450513          	addi	a0,a0,1668 # 80008410 <states.0+0x78>
    80002d94:	ffffd097          	auipc	ra,0xffffd
    80002d98:	7f2080e7          	jalr	2034(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002d9c:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002da0:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002da4:	00005517          	auipc	a0,0x5
    80002da8:	69c50513          	addi	a0,a0,1692 # 80008440 <states.0+0xa8>
    80002dac:	ffffd097          	auipc	ra,0xffffd
    80002db0:	7da080e7          	jalr	2010(ra) # 80000586 <printf>
    setkilled(p);
    80002db4:	8526                	mv	a0,s1
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	8aa080e7          	jalr	-1878(ra) # 80002660 <setkilled>
    80002dbe:	b769                	j	80002d48 <usertrap+0x8e>
    yield();
    80002dc0:	fffff097          	auipc	ra,0xfffff
    80002dc4:	5e8080e7          	jalr	1512(ra) # 800023a8 <yield>
    80002dc8:	bf79                	j	80002d66 <usertrap+0xac>

0000000080002dca <kerneltrap>:
{
    80002dca:	7179                	addi	sp,sp,-48
    80002dcc:	f406                	sd	ra,40(sp)
    80002dce:	f022                	sd	s0,32(sp)
    80002dd0:	ec26                	sd	s1,24(sp)
    80002dd2:	e84a                	sd	s2,16(sp)
    80002dd4:	e44e                	sd	s3,8(sp)
    80002dd6:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002dd8:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ddc:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002de0:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002de4:	1004f793          	andi	a5,s1,256
    80002de8:	cb85                	beqz	a5,80002e18 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002dea:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002dee:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002df0:	ef85                	bnez	a5,80002e28 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002df2:	00000097          	auipc	ra,0x0
    80002df6:	e22080e7          	jalr	-478(ra) # 80002c14 <devintr>
    80002dfa:	cd1d                	beqz	a0,80002e38 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002dfc:	4789                	li	a5,2
    80002dfe:	06f50a63          	beq	a0,a5,80002e72 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002e02:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002e06:	10049073          	csrw	sstatus,s1
}
    80002e0a:	70a2                	ld	ra,40(sp)
    80002e0c:	7402                	ld	s0,32(sp)
    80002e0e:	64e2                	ld	s1,24(sp)
    80002e10:	6942                	ld	s2,16(sp)
    80002e12:	69a2                	ld	s3,8(sp)
    80002e14:	6145                	addi	sp,sp,48
    80002e16:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002e18:	00005517          	auipc	a0,0x5
    80002e1c:	64850513          	addi	a0,a0,1608 # 80008460 <states.0+0xc8>
    80002e20:	ffffd097          	auipc	ra,0xffffd
    80002e24:	71c080e7          	jalr	1820(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002e28:	00005517          	auipc	a0,0x5
    80002e2c:	66050513          	addi	a0,a0,1632 # 80008488 <states.0+0xf0>
    80002e30:	ffffd097          	auipc	ra,0xffffd
    80002e34:	70c080e7          	jalr	1804(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002e38:	85ce                	mv	a1,s3
    80002e3a:	00005517          	auipc	a0,0x5
    80002e3e:	66e50513          	addi	a0,a0,1646 # 800084a8 <states.0+0x110>
    80002e42:	ffffd097          	auipc	ra,0xffffd
    80002e46:	744080e7          	jalr	1860(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002e4a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002e4e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002e52:	00005517          	auipc	a0,0x5
    80002e56:	66650513          	addi	a0,a0,1638 # 800084b8 <states.0+0x120>
    80002e5a:	ffffd097          	auipc	ra,0xffffd
    80002e5e:	72c080e7          	jalr	1836(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002e62:	00005517          	auipc	a0,0x5
    80002e66:	66e50513          	addi	a0,a0,1646 # 800084d0 <states.0+0x138>
    80002e6a:	ffffd097          	auipc	ra,0xffffd
    80002e6e:	6d2080e7          	jalr	1746(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002e72:	fffff097          	auipc	ra,0xfffff
    80002e76:	dea080e7          	jalr	-534(ra) # 80001c5c <myproc>
    80002e7a:	d541                	beqz	a0,80002e02 <kerneltrap+0x38>
    80002e7c:	fffff097          	auipc	ra,0xfffff
    80002e80:	de0080e7          	jalr	-544(ra) # 80001c5c <myproc>
    80002e84:	4d18                	lw	a4,24(a0)
    80002e86:	4791                	li	a5,4
    80002e88:	f6f71de3          	bne	a4,a5,80002e02 <kerneltrap+0x38>
    yield();
    80002e8c:	fffff097          	auipc	ra,0xfffff
    80002e90:	51c080e7          	jalr	1308(ra) # 800023a8 <yield>
    80002e94:	b7bd                	j	80002e02 <kerneltrap+0x38>

0000000080002e96 <argraw>:
    return strlen(buf);
}

static uint64
argraw(int n)
{
    80002e96:	1101                	addi	sp,sp,-32
    80002e98:	ec06                	sd	ra,24(sp)
    80002e9a:	e822                	sd	s0,16(sp)
    80002e9c:	e426                	sd	s1,8(sp)
    80002e9e:	1000                	addi	s0,sp,32
    80002ea0:	84aa                	mv	s1,a0
    struct proc *p = myproc();
    80002ea2:	fffff097          	auipc	ra,0xfffff
    80002ea6:	dba080e7          	jalr	-582(ra) # 80001c5c <myproc>
    switch (n)
    80002eaa:	4795                	li	a5,5
    80002eac:	0497e163          	bltu	a5,s1,80002eee <argraw+0x58>
    80002eb0:	048a                	slli	s1,s1,0x2
    80002eb2:	00005717          	auipc	a4,0x5
    80002eb6:	65670713          	addi	a4,a4,1622 # 80008508 <states.0+0x170>
    80002eba:	94ba                	add	s1,s1,a4
    80002ebc:	409c                	lw	a5,0(s1)
    80002ebe:	97ba                	add	a5,a5,a4
    80002ec0:	8782                	jr	a5
    {
    case 0:
        return p->trapframe->a0;
    80002ec2:	6d3c                	ld	a5,88(a0)
    80002ec4:	7ba8                	ld	a0,112(a5)
    case 5:
        return p->trapframe->a5;
    }
    panic("argraw");
    return -1;
}
    80002ec6:	60e2                	ld	ra,24(sp)
    80002ec8:	6442                	ld	s0,16(sp)
    80002eca:	64a2                	ld	s1,8(sp)
    80002ecc:	6105                	addi	sp,sp,32
    80002ece:	8082                	ret
        return p->trapframe->a1;
    80002ed0:	6d3c                	ld	a5,88(a0)
    80002ed2:	7fa8                	ld	a0,120(a5)
    80002ed4:	bfcd                	j	80002ec6 <argraw+0x30>
        return p->trapframe->a2;
    80002ed6:	6d3c                	ld	a5,88(a0)
    80002ed8:	63c8                	ld	a0,128(a5)
    80002eda:	b7f5                	j	80002ec6 <argraw+0x30>
        return p->trapframe->a3;
    80002edc:	6d3c                	ld	a5,88(a0)
    80002ede:	67c8                	ld	a0,136(a5)
    80002ee0:	b7dd                	j	80002ec6 <argraw+0x30>
        return p->trapframe->a4;
    80002ee2:	6d3c                	ld	a5,88(a0)
    80002ee4:	6bc8                	ld	a0,144(a5)
    80002ee6:	b7c5                	j	80002ec6 <argraw+0x30>
        return p->trapframe->a5;
    80002ee8:	6d3c                	ld	a5,88(a0)
    80002eea:	6fc8                	ld	a0,152(a5)
    80002eec:	bfe9                	j	80002ec6 <argraw+0x30>
    panic("argraw");
    80002eee:	00005517          	auipc	a0,0x5
    80002ef2:	5f250513          	addi	a0,a0,1522 # 800084e0 <states.0+0x148>
    80002ef6:	ffffd097          	auipc	ra,0xffffd
    80002efa:	646080e7          	jalr	1606(ra) # 8000053c <panic>

0000000080002efe <fetchaddr>:
{
    80002efe:	1101                	addi	sp,sp,-32
    80002f00:	ec06                	sd	ra,24(sp)
    80002f02:	e822                	sd	s0,16(sp)
    80002f04:	e426                	sd	s1,8(sp)
    80002f06:	e04a                	sd	s2,0(sp)
    80002f08:	1000                	addi	s0,sp,32
    80002f0a:	84aa                	mv	s1,a0
    80002f0c:	892e                	mv	s2,a1
    struct proc *p = myproc();
    80002f0e:	fffff097          	auipc	ra,0xfffff
    80002f12:	d4e080e7          	jalr	-690(ra) # 80001c5c <myproc>
    if (addr >= p->sz || addr + sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002f16:	653c                	ld	a5,72(a0)
    80002f18:	02f4f863          	bgeu	s1,a5,80002f48 <fetchaddr+0x4a>
    80002f1c:	00848713          	addi	a4,s1,8
    80002f20:	02e7e663          	bltu	a5,a4,80002f4c <fetchaddr+0x4e>
    if (copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002f24:	46a1                	li	a3,8
    80002f26:	8626                	mv	a2,s1
    80002f28:	85ca                	mv	a1,s2
    80002f2a:	6928                	ld	a0,80(a0)
    80002f2c:	ffffe097          	auipc	ra,0xffffe
    80002f30:	7c6080e7          	jalr	1990(ra) # 800016f2 <copyin>
    80002f34:	00a03533          	snez	a0,a0
    80002f38:	40a00533          	neg	a0,a0
}
    80002f3c:	60e2                	ld	ra,24(sp)
    80002f3e:	6442                	ld	s0,16(sp)
    80002f40:	64a2                	ld	s1,8(sp)
    80002f42:	6902                	ld	s2,0(sp)
    80002f44:	6105                	addi	sp,sp,32
    80002f46:	8082                	ret
        return -1;
    80002f48:	557d                	li	a0,-1
    80002f4a:	bfcd                	j	80002f3c <fetchaddr+0x3e>
    80002f4c:	557d                	li	a0,-1
    80002f4e:	b7fd                	j	80002f3c <fetchaddr+0x3e>

0000000080002f50 <fetchstr>:
{
    80002f50:	7179                	addi	sp,sp,-48
    80002f52:	f406                	sd	ra,40(sp)
    80002f54:	f022                	sd	s0,32(sp)
    80002f56:	ec26                	sd	s1,24(sp)
    80002f58:	e84a                	sd	s2,16(sp)
    80002f5a:	e44e                	sd	s3,8(sp)
    80002f5c:	1800                	addi	s0,sp,48
    80002f5e:	892a                	mv	s2,a0
    80002f60:	84ae                	mv	s1,a1
    80002f62:	89b2                	mv	s3,a2
    struct proc *p = myproc();
    80002f64:	fffff097          	auipc	ra,0xfffff
    80002f68:	cf8080e7          	jalr	-776(ra) # 80001c5c <myproc>
    if (copyinstr(p->pagetable, buf, addr, max) < 0)
    80002f6c:	86ce                	mv	a3,s3
    80002f6e:	864a                	mv	a2,s2
    80002f70:	85a6                	mv	a1,s1
    80002f72:	6928                	ld	a0,80(a0)
    80002f74:	fffff097          	auipc	ra,0xfffff
    80002f78:	80c080e7          	jalr	-2036(ra) # 80001780 <copyinstr>
    80002f7c:	00054e63          	bltz	a0,80002f98 <fetchstr+0x48>
    return strlen(buf);
    80002f80:	8526                	mv	a0,s1
    80002f82:	ffffe097          	auipc	ra,0xffffe
    80002f86:	ec6080e7          	jalr	-314(ra) # 80000e48 <strlen>
}
    80002f8a:	70a2                	ld	ra,40(sp)
    80002f8c:	7402                	ld	s0,32(sp)
    80002f8e:	64e2                	ld	s1,24(sp)
    80002f90:	6942                	ld	s2,16(sp)
    80002f92:	69a2                	ld	s3,8(sp)
    80002f94:	6145                	addi	sp,sp,48
    80002f96:	8082                	ret
        return -1;
    80002f98:	557d                	li	a0,-1
    80002f9a:	bfc5                	j	80002f8a <fetchstr+0x3a>

0000000080002f9c <argint>:

// Fetch the nth 32-bit system call argument.
void argint(int n, int *ip)
{
    80002f9c:	1101                	addi	sp,sp,-32
    80002f9e:	ec06                	sd	ra,24(sp)
    80002fa0:	e822                	sd	s0,16(sp)
    80002fa2:	e426                	sd	s1,8(sp)
    80002fa4:	1000                	addi	s0,sp,32
    80002fa6:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002fa8:	00000097          	auipc	ra,0x0
    80002fac:	eee080e7          	jalr	-274(ra) # 80002e96 <argraw>
    80002fb0:	c088                	sw	a0,0(s1)
}
    80002fb2:	60e2                	ld	ra,24(sp)
    80002fb4:	6442                	ld	s0,16(sp)
    80002fb6:	64a2                	ld	s1,8(sp)
    80002fb8:	6105                	addi	sp,sp,32
    80002fba:	8082                	ret

0000000080002fbc <argaddr>:

// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void argaddr(int n, uint64 *ip)
{
    80002fbc:	1101                	addi	sp,sp,-32
    80002fbe:	ec06                	sd	ra,24(sp)
    80002fc0:	e822                	sd	s0,16(sp)
    80002fc2:	e426                	sd	s1,8(sp)
    80002fc4:	1000                	addi	s0,sp,32
    80002fc6:	84ae                	mv	s1,a1
    *ip = argraw(n);
    80002fc8:	00000097          	auipc	ra,0x0
    80002fcc:	ece080e7          	jalr	-306(ra) # 80002e96 <argraw>
    80002fd0:	e088                	sd	a0,0(s1)
}
    80002fd2:	60e2                	ld	ra,24(sp)
    80002fd4:	6442                	ld	s0,16(sp)
    80002fd6:	64a2                	ld	s1,8(sp)
    80002fd8:	6105                	addi	sp,sp,32
    80002fda:	8082                	ret

0000000080002fdc <argstr>:

// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int argstr(int n, char *buf, int max)
{
    80002fdc:	7179                	addi	sp,sp,-48
    80002fde:	f406                	sd	ra,40(sp)
    80002fe0:	f022                	sd	s0,32(sp)
    80002fe2:	ec26                	sd	s1,24(sp)
    80002fe4:	e84a                	sd	s2,16(sp)
    80002fe6:	1800                	addi	s0,sp,48
    80002fe8:	84ae                	mv	s1,a1
    80002fea:	8932                	mv	s2,a2
    uint64 addr;
    argaddr(n, &addr);
    80002fec:	fd840593          	addi	a1,s0,-40
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	fcc080e7          	jalr	-52(ra) # 80002fbc <argaddr>
    return fetchstr(addr, buf, max);
    80002ff8:	864a                	mv	a2,s2
    80002ffa:	85a6                	mv	a1,s1
    80002ffc:	fd843503          	ld	a0,-40(s0)
    80003000:	00000097          	auipc	ra,0x0
    80003004:	f50080e7          	jalr	-176(ra) # 80002f50 <fetchstr>
}
    80003008:	70a2                	ld	ra,40(sp)
    8000300a:	7402                	ld	s0,32(sp)
    8000300c:	64e2                	ld	s1,24(sp)
    8000300e:	6942                	ld	s2,16(sp)
    80003010:	6145                	addi	sp,sp,48
    80003012:	8082                	ret

0000000080003014 <syscall>:
    [SYS_schedls] sys_schedls,
    [SYS_schedset] sys_schedset,
};

void syscall(void)
{
    80003014:	1101                	addi	sp,sp,-32
    80003016:	ec06                	sd	ra,24(sp)
    80003018:	e822                	sd	s0,16(sp)
    8000301a:	e426                	sd	s1,8(sp)
    8000301c:	e04a                	sd	s2,0(sp)
    8000301e:	1000                	addi	s0,sp,32
    int num;
    struct proc *p = myproc();
    80003020:	fffff097          	auipc	ra,0xfffff
    80003024:	c3c080e7          	jalr	-964(ra) # 80001c5c <myproc>
    80003028:	84aa                	mv	s1,a0

    num = p->trapframe->a7;
    8000302a:	05853903          	ld	s2,88(a0)
    8000302e:	0a893783          	ld	a5,168(s2)
    80003032:	0007869b          	sext.w	a3,a5
    if (num > 0 && num < NELEM(syscalls) && syscalls[num])
    80003036:	37fd                	addiw	a5,a5,-1
    80003038:	475d                	li	a4,23
    8000303a:	00f76f63          	bltu	a4,a5,80003058 <syscall+0x44>
    8000303e:	00369713          	slli	a4,a3,0x3
    80003042:	00005797          	auipc	a5,0x5
    80003046:	4de78793          	addi	a5,a5,1246 # 80008520 <syscalls>
    8000304a:	97ba                	add	a5,a5,a4
    8000304c:	639c                	ld	a5,0(a5)
    8000304e:	c789                	beqz	a5,80003058 <syscall+0x44>
    {
        // Use num to lookup the system call function for num, call it,
        // and store its return value in p->trapframe->a0
        p->trapframe->a0 = syscalls[num]();
    80003050:	9782                	jalr	a5
    80003052:	06a93823          	sd	a0,112(s2)
    80003056:	a839                	j	80003074 <syscall+0x60>
    }
    else
    {
        printf("%d %s: unknown sys call %d\n",
    80003058:	15848613          	addi	a2,s1,344
    8000305c:	588c                	lw	a1,48(s1)
    8000305e:	00005517          	auipc	a0,0x5
    80003062:	48a50513          	addi	a0,a0,1162 # 800084e8 <states.0+0x150>
    80003066:	ffffd097          	auipc	ra,0xffffd
    8000306a:	520080e7          	jalr	1312(ra) # 80000586 <printf>
               p->pid, p->name, num);
        p->trapframe->a0 = -1;
    8000306e:	6cbc                	ld	a5,88(s1)
    80003070:	577d                	li	a4,-1
    80003072:	fbb8                	sd	a4,112(a5)
    }
}
    80003074:	60e2                	ld	ra,24(sp)
    80003076:	6442                	ld	s0,16(sp)
    80003078:	64a2                	ld	s1,8(sp)
    8000307a:	6902                	ld	s2,0(sp)
    8000307c:	6105                	addi	sp,sp,32
    8000307e:	8082                	ret

0000000080003080 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80003080:	1101                	addi	sp,sp,-32
    80003082:	ec06                	sd	ra,24(sp)
    80003084:	e822                	sd	s0,16(sp)
    80003086:	1000                	addi	s0,sp,32
    int n;
    argint(0, &n);
    80003088:	fec40593          	addi	a1,s0,-20
    8000308c:	4501                	li	a0,0
    8000308e:	00000097          	auipc	ra,0x0
    80003092:	f0e080e7          	jalr	-242(ra) # 80002f9c <argint>
    exit(n);
    80003096:	fec42503          	lw	a0,-20(s0)
    8000309a:	fffff097          	auipc	ra,0xfffff
    8000309e:	47e080e7          	jalr	1150(ra) # 80002518 <exit>
    return 0; // not reached
}
    800030a2:	4501                	li	a0,0
    800030a4:	60e2                	ld	ra,24(sp)
    800030a6:	6442                	ld	s0,16(sp)
    800030a8:	6105                	addi	sp,sp,32
    800030aa:	8082                	ret

00000000800030ac <sys_getpid>:

uint64
sys_getpid(void)
{
    800030ac:	1141                	addi	sp,sp,-16
    800030ae:	e406                	sd	ra,8(sp)
    800030b0:	e022                	sd	s0,0(sp)
    800030b2:	0800                	addi	s0,sp,16
    return myproc()->pid;
    800030b4:	fffff097          	auipc	ra,0xfffff
    800030b8:	ba8080e7          	jalr	-1112(ra) # 80001c5c <myproc>
}
    800030bc:	5908                	lw	a0,48(a0)
    800030be:	60a2                	ld	ra,8(sp)
    800030c0:	6402                	ld	s0,0(sp)
    800030c2:	0141                	addi	sp,sp,16
    800030c4:	8082                	ret

00000000800030c6 <sys_fork>:

uint64
sys_fork(void)
{
    800030c6:	1141                	addi	sp,sp,-16
    800030c8:	e406                	sd	ra,8(sp)
    800030ca:	e022                	sd	s0,0(sp)
    800030cc:	0800                	addi	s0,sp,16
    return fork();
    800030ce:	fffff097          	auipc	ra,0xfffff
    800030d2:	094080e7          	jalr	148(ra) # 80002162 <fork>
}
    800030d6:	60a2                	ld	ra,8(sp)
    800030d8:	6402                	ld	s0,0(sp)
    800030da:	0141                	addi	sp,sp,16
    800030dc:	8082                	ret

00000000800030de <sys_wait>:

uint64
sys_wait(void)
{
    800030de:	1101                	addi	sp,sp,-32
    800030e0:	ec06                	sd	ra,24(sp)
    800030e2:	e822                	sd	s0,16(sp)
    800030e4:	1000                	addi	s0,sp,32
    uint64 p;
    argaddr(0, &p);
    800030e6:	fe840593          	addi	a1,s0,-24
    800030ea:	4501                	li	a0,0
    800030ec:	00000097          	auipc	ra,0x0
    800030f0:	ed0080e7          	jalr	-304(ra) # 80002fbc <argaddr>
    return wait(p);
    800030f4:	fe843503          	ld	a0,-24(s0)
    800030f8:	fffff097          	auipc	ra,0xfffff
    800030fc:	5c6080e7          	jalr	1478(ra) # 800026be <wait>
}
    80003100:	60e2                	ld	ra,24(sp)
    80003102:	6442                	ld	s0,16(sp)
    80003104:	6105                	addi	sp,sp,32
    80003106:	8082                	ret

0000000080003108 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80003108:	7179                	addi	sp,sp,-48
    8000310a:	f406                	sd	ra,40(sp)
    8000310c:	f022                	sd	s0,32(sp)
    8000310e:	ec26                	sd	s1,24(sp)
    80003110:	1800                	addi	s0,sp,48
    uint64 addr;
    int n;

    argint(0, &n);
    80003112:	fdc40593          	addi	a1,s0,-36
    80003116:	4501                	li	a0,0
    80003118:	00000097          	auipc	ra,0x0
    8000311c:	e84080e7          	jalr	-380(ra) # 80002f9c <argint>
    addr = myproc()->sz;
    80003120:	fffff097          	auipc	ra,0xfffff
    80003124:	b3c080e7          	jalr	-1220(ra) # 80001c5c <myproc>
    80003128:	6524                	ld	s1,72(a0)
    if (growproc(n) < 0)
    8000312a:	fdc42503          	lw	a0,-36(s0)
    8000312e:	fffff097          	auipc	ra,0xfffff
    80003132:	e88080e7          	jalr	-376(ra) # 80001fb6 <growproc>
    80003136:	00054863          	bltz	a0,80003146 <sys_sbrk+0x3e>
        return -1;
    return addr;
}
    8000313a:	8526                	mv	a0,s1
    8000313c:	70a2                	ld	ra,40(sp)
    8000313e:	7402                	ld	s0,32(sp)
    80003140:	64e2                	ld	s1,24(sp)
    80003142:	6145                	addi	sp,sp,48
    80003144:	8082                	ret
        return -1;
    80003146:	54fd                	li	s1,-1
    80003148:	bfcd                	j	8000313a <sys_sbrk+0x32>

000000008000314a <sys_sleep>:

uint64
sys_sleep(void)
{
    8000314a:	7139                	addi	sp,sp,-64
    8000314c:	fc06                	sd	ra,56(sp)
    8000314e:	f822                	sd	s0,48(sp)
    80003150:	f426                	sd	s1,40(sp)
    80003152:	f04a                	sd	s2,32(sp)
    80003154:	ec4e                	sd	s3,24(sp)
    80003156:	0080                	addi	s0,sp,64
    int n;
    uint ticks0;

    argint(0, &n);
    80003158:	fcc40593          	addi	a1,s0,-52
    8000315c:	4501                	li	a0,0
    8000315e:	00000097          	auipc	ra,0x0
    80003162:	e3e080e7          	jalr	-450(ra) # 80002f9c <argint>
    acquire(&tickslock);
    80003166:	00014517          	auipc	a0,0x14
    8000316a:	a3a50513          	addi	a0,a0,-1478 # 80016ba0 <tickslock>
    8000316e:	ffffe097          	auipc	ra,0xffffe
    80003172:	a64080e7          	jalr	-1436(ra) # 80000bd2 <acquire>
    ticks0 = ticks;
    80003176:	00006917          	auipc	s2,0x6
    8000317a:	89292903          	lw	s2,-1902(s2) # 80008a08 <ticks>
    while (ticks - ticks0 < n)
    8000317e:	fcc42783          	lw	a5,-52(s0)
    80003182:	cf9d                	beqz	a5,800031c0 <sys_sleep+0x76>
        if (killed(myproc()))
        {
            release(&tickslock);
            return -1;
        }
        sleep(&ticks, &tickslock);
    80003184:	00014997          	auipc	s3,0x14
    80003188:	a1c98993          	addi	s3,s3,-1508 # 80016ba0 <tickslock>
    8000318c:	00006497          	auipc	s1,0x6
    80003190:	87c48493          	addi	s1,s1,-1924 # 80008a08 <ticks>
        if (killed(myproc()))
    80003194:	fffff097          	auipc	ra,0xfffff
    80003198:	ac8080e7          	jalr	-1336(ra) # 80001c5c <myproc>
    8000319c:	fffff097          	auipc	ra,0xfffff
    800031a0:	4f0080e7          	jalr	1264(ra) # 8000268c <killed>
    800031a4:	ed15                	bnez	a0,800031e0 <sys_sleep+0x96>
        sleep(&ticks, &tickslock);
    800031a6:	85ce                	mv	a1,s3
    800031a8:	8526                	mv	a0,s1
    800031aa:	fffff097          	auipc	ra,0xfffff
    800031ae:	23a080e7          	jalr	570(ra) # 800023e4 <sleep>
    while (ticks - ticks0 < n)
    800031b2:	409c                	lw	a5,0(s1)
    800031b4:	412787bb          	subw	a5,a5,s2
    800031b8:	fcc42703          	lw	a4,-52(s0)
    800031bc:	fce7ece3          	bltu	a5,a4,80003194 <sys_sleep+0x4a>
    }
    release(&tickslock);
    800031c0:	00014517          	auipc	a0,0x14
    800031c4:	9e050513          	addi	a0,a0,-1568 # 80016ba0 <tickslock>
    800031c8:	ffffe097          	auipc	ra,0xffffe
    800031cc:	abe080e7          	jalr	-1346(ra) # 80000c86 <release>
    return 0;
    800031d0:	4501                	li	a0,0
}
    800031d2:	70e2                	ld	ra,56(sp)
    800031d4:	7442                	ld	s0,48(sp)
    800031d6:	74a2                	ld	s1,40(sp)
    800031d8:	7902                	ld	s2,32(sp)
    800031da:	69e2                	ld	s3,24(sp)
    800031dc:	6121                	addi	sp,sp,64
    800031de:	8082                	ret
            release(&tickslock);
    800031e0:	00014517          	auipc	a0,0x14
    800031e4:	9c050513          	addi	a0,a0,-1600 # 80016ba0 <tickslock>
    800031e8:	ffffe097          	auipc	ra,0xffffe
    800031ec:	a9e080e7          	jalr	-1378(ra) # 80000c86 <release>
            return -1;
    800031f0:	557d                	li	a0,-1
    800031f2:	b7c5                	j	800031d2 <sys_sleep+0x88>

00000000800031f4 <sys_kill>:

uint64
sys_kill(void)
{
    800031f4:	1101                	addi	sp,sp,-32
    800031f6:	ec06                	sd	ra,24(sp)
    800031f8:	e822                	sd	s0,16(sp)
    800031fa:	1000                	addi	s0,sp,32
    int pid;

    argint(0, &pid);
    800031fc:	fec40593          	addi	a1,s0,-20
    80003200:	4501                	li	a0,0
    80003202:	00000097          	auipc	ra,0x0
    80003206:	d9a080e7          	jalr	-614(ra) # 80002f9c <argint>
    return kill(pid);
    8000320a:	fec42503          	lw	a0,-20(s0)
    8000320e:	fffff097          	auipc	ra,0xfffff
    80003212:	3e0080e7          	jalr	992(ra) # 800025ee <kill>
}
    80003216:	60e2                	ld	ra,24(sp)
    80003218:	6442                	ld	s0,16(sp)
    8000321a:	6105                	addi	sp,sp,32
    8000321c:	8082                	ret

000000008000321e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    8000321e:	1101                	addi	sp,sp,-32
    80003220:	ec06                	sd	ra,24(sp)
    80003222:	e822                	sd	s0,16(sp)
    80003224:	e426                	sd	s1,8(sp)
    80003226:	1000                	addi	s0,sp,32
    uint xticks;

    acquire(&tickslock);
    80003228:	00014517          	auipc	a0,0x14
    8000322c:	97850513          	addi	a0,a0,-1672 # 80016ba0 <tickslock>
    80003230:	ffffe097          	auipc	ra,0xffffe
    80003234:	9a2080e7          	jalr	-1630(ra) # 80000bd2 <acquire>
    xticks = ticks;
    80003238:	00005497          	auipc	s1,0x5
    8000323c:	7d04a483          	lw	s1,2000(s1) # 80008a08 <ticks>
    release(&tickslock);
    80003240:	00014517          	auipc	a0,0x14
    80003244:	96050513          	addi	a0,a0,-1696 # 80016ba0 <tickslock>
    80003248:	ffffe097          	auipc	ra,0xffffe
    8000324c:	a3e080e7          	jalr	-1474(ra) # 80000c86 <release>
    return xticks;
}
    80003250:	02049513          	slli	a0,s1,0x20
    80003254:	9101                	srli	a0,a0,0x20
    80003256:	60e2                	ld	ra,24(sp)
    80003258:	6442                	ld	s0,16(sp)
    8000325a:	64a2                	ld	s1,8(sp)
    8000325c:	6105                	addi	sp,sp,32
    8000325e:	8082                	ret

0000000080003260 <sys_ps>:

void *
sys_ps(void)
{
    80003260:	1101                	addi	sp,sp,-32
    80003262:	ec06                	sd	ra,24(sp)
    80003264:	e822                	sd	s0,16(sp)
    80003266:	1000                	addi	s0,sp,32
    int start = 0, count = 0;
    80003268:	fe042623          	sw	zero,-20(s0)
    8000326c:	fe042423          	sw	zero,-24(s0)
    argint(0, &start);
    80003270:	fec40593          	addi	a1,s0,-20
    80003274:	4501                	li	a0,0
    80003276:	00000097          	auipc	ra,0x0
    8000327a:	d26080e7          	jalr	-730(ra) # 80002f9c <argint>
    argint(1, &count);
    8000327e:	fe840593          	addi	a1,s0,-24
    80003282:	4505                	li	a0,1
    80003284:	00000097          	auipc	ra,0x0
    80003288:	d18080e7          	jalr	-744(ra) # 80002f9c <argint>
    return ps((uint8)start, (uint8)count);
    8000328c:	fe844583          	lbu	a1,-24(s0)
    80003290:	fec44503          	lbu	a0,-20(s0)
    80003294:	fffff097          	auipc	ra,0xfffff
    80003298:	d7e080e7          	jalr	-642(ra) # 80002012 <ps>
}
    8000329c:	60e2                	ld	ra,24(sp)
    8000329e:	6442                	ld	s0,16(sp)
    800032a0:	6105                	addi	sp,sp,32
    800032a2:	8082                	ret

00000000800032a4 <sys_schedls>:

uint64 sys_schedls(void)
{
    800032a4:	1141                	addi	sp,sp,-16
    800032a6:	e406                	sd	ra,8(sp)
    800032a8:	e022                	sd	s0,0(sp)
    800032aa:	0800                	addi	s0,sp,16
    schedls();
    800032ac:	fffff097          	auipc	ra,0xfffff
    800032b0:	69c080e7          	jalr	1692(ra) # 80002948 <schedls>
    return 0;
}
    800032b4:	4501                	li	a0,0
    800032b6:	60a2                	ld	ra,8(sp)
    800032b8:	6402                	ld	s0,0(sp)
    800032ba:	0141                	addi	sp,sp,16
    800032bc:	8082                	ret

00000000800032be <sys_schedset>:

uint64 sys_schedset(void)
{
    800032be:	1101                	addi	sp,sp,-32
    800032c0:	ec06                	sd	ra,24(sp)
    800032c2:	e822                	sd	s0,16(sp)
    800032c4:	1000                	addi	s0,sp,32
    int id = 0;
    800032c6:	fe042623          	sw	zero,-20(s0)
    argint(0, &id);
    800032ca:	fec40593          	addi	a1,s0,-20
    800032ce:	4501                	li	a0,0
    800032d0:	00000097          	auipc	ra,0x0
    800032d4:	ccc080e7          	jalr	-820(ra) # 80002f9c <argint>
    schedset(id - 1);
    800032d8:	fec42503          	lw	a0,-20(s0)
    800032dc:	357d                	addiw	a0,a0,-1
    800032de:	fffff097          	auipc	ra,0xfffff
    800032e2:	756080e7          	jalr	1878(ra) # 80002a34 <schedset>
    return 0;
    800032e6:	4501                	li	a0,0
    800032e8:	60e2                	ld	ra,24(sp)
    800032ea:	6442                	ld	s0,16(sp)
    800032ec:	6105                	addi	sp,sp,32
    800032ee:	8082                	ret

00000000800032f0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800032f0:	7179                	addi	sp,sp,-48
    800032f2:	f406                	sd	ra,40(sp)
    800032f4:	f022                	sd	s0,32(sp)
    800032f6:	ec26                	sd	s1,24(sp)
    800032f8:	e84a                	sd	s2,16(sp)
    800032fa:	e44e                	sd	s3,8(sp)
    800032fc:	e052                	sd	s4,0(sp)
    800032fe:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003300:	00005597          	auipc	a1,0x5
    80003304:	2e858593          	addi	a1,a1,744 # 800085e8 <syscalls+0xc8>
    80003308:	00014517          	auipc	a0,0x14
    8000330c:	8b050513          	addi	a0,a0,-1872 # 80016bb8 <bcache>
    80003310:	ffffe097          	auipc	ra,0xffffe
    80003314:	832080e7          	jalr	-1998(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80003318:	0001c797          	auipc	a5,0x1c
    8000331c:	8a078793          	addi	a5,a5,-1888 # 8001ebb8 <bcache+0x8000>
    80003320:	0001c717          	auipc	a4,0x1c
    80003324:	b0070713          	addi	a4,a4,-1280 # 8001ee20 <bcache+0x8268>
    80003328:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    8000332c:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003330:	00014497          	auipc	s1,0x14
    80003334:	8a048493          	addi	s1,s1,-1888 # 80016bd0 <bcache+0x18>
    b->next = bcache.head.next;
    80003338:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    8000333a:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    8000333c:	00005a17          	auipc	s4,0x5
    80003340:	2b4a0a13          	addi	s4,s4,692 # 800085f0 <syscalls+0xd0>
    b->next = bcache.head.next;
    80003344:	2b893783          	ld	a5,696(s2)
    80003348:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    8000334a:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    8000334e:	85d2                	mv	a1,s4
    80003350:	01048513          	addi	a0,s1,16
    80003354:	00001097          	auipc	ra,0x1
    80003358:	496080e7          	jalr	1174(ra) # 800047ea <initsleeplock>
    bcache.head.next->prev = b;
    8000335c:	2b893783          	ld	a5,696(s2)
    80003360:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80003362:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80003366:	45848493          	addi	s1,s1,1112
    8000336a:	fd349de3          	bne	s1,s3,80003344 <binit+0x54>
  }
}
    8000336e:	70a2                	ld	ra,40(sp)
    80003370:	7402                	ld	s0,32(sp)
    80003372:	64e2                	ld	s1,24(sp)
    80003374:	6942                	ld	s2,16(sp)
    80003376:	69a2                	ld	s3,8(sp)
    80003378:	6a02                	ld	s4,0(sp)
    8000337a:	6145                	addi	sp,sp,48
    8000337c:	8082                	ret

000000008000337e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    8000337e:	7179                	addi	sp,sp,-48
    80003380:	f406                	sd	ra,40(sp)
    80003382:	f022                	sd	s0,32(sp)
    80003384:	ec26                	sd	s1,24(sp)
    80003386:	e84a                	sd	s2,16(sp)
    80003388:	e44e                	sd	s3,8(sp)
    8000338a:	1800                	addi	s0,sp,48
    8000338c:	892a                	mv	s2,a0
    8000338e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003390:	00014517          	auipc	a0,0x14
    80003394:	82850513          	addi	a0,a0,-2008 # 80016bb8 <bcache>
    80003398:	ffffe097          	auipc	ra,0xffffe
    8000339c:	83a080e7          	jalr	-1990(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    800033a0:	0001c497          	auipc	s1,0x1c
    800033a4:	ad04b483          	ld	s1,-1328(s1) # 8001ee70 <bcache+0x82b8>
    800033a8:	0001c797          	auipc	a5,0x1c
    800033ac:	a7878793          	addi	a5,a5,-1416 # 8001ee20 <bcache+0x8268>
    800033b0:	02f48f63          	beq	s1,a5,800033ee <bread+0x70>
    800033b4:	873e                	mv	a4,a5
    800033b6:	a021                	j	800033be <bread+0x40>
    800033b8:	68a4                	ld	s1,80(s1)
    800033ba:	02e48a63          	beq	s1,a4,800033ee <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    800033be:	449c                	lw	a5,8(s1)
    800033c0:	ff279ce3          	bne	a5,s2,800033b8 <bread+0x3a>
    800033c4:	44dc                	lw	a5,12(s1)
    800033c6:	ff3799e3          	bne	a5,s3,800033b8 <bread+0x3a>
      b->refcnt++;
    800033ca:	40bc                	lw	a5,64(s1)
    800033cc:	2785                	addiw	a5,a5,1
    800033ce:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800033d0:	00013517          	auipc	a0,0x13
    800033d4:	7e850513          	addi	a0,a0,2024 # 80016bb8 <bcache>
    800033d8:	ffffe097          	auipc	ra,0xffffe
    800033dc:	8ae080e7          	jalr	-1874(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    800033e0:	01048513          	addi	a0,s1,16
    800033e4:	00001097          	auipc	ra,0x1
    800033e8:	440080e7          	jalr	1088(ra) # 80004824 <acquiresleep>
      return b;
    800033ec:	a8b9                	j	8000344a <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800033ee:	0001c497          	auipc	s1,0x1c
    800033f2:	a7a4b483          	ld	s1,-1414(s1) # 8001ee68 <bcache+0x82b0>
    800033f6:	0001c797          	auipc	a5,0x1c
    800033fa:	a2a78793          	addi	a5,a5,-1494 # 8001ee20 <bcache+0x8268>
    800033fe:	00f48863          	beq	s1,a5,8000340e <bread+0x90>
    80003402:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80003404:	40bc                	lw	a5,64(s1)
    80003406:	cf81                	beqz	a5,8000341e <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003408:	64a4                	ld	s1,72(s1)
    8000340a:	fee49de3          	bne	s1,a4,80003404 <bread+0x86>
  panic("bget: no buffers");
    8000340e:	00005517          	auipc	a0,0x5
    80003412:	1ea50513          	addi	a0,a0,490 # 800085f8 <syscalls+0xd8>
    80003416:	ffffd097          	auipc	ra,0xffffd
    8000341a:	126080e7          	jalr	294(ra) # 8000053c <panic>
      b->dev = dev;
    8000341e:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003422:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003426:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    8000342a:	4785                	li	a5,1
    8000342c:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000342e:	00013517          	auipc	a0,0x13
    80003432:	78a50513          	addi	a0,a0,1930 # 80016bb8 <bcache>
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	850080e7          	jalr	-1968(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000343e:	01048513          	addi	a0,s1,16
    80003442:	00001097          	auipc	ra,0x1
    80003446:	3e2080e7          	jalr	994(ra) # 80004824 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    8000344a:	409c                	lw	a5,0(s1)
    8000344c:	cb89                	beqz	a5,8000345e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000344e:	8526                	mv	a0,s1
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6145                	addi	sp,sp,48
    8000345c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000345e:	4581                	li	a1,0
    80003460:	8526                	mv	a0,s1
    80003462:	00003097          	auipc	ra,0x3
    80003466:	f80080e7          	jalr	-128(ra) # 800063e2 <virtio_disk_rw>
    b->valid = 1;
    8000346a:	4785                	li	a5,1
    8000346c:	c09c                	sw	a5,0(s1)
  return b;
    8000346e:	b7c5                	j	8000344e <bread+0xd0>

0000000080003470 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003470:	1101                	addi	sp,sp,-32
    80003472:	ec06                	sd	ra,24(sp)
    80003474:	e822                	sd	s0,16(sp)
    80003476:	e426                	sd	s1,8(sp)
    80003478:	1000                	addi	s0,sp,32
    8000347a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000347c:	0541                	addi	a0,a0,16
    8000347e:	00001097          	auipc	ra,0x1
    80003482:	440080e7          	jalr	1088(ra) # 800048be <holdingsleep>
    80003486:	cd01                	beqz	a0,8000349e <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003488:	4585                	li	a1,1
    8000348a:	8526                	mv	a0,s1
    8000348c:	00003097          	auipc	ra,0x3
    80003490:	f56080e7          	jalr	-170(ra) # 800063e2 <virtio_disk_rw>
}
    80003494:	60e2                	ld	ra,24(sp)
    80003496:	6442                	ld	s0,16(sp)
    80003498:	64a2                	ld	s1,8(sp)
    8000349a:	6105                	addi	sp,sp,32
    8000349c:	8082                	ret
    panic("bwrite");
    8000349e:	00005517          	auipc	a0,0x5
    800034a2:	17250513          	addi	a0,a0,370 # 80008610 <syscalls+0xf0>
    800034a6:	ffffd097          	auipc	ra,0xffffd
    800034aa:	096080e7          	jalr	150(ra) # 8000053c <panic>

00000000800034ae <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800034ae:	1101                	addi	sp,sp,-32
    800034b0:	ec06                	sd	ra,24(sp)
    800034b2:	e822                	sd	s0,16(sp)
    800034b4:	e426                	sd	s1,8(sp)
    800034b6:	e04a                	sd	s2,0(sp)
    800034b8:	1000                	addi	s0,sp,32
    800034ba:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800034bc:	01050913          	addi	s2,a0,16
    800034c0:	854a                	mv	a0,s2
    800034c2:	00001097          	auipc	ra,0x1
    800034c6:	3fc080e7          	jalr	1020(ra) # 800048be <holdingsleep>
    800034ca:	c925                	beqz	a0,8000353a <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800034cc:	854a                	mv	a0,s2
    800034ce:	00001097          	auipc	ra,0x1
    800034d2:	3ac080e7          	jalr	940(ra) # 8000487a <releasesleep>

  acquire(&bcache.lock);
    800034d6:	00013517          	auipc	a0,0x13
    800034da:	6e250513          	addi	a0,a0,1762 # 80016bb8 <bcache>
    800034de:	ffffd097          	auipc	ra,0xffffd
    800034e2:	6f4080e7          	jalr	1780(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800034e6:	40bc                	lw	a5,64(s1)
    800034e8:	37fd                	addiw	a5,a5,-1
    800034ea:	0007871b          	sext.w	a4,a5
    800034ee:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800034f0:	e71d                	bnez	a4,8000351e <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800034f2:	68b8                	ld	a4,80(s1)
    800034f4:	64bc                	ld	a5,72(s1)
    800034f6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800034f8:	68b8                	ld	a4,80(s1)
    800034fa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800034fc:	0001b797          	auipc	a5,0x1b
    80003500:	6bc78793          	addi	a5,a5,1724 # 8001ebb8 <bcache+0x8000>
    80003504:	2b87b703          	ld	a4,696(a5)
    80003508:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    8000350a:	0001c717          	auipc	a4,0x1c
    8000350e:	91670713          	addi	a4,a4,-1770 # 8001ee20 <bcache+0x8268>
    80003512:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80003514:	2b87b703          	ld	a4,696(a5)
    80003518:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    8000351a:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000351e:	00013517          	auipc	a0,0x13
    80003522:	69a50513          	addi	a0,a0,1690 # 80016bb8 <bcache>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	760080e7          	jalr	1888(ra) # 80000c86 <release>
}
    8000352e:	60e2                	ld	ra,24(sp)
    80003530:	6442                	ld	s0,16(sp)
    80003532:	64a2                	ld	s1,8(sp)
    80003534:	6902                	ld	s2,0(sp)
    80003536:	6105                	addi	sp,sp,32
    80003538:	8082                	ret
    panic("brelse");
    8000353a:	00005517          	auipc	a0,0x5
    8000353e:	0de50513          	addi	a0,a0,222 # 80008618 <syscalls+0xf8>
    80003542:	ffffd097          	auipc	ra,0xffffd
    80003546:	ffa080e7          	jalr	-6(ra) # 8000053c <panic>

000000008000354a <bpin>:

void
bpin(struct buf *b) {
    8000354a:	1101                	addi	sp,sp,-32
    8000354c:	ec06                	sd	ra,24(sp)
    8000354e:	e822                	sd	s0,16(sp)
    80003550:	e426                	sd	s1,8(sp)
    80003552:	1000                	addi	s0,sp,32
    80003554:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003556:	00013517          	auipc	a0,0x13
    8000355a:	66250513          	addi	a0,a0,1634 # 80016bb8 <bcache>
    8000355e:	ffffd097          	auipc	ra,0xffffd
    80003562:	674080e7          	jalr	1652(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003566:	40bc                	lw	a5,64(s1)
    80003568:	2785                	addiw	a5,a5,1
    8000356a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000356c:	00013517          	auipc	a0,0x13
    80003570:	64c50513          	addi	a0,a0,1612 # 80016bb8 <bcache>
    80003574:	ffffd097          	auipc	ra,0xffffd
    80003578:	712080e7          	jalr	1810(ra) # 80000c86 <release>
}
    8000357c:	60e2                	ld	ra,24(sp)
    8000357e:	6442                	ld	s0,16(sp)
    80003580:	64a2                	ld	s1,8(sp)
    80003582:	6105                	addi	sp,sp,32
    80003584:	8082                	ret

0000000080003586 <bunpin>:

void
bunpin(struct buf *b) {
    80003586:	1101                	addi	sp,sp,-32
    80003588:	ec06                	sd	ra,24(sp)
    8000358a:	e822                	sd	s0,16(sp)
    8000358c:	e426                	sd	s1,8(sp)
    8000358e:	1000                	addi	s0,sp,32
    80003590:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003592:	00013517          	auipc	a0,0x13
    80003596:	62650513          	addi	a0,a0,1574 # 80016bb8 <bcache>
    8000359a:	ffffd097          	auipc	ra,0xffffd
    8000359e:	638080e7          	jalr	1592(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800035a2:	40bc                	lw	a5,64(s1)
    800035a4:	37fd                	addiw	a5,a5,-1
    800035a6:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800035a8:	00013517          	auipc	a0,0x13
    800035ac:	61050513          	addi	a0,a0,1552 # 80016bb8 <bcache>
    800035b0:	ffffd097          	auipc	ra,0xffffd
    800035b4:	6d6080e7          	jalr	1750(ra) # 80000c86 <release>
}
    800035b8:	60e2                	ld	ra,24(sp)
    800035ba:	6442                	ld	s0,16(sp)
    800035bc:	64a2                	ld	s1,8(sp)
    800035be:	6105                	addi	sp,sp,32
    800035c0:	8082                	ret

00000000800035c2 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800035c2:	1101                	addi	sp,sp,-32
    800035c4:	ec06                	sd	ra,24(sp)
    800035c6:	e822                	sd	s0,16(sp)
    800035c8:	e426                	sd	s1,8(sp)
    800035ca:	e04a                	sd	s2,0(sp)
    800035cc:	1000                	addi	s0,sp,32
    800035ce:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800035d0:	00d5d59b          	srliw	a1,a1,0xd
    800035d4:	0001c797          	auipc	a5,0x1c
    800035d8:	cc07a783          	lw	a5,-832(a5) # 8001f294 <sb+0x1c>
    800035dc:	9dbd                	addw	a1,a1,a5
    800035de:	00000097          	auipc	ra,0x0
    800035e2:	da0080e7          	jalr	-608(ra) # 8000337e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    800035e6:	0074f713          	andi	a4,s1,7
    800035ea:	4785                	li	a5,1
    800035ec:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800035f0:	14ce                	slli	s1,s1,0x33
    800035f2:	90d9                	srli	s1,s1,0x36
    800035f4:	00950733          	add	a4,a0,s1
    800035f8:	05874703          	lbu	a4,88(a4)
    800035fc:	00e7f6b3          	and	a3,a5,a4
    80003600:	c69d                	beqz	a3,8000362e <bfree+0x6c>
    80003602:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003604:	94aa                	add	s1,s1,a0
    80003606:	fff7c793          	not	a5,a5
    8000360a:	8f7d                	and	a4,a4,a5
    8000360c:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003610:	00001097          	auipc	ra,0x1
    80003614:	0f6080e7          	jalr	246(ra) # 80004706 <log_write>
  brelse(bp);
    80003618:	854a                	mv	a0,s2
    8000361a:	00000097          	auipc	ra,0x0
    8000361e:	e94080e7          	jalr	-364(ra) # 800034ae <brelse>
}
    80003622:	60e2                	ld	ra,24(sp)
    80003624:	6442                	ld	s0,16(sp)
    80003626:	64a2                	ld	s1,8(sp)
    80003628:	6902                	ld	s2,0(sp)
    8000362a:	6105                	addi	sp,sp,32
    8000362c:	8082                	ret
    panic("freeing free block");
    8000362e:	00005517          	auipc	a0,0x5
    80003632:	ff250513          	addi	a0,a0,-14 # 80008620 <syscalls+0x100>
    80003636:	ffffd097          	auipc	ra,0xffffd
    8000363a:	f06080e7          	jalr	-250(ra) # 8000053c <panic>

000000008000363e <balloc>:
{
    8000363e:	711d                	addi	sp,sp,-96
    80003640:	ec86                	sd	ra,88(sp)
    80003642:	e8a2                	sd	s0,80(sp)
    80003644:	e4a6                	sd	s1,72(sp)
    80003646:	e0ca                	sd	s2,64(sp)
    80003648:	fc4e                	sd	s3,56(sp)
    8000364a:	f852                	sd	s4,48(sp)
    8000364c:	f456                	sd	s5,40(sp)
    8000364e:	f05a                	sd	s6,32(sp)
    80003650:	ec5e                	sd	s7,24(sp)
    80003652:	e862                	sd	s8,16(sp)
    80003654:	e466                	sd	s9,8(sp)
    80003656:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003658:	0001c797          	auipc	a5,0x1c
    8000365c:	c247a783          	lw	a5,-988(a5) # 8001f27c <sb+0x4>
    80003660:	cff5                	beqz	a5,8000375c <balloc+0x11e>
    80003662:	8baa                	mv	s7,a0
    80003664:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003666:	0001cb17          	auipc	s6,0x1c
    8000366a:	c12b0b13          	addi	s6,s6,-1006 # 8001f278 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000366e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003670:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003672:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003674:	6c89                	lui	s9,0x2
    80003676:	a061                	j	800036fe <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003678:	97ca                	add	a5,a5,s2
    8000367a:	8e55                	or	a2,a2,a3
    8000367c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003680:	854a                	mv	a0,s2
    80003682:	00001097          	auipc	ra,0x1
    80003686:	084080e7          	jalr	132(ra) # 80004706 <log_write>
        brelse(bp);
    8000368a:	854a                	mv	a0,s2
    8000368c:	00000097          	auipc	ra,0x0
    80003690:	e22080e7          	jalr	-478(ra) # 800034ae <brelse>
  bp = bread(dev, bno);
    80003694:	85a6                	mv	a1,s1
    80003696:	855e                	mv	a0,s7
    80003698:	00000097          	auipc	ra,0x0
    8000369c:	ce6080e7          	jalr	-794(ra) # 8000337e <bread>
    800036a0:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800036a2:	40000613          	li	a2,1024
    800036a6:	4581                	li	a1,0
    800036a8:	05850513          	addi	a0,a0,88
    800036ac:	ffffd097          	auipc	ra,0xffffd
    800036b0:	622080e7          	jalr	1570(ra) # 80000cce <memset>
  log_write(bp);
    800036b4:	854a                	mv	a0,s2
    800036b6:	00001097          	auipc	ra,0x1
    800036ba:	050080e7          	jalr	80(ra) # 80004706 <log_write>
  brelse(bp);
    800036be:	854a                	mv	a0,s2
    800036c0:	00000097          	auipc	ra,0x0
    800036c4:	dee080e7          	jalr	-530(ra) # 800034ae <brelse>
}
    800036c8:	8526                	mv	a0,s1
    800036ca:	60e6                	ld	ra,88(sp)
    800036cc:	6446                	ld	s0,80(sp)
    800036ce:	64a6                	ld	s1,72(sp)
    800036d0:	6906                	ld	s2,64(sp)
    800036d2:	79e2                	ld	s3,56(sp)
    800036d4:	7a42                	ld	s4,48(sp)
    800036d6:	7aa2                	ld	s5,40(sp)
    800036d8:	7b02                	ld	s6,32(sp)
    800036da:	6be2                	ld	s7,24(sp)
    800036dc:	6c42                	ld	s8,16(sp)
    800036de:	6ca2                	ld	s9,8(sp)
    800036e0:	6125                	addi	sp,sp,96
    800036e2:	8082                	ret
    brelse(bp);
    800036e4:	854a                	mv	a0,s2
    800036e6:	00000097          	auipc	ra,0x0
    800036ea:	dc8080e7          	jalr	-568(ra) # 800034ae <brelse>
  for(b = 0; b < sb.size; b += BPB){
    800036ee:	015c87bb          	addw	a5,s9,s5
    800036f2:	00078a9b          	sext.w	s5,a5
    800036f6:	004b2703          	lw	a4,4(s6)
    800036fa:	06eaf163          	bgeu	s5,a4,8000375c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800036fe:	41fad79b          	sraiw	a5,s5,0x1f
    80003702:	0137d79b          	srliw	a5,a5,0x13
    80003706:	015787bb          	addw	a5,a5,s5
    8000370a:	40d7d79b          	sraiw	a5,a5,0xd
    8000370e:	01cb2583          	lw	a1,28(s6)
    80003712:	9dbd                	addw	a1,a1,a5
    80003714:	855e                	mv	a0,s7
    80003716:	00000097          	auipc	ra,0x0
    8000371a:	c68080e7          	jalr	-920(ra) # 8000337e <bread>
    8000371e:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003720:	004b2503          	lw	a0,4(s6)
    80003724:	000a849b          	sext.w	s1,s5
    80003728:	8762                	mv	a4,s8
    8000372a:	faa4fde3          	bgeu	s1,a0,800036e4 <balloc+0xa6>
      m = 1 << (bi % 8);
    8000372e:	00777693          	andi	a3,a4,7
    80003732:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003736:	41f7579b          	sraiw	a5,a4,0x1f
    8000373a:	01d7d79b          	srliw	a5,a5,0x1d
    8000373e:	9fb9                	addw	a5,a5,a4
    80003740:	4037d79b          	sraiw	a5,a5,0x3
    80003744:	00f90633          	add	a2,s2,a5
    80003748:	05864603          	lbu	a2,88(a2)
    8000374c:	00c6f5b3          	and	a1,a3,a2
    80003750:	d585                	beqz	a1,80003678 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003752:	2705                	addiw	a4,a4,1
    80003754:	2485                	addiw	s1,s1,1
    80003756:	fd471ae3          	bne	a4,s4,8000372a <balloc+0xec>
    8000375a:	b769                	j	800036e4 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000375c:	00005517          	auipc	a0,0x5
    80003760:	edc50513          	addi	a0,a0,-292 # 80008638 <syscalls+0x118>
    80003764:	ffffd097          	auipc	ra,0xffffd
    80003768:	e22080e7          	jalr	-478(ra) # 80000586 <printf>
  return 0;
    8000376c:	4481                	li	s1,0
    8000376e:	bfa9                	j	800036c8 <balloc+0x8a>

0000000080003770 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003770:	7179                	addi	sp,sp,-48
    80003772:	f406                	sd	ra,40(sp)
    80003774:	f022                	sd	s0,32(sp)
    80003776:	ec26                	sd	s1,24(sp)
    80003778:	e84a                	sd	s2,16(sp)
    8000377a:	e44e                	sd	s3,8(sp)
    8000377c:	e052                	sd	s4,0(sp)
    8000377e:	1800                	addi	s0,sp,48
    80003780:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003782:	47ad                	li	a5,11
    80003784:	02b7e863          	bltu	a5,a1,800037b4 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003788:	02059793          	slli	a5,a1,0x20
    8000378c:	01e7d593          	srli	a1,a5,0x1e
    80003790:	00b504b3          	add	s1,a0,a1
    80003794:	0504a903          	lw	s2,80(s1)
    80003798:	06091e63          	bnez	s2,80003814 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000379c:	4108                	lw	a0,0(a0)
    8000379e:	00000097          	auipc	ra,0x0
    800037a2:	ea0080e7          	jalr	-352(ra) # 8000363e <balloc>
    800037a6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037aa:	06090563          	beqz	s2,80003814 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800037ae:	0524a823          	sw	s2,80(s1)
    800037b2:	a08d                	j	80003814 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800037b4:	ff45849b          	addiw	s1,a1,-12
    800037b8:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800037bc:	0ff00793          	li	a5,255
    800037c0:	08e7e563          	bltu	a5,a4,8000384a <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800037c4:	08052903          	lw	s2,128(a0)
    800037c8:	00091d63          	bnez	s2,800037e2 <bmap+0x72>
      addr = balloc(ip->dev);
    800037cc:	4108                	lw	a0,0(a0)
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	e70080e7          	jalr	-400(ra) # 8000363e <balloc>
    800037d6:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800037da:	02090d63          	beqz	s2,80003814 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    800037de:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    800037e2:	85ca                	mv	a1,s2
    800037e4:	0009a503          	lw	a0,0(s3)
    800037e8:	00000097          	auipc	ra,0x0
    800037ec:	b96080e7          	jalr	-1130(ra) # 8000337e <bread>
    800037f0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800037f2:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800037f6:	02049713          	slli	a4,s1,0x20
    800037fa:	01e75593          	srli	a1,a4,0x1e
    800037fe:	00b784b3          	add	s1,a5,a1
    80003802:	0004a903          	lw	s2,0(s1)
    80003806:	02090063          	beqz	s2,80003826 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000380a:	8552                	mv	a0,s4
    8000380c:	00000097          	auipc	ra,0x0
    80003810:	ca2080e7          	jalr	-862(ra) # 800034ae <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    80003814:	854a                	mv	a0,s2
    80003816:	70a2                	ld	ra,40(sp)
    80003818:	7402                	ld	s0,32(sp)
    8000381a:	64e2                	ld	s1,24(sp)
    8000381c:	6942                	ld	s2,16(sp)
    8000381e:	69a2                	ld	s3,8(sp)
    80003820:	6a02                	ld	s4,0(sp)
    80003822:	6145                	addi	sp,sp,48
    80003824:	8082                	ret
      addr = balloc(ip->dev);
    80003826:	0009a503          	lw	a0,0(s3)
    8000382a:	00000097          	auipc	ra,0x0
    8000382e:	e14080e7          	jalr	-492(ra) # 8000363e <balloc>
    80003832:	0005091b          	sext.w	s2,a0
      if(addr){
    80003836:	fc090ae3          	beqz	s2,8000380a <bmap+0x9a>
        a[bn] = addr;
    8000383a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    8000383e:	8552                	mv	a0,s4
    80003840:	00001097          	auipc	ra,0x1
    80003844:	ec6080e7          	jalr	-314(ra) # 80004706 <log_write>
    80003848:	b7c9                	j	8000380a <bmap+0x9a>
  panic("bmap: out of range");
    8000384a:	00005517          	auipc	a0,0x5
    8000384e:	e0650513          	addi	a0,a0,-506 # 80008650 <syscalls+0x130>
    80003852:	ffffd097          	auipc	ra,0xffffd
    80003856:	cea080e7          	jalr	-790(ra) # 8000053c <panic>

000000008000385a <iget>:
{
    8000385a:	7179                	addi	sp,sp,-48
    8000385c:	f406                	sd	ra,40(sp)
    8000385e:	f022                	sd	s0,32(sp)
    80003860:	ec26                	sd	s1,24(sp)
    80003862:	e84a                	sd	s2,16(sp)
    80003864:	e44e                	sd	s3,8(sp)
    80003866:	e052                	sd	s4,0(sp)
    80003868:	1800                	addi	s0,sp,48
    8000386a:	89aa                	mv	s3,a0
    8000386c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000386e:	0001c517          	auipc	a0,0x1c
    80003872:	a2a50513          	addi	a0,a0,-1494 # 8001f298 <itable>
    80003876:	ffffd097          	auipc	ra,0xffffd
    8000387a:	35c080e7          	jalr	860(ra) # 80000bd2 <acquire>
  empty = 0;
    8000387e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003880:	0001c497          	auipc	s1,0x1c
    80003884:	a3048493          	addi	s1,s1,-1488 # 8001f2b0 <itable+0x18>
    80003888:	0001d697          	auipc	a3,0x1d
    8000388c:	4b868693          	addi	a3,a3,1208 # 80020d40 <log>
    80003890:	a039                	j	8000389e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003892:	02090b63          	beqz	s2,800038c8 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003896:	08848493          	addi	s1,s1,136
    8000389a:	02d48a63          	beq	s1,a3,800038ce <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000389e:	449c                	lw	a5,8(s1)
    800038a0:	fef059e3          	blez	a5,80003892 <iget+0x38>
    800038a4:	4098                	lw	a4,0(s1)
    800038a6:	ff3716e3          	bne	a4,s3,80003892 <iget+0x38>
    800038aa:	40d8                	lw	a4,4(s1)
    800038ac:	ff4713e3          	bne	a4,s4,80003892 <iget+0x38>
      ip->ref++;
    800038b0:	2785                	addiw	a5,a5,1
    800038b2:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800038b4:	0001c517          	auipc	a0,0x1c
    800038b8:	9e450513          	addi	a0,a0,-1564 # 8001f298 <itable>
    800038bc:	ffffd097          	auipc	ra,0xffffd
    800038c0:	3ca080e7          	jalr	970(ra) # 80000c86 <release>
      return ip;
    800038c4:	8926                	mv	s2,s1
    800038c6:	a03d                	j	800038f4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800038c8:	f7f9                	bnez	a5,80003896 <iget+0x3c>
    800038ca:	8926                	mv	s2,s1
    800038cc:	b7e9                	j	80003896 <iget+0x3c>
  if(empty == 0)
    800038ce:	02090c63          	beqz	s2,80003906 <iget+0xac>
  ip->dev = dev;
    800038d2:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800038d6:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    800038da:	4785                	li	a5,1
    800038dc:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    800038e0:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    800038e4:	0001c517          	auipc	a0,0x1c
    800038e8:	9b450513          	addi	a0,a0,-1612 # 8001f298 <itable>
    800038ec:	ffffd097          	auipc	ra,0xffffd
    800038f0:	39a080e7          	jalr	922(ra) # 80000c86 <release>
}
    800038f4:	854a                	mv	a0,s2
    800038f6:	70a2                	ld	ra,40(sp)
    800038f8:	7402                	ld	s0,32(sp)
    800038fa:	64e2                	ld	s1,24(sp)
    800038fc:	6942                	ld	s2,16(sp)
    800038fe:	69a2                	ld	s3,8(sp)
    80003900:	6a02                	ld	s4,0(sp)
    80003902:	6145                	addi	sp,sp,48
    80003904:	8082                	ret
    panic("iget: no inodes");
    80003906:	00005517          	auipc	a0,0x5
    8000390a:	d6250513          	addi	a0,a0,-670 # 80008668 <syscalls+0x148>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	c2e080e7          	jalr	-978(ra) # 8000053c <panic>

0000000080003916 <fsinit>:
fsinit(int dev) {
    80003916:	7179                	addi	sp,sp,-48
    80003918:	f406                	sd	ra,40(sp)
    8000391a:	f022                	sd	s0,32(sp)
    8000391c:	ec26                	sd	s1,24(sp)
    8000391e:	e84a                	sd	s2,16(sp)
    80003920:	e44e                	sd	s3,8(sp)
    80003922:	1800                	addi	s0,sp,48
    80003924:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003926:	4585                	li	a1,1
    80003928:	00000097          	auipc	ra,0x0
    8000392c:	a56080e7          	jalr	-1450(ra) # 8000337e <bread>
    80003930:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003932:	0001c997          	auipc	s3,0x1c
    80003936:	94698993          	addi	s3,s3,-1722 # 8001f278 <sb>
    8000393a:	02000613          	li	a2,32
    8000393e:	05850593          	addi	a1,a0,88
    80003942:	854e                	mv	a0,s3
    80003944:	ffffd097          	auipc	ra,0xffffd
    80003948:	3e6080e7          	jalr	998(ra) # 80000d2a <memmove>
  brelse(bp);
    8000394c:	8526                	mv	a0,s1
    8000394e:	00000097          	auipc	ra,0x0
    80003952:	b60080e7          	jalr	-1184(ra) # 800034ae <brelse>
  if(sb.magic != FSMAGIC)
    80003956:	0009a703          	lw	a4,0(s3)
    8000395a:	102037b7          	lui	a5,0x10203
    8000395e:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003962:	02f71263          	bne	a4,a5,80003986 <fsinit+0x70>
  initlog(dev, &sb);
    80003966:	0001c597          	auipc	a1,0x1c
    8000396a:	91258593          	addi	a1,a1,-1774 # 8001f278 <sb>
    8000396e:	854a                	mv	a0,s2
    80003970:	00001097          	auipc	ra,0x1
    80003974:	b2c080e7          	jalr	-1236(ra) # 8000449c <initlog>
}
    80003978:	70a2                	ld	ra,40(sp)
    8000397a:	7402                	ld	s0,32(sp)
    8000397c:	64e2                	ld	s1,24(sp)
    8000397e:	6942                	ld	s2,16(sp)
    80003980:	69a2                	ld	s3,8(sp)
    80003982:	6145                	addi	sp,sp,48
    80003984:	8082                	ret
    panic("invalid file system");
    80003986:	00005517          	auipc	a0,0x5
    8000398a:	cf250513          	addi	a0,a0,-782 # 80008678 <syscalls+0x158>
    8000398e:	ffffd097          	auipc	ra,0xffffd
    80003992:	bae080e7          	jalr	-1106(ra) # 8000053c <panic>

0000000080003996 <iinit>:
{
    80003996:	7179                	addi	sp,sp,-48
    80003998:	f406                	sd	ra,40(sp)
    8000399a:	f022                	sd	s0,32(sp)
    8000399c:	ec26                	sd	s1,24(sp)
    8000399e:	e84a                	sd	s2,16(sp)
    800039a0:	e44e                	sd	s3,8(sp)
    800039a2:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800039a4:	00005597          	auipc	a1,0x5
    800039a8:	cec58593          	addi	a1,a1,-788 # 80008690 <syscalls+0x170>
    800039ac:	0001c517          	auipc	a0,0x1c
    800039b0:	8ec50513          	addi	a0,a0,-1812 # 8001f298 <itable>
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	18e080e7          	jalr	398(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800039bc:	0001c497          	auipc	s1,0x1c
    800039c0:	90448493          	addi	s1,s1,-1788 # 8001f2c0 <itable+0x28>
    800039c4:	0001d997          	auipc	s3,0x1d
    800039c8:	38c98993          	addi	s3,s3,908 # 80020d50 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800039cc:	00005917          	auipc	s2,0x5
    800039d0:	ccc90913          	addi	s2,s2,-820 # 80008698 <syscalls+0x178>
    800039d4:	85ca                	mv	a1,s2
    800039d6:	8526                	mv	a0,s1
    800039d8:	00001097          	auipc	ra,0x1
    800039dc:	e12080e7          	jalr	-494(ra) # 800047ea <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    800039e0:	08848493          	addi	s1,s1,136
    800039e4:	ff3498e3          	bne	s1,s3,800039d4 <iinit+0x3e>
}
    800039e8:	70a2                	ld	ra,40(sp)
    800039ea:	7402                	ld	s0,32(sp)
    800039ec:	64e2                	ld	s1,24(sp)
    800039ee:	6942                	ld	s2,16(sp)
    800039f0:	69a2                	ld	s3,8(sp)
    800039f2:	6145                	addi	sp,sp,48
    800039f4:	8082                	ret

00000000800039f6 <ialloc>:
{
    800039f6:	7139                	addi	sp,sp,-64
    800039f8:	fc06                	sd	ra,56(sp)
    800039fa:	f822                	sd	s0,48(sp)
    800039fc:	f426                	sd	s1,40(sp)
    800039fe:	f04a                	sd	s2,32(sp)
    80003a00:	ec4e                	sd	s3,24(sp)
    80003a02:	e852                	sd	s4,16(sp)
    80003a04:	e456                	sd	s5,8(sp)
    80003a06:	e05a                	sd	s6,0(sp)
    80003a08:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a0a:	0001c717          	auipc	a4,0x1c
    80003a0e:	87a72703          	lw	a4,-1926(a4) # 8001f284 <sb+0xc>
    80003a12:	4785                	li	a5,1
    80003a14:	04e7f863          	bgeu	a5,a4,80003a64 <ialloc+0x6e>
    80003a18:	8aaa                	mv	s5,a0
    80003a1a:	8b2e                	mv	s6,a1
    80003a1c:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003a1e:	0001ca17          	auipc	s4,0x1c
    80003a22:	85aa0a13          	addi	s4,s4,-1958 # 8001f278 <sb>
    80003a26:	00495593          	srli	a1,s2,0x4
    80003a2a:	018a2783          	lw	a5,24(s4)
    80003a2e:	9dbd                	addw	a1,a1,a5
    80003a30:	8556                	mv	a0,s5
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	94c080e7          	jalr	-1716(ra) # 8000337e <bread>
    80003a3a:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003a3c:	05850993          	addi	s3,a0,88
    80003a40:	00f97793          	andi	a5,s2,15
    80003a44:	079a                	slli	a5,a5,0x6
    80003a46:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003a48:	00099783          	lh	a5,0(s3)
    80003a4c:	cf9d                	beqz	a5,80003a8a <ialloc+0x94>
    brelse(bp);
    80003a4e:	00000097          	auipc	ra,0x0
    80003a52:	a60080e7          	jalr	-1440(ra) # 800034ae <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003a56:	0905                	addi	s2,s2,1
    80003a58:	00ca2703          	lw	a4,12(s4)
    80003a5c:	0009079b          	sext.w	a5,s2
    80003a60:	fce7e3e3          	bltu	a5,a4,80003a26 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003a64:	00005517          	auipc	a0,0x5
    80003a68:	c3c50513          	addi	a0,a0,-964 # 800086a0 <syscalls+0x180>
    80003a6c:	ffffd097          	auipc	ra,0xffffd
    80003a70:	b1a080e7          	jalr	-1254(ra) # 80000586 <printf>
  return 0;
    80003a74:	4501                	li	a0,0
}
    80003a76:	70e2                	ld	ra,56(sp)
    80003a78:	7442                	ld	s0,48(sp)
    80003a7a:	74a2                	ld	s1,40(sp)
    80003a7c:	7902                	ld	s2,32(sp)
    80003a7e:	69e2                	ld	s3,24(sp)
    80003a80:	6a42                	ld	s4,16(sp)
    80003a82:	6aa2                	ld	s5,8(sp)
    80003a84:	6b02                	ld	s6,0(sp)
    80003a86:	6121                	addi	sp,sp,64
    80003a88:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    80003a8a:	04000613          	li	a2,64
    80003a8e:	4581                	li	a1,0
    80003a90:	854e                	mv	a0,s3
    80003a92:	ffffd097          	auipc	ra,0xffffd
    80003a96:	23c080e7          	jalr	572(ra) # 80000cce <memset>
      dip->type = type;
    80003a9a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003a9e:	8526                	mv	a0,s1
    80003aa0:	00001097          	auipc	ra,0x1
    80003aa4:	c66080e7          	jalr	-922(ra) # 80004706 <log_write>
      brelse(bp);
    80003aa8:	8526                	mv	a0,s1
    80003aaa:	00000097          	auipc	ra,0x0
    80003aae:	a04080e7          	jalr	-1532(ra) # 800034ae <brelse>
      return iget(dev, inum);
    80003ab2:	0009059b          	sext.w	a1,s2
    80003ab6:	8556                	mv	a0,s5
    80003ab8:	00000097          	auipc	ra,0x0
    80003abc:	da2080e7          	jalr	-606(ra) # 8000385a <iget>
    80003ac0:	bf5d                	j	80003a76 <ialloc+0x80>

0000000080003ac2 <iupdate>:
{
    80003ac2:	1101                	addi	sp,sp,-32
    80003ac4:	ec06                	sd	ra,24(sp)
    80003ac6:	e822                	sd	s0,16(sp)
    80003ac8:	e426                	sd	s1,8(sp)
    80003aca:	e04a                	sd	s2,0(sp)
    80003acc:	1000                	addi	s0,sp,32
    80003ace:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003ad0:	415c                	lw	a5,4(a0)
    80003ad2:	0047d79b          	srliw	a5,a5,0x4
    80003ad6:	0001b597          	auipc	a1,0x1b
    80003ada:	7ba5a583          	lw	a1,1978(a1) # 8001f290 <sb+0x18>
    80003ade:	9dbd                	addw	a1,a1,a5
    80003ae0:	4108                	lw	a0,0(a0)
    80003ae2:	00000097          	auipc	ra,0x0
    80003ae6:	89c080e7          	jalr	-1892(ra) # 8000337e <bread>
    80003aea:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003aec:	05850793          	addi	a5,a0,88
    80003af0:	40d8                	lw	a4,4(s1)
    80003af2:	8b3d                	andi	a4,a4,15
    80003af4:	071a                	slli	a4,a4,0x6
    80003af6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003af8:	04449703          	lh	a4,68(s1)
    80003afc:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003b00:	04649703          	lh	a4,70(s1)
    80003b04:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003b08:	04849703          	lh	a4,72(s1)
    80003b0c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003b10:	04a49703          	lh	a4,74(s1)
    80003b14:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003b18:	44f8                	lw	a4,76(s1)
    80003b1a:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003b1c:	03400613          	li	a2,52
    80003b20:	05048593          	addi	a1,s1,80
    80003b24:	00c78513          	addi	a0,a5,12
    80003b28:	ffffd097          	auipc	ra,0xffffd
    80003b2c:	202080e7          	jalr	514(ra) # 80000d2a <memmove>
  log_write(bp);
    80003b30:	854a                	mv	a0,s2
    80003b32:	00001097          	auipc	ra,0x1
    80003b36:	bd4080e7          	jalr	-1068(ra) # 80004706 <log_write>
  brelse(bp);
    80003b3a:	854a                	mv	a0,s2
    80003b3c:	00000097          	auipc	ra,0x0
    80003b40:	972080e7          	jalr	-1678(ra) # 800034ae <brelse>
}
    80003b44:	60e2                	ld	ra,24(sp)
    80003b46:	6442                	ld	s0,16(sp)
    80003b48:	64a2                	ld	s1,8(sp)
    80003b4a:	6902                	ld	s2,0(sp)
    80003b4c:	6105                	addi	sp,sp,32
    80003b4e:	8082                	ret

0000000080003b50 <idup>:
{
    80003b50:	1101                	addi	sp,sp,-32
    80003b52:	ec06                	sd	ra,24(sp)
    80003b54:	e822                	sd	s0,16(sp)
    80003b56:	e426                	sd	s1,8(sp)
    80003b58:	1000                	addi	s0,sp,32
    80003b5a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003b5c:	0001b517          	auipc	a0,0x1b
    80003b60:	73c50513          	addi	a0,a0,1852 # 8001f298 <itable>
    80003b64:	ffffd097          	auipc	ra,0xffffd
    80003b68:	06e080e7          	jalr	110(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003b6c:	449c                	lw	a5,8(s1)
    80003b6e:	2785                	addiw	a5,a5,1
    80003b70:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b72:	0001b517          	auipc	a0,0x1b
    80003b76:	72650513          	addi	a0,a0,1830 # 8001f298 <itable>
    80003b7a:	ffffd097          	auipc	ra,0xffffd
    80003b7e:	10c080e7          	jalr	268(ra) # 80000c86 <release>
}
    80003b82:	8526                	mv	a0,s1
    80003b84:	60e2                	ld	ra,24(sp)
    80003b86:	6442                	ld	s0,16(sp)
    80003b88:	64a2                	ld	s1,8(sp)
    80003b8a:	6105                	addi	sp,sp,32
    80003b8c:	8082                	ret

0000000080003b8e <ilock>:
{
    80003b8e:	1101                	addi	sp,sp,-32
    80003b90:	ec06                	sd	ra,24(sp)
    80003b92:	e822                	sd	s0,16(sp)
    80003b94:	e426                	sd	s1,8(sp)
    80003b96:	e04a                	sd	s2,0(sp)
    80003b98:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003b9a:	c115                	beqz	a0,80003bbe <ilock+0x30>
    80003b9c:	84aa                	mv	s1,a0
    80003b9e:	451c                	lw	a5,8(a0)
    80003ba0:	00f05f63          	blez	a5,80003bbe <ilock+0x30>
  acquiresleep(&ip->lock);
    80003ba4:	0541                	addi	a0,a0,16
    80003ba6:	00001097          	auipc	ra,0x1
    80003baa:	c7e080e7          	jalr	-898(ra) # 80004824 <acquiresleep>
  if(ip->valid == 0){
    80003bae:	40bc                	lw	a5,64(s1)
    80003bb0:	cf99                	beqz	a5,80003bce <ilock+0x40>
}
    80003bb2:	60e2                	ld	ra,24(sp)
    80003bb4:	6442                	ld	s0,16(sp)
    80003bb6:	64a2                	ld	s1,8(sp)
    80003bb8:	6902                	ld	s2,0(sp)
    80003bba:	6105                	addi	sp,sp,32
    80003bbc:	8082                	ret
    panic("ilock");
    80003bbe:	00005517          	auipc	a0,0x5
    80003bc2:	afa50513          	addi	a0,a0,-1286 # 800086b8 <syscalls+0x198>
    80003bc6:	ffffd097          	auipc	ra,0xffffd
    80003bca:	976080e7          	jalr	-1674(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003bce:	40dc                	lw	a5,4(s1)
    80003bd0:	0047d79b          	srliw	a5,a5,0x4
    80003bd4:	0001b597          	auipc	a1,0x1b
    80003bd8:	6bc5a583          	lw	a1,1724(a1) # 8001f290 <sb+0x18>
    80003bdc:	9dbd                	addw	a1,a1,a5
    80003bde:	4088                	lw	a0,0(s1)
    80003be0:	fffff097          	auipc	ra,0xfffff
    80003be4:	79e080e7          	jalr	1950(ra) # 8000337e <bread>
    80003be8:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003bea:	05850593          	addi	a1,a0,88
    80003bee:	40dc                	lw	a5,4(s1)
    80003bf0:	8bbd                	andi	a5,a5,15
    80003bf2:	079a                	slli	a5,a5,0x6
    80003bf4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003bf6:	00059783          	lh	a5,0(a1)
    80003bfa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003bfe:	00259783          	lh	a5,2(a1)
    80003c02:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003c06:	00459783          	lh	a5,4(a1)
    80003c0a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003c0e:	00659783          	lh	a5,6(a1)
    80003c12:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003c16:	459c                	lw	a5,8(a1)
    80003c18:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003c1a:	03400613          	li	a2,52
    80003c1e:	05b1                	addi	a1,a1,12
    80003c20:	05048513          	addi	a0,s1,80
    80003c24:	ffffd097          	auipc	ra,0xffffd
    80003c28:	106080e7          	jalr	262(ra) # 80000d2a <memmove>
    brelse(bp);
    80003c2c:	854a                	mv	a0,s2
    80003c2e:	00000097          	auipc	ra,0x0
    80003c32:	880080e7          	jalr	-1920(ra) # 800034ae <brelse>
    ip->valid = 1;
    80003c36:	4785                	li	a5,1
    80003c38:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003c3a:	04449783          	lh	a5,68(s1)
    80003c3e:	fbb5                	bnez	a5,80003bb2 <ilock+0x24>
      panic("ilock: no type");
    80003c40:	00005517          	auipc	a0,0x5
    80003c44:	a8050513          	addi	a0,a0,-1408 # 800086c0 <syscalls+0x1a0>
    80003c48:	ffffd097          	auipc	ra,0xffffd
    80003c4c:	8f4080e7          	jalr	-1804(ra) # 8000053c <panic>

0000000080003c50 <iunlock>:
{
    80003c50:	1101                	addi	sp,sp,-32
    80003c52:	ec06                	sd	ra,24(sp)
    80003c54:	e822                	sd	s0,16(sp)
    80003c56:	e426                	sd	s1,8(sp)
    80003c58:	e04a                	sd	s2,0(sp)
    80003c5a:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003c5c:	c905                	beqz	a0,80003c8c <iunlock+0x3c>
    80003c5e:	84aa                	mv	s1,a0
    80003c60:	01050913          	addi	s2,a0,16
    80003c64:	854a                	mv	a0,s2
    80003c66:	00001097          	auipc	ra,0x1
    80003c6a:	c58080e7          	jalr	-936(ra) # 800048be <holdingsleep>
    80003c6e:	cd19                	beqz	a0,80003c8c <iunlock+0x3c>
    80003c70:	449c                	lw	a5,8(s1)
    80003c72:	00f05d63          	blez	a5,80003c8c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003c76:	854a                	mv	a0,s2
    80003c78:	00001097          	auipc	ra,0x1
    80003c7c:	c02080e7          	jalr	-1022(ra) # 8000487a <releasesleep>
}
    80003c80:	60e2                	ld	ra,24(sp)
    80003c82:	6442                	ld	s0,16(sp)
    80003c84:	64a2                	ld	s1,8(sp)
    80003c86:	6902                	ld	s2,0(sp)
    80003c88:	6105                	addi	sp,sp,32
    80003c8a:	8082                	ret
    panic("iunlock");
    80003c8c:	00005517          	auipc	a0,0x5
    80003c90:	a4450513          	addi	a0,a0,-1468 # 800086d0 <syscalls+0x1b0>
    80003c94:	ffffd097          	auipc	ra,0xffffd
    80003c98:	8a8080e7          	jalr	-1880(ra) # 8000053c <panic>

0000000080003c9c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003c9c:	7179                	addi	sp,sp,-48
    80003c9e:	f406                	sd	ra,40(sp)
    80003ca0:	f022                	sd	s0,32(sp)
    80003ca2:	ec26                	sd	s1,24(sp)
    80003ca4:	e84a                	sd	s2,16(sp)
    80003ca6:	e44e                	sd	s3,8(sp)
    80003ca8:	e052                	sd	s4,0(sp)
    80003caa:	1800                	addi	s0,sp,48
    80003cac:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003cae:	05050493          	addi	s1,a0,80
    80003cb2:	08050913          	addi	s2,a0,128
    80003cb6:	a021                	j	80003cbe <itrunc+0x22>
    80003cb8:	0491                	addi	s1,s1,4
    80003cba:	01248d63          	beq	s1,s2,80003cd4 <itrunc+0x38>
    if(ip->addrs[i]){
    80003cbe:	408c                	lw	a1,0(s1)
    80003cc0:	dde5                	beqz	a1,80003cb8 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003cc2:	0009a503          	lw	a0,0(s3)
    80003cc6:	00000097          	auipc	ra,0x0
    80003cca:	8fc080e7          	jalr	-1796(ra) # 800035c2 <bfree>
      ip->addrs[i] = 0;
    80003cce:	0004a023          	sw	zero,0(s1)
    80003cd2:	b7dd                	j	80003cb8 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003cd4:	0809a583          	lw	a1,128(s3)
    80003cd8:	e185                	bnez	a1,80003cf8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003cda:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003cde:	854e                	mv	a0,s3
    80003ce0:	00000097          	auipc	ra,0x0
    80003ce4:	de2080e7          	jalr	-542(ra) # 80003ac2 <iupdate>
}
    80003ce8:	70a2                	ld	ra,40(sp)
    80003cea:	7402                	ld	s0,32(sp)
    80003cec:	64e2                	ld	s1,24(sp)
    80003cee:	6942                	ld	s2,16(sp)
    80003cf0:	69a2                	ld	s3,8(sp)
    80003cf2:	6a02                	ld	s4,0(sp)
    80003cf4:	6145                	addi	sp,sp,48
    80003cf6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003cf8:	0009a503          	lw	a0,0(s3)
    80003cfc:	fffff097          	auipc	ra,0xfffff
    80003d00:	682080e7          	jalr	1666(ra) # 8000337e <bread>
    80003d04:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003d06:	05850493          	addi	s1,a0,88
    80003d0a:	45850913          	addi	s2,a0,1112
    80003d0e:	a021                	j	80003d16 <itrunc+0x7a>
    80003d10:	0491                	addi	s1,s1,4
    80003d12:	01248b63          	beq	s1,s2,80003d28 <itrunc+0x8c>
      if(a[j])
    80003d16:	408c                	lw	a1,0(s1)
    80003d18:	dde5                	beqz	a1,80003d10 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003d1a:	0009a503          	lw	a0,0(s3)
    80003d1e:	00000097          	auipc	ra,0x0
    80003d22:	8a4080e7          	jalr	-1884(ra) # 800035c2 <bfree>
    80003d26:	b7ed                	j	80003d10 <itrunc+0x74>
    brelse(bp);
    80003d28:	8552                	mv	a0,s4
    80003d2a:	fffff097          	auipc	ra,0xfffff
    80003d2e:	784080e7          	jalr	1924(ra) # 800034ae <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003d32:	0809a583          	lw	a1,128(s3)
    80003d36:	0009a503          	lw	a0,0(s3)
    80003d3a:	00000097          	auipc	ra,0x0
    80003d3e:	888080e7          	jalr	-1912(ra) # 800035c2 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003d42:	0809a023          	sw	zero,128(s3)
    80003d46:	bf51                	j	80003cda <itrunc+0x3e>

0000000080003d48 <iput>:
{
    80003d48:	1101                	addi	sp,sp,-32
    80003d4a:	ec06                	sd	ra,24(sp)
    80003d4c:	e822                	sd	s0,16(sp)
    80003d4e:	e426                	sd	s1,8(sp)
    80003d50:	e04a                	sd	s2,0(sp)
    80003d52:	1000                	addi	s0,sp,32
    80003d54:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003d56:	0001b517          	auipc	a0,0x1b
    80003d5a:	54250513          	addi	a0,a0,1346 # 8001f298 <itable>
    80003d5e:	ffffd097          	auipc	ra,0xffffd
    80003d62:	e74080e7          	jalr	-396(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d66:	4498                	lw	a4,8(s1)
    80003d68:	4785                	li	a5,1
    80003d6a:	02f70363          	beq	a4,a5,80003d90 <iput+0x48>
  ip->ref--;
    80003d6e:	449c                	lw	a5,8(s1)
    80003d70:	37fd                	addiw	a5,a5,-1
    80003d72:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003d74:	0001b517          	auipc	a0,0x1b
    80003d78:	52450513          	addi	a0,a0,1316 # 8001f298 <itable>
    80003d7c:	ffffd097          	auipc	ra,0xffffd
    80003d80:	f0a080e7          	jalr	-246(ra) # 80000c86 <release>
}
    80003d84:	60e2                	ld	ra,24(sp)
    80003d86:	6442                	ld	s0,16(sp)
    80003d88:	64a2                	ld	s1,8(sp)
    80003d8a:	6902                	ld	s2,0(sp)
    80003d8c:	6105                	addi	sp,sp,32
    80003d8e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003d90:	40bc                	lw	a5,64(s1)
    80003d92:	dff1                	beqz	a5,80003d6e <iput+0x26>
    80003d94:	04a49783          	lh	a5,74(s1)
    80003d98:	fbf9                	bnez	a5,80003d6e <iput+0x26>
    acquiresleep(&ip->lock);
    80003d9a:	01048913          	addi	s2,s1,16
    80003d9e:	854a                	mv	a0,s2
    80003da0:	00001097          	auipc	ra,0x1
    80003da4:	a84080e7          	jalr	-1404(ra) # 80004824 <acquiresleep>
    release(&itable.lock);
    80003da8:	0001b517          	auipc	a0,0x1b
    80003dac:	4f050513          	addi	a0,a0,1264 # 8001f298 <itable>
    80003db0:	ffffd097          	auipc	ra,0xffffd
    80003db4:	ed6080e7          	jalr	-298(ra) # 80000c86 <release>
    itrunc(ip);
    80003db8:	8526                	mv	a0,s1
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	ee2080e7          	jalr	-286(ra) # 80003c9c <itrunc>
    ip->type = 0;
    80003dc2:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003dc6:	8526                	mv	a0,s1
    80003dc8:	00000097          	auipc	ra,0x0
    80003dcc:	cfa080e7          	jalr	-774(ra) # 80003ac2 <iupdate>
    ip->valid = 0;
    80003dd0:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003dd4:	854a                	mv	a0,s2
    80003dd6:	00001097          	auipc	ra,0x1
    80003dda:	aa4080e7          	jalr	-1372(ra) # 8000487a <releasesleep>
    acquire(&itable.lock);
    80003dde:	0001b517          	auipc	a0,0x1b
    80003de2:	4ba50513          	addi	a0,a0,1210 # 8001f298 <itable>
    80003de6:	ffffd097          	auipc	ra,0xffffd
    80003dea:	dec080e7          	jalr	-532(ra) # 80000bd2 <acquire>
    80003dee:	b741                	j	80003d6e <iput+0x26>

0000000080003df0 <iunlockput>:
{
    80003df0:	1101                	addi	sp,sp,-32
    80003df2:	ec06                	sd	ra,24(sp)
    80003df4:	e822                	sd	s0,16(sp)
    80003df6:	e426                	sd	s1,8(sp)
    80003df8:	1000                	addi	s0,sp,32
    80003dfa:	84aa                	mv	s1,a0
  iunlock(ip);
    80003dfc:	00000097          	auipc	ra,0x0
    80003e00:	e54080e7          	jalr	-428(ra) # 80003c50 <iunlock>
  iput(ip);
    80003e04:	8526                	mv	a0,s1
    80003e06:	00000097          	auipc	ra,0x0
    80003e0a:	f42080e7          	jalr	-190(ra) # 80003d48 <iput>
}
    80003e0e:	60e2                	ld	ra,24(sp)
    80003e10:	6442                	ld	s0,16(sp)
    80003e12:	64a2                	ld	s1,8(sp)
    80003e14:	6105                	addi	sp,sp,32
    80003e16:	8082                	ret

0000000080003e18 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003e18:	1141                	addi	sp,sp,-16
    80003e1a:	e422                	sd	s0,8(sp)
    80003e1c:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003e1e:	411c                	lw	a5,0(a0)
    80003e20:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003e22:	415c                	lw	a5,4(a0)
    80003e24:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003e26:	04451783          	lh	a5,68(a0)
    80003e2a:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003e2e:	04a51783          	lh	a5,74(a0)
    80003e32:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003e36:	04c56783          	lwu	a5,76(a0)
    80003e3a:	e99c                	sd	a5,16(a1)
}
    80003e3c:	6422                	ld	s0,8(sp)
    80003e3e:	0141                	addi	sp,sp,16
    80003e40:	8082                	ret

0000000080003e42 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003e42:	457c                	lw	a5,76(a0)
    80003e44:	0ed7e963          	bltu	a5,a3,80003f36 <readi+0xf4>
{
    80003e48:	7159                	addi	sp,sp,-112
    80003e4a:	f486                	sd	ra,104(sp)
    80003e4c:	f0a2                	sd	s0,96(sp)
    80003e4e:	eca6                	sd	s1,88(sp)
    80003e50:	e8ca                	sd	s2,80(sp)
    80003e52:	e4ce                	sd	s3,72(sp)
    80003e54:	e0d2                	sd	s4,64(sp)
    80003e56:	fc56                	sd	s5,56(sp)
    80003e58:	f85a                	sd	s6,48(sp)
    80003e5a:	f45e                	sd	s7,40(sp)
    80003e5c:	f062                	sd	s8,32(sp)
    80003e5e:	ec66                	sd	s9,24(sp)
    80003e60:	e86a                	sd	s10,16(sp)
    80003e62:	e46e                	sd	s11,8(sp)
    80003e64:	1880                	addi	s0,sp,112
    80003e66:	8b2a                	mv	s6,a0
    80003e68:	8bae                	mv	s7,a1
    80003e6a:	8a32                	mv	s4,a2
    80003e6c:	84b6                	mv	s1,a3
    80003e6e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003e70:	9f35                	addw	a4,a4,a3
    return 0;
    80003e72:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003e74:	0ad76063          	bltu	a4,a3,80003f14 <readi+0xd2>
  if(off + n > ip->size)
    80003e78:	00e7f463          	bgeu	a5,a4,80003e80 <readi+0x3e>
    n = ip->size - off;
    80003e7c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003e80:	0a0a8963          	beqz	s5,80003f32 <readi+0xf0>
    80003e84:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003e86:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003e8a:	5c7d                	li	s8,-1
    80003e8c:	a82d                	j	80003ec6 <readi+0x84>
    80003e8e:	020d1d93          	slli	s11,s10,0x20
    80003e92:	020ddd93          	srli	s11,s11,0x20
    80003e96:	05890613          	addi	a2,s2,88
    80003e9a:	86ee                	mv	a3,s11
    80003e9c:	963a                	add	a2,a2,a4
    80003e9e:	85d2                	mv	a1,s4
    80003ea0:	855e                	mv	a0,s7
    80003ea2:	fffff097          	auipc	ra,0xfffff
    80003ea6:	94a080e7          	jalr	-1718(ra) # 800027ec <either_copyout>
    80003eaa:	05850d63          	beq	a0,s8,80003f04 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003eae:	854a                	mv	a0,s2
    80003eb0:	fffff097          	auipc	ra,0xfffff
    80003eb4:	5fe080e7          	jalr	1534(ra) # 800034ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003eb8:	013d09bb          	addw	s3,s10,s3
    80003ebc:	009d04bb          	addw	s1,s10,s1
    80003ec0:	9a6e                	add	s4,s4,s11
    80003ec2:	0559f763          	bgeu	s3,s5,80003f10 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003ec6:	00a4d59b          	srliw	a1,s1,0xa
    80003eca:	855a                	mv	a0,s6
    80003ecc:	00000097          	auipc	ra,0x0
    80003ed0:	8a4080e7          	jalr	-1884(ra) # 80003770 <bmap>
    80003ed4:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003ed8:	cd85                	beqz	a1,80003f10 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003eda:	000b2503          	lw	a0,0(s6)
    80003ede:	fffff097          	auipc	ra,0xfffff
    80003ee2:	4a0080e7          	jalr	1184(ra) # 8000337e <bread>
    80003ee6:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ee8:	3ff4f713          	andi	a4,s1,1023
    80003eec:	40ec87bb          	subw	a5,s9,a4
    80003ef0:	413a86bb          	subw	a3,s5,s3
    80003ef4:	8d3e                	mv	s10,a5
    80003ef6:	2781                	sext.w	a5,a5
    80003ef8:	0006861b          	sext.w	a2,a3
    80003efc:	f8f679e3          	bgeu	a2,a5,80003e8e <readi+0x4c>
    80003f00:	8d36                	mv	s10,a3
    80003f02:	b771                	j	80003e8e <readi+0x4c>
      brelse(bp);
    80003f04:	854a                	mv	a0,s2
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	5a8080e7          	jalr	1448(ra) # 800034ae <brelse>
      tot = -1;
    80003f0e:	59fd                	li	s3,-1
  }
  return tot;
    80003f10:	0009851b          	sext.w	a0,s3
}
    80003f14:	70a6                	ld	ra,104(sp)
    80003f16:	7406                	ld	s0,96(sp)
    80003f18:	64e6                	ld	s1,88(sp)
    80003f1a:	6946                	ld	s2,80(sp)
    80003f1c:	69a6                	ld	s3,72(sp)
    80003f1e:	6a06                	ld	s4,64(sp)
    80003f20:	7ae2                	ld	s5,56(sp)
    80003f22:	7b42                	ld	s6,48(sp)
    80003f24:	7ba2                	ld	s7,40(sp)
    80003f26:	7c02                	ld	s8,32(sp)
    80003f28:	6ce2                	ld	s9,24(sp)
    80003f2a:	6d42                	ld	s10,16(sp)
    80003f2c:	6da2                	ld	s11,8(sp)
    80003f2e:	6165                	addi	sp,sp,112
    80003f30:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003f32:	89d6                	mv	s3,s5
    80003f34:	bff1                	j	80003f10 <readi+0xce>
    return 0;
    80003f36:	4501                	li	a0,0
}
    80003f38:	8082                	ret

0000000080003f3a <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003f3a:	457c                	lw	a5,76(a0)
    80003f3c:	10d7e863          	bltu	a5,a3,8000404c <writei+0x112>
{
    80003f40:	7159                	addi	sp,sp,-112
    80003f42:	f486                	sd	ra,104(sp)
    80003f44:	f0a2                	sd	s0,96(sp)
    80003f46:	eca6                	sd	s1,88(sp)
    80003f48:	e8ca                	sd	s2,80(sp)
    80003f4a:	e4ce                	sd	s3,72(sp)
    80003f4c:	e0d2                	sd	s4,64(sp)
    80003f4e:	fc56                	sd	s5,56(sp)
    80003f50:	f85a                	sd	s6,48(sp)
    80003f52:	f45e                	sd	s7,40(sp)
    80003f54:	f062                	sd	s8,32(sp)
    80003f56:	ec66                	sd	s9,24(sp)
    80003f58:	e86a                	sd	s10,16(sp)
    80003f5a:	e46e                	sd	s11,8(sp)
    80003f5c:	1880                	addi	s0,sp,112
    80003f5e:	8aaa                	mv	s5,a0
    80003f60:	8bae                	mv	s7,a1
    80003f62:	8a32                	mv	s4,a2
    80003f64:	8936                	mv	s2,a3
    80003f66:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003f68:	00e687bb          	addw	a5,a3,a4
    80003f6c:	0ed7e263          	bltu	a5,a3,80004050 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003f70:	00043737          	lui	a4,0x43
    80003f74:	0ef76063          	bltu	a4,a5,80004054 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003f78:	0c0b0863          	beqz	s6,80004048 <writei+0x10e>
    80003f7c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003f7e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003f82:	5c7d                	li	s8,-1
    80003f84:	a091                	j	80003fc8 <writei+0x8e>
    80003f86:	020d1d93          	slli	s11,s10,0x20
    80003f8a:	020ddd93          	srli	s11,s11,0x20
    80003f8e:	05848513          	addi	a0,s1,88
    80003f92:	86ee                	mv	a3,s11
    80003f94:	8652                	mv	a2,s4
    80003f96:	85de                	mv	a1,s7
    80003f98:	953a                	add	a0,a0,a4
    80003f9a:	fffff097          	auipc	ra,0xfffff
    80003f9e:	8a8080e7          	jalr	-1880(ra) # 80002842 <either_copyin>
    80003fa2:	07850263          	beq	a0,s8,80004006 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003fa6:	8526                	mv	a0,s1
    80003fa8:	00000097          	auipc	ra,0x0
    80003fac:	75e080e7          	jalr	1886(ra) # 80004706 <log_write>
    brelse(bp);
    80003fb0:	8526                	mv	a0,s1
    80003fb2:	fffff097          	auipc	ra,0xfffff
    80003fb6:	4fc080e7          	jalr	1276(ra) # 800034ae <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003fba:	013d09bb          	addw	s3,s10,s3
    80003fbe:	012d093b          	addw	s2,s10,s2
    80003fc2:	9a6e                	add	s4,s4,s11
    80003fc4:	0569f663          	bgeu	s3,s6,80004010 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003fc8:	00a9559b          	srliw	a1,s2,0xa
    80003fcc:	8556                	mv	a0,s5
    80003fce:	fffff097          	auipc	ra,0xfffff
    80003fd2:	7a2080e7          	jalr	1954(ra) # 80003770 <bmap>
    80003fd6:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003fda:	c99d                	beqz	a1,80004010 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003fdc:	000aa503          	lw	a0,0(s5)
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	39e080e7          	jalr	926(ra) # 8000337e <bread>
    80003fe8:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003fea:	3ff97713          	andi	a4,s2,1023
    80003fee:	40ec87bb          	subw	a5,s9,a4
    80003ff2:	413b06bb          	subw	a3,s6,s3
    80003ff6:	8d3e                	mv	s10,a5
    80003ff8:	2781                	sext.w	a5,a5
    80003ffa:	0006861b          	sext.w	a2,a3
    80003ffe:	f8f674e3          	bgeu	a2,a5,80003f86 <writei+0x4c>
    80004002:	8d36                	mv	s10,a3
    80004004:	b749                	j	80003f86 <writei+0x4c>
      brelse(bp);
    80004006:	8526                	mv	a0,s1
    80004008:	fffff097          	auipc	ra,0xfffff
    8000400c:	4a6080e7          	jalr	1190(ra) # 800034ae <brelse>
  }

  if(off > ip->size)
    80004010:	04caa783          	lw	a5,76(s5)
    80004014:	0127f463          	bgeu	a5,s2,8000401c <writei+0xe2>
    ip->size = off;
    80004018:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    8000401c:	8556                	mv	a0,s5
    8000401e:	00000097          	auipc	ra,0x0
    80004022:	aa4080e7          	jalr	-1372(ra) # 80003ac2 <iupdate>

  return tot;
    80004026:	0009851b          	sext.w	a0,s3
}
    8000402a:	70a6                	ld	ra,104(sp)
    8000402c:	7406                	ld	s0,96(sp)
    8000402e:	64e6                	ld	s1,88(sp)
    80004030:	6946                	ld	s2,80(sp)
    80004032:	69a6                	ld	s3,72(sp)
    80004034:	6a06                	ld	s4,64(sp)
    80004036:	7ae2                	ld	s5,56(sp)
    80004038:	7b42                	ld	s6,48(sp)
    8000403a:	7ba2                	ld	s7,40(sp)
    8000403c:	7c02                	ld	s8,32(sp)
    8000403e:	6ce2                	ld	s9,24(sp)
    80004040:	6d42                	ld	s10,16(sp)
    80004042:	6da2                	ld	s11,8(sp)
    80004044:	6165                	addi	sp,sp,112
    80004046:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80004048:	89da                	mv	s3,s6
    8000404a:	bfc9                	j	8000401c <writei+0xe2>
    return -1;
    8000404c:	557d                	li	a0,-1
}
    8000404e:	8082                	ret
    return -1;
    80004050:	557d                	li	a0,-1
    80004052:	bfe1                	j	8000402a <writei+0xf0>
    return -1;
    80004054:	557d                	li	a0,-1
    80004056:	bfd1                	j	8000402a <writei+0xf0>

0000000080004058 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80004058:	1141                	addi	sp,sp,-16
    8000405a:	e406                	sd	ra,8(sp)
    8000405c:	e022                	sd	s0,0(sp)
    8000405e:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80004060:	4639                	li	a2,14
    80004062:	ffffd097          	auipc	ra,0xffffd
    80004066:	d3c080e7          	jalr	-708(ra) # 80000d9e <strncmp>
}
    8000406a:	60a2                	ld	ra,8(sp)
    8000406c:	6402                	ld	s0,0(sp)
    8000406e:	0141                	addi	sp,sp,16
    80004070:	8082                	ret

0000000080004072 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80004072:	7139                	addi	sp,sp,-64
    80004074:	fc06                	sd	ra,56(sp)
    80004076:	f822                	sd	s0,48(sp)
    80004078:	f426                	sd	s1,40(sp)
    8000407a:	f04a                	sd	s2,32(sp)
    8000407c:	ec4e                	sd	s3,24(sp)
    8000407e:	e852                	sd	s4,16(sp)
    80004080:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80004082:	04451703          	lh	a4,68(a0)
    80004086:	4785                	li	a5,1
    80004088:	00f71a63          	bne	a4,a5,8000409c <dirlookup+0x2a>
    8000408c:	892a                	mv	s2,a0
    8000408e:	89ae                	mv	s3,a1
    80004090:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80004092:	457c                	lw	a5,76(a0)
    80004094:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80004096:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004098:	e79d                	bnez	a5,800040c6 <dirlookup+0x54>
    8000409a:	a8a5                	j	80004112 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    8000409c:	00004517          	auipc	a0,0x4
    800040a0:	63c50513          	addi	a0,a0,1596 # 800086d8 <syscalls+0x1b8>
    800040a4:	ffffc097          	auipc	ra,0xffffc
    800040a8:	498080e7          	jalr	1176(ra) # 8000053c <panic>
      panic("dirlookup read");
    800040ac:	00004517          	auipc	a0,0x4
    800040b0:	64450513          	addi	a0,a0,1604 # 800086f0 <syscalls+0x1d0>
    800040b4:	ffffc097          	auipc	ra,0xffffc
    800040b8:	488080e7          	jalr	1160(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800040bc:	24c1                	addiw	s1,s1,16
    800040be:	04c92783          	lw	a5,76(s2)
    800040c2:	04f4f763          	bgeu	s1,a5,80004110 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800040c6:	4741                	li	a4,16
    800040c8:	86a6                	mv	a3,s1
    800040ca:	fc040613          	addi	a2,s0,-64
    800040ce:	4581                	li	a1,0
    800040d0:	854a                	mv	a0,s2
    800040d2:	00000097          	auipc	ra,0x0
    800040d6:	d70080e7          	jalr	-656(ra) # 80003e42 <readi>
    800040da:	47c1                	li	a5,16
    800040dc:	fcf518e3          	bne	a0,a5,800040ac <dirlookup+0x3a>
    if(de.inum == 0)
    800040e0:	fc045783          	lhu	a5,-64(s0)
    800040e4:	dfe1                	beqz	a5,800040bc <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    800040e6:	fc240593          	addi	a1,s0,-62
    800040ea:	854e                	mv	a0,s3
    800040ec:	00000097          	auipc	ra,0x0
    800040f0:	f6c080e7          	jalr	-148(ra) # 80004058 <namecmp>
    800040f4:	f561                	bnez	a0,800040bc <dirlookup+0x4a>
      if(poff)
    800040f6:	000a0463          	beqz	s4,800040fe <dirlookup+0x8c>
        *poff = off;
    800040fa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    800040fe:	fc045583          	lhu	a1,-64(s0)
    80004102:	00092503          	lw	a0,0(s2)
    80004106:	fffff097          	auipc	ra,0xfffff
    8000410a:	754080e7          	jalr	1876(ra) # 8000385a <iget>
    8000410e:	a011                	j	80004112 <dirlookup+0xa0>
  return 0;
    80004110:	4501                	li	a0,0
}
    80004112:	70e2                	ld	ra,56(sp)
    80004114:	7442                	ld	s0,48(sp)
    80004116:	74a2                	ld	s1,40(sp)
    80004118:	7902                	ld	s2,32(sp)
    8000411a:	69e2                	ld	s3,24(sp)
    8000411c:	6a42                	ld	s4,16(sp)
    8000411e:	6121                	addi	sp,sp,64
    80004120:	8082                	ret

0000000080004122 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80004122:	711d                	addi	sp,sp,-96
    80004124:	ec86                	sd	ra,88(sp)
    80004126:	e8a2                	sd	s0,80(sp)
    80004128:	e4a6                	sd	s1,72(sp)
    8000412a:	e0ca                	sd	s2,64(sp)
    8000412c:	fc4e                	sd	s3,56(sp)
    8000412e:	f852                	sd	s4,48(sp)
    80004130:	f456                	sd	s5,40(sp)
    80004132:	f05a                	sd	s6,32(sp)
    80004134:	ec5e                	sd	s7,24(sp)
    80004136:	e862                	sd	s8,16(sp)
    80004138:	e466                	sd	s9,8(sp)
    8000413a:	1080                	addi	s0,sp,96
    8000413c:	84aa                	mv	s1,a0
    8000413e:	8b2e                	mv	s6,a1
    80004140:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80004142:	00054703          	lbu	a4,0(a0)
    80004146:	02f00793          	li	a5,47
    8000414a:	02f70263          	beq	a4,a5,8000416e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    8000414e:	ffffe097          	auipc	ra,0xffffe
    80004152:	b0e080e7          	jalr	-1266(ra) # 80001c5c <myproc>
    80004156:	15053503          	ld	a0,336(a0)
    8000415a:	00000097          	auipc	ra,0x0
    8000415e:	9f6080e7          	jalr	-1546(ra) # 80003b50 <idup>
    80004162:	8a2a                	mv	s4,a0
  while(*path == '/')
    80004164:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80004168:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    8000416a:	4b85                	li	s7,1
    8000416c:	a875                	j	80004228 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    8000416e:	4585                	li	a1,1
    80004170:	4505                	li	a0,1
    80004172:	fffff097          	auipc	ra,0xfffff
    80004176:	6e8080e7          	jalr	1768(ra) # 8000385a <iget>
    8000417a:	8a2a                	mv	s4,a0
    8000417c:	b7e5                	j	80004164 <namex+0x42>
      iunlockput(ip);
    8000417e:	8552                	mv	a0,s4
    80004180:	00000097          	auipc	ra,0x0
    80004184:	c70080e7          	jalr	-912(ra) # 80003df0 <iunlockput>
      return 0;
    80004188:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    8000418a:	8552                	mv	a0,s4
    8000418c:	60e6                	ld	ra,88(sp)
    8000418e:	6446                	ld	s0,80(sp)
    80004190:	64a6                	ld	s1,72(sp)
    80004192:	6906                	ld	s2,64(sp)
    80004194:	79e2                	ld	s3,56(sp)
    80004196:	7a42                	ld	s4,48(sp)
    80004198:	7aa2                	ld	s5,40(sp)
    8000419a:	7b02                	ld	s6,32(sp)
    8000419c:	6be2                	ld	s7,24(sp)
    8000419e:	6c42                	ld	s8,16(sp)
    800041a0:	6ca2                	ld	s9,8(sp)
    800041a2:	6125                	addi	sp,sp,96
    800041a4:	8082                	ret
      iunlock(ip);
    800041a6:	8552                	mv	a0,s4
    800041a8:	00000097          	auipc	ra,0x0
    800041ac:	aa8080e7          	jalr	-1368(ra) # 80003c50 <iunlock>
      return ip;
    800041b0:	bfe9                	j	8000418a <namex+0x68>
      iunlockput(ip);
    800041b2:	8552                	mv	a0,s4
    800041b4:	00000097          	auipc	ra,0x0
    800041b8:	c3c080e7          	jalr	-964(ra) # 80003df0 <iunlockput>
      return 0;
    800041bc:	8a4e                	mv	s4,s3
    800041be:	b7f1                	j	8000418a <namex+0x68>
  len = path - s;
    800041c0:	40998633          	sub	a2,s3,s1
    800041c4:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    800041c8:	099c5863          	bge	s8,s9,80004258 <namex+0x136>
    memmove(name, s, DIRSIZ);
    800041cc:	4639                	li	a2,14
    800041ce:	85a6                	mv	a1,s1
    800041d0:	8556                	mv	a0,s5
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	b58080e7          	jalr	-1192(ra) # 80000d2a <memmove>
    800041da:	84ce                	mv	s1,s3
  while(*path == '/')
    800041dc:	0004c783          	lbu	a5,0(s1)
    800041e0:	01279763          	bne	a5,s2,800041ee <namex+0xcc>
    path++;
    800041e4:	0485                	addi	s1,s1,1
  while(*path == '/')
    800041e6:	0004c783          	lbu	a5,0(s1)
    800041ea:	ff278de3          	beq	a5,s2,800041e4 <namex+0xc2>
    ilock(ip);
    800041ee:	8552                	mv	a0,s4
    800041f0:	00000097          	auipc	ra,0x0
    800041f4:	99e080e7          	jalr	-1634(ra) # 80003b8e <ilock>
    if(ip->type != T_DIR){
    800041f8:	044a1783          	lh	a5,68(s4)
    800041fc:	f97791e3          	bne	a5,s7,8000417e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80004200:	000b0563          	beqz	s6,8000420a <namex+0xe8>
    80004204:	0004c783          	lbu	a5,0(s1)
    80004208:	dfd9                	beqz	a5,800041a6 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000420a:	4601                	li	a2,0
    8000420c:	85d6                	mv	a1,s5
    8000420e:	8552                	mv	a0,s4
    80004210:	00000097          	auipc	ra,0x0
    80004214:	e62080e7          	jalr	-414(ra) # 80004072 <dirlookup>
    80004218:	89aa                	mv	s3,a0
    8000421a:	dd41                	beqz	a0,800041b2 <namex+0x90>
    iunlockput(ip);
    8000421c:	8552                	mv	a0,s4
    8000421e:	00000097          	auipc	ra,0x0
    80004222:	bd2080e7          	jalr	-1070(ra) # 80003df0 <iunlockput>
    ip = next;
    80004226:	8a4e                	mv	s4,s3
  while(*path == '/')
    80004228:	0004c783          	lbu	a5,0(s1)
    8000422c:	01279763          	bne	a5,s2,8000423a <namex+0x118>
    path++;
    80004230:	0485                	addi	s1,s1,1
  while(*path == '/')
    80004232:	0004c783          	lbu	a5,0(s1)
    80004236:	ff278de3          	beq	a5,s2,80004230 <namex+0x10e>
  if(*path == 0)
    8000423a:	cb9d                	beqz	a5,80004270 <namex+0x14e>
  while(*path != '/' && *path != 0)
    8000423c:	0004c783          	lbu	a5,0(s1)
    80004240:	89a6                	mv	s3,s1
  len = path - s;
    80004242:	4c81                	li	s9,0
    80004244:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80004246:	01278963          	beq	a5,s2,80004258 <namex+0x136>
    8000424a:	dbbd                	beqz	a5,800041c0 <namex+0x9e>
    path++;
    8000424c:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    8000424e:	0009c783          	lbu	a5,0(s3)
    80004252:	ff279ce3          	bne	a5,s2,8000424a <namex+0x128>
    80004256:	b7ad                	j	800041c0 <namex+0x9e>
    memmove(name, s, len);
    80004258:	2601                	sext.w	a2,a2
    8000425a:	85a6                	mv	a1,s1
    8000425c:	8556                	mv	a0,s5
    8000425e:	ffffd097          	auipc	ra,0xffffd
    80004262:	acc080e7          	jalr	-1332(ra) # 80000d2a <memmove>
    name[len] = 0;
    80004266:	9cd6                	add	s9,s9,s5
    80004268:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    8000426c:	84ce                	mv	s1,s3
    8000426e:	b7bd                	j	800041dc <namex+0xba>
  if(nameiparent){
    80004270:	f00b0de3          	beqz	s6,8000418a <namex+0x68>
    iput(ip);
    80004274:	8552                	mv	a0,s4
    80004276:	00000097          	auipc	ra,0x0
    8000427a:	ad2080e7          	jalr	-1326(ra) # 80003d48 <iput>
    return 0;
    8000427e:	4a01                	li	s4,0
    80004280:	b729                	j	8000418a <namex+0x68>

0000000080004282 <dirlink>:
{
    80004282:	7139                	addi	sp,sp,-64
    80004284:	fc06                	sd	ra,56(sp)
    80004286:	f822                	sd	s0,48(sp)
    80004288:	f426                	sd	s1,40(sp)
    8000428a:	f04a                	sd	s2,32(sp)
    8000428c:	ec4e                	sd	s3,24(sp)
    8000428e:	e852                	sd	s4,16(sp)
    80004290:	0080                	addi	s0,sp,64
    80004292:	892a                	mv	s2,a0
    80004294:	8a2e                	mv	s4,a1
    80004296:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80004298:	4601                	li	a2,0
    8000429a:	00000097          	auipc	ra,0x0
    8000429e:	dd8080e7          	jalr	-552(ra) # 80004072 <dirlookup>
    800042a2:	e93d                	bnez	a0,80004318 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042a4:	04c92483          	lw	s1,76(s2)
    800042a8:	c49d                	beqz	s1,800042d6 <dirlink+0x54>
    800042aa:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ac:	4741                	li	a4,16
    800042ae:	86a6                	mv	a3,s1
    800042b0:	fc040613          	addi	a2,s0,-64
    800042b4:	4581                	li	a1,0
    800042b6:	854a                	mv	a0,s2
    800042b8:	00000097          	auipc	ra,0x0
    800042bc:	b8a080e7          	jalr	-1142(ra) # 80003e42 <readi>
    800042c0:	47c1                	li	a5,16
    800042c2:	06f51163          	bne	a0,a5,80004324 <dirlink+0xa2>
    if(de.inum == 0)
    800042c6:	fc045783          	lhu	a5,-64(s0)
    800042ca:	c791                	beqz	a5,800042d6 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800042cc:	24c1                	addiw	s1,s1,16
    800042ce:	04c92783          	lw	a5,76(s2)
    800042d2:	fcf4ede3          	bltu	s1,a5,800042ac <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    800042d6:	4639                	li	a2,14
    800042d8:	85d2                	mv	a1,s4
    800042da:	fc240513          	addi	a0,s0,-62
    800042de:	ffffd097          	auipc	ra,0xffffd
    800042e2:	afc080e7          	jalr	-1284(ra) # 80000dda <strncpy>
  de.inum = inum;
    800042e6:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800042ea:	4741                	li	a4,16
    800042ec:	86a6                	mv	a3,s1
    800042ee:	fc040613          	addi	a2,s0,-64
    800042f2:	4581                	li	a1,0
    800042f4:	854a                	mv	a0,s2
    800042f6:	00000097          	auipc	ra,0x0
    800042fa:	c44080e7          	jalr	-956(ra) # 80003f3a <writei>
    800042fe:	1541                	addi	a0,a0,-16
    80004300:	00a03533          	snez	a0,a0
    80004304:	40a00533          	neg	a0,a0
}
    80004308:	70e2                	ld	ra,56(sp)
    8000430a:	7442                	ld	s0,48(sp)
    8000430c:	74a2                	ld	s1,40(sp)
    8000430e:	7902                	ld	s2,32(sp)
    80004310:	69e2                	ld	s3,24(sp)
    80004312:	6a42                	ld	s4,16(sp)
    80004314:	6121                	addi	sp,sp,64
    80004316:	8082                	ret
    iput(ip);
    80004318:	00000097          	auipc	ra,0x0
    8000431c:	a30080e7          	jalr	-1488(ra) # 80003d48 <iput>
    return -1;
    80004320:	557d                	li	a0,-1
    80004322:	b7dd                	j	80004308 <dirlink+0x86>
      panic("dirlink read");
    80004324:	00004517          	auipc	a0,0x4
    80004328:	3dc50513          	addi	a0,a0,988 # 80008700 <syscalls+0x1e0>
    8000432c:	ffffc097          	auipc	ra,0xffffc
    80004330:	210080e7          	jalr	528(ra) # 8000053c <panic>

0000000080004334 <namei>:

struct inode*
namei(char *path)
{
    80004334:	1101                	addi	sp,sp,-32
    80004336:	ec06                	sd	ra,24(sp)
    80004338:	e822                	sd	s0,16(sp)
    8000433a:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    8000433c:	fe040613          	addi	a2,s0,-32
    80004340:	4581                	li	a1,0
    80004342:	00000097          	auipc	ra,0x0
    80004346:	de0080e7          	jalr	-544(ra) # 80004122 <namex>
}
    8000434a:	60e2                	ld	ra,24(sp)
    8000434c:	6442                	ld	s0,16(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret

0000000080004352 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80004352:	1141                	addi	sp,sp,-16
    80004354:	e406                	sd	ra,8(sp)
    80004356:	e022                	sd	s0,0(sp)
    80004358:	0800                	addi	s0,sp,16
    8000435a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    8000435c:	4585                	li	a1,1
    8000435e:	00000097          	auipc	ra,0x0
    80004362:	dc4080e7          	jalr	-572(ra) # 80004122 <namex>
}
    80004366:	60a2                	ld	ra,8(sp)
    80004368:	6402                	ld	s0,0(sp)
    8000436a:	0141                	addi	sp,sp,16
    8000436c:	8082                	ret

000000008000436e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    8000436e:	1101                	addi	sp,sp,-32
    80004370:	ec06                	sd	ra,24(sp)
    80004372:	e822                	sd	s0,16(sp)
    80004374:	e426                	sd	s1,8(sp)
    80004376:	e04a                	sd	s2,0(sp)
    80004378:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    8000437a:	0001d917          	auipc	s2,0x1d
    8000437e:	9c690913          	addi	s2,s2,-1594 # 80020d40 <log>
    80004382:	01892583          	lw	a1,24(s2)
    80004386:	02892503          	lw	a0,40(s2)
    8000438a:	fffff097          	auipc	ra,0xfffff
    8000438e:	ff4080e7          	jalr	-12(ra) # 8000337e <bread>
    80004392:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80004394:	02c92603          	lw	a2,44(s2)
    80004398:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    8000439a:	00c05f63          	blez	a2,800043b8 <write_head+0x4a>
    8000439e:	0001d717          	auipc	a4,0x1d
    800043a2:	9d270713          	addi	a4,a4,-1582 # 80020d70 <log+0x30>
    800043a6:	87aa                	mv	a5,a0
    800043a8:	060a                	slli	a2,a2,0x2
    800043aa:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800043ac:	4314                	lw	a3,0(a4)
    800043ae:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800043b0:	0711                	addi	a4,a4,4
    800043b2:	0791                	addi	a5,a5,4
    800043b4:	fec79ce3          	bne	a5,a2,800043ac <write_head+0x3e>
  }
  bwrite(buf);
    800043b8:	8526                	mv	a0,s1
    800043ba:	fffff097          	auipc	ra,0xfffff
    800043be:	0b6080e7          	jalr	182(ra) # 80003470 <bwrite>
  brelse(buf);
    800043c2:	8526                	mv	a0,s1
    800043c4:	fffff097          	auipc	ra,0xfffff
    800043c8:	0ea080e7          	jalr	234(ra) # 800034ae <brelse>
}
    800043cc:	60e2                	ld	ra,24(sp)
    800043ce:	6442                	ld	s0,16(sp)
    800043d0:	64a2                	ld	s1,8(sp)
    800043d2:	6902                	ld	s2,0(sp)
    800043d4:	6105                	addi	sp,sp,32
    800043d6:	8082                	ret

00000000800043d8 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800043d8:	0001d797          	auipc	a5,0x1d
    800043dc:	9947a783          	lw	a5,-1644(a5) # 80020d6c <log+0x2c>
    800043e0:	0af05d63          	blez	a5,8000449a <install_trans+0xc2>
{
    800043e4:	7139                	addi	sp,sp,-64
    800043e6:	fc06                	sd	ra,56(sp)
    800043e8:	f822                	sd	s0,48(sp)
    800043ea:	f426                	sd	s1,40(sp)
    800043ec:	f04a                	sd	s2,32(sp)
    800043ee:	ec4e                	sd	s3,24(sp)
    800043f0:	e852                	sd	s4,16(sp)
    800043f2:	e456                	sd	s5,8(sp)
    800043f4:	e05a                	sd	s6,0(sp)
    800043f6:	0080                	addi	s0,sp,64
    800043f8:	8b2a                	mv	s6,a0
    800043fa:	0001da97          	auipc	s5,0x1d
    800043fe:	976a8a93          	addi	s5,s5,-1674 # 80020d70 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004402:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004404:	0001d997          	auipc	s3,0x1d
    80004408:	93c98993          	addi	s3,s3,-1732 # 80020d40 <log>
    8000440c:	a00d                	j	8000442e <install_trans+0x56>
    brelse(lbuf);
    8000440e:	854a                	mv	a0,s2
    80004410:	fffff097          	auipc	ra,0xfffff
    80004414:	09e080e7          	jalr	158(ra) # 800034ae <brelse>
    brelse(dbuf);
    80004418:	8526                	mv	a0,s1
    8000441a:	fffff097          	auipc	ra,0xfffff
    8000441e:	094080e7          	jalr	148(ra) # 800034ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004422:	2a05                	addiw	s4,s4,1
    80004424:	0a91                	addi	s5,s5,4
    80004426:	02c9a783          	lw	a5,44(s3)
    8000442a:	04fa5e63          	bge	s4,a5,80004486 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000442e:	0189a583          	lw	a1,24(s3)
    80004432:	014585bb          	addw	a1,a1,s4
    80004436:	2585                	addiw	a1,a1,1
    80004438:	0289a503          	lw	a0,40(s3)
    8000443c:	fffff097          	auipc	ra,0xfffff
    80004440:	f42080e7          	jalr	-190(ra) # 8000337e <bread>
    80004444:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004446:	000aa583          	lw	a1,0(s5)
    8000444a:	0289a503          	lw	a0,40(s3)
    8000444e:	fffff097          	auipc	ra,0xfffff
    80004452:	f30080e7          	jalr	-208(ra) # 8000337e <bread>
    80004456:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004458:	40000613          	li	a2,1024
    8000445c:	05890593          	addi	a1,s2,88
    80004460:	05850513          	addi	a0,a0,88
    80004464:	ffffd097          	auipc	ra,0xffffd
    80004468:	8c6080e7          	jalr	-1850(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000446c:	8526                	mv	a0,s1
    8000446e:	fffff097          	auipc	ra,0xfffff
    80004472:	002080e7          	jalr	2(ra) # 80003470 <bwrite>
    if(recovering == 0)
    80004476:	f80b1ce3          	bnez	s6,8000440e <install_trans+0x36>
      bunpin(dbuf);
    8000447a:	8526                	mv	a0,s1
    8000447c:	fffff097          	auipc	ra,0xfffff
    80004480:	10a080e7          	jalr	266(ra) # 80003586 <bunpin>
    80004484:	b769                	j	8000440e <install_trans+0x36>
}
    80004486:	70e2                	ld	ra,56(sp)
    80004488:	7442                	ld	s0,48(sp)
    8000448a:	74a2                	ld	s1,40(sp)
    8000448c:	7902                	ld	s2,32(sp)
    8000448e:	69e2                	ld	s3,24(sp)
    80004490:	6a42                	ld	s4,16(sp)
    80004492:	6aa2                	ld	s5,8(sp)
    80004494:	6b02                	ld	s6,0(sp)
    80004496:	6121                	addi	sp,sp,64
    80004498:	8082                	ret
    8000449a:	8082                	ret

000000008000449c <initlog>:
{
    8000449c:	7179                	addi	sp,sp,-48
    8000449e:	f406                	sd	ra,40(sp)
    800044a0:	f022                	sd	s0,32(sp)
    800044a2:	ec26                	sd	s1,24(sp)
    800044a4:	e84a                	sd	s2,16(sp)
    800044a6:	e44e                	sd	s3,8(sp)
    800044a8:	1800                	addi	s0,sp,48
    800044aa:	892a                	mv	s2,a0
    800044ac:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800044ae:	0001d497          	auipc	s1,0x1d
    800044b2:	89248493          	addi	s1,s1,-1902 # 80020d40 <log>
    800044b6:	00004597          	auipc	a1,0x4
    800044ba:	25a58593          	addi	a1,a1,602 # 80008710 <syscalls+0x1f0>
    800044be:	8526                	mv	a0,s1
    800044c0:	ffffc097          	auipc	ra,0xffffc
    800044c4:	682080e7          	jalr	1666(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800044c8:	0149a583          	lw	a1,20(s3)
    800044cc:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800044ce:	0109a783          	lw	a5,16(s3)
    800044d2:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800044d4:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800044d8:	854a                	mv	a0,s2
    800044da:	fffff097          	auipc	ra,0xfffff
    800044de:	ea4080e7          	jalr	-348(ra) # 8000337e <bread>
  log.lh.n = lh->n;
    800044e2:	4d30                	lw	a2,88(a0)
    800044e4:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    800044e6:	00c05f63          	blez	a2,80004504 <initlog+0x68>
    800044ea:	87aa                	mv	a5,a0
    800044ec:	0001d717          	auipc	a4,0x1d
    800044f0:	88470713          	addi	a4,a4,-1916 # 80020d70 <log+0x30>
    800044f4:	060a                	slli	a2,a2,0x2
    800044f6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800044f8:	4ff4                	lw	a3,92(a5)
    800044fa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800044fc:	0791                	addi	a5,a5,4
    800044fe:	0711                	addi	a4,a4,4
    80004500:	fec79ce3          	bne	a5,a2,800044f8 <initlog+0x5c>
  brelse(buf);
    80004504:	fffff097          	auipc	ra,0xfffff
    80004508:	faa080e7          	jalr	-86(ra) # 800034ae <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    8000450c:	4505                	li	a0,1
    8000450e:	00000097          	auipc	ra,0x0
    80004512:	eca080e7          	jalr	-310(ra) # 800043d8 <install_trans>
  log.lh.n = 0;
    80004516:	0001d797          	auipc	a5,0x1d
    8000451a:	8407ab23          	sw	zero,-1962(a5) # 80020d6c <log+0x2c>
  write_head(); // clear the log
    8000451e:	00000097          	auipc	ra,0x0
    80004522:	e50080e7          	jalr	-432(ra) # 8000436e <write_head>
}
    80004526:	70a2                	ld	ra,40(sp)
    80004528:	7402                	ld	s0,32(sp)
    8000452a:	64e2                	ld	s1,24(sp)
    8000452c:	6942                	ld	s2,16(sp)
    8000452e:	69a2                	ld	s3,8(sp)
    80004530:	6145                	addi	sp,sp,48
    80004532:	8082                	ret

0000000080004534 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80004534:	1101                	addi	sp,sp,-32
    80004536:	ec06                	sd	ra,24(sp)
    80004538:	e822                	sd	s0,16(sp)
    8000453a:	e426                	sd	s1,8(sp)
    8000453c:	e04a                	sd	s2,0(sp)
    8000453e:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80004540:	0001d517          	auipc	a0,0x1d
    80004544:	80050513          	addi	a0,a0,-2048 # 80020d40 <log>
    80004548:	ffffc097          	auipc	ra,0xffffc
    8000454c:	68a080e7          	jalr	1674(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004550:	0001c497          	auipc	s1,0x1c
    80004554:	7f048493          	addi	s1,s1,2032 # 80020d40 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004558:	4979                	li	s2,30
    8000455a:	a039                	j	80004568 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000455c:	85a6                	mv	a1,s1
    8000455e:	8526                	mv	a0,s1
    80004560:	ffffe097          	auipc	ra,0xffffe
    80004564:	e84080e7          	jalr	-380(ra) # 800023e4 <sleep>
    if(log.committing){
    80004568:	50dc                	lw	a5,36(s1)
    8000456a:	fbed                	bnez	a5,8000455c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000456c:	5098                	lw	a4,32(s1)
    8000456e:	2705                	addiw	a4,a4,1
    80004570:	0027179b          	slliw	a5,a4,0x2
    80004574:	9fb9                	addw	a5,a5,a4
    80004576:	0017979b          	slliw	a5,a5,0x1
    8000457a:	54d4                	lw	a3,44(s1)
    8000457c:	9fb5                	addw	a5,a5,a3
    8000457e:	00f95963          	bge	s2,a5,80004590 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004582:	85a6                	mv	a1,s1
    80004584:	8526                	mv	a0,s1
    80004586:	ffffe097          	auipc	ra,0xffffe
    8000458a:	e5e080e7          	jalr	-418(ra) # 800023e4 <sleep>
    8000458e:	bfe9                	j	80004568 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004590:	0001c517          	auipc	a0,0x1c
    80004594:	7b050513          	addi	a0,a0,1968 # 80020d40 <log>
    80004598:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000459a:	ffffc097          	auipc	ra,0xffffc
    8000459e:	6ec080e7          	jalr	1772(ra) # 80000c86 <release>
      break;
    }
  }
}
    800045a2:	60e2                	ld	ra,24(sp)
    800045a4:	6442                	ld	s0,16(sp)
    800045a6:	64a2                	ld	s1,8(sp)
    800045a8:	6902                	ld	s2,0(sp)
    800045aa:	6105                	addi	sp,sp,32
    800045ac:	8082                	ret

00000000800045ae <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800045ae:	7139                	addi	sp,sp,-64
    800045b0:	fc06                	sd	ra,56(sp)
    800045b2:	f822                	sd	s0,48(sp)
    800045b4:	f426                	sd	s1,40(sp)
    800045b6:	f04a                	sd	s2,32(sp)
    800045b8:	ec4e                	sd	s3,24(sp)
    800045ba:	e852                	sd	s4,16(sp)
    800045bc:	e456                	sd	s5,8(sp)
    800045be:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800045c0:	0001c497          	auipc	s1,0x1c
    800045c4:	78048493          	addi	s1,s1,1920 # 80020d40 <log>
    800045c8:	8526                	mv	a0,s1
    800045ca:	ffffc097          	auipc	ra,0xffffc
    800045ce:	608080e7          	jalr	1544(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800045d2:	509c                	lw	a5,32(s1)
    800045d4:	37fd                	addiw	a5,a5,-1
    800045d6:	0007891b          	sext.w	s2,a5
    800045da:	d09c                	sw	a5,32(s1)
  if(log.committing)
    800045dc:	50dc                	lw	a5,36(s1)
    800045de:	e7b9                	bnez	a5,8000462c <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    800045e0:	04091e63          	bnez	s2,8000463c <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    800045e4:	0001c497          	auipc	s1,0x1c
    800045e8:	75c48493          	addi	s1,s1,1884 # 80020d40 <log>
    800045ec:	4785                	li	a5,1
    800045ee:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800045f0:	8526                	mv	a0,s1
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	694080e7          	jalr	1684(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800045fa:	54dc                	lw	a5,44(s1)
    800045fc:	06f04763          	bgtz	a5,8000466a <end_op+0xbc>
    acquire(&log.lock);
    80004600:	0001c497          	auipc	s1,0x1c
    80004604:	74048493          	addi	s1,s1,1856 # 80020d40 <log>
    80004608:	8526                	mv	a0,s1
    8000460a:	ffffc097          	auipc	ra,0xffffc
    8000460e:	5c8080e7          	jalr	1480(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004612:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004616:	8526                	mv	a0,s1
    80004618:	ffffe097          	auipc	ra,0xffffe
    8000461c:	e30080e7          	jalr	-464(ra) # 80002448 <wakeup>
    release(&log.lock);
    80004620:	8526                	mv	a0,s1
    80004622:	ffffc097          	auipc	ra,0xffffc
    80004626:	664080e7          	jalr	1636(ra) # 80000c86 <release>
}
    8000462a:	a03d                	j	80004658 <end_op+0xaa>
    panic("log.committing");
    8000462c:	00004517          	auipc	a0,0x4
    80004630:	0ec50513          	addi	a0,a0,236 # 80008718 <syscalls+0x1f8>
    80004634:	ffffc097          	auipc	ra,0xffffc
    80004638:	f08080e7          	jalr	-248(ra) # 8000053c <panic>
    wakeup(&log);
    8000463c:	0001c497          	auipc	s1,0x1c
    80004640:	70448493          	addi	s1,s1,1796 # 80020d40 <log>
    80004644:	8526                	mv	a0,s1
    80004646:	ffffe097          	auipc	ra,0xffffe
    8000464a:	e02080e7          	jalr	-510(ra) # 80002448 <wakeup>
  release(&log.lock);
    8000464e:	8526                	mv	a0,s1
    80004650:	ffffc097          	auipc	ra,0xffffc
    80004654:	636080e7          	jalr	1590(ra) # 80000c86 <release>
}
    80004658:	70e2                	ld	ra,56(sp)
    8000465a:	7442                	ld	s0,48(sp)
    8000465c:	74a2                	ld	s1,40(sp)
    8000465e:	7902                	ld	s2,32(sp)
    80004660:	69e2                	ld	s3,24(sp)
    80004662:	6a42                	ld	s4,16(sp)
    80004664:	6aa2                	ld	s5,8(sp)
    80004666:	6121                	addi	sp,sp,64
    80004668:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000466a:	0001ca97          	auipc	s5,0x1c
    8000466e:	706a8a93          	addi	s5,s5,1798 # 80020d70 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004672:	0001ca17          	auipc	s4,0x1c
    80004676:	6cea0a13          	addi	s4,s4,1742 # 80020d40 <log>
    8000467a:	018a2583          	lw	a1,24(s4)
    8000467e:	012585bb          	addw	a1,a1,s2
    80004682:	2585                	addiw	a1,a1,1
    80004684:	028a2503          	lw	a0,40(s4)
    80004688:	fffff097          	auipc	ra,0xfffff
    8000468c:	cf6080e7          	jalr	-778(ra) # 8000337e <bread>
    80004690:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004692:	000aa583          	lw	a1,0(s5)
    80004696:	028a2503          	lw	a0,40(s4)
    8000469a:	fffff097          	auipc	ra,0xfffff
    8000469e:	ce4080e7          	jalr	-796(ra) # 8000337e <bread>
    800046a2:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800046a4:	40000613          	li	a2,1024
    800046a8:	05850593          	addi	a1,a0,88
    800046ac:	05848513          	addi	a0,s1,88
    800046b0:	ffffc097          	auipc	ra,0xffffc
    800046b4:	67a080e7          	jalr	1658(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800046b8:	8526                	mv	a0,s1
    800046ba:	fffff097          	auipc	ra,0xfffff
    800046be:	db6080e7          	jalr	-586(ra) # 80003470 <bwrite>
    brelse(from);
    800046c2:	854e                	mv	a0,s3
    800046c4:	fffff097          	auipc	ra,0xfffff
    800046c8:	dea080e7          	jalr	-534(ra) # 800034ae <brelse>
    brelse(to);
    800046cc:	8526                	mv	a0,s1
    800046ce:	fffff097          	auipc	ra,0xfffff
    800046d2:	de0080e7          	jalr	-544(ra) # 800034ae <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800046d6:	2905                	addiw	s2,s2,1
    800046d8:	0a91                	addi	s5,s5,4
    800046da:	02ca2783          	lw	a5,44(s4)
    800046de:	f8f94ee3          	blt	s2,a5,8000467a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    800046e2:	00000097          	auipc	ra,0x0
    800046e6:	c8c080e7          	jalr	-884(ra) # 8000436e <write_head>
    install_trans(0); // Now install writes to home locations
    800046ea:	4501                	li	a0,0
    800046ec:	00000097          	auipc	ra,0x0
    800046f0:	cec080e7          	jalr	-788(ra) # 800043d8 <install_trans>
    log.lh.n = 0;
    800046f4:	0001c797          	auipc	a5,0x1c
    800046f8:	6607ac23          	sw	zero,1656(a5) # 80020d6c <log+0x2c>
    write_head();    // Erase the transaction from the log
    800046fc:	00000097          	auipc	ra,0x0
    80004700:	c72080e7          	jalr	-910(ra) # 8000436e <write_head>
    80004704:	bdf5                	j	80004600 <end_op+0x52>

0000000080004706 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004706:	1101                	addi	sp,sp,-32
    80004708:	ec06                	sd	ra,24(sp)
    8000470a:	e822                	sd	s0,16(sp)
    8000470c:	e426                	sd	s1,8(sp)
    8000470e:	e04a                	sd	s2,0(sp)
    80004710:	1000                	addi	s0,sp,32
    80004712:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80004714:	0001c917          	auipc	s2,0x1c
    80004718:	62c90913          	addi	s2,s2,1580 # 80020d40 <log>
    8000471c:	854a                	mv	a0,s2
    8000471e:	ffffc097          	auipc	ra,0xffffc
    80004722:	4b4080e7          	jalr	1204(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004726:	02c92603          	lw	a2,44(s2)
    8000472a:	47f5                	li	a5,29
    8000472c:	06c7c563          	blt	a5,a2,80004796 <log_write+0x90>
    80004730:	0001c797          	auipc	a5,0x1c
    80004734:	62c7a783          	lw	a5,1580(a5) # 80020d5c <log+0x1c>
    80004738:	37fd                	addiw	a5,a5,-1
    8000473a:	04f65e63          	bge	a2,a5,80004796 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    8000473e:	0001c797          	auipc	a5,0x1c
    80004742:	6227a783          	lw	a5,1570(a5) # 80020d60 <log+0x20>
    80004746:	06f05063          	blez	a5,800047a6 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    8000474a:	4781                	li	a5,0
    8000474c:	06c05563          	blez	a2,800047b6 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004750:	44cc                	lw	a1,12(s1)
    80004752:	0001c717          	auipc	a4,0x1c
    80004756:	61e70713          	addi	a4,a4,1566 # 80020d70 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000475a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000475c:	4314                	lw	a3,0(a4)
    8000475e:	04b68c63          	beq	a3,a1,800047b6 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004762:	2785                	addiw	a5,a5,1
    80004764:	0711                	addi	a4,a4,4
    80004766:	fef61be3          	bne	a2,a5,8000475c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000476a:	0621                	addi	a2,a2,8
    8000476c:	060a                	slli	a2,a2,0x2
    8000476e:	0001c797          	auipc	a5,0x1c
    80004772:	5d278793          	addi	a5,a5,1490 # 80020d40 <log>
    80004776:	97b2                	add	a5,a5,a2
    80004778:	44d8                	lw	a4,12(s1)
    8000477a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000477c:	8526                	mv	a0,s1
    8000477e:	fffff097          	auipc	ra,0xfffff
    80004782:	dcc080e7          	jalr	-564(ra) # 8000354a <bpin>
    log.lh.n++;
    80004786:	0001c717          	auipc	a4,0x1c
    8000478a:	5ba70713          	addi	a4,a4,1466 # 80020d40 <log>
    8000478e:	575c                	lw	a5,44(a4)
    80004790:	2785                	addiw	a5,a5,1
    80004792:	d75c                	sw	a5,44(a4)
    80004794:	a82d                	j	800047ce <log_write+0xc8>
    panic("too big a transaction");
    80004796:	00004517          	auipc	a0,0x4
    8000479a:	f9250513          	addi	a0,a0,-110 # 80008728 <syscalls+0x208>
    8000479e:	ffffc097          	auipc	ra,0xffffc
    800047a2:	d9e080e7          	jalr	-610(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800047a6:	00004517          	auipc	a0,0x4
    800047aa:	f9a50513          	addi	a0,a0,-102 # 80008740 <syscalls+0x220>
    800047ae:	ffffc097          	auipc	ra,0xffffc
    800047b2:	d8e080e7          	jalr	-626(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800047b6:	00878693          	addi	a3,a5,8
    800047ba:	068a                	slli	a3,a3,0x2
    800047bc:	0001c717          	auipc	a4,0x1c
    800047c0:	58470713          	addi	a4,a4,1412 # 80020d40 <log>
    800047c4:	9736                	add	a4,a4,a3
    800047c6:	44d4                	lw	a3,12(s1)
    800047c8:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800047ca:	faf609e3          	beq	a2,a5,8000477c <log_write+0x76>
  }
  release(&log.lock);
    800047ce:	0001c517          	auipc	a0,0x1c
    800047d2:	57250513          	addi	a0,a0,1394 # 80020d40 <log>
    800047d6:	ffffc097          	auipc	ra,0xffffc
    800047da:	4b0080e7          	jalr	1200(ra) # 80000c86 <release>
}
    800047de:	60e2                	ld	ra,24(sp)
    800047e0:	6442                	ld	s0,16(sp)
    800047e2:	64a2                	ld	s1,8(sp)
    800047e4:	6902                	ld	s2,0(sp)
    800047e6:	6105                	addi	sp,sp,32
    800047e8:	8082                	ret

00000000800047ea <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800047ea:	1101                	addi	sp,sp,-32
    800047ec:	ec06                	sd	ra,24(sp)
    800047ee:	e822                	sd	s0,16(sp)
    800047f0:	e426                	sd	s1,8(sp)
    800047f2:	e04a                	sd	s2,0(sp)
    800047f4:	1000                	addi	s0,sp,32
    800047f6:	84aa                	mv	s1,a0
    800047f8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800047fa:	00004597          	auipc	a1,0x4
    800047fe:	f6658593          	addi	a1,a1,-154 # 80008760 <syscalls+0x240>
    80004802:	0521                	addi	a0,a0,8
    80004804:	ffffc097          	auipc	ra,0xffffc
    80004808:	33e080e7          	jalr	830(ra) # 80000b42 <initlock>
  lk->name = name;
    8000480c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004810:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004814:	0204a423          	sw	zero,40(s1)
}
    80004818:	60e2                	ld	ra,24(sp)
    8000481a:	6442                	ld	s0,16(sp)
    8000481c:	64a2                	ld	s1,8(sp)
    8000481e:	6902                	ld	s2,0(sp)
    80004820:	6105                	addi	sp,sp,32
    80004822:	8082                	ret

0000000080004824 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80004824:	1101                	addi	sp,sp,-32
    80004826:	ec06                	sd	ra,24(sp)
    80004828:	e822                	sd	s0,16(sp)
    8000482a:	e426                	sd	s1,8(sp)
    8000482c:	e04a                	sd	s2,0(sp)
    8000482e:	1000                	addi	s0,sp,32
    80004830:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004832:	00850913          	addi	s2,a0,8
    80004836:	854a                	mv	a0,s2
    80004838:	ffffc097          	auipc	ra,0xffffc
    8000483c:	39a080e7          	jalr	922(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004840:	409c                	lw	a5,0(s1)
    80004842:	cb89                	beqz	a5,80004854 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    80004844:	85ca                	mv	a1,s2
    80004846:	8526                	mv	a0,s1
    80004848:	ffffe097          	auipc	ra,0xffffe
    8000484c:	b9c080e7          	jalr	-1124(ra) # 800023e4 <sleep>
  while (lk->locked) {
    80004850:	409c                	lw	a5,0(s1)
    80004852:	fbed                	bnez	a5,80004844 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004854:	4785                	li	a5,1
    80004856:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004858:	ffffd097          	auipc	ra,0xffffd
    8000485c:	404080e7          	jalr	1028(ra) # 80001c5c <myproc>
    80004860:	591c                	lw	a5,48(a0)
    80004862:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004864:	854a                	mv	a0,s2
    80004866:	ffffc097          	auipc	ra,0xffffc
    8000486a:	420080e7          	jalr	1056(ra) # 80000c86 <release>
}
    8000486e:	60e2                	ld	ra,24(sp)
    80004870:	6442                	ld	s0,16(sp)
    80004872:	64a2                	ld	s1,8(sp)
    80004874:	6902                	ld	s2,0(sp)
    80004876:	6105                	addi	sp,sp,32
    80004878:	8082                	ret

000000008000487a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000487a:	1101                	addi	sp,sp,-32
    8000487c:	ec06                	sd	ra,24(sp)
    8000487e:	e822                	sd	s0,16(sp)
    80004880:	e426                	sd	s1,8(sp)
    80004882:	e04a                	sd	s2,0(sp)
    80004884:	1000                	addi	s0,sp,32
    80004886:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004888:	00850913          	addi	s2,a0,8
    8000488c:	854a                	mv	a0,s2
    8000488e:	ffffc097          	auipc	ra,0xffffc
    80004892:	344080e7          	jalr	836(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004896:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000489a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000489e:	8526                	mv	a0,s1
    800048a0:	ffffe097          	auipc	ra,0xffffe
    800048a4:	ba8080e7          	jalr	-1112(ra) # 80002448 <wakeup>
  release(&lk->lk);
    800048a8:	854a                	mv	a0,s2
    800048aa:	ffffc097          	auipc	ra,0xffffc
    800048ae:	3dc080e7          	jalr	988(ra) # 80000c86 <release>
}
    800048b2:	60e2                	ld	ra,24(sp)
    800048b4:	6442                	ld	s0,16(sp)
    800048b6:	64a2                	ld	s1,8(sp)
    800048b8:	6902                	ld	s2,0(sp)
    800048ba:	6105                	addi	sp,sp,32
    800048bc:	8082                	ret

00000000800048be <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800048be:	7179                	addi	sp,sp,-48
    800048c0:	f406                	sd	ra,40(sp)
    800048c2:	f022                	sd	s0,32(sp)
    800048c4:	ec26                	sd	s1,24(sp)
    800048c6:	e84a                	sd	s2,16(sp)
    800048c8:	e44e                	sd	s3,8(sp)
    800048ca:	1800                	addi	s0,sp,48
    800048cc:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800048ce:	00850913          	addi	s2,a0,8
    800048d2:	854a                	mv	a0,s2
    800048d4:	ffffc097          	auipc	ra,0xffffc
    800048d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    800048dc:	409c                	lw	a5,0(s1)
    800048de:	ef99                	bnez	a5,800048fc <holdingsleep+0x3e>
    800048e0:	4481                	li	s1,0
  release(&lk->lk);
    800048e2:	854a                	mv	a0,s2
    800048e4:	ffffc097          	auipc	ra,0xffffc
    800048e8:	3a2080e7          	jalr	930(ra) # 80000c86 <release>
  return r;
}
    800048ec:	8526                	mv	a0,s1
    800048ee:	70a2                	ld	ra,40(sp)
    800048f0:	7402                	ld	s0,32(sp)
    800048f2:	64e2                	ld	s1,24(sp)
    800048f4:	6942                	ld	s2,16(sp)
    800048f6:	69a2                	ld	s3,8(sp)
    800048f8:	6145                	addi	sp,sp,48
    800048fa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800048fc:	0284a983          	lw	s3,40(s1)
    80004900:	ffffd097          	auipc	ra,0xffffd
    80004904:	35c080e7          	jalr	860(ra) # 80001c5c <myproc>
    80004908:	5904                	lw	s1,48(a0)
    8000490a:	413484b3          	sub	s1,s1,s3
    8000490e:	0014b493          	seqz	s1,s1
    80004912:	bfc1                	j	800048e2 <holdingsleep+0x24>

0000000080004914 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80004914:	1141                	addi	sp,sp,-16
    80004916:	e406                	sd	ra,8(sp)
    80004918:	e022                	sd	s0,0(sp)
    8000491a:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    8000491c:	00004597          	auipc	a1,0x4
    80004920:	e5458593          	addi	a1,a1,-428 # 80008770 <syscalls+0x250>
    80004924:	0001c517          	auipc	a0,0x1c
    80004928:	56450513          	addi	a0,a0,1380 # 80020e88 <ftable>
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	216080e7          	jalr	534(ra) # 80000b42 <initlock>
}
    80004934:	60a2                	ld	ra,8(sp)
    80004936:	6402                	ld	s0,0(sp)
    80004938:	0141                	addi	sp,sp,16
    8000493a:	8082                	ret

000000008000493c <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    8000493c:	1101                	addi	sp,sp,-32
    8000493e:	ec06                	sd	ra,24(sp)
    80004940:	e822                	sd	s0,16(sp)
    80004942:	e426                	sd	s1,8(sp)
    80004944:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004946:	0001c517          	auipc	a0,0x1c
    8000494a:	54250513          	addi	a0,a0,1346 # 80020e88 <ftable>
    8000494e:	ffffc097          	auipc	ra,0xffffc
    80004952:	284080e7          	jalr	644(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004956:	0001c497          	auipc	s1,0x1c
    8000495a:	54a48493          	addi	s1,s1,1354 # 80020ea0 <ftable+0x18>
    8000495e:	0001d717          	auipc	a4,0x1d
    80004962:	4e270713          	addi	a4,a4,1250 # 80021e40 <disk>
    if(f->ref == 0){
    80004966:	40dc                	lw	a5,4(s1)
    80004968:	cf99                	beqz	a5,80004986 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000496a:	02848493          	addi	s1,s1,40
    8000496e:	fee49ce3          	bne	s1,a4,80004966 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004972:	0001c517          	auipc	a0,0x1c
    80004976:	51650513          	addi	a0,a0,1302 # 80020e88 <ftable>
    8000497a:	ffffc097          	auipc	ra,0xffffc
    8000497e:	30c080e7          	jalr	780(ra) # 80000c86 <release>
  return 0;
    80004982:	4481                	li	s1,0
    80004984:	a819                	j	8000499a <filealloc+0x5e>
      f->ref = 1;
    80004986:	4785                	li	a5,1
    80004988:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000498a:	0001c517          	auipc	a0,0x1c
    8000498e:	4fe50513          	addi	a0,a0,1278 # 80020e88 <ftable>
    80004992:	ffffc097          	auipc	ra,0xffffc
    80004996:	2f4080e7          	jalr	756(ra) # 80000c86 <release>
}
    8000499a:	8526                	mv	a0,s1
    8000499c:	60e2                	ld	ra,24(sp)
    8000499e:	6442                	ld	s0,16(sp)
    800049a0:	64a2                	ld	s1,8(sp)
    800049a2:	6105                	addi	sp,sp,32
    800049a4:	8082                	ret

00000000800049a6 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800049a6:	1101                	addi	sp,sp,-32
    800049a8:	ec06                	sd	ra,24(sp)
    800049aa:	e822                	sd	s0,16(sp)
    800049ac:	e426                	sd	s1,8(sp)
    800049ae:	1000                	addi	s0,sp,32
    800049b0:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800049b2:	0001c517          	auipc	a0,0x1c
    800049b6:	4d650513          	addi	a0,a0,1238 # 80020e88 <ftable>
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	218080e7          	jalr	536(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800049c2:	40dc                	lw	a5,4(s1)
    800049c4:	02f05263          	blez	a5,800049e8 <filedup+0x42>
    panic("filedup");
  f->ref++;
    800049c8:	2785                	addiw	a5,a5,1
    800049ca:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800049cc:	0001c517          	auipc	a0,0x1c
    800049d0:	4bc50513          	addi	a0,a0,1212 # 80020e88 <ftable>
    800049d4:	ffffc097          	auipc	ra,0xffffc
    800049d8:	2b2080e7          	jalr	690(ra) # 80000c86 <release>
  return f;
}
    800049dc:	8526                	mv	a0,s1
    800049de:	60e2                	ld	ra,24(sp)
    800049e0:	6442                	ld	s0,16(sp)
    800049e2:	64a2                	ld	s1,8(sp)
    800049e4:	6105                	addi	sp,sp,32
    800049e6:	8082                	ret
    panic("filedup");
    800049e8:	00004517          	auipc	a0,0x4
    800049ec:	d9050513          	addi	a0,a0,-624 # 80008778 <syscalls+0x258>
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	b4c080e7          	jalr	-1204(ra) # 8000053c <panic>

00000000800049f8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800049f8:	7139                	addi	sp,sp,-64
    800049fa:	fc06                	sd	ra,56(sp)
    800049fc:	f822                	sd	s0,48(sp)
    800049fe:	f426                	sd	s1,40(sp)
    80004a00:	f04a                	sd	s2,32(sp)
    80004a02:	ec4e                	sd	s3,24(sp)
    80004a04:	e852                	sd	s4,16(sp)
    80004a06:	e456                	sd	s5,8(sp)
    80004a08:	0080                	addi	s0,sp,64
    80004a0a:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004a0c:	0001c517          	auipc	a0,0x1c
    80004a10:	47c50513          	addi	a0,a0,1148 # 80020e88 <ftable>
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	1be080e7          	jalr	446(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004a1c:	40dc                	lw	a5,4(s1)
    80004a1e:	06f05163          	blez	a5,80004a80 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004a22:	37fd                	addiw	a5,a5,-1
    80004a24:	0007871b          	sext.w	a4,a5
    80004a28:	c0dc                	sw	a5,4(s1)
    80004a2a:	06e04363          	bgtz	a4,80004a90 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004a2e:	0004a903          	lw	s2,0(s1)
    80004a32:	0094ca83          	lbu	s5,9(s1)
    80004a36:	0104ba03          	ld	s4,16(s1)
    80004a3a:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004a3e:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004a42:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004a46:	0001c517          	auipc	a0,0x1c
    80004a4a:	44250513          	addi	a0,a0,1090 # 80020e88 <ftable>
    80004a4e:	ffffc097          	auipc	ra,0xffffc
    80004a52:	238080e7          	jalr	568(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004a56:	4785                	li	a5,1
    80004a58:	04f90d63          	beq	s2,a5,80004ab2 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004a5c:	3979                	addiw	s2,s2,-2
    80004a5e:	4785                	li	a5,1
    80004a60:	0527e063          	bltu	a5,s2,80004aa0 <fileclose+0xa8>
    begin_op();
    80004a64:	00000097          	auipc	ra,0x0
    80004a68:	ad0080e7          	jalr	-1328(ra) # 80004534 <begin_op>
    iput(ff.ip);
    80004a6c:	854e                	mv	a0,s3
    80004a6e:	fffff097          	auipc	ra,0xfffff
    80004a72:	2da080e7          	jalr	730(ra) # 80003d48 <iput>
    end_op();
    80004a76:	00000097          	auipc	ra,0x0
    80004a7a:	b38080e7          	jalr	-1224(ra) # 800045ae <end_op>
    80004a7e:	a00d                	j	80004aa0 <fileclose+0xa8>
    panic("fileclose");
    80004a80:	00004517          	auipc	a0,0x4
    80004a84:	d0050513          	addi	a0,a0,-768 # 80008780 <syscalls+0x260>
    80004a88:	ffffc097          	auipc	ra,0xffffc
    80004a8c:	ab4080e7          	jalr	-1356(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004a90:	0001c517          	auipc	a0,0x1c
    80004a94:	3f850513          	addi	a0,a0,1016 # 80020e88 <ftable>
    80004a98:	ffffc097          	auipc	ra,0xffffc
    80004a9c:	1ee080e7          	jalr	494(ra) # 80000c86 <release>
  }
}
    80004aa0:	70e2                	ld	ra,56(sp)
    80004aa2:	7442                	ld	s0,48(sp)
    80004aa4:	74a2                	ld	s1,40(sp)
    80004aa6:	7902                	ld	s2,32(sp)
    80004aa8:	69e2                	ld	s3,24(sp)
    80004aaa:	6a42                	ld	s4,16(sp)
    80004aac:	6aa2                	ld	s5,8(sp)
    80004aae:	6121                	addi	sp,sp,64
    80004ab0:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004ab2:	85d6                	mv	a1,s5
    80004ab4:	8552                	mv	a0,s4
    80004ab6:	00000097          	auipc	ra,0x0
    80004aba:	348080e7          	jalr	840(ra) # 80004dfe <pipeclose>
    80004abe:	b7cd                	j	80004aa0 <fileclose+0xa8>

0000000080004ac0 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004ac0:	715d                	addi	sp,sp,-80
    80004ac2:	e486                	sd	ra,72(sp)
    80004ac4:	e0a2                	sd	s0,64(sp)
    80004ac6:	fc26                	sd	s1,56(sp)
    80004ac8:	f84a                	sd	s2,48(sp)
    80004aca:	f44e                	sd	s3,40(sp)
    80004acc:	0880                	addi	s0,sp,80
    80004ace:	84aa                	mv	s1,a0
    80004ad0:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004ad2:	ffffd097          	auipc	ra,0xffffd
    80004ad6:	18a080e7          	jalr	394(ra) # 80001c5c <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004ada:	409c                	lw	a5,0(s1)
    80004adc:	37f9                	addiw	a5,a5,-2
    80004ade:	4705                	li	a4,1
    80004ae0:	04f76763          	bltu	a4,a5,80004b2e <filestat+0x6e>
    80004ae4:	892a                	mv	s2,a0
    ilock(f->ip);
    80004ae6:	6c88                	ld	a0,24(s1)
    80004ae8:	fffff097          	auipc	ra,0xfffff
    80004aec:	0a6080e7          	jalr	166(ra) # 80003b8e <ilock>
    stati(f->ip, &st);
    80004af0:	fb840593          	addi	a1,s0,-72
    80004af4:	6c88                	ld	a0,24(s1)
    80004af6:	fffff097          	auipc	ra,0xfffff
    80004afa:	322080e7          	jalr	802(ra) # 80003e18 <stati>
    iunlock(f->ip);
    80004afe:	6c88                	ld	a0,24(s1)
    80004b00:	fffff097          	auipc	ra,0xfffff
    80004b04:	150080e7          	jalr	336(ra) # 80003c50 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004b08:	46e1                	li	a3,24
    80004b0a:	fb840613          	addi	a2,s0,-72
    80004b0e:	85ce                	mv	a1,s3
    80004b10:	05093503          	ld	a0,80(s2)
    80004b14:	ffffd097          	auipc	ra,0xffffd
    80004b18:	b52080e7          	jalr	-1198(ra) # 80001666 <copyout>
    80004b1c:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004b20:	60a6                	ld	ra,72(sp)
    80004b22:	6406                	ld	s0,64(sp)
    80004b24:	74e2                	ld	s1,56(sp)
    80004b26:	7942                	ld	s2,48(sp)
    80004b28:	79a2                	ld	s3,40(sp)
    80004b2a:	6161                	addi	sp,sp,80
    80004b2c:	8082                	ret
  return -1;
    80004b2e:	557d                	li	a0,-1
    80004b30:	bfc5                	j	80004b20 <filestat+0x60>

0000000080004b32 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004b32:	7179                	addi	sp,sp,-48
    80004b34:	f406                	sd	ra,40(sp)
    80004b36:	f022                	sd	s0,32(sp)
    80004b38:	ec26                	sd	s1,24(sp)
    80004b3a:	e84a                	sd	s2,16(sp)
    80004b3c:	e44e                	sd	s3,8(sp)
    80004b3e:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004b40:	00854783          	lbu	a5,8(a0)
    80004b44:	c3d5                	beqz	a5,80004be8 <fileread+0xb6>
    80004b46:	84aa                	mv	s1,a0
    80004b48:	89ae                	mv	s3,a1
    80004b4a:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004b4c:	411c                	lw	a5,0(a0)
    80004b4e:	4705                	li	a4,1
    80004b50:	04e78963          	beq	a5,a4,80004ba2 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004b54:	470d                	li	a4,3
    80004b56:	04e78d63          	beq	a5,a4,80004bb0 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004b5a:	4709                	li	a4,2
    80004b5c:	06e79e63          	bne	a5,a4,80004bd8 <fileread+0xa6>
    ilock(f->ip);
    80004b60:	6d08                	ld	a0,24(a0)
    80004b62:	fffff097          	auipc	ra,0xfffff
    80004b66:	02c080e7          	jalr	44(ra) # 80003b8e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004b6a:	874a                	mv	a4,s2
    80004b6c:	5094                	lw	a3,32(s1)
    80004b6e:	864e                	mv	a2,s3
    80004b70:	4585                	li	a1,1
    80004b72:	6c88                	ld	a0,24(s1)
    80004b74:	fffff097          	auipc	ra,0xfffff
    80004b78:	2ce080e7          	jalr	718(ra) # 80003e42 <readi>
    80004b7c:	892a                	mv	s2,a0
    80004b7e:	00a05563          	blez	a0,80004b88 <fileread+0x56>
      f->off += r;
    80004b82:	509c                	lw	a5,32(s1)
    80004b84:	9fa9                	addw	a5,a5,a0
    80004b86:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004b88:	6c88                	ld	a0,24(s1)
    80004b8a:	fffff097          	auipc	ra,0xfffff
    80004b8e:	0c6080e7          	jalr	198(ra) # 80003c50 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004b92:	854a                	mv	a0,s2
    80004b94:	70a2                	ld	ra,40(sp)
    80004b96:	7402                	ld	s0,32(sp)
    80004b98:	64e2                	ld	s1,24(sp)
    80004b9a:	6942                	ld	s2,16(sp)
    80004b9c:	69a2                	ld	s3,8(sp)
    80004b9e:	6145                	addi	sp,sp,48
    80004ba0:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004ba2:	6908                	ld	a0,16(a0)
    80004ba4:	00000097          	auipc	ra,0x0
    80004ba8:	3c2080e7          	jalr	962(ra) # 80004f66 <piperead>
    80004bac:	892a                	mv	s2,a0
    80004bae:	b7d5                	j	80004b92 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004bb0:	02451783          	lh	a5,36(a0)
    80004bb4:	03079693          	slli	a3,a5,0x30
    80004bb8:	92c1                	srli	a3,a3,0x30
    80004bba:	4725                	li	a4,9
    80004bbc:	02d76863          	bltu	a4,a3,80004bec <fileread+0xba>
    80004bc0:	0792                	slli	a5,a5,0x4
    80004bc2:	0001c717          	auipc	a4,0x1c
    80004bc6:	22670713          	addi	a4,a4,550 # 80020de8 <devsw>
    80004bca:	97ba                	add	a5,a5,a4
    80004bcc:	639c                	ld	a5,0(a5)
    80004bce:	c38d                	beqz	a5,80004bf0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004bd0:	4505                	li	a0,1
    80004bd2:	9782                	jalr	a5
    80004bd4:	892a                	mv	s2,a0
    80004bd6:	bf75                	j	80004b92 <fileread+0x60>
    panic("fileread");
    80004bd8:	00004517          	auipc	a0,0x4
    80004bdc:	bb850513          	addi	a0,a0,-1096 # 80008790 <syscalls+0x270>
    80004be0:	ffffc097          	auipc	ra,0xffffc
    80004be4:	95c080e7          	jalr	-1700(ra) # 8000053c <panic>
    return -1;
    80004be8:	597d                	li	s2,-1
    80004bea:	b765                	j	80004b92 <fileread+0x60>
      return -1;
    80004bec:	597d                	li	s2,-1
    80004bee:	b755                	j	80004b92 <fileread+0x60>
    80004bf0:	597d                	li	s2,-1
    80004bf2:	b745                	j	80004b92 <fileread+0x60>

0000000080004bf4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004bf4:	00954783          	lbu	a5,9(a0)
    80004bf8:	10078e63          	beqz	a5,80004d14 <filewrite+0x120>
{
    80004bfc:	715d                	addi	sp,sp,-80
    80004bfe:	e486                	sd	ra,72(sp)
    80004c00:	e0a2                	sd	s0,64(sp)
    80004c02:	fc26                	sd	s1,56(sp)
    80004c04:	f84a                	sd	s2,48(sp)
    80004c06:	f44e                	sd	s3,40(sp)
    80004c08:	f052                	sd	s4,32(sp)
    80004c0a:	ec56                	sd	s5,24(sp)
    80004c0c:	e85a                	sd	s6,16(sp)
    80004c0e:	e45e                	sd	s7,8(sp)
    80004c10:	e062                	sd	s8,0(sp)
    80004c12:	0880                	addi	s0,sp,80
    80004c14:	892a                	mv	s2,a0
    80004c16:	8b2e                	mv	s6,a1
    80004c18:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004c1a:	411c                	lw	a5,0(a0)
    80004c1c:	4705                	li	a4,1
    80004c1e:	02e78263          	beq	a5,a4,80004c42 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004c22:	470d                	li	a4,3
    80004c24:	02e78563          	beq	a5,a4,80004c4e <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004c28:	4709                	li	a4,2
    80004c2a:	0ce79d63          	bne	a5,a4,80004d04 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004c2e:	0ac05b63          	blez	a2,80004ce4 <filewrite+0xf0>
    int i = 0;
    80004c32:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004c34:	6b85                	lui	s7,0x1
    80004c36:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004c3a:	6c05                	lui	s8,0x1
    80004c3c:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004c40:	a851                	j	80004cd4 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004c42:	6908                	ld	a0,16(a0)
    80004c44:	00000097          	auipc	ra,0x0
    80004c48:	22a080e7          	jalr	554(ra) # 80004e6e <pipewrite>
    80004c4c:	a045                	j	80004cec <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004c4e:	02451783          	lh	a5,36(a0)
    80004c52:	03079693          	slli	a3,a5,0x30
    80004c56:	92c1                	srli	a3,a3,0x30
    80004c58:	4725                	li	a4,9
    80004c5a:	0ad76f63          	bltu	a4,a3,80004d18 <filewrite+0x124>
    80004c5e:	0792                	slli	a5,a5,0x4
    80004c60:	0001c717          	auipc	a4,0x1c
    80004c64:	18870713          	addi	a4,a4,392 # 80020de8 <devsw>
    80004c68:	97ba                	add	a5,a5,a4
    80004c6a:	679c                	ld	a5,8(a5)
    80004c6c:	cbc5                	beqz	a5,80004d1c <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004c6e:	4505                	li	a0,1
    80004c70:	9782                	jalr	a5
    80004c72:	a8ad                	j	80004cec <filewrite+0xf8>
      if(n1 > max)
    80004c74:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004c78:	00000097          	auipc	ra,0x0
    80004c7c:	8bc080e7          	jalr	-1860(ra) # 80004534 <begin_op>
      ilock(f->ip);
    80004c80:	01893503          	ld	a0,24(s2)
    80004c84:	fffff097          	auipc	ra,0xfffff
    80004c88:	f0a080e7          	jalr	-246(ra) # 80003b8e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004c8c:	8756                	mv	a4,s5
    80004c8e:	02092683          	lw	a3,32(s2)
    80004c92:	01698633          	add	a2,s3,s6
    80004c96:	4585                	li	a1,1
    80004c98:	01893503          	ld	a0,24(s2)
    80004c9c:	fffff097          	auipc	ra,0xfffff
    80004ca0:	29e080e7          	jalr	670(ra) # 80003f3a <writei>
    80004ca4:	84aa                	mv	s1,a0
    80004ca6:	00a05763          	blez	a0,80004cb4 <filewrite+0xc0>
        f->off += r;
    80004caa:	02092783          	lw	a5,32(s2)
    80004cae:	9fa9                	addw	a5,a5,a0
    80004cb0:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004cb4:	01893503          	ld	a0,24(s2)
    80004cb8:	fffff097          	auipc	ra,0xfffff
    80004cbc:	f98080e7          	jalr	-104(ra) # 80003c50 <iunlock>
      end_op();
    80004cc0:	00000097          	auipc	ra,0x0
    80004cc4:	8ee080e7          	jalr	-1810(ra) # 800045ae <end_op>

      if(r != n1){
    80004cc8:	009a9f63          	bne	s5,s1,80004ce6 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004ccc:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004cd0:	0149db63          	bge	s3,s4,80004ce6 <filewrite+0xf2>
      int n1 = n - i;
    80004cd4:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004cd8:	0004879b          	sext.w	a5,s1
    80004cdc:	f8fbdce3          	bge	s7,a5,80004c74 <filewrite+0x80>
    80004ce0:	84e2                	mv	s1,s8
    80004ce2:	bf49                	j	80004c74 <filewrite+0x80>
    int i = 0;
    80004ce4:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004ce6:	033a1d63          	bne	s4,s3,80004d20 <filewrite+0x12c>
    80004cea:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004cec:	60a6                	ld	ra,72(sp)
    80004cee:	6406                	ld	s0,64(sp)
    80004cf0:	74e2                	ld	s1,56(sp)
    80004cf2:	7942                	ld	s2,48(sp)
    80004cf4:	79a2                	ld	s3,40(sp)
    80004cf6:	7a02                	ld	s4,32(sp)
    80004cf8:	6ae2                	ld	s5,24(sp)
    80004cfa:	6b42                	ld	s6,16(sp)
    80004cfc:	6ba2                	ld	s7,8(sp)
    80004cfe:	6c02                	ld	s8,0(sp)
    80004d00:	6161                	addi	sp,sp,80
    80004d02:	8082                	ret
    panic("filewrite");
    80004d04:	00004517          	auipc	a0,0x4
    80004d08:	a9c50513          	addi	a0,a0,-1380 # 800087a0 <syscalls+0x280>
    80004d0c:	ffffc097          	auipc	ra,0xffffc
    80004d10:	830080e7          	jalr	-2000(ra) # 8000053c <panic>
    return -1;
    80004d14:	557d                	li	a0,-1
}
    80004d16:	8082                	ret
      return -1;
    80004d18:	557d                	li	a0,-1
    80004d1a:	bfc9                	j	80004cec <filewrite+0xf8>
    80004d1c:	557d                	li	a0,-1
    80004d1e:	b7f9                	j	80004cec <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004d20:	557d                	li	a0,-1
    80004d22:	b7e9                	j	80004cec <filewrite+0xf8>

0000000080004d24 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004d24:	7179                	addi	sp,sp,-48
    80004d26:	f406                	sd	ra,40(sp)
    80004d28:	f022                	sd	s0,32(sp)
    80004d2a:	ec26                	sd	s1,24(sp)
    80004d2c:	e84a                	sd	s2,16(sp)
    80004d2e:	e44e                	sd	s3,8(sp)
    80004d30:	e052                	sd	s4,0(sp)
    80004d32:	1800                	addi	s0,sp,48
    80004d34:	84aa                	mv	s1,a0
    80004d36:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004d38:	0005b023          	sd	zero,0(a1)
    80004d3c:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004d40:	00000097          	auipc	ra,0x0
    80004d44:	bfc080e7          	jalr	-1028(ra) # 8000493c <filealloc>
    80004d48:	e088                	sd	a0,0(s1)
    80004d4a:	c551                	beqz	a0,80004dd6 <pipealloc+0xb2>
    80004d4c:	00000097          	auipc	ra,0x0
    80004d50:	bf0080e7          	jalr	-1040(ra) # 8000493c <filealloc>
    80004d54:	00aa3023          	sd	a0,0(s4)
    80004d58:	c92d                	beqz	a0,80004dca <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004d5a:	ffffc097          	auipc	ra,0xffffc
    80004d5e:	d88080e7          	jalr	-632(ra) # 80000ae2 <kalloc>
    80004d62:	892a                	mv	s2,a0
    80004d64:	c125                	beqz	a0,80004dc4 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004d66:	4985                	li	s3,1
    80004d68:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004d6c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004d70:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004d74:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004d78:	00004597          	auipc	a1,0x4
    80004d7c:	a3858593          	addi	a1,a1,-1480 # 800087b0 <syscalls+0x290>
    80004d80:	ffffc097          	auipc	ra,0xffffc
    80004d84:	dc2080e7          	jalr	-574(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004d88:	609c                	ld	a5,0(s1)
    80004d8a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004d8e:	609c                	ld	a5,0(s1)
    80004d90:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004d94:	609c                	ld	a5,0(s1)
    80004d96:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004d9a:	609c                	ld	a5,0(s1)
    80004d9c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004da0:	000a3783          	ld	a5,0(s4)
    80004da4:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004da8:	000a3783          	ld	a5,0(s4)
    80004dac:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004db0:	000a3783          	ld	a5,0(s4)
    80004db4:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004db8:	000a3783          	ld	a5,0(s4)
    80004dbc:	0127b823          	sd	s2,16(a5)
  return 0;
    80004dc0:	4501                	li	a0,0
    80004dc2:	a025                	j	80004dea <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004dc4:	6088                	ld	a0,0(s1)
    80004dc6:	e501                	bnez	a0,80004dce <pipealloc+0xaa>
    80004dc8:	a039                	j	80004dd6 <pipealloc+0xb2>
    80004dca:	6088                	ld	a0,0(s1)
    80004dcc:	c51d                	beqz	a0,80004dfa <pipealloc+0xd6>
    fileclose(*f0);
    80004dce:	00000097          	auipc	ra,0x0
    80004dd2:	c2a080e7          	jalr	-982(ra) # 800049f8 <fileclose>
  if(*f1)
    80004dd6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004dda:	557d                	li	a0,-1
  if(*f1)
    80004ddc:	c799                	beqz	a5,80004dea <pipealloc+0xc6>
    fileclose(*f1);
    80004dde:	853e                	mv	a0,a5
    80004de0:	00000097          	auipc	ra,0x0
    80004de4:	c18080e7          	jalr	-1000(ra) # 800049f8 <fileclose>
  return -1;
    80004de8:	557d                	li	a0,-1
}
    80004dea:	70a2                	ld	ra,40(sp)
    80004dec:	7402                	ld	s0,32(sp)
    80004dee:	64e2                	ld	s1,24(sp)
    80004df0:	6942                	ld	s2,16(sp)
    80004df2:	69a2                	ld	s3,8(sp)
    80004df4:	6a02                	ld	s4,0(sp)
    80004df6:	6145                	addi	sp,sp,48
    80004df8:	8082                	ret
  return -1;
    80004dfa:	557d                	li	a0,-1
    80004dfc:	b7fd                	j	80004dea <pipealloc+0xc6>

0000000080004dfe <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004dfe:	1101                	addi	sp,sp,-32
    80004e00:	ec06                	sd	ra,24(sp)
    80004e02:	e822                	sd	s0,16(sp)
    80004e04:	e426                	sd	s1,8(sp)
    80004e06:	e04a                	sd	s2,0(sp)
    80004e08:	1000                	addi	s0,sp,32
    80004e0a:	84aa                	mv	s1,a0
    80004e0c:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004e0e:	ffffc097          	auipc	ra,0xffffc
    80004e12:	dc4080e7          	jalr	-572(ra) # 80000bd2 <acquire>
  if(writable){
    80004e16:	02090d63          	beqz	s2,80004e50 <pipeclose+0x52>
    pi->writeopen = 0;
    80004e1a:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004e1e:	21848513          	addi	a0,s1,536
    80004e22:	ffffd097          	auipc	ra,0xffffd
    80004e26:	626080e7          	jalr	1574(ra) # 80002448 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004e2a:	2204b783          	ld	a5,544(s1)
    80004e2e:	eb95                	bnez	a5,80004e62 <pipeclose+0x64>
    release(&pi->lock);
    80004e30:	8526                	mv	a0,s1
    80004e32:	ffffc097          	auipc	ra,0xffffc
    80004e36:	e54080e7          	jalr	-428(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	ffffc097          	auipc	ra,0xffffc
    80004e40:	ba8080e7          	jalr	-1112(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004e44:	60e2                	ld	ra,24(sp)
    80004e46:	6442                	ld	s0,16(sp)
    80004e48:	64a2                	ld	s1,8(sp)
    80004e4a:	6902                	ld	s2,0(sp)
    80004e4c:	6105                	addi	sp,sp,32
    80004e4e:	8082                	ret
    pi->readopen = 0;
    80004e50:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004e54:	21c48513          	addi	a0,s1,540
    80004e58:	ffffd097          	auipc	ra,0xffffd
    80004e5c:	5f0080e7          	jalr	1520(ra) # 80002448 <wakeup>
    80004e60:	b7e9                	j	80004e2a <pipeclose+0x2c>
    release(&pi->lock);
    80004e62:	8526                	mv	a0,s1
    80004e64:	ffffc097          	auipc	ra,0xffffc
    80004e68:	e22080e7          	jalr	-478(ra) # 80000c86 <release>
}
    80004e6c:	bfe1                	j	80004e44 <pipeclose+0x46>

0000000080004e6e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004e6e:	711d                	addi	sp,sp,-96
    80004e70:	ec86                	sd	ra,88(sp)
    80004e72:	e8a2                	sd	s0,80(sp)
    80004e74:	e4a6                	sd	s1,72(sp)
    80004e76:	e0ca                	sd	s2,64(sp)
    80004e78:	fc4e                	sd	s3,56(sp)
    80004e7a:	f852                	sd	s4,48(sp)
    80004e7c:	f456                	sd	s5,40(sp)
    80004e7e:	f05a                	sd	s6,32(sp)
    80004e80:	ec5e                	sd	s7,24(sp)
    80004e82:	e862                	sd	s8,16(sp)
    80004e84:	1080                	addi	s0,sp,96
    80004e86:	84aa                	mv	s1,a0
    80004e88:	8aae                	mv	s5,a1
    80004e8a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004e8c:	ffffd097          	auipc	ra,0xffffd
    80004e90:	dd0080e7          	jalr	-560(ra) # 80001c5c <myproc>
    80004e94:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004e96:	8526                	mv	a0,s1
    80004e98:	ffffc097          	auipc	ra,0xffffc
    80004e9c:	d3a080e7          	jalr	-710(ra) # 80000bd2 <acquire>
  while(i < n){
    80004ea0:	0b405663          	blez	s4,80004f4c <pipewrite+0xde>
  int i = 0;
    80004ea4:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ea6:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ea8:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004eac:	21c48b93          	addi	s7,s1,540
    80004eb0:	a089                	j	80004ef2 <pipewrite+0x84>
      release(&pi->lock);
    80004eb2:	8526                	mv	a0,s1
    80004eb4:	ffffc097          	auipc	ra,0xffffc
    80004eb8:	dd2080e7          	jalr	-558(ra) # 80000c86 <release>
      return -1;
    80004ebc:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ebe:	854a                	mv	a0,s2
    80004ec0:	60e6                	ld	ra,88(sp)
    80004ec2:	6446                	ld	s0,80(sp)
    80004ec4:	64a6                	ld	s1,72(sp)
    80004ec6:	6906                	ld	s2,64(sp)
    80004ec8:	79e2                	ld	s3,56(sp)
    80004eca:	7a42                	ld	s4,48(sp)
    80004ecc:	7aa2                	ld	s5,40(sp)
    80004ece:	7b02                	ld	s6,32(sp)
    80004ed0:	6be2                	ld	s7,24(sp)
    80004ed2:	6c42                	ld	s8,16(sp)
    80004ed4:	6125                	addi	sp,sp,96
    80004ed6:	8082                	ret
      wakeup(&pi->nread);
    80004ed8:	8562                	mv	a0,s8
    80004eda:	ffffd097          	auipc	ra,0xffffd
    80004ede:	56e080e7          	jalr	1390(ra) # 80002448 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ee2:	85a6                	mv	a1,s1
    80004ee4:	855e                	mv	a0,s7
    80004ee6:	ffffd097          	auipc	ra,0xffffd
    80004eea:	4fe080e7          	jalr	1278(ra) # 800023e4 <sleep>
  while(i < n){
    80004eee:	07495063          	bge	s2,s4,80004f4e <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004ef2:	2204a783          	lw	a5,544(s1)
    80004ef6:	dfd5                	beqz	a5,80004eb2 <pipewrite+0x44>
    80004ef8:	854e                	mv	a0,s3
    80004efa:	ffffd097          	auipc	ra,0xffffd
    80004efe:	792080e7          	jalr	1938(ra) # 8000268c <killed>
    80004f02:	f945                	bnez	a0,80004eb2 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004f04:	2184a783          	lw	a5,536(s1)
    80004f08:	21c4a703          	lw	a4,540(s1)
    80004f0c:	2007879b          	addiw	a5,a5,512
    80004f10:	fcf704e3          	beq	a4,a5,80004ed8 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004f14:	4685                	li	a3,1
    80004f16:	01590633          	add	a2,s2,s5
    80004f1a:	faf40593          	addi	a1,s0,-81
    80004f1e:	0509b503          	ld	a0,80(s3)
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	7d0080e7          	jalr	2000(ra) # 800016f2 <copyin>
    80004f2a:	03650263          	beq	a0,s6,80004f4e <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004f2e:	21c4a783          	lw	a5,540(s1)
    80004f32:	0017871b          	addiw	a4,a5,1
    80004f36:	20e4ae23          	sw	a4,540(s1)
    80004f3a:	1ff7f793          	andi	a5,a5,511
    80004f3e:	97a6                	add	a5,a5,s1
    80004f40:	faf44703          	lbu	a4,-81(s0)
    80004f44:	00e78c23          	sb	a4,24(a5)
      i++;
    80004f48:	2905                	addiw	s2,s2,1
    80004f4a:	b755                	j	80004eee <pipewrite+0x80>
  int i = 0;
    80004f4c:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004f4e:	21848513          	addi	a0,s1,536
    80004f52:	ffffd097          	auipc	ra,0xffffd
    80004f56:	4f6080e7          	jalr	1270(ra) # 80002448 <wakeup>
  release(&pi->lock);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	ffffc097          	auipc	ra,0xffffc
    80004f60:	d2a080e7          	jalr	-726(ra) # 80000c86 <release>
  return i;
    80004f64:	bfa9                	j	80004ebe <pipewrite+0x50>

0000000080004f66 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004f66:	715d                	addi	sp,sp,-80
    80004f68:	e486                	sd	ra,72(sp)
    80004f6a:	e0a2                	sd	s0,64(sp)
    80004f6c:	fc26                	sd	s1,56(sp)
    80004f6e:	f84a                	sd	s2,48(sp)
    80004f70:	f44e                	sd	s3,40(sp)
    80004f72:	f052                	sd	s4,32(sp)
    80004f74:	ec56                	sd	s5,24(sp)
    80004f76:	e85a                	sd	s6,16(sp)
    80004f78:	0880                	addi	s0,sp,80
    80004f7a:	84aa                	mv	s1,a0
    80004f7c:	892e                	mv	s2,a1
    80004f7e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004f80:	ffffd097          	auipc	ra,0xffffd
    80004f84:	cdc080e7          	jalr	-804(ra) # 80001c5c <myproc>
    80004f88:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004f8a:	8526                	mv	a0,s1
    80004f8c:	ffffc097          	auipc	ra,0xffffc
    80004f90:	c46080e7          	jalr	-954(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004f94:	2184a703          	lw	a4,536(s1)
    80004f98:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004f9c:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fa0:	02f71763          	bne	a4,a5,80004fce <piperead+0x68>
    80004fa4:	2244a783          	lw	a5,548(s1)
    80004fa8:	c39d                	beqz	a5,80004fce <piperead+0x68>
    if(killed(pr)){
    80004faa:	8552                	mv	a0,s4
    80004fac:	ffffd097          	auipc	ra,0xffffd
    80004fb0:	6e0080e7          	jalr	1760(ra) # 8000268c <killed>
    80004fb4:	e949                	bnez	a0,80005046 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004fb6:	85a6                	mv	a1,s1
    80004fb8:	854e                	mv	a0,s3
    80004fba:	ffffd097          	auipc	ra,0xffffd
    80004fbe:	42a080e7          	jalr	1066(ra) # 800023e4 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004fc2:	2184a703          	lw	a4,536(s1)
    80004fc6:	21c4a783          	lw	a5,540(s1)
    80004fca:	fcf70de3          	beq	a4,a5,80004fa4 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fce:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004fd0:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004fd2:	05505463          	blez	s5,8000501a <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004fd6:	2184a783          	lw	a5,536(s1)
    80004fda:	21c4a703          	lw	a4,540(s1)
    80004fde:	02f70e63          	beq	a4,a5,8000501a <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004fe2:	0017871b          	addiw	a4,a5,1
    80004fe6:	20e4ac23          	sw	a4,536(s1)
    80004fea:	1ff7f793          	andi	a5,a5,511
    80004fee:	97a6                	add	a5,a5,s1
    80004ff0:	0187c783          	lbu	a5,24(a5)
    80004ff4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ff8:	4685                	li	a3,1
    80004ffa:	fbf40613          	addi	a2,s0,-65
    80004ffe:	85ca                	mv	a1,s2
    80005000:	050a3503          	ld	a0,80(s4)
    80005004:	ffffc097          	auipc	ra,0xffffc
    80005008:	662080e7          	jalr	1634(ra) # 80001666 <copyout>
    8000500c:	01650763          	beq	a0,s6,8000501a <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80005010:	2985                	addiw	s3,s3,1
    80005012:	0905                	addi	s2,s2,1
    80005014:	fd3a91e3          	bne	s5,s3,80004fd6 <piperead+0x70>
    80005018:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    8000501a:	21c48513          	addi	a0,s1,540
    8000501e:	ffffd097          	auipc	ra,0xffffd
    80005022:	42a080e7          	jalr	1066(ra) # 80002448 <wakeup>
  release(&pi->lock);
    80005026:	8526                	mv	a0,s1
    80005028:	ffffc097          	auipc	ra,0xffffc
    8000502c:	c5e080e7          	jalr	-930(ra) # 80000c86 <release>
  return i;
}
    80005030:	854e                	mv	a0,s3
    80005032:	60a6                	ld	ra,72(sp)
    80005034:	6406                	ld	s0,64(sp)
    80005036:	74e2                	ld	s1,56(sp)
    80005038:	7942                	ld	s2,48(sp)
    8000503a:	79a2                	ld	s3,40(sp)
    8000503c:	7a02                	ld	s4,32(sp)
    8000503e:	6ae2                	ld	s5,24(sp)
    80005040:	6b42                	ld	s6,16(sp)
    80005042:	6161                	addi	sp,sp,80
    80005044:	8082                	ret
      release(&pi->lock);
    80005046:	8526                	mv	a0,s1
    80005048:	ffffc097          	auipc	ra,0xffffc
    8000504c:	c3e080e7          	jalr	-962(ra) # 80000c86 <release>
      return -1;
    80005050:	59fd                	li	s3,-1
    80005052:	bff9                	j	80005030 <piperead+0xca>

0000000080005054 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80005054:	1141                	addi	sp,sp,-16
    80005056:	e422                	sd	s0,8(sp)
    80005058:	0800                	addi	s0,sp,16
    8000505a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    8000505c:	8905                	andi	a0,a0,1
    8000505e:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80005060:	8b89                	andi	a5,a5,2
    80005062:	c399                	beqz	a5,80005068 <flags2perm+0x14>
      perm |= PTE_W;
    80005064:	00456513          	ori	a0,a0,4
    return perm;
}
    80005068:	6422                	ld	s0,8(sp)
    8000506a:	0141                	addi	sp,sp,16
    8000506c:	8082                	ret

000000008000506e <exec>:

int
exec(char *path, char **argv)
{
    8000506e:	df010113          	addi	sp,sp,-528
    80005072:	20113423          	sd	ra,520(sp)
    80005076:	20813023          	sd	s0,512(sp)
    8000507a:	ffa6                	sd	s1,504(sp)
    8000507c:	fbca                	sd	s2,496(sp)
    8000507e:	f7ce                	sd	s3,488(sp)
    80005080:	f3d2                	sd	s4,480(sp)
    80005082:	efd6                	sd	s5,472(sp)
    80005084:	ebda                	sd	s6,464(sp)
    80005086:	e7de                	sd	s7,456(sp)
    80005088:	e3e2                	sd	s8,448(sp)
    8000508a:	ff66                	sd	s9,440(sp)
    8000508c:	fb6a                	sd	s10,432(sp)
    8000508e:	f76e                	sd	s11,424(sp)
    80005090:	0c00                	addi	s0,sp,528
    80005092:	892a                	mv	s2,a0
    80005094:	dea43c23          	sd	a0,-520(s0)
    80005098:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000509c:	ffffd097          	auipc	ra,0xffffd
    800050a0:	bc0080e7          	jalr	-1088(ra) # 80001c5c <myproc>
    800050a4:	84aa                	mv	s1,a0

  begin_op();
    800050a6:	fffff097          	auipc	ra,0xfffff
    800050aa:	48e080e7          	jalr	1166(ra) # 80004534 <begin_op>

  if((ip = namei(path)) == 0){
    800050ae:	854a                	mv	a0,s2
    800050b0:	fffff097          	auipc	ra,0xfffff
    800050b4:	284080e7          	jalr	644(ra) # 80004334 <namei>
    800050b8:	c92d                	beqz	a0,8000512a <exec+0xbc>
    800050ba:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800050bc:	fffff097          	auipc	ra,0xfffff
    800050c0:	ad2080e7          	jalr	-1326(ra) # 80003b8e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800050c4:	04000713          	li	a4,64
    800050c8:	4681                	li	a3,0
    800050ca:	e5040613          	addi	a2,s0,-432
    800050ce:	4581                	li	a1,0
    800050d0:	8552                	mv	a0,s4
    800050d2:	fffff097          	auipc	ra,0xfffff
    800050d6:	d70080e7          	jalr	-656(ra) # 80003e42 <readi>
    800050da:	04000793          	li	a5,64
    800050de:	00f51a63          	bne	a0,a5,800050f2 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    800050e2:	e5042703          	lw	a4,-432(s0)
    800050e6:	464c47b7          	lui	a5,0x464c4
    800050ea:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800050ee:	04f70463          	beq	a4,a5,80005136 <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800050f2:	8552                	mv	a0,s4
    800050f4:	fffff097          	auipc	ra,0xfffff
    800050f8:	cfc080e7          	jalr	-772(ra) # 80003df0 <iunlockput>
    end_op();
    800050fc:	fffff097          	auipc	ra,0xfffff
    80005100:	4b2080e7          	jalr	1202(ra) # 800045ae <end_op>
  }
  return -1;
    80005104:	557d                	li	a0,-1
}
    80005106:	20813083          	ld	ra,520(sp)
    8000510a:	20013403          	ld	s0,512(sp)
    8000510e:	74fe                	ld	s1,504(sp)
    80005110:	795e                	ld	s2,496(sp)
    80005112:	79be                	ld	s3,488(sp)
    80005114:	7a1e                	ld	s4,480(sp)
    80005116:	6afe                	ld	s5,472(sp)
    80005118:	6b5e                	ld	s6,464(sp)
    8000511a:	6bbe                	ld	s7,456(sp)
    8000511c:	6c1e                	ld	s8,448(sp)
    8000511e:	7cfa                	ld	s9,440(sp)
    80005120:	7d5a                	ld	s10,432(sp)
    80005122:	7dba                	ld	s11,424(sp)
    80005124:	21010113          	addi	sp,sp,528
    80005128:	8082                	ret
    end_op();
    8000512a:	fffff097          	auipc	ra,0xfffff
    8000512e:	484080e7          	jalr	1156(ra) # 800045ae <end_op>
    return -1;
    80005132:	557d                	li	a0,-1
    80005134:	bfc9                	j	80005106 <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80005136:	8526                	mv	a0,s1
    80005138:	ffffd097          	auipc	ra,0xffffd
    8000513c:	be8080e7          	jalr	-1048(ra) # 80001d20 <proc_pagetable>
    80005140:	8b2a                	mv	s6,a0
    80005142:	d945                	beqz	a0,800050f2 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005144:	e7042d03          	lw	s10,-400(s0)
    80005148:	e8845783          	lhu	a5,-376(s0)
    8000514c:	10078463          	beqz	a5,80005254 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005150:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80005152:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80005154:	6c85                	lui	s9,0x1
    80005156:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    8000515a:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    8000515e:	6a85                	lui	s5,0x1
    80005160:	a0b5                	j	800051cc <exec+0x15e>
      panic("loadseg: address should exist");
    80005162:	00003517          	auipc	a0,0x3
    80005166:	65650513          	addi	a0,a0,1622 # 800087b8 <syscalls+0x298>
    8000516a:	ffffb097          	auipc	ra,0xffffb
    8000516e:	3d2080e7          	jalr	978(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80005172:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80005174:	8726                	mv	a4,s1
    80005176:	012c06bb          	addw	a3,s8,s2
    8000517a:	4581                	li	a1,0
    8000517c:	8552                	mv	a0,s4
    8000517e:	fffff097          	auipc	ra,0xfffff
    80005182:	cc4080e7          	jalr	-828(ra) # 80003e42 <readi>
    80005186:	2501                	sext.w	a0,a0
    80005188:	24a49863          	bne	s1,a0,800053d8 <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    8000518c:	012a893b          	addw	s2,s5,s2
    80005190:	03397563          	bgeu	s2,s3,800051ba <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80005194:	02091593          	slli	a1,s2,0x20
    80005198:	9181                	srli	a1,a1,0x20
    8000519a:	95de                	add	a1,a1,s7
    8000519c:	855a                	mv	a0,s6
    8000519e:	ffffc097          	auipc	ra,0xffffc
    800051a2:	eb8080e7          	jalr	-328(ra) # 80001056 <walkaddr>
    800051a6:	862a                	mv	a2,a0
    if(pa == 0)
    800051a8:	dd4d                	beqz	a0,80005162 <exec+0xf4>
    if(sz - i < PGSIZE)
    800051aa:	412984bb          	subw	s1,s3,s2
    800051ae:	0004879b          	sext.w	a5,s1
    800051b2:	fcfcf0e3          	bgeu	s9,a5,80005172 <exec+0x104>
    800051b6:	84d6                	mv	s1,s5
    800051b8:	bf6d                	j	80005172 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051ba:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800051be:	2d85                	addiw	s11,s11,1
    800051c0:	038d0d1b          	addiw	s10,s10,56
    800051c4:	e8845783          	lhu	a5,-376(s0)
    800051c8:	08fdd763          	bge	s11,a5,80005256 <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800051cc:	2d01                	sext.w	s10,s10
    800051ce:	03800713          	li	a4,56
    800051d2:	86ea                	mv	a3,s10
    800051d4:	e1840613          	addi	a2,s0,-488
    800051d8:	4581                	li	a1,0
    800051da:	8552                	mv	a0,s4
    800051dc:	fffff097          	auipc	ra,0xfffff
    800051e0:	c66080e7          	jalr	-922(ra) # 80003e42 <readi>
    800051e4:	03800793          	li	a5,56
    800051e8:	1ef51663          	bne	a0,a5,800053d4 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    800051ec:	e1842783          	lw	a5,-488(s0)
    800051f0:	4705                	li	a4,1
    800051f2:	fce796e3          	bne	a5,a4,800051be <exec+0x150>
    if(ph.memsz < ph.filesz)
    800051f6:	e4043483          	ld	s1,-448(s0)
    800051fa:	e3843783          	ld	a5,-456(s0)
    800051fe:	1ef4e863          	bltu	s1,a5,800053ee <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80005202:	e2843783          	ld	a5,-472(s0)
    80005206:	94be                	add	s1,s1,a5
    80005208:	1ef4e663          	bltu	s1,a5,800053f4 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    8000520c:	df043703          	ld	a4,-528(s0)
    80005210:	8ff9                	and	a5,a5,a4
    80005212:	1e079463          	bnez	a5,800053fa <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005216:	e1c42503          	lw	a0,-484(s0)
    8000521a:	00000097          	auipc	ra,0x0
    8000521e:	e3a080e7          	jalr	-454(ra) # 80005054 <flags2perm>
    80005222:	86aa                	mv	a3,a0
    80005224:	8626                	mv	a2,s1
    80005226:	85ca                	mv	a1,s2
    80005228:	855a                	mv	a0,s6
    8000522a:	ffffc097          	auipc	ra,0xffffc
    8000522e:	1e0080e7          	jalr	480(ra) # 8000140a <uvmalloc>
    80005232:	e0a43423          	sd	a0,-504(s0)
    80005236:	1c050563          	beqz	a0,80005400 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    8000523a:	e2843b83          	ld	s7,-472(s0)
    8000523e:	e2042c03          	lw	s8,-480(s0)
    80005242:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80005246:	00098463          	beqz	s3,8000524e <exec+0x1e0>
    8000524a:	4901                	li	s2,0
    8000524c:	b7a1                	j	80005194 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000524e:	e0843903          	ld	s2,-504(s0)
    80005252:	b7b5                	j	800051be <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80005254:	4901                	li	s2,0
  iunlockput(ip);
    80005256:	8552                	mv	a0,s4
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	b98080e7          	jalr	-1128(ra) # 80003df0 <iunlockput>
  end_op();
    80005260:	fffff097          	auipc	ra,0xfffff
    80005264:	34e080e7          	jalr	846(ra) # 800045ae <end_op>
  p = myproc();
    80005268:	ffffd097          	auipc	ra,0xffffd
    8000526c:	9f4080e7          	jalr	-1548(ra) # 80001c5c <myproc>
    80005270:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80005272:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80005276:	6985                	lui	s3,0x1
    80005278:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    8000527a:	99ca                	add	s3,s3,s2
    8000527c:	77fd                	lui	a5,0xfffff
    8000527e:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80005282:	4691                	li	a3,4
    80005284:	6609                	lui	a2,0x2
    80005286:	964e                	add	a2,a2,s3
    80005288:	85ce                	mv	a1,s3
    8000528a:	855a                	mv	a0,s6
    8000528c:	ffffc097          	auipc	ra,0xffffc
    80005290:	17e080e7          	jalr	382(ra) # 8000140a <uvmalloc>
    80005294:	892a                	mv	s2,a0
    80005296:	e0a43423          	sd	a0,-504(s0)
    8000529a:	e509                	bnez	a0,800052a4 <exec+0x236>
  if(pagetable)
    8000529c:	e1343423          	sd	s3,-504(s0)
    800052a0:	4a01                	li	s4,0
    800052a2:	aa1d                	j	800053d8 <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    800052a4:	75f9                	lui	a1,0xffffe
    800052a6:	95aa                	add	a1,a1,a0
    800052a8:	855a                	mv	a0,s6
    800052aa:	ffffc097          	auipc	ra,0xffffc
    800052ae:	38a080e7          	jalr	906(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    800052b2:	7bfd                	lui	s7,0xfffff
    800052b4:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    800052b6:	e0043783          	ld	a5,-512(s0)
    800052ba:	6388                	ld	a0,0(a5)
    800052bc:	c52d                	beqz	a0,80005326 <exec+0x2b8>
    800052be:	e9040993          	addi	s3,s0,-368
    800052c2:	f9040c13          	addi	s8,s0,-112
    800052c6:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    800052c8:	ffffc097          	auipc	ra,0xffffc
    800052cc:	b80080e7          	jalr	-1152(ra) # 80000e48 <strlen>
    800052d0:	0015079b          	addiw	a5,a0,1
    800052d4:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    800052d8:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    800052dc:	13796563          	bltu	s2,s7,80005406 <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    800052e0:	e0043d03          	ld	s10,-512(s0)
    800052e4:	000d3a03          	ld	s4,0(s10)
    800052e8:	8552                	mv	a0,s4
    800052ea:	ffffc097          	auipc	ra,0xffffc
    800052ee:	b5e080e7          	jalr	-1186(ra) # 80000e48 <strlen>
    800052f2:	0015069b          	addiw	a3,a0,1
    800052f6:	8652                	mv	a2,s4
    800052f8:	85ca                	mv	a1,s2
    800052fa:	855a                	mv	a0,s6
    800052fc:	ffffc097          	auipc	ra,0xffffc
    80005300:	36a080e7          	jalr	874(ra) # 80001666 <copyout>
    80005304:	10054363          	bltz	a0,8000540a <exec+0x39c>
    ustack[argc] = sp;
    80005308:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000530c:	0485                	addi	s1,s1,1
    8000530e:	008d0793          	addi	a5,s10,8
    80005312:	e0f43023          	sd	a5,-512(s0)
    80005316:	008d3503          	ld	a0,8(s10)
    8000531a:	c909                	beqz	a0,8000532c <exec+0x2be>
    if(argc >= MAXARG)
    8000531c:	09a1                	addi	s3,s3,8
    8000531e:	fb8995e3          	bne	s3,s8,800052c8 <exec+0x25a>
  ip = 0;
    80005322:	4a01                	li	s4,0
    80005324:	a855                	j	800053d8 <exec+0x36a>
  sp = sz;
    80005326:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    8000532a:	4481                	li	s1,0
  ustack[argc] = 0;
    8000532c:	00349793          	slli	a5,s1,0x3
    80005330:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd010>
    80005334:	97a2                	add	a5,a5,s0
    80005336:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    8000533a:	00148693          	addi	a3,s1,1
    8000533e:	068e                	slli	a3,a3,0x3
    80005340:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80005344:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80005348:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    8000534c:	f57968e3          	bltu	s2,s7,8000529c <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005350:	e9040613          	addi	a2,s0,-368
    80005354:	85ca                	mv	a1,s2
    80005356:	855a                	mv	a0,s6
    80005358:	ffffc097          	auipc	ra,0xffffc
    8000535c:	30e080e7          	jalr	782(ra) # 80001666 <copyout>
    80005360:	0a054763          	bltz	a0,8000540e <exec+0x3a0>
  p->trapframe->a1 = sp;
    80005364:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80005368:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    8000536c:	df843783          	ld	a5,-520(s0)
    80005370:	0007c703          	lbu	a4,0(a5)
    80005374:	cf11                	beqz	a4,80005390 <exec+0x322>
    80005376:	0785                	addi	a5,a5,1
    if(*s == '/')
    80005378:	02f00693          	li	a3,47
    8000537c:	a039                	j	8000538a <exec+0x31c>
      last = s+1;
    8000537e:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80005382:	0785                	addi	a5,a5,1
    80005384:	fff7c703          	lbu	a4,-1(a5)
    80005388:	c701                	beqz	a4,80005390 <exec+0x322>
    if(*s == '/')
    8000538a:	fed71ce3          	bne	a4,a3,80005382 <exec+0x314>
    8000538e:	bfc5                	j	8000537e <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80005390:	4641                	li	a2,16
    80005392:	df843583          	ld	a1,-520(s0)
    80005396:	158a8513          	addi	a0,s5,344
    8000539a:	ffffc097          	auipc	ra,0xffffc
    8000539e:	a7c080e7          	jalr	-1412(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    800053a2:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800053a6:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    800053aa:	e0843783          	ld	a5,-504(s0)
    800053ae:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800053b2:	058ab783          	ld	a5,88(s5)
    800053b6:	e6843703          	ld	a4,-408(s0)
    800053ba:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800053bc:	058ab783          	ld	a5,88(s5)
    800053c0:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800053c4:	85e6                	mv	a1,s9
    800053c6:	ffffd097          	auipc	ra,0xffffd
    800053ca:	9f6080e7          	jalr	-1546(ra) # 80001dbc <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800053ce:	0004851b          	sext.w	a0,s1
    800053d2:	bb15                	j	80005106 <exec+0x98>
    800053d4:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    800053d8:	e0843583          	ld	a1,-504(s0)
    800053dc:	855a                	mv	a0,s6
    800053de:	ffffd097          	auipc	ra,0xffffd
    800053e2:	9de080e7          	jalr	-1570(ra) # 80001dbc <proc_freepagetable>
  return -1;
    800053e6:	557d                	li	a0,-1
  if(ip){
    800053e8:	d00a0fe3          	beqz	s4,80005106 <exec+0x98>
    800053ec:	b319                	j	800050f2 <exec+0x84>
    800053ee:	e1243423          	sd	s2,-504(s0)
    800053f2:	b7dd                	j	800053d8 <exec+0x36a>
    800053f4:	e1243423          	sd	s2,-504(s0)
    800053f8:	b7c5                	j	800053d8 <exec+0x36a>
    800053fa:	e1243423          	sd	s2,-504(s0)
    800053fe:	bfe9                	j	800053d8 <exec+0x36a>
    80005400:	e1243423          	sd	s2,-504(s0)
    80005404:	bfd1                	j	800053d8 <exec+0x36a>
  ip = 0;
    80005406:	4a01                	li	s4,0
    80005408:	bfc1                	j	800053d8 <exec+0x36a>
    8000540a:	4a01                	li	s4,0
  if(pagetable)
    8000540c:	b7f1                	j	800053d8 <exec+0x36a>
  sz = sz1;
    8000540e:	e0843983          	ld	s3,-504(s0)
    80005412:	b569                	j	8000529c <exec+0x22e>

0000000080005414 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005414:	7179                	addi	sp,sp,-48
    80005416:	f406                	sd	ra,40(sp)
    80005418:	f022                	sd	s0,32(sp)
    8000541a:	ec26                	sd	s1,24(sp)
    8000541c:	e84a                	sd	s2,16(sp)
    8000541e:	1800                	addi	s0,sp,48
    80005420:	892e                	mv	s2,a1
    80005422:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005424:	fdc40593          	addi	a1,s0,-36
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	b74080e7          	jalr	-1164(ra) # 80002f9c <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005430:	fdc42703          	lw	a4,-36(s0)
    80005434:	47bd                	li	a5,15
    80005436:	02e7eb63          	bltu	a5,a4,8000546c <argfd+0x58>
    8000543a:	ffffd097          	auipc	ra,0xffffd
    8000543e:	822080e7          	jalr	-2014(ra) # 80001c5c <myproc>
    80005442:	fdc42703          	lw	a4,-36(s0)
    80005446:	01a70793          	addi	a5,a4,26
    8000544a:	078e                	slli	a5,a5,0x3
    8000544c:	953e                	add	a0,a0,a5
    8000544e:	611c                	ld	a5,0(a0)
    80005450:	c385                	beqz	a5,80005470 <argfd+0x5c>
    return -1;
  if(pfd)
    80005452:	00090463          	beqz	s2,8000545a <argfd+0x46>
    *pfd = fd;
    80005456:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000545a:	4501                	li	a0,0
  if(pf)
    8000545c:	c091                	beqz	s1,80005460 <argfd+0x4c>
    *pf = f;
    8000545e:	e09c                	sd	a5,0(s1)
}
    80005460:	70a2                	ld	ra,40(sp)
    80005462:	7402                	ld	s0,32(sp)
    80005464:	64e2                	ld	s1,24(sp)
    80005466:	6942                	ld	s2,16(sp)
    80005468:	6145                	addi	sp,sp,48
    8000546a:	8082                	ret
    return -1;
    8000546c:	557d                	li	a0,-1
    8000546e:	bfcd                	j	80005460 <argfd+0x4c>
    80005470:	557d                	li	a0,-1
    80005472:	b7fd                	j	80005460 <argfd+0x4c>

0000000080005474 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005474:	1101                	addi	sp,sp,-32
    80005476:	ec06                	sd	ra,24(sp)
    80005478:	e822                	sd	s0,16(sp)
    8000547a:	e426                	sd	s1,8(sp)
    8000547c:	1000                	addi	s0,sp,32
    8000547e:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005480:	ffffc097          	auipc	ra,0xffffc
    80005484:	7dc080e7          	jalr	2012(ra) # 80001c5c <myproc>
    80005488:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000548a:	0d050793          	addi	a5,a0,208
    8000548e:	4501                	li	a0,0
    80005490:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005492:	6398                	ld	a4,0(a5)
    80005494:	cb19                	beqz	a4,800054aa <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005496:	2505                	addiw	a0,a0,1
    80005498:	07a1                	addi	a5,a5,8
    8000549a:	fed51ce3          	bne	a0,a3,80005492 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000549e:	557d                	li	a0,-1
}
    800054a0:	60e2                	ld	ra,24(sp)
    800054a2:	6442                	ld	s0,16(sp)
    800054a4:	64a2                	ld	s1,8(sp)
    800054a6:	6105                	addi	sp,sp,32
    800054a8:	8082                	ret
      p->ofile[fd] = f;
    800054aa:	01a50793          	addi	a5,a0,26
    800054ae:	078e                	slli	a5,a5,0x3
    800054b0:	963e                	add	a2,a2,a5
    800054b2:	e204                	sd	s1,0(a2)
      return fd;
    800054b4:	b7f5                	j	800054a0 <fdalloc+0x2c>

00000000800054b6 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800054b6:	715d                	addi	sp,sp,-80
    800054b8:	e486                	sd	ra,72(sp)
    800054ba:	e0a2                	sd	s0,64(sp)
    800054bc:	fc26                	sd	s1,56(sp)
    800054be:	f84a                	sd	s2,48(sp)
    800054c0:	f44e                	sd	s3,40(sp)
    800054c2:	f052                	sd	s4,32(sp)
    800054c4:	ec56                	sd	s5,24(sp)
    800054c6:	e85a                	sd	s6,16(sp)
    800054c8:	0880                	addi	s0,sp,80
    800054ca:	8b2e                	mv	s6,a1
    800054cc:	89b2                	mv	s3,a2
    800054ce:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800054d0:	fb040593          	addi	a1,s0,-80
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	e7e080e7          	jalr	-386(ra) # 80004352 <nameiparent>
    800054dc:	84aa                	mv	s1,a0
    800054de:	14050b63          	beqz	a0,80005634 <create+0x17e>
    return 0;

  ilock(dp);
    800054e2:	ffffe097          	auipc	ra,0xffffe
    800054e6:	6ac080e7          	jalr	1708(ra) # 80003b8e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800054ea:	4601                	li	a2,0
    800054ec:	fb040593          	addi	a1,s0,-80
    800054f0:	8526                	mv	a0,s1
    800054f2:	fffff097          	auipc	ra,0xfffff
    800054f6:	b80080e7          	jalr	-1152(ra) # 80004072 <dirlookup>
    800054fa:	8aaa                	mv	s5,a0
    800054fc:	c921                	beqz	a0,8000554c <create+0x96>
    iunlockput(dp);
    800054fe:	8526                	mv	a0,s1
    80005500:	fffff097          	auipc	ra,0xfffff
    80005504:	8f0080e7          	jalr	-1808(ra) # 80003df0 <iunlockput>
    ilock(ip);
    80005508:	8556                	mv	a0,s5
    8000550a:	ffffe097          	auipc	ra,0xffffe
    8000550e:	684080e7          	jalr	1668(ra) # 80003b8e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005512:	4789                	li	a5,2
    80005514:	02fb1563          	bne	s6,a5,8000553e <create+0x88>
    80005518:	044ad783          	lhu	a5,68(s5)
    8000551c:	37f9                	addiw	a5,a5,-2
    8000551e:	17c2                	slli	a5,a5,0x30
    80005520:	93c1                	srli	a5,a5,0x30
    80005522:	4705                	li	a4,1
    80005524:	00f76d63          	bltu	a4,a5,8000553e <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005528:	8556                	mv	a0,s5
    8000552a:	60a6                	ld	ra,72(sp)
    8000552c:	6406                	ld	s0,64(sp)
    8000552e:	74e2                	ld	s1,56(sp)
    80005530:	7942                	ld	s2,48(sp)
    80005532:	79a2                	ld	s3,40(sp)
    80005534:	7a02                	ld	s4,32(sp)
    80005536:	6ae2                	ld	s5,24(sp)
    80005538:	6b42                	ld	s6,16(sp)
    8000553a:	6161                	addi	sp,sp,80
    8000553c:	8082                	ret
    iunlockput(ip);
    8000553e:	8556                	mv	a0,s5
    80005540:	fffff097          	auipc	ra,0xfffff
    80005544:	8b0080e7          	jalr	-1872(ra) # 80003df0 <iunlockput>
    return 0;
    80005548:	4a81                	li	s5,0
    8000554a:	bff9                	j	80005528 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000554c:	85da                	mv	a1,s6
    8000554e:	4088                	lw	a0,0(s1)
    80005550:	ffffe097          	auipc	ra,0xffffe
    80005554:	4a6080e7          	jalr	1190(ra) # 800039f6 <ialloc>
    80005558:	8a2a                	mv	s4,a0
    8000555a:	c529                	beqz	a0,800055a4 <create+0xee>
  ilock(ip);
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	632080e7          	jalr	1586(ra) # 80003b8e <ilock>
  ip->major = major;
    80005564:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005568:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000556c:	4905                	li	s2,1
    8000556e:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005572:	8552                	mv	a0,s4
    80005574:	ffffe097          	auipc	ra,0xffffe
    80005578:	54e080e7          	jalr	1358(ra) # 80003ac2 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000557c:	032b0b63          	beq	s6,s2,800055b2 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005580:	004a2603          	lw	a2,4(s4)
    80005584:	fb040593          	addi	a1,s0,-80
    80005588:	8526                	mv	a0,s1
    8000558a:	fffff097          	auipc	ra,0xfffff
    8000558e:	cf8080e7          	jalr	-776(ra) # 80004282 <dirlink>
    80005592:	06054f63          	bltz	a0,80005610 <create+0x15a>
  iunlockput(dp);
    80005596:	8526                	mv	a0,s1
    80005598:	fffff097          	auipc	ra,0xfffff
    8000559c:	858080e7          	jalr	-1960(ra) # 80003df0 <iunlockput>
  return ip;
    800055a0:	8ad2                	mv	s5,s4
    800055a2:	b759                	j	80005528 <create+0x72>
    iunlockput(dp);
    800055a4:	8526                	mv	a0,s1
    800055a6:	fffff097          	auipc	ra,0xfffff
    800055aa:	84a080e7          	jalr	-1974(ra) # 80003df0 <iunlockput>
    return 0;
    800055ae:	8ad2                	mv	s5,s4
    800055b0:	bfa5                	j	80005528 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800055b2:	004a2603          	lw	a2,4(s4)
    800055b6:	00003597          	auipc	a1,0x3
    800055ba:	22258593          	addi	a1,a1,546 # 800087d8 <syscalls+0x2b8>
    800055be:	8552                	mv	a0,s4
    800055c0:	fffff097          	auipc	ra,0xfffff
    800055c4:	cc2080e7          	jalr	-830(ra) # 80004282 <dirlink>
    800055c8:	04054463          	bltz	a0,80005610 <create+0x15a>
    800055cc:	40d0                	lw	a2,4(s1)
    800055ce:	00003597          	auipc	a1,0x3
    800055d2:	21258593          	addi	a1,a1,530 # 800087e0 <syscalls+0x2c0>
    800055d6:	8552                	mv	a0,s4
    800055d8:	fffff097          	auipc	ra,0xfffff
    800055dc:	caa080e7          	jalr	-854(ra) # 80004282 <dirlink>
    800055e0:	02054863          	bltz	a0,80005610 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800055e4:	004a2603          	lw	a2,4(s4)
    800055e8:	fb040593          	addi	a1,s0,-80
    800055ec:	8526                	mv	a0,s1
    800055ee:	fffff097          	auipc	ra,0xfffff
    800055f2:	c94080e7          	jalr	-876(ra) # 80004282 <dirlink>
    800055f6:	00054d63          	bltz	a0,80005610 <create+0x15a>
    dp->nlink++;  // for ".."
    800055fa:	04a4d783          	lhu	a5,74(s1)
    800055fe:	2785                	addiw	a5,a5,1
    80005600:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005604:	8526                	mv	a0,s1
    80005606:	ffffe097          	auipc	ra,0xffffe
    8000560a:	4bc080e7          	jalr	1212(ra) # 80003ac2 <iupdate>
    8000560e:	b761                	j	80005596 <create+0xe0>
  ip->nlink = 0;
    80005610:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005614:	8552                	mv	a0,s4
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	4ac080e7          	jalr	1196(ra) # 80003ac2 <iupdate>
  iunlockput(ip);
    8000561e:	8552                	mv	a0,s4
    80005620:	ffffe097          	auipc	ra,0xffffe
    80005624:	7d0080e7          	jalr	2000(ra) # 80003df0 <iunlockput>
  iunlockput(dp);
    80005628:	8526                	mv	a0,s1
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	7c6080e7          	jalr	1990(ra) # 80003df0 <iunlockput>
  return 0;
    80005632:	bddd                	j	80005528 <create+0x72>
    return 0;
    80005634:	8aaa                	mv	s5,a0
    80005636:	bdcd                	j	80005528 <create+0x72>

0000000080005638 <sys_dup>:
{
    80005638:	7179                	addi	sp,sp,-48
    8000563a:	f406                	sd	ra,40(sp)
    8000563c:	f022                	sd	s0,32(sp)
    8000563e:	ec26                	sd	s1,24(sp)
    80005640:	e84a                	sd	s2,16(sp)
    80005642:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005644:	fd840613          	addi	a2,s0,-40
    80005648:	4581                	li	a1,0
    8000564a:	4501                	li	a0,0
    8000564c:	00000097          	auipc	ra,0x0
    80005650:	dc8080e7          	jalr	-568(ra) # 80005414 <argfd>
    return -1;
    80005654:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005656:	02054363          	bltz	a0,8000567c <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000565a:	fd843903          	ld	s2,-40(s0)
    8000565e:	854a                	mv	a0,s2
    80005660:	00000097          	auipc	ra,0x0
    80005664:	e14080e7          	jalr	-492(ra) # 80005474 <fdalloc>
    80005668:	84aa                	mv	s1,a0
    return -1;
    8000566a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000566c:	00054863          	bltz	a0,8000567c <sys_dup+0x44>
  filedup(f);
    80005670:	854a                	mv	a0,s2
    80005672:	fffff097          	auipc	ra,0xfffff
    80005676:	334080e7          	jalr	820(ra) # 800049a6 <filedup>
  return fd;
    8000567a:	87a6                	mv	a5,s1
}
    8000567c:	853e                	mv	a0,a5
    8000567e:	70a2                	ld	ra,40(sp)
    80005680:	7402                	ld	s0,32(sp)
    80005682:	64e2                	ld	s1,24(sp)
    80005684:	6942                	ld	s2,16(sp)
    80005686:	6145                	addi	sp,sp,48
    80005688:	8082                	ret

000000008000568a <sys_read>:
{
    8000568a:	7179                	addi	sp,sp,-48
    8000568c:	f406                	sd	ra,40(sp)
    8000568e:	f022                	sd	s0,32(sp)
    80005690:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005692:	fd840593          	addi	a1,s0,-40
    80005696:	4505                	li	a0,1
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	924080e7          	jalr	-1756(ra) # 80002fbc <argaddr>
  argint(2, &n);
    800056a0:	fe440593          	addi	a1,s0,-28
    800056a4:	4509                	li	a0,2
    800056a6:	ffffe097          	auipc	ra,0xffffe
    800056aa:	8f6080e7          	jalr	-1802(ra) # 80002f9c <argint>
  if(argfd(0, 0, &f) < 0)
    800056ae:	fe840613          	addi	a2,s0,-24
    800056b2:	4581                	li	a1,0
    800056b4:	4501                	li	a0,0
    800056b6:	00000097          	auipc	ra,0x0
    800056ba:	d5e080e7          	jalr	-674(ra) # 80005414 <argfd>
    800056be:	87aa                	mv	a5,a0
    return -1;
    800056c0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800056c2:	0007cc63          	bltz	a5,800056da <sys_read+0x50>
  return fileread(f, p, n);
    800056c6:	fe442603          	lw	a2,-28(s0)
    800056ca:	fd843583          	ld	a1,-40(s0)
    800056ce:	fe843503          	ld	a0,-24(s0)
    800056d2:	fffff097          	auipc	ra,0xfffff
    800056d6:	460080e7          	jalr	1120(ra) # 80004b32 <fileread>
}
    800056da:	70a2                	ld	ra,40(sp)
    800056dc:	7402                	ld	s0,32(sp)
    800056de:	6145                	addi	sp,sp,48
    800056e0:	8082                	ret

00000000800056e2 <sys_write>:
{
    800056e2:	7179                	addi	sp,sp,-48
    800056e4:	f406                	sd	ra,40(sp)
    800056e6:	f022                	sd	s0,32(sp)
    800056e8:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800056ea:	fd840593          	addi	a1,s0,-40
    800056ee:	4505                	li	a0,1
    800056f0:	ffffe097          	auipc	ra,0xffffe
    800056f4:	8cc080e7          	jalr	-1844(ra) # 80002fbc <argaddr>
  argint(2, &n);
    800056f8:	fe440593          	addi	a1,s0,-28
    800056fc:	4509                	li	a0,2
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	89e080e7          	jalr	-1890(ra) # 80002f9c <argint>
  if(argfd(0, 0, &f) < 0)
    80005706:	fe840613          	addi	a2,s0,-24
    8000570a:	4581                	li	a1,0
    8000570c:	4501                	li	a0,0
    8000570e:	00000097          	auipc	ra,0x0
    80005712:	d06080e7          	jalr	-762(ra) # 80005414 <argfd>
    80005716:	87aa                	mv	a5,a0
    return -1;
    80005718:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000571a:	0007cc63          	bltz	a5,80005732 <sys_write+0x50>
  return filewrite(f, p, n);
    8000571e:	fe442603          	lw	a2,-28(s0)
    80005722:	fd843583          	ld	a1,-40(s0)
    80005726:	fe843503          	ld	a0,-24(s0)
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	4ca080e7          	jalr	1226(ra) # 80004bf4 <filewrite>
}
    80005732:	70a2                	ld	ra,40(sp)
    80005734:	7402                	ld	s0,32(sp)
    80005736:	6145                	addi	sp,sp,48
    80005738:	8082                	ret

000000008000573a <sys_close>:
{
    8000573a:	1101                	addi	sp,sp,-32
    8000573c:	ec06                	sd	ra,24(sp)
    8000573e:	e822                	sd	s0,16(sp)
    80005740:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005742:	fe040613          	addi	a2,s0,-32
    80005746:	fec40593          	addi	a1,s0,-20
    8000574a:	4501                	li	a0,0
    8000574c:	00000097          	auipc	ra,0x0
    80005750:	cc8080e7          	jalr	-824(ra) # 80005414 <argfd>
    return -1;
    80005754:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005756:	02054463          	bltz	a0,8000577e <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000575a:	ffffc097          	auipc	ra,0xffffc
    8000575e:	502080e7          	jalr	1282(ra) # 80001c5c <myproc>
    80005762:	fec42783          	lw	a5,-20(s0)
    80005766:	07e9                	addi	a5,a5,26
    80005768:	078e                	slli	a5,a5,0x3
    8000576a:	953e                	add	a0,a0,a5
    8000576c:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005770:	fe043503          	ld	a0,-32(s0)
    80005774:	fffff097          	auipc	ra,0xfffff
    80005778:	284080e7          	jalr	644(ra) # 800049f8 <fileclose>
  return 0;
    8000577c:	4781                	li	a5,0
}
    8000577e:	853e                	mv	a0,a5
    80005780:	60e2                	ld	ra,24(sp)
    80005782:	6442                	ld	s0,16(sp)
    80005784:	6105                	addi	sp,sp,32
    80005786:	8082                	ret

0000000080005788 <sys_fstat>:
{
    80005788:	1101                	addi	sp,sp,-32
    8000578a:	ec06                	sd	ra,24(sp)
    8000578c:	e822                	sd	s0,16(sp)
    8000578e:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005790:	fe040593          	addi	a1,s0,-32
    80005794:	4505                	li	a0,1
    80005796:	ffffe097          	auipc	ra,0xffffe
    8000579a:	826080e7          	jalr	-2010(ra) # 80002fbc <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000579e:	fe840613          	addi	a2,s0,-24
    800057a2:	4581                	li	a1,0
    800057a4:	4501                	li	a0,0
    800057a6:	00000097          	auipc	ra,0x0
    800057aa:	c6e080e7          	jalr	-914(ra) # 80005414 <argfd>
    800057ae:	87aa                	mv	a5,a0
    return -1;
    800057b0:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800057b2:	0007ca63          	bltz	a5,800057c6 <sys_fstat+0x3e>
  return filestat(f, st);
    800057b6:	fe043583          	ld	a1,-32(s0)
    800057ba:	fe843503          	ld	a0,-24(s0)
    800057be:	fffff097          	auipc	ra,0xfffff
    800057c2:	302080e7          	jalr	770(ra) # 80004ac0 <filestat>
}
    800057c6:	60e2                	ld	ra,24(sp)
    800057c8:	6442                	ld	s0,16(sp)
    800057ca:	6105                	addi	sp,sp,32
    800057cc:	8082                	ret

00000000800057ce <sys_link>:
{
    800057ce:	7169                	addi	sp,sp,-304
    800057d0:	f606                	sd	ra,296(sp)
    800057d2:	f222                	sd	s0,288(sp)
    800057d4:	ee26                	sd	s1,280(sp)
    800057d6:	ea4a                	sd	s2,272(sp)
    800057d8:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057da:	08000613          	li	a2,128
    800057de:	ed040593          	addi	a1,s0,-304
    800057e2:	4501                	li	a0,0
    800057e4:	ffffd097          	auipc	ra,0xffffd
    800057e8:	7f8080e7          	jalr	2040(ra) # 80002fdc <argstr>
    return -1;
    800057ec:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800057ee:	10054e63          	bltz	a0,8000590a <sys_link+0x13c>
    800057f2:	08000613          	li	a2,128
    800057f6:	f5040593          	addi	a1,s0,-176
    800057fa:	4505                	li	a0,1
    800057fc:	ffffd097          	auipc	ra,0xffffd
    80005800:	7e0080e7          	jalr	2016(ra) # 80002fdc <argstr>
    return -1;
    80005804:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005806:	10054263          	bltz	a0,8000590a <sys_link+0x13c>
  begin_op();
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	d2a080e7          	jalr	-726(ra) # 80004534 <begin_op>
  if((ip = namei(old)) == 0){
    80005812:	ed040513          	addi	a0,s0,-304
    80005816:	fffff097          	auipc	ra,0xfffff
    8000581a:	b1e080e7          	jalr	-1250(ra) # 80004334 <namei>
    8000581e:	84aa                	mv	s1,a0
    80005820:	c551                	beqz	a0,800058ac <sys_link+0xde>
  ilock(ip);
    80005822:	ffffe097          	auipc	ra,0xffffe
    80005826:	36c080e7          	jalr	876(ra) # 80003b8e <ilock>
  if(ip->type == T_DIR){
    8000582a:	04449703          	lh	a4,68(s1)
    8000582e:	4785                	li	a5,1
    80005830:	08f70463          	beq	a4,a5,800058b8 <sys_link+0xea>
  ip->nlink++;
    80005834:	04a4d783          	lhu	a5,74(s1)
    80005838:	2785                	addiw	a5,a5,1
    8000583a:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000583e:	8526                	mv	a0,s1
    80005840:	ffffe097          	auipc	ra,0xffffe
    80005844:	282080e7          	jalr	642(ra) # 80003ac2 <iupdate>
  iunlock(ip);
    80005848:	8526                	mv	a0,s1
    8000584a:	ffffe097          	auipc	ra,0xffffe
    8000584e:	406080e7          	jalr	1030(ra) # 80003c50 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005852:	fd040593          	addi	a1,s0,-48
    80005856:	f5040513          	addi	a0,s0,-176
    8000585a:	fffff097          	auipc	ra,0xfffff
    8000585e:	af8080e7          	jalr	-1288(ra) # 80004352 <nameiparent>
    80005862:	892a                	mv	s2,a0
    80005864:	c935                	beqz	a0,800058d8 <sys_link+0x10a>
  ilock(dp);
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	328080e7          	jalr	808(ra) # 80003b8e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000586e:	00092703          	lw	a4,0(s2)
    80005872:	409c                	lw	a5,0(s1)
    80005874:	04f71d63          	bne	a4,a5,800058ce <sys_link+0x100>
    80005878:	40d0                	lw	a2,4(s1)
    8000587a:	fd040593          	addi	a1,s0,-48
    8000587e:	854a                	mv	a0,s2
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	a02080e7          	jalr	-1534(ra) # 80004282 <dirlink>
    80005888:	04054363          	bltz	a0,800058ce <sys_link+0x100>
  iunlockput(dp);
    8000588c:	854a                	mv	a0,s2
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	562080e7          	jalr	1378(ra) # 80003df0 <iunlockput>
  iput(ip);
    80005896:	8526                	mv	a0,s1
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	4b0080e7          	jalr	1200(ra) # 80003d48 <iput>
  end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	d0e080e7          	jalr	-754(ra) # 800045ae <end_op>
  return 0;
    800058a8:	4781                	li	a5,0
    800058aa:	a085                	j	8000590a <sys_link+0x13c>
    end_op();
    800058ac:	fffff097          	auipc	ra,0xfffff
    800058b0:	d02080e7          	jalr	-766(ra) # 800045ae <end_op>
    return -1;
    800058b4:	57fd                	li	a5,-1
    800058b6:	a891                	j	8000590a <sys_link+0x13c>
    iunlockput(ip);
    800058b8:	8526                	mv	a0,s1
    800058ba:	ffffe097          	auipc	ra,0xffffe
    800058be:	536080e7          	jalr	1334(ra) # 80003df0 <iunlockput>
    end_op();
    800058c2:	fffff097          	auipc	ra,0xfffff
    800058c6:	cec080e7          	jalr	-788(ra) # 800045ae <end_op>
    return -1;
    800058ca:	57fd                	li	a5,-1
    800058cc:	a83d                	j	8000590a <sys_link+0x13c>
    iunlockput(dp);
    800058ce:	854a                	mv	a0,s2
    800058d0:	ffffe097          	auipc	ra,0xffffe
    800058d4:	520080e7          	jalr	1312(ra) # 80003df0 <iunlockput>
  ilock(ip);
    800058d8:	8526                	mv	a0,s1
    800058da:	ffffe097          	auipc	ra,0xffffe
    800058de:	2b4080e7          	jalr	692(ra) # 80003b8e <ilock>
  ip->nlink--;
    800058e2:	04a4d783          	lhu	a5,74(s1)
    800058e6:	37fd                	addiw	a5,a5,-1
    800058e8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800058ec:	8526                	mv	a0,s1
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	1d4080e7          	jalr	468(ra) # 80003ac2 <iupdate>
  iunlockput(ip);
    800058f6:	8526                	mv	a0,s1
    800058f8:	ffffe097          	auipc	ra,0xffffe
    800058fc:	4f8080e7          	jalr	1272(ra) # 80003df0 <iunlockput>
  end_op();
    80005900:	fffff097          	auipc	ra,0xfffff
    80005904:	cae080e7          	jalr	-850(ra) # 800045ae <end_op>
  return -1;
    80005908:	57fd                	li	a5,-1
}
    8000590a:	853e                	mv	a0,a5
    8000590c:	70b2                	ld	ra,296(sp)
    8000590e:	7412                	ld	s0,288(sp)
    80005910:	64f2                	ld	s1,280(sp)
    80005912:	6952                	ld	s2,272(sp)
    80005914:	6155                	addi	sp,sp,304
    80005916:	8082                	ret

0000000080005918 <sys_unlink>:
{
    80005918:	7151                	addi	sp,sp,-240
    8000591a:	f586                	sd	ra,232(sp)
    8000591c:	f1a2                	sd	s0,224(sp)
    8000591e:	eda6                	sd	s1,216(sp)
    80005920:	e9ca                	sd	s2,208(sp)
    80005922:	e5ce                	sd	s3,200(sp)
    80005924:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005926:	08000613          	li	a2,128
    8000592a:	f3040593          	addi	a1,s0,-208
    8000592e:	4501                	li	a0,0
    80005930:	ffffd097          	auipc	ra,0xffffd
    80005934:	6ac080e7          	jalr	1708(ra) # 80002fdc <argstr>
    80005938:	18054163          	bltz	a0,80005aba <sys_unlink+0x1a2>
  begin_op();
    8000593c:	fffff097          	auipc	ra,0xfffff
    80005940:	bf8080e7          	jalr	-1032(ra) # 80004534 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005944:	fb040593          	addi	a1,s0,-80
    80005948:	f3040513          	addi	a0,s0,-208
    8000594c:	fffff097          	auipc	ra,0xfffff
    80005950:	a06080e7          	jalr	-1530(ra) # 80004352 <nameiparent>
    80005954:	84aa                	mv	s1,a0
    80005956:	c979                	beqz	a0,80005a2c <sys_unlink+0x114>
  ilock(dp);
    80005958:	ffffe097          	auipc	ra,0xffffe
    8000595c:	236080e7          	jalr	566(ra) # 80003b8e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005960:	00003597          	auipc	a1,0x3
    80005964:	e7858593          	addi	a1,a1,-392 # 800087d8 <syscalls+0x2b8>
    80005968:	fb040513          	addi	a0,s0,-80
    8000596c:	ffffe097          	auipc	ra,0xffffe
    80005970:	6ec080e7          	jalr	1772(ra) # 80004058 <namecmp>
    80005974:	14050a63          	beqz	a0,80005ac8 <sys_unlink+0x1b0>
    80005978:	00003597          	auipc	a1,0x3
    8000597c:	e6858593          	addi	a1,a1,-408 # 800087e0 <syscalls+0x2c0>
    80005980:	fb040513          	addi	a0,s0,-80
    80005984:	ffffe097          	auipc	ra,0xffffe
    80005988:	6d4080e7          	jalr	1748(ra) # 80004058 <namecmp>
    8000598c:	12050e63          	beqz	a0,80005ac8 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005990:	f2c40613          	addi	a2,s0,-212
    80005994:	fb040593          	addi	a1,s0,-80
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	6d8080e7          	jalr	1752(ra) # 80004072 <dirlookup>
    800059a2:	892a                	mv	s2,a0
    800059a4:	12050263          	beqz	a0,80005ac8 <sys_unlink+0x1b0>
  ilock(ip);
    800059a8:	ffffe097          	auipc	ra,0xffffe
    800059ac:	1e6080e7          	jalr	486(ra) # 80003b8e <ilock>
  if(ip->nlink < 1)
    800059b0:	04a91783          	lh	a5,74(s2)
    800059b4:	08f05263          	blez	a5,80005a38 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800059b8:	04491703          	lh	a4,68(s2)
    800059bc:	4785                	li	a5,1
    800059be:	08f70563          	beq	a4,a5,80005a48 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800059c2:	4641                	li	a2,16
    800059c4:	4581                	li	a1,0
    800059c6:	fc040513          	addi	a0,s0,-64
    800059ca:	ffffb097          	auipc	ra,0xffffb
    800059ce:	304080e7          	jalr	772(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800059d2:	4741                	li	a4,16
    800059d4:	f2c42683          	lw	a3,-212(s0)
    800059d8:	fc040613          	addi	a2,s0,-64
    800059dc:	4581                	li	a1,0
    800059de:	8526                	mv	a0,s1
    800059e0:	ffffe097          	auipc	ra,0xffffe
    800059e4:	55a080e7          	jalr	1370(ra) # 80003f3a <writei>
    800059e8:	47c1                	li	a5,16
    800059ea:	0af51563          	bne	a0,a5,80005a94 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800059ee:	04491703          	lh	a4,68(s2)
    800059f2:	4785                	li	a5,1
    800059f4:	0af70863          	beq	a4,a5,80005aa4 <sys_unlink+0x18c>
  iunlockput(dp);
    800059f8:	8526                	mv	a0,s1
    800059fa:	ffffe097          	auipc	ra,0xffffe
    800059fe:	3f6080e7          	jalr	1014(ra) # 80003df0 <iunlockput>
  ip->nlink--;
    80005a02:	04a95783          	lhu	a5,74(s2)
    80005a06:	37fd                	addiw	a5,a5,-1
    80005a08:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005a0c:	854a                	mv	a0,s2
    80005a0e:	ffffe097          	auipc	ra,0xffffe
    80005a12:	0b4080e7          	jalr	180(ra) # 80003ac2 <iupdate>
  iunlockput(ip);
    80005a16:	854a                	mv	a0,s2
    80005a18:	ffffe097          	auipc	ra,0xffffe
    80005a1c:	3d8080e7          	jalr	984(ra) # 80003df0 <iunlockput>
  end_op();
    80005a20:	fffff097          	auipc	ra,0xfffff
    80005a24:	b8e080e7          	jalr	-1138(ra) # 800045ae <end_op>
  return 0;
    80005a28:	4501                	li	a0,0
    80005a2a:	a84d                	j	80005adc <sys_unlink+0x1c4>
    end_op();
    80005a2c:	fffff097          	auipc	ra,0xfffff
    80005a30:	b82080e7          	jalr	-1150(ra) # 800045ae <end_op>
    return -1;
    80005a34:	557d                	li	a0,-1
    80005a36:	a05d                	j	80005adc <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005a38:	00003517          	auipc	a0,0x3
    80005a3c:	db050513          	addi	a0,a0,-592 # 800087e8 <syscalls+0x2c8>
    80005a40:	ffffb097          	auipc	ra,0xffffb
    80005a44:	afc080e7          	jalr	-1284(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a48:	04c92703          	lw	a4,76(s2)
    80005a4c:	02000793          	li	a5,32
    80005a50:	f6e7f9e3          	bgeu	a5,a4,800059c2 <sys_unlink+0xaa>
    80005a54:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005a58:	4741                	li	a4,16
    80005a5a:	86ce                	mv	a3,s3
    80005a5c:	f1840613          	addi	a2,s0,-232
    80005a60:	4581                	li	a1,0
    80005a62:	854a                	mv	a0,s2
    80005a64:	ffffe097          	auipc	ra,0xffffe
    80005a68:	3de080e7          	jalr	990(ra) # 80003e42 <readi>
    80005a6c:	47c1                	li	a5,16
    80005a6e:	00f51b63          	bne	a0,a5,80005a84 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005a72:	f1845783          	lhu	a5,-232(s0)
    80005a76:	e7a1                	bnez	a5,80005abe <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005a78:	29c1                	addiw	s3,s3,16
    80005a7a:	04c92783          	lw	a5,76(s2)
    80005a7e:	fcf9ede3          	bltu	s3,a5,80005a58 <sys_unlink+0x140>
    80005a82:	b781                	j	800059c2 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005a84:	00003517          	auipc	a0,0x3
    80005a88:	d7c50513          	addi	a0,a0,-644 # 80008800 <syscalls+0x2e0>
    80005a8c:	ffffb097          	auipc	ra,0xffffb
    80005a90:	ab0080e7          	jalr	-1360(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005a94:	00003517          	auipc	a0,0x3
    80005a98:	d8450513          	addi	a0,a0,-636 # 80008818 <syscalls+0x2f8>
    80005a9c:	ffffb097          	auipc	ra,0xffffb
    80005aa0:	aa0080e7          	jalr	-1376(ra) # 8000053c <panic>
    dp->nlink--;
    80005aa4:	04a4d783          	lhu	a5,74(s1)
    80005aa8:	37fd                	addiw	a5,a5,-1
    80005aaa:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005aae:	8526                	mv	a0,s1
    80005ab0:	ffffe097          	auipc	ra,0xffffe
    80005ab4:	012080e7          	jalr	18(ra) # 80003ac2 <iupdate>
    80005ab8:	b781                	j	800059f8 <sys_unlink+0xe0>
    return -1;
    80005aba:	557d                	li	a0,-1
    80005abc:	a005                	j	80005adc <sys_unlink+0x1c4>
    iunlockput(ip);
    80005abe:	854a                	mv	a0,s2
    80005ac0:	ffffe097          	auipc	ra,0xffffe
    80005ac4:	330080e7          	jalr	816(ra) # 80003df0 <iunlockput>
  iunlockput(dp);
    80005ac8:	8526                	mv	a0,s1
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	326080e7          	jalr	806(ra) # 80003df0 <iunlockput>
  end_op();
    80005ad2:	fffff097          	auipc	ra,0xfffff
    80005ad6:	adc080e7          	jalr	-1316(ra) # 800045ae <end_op>
  return -1;
    80005ada:	557d                	li	a0,-1
}
    80005adc:	70ae                	ld	ra,232(sp)
    80005ade:	740e                	ld	s0,224(sp)
    80005ae0:	64ee                	ld	s1,216(sp)
    80005ae2:	694e                	ld	s2,208(sp)
    80005ae4:	69ae                	ld	s3,200(sp)
    80005ae6:	616d                	addi	sp,sp,240
    80005ae8:	8082                	ret

0000000080005aea <sys_open>:

uint64
sys_open(void)
{
    80005aea:	7131                	addi	sp,sp,-192
    80005aec:	fd06                	sd	ra,184(sp)
    80005aee:	f922                	sd	s0,176(sp)
    80005af0:	f526                	sd	s1,168(sp)
    80005af2:	f14a                	sd	s2,160(sp)
    80005af4:	ed4e                	sd	s3,152(sp)
    80005af6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80005af8:	f4c40593          	addi	a1,s0,-180
    80005afc:	4505                	li	a0,1
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	49e080e7          	jalr	1182(ra) # 80002f9c <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b06:	08000613          	li	a2,128
    80005b0a:	f5040593          	addi	a1,s0,-176
    80005b0e:	4501                	li	a0,0
    80005b10:	ffffd097          	auipc	ra,0xffffd
    80005b14:	4cc080e7          	jalr	1228(ra) # 80002fdc <argstr>
    80005b18:	87aa                	mv	a5,a0
    return -1;
    80005b1a:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005b1c:	0a07c863          	bltz	a5,80005bcc <sys_open+0xe2>

  begin_op();
    80005b20:	fffff097          	auipc	ra,0xfffff
    80005b24:	a14080e7          	jalr	-1516(ra) # 80004534 <begin_op>

  if(omode & O_CREATE){
    80005b28:	f4c42783          	lw	a5,-180(s0)
    80005b2c:	2007f793          	andi	a5,a5,512
    80005b30:	cbdd                	beqz	a5,80005be6 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005b32:	4681                	li	a3,0
    80005b34:	4601                	li	a2,0
    80005b36:	4589                	li	a1,2
    80005b38:	f5040513          	addi	a0,s0,-176
    80005b3c:	00000097          	auipc	ra,0x0
    80005b40:	97a080e7          	jalr	-1670(ra) # 800054b6 <create>
    80005b44:	84aa                	mv	s1,a0
    if(ip == 0){
    80005b46:	c951                	beqz	a0,80005bda <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005b48:	04449703          	lh	a4,68(s1)
    80005b4c:	478d                	li	a5,3
    80005b4e:	00f71763          	bne	a4,a5,80005b5c <sys_open+0x72>
    80005b52:	0464d703          	lhu	a4,70(s1)
    80005b56:	47a5                	li	a5,9
    80005b58:	0ce7ec63          	bltu	a5,a4,80005c30 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005b5c:	fffff097          	auipc	ra,0xfffff
    80005b60:	de0080e7          	jalr	-544(ra) # 8000493c <filealloc>
    80005b64:	892a                	mv	s2,a0
    80005b66:	c56d                	beqz	a0,80005c50 <sys_open+0x166>
    80005b68:	00000097          	auipc	ra,0x0
    80005b6c:	90c080e7          	jalr	-1780(ra) # 80005474 <fdalloc>
    80005b70:	89aa                	mv	s3,a0
    80005b72:	0c054a63          	bltz	a0,80005c46 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005b76:	04449703          	lh	a4,68(s1)
    80005b7a:	478d                	li	a5,3
    80005b7c:	0ef70563          	beq	a4,a5,80005c66 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005b80:	4789                	li	a5,2
    80005b82:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005b86:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005b8a:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005b8e:	f4c42783          	lw	a5,-180(s0)
    80005b92:	0017c713          	xori	a4,a5,1
    80005b96:	8b05                	andi	a4,a4,1
    80005b98:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005b9c:	0037f713          	andi	a4,a5,3
    80005ba0:	00e03733          	snez	a4,a4
    80005ba4:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005ba8:	4007f793          	andi	a5,a5,1024
    80005bac:	c791                	beqz	a5,80005bb8 <sys_open+0xce>
    80005bae:	04449703          	lh	a4,68(s1)
    80005bb2:	4789                	li	a5,2
    80005bb4:	0cf70063          	beq	a4,a5,80005c74 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005bb8:	8526                	mv	a0,s1
    80005bba:	ffffe097          	auipc	ra,0xffffe
    80005bbe:	096080e7          	jalr	150(ra) # 80003c50 <iunlock>
  end_op();
    80005bc2:	fffff097          	auipc	ra,0xfffff
    80005bc6:	9ec080e7          	jalr	-1556(ra) # 800045ae <end_op>

  return fd;
    80005bca:	854e                	mv	a0,s3
}
    80005bcc:	70ea                	ld	ra,184(sp)
    80005bce:	744a                	ld	s0,176(sp)
    80005bd0:	74aa                	ld	s1,168(sp)
    80005bd2:	790a                	ld	s2,160(sp)
    80005bd4:	69ea                	ld	s3,152(sp)
    80005bd6:	6129                	addi	sp,sp,192
    80005bd8:	8082                	ret
      end_op();
    80005bda:	fffff097          	auipc	ra,0xfffff
    80005bde:	9d4080e7          	jalr	-1580(ra) # 800045ae <end_op>
      return -1;
    80005be2:	557d                	li	a0,-1
    80005be4:	b7e5                	j	80005bcc <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    80005be6:	f5040513          	addi	a0,s0,-176
    80005bea:	ffffe097          	auipc	ra,0xffffe
    80005bee:	74a080e7          	jalr	1866(ra) # 80004334 <namei>
    80005bf2:	84aa                	mv	s1,a0
    80005bf4:	c905                	beqz	a0,80005c24 <sys_open+0x13a>
    ilock(ip);
    80005bf6:	ffffe097          	auipc	ra,0xffffe
    80005bfa:	f98080e7          	jalr	-104(ra) # 80003b8e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005bfe:	04449703          	lh	a4,68(s1)
    80005c02:	4785                	li	a5,1
    80005c04:	f4f712e3          	bne	a4,a5,80005b48 <sys_open+0x5e>
    80005c08:	f4c42783          	lw	a5,-180(s0)
    80005c0c:	dba1                	beqz	a5,80005b5c <sys_open+0x72>
      iunlockput(ip);
    80005c0e:	8526                	mv	a0,s1
    80005c10:	ffffe097          	auipc	ra,0xffffe
    80005c14:	1e0080e7          	jalr	480(ra) # 80003df0 <iunlockput>
      end_op();
    80005c18:	fffff097          	auipc	ra,0xfffff
    80005c1c:	996080e7          	jalr	-1642(ra) # 800045ae <end_op>
      return -1;
    80005c20:	557d                	li	a0,-1
    80005c22:	b76d                	j	80005bcc <sys_open+0xe2>
      end_op();
    80005c24:	fffff097          	auipc	ra,0xfffff
    80005c28:	98a080e7          	jalr	-1654(ra) # 800045ae <end_op>
      return -1;
    80005c2c:	557d                	li	a0,-1
    80005c2e:	bf79                	j	80005bcc <sys_open+0xe2>
    iunlockput(ip);
    80005c30:	8526                	mv	a0,s1
    80005c32:	ffffe097          	auipc	ra,0xffffe
    80005c36:	1be080e7          	jalr	446(ra) # 80003df0 <iunlockput>
    end_op();
    80005c3a:	fffff097          	auipc	ra,0xfffff
    80005c3e:	974080e7          	jalr	-1676(ra) # 800045ae <end_op>
    return -1;
    80005c42:	557d                	li	a0,-1
    80005c44:	b761                	j	80005bcc <sys_open+0xe2>
      fileclose(f);
    80005c46:	854a                	mv	a0,s2
    80005c48:	fffff097          	auipc	ra,0xfffff
    80005c4c:	db0080e7          	jalr	-592(ra) # 800049f8 <fileclose>
    iunlockput(ip);
    80005c50:	8526                	mv	a0,s1
    80005c52:	ffffe097          	auipc	ra,0xffffe
    80005c56:	19e080e7          	jalr	414(ra) # 80003df0 <iunlockput>
    end_op();
    80005c5a:	fffff097          	auipc	ra,0xfffff
    80005c5e:	954080e7          	jalr	-1708(ra) # 800045ae <end_op>
    return -1;
    80005c62:	557d                	li	a0,-1
    80005c64:	b7a5                	j	80005bcc <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005c66:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005c6a:	04649783          	lh	a5,70(s1)
    80005c6e:	02f91223          	sh	a5,36(s2)
    80005c72:	bf21                	j	80005b8a <sys_open+0xa0>
    itrunc(ip);
    80005c74:	8526                	mv	a0,s1
    80005c76:	ffffe097          	auipc	ra,0xffffe
    80005c7a:	026080e7          	jalr	38(ra) # 80003c9c <itrunc>
    80005c7e:	bf2d                	j	80005bb8 <sys_open+0xce>

0000000080005c80 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005c80:	7175                	addi	sp,sp,-144
    80005c82:	e506                	sd	ra,136(sp)
    80005c84:	e122                	sd	s0,128(sp)
    80005c86:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005c88:	fffff097          	auipc	ra,0xfffff
    80005c8c:	8ac080e7          	jalr	-1876(ra) # 80004534 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005c90:	08000613          	li	a2,128
    80005c94:	f7040593          	addi	a1,s0,-144
    80005c98:	4501                	li	a0,0
    80005c9a:	ffffd097          	auipc	ra,0xffffd
    80005c9e:	342080e7          	jalr	834(ra) # 80002fdc <argstr>
    80005ca2:	02054963          	bltz	a0,80005cd4 <sys_mkdir+0x54>
    80005ca6:	4681                	li	a3,0
    80005ca8:	4601                	li	a2,0
    80005caa:	4585                	li	a1,1
    80005cac:	f7040513          	addi	a0,s0,-144
    80005cb0:	00000097          	auipc	ra,0x0
    80005cb4:	806080e7          	jalr	-2042(ra) # 800054b6 <create>
    80005cb8:	cd11                	beqz	a0,80005cd4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005cba:	ffffe097          	auipc	ra,0xffffe
    80005cbe:	136080e7          	jalr	310(ra) # 80003df0 <iunlockput>
  end_op();
    80005cc2:	fffff097          	auipc	ra,0xfffff
    80005cc6:	8ec080e7          	jalr	-1812(ra) # 800045ae <end_op>
  return 0;
    80005cca:	4501                	li	a0,0
}
    80005ccc:	60aa                	ld	ra,136(sp)
    80005cce:	640a                	ld	s0,128(sp)
    80005cd0:	6149                	addi	sp,sp,144
    80005cd2:	8082                	ret
    end_op();
    80005cd4:	fffff097          	auipc	ra,0xfffff
    80005cd8:	8da080e7          	jalr	-1830(ra) # 800045ae <end_op>
    return -1;
    80005cdc:	557d                	li	a0,-1
    80005cde:	b7fd                	j	80005ccc <sys_mkdir+0x4c>

0000000080005ce0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ce0:	7135                	addi	sp,sp,-160
    80005ce2:	ed06                	sd	ra,152(sp)
    80005ce4:	e922                	sd	s0,144(sp)
    80005ce6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ce8:	fffff097          	auipc	ra,0xfffff
    80005cec:	84c080e7          	jalr	-1972(ra) # 80004534 <begin_op>
  argint(1, &major);
    80005cf0:	f6c40593          	addi	a1,s0,-148
    80005cf4:	4505                	li	a0,1
    80005cf6:	ffffd097          	auipc	ra,0xffffd
    80005cfa:	2a6080e7          	jalr	678(ra) # 80002f9c <argint>
  argint(2, &minor);
    80005cfe:	f6840593          	addi	a1,s0,-152
    80005d02:	4509                	li	a0,2
    80005d04:	ffffd097          	auipc	ra,0xffffd
    80005d08:	298080e7          	jalr	664(ra) # 80002f9c <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d0c:	08000613          	li	a2,128
    80005d10:	f7040593          	addi	a1,s0,-144
    80005d14:	4501                	li	a0,0
    80005d16:	ffffd097          	auipc	ra,0xffffd
    80005d1a:	2c6080e7          	jalr	710(ra) # 80002fdc <argstr>
    80005d1e:	02054b63          	bltz	a0,80005d54 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005d22:	f6841683          	lh	a3,-152(s0)
    80005d26:	f6c41603          	lh	a2,-148(s0)
    80005d2a:	458d                	li	a1,3
    80005d2c:	f7040513          	addi	a0,s0,-144
    80005d30:	fffff097          	auipc	ra,0xfffff
    80005d34:	786080e7          	jalr	1926(ra) # 800054b6 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005d38:	cd11                	beqz	a0,80005d54 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005d3a:	ffffe097          	auipc	ra,0xffffe
    80005d3e:	0b6080e7          	jalr	182(ra) # 80003df0 <iunlockput>
  end_op();
    80005d42:	fffff097          	auipc	ra,0xfffff
    80005d46:	86c080e7          	jalr	-1940(ra) # 800045ae <end_op>
  return 0;
    80005d4a:	4501                	li	a0,0
}
    80005d4c:	60ea                	ld	ra,152(sp)
    80005d4e:	644a                	ld	s0,144(sp)
    80005d50:	610d                	addi	sp,sp,160
    80005d52:	8082                	ret
    end_op();
    80005d54:	fffff097          	auipc	ra,0xfffff
    80005d58:	85a080e7          	jalr	-1958(ra) # 800045ae <end_op>
    return -1;
    80005d5c:	557d                	li	a0,-1
    80005d5e:	b7fd                	j	80005d4c <sys_mknod+0x6c>

0000000080005d60 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005d60:	7135                	addi	sp,sp,-160
    80005d62:	ed06                	sd	ra,152(sp)
    80005d64:	e922                	sd	s0,144(sp)
    80005d66:	e526                	sd	s1,136(sp)
    80005d68:	e14a                	sd	s2,128(sp)
    80005d6a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005d6c:	ffffc097          	auipc	ra,0xffffc
    80005d70:	ef0080e7          	jalr	-272(ra) # 80001c5c <myproc>
    80005d74:	892a                	mv	s2,a0
  
  begin_op();
    80005d76:	ffffe097          	auipc	ra,0xffffe
    80005d7a:	7be080e7          	jalr	1982(ra) # 80004534 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005d7e:	08000613          	li	a2,128
    80005d82:	f6040593          	addi	a1,s0,-160
    80005d86:	4501                	li	a0,0
    80005d88:	ffffd097          	auipc	ra,0xffffd
    80005d8c:	254080e7          	jalr	596(ra) # 80002fdc <argstr>
    80005d90:	04054b63          	bltz	a0,80005de6 <sys_chdir+0x86>
    80005d94:	f6040513          	addi	a0,s0,-160
    80005d98:	ffffe097          	auipc	ra,0xffffe
    80005d9c:	59c080e7          	jalr	1436(ra) # 80004334 <namei>
    80005da0:	84aa                	mv	s1,a0
    80005da2:	c131                	beqz	a0,80005de6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005da4:	ffffe097          	auipc	ra,0xffffe
    80005da8:	dea080e7          	jalr	-534(ra) # 80003b8e <ilock>
  if(ip->type != T_DIR){
    80005dac:	04449703          	lh	a4,68(s1)
    80005db0:	4785                	li	a5,1
    80005db2:	04f71063          	bne	a4,a5,80005df2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005db6:	8526                	mv	a0,s1
    80005db8:	ffffe097          	auipc	ra,0xffffe
    80005dbc:	e98080e7          	jalr	-360(ra) # 80003c50 <iunlock>
  iput(p->cwd);
    80005dc0:	15093503          	ld	a0,336(s2)
    80005dc4:	ffffe097          	auipc	ra,0xffffe
    80005dc8:	f84080e7          	jalr	-124(ra) # 80003d48 <iput>
  end_op();
    80005dcc:	ffffe097          	auipc	ra,0xffffe
    80005dd0:	7e2080e7          	jalr	2018(ra) # 800045ae <end_op>
  p->cwd = ip;
    80005dd4:	14993823          	sd	s1,336(s2)
  return 0;
    80005dd8:	4501                	li	a0,0
}
    80005dda:	60ea                	ld	ra,152(sp)
    80005ddc:	644a                	ld	s0,144(sp)
    80005dde:	64aa                	ld	s1,136(sp)
    80005de0:	690a                	ld	s2,128(sp)
    80005de2:	610d                	addi	sp,sp,160
    80005de4:	8082                	ret
    end_op();
    80005de6:	ffffe097          	auipc	ra,0xffffe
    80005dea:	7c8080e7          	jalr	1992(ra) # 800045ae <end_op>
    return -1;
    80005dee:	557d                	li	a0,-1
    80005df0:	b7ed                	j	80005dda <sys_chdir+0x7a>
    iunlockput(ip);
    80005df2:	8526                	mv	a0,s1
    80005df4:	ffffe097          	auipc	ra,0xffffe
    80005df8:	ffc080e7          	jalr	-4(ra) # 80003df0 <iunlockput>
    end_op();
    80005dfc:	ffffe097          	auipc	ra,0xffffe
    80005e00:	7b2080e7          	jalr	1970(ra) # 800045ae <end_op>
    return -1;
    80005e04:	557d                	li	a0,-1
    80005e06:	bfd1                	j	80005dda <sys_chdir+0x7a>

0000000080005e08 <sys_exec>:

uint64
sys_exec(void)
{
    80005e08:	7121                	addi	sp,sp,-448
    80005e0a:	ff06                	sd	ra,440(sp)
    80005e0c:	fb22                	sd	s0,432(sp)
    80005e0e:	f726                	sd	s1,424(sp)
    80005e10:	f34a                	sd	s2,416(sp)
    80005e12:	ef4e                	sd	s3,408(sp)
    80005e14:	eb52                	sd	s4,400(sp)
    80005e16:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005e18:	e4840593          	addi	a1,s0,-440
    80005e1c:	4505                	li	a0,1
    80005e1e:	ffffd097          	auipc	ra,0xffffd
    80005e22:	19e080e7          	jalr	414(ra) # 80002fbc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005e26:	08000613          	li	a2,128
    80005e2a:	f5040593          	addi	a1,s0,-176
    80005e2e:	4501                	li	a0,0
    80005e30:	ffffd097          	auipc	ra,0xffffd
    80005e34:	1ac080e7          	jalr	428(ra) # 80002fdc <argstr>
    80005e38:	87aa                	mv	a5,a0
    return -1;
    80005e3a:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005e3c:	0c07c263          	bltz	a5,80005f00 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005e40:	10000613          	li	a2,256
    80005e44:	4581                	li	a1,0
    80005e46:	e5040513          	addi	a0,s0,-432
    80005e4a:	ffffb097          	auipc	ra,0xffffb
    80005e4e:	e84080e7          	jalr	-380(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005e52:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005e56:	89a6                	mv	s3,s1
    80005e58:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005e5a:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005e5e:	00391513          	slli	a0,s2,0x3
    80005e62:	e4040593          	addi	a1,s0,-448
    80005e66:	e4843783          	ld	a5,-440(s0)
    80005e6a:	953e                	add	a0,a0,a5
    80005e6c:	ffffd097          	auipc	ra,0xffffd
    80005e70:	092080e7          	jalr	146(ra) # 80002efe <fetchaddr>
    80005e74:	02054a63          	bltz	a0,80005ea8 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005e78:	e4043783          	ld	a5,-448(s0)
    80005e7c:	c3b9                	beqz	a5,80005ec2 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005e7e:	ffffb097          	auipc	ra,0xffffb
    80005e82:	c64080e7          	jalr	-924(ra) # 80000ae2 <kalloc>
    80005e86:	85aa                	mv	a1,a0
    80005e88:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005e8c:	cd11                	beqz	a0,80005ea8 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005e8e:	6605                	lui	a2,0x1
    80005e90:	e4043503          	ld	a0,-448(s0)
    80005e94:	ffffd097          	auipc	ra,0xffffd
    80005e98:	0bc080e7          	jalr	188(ra) # 80002f50 <fetchstr>
    80005e9c:	00054663          	bltz	a0,80005ea8 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005ea0:	0905                	addi	s2,s2,1
    80005ea2:	09a1                	addi	s3,s3,8
    80005ea4:	fb491de3          	bne	s2,s4,80005e5e <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ea8:	f5040913          	addi	s2,s0,-176
    80005eac:	6088                	ld	a0,0(s1)
    80005eae:	c921                	beqz	a0,80005efe <sys_exec+0xf6>
    kfree(argv[i]);
    80005eb0:	ffffb097          	auipc	ra,0xffffb
    80005eb4:	b34080e7          	jalr	-1228(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005eb8:	04a1                	addi	s1,s1,8
    80005eba:	ff2499e3          	bne	s1,s2,80005eac <sys_exec+0xa4>
  return -1;
    80005ebe:	557d                	li	a0,-1
    80005ec0:	a081                	j	80005f00 <sys_exec+0xf8>
      argv[i] = 0;
    80005ec2:	0009079b          	sext.w	a5,s2
    80005ec6:	078e                	slli	a5,a5,0x3
    80005ec8:	fd078793          	addi	a5,a5,-48
    80005ecc:	97a2                	add	a5,a5,s0
    80005ece:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ed2:	e5040593          	addi	a1,s0,-432
    80005ed6:	f5040513          	addi	a0,s0,-176
    80005eda:	fffff097          	auipc	ra,0xfffff
    80005ede:	194080e7          	jalr	404(ra) # 8000506e <exec>
    80005ee2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ee4:	f5040993          	addi	s3,s0,-176
    80005ee8:	6088                	ld	a0,0(s1)
    80005eea:	c901                	beqz	a0,80005efa <sys_exec+0xf2>
    kfree(argv[i]);
    80005eec:	ffffb097          	auipc	ra,0xffffb
    80005ef0:	af8080e7          	jalr	-1288(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ef4:	04a1                	addi	s1,s1,8
    80005ef6:	ff3499e3          	bne	s1,s3,80005ee8 <sys_exec+0xe0>
  return ret;
    80005efa:	854a                	mv	a0,s2
    80005efc:	a011                	j	80005f00 <sys_exec+0xf8>
  return -1;
    80005efe:	557d                	li	a0,-1
}
    80005f00:	70fa                	ld	ra,440(sp)
    80005f02:	745a                	ld	s0,432(sp)
    80005f04:	74ba                	ld	s1,424(sp)
    80005f06:	791a                	ld	s2,416(sp)
    80005f08:	69fa                	ld	s3,408(sp)
    80005f0a:	6a5a                	ld	s4,400(sp)
    80005f0c:	6139                	addi	sp,sp,448
    80005f0e:	8082                	ret

0000000080005f10 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005f10:	7139                	addi	sp,sp,-64
    80005f12:	fc06                	sd	ra,56(sp)
    80005f14:	f822                	sd	s0,48(sp)
    80005f16:	f426                	sd	s1,40(sp)
    80005f18:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005f1a:	ffffc097          	auipc	ra,0xffffc
    80005f1e:	d42080e7          	jalr	-702(ra) # 80001c5c <myproc>
    80005f22:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005f24:	fd840593          	addi	a1,s0,-40
    80005f28:	4501                	li	a0,0
    80005f2a:	ffffd097          	auipc	ra,0xffffd
    80005f2e:	092080e7          	jalr	146(ra) # 80002fbc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005f32:	fc840593          	addi	a1,s0,-56
    80005f36:	fd040513          	addi	a0,s0,-48
    80005f3a:	fffff097          	auipc	ra,0xfffff
    80005f3e:	dea080e7          	jalr	-534(ra) # 80004d24 <pipealloc>
    return -1;
    80005f42:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005f44:	0c054463          	bltz	a0,8000600c <sys_pipe+0xfc>
  fd0 = -1;
    80005f48:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005f4c:	fd043503          	ld	a0,-48(s0)
    80005f50:	fffff097          	auipc	ra,0xfffff
    80005f54:	524080e7          	jalr	1316(ra) # 80005474 <fdalloc>
    80005f58:	fca42223          	sw	a0,-60(s0)
    80005f5c:	08054b63          	bltz	a0,80005ff2 <sys_pipe+0xe2>
    80005f60:	fc843503          	ld	a0,-56(s0)
    80005f64:	fffff097          	auipc	ra,0xfffff
    80005f68:	510080e7          	jalr	1296(ra) # 80005474 <fdalloc>
    80005f6c:	fca42023          	sw	a0,-64(s0)
    80005f70:	06054863          	bltz	a0,80005fe0 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005f74:	4691                	li	a3,4
    80005f76:	fc440613          	addi	a2,s0,-60
    80005f7a:	fd843583          	ld	a1,-40(s0)
    80005f7e:	68a8                	ld	a0,80(s1)
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	6e6080e7          	jalr	1766(ra) # 80001666 <copyout>
    80005f88:	02054063          	bltz	a0,80005fa8 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005f8c:	4691                	li	a3,4
    80005f8e:	fc040613          	addi	a2,s0,-64
    80005f92:	fd843583          	ld	a1,-40(s0)
    80005f96:	0591                	addi	a1,a1,4
    80005f98:	68a8                	ld	a0,80(s1)
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	6cc080e7          	jalr	1740(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005fa2:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005fa4:	06055463          	bgez	a0,8000600c <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005fa8:	fc442783          	lw	a5,-60(s0)
    80005fac:	07e9                	addi	a5,a5,26
    80005fae:	078e                	slli	a5,a5,0x3
    80005fb0:	97a6                	add	a5,a5,s1
    80005fb2:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005fb6:	fc042783          	lw	a5,-64(s0)
    80005fba:	07e9                	addi	a5,a5,26
    80005fbc:	078e                	slli	a5,a5,0x3
    80005fbe:	94be                	add	s1,s1,a5
    80005fc0:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005fc4:	fd043503          	ld	a0,-48(s0)
    80005fc8:	fffff097          	auipc	ra,0xfffff
    80005fcc:	a30080e7          	jalr	-1488(ra) # 800049f8 <fileclose>
    fileclose(wf);
    80005fd0:	fc843503          	ld	a0,-56(s0)
    80005fd4:	fffff097          	auipc	ra,0xfffff
    80005fd8:	a24080e7          	jalr	-1500(ra) # 800049f8 <fileclose>
    return -1;
    80005fdc:	57fd                	li	a5,-1
    80005fde:	a03d                	j	8000600c <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005fe0:	fc442783          	lw	a5,-60(s0)
    80005fe4:	0007c763          	bltz	a5,80005ff2 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005fe8:	07e9                	addi	a5,a5,26
    80005fea:	078e                	slli	a5,a5,0x3
    80005fec:	97a6                	add	a5,a5,s1
    80005fee:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005ff2:	fd043503          	ld	a0,-48(s0)
    80005ff6:	fffff097          	auipc	ra,0xfffff
    80005ffa:	a02080e7          	jalr	-1534(ra) # 800049f8 <fileclose>
    fileclose(wf);
    80005ffe:	fc843503          	ld	a0,-56(s0)
    80006002:	fffff097          	auipc	ra,0xfffff
    80006006:	9f6080e7          	jalr	-1546(ra) # 800049f8 <fileclose>
    return -1;
    8000600a:	57fd                	li	a5,-1
}
    8000600c:	853e                	mv	a0,a5
    8000600e:	70e2                	ld	ra,56(sp)
    80006010:	7442                	ld	s0,48(sp)
    80006012:	74a2                	ld	s1,40(sp)
    80006014:	6121                	addi	sp,sp,64
    80006016:	8082                	ret
	...

0000000080006020 <kernelvec>:
    80006020:	7111                	addi	sp,sp,-256
    80006022:	e006                	sd	ra,0(sp)
    80006024:	e40a                	sd	sp,8(sp)
    80006026:	e80e                	sd	gp,16(sp)
    80006028:	ec12                	sd	tp,24(sp)
    8000602a:	f016                	sd	t0,32(sp)
    8000602c:	f41a                	sd	t1,40(sp)
    8000602e:	f81e                	sd	t2,48(sp)
    80006030:	fc22                	sd	s0,56(sp)
    80006032:	e0a6                	sd	s1,64(sp)
    80006034:	e4aa                	sd	a0,72(sp)
    80006036:	e8ae                	sd	a1,80(sp)
    80006038:	ecb2                	sd	a2,88(sp)
    8000603a:	f0b6                	sd	a3,96(sp)
    8000603c:	f4ba                	sd	a4,104(sp)
    8000603e:	f8be                	sd	a5,112(sp)
    80006040:	fcc2                	sd	a6,120(sp)
    80006042:	e146                	sd	a7,128(sp)
    80006044:	e54a                	sd	s2,136(sp)
    80006046:	e94e                	sd	s3,144(sp)
    80006048:	ed52                	sd	s4,152(sp)
    8000604a:	f156                	sd	s5,160(sp)
    8000604c:	f55a                	sd	s6,168(sp)
    8000604e:	f95e                	sd	s7,176(sp)
    80006050:	fd62                	sd	s8,184(sp)
    80006052:	e1e6                	sd	s9,192(sp)
    80006054:	e5ea                	sd	s10,200(sp)
    80006056:	e9ee                	sd	s11,208(sp)
    80006058:	edf2                	sd	t3,216(sp)
    8000605a:	f1f6                	sd	t4,224(sp)
    8000605c:	f5fa                	sd	t5,232(sp)
    8000605e:	f9fe                	sd	t6,240(sp)
    80006060:	d6bfc0ef          	jal	ra,80002dca <kerneltrap>
    80006064:	6082                	ld	ra,0(sp)
    80006066:	6122                	ld	sp,8(sp)
    80006068:	61c2                	ld	gp,16(sp)
    8000606a:	7282                	ld	t0,32(sp)
    8000606c:	7322                	ld	t1,40(sp)
    8000606e:	73c2                	ld	t2,48(sp)
    80006070:	7462                	ld	s0,56(sp)
    80006072:	6486                	ld	s1,64(sp)
    80006074:	6526                	ld	a0,72(sp)
    80006076:	65c6                	ld	a1,80(sp)
    80006078:	6666                	ld	a2,88(sp)
    8000607a:	7686                	ld	a3,96(sp)
    8000607c:	7726                	ld	a4,104(sp)
    8000607e:	77c6                	ld	a5,112(sp)
    80006080:	7866                	ld	a6,120(sp)
    80006082:	688a                	ld	a7,128(sp)
    80006084:	692a                	ld	s2,136(sp)
    80006086:	69ca                	ld	s3,144(sp)
    80006088:	6a6a                	ld	s4,152(sp)
    8000608a:	7a8a                	ld	s5,160(sp)
    8000608c:	7b2a                	ld	s6,168(sp)
    8000608e:	7bca                	ld	s7,176(sp)
    80006090:	7c6a                	ld	s8,184(sp)
    80006092:	6c8e                	ld	s9,192(sp)
    80006094:	6d2e                	ld	s10,200(sp)
    80006096:	6dce                	ld	s11,208(sp)
    80006098:	6e6e                	ld	t3,216(sp)
    8000609a:	7e8e                	ld	t4,224(sp)
    8000609c:	7f2e                	ld	t5,232(sp)
    8000609e:	7fce                	ld	t6,240(sp)
    800060a0:	6111                	addi	sp,sp,256
    800060a2:	10200073          	sret
    800060a6:	00000013          	nop
    800060aa:	00000013          	nop
    800060ae:	0001                	nop

00000000800060b0 <timervec>:
    800060b0:	34051573          	csrrw	a0,mscratch,a0
    800060b4:	e10c                	sd	a1,0(a0)
    800060b6:	e510                	sd	a2,8(a0)
    800060b8:	e914                	sd	a3,16(a0)
    800060ba:	6d0c                	ld	a1,24(a0)
    800060bc:	7110                	ld	a2,32(a0)
    800060be:	6194                	ld	a3,0(a1)
    800060c0:	96b2                	add	a3,a3,a2
    800060c2:	e194                	sd	a3,0(a1)
    800060c4:	4589                	li	a1,2
    800060c6:	14459073          	csrw	sip,a1
    800060ca:	6914                	ld	a3,16(a0)
    800060cc:	6510                	ld	a2,8(a0)
    800060ce:	610c                	ld	a1,0(a0)
    800060d0:	34051573          	csrrw	a0,mscratch,a0
    800060d4:	30200073          	mret
	...

00000000800060da <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    800060da:	1141                	addi	sp,sp,-16
    800060dc:	e422                	sd	s0,8(sp)
    800060de:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800060e0:	0c0007b7          	lui	a5,0xc000
    800060e4:	4705                	li	a4,1
    800060e6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800060e8:	c3d8                	sw	a4,4(a5)
}
    800060ea:	6422                	ld	s0,8(sp)
    800060ec:	0141                	addi	sp,sp,16
    800060ee:	8082                	ret

00000000800060f0 <plicinithart>:

void
plicinithart(void)
{
    800060f0:	1141                	addi	sp,sp,-16
    800060f2:	e406                	sd	ra,8(sp)
    800060f4:	e022                	sd	s0,0(sp)
    800060f6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800060f8:	ffffc097          	auipc	ra,0xffffc
    800060fc:	b38080e7          	jalr	-1224(ra) # 80001c30 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80006100:	0085171b          	slliw	a4,a0,0x8
    80006104:	0c0027b7          	lui	a5,0xc002
    80006108:	97ba                	add	a5,a5,a4
    8000610a:	40200713          	li	a4,1026
    8000610e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80006112:	00d5151b          	slliw	a0,a0,0xd
    80006116:	0c2017b7          	lui	a5,0xc201
    8000611a:	97aa                	add	a5,a5,a0
    8000611c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80006120:	60a2                	ld	ra,8(sp)
    80006122:	6402                	ld	s0,0(sp)
    80006124:	0141                	addi	sp,sp,16
    80006126:	8082                	ret

0000000080006128 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80006128:	1141                	addi	sp,sp,-16
    8000612a:	e406                	sd	ra,8(sp)
    8000612c:	e022                	sd	s0,0(sp)
    8000612e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80006130:	ffffc097          	auipc	ra,0xffffc
    80006134:	b00080e7          	jalr	-1280(ra) # 80001c30 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80006138:	00d5151b          	slliw	a0,a0,0xd
    8000613c:	0c2017b7          	lui	a5,0xc201
    80006140:	97aa                	add	a5,a5,a0
  return irq;
}
    80006142:	43c8                	lw	a0,4(a5)
    80006144:	60a2                	ld	ra,8(sp)
    80006146:	6402                	ld	s0,0(sp)
    80006148:	0141                	addi	sp,sp,16
    8000614a:	8082                	ret

000000008000614c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000614c:	1101                	addi	sp,sp,-32
    8000614e:	ec06                	sd	ra,24(sp)
    80006150:	e822                	sd	s0,16(sp)
    80006152:	e426                	sd	s1,8(sp)
    80006154:	1000                	addi	s0,sp,32
    80006156:	84aa                	mv	s1,a0
  int hart = cpuid();
    80006158:	ffffc097          	auipc	ra,0xffffc
    8000615c:	ad8080e7          	jalr	-1320(ra) # 80001c30 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80006160:	00d5151b          	slliw	a0,a0,0xd
    80006164:	0c2017b7          	lui	a5,0xc201
    80006168:	97aa                	add	a5,a5,a0
    8000616a:	c3c4                	sw	s1,4(a5)
}
    8000616c:	60e2                	ld	ra,24(sp)
    8000616e:	6442                	ld	s0,16(sp)
    80006170:	64a2                	ld	s1,8(sp)
    80006172:	6105                	addi	sp,sp,32
    80006174:	8082                	ret

0000000080006176 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80006176:	1141                	addi	sp,sp,-16
    80006178:	e406                	sd	ra,8(sp)
    8000617a:	e022                	sd	s0,0(sp)
    8000617c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    8000617e:	479d                	li	a5,7
    80006180:	04a7cc63          	blt	a5,a0,800061d8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80006184:	0001c797          	auipc	a5,0x1c
    80006188:	cbc78793          	addi	a5,a5,-836 # 80021e40 <disk>
    8000618c:	97aa                	add	a5,a5,a0
    8000618e:	0187c783          	lbu	a5,24(a5)
    80006192:	ebb9                	bnez	a5,800061e8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80006194:	00451693          	slli	a3,a0,0x4
    80006198:	0001c797          	auipc	a5,0x1c
    8000619c:	ca878793          	addi	a5,a5,-856 # 80021e40 <disk>
    800061a0:	6398                	ld	a4,0(a5)
    800061a2:	9736                	add	a4,a4,a3
    800061a4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800061a8:	6398                	ld	a4,0(a5)
    800061aa:	9736                	add	a4,a4,a3
    800061ac:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800061b0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800061b4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800061b8:	97aa                	add	a5,a5,a0
    800061ba:	4705                	li	a4,1
    800061bc:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800061c0:	0001c517          	auipc	a0,0x1c
    800061c4:	c9850513          	addi	a0,a0,-872 # 80021e58 <disk+0x18>
    800061c8:	ffffc097          	auipc	ra,0xffffc
    800061cc:	280080e7          	jalr	640(ra) # 80002448 <wakeup>
}
    800061d0:	60a2                	ld	ra,8(sp)
    800061d2:	6402                	ld	s0,0(sp)
    800061d4:	0141                	addi	sp,sp,16
    800061d6:	8082                	ret
    panic("free_desc 1");
    800061d8:	00002517          	auipc	a0,0x2
    800061dc:	65050513          	addi	a0,a0,1616 # 80008828 <syscalls+0x308>
    800061e0:	ffffa097          	auipc	ra,0xffffa
    800061e4:	35c080e7          	jalr	860(ra) # 8000053c <panic>
    panic("free_desc 2");
    800061e8:	00002517          	auipc	a0,0x2
    800061ec:	65050513          	addi	a0,a0,1616 # 80008838 <syscalls+0x318>
    800061f0:	ffffa097          	auipc	ra,0xffffa
    800061f4:	34c080e7          	jalr	844(ra) # 8000053c <panic>

00000000800061f8 <virtio_disk_init>:
{
    800061f8:	1101                	addi	sp,sp,-32
    800061fa:	ec06                	sd	ra,24(sp)
    800061fc:	e822                	sd	s0,16(sp)
    800061fe:	e426                	sd	s1,8(sp)
    80006200:	e04a                	sd	s2,0(sp)
    80006202:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80006204:	00002597          	auipc	a1,0x2
    80006208:	64458593          	addi	a1,a1,1604 # 80008848 <syscalls+0x328>
    8000620c:	0001c517          	auipc	a0,0x1c
    80006210:	d5c50513          	addi	a0,a0,-676 # 80021f68 <disk+0x128>
    80006214:	ffffb097          	auipc	ra,0xffffb
    80006218:	92e080e7          	jalr	-1746(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000621c:	100017b7          	lui	a5,0x10001
    80006220:	4398                	lw	a4,0(a5)
    80006222:	2701                	sext.w	a4,a4
    80006224:	747277b7          	lui	a5,0x74727
    80006228:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000622c:	14f71b63          	bne	a4,a5,80006382 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006230:	100017b7          	lui	a5,0x10001
    80006234:	43dc                	lw	a5,4(a5)
    80006236:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006238:	4709                	li	a4,2
    8000623a:	14e79463          	bne	a5,a4,80006382 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000623e:	100017b7          	lui	a5,0x10001
    80006242:	479c                	lw	a5,8(a5)
    80006244:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006246:	12e79e63          	bne	a5,a4,80006382 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000624a:	100017b7          	lui	a5,0x10001
    8000624e:	47d8                	lw	a4,12(a5)
    80006250:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006252:	554d47b7          	lui	a5,0x554d4
    80006256:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000625a:	12f71463          	bne	a4,a5,80006382 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000625e:	100017b7          	lui	a5,0x10001
    80006262:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006266:	4705                	li	a4,1
    80006268:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000626a:	470d                	li	a4,3
    8000626c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000626e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006270:	c7ffe6b7          	lui	a3,0xc7ffe
    80006274:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc7df>
    80006278:	8f75                	and	a4,a4,a3
    8000627a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000627c:	472d                	li	a4,11
    8000627e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006280:	5bbc                	lw	a5,112(a5)
    80006282:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006286:	8ba1                	andi	a5,a5,8
    80006288:	10078563          	beqz	a5,80006392 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000628c:	100017b7          	lui	a5,0x10001
    80006290:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006294:	43fc                	lw	a5,68(a5)
    80006296:	2781                	sext.w	a5,a5
    80006298:	10079563          	bnez	a5,800063a2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000629c:	100017b7          	lui	a5,0x10001
    800062a0:	5bdc                	lw	a5,52(a5)
    800062a2:	2781                	sext.w	a5,a5
  if(max == 0)
    800062a4:	10078763          	beqz	a5,800063b2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    800062a8:	471d                	li	a4,7
    800062aa:	10f77c63          	bgeu	a4,a5,800063c2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    800062ae:	ffffb097          	auipc	ra,0xffffb
    800062b2:	834080e7          	jalr	-1996(ra) # 80000ae2 <kalloc>
    800062b6:	0001c497          	auipc	s1,0x1c
    800062ba:	b8a48493          	addi	s1,s1,-1142 # 80021e40 <disk>
    800062be:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800062c0:	ffffb097          	auipc	ra,0xffffb
    800062c4:	822080e7          	jalr	-2014(ra) # 80000ae2 <kalloc>
    800062c8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800062ca:	ffffb097          	auipc	ra,0xffffb
    800062ce:	818080e7          	jalr	-2024(ra) # 80000ae2 <kalloc>
    800062d2:	87aa                	mv	a5,a0
    800062d4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800062d6:	6088                	ld	a0,0(s1)
    800062d8:	cd6d                	beqz	a0,800063d2 <virtio_disk_init+0x1da>
    800062da:	0001c717          	auipc	a4,0x1c
    800062de:	b6e73703          	ld	a4,-1170(a4) # 80021e48 <disk+0x8>
    800062e2:	cb65                	beqz	a4,800063d2 <virtio_disk_init+0x1da>
    800062e4:	c7fd                	beqz	a5,800063d2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800062e6:	6605                	lui	a2,0x1
    800062e8:	4581                	li	a1,0
    800062ea:	ffffb097          	auipc	ra,0xffffb
    800062ee:	9e4080e7          	jalr	-1564(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    800062f2:	0001c497          	auipc	s1,0x1c
    800062f6:	b4e48493          	addi	s1,s1,-1202 # 80021e40 <disk>
    800062fa:	6605                	lui	a2,0x1
    800062fc:	4581                	li	a1,0
    800062fe:	6488                	ld	a0,8(s1)
    80006300:	ffffb097          	auipc	ra,0xffffb
    80006304:	9ce080e7          	jalr	-1586(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80006308:	6605                	lui	a2,0x1
    8000630a:	4581                	li	a1,0
    8000630c:	6888                	ld	a0,16(s1)
    8000630e:	ffffb097          	auipc	ra,0xffffb
    80006312:	9c0080e7          	jalr	-1600(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80006316:	100017b7          	lui	a5,0x10001
    8000631a:	4721                	li	a4,8
    8000631c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    8000631e:	4098                	lw	a4,0(s1)
    80006320:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006324:	40d8                	lw	a4,4(s1)
    80006326:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000632a:	6498                	ld	a4,8(s1)
    8000632c:	0007069b          	sext.w	a3,a4
    80006330:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006334:	9701                	srai	a4,a4,0x20
    80006336:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000633a:	6898                	ld	a4,16(s1)
    8000633c:	0007069b          	sext.w	a3,a4
    80006340:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006344:	9701                	srai	a4,a4,0x20
    80006346:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000634a:	4705                	li	a4,1
    8000634c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000634e:	00e48c23          	sb	a4,24(s1)
    80006352:	00e48ca3          	sb	a4,25(s1)
    80006356:	00e48d23          	sb	a4,26(s1)
    8000635a:	00e48da3          	sb	a4,27(s1)
    8000635e:	00e48e23          	sb	a4,28(s1)
    80006362:	00e48ea3          	sb	a4,29(s1)
    80006366:	00e48f23          	sb	a4,30(s1)
    8000636a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000636e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006372:	0727a823          	sw	s2,112(a5)
}
    80006376:	60e2                	ld	ra,24(sp)
    80006378:	6442                	ld	s0,16(sp)
    8000637a:	64a2                	ld	s1,8(sp)
    8000637c:	6902                	ld	s2,0(sp)
    8000637e:	6105                	addi	sp,sp,32
    80006380:	8082                	ret
    panic("could not find virtio disk");
    80006382:	00002517          	auipc	a0,0x2
    80006386:	4d650513          	addi	a0,a0,1238 # 80008858 <syscalls+0x338>
    8000638a:	ffffa097          	auipc	ra,0xffffa
    8000638e:	1b2080e7          	jalr	434(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006392:	00002517          	auipc	a0,0x2
    80006396:	4e650513          	addi	a0,a0,1254 # 80008878 <syscalls+0x358>
    8000639a:	ffffa097          	auipc	ra,0xffffa
    8000639e:	1a2080e7          	jalr	418(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    800063a2:	00002517          	auipc	a0,0x2
    800063a6:	4f650513          	addi	a0,a0,1270 # 80008898 <syscalls+0x378>
    800063aa:	ffffa097          	auipc	ra,0xffffa
    800063ae:	192080e7          	jalr	402(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    800063b2:	00002517          	auipc	a0,0x2
    800063b6:	50650513          	addi	a0,a0,1286 # 800088b8 <syscalls+0x398>
    800063ba:	ffffa097          	auipc	ra,0xffffa
    800063be:	182080e7          	jalr	386(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    800063c2:	00002517          	auipc	a0,0x2
    800063c6:	51650513          	addi	a0,a0,1302 # 800088d8 <syscalls+0x3b8>
    800063ca:	ffffa097          	auipc	ra,0xffffa
    800063ce:	172080e7          	jalr	370(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800063d2:	00002517          	auipc	a0,0x2
    800063d6:	52650513          	addi	a0,a0,1318 # 800088f8 <syscalls+0x3d8>
    800063da:	ffffa097          	auipc	ra,0xffffa
    800063de:	162080e7          	jalr	354(ra) # 8000053c <panic>

00000000800063e2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800063e2:	7159                	addi	sp,sp,-112
    800063e4:	f486                	sd	ra,104(sp)
    800063e6:	f0a2                	sd	s0,96(sp)
    800063e8:	eca6                	sd	s1,88(sp)
    800063ea:	e8ca                	sd	s2,80(sp)
    800063ec:	e4ce                	sd	s3,72(sp)
    800063ee:	e0d2                	sd	s4,64(sp)
    800063f0:	fc56                	sd	s5,56(sp)
    800063f2:	f85a                	sd	s6,48(sp)
    800063f4:	f45e                	sd	s7,40(sp)
    800063f6:	f062                	sd	s8,32(sp)
    800063f8:	ec66                	sd	s9,24(sp)
    800063fa:	e86a                	sd	s10,16(sp)
    800063fc:	1880                	addi	s0,sp,112
    800063fe:	8a2a                	mv	s4,a0
    80006400:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006402:	00c52c83          	lw	s9,12(a0)
    80006406:	001c9c9b          	slliw	s9,s9,0x1
    8000640a:	1c82                	slli	s9,s9,0x20
    8000640c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006410:	0001c517          	auipc	a0,0x1c
    80006414:	b5850513          	addi	a0,a0,-1192 # 80021f68 <disk+0x128>
    80006418:	ffffa097          	auipc	ra,0xffffa
    8000641c:	7ba080e7          	jalr	1978(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006420:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006422:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006424:	0001cb17          	auipc	s6,0x1c
    80006428:	a1cb0b13          	addi	s6,s6,-1508 # 80021e40 <disk>
  for(int i = 0; i < 3; i++){
    8000642c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000642e:	0001cc17          	auipc	s8,0x1c
    80006432:	b3ac0c13          	addi	s8,s8,-1222 # 80021f68 <disk+0x128>
    80006436:	a095                	j	8000649a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006438:	00fb0733          	add	a4,s6,a5
    8000643c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006440:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006442:	0207c563          	bltz	a5,8000646c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006446:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006448:	0591                	addi	a1,a1,4
    8000644a:	05560d63          	beq	a2,s5,800064a4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000644e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006450:	0001c717          	auipc	a4,0x1c
    80006454:	9f070713          	addi	a4,a4,-1552 # 80021e40 <disk>
    80006458:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000645a:	01874683          	lbu	a3,24(a4)
    8000645e:	fee9                	bnez	a3,80006438 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006460:	2785                	addiw	a5,a5,1
    80006462:	0705                	addi	a4,a4,1
    80006464:	fe979be3          	bne	a5,s1,8000645a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006468:	57fd                	li	a5,-1
    8000646a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000646c:	00c05e63          	blez	a2,80006488 <virtio_disk_rw+0xa6>
    80006470:	060a                	slli	a2,a2,0x2
    80006472:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006476:	0009a503          	lw	a0,0(s3)
    8000647a:	00000097          	auipc	ra,0x0
    8000647e:	cfc080e7          	jalr	-772(ra) # 80006176 <free_desc>
      for(int j = 0; j < i; j++)
    80006482:	0991                	addi	s3,s3,4
    80006484:	ffa999e3          	bne	s3,s10,80006476 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006488:	85e2                	mv	a1,s8
    8000648a:	0001c517          	auipc	a0,0x1c
    8000648e:	9ce50513          	addi	a0,a0,-1586 # 80021e58 <disk+0x18>
    80006492:	ffffc097          	auipc	ra,0xffffc
    80006496:	f52080e7          	jalr	-174(ra) # 800023e4 <sleep>
  for(int i = 0; i < 3; i++){
    8000649a:	f9040993          	addi	s3,s0,-112
{
    8000649e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800064a0:	864a                	mv	a2,s2
    800064a2:	b775                	j	8000644e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064a4:	f9042503          	lw	a0,-112(s0)
    800064a8:	00a50713          	addi	a4,a0,10
    800064ac:	0712                	slli	a4,a4,0x4

  if(write)
    800064ae:	0001c797          	auipc	a5,0x1c
    800064b2:	99278793          	addi	a5,a5,-1646 # 80021e40 <disk>
    800064b6:	00e786b3          	add	a3,a5,a4
    800064ba:	01703633          	snez	a2,s7
    800064be:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800064c0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800064c4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800064c8:	f6070613          	addi	a2,a4,-160
    800064cc:	6394                	ld	a3,0(a5)
    800064ce:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800064d0:	00870593          	addi	a1,a4,8
    800064d4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800064d6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800064d8:	0007b803          	ld	a6,0(a5)
    800064dc:	9642                	add	a2,a2,a6
    800064de:	46c1                	li	a3,16
    800064e0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800064e2:	4585                	li	a1,1
    800064e4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800064e8:	f9442683          	lw	a3,-108(s0)
    800064ec:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800064f0:	0692                	slli	a3,a3,0x4
    800064f2:	9836                	add	a6,a6,a3
    800064f4:	058a0613          	addi	a2,s4,88
    800064f8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800064fc:	0007b803          	ld	a6,0(a5)
    80006500:	96c2                	add	a3,a3,a6
    80006502:	40000613          	li	a2,1024
    80006506:	c690                	sw	a2,8(a3)
  if(write)
    80006508:	001bb613          	seqz	a2,s7
    8000650c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006510:	00166613          	ori	a2,a2,1
    80006514:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006518:	f9842603          	lw	a2,-104(s0)
    8000651c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006520:	00250693          	addi	a3,a0,2
    80006524:	0692                	slli	a3,a3,0x4
    80006526:	96be                	add	a3,a3,a5
    80006528:	58fd                	li	a7,-1
    8000652a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000652e:	0612                	slli	a2,a2,0x4
    80006530:	9832                	add	a6,a6,a2
    80006532:	f9070713          	addi	a4,a4,-112
    80006536:	973e                	add	a4,a4,a5
    80006538:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000653c:	6398                	ld	a4,0(a5)
    8000653e:	9732                	add	a4,a4,a2
    80006540:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006542:	4609                	li	a2,2
    80006544:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006548:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000654c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006550:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006554:	6794                	ld	a3,8(a5)
    80006556:	0026d703          	lhu	a4,2(a3)
    8000655a:	8b1d                	andi	a4,a4,7
    8000655c:	0706                	slli	a4,a4,0x1
    8000655e:	96ba                	add	a3,a3,a4
    80006560:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006564:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006568:	6798                	ld	a4,8(a5)
    8000656a:	00275783          	lhu	a5,2(a4)
    8000656e:	2785                	addiw	a5,a5,1
    80006570:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006574:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006578:	100017b7          	lui	a5,0x10001
    8000657c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006580:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006584:	0001c917          	auipc	s2,0x1c
    80006588:	9e490913          	addi	s2,s2,-1564 # 80021f68 <disk+0x128>
  while(b->disk == 1) {
    8000658c:	4485                	li	s1,1
    8000658e:	00b79c63          	bne	a5,a1,800065a6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006592:	85ca                	mv	a1,s2
    80006594:	8552                	mv	a0,s4
    80006596:	ffffc097          	auipc	ra,0xffffc
    8000659a:	e4e080e7          	jalr	-434(ra) # 800023e4 <sleep>
  while(b->disk == 1) {
    8000659e:	004a2783          	lw	a5,4(s4)
    800065a2:	fe9788e3          	beq	a5,s1,80006592 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800065a6:	f9042903          	lw	s2,-112(s0)
    800065aa:	00290713          	addi	a4,s2,2
    800065ae:	0712                	slli	a4,a4,0x4
    800065b0:	0001c797          	auipc	a5,0x1c
    800065b4:	89078793          	addi	a5,a5,-1904 # 80021e40 <disk>
    800065b8:	97ba                	add	a5,a5,a4
    800065ba:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800065be:	0001c997          	auipc	s3,0x1c
    800065c2:	88298993          	addi	s3,s3,-1918 # 80021e40 <disk>
    800065c6:	00491713          	slli	a4,s2,0x4
    800065ca:	0009b783          	ld	a5,0(s3)
    800065ce:	97ba                	add	a5,a5,a4
    800065d0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800065d4:	854a                	mv	a0,s2
    800065d6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800065da:	00000097          	auipc	ra,0x0
    800065de:	b9c080e7          	jalr	-1124(ra) # 80006176 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800065e2:	8885                	andi	s1,s1,1
    800065e4:	f0ed                	bnez	s1,800065c6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800065e6:	0001c517          	auipc	a0,0x1c
    800065ea:	98250513          	addi	a0,a0,-1662 # 80021f68 <disk+0x128>
    800065ee:	ffffa097          	auipc	ra,0xffffa
    800065f2:	698080e7          	jalr	1688(ra) # 80000c86 <release>
}
    800065f6:	70a6                	ld	ra,104(sp)
    800065f8:	7406                	ld	s0,96(sp)
    800065fa:	64e6                	ld	s1,88(sp)
    800065fc:	6946                	ld	s2,80(sp)
    800065fe:	69a6                	ld	s3,72(sp)
    80006600:	6a06                	ld	s4,64(sp)
    80006602:	7ae2                	ld	s5,56(sp)
    80006604:	7b42                	ld	s6,48(sp)
    80006606:	7ba2                	ld	s7,40(sp)
    80006608:	7c02                	ld	s8,32(sp)
    8000660a:	6ce2                	ld	s9,24(sp)
    8000660c:	6d42                	ld	s10,16(sp)
    8000660e:	6165                	addi	sp,sp,112
    80006610:	8082                	ret

0000000080006612 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006612:	1101                	addi	sp,sp,-32
    80006614:	ec06                	sd	ra,24(sp)
    80006616:	e822                	sd	s0,16(sp)
    80006618:	e426                	sd	s1,8(sp)
    8000661a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000661c:	0001c497          	auipc	s1,0x1c
    80006620:	82448493          	addi	s1,s1,-2012 # 80021e40 <disk>
    80006624:	0001c517          	auipc	a0,0x1c
    80006628:	94450513          	addi	a0,a0,-1724 # 80021f68 <disk+0x128>
    8000662c:	ffffa097          	auipc	ra,0xffffa
    80006630:	5a6080e7          	jalr	1446(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006634:	10001737          	lui	a4,0x10001
    80006638:	533c                	lw	a5,96(a4)
    8000663a:	8b8d                	andi	a5,a5,3
    8000663c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000663e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006642:	689c                	ld	a5,16(s1)
    80006644:	0204d703          	lhu	a4,32(s1)
    80006648:	0027d783          	lhu	a5,2(a5)
    8000664c:	04f70863          	beq	a4,a5,8000669c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006650:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006654:	6898                	ld	a4,16(s1)
    80006656:	0204d783          	lhu	a5,32(s1)
    8000665a:	8b9d                	andi	a5,a5,7
    8000665c:	078e                	slli	a5,a5,0x3
    8000665e:	97ba                	add	a5,a5,a4
    80006660:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006662:	00278713          	addi	a4,a5,2
    80006666:	0712                	slli	a4,a4,0x4
    80006668:	9726                	add	a4,a4,s1
    8000666a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000666e:	e721                	bnez	a4,800066b6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006670:	0789                	addi	a5,a5,2
    80006672:	0792                	slli	a5,a5,0x4
    80006674:	97a6                	add	a5,a5,s1
    80006676:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006678:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000667c:	ffffc097          	auipc	ra,0xffffc
    80006680:	dcc080e7          	jalr	-564(ra) # 80002448 <wakeup>

    disk.used_idx += 1;
    80006684:	0204d783          	lhu	a5,32(s1)
    80006688:	2785                	addiw	a5,a5,1
    8000668a:	17c2                	slli	a5,a5,0x30
    8000668c:	93c1                	srli	a5,a5,0x30
    8000668e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006692:	6898                	ld	a4,16(s1)
    80006694:	00275703          	lhu	a4,2(a4)
    80006698:	faf71ce3          	bne	a4,a5,80006650 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000669c:	0001c517          	auipc	a0,0x1c
    800066a0:	8cc50513          	addi	a0,a0,-1844 # 80021f68 <disk+0x128>
    800066a4:	ffffa097          	auipc	ra,0xffffa
    800066a8:	5e2080e7          	jalr	1506(ra) # 80000c86 <release>
}
    800066ac:	60e2                	ld	ra,24(sp)
    800066ae:	6442                	ld	s0,16(sp)
    800066b0:	64a2                	ld	s1,8(sp)
    800066b2:	6105                	addi	sp,sp,32
    800066b4:	8082                	ret
      panic("virtio_disk_intr status");
    800066b6:	00002517          	auipc	a0,0x2
    800066ba:	25a50513          	addi	a0,a0,602 # 80008910 <syscalls+0x3f0>
    800066be:	ffffa097          	auipc	ra,0xffffa
    800066c2:	e7e080e7          	jalr	-386(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
