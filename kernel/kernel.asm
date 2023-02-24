
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c2010113          	add	sp,sp,-992 # 80008c20 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	add	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	add	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	add	s0,sp,16
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
    8000002a:	0037979b          	sllw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	add	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	sll	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	sll	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	a9070713          	add	a4,a4,-1392 # 80008ae0 <timer_scratch>
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
    80000066:	d0e78793          	add	a5,a5,-754 # 80005d70 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	or	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	or	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	add	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	add	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	add	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fe650bf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	add	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	add	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	add	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	or	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srl	a5,a5,0xa
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
    800000fc:	0141                	add	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	add	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	add	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	add	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	4d4080e7          	jalr	1236(ra) # 800025fe <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addw	s2,s2,1
    80000144:	0485                	add	s1,s1,1
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
    8000015c:	6161                	add	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	add	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	add	s0,sp,96
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
    80000188:	a9c50513          	add	a0,a0,-1380 # 80010c20 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a8c48493          	add	s1,s1,-1396 # 80010c20 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	b1c90913          	add	s2,s2,-1252 # 80010cb8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	842080e7          	jalr	-1982(ra) # 800019f6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	290080e7          	jalr	656(ra) # 8000244c <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	fc2080e7          	jalr	-62(ra) # 8000218c <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a4270713          	add	a4,a4,-1470 # 80010c20 <cons>
    800001e6:	0017869b          	addw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	and	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	add	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	398080e7          	jalr	920(ra) # 800025a8 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	add	s4,s4,1
    --n;
    80000220:	39fd                	addw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00011517          	auipc	a0,0x11
    8000022c:	9f850513          	add	a0,a0,-1544 # 80010c20 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	9e250513          	add	a0,a0,-1566 # 80010c20 <cons>
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
    80000262:	6125                	add	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	a4f72523          	sw	a5,-1462(a4) # 80010cb8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	add	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	add	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	add	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	add	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	add	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00011517          	auipc	a0,0x11
    800002cc:	95850513          	add	a0,a0,-1704 # 80010c20 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	366080e7          	jalr	870(ra) # 80002654 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	92a50513          	add	a0,a0,-1750 # 80010c20 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	add	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00011717          	auipc	a4,0x11
    8000031e:	90670713          	add	a4,a4,-1786 # 80010c20 <cons>
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
    80000348:	8dc78793          	add	a5,a5,-1828 # 80010c20 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	and	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00011797          	auipc	a5,0x11
    80000376:	9467a783          	lw	a5,-1722(a5) # 80010cb8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	89a70713          	add	a4,a4,-1894 # 80010c20 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	88a48493          	add	s1,s1,-1910 # 80010c20 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addw	a5,a5,-1
    800003a6:	07f7f713          	and	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00011717          	auipc	a4,0x11
    800003d6:	84e70713          	add	a4,a4,-1970 # 80010c20 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	8cf72c23          	sw	a5,-1832(a4) # 80010cc0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00011797          	auipc	a5,0x11
    80000412:	81278793          	add	a5,a5,-2030 # 80010c20 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	and	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00011797          	auipc	a5,0x11
    80000436:	88c7a523          	sw	a2,-1910(a5) # 80010cbc <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	87e50513          	add	a0,a0,-1922 # 80010cb8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	dae080e7          	jalr	-594(ra) # 800021f0 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	add	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	add	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	add	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	7c450513          	add	a0,a0,1988 # 80010c20 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00198797          	auipc	a5,0x198
    80000478:	d4c78793          	add	a5,a5,-692 # 801981c0 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	add	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	add	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	add	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	add	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	add	s0,sp,48
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
    800004ae:	fd040693          	add	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	add	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	sll	a5,a5,0x20
    800004c8:	9381                	srl	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	add	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	add	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	add	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	add	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addw	a4,a4,-1
    8000050e:	1702                	sll	a4,a4,0x20
    80000510:	9301                	srl	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	add	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	add	sp,sp,48
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
    8000053c:	1101                	add	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	add	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	7807ac23          	sw	zero,1944(a5) # 80010ce0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	add	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	4d650513          	add	a0,a0,1238 # 80008a40 <syscalls+0x5a0>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	52f72223          	sw	a5,1316(a4) # 80008aa0 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	add	sp,sp,-192
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
    800005a2:	0100                	add	s0,sp,128
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
    800005bc:	728dad83          	lw	s11,1832(s11) # 80010ce0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	add	a5,s0,8
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
    800005e8:	a5cb0b13          	add	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	6d250513          	add	a0,a0,1746 # 80010cc8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	add	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addw	s3,s3,1
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
    8000065a:	00878713          	add	a4,a5,8
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
    8000067e:	00878713          	add	a4,a5,8
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
    8000069a:	00878713          	add	a4,a5,8
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
    800006c0:	03c95793          	srl	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	sll	s2,s2,0x4
    800006d4:	34fd                	addw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	add	a4,a5,8
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
    800006f8:	0485                	add	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	add	s1,s1,-1762 # 80008020 <etext+0x20>
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
    80000750:	6129                	add	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	57450513          	add	a0,a0,1396 # 80010cc8 <pr>
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
    80000766:	1101                	add	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	add	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	55848493          	add	s1,s1,1368 # 80010cc8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	add	a1,a1,-1856 # 80008038 <etext+0x38>
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
    80000794:	6105                	add	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	add	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	add	s0,sp,16
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
    800007cc:	89058593          	add	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	51850513          	add	a0,a0,1304 # 80010ce8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	add	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	add	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	add	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	2a47a783          	lw	a5,676(a5) # 80008aa0 <panicked>
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
    80000810:	0207f793          	and	a5,a5,32
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
    80000830:	6105                	add	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	2747b783          	ld	a5,628(a5) # 80008aa8 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	27473703          	ld	a4,628(a4) # 80008ab0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	add	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	add	s0,sp,64
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
    80000862:	48aa0a13          	add	s4,s4,1162 # 80010ce8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	24248493          	add	s1,s1,578 # 80008aa8 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	24298993          	add	s3,s3,578 # 80008ab0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	and	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	and	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	add	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	960080e7          	jalr	-1696(ra) # 800021f0 <wakeup>
    
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
    800008b4:	6121                	add	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	add	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	add	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	41c50513          	add	a0,a0,1052 # 80010ce8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1c47a783          	lw	a5,452(a5) # 80008aa0 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	1ca73703          	ld	a4,458(a4) # 80008ab0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	1ba7b783          	ld	a5,442(a5) # 80008aa8 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	3ee98993          	add	s3,s3,1006 # 80010ce8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	1a648493          	add	s1,s1,422 # 80008aa8 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	1a690913          	add	s2,s2,422 # 80008ab0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	872080e7          	jalr	-1934(ra) # 8000218c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	3b848493          	add	s1,s1,952 # 80010ce8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	16e7b623          	sd	a4,364(a5) # 80008ab0 <uart_tx_w>
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
    8000096a:	6145                	add	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	add	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	add	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	and	a5,a5,1
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
    8000098c:	0141                	add	sp,sp,16
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
    80000994:	1101                	add	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	add	s0,sp,32
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
    800009ba:	33248493          	add	s1,s1,818 # 80010ce8 <uart_tx_lock>
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
    800009e0:	6105                	add	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	add	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	add	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	sll	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00199797          	auipc	a5,0x199
    800009fc:	d4878793          	add	a5,a5,-696 # 80199740 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	sll	a5,a5,0x1b
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
    80000a1c:	30890913          	add	s2,s2,776 # 80010d20 <kmem>
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
    80000a46:	6105                	add	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	add	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	add	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	add	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	add	a4,a5,-1 # fff <_entry-0x7ffff001>
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
    80000aa2:	6145                	add	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	add	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	add	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	add	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	26a50513          	add	a0,a0,618 # 80010d20 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00199517          	auipc	a0,0x199
    80000ace:	c7650513          	add	a0,a0,-906 # 80199740 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	add	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	add	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	add	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	23448493          	add	s1,s1,564 # 80010d20 <kmem>
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
    80000b08:	21c50513          	add	a0,a0,540 # 80010d20 <kmem>
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
    80000b2c:	6105                	add	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	1f050513          	add	a0,a0,496 # 80010d20 <kmem>
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
    80000b42:	1141                	add	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	add	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	add	sp,sp,16
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
    80000b60:	1101                	add	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	add	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e6e080e7          	jalr	-402(ra) # 800019da <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	add	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	add	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	e3c080e7          	jalr	-452(ra) # 800019da <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e30080e7          	jalr	-464(ra) # 800019da <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	add	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	e18080e7          	jalr	-488(ra) # 800019da <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srl	s1,s1,0x1
    80000bcc:	8885                	and	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	add	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	add	s0,sp,32
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
    80000c06:	dd8080e7          	jalr	-552(ra) # 800019da <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	add	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	add	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	add	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	add	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	dac080e7          	jalr	-596(ra) # 800019da <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	and	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	add	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	add	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	add	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	add	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	add	s0,sp,32
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
    80000cba:	6105                	add	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	add	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	add	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	sll	a2,a2,0x20
    80000cda:	9201                	srl	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	add	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	add	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	add	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	add	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	sll	a3,a3,0x20
    80000cfe:	9281                	srl	a3,a3,0x20
    80000d00:	0685                	add	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	add	a0,a0,1
    80000d12:	0585                	add	a1,a1,1
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
    80000d22:	0141                	add	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	add	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	add	s0,sp,16
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
    80000d36:	1602                	sll	a2,a2,0x20
    80000d38:	9201                	srl	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	add	a1,a1,1
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fe658c1>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	add	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	sll	a3,a2,0x20
    80000d5a:	9281                	srl	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addw	a5,a2,-1
    80000d6a:	1782                	sll	a5,a5,0x20
    80000d6c:	9381                	srl	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	add	a4,a4,-1
    80000d76:	16fd                	add	a3,a3,-1
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
    80000d86:	1141                	add	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	add	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	add	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	add	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addw	a2,a2,-1
    80000db6:	0505                	add	a0,a0,1
    80000db8:	0585                	add	a1,a1,1
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
    80000dd2:	0141                	add	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	add	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	add	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	add	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	add	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	add	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	add	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	add	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addw	a3,a2,-1
    80000e24:	1682                	sll	a3,a3,0x20
    80000e26:	9281                	srl	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	add	a1,a1,1
    80000e32:	0785                	add	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	add	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	add	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	add	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	add	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	add	sp,sp,16
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
    80000e72:	1141                	add	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	add	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b50080e7          	jalr	-1200(ra) # 800019ca <cpuid>

    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	c3670713          	add	a4,a4,-970 # 80008ab8 <started>
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
    80000e9a:	b34080e7          	jalr	-1228(ra) # 800019ca <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	add	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0e0080e7          	jalr	224(ra) # 80000f90 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00002097          	auipc	ra,0x2
    80000ebc:	8e6080e7          	jalr	-1818(ra) # 8000279e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	ef0080e7          	jalr	-272(ra) # 80005db0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	10c080e7          	jalr	268(ra) # 80001fd4 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b6050513          	add	a0,a0,-1184 # 80008a40 <syscalls+0x5a0>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	b4050513          	add	a0,a0,-1216 # 80008a40 <syscalls+0x5a0>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	32e080e7          	jalr	814(ra) # 80001246 <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	070080e7          	jalr	112(ra) # 80000f90 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	9e6080e7          	jalr	-1562(ra) # 8000190e <procinit>
    trapinit();      // trap vectors
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	846080e7          	jalr	-1978(ra) # 80002776 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	866080e7          	jalr	-1946(ra) # 8000279e <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	e5a080e7          	jalr	-422(ra) # 80005d9a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	e68080e7          	jalr	-408(ra) # 80005db0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	fda080e7          	jalr	-38(ra) # 80002f2a <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	678080e7          	jalr	1656(ra) # 800035d0 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5ee080e7          	jalr	1518(ra) # 8000454e <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	f50080e7          	jalr	-176(ra) # 80005eb8 <virtio_disk_init>
    init_psa_regions();
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	460080e7          	jalr	1120(ra) # 800063d0 <init_psa_regions>
    userinit();      // first user process
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	d5e080e7          	jalr	-674(ra) # 80001cd6 <userinit>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	b2f72923          	sw	a5,-1230(a4) # 80008ab8 <started>
    80000f8e:	bf2d                	j	80000ec8 <main+0x56>

0000000080000f90 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f90:	1141                	add	sp,sp,-16
    80000f92:	e422                	sd	s0,8(sp)
    80000f94:	0800                	add	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f96:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f9a:	00008797          	auipc	a5,0x8
    80000f9e:	b267b783          	ld	a5,-1242(a5) # 80008ac0 <kernel_pagetable>
    80000fa2:	83b1                	srl	a5,a5,0xc
    80000fa4:	577d                	li	a4,-1
    80000fa6:	177e                	sll	a4,a4,0x3f
    80000fa8:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000faa:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fae:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb2:	6422                	ld	s0,8(sp)
    80000fb4:	0141                	add	sp,sp,16
    80000fb6:	8082                	ret

0000000080000fb8 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb8:	7139                	add	sp,sp,-64
    80000fba:	fc06                	sd	ra,56(sp)
    80000fbc:	f822                	sd	s0,48(sp)
    80000fbe:	f426                	sd	s1,40(sp)
    80000fc0:	f04a                	sd	s2,32(sp)
    80000fc2:	ec4e                	sd	s3,24(sp)
    80000fc4:	e852                	sd	s4,16(sp)
    80000fc6:	e456                	sd	s5,8(sp)
    80000fc8:	e05a                	sd	s6,0(sp)
    80000fca:	0080                	add	s0,sp,64
    80000fcc:	84aa                	mv	s1,a0
    80000fce:	89ae                	mv	s3,a1
    80000fd0:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd2:	57fd                	li	a5,-1
    80000fd4:	83e9                	srl	a5,a5,0x1a
    80000fd6:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd8:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fda:	04b7f263          	bgeu	a5,a1,8000101e <walk+0x66>
    panic("walk");
    80000fde:	00007517          	auipc	a0,0x7
    80000fe2:	0f250513          	add	a0,a0,242 # 800080d0 <digits+0x90>
    80000fe6:	fffff097          	auipc	ra,0xfffff
    80000fea:	556080e7          	jalr	1366(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fee:	060a8663          	beqz	s5,8000105a <walk+0xa2>
    80000ff2:	00000097          	auipc	ra,0x0
    80000ff6:	af0080e7          	jalr	-1296(ra) # 80000ae2 <kalloc>
    80000ffa:	84aa                	mv	s1,a0
    80000ffc:	c529                	beqz	a0,80001046 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffe:	6605                	lui	a2,0x1
    80001000:	4581                	li	a1,0
    80001002:	00000097          	auipc	ra,0x0
    80001006:	ccc080e7          	jalr	-820(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    8000100a:	00c4d793          	srl	a5,s1,0xc
    8000100e:	07aa                	sll	a5,a5,0xa
    80001010:	0017e793          	or	a5,a5,1
    80001014:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001018:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7fe658b7>
    8000101a:	036a0063          	beq	s4,s6,8000103a <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101e:	0149d933          	srl	s2,s3,s4
    80001022:	1ff97913          	and	s2,s2,511
    80001026:	090e                	sll	s2,s2,0x3
    80001028:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    8000102a:	00093483          	ld	s1,0(s2)
    8000102e:	0014f793          	and	a5,s1,1
    80001032:	dfd5                	beqz	a5,80000fee <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001034:	80a9                	srl	s1,s1,0xa
    80001036:	04b2                	sll	s1,s1,0xc
    80001038:	b7c5                	j	80001018 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    8000103a:	00c9d513          	srl	a0,s3,0xc
    8000103e:	1ff57513          	and	a0,a0,511
    80001042:	050e                	sll	a0,a0,0x3
    80001044:	9526                	add	a0,a0,s1
}
    80001046:	70e2                	ld	ra,56(sp)
    80001048:	7442                	ld	s0,48(sp)
    8000104a:	74a2                	ld	s1,40(sp)
    8000104c:	7902                	ld	s2,32(sp)
    8000104e:	69e2                	ld	s3,24(sp)
    80001050:	6a42                	ld	s4,16(sp)
    80001052:	6aa2                	ld	s5,8(sp)
    80001054:	6b02                	ld	s6,0(sp)
    80001056:	6121                	add	sp,sp,64
    80001058:	8082                	ret
        return 0;
    8000105a:	4501                	li	a0,0
    8000105c:	b7ed                	j	80001046 <walk+0x8e>

000000008000105e <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105e:	57fd                	li	a5,-1
    80001060:	83e9                	srl	a5,a5,0x1a
    80001062:	00b7f463          	bgeu	a5,a1,8000106a <walkaddr+0xc>
    return 0;
    80001066:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001068:	8082                	ret
{
    8000106a:	1141                	add	sp,sp,-16
    8000106c:	e406                	sd	ra,8(sp)
    8000106e:	e022                	sd	s0,0(sp)
    80001070:	0800                	add	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001072:	4601                	li	a2,0
    80001074:	00000097          	auipc	ra,0x0
    80001078:	f44080e7          	jalr	-188(ra) # 80000fb8 <walk>
  if(pte == 0)
    8000107c:	c105                	beqz	a0,8000109c <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107e:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001080:	0117f693          	and	a3,a5,17
    80001084:	4745                	li	a4,17
    return 0;
    80001086:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001088:	00e68663          	beq	a3,a4,80001094 <walkaddr+0x36>
}
    8000108c:	60a2                	ld	ra,8(sp)
    8000108e:	6402                	ld	s0,0(sp)
    80001090:	0141                	add	sp,sp,16
    80001092:	8082                	ret
  pa = PTE2PA(*pte);
    80001094:	83a9                	srl	a5,a5,0xa
    80001096:	00c79513          	sll	a0,a5,0xc
  return pa;
    8000109a:	bfcd                	j	8000108c <walkaddr+0x2e>
    return 0;
    8000109c:	4501                	li	a0,0
    8000109e:	b7fd                	j	8000108c <walkaddr+0x2e>

00000000800010a0 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    800010a0:	715d                	add	sp,sp,-80
    800010a2:	e486                	sd	ra,72(sp)
    800010a4:	e0a2                	sd	s0,64(sp)
    800010a6:	fc26                	sd	s1,56(sp)
    800010a8:	f84a                	sd	s2,48(sp)
    800010aa:	f44e                	sd	s3,40(sp)
    800010ac:	f052                	sd	s4,32(sp)
    800010ae:	ec56                	sd	s5,24(sp)
    800010b0:	e85a                	sd	s6,16(sp)
    800010b2:	e45e                	sd	s7,8(sp)
    800010b4:	0880                	add	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b6:	c639                	beqz	a2,80001104 <mappages+0x64>
    800010b8:	8aaa                	mv	s5,a0
    800010ba:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010bc:	777d                	lui	a4,0xfffff
    800010be:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c2:	fff58993          	add	s3,a1,-1
    800010c6:	99b2                	add	s3,s3,a2
    800010c8:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010cc:	893e                	mv	s2,a5
    800010ce:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d2:	6b85                	lui	s7,0x1
    800010d4:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d8:	4605                	li	a2,1
    800010da:	85ca                	mv	a1,s2
    800010dc:	8556                	mv	a0,s5
    800010de:	00000097          	auipc	ra,0x0
    800010e2:	eda080e7          	jalr	-294(ra) # 80000fb8 <walk>
    800010e6:	cd1d                	beqz	a0,80001124 <mappages+0x84>
    if(*pte & PTE_V)
    800010e8:	611c                	ld	a5,0(a0)
    800010ea:	8b85                	and	a5,a5,1
    800010ec:	e785                	bnez	a5,80001114 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ee:	80b1                	srl	s1,s1,0xc
    800010f0:	04aa                	sll	s1,s1,0xa
    800010f2:	0164e4b3          	or	s1,s1,s6
    800010f6:	0014e493          	or	s1,s1,1
    800010fa:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fc:	05390063          	beq	s2,s3,8000113c <mappages+0x9c>
    a += PGSIZE;
    80001100:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001102:	bfc9                	j	800010d4 <mappages+0x34>
    panic("mappages: size");
    80001104:	00007517          	auipc	a0,0x7
    80001108:	fd450513          	add	a0,a0,-44 # 800080d8 <digits+0x98>
    8000110c:	fffff097          	auipc	ra,0xfffff
    80001110:	430080e7          	jalr	1072(ra) # 8000053c <panic>
      panic("mappages: remap");
    80001114:	00007517          	auipc	a0,0x7
    80001118:	fd450513          	add	a0,a0,-44 # 800080e8 <digits+0xa8>
    8000111c:	fffff097          	auipc	ra,0xfffff
    80001120:	420080e7          	jalr	1056(ra) # 8000053c <panic>
      return -1;
    80001124:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001126:	60a6                	ld	ra,72(sp)
    80001128:	6406                	ld	s0,64(sp)
    8000112a:	74e2                	ld	s1,56(sp)
    8000112c:	7942                	ld	s2,48(sp)
    8000112e:	79a2                	ld	s3,40(sp)
    80001130:	7a02                	ld	s4,32(sp)
    80001132:	6ae2                	ld	s5,24(sp)
    80001134:	6b42                	ld	s6,16(sp)
    80001136:	6ba2                	ld	s7,8(sp)
    80001138:	6161                	add	sp,sp,80
    8000113a:	8082                	ret
  return 0;
    8000113c:	4501                	li	a0,0
    8000113e:	b7e5                	j	80001126 <mappages+0x86>

0000000080001140 <kvmmap>:
{
    80001140:	1141                	add	sp,sp,-16
    80001142:	e406                	sd	ra,8(sp)
    80001144:	e022                	sd	s0,0(sp)
    80001146:	0800                	add	s0,sp,16
    80001148:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    8000114a:	86b2                	mv	a3,a2
    8000114c:	863e                	mv	a2,a5
    8000114e:	00000097          	auipc	ra,0x0
    80001152:	f52080e7          	jalr	-174(ra) # 800010a0 <mappages>
    80001156:	e509                	bnez	a0,80001160 <kvmmap+0x20>
}
    80001158:	60a2                	ld	ra,8(sp)
    8000115a:	6402                	ld	s0,0(sp)
    8000115c:	0141                	add	sp,sp,16
    8000115e:	8082                	ret
    panic("kvmmap");
    80001160:	00007517          	auipc	a0,0x7
    80001164:	f9850513          	add	a0,a0,-104 # 800080f8 <digits+0xb8>
    80001168:	fffff097          	auipc	ra,0xfffff
    8000116c:	3d4080e7          	jalr	980(ra) # 8000053c <panic>

0000000080001170 <kvmmake>:
{
    80001170:	1101                	add	sp,sp,-32
    80001172:	ec06                	sd	ra,24(sp)
    80001174:	e822                	sd	s0,16(sp)
    80001176:	e426                	sd	s1,8(sp)
    80001178:	e04a                	sd	s2,0(sp)
    8000117a:	1000                	add	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117c:	00000097          	auipc	ra,0x0
    80001180:	966080e7          	jalr	-1690(ra) # 80000ae2 <kalloc>
    80001184:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001186:	6605                	lui	a2,0x1
    80001188:	4581                	li	a1,0
    8000118a:	00000097          	auipc	ra,0x0
    8000118e:	b44080e7          	jalr	-1212(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001192:	4719                	li	a4,6
    80001194:	6685                	lui	a3,0x1
    80001196:	10000637          	lui	a2,0x10000
    8000119a:	100005b7          	lui	a1,0x10000
    8000119e:	8526                	mv	a0,s1
    800011a0:	00000097          	auipc	ra,0x0
    800011a4:	fa0080e7          	jalr	-96(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a8:	4719                	li	a4,6
    800011aa:	6685                	lui	a3,0x1
    800011ac:	10001637          	lui	a2,0x10001
    800011b0:	100015b7          	lui	a1,0x10001
    800011b4:	8526                	mv	a0,s1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	f8a080e7          	jalr	-118(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011be:	4719                	li	a4,6
    800011c0:	004006b7          	lui	a3,0x400
    800011c4:	0c000637          	lui	a2,0xc000
    800011c8:	0c0005b7          	lui	a1,0xc000
    800011cc:	8526                	mv	a0,s1
    800011ce:	00000097          	auipc	ra,0x0
    800011d2:	f72080e7          	jalr	-142(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d6:	00007917          	auipc	s2,0x7
    800011da:	e2a90913          	add	s2,s2,-470 # 80008000 <etext>
    800011de:	4729                	li	a4,10
    800011e0:	80007697          	auipc	a3,0x80007
    800011e4:	e2068693          	add	a3,a3,-480 # 8000 <_entry-0x7fff8000>
    800011e8:	4605                	li	a2,1
    800011ea:	067e                	sll	a2,a2,0x1f
    800011ec:	85b2                	mv	a1,a2
    800011ee:	8526                	mv	a0,s1
    800011f0:	00000097          	auipc	ra,0x0
    800011f4:	f50080e7          	jalr	-176(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f8:	4719                	li	a4,6
    800011fa:	46c5                	li	a3,17
    800011fc:	06ee                	sll	a3,a3,0x1b
    800011fe:	412686b3          	sub	a3,a3,s2
    80001202:	864a                	mv	a2,s2
    80001204:	85ca                	mv	a1,s2
    80001206:	8526                	mv	a0,s1
    80001208:	00000097          	auipc	ra,0x0
    8000120c:	f38080e7          	jalr	-200(ra) # 80001140 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001210:	4729                	li	a4,10
    80001212:	6685                	lui	a3,0x1
    80001214:	00006617          	auipc	a2,0x6
    80001218:	dec60613          	add	a2,a2,-532 # 80007000 <_trampoline>
    8000121c:	040005b7          	lui	a1,0x4000
    80001220:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001222:	05b2                	sll	a1,a1,0xc
    80001224:	8526                	mv	a0,s1
    80001226:	00000097          	auipc	ra,0x0
    8000122a:	f1a080e7          	jalr	-230(ra) # 80001140 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122e:	8526                	mv	a0,s1
    80001230:	00000097          	auipc	ra,0x0
    80001234:	640080e7          	jalr	1600(ra) # 80001870 <proc_mapstacks>
}
    80001238:	8526                	mv	a0,s1
    8000123a:	60e2                	ld	ra,24(sp)
    8000123c:	6442                	ld	s0,16(sp)
    8000123e:	64a2                	ld	s1,8(sp)
    80001240:	6902                	ld	s2,0(sp)
    80001242:	6105                	add	sp,sp,32
    80001244:	8082                	ret

0000000080001246 <kvminit>:
{
    80001246:	1141                	add	sp,sp,-16
    80001248:	e406                	sd	ra,8(sp)
    8000124a:	e022                	sd	s0,0(sp)
    8000124c:	0800                	add	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124e:	00000097          	auipc	ra,0x0
    80001252:	f22080e7          	jalr	-222(ra) # 80001170 <kvmmake>
    80001256:	00008797          	auipc	a5,0x8
    8000125a:	86a7b523          	sd	a0,-1942(a5) # 80008ac0 <kernel_pagetable>
}
    8000125e:	60a2                	ld	ra,8(sp)
    80001260:	6402                	ld	s0,0(sp)
    80001262:	0141                	add	sp,sp,16
    80001264:	8082                	ret

0000000080001266 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001266:	715d                	add	sp,sp,-80
    80001268:	e486                	sd	ra,72(sp)
    8000126a:	e0a2                	sd	s0,64(sp)
    8000126c:	fc26                	sd	s1,56(sp)
    8000126e:	f84a                	sd	s2,48(sp)
    80001270:	f44e                	sd	s3,40(sp)
    80001272:	f052                	sd	s4,32(sp)
    80001274:	ec56                	sd	s5,24(sp)
    80001276:	e85a                	sd	s6,16(sp)
    80001278:	e45e                	sd	s7,8(sp)
    8000127a:	0880                	add	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127c:	03459793          	sll	a5,a1,0x34
    80001280:	e795                	bnez	a5,800012ac <uvmunmap+0x46>
    80001282:	8a2a                	mv	s4,a0
    80001284:	892e                	mv	s2,a1
    80001286:	8b36                	mv	s6,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	0632                	sll	a2,a2,0xc
    8000128a:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      continue;
      /* CSE 536: removed for on-demand allocation. */
      // panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128e:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001290:	6a85                	lui	s5,0x1
    80001292:	0535ea63          	bltu	a1,s3,800012e6 <uvmunmap+0x80>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001296:	60a6                	ld	ra,72(sp)
    80001298:	6406                	ld	s0,64(sp)
    8000129a:	74e2                	ld	s1,56(sp)
    8000129c:	7942                	ld	s2,48(sp)
    8000129e:	79a2                	ld	s3,40(sp)
    800012a0:	7a02                	ld	s4,32(sp)
    800012a2:	6ae2                	ld	s5,24(sp)
    800012a4:	6b42                	ld	s6,16(sp)
    800012a6:	6ba2                	ld	s7,8(sp)
    800012a8:	6161                	add	sp,sp,80
    800012aa:	8082                	ret
    panic("uvmunmap: not aligned");
    800012ac:	00007517          	auipc	a0,0x7
    800012b0:	e5450513          	add	a0,a0,-428 # 80008100 <digits+0xc0>
    800012b4:	fffff097          	auipc	ra,0xfffff
    800012b8:	288080e7          	jalr	648(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012bc:	00007517          	auipc	a0,0x7
    800012c0:	e5c50513          	add	a0,a0,-420 # 80008118 <digits+0xd8>
    800012c4:	fffff097          	auipc	ra,0xfffff
    800012c8:	278080e7          	jalr	632(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012cc:	00007517          	auipc	a0,0x7
    800012d0:	e5c50513          	add	a0,a0,-420 # 80008128 <digits+0xe8>
    800012d4:	fffff097          	auipc	ra,0xfffff
    800012d8:	268080e7          	jalr	616(ra) # 8000053c <panic>
    *pte = 0;
    800012dc:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e0:	9956                	add	s2,s2,s5
    800012e2:	fb397ae3          	bgeu	s2,s3,80001296 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012e6:	4601                	li	a2,0
    800012e8:	85ca                	mv	a1,s2
    800012ea:	8552                	mv	a0,s4
    800012ec:	00000097          	auipc	ra,0x0
    800012f0:	ccc080e7          	jalr	-820(ra) # 80000fb8 <walk>
    800012f4:	84aa                	mv	s1,a0
    800012f6:	d179                	beqz	a0,800012bc <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    800012f8:	611c                	ld	a5,0(a0)
    800012fa:	0017f713          	and	a4,a5,1
    800012fe:	d36d                	beqz	a4,800012e0 <uvmunmap+0x7a>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001300:	3ff7f713          	and	a4,a5,1023
    80001304:	fd7704e3          	beq	a4,s7,800012cc <uvmunmap+0x66>
    if(do_free){
    80001308:	fc0b0ae3          	beqz	s6,800012dc <uvmunmap+0x76>
      uint64 pa = PTE2PA(*pte);
    8000130c:	83a9                	srl	a5,a5,0xa
      kfree((void*)pa);
    8000130e:	00c79513          	sll	a0,a5,0xc
    80001312:	fffff097          	auipc	ra,0xfffff
    80001316:	6d2080e7          	jalr	1746(ra) # 800009e4 <kfree>
    8000131a:	b7c9                	j	800012dc <uvmunmap+0x76>

000000008000131c <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    8000131c:	1101                	add	sp,sp,-32
    8000131e:	ec06                	sd	ra,24(sp)
    80001320:	e822                	sd	s0,16(sp)
    80001322:	e426                	sd	s1,8(sp)
    80001324:	1000                	add	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001326:	fffff097          	auipc	ra,0xfffff
    8000132a:	7bc080e7          	jalr	1980(ra) # 80000ae2 <kalloc>
    8000132e:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001330:	c519                	beqz	a0,8000133e <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001332:	6605                	lui	a2,0x1
    80001334:	4581                	li	a1,0
    80001336:	00000097          	auipc	ra,0x0
    8000133a:	998080e7          	jalr	-1640(ra) # 80000cce <memset>
  return pagetable;
}
    8000133e:	8526                	mv	a0,s1
    80001340:	60e2                	ld	ra,24(sp)
    80001342:	6442                	ld	s0,16(sp)
    80001344:	64a2                	ld	s1,8(sp)
    80001346:	6105                	add	sp,sp,32
    80001348:	8082                	ret

000000008000134a <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000134a:	7179                	add	sp,sp,-48
    8000134c:	f406                	sd	ra,40(sp)
    8000134e:	f022                	sd	s0,32(sp)
    80001350:	ec26                	sd	s1,24(sp)
    80001352:	e84a                	sd	s2,16(sp)
    80001354:	e44e                	sd	s3,8(sp)
    80001356:	e052                	sd	s4,0(sp)
    80001358:	1800                	add	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    8000135a:	6785                	lui	a5,0x1
    8000135c:	04f67863          	bgeu	a2,a5,800013ac <uvmfirst+0x62>
    80001360:	8a2a                	mv	s4,a0
    80001362:	89ae                	mv	s3,a1
    80001364:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001366:	fffff097          	auipc	ra,0xfffff
    8000136a:	77c080e7          	jalr	1916(ra) # 80000ae2 <kalloc>
    8000136e:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001370:	6605                	lui	a2,0x1
    80001372:	4581                	li	a1,0
    80001374:	00000097          	auipc	ra,0x0
    80001378:	95a080e7          	jalr	-1702(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    8000137c:	4779                	li	a4,30
    8000137e:	86ca                	mv	a3,s2
    80001380:	6605                	lui	a2,0x1
    80001382:	4581                	li	a1,0
    80001384:	8552                	mv	a0,s4
    80001386:	00000097          	auipc	ra,0x0
    8000138a:	d1a080e7          	jalr	-742(ra) # 800010a0 <mappages>
  memmove(mem, src, sz);
    8000138e:	8626                	mv	a2,s1
    80001390:	85ce                	mv	a1,s3
    80001392:	854a                	mv	a0,s2
    80001394:	00000097          	auipc	ra,0x0
    80001398:	996080e7          	jalr	-1642(ra) # 80000d2a <memmove>
}
    8000139c:	70a2                	ld	ra,40(sp)
    8000139e:	7402                	ld	s0,32(sp)
    800013a0:	64e2                	ld	s1,24(sp)
    800013a2:	6942                	ld	s2,16(sp)
    800013a4:	69a2                	ld	s3,8(sp)
    800013a6:	6a02                	ld	s4,0(sp)
    800013a8:	6145                	add	sp,sp,48
    800013aa:	8082                	ret
    panic("uvmfirst: more than a page");
    800013ac:	00007517          	auipc	a0,0x7
    800013b0:	d9450513          	add	a0,a0,-620 # 80008140 <digits+0x100>
    800013b4:	fffff097          	auipc	ra,0xfffff
    800013b8:	188080e7          	jalr	392(ra) # 8000053c <panic>

00000000800013bc <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013bc:	1101                	add	sp,sp,-32
    800013be:	ec06                	sd	ra,24(sp)
    800013c0:	e822                	sd	s0,16(sp)
    800013c2:	e426                	sd	s1,8(sp)
    800013c4:	1000                	add	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013c6:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013c8:	00b67d63          	bgeu	a2,a1,800013e2 <uvmdealloc+0x26>
    800013cc:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013ce:	6785                	lui	a5,0x1
    800013d0:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d2:	00f60733          	add	a4,a2,a5
    800013d6:	76fd                	lui	a3,0xfffff
    800013d8:	8f75                	and	a4,a4,a3
    800013da:	97ae                	add	a5,a5,a1
    800013dc:	8ff5                	and	a5,a5,a3
    800013de:	00f76863          	bltu	a4,a5,800013ee <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e2:	8526                	mv	a0,s1
    800013e4:	60e2                	ld	ra,24(sp)
    800013e6:	6442                	ld	s0,16(sp)
    800013e8:	64a2                	ld	s1,8(sp)
    800013ea:	6105                	add	sp,sp,32
    800013ec:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013ee:	8f99                	sub	a5,a5,a4
    800013f0:	83b1                	srl	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f2:	4685                	li	a3,1
    800013f4:	0007861b          	sext.w	a2,a5
    800013f8:	85ba                	mv	a1,a4
    800013fa:	00000097          	auipc	ra,0x0
    800013fe:	e6c080e7          	jalr	-404(ra) # 80001266 <uvmunmap>
    80001402:	b7c5                	j	800013e2 <uvmdealloc+0x26>

0000000080001404 <uvmalloc>:
  if(newsz < oldsz)
    80001404:	0ab66563          	bltu	a2,a1,800014ae <uvmalloc+0xaa>
{
    80001408:	7139                	add	sp,sp,-64
    8000140a:	fc06                	sd	ra,56(sp)
    8000140c:	f822                	sd	s0,48(sp)
    8000140e:	f426                	sd	s1,40(sp)
    80001410:	f04a                	sd	s2,32(sp)
    80001412:	ec4e                	sd	s3,24(sp)
    80001414:	e852                	sd	s4,16(sp)
    80001416:	e456                	sd	s5,8(sp)
    80001418:	e05a                	sd	s6,0(sp)
    8000141a:	0080                	add	s0,sp,64
    8000141c:	8aaa                	mv	s5,a0
    8000141e:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001420:	6785                	lui	a5,0x1
    80001422:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001424:	95be                	add	a1,a1,a5
    80001426:	77fd                	lui	a5,0xfffff
    80001428:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000142c:	08c9f363          	bgeu	s3,a2,800014b2 <uvmalloc+0xae>
    80001430:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001432:	0126eb13          	or	s6,a3,18
    mem = kalloc();
    80001436:	fffff097          	auipc	ra,0xfffff
    8000143a:	6ac080e7          	jalr	1708(ra) # 80000ae2 <kalloc>
    8000143e:	84aa                	mv	s1,a0
    if(mem == 0){
    80001440:	c51d                	beqz	a0,8000146e <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001442:	6605                	lui	a2,0x1
    80001444:	4581                	li	a1,0
    80001446:	00000097          	auipc	ra,0x0
    8000144a:	888080e7          	jalr	-1912(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000144e:	875a                	mv	a4,s6
    80001450:	86a6                	mv	a3,s1
    80001452:	6605                	lui	a2,0x1
    80001454:	85ca                	mv	a1,s2
    80001456:	8556                	mv	a0,s5
    80001458:	00000097          	auipc	ra,0x0
    8000145c:	c48080e7          	jalr	-952(ra) # 800010a0 <mappages>
    80001460:	e90d                	bnez	a0,80001492 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001462:	6785                	lui	a5,0x1
    80001464:	993e                	add	s2,s2,a5
    80001466:	fd4968e3          	bltu	s2,s4,80001436 <uvmalloc+0x32>
  return newsz;
    8000146a:	8552                	mv	a0,s4
    8000146c:	a809                	j	8000147e <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000146e:	864e                	mv	a2,s3
    80001470:	85ca                	mv	a1,s2
    80001472:	8556                	mv	a0,s5
    80001474:	00000097          	auipc	ra,0x0
    80001478:	f48080e7          	jalr	-184(ra) # 800013bc <uvmdealloc>
      return 0;
    8000147c:	4501                	li	a0,0
}
    8000147e:	70e2                	ld	ra,56(sp)
    80001480:	7442                	ld	s0,48(sp)
    80001482:	74a2                	ld	s1,40(sp)
    80001484:	7902                	ld	s2,32(sp)
    80001486:	69e2                	ld	s3,24(sp)
    80001488:	6a42                	ld	s4,16(sp)
    8000148a:	6aa2                	ld	s5,8(sp)
    8000148c:	6b02                	ld	s6,0(sp)
    8000148e:	6121                	add	sp,sp,64
    80001490:	8082                	ret
      kfree(mem);
    80001492:	8526                	mv	a0,s1
    80001494:	fffff097          	auipc	ra,0xfffff
    80001498:	550080e7          	jalr	1360(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    8000149c:	864e                	mv	a2,s3
    8000149e:	85ca                	mv	a1,s2
    800014a0:	8556                	mv	a0,s5
    800014a2:	00000097          	auipc	ra,0x0
    800014a6:	f1a080e7          	jalr	-230(ra) # 800013bc <uvmdealloc>
      return 0;
    800014aa:	4501                	li	a0,0
    800014ac:	bfc9                	j	8000147e <uvmalloc+0x7a>
    return oldsz;
    800014ae:	852e                	mv	a0,a1
}
    800014b0:	8082                	ret
  return newsz;
    800014b2:	8532                	mv	a0,a2
    800014b4:	b7e9                	j	8000147e <uvmalloc+0x7a>

00000000800014b6 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014b6:	7179                	add	sp,sp,-48
    800014b8:	f406                	sd	ra,40(sp)
    800014ba:	f022                	sd	s0,32(sp)
    800014bc:	ec26                	sd	s1,24(sp)
    800014be:	e84a                	sd	s2,16(sp)
    800014c0:	e44e                	sd	s3,8(sp)
    800014c2:	e052                	sd	s4,0(sp)
    800014c4:	1800                	add	s0,sp,48
    800014c6:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014c8:	84aa                	mv	s1,a0
    800014ca:	6905                	lui	s2,0x1
    800014cc:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ce:	4985                	li	s3,1
    800014d0:	a829                	j	800014ea <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d2:	81a9                	srl	a1,a1,0xa
      freewalk((pagetable_t)child);
    800014d4:	00c59513          	sll	a0,a1,0xc
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	fde080e7          	jalr	-34(ra) # 800014b6 <freewalk>
      pagetable[i] = 0;
    800014e0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e4:	04a1                	add	s1,s1,8
    800014e6:	03248b63          	beq	s1,s2,8000151c <freewalk+0x66>
    pte_t pte = pagetable[i];
    800014ea:	608c                	ld	a1,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ec:	00f5f793          	and	a5,a1,15
    800014f0:	ff3781e3          	beq	a5,s3,800014d2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f4:	0015f793          	and	a5,a1,1
    800014f8:	d7f5                	beqz	a5,800014e4 <freewalk+0x2e>
      printf("pte %p, PTE_V %p\n", pte, PTE_V);
    800014fa:	4605                	li	a2,1
    800014fc:	00007517          	auipc	a0,0x7
    80001500:	c6450513          	add	a0,a0,-924 # 80008160 <digits+0x120>
    80001504:	fffff097          	auipc	ra,0xfffff
    80001508:	082080e7          	jalr	130(ra) # 80000586 <printf>
      panic("freewalk: leaf");
    8000150c:	00007517          	auipc	a0,0x7
    80001510:	c6c50513          	add	a0,a0,-916 # 80008178 <digits+0x138>
    80001514:	fffff097          	auipc	ra,0xfffff
    80001518:	028080e7          	jalr	40(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000151c:	8552                	mv	a0,s4
    8000151e:	fffff097          	auipc	ra,0xfffff
    80001522:	4c6080e7          	jalr	1222(ra) # 800009e4 <kfree>
}
    80001526:	70a2                	ld	ra,40(sp)
    80001528:	7402                	ld	s0,32(sp)
    8000152a:	64e2                	ld	s1,24(sp)
    8000152c:	6942                	ld	s2,16(sp)
    8000152e:	69a2                	ld	s3,8(sp)
    80001530:	6a02                	ld	s4,0(sp)
    80001532:	6145                	add	sp,sp,48
    80001534:	8082                	ret

0000000080001536 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001536:	1101                	add	sp,sp,-32
    80001538:	ec06                	sd	ra,24(sp)
    8000153a:	e822                	sd	s0,16(sp)
    8000153c:	e426                	sd	s1,8(sp)
    8000153e:	1000                	add	s0,sp,32
    80001540:	84aa                	mv	s1,a0
  if(sz > 0)
    80001542:	e999                	bnez	a1,80001558 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001544:	8526                	mv	a0,s1
    80001546:	00000097          	auipc	ra,0x0
    8000154a:	f70080e7          	jalr	-144(ra) # 800014b6 <freewalk>
}
    8000154e:	60e2                	ld	ra,24(sp)
    80001550:	6442                	ld	s0,16(sp)
    80001552:	64a2                	ld	s1,8(sp)
    80001554:	6105                	add	sp,sp,32
    80001556:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001558:	6785                	lui	a5,0x1
    8000155a:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000155c:	95be                	add	a1,a1,a5
    8000155e:	4685                	li	a3,1
    80001560:	00c5d613          	srl	a2,a1,0xc
    80001564:	4581                	li	a1,0
    80001566:	00000097          	auipc	ra,0x0
    8000156a:	d00080e7          	jalr	-768(ra) # 80001266 <uvmunmap>
    8000156e:	bfd9                	j	80001544 <uvmfree+0xe>

0000000080001570 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001570:	c679                	beqz	a2,8000163e <uvmcopy+0xce>
{
    80001572:	715d                	add	sp,sp,-80
    80001574:	e486                	sd	ra,72(sp)
    80001576:	e0a2                	sd	s0,64(sp)
    80001578:	fc26                	sd	s1,56(sp)
    8000157a:	f84a                	sd	s2,48(sp)
    8000157c:	f44e                	sd	s3,40(sp)
    8000157e:	f052                	sd	s4,32(sp)
    80001580:	ec56                	sd	s5,24(sp)
    80001582:	e85a                	sd	s6,16(sp)
    80001584:	e45e                	sd	s7,8(sp)
    80001586:	0880                	add	s0,sp,80
    80001588:	8b2a                	mv	s6,a0
    8000158a:	8aae                	mv	s5,a1
    8000158c:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000158e:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001590:	4601                	li	a2,0
    80001592:	85ce                	mv	a1,s3
    80001594:	855a                	mv	a0,s6
    80001596:	00000097          	auipc	ra,0x0
    8000159a:	a22080e7          	jalr	-1502(ra) # 80000fb8 <walk>
    8000159e:	c531                	beqz	a0,800015ea <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800015a0:	6118                	ld	a4,0(a0)
    800015a2:	00177793          	and	a5,a4,1
    800015a6:	cbb1                	beqz	a5,800015fa <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a8:	00a75593          	srl	a1,a4,0xa
    800015ac:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015b0:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015b4:	fffff097          	auipc	ra,0xfffff
    800015b8:	52e080e7          	jalr	1326(ra) # 80000ae2 <kalloc>
    800015bc:	892a                	mv	s2,a0
    800015be:	c939                	beqz	a0,80001614 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015c0:	6605                	lui	a2,0x1
    800015c2:	85de                	mv	a1,s7
    800015c4:	fffff097          	auipc	ra,0xfffff
    800015c8:	766080e7          	jalr	1894(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015cc:	8726                	mv	a4,s1
    800015ce:	86ca                	mv	a3,s2
    800015d0:	6605                	lui	a2,0x1
    800015d2:	85ce                	mv	a1,s3
    800015d4:	8556                	mv	a0,s5
    800015d6:	00000097          	auipc	ra,0x0
    800015da:	aca080e7          	jalr	-1334(ra) # 800010a0 <mappages>
    800015de:	e515                	bnez	a0,8000160a <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015e0:	6785                	lui	a5,0x1
    800015e2:	99be                	add	s3,s3,a5
    800015e4:	fb49e6e3          	bltu	s3,s4,80001590 <uvmcopy+0x20>
    800015e8:	a081                	j	80001628 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015ea:	00007517          	auipc	a0,0x7
    800015ee:	b9e50513          	add	a0,a0,-1122 # 80008188 <digits+0x148>
    800015f2:	fffff097          	auipc	ra,0xfffff
    800015f6:	f4a080e7          	jalr	-182(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015fa:	00007517          	auipc	a0,0x7
    800015fe:	bae50513          	add	a0,a0,-1106 # 800081a8 <digits+0x168>
    80001602:	fffff097          	auipc	ra,0xfffff
    80001606:	f3a080e7          	jalr	-198(ra) # 8000053c <panic>
      kfree(mem);
    8000160a:	854a                	mv	a0,s2
    8000160c:	fffff097          	auipc	ra,0xfffff
    80001610:	3d8080e7          	jalr	984(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001614:	4685                	li	a3,1
    80001616:	00c9d613          	srl	a2,s3,0xc
    8000161a:	4581                	li	a1,0
    8000161c:	8556                	mv	a0,s5
    8000161e:	00000097          	auipc	ra,0x0
    80001622:	c48080e7          	jalr	-952(ra) # 80001266 <uvmunmap>
  return -1;
    80001626:	557d                	li	a0,-1
}
    80001628:	60a6                	ld	ra,72(sp)
    8000162a:	6406                	ld	s0,64(sp)
    8000162c:	74e2                	ld	s1,56(sp)
    8000162e:	7942                	ld	s2,48(sp)
    80001630:	79a2                	ld	s3,40(sp)
    80001632:	7a02                	ld	s4,32(sp)
    80001634:	6ae2                	ld	s5,24(sp)
    80001636:	6b42                	ld	s6,16(sp)
    80001638:	6ba2                	ld	s7,8(sp)
    8000163a:	6161                	add	sp,sp,80
    8000163c:	8082                	ret
  return 0;
    8000163e:	4501                	li	a0,0
}
    80001640:	8082                	ret

0000000080001642 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001642:	1141                	add	sp,sp,-16
    80001644:	e406                	sd	ra,8(sp)
    80001646:	e022                	sd	s0,0(sp)
    80001648:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000164a:	4601                	li	a2,0
    8000164c:	00000097          	auipc	ra,0x0
    80001650:	96c080e7          	jalr	-1684(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001654:	c901                	beqz	a0,80001664 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001656:	611c                	ld	a5,0(a0)
    80001658:	9bbd                	and	a5,a5,-17
    8000165a:	e11c                	sd	a5,0(a0)
}
    8000165c:	60a2                	ld	ra,8(sp)
    8000165e:	6402                	ld	s0,0(sp)
    80001660:	0141                	add	sp,sp,16
    80001662:	8082                	ret
    panic("uvmclear");
    80001664:	00007517          	auipc	a0,0x7
    80001668:	b6450513          	add	a0,a0,-1180 # 800081c8 <digits+0x188>
    8000166c:	fffff097          	auipc	ra,0xfffff
    80001670:	ed0080e7          	jalr	-304(ra) # 8000053c <panic>

0000000080001674 <uvminvalid>:

// CSE 536: mark a PTE invalid. For swapping 
// pages in and out of memory.
void
uvminvalid(pagetable_t pagetable, uint64 va)
{
    80001674:	1141                	add	sp,sp,-16
    80001676:	e406                	sd	ra,8(sp)
    80001678:	e022                	sd	s0,0(sp)
    8000167a:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000167c:	4601                	li	a2,0
    8000167e:	00000097          	auipc	ra,0x0
    80001682:	93a080e7          	jalr	-1734(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001686:	c901                	beqz	a0,80001696 <uvminvalid+0x22>
    panic("uvminvalid");
  *pte &= ~PTE_V;
    80001688:	611c                	ld	a5,0(a0)
    8000168a:	9bf9                	and	a5,a5,-2
    8000168c:	e11c                	sd	a5,0(a0)
}
    8000168e:	60a2                	ld	ra,8(sp)
    80001690:	6402                	ld	s0,0(sp)
    80001692:	0141                	add	sp,sp,16
    80001694:	8082                	ret
    panic("uvminvalid");
    80001696:	00007517          	auipc	a0,0x7
    8000169a:	b4250513          	add	a0,a0,-1214 # 800081d8 <digits+0x198>
    8000169e:	fffff097          	auipc	ra,0xfffff
    800016a2:	e9e080e7          	jalr	-354(ra) # 8000053c <panic>

00000000800016a6 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016a6:	c6bd                	beqz	a3,80001714 <copyout+0x6e>
{
    800016a8:	715d                	add	sp,sp,-80
    800016aa:	e486                	sd	ra,72(sp)
    800016ac:	e0a2                	sd	s0,64(sp)
    800016ae:	fc26                	sd	s1,56(sp)
    800016b0:	f84a                	sd	s2,48(sp)
    800016b2:	f44e                	sd	s3,40(sp)
    800016b4:	f052                	sd	s4,32(sp)
    800016b6:	ec56                	sd	s5,24(sp)
    800016b8:	e85a                	sd	s6,16(sp)
    800016ba:	e45e                	sd	s7,8(sp)
    800016bc:	e062                	sd	s8,0(sp)
    800016be:	0880                	add	s0,sp,80
    800016c0:	8b2a                	mv	s6,a0
    800016c2:	8c2e                	mv	s8,a1
    800016c4:	8a32                	mv	s4,a2
    800016c6:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016c8:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0){
      return -1;
    }
    n = PGSIZE - (dstva - va0);
    800016ca:	6a85                	lui	s5,0x1
    800016cc:	a015                	j	800016f0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ce:	9562                	add	a0,a0,s8
    800016d0:	0004861b          	sext.w	a2,s1
    800016d4:	85d2                	mv	a1,s4
    800016d6:	41250533          	sub	a0,a0,s2
    800016da:	fffff097          	auipc	ra,0xfffff
    800016de:	650080e7          	jalr	1616(ra) # 80000d2a <memmove>

    len -= n;
    800016e2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016e6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016e8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ec:	02098263          	beqz	s3,80001710 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016f0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016f4:	85ca                	mv	a1,s2
    800016f6:	855a                	mv	a0,s6
    800016f8:	00000097          	auipc	ra,0x0
    800016fc:	966080e7          	jalr	-1690(ra) # 8000105e <walkaddr>
    if (pa0 == 0){
    80001700:	cd01                	beqz	a0,80001718 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80001702:	418904b3          	sub	s1,s2,s8
    80001706:	94d6                	add	s1,s1,s5
    80001708:	fc99f3e3          	bgeu	s3,s1,800016ce <copyout+0x28>
    8000170c:	84ce                	mv	s1,s3
    8000170e:	b7c1                	j	800016ce <copyout+0x28>
  }
  return 0;
    80001710:	4501                	li	a0,0
    80001712:	a021                	j	8000171a <copyout+0x74>
    80001714:	4501                	li	a0,0
}
    80001716:	8082                	ret
      return -1;
    80001718:	557d                	li	a0,-1
}
    8000171a:	60a6                	ld	ra,72(sp)
    8000171c:	6406                	ld	s0,64(sp)
    8000171e:	74e2                	ld	s1,56(sp)
    80001720:	7942                	ld	s2,48(sp)
    80001722:	79a2                	ld	s3,40(sp)
    80001724:	7a02                	ld	s4,32(sp)
    80001726:	6ae2                	ld	s5,24(sp)
    80001728:	6b42                	ld	s6,16(sp)
    8000172a:	6ba2                	ld	s7,8(sp)
    8000172c:	6c02                	ld	s8,0(sp)
    8000172e:	6161                	add	sp,sp,80
    80001730:	8082                	ret

0000000080001732 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001732:	caa5                	beqz	a3,800017a2 <copyin+0x70>
{
    80001734:	715d                	add	sp,sp,-80
    80001736:	e486                	sd	ra,72(sp)
    80001738:	e0a2                	sd	s0,64(sp)
    8000173a:	fc26                	sd	s1,56(sp)
    8000173c:	f84a                	sd	s2,48(sp)
    8000173e:	f44e                	sd	s3,40(sp)
    80001740:	f052                	sd	s4,32(sp)
    80001742:	ec56                	sd	s5,24(sp)
    80001744:	e85a                	sd	s6,16(sp)
    80001746:	e45e                	sd	s7,8(sp)
    80001748:	e062                	sd	s8,0(sp)
    8000174a:	0880                	add	s0,sp,80
    8000174c:	8b2a                	mv	s6,a0
    8000174e:	8a2e                	mv	s4,a1
    80001750:	8c32                	mv	s8,a2
    80001752:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001754:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001756:	6a85                	lui	s5,0x1
    80001758:	a01d                	j	8000177e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000175a:	018505b3          	add	a1,a0,s8
    8000175e:	0004861b          	sext.w	a2,s1
    80001762:	412585b3          	sub	a1,a1,s2
    80001766:	8552                	mv	a0,s4
    80001768:	fffff097          	auipc	ra,0xfffff
    8000176c:	5c2080e7          	jalr	1474(ra) # 80000d2a <memmove>

    len -= n;
    80001770:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001774:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001776:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000177a:	02098263          	beqz	s3,8000179e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000177e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001782:	85ca                	mv	a1,s2
    80001784:	855a                	mv	a0,s6
    80001786:	00000097          	auipc	ra,0x0
    8000178a:	8d8080e7          	jalr	-1832(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000178e:	cd01                	beqz	a0,800017a6 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001790:	418904b3          	sub	s1,s2,s8
    80001794:	94d6                	add	s1,s1,s5
    80001796:	fc99f2e3          	bgeu	s3,s1,8000175a <copyin+0x28>
    8000179a:	84ce                	mv	s1,s3
    8000179c:	bf7d                	j	8000175a <copyin+0x28>
  }
  return 0;
    8000179e:	4501                	li	a0,0
    800017a0:	a021                	j	800017a8 <copyin+0x76>
    800017a2:	4501                	li	a0,0
}
    800017a4:	8082                	ret
      return -1;
    800017a6:	557d                	li	a0,-1
}
    800017a8:	60a6                	ld	ra,72(sp)
    800017aa:	6406                	ld	s0,64(sp)
    800017ac:	74e2                	ld	s1,56(sp)
    800017ae:	7942                	ld	s2,48(sp)
    800017b0:	79a2                	ld	s3,40(sp)
    800017b2:	7a02                	ld	s4,32(sp)
    800017b4:	6ae2                	ld	s5,24(sp)
    800017b6:	6b42                	ld	s6,16(sp)
    800017b8:	6ba2                	ld	s7,8(sp)
    800017ba:	6c02                	ld	s8,0(sp)
    800017bc:	6161                	add	sp,sp,80
    800017be:	8082                	ret

00000000800017c0 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017c0:	c2dd                	beqz	a3,80001866 <copyinstr+0xa6>
{
    800017c2:	715d                	add	sp,sp,-80
    800017c4:	e486                	sd	ra,72(sp)
    800017c6:	e0a2                	sd	s0,64(sp)
    800017c8:	fc26                	sd	s1,56(sp)
    800017ca:	f84a                	sd	s2,48(sp)
    800017cc:	f44e                	sd	s3,40(sp)
    800017ce:	f052                	sd	s4,32(sp)
    800017d0:	ec56                	sd	s5,24(sp)
    800017d2:	e85a                	sd	s6,16(sp)
    800017d4:	e45e                	sd	s7,8(sp)
    800017d6:	0880                	add	s0,sp,80
    800017d8:	8a2a                	mv	s4,a0
    800017da:	8b2e                	mv	s6,a1
    800017dc:	8bb2                	mv	s7,a2
    800017de:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017e0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017e2:	6985                	lui	s3,0x1
    800017e4:	a02d                	j	8000180e <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017e6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017ea:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ec:	37fd                	addw	a5,a5,-1
    800017ee:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017f2:	60a6                	ld	ra,72(sp)
    800017f4:	6406                	ld	s0,64(sp)
    800017f6:	74e2                	ld	s1,56(sp)
    800017f8:	7942                	ld	s2,48(sp)
    800017fa:	79a2                	ld	s3,40(sp)
    800017fc:	7a02                	ld	s4,32(sp)
    800017fe:	6ae2                	ld	s5,24(sp)
    80001800:	6b42                	ld	s6,16(sp)
    80001802:	6ba2                	ld	s7,8(sp)
    80001804:	6161                	add	sp,sp,80
    80001806:	8082                	ret
    srcva = va0 + PGSIZE;
    80001808:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    8000180c:	c8a9                	beqz	s1,8000185e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    8000180e:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    80001812:	85ca                	mv	a1,s2
    80001814:	8552                	mv	a0,s4
    80001816:	00000097          	auipc	ra,0x0
    8000181a:	848080e7          	jalr	-1976(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000181e:	c131                	beqz	a0,80001862 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001820:	417906b3          	sub	a3,s2,s7
    80001824:	96ce                	add	a3,a3,s3
    80001826:	00d4f363          	bgeu	s1,a3,8000182c <copyinstr+0x6c>
    8000182a:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    8000182c:	955e                	add	a0,a0,s7
    8000182e:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80001832:	daf9                	beqz	a3,80001808 <copyinstr+0x48>
    80001834:	87da                	mv	a5,s6
    80001836:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001838:	41650633          	sub	a2,a0,s6
    while(n > 0){
    8000183c:	96da                	add	a3,a3,s6
    8000183e:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001840:	00f60733          	add	a4,a2,a5
    80001844:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fe658c0>
    80001848:	df59                	beqz	a4,800017e6 <copyinstr+0x26>
        *dst = *p;
    8000184a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000184e:	0785                	add	a5,a5,1
    while(n > 0){
    80001850:	fed797e3          	bne	a5,a3,8000183e <copyinstr+0x7e>
    80001854:	14fd                	add	s1,s1,-1
    80001856:	94c2                	add	s1,s1,a6
      --max;
    80001858:	8c8d                	sub	s1,s1,a1
      dst++;
    8000185a:	8b3e                	mv	s6,a5
    8000185c:	b775                	j	80001808 <copyinstr+0x48>
    8000185e:	4781                	li	a5,0
    80001860:	b771                	j	800017ec <copyinstr+0x2c>
      return -1;
    80001862:	557d                	li	a0,-1
    80001864:	b779                	j	800017f2 <copyinstr+0x32>
  int got_null = 0;
    80001866:	4781                	li	a5,0
  if(got_null){
    80001868:	37fd                	addw	a5,a5,-1
    8000186a:	0007851b          	sext.w	a0,a5
}
    8000186e:	8082                	ret

0000000080001870 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001870:	715d                	add	sp,sp,-80
    80001872:	e486                	sd	ra,72(sp)
    80001874:	e0a2                	sd	s0,64(sp)
    80001876:	fc26                	sd	s1,56(sp)
    80001878:	f84a                	sd	s2,48(sp)
    8000187a:	f44e                	sd	s3,40(sp)
    8000187c:	f052                	sd	s4,32(sp)
    8000187e:	ec56                	sd	s5,24(sp)
    80001880:	e85a                	sd	s6,16(sp)
    80001882:	e45e                	sd	s7,8(sp)
    80001884:	0880                	add	s0,sp,80
    80001886:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001888:	00010497          	auipc	s1,0x10
    8000188c:	8e848493          	add	s1,s1,-1816 # 80011170 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001890:	8ba6                	mv	s7,s1
    80001892:	00006b17          	auipc	s6,0x6
    80001896:	76eb0b13          	add	s6,s6,1902 # 80008000 <etext>
    8000189a:	04000937          	lui	s2,0x4000
    8000189e:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    800018a0:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a2:	6999                	lui	s3,0x6
    800018a4:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    800018a8:	0018ca97          	auipc	s5,0x18c
    800018ac:	6c8a8a93          	add	s5,s5,1736 # 8018df70 <tickslock>
    char *pa = kalloc();
    800018b0:	fffff097          	auipc	ra,0xfffff
    800018b4:	232080e7          	jalr	562(ra) # 80000ae2 <kalloc>
    800018b8:	862a                	mv	a2,a0
    if(pa == 0)
    800018ba:	c131                	beqz	a0,800018fe <proc_mapstacks+0x8e>
    uint64 va = KSTACK((int) (p - proc));
    800018bc:	417485b3          	sub	a1,s1,s7
    800018c0:	858d                	sra	a1,a1,0x3
    800018c2:	000b3783          	ld	a5,0(s6)
    800018c6:	02f585b3          	mul	a1,a1,a5
    800018ca:	2585                	addw	a1,a1,1
    800018cc:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018d0:	4719                	li	a4,6
    800018d2:	6685                	lui	a3,0x1
    800018d4:	40b905b3          	sub	a1,s2,a1
    800018d8:	8552                	mv	a0,s4
    800018da:	00000097          	auipc	ra,0x0
    800018de:	866080e7          	jalr	-1946(ra) # 80001140 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018e2:	94ce                	add	s1,s1,s3
    800018e4:	fd5496e3          	bne	s1,s5,800018b0 <proc_mapstacks+0x40>
  }
}
    800018e8:	60a6                	ld	ra,72(sp)
    800018ea:	6406                	ld	s0,64(sp)
    800018ec:	74e2                	ld	s1,56(sp)
    800018ee:	7942                	ld	s2,48(sp)
    800018f0:	79a2                	ld	s3,40(sp)
    800018f2:	7a02                	ld	s4,32(sp)
    800018f4:	6ae2                	ld	s5,24(sp)
    800018f6:	6b42                	ld	s6,16(sp)
    800018f8:	6ba2                	ld	s7,8(sp)
    800018fa:	6161                	add	sp,sp,80
    800018fc:	8082                	ret
      panic("kalloc");
    800018fe:	00007517          	auipc	a0,0x7
    80001902:	8ea50513          	add	a0,a0,-1814 # 800081e8 <digits+0x1a8>
    80001906:	fffff097          	auipc	ra,0xfffff
    8000190a:	c36080e7          	jalr	-970(ra) # 8000053c <panic>

000000008000190e <procinit>:

// initialize the proc table.
void
procinit(void)
{
    8000190e:	715d                	add	sp,sp,-80
    80001910:	e486                	sd	ra,72(sp)
    80001912:	e0a2                	sd	s0,64(sp)
    80001914:	fc26                	sd	s1,56(sp)
    80001916:	f84a                	sd	s2,48(sp)
    80001918:	f44e                	sd	s3,40(sp)
    8000191a:	f052                	sd	s4,32(sp)
    8000191c:	ec56                	sd	s5,24(sp)
    8000191e:	e85a                	sd	s6,16(sp)
    80001920:	e45e                	sd	s7,8(sp)
    80001922:	0880                	add	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001924:	00007597          	auipc	a1,0x7
    80001928:	8cc58593          	add	a1,a1,-1844 # 800081f0 <digits+0x1b0>
    8000192c:	0000f517          	auipc	a0,0xf
    80001930:	41450513          	add	a0,a0,1044 # 80010d40 <pid_lock>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	20e080e7          	jalr	526(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000193c:	00007597          	auipc	a1,0x7
    80001940:	8bc58593          	add	a1,a1,-1860 # 800081f8 <digits+0x1b8>
    80001944:	0000f517          	auipc	a0,0xf
    80001948:	41450513          	add	a0,a0,1044 # 80010d58 <wait_lock>
    8000194c:	fffff097          	auipc	ra,0xfffff
    80001950:	1f6080e7          	jalr	502(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001954:	00010497          	auipc	s1,0x10
    80001958:	81c48493          	add	s1,s1,-2020 # 80011170 <proc>
      initlock(&p->lock, "proc");
    8000195c:	00007b97          	auipc	s7,0x7
    80001960:	8acb8b93          	add	s7,s7,-1876 # 80008208 <digits+0x1c8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001964:	8b26                	mv	s6,s1
    80001966:	00006a97          	auipc	s5,0x6
    8000196a:	69aa8a93          	add	s5,s5,1690 # 80008000 <etext>
    8000196e:	04000937          	lui	s2,0x4000
    80001972:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001974:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001976:	6999                	lui	s3,0x6
    80001978:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000197c:	0018ca17          	auipc	s4,0x18c
    80001980:	5f4a0a13          	add	s4,s4,1524 # 8018df70 <tickslock>
      initlock(&p->lock, "proc");
    80001984:	85de                	mv	a1,s7
    80001986:	8526                	mv	a0,s1
    80001988:	fffff097          	auipc	ra,0xfffff
    8000198c:	1ba080e7          	jalr	442(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001990:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001994:	416487b3          	sub	a5,s1,s6
    80001998:	878d                	sra	a5,a5,0x3
    8000199a:	000ab703          	ld	a4,0(s5)
    8000199e:	02e787b3          	mul	a5,a5,a4
    800019a2:	2785                	addw	a5,a5,1
    800019a4:	00d7979b          	sllw	a5,a5,0xd
    800019a8:	40f907b3          	sub	a5,s2,a5
    800019ac:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    800019ae:	94ce                	add	s1,s1,s3
    800019b0:	fd449ae3          	bne	s1,s4,80001984 <procinit+0x76>
  }
}
    800019b4:	60a6                	ld	ra,72(sp)
    800019b6:	6406                	ld	s0,64(sp)
    800019b8:	74e2                	ld	s1,56(sp)
    800019ba:	7942                	ld	s2,48(sp)
    800019bc:	79a2                	ld	s3,40(sp)
    800019be:	7a02                	ld	s4,32(sp)
    800019c0:	6ae2                	ld	s5,24(sp)
    800019c2:	6b42                	ld	s6,16(sp)
    800019c4:	6ba2                	ld	s7,8(sp)
    800019c6:	6161                	add	sp,sp,80
    800019c8:	8082                	ret

00000000800019ca <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019ca:	1141                	add	sp,sp,-16
    800019cc:	e422                	sd	s0,8(sp)
    800019ce:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019d0:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019d2:	2501                	sext.w	a0,a0
    800019d4:	6422                	ld	s0,8(sp)
    800019d6:	0141                	add	sp,sp,16
    800019d8:	8082                	ret

00000000800019da <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019da:	1141                	add	sp,sp,-16
    800019dc:	e422                	sd	s0,8(sp)
    800019de:	0800                	add	s0,sp,16
    800019e0:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019e2:	2781                	sext.w	a5,a5
    800019e4:	079e                	sll	a5,a5,0x7
  return c;
}
    800019e6:	0000f517          	auipc	a0,0xf
    800019ea:	38a50513          	add	a0,a0,906 # 80010d70 <cpus>
    800019ee:	953e                	add	a0,a0,a5
    800019f0:	6422                	ld	s0,8(sp)
    800019f2:	0141                	add	sp,sp,16
    800019f4:	8082                	ret

00000000800019f6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019f6:	1101                	add	sp,sp,-32
    800019f8:	ec06                	sd	ra,24(sp)
    800019fa:	e822                	sd	s0,16(sp)
    800019fc:	e426                	sd	s1,8(sp)
    800019fe:	1000                	add	s0,sp,32
  push_off();
    80001a00:	fffff097          	auipc	ra,0xfffff
    80001a04:	186080e7          	jalr	390(ra) # 80000b86 <push_off>
    80001a08:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001a0a:	2781                	sext.w	a5,a5
    80001a0c:	079e                	sll	a5,a5,0x7
    80001a0e:	0000f717          	auipc	a4,0xf
    80001a12:	33270713          	add	a4,a4,818 # 80010d40 <pid_lock>
    80001a16:	97ba                	add	a5,a5,a4
    80001a18:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a1a:	fffff097          	auipc	ra,0xfffff
    80001a1e:	20c080e7          	jalr	524(ra) # 80000c26 <pop_off>
  return p;
}
    80001a22:	8526                	mv	a0,s1
    80001a24:	60e2                	ld	ra,24(sp)
    80001a26:	6442                	ld	s0,16(sp)
    80001a28:	64a2                	ld	s1,8(sp)
    80001a2a:	6105                	add	sp,sp,32
    80001a2c:	8082                	ret

0000000080001a2e <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a2e:	1141                	add	sp,sp,-16
    80001a30:	e406                	sd	ra,8(sp)
    80001a32:	e022                	sd	s0,0(sp)
    80001a34:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a36:	00000097          	auipc	ra,0x0
    80001a3a:	fc0080e7          	jalr	-64(ra) # 800019f6 <myproc>
    80001a3e:	fffff097          	auipc	ra,0xfffff
    80001a42:	248080e7          	jalr	584(ra) # 80000c86 <release>

  if (first) {
    80001a46:	00007797          	auipc	a5,0x7
    80001a4a:	00a7a783          	lw	a5,10(a5) # 80008a50 <first.1>
    80001a4e:	eb89                	bnez	a5,80001a60 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a50:	00001097          	auipc	ra,0x1
    80001a54:	d66080e7          	jalr	-666(ra) # 800027b6 <usertrapret>
}
    80001a58:	60a2                	ld	ra,8(sp)
    80001a5a:	6402                	ld	s0,0(sp)
    80001a5c:	0141                	add	sp,sp,16
    80001a5e:	8082                	ret
    first = 0;
    80001a60:	00007797          	auipc	a5,0x7
    80001a64:	fe07a823          	sw	zero,-16(a5) # 80008a50 <first.1>
    fsinit(ROOTDEV);
    80001a68:	4505                	li	a0,1
    80001a6a:	00002097          	auipc	ra,0x2
    80001a6e:	ae6080e7          	jalr	-1306(ra) # 80003550 <fsinit>
    80001a72:	bff9                	j	80001a50 <forkret+0x22>

0000000080001a74 <allocpid>:
{
    80001a74:	1101                	add	sp,sp,-32
    80001a76:	ec06                	sd	ra,24(sp)
    80001a78:	e822                	sd	s0,16(sp)
    80001a7a:	e426                	sd	s1,8(sp)
    80001a7c:	e04a                	sd	s2,0(sp)
    80001a7e:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a80:	0000f917          	auipc	s2,0xf
    80001a84:	2c090913          	add	s2,s2,704 # 80010d40 <pid_lock>
    80001a88:	854a                	mv	a0,s2
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	148080e7          	jalr	328(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a92:	00007797          	auipc	a5,0x7
    80001a96:	fc278793          	add	a5,a5,-62 # 80008a54 <nextpid>
    80001a9a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a9c:	0014871b          	addw	a4,s1,1
    80001aa0:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001aa2:	854a                	mv	a0,s2
    80001aa4:	fffff097          	auipc	ra,0xfffff
    80001aa8:	1e2080e7          	jalr	482(ra) # 80000c86 <release>
}
    80001aac:	8526                	mv	a0,s1
    80001aae:	60e2                	ld	ra,24(sp)
    80001ab0:	6442                	ld	s0,16(sp)
    80001ab2:	64a2                	ld	s1,8(sp)
    80001ab4:	6902                	ld	s2,0(sp)
    80001ab6:	6105                	add	sp,sp,32
    80001ab8:	8082                	ret

0000000080001aba <proc_pagetable>:
{
    80001aba:	1101                	add	sp,sp,-32
    80001abc:	ec06                	sd	ra,24(sp)
    80001abe:	e822                	sd	s0,16(sp)
    80001ac0:	e426                	sd	s1,8(sp)
    80001ac2:	e04a                	sd	s2,0(sp)
    80001ac4:	1000                	add	s0,sp,32
    80001ac6:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ac8:	00000097          	auipc	ra,0x0
    80001acc:	854080e7          	jalr	-1964(ra) # 8000131c <uvmcreate>
    80001ad0:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001ad2:	c121                	beqz	a0,80001b12 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ad4:	4729                	li	a4,10
    80001ad6:	00005697          	auipc	a3,0x5
    80001ada:	52a68693          	add	a3,a3,1322 # 80007000 <_trampoline>
    80001ade:	6605                	lui	a2,0x1
    80001ae0:	040005b7          	lui	a1,0x4000
    80001ae4:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ae6:	05b2                	sll	a1,a1,0xc
    80001ae8:	fffff097          	auipc	ra,0xfffff
    80001aec:	5b8080e7          	jalr	1464(ra) # 800010a0 <mappages>
    80001af0:	02054863          	bltz	a0,80001b20 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001af4:	4719                	li	a4,6
    80001af6:	05893683          	ld	a3,88(s2)
    80001afa:	6605                	lui	a2,0x1
    80001afc:	020005b7          	lui	a1,0x2000
    80001b00:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b02:	05b6                	sll	a1,a1,0xd
    80001b04:	8526                	mv	a0,s1
    80001b06:	fffff097          	auipc	ra,0xfffff
    80001b0a:	59a080e7          	jalr	1434(ra) # 800010a0 <mappages>
    80001b0e:	02054163          	bltz	a0,80001b30 <proc_pagetable+0x76>
}
    80001b12:	8526                	mv	a0,s1
    80001b14:	60e2                	ld	ra,24(sp)
    80001b16:	6442                	ld	s0,16(sp)
    80001b18:	64a2                	ld	s1,8(sp)
    80001b1a:	6902                	ld	s2,0(sp)
    80001b1c:	6105                	add	sp,sp,32
    80001b1e:	8082                	ret
    uvmfree(pagetable, 0);
    80001b20:	4581                	li	a1,0
    80001b22:	8526                	mv	a0,s1
    80001b24:	00000097          	auipc	ra,0x0
    80001b28:	a12080e7          	jalr	-1518(ra) # 80001536 <uvmfree>
    return 0;
    80001b2c:	4481                	li	s1,0
    80001b2e:	b7d5                	j	80001b12 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b30:	4681                	li	a3,0
    80001b32:	4605                	li	a2,1
    80001b34:	040005b7          	lui	a1,0x4000
    80001b38:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b3a:	05b2                	sll	a1,a1,0xc
    80001b3c:	8526                	mv	a0,s1
    80001b3e:	fffff097          	auipc	ra,0xfffff
    80001b42:	728080e7          	jalr	1832(ra) # 80001266 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b46:	4581                	li	a1,0
    80001b48:	8526                	mv	a0,s1
    80001b4a:	00000097          	auipc	ra,0x0
    80001b4e:	9ec080e7          	jalr	-1556(ra) # 80001536 <uvmfree>
    return 0;
    80001b52:	4481                	li	s1,0
    80001b54:	bf7d                	j	80001b12 <proc_pagetable+0x58>

0000000080001b56 <proc_freepagetable>:
{
    80001b56:	1101                	add	sp,sp,-32
    80001b58:	ec06                	sd	ra,24(sp)
    80001b5a:	e822                	sd	s0,16(sp)
    80001b5c:	e426                	sd	s1,8(sp)
    80001b5e:	e04a                	sd	s2,0(sp)
    80001b60:	1000                	add	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
    80001b64:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b66:	4681                	li	a3,0
    80001b68:	4605                	li	a2,1
    80001b6a:	040005b7          	lui	a1,0x4000
    80001b6e:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b70:	05b2                	sll	a1,a1,0xc
    80001b72:	fffff097          	auipc	ra,0xfffff
    80001b76:	6f4080e7          	jalr	1780(ra) # 80001266 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b7a:	4681                	li	a3,0
    80001b7c:	4605                	li	a2,1
    80001b7e:	020005b7          	lui	a1,0x2000
    80001b82:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b84:	05b6                	sll	a1,a1,0xd
    80001b86:	8526                	mv	a0,s1
    80001b88:	fffff097          	auipc	ra,0xfffff
    80001b8c:	6de080e7          	jalr	1758(ra) # 80001266 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b90:	85ca                	mv	a1,s2
    80001b92:	8526                	mv	a0,s1
    80001b94:	00000097          	auipc	ra,0x0
    80001b98:	9a2080e7          	jalr	-1630(ra) # 80001536 <uvmfree>
}
    80001b9c:	60e2                	ld	ra,24(sp)
    80001b9e:	6442                	ld	s0,16(sp)
    80001ba0:	64a2                	ld	s1,8(sp)
    80001ba2:	6902                	ld	s2,0(sp)
    80001ba4:	6105                	add	sp,sp,32
    80001ba6:	8082                	ret

0000000080001ba8 <freeproc>:
{
    80001ba8:	1101                	add	sp,sp,-32
    80001baa:	ec06                	sd	ra,24(sp)
    80001bac:	e822                	sd	s0,16(sp)
    80001bae:	e426                	sd	s1,8(sp)
    80001bb0:	1000                	add	s0,sp,32
    80001bb2:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001bb4:	6d28                	ld	a0,88(a0)
    80001bb6:	c509                	beqz	a0,80001bc0 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001bb8:	fffff097          	auipc	ra,0xfffff
    80001bbc:	e2c080e7          	jalr	-468(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001bc0:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bc4:	68a8                	ld	a0,80(s1)
    80001bc6:	c511                	beqz	a0,80001bd2 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bc8:	64ac                	ld	a1,72(s1)
    80001bca:	00000097          	auipc	ra,0x0
    80001bce:	f8c080e7          	jalr	-116(ra) # 80001b56 <proc_freepagetable>
  p->pagetable = 0;
    80001bd2:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bd6:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bda:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bde:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001be2:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001be6:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bea:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bee:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bf2:	0004ac23          	sw	zero,24(s1)
}
    80001bf6:	60e2                	ld	ra,24(sp)
    80001bf8:	6442                	ld	s0,16(sp)
    80001bfa:	64a2                	ld	s1,8(sp)
    80001bfc:	6105                	add	sp,sp,32
    80001bfe:	8082                	ret

0000000080001c00 <allocproc>:
{
    80001c00:	7179                	add	sp,sp,-48
    80001c02:	f406                	sd	ra,40(sp)
    80001c04:	f022                	sd	s0,32(sp)
    80001c06:	ec26                	sd	s1,24(sp)
    80001c08:	e84a                	sd	s2,16(sp)
    80001c0a:	e44e                	sd	s3,8(sp)
    80001c0c:	1800                	add	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c0e:	0000f497          	auipc	s1,0xf
    80001c12:	56248493          	add	s1,s1,1378 # 80011170 <proc>
    80001c16:	6919                	lui	s2,0x6
    80001c18:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80001c1c:	0018c997          	auipc	s3,0x18c
    80001c20:	35498993          	add	s3,s3,852 # 8018df70 <tickslock>
    acquire(&p->lock);
    80001c24:	8526                	mv	a0,s1
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	fac080e7          	jalr	-84(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001c2e:	4c9c                	lw	a5,24(s1)
    80001c30:	cb99                	beqz	a5,80001c46 <allocproc+0x46>
      release(&p->lock);
    80001c32:	8526                	mv	a0,s1
    80001c34:	fffff097          	auipc	ra,0xfffff
    80001c38:	052080e7          	jalr	82(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c3c:	94ca                	add	s1,s1,s2
    80001c3e:	ff3493e3          	bne	s1,s3,80001c24 <allocproc+0x24>
  return 0;
    80001c42:	4481                	li	s1,0
    80001c44:	a889                	j	80001c96 <allocproc+0x96>
  p->pid = allocpid();
    80001c46:	00000097          	auipc	ra,0x0
    80001c4a:	e2e080e7          	jalr	-466(ra) # 80001a74 <allocpid>
    80001c4e:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c50:	4785                	li	a5,1
    80001c52:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c54:	fffff097          	auipc	ra,0xfffff
    80001c58:	e8e080e7          	jalr	-370(ra) # 80000ae2 <kalloc>
    80001c5c:	892a                	mv	s2,a0
    80001c5e:	eca8                	sd	a0,88(s1)
    80001c60:	c139                	beqz	a0,80001ca6 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001c62:	8526                	mv	a0,s1
    80001c64:	00000097          	auipc	ra,0x0
    80001c68:	e56080e7          	jalr	-426(ra) # 80001aba <proc_pagetable>
    80001c6c:	892a                	mv	s2,a0
    80001c6e:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c70:	c539                	beqz	a0,80001cbe <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001c72:	07000613          	li	a2,112
    80001c76:	4581                	li	a1,0
    80001c78:	06048513          	add	a0,s1,96
    80001c7c:	fffff097          	auipc	ra,0xfffff
    80001c80:	052080e7          	jalr	82(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c84:	00000797          	auipc	a5,0x0
    80001c88:	daa78793          	add	a5,a5,-598 # 80001a2e <forkret>
    80001c8c:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c8e:	60bc                	ld	a5,64(s1)
    80001c90:	6705                	lui	a4,0x1
    80001c92:	97ba                	add	a5,a5,a4
    80001c94:	f4bc                	sd	a5,104(s1)
}
    80001c96:	8526                	mv	a0,s1
    80001c98:	70a2                	ld	ra,40(sp)
    80001c9a:	7402                	ld	s0,32(sp)
    80001c9c:	64e2                	ld	s1,24(sp)
    80001c9e:	6942                	ld	s2,16(sp)
    80001ca0:	69a2                	ld	s3,8(sp)
    80001ca2:	6145                	add	sp,sp,48
    80001ca4:	8082                	ret
    freeproc(p);
    80001ca6:	8526                	mv	a0,s1
    80001ca8:	00000097          	auipc	ra,0x0
    80001cac:	f00080e7          	jalr	-256(ra) # 80001ba8 <freeproc>
    release(&p->lock);
    80001cb0:	8526                	mv	a0,s1
    80001cb2:	fffff097          	auipc	ra,0xfffff
    80001cb6:	fd4080e7          	jalr	-44(ra) # 80000c86 <release>
    return 0;
    80001cba:	84ca                	mv	s1,s2
    80001cbc:	bfe9                	j	80001c96 <allocproc+0x96>
    freeproc(p);
    80001cbe:	8526                	mv	a0,s1
    80001cc0:	00000097          	auipc	ra,0x0
    80001cc4:	ee8080e7          	jalr	-280(ra) # 80001ba8 <freeproc>
    release(&p->lock);
    80001cc8:	8526                	mv	a0,s1
    80001cca:	fffff097          	auipc	ra,0xfffff
    80001cce:	fbc080e7          	jalr	-68(ra) # 80000c86 <release>
    return 0;
    80001cd2:	84ca                	mv	s1,s2
    80001cd4:	b7c9                	j	80001c96 <allocproc+0x96>

0000000080001cd6 <userinit>:
{
    80001cd6:	1101                	add	sp,sp,-32
    80001cd8:	ec06                	sd	ra,24(sp)
    80001cda:	e822                	sd	s0,16(sp)
    80001cdc:	e426                	sd	s1,8(sp)
    80001cde:	1000                	add	s0,sp,32
  p = allocproc();
    80001ce0:	00000097          	auipc	ra,0x0
    80001ce4:	f20080e7          	jalr	-224(ra) # 80001c00 <allocproc>
    80001ce8:	84aa                	mv	s1,a0
  initproc = p;
    80001cea:	00007797          	auipc	a5,0x7
    80001cee:	dca7bf23          	sd	a0,-546(a5) # 80008ac8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cf2:	03400613          	li	a2,52
    80001cf6:	00007597          	auipc	a1,0x7
    80001cfa:	d6a58593          	add	a1,a1,-662 # 80008a60 <initcode>
    80001cfe:	6928                	ld	a0,80(a0)
    80001d00:	fffff097          	auipc	ra,0xfffff
    80001d04:	64a080e7          	jalr	1610(ra) # 8000134a <uvmfirst>
  p->sz = PGSIZE;
    80001d08:	6785                	lui	a5,0x1
    80001d0a:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001d0c:	6cb8                	ld	a4,88(s1)
    80001d0e:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001d12:	6cb8                	ld	a4,88(s1)
    80001d14:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d16:	4641                	li	a2,16
    80001d18:	00006597          	auipc	a1,0x6
    80001d1c:	4f858593          	add	a1,a1,1272 # 80008210 <digits+0x1d0>
    80001d20:	15848513          	add	a0,s1,344
    80001d24:	fffff097          	auipc	ra,0xfffff
    80001d28:	0f2080e7          	jalr	242(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d2c:	00006517          	auipc	a0,0x6
    80001d30:	4f450513          	add	a0,a0,1268 # 80008220 <digits+0x1e0>
    80001d34:	00002097          	auipc	ra,0x2
    80001d38:	23a080e7          	jalr	570(ra) # 80003f6e <namei>
    80001d3c:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d40:	478d                	li	a5,3
    80001d42:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d44:	8526                	mv	a0,s1
    80001d46:	fffff097          	auipc	ra,0xfffff
    80001d4a:	f40080e7          	jalr	-192(ra) # 80000c86 <release>
}
    80001d4e:	60e2                	ld	ra,24(sp)
    80001d50:	6442                	ld	s0,16(sp)
    80001d52:	64a2                	ld	s1,8(sp)
    80001d54:	6105                	add	sp,sp,32
    80001d56:	8082                	ret

0000000080001d58 <track_heap>:
  for (int i = 0; i < MAXHEAP; i++) {
    80001d58:	17050793          	add	a5,a0,368
    80001d5c:	6719                	lui	a4,0x6
    80001d5e:	f3070713          	add	a4,a4,-208 # 5f30 <_entry-0x7fffa0d0>
    80001d62:	953a                	add	a0,a0,a4
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d64:	56fd                	li	a3,-1
  for (int i = 0; i < MAXHEAP; i++) {
    80001d66:	6805                	lui	a6,0x1
    80001d68:	a029                	j	80001d72 <track_heap+0x1a>
    80001d6a:	07e1                	add	a5,a5,24 # 1018 <_entry-0x7fffefe8>
    80001d6c:	95c2                	add	a1,a1,a6
    80001d6e:	00a78c63          	beq	a5,a0,80001d86 <track_heap+0x2e>
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d72:	6398                	ld	a4,0(a5)
    80001d74:	fed71be3          	bne	a4,a3,80001d6a <track_heap+0x12>
      p->heap_tracker[i].addr           = start + (i*PGSIZE);
    80001d78:	e38c                	sd	a1,0(a5)
      p->heap_tracker[i].loaded         = 0;   
    80001d7a:	00078823          	sb	zero,16(a5)
      p->heap_tracker[i].startblock     = -1;
    80001d7e:	cbd4                	sw	a3,20(a5)
      npages--;
    80001d80:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
      if (npages == 0) return;
    80001d82:	f665                	bnez	a2,80001d6a <track_heap+0x12>
    80001d84:	8082                	ret
void track_heap(struct proc* p, uint64 start, int npages) {
    80001d86:	1141                	add	sp,sp,-16
    80001d88:	e406                	sd	ra,8(sp)
    80001d8a:	e022                	sd	s0,0(sp)
    80001d8c:	0800                	add	s0,sp,16
  panic("Error: No more process heap pages allowed.\n");
    80001d8e:	00006517          	auipc	a0,0x6
    80001d92:	49a50513          	add	a0,a0,1178 # 80008228 <digits+0x1e8>
    80001d96:	ffffe097          	auipc	ra,0xffffe
    80001d9a:	7a6080e7          	jalr	1958(ra) # 8000053c <panic>

0000000080001d9e <growproc>:
{
    80001d9e:	7179                	add	sp,sp,-48
    80001da0:	f406                	sd	ra,40(sp)
    80001da2:	f022                	sd	s0,32(sp)
    80001da4:	ec26                	sd	s1,24(sp)
    80001da6:	e84a                	sd	s2,16(sp)
    80001da8:	e44e                	sd	s3,8(sp)
    80001daa:	1800                	add	s0,sp,48
    80001dac:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80001dae:	00000097          	auipc	ra,0x0
    80001db2:	c48080e7          	jalr	-952(ra) # 800019f6 <myproc>
    80001db6:	84aa                	mv	s1,a0
  if (strncmp(p->name, "/init", 5) == 0 || strncmp(p->name, "sh", 2) == 0) {
    80001db8:	15850913          	add	s2,a0,344
    80001dbc:	4615                	li	a2,5
    80001dbe:	00006597          	auipc	a1,0x6
    80001dc2:	49a58593          	add	a1,a1,1178 # 80008258 <digits+0x218>
    80001dc6:	854a                	mv	a0,s2
    80001dc8:	fffff097          	auipc	ra,0xfffff
    80001dcc:	fd6080e7          	jalr	-42(ra) # 80000d9e <strncmp>
    80001dd0:	e51d                	bnez	a0,80001dfe <growproc+0x60>
    80001dd2:	16048423          	sb	zero,360(s1)
  n = PGROUNDUP(n);
    80001dd6:	6605                	lui	a2,0x1
    80001dd8:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001dda:	0136063b          	addw	a2,a2,s3
    80001dde:	77fd                	lui	a5,0xfffff
    80001de0:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001de2:	64ac                	ld	a1,72(s1)
  if(n > 0){
    80001de4:	08c04163          	bgtz	a2,80001e66 <growproc+0xc8>
  } else if(n < 0){
    80001de8:	08064a63          	bltz	a2,80001e7c <growproc+0xde>
  p->sz = sz;
    80001dec:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dee:	4501                	li	a0,0
}
    80001df0:	70a2                	ld	ra,40(sp)
    80001df2:	7402                	ld	s0,32(sp)
    80001df4:	64e2                	ld	s1,24(sp)
    80001df6:	6942                	ld	s2,16(sp)
    80001df8:	69a2                	ld	s3,8(sp)
    80001dfa:	6145                	add	sp,sp,48
    80001dfc:	8082                	ret
  if (strncmp(p->name, "/init", 5) == 0 || strncmp(p->name, "sh", 2) == 0) {
    80001dfe:	4609                	li	a2,2
    80001e00:	00006597          	auipc	a1,0x6
    80001e04:	46058593          	add	a1,a1,1120 # 80008260 <digits+0x220>
    80001e08:	854a                	mv	a0,s2
    80001e0a:	fffff097          	auipc	ra,0xfffff
    80001e0e:	f94080e7          	jalr	-108(ra) # 80000d9e <strncmp>
    80001e12:	00a037b3          	snez	a5,a0
    80001e16:	16f48423          	sb	a5,360(s1)
  n = PGROUNDUP(n);
    80001e1a:	6605                	lui	a2,0x1
    80001e1c:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001e1e:	0136063b          	addw	a2,a2,s3
    80001e22:	77fd                	lui	a5,0xfffff
    80001e24:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001e26:	64ac                	ld	a1,72(s1)
  if (p->ondemand) {
    80001e28:	dd55                	beqz	a0,80001de4 <growproc+0x46>
    sz = PGROUNDUP(sz);
    80001e2a:	6785                	lui	a5,0x1
    80001e2c:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001e2e:	95be                	add	a1,a1,a5
    80001e30:	77fd                	lui	a5,0xfffff
    80001e32:	8dfd                	and	a1,a1,a5
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e34:	00b607b3          	add	a5,a2,a1
    80001e38:	02f5f563          	bgeu	a1,a5,80001e62 <growproc+0xc4>
    80001e3c:	17048513          	add	a0,s1,368
    80001e40:	872e                	mv	a4,a1
    80001e42:	4601                	li	a2,0
    80001e44:	6685                	lui	a3,0x1
      p->heap_tracker[i].addr = addr;
    80001e46:	e118                	sd	a4,0(a0)
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e48:	0605                	add	a2,a2,1
    80001e4a:	9736                	add	a4,a4,a3
    80001e4c:	0561                	add	a0,a0,24
    80001e4e:	fef76ce3          	bltu	a4,a5,80001e46 <growproc+0xa8>
  print_skip_heap_region(p->name, sz, i);
    80001e52:	2601                	sext.w	a2,a2
    80001e54:	854a                	mv	a0,s2
    80001e56:	00005097          	auipc	ra,0x5
    80001e5a:	974080e7          	jalr	-1676(ra) # 800067ca <print_skip_heap_region>
  return 0;
    80001e5e:	4501                	li	a0,0
    80001e60:	bf41                	j	80001df0 <growproc+0x52>
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e62:	4601                	li	a2,0
    80001e64:	b7fd                	j	80001e52 <growproc+0xb4>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e66:	4691                	li	a3,4
    80001e68:	962e                	add	a2,a2,a1
    80001e6a:	68a8                	ld	a0,80(s1)
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	598080e7          	jalr	1432(ra) # 80001404 <uvmalloc>
    80001e74:	85aa                	mv	a1,a0
    80001e76:	f93d                	bnez	a0,80001dec <growproc+0x4e>
      return -1;
    80001e78:	557d                	li	a0,-1
    80001e7a:	bf9d                	j	80001df0 <growproc+0x52>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e7c:	962e                	add	a2,a2,a1
    80001e7e:	68a8                	ld	a0,80(s1)
    80001e80:	fffff097          	auipc	ra,0xfffff
    80001e84:	53c080e7          	jalr	1340(ra) # 800013bc <uvmdealloc>
    80001e88:	85aa                	mv	a1,a0
    80001e8a:	b78d                	j	80001dec <growproc+0x4e>

0000000080001e8c <fork>:
{
    80001e8c:	7139                	add	sp,sp,-64
    80001e8e:	fc06                	sd	ra,56(sp)
    80001e90:	f822                	sd	s0,48(sp)
    80001e92:	f426                	sd	s1,40(sp)
    80001e94:	f04a                	sd	s2,32(sp)
    80001e96:	ec4e                	sd	s3,24(sp)
    80001e98:	e852                	sd	s4,16(sp)
    80001e9a:	e456                	sd	s5,8(sp)
    80001e9c:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e9e:	00000097          	auipc	ra,0x0
    80001ea2:	b58080e7          	jalr	-1192(ra) # 800019f6 <myproc>
    80001ea6:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ea8:	00000097          	auipc	ra,0x0
    80001eac:	d58080e7          	jalr	-680(ra) # 80001c00 <allocproc>
    80001eb0:	12050063          	beqz	a0,80001fd0 <fork+0x144>
    80001eb4:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eb6:	048ab603          	ld	a2,72(s5)
    80001eba:	692c                	ld	a1,80(a0)
    80001ebc:	050ab503          	ld	a0,80(s5)
    80001ec0:	fffff097          	auipc	ra,0xfffff
    80001ec4:	6b0080e7          	jalr	1712(ra) # 80001570 <uvmcopy>
    80001ec8:	04054863          	bltz	a0,80001f18 <fork+0x8c>
  np->sz = p->sz;
    80001ecc:	048ab783          	ld	a5,72(s5)
    80001ed0:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ed4:	058ab683          	ld	a3,88(s5)
    80001ed8:	87b6                	mv	a5,a3
    80001eda:	0589b703          	ld	a4,88(s3)
    80001ede:	12068693          	add	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80001ee2:	0007b803          	ld	a6,0(a5) # fffffffffffff000 <end+0xffffffff7fe658c0>
    80001ee6:	6788                	ld	a0,8(a5)
    80001ee8:	6b8c                	ld	a1,16(a5)
    80001eea:	6f90                	ld	a2,24(a5)
    80001eec:	01073023          	sd	a6,0(a4)
    80001ef0:	e708                	sd	a0,8(a4)
    80001ef2:	eb0c                	sd	a1,16(a4)
    80001ef4:	ef10                	sd	a2,24(a4)
    80001ef6:	02078793          	add	a5,a5,32
    80001efa:	02070713          	add	a4,a4,32
    80001efe:	fed792e3          	bne	a5,a3,80001ee2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f02:	0589b783          	ld	a5,88(s3)
    80001f06:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f0a:	0d0a8493          	add	s1,s5,208
    80001f0e:	0d098913          	add	s2,s3,208
    80001f12:	150a8a13          	add	s4,s5,336
    80001f16:	a00d                	j	80001f38 <fork+0xac>
    freeproc(np);
    80001f18:	854e                	mv	a0,s3
    80001f1a:	00000097          	auipc	ra,0x0
    80001f1e:	c8e080e7          	jalr	-882(ra) # 80001ba8 <freeproc>
    release(&np->lock);
    80001f22:	854e                	mv	a0,s3
    80001f24:	fffff097          	auipc	ra,0xfffff
    80001f28:	d62080e7          	jalr	-670(ra) # 80000c86 <release>
    return -1;
    80001f2c:	597d                	li	s2,-1
    80001f2e:	a079                	j	80001fbc <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f30:	04a1                	add	s1,s1,8
    80001f32:	0921                	add	s2,s2,8
    80001f34:	01448b63          	beq	s1,s4,80001f4a <fork+0xbe>
    if(p->ofile[i])
    80001f38:	6088                	ld	a0,0(s1)
    80001f3a:	d97d                	beqz	a0,80001f30 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f3c:	00002097          	auipc	ra,0x2
    80001f40:	6a4080e7          	jalr	1700(ra) # 800045e0 <filedup>
    80001f44:	00a93023          	sd	a0,0(s2)
    80001f48:	b7e5                	j	80001f30 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001f4a:	150ab503          	ld	a0,336(s5)
    80001f4e:	00002097          	auipc	ra,0x2
    80001f52:	83c080e7          	jalr	-1988(ra) # 8000378a <idup>
    80001f56:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f5a:	4641                	li	a2,16
    80001f5c:	158a8593          	add	a1,s5,344
    80001f60:	15898513          	add	a0,s3,344
    80001f64:	fffff097          	auipc	ra,0xfffff
    80001f68:	eb2080e7          	jalr	-334(ra) # 80000e16 <safestrcpy>
  np->ondemand = p->ondemand;
    80001f6c:	168ac783          	lbu	a5,360(s5)
    80001f70:	16f98423          	sb	a5,360(s3)
  pid = np->pid;
    80001f74:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f78:	854e                	mv	a0,s3
    80001f7a:	fffff097          	auipc	ra,0xfffff
    80001f7e:	d0c080e7          	jalr	-756(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001f82:	0000f497          	auipc	s1,0xf
    80001f86:	dd648493          	add	s1,s1,-554 # 80010d58 <wait_lock>
    80001f8a:	8526                	mv	a0,s1
    80001f8c:	fffff097          	auipc	ra,0xfffff
    80001f90:	c46080e7          	jalr	-954(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f94:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f98:	8526                	mv	a0,s1
    80001f9a:	fffff097          	auipc	ra,0xfffff
    80001f9e:	cec080e7          	jalr	-788(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001fa2:	854e                	mv	a0,s3
    80001fa4:	fffff097          	auipc	ra,0xfffff
    80001fa8:	c2e080e7          	jalr	-978(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001fac:	478d                	li	a5,3
    80001fae:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001fb2:	854e                	mv	a0,s3
    80001fb4:	fffff097          	auipc	ra,0xfffff
    80001fb8:	cd2080e7          	jalr	-814(ra) # 80000c86 <release>
}
    80001fbc:	854a                	mv	a0,s2
    80001fbe:	70e2                	ld	ra,56(sp)
    80001fc0:	7442                	ld	s0,48(sp)
    80001fc2:	74a2                	ld	s1,40(sp)
    80001fc4:	7902                	ld	s2,32(sp)
    80001fc6:	69e2                	ld	s3,24(sp)
    80001fc8:	6a42                	ld	s4,16(sp)
    80001fca:	6aa2                	ld	s5,8(sp)
    80001fcc:	6121                	add	sp,sp,64
    80001fce:	8082                	ret
    return -1;
    80001fd0:	597d                	li	s2,-1
    80001fd2:	b7ed                	j	80001fbc <fork+0x130>

0000000080001fd4 <scheduler>:
{
    80001fd4:	715d                	add	sp,sp,-80
    80001fd6:	e486                	sd	ra,72(sp)
    80001fd8:	e0a2                	sd	s0,64(sp)
    80001fda:	fc26                	sd	s1,56(sp)
    80001fdc:	f84a                	sd	s2,48(sp)
    80001fde:	f44e                	sd	s3,40(sp)
    80001fe0:	f052                	sd	s4,32(sp)
    80001fe2:	ec56                	sd	s5,24(sp)
    80001fe4:	e85a                	sd	s6,16(sp)
    80001fe6:	e45e                	sd	s7,8(sp)
    80001fe8:	0880                	add	s0,sp,80
    80001fea:	8792                	mv	a5,tp
  int id = r_tp();
    80001fec:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fee:	00779b13          	sll	s6,a5,0x7
    80001ff2:	0000f717          	auipc	a4,0xf
    80001ff6:	d4e70713          	add	a4,a4,-690 # 80010d40 <pid_lock>
    80001ffa:	975a                	add	a4,a4,s6
    80001ffc:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80002000:	0000f717          	auipc	a4,0xf
    80002004:	d7870713          	add	a4,a4,-648 # 80010d78 <cpus+0x8>
    80002008:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    8000200a:	4b91                	li	s7,4
        c->proc = p;
    8000200c:	079e                	sll	a5,a5,0x7
    8000200e:	0000fa97          	auipc	s5,0xf
    80002012:	d32a8a93          	add	s5,s5,-718 # 80010d40 <pid_lock>
    80002016:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002018:	6999                	lui	s3,0x6
    8000201a:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000201e:	0018ca17          	auipc	s4,0x18c
    80002022:	f52a0a13          	add	s4,s4,-174 # 8018df70 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002026:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000202a:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000202e:	10079073          	csrw	sstatus,a5
    80002032:	0000f497          	auipc	s1,0xf
    80002036:	13e48493          	add	s1,s1,318 # 80011170 <proc>
      if(p->state == RUNNABLE) {
    8000203a:	490d                	li	s2,3
    8000203c:	a809                	j	8000204e <scheduler+0x7a>
      release(&p->lock);
    8000203e:	8526                	mv	a0,s1
    80002040:	fffff097          	auipc	ra,0xfffff
    80002044:	c46080e7          	jalr	-954(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002048:	94ce                	add	s1,s1,s3
    8000204a:	fd448ee3          	beq	s1,s4,80002026 <scheduler+0x52>
      acquire(&p->lock);
    8000204e:	8526                	mv	a0,s1
    80002050:	fffff097          	auipc	ra,0xfffff
    80002054:	b82080e7          	jalr	-1150(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80002058:	4c9c                	lw	a5,24(s1)
    8000205a:	ff2792e3          	bne	a5,s2,8000203e <scheduler+0x6a>
        p->state = RUNNING;
    8000205e:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80002062:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80002066:	06048593          	add	a1,s1,96
    8000206a:	855a                	mv	a0,s6
    8000206c:	00000097          	auipc	ra,0x0
    80002070:	6a0080e7          	jalr	1696(ra) # 8000270c <swtch>
        c->proc = 0;
    80002074:	020ab823          	sd	zero,48(s5)
    80002078:	b7d9                	j	8000203e <scheduler+0x6a>

000000008000207a <sched>:
{
    8000207a:	7179                	add	sp,sp,-48
    8000207c:	f406                	sd	ra,40(sp)
    8000207e:	f022                	sd	s0,32(sp)
    80002080:	ec26                	sd	s1,24(sp)
    80002082:	e84a                	sd	s2,16(sp)
    80002084:	e44e                	sd	s3,8(sp)
    80002086:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80002088:	00000097          	auipc	ra,0x0
    8000208c:	96e080e7          	jalr	-1682(ra) # 800019f6 <myproc>
    80002090:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	ac6080e7          	jalr	-1338(ra) # 80000b58 <holding>
    8000209a:	c93d                	beqz	a0,80002110 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000209c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000209e:	2781                	sext.w	a5,a5
    800020a0:	079e                	sll	a5,a5,0x7
    800020a2:	0000f717          	auipc	a4,0xf
    800020a6:	c9e70713          	add	a4,a4,-866 # 80010d40 <pid_lock>
    800020aa:	97ba                	add	a5,a5,a4
    800020ac:	0a87a703          	lw	a4,168(a5)
    800020b0:	4785                	li	a5,1
    800020b2:	06f71763          	bne	a4,a5,80002120 <sched+0xa6>
  if(p->state == RUNNING)
    800020b6:	4c98                	lw	a4,24(s1)
    800020b8:	4791                	li	a5,4
    800020ba:	06f70b63          	beq	a4,a5,80002130 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020be:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020c2:	8b89                	and	a5,a5,2
  if(intr_get())
    800020c4:	efb5                	bnez	a5,80002140 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020c6:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020c8:	0000f917          	auipc	s2,0xf
    800020cc:	c7890913          	add	s2,s2,-904 # 80010d40 <pid_lock>
    800020d0:	2781                	sext.w	a5,a5
    800020d2:	079e                	sll	a5,a5,0x7
    800020d4:	97ca                	add	a5,a5,s2
    800020d6:	0ac7a983          	lw	s3,172(a5)
    800020da:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020dc:	2781                	sext.w	a5,a5
    800020de:	079e                	sll	a5,a5,0x7
    800020e0:	0000f597          	auipc	a1,0xf
    800020e4:	c9858593          	add	a1,a1,-872 # 80010d78 <cpus+0x8>
    800020e8:	95be                	add	a1,a1,a5
    800020ea:	06048513          	add	a0,s1,96
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	61e080e7          	jalr	1566(ra) # 8000270c <swtch>
    800020f6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020f8:	2781                	sext.w	a5,a5
    800020fa:	079e                	sll	a5,a5,0x7
    800020fc:	993e                	add	s2,s2,a5
    800020fe:	0b392623          	sw	s3,172(s2)
}
    80002102:	70a2                	ld	ra,40(sp)
    80002104:	7402                	ld	s0,32(sp)
    80002106:	64e2                	ld	s1,24(sp)
    80002108:	6942                	ld	s2,16(sp)
    8000210a:	69a2                	ld	s3,8(sp)
    8000210c:	6145                	add	sp,sp,48
    8000210e:	8082                	ret
    panic("sched p->lock");
    80002110:	00006517          	auipc	a0,0x6
    80002114:	15850513          	add	a0,a0,344 # 80008268 <digits+0x228>
    80002118:	ffffe097          	auipc	ra,0xffffe
    8000211c:	424080e7          	jalr	1060(ra) # 8000053c <panic>
    panic("sched locks");
    80002120:	00006517          	auipc	a0,0x6
    80002124:	15850513          	add	a0,a0,344 # 80008278 <digits+0x238>
    80002128:	ffffe097          	auipc	ra,0xffffe
    8000212c:	414080e7          	jalr	1044(ra) # 8000053c <panic>
    panic("sched running");
    80002130:	00006517          	auipc	a0,0x6
    80002134:	15850513          	add	a0,a0,344 # 80008288 <digits+0x248>
    80002138:	ffffe097          	auipc	ra,0xffffe
    8000213c:	404080e7          	jalr	1028(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002140:	00006517          	auipc	a0,0x6
    80002144:	15850513          	add	a0,a0,344 # 80008298 <digits+0x258>
    80002148:	ffffe097          	auipc	ra,0xffffe
    8000214c:	3f4080e7          	jalr	1012(ra) # 8000053c <panic>

0000000080002150 <yield>:
{
    80002150:	1101                	add	sp,sp,-32
    80002152:	ec06                	sd	ra,24(sp)
    80002154:	e822                	sd	s0,16(sp)
    80002156:	e426                	sd	s1,8(sp)
    80002158:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    8000215a:	00000097          	auipc	ra,0x0
    8000215e:	89c080e7          	jalr	-1892(ra) # 800019f6 <myproc>
    80002162:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002164:	fffff097          	auipc	ra,0xfffff
    80002168:	a6e080e7          	jalr	-1426(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000216c:	478d                	li	a5,3
    8000216e:	cc9c                	sw	a5,24(s1)
  sched();
    80002170:	00000097          	auipc	ra,0x0
    80002174:	f0a080e7          	jalr	-246(ra) # 8000207a <sched>
  release(&p->lock);
    80002178:	8526                	mv	a0,s1
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	b0c080e7          	jalr	-1268(ra) # 80000c86 <release>
}
    80002182:	60e2                	ld	ra,24(sp)
    80002184:	6442                	ld	s0,16(sp)
    80002186:	64a2                	ld	s1,8(sp)
    80002188:	6105                	add	sp,sp,32
    8000218a:	8082                	ret

000000008000218c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000218c:	7179                	add	sp,sp,-48
    8000218e:	f406                	sd	ra,40(sp)
    80002190:	f022                	sd	s0,32(sp)
    80002192:	ec26                	sd	s1,24(sp)
    80002194:	e84a                	sd	s2,16(sp)
    80002196:	e44e                	sd	s3,8(sp)
    80002198:	1800                	add	s0,sp,48
    8000219a:	89aa                	mv	s3,a0
    8000219c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000219e:	00000097          	auipc	ra,0x0
    800021a2:	858080e7          	jalr	-1960(ra) # 800019f6 <myproc>
    800021a6:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021a8:	fffff097          	auipc	ra,0xfffff
    800021ac:	a2a080e7          	jalr	-1494(ra) # 80000bd2 <acquire>
  release(lk);
    800021b0:	854a                	mv	a0,s2
    800021b2:	fffff097          	auipc	ra,0xfffff
    800021b6:	ad4080e7          	jalr	-1324(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800021ba:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021be:	4789                	li	a5,2
    800021c0:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    800021c2:	00000097          	auipc	ra,0x0
    800021c6:	eb8080e7          	jalr	-328(ra) # 8000207a <sched>

  // Tidy up.
  p->chan = 0;
    800021ca:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ce:	8526                	mv	a0,s1
    800021d0:	fffff097          	auipc	ra,0xfffff
    800021d4:	ab6080e7          	jalr	-1354(ra) # 80000c86 <release>
  acquire(lk);
    800021d8:	854a                	mv	a0,s2
    800021da:	fffff097          	auipc	ra,0xfffff
    800021de:	9f8080e7          	jalr	-1544(ra) # 80000bd2 <acquire>
}
    800021e2:	70a2                	ld	ra,40(sp)
    800021e4:	7402                	ld	s0,32(sp)
    800021e6:	64e2                	ld	s1,24(sp)
    800021e8:	6942                	ld	s2,16(sp)
    800021ea:	69a2                	ld	s3,8(sp)
    800021ec:	6145                	add	sp,sp,48
    800021ee:	8082                	ret

00000000800021f0 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021f0:	7139                	add	sp,sp,-64
    800021f2:	fc06                	sd	ra,56(sp)
    800021f4:	f822                	sd	s0,48(sp)
    800021f6:	f426                	sd	s1,40(sp)
    800021f8:	f04a                	sd	s2,32(sp)
    800021fa:	ec4e                	sd	s3,24(sp)
    800021fc:	e852                	sd	s4,16(sp)
    800021fe:	e456                	sd	s5,8(sp)
    80002200:	e05a                	sd	s6,0(sp)
    80002202:	0080                	add	s0,sp,64
    80002204:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002206:	0000f497          	auipc	s1,0xf
    8000220a:	f6a48493          	add	s1,s1,-150 # 80011170 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    8000220e:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002210:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002212:	6919                	lui	s2,0x6
    80002214:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002218:	0018c997          	auipc	s3,0x18c
    8000221c:	d5898993          	add	s3,s3,-680 # 8018df70 <tickslock>
    80002220:	a809                	j	80002232 <wakeup+0x42>
      }
      release(&p->lock);
    80002222:	8526                	mv	a0,s1
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	a62080e7          	jalr	-1438(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000222c:	94ca                	add	s1,s1,s2
    8000222e:	03348663          	beq	s1,s3,8000225a <wakeup+0x6a>
    if(p != myproc()){
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	7c4080e7          	jalr	1988(ra) # 800019f6 <myproc>
    8000223a:	fea489e3          	beq	s1,a0,8000222c <wakeup+0x3c>
      acquire(&p->lock);
    8000223e:	8526                	mv	a0,s1
    80002240:	fffff097          	auipc	ra,0xfffff
    80002244:	992080e7          	jalr	-1646(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002248:	4c9c                	lw	a5,24(s1)
    8000224a:	fd479ce3          	bne	a5,s4,80002222 <wakeup+0x32>
    8000224e:	709c                	ld	a5,32(s1)
    80002250:	fd5799e3          	bne	a5,s5,80002222 <wakeup+0x32>
        p->state = RUNNABLE;
    80002254:	0164ac23          	sw	s6,24(s1)
    80002258:	b7e9                	j	80002222 <wakeup+0x32>
    }
  }
}
    8000225a:	70e2                	ld	ra,56(sp)
    8000225c:	7442                	ld	s0,48(sp)
    8000225e:	74a2                	ld	s1,40(sp)
    80002260:	7902                	ld	s2,32(sp)
    80002262:	69e2                	ld	s3,24(sp)
    80002264:	6a42                	ld	s4,16(sp)
    80002266:	6aa2                	ld	s5,8(sp)
    80002268:	6b02                	ld	s6,0(sp)
    8000226a:	6121                	add	sp,sp,64
    8000226c:	8082                	ret

000000008000226e <reparent>:
{
    8000226e:	7139                	add	sp,sp,-64
    80002270:	fc06                	sd	ra,56(sp)
    80002272:	f822                	sd	s0,48(sp)
    80002274:	f426                	sd	s1,40(sp)
    80002276:	f04a                	sd	s2,32(sp)
    80002278:	ec4e                	sd	s3,24(sp)
    8000227a:	e852                	sd	s4,16(sp)
    8000227c:	e456                	sd	s5,8(sp)
    8000227e:	0080                	add	s0,sp,64
    80002280:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002282:	0000f497          	auipc	s1,0xf
    80002286:	eee48493          	add	s1,s1,-274 # 80011170 <proc>
      pp->parent = initproc;
    8000228a:	00007a97          	auipc	s5,0x7
    8000228e:	83ea8a93          	add	s5,s5,-1986 # 80008ac8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002292:	6919                	lui	s2,0x6
    80002294:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002298:	0018ca17          	auipc	s4,0x18c
    8000229c:	cd8a0a13          	add	s4,s4,-808 # 8018df70 <tickslock>
    800022a0:	a021                	j	800022a8 <reparent+0x3a>
    800022a2:	94ca                	add	s1,s1,s2
    800022a4:	01448d63          	beq	s1,s4,800022be <reparent+0x50>
    if(pp->parent == p){
    800022a8:	7c9c                	ld	a5,56(s1)
    800022aa:	ff379ce3          	bne	a5,s3,800022a2 <reparent+0x34>
      pp->parent = initproc;
    800022ae:	000ab503          	ld	a0,0(s5)
    800022b2:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022b4:	00000097          	auipc	ra,0x0
    800022b8:	f3c080e7          	jalr	-196(ra) # 800021f0 <wakeup>
    800022bc:	b7dd                	j	800022a2 <reparent+0x34>
}
    800022be:	70e2                	ld	ra,56(sp)
    800022c0:	7442                	ld	s0,48(sp)
    800022c2:	74a2                	ld	s1,40(sp)
    800022c4:	7902                	ld	s2,32(sp)
    800022c6:	69e2                	ld	s3,24(sp)
    800022c8:	6a42                	ld	s4,16(sp)
    800022ca:	6aa2                	ld	s5,8(sp)
    800022cc:	6121                	add	sp,sp,64
    800022ce:	8082                	ret

00000000800022d0 <exit>:
{
    800022d0:	7179                	add	sp,sp,-48
    800022d2:	f406                	sd	ra,40(sp)
    800022d4:	f022                	sd	s0,32(sp)
    800022d6:	ec26                	sd	s1,24(sp)
    800022d8:	e84a                	sd	s2,16(sp)
    800022da:	e44e                	sd	s3,8(sp)
    800022dc:	e052                	sd	s4,0(sp)
    800022de:	1800                	add	s0,sp,48
    800022e0:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022e2:	fffff097          	auipc	ra,0xfffff
    800022e6:	714080e7          	jalr	1812(ra) # 800019f6 <myproc>
    800022ea:	89aa                	mv	s3,a0
  if(p == initproc)
    800022ec:	00006797          	auipc	a5,0x6
    800022f0:	7dc7b783          	ld	a5,2012(a5) # 80008ac8 <initproc>
    800022f4:	0d050493          	add	s1,a0,208
    800022f8:	15050913          	add	s2,a0,336
    800022fc:	02a79363          	bne	a5,a0,80002322 <exit+0x52>
    panic("init exiting");
    80002300:	00006517          	auipc	a0,0x6
    80002304:	fb050513          	add	a0,a0,-80 # 800082b0 <digits+0x270>
    80002308:	ffffe097          	auipc	ra,0xffffe
    8000230c:	234080e7          	jalr	564(ra) # 8000053c <panic>
      fileclose(f);
    80002310:	00002097          	auipc	ra,0x2
    80002314:	322080e7          	jalr	802(ra) # 80004632 <fileclose>
      p->ofile[fd] = 0;
    80002318:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000231c:	04a1                	add	s1,s1,8
    8000231e:	01248563          	beq	s1,s2,80002328 <exit+0x58>
    if(p->ofile[fd]){
    80002322:	6088                	ld	a0,0(s1)
    80002324:	f575                	bnez	a0,80002310 <exit+0x40>
    80002326:	bfdd                	j	8000231c <exit+0x4c>
  begin_op();
    80002328:	00002097          	auipc	ra,0x2
    8000232c:	e46080e7          	jalr	-442(ra) # 8000416e <begin_op>
  iput(p->cwd);
    80002330:	1509b503          	ld	a0,336(s3)
    80002334:	00001097          	auipc	ra,0x1
    80002338:	64e080e7          	jalr	1614(ra) # 80003982 <iput>
  end_op();
    8000233c:	00002097          	auipc	ra,0x2
    80002340:	eac080e7          	jalr	-340(ra) # 800041e8 <end_op>
  p->cwd = 0;
    80002344:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002348:	0000f497          	auipc	s1,0xf
    8000234c:	a1048493          	add	s1,s1,-1520 # 80010d58 <wait_lock>
    80002350:	8526                	mv	a0,s1
    80002352:	fffff097          	auipc	ra,0xfffff
    80002356:	880080e7          	jalr	-1920(ra) # 80000bd2 <acquire>
  reparent(p);
    8000235a:	854e                	mv	a0,s3
    8000235c:	00000097          	auipc	ra,0x0
    80002360:	f12080e7          	jalr	-238(ra) # 8000226e <reparent>
  wakeup(p->parent);
    80002364:	0389b503          	ld	a0,56(s3)
    80002368:	00000097          	auipc	ra,0x0
    8000236c:	e88080e7          	jalr	-376(ra) # 800021f0 <wakeup>
  acquire(&p->lock);
    80002370:	854e                	mv	a0,s3
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	860080e7          	jalr	-1952(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000237a:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000237e:	4795                	li	a5,5
    80002380:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002384:	8526                	mv	a0,s1
    80002386:	fffff097          	auipc	ra,0xfffff
    8000238a:	900080e7          	jalr	-1792(ra) # 80000c86 <release>
  sched();
    8000238e:	00000097          	auipc	ra,0x0
    80002392:	cec080e7          	jalr	-788(ra) # 8000207a <sched>
  panic("zombie exit");
    80002396:	00006517          	auipc	a0,0x6
    8000239a:	f2a50513          	add	a0,a0,-214 # 800082c0 <digits+0x280>
    8000239e:	ffffe097          	auipc	ra,0xffffe
    800023a2:	19e080e7          	jalr	414(ra) # 8000053c <panic>

00000000800023a6 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023a6:	7179                	add	sp,sp,-48
    800023a8:	f406                	sd	ra,40(sp)
    800023aa:	f022                	sd	s0,32(sp)
    800023ac:	ec26                	sd	s1,24(sp)
    800023ae:	e84a                	sd	s2,16(sp)
    800023b0:	e44e                	sd	s3,8(sp)
    800023b2:	e052                	sd	s4,0(sp)
    800023b4:	1800                	add	s0,sp,48
    800023b6:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023b8:	0000f497          	auipc	s1,0xf
    800023bc:	db848493          	add	s1,s1,-584 # 80011170 <proc>
    800023c0:	6999                	lui	s3,0x6
    800023c2:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    800023c6:	0018ca17          	auipc	s4,0x18c
    800023ca:	baaa0a13          	add	s4,s4,-1110 # 8018df70 <tickslock>
    acquire(&p->lock);
    800023ce:	8526                	mv	a0,s1
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	802080e7          	jalr	-2046(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800023d8:	589c                	lw	a5,48(s1)
    800023da:	01278c63          	beq	a5,s2,800023f2 <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023de:	8526                	mv	a0,s1
    800023e0:	fffff097          	auipc	ra,0xfffff
    800023e4:	8a6080e7          	jalr	-1882(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023e8:	94ce                	add	s1,s1,s3
    800023ea:	ff4492e3          	bne	s1,s4,800023ce <kill+0x28>
  }
  return -1;
    800023ee:	557d                	li	a0,-1
    800023f0:	a829                	j	8000240a <kill+0x64>
      p->killed = 1;
    800023f2:	4785                	li	a5,1
    800023f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023f6:	4c98                	lw	a4,24(s1)
    800023f8:	4789                	li	a5,2
    800023fa:	02f70063          	beq	a4,a5,8000241a <kill+0x74>
      release(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	886080e7          	jalr	-1914(ra) # 80000c86 <release>
      return 0;
    80002408:	4501                	li	a0,0
}
    8000240a:	70a2                	ld	ra,40(sp)
    8000240c:	7402                	ld	s0,32(sp)
    8000240e:	64e2                	ld	s1,24(sp)
    80002410:	6942                	ld	s2,16(sp)
    80002412:	69a2                	ld	s3,8(sp)
    80002414:	6a02                	ld	s4,0(sp)
    80002416:	6145                	add	sp,sp,48
    80002418:	8082                	ret
        p->state = RUNNABLE;
    8000241a:	478d                	li	a5,3
    8000241c:	cc9c                	sw	a5,24(s1)
    8000241e:	b7c5                	j	800023fe <kill+0x58>

0000000080002420 <setkilled>:

void
setkilled(struct proc *p)
{
    80002420:	1101                	add	sp,sp,-32
    80002422:	ec06                	sd	ra,24(sp)
    80002424:	e822                	sd	s0,16(sp)
    80002426:	e426                	sd	s1,8(sp)
    80002428:	1000                	add	s0,sp,32
    8000242a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000242c:	ffffe097          	auipc	ra,0xffffe
    80002430:	7a6080e7          	jalr	1958(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002434:	4785                	li	a5,1
    80002436:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002438:	8526                	mv	a0,s1
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	84c080e7          	jalr	-1972(ra) # 80000c86 <release>
}
    80002442:	60e2                	ld	ra,24(sp)
    80002444:	6442                	ld	s0,16(sp)
    80002446:	64a2                	ld	s1,8(sp)
    80002448:	6105                	add	sp,sp,32
    8000244a:	8082                	ret

000000008000244c <killed>:

int
killed(struct proc *p)
{
    8000244c:	1101                	add	sp,sp,-32
    8000244e:	ec06                	sd	ra,24(sp)
    80002450:	e822                	sd	s0,16(sp)
    80002452:	e426                	sd	s1,8(sp)
    80002454:	e04a                	sd	s2,0(sp)
    80002456:	1000                	add	s0,sp,32
    80002458:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    8000245a:	ffffe097          	auipc	ra,0xffffe
    8000245e:	778080e7          	jalr	1912(ra) # 80000bd2 <acquire>
  k = p->killed;
    80002462:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002466:	8526                	mv	a0,s1
    80002468:	fffff097          	auipc	ra,0xfffff
    8000246c:	81e080e7          	jalr	-2018(ra) # 80000c86 <release>
  return k;
}
    80002470:	854a                	mv	a0,s2
    80002472:	60e2                	ld	ra,24(sp)
    80002474:	6442                	ld	s0,16(sp)
    80002476:	64a2                	ld	s1,8(sp)
    80002478:	6902                	ld	s2,0(sp)
    8000247a:	6105                	add	sp,sp,32
    8000247c:	8082                	ret

000000008000247e <wait>:
{
    8000247e:	715d                	add	sp,sp,-80
    80002480:	e486                	sd	ra,72(sp)
    80002482:	e0a2                	sd	s0,64(sp)
    80002484:	fc26                	sd	s1,56(sp)
    80002486:	f84a                	sd	s2,48(sp)
    80002488:	f44e                	sd	s3,40(sp)
    8000248a:	f052                	sd	s4,32(sp)
    8000248c:	ec56                	sd	s5,24(sp)
    8000248e:	e85a                	sd	s6,16(sp)
    80002490:	e45e                	sd	s7,8(sp)
    80002492:	0880                	add	s0,sp,80
    80002494:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	560080e7          	jalr	1376(ra) # 800019f6 <myproc>
    8000249e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024a0:	0000f517          	auipc	a0,0xf
    800024a4:	8b850513          	add	a0,a0,-1864 # 80010d58 <wait_lock>
    800024a8:	ffffe097          	auipc	ra,0xffffe
    800024ac:	72a080e7          	jalr	1834(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    800024b0:	4a95                	li	s5,5
        havekids = 1;
    800024b2:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b4:	6999                	lui	s3,0x6
    800024b6:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    800024ba:	0018ca17          	auipc	s4,0x18c
    800024be:	ab6a0a13          	add	s4,s4,-1354 # 8018df70 <tickslock>
    800024c2:	a0d9                	j	80002588 <wait+0x10a>
          pid = pp->pid;
    800024c4:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024c8:	000b8e63          	beqz	s7,800024e4 <wait+0x66>
    800024cc:	4691                	li	a3,4
    800024ce:	02c48613          	add	a2,s1,44
    800024d2:	85de                	mv	a1,s7
    800024d4:	05093503          	ld	a0,80(s2)
    800024d8:	fffff097          	auipc	ra,0xfffff
    800024dc:	1ce080e7          	jalr	462(ra) # 800016a6 <copyout>
    800024e0:	04054063          	bltz	a0,80002520 <wait+0xa2>
          freeproc(pp);
    800024e4:	8526                	mv	a0,s1
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	6c2080e7          	jalr	1730(ra) # 80001ba8 <freeproc>
          release(&pp->lock);
    800024ee:	8526                	mv	a0,s1
    800024f0:	ffffe097          	auipc	ra,0xffffe
    800024f4:	796080e7          	jalr	1942(ra) # 80000c86 <release>
          release(&wait_lock);
    800024f8:	0000f517          	auipc	a0,0xf
    800024fc:	86050513          	add	a0,a0,-1952 # 80010d58 <wait_lock>
    80002500:	ffffe097          	auipc	ra,0xffffe
    80002504:	786080e7          	jalr	1926(ra) # 80000c86 <release>
}
    80002508:	854e                	mv	a0,s3
    8000250a:	60a6                	ld	ra,72(sp)
    8000250c:	6406                	ld	s0,64(sp)
    8000250e:	74e2                	ld	s1,56(sp)
    80002510:	7942                	ld	s2,48(sp)
    80002512:	79a2                	ld	s3,40(sp)
    80002514:	7a02                	ld	s4,32(sp)
    80002516:	6ae2                	ld	s5,24(sp)
    80002518:	6b42                	ld	s6,16(sp)
    8000251a:	6ba2                	ld	s7,8(sp)
    8000251c:	6161                	add	sp,sp,80
    8000251e:	8082                	ret
            release(&pp->lock);
    80002520:	8526                	mv	a0,s1
    80002522:	ffffe097          	auipc	ra,0xffffe
    80002526:	764080e7          	jalr	1892(ra) # 80000c86 <release>
            release(&wait_lock);
    8000252a:	0000f517          	auipc	a0,0xf
    8000252e:	82e50513          	add	a0,a0,-2002 # 80010d58 <wait_lock>
    80002532:	ffffe097          	auipc	ra,0xffffe
    80002536:	754080e7          	jalr	1876(ra) # 80000c86 <release>
            return -1;
    8000253a:	59fd                	li	s3,-1
    8000253c:	b7f1                	j	80002508 <wait+0x8a>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000253e:	94ce                	add	s1,s1,s3
    80002540:	03448463          	beq	s1,s4,80002568 <wait+0xea>
      if(pp->parent == p){
    80002544:	7c9c                	ld	a5,56(s1)
    80002546:	ff279ce3          	bne	a5,s2,8000253e <wait+0xc0>
        acquire(&pp->lock);
    8000254a:	8526                	mv	a0,s1
    8000254c:	ffffe097          	auipc	ra,0xffffe
    80002550:	686080e7          	jalr	1670(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002554:	4c9c                	lw	a5,24(s1)
    80002556:	f75787e3          	beq	a5,s5,800024c4 <wait+0x46>
        release(&pp->lock);
    8000255a:	8526                	mv	a0,s1
    8000255c:	ffffe097          	auipc	ra,0xffffe
    80002560:	72a080e7          	jalr	1834(ra) # 80000c86 <release>
        havekids = 1;
    80002564:	875a                	mv	a4,s6
    80002566:	bfe1                	j	8000253e <wait+0xc0>
    if(!havekids || killed(p)){
    80002568:	c715                	beqz	a4,80002594 <wait+0x116>
    8000256a:	854a                	mv	a0,s2
    8000256c:	00000097          	auipc	ra,0x0
    80002570:	ee0080e7          	jalr	-288(ra) # 8000244c <killed>
    80002574:	e105                	bnez	a0,80002594 <wait+0x116>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002576:	0000e597          	auipc	a1,0xe
    8000257a:	7e258593          	add	a1,a1,2018 # 80010d58 <wait_lock>
    8000257e:	854a                	mv	a0,s2
    80002580:	00000097          	auipc	ra,0x0
    80002584:	c0c080e7          	jalr	-1012(ra) # 8000218c <sleep>
    havekids = 0;
    80002588:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000258a:	0000f497          	auipc	s1,0xf
    8000258e:	be648493          	add	s1,s1,-1050 # 80011170 <proc>
    80002592:	bf4d                	j	80002544 <wait+0xc6>
      release(&wait_lock);
    80002594:	0000e517          	auipc	a0,0xe
    80002598:	7c450513          	add	a0,a0,1988 # 80010d58 <wait_lock>
    8000259c:	ffffe097          	auipc	ra,0xffffe
    800025a0:	6ea080e7          	jalr	1770(ra) # 80000c86 <release>
      return -1;
    800025a4:	59fd                	li	s3,-1
    800025a6:	b78d                	j	80002508 <wait+0x8a>

00000000800025a8 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025a8:	7179                	add	sp,sp,-48
    800025aa:	f406                	sd	ra,40(sp)
    800025ac:	f022                	sd	s0,32(sp)
    800025ae:	ec26                	sd	s1,24(sp)
    800025b0:	e84a                	sd	s2,16(sp)
    800025b2:	e44e                	sd	s3,8(sp)
    800025b4:	e052                	sd	s4,0(sp)
    800025b6:	1800                	add	s0,sp,48
    800025b8:	84aa                	mv	s1,a0
    800025ba:	892e                	mv	s2,a1
    800025bc:	89b2                	mv	s3,a2
    800025be:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c0:	fffff097          	auipc	ra,0xfffff
    800025c4:	436080e7          	jalr	1078(ra) # 800019f6 <myproc>
  if(user_dst){
    800025c8:	c08d                	beqz	s1,800025ea <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025ca:	86d2                	mv	a3,s4
    800025cc:	864e                	mv	a2,s3
    800025ce:	85ca                	mv	a1,s2
    800025d0:	6928                	ld	a0,80(a0)
    800025d2:	fffff097          	auipc	ra,0xfffff
    800025d6:	0d4080e7          	jalr	212(ra) # 800016a6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025da:	70a2                	ld	ra,40(sp)
    800025dc:	7402                	ld	s0,32(sp)
    800025de:	64e2                	ld	s1,24(sp)
    800025e0:	6942                	ld	s2,16(sp)
    800025e2:	69a2                	ld	s3,8(sp)
    800025e4:	6a02                	ld	s4,0(sp)
    800025e6:	6145                	add	sp,sp,48
    800025e8:	8082                	ret
    memmove((char *)dst, src, len);
    800025ea:	000a061b          	sext.w	a2,s4
    800025ee:	85ce                	mv	a1,s3
    800025f0:	854a                	mv	a0,s2
    800025f2:	ffffe097          	auipc	ra,0xffffe
    800025f6:	738080e7          	jalr	1848(ra) # 80000d2a <memmove>
    return 0;
    800025fa:	8526                	mv	a0,s1
    800025fc:	bff9                	j	800025da <either_copyout+0x32>

00000000800025fe <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025fe:	7179                	add	sp,sp,-48
    80002600:	f406                	sd	ra,40(sp)
    80002602:	f022                	sd	s0,32(sp)
    80002604:	ec26                	sd	s1,24(sp)
    80002606:	e84a                	sd	s2,16(sp)
    80002608:	e44e                	sd	s3,8(sp)
    8000260a:	e052                	sd	s4,0(sp)
    8000260c:	1800                	add	s0,sp,48
    8000260e:	892a                	mv	s2,a0
    80002610:	84ae                	mv	s1,a1
    80002612:	89b2                	mv	s3,a2
    80002614:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002616:	fffff097          	auipc	ra,0xfffff
    8000261a:	3e0080e7          	jalr	992(ra) # 800019f6 <myproc>
  if(user_src){
    8000261e:	c08d                	beqz	s1,80002640 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002620:	86d2                	mv	a3,s4
    80002622:	864e                	mv	a2,s3
    80002624:	85ca                	mv	a1,s2
    80002626:	6928                	ld	a0,80(a0)
    80002628:	fffff097          	auipc	ra,0xfffff
    8000262c:	10a080e7          	jalr	266(ra) # 80001732 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002630:	70a2                	ld	ra,40(sp)
    80002632:	7402                	ld	s0,32(sp)
    80002634:	64e2                	ld	s1,24(sp)
    80002636:	6942                	ld	s2,16(sp)
    80002638:	69a2                	ld	s3,8(sp)
    8000263a:	6a02                	ld	s4,0(sp)
    8000263c:	6145                	add	sp,sp,48
    8000263e:	8082                	ret
    memmove(dst, (char*)src, len);
    80002640:	000a061b          	sext.w	a2,s4
    80002644:	85ce                	mv	a1,s3
    80002646:	854a                	mv	a0,s2
    80002648:	ffffe097          	auipc	ra,0xffffe
    8000264c:	6e2080e7          	jalr	1762(ra) # 80000d2a <memmove>
    return 0;
    80002650:	8526                	mv	a0,s1
    80002652:	bff9                	j	80002630 <either_copyin+0x32>

0000000080002654 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002654:	715d                	add	sp,sp,-80
    80002656:	e486                	sd	ra,72(sp)
    80002658:	e0a2                	sd	s0,64(sp)
    8000265a:	fc26                	sd	s1,56(sp)
    8000265c:	f84a                	sd	s2,48(sp)
    8000265e:	f44e                	sd	s3,40(sp)
    80002660:	f052                	sd	s4,32(sp)
    80002662:	ec56                	sd	s5,24(sp)
    80002664:	e85a                	sd	s6,16(sp)
    80002666:	e45e                	sd	s7,8(sp)
    80002668:	e062                	sd	s8,0(sp)
    8000266a:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000266c:	00006517          	auipc	a0,0x6
    80002670:	3d450513          	add	a0,a0,980 # 80008a40 <syscalls+0x5a0>
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	f12080e7          	jalr	-238(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000267c:	0000f497          	auipc	s1,0xf
    80002680:	c4c48493          	add	s1,s1,-948 # 800112c8 <proc+0x158>
    80002684:	0018c997          	auipc	s3,0x18c
    80002688:	a4498993          	add	s3,s3,-1468 # 8018e0c8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000268c:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    8000268e:	00006a17          	auipc	s4,0x6
    80002692:	c42a0a13          	add	s4,s4,-958 # 800082d0 <digits+0x290>
    printf("%d %s %s", p->pid, state, p->name);
    80002696:	00006b17          	auipc	s6,0x6
    8000269a:	c42b0b13          	add	s6,s6,-958 # 800082d8 <digits+0x298>
    printf("\n");
    8000269e:	00006a97          	auipc	s5,0x6
    800026a2:	3a2a8a93          	add	s5,s5,930 # 80008a40 <syscalls+0x5a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a6:	00006c17          	auipc	s8,0x6
    800026aa:	c72c0c13          	add	s8,s8,-910 # 80008318 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ae:	6919                	lui	s2,0x6
    800026b0:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    800026b4:	a005                	j	800026d4 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800026b6:	ed86a583          	lw	a1,-296(a3)
    800026ba:	855a                	mv	a0,s6
    800026bc:	ffffe097          	auipc	ra,0xffffe
    800026c0:	eca080e7          	jalr	-310(ra) # 80000586 <printf>
    printf("\n");
    800026c4:	8556                	mv	a0,s5
    800026c6:	ffffe097          	auipc	ra,0xffffe
    800026ca:	ec0080e7          	jalr	-320(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ce:	94ca                	add	s1,s1,s2
    800026d0:	03348263          	beq	s1,s3,800026f4 <procdump+0xa0>
    if(p->state == UNUSED)
    800026d4:	86a6                	mv	a3,s1
    800026d6:	ec04a783          	lw	a5,-320(s1)
    800026da:	dbf5                	beqz	a5,800026ce <procdump+0x7a>
      state = "???";
    800026dc:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026de:	fcfbece3          	bltu	s7,a5,800026b6 <procdump+0x62>
    800026e2:	02079713          	sll	a4,a5,0x20
    800026e6:	01d75793          	srl	a5,a4,0x1d
    800026ea:	97e2                	add	a5,a5,s8
    800026ec:	6390                	ld	a2,0(a5)
    800026ee:	f661                	bnez	a2,800026b6 <procdump+0x62>
      state = "???";
    800026f0:	8652                	mv	a2,s4
    800026f2:	b7d1                	j	800026b6 <procdump+0x62>
  }
}
    800026f4:	60a6                	ld	ra,72(sp)
    800026f6:	6406                	ld	s0,64(sp)
    800026f8:	74e2                	ld	s1,56(sp)
    800026fa:	7942                	ld	s2,48(sp)
    800026fc:	79a2                	ld	s3,40(sp)
    800026fe:	7a02                	ld	s4,32(sp)
    80002700:	6ae2                	ld	s5,24(sp)
    80002702:	6b42                	ld	s6,16(sp)
    80002704:	6ba2                	ld	s7,8(sp)
    80002706:	6c02                	ld	s8,0(sp)
    80002708:	6161                	add	sp,sp,80
    8000270a:	8082                	ret

000000008000270c <swtch>:
    8000270c:	00153023          	sd	ra,0(a0)
    80002710:	00253423          	sd	sp,8(a0)
    80002714:	e900                	sd	s0,16(a0)
    80002716:	ed04                	sd	s1,24(a0)
    80002718:	03253023          	sd	s2,32(a0)
    8000271c:	03353423          	sd	s3,40(a0)
    80002720:	03453823          	sd	s4,48(a0)
    80002724:	03553c23          	sd	s5,56(a0)
    80002728:	05653023          	sd	s6,64(a0)
    8000272c:	05753423          	sd	s7,72(a0)
    80002730:	05853823          	sd	s8,80(a0)
    80002734:	05953c23          	sd	s9,88(a0)
    80002738:	07a53023          	sd	s10,96(a0)
    8000273c:	07b53423          	sd	s11,104(a0)
    80002740:	0005b083          	ld	ra,0(a1)
    80002744:	0085b103          	ld	sp,8(a1)
    80002748:	6980                	ld	s0,16(a1)
    8000274a:	6d84                	ld	s1,24(a1)
    8000274c:	0205b903          	ld	s2,32(a1)
    80002750:	0285b983          	ld	s3,40(a1)
    80002754:	0305ba03          	ld	s4,48(a1)
    80002758:	0385ba83          	ld	s5,56(a1)
    8000275c:	0405bb03          	ld	s6,64(a1)
    80002760:	0485bb83          	ld	s7,72(a1)
    80002764:	0505bc03          	ld	s8,80(a1)
    80002768:	0585bc83          	ld	s9,88(a1)
    8000276c:	0605bd03          	ld	s10,96(a1)
    80002770:	0685bd83          	ld	s11,104(a1)
    80002774:	8082                	ret

0000000080002776 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002776:	1141                	add	sp,sp,-16
    80002778:	e406                	sd	ra,8(sp)
    8000277a:	e022                	sd	s0,0(sp)
    8000277c:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000277e:	00006597          	auipc	a1,0x6
    80002782:	bca58593          	add	a1,a1,-1078 # 80008348 <states.0+0x30>
    80002786:	0018b517          	auipc	a0,0x18b
    8000278a:	7ea50513          	add	a0,a0,2026 # 8018df70 <tickslock>
    8000278e:	ffffe097          	auipc	ra,0xffffe
    80002792:	3b4080e7          	jalr	948(ra) # 80000b42 <initlock>
}
    80002796:	60a2                	ld	ra,8(sp)
    80002798:	6402                	ld	s0,0(sp)
    8000279a:	0141                	add	sp,sp,16
    8000279c:	8082                	ret

000000008000279e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000279e:	1141                	add	sp,sp,-16
    800027a0:	e422                	sd	s0,8(sp)
    800027a2:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027a4:	00003797          	auipc	a5,0x3
    800027a8:	53c78793          	add	a5,a5,1340 # 80005ce0 <kernelvec>
    800027ac:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027b0:	6422                	ld	s0,8(sp)
    800027b2:	0141                	add	sp,sp,16
    800027b4:	8082                	ret

00000000800027b6 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027b6:	1141                	add	sp,sp,-16
    800027b8:	e406                	sd	ra,8(sp)
    800027ba:	e022                	sd	s0,0(sp)
    800027bc:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800027be:	fffff097          	auipc	ra,0xfffff
    800027c2:	238080e7          	jalr	568(ra) # 800019f6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027ca:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027cc:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027d0:	00005697          	auipc	a3,0x5
    800027d4:	83068693          	add	a3,a3,-2000 # 80007000 <_trampoline>
    800027d8:	00005717          	auipc	a4,0x5
    800027dc:	82870713          	add	a4,a4,-2008 # 80007000 <_trampoline>
    800027e0:	8f15                	sub	a4,a4,a3
    800027e2:	040007b7          	lui	a5,0x4000
    800027e6:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027e8:	07b2                	sll	a5,a5,0xc
    800027ea:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027ec:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027f0:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027f2:	18002673          	csrr	a2,satp
    800027f6:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027f8:	6d30                	ld	a2,88(a0)
    800027fa:	6138                	ld	a4,64(a0)
    800027fc:	6585                	lui	a1,0x1
    800027fe:	972e                	add	a4,a4,a1
    80002800:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002802:	6d38                	ld	a4,88(a0)
    80002804:	00000617          	auipc	a2,0x0
    80002808:	13460613          	add	a2,a2,308 # 80002938 <usertrap>
    8000280c:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    8000280e:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002810:	8612                	mv	a2,tp
    80002812:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002814:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002818:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000281c:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002820:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002824:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002826:	6f18                	ld	a4,24(a4)
    80002828:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000282c:	6928                	ld	a0,80(a0)
    8000282e:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002830:	00005717          	auipc	a4,0x5
    80002834:	86c70713          	add	a4,a4,-1940 # 8000709c <userret>
    80002838:	8f15                	sub	a4,a4,a3
    8000283a:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000283c:	577d                	li	a4,-1
    8000283e:	177e                	sll	a4,a4,0x3f
    80002840:	8d59                	or	a0,a0,a4
    80002842:	9782                	jalr	a5
}
    80002844:	60a2                	ld	ra,8(sp)
    80002846:	6402                	ld	s0,0(sp)
    80002848:	0141                	add	sp,sp,16
    8000284a:	8082                	ret

000000008000284c <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    8000284c:	1101                	add	sp,sp,-32
    8000284e:	ec06                	sd	ra,24(sp)
    80002850:	e822                	sd	s0,16(sp)
    80002852:	e426                	sd	s1,8(sp)
    80002854:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002856:	0018b497          	auipc	s1,0x18b
    8000285a:	71a48493          	add	s1,s1,1818 # 8018df70 <tickslock>
    8000285e:	8526                	mv	a0,s1
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	372080e7          	jalr	882(ra) # 80000bd2 <acquire>
  ticks++;
    80002868:	00006517          	auipc	a0,0x6
    8000286c:	26850513          	add	a0,a0,616 # 80008ad0 <ticks>
    80002870:	411c                	lw	a5,0(a0)
    80002872:	2785                	addw	a5,a5,1
    80002874:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002876:	00000097          	auipc	ra,0x0
    8000287a:	97a080e7          	jalr	-1670(ra) # 800021f0 <wakeup>
  release(&tickslock);
    8000287e:	8526                	mv	a0,s1
    80002880:	ffffe097          	auipc	ra,0xffffe
    80002884:	406080e7          	jalr	1030(ra) # 80000c86 <release>
}
    80002888:	60e2                	ld	ra,24(sp)
    8000288a:	6442                	ld	s0,16(sp)
    8000288c:	64a2                	ld	s1,8(sp)
    8000288e:	6105                	add	sp,sp,32
    80002890:	8082                	ret

0000000080002892 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002892:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002896:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002898:	0807df63          	bgez	a5,80002936 <devintr+0xa4>
{
    8000289c:	1101                	add	sp,sp,-32
    8000289e:	ec06                	sd	ra,24(sp)
    800028a0:	e822                	sd	s0,16(sp)
    800028a2:	e426                	sd	s1,8(sp)
    800028a4:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    800028a6:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    800028aa:	46a5                	li	a3,9
    800028ac:	00d70d63          	beq	a4,a3,800028c6 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    800028b0:	577d                	li	a4,-1
    800028b2:	177e                	sll	a4,a4,0x3f
    800028b4:	0705                	add	a4,a4,1
    return 0;
    800028b6:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028b8:	04e78e63          	beq	a5,a4,80002914 <devintr+0x82>
  }
}
    800028bc:	60e2                	ld	ra,24(sp)
    800028be:	6442                	ld	s0,16(sp)
    800028c0:	64a2                	ld	s1,8(sp)
    800028c2:	6105                	add	sp,sp,32
    800028c4:	8082                	ret
    int irq = plic_claim();
    800028c6:	00003097          	auipc	ra,0x3
    800028ca:	522080e7          	jalr	1314(ra) # 80005de8 <plic_claim>
    800028ce:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028d0:	47a9                	li	a5,10
    800028d2:	02f50763          	beq	a0,a5,80002900 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800028d6:	4785                	li	a5,1
    800028d8:	02f50963          	beq	a0,a5,8000290a <devintr+0x78>
    return 1;
    800028dc:	4505                	li	a0,1
    } else if(irq){
    800028de:	dcf9                	beqz	s1,800028bc <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800028e0:	85a6                	mv	a1,s1
    800028e2:	00006517          	auipc	a0,0x6
    800028e6:	a6e50513          	add	a0,a0,-1426 # 80008350 <states.0+0x38>
    800028ea:	ffffe097          	auipc	ra,0xffffe
    800028ee:	c9c080e7          	jalr	-868(ra) # 80000586 <printf>
      plic_complete(irq);
    800028f2:	8526                	mv	a0,s1
    800028f4:	00003097          	auipc	ra,0x3
    800028f8:	518080e7          	jalr	1304(ra) # 80005e0c <plic_complete>
    return 1;
    800028fc:	4505                	li	a0,1
    800028fe:	bf7d                	j	800028bc <devintr+0x2a>
      uartintr();
    80002900:	ffffe097          	auipc	ra,0xffffe
    80002904:	094080e7          	jalr	148(ra) # 80000994 <uartintr>
    if(irq)
    80002908:	b7ed                	j	800028f2 <devintr+0x60>
      virtio_disk_intr();
    8000290a:	00004097          	auipc	ra,0x4
    8000290e:	9c8080e7          	jalr	-1592(ra) # 800062d2 <virtio_disk_intr>
    if(irq)
    80002912:	b7c5                	j	800028f2 <devintr+0x60>
    if(cpuid() == 0){
    80002914:	fffff097          	auipc	ra,0xfffff
    80002918:	0b6080e7          	jalr	182(ra) # 800019ca <cpuid>
    8000291c:	c901                	beqz	a0,8000292c <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000291e:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002922:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002924:	14479073          	csrw	sip,a5
    return 2;
    80002928:	4509                	li	a0,2
    8000292a:	bf49                	j	800028bc <devintr+0x2a>
      clockintr();
    8000292c:	00000097          	auipc	ra,0x0
    80002930:	f20080e7          	jalr	-224(ra) # 8000284c <clockintr>
    80002934:	b7ed                	j	8000291e <devintr+0x8c>
}
    80002936:	8082                	ret

0000000080002938 <usertrap>:
{
    80002938:	1101                	add	sp,sp,-32
    8000293a:	ec06                	sd	ra,24(sp)
    8000293c:	e822                	sd	s0,16(sp)
    8000293e:	e426                	sd	s1,8(sp)
    80002940:	e04a                	sd	s2,0(sp)
    80002942:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002944:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002948:	1007f793          	and	a5,a5,256
    8000294c:	e7c1                	bnez	a5,800029d4 <usertrap+0x9c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000294e:	00003797          	auipc	a5,0x3
    80002952:	39278793          	add	a5,a5,914 # 80005ce0 <kernelvec>
    80002956:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    8000295a:	fffff097          	auipc	ra,0xfffff
    8000295e:	09c080e7          	jalr	156(ra) # 800019f6 <myproc>
    80002962:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002964:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002966:	14102773          	csrr	a4,sepc
    8000296a:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000296c:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002970:	47a1                	li	a5,8
    80002972:	06f70963          	beq	a4,a5,800029e4 <usertrap+0xac>
    80002976:	14202773          	csrr	a4,scause
  else if(r_scause() == 12 || r_scause() == 13 || r_scause() == 15){
    8000297a:	47b1                	li	a5,12
    8000297c:	00f70c63          	beq	a4,a5,80002994 <usertrap+0x5c>
    80002980:	14202773          	csrr	a4,scause
    80002984:	47b5                	li	a5,13
    80002986:	00f70763          	beq	a4,a5,80002994 <usertrap+0x5c>
    8000298a:	14202773          	csrr	a4,scause
    8000298e:	47bd                	li	a5,15
    80002990:	08f71a63          	bne	a4,a5,80002a24 <usertrap+0xec>
    if(killed(p))
    80002994:	8526                	mv	a0,s1
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	ab6080e7          	jalr	-1354(ra) # 8000244c <killed>
    8000299e:	ed2d                	bnez	a0,80002a18 <usertrap+0xe0>
    page_fault_handler();
    800029a0:	00004097          	auipc	ra,0x4
    800029a4:	ab4080e7          	jalr	-1356(ra) # 80006454 <page_fault_handler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029ac:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b0:	10079073          	csrw	sstatus,a5
  if(killed(p))
    800029b4:	8526                	mv	a0,s1
    800029b6:	00000097          	auipc	ra,0x0
    800029ba:	a96080e7          	jalr	-1386(ra) # 8000244c <killed>
    800029be:	ed4d                	bnez	a0,80002a78 <usertrap+0x140>
  usertrapret();
    800029c0:	00000097          	auipc	ra,0x0
    800029c4:	df6080e7          	jalr	-522(ra) # 800027b6 <usertrapret>
}
    800029c8:	60e2                	ld	ra,24(sp)
    800029ca:	6442                	ld	s0,16(sp)
    800029cc:	64a2                	ld	s1,8(sp)
    800029ce:	6902                	ld	s2,0(sp)
    800029d0:	6105                	add	sp,sp,32
    800029d2:	8082                	ret
    panic("usertrap: not from user mode");
    800029d4:	00006517          	auipc	a0,0x6
    800029d8:	99c50513          	add	a0,a0,-1636 # 80008370 <states.0+0x58>
    800029dc:	ffffe097          	auipc	ra,0xffffe
    800029e0:	b60080e7          	jalr	-1184(ra) # 8000053c <panic>
    if(killed(p))
    800029e4:	00000097          	auipc	ra,0x0
    800029e8:	a68080e7          	jalr	-1432(ra) # 8000244c <killed>
    800029ec:	e105                	bnez	a0,80002a0c <usertrap+0xd4>
    p->trapframe->epc += 4;
    800029ee:	6cb8                	ld	a4,88(s1)
    800029f0:	6f1c                	ld	a5,24(a4)
    800029f2:	0791                	add	a5,a5,4
    800029f4:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029f6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029fa:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fe:	10079073          	csrw	sstatus,a5
    syscall();
    80002a02:	00000097          	auipc	ra,0x0
    80002a06:	2dc080e7          	jalr	732(ra) # 80002cde <syscall>
    80002a0a:	b76d                	j	800029b4 <usertrap+0x7c>
      exit(-1);
    80002a0c:	557d                	li	a0,-1
    80002a0e:	00000097          	auipc	ra,0x0
    80002a12:	8c2080e7          	jalr	-1854(ra) # 800022d0 <exit>
    80002a16:	bfe1                	j	800029ee <usertrap+0xb6>
      exit(-1);
    80002a18:	557d                	li	a0,-1
    80002a1a:	00000097          	auipc	ra,0x0
    80002a1e:	8b6080e7          	jalr	-1866(ra) # 800022d0 <exit>
    80002a22:	bfbd                	j	800029a0 <usertrap+0x68>
  else if((which_dev = devintr()) != 0){
    80002a24:	00000097          	auipc	ra,0x0
    80002a28:	e6e080e7          	jalr	-402(ra) # 80002892 <devintr>
    80002a2c:	892a                	mv	s2,a0
    80002a2e:	c901                	beqz	a0,80002a3e <usertrap+0x106>
  if(killed(p))
    80002a30:	8526                	mv	a0,s1
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	a1a080e7          	jalr	-1510(ra) # 8000244c <killed>
    80002a3a:	c529                	beqz	a0,80002a84 <usertrap+0x14c>
    80002a3c:	a83d                	j	80002a7a <usertrap+0x142>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a3e:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a42:	5890                	lw	a2,48(s1)
    80002a44:	00006517          	auipc	a0,0x6
    80002a48:	94c50513          	add	a0,a0,-1716 # 80008390 <states.0+0x78>
    80002a4c:	ffffe097          	auipc	ra,0xffffe
    80002a50:	b3a080e7          	jalr	-1222(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a54:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a58:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a5c:	00006517          	auipc	a0,0x6
    80002a60:	96450513          	add	a0,a0,-1692 # 800083c0 <states.0+0xa8>
    80002a64:	ffffe097          	auipc	ra,0xffffe
    80002a68:	b22080e7          	jalr	-1246(ra) # 80000586 <printf>
    setkilled(p);
    80002a6c:	8526                	mv	a0,s1
    80002a6e:	00000097          	auipc	ra,0x0
    80002a72:	9b2080e7          	jalr	-1614(ra) # 80002420 <setkilled>
    80002a76:	bf3d                	j	800029b4 <usertrap+0x7c>
  if(killed(p))
    80002a78:	4901                	li	s2,0
    exit(-1);
    80002a7a:	557d                	li	a0,-1
    80002a7c:	00000097          	auipc	ra,0x0
    80002a80:	854080e7          	jalr	-1964(ra) # 800022d0 <exit>
  if(which_dev == 2)
    80002a84:	4789                	li	a5,2
    80002a86:	f2f91de3          	bne	s2,a5,800029c0 <usertrap+0x88>
    yield();
    80002a8a:	fffff097          	auipc	ra,0xfffff
    80002a8e:	6c6080e7          	jalr	1734(ra) # 80002150 <yield>
    80002a92:	b73d                	j	800029c0 <usertrap+0x88>

0000000080002a94 <kerneltrap>:
{
    80002a94:	7179                	add	sp,sp,-48
    80002a96:	f406                	sd	ra,40(sp)
    80002a98:	f022                	sd	s0,32(sp)
    80002a9a:	ec26                	sd	s1,24(sp)
    80002a9c:	e84a                	sd	s2,16(sp)
    80002a9e:	e44e                	sd	s3,8(sp)
    80002aa0:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002aa2:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa6:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002aaa:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002aae:	1004f793          	and	a5,s1,256
    80002ab2:	cb85                	beqz	a5,80002ae2 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002ab4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002ab8:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002aba:	ef85                	bnez	a5,80002af2 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002abc:	00000097          	auipc	ra,0x0
    80002ac0:	dd6080e7          	jalr	-554(ra) # 80002892 <devintr>
    80002ac4:	cd1d                	beqz	a0,80002b02 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002ac6:	4789                	li	a5,2
    80002ac8:	06f50a63          	beq	a0,a5,80002b3c <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002acc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002ad0:	10049073          	csrw	sstatus,s1
}
    80002ad4:	70a2                	ld	ra,40(sp)
    80002ad6:	7402                	ld	s0,32(sp)
    80002ad8:	64e2                	ld	s1,24(sp)
    80002ada:	6942                	ld	s2,16(sp)
    80002adc:	69a2                	ld	s3,8(sp)
    80002ade:	6145                	add	sp,sp,48
    80002ae0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ae2:	00006517          	auipc	a0,0x6
    80002ae6:	8fe50513          	add	a0,a0,-1794 # 800083e0 <states.0+0xc8>
    80002aea:	ffffe097          	auipc	ra,0xffffe
    80002aee:	a52080e7          	jalr	-1454(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002af2:	00006517          	auipc	a0,0x6
    80002af6:	91650513          	add	a0,a0,-1770 # 80008408 <states.0+0xf0>
    80002afa:	ffffe097          	auipc	ra,0xffffe
    80002afe:	a42080e7          	jalr	-1470(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002b02:	85ce                	mv	a1,s3
    80002b04:	00006517          	auipc	a0,0x6
    80002b08:	92450513          	add	a0,a0,-1756 # 80008428 <states.0+0x110>
    80002b0c:	ffffe097          	auipc	ra,0xffffe
    80002b10:	a7a080e7          	jalr	-1414(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b14:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b18:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b1c:	00006517          	auipc	a0,0x6
    80002b20:	91c50513          	add	a0,a0,-1764 # 80008438 <states.0+0x120>
    80002b24:	ffffe097          	auipc	ra,0xffffe
    80002b28:	a62080e7          	jalr	-1438(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002b2c:	00006517          	auipc	a0,0x6
    80002b30:	92450513          	add	a0,a0,-1756 # 80008450 <states.0+0x138>
    80002b34:	ffffe097          	auipc	ra,0xffffe
    80002b38:	a08080e7          	jalr	-1528(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002b3c:	fffff097          	auipc	ra,0xfffff
    80002b40:	eba080e7          	jalr	-326(ra) # 800019f6 <myproc>
    80002b44:	d541                	beqz	a0,80002acc <kerneltrap+0x38>
    80002b46:	fffff097          	auipc	ra,0xfffff
    80002b4a:	eb0080e7          	jalr	-336(ra) # 800019f6 <myproc>
    80002b4e:	4d18                	lw	a4,24(a0)
    80002b50:	4791                	li	a5,4
    80002b52:	f6f71de3          	bne	a4,a5,80002acc <kerneltrap+0x38>
    yield();
    80002b56:	fffff097          	auipc	ra,0xfffff
    80002b5a:	5fa080e7          	jalr	1530(ra) # 80002150 <yield>
    80002b5e:	b7bd                	j	80002acc <kerneltrap+0x38>

0000000080002b60 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b60:	1101                	add	sp,sp,-32
    80002b62:	ec06                	sd	ra,24(sp)
    80002b64:	e822                	sd	s0,16(sp)
    80002b66:	e426                	sd	s1,8(sp)
    80002b68:	1000                	add	s0,sp,32
    80002b6a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	e8a080e7          	jalr	-374(ra) # 800019f6 <myproc>
  switch (n) {
    80002b74:	4795                	li	a5,5
    80002b76:	0497e163          	bltu	a5,s1,80002bb8 <argraw+0x58>
    80002b7a:	048a                	sll	s1,s1,0x2
    80002b7c:	00006717          	auipc	a4,0x6
    80002b80:	90c70713          	add	a4,a4,-1780 # 80008488 <states.0+0x170>
    80002b84:	94ba                	add	s1,s1,a4
    80002b86:	409c                	lw	a5,0(s1)
    80002b88:	97ba                	add	a5,a5,a4
    80002b8a:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b8c:	6d3c                	ld	a5,88(a0)
    80002b8e:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b90:	60e2                	ld	ra,24(sp)
    80002b92:	6442                	ld	s0,16(sp)
    80002b94:	64a2                	ld	s1,8(sp)
    80002b96:	6105                	add	sp,sp,32
    80002b98:	8082                	ret
    return p->trapframe->a1;
    80002b9a:	6d3c                	ld	a5,88(a0)
    80002b9c:	7fa8                	ld	a0,120(a5)
    80002b9e:	bfcd                	j	80002b90 <argraw+0x30>
    return p->trapframe->a2;
    80002ba0:	6d3c                	ld	a5,88(a0)
    80002ba2:	63c8                	ld	a0,128(a5)
    80002ba4:	b7f5                	j	80002b90 <argraw+0x30>
    return p->trapframe->a3;
    80002ba6:	6d3c                	ld	a5,88(a0)
    80002ba8:	67c8                	ld	a0,136(a5)
    80002baa:	b7dd                	j	80002b90 <argraw+0x30>
    return p->trapframe->a4;
    80002bac:	6d3c                	ld	a5,88(a0)
    80002bae:	6bc8                	ld	a0,144(a5)
    80002bb0:	b7c5                	j	80002b90 <argraw+0x30>
    return p->trapframe->a5;
    80002bb2:	6d3c                	ld	a5,88(a0)
    80002bb4:	6fc8                	ld	a0,152(a5)
    80002bb6:	bfe9                	j	80002b90 <argraw+0x30>
  panic("argraw");
    80002bb8:	00006517          	auipc	a0,0x6
    80002bbc:	8a850513          	add	a0,a0,-1880 # 80008460 <states.0+0x148>
    80002bc0:	ffffe097          	auipc	ra,0xffffe
    80002bc4:	97c080e7          	jalr	-1668(ra) # 8000053c <panic>

0000000080002bc8 <fetchaddr>:
{
    80002bc8:	1101                	add	sp,sp,-32
    80002bca:	ec06                	sd	ra,24(sp)
    80002bcc:	e822                	sd	s0,16(sp)
    80002bce:	e426                	sd	s1,8(sp)
    80002bd0:	e04a                	sd	s2,0(sp)
    80002bd2:	1000                	add	s0,sp,32
    80002bd4:	84aa                	mv	s1,a0
    80002bd6:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	e1e080e7          	jalr	-482(ra) # 800019f6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002be0:	653c                	ld	a5,72(a0)
    80002be2:	02f4f863          	bgeu	s1,a5,80002c12 <fetchaddr+0x4a>
    80002be6:	00848713          	add	a4,s1,8
    80002bea:	02e7e663          	bltu	a5,a4,80002c16 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bee:	46a1                	li	a3,8
    80002bf0:	8626                	mv	a2,s1
    80002bf2:	85ca                	mv	a1,s2
    80002bf4:	6928                	ld	a0,80(a0)
    80002bf6:	fffff097          	auipc	ra,0xfffff
    80002bfa:	b3c080e7          	jalr	-1220(ra) # 80001732 <copyin>
    80002bfe:	00a03533          	snez	a0,a0
    80002c02:	40a00533          	neg	a0,a0
}
    80002c06:	60e2                	ld	ra,24(sp)
    80002c08:	6442                	ld	s0,16(sp)
    80002c0a:	64a2                	ld	s1,8(sp)
    80002c0c:	6902                	ld	s2,0(sp)
    80002c0e:	6105                	add	sp,sp,32
    80002c10:	8082                	ret
    return -1;
    80002c12:	557d                	li	a0,-1
    80002c14:	bfcd                	j	80002c06 <fetchaddr+0x3e>
    80002c16:	557d                	li	a0,-1
    80002c18:	b7fd                	j	80002c06 <fetchaddr+0x3e>

0000000080002c1a <fetchstr>:
{
    80002c1a:	7179                	add	sp,sp,-48
    80002c1c:	f406                	sd	ra,40(sp)
    80002c1e:	f022                	sd	s0,32(sp)
    80002c20:	ec26                	sd	s1,24(sp)
    80002c22:	e84a                	sd	s2,16(sp)
    80002c24:	e44e                	sd	s3,8(sp)
    80002c26:	1800                	add	s0,sp,48
    80002c28:	892a                	mv	s2,a0
    80002c2a:	84ae                	mv	s1,a1
    80002c2c:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c2e:	fffff097          	auipc	ra,0xfffff
    80002c32:	dc8080e7          	jalr	-568(ra) # 800019f6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c36:	86ce                	mv	a3,s3
    80002c38:	864a                	mv	a2,s2
    80002c3a:	85a6                	mv	a1,s1
    80002c3c:	6928                	ld	a0,80(a0)
    80002c3e:	fffff097          	auipc	ra,0xfffff
    80002c42:	b82080e7          	jalr	-1150(ra) # 800017c0 <copyinstr>
    80002c46:	00054e63          	bltz	a0,80002c62 <fetchstr+0x48>
  return strlen(buf);
    80002c4a:	8526                	mv	a0,s1
    80002c4c:	ffffe097          	auipc	ra,0xffffe
    80002c50:	1fc080e7          	jalr	508(ra) # 80000e48 <strlen>
}
    80002c54:	70a2                	ld	ra,40(sp)
    80002c56:	7402                	ld	s0,32(sp)
    80002c58:	64e2                	ld	s1,24(sp)
    80002c5a:	6942                	ld	s2,16(sp)
    80002c5c:	69a2                	ld	s3,8(sp)
    80002c5e:	6145                	add	sp,sp,48
    80002c60:	8082                	ret
    return -1;
    80002c62:	557d                	li	a0,-1
    80002c64:	bfc5                	j	80002c54 <fetchstr+0x3a>

0000000080002c66 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c66:	1101                	add	sp,sp,-32
    80002c68:	ec06                	sd	ra,24(sp)
    80002c6a:	e822                	sd	s0,16(sp)
    80002c6c:	e426                	sd	s1,8(sp)
    80002c6e:	1000                	add	s0,sp,32
    80002c70:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c72:	00000097          	auipc	ra,0x0
    80002c76:	eee080e7          	jalr	-274(ra) # 80002b60 <argraw>
    80002c7a:	c088                	sw	a0,0(s1)
}
    80002c7c:	60e2                	ld	ra,24(sp)
    80002c7e:	6442                	ld	s0,16(sp)
    80002c80:	64a2                	ld	s1,8(sp)
    80002c82:	6105                	add	sp,sp,32
    80002c84:	8082                	ret

0000000080002c86 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c86:	1101                	add	sp,sp,-32
    80002c88:	ec06                	sd	ra,24(sp)
    80002c8a:	e822                	sd	s0,16(sp)
    80002c8c:	e426                	sd	s1,8(sp)
    80002c8e:	1000                	add	s0,sp,32
    80002c90:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c92:	00000097          	auipc	ra,0x0
    80002c96:	ece080e7          	jalr	-306(ra) # 80002b60 <argraw>
    80002c9a:	e088                	sd	a0,0(s1)
}
    80002c9c:	60e2                	ld	ra,24(sp)
    80002c9e:	6442                	ld	s0,16(sp)
    80002ca0:	64a2                	ld	s1,8(sp)
    80002ca2:	6105                	add	sp,sp,32
    80002ca4:	8082                	ret

0000000080002ca6 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002ca6:	7179                	add	sp,sp,-48
    80002ca8:	f406                	sd	ra,40(sp)
    80002caa:	f022                	sd	s0,32(sp)
    80002cac:	ec26                	sd	s1,24(sp)
    80002cae:	e84a                	sd	s2,16(sp)
    80002cb0:	1800                	add	s0,sp,48
    80002cb2:	84ae                	mv	s1,a1
    80002cb4:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002cb6:	fd840593          	add	a1,s0,-40
    80002cba:	00000097          	auipc	ra,0x0
    80002cbe:	fcc080e7          	jalr	-52(ra) # 80002c86 <argaddr>
  return fetchstr(addr, buf, max);
    80002cc2:	864a                	mv	a2,s2
    80002cc4:	85a6                	mv	a1,s1
    80002cc6:	fd843503          	ld	a0,-40(s0)
    80002cca:	00000097          	auipc	ra,0x0
    80002cce:	f50080e7          	jalr	-176(ra) # 80002c1a <fetchstr>
}
    80002cd2:	70a2                	ld	ra,40(sp)
    80002cd4:	7402                	ld	s0,32(sp)
    80002cd6:	64e2                	ld	s1,24(sp)
    80002cd8:	6942                	ld	s2,16(sp)
    80002cda:	6145                	add	sp,sp,48
    80002cdc:	8082                	ret

0000000080002cde <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002cde:	1101                	add	sp,sp,-32
    80002ce0:	ec06                	sd	ra,24(sp)
    80002ce2:	e822                	sd	s0,16(sp)
    80002ce4:	e426                	sd	s1,8(sp)
    80002ce6:	e04a                	sd	s2,0(sp)
    80002ce8:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002cea:	fffff097          	auipc	ra,0xfffff
    80002cee:	d0c080e7          	jalr	-756(ra) # 800019f6 <myproc>
    80002cf2:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002cf4:	05853903          	ld	s2,88(a0)
    80002cf8:	0a893783          	ld	a5,168(s2)
    80002cfc:	0007869b          	sext.w	a3,a5
  
  /* Adil: debugging */
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002d00:	37fd                	addw	a5,a5,-1
    80002d02:	4751                	li	a4,20
    80002d04:	00f76f63          	bltu	a4,a5,80002d22 <syscall+0x44>
    80002d08:	00369713          	sll	a4,a3,0x3
    80002d0c:	00005797          	auipc	a5,0x5
    80002d10:	79478793          	add	a5,a5,1940 # 800084a0 <syscalls>
    80002d14:	97ba                	add	a5,a5,a4
    80002d16:	639c                	ld	a5,0(a5)
    80002d18:	c789                	beqz	a5,80002d22 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d1a:	9782                	jalr	a5
    80002d1c:	06a93823          	sd	a0,112(s2)
    80002d20:	a839                	j	80002d3e <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d22:	15848613          	add	a2,s1,344
    80002d26:	588c                	lw	a1,48(s1)
    80002d28:	00005517          	auipc	a0,0x5
    80002d2c:	74050513          	add	a0,a0,1856 # 80008468 <states.0+0x150>
    80002d30:	ffffe097          	auipc	ra,0xffffe
    80002d34:	856080e7          	jalr	-1962(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d38:	6cbc                	ld	a5,88(s1)
    80002d3a:	577d                	li	a4,-1
    80002d3c:	fbb8                	sd	a4,112(a5)
  }
}
    80002d3e:	60e2                	ld	ra,24(sp)
    80002d40:	6442                	ld	s0,16(sp)
    80002d42:	64a2                	ld	s1,8(sp)
    80002d44:	6902                	ld	s2,0(sp)
    80002d46:	6105                	add	sp,sp,32
    80002d48:	8082                	ret

0000000080002d4a <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d4a:	1101                	add	sp,sp,-32
    80002d4c:	ec06                	sd	ra,24(sp)
    80002d4e:	e822                	sd	s0,16(sp)
    80002d50:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002d52:	fec40593          	add	a1,s0,-20
    80002d56:	4501                	li	a0,0
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	f0e080e7          	jalr	-242(ra) # 80002c66 <argint>
  exit(n);
    80002d60:	fec42503          	lw	a0,-20(s0)
    80002d64:	fffff097          	auipc	ra,0xfffff
    80002d68:	56c080e7          	jalr	1388(ra) # 800022d0 <exit>
  return 0;  // not reached
}
    80002d6c:	4501                	li	a0,0
    80002d6e:	60e2                	ld	ra,24(sp)
    80002d70:	6442                	ld	s0,16(sp)
    80002d72:	6105                	add	sp,sp,32
    80002d74:	8082                	ret

0000000080002d76 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d76:	1141                	add	sp,sp,-16
    80002d78:	e406                	sd	ra,8(sp)
    80002d7a:	e022                	sd	s0,0(sp)
    80002d7c:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002d7e:	fffff097          	auipc	ra,0xfffff
    80002d82:	c78080e7          	jalr	-904(ra) # 800019f6 <myproc>
}
    80002d86:	5908                	lw	a0,48(a0)
    80002d88:	60a2                	ld	ra,8(sp)
    80002d8a:	6402                	ld	s0,0(sp)
    80002d8c:	0141                	add	sp,sp,16
    80002d8e:	8082                	ret

0000000080002d90 <sys_fork>:

uint64
sys_fork(void)
{
    80002d90:	1141                	add	sp,sp,-16
    80002d92:	e406                	sd	ra,8(sp)
    80002d94:	e022                	sd	s0,0(sp)
    80002d96:	0800                	add	s0,sp,16
  return fork();
    80002d98:	fffff097          	auipc	ra,0xfffff
    80002d9c:	0f4080e7          	jalr	244(ra) # 80001e8c <fork>
}
    80002da0:	60a2                	ld	ra,8(sp)
    80002da2:	6402                	ld	s0,0(sp)
    80002da4:	0141                	add	sp,sp,16
    80002da6:	8082                	ret

0000000080002da8 <sys_wait>:

uint64
sys_wait(void)
{
    80002da8:	1101                	add	sp,sp,-32
    80002daa:	ec06                	sd	ra,24(sp)
    80002dac:	e822                	sd	s0,16(sp)
    80002dae:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002db0:	fe840593          	add	a1,s0,-24
    80002db4:	4501                	li	a0,0
    80002db6:	00000097          	auipc	ra,0x0
    80002dba:	ed0080e7          	jalr	-304(ra) # 80002c86 <argaddr>
  return wait(p);
    80002dbe:	fe843503          	ld	a0,-24(s0)
    80002dc2:	fffff097          	auipc	ra,0xfffff
    80002dc6:	6bc080e7          	jalr	1724(ra) # 8000247e <wait>
}
    80002dca:	60e2                	ld	ra,24(sp)
    80002dcc:	6442                	ld	s0,16(sp)
    80002dce:	6105                	add	sp,sp,32
    80002dd0:	8082                	ret

0000000080002dd2 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dd2:	7179                	add	sp,sp,-48
    80002dd4:	f406                	sd	ra,40(sp)
    80002dd6:	f022                	sd	s0,32(sp)
    80002dd8:	ec26                	sd	s1,24(sp)
    80002dda:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002ddc:	fdc40593          	add	a1,s0,-36
    80002de0:	4501                	li	a0,0
    80002de2:	00000097          	auipc	ra,0x0
    80002de6:	e84080e7          	jalr	-380(ra) # 80002c66 <argint>
  addr = myproc()->sz;
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	c0c080e7          	jalr	-1012(ra) # 800019f6 <myproc>
    80002df2:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002df4:	fdc42503          	lw	a0,-36(s0)
    80002df8:	fffff097          	auipc	ra,0xfffff
    80002dfc:	fa6080e7          	jalr	-90(ra) # 80001d9e <growproc>
    80002e00:	00054863          	bltz	a0,80002e10 <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002e04:	8526                	mv	a0,s1
    80002e06:	70a2                	ld	ra,40(sp)
    80002e08:	7402                	ld	s0,32(sp)
    80002e0a:	64e2                	ld	s1,24(sp)
    80002e0c:	6145                	add	sp,sp,48
    80002e0e:	8082                	ret
    return -1;
    80002e10:	54fd                	li	s1,-1
    80002e12:	bfcd                	j	80002e04 <sys_sbrk+0x32>

0000000080002e14 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e14:	7139                	add	sp,sp,-64
    80002e16:	fc06                	sd	ra,56(sp)
    80002e18:	f822                	sd	s0,48(sp)
    80002e1a:	f426                	sd	s1,40(sp)
    80002e1c:	f04a                	sd	s2,32(sp)
    80002e1e:	ec4e                	sd	s3,24(sp)
    80002e20:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e22:	fcc40593          	add	a1,s0,-52
    80002e26:	4501                	li	a0,0
    80002e28:	00000097          	auipc	ra,0x0
    80002e2c:	e3e080e7          	jalr	-450(ra) # 80002c66 <argint>
  acquire(&tickslock);
    80002e30:	0018b517          	auipc	a0,0x18b
    80002e34:	14050513          	add	a0,a0,320 # 8018df70 <tickslock>
    80002e38:	ffffe097          	auipc	ra,0xffffe
    80002e3c:	d9a080e7          	jalr	-614(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002e40:	00006917          	auipc	s2,0x6
    80002e44:	c9092903          	lw	s2,-880(s2) # 80008ad0 <ticks>
  while(ticks - ticks0 < n){
    80002e48:	fcc42783          	lw	a5,-52(s0)
    80002e4c:	cf9d                	beqz	a5,80002e8a <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e4e:	0018b997          	auipc	s3,0x18b
    80002e52:	12298993          	add	s3,s3,290 # 8018df70 <tickslock>
    80002e56:	00006497          	auipc	s1,0x6
    80002e5a:	c7a48493          	add	s1,s1,-902 # 80008ad0 <ticks>
    if(killed(myproc())){
    80002e5e:	fffff097          	auipc	ra,0xfffff
    80002e62:	b98080e7          	jalr	-1128(ra) # 800019f6 <myproc>
    80002e66:	fffff097          	auipc	ra,0xfffff
    80002e6a:	5e6080e7          	jalr	1510(ra) # 8000244c <killed>
    80002e6e:	ed15                	bnez	a0,80002eaa <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e70:	85ce                	mv	a1,s3
    80002e72:	8526                	mv	a0,s1
    80002e74:	fffff097          	auipc	ra,0xfffff
    80002e78:	318080e7          	jalr	792(ra) # 8000218c <sleep>
  while(ticks - ticks0 < n){
    80002e7c:	409c                	lw	a5,0(s1)
    80002e7e:	412787bb          	subw	a5,a5,s2
    80002e82:	fcc42703          	lw	a4,-52(s0)
    80002e86:	fce7ece3          	bltu	a5,a4,80002e5e <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e8a:	0018b517          	auipc	a0,0x18b
    80002e8e:	0e650513          	add	a0,a0,230 # 8018df70 <tickslock>
    80002e92:	ffffe097          	auipc	ra,0xffffe
    80002e96:	df4080e7          	jalr	-524(ra) # 80000c86 <release>
  return 0;
    80002e9a:	4501                	li	a0,0
}
    80002e9c:	70e2                	ld	ra,56(sp)
    80002e9e:	7442                	ld	s0,48(sp)
    80002ea0:	74a2                	ld	s1,40(sp)
    80002ea2:	7902                	ld	s2,32(sp)
    80002ea4:	69e2                	ld	s3,24(sp)
    80002ea6:	6121                	add	sp,sp,64
    80002ea8:	8082                	ret
      release(&tickslock);
    80002eaa:	0018b517          	auipc	a0,0x18b
    80002eae:	0c650513          	add	a0,a0,198 # 8018df70 <tickslock>
    80002eb2:	ffffe097          	auipc	ra,0xffffe
    80002eb6:	dd4080e7          	jalr	-556(ra) # 80000c86 <release>
      return -1;
    80002eba:	557d                	li	a0,-1
    80002ebc:	b7c5                	j	80002e9c <sys_sleep+0x88>

0000000080002ebe <sys_kill>:

uint64
sys_kill(void)
{
    80002ebe:	1101                	add	sp,sp,-32
    80002ec0:	ec06                	sd	ra,24(sp)
    80002ec2:	e822                	sd	s0,16(sp)
    80002ec4:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002ec6:	fec40593          	add	a1,s0,-20
    80002eca:	4501                	li	a0,0
    80002ecc:	00000097          	auipc	ra,0x0
    80002ed0:	d9a080e7          	jalr	-614(ra) # 80002c66 <argint>
  return kill(pid);
    80002ed4:	fec42503          	lw	a0,-20(s0)
    80002ed8:	fffff097          	auipc	ra,0xfffff
    80002edc:	4ce080e7          	jalr	1230(ra) # 800023a6 <kill>
}
    80002ee0:	60e2                	ld	ra,24(sp)
    80002ee2:	6442                	ld	s0,16(sp)
    80002ee4:	6105                	add	sp,sp,32
    80002ee6:	8082                	ret

0000000080002ee8 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ee8:	1101                	add	sp,sp,-32
    80002eea:	ec06                	sd	ra,24(sp)
    80002eec:	e822                	sd	s0,16(sp)
    80002eee:	e426                	sd	s1,8(sp)
    80002ef0:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ef2:	0018b517          	auipc	a0,0x18b
    80002ef6:	07e50513          	add	a0,a0,126 # 8018df70 <tickslock>
    80002efa:	ffffe097          	auipc	ra,0xffffe
    80002efe:	cd8080e7          	jalr	-808(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002f02:	00006497          	auipc	s1,0x6
    80002f06:	bce4a483          	lw	s1,-1074(s1) # 80008ad0 <ticks>
  release(&tickslock);
    80002f0a:	0018b517          	auipc	a0,0x18b
    80002f0e:	06650513          	add	a0,a0,102 # 8018df70 <tickslock>
    80002f12:	ffffe097          	auipc	ra,0xffffe
    80002f16:	d74080e7          	jalr	-652(ra) # 80000c86 <release>
  return xticks;
}
    80002f1a:	02049513          	sll	a0,s1,0x20
    80002f1e:	9101                	srl	a0,a0,0x20
    80002f20:	60e2                	ld	ra,24(sp)
    80002f22:	6442                	ld	s0,16(sp)
    80002f24:	64a2                	ld	s1,8(sp)
    80002f26:	6105                	add	sp,sp,32
    80002f28:	8082                	ret

0000000080002f2a <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f2a:	7179                	add	sp,sp,-48
    80002f2c:	f406                	sd	ra,40(sp)
    80002f2e:	f022                	sd	s0,32(sp)
    80002f30:	ec26                	sd	s1,24(sp)
    80002f32:	e84a                	sd	s2,16(sp)
    80002f34:	e44e                	sd	s3,8(sp)
    80002f36:	e052                	sd	s4,0(sp)
    80002f38:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f3a:	00005597          	auipc	a1,0x5
    80002f3e:	61658593          	add	a1,a1,1558 # 80008550 <syscalls+0xb0>
    80002f42:	0018b517          	auipc	a0,0x18b
    80002f46:	04650513          	add	a0,a0,70 # 8018df88 <bcache>
    80002f4a:	ffffe097          	auipc	ra,0xffffe
    80002f4e:	bf8080e7          	jalr	-1032(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f52:	00193797          	auipc	a5,0x193
    80002f56:	03678793          	add	a5,a5,54 # 80195f88 <bcache+0x8000>
    80002f5a:	00193717          	auipc	a4,0x193
    80002f5e:	29670713          	add	a4,a4,662 # 801961f0 <bcache+0x8268>
    80002f62:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f66:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f6a:	0018b497          	auipc	s1,0x18b
    80002f6e:	03648493          	add	s1,s1,54 # 8018dfa0 <bcache+0x18>
    b->next = bcache.head.next;
    80002f72:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f74:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f76:	00005a17          	auipc	s4,0x5
    80002f7a:	5e2a0a13          	add	s4,s4,1506 # 80008558 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002f7e:	2b893783          	ld	a5,696(s2)
    80002f82:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f84:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f88:	85d2                	mv	a1,s4
    80002f8a:	01048513          	add	a0,s1,16
    80002f8e:	00001097          	auipc	ra,0x1
    80002f92:	496080e7          	jalr	1174(ra) # 80004424 <initsleeplock>
    bcache.head.next->prev = b;
    80002f96:	2b893783          	ld	a5,696(s2)
    80002f9a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f9c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002fa0:	45848493          	add	s1,s1,1112
    80002fa4:	fd349de3          	bne	s1,s3,80002f7e <binit+0x54>
  }
}
    80002fa8:	70a2                	ld	ra,40(sp)
    80002faa:	7402                	ld	s0,32(sp)
    80002fac:	64e2                	ld	s1,24(sp)
    80002fae:	6942                	ld	s2,16(sp)
    80002fb0:	69a2                	ld	s3,8(sp)
    80002fb2:	6a02                	ld	s4,0(sp)
    80002fb4:	6145                	add	sp,sp,48
    80002fb6:	8082                	ret

0000000080002fb8 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fb8:	7179                	add	sp,sp,-48
    80002fba:	f406                	sd	ra,40(sp)
    80002fbc:	f022                	sd	s0,32(sp)
    80002fbe:	ec26                	sd	s1,24(sp)
    80002fc0:	e84a                	sd	s2,16(sp)
    80002fc2:	e44e                	sd	s3,8(sp)
    80002fc4:	1800                	add	s0,sp,48
    80002fc6:	892a                	mv	s2,a0
    80002fc8:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fca:	0018b517          	auipc	a0,0x18b
    80002fce:	fbe50513          	add	a0,a0,-66 # 8018df88 <bcache>
    80002fd2:	ffffe097          	auipc	ra,0xffffe
    80002fd6:	c00080e7          	jalr	-1024(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fda:	00193497          	auipc	s1,0x193
    80002fde:	2664b483          	ld	s1,614(s1) # 80196240 <bcache+0x82b8>
    80002fe2:	00193797          	auipc	a5,0x193
    80002fe6:	20e78793          	add	a5,a5,526 # 801961f0 <bcache+0x8268>
    80002fea:	02f48f63          	beq	s1,a5,80003028 <bread+0x70>
    80002fee:	873e                	mv	a4,a5
    80002ff0:	a021                	j	80002ff8 <bread+0x40>
    80002ff2:	68a4                	ld	s1,80(s1)
    80002ff4:	02e48a63          	beq	s1,a4,80003028 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002ff8:	449c                	lw	a5,8(s1)
    80002ffa:	ff279ce3          	bne	a5,s2,80002ff2 <bread+0x3a>
    80002ffe:	44dc                	lw	a5,12(s1)
    80003000:	ff3799e3          	bne	a5,s3,80002ff2 <bread+0x3a>
      b->refcnt++;
    80003004:	40bc                	lw	a5,64(s1)
    80003006:	2785                	addw	a5,a5,1
    80003008:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000300a:	0018b517          	auipc	a0,0x18b
    8000300e:	f7e50513          	add	a0,a0,-130 # 8018df88 <bcache>
    80003012:	ffffe097          	auipc	ra,0xffffe
    80003016:	c74080e7          	jalr	-908(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    8000301a:	01048513          	add	a0,s1,16
    8000301e:	00001097          	auipc	ra,0x1
    80003022:	440080e7          	jalr	1088(ra) # 8000445e <acquiresleep>
      return b;
    80003026:	a8b9                	j	80003084 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003028:	00193497          	auipc	s1,0x193
    8000302c:	2104b483          	ld	s1,528(s1) # 80196238 <bcache+0x82b0>
    80003030:	00193797          	auipc	a5,0x193
    80003034:	1c078793          	add	a5,a5,448 # 801961f0 <bcache+0x8268>
    80003038:	00f48863          	beq	s1,a5,80003048 <bread+0x90>
    8000303c:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000303e:	40bc                	lw	a5,64(s1)
    80003040:	cf81                	beqz	a5,80003058 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003042:	64a4                	ld	s1,72(s1)
    80003044:	fee49de3          	bne	s1,a4,8000303e <bread+0x86>
  panic("bget: no buffers");
    80003048:	00005517          	auipc	a0,0x5
    8000304c:	51850513          	add	a0,a0,1304 # 80008560 <syscalls+0xc0>
    80003050:	ffffd097          	auipc	ra,0xffffd
    80003054:	4ec080e7          	jalr	1260(ra) # 8000053c <panic>
      b->dev = dev;
    80003058:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    8000305c:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80003060:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003064:	4785                	li	a5,1
    80003066:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003068:	0018b517          	auipc	a0,0x18b
    8000306c:	f2050513          	add	a0,a0,-224 # 8018df88 <bcache>
    80003070:	ffffe097          	auipc	ra,0xffffe
    80003074:	c16080e7          	jalr	-1002(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003078:	01048513          	add	a0,s1,16
    8000307c:	00001097          	auipc	ra,0x1
    80003080:	3e2080e7          	jalr	994(ra) # 8000445e <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003084:	409c                	lw	a5,0(s1)
    80003086:	cb89                	beqz	a5,80003098 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003088:	8526                	mv	a0,s1
    8000308a:	70a2                	ld	ra,40(sp)
    8000308c:	7402                	ld	s0,32(sp)
    8000308e:	64e2                	ld	s1,24(sp)
    80003090:	6942                	ld	s2,16(sp)
    80003092:	69a2                	ld	s3,8(sp)
    80003094:	6145                	add	sp,sp,48
    80003096:	8082                	ret
    virtio_disk_rw(b, 0);
    80003098:	4581                	li	a1,0
    8000309a:	8526                	mv	a0,s1
    8000309c:	00003097          	auipc	ra,0x3
    800030a0:	006080e7          	jalr	6(ra) # 800060a2 <virtio_disk_rw>
    b->valid = 1;
    800030a4:	4785                	li	a5,1
    800030a6:	c09c                	sw	a5,0(s1)
  return b;
    800030a8:	b7c5                	j	80003088 <bread+0xd0>

00000000800030aa <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800030aa:	1101                	add	sp,sp,-32
    800030ac:	ec06                	sd	ra,24(sp)
    800030ae:	e822                	sd	s0,16(sp)
    800030b0:	e426                	sd	s1,8(sp)
    800030b2:	1000                	add	s0,sp,32
    800030b4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030b6:	0541                	add	a0,a0,16
    800030b8:	00001097          	auipc	ra,0x1
    800030bc:	440080e7          	jalr	1088(ra) # 800044f8 <holdingsleep>
    800030c0:	cd01                	beqz	a0,800030d8 <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    800030c2:	4585                	li	a1,1
    800030c4:	8526                	mv	a0,s1
    800030c6:	00003097          	auipc	ra,0x3
    800030ca:	fdc080e7          	jalr	-36(ra) # 800060a2 <virtio_disk_rw>
}
    800030ce:	60e2                	ld	ra,24(sp)
    800030d0:	6442                	ld	s0,16(sp)
    800030d2:	64a2                	ld	s1,8(sp)
    800030d4:	6105                	add	sp,sp,32
    800030d6:	8082                	ret
    panic("bwrite");
    800030d8:	00005517          	auipc	a0,0x5
    800030dc:	4a050513          	add	a0,a0,1184 # 80008578 <syscalls+0xd8>
    800030e0:	ffffd097          	auipc	ra,0xffffd
    800030e4:	45c080e7          	jalr	1116(ra) # 8000053c <panic>

00000000800030e8 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030e8:	1101                	add	sp,sp,-32
    800030ea:	ec06                	sd	ra,24(sp)
    800030ec:	e822                	sd	s0,16(sp)
    800030ee:	e426                	sd	s1,8(sp)
    800030f0:	e04a                	sd	s2,0(sp)
    800030f2:	1000                	add	s0,sp,32
    800030f4:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030f6:	01050913          	add	s2,a0,16
    800030fa:	854a                	mv	a0,s2
    800030fc:	00001097          	auipc	ra,0x1
    80003100:	3fc080e7          	jalr	1020(ra) # 800044f8 <holdingsleep>
    80003104:	c925                	beqz	a0,80003174 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003106:	854a                	mv	a0,s2
    80003108:	00001097          	auipc	ra,0x1
    8000310c:	3ac080e7          	jalr	940(ra) # 800044b4 <releasesleep>

  acquire(&bcache.lock);
    80003110:	0018b517          	auipc	a0,0x18b
    80003114:	e7850513          	add	a0,a0,-392 # 8018df88 <bcache>
    80003118:	ffffe097          	auipc	ra,0xffffe
    8000311c:	aba080e7          	jalr	-1350(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003120:	40bc                	lw	a5,64(s1)
    80003122:	37fd                	addw	a5,a5,-1
    80003124:	0007871b          	sext.w	a4,a5
    80003128:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    8000312a:	e71d                	bnez	a4,80003158 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000312c:	68b8                	ld	a4,80(s1)
    8000312e:	64bc                	ld	a5,72(s1)
    80003130:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80003132:	68b8                	ld	a4,80(s1)
    80003134:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003136:	00193797          	auipc	a5,0x193
    8000313a:	e5278793          	add	a5,a5,-430 # 80195f88 <bcache+0x8000>
    8000313e:	2b87b703          	ld	a4,696(a5)
    80003142:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003144:	00193717          	auipc	a4,0x193
    80003148:	0ac70713          	add	a4,a4,172 # 801961f0 <bcache+0x8268>
    8000314c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000314e:	2b87b703          	ld	a4,696(a5)
    80003152:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003154:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003158:	0018b517          	auipc	a0,0x18b
    8000315c:	e3050513          	add	a0,a0,-464 # 8018df88 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	b26080e7          	jalr	-1242(ra) # 80000c86 <release>
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6902                	ld	s2,0(sp)
    80003170:	6105                	add	sp,sp,32
    80003172:	8082                	ret
    panic("brelse");
    80003174:	00005517          	auipc	a0,0x5
    80003178:	40c50513          	add	a0,a0,1036 # 80008580 <syscalls+0xe0>
    8000317c:	ffffd097          	auipc	ra,0xffffd
    80003180:	3c0080e7          	jalr	960(ra) # 8000053c <panic>

0000000080003184 <bpin>:

void
bpin(struct buf *b) {
    80003184:	1101                	add	sp,sp,-32
    80003186:	ec06                	sd	ra,24(sp)
    80003188:	e822                	sd	s0,16(sp)
    8000318a:	e426                	sd	s1,8(sp)
    8000318c:	1000                	add	s0,sp,32
    8000318e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003190:	0018b517          	auipc	a0,0x18b
    80003194:	df850513          	add	a0,a0,-520 # 8018df88 <bcache>
    80003198:	ffffe097          	auipc	ra,0xffffe
    8000319c:	a3a080e7          	jalr	-1478(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800031a0:	40bc                	lw	a5,64(s1)
    800031a2:	2785                	addw	a5,a5,1
    800031a4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031a6:	0018b517          	auipc	a0,0x18b
    800031aa:	de250513          	add	a0,a0,-542 # 8018df88 <bcache>
    800031ae:	ffffe097          	auipc	ra,0xffffe
    800031b2:	ad8080e7          	jalr	-1320(ra) # 80000c86 <release>
}
    800031b6:	60e2                	ld	ra,24(sp)
    800031b8:	6442                	ld	s0,16(sp)
    800031ba:	64a2                	ld	s1,8(sp)
    800031bc:	6105                	add	sp,sp,32
    800031be:	8082                	ret

00000000800031c0 <bunpin>:

void
bunpin(struct buf *b) {
    800031c0:	1101                	add	sp,sp,-32
    800031c2:	ec06                	sd	ra,24(sp)
    800031c4:	e822                	sd	s0,16(sp)
    800031c6:	e426                	sd	s1,8(sp)
    800031c8:	1000                	add	s0,sp,32
    800031ca:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031cc:	0018b517          	auipc	a0,0x18b
    800031d0:	dbc50513          	add	a0,a0,-580 # 8018df88 <bcache>
    800031d4:	ffffe097          	auipc	ra,0xffffe
    800031d8:	9fe080e7          	jalr	-1538(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031dc:	40bc                	lw	a5,64(s1)
    800031de:	37fd                	addw	a5,a5,-1
    800031e0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031e2:	0018b517          	auipc	a0,0x18b
    800031e6:	da650513          	add	a0,a0,-602 # 8018df88 <bcache>
    800031ea:	ffffe097          	auipc	ra,0xffffe
    800031ee:	a9c080e7          	jalr	-1380(ra) # 80000c86 <release>
}
    800031f2:	60e2                	ld	ra,24(sp)
    800031f4:	6442                	ld	s0,16(sp)
    800031f6:	64a2                	ld	s1,8(sp)
    800031f8:	6105                	add	sp,sp,32
    800031fa:	8082                	ret

00000000800031fc <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031fc:	1101                	add	sp,sp,-32
    800031fe:	ec06                	sd	ra,24(sp)
    80003200:	e822                	sd	s0,16(sp)
    80003202:	e426                	sd	s1,8(sp)
    80003204:	e04a                	sd	s2,0(sp)
    80003206:	1000                	add	s0,sp,32
    80003208:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000320a:	00d5d59b          	srlw	a1,a1,0xd
    8000320e:	00193797          	auipc	a5,0x193
    80003212:	4567a783          	lw	a5,1110(a5) # 80196664 <sb+0x1c>
    80003216:	9dbd                	addw	a1,a1,a5
    80003218:	00000097          	auipc	ra,0x0
    8000321c:	da0080e7          	jalr	-608(ra) # 80002fb8 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003220:	0074f713          	and	a4,s1,7
    80003224:	4785                	li	a5,1
    80003226:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000322a:	14ce                	sll	s1,s1,0x33
    8000322c:	90d9                	srl	s1,s1,0x36
    8000322e:	00950733          	add	a4,a0,s1
    80003232:	05874703          	lbu	a4,88(a4)
    80003236:	00e7f6b3          	and	a3,a5,a4
    8000323a:	c69d                	beqz	a3,80003268 <bfree+0x6c>
    8000323c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000323e:	94aa                	add	s1,s1,a0
    80003240:	fff7c793          	not	a5,a5
    80003244:	8f7d                	and	a4,a4,a5
    80003246:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000324a:	00001097          	auipc	ra,0x1
    8000324e:	0f6080e7          	jalr	246(ra) # 80004340 <log_write>
  brelse(bp);
    80003252:	854a                	mv	a0,s2
    80003254:	00000097          	auipc	ra,0x0
    80003258:	e94080e7          	jalr	-364(ra) # 800030e8 <brelse>
}
    8000325c:	60e2                	ld	ra,24(sp)
    8000325e:	6442                	ld	s0,16(sp)
    80003260:	64a2                	ld	s1,8(sp)
    80003262:	6902                	ld	s2,0(sp)
    80003264:	6105                	add	sp,sp,32
    80003266:	8082                	ret
    panic("freeing free block");
    80003268:	00005517          	auipc	a0,0x5
    8000326c:	32050513          	add	a0,a0,800 # 80008588 <syscalls+0xe8>
    80003270:	ffffd097          	auipc	ra,0xffffd
    80003274:	2cc080e7          	jalr	716(ra) # 8000053c <panic>

0000000080003278 <balloc>:
{
    80003278:	711d                	add	sp,sp,-96
    8000327a:	ec86                	sd	ra,88(sp)
    8000327c:	e8a2                	sd	s0,80(sp)
    8000327e:	e4a6                	sd	s1,72(sp)
    80003280:	e0ca                	sd	s2,64(sp)
    80003282:	fc4e                	sd	s3,56(sp)
    80003284:	f852                	sd	s4,48(sp)
    80003286:	f456                	sd	s5,40(sp)
    80003288:	f05a                	sd	s6,32(sp)
    8000328a:	ec5e                	sd	s7,24(sp)
    8000328c:	e862                	sd	s8,16(sp)
    8000328e:	e466                	sd	s9,8(sp)
    80003290:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003292:	00193797          	auipc	a5,0x193
    80003296:	3ba7a783          	lw	a5,954(a5) # 8019664c <sb+0x4>
    8000329a:	cff5                	beqz	a5,80003396 <balloc+0x11e>
    8000329c:	8baa                	mv	s7,a0
    8000329e:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800032a0:	00193b17          	auipc	s6,0x193
    800032a4:	3a8b0b13          	add	s6,s6,936 # 80196648 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032a8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800032aa:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032ac:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800032ae:	6c89                	lui	s9,0x2
    800032b0:	a061                	j	80003338 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800032b2:	97ca                	add	a5,a5,s2
    800032b4:	8e55                	or	a2,a2,a3
    800032b6:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032ba:	854a                	mv	a0,s2
    800032bc:	00001097          	auipc	ra,0x1
    800032c0:	084080e7          	jalr	132(ra) # 80004340 <log_write>
        brelse(bp);
    800032c4:	854a                	mv	a0,s2
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	e22080e7          	jalr	-478(ra) # 800030e8 <brelse>
  bp = bread(dev, bno);
    800032ce:	85a6                	mv	a1,s1
    800032d0:	855e                	mv	a0,s7
    800032d2:	00000097          	auipc	ra,0x0
    800032d6:	ce6080e7          	jalr	-794(ra) # 80002fb8 <bread>
    800032da:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032dc:	40000613          	li	a2,1024
    800032e0:	4581                	li	a1,0
    800032e2:	05850513          	add	a0,a0,88
    800032e6:	ffffe097          	auipc	ra,0xffffe
    800032ea:	9e8080e7          	jalr	-1560(ra) # 80000cce <memset>
  log_write(bp);
    800032ee:	854a                	mv	a0,s2
    800032f0:	00001097          	auipc	ra,0x1
    800032f4:	050080e7          	jalr	80(ra) # 80004340 <log_write>
  brelse(bp);
    800032f8:	854a                	mv	a0,s2
    800032fa:	00000097          	auipc	ra,0x0
    800032fe:	dee080e7          	jalr	-530(ra) # 800030e8 <brelse>
}
    80003302:	8526                	mv	a0,s1
    80003304:	60e6                	ld	ra,88(sp)
    80003306:	6446                	ld	s0,80(sp)
    80003308:	64a6                	ld	s1,72(sp)
    8000330a:	6906                	ld	s2,64(sp)
    8000330c:	79e2                	ld	s3,56(sp)
    8000330e:	7a42                	ld	s4,48(sp)
    80003310:	7aa2                	ld	s5,40(sp)
    80003312:	7b02                	ld	s6,32(sp)
    80003314:	6be2                	ld	s7,24(sp)
    80003316:	6c42                	ld	s8,16(sp)
    80003318:	6ca2                	ld	s9,8(sp)
    8000331a:	6125                	add	sp,sp,96
    8000331c:	8082                	ret
    brelse(bp);
    8000331e:	854a                	mv	a0,s2
    80003320:	00000097          	auipc	ra,0x0
    80003324:	dc8080e7          	jalr	-568(ra) # 800030e8 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003328:	015c87bb          	addw	a5,s9,s5
    8000332c:	00078a9b          	sext.w	s5,a5
    80003330:	004b2703          	lw	a4,4(s6)
    80003334:	06eaf163          	bgeu	s5,a4,80003396 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003338:	41fad79b          	sraw	a5,s5,0x1f
    8000333c:	0137d79b          	srlw	a5,a5,0x13
    80003340:	015787bb          	addw	a5,a5,s5
    80003344:	40d7d79b          	sraw	a5,a5,0xd
    80003348:	01cb2583          	lw	a1,28(s6)
    8000334c:	9dbd                	addw	a1,a1,a5
    8000334e:	855e                	mv	a0,s7
    80003350:	00000097          	auipc	ra,0x0
    80003354:	c68080e7          	jalr	-920(ra) # 80002fb8 <bread>
    80003358:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000335a:	004b2503          	lw	a0,4(s6)
    8000335e:	000a849b          	sext.w	s1,s5
    80003362:	8762                	mv	a4,s8
    80003364:	faa4fde3          	bgeu	s1,a0,8000331e <balloc+0xa6>
      m = 1 << (bi % 8);
    80003368:	00777693          	and	a3,a4,7
    8000336c:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80003370:	41f7579b          	sraw	a5,a4,0x1f
    80003374:	01d7d79b          	srlw	a5,a5,0x1d
    80003378:	9fb9                	addw	a5,a5,a4
    8000337a:	4037d79b          	sraw	a5,a5,0x3
    8000337e:	00f90633          	add	a2,s2,a5
    80003382:	05864603          	lbu	a2,88(a2)
    80003386:	00c6f5b3          	and	a1,a3,a2
    8000338a:	d585                	beqz	a1,800032b2 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000338c:	2705                	addw	a4,a4,1
    8000338e:	2485                	addw	s1,s1,1
    80003390:	fd471ae3          	bne	a4,s4,80003364 <balloc+0xec>
    80003394:	b769                	j	8000331e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003396:	00005517          	auipc	a0,0x5
    8000339a:	20a50513          	add	a0,a0,522 # 800085a0 <syscalls+0x100>
    8000339e:	ffffd097          	auipc	ra,0xffffd
    800033a2:	1e8080e7          	jalr	488(ra) # 80000586 <printf>
  return 0;
    800033a6:	4481                	li	s1,0
    800033a8:	bfa9                	j	80003302 <balloc+0x8a>

00000000800033aa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800033aa:	7179                	add	sp,sp,-48
    800033ac:	f406                	sd	ra,40(sp)
    800033ae:	f022                	sd	s0,32(sp)
    800033b0:	ec26                	sd	s1,24(sp)
    800033b2:	e84a                	sd	s2,16(sp)
    800033b4:	e44e                	sd	s3,8(sp)
    800033b6:	e052                	sd	s4,0(sp)
    800033b8:	1800                	add	s0,sp,48
    800033ba:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033bc:	47ad                	li	a5,11
    800033be:	02b7e863          	bltu	a5,a1,800033ee <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800033c2:	02059793          	sll	a5,a1,0x20
    800033c6:	01e7d593          	srl	a1,a5,0x1e
    800033ca:	00b504b3          	add	s1,a0,a1
    800033ce:	0504a903          	lw	s2,80(s1)
    800033d2:	06091e63          	bnez	s2,8000344e <bmap+0xa4>
      addr = balloc(ip->dev);
    800033d6:	4108                	lw	a0,0(a0)
    800033d8:	00000097          	auipc	ra,0x0
    800033dc:	ea0080e7          	jalr	-352(ra) # 80003278 <balloc>
    800033e0:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033e4:	06090563          	beqz	s2,8000344e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800033e8:	0524a823          	sw	s2,80(s1)
    800033ec:	a08d                	j	8000344e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033ee:	ff45849b          	addw	s1,a1,-12
    800033f2:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033f6:	0ff00793          	li	a5,255
    800033fa:	08e7e563          	bltu	a5,a4,80003484 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033fe:	08052903          	lw	s2,128(a0)
    80003402:	00091d63          	bnez	s2,8000341c <bmap+0x72>
      addr = balloc(ip->dev);
    80003406:	4108                	lw	a0,0(a0)
    80003408:	00000097          	auipc	ra,0x0
    8000340c:	e70080e7          	jalr	-400(ra) # 80003278 <balloc>
    80003410:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003414:	02090d63          	beqz	s2,8000344e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003418:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000341c:	85ca                	mv	a1,s2
    8000341e:	0009a503          	lw	a0,0(s3)
    80003422:	00000097          	auipc	ra,0x0
    80003426:	b96080e7          	jalr	-1130(ra) # 80002fb8 <bread>
    8000342a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000342c:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    80003430:	02049713          	sll	a4,s1,0x20
    80003434:	01e75593          	srl	a1,a4,0x1e
    80003438:	00b784b3          	add	s1,a5,a1
    8000343c:	0004a903          	lw	s2,0(s1)
    80003440:	02090063          	beqz	s2,80003460 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003444:	8552                	mv	a0,s4
    80003446:	00000097          	auipc	ra,0x0
    8000344a:	ca2080e7          	jalr	-862(ra) # 800030e8 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000344e:	854a                	mv	a0,s2
    80003450:	70a2                	ld	ra,40(sp)
    80003452:	7402                	ld	s0,32(sp)
    80003454:	64e2                	ld	s1,24(sp)
    80003456:	6942                	ld	s2,16(sp)
    80003458:	69a2                	ld	s3,8(sp)
    8000345a:	6a02                	ld	s4,0(sp)
    8000345c:	6145                	add	sp,sp,48
    8000345e:	8082                	ret
      addr = balloc(ip->dev);
    80003460:	0009a503          	lw	a0,0(s3)
    80003464:	00000097          	auipc	ra,0x0
    80003468:	e14080e7          	jalr	-492(ra) # 80003278 <balloc>
    8000346c:	0005091b          	sext.w	s2,a0
      if(addr){
    80003470:	fc090ae3          	beqz	s2,80003444 <bmap+0x9a>
        a[bn] = addr;
    80003474:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003478:	8552                	mv	a0,s4
    8000347a:	00001097          	auipc	ra,0x1
    8000347e:	ec6080e7          	jalr	-314(ra) # 80004340 <log_write>
    80003482:	b7c9                	j	80003444 <bmap+0x9a>
  panic("bmap: out of range");
    80003484:	00005517          	auipc	a0,0x5
    80003488:	13450513          	add	a0,a0,308 # 800085b8 <syscalls+0x118>
    8000348c:	ffffd097          	auipc	ra,0xffffd
    80003490:	0b0080e7          	jalr	176(ra) # 8000053c <panic>

0000000080003494 <iget>:
{
    80003494:	7179                	add	sp,sp,-48
    80003496:	f406                	sd	ra,40(sp)
    80003498:	f022                	sd	s0,32(sp)
    8000349a:	ec26                	sd	s1,24(sp)
    8000349c:	e84a                	sd	s2,16(sp)
    8000349e:	e44e                	sd	s3,8(sp)
    800034a0:	e052                	sd	s4,0(sp)
    800034a2:	1800                	add	s0,sp,48
    800034a4:	89aa                	mv	s3,a0
    800034a6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800034a8:	00193517          	auipc	a0,0x193
    800034ac:	1c850513          	add	a0,a0,456 # 80196670 <itable>
    800034b0:	ffffd097          	auipc	ra,0xffffd
    800034b4:	722080e7          	jalr	1826(ra) # 80000bd2 <acquire>
  empty = 0;
    800034b8:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034ba:	00193497          	auipc	s1,0x193
    800034be:	1ce48493          	add	s1,s1,462 # 80196688 <itable+0x18>
    800034c2:	00195697          	auipc	a3,0x195
    800034c6:	c5668693          	add	a3,a3,-938 # 80198118 <log>
    800034ca:	a039                	j	800034d8 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034cc:	02090b63          	beqz	s2,80003502 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034d0:	08848493          	add	s1,s1,136
    800034d4:	02d48a63          	beq	s1,a3,80003508 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034d8:	449c                	lw	a5,8(s1)
    800034da:	fef059e3          	blez	a5,800034cc <iget+0x38>
    800034de:	4098                	lw	a4,0(s1)
    800034e0:	ff3716e3          	bne	a4,s3,800034cc <iget+0x38>
    800034e4:	40d8                	lw	a4,4(s1)
    800034e6:	ff4713e3          	bne	a4,s4,800034cc <iget+0x38>
      ip->ref++;
    800034ea:	2785                	addw	a5,a5,1
    800034ec:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034ee:	00193517          	auipc	a0,0x193
    800034f2:	18250513          	add	a0,a0,386 # 80196670 <itable>
    800034f6:	ffffd097          	auipc	ra,0xffffd
    800034fa:	790080e7          	jalr	1936(ra) # 80000c86 <release>
      return ip;
    800034fe:	8926                	mv	s2,s1
    80003500:	a03d                	j	8000352e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003502:	f7f9                	bnez	a5,800034d0 <iget+0x3c>
    80003504:	8926                	mv	s2,s1
    80003506:	b7e9                	j	800034d0 <iget+0x3c>
  if(empty == 0)
    80003508:	02090c63          	beqz	s2,80003540 <iget+0xac>
  ip->dev = dev;
    8000350c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003510:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003514:	4785                	li	a5,1
    80003516:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000351a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000351e:	00193517          	auipc	a0,0x193
    80003522:	15250513          	add	a0,a0,338 # 80196670 <itable>
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	760080e7          	jalr	1888(ra) # 80000c86 <release>
}
    8000352e:	854a                	mv	a0,s2
    80003530:	70a2                	ld	ra,40(sp)
    80003532:	7402                	ld	s0,32(sp)
    80003534:	64e2                	ld	s1,24(sp)
    80003536:	6942                	ld	s2,16(sp)
    80003538:	69a2                	ld	s3,8(sp)
    8000353a:	6a02                	ld	s4,0(sp)
    8000353c:	6145                	add	sp,sp,48
    8000353e:	8082                	ret
    panic("iget: no inodes");
    80003540:	00005517          	auipc	a0,0x5
    80003544:	09050513          	add	a0,a0,144 # 800085d0 <syscalls+0x130>
    80003548:	ffffd097          	auipc	ra,0xffffd
    8000354c:	ff4080e7          	jalr	-12(ra) # 8000053c <panic>

0000000080003550 <fsinit>:
fsinit(int dev) {
    80003550:	7179                	add	sp,sp,-48
    80003552:	f406                	sd	ra,40(sp)
    80003554:	f022                	sd	s0,32(sp)
    80003556:	ec26                	sd	s1,24(sp)
    80003558:	e84a                	sd	s2,16(sp)
    8000355a:	e44e                	sd	s3,8(sp)
    8000355c:	1800                	add	s0,sp,48
    8000355e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003560:	4585                	li	a1,1
    80003562:	00000097          	auipc	ra,0x0
    80003566:	a56080e7          	jalr	-1450(ra) # 80002fb8 <bread>
    8000356a:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    8000356c:	00193997          	auipc	s3,0x193
    80003570:	0dc98993          	add	s3,s3,220 # 80196648 <sb>
    80003574:	02800613          	li	a2,40
    80003578:	05850593          	add	a1,a0,88
    8000357c:	854e                	mv	a0,s3
    8000357e:	ffffd097          	auipc	ra,0xffffd
    80003582:	7ac080e7          	jalr	1964(ra) # 80000d2a <memmove>
  brelse(bp);
    80003586:	8526                	mv	a0,s1
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	b60080e7          	jalr	-1184(ra) # 800030e8 <brelse>
  if(sb.magic != FSMAGIC)
    80003590:	0009a703          	lw	a4,0(s3)
    80003594:	102037b7          	lui	a5,0x10203
    80003598:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    8000359c:	02f71263          	bne	a4,a5,800035c0 <fsinit+0x70>
  initlog(dev, &sb);
    800035a0:	00193597          	auipc	a1,0x193
    800035a4:	0a858593          	add	a1,a1,168 # 80196648 <sb>
    800035a8:	854a                	mv	a0,s2
    800035aa:	00001097          	auipc	ra,0x1
    800035ae:	b2c080e7          	jalr	-1236(ra) # 800040d6 <initlog>
}
    800035b2:	70a2                	ld	ra,40(sp)
    800035b4:	7402                	ld	s0,32(sp)
    800035b6:	64e2                	ld	s1,24(sp)
    800035b8:	6942                	ld	s2,16(sp)
    800035ba:	69a2                	ld	s3,8(sp)
    800035bc:	6145                	add	sp,sp,48
    800035be:	8082                	ret
    panic("invalid file system");
    800035c0:	00005517          	auipc	a0,0x5
    800035c4:	02050513          	add	a0,a0,32 # 800085e0 <syscalls+0x140>
    800035c8:	ffffd097          	auipc	ra,0xffffd
    800035cc:	f74080e7          	jalr	-140(ra) # 8000053c <panic>

00000000800035d0 <iinit>:
{
    800035d0:	7179                	add	sp,sp,-48
    800035d2:	f406                	sd	ra,40(sp)
    800035d4:	f022                	sd	s0,32(sp)
    800035d6:	ec26                	sd	s1,24(sp)
    800035d8:	e84a                	sd	s2,16(sp)
    800035da:	e44e                	sd	s3,8(sp)
    800035dc:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800035de:	00005597          	auipc	a1,0x5
    800035e2:	01a58593          	add	a1,a1,26 # 800085f8 <syscalls+0x158>
    800035e6:	00193517          	auipc	a0,0x193
    800035ea:	08a50513          	add	a0,a0,138 # 80196670 <itable>
    800035ee:	ffffd097          	auipc	ra,0xffffd
    800035f2:	554080e7          	jalr	1364(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035f6:	00193497          	auipc	s1,0x193
    800035fa:	0a248493          	add	s1,s1,162 # 80196698 <itable+0x28>
    800035fe:	00195997          	auipc	s3,0x195
    80003602:	b2a98993          	add	s3,s3,-1238 # 80198128 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003606:	00005917          	auipc	s2,0x5
    8000360a:	ffa90913          	add	s2,s2,-6 # 80008600 <syscalls+0x160>
    8000360e:	85ca                	mv	a1,s2
    80003610:	8526                	mv	a0,s1
    80003612:	00001097          	auipc	ra,0x1
    80003616:	e12080e7          	jalr	-494(ra) # 80004424 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000361a:	08848493          	add	s1,s1,136
    8000361e:	ff3498e3          	bne	s1,s3,8000360e <iinit+0x3e>
}
    80003622:	70a2                	ld	ra,40(sp)
    80003624:	7402                	ld	s0,32(sp)
    80003626:	64e2                	ld	s1,24(sp)
    80003628:	6942                	ld	s2,16(sp)
    8000362a:	69a2                	ld	s3,8(sp)
    8000362c:	6145                	add	sp,sp,48
    8000362e:	8082                	ret

0000000080003630 <ialloc>:
{
    80003630:	7139                	add	sp,sp,-64
    80003632:	fc06                	sd	ra,56(sp)
    80003634:	f822                	sd	s0,48(sp)
    80003636:	f426                	sd	s1,40(sp)
    80003638:	f04a                	sd	s2,32(sp)
    8000363a:	ec4e                	sd	s3,24(sp)
    8000363c:	e852                	sd	s4,16(sp)
    8000363e:	e456                	sd	s5,8(sp)
    80003640:	e05a                	sd	s6,0(sp)
    80003642:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003644:	00193717          	auipc	a4,0x193
    80003648:	01072703          	lw	a4,16(a4) # 80196654 <sb+0xc>
    8000364c:	4785                	li	a5,1
    8000364e:	04e7f863          	bgeu	a5,a4,8000369e <ialloc+0x6e>
    80003652:	8aaa                	mv	s5,a0
    80003654:	8b2e                	mv	s6,a1
    80003656:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003658:	00193a17          	auipc	s4,0x193
    8000365c:	ff0a0a13          	add	s4,s4,-16 # 80196648 <sb>
    80003660:	00495593          	srl	a1,s2,0x4
    80003664:	018a2783          	lw	a5,24(s4)
    80003668:	9dbd                	addw	a1,a1,a5
    8000366a:	8556                	mv	a0,s5
    8000366c:	00000097          	auipc	ra,0x0
    80003670:	94c080e7          	jalr	-1716(ra) # 80002fb8 <bread>
    80003674:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003676:	05850993          	add	s3,a0,88
    8000367a:	00f97793          	and	a5,s2,15
    8000367e:	079a                	sll	a5,a5,0x6
    80003680:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003682:	00099783          	lh	a5,0(s3)
    80003686:	cf9d                	beqz	a5,800036c4 <ialloc+0x94>
    brelse(bp);
    80003688:	00000097          	auipc	ra,0x0
    8000368c:	a60080e7          	jalr	-1440(ra) # 800030e8 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003690:	0905                	add	s2,s2,1
    80003692:	00ca2703          	lw	a4,12(s4)
    80003696:	0009079b          	sext.w	a5,s2
    8000369a:	fce7e3e3          	bltu	a5,a4,80003660 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000369e:	00005517          	auipc	a0,0x5
    800036a2:	f6a50513          	add	a0,a0,-150 # 80008608 <syscalls+0x168>
    800036a6:	ffffd097          	auipc	ra,0xffffd
    800036aa:	ee0080e7          	jalr	-288(ra) # 80000586 <printf>
  return 0;
    800036ae:	4501                	li	a0,0
}
    800036b0:	70e2                	ld	ra,56(sp)
    800036b2:	7442                	ld	s0,48(sp)
    800036b4:	74a2                	ld	s1,40(sp)
    800036b6:	7902                	ld	s2,32(sp)
    800036b8:	69e2                	ld	s3,24(sp)
    800036ba:	6a42                	ld	s4,16(sp)
    800036bc:	6aa2                	ld	s5,8(sp)
    800036be:	6b02                	ld	s6,0(sp)
    800036c0:	6121                	add	sp,sp,64
    800036c2:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036c4:	04000613          	li	a2,64
    800036c8:	4581                	li	a1,0
    800036ca:	854e                	mv	a0,s3
    800036cc:	ffffd097          	auipc	ra,0xffffd
    800036d0:	602080e7          	jalr	1538(ra) # 80000cce <memset>
      dip->type = type;
    800036d4:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036d8:	8526                	mv	a0,s1
    800036da:	00001097          	auipc	ra,0x1
    800036de:	c66080e7          	jalr	-922(ra) # 80004340 <log_write>
      brelse(bp);
    800036e2:	8526                	mv	a0,s1
    800036e4:	00000097          	auipc	ra,0x0
    800036e8:	a04080e7          	jalr	-1532(ra) # 800030e8 <brelse>
      return iget(dev, inum);
    800036ec:	0009059b          	sext.w	a1,s2
    800036f0:	8556                	mv	a0,s5
    800036f2:	00000097          	auipc	ra,0x0
    800036f6:	da2080e7          	jalr	-606(ra) # 80003494 <iget>
    800036fa:	bf5d                	j	800036b0 <ialloc+0x80>

00000000800036fc <iupdate>:
{
    800036fc:	1101                	add	sp,sp,-32
    800036fe:	ec06                	sd	ra,24(sp)
    80003700:	e822                	sd	s0,16(sp)
    80003702:	e426                	sd	s1,8(sp)
    80003704:	e04a                	sd	s2,0(sp)
    80003706:	1000                	add	s0,sp,32
    80003708:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000370a:	415c                	lw	a5,4(a0)
    8000370c:	0047d79b          	srlw	a5,a5,0x4
    80003710:	00193597          	auipc	a1,0x193
    80003714:	f505a583          	lw	a1,-176(a1) # 80196660 <sb+0x18>
    80003718:	9dbd                	addw	a1,a1,a5
    8000371a:	4108                	lw	a0,0(a0)
    8000371c:	00000097          	auipc	ra,0x0
    80003720:	89c080e7          	jalr	-1892(ra) # 80002fb8 <bread>
    80003724:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003726:	05850793          	add	a5,a0,88
    8000372a:	40d8                	lw	a4,4(s1)
    8000372c:	8b3d                	and	a4,a4,15
    8000372e:	071a                	sll	a4,a4,0x6
    80003730:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003732:	04449703          	lh	a4,68(s1)
    80003736:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000373a:	04649703          	lh	a4,70(s1)
    8000373e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003742:	04849703          	lh	a4,72(s1)
    80003746:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000374a:	04a49703          	lh	a4,74(s1)
    8000374e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003752:	44f8                	lw	a4,76(s1)
    80003754:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003756:	03400613          	li	a2,52
    8000375a:	05048593          	add	a1,s1,80
    8000375e:	00c78513          	add	a0,a5,12
    80003762:	ffffd097          	auipc	ra,0xffffd
    80003766:	5c8080e7          	jalr	1480(ra) # 80000d2a <memmove>
  log_write(bp);
    8000376a:	854a                	mv	a0,s2
    8000376c:	00001097          	auipc	ra,0x1
    80003770:	bd4080e7          	jalr	-1068(ra) # 80004340 <log_write>
  brelse(bp);
    80003774:	854a                	mv	a0,s2
    80003776:	00000097          	auipc	ra,0x0
    8000377a:	972080e7          	jalr	-1678(ra) # 800030e8 <brelse>
}
    8000377e:	60e2                	ld	ra,24(sp)
    80003780:	6442                	ld	s0,16(sp)
    80003782:	64a2                	ld	s1,8(sp)
    80003784:	6902                	ld	s2,0(sp)
    80003786:	6105                	add	sp,sp,32
    80003788:	8082                	ret

000000008000378a <idup>:
{
    8000378a:	1101                	add	sp,sp,-32
    8000378c:	ec06                	sd	ra,24(sp)
    8000378e:	e822                	sd	s0,16(sp)
    80003790:	e426                	sd	s1,8(sp)
    80003792:	1000                	add	s0,sp,32
    80003794:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003796:	00193517          	auipc	a0,0x193
    8000379a:	eda50513          	add	a0,a0,-294 # 80196670 <itable>
    8000379e:	ffffd097          	auipc	ra,0xffffd
    800037a2:	434080e7          	jalr	1076(ra) # 80000bd2 <acquire>
  ip->ref++;
    800037a6:	449c                	lw	a5,8(s1)
    800037a8:	2785                	addw	a5,a5,1
    800037aa:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800037ac:	00193517          	auipc	a0,0x193
    800037b0:	ec450513          	add	a0,a0,-316 # 80196670 <itable>
    800037b4:	ffffd097          	auipc	ra,0xffffd
    800037b8:	4d2080e7          	jalr	1234(ra) # 80000c86 <release>
}
    800037bc:	8526                	mv	a0,s1
    800037be:	60e2                	ld	ra,24(sp)
    800037c0:	6442                	ld	s0,16(sp)
    800037c2:	64a2                	ld	s1,8(sp)
    800037c4:	6105                	add	sp,sp,32
    800037c6:	8082                	ret

00000000800037c8 <ilock>:
{
    800037c8:	1101                	add	sp,sp,-32
    800037ca:	ec06                	sd	ra,24(sp)
    800037cc:	e822                	sd	s0,16(sp)
    800037ce:	e426                	sd	s1,8(sp)
    800037d0:	e04a                	sd	s2,0(sp)
    800037d2:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037d4:	c115                	beqz	a0,800037f8 <ilock+0x30>
    800037d6:	84aa                	mv	s1,a0
    800037d8:	451c                	lw	a5,8(a0)
    800037da:	00f05f63          	blez	a5,800037f8 <ilock+0x30>
  acquiresleep(&ip->lock);
    800037de:	0541                	add	a0,a0,16
    800037e0:	00001097          	auipc	ra,0x1
    800037e4:	c7e080e7          	jalr	-898(ra) # 8000445e <acquiresleep>
  if(ip->valid == 0){
    800037e8:	40bc                	lw	a5,64(s1)
    800037ea:	cf99                	beqz	a5,80003808 <ilock+0x40>
}
    800037ec:	60e2                	ld	ra,24(sp)
    800037ee:	6442                	ld	s0,16(sp)
    800037f0:	64a2                	ld	s1,8(sp)
    800037f2:	6902                	ld	s2,0(sp)
    800037f4:	6105                	add	sp,sp,32
    800037f6:	8082                	ret
    panic("ilock");
    800037f8:	00005517          	auipc	a0,0x5
    800037fc:	e2850513          	add	a0,a0,-472 # 80008620 <syscalls+0x180>
    80003800:	ffffd097          	auipc	ra,0xffffd
    80003804:	d3c080e7          	jalr	-708(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003808:	40dc                	lw	a5,4(s1)
    8000380a:	0047d79b          	srlw	a5,a5,0x4
    8000380e:	00193597          	auipc	a1,0x193
    80003812:	e525a583          	lw	a1,-430(a1) # 80196660 <sb+0x18>
    80003816:	9dbd                	addw	a1,a1,a5
    80003818:	4088                	lw	a0,0(s1)
    8000381a:	fffff097          	auipc	ra,0xfffff
    8000381e:	79e080e7          	jalr	1950(ra) # 80002fb8 <bread>
    80003822:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003824:	05850593          	add	a1,a0,88
    80003828:	40dc                	lw	a5,4(s1)
    8000382a:	8bbd                	and	a5,a5,15
    8000382c:	079a                	sll	a5,a5,0x6
    8000382e:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003830:	00059783          	lh	a5,0(a1)
    80003834:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003838:	00259783          	lh	a5,2(a1)
    8000383c:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003840:	00459783          	lh	a5,4(a1)
    80003844:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003848:	00659783          	lh	a5,6(a1)
    8000384c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003850:	459c                	lw	a5,8(a1)
    80003852:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003854:	03400613          	li	a2,52
    80003858:	05b1                	add	a1,a1,12
    8000385a:	05048513          	add	a0,s1,80
    8000385e:	ffffd097          	auipc	ra,0xffffd
    80003862:	4cc080e7          	jalr	1228(ra) # 80000d2a <memmove>
    brelse(bp);
    80003866:	854a                	mv	a0,s2
    80003868:	00000097          	auipc	ra,0x0
    8000386c:	880080e7          	jalr	-1920(ra) # 800030e8 <brelse>
    ip->valid = 1;
    80003870:	4785                	li	a5,1
    80003872:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003874:	04449783          	lh	a5,68(s1)
    80003878:	fbb5                	bnez	a5,800037ec <ilock+0x24>
      panic("ilock: no type");
    8000387a:	00005517          	auipc	a0,0x5
    8000387e:	dae50513          	add	a0,a0,-594 # 80008628 <syscalls+0x188>
    80003882:	ffffd097          	auipc	ra,0xffffd
    80003886:	cba080e7          	jalr	-838(ra) # 8000053c <panic>

000000008000388a <iunlock>:
{
    8000388a:	1101                	add	sp,sp,-32
    8000388c:	ec06                	sd	ra,24(sp)
    8000388e:	e822                	sd	s0,16(sp)
    80003890:	e426                	sd	s1,8(sp)
    80003892:	e04a                	sd	s2,0(sp)
    80003894:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003896:	c905                	beqz	a0,800038c6 <iunlock+0x3c>
    80003898:	84aa                	mv	s1,a0
    8000389a:	01050913          	add	s2,a0,16
    8000389e:	854a                	mv	a0,s2
    800038a0:	00001097          	auipc	ra,0x1
    800038a4:	c58080e7          	jalr	-936(ra) # 800044f8 <holdingsleep>
    800038a8:	cd19                	beqz	a0,800038c6 <iunlock+0x3c>
    800038aa:	449c                	lw	a5,8(s1)
    800038ac:	00f05d63          	blez	a5,800038c6 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800038b0:	854a                	mv	a0,s2
    800038b2:	00001097          	auipc	ra,0x1
    800038b6:	c02080e7          	jalr	-1022(ra) # 800044b4 <releasesleep>
}
    800038ba:	60e2                	ld	ra,24(sp)
    800038bc:	6442                	ld	s0,16(sp)
    800038be:	64a2                	ld	s1,8(sp)
    800038c0:	6902                	ld	s2,0(sp)
    800038c2:	6105                	add	sp,sp,32
    800038c4:	8082                	ret
    panic("iunlock");
    800038c6:	00005517          	auipc	a0,0x5
    800038ca:	d7250513          	add	a0,a0,-654 # 80008638 <syscalls+0x198>
    800038ce:	ffffd097          	auipc	ra,0xffffd
    800038d2:	c6e080e7          	jalr	-914(ra) # 8000053c <panic>

00000000800038d6 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038d6:	7179                	add	sp,sp,-48
    800038d8:	f406                	sd	ra,40(sp)
    800038da:	f022                	sd	s0,32(sp)
    800038dc:	ec26                	sd	s1,24(sp)
    800038de:	e84a                	sd	s2,16(sp)
    800038e0:	e44e                	sd	s3,8(sp)
    800038e2:	e052                	sd	s4,0(sp)
    800038e4:	1800                	add	s0,sp,48
    800038e6:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038e8:	05050493          	add	s1,a0,80
    800038ec:	08050913          	add	s2,a0,128
    800038f0:	a021                	j	800038f8 <itrunc+0x22>
    800038f2:	0491                	add	s1,s1,4
    800038f4:	01248d63          	beq	s1,s2,8000390e <itrunc+0x38>
    if(ip->addrs[i]){
    800038f8:	408c                	lw	a1,0(s1)
    800038fa:	dde5                	beqz	a1,800038f2 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038fc:	0009a503          	lw	a0,0(s3)
    80003900:	00000097          	auipc	ra,0x0
    80003904:	8fc080e7          	jalr	-1796(ra) # 800031fc <bfree>
      ip->addrs[i] = 0;
    80003908:	0004a023          	sw	zero,0(s1)
    8000390c:	b7dd                	j	800038f2 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000390e:	0809a583          	lw	a1,128(s3)
    80003912:	e185                	bnez	a1,80003932 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003914:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003918:	854e                	mv	a0,s3
    8000391a:	00000097          	auipc	ra,0x0
    8000391e:	de2080e7          	jalr	-542(ra) # 800036fc <iupdate>
}
    80003922:	70a2                	ld	ra,40(sp)
    80003924:	7402                	ld	s0,32(sp)
    80003926:	64e2                	ld	s1,24(sp)
    80003928:	6942                	ld	s2,16(sp)
    8000392a:	69a2                	ld	s3,8(sp)
    8000392c:	6a02                	ld	s4,0(sp)
    8000392e:	6145                	add	sp,sp,48
    80003930:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003932:	0009a503          	lw	a0,0(s3)
    80003936:	fffff097          	auipc	ra,0xfffff
    8000393a:	682080e7          	jalr	1666(ra) # 80002fb8 <bread>
    8000393e:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003940:	05850493          	add	s1,a0,88
    80003944:	45850913          	add	s2,a0,1112
    80003948:	a021                	j	80003950 <itrunc+0x7a>
    8000394a:	0491                	add	s1,s1,4
    8000394c:	01248b63          	beq	s1,s2,80003962 <itrunc+0x8c>
      if(a[j])
    80003950:	408c                	lw	a1,0(s1)
    80003952:	dde5                	beqz	a1,8000394a <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003954:	0009a503          	lw	a0,0(s3)
    80003958:	00000097          	auipc	ra,0x0
    8000395c:	8a4080e7          	jalr	-1884(ra) # 800031fc <bfree>
    80003960:	b7ed                	j	8000394a <itrunc+0x74>
    brelse(bp);
    80003962:	8552                	mv	a0,s4
    80003964:	fffff097          	auipc	ra,0xfffff
    80003968:	784080e7          	jalr	1924(ra) # 800030e8 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    8000396c:	0809a583          	lw	a1,128(s3)
    80003970:	0009a503          	lw	a0,0(s3)
    80003974:	00000097          	auipc	ra,0x0
    80003978:	888080e7          	jalr	-1912(ra) # 800031fc <bfree>
    ip->addrs[NDIRECT] = 0;
    8000397c:	0809a023          	sw	zero,128(s3)
    80003980:	bf51                	j	80003914 <itrunc+0x3e>

0000000080003982 <iput>:
{
    80003982:	1101                	add	sp,sp,-32
    80003984:	ec06                	sd	ra,24(sp)
    80003986:	e822                	sd	s0,16(sp)
    80003988:	e426                	sd	s1,8(sp)
    8000398a:	e04a                	sd	s2,0(sp)
    8000398c:	1000                	add	s0,sp,32
    8000398e:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003990:	00193517          	auipc	a0,0x193
    80003994:	ce050513          	add	a0,a0,-800 # 80196670 <itable>
    80003998:	ffffd097          	auipc	ra,0xffffd
    8000399c:	23a080e7          	jalr	570(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039a0:	4498                	lw	a4,8(s1)
    800039a2:	4785                	li	a5,1
    800039a4:	02f70363          	beq	a4,a5,800039ca <iput+0x48>
  ip->ref--;
    800039a8:	449c                	lw	a5,8(s1)
    800039aa:	37fd                	addw	a5,a5,-1
    800039ac:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800039ae:	00193517          	auipc	a0,0x193
    800039b2:	cc250513          	add	a0,a0,-830 # 80196670 <itable>
    800039b6:	ffffd097          	auipc	ra,0xffffd
    800039ba:	2d0080e7          	jalr	720(ra) # 80000c86 <release>
}
    800039be:	60e2                	ld	ra,24(sp)
    800039c0:	6442                	ld	s0,16(sp)
    800039c2:	64a2                	ld	s1,8(sp)
    800039c4:	6902                	ld	s2,0(sp)
    800039c6:	6105                	add	sp,sp,32
    800039c8:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039ca:	40bc                	lw	a5,64(s1)
    800039cc:	dff1                	beqz	a5,800039a8 <iput+0x26>
    800039ce:	04a49783          	lh	a5,74(s1)
    800039d2:	fbf9                	bnez	a5,800039a8 <iput+0x26>
    acquiresleep(&ip->lock);
    800039d4:	01048913          	add	s2,s1,16
    800039d8:	854a                	mv	a0,s2
    800039da:	00001097          	auipc	ra,0x1
    800039de:	a84080e7          	jalr	-1404(ra) # 8000445e <acquiresleep>
    release(&itable.lock);
    800039e2:	00193517          	auipc	a0,0x193
    800039e6:	c8e50513          	add	a0,a0,-882 # 80196670 <itable>
    800039ea:	ffffd097          	auipc	ra,0xffffd
    800039ee:	29c080e7          	jalr	668(ra) # 80000c86 <release>
    itrunc(ip);
    800039f2:	8526                	mv	a0,s1
    800039f4:	00000097          	auipc	ra,0x0
    800039f8:	ee2080e7          	jalr	-286(ra) # 800038d6 <itrunc>
    ip->type = 0;
    800039fc:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003a00:	8526                	mv	a0,s1
    80003a02:	00000097          	auipc	ra,0x0
    80003a06:	cfa080e7          	jalr	-774(ra) # 800036fc <iupdate>
    ip->valid = 0;
    80003a0a:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003a0e:	854a                	mv	a0,s2
    80003a10:	00001097          	auipc	ra,0x1
    80003a14:	aa4080e7          	jalr	-1372(ra) # 800044b4 <releasesleep>
    acquire(&itable.lock);
    80003a18:	00193517          	auipc	a0,0x193
    80003a1c:	c5850513          	add	a0,a0,-936 # 80196670 <itable>
    80003a20:	ffffd097          	auipc	ra,0xffffd
    80003a24:	1b2080e7          	jalr	434(ra) # 80000bd2 <acquire>
    80003a28:	b741                	j	800039a8 <iput+0x26>

0000000080003a2a <iunlockput>:
{
    80003a2a:	1101                	add	sp,sp,-32
    80003a2c:	ec06                	sd	ra,24(sp)
    80003a2e:	e822                	sd	s0,16(sp)
    80003a30:	e426                	sd	s1,8(sp)
    80003a32:	1000                	add	s0,sp,32
    80003a34:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a36:	00000097          	auipc	ra,0x0
    80003a3a:	e54080e7          	jalr	-428(ra) # 8000388a <iunlock>
  iput(ip);
    80003a3e:	8526                	mv	a0,s1
    80003a40:	00000097          	auipc	ra,0x0
    80003a44:	f42080e7          	jalr	-190(ra) # 80003982 <iput>
}
    80003a48:	60e2                	ld	ra,24(sp)
    80003a4a:	6442                	ld	s0,16(sp)
    80003a4c:	64a2                	ld	s1,8(sp)
    80003a4e:	6105                	add	sp,sp,32
    80003a50:	8082                	ret

0000000080003a52 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a52:	1141                	add	sp,sp,-16
    80003a54:	e422                	sd	s0,8(sp)
    80003a56:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003a58:	411c                	lw	a5,0(a0)
    80003a5a:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a5c:	415c                	lw	a5,4(a0)
    80003a5e:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a60:	04451783          	lh	a5,68(a0)
    80003a64:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a68:	04a51783          	lh	a5,74(a0)
    80003a6c:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a70:	04c56783          	lwu	a5,76(a0)
    80003a74:	e99c                	sd	a5,16(a1)
}
    80003a76:	6422                	ld	s0,8(sp)
    80003a78:	0141                	add	sp,sp,16
    80003a7a:	8082                	ret

0000000080003a7c <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a7c:	457c                	lw	a5,76(a0)
    80003a7e:	0ed7e963          	bltu	a5,a3,80003b70 <readi+0xf4>
{
    80003a82:	7159                	add	sp,sp,-112
    80003a84:	f486                	sd	ra,104(sp)
    80003a86:	f0a2                	sd	s0,96(sp)
    80003a88:	eca6                	sd	s1,88(sp)
    80003a8a:	e8ca                	sd	s2,80(sp)
    80003a8c:	e4ce                	sd	s3,72(sp)
    80003a8e:	e0d2                	sd	s4,64(sp)
    80003a90:	fc56                	sd	s5,56(sp)
    80003a92:	f85a                	sd	s6,48(sp)
    80003a94:	f45e                	sd	s7,40(sp)
    80003a96:	f062                	sd	s8,32(sp)
    80003a98:	ec66                	sd	s9,24(sp)
    80003a9a:	e86a                	sd	s10,16(sp)
    80003a9c:	e46e                	sd	s11,8(sp)
    80003a9e:	1880                	add	s0,sp,112
    80003aa0:	8b2a                	mv	s6,a0
    80003aa2:	8bae                	mv	s7,a1
    80003aa4:	8a32                	mv	s4,a2
    80003aa6:	84b6                	mv	s1,a3
    80003aa8:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003aaa:	9f35                	addw	a4,a4,a3
    return 0;
    80003aac:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003aae:	0ad76063          	bltu	a4,a3,80003b4e <readi+0xd2>
  if(off + n > ip->size)
    80003ab2:	00e7f463          	bgeu	a5,a4,80003aba <readi+0x3e>
    n = ip->size - off;
    80003ab6:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aba:	0a0a8963          	beqz	s5,80003b6c <readi+0xf0>
    80003abe:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ac0:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ac4:	5c7d                	li	s8,-1
    80003ac6:	a82d                	j	80003b00 <readi+0x84>
    80003ac8:	020d1d93          	sll	s11,s10,0x20
    80003acc:	020ddd93          	srl	s11,s11,0x20
    80003ad0:	05890613          	add	a2,s2,88
    80003ad4:	86ee                	mv	a3,s11
    80003ad6:	963a                	add	a2,a2,a4
    80003ad8:	85d2                	mv	a1,s4
    80003ada:	855e                	mv	a0,s7
    80003adc:	fffff097          	auipc	ra,0xfffff
    80003ae0:	acc080e7          	jalr	-1332(ra) # 800025a8 <either_copyout>
    80003ae4:	05850d63          	beq	a0,s8,80003b3e <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ae8:	854a                	mv	a0,s2
    80003aea:	fffff097          	auipc	ra,0xfffff
    80003aee:	5fe080e7          	jalr	1534(ra) # 800030e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003af2:	013d09bb          	addw	s3,s10,s3
    80003af6:	009d04bb          	addw	s1,s10,s1
    80003afa:	9a6e                	add	s4,s4,s11
    80003afc:	0559f763          	bgeu	s3,s5,80003b4a <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003b00:	00a4d59b          	srlw	a1,s1,0xa
    80003b04:	855a                	mv	a0,s6
    80003b06:	00000097          	auipc	ra,0x0
    80003b0a:	8a4080e7          	jalr	-1884(ra) # 800033aa <bmap>
    80003b0e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b12:	cd85                	beqz	a1,80003b4a <readi+0xce>
    bp = bread(ip->dev, addr);
    80003b14:	000b2503          	lw	a0,0(s6)
    80003b18:	fffff097          	auipc	ra,0xfffff
    80003b1c:	4a0080e7          	jalr	1184(ra) # 80002fb8 <bread>
    80003b20:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b22:	3ff4f713          	and	a4,s1,1023
    80003b26:	40ec87bb          	subw	a5,s9,a4
    80003b2a:	413a86bb          	subw	a3,s5,s3
    80003b2e:	8d3e                	mv	s10,a5
    80003b30:	2781                	sext.w	a5,a5
    80003b32:	0006861b          	sext.w	a2,a3
    80003b36:	f8f679e3          	bgeu	a2,a5,80003ac8 <readi+0x4c>
    80003b3a:	8d36                	mv	s10,a3
    80003b3c:	b771                	j	80003ac8 <readi+0x4c>
      brelse(bp);
    80003b3e:	854a                	mv	a0,s2
    80003b40:	fffff097          	auipc	ra,0xfffff
    80003b44:	5a8080e7          	jalr	1448(ra) # 800030e8 <brelse>
      tot = -1;
    80003b48:	59fd                	li	s3,-1
  }
  return tot;
    80003b4a:	0009851b          	sext.w	a0,s3
}
    80003b4e:	70a6                	ld	ra,104(sp)
    80003b50:	7406                	ld	s0,96(sp)
    80003b52:	64e6                	ld	s1,88(sp)
    80003b54:	6946                	ld	s2,80(sp)
    80003b56:	69a6                	ld	s3,72(sp)
    80003b58:	6a06                	ld	s4,64(sp)
    80003b5a:	7ae2                	ld	s5,56(sp)
    80003b5c:	7b42                	ld	s6,48(sp)
    80003b5e:	7ba2                	ld	s7,40(sp)
    80003b60:	7c02                	ld	s8,32(sp)
    80003b62:	6ce2                	ld	s9,24(sp)
    80003b64:	6d42                	ld	s10,16(sp)
    80003b66:	6da2                	ld	s11,8(sp)
    80003b68:	6165                	add	sp,sp,112
    80003b6a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b6c:	89d6                	mv	s3,s5
    80003b6e:	bff1                	j	80003b4a <readi+0xce>
    return 0;
    80003b70:	4501                	li	a0,0
}
    80003b72:	8082                	ret

0000000080003b74 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b74:	457c                	lw	a5,76(a0)
    80003b76:	10d7e863          	bltu	a5,a3,80003c86 <writei+0x112>
{
    80003b7a:	7159                	add	sp,sp,-112
    80003b7c:	f486                	sd	ra,104(sp)
    80003b7e:	f0a2                	sd	s0,96(sp)
    80003b80:	eca6                	sd	s1,88(sp)
    80003b82:	e8ca                	sd	s2,80(sp)
    80003b84:	e4ce                	sd	s3,72(sp)
    80003b86:	e0d2                	sd	s4,64(sp)
    80003b88:	fc56                	sd	s5,56(sp)
    80003b8a:	f85a                	sd	s6,48(sp)
    80003b8c:	f45e                	sd	s7,40(sp)
    80003b8e:	f062                	sd	s8,32(sp)
    80003b90:	ec66                	sd	s9,24(sp)
    80003b92:	e86a                	sd	s10,16(sp)
    80003b94:	e46e                	sd	s11,8(sp)
    80003b96:	1880                	add	s0,sp,112
    80003b98:	8aaa                	mv	s5,a0
    80003b9a:	8bae                	mv	s7,a1
    80003b9c:	8a32                	mv	s4,a2
    80003b9e:	8936                	mv	s2,a3
    80003ba0:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ba2:	00e687bb          	addw	a5,a3,a4
    80003ba6:	0ed7e263          	bltu	a5,a3,80003c8a <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003baa:	00043737          	lui	a4,0x43
    80003bae:	0ef76063          	bltu	a4,a5,80003c8e <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bb2:	0c0b0863          	beqz	s6,80003c82 <writei+0x10e>
    80003bb6:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003bb8:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003bbc:	5c7d                	li	s8,-1
    80003bbe:	a091                	j	80003c02 <writei+0x8e>
    80003bc0:	020d1d93          	sll	s11,s10,0x20
    80003bc4:	020ddd93          	srl	s11,s11,0x20
    80003bc8:	05848513          	add	a0,s1,88
    80003bcc:	86ee                	mv	a3,s11
    80003bce:	8652                	mv	a2,s4
    80003bd0:	85de                	mv	a1,s7
    80003bd2:	953a                	add	a0,a0,a4
    80003bd4:	fffff097          	auipc	ra,0xfffff
    80003bd8:	a2a080e7          	jalr	-1494(ra) # 800025fe <either_copyin>
    80003bdc:	07850263          	beq	a0,s8,80003c40 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003be0:	8526                	mv	a0,s1
    80003be2:	00000097          	auipc	ra,0x0
    80003be6:	75e080e7          	jalr	1886(ra) # 80004340 <log_write>
    brelse(bp);
    80003bea:	8526                	mv	a0,s1
    80003bec:	fffff097          	auipc	ra,0xfffff
    80003bf0:	4fc080e7          	jalr	1276(ra) # 800030e8 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bf4:	013d09bb          	addw	s3,s10,s3
    80003bf8:	012d093b          	addw	s2,s10,s2
    80003bfc:	9a6e                	add	s4,s4,s11
    80003bfe:	0569f663          	bgeu	s3,s6,80003c4a <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003c02:	00a9559b          	srlw	a1,s2,0xa
    80003c06:	8556                	mv	a0,s5
    80003c08:	fffff097          	auipc	ra,0xfffff
    80003c0c:	7a2080e7          	jalr	1954(ra) # 800033aa <bmap>
    80003c10:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c14:	c99d                	beqz	a1,80003c4a <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003c16:	000aa503          	lw	a0,0(s5)
    80003c1a:	fffff097          	auipc	ra,0xfffff
    80003c1e:	39e080e7          	jalr	926(ra) # 80002fb8 <bread>
    80003c22:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c24:	3ff97713          	and	a4,s2,1023
    80003c28:	40ec87bb          	subw	a5,s9,a4
    80003c2c:	413b06bb          	subw	a3,s6,s3
    80003c30:	8d3e                	mv	s10,a5
    80003c32:	2781                	sext.w	a5,a5
    80003c34:	0006861b          	sext.w	a2,a3
    80003c38:	f8f674e3          	bgeu	a2,a5,80003bc0 <writei+0x4c>
    80003c3c:	8d36                	mv	s10,a3
    80003c3e:	b749                	j	80003bc0 <writei+0x4c>
      brelse(bp);
    80003c40:	8526                	mv	a0,s1
    80003c42:	fffff097          	auipc	ra,0xfffff
    80003c46:	4a6080e7          	jalr	1190(ra) # 800030e8 <brelse>
  }

  if(off > ip->size)
    80003c4a:	04caa783          	lw	a5,76(s5)
    80003c4e:	0127f463          	bgeu	a5,s2,80003c56 <writei+0xe2>
    ip->size = off;
    80003c52:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c56:	8556                	mv	a0,s5
    80003c58:	00000097          	auipc	ra,0x0
    80003c5c:	aa4080e7          	jalr	-1372(ra) # 800036fc <iupdate>

  return tot;
    80003c60:	0009851b          	sext.w	a0,s3
}
    80003c64:	70a6                	ld	ra,104(sp)
    80003c66:	7406                	ld	s0,96(sp)
    80003c68:	64e6                	ld	s1,88(sp)
    80003c6a:	6946                	ld	s2,80(sp)
    80003c6c:	69a6                	ld	s3,72(sp)
    80003c6e:	6a06                	ld	s4,64(sp)
    80003c70:	7ae2                	ld	s5,56(sp)
    80003c72:	7b42                	ld	s6,48(sp)
    80003c74:	7ba2                	ld	s7,40(sp)
    80003c76:	7c02                	ld	s8,32(sp)
    80003c78:	6ce2                	ld	s9,24(sp)
    80003c7a:	6d42                	ld	s10,16(sp)
    80003c7c:	6da2                	ld	s11,8(sp)
    80003c7e:	6165                	add	sp,sp,112
    80003c80:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c82:	89da                	mv	s3,s6
    80003c84:	bfc9                	j	80003c56 <writei+0xe2>
    return -1;
    80003c86:	557d                	li	a0,-1
}
    80003c88:	8082                	ret
    return -1;
    80003c8a:	557d                	li	a0,-1
    80003c8c:	bfe1                	j	80003c64 <writei+0xf0>
    return -1;
    80003c8e:	557d                	li	a0,-1
    80003c90:	bfd1                	j	80003c64 <writei+0xf0>

0000000080003c92 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c92:	1141                	add	sp,sp,-16
    80003c94:	e406                	sd	ra,8(sp)
    80003c96:	e022                	sd	s0,0(sp)
    80003c98:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c9a:	4639                	li	a2,14
    80003c9c:	ffffd097          	auipc	ra,0xffffd
    80003ca0:	102080e7          	jalr	258(ra) # 80000d9e <strncmp>
}
    80003ca4:	60a2                	ld	ra,8(sp)
    80003ca6:	6402                	ld	s0,0(sp)
    80003ca8:	0141                	add	sp,sp,16
    80003caa:	8082                	ret

0000000080003cac <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003cac:	7139                	add	sp,sp,-64
    80003cae:	fc06                	sd	ra,56(sp)
    80003cb0:	f822                	sd	s0,48(sp)
    80003cb2:	f426                	sd	s1,40(sp)
    80003cb4:	f04a                	sd	s2,32(sp)
    80003cb6:	ec4e                	sd	s3,24(sp)
    80003cb8:	e852                	sd	s4,16(sp)
    80003cba:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003cbc:	04451703          	lh	a4,68(a0)
    80003cc0:	4785                	li	a5,1
    80003cc2:	00f71a63          	bne	a4,a5,80003cd6 <dirlookup+0x2a>
    80003cc6:	892a                	mv	s2,a0
    80003cc8:	89ae                	mv	s3,a1
    80003cca:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ccc:	457c                	lw	a5,76(a0)
    80003cce:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cd0:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cd2:	e79d                	bnez	a5,80003d00 <dirlookup+0x54>
    80003cd4:	a8a5                	j	80003d4c <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cd6:	00005517          	auipc	a0,0x5
    80003cda:	96a50513          	add	a0,a0,-1686 # 80008640 <syscalls+0x1a0>
    80003cde:	ffffd097          	auipc	ra,0xffffd
    80003ce2:	85e080e7          	jalr	-1954(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003ce6:	00005517          	auipc	a0,0x5
    80003cea:	97250513          	add	a0,a0,-1678 # 80008658 <syscalls+0x1b8>
    80003cee:	ffffd097          	auipc	ra,0xffffd
    80003cf2:	84e080e7          	jalr	-1970(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cf6:	24c1                	addw	s1,s1,16
    80003cf8:	04c92783          	lw	a5,76(s2)
    80003cfc:	04f4f763          	bgeu	s1,a5,80003d4a <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d00:	4741                	li	a4,16
    80003d02:	86a6                	mv	a3,s1
    80003d04:	fc040613          	add	a2,s0,-64
    80003d08:	4581                	li	a1,0
    80003d0a:	854a                	mv	a0,s2
    80003d0c:	00000097          	auipc	ra,0x0
    80003d10:	d70080e7          	jalr	-656(ra) # 80003a7c <readi>
    80003d14:	47c1                	li	a5,16
    80003d16:	fcf518e3          	bne	a0,a5,80003ce6 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d1a:	fc045783          	lhu	a5,-64(s0)
    80003d1e:	dfe1                	beqz	a5,80003cf6 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d20:	fc240593          	add	a1,s0,-62
    80003d24:	854e                	mv	a0,s3
    80003d26:	00000097          	auipc	ra,0x0
    80003d2a:	f6c080e7          	jalr	-148(ra) # 80003c92 <namecmp>
    80003d2e:	f561                	bnez	a0,80003cf6 <dirlookup+0x4a>
      if(poff)
    80003d30:	000a0463          	beqz	s4,80003d38 <dirlookup+0x8c>
        *poff = off;
    80003d34:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d38:	fc045583          	lhu	a1,-64(s0)
    80003d3c:	00092503          	lw	a0,0(s2)
    80003d40:	fffff097          	auipc	ra,0xfffff
    80003d44:	754080e7          	jalr	1876(ra) # 80003494 <iget>
    80003d48:	a011                	j	80003d4c <dirlookup+0xa0>
  return 0;
    80003d4a:	4501                	li	a0,0
}
    80003d4c:	70e2                	ld	ra,56(sp)
    80003d4e:	7442                	ld	s0,48(sp)
    80003d50:	74a2                	ld	s1,40(sp)
    80003d52:	7902                	ld	s2,32(sp)
    80003d54:	69e2                	ld	s3,24(sp)
    80003d56:	6a42                	ld	s4,16(sp)
    80003d58:	6121                	add	sp,sp,64
    80003d5a:	8082                	ret

0000000080003d5c <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d5c:	711d                	add	sp,sp,-96
    80003d5e:	ec86                	sd	ra,88(sp)
    80003d60:	e8a2                	sd	s0,80(sp)
    80003d62:	e4a6                	sd	s1,72(sp)
    80003d64:	e0ca                	sd	s2,64(sp)
    80003d66:	fc4e                	sd	s3,56(sp)
    80003d68:	f852                	sd	s4,48(sp)
    80003d6a:	f456                	sd	s5,40(sp)
    80003d6c:	f05a                	sd	s6,32(sp)
    80003d6e:	ec5e                	sd	s7,24(sp)
    80003d70:	e862                	sd	s8,16(sp)
    80003d72:	e466                	sd	s9,8(sp)
    80003d74:	1080                	add	s0,sp,96
    80003d76:	84aa                	mv	s1,a0
    80003d78:	8b2e                	mv	s6,a1
    80003d7a:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d7c:	00054703          	lbu	a4,0(a0)
    80003d80:	02f00793          	li	a5,47
    80003d84:	02f70263          	beq	a4,a5,80003da8 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d88:	ffffe097          	auipc	ra,0xffffe
    80003d8c:	c6e080e7          	jalr	-914(ra) # 800019f6 <myproc>
    80003d90:	15053503          	ld	a0,336(a0)
    80003d94:	00000097          	auipc	ra,0x0
    80003d98:	9f6080e7          	jalr	-1546(ra) # 8000378a <idup>
    80003d9c:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d9e:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003da2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003da4:	4b85                	li	s7,1
    80003da6:	a875                	j	80003e62 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003da8:	4585                	li	a1,1
    80003daa:	4505                	li	a0,1
    80003dac:	fffff097          	auipc	ra,0xfffff
    80003db0:	6e8080e7          	jalr	1768(ra) # 80003494 <iget>
    80003db4:	8a2a                	mv	s4,a0
    80003db6:	b7e5                	j	80003d9e <namex+0x42>
      iunlockput(ip);
    80003db8:	8552                	mv	a0,s4
    80003dba:	00000097          	auipc	ra,0x0
    80003dbe:	c70080e7          	jalr	-912(ra) # 80003a2a <iunlockput>
      return 0;
    80003dc2:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003dc4:	8552                	mv	a0,s4
    80003dc6:	60e6                	ld	ra,88(sp)
    80003dc8:	6446                	ld	s0,80(sp)
    80003dca:	64a6                	ld	s1,72(sp)
    80003dcc:	6906                	ld	s2,64(sp)
    80003dce:	79e2                	ld	s3,56(sp)
    80003dd0:	7a42                	ld	s4,48(sp)
    80003dd2:	7aa2                	ld	s5,40(sp)
    80003dd4:	7b02                	ld	s6,32(sp)
    80003dd6:	6be2                	ld	s7,24(sp)
    80003dd8:	6c42                	ld	s8,16(sp)
    80003dda:	6ca2                	ld	s9,8(sp)
    80003ddc:	6125                	add	sp,sp,96
    80003dde:	8082                	ret
      iunlock(ip);
    80003de0:	8552                	mv	a0,s4
    80003de2:	00000097          	auipc	ra,0x0
    80003de6:	aa8080e7          	jalr	-1368(ra) # 8000388a <iunlock>
      return ip;
    80003dea:	bfe9                	j	80003dc4 <namex+0x68>
      iunlockput(ip);
    80003dec:	8552                	mv	a0,s4
    80003dee:	00000097          	auipc	ra,0x0
    80003df2:	c3c080e7          	jalr	-964(ra) # 80003a2a <iunlockput>
      return 0;
    80003df6:	8a4e                	mv	s4,s3
    80003df8:	b7f1                	j	80003dc4 <namex+0x68>
  len = path - s;
    80003dfa:	40998633          	sub	a2,s3,s1
    80003dfe:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003e02:	099c5863          	bge	s8,s9,80003e92 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003e06:	4639                	li	a2,14
    80003e08:	85a6                	mv	a1,s1
    80003e0a:	8556                	mv	a0,s5
    80003e0c:	ffffd097          	auipc	ra,0xffffd
    80003e10:	f1e080e7          	jalr	-226(ra) # 80000d2a <memmove>
    80003e14:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e16:	0004c783          	lbu	a5,0(s1)
    80003e1a:	01279763          	bne	a5,s2,80003e28 <namex+0xcc>
    path++;
    80003e1e:	0485                	add	s1,s1,1
  while(*path == '/')
    80003e20:	0004c783          	lbu	a5,0(s1)
    80003e24:	ff278de3          	beq	a5,s2,80003e1e <namex+0xc2>
    ilock(ip);
    80003e28:	8552                	mv	a0,s4
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	99e080e7          	jalr	-1634(ra) # 800037c8 <ilock>
    if(ip->type != T_DIR){
    80003e32:	044a1783          	lh	a5,68(s4)
    80003e36:	f97791e3          	bne	a5,s7,80003db8 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e3a:	000b0563          	beqz	s6,80003e44 <namex+0xe8>
    80003e3e:	0004c783          	lbu	a5,0(s1)
    80003e42:	dfd9                	beqz	a5,80003de0 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e44:	4601                	li	a2,0
    80003e46:	85d6                	mv	a1,s5
    80003e48:	8552                	mv	a0,s4
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	e62080e7          	jalr	-414(ra) # 80003cac <dirlookup>
    80003e52:	89aa                	mv	s3,a0
    80003e54:	dd41                	beqz	a0,80003dec <namex+0x90>
    iunlockput(ip);
    80003e56:	8552                	mv	a0,s4
    80003e58:	00000097          	auipc	ra,0x0
    80003e5c:	bd2080e7          	jalr	-1070(ra) # 80003a2a <iunlockput>
    ip = next;
    80003e60:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e62:	0004c783          	lbu	a5,0(s1)
    80003e66:	01279763          	bne	a5,s2,80003e74 <namex+0x118>
    path++;
    80003e6a:	0485                	add	s1,s1,1
  while(*path == '/')
    80003e6c:	0004c783          	lbu	a5,0(s1)
    80003e70:	ff278de3          	beq	a5,s2,80003e6a <namex+0x10e>
  if(*path == 0)
    80003e74:	cb9d                	beqz	a5,80003eaa <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e76:	0004c783          	lbu	a5,0(s1)
    80003e7a:	89a6                	mv	s3,s1
  len = path - s;
    80003e7c:	4c81                	li	s9,0
    80003e7e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e80:	01278963          	beq	a5,s2,80003e92 <namex+0x136>
    80003e84:	dbbd                	beqz	a5,80003dfa <namex+0x9e>
    path++;
    80003e86:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e88:	0009c783          	lbu	a5,0(s3)
    80003e8c:	ff279ce3          	bne	a5,s2,80003e84 <namex+0x128>
    80003e90:	b7ad                	j	80003dfa <namex+0x9e>
    memmove(name, s, len);
    80003e92:	2601                	sext.w	a2,a2
    80003e94:	85a6                	mv	a1,s1
    80003e96:	8556                	mv	a0,s5
    80003e98:	ffffd097          	auipc	ra,0xffffd
    80003e9c:	e92080e7          	jalr	-366(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003ea0:	9cd6                	add	s9,s9,s5
    80003ea2:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003ea6:	84ce                	mv	s1,s3
    80003ea8:	b7bd                	j	80003e16 <namex+0xba>
  if(nameiparent){
    80003eaa:	f00b0de3          	beqz	s6,80003dc4 <namex+0x68>
    iput(ip);
    80003eae:	8552                	mv	a0,s4
    80003eb0:	00000097          	auipc	ra,0x0
    80003eb4:	ad2080e7          	jalr	-1326(ra) # 80003982 <iput>
    return 0;
    80003eb8:	4a01                	li	s4,0
    80003eba:	b729                	j	80003dc4 <namex+0x68>

0000000080003ebc <dirlink>:
{
    80003ebc:	7139                	add	sp,sp,-64
    80003ebe:	fc06                	sd	ra,56(sp)
    80003ec0:	f822                	sd	s0,48(sp)
    80003ec2:	f426                	sd	s1,40(sp)
    80003ec4:	f04a                	sd	s2,32(sp)
    80003ec6:	ec4e                	sd	s3,24(sp)
    80003ec8:	e852                	sd	s4,16(sp)
    80003eca:	0080                	add	s0,sp,64
    80003ecc:	892a                	mv	s2,a0
    80003ece:	8a2e                	mv	s4,a1
    80003ed0:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ed2:	4601                	li	a2,0
    80003ed4:	00000097          	auipc	ra,0x0
    80003ed8:	dd8080e7          	jalr	-552(ra) # 80003cac <dirlookup>
    80003edc:	e93d                	bnez	a0,80003f52 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ede:	04c92483          	lw	s1,76(s2)
    80003ee2:	c49d                	beqz	s1,80003f10 <dirlink+0x54>
    80003ee4:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ee6:	4741                	li	a4,16
    80003ee8:	86a6                	mv	a3,s1
    80003eea:	fc040613          	add	a2,s0,-64
    80003eee:	4581                	li	a1,0
    80003ef0:	854a                	mv	a0,s2
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	b8a080e7          	jalr	-1142(ra) # 80003a7c <readi>
    80003efa:	47c1                	li	a5,16
    80003efc:	06f51163          	bne	a0,a5,80003f5e <dirlink+0xa2>
    if(de.inum == 0)
    80003f00:	fc045783          	lhu	a5,-64(s0)
    80003f04:	c791                	beqz	a5,80003f10 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003f06:	24c1                	addw	s1,s1,16
    80003f08:	04c92783          	lw	a5,76(s2)
    80003f0c:	fcf4ede3          	bltu	s1,a5,80003ee6 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003f10:	4639                	li	a2,14
    80003f12:	85d2                	mv	a1,s4
    80003f14:	fc240513          	add	a0,s0,-62
    80003f18:	ffffd097          	auipc	ra,0xffffd
    80003f1c:	ec2080e7          	jalr	-318(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003f20:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f24:	4741                	li	a4,16
    80003f26:	86a6                	mv	a3,s1
    80003f28:	fc040613          	add	a2,s0,-64
    80003f2c:	4581                	li	a1,0
    80003f2e:	854a                	mv	a0,s2
    80003f30:	00000097          	auipc	ra,0x0
    80003f34:	c44080e7          	jalr	-956(ra) # 80003b74 <writei>
    80003f38:	1541                	add	a0,a0,-16
    80003f3a:	00a03533          	snez	a0,a0
    80003f3e:	40a00533          	neg	a0,a0
}
    80003f42:	70e2                	ld	ra,56(sp)
    80003f44:	7442                	ld	s0,48(sp)
    80003f46:	74a2                	ld	s1,40(sp)
    80003f48:	7902                	ld	s2,32(sp)
    80003f4a:	69e2                	ld	s3,24(sp)
    80003f4c:	6a42                	ld	s4,16(sp)
    80003f4e:	6121                	add	sp,sp,64
    80003f50:	8082                	ret
    iput(ip);
    80003f52:	00000097          	auipc	ra,0x0
    80003f56:	a30080e7          	jalr	-1488(ra) # 80003982 <iput>
    return -1;
    80003f5a:	557d                	li	a0,-1
    80003f5c:	b7dd                	j	80003f42 <dirlink+0x86>
      panic("dirlink read");
    80003f5e:	00004517          	auipc	a0,0x4
    80003f62:	70a50513          	add	a0,a0,1802 # 80008668 <syscalls+0x1c8>
    80003f66:	ffffc097          	auipc	ra,0xffffc
    80003f6a:	5d6080e7          	jalr	1494(ra) # 8000053c <panic>

0000000080003f6e <namei>:

struct inode*
namei(char *path)
{
    80003f6e:	1101                	add	sp,sp,-32
    80003f70:	ec06                	sd	ra,24(sp)
    80003f72:	e822                	sd	s0,16(sp)
    80003f74:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f76:	fe040613          	add	a2,s0,-32
    80003f7a:	4581                	li	a1,0
    80003f7c:	00000097          	auipc	ra,0x0
    80003f80:	de0080e7          	jalr	-544(ra) # 80003d5c <namex>
}
    80003f84:	60e2                	ld	ra,24(sp)
    80003f86:	6442                	ld	s0,16(sp)
    80003f88:	6105                	add	sp,sp,32
    80003f8a:	8082                	ret

0000000080003f8c <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f8c:	1141                	add	sp,sp,-16
    80003f8e:	e406                	sd	ra,8(sp)
    80003f90:	e022                	sd	s0,0(sp)
    80003f92:	0800                	add	s0,sp,16
    80003f94:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f96:	4585                	li	a1,1
    80003f98:	00000097          	auipc	ra,0x0
    80003f9c:	dc4080e7          	jalr	-572(ra) # 80003d5c <namex>
}
    80003fa0:	60a2                	ld	ra,8(sp)
    80003fa2:	6402                	ld	s0,0(sp)
    80003fa4:	0141                	add	sp,sp,16
    80003fa6:	8082                	ret

0000000080003fa8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003fa8:	1101                	add	sp,sp,-32
    80003faa:	ec06                	sd	ra,24(sp)
    80003fac:	e822                	sd	s0,16(sp)
    80003fae:	e426                	sd	s1,8(sp)
    80003fb0:	e04a                	sd	s2,0(sp)
    80003fb2:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fb4:	00194917          	auipc	s2,0x194
    80003fb8:	16490913          	add	s2,s2,356 # 80198118 <log>
    80003fbc:	01892583          	lw	a1,24(s2)
    80003fc0:	02892503          	lw	a0,40(s2)
    80003fc4:	fffff097          	auipc	ra,0xfffff
    80003fc8:	ff4080e7          	jalr	-12(ra) # 80002fb8 <bread>
    80003fcc:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fce:	02c92603          	lw	a2,44(s2)
    80003fd2:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fd4:	00c05f63          	blez	a2,80003ff2 <write_head+0x4a>
    80003fd8:	00194717          	auipc	a4,0x194
    80003fdc:	17070713          	add	a4,a4,368 # 80198148 <log+0x30>
    80003fe0:	87aa                	mv	a5,a0
    80003fe2:	060a                	sll	a2,a2,0x2
    80003fe4:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fe6:	4314                	lw	a3,0(a4)
    80003fe8:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fea:	0711                	add	a4,a4,4
    80003fec:	0791                	add	a5,a5,4
    80003fee:	fec79ce3          	bne	a5,a2,80003fe6 <write_head+0x3e>
  }
  bwrite(buf);
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	fffff097          	auipc	ra,0xfffff
    80003ff8:	0b6080e7          	jalr	182(ra) # 800030aa <bwrite>
  brelse(buf);
    80003ffc:	8526                	mv	a0,s1
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	0ea080e7          	jalr	234(ra) # 800030e8 <brelse>
}
    80004006:	60e2                	ld	ra,24(sp)
    80004008:	6442                	ld	s0,16(sp)
    8000400a:	64a2                	ld	s1,8(sp)
    8000400c:	6902                	ld	s2,0(sp)
    8000400e:	6105                	add	sp,sp,32
    80004010:	8082                	ret

0000000080004012 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004012:	00194797          	auipc	a5,0x194
    80004016:	1327a783          	lw	a5,306(a5) # 80198144 <log+0x2c>
    8000401a:	0af05d63          	blez	a5,800040d4 <install_trans+0xc2>
{
    8000401e:	7139                	add	sp,sp,-64
    80004020:	fc06                	sd	ra,56(sp)
    80004022:	f822                	sd	s0,48(sp)
    80004024:	f426                	sd	s1,40(sp)
    80004026:	f04a                	sd	s2,32(sp)
    80004028:	ec4e                	sd	s3,24(sp)
    8000402a:	e852                	sd	s4,16(sp)
    8000402c:	e456                	sd	s5,8(sp)
    8000402e:	e05a                	sd	s6,0(sp)
    80004030:	0080                	add	s0,sp,64
    80004032:	8b2a                	mv	s6,a0
    80004034:	00194a97          	auipc	s5,0x194
    80004038:	114a8a93          	add	s5,s5,276 # 80198148 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000403c:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000403e:	00194997          	auipc	s3,0x194
    80004042:	0da98993          	add	s3,s3,218 # 80198118 <log>
    80004046:	a00d                	j	80004068 <install_trans+0x56>
    brelse(lbuf);
    80004048:	854a                	mv	a0,s2
    8000404a:	fffff097          	auipc	ra,0xfffff
    8000404e:	09e080e7          	jalr	158(ra) # 800030e8 <brelse>
    brelse(dbuf);
    80004052:	8526                	mv	a0,s1
    80004054:	fffff097          	auipc	ra,0xfffff
    80004058:	094080e7          	jalr	148(ra) # 800030e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000405c:	2a05                	addw	s4,s4,1
    8000405e:	0a91                	add	s5,s5,4
    80004060:	02c9a783          	lw	a5,44(s3)
    80004064:	04fa5e63          	bge	s4,a5,800040c0 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004068:	0189a583          	lw	a1,24(s3)
    8000406c:	014585bb          	addw	a1,a1,s4
    80004070:	2585                	addw	a1,a1,1
    80004072:	0289a503          	lw	a0,40(s3)
    80004076:	fffff097          	auipc	ra,0xfffff
    8000407a:	f42080e7          	jalr	-190(ra) # 80002fb8 <bread>
    8000407e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80004080:	000aa583          	lw	a1,0(s5)
    80004084:	0289a503          	lw	a0,40(s3)
    80004088:	fffff097          	auipc	ra,0xfffff
    8000408c:	f30080e7          	jalr	-208(ra) # 80002fb8 <bread>
    80004090:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004092:	40000613          	li	a2,1024
    80004096:	05890593          	add	a1,s2,88
    8000409a:	05850513          	add	a0,a0,88
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	c8c080e7          	jalr	-884(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    800040a6:	8526                	mv	a0,s1
    800040a8:	fffff097          	auipc	ra,0xfffff
    800040ac:	002080e7          	jalr	2(ra) # 800030aa <bwrite>
    if(recovering == 0)
    800040b0:	f80b1ce3          	bnez	s6,80004048 <install_trans+0x36>
      bunpin(dbuf);
    800040b4:	8526                	mv	a0,s1
    800040b6:	fffff097          	auipc	ra,0xfffff
    800040ba:	10a080e7          	jalr	266(ra) # 800031c0 <bunpin>
    800040be:	b769                	j	80004048 <install_trans+0x36>
}
    800040c0:	70e2                	ld	ra,56(sp)
    800040c2:	7442                	ld	s0,48(sp)
    800040c4:	74a2                	ld	s1,40(sp)
    800040c6:	7902                	ld	s2,32(sp)
    800040c8:	69e2                	ld	s3,24(sp)
    800040ca:	6a42                	ld	s4,16(sp)
    800040cc:	6aa2                	ld	s5,8(sp)
    800040ce:	6b02                	ld	s6,0(sp)
    800040d0:	6121                	add	sp,sp,64
    800040d2:	8082                	ret
    800040d4:	8082                	ret

00000000800040d6 <initlog>:
{
    800040d6:	7179                	add	sp,sp,-48
    800040d8:	f406                	sd	ra,40(sp)
    800040da:	f022                	sd	s0,32(sp)
    800040dc:	ec26                	sd	s1,24(sp)
    800040de:	e84a                	sd	s2,16(sp)
    800040e0:	e44e                	sd	s3,8(sp)
    800040e2:	1800                	add	s0,sp,48
    800040e4:	892a                	mv	s2,a0
    800040e6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040e8:	00194497          	auipc	s1,0x194
    800040ec:	03048493          	add	s1,s1,48 # 80198118 <log>
    800040f0:	00004597          	auipc	a1,0x4
    800040f4:	58858593          	add	a1,a1,1416 # 80008678 <syscalls+0x1d8>
    800040f8:	8526                	mv	a0,s1
    800040fa:	ffffd097          	auipc	ra,0xffffd
    800040fe:	a48080e7          	jalr	-1464(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004102:	0149a583          	lw	a1,20(s3)
    80004106:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004108:	0109a783          	lw	a5,16(s3)
    8000410c:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000410e:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004112:	854a                	mv	a0,s2
    80004114:	fffff097          	auipc	ra,0xfffff
    80004118:	ea4080e7          	jalr	-348(ra) # 80002fb8 <bread>
  log.lh.n = lh->n;
    8000411c:	4d30                	lw	a2,88(a0)
    8000411e:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004120:	00c05f63          	blez	a2,8000413e <initlog+0x68>
    80004124:	87aa                	mv	a5,a0
    80004126:	00194717          	auipc	a4,0x194
    8000412a:	02270713          	add	a4,a4,34 # 80198148 <log+0x30>
    8000412e:	060a                	sll	a2,a2,0x2
    80004130:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80004132:	4ff4                	lw	a3,92(a5)
    80004134:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004136:	0791                	add	a5,a5,4
    80004138:	0711                	add	a4,a4,4
    8000413a:	fec79ce3          	bne	a5,a2,80004132 <initlog+0x5c>
  brelse(buf);
    8000413e:	fffff097          	auipc	ra,0xfffff
    80004142:	faa080e7          	jalr	-86(ra) # 800030e8 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004146:	4505                	li	a0,1
    80004148:	00000097          	auipc	ra,0x0
    8000414c:	eca080e7          	jalr	-310(ra) # 80004012 <install_trans>
  log.lh.n = 0;
    80004150:	00194797          	auipc	a5,0x194
    80004154:	fe07aa23          	sw	zero,-12(a5) # 80198144 <log+0x2c>
  write_head(); // clear the log
    80004158:	00000097          	auipc	ra,0x0
    8000415c:	e50080e7          	jalr	-432(ra) # 80003fa8 <write_head>
}
    80004160:	70a2                	ld	ra,40(sp)
    80004162:	7402                	ld	s0,32(sp)
    80004164:	64e2                	ld	s1,24(sp)
    80004166:	6942                	ld	s2,16(sp)
    80004168:	69a2                	ld	s3,8(sp)
    8000416a:	6145                	add	sp,sp,48
    8000416c:	8082                	ret

000000008000416e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000416e:	1101                	add	sp,sp,-32
    80004170:	ec06                	sd	ra,24(sp)
    80004172:	e822                	sd	s0,16(sp)
    80004174:	e426                	sd	s1,8(sp)
    80004176:	e04a                	sd	s2,0(sp)
    80004178:	1000                	add	s0,sp,32
  acquire(&log.lock);
    8000417a:	00194517          	auipc	a0,0x194
    8000417e:	f9e50513          	add	a0,a0,-98 # 80198118 <log>
    80004182:	ffffd097          	auipc	ra,0xffffd
    80004186:	a50080e7          	jalr	-1456(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    8000418a:	00194497          	auipc	s1,0x194
    8000418e:	f8e48493          	add	s1,s1,-114 # 80198118 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004192:	4979                	li	s2,30
    80004194:	a039                	j	800041a2 <begin_op+0x34>
      sleep(&log, &log.lock);
    80004196:	85a6                	mv	a1,s1
    80004198:	8526                	mv	a0,s1
    8000419a:	ffffe097          	auipc	ra,0xffffe
    8000419e:	ff2080e7          	jalr	-14(ra) # 8000218c <sleep>
    if(log.committing){
    800041a2:	50dc                	lw	a5,36(s1)
    800041a4:	fbed                	bnez	a5,80004196 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800041a6:	5098                	lw	a4,32(s1)
    800041a8:	2705                	addw	a4,a4,1
    800041aa:	0027179b          	sllw	a5,a4,0x2
    800041ae:	9fb9                	addw	a5,a5,a4
    800041b0:	0017979b          	sllw	a5,a5,0x1
    800041b4:	54d4                	lw	a3,44(s1)
    800041b6:	9fb5                	addw	a5,a5,a3
    800041b8:	00f95963          	bge	s2,a5,800041ca <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041bc:	85a6                	mv	a1,s1
    800041be:	8526                	mv	a0,s1
    800041c0:	ffffe097          	auipc	ra,0xffffe
    800041c4:	fcc080e7          	jalr	-52(ra) # 8000218c <sleep>
    800041c8:	bfe9                	j	800041a2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041ca:	00194517          	auipc	a0,0x194
    800041ce:	f4e50513          	add	a0,a0,-178 # 80198118 <log>
    800041d2:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800041d4:	ffffd097          	auipc	ra,0xffffd
    800041d8:	ab2080e7          	jalr	-1358(ra) # 80000c86 <release>
      break;
    }
  }
}
    800041dc:	60e2                	ld	ra,24(sp)
    800041de:	6442                	ld	s0,16(sp)
    800041e0:	64a2                	ld	s1,8(sp)
    800041e2:	6902                	ld	s2,0(sp)
    800041e4:	6105                	add	sp,sp,32
    800041e6:	8082                	ret

00000000800041e8 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041e8:	7139                	add	sp,sp,-64
    800041ea:	fc06                	sd	ra,56(sp)
    800041ec:	f822                	sd	s0,48(sp)
    800041ee:	f426                	sd	s1,40(sp)
    800041f0:	f04a                	sd	s2,32(sp)
    800041f2:	ec4e                	sd	s3,24(sp)
    800041f4:	e852                	sd	s4,16(sp)
    800041f6:	e456                	sd	s5,8(sp)
    800041f8:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041fa:	00194497          	auipc	s1,0x194
    800041fe:	f1e48493          	add	s1,s1,-226 # 80198118 <log>
    80004202:	8526                	mv	a0,s1
    80004204:	ffffd097          	auipc	ra,0xffffd
    80004208:	9ce080e7          	jalr	-1586(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    8000420c:	509c                	lw	a5,32(s1)
    8000420e:	37fd                	addw	a5,a5,-1
    80004210:	0007891b          	sext.w	s2,a5
    80004214:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004216:	50dc                	lw	a5,36(s1)
    80004218:	e7b9                	bnez	a5,80004266 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000421a:	04091e63          	bnez	s2,80004276 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000421e:	00194497          	auipc	s1,0x194
    80004222:	efa48493          	add	s1,s1,-262 # 80198118 <log>
    80004226:	4785                	li	a5,1
    80004228:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    8000422a:	8526                	mv	a0,s1
    8000422c:	ffffd097          	auipc	ra,0xffffd
    80004230:	a5a080e7          	jalr	-1446(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004234:	54dc                	lw	a5,44(s1)
    80004236:	06f04763          	bgtz	a5,800042a4 <end_op+0xbc>
    acquire(&log.lock);
    8000423a:	00194497          	auipc	s1,0x194
    8000423e:	ede48493          	add	s1,s1,-290 # 80198118 <log>
    80004242:	8526                	mv	a0,s1
    80004244:	ffffd097          	auipc	ra,0xffffd
    80004248:	98e080e7          	jalr	-1650(ra) # 80000bd2 <acquire>
    log.committing = 0;
    8000424c:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80004250:	8526                	mv	a0,s1
    80004252:	ffffe097          	auipc	ra,0xffffe
    80004256:	f9e080e7          	jalr	-98(ra) # 800021f0 <wakeup>
    release(&log.lock);
    8000425a:	8526                	mv	a0,s1
    8000425c:	ffffd097          	auipc	ra,0xffffd
    80004260:	a2a080e7          	jalr	-1494(ra) # 80000c86 <release>
}
    80004264:	a03d                	j	80004292 <end_op+0xaa>
    panic("log.committing");
    80004266:	00004517          	auipc	a0,0x4
    8000426a:	41a50513          	add	a0,a0,1050 # 80008680 <syscalls+0x1e0>
    8000426e:	ffffc097          	auipc	ra,0xffffc
    80004272:	2ce080e7          	jalr	718(ra) # 8000053c <panic>
    wakeup(&log);
    80004276:	00194497          	auipc	s1,0x194
    8000427a:	ea248493          	add	s1,s1,-350 # 80198118 <log>
    8000427e:	8526                	mv	a0,s1
    80004280:	ffffe097          	auipc	ra,0xffffe
    80004284:	f70080e7          	jalr	-144(ra) # 800021f0 <wakeup>
  release(&log.lock);
    80004288:	8526                	mv	a0,s1
    8000428a:	ffffd097          	auipc	ra,0xffffd
    8000428e:	9fc080e7          	jalr	-1540(ra) # 80000c86 <release>
}
    80004292:	70e2                	ld	ra,56(sp)
    80004294:	7442                	ld	s0,48(sp)
    80004296:	74a2                	ld	s1,40(sp)
    80004298:	7902                	ld	s2,32(sp)
    8000429a:	69e2                	ld	s3,24(sp)
    8000429c:	6a42                	ld	s4,16(sp)
    8000429e:	6aa2                	ld	s5,8(sp)
    800042a0:	6121                	add	sp,sp,64
    800042a2:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800042a4:	00194a97          	auipc	s5,0x194
    800042a8:	ea4a8a93          	add	s5,s5,-348 # 80198148 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800042ac:	00194a17          	auipc	s4,0x194
    800042b0:	e6ca0a13          	add	s4,s4,-404 # 80198118 <log>
    800042b4:	018a2583          	lw	a1,24(s4)
    800042b8:	012585bb          	addw	a1,a1,s2
    800042bc:	2585                	addw	a1,a1,1
    800042be:	028a2503          	lw	a0,40(s4)
    800042c2:	fffff097          	auipc	ra,0xfffff
    800042c6:	cf6080e7          	jalr	-778(ra) # 80002fb8 <bread>
    800042ca:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042cc:	000aa583          	lw	a1,0(s5)
    800042d0:	028a2503          	lw	a0,40(s4)
    800042d4:	fffff097          	auipc	ra,0xfffff
    800042d8:	ce4080e7          	jalr	-796(ra) # 80002fb8 <bread>
    800042dc:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042de:	40000613          	li	a2,1024
    800042e2:	05850593          	add	a1,a0,88
    800042e6:	05848513          	add	a0,s1,88
    800042ea:	ffffd097          	auipc	ra,0xffffd
    800042ee:	a40080e7          	jalr	-1472(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	db6080e7          	jalr	-586(ra) # 800030aa <bwrite>
    brelse(from);
    800042fc:	854e                	mv	a0,s3
    800042fe:	fffff097          	auipc	ra,0xfffff
    80004302:	dea080e7          	jalr	-534(ra) # 800030e8 <brelse>
    brelse(to);
    80004306:	8526                	mv	a0,s1
    80004308:	fffff097          	auipc	ra,0xfffff
    8000430c:	de0080e7          	jalr	-544(ra) # 800030e8 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004310:	2905                	addw	s2,s2,1
    80004312:	0a91                	add	s5,s5,4
    80004314:	02ca2783          	lw	a5,44(s4)
    80004318:	f8f94ee3          	blt	s2,a5,800042b4 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000431c:	00000097          	auipc	ra,0x0
    80004320:	c8c080e7          	jalr	-884(ra) # 80003fa8 <write_head>
    install_trans(0); // Now install writes to home locations
    80004324:	4501                	li	a0,0
    80004326:	00000097          	auipc	ra,0x0
    8000432a:	cec080e7          	jalr	-788(ra) # 80004012 <install_trans>
    log.lh.n = 0;
    8000432e:	00194797          	auipc	a5,0x194
    80004332:	e007ab23          	sw	zero,-490(a5) # 80198144 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004336:	00000097          	auipc	ra,0x0
    8000433a:	c72080e7          	jalr	-910(ra) # 80003fa8 <write_head>
    8000433e:	bdf5                	j	8000423a <end_op+0x52>

0000000080004340 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80004340:	1101                	add	sp,sp,-32
    80004342:	ec06                	sd	ra,24(sp)
    80004344:	e822                	sd	s0,16(sp)
    80004346:	e426                	sd	s1,8(sp)
    80004348:	e04a                	sd	s2,0(sp)
    8000434a:	1000                	add	s0,sp,32
    8000434c:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000434e:	00194917          	auipc	s2,0x194
    80004352:	dca90913          	add	s2,s2,-566 # 80198118 <log>
    80004356:	854a                	mv	a0,s2
    80004358:	ffffd097          	auipc	ra,0xffffd
    8000435c:	87a080e7          	jalr	-1926(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80004360:	02c92603          	lw	a2,44(s2)
    80004364:	47f5                	li	a5,29
    80004366:	06c7c563          	blt	a5,a2,800043d0 <log_write+0x90>
    8000436a:	00194797          	auipc	a5,0x194
    8000436e:	dca7a783          	lw	a5,-566(a5) # 80198134 <log+0x1c>
    80004372:	37fd                	addw	a5,a5,-1
    80004374:	04f65e63          	bge	a2,a5,800043d0 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004378:	00194797          	auipc	a5,0x194
    8000437c:	dc07a783          	lw	a5,-576(a5) # 80198138 <log+0x20>
    80004380:	06f05063          	blez	a5,800043e0 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004384:	4781                	li	a5,0
    80004386:	06c05563          	blez	a2,800043f0 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000438a:	44cc                	lw	a1,12(s1)
    8000438c:	00194717          	auipc	a4,0x194
    80004390:	dbc70713          	add	a4,a4,-580 # 80198148 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004394:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004396:	4314                	lw	a3,0(a4)
    80004398:	04b68c63          	beq	a3,a1,800043f0 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000439c:	2785                	addw	a5,a5,1
    8000439e:	0711                	add	a4,a4,4
    800043a0:	fef61be3          	bne	a2,a5,80004396 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800043a4:	0621                	add	a2,a2,8
    800043a6:	060a                	sll	a2,a2,0x2
    800043a8:	00194797          	auipc	a5,0x194
    800043ac:	d7078793          	add	a5,a5,-656 # 80198118 <log>
    800043b0:	97b2                	add	a5,a5,a2
    800043b2:	44d8                	lw	a4,12(s1)
    800043b4:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043b6:	8526                	mv	a0,s1
    800043b8:	fffff097          	auipc	ra,0xfffff
    800043bc:	dcc080e7          	jalr	-564(ra) # 80003184 <bpin>
    log.lh.n++;
    800043c0:	00194717          	auipc	a4,0x194
    800043c4:	d5870713          	add	a4,a4,-680 # 80198118 <log>
    800043c8:	575c                	lw	a5,44(a4)
    800043ca:	2785                	addw	a5,a5,1
    800043cc:	d75c                	sw	a5,44(a4)
    800043ce:	a82d                	j	80004408 <log_write+0xc8>
    panic("too big a transaction");
    800043d0:	00004517          	auipc	a0,0x4
    800043d4:	2c050513          	add	a0,a0,704 # 80008690 <syscalls+0x1f0>
    800043d8:	ffffc097          	auipc	ra,0xffffc
    800043dc:	164080e7          	jalr	356(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800043e0:	00004517          	auipc	a0,0x4
    800043e4:	2c850513          	add	a0,a0,712 # 800086a8 <syscalls+0x208>
    800043e8:	ffffc097          	auipc	ra,0xffffc
    800043ec:	154080e7          	jalr	340(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043f0:	00878693          	add	a3,a5,8
    800043f4:	068a                	sll	a3,a3,0x2
    800043f6:	00194717          	auipc	a4,0x194
    800043fa:	d2270713          	add	a4,a4,-734 # 80198118 <log>
    800043fe:	9736                	add	a4,a4,a3
    80004400:	44d4                	lw	a3,12(s1)
    80004402:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004404:	faf609e3          	beq	a2,a5,800043b6 <log_write+0x76>
  }
  release(&log.lock);
    80004408:	00194517          	auipc	a0,0x194
    8000440c:	d1050513          	add	a0,a0,-752 # 80198118 <log>
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
}
    80004418:	60e2                	ld	ra,24(sp)
    8000441a:	6442                	ld	s0,16(sp)
    8000441c:	64a2                	ld	s1,8(sp)
    8000441e:	6902                	ld	s2,0(sp)
    80004420:	6105                	add	sp,sp,32
    80004422:	8082                	ret

0000000080004424 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004424:	1101                	add	sp,sp,-32
    80004426:	ec06                	sd	ra,24(sp)
    80004428:	e822                	sd	s0,16(sp)
    8000442a:	e426                	sd	s1,8(sp)
    8000442c:	e04a                	sd	s2,0(sp)
    8000442e:	1000                	add	s0,sp,32
    80004430:	84aa                	mv	s1,a0
    80004432:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004434:	00004597          	auipc	a1,0x4
    80004438:	29458593          	add	a1,a1,660 # 800086c8 <syscalls+0x228>
    8000443c:	0521                	add	a0,a0,8
    8000443e:	ffffc097          	auipc	ra,0xffffc
    80004442:	704080e7          	jalr	1796(ra) # 80000b42 <initlock>
  lk->name = name;
    80004446:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    8000444a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000444e:	0204a423          	sw	zero,40(s1)
}
    80004452:	60e2                	ld	ra,24(sp)
    80004454:	6442                	ld	s0,16(sp)
    80004456:	64a2                	ld	s1,8(sp)
    80004458:	6902                	ld	s2,0(sp)
    8000445a:	6105                	add	sp,sp,32
    8000445c:	8082                	ret

000000008000445e <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000445e:	1101                	add	sp,sp,-32
    80004460:	ec06                	sd	ra,24(sp)
    80004462:	e822                	sd	s0,16(sp)
    80004464:	e426                	sd	s1,8(sp)
    80004466:	e04a                	sd	s2,0(sp)
    80004468:	1000                	add	s0,sp,32
    8000446a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000446c:	00850913          	add	s2,a0,8
    80004470:	854a                	mv	a0,s2
    80004472:	ffffc097          	auipc	ra,0xffffc
    80004476:	760080e7          	jalr	1888(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    8000447a:	409c                	lw	a5,0(s1)
    8000447c:	cb89                	beqz	a5,8000448e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000447e:	85ca                	mv	a1,s2
    80004480:	8526                	mv	a0,s1
    80004482:	ffffe097          	auipc	ra,0xffffe
    80004486:	d0a080e7          	jalr	-758(ra) # 8000218c <sleep>
  while (lk->locked) {
    8000448a:	409c                	lw	a5,0(s1)
    8000448c:	fbed                	bnez	a5,8000447e <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000448e:	4785                	li	a5,1
    80004490:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004492:	ffffd097          	auipc	ra,0xffffd
    80004496:	564080e7          	jalr	1380(ra) # 800019f6 <myproc>
    8000449a:	591c                	lw	a5,48(a0)
    8000449c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000449e:	854a                	mv	a0,s2
    800044a0:	ffffc097          	auipc	ra,0xffffc
    800044a4:	7e6080e7          	jalr	2022(ra) # 80000c86 <release>
}
    800044a8:	60e2                	ld	ra,24(sp)
    800044aa:	6442                	ld	s0,16(sp)
    800044ac:	64a2                	ld	s1,8(sp)
    800044ae:	6902                	ld	s2,0(sp)
    800044b0:	6105                	add	sp,sp,32
    800044b2:	8082                	ret

00000000800044b4 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044b4:	1101                	add	sp,sp,-32
    800044b6:	ec06                	sd	ra,24(sp)
    800044b8:	e822                	sd	s0,16(sp)
    800044ba:	e426                	sd	s1,8(sp)
    800044bc:	e04a                	sd	s2,0(sp)
    800044be:	1000                	add	s0,sp,32
    800044c0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044c2:	00850913          	add	s2,a0,8
    800044c6:	854a                	mv	a0,s2
    800044c8:	ffffc097          	auipc	ra,0xffffc
    800044cc:	70a080e7          	jalr	1802(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800044d0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044d4:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044d8:	8526                	mv	a0,s1
    800044da:	ffffe097          	auipc	ra,0xffffe
    800044de:	d16080e7          	jalr	-746(ra) # 800021f0 <wakeup>
  release(&lk->lk);
    800044e2:	854a                	mv	a0,s2
    800044e4:	ffffc097          	auipc	ra,0xffffc
    800044e8:	7a2080e7          	jalr	1954(ra) # 80000c86 <release>
}
    800044ec:	60e2                	ld	ra,24(sp)
    800044ee:	6442                	ld	s0,16(sp)
    800044f0:	64a2                	ld	s1,8(sp)
    800044f2:	6902                	ld	s2,0(sp)
    800044f4:	6105                	add	sp,sp,32
    800044f6:	8082                	ret

00000000800044f8 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044f8:	7179                	add	sp,sp,-48
    800044fa:	f406                	sd	ra,40(sp)
    800044fc:	f022                	sd	s0,32(sp)
    800044fe:	ec26                	sd	s1,24(sp)
    80004500:	e84a                	sd	s2,16(sp)
    80004502:	e44e                	sd	s3,8(sp)
    80004504:	1800                	add	s0,sp,48
    80004506:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004508:	00850913          	add	s2,a0,8
    8000450c:	854a                	mv	a0,s2
    8000450e:	ffffc097          	auipc	ra,0xffffc
    80004512:	6c4080e7          	jalr	1732(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004516:	409c                	lw	a5,0(s1)
    80004518:	ef99                	bnez	a5,80004536 <holdingsleep+0x3e>
    8000451a:	4481                	li	s1,0
  release(&lk->lk);
    8000451c:	854a                	mv	a0,s2
    8000451e:	ffffc097          	auipc	ra,0xffffc
    80004522:	768080e7          	jalr	1896(ra) # 80000c86 <release>
  return r;
}
    80004526:	8526                	mv	a0,s1
    80004528:	70a2                	ld	ra,40(sp)
    8000452a:	7402                	ld	s0,32(sp)
    8000452c:	64e2                	ld	s1,24(sp)
    8000452e:	6942                	ld	s2,16(sp)
    80004530:	69a2                	ld	s3,8(sp)
    80004532:	6145                	add	sp,sp,48
    80004534:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004536:	0284a983          	lw	s3,40(s1)
    8000453a:	ffffd097          	auipc	ra,0xffffd
    8000453e:	4bc080e7          	jalr	1212(ra) # 800019f6 <myproc>
    80004542:	5904                	lw	s1,48(a0)
    80004544:	413484b3          	sub	s1,s1,s3
    80004548:	0014b493          	seqz	s1,s1
    8000454c:	bfc1                	j	8000451c <holdingsleep+0x24>

000000008000454e <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000454e:	1141                	add	sp,sp,-16
    80004550:	e406                	sd	ra,8(sp)
    80004552:	e022                	sd	s0,0(sp)
    80004554:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004556:	00004597          	auipc	a1,0x4
    8000455a:	18258593          	add	a1,a1,386 # 800086d8 <syscalls+0x238>
    8000455e:	00194517          	auipc	a0,0x194
    80004562:	d0250513          	add	a0,a0,-766 # 80198260 <ftable>
    80004566:	ffffc097          	auipc	ra,0xffffc
    8000456a:	5dc080e7          	jalr	1500(ra) # 80000b42 <initlock>
}
    8000456e:	60a2                	ld	ra,8(sp)
    80004570:	6402                	ld	s0,0(sp)
    80004572:	0141                	add	sp,sp,16
    80004574:	8082                	ret

0000000080004576 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004576:	1101                	add	sp,sp,-32
    80004578:	ec06                	sd	ra,24(sp)
    8000457a:	e822                	sd	s0,16(sp)
    8000457c:	e426                	sd	s1,8(sp)
    8000457e:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004580:	00194517          	auipc	a0,0x194
    80004584:	ce050513          	add	a0,a0,-800 # 80198260 <ftable>
    80004588:	ffffc097          	auipc	ra,0xffffc
    8000458c:	64a080e7          	jalr	1610(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004590:	00194497          	auipc	s1,0x194
    80004594:	ce848493          	add	s1,s1,-792 # 80198278 <ftable+0x18>
    80004598:	00195717          	auipc	a4,0x195
    8000459c:	c8070713          	add	a4,a4,-896 # 80199218 <disk>
    if(f->ref == 0){
    800045a0:	40dc                	lw	a5,4(s1)
    800045a2:	cf99                	beqz	a5,800045c0 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800045a4:	02848493          	add	s1,s1,40
    800045a8:	fee49ce3          	bne	s1,a4,800045a0 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800045ac:	00194517          	auipc	a0,0x194
    800045b0:	cb450513          	add	a0,a0,-844 # 80198260 <ftable>
    800045b4:	ffffc097          	auipc	ra,0xffffc
    800045b8:	6d2080e7          	jalr	1746(ra) # 80000c86 <release>
  return 0;
    800045bc:	4481                	li	s1,0
    800045be:	a819                	j	800045d4 <filealloc+0x5e>
      f->ref = 1;
    800045c0:	4785                	li	a5,1
    800045c2:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045c4:	00194517          	auipc	a0,0x194
    800045c8:	c9c50513          	add	a0,a0,-868 # 80198260 <ftable>
    800045cc:	ffffc097          	auipc	ra,0xffffc
    800045d0:	6ba080e7          	jalr	1722(ra) # 80000c86 <release>
}
    800045d4:	8526                	mv	a0,s1
    800045d6:	60e2                	ld	ra,24(sp)
    800045d8:	6442                	ld	s0,16(sp)
    800045da:	64a2                	ld	s1,8(sp)
    800045dc:	6105                	add	sp,sp,32
    800045de:	8082                	ret

00000000800045e0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045e0:	1101                	add	sp,sp,-32
    800045e2:	ec06                	sd	ra,24(sp)
    800045e4:	e822                	sd	s0,16(sp)
    800045e6:	e426                	sd	s1,8(sp)
    800045e8:	1000                	add	s0,sp,32
    800045ea:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045ec:	00194517          	auipc	a0,0x194
    800045f0:	c7450513          	add	a0,a0,-908 # 80198260 <ftable>
    800045f4:	ffffc097          	auipc	ra,0xffffc
    800045f8:	5de080e7          	jalr	1502(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045fc:	40dc                	lw	a5,4(s1)
    800045fe:	02f05263          	blez	a5,80004622 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004602:	2785                	addw	a5,a5,1
    80004604:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004606:	00194517          	auipc	a0,0x194
    8000460a:	c5a50513          	add	a0,a0,-934 # 80198260 <ftable>
    8000460e:	ffffc097          	auipc	ra,0xffffc
    80004612:	678080e7          	jalr	1656(ra) # 80000c86 <release>
  return f;
}
    80004616:	8526                	mv	a0,s1
    80004618:	60e2                	ld	ra,24(sp)
    8000461a:	6442                	ld	s0,16(sp)
    8000461c:	64a2                	ld	s1,8(sp)
    8000461e:	6105                	add	sp,sp,32
    80004620:	8082                	ret
    panic("filedup");
    80004622:	00004517          	auipc	a0,0x4
    80004626:	0be50513          	add	a0,a0,190 # 800086e0 <syscalls+0x240>
    8000462a:	ffffc097          	auipc	ra,0xffffc
    8000462e:	f12080e7          	jalr	-238(ra) # 8000053c <panic>

0000000080004632 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80004632:	7139                	add	sp,sp,-64
    80004634:	fc06                	sd	ra,56(sp)
    80004636:	f822                	sd	s0,48(sp)
    80004638:	f426                	sd	s1,40(sp)
    8000463a:	f04a                	sd	s2,32(sp)
    8000463c:	ec4e                	sd	s3,24(sp)
    8000463e:	e852                	sd	s4,16(sp)
    80004640:	e456                	sd	s5,8(sp)
    80004642:	0080                	add	s0,sp,64
    80004644:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004646:	00194517          	auipc	a0,0x194
    8000464a:	c1a50513          	add	a0,a0,-998 # 80198260 <ftable>
    8000464e:	ffffc097          	auipc	ra,0xffffc
    80004652:	584080e7          	jalr	1412(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004656:	40dc                	lw	a5,4(s1)
    80004658:	06f05163          	blez	a5,800046ba <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    8000465c:	37fd                	addw	a5,a5,-1
    8000465e:	0007871b          	sext.w	a4,a5
    80004662:	c0dc                	sw	a5,4(s1)
    80004664:	06e04363          	bgtz	a4,800046ca <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004668:	0004a903          	lw	s2,0(s1)
    8000466c:	0094ca83          	lbu	s5,9(s1)
    80004670:	0104ba03          	ld	s4,16(s1)
    80004674:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004678:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    8000467c:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004680:	00194517          	auipc	a0,0x194
    80004684:	be050513          	add	a0,a0,-1056 # 80198260 <ftable>
    80004688:	ffffc097          	auipc	ra,0xffffc
    8000468c:	5fe080e7          	jalr	1534(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004690:	4785                	li	a5,1
    80004692:	04f90d63          	beq	s2,a5,800046ec <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004696:	3979                	addw	s2,s2,-2
    80004698:	4785                	li	a5,1
    8000469a:	0527e063          	bltu	a5,s2,800046da <fileclose+0xa8>
    begin_op();
    8000469e:	00000097          	auipc	ra,0x0
    800046a2:	ad0080e7          	jalr	-1328(ra) # 8000416e <begin_op>
    iput(ff.ip);
    800046a6:	854e                	mv	a0,s3
    800046a8:	fffff097          	auipc	ra,0xfffff
    800046ac:	2da080e7          	jalr	730(ra) # 80003982 <iput>
    end_op();
    800046b0:	00000097          	auipc	ra,0x0
    800046b4:	b38080e7          	jalr	-1224(ra) # 800041e8 <end_op>
    800046b8:	a00d                	j	800046da <fileclose+0xa8>
    panic("fileclose");
    800046ba:	00004517          	auipc	a0,0x4
    800046be:	02e50513          	add	a0,a0,46 # 800086e8 <syscalls+0x248>
    800046c2:	ffffc097          	auipc	ra,0xffffc
    800046c6:	e7a080e7          	jalr	-390(ra) # 8000053c <panic>
    release(&ftable.lock);
    800046ca:	00194517          	auipc	a0,0x194
    800046ce:	b9650513          	add	a0,a0,-1130 # 80198260 <ftable>
    800046d2:	ffffc097          	auipc	ra,0xffffc
    800046d6:	5b4080e7          	jalr	1460(ra) # 80000c86 <release>
  }
}
    800046da:	70e2                	ld	ra,56(sp)
    800046dc:	7442                	ld	s0,48(sp)
    800046de:	74a2                	ld	s1,40(sp)
    800046e0:	7902                	ld	s2,32(sp)
    800046e2:	69e2                	ld	s3,24(sp)
    800046e4:	6a42                	ld	s4,16(sp)
    800046e6:	6aa2                	ld	s5,8(sp)
    800046e8:	6121                	add	sp,sp,64
    800046ea:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046ec:	85d6                	mv	a1,s5
    800046ee:	8552                	mv	a0,s4
    800046f0:	00000097          	auipc	ra,0x0
    800046f4:	348080e7          	jalr	840(ra) # 80004a38 <pipeclose>
    800046f8:	b7cd                	j	800046da <fileclose+0xa8>

00000000800046fa <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046fa:	715d                	add	sp,sp,-80
    800046fc:	e486                	sd	ra,72(sp)
    800046fe:	e0a2                	sd	s0,64(sp)
    80004700:	fc26                	sd	s1,56(sp)
    80004702:	f84a                	sd	s2,48(sp)
    80004704:	f44e                	sd	s3,40(sp)
    80004706:	0880                	add	s0,sp,80
    80004708:	84aa                	mv	s1,a0
    8000470a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000470c:	ffffd097          	auipc	ra,0xffffd
    80004710:	2ea080e7          	jalr	746(ra) # 800019f6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004714:	409c                	lw	a5,0(s1)
    80004716:	37f9                	addw	a5,a5,-2
    80004718:	4705                	li	a4,1
    8000471a:	04f76763          	bltu	a4,a5,80004768 <filestat+0x6e>
    8000471e:	892a                	mv	s2,a0
    ilock(f->ip);
    80004720:	6c88                	ld	a0,24(s1)
    80004722:	fffff097          	auipc	ra,0xfffff
    80004726:	0a6080e7          	jalr	166(ra) # 800037c8 <ilock>
    stati(f->ip, &st);
    8000472a:	fb840593          	add	a1,s0,-72
    8000472e:	6c88                	ld	a0,24(s1)
    80004730:	fffff097          	auipc	ra,0xfffff
    80004734:	322080e7          	jalr	802(ra) # 80003a52 <stati>
    iunlock(f->ip);
    80004738:	6c88                	ld	a0,24(s1)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	150080e7          	jalr	336(ra) # 8000388a <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80004742:	46e1                	li	a3,24
    80004744:	fb840613          	add	a2,s0,-72
    80004748:	85ce                	mv	a1,s3
    8000474a:	05093503          	ld	a0,80(s2)
    8000474e:	ffffd097          	auipc	ra,0xffffd
    80004752:	f58080e7          	jalr	-168(ra) # 800016a6 <copyout>
    80004756:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    8000475a:	60a6                	ld	ra,72(sp)
    8000475c:	6406                	ld	s0,64(sp)
    8000475e:	74e2                	ld	s1,56(sp)
    80004760:	7942                	ld	s2,48(sp)
    80004762:	79a2                	ld	s3,40(sp)
    80004764:	6161                	add	sp,sp,80
    80004766:	8082                	ret
  return -1;
    80004768:	557d                	li	a0,-1
    8000476a:	bfc5                	j	8000475a <filestat+0x60>

000000008000476c <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    8000476c:	7179                	add	sp,sp,-48
    8000476e:	f406                	sd	ra,40(sp)
    80004770:	f022                	sd	s0,32(sp)
    80004772:	ec26                	sd	s1,24(sp)
    80004774:	e84a                	sd	s2,16(sp)
    80004776:	e44e                	sd	s3,8(sp)
    80004778:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000477a:	00854783          	lbu	a5,8(a0)
    8000477e:	c3d5                	beqz	a5,80004822 <fileread+0xb6>
    80004780:	84aa                	mv	s1,a0
    80004782:	89ae                	mv	s3,a1
    80004784:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004786:	411c                	lw	a5,0(a0)
    80004788:	4705                	li	a4,1
    8000478a:	04e78963          	beq	a5,a4,800047dc <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000478e:	470d                	li	a4,3
    80004790:	04e78d63          	beq	a5,a4,800047ea <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004794:	4709                	li	a4,2
    80004796:	06e79e63          	bne	a5,a4,80004812 <fileread+0xa6>
    ilock(f->ip);
    8000479a:	6d08                	ld	a0,24(a0)
    8000479c:	fffff097          	auipc	ra,0xfffff
    800047a0:	02c080e7          	jalr	44(ra) # 800037c8 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800047a4:	874a                	mv	a4,s2
    800047a6:	5094                	lw	a3,32(s1)
    800047a8:	864e                	mv	a2,s3
    800047aa:	4585                	li	a1,1
    800047ac:	6c88                	ld	a0,24(s1)
    800047ae:	fffff097          	auipc	ra,0xfffff
    800047b2:	2ce080e7          	jalr	718(ra) # 80003a7c <readi>
    800047b6:	892a                	mv	s2,a0
    800047b8:	00a05563          	blez	a0,800047c2 <fileread+0x56>
      f->off += r;
    800047bc:	509c                	lw	a5,32(s1)
    800047be:	9fa9                	addw	a5,a5,a0
    800047c0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047c2:	6c88                	ld	a0,24(s1)
    800047c4:	fffff097          	auipc	ra,0xfffff
    800047c8:	0c6080e7          	jalr	198(ra) # 8000388a <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047cc:	854a                	mv	a0,s2
    800047ce:	70a2                	ld	ra,40(sp)
    800047d0:	7402                	ld	s0,32(sp)
    800047d2:	64e2                	ld	s1,24(sp)
    800047d4:	6942                	ld	s2,16(sp)
    800047d6:	69a2                	ld	s3,8(sp)
    800047d8:	6145                	add	sp,sp,48
    800047da:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047dc:	6908                	ld	a0,16(a0)
    800047de:	00000097          	auipc	ra,0x0
    800047e2:	3c2080e7          	jalr	962(ra) # 80004ba0 <piperead>
    800047e6:	892a                	mv	s2,a0
    800047e8:	b7d5                	j	800047cc <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047ea:	02451783          	lh	a5,36(a0)
    800047ee:	03079693          	sll	a3,a5,0x30
    800047f2:	92c1                	srl	a3,a3,0x30
    800047f4:	4725                	li	a4,9
    800047f6:	02d76863          	bltu	a4,a3,80004826 <fileread+0xba>
    800047fa:	0792                	sll	a5,a5,0x4
    800047fc:	00194717          	auipc	a4,0x194
    80004800:	9c470713          	add	a4,a4,-1596 # 801981c0 <devsw>
    80004804:	97ba                	add	a5,a5,a4
    80004806:	639c                	ld	a5,0(a5)
    80004808:	c38d                	beqz	a5,8000482a <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000480a:	4505                	li	a0,1
    8000480c:	9782                	jalr	a5
    8000480e:	892a                	mv	s2,a0
    80004810:	bf75                	j	800047cc <fileread+0x60>
    panic("fileread");
    80004812:	00004517          	auipc	a0,0x4
    80004816:	ee650513          	add	a0,a0,-282 # 800086f8 <syscalls+0x258>
    8000481a:	ffffc097          	auipc	ra,0xffffc
    8000481e:	d22080e7          	jalr	-734(ra) # 8000053c <panic>
    return -1;
    80004822:	597d                	li	s2,-1
    80004824:	b765                	j	800047cc <fileread+0x60>
      return -1;
    80004826:	597d                	li	s2,-1
    80004828:	b755                	j	800047cc <fileread+0x60>
    8000482a:	597d                	li	s2,-1
    8000482c:	b745                	j	800047cc <fileread+0x60>

000000008000482e <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000482e:	00954783          	lbu	a5,9(a0)
    80004832:	10078e63          	beqz	a5,8000494e <filewrite+0x120>
{
    80004836:	715d                	add	sp,sp,-80
    80004838:	e486                	sd	ra,72(sp)
    8000483a:	e0a2                	sd	s0,64(sp)
    8000483c:	fc26                	sd	s1,56(sp)
    8000483e:	f84a                	sd	s2,48(sp)
    80004840:	f44e                	sd	s3,40(sp)
    80004842:	f052                	sd	s4,32(sp)
    80004844:	ec56                	sd	s5,24(sp)
    80004846:	e85a                	sd	s6,16(sp)
    80004848:	e45e                	sd	s7,8(sp)
    8000484a:	e062                	sd	s8,0(sp)
    8000484c:	0880                	add	s0,sp,80
    8000484e:	892a                	mv	s2,a0
    80004850:	8b2e                	mv	s6,a1
    80004852:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004854:	411c                	lw	a5,0(a0)
    80004856:	4705                	li	a4,1
    80004858:	02e78263          	beq	a5,a4,8000487c <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000485c:	470d                	li	a4,3
    8000485e:	02e78563          	beq	a5,a4,80004888 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80004862:	4709                	li	a4,2
    80004864:	0ce79d63          	bne	a5,a4,8000493e <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004868:	0ac05b63          	blez	a2,8000491e <filewrite+0xf0>
    int i = 0;
    8000486c:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000486e:	6b85                	lui	s7,0x1
    80004870:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004874:	6c05                	lui	s8,0x1
    80004876:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000487a:	a851                	j	8000490e <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    8000487c:	6908                	ld	a0,16(a0)
    8000487e:	00000097          	auipc	ra,0x0
    80004882:	22a080e7          	jalr	554(ra) # 80004aa8 <pipewrite>
    80004886:	a045                	j	80004926 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004888:	02451783          	lh	a5,36(a0)
    8000488c:	03079693          	sll	a3,a5,0x30
    80004890:	92c1                	srl	a3,a3,0x30
    80004892:	4725                	li	a4,9
    80004894:	0ad76f63          	bltu	a4,a3,80004952 <filewrite+0x124>
    80004898:	0792                	sll	a5,a5,0x4
    8000489a:	00194717          	auipc	a4,0x194
    8000489e:	92670713          	add	a4,a4,-1754 # 801981c0 <devsw>
    800048a2:	97ba                	add	a5,a5,a4
    800048a4:	679c                	ld	a5,8(a5)
    800048a6:	cbc5                	beqz	a5,80004956 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800048a8:	4505                	li	a0,1
    800048aa:	9782                	jalr	a5
    800048ac:	a8ad                	j	80004926 <filewrite+0xf8>
      if(n1 > max)
    800048ae:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800048b2:	00000097          	auipc	ra,0x0
    800048b6:	8bc080e7          	jalr	-1860(ra) # 8000416e <begin_op>
      ilock(f->ip);
    800048ba:	01893503          	ld	a0,24(s2)
    800048be:	fffff097          	auipc	ra,0xfffff
    800048c2:	f0a080e7          	jalr	-246(ra) # 800037c8 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048c6:	8756                	mv	a4,s5
    800048c8:	02092683          	lw	a3,32(s2)
    800048cc:	01698633          	add	a2,s3,s6
    800048d0:	4585                	li	a1,1
    800048d2:	01893503          	ld	a0,24(s2)
    800048d6:	fffff097          	auipc	ra,0xfffff
    800048da:	29e080e7          	jalr	670(ra) # 80003b74 <writei>
    800048de:	84aa                	mv	s1,a0
    800048e0:	00a05763          	blez	a0,800048ee <filewrite+0xc0>
        f->off += r;
    800048e4:	02092783          	lw	a5,32(s2)
    800048e8:	9fa9                	addw	a5,a5,a0
    800048ea:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048ee:	01893503          	ld	a0,24(s2)
    800048f2:	fffff097          	auipc	ra,0xfffff
    800048f6:	f98080e7          	jalr	-104(ra) # 8000388a <iunlock>
      end_op();
    800048fa:	00000097          	auipc	ra,0x0
    800048fe:	8ee080e7          	jalr	-1810(ra) # 800041e8 <end_op>

      if(r != n1){
    80004902:	009a9f63          	bne	s5,s1,80004920 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004906:	013489bb          	addw	s3,s1,s3
    while(i < n){
    8000490a:	0149db63          	bge	s3,s4,80004920 <filewrite+0xf2>
      int n1 = n - i;
    8000490e:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004912:	0004879b          	sext.w	a5,s1
    80004916:	f8fbdce3          	bge	s7,a5,800048ae <filewrite+0x80>
    8000491a:	84e2                	mv	s1,s8
    8000491c:	bf49                	j	800048ae <filewrite+0x80>
    int i = 0;
    8000491e:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004920:	033a1d63          	bne	s4,s3,8000495a <filewrite+0x12c>
    80004924:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004926:	60a6                	ld	ra,72(sp)
    80004928:	6406                	ld	s0,64(sp)
    8000492a:	74e2                	ld	s1,56(sp)
    8000492c:	7942                	ld	s2,48(sp)
    8000492e:	79a2                	ld	s3,40(sp)
    80004930:	7a02                	ld	s4,32(sp)
    80004932:	6ae2                	ld	s5,24(sp)
    80004934:	6b42                	ld	s6,16(sp)
    80004936:	6ba2                	ld	s7,8(sp)
    80004938:	6c02                	ld	s8,0(sp)
    8000493a:	6161                	add	sp,sp,80
    8000493c:	8082                	ret
    panic("filewrite");
    8000493e:	00004517          	auipc	a0,0x4
    80004942:	dca50513          	add	a0,a0,-566 # 80008708 <syscalls+0x268>
    80004946:	ffffc097          	auipc	ra,0xffffc
    8000494a:	bf6080e7          	jalr	-1034(ra) # 8000053c <panic>
    return -1;
    8000494e:	557d                	li	a0,-1
}
    80004950:	8082                	ret
      return -1;
    80004952:	557d                	li	a0,-1
    80004954:	bfc9                	j	80004926 <filewrite+0xf8>
    80004956:	557d                	li	a0,-1
    80004958:	b7f9                	j	80004926 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    8000495a:	557d                	li	a0,-1
    8000495c:	b7e9                	j	80004926 <filewrite+0xf8>

000000008000495e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000495e:	7179                	add	sp,sp,-48
    80004960:	f406                	sd	ra,40(sp)
    80004962:	f022                	sd	s0,32(sp)
    80004964:	ec26                	sd	s1,24(sp)
    80004966:	e84a                	sd	s2,16(sp)
    80004968:	e44e                	sd	s3,8(sp)
    8000496a:	e052                	sd	s4,0(sp)
    8000496c:	1800                	add	s0,sp,48
    8000496e:	84aa                	mv	s1,a0
    80004970:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004972:	0005b023          	sd	zero,0(a1)
    80004976:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    8000497a:	00000097          	auipc	ra,0x0
    8000497e:	bfc080e7          	jalr	-1028(ra) # 80004576 <filealloc>
    80004982:	e088                	sd	a0,0(s1)
    80004984:	c551                	beqz	a0,80004a10 <pipealloc+0xb2>
    80004986:	00000097          	auipc	ra,0x0
    8000498a:	bf0080e7          	jalr	-1040(ra) # 80004576 <filealloc>
    8000498e:	00aa3023          	sd	a0,0(s4)
    80004992:	c92d                	beqz	a0,80004a04 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004994:	ffffc097          	auipc	ra,0xffffc
    80004998:	14e080e7          	jalr	334(ra) # 80000ae2 <kalloc>
    8000499c:	892a                	mv	s2,a0
    8000499e:	c125                	beqz	a0,800049fe <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800049a0:	4985                	li	s3,1
    800049a2:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800049a6:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800049aa:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800049ae:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800049b2:	00004597          	auipc	a1,0x4
    800049b6:	d6658593          	add	a1,a1,-666 # 80008718 <syscalls+0x278>
    800049ba:	ffffc097          	auipc	ra,0xffffc
    800049be:	188080e7          	jalr	392(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    800049c2:	609c                	ld	a5,0(s1)
    800049c4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049c8:	609c                	ld	a5,0(s1)
    800049ca:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049ce:	609c                	ld	a5,0(s1)
    800049d0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049d4:	609c                	ld	a5,0(s1)
    800049d6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049da:	000a3783          	ld	a5,0(s4)
    800049de:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049e2:	000a3783          	ld	a5,0(s4)
    800049e6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049ea:	000a3783          	ld	a5,0(s4)
    800049ee:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049f2:	000a3783          	ld	a5,0(s4)
    800049f6:	0127b823          	sd	s2,16(a5)
  return 0;
    800049fa:	4501                	li	a0,0
    800049fc:	a025                	j	80004a24 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049fe:	6088                	ld	a0,0(s1)
    80004a00:	e501                	bnez	a0,80004a08 <pipealloc+0xaa>
    80004a02:	a039                	j	80004a10 <pipealloc+0xb2>
    80004a04:	6088                	ld	a0,0(s1)
    80004a06:	c51d                	beqz	a0,80004a34 <pipealloc+0xd6>
    fileclose(*f0);
    80004a08:	00000097          	auipc	ra,0x0
    80004a0c:	c2a080e7          	jalr	-982(ra) # 80004632 <fileclose>
  if(*f1)
    80004a10:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a14:	557d                	li	a0,-1
  if(*f1)
    80004a16:	c799                	beqz	a5,80004a24 <pipealloc+0xc6>
    fileclose(*f1);
    80004a18:	853e                	mv	a0,a5
    80004a1a:	00000097          	auipc	ra,0x0
    80004a1e:	c18080e7          	jalr	-1000(ra) # 80004632 <fileclose>
  return -1;
    80004a22:	557d                	li	a0,-1
}
    80004a24:	70a2                	ld	ra,40(sp)
    80004a26:	7402                	ld	s0,32(sp)
    80004a28:	64e2                	ld	s1,24(sp)
    80004a2a:	6942                	ld	s2,16(sp)
    80004a2c:	69a2                	ld	s3,8(sp)
    80004a2e:	6a02                	ld	s4,0(sp)
    80004a30:	6145                	add	sp,sp,48
    80004a32:	8082                	ret
  return -1;
    80004a34:	557d                	li	a0,-1
    80004a36:	b7fd                	j	80004a24 <pipealloc+0xc6>

0000000080004a38 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a38:	1101                	add	sp,sp,-32
    80004a3a:	ec06                	sd	ra,24(sp)
    80004a3c:	e822                	sd	s0,16(sp)
    80004a3e:	e426                	sd	s1,8(sp)
    80004a40:	e04a                	sd	s2,0(sp)
    80004a42:	1000                	add	s0,sp,32
    80004a44:	84aa                	mv	s1,a0
    80004a46:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	18a080e7          	jalr	394(ra) # 80000bd2 <acquire>
  if(writable){
    80004a50:	02090d63          	beqz	s2,80004a8a <pipeclose+0x52>
    pi->writeopen = 0;
    80004a54:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a58:	21848513          	add	a0,s1,536
    80004a5c:	ffffd097          	auipc	ra,0xffffd
    80004a60:	794080e7          	jalr	1940(ra) # 800021f0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a64:	2204b783          	ld	a5,544(s1)
    80004a68:	eb95                	bnez	a5,80004a9c <pipeclose+0x64>
    release(&pi->lock);
    80004a6a:	8526                	mv	a0,s1
    80004a6c:	ffffc097          	auipc	ra,0xffffc
    80004a70:	21a080e7          	jalr	538(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a74:	8526                	mv	a0,s1
    80004a76:	ffffc097          	auipc	ra,0xffffc
    80004a7a:	f6e080e7          	jalr	-146(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a7e:	60e2                	ld	ra,24(sp)
    80004a80:	6442                	ld	s0,16(sp)
    80004a82:	64a2                	ld	s1,8(sp)
    80004a84:	6902                	ld	s2,0(sp)
    80004a86:	6105                	add	sp,sp,32
    80004a88:	8082                	ret
    pi->readopen = 0;
    80004a8a:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a8e:	21c48513          	add	a0,s1,540
    80004a92:	ffffd097          	auipc	ra,0xffffd
    80004a96:	75e080e7          	jalr	1886(ra) # 800021f0 <wakeup>
    80004a9a:	b7e9                	j	80004a64 <pipeclose+0x2c>
    release(&pi->lock);
    80004a9c:	8526                	mv	a0,s1
    80004a9e:	ffffc097          	auipc	ra,0xffffc
    80004aa2:	1e8080e7          	jalr	488(ra) # 80000c86 <release>
}
    80004aa6:	bfe1                	j	80004a7e <pipeclose+0x46>

0000000080004aa8 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004aa8:	711d                	add	sp,sp,-96
    80004aaa:	ec86                	sd	ra,88(sp)
    80004aac:	e8a2                	sd	s0,80(sp)
    80004aae:	e4a6                	sd	s1,72(sp)
    80004ab0:	e0ca                	sd	s2,64(sp)
    80004ab2:	fc4e                	sd	s3,56(sp)
    80004ab4:	f852                	sd	s4,48(sp)
    80004ab6:	f456                	sd	s5,40(sp)
    80004ab8:	f05a                	sd	s6,32(sp)
    80004aba:	ec5e                	sd	s7,24(sp)
    80004abc:	e862                	sd	s8,16(sp)
    80004abe:	1080                	add	s0,sp,96
    80004ac0:	84aa                	mv	s1,a0
    80004ac2:	8aae                	mv	s5,a1
    80004ac4:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ac6:	ffffd097          	auipc	ra,0xffffd
    80004aca:	f30080e7          	jalr	-208(ra) # 800019f6 <myproc>
    80004ace:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004ad0:	8526                	mv	a0,s1
    80004ad2:	ffffc097          	auipc	ra,0xffffc
    80004ad6:	100080e7          	jalr	256(ra) # 80000bd2 <acquire>
  while(i < n){
    80004ada:	0b405663          	blez	s4,80004b86 <pipewrite+0xde>
  int i = 0;
    80004ade:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ae0:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ae2:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ae6:	21c48b93          	add	s7,s1,540
    80004aea:	a089                	j	80004b2c <pipewrite+0x84>
      release(&pi->lock);
    80004aec:	8526                	mv	a0,s1
    80004aee:	ffffc097          	auipc	ra,0xffffc
    80004af2:	198080e7          	jalr	408(ra) # 80000c86 <release>
      return -1;
    80004af6:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004af8:	854a                	mv	a0,s2
    80004afa:	60e6                	ld	ra,88(sp)
    80004afc:	6446                	ld	s0,80(sp)
    80004afe:	64a6                	ld	s1,72(sp)
    80004b00:	6906                	ld	s2,64(sp)
    80004b02:	79e2                	ld	s3,56(sp)
    80004b04:	7a42                	ld	s4,48(sp)
    80004b06:	7aa2                	ld	s5,40(sp)
    80004b08:	7b02                	ld	s6,32(sp)
    80004b0a:	6be2                	ld	s7,24(sp)
    80004b0c:	6c42                	ld	s8,16(sp)
    80004b0e:	6125                	add	sp,sp,96
    80004b10:	8082                	ret
      wakeup(&pi->nread);
    80004b12:	8562                	mv	a0,s8
    80004b14:	ffffd097          	auipc	ra,0xffffd
    80004b18:	6dc080e7          	jalr	1756(ra) # 800021f0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b1c:	85a6                	mv	a1,s1
    80004b1e:	855e                	mv	a0,s7
    80004b20:	ffffd097          	auipc	ra,0xffffd
    80004b24:	66c080e7          	jalr	1644(ra) # 8000218c <sleep>
  while(i < n){
    80004b28:	07495063          	bge	s2,s4,80004b88 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004b2c:	2204a783          	lw	a5,544(s1)
    80004b30:	dfd5                	beqz	a5,80004aec <pipewrite+0x44>
    80004b32:	854e                	mv	a0,s3
    80004b34:	ffffe097          	auipc	ra,0xffffe
    80004b38:	918080e7          	jalr	-1768(ra) # 8000244c <killed>
    80004b3c:	f945                	bnez	a0,80004aec <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b3e:	2184a783          	lw	a5,536(s1)
    80004b42:	21c4a703          	lw	a4,540(s1)
    80004b46:	2007879b          	addw	a5,a5,512
    80004b4a:	fcf704e3          	beq	a4,a5,80004b12 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b4e:	4685                	li	a3,1
    80004b50:	01590633          	add	a2,s2,s5
    80004b54:	faf40593          	add	a1,s0,-81
    80004b58:	0509b503          	ld	a0,80(s3)
    80004b5c:	ffffd097          	auipc	ra,0xffffd
    80004b60:	bd6080e7          	jalr	-1066(ra) # 80001732 <copyin>
    80004b64:	03650263          	beq	a0,s6,80004b88 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b68:	21c4a783          	lw	a5,540(s1)
    80004b6c:	0017871b          	addw	a4,a5,1
    80004b70:	20e4ae23          	sw	a4,540(s1)
    80004b74:	1ff7f793          	and	a5,a5,511
    80004b78:	97a6                	add	a5,a5,s1
    80004b7a:	faf44703          	lbu	a4,-81(s0)
    80004b7e:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b82:	2905                	addw	s2,s2,1
    80004b84:	b755                	j	80004b28 <pipewrite+0x80>
  int i = 0;
    80004b86:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b88:	21848513          	add	a0,s1,536
    80004b8c:	ffffd097          	auipc	ra,0xffffd
    80004b90:	664080e7          	jalr	1636(ra) # 800021f0 <wakeup>
  release(&pi->lock);
    80004b94:	8526                	mv	a0,s1
    80004b96:	ffffc097          	auipc	ra,0xffffc
    80004b9a:	0f0080e7          	jalr	240(ra) # 80000c86 <release>
  return i;
    80004b9e:	bfa9                	j	80004af8 <pipewrite+0x50>

0000000080004ba0 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004ba0:	715d                	add	sp,sp,-80
    80004ba2:	e486                	sd	ra,72(sp)
    80004ba4:	e0a2                	sd	s0,64(sp)
    80004ba6:	fc26                	sd	s1,56(sp)
    80004ba8:	f84a                	sd	s2,48(sp)
    80004baa:	f44e                	sd	s3,40(sp)
    80004bac:	f052                	sd	s4,32(sp)
    80004bae:	ec56                	sd	s5,24(sp)
    80004bb0:	e85a                	sd	s6,16(sp)
    80004bb2:	0880                	add	s0,sp,80
    80004bb4:	84aa                	mv	s1,a0
    80004bb6:	892e                	mv	s2,a1
    80004bb8:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004bba:	ffffd097          	auipc	ra,0xffffd
    80004bbe:	e3c080e7          	jalr	-452(ra) # 800019f6 <myproc>
    80004bc2:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bc4:	8526                	mv	a0,s1
    80004bc6:	ffffc097          	auipc	ra,0xffffc
    80004bca:	00c080e7          	jalr	12(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bce:	2184a703          	lw	a4,536(s1)
    80004bd2:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bd6:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bda:	02f71763          	bne	a4,a5,80004c08 <piperead+0x68>
    80004bde:	2244a783          	lw	a5,548(s1)
    80004be2:	c39d                	beqz	a5,80004c08 <piperead+0x68>
    if(killed(pr)){
    80004be4:	8552                	mv	a0,s4
    80004be6:	ffffe097          	auipc	ra,0xffffe
    80004bea:	866080e7          	jalr	-1946(ra) # 8000244c <killed>
    80004bee:	e949                	bnez	a0,80004c80 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bf0:	85a6                	mv	a1,s1
    80004bf2:	854e                	mv	a0,s3
    80004bf4:	ffffd097          	auipc	ra,0xffffd
    80004bf8:	598080e7          	jalr	1432(ra) # 8000218c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bfc:	2184a703          	lw	a4,536(s1)
    80004c00:	21c4a783          	lw	a5,540(s1)
    80004c04:	fcf70de3          	beq	a4,a5,80004bde <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c08:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c0a:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c0c:	05505463          	blez	s5,80004c54 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004c10:	2184a783          	lw	a5,536(s1)
    80004c14:	21c4a703          	lw	a4,540(s1)
    80004c18:	02f70e63          	beq	a4,a5,80004c54 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c1c:	0017871b          	addw	a4,a5,1
    80004c20:	20e4ac23          	sw	a4,536(s1)
    80004c24:	1ff7f793          	and	a5,a5,511
    80004c28:	97a6                	add	a5,a5,s1
    80004c2a:	0187c783          	lbu	a5,24(a5)
    80004c2e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c32:	4685                	li	a3,1
    80004c34:	fbf40613          	add	a2,s0,-65
    80004c38:	85ca                	mv	a1,s2
    80004c3a:	050a3503          	ld	a0,80(s4)
    80004c3e:	ffffd097          	auipc	ra,0xffffd
    80004c42:	a68080e7          	jalr	-1432(ra) # 800016a6 <copyout>
    80004c46:	01650763          	beq	a0,s6,80004c54 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c4a:	2985                	addw	s3,s3,1
    80004c4c:	0905                	add	s2,s2,1
    80004c4e:	fd3a91e3          	bne	s5,s3,80004c10 <piperead+0x70>
    80004c52:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c54:	21c48513          	add	a0,s1,540
    80004c58:	ffffd097          	auipc	ra,0xffffd
    80004c5c:	598080e7          	jalr	1432(ra) # 800021f0 <wakeup>
  release(&pi->lock);
    80004c60:	8526                	mv	a0,s1
    80004c62:	ffffc097          	auipc	ra,0xffffc
    80004c66:	024080e7          	jalr	36(ra) # 80000c86 <release>
  return i;
}
    80004c6a:	854e                	mv	a0,s3
    80004c6c:	60a6                	ld	ra,72(sp)
    80004c6e:	6406                	ld	s0,64(sp)
    80004c70:	74e2                	ld	s1,56(sp)
    80004c72:	7942                	ld	s2,48(sp)
    80004c74:	79a2                	ld	s3,40(sp)
    80004c76:	7a02                	ld	s4,32(sp)
    80004c78:	6ae2                	ld	s5,24(sp)
    80004c7a:	6b42                	ld	s6,16(sp)
    80004c7c:	6161                	add	sp,sp,80
    80004c7e:	8082                	ret
      release(&pi->lock);
    80004c80:	8526                	mv	a0,s1
    80004c82:	ffffc097          	auipc	ra,0xffffc
    80004c86:	004080e7          	jalr	4(ra) # 80000c86 <release>
      return -1;
    80004c8a:	59fd                	li	s3,-1
    80004c8c:	bff9                	j	80004c6a <piperead+0xca>

0000000080004c8e <flags2perm>:

// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c8e:	1141                	add	sp,sp,-16
    80004c90:	e422                	sd	s0,8(sp)
    80004c92:	0800                	add	s0,sp,16
    80004c94:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c96:	8905                	and	a0,a0,1
    80004c98:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c9a:	8b89                	and	a5,a5,2
    80004c9c:	c399                	beqz	a5,80004ca2 <flags2perm+0x14>
      perm |= PTE_W;
    80004c9e:	00456513          	or	a0,a0,4
    return perm;
}
    80004ca2:	6422                	ld	s0,8(sp)
    80004ca4:	0141                	add	sp,sp,16
    80004ca6:	8082                	ret

0000000080004ca8 <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004ca8:	c749                	beqz	a4,80004d32 <loadseg+0x8a>
{
    80004caa:	711d                	add	sp,sp,-96
    80004cac:	ec86                	sd	ra,88(sp)
    80004cae:	e8a2                	sd	s0,80(sp)
    80004cb0:	e4a6                	sd	s1,72(sp)
    80004cb2:	e0ca                	sd	s2,64(sp)
    80004cb4:	fc4e                	sd	s3,56(sp)
    80004cb6:	f852                	sd	s4,48(sp)
    80004cb8:	f456                	sd	s5,40(sp)
    80004cba:	f05a                	sd	s6,32(sp)
    80004cbc:	ec5e                	sd	s7,24(sp)
    80004cbe:	e862                	sd	s8,16(sp)
    80004cc0:	e466                	sd	s9,8(sp)
    80004cc2:	1080                	add	s0,sp,96
    80004cc4:	8aaa                	mv	s5,a0
    80004cc6:	8b2e                	mv	s6,a1
    80004cc8:	8bb2                	mv	s7,a2
    80004cca:	8c36                	mv	s8,a3
    80004ccc:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004cce:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cd0:	6c85                	lui	s9,0x1
    80004cd2:	6a05                	lui	s4,0x1
    80004cd4:	a815                	j	80004d08 <loadseg+0x60>
      panic("loadseg: address should exist");
    80004cd6:	00004517          	auipc	a0,0x4
    80004cda:	a4a50513          	add	a0,a0,-1462 # 80008720 <syscalls+0x280>
    80004cde:	ffffc097          	auipc	ra,0xffffc
    80004ce2:	85e080e7          	jalr	-1954(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004ce6:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004ce8:	8726                	mv	a4,s1
    80004cea:	012c06bb          	addw	a3,s8,s2
    80004cee:	4581                	li	a1,0
    80004cf0:	855e                	mv	a0,s7
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	d8a080e7          	jalr	-630(ra) # 80003a7c <readi>
    80004cfa:	2501                	sext.w	a0,a0
    80004cfc:	02951d63          	bne	a0,s1,80004d36 <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004d00:	012a093b          	addw	s2,s4,s2
    80004d04:	03397563          	bgeu	s2,s3,80004d2e <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004d08:	02091593          	sll	a1,s2,0x20
    80004d0c:	9181                	srl	a1,a1,0x20
    80004d0e:	95da                	add	a1,a1,s6
    80004d10:	8556                	mv	a0,s5
    80004d12:	ffffc097          	auipc	ra,0xffffc
    80004d16:	34c080e7          	jalr	844(ra) # 8000105e <walkaddr>
    80004d1a:	862a                	mv	a2,a0
    if(pa == 0)
    80004d1c:	dd4d                	beqz	a0,80004cd6 <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004d1e:	412984bb          	subw	s1,s3,s2
    80004d22:	0004879b          	sext.w	a5,s1
    80004d26:	fcfcf0e3          	bgeu	s9,a5,80004ce6 <loadseg+0x3e>
    80004d2a:	84d2                	mv	s1,s4
    80004d2c:	bf6d                	j	80004ce6 <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004d2e:	4501                	li	a0,0
    80004d30:	a021                	j	80004d38 <loadseg+0x90>
    80004d32:	4501                	li	a0,0
}
    80004d34:	8082                	ret
      return -1;
    80004d36:	557d                	li	a0,-1
}
    80004d38:	60e6                	ld	ra,88(sp)
    80004d3a:	6446                	ld	s0,80(sp)
    80004d3c:	64a6                	ld	s1,72(sp)
    80004d3e:	6906                	ld	s2,64(sp)
    80004d40:	79e2                	ld	s3,56(sp)
    80004d42:	7a42                	ld	s4,48(sp)
    80004d44:	7aa2                	ld	s5,40(sp)
    80004d46:	7b02                	ld	s6,32(sp)
    80004d48:	6be2                	ld	s7,24(sp)
    80004d4a:	6c42                	ld	s8,16(sp)
    80004d4c:	6ca2                	ld	s9,8(sp)
    80004d4e:	6125                	add	sp,sp,96
    80004d50:	8082                	ret

0000000080004d52 <exec>:
{
    80004d52:	7101                	add	sp,sp,-512
    80004d54:	ff86                	sd	ra,504(sp)
    80004d56:	fba2                	sd	s0,496(sp)
    80004d58:	f7a6                	sd	s1,488(sp)
    80004d5a:	f3ca                	sd	s2,480(sp)
    80004d5c:	efce                	sd	s3,472(sp)
    80004d5e:	ebd2                	sd	s4,464(sp)
    80004d60:	e7d6                	sd	s5,456(sp)
    80004d62:	e3da                	sd	s6,448(sp)
    80004d64:	ff5e                	sd	s7,440(sp)
    80004d66:	fb62                	sd	s8,432(sp)
    80004d68:	f766                	sd	s9,424(sp)
    80004d6a:	f36a                	sd	s10,416(sp)
    80004d6c:	ef6e                	sd	s11,408(sp)
    80004d6e:	0400                	add	s0,sp,512
    80004d70:	89aa                	mv	s3,a0
    80004d72:	8bae                	mv	s7,a1
  struct proc *p = myproc();
    80004d74:	ffffd097          	auipc	ra,0xffffd
    80004d78:	c82080e7          	jalr	-894(ra) # 800019f6 <myproc>
    80004d7c:	8a2a                	mv	s4,a0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004d7e:	4615                	li	a2,5
    80004d80:	00003597          	auipc	a1,0x3
    80004d84:	4d858593          	add	a1,a1,1240 # 80008258 <digits+0x218>
    80004d88:	854e                	mv	a0,s3
    80004d8a:	ffffc097          	auipc	ra,0xffffc
    80004d8e:	014080e7          	jalr	20(ra) # 80000d9e <strncmp>
    80004d92:	e159                	bnez	a0,80004e18 <exec+0xc6>
    80004d94:	160a0423          	sb	zero,360(s4) # 1168 <_entry-0x7fffee98>
  begin_op();
    80004d98:	fffff097          	auipc	ra,0xfffff
    80004d9c:	3d6080e7          	jalr	982(ra) # 8000416e <begin_op>
  if((ip = namei(path)) == 0){
    80004da0:	854e                	mv	a0,s3
    80004da2:	fffff097          	auipc	ra,0xfffff
    80004da6:	1cc080e7          	jalr	460(ra) # 80003f6e <namei>
    80004daa:	84aa                	mv	s1,a0
    80004dac:	c959                	beqz	a0,80004e42 <exec+0xf0>
  ilock(ip);
    80004dae:	fffff097          	auipc	ra,0xfffff
    80004db2:	a1a080e7          	jalr	-1510(ra) # 800037c8 <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004db6:	04000713          	li	a4,64
    80004dba:	4681                	li	a3,0
    80004dbc:	e5040613          	add	a2,s0,-432
    80004dc0:	4581                	li	a1,0
    80004dc2:	8526                	mv	a0,s1
    80004dc4:	fffff097          	auipc	ra,0xfffff
    80004dc8:	cb8080e7          	jalr	-840(ra) # 80003a7c <readi>
    80004dcc:	04000793          	li	a5,64
    80004dd0:	00f51a63          	bne	a0,a5,80004de4 <exec+0x92>
  if(elf.magic != ELF_MAGIC)
    80004dd4:	e5042703          	lw	a4,-432(s0)
    80004dd8:	464c47b7          	lui	a5,0x464c4
    80004ddc:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004de0:	06f70763          	beq	a4,a5,80004e4e <exec+0xfc>
    iunlockput(ip);
    80004de4:	8526                	mv	a0,s1
    80004de6:	fffff097          	auipc	ra,0xfffff
    80004dea:	c44080e7          	jalr	-956(ra) # 80003a2a <iunlockput>
    end_op();
    80004dee:	fffff097          	auipc	ra,0xfffff
    80004df2:	3fa080e7          	jalr	1018(ra) # 800041e8 <end_op>
  return -1;
    80004df6:	557d                	li	a0,-1
}
    80004df8:	70fe                	ld	ra,504(sp)
    80004dfa:	745e                	ld	s0,496(sp)
    80004dfc:	74be                	ld	s1,488(sp)
    80004dfe:	791e                	ld	s2,480(sp)
    80004e00:	69fe                	ld	s3,472(sp)
    80004e02:	6a5e                	ld	s4,464(sp)
    80004e04:	6abe                	ld	s5,456(sp)
    80004e06:	6b1e                	ld	s6,448(sp)
    80004e08:	7bfa                	ld	s7,440(sp)
    80004e0a:	7c5a                	ld	s8,432(sp)
    80004e0c:	7cba                	ld	s9,424(sp)
    80004e0e:	7d1a                	ld	s10,416(sp)
    80004e10:	6dfa                	ld	s11,408(sp)
    80004e12:	20010113          	add	sp,sp,512
    80004e16:	8082                	ret
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004e18:	4609                	li	a2,2
    80004e1a:	00003597          	auipc	a1,0x3
    80004e1e:	44658593          	add	a1,a1,1094 # 80008260 <digits+0x220>
    80004e22:	854e                	mv	a0,s3
    80004e24:	ffffc097          	auipc	ra,0xffffc
    80004e28:	f7a080e7          	jalr	-134(ra) # 80000d9e <strncmp>
    80004e2c:	00a037b3          	snez	a5,a0
    80004e30:	16fa0423          	sb	a5,360(s4)
  if (p->ondemand == true) {
    80004e34:	d135                	beqz	a0,80004d98 <exec+0x46>
    print_ondemand_proc(path);
    80004e36:	854e                	mv	a0,s3
    80004e38:	00002097          	auipc	ra,0x2
    80004e3c:	894080e7          	jalr	-1900(ra) # 800066cc <print_ondemand_proc>
    80004e40:	bfa1                	j	80004d98 <exec+0x46>
    end_op();
    80004e42:	fffff097          	auipc	ra,0xfffff
    80004e46:	3a6080e7          	jalr	934(ra) # 800041e8 <end_op>
    return -1;
    80004e4a:	557d                	li	a0,-1
    80004e4c:	b775                	j	80004df8 <exec+0xa6>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e4e:	8552                	mv	a0,s4
    80004e50:	ffffd097          	auipc	ra,0xffffd
    80004e54:	c6a080e7          	jalr	-918(ra) # 80001aba <proc_pagetable>
    80004e58:	8c2a                	mv	s8,a0
    80004e5a:	d549                	beqz	a0,80004de4 <exec+0x92>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e5c:	e7042903          	lw	s2,-400(s0)
    80004e60:	e8845783          	lhu	a5,-376(s0)
    80004e64:	c3f9                	beqz	a5,80004f2a <exec+0x1d8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e66:	4b01                	li	s6,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e68:	4a81                	li	s5,0
    if(ph.type != ELF_PROG_LOAD)
    80004e6a:	4d05                	li	s10,1
    if(ph.vaddr % PGSIZE != 0)
    80004e6c:	6d85                	lui	s11,0x1
    80004e6e:	1dfd                	add	s11,s11,-1 # fff <_entry-0x7ffff001>
    80004e70:	a03d                	j	80004e9e <exec+0x14c>
      print_skip_section(path, ph.vaddr, ph.memsz);
    80004e72:	2601                	sext.w	a2,a2
    80004e74:	854e                	mv	a0,s3
    80004e76:	00002097          	auipc	ra,0x2
    80004e7a:	878080e7          	jalr	-1928(ra) # 800066ee <print_skip_section>
      sz = PGROUNDUP(ph.vaddr + ph.memsz);
    80004e7e:	e2843b03          	ld	s6,-472(s0)
    80004e82:	e4043783          	ld	a5,-448(s0)
    80004e86:	9b3e                	add	s6,s6,a5
    80004e88:	9b6e                	add	s6,s6,s11
    80004e8a:	77fd                	lui	a5,0xfffff
    80004e8c:	00fb7b33          	and	s6,s6,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e90:	2a85                	addw	s5,s5,1
    80004e92:	0389091b          	addw	s2,s2,56
    80004e96:	e8845783          	lhu	a5,-376(s0)
    80004e9a:	08fad963          	bge	s5,a5,80004f2c <exec+0x1da>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e9e:	2901                	sext.w	s2,s2
    80004ea0:	03800713          	li	a4,56
    80004ea4:	86ca                	mv	a3,s2
    80004ea6:	e1840613          	add	a2,s0,-488
    80004eaa:	4581                	li	a1,0
    80004eac:	8526                	mv	a0,s1
    80004eae:	fffff097          	auipc	ra,0xfffff
    80004eb2:	bce080e7          	jalr	-1074(ra) # 80003a7c <readi>
    80004eb6:	03800793          	li	a5,56
    80004eba:	0af51d63          	bne	a0,a5,80004f74 <exec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004ebe:	e1842783          	lw	a5,-488(s0)
    80004ec2:	fda797e3          	bne	a5,s10,80004e90 <exec+0x13e>
    if(ph.memsz < ph.filesz)
    80004ec6:	e4043603          	ld	a2,-448(s0)
    80004eca:	e3843783          	ld	a5,-456(s0)
    80004ece:	0af66363          	bltu	a2,a5,80004f74 <exec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ed2:	e2843583          	ld	a1,-472(s0)
    80004ed6:	00b60cb3          	add	s9,a2,a1
    80004eda:	08bced63          	bltu	s9,a1,80004f74 <exec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004ede:	01b5f7b3          	and	a5,a1,s11
    80004ee2:	ebc9                	bnez	a5,80004f74 <exec+0x222>
    if(p->ondemand == false){
    80004ee4:	168a4783          	lbu	a5,360(s4)
    80004ee8:	f7c9                	bnez	a5,80004e72 <exec+0x120>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004eea:	e1c42503          	lw	a0,-484(s0)
    80004eee:	00000097          	auipc	ra,0x0
    80004ef2:	da0080e7          	jalr	-608(ra) # 80004c8e <flags2perm>
    80004ef6:	86aa                	mv	a3,a0
    80004ef8:	8666                	mv	a2,s9
    80004efa:	85da                	mv	a1,s6
    80004efc:	8562                	mv	a0,s8
    80004efe:	ffffc097          	auipc	ra,0xffffc
    80004f02:	506080e7          	jalr	1286(ra) # 80001404 <uvmalloc>
    80004f06:	8caa                	mv	s9,a0
    80004f08:	c535                	beqz	a0,80004f74 <exec+0x222>
      if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f0a:	e3842703          	lw	a4,-456(s0)
    80004f0e:	e2042683          	lw	a3,-480(s0)
    80004f12:	8626                	mv	a2,s1
    80004f14:	e2843583          	ld	a1,-472(s0)
    80004f18:	8562                	mv	a0,s8
    80004f1a:	00000097          	auipc	ra,0x0
    80004f1e:	d8e080e7          	jalr	-626(ra) # 80004ca8 <loadseg>
    80004f22:	1a054263          	bltz	a0,800050c6 <exec+0x374>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f26:	8b66                	mv	s6,s9
    80004f28:	b7a5                	j	80004e90 <exec+0x13e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f2a:	4b01                	li	s6,0
  iunlockput(ip);
    80004f2c:	8526                	mv	a0,s1
    80004f2e:	fffff097          	auipc	ra,0xfffff
    80004f32:	afc080e7          	jalr	-1284(ra) # 80003a2a <iunlockput>
  end_op();
    80004f36:	fffff097          	auipc	ra,0xfffff
    80004f3a:	2b2080e7          	jalr	690(ra) # 800041e8 <end_op>
  p = myproc();
    80004f3e:	ffffd097          	auipc	ra,0xffffd
    80004f42:	ab8080e7          	jalr	-1352(ra) # 800019f6 <myproc>
    80004f46:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004f48:	653c                	ld	a5,72(a0)
    80004f4a:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004f4e:	6a05                	lui	s4,0x1
    80004f50:	1a7d                	add	s4,s4,-1 # fff <_entry-0x7ffff001>
    80004f52:	9a5a                	add	s4,s4,s6
    80004f54:	77fd                	lui	a5,0xfffff
    80004f56:	00fa7a33          	and	s4,s4,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f5a:	4691                	li	a3,4
    80004f5c:	6609                	lui	a2,0x2
    80004f5e:	9652                	add	a2,a2,s4
    80004f60:	85d2                	mv	a1,s4
    80004f62:	8562                	mv	a0,s8
    80004f64:	ffffc097          	auipc	ra,0xffffc
    80004f68:	4a0080e7          	jalr	1184(ra) # 80001404 <uvmalloc>
    80004f6c:	8b2a                	mv	s6,a0
    80004f6e:	ed09                	bnez	a0,80004f88 <exec+0x236>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f70:	8b52                	mv	s6,s4
    80004f72:	4481                	li	s1,0
    proc_freepagetable(pagetable, sz);
    80004f74:	85da                	mv	a1,s6
    80004f76:	8562                	mv	a0,s8
    80004f78:	ffffd097          	auipc	ra,0xffffd
    80004f7c:	bde080e7          	jalr	-1058(ra) # 80001b56 <proc_freepagetable>
  return -1;
    80004f80:	557d                	li	a0,-1
  if(ip){
    80004f82:	e6048be3          	beqz	s1,80004df8 <exec+0xa6>
    80004f86:	bdb9                	j	80004de4 <exec+0x92>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f88:	75f9                	lui	a1,0xffffe
    80004f8a:	95aa                	add	a1,a1,a0
    80004f8c:	8562                	mv	a0,s8
    80004f8e:	ffffc097          	auipc	ra,0xffffc
    80004f92:	6b4080e7          	jalr	1716(ra) # 80001642 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f96:	7cfd                	lui	s9,0xfffff
    80004f98:	9cda                	add	s9,s9,s6
  for(argc = 0; argv[argc]; argc++) {
    80004f9a:	000bb503          	ld	a0,0(s7)
    80004f9e:	c125                	beqz	a0,80004ffe <exec+0x2ac>
    80004fa0:	e9040a13          	add	s4,s0,-368
    80004fa4:	f9040d93          	add	s11,s0,-112
  sp = sz;
    80004fa8:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004faa:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fac:	ffffc097          	auipc	ra,0xffffc
    80004fb0:	e9c080e7          	jalr	-356(ra) # 80000e48 <strlen>
    80004fb4:	2505                	addw	a0,a0,1
    80004fb6:	40a90533          	sub	a0,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fba:	ff057913          	and	s2,a0,-16
    if(sp < stackbase)
    80004fbe:	11996663          	bltu	s2,s9,800050ca <exec+0x378>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fc2:	000bba83          	ld	s5,0(s7)
    80004fc6:	8556                	mv	a0,s5
    80004fc8:	ffffc097          	auipc	ra,0xffffc
    80004fcc:	e80080e7          	jalr	-384(ra) # 80000e48 <strlen>
    80004fd0:	0015069b          	addw	a3,a0,1
    80004fd4:	8656                	mv	a2,s5
    80004fd6:	85ca                	mv	a1,s2
    80004fd8:	8562                	mv	a0,s8
    80004fda:	ffffc097          	auipc	ra,0xffffc
    80004fde:	6cc080e7          	jalr	1740(ra) # 800016a6 <copyout>
    80004fe2:	0e054663          	bltz	a0,800050ce <exec+0x37c>
    ustack[argc] = sp;
    80004fe6:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80004fea:	0485                	add	s1,s1,1
    80004fec:	0ba1                	add	s7,s7,8
    80004fee:	000bb503          	ld	a0,0(s7)
    80004ff2:	c901                	beqz	a0,80005002 <exec+0x2b0>
    if(argc >= MAXARG)
    80004ff4:	0a21                	add	s4,s4,8
    80004ff6:	fbba1be3          	bne	s4,s11,80004fac <exec+0x25a>
  ip = 0;
    80004ffa:	4481                	li	s1,0
    80004ffc:	bfa5                	j	80004f74 <exec+0x222>
  sp = sz;
    80004ffe:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80005000:	4481                	li	s1,0
  ustack[argc] = 0;
    80005002:	00349793          	sll	a5,s1,0x3
    80005006:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fe65850>
    8000500a:	97a2                	add	a5,a5,s0
    8000500c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005010:	00148693          	add	a3,s1,1
    80005014:	068e                	sll	a3,a3,0x3
    80005016:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000501a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000501e:	8a5a                	mv	s4,s6
  if(sp < stackbase)
    80005020:	f59968e3          	bltu	s2,s9,80004f70 <exec+0x21e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005024:	e9040613          	add	a2,s0,-368
    80005028:	85ca                	mv	a1,s2
    8000502a:	8562                	mv	a0,s8
    8000502c:	ffffc097          	auipc	ra,0xffffc
    80005030:	67a080e7          	jalr	1658(ra) # 800016a6 <copyout>
    80005034:	f2054ee3          	bltz	a0,80004f70 <exec+0x21e>
  p->trapframe->a1 = sp;
    80005038:	058d3783          	ld	a5,88(s10)
    8000503c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005040:	0009c703          	lbu	a4,0(s3)
    80005044:	cf11                	beqz	a4,80005060 <exec+0x30e>
    80005046:	00198793          	add	a5,s3,1
    if(*s == '/')
    8000504a:	02f00693          	li	a3,47
    8000504e:	a029                	j	80005058 <exec+0x306>
  for(last=s=path; *s; s++)
    80005050:	0785                	add	a5,a5,1
    80005052:	fff7c703          	lbu	a4,-1(a5)
    80005056:	c709                	beqz	a4,80005060 <exec+0x30e>
    if(*s == '/')
    80005058:	fed71ce3          	bne	a4,a3,80005050 <exec+0x2fe>
      last = s+1;
    8000505c:	89be                	mv	s3,a5
    8000505e:	bfcd                	j	80005050 <exec+0x2fe>
  safestrcpy(p->name, last, sizeof(p->name));
    80005060:	4641                	li	a2,16
    80005062:	85ce                	mv	a1,s3
    80005064:	158d0513          	add	a0,s10,344
    80005068:	ffffc097          	auipc	ra,0xffffc
    8000506c:	dae080e7          	jalr	-594(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005070:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80005074:	058d3823          	sd	s8,80(s10)
  p->sz = sz;
    80005078:	056d3423          	sd	s6,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000507c:	058d3783          	ld	a5,88(s10)
    80005080:	e6843703          	ld	a4,-408(s0)
    80005084:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005086:	058d3783          	ld	a5,88(s10)
    8000508a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000508e:	e0843583          	ld	a1,-504(s0)
    80005092:	ffffd097          	auipc	ra,0xffffd
    80005096:	ac4080e7          	jalr	-1340(ra) # 80001b56 <proc_freepagetable>
  for (int i = 0; i < MAXHEAP; i++) {
    8000509a:	170d0793          	add	a5,s10,368
    8000509e:	6699                	lui	a3,0x6
    800050a0:	f3068693          	add	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    800050a4:	96ea                	add	a3,a3,s10
    p->heap_tracker[i].addr            = 0xFFFFFFFFFFFFFFFF;
    800050a6:	577d                	li	a4,-1
    800050a8:	e398                	sd	a4,0(a5)
    p->heap_tracker[i].startblock      = -1;
    800050aa:	cbd8                	sw	a4,20(a5)
    p->heap_tracker[i].last_load_time  = 0xFFFFFFFFFFFFFFFF;
    800050ac:	e798                	sd	a4,8(a5)
    p->heap_tracker[i].loaded          = false;
    800050ae:	00078823          	sb	zero,16(a5)
  for (int i = 0; i < MAXHEAP; i++) {
    800050b2:	07e1                	add	a5,a5,24
    800050b4:	fed79ae3          	bne	a5,a3,800050a8 <exec+0x356>
  p->resident_heap_pages = 0;
    800050b8:	6799                	lui	a5,0x6
    800050ba:	9d3e                	add	s10,s10,a5
    800050bc:	f20d2823          	sw	zero,-208(s10)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050c0:	0004851b          	sext.w	a0,s1
    800050c4:	bb15                	j	80004df8 <exec+0xa6>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050c6:	8b66                	mv	s6,s9
    800050c8:	b575                	j	80004f74 <exec+0x222>
  ip = 0;
    800050ca:	4481                	li	s1,0
    800050cc:	b565                	j	80004f74 <exec+0x222>
    800050ce:	4481                	li	s1,0
  if(pagetable)
    800050d0:	b555                	j	80004f74 <exec+0x222>

00000000800050d2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050d2:	7179                	add	sp,sp,-48
    800050d4:	f406                	sd	ra,40(sp)
    800050d6:	f022                	sd	s0,32(sp)
    800050d8:	ec26                	sd	s1,24(sp)
    800050da:	e84a                	sd	s2,16(sp)
    800050dc:	1800                	add	s0,sp,48
    800050de:	892e                	mv	s2,a1
    800050e0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050e2:	fdc40593          	add	a1,s0,-36
    800050e6:	ffffe097          	auipc	ra,0xffffe
    800050ea:	b80080e7          	jalr	-1152(ra) # 80002c66 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050ee:	fdc42703          	lw	a4,-36(s0)
    800050f2:	47bd                	li	a5,15
    800050f4:	02e7eb63          	bltu	a5,a4,8000512a <argfd+0x58>
    800050f8:	ffffd097          	auipc	ra,0xffffd
    800050fc:	8fe080e7          	jalr	-1794(ra) # 800019f6 <myproc>
    80005100:	fdc42703          	lw	a4,-36(s0)
    80005104:	01a70793          	add	a5,a4,26
    80005108:	078e                	sll	a5,a5,0x3
    8000510a:	953e                	add	a0,a0,a5
    8000510c:	611c                	ld	a5,0(a0)
    8000510e:	c385                	beqz	a5,8000512e <argfd+0x5c>
    return -1;
  if(pfd)
    80005110:	00090463          	beqz	s2,80005118 <argfd+0x46>
    *pfd = fd;
    80005114:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005118:	4501                	li	a0,0
  if(pf)
    8000511a:	c091                	beqz	s1,8000511e <argfd+0x4c>
    *pf = f;
    8000511c:	e09c                	sd	a5,0(s1)
}
    8000511e:	70a2                	ld	ra,40(sp)
    80005120:	7402                	ld	s0,32(sp)
    80005122:	64e2                	ld	s1,24(sp)
    80005124:	6942                	ld	s2,16(sp)
    80005126:	6145                	add	sp,sp,48
    80005128:	8082                	ret
    return -1;
    8000512a:	557d                	li	a0,-1
    8000512c:	bfcd                	j	8000511e <argfd+0x4c>
    8000512e:	557d                	li	a0,-1
    80005130:	b7fd                	j	8000511e <argfd+0x4c>

0000000080005132 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005132:	1101                	add	sp,sp,-32
    80005134:	ec06                	sd	ra,24(sp)
    80005136:	e822                	sd	s0,16(sp)
    80005138:	e426                	sd	s1,8(sp)
    8000513a:	1000                	add	s0,sp,32
    8000513c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000513e:	ffffd097          	auipc	ra,0xffffd
    80005142:	8b8080e7          	jalr	-1864(ra) # 800019f6 <myproc>
    80005146:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005148:	0d050793          	add	a5,a0,208
    8000514c:	4501                	li	a0,0
    8000514e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005150:	6398                	ld	a4,0(a5)
    80005152:	cb19                	beqz	a4,80005168 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005154:	2505                	addw	a0,a0,1
    80005156:	07a1                	add	a5,a5,8 # 6008 <_entry-0x7fff9ff8>
    80005158:	fed51ce3          	bne	a0,a3,80005150 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000515c:	557d                	li	a0,-1
}
    8000515e:	60e2                	ld	ra,24(sp)
    80005160:	6442                	ld	s0,16(sp)
    80005162:	64a2                	ld	s1,8(sp)
    80005164:	6105                	add	sp,sp,32
    80005166:	8082                	ret
      p->ofile[fd] = f;
    80005168:	01a50793          	add	a5,a0,26
    8000516c:	078e                	sll	a5,a5,0x3
    8000516e:	963e                	add	a2,a2,a5
    80005170:	e204                	sd	s1,0(a2)
      return fd;
    80005172:	b7f5                	j	8000515e <fdalloc+0x2c>

0000000080005174 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005174:	715d                	add	sp,sp,-80
    80005176:	e486                	sd	ra,72(sp)
    80005178:	e0a2                	sd	s0,64(sp)
    8000517a:	fc26                	sd	s1,56(sp)
    8000517c:	f84a                	sd	s2,48(sp)
    8000517e:	f44e                	sd	s3,40(sp)
    80005180:	f052                	sd	s4,32(sp)
    80005182:	ec56                	sd	s5,24(sp)
    80005184:	e85a                	sd	s6,16(sp)
    80005186:	0880                	add	s0,sp,80
    80005188:	8b2e                	mv	s6,a1
    8000518a:	89b2                	mv	s3,a2
    8000518c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000518e:	fb040593          	add	a1,s0,-80
    80005192:	fffff097          	auipc	ra,0xfffff
    80005196:	dfa080e7          	jalr	-518(ra) # 80003f8c <nameiparent>
    8000519a:	84aa                	mv	s1,a0
    8000519c:	14050b63          	beqz	a0,800052f2 <create+0x17e>
    return 0;

  ilock(dp);
    800051a0:	ffffe097          	auipc	ra,0xffffe
    800051a4:	628080e7          	jalr	1576(ra) # 800037c8 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051a8:	4601                	li	a2,0
    800051aa:	fb040593          	add	a1,s0,-80
    800051ae:	8526                	mv	a0,s1
    800051b0:	fffff097          	auipc	ra,0xfffff
    800051b4:	afc080e7          	jalr	-1284(ra) # 80003cac <dirlookup>
    800051b8:	8aaa                	mv	s5,a0
    800051ba:	c921                	beqz	a0,8000520a <create+0x96>
    iunlockput(dp);
    800051bc:	8526                	mv	a0,s1
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	86c080e7          	jalr	-1940(ra) # 80003a2a <iunlockput>
    ilock(ip);
    800051c6:	8556                	mv	a0,s5
    800051c8:	ffffe097          	auipc	ra,0xffffe
    800051cc:	600080e7          	jalr	1536(ra) # 800037c8 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051d0:	4789                	li	a5,2
    800051d2:	02fb1563          	bne	s6,a5,800051fc <create+0x88>
    800051d6:	044ad783          	lhu	a5,68(s5)
    800051da:	37f9                	addw	a5,a5,-2
    800051dc:	17c2                	sll	a5,a5,0x30
    800051de:	93c1                	srl	a5,a5,0x30
    800051e0:	4705                	li	a4,1
    800051e2:	00f76d63          	bltu	a4,a5,800051fc <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051e6:	8556                	mv	a0,s5
    800051e8:	60a6                	ld	ra,72(sp)
    800051ea:	6406                	ld	s0,64(sp)
    800051ec:	74e2                	ld	s1,56(sp)
    800051ee:	7942                	ld	s2,48(sp)
    800051f0:	79a2                	ld	s3,40(sp)
    800051f2:	7a02                	ld	s4,32(sp)
    800051f4:	6ae2                	ld	s5,24(sp)
    800051f6:	6b42                	ld	s6,16(sp)
    800051f8:	6161                	add	sp,sp,80
    800051fa:	8082                	ret
    iunlockput(ip);
    800051fc:	8556                	mv	a0,s5
    800051fe:	fffff097          	auipc	ra,0xfffff
    80005202:	82c080e7          	jalr	-2004(ra) # 80003a2a <iunlockput>
    return 0;
    80005206:	4a81                	li	s5,0
    80005208:	bff9                	j	800051e6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000520a:	85da                	mv	a1,s6
    8000520c:	4088                	lw	a0,0(s1)
    8000520e:	ffffe097          	auipc	ra,0xffffe
    80005212:	422080e7          	jalr	1058(ra) # 80003630 <ialloc>
    80005216:	8a2a                	mv	s4,a0
    80005218:	c529                	beqz	a0,80005262 <create+0xee>
  ilock(ip);
    8000521a:	ffffe097          	auipc	ra,0xffffe
    8000521e:	5ae080e7          	jalr	1454(ra) # 800037c8 <ilock>
  ip->major = major;
    80005222:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005226:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000522a:	4905                	li	s2,1
    8000522c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005230:	8552                	mv	a0,s4
    80005232:	ffffe097          	auipc	ra,0xffffe
    80005236:	4ca080e7          	jalr	1226(ra) # 800036fc <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000523a:	032b0b63          	beq	s6,s2,80005270 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000523e:	004a2603          	lw	a2,4(s4)
    80005242:	fb040593          	add	a1,s0,-80
    80005246:	8526                	mv	a0,s1
    80005248:	fffff097          	auipc	ra,0xfffff
    8000524c:	c74080e7          	jalr	-908(ra) # 80003ebc <dirlink>
    80005250:	06054f63          	bltz	a0,800052ce <create+0x15a>
  iunlockput(dp);
    80005254:	8526                	mv	a0,s1
    80005256:	ffffe097          	auipc	ra,0xffffe
    8000525a:	7d4080e7          	jalr	2004(ra) # 80003a2a <iunlockput>
  return ip;
    8000525e:	8ad2                	mv	s5,s4
    80005260:	b759                	j	800051e6 <create+0x72>
    iunlockput(dp);
    80005262:	8526                	mv	a0,s1
    80005264:	ffffe097          	auipc	ra,0xffffe
    80005268:	7c6080e7          	jalr	1990(ra) # 80003a2a <iunlockput>
    return 0;
    8000526c:	8ad2                	mv	s5,s4
    8000526e:	bfa5                	j	800051e6 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005270:	004a2603          	lw	a2,4(s4)
    80005274:	00003597          	auipc	a1,0x3
    80005278:	4cc58593          	add	a1,a1,1228 # 80008740 <syscalls+0x2a0>
    8000527c:	8552                	mv	a0,s4
    8000527e:	fffff097          	auipc	ra,0xfffff
    80005282:	c3e080e7          	jalr	-962(ra) # 80003ebc <dirlink>
    80005286:	04054463          	bltz	a0,800052ce <create+0x15a>
    8000528a:	40d0                	lw	a2,4(s1)
    8000528c:	00003597          	auipc	a1,0x3
    80005290:	4bc58593          	add	a1,a1,1212 # 80008748 <syscalls+0x2a8>
    80005294:	8552                	mv	a0,s4
    80005296:	fffff097          	auipc	ra,0xfffff
    8000529a:	c26080e7          	jalr	-986(ra) # 80003ebc <dirlink>
    8000529e:	02054863          	bltz	a0,800052ce <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800052a2:	004a2603          	lw	a2,4(s4)
    800052a6:	fb040593          	add	a1,s0,-80
    800052aa:	8526                	mv	a0,s1
    800052ac:	fffff097          	auipc	ra,0xfffff
    800052b0:	c10080e7          	jalr	-1008(ra) # 80003ebc <dirlink>
    800052b4:	00054d63          	bltz	a0,800052ce <create+0x15a>
    dp->nlink++;  // for ".."
    800052b8:	04a4d783          	lhu	a5,74(s1)
    800052bc:	2785                	addw	a5,a5,1
    800052be:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052c2:	8526                	mv	a0,s1
    800052c4:	ffffe097          	auipc	ra,0xffffe
    800052c8:	438080e7          	jalr	1080(ra) # 800036fc <iupdate>
    800052cc:	b761                	j	80005254 <create+0xe0>
  ip->nlink = 0;
    800052ce:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800052d2:	8552                	mv	a0,s4
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	428080e7          	jalr	1064(ra) # 800036fc <iupdate>
  iunlockput(ip);
    800052dc:	8552                	mv	a0,s4
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	74c080e7          	jalr	1868(ra) # 80003a2a <iunlockput>
  iunlockput(dp);
    800052e6:	8526                	mv	a0,s1
    800052e8:	ffffe097          	auipc	ra,0xffffe
    800052ec:	742080e7          	jalr	1858(ra) # 80003a2a <iunlockput>
  return 0;
    800052f0:	bddd                	j	800051e6 <create+0x72>
    return 0;
    800052f2:	8aaa                	mv	s5,a0
    800052f4:	bdcd                	j	800051e6 <create+0x72>

00000000800052f6 <sys_dup>:
{
    800052f6:	7179                	add	sp,sp,-48
    800052f8:	f406                	sd	ra,40(sp)
    800052fa:	f022                	sd	s0,32(sp)
    800052fc:	ec26                	sd	s1,24(sp)
    800052fe:	e84a                	sd	s2,16(sp)
    80005300:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005302:	fd840613          	add	a2,s0,-40
    80005306:	4581                	li	a1,0
    80005308:	4501                	li	a0,0
    8000530a:	00000097          	auipc	ra,0x0
    8000530e:	dc8080e7          	jalr	-568(ra) # 800050d2 <argfd>
    return -1;
    80005312:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005314:	02054363          	bltz	a0,8000533a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005318:	fd843903          	ld	s2,-40(s0)
    8000531c:	854a                	mv	a0,s2
    8000531e:	00000097          	auipc	ra,0x0
    80005322:	e14080e7          	jalr	-492(ra) # 80005132 <fdalloc>
    80005326:	84aa                	mv	s1,a0
    return -1;
    80005328:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000532a:	00054863          	bltz	a0,8000533a <sys_dup+0x44>
  filedup(f);
    8000532e:	854a                	mv	a0,s2
    80005330:	fffff097          	auipc	ra,0xfffff
    80005334:	2b0080e7          	jalr	688(ra) # 800045e0 <filedup>
  return fd;
    80005338:	87a6                	mv	a5,s1
}
    8000533a:	853e                	mv	a0,a5
    8000533c:	70a2                	ld	ra,40(sp)
    8000533e:	7402                	ld	s0,32(sp)
    80005340:	64e2                	ld	s1,24(sp)
    80005342:	6942                	ld	s2,16(sp)
    80005344:	6145                	add	sp,sp,48
    80005346:	8082                	ret

0000000080005348 <sys_read>:
{
    80005348:	7179                	add	sp,sp,-48
    8000534a:	f406                	sd	ra,40(sp)
    8000534c:	f022                	sd	s0,32(sp)
    8000534e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005350:	fd840593          	add	a1,s0,-40
    80005354:	4505                	li	a0,1
    80005356:	ffffe097          	auipc	ra,0xffffe
    8000535a:	930080e7          	jalr	-1744(ra) # 80002c86 <argaddr>
  argint(2, &n);
    8000535e:	fe440593          	add	a1,s0,-28
    80005362:	4509                	li	a0,2
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	902080e7          	jalr	-1790(ra) # 80002c66 <argint>
  if(argfd(0, 0, &f) < 0)
    8000536c:	fe840613          	add	a2,s0,-24
    80005370:	4581                	li	a1,0
    80005372:	4501                	li	a0,0
    80005374:	00000097          	auipc	ra,0x0
    80005378:	d5e080e7          	jalr	-674(ra) # 800050d2 <argfd>
    8000537c:	87aa                	mv	a5,a0
    return -1;
    8000537e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005380:	0007cc63          	bltz	a5,80005398 <sys_read+0x50>
  return fileread(f, p, n);
    80005384:	fe442603          	lw	a2,-28(s0)
    80005388:	fd843583          	ld	a1,-40(s0)
    8000538c:	fe843503          	ld	a0,-24(s0)
    80005390:	fffff097          	auipc	ra,0xfffff
    80005394:	3dc080e7          	jalr	988(ra) # 8000476c <fileread>
}
    80005398:	70a2                	ld	ra,40(sp)
    8000539a:	7402                	ld	s0,32(sp)
    8000539c:	6145                	add	sp,sp,48
    8000539e:	8082                	ret

00000000800053a0 <sys_write>:
{
    800053a0:	7179                	add	sp,sp,-48
    800053a2:	f406                	sd	ra,40(sp)
    800053a4:	f022                	sd	s0,32(sp)
    800053a6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800053a8:	fd840593          	add	a1,s0,-40
    800053ac:	4505                	li	a0,1
    800053ae:	ffffe097          	auipc	ra,0xffffe
    800053b2:	8d8080e7          	jalr	-1832(ra) # 80002c86 <argaddr>
  argint(2, &n);
    800053b6:	fe440593          	add	a1,s0,-28
    800053ba:	4509                	li	a0,2
    800053bc:	ffffe097          	auipc	ra,0xffffe
    800053c0:	8aa080e7          	jalr	-1878(ra) # 80002c66 <argint>
  if(argfd(0, 0, &f) < 0)
    800053c4:	fe840613          	add	a2,s0,-24
    800053c8:	4581                	li	a1,0
    800053ca:	4501                	li	a0,0
    800053cc:	00000097          	auipc	ra,0x0
    800053d0:	d06080e7          	jalr	-762(ra) # 800050d2 <argfd>
    800053d4:	87aa                	mv	a5,a0
    return -1;
    800053d6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053d8:	0007cc63          	bltz	a5,800053f0 <sys_write+0x50>
  return filewrite(f, p, n);
    800053dc:	fe442603          	lw	a2,-28(s0)
    800053e0:	fd843583          	ld	a1,-40(s0)
    800053e4:	fe843503          	ld	a0,-24(s0)
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	446080e7          	jalr	1094(ra) # 8000482e <filewrite>
}
    800053f0:	70a2                	ld	ra,40(sp)
    800053f2:	7402                	ld	s0,32(sp)
    800053f4:	6145                	add	sp,sp,48
    800053f6:	8082                	ret

00000000800053f8 <sys_close>:
{
    800053f8:	1101                	add	sp,sp,-32
    800053fa:	ec06                	sd	ra,24(sp)
    800053fc:	e822                	sd	s0,16(sp)
    800053fe:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005400:	fe040613          	add	a2,s0,-32
    80005404:	fec40593          	add	a1,s0,-20
    80005408:	4501                	li	a0,0
    8000540a:	00000097          	auipc	ra,0x0
    8000540e:	cc8080e7          	jalr	-824(ra) # 800050d2 <argfd>
    return -1;
    80005412:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005414:	02054463          	bltz	a0,8000543c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005418:	ffffc097          	auipc	ra,0xffffc
    8000541c:	5de080e7          	jalr	1502(ra) # 800019f6 <myproc>
    80005420:	fec42783          	lw	a5,-20(s0)
    80005424:	07e9                	add	a5,a5,26
    80005426:	078e                	sll	a5,a5,0x3
    80005428:	953e                	add	a0,a0,a5
    8000542a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000542e:	fe043503          	ld	a0,-32(s0)
    80005432:	fffff097          	auipc	ra,0xfffff
    80005436:	200080e7          	jalr	512(ra) # 80004632 <fileclose>
  return 0;
    8000543a:	4781                	li	a5,0
}
    8000543c:	853e                	mv	a0,a5
    8000543e:	60e2                	ld	ra,24(sp)
    80005440:	6442                	ld	s0,16(sp)
    80005442:	6105                	add	sp,sp,32
    80005444:	8082                	ret

0000000080005446 <sys_fstat>:
{
    80005446:	1101                	add	sp,sp,-32
    80005448:	ec06                	sd	ra,24(sp)
    8000544a:	e822                	sd	s0,16(sp)
    8000544c:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000544e:	fe040593          	add	a1,s0,-32
    80005452:	4505                	li	a0,1
    80005454:	ffffe097          	auipc	ra,0xffffe
    80005458:	832080e7          	jalr	-1998(ra) # 80002c86 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000545c:	fe840613          	add	a2,s0,-24
    80005460:	4581                	li	a1,0
    80005462:	4501                	li	a0,0
    80005464:	00000097          	auipc	ra,0x0
    80005468:	c6e080e7          	jalr	-914(ra) # 800050d2 <argfd>
    8000546c:	87aa                	mv	a5,a0
    return -1;
    8000546e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005470:	0007ca63          	bltz	a5,80005484 <sys_fstat+0x3e>
  return filestat(f, st);
    80005474:	fe043583          	ld	a1,-32(s0)
    80005478:	fe843503          	ld	a0,-24(s0)
    8000547c:	fffff097          	auipc	ra,0xfffff
    80005480:	27e080e7          	jalr	638(ra) # 800046fa <filestat>
}
    80005484:	60e2                	ld	ra,24(sp)
    80005486:	6442                	ld	s0,16(sp)
    80005488:	6105                	add	sp,sp,32
    8000548a:	8082                	ret

000000008000548c <sys_link>:
{
    8000548c:	7169                	add	sp,sp,-304
    8000548e:	f606                	sd	ra,296(sp)
    80005490:	f222                	sd	s0,288(sp)
    80005492:	ee26                	sd	s1,280(sp)
    80005494:	ea4a                	sd	s2,272(sp)
    80005496:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005498:	08000613          	li	a2,128
    8000549c:	ed040593          	add	a1,s0,-304
    800054a0:	4501                	li	a0,0
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	804080e7          	jalr	-2044(ra) # 80002ca6 <argstr>
    return -1;
    800054aa:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054ac:	10054e63          	bltz	a0,800055c8 <sys_link+0x13c>
    800054b0:	08000613          	li	a2,128
    800054b4:	f5040593          	add	a1,s0,-176
    800054b8:	4505                	li	a0,1
    800054ba:	ffffd097          	auipc	ra,0xffffd
    800054be:	7ec080e7          	jalr	2028(ra) # 80002ca6 <argstr>
    return -1;
    800054c2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054c4:	10054263          	bltz	a0,800055c8 <sys_link+0x13c>
  begin_op();
    800054c8:	fffff097          	auipc	ra,0xfffff
    800054cc:	ca6080e7          	jalr	-858(ra) # 8000416e <begin_op>
  if((ip = namei(old)) == 0){
    800054d0:	ed040513          	add	a0,s0,-304
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	a9a080e7          	jalr	-1382(ra) # 80003f6e <namei>
    800054dc:	84aa                	mv	s1,a0
    800054de:	c551                	beqz	a0,8000556a <sys_link+0xde>
  ilock(ip);
    800054e0:	ffffe097          	auipc	ra,0xffffe
    800054e4:	2e8080e7          	jalr	744(ra) # 800037c8 <ilock>
  if(ip->type == T_DIR){
    800054e8:	04449703          	lh	a4,68(s1)
    800054ec:	4785                	li	a5,1
    800054ee:	08f70463          	beq	a4,a5,80005576 <sys_link+0xea>
  ip->nlink++;
    800054f2:	04a4d783          	lhu	a5,74(s1)
    800054f6:	2785                	addw	a5,a5,1
    800054f8:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054fc:	8526                	mv	a0,s1
    800054fe:	ffffe097          	auipc	ra,0xffffe
    80005502:	1fe080e7          	jalr	510(ra) # 800036fc <iupdate>
  iunlock(ip);
    80005506:	8526                	mv	a0,s1
    80005508:	ffffe097          	auipc	ra,0xffffe
    8000550c:	382080e7          	jalr	898(ra) # 8000388a <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005510:	fd040593          	add	a1,s0,-48
    80005514:	f5040513          	add	a0,s0,-176
    80005518:	fffff097          	auipc	ra,0xfffff
    8000551c:	a74080e7          	jalr	-1420(ra) # 80003f8c <nameiparent>
    80005520:	892a                	mv	s2,a0
    80005522:	c935                	beqz	a0,80005596 <sys_link+0x10a>
  ilock(dp);
    80005524:	ffffe097          	auipc	ra,0xffffe
    80005528:	2a4080e7          	jalr	676(ra) # 800037c8 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000552c:	00092703          	lw	a4,0(s2)
    80005530:	409c                	lw	a5,0(s1)
    80005532:	04f71d63          	bne	a4,a5,8000558c <sys_link+0x100>
    80005536:	40d0                	lw	a2,4(s1)
    80005538:	fd040593          	add	a1,s0,-48
    8000553c:	854a                	mv	a0,s2
    8000553e:	fffff097          	auipc	ra,0xfffff
    80005542:	97e080e7          	jalr	-1666(ra) # 80003ebc <dirlink>
    80005546:	04054363          	bltz	a0,8000558c <sys_link+0x100>
  iunlockput(dp);
    8000554a:	854a                	mv	a0,s2
    8000554c:	ffffe097          	auipc	ra,0xffffe
    80005550:	4de080e7          	jalr	1246(ra) # 80003a2a <iunlockput>
  iput(ip);
    80005554:	8526                	mv	a0,s1
    80005556:	ffffe097          	auipc	ra,0xffffe
    8000555a:	42c080e7          	jalr	1068(ra) # 80003982 <iput>
  end_op();
    8000555e:	fffff097          	auipc	ra,0xfffff
    80005562:	c8a080e7          	jalr	-886(ra) # 800041e8 <end_op>
  return 0;
    80005566:	4781                	li	a5,0
    80005568:	a085                	j	800055c8 <sys_link+0x13c>
    end_op();
    8000556a:	fffff097          	auipc	ra,0xfffff
    8000556e:	c7e080e7          	jalr	-898(ra) # 800041e8 <end_op>
    return -1;
    80005572:	57fd                	li	a5,-1
    80005574:	a891                	j	800055c8 <sys_link+0x13c>
    iunlockput(ip);
    80005576:	8526                	mv	a0,s1
    80005578:	ffffe097          	auipc	ra,0xffffe
    8000557c:	4b2080e7          	jalr	1202(ra) # 80003a2a <iunlockput>
    end_op();
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	c68080e7          	jalr	-920(ra) # 800041e8 <end_op>
    return -1;
    80005588:	57fd                	li	a5,-1
    8000558a:	a83d                	j	800055c8 <sys_link+0x13c>
    iunlockput(dp);
    8000558c:	854a                	mv	a0,s2
    8000558e:	ffffe097          	auipc	ra,0xffffe
    80005592:	49c080e7          	jalr	1180(ra) # 80003a2a <iunlockput>
  ilock(ip);
    80005596:	8526                	mv	a0,s1
    80005598:	ffffe097          	auipc	ra,0xffffe
    8000559c:	230080e7          	jalr	560(ra) # 800037c8 <ilock>
  ip->nlink--;
    800055a0:	04a4d783          	lhu	a5,74(s1)
    800055a4:	37fd                	addw	a5,a5,-1
    800055a6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055aa:	8526                	mv	a0,s1
    800055ac:	ffffe097          	auipc	ra,0xffffe
    800055b0:	150080e7          	jalr	336(ra) # 800036fc <iupdate>
  iunlockput(ip);
    800055b4:	8526                	mv	a0,s1
    800055b6:	ffffe097          	auipc	ra,0xffffe
    800055ba:	474080e7          	jalr	1140(ra) # 80003a2a <iunlockput>
  end_op();
    800055be:	fffff097          	auipc	ra,0xfffff
    800055c2:	c2a080e7          	jalr	-982(ra) # 800041e8 <end_op>
  return -1;
    800055c6:	57fd                	li	a5,-1
}
    800055c8:	853e                	mv	a0,a5
    800055ca:	70b2                	ld	ra,296(sp)
    800055cc:	7412                	ld	s0,288(sp)
    800055ce:	64f2                	ld	s1,280(sp)
    800055d0:	6952                	ld	s2,272(sp)
    800055d2:	6155                	add	sp,sp,304
    800055d4:	8082                	ret

00000000800055d6 <sys_unlink>:
{
    800055d6:	7151                	add	sp,sp,-240
    800055d8:	f586                	sd	ra,232(sp)
    800055da:	f1a2                	sd	s0,224(sp)
    800055dc:	eda6                	sd	s1,216(sp)
    800055de:	e9ca                	sd	s2,208(sp)
    800055e0:	e5ce                	sd	s3,200(sp)
    800055e2:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055e4:	08000613          	li	a2,128
    800055e8:	f3040593          	add	a1,s0,-208
    800055ec:	4501                	li	a0,0
    800055ee:	ffffd097          	auipc	ra,0xffffd
    800055f2:	6b8080e7          	jalr	1720(ra) # 80002ca6 <argstr>
    800055f6:	18054163          	bltz	a0,80005778 <sys_unlink+0x1a2>
  begin_op();
    800055fa:	fffff097          	auipc	ra,0xfffff
    800055fe:	b74080e7          	jalr	-1164(ra) # 8000416e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005602:	fb040593          	add	a1,s0,-80
    80005606:	f3040513          	add	a0,s0,-208
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	982080e7          	jalr	-1662(ra) # 80003f8c <nameiparent>
    80005612:	84aa                	mv	s1,a0
    80005614:	c979                	beqz	a0,800056ea <sys_unlink+0x114>
  ilock(dp);
    80005616:	ffffe097          	auipc	ra,0xffffe
    8000561a:	1b2080e7          	jalr	434(ra) # 800037c8 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000561e:	00003597          	auipc	a1,0x3
    80005622:	12258593          	add	a1,a1,290 # 80008740 <syscalls+0x2a0>
    80005626:	fb040513          	add	a0,s0,-80
    8000562a:	ffffe097          	auipc	ra,0xffffe
    8000562e:	668080e7          	jalr	1640(ra) # 80003c92 <namecmp>
    80005632:	14050a63          	beqz	a0,80005786 <sys_unlink+0x1b0>
    80005636:	00003597          	auipc	a1,0x3
    8000563a:	11258593          	add	a1,a1,274 # 80008748 <syscalls+0x2a8>
    8000563e:	fb040513          	add	a0,s0,-80
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	650080e7          	jalr	1616(ra) # 80003c92 <namecmp>
    8000564a:	12050e63          	beqz	a0,80005786 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000564e:	f2c40613          	add	a2,s0,-212
    80005652:	fb040593          	add	a1,s0,-80
    80005656:	8526                	mv	a0,s1
    80005658:	ffffe097          	auipc	ra,0xffffe
    8000565c:	654080e7          	jalr	1620(ra) # 80003cac <dirlookup>
    80005660:	892a                	mv	s2,a0
    80005662:	12050263          	beqz	a0,80005786 <sys_unlink+0x1b0>
  ilock(ip);
    80005666:	ffffe097          	auipc	ra,0xffffe
    8000566a:	162080e7          	jalr	354(ra) # 800037c8 <ilock>
  if(ip->nlink < 1)
    8000566e:	04a91783          	lh	a5,74(s2)
    80005672:	08f05263          	blez	a5,800056f6 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005676:	04491703          	lh	a4,68(s2)
    8000567a:	4785                	li	a5,1
    8000567c:	08f70563          	beq	a4,a5,80005706 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005680:	4641                	li	a2,16
    80005682:	4581                	li	a1,0
    80005684:	fc040513          	add	a0,s0,-64
    80005688:	ffffb097          	auipc	ra,0xffffb
    8000568c:	646080e7          	jalr	1606(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005690:	4741                	li	a4,16
    80005692:	f2c42683          	lw	a3,-212(s0)
    80005696:	fc040613          	add	a2,s0,-64
    8000569a:	4581                	li	a1,0
    8000569c:	8526                	mv	a0,s1
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	4d6080e7          	jalr	1238(ra) # 80003b74 <writei>
    800056a6:	47c1                	li	a5,16
    800056a8:	0af51563          	bne	a0,a5,80005752 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056ac:	04491703          	lh	a4,68(s2)
    800056b0:	4785                	li	a5,1
    800056b2:	0af70863          	beq	a4,a5,80005762 <sys_unlink+0x18c>
  iunlockput(dp);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	372080e7          	jalr	882(ra) # 80003a2a <iunlockput>
  ip->nlink--;
    800056c0:	04a95783          	lhu	a5,74(s2)
    800056c4:	37fd                	addw	a5,a5,-1
    800056c6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056ca:	854a                	mv	a0,s2
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	030080e7          	jalr	48(ra) # 800036fc <iupdate>
  iunlockput(ip);
    800056d4:	854a                	mv	a0,s2
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	354080e7          	jalr	852(ra) # 80003a2a <iunlockput>
  end_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	b0a080e7          	jalr	-1270(ra) # 800041e8 <end_op>
  return 0;
    800056e6:	4501                	li	a0,0
    800056e8:	a84d                	j	8000579a <sys_unlink+0x1c4>
    end_op();
    800056ea:	fffff097          	auipc	ra,0xfffff
    800056ee:	afe080e7          	jalr	-1282(ra) # 800041e8 <end_op>
    return -1;
    800056f2:	557d                	li	a0,-1
    800056f4:	a05d                	j	8000579a <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800056f6:	00003517          	auipc	a0,0x3
    800056fa:	05a50513          	add	a0,a0,90 # 80008750 <syscalls+0x2b0>
    800056fe:	ffffb097          	auipc	ra,0xffffb
    80005702:	e3e080e7          	jalr	-450(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005706:	04c92703          	lw	a4,76(s2)
    8000570a:	02000793          	li	a5,32
    8000570e:	f6e7f9e3          	bgeu	a5,a4,80005680 <sys_unlink+0xaa>
    80005712:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005716:	4741                	li	a4,16
    80005718:	86ce                	mv	a3,s3
    8000571a:	f1840613          	add	a2,s0,-232
    8000571e:	4581                	li	a1,0
    80005720:	854a                	mv	a0,s2
    80005722:	ffffe097          	auipc	ra,0xffffe
    80005726:	35a080e7          	jalr	858(ra) # 80003a7c <readi>
    8000572a:	47c1                	li	a5,16
    8000572c:	00f51b63          	bne	a0,a5,80005742 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005730:	f1845783          	lhu	a5,-232(s0)
    80005734:	e7a1                	bnez	a5,8000577c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005736:	29c1                	addw	s3,s3,16
    80005738:	04c92783          	lw	a5,76(s2)
    8000573c:	fcf9ede3          	bltu	s3,a5,80005716 <sys_unlink+0x140>
    80005740:	b781                	j	80005680 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005742:	00003517          	auipc	a0,0x3
    80005746:	02650513          	add	a0,a0,38 # 80008768 <syscalls+0x2c8>
    8000574a:	ffffb097          	auipc	ra,0xffffb
    8000574e:	df2080e7          	jalr	-526(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005752:	00003517          	auipc	a0,0x3
    80005756:	02e50513          	add	a0,a0,46 # 80008780 <syscalls+0x2e0>
    8000575a:	ffffb097          	auipc	ra,0xffffb
    8000575e:	de2080e7          	jalr	-542(ra) # 8000053c <panic>
    dp->nlink--;
    80005762:	04a4d783          	lhu	a5,74(s1)
    80005766:	37fd                	addw	a5,a5,-1
    80005768:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000576c:	8526                	mv	a0,s1
    8000576e:	ffffe097          	auipc	ra,0xffffe
    80005772:	f8e080e7          	jalr	-114(ra) # 800036fc <iupdate>
    80005776:	b781                	j	800056b6 <sys_unlink+0xe0>
    return -1;
    80005778:	557d                	li	a0,-1
    8000577a:	a005                	j	8000579a <sys_unlink+0x1c4>
    iunlockput(ip);
    8000577c:	854a                	mv	a0,s2
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	2ac080e7          	jalr	684(ra) # 80003a2a <iunlockput>
  iunlockput(dp);
    80005786:	8526                	mv	a0,s1
    80005788:	ffffe097          	auipc	ra,0xffffe
    8000578c:	2a2080e7          	jalr	674(ra) # 80003a2a <iunlockput>
  end_op();
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	a58080e7          	jalr	-1448(ra) # 800041e8 <end_op>
  return -1;
    80005798:	557d                	li	a0,-1
}
    8000579a:	70ae                	ld	ra,232(sp)
    8000579c:	740e                	ld	s0,224(sp)
    8000579e:	64ee                	ld	s1,216(sp)
    800057a0:	694e                	ld	s2,208(sp)
    800057a2:	69ae                	ld	s3,200(sp)
    800057a4:	616d                	add	sp,sp,240
    800057a6:	8082                	ret

00000000800057a8 <sys_open>:

uint64
sys_open(void)
{
    800057a8:	7131                	add	sp,sp,-192
    800057aa:	fd06                	sd	ra,184(sp)
    800057ac:	f922                	sd	s0,176(sp)
    800057ae:	f526                	sd	s1,168(sp)
    800057b0:	f14a                	sd	s2,160(sp)
    800057b2:	ed4e                	sd	s3,152(sp)
    800057b4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057b6:	f4c40593          	add	a1,s0,-180
    800057ba:	4505                	li	a0,1
    800057bc:	ffffd097          	auipc	ra,0xffffd
    800057c0:	4aa080e7          	jalr	1194(ra) # 80002c66 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057c4:	08000613          	li	a2,128
    800057c8:	f5040593          	add	a1,s0,-176
    800057cc:	4501                	li	a0,0
    800057ce:	ffffd097          	auipc	ra,0xffffd
    800057d2:	4d8080e7          	jalr	1240(ra) # 80002ca6 <argstr>
    800057d6:	87aa                	mv	a5,a0
    return -1;
    800057d8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057da:	0a07c863          	bltz	a5,8000588a <sys_open+0xe2>

  begin_op();
    800057de:	fffff097          	auipc	ra,0xfffff
    800057e2:	990080e7          	jalr	-1648(ra) # 8000416e <begin_op>

  if(omode & O_CREATE){
    800057e6:	f4c42783          	lw	a5,-180(s0)
    800057ea:	2007f793          	and	a5,a5,512
    800057ee:	cbdd                	beqz	a5,800058a4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    800057f0:	4681                	li	a3,0
    800057f2:	4601                	li	a2,0
    800057f4:	4589                	li	a1,2
    800057f6:	f5040513          	add	a0,s0,-176
    800057fa:	00000097          	auipc	ra,0x0
    800057fe:	97a080e7          	jalr	-1670(ra) # 80005174 <create>
    80005802:	84aa                	mv	s1,a0
    if(ip == 0){
    80005804:	c951                	beqz	a0,80005898 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005806:	04449703          	lh	a4,68(s1)
    8000580a:	478d                	li	a5,3
    8000580c:	00f71763          	bne	a4,a5,8000581a <sys_open+0x72>
    80005810:	0464d703          	lhu	a4,70(s1)
    80005814:	47a5                	li	a5,9
    80005816:	0ce7ec63          	bltu	a5,a4,800058ee <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000581a:	fffff097          	auipc	ra,0xfffff
    8000581e:	d5c080e7          	jalr	-676(ra) # 80004576 <filealloc>
    80005822:	892a                	mv	s2,a0
    80005824:	c56d                	beqz	a0,8000590e <sys_open+0x166>
    80005826:	00000097          	auipc	ra,0x0
    8000582a:	90c080e7          	jalr	-1780(ra) # 80005132 <fdalloc>
    8000582e:	89aa                	mv	s3,a0
    80005830:	0c054a63          	bltz	a0,80005904 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005834:	04449703          	lh	a4,68(s1)
    80005838:	478d                	li	a5,3
    8000583a:	0ef70563          	beq	a4,a5,80005924 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000583e:	4789                	li	a5,2
    80005840:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005844:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005848:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000584c:	f4c42783          	lw	a5,-180(s0)
    80005850:	0017c713          	xor	a4,a5,1
    80005854:	8b05                	and	a4,a4,1
    80005856:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000585a:	0037f713          	and	a4,a5,3
    8000585e:	00e03733          	snez	a4,a4
    80005862:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005866:	4007f793          	and	a5,a5,1024
    8000586a:	c791                	beqz	a5,80005876 <sys_open+0xce>
    8000586c:	04449703          	lh	a4,68(s1)
    80005870:	4789                	li	a5,2
    80005872:	0cf70063          	beq	a4,a5,80005932 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005876:	8526                	mv	a0,s1
    80005878:	ffffe097          	auipc	ra,0xffffe
    8000587c:	012080e7          	jalr	18(ra) # 8000388a <iunlock>
  end_op();
    80005880:	fffff097          	auipc	ra,0xfffff
    80005884:	968080e7          	jalr	-1688(ra) # 800041e8 <end_op>

  return fd;
    80005888:	854e                	mv	a0,s3
}
    8000588a:	70ea                	ld	ra,184(sp)
    8000588c:	744a                	ld	s0,176(sp)
    8000588e:	74aa                	ld	s1,168(sp)
    80005890:	790a                	ld	s2,160(sp)
    80005892:	69ea                	ld	s3,152(sp)
    80005894:	6129                	add	sp,sp,192
    80005896:	8082                	ret
      end_op();
    80005898:	fffff097          	auipc	ra,0xfffff
    8000589c:	950080e7          	jalr	-1712(ra) # 800041e8 <end_op>
      return -1;
    800058a0:	557d                	li	a0,-1
    800058a2:	b7e5                	j	8000588a <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800058a4:	f5040513          	add	a0,s0,-176
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	6c6080e7          	jalr	1734(ra) # 80003f6e <namei>
    800058b0:	84aa                	mv	s1,a0
    800058b2:	c905                	beqz	a0,800058e2 <sys_open+0x13a>
    ilock(ip);
    800058b4:	ffffe097          	auipc	ra,0xffffe
    800058b8:	f14080e7          	jalr	-236(ra) # 800037c8 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058bc:	04449703          	lh	a4,68(s1)
    800058c0:	4785                	li	a5,1
    800058c2:	f4f712e3          	bne	a4,a5,80005806 <sys_open+0x5e>
    800058c6:	f4c42783          	lw	a5,-180(s0)
    800058ca:	dba1                	beqz	a5,8000581a <sys_open+0x72>
      iunlockput(ip);
    800058cc:	8526                	mv	a0,s1
    800058ce:	ffffe097          	auipc	ra,0xffffe
    800058d2:	15c080e7          	jalr	348(ra) # 80003a2a <iunlockput>
      end_op();
    800058d6:	fffff097          	auipc	ra,0xfffff
    800058da:	912080e7          	jalr	-1774(ra) # 800041e8 <end_op>
      return -1;
    800058de:	557d                	li	a0,-1
    800058e0:	b76d                	j	8000588a <sys_open+0xe2>
      end_op();
    800058e2:	fffff097          	auipc	ra,0xfffff
    800058e6:	906080e7          	jalr	-1786(ra) # 800041e8 <end_op>
      return -1;
    800058ea:	557d                	li	a0,-1
    800058ec:	bf79                	j	8000588a <sys_open+0xe2>
    iunlockput(ip);
    800058ee:	8526                	mv	a0,s1
    800058f0:	ffffe097          	auipc	ra,0xffffe
    800058f4:	13a080e7          	jalr	314(ra) # 80003a2a <iunlockput>
    end_op();
    800058f8:	fffff097          	auipc	ra,0xfffff
    800058fc:	8f0080e7          	jalr	-1808(ra) # 800041e8 <end_op>
    return -1;
    80005900:	557d                	li	a0,-1
    80005902:	b761                	j	8000588a <sys_open+0xe2>
      fileclose(f);
    80005904:	854a                	mv	a0,s2
    80005906:	fffff097          	auipc	ra,0xfffff
    8000590a:	d2c080e7          	jalr	-724(ra) # 80004632 <fileclose>
    iunlockput(ip);
    8000590e:	8526                	mv	a0,s1
    80005910:	ffffe097          	auipc	ra,0xffffe
    80005914:	11a080e7          	jalr	282(ra) # 80003a2a <iunlockput>
    end_op();
    80005918:	fffff097          	auipc	ra,0xfffff
    8000591c:	8d0080e7          	jalr	-1840(ra) # 800041e8 <end_op>
    return -1;
    80005920:	557d                	li	a0,-1
    80005922:	b7a5                	j	8000588a <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005924:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005928:	04649783          	lh	a5,70(s1)
    8000592c:	02f91223          	sh	a5,36(s2)
    80005930:	bf21                	j	80005848 <sys_open+0xa0>
    itrunc(ip);
    80005932:	8526                	mv	a0,s1
    80005934:	ffffe097          	auipc	ra,0xffffe
    80005938:	fa2080e7          	jalr	-94(ra) # 800038d6 <itrunc>
    8000593c:	bf2d                	j	80005876 <sys_open+0xce>

000000008000593e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000593e:	7175                	add	sp,sp,-144
    80005940:	e506                	sd	ra,136(sp)
    80005942:	e122                	sd	s0,128(sp)
    80005944:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005946:	fffff097          	auipc	ra,0xfffff
    8000594a:	828080e7          	jalr	-2008(ra) # 8000416e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000594e:	08000613          	li	a2,128
    80005952:	f7040593          	add	a1,s0,-144
    80005956:	4501                	li	a0,0
    80005958:	ffffd097          	auipc	ra,0xffffd
    8000595c:	34e080e7          	jalr	846(ra) # 80002ca6 <argstr>
    80005960:	02054963          	bltz	a0,80005992 <sys_mkdir+0x54>
    80005964:	4681                	li	a3,0
    80005966:	4601                	li	a2,0
    80005968:	4585                	li	a1,1
    8000596a:	f7040513          	add	a0,s0,-144
    8000596e:	00000097          	auipc	ra,0x0
    80005972:	806080e7          	jalr	-2042(ra) # 80005174 <create>
    80005976:	cd11                	beqz	a0,80005992 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005978:	ffffe097          	auipc	ra,0xffffe
    8000597c:	0b2080e7          	jalr	178(ra) # 80003a2a <iunlockput>
  end_op();
    80005980:	fffff097          	auipc	ra,0xfffff
    80005984:	868080e7          	jalr	-1944(ra) # 800041e8 <end_op>
  return 0;
    80005988:	4501                	li	a0,0
}
    8000598a:	60aa                	ld	ra,136(sp)
    8000598c:	640a                	ld	s0,128(sp)
    8000598e:	6149                	add	sp,sp,144
    80005990:	8082                	ret
    end_op();
    80005992:	fffff097          	auipc	ra,0xfffff
    80005996:	856080e7          	jalr	-1962(ra) # 800041e8 <end_op>
    return -1;
    8000599a:	557d                	li	a0,-1
    8000599c:	b7fd                	j	8000598a <sys_mkdir+0x4c>

000000008000599e <sys_mknod>:

uint64
sys_mknod(void)
{
    8000599e:	7135                	add	sp,sp,-160
    800059a0:	ed06                	sd	ra,152(sp)
    800059a2:	e922                	sd	s0,144(sp)
    800059a4:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059a6:	ffffe097          	auipc	ra,0xffffe
    800059aa:	7c8080e7          	jalr	1992(ra) # 8000416e <begin_op>
  argint(1, &major);
    800059ae:	f6c40593          	add	a1,s0,-148
    800059b2:	4505                	li	a0,1
    800059b4:	ffffd097          	auipc	ra,0xffffd
    800059b8:	2b2080e7          	jalr	690(ra) # 80002c66 <argint>
  argint(2, &minor);
    800059bc:	f6840593          	add	a1,s0,-152
    800059c0:	4509                	li	a0,2
    800059c2:	ffffd097          	auipc	ra,0xffffd
    800059c6:	2a4080e7          	jalr	676(ra) # 80002c66 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059ca:	08000613          	li	a2,128
    800059ce:	f7040593          	add	a1,s0,-144
    800059d2:	4501                	li	a0,0
    800059d4:	ffffd097          	auipc	ra,0xffffd
    800059d8:	2d2080e7          	jalr	722(ra) # 80002ca6 <argstr>
    800059dc:	02054b63          	bltz	a0,80005a12 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059e0:	f6841683          	lh	a3,-152(s0)
    800059e4:	f6c41603          	lh	a2,-148(s0)
    800059e8:	458d                	li	a1,3
    800059ea:	f7040513          	add	a0,s0,-144
    800059ee:	fffff097          	auipc	ra,0xfffff
    800059f2:	786080e7          	jalr	1926(ra) # 80005174 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059f6:	cd11                	beqz	a0,80005a12 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	032080e7          	jalr	50(ra) # 80003a2a <iunlockput>
  end_op();
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	7e8080e7          	jalr	2024(ra) # 800041e8 <end_op>
  return 0;
    80005a08:	4501                	li	a0,0
}
    80005a0a:	60ea                	ld	ra,152(sp)
    80005a0c:	644a                	ld	s0,144(sp)
    80005a0e:	610d                	add	sp,sp,160
    80005a10:	8082                	ret
    end_op();
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	7d6080e7          	jalr	2006(ra) # 800041e8 <end_op>
    return -1;
    80005a1a:	557d                	li	a0,-1
    80005a1c:	b7fd                	j	80005a0a <sys_mknod+0x6c>

0000000080005a1e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a1e:	7135                	add	sp,sp,-160
    80005a20:	ed06                	sd	ra,152(sp)
    80005a22:	e922                	sd	s0,144(sp)
    80005a24:	e526                	sd	s1,136(sp)
    80005a26:	e14a                	sd	s2,128(sp)
    80005a28:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a2a:	ffffc097          	auipc	ra,0xffffc
    80005a2e:	fcc080e7          	jalr	-52(ra) # 800019f6 <myproc>
    80005a32:	892a                	mv	s2,a0
  
  begin_op();
    80005a34:	ffffe097          	auipc	ra,0xffffe
    80005a38:	73a080e7          	jalr	1850(ra) # 8000416e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a3c:	08000613          	li	a2,128
    80005a40:	f6040593          	add	a1,s0,-160
    80005a44:	4501                	li	a0,0
    80005a46:	ffffd097          	auipc	ra,0xffffd
    80005a4a:	260080e7          	jalr	608(ra) # 80002ca6 <argstr>
    80005a4e:	04054b63          	bltz	a0,80005aa4 <sys_chdir+0x86>
    80005a52:	f6040513          	add	a0,s0,-160
    80005a56:	ffffe097          	auipc	ra,0xffffe
    80005a5a:	518080e7          	jalr	1304(ra) # 80003f6e <namei>
    80005a5e:	84aa                	mv	s1,a0
    80005a60:	c131                	beqz	a0,80005aa4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a62:	ffffe097          	auipc	ra,0xffffe
    80005a66:	d66080e7          	jalr	-666(ra) # 800037c8 <ilock>
  if(ip->type != T_DIR){
    80005a6a:	04449703          	lh	a4,68(s1)
    80005a6e:	4785                	li	a5,1
    80005a70:	04f71063          	bne	a4,a5,80005ab0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a74:	8526                	mv	a0,s1
    80005a76:	ffffe097          	auipc	ra,0xffffe
    80005a7a:	e14080e7          	jalr	-492(ra) # 8000388a <iunlock>
  iput(p->cwd);
    80005a7e:	15093503          	ld	a0,336(s2)
    80005a82:	ffffe097          	auipc	ra,0xffffe
    80005a86:	f00080e7          	jalr	-256(ra) # 80003982 <iput>
  end_op();
    80005a8a:	ffffe097          	auipc	ra,0xffffe
    80005a8e:	75e080e7          	jalr	1886(ra) # 800041e8 <end_op>
  p->cwd = ip;
    80005a92:	14993823          	sd	s1,336(s2)
  return 0;
    80005a96:	4501                	li	a0,0
}
    80005a98:	60ea                	ld	ra,152(sp)
    80005a9a:	644a                	ld	s0,144(sp)
    80005a9c:	64aa                	ld	s1,136(sp)
    80005a9e:	690a                	ld	s2,128(sp)
    80005aa0:	610d                	add	sp,sp,160
    80005aa2:	8082                	ret
    end_op();
    80005aa4:	ffffe097          	auipc	ra,0xffffe
    80005aa8:	744080e7          	jalr	1860(ra) # 800041e8 <end_op>
    return -1;
    80005aac:	557d                	li	a0,-1
    80005aae:	b7ed                	j	80005a98 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ab0:	8526                	mv	a0,s1
    80005ab2:	ffffe097          	auipc	ra,0xffffe
    80005ab6:	f78080e7          	jalr	-136(ra) # 80003a2a <iunlockput>
    end_op();
    80005aba:	ffffe097          	auipc	ra,0xffffe
    80005abe:	72e080e7          	jalr	1838(ra) # 800041e8 <end_op>
    return -1;
    80005ac2:	557d                	li	a0,-1
    80005ac4:	bfd1                	j	80005a98 <sys_chdir+0x7a>

0000000080005ac6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ac6:	7121                	add	sp,sp,-448
    80005ac8:	ff06                	sd	ra,440(sp)
    80005aca:	fb22                	sd	s0,432(sp)
    80005acc:	f726                	sd	s1,424(sp)
    80005ace:	f34a                	sd	s2,416(sp)
    80005ad0:	ef4e                	sd	s3,408(sp)
    80005ad2:	eb52                	sd	s4,400(sp)
    80005ad4:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ad6:	e4840593          	add	a1,s0,-440
    80005ada:	4505                	li	a0,1
    80005adc:	ffffd097          	auipc	ra,0xffffd
    80005ae0:	1aa080e7          	jalr	426(ra) # 80002c86 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005ae4:	08000613          	li	a2,128
    80005ae8:	f5040593          	add	a1,s0,-176
    80005aec:	4501                	li	a0,0
    80005aee:	ffffd097          	auipc	ra,0xffffd
    80005af2:	1b8080e7          	jalr	440(ra) # 80002ca6 <argstr>
    80005af6:	87aa                	mv	a5,a0
    return -1;
    80005af8:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005afa:	0c07c263          	bltz	a5,80005bbe <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005afe:	10000613          	li	a2,256
    80005b02:	4581                	li	a1,0
    80005b04:	e5040513          	add	a0,s0,-432
    80005b08:	ffffb097          	auipc	ra,0xffffb
    80005b0c:	1c6080e7          	jalr	454(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b10:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b14:	89a6                	mv	s3,s1
    80005b16:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b18:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b1c:	00391513          	sll	a0,s2,0x3
    80005b20:	e4040593          	add	a1,s0,-448
    80005b24:	e4843783          	ld	a5,-440(s0)
    80005b28:	953e                	add	a0,a0,a5
    80005b2a:	ffffd097          	auipc	ra,0xffffd
    80005b2e:	09e080e7          	jalr	158(ra) # 80002bc8 <fetchaddr>
    80005b32:	02054a63          	bltz	a0,80005b66 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b36:	e4043783          	ld	a5,-448(s0)
    80005b3a:	c3b9                	beqz	a5,80005b80 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b3c:	ffffb097          	auipc	ra,0xffffb
    80005b40:	fa6080e7          	jalr	-90(ra) # 80000ae2 <kalloc>
    80005b44:	85aa                	mv	a1,a0
    80005b46:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b4a:	cd11                	beqz	a0,80005b66 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b4c:	6605                	lui	a2,0x1
    80005b4e:	e4043503          	ld	a0,-448(s0)
    80005b52:	ffffd097          	auipc	ra,0xffffd
    80005b56:	0c8080e7          	jalr	200(ra) # 80002c1a <fetchstr>
    80005b5a:	00054663          	bltz	a0,80005b66 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005b5e:	0905                	add	s2,s2,1
    80005b60:	09a1                	add	s3,s3,8
    80005b62:	fb491de3          	bne	s2,s4,80005b1c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b66:	f5040913          	add	s2,s0,-176
    80005b6a:	6088                	ld	a0,0(s1)
    80005b6c:	c921                	beqz	a0,80005bbc <sys_exec+0xf6>
    kfree(argv[i]);
    80005b6e:	ffffb097          	auipc	ra,0xffffb
    80005b72:	e76080e7          	jalr	-394(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b76:	04a1                	add	s1,s1,8
    80005b78:	ff2499e3          	bne	s1,s2,80005b6a <sys_exec+0xa4>
  return -1;
    80005b7c:	557d                	li	a0,-1
    80005b7e:	a081                	j	80005bbe <sys_exec+0xf8>
      argv[i] = 0;
    80005b80:	0009079b          	sext.w	a5,s2
    80005b84:	078e                	sll	a5,a5,0x3
    80005b86:	fd078793          	add	a5,a5,-48
    80005b8a:	97a2                	add	a5,a5,s0
    80005b8c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005b90:	e5040593          	add	a1,s0,-432
    80005b94:	f5040513          	add	a0,s0,-176
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	1ba080e7          	jalr	442(ra) # 80004d52 <exec>
    80005ba0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ba2:	f5040993          	add	s3,s0,-176
    80005ba6:	6088                	ld	a0,0(s1)
    80005ba8:	c901                	beqz	a0,80005bb8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005baa:	ffffb097          	auipc	ra,0xffffb
    80005bae:	e3a080e7          	jalr	-454(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb2:	04a1                	add	s1,s1,8
    80005bb4:	ff3499e3          	bne	s1,s3,80005ba6 <sys_exec+0xe0>
  return ret;
    80005bb8:	854a                	mv	a0,s2
    80005bba:	a011                	j	80005bbe <sys_exec+0xf8>
  return -1;
    80005bbc:	557d                	li	a0,-1
}
    80005bbe:	70fa                	ld	ra,440(sp)
    80005bc0:	745a                	ld	s0,432(sp)
    80005bc2:	74ba                	ld	s1,424(sp)
    80005bc4:	791a                	ld	s2,416(sp)
    80005bc6:	69fa                	ld	s3,408(sp)
    80005bc8:	6a5a                	ld	s4,400(sp)
    80005bca:	6139                	add	sp,sp,448
    80005bcc:	8082                	ret

0000000080005bce <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bce:	7139                	add	sp,sp,-64
    80005bd0:	fc06                	sd	ra,56(sp)
    80005bd2:	f822                	sd	s0,48(sp)
    80005bd4:	f426                	sd	s1,40(sp)
    80005bd6:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005bd8:	ffffc097          	auipc	ra,0xffffc
    80005bdc:	e1e080e7          	jalr	-482(ra) # 800019f6 <myproc>
    80005be0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005be2:	fd840593          	add	a1,s0,-40
    80005be6:	4501                	li	a0,0
    80005be8:	ffffd097          	auipc	ra,0xffffd
    80005bec:	09e080e7          	jalr	158(ra) # 80002c86 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005bf0:	fc840593          	add	a1,s0,-56
    80005bf4:	fd040513          	add	a0,s0,-48
    80005bf8:	fffff097          	auipc	ra,0xfffff
    80005bfc:	d66080e7          	jalr	-666(ra) # 8000495e <pipealloc>
    return -1;
    80005c00:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c02:	0c054463          	bltz	a0,80005cca <sys_pipe+0xfc>
  fd0 = -1;
    80005c06:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c0a:	fd043503          	ld	a0,-48(s0)
    80005c0e:	fffff097          	auipc	ra,0xfffff
    80005c12:	524080e7          	jalr	1316(ra) # 80005132 <fdalloc>
    80005c16:	fca42223          	sw	a0,-60(s0)
    80005c1a:	08054b63          	bltz	a0,80005cb0 <sys_pipe+0xe2>
    80005c1e:	fc843503          	ld	a0,-56(s0)
    80005c22:	fffff097          	auipc	ra,0xfffff
    80005c26:	510080e7          	jalr	1296(ra) # 80005132 <fdalloc>
    80005c2a:	fca42023          	sw	a0,-64(s0)
    80005c2e:	06054863          	bltz	a0,80005c9e <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c32:	4691                	li	a3,4
    80005c34:	fc440613          	add	a2,s0,-60
    80005c38:	fd843583          	ld	a1,-40(s0)
    80005c3c:	68a8                	ld	a0,80(s1)
    80005c3e:	ffffc097          	auipc	ra,0xffffc
    80005c42:	a68080e7          	jalr	-1432(ra) # 800016a6 <copyout>
    80005c46:	02054063          	bltz	a0,80005c66 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c4a:	4691                	li	a3,4
    80005c4c:	fc040613          	add	a2,s0,-64
    80005c50:	fd843583          	ld	a1,-40(s0)
    80005c54:	0591                	add	a1,a1,4
    80005c56:	68a8                	ld	a0,80(s1)
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	a4e080e7          	jalr	-1458(ra) # 800016a6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c60:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c62:	06055463          	bgez	a0,80005cca <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005c66:	fc442783          	lw	a5,-60(s0)
    80005c6a:	07e9                	add	a5,a5,26
    80005c6c:	078e                	sll	a5,a5,0x3
    80005c6e:	97a6                	add	a5,a5,s1
    80005c70:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c74:	fc042783          	lw	a5,-64(s0)
    80005c78:	07e9                	add	a5,a5,26
    80005c7a:	078e                	sll	a5,a5,0x3
    80005c7c:	94be                	add	s1,s1,a5
    80005c7e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c82:	fd043503          	ld	a0,-48(s0)
    80005c86:	fffff097          	auipc	ra,0xfffff
    80005c8a:	9ac080e7          	jalr	-1620(ra) # 80004632 <fileclose>
    fileclose(wf);
    80005c8e:	fc843503          	ld	a0,-56(s0)
    80005c92:	fffff097          	auipc	ra,0xfffff
    80005c96:	9a0080e7          	jalr	-1632(ra) # 80004632 <fileclose>
    return -1;
    80005c9a:	57fd                	li	a5,-1
    80005c9c:	a03d                	j	80005cca <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c9e:	fc442783          	lw	a5,-60(s0)
    80005ca2:	0007c763          	bltz	a5,80005cb0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005ca6:	07e9                	add	a5,a5,26
    80005ca8:	078e                	sll	a5,a5,0x3
    80005caa:	97a6                	add	a5,a5,s1
    80005cac:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cb0:	fd043503          	ld	a0,-48(s0)
    80005cb4:	fffff097          	auipc	ra,0xfffff
    80005cb8:	97e080e7          	jalr	-1666(ra) # 80004632 <fileclose>
    fileclose(wf);
    80005cbc:	fc843503          	ld	a0,-56(s0)
    80005cc0:	fffff097          	auipc	ra,0xfffff
    80005cc4:	972080e7          	jalr	-1678(ra) # 80004632 <fileclose>
    return -1;
    80005cc8:	57fd                	li	a5,-1
}
    80005cca:	853e                	mv	a0,a5
    80005ccc:	70e2                	ld	ra,56(sp)
    80005cce:	7442                	ld	s0,48(sp)
    80005cd0:	74a2                	ld	s1,40(sp)
    80005cd2:	6121                	add	sp,sp,64
    80005cd4:	8082                	ret
	...

0000000080005ce0 <kernelvec>:
    80005ce0:	7111                	add	sp,sp,-256
    80005ce2:	e006                	sd	ra,0(sp)
    80005ce4:	e40a                	sd	sp,8(sp)
    80005ce6:	e80e                	sd	gp,16(sp)
    80005ce8:	ec12                	sd	tp,24(sp)
    80005cea:	f016                	sd	t0,32(sp)
    80005cec:	f41a                	sd	t1,40(sp)
    80005cee:	f81e                	sd	t2,48(sp)
    80005cf0:	fc22                	sd	s0,56(sp)
    80005cf2:	e0a6                	sd	s1,64(sp)
    80005cf4:	e4aa                	sd	a0,72(sp)
    80005cf6:	e8ae                	sd	a1,80(sp)
    80005cf8:	ecb2                	sd	a2,88(sp)
    80005cfa:	f0b6                	sd	a3,96(sp)
    80005cfc:	f4ba                	sd	a4,104(sp)
    80005cfe:	f8be                	sd	a5,112(sp)
    80005d00:	fcc2                	sd	a6,120(sp)
    80005d02:	e146                	sd	a7,128(sp)
    80005d04:	e54a                	sd	s2,136(sp)
    80005d06:	e94e                	sd	s3,144(sp)
    80005d08:	ed52                	sd	s4,152(sp)
    80005d0a:	f156                	sd	s5,160(sp)
    80005d0c:	f55a                	sd	s6,168(sp)
    80005d0e:	f95e                	sd	s7,176(sp)
    80005d10:	fd62                	sd	s8,184(sp)
    80005d12:	e1e6                	sd	s9,192(sp)
    80005d14:	e5ea                	sd	s10,200(sp)
    80005d16:	e9ee                	sd	s11,208(sp)
    80005d18:	edf2                	sd	t3,216(sp)
    80005d1a:	f1f6                	sd	t4,224(sp)
    80005d1c:	f5fa                	sd	t5,232(sp)
    80005d1e:	f9fe                	sd	t6,240(sp)
    80005d20:	d75fc0ef          	jal	80002a94 <kerneltrap>
    80005d24:	6082                	ld	ra,0(sp)
    80005d26:	6122                	ld	sp,8(sp)
    80005d28:	61c2                	ld	gp,16(sp)
    80005d2a:	7282                	ld	t0,32(sp)
    80005d2c:	7322                	ld	t1,40(sp)
    80005d2e:	73c2                	ld	t2,48(sp)
    80005d30:	7462                	ld	s0,56(sp)
    80005d32:	6486                	ld	s1,64(sp)
    80005d34:	6526                	ld	a0,72(sp)
    80005d36:	65c6                	ld	a1,80(sp)
    80005d38:	6666                	ld	a2,88(sp)
    80005d3a:	7686                	ld	a3,96(sp)
    80005d3c:	7726                	ld	a4,104(sp)
    80005d3e:	77c6                	ld	a5,112(sp)
    80005d40:	7866                	ld	a6,120(sp)
    80005d42:	688a                	ld	a7,128(sp)
    80005d44:	692a                	ld	s2,136(sp)
    80005d46:	69ca                	ld	s3,144(sp)
    80005d48:	6a6a                	ld	s4,152(sp)
    80005d4a:	7a8a                	ld	s5,160(sp)
    80005d4c:	7b2a                	ld	s6,168(sp)
    80005d4e:	7bca                	ld	s7,176(sp)
    80005d50:	7c6a                	ld	s8,184(sp)
    80005d52:	6c8e                	ld	s9,192(sp)
    80005d54:	6d2e                	ld	s10,200(sp)
    80005d56:	6dce                	ld	s11,208(sp)
    80005d58:	6e6e                	ld	t3,216(sp)
    80005d5a:	7e8e                	ld	t4,224(sp)
    80005d5c:	7f2e                	ld	t5,232(sp)
    80005d5e:	7fce                	ld	t6,240(sp)
    80005d60:	6111                	add	sp,sp,256
    80005d62:	10200073          	sret
    80005d66:	00000013          	nop
    80005d6a:	00000013          	nop
    80005d6e:	0001                	nop

0000000080005d70 <timervec>:
    80005d70:	34051573          	csrrw	a0,mscratch,a0
    80005d74:	e10c                	sd	a1,0(a0)
    80005d76:	e510                	sd	a2,8(a0)
    80005d78:	e914                	sd	a3,16(a0)
    80005d7a:	6d0c                	ld	a1,24(a0)
    80005d7c:	7110                	ld	a2,32(a0)
    80005d7e:	6194                	ld	a3,0(a1)
    80005d80:	96b2                	add	a3,a3,a2
    80005d82:	e194                	sd	a3,0(a1)
    80005d84:	4589                	li	a1,2
    80005d86:	14459073          	csrw	sip,a1
    80005d8a:	6914                	ld	a3,16(a0)
    80005d8c:	6510                	ld	a2,8(a0)
    80005d8e:	610c                	ld	a1,0(a0)
    80005d90:	34051573          	csrrw	a0,mscratch,a0
    80005d94:	30200073          	mret
	...

0000000080005d9a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d9a:	1141                	add	sp,sp,-16
    80005d9c:	e422                	sd	s0,8(sp)
    80005d9e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005da0:	0c0007b7          	lui	a5,0xc000
    80005da4:	4705                	li	a4,1
    80005da6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005da8:	c3d8                	sw	a4,4(a5)
}
    80005daa:	6422                	ld	s0,8(sp)
    80005dac:	0141                	add	sp,sp,16
    80005dae:	8082                	ret

0000000080005db0 <plicinithart>:

void
plicinithart(void)
{
    80005db0:	1141                	add	sp,sp,-16
    80005db2:	e406                	sd	ra,8(sp)
    80005db4:	e022                	sd	s0,0(sp)
    80005db6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005db8:	ffffc097          	auipc	ra,0xffffc
    80005dbc:	c12080e7          	jalr	-1006(ra) # 800019ca <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005dc0:	0085171b          	sllw	a4,a0,0x8
    80005dc4:	0c0027b7          	lui	a5,0xc002
    80005dc8:	97ba                	add	a5,a5,a4
    80005dca:	40200713          	li	a4,1026
    80005dce:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005dd2:	00d5151b          	sllw	a0,a0,0xd
    80005dd6:	0c2017b7          	lui	a5,0xc201
    80005dda:	97aa                	add	a5,a5,a0
    80005ddc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005de0:	60a2                	ld	ra,8(sp)
    80005de2:	6402                	ld	s0,0(sp)
    80005de4:	0141                	add	sp,sp,16
    80005de6:	8082                	ret

0000000080005de8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005de8:	1141                	add	sp,sp,-16
    80005dea:	e406                	sd	ra,8(sp)
    80005dec:	e022                	sd	s0,0(sp)
    80005dee:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005df0:	ffffc097          	auipc	ra,0xffffc
    80005df4:	bda080e7          	jalr	-1062(ra) # 800019ca <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005df8:	00d5151b          	sllw	a0,a0,0xd
    80005dfc:	0c2017b7          	lui	a5,0xc201
    80005e00:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e02:	43c8                	lw	a0,4(a5)
    80005e04:	60a2                	ld	ra,8(sp)
    80005e06:	6402                	ld	s0,0(sp)
    80005e08:	0141                	add	sp,sp,16
    80005e0a:	8082                	ret

0000000080005e0c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e0c:	1101                	add	sp,sp,-32
    80005e0e:	ec06                	sd	ra,24(sp)
    80005e10:	e822                	sd	s0,16(sp)
    80005e12:	e426                	sd	s1,8(sp)
    80005e14:	1000                	add	s0,sp,32
    80005e16:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e18:	ffffc097          	auipc	ra,0xffffc
    80005e1c:	bb2080e7          	jalr	-1102(ra) # 800019ca <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e20:	00d5151b          	sllw	a0,a0,0xd
    80005e24:	0c2017b7          	lui	a5,0xc201
    80005e28:	97aa                	add	a5,a5,a0
    80005e2a:	c3c4                	sw	s1,4(a5)
}
    80005e2c:	60e2                	ld	ra,24(sp)
    80005e2e:	6442                	ld	s0,16(sp)
    80005e30:	64a2                	ld	s1,8(sp)
    80005e32:	6105                	add	sp,sp,32
    80005e34:	8082                	ret

0000000080005e36 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e36:	1141                	add	sp,sp,-16
    80005e38:	e406                	sd	ra,8(sp)
    80005e3a:	e022                	sd	s0,0(sp)
    80005e3c:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005e3e:	479d                	li	a5,7
    80005e40:	04a7cc63          	blt	a5,a0,80005e98 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e44:	00193797          	auipc	a5,0x193
    80005e48:	3d478793          	add	a5,a5,980 # 80199218 <disk>
    80005e4c:	97aa                	add	a5,a5,a0
    80005e4e:	0187c783          	lbu	a5,24(a5)
    80005e52:	ebb9                	bnez	a5,80005ea8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e54:	00451693          	sll	a3,a0,0x4
    80005e58:	00193797          	auipc	a5,0x193
    80005e5c:	3c078793          	add	a5,a5,960 # 80199218 <disk>
    80005e60:	6398                	ld	a4,0(a5)
    80005e62:	9736                	add	a4,a4,a3
    80005e64:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e68:	6398                	ld	a4,0(a5)
    80005e6a:	9736                	add	a4,a4,a3
    80005e6c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e70:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e74:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e78:	97aa                	add	a5,a5,a0
    80005e7a:	4705                	li	a4,1
    80005e7c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e80:	00193517          	auipc	a0,0x193
    80005e84:	3b050513          	add	a0,a0,944 # 80199230 <disk+0x18>
    80005e88:	ffffc097          	auipc	ra,0xffffc
    80005e8c:	368080e7          	jalr	872(ra) # 800021f0 <wakeup>
}
    80005e90:	60a2                	ld	ra,8(sp)
    80005e92:	6402                	ld	s0,0(sp)
    80005e94:	0141                	add	sp,sp,16
    80005e96:	8082                	ret
    panic("free_desc 1");
    80005e98:	00003517          	auipc	a0,0x3
    80005e9c:	8f850513          	add	a0,a0,-1800 # 80008790 <syscalls+0x2f0>
    80005ea0:	ffffa097          	auipc	ra,0xffffa
    80005ea4:	69c080e7          	jalr	1692(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005ea8:	00003517          	auipc	a0,0x3
    80005eac:	8f850513          	add	a0,a0,-1800 # 800087a0 <syscalls+0x300>
    80005eb0:	ffffa097          	auipc	ra,0xffffa
    80005eb4:	68c080e7          	jalr	1676(ra) # 8000053c <panic>

0000000080005eb8 <virtio_disk_init>:
{
    80005eb8:	1101                	add	sp,sp,-32
    80005eba:	ec06                	sd	ra,24(sp)
    80005ebc:	e822                	sd	s0,16(sp)
    80005ebe:	e426                	sd	s1,8(sp)
    80005ec0:	e04a                	sd	s2,0(sp)
    80005ec2:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ec4:	00003597          	auipc	a1,0x3
    80005ec8:	8ec58593          	add	a1,a1,-1812 # 800087b0 <syscalls+0x310>
    80005ecc:	00193517          	auipc	a0,0x193
    80005ed0:	47450513          	add	a0,a0,1140 # 80199340 <disk+0x128>
    80005ed4:	ffffb097          	auipc	ra,0xffffb
    80005ed8:	c6e080e7          	jalr	-914(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005edc:	100017b7          	lui	a5,0x10001
    80005ee0:	4398                	lw	a4,0(a5)
    80005ee2:	2701                	sext.w	a4,a4
    80005ee4:	747277b7          	lui	a5,0x74727
    80005ee8:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005eec:	14f71b63          	bne	a4,a5,80006042 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005ef0:	100017b7          	lui	a5,0x10001
    80005ef4:	43dc                	lw	a5,4(a5)
    80005ef6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ef8:	4709                	li	a4,2
    80005efa:	14e79463          	bne	a5,a4,80006042 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005efe:	100017b7          	lui	a5,0x10001
    80005f02:	479c                	lw	a5,8(a5)
    80005f04:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f06:	12e79e63          	bne	a5,a4,80006042 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f0a:	100017b7          	lui	a5,0x10001
    80005f0e:	47d8                	lw	a4,12(a5)
    80005f10:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f12:	554d47b7          	lui	a5,0x554d4
    80005f16:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f1a:	12f71463          	bne	a4,a5,80006042 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f1e:	100017b7          	lui	a5,0x10001
    80005f22:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f26:	4705                	li	a4,1
    80005f28:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f2a:	470d                	li	a4,3
    80005f2c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f2e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f30:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f34:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47e6501f>
    80005f38:	8f75                	and	a4,a4,a3
    80005f3a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f3c:	472d                	li	a4,11
    80005f3e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f40:	5bbc                	lw	a5,112(a5)
    80005f42:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f46:	8ba1                	and	a5,a5,8
    80005f48:	10078563          	beqz	a5,80006052 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f4c:	100017b7          	lui	a5,0x10001
    80005f50:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f54:	43fc                	lw	a5,68(a5)
    80005f56:	2781                	sext.w	a5,a5
    80005f58:	10079563          	bnez	a5,80006062 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f5c:	100017b7          	lui	a5,0x10001
    80005f60:	5bdc                	lw	a5,52(a5)
    80005f62:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f64:	10078763          	beqz	a5,80006072 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005f68:	471d                	li	a4,7
    80005f6a:	10f77c63          	bgeu	a4,a5,80006082 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005f6e:	ffffb097          	auipc	ra,0xffffb
    80005f72:	b74080e7          	jalr	-1164(ra) # 80000ae2 <kalloc>
    80005f76:	00193497          	auipc	s1,0x193
    80005f7a:	2a248493          	add	s1,s1,674 # 80199218 <disk>
    80005f7e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f80:	ffffb097          	auipc	ra,0xffffb
    80005f84:	b62080e7          	jalr	-1182(ra) # 80000ae2 <kalloc>
    80005f88:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f8a:	ffffb097          	auipc	ra,0xffffb
    80005f8e:	b58080e7          	jalr	-1192(ra) # 80000ae2 <kalloc>
    80005f92:	87aa                	mv	a5,a0
    80005f94:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f96:	6088                	ld	a0,0(s1)
    80005f98:	cd6d                	beqz	a0,80006092 <virtio_disk_init+0x1da>
    80005f9a:	00193717          	auipc	a4,0x193
    80005f9e:	28673703          	ld	a4,646(a4) # 80199220 <disk+0x8>
    80005fa2:	cb65                	beqz	a4,80006092 <virtio_disk_init+0x1da>
    80005fa4:	c7fd                	beqz	a5,80006092 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005fa6:	6605                	lui	a2,0x1
    80005fa8:	4581                	li	a1,0
    80005faa:	ffffb097          	auipc	ra,0xffffb
    80005fae:	d24080e7          	jalr	-732(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fb2:	00193497          	auipc	s1,0x193
    80005fb6:	26648493          	add	s1,s1,614 # 80199218 <disk>
    80005fba:	6605                	lui	a2,0x1
    80005fbc:	4581                	li	a1,0
    80005fbe:	6488                	ld	a0,8(s1)
    80005fc0:	ffffb097          	auipc	ra,0xffffb
    80005fc4:	d0e080e7          	jalr	-754(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005fc8:	6605                	lui	a2,0x1
    80005fca:	4581                	li	a1,0
    80005fcc:	6888                	ld	a0,16(s1)
    80005fce:	ffffb097          	auipc	ra,0xffffb
    80005fd2:	d00080e7          	jalr	-768(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005fd6:	100017b7          	lui	a5,0x10001
    80005fda:	4721                	li	a4,8
    80005fdc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005fde:	4098                	lw	a4,0(s1)
    80005fe0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005fe4:	40d8                	lw	a4,4(s1)
    80005fe6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005fea:	6498                	ld	a4,8(s1)
    80005fec:	0007069b          	sext.w	a3,a4
    80005ff0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005ff4:	9701                	sra	a4,a4,0x20
    80005ff6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005ffa:	6898                	ld	a4,16(s1)
    80005ffc:	0007069b          	sext.w	a3,a4
    80006000:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006004:	9701                	sra	a4,a4,0x20
    80006006:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000600a:	4705                	li	a4,1
    8000600c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000600e:	00e48c23          	sb	a4,24(s1)
    80006012:	00e48ca3          	sb	a4,25(s1)
    80006016:	00e48d23          	sb	a4,26(s1)
    8000601a:	00e48da3          	sb	a4,27(s1)
    8000601e:	00e48e23          	sb	a4,28(s1)
    80006022:	00e48ea3          	sb	a4,29(s1)
    80006026:	00e48f23          	sb	a4,30(s1)
    8000602a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000602e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006032:	0727a823          	sw	s2,112(a5)
}
    80006036:	60e2                	ld	ra,24(sp)
    80006038:	6442                	ld	s0,16(sp)
    8000603a:	64a2                	ld	s1,8(sp)
    8000603c:	6902                	ld	s2,0(sp)
    8000603e:	6105                	add	sp,sp,32
    80006040:	8082                	ret
    panic("could not find virtio disk");
    80006042:	00002517          	auipc	a0,0x2
    80006046:	77e50513          	add	a0,a0,1918 # 800087c0 <syscalls+0x320>
    8000604a:	ffffa097          	auipc	ra,0xffffa
    8000604e:	4f2080e7          	jalr	1266(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006052:	00002517          	auipc	a0,0x2
    80006056:	78e50513          	add	a0,a0,1934 # 800087e0 <syscalls+0x340>
    8000605a:	ffffa097          	auipc	ra,0xffffa
    8000605e:	4e2080e7          	jalr	1250(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006062:	00002517          	auipc	a0,0x2
    80006066:	79e50513          	add	a0,a0,1950 # 80008800 <syscalls+0x360>
    8000606a:	ffffa097          	auipc	ra,0xffffa
    8000606e:	4d2080e7          	jalr	1234(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006072:	00002517          	auipc	a0,0x2
    80006076:	7ae50513          	add	a0,a0,1966 # 80008820 <syscalls+0x380>
    8000607a:	ffffa097          	auipc	ra,0xffffa
    8000607e:	4c2080e7          	jalr	1218(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006082:	00002517          	auipc	a0,0x2
    80006086:	7be50513          	add	a0,a0,1982 # 80008840 <syscalls+0x3a0>
    8000608a:	ffffa097          	auipc	ra,0xffffa
    8000608e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006092:	00002517          	auipc	a0,0x2
    80006096:	7ce50513          	add	a0,a0,1998 # 80008860 <syscalls+0x3c0>
    8000609a:	ffffa097          	auipc	ra,0xffffa
    8000609e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>

00000000800060a2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060a2:	7159                	add	sp,sp,-112
    800060a4:	f486                	sd	ra,104(sp)
    800060a6:	f0a2                	sd	s0,96(sp)
    800060a8:	eca6                	sd	s1,88(sp)
    800060aa:	e8ca                	sd	s2,80(sp)
    800060ac:	e4ce                	sd	s3,72(sp)
    800060ae:	e0d2                	sd	s4,64(sp)
    800060b0:	fc56                	sd	s5,56(sp)
    800060b2:	f85a                	sd	s6,48(sp)
    800060b4:	f45e                	sd	s7,40(sp)
    800060b6:	f062                	sd	s8,32(sp)
    800060b8:	ec66                	sd	s9,24(sp)
    800060ba:	e86a                	sd	s10,16(sp)
    800060bc:	1880                	add	s0,sp,112
    800060be:	8a2a                	mv	s4,a0
    800060c0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060c2:	00c52c83          	lw	s9,12(a0)
    800060c6:	001c9c9b          	sllw	s9,s9,0x1
    800060ca:	1c82                	sll	s9,s9,0x20
    800060cc:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060d0:	00193517          	auipc	a0,0x193
    800060d4:	27050513          	add	a0,a0,624 # 80199340 <disk+0x128>
    800060d8:	ffffb097          	auipc	ra,0xffffb
    800060dc:	afa080e7          	jalr	-1286(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    800060e0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    800060e2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800060e4:	00193b17          	auipc	s6,0x193
    800060e8:	134b0b13          	add	s6,s6,308 # 80199218 <disk>
  for(int i = 0; i < 3; i++){
    800060ec:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060ee:	00193c17          	auipc	s8,0x193
    800060f2:	252c0c13          	add	s8,s8,594 # 80199340 <disk+0x128>
    800060f6:	a095                	j	8000615a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    800060f8:	00fb0733          	add	a4,s6,a5
    800060fc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006100:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006102:	0207c563          	bltz	a5,8000612c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006106:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006108:	0591                	add	a1,a1,4
    8000610a:	05560d63          	beq	a2,s5,80006164 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000610e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006110:	00193717          	auipc	a4,0x193
    80006114:	10870713          	add	a4,a4,264 # 80199218 <disk>
    80006118:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000611a:	01874683          	lbu	a3,24(a4)
    8000611e:	fee9                	bnez	a3,800060f8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006120:	2785                	addw	a5,a5,1
    80006122:	0705                	add	a4,a4,1
    80006124:	fe979be3          	bne	a5,s1,8000611a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006128:	57fd                	li	a5,-1
    8000612a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000612c:	00c05e63          	blez	a2,80006148 <virtio_disk_rw+0xa6>
    80006130:	060a                	sll	a2,a2,0x2
    80006132:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006136:	0009a503          	lw	a0,0(s3)
    8000613a:	00000097          	auipc	ra,0x0
    8000613e:	cfc080e7          	jalr	-772(ra) # 80005e36 <free_desc>
      for(int j = 0; j < i; j++)
    80006142:	0991                	add	s3,s3,4
    80006144:	ffa999e3          	bne	s3,s10,80006136 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006148:	85e2                	mv	a1,s8
    8000614a:	00193517          	auipc	a0,0x193
    8000614e:	0e650513          	add	a0,a0,230 # 80199230 <disk+0x18>
    80006152:	ffffc097          	auipc	ra,0xffffc
    80006156:	03a080e7          	jalr	58(ra) # 8000218c <sleep>
  for(int i = 0; i < 3; i++){
    8000615a:	f9040993          	add	s3,s0,-112
{
    8000615e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006160:	864a                	mv	a2,s2
    80006162:	b775                	j	8000610e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006164:	f9042503          	lw	a0,-112(s0)
    80006168:	00a50713          	add	a4,a0,10
    8000616c:	0712                	sll	a4,a4,0x4

  if(write)
    8000616e:	00193797          	auipc	a5,0x193
    80006172:	0aa78793          	add	a5,a5,170 # 80199218 <disk>
    80006176:	00e786b3          	add	a3,a5,a4
    8000617a:	01703633          	snez	a2,s7
    8000617e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006180:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006184:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006188:	f6070613          	add	a2,a4,-160
    8000618c:	6394                	ld	a3,0(a5)
    8000618e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006190:	00870593          	add	a1,a4,8
    80006194:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006196:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006198:	0007b803          	ld	a6,0(a5)
    8000619c:	9642                	add	a2,a2,a6
    8000619e:	46c1                	li	a3,16
    800061a0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061a2:	4585                	li	a1,1
    800061a4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800061a8:	f9442683          	lw	a3,-108(s0)
    800061ac:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061b0:	0692                	sll	a3,a3,0x4
    800061b2:	9836                	add	a6,a6,a3
    800061b4:	058a0613          	add	a2,s4,88
    800061b8:	00c83023          	sd	a2,0(a6) # 1000 <_entry-0x7ffff000>
  disk.desc[idx[1]].len = BSIZE;
    800061bc:	0007b803          	ld	a6,0(a5)
    800061c0:	96c2                	add	a3,a3,a6
    800061c2:	40000613          	li	a2,1024
    800061c6:	c690                	sw	a2,8(a3)
  if(write)
    800061c8:	001bb613          	seqz	a2,s7
    800061cc:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061d0:	00166613          	or	a2,a2,1
    800061d4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800061d8:	f9842603          	lw	a2,-104(s0)
    800061dc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061e0:	00250693          	add	a3,a0,2
    800061e4:	0692                	sll	a3,a3,0x4
    800061e6:	96be                	add	a3,a3,a5
    800061e8:	58fd                	li	a7,-1
    800061ea:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061ee:	0612                	sll	a2,a2,0x4
    800061f0:	9832                	add	a6,a6,a2
    800061f2:	f9070713          	add	a4,a4,-112
    800061f6:	973e                	add	a4,a4,a5
    800061f8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    800061fc:	6398                	ld	a4,0(a5)
    800061fe:	9732                	add	a4,a4,a2
    80006200:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006202:	4609                	li	a2,2
    80006204:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006208:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000620c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006210:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006214:	6794                	ld	a3,8(a5)
    80006216:	0026d703          	lhu	a4,2(a3)
    8000621a:	8b1d                	and	a4,a4,7
    8000621c:	0706                	sll	a4,a4,0x1
    8000621e:	96ba                	add	a3,a3,a4
    80006220:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006224:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006228:	6798                	ld	a4,8(a5)
    8000622a:	00275783          	lhu	a5,2(a4)
    8000622e:	2785                	addw	a5,a5,1
    80006230:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006234:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006238:	100017b7          	lui	a5,0x10001
    8000623c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006240:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006244:	00193917          	auipc	s2,0x193
    80006248:	0fc90913          	add	s2,s2,252 # 80199340 <disk+0x128>
  while(b->disk == 1) {
    8000624c:	4485                	li	s1,1
    8000624e:	00b79c63          	bne	a5,a1,80006266 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006252:	85ca                	mv	a1,s2
    80006254:	8552                	mv	a0,s4
    80006256:	ffffc097          	auipc	ra,0xffffc
    8000625a:	f36080e7          	jalr	-202(ra) # 8000218c <sleep>
  while(b->disk == 1) {
    8000625e:	004a2783          	lw	a5,4(s4)
    80006262:	fe9788e3          	beq	a5,s1,80006252 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006266:	f9042903          	lw	s2,-112(s0)
    8000626a:	00290713          	add	a4,s2,2
    8000626e:	0712                	sll	a4,a4,0x4
    80006270:	00193797          	auipc	a5,0x193
    80006274:	fa878793          	add	a5,a5,-88 # 80199218 <disk>
    80006278:	97ba                	add	a5,a5,a4
    8000627a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000627e:	00193997          	auipc	s3,0x193
    80006282:	f9a98993          	add	s3,s3,-102 # 80199218 <disk>
    80006286:	00491713          	sll	a4,s2,0x4
    8000628a:	0009b783          	ld	a5,0(s3)
    8000628e:	97ba                	add	a5,a5,a4
    80006290:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006294:	854a                	mv	a0,s2
    80006296:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000629a:	00000097          	auipc	ra,0x0
    8000629e:	b9c080e7          	jalr	-1124(ra) # 80005e36 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062a2:	8885                	and	s1,s1,1
    800062a4:	f0ed                	bnez	s1,80006286 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062a6:	00193517          	auipc	a0,0x193
    800062aa:	09a50513          	add	a0,a0,154 # 80199340 <disk+0x128>
    800062ae:	ffffb097          	auipc	ra,0xffffb
    800062b2:	9d8080e7          	jalr	-1576(ra) # 80000c86 <release>
}
    800062b6:	70a6                	ld	ra,104(sp)
    800062b8:	7406                	ld	s0,96(sp)
    800062ba:	64e6                	ld	s1,88(sp)
    800062bc:	6946                	ld	s2,80(sp)
    800062be:	69a6                	ld	s3,72(sp)
    800062c0:	6a06                	ld	s4,64(sp)
    800062c2:	7ae2                	ld	s5,56(sp)
    800062c4:	7b42                	ld	s6,48(sp)
    800062c6:	7ba2                	ld	s7,40(sp)
    800062c8:	7c02                	ld	s8,32(sp)
    800062ca:	6ce2                	ld	s9,24(sp)
    800062cc:	6d42                	ld	s10,16(sp)
    800062ce:	6165                	add	sp,sp,112
    800062d0:	8082                	ret

00000000800062d2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062d2:	1101                	add	sp,sp,-32
    800062d4:	ec06                	sd	ra,24(sp)
    800062d6:	e822                	sd	s0,16(sp)
    800062d8:	e426                	sd	s1,8(sp)
    800062da:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062dc:	00193497          	auipc	s1,0x193
    800062e0:	f3c48493          	add	s1,s1,-196 # 80199218 <disk>
    800062e4:	00193517          	auipc	a0,0x193
    800062e8:	05c50513          	add	a0,a0,92 # 80199340 <disk+0x128>
    800062ec:	ffffb097          	auipc	ra,0xffffb
    800062f0:	8e6080e7          	jalr	-1818(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800062f4:	10001737          	lui	a4,0x10001
    800062f8:	533c                	lw	a5,96(a4)
    800062fa:	8b8d                	and	a5,a5,3
    800062fc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800062fe:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006302:	689c                	ld	a5,16(s1)
    80006304:	0204d703          	lhu	a4,32(s1)
    80006308:	0027d783          	lhu	a5,2(a5)
    8000630c:	04f70863          	beq	a4,a5,8000635c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006310:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006314:	6898                	ld	a4,16(s1)
    80006316:	0204d783          	lhu	a5,32(s1)
    8000631a:	8b9d                	and	a5,a5,7
    8000631c:	078e                	sll	a5,a5,0x3
    8000631e:	97ba                	add	a5,a5,a4
    80006320:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006322:	00278713          	add	a4,a5,2
    80006326:	0712                	sll	a4,a4,0x4
    80006328:	9726                	add	a4,a4,s1
    8000632a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000632e:	e721                	bnez	a4,80006376 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006330:	0789                	add	a5,a5,2
    80006332:	0792                	sll	a5,a5,0x4
    80006334:	97a6                	add	a5,a5,s1
    80006336:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006338:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000633c:	ffffc097          	auipc	ra,0xffffc
    80006340:	eb4080e7          	jalr	-332(ra) # 800021f0 <wakeup>

    disk.used_idx += 1;
    80006344:	0204d783          	lhu	a5,32(s1)
    80006348:	2785                	addw	a5,a5,1
    8000634a:	17c2                	sll	a5,a5,0x30
    8000634c:	93c1                	srl	a5,a5,0x30
    8000634e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006352:	6898                	ld	a4,16(s1)
    80006354:	00275703          	lhu	a4,2(a4)
    80006358:	faf71ce3          	bne	a4,a5,80006310 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000635c:	00193517          	auipc	a0,0x193
    80006360:	fe450513          	add	a0,a0,-28 # 80199340 <disk+0x128>
    80006364:	ffffb097          	auipc	ra,0xffffb
    80006368:	922080e7          	jalr	-1758(ra) # 80000c86 <release>
}
    8000636c:	60e2                	ld	ra,24(sp)
    8000636e:	6442                	ld	s0,16(sp)
    80006370:	64a2                	ld	s1,8(sp)
    80006372:	6105                	add	sp,sp,32
    80006374:	8082                	ret
      panic("virtio_disk_intr status");
    80006376:	00002517          	auipc	a0,0x2
    8000637a:	50250513          	add	a0,a0,1282 # 80008878 <syscalls+0x3d8>
    8000637e:	ffffa097          	auipc	ra,0xffffa
    80006382:	1be080e7          	jalr	446(ra) # 8000053c <panic>

0000000080006386 <read_current_timestamp>:

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
    80006386:	1101                	add	sp,sp,-32
    80006388:	ec06                	sd	ra,24(sp)
    8000638a:	e822                	sd	s0,16(sp)
    8000638c:	e426                	sd	s1,8(sp)
    8000638e:	1000                	add	s0,sp,32
  uint64 curticks = 0;
  acquire(&tickslock);
    80006390:	00188517          	auipc	a0,0x188
    80006394:	be050513          	add	a0,a0,-1056 # 8018df70 <tickslock>
    80006398:	ffffb097          	auipc	ra,0xffffb
    8000639c:	83a080e7          	jalr	-1990(ra) # 80000bd2 <acquire>
  curticks = ticks;
    800063a0:	00002517          	auipc	a0,0x2
    800063a4:	73050513          	add	a0,a0,1840 # 80008ad0 <ticks>
    800063a8:	00056483          	lwu	s1,0(a0)
  wakeup(&ticks);
    800063ac:	ffffc097          	auipc	ra,0xffffc
    800063b0:	e44080e7          	jalr	-444(ra) # 800021f0 <wakeup>
  release(&tickslock);
    800063b4:	00188517          	auipc	a0,0x188
    800063b8:	bbc50513          	add	a0,a0,-1092 # 8018df70 <tickslock>
    800063bc:	ffffb097          	auipc	ra,0xffffb
    800063c0:	8ca080e7          	jalr	-1846(ra) # 80000c86 <release>
  return curticks;
}
    800063c4:	8526                	mv	a0,s1
    800063c6:	60e2                	ld	ra,24(sp)
    800063c8:	6442                	ld	s0,16(sp)
    800063ca:	64a2                	ld	s1,8(sp)
    800063cc:	6105                	add	sp,sp,32
    800063ce:	8082                	ret

00000000800063d0 <init_psa_regions>:

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    800063d0:	1141                	add	sp,sp,-16
    800063d2:	e422                	sd	s0,8(sp)
    800063d4:	0800                	add	s0,sp,16
    for (int i = 0; i < PSASIZE; i++) 
    800063d6:	00193797          	auipc	a5,0x193
    800063da:	f8278793          	add	a5,a5,-126 # 80199358 <psa_tracker>
    800063de:	00193717          	auipc	a4,0x193
    800063e2:	36270713          	add	a4,a4,866 # 80199740 <end>
        psa_tracker[i] = false;
    800063e6:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PSASIZE; i++) 
    800063ea:	0785                	add	a5,a5,1
    800063ec:	fee79de3          	bne	a5,a4,800063e6 <init_psa_regions+0x16>
}
    800063f0:	6422                	ld	s0,8(sp)
    800063f2:	0141                	add	sp,sp,16
    800063f4:	8082                	ret

00000000800063f6 <evict_page_to_disk>:

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    800063f6:	1101                	add	sp,sp,-32
    800063f8:	ec06                	sd	ra,24(sp)
    800063fa:	e822                	sd	s0,16(sp)
    800063fc:	e426                	sd	s1,8(sp)
    800063fe:	1000                	add	s0,sp,32
    /* Find free block */
    int blockno = 0;
    /* Find victim page using FIFO. */
    /* Print statement. */
    print_evict_page(0, 0);
    80006400:	4581                	li	a1,0
    80006402:	4501                	li	a0,0
    80006404:	00000097          	auipc	ra,0x0
    80006408:	350080e7          	jalr	848(ra) # 80006754 <print_evict_page>
    /* Read memory from the user to kernel memory first. */
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    struct buf* b;
    b = bread(1, PSASTART+(blockno));
    8000640c:	02100593          	li	a1,33
    80006410:	4505                	li	a0,1
    80006412:	ffffd097          	auipc	ra,0xffffd
    80006416:	ba6080e7          	jalr	-1114(ra) # 80002fb8 <bread>
    8000641a:	84aa                	mv	s1,a0
        // Copy page contents to b.data using memmove.
    bwrite(b);
    8000641c:	ffffd097          	auipc	ra,0xffffd
    80006420:	c8e080e7          	jalr	-882(ra) # 800030aa <bwrite>
    brelse(b);
    80006424:	8526                	mv	a0,s1
    80006426:	ffffd097          	auipc	ra,0xffffd
    8000642a:	cc2080e7          	jalr	-830(ra) # 800030e8 <brelse>

    /* Unmap swapped out page */
    /* Update the resident heap tracker. */
}
    8000642e:	60e2                	ld	ra,24(sp)
    80006430:	6442                	ld	s0,16(sp)
    80006432:	64a2                	ld	s1,8(sp)
    80006434:	6105                	add	sp,sp,32
    80006436:	8082                	ret

0000000080006438 <retrieve_page_from_disk>:

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    80006438:	1141                	add	sp,sp,-16
    8000643a:	e406                	sd	ra,8(sp)
    8000643c:	e022                	sd	s0,0(sp)
    8000643e:	0800                	add	s0,sp,16
    /* Find where the page is located in disk */

    /* Print statement. */
    print_retrieve_page(0, 0);
    80006440:	4581                	li	a1,0
    80006442:	4501                	li	a0,0
    80006444:	00000097          	auipc	ra,0x0
    80006448:	338080e7          	jalr	824(ra) # 8000677c <print_retrieve_page>
    /* Create a kernel page to read memory temporarily into first. */
    
    /* Read the disk block into temp kernel page. */

    /* Copy from temp kernel page to uvaddr (use copyout) */
}
    8000644c:	60a2                	ld	ra,8(sp)
    8000644e:	6402                	ld	s0,0(sp)
    80006450:	0141                	add	sp,sp,16
    80006452:	8082                	ret

0000000080006454 <page_fault_handler>:


void page_fault_handler(void) 
{
    80006454:	7155                	add	sp,sp,-208
    80006456:	e586                	sd	ra,200(sp)
    80006458:	e1a2                	sd	s0,192(sp)
    8000645a:	fd26                	sd	s1,184(sp)
    8000645c:	f94a                	sd	s2,176(sp)
    8000645e:	f54e                	sd	s3,168(sp)
    80006460:	f152                	sd	s4,160(sp)
    80006462:	ed56                	sd	s5,152(sp)
    80006464:	e95a                	sd	s6,144(sp)
    80006466:	e55e                	sd	s7,136(sp)
    80006468:	0980                	add	s0,sp,208
    /* Current process struct */
    struct proc *p = myproc();
    8000646a:	ffffb097          	auipc	ra,0xffffb
    8000646e:	58c080e7          	jalr	1420(ra) # 800019f6 <myproc>
    80006472:	892a                	mv	s2,a0
    80006474:	143024f3          	csrr	s1,stval
    uint64 faulting_addr = 0;
    faulting_addr = r_stval();
    // get the faulting address from stval and find the base address of the page
    // faulting_addr = PGROUNDDOWN(faulting_addr);
    faulting_addr >>= 12;
    faulting_addr <<= 12;
    80006478:	77fd                	lui	a5,0xfffff
    8000647a:	8cfd                	and	s1,s1,a5
    print_page_fault(p->name, faulting_addr);
    8000647c:	15850993          	add	s3,a0,344
    80006480:	85a6                	mv	a1,s1
    80006482:	854e                	mv	a0,s3
    80006484:	00000097          	auipc	ra,0x0
    80006488:	290080e7          	jalr	656(ra) # 80006714 <print_page_fault>

    for(int i=0; i<MAXHEAP; i++) {
    8000648c:	17090793          	add	a5,s2,368
    80006490:	6699                	lui	a3,0x6
    80006492:	f3068693          	add	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    80006496:	96ca                	add	a3,a3,s2
        if(p->heap_tracker[i].addr == faulting_addr) {
    80006498:	6398                	ld	a4,0(a5)
    8000649a:	06970a63          	beq	a4,s1,8000650e <page_fault_handler+0xba>
    for(int i=0; i<MAXHEAP; i++) {
    8000649e:	07e1                	add	a5,a5,24 # fffffffffffff018 <end+0xffffffff7fe658d8>
    800064a0:	fed79ce3          	bne	a5,a3,80006498 <page_fault_handler+0x44>
    uint64 pagesize = PGSIZE, allowed_size = 0, offset = 0, sz = 0;
    pagetable_t pagetable = 0;
    char* path = p->name;

    // same checks as in exec.c
    begin_op();    
    800064a4:	ffffe097          	auipc	ra,0xffffe
    800064a8:	cca080e7          	jalr	-822(ra) # 8000416e <begin_op>

    if((ip = namei(path)) == 0){
    800064ac:	854e                	mv	a0,s3
    800064ae:	ffffe097          	auipc	ra,0xffffe
    800064b2:	ac0080e7          	jalr	-1344(ra) # 80003f6e <namei>
    800064b6:	89aa                	mv	s3,a0
    800064b8:	cd55                	beqz	a0,80006574 <page_fault_handler+0x120>
        end_op();
    }
    ilock(ip);
    800064ba:	ffffd097          	auipc	ra,0xffffd
    800064be:	30e080e7          	jalr	782(ra) # 800037c8 <ilock>
    
    // read the elf header
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800064c2:	04000713          	li	a4,64
    800064c6:	4681                	li	a3,0
    800064c8:	f7040613          	add	a2,s0,-144
    800064cc:	4581                	li	a1,0
    800064ce:	854e                	mv	a0,s3
    800064d0:	ffffd097          	auipc	ra,0xffffd
    800064d4:	5ac080e7          	jalr	1452(ra) # 80003a7c <readi>
    800064d8:	04000793          	li	a5,64
    800064dc:	1af51d63          	bne	a0,a5,80006696 <page_fault_handler+0x242>
        goto bad;

    if(elf.magic != ELF_MAGIC)
    800064e0:	f7042703          	lw	a4,-144(s0)
    800064e4:	464c47b7          	lui	a5,0x464c4
    800064e8:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800064ec:	1af71563          	bne	a4,a5,80006696 <page_fault_handler+0x242>
        goto bad;

    if((pagetable = p->pagetable) == 0)
    800064f0:	05093a83          	ld	s5,80(s2)
    800064f4:	180a8f63          	beqz	s5,80006692 <page_fault_handler+0x23e>
        goto bad;

    // read the program section headers to find the one that contains the faulting address
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800064f8:	f9042903          	lw	s2,-112(s0)
    800064fc:	fa845783          	lhu	a5,-88(s0)
    80006500:	16078763          	beqz	a5,8000666e <page_fault_handler+0x21a>
    80006504:	4a01                	li	s4,0
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            goto bad;
        if(ph.type != ELF_PROG_LOAD)
    80006506:	4b05                	li	s6,1
            continue;
        if(ph.memsz < ph.filesz)
            goto bad;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            goto bad;
        if(ph.vaddr % PGSIZE != 0)
    80006508:	6b85                	lui	s7,0x1
    8000650a:	1bfd                	add	s7,s7,-1 # fff <_entry-0x7ffff001>
    8000650c:	a865                	j	800065c4 <page_fault_handler+0x170>
    /* Go to out, since the remainder of this code is for the heap. */
    goto out;

heap_handle:
    /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages == MAXRESHEAP) {
    8000650e:	6799                	lui	a5,0x6
    80006510:	97ca                	add	a5,a5,s2
    80006512:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    80006516:	06400793          	li	a5,100
    8000651a:	16f70063          	beq	a4,a5,8000667a <page_fault_handler+0x226>
        evict_page_to_disk(p);
    }

    /* 2.3: Map a heap page into the process' address space. (Hint: check growproc) */
    uint64 size;
    size = uvmalloc(p->pagetable, p->sz, p->sz+PGSIZE, PTE_W);
    8000651e:	04893583          	ld	a1,72(s2)
    80006522:	4691                	li	a3,4
    80006524:	6605                	lui	a2,0x1
    80006526:	962e                	add	a2,a2,a1
    80006528:	05093503          	ld	a0,80(s2)
    8000652c:	ffffb097          	auipc	ra,0xffffb
    80006530:	ed8080e7          	jalr	-296(ra) # 80001404 <uvmalloc>
    80006534:	84aa                	mv	s1,a0
    printf("size: %d\n", size);
    80006536:	85aa                	mv	a1,a0
    80006538:	00002517          	auipc	a0,0x2
    8000653c:	35850513          	add	a0,a0,856 # 80008890 <syscalls+0x3f0>
    80006540:	ffffa097          	auipc	ra,0xffffa
    80006544:	046080e7          	jalr	70(ra) # 80000586 <printf>
    p->sz = size;
    80006548:	04993423          	sd	s1,72(s2)
    if (load_from_disk) {
        retrieve_page_from_disk(p, faulting_addr);
    }

    /* Track that another heap page has been brought into memory. */
    p->resident_heap_pages++;
    8000654c:	6799                	lui	a5,0x6
    8000654e:	97ca                	add	a5,a5,s2
    80006550:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    80006554:	2705                	addw	a4,a4,1
    80006556:	f2e7a823          	sw	a4,-208(a5)
  asm volatile("sfence.vma zero, zero");
    8000655a:	12000073          	sfence.vma

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
    8000655e:	60ae                	ld	ra,200(sp)
    80006560:	640e                	ld	s0,192(sp)
    80006562:	74ea                	ld	s1,184(sp)
    80006564:	794a                	ld	s2,176(sp)
    80006566:	79aa                	ld	s3,168(sp)
    80006568:	7a0a                	ld	s4,160(sp)
    8000656a:	6aea                	ld	s5,152(sp)
    8000656c:	6b4a                	ld	s6,144(sp)
    8000656e:	6baa                	ld	s7,136(sp)
    80006570:	6169                	add	sp,sp,208
    80006572:	8082                	ret
        end_op();
    80006574:	ffffe097          	auipc	ra,0xffffe
    80006578:	c74080e7          	jalr	-908(ra) # 800041e8 <end_op>
    ilock(ip);
    8000657c:	4501                	li	a0,0
    8000657e:	ffffd097          	auipc	ra,0xffffd
    80006582:	24a080e7          	jalr	586(ra) # 800037c8 <ilock>
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006586:	04000713          	li	a4,64
    8000658a:	4681                	li	a3,0
    8000658c:	f7040613          	add	a2,s0,-144
    80006590:	4581                	li	a1,0
    80006592:	4501                	li	a0,0
    80006594:	ffffd097          	auipc	ra,0xffffd
    80006598:	4e8080e7          	jalr	1256(ra) # 80003a7c <readi>
    8000659c:	04000793          	li	a5,64
    800065a0:	faf51de3          	bne	a0,a5,8000655a <page_fault_handler+0x106>
    if(elf.magic != ELF_MAGIC)
    800065a4:	f7042703          	lw	a4,-144(s0)
    800065a8:	464c47b7          	lui	a5,0x464c4
    800065ac:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800065b0:	faf715e3          	bne	a4,a5,8000655a <page_fault_handler+0x106>
    800065b4:	bf35                	j	800064f0 <page_fault_handler+0x9c>
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800065b6:	2a05                	addw	s4,s4,1
    800065b8:	0389091b          	addw	s2,s2,56
    800065bc:	fa845783          	lhu	a5,-88(s0)
    800065c0:	0afa5763          	bge	s4,a5,8000666e <page_fault_handler+0x21a>
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800065c4:	2901                	sext.w	s2,s2
    800065c6:	03800713          	li	a4,56
    800065ca:	86ca                	mv	a3,s2
    800065cc:	f3840613          	add	a2,s0,-200
    800065d0:	4581                	li	a1,0
    800065d2:	854e                	mv	a0,s3
    800065d4:	ffffd097          	auipc	ra,0xffffd
    800065d8:	4a8080e7          	jalr	1192(ra) # 80003a7c <readi>
    800065dc:	03800793          	li	a5,56
    800065e0:	0af51363          	bne	a0,a5,80006686 <page_fault_handler+0x232>
        if(ph.type != ELF_PROG_LOAD)
    800065e4:	f3842783          	lw	a5,-200(s0)
    800065e8:	fd6797e3          	bne	a5,s6,800065b6 <page_fault_handler+0x162>
        if(ph.memsz < ph.filesz)
    800065ec:	f6043783          	ld	a5,-160(s0)
    800065f0:	f5843703          	ld	a4,-168(s0)
    800065f4:	08e7e963          	bltu	a5,a4,80006686 <page_fault_handler+0x232>
        if(ph.vaddr + ph.memsz < ph.vaddr)
    800065f8:	f4843703          	ld	a4,-184(s0)
    800065fc:	97ba                	add	a5,a5,a4
    800065fe:	08e7e463          	bltu	a5,a4,80006686 <page_fault_handler+0x232>
        if(ph.vaddr % PGSIZE != 0)
    80006602:	017776b3          	and	a3,a4,s7
    80006606:	e2c1                	bnez	a3,80006686 <page_fault_handler+0x232>
        if((faulting_addr >= ph.vaddr) && (faulting_addr < (ph.vaddr + ph.memsz))){
    80006608:	fae4e7e3          	bltu	s1,a4,800065b6 <page_fault_handler+0x162>
    8000660c:	faf4f5e3          	bgeu	s1,a5,800065b6 <page_fault_handler+0x162>
            allowed_size = ph.vaddr + ph.memsz - faulting_addr;
    80006610:	40978933          	sub	s2,a5,s1
            if (allowed_size < pagesize)
    80006614:	6785                	lui	a5,0x1
    80006616:	0127f363          	bgeu	a5,s2,8000661c <page_fault_handler+0x1c8>
    8000661a:	6905                	lui	s2,0x1
            offset = faulting_addr - ph.vaddr + ph.off;
    8000661c:	f4043a03          	ld	s4,-192(s0)
    80006620:	40ea0a33          	sub	s4,s4,a4
    80006624:	9a26                	add	s4,s4,s1
            uvmalloc(pagetable, faulting_addr, faulting_addr + pagesize, flags2perm(ph.flags));
    80006626:	00990b33          	add	s6,s2,s1
    8000662a:	f3c42503          	lw	a0,-196(s0)
    8000662e:	ffffe097          	auipc	ra,0xffffe
    80006632:	660080e7          	jalr	1632(ra) # 80004c8e <flags2perm>
    80006636:	86aa                	mv	a3,a0
    80006638:	865a                	mv	a2,s6
    8000663a:	85a6                	mv	a1,s1
    8000663c:	8556                	mv	a0,s5
    8000663e:	ffffb097          	auipc	ra,0xffffb
    80006642:	dc6080e7          	jalr	-570(ra) # 80001404 <uvmalloc>
            loadseg(pagetable, faulting_addr, ip, offset, pagesize);
    80006646:	2901                	sext.w	s2,s2
    80006648:	874a                	mv	a4,s2
    8000664a:	000a069b          	sext.w	a3,s4
    8000664e:	864e                	mv	a2,s3
    80006650:	85a6                	mv	a1,s1
    80006652:	8556                	mv	a0,s5
    80006654:	ffffe097          	auipc	ra,0xffffe
    80006658:	654080e7          	jalr	1620(ra) # 80004ca8 <loadseg>
            print_load_seg(faulting_addr, ph.off, pagesize);
    8000665c:	864a                	mv	a2,s2
    8000665e:	f4043583          	ld	a1,-192(s0)
    80006662:	8526                	mv	a0,s1
    80006664:	00000097          	auipc	ra,0x0
    80006668:	140080e7          	jalr	320(ra) # 800067a4 <print_load_seg>
            goto out;
    8000666c:	b5fd                	j	8000655a <page_fault_handler+0x106>
    iunlockput(ip);
    8000666e:	854e                	mv	a0,s3
    80006670:	ffffd097          	auipc	ra,0xffffd
    80006674:	3ba080e7          	jalr	954(ra) # 80003a2a <iunlockput>
    goto out;
    80006678:	b5cd                	j	8000655a <page_fault_handler+0x106>
        evict_page_to_disk(p);
    8000667a:	854a                	mv	a0,s2
    8000667c:	00000097          	auipc	ra,0x0
    80006680:	d7a080e7          	jalr	-646(ra) # 800063f6 <evict_page_to_disk>
    80006684:	bd69                	j	8000651e <page_fault_handler+0xca>
        proc_freepagetable(pagetable, sz);
    80006686:	4581                	li	a1,0
    80006688:	8556                	mv	a0,s5
    8000668a:	ffffb097          	auipc	ra,0xffffb
    8000668e:	4cc080e7          	jalr	1228(ra) # 80001b56 <proc_freepagetable>
    if(ip){
    80006692:	ec0984e3          	beqz	s3,8000655a <page_fault_handler+0x106>
        iunlockput(ip);
    80006696:	854e                	mv	a0,s3
    80006698:	ffffd097          	auipc	ra,0xffffd
    8000669c:	392080e7          	jalr	914(ra) # 80003a2a <iunlockput>
        end_op();
    800066a0:	ffffe097          	auipc	ra,0xffffe
    800066a4:	b48080e7          	jalr	-1208(ra) # 800041e8 <end_op>
    800066a8:	bd4d                	j	8000655a <page_fault_handler+0x106>

00000000800066aa <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    800066aa:	1141                	add	sp,sp,-16
    800066ac:	e406                	sd	ra,8(sp)
    800066ae:	e022                	sd	s0,0(sp)
    800066b0:	0800                	add	s0,sp,16
    800066b2:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    800066b4:	00002517          	auipc	a0,0x2
    800066b8:	1ec50513          	add	a0,a0,492 # 800088a0 <syscalls+0x400>
    800066bc:	ffffa097          	auipc	ra,0xffffa
    800066c0:	eca080e7          	jalr	-310(ra) # 80000586 <printf>
}
    800066c4:	60a2                	ld	ra,8(sp)
    800066c6:	6402                	ld	s0,0(sp)
    800066c8:	0141                	add	sp,sp,16
    800066ca:	8082                	ret

00000000800066cc <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    800066cc:	1141                	add	sp,sp,-16
    800066ce:	e406                	sd	ra,8(sp)
    800066d0:	e022                	sd	s0,0(sp)
    800066d2:	0800                	add	s0,sp,16
    800066d4:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    800066d6:	00002517          	auipc	a0,0x2
    800066da:	1f250513          	add	a0,a0,498 # 800088c8 <syscalls+0x428>
    800066de:	ffffa097          	auipc	ra,0xffffa
    800066e2:	ea8080e7          	jalr	-344(ra) # 80000586 <printf>
}
    800066e6:	60a2                	ld	ra,8(sp)
    800066e8:	6402                	ld	s0,0(sp)
    800066ea:	0141                	add	sp,sp,16
    800066ec:	8082                	ret

00000000800066ee <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    800066ee:	1141                	add	sp,sp,-16
    800066f0:	e406                	sd	ra,8(sp)
    800066f2:	e022                	sd	s0,0(sp)
    800066f4:	0800                	add	s0,sp,16
    800066f6:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    800066f8:	862e                	mv	a2,a1
    800066fa:	85aa                	mv	a1,a0
    800066fc:	00002517          	auipc	a0,0x2
    80006700:	1f450513          	add	a0,a0,500 # 800088f0 <syscalls+0x450>
    80006704:	ffffa097          	auipc	ra,0xffffa
    80006708:	e82080e7          	jalr	-382(ra) # 80000586 <printf>
        name, vaddr, size);
}
    8000670c:	60a2                	ld	ra,8(sp)
    8000670e:	6402                	ld	s0,0(sp)
    80006710:	0141                	add	sp,sp,16
    80006712:	8082                	ret

0000000080006714 <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    80006714:	1101                	add	sp,sp,-32
    80006716:	ec06                	sd	ra,24(sp)
    80006718:	e822                	sd	s0,16(sp)
    8000671a:	e426                	sd	s1,8(sp)
    8000671c:	e04a                	sd	s2,0(sp)
    8000671e:	1000                	add	s0,sp,32
    80006720:	84aa                	mv	s1,a0
    80006722:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    80006724:	00002517          	auipc	a0,0x2
    80006728:	21450513          	add	a0,a0,532 # 80008938 <syscalls+0x498>
    8000672c:	ffffa097          	auipc	ra,0xffffa
    80006730:	e5a080e7          	jalr	-422(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    80006734:	864a                	mv	a2,s2
    80006736:	85a6                	mv	a1,s1
    80006738:	00002517          	auipc	a0,0x2
    8000673c:	23050513          	add	a0,a0,560 # 80008968 <syscalls+0x4c8>
    80006740:	ffffa097          	auipc	ra,0xffffa
    80006744:	e46080e7          	jalr	-442(ra) # 80000586 <printf>
}
    80006748:	60e2                	ld	ra,24(sp)
    8000674a:	6442                	ld	s0,16(sp)
    8000674c:	64a2                	ld	s1,8(sp)
    8000674e:	6902                	ld	s2,0(sp)
    80006750:	6105                	add	sp,sp,32
    80006752:	8082                	ret

0000000080006754 <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    80006754:	1141                	add	sp,sp,-16
    80006756:	e406                	sd	ra,8(sp)
    80006758:	e022                	sd	s0,0(sp)
    8000675a:	0800                	add	s0,sp,16
    8000675c:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    8000675e:	0035869b          	addw	a3,a1,3
    80006762:	85aa                	mv	a1,a0
    80006764:	00002517          	auipc	a0,0x2
    80006768:	22450513          	add	a0,a0,548 # 80008988 <syscalls+0x4e8>
    8000676c:	ffffa097          	auipc	ra,0xffffa
    80006770:	e1a080e7          	jalr	-486(ra) # 80000586 <printf>
}
    80006774:	60a2                	ld	ra,8(sp)
    80006776:	6402                	ld	s0,0(sp)
    80006778:	0141                	add	sp,sp,16
    8000677a:	8082                	ret

000000008000677c <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    8000677c:	1141                	add	sp,sp,-16
    8000677e:	e406                	sd	ra,8(sp)
    80006780:	e022                	sd	s0,0(sp)
    80006782:	0800                	add	s0,sp,16
    80006784:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    80006786:	0035869b          	addw	a3,a1,3
    8000678a:	85aa                	mv	a1,a0
    8000678c:	00002517          	auipc	a0,0x2
    80006790:	22450513          	add	a0,a0,548 # 800089b0 <syscalls+0x510>
    80006794:	ffffa097          	auipc	ra,0xffffa
    80006798:	df2080e7          	jalr	-526(ra) # 80000586 <printf>
}
    8000679c:	60a2                	ld	ra,8(sp)
    8000679e:	6402                	ld	s0,0(sp)
    800067a0:	0141                	add	sp,sp,16
    800067a2:	8082                	ret

00000000800067a4 <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    800067a4:	1141                	add	sp,sp,-16
    800067a6:	e406                	sd	ra,8(sp)
    800067a8:	e022                	sd	s0,0(sp)
    800067aa:	0800                	add	s0,sp,16
    800067ac:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    800067ae:	862e                	mv	a2,a1
    800067b0:	85aa                	mv	a1,a0
    800067b2:	00002517          	auipc	a0,0x2
    800067b6:	22650513          	add	a0,a0,550 # 800089d8 <syscalls+0x538>
    800067ba:	ffffa097          	auipc	ra,0xffffa
    800067be:	dcc080e7          	jalr	-564(ra) # 80000586 <printf>
}
    800067c2:	60a2                	ld	ra,8(sp)
    800067c4:	6402                	ld	s0,0(sp)
    800067c6:	0141                	add	sp,sp,16
    800067c8:	8082                	ret

00000000800067ca <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    800067ca:	1141                	add	sp,sp,-16
    800067cc:	e406                	sd	ra,8(sp)
    800067ce:	e022                	sd	s0,0(sp)
    800067d0:	0800                	add	s0,sp,16
    800067d2:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    800067d4:	862e                	mv	a2,a1
    800067d6:	85aa                	mv	a1,a0
    800067d8:	00002517          	auipc	a0,0x2
    800067dc:	22850513          	add	a0,a0,552 # 80008a00 <syscalls+0x560>
    800067e0:	ffffa097          	auipc	ra,0xffffa
    800067e4:	da6080e7          	jalr	-602(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    800067e8:	60a2                	ld	ra,8(sp)
    800067ea:	6402                	ld	s0,0(sp)
    800067ec:	0141                	add	sp,sp,16
    800067ee:	8082                	ret
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	sll	a0,a0,0xd
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
    800070ac:	357d                	addw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	sll	a0,a0,0xd
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
