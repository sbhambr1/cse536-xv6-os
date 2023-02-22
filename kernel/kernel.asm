
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	bf010113          	add	sp,sp,-1040 # 80008bf0 <stack0>
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
    80000054:	a6070713          	add	a4,a4,-1440 # 80008ab0 <timer_scratch>
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
    80000066:	c2e78793          	add	a5,a5,-978 # 80005c90 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fe650ef>
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
    8000012e:	436080e7          	jalr	1078(ra) # 80002560 <either_copyin>
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
    80000188:	a6c50513          	add	a0,a0,-1428 # 80010bf0 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a5c48493          	add	s1,s1,-1444 # 80010bf0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	aec90913          	add	s2,s2,-1300 # 80010c88 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00002097          	auipc	ra,0x2
    800001b8:	82e080e7          	jalr	-2002(ra) # 800019e2 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	1f2080e7          	jalr	498(ra) # 800023ae <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f24080e7          	jalr	-220(ra) # 800020ee <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a1270713          	add	a4,a4,-1518 # 80010bf0 <cons>
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
    80000214:	2fa080e7          	jalr	762(ra) # 8000250a <either_copyout>
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
    8000022c:	9c850513          	add	a0,a0,-1592 # 80010bf0 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	9b250513          	add	a0,a0,-1614 # 80010bf0 <cons>
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
    80000272:	a0f72d23          	sw	a5,-1510(a4) # 80010c88 <cons+0x98>
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
    800002cc:	92850513          	add	a0,a0,-1752 # 80010bf0 <cons>
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
    800002f2:	2c8080e7          	jalr	712(ra) # 800025b6 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	8fa50513          	add	a0,a0,-1798 # 80010bf0 <cons>
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
    8000031e:	8d670713          	add	a4,a4,-1834 # 80010bf0 <cons>
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
    80000348:	8ac78793          	add	a5,a5,-1876 # 80010bf0 <cons>
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
    80000376:	9167a783          	lw	a5,-1770(a5) # 80010c88 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	86a70713          	add	a4,a4,-1942 # 80010bf0 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	85a48493          	add	s1,s1,-1958 # 80010bf0 <cons>
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
    800003d6:	81e70713          	add	a4,a4,-2018 # 80010bf0 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	8af72423          	sw	a5,-1880(a4) # 80010c90 <cons+0xa0>
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
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	7e278793          	add	a5,a5,2018 # 80010bf0 <cons>
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
    80000436:	84c7ad23          	sw	a2,-1958(a5) # 80010c8c <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	84e50513          	add	a0,a0,-1970 # 80010c88 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d10080e7          	jalr	-752(ra) # 80002152 <wakeup>
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
    80000460:	79450513          	add	a0,a0,1940 # 80010bf0 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00198797          	auipc	a5,0x198
    80000478:	d1c78793          	add	a5,a5,-740 # 80198190 <devsw>
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
    8000054c:	7607a423          	sw	zero,1896(a5) # 80010cb0 <pr+0x18>
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
    8000056e:	4ae50513          	add	a0,a0,1198 # 80008a18 <syscalls+0x5a0>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	4ef72a23          	sw	a5,1268(a4) # 80008a70 <panicked>
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
    800005bc:	6f8dad83          	lw	s11,1784(s11) # 80010cb0 <pr+0x18>
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
    800005fa:	6a250513          	add	a0,a0,1698 # 80010c98 <pr>
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
    80000758:	54450513          	add	a0,a0,1348 # 80010c98 <pr>
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
    80000774:	52848493          	add	s1,s1,1320 # 80010c98 <pr>
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
    800007d4:	4e850513          	add	a0,a0,1256 # 80010cb8 <uart_tx_lock>
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
    80000800:	2747a783          	lw	a5,628(a5) # 80008a70 <panicked>
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
    80000838:	2447b783          	ld	a5,580(a5) # 80008a78 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	24473703          	ld	a4,580(a4) # 80008a80 <uart_tx_w>
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
    80000862:	45aa0a13          	add	s4,s4,1114 # 80010cb8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	21248493          	add	s1,s1,530 # 80008a78 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	21298993          	add	s3,s3,530 # 80008a80 <uart_tx_w>
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
    80000894:	8c2080e7          	jalr	-1854(ra) # 80002152 <wakeup>
    
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
    800008d0:	3ec50513          	add	a0,a0,1004 # 80010cb8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1947a783          	lw	a5,404(a5) # 80008a70 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	19a73703          	ld	a4,410(a4) # 80008a80 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	18a7b783          	ld	a5,394(a5) # 80008a78 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	3be98993          	add	s3,s3,958 # 80010cb8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	17648493          	add	s1,s1,374 # 80008a78 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	17690913          	add	s2,s2,374 # 80008a80 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7d4080e7          	jalr	2004(ra) # 800020ee <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	38848493          	add	s1,s1,904 # 80010cb8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	12e7be23          	sd	a4,316(a5) # 80008a80 <uart_tx_w>
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
    800009ba:	30248493          	add	s1,s1,770 # 80010cb8 <uart_tx_lock>
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
    800009fc:	d1878793          	add	a5,a5,-744 # 80199710 <end>
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
    80000a1c:	2d890913          	add	s2,s2,728 # 80010cf0 <kmem>
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
    80000aba:	23a50513          	add	a0,a0,570 # 80010cf0 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00199517          	auipc	a0,0x199
    80000ace:	c4650513          	add	a0,a0,-954 # 80199710 <end>
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
    80000af0:	20448493          	add	s1,s1,516 # 80010cf0 <kmem>
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
    80000b08:	1ec50513          	add	a0,a0,492 # 80010cf0 <kmem>
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
    80000b34:	1c050513          	add	a0,a0,448 # 80010cf0 <kmem>
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
    80000b70:	e5a080e7          	jalr	-422(ra) # 800019c6 <mycpu>
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
    80000ba2:	e28080e7          	jalr	-472(ra) # 800019c6 <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	e1c080e7          	jalr	-484(ra) # 800019c6 <mycpu>
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
    80000bc6:	e04080e7          	jalr	-508(ra) # 800019c6 <mycpu>
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
    80000c06:	dc4080e7          	jalr	-572(ra) # 800019c6 <mycpu>
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
    80000c32:	d98080e7          	jalr	-616(ra) # 800019c6 <mycpu>
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
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fe658f1>
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
    80000e7e:	b3c080e7          	jalr	-1220(ra) # 800019b6 <cpuid>

    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	c0670713          	add	a4,a4,-1018 # 80008a88 <started>
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
    80000e9a:	b20080e7          	jalr	-1248(ra) # 800019b6 <cpuid>
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
    80000ebc:	848080e7          	jalr	-1976(ra) # 80002700 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e10080e7          	jalr	-496(ra) # 80005cd0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	06e080e7          	jalr	110(ra) # 80001f36 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b3850513          	add	a0,a0,-1224 # 80008a18 <syscalls+0x5a0>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	b1850513          	add	a0,a0,-1256 # 80008a18 <syscalls+0x5a0>
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
    80000f2c:	9d2080e7          	jalr	-1582(ra) # 800018fa <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	7a8080e7          	jalr	1960(ra) # 800026d8 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	7c8080e7          	jalr	1992(ra) # 80002700 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	d7a080e7          	jalr	-646(ra) # 80005cba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	d88080e7          	jalr	-632(ra) # 80005cd0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f06080e7          	jalr	-250(ra) # 80002e56 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	5a4080e7          	jalr	1444(ra) # 800034fc <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	51a080e7          	jalr	1306(ra) # 8000447a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	e70080e7          	jalr	-400(ra) # 80005dd8 <virtio_disk_init>
    init_psa_regions();
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	380080e7          	jalr	896(ra) # 800062f0 <init_psa_regions>
    userinit();      // first user process
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	d4a080e7          	jalr	-694(ra) # 80001cc2 <userinit>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	b0f72123          	sw	a5,-1278(a4) # 80008a88 <started>
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
    80000f9e:	af67b783          	ld	a5,-1290(a5) # 80008a90 <kernel_pagetable>
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
    80001018:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7fe658e7>
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
    80001234:	62c080e7          	jalr	1580(ra) # 8000185c <proc_mapstacks>
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
    8000125a:	82a7bd23          	sd	a0,-1990(a5) # 80008a90 <kernel_pagetable>
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
    800014d2:	83a9                	srl	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014d4:	00c79513          	sll	a0,a5,0xc
    800014d8:	00000097          	auipc	ra,0x0
    800014dc:	fde080e7          	jalr	-34(ra) # 800014b6 <freewalk>
      pagetable[i] = 0;
    800014e0:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014e4:	04a1                	add	s1,s1,8
    800014e6:	03248163          	beq	s1,s2,80001508 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014ea:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014ec:	00f7f713          	and	a4,a5,15
    800014f0:	ff3701e3          	beq	a4,s3,800014d2 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014f4:	8b85                	and	a5,a5,1
    800014f6:	d7fd                	beqz	a5,800014e4 <freewalk+0x2e>
      panic("freewalk: leaf");
    800014f8:	00007517          	auipc	a0,0x7
    800014fc:	c6850513          	add	a0,a0,-920 # 80008160 <digits+0x120>
    80001500:	fffff097          	auipc	ra,0xfffff
    80001504:	03c080e7          	jalr	60(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    80001508:	8552                	mv	a0,s4
    8000150a:	fffff097          	auipc	ra,0xfffff
    8000150e:	4da080e7          	jalr	1242(ra) # 800009e4 <kfree>
}
    80001512:	70a2                	ld	ra,40(sp)
    80001514:	7402                	ld	s0,32(sp)
    80001516:	64e2                	ld	s1,24(sp)
    80001518:	6942                	ld	s2,16(sp)
    8000151a:	69a2                	ld	s3,8(sp)
    8000151c:	6a02                	ld	s4,0(sp)
    8000151e:	6145                	add	sp,sp,48
    80001520:	8082                	ret

0000000080001522 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001522:	1101                	add	sp,sp,-32
    80001524:	ec06                	sd	ra,24(sp)
    80001526:	e822                	sd	s0,16(sp)
    80001528:	e426                	sd	s1,8(sp)
    8000152a:	1000                	add	s0,sp,32
    8000152c:	84aa                	mv	s1,a0
  if(sz > 0)
    8000152e:	e999                	bnez	a1,80001544 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001530:	8526                	mv	a0,s1
    80001532:	00000097          	auipc	ra,0x0
    80001536:	f84080e7          	jalr	-124(ra) # 800014b6 <freewalk>
}
    8000153a:	60e2                	ld	ra,24(sp)
    8000153c:	6442                	ld	s0,16(sp)
    8000153e:	64a2                	ld	s1,8(sp)
    80001540:	6105                	add	sp,sp,32
    80001542:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001544:	6785                	lui	a5,0x1
    80001546:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001548:	95be                	add	a1,a1,a5
    8000154a:	4685                	li	a3,1
    8000154c:	00c5d613          	srl	a2,a1,0xc
    80001550:	4581                	li	a1,0
    80001552:	00000097          	auipc	ra,0x0
    80001556:	d14080e7          	jalr	-748(ra) # 80001266 <uvmunmap>
    8000155a:	bfd9                	j	80001530 <uvmfree+0xe>

000000008000155c <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    8000155c:	c679                	beqz	a2,8000162a <uvmcopy+0xce>
{
    8000155e:	715d                	add	sp,sp,-80
    80001560:	e486                	sd	ra,72(sp)
    80001562:	e0a2                	sd	s0,64(sp)
    80001564:	fc26                	sd	s1,56(sp)
    80001566:	f84a                	sd	s2,48(sp)
    80001568:	f44e                	sd	s3,40(sp)
    8000156a:	f052                	sd	s4,32(sp)
    8000156c:	ec56                	sd	s5,24(sp)
    8000156e:	e85a                	sd	s6,16(sp)
    80001570:	e45e                	sd	s7,8(sp)
    80001572:	0880                	add	s0,sp,80
    80001574:	8b2a                	mv	s6,a0
    80001576:	8aae                	mv	s5,a1
    80001578:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    8000157a:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    8000157c:	4601                	li	a2,0
    8000157e:	85ce                	mv	a1,s3
    80001580:	855a                	mv	a0,s6
    80001582:	00000097          	auipc	ra,0x0
    80001586:	a36080e7          	jalr	-1482(ra) # 80000fb8 <walk>
    8000158a:	c531                	beqz	a0,800015d6 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    8000158c:	6118                	ld	a4,0(a0)
    8000158e:	00177793          	and	a5,a4,1
    80001592:	cbb1                	beqz	a5,800015e6 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80001594:	00a75593          	srl	a1,a4,0xa
    80001598:	00c59b93          	sll	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    8000159c:	3ff77493          	and	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a0:	fffff097          	auipc	ra,0xfffff
    800015a4:	542080e7          	jalr	1346(ra) # 80000ae2 <kalloc>
    800015a8:	892a                	mv	s2,a0
    800015aa:	c939                	beqz	a0,80001600 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015ac:	6605                	lui	a2,0x1
    800015ae:	85de                	mv	a1,s7
    800015b0:	fffff097          	auipc	ra,0xfffff
    800015b4:	77a080e7          	jalr	1914(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015b8:	8726                	mv	a4,s1
    800015ba:	86ca                	mv	a3,s2
    800015bc:	6605                	lui	a2,0x1
    800015be:	85ce                	mv	a1,s3
    800015c0:	8556                	mv	a0,s5
    800015c2:	00000097          	auipc	ra,0x0
    800015c6:	ade080e7          	jalr	-1314(ra) # 800010a0 <mappages>
    800015ca:	e515                	bnez	a0,800015f6 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015cc:	6785                	lui	a5,0x1
    800015ce:	99be                	add	s3,s3,a5
    800015d0:	fb49e6e3          	bltu	s3,s4,8000157c <uvmcopy+0x20>
    800015d4:	a081                	j	80001614 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015d6:	00007517          	auipc	a0,0x7
    800015da:	b9a50513          	add	a0,a0,-1126 # 80008170 <digits+0x130>
    800015de:	fffff097          	auipc	ra,0xfffff
    800015e2:	f5e080e7          	jalr	-162(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015e6:	00007517          	auipc	a0,0x7
    800015ea:	baa50513          	add	a0,a0,-1110 # 80008190 <digits+0x150>
    800015ee:	fffff097          	auipc	ra,0xfffff
    800015f2:	f4e080e7          	jalr	-178(ra) # 8000053c <panic>
      kfree(mem);
    800015f6:	854a                	mv	a0,s2
    800015f8:	fffff097          	auipc	ra,0xfffff
    800015fc:	3ec080e7          	jalr	1004(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001600:	4685                	li	a3,1
    80001602:	00c9d613          	srl	a2,s3,0xc
    80001606:	4581                	li	a1,0
    80001608:	8556                	mv	a0,s5
    8000160a:	00000097          	auipc	ra,0x0
    8000160e:	c5c080e7          	jalr	-932(ra) # 80001266 <uvmunmap>
  return -1;
    80001612:	557d                	li	a0,-1
}
    80001614:	60a6                	ld	ra,72(sp)
    80001616:	6406                	ld	s0,64(sp)
    80001618:	74e2                	ld	s1,56(sp)
    8000161a:	7942                	ld	s2,48(sp)
    8000161c:	79a2                	ld	s3,40(sp)
    8000161e:	7a02                	ld	s4,32(sp)
    80001620:	6ae2                	ld	s5,24(sp)
    80001622:	6b42                	ld	s6,16(sp)
    80001624:	6ba2                	ld	s7,8(sp)
    80001626:	6161                	add	sp,sp,80
    80001628:	8082                	ret
  return 0;
    8000162a:	4501                	li	a0,0
}
    8000162c:	8082                	ret

000000008000162e <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000162e:	1141                	add	sp,sp,-16
    80001630:	e406                	sd	ra,8(sp)
    80001632:	e022                	sd	s0,0(sp)
    80001634:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001636:	4601                	li	a2,0
    80001638:	00000097          	auipc	ra,0x0
    8000163c:	980080e7          	jalr	-1664(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001640:	c901                	beqz	a0,80001650 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001642:	611c                	ld	a5,0(a0)
    80001644:	9bbd                	and	a5,a5,-17
    80001646:	e11c                	sd	a5,0(a0)
}
    80001648:	60a2                	ld	ra,8(sp)
    8000164a:	6402                	ld	s0,0(sp)
    8000164c:	0141                	add	sp,sp,16
    8000164e:	8082                	ret
    panic("uvmclear");
    80001650:	00007517          	auipc	a0,0x7
    80001654:	b6050513          	add	a0,a0,-1184 # 800081b0 <digits+0x170>
    80001658:	fffff097          	auipc	ra,0xfffff
    8000165c:	ee4080e7          	jalr	-284(ra) # 8000053c <panic>

0000000080001660 <uvminvalid>:

// CSE 536: mark a PTE invalid. For swapping 
// pages in and out of memory.
void
uvminvalid(pagetable_t pagetable, uint64 va)
{
    80001660:	1141                	add	sp,sp,-16
    80001662:	e406                	sd	ra,8(sp)
    80001664:	e022                	sd	s0,0(sp)
    80001666:	0800                	add	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001668:	4601                	li	a2,0
    8000166a:	00000097          	auipc	ra,0x0
    8000166e:	94e080e7          	jalr	-1714(ra) # 80000fb8 <walk>
  if(pte == 0)
    80001672:	c901                	beqz	a0,80001682 <uvminvalid+0x22>
    panic("uvminvalid");
  *pte &= ~PTE_V;
    80001674:	611c                	ld	a5,0(a0)
    80001676:	9bf9                	and	a5,a5,-2
    80001678:	e11c                	sd	a5,0(a0)
}
    8000167a:	60a2                	ld	ra,8(sp)
    8000167c:	6402                	ld	s0,0(sp)
    8000167e:	0141                	add	sp,sp,16
    80001680:	8082                	ret
    panic("uvminvalid");
    80001682:	00007517          	auipc	a0,0x7
    80001686:	b3e50513          	add	a0,a0,-1218 # 800081c0 <digits+0x180>
    8000168a:	fffff097          	auipc	ra,0xfffff
    8000168e:	eb2080e7          	jalr	-334(ra) # 8000053c <panic>

0000000080001692 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001692:	c6bd                	beqz	a3,80001700 <copyout+0x6e>
{
    80001694:	715d                	add	sp,sp,-80
    80001696:	e486                	sd	ra,72(sp)
    80001698:	e0a2                	sd	s0,64(sp)
    8000169a:	fc26                	sd	s1,56(sp)
    8000169c:	f84a                	sd	s2,48(sp)
    8000169e:	f44e                	sd	s3,40(sp)
    800016a0:	f052                	sd	s4,32(sp)
    800016a2:	ec56                	sd	s5,24(sp)
    800016a4:	e85a                	sd	s6,16(sp)
    800016a6:	e45e                	sd	s7,8(sp)
    800016a8:	e062                	sd	s8,0(sp)
    800016aa:	0880                	add	s0,sp,80
    800016ac:	8b2a                	mv	s6,a0
    800016ae:	8c2e                	mv	s8,a1
    800016b0:	8a32                	mv	s4,a2
    800016b2:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    800016b4:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if (pa0 == 0){
      return -1;
    }
    n = PGSIZE - (dstva - va0);
    800016b6:	6a85                	lui	s5,0x1
    800016b8:	a015                	j	800016dc <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    800016ba:	9562                	add	a0,a0,s8
    800016bc:	0004861b          	sext.w	a2,s1
    800016c0:	85d2                	mv	a1,s4
    800016c2:	41250533          	sub	a0,a0,s2
    800016c6:	fffff097          	auipc	ra,0xfffff
    800016ca:	664080e7          	jalr	1636(ra) # 80000d2a <memmove>

    len -= n;
    800016ce:	409989b3          	sub	s3,s3,s1
    src += n;
    800016d2:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016d4:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016d8:	02098263          	beqz	s3,800016fc <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016dc:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016e0:	85ca                	mv	a1,s2
    800016e2:	855a                	mv	a0,s6
    800016e4:	00000097          	auipc	ra,0x0
    800016e8:	97a080e7          	jalr	-1670(ra) # 8000105e <walkaddr>
    if (pa0 == 0){
    800016ec:	cd01                	beqz	a0,80001704 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016ee:	418904b3          	sub	s1,s2,s8
    800016f2:	94d6                	add	s1,s1,s5
    800016f4:	fc99f3e3          	bgeu	s3,s1,800016ba <copyout+0x28>
    800016f8:	84ce                	mv	s1,s3
    800016fa:	b7c1                	j	800016ba <copyout+0x28>
  }
  return 0;
    800016fc:	4501                	li	a0,0
    800016fe:	a021                	j	80001706 <copyout+0x74>
    80001700:	4501                	li	a0,0
}
    80001702:	8082                	ret
      return -1;
    80001704:	557d                	li	a0,-1
}
    80001706:	60a6                	ld	ra,72(sp)
    80001708:	6406                	ld	s0,64(sp)
    8000170a:	74e2                	ld	s1,56(sp)
    8000170c:	7942                	ld	s2,48(sp)
    8000170e:	79a2                	ld	s3,40(sp)
    80001710:	7a02                	ld	s4,32(sp)
    80001712:	6ae2                	ld	s5,24(sp)
    80001714:	6b42                	ld	s6,16(sp)
    80001716:	6ba2                	ld	s7,8(sp)
    80001718:	6c02                	ld	s8,0(sp)
    8000171a:	6161                	add	sp,sp,80
    8000171c:	8082                	ret

000000008000171e <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000171e:	caa5                	beqz	a3,8000178e <copyin+0x70>
{
    80001720:	715d                	add	sp,sp,-80
    80001722:	e486                	sd	ra,72(sp)
    80001724:	e0a2                	sd	s0,64(sp)
    80001726:	fc26                	sd	s1,56(sp)
    80001728:	f84a                	sd	s2,48(sp)
    8000172a:	f44e                	sd	s3,40(sp)
    8000172c:	f052                	sd	s4,32(sp)
    8000172e:	ec56                	sd	s5,24(sp)
    80001730:	e85a                	sd	s6,16(sp)
    80001732:	e45e                	sd	s7,8(sp)
    80001734:	e062                	sd	s8,0(sp)
    80001736:	0880                	add	s0,sp,80
    80001738:	8b2a                	mv	s6,a0
    8000173a:	8a2e                	mv	s4,a1
    8000173c:	8c32                	mv	s8,a2
    8000173e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001740:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001742:	6a85                	lui	s5,0x1
    80001744:	a01d                	j	8000176a <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001746:	018505b3          	add	a1,a0,s8
    8000174a:	0004861b          	sext.w	a2,s1
    8000174e:	412585b3          	sub	a1,a1,s2
    80001752:	8552                	mv	a0,s4
    80001754:	fffff097          	auipc	ra,0xfffff
    80001758:	5d6080e7          	jalr	1494(ra) # 80000d2a <memmove>

    len -= n;
    8000175c:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001760:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001762:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001766:	02098263          	beqz	s3,8000178a <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000176a:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    8000176e:	85ca                	mv	a1,s2
    80001770:	855a                	mv	a0,s6
    80001772:	00000097          	auipc	ra,0x0
    80001776:	8ec080e7          	jalr	-1812(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000177a:	cd01                	beqz	a0,80001792 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    8000177c:	418904b3          	sub	s1,s2,s8
    80001780:	94d6                	add	s1,s1,s5
    80001782:	fc99f2e3          	bgeu	s3,s1,80001746 <copyin+0x28>
    80001786:	84ce                	mv	s1,s3
    80001788:	bf7d                	j	80001746 <copyin+0x28>
  }
  return 0;
    8000178a:	4501                	li	a0,0
    8000178c:	a021                	j	80001794 <copyin+0x76>
    8000178e:	4501                	li	a0,0
}
    80001790:	8082                	ret
      return -1;
    80001792:	557d                	li	a0,-1
}
    80001794:	60a6                	ld	ra,72(sp)
    80001796:	6406                	ld	s0,64(sp)
    80001798:	74e2                	ld	s1,56(sp)
    8000179a:	7942                	ld	s2,48(sp)
    8000179c:	79a2                	ld	s3,40(sp)
    8000179e:	7a02                	ld	s4,32(sp)
    800017a0:	6ae2                	ld	s5,24(sp)
    800017a2:	6b42                	ld	s6,16(sp)
    800017a4:	6ba2                	ld	s7,8(sp)
    800017a6:	6c02                	ld	s8,0(sp)
    800017a8:	6161                	add	sp,sp,80
    800017aa:	8082                	ret

00000000800017ac <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800017ac:	c2dd                	beqz	a3,80001852 <copyinstr+0xa6>
{
    800017ae:	715d                	add	sp,sp,-80
    800017b0:	e486                	sd	ra,72(sp)
    800017b2:	e0a2                	sd	s0,64(sp)
    800017b4:	fc26                	sd	s1,56(sp)
    800017b6:	f84a                	sd	s2,48(sp)
    800017b8:	f44e                	sd	s3,40(sp)
    800017ba:	f052                	sd	s4,32(sp)
    800017bc:	ec56                	sd	s5,24(sp)
    800017be:	e85a                	sd	s6,16(sp)
    800017c0:	e45e                	sd	s7,8(sp)
    800017c2:	0880                	add	s0,sp,80
    800017c4:	8a2a                	mv	s4,a0
    800017c6:	8b2e                	mv	s6,a1
    800017c8:	8bb2                	mv	s7,a2
    800017ca:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017cc:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017ce:	6985                	lui	s3,0x1
    800017d0:	a02d                	j	800017fa <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017d2:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017d6:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017d8:	37fd                	addw	a5,a5,-1
    800017da:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017de:	60a6                	ld	ra,72(sp)
    800017e0:	6406                	ld	s0,64(sp)
    800017e2:	74e2                	ld	s1,56(sp)
    800017e4:	7942                	ld	s2,48(sp)
    800017e6:	79a2                	ld	s3,40(sp)
    800017e8:	7a02                	ld	s4,32(sp)
    800017ea:	6ae2                	ld	s5,24(sp)
    800017ec:	6b42                	ld	s6,16(sp)
    800017ee:	6ba2                	ld	s7,8(sp)
    800017f0:	6161                	add	sp,sp,80
    800017f2:	8082                	ret
    srcva = va0 + PGSIZE;
    800017f4:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017f8:	c8a9                	beqz	s1,8000184a <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017fa:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017fe:	85ca                	mv	a1,s2
    80001800:	8552                	mv	a0,s4
    80001802:	00000097          	auipc	ra,0x0
    80001806:	85c080e7          	jalr	-1956(ra) # 8000105e <walkaddr>
    if(pa0 == 0)
    8000180a:	c131                	beqz	a0,8000184e <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    8000180c:	417906b3          	sub	a3,s2,s7
    80001810:	96ce                	add	a3,a3,s3
    80001812:	00d4f363          	bgeu	s1,a3,80001818 <copyinstr+0x6c>
    80001816:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    80001818:	955e                	add	a0,a0,s7
    8000181a:	41250533          	sub	a0,a0,s2
    while(n > 0){
    8000181e:	daf9                	beqz	a3,800017f4 <copyinstr+0x48>
    80001820:	87da                	mv	a5,s6
    80001822:	885a                	mv	a6,s6
      if(*p == '\0'){
    80001824:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001828:	96da                	add	a3,a3,s6
    8000182a:	85be                	mv	a1,a5
      if(*p == '\0'){
    8000182c:	00f60733          	add	a4,a2,a5
    80001830:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fe658f0>
    80001834:	df59                	beqz	a4,800017d2 <copyinstr+0x26>
        *dst = *p;
    80001836:	00e78023          	sb	a4,0(a5)
      dst++;
    8000183a:	0785                	add	a5,a5,1
    while(n > 0){
    8000183c:	fed797e3          	bne	a5,a3,8000182a <copyinstr+0x7e>
    80001840:	14fd                	add	s1,s1,-1
    80001842:	94c2                	add	s1,s1,a6
      --max;
    80001844:	8c8d                	sub	s1,s1,a1
      dst++;
    80001846:	8b3e                	mv	s6,a5
    80001848:	b775                	j	800017f4 <copyinstr+0x48>
    8000184a:	4781                	li	a5,0
    8000184c:	b771                	j	800017d8 <copyinstr+0x2c>
      return -1;
    8000184e:	557d                	li	a0,-1
    80001850:	b779                	j	800017de <copyinstr+0x32>
  int got_null = 0;
    80001852:	4781                	li	a5,0
  if(got_null){
    80001854:	37fd                	addw	a5,a5,-1
    80001856:	0007851b          	sext.w	a0,a5
}
    8000185a:	8082                	ret

000000008000185c <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    8000185c:	715d                	add	sp,sp,-80
    8000185e:	e486                	sd	ra,72(sp)
    80001860:	e0a2                	sd	s0,64(sp)
    80001862:	fc26                	sd	s1,56(sp)
    80001864:	f84a                	sd	s2,48(sp)
    80001866:	f44e                	sd	s3,40(sp)
    80001868:	f052                	sd	s4,32(sp)
    8000186a:	ec56                	sd	s5,24(sp)
    8000186c:	e85a                	sd	s6,16(sp)
    8000186e:	e45e                	sd	s7,8(sp)
    80001870:	0880                	add	s0,sp,80
    80001872:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001874:	00010497          	auipc	s1,0x10
    80001878:	8cc48493          	add	s1,s1,-1844 # 80011140 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000187c:	8ba6                	mv	s7,s1
    8000187e:	00006b17          	auipc	s6,0x6
    80001882:	782b0b13          	add	s6,s6,1922 # 80008000 <etext>
    80001886:	04000937          	lui	s2,0x4000
    8000188a:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000188c:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000188e:	6999                	lui	s3,0x6
    80001890:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001894:	0018ca97          	auipc	s5,0x18c
    80001898:	6aca8a93          	add	s5,s5,1708 # 8018df40 <tickslock>
    char *pa = kalloc();
    8000189c:	fffff097          	auipc	ra,0xfffff
    800018a0:	246080e7          	jalr	582(ra) # 80000ae2 <kalloc>
    800018a4:	862a                	mv	a2,a0
    if(pa == 0)
    800018a6:	c131                	beqz	a0,800018ea <proc_mapstacks+0x8e>
    uint64 va = KSTACK((int) (p - proc));
    800018a8:	417485b3          	sub	a1,s1,s7
    800018ac:	858d                	sra	a1,a1,0x3
    800018ae:	000b3783          	ld	a5,0(s6)
    800018b2:	02f585b3          	mul	a1,a1,a5
    800018b6:	2585                	addw	a1,a1,1
    800018b8:	00d5959b          	sllw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800018bc:	4719                	li	a4,6
    800018be:	6685                	lui	a3,0x1
    800018c0:	40b905b3          	sub	a1,s2,a1
    800018c4:	8552                	mv	a0,s4
    800018c6:	00000097          	auipc	ra,0x0
    800018ca:	87a080e7          	jalr	-1926(ra) # 80001140 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018ce:	94ce                	add	s1,s1,s3
    800018d0:	fd5496e3          	bne	s1,s5,8000189c <proc_mapstacks+0x40>
  }
}
    800018d4:	60a6                	ld	ra,72(sp)
    800018d6:	6406                	ld	s0,64(sp)
    800018d8:	74e2                	ld	s1,56(sp)
    800018da:	7942                	ld	s2,48(sp)
    800018dc:	79a2                	ld	s3,40(sp)
    800018de:	7a02                	ld	s4,32(sp)
    800018e0:	6ae2                	ld	s5,24(sp)
    800018e2:	6b42                	ld	s6,16(sp)
    800018e4:	6ba2                	ld	s7,8(sp)
    800018e6:	6161                	add	sp,sp,80
    800018e8:	8082                	ret
      panic("kalloc");
    800018ea:	00007517          	auipc	a0,0x7
    800018ee:	8e650513          	add	a0,a0,-1818 # 800081d0 <digits+0x190>
    800018f2:	fffff097          	auipc	ra,0xfffff
    800018f6:	c4a080e7          	jalr	-950(ra) # 8000053c <panic>

00000000800018fa <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018fa:	715d                	add	sp,sp,-80
    800018fc:	e486                	sd	ra,72(sp)
    800018fe:	e0a2                	sd	s0,64(sp)
    80001900:	fc26                	sd	s1,56(sp)
    80001902:	f84a                	sd	s2,48(sp)
    80001904:	f44e                	sd	s3,40(sp)
    80001906:	f052                	sd	s4,32(sp)
    80001908:	ec56                	sd	s5,24(sp)
    8000190a:	e85a                	sd	s6,16(sp)
    8000190c:	e45e                	sd	s7,8(sp)
    8000190e:	0880                	add	s0,sp,80
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001910:	00007597          	auipc	a1,0x7
    80001914:	8c858593          	add	a1,a1,-1848 # 800081d8 <digits+0x198>
    80001918:	0000f517          	auipc	a0,0xf
    8000191c:	3f850513          	add	a0,a0,1016 # 80010d10 <pid_lock>
    80001920:	fffff097          	auipc	ra,0xfffff
    80001924:	222080e7          	jalr	546(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001928:	00007597          	auipc	a1,0x7
    8000192c:	8b858593          	add	a1,a1,-1864 # 800081e0 <digits+0x1a0>
    80001930:	0000f517          	auipc	a0,0xf
    80001934:	3f850513          	add	a0,a0,1016 # 80010d28 <wait_lock>
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001940:	00010497          	auipc	s1,0x10
    80001944:	80048493          	add	s1,s1,-2048 # 80011140 <proc>
      initlock(&p->lock, "proc");
    80001948:	00007b97          	auipc	s7,0x7
    8000194c:	8a8b8b93          	add	s7,s7,-1880 # 800081f0 <digits+0x1b0>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001950:	8b26                	mv	s6,s1
    80001952:	00006a97          	auipc	s5,0x6
    80001956:	6aea8a93          	add	s5,s5,1710 # 80008000 <etext>
    8000195a:	04000937          	lui	s2,0x4000
    8000195e:	197d                	add	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001960:	0932                	sll	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001962:	6999                	lui	s3,0x6
    80001964:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001968:	0018ca17          	auipc	s4,0x18c
    8000196c:	5d8a0a13          	add	s4,s4,1496 # 8018df40 <tickslock>
      initlock(&p->lock, "proc");
    80001970:	85de                	mv	a1,s7
    80001972:	8526                	mv	a0,s1
    80001974:	fffff097          	auipc	ra,0xfffff
    80001978:	1ce080e7          	jalr	462(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    8000197c:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001980:	416487b3          	sub	a5,s1,s6
    80001984:	878d                	sra	a5,a5,0x3
    80001986:	000ab703          	ld	a4,0(s5)
    8000198a:	02e787b3          	mul	a5,a5,a4
    8000198e:	2785                	addw	a5,a5,1
    80001990:	00d7979b          	sllw	a5,a5,0xd
    80001994:	40f907b3          	sub	a5,s2,a5
    80001998:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000199a:	94ce                	add	s1,s1,s3
    8000199c:	fd449ae3          	bne	s1,s4,80001970 <procinit+0x76>
  }
}
    800019a0:	60a6                	ld	ra,72(sp)
    800019a2:	6406                	ld	s0,64(sp)
    800019a4:	74e2                	ld	s1,56(sp)
    800019a6:	7942                	ld	s2,48(sp)
    800019a8:	79a2                	ld	s3,40(sp)
    800019aa:	7a02                	ld	s4,32(sp)
    800019ac:	6ae2                	ld	s5,24(sp)
    800019ae:	6b42                	ld	s6,16(sp)
    800019b0:	6ba2                	ld	s7,8(sp)
    800019b2:	6161                	add	sp,sp,80
    800019b4:	8082                	ret

00000000800019b6 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800019b6:	1141                	add	sp,sp,-16
    800019b8:	e422                	sd	s0,8(sp)
    800019ba:	0800                	add	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800019bc:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800019be:	2501                	sext.w	a0,a0
    800019c0:	6422                	ld	s0,8(sp)
    800019c2:	0141                	add	sp,sp,16
    800019c4:	8082                	ret

00000000800019c6 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800019c6:	1141                	add	sp,sp,-16
    800019c8:	e422                	sd	s0,8(sp)
    800019ca:	0800                	add	s0,sp,16
    800019cc:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800019ce:	2781                	sext.w	a5,a5
    800019d0:	079e                	sll	a5,a5,0x7
  return c;
}
    800019d2:	0000f517          	auipc	a0,0xf
    800019d6:	36e50513          	add	a0,a0,878 # 80010d40 <cpus>
    800019da:	953e                	add	a0,a0,a5
    800019dc:	6422                	ld	s0,8(sp)
    800019de:	0141                	add	sp,sp,16
    800019e0:	8082                	ret

00000000800019e2 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019e2:	1101                	add	sp,sp,-32
    800019e4:	ec06                	sd	ra,24(sp)
    800019e6:	e822                	sd	s0,16(sp)
    800019e8:	e426                	sd	s1,8(sp)
    800019ea:	1000                	add	s0,sp,32
  push_off();
    800019ec:	fffff097          	auipc	ra,0xfffff
    800019f0:	19a080e7          	jalr	410(ra) # 80000b86 <push_off>
    800019f4:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019f6:	2781                	sext.w	a5,a5
    800019f8:	079e                	sll	a5,a5,0x7
    800019fa:	0000f717          	auipc	a4,0xf
    800019fe:	31670713          	add	a4,a4,790 # 80010d10 <pid_lock>
    80001a02:	97ba                	add	a5,a5,a4
    80001a04:	7b84                	ld	s1,48(a5)
  pop_off();
    80001a06:	fffff097          	auipc	ra,0xfffff
    80001a0a:	220080e7          	jalr	544(ra) # 80000c26 <pop_off>
  return p;
}
    80001a0e:	8526                	mv	a0,s1
    80001a10:	60e2                	ld	ra,24(sp)
    80001a12:	6442                	ld	s0,16(sp)
    80001a14:	64a2                	ld	s1,8(sp)
    80001a16:	6105                	add	sp,sp,32
    80001a18:	8082                	ret

0000000080001a1a <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001a1a:	1141                	add	sp,sp,-16
    80001a1c:	e406                	sd	ra,8(sp)
    80001a1e:	e022                	sd	s0,0(sp)
    80001a20:	0800                	add	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001a22:	00000097          	auipc	ra,0x0
    80001a26:	fc0080e7          	jalr	-64(ra) # 800019e2 <myproc>
    80001a2a:	fffff097          	auipc	ra,0xfffff
    80001a2e:	25c080e7          	jalr	604(ra) # 80000c86 <release>

  if (first) {
    80001a32:	00007797          	auipc	a5,0x7
    80001a36:	fee7a783          	lw	a5,-18(a5) # 80008a20 <first.1>
    80001a3a:	eb89                	bnez	a5,80001a4c <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a3c:	00001097          	auipc	ra,0x1
    80001a40:	cdc080e7          	jalr	-804(ra) # 80002718 <usertrapret>
}
    80001a44:	60a2                	ld	ra,8(sp)
    80001a46:	6402                	ld	s0,0(sp)
    80001a48:	0141                	add	sp,sp,16
    80001a4a:	8082                	ret
    first = 0;
    80001a4c:	00007797          	auipc	a5,0x7
    80001a50:	fc07aa23          	sw	zero,-44(a5) # 80008a20 <first.1>
    fsinit(ROOTDEV);
    80001a54:	4505                	li	a0,1
    80001a56:	00002097          	auipc	ra,0x2
    80001a5a:	a26080e7          	jalr	-1498(ra) # 8000347c <fsinit>
    80001a5e:	bff9                	j	80001a3c <forkret+0x22>

0000000080001a60 <allocpid>:
{
    80001a60:	1101                	add	sp,sp,-32
    80001a62:	ec06                	sd	ra,24(sp)
    80001a64:	e822                	sd	s0,16(sp)
    80001a66:	e426                	sd	s1,8(sp)
    80001a68:	e04a                	sd	s2,0(sp)
    80001a6a:	1000                	add	s0,sp,32
  acquire(&pid_lock);
    80001a6c:	0000f917          	auipc	s2,0xf
    80001a70:	2a490913          	add	s2,s2,676 # 80010d10 <pid_lock>
    80001a74:	854a                	mv	a0,s2
    80001a76:	fffff097          	auipc	ra,0xfffff
    80001a7a:	15c080e7          	jalr	348(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a7e:	00007797          	auipc	a5,0x7
    80001a82:	fa678793          	add	a5,a5,-90 # 80008a24 <nextpid>
    80001a86:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a88:	0014871b          	addw	a4,s1,1
    80001a8c:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a8e:	854a                	mv	a0,s2
    80001a90:	fffff097          	auipc	ra,0xfffff
    80001a94:	1f6080e7          	jalr	502(ra) # 80000c86 <release>
}
    80001a98:	8526                	mv	a0,s1
    80001a9a:	60e2                	ld	ra,24(sp)
    80001a9c:	6442                	ld	s0,16(sp)
    80001a9e:	64a2                	ld	s1,8(sp)
    80001aa0:	6902                	ld	s2,0(sp)
    80001aa2:	6105                	add	sp,sp,32
    80001aa4:	8082                	ret

0000000080001aa6 <proc_pagetable>:
{
    80001aa6:	1101                	add	sp,sp,-32
    80001aa8:	ec06                	sd	ra,24(sp)
    80001aaa:	e822                	sd	s0,16(sp)
    80001aac:	e426                	sd	s1,8(sp)
    80001aae:	e04a                	sd	s2,0(sp)
    80001ab0:	1000                	add	s0,sp,32
    80001ab2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001ab4:	00000097          	auipc	ra,0x0
    80001ab8:	868080e7          	jalr	-1944(ra) # 8000131c <uvmcreate>
    80001abc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001abe:	c121                	beqz	a0,80001afe <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001ac0:	4729                	li	a4,10
    80001ac2:	00005697          	auipc	a3,0x5
    80001ac6:	53e68693          	add	a3,a3,1342 # 80007000 <_trampoline>
    80001aca:	6605                	lui	a2,0x1
    80001acc:	040005b7          	lui	a1,0x4000
    80001ad0:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001ad2:	05b2                	sll	a1,a1,0xc
    80001ad4:	fffff097          	auipc	ra,0xfffff
    80001ad8:	5cc080e7          	jalr	1484(ra) # 800010a0 <mappages>
    80001adc:	02054863          	bltz	a0,80001b0c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001ae0:	4719                	li	a4,6
    80001ae2:	05893683          	ld	a3,88(s2)
    80001ae6:	6605                	lui	a2,0x1
    80001ae8:	020005b7          	lui	a1,0x2000
    80001aec:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001aee:	05b6                	sll	a1,a1,0xd
    80001af0:	8526                	mv	a0,s1
    80001af2:	fffff097          	auipc	ra,0xfffff
    80001af6:	5ae080e7          	jalr	1454(ra) # 800010a0 <mappages>
    80001afa:	02054163          	bltz	a0,80001b1c <proc_pagetable+0x76>
}
    80001afe:	8526                	mv	a0,s1
    80001b00:	60e2                	ld	ra,24(sp)
    80001b02:	6442                	ld	s0,16(sp)
    80001b04:	64a2                	ld	s1,8(sp)
    80001b06:	6902                	ld	s2,0(sp)
    80001b08:	6105                	add	sp,sp,32
    80001b0a:	8082                	ret
    uvmfree(pagetable, 0);
    80001b0c:	4581                	li	a1,0
    80001b0e:	8526                	mv	a0,s1
    80001b10:	00000097          	auipc	ra,0x0
    80001b14:	a12080e7          	jalr	-1518(ra) # 80001522 <uvmfree>
    return 0;
    80001b18:	4481                	li	s1,0
    80001b1a:	b7d5                	j	80001afe <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b1c:	4681                	li	a3,0
    80001b1e:	4605                	li	a2,1
    80001b20:	040005b7          	lui	a1,0x4000
    80001b24:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b26:	05b2                	sll	a1,a1,0xc
    80001b28:	8526                	mv	a0,s1
    80001b2a:	fffff097          	auipc	ra,0xfffff
    80001b2e:	73c080e7          	jalr	1852(ra) # 80001266 <uvmunmap>
    uvmfree(pagetable, 0);
    80001b32:	4581                	li	a1,0
    80001b34:	8526                	mv	a0,s1
    80001b36:	00000097          	auipc	ra,0x0
    80001b3a:	9ec080e7          	jalr	-1556(ra) # 80001522 <uvmfree>
    return 0;
    80001b3e:	4481                	li	s1,0
    80001b40:	bf7d                	j	80001afe <proc_pagetable+0x58>

0000000080001b42 <proc_freepagetable>:
{
    80001b42:	1101                	add	sp,sp,-32
    80001b44:	ec06                	sd	ra,24(sp)
    80001b46:	e822                	sd	s0,16(sp)
    80001b48:	e426                	sd	s1,8(sp)
    80001b4a:	e04a                	sd	s2,0(sp)
    80001b4c:	1000                	add	s0,sp,32
    80001b4e:	84aa                	mv	s1,a0
    80001b50:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b52:	4681                	li	a3,0
    80001b54:	4605                	li	a2,1
    80001b56:	040005b7          	lui	a1,0x4000
    80001b5a:	15fd                	add	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b5c:	05b2                	sll	a1,a1,0xc
    80001b5e:	fffff097          	auipc	ra,0xfffff
    80001b62:	708080e7          	jalr	1800(ra) # 80001266 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b66:	4681                	li	a3,0
    80001b68:	4605                	li	a2,1
    80001b6a:	020005b7          	lui	a1,0x2000
    80001b6e:	15fd                	add	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b70:	05b6                	sll	a1,a1,0xd
    80001b72:	8526                	mv	a0,s1
    80001b74:	fffff097          	auipc	ra,0xfffff
    80001b78:	6f2080e7          	jalr	1778(ra) # 80001266 <uvmunmap>
  uvmfree(pagetable, sz);
    80001b7c:	85ca                	mv	a1,s2
    80001b7e:	8526                	mv	a0,s1
    80001b80:	00000097          	auipc	ra,0x0
    80001b84:	9a2080e7          	jalr	-1630(ra) # 80001522 <uvmfree>
}
    80001b88:	60e2                	ld	ra,24(sp)
    80001b8a:	6442                	ld	s0,16(sp)
    80001b8c:	64a2                	ld	s1,8(sp)
    80001b8e:	6902                	ld	s2,0(sp)
    80001b90:	6105                	add	sp,sp,32
    80001b92:	8082                	ret

0000000080001b94 <freeproc>:
{
    80001b94:	1101                	add	sp,sp,-32
    80001b96:	ec06                	sd	ra,24(sp)
    80001b98:	e822                	sd	s0,16(sp)
    80001b9a:	e426                	sd	s1,8(sp)
    80001b9c:	1000                	add	s0,sp,32
    80001b9e:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001ba0:	6d28                	ld	a0,88(a0)
    80001ba2:	c509                	beqz	a0,80001bac <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001ba4:	fffff097          	auipc	ra,0xfffff
    80001ba8:	e40080e7          	jalr	-448(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001bac:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001bb0:	68a8                	ld	a0,80(s1)
    80001bb2:	c511                	beqz	a0,80001bbe <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001bb4:	64ac                	ld	a1,72(s1)
    80001bb6:	00000097          	auipc	ra,0x0
    80001bba:	f8c080e7          	jalr	-116(ra) # 80001b42 <proc_freepagetable>
  p->pagetable = 0;
    80001bbe:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001bc2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001bc6:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001bca:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001bce:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001bd2:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001bd6:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001bda:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001bde:	0004ac23          	sw	zero,24(s1)
}
    80001be2:	60e2                	ld	ra,24(sp)
    80001be4:	6442                	ld	s0,16(sp)
    80001be6:	64a2                	ld	s1,8(sp)
    80001be8:	6105                	add	sp,sp,32
    80001bea:	8082                	ret

0000000080001bec <allocproc>:
{
    80001bec:	7179                	add	sp,sp,-48
    80001bee:	f406                	sd	ra,40(sp)
    80001bf0:	f022                	sd	s0,32(sp)
    80001bf2:	ec26                	sd	s1,24(sp)
    80001bf4:	e84a                	sd	s2,16(sp)
    80001bf6:	e44e                	sd	s3,8(sp)
    80001bf8:	1800                	add	s0,sp,48
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bfa:	0000f497          	auipc	s1,0xf
    80001bfe:	54648493          	add	s1,s1,1350 # 80011140 <proc>
    80001c02:	6919                	lui	s2,0x6
    80001c04:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80001c08:	0018c997          	auipc	s3,0x18c
    80001c0c:	33898993          	add	s3,s3,824 # 8018df40 <tickslock>
    acquire(&p->lock);
    80001c10:	8526                	mv	a0,s1
    80001c12:	fffff097          	auipc	ra,0xfffff
    80001c16:	fc0080e7          	jalr	-64(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001c1a:	4c9c                	lw	a5,24(s1)
    80001c1c:	cb99                	beqz	a5,80001c32 <allocproc+0x46>
      release(&p->lock);
    80001c1e:	8526                	mv	a0,s1
    80001c20:	fffff097          	auipc	ra,0xfffff
    80001c24:	066080e7          	jalr	102(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001c28:	94ca                	add	s1,s1,s2
    80001c2a:	ff3493e3          	bne	s1,s3,80001c10 <allocproc+0x24>
  return 0;
    80001c2e:	4481                	li	s1,0
    80001c30:	a889                	j	80001c82 <allocproc+0x96>
  p->pid = allocpid();
    80001c32:	00000097          	auipc	ra,0x0
    80001c36:	e2e080e7          	jalr	-466(ra) # 80001a60 <allocpid>
    80001c3a:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001c3c:	4785                	li	a5,1
    80001c3e:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001c40:	fffff097          	auipc	ra,0xfffff
    80001c44:	ea2080e7          	jalr	-350(ra) # 80000ae2 <kalloc>
    80001c48:	892a                	mv	s2,a0
    80001c4a:	eca8                	sd	a0,88(s1)
    80001c4c:	c139                	beqz	a0,80001c92 <allocproc+0xa6>
  p->pagetable = proc_pagetable(p);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	e56080e7          	jalr	-426(ra) # 80001aa6 <proc_pagetable>
    80001c58:	892a                	mv	s2,a0
    80001c5a:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c5c:	c539                	beqz	a0,80001caa <allocproc+0xbe>
  memset(&p->context, 0, sizeof(p->context));
    80001c5e:	07000613          	li	a2,112
    80001c62:	4581                	li	a1,0
    80001c64:	06048513          	add	a0,s1,96
    80001c68:	fffff097          	auipc	ra,0xfffff
    80001c6c:	066080e7          	jalr	102(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c70:	00000797          	auipc	a5,0x0
    80001c74:	daa78793          	add	a5,a5,-598 # 80001a1a <forkret>
    80001c78:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c7a:	60bc                	ld	a5,64(s1)
    80001c7c:	6705                	lui	a4,0x1
    80001c7e:	97ba                	add	a5,a5,a4
    80001c80:	f4bc                	sd	a5,104(s1)
}
    80001c82:	8526                	mv	a0,s1
    80001c84:	70a2                	ld	ra,40(sp)
    80001c86:	7402                	ld	s0,32(sp)
    80001c88:	64e2                	ld	s1,24(sp)
    80001c8a:	6942                	ld	s2,16(sp)
    80001c8c:	69a2                	ld	s3,8(sp)
    80001c8e:	6145                	add	sp,sp,48
    80001c90:	8082                	ret
    freeproc(p);
    80001c92:	8526                	mv	a0,s1
    80001c94:	00000097          	auipc	ra,0x0
    80001c98:	f00080e7          	jalr	-256(ra) # 80001b94 <freeproc>
    release(&p->lock);
    80001c9c:	8526                	mv	a0,s1
    80001c9e:	fffff097          	auipc	ra,0xfffff
    80001ca2:	fe8080e7          	jalr	-24(ra) # 80000c86 <release>
    return 0;
    80001ca6:	84ca                	mv	s1,s2
    80001ca8:	bfe9                	j	80001c82 <allocproc+0x96>
    freeproc(p);
    80001caa:	8526                	mv	a0,s1
    80001cac:	00000097          	auipc	ra,0x0
    80001cb0:	ee8080e7          	jalr	-280(ra) # 80001b94 <freeproc>
    release(&p->lock);
    80001cb4:	8526                	mv	a0,s1
    80001cb6:	fffff097          	auipc	ra,0xfffff
    80001cba:	fd0080e7          	jalr	-48(ra) # 80000c86 <release>
    return 0;
    80001cbe:	84ca                	mv	s1,s2
    80001cc0:	b7c9                	j	80001c82 <allocproc+0x96>

0000000080001cc2 <userinit>:
{
    80001cc2:	1101                	add	sp,sp,-32
    80001cc4:	ec06                	sd	ra,24(sp)
    80001cc6:	e822                	sd	s0,16(sp)
    80001cc8:	e426                	sd	s1,8(sp)
    80001cca:	1000                	add	s0,sp,32
  p = allocproc();
    80001ccc:	00000097          	auipc	ra,0x0
    80001cd0:	f20080e7          	jalr	-224(ra) # 80001bec <allocproc>
    80001cd4:	84aa                	mv	s1,a0
  initproc = p;
    80001cd6:	00007797          	auipc	a5,0x7
    80001cda:	dca7b123          	sd	a0,-574(a5) # 80008a98 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cde:	03400613          	li	a2,52
    80001ce2:	00007597          	auipc	a1,0x7
    80001ce6:	d4e58593          	add	a1,a1,-690 # 80008a30 <initcode>
    80001cea:	6928                	ld	a0,80(a0)
    80001cec:	fffff097          	auipc	ra,0xfffff
    80001cf0:	65e080e7          	jalr	1630(ra) # 8000134a <uvmfirst>
  p->sz = PGSIZE;
    80001cf4:	6785                	lui	a5,0x1
    80001cf6:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cf8:	6cb8                	ld	a4,88(s1)
    80001cfa:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cfe:	6cb8                	ld	a4,88(s1)
    80001d00:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001d02:	4641                	li	a2,16
    80001d04:	00006597          	auipc	a1,0x6
    80001d08:	4f458593          	add	a1,a1,1268 # 800081f8 <digits+0x1b8>
    80001d0c:	15848513          	add	a0,s1,344
    80001d10:	fffff097          	auipc	ra,0xfffff
    80001d14:	106080e7          	jalr	262(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001d18:	00006517          	auipc	a0,0x6
    80001d1c:	4f050513          	add	a0,a0,1264 # 80008208 <digits+0x1c8>
    80001d20:	00002097          	auipc	ra,0x2
    80001d24:	17a080e7          	jalr	378(ra) # 80003e9a <namei>
    80001d28:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001d2c:	478d                	li	a5,3
    80001d2e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001d30:	8526                	mv	a0,s1
    80001d32:	fffff097          	auipc	ra,0xfffff
    80001d36:	f54080e7          	jalr	-172(ra) # 80000c86 <release>
}
    80001d3a:	60e2                	ld	ra,24(sp)
    80001d3c:	6442                	ld	s0,16(sp)
    80001d3e:	64a2                	ld	s1,8(sp)
    80001d40:	6105                	add	sp,sp,32
    80001d42:	8082                	ret

0000000080001d44 <track_heap>:
  for (int i = 0; i < MAXHEAP; i++) {
    80001d44:	17050793          	add	a5,a0,368
    80001d48:	6719                	lui	a4,0x6
    80001d4a:	f3070713          	add	a4,a4,-208 # 5f30 <_entry-0x7fffa0d0>
    80001d4e:	953a                	add	a0,a0,a4
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d50:	56fd                	li	a3,-1
  for (int i = 0; i < MAXHEAP; i++) {
    80001d52:	6805                	lui	a6,0x1
    80001d54:	a029                	j	80001d5e <track_heap+0x1a>
    80001d56:	07e1                	add	a5,a5,24 # 1018 <_entry-0x7fffefe8>
    80001d58:	95c2                	add	a1,a1,a6
    80001d5a:	00a78c63          	beq	a5,a0,80001d72 <track_heap+0x2e>
    if (p->heap_tracker[i].addr == 0xFFFFFFFFFFFFFFFF) {
    80001d5e:	6398                	ld	a4,0(a5)
    80001d60:	fed71be3          	bne	a4,a3,80001d56 <track_heap+0x12>
      p->heap_tracker[i].addr           = start + (i*PGSIZE);
    80001d64:	e38c                	sd	a1,0(a5)
      p->heap_tracker[i].loaded         = 0;   
    80001d66:	00078823          	sb	zero,16(a5)
      p->heap_tracker[i].startblock     = -1;
    80001d6a:	cbd4                	sw	a3,20(a5)
      npages--;
    80001d6c:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
      if (npages == 0) return;
    80001d6e:	f665                	bnez	a2,80001d56 <track_heap+0x12>
    80001d70:	8082                	ret
void track_heap(struct proc* p, uint64 start, int npages) {
    80001d72:	1141                	add	sp,sp,-16
    80001d74:	e406                	sd	ra,8(sp)
    80001d76:	e022                	sd	s0,0(sp)
    80001d78:	0800                	add	s0,sp,16
  panic("Error: No more process heap pages allowed.\n");
    80001d7a:	00006517          	auipc	a0,0x6
    80001d7e:	49650513          	add	a0,a0,1174 # 80008210 <digits+0x1d0>
    80001d82:	ffffe097          	auipc	ra,0xffffe
    80001d86:	7ba080e7          	jalr	1978(ra) # 8000053c <panic>

0000000080001d8a <growproc>:
{
    80001d8a:	1101                	add	sp,sp,-32
    80001d8c:	ec06                	sd	ra,24(sp)
    80001d8e:	e822                	sd	s0,16(sp)
    80001d90:	e426                	sd	s1,8(sp)
    80001d92:	e04a                	sd	s2,0(sp)
    80001d94:	1000                	add	s0,sp,32
    80001d96:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d98:	00000097          	auipc	ra,0x0
    80001d9c:	c4a080e7          	jalr	-950(ra) # 800019e2 <myproc>
    80001da0:	84aa                	mv	s1,a0
  n = PGROUNDUP(n);
    80001da2:	6605                	lui	a2,0x1
    80001da4:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001da6:	0126063b          	addw	a2,a2,s2
    80001daa:	77fd                	lui	a5,0xfffff
    80001dac:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001dae:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001db0:	00c04c63          	bgtz	a2,80001dc8 <growproc+0x3e>
  } else if(n < 0){
    80001db4:	02064563          	bltz	a2,80001dde <growproc+0x54>
  p->sz = sz;
    80001db8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dba:	4501                	li	a0,0
}
    80001dbc:	60e2                	ld	ra,24(sp)
    80001dbe:	6442                	ld	s0,16(sp)
    80001dc0:	64a2                	ld	s1,8(sp)
    80001dc2:	6902                	ld	s2,0(sp)
    80001dc4:	6105                	add	sp,sp,32
    80001dc6:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001dc8:	4691                	li	a3,4
    80001dca:	962e                	add	a2,a2,a1
    80001dcc:	6928                	ld	a0,80(a0)
    80001dce:	fffff097          	auipc	ra,0xfffff
    80001dd2:	636080e7          	jalr	1590(ra) # 80001404 <uvmalloc>
    80001dd6:	85aa                	mv	a1,a0
    80001dd8:	f165                	bnez	a0,80001db8 <growproc+0x2e>
      return -1;
    80001dda:	557d                	li	a0,-1
    80001ddc:	b7c5                	j	80001dbc <growproc+0x32>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001dde:	962e                	add	a2,a2,a1
    80001de0:	6928                	ld	a0,80(a0)
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	5da080e7          	jalr	1498(ra) # 800013bc <uvmdealloc>
    80001dea:	85aa                	mv	a1,a0
    80001dec:	b7f1                	j	80001db8 <growproc+0x2e>

0000000080001dee <fork>:
{
    80001dee:	7139                	add	sp,sp,-64
    80001df0:	fc06                	sd	ra,56(sp)
    80001df2:	f822                	sd	s0,48(sp)
    80001df4:	f426                	sd	s1,40(sp)
    80001df6:	f04a                	sd	s2,32(sp)
    80001df8:	ec4e                	sd	s3,24(sp)
    80001dfa:	e852                	sd	s4,16(sp)
    80001dfc:	e456                	sd	s5,8(sp)
    80001dfe:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e00:	00000097          	auipc	ra,0x0
    80001e04:	be2080e7          	jalr	-1054(ra) # 800019e2 <myproc>
    80001e08:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e0a:	00000097          	auipc	ra,0x0
    80001e0e:	de2080e7          	jalr	-542(ra) # 80001bec <allocproc>
    80001e12:	12050063          	beqz	a0,80001f32 <fork+0x144>
    80001e16:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e18:	048ab603          	ld	a2,72(s5)
    80001e1c:	692c                	ld	a1,80(a0)
    80001e1e:	050ab503          	ld	a0,80(s5)
    80001e22:	fffff097          	auipc	ra,0xfffff
    80001e26:	73a080e7          	jalr	1850(ra) # 8000155c <uvmcopy>
    80001e2a:	04054863          	bltz	a0,80001e7a <fork+0x8c>
  np->sz = p->sz;
    80001e2e:	048ab783          	ld	a5,72(s5)
    80001e32:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e36:	058ab683          	ld	a3,88(s5)
    80001e3a:	87b6                	mv	a5,a3
    80001e3c:	0589b703          	ld	a4,88(s3)
    80001e40:	12068693          	add	a3,a3,288
    80001e44:	0007b803          	ld	a6,0(a5) # fffffffffffff000 <end+0xffffffff7fe658f0>
    80001e48:	6788                	ld	a0,8(a5)
    80001e4a:	6b8c                	ld	a1,16(a5)
    80001e4c:	6f90                	ld	a2,24(a5)
    80001e4e:	01073023          	sd	a6,0(a4)
    80001e52:	e708                	sd	a0,8(a4)
    80001e54:	eb0c                	sd	a1,16(a4)
    80001e56:	ef10                	sd	a2,24(a4)
    80001e58:	02078793          	add	a5,a5,32
    80001e5c:	02070713          	add	a4,a4,32
    80001e60:	fed792e3          	bne	a5,a3,80001e44 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e64:	0589b783          	ld	a5,88(s3)
    80001e68:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e6c:	0d0a8493          	add	s1,s5,208
    80001e70:	0d098913          	add	s2,s3,208
    80001e74:	150a8a13          	add	s4,s5,336
    80001e78:	a00d                	j	80001e9a <fork+0xac>
    freeproc(np);
    80001e7a:	854e                	mv	a0,s3
    80001e7c:	00000097          	auipc	ra,0x0
    80001e80:	d18080e7          	jalr	-744(ra) # 80001b94 <freeproc>
    release(&np->lock);
    80001e84:	854e                	mv	a0,s3
    80001e86:	fffff097          	auipc	ra,0xfffff
    80001e8a:	e00080e7          	jalr	-512(ra) # 80000c86 <release>
    return -1;
    80001e8e:	597d                	li	s2,-1
    80001e90:	a079                	j	80001f1e <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001e92:	04a1                	add	s1,s1,8
    80001e94:	0921                	add	s2,s2,8
    80001e96:	01448b63          	beq	s1,s4,80001eac <fork+0xbe>
    if(p->ofile[i])
    80001e9a:	6088                	ld	a0,0(s1)
    80001e9c:	d97d                	beqz	a0,80001e92 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e9e:	00002097          	auipc	ra,0x2
    80001ea2:	66e080e7          	jalr	1646(ra) # 8000450c <filedup>
    80001ea6:	00a93023          	sd	a0,0(s2)
    80001eaa:	b7e5                	j	80001e92 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001eac:	150ab503          	ld	a0,336(s5)
    80001eb0:	00002097          	auipc	ra,0x2
    80001eb4:	806080e7          	jalr	-2042(ra) # 800036b6 <idup>
    80001eb8:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ebc:	4641                	li	a2,16
    80001ebe:	158a8593          	add	a1,s5,344
    80001ec2:	15898513          	add	a0,s3,344
    80001ec6:	fffff097          	auipc	ra,0xfffff
    80001eca:	f50080e7          	jalr	-176(ra) # 80000e16 <safestrcpy>
  np->ondemand = p->ondemand;
    80001ece:	168ac783          	lbu	a5,360(s5)
    80001ed2:	16f98423          	sb	a5,360(s3)
  pid = np->pid;
    80001ed6:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001eda:	854e                	mv	a0,s3
    80001edc:	fffff097          	auipc	ra,0xfffff
    80001ee0:	daa080e7          	jalr	-598(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001ee4:	0000f497          	auipc	s1,0xf
    80001ee8:	e4448493          	add	s1,s1,-444 # 80010d28 <wait_lock>
    80001eec:	8526                	mv	a0,s1
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	ce4080e7          	jalr	-796(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001ef6:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001efa:	8526                	mv	a0,s1
    80001efc:	fffff097          	auipc	ra,0xfffff
    80001f00:	d8a080e7          	jalr	-630(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f04:	854e                	mv	a0,s3
    80001f06:	fffff097          	auipc	ra,0xfffff
    80001f0a:	ccc080e7          	jalr	-820(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001f0e:	478d                	li	a5,3
    80001f10:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f14:	854e                	mv	a0,s3
    80001f16:	fffff097          	auipc	ra,0xfffff
    80001f1a:	d70080e7          	jalr	-656(ra) # 80000c86 <release>
}
    80001f1e:	854a                	mv	a0,s2
    80001f20:	70e2                	ld	ra,56(sp)
    80001f22:	7442                	ld	s0,48(sp)
    80001f24:	74a2                	ld	s1,40(sp)
    80001f26:	7902                	ld	s2,32(sp)
    80001f28:	69e2                	ld	s3,24(sp)
    80001f2a:	6a42                	ld	s4,16(sp)
    80001f2c:	6aa2                	ld	s5,8(sp)
    80001f2e:	6121                	add	sp,sp,64
    80001f30:	8082                	ret
    return -1;
    80001f32:	597d                	li	s2,-1
    80001f34:	b7ed                	j	80001f1e <fork+0x130>

0000000080001f36 <scheduler>:
{
    80001f36:	715d                	add	sp,sp,-80
    80001f38:	e486                	sd	ra,72(sp)
    80001f3a:	e0a2                	sd	s0,64(sp)
    80001f3c:	fc26                	sd	s1,56(sp)
    80001f3e:	f84a                	sd	s2,48(sp)
    80001f40:	f44e                	sd	s3,40(sp)
    80001f42:	f052                	sd	s4,32(sp)
    80001f44:	ec56                	sd	s5,24(sp)
    80001f46:	e85a                	sd	s6,16(sp)
    80001f48:	e45e                	sd	s7,8(sp)
    80001f4a:	0880                	add	s0,sp,80
    80001f4c:	8792                	mv	a5,tp
  int id = r_tp();
    80001f4e:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f50:	00779b13          	sll	s6,a5,0x7
    80001f54:	0000f717          	auipc	a4,0xf
    80001f58:	dbc70713          	add	a4,a4,-580 # 80010d10 <pid_lock>
    80001f5c:	975a                	add	a4,a4,s6
    80001f5e:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f62:	0000f717          	auipc	a4,0xf
    80001f66:	de670713          	add	a4,a4,-538 # 80010d48 <cpus+0x8>
    80001f6a:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f6c:	4b91                	li	s7,4
        c->proc = p;
    80001f6e:	079e                	sll	a5,a5,0x7
    80001f70:	0000fa97          	auipc	s5,0xf
    80001f74:	da0a8a93          	add	s5,s5,-608 # 80010d10 <pid_lock>
    80001f78:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f7a:	6999                	lui	s3,0x6
    80001f7c:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001f80:	0018ca17          	auipc	s4,0x18c
    80001f84:	fc0a0a13          	add	s4,s4,-64 # 8018df40 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f88:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001f8c:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001f90:	10079073          	csrw	sstatus,a5
    80001f94:	0000f497          	auipc	s1,0xf
    80001f98:	1ac48493          	add	s1,s1,428 # 80011140 <proc>
      if(p->state == RUNNABLE) {
    80001f9c:	490d                	li	s2,3
    80001f9e:	a809                	j	80001fb0 <scheduler+0x7a>
      release(&p->lock);
    80001fa0:	8526                	mv	a0,s1
    80001fa2:	fffff097          	auipc	ra,0xfffff
    80001fa6:	ce4080e7          	jalr	-796(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001faa:	94ce                	add	s1,s1,s3
    80001fac:	fd448ee3          	beq	s1,s4,80001f88 <scheduler+0x52>
      acquire(&p->lock);
    80001fb0:	8526                	mv	a0,s1
    80001fb2:	fffff097          	auipc	ra,0xfffff
    80001fb6:	c20080e7          	jalr	-992(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001fba:	4c9c                	lw	a5,24(s1)
    80001fbc:	ff2792e3          	bne	a5,s2,80001fa0 <scheduler+0x6a>
        p->state = RUNNING;
    80001fc0:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001fc4:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001fc8:	06048593          	add	a1,s1,96
    80001fcc:	855a                	mv	a0,s6
    80001fce:	00000097          	auipc	ra,0x0
    80001fd2:	6a0080e7          	jalr	1696(ra) # 8000266e <swtch>
        c->proc = 0;
    80001fd6:	020ab823          	sd	zero,48(s5)
    80001fda:	b7d9                	j	80001fa0 <scheduler+0x6a>

0000000080001fdc <sched>:
{
    80001fdc:	7179                	add	sp,sp,-48
    80001fde:	f406                	sd	ra,40(sp)
    80001fe0:	f022                	sd	s0,32(sp)
    80001fe2:	ec26                	sd	s1,24(sp)
    80001fe4:	e84a                	sd	s2,16(sp)
    80001fe6:	e44e                	sd	s3,8(sp)
    80001fe8:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001fea:	00000097          	auipc	ra,0x0
    80001fee:	9f8080e7          	jalr	-1544(ra) # 800019e2 <myproc>
    80001ff2:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001ff4:	fffff097          	auipc	ra,0xfffff
    80001ff8:	b64080e7          	jalr	-1180(ra) # 80000b58 <holding>
    80001ffc:	c93d                	beqz	a0,80002072 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ffe:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002000:	2781                	sext.w	a5,a5
    80002002:	079e                	sll	a5,a5,0x7
    80002004:	0000f717          	auipc	a4,0xf
    80002008:	d0c70713          	add	a4,a4,-756 # 80010d10 <pid_lock>
    8000200c:	97ba                	add	a5,a5,a4
    8000200e:	0a87a703          	lw	a4,168(a5)
    80002012:	4785                	li	a5,1
    80002014:	06f71763          	bne	a4,a5,80002082 <sched+0xa6>
  if(p->state == RUNNING)
    80002018:	4c98                	lw	a4,24(s1)
    8000201a:	4791                	li	a5,4
    8000201c:	06f70b63          	beq	a4,a5,80002092 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002020:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002024:	8b89                	and	a5,a5,2
  if(intr_get())
    80002026:	efb5                	bnez	a5,800020a2 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002028:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000202a:	0000f917          	auipc	s2,0xf
    8000202e:	ce690913          	add	s2,s2,-794 # 80010d10 <pid_lock>
    80002032:	2781                	sext.w	a5,a5
    80002034:	079e                	sll	a5,a5,0x7
    80002036:	97ca                	add	a5,a5,s2
    80002038:	0ac7a983          	lw	s3,172(a5)
    8000203c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000203e:	2781                	sext.w	a5,a5
    80002040:	079e                	sll	a5,a5,0x7
    80002042:	0000f597          	auipc	a1,0xf
    80002046:	d0658593          	add	a1,a1,-762 # 80010d48 <cpus+0x8>
    8000204a:	95be                	add	a1,a1,a5
    8000204c:	06048513          	add	a0,s1,96
    80002050:	00000097          	auipc	ra,0x0
    80002054:	61e080e7          	jalr	1566(ra) # 8000266e <swtch>
    80002058:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000205a:	2781                	sext.w	a5,a5
    8000205c:	079e                	sll	a5,a5,0x7
    8000205e:	993e                	add	s2,s2,a5
    80002060:	0b392623          	sw	s3,172(s2)
}
    80002064:	70a2                	ld	ra,40(sp)
    80002066:	7402                	ld	s0,32(sp)
    80002068:	64e2                	ld	s1,24(sp)
    8000206a:	6942                	ld	s2,16(sp)
    8000206c:	69a2                	ld	s3,8(sp)
    8000206e:	6145                	add	sp,sp,48
    80002070:	8082                	ret
    panic("sched p->lock");
    80002072:	00006517          	auipc	a0,0x6
    80002076:	1ce50513          	add	a0,a0,462 # 80008240 <digits+0x200>
    8000207a:	ffffe097          	auipc	ra,0xffffe
    8000207e:	4c2080e7          	jalr	1218(ra) # 8000053c <panic>
    panic("sched locks");
    80002082:	00006517          	auipc	a0,0x6
    80002086:	1ce50513          	add	a0,a0,462 # 80008250 <digits+0x210>
    8000208a:	ffffe097          	auipc	ra,0xffffe
    8000208e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>
    panic("sched running");
    80002092:	00006517          	auipc	a0,0x6
    80002096:	1ce50513          	add	a0,a0,462 # 80008260 <digits+0x220>
    8000209a:	ffffe097          	auipc	ra,0xffffe
    8000209e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>
    panic("sched interruptible");
    800020a2:	00006517          	auipc	a0,0x6
    800020a6:	1ce50513          	add	a0,a0,462 # 80008270 <digits+0x230>
    800020aa:	ffffe097          	auipc	ra,0xffffe
    800020ae:	492080e7          	jalr	1170(ra) # 8000053c <panic>

00000000800020b2 <yield>:
{
    800020b2:	1101                	add	sp,sp,-32
    800020b4:	ec06                	sd	ra,24(sp)
    800020b6:	e822                	sd	s0,16(sp)
    800020b8:	e426                	sd	s1,8(sp)
    800020ba:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020bc:	00000097          	auipc	ra,0x0
    800020c0:	926080e7          	jalr	-1754(ra) # 800019e2 <myproc>
    800020c4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020c6:	fffff097          	auipc	ra,0xfffff
    800020ca:	b0c080e7          	jalr	-1268(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020ce:	478d                	li	a5,3
    800020d0:	cc9c                	sw	a5,24(s1)
  sched();
    800020d2:	00000097          	auipc	ra,0x0
    800020d6:	f0a080e7          	jalr	-246(ra) # 80001fdc <sched>
  release(&p->lock);
    800020da:	8526                	mv	a0,s1
    800020dc:	fffff097          	auipc	ra,0xfffff
    800020e0:	baa080e7          	jalr	-1110(ra) # 80000c86 <release>
}
    800020e4:	60e2                	ld	ra,24(sp)
    800020e6:	6442                	ld	s0,16(sp)
    800020e8:	64a2                	ld	s1,8(sp)
    800020ea:	6105                	add	sp,sp,32
    800020ec:	8082                	ret

00000000800020ee <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800020ee:	7179                	add	sp,sp,-48
    800020f0:	f406                	sd	ra,40(sp)
    800020f2:	f022                	sd	s0,32(sp)
    800020f4:	ec26                	sd	s1,24(sp)
    800020f6:	e84a                	sd	s2,16(sp)
    800020f8:	e44e                	sd	s3,8(sp)
    800020fa:	1800                	add	s0,sp,48
    800020fc:	89aa                	mv	s3,a0
    800020fe:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002100:	00000097          	auipc	ra,0x0
    80002104:	8e2080e7          	jalr	-1822(ra) # 800019e2 <myproc>
    80002108:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000210a:	fffff097          	auipc	ra,0xfffff
    8000210e:	ac8080e7          	jalr	-1336(ra) # 80000bd2 <acquire>
  release(lk);
    80002112:	854a                	mv	a0,s2
    80002114:	fffff097          	auipc	ra,0xfffff
    80002118:	b72080e7          	jalr	-1166(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000211c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002120:	4789                	li	a5,2
    80002122:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    80002124:	00000097          	auipc	ra,0x0
    80002128:	eb8080e7          	jalr	-328(ra) # 80001fdc <sched>

  // Tidy up.
  p->chan = 0;
    8000212c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002130:	8526                	mv	a0,s1
    80002132:	fffff097          	auipc	ra,0xfffff
    80002136:	b54080e7          	jalr	-1196(ra) # 80000c86 <release>
  acquire(lk);
    8000213a:	854a                	mv	a0,s2
    8000213c:	fffff097          	auipc	ra,0xfffff
    80002140:	a96080e7          	jalr	-1386(ra) # 80000bd2 <acquire>
}
    80002144:	70a2                	ld	ra,40(sp)
    80002146:	7402                	ld	s0,32(sp)
    80002148:	64e2                	ld	s1,24(sp)
    8000214a:	6942                	ld	s2,16(sp)
    8000214c:	69a2                	ld	s3,8(sp)
    8000214e:	6145                	add	sp,sp,48
    80002150:	8082                	ret

0000000080002152 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002152:	7139                	add	sp,sp,-64
    80002154:	fc06                	sd	ra,56(sp)
    80002156:	f822                	sd	s0,48(sp)
    80002158:	f426                	sd	s1,40(sp)
    8000215a:	f04a                	sd	s2,32(sp)
    8000215c:	ec4e                	sd	s3,24(sp)
    8000215e:	e852                	sd	s4,16(sp)
    80002160:	e456                	sd	s5,8(sp)
    80002162:	e05a                	sd	s6,0(sp)
    80002164:	0080                	add	s0,sp,64
    80002166:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80002168:	0000f497          	auipc	s1,0xf
    8000216c:	fd848493          	add	s1,s1,-40 # 80011140 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002170:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002172:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002174:	6919                	lui	s2,0x6
    80002176:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    8000217a:	0018c997          	auipc	s3,0x18c
    8000217e:	dc698993          	add	s3,s3,-570 # 8018df40 <tickslock>
    80002182:	a809                	j	80002194 <wakeup+0x42>
      }
      release(&p->lock);
    80002184:	8526                	mv	a0,s1
    80002186:	fffff097          	auipc	ra,0xfffff
    8000218a:	b00080e7          	jalr	-1280(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000218e:	94ca                	add	s1,s1,s2
    80002190:	03348663          	beq	s1,s3,800021bc <wakeup+0x6a>
    if(p != myproc()){
    80002194:	00000097          	auipc	ra,0x0
    80002198:	84e080e7          	jalr	-1970(ra) # 800019e2 <myproc>
    8000219c:	fea489e3          	beq	s1,a0,8000218e <wakeup+0x3c>
      acquire(&p->lock);
    800021a0:	8526                	mv	a0,s1
    800021a2:	fffff097          	auipc	ra,0xfffff
    800021a6:	a30080e7          	jalr	-1488(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021aa:	4c9c                	lw	a5,24(s1)
    800021ac:	fd479ce3          	bne	a5,s4,80002184 <wakeup+0x32>
    800021b0:	709c                	ld	a5,32(s1)
    800021b2:	fd5799e3          	bne	a5,s5,80002184 <wakeup+0x32>
        p->state = RUNNABLE;
    800021b6:	0164ac23          	sw	s6,24(s1)
    800021ba:	b7e9                	j	80002184 <wakeup+0x32>
    }
  }
}
    800021bc:	70e2                	ld	ra,56(sp)
    800021be:	7442                	ld	s0,48(sp)
    800021c0:	74a2                	ld	s1,40(sp)
    800021c2:	7902                	ld	s2,32(sp)
    800021c4:	69e2                	ld	s3,24(sp)
    800021c6:	6a42                	ld	s4,16(sp)
    800021c8:	6aa2                	ld	s5,8(sp)
    800021ca:	6b02                	ld	s6,0(sp)
    800021cc:	6121                	add	sp,sp,64
    800021ce:	8082                	ret

00000000800021d0 <reparent>:
{
    800021d0:	7139                	add	sp,sp,-64
    800021d2:	fc06                	sd	ra,56(sp)
    800021d4:	f822                	sd	s0,48(sp)
    800021d6:	f426                	sd	s1,40(sp)
    800021d8:	f04a                	sd	s2,32(sp)
    800021da:	ec4e                	sd	s3,24(sp)
    800021dc:	e852                	sd	s4,16(sp)
    800021de:	e456                	sd	s5,8(sp)
    800021e0:	0080                	add	s0,sp,64
    800021e2:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021e4:	0000f497          	auipc	s1,0xf
    800021e8:	f5c48493          	add	s1,s1,-164 # 80011140 <proc>
      pp->parent = initproc;
    800021ec:	00007a97          	auipc	s5,0x7
    800021f0:	8aca8a93          	add	s5,s5,-1876 # 80008a98 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f4:	6919                	lui	s2,0x6
    800021f6:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    800021fa:	0018ca17          	auipc	s4,0x18c
    800021fe:	d46a0a13          	add	s4,s4,-698 # 8018df40 <tickslock>
    80002202:	a021                	j	8000220a <reparent+0x3a>
    80002204:	94ca                	add	s1,s1,s2
    80002206:	01448d63          	beq	s1,s4,80002220 <reparent+0x50>
    if(pp->parent == p){
    8000220a:	7c9c                	ld	a5,56(s1)
    8000220c:	ff379ce3          	bne	a5,s3,80002204 <reparent+0x34>
      pp->parent = initproc;
    80002210:	000ab503          	ld	a0,0(s5)
    80002214:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002216:	00000097          	auipc	ra,0x0
    8000221a:	f3c080e7          	jalr	-196(ra) # 80002152 <wakeup>
    8000221e:	b7dd                	j	80002204 <reparent+0x34>
}
    80002220:	70e2                	ld	ra,56(sp)
    80002222:	7442                	ld	s0,48(sp)
    80002224:	74a2                	ld	s1,40(sp)
    80002226:	7902                	ld	s2,32(sp)
    80002228:	69e2                	ld	s3,24(sp)
    8000222a:	6a42                	ld	s4,16(sp)
    8000222c:	6aa2                	ld	s5,8(sp)
    8000222e:	6121                	add	sp,sp,64
    80002230:	8082                	ret

0000000080002232 <exit>:
{
    80002232:	7179                	add	sp,sp,-48
    80002234:	f406                	sd	ra,40(sp)
    80002236:	f022                	sd	s0,32(sp)
    80002238:	ec26                	sd	s1,24(sp)
    8000223a:	e84a                	sd	s2,16(sp)
    8000223c:	e44e                	sd	s3,8(sp)
    8000223e:	e052                	sd	s4,0(sp)
    80002240:	1800                	add	s0,sp,48
    80002242:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002244:	fffff097          	auipc	ra,0xfffff
    80002248:	79e080e7          	jalr	1950(ra) # 800019e2 <myproc>
    8000224c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000224e:	00007797          	auipc	a5,0x7
    80002252:	84a7b783          	ld	a5,-1974(a5) # 80008a98 <initproc>
    80002256:	0d050493          	add	s1,a0,208
    8000225a:	15050913          	add	s2,a0,336
    8000225e:	02a79363          	bne	a5,a0,80002284 <exit+0x52>
    panic("init exiting");
    80002262:	00006517          	auipc	a0,0x6
    80002266:	02650513          	add	a0,a0,38 # 80008288 <digits+0x248>
    8000226a:	ffffe097          	auipc	ra,0xffffe
    8000226e:	2d2080e7          	jalr	722(ra) # 8000053c <panic>
      fileclose(f);
    80002272:	00002097          	auipc	ra,0x2
    80002276:	2ec080e7          	jalr	748(ra) # 8000455e <fileclose>
      p->ofile[fd] = 0;
    8000227a:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    8000227e:	04a1                	add	s1,s1,8
    80002280:	01248563          	beq	s1,s2,8000228a <exit+0x58>
    if(p->ofile[fd]){
    80002284:	6088                	ld	a0,0(s1)
    80002286:	f575                	bnez	a0,80002272 <exit+0x40>
    80002288:	bfdd                	j	8000227e <exit+0x4c>
  begin_op();
    8000228a:	00002097          	auipc	ra,0x2
    8000228e:	e10080e7          	jalr	-496(ra) # 8000409a <begin_op>
  iput(p->cwd);
    80002292:	1509b503          	ld	a0,336(s3)
    80002296:	00001097          	auipc	ra,0x1
    8000229a:	618080e7          	jalr	1560(ra) # 800038ae <iput>
  end_op();
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	e76080e7          	jalr	-394(ra) # 80004114 <end_op>
  p->cwd = 0;
    800022a6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022aa:	0000f497          	auipc	s1,0xf
    800022ae:	a7e48493          	add	s1,s1,-1410 # 80010d28 <wait_lock>
    800022b2:	8526                	mv	a0,s1
    800022b4:	fffff097          	auipc	ra,0xfffff
    800022b8:	91e080e7          	jalr	-1762(ra) # 80000bd2 <acquire>
  reparent(p);
    800022bc:	854e                	mv	a0,s3
    800022be:	00000097          	auipc	ra,0x0
    800022c2:	f12080e7          	jalr	-238(ra) # 800021d0 <reparent>
  wakeup(p->parent);
    800022c6:	0389b503          	ld	a0,56(s3)
    800022ca:	00000097          	auipc	ra,0x0
    800022ce:	e88080e7          	jalr	-376(ra) # 80002152 <wakeup>
  acquire(&p->lock);
    800022d2:	854e                	mv	a0,s3
    800022d4:	fffff097          	auipc	ra,0xfffff
    800022d8:	8fe080e7          	jalr	-1794(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022dc:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022e0:	4795                	li	a5,5
    800022e2:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022e6:	8526                	mv	a0,s1
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	99e080e7          	jalr	-1634(ra) # 80000c86 <release>
  sched();
    800022f0:	00000097          	auipc	ra,0x0
    800022f4:	cec080e7          	jalr	-788(ra) # 80001fdc <sched>
  panic("zombie exit");
    800022f8:	00006517          	auipc	a0,0x6
    800022fc:	fa050513          	add	a0,a0,-96 # 80008298 <digits+0x258>
    80002300:	ffffe097          	auipc	ra,0xffffe
    80002304:	23c080e7          	jalr	572(ra) # 8000053c <panic>

0000000080002308 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002308:	7179                	add	sp,sp,-48
    8000230a:	f406                	sd	ra,40(sp)
    8000230c:	f022                	sd	s0,32(sp)
    8000230e:	ec26                	sd	s1,24(sp)
    80002310:	e84a                	sd	s2,16(sp)
    80002312:	e44e                	sd	s3,8(sp)
    80002314:	e052                	sd	s4,0(sp)
    80002316:	1800                	add	s0,sp,48
    80002318:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000231a:	0000f497          	auipc	s1,0xf
    8000231e:	e2648493          	add	s1,s1,-474 # 80011140 <proc>
    80002322:	6999                	lui	s3,0x6
    80002324:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80002328:	0018ca17          	auipc	s4,0x18c
    8000232c:	c18a0a13          	add	s4,s4,-1000 # 8018df40 <tickslock>
    acquire(&p->lock);
    80002330:	8526                	mv	a0,s1
    80002332:	fffff097          	auipc	ra,0xfffff
    80002336:	8a0080e7          	jalr	-1888(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000233a:	589c                	lw	a5,48(s1)
    8000233c:	01278c63          	beq	a5,s2,80002354 <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002340:	8526                	mv	a0,s1
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	944080e7          	jalr	-1724(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000234a:	94ce                	add	s1,s1,s3
    8000234c:	ff4492e3          	bne	s1,s4,80002330 <kill+0x28>
  }
  return -1;
    80002350:	557d                	li	a0,-1
    80002352:	a829                	j	8000236c <kill+0x64>
      p->killed = 1;
    80002354:	4785                	li	a5,1
    80002356:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    80002358:	4c98                	lw	a4,24(s1)
    8000235a:	4789                	li	a5,2
    8000235c:	02f70063          	beq	a4,a5,8000237c <kill+0x74>
      release(&p->lock);
    80002360:	8526                	mv	a0,s1
    80002362:	fffff097          	auipc	ra,0xfffff
    80002366:	924080e7          	jalr	-1756(ra) # 80000c86 <release>
      return 0;
    8000236a:	4501                	li	a0,0
}
    8000236c:	70a2                	ld	ra,40(sp)
    8000236e:	7402                	ld	s0,32(sp)
    80002370:	64e2                	ld	s1,24(sp)
    80002372:	6942                	ld	s2,16(sp)
    80002374:	69a2                	ld	s3,8(sp)
    80002376:	6a02                	ld	s4,0(sp)
    80002378:	6145                	add	sp,sp,48
    8000237a:	8082                	ret
        p->state = RUNNABLE;
    8000237c:	478d                	li	a5,3
    8000237e:	cc9c                	sw	a5,24(s1)
    80002380:	b7c5                	j	80002360 <kill+0x58>

0000000080002382 <setkilled>:

void
setkilled(struct proc *p)
{
    80002382:	1101                	add	sp,sp,-32
    80002384:	ec06                	sd	ra,24(sp)
    80002386:	e822                	sd	s0,16(sp)
    80002388:	e426                	sd	s1,8(sp)
    8000238a:	1000                	add	s0,sp,32
    8000238c:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000238e:	fffff097          	auipc	ra,0xfffff
    80002392:	844080e7          	jalr	-1980(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002396:	4785                	li	a5,1
    80002398:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    8000239a:	8526                	mv	a0,s1
    8000239c:	fffff097          	auipc	ra,0xfffff
    800023a0:	8ea080e7          	jalr	-1814(ra) # 80000c86 <release>
}
    800023a4:	60e2                	ld	ra,24(sp)
    800023a6:	6442                	ld	s0,16(sp)
    800023a8:	64a2                	ld	s1,8(sp)
    800023aa:	6105                	add	sp,sp,32
    800023ac:	8082                	ret

00000000800023ae <killed>:

int
killed(struct proc *p)
{
    800023ae:	1101                	add	sp,sp,-32
    800023b0:	ec06                	sd	ra,24(sp)
    800023b2:	e822                	sd	s0,16(sp)
    800023b4:	e426                	sd	s1,8(sp)
    800023b6:	e04a                	sd	s2,0(sp)
    800023b8:	1000                	add	s0,sp,32
    800023ba:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	816080e7          	jalr	-2026(ra) # 80000bd2 <acquire>
  k = p->killed;
    800023c4:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023c8:	8526                	mv	a0,s1
    800023ca:	fffff097          	auipc	ra,0xfffff
    800023ce:	8bc080e7          	jalr	-1860(ra) # 80000c86 <release>
  return k;
}
    800023d2:	854a                	mv	a0,s2
    800023d4:	60e2                	ld	ra,24(sp)
    800023d6:	6442                	ld	s0,16(sp)
    800023d8:	64a2                	ld	s1,8(sp)
    800023da:	6902                	ld	s2,0(sp)
    800023dc:	6105                	add	sp,sp,32
    800023de:	8082                	ret

00000000800023e0 <wait>:
{
    800023e0:	715d                	add	sp,sp,-80
    800023e2:	e486                	sd	ra,72(sp)
    800023e4:	e0a2                	sd	s0,64(sp)
    800023e6:	fc26                	sd	s1,56(sp)
    800023e8:	f84a                	sd	s2,48(sp)
    800023ea:	f44e                	sd	s3,40(sp)
    800023ec:	f052                	sd	s4,32(sp)
    800023ee:	ec56                	sd	s5,24(sp)
    800023f0:	e85a                	sd	s6,16(sp)
    800023f2:	e45e                	sd	s7,8(sp)
    800023f4:	0880                	add	s0,sp,80
    800023f6:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800023f8:	fffff097          	auipc	ra,0xfffff
    800023fc:	5ea080e7          	jalr	1514(ra) # 800019e2 <myproc>
    80002400:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002402:	0000f517          	auipc	a0,0xf
    80002406:	92650513          	add	a0,a0,-1754 # 80010d28 <wait_lock>
    8000240a:	ffffe097          	auipc	ra,0xffffe
    8000240e:	7c8080e7          	jalr	1992(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002412:	4a95                	li	s5,5
        havekids = 1;
    80002414:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002416:	6999                	lui	s3,0x6
    80002418:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000241c:	0018ca17          	auipc	s4,0x18c
    80002420:	b24a0a13          	add	s4,s4,-1244 # 8018df40 <tickslock>
    80002424:	a0d9                	j	800024ea <wait+0x10a>
          pid = pp->pid;
    80002426:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000242a:	000b8e63          	beqz	s7,80002446 <wait+0x66>
    8000242e:	4691                	li	a3,4
    80002430:	02c48613          	add	a2,s1,44
    80002434:	85de                	mv	a1,s7
    80002436:	05093503          	ld	a0,80(s2)
    8000243a:	fffff097          	auipc	ra,0xfffff
    8000243e:	258080e7          	jalr	600(ra) # 80001692 <copyout>
    80002442:	04054063          	bltz	a0,80002482 <wait+0xa2>
          freeproc(pp);
    80002446:	8526                	mv	a0,s1
    80002448:	fffff097          	auipc	ra,0xfffff
    8000244c:	74c080e7          	jalr	1868(ra) # 80001b94 <freeproc>
          release(&pp->lock);
    80002450:	8526                	mv	a0,s1
    80002452:	fffff097          	auipc	ra,0xfffff
    80002456:	834080e7          	jalr	-1996(ra) # 80000c86 <release>
          release(&wait_lock);
    8000245a:	0000f517          	auipc	a0,0xf
    8000245e:	8ce50513          	add	a0,a0,-1842 # 80010d28 <wait_lock>
    80002462:	fffff097          	auipc	ra,0xfffff
    80002466:	824080e7          	jalr	-2012(ra) # 80000c86 <release>
}
    8000246a:	854e                	mv	a0,s3
    8000246c:	60a6                	ld	ra,72(sp)
    8000246e:	6406                	ld	s0,64(sp)
    80002470:	74e2                	ld	s1,56(sp)
    80002472:	7942                	ld	s2,48(sp)
    80002474:	79a2                	ld	s3,40(sp)
    80002476:	7a02                	ld	s4,32(sp)
    80002478:	6ae2                	ld	s5,24(sp)
    8000247a:	6b42                	ld	s6,16(sp)
    8000247c:	6ba2                	ld	s7,8(sp)
    8000247e:	6161                	add	sp,sp,80
    80002480:	8082                	ret
            release(&pp->lock);
    80002482:	8526                	mv	a0,s1
    80002484:	fffff097          	auipc	ra,0xfffff
    80002488:	802080e7          	jalr	-2046(ra) # 80000c86 <release>
            release(&wait_lock);
    8000248c:	0000f517          	auipc	a0,0xf
    80002490:	89c50513          	add	a0,a0,-1892 # 80010d28 <wait_lock>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	7f2080e7          	jalr	2034(ra) # 80000c86 <release>
            return -1;
    8000249c:	59fd                	li	s3,-1
    8000249e:	b7f1                	j	8000246a <wait+0x8a>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a0:	94ce                	add	s1,s1,s3
    800024a2:	03448463          	beq	s1,s4,800024ca <wait+0xea>
      if(pp->parent == p){
    800024a6:	7c9c                	ld	a5,56(s1)
    800024a8:	ff279ce3          	bne	a5,s2,800024a0 <wait+0xc0>
        acquire(&pp->lock);
    800024ac:	8526                	mv	a0,s1
    800024ae:	ffffe097          	auipc	ra,0xffffe
    800024b2:	724080e7          	jalr	1828(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    800024b6:	4c9c                	lw	a5,24(s1)
    800024b8:	f75787e3          	beq	a5,s5,80002426 <wait+0x46>
        release(&pp->lock);
    800024bc:	8526                	mv	a0,s1
    800024be:	ffffe097          	auipc	ra,0xffffe
    800024c2:	7c8080e7          	jalr	1992(ra) # 80000c86 <release>
        havekids = 1;
    800024c6:	875a                	mv	a4,s6
    800024c8:	bfe1                	j	800024a0 <wait+0xc0>
    if(!havekids || killed(p)){
    800024ca:	c715                	beqz	a4,800024f6 <wait+0x116>
    800024cc:	854a                	mv	a0,s2
    800024ce:	00000097          	auipc	ra,0x0
    800024d2:	ee0080e7          	jalr	-288(ra) # 800023ae <killed>
    800024d6:	e105                	bnez	a0,800024f6 <wait+0x116>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024d8:	0000f597          	auipc	a1,0xf
    800024dc:	85058593          	add	a1,a1,-1968 # 80010d28 <wait_lock>
    800024e0:	854a                	mv	a0,s2
    800024e2:	00000097          	auipc	ra,0x0
    800024e6:	c0c080e7          	jalr	-1012(ra) # 800020ee <sleep>
    havekids = 0;
    800024ea:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024ec:	0000f497          	auipc	s1,0xf
    800024f0:	c5448493          	add	s1,s1,-940 # 80011140 <proc>
    800024f4:	bf4d                	j	800024a6 <wait+0xc6>
      release(&wait_lock);
    800024f6:	0000f517          	auipc	a0,0xf
    800024fa:	83250513          	add	a0,a0,-1998 # 80010d28 <wait_lock>
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	788080e7          	jalr	1928(ra) # 80000c86 <release>
      return -1;
    80002506:	59fd                	li	s3,-1
    80002508:	b78d                	j	8000246a <wait+0x8a>

000000008000250a <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000250a:	7179                	add	sp,sp,-48
    8000250c:	f406                	sd	ra,40(sp)
    8000250e:	f022                	sd	s0,32(sp)
    80002510:	ec26                	sd	s1,24(sp)
    80002512:	e84a                	sd	s2,16(sp)
    80002514:	e44e                	sd	s3,8(sp)
    80002516:	e052                	sd	s4,0(sp)
    80002518:	1800                	add	s0,sp,48
    8000251a:	84aa                	mv	s1,a0
    8000251c:	892e                	mv	s2,a1
    8000251e:	89b2                	mv	s3,a2
    80002520:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002522:	fffff097          	auipc	ra,0xfffff
    80002526:	4c0080e7          	jalr	1216(ra) # 800019e2 <myproc>
  if(user_dst){
    8000252a:	c08d                	beqz	s1,8000254c <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000252c:	86d2                	mv	a3,s4
    8000252e:	864e                	mv	a2,s3
    80002530:	85ca                	mv	a1,s2
    80002532:	6928                	ld	a0,80(a0)
    80002534:	fffff097          	auipc	ra,0xfffff
    80002538:	15e080e7          	jalr	350(ra) # 80001692 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    8000253c:	70a2                	ld	ra,40(sp)
    8000253e:	7402                	ld	s0,32(sp)
    80002540:	64e2                	ld	s1,24(sp)
    80002542:	6942                	ld	s2,16(sp)
    80002544:	69a2                	ld	s3,8(sp)
    80002546:	6a02                	ld	s4,0(sp)
    80002548:	6145                	add	sp,sp,48
    8000254a:	8082                	ret
    memmove((char *)dst, src, len);
    8000254c:	000a061b          	sext.w	a2,s4
    80002550:	85ce                	mv	a1,s3
    80002552:	854a                	mv	a0,s2
    80002554:	ffffe097          	auipc	ra,0xffffe
    80002558:	7d6080e7          	jalr	2006(ra) # 80000d2a <memmove>
    return 0;
    8000255c:	8526                	mv	a0,s1
    8000255e:	bff9                	j	8000253c <either_copyout+0x32>

0000000080002560 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002560:	7179                	add	sp,sp,-48
    80002562:	f406                	sd	ra,40(sp)
    80002564:	f022                	sd	s0,32(sp)
    80002566:	ec26                	sd	s1,24(sp)
    80002568:	e84a                	sd	s2,16(sp)
    8000256a:	e44e                	sd	s3,8(sp)
    8000256c:	e052                	sd	s4,0(sp)
    8000256e:	1800                	add	s0,sp,48
    80002570:	892a                	mv	s2,a0
    80002572:	84ae                	mv	s1,a1
    80002574:	89b2                	mv	s3,a2
    80002576:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002578:	fffff097          	auipc	ra,0xfffff
    8000257c:	46a080e7          	jalr	1130(ra) # 800019e2 <myproc>
  if(user_src){
    80002580:	c08d                	beqz	s1,800025a2 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002582:	86d2                	mv	a3,s4
    80002584:	864e                	mv	a2,s3
    80002586:	85ca                	mv	a1,s2
    80002588:	6928                	ld	a0,80(a0)
    8000258a:	fffff097          	auipc	ra,0xfffff
    8000258e:	194080e7          	jalr	404(ra) # 8000171e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002592:	70a2                	ld	ra,40(sp)
    80002594:	7402                	ld	s0,32(sp)
    80002596:	64e2                	ld	s1,24(sp)
    80002598:	6942                	ld	s2,16(sp)
    8000259a:	69a2                	ld	s3,8(sp)
    8000259c:	6a02                	ld	s4,0(sp)
    8000259e:	6145                	add	sp,sp,48
    800025a0:	8082                	ret
    memmove(dst, (char*)src, len);
    800025a2:	000a061b          	sext.w	a2,s4
    800025a6:	85ce                	mv	a1,s3
    800025a8:	854a                	mv	a0,s2
    800025aa:	ffffe097          	auipc	ra,0xffffe
    800025ae:	780080e7          	jalr	1920(ra) # 80000d2a <memmove>
    return 0;
    800025b2:	8526                	mv	a0,s1
    800025b4:	bff9                	j	80002592 <either_copyin+0x32>

00000000800025b6 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025b6:	715d                	add	sp,sp,-80
    800025b8:	e486                	sd	ra,72(sp)
    800025ba:	e0a2                	sd	s0,64(sp)
    800025bc:	fc26                	sd	s1,56(sp)
    800025be:	f84a                	sd	s2,48(sp)
    800025c0:	f44e                	sd	s3,40(sp)
    800025c2:	f052                	sd	s4,32(sp)
    800025c4:	ec56                	sd	s5,24(sp)
    800025c6:	e85a                	sd	s6,16(sp)
    800025c8:	e45e                	sd	s7,8(sp)
    800025ca:	e062                	sd	s8,0(sp)
    800025cc:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025ce:	00006517          	auipc	a0,0x6
    800025d2:	44a50513          	add	a0,a0,1098 # 80008a18 <syscalls+0x5a0>
    800025d6:	ffffe097          	auipc	ra,0xffffe
    800025da:	fb0080e7          	jalr	-80(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025de:	0000f497          	auipc	s1,0xf
    800025e2:	cba48493          	add	s1,s1,-838 # 80011298 <proc+0x158>
    800025e6:	0018c997          	auipc	s3,0x18c
    800025ea:	ab298993          	add	s3,s3,-1358 # 8018e098 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800025ee:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    800025f0:	00006a17          	auipc	s4,0x6
    800025f4:	cb8a0a13          	add	s4,s4,-840 # 800082a8 <digits+0x268>
    printf("%d %s %s", p->pid, state, p->name);
    800025f8:	00006b17          	auipc	s6,0x6
    800025fc:	cb8b0b13          	add	s6,s6,-840 # 800082b0 <digits+0x270>
    printf("\n");
    80002600:	00006a97          	auipc	s5,0x6
    80002604:	418a8a93          	add	s5,s5,1048 # 80008a18 <syscalls+0x5a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002608:	00006c17          	auipc	s8,0x6
    8000260c:	ce8c0c13          	add	s8,s8,-792 # 800082f0 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002610:	6919                	lui	s2,0x6
    80002612:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002616:	a005                	j	80002636 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    80002618:	ed86a583          	lw	a1,-296(a3)
    8000261c:	855a                	mv	a0,s6
    8000261e:	ffffe097          	auipc	ra,0xffffe
    80002622:	f68080e7          	jalr	-152(ra) # 80000586 <printf>
    printf("\n");
    80002626:	8556                	mv	a0,s5
    80002628:	ffffe097          	auipc	ra,0xffffe
    8000262c:	f5e080e7          	jalr	-162(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002630:	94ca                	add	s1,s1,s2
    80002632:	03348263          	beq	s1,s3,80002656 <procdump+0xa0>
    if(p->state == UNUSED)
    80002636:	86a6                	mv	a3,s1
    80002638:	ec04a783          	lw	a5,-320(s1)
    8000263c:	dbf5                	beqz	a5,80002630 <procdump+0x7a>
      state = "???";
    8000263e:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002640:	fcfbece3          	bltu	s7,a5,80002618 <procdump+0x62>
    80002644:	02079713          	sll	a4,a5,0x20
    80002648:	01d75793          	srl	a5,a4,0x1d
    8000264c:	97e2                	add	a5,a5,s8
    8000264e:	6390                	ld	a2,0(a5)
    80002650:	f661                	bnez	a2,80002618 <procdump+0x62>
      state = "???";
    80002652:	8652                	mv	a2,s4
    80002654:	b7d1                	j	80002618 <procdump+0x62>
  }
}
    80002656:	60a6                	ld	ra,72(sp)
    80002658:	6406                	ld	s0,64(sp)
    8000265a:	74e2                	ld	s1,56(sp)
    8000265c:	7942                	ld	s2,48(sp)
    8000265e:	79a2                	ld	s3,40(sp)
    80002660:	7a02                	ld	s4,32(sp)
    80002662:	6ae2                	ld	s5,24(sp)
    80002664:	6b42                	ld	s6,16(sp)
    80002666:	6ba2                	ld	s7,8(sp)
    80002668:	6c02                	ld	s8,0(sp)
    8000266a:	6161                	add	sp,sp,80
    8000266c:	8082                	ret

000000008000266e <swtch>:
    8000266e:	00153023          	sd	ra,0(a0)
    80002672:	00253423          	sd	sp,8(a0)
    80002676:	e900                	sd	s0,16(a0)
    80002678:	ed04                	sd	s1,24(a0)
    8000267a:	03253023          	sd	s2,32(a0)
    8000267e:	03353423          	sd	s3,40(a0)
    80002682:	03453823          	sd	s4,48(a0)
    80002686:	03553c23          	sd	s5,56(a0)
    8000268a:	05653023          	sd	s6,64(a0)
    8000268e:	05753423          	sd	s7,72(a0)
    80002692:	05853823          	sd	s8,80(a0)
    80002696:	05953c23          	sd	s9,88(a0)
    8000269a:	07a53023          	sd	s10,96(a0)
    8000269e:	07b53423          	sd	s11,104(a0)
    800026a2:	0005b083          	ld	ra,0(a1)
    800026a6:	0085b103          	ld	sp,8(a1)
    800026aa:	6980                	ld	s0,16(a1)
    800026ac:	6d84                	ld	s1,24(a1)
    800026ae:	0205b903          	ld	s2,32(a1)
    800026b2:	0285b983          	ld	s3,40(a1)
    800026b6:	0305ba03          	ld	s4,48(a1)
    800026ba:	0385ba83          	ld	s5,56(a1)
    800026be:	0405bb03          	ld	s6,64(a1)
    800026c2:	0485bb83          	ld	s7,72(a1)
    800026c6:	0505bc03          	ld	s8,80(a1)
    800026ca:	0585bc83          	ld	s9,88(a1)
    800026ce:	0605bd03          	ld	s10,96(a1)
    800026d2:	0685bd83          	ld	s11,104(a1)
    800026d6:	8082                	ret

00000000800026d8 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026d8:	1141                	add	sp,sp,-16
    800026da:	e406                	sd	ra,8(sp)
    800026dc:	e022                	sd	s0,0(sp)
    800026de:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800026e0:	00006597          	auipc	a1,0x6
    800026e4:	c4058593          	add	a1,a1,-960 # 80008320 <states.0+0x30>
    800026e8:	0018c517          	auipc	a0,0x18c
    800026ec:	85850513          	add	a0,a0,-1960 # 8018df40 <tickslock>
    800026f0:	ffffe097          	auipc	ra,0xffffe
    800026f4:	452080e7          	jalr	1106(ra) # 80000b42 <initlock>
}
    800026f8:	60a2                	ld	ra,8(sp)
    800026fa:	6402                	ld	s0,0(sp)
    800026fc:	0141                	add	sp,sp,16
    800026fe:	8082                	ret

0000000080002700 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002700:	1141                	add	sp,sp,-16
    80002702:	e422                	sd	s0,8(sp)
    80002704:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002706:	00003797          	auipc	a5,0x3
    8000270a:	4fa78793          	add	a5,a5,1274 # 80005c00 <kernelvec>
    8000270e:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002712:	6422                	ld	s0,8(sp)
    80002714:	0141                	add	sp,sp,16
    80002716:	8082                	ret

0000000080002718 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002718:	1141                	add	sp,sp,-16
    8000271a:	e406                	sd	ra,8(sp)
    8000271c:	e022                	sd	s0,0(sp)
    8000271e:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    80002720:	fffff097          	auipc	ra,0xfffff
    80002724:	2c2080e7          	jalr	706(ra) # 800019e2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002728:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    8000272c:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000272e:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002732:	00005697          	auipc	a3,0x5
    80002736:	8ce68693          	add	a3,a3,-1842 # 80007000 <_trampoline>
    8000273a:	00005717          	auipc	a4,0x5
    8000273e:	8c670713          	add	a4,a4,-1850 # 80007000 <_trampoline>
    80002742:	8f15                	sub	a4,a4,a3
    80002744:	040007b7          	lui	a5,0x4000
    80002748:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000274a:	07b2                	sll	a5,a5,0xc
    8000274c:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000274e:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002752:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002754:	18002673          	csrr	a2,satp
    80002758:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000275a:	6d30                	ld	a2,88(a0)
    8000275c:	6138                	ld	a4,64(a0)
    8000275e:	6585                	lui	a1,0x1
    80002760:	972e                	add	a4,a4,a1
    80002762:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002764:	6d38                	ld	a4,88(a0)
    80002766:	00000617          	auipc	a2,0x0
    8000276a:	13460613          	add	a2,a2,308 # 8000289a <usertrap>
    8000276e:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002770:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002772:	8612                	mv	a2,tp
    80002774:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002776:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000277a:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    8000277e:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002782:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002786:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002788:	6f18                	ld	a4,24(a4)
    8000278a:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    8000278e:	6928                	ld	a0,80(a0)
    80002790:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    80002792:	00005717          	auipc	a4,0x5
    80002796:	90a70713          	add	a4,a4,-1782 # 8000709c <userret>
    8000279a:	8f15                	sub	a4,a4,a3
    8000279c:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    8000279e:	577d                	li	a4,-1
    800027a0:	177e                	sll	a4,a4,0x3f
    800027a2:	8d59                	or	a0,a0,a4
    800027a4:	9782                	jalr	a5
}
    800027a6:	60a2                	ld	ra,8(sp)
    800027a8:	6402                	ld	s0,0(sp)
    800027aa:	0141                	add	sp,sp,16
    800027ac:	8082                	ret

00000000800027ae <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027ae:	1101                	add	sp,sp,-32
    800027b0:	ec06                	sd	ra,24(sp)
    800027b2:	e822                	sd	s0,16(sp)
    800027b4:	e426                	sd	s1,8(sp)
    800027b6:	1000                	add	s0,sp,32
  acquire(&tickslock);
    800027b8:	0018b497          	auipc	s1,0x18b
    800027bc:	78848493          	add	s1,s1,1928 # 8018df40 <tickslock>
    800027c0:	8526                	mv	a0,s1
    800027c2:	ffffe097          	auipc	ra,0xffffe
    800027c6:	410080e7          	jalr	1040(ra) # 80000bd2 <acquire>
  ticks++;
    800027ca:	00006517          	auipc	a0,0x6
    800027ce:	2d650513          	add	a0,a0,726 # 80008aa0 <ticks>
    800027d2:	411c                	lw	a5,0(a0)
    800027d4:	2785                	addw	a5,a5,1
    800027d6:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027d8:	00000097          	auipc	ra,0x0
    800027dc:	97a080e7          	jalr	-1670(ra) # 80002152 <wakeup>
  release(&tickslock);
    800027e0:	8526                	mv	a0,s1
    800027e2:	ffffe097          	auipc	ra,0xffffe
    800027e6:	4a4080e7          	jalr	1188(ra) # 80000c86 <release>
}
    800027ea:	60e2                	ld	ra,24(sp)
    800027ec:	6442                	ld	s0,16(sp)
    800027ee:	64a2                	ld	s1,8(sp)
    800027f0:	6105                	add	sp,sp,32
    800027f2:	8082                	ret

00000000800027f4 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    800027f4:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800027f8:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    800027fa:	0807df63          	bgez	a5,80002898 <devintr+0xa4>
{
    800027fe:	1101                	add	sp,sp,-32
    80002800:	ec06                	sd	ra,24(sp)
    80002802:	e822                	sd	s0,16(sp)
    80002804:	e426                	sd	s1,8(sp)
    80002806:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002808:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    8000280c:	46a5                	li	a3,9
    8000280e:	00d70d63          	beq	a4,a3,80002828 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002812:	577d                	li	a4,-1
    80002814:	177e                	sll	a4,a4,0x3f
    80002816:	0705                	add	a4,a4,1
    return 0;
    80002818:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000281a:	04e78e63          	beq	a5,a4,80002876 <devintr+0x82>
  }
}
    8000281e:	60e2                	ld	ra,24(sp)
    80002820:	6442                	ld	s0,16(sp)
    80002822:	64a2                	ld	s1,8(sp)
    80002824:	6105                	add	sp,sp,32
    80002826:	8082                	ret
    int irq = plic_claim();
    80002828:	00003097          	auipc	ra,0x3
    8000282c:	4e0080e7          	jalr	1248(ra) # 80005d08 <plic_claim>
    80002830:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002832:	47a9                	li	a5,10
    80002834:	02f50763          	beq	a0,a5,80002862 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    80002838:	4785                	li	a5,1
    8000283a:	02f50963          	beq	a0,a5,8000286c <devintr+0x78>
    return 1;
    8000283e:	4505                	li	a0,1
    } else if(irq){
    80002840:	dcf9                	beqz	s1,8000281e <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002842:	85a6                	mv	a1,s1
    80002844:	00006517          	auipc	a0,0x6
    80002848:	ae450513          	add	a0,a0,-1308 # 80008328 <states.0+0x38>
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	d3a080e7          	jalr	-710(ra) # 80000586 <printf>
      plic_complete(irq);
    80002854:	8526                	mv	a0,s1
    80002856:	00003097          	auipc	ra,0x3
    8000285a:	4d6080e7          	jalr	1238(ra) # 80005d2c <plic_complete>
    return 1;
    8000285e:	4505                	li	a0,1
    80002860:	bf7d                	j	8000281e <devintr+0x2a>
      uartintr();
    80002862:	ffffe097          	auipc	ra,0xffffe
    80002866:	132080e7          	jalr	306(ra) # 80000994 <uartintr>
    if(irq)
    8000286a:	b7ed                	j	80002854 <devintr+0x60>
      virtio_disk_intr();
    8000286c:	00004097          	auipc	ra,0x4
    80002870:	986080e7          	jalr	-1658(ra) # 800061f2 <virtio_disk_intr>
    if(irq)
    80002874:	b7c5                	j	80002854 <devintr+0x60>
    if(cpuid() == 0){
    80002876:	fffff097          	auipc	ra,0xfffff
    8000287a:	140080e7          	jalr	320(ra) # 800019b6 <cpuid>
    8000287e:	c901                	beqz	a0,8000288e <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002880:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002884:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002886:	14479073          	csrw	sip,a5
    return 2;
    8000288a:	4509                	li	a0,2
    8000288c:	bf49                	j	8000281e <devintr+0x2a>
      clockintr();
    8000288e:	00000097          	auipc	ra,0x0
    80002892:	f20080e7          	jalr	-224(ra) # 800027ae <clockintr>
    80002896:	b7ed                	j	80002880 <devintr+0x8c>
}
    80002898:	8082                	ret

000000008000289a <usertrap>:
{
    8000289a:	1101                	add	sp,sp,-32
    8000289c:	ec06                	sd	ra,24(sp)
    8000289e:	e822                	sd	s0,16(sp)
    800028a0:	e426                	sd	s1,8(sp)
    800028a2:	e04a                	sd	s2,0(sp)
    800028a4:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028a6:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028aa:	1007f793          	and	a5,a5,256
    800028ae:	e7b9                	bnez	a5,800028fc <usertrap+0x62>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028b0:	00003797          	auipc	a5,0x3
    800028b4:	35078793          	add	a5,a5,848 # 80005c00 <kernelvec>
    800028b8:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028bc:	fffff097          	auipc	ra,0xfffff
    800028c0:	126080e7          	jalr	294(ra) # 800019e2 <myproc>
    800028c4:	84aa                	mv	s1,a0
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028c6:	14202773          	csrr	a4,scause
  if(r_scause() == 12 || r_scause == 13 || r_scause == 15){
    800028ca:	47b1                	li	a5,12
    800028cc:	04f70063          	beq	a4,a5,8000290c <usertrap+0x72>
  p->trapframe->epc = r_sepc();
    800028d0:	6cbc                	ld	a5,88(s1)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028d2:	14102773          	csrr	a4,sepc
    800028d6:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028d8:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028dc:	47a1                	li	a5,8
    800028de:	02f70c63          	beq	a4,a5,80002916 <usertrap+0x7c>
  } else if((which_dev = devintr()) != 0){
    800028e2:	00000097          	auipc	ra,0x0
    800028e6:	f12080e7          	jalr	-238(ra) # 800027f4 <devintr>
    800028ea:	892a                	mv	s2,a0
    800028ec:	c941                	beqz	a0,8000297c <usertrap+0xe2>
  if(killed(p))
    800028ee:	8526                	mv	a0,s1
    800028f0:	00000097          	auipc	ra,0x0
    800028f4:	abe080e7          	jalr	-1346(ra) # 800023ae <killed>
    800028f8:	cd39                	beqz	a0,80002956 <usertrap+0xbc>
    800028fa:	a889                	j	8000294c <usertrap+0xb2>
    panic("usertrap: not from user mode");
    800028fc:	00006517          	auipc	a0,0x6
    80002900:	a4c50513          	add	a0,a0,-1460 # 80008348 <states.0+0x58>
    80002904:	ffffe097          	auipc	ra,0xffffe
    80002908:	c38080e7          	jalr	-968(ra) # 8000053c <panic>
    page_fault_handler();
    8000290c:	00004097          	auipc	ra,0x4
    80002910:	a68080e7          	jalr	-1432(ra) # 80006374 <page_fault_handler>
    80002914:	bf75                	j	800028d0 <usertrap+0x36>
    if(killed(p))
    80002916:	8526                	mv	a0,s1
    80002918:	00000097          	auipc	ra,0x0
    8000291c:	a96080e7          	jalr	-1386(ra) # 800023ae <killed>
    80002920:	e921                	bnez	a0,80002970 <usertrap+0xd6>
    p->trapframe->epc += 4;
    80002922:	6cb8                	ld	a4,88(s1)
    80002924:	6f1c                	ld	a5,24(a4)
    80002926:	0791                	add	a5,a5,4
    80002928:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000292a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000292e:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002932:	10079073          	csrw	sstatus,a5
    syscall();
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	2d4080e7          	jalr	724(ra) # 80002c0a <syscall>
  if(killed(p))
    8000293e:	8526                	mv	a0,s1
    80002940:	00000097          	auipc	ra,0x0
    80002944:	a6e080e7          	jalr	-1426(ra) # 800023ae <killed>
    80002948:	c911                	beqz	a0,8000295c <usertrap+0xc2>
    8000294a:	4901                	li	s2,0
    exit(-1);
    8000294c:	557d                	li	a0,-1
    8000294e:	00000097          	auipc	ra,0x0
    80002952:	8e4080e7          	jalr	-1820(ra) # 80002232 <exit>
  if(which_dev == 2)
    80002956:	4789                	li	a5,2
    80002958:	04f90f63          	beq	s2,a5,800029b6 <usertrap+0x11c>
  usertrapret();
    8000295c:	00000097          	auipc	ra,0x0
    80002960:	dbc080e7          	jalr	-580(ra) # 80002718 <usertrapret>
}
    80002964:	60e2                	ld	ra,24(sp)
    80002966:	6442                	ld	s0,16(sp)
    80002968:	64a2                	ld	s1,8(sp)
    8000296a:	6902                	ld	s2,0(sp)
    8000296c:	6105                	add	sp,sp,32
    8000296e:	8082                	ret
      exit(-1);
    80002970:	557d                	li	a0,-1
    80002972:	00000097          	auipc	ra,0x0
    80002976:	8c0080e7          	jalr	-1856(ra) # 80002232 <exit>
    8000297a:	b765                	j	80002922 <usertrap+0x88>
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000297c:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002980:	5890                	lw	a2,48(s1)
    80002982:	00006517          	auipc	a0,0x6
    80002986:	9e650513          	add	a0,a0,-1562 # 80008368 <states.0+0x78>
    8000298a:	ffffe097          	auipc	ra,0xffffe
    8000298e:	bfc080e7          	jalr	-1028(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002992:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002996:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    8000299a:	00006517          	auipc	a0,0x6
    8000299e:	9fe50513          	add	a0,a0,-1538 # 80008398 <states.0+0xa8>
    800029a2:	ffffe097          	auipc	ra,0xffffe
    800029a6:	be4080e7          	jalr	-1052(ra) # 80000586 <printf>
    setkilled(p);
    800029aa:	8526                	mv	a0,s1
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	9d6080e7          	jalr	-1578(ra) # 80002382 <setkilled>
    800029b4:	b769                	j	8000293e <usertrap+0xa4>
    yield();
    800029b6:	fffff097          	auipc	ra,0xfffff
    800029ba:	6fc080e7          	jalr	1788(ra) # 800020b2 <yield>
    800029be:	bf79                	j	8000295c <usertrap+0xc2>

00000000800029c0 <kerneltrap>:
{
    800029c0:	7179                	add	sp,sp,-48
    800029c2:	f406                	sd	ra,40(sp)
    800029c4:	f022                	sd	s0,32(sp)
    800029c6:	ec26                	sd	s1,24(sp)
    800029c8:	e84a                	sd	s2,16(sp)
    800029ca:	e44e                	sd	s3,8(sp)
    800029cc:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ce:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029d2:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029d6:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800029da:	1004f793          	and	a5,s1,256
    800029de:	cb85                	beqz	a5,80002a0e <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800029e4:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    800029e6:	ef85                	bnez	a5,80002a1e <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    800029e8:	00000097          	auipc	ra,0x0
    800029ec:	e0c080e7          	jalr	-500(ra) # 800027f4 <devintr>
    800029f0:	cd1d                	beqz	a0,80002a2e <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    800029f2:	4789                	li	a5,2
    800029f4:	06f50a63          	beq	a0,a5,80002a68 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800029f8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029fc:	10049073          	csrw	sstatus,s1
}
    80002a00:	70a2                	ld	ra,40(sp)
    80002a02:	7402                	ld	s0,32(sp)
    80002a04:	64e2                	ld	s1,24(sp)
    80002a06:	6942                	ld	s2,16(sp)
    80002a08:	69a2                	ld	s3,8(sp)
    80002a0a:	6145                	add	sp,sp,48
    80002a0c:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a0e:	00006517          	auipc	a0,0x6
    80002a12:	9aa50513          	add	a0,a0,-1622 # 800083b8 <states.0+0xc8>
    80002a16:	ffffe097          	auipc	ra,0xffffe
    80002a1a:	b26080e7          	jalr	-1242(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002a1e:	00006517          	auipc	a0,0x6
    80002a22:	9c250513          	add	a0,a0,-1598 # 800083e0 <states.0+0xf0>
    80002a26:	ffffe097          	auipc	ra,0xffffe
    80002a2a:	b16080e7          	jalr	-1258(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002a2e:	85ce                	mv	a1,s3
    80002a30:	00006517          	auipc	a0,0x6
    80002a34:	9d050513          	add	a0,a0,-1584 # 80008400 <states.0+0x110>
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b4e080e7          	jalr	-1202(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a44:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a48:	00006517          	auipc	a0,0x6
    80002a4c:	9c850513          	add	a0,a0,-1592 # 80008410 <states.0+0x120>
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	b36080e7          	jalr	-1226(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002a58:	00006517          	auipc	a0,0x6
    80002a5c:	9d050513          	add	a0,a0,-1584 # 80008428 <states.0+0x138>
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	adc080e7          	jalr	-1316(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002a68:	fffff097          	auipc	ra,0xfffff
    80002a6c:	f7a080e7          	jalr	-134(ra) # 800019e2 <myproc>
    80002a70:	d541                	beqz	a0,800029f8 <kerneltrap+0x38>
    80002a72:	fffff097          	auipc	ra,0xfffff
    80002a76:	f70080e7          	jalr	-144(ra) # 800019e2 <myproc>
    80002a7a:	4d18                	lw	a4,24(a0)
    80002a7c:	4791                	li	a5,4
    80002a7e:	f6f71de3          	bne	a4,a5,800029f8 <kerneltrap+0x38>
    yield();
    80002a82:	fffff097          	auipc	ra,0xfffff
    80002a86:	630080e7          	jalr	1584(ra) # 800020b2 <yield>
    80002a8a:	b7bd                	j	800029f8 <kerneltrap+0x38>

0000000080002a8c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002a8c:	1101                	add	sp,sp,-32
    80002a8e:	ec06                	sd	ra,24(sp)
    80002a90:	e822                	sd	s0,16(sp)
    80002a92:	e426                	sd	s1,8(sp)
    80002a94:	1000                	add	s0,sp,32
    80002a96:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	f4a080e7          	jalr	-182(ra) # 800019e2 <myproc>
  switch (n) {
    80002aa0:	4795                	li	a5,5
    80002aa2:	0497e163          	bltu	a5,s1,80002ae4 <argraw+0x58>
    80002aa6:	048a                	sll	s1,s1,0x2
    80002aa8:	00006717          	auipc	a4,0x6
    80002aac:	9b870713          	add	a4,a4,-1608 # 80008460 <states.0+0x170>
    80002ab0:	94ba                	add	s1,s1,a4
    80002ab2:	409c                	lw	a5,0(s1)
    80002ab4:	97ba                	add	a5,a5,a4
    80002ab6:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002ab8:	6d3c                	ld	a5,88(a0)
    80002aba:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002abc:	60e2                	ld	ra,24(sp)
    80002abe:	6442                	ld	s0,16(sp)
    80002ac0:	64a2                	ld	s1,8(sp)
    80002ac2:	6105                	add	sp,sp,32
    80002ac4:	8082                	ret
    return p->trapframe->a1;
    80002ac6:	6d3c                	ld	a5,88(a0)
    80002ac8:	7fa8                	ld	a0,120(a5)
    80002aca:	bfcd                	j	80002abc <argraw+0x30>
    return p->trapframe->a2;
    80002acc:	6d3c                	ld	a5,88(a0)
    80002ace:	63c8                	ld	a0,128(a5)
    80002ad0:	b7f5                	j	80002abc <argraw+0x30>
    return p->trapframe->a3;
    80002ad2:	6d3c                	ld	a5,88(a0)
    80002ad4:	67c8                	ld	a0,136(a5)
    80002ad6:	b7dd                	j	80002abc <argraw+0x30>
    return p->trapframe->a4;
    80002ad8:	6d3c                	ld	a5,88(a0)
    80002ada:	6bc8                	ld	a0,144(a5)
    80002adc:	b7c5                	j	80002abc <argraw+0x30>
    return p->trapframe->a5;
    80002ade:	6d3c                	ld	a5,88(a0)
    80002ae0:	6fc8                	ld	a0,152(a5)
    80002ae2:	bfe9                	j	80002abc <argraw+0x30>
  panic("argraw");
    80002ae4:	00006517          	auipc	a0,0x6
    80002ae8:	95450513          	add	a0,a0,-1708 # 80008438 <states.0+0x148>
    80002aec:	ffffe097          	auipc	ra,0xffffe
    80002af0:	a50080e7          	jalr	-1456(ra) # 8000053c <panic>

0000000080002af4 <fetchaddr>:
{
    80002af4:	1101                	add	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	e04a                	sd	s2,0(sp)
    80002afe:	1000                	add	s0,sp,32
    80002b00:	84aa                	mv	s1,a0
    80002b02:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b04:	fffff097          	auipc	ra,0xfffff
    80002b08:	ede080e7          	jalr	-290(ra) # 800019e2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b0c:	653c                	ld	a5,72(a0)
    80002b0e:	02f4f863          	bgeu	s1,a5,80002b3e <fetchaddr+0x4a>
    80002b12:	00848713          	add	a4,s1,8
    80002b16:	02e7e663          	bltu	a5,a4,80002b42 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b1a:	46a1                	li	a3,8
    80002b1c:	8626                	mv	a2,s1
    80002b1e:	85ca                	mv	a1,s2
    80002b20:	6928                	ld	a0,80(a0)
    80002b22:	fffff097          	auipc	ra,0xfffff
    80002b26:	bfc080e7          	jalr	-1028(ra) # 8000171e <copyin>
    80002b2a:	00a03533          	snez	a0,a0
    80002b2e:	40a00533          	neg	a0,a0
}
    80002b32:	60e2                	ld	ra,24(sp)
    80002b34:	6442                	ld	s0,16(sp)
    80002b36:	64a2                	ld	s1,8(sp)
    80002b38:	6902                	ld	s2,0(sp)
    80002b3a:	6105                	add	sp,sp,32
    80002b3c:	8082                	ret
    return -1;
    80002b3e:	557d                	li	a0,-1
    80002b40:	bfcd                	j	80002b32 <fetchaddr+0x3e>
    80002b42:	557d                	li	a0,-1
    80002b44:	b7fd                	j	80002b32 <fetchaddr+0x3e>

0000000080002b46 <fetchstr>:
{
    80002b46:	7179                	add	sp,sp,-48
    80002b48:	f406                	sd	ra,40(sp)
    80002b4a:	f022                	sd	s0,32(sp)
    80002b4c:	ec26                	sd	s1,24(sp)
    80002b4e:	e84a                	sd	s2,16(sp)
    80002b50:	e44e                	sd	s3,8(sp)
    80002b52:	1800                	add	s0,sp,48
    80002b54:	892a                	mv	s2,a0
    80002b56:	84ae                	mv	s1,a1
    80002b58:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002b5a:	fffff097          	auipc	ra,0xfffff
    80002b5e:	e88080e7          	jalr	-376(ra) # 800019e2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002b62:	86ce                	mv	a3,s3
    80002b64:	864a                	mv	a2,s2
    80002b66:	85a6                	mv	a1,s1
    80002b68:	6928                	ld	a0,80(a0)
    80002b6a:	fffff097          	auipc	ra,0xfffff
    80002b6e:	c42080e7          	jalr	-958(ra) # 800017ac <copyinstr>
    80002b72:	00054e63          	bltz	a0,80002b8e <fetchstr+0x48>
  return strlen(buf);
    80002b76:	8526                	mv	a0,s1
    80002b78:	ffffe097          	auipc	ra,0xffffe
    80002b7c:	2d0080e7          	jalr	720(ra) # 80000e48 <strlen>
}
    80002b80:	70a2                	ld	ra,40(sp)
    80002b82:	7402                	ld	s0,32(sp)
    80002b84:	64e2                	ld	s1,24(sp)
    80002b86:	6942                	ld	s2,16(sp)
    80002b88:	69a2                	ld	s3,8(sp)
    80002b8a:	6145                	add	sp,sp,48
    80002b8c:	8082                	ret
    return -1;
    80002b8e:	557d                	li	a0,-1
    80002b90:	bfc5                	j	80002b80 <fetchstr+0x3a>

0000000080002b92 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002b92:	1101                	add	sp,sp,-32
    80002b94:	ec06                	sd	ra,24(sp)
    80002b96:	e822                	sd	s0,16(sp)
    80002b98:	e426                	sd	s1,8(sp)
    80002b9a:	1000                	add	s0,sp,32
    80002b9c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002b9e:	00000097          	auipc	ra,0x0
    80002ba2:	eee080e7          	jalr	-274(ra) # 80002a8c <argraw>
    80002ba6:	c088                	sw	a0,0(s1)
}
    80002ba8:	60e2                	ld	ra,24(sp)
    80002baa:	6442                	ld	s0,16(sp)
    80002bac:	64a2                	ld	s1,8(sp)
    80002bae:	6105                	add	sp,sp,32
    80002bb0:	8082                	ret

0000000080002bb2 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bb2:	1101                	add	sp,sp,-32
    80002bb4:	ec06                	sd	ra,24(sp)
    80002bb6:	e822                	sd	s0,16(sp)
    80002bb8:	e426                	sd	s1,8(sp)
    80002bba:	1000                	add	s0,sp,32
    80002bbc:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002bbe:	00000097          	auipc	ra,0x0
    80002bc2:	ece080e7          	jalr	-306(ra) # 80002a8c <argraw>
    80002bc6:	e088                	sd	a0,0(s1)
}
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	64a2                	ld	s1,8(sp)
    80002bce:	6105                	add	sp,sp,32
    80002bd0:	8082                	ret

0000000080002bd2 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002bd2:	7179                	add	sp,sp,-48
    80002bd4:	f406                	sd	ra,40(sp)
    80002bd6:	f022                	sd	s0,32(sp)
    80002bd8:	ec26                	sd	s1,24(sp)
    80002bda:	e84a                	sd	s2,16(sp)
    80002bdc:	1800                	add	s0,sp,48
    80002bde:	84ae                	mv	s1,a1
    80002be0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002be2:	fd840593          	add	a1,s0,-40
    80002be6:	00000097          	auipc	ra,0x0
    80002bea:	fcc080e7          	jalr	-52(ra) # 80002bb2 <argaddr>
  return fetchstr(addr, buf, max);
    80002bee:	864a                	mv	a2,s2
    80002bf0:	85a6                	mv	a1,s1
    80002bf2:	fd843503          	ld	a0,-40(s0)
    80002bf6:	00000097          	auipc	ra,0x0
    80002bfa:	f50080e7          	jalr	-176(ra) # 80002b46 <fetchstr>
}
    80002bfe:	70a2                	ld	ra,40(sp)
    80002c00:	7402                	ld	s0,32(sp)
    80002c02:	64e2                	ld	s1,24(sp)
    80002c04:	6942                	ld	s2,16(sp)
    80002c06:	6145                	add	sp,sp,48
    80002c08:	8082                	ret

0000000080002c0a <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c0a:	1101                	add	sp,sp,-32
    80002c0c:	ec06                	sd	ra,24(sp)
    80002c0e:	e822                	sd	s0,16(sp)
    80002c10:	e426                	sd	s1,8(sp)
    80002c12:	e04a                	sd	s2,0(sp)
    80002c14:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c16:	fffff097          	auipc	ra,0xfffff
    80002c1a:	dcc080e7          	jalr	-564(ra) # 800019e2 <myproc>
    80002c1e:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002c20:	05853903          	ld	s2,88(a0)
    80002c24:	0a893783          	ld	a5,168(s2)
    80002c28:	0007869b          	sext.w	a3,a5
  
  /* Adil: debugging */
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c2c:	37fd                	addw	a5,a5,-1
    80002c2e:	4751                	li	a4,20
    80002c30:	00f76f63          	bltu	a4,a5,80002c4e <syscall+0x44>
    80002c34:	00369713          	sll	a4,a3,0x3
    80002c38:	00006797          	auipc	a5,0x6
    80002c3c:	84078793          	add	a5,a5,-1984 # 80008478 <syscalls>
    80002c40:	97ba                	add	a5,a5,a4
    80002c42:	639c                	ld	a5,0(a5)
    80002c44:	c789                	beqz	a5,80002c4e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c46:	9782                	jalr	a5
    80002c48:	06a93823          	sd	a0,112(s2)
    80002c4c:	a839                	j	80002c6a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c4e:	15848613          	add	a2,s1,344
    80002c52:	588c                	lw	a1,48(s1)
    80002c54:	00005517          	auipc	a0,0x5
    80002c58:	7ec50513          	add	a0,a0,2028 # 80008440 <states.0+0x150>
    80002c5c:	ffffe097          	auipc	ra,0xffffe
    80002c60:	92a080e7          	jalr	-1750(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002c64:	6cbc                	ld	a5,88(s1)
    80002c66:	577d                	li	a4,-1
    80002c68:	fbb8                	sd	a4,112(a5)
  }
}
    80002c6a:	60e2                	ld	ra,24(sp)
    80002c6c:	6442                	ld	s0,16(sp)
    80002c6e:	64a2                	ld	s1,8(sp)
    80002c70:	6902                	ld	s2,0(sp)
    80002c72:	6105                	add	sp,sp,32
    80002c74:	8082                	ret

0000000080002c76 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002c76:	1101                	add	sp,sp,-32
    80002c78:	ec06                	sd	ra,24(sp)
    80002c7a:	e822                	sd	s0,16(sp)
    80002c7c:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002c7e:	fec40593          	add	a1,s0,-20
    80002c82:	4501                	li	a0,0
    80002c84:	00000097          	auipc	ra,0x0
    80002c88:	f0e080e7          	jalr	-242(ra) # 80002b92 <argint>
  exit(n);
    80002c8c:	fec42503          	lw	a0,-20(s0)
    80002c90:	fffff097          	auipc	ra,0xfffff
    80002c94:	5a2080e7          	jalr	1442(ra) # 80002232 <exit>
  return 0;  // not reached
}
    80002c98:	4501                	li	a0,0
    80002c9a:	60e2                	ld	ra,24(sp)
    80002c9c:	6442                	ld	s0,16(sp)
    80002c9e:	6105                	add	sp,sp,32
    80002ca0:	8082                	ret

0000000080002ca2 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002ca2:	1141                	add	sp,sp,-16
    80002ca4:	e406                	sd	ra,8(sp)
    80002ca6:	e022                	sd	s0,0(sp)
    80002ca8:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002caa:	fffff097          	auipc	ra,0xfffff
    80002cae:	d38080e7          	jalr	-712(ra) # 800019e2 <myproc>
}
    80002cb2:	5908                	lw	a0,48(a0)
    80002cb4:	60a2                	ld	ra,8(sp)
    80002cb6:	6402                	ld	s0,0(sp)
    80002cb8:	0141                	add	sp,sp,16
    80002cba:	8082                	ret

0000000080002cbc <sys_fork>:

uint64
sys_fork(void)
{
    80002cbc:	1141                	add	sp,sp,-16
    80002cbe:	e406                	sd	ra,8(sp)
    80002cc0:	e022                	sd	s0,0(sp)
    80002cc2:	0800                	add	s0,sp,16
  return fork();
    80002cc4:	fffff097          	auipc	ra,0xfffff
    80002cc8:	12a080e7          	jalr	298(ra) # 80001dee <fork>
}
    80002ccc:	60a2                	ld	ra,8(sp)
    80002cce:	6402                	ld	s0,0(sp)
    80002cd0:	0141                	add	sp,sp,16
    80002cd2:	8082                	ret

0000000080002cd4 <sys_wait>:

uint64
sys_wait(void)
{
    80002cd4:	1101                	add	sp,sp,-32
    80002cd6:	ec06                	sd	ra,24(sp)
    80002cd8:	e822                	sd	s0,16(sp)
    80002cda:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002cdc:	fe840593          	add	a1,s0,-24
    80002ce0:	4501                	li	a0,0
    80002ce2:	00000097          	auipc	ra,0x0
    80002ce6:	ed0080e7          	jalr	-304(ra) # 80002bb2 <argaddr>
  return wait(p);
    80002cea:	fe843503          	ld	a0,-24(s0)
    80002cee:	fffff097          	auipc	ra,0xfffff
    80002cf2:	6f2080e7          	jalr	1778(ra) # 800023e0 <wait>
}
    80002cf6:	60e2                	ld	ra,24(sp)
    80002cf8:	6442                	ld	s0,16(sp)
    80002cfa:	6105                	add	sp,sp,32
    80002cfc:	8082                	ret

0000000080002cfe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002cfe:	7179                	add	sp,sp,-48
    80002d00:	f406                	sd	ra,40(sp)
    80002d02:	f022                	sd	s0,32(sp)
    80002d04:	ec26                	sd	s1,24(sp)
    80002d06:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d08:	fdc40593          	add	a1,s0,-36
    80002d0c:	4501                	li	a0,0
    80002d0e:	00000097          	auipc	ra,0x0
    80002d12:	e84080e7          	jalr	-380(ra) # 80002b92 <argint>
  addr = myproc()->sz;
    80002d16:	fffff097          	auipc	ra,0xfffff
    80002d1a:	ccc080e7          	jalr	-820(ra) # 800019e2 <myproc>
    80002d1e:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d20:	fdc42503          	lw	a0,-36(s0)
    80002d24:	fffff097          	auipc	ra,0xfffff
    80002d28:	066080e7          	jalr	102(ra) # 80001d8a <growproc>
    80002d2c:	00054863          	bltz	a0,80002d3c <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002d30:	8526                	mv	a0,s1
    80002d32:	70a2                	ld	ra,40(sp)
    80002d34:	7402                	ld	s0,32(sp)
    80002d36:	64e2                	ld	s1,24(sp)
    80002d38:	6145                	add	sp,sp,48
    80002d3a:	8082                	ret
    return -1;
    80002d3c:	54fd                	li	s1,-1
    80002d3e:	bfcd                	j	80002d30 <sys_sbrk+0x32>

0000000080002d40 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d40:	7139                	add	sp,sp,-64
    80002d42:	fc06                	sd	ra,56(sp)
    80002d44:	f822                	sd	s0,48(sp)
    80002d46:	f426                	sd	s1,40(sp)
    80002d48:	f04a                	sd	s2,32(sp)
    80002d4a:	ec4e                	sd	s3,24(sp)
    80002d4c:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d4e:	fcc40593          	add	a1,s0,-52
    80002d52:	4501                	li	a0,0
    80002d54:	00000097          	auipc	ra,0x0
    80002d58:	e3e080e7          	jalr	-450(ra) # 80002b92 <argint>
  acquire(&tickslock);
    80002d5c:	0018b517          	auipc	a0,0x18b
    80002d60:	1e450513          	add	a0,a0,484 # 8018df40 <tickslock>
    80002d64:	ffffe097          	auipc	ra,0xffffe
    80002d68:	e6e080e7          	jalr	-402(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002d6c:	00006917          	auipc	s2,0x6
    80002d70:	d3492903          	lw	s2,-716(s2) # 80008aa0 <ticks>
  while(ticks - ticks0 < n){
    80002d74:	fcc42783          	lw	a5,-52(s0)
    80002d78:	cf9d                	beqz	a5,80002db6 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002d7a:	0018b997          	auipc	s3,0x18b
    80002d7e:	1c698993          	add	s3,s3,454 # 8018df40 <tickslock>
    80002d82:	00006497          	auipc	s1,0x6
    80002d86:	d1e48493          	add	s1,s1,-738 # 80008aa0 <ticks>
    if(killed(myproc())){
    80002d8a:	fffff097          	auipc	ra,0xfffff
    80002d8e:	c58080e7          	jalr	-936(ra) # 800019e2 <myproc>
    80002d92:	fffff097          	auipc	ra,0xfffff
    80002d96:	61c080e7          	jalr	1564(ra) # 800023ae <killed>
    80002d9a:	ed15                	bnez	a0,80002dd6 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002d9c:	85ce                	mv	a1,s3
    80002d9e:	8526                	mv	a0,s1
    80002da0:	fffff097          	auipc	ra,0xfffff
    80002da4:	34e080e7          	jalr	846(ra) # 800020ee <sleep>
  while(ticks - ticks0 < n){
    80002da8:	409c                	lw	a5,0(s1)
    80002daa:	412787bb          	subw	a5,a5,s2
    80002dae:	fcc42703          	lw	a4,-52(s0)
    80002db2:	fce7ece3          	bltu	a5,a4,80002d8a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002db6:	0018b517          	auipc	a0,0x18b
    80002dba:	18a50513          	add	a0,a0,394 # 8018df40 <tickslock>
    80002dbe:	ffffe097          	auipc	ra,0xffffe
    80002dc2:	ec8080e7          	jalr	-312(ra) # 80000c86 <release>
  return 0;
    80002dc6:	4501                	li	a0,0
}
    80002dc8:	70e2                	ld	ra,56(sp)
    80002dca:	7442                	ld	s0,48(sp)
    80002dcc:	74a2                	ld	s1,40(sp)
    80002dce:	7902                	ld	s2,32(sp)
    80002dd0:	69e2                	ld	s3,24(sp)
    80002dd2:	6121                	add	sp,sp,64
    80002dd4:	8082                	ret
      release(&tickslock);
    80002dd6:	0018b517          	auipc	a0,0x18b
    80002dda:	16a50513          	add	a0,a0,362 # 8018df40 <tickslock>
    80002dde:	ffffe097          	auipc	ra,0xffffe
    80002de2:	ea8080e7          	jalr	-344(ra) # 80000c86 <release>
      return -1;
    80002de6:	557d                	li	a0,-1
    80002de8:	b7c5                	j	80002dc8 <sys_sleep+0x88>

0000000080002dea <sys_kill>:

uint64
sys_kill(void)
{
    80002dea:	1101                	add	sp,sp,-32
    80002dec:	ec06                	sd	ra,24(sp)
    80002dee:	e822                	sd	s0,16(sp)
    80002df0:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002df2:	fec40593          	add	a1,s0,-20
    80002df6:	4501                	li	a0,0
    80002df8:	00000097          	auipc	ra,0x0
    80002dfc:	d9a080e7          	jalr	-614(ra) # 80002b92 <argint>
  return kill(pid);
    80002e00:	fec42503          	lw	a0,-20(s0)
    80002e04:	fffff097          	auipc	ra,0xfffff
    80002e08:	504080e7          	jalr	1284(ra) # 80002308 <kill>
}
    80002e0c:	60e2                	ld	ra,24(sp)
    80002e0e:	6442                	ld	s0,16(sp)
    80002e10:	6105                	add	sp,sp,32
    80002e12:	8082                	ret

0000000080002e14 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e14:	1101                	add	sp,sp,-32
    80002e16:	ec06                	sd	ra,24(sp)
    80002e18:	e822                	sd	s0,16(sp)
    80002e1a:	e426                	sd	s1,8(sp)
    80002e1c:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e1e:	0018b517          	auipc	a0,0x18b
    80002e22:	12250513          	add	a0,a0,290 # 8018df40 <tickslock>
    80002e26:	ffffe097          	auipc	ra,0xffffe
    80002e2a:	dac080e7          	jalr	-596(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e2e:	00006497          	auipc	s1,0x6
    80002e32:	c724a483          	lw	s1,-910(s1) # 80008aa0 <ticks>
  release(&tickslock);
    80002e36:	0018b517          	auipc	a0,0x18b
    80002e3a:	10a50513          	add	a0,a0,266 # 8018df40 <tickslock>
    80002e3e:	ffffe097          	auipc	ra,0xffffe
    80002e42:	e48080e7          	jalr	-440(ra) # 80000c86 <release>
  return xticks;
}
    80002e46:	02049513          	sll	a0,s1,0x20
    80002e4a:	9101                	srl	a0,a0,0x20
    80002e4c:	60e2                	ld	ra,24(sp)
    80002e4e:	6442                	ld	s0,16(sp)
    80002e50:	64a2                	ld	s1,8(sp)
    80002e52:	6105                	add	sp,sp,32
    80002e54:	8082                	ret

0000000080002e56 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002e56:	7179                	add	sp,sp,-48
    80002e58:	f406                	sd	ra,40(sp)
    80002e5a:	f022                	sd	s0,32(sp)
    80002e5c:	ec26                	sd	s1,24(sp)
    80002e5e:	e84a                	sd	s2,16(sp)
    80002e60:	e44e                	sd	s3,8(sp)
    80002e62:	e052                	sd	s4,0(sp)
    80002e64:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002e66:	00005597          	auipc	a1,0x5
    80002e6a:	6c258593          	add	a1,a1,1730 # 80008528 <syscalls+0xb0>
    80002e6e:	0018b517          	auipc	a0,0x18b
    80002e72:	0ea50513          	add	a0,a0,234 # 8018df58 <bcache>
    80002e76:	ffffe097          	auipc	ra,0xffffe
    80002e7a:	ccc080e7          	jalr	-820(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002e7e:	00193797          	auipc	a5,0x193
    80002e82:	0da78793          	add	a5,a5,218 # 80195f58 <bcache+0x8000>
    80002e86:	00193717          	auipc	a4,0x193
    80002e8a:	33a70713          	add	a4,a4,826 # 801961c0 <bcache+0x8268>
    80002e8e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002e92:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002e96:	0018b497          	auipc	s1,0x18b
    80002e9a:	0da48493          	add	s1,s1,218 # 8018df70 <bcache+0x18>
    b->next = bcache.head.next;
    80002e9e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002ea0:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002ea2:	00005a17          	auipc	s4,0x5
    80002ea6:	68ea0a13          	add	s4,s4,1678 # 80008530 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002eaa:	2b893783          	ld	a5,696(s2)
    80002eae:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002eb0:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002eb4:	85d2                	mv	a1,s4
    80002eb6:	01048513          	add	a0,s1,16
    80002eba:	00001097          	auipc	ra,0x1
    80002ebe:	496080e7          	jalr	1174(ra) # 80004350 <initsleeplock>
    bcache.head.next->prev = b;
    80002ec2:	2b893783          	ld	a5,696(s2)
    80002ec6:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002ec8:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ecc:	45848493          	add	s1,s1,1112
    80002ed0:	fd349de3          	bne	s1,s3,80002eaa <binit+0x54>
  }
}
    80002ed4:	70a2                	ld	ra,40(sp)
    80002ed6:	7402                	ld	s0,32(sp)
    80002ed8:	64e2                	ld	s1,24(sp)
    80002eda:	6942                	ld	s2,16(sp)
    80002edc:	69a2                	ld	s3,8(sp)
    80002ede:	6a02                	ld	s4,0(sp)
    80002ee0:	6145                	add	sp,sp,48
    80002ee2:	8082                	ret

0000000080002ee4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002ee4:	7179                	add	sp,sp,-48
    80002ee6:	f406                	sd	ra,40(sp)
    80002ee8:	f022                	sd	s0,32(sp)
    80002eea:	ec26                	sd	s1,24(sp)
    80002eec:	e84a                	sd	s2,16(sp)
    80002eee:	e44e                	sd	s3,8(sp)
    80002ef0:	1800                	add	s0,sp,48
    80002ef2:	892a                	mv	s2,a0
    80002ef4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002ef6:	0018b517          	auipc	a0,0x18b
    80002efa:	06250513          	add	a0,a0,98 # 8018df58 <bcache>
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	cd4080e7          	jalr	-812(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f06:	00193497          	auipc	s1,0x193
    80002f0a:	30a4b483          	ld	s1,778(s1) # 80196210 <bcache+0x82b8>
    80002f0e:	00193797          	auipc	a5,0x193
    80002f12:	2b278793          	add	a5,a5,690 # 801961c0 <bcache+0x8268>
    80002f16:	02f48f63          	beq	s1,a5,80002f54 <bread+0x70>
    80002f1a:	873e                	mv	a4,a5
    80002f1c:	a021                	j	80002f24 <bread+0x40>
    80002f1e:	68a4                	ld	s1,80(s1)
    80002f20:	02e48a63          	beq	s1,a4,80002f54 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f24:	449c                	lw	a5,8(s1)
    80002f26:	ff279ce3          	bne	a5,s2,80002f1e <bread+0x3a>
    80002f2a:	44dc                	lw	a5,12(s1)
    80002f2c:	ff3799e3          	bne	a5,s3,80002f1e <bread+0x3a>
      b->refcnt++;
    80002f30:	40bc                	lw	a5,64(s1)
    80002f32:	2785                	addw	a5,a5,1
    80002f34:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f36:	0018b517          	auipc	a0,0x18b
    80002f3a:	02250513          	add	a0,a0,34 # 8018df58 <bcache>
    80002f3e:	ffffe097          	auipc	ra,0xffffe
    80002f42:	d48080e7          	jalr	-696(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f46:	01048513          	add	a0,s1,16
    80002f4a:	00001097          	auipc	ra,0x1
    80002f4e:	440080e7          	jalr	1088(ra) # 8000438a <acquiresleep>
      return b;
    80002f52:	a8b9                	j	80002fb0 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f54:	00193497          	auipc	s1,0x193
    80002f58:	2b44b483          	ld	s1,692(s1) # 80196208 <bcache+0x82b0>
    80002f5c:	00193797          	auipc	a5,0x193
    80002f60:	26478793          	add	a5,a5,612 # 801961c0 <bcache+0x8268>
    80002f64:	00f48863          	beq	s1,a5,80002f74 <bread+0x90>
    80002f68:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002f6a:	40bc                	lw	a5,64(s1)
    80002f6c:	cf81                	beqz	a5,80002f84 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f6e:	64a4                	ld	s1,72(s1)
    80002f70:	fee49de3          	bne	s1,a4,80002f6a <bread+0x86>
  panic("bget: no buffers");
    80002f74:	00005517          	auipc	a0,0x5
    80002f78:	5c450513          	add	a0,a0,1476 # 80008538 <syscalls+0xc0>
    80002f7c:	ffffd097          	auipc	ra,0xffffd
    80002f80:	5c0080e7          	jalr	1472(ra) # 8000053c <panic>
      b->dev = dev;
    80002f84:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002f88:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002f8c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002f90:	4785                	li	a5,1
    80002f92:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f94:	0018b517          	auipc	a0,0x18b
    80002f98:	fc450513          	add	a0,a0,-60 # 8018df58 <bcache>
    80002f9c:	ffffe097          	auipc	ra,0xffffe
    80002fa0:	cea080e7          	jalr	-790(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fa4:	01048513          	add	a0,s1,16
    80002fa8:	00001097          	auipc	ra,0x1
    80002fac:	3e2080e7          	jalr	994(ra) # 8000438a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002fb0:	409c                	lw	a5,0(s1)
    80002fb2:	cb89                	beqz	a5,80002fc4 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002fb4:	8526                	mv	a0,s1
    80002fb6:	70a2                	ld	ra,40(sp)
    80002fb8:	7402                	ld	s0,32(sp)
    80002fba:	64e2                	ld	s1,24(sp)
    80002fbc:	6942                	ld	s2,16(sp)
    80002fbe:	69a2                	ld	s3,8(sp)
    80002fc0:	6145                	add	sp,sp,48
    80002fc2:	8082                	ret
    virtio_disk_rw(b, 0);
    80002fc4:	4581                	li	a1,0
    80002fc6:	8526                	mv	a0,s1
    80002fc8:	00003097          	auipc	ra,0x3
    80002fcc:	ffa080e7          	jalr	-6(ra) # 80005fc2 <virtio_disk_rw>
    b->valid = 1;
    80002fd0:	4785                	li	a5,1
    80002fd2:	c09c                	sw	a5,0(s1)
  return b;
    80002fd4:	b7c5                	j	80002fb4 <bread+0xd0>

0000000080002fd6 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002fd6:	1101                	add	sp,sp,-32
    80002fd8:	ec06                	sd	ra,24(sp)
    80002fda:	e822                	sd	s0,16(sp)
    80002fdc:	e426                	sd	s1,8(sp)
    80002fde:	1000                	add	s0,sp,32
    80002fe0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002fe2:	0541                	add	a0,a0,16
    80002fe4:	00001097          	auipc	ra,0x1
    80002fe8:	440080e7          	jalr	1088(ra) # 80004424 <holdingsleep>
    80002fec:	cd01                	beqz	a0,80003004 <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    80002fee:	4585                	li	a1,1
    80002ff0:	8526                	mv	a0,s1
    80002ff2:	00003097          	auipc	ra,0x3
    80002ff6:	fd0080e7          	jalr	-48(ra) # 80005fc2 <virtio_disk_rw>
}
    80002ffa:	60e2                	ld	ra,24(sp)
    80002ffc:	6442                	ld	s0,16(sp)
    80002ffe:	64a2                	ld	s1,8(sp)
    80003000:	6105                	add	sp,sp,32
    80003002:	8082                	ret
    panic("bwrite");
    80003004:	00005517          	auipc	a0,0x5
    80003008:	54c50513          	add	a0,a0,1356 # 80008550 <syscalls+0xd8>
    8000300c:	ffffd097          	auipc	ra,0xffffd
    80003010:	530080e7          	jalr	1328(ra) # 8000053c <panic>

0000000080003014 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003014:	1101                	add	sp,sp,-32
    80003016:	ec06                	sd	ra,24(sp)
    80003018:	e822                	sd	s0,16(sp)
    8000301a:	e426                	sd	s1,8(sp)
    8000301c:	e04a                	sd	s2,0(sp)
    8000301e:	1000                	add	s0,sp,32
    80003020:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003022:	01050913          	add	s2,a0,16
    80003026:	854a                	mv	a0,s2
    80003028:	00001097          	auipc	ra,0x1
    8000302c:	3fc080e7          	jalr	1020(ra) # 80004424 <holdingsleep>
    80003030:	c925                	beqz	a0,800030a0 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80003032:	854a                	mv	a0,s2
    80003034:	00001097          	auipc	ra,0x1
    80003038:	3ac080e7          	jalr	940(ra) # 800043e0 <releasesleep>

  acquire(&bcache.lock);
    8000303c:	0018b517          	auipc	a0,0x18b
    80003040:	f1c50513          	add	a0,a0,-228 # 8018df58 <bcache>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	b8e080e7          	jalr	-1138(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000304c:	40bc                	lw	a5,64(s1)
    8000304e:	37fd                	addw	a5,a5,-1
    80003050:	0007871b          	sext.w	a4,a5
    80003054:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003056:	e71d                	bnez	a4,80003084 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003058:	68b8                	ld	a4,80(s1)
    8000305a:	64bc                	ld	a5,72(s1)
    8000305c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000305e:	68b8                	ld	a4,80(s1)
    80003060:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003062:	00193797          	auipc	a5,0x193
    80003066:	ef678793          	add	a5,a5,-266 # 80195f58 <bcache+0x8000>
    8000306a:	2b87b703          	ld	a4,696(a5)
    8000306e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003070:	00193717          	auipc	a4,0x193
    80003074:	15070713          	add	a4,a4,336 # 801961c0 <bcache+0x8268>
    80003078:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000307a:	2b87b703          	ld	a4,696(a5)
    8000307e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003080:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003084:	0018b517          	auipc	a0,0x18b
    80003088:	ed450513          	add	a0,a0,-300 # 8018df58 <bcache>
    8000308c:	ffffe097          	auipc	ra,0xffffe
    80003090:	bfa080e7          	jalr	-1030(ra) # 80000c86 <release>
}
    80003094:	60e2                	ld	ra,24(sp)
    80003096:	6442                	ld	s0,16(sp)
    80003098:	64a2                	ld	s1,8(sp)
    8000309a:	6902                	ld	s2,0(sp)
    8000309c:	6105                	add	sp,sp,32
    8000309e:	8082                	ret
    panic("brelse");
    800030a0:	00005517          	auipc	a0,0x5
    800030a4:	4b850513          	add	a0,a0,1208 # 80008558 <syscalls+0xe0>
    800030a8:	ffffd097          	auipc	ra,0xffffd
    800030ac:	494080e7          	jalr	1172(ra) # 8000053c <panic>

00000000800030b0 <bpin>:

void
bpin(struct buf *b) {
    800030b0:	1101                	add	sp,sp,-32
    800030b2:	ec06                	sd	ra,24(sp)
    800030b4:	e822                	sd	s0,16(sp)
    800030b6:	e426                	sd	s1,8(sp)
    800030b8:	1000                	add	s0,sp,32
    800030ba:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030bc:	0018b517          	auipc	a0,0x18b
    800030c0:	e9c50513          	add	a0,a0,-356 # 8018df58 <bcache>
    800030c4:	ffffe097          	auipc	ra,0xffffe
    800030c8:	b0e080e7          	jalr	-1266(ra) # 80000bd2 <acquire>
  b->refcnt++;
    800030cc:	40bc                	lw	a5,64(s1)
    800030ce:	2785                	addw	a5,a5,1
    800030d0:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800030d2:	0018b517          	auipc	a0,0x18b
    800030d6:	e8650513          	add	a0,a0,-378 # 8018df58 <bcache>
    800030da:	ffffe097          	auipc	ra,0xffffe
    800030de:	bac080e7          	jalr	-1108(ra) # 80000c86 <release>
}
    800030e2:	60e2                	ld	ra,24(sp)
    800030e4:	6442                	ld	s0,16(sp)
    800030e6:	64a2                	ld	s1,8(sp)
    800030e8:	6105                	add	sp,sp,32
    800030ea:	8082                	ret

00000000800030ec <bunpin>:

void
bunpin(struct buf *b) {
    800030ec:	1101                	add	sp,sp,-32
    800030ee:	ec06                	sd	ra,24(sp)
    800030f0:	e822                	sd	s0,16(sp)
    800030f2:	e426                	sd	s1,8(sp)
    800030f4:	1000                	add	s0,sp,32
    800030f6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800030f8:	0018b517          	auipc	a0,0x18b
    800030fc:	e6050513          	add	a0,a0,-416 # 8018df58 <bcache>
    80003100:	ffffe097          	auipc	ra,0xffffe
    80003104:	ad2080e7          	jalr	-1326(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003108:	40bc                	lw	a5,64(s1)
    8000310a:	37fd                	addw	a5,a5,-1
    8000310c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000310e:	0018b517          	auipc	a0,0x18b
    80003112:	e4a50513          	add	a0,a0,-438 # 8018df58 <bcache>
    80003116:	ffffe097          	auipc	ra,0xffffe
    8000311a:	b70080e7          	jalr	-1168(ra) # 80000c86 <release>
}
    8000311e:	60e2                	ld	ra,24(sp)
    80003120:	6442                	ld	s0,16(sp)
    80003122:	64a2                	ld	s1,8(sp)
    80003124:	6105                	add	sp,sp,32
    80003126:	8082                	ret

0000000080003128 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003128:	1101                	add	sp,sp,-32
    8000312a:	ec06                	sd	ra,24(sp)
    8000312c:	e822                	sd	s0,16(sp)
    8000312e:	e426                	sd	s1,8(sp)
    80003130:	e04a                	sd	s2,0(sp)
    80003132:	1000                	add	s0,sp,32
    80003134:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003136:	00d5d59b          	srlw	a1,a1,0xd
    8000313a:	00193797          	auipc	a5,0x193
    8000313e:	4fa7a783          	lw	a5,1274(a5) # 80196634 <sb+0x1c>
    80003142:	9dbd                	addw	a1,a1,a5
    80003144:	00000097          	auipc	ra,0x0
    80003148:	da0080e7          	jalr	-608(ra) # 80002ee4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000314c:	0074f713          	and	a4,s1,7
    80003150:	4785                	li	a5,1
    80003152:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003156:	14ce                	sll	s1,s1,0x33
    80003158:	90d9                	srl	s1,s1,0x36
    8000315a:	00950733          	add	a4,a0,s1
    8000315e:	05874703          	lbu	a4,88(a4)
    80003162:	00e7f6b3          	and	a3,a5,a4
    80003166:	c69d                	beqz	a3,80003194 <bfree+0x6c>
    80003168:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000316a:	94aa                	add	s1,s1,a0
    8000316c:	fff7c793          	not	a5,a5
    80003170:	8f7d                	and	a4,a4,a5
    80003172:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003176:	00001097          	auipc	ra,0x1
    8000317a:	0f6080e7          	jalr	246(ra) # 8000426c <log_write>
  brelse(bp);
    8000317e:	854a                	mv	a0,s2
    80003180:	00000097          	auipc	ra,0x0
    80003184:	e94080e7          	jalr	-364(ra) # 80003014 <brelse>
}
    80003188:	60e2                	ld	ra,24(sp)
    8000318a:	6442                	ld	s0,16(sp)
    8000318c:	64a2                	ld	s1,8(sp)
    8000318e:	6902                	ld	s2,0(sp)
    80003190:	6105                	add	sp,sp,32
    80003192:	8082                	ret
    panic("freeing free block");
    80003194:	00005517          	auipc	a0,0x5
    80003198:	3cc50513          	add	a0,a0,972 # 80008560 <syscalls+0xe8>
    8000319c:	ffffd097          	auipc	ra,0xffffd
    800031a0:	3a0080e7          	jalr	928(ra) # 8000053c <panic>

00000000800031a4 <balloc>:
{
    800031a4:	711d                	add	sp,sp,-96
    800031a6:	ec86                	sd	ra,88(sp)
    800031a8:	e8a2                	sd	s0,80(sp)
    800031aa:	e4a6                	sd	s1,72(sp)
    800031ac:	e0ca                	sd	s2,64(sp)
    800031ae:	fc4e                	sd	s3,56(sp)
    800031b0:	f852                	sd	s4,48(sp)
    800031b2:	f456                	sd	s5,40(sp)
    800031b4:	f05a                	sd	s6,32(sp)
    800031b6:	ec5e                	sd	s7,24(sp)
    800031b8:	e862                	sd	s8,16(sp)
    800031ba:	e466                	sd	s9,8(sp)
    800031bc:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800031be:	00193797          	auipc	a5,0x193
    800031c2:	45e7a783          	lw	a5,1118(a5) # 8019661c <sb+0x4>
    800031c6:	cff5                	beqz	a5,800032c2 <balloc+0x11e>
    800031c8:	8baa                	mv	s7,a0
    800031ca:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800031cc:	00193b17          	auipc	s6,0x193
    800031d0:	44cb0b13          	add	s6,s6,1100 # 80196618 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d4:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800031d6:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031d8:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800031da:	6c89                	lui	s9,0x2
    800031dc:	a061                	j	80003264 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    800031de:	97ca                	add	a5,a5,s2
    800031e0:	8e55                	or	a2,a2,a3
    800031e2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800031e6:	854a                	mv	a0,s2
    800031e8:	00001097          	auipc	ra,0x1
    800031ec:	084080e7          	jalr	132(ra) # 8000426c <log_write>
        brelse(bp);
    800031f0:	854a                	mv	a0,s2
    800031f2:	00000097          	auipc	ra,0x0
    800031f6:	e22080e7          	jalr	-478(ra) # 80003014 <brelse>
  bp = bread(dev, bno);
    800031fa:	85a6                	mv	a1,s1
    800031fc:	855e                	mv	a0,s7
    800031fe:	00000097          	auipc	ra,0x0
    80003202:	ce6080e7          	jalr	-794(ra) # 80002ee4 <bread>
    80003206:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003208:	40000613          	li	a2,1024
    8000320c:	4581                	li	a1,0
    8000320e:	05850513          	add	a0,a0,88
    80003212:	ffffe097          	auipc	ra,0xffffe
    80003216:	abc080e7          	jalr	-1348(ra) # 80000cce <memset>
  log_write(bp);
    8000321a:	854a                	mv	a0,s2
    8000321c:	00001097          	auipc	ra,0x1
    80003220:	050080e7          	jalr	80(ra) # 8000426c <log_write>
  brelse(bp);
    80003224:	854a                	mv	a0,s2
    80003226:	00000097          	auipc	ra,0x0
    8000322a:	dee080e7          	jalr	-530(ra) # 80003014 <brelse>
}
    8000322e:	8526                	mv	a0,s1
    80003230:	60e6                	ld	ra,88(sp)
    80003232:	6446                	ld	s0,80(sp)
    80003234:	64a6                	ld	s1,72(sp)
    80003236:	6906                	ld	s2,64(sp)
    80003238:	79e2                	ld	s3,56(sp)
    8000323a:	7a42                	ld	s4,48(sp)
    8000323c:	7aa2                	ld	s5,40(sp)
    8000323e:	7b02                	ld	s6,32(sp)
    80003240:	6be2                	ld	s7,24(sp)
    80003242:	6c42                	ld	s8,16(sp)
    80003244:	6ca2                	ld	s9,8(sp)
    80003246:	6125                	add	sp,sp,96
    80003248:	8082                	ret
    brelse(bp);
    8000324a:	854a                	mv	a0,s2
    8000324c:	00000097          	auipc	ra,0x0
    80003250:	dc8080e7          	jalr	-568(ra) # 80003014 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003254:	015c87bb          	addw	a5,s9,s5
    80003258:	00078a9b          	sext.w	s5,a5
    8000325c:	004b2703          	lw	a4,4(s6)
    80003260:	06eaf163          	bgeu	s5,a4,800032c2 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003264:	41fad79b          	sraw	a5,s5,0x1f
    80003268:	0137d79b          	srlw	a5,a5,0x13
    8000326c:	015787bb          	addw	a5,a5,s5
    80003270:	40d7d79b          	sraw	a5,a5,0xd
    80003274:	01cb2583          	lw	a1,28(s6)
    80003278:	9dbd                	addw	a1,a1,a5
    8000327a:	855e                	mv	a0,s7
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	c68080e7          	jalr	-920(ra) # 80002ee4 <bread>
    80003284:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003286:	004b2503          	lw	a0,4(s6)
    8000328a:	000a849b          	sext.w	s1,s5
    8000328e:	8762                	mv	a4,s8
    80003290:	faa4fde3          	bgeu	s1,a0,8000324a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003294:	00777693          	and	a3,a4,7
    80003298:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000329c:	41f7579b          	sraw	a5,a4,0x1f
    800032a0:	01d7d79b          	srlw	a5,a5,0x1d
    800032a4:	9fb9                	addw	a5,a5,a4
    800032a6:	4037d79b          	sraw	a5,a5,0x3
    800032aa:	00f90633          	add	a2,s2,a5
    800032ae:	05864603          	lbu	a2,88(a2)
    800032b2:	00c6f5b3          	and	a1,a3,a2
    800032b6:	d585                	beqz	a1,800031de <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032b8:	2705                	addw	a4,a4,1
    800032ba:	2485                	addw	s1,s1,1
    800032bc:	fd471ae3          	bne	a4,s4,80003290 <balloc+0xec>
    800032c0:	b769                	j	8000324a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800032c2:	00005517          	auipc	a0,0x5
    800032c6:	2b650513          	add	a0,a0,694 # 80008578 <syscalls+0x100>
    800032ca:	ffffd097          	auipc	ra,0xffffd
    800032ce:	2bc080e7          	jalr	700(ra) # 80000586 <printf>
  return 0;
    800032d2:	4481                	li	s1,0
    800032d4:	bfa9                	j	8000322e <balloc+0x8a>

00000000800032d6 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800032d6:	7179                	add	sp,sp,-48
    800032d8:	f406                	sd	ra,40(sp)
    800032da:	f022                	sd	s0,32(sp)
    800032dc:	ec26                	sd	s1,24(sp)
    800032de:	e84a                	sd	s2,16(sp)
    800032e0:	e44e                	sd	s3,8(sp)
    800032e2:	e052                	sd	s4,0(sp)
    800032e4:	1800                	add	s0,sp,48
    800032e6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800032e8:	47ad                	li	a5,11
    800032ea:	02b7e863          	bltu	a5,a1,8000331a <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800032ee:	02059793          	sll	a5,a1,0x20
    800032f2:	01e7d593          	srl	a1,a5,0x1e
    800032f6:	00b504b3          	add	s1,a0,a1
    800032fa:	0504a903          	lw	s2,80(s1)
    800032fe:	06091e63          	bnez	s2,8000337a <bmap+0xa4>
      addr = balloc(ip->dev);
    80003302:	4108                	lw	a0,0(a0)
    80003304:	00000097          	auipc	ra,0x0
    80003308:	ea0080e7          	jalr	-352(ra) # 800031a4 <balloc>
    8000330c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003310:	06090563          	beqz	s2,8000337a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003314:	0524a823          	sw	s2,80(s1)
    80003318:	a08d                	j	8000337a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000331a:	ff45849b          	addw	s1,a1,-12
    8000331e:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003322:	0ff00793          	li	a5,255
    80003326:	08e7e563          	bltu	a5,a4,800033b0 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000332a:	08052903          	lw	s2,128(a0)
    8000332e:	00091d63          	bnez	s2,80003348 <bmap+0x72>
      addr = balloc(ip->dev);
    80003332:	4108                	lw	a0,0(a0)
    80003334:	00000097          	auipc	ra,0x0
    80003338:	e70080e7          	jalr	-400(ra) # 800031a4 <balloc>
    8000333c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003340:	02090d63          	beqz	s2,8000337a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003344:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003348:	85ca                	mv	a1,s2
    8000334a:	0009a503          	lw	a0,0(s3)
    8000334e:	00000097          	auipc	ra,0x0
    80003352:	b96080e7          	jalr	-1130(ra) # 80002ee4 <bread>
    80003356:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003358:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    8000335c:	02049713          	sll	a4,s1,0x20
    80003360:	01e75593          	srl	a1,a4,0x1e
    80003364:	00b784b3          	add	s1,a5,a1
    80003368:	0004a903          	lw	s2,0(s1)
    8000336c:	02090063          	beqz	s2,8000338c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003370:	8552                	mv	a0,s4
    80003372:	00000097          	auipc	ra,0x0
    80003376:	ca2080e7          	jalr	-862(ra) # 80003014 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000337a:	854a                	mv	a0,s2
    8000337c:	70a2                	ld	ra,40(sp)
    8000337e:	7402                	ld	s0,32(sp)
    80003380:	64e2                	ld	s1,24(sp)
    80003382:	6942                	ld	s2,16(sp)
    80003384:	69a2                	ld	s3,8(sp)
    80003386:	6a02                	ld	s4,0(sp)
    80003388:	6145                	add	sp,sp,48
    8000338a:	8082                	ret
      addr = balloc(ip->dev);
    8000338c:	0009a503          	lw	a0,0(s3)
    80003390:	00000097          	auipc	ra,0x0
    80003394:	e14080e7          	jalr	-492(ra) # 800031a4 <balloc>
    80003398:	0005091b          	sext.w	s2,a0
      if(addr){
    8000339c:	fc090ae3          	beqz	s2,80003370 <bmap+0x9a>
        a[bn] = addr;
    800033a0:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033a4:	8552                	mv	a0,s4
    800033a6:	00001097          	auipc	ra,0x1
    800033aa:	ec6080e7          	jalr	-314(ra) # 8000426c <log_write>
    800033ae:	b7c9                	j	80003370 <bmap+0x9a>
  panic("bmap: out of range");
    800033b0:	00005517          	auipc	a0,0x5
    800033b4:	1e050513          	add	a0,a0,480 # 80008590 <syscalls+0x118>
    800033b8:	ffffd097          	auipc	ra,0xffffd
    800033bc:	184080e7          	jalr	388(ra) # 8000053c <panic>

00000000800033c0 <iget>:
{
    800033c0:	7179                	add	sp,sp,-48
    800033c2:	f406                	sd	ra,40(sp)
    800033c4:	f022                	sd	s0,32(sp)
    800033c6:	ec26                	sd	s1,24(sp)
    800033c8:	e84a                	sd	s2,16(sp)
    800033ca:	e44e                	sd	s3,8(sp)
    800033cc:	e052                	sd	s4,0(sp)
    800033ce:	1800                	add	s0,sp,48
    800033d0:	89aa                	mv	s3,a0
    800033d2:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800033d4:	00193517          	auipc	a0,0x193
    800033d8:	26c50513          	add	a0,a0,620 # 80196640 <itable>
    800033dc:	ffffd097          	auipc	ra,0xffffd
    800033e0:	7f6080e7          	jalr	2038(ra) # 80000bd2 <acquire>
  empty = 0;
    800033e4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033e6:	00193497          	auipc	s1,0x193
    800033ea:	27248493          	add	s1,s1,626 # 80196658 <itable+0x18>
    800033ee:	00195697          	auipc	a3,0x195
    800033f2:	cfa68693          	add	a3,a3,-774 # 801980e8 <log>
    800033f6:	a039                	j	80003404 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800033f8:	02090b63          	beqz	s2,8000342e <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800033fc:	08848493          	add	s1,s1,136
    80003400:	02d48a63          	beq	s1,a3,80003434 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003404:	449c                	lw	a5,8(s1)
    80003406:	fef059e3          	blez	a5,800033f8 <iget+0x38>
    8000340a:	4098                	lw	a4,0(s1)
    8000340c:	ff3716e3          	bne	a4,s3,800033f8 <iget+0x38>
    80003410:	40d8                	lw	a4,4(s1)
    80003412:	ff4713e3          	bne	a4,s4,800033f8 <iget+0x38>
      ip->ref++;
    80003416:	2785                	addw	a5,a5,1
    80003418:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000341a:	00193517          	auipc	a0,0x193
    8000341e:	22650513          	add	a0,a0,550 # 80196640 <itable>
    80003422:	ffffe097          	auipc	ra,0xffffe
    80003426:	864080e7          	jalr	-1948(ra) # 80000c86 <release>
      return ip;
    8000342a:	8926                	mv	s2,s1
    8000342c:	a03d                	j	8000345a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000342e:	f7f9                	bnez	a5,800033fc <iget+0x3c>
    80003430:	8926                	mv	s2,s1
    80003432:	b7e9                	j	800033fc <iget+0x3c>
  if(empty == 0)
    80003434:	02090c63          	beqz	s2,8000346c <iget+0xac>
  ip->dev = dev;
    80003438:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000343c:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003440:	4785                	li	a5,1
    80003442:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003446:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000344a:	00193517          	auipc	a0,0x193
    8000344e:	1f650513          	add	a0,a0,502 # 80196640 <itable>
    80003452:	ffffe097          	auipc	ra,0xffffe
    80003456:	834080e7          	jalr	-1996(ra) # 80000c86 <release>
}
    8000345a:	854a                	mv	a0,s2
    8000345c:	70a2                	ld	ra,40(sp)
    8000345e:	7402                	ld	s0,32(sp)
    80003460:	64e2                	ld	s1,24(sp)
    80003462:	6942                	ld	s2,16(sp)
    80003464:	69a2                	ld	s3,8(sp)
    80003466:	6a02                	ld	s4,0(sp)
    80003468:	6145                	add	sp,sp,48
    8000346a:	8082                	ret
    panic("iget: no inodes");
    8000346c:	00005517          	auipc	a0,0x5
    80003470:	13c50513          	add	a0,a0,316 # 800085a8 <syscalls+0x130>
    80003474:	ffffd097          	auipc	ra,0xffffd
    80003478:	0c8080e7          	jalr	200(ra) # 8000053c <panic>

000000008000347c <fsinit>:
fsinit(int dev) {
    8000347c:	7179                	add	sp,sp,-48
    8000347e:	f406                	sd	ra,40(sp)
    80003480:	f022                	sd	s0,32(sp)
    80003482:	ec26                	sd	s1,24(sp)
    80003484:	e84a                	sd	s2,16(sp)
    80003486:	e44e                	sd	s3,8(sp)
    80003488:	1800                	add	s0,sp,48
    8000348a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000348c:	4585                	li	a1,1
    8000348e:	00000097          	auipc	ra,0x0
    80003492:	a56080e7          	jalr	-1450(ra) # 80002ee4 <bread>
    80003496:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003498:	00193997          	auipc	s3,0x193
    8000349c:	18098993          	add	s3,s3,384 # 80196618 <sb>
    800034a0:	02800613          	li	a2,40
    800034a4:	05850593          	add	a1,a0,88
    800034a8:	854e                	mv	a0,s3
    800034aa:	ffffe097          	auipc	ra,0xffffe
    800034ae:	880080e7          	jalr	-1920(ra) # 80000d2a <memmove>
  brelse(bp);
    800034b2:	8526                	mv	a0,s1
    800034b4:	00000097          	auipc	ra,0x0
    800034b8:	b60080e7          	jalr	-1184(ra) # 80003014 <brelse>
  if(sb.magic != FSMAGIC)
    800034bc:	0009a703          	lw	a4,0(s3)
    800034c0:	102037b7          	lui	a5,0x10203
    800034c4:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800034c8:	02f71263          	bne	a4,a5,800034ec <fsinit+0x70>
  initlog(dev, &sb);
    800034cc:	00193597          	auipc	a1,0x193
    800034d0:	14c58593          	add	a1,a1,332 # 80196618 <sb>
    800034d4:	854a                	mv	a0,s2
    800034d6:	00001097          	auipc	ra,0x1
    800034da:	b2c080e7          	jalr	-1236(ra) # 80004002 <initlog>
}
    800034de:	70a2                	ld	ra,40(sp)
    800034e0:	7402                	ld	s0,32(sp)
    800034e2:	64e2                	ld	s1,24(sp)
    800034e4:	6942                	ld	s2,16(sp)
    800034e6:	69a2                	ld	s3,8(sp)
    800034e8:	6145                	add	sp,sp,48
    800034ea:	8082                	ret
    panic("invalid file system");
    800034ec:	00005517          	auipc	a0,0x5
    800034f0:	0cc50513          	add	a0,a0,204 # 800085b8 <syscalls+0x140>
    800034f4:	ffffd097          	auipc	ra,0xffffd
    800034f8:	048080e7          	jalr	72(ra) # 8000053c <panic>

00000000800034fc <iinit>:
{
    800034fc:	7179                	add	sp,sp,-48
    800034fe:	f406                	sd	ra,40(sp)
    80003500:	f022                	sd	s0,32(sp)
    80003502:	ec26                	sd	s1,24(sp)
    80003504:	e84a                	sd	s2,16(sp)
    80003506:	e44e                	sd	s3,8(sp)
    80003508:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    8000350a:	00005597          	auipc	a1,0x5
    8000350e:	0c658593          	add	a1,a1,198 # 800085d0 <syscalls+0x158>
    80003512:	00193517          	auipc	a0,0x193
    80003516:	12e50513          	add	a0,a0,302 # 80196640 <itable>
    8000351a:	ffffd097          	auipc	ra,0xffffd
    8000351e:	628080e7          	jalr	1576(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003522:	00193497          	auipc	s1,0x193
    80003526:	14648493          	add	s1,s1,326 # 80196668 <itable+0x28>
    8000352a:	00195997          	auipc	s3,0x195
    8000352e:	bce98993          	add	s3,s3,-1074 # 801980f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003532:	00005917          	auipc	s2,0x5
    80003536:	0a690913          	add	s2,s2,166 # 800085d8 <syscalls+0x160>
    8000353a:	85ca                	mv	a1,s2
    8000353c:	8526                	mv	a0,s1
    8000353e:	00001097          	auipc	ra,0x1
    80003542:	e12080e7          	jalr	-494(ra) # 80004350 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003546:	08848493          	add	s1,s1,136
    8000354a:	ff3498e3          	bne	s1,s3,8000353a <iinit+0x3e>
}
    8000354e:	70a2                	ld	ra,40(sp)
    80003550:	7402                	ld	s0,32(sp)
    80003552:	64e2                	ld	s1,24(sp)
    80003554:	6942                	ld	s2,16(sp)
    80003556:	69a2                	ld	s3,8(sp)
    80003558:	6145                	add	sp,sp,48
    8000355a:	8082                	ret

000000008000355c <ialloc>:
{
    8000355c:	7139                	add	sp,sp,-64
    8000355e:	fc06                	sd	ra,56(sp)
    80003560:	f822                	sd	s0,48(sp)
    80003562:	f426                	sd	s1,40(sp)
    80003564:	f04a                	sd	s2,32(sp)
    80003566:	ec4e                	sd	s3,24(sp)
    80003568:	e852                	sd	s4,16(sp)
    8000356a:	e456                	sd	s5,8(sp)
    8000356c:	e05a                	sd	s6,0(sp)
    8000356e:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003570:	00193717          	auipc	a4,0x193
    80003574:	0b472703          	lw	a4,180(a4) # 80196624 <sb+0xc>
    80003578:	4785                	li	a5,1
    8000357a:	04e7f863          	bgeu	a5,a4,800035ca <ialloc+0x6e>
    8000357e:	8aaa                	mv	s5,a0
    80003580:	8b2e                	mv	s6,a1
    80003582:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003584:	00193a17          	auipc	s4,0x193
    80003588:	094a0a13          	add	s4,s4,148 # 80196618 <sb>
    8000358c:	00495593          	srl	a1,s2,0x4
    80003590:	018a2783          	lw	a5,24(s4)
    80003594:	9dbd                	addw	a1,a1,a5
    80003596:	8556                	mv	a0,s5
    80003598:	00000097          	auipc	ra,0x0
    8000359c:	94c080e7          	jalr	-1716(ra) # 80002ee4 <bread>
    800035a0:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035a2:	05850993          	add	s3,a0,88
    800035a6:	00f97793          	and	a5,s2,15
    800035aa:	079a                	sll	a5,a5,0x6
    800035ac:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035ae:	00099783          	lh	a5,0(s3)
    800035b2:	cf9d                	beqz	a5,800035f0 <ialloc+0x94>
    brelse(bp);
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	a60080e7          	jalr	-1440(ra) # 80003014 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800035bc:	0905                	add	s2,s2,1
    800035be:	00ca2703          	lw	a4,12(s4)
    800035c2:	0009079b          	sext.w	a5,s2
    800035c6:	fce7e3e3          	bltu	a5,a4,8000358c <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800035ca:	00005517          	auipc	a0,0x5
    800035ce:	01650513          	add	a0,a0,22 # 800085e0 <syscalls+0x168>
    800035d2:	ffffd097          	auipc	ra,0xffffd
    800035d6:	fb4080e7          	jalr	-76(ra) # 80000586 <printf>
  return 0;
    800035da:	4501                	li	a0,0
}
    800035dc:	70e2                	ld	ra,56(sp)
    800035de:	7442                	ld	s0,48(sp)
    800035e0:	74a2                	ld	s1,40(sp)
    800035e2:	7902                	ld	s2,32(sp)
    800035e4:	69e2                	ld	s3,24(sp)
    800035e6:	6a42                	ld	s4,16(sp)
    800035e8:	6aa2                	ld	s5,8(sp)
    800035ea:	6b02                	ld	s6,0(sp)
    800035ec:	6121                	add	sp,sp,64
    800035ee:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800035f0:	04000613          	li	a2,64
    800035f4:	4581                	li	a1,0
    800035f6:	854e                	mv	a0,s3
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	6d6080e7          	jalr	1750(ra) # 80000cce <memset>
      dip->type = type;
    80003600:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003604:	8526                	mv	a0,s1
    80003606:	00001097          	auipc	ra,0x1
    8000360a:	c66080e7          	jalr	-922(ra) # 8000426c <log_write>
      brelse(bp);
    8000360e:	8526                	mv	a0,s1
    80003610:	00000097          	auipc	ra,0x0
    80003614:	a04080e7          	jalr	-1532(ra) # 80003014 <brelse>
      return iget(dev, inum);
    80003618:	0009059b          	sext.w	a1,s2
    8000361c:	8556                	mv	a0,s5
    8000361e:	00000097          	auipc	ra,0x0
    80003622:	da2080e7          	jalr	-606(ra) # 800033c0 <iget>
    80003626:	bf5d                	j	800035dc <ialloc+0x80>

0000000080003628 <iupdate>:
{
    80003628:	1101                	add	sp,sp,-32
    8000362a:	ec06                	sd	ra,24(sp)
    8000362c:	e822                	sd	s0,16(sp)
    8000362e:	e426                	sd	s1,8(sp)
    80003630:	e04a                	sd	s2,0(sp)
    80003632:	1000                	add	s0,sp,32
    80003634:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003636:	415c                	lw	a5,4(a0)
    80003638:	0047d79b          	srlw	a5,a5,0x4
    8000363c:	00193597          	auipc	a1,0x193
    80003640:	ff45a583          	lw	a1,-12(a1) # 80196630 <sb+0x18>
    80003644:	9dbd                	addw	a1,a1,a5
    80003646:	4108                	lw	a0,0(a0)
    80003648:	00000097          	auipc	ra,0x0
    8000364c:	89c080e7          	jalr	-1892(ra) # 80002ee4 <bread>
    80003650:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003652:	05850793          	add	a5,a0,88
    80003656:	40d8                	lw	a4,4(s1)
    80003658:	8b3d                	and	a4,a4,15
    8000365a:	071a                	sll	a4,a4,0x6
    8000365c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000365e:	04449703          	lh	a4,68(s1)
    80003662:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003666:	04649703          	lh	a4,70(s1)
    8000366a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000366e:	04849703          	lh	a4,72(s1)
    80003672:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003676:	04a49703          	lh	a4,74(s1)
    8000367a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000367e:	44f8                	lw	a4,76(s1)
    80003680:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003682:	03400613          	li	a2,52
    80003686:	05048593          	add	a1,s1,80
    8000368a:	00c78513          	add	a0,a5,12
    8000368e:	ffffd097          	auipc	ra,0xffffd
    80003692:	69c080e7          	jalr	1692(ra) # 80000d2a <memmove>
  log_write(bp);
    80003696:	854a                	mv	a0,s2
    80003698:	00001097          	auipc	ra,0x1
    8000369c:	bd4080e7          	jalr	-1068(ra) # 8000426c <log_write>
  brelse(bp);
    800036a0:	854a                	mv	a0,s2
    800036a2:	00000097          	auipc	ra,0x0
    800036a6:	972080e7          	jalr	-1678(ra) # 80003014 <brelse>
}
    800036aa:	60e2                	ld	ra,24(sp)
    800036ac:	6442                	ld	s0,16(sp)
    800036ae:	64a2                	ld	s1,8(sp)
    800036b0:	6902                	ld	s2,0(sp)
    800036b2:	6105                	add	sp,sp,32
    800036b4:	8082                	ret

00000000800036b6 <idup>:
{
    800036b6:	1101                	add	sp,sp,-32
    800036b8:	ec06                	sd	ra,24(sp)
    800036ba:	e822                	sd	s0,16(sp)
    800036bc:	e426                	sd	s1,8(sp)
    800036be:	1000                	add	s0,sp,32
    800036c0:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800036c2:	00193517          	auipc	a0,0x193
    800036c6:	f7e50513          	add	a0,a0,-130 # 80196640 <itable>
    800036ca:	ffffd097          	auipc	ra,0xffffd
    800036ce:	508080e7          	jalr	1288(ra) # 80000bd2 <acquire>
  ip->ref++;
    800036d2:	449c                	lw	a5,8(s1)
    800036d4:	2785                	addw	a5,a5,1
    800036d6:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800036d8:	00193517          	auipc	a0,0x193
    800036dc:	f6850513          	add	a0,a0,-152 # 80196640 <itable>
    800036e0:	ffffd097          	auipc	ra,0xffffd
    800036e4:	5a6080e7          	jalr	1446(ra) # 80000c86 <release>
}
    800036e8:	8526                	mv	a0,s1
    800036ea:	60e2                	ld	ra,24(sp)
    800036ec:	6442                	ld	s0,16(sp)
    800036ee:	64a2                	ld	s1,8(sp)
    800036f0:	6105                	add	sp,sp,32
    800036f2:	8082                	ret

00000000800036f4 <ilock>:
{
    800036f4:	1101                	add	sp,sp,-32
    800036f6:	ec06                	sd	ra,24(sp)
    800036f8:	e822                	sd	s0,16(sp)
    800036fa:	e426                	sd	s1,8(sp)
    800036fc:	e04a                	sd	s2,0(sp)
    800036fe:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80003700:	c115                	beqz	a0,80003724 <ilock+0x30>
    80003702:	84aa                	mv	s1,a0
    80003704:	451c                	lw	a5,8(a0)
    80003706:	00f05f63          	blez	a5,80003724 <ilock+0x30>
  acquiresleep(&ip->lock);
    8000370a:	0541                	add	a0,a0,16
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	c7e080e7          	jalr	-898(ra) # 8000438a <acquiresleep>
  if(ip->valid == 0){
    80003714:	40bc                	lw	a5,64(s1)
    80003716:	cf99                	beqz	a5,80003734 <ilock+0x40>
}
    80003718:	60e2                	ld	ra,24(sp)
    8000371a:	6442                	ld	s0,16(sp)
    8000371c:	64a2                	ld	s1,8(sp)
    8000371e:	6902                	ld	s2,0(sp)
    80003720:	6105                	add	sp,sp,32
    80003722:	8082                	ret
    panic("ilock");
    80003724:	00005517          	auipc	a0,0x5
    80003728:	ed450513          	add	a0,a0,-300 # 800085f8 <syscalls+0x180>
    8000372c:	ffffd097          	auipc	ra,0xffffd
    80003730:	e10080e7          	jalr	-496(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003734:	40dc                	lw	a5,4(s1)
    80003736:	0047d79b          	srlw	a5,a5,0x4
    8000373a:	00193597          	auipc	a1,0x193
    8000373e:	ef65a583          	lw	a1,-266(a1) # 80196630 <sb+0x18>
    80003742:	9dbd                	addw	a1,a1,a5
    80003744:	4088                	lw	a0,0(s1)
    80003746:	fffff097          	auipc	ra,0xfffff
    8000374a:	79e080e7          	jalr	1950(ra) # 80002ee4 <bread>
    8000374e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003750:	05850593          	add	a1,a0,88
    80003754:	40dc                	lw	a5,4(s1)
    80003756:	8bbd                	and	a5,a5,15
    80003758:	079a                	sll	a5,a5,0x6
    8000375a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000375c:	00059783          	lh	a5,0(a1)
    80003760:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003764:	00259783          	lh	a5,2(a1)
    80003768:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000376c:	00459783          	lh	a5,4(a1)
    80003770:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003774:	00659783          	lh	a5,6(a1)
    80003778:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000377c:	459c                	lw	a5,8(a1)
    8000377e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003780:	03400613          	li	a2,52
    80003784:	05b1                	add	a1,a1,12
    80003786:	05048513          	add	a0,s1,80
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	5a0080e7          	jalr	1440(ra) # 80000d2a <memmove>
    brelse(bp);
    80003792:	854a                	mv	a0,s2
    80003794:	00000097          	auipc	ra,0x0
    80003798:	880080e7          	jalr	-1920(ra) # 80003014 <brelse>
    ip->valid = 1;
    8000379c:	4785                	li	a5,1
    8000379e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037a0:	04449783          	lh	a5,68(s1)
    800037a4:	fbb5                	bnez	a5,80003718 <ilock+0x24>
      panic("ilock: no type");
    800037a6:	00005517          	auipc	a0,0x5
    800037aa:	e5a50513          	add	a0,a0,-422 # 80008600 <syscalls+0x188>
    800037ae:	ffffd097          	auipc	ra,0xffffd
    800037b2:	d8e080e7          	jalr	-626(ra) # 8000053c <panic>

00000000800037b6 <iunlock>:
{
    800037b6:	1101                	add	sp,sp,-32
    800037b8:	ec06                	sd	ra,24(sp)
    800037ba:	e822                	sd	s0,16(sp)
    800037bc:	e426                	sd	s1,8(sp)
    800037be:	e04a                	sd	s2,0(sp)
    800037c0:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800037c2:	c905                	beqz	a0,800037f2 <iunlock+0x3c>
    800037c4:	84aa                	mv	s1,a0
    800037c6:	01050913          	add	s2,a0,16
    800037ca:	854a                	mv	a0,s2
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	c58080e7          	jalr	-936(ra) # 80004424 <holdingsleep>
    800037d4:	cd19                	beqz	a0,800037f2 <iunlock+0x3c>
    800037d6:	449c                	lw	a5,8(s1)
    800037d8:	00f05d63          	blez	a5,800037f2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    800037dc:	854a                	mv	a0,s2
    800037de:	00001097          	auipc	ra,0x1
    800037e2:	c02080e7          	jalr	-1022(ra) # 800043e0 <releasesleep>
}
    800037e6:	60e2                	ld	ra,24(sp)
    800037e8:	6442                	ld	s0,16(sp)
    800037ea:	64a2                	ld	s1,8(sp)
    800037ec:	6902                	ld	s2,0(sp)
    800037ee:	6105                	add	sp,sp,32
    800037f0:	8082                	ret
    panic("iunlock");
    800037f2:	00005517          	auipc	a0,0x5
    800037f6:	e1e50513          	add	a0,a0,-482 # 80008610 <syscalls+0x198>
    800037fa:	ffffd097          	auipc	ra,0xffffd
    800037fe:	d42080e7          	jalr	-702(ra) # 8000053c <panic>

0000000080003802 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003802:	7179                	add	sp,sp,-48
    80003804:	f406                	sd	ra,40(sp)
    80003806:	f022                	sd	s0,32(sp)
    80003808:	ec26                	sd	s1,24(sp)
    8000380a:	e84a                	sd	s2,16(sp)
    8000380c:	e44e                	sd	s3,8(sp)
    8000380e:	e052                	sd	s4,0(sp)
    80003810:	1800                	add	s0,sp,48
    80003812:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003814:	05050493          	add	s1,a0,80
    80003818:	08050913          	add	s2,a0,128
    8000381c:	a021                	j	80003824 <itrunc+0x22>
    8000381e:	0491                	add	s1,s1,4
    80003820:	01248d63          	beq	s1,s2,8000383a <itrunc+0x38>
    if(ip->addrs[i]){
    80003824:	408c                	lw	a1,0(s1)
    80003826:	dde5                	beqz	a1,8000381e <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003828:	0009a503          	lw	a0,0(s3)
    8000382c:	00000097          	auipc	ra,0x0
    80003830:	8fc080e7          	jalr	-1796(ra) # 80003128 <bfree>
      ip->addrs[i] = 0;
    80003834:	0004a023          	sw	zero,0(s1)
    80003838:	b7dd                	j	8000381e <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    8000383a:	0809a583          	lw	a1,128(s3)
    8000383e:	e185                	bnez	a1,8000385e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003840:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003844:	854e                	mv	a0,s3
    80003846:	00000097          	auipc	ra,0x0
    8000384a:	de2080e7          	jalr	-542(ra) # 80003628 <iupdate>
}
    8000384e:	70a2                	ld	ra,40(sp)
    80003850:	7402                	ld	s0,32(sp)
    80003852:	64e2                	ld	s1,24(sp)
    80003854:	6942                	ld	s2,16(sp)
    80003856:	69a2                	ld	s3,8(sp)
    80003858:	6a02                	ld	s4,0(sp)
    8000385a:	6145                	add	sp,sp,48
    8000385c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000385e:	0009a503          	lw	a0,0(s3)
    80003862:	fffff097          	auipc	ra,0xfffff
    80003866:	682080e7          	jalr	1666(ra) # 80002ee4 <bread>
    8000386a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000386c:	05850493          	add	s1,a0,88
    80003870:	45850913          	add	s2,a0,1112
    80003874:	a021                	j	8000387c <itrunc+0x7a>
    80003876:	0491                	add	s1,s1,4
    80003878:	01248b63          	beq	s1,s2,8000388e <itrunc+0x8c>
      if(a[j])
    8000387c:	408c                	lw	a1,0(s1)
    8000387e:	dde5                	beqz	a1,80003876 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003880:	0009a503          	lw	a0,0(s3)
    80003884:	00000097          	auipc	ra,0x0
    80003888:	8a4080e7          	jalr	-1884(ra) # 80003128 <bfree>
    8000388c:	b7ed                	j	80003876 <itrunc+0x74>
    brelse(bp);
    8000388e:	8552                	mv	a0,s4
    80003890:	fffff097          	auipc	ra,0xfffff
    80003894:	784080e7          	jalr	1924(ra) # 80003014 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003898:	0809a583          	lw	a1,128(s3)
    8000389c:	0009a503          	lw	a0,0(s3)
    800038a0:	00000097          	auipc	ra,0x0
    800038a4:	888080e7          	jalr	-1912(ra) # 80003128 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038a8:	0809a023          	sw	zero,128(s3)
    800038ac:	bf51                	j	80003840 <itrunc+0x3e>

00000000800038ae <iput>:
{
    800038ae:	1101                	add	sp,sp,-32
    800038b0:	ec06                	sd	ra,24(sp)
    800038b2:	e822                	sd	s0,16(sp)
    800038b4:	e426                	sd	s1,8(sp)
    800038b6:	e04a                	sd	s2,0(sp)
    800038b8:	1000                	add	s0,sp,32
    800038ba:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038bc:	00193517          	auipc	a0,0x193
    800038c0:	d8450513          	add	a0,a0,-636 # 80196640 <itable>
    800038c4:	ffffd097          	auipc	ra,0xffffd
    800038c8:	30e080e7          	jalr	782(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038cc:	4498                	lw	a4,8(s1)
    800038ce:	4785                	li	a5,1
    800038d0:	02f70363          	beq	a4,a5,800038f6 <iput+0x48>
  ip->ref--;
    800038d4:	449c                	lw	a5,8(s1)
    800038d6:	37fd                	addw	a5,a5,-1
    800038d8:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    800038da:	00193517          	auipc	a0,0x193
    800038de:	d6650513          	add	a0,a0,-666 # 80196640 <itable>
    800038e2:	ffffd097          	auipc	ra,0xffffd
    800038e6:	3a4080e7          	jalr	932(ra) # 80000c86 <release>
}
    800038ea:	60e2                	ld	ra,24(sp)
    800038ec:	6442                	ld	s0,16(sp)
    800038ee:	64a2                	ld	s1,8(sp)
    800038f0:	6902                	ld	s2,0(sp)
    800038f2:	6105                	add	sp,sp,32
    800038f4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800038f6:	40bc                	lw	a5,64(s1)
    800038f8:	dff1                	beqz	a5,800038d4 <iput+0x26>
    800038fa:	04a49783          	lh	a5,74(s1)
    800038fe:	fbf9                	bnez	a5,800038d4 <iput+0x26>
    acquiresleep(&ip->lock);
    80003900:	01048913          	add	s2,s1,16
    80003904:	854a                	mv	a0,s2
    80003906:	00001097          	auipc	ra,0x1
    8000390a:	a84080e7          	jalr	-1404(ra) # 8000438a <acquiresleep>
    release(&itable.lock);
    8000390e:	00193517          	auipc	a0,0x193
    80003912:	d3250513          	add	a0,a0,-718 # 80196640 <itable>
    80003916:	ffffd097          	auipc	ra,0xffffd
    8000391a:	370080e7          	jalr	880(ra) # 80000c86 <release>
    itrunc(ip);
    8000391e:	8526                	mv	a0,s1
    80003920:	00000097          	auipc	ra,0x0
    80003924:	ee2080e7          	jalr	-286(ra) # 80003802 <itrunc>
    ip->type = 0;
    80003928:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000392c:	8526                	mv	a0,s1
    8000392e:	00000097          	auipc	ra,0x0
    80003932:	cfa080e7          	jalr	-774(ra) # 80003628 <iupdate>
    ip->valid = 0;
    80003936:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    8000393a:	854a                	mv	a0,s2
    8000393c:	00001097          	auipc	ra,0x1
    80003940:	aa4080e7          	jalr	-1372(ra) # 800043e0 <releasesleep>
    acquire(&itable.lock);
    80003944:	00193517          	auipc	a0,0x193
    80003948:	cfc50513          	add	a0,a0,-772 # 80196640 <itable>
    8000394c:	ffffd097          	auipc	ra,0xffffd
    80003950:	286080e7          	jalr	646(ra) # 80000bd2 <acquire>
    80003954:	b741                	j	800038d4 <iput+0x26>

0000000080003956 <iunlockput>:
{
    80003956:	1101                	add	sp,sp,-32
    80003958:	ec06                	sd	ra,24(sp)
    8000395a:	e822                	sd	s0,16(sp)
    8000395c:	e426                	sd	s1,8(sp)
    8000395e:	1000                	add	s0,sp,32
    80003960:	84aa                	mv	s1,a0
  iunlock(ip);
    80003962:	00000097          	auipc	ra,0x0
    80003966:	e54080e7          	jalr	-428(ra) # 800037b6 <iunlock>
  iput(ip);
    8000396a:	8526                	mv	a0,s1
    8000396c:	00000097          	auipc	ra,0x0
    80003970:	f42080e7          	jalr	-190(ra) # 800038ae <iput>
}
    80003974:	60e2                	ld	ra,24(sp)
    80003976:	6442                	ld	s0,16(sp)
    80003978:	64a2                	ld	s1,8(sp)
    8000397a:	6105                	add	sp,sp,32
    8000397c:	8082                	ret

000000008000397e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    8000397e:	1141                	add	sp,sp,-16
    80003980:	e422                	sd	s0,8(sp)
    80003982:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003984:	411c                	lw	a5,0(a0)
    80003986:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003988:	415c                	lw	a5,4(a0)
    8000398a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    8000398c:	04451783          	lh	a5,68(a0)
    80003990:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003994:	04a51783          	lh	a5,74(a0)
    80003998:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    8000399c:	04c56783          	lwu	a5,76(a0)
    800039a0:	e99c                	sd	a5,16(a1)
}
    800039a2:	6422                	ld	s0,8(sp)
    800039a4:	0141                	add	sp,sp,16
    800039a6:	8082                	ret

00000000800039a8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039a8:	457c                	lw	a5,76(a0)
    800039aa:	0ed7e963          	bltu	a5,a3,80003a9c <readi+0xf4>
{
    800039ae:	7159                	add	sp,sp,-112
    800039b0:	f486                	sd	ra,104(sp)
    800039b2:	f0a2                	sd	s0,96(sp)
    800039b4:	eca6                	sd	s1,88(sp)
    800039b6:	e8ca                	sd	s2,80(sp)
    800039b8:	e4ce                	sd	s3,72(sp)
    800039ba:	e0d2                	sd	s4,64(sp)
    800039bc:	fc56                	sd	s5,56(sp)
    800039be:	f85a                	sd	s6,48(sp)
    800039c0:	f45e                	sd	s7,40(sp)
    800039c2:	f062                	sd	s8,32(sp)
    800039c4:	ec66                	sd	s9,24(sp)
    800039c6:	e86a                	sd	s10,16(sp)
    800039c8:	e46e                	sd	s11,8(sp)
    800039ca:	1880                	add	s0,sp,112
    800039cc:	8b2a                	mv	s6,a0
    800039ce:	8bae                	mv	s7,a1
    800039d0:	8a32                	mv	s4,a2
    800039d2:	84b6                	mv	s1,a3
    800039d4:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    800039d6:	9f35                	addw	a4,a4,a3
    return 0;
    800039d8:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    800039da:	0ad76063          	bltu	a4,a3,80003a7a <readi+0xd2>
  if(off + n > ip->size)
    800039de:	00e7f463          	bgeu	a5,a4,800039e6 <readi+0x3e>
    n = ip->size - off;
    800039e2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039e6:	0a0a8963          	beqz	s5,80003a98 <readi+0xf0>
    800039ea:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    800039ec:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    800039f0:	5c7d                	li	s8,-1
    800039f2:	a82d                	j	80003a2c <readi+0x84>
    800039f4:	020d1d93          	sll	s11,s10,0x20
    800039f8:	020ddd93          	srl	s11,s11,0x20
    800039fc:	05890613          	add	a2,s2,88
    80003a00:	86ee                	mv	a3,s11
    80003a02:	963a                	add	a2,a2,a4
    80003a04:	85d2                	mv	a1,s4
    80003a06:	855e                	mv	a0,s7
    80003a08:	fffff097          	auipc	ra,0xfffff
    80003a0c:	b02080e7          	jalr	-1278(ra) # 8000250a <either_copyout>
    80003a10:	05850d63          	beq	a0,s8,80003a6a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a14:	854a                	mv	a0,s2
    80003a16:	fffff097          	auipc	ra,0xfffff
    80003a1a:	5fe080e7          	jalr	1534(ra) # 80003014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a1e:	013d09bb          	addw	s3,s10,s3
    80003a22:	009d04bb          	addw	s1,s10,s1
    80003a26:	9a6e                	add	s4,s4,s11
    80003a28:	0559f763          	bgeu	s3,s5,80003a76 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a2c:	00a4d59b          	srlw	a1,s1,0xa
    80003a30:	855a                	mv	a0,s6
    80003a32:	00000097          	auipc	ra,0x0
    80003a36:	8a4080e7          	jalr	-1884(ra) # 800032d6 <bmap>
    80003a3a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a3e:	cd85                	beqz	a1,80003a76 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a40:	000b2503          	lw	a0,0(s6)
    80003a44:	fffff097          	auipc	ra,0xfffff
    80003a48:	4a0080e7          	jalr	1184(ra) # 80002ee4 <bread>
    80003a4c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a4e:	3ff4f713          	and	a4,s1,1023
    80003a52:	40ec87bb          	subw	a5,s9,a4
    80003a56:	413a86bb          	subw	a3,s5,s3
    80003a5a:	8d3e                	mv	s10,a5
    80003a5c:	2781                	sext.w	a5,a5
    80003a5e:	0006861b          	sext.w	a2,a3
    80003a62:	f8f679e3          	bgeu	a2,a5,800039f4 <readi+0x4c>
    80003a66:	8d36                	mv	s10,a3
    80003a68:	b771                	j	800039f4 <readi+0x4c>
      brelse(bp);
    80003a6a:	854a                	mv	a0,s2
    80003a6c:	fffff097          	auipc	ra,0xfffff
    80003a70:	5a8080e7          	jalr	1448(ra) # 80003014 <brelse>
      tot = -1;
    80003a74:	59fd                	li	s3,-1
  }
  return tot;
    80003a76:	0009851b          	sext.w	a0,s3
}
    80003a7a:	70a6                	ld	ra,104(sp)
    80003a7c:	7406                	ld	s0,96(sp)
    80003a7e:	64e6                	ld	s1,88(sp)
    80003a80:	6946                	ld	s2,80(sp)
    80003a82:	69a6                	ld	s3,72(sp)
    80003a84:	6a06                	ld	s4,64(sp)
    80003a86:	7ae2                	ld	s5,56(sp)
    80003a88:	7b42                	ld	s6,48(sp)
    80003a8a:	7ba2                	ld	s7,40(sp)
    80003a8c:	7c02                	ld	s8,32(sp)
    80003a8e:	6ce2                	ld	s9,24(sp)
    80003a90:	6d42                	ld	s10,16(sp)
    80003a92:	6da2                	ld	s11,8(sp)
    80003a94:	6165                	add	sp,sp,112
    80003a96:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a98:	89d6                	mv	s3,s5
    80003a9a:	bff1                	j	80003a76 <readi+0xce>
    return 0;
    80003a9c:	4501                	li	a0,0
}
    80003a9e:	8082                	ret

0000000080003aa0 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aa0:	457c                	lw	a5,76(a0)
    80003aa2:	10d7e863          	bltu	a5,a3,80003bb2 <writei+0x112>
{
    80003aa6:	7159                	add	sp,sp,-112
    80003aa8:	f486                	sd	ra,104(sp)
    80003aaa:	f0a2                	sd	s0,96(sp)
    80003aac:	eca6                	sd	s1,88(sp)
    80003aae:	e8ca                	sd	s2,80(sp)
    80003ab0:	e4ce                	sd	s3,72(sp)
    80003ab2:	e0d2                	sd	s4,64(sp)
    80003ab4:	fc56                	sd	s5,56(sp)
    80003ab6:	f85a                	sd	s6,48(sp)
    80003ab8:	f45e                	sd	s7,40(sp)
    80003aba:	f062                	sd	s8,32(sp)
    80003abc:	ec66                	sd	s9,24(sp)
    80003abe:	e86a                	sd	s10,16(sp)
    80003ac0:	e46e                	sd	s11,8(sp)
    80003ac2:	1880                	add	s0,sp,112
    80003ac4:	8aaa                	mv	s5,a0
    80003ac6:	8bae                	mv	s7,a1
    80003ac8:	8a32                	mv	s4,a2
    80003aca:	8936                	mv	s2,a3
    80003acc:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003ace:	00e687bb          	addw	a5,a3,a4
    80003ad2:	0ed7e263          	bltu	a5,a3,80003bb6 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003ad6:	00043737          	lui	a4,0x43
    80003ada:	0ef76063          	bltu	a4,a5,80003bba <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003ade:	0c0b0863          	beqz	s6,80003bae <writei+0x10e>
    80003ae2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ae4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ae8:	5c7d                	li	s8,-1
    80003aea:	a091                	j	80003b2e <writei+0x8e>
    80003aec:	020d1d93          	sll	s11,s10,0x20
    80003af0:	020ddd93          	srl	s11,s11,0x20
    80003af4:	05848513          	add	a0,s1,88
    80003af8:	86ee                	mv	a3,s11
    80003afa:	8652                	mv	a2,s4
    80003afc:	85de                	mv	a1,s7
    80003afe:	953a                	add	a0,a0,a4
    80003b00:	fffff097          	auipc	ra,0xfffff
    80003b04:	a60080e7          	jalr	-1440(ra) # 80002560 <either_copyin>
    80003b08:	07850263          	beq	a0,s8,80003b6c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b0c:	8526                	mv	a0,s1
    80003b0e:	00000097          	auipc	ra,0x0
    80003b12:	75e080e7          	jalr	1886(ra) # 8000426c <log_write>
    brelse(bp);
    80003b16:	8526                	mv	a0,s1
    80003b18:	fffff097          	auipc	ra,0xfffff
    80003b1c:	4fc080e7          	jalr	1276(ra) # 80003014 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b20:	013d09bb          	addw	s3,s10,s3
    80003b24:	012d093b          	addw	s2,s10,s2
    80003b28:	9a6e                	add	s4,s4,s11
    80003b2a:	0569f663          	bgeu	s3,s6,80003b76 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b2e:	00a9559b          	srlw	a1,s2,0xa
    80003b32:	8556                	mv	a0,s5
    80003b34:	fffff097          	auipc	ra,0xfffff
    80003b38:	7a2080e7          	jalr	1954(ra) # 800032d6 <bmap>
    80003b3c:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b40:	c99d                	beqz	a1,80003b76 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b42:	000aa503          	lw	a0,0(s5)
    80003b46:	fffff097          	auipc	ra,0xfffff
    80003b4a:	39e080e7          	jalr	926(ra) # 80002ee4 <bread>
    80003b4e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b50:	3ff97713          	and	a4,s2,1023
    80003b54:	40ec87bb          	subw	a5,s9,a4
    80003b58:	413b06bb          	subw	a3,s6,s3
    80003b5c:	8d3e                	mv	s10,a5
    80003b5e:	2781                	sext.w	a5,a5
    80003b60:	0006861b          	sext.w	a2,a3
    80003b64:	f8f674e3          	bgeu	a2,a5,80003aec <writei+0x4c>
    80003b68:	8d36                	mv	s10,a3
    80003b6a:	b749                	j	80003aec <writei+0x4c>
      brelse(bp);
    80003b6c:	8526                	mv	a0,s1
    80003b6e:	fffff097          	auipc	ra,0xfffff
    80003b72:	4a6080e7          	jalr	1190(ra) # 80003014 <brelse>
  }

  if(off > ip->size)
    80003b76:	04caa783          	lw	a5,76(s5)
    80003b7a:	0127f463          	bgeu	a5,s2,80003b82 <writei+0xe2>
    ip->size = off;
    80003b7e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003b82:	8556                	mv	a0,s5
    80003b84:	00000097          	auipc	ra,0x0
    80003b88:	aa4080e7          	jalr	-1372(ra) # 80003628 <iupdate>

  return tot;
    80003b8c:	0009851b          	sext.w	a0,s3
}
    80003b90:	70a6                	ld	ra,104(sp)
    80003b92:	7406                	ld	s0,96(sp)
    80003b94:	64e6                	ld	s1,88(sp)
    80003b96:	6946                	ld	s2,80(sp)
    80003b98:	69a6                	ld	s3,72(sp)
    80003b9a:	6a06                	ld	s4,64(sp)
    80003b9c:	7ae2                	ld	s5,56(sp)
    80003b9e:	7b42                	ld	s6,48(sp)
    80003ba0:	7ba2                	ld	s7,40(sp)
    80003ba2:	7c02                	ld	s8,32(sp)
    80003ba4:	6ce2                	ld	s9,24(sp)
    80003ba6:	6d42                	ld	s10,16(sp)
    80003ba8:	6da2                	ld	s11,8(sp)
    80003baa:	6165                	add	sp,sp,112
    80003bac:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bae:	89da                	mv	s3,s6
    80003bb0:	bfc9                	j	80003b82 <writei+0xe2>
    return -1;
    80003bb2:	557d                	li	a0,-1
}
    80003bb4:	8082                	ret
    return -1;
    80003bb6:	557d                	li	a0,-1
    80003bb8:	bfe1                	j	80003b90 <writei+0xf0>
    return -1;
    80003bba:	557d                	li	a0,-1
    80003bbc:	bfd1                	j	80003b90 <writei+0xf0>

0000000080003bbe <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003bbe:	1141                	add	sp,sp,-16
    80003bc0:	e406                	sd	ra,8(sp)
    80003bc2:	e022                	sd	s0,0(sp)
    80003bc4:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003bc6:	4639                	li	a2,14
    80003bc8:	ffffd097          	auipc	ra,0xffffd
    80003bcc:	1d6080e7          	jalr	470(ra) # 80000d9e <strncmp>
}
    80003bd0:	60a2                	ld	ra,8(sp)
    80003bd2:	6402                	ld	s0,0(sp)
    80003bd4:	0141                	add	sp,sp,16
    80003bd6:	8082                	ret

0000000080003bd8 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003bd8:	7139                	add	sp,sp,-64
    80003bda:	fc06                	sd	ra,56(sp)
    80003bdc:	f822                	sd	s0,48(sp)
    80003bde:	f426                	sd	s1,40(sp)
    80003be0:	f04a                	sd	s2,32(sp)
    80003be2:	ec4e                	sd	s3,24(sp)
    80003be4:	e852                	sd	s4,16(sp)
    80003be6:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003be8:	04451703          	lh	a4,68(a0)
    80003bec:	4785                	li	a5,1
    80003bee:	00f71a63          	bne	a4,a5,80003c02 <dirlookup+0x2a>
    80003bf2:	892a                	mv	s2,a0
    80003bf4:	89ae                	mv	s3,a1
    80003bf6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bf8:	457c                	lw	a5,76(a0)
    80003bfa:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003bfc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003bfe:	e79d                	bnez	a5,80003c2c <dirlookup+0x54>
    80003c00:	a8a5                	j	80003c78 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c02:	00005517          	auipc	a0,0x5
    80003c06:	a1650513          	add	a0,a0,-1514 # 80008618 <syscalls+0x1a0>
    80003c0a:	ffffd097          	auipc	ra,0xffffd
    80003c0e:	932080e7          	jalr	-1742(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c12:	00005517          	auipc	a0,0x5
    80003c16:	a1e50513          	add	a0,a0,-1506 # 80008630 <syscalls+0x1b8>
    80003c1a:	ffffd097          	auipc	ra,0xffffd
    80003c1e:	922080e7          	jalr	-1758(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c22:	24c1                	addw	s1,s1,16
    80003c24:	04c92783          	lw	a5,76(s2)
    80003c28:	04f4f763          	bgeu	s1,a5,80003c76 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c2c:	4741                	li	a4,16
    80003c2e:	86a6                	mv	a3,s1
    80003c30:	fc040613          	add	a2,s0,-64
    80003c34:	4581                	li	a1,0
    80003c36:	854a                	mv	a0,s2
    80003c38:	00000097          	auipc	ra,0x0
    80003c3c:	d70080e7          	jalr	-656(ra) # 800039a8 <readi>
    80003c40:	47c1                	li	a5,16
    80003c42:	fcf518e3          	bne	a0,a5,80003c12 <dirlookup+0x3a>
    if(de.inum == 0)
    80003c46:	fc045783          	lhu	a5,-64(s0)
    80003c4a:	dfe1                	beqz	a5,80003c22 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c4c:	fc240593          	add	a1,s0,-62
    80003c50:	854e                	mv	a0,s3
    80003c52:	00000097          	auipc	ra,0x0
    80003c56:	f6c080e7          	jalr	-148(ra) # 80003bbe <namecmp>
    80003c5a:	f561                	bnez	a0,80003c22 <dirlookup+0x4a>
      if(poff)
    80003c5c:	000a0463          	beqz	s4,80003c64 <dirlookup+0x8c>
        *poff = off;
    80003c60:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003c64:	fc045583          	lhu	a1,-64(s0)
    80003c68:	00092503          	lw	a0,0(s2)
    80003c6c:	fffff097          	auipc	ra,0xfffff
    80003c70:	754080e7          	jalr	1876(ra) # 800033c0 <iget>
    80003c74:	a011                	j	80003c78 <dirlookup+0xa0>
  return 0;
    80003c76:	4501                	li	a0,0
}
    80003c78:	70e2                	ld	ra,56(sp)
    80003c7a:	7442                	ld	s0,48(sp)
    80003c7c:	74a2                	ld	s1,40(sp)
    80003c7e:	7902                	ld	s2,32(sp)
    80003c80:	69e2                	ld	s3,24(sp)
    80003c82:	6a42                	ld	s4,16(sp)
    80003c84:	6121                	add	sp,sp,64
    80003c86:	8082                	ret

0000000080003c88 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003c88:	711d                	add	sp,sp,-96
    80003c8a:	ec86                	sd	ra,88(sp)
    80003c8c:	e8a2                	sd	s0,80(sp)
    80003c8e:	e4a6                	sd	s1,72(sp)
    80003c90:	e0ca                	sd	s2,64(sp)
    80003c92:	fc4e                	sd	s3,56(sp)
    80003c94:	f852                	sd	s4,48(sp)
    80003c96:	f456                	sd	s5,40(sp)
    80003c98:	f05a                	sd	s6,32(sp)
    80003c9a:	ec5e                	sd	s7,24(sp)
    80003c9c:	e862                	sd	s8,16(sp)
    80003c9e:	e466                	sd	s9,8(sp)
    80003ca0:	1080                	add	s0,sp,96
    80003ca2:	84aa                	mv	s1,a0
    80003ca4:	8b2e                	mv	s6,a1
    80003ca6:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ca8:	00054703          	lbu	a4,0(a0)
    80003cac:	02f00793          	li	a5,47
    80003cb0:	02f70263          	beq	a4,a5,80003cd4 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cb4:	ffffe097          	auipc	ra,0xffffe
    80003cb8:	d2e080e7          	jalr	-722(ra) # 800019e2 <myproc>
    80003cbc:	15053503          	ld	a0,336(a0)
    80003cc0:	00000097          	auipc	ra,0x0
    80003cc4:	9f6080e7          	jalr	-1546(ra) # 800036b6 <idup>
    80003cc8:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003cca:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003cce:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003cd0:	4b85                	li	s7,1
    80003cd2:	a875                	j	80003d8e <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003cd4:	4585                	li	a1,1
    80003cd6:	4505                	li	a0,1
    80003cd8:	fffff097          	auipc	ra,0xfffff
    80003cdc:	6e8080e7          	jalr	1768(ra) # 800033c0 <iget>
    80003ce0:	8a2a                	mv	s4,a0
    80003ce2:	b7e5                	j	80003cca <namex+0x42>
      iunlockput(ip);
    80003ce4:	8552                	mv	a0,s4
    80003ce6:	00000097          	auipc	ra,0x0
    80003cea:	c70080e7          	jalr	-912(ra) # 80003956 <iunlockput>
      return 0;
    80003cee:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003cf0:	8552                	mv	a0,s4
    80003cf2:	60e6                	ld	ra,88(sp)
    80003cf4:	6446                	ld	s0,80(sp)
    80003cf6:	64a6                	ld	s1,72(sp)
    80003cf8:	6906                	ld	s2,64(sp)
    80003cfa:	79e2                	ld	s3,56(sp)
    80003cfc:	7a42                	ld	s4,48(sp)
    80003cfe:	7aa2                	ld	s5,40(sp)
    80003d00:	7b02                	ld	s6,32(sp)
    80003d02:	6be2                	ld	s7,24(sp)
    80003d04:	6c42                	ld	s8,16(sp)
    80003d06:	6ca2                	ld	s9,8(sp)
    80003d08:	6125                	add	sp,sp,96
    80003d0a:	8082                	ret
      iunlock(ip);
    80003d0c:	8552                	mv	a0,s4
    80003d0e:	00000097          	auipc	ra,0x0
    80003d12:	aa8080e7          	jalr	-1368(ra) # 800037b6 <iunlock>
      return ip;
    80003d16:	bfe9                	j	80003cf0 <namex+0x68>
      iunlockput(ip);
    80003d18:	8552                	mv	a0,s4
    80003d1a:	00000097          	auipc	ra,0x0
    80003d1e:	c3c080e7          	jalr	-964(ra) # 80003956 <iunlockput>
      return 0;
    80003d22:	8a4e                	mv	s4,s3
    80003d24:	b7f1                	j	80003cf0 <namex+0x68>
  len = path - s;
    80003d26:	40998633          	sub	a2,s3,s1
    80003d2a:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d2e:	099c5863          	bge	s8,s9,80003dbe <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003d32:	4639                	li	a2,14
    80003d34:	85a6                	mv	a1,s1
    80003d36:	8556                	mv	a0,s5
    80003d38:	ffffd097          	auipc	ra,0xffffd
    80003d3c:	ff2080e7          	jalr	-14(ra) # 80000d2a <memmove>
    80003d40:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d42:	0004c783          	lbu	a5,0(s1)
    80003d46:	01279763          	bne	a5,s2,80003d54 <namex+0xcc>
    path++;
    80003d4a:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d4c:	0004c783          	lbu	a5,0(s1)
    80003d50:	ff278de3          	beq	a5,s2,80003d4a <namex+0xc2>
    ilock(ip);
    80003d54:	8552                	mv	a0,s4
    80003d56:	00000097          	auipc	ra,0x0
    80003d5a:	99e080e7          	jalr	-1634(ra) # 800036f4 <ilock>
    if(ip->type != T_DIR){
    80003d5e:	044a1783          	lh	a5,68(s4)
    80003d62:	f97791e3          	bne	a5,s7,80003ce4 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003d66:	000b0563          	beqz	s6,80003d70 <namex+0xe8>
    80003d6a:	0004c783          	lbu	a5,0(s1)
    80003d6e:	dfd9                	beqz	a5,80003d0c <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003d70:	4601                	li	a2,0
    80003d72:	85d6                	mv	a1,s5
    80003d74:	8552                	mv	a0,s4
    80003d76:	00000097          	auipc	ra,0x0
    80003d7a:	e62080e7          	jalr	-414(ra) # 80003bd8 <dirlookup>
    80003d7e:	89aa                	mv	s3,a0
    80003d80:	dd41                	beqz	a0,80003d18 <namex+0x90>
    iunlockput(ip);
    80003d82:	8552                	mv	a0,s4
    80003d84:	00000097          	auipc	ra,0x0
    80003d88:	bd2080e7          	jalr	-1070(ra) # 80003956 <iunlockput>
    ip = next;
    80003d8c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003d8e:	0004c783          	lbu	a5,0(s1)
    80003d92:	01279763          	bne	a5,s2,80003da0 <namex+0x118>
    path++;
    80003d96:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d98:	0004c783          	lbu	a5,0(s1)
    80003d9c:	ff278de3          	beq	a5,s2,80003d96 <namex+0x10e>
  if(*path == 0)
    80003da0:	cb9d                	beqz	a5,80003dd6 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003da2:	0004c783          	lbu	a5,0(s1)
    80003da6:	89a6                	mv	s3,s1
  len = path - s;
    80003da8:	4c81                	li	s9,0
    80003daa:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003dac:	01278963          	beq	a5,s2,80003dbe <namex+0x136>
    80003db0:	dbbd                	beqz	a5,80003d26 <namex+0x9e>
    path++;
    80003db2:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003db4:	0009c783          	lbu	a5,0(s3)
    80003db8:	ff279ce3          	bne	a5,s2,80003db0 <namex+0x128>
    80003dbc:	b7ad                	j	80003d26 <namex+0x9e>
    memmove(name, s, len);
    80003dbe:	2601                	sext.w	a2,a2
    80003dc0:	85a6                	mv	a1,s1
    80003dc2:	8556                	mv	a0,s5
    80003dc4:	ffffd097          	auipc	ra,0xffffd
    80003dc8:	f66080e7          	jalr	-154(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003dcc:	9cd6                	add	s9,s9,s5
    80003dce:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003dd2:	84ce                	mv	s1,s3
    80003dd4:	b7bd                	j	80003d42 <namex+0xba>
  if(nameiparent){
    80003dd6:	f00b0de3          	beqz	s6,80003cf0 <namex+0x68>
    iput(ip);
    80003dda:	8552                	mv	a0,s4
    80003ddc:	00000097          	auipc	ra,0x0
    80003de0:	ad2080e7          	jalr	-1326(ra) # 800038ae <iput>
    return 0;
    80003de4:	4a01                	li	s4,0
    80003de6:	b729                	j	80003cf0 <namex+0x68>

0000000080003de8 <dirlink>:
{
    80003de8:	7139                	add	sp,sp,-64
    80003dea:	fc06                	sd	ra,56(sp)
    80003dec:	f822                	sd	s0,48(sp)
    80003dee:	f426                	sd	s1,40(sp)
    80003df0:	f04a                	sd	s2,32(sp)
    80003df2:	ec4e                	sd	s3,24(sp)
    80003df4:	e852                	sd	s4,16(sp)
    80003df6:	0080                	add	s0,sp,64
    80003df8:	892a                	mv	s2,a0
    80003dfa:	8a2e                	mv	s4,a1
    80003dfc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003dfe:	4601                	li	a2,0
    80003e00:	00000097          	auipc	ra,0x0
    80003e04:	dd8080e7          	jalr	-552(ra) # 80003bd8 <dirlookup>
    80003e08:	e93d                	bnez	a0,80003e7e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e0a:	04c92483          	lw	s1,76(s2)
    80003e0e:	c49d                	beqz	s1,80003e3c <dirlink+0x54>
    80003e10:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e12:	4741                	li	a4,16
    80003e14:	86a6                	mv	a3,s1
    80003e16:	fc040613          	add	a2,s0,-64
    80003e1a:	4581                	li	a1,0
    80003e1c:	854a                	mv	a0,s2
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	b8a080e7          	jalr	-1142(ra) # 800039a8 <readi>
    80003e26:	47c1                	li	a5,16
    80003e28:	06f51163          	bne	a0,a5,80003e8a <dirlink+0xa2>
    if(de.inum == 0)
    80003e2c:	fc045783          	lhu	a5,-64(s0)
    80003e30:	c791                	beqz	a5,80003e3c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e32:	24c1                	addw	s1,s1,16
    80003e34:	04c92783          	lw	a5,76(s2)
    80003e38:	fcf4ede3          	bltu	s1,a5,80003e12 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e3c:	4639                	li	a2,14
    80003e3e:	85d2                	mv	a1,s4
    80003e40:	fc240513          	add	a0,s0,-62
    80003e44:	ffffd097          	auipc	ra,0xffffd
    80003e48:	f96080e7          	jalr	-106(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003e4c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e50:	4741                	li	a4,16
    80003e52:	86a6                	mv	a3,s1
    80003e54:	fc040613          	add	a2,s0,-64
    80003e58:	4581                	li	a1,0
    80003e5a:	854a                	mv	a0,s2
    80003e5c:	00000097          	auipc	ra,0x0
    80003e60:	c44080e7          	jalr	-956(ra) # 80003aa0 <writei>
    80003e64:	1541                	add	a0,a0,-16
    80003e66:	00a03533          	snez	a0,a0
    80003e6a:	40a00533          	neg	a0,a0
}
    80003e6e:	70e2                	ld	ra,56(sp)
    80003e70:	7442                	ld	s0,48(sp)
    80003e72:	74a2                	ld	s1,40(sp)
    80003e74:	7902                	ld	s2,32(sp)
    80003e76:	69e2                	ld	s3,24(sp)
    80003e78:	6a42                	ld	s4,16(sp)
    80003e7a:	6121                	add	sp,sp,64
    80003e7c:	8082                	ret
    iput(ip);
    80003e7e:	00000097          	auipc	ra,0x0
    80003e82:	a30080e7          	jalr	-1488(ra) # 800038ae <iput>
    return -1;
    80003e86:	557d                	li	a0,-1
    80003e88:	b7dd                	j	80003e6e <dirlink+0x86>
      panic("dirlink read");
    80003e8a:	00004517          	auipc	a0,0x4
    80003e8e:	7b650513          	add	a0,a0,1974 # 80008640 <syscalls+0x1c8>
    80003e92:	ffffc097          	auipc	ra,0xffffc
    80003e96:	6aa080e7          	jalr	1706(ra) # 8000053c <panic>

0000000080003e9a <namei>:

struct inode*
namei(char *path)
{
    80003e9a:	1101                	add	sp,sp,-32
    80003e9c:	ec06                	sd	ra,24(sp)
    80003e9e:	e822                	sd	s0,16(sp)
    80003ea0:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003ea2:	fe040613          	add	a2,s0,-32
    80003ea6:	4581                	li	a1,0
    80003ea8:	00000097          	auipc	ra,0x0
    80003eac:	de0080e7          	jalr	-544(ra) # 80003c88 <namex>
}
    80003eb0:	60e2                	ld	ra,24(sp)
    80003eb2:	6442                	ld	s0,16(sp)
    80003eb4:	6105                	add	sp,sp,32
    80003eb6:	8082                	ret

0000000080003eb8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003eb8:	1141                	add	sp,sp,-16
    80003eba:	e406                	sd	ra,8(sp)
    80003ebc:	e022                	sd	s0,0(sp)
    80003ebe:	0800                	add	s0,sp,16
    80003ec0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003ec2:	4585                	li	a1,1
    80003ec4:	00000097          	auipc	ra,0x0
    80003ec8:	dc4080e7          	jalr	-572(ra) # 80003c88 <namex>
}
    80003ecc:	60a2                	ld	ra,8(sp)
    80003ece:	6402                	ld	s0,0(sp)
    80003ed0:	0141                	add	sp,sp,16
    80003ed2:	8082                	ret

0000000080003ed4 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003ed4:	1101                	add	sp,sp,-32
    80003ed6:	ec06                	sd	ra,24(sp)
    80003ed8:	e822                	sd	s0,16(sp)
    80003eda:	e426                	sd	s1,8(sp)
    80003edc:	e04a                	sd	s2,0(sp)
    80003ede:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003ee0:	00194917          	auipc	s2,0x194
    80003ee4:	20890913          	add	s2,s2,520 # 801980e8 <log>
    80003ee8:	01892583          	lw	a1,24(s2)
    80003eec:	02892503          	lw	a0,40(s2)
    80003ef0:	fffff097          	auipc	ra,0xfffff
    80003ef4:	ff4080e7          	jalr	-12(ra) # 80002ee4 <bread>
    80003ef8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003efa:	02c92603          	lw	a2,44(s2)
    80003efe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f00:	00c05f63          	blez	a2,80003f1e <write_head+0x4a>
    80003f04:	00194717          	auipc	a4,0x194
    80003f08:	21470713          	add	a4,a4,532 # 80198118 <log+0x30>
    80003f0c:	87aa                	mv	a5,a0
    80003f0e:	060a                	sll	a2,a2,0x2
    80003f10:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f12:	4314                	lw	a3,0(a4)
    80003f14:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f16:	0711                	add	a4,a4,4
    80003f18:	0791                	add	a5,a5,4
    80003f1a:	fec79ce3          	bne	a5,a2,80003f12 <write_head+0x3e>
  }
  bwrite(buf);
    80003f1e:	8526                	mv	a0,s1
    80003f20:	fffff097          	auipc	ra,0xfffff
    80003f24:	0b6080e7          	jalr	182(ra) # 80002fd6 <bwrite>
  brelse(buf);
    80003f28:	8526                	mv	a0,s1
    80003f2a:	fffff097          	auipc	ra,0xfffff
    80003f2e:	0ea080e7          	jalr	234(ra) # 80003014 <brelse>
}
    80003f32:	60e2                	ld	ra,24(sp)
    80003f34:	6442                	ld	s0,16(sp)
    80003f36:	64a2                	ld	s1,8(sp)
    80003f38:	6902                	ld	s2,0(sp)
    80003f3a:	6105                	add	sp,sp,32
    80003f3c:	8082                	ret

0000000080003f3e <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f3e:	00194797          	auipc	a5,0x194
    80003f42:	1d67a783          	lw	a5,470(a5) # 80198114 <log+0x2c>
    80003f46:	0af05d63          	blez	a5,80004000 <install_trans+0xc2>
{
    80003f4a:	7139                	add	sp,sp,-64
    80003f4c:	fc06                	sd	ra,56(sp)
    80003f4e:	f822                	sd	s0,48(sp)
    80003f50:	f426                	sd	s1,40(sp)
    80003f52:	f04a                	sd	s2,32(sp)
    80003f54:	ec4e                	sd	s3,24(sp)
    80003f56:	e852                	sd	s4,16(sp)
    80003f58:	e456                	sd	s5,8(sp)
    80003f5a:	e05a                	sd	s6,0(sp)
    80003f5c:	0080                	add	s0,sp,64
    80003f5e:	8b2a                	mv	s6,a0
    80003f60:	00194a97          	auipc	s5,0x194
    80003f64:	1b8a8a93          	add	s5,s5,440 # 80198118 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f68:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f6a:	00194997          	auipc	s3,0x194
    80003f6e:	17e98993          	add	s3,s3,382 # 801980e8 <log>
    80003f72:	a00d                	j	80003f94 <install_trans+0x56>
    brelse(lbuf);
    80003f74:	854a                	mv	a0,s2
    80003f76:	fffff097          	auipc	ra,0xfffff
    80003f7a:	09e080e7          	jalr	158(ra) # 80003014 <brelse>
    brelse(dbuf);
    80003f7e:	8526                	mv	a0,s1
    80003f80:	fffff097          	auipc	ra,0xfffff
    80003f84:	094080e7          	jalr	148(ra) # 80003014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f88:	2a05                	addw	s4,s4,1
    80003f8a:	0a91                	add	s5,s5,4
    80003f8c:	02c9a783          	lw	a5,44(s3)
    80003f90:	04fa5e63          	bge	s4,a5,80003fec <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003f94:	0189a583          	lw	a1,24(s3)
    80003f98:	014585bb          	addw	a1,a1,s4
    80003f9c:	2585                	addw	a1,a1,1
    80003f9e:	0289a503          	lw	a0,40(s3)
    80003fa2:	fffff097          	auipc	ra,0xfffff
    80003fa6:	f42080e7          	jalr	-190(ra) # 80002ee4 <bread>
    80003faa:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003fac:	000aa583          	lw	a1,0(s5)
    80003fb0:	0289a503          	lw	a0,40(s3)
    80003fb4:	fffff097          	auipc	ra,0xfffff
    80003fb8:	f30080e7          	jalr	-208(ra) # 80002ee4 <bread>
    80003fbc:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003fbe:	40000613          	li	a2,1024
    80003fc2:	05890593          	add	a1,s2,88
    80003fc6:	05850513          	add	a0,a0,88
    80003fca:	ffffd097          	auipc	ra,0xffffd
    80003fce:	d60080e7          	jalr	-672(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003fd2:	8526                	mv	a0,s1
    80003fd4:	fffff097          	auipc	ra,0xfffff
    80003fd8:	002080e7          	jalr	2(ra) # 80002fd6 <bwrite>
    if(recovering == 0)
    80003fdc:	f80b1ce3          	bnez	s6,80003f74 <install_trans+0x36>
      bunpin(dbuf);
    80003fe0:	8526                	mv	a0,s1
    80003fe2:	fffff097          	auipc	ra,0xfffff
    80003fe6:	10a080e7          	jalr	266(ra) # 800030ec <bunpin>
    80003fea:	b769                	j	80003f74 <install_trans+0x36>
}
    80003fec:	70e2                	ld	ra,56(sp)
    80003fee:	7442                	ld	s0,48(sp)
    80003ff0:	74a2                	ld	s1,40(sp)
    80003ff2:	7902                	ld	s2,32(sp)
    80003ff4:	69e2                	ld	s3,24(sp)
    80003ff6:	6a42                	ld	s4,16(sp)
    80003ff8:	6aa2                	ld	s5,8(sp)
    80003ffa:	6b02                	ld	s6,0(sp)
    80003ffc:	6121                	add	sp,sp,64
    80003ffe:	8082                	ret
    80004000:	8082                	ret

0000000080004002 <initlog>:
{
    80004002:	7179                	add	sp,sp,-48
    80004004:	f406                	sd	ra,40(sp)
    80004006:	f022                	sd	s0,32(sp)
    80004008:	ec26                	sd	s1,24(sp)
    8000400a:	e84a                	sd	s2,16(sp)
    8000400c:	e44e                	sd	s3,8(sp)
    8000400e:	1800                	add	s0,sp,48
    80004010:	892a                	mv	s2,a0
    80004012:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004014:	00194497          	auipc	s1,0x194
    80004018:	0d448493          	add	s1,s1,212 # 801980e8 <log>
    8000401c:	00004597          	auipc	a1,0x4
    80004020:	63458593          	add	a1,a1,1588 # 80008650 <syscalls+0x1d8>
    80004024:	8526                	mv	a0,s1
    80004026:	ffffd097          	auipc	ra,0xffffd
    8000402a:	b1c080e7          	jalr	-1252(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    8000402e:	0149a583          	lw	a1,20(s3)
    80004032:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004034:	0109a783          	lw	a5,16(s3)
    80004038:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000403a:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    8000403e:	854a                	mv	a0,s2
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	ea4080e7          	jalr	-348(ra) # 80002ee4 <bread>
  log.lh.n = lh->n;
    80004048:	4d30                	lw	a2,88(a0)
    8000404a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000404c:	00c05f63          	blez	a2,8000406a <initlog+0x68>
    80004050:	87aa                	mv	a5,a0
    80004052:	00194717          	auipc	a4,0x194
    80004056:	0c670713          	add	a4,a4,198 # 80198118 <log+0x30>
    8000405a:	060a                	sll	a2,a2,0x2
    8000405c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000405e:	4ff4                	lw	a3,92(a5)
    80004060:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004062:	0791                	add	a5,a5,4
    80004064:	0711                	add	a4,a4,4
    80004066:	fec79ce3          	bne	a5,a2,8000405e <initlog+0x5c>
  brelse(buf);
    8000406a:	fffff097          	auipc	ra,0xfffff
    8000406e:	faa080e7          	jalr	-86(ra) # 80003014 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004072:	4505                	li	a0,1
    80004074:	00000097          	auipc	ra,0x0
    80004078:	eca080e7          	jalr	-310(ra) # 80003f3e <install_trans>
  log.lh.n = 0;
    8000407c:	00194797          	auipc	a5,0x194
    80004080:	0807ac23          	sw	zero,152(a5) # 80198114 <log+0x2c>
  write_head(); // clear the log
    80004084:	00000097          	auipc	ra,0x0
    80004088:	e50080e7          	jalr	-432(ra) # 80003ed4 <write_head>
}
    8000408c:	70a2                	ld	ra,40(sp)
    8000408e:	7402                	ld	s0,32(sp)
    80004090:	64e2                	ld	s1,24(sp)
    80004092:	6942                	ld	s2,16(sp)
    80004094:	69a2                	ld	s3,8(sp)
    80004096:	6145                	add	sp,sp,48
    80004098:	8082                	ret

000000008000409a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000409a:	1101                	add	sp,sp,-32
    8000409c:	ec06                	sd	ra,24(sp)
    8000409e:	e822                	sd	s0,16(sp)
    800040a0:	e426                	sd	s1,8(sp)
    800040a2:	e04a                	sd	s2,0(sp)
    800040a4:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800040a6:	00194517          	auipc	a0,0x194
    800040aa:	04250513          	add	a0,a0,66 # 801980e8 <log>
    800040ae:	ffffd097          	auipc	ra,0xffffd
    800040b2:	b24080e7          	jalr	-1244(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    800040b6:	00194497          	auipc	s1,0x194
    800040ba:	03248493          	add	s1,s1,50 # 801980e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040be:	4979                	li	s2,30
    800040c0:	a039                	j	800040ce <begin_op+0x34>
      sleep(&log, &log.lock);
    800040c2:	85a6                	mv	a1,s1
    800040c4:	8526                	mv	a0,s1
    800040c6:	ffffe097          	auipc	ra,0xffffe
    800040ca:	028080e7          	jalr	40(ra) # 800020ee <sleep>
    if(log.committing){
    800040ce:	50dc                	lw	a5,36(s1)
    800040d0:	fbed                	bnez	a5,800040c2 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800040d2:	5098                	lw	a4,32(s1)
    800040d4:	2705                	addw	a4,a4,1
    800040d6:	0027179b          	sllw	a5,a4,0x2
    800040da:	9fb9                	addw	a5,a5,a4
    800040dc:	0017979b          	sllw	a5,a5,0x1
    800040e0:	54d4                	lw	a3,44(s1)
    800040e2:	9fb5                	addw	a5,a5,a3
    800040e4:	00f95963          	bge	s2,a5,800040f6 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800040e8:	85a6                	mv	a1,s1
    800040ea:	8526                	mv	a0,s1
    800040ec:	ffffe097          	auipc	ra,0xffffe
    800040f0:	002080e7          	jalr	2(ra) # 800020ee <sleep>
    800040f4:	bfe9                	j	800040ce <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800040f6:	00194517          	auipc	a0,0x194
    800040fa:	ff250513          	add	a0,a0,-14 # 801980e8 <log>
    800040fe:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80004100:	ffffd097          	auipc	ra,0xffffd
    80004104:	b86080e7          	jalr	-1146(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004108:	60e2                	ld	ra,24(sp)
    8000410a:	6442                	ld	s0,16(sp)
    8000410c:	64a2                	ld	s1,8(sp)
    8000410e:	6902                	ld	s2,0(sp)
    80004110:	6105                	add	sp,sp,32
    80004112:	8082                	ret

0000000080004114 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004114:	7139                	add	sp,sp,-64
    80004116:	fc06                	sd	ra,56(sp)
    80004118:	f822                	sd	s0,48(sp)
    8000411a:	f426                	sd	s1,40(sp)
    8000411c:	f04a                	sd	s2,32(sp)
    8000411e:	ec4e                	sd	s3,24(sp)
    80004120:	e852                	sd	s4,16(sp)
    80004122:	e456                	sd	s5,8(sp)
    80004124:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004126:	00194497          	auipc	s1,0x194
    8000412a:	fc248493          	add	s1,s1,-62 # 801980e8 <log>
    8000412e:	8526                	mv	a0,s1
    80004130:	ffffd097          	auipc	ra,0xffffd
    80004134:	aa2080e7          	jalr	-1374(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    80004138:	509c                	lw	a5,32(s1)
    8000413a:	37fd                	addw	a5,a5,-1
    8000413c:	0007891b          	sext.w	s2,a5
    80004140:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004142:	50dc                	lw	a5,36(s1)
    80004144:	e7b9                	bnez	a5,80004192 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004146:	04091e63          	bnez	s2,800041a2 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000414a:	00194497          	auipc	s1,0x194
    8000414e:	f9e48493          	add	s1,s1,-98 # 801980e8 <log>
    80004152:	4785                	li	a5,1
    80004154:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004156:	8526                	mv	a0,s1
    80004158:	ffffd097          	auipc	ra,0xffffd
    8000415c:	b2e080e7          	jalr	-1234(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004160:	54dc                	lw	a5,44(s1)
    80004162:	06f04763          	bgtz	a5,800041d0 <end_op+0xbc>
    acquire(&log.lock);
    80004166:	00194497          	auipc	s1,0x194
    8000416a:	f8248493          	add	s1,s1,-126 # 801980e8 <log>
    8000416e:	8526                	mv	a0,s1
    80004170:	ffffd097          	auipc	ra,0xffffd
    80004174:	a62080e7          	jalr	-1438(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004178:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000417c:	8526                	mv	a0,s1
    8000417e:	ffffe097          	auipc	ra,0xffffe
    80004182:	fd4080e7          	jalr	-44(ra) # 80002152 <wakeup>
    release(&log.lock);
    80004186:	8526                	mv	a0,s1
    80004188:	ffffd097          	auipc	ra,0xffffd
    8000418c:	afe080e7          	jalr	-1282(ra) # 80000c86 <release>
}
    80004190:	a03d                	j	800041be <end_op+0xaa>
    panic("log.committing");
    80004192:	00004517          	auipc	a0,0x4
    80004196:	4c650513          	add	a0,a0,1222 # 80008658 <syscalls+0x1e0>
    8000419a:	ffffc097          	auipc	ra,0xffffc
    8000419e:	3a2080e7          	jalr	930(ra) # 8000053c <panic>
    wakeup(&log);
    800041a2:	00194497          	auipc	s1,0x194
    800041a6:	f4648493          	add	s1,s1,-186 # 801980e8 <log>
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffe097          	auipc	ra,0xffffe
    800041b0:	fa6080e7          	jalr	-90(ra) # 80002152 <wakeup>
  release(&log.lock);
    800041b4:	8526                	mv	a0,s1
    800041b6:	ffffd097          	auipc	ra,0xffffd
    800041ba:	ad0080e7          	jalr	-1328(ra) # 80000c86 <release>
}
    800041be:	70e2                	ld	ra,56(sp)
    800041c0:	7442                	ld	s0,48(sp)
    800041c2:	74a2                	ld	s1,40(sp)
    800041c4:	7902                	ld	s2,32(sp)
    800041c6:	69e2                	ld	s3,24(sp)
    800041c8:	6a42                	ld	s4,16(sp)
    800041ca:	6aa2                	ld	s5,8(sp)
    800041cc:	6121                	add	sp,sp,64
    800041ce:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800041d0:	00194a97          	auipc	s5,0x194
    800041d4:	f48a8a93          	add	s5,s5,-184 # 80198118 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800041d8:	00194a17          	auipc	s4,0x194
    800041dc:	f10a0a13          	add	s4,s4,-240 # 801980e8 <log>
    800041e0:	018a2583          	lw	a1,24(s4)
    800041e4:	012585bb          	addw	a1,a1,s2
    800041e8:	2585                	addw	a1,a1,1
    800041ea:	028a2503          	lw	a0,40(s4)
    800041ee:	fffff097          	auipc	ra,0xfffff
    800041f2:	cf6080e7          	jalr	-778(ra) # 80002ee4 <bread>
    800041f6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800041f8:	000aa583          	lw	a1,0(s5)
    800041fc:	028a2503          	lw	a0,40(s4)
    80004200:	fffff097          	auipc	ra,0xfffff
    80004204:	ce4080e7          	jalr	-796(ra) # 80002ee4 <bread>
    80004208:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000420a:	40000613          	li	a2,1024
    8000420e:	05850593          	add	a1,a0,88
    80004212:	05848513          	add	a0,s1,88
    80004216:	ffffd097          	auipc	ra,0xffffd
    8000421a:	b14080e7          	jalr	-1260(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    8000421e:	8526                	mv	a0,s1
    80004220:	fffff097          	auipc	ra,0xfffff
    80004224:	db6080e7          	jalr	-586(ra) # 80002fd6 <bwrite>
    brelse(from);
    80004228:	854e                	mv	a0,s3
    8000422a:	fffff097          	auipc	ra,0xfffff
    8000422e:	dea080e7          	jalr	-534(ra) # 80003014 <brelse>
    brelse(to);
    80004232:	8526                	mv	a0,s1
    80004234:	fffff097          	auipc	ra,0xfffff
    80004238:	de0080e7          	jalr	-544(ra) # 80003014 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000423c:	2905                	addw	s2,s2,1
    8000423e:	0a91                	add	s5,s5,4
    80004240:	02ca2783          	lw	a5,44(s4)
    80004244:	f8f94ee3          	blt	s2,a5,800041e0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004248:	00000097          	auipc	ra,0x0
    8000424c:	c8c080e7          	jalr	-884(ra) # 80003ed4 <write_head>
    install_trans(0); // Now install writes to home locations
    80004250:	4501                	li	a0,0
    80004252:	00000097          	auipc	ra,0x0
    80004256:	cec080e7          	jalr	-788(ra) # 80003f3e <install_trans>
    log.lh.n = 0;
    8000425a:	00194797          	auipc	a5,0x194
    8000425e:	ea07ad23          	sw	zero,-326(a5) # 80198114 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004262:	00000097          	auipc	ra,0x0
    80004266:	c72080e7          	jalr	-910(ra) # 80003ed4 <write_head>
    8000426a:	bdf5                	j	80004166 <end_op+0x52>

000000008000426c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000426c:	1101                	add	sp,sp,-32
    8000426e:	ec06                	sd	ra,24(sp)
    80004270:	e822                	sd	s0,16(sp)
    80004272:	e426                	sd	s1,8(sp)
    80004274:	e04a                	sd	s2,0(sp)
    80004276:	1000                	add	s0,sp,32
    80004278:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000427a:	00194917          	auipc	s2,0x194
    8000427e:	e6e90913          	add	s2,s2,-402 # 801980e8 <log>
    80004282:	854a                	mv	a0,s2
    80004284:	ffffd097          	auipc	ra,0xffffd
    80004288:	94e080e7          	jalr	-1714(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000428c:	02c92603          	lw	a2,44(s2)
    80004290:	47f5                	li	a5,29
    80004292:	06c7c563          	blt	a5,a2,800042fc <log_write+0x90>
    80004296:	00194797          	auipc	a5,0x194
    8000429a:	e6e7a783          	lw	a5,-402(a5) # 80198104 <log+0x1c>
    8000429e:	37fd                	addw	a5,a5,-1
    800042a0:	04f65e63          	bge	a2,a5,800042fc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042a4:	00194797          	auipc	a5,0x194
    800042a8:	e647a783          	lw	a5,-412(a5) # 80198108 <log+0x20>
    800042ac:	06f05063          	blez	a5,8000430c <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042b0:	4781                	li	a5,0
    800042b2:	06c05563          	blez	a2,8000431c <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042b6:	44cc                	lw	a1,12(s1)
    800042b8:	00194717          	auipc	a4,0x194
    800042bc:	e6070713          	add	a4,a4,-416 # 80198118 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800042c0:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800042c2:	4314                	lw	a3,0(a4)
    800042c4:	04b68c63          	beq	a3,a1,8000431c <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800042c8:	2785                	addw	a5,a5,1
    800042ca:	0711                	add	a4,a4,4
    800042cc:	fef61be3          	bne	a2,a5,800042c2 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800042d0:	0621                	add	a2,a2,8
    800042d2:	060a                	sll	a2,a2,0x2
    800042d4:	00194797          	auipc	a5,0x194
    800042d8:	e1478793          	add	a5,a5,-492 # 801980e8 <log>
    800042dc:	97b2                	add	a5,a5,a2
    800042de:	44d8                	lw	a4,12(s1)
    800042e0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800042e2:	8526                	mv	a0,s1
    800042e4:	fffff097          	auipc	ra,0xfffff
    800042e8:	dcc080e7          	jalr	-564(ra) # 800030b0 <bpin>
    log.lh.n++;
    800042ec:	00194717          	auipc	a4,0x194
    800042f0:	dfc70713          	add	a4,a4,-516 # 801980e8 <log>
    800042f4:	575c                	lw	a5,44(a4)
    800042f6:	2785                	addw	a5,a5,1
    800042f8:	d75c                	sw	a5,44(a4)
    800042fa:	a82d                	j	80004334 <log_write+0xc8>
    panic("too big a transaction");
    800042fc:	00004517          	auipc	a0,0x4
    80004300:	36c50513          	add	a0,a0,876 # 80008668 <syscalls+0x1f0>
    80004304:	ffffc097          	auipc	ra,0xffffc
    80004308:	238080e7          	jalr	568(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000430c:	00004517          	auipc	a0,0x4
    80004310:	37450513          	add	a0,a0,884 # 80008680 <syscalls+0x208>
    80004314:	ffffc097          	auipc	ra,0xffffc
    80004318:	228080e7          	jalr	552(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    8000431c:	00878693          	add	a3,a5,8
    80004320:	068a                	sll	a3,a3,0x2
    80004322:	00194717          	auipc	a4,0x194
    80004326:	dc670713          	add	a4,a4,-570 # 801980e8 <log>
    8000432a:	9736                	add	a4,a4,a3
    8000432c:	44d4                	lw	a3,12(s1)
    8000432e:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004330:	faf609e3          	beq	a2,a5,800042e2 <log_write+0x76>
  }
  release(&log.lock);
    80004334:	00194517          	auipc	a0,0x194
    80004338:	db450513          	add	a0,a0,-588 # 801980e8 <log>
    8000433c:	ffffd097          	auipc	ra,0xffffd
    80004340:	94a080e7          	jalr	-1718(ra) # 80000c86 <release>
}
    80004344:	60e2                	ld	ra,24(sp)
    80004346:	6442                	ld	s0,16(sp)
    80004348:	64a2                	ld	s1,8(sp)
    8000434a:	6902                	ld	s2,0(sp)
    8000434c:	6105                	add	sp,sp,32
    8000434e:	8082                	ret

0000000080004350 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004350:	1101                	add	sp,sp,-32
    80004352:	ec06                	sd	ra,24(sp)
    80004354:	e822                	sd	s0,16(sp)
    80004356:	e426                	sd	s1,8(sp)
    80004358:	e04a                	sd	s2,0(sp)
    8000435a:	1000                	add	s0,sp,32
    8000435c:	84aa                	mv	s1,a0
    8000435e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004360:	00004597          	auipc	a1,0x4
    80004364:	34058593          	add	a1,a1,832 # 800086a0 <syscalls+0x228>
    80004368:	0521                	add	a0,a0,8
    8000436a:	ffffc097          	auipc	ra,0xffffc
    8000436e:	7d8080e7          	jalr	2008(ra) # 80000b42 <initlock>
  lk->name = name;
    80004372:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004376:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000437a:	0204a423          	sw	zero,40(s1)
}
    8000437e:	60e2                	ld	ra,24(sp)
    80004380:	6442                	ld	s0,16(sp)
    80004382:	64a2                	ld	s1,8(sp)
    80004384:	6902                	ld	s2,0(sp)
    80004386:	6105                	add	sp,sp,32
    80004388:	8082                	ret

000000008000438a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000438a:	1101                	add	sp,sp,-32
    8000438c:	ec06                	sd	ra,24(sp)
    8000438e:	e822                	sd	s0,16(sp)
    80004390:	e426                	sd	s1,8(sp)
    80004392:	e04a                	sd	s2,0(sp)
    80004394:	1000                	add	s0,sp,32
    80004396:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004398:	00850913          	add	s2,a0,8
    8000439c:	854a                	mv	a0,s2
    8000439e:	ffffd097          	auipc	ra,0xffffd
    800043a2:	834080e7          	jalr	-1996(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800043a6:	409c                	lw	a5,0(s1)
    800043a8:	cb89                	beqz	a5,800043ba <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043aa:	85ca                	mv	a1,s2
    800043ac:	8526                	mv	a0,s1
    800043ae:	ffffe097          	auipc	ra,0xffffe
    800043b2:	d40080e7          	jalr	-704(ra) # 800020ee <sleep>
  while (lk->locked) {
    800043b6:	409c                	lw	a5,0(s1)
    800043b8:	fbed                	bnez	a5,800043aa <acquiresleep+0x20>
  }
  lk->locked = 1;
    800043ba:	4785                	li	a5,1
    800043bc:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800043be:	ffffd097          	auipc	ra,0xffffd
    800043c2:	624080e7          	jalr	1572(ra) # 800019e2 <myproc>
    800043c6:	591c                	lw	a5,48(a0)
    800043c8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800043ca:	854a                	mv	a0,s2
    800043cc:	ffffd097          	auipc	ra,0xffffd
    800043d0:	8ba080e7          	jalr	-1862(ra) # 80000c86 <release>
}
    800043d4:	60e2                	ld	ra,24(sp)
    800043d6:	6442                	ld	s0,16(sp)
    800043d8:	64a2                	ld	s1,8(sp)
    800043da:	6902                	ld	s2,0(sp)
    800043dc:	6105                	add	sp,sp,32
    800043de:	8082                	ret

00000000800043e0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800043e0:	1101                	add	sp,sp,-32
    800043e2:	ec06                	sd	ra,24(sp)
    800043e4:	e822                	sd	s0,16(sp)
    800043e6:	e426                	sd	s1,8(sp)
    800043e8:	e04a                	sd	s2,0(sp)
    800043ea:	1000                	add	s0,sp,32
    800043ec:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043ee:	00850913          	add	s2,a0,8
    800043f2:	854a                	mv	a0,s2
    800043f4:	ffffc097          	auipc	ra,0xffffc
    800043f8:	7de080e7          	jalr	2014(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800043fc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004400:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004404:	8526                	mv	a0,s1
    80004406:	ffffe097          	auipc	ra,0xffffe
    8000440a:	d4c080e7          	jalr	-692(ra) # 80002152 <wakeup>
  release(&lk->lk);
    8000440e:	854a                	mv	a0,s2
    80004410:	ffffd097          	auipc	ra,0xffffd
    80004414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
}
    80004418:	60e2                	ld	ra,24(sp)
    8000441a:	6442                	ld	s0,16(sp)
    8000441c:	64a2                	ld	s1,8(sp)
    8000441e:	6902                	ld	s2,0(sp)
    80004420:	6105                	add	sp,sp,32
    80004422:	8082                	ret

0000000080004424 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004424:	7179                	add	sp,sp,-48
    80004426:	f406                	sd	ra,40(sp)
    80004428:	f022                	sd	s0,32(sp)
    8000442a:	ec26                	sd	s1,24(sp)
    8000442c:	e84a                	sd	s2,16(sp)
    8000442e:	e44e                	sd	s3,8(sp)
    80004430:	1800                	add	s0,sp,48
    80004432:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004434:	00850913          	add	s2,a0,8
    80004438:	854a                	mv	a0,s2
    8000443a:	ffffc097          	auipc	ra,0xffffc
    8000443e:	798080e7          	jalr	1944(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004442:	409c                	lw	a5,0(s1)
    80004444:	ef99                	bnez	a5,80004462 <holdingsleep+0x3e>
    80004446:	4481                	li	s1,0
  release(&lk->lk);
    80004448:	854a                	mv	a0,s2
    8000444a:	ffffd097          	auipc	ra,0xffffd
    8000444e:	83c080e7          	jalr	-1988(ra) # 80000c86 <release>
  return r;
}
    80004452:	8526                	mv	a0,s1
    80004454:	70a2                	ld	ra,40(sp)
    80004456:	7402                	ld	s0,32(sp)
    80004458:	64e2                	ld	s1,24(sp)
    8000445a:	6942                	ld	s2,16(sp)
    8000445c:	69a2                	ld	s3,8(sp)
    8000445e:	6145                	add	sp,sp,48
    80004460:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004462:	0284a983          	lw	s3,40(s1)
    80004466:	ffffd097          	auipc	ra,0xffffd
    8000446a:	57c080e7          	jalr	1404(ra) # 800019e2 <myproc>
    8000446e:	5904                	lw	s1,48(a0)
    80004470:	413484b3          	sub	s1,s1,s3
    80004474:	0014b493          	seqz	s1,s1
    80004478:	bfc1                	j	80004448 <holdingsleep+0x24>

000000008000447a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000447a:	1141                	add	sp,sp,-16
    8000447c:	e406                	sd	ra,8(sp)
    8000447e:	e022                	sd	s0,0(sp)
    80004480:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004482:	00004597          	auipc	a1,0x4
    80004486:	22e58593          	add	a1,a1,558 # 800086b0 <syscalls+0x238>
    8000448a:	00194517          	auipc	a0,0x194
    8000448e:	da650513          	add	a0,a0,-602 # 80198230 <ftable>
    80004492:	ffffc097          	auipc	ra,0xffffc
    80004496:	6b0080e7          	jalr	1712(ra) # 80000b42 <initlock>
}
    8000449a:	60a2                	ld	ra,8(sp)
    8000449c:	6402                	ld	s0,0(sp)
    8000449e:	0141                	add	sp,sp,16
    800044a0:	8082                	ret

00000000800044a2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044a2:	1101                	add	sp,sp,-32
    800044a4:	ec06                	sd	ra,24(sp)
    800044a6:	e822                	sd	s0,16(sp)
    800044a8:	e426                	sd	s1,8(sp)
    800044aa:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044ac:	00194517          	auipc	a0,0x194
    800044b0:	d8450513          	add	a0,a0,-636 # 80198230 <ftable>
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	71e080e7          	jalr	1822(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044bc:	00194497          	auipc	s1,0x194
    800044c0:	d8c48493          	add	s1,s1,-628 # 80198248 <ftable+0x18>
    800044c4:	00195717          	auipc	a4,0x195
    800044c8:	d2470713          	add	a4,a4,-732 # 801991e8 <disk>
    if(f->ref == 0){
    800044cc:	40dc                	lw	a5,4(s1)
    800044ce:	cf99                	beqz	a5,800044ec <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800044d0:	02848493          	add	s1,s1,40
    800044d4:	fee49ce3          	bne	s1,a4,800044cc <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    800044d8:	00194517          	auipc	a0,0x194
    800044dc:	d5850513          	add	a0,a0,-680 # 80198230 <ftable>
    800044e0:	ffffc097          	auipc	ra,0xffffc
    800044e4:	7a6080e7          	jalr	1958(ra) # 80000c86 <release>
  return 0;
    800044e8:	4481                	li	s1,0
    800044ea:	a819                	j	80004500 <filealloc+0x5e>
      f->ref = 1;
    800044ec:	4785                	li	a5,1
    800044ee:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800044f0:	00194517          	auipc	a0,0x194
    800044f4:	d4050513          	add	a0,a0,-704 # 80198230 <ftable>
    800044f8:	ffffc097          	auipc	ra,0xffffc
    800044fc:	78e080e7          	jalr	1934(ra) # 80000c86 <release>
}
    80004500:	8526                	mv	a0,s1
    80004502:	60e2                	ld	ra,24(sp)
    80004504:	6442                	ld	s0,16(sp)
    80004506:	64a2                	ld	s1,8(sp)
    80004508:	6105                	add	sp,sp,32
    8000450a:	8082                	ret

000000008000450c <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000450c:	1101                	add	sp,sp,-32
    8000450e:	ec06                	sd	ra,24(sp)
    80004510:	e822                	sd	s0,16(sp)
    80004512:	e426                	sd	s1,8(sp)
    80004514:	1000                	add	s0,sp,32
    80004516:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004518:	00194517          	auipc	a0,0x194
    8000451c:	d1850513          	add	a0,a0,-744 # 80198230 <ftable>
    80004520:	ffffc097          	auipc	ra,0xffffc
    80004524:	6b2080e7          	jalr	1714(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004528:	40dc                	lw	a5,4(s1)
    8000452a:	02f05263          	blez	a5,8000454e <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000452e:	2785                	addw	a5,a5,1
    80004530:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004532:	00194517          	auipc	a0,0x194
    80004536:	cfe50513          	add	a0,a0,-770 # 80198230 <ftable>
    8000453a:	ffffc097          	auipc	ra,0xffffc
    8000453e:	74c080e7          	jalr	1868(ra) # 80000c86 <release>
  return f;
}
    80004542:	8526                	mv	a0,s1
    80004544:	60e2                	ld	ra,24(sp)
    80004546:	6442                	ld	s0,16(sp)
    80004548:	64a2                	ld	s1,8(sp)
    8000454a:	6105                	add	sp,sp,32
    8000454c:	8082                	ret
    panic("filedup");
    8000454e:	00004517          	auipc	a0,0x4
    80004552:	16a50513          	add	a0,a0,362 # 800086b8 <syscalls+0x240>
    80004556:	ffffc097          	auipc	ra,0xffffc
    8000455a:	fe6080e7          	jalr	-26(ra) # 8000053c <panic>

000000008000455e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000455e:	7139                	add	sp,sp,-64
    80004560:	fc06                	sd	ra,56(sp)
    80004562:	f822                	sd	s0,48(sp)
    80004564:	f426                	sd	s1,40(sp)
    80004566:	f04a                	sd	s2,32(sp)
    80004568:	ec4e                	sd	s3,24(sp)
    8000456a:	e852                	sd	s4,16(sp)
    8000456c:	e456                	sd	s5,8(sp)
    8000456e:	0080                	add	s0,sp,64
    80004570:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004572:	00194517          	auipc	a0,0x194
    80004576:	cbe50513          	add	a0,a0,-834 # 80198230 <ftable>
    8000457a:	ffffc097          	auipc	ra,0xffffc
    8000457e:	658080e7          	jalr	1624(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004582:	40dc                	lw	a5,4(s1)
    80004584:	06f05163          	blez	a5,800045e6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004588:	37fd                	addw	a5,a5,-1
    8000458a:	0007871b          	sext.w	a4,a5
    8000458e:	c0dc                	sw	a5,4(s1)
    80004590:	06e04363          	bgtz	a4,800045f6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004594:	0004a903          	lw	s2,0(s1)
    80004598:	0094ca83          	lbu	s5,9(s1)
    8000459c:	0104ba03          	ld	s4,16(s1)
    800045a0:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045a4:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045a8:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045ac:	00194517          	auipc	a0,0x194
    800045b0:	c8450513          	add	a0,a0,-892 # 80198230 <ftable>
    800045b4:	ffffc097          	auipc	ra,0xffffc
    800045b8:	6d2080e7          	jalr	1746(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800045bc:	4785                	li	a5,1
    800045be:	04f90d63          	beq	s2,a5,80004618 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800045c2:	3979                	addw	s2,s2,-2
    800045c4:	4785                	li	a5,1
    800045c6:	0527e063          	bltu	a5,s2,80004606 <fileclose+0xa8>
    begin_op();
    800045ca:	00000097          	auipc	ra,0x0
    800045ce:	ad0080e7          	jalr	-1328(ra) # 8000409a <begin_op>
    iput(ff.ip);
    800045d2:	854e                	mv	a0,s3
    800045d4:	fffff097          	auipc	ra,0xfffff
    800045d8:	2da080e7          	jalr	730(ra) # 800038ae <iput>
    end_op();
    800045dc:	00000097          	auipc	ra,0x0
    800045e0:	b38080e7          	jalr	-1224(ra) # 80004114 <end_op>
    800045e4:	a00d                	j	80004606 <fileclose+0xa8>
    panic("fileclose");
    800045e6:	00004517          	auipc	a0,0x4
    800045ea:	0da50513          	add	a0,a0,218 # 800086c0 <syscalls+0x248>
    800045ee:	ffffc097          	auipc	ra,0xffffc
    800045f2:	f4e080e7          	jalr	-178(ra) # 8000053c <panic>
    release(&ftable.lock);
    800045f6:	00194517          	auipc	a0,0x194
    800045fa:	c3a50513          	add	a0,a0,-966 # 80198230 <ftable>
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	688080e7          	jalr	1672(ra) # 80000c86 <release>
  }
}
    80004606:	70e2                	ld	ra,56(sp)
    80004608:	7442                	ld	s0,48(sp)
    8000460a:	74a2                	ld	s1,40(sp)
    8000460c:	7902                	ld	s2,32(sp)
    8000460e:	69e2                	ld	s3,24(sp)
    80004610:	6a42                	ld	s4,16(sp)
    80004612:	6aa2                	ld	s5,8(sp)
    80004614:	6121                	add	sp,sp,64
    80004616:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004618:	85d6                	mv	a1,s5
    8000461a:	8552                	mv	a0,s4
    8000461c:	00000097          	auipc	ra,0x0
    80004620:	348080e7          	jalr	840(ra) # 80004964 <pipeclose>
    80004624:	b7cd                	j	80004606 <fileclose+0xa8>

0000000080004626 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004626:	715d                	add	sp,sp,-80
    80004628:	e486                	sd	ra,72(sp)
    8000462a:	e0a2                	sd	s0,64(sp)
    8000462c:	fc26                	sd	s1,56(sp)
    8000462e:	f84a                	sd	s2,48(sp)
    80004630:	f44e                	sd	s3,40(sp)
    80004632:	0880                	add	s0,sp,80
    80004634:	84aa                	mv	s1,a0
    80004636:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004638:	ffffd097          	auipc	ra,0xffffd
    8000463c:	3aa080e7          	jalr	938(ra) # 800019e2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004640:	409c                	lw	a5,0(s1)
    80004642:	37f9                	addw	a5,a5,-2
    80004644:	4705                	li	a4,1
    80004646:	04f76763          	bltu	a4,a5,80004694 <filestat+0x6e>
    8000464a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000464c:	6c88                	ld	a0,24(s1)
    8000464e:	fffff097          	auipc	ra,0xfffff
    80004652:	0a6080e7          	jalr	166(ra) # 800036f4 <ilock>
    stati(f->ip, &st);
    80004656:	fb840593          	add	a1,s0,-72
    8000465a:	6c88                	ld	a0,24(s1)
    8000465c:	fffff097          	auipc	ra,0xfffff
    80004660:	322080e7          	jalr	802(ra) # 8000397e <stati>
    iunlock(f->ip);
    80004664:	6c88                	ld	a0,24(s1)
    80004666:	fffff097          	auipc	ra,0xfffff
    8000466a:	150080e7          	jalr	336(ra) # 800037b6 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000466e:	46e1                	li	a3,24
    80004670:	fb840613          	add	a2,s0,-72
    80004674:	85ce                	mv	a1,s3
    80004676:	05093503          	ld	a0,80(s2)
    8000467a:	ffffd097          	auipc	ra,0xffffd
    8000467e:	018080e7          	jalr	24(ra) # 80001692 <copyout>
    80004682:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004686:	60a6                	ld	ra,72(sp)
    80004688:	6406                	ld	s0,64(sp)
    8000468a:	74e2                	ld	s1,56(sp)
    8000468c:	7942                	ld	s2,48(sp)
    8000468e:	79a2                	ld	s3,40(sp)
    80004690:	6161                	add	sp,sp,80
    80004692:	8082                	ret
  return -1;
    80004694:	557d                	li	a0,-1
    80004696:	bfc5                	j	80004686 <filestat+0x60>

0000000080004698 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004698:	7179                	add	sp,sp,-48
    8000469a:	f406                	sd	ra,40(sp)
    8000469c:	f022                	sd	s0,32(sp)
    8000469e:	ec26                	sd	s1,24(sp)
    800046a0:	e84a                	sd	s2,16(sp)
    800046a2:	e44e                	sd	s3,8(sp)
    800046a4:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046a6:	00854783          	lbu	a5,8(a0)
    800046aa:	c3d5                	beqz	a5,8000474e <fileread+0xb6>
    800046ac:	84aa                	mv	s1,a0
    800046ae:	89ae                	mv	s3,a1
    800046b0:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046b2:	411c                	lw	a5,0(a0)
    800046b4:	4705                	li	a4,1
    800046b6:	04e78963          	beq	a5,a4,80004708 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046ba:	470d                	li	a4,3
    800046bc:	04e78d63          	beq	a5,a4,80004716 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800046c0:	4709                	li	a4,2
    800046c2:	06e79e63          	bne	a5,a4,8000473e <fileread+0xa6>
    ilock(f->ip);
    800046c6:	6d08                	ld	a0,24(a0)
    800046c8:	fffff097          	auipc	ra,0xfffff
    800046cc:	02c080e7          	jalr	44(ra) # 800036f4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800046d0:	874a                	mv	a4,s2
    800046d2:	5094                	lw	a3,32(s1)
    800046d4:	864e                	mv	a2,s3
    800046d6:	4585                	li	a1,1
    800046d8:	6c88                	ld	a0,24(s1)
    800046da:	fffff097          	auipc	ra,0xfffff
    800046de:	2ce080e7          	jalr	718(ra) # 800039a8 <readi>
    800046e2:	892a                	mv	s2,a0
    800046e4:	00a05563          	blez	a0,800046ee <fileread+0x56>
      f->off += r;
    800046e8:	509c                	lw	a5,32(s1)
    800046ea:	9fa9                	addw	a5,a5,a0
    800046ec:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800046ee:	6c88                	ld	a0,24(s1)
    800046f0:	fffff097          	auipc	ra,0xfffff
    800046f4:	0c6080e7          	jalr	198(ra) # 800037b6 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800046f8:	854a                	mv	a0,s2
    800046fa:	70a2                	ld	ra,40(sp)
    800046fc:	7402                	ld	s0,32(sp)
    800046fe:	64e2                	ld	s1,24(sp)
    80004700:	6942                	ld	s2,16(sp)
    80004702:	69a2                	ld	s3,8(sp)
    80004704:	6145                	add	sp,sp,48
    80004706:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004708:	6908                	ld	a0,16(a0)
    8000470a:	00000097          	auipc	ra,0x0
    8000470e:	3c2080e7          	jalr	962(ra) # 80004acc <piperead>
    80004712:	892a                	mv	s2,a0
    80004714:	b7d5                	j	800046f8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004716:	02451783          	lh	a5,36(a0)
    8000471a:	03079693          	sll	a3,a5,0x30
    8000471e:	92c1                	srl	a3,a3,0x30
    80004720:	4725                	li	a4,9
    80004722:	02d76863          	bltu	a4,a3,80004752 <fileread+0xba>
    80004726:	0792                	sll	a5,a5,0x4
    80004728:	00194717          	auipc	a4,0x194
    8000472c:	a6870713          	add	a4,a4,-1432 # 80198190 <devsw>
    80004730:	97ba                	add	a5,a5,a4
    80004732:	639c                	ld	a5,0(a5)
    80004734:	c38d                	beqz	a5,80004756 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004736:	4505                	li	a0,1
    80004738:	9782                	jalr	a5
    8000473a:	892a                	mv	s2,a0
    8000473c:	bf75                	j	800046f8 <fileread+0x60>
    panic("fileread");
    8000473e:	00004517          	auipc	a0,0x4
    80004742:	f9250513          	add	a0,a0,-110 # 800086d0 <syscalls+0x258>
    80004746:	ffffc097          	auipc	ra,0xffffc
    8000474a:	df6080e7          	jalr	-522(ra) # 8000053c <panic>
    return -1;
    8000474e:	597d                	li	s2,-1
    80004750:	b765                	j	800046f8 <fileread+0x60>
      return -1;
    80004752:	597d                	li	s2,-1
    80004754:	b755                	j	800046f8 <fileread+0x60>
    80004756:	597d                	li	s2,-1
    80004758:	b745                	j	800046f8 <fileread+0x60>

000000008000475a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000475a:	00954783          	lbu	a5,9(a0)
    8000475e:	10078e63          	beqz	a5,8000487a <filewrite+0x120>
{
    80004762:	715d                	add	sp,sp,-80
    80004764:	e486                	sd	ra,72(sp)
    80004766:	e0a2                	sd	s0,64(sp)
    80004768:	fc26                	sd	s1,56(sp)
    8000476a:	f84a                	sd	s2,48(sp)
    8000476c:	f44e                	sd	s3,40(sp)
    8000476e:	f052                	sd	s4,32(sp)
    80004770:	ec56                	sd	s5,24(sp)
    80004772:	e85a                	sd	s6,16(sp)
    80004774:	e45e                	sd	s7,8(sp)
    80004776:	e062                	sd	s8,0(sp)
    80004778:	0880                	add	s0,sp,80
    8000477a:	892a                	mv	s2,a0
    8000477c:	8b2e                	mv	s6,a1
    8000477e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004780:	411c                	lw	a5,0(a0)
    80004782:	4705                	li	a4,1
    80004784:	02e78263          	beq	a5,a4,800047a8 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004788:	470d                	li	a4,3
    8000478a:	02e78563          	beq	a5,a4,800047b4 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000478e:	4709                	li	a4,2
    80004790:	0ce79d63          	bne	a5,a4,8000486a <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004794:	0ac05b63          	blez	a2,8000484a <filewrite+0xf0>
    int i = 0;
    80004798:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000479a:	6b85                	lui	s7,0x1
    8000479c:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047a0:	6c05                	lui	s8,0x1
    800047a2:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047a6:	a851                	j	8000483a <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800047a8:	6908                	ld	a0,16(a0)
    800047aa:	00000097          	auipc	ra,0x0
    800047ae:	22a080e7          	jalr	554(ra) # 800049d4 <pipewrite>
    800047b2:	a045                	j	80004852 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047b4:	02451783          	lh	a5,36(a0)
    800047b8:	03079693          	sll	a3,a5,0x30
    800047bc:	92c1                	srl	a3,a3,0x30
    800047be:	4725                	li	a4,9
    800047c0:	0ad76f63          	bltu	a4,a3,8000487e <filewrite+0x124>
    800047c4:	0792                	sll	a5,a5,0x4
    800047c6:	00194717          	auipc	a4,0x194
    800047ca:	9ca70713          	add	a4,a4,-1590 # 80198190 <devsw>
    800047ce:	97ba                	add	a5,a5,a4
    800047d0:	679c                	ld	a5,8(a5)
    800047d2:	cbc5                	beqz	a5,80004882 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    800047d4:	4505                	li	a0,1
    800047d6:	9782                	jalr	a5
    800047d8:	a8ad                	j	80004852 <filewrite+0xf8>
      if(n1 > max)
    800047da:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800047de:	00000097          	auipc	ra,0x0
    800047e2:	8bc080e7          	jalr	-1860(ra) # 8000409a <begin_op>
      ilock(f->ip);
    800047e6:	01893503          	ld	a0,24(s2)
    800047ea:	fffff097          	auipc	ra,0xfffff
    800047ee:	f0a080e7          	jalr	-246(ra) # 800036f4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800047f2:	8756                	mv	a4,s5
    800047f4:	02092683          	lw	a3,32(s2)
    800047f8:	01698633          	add	a2,s3,s6
    800047fc:	4585                	li	a1,1
    800047fe:	01893503          	ld	a0,24(s2)
    80004802:	fffff097          	auipc	ra,0xfffff
    80004806:	29e080e7          	jalr	670(ra) # 80003aa0 <writei>
    8000480a:	84aa                	mv	s1,a0
    8000480c:	00a05763          	blez	a0,8000481a <filewrite+0xc0>
        f->off += r;
    80004810:	02092783          	lw	a5,32(s2)
    80004814:	9fa9                	addw	a5,a5,a0
    80004816:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    8000481a:	01893503          	ld	a0,24(s2)
    8000481e:	fffff097          	auipc	ra,0xfffff
    80004822:	f98080e7          	jalr	-104(ra) # 800037b6 <iunlock>
      end_op();
    80004826:	00000097          	auipc	ra,0x0
    8000482a:	8ee080e7          	jalr	-1810(ra) # 80004114 <end_op>

      if(r != n1){
    8000482e:	009a9f63          	bne	s5,s1,8000484c <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004832:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004836:	0149db63          	bge	s3,s4,8000484c <filewrite+0xf2>
      int n1 = n - i;
    8000483a:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000483e:	0004879b          	sext.w	a5,s1
    80004842:	f8fbdce3          	bge	s7,a5,800047da <filewrite+0x80>
    80004846:	84e2                	mv	s1,s8
    80004848:	bf49                	j	800047da <filewrite+0x80>
    int i = 0;
    8000484a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000484c:	033a1d63          	bne	s4,s3,80004886 <filewrite+0x12c>
    80004850:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004852:	60a6                	ld	ra,72(sp)
    80004854:	6406                	ld	s0,64(sp)
    80004856:	74e2                	ld	s1,56(sp)
    80004858:	7942                	ld	s2,48(sp)
    8000485a:	79a2                	ld	s3,40(sp)
    8000485c:	7a02                	ld	s4,32(sp)
    8000485e:	6ae2                	ld	s5,24(sp)
    80004860:	6b42                	ld	s6,16(sp)
    80004862:	6ba2                	ld	s7,8(sp)
    80004864:	6c02                	ld	s8,0(sp)
    80004866:	6161                	add	sp,sp,80
    80004868:	8082                	ret
    panic("filewrite");
    8000486a:	00004517          	auipc	a0,0x4
    8000486e:	e7650513          	add	a0,a0,-394 # 800086e0 <syscalls+0x268>
    80004872:	ffffc097          	auipc	ra,0xffffc
    80004876:	cca080e7          	jalr	-822(ra) # 8000053c <panic>
    return -1;
    8000487a:	557d                	li	a0,-1
}
    8000487c:	8082                	ret
      return -1;
    8000487e:	557d                	li	a0,-1
    80004880:	bfc9                	j	80004852 <filewrite+0xf8>
    80004882:	557d                	li	a0,-1
    80004884:	b7f9                	j	80004852 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004886:	557d                	li	a0,-1
    80004888:	b7e9                	j	80004852 <filewrite+0xf8>

000000008000488a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000488a:	7179                	add	sp,sp,-48
    8000488c:	f406                	sd	ra,40(sp)
    8000488e:	f022                	sd	s0,32(sp)
    80004890:	ec26                	sd	s1,24(sp)
    80004892:	e84a                	sd	s2,16(sp)
    80004894:	e44e                	sd	s3,8(sp)
    80004896:	e052                	sd	s4,0(sp)
    80004898:	1800                	add	s0,sp,48
    8000489a:	84aa                	mv	s1,a0
    8000489c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000489e:	0005b023          	sd	zero,0(a1)
    800048a2:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048a6:	00000097          	auipc	ra,0x0
    800048aa:	bfc080e7          	jalr	-1028(ra) # 800044a2 <filealloc>
    800048ae:	e088                	sd	a0,0(s1)
    800048b0:	c551                	beqz	a0,8000493c <pipealloc+0xb2>
    800048b2:	00000097          	auipc	ra,0x0
    800048b6:	bf0080e7          	jalr	-1040(ra) # 800044a2 <filealloc>
    800048ba:	00aa3023          	sd	a0,0(s4)
    800048be:	c92d                	beqz	a0,80004930 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800048c0:	ffffc097          	auipc	ra,0xffffc
    800048c4:	222080e7          	jalr	546(ra) # 80000ae2 <kalloc>
    800048c8:	892a                	mv	s2,a0
    800048ca:	c125                	beqz	a0,8000492a <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800048cc:	4985                	li	s3,1
    800048ce:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    800048d2:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    800048d6:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    800048da:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    800048de:	00004597          	auipc	a1,0x4
    800048e2:	e1258593          	add	a1,a1,-494 # 800086f0 <syscalls+0x278>
    800048e6:	ffffc097          	auipc	ra,0xffffc
    800048ea:	25c080e7          	jalr	604(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    800048ee:	609c                	ld	a5,0(s1)
    800048f0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800048f4:	609c                	ld	a5,0(s1)
    800048f6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800048fa:	609c                	ld	a5,0(s1)
    800048fc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004900:	609c                	ld	a5,0(s1)
    80004902:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004906:	000a3783          	ld	a5,0(s4)
    8000490a:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000490e:	000a3783          	ld	a5,0(s4)
    80004912:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004916:	000a3783          	ld	a5,0(s4)
    8000491a:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000491e:	000a3783          	ld	a5,0(s4)
    80004922:	0127b823          	sd	s2,16(a5)
  return 0;
    80004926:	4501                	li	a0,0
    80004928:	a025                	j	80004950 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    8000492a:	6088                	ld	a0,0(s1)
    8000492c:	e501                	bnez	a0,80004934 <pipealloc+0xaa>
    8000492e:	a039                	j	8000493c <pipealloc+0xb2>
    80004930:	6088                	ld	a0,0(s1)
    80004932:	c51d                	beqz	a0,80004960 <pipealloc+0xd6>
    fileclose(*f0);
    80004934:	00000097          	auipc	ra,0x0
    80004938:	c2a080e7          	jalr	-982(ra) # 8000455e <fileclose>
  if(*f1)
    8000493c:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004940:	557d                	li	a0,-1
  if(*f1)
    80004942:	c799                	beqz	a5,80004950 <pipealloc+0xc6>
    fileclose(*f1);
    80004944:	853e                	mv	a0,a5
    80004946:	00000097          	auipc	ra,0x0
    8000494a:	c18080e7          	jalr	-1000(ra) # 8000455e <fileclose>
  return -1;
    8000494e:	557d                	li	a0,-1
}
    80004950:	70a2                	ld	ra,40(sp)
    80004952:	7402                	ld	s0,32(sp)
    80004954:	64e2                	ld	s1,24(sp)
    80004956:	6942                	ld	s2,16(sp)
    80004958:	69a2                	ld	s3,8(sp)
    8000495a:	6a02                	ld	s4,0(sp)
    8000495c:	6145                	add	sp,sp,48
    8000495e:	8082                	ret
  return -1;
    80004960:	557d                	li	a0,-1
    80004962:	b7fd                	j	80004950 <pipealloc+0xc6>

0000000080004964 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004964:	1101                	add	sp,sp,-32
    80004966:	ec06                	sd	ra,24(sp)
    80004968:	e822                	sd	s0,16(sp)
    8000496a:	e426                	sd	s1,8(sp)
    8000496c:	e04a                	sd	s2,0(sp)
    8000496e:	1000                	add	s0,sp,32
    80004970:	84aa                	mv	s1,a0
    80004972:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004974:	ffffc097          	auipc	ra,0xffffc
    80004978:	25e080e7          	jalr	606(ra) # 80000bd2 <acquire>
  if(writable){
    8000497c:	02090d63          	beqz	s2,800049b6 <pipeclose+0x52>
    pi->writeopen = 0;
    80004980:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004984:	21848513          	add	a0,s1,536
    80004988:	ffffd097          	auipc	ra,0xffffd
    8000498c:	7ca080e7          	jalr	1994(ra) # 80002152 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004990:	2204b783          	ld	a5,544(s1)
    80004994:	eb95                	bnez	a5,800049c8 <pipeclose+0x64>
    release(&pi->lock);
    80004996:	8526                	mv	a0,s1
    80004998:	ffffc097          	auipc	ra,0xffffc
    8000499c:	2ee080e7          	jalr	750(ra) # 80000c86 <release>
    kfree((char*)pi);
    800049a0:	8526                	mv	a0,s1
    800049a2:	ffffc097          	auipc	ra,0xffffc
    800049a6:	042080e7          	jalr	66(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800049aa:	60e2                	ld	ra,24(sp)
    800049ac:	6442                	ld	s0,16(sp)
    800049ae:	64a2                	ld	s1,8(sp)
    800049b0:	6902                	ld	s2,0(sp)
    800049b2:	6105                	add	sp,sp,32
    800049b4:	8082                	ret
    pi->readopen = 0;
    800049b6:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800049ba:	21c48513          	add	a0,s1,540
    800049be:	ffffd097          	auipc	ra,0xffffd
    800049c2:	794080e7          	jalr	1940(ra) # 80002152 <wakeup>
    800049c6:	b7e9                	j	80004990 <pipeclose+0x2c>
    release(&pi->lock);
    800049c8:	8526                	mv	a0,s1
    800049ca:	ffffc097          	auipc	ra,0xffffc
    800049ce:	2bc080e7          	jalr	700(ra) # 80000c86 <release>
}
    800049d2:	bfe1                	j	800049aa <pipeclose+0x46>

00000000800049d4 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    800049d4:	711d                	add	sp,sp,-96
    800049d6:	ec86                	sd	ra,88(sp)
    800049d8:	e8a2                	sd	s0,80(sp)
    800049da:	e4a6                	sd	s1,72(sp)
    800049dc:	e0ca                	sd	s2,64(sp)
    800049de:	fc4e                	sd	s3,56(sp)
    800049e0:	f852                	sd	s4,48(sp)
    800049e2:	f456                	sd	s5,40(sp)
    800049e4:	f05a                	sd	s6,32(sp)
    800049e6:	ec5e                	sd	s7,24(sp)
    800049e8:	e862                	sd	s8,16(sp)
    800049ea:	1080                	add	s0,sp,96
    800049ec:	84aa                	mv	s1,a0
    800049ee:	8aae                	mv	s5,a1
    800049f0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    800049f2:	ffffd097          	auipc	ra,0xffffd
    800049f6:	ff0080e7          	jalr	-16(ra) # 800019e2 <myproc>
    800049fa:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    800049fc:	8526                	mv	a0,s1
    800049fe:	ffffc097          	auipc	ra,0xffffc
    80004a02:	1d4080e7          	jalr	468(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a06:	0b405663          	blez	s4,80004ab2 <pipewrite+0xde>
  int i = 0;
    80004a0a:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a0c:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a0e:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a12:	21c48b93          	add	s7,s1,540
    80004a16:	a089                	j	80004a58 <pipewrite+0x84>
      release(&pi->lock);
    80004a18:	8526                	mv	a0,s1
    80004a1a:	ffffc097          	auipc	ra,0xffffc
    80004a1e:	26c080e7          	jalr	620(ra) # 80000c86 <release>
      return -1;
    80004a22:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a24:	854a                	mv	a0,s2
    80004a26:	60e6                	ld	ra,88(sp)
    80004a28:	6446                	ld	s0,80(sp)
    80004a2a:	64a6                	ld	s1,72(sp)
    80004a2c:	6906                	ld	s2,64(sp)
    80004a2e:	79e2                	ld	s3,56(sp)
    80004a30:	7a42                	ld	s4,48(sp)
    80004a32:	7aa2                	ld	s5,40(sp)
    80004a34:	7b02                	ld	s6,32(sp)
    80004a36:	6be2                	ld	s7,24(sp)
    80004a38:	6c42                	ld	s8,16(sp)
    80004a3a:	6125                	add	sp,sp,96
    80004a3c:	8082                	ret
      wakeup(&pi->nread);
    80004a3e:	8562                	mv	a0,s8
    80004a40:	ffffd097          	auipc	ra,0xffffd
    80004a44:	712080e7          	jalr	1810(ra) # 80002152 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a48:	85a6                	mv	a1,s1
    80004a4a:	855e                	mv	a0,s7
    80004a4c:	ffffd097          	auipc	ra,0xffffd
    80004a50:	6a2080e7          	jalr	1698(ra) # 800020ee <sleep>
  while(i < n){
    80004a54:	07495063          	bge	s2,s4,80004ab4 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004a58:	2204a783          	lw	a5,544(s1)
    80004a5c:	dfd5                	beqz	a5,80004a18 <pipewrite+0x44>
    80004a5e:	854e                	mv	a0,s3
    80004a60:	ffffe097          	auipc	ra,0xffffe
    80004a64:	94e080e7          	jalr	-1714(ra) # 800023ae <killed>
    80004a68:	f945                	bnez	a0,80004a18 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004a6a:	2184a783          	lw	a5,536(s1)
    80004a6e:	21c4a703          	lw	a4,540(s1)
    80004a72:	2007879b          	addw	a5,a5,512
    80004a76:	fcf704e3          	beq	a4,a5,80004a3e <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a7a:	4685                	li	a3,1
    80004a7c:	01590633          	add	a2,s2,s5
    80004a80:	faf40593          	add	a1,s0,-81
    80004a84:	0509b503          	ld	a0,80(s3)
    80004a88:	ffffd097          	auipc	ra,0xffffd
    80004a8c:	c96080e7          	jalr	-874(ra) # 8000171e <copyin>
    80004a90:	03650263          	beq	a0,s6,80004ab4 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004a94:	21c4a783          	lw	a5,540(s1)
    80004a98:	0017871b          	addw	a4,a5,1
    80004a9c:	20e4ae23          	sw	a4,540(s1)
    80004aa0:	1ff7f793          	and	a5,a5,511
    80004aa4:	97a6                	add	a5,a5,s1
    80004aa6:	faf44703          	lbu	a4,-81(s0)
    80004aaa:	00e78c23          	sb	a4,24(a5)
      i++;
    80004aae:	2905                	addw	s2,s2,1
    80004ab0:	b755                	j	80004a54 <pipewrite+0x80>
  int i = 0;
    80004ab2:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004ab4:	21848513          	add	a0,s1,536
    80004ab8:	ffffd097          	auipc	ra,0xffffd
    80004abc:	69a080e7          	jalr	1690(ra) # 80002152 <wakeup>
  release(&pi->lock);
    80004ac0:	8526                	mv	a0,s1
    80004ac2:	ffffc097          	auipc	ra,0xffffc
    80004ac6:	1c4080e7          	jalr	452(ra) # 80000c86 <release>
  return i;
    80004aca:	bfa9                	j	80004a24 <pipewrite+0x50>

0000000080004acc <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004acc:	715d                	add	sp,sp,-80
    80004ace:	e486                	sd	ra,72(sp)
    80004ad0:	e0a2                	sd	s0,64(sp)
    80004ad2:	fc26                	sd	s1,56(sp)
    80004ad4:	f84a                	sd	s2,48(sp)
    80004ad6:	f44e                	sd	s3,40(sp)
    80004ad8:	f052                	sd	s4,32(sp)
    80004ada:	ec56                	sd	s5,24(sp)
    80004adc:	e85a                	sd	s6,16(sp)
    80004ade:	0880                	add	s0,sp,80
    80004ae0:	84aa                	mv	s1,a0
    80004ae2:	892e                	mv	s2,a1
    80004ae4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ae6:	ffffd097          	auipc	ra,0xffffd
    80004aea:	efc080e7          	jalr	-260(ra) # 800019e2 <myproc>
    80004aee:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004af0:	8526                	mv	a0,s1
    80004af2:	ffffc097          	auipc	ra,0xffffc
    80004af6:	0e0080e7          	jalr	224(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004afa:	2184a703          	lw	a4,536(s1)
    80004afe:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b02:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b06:	02f71763          	bne	a4,a5,80004b34 <piperead+0x68>
    80004b0a:	2244a783          	lw	a5,548(s1)
    80004b0e:	c39d                	beqz	a5,80004b34 <piperead+0x68>
    if(killed(pr)){
    80004b10:	8552                	mv	a0,s4
    80004b12:	ffffe097          	auipc	ra,0xffffe
    80004b16:	89c080e7          	jalr	-1892(ra) # 800023ae <killed>
    80004b1a:	e949                	bnez	a0,80004bac <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b1c:	85a6                	mv	a1,s1
    80004b1e:	854e                	mv	a0,s3
    80004b20:	ffffd097          	auipc	ra,0xffffd
    80004b24:	5ce080e7          	jalr	1486(ra) # 800020ee <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b28:	2184a703          	lw	a4,536(s1)
    80004b2c:	21c4a783          	lw	a5,540(s1)
    80004b30:	fcf70de3          	beq	a4,a5,80004b0a <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b34:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b36:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b38:	05505463          	blez	s5,80004b80 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b3c:	2184a783          	lw	a5,536(s1)
    80004b40:	21c4a703          	lw	a4,540(s1)
    80004b44:	02f70e63          	beq	a4,a5,80004b80 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b48:	0017871b          	addw	a4,a5,1
    80004b4c:	20e4ac23          	sw	a4,536(s1)
    80004b50:	1ff7f793          	and	a5,a5,511
    80004b54:	97a6                	add	a5,a5,s1
    80004b56:	0187c783          	lbu	a5,24(a5)
    80004b5a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b5e:	4685                	li	a3,1
    80004b60:	fbf40613          	add	a2,s0,-65
    80004b64:	85ca                	mv	a1,s2
    80004b66:	050a3503          	ld	a0,80(s4)
    80004b6a:	ffffd097          	auipc	ra,0xffffd
    80004b6e:	b28080e7          	jalr	-1240(ra) # 80001692 <copyout>
    80004b72:	01650763          	beq	a0,s6,80004b80 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b76:	2985                	addw	s3,s3,1
    80004b78:	0905                	add	s2,s2,1
    80004b7a:	fd3a91e3          	bne	s5,s3,80004b3c <piperead+0x70>
    80004b7e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004b80:	21c48513          	add	a0,s1,540
    80004b84:	ffffd097          	auipc	ra,0xffffd
    80004b88:	5ce080e7          	jalr	1486(ra) # 80002152 <wakeup>
  release(&pi->lock);
    80004b8c:	8526                	mv	a0,s1
    80004b8e:	ffffc097          	auipc	ra,0xffffc
    80004b92:	0f8080e7          	jalr	248(ra) # 80000c86 <release>
  return i;
}
    80004b96:	854e                	mv	a0,s3
    80004b98:	60a6                	ld	ra,72(sp)
    80004b9a:	6406                	ld	s0,64(sp)
    80004b9c:	74e2                	ld	s1,56(sp)
    80004b9e:	7942                	ld	s2,48(sp)
    80004ba0:	79a2                	ld	s3,40(sp)
    80004ba2:	7a02                	ld	s4,32(sp)
    80004ba4:	6ae2                	ld	s5,24(sp)
    80004ba6:	6b42                	ld	s6,16(sp)
    80004ba8:	6161                	add	sp,sp,80
    80004baa:	8082                	ret
      release(&pi->lock);
    80004bac:	8526                	mv	a0,s1
    80004bae:	ffffc097          	auipc	ra,0xffffc
    80004bb2:	0d8080e7          	jalr	216(ra) # 80000c86 <release>
      return -1;
    80004bb6:	59fd                	li	s3,-1
    80004bb8:	bff9                	j	80004b96 <piperead+0xca>

0000000080004bba <flags2perm>:

// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004bba:	1141                	add	sp,sp,-16
    80004bbc:	e422                	sd	s0,8(sp)
    80004bbe:	0800                	add	s0,sp,16
    80004bc0:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004bc2:	8905                	and	a0,a0,1
    80004bc4:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004bc6:	8b89                	and	a5,a5,2
    80004bc8:	c399                	beqz	a5,80004bce <flags2perm+0x14>
      perm |= PTE_W;
    80004bca:	00456513          	or	a0,a0,4
    return perm;
}
    80004bce:	6422                	ld	s0,8(sp)
    80004bd0:	0141                	add	sp,sp,16
    80004bd2:	8082                	ret

0000000080004bd4 <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004bd4:	c749                	beqz	a4,80004c5e <loadseg+0x8a>
{
    80004bd6:	711d                	add	sp,sp,-96
    80004bd8:	ec86                	sd	ra,88(sp)
    80004bda:	e8a2                	sd	s0,80(sp)
    80004bdc:	e4a6                	sd	s1,72(sp)
    80004bde:	e0ca                	sd	s2,64(sp)
    80004be0:	fc4e                	sd	s3,56(sp)
    80004be2:	f852                	sd	s4,48(sp)
    80004be4:	f456                	sd	s5,40(sp)
    80004be6:	f05a                	sd	s6,32(sp)
    80004be8:	ec5e                	sd	s7,24(sp)
    80004bea:	e862                	sd	s8,16(sp)
    80004bec:	e466                	sd	s9,8(sp)
    80004bee:	1080                	add	s0,sp,96
    80004bf0:	8aaa                	mv	s5,a0
    80004bf2:	8b2e                	mv	s6,a1
    80004bf4:	8bb2                	mv	s7,a2
    80004bf6:	8c36                	mv	s8,a3
    80004bf8:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004bfa:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004bfc:	6c85                	lui	s9,0x1
    80004bfe:	6a05                	lui	s4,0x1
    80004c00:	a815                	j	80004c34 <loadseg+0x60>
      panic("loadseg: address should exist");
    80004c02:	00004517          	auipc	a0,0x4
    80004c06:	af650513          	add	a0,a0,-1290 # 800086f8 <syscalls+0x280>
    80004c0a:	ffffc097          	auipc	ra,0xffffc
    80004c0e:	932080e7          	jalr	-1742(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004c12:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c14:	8726                	mv	a4,s1
    80004c16:	012c06bb          	addw	a3,s8,s2
    80004c1a:	4581                	li	a1,0
    80004c1c:	855e                	mv	a0,s7
    80004c1e:	fffff097          	auipc	ra,0xfffff
    80004c22:	d8a080e7          	jalr	-630(ra) # 800039a8 <readi>
    80004c26:	2501                	sext.w	a0,a0
    80004c28:	02951d63          	bne	a0,s1,80004c62 <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004c2c:	012a093b          	addw	s2,s4,s2
    80004c30:	03397563          	bgeu	s2,s3,80004c5a <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004c34:	02091593          	sll	a1,s2,0x20
    80004c38:	9181                	srl	a1,a1,0x20
    80004c3a:	95da                	add	a1,a1,s6
    80004c3c:	8556                	mv	a0,s5
    80004c3e:	ffffc097          	auipc	ra,0xffffc
    80004c42:	420080e7          	jalr	1056(ra) # 8000105e <walkaddr>
    80004c46:	862a                	mv	a2,a0
    if(pa == 0)
    80004c48:	dd4d                	beqz	a0,80004c02 <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004c4a:	412984bb          	subw	s1,s3,s2
    80004c4e:	0004879b          	sext.w	a5,s1
    80004c52:	fcfcf0e3          	bgeu	s9,a5,80004c12 <loadseg+0x3e>
    80004c56:	84d2                	mv	s1,s4
    80004c58:	bf6d                	j	80004c12 <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004c5a:	4501                	li	a0,0
    80004c5c:	a021                	j	80004c64 <loadseg+0x90>
    80004c5e:	4501                	li	a0,0
}
    80004c60:	8082                	ret
      return -1;
    80004c62:	557d                	li	a0,-1
}
    80004c64:	60e6                	ld	ra,88(sp)
    80004c66:	6446                	ld	s0,80(sp)
    80004c68:	64a6                	ld	s1,72(sp)
    80004c6a:	6906                	ld	s2,64(sp)
    80004c6c:	79e2                	ld	s3,56(sp)
    80004c6e:	7a42                	ld	s4,48(sp)
    80004c70:	7aa2                	ld	s5,40(sp)
    80004c72:	7b02                	ld	s6,32(sp)
    80004c74:	6be2                	ld	s7,24(sp)
    80004c76:	6c42                	ld	s8,16(sp)
    80004c78:	6ca2                	ld	s9,8(sp)
    80004c7a:	6125                	add	sp,sp,96
    80004c7c:	8082                	ret

0000000080004c7e <exec>:
{
    80004c7e:	7101                	add	sp,sp,-512
    80004c80:	ff86                	sd	ra,504(sp)
    80004c82:	fba2                	sd	s0,496(sp)
    80004c84:	f7a6                	sd	s1,488(sp)
    80004c86:	f3ca                	sd	s2,480(sp)
    80004c88:	efce                	sd	s3,472(sp)
    80004c8a:	ebd2                	sd	s4,464(sp)
    80004c8c:	e7d6                	sd	s5,456(sp)
    80004c8e:	e3da                	sd	s6,448(sp)
    80004c90:	ff5e                	sd	s7,440(sp)
    80004c92:	fb62                	sd	s8,432(sp)
    80004c94:	f766                	sd	s9,424(sp)
    80004c96:	f36a                	sd	s10,416(sp)
    80004c98:	ef6e                	sd	s11,408(sp)
    80004c9a:	0400                	add	s0,sp,512
    80004c9c:	84aa                	mv	s1,a0
    80004c9e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80004ca0:	ffffd097          	auipc	ra,0xffffd
    80004ca4:	d42080e7          	jalr	-702(ra) # 800019e2 <myproc>
    80004ca8:	8baa                	mv	s7,a0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004caa:	4615                	li	a2,5
    80004cac:	00004597          	auipc	a1,0x4
    80004cb0:	a6c58593          	add	a1,a1,-1428 # 80008718 <syscalls+0x2a0>
    80004cb4:	8526                	mv	a0,s1
    80004cb6:	ffffc097          	auipc	ra,0xffffc
    80004cba:	0e8080e7          	jalr	232(ra) # 80000d9e <strncmp>
    p->ondemand = false;
    80004cbe:	4781                	li	a5,0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004cc0:	e159                	bnez	a0,80004d46 <exec+0xc8>
    80004cc2:	16fb8423          	sb	a5,360(s7)
  begin_op();
    80004cc6:	fffff097          	auipc	ra,0xfffff
    80004cca:	3d4080e7          	jalr	980(ra) # 8000409a <begin_op>
  if((ip = namei(path)) == 0){
    80004cce:	8526                	mv	a0,s1
    80004cd0:	fffff097          	auipc	ra,0xfffff
    80004cd4:	1ca080e7          	jalr	458(ra) # 80003e9a <namei>
    80004cd8:	8b2a                	mv	s6,a0
    80004cda:	c159                	beqz	a0,80004d60 <exec+0xe2>
  ilock(ip);
    80004cdc:	fffff097          	auipc	ra,0xfffff
    80004ce0:	a18080e7          	jalr	-1512(ra) # 800036f4 <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004ce4:	04000713          	li	a4,64
    80004ce8:	4681                	li	a3,0
    80004cea:	e5040613          	add	a2,s0,-432
    80004cee:	4581                	li	a1,0
    80004cf0:	855a                	mv	a0,s6
    80004cf2:	fffff097          	auipc	ra,0xfffff
    80004cf6:	cb6080e7          	jalr	-842(ra) # 800039a8 <readi>
    80004cfa:	04000793          	li	a5,64
    80004cfe:	00f51a63          	bne	a0,a5,80004d12 <exec+0x94>
  if(elf.magic != ELF_MAGIC)
    80004d02:	e5042703          	lw	a4,-432(s0)
    80004d06:	464c47b7          	lui	a5,0x464c4
    80004d0a:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d0e:	04f70f63          	beq	a4,a5,80004d6c <exec+0xee>
    iunlockput(ip);
    80004d12:	855a                	mv	a0,s6
    80004d14:	fffff097          	auipc	ra,0xfffff
    80004d18:	c42080e7          	jalr	-958(ra) # 80003956 <iunlockput>
    end_op();
    80004d1c:	fffff097          	auipc	ra,0xfffff
    80004d20:	3f8080e7          	jalr	1016(ra) # 80004114 <end_op>
  return -1;
    80004d24:	557d                	li	a0,-1
}
    80004d26:	70fe                	ld	ra,504(sp)
    80004d28:	745e                	ld	s0,496(sp)
    80004d2a:	74be                	ld	s1,488(sp)
    80004d2c:	791e                	ld	s2,480(sp)
    80004d2e:	69fe                	ld	s3,472(sp)
    80004d30:	6a5e                	ld	s4,464(sp)
    80004d32:	6abe                	ld	s5,456(sp)
    80004d34:	6b1e                	ld	s6,448(sp)
    80004d36:	7bfa                	ld	s7,440(sp)
    80004d38:	7c5a                	ld	s8,432(sp)
    80004d3a:	7cba                	ld	s9,424(sp)
    80004d3c:	7d1a                	ld	s10,416(sp)
    80004d3e:	6dfa                	ld	s11,408(sp)
    80004d40:	20010113          	add	sp,sp,512
    80004d44:	8082                	ret
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004d46:	4609                	li	a2,2
    80004d48:	00004597          	auipc	a1,0x4
    80004d4c:	9d858593          	add	a1,a1,-1576 # 80008720 <syscalls+0x2a8>
    80004d50:	8526                	mv	a0,s1
    80004d52:	ffffc097          	auipc	ra,0xffffc
    80004d56:	04c080e7          	jalr	76(ra) # 80000d9e <strncmp>
    80004d5a:	00a037b3          	snez	a5,a0
    80004d5e:	b795                	j	80004cc2 <exec+0x44>
    end_op();
    80004d60:	fffff097          	auipc	ra,0xfffff
    80004d64:	3b4080e7          	jalr	948(ra) # 80004114 <end_op>
    return -1;
    80004d68:	557d                	li	a0,-1
    80004d6a:	bf75                	j	80004d26 <exec+0xa8>
  if((pagetable = proc_pagetable(p)) == 0)
    80004d6c:	855e                	mv	a0,s7
    80004d6e:	ffffd097          	auipc	ra,0xffffd
    80004d72:	d38080e7          	jalr	-712(ra) # 80001aa6 <proc_pagetable>
    80004d76:	89aa                	mv	s3,a0
    80004d78:	dd49                	beqz	a0,80004d12 <exec+0x94>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d7a:	e7042a03          	lw	s4,-400(s0)
    80004d7e:	e8845783          	lhu	a5,-376(s0)
    80004d82:	c7e1                	beqz	a5,80004e4a <exec+0x1cc>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004d84:	4a81                	li	s5,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d86:	4c01                	li	s8,0
    if(ph.type != ELF_PROG_LOAD)
    80004d88:	4c85                	li	s9,1
    if(ph.vaddr % PGSIZE != 0)
    80004d8a:	6d05                	lui	s10,0x1
    80004d8c:	1d7d                	add	s10,s10,-1 # fff <_entry-0x7ffff001>
    80004d8e:	a831                	j	80004daa <exec+0x12c>
      print_skip_section(path, ph.vaddr, ph.memsz);
    80004d90:	2601                	sext.w	a2,a2
    80004d92:	8526                	mv	a0,s1
    80004d94:	00001097          	auipc	ra,0x1
    80004d98:	684080e7          	jalr	1668(ra) # 80006418 <print_skip_section>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004d9c:	2c05                	addw	s8,s8,1
    80004d9e:	038a0a1b          	addw	s4,s4,56 # 1038 <_entry-0x7fffefc8>
    80004da2:	e8845783          	lhu	a5,-376(s0)
    80004da6:	0afc5363          	bge	s8,a5,80004e4c <exec+0x1ce>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004daa:	2a01                	sext.w	s4,s4
    80004dac:	03800713          	li	a4,56
    80004db0:	86d2                	mv	a3,s4
    80004db2:	e1840613          	add	a2,s0,-488
    80004db6:	4581                	li	a1,0
    80004db8:	855a                	mv	a0,s6
    80004dba:	fffff097          	auipc	ra,0xfffff
    80004dbe:	bee080e7          	jalr	-1042(ra) # 800039a8 <readi>
    80004dc2:	03800793          	li	a5,56
    80004dc6:	0cf51763          	bne	a0,a5,80004e94 <exec+0x216>
    if(ph.type != ELF_PROG_LOAD)
    80004dca:	e1842783          	lw	a5,-488(s0)
    80004dce:	fd9797e3          	bne	a5,s9,80004d9c <exec+0x11e>
    if(ph.memsz < ph.filesz)
    80004dd2:	e4043603          	ld	a2,-448(s0)
    80004dd6:	e3843783          	ld	a5,-456(s0)
    80004dda:	0af66d63          	bltu	a2,a5,80004e94 <exec+0x216>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004dde:	e2843583          	ld	a1,-472(s0)
    80004de2:	00b607b3          	add	a5,a2,a1
    80004de6:	0ab7e763          	bltu	a5,a1,80004e94 <exec+0x216>
    if(ph.vaddr % PGSIZE != 0)
    80004dea:	01a5f7b3          	and	a5,a1,s10
    80004dee:	e3dd                	bnez	a5,80004e94 <exec+0x216>
    if(p->ondemand == false){
    80004df0:	168bc783          	lbu	a5,360(s7)
    80004df4:	ffd1                	bnez	a5,80004d90 <exec+0x112>
      print_ondemand_proc(path);
    80004df6:	8526                	mv	a0,s1
    80004df8:	00001097          	auipc	ra,0x1
    80004dfc:	5fe080e7          	jalr	1534(ra) # 800063f6 <print_ondemand_proc>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e00:	e2843d83          	ld	s11,-472(s0)
    80004e04:	e4043783          	ld	a5,-448(s0)
    80004e08:	9dbe                	add	s11,s11,a5
    80004e0a:	e1c42503          	lw	a0,-484(s0)
    80004e0e:	00000097          	auipc	ra,0x0
    80004e12:	dac080e7          	jalr	-596(ra) # 80004bba <flags2perm>
    80004e16:	86aa                	mv	a3,a0
    80004e18:	866e                	mv	a2,s11
    80004e1a:	85d6                	mv	a1,s5
    80004e1c:	854e                	mv	a0,s3
    80004e1e:	ffffc097          	auipc	ra,0xffffc
    80004e22:	5e6080e7          	jalr	1510(ra) # 80001404 <uvmalloc>
    80004e26:	8daa                	mv	s11,a0
    80004e28:	c535                	beqz	a0,80004e94 <exec+0x216>
      if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e2a:	e3842703          	lw	a4,-456(s0)
    80004e2e:	e2042683          	lw	a3,-480(s0)
    80004e32:	865a                	mv	a2,s6
    80004e34:	e2843583          	ld	a1,-472(s0)
    80004e38:	854e                	mv	a0,s3
    80004e3a:	00000097          	auipc	ra,0x0
    80004e3e:	d9a080e7          	jalr	-614(ra) # 80004bd4 <loadseg>
    80004e42:	1a054263          	bltz	a0,80004fe6 <exec+0x368>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e46:	8aee                	mv	s5,s11
    80004e48:	bf91                	j	80004d9c <exec+0x11e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e4a:	4a81                	li	s5,0
  iunlockput(ip);
    80004e4c:	855a                	mv	a0,s6
    80004e4e:	fffff097          	auipc	ra,0xfffff
    80004e52:	b08080e7          	jalr	-1272(ra) # 80003956 <iunlockput>
  end_op();
    80004e56:	fffff097          	auipc	ra,0xfffff
    80004e5a:	2be080e7          	jalr	702(ra) # 80004114 <end_op>
  p = myproc();
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	b84080e7          	jalr	-1148(ra) # 800019e2 <myproc>
    80004e66:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004e68:	653c                	ld	a5,72(a0)
    80004e6a:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004e6e:	6b05                	lui	s6,0x1
    80004e70:	1b7d                	add	s6,s6,-1 # fff <_entry-0x7ffff001>
    80004e72:	9b56                	add	s6,s6,s5
    80004e74:	77fd                	lui	a5,0xfffff
    80004e76:	00fb7b33          	and	s6,s6,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004e7a:	4691                	li	a3,4
    80004e7c:	6609                	lui	a2,0x2
    80004e7e:	965a                	add	a2,a2,s6
    80004e80:	85da                	mv	a1,s6
    80004e82:	854e                	mv	a0,s3
    80004e84:	ffffc097          	auipc	ra,0xffffc
    80004e88:	580080e7          	jalr	1408(ra) # 80001404 <uvmalloc>
    80004e8c:	8aaa                	mv	s5,a0
    80004e8e:	ed09                	bnez	a0,80004ea8 <exec+0x22a>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e90:	8ada                	mv	s5,s6
    80004e92:	4b01                	li	s6,0
    proc_freepagetable(pagetable, sz);
    80004e94:	85d6                	mv	a1,s5
    80004e96:	854e                	mv	a0,s3
    80004e98:	ffffd097          	auipc	ra,0xffffd
    80004e9c:	caa080e7          	jalr	-854(ra) # 80001b42 <proc_freepagetable>
  return -1;
    80004ea0:	557d                	li	a0,-1
  if(ip){
    80004ea2:	e80b02e3          	beqz	s6,80004d26 <exec+0xa8>
    80004ea6:	b5b5                	j	80004d12 <exec+0x94>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004ea8:	75f9                	lui	a1,0xffffe
    80004eaa:	95aa                	add	a1,a1,a0
    80004eac:	854e                	mv	a0,s3
    80004eae:	ffffc097          	auipc	ra,0xffffc
    80004eb2:	780080e7          	jalr	1920(ra) # 8000162e <uvmclear>
  stackbase = sp - PGSIZE;
    80004eb6:	7cfd                	lui	s9,0xfffff
    80004eb8:	9cd6                	add	s9,s9,s5
  for(argc = 0; argv[argc]; argc++) {
    80004eba:	00093503          	ld	a0,0(s2)
    80004ebe:	c125                	beqz	a0,80004f1e <exec+0x2a0>
    80004ec0:	e9040b93          	add	s7,s0,-368
    80004ec4:	f9040d93          	add	s11,s0,-112
  sp = sz;
    80004ec8:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004eca:	4a01                	li	s4,0
    sp -= strlen(argv[argc]) + 1;
    80004ecc:	ffffc097          	auipc	ra,0xffffc
    80004ed0:	f7c080e7          	jalr	-132(ra) # 80000e48 <strlen>
    80004ed4:	2505                	addw	a0,a0,1
    80004ed6:	40ab0533          	sub	a0,s6,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004eda:	ff057b13          	and	s6,a0,-16
    if(sp < stackbase)
    80004ede:	119b6663          	bltu	s6,s9,80004fea <exec+0x36c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004ee2:	00093c03          	ld	s8,0(s2)
    80004ee6:	8562                	mv	a0,s8
    80004ee8:	ffffc097          	auipc	ra,0xffffc
    80004eec:	f60080e7          	jalr	-160(ra) # 80000e48 <strlen>
    80004ef0:	0015069b          	addw	a3,a0,1
    80004ef4:	8662                	mv	a2,s8
    80004ef6:	85da                	mv	a1,s6
    80004ef8:	854e                	mv	a0,s3
    80004efa:	ffffc097          	auipc	ra,0xffffc
    80004efe:	798080e7          	jalr	1944(ra) # 80001692 <copyout>
    80004f02:	0e054663          	bltz	a0,80004fee <exec+0x370>
    ustack[argc] = sp;
    80004f06:	016bb023          	sd	s6,0(s7)
  for(argc = 0; argv[argc]; argc++) {
    80004f0a:	0a05                	add	s4,s4,1
    80004f0c:	0921                	add	s2,s2,8
    80004f0e:	00093503          	ld	a0,0(s2)
    80004f12:	c901                	beqz	a0,80004f22 <exec+0x2a4>
    if(argc >= MAXARG)
    80004f14:	0ba1                	add	s7,s7,8
    80004f16:	fbbb9be3          	bne	s7,s11,80004ecc <exec+0x24e>
  ip = 0;
    80004f1a:	4b01                	li	s6,0
    80004f1c:	bfa5                	j	80004e94 <exec+0x216>
  sp = sz;
    80004f1e:	8b56                	mv	s6,s5
  for(argc = 0; argv[argc]; argc++) {
    80004f20:	4a01                	li	s4,0
  ustack[argc] = 0;
    80004f22:	003a1793          	sll	a5,s4,0x3
    80004f26:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fe65880>
    80004f2a:	97a2                	add	a5,a5,s0
    80004f2c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f30:	001a0693          	add	a3,s4,1
    80004f34:	068e                	sll	a3,a3,0x3
    80004f36:	40db0933          	sub	s2,s6,a3
  sp -= sp % 16;
    80004f3a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80004f3e:	8b56                	mv	s6,s5
  if(sp < stackbase)
    80004f40:	f59968e3          	bltu	s2,s9,80004e90 <exec+0x212>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f44:	e9040613          	add	a2,s0,-368
    80004f48:	85ca                	mv	a1,s2
    80004f4a:	854e                	mv	a0,s3
    80004f4c:	ffffc097          	auipc	ra,0xffffc
    80004f50:	746080e7          	jalr	1862(ra) # 80001692 <copyout>
    80004f54:	f2054ee3          	bltz	a0,80004e90 <exec+0x212>
  p->trapframe->a1 = sp;
    80004f58:	058d3783          	ld	a5,88(s10)
    80004f5c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004f60:	0004c703          	lbu	a4,0(s1)
    80004f64:	cf11                	beqz	a4,80004f80 <exec+0x302>
    80004f66:	00148793          	add	a5,s1,1
    if(*s == '/')
    80004f6a:	02f00693          	li	a3,47
    80004f6e:	a029                	j	80004f78 <exec+0x2fa>
  for(last=s=path; *s; s++)
    80004f70:	0785                	add	a5,a5,1
    80004f72:	fff7c703          	lbu	a4,-1(a5)
    80004f76:	c709                	beqz	a4,80004f80 <exec+0x302>
    if(*s == '/')
    80004f78:	fed71ce3          	bne	a4,a3,80004f70 <exec+0x2f2>
      last = s+1;
    80004f7c:	84be                	mv	s1,a5
    80004f7e:	bfcd                	j	80004f70 <exec+0x2f2>
  safestrcpy(p->name, last, sizeof(p->name));
    80004f80:	4641                	li	a2,16
    80004f82:	85a6                	mv	a1,s1
    80004f84:	158d0513          	add	a0,s10,344
    80004f88:	ffffc097          	auipc	ra,0xffffc
    80004f8c:	e8e080e7          	jalr	-370(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004f90:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80004f94:	053d3823          	sd	s3,80(s10)
  p->sz = sz;
    80004f98:	055d3423          	sd	s5,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004f9c:	058d3783          	ld	a5,88(s10)
    80004fa0:	e6843703          	ld	a4,-408(s0)
    80004fa4:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004fa6:	058d3783          	ld	a5,88(s10)
    80004faa:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004fae:	e0843583          	ld	a1,-504(s0)
    80004fb2:	ffffd097          	auipc	ra,0xffffd
    80004fb6:	b90080e7          	jalr	-1136(ra) # 80001b42 <proc_freepagetable>
  for (int i = 0; i < MAXHEAP; i++) {
    80004fba:	170d0793          	add	a5,s10,368
    80004fbe:	6699                	lui	a3,0x6
    80004fc0:	f3068693          	add	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    80004fc4:	96ea                	add	a3,a3,s10
    p->heap_tracker[i].addr            = 0xFFFFFFFFFFFFFFFF;
    80004fc6:	577d                	li	a4,-1
    80004fc8:	e398                	sd	a4,0(a5)
    p->heap_tracker[i].startblock      = -1;
    80004fca:	cbd8                	sw	a4,20(a5)
    p->heap_tracker[i].last_load_time  = 0xFFFFFFFFFFFFFFFF;
    80004fcc:	e798                	sd	a4,8(a5)
    p->heap_tracker[i].loaded          = false;
    80004fce:	00078823          	sb	zero,16(a5)
  for (int i = 0; i < MAXHEAP; i++) {
    80004fd2:	07e1                	add	a5,a5,24
    80004fd4:	fed79ae3          	bne	a5,a3,80004fc8 <exec+0x34a>
  p->resident_heap_pages = 0;
    80004fd8:	6799                	lui	a5,0x6
    80004fda:	9d3e                	add	s10,s10,a5
    80004fdc:	f20d2823          	sw	zero,-208(s10)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004fe0:	000a051b          	sext.w	a0,s4
    80004fe4:	b389                	j	80004d26 <exec+0xa8>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004fe6:	8aee                	mv	s5,s11
    80004fe8:	b575                	j	80004e94 <exec+0x216>
  ip = 0;
    80004fea:	4b01                	li	s6,0
    80004fec:	b565                	j	80004e94 <exec+0x216>
    80004fee:	4b01                	li	s6,0
  if(pagetable)
    80004ff0:	b555                	j	80004e94 <exec+0x216>

0000000080004ff2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ff2:	7179                	add	sp,sp,-48
    80004ff4:	f406                	sd	ra,40(sp)
    80004ff6:	f022                	sd	s0,32(sp)
    80004ff8:	ec26                	sd	s1,24(sp)
    80004ffa:	e84a                	sd	s2,16(sp)
    80004ffc:	1800                	add	s0,sp,48
    80004ffe:	892e                	mv	s2,a1
    80005000:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005002:	fdc40593          	add	a1,s0,-36
    80005006:	ffffe097          	auipc	ra,0xffffe
    8000500a:	b8c080e7          	jalr	-1140(ra) # 80002b92 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    8000500e:	fdc42703          	lw	a4,-36(s0)
    80005012:	47bd                	li	a5,15
    80005014:	02e7eb63          	bltu	a5,a4,8000504a <argfd+0x58>
    80005018:	ffffd097          	auipc	ra,0xffffd
    8000501c:	9ca080e7          	jalr	-1590(ra) # 800019e2 <myproc>
    80005020:	fdc42703          	lw	a4,-36(s0)
    80005024:	01a70793          	add	a5,a4,26
    80005028:	078e                	sll	a5,a5,0x3
    8000502a:	953e                	add	a0,a0,a5
    8000502c:	611c                	ld	a5,0(a0)
    8000502e:	c385                	beqz	a5,8000504e <argfd+0x5c>
    return -1;
  if(pfd)
    80005030:	00090463          	beqz	s2,80005038 <argfd+0x46>
    *pfd = fd;
    80005034:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005038:	4501                	li	a0,0
  if(pf)
    8000503a:	c091                	beqz	s1,8000503e <argfd+0x4c>
    *pf = f;
    8000503c:	e09c                	sd	a5,0(s1)
}
    8000503e:	70a2                	ld	ra,40(sp)
    80005040:	7402                	ld	s0,32(sp)
    80005042:	64e2                	ld	s1,24(sp)
    80005044:	6942                	ld	s2,16(sp)
    80005046:	6145                	add	sp,sp,48
    80005048:	8082                	ret
    return -1;
    8000504a:	557d                	li	a0,-1
    8000504c:	bfcd                	j	8000503e <argfd+0x4c>
    8000504e:	557d                	li	a0,-1
    80005050:	b7fd                	j	8000503e <argfd+0x4c>

0000000080005052 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005052:	1101                	add	sp,sp,-32
    80005054:	ec06                	sd	ra,24(sp)
    80005056:	e822                	sd	s0,16(sp)
    80005058:	e426                	sd	s1,8(sp)
    8000505a:	1000                	add	s0,sp,32
    8000505c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000505e:	ffffd097          	auipc	ra,0xffffd
    80005062:	984080e7          	jalr	-1660(ra) # 800019e2 <myproc>
    80005066:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005068:	0d050793          	add	a5,a0,208
    8000506c:	4501                	li	a0,0
    8000506e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005070:	6398                	ld	a4,0(a5)
    80005072:	cb19                	beqz	a4,80005088 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005074:	2505                	addw	a0,a0,1
    80005076:	07a1                	add	a5,a5,8 # 6008 <_entry-0x7fff9ff8>
    80005078:	fed51ce3          	bne	a0,a3,80005070 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000507c:	557d                	li	a0,-1
}
    8000507e:	60e2                	ld	ra,24(sp)
    80005080:	6442                	ld	s0,16(sp)
    80005082:	64a2                	ld	s1,8(sp)
    80005084:	6105                	add	sp,sp,32
    80005086:	8082                	ret
      p->ofile[fd] = f;
    80005088:	01a50793          	add	a5,a0,26
    8000508c:	078e                	sll	a5,a5,0x3
    8000508e:	963e                	add	a2,a2,a5
    80005090:	e204                	sd	s1,0(a2)
      return fd;
    80005092:	b7f5                	j	8000507e <fdalloc+0x2c>

0000000080005094 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005094:	715d                	add	sp,sp,-80
    80005096:	e486                	sd	ra,72(sp)
    80005098:	e0a2                	sd	s0,64(sp)
    8000509a:	fc26                	sd	s1,56(sp)
    8000509c:	f84a                	sd	s2,48(sp)
    8000509e:	f44e                	sd	s3,40(sp)
    800050a0:	f052                	sd	s4,32(sp)
    800050a2:	ec56                	sd	s5,24(sp)
    800050a4:	e85a                	sd	s6,16(sp)
    800050a6:	0880                	add	s0,sp,80
    800050a8:	8b2e                	mv	s6,a1
    800050aa:	89b2                	mv	s3,a2
    800050ac:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800050ae:	fb040593          	add	a1,s0,-80
    800050b2:	fffff097          	auipc	ra,0xfffff
    800050b6:	e06080e7          	jalr	-506(ra) # 80003eb8 <nameiparent>
    800050ba:	84aa                	mv	s1,a0
    800050bc:	14050b63          	beqz	a0,80005212 <create+0x17e>
    return 0;

  ilock(dp);
    800050c0:	ffffe097          	auipc	ra,0xffffe
    800050c4:	634080e7          	jalr	1588(ra) # 800036f4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800050c8:	4601                	li	a2,0
    800050ca:	fb040593          	add	a1,s0,-80
    800050ce:	8526                	mv	a0,s1
    800050d0:	fffff097          	auipc	ra,0xfffff
    800050d4:	b08080e7          	jalr	-1272(ra) # 80003bd8 <dirlookup>
    800050d8:	8aaa                	mv	s5,a0
    800050da:	c921                	beqz	a0,8000512a <create+0x96>
    iunlockput(dp);
    800050dc:	8526                	mv	a0,s1
    800050de:	fffff097          	auipc	ra,0xfffff
    800050e2:	878080e7          	jalr	-1928(ra) # 80003956 <iunlockput>
    ilock(ip);
    800050e6:	8556                	mv	a0,s5
    800050e8:	ffffe097          	auipc	ra,0xffffe
    800050ec:	60c080e7          	jalr	1548(ra) # 800036f4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800050f0:	4789                	li	a5,2
    800050f2:	02fb1563          	bne	s6,a5,8000511c <create+0x88>
    800050f6:	044ad783          	lhu	a5,68(s5)
    800050fa:	37f9                	addw	a5,a5,-2
    800050fc:	17c2                	sll	a5,a5,0x30
    800050fe:	93c1                	srl	a5,a5,0x30
    80005100:	4705                	li	a4,1
    80005102:	00f76d63          	bltu	a4,a5,8000511c <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005106:	8556                	mv	a0,s5
    80005108:	60a6                	ld	ra,72(sp)
    8000510a:	6406                	ld	s0,64(sp)
    8000510c:	74e2                	ld	s1,56(sp)
    8000510e:	7942                	ld	s2,48(sp)
    80005110:	79a2                	ld	s3,40(sp)
    80005112:	7a02                	ld	s4,32(sp)
    80005114:	6ae2                	ld	s5,24(sp)
    80005116:	6b42                	ld	s6,16(sp)
    80005118:	6161                	add	sp,sp,80
    8000511a:	8082                	ret
    iunlockput(ip);
    8000511c:	8556                	mv	a0,s5
    8000511e:	fffff097          	auipc	ra,0xfffff
    80005122:	838080e7          	jalr	-1992(ra) # 80003956 <iunlockput>
    return 0;
    80005126:	4a81                	li	s5,0
    80005128:	bff9                	j	80005106 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000512a:	85da                	mv	a1,s6
    8000512c:	4088                	lw	a0,0(s1)
    8000512e:	ffffe097          	auipc	ra,0xffffe
    80005132:	42e080e7          	jalr	1070(ra) # 8000355c <ialloc>
    80005136:	8a2a                	mv	s4,a0
    80005138:	c529                	beqz	a0,80005182 <create+0xee>
  ilock(ip);
    8000513a:	ffffe097          	auipc	ra,0xffffe
    8000513e:	5ba080e7          	jalr	1466(ra) # 800036f4 <ilock>
  ip->major = major;
    80005142:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005146:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000514a:	4905                	li	s2,1
    8000514c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005150:	8552                	mv	a0,s4
    80005152:	ffffe097          	auipc	ra,0xffffe
    80005156:	4d6080e7          	jalr	1238(ra) # 80003628 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000515a:	032b0b63          	beq	s6,s2,80005190 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000515e:	004a2603          	lw	a2,4(s4)
    80005162:	fb040593          	add	a1,s0,-80
    80005166:	8526                	mv	a0,s1
    80005168:	fffff097          	auipc	ra,0xfffff
    8000516c:	c80080e7          	jalr	-896(ra) # 80003de8 <dirlink>
    80005170:	06054f63          	bltz	a0,800051ee <create+0x15a>
  iunlockput(dp);
    80005174:	8526                	mv	a0,s1
    80005176:	ffffe097          	auipc	ra,0xffffe
    8000517a:	7e0080e7          	jalr	2016(ra) # 80003956 <iunlockput>
  return ip;
    8000517e:	8ad2                	mv	s5,s4
    80005180:	b759                	j	80005106 <create+0x72>
    iunlockput(dp);
    80005182:	8526                	mv	a0,s1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	7d2080e7          	jalr	2002(ra) # 80003956 <iunlockput>
    return 0;
    8000518c:	8ad2                	mv	s5,s4
    8000518e:	bfa5                	j	80005106 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005190:	004a2603          	lw	a2,4(s4)
    80005194:	00003597          	auipc	a1,0x3
    80005198:	59458593          	add	a1,a1,1428 # 80008728 <syscalls+0x2b0>
    8000519c:	8552                	mv	a0,s4
    8000519e:	fffff097          	auipc	ra,0xfffff
    800051a2:	c4a080e7          	jalr	-950(ra) # 80003de8 <dirlink>
    800051a6:	04054463          	bltz	a0,800051ee <create+0x15a>
    800051aa:	40d0                	lw	a2,4(s1)
    800051ac:	00003597          	auipc	a1,0x3
    800051b0:	58458593          	add	a1,a1,1412 # 80008730 <syscalls+0x2b8>
    800051b4:	8552                	mv	a0,s4
    800051b6:	fffff097          	auipc	ra,0xfffff
    800051ba:	c32080e7          	jalr	-974(ra) # 80003de8 <dirlink>
    800051be:	02054863          	bltz	a0,800051ee <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800051c2:	004a2603          	lw	a2,4(s4)
    800051c6:	fb040593          	add	a1,s0,-80
    800051ca:	8526                	mv	a0,s1
    800051cc:	fffff097          	auipc	ra,0xfffff
    800051d0:	c1c080e7          	jalr	-996(ra) # 80003de8 <dirlink>
    800051d4:	00054d63          	bltz	a0,800051ee <create+0x15a>
    dp->nlink++;  // for ".."
    800051d8:	04a4d783          	lhu	a5,74(s1)
    800051dc:	2785                	addw	a5,a5,1
    800051de:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800051e2:	8526                	mv	a0,s1
    800051e4:	ffffe097          	auipc	ra,0xffffe
    800051e8:	444080e7          	jalr	1092(ra) # 80003628 <iupdate>
    800051ec:	b761                	j	80005174 <create+0xe0>
  ip->nlink = 0;
    800051ee:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800051f2:	8552                	mv	a0,s4
    800051f4:	ffffe097          	auipc	ra,0xffffe
    800051f8:	434080e7          	jalr	1076(ra) # 80003628 <iupdate>
  iunlockput(ip);
    800051fc:	8552                	mv	a0,s4
    800051fe:	ffffe097          	auipc	ra,0xffffe
    80005202:	758080e7          	jalr	1880(ra) # 80003956 <iunlockput>
  iunlockput(dp);
    80005206:	8526                	mv	a0,s1
    80005208:	ffffe097          	auipc	ra,0xffffe
    8000520c:	74e080e7          	jalr	1870(ra) # 80003956 <iunlockput>
  return 0;
    80005210:	bddd                	j	80005106 <create+0x72>
    return 0;
    80005212:	8aaa                	mv	s5,a0
    80005214:	bdcd                	j	80005106 <create+0x72>

0000000080005216 <sys_dup>:
{
    80005216:	7179                	add	sp,sp,-48
    80005218:	f406                	sd	ra,40(sp)
    8000521a:	f022                	sd	s0,32(sp)
    8000521c:	ec26                	sd	s1,24(sp)
    8000521e:	e84a                	sd	s2,16(sp)
    80005220:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005222:	fd840613          	add	a2,s0,-40
    80005226:	4581                	li	a1,0
    80005228:	4501                	li	a0,0
    8000522a:	00000097          	auipc	ra,0x0
    8000522e:	dc8080e7          	jalr	-568(ra) # 80004ff2 <argfd>
    return -1;
    80005232:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005234:	02054363          	bltz	a0,8000525a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005238:	fd843903          	ld	s2,-40(s0)
    8000523c:	854a                	mv	a0,s2
    8000523e:	00000097          	auipc	ra,0x0
    80005242:	e14080e7          	jalr	-492(ra) # 80005052 <fdalloc>
    80005246:	84aa                	mv	s1,a0
    return -1;
    80005248:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000524a:	00054863          	bltz	a0,8000525a <sys_dup+0x44>
  filedup(f);
    8000524e:	854a                	mv	a0,s2
    80005250:	fffff097          	auipc	ra,0xfffff
    80005254:	2bc080e7          	jalr	700(ra) # 8000450c <filedup>
  return fd;
    80005258:	87a6                	mv	a5,s1
}
    8000525a:	853e                	mv	a0,a5
    8000525c:	70a2                	ld	ra,40(sp)
    8000525e:	7402                	ld	s0,32(sp)
    80005260:	64e2                	ld	s1,24(sp)
    80005262:	6942                	ld	s2,16(sp)
    80005264:	6145                	add	sp,sp,48
    80005266:	8082                	ret

0000000080005268 <sys_read>:
{
    80005268:	7179                	add	sp,sp,-48
    8000526a:	f406                	sd	ra,40(sp)
    8000526c:	f022                	sd	s0,32(sp)
    8000526e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005270:	fd840593          	add	a1,s0,-40
    80005274:	4505                	li	a0,1
    80005276:	ffffe097          	auipc	ra,0xffffe
    8000527a:	93c080e7          	jalr	-1732(ra) # 80002bb2 <argaddr>
  argint(2, &n);
    8000527e:	fe440593          	add	a1,s0,-28
    80005282:	4509                	li	a0,2
    80005284:	ffffe097          	auipc	ra,0xffffe
    80005288:	90e080e7          	jalr	-1778(ra) # 80002b92 <argint>
  if(argfd(0, 0, &f) < 0)
    8000528c:	fe840613          	add	a2,s0,-24
    80005290:	4581                	li	a1,0
    80005292:	4501                	li	a0,0
    80005294:	00000097          	auipc	ra,0x0
    80005298:	d5e080e7          	jalr	-674(ra) # 80004ff2 <argfd>
    8000529c:	87aa                	mv	a5,a0
    return -1;
    8000529e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052a0:	0007cc63          	bltz	a5,800052b8 <sys_read+0x50>
  return fileread(f, p, n);
    800052a4:	fe442603          	lw	a2,-28(s0)
    800052a8:	fd843583          	ld	a1,-40(s0)
    800052ac:	fe843503          	ld	a0,-24(s0)
    800052b0:	fffff097          	auipc	ra,0xfffff
    800052b4:	3e8080e7          	jalr	1000(ra) # 80004698 <fileread>
}
    800052b8:	70a2                	ld	ra,40(sp)
    800052ba:	7402                	ld	s0,32(sp)
    800052bc:	6145                	add	sp,sp,48
    800052be:	8082                	ret

00000000800052c0 <sys_write>:
{
    800052c0:	7179                	add	sp,sp,-48
    800052c2:	f406                	sd	ra,40(sp)
    800052c4:	f022                	sd	s0,32(sp)
    800052c6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800052c8:	fd840593          	add	a1,s0,-40
    800052cc:	4505                	li	a0,1
    800052ce:	ffffe097          	auipc	ra,0xffffe
    800052d2:	8e4080e7          	jalr	-1820(ra) # 80002bb2 <argaddr>
  argint(2, &n);
    800052d6:	fe440593          	add	a1,s0,-28
    800052da:	4509                	li	a0,2
    800052dc:	ffffe097          	auipc	ra,0xffffe
    800052e0:	8b6080e7          	jalr	-1866(ra) # 80002b92 <argint>
  if(argfd(0, 0, &f) < 0)
    800052e4:	fe840613          	add	a2,s0,-24
    800052e8:	4581                	li	a1,0
    800052ea:	4501                	li	a0,0
    800052ec:	00000097          	auipc	ra,0x0
    800052f0:	d06080e7          	jalr	-762(ra) # 80004ff2 <argfd>
    800052f4:	87aa                	mv	a5,a0
    return -1;
    800052f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052f8:	0007cc63          	bltz	a5,80005310 <sys_write+0x50>
  return filewrite(f, p, n);
    800052fc:	fe442603          	lw	a2,-28(s0)
    80005300:	fd843583          	ld	a1,-40(s0)
    80005304:	fe843503          	ld	a0,-24(s0)
    80005308:	fffff097          	auipc	ra,0xfffff
    8000530c:	452080e7          	jalr	1106(ra) # 8000475a <filewrite>
}
    80005310:	70a2                	ld	ra,40(sp)
    80005312:	7402                	ld	s0,32(sp)
    80005314:	6145                	add	sp,sp,48
    80005316:	8082                	ret

0000000080005318 <sys_close>:
{
    80005318:	1101                	add	sp,sp,-32
    8000531a:	ec06                	sd	ra,24(sp)
    8000531c:	e822                	sd	s0,16(sp)
    8000531e:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005320:	fe040613          	add	a2,s0,-32
    80005324:	fec40593          	add	a1,s0,-20
    80005328:	4501                	li	a0,0
    8000532a:	00000097          	auipc	ra,0x0
    8000532e:	cc8080e7          	jalr	-824(ra) # 80004ff2 <argfd>
    return -1;
    80005332:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005334:	02054463          	bltz	a0,8000535c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005338:	ffffc097          	auipc	ra,0xffffc
    8000533c:	6aa080e7          	jalr	1706(ra) # 800019e2 <myproc>
    80005340:	fec42783          	lw	a5,-20(s0)
    80005344:	07e9                	add	a5,a5,26
    80005346:	078e                	sll	a5,a5,0x3
    80005348:	953e                	add	a0,a0,a5
    8000534a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000534e:	fe043503          	ld	a0,-32(s0)
    80005352:	fffff097          	auipc	ra,0xfffff
    80005356:	20c080e7          	jalr	524(ra) # 8000455e <fileclose>
  return 0;
    8000535a:	4781                	li	a5,0
}
    8000535c:	853e                	mv	a0,a5
    8000535e:	60e2                	ld	ra,24(sp)
    80005360:	6442                	ld	s0,16(sp)
    80005362:	6105                	add	sp,sp,32
    80005364:	8082                	ret

0000000080005366 <sys_fstat>:
{
    80005366:	1101                	add	sp,sp,-32
    80005368:	ec06                	sd	ra,24(sp)
    8000536a:	e822                	sd	s0,16(sp)
    8000536c:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000536e:	fe040593          	add	a1,s0,-32
    80005372:	4505                	li	a0,1
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	83e080e7          	jalr	-1986(ra) # 80002bb2 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000537c:	fe840613          	add	a2,s0,-24
    80005380:	4581                	li	a1,0
    80005382:	4501                	li	a0,0
    80005384:	00000097          	auipc	ra,0x0
    80005388:	c6e080e7          	jalr	-914(ra) # 80004ff2 <argfd>
    8000538c:	87aa                	mv	a5,a0
    return -1;
    8000538e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005390:	0007ca63          	bltz	a5,800053a4 <sys_fstat+0x3e>
  return filestat(f, st);
    80005394:	fe043583          	ld	a1,-32(s0)
    80005398:	fe843503          	ld	a0,-24(s0)
    8000539c:	fffff097          	auipc	ra,0xfffff
    800053a0:	28a080e7          	jalr	650(ra) # 80004626 <filestat>
}
    800053a4:	60e2                	ld	ra,24(sp)
    800053a6:	6442                	ld	s0,16(sp)
    800053a8:	6105                	add	sp,sp,32
    800053aa:	8082                	ret

00000000800053ac <sys_link>:
{
    800053ac:	7169                	add	sp,sp,-304
    800053ae:	f606                	sd	ra,296(sp)
    800053b0:	f222                	sd	s0,288(sp)
    800053b2:	ee26                	sd	s1,280(sp)
    800053b4:	ea4a                	sd	s2,272(sp)
    800053b6:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053b8:	08000613          	li	a2,128
    800053bc:	ed040593          	add	a1,s0,-304
    800053c0:	4501                	li	a0,0
    800053c2:	ffffe097          	auipc	ra,0xffffe
    800053c6:	810080e7          	jalr	-2032(ra) # 80002bd2 <argstr>
    return -1;
    800053ca:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053cc:	10054e63          	bltz	a0,800054e8 <sys_link+0x13c>
    800053d0:	08000613          	li	a2,128
    800053d4:	f5040593          	add	a1,s0,-176
    800053d8:	4505                	li	a0,1
    800053da:	ffffd097          	auipc	ra,0xffffd
    800053de:	7f8080e7          	jalr	2040(ra) # 80002bd2 <argstr>
    return -1;
    800053e2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800053e4:	10054263          	bltz	a0,800054e8 <sys_link+0x13c>
  begin_op();
    800053e8:	fffff097          	auipc	ra,0xfffff
    800053ec:	cb2080e7          	jalr	-846(ra) # 8000409a <begin_op>
  if((ip = namei(old)) == 0){
    800053f0:	ed040513          	add	a0,s0,-304
    800053f4:	fffff097          	auipc	ra,0xfffff
    800053f8:	aa6080e7          	jalr	-1370(ra) # 80003e9a <namei>
    800053fc:	84aa                	mv	s1,a0
    800053fe:	c551                	beqz	a0,8000548a <sys_link+0xde>
  ilock(ip);
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	2f4080e7          	jalr	756(ra) # 800036f4 <ilock>
  if(ip->type == T_DIR){
    80005408:	04449703          	lh	a4,68(s1)
    8000540c:	4785                	li	a5,1
    8000540e:	08f70463          	beq	a4,a5,80005496 <sys_link+0xea>
  ip->nlink++;
    80005412:	04a4d783          	lhu	a5,74(s1)
    80005416:	2785                	addw	a5,a5,1
    80005418:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000541c:	8526                	mv	a0,s1
    8000541e:	ffffe097          	auipc	ra,0xffffe
    80005422:	20a080e7          	jalr	522(ra) # 80003628 <iupdate>
  iunlock(ip);
    80005426:	8526                	mv	a0,s1
    80005428:	ffffe097          	auipc	ra,0xffffe
    8000542c:	38e080e7          	jalr	910(ra) # 800037b6 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005430:	fd040593          	add	a1,s0,-48
    80005434:	f5040513          	add	a0,s0,-176
    80005438:	fffff097          	auipc	ra,0xfffff
    8000543c:	a80080e7          	jalr	-1408(ra) # 80003eb8 <nameiparent>
    80005440:	892a                	mv	s2,a0
    80005442:	c935                	beqz	a0,800054b6 <sys_link+0x10a>
  ilock(dp);
    80005444:	ffffe097          	auipc	ra,0xffffe
    80005448:	2b0080e7          	jalr	688(ra) # 800036f4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000544c:	00092703          	lw	a4,0(s2)
    80005450:	409c                	lw	a5,0(s1)
    80005452:	04f71d63          	bne	a4,a5,800054ac <sys_link+0x100>
    80005456:	40d0                	lw	a2,4(s1)
    80005458:	fd040593          	add	a1,s0,-48
    8000545c:	854a                	mv	a0,s2
    8000545e:	fffff097          	auipc	ra,0xfffff
    80005462:	98a080e7          	jalr	-1654(ra) # 80003de8 <dirlink>
    80005466:	04054363          	bltz	a0,800054ac <sys_link+0x100>
  iunlockput(dp);
    8000546a:	854a                	mv	a0,s2
    8000546c:	ffffe097          	auipc	ra,0xffffe
    80005470:	4ea080e7          	jalr	1258(ra) # 80003956 <iunlockput>
  iput(ip);
    80005474:	8526                	mv	a0,s1
    80005476:	ffffe097          	auipc	ra,0xffffe
    8000547a:	438080e7          	jalr	1080(ra) # 800038ae <iput>
  end_op();
    8000547e:	fffff097          	auipc	ra,0xfffff
    80005482:	c96080e7          	jalr	-874(ra) # 80004114 <end_op>
  return 0;
    80005486:	4781                	li	a5,0
    80005488:	a085                	j	800054e8 <sys_link+0x13c>
    end_op();
    8000548a:	fffff097          	auipc	ra,0xfffff
    8000548e:	c8a080e7          	jalr	-886(ra) # 80004114 <end_op>
    return -1;
    80005492:	57fd                	li	a5,-1
    80005494:	a891                	j	800054e8 <sys_link+0x13c>
    iunlockput(ip);
    80005496:	8526                	mv	a0,s1
    80005498:	ffffe097          	auipc	ra,0xffffe
    8000549c:	4be080e7          	jalr	1214(ra) # 80003956 <iunlockput>
    end_op();
    800054a0:	fffff097          	auipc	ra,0xfffff
    800054a4:	c74080e7          	jalr	-908(ra) # 80004114 <end_op>
    return -1;
    800054a8:	57fd                	li	a5,-1
    800054aa:	a83d                	j	800054e8 <sys_link+0x13c>
    iunlockput(dp);
    800054ac:	854a                	mv	a0,s2
    800054ae:	ffffe097          	auipc	ra,0xffffe
    800054b2:	4a8080e7          	jalr	1192(ra) # 80003956 <iunlockput>
  ilock(ip);
    800054b6:	8526                	mv	a0,s1
    800054b8:	ffffe097          	auipc	ra,0xffffe
    800054bc:	23c080e7          	jalr	572(ra) # 800036f4 <ilock>
  ip->nlink--;
    800054c0:	04a4d783          	lhu	a5,74(s1)
    800054c4:	37fd                	addw	a5,a5,-1
    800054c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800054ca:	8526                	mv	a0,s1
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	15c080e7          	jalr	348(ra) # 80003628 <iupdate>
  iunlockput(ip);
    800054d4:	8526                	mv	a0,s1
    800054d6:	ffffe097          	auipc	ra,0xffffe
    800054da:	480080e7          	jalr	1152(ra) # 80003956 <iunlockput>
  end_op();
    800054de:	fffff097          	auipc	ra,0xfffff
    800054e2:	c36080e7          	jalr	-970(ra) # 80004114 <end_op>
  return -1;
    800054e6:	57fd                	li	a5,-1
}
    800054e8:	853e                	mv	a0,a5
    800054ea:	70b2                	ld	ra,296(sp)
    800054ec:	7412                	ld	s0,288(sp)
    800054ee:	64f2                	ld	s1,280(sp)
    800054f0:	6952                	ld	s2,272(sp)
    800054f2:	6155                	add	sp,sp,304
    800054f4:	8082                	ret

00000000800054f6 <sys_unlink>:
{
    800054f6:	7151                	add	sp,sp,-240
    800054f8:	f586                	sd	ra,232(sp)
    800054fa:	f1a2                	sd	s0,224(sp)
    800054fc:	eda6                	sd	s1,216(sp)
    800054fe:	e9ca                	sd	s2,208(sp)
    80005500:	e5ce                	sd	s3,200(sp)
    80005502:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005504:	08000613          	li	a2,128
    80005508:	f3040593          	add	a1,s0,-208
    8000550c:	4501                	li	a0,0
    8000550e:	ffffd097          	auipc	ra,0xffffd
    80005512:	6c4080e7          	jalr	1732(ra) # 80002bd2 <argstr>
    80005516:	18054163          	bltz	a0,80005698 <sys_unlink+0x1a2>
  begin_op();
    8000551a:	fffff097          	auipc	ra,0xfffff
    8000551e:	b80080e7          	jalr	-1152(ra) # 8000409a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005522:	fb040593          	add	a1,s0,-80
    80005526:	f3040513          	add	a0,s0,-208
    8000552a:	fffff097          	auipc	ra,0xfffff
    8000552e:	98e080e7          	jalr	-1650(ra) # 80003eb8 <nameiparent>
    80005532:	84aa                	mv	s1,a0
    80005534:	c979                	beqz	a0,8000560a <sys_unlink+0x114>
  ilock(dp);
    80005536:	ffffe097          	auipc	ra,0xffffe
    8000553a:	1be080e7          	jalr	446(ra) # 800036f4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000553e:	00003597          	auipc	a1,0x3
    80005542:	1ea58593          	add	a1,a1,490 # 80008728 <syscalls+0x2b0>
    80005546:	fb040513          	add	a0,s0,-80
    8000554a:	ffffe097          	auipc	ra,0xffffe
    8000554e:	674080e7          	jalr	1652(ra) # 80003bbe <namecmp>
    80005552:	14050a63          	beqz	a0,800056a6 <sys_unlink+0x1b0>
    80005556:	00003597          	auipc	a1,0x3
    8000555a:	1da58593          	add	a1,a1,474 # 80008730 <syscalls+0x2b8>
    8000555e:	fb040513          	add	a0,s0,-80
    80005562:	ffffe097          	auipc	ra,0xffffe
    80005566:	65c080e7          	jalr	1628(ra) # 80003bbe <namecmp>
    8000556a:	12050e63          	beqz	a0,800056a6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000556e:	f2c40613          	add	a2,s0,-212
    80005572:	fb040593          	add	a1,s0,-80
    80005576:	8526                	mv	a0,s1
    80005578:	ffffe097          	auipc	ra,0xffffe
    8000557c:	660080e7          	jalr	1632(ra) # 80003bd8 <dirlookup>
    80005580:	892a                	mv	s2,a0
    80005582:	12050263          	beqz	a0,800056a6 <sys_unlink+0x1b0>
  ilock(ip);
    80005586:	ffffe097          	auipc	ra,0xffffe
    8000558a:	16e080e7          	jalr	366(ra) # 800036f4 <ilock>
  if(ip->nlink < 1)
    8000558e:	04a91783          	lh	a5,74(s2)
    80005592:	08f05263          	blez	a5,80005616 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005596:	04491703          	lh	a4,68(s2)
    8000559a:	4785                	li	a5,1
    8000559c:	08f70563          	beq	a4,a5,80005626 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055a0:	4641                	li	a2,16
    800055a2:	4581                	li	a1,0
    800055a4:	fc040513          	add	a0,s0,-64
    800055a8:	ffffb097          	auipc	ra,0xffffb
    800055ac:	726080e7          	jalr	1830(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800055b0:	4741                	li	a4,16
    800055b2:	f2c42683          	lw	a3,-212(s0)
    800055b6:	fc040613          	add	a2,s0,-64
    800055ba:	4581                	li	a1,0
    800055bc:	8526                	mv	a0,s1
    800055be:	ffffe097          	auipc	ra,0xffffe
    800055c2:	4e2080e7          	jalr	1250(ra) # 80003aa0 <writei>
    800055c6:	47c1                	li	a5,16
    800055c8:	0af51563          	bne	a0,a5,80005672 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800055cc:	04491703          	lh	a4,68(s2)
    800055d0:	4785                	li	a5,1
    800055d2:	0af70863          	beq	a4,a5,80005682 <sys_unlink+0x18c>
  iunlockput(dp);
    800055d6:	8526                	mv	a0,s1
    800055d8:	ffffe097          	auipc	ra,0xffffe
    800055dc:	37e080e7          	jalr	894(ra) # 80003956 <iunlockput>
  ip->nlink--;
    800055e0:	04a95783          	lhu	a5,74(s2)
    800055e4:	37fd                	addw	a5,a5,-1
    800055e6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800055ea:	854a                	mv	a0,s2
    800055ec:	ffffe097          	auipc	ra,0xffffe
    800055f0:	03c080e7          	jalr	60(ra) # 80003628 <iupdate>
  iunlockput(ip);
    800055f4:	854a                	mv	a0,s2
    800055f6:	ffffe097          	auipc	ra,0xffffe
    800055fa:	360080e7          	jalr	864(ra) # 80003956 <iunlockput>
  end_op();
    800055fe:	fffff097          	auipc	ra,0xfffff
    80005602:	b16080e7          	jalr	-1258(ra) # 80004114 <end_op>
  return 0;
    80005606:	4501                	li	a0,0
    80005608:	a84d                	j	800056ba <sys_unlink+0x1c4>
    end_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	b0a080e7          	jalr	-1270(ra) # 80004114 <end_op>
    return -1;
    80005612:	557d                	li	a0,-1
    80005614:	a05d                	j	800056ba <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005616:	00003517          	auipc	a0,0x3
    8000561a:	12250513          	add	a0,a0,290 # 80008738 <syscalls+0x2c0>
    8000561e:	ffffb097          	auipc	ra,0xffffb
    80005622:	f1e080e7          	jalr	-226(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005626:	04c92703          	lw	a4,76(s2)
    8000562a:	02000793          	li	a5,32
    8000562e:	f6e7f9e3          	bgeu	a5,a4,800055a0 <sys_unlink+0xaa>
    80005632:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005636:	4741                	li	a4,16
    80005638:	86ce                	mv	a3,s3
    8000563a:	f1840613          	add	a2,s0,-232
    8000563e:	4581                	li	a1,0
    80005640:	854a                	mv	a0,s2
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	366080e7          	jalr	870(ra) # 800039a8 <readi>
    8000564a:	47c1                	li	a5,16
    8000564c:	00f51b63          	bne	a0,a5,80005662 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005650:	f1845783          	lhu	a5,-232(s0)
    80005654:	e7a1                	bnez	a5,8000569c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005656:	29c1                	addw	s3,s3,16
    80005658:	04c92783          	lw	a5,76(s2)
    8000565c:	fcf9ede3          	bltu	s3,a5,80005636 <sys_unlink+0x140>
    80005660:	b781                	j	800055a0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005662:	00003517          	auipc	a0,0x3
    80005666:	0ee50513          	add	a0,a0,238 # 80008750 <syscalls+0x2d8>
    8000566a:	ffffb097          	auipc	ra,0xffffb
    8000566e:	ed2080e7          	jalr	-302(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005672:	00003517          	auipc	a0,0x3
    80005676:	0f650513          	add	a0,a0,246 # 80008768 <syscalls+0x2f0>
    8000567a:	ffffb097          	auipc	ra,0xffffb
    8000567e:	ec2080e7          	jalr	-318(ra) # 8000053c <panic>
    dp->nlink--;
    80005682:	04a4d783          	lhu	a5,74(s1)
    80005686:	37fd                	addw	a5,a5,-1
    80005688:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000568c:	8526                	mv	a0,s1
    8000568e:	ffffe097          	auipc	ra,0xffffe
    80005692:	f9a080e7          	jalr	-102(ra) # 80003628 <iupdate>
    80005696:	b781                	j	800055d6 <sys_unlink+0xe0>
    return -1;
    80005698:	557d                	li	a0,-1
    8000569a:	a005                	j	800056ba <sys_unlink+0x1c4>
    iunlockput(ip);
    8000569c:	854a                	mv	a0,s2
    8000569e:	ffffe097          	auipc	ra,0xffffe
    800056a2:	2b8080e7          	jalr	696(ra) # 80003956 <iunlockput>
  iunlockput(dp);
    800056a6:	8526                	mv	a0,s1
    800056a8:	ffffe097          	auipc	ra,0xffffe
    800056ac:	2ae080e7          	jalr	686(ra) # 80003956 <iunlockput>
  end_op();
    800056b0:	fffff097          	auipc	ra,0xfffff
    800056b4:	a64080e7          	jalr	-1436(ra) # 80004114 <end_op>
  return -1;
    800056b8:	557d                	li	a0,-1
}
    800056ba:	70ae                	ld	ra,232(sp)
    800056bc:	740e                	ld	s0,224(sp)
    800056be:	64ee                	ld	s1,216(sp)
    800056c0:	694e                	ld	s2,208(sp)
    800056c2:	69ae                	ld	s3,200(sp)
    800056c4:	616d                	add	sp,sp,240
    800056c6:	8082                	ret

00000000800056c8 <sys_open>:

uint64
sys_open(void)
{
    800056c8:	7131                	add	sp,sp,-192
    800056ca:	fd06                	sd	ra,184(sp)
    800056cc:	f922                	sd	s0,176(sp)
    800056ce:	f526                	sd	s1,168(sp)
    800056d0:	f14a                	sd	s2,160(sp)
    800056d2:	ed4e                	sd	s3,152(sp)
    800056d4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800056d6:	f4c40593          	add	a1,s0,-180
    800056da:	4505                	li	a0,1
    800056dc:	ffffd097          	auipc	ra,0xffffd
    800056e0:	4b6080e7          	jalr	1206(ra) # 80002b92 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056e4:	08000613          	li	a2,128
    800056e8:	f5040593          	add	a1,s0,-176
    800056ec:	4501                	li	a0,0
    800056ee:	ffffd097          	auipc	ra,0xffffd
    800056f2:	4e4080e7          	jalr	1252(ra) # 80002bd2 <argstr>
    800056f6:	87aa                	mv	a5,a0
    return -1;
    800056f8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800056fa:	0a07c863          	bltz	a5,800057aa <sys_open+0xe2>

  begin_op();
    800056fe:	fffff097          	auipc	ra,0xfffff
    80005702:	99c080e7          	jalr	-1636(ra) # 8000409a <begin_op>

  if(omode & O_CREATE){
    80005706:	f4c42783          	lw	a5,-180(s0)
    8000570a:	2007f793          	and	a5,a5,512
    8000570e:	cbdd                	beqz	a5,800057c4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005710:	4681                	li	a3,0
    80005712:	4601                	li	a2,0
    80005714:	4589                	li	a1,2
    80005716:	f5040513          	add	a0,s0,-176
    8000571a:	00000097          	auipc	ra,0x0
    8000571e:	97a080e7          	jalr	-1670(ra) # 80005094 <create>
    80005722:	84aa                	mv	s1,a0
    if(ip == 0){
    80005724:	c951                	beqz	a0,800057b8 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005726:	04449703          	lh	a4,68(s1)
    8000572a:	478d                	li	a5,3
    8000572c:	00f71763          	bne	a4,a5,8000573a <sys_open+0x72>
    80005730:	0464d703          	lhu	a4,70(s1)
    80005734:	47a5                	li	a5,9
    80005736:	0ce7ec63          	bltu	a5,a4,8000580e <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000573a:	fffff097          	auipc	ra,0xfffff
    8000573e:	d68080e7          	jalr	-664(ra) # 800044a2 <filealloc>
    80005742:	892a                	mv	s2,a0
    80005744:	c56d                	beqz	a0,8000582e <sys_open+0x166>
    80005746:	00000097          	auipc	ra,0x0
    8000574a:	90c080e7          	jalr	-1780(ra) # 80005052 <fdalloc>
    8000574e:	89aa                	mv	s3,a0
    80005750:	0c054a63          	bltz	a0,80005824 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005754:	04449703          	lh	a4,68(s1)
    80005758:	478d                	li	a5,3
    8000575a:	0ef70563          	beq	a4,a5,80005844 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000575e:	4789                	li	a5,2
    80005760:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005764:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005768:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000576c:	f4c42783          	lw	a5,-180(s0)
    80005770:	0017c713          	xor	a4,a5,1
    80005774:	8b05                	and	a4,a4,1
    80005776:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000577a:	0037f713          	and	a4,a5,3
    8000577e:	00e03733          	snez	a4,a4
    80005782:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005786:	4007f793          	and	a5,a5,1024
    8000578a:	c791                	beqz	a5,80005796 <sys_open+0xce>
    8000578c:	04449703          	lh	a4,68(s1)
    80005790:	4789                	li	a5,2
    80005792:	0cf70063          	beq	a4,a5,80005852 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	01e080e7          	jalr	30(ra) # 800037b6 <iunlock>
  end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	974080e7          	jalr	-1676(ra) # 80004114 <end_op>

  return fd;
    800057a8:	854e                	mv	a0,s3
}
    800057aa:	70ea                	ld	ra,184(sp)
    800057ac:	744a                	ld	s0,176(sp)
    800057ae:	74aa                	ld	s1,168(sp)
    800057b0:	790a                	ld	s2,160(sp)
    800057b2:	69ea                	ld	s3,152(sp)
    800057b4:	6129                	add	sp,sp,192
    800057b6:	8082                	ret
      end_op();
    800057b8:	fffff097          	auipc	ra,0xfffff
    800057bc:	95c080e7          	jalr	-1700(ra) # 80004114 <end_op>
      return -1;
    800057c0:	557d                	li	a0,-1
    800057c2:	b7e5                	j	800057aa <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800057c4:	f5040513          	add	a0,s0,-176
    800057c8:	ffffe097          	auipc	ra,0xffffe
    800057cc:	6d2080e7          	jalr	1746(ra) # 80003e9a <namei>
    800057d0:	84aa                	mv	s1,a0
    800057d2:	c905                	beqz	a0,80005802 <sys_open+0x13a>
    ilock(ip);
    800057d4:	ffffe097          	auipc	ra,0xffffe
    800057d8:	f20080e7          	jalr	-224(ra) # 800036f4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800057dc:	04449703          	lh	a4,68(s1)
    800057e0:	4785                	li	a5,1
    800057e2:	f4f712e3          	bne	a4,a5,80005726 <sys_open+0x5e>
    800057e6:	f4c42783          	lw	a5,-180(s0)
    800057ea:	dba1                	beqz	a5,8000573a <sys_open+0x72>
      iunlockput(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	168080e7          	jalr	360(ra) # 80003956 <iunlockput>
      end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	91e080e7          	jalr	-1762(ra) # 80004114 <end_op>
      return -1;
    800057fe:	557d                	li	a0,-1
    80005800:	b76d                	j	800057aa <sys_open+0xe2>
      end_op();
    80005802:	fffff097          	auipc	ra,0xfffff
    80005806:	912080e7          	jalr	-1774(ra) # 80004114 <end_op>
      return -1;
    8000580a:	557d                	li	a0,-1
    8000580c:	bf79                	j	800057aa <sys_open+0xe2>
    iunlockput(ip);
    8000580e:	8526                	mv	a0,s1
    80005810:	ffffe097          	auipc	ra,0xffffe
    80005814:	146080e7          	jalr	326(ra) # 80003956 <iunlockput>
    end_op();
    80005818:	fffff097          	auipc	ra,0xfffff
    8000581c:	8fc080e7          	jalr	-1796(ra) # 80004114 <end_op>
    return -1;
    80005820:	557d                	li	a0,-1
    80005822:	b761                	j	800057aa <sys_open+0xe2>
      fileclose(f);
    80005824:	854a                	mv	a0,s2
    80005826:	fffff097          	auipc	ra,0xfffff
    8000582a:	d38080e7          	jalr	-712(ra) # 8000455e <fileclose>
    iunlockput(ip);
    8000582e:	8526                	mv	a0,s1
    80005830:	ffffe097          	auipc	ra,0xffffe
    80005834:	126080e7          	jalr	294(ra) # 80003956 <iunlockput>
    end_op();
    80005838:	fffff097          	auipc	ra,0xfffff
    8000583c:	8dc080e7          	jalr	-1828(ra) # 80004114 <end_op>
    return -1;
    80005840:	557d                	li	a0,-1
    80005842:	b7a5                	j	800057aa <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005844:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005848:	04649783          	lh	a5,70(s1)
    8000584c:	02f91223          	sh	a5,36(s2)
    80005850:	bf21                	j	80005768 <sys_open+0xa0>
    itrunc(ip);
    80005852:	8526                	mv	a0,s1
    80005854:	ffffe097          	auipc	ra,0xffffe
    80005858:	fae080e7          	jalr	-82(ra) # 80003802 <itrunc>
    8000585c:	bf2d                	j	80005796 <sys_open+0xce>

000000008000585e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000585e:	7175                	add	sp,sp,-144
    80005860:	e506                	sd	ra,136(sp)
    80005862:	e122                	sd	s0,128(sp)
    80005864:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005866:	fffff097          	auipc	ra,0xfffff
    8000586a:	834080e7          	jalr	-1996(ra) # 8000409a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000586e:	08000613          	li	a2,128
    80005872:	f7040593          	add	a1,s0,-144
    80005876:	4501                	li	a0,0
    80005878:	ffffd097          	auipc	ra,0xffffd
    8000587c:	35a080e7          	jalr	858(ra) # 80002bd2 <argstr>
    80005880:	02054963          	bltz	a0,800058b2 <sys_mkdir+0x54>
    80005884:	4681                	li	a3,0
    80005886:	4601                	li	a2,0
    80005888:	4585                	li	a1,1
    8000588a:	f7040513          	add	a0,s0,-144
    8000588e:	00000097          	auipc	ra,0x0
    80005892:	806080e7          	jalr	-2042(ra) # 80005094 <create>
    80005896:	cd11                	beqz	a0,800058b2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005898:	ffffe097          	auipc	ra,0xffffe
    8000589c:	0be080e7          	jalr	190(ra) # 80003956 <iunlockput>
  end_op();
    800058a0:	fffff097          	auipc	ra,0xfffff
    800058a4:	874080e7          	jalr	-1932(ra) # 80004114 <end_op>
  return 0;
    800058a8:	4501                	li	a0,0
}
    800058aa:	60aa                	ld	ra,136(sp)
    800058ac:	640a                	ld	s0,128(sp)
    800058ae:	6149                	add	sp,sp,144
    800058b0:	8082                	ret
    end_op();
    800058b2:	fffff097          	auipc	ra,0xfffff
    800058b6:	862080e7          	jalr	-1950(ra) # 80004114 <end_op>
    return -1;
    800058ba:	557d                	li	a0,-1
    800058bc:	b7fd                	j	800058aa <sys_mkdir+0x4c>

00000000800058be <sys_mknod>:

uint64
sys_mknod(void)
{
    800058be:	7135                	add	sp,sp,-160
    800058c0:	ed06                	sd	ra,152(sp)
    800058c2:	e922                	sd	s0,144(sp)
    800058c4:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800058c6:	ffffe097          	auipc	ra,0xffffe
    800058ca:	7d4080e7          	jalr	2004(ra) # 8000409a <begin_op>
  argint(1, &major);
    800058ce:	f6c40593          	add	a1,s0,-148
    800058d2:	4505                	li	a0,1
    800058d4:	ffffd097          	auipc	ra,0xffffd
    800058d8:	2be080e7          	jalr	702(ra) # 80002b92 <argint>
  argint(2, &minor);
    800058dc:	f6840593          	add	a1,s0,-152
    800058e0:	4509                	li	a0,2
    800058e2:	ffffd097          	auipc	ra,0xffffd
    800058e6:	2b0080e7          	jalr	688(ra) # 80002b92 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800058ea:	08000613          	li	a2,128
    800058ee:	f7040593          	add	a1,s0,-144
    800058f2:	4501                	li	a0,0
    800058f4:	ffffd097          	auipc	ra,0xffffd
    800058f8:	2de080e7          	jalr	734(ra) # 80002bd2 <argstr>
    800058fc:	02054b63          	bltz	a0,80005932 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005900:	f6841683          	lh	a3,-152(s0)
    80005904:	f6c41603          	lh	a2,-148(s0)
    80005908:	458d                	li	a1,3
    8000590a:	f7040513          	add	a0,s0,-144
    8000590e:	fffff097          	auipc	ra,0xfffff
    80005912:	786080e7          	jalr	1926(ra) # 80005094 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005916:	cd11                	beqz	a0,80005932 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005918:	ffffe097          	auipc	ra,0xffffe
    8000591c:	03e080e7          	jalr	62(ra) # 80003956 <iunlockput>
  end_op();
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	7f4080e7          	jalr	2036(ra) # 80004114 <end_op>
  return 0;
    80005928:	4501                	li	a0,0
}
    8000592a:	60ea                	ld	ra,152(sp)
    8000592c:	644a                	ld	s0,144(sp)
    8000592e:	610d                	add	sp,sp,160
    80005930:	8082                	ret
    end_op();
    80005932:	ffffe097          	auipc	ra,0xffffe
    80005936:	7e2080e7          	jalr	2018(ra) # 80004114 <end_op>
    return -1;
    8000593a:	557d                	li	a0,-1
    8000593c:	b7fd                	j	8000592a <sys_mknod+0x6c>

000000008000593e <sys_chdir>:

uint64
sys_chdir(void)
{
    8000593e:	7135                	add	sp,sp,-160
    80005940:	ed06                	sd	ra,152(sp)
    80005942:	e922                	sd	s0,144(sp)
    80005944:	e526                	sd	s1,136(sp)
    80005946:	e14a                	sd	s2,128(sp)
    80005948:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    8000594a:	ffffc097          	auipc	ra,0xffffc
    8000594e:	098080e7          	jalr	152(ra) # 800019e2 <myproc>
    80005952:	892a                	mv	s2,a0
  
  begin_op();
    80005954:	ffffe097          	auipc	ra,0xffffe
    80005958:	746080e7          	jalr	1862(ra) # 8000409a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    8000595c:	08000613          	li	a2,128
    80005960:	f6040593          	add	a1,s0,-160
    80005964:	4501                	li	a0,0
    80005966:	ffffd097          	auipc	ra,0xffffd
    8000596a:	26c080e7          	jalr	620(ra) # 80002bd2 <argstr>
    8000596e:	04054b63          	bltz	a0,800059c4 <sys_chdir+0x86>
    80005972:	f6040513          	add	a0,s0,-160
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	524080e7          	jalr	1316(ra) # 80003e9a <namei>
    8000597e:	84aa                	mv	s1,a0
    80005980:	c131                	beqz	a0,800059c4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005982:	ffffe097          	auipc	ra,0xffffe
    80005986:	d72080e7          	jalr	-654(ra) # 800036f4 <ilock>
  if(ip->type != T_DIR){
    8000598a:	04449703          	lh	a4,68(s1)
    8000598e:	4785                	li	a5,1
    80005990:	04f71063          	bne	a4,a5,800059d0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005994:	8526                	mv	a0,s1
    80005996:	ffffe097          	auipc	ra,0xffffe
    8000599a:	e20080e7          	jalr	-480(ra) # 800037b6 <iunlock>
  iput(p->cwd);
    8000599e:	15093503          	ld	a0,336(s2)
    800059a2:	ffffe097          	auipc	ra,0xffffe
    800059a6:	f0c080e7          	jalr	-244(ra) # 800038ae <iput>
  end_op();
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	76a080e7          	jalr	1898(ra) # 80004114 <end_op>
  p->cwd = ip;
    800059b2:	14993823          	sd	s1,336(s2)
  return 0;
    800059b6:	4501                	li	a0,0
}
    800059b8:	60ea                	ld	ra,152(sp)
    800059ba:	644a                	ld	s0,144(sp)
    800059bc:	64aa                	ld	s1,136(sp)
    800059be:	690a                	ld	s2,128(sp)
    800059c0:	610d                	add	sp,sp,160
    800059c2:	8082                	ret
    end_op();
    800059c4:	ffffe097          	auipc	ra,0xffffe
    800059c8:	750080e7          	jalr	1872(ra) # 80004114 <end_op>
    return -1;
    800059cc:	557d                	li	a0,-1
    800059ce:	b7ed                	j	800059b8 <sys_chdir+0x7a>
    iunlockput(ip);
    800059d0:	8526                	mv	a0,s1
    800059d2:	ffffe097          	auipc	ra,0xffffe
    800059d6:	f84080e7          	jalr	-124(ra) # 80003956 <iunlockput>
    end_op();
    800059da:	ffffe097          	auipc	ra,0xffffe
    800059de:	73a080e7          	jalr	1850(ra) # 80004114 <end_op>
    return -1;
    800059e2:	557d                	li	a0,-1
    800059e4:	bfd1                	j	800059b8 <sys_chdir+0x7a>

00000000800059e6 <sys_exec>:

uint64
sys_exec(void)
{
    800059e6:	7121                	add	sp,sp,-448
    800059e8:	ff06                	sd	ra,440(sp)
    800059ea:	fb22                	sd	s0,432(sp)
    800059ec:	f726                	sd	s1,424(sp)
    800059ee:	f34a                	sd	s2,416(sp)
    800059f0:	ef4e                	sd	s3,408(sp)
    800059f2:	eb52                	sd	s4,400(sp)
    800059f4:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800059f6:	e4840593          	add	a1,s0,-440
    800059fa:	4505                	li	a0,1
    800059fc:	ffffd097          	auipc	ra,0xffffd
    80005a00:	1b6080e7          	jalr	438(ra) # 80002bb2 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a04:	08000613          	li	a2,128
    80005a08:	f5040593          	add	a1,s0,-176
    80005a0c:	4501                	li	a0,0
    80005a0e:	ffffd097          	auipc	ra,0xffffd
    80005a12:	1c4080e7          	jalr	452(ra) # 80002bd2 <argstr>
    80005a16:	87aa                	mv	a5,a0
    return -1;
    80005a18:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a1a:	0c07c263          	bltz	a5,80005ade <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a1e:	10000613          	li	a2,256
    80005a22:	4581                	li	a1,0
    80005a24:	e5040513          	add	a0,s0,-432
    80005a28:	ffffb097          	auipc	ra,0xffffb
    80005a2c:	2a6080e7          	jalr	678(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a30:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a34:	89a6                	mv	s3,s1
    80005a36:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a38:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a3c:	00391513          	sll	a0,s2,0x3
    80005a40:	e4040593          	add	a1,s0,-448
    80005a44:	e4843783          	ld	a5,-440(s0)
    80005a48:	953e                	add	a0,a0,a5
    80005a4a:	ffffd097          	auipc	ra,0xffffd
    80005a4e:	0aa080e7          	jalr	170(ra) # 80002af4 <fetchaddr>
    80005a52:	02054a63          	bltz	a0,80005a86 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005a56:	e4043783          	ld	a5,-448(s0)
    80005a5a:	c3b9                	beqz	a5,80005aa0 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005a5c:	ffffb097          	auipc	ra,0xffffb
    80005a60:	086080e7          	jalr	134(ra) # 80000ae2 <kalloc>
    80005a64:	85aa                	mv	a1,a0
    80005a66:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005a6a:	cd11                	beqz	a0,80005a86 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005a6c:	6605                	lui	a2,0x1
    80005a6e:	e4043503          	ld	a0,-448(s0)
    80005a72:	ffffd097          	auipc	ra,0xffffd
    80005a76:	0d4080e7          	jalr	212(ra) # 80002b46 <fetchstr>
    80005a7a:	00054663          	bltz	a0,80005a86 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005a7e:	0905                	add	s2,s2,1
    80005a80:	09a1                	add	s3,s3,8
    80005a82:	fb491de3          	bne	s2,s4,80005a3c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a86:	f5040913          	add	s2,s0,-176
    80005a8a:	6088                	ld	a0,0(s1)
    80005a8c:	c921                	beqz	a0,80005adc <sys_exec+0xf6>
    kfree(argv[i]);
    80005a8e:	ffffb097          	auipc	ra,0xffffb
    80005a92:	f56080e7          	jalr	-170(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005a96:	04a1                	add	s1,s1,8
    80005a98:	ff2499e3          	bne	s1,s2,80005a8a <sys_exec+0xa4>
  return -1;
    80005a9c:	557d                	li	a0,-1
    80005a9e:	a081                	j	80005ade <sys_exec+0xf8>
      argv[i] = 0;
    80005aa0:	0009079b          	sext.w	a5,s2
    80005aa4:	078e                	sll	a5,a5,0x3
    80005aa6:	fd078793          	add	a5,a5,-48
    80005aaa:	97a2                	add	a5,a5,s0
    80005aac:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ab0:	e5040593          	add	a1,s0,-432
    80005ab4:	f5040513          	add	a0,s0,-176
    80005ab8:	fffff097          	auipc	ra,0xfffff
    80005abc:	1c6080e7          	jalr	454(ra) # 80004c7e <exec>
    80005ac0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ac2:	f5040993          	add	s3,s0,-176
    80005ac6:	6088                	ld	a0,0(s1)
    80005ac8:	c901                	beqz	a0,80005ad8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005aca:	ffffb097          	auipc	ra,0xffffb
    80005ace:	f1a080e7          	jalr	-230(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005ad2:	04a1                	add	s1,s1,8
    80005ad4:	ff3499e3          	bne	s1,s3,80005ac6 <sys_exec+0xe0>
  return ret;
    80005ad8:	854a                	mv	a0,s2
    80005ada:	a011                	j	80005ade <sys_exec+0xf8>
  return -1;
    80005adc:	557d                	li	a0,-1
}
    80005ade:	70fa                	ld	ra,440(sp)
    80005ae0:	745a                	ld	s0,432(sp)
    80005ae2:	74ba                	ld	s1,424(sp)
    80005ae4:	791a                	ld	s2,416(sp)
    80005ae6:	69fa                	ld	s3,408(sp)
    80005ae8:	6a5a                	ld	s4,400(sp)
    80005aea:	6139                	add	sp,sp,448
    80005aec:	8082                	ret

0000000080005aee <sys_pipe>:

uint64
sys_pipe(void)
{
    80005aee:	7139                	add	sp,sp,-64
    80005af0:	fc06                	sd	ra,56(sp)
    80005af2:	f822                	sd	s0,48(sp)
    80005af4:	f426                	sd	s1,40(sp)
    80005af6:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005af8:	ffffc097          	auipc	ra,0xffffc
    80005afc:	eea080e7          	jalr	-278(ra) # 800019e2 <myproc>
    80005b00:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b02:	fd840593          	add	a1,s0,-40
    80005b06:	4501                	li	a0,0
    80005b08:	ffffd097          	auipc	ra,0xffffd
    80005b0c:	0aa080e7          	jalr	170(ra) # 80002bb2 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b10:	fc840593          	add	a1,s0,-56
    80005b14:	fd040513          	add	a0,s0,-48
    80005b18:	fffff097          	auipc	ra,0xfffff
    80005b1c:	d72080e7          	jalr	-654(ra) # 8000488a <pipealloc>
    return -1;
    80005b20:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b22:	0c054463          	bltz	a0,80005bea <sys_pipe+0xfc>
  fd0 = -1;
    80005b26:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b2a:	fd043503          	ld	a0,-48(s0)
    80005b2e:	fffff097          	auipc	ra,0xfffff
    80005b32:	524080e7          	jalr	1316(ra) # 80005052 <fdalloc>
    80005b36:	fca42223          	sw	a0,-60(s0)
    80005b3a:	08054b63          	bltz	a0,80005bd0 <sys_pipe+0xe2>
    80005b3e:	fc843503          	ld	a0,-56(s0)
    80005b42:	fffff097          	auipc	ra,0xfffff
    80005b46:	510080e7          	jalr	1296(ra) # 80005052 <fdalloc>
    80005b4a:	fca42023          	sw	a0,-64(s0)
    80005b4e:	06054863          	bltz	a0,80005bbe <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b52:	4691                	li	a3,4
    80005b54:	fc440613          	add	a2,s0,-60
    80005b58:	fd843583          	ld	a1,-40(s0)
    80005b5c:	68a8                	ld	a0,80(s1)
    80005b5e:	ffffc097          	auipc	ra,0xffffc
    80005b62:	b34080e7          	jalr	-1228(ra) # 80001692 <copyout>
    80005b66:	02054063          	bltz	a0,80005b86 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005b6a:	4691                	li	a3,4
    80005b6c:	fc040613          	add	a2,s0,-64
    80005b70:	fd843583          	ld	a1,-40(s0)
    80005b74:	0591                	add	a1,a1,4
    80005b76:	68a8                	ld	a0,80(s1)
    80005b78:	ffffc097          	auipc	ra,0xffffc
    80005b7c:	b1a080e7          	jalr	-1254(ra) # 80001692 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005b80:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005b82:	06055463          	bgez	a0,80005bea <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005b86:	fc442783          	lw	a5,-60(s0)
    80005b8a:	07e9                	add	a5,a5,26
    80005b8c:	078e                	sll	a5,a5,0x3
    80005b8e:	97a6                	add	a5,a5,s1
    80005b90:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005b94:	fc042783          	lw	a5,-64(s0)
    80005b98:	07e9                	add	a5,a5,26
    80005b9a:	078e                	sll	a5,a5,0x3
    80005b9c:	94be                	add	s1,s1,a5
    80005b9e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005ba2:	fd043503          	ld	a0,-48(s0)
    80005ba6:	fffff097          	auipc	ra,0xfffff
    80005baa:	9b8080e7          	jalr	-1608(ra) # 8000455e <fileclose>
    fileclose(wf);
    80005bae:	fc843503          	ld	a0,-56(s0)
    80005bb2:	fffff097          	auipc	ra,0xfffff
    80005bb6:	9ac080e7          	jalr	-1620(ra) # 8000455e <fileclose>
    return -1;
    80005bba:	57fd                	li	a5,-1
    80005bbc:	a03d                	j	80005bea <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005bbe:	fc442783          	lw	a5,-60(s0)
    80005bc2:	0007c763          	bltz	a5,80005bd0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005bc6:	07e9                	add	a5,a5,26
    80005bc8:	078e                	sll	a5,a5,0x3
    80005bca:	97a6                	add	a5,a5,s1
    80005bcc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005bd0:	fd043503          	ld	a0,-48(s0)
    80005bd4:	fffff097          	auipc	ra,0xfffff
    80005bd8:	98a080e7          	jalr	-1654(ra) # 8000455e <fileclose>
    fileclose(wf);
    80005bdc:	fc843503          	ld	a0,-56(s0)
    80005be0:	fffff097          	auipc	ra,0xfffff
    80005be4:	97e080e7          	jalr	-1666(ra) # 8000455e <fileclose>
    return -1;
    80005be8:	57fd                	li	a5,-1
}
    80005bea:	853e                	mv	a0,a5
    80005bec:	70e2                	ld	ra,56(sp)
    80005bee:	7442                	ld	s0,48(sp)
    80005bf0:	74a2                	ld	s1,40(sp)
    80005bf2:	6121                	add	sp,sp,64
    80005bf4:	8082                	ret
	...

0000000080005c00 <kernelvec>:
    80005c00:	7111                	add	sp,sp,-256
    80005c02:	e006                	sd	ra,0(sp)
    80005c04:	e40a                	sd	sp,8(sp)
    80005c06:	e80e                	sd	gp,16(sp)
    80005c08:	ec12                	sd	tp,24(sp)
    80005c0a:	f016                	sd	t0,32(sp)
    80005c0c:	f41a                	sd	t1,40(sp)
    80005c0e:	f81e                	sd	t2,48(sp)
    80005c10:	fc22                	sd	s0,56(sp)
    80005c12:	e0a6                	sd	s1,64(sp)
    80005c14:	e4aa                	sd	a0,72(sp)
    80005c16:	e8ae                	sd	a1,80(sp)
    80005c18:	ecb2                	sd	a2,88(sp)
    80005c1a:	f0b6                	sd	a3,96(sp)
    80005c1c:	f4ba                	sd	a4,104(sp)
    80005c1e:	f8be                	sd	a5,112(sp)
    80005c20:	fcc2                	sd	a6,120(sp)
    80005c22:	e146                	sd	a7,128(sp)
    80005c24:	e54a                	sd	s2,136(sp)
    80005c26:	e94e                	sd	s3,144(sp)
    80005c28:	ed52                	sd	s4,152(sp)
    80005c2a:	f156                	sd	s5,160(sp)
    80005c2c:	f55a                	sd	s6,168(sp)
    80005c2e:	f95e                	sd	s7,176(sp)
    80005c30:	fd62                	sd	s8,184(sp)
    80005c32:	e1e6                	sd	s9,192(sp)
    80005c34:	e5ea                	sd	s10,200(sp)
    80005c36:	e9ee                	sd	s11,208(sp)
    80005c38:	edf2                	sd	t3,216(sp)
    80005c3a:	f1f6                	sd	t4,224(sp)
    80005c3c:	f5fa                	sd	t5,232(sp)
    80005c3e:	f9fe                	sd	t6,240(sp)
    80005c40:	d81fc0ef          	jal	800029c0 <kerneltrap>
    80005c44:	6082                	ld	ra,0(sp)
    80005c46:	6122                	ld	sp,8(sp)
    80005c48:	61c2                	ld	gp,16(sp)
    80005c4a:	7282                	ld	t0,32(sp)
    80005c4c:	7322                	ld	t1,40(sp)
    80005c4e:	73c2                	ld	t2,48(sp)
    80005c50:	7462                	ld	s0,56(sp)
    80005c52:	6486                	ld	s1,64(sp)
    80005c54:	6526                	ld	a0,72(sp)
    80005c56:	65c6                	ld	a1,80(sp)
    80005c58:	6666                	ld	a2,88(sp)
    80005c5a:	7686                	ld	a3,96(sp)
    80005c5c:	7726                	ld	a4,104(sp)
    80005c5e:	77c6                	ld	a5,112(sp)
    80005c60:	7866                	ld	a6,120(sp)
    80005c62:	688a                	ld	a7,128(sp)
    80005c64:	692a                	ld	s2,136(sp)
    80005c66:	69ca                	ld	s3,144(sp)
    80005c68:	6a6a                	ld	s4,152(sp)
    80005c6a:	7a8a                	ld	s5,160(sp)
    80005c6c:	7b2a                	ld	s6,168(sp)
    80005c6e:	7bca                	ld	s7,176(sp)
    80005c70:	7c6a                	ld	s8,184(sp)
    80005c72:	6c8e                	ld	s9,192(sp)
    80005c74:	6d2e                	ld	s10,200(sp)
    80005c76:	6dce                	ld	s11,208(sp)
    80005c78:	6e6e                	ld	t3,216(sp)
    80005c7a:	7e8e                	ld	t4,224(sp)
    80005c7c:	7f2e                	ld	t5,232(sp)
    80005c7e:	7fce                	ld	t6,240(sp)
    80005c80:	6111                	add	sp,sp,256
    80005c82:	10200073          	sret
    80005c86:	00000013          	nop
    80005c8a:	00000013          	nop
    80005c8e:	0001                	nop

0000000080005c90 <timervec>:
    80005c90:	34051573          	csrrw	a0,mscratch,a0
    80005c94:	e10c                	sd	a1,0(a0)
    80005c96:	e510                	sd	a2,8(a0)
    80005c98:	e914                	sd	a3,16(a0)
    80005c9a:	6d0c                	ld	a1,24(a0)
    80005c9c:	7110                	ld	a2,32(a0)
    80005c9e:	6194                	ld	a3,0(a1)
    80005ca0:	96b2                	add	a3,a3,a2
    80005ca2:	e194                	sd	a3,0(a1)
    80005ca4:	4589                	li	a1,2
    80005ca6:	14459073          	csrw	sip,a1
    80005caa:	6914                	ld	a3,16(a0)
    80005cac:	6510                	ld	a2,8(a0)
    80005cae:	610c                	ld	a1,0(a0)
    80005cb0:	34051573          	csrrw	a0,mscratch,a0
    80005cb4:	30200073          	mret
	...

0000000080005cba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005cba:	1141                	add	sp,sp,-16
    80005cbc:	e422                	sd	s0,8(sp)
    80005cbe:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005cc0:	0c0007b7          	lui	a5,0xc000
    80005cc4:	4705                	li	a4,1
    80005cc6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005cc8:	c3d8                	sw	a4,4(a5)
}
    80005cca:	6422                	ld	s0,8(sp)
    80005ccc:	0141                	add	sp,sp,16
    80005cce:	8082                	ret

0000000080005cd0 <plicinithart>:

void
plicinithart(void)
{
    80005cd0:	1141                	add	sp,sp,-16
    80005cd2:	e406                	sd	ra,8(sp)
    80005cd4:	e022                	sd	s0,0(sp)
    80005cd6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005cd8:	ffffc097          	auipc	ra,0xffffc
    80005cdc:	cde080e7          	jalr	-802(ra) # 800019b6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ce0:	0085171b          	sllw	a4,a0,0x8
    80005ce4:	0c0027b7          	lui	a5,0xc002
    80005ce8:	97ba                	add	a5,a5,a4
    80005cea:	40200713          	li	a4,1026
    80005cee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005cf2:	00d5151b          	sllw	a0,a0,0xd
    80005cf6:	0c2017b7          	lui	a5,0xc201
    80005cfa:	97aa                	add	a5,a5,a0
    80005cfc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d00:	60a2                	ld	ra,8(sp)
    80005d02:	6402                	ld	s0,0(sp)
    80005d04:	0141                	add	sp,sp,16
    80005d06:	8082                	ret

0000000080005d08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d08:	1141                	add	sp,sp,-16
    80005d0a:	e406                	sd	ra,8(sp)
    80005d0c:	e022                	sd	s0,0(sp)
    80005d0e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005d10:	ffffc097          	auipc	ra,0xffffc
    80005d14:	ca6080e7          	jalr	-858(ra) # 800019b6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d18:	00d5151b          	sllw	a0,a0,0xd
    80005d1c:	0c2017b7          	lui	a5,0xc201
    80005d20:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d22:	43c8                	lw	a0,4(a5)
    80005d24:	60a2                	ld	ra,8(sp)
    80005d26:	6402                	ld	s0,0(sp)
    80005d28:	0141                	add	sp,sp,16
    80005d2a:	8082                	ret

0000000080005d2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d2c:	1101                	add	sp,sp,-32
    80005d2e:	ec06                	sd	ra,24(sp)
    80005d30:	e822                	sd	s0,16(sp)
    80005d32:	e426                	sd	s1,8(sp)
    80005d34:	1000                	add	s0,sp,32
    80005d36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d38:	ffffc097          	auipc	ra,0xffffc
    80005d3c:	c7e080e7          	jalr	-898(ra) # 800019b6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d40:	00d5151b          	sllw	a0,a0,0xd
    80005d44:	0c2017b7          	lui	a5,0xc201
    80005d48:	97aa                	add	a5,a5,a0
    80005d4a:	c3c4                	sw	s1,4(a5)
}
    80005d4c:	60e2                	ld	ra,24(sp)
    80005d4e:	6442                	ld	s0,16(sp)
    80005d50:	64a2                	ld	s1,8(sp)
    80005d52:	6105                	add	sp,sp,32
    80005d54:	8082                	ret

0000000080005d56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005d56:	1141                	add	sp,sp,-16
    80005d58:	e406                	sd	ra,8(sp)
    80005d5a:	e022                	sd	s0,0(sp)
    80005d5c:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005d5e:	479d                	li	a5,7
    80005d60:	04a7cc63          	blt	a5,a0,80005db8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005d64:	00193797          	auipc	a5,0x193
    80005d68:	48478793          	add	a5,a5,1156 # 801991e8 <disk>
    80005d6c:	97aa                	add	a5,a5,a0
    80005d6e:	0187c783          	lbu	a5,24(a5)
    80005d72:	ebb9                	bnez	a5,80005dc8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005d74:	00451693          	sll	a3,a0,0x4
    80005d78:	00193797          	auipc	a5,0x193
    80005d7c:	47078793          	add	a5,a5,1136 # 801991e8 <disk>
    80005d80:	6398                	ld	a4,0(a5)
    80005d82:	9736                	add	a4,a4,a3
    80005d84:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005d88:	6398                	ld	a4,0(a5)
    80005d8a:	9736                	add	a4,a4,a3
    80005d8c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005d90:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005d94:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005d98:	97aa                	add	a5,a5,a0
    80005d9a:	4705                	li	a4,1
    80005d9c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005da0:	00193517          	auipc	a0,0x193
    80005da4:	46050513          	add	a0,a0,1120 # 80199200 <disk+0x18>
    80005da8:	ffffc097          	auipc	ra,0xffffc
    80005dac:	3aa080e7          	jalr	938(ra) # 80002152 <wakeup>
}
    80005db0:	60a2                	ld	ra,8(sp)
    80005db2:	6402                	ld	s0,0(sp)
    80005db4:	0141                	add	sp,sp,16
    80005db6:	8082                	ret
    panic("free_desc 1");
    80005db8:	00003517          	auipc	a0,0x3
    80005dbc:	9c050513          	add	a0,a0,-1600 # 80008778 <syscalls+0x300>
    80005dc0:	ffffa097          	auipc	ra,0xffffa
    80005dc4:	77c080e7          	jalr	1916(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005dc8:	00003517          	auipc	a0,0x3
    80005dcc:	9c050513          	add	a0,a0,-1600 # 80008788 <syscalls+0x310>
    80005dd0:	ffffa097          	auipc	ra,0xffffa
    80005dd4:	76c080e7          	jalr	1900(ra) # 8000053c <panic>

0000000080005dd8 <virtio_disk_init>:
{
    80005dd8:	1101                	add	sp,sp,-32
    80005dda:	ec06                	sd	ra,24(sp)
    80005ddc:	e822                	sd	s0,16(sp)
    80005dde:	e426                	sd	s1,8(sp)
    80005de0:	e04a                	sd	s2,0(sp)
    80005de2:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005de4:	00003597          	auipc	a1,0x3
    80005de8:	9b458593          	add	a1,a1,-1612 # 80008798 <syscalls+0x320>
    80005dec:	00193517          	auipc	a0,0x193
    80005df0:	52450513          	add	a0,a0,1316 # 80199310 <disk+0x128>
    80005df4:	ffffb097          	auipc	ra,0xffffb
    80005df8:	d4e080e7          	jalr	-690(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005dfc:	100017b7          	lui	a5,0x10001
    80005e00:	4398                	lw	a4,0(a5)
    80005e02:	2701                	sext.w	a4,a4
    80005e04:	747277b7          	lui	a5,0x74727
    80005e08:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e0c:	14f71b63          	bne	a4,a5,80005f62 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e10:	100017b7          	lui	a5,0x10001
    80005e14:	43dc                	lw	a5,4(a5)
    80005e16:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e18:	4709                	li	a4,2
    80005e1a:	14e79463          	bne	a5,a4,80005f62 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e1e:	100017b7          	lui	a5,0x10001
    80005e22:	479c                	lw	a5,8(a5)
    80005e24:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e26:	12e79e63          	bne	a5,a4,80005f62 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e2a:	100017b7          	lui	a5,0x10001
    80005e2e:	47d8                	lw	a4,12(a5)
    80005e30:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e32:	554d47b7          	lui	a5,0x554d4
    80005e36:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e3a:	12f71463          	bne	a4,a5,80005f62 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e3e:	100017b7          	lui	a5,0x10001
    80005e42:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e46:	4705                	li	a4,1
    80005e48:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e4a:	470d                	li	a4,3
    80005e4c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e4e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005e50:	c7ffe6b7          	lui	a3,0xc7ffe
    80005e54:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47e6504f>
    80005e58:	8f75                	and	a4,a4,a3
    80005e5a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e5c:	472d                	li	a4,11
    80005e5e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005e60:	5bbc                	lw	a5,112(a5)
    80005e62:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005e66:	8ba1                	and	a5,a5,8
    80005e68:	10078563          	beqz	a5,80005f72 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005e6c:	100017b7          	lui	a5,0x10001
    80005e70:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005e74:	43fc                	lw	a5,68(a5)
    80005e76:	2781                	sext.w	a5,a5
    80005e78:	10079563          	bnez	a5,80005f82 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005e7c:	100017b7          	lui	a5,0x10001
    80005e80:	5bdc                	lw	a5,52(a5)
    80005e82:	2781                	sext.w	a5,a5
  if(max == 0)
    80005e84:	10078763          	beqz	a5,80005f92 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005e88:	471d                	li	a4,7
    80005e8a:	10f77c63          	bgeu	a4,a5,80005fa2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005e8e:	ffffb097          	auipc	ra,0xffffb
    80005e92:	c54080e7          	jalr	-940(ra) # 80000ae2 <kalloc>
    80005e96:	00193497          	auipc	s1,0x193
    80005e9a:	35248493          	add	s1,s1,850 # 801991e8 <disk>
    80005e9e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ea0:	ffffb097          	auipc	ra,0xffffb
    80005ea4:	c42080e7          	jalr	-958(ra) # 80000ae2 <kalloc>
    80005ea8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005eaa:	ffffb097          	auipc	ra,0xffffb
    80005eae:	c38080e7          	jalr	-968(ra) # 80000ae2 <kalloc>
    80005eb2:	87aa                	mv	a5,a0
    80005eb4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005eb6:	6088                	ld	a0,0(s1)
    80005eb8:	cd6d                	beqz	a0,80005fb2 <virtio_disk_init+0x1da>
    80005eba:	00193717          	auipc	a4,0x193
    80005ebe:	33673703          	ld	a4,822(a4) # 801991f0 <disk+0x8>
    80005ec2:	cb65                	beqz	a4,80005fb2 <virtio_disk_init+0x1da>
    80005ec4:	c7fd                	beqz	a5,80005fb2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005ec6:	6605                	lui	a2,0x1
    80005ec8:	4581                	li	a1,0
    80005eca:	ffffb097          	auipc	ra,0xffffb
    80005ece:	e04080e7          	jalr	-508(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005ed2:	00193497          	auipc	s1,0x193
    80005ed6:	31648493          	add	s1,s1,790 # 801991e8 <disk>
    80005eda:	6605                	lui	a2,0x1
    80005edc:	4581                	li	a1,0
    80005ede:	6488                	ld	a0,8(s1)
    80005ee0:	ffffb097          	auipc	ra,0xffffb
    80005ee4:	dee080e7          	jalr	-530(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005ee8:	6605                	lui	a2,0x1
    80005eea:	4581                	li	a1,0
    80005eec:	6888                	ld	a0,16(s1)
    80005eee:	ffffb097          	auipc	ra,0xffffb
    80005ef2:	de0080e7          	jalr	-544(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005ef6:	100017b7          	lui	a5,0x10001
    80005efa:	4721                	li	a4,8
    80005efc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005efe:	4098                	lw	a4,0(s1)
    80005f00:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f04:	40d8                	lw	a4,4(s1)
    80005f06:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f0a:	6498                	ld	a4,8(s1)
    80005f0c:	0007069b          	sext.w	a3,a4
    80005f10:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f14:	9701                	sra	a4,a4,0x20
    80005f16:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f1a:	6898                	ld	a4,16(s1)
    80005f1c:	0007069b          	sext.w	a3,a4
    80005f20:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f24:	9701                	sra	a4,a4,0x20
    80005f26:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f2a:	4705                	li	a4,1
    80005f2c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f2e:	00e48c23          	sb	a4,24(s1)
    80005f32:	00e48ca3          	sb	a4,25(s1)
    80005f36:	00e48d23          	sb	a4,26(s1)
    80005f3a:	00e48da3          	sb	a4,27(s1)
    80005f3e:	00e48e23          	sb	a4,28(s1)
    80005f42:	00e48ea3          	sb	a4,29(s1)
    80005f46:	00e48f23          	sb	a4,30(s1)
    80005f4a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f4e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f52:	0727a823          	sw	s2,112(a5)
}
    80005f56:	60e2                	ld	ra,24(sp)
    80005f58:	6442                	ld	s0,16(sp)
    80005f5a:	64a2                	ld	s1,8(sp)
    80005f5c:	6902                	ld	s2,0(sp)
    80005f5e:	6105                	add	sp,sp,32
    80005f60:	8082                	ret
    panic("could not find virtio disk");
    80005f62:	00003517          	auipc	a0,0x3
    80005f66:	84650513          	add	a0,a0,-1978 # 800087a8 <syscalls+0x330>
    80005f6a:	ffffa097          	auipc	ra,0xffffa
    80005f6e:	5d2080e7          	jalr	1490(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005f72:	00003517          	auipc	a0,0x3
    80005f76:	85650513          	add	a0,a0,-1962 # 800087c8 <syscalls+0x350>
    80005f7a:	ffffa097          	auipc	ra,0xffffa
    80005f7e:	5c2080e7          	jalr	1474(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005f82:	00003517          	auipc	a0,0x3
    80005f86:	86650513          	add	a0,a0,-1946 # 800087e8 <syscalls+0x370>
    80005f8a:	ffffa097          	auipc	ra,0xffffa
    80005f8e:	5b2080e7          	jalr	1458(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005f92:	00003517          	auipc	a0,0x3
    80005f96:	87650513          	add	a0,a0,-1930 # 80008808 <syscalls+0x390>
    80005f9a:	ffffa097          	auipc	ra,0xffffa
    80005f9e:	5a2080e7          	jalr	1442(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005fa2:	00003517          	auipc	a0,0x3
    80005fa6:	88650513          	add	a0,a0,-1914 # 80008828 <syscalls+0x3b0>
    80005faa:	ffffa097          	auipc	ra,0xffffa
    80005fae:	592080e7          	jalr	1426(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	89650513          	add	a0,a0,-1898 # 80008848 <syscalls+0x3d0>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>

0000000080005fc2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005fc2:	7159                	add	sp,sp,-112
    80005fc4:	f486                	sd	ra,104(sp)
    80005fc6:	f0a2                	sd	s0,96(sp)
    80005fc8:	eca6                	sd	s1,88(sp)
    80005fca:	e8ca                	sd	s2,80(sp)
    80005fcc:	e4ce                	sd	s3,72(sp)
    80005fce:	e0d2                	sd	s4,64(sp)
    80005fd0:	fc56                	sd	s5,56(sp)
    80005fd2:	f85a                	sd	s6,48(sp)
    80005fd4:	f45e                	sd	s7,40(sp)
    80005fd6:	f062                	sd	s8,32(sp)
    80005fd8:	ec66                	sd	s9,24(sp)
    80005fda:	e86a                	sd	s10,16(sp)
    80005fdc:	1880                	add	s0,sp,112
    80005fde:	8a2a                	mv	s4,a0
    80005fe0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005fe2:	00c52c83          	lw	s9,12(a0)
    80005fe6:	001c9c9b          	sllw	s9,s9,0x1
    80005fea:	1c82                	sll	s9,s9,0x20
    80005fec:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ff0:	00193517          	auipc	a0,0x193
    80005ff4:	32050513          	add	a0,a0,800 # 80199310 <disk+0x128>
    80005ff8:	ffffb097          	auipc	ra,0xffffb
    80005ffc:	bda080e7          	jalr	-1062(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006000:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006002:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006004:	00193b17          	auipc	s6,0x193
    80006008:	1e4b0b13          	add	s6,s6,484 # 801991e8 <disk>
  for(int i = 0; i < 3; i++){
    8000600c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000600e:	00193c17          	auipc	s8,0x193
    80006012:	302c0c13          	add	s8,s8,770 # 80199310 <disk+0x128>
    80006016:	a095                	j	8000607a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006018:	00fb0733          	add	a4,s6,a5
    8000601c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006020:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006022:	0207c563          	bltz	a5,8000604c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006026:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006028:	0591                	add	a1,a1,4
    8000602a:	05560d63          	beq	a2,s5,80006084 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000602e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006030:	00193717          	auipc	a4,0x193
    80006034:	1b870713          	add	a4,a4,440 # 801991e8 <disk>
    80006038:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000603a:	01874683          	lbu	a3,24(a4)
    8000603e:	fee9                	bnez	a3,80006018 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006040:	2785                	addw	a5,a5,1
    80006042:	0705                	add	a4,a4,1
    80006044:	fe979be3          	bne	a5,s1,8000603a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006048:	57fd                	li	a5,-1
    8000604a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000604c:	00c05e63          	blez	a2,80006068 <virtio_disk_rw+0xa6>
    80006050:	060a                	sll	a2,a2,0x2
    80006052:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006056:	0009a503          	lw	a0,0(s3)
    8000605a:	00000097          	auipc	ra,0x0
    8000605e:	cfc080e7          	jalr	-772(ra) # 80005d56 <free_desc>
      for(int j = 0; j < i; j++)
    80006062:	0991                	add	s3,s3,4
    80006064:	ffa999e3          	bne	s3,s10,80006056 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006068:	85e2                	mv	a1,s8
    8000606a:	00193517          	auipc	a0,0x193
    8000606e:	19650513          	add	a0,a0,406 # 80199200 <disk+0x18>
    80006072:	ffffc097          	auipc	ra,0xffffc
    80006076:	07c080e7          	jalr	124(ra) # 800020ee <sleep>
  for(int i = 0; i < 3; i++){
    8000607a:	f9040993          	add	s3,s0,-112
{
    8000607e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006080:	864a                	mv	a2,s2
    80006082:	b775                	j	8000602e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006084:	f9042503          	lw	a0,-112(s0)
    80006088:	00a50713          	add	a4,a0,10
    8000608c:	0712                	sll	a4,a4,0x4

  if(write)
    8000608e:	00193797          	auipc	a5,0x193
    80006092:	15a78793          	add	a5,a5,346 # 801991e8 <disk>
    80006096:	00e786b3          	add	a3,a5,a4
    8000609a:	01703633          	snez	a2,s7
    8000609e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060a0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060a4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060a8:	f6070613          	add	a2,a4,-160
    800060ac:	6394                	ld	a3,0(a5)
    800060ae:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060b0:	00870593          	add	a1,a4,8
    800060b4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800060b6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800060b8:	0007b803          	ld	a6,0(a5)
    800060bc:	9642                	add	a2,a2,a6
    800060be:	46c1                	li	a3,16
    800060c0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800060c2:	4585                	li	a1,1
    800060c4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800060c8:	f9442683          	lw	a3,-108(s0)
    800060cc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800060d0:	0692                	sll	a3,a3,0x4
    800060d2:	9836                	add	a6,a6,a3
    800060d4:	058a0613          	add	a2,s4,88
    800060d8:	00c83023          	sd	a2,0(a6) # 1000 <_entry-0x7ffff000>
  disk.desc[idx[1]].len = BSIZE;
    800060dc:	0007b803          	ld	a6,0(a5)
    800060e0:	96c2                	add	a3,a3,a6
    800060e2:	40000613          	li	a2,1024
    800060e6:	c690                	sw	a2,8(a3)
  if(write)
    800060e8:	001bb613          	seqz	a2,s7
    800060ec:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800060f0:	00166613          	or	a2,a2,1
    800060f4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800060f8:	f9842603          	lw	a2,-104(s0)
    800060fc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006100:	00250693          	add	a3,a0,2
    80006104:	0692                	sll	a3,a3,0x4
    80006106:	96be                	add	a3,a3,a5
    80006108:	58fd                	li	a7,-1
    8000610a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000610e:	0612                	sll	a2,a2,0x4
    80006110:	9832                	add	a6,a6,a2
    80006112:	f9070713          	add	a4,a4,-112
    80006116:	973e                	add	a4,a4,a5
    80006118:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000611c:	6398                	ld	a4,0(a5)
    8000611e:	9732                	add	a4,a4,a2
    80006120:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006122:	4609                	li	a2,2
    80006124:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006128:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000612c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006130:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006134:	6794                	ld	a3,8(a5)
    80006136:	0026d703          	lhu	a4,2(a3)
    8000613a:	8b1d                	and	a4,a4,7
    8000613c:	0706                	sll	a4,a4,0x1
    8000613e:	96ba                	add	a3,a3,a4
    80006140:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006144:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006148:	6798                	ld	a4,8(a5)
    8000614a:	00275783          	lhu	a5,2(a4)
    8000614e:	2785                	addw	a5,a5,1
    80006150:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006154:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006158:	100017b7          	lui	a5,0x10001
    8000615c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006160:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006164:	00193917          	auipc	s2,0x193
    80006168:	1ac90913          	add	s2,s2,428 # 80199310 <disk+0x128>
  while(b->disk == 1) {
    8000616c:	4485                	li	s1,1
    8000616e:	00b79c63          	bne	a5,a1,80006186 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006172:	85ca                	mv	a1,s2
    80006174:	8552                	mv	a0,s4
    80006176:	ffffc097          	auipc	ra,0xffffc
    8000617a:	f78080e7          	jalr	-136(ra) # 800020ee <sleep>
  while(b->disk == 1) {
    8000617e:	004a2783          	lw	a5,4(s4)
    80006182:	fe9788e3          	beq	a5,s1,80006172 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006186:	f9042903          	lw	s2,-112(s0)
    8000618a:	00290713          	add	a4,s2,2
    8000618e:	0712                	sll	a4,a4,0x4
    80006190:	00193797          	auipc	a5,0x193
    80006194:	05878793          	add	a5,a5,88 # 801991e8 <disk>
    80006198:	97ba                	add	a5,a5,a4
    8000619a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000619e:	00193997          	auipc	s3,0x193
    800061a2:	04a98993          	add	s3,s3,74 # 801991e8 <disk>
    800061a6:	00491713          	sll	a4,s2,0x4
    800061aa:	0009b783          	ld	a5,0(s3)
    800061ae:	97ba                	add	a5,a5,a4
    800061b0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800061b4:	854a                	mv	a0,s2
    800061b6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800061ba:	00000097          	auipc	ra,0x0
    800061be:	b9c080e7          	jalr	-1124(ra) # 80005d56 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800061c2:	8885                	and	s1,s1,1
    800061c4:	f0ed                	bnez	s1,800061a6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800061c6:	00193517          	auipc	a0,0x193
    800061ca:	14a50513          	add	a0,a0,330 # 80199310 <disk+0x128>
    800061ce:	ffffb097          	auipc	ra,0xffffb
    800061d2:	ab8080e7          	jalr	-1352(ra) # 80000c86 <release>
}
    800061d6:	70a6                	ld	ra,104(sp)
    800061d8:	7406                	ld	s0,96(sp)
    800061da:	64e6                	ld	s1,88(sp)
    800061dc:	6946                	ld	s2,80(sp)
    800061de:	69a6                	ld	s3,72(sp)
    800061e0:	6a06                	ld	s4,64(sp)
    800061e2:	7ae2                	ld	s5,56(sp)
    800061e4:	7b42                	ld	s6,48(sp)
    800061e6:	7ba2                	ld	s7,40(sp)
    800061e8:	7c02                	ld	s8,32(sp)
    800061ea:	6ce2                	ld	s9,24(sp)
    800061ec:	6d42                	ld	s10,16(sp)
    800061ee:	6165                	add	sp,sp,112
    800061f0:	8082                	ret

00000000800061f2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800061f2:	1101                	add	sp,sp,-32
    800061f4:	ec06                	sd	ra,24(sp)
    800061f6:	e822                	sd	s0,16(sp)
    800061f8:	e426                	sd	s1,8(sp)
    800061fa:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800061fc:	00193497          	auipc	s1,0x193
    80006200:	fec48493          	add	s1,s1,-20 # 801991e8 <disk>
    80006204:	00193517          	auipc	a0,0x193
    80006208:	10c50513          	add	a0,a0,268 # 80199310 <disk+0x128>
    8000620c:	ffffb097          	auipc	ra,0xffffb
    80006210:	9c6080e7          	jalr	-1594(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006214:	10001737          	lui	a4,0x10001
    80006218:	533c                	lw	a5,96(a4)
    8000621a:	8b8d                	and	a5,a5,3
    8000621c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000621e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006222:	689c                	ld	a5,16(s1)
    80006224:	0204d703          	lhu	a4,32(s1)
    80006228:	0027d783          	lhu	a5,2(a5)
    8000622c:	04f70863          	beq	a4,a5,8000627c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006230:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006234:	6898                	ld	a4,16(s1)
    80006236:	0204d783          	lhu	a5,32(s1)
    8000623a:	8b9d                	and	a5,a5,7
    8000623c:	078e                	sll	a5,a5,0x3
    8000623e:	97ba                	add	a5,a5,a4
    80006240:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006242:	00278713          	add	a4,a5,2
    80006246:	0712                	sll	a4,a4,0x4
    80006248:	9726                	add	a4,a4,s1
    8000624a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000624e:	e721                	bnez	a4,80006296 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006250:	0789                	add	a5,a5,2
    80006252:	0792                	sll	a5,a5,0x4
    80006254:	97a6                	add	a5,a5,s1
    80006256:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006258:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000625c:	ffffc097          	auipc	ra,0xffffc
    80006260:	ef6080e7          	jalr	-266(ra) # 80002152 <wakeup>

    disk.used_idx += 1;
    80006264:	0204d783          	lhu	a5,32(s1)
    80006268:	2785                	addw	a5,a5,1
    8000626a:	17c2                	sll	a5,a5,0x30
    8000626c:	93c1                	srl	a5,a5,0x30
    8000626e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006272:	6898                	ld	a4,16(s1)
    80006274:	00275703          	lhu	a4,2(a4)
    80006278:	faf71ce3          	bne	a4,a5,80006230 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000627c:	00193517          	auipc	a0,0x193
    80006280:	09450513          	add	a0,a0,148 # 80199310 <disk+0x128>
    80006284:	ffffb097          	auipc	ra,0xffffb
    80006288:	a02080e7          	jalr	-1534(ra) # 80000c86 <release>
}
    8000628c:	60e2                	ld	ra,24(sp)
    8000628e:	6442                	ld	s0,16(sp)
    80006290:	64a2                	ld	s1,8(sp)
    80006292:	6105                	add	sp,sp,32
    80006294:	8082                	ret
      panic("virtio_disk_intr status");
    80006296:	00002517          	auipc	a0,0x2
    8000629a:	5ca50513          	add	a0,a0,1482 # 80008860 <syscalls+0x3e8>
    8000629e:	ffffa097          	auipc	ra,0xffffa
    800062a2:	29e080e7          	jalr	670(ra) # 8000053c <panic>

00000000800062a6 <read_current_timestamp>:

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
    800062a6:	1101                	add	sp,sp,-32
    800062a8:	ec06                	sd	ra,24(sp)
    800062aa:	e822                	sd	s0,16(sp)
    800062ac:	e426                	sd	s1,8(sp)
    800062ae:	1000                	add	s0,sp,32
  uint64 curticks = 0;
  acquire(&tickslock);
    800062b0:	00188517          	auipc	a0,0x188
    800062b4:	c9050513          	add	a0,a0,-880 # 8018df40 <tickslock>
    800062b8:	ffffb097          	auipc	ra,0xffffb
    800062bc:	91a080e7          	jalr	-1766(ra) # 80000bd2 <acquire>
  curticks = ticks;
    800062c0:	00002517          	auipc	a0,0x2
    800062c4:	7e050513          	add	a0,a0,2016 # 80008aa0 <ticks>
    800062c8:	00056483          	lwu	s1,0(a0)
  wakeup(&ticks);
    800062cc:	ffffc097          	auipc	ra,0xffffc
    800062d0:	e86080e7          	jalr	-378(ra) # 80002152 <wakeup>
  release(&tickslock);
    800062d4:	00188517          	auipc	a0,0x188
    800062d8:	c6c50513          	add	a0,a0,-916 # 8018df40 <tickslock>
    800062dc:	ffffb097          	auipc	ra,0xffffb
    800062e0:	9aa080e7          	jalr	-1622(ra) # 80000c86 <release>
  return curticks;
}
    800062e4:	8526                	mv	a0,s1
    800062e6:	60e2                	ld	ra,24(sp)
    800062e8:	6442                	ld	s0,16(sp)
    800062ea:	64a2                	ld	s1,8(sp)
    800062ec:	6105                	add	sp,sp,32
    800062ee:	8082                	ret

00000000800062f0 <init_psa_regions>:

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    800062f0:	1141                	add	sp,sp,-16
    800062f2:	e422                	sd	s0,8(sp)
    800062f4:	0800                	add	s0,sp,16
    for (int i = 0; i < PSASIZE; i++) 
    800062f6:	00193797          	auipc	a5,0x193
    800062fa:	03278793          	add	a5,a5,50 # 80199328 <psa_tracker>
    800062fe:	00193717          	auipc	a4,0x193
    80006302:	41270713          	add	a4,a4,1042 # 80199710 <end>
        psa_tracker[i] = false;
    80006306:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PSASIZE; i++) 
    8000630a:	0785                	add	a5,a5,1
    8000630c:	fee79de3          	bne	a5,a4,80006306 <init_psa_regions+0x16>
}
    80006310:	6422                	ld	s0,8(sp)
    80006312:	0141                	add	sp,sp,16
    80006314:	8082                	ret

0000000080006316 <evict_page_to_disk>:

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    80006316:	1101                	add	sp,sp,-32
    80006318:	ec06                	sd	ra,24(sp)
    8000631a:	e822                	sd	s0,16(sp)
    8000631c:	e426                	sd	s1,8(sp)
    8000631e:	1000                	add	s0,sp,32
    /* Find free block */
    int blockno = 0;
    /* Find victim page using FIFO. */
    /* Print statement. */
    print_evict_page(0, 0);
    80006320:	4581                	li	a1,0
    80006322:	4501                	li	a0,0
    80006324:	00000097          	auipc	ra,0x0
    80006328:	15a080e7          	jalr	346(ra) # 8000647e <print_evict_page>
    /* Read memory from the user to kernel memory first. */
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    struct buf* b;
    b = bread(1, PSASTART+(blockno));
    8000632c:	02100593          	li	a1,33
    80006330:	4505                	li	a0,1
    80006332:	ffffd097          	auipc	ra,0xffffd
    80006336:	bb2080e7          	jalr	-1102(ra) # 80002ee4 <bread>
    8000633a:	84aa                	mv	s1,a0
        // Copy page contents to b.data using memmove.
    bwrite(b);
    8000633c:	ffffd097          	auipc	ra,0xffffd
    80006340:	c9a080e7          	jalr	-870(ra) # 80002fd6 <bwrite>
    brelse(b);
    80006344:	8526                	mv	a0,s1
    80006346:	ffffd097          	auipc	ra,0xffffd
    8000634a:	cce080e7          	jalr	-818(ra) # 80003014 <brelse>

    /* Unmap swapped out page */
    /* Update the resident heap tracker. */
}
    8000634e:	60e2                	ld	ra,24(sp)
    80006350:	6442                	ld	s0,16(sp)
    80006352:	64a2                	ld	s1,8(sp)
    80006354:	6105                	add	sp,sp,32
    80006356:	8082                	ret

0000000080006358 <retrieve_page_from_disk>:

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    80006358:	1141                	add	sp,sp,-16
    8000635a:	e406                	sd	ra,8(sp)
    8000635c:	e022                	sd	s0,0(sp)
    8000635e:	0800                	add	s0,sp,16
    /* Find where the page is located in disk */

    /* Print statement. */
    print_retrieve_page(0, 0);
    80006360:	4581                	li	a1,0
    80006362:	4501                	li	a0,0
    80006364:	00000097          	auipc	ra,0x0
    80006368:	142080e7          	jalr	322(ra) # 800064a6 <print_retrieve_page>
    /* Create a kernel page to read memory temporarily into first. */
    
    /* Read the disk block into temp kernel page. */

    /* Copy from temp kernel page to uvaddr (use copyout) */
}
    8000636c:	60a2                	ld	ra,8(sp)
    8000636e:	6402                	ld	s0,0(sp)
    80006370:	0141                	add	sp,sp,16
    80006372:	8082                	ret

0000000080006374 <page_fault_handler>:


void page_fault_handler(void) 
{
    80006374:	1101                	add	sp,sp,-32
    80006376:	ec06                	sd	ra,24(sp)
    80006378:	e822                	sd	s0,16(sp)
    8000637a:	e426                	sd	s1,8(sp)
    8000637c:	1000                	add	s0,sp,32
    /* Current process struct */
    struct proc *p = myproc();
    8000637e:	ffffb097          	auipc	ra,0xffffb
    80006382:	664080e7          	jalr	1636(ra) # 800019e2 <myproc>
    80006386:	84aa                	mv	s1,a0
    80006388:	143025f3          	csrr	a1,stval
    /* Find faulting address. */
    uint64 faulting_addr = 0;
    faulting_addr = r_stval();
    // get the faulting address from stval and find the base address of the page
    faulting_addr = PGROUNDDOWN(faulting_addr);
    print_page_fault(p->name, faulting_addr);
    8000638c:	77fd                	lui	a5,0xfffff
    8000638e:	8dfd                	and	a1,a1,a5
    80006390:	15850513          	add	a0,a0,344
    80006394:	00000097          	auipc	ra,0x0
    80006398:	0aa080e7          	jalr	170(ra) # 8000643e <print_page_fault>
    /* Go to out, since the remainder of this code is for the heap. */
    goto out;

heap_handle:
    /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages == MAXRESHEAP) {
    8000639c:	6799                	lui	a5,0x6
    8000639e:	97a6                	add	a5,a5,s1
    800063a0:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    800063a4:	06400793          	li	a5,100
    800063a8:	02f70063          	beq	a4,a5,800063c8 <page_fault_handler+0x54>
    if (load_from_disk) {
        retrieve_page_from_disk(p, faulting_addr);
    }

    /* Track that another heap page has been brought into memory. */
    p->resident_heap_pages++;
    800063ac:	6799                	lui	a5,0x6
    800063ae:	94be                	add	s1,s1,a5
    800063b0:	f304a783          	lw	a5,-208(s1)
    800063b4:	2785                	addw	a5,a5,1 # 6001 <_entry-0x7fff9fff>
    800063b6:	f2f4a823          	sw	a5,-208(s1)
  asm volatile("sfence.vma zero, zero");
    800063ba:	12000073          	sfence.vma

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
    800063be:	60e2                	ld	ra,24(sp)
    800063c0:	6442                	ld	s0,16(sp)
    800063c2:	64a2                	ld	s1,8(sp)
    800063c4:	6105                	add	sp,sp,32
    800063c6:	8082                	ret
        evict_page_to_disk(p);
    800063c8:	8526                	mv	a0,s1
    800063ca:	00000097          	auipc	ra,0x0
    800063ce:	f4c080e7          	jalr	-180(ra) # 80006316 <evict_page_to_disk>
    800063d2:	bfe9                	j	800063ac <page_fault_handler+0x38>

00000000800063d4 <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    800063d4:	1141                	add	sp,sp,-16
    800063d6:	e406                	sd	ra,8(sp)
    800063d8:	e022                	sd	s0,0(sp)
    800063da:	0800                	add	s0,sp,16
    800063dc:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    800063de:	00002517          	auipc	a0,0x2
    800063e2:	49a50513          	add	a0,a0,1178 # 80008878 <syscalls+0x400>
    800063e6:	ffffa097          	auipc	ra,0xffffa
    800063ea:	1a0080e7          	jalr	416(ra) # 80000586 <printf>
}
    800063ee:	60a2                	ld	ra,8(sp)
    800063f0:	6402                	ld	s0,0(sp)
    800063f2:	0141                	add	sp,sp,16
    800063f4:	8082                	ret

00000000800063f6 <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    800063f6:	1141                	add	sp,sp,-16
    800063f8:	e406                	sd	ra,8(sp)
    800063fa:	e022                	sd	s0,0(sp)
    800063fc:	0800                	add	s0,sp,16
    800063fe:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    80006400:	00002517          	auipc	a0,0x2
    80006404:	4a050513          	add	a0,a0,1184 # 800088a0 <syscalls+0x428>
    80006408:	ffffa097          	auipc	ra,0xffffa
    8000640c:	17e080e7          	jalr	382(ra) # 80000586 <printf>
}
    80006410:	60a2                	ld	ra,8(sp)
    80006412:	6402                	ld	s0,0(sp)
    80006414:	0141                	add	sp,sp,16
    80006416:	8082                	ret

0000000080006418 <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    80006418:	1141                	add	sp,sp,-16
    8000641a:	e406                	sd	ra,8(sp)
    8000641c:	e022                	sd	s0,0(sp)
    8000641e:	0800                	add	s0,sp,16
    80006420:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    80006422:	862e                	mv	a2,a1
    80006424:	85aa                	mv	a1,a0
    80006426:	00002517          	auipc	a0,0x2
    8000642a:	4a250513          	add	a0,a0,1186 # 800088c8 <syscalls+0x450>
    8000642e:	ffffa097          	auipc	ra,0xffffa
    80006432:	158080e7          	jalr	344(ra) # 80000586 <printf>
        name, vaddr, size);
}
    80006436:	60a2                	ld	ra,8(sp)
    80006438:	6402                	ld	s0,0(sp)
    8000643a:	0141                	add	sp,sp,16
    8000643c:	8082                	ret

000000008000643e <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    8000643e:	1101                	add	sp,sp,-32
    80006440:	ec06                	sd	ra,24(sp)
    80006442:	e822                	sd	s0,16(sp)
    80006444:	e426                	sd	s1,8(sp)
    80006446:	e04a                	sd	s2,0(sp)
    80006448:	1000                	add	s0,sp,32
    8000644a:	84aa                	mv	s1,a0
    8000644c:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    8000644e:	00002517          	auipc	a0,0x2
    80006452:	4c250513          	add	a0,a0,1218 # 80008910 <syscalls+0x498>
    80006456:	ffffa097          	auipc	ra,0xffffa
    8000645a:	130080e7          	jalr	304(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    8000645e:	864a                	mv	a2,s2
    80006460:	85a6                	mv	a1,s1
    80006462:	00002517          	auipc	a0,0x2
    80006466:	4de50513          	add	a0,a0,1246 # 80008940 <syscalls+0x4c8>
    8000646a:	ffffa097          	auipc	ra,0xffffa
    8000646e:	11c080e7          	jalr	284(ra) # 80000586 <printf>
}
    80006472:	60e2                	ld	ra,24(sp)
    80006474:	6442                	ld	s0,16(sp)
    80006476:	64a2                	ld	s1,8(sp)
    80006478:	6902                	ld	s2,0(sp)
    8000647a:	6105                	add	sp,sp,32
    8000647c:	8082                	ret

000000008000647e <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    8000647e:	1141                	add	sp,sp,-16
    80006480:	e406                	sd	ra,8(sp)
    80006482:	e022                	sd	s0,0(sp)
    80006484:	0800                	add	s0,sp,16
    80006486:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    80006488:	0035869b          	addw	a3,a1,3
    8000648c:	85aa                	mv	a1,a0
    8000648e:	00002517          	auipc	a0,0x2
    80006492:	4d250513          	add	a0,a0,1234 # 80008960 <syscalls+0x4e8>
    80006496:	ffffa097          	auipc	ra,0xffffa
    8000649a:	0f0080e7          	jalr	240(ra) # 80000586 <printf>
}
    8000649e:	60a2                	ld	ra,8(sp)
    800064a0:	6402                	ld	s0,0(sp)
    800064a2:	0141                	add	sp,sp,16
    800064a4:	8082                	ret

00000000800064a6 <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    800064a6:	1141                	add	sp,sp,-16
    800064a8:	e406                	sd	ra,8(sp)
    800064aa:	e022                	sd	s0,0(sp)
    800064ac:	0800                	add	s0,sp,16
    800064ae:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    800064b0:	0035869b          	addw	a3,a1,3
    800064b4:	85aa                	mv	a1,a0
    800064b6:	00002517          	auipc	a0,0x2
    800064ba:	4d250513          	add	a0,a0,1234 # 80008988 <syscalls+0x510>
    800064be:	ffffa097          	auipc	ra,0xffffa
    800064c2:	0c8080e7          	jalr	200(ra) # 80000586 <printf>
}
    800064c6:	60a2                	ld	ra,8(sp)
    800064c8:	6402                	ld	s0,0(sp)
    800064ca:	0141                	add	sp,sp,16
    800064cc:	8082                	ret

00000000800064ce <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    800064ce:	1141                	add	sp,sp,-16
    800064d0:	e406                	sd	ra,8(sp)
    800064d2:	e022                	sd	s0,0(sp)
    800064d4:	0800                	add	s0,sp,16
    800064d6:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    800064d8:	862e                	mv	a2,a1
    800064da:	85aa                	mv	a1,a0
    800064dc:	00002517          	auipc	a0,0x2
    800064e0:	4d450513          	add	a0,a0,1236 # 800089b0 <syscalls+0x538>
    800064e4:	ffffa097          	auipc	ra,0xffffa
    800064e8:	0a2080e7          	jalr	162(ra) # 80000586 <printf>
}
    800064ec:	60a2                	ld	ra,8(sp)
    800064ee:	6402                	ld	s0,0(sp)
    800064f0:	0141                	add	sp,sp,16
    800064f2:	8082                	ret

00000000800064f4 <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    800064f4:	1141                	add	sp,sp,-16
    800064f6:	e406                	sd	ra,8(sp)
    800064f8:	e022                	sd	s0,0(sp)
    800064fa:	0800                	add	s0,sp,16
    800064fc:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    800064fe:	862e                	mv	a2,a1
    80006500:	85aa                	mv	a1,a0
    80006502:	00002517          	auipc	a0,0x2
    80006506:	4d650513          	add	a0,a0,1238 # 800089d8 <syscalls+0x560>
    8000650a:	ffffa097          	auipc	ra,0xffffa
    8000650e:	07c080e7          	jalr	124(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    80006512:	60a2                	ld	ra,8(sp)
    80006514:	6402                	ld	s0,0(sp)
    80006516:	0141                	add	sp,sp,16
    80006518:	8082                	ret
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
