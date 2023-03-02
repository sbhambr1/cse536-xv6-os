
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
    80000066:	d1e78793          	add	a5,a5,-738 # 80005d80 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fe64537>
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
    8000012e:	4c0080e7          	jalr	1216(ra) # 800025ea <either_copyin>
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
    800001c0:	27c080e7          	jalr	636(ra) # 80002438 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	fae080e7          	jalr	-82(ra) # 80002178 <sleep>
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
    80000214:	384080e7          	jalr	900(ra) # 80002594 <either_copyout>
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
    800002f2:	352080e7          	jalr	850(ra) # 80002640 <procdump>
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
    80000446:	d9a080e7          	jalr	-614(ra) # 800021dc <wakeup>
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
    8000056e:	4ae50513          	add	a0,a0,1198 # 80008a18 <syscalls+0x590>
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
    80000894:	94c080e7          	jalr	-1716(ra) # 800021dc <wakeup>
    
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
    8000091a:	00002097          	auipc	ra,0x2
    8000091e:	85e080e7          	jalr	-1954(ra) # 80002178 <sleep>
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
    800009f8:	0019a797          	auipc	a5,0x19a
    800009fc:	8d078793          	add	a5,a5,-1840 # 8019a2c8 <end>
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
    80000ace:	7fe50513          	add	a0,a0,2046 # 8019a2c8 <end>
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
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fe64d39>
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
    80000ebc:	8d2080e7          	jalr	-1838(ra) # 8000278a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	f00080e7          	jalr	-256(ra) # 80005dc0 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	0f8080e7          	jalr	248(ra) # 80001fc0 <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b3850513          	add	a0,a0,-1224 # 80008a18 <syscalls+0x590>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	b1850513          	add	a0,a0,-1256 # 80008a18 <syscalls+0x590>
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
    80000f30:	00002097          	auipc	ra,0x2
    80000f34:	832080e7          	jalr	-1998(ra) # 80002762 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00002097          	auipc	ra,0x2
    80000f3c:	852080e7          	jalr	-1966(ra) # 8000278a <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	e6a080e7          	jalr	-406(ra) # 80005daa <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	e78080e7          	jalr	-392(ra) # 80005dc0 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	fc6080e7          	jalr	-58(ra) # 80002f16 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	664080e7          	jalr	1636(ra) # 800035bc <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	5da080e7          	jalr	1498(ra) # 8000453a <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	f60080e7          	jalr	-160(ra) # 80005ec8 <virtio_disk_init>
    init_psa_regions();
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	470080e7          	jalr	1136(ra) # 800063e0 <init_psa_regions>
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
    80001018:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7fe64d2f>
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
    80001830:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fe64d38>
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
    80001a40:	d66080e7          	jalr	-666(ra) # 800027a2 <usertrapret>
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
    80001a5a:	ae6080e7          	jalr	-1306(ra) # 8000353c <fsinit>
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
    80001d24:	23a080e7          	jalr	570(ra) # 80003f5a <namei>
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
    80001d8a:	7179                	add	sp,sp,-48
    80001d8c:	f406                	sd	ra,40(sp)
    80001d8e:	f022                	sd	s0,32(sp)
    80001d90:	ec26                	sd	s1,24(sp)
    80001d92:	e84a                	sd	s2,16(sp)
    80001d94:	e44e                	sd	s3,8(sp)
    80001d96:	1800                	add	s0,sp,48
    80001d98:	89aa                	mv	s3,a0
  struct proc *p = myproc();
    80001d9a:	00000097          	auipc	ra,0x0
    80001d9e:	c48080e7          	jalr	-952(ra) # 800019e2 <myproc>
    80001da2:	84aa                	mv	s1,a0
  if (strncmp(p->name, "/init", 5) == 0 || strncmp(p->name, "sh", 2) == 0) {
    80001da4:	15850913          	add	s2,a0,344
    80001da8:	4615                	li	a2,5
    80001daa:	00006597          	auipc	a1,0x6
    80001dae:	49658593          	add	a1,a1,1174 # 80008240 <digits+0x200>
    80001db2:	854a                	mv	a0,s2
    80001db4:	fffff097          	auipc	ra,0xfffff
    80001db8:	fea080e7          	jalr	-22(ra) # 80000d9e <strncmp>
    80001dbc:	e51d                	bnez	a0,80001dea <growproc+0x60>
    80001dbe:	16048423          	sb	zero,360(s1)
  n = PGROUNDUP(n);
    80001dc2:	6605                	lui	a2,0x1
    80001dc4:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001dc6:	0136063b          	addw	a2,a2,s3
    80001dca:	77fd                	lui	a5,0xfffff
    80001dcc:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001dce:	64ac                	ld	a1,72(s1)
  if(n > 0){
    80001dd0:	08c04163          	bgtz	a2,80001e52 <growproc+0xc8>
  } else if(n < 0){
    80001dd4:	08064a63          	bltz	a2,80001e68 <growproc+0xde>
  p->sz = sz;
    80001dd8:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dda:	4501                	li	a0,0
}
    80001ddc:	70a2                	ld	ra,40(sp)
    80001dde:	7402                	ld	s0,32(sp)
    80001de0:	64e2                	ld	s1,24(sp)
    80001de2:	6942                	ld	s2,16(sp)
    80001de4:	69a2                	ld	s3,8(sp)
    80001de6:	6145                	add	sp,sp,48
    80001de8:	8082                	ret
  if (strncmp(p->name, "/init", 5) == 0 || strncmp(p->name, "sh", 2) == 0) {
    80001dea:	4609                	li	a2,2
    80001dec:	00006597          	auipc	a1,0x6
    80001df0:	45c58593          	add	a1,a1,1116 # 80008248 <digits+0x208>
    80001df4:	854a                	mv	a0,s2
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	fa8080e7          	jalr	-88(ra) # 80000d9e <strncmp>
    80001dfe:	00a037b3          	snez	a5,a0
    80001e02:	16f48423          	sb	a5,360(s1)
  n = PGROUNDUP(n);
    80001e06:	6605                	lui	a2,0x1
    80001e08:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001e0a:	0136063b          	addw	a2,a2,s3
    80001e0e:	77fd                	lui	a5,0xfffff
    80001e10:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001e12:	64ac                	ld	a1,72(s1)
  if (p->ondemand) {
    80001e14:	dd55                	beqz	a0,80001dd0 <growproc+0x46>
    sz = PGROUNDUP(sz);
    80001e16:	6785                	lui	a5,0x1
    80001e18:	17fd                	add	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001e1a:	95be                	add	a1,a1,a5
    80001e1c:	77fd                	lui	a5,0xfffff
    80001e1e:	8dfd                	and	a1,a1,a5
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e20:	00b607b3          	add	a5,a2,a1
    80001e24:	02f5f563          	bgeu	a1,a5,80001e4e <growproc+0xc4>
    80001e28:	17048513          	add	a0,s1,368
    80001e2c:	872e                	mv	a4,a1
    80001e2e:	4601                	li	a2,0
    80001e30:	6685                	lui	a3,0x1
      p->heap_tracker[i].addr = addr;
    80001e32:	e118                	sd	a4,0(a0)
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e34:	0605                	add	a2,a2,1
    80001e36:	9736                	add	a4,a4,a3
    80001e38:	0561                	add	a0,a0,24
    80001e3a:	fef76ce3          	bltu	a4,a5,80001e32 <growproc+0xa8>
  print_skip_heap_region(p->name, sz, i);
    80001e3e:	2601                	sext.w	a2,a2
    80001e40:	854a                	mv	a0,s2
    80001e42:	00005097          	auipc	ra,0x5
    80001e46:	ba8080e7          	jalr	-1112(ra) # 800069ea <print_skip_heap_region>
  return 0;
    80001e4a:	4501                	li	a0,0
    80001e4c:	bf41                	j	80001ddc <growproc+0x52>
    for(i = 0, addr = sz; addr < sz + n; i++, addr += PGSIZE) {
    80001e4e:	4601                	li	a2,0
    80001e50:	b7fd                	j	80001e3e <growproc+0xb4>
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e52:	4691                	li	a3,4
    80001e54:	962e                	add	a2,a2,a1
    80001e56:	68a8                	ld	a0,80(s1)
    80001e58:	fffff097          	auipc	ra,0xfffff
    80001e5c:	5ac080e7          	jalr	1452(ra) # 80001404 <uvmalloc>
    80001e60:	85aa                	mv	a1,a0
    80001e62:	f93d                	bnez	a0,80001dd8 <growproc+0x4e>
      return -1;
    80001e64:	557d                	li	a0,-1
    80001e66:	bf9d                	j	80001ddc <growproc+0x52>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e68:	962e                	add	a2,a2,a1
    80001e6a:	68a8                	ld	a0,80(s1)
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	550080e7          	jalr	1360(ra) # 800013bc <uvmdealloc>
    80001e74:	85aa                	mv	a1,a0
    80001e76:	b78d                	j	80001dd8 <growproc+0x4e>

0000000080001e78 <fork>:
{
    80001e78:	7139                	add	sp,sp,-64
    80001e7a:	fc06                	sd	ra,56(sp)
    80001e7c:	f822                	sd	s0,48(sp)
    80001e7e:	f426                	sd	s1,40(sp)
    80001e80:	f04a                	sd	s2,32(sp)
    80001e82:	ec4e                	sd	s3,24(sp)
    80001e84:	e852                	sd	s4,16(sp)
    80001e86:	e456                	sd	s5,8(sp)
    80001e88:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e8a:	00000097          	auipc	ra,0x0
    80001e8e:	b58080e7          	jalr	-1192(ra) # 800019e2 <myproc>
    80001e92:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e94:	00000097          	auipc	ra,0x0
    80001e98:	d58080e7          	jalr	-680(ra) # 80001bec <allocproc>
    80001e9c:	12050063          	beqz	a0,80001fbc <fork+0x144>
    80001ea0:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001ea2:	048ab603          	ld	a2,72(s5)
    80001ea6:	692c                	ld	a1,80(a0)
    80001ea8:	050ab503          	ld	a0,80(s5)
    80001eac:	fffff097          	auipc	ra,0xfffff
    80001eb0:	6b0080e7          	jalr	1712(ra) # 8000155c <uvmcopy>
    80001eb4:	04054863          	bltz	a0,80001f04 <fork+0x8c>
  np->sz = p->sz;
    80001eb8:	048ab783          	ld	a5,72(s5)
    80001ebc:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001ec0:	058ab683          	ld	a3,88(s5)
    80001ec4:	87b6                	mv	a5,a3
    80001ec6:	0589b703          	ld	a4,88(s3)
    80001eca:	12068693          	add	a3,a3,288 # 1120 <_entry-0x7fffeee0>
    80001ece:	0007b803          	ld	a6,0(a5) # fffffffffffff000 <end+0xffffffff7fe64d38>
    80001ed2:	6788                	ld	a0,8(a5)
    80001ed4:	6b8c                	ld	a1,16(a5)
    80001ed6:	6f90                	ld	a2,24(a5)
    80001ed8:	01073023          	sd	a6,0(a4)
    80001edc:	e708                	sd	a0,8(a4)
    80001ede:	eb0c                	sd	a1,16(a4)
    80001ee0:	ef10                	sd	a2,24(a4)
    80001ee2:	02078793          	add	a5,a5,32
    80001ee6:	02070713          	add	a4,a4,32
    80001eea:	fed792e3          	bne	a5,a3,80001ece <fork+0x56>
  np->trapframe->a0 = 0;
    80001eee:	0589b783          	ld	a5,88(s3)
    80001ef2:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ef6:	0d0a8493          	add	s1,s5,208
    80001efa:	0d098913          	add	s2,s3,208
    80001efe:	150a8a13          	add	s4,s5,336
    80001f02:	a00d                	j	80001f24 <fork+0xac>
    freeproc(np);
    80001f04:	854e                	mv	a0,s3
    80001f06:	00000097          	auipc	ra,0x0
    80001f0a:	c8e080e7          	jalr	-882(ra) # 80001b94 <freeproc>
    release(&np->lock);
    80001f0e:	854e                	mv	a0,s3
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d76080e7          	jalr	-650(ra) # 80000c86 <release>
    return -1;
    80001f18:	597d                	li	s2,-1
    80001f1a:	a079                	j	80001fa8 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001f1c:	04a1                	add	s1,s1,8
    80001f1e:	0921                	add	s2,s2,8
    80001f20:	01448b63          	beq	s1,s4,80001f36 <fork+0xbe>
    if(p->ofile[i])
    80001f24:	6088                	ld	a0,0(s1)
    80001f26:	d97d                	beqz	a0,80001f1c <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f28:	00002097          	auipc	ra,0x2
    80001f2c:	6a4080e7          	jalr	1700(ra) # 800045cc <filedup>
    80001f30:	00a93023          	sd	a0,0(s2)
    80001f34:	b7e5                	j	80001f1c <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001f36:	150ab503          	ld	a0,336(s5)
    80001f3a:	00002097          	auipc	ra,0x2
    80001f3e:	83c080e7          	jalr	-1988(ra) # 80003776 <idup>
    80001f42:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f46:	4641                	li	a2,16
    80001f48:	158a8593          	add	a1,s5,344
    80001f4c:	15898513          	add	a0,s3,344
    80001f50:	fffff097          	auipc	ra,0xfffff
    80001f54:	ec6080e7          	jalr	-314(ra) # 80000e16 <safestrcpy>
  np->ondemand = p->ondemand;
    80001f58:	168ac783          	lbu	a5,360(s5)
    80001f5c:	16f98423          	sb	a5,360(s3)
  pid = np->pid;
    80001f60:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001f64:	854e                	mv	a0,s3
    80001f66:	fffff097          	auipc	ra,0xfffff
    80001f6a:	d20080e7          	jalr	-736(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001f6e:	0000f497          	auipc	s1,0xf
    80001f72:	dba48493          	add	s1,s1,-582 # 80010d28 <wait_lock>
    80001f76:	8526                	mv	a0,s1
    80001f78:	fffff097          	auipc	ra,0xfffff
    80001f7c:	c5a080e7          	jalr	-934(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f80:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f84:	8526                	mv	a0,s1
    80001f86:	fffff097          	auipc	ra,0xfffff
    80001f8a:	d00080e7          	jalr	-768(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f8e:	854e                	mv	a0,s3
    80001f90:	fffff097          	auipc	ra,0xfffff
    80001f94:	c42080e7          	jalr	-958(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001f98:	478d                	li	a5,3
    80001f9a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f9e:	854e                	mv	a0,s3
    80001fa0:	fffff097          	auipc	ra,0xfffff
    80001fa4:	ce6080e7          	jalr	-794(ra) # 80000c86 <release>
}
    80001fa8:	854a                	mv	a0,s2
    80001faa:	70e2                	ld	ra,56(sp)
    80001fac:	7442                	ld	s0,48(sp)
    80001fae:	74a2                	ld	s1,40(sp)
    80001fb0:	7902                	ld	s2,32(sp)
    80001fb2:	69e2                	ld	s3,24(sp)
    80001fb4:	6a42                	ld	s4,16(sp)
    80001fb6:	6aa2                	ld	s5,8(sp)
    80001fb8:	6121                	add	sp,sp,64
    80001fba:	8082                	ret
    return -1;
    80001fbc:	597d                	li	s2,-1
    80001fbe:	b7ed                	j	80001fa8 <fork+0x130>

0000000080001fc0 <scheduler>:
{
    80001fc0:	715d                	add	sp,sp,-80
    80001fc2:	e486                	sd	ra,72(sp)
    80001fc4:	e0a2                	sd	s0,64(sp)
    80001fc6:	fc26                	sd	s1,56(sp)
    80001fc8:	f84a                	sd	s2,48(sp)
    80001fca:	f44e                	sd	s3,40(sp)
    80001fcc:	f052                	sd	s4,32(sp)
    80001fce:	ec56                	sd	s5,24(sp)
    80001fd0:	e85a                	sd	s6,16(sp)
    80001fd2:	e45e                	sd	s7,8(sp)
    80001fd4:	0880                	add	s0,sp,80
    80001fd6:	8792                	mv	a5,tp
  int id = r_tp();
    80001fd8:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001fda:	00779b13          	sll	s6,a5,0x7
    80001fde:	0000f717          	auipc	a4,0xf
    80001fe2:	d3270713          	add	a4,a4,-718 # 80010d10 <pid_lock>
    80001fe6:	975a                	add	a4,a4,s6
    80001fe8:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001fec:	0000f717          	auipc	a4,0xf
    80001ff0:	d5c70713          	add	a4,a4,-676 # 80010d48 <cpus+0x8>
    80001ff4:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001ff6:	4b91                	li	s7,4
        c->proc = p;
    80001ff8:	079e                	sll	a5,a5,0x7
    80001ffa:	0000fa97          	auipc	s5,0xf
    80001ffe:	d16a8a93          	add	s5,s5,-746 # 80010d10 <pid_lock>
    80002002:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002004:	6999                	lui	s3,0x6
    80002006:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000200a:	0018ca17          	auipc	s4,0x18c
    8000200e:	f36a0a13          	add	s4,s4,-202 # 8018df40 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002012:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002016:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000201a:	10079073          	csrw	sstatus,a5
    8000201e:	0000f497          	auipc	s1,0xf
    80002022:	12248493          	add	s1,s1,290 # 80011140 <proc>
      if(p->state == RUNNABLE) {
    80002026:	490d                	li	s2,3
    80002028:	a809                	j	8000203a <scheduler+0x7a>
      release(&p->lock);
    8000202a:	8526                	mv	a0,s1
    8000202c:	fffff097          	auipc	ra,0xfffff
    80002030:	c5a080e7          	jalr	-934(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80002034:	94ce                	add	s1,s1,s3
    80002036:	fd448ee3          	beq	s1,s4,80002012 <scheduler+0x52>
      acquire(&p->lock);
    8000203a:	8526                	mv	a0,s1
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	b96080e7          	jalr	-1130(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80002044:	4c9c                	lw	a5,24(s1)
    80002046:	ff2792e3          	bne	a5,s2,8000202a <scheduler+0x6a>
        p->state = RUNNING;
    8000204a:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000204e:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80002052:	06048593          	add	a1,s1,96
    80002056:	855a                	mv	a0,s6
    80002058:	00000097          	auipc	ra,0x0
    8000205c:	6a0080e7          	jalr	1696(ra) # 800026f8 <swtch>
        c->proc = 0;
    80002060:	020ab823          	sd	zero,48(s5)
    80002064:	b7d9                	j	8000202a <scheduler+0x6a>

0000000080002066 <sched>:
{
    80002066:	7179                	add	sp,sp,-48
    80002068:	f406                	sd	ra,40(sp)
    8000206a:	f022                	sd	s0,32(sp)
    8000206c:	ec26                	sd	s1,24(sp)
    8000206e:	e84a                	sd	s2,16(sp)
    80002070:	e44e                	sd	s3,8(sp)
    80002072:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80002074:	00000097          	auipc	ra,0x0
    80002078:	96e080e7          	jalr	-1682(ra) # 800019e2 <myproc>
    8000207c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    8000207e:	fffff097          	auipc	ra,0xfffff
    80002082:	ada080e7          	jalr	-1318(ra) # 80000b58 <holding>
    80002086:	c93d                	beqz	a0,800020fc <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002088:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000208a:	2781                	sext.w	a5,a5
    8000208c:	079e                	sll	a5,a5,0x7
    8000208e:	0000f717          	auipc	a4,0xf
    80002092:	c8270713          	add	a4,a4,-894 # 80010d10 <pid_lock>
    80002096:	97ba                	add	a5,a5,a4
    80002098:	0a87a703          	lw	a4,168(a5)
    8000209c:	4785                	li	a5,1
    8000209e:	06f71763          	bne	a4,a5,8000210c <sched+0xa6>
  if(p->state == RUNNING)
    800020a2:	4c98                	lw	a4,24(s1)
    800020a4:	4791                	li	a5,4
    800020a6:	06f70b63          	beq	a4,a5,8000211c <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020aa:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020ae:	8b89                	and	a5,a5,2
  if(intr_get())
    800020b0:	efb5                	bnez	a5,8000212c <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b2:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020b4:	0000f917          	auipc	s2,0xf
    800020b8:	c5c90913          	add	s2,s2,-932 # 80010d10 <pid_lock>
    800020bc:	2781                	sext.w	a5,a5
    800020be:	079e                	sll	a5,a5,0x7
    800020c0:	97ca                	add	a5,a5,s2
    800020c2:	0ac7a983          	lw	s3,172(a5)
    800020c6:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020c8:	2781                	sext.w	a5,a5
    800020ca:	079e                	sll	a5,a5,0x7
    800020cc:	0000f597          	auipc	a1,0xf
    800020d0:	c7c58593          	add	a1,a1,-900 # 80010d48 <cpus+0x8>
    800020d4:	95be                	add	a1,a1,a5
    800020d6:	06048513          	add	a0,s1,96
    800020da:	00000097          	auipc	ra,0x0
    800020de:	61e080e7          	jalr	1566(ra) # 800026f8 <swtch>
    800020e2:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    800020e4:	2781                	sext.w	a5,a5
    800020e6:	079e                	sll	a5,a5,0x7
    800020e8:	993e                	add	s2,s2,a5
    800020ea:	0b392623          	sw	s3,172(s2)
}
    800020ee:	70a2                	ld	ra,40(sp)
    800020f0:	7402                	ld	s0,32(sp)
    800020f2:	64e2                	ld	s1,24(sp)
    800020f4:	6942                	ld	s2,16(sp)
    800020f6:	69a2                	ld	s3,8(sp)
    800020f8:	6145                	add	sp,sp,48
    800020fa:	8082                	ret
    panic("sched p->lock");
    800020fc:	00006517          	auipc	a0,0x6
    80002100:	15450513          	add	a0,a0,340 # 80008250 <digits+0x210>
    80002104:	ffffe097          	auipc	ra,0xffffe
    80002108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
    panic("sched locks");
    8000210c:	00006517          	auipc	a0,0x6
    80002110:	15450513          	add	a0,a0,340 # 80008260 <digits+0x220>
    80002114:	ffffe097          	auipc	ra,0xffffe
    80002118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
    panic("sched running");
    8000211c:	00006517          	auipc	a0,0x6
    80002120:	15450513          	add	a0,a0,340 # 80008270 <digits+0x230>
    80002124:	ffffe097          	auipc	ra,0xffffe
    80002128:	418080e7          	jalr	1048(ra) # 8000053c <panic>
    panic("sched interruptible");
    8000212c:	00006517          	auipc	a0,0x6
    80002130:	15450513          	add	a0,a0,340 # 80008280 <digits+0x240>
    80002134:	ffffe097          	auipc	ra,0xffffe
    80002138:	408080e7          	jalr	1032(ra) # 8000053c <panic>

000000008000213c <yield>:
{
    8000213c:	1101                	add	sp,sp,-32
    8000213e:	ec06                	sd	ra,24(sp)
    80002140:	e822                	sd	s0,16(sp)
    80002142:	e426                	sd	s1,8(sp)
    80002144:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    80002146:	00000097          	auipc	ra,0x0
    8000214a:	89c080e7          	jalr	-1892(ra) # 800019e2 <myproc>
    8000214e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	a82080e7          	jalr	-1406(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    80002158:	478d                	li	a5,3
    8000215a:	cc9c                	sw	a5,24(s1)
  sched();
    8000215c:	00000097          	auipc	ra,0x0
    80002160:	f0a080e7          	jalr	-246(ra) # 80002066 <sched>
  release(&p->lock);
    80002164:	8526                	mv	a0,s1
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	b20080e7          	jalr	-1248(ra) # 80000c86 <release>
}
    8000216e:	60e2                	ld	ra,24(sp)
    80002170:	6442                	ld	s0,16(sp)
    80002172:	64a2                	ld	s1,8(sp)
    80002174:	6105                	add	sp,sp,32
    80002176:	8082                	ret

0000000080002178 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002178:	7179                	add	sp,sp,-48
    8000217a:	f406                	sd	ra,40(sp)
    8000217c:	f022                	sd	s0,32(sp)
    8000217e:	ec26                	sd	s1,24(sp)
    80002180:	e84a                	sd	s2,16(sp)
    80002182:	e44e                	sd	s3,8(sp)
    80002184:	1800                	add	s0,sp,48
    80002186:	89aa                	mv	s3,a0
    80002188:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000218a:	00000097          	auipc	ra,0x0
    8000218e:	858080e7          	jalr	-1960(ra) # 800019e2 <myproc>
    80002192:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80002194:	fffff097          	auipc	ra,0xfffff
    80002198:	a3e080e7          	jalr	-1474(ra) # 80000bd2 <acquire>
  release(lk);
    8000219c:	854a                	mv	a0,s2
    8000219e:	fffff097          	auipc	ra,0xfffff
    800021a2:	ae8080e7          	jalr	-1304(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    800021a6:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021aa:	4789                	li	a5,2
    800021ac:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    800021ae:	00000097          	auipc	ra,0x0
    800021b2:	eb8080e7          	jalr	-328(ra) # 80002066 <sched>

  // Tidy up.
  p->chan = 0;
    800021b6:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021ba:	8526                	mv	a0,s1
    800021bc:	fffff097          	auipc	ra,0xfffff
    800021c0:	aca080e7          	jalr	-1334(ra) # 80000c86 <release>
  acquire(lk);
    800021c4:	854a                	mv	a0,s2
    800021c6:	fffff097          	auipc	ra,0xfffff
    800021ca:	a0c080e7          	jalr	-1524(ra) # 80000bd2 <acquire>
}
    800021ce:	70a2                	ld	ra,40(sp)
    800021d0:	7402                	ld	s0,32(sp)
    800021d2:	64e2                	ld	s1,24(sp)
    800021d4:	6942                	ld	s2,16(sp)
    800021d6:	69a2                	ld	s3,8(sp)
    800021d8:	6145                	add	sp,sp,48
    800021da:	8082                	ret

00000000800021dc <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800021dc:	7139                	add	sp,sp,-64
    800021de:	fc06                	sd	ra,56(sp)
    800021e0:	f822                	sd	s0,48(sp)
    800021e2:	f426                	sd	s1,40(sp)
    800021e4:	f04a                	sd	s2,32(sp)
    800021e6:	ec4e                	sd	s3,24(sp)
    800021e8:	e852                	sd	s4,16(sp)
    800021ea:	e456                	sd	s5,8(sp)
    800021ec:	e05a                	sd	s6,0(sp)
    800021ee:	0080                	add	s0,sp,64
    800021f0:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800021f2:	0000f497          	auipc	s1,0xf
    800021f6:	f4e48493          	add	s1,s1,-178 # 80011140 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800021fa:	4a09                	li	s4,2
        p->state = RUNNABLE;
    800021fc:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800021fe:	6919                	lui	s2,0x6
    80002200:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002204:	0018c997          	auipc	s3,0x18c
    80002208:	d3c98993          	add	s3,s3,-708 # 8018df40 <tickslock>
    8000220c:	a809                	j	8000221e <wakeup+0x42>
      }
      release(&p->lock);
    8000220e:	8526                	mv	a0,s1
    80002210:	fffff097          	auipc	ra,0xfffff
    80002214:	a76080e7          	jalr	-1418(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80002218:	94ca                	add	s1,s1,s2
    8000221a:	03348663          	beq	s1,s3,80002246 <wakeup+0x6a>
    if(p != myproc()){
    8000221e:	fffff097          	auipc	ra,0xfffff
    80002222:	7c4080e7          	jalr	1988(ra) # 800019e2 <myproc>
    80002226:	fea489e3          	beq	s1,a0,80002218 <wakeup+0x3c>
      acquire(&p->lock);
    8000222a:	8526                	mv	a0,s1
    8000222c:	fffff097          	auipc	ra,0xfffff
    80002230:	9a6080e7          	jalr	-1626(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002234:	4c9c                	lw	a5,24(s1)
    80002236:	fd479ce3          	bne	a5,s4,8000220e <wakeup+0x32>
    8000223a:	709c                	ld	a5,32(s1)
    8000223c:	fd5799e3          	bne	a5,s5,8000220e <wakeup+0x32>
        p->state = RUNNABLE;
    80002240:	0164ac23          	sw	s6,24(s1)
    80002244:	b7e9                	j	8000220e <wakeup+0x32>
    }
  }
}
    80002246:	70e2                	ld	ra,56(sp)
    80002248:	7442                	ld	s0,48(sp)
    8000224a:	74a2                	ld	s1,40(sp)
    8000224c:	7902                	ld	s2,32(sp)
    8000224e:	69e2                	ld	s3,24(sp)
    80002250:	6a42                	ld	s4,16(sp)
    80002252:	6aa2                	ld	s5,8(sp)
    80002254:	6b02                	ld	s6,0(sp)
    80002256:	6121                	add	sp,sp,64
    80002258:	8082                	ret

000000008000225a <reparent>:
{
    8000225a:	7139                	add	sp,sp,-64
    8000225c:	fc06                	sd	ra,56(sp)
    8000225e:	f822                	sd	s0,48(sp)
    80002260:	f426                	sd	s1,40(sp)
    80002262:	f04a                	sd	s2,32(sp)
    80002264:	ec4e                	sd	s3,24(sp)
    80002266:	e852                	sd	s4,16(sp)
    80002268:	e456                	sd	s5,8(sp)
    8000226a:	0080                	add	s0,sp,64
    8000226c:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226e:	0000f497          	auipc	s1,0xf
    80002272:	ed248493          	add	s1,s1,-302 # 80011140 <proc>
      pp->parent = initproc;
    80002276:	00007a97          	auipc	s5,0x7
    8000227a:	822a8a93          	add	s5,s5,-2014 # 80008a98 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000227e:	6919                	lui	s2,0x6
    80002280:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80002284:	0018ca17          	auipc	s4,0x18c
    80002288:	cbca0a13          	add	s4,s4,-836 # 8018df40 <tickslock>
    8000228c:	a021                	j	80002294 <reparent+0x3a>
    8000228e:	94ca                	add	s1,s1,s2
    80002290:	01448d63          	beq	s1,s4,800022aa <reparent+0x50>
    if(pp->parent == p){
    80002294:	7c9c                	ld	a5,56(s1)
    80002296:	ff379ce3          	bne	a5,s3,8000228e <reparent+0x34>
      pp->parent = initproc;
    8000229a:	000ab503          	ld	a0,0(s5)
    8000229e:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022a0:	00000097          	auipc	ra,0x0
    800022a4:	f3c080e7          	jalr	-196(ra) # 800021dc <wakeup>
    800022a8:	b7dd                	j	8000228e <reparent+0x34>
}
    800022aa:	70e2                	ld	ra,56(sp)
    800022ac:	7442                	ld	s0,48(sp)
    800022ae:	74a2                	ld	s1,40(sp)
    800022b0:	7902                	ld	s2,32(sp)
    800022b2:	69e2                	ld	s3,24(sp)
    800022b4:	6a42                	ld	s4,16(sp)
    800022b6:	6aa2                	ld	s5,8(sp)
    800022b8:	6121                	add	sp,sp,64
    800022ba:	8082                	ret

00000000800022bc <exit>:
{
    800022bc:	7179                	add	sp,sp,-48
    800022be:	f406                	sd	ra,40(sp)
    800022c0:	f022                	sd	s0,32(sp)
    800022c2:	ec26                	sd	s1,24(sp)
    800022c4:	e84a                	sd	s2,16(sp)
    800022c6:	e44e                	sd	s3,8(sp)
    800022c8:	e052                	sd	s4,0(sp)
    800022ca:	1800                	add	s0,sp,48
    800022cc:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022ce:	fffff097          	auipc	ra,0xfffff
    800022d2:	714080e7          	jalr	1812(ra) # 800019e2 <myproc>
    800022d6:	89aa                	mv	s3,a0
  if(p == initproc)
    800022d8:	00006797          	auipc	a5,0x6
    800022dc:	7c07b783          	ld	a5,1984(a5) # 80008a98 <initproc>
    800022e0:	0d050493          	add	s1,a0,208
    800022e4:	15050913          	add	s2,a0,336
    800022e8:	02a79363          	bne	a5,a0,8000230e <exit+0x52>
    panic("init exiting");
    800022ec:	00006517          	auipc	a0,0x6
    800022f0:	fac50513          	add	a0,a0,-84 # 80008298 <digits+0x258>
    800022f4:	ffffe097          	auipc	ra,0xffffe
    800022f8:	248080e7          	jalr	584(ra) # 8000053c <panic>
      fileclose(f);
    800022fc:	00002097          	auipc	ra,0x2
    80002300:	322080e7          	jalr	802(ra) # 8000461e <fileclose>
      p->ofile[fd] = 0;
    80002304:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002308:	04a1                	add	s1,s1,8
    8000230a:	01248563          	beq	s1,s2,80002314 <exit+0x58>
    if(p->ofile[fd]){
    8000230e:	6088                	ld	a0,0(s1)
    80002310:	f575                	bnez	a0,800022fc <exit+0x40>
    80002312:	bfdd                	j	80002308 <exit+0x4c>
  begin_op();
    80002314:	00002097          	auipc	ra,0x2
    80002318:	e46080e7          	jalr	-442(ra) # 8000415a <begin_op>
  iput(p->cwd);
    8000231c:	1509b503          	ld	a0,336(s3)
    80002320:	00001097          	auipc	ra,0x1
    80002324:	64e080e7          	jalr	1614(ra) # 8000396e <iput>
  end_op();
    80002328:	00002097          	auipc	ra,0x2
    8000232c:	eac080e7          	jalr	-340(ra) # 800041d4 <end_op>
  p->cwd = 0;
    80002330:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002334:	0000f497          	auipc	s1,0xf
    80002338:	9f448493          	add	s1,s1,-1548 # 80010d28 <wait_lock>
    8000233c:	8526                	mv	a0,s1
    8000233e:	fffff097          	auipc	ra,0xfffff
    80002342:	894080e7          	jalr	-1900(ra) # 80000bd2 <acquire>
  reparent(p);
    80002346:	854e                	mv	a0,s3
    80002348:	00000097          	auipc	ra,0x0
    8000234c:	f12080e7          	jalr	-238(ra) # 8000225a <reparent>
  wakeup(p->parent);
    80002350:	0389b503          	ld	a0,56(s3)
    80002354:	00000097          	auipc	ra,0x0
    80002358:	e88080e7          	jalr	-376(ra) # 800021dc <wakeup>
  acquire(&p->lock);
    8000235c:	854e                	mv	a0,s3
    8000235e:	fffff097          	auipc	ra,0xfffff
    80002362:	874080e7          	jalr	-1932(ra) # 80000bd2 <acquire>
  p->xstate = status;
    80002366:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    8000236a:	4795                	li	a5,5
    8000236c:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002370:	8526                	mv	a0,s1
    80002372:	fffff097          	auipc	ra,0xfffff
    80002376:	914080e7          	jalr	-1772(ra) # 80000c86 <release>
  sched();
    8000237a:	00000097          	auipc	ra,0x0
    8000237e:	cec080e7          	jalr	-788(ra) # 80002066 <sched>
  panic("zombie exit");
    80002382:	00006517          	auipc	a0,0x6
    80002386:	f2650513          	add	a0,a0,-218 # 800082a8 <digits+0x268>
    8000238a:	ffffe097          	auipc	ra,0xffffe
    8000238e:	1b2080e7          	jalr	434(ra) # 8000053c <panic>

0000000080002392 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002392:	7179                	add	sp,sp,-48
    80002394:	f406                	sd	ra,40(sp)
    80002396:	f022                	sd	s0,32(sp)
    80002398:	ec26                	sd	s1,24(sp)
    8000239a:	e84a                	sd	s2,16(sp)
    8000239c:	e44e                	sd	s3,8(sp)
    8000239e:	e052                	sd	s4,0(sp)
    800023a0:	1800                	add	s0,sp,48
    800023a2:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023a4:	0000f497          	auipc	s1,0xf
    800023a8:	d9c48493          	add	s1,s1,-612 # 80011140 <proc>
    800023ac:	6999                	lui	s3,0x6
    800023ae:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    800023b2:	0018ca17          	auipc	s4,0x18c
    800023b6:	b8ea0a13          	add	s4,s4,-1138 # 8018df40 <tickslock>
    acquire(&p->lock);
    800023ba:	8526                	mv	a0,s1
    800023bc:	fffff097          	auipc	ra,0xfffff
    800023c0:	816080e7          	jalr	-2026(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    800023c4:	589c                	lw	a5,48(s1)
    800023c6:	01278c63          	beq	a5,s2,800023de <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023ca:	8526                	mv	a0,s1
    800023cc:	fffff097          	auipc	ra,0xfffff
    800023d0:	8ba080e7          	jalr	-1862(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023d4:	94ce                	add	s1,s1,s3
    800023d6:	ff4492e3          	bne	s1,s4,800023ba <kill+0x28>
  }
  return -1;
    800023da:	557d                	li	a0,-1
    800023dc:	a829                	j	800023f6 <kill+0x64>
      p->killed = 1;
    800023de:	4785                	li	a5,1
    800023e0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023e2:	4c98                	lw	a4,24(s1)
    800023e4:	4789                	li	a5,2
    800023e6:	02f70063          	beq	a4,a5,80002406 <kill+0x74>
      release(&p->lock);
    800023ea:	8526                	mv	a0,s1
    800023ec:	fffff097          	auipc	ra,0xfffff
    800023f0:	89a080e7          	jalr	-1894(ra) # 80000c86 <release>
      return 0;
    800023f4:	4501                	li	a0,0
}
    800023f6:	70a2                	ld	ra,40(sp)
    800023f8:	7402                	ld	s0,32(sp)
    800023fa:	64e2                	ld	s1,24(sp)
    800023fc:	6942                	ld	s2,16(sp)
    800023fe:	69a2                	ld	s3,8(sp)
    80002400:	6a02                	ld	s4,0(sp)
    80002402:	6145                	add	sp,sp,48
    80002404:	8082                	ret
        p->state = RUNNABLE;
    80002406:	478d                	li	a5,3
    80002408:	cc9c                	sw	a5,24(s1)
    8000240a:	b7c5                	j	800023ea <kill+0x58>

000000008000240c <setkilled>:

void
setkilled(struct proc *p)
{
    8000240c:	1101                	add	sp,sp,-32
    8000240e:	ec06                	sd	ra,24(sp)
    80002410:	e822                	sd	s0,16(sp)
    80002412:	e426                	sd	s1,8(sp)
    80002414:	1000                	add	s0,sp,32
    80002416:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002418:	ffffe097          	auipc	ra,0xffffe
    8000241c:	7ba080e7          	jalr	1978(ra) # 80000bd2 <acquire>
  p->killed = 1;
    80002420:	4785                	li	a5,1
    80002422:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002424:	8526                	mv	a0,s1
    80002426:	fffff097          	auipc	ra,0xfffff
    8000242a:	860080e7          	jalr	-1952(ra) # 80000c86 <release>
}
    8000242e:	60e2                	ld	ra,24(sp)
    80002430:	6442                	ld	s0,16(sp)
    80002432:	64a2                	ld	s1,8(sp)
    80002434:	6105                	add	sp,sp,32
    80002436:	8082                	ret

0000000080002438 <killed>:

int
killed(struct proc *p)
{
    80002438:	1101                	add	sp,sp,-32
    8000243a:	ec06                	sd	ra,24(sp)
    8000243c:	e822                	sd	s0,16(sp)
    8000243e:	e426                	sd	s1,8(sp)
    80002440:	e04a                	sd	s2,0(sp)
    80002442:	1000                	add	s0,sp,32
    80002444:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002446:	ffffe097          	auipc	ra,0xffffe
    8000244a:	78c080e7          	jalr	1932(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000244e:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002452:	8526                	mv	a0,s1
    80002454:	fffff097          	auipc	ra,0xfffff
    80002458:	832080e7          	jalr	-1998(ra) # 80000c86 <release>
  return k;
}
    8000245c:	854a                	mv	a0,s2
    8000245e:	60e2                	ld	ra,24(sp)
    80002460:	6442                	ld	s0,16(sp)
    80002462:	64a2                	ld	s1,8(sp)
    80002464:	6902                	ld	s2,0(sp)
    80002466:	6105                	add	sp,sp,32
    80002468:	8082                	ret

000000008000246a <wait>:
{
    8000246a:	715d                	add	sp,sp,-80
    8000246c:	e486                	sd	ra,72(sp)
    8000246e:	e0a2                	sd	s0,64(sp)
    80002470:	fc26                	sd	s1,56(sp)
    80002472:	f84a                	sd	s2,48(sp)
    80002474:	f44e                	sd	s3,40(sp)
    80002476:	f052                	sd	s4,32(sp)
    80002478:	ec56                	sd	s5,24(sp)
    8000247a:	e85a                	sd	s6,16(sp)
    8000247c:	e45e                	sd	s7,8(sp)
    8000247e:	0880                	add	s0,sp,80
    80002480:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    80002482:	fffff097          	auipc	ra,0xfffff
    80002486:	560080e7          	jalr	1376(ra) # 800019e2 <myproc>
    8000248a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000248c:	0000f517          	auipc	a0,0xf
    80002490:	89c50513          	add	a0,a0,-1892 # 80010d28 <wait_lock>
    80002494:	ffffe097          	auipc	ra,0xffffe
    80002498:	73e080e7          	jalr	1854(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    8000249c:	4a95                	li	s5,5
        havekids = 1;
    8000249e:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024a0:	6999                	lui	s3,0x6
    800024a2:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    800024a6:	0018ca17          	auipc	s4,0x18c
    800024aa:	a9aa0a13          	add	s4,s4,-1382 # 8018df40 <tickslock>
    800024ae:	a0d9                	j	80002574 <wait+0x10a>
          pid = pp->pid;
    800024b0:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024b4:	000b8e63          	beqz	s7,800024d0 <wait+0x66>
    800024b8:	4691                	li	a3,4
    800024ba:	02c48613          	add	a2,s1,44
    800024be:	85de                	mv	a1,s7
    800024c0:	05093503          	ld	a0,80(s2)
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	1ce080e7          	jalr	462(ra) # 80001692 <copyout>
    800024cc:	04054063          	bltz	a0,8000250c <wait+0xa2>
          freeproc(pp);
    800024d0:	8526                	mv	a0,s1
    800024d2:	fffff097          	auipc	ra,0xfffff
    800024d6:	6c2080e7          	jalr	1730(ra) # 80001b94 <freeproc>
          release(&pp->lock);
    800024da:	8526                	mv	a0,s1
    800024dc:	ffffe097          	auipc	ra,0xffffe
    800024e0:	7aa080e7          	jalr	1962(ra) # 80000c86 <release>
          release(&wait_lock);
    800024e4:	0000f517          	auipc	a0,0xf
    800024e8:	84450513          	add	a0,a0,-1980 # 80010d28 <wait_lock>
    800024ec:	ffffe097          	auipc	ra,0xffffe
    800024f0:	79a080e7          	jalr	1946(ra) # 80000c86 <release>
}
    800024f4:	854e                	mv	a0,s3
    800024f6:	60a6                	ld	ra,72(sp)
    800024f8:	6406                	ld	s0,64(sp)
    800024fa:	74e2                	ld	s1,56(sp)
    800024fc:	7942                	ld	s2,48(sp)
    800024fe:	79a2                	ld	s3,40(sp)
    80002500:	7a02                	ld	s4,32(sp)
    80002502:	6ae2                	ld	s5,24(sp)
    80002504:	6b42                	ld	s6,16(sp)
    80002506:	6ba2                	ld	s7,8(sp)
    80002508:	6161                	add	sp,sp,80
    8000250a:	8082                	ret
            release(&pp->lock);
    8000250c:	8526                	mv	a0,s1
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	778080e7          	jalr	1912(ra) # 80000c86 <release>
            release(&wait_lock);
    80002516:	0000f517          	auipc	a0,0xf
    8000251a:	81250513          	add	a0,a0,-2030 # 80010d28 <wait_lock>
    8000251e:	ffffe097          	auipc	ra,0xffffe
    80002522:	768080e7          	jalr	1896(ra) # 80000c86 <release>
            return -1;
    80002526:	59fd                	li	s3,-1
    80002528:	b7f1                	j	800024f4 <wait+0x8a>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000252a:	94ce                	add	s1,s1,s3
    8000252c:	03448463          	beq	s1,s4,80002554 <wait+0xea>
      if(pp->parent == p){
    80002530:	7c9c                	ld	a5,56(s1)
    80002532:	ff279ce3          	bne	a5,s2,8000252a <wait+0xc0>
        acquire(&pp->lock);
    80002536:	8526                	mv	a0,s1
    80002538:	ffffe097          	auipc	ra,0xffffe
    8000253c:	69a080e7          	jalr	1690(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002540:	4c9c                	lw	a5,24(s1)
    80002542:	f75787e3          	beq	a5,s5,800024b0 <wait+0x46>
        release(&pp->lock);
    80002546:	8526                	mv	a0,s1
    80002548:	ffffe097          	auipc	ra,0xffffe
    8000254c:	73e080e7          	jalr	1854(ra) # 80000c86 <release>
        havekids = 1;
    80002550:	875a                	mv	a4,s6
    80002552:	bfe1                	j	8000252a <wait+0xc0>
    if(!havekids || killed(p)){
    80002554:	c715                	beqz	a4,80002580 <wait+0x116>
    80002556:	854a                	mv	a0,s2
    80002558:	00000097          	auipc	ra,0x0
    8000255c:	ee0080e7          	jalr	-288(ra) # 80002438 <killed>
    80002560:	e105                	bnez	a0,80002580 <wait+0x116>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002562:	0000e597          	auipc	a1,0xe
    80002566:	7c658593          	add	a1,a1,1990 # 80010d28 <wait_lock>
    8000256a:	854a                	mv	a0,s2
    8000256c:	00000097          	auipc	ra,0x0
    80002570:	c0c080e7          	jalr	-1012(ra) # 80002178 <sleep>
    havekids = 0;
    80002574:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002576:	0000f497          	auipc	s1,0xf
    8000257a:	bca48493          	add	s1,s1,-1078 # 80011140 <proc>
    8000257e:	bf4d                	j	80002530 <wait+0xc6>
      release(&wait_lock);
    80002580:	0000e517          	auipc	a0,0xe
    80002584:	7a850513          	add	a0,a0,1960 # 80010d28 <wait_lock>
    80002588:	ffffe097          	auipc	ra,0xffffe
    8000258c:	6fe080e7          	jalr	1790(ra) # 80000c86 <release>
      return -1;
    80002590:	59fd                	li	s3,-1
    80002592:	b78d                	j	800024f4 <wait+0x8a>

0000000080002594 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002594:	7179                	add	sp,sp,-48
    80002596:	f406                	sd	ra,40(sp)
    80002598:	f022                	sd	s0,32(sp)
    8000259a:	ec26                	sd	s1,24(sp)
    8000259c:	e84a                	sd	s2,16(sp)
    8000259e:	e44e                	sd	s3,8(sp)
    800025a0:	e052                	sd	s4,0(sp)
    800025a2:	1800                	add	s0,sp,48
    800025a4:	84aa                	mv	s1,a0
    800025a6:	892e                	mv	s2,a1
    800025a8:	89b2                	mv	s3,a2
    800025aa:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025ac:	fffff097          	auipc	ra,0xfffff
    800025b0:	436080e7          	jalr	1078(ra) # 800019e2 <myproc>
  if(user_dst){
    800025b4:	c08d                	beqz	s1,800025d6 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025b6:	86d2                	mv	a3,s4
    800025b8:	864e                	mv	a2,s3
    800025ba:	85ca                	mv	a1,s2
    800025bc:	6928                	ld	a0,80(a0)
    800025be:	fffff097          	auipc	ra,0xfffff
    800025c2:	0d4080e7          	jalr	212(ra) # 80001692 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025c6:	70a2                	ld	ra,40(sp)
    800025c8:	7402                	ld	s0,32(sp)
    800025ca:	64e2                	ld	s1,24(sp)
    800025cc:	6942                	ld	s2,16(sp)
    800025ce:	69a2                	ld	s3,8(sp)
    800025d0:	6a02                	ld	s4,0(sp)
    800025d2:	6145                	add	sp,sp,48
    800025d4:	8082                	ret
    memmove((char *)dst, src, len);
    800025d6:	000a061b          	sext.w	a2,s4
    800025da:	85ce                	mv	a1,s3
    800025dc:	854a                	mv	a0,s2
    800025de:	ffffe097          	auipc	ra,0xffffe
    800025e2:	74c080e7          	jalr	1868(ra) # 80000d2a <memmove>
    return 0;
    800025e6:	8526                	mv	a0,s1
    800025e8:	bff9                	j	800025c6 <either_copyout+0x32>

00000000800025ea <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800025ea:	7179                	add	sp,sp,-48
    800025ec:	f406                	sd	ra,40(sp)
    800025ee:	f022                	sd	s0,32(sp)
    800025f0:	ec26                	sd	s1,24(sp)
    800025f2:	e84a                	sd	s2,16(sp)
    800025f4:	e44e                	sd	s3,8(sp)
    800025f6:	e052                	sd	s4,0(sp)
    800025f8:	1800                	add	s0,sp,48
    800025fa:	892a                	mv	s2,a0
    800025fc:	84ae                	mv	s1,a1
    800025fe:	89b2                	mv	s3,a2
    80002600:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002602:	fffff097          	auipc	ra,0xfffff
    80002606:	3e0080e7          	jalr	992(ra) # 800019e2 <myproc>
  if(user_src){
    8000260a:	c08d                	beqz	s1,8000262c <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    8000260c:	86d2                	mv	a3,s4
    8000260e:	864e                	mv	a2,s3
    80002610:	85ca                	mv	a1,s2
    80002612:	6928                	ld	a0,80(a0)
    80002614:	fffff097          	auipc	ra,0xfffff
    80002618:	10a080e7          	jalr	266(ra) # 8000171e <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    8000261c:	70a2                	ld	ra,40(sp)
    8000261e:	7402                	ld	s0,32(sp)
    80002620:	64e2                	ld	s1,24(sp)
    80002622:	6942                	ld	s2,16(sp)
    80002624:	69a2                	ld	s3,8(sp)
    80002626:	6a02                	ld	s4,0(sp)
    80002628:	6145                	add	sp,sp,48
    8000262a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000262c:	000a061b          	sext.w	a2,s4
    80002630:	85ce                	mv	a1,s3
    80002632:	854a                	mv	a0,s2
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	6f6080e7          	jalr	1782(ra) # 80000d2a <memmove>
    return 0;
    8000263c:	8526                	mv	a0,s1
    8000263e:	bff9                	j	8000261c <either_copyin+0x32>

0000000080002640 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002640:	715d                	add	sp,sp,-80
    80002642:	e486                	sd	ra,72(sp)
    80002644:	e0a2                	sd	s0,64(sp)
    80002646:	fc26                	sd	s1,56(sp)
    80002648:	f84a                	sd	s2,48(sp)
    8000264a:	f44e                	sd	s3,40(sp)
    8000264c:	f052                	sd	s4,32(sp)
    8000264e:	ec56                	sd	s5,24(sp)
    80002650:	e85a                	sd	s6,16(sp)
    80002652:	e45e                	sd	s7,8(sp)
    80002654:	e062                	sd	s8,0(sp)
    80002656:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002658:	00006517          	auipc	a0,0x6
    8000265c:	3c050513          	add	a0,a0,960 # 80008a18 <syscalls+0x590>
    80002660:	ffffe097          	auipc	ra,0xffffe
    80002664:	f26080e7          	jalr	-218(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002668:	0000f497          	auipc	s1,0xf
    8000266c:	c3048493          	add	s1,s1,-976 # 80011298 <proc+0x158>
    80002670:	0018c997          	auipc	s3,0x18c
    80002674:	a2898993          	add	s3,s3,-1496 # 8018e098 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002678:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    8000267a:	00006a17          	auipc	s4,0x6
    8000267e:	c3ea0a13          	add	s4,s4,-962 # 800082b8 <digits+0x278>
    printf("%d %s %s", p->pid, state, p->name);
    80002682:	00006b17          	auipc	s6,0x6
    80002686:	c3eb0b13          	add	s6,s6,-962 # 800082c0 <digits+0x280>
    printf("\n");
    8000268a:	00006a97          	auipc	s5,0x6
    8000268e:	38ea8a93          	add	s5,s5,910 # 80008a18 <syscalls+0x590>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002692:	00006c17          	auipc	s8,0x6
    80002696:	c6ec0c13          	add	s8,s8,-914 # 80008300 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    8000269a:	6919                	lui	s2,0x6
    8000269c:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    800026a0:	a005                	j	800026c0 <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    800026a2:	ed86a583          	lw	a1,-296(a3)
    800026a6:	855a                	mv	a0,s6
    800026a8:	ffffe097          	auipc	ra,0xffffe
    800026ac:	ede080e7          	jalr	-290(ra) # 80000586 <printf>
    printf("\n");
    800026b0:	8556                	mv	a0,s5
    800026b2:	ffffe097          	auipc	ra,0xffffe
    800026b6:	ed4080e7          	jalr	-300(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026ba:	94ca                	add	s1,s1,s2
    800026bc:	03348263          	beq	s1,s3,800026e0 <procdump+0xa0>
    if(p->state == UNUSED)
    800026c0:	86a6                	mv	a3,s1
    800026c2:	ec04a783          	lw	a5,-320(s1)
    800026c6:	dbf5                	beqz	a5,800026ba <procdump+0x7a>
      state = "???";
    800026c8:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026ca:	fcfbece3          	bltu	s7,a5,800026a2 <procdump+0x62>
    800026ce:	02079713          	sll	a4,a5,0x20
    800026d2:	01d75793          	srl	a5,a4,0x1d
    800026d6:	97e2                	add	a5,a5,s8
    800026d8:	6390                	ld	a2,0(a5)
    800026da:	f661                	bnez	a2,800026a2 <procdump+0x62>
      state = "???";
    800026dc:	8652                	mv	a2,s4
    800026de:	b7d1                	j	800026a2 <procdump+0x62>
  }
}
    800026e0:	60a6                	ld	ra,72(sp)
    800026e2:	6406                	ld	s0,64(sp)
    800026e4:	74e2                	ld	s1,56(sp)
    800026e6:	7942                	ld	s2,48(sp)
    800026e8:	79a2                	ld	s3,40(sp)
    800026ea:	7a02                	ld	s4,32(sp)
    800026ec:	6ae2                	ld	s5,24(sp)
    800026ee:	6b42                	ld	s6,16(sp)
    800026f0:	6ba2                	ld	s7,8(sp)
    800026f2:	6c02                	ld	s8,0(sp)
    800026f4:	6161                	add	sp,sp,80
    800026f6:	8082                	ret

00000000800026f8 <swtch>:
    800026f8:	00153023          	sd	ra,0(a0)
    800026fc:	00253423          	sd	sp,8(a0)
    80002700:	e900                	sd	s0,16(a0)
    80002702:	ed04                	sd	s1,24(a0)
    80002704:	03253023          	sd	s2,32(a0)
    80002708:	03353423          	sd	s3,40(a0)
    8000270c:	03453823          	sd	s4,48(a0)
    80002710:	03553c23          	sd	s5,56(a0)
    80002714:	05653023          	sd	s6,64(a0)
    80002718:	05753423          	sd	s7,72(a0)
    8000271c:	05853823          	sd	s8,80(a0)
    80002720:	05953c23          	sd	s9,88(a0)
    80002724:	07a53023          	sd	s10,96(a0)
    80002728:	07b53423          	sd	s11,104(a0)
    8000272c:	0005b083          	ld	ra,0(a1)
    80002730:	0085b103          	ld	sp,8(a1)
    80002734:	6980                	ld	s0,16(a1)
    80002736:	6d84                	ld	s1,24(a1)
    80002738:	0205b903          	ld	s2,32(a1)
    8000273c:	0285b983          	ld	s3,40(a1)
    80002740:	0305ba03          	ld	s4,48(a1)
    80002744:	0385ba83          	ld	s5,56(a1)
    80002748:	0405bb03          	ld	s6,64(a1)
    8000274c:	0485bb83          	ld	s7,72(a1)
    80002750:	0505bc03          	ld	s8,80(a1)
    80002754:	0585bc83          	ld	s9,88(a1)
    80002758:	0605bd03          	ld	s10,96(a1)
    8000275c:	0685bd83          	ld	s11,104(a1)
    80002760:	8082                	ret

0000000080002762 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002762:	1141                	add	sp,sp,-16
    80002764:	e406                	sd	ra,8(sp)
    80002766:	e022                	sd	s0,0(sp)
    80002768:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    8000276a:	00006597          	auipc	a1,0x6
    8000276e:	bc658593          	add	a1,a1,-1082 # 80008330 <states.0+0x30>
    80002772:	0018b517          	auipc	a0,0x18b
    80002776:	7ce50513          	add	a0,a0,1998 # 8018df40 <tickslock>
    8000277a:	ffffe097          	auipc	ra,0xffffe
    8000277e:	3c8080e7          	jalr	968(ra) # 80000b42 <initlock>
}
    80002782:	60a2                	ld	ra,8(sp)
    80002784:	6402                	ld	s0,0(sp)
    80002786:	0141                	add	sp,sp,16
    80002788:	8082                	ret

000000008000278a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000278a:	1141                	add	sp,sp,-16
    8000278c:	e422                	sd	s0,8(sp)
    8000278e:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002790:	00003797          	auipc	a5,0x3
    80002794:	56078793          	add	a5,a5,1376 # 80005cf0 <kernelvec>
    80002798:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    8000279c:	6422                	ld	s0,8(sp)
    8000279e:	0141                	add	sp,sp,16
    800027a0:	8082                	ret

00000000800027a2 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027a2:	1141                	add	sp,sp,-16
    800027a4:	e406                	sd	ra,8(sp)
    800027a6:	e022                	sd	s0,0(sp)
    800027a8:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    800027aa:	fffff097          	auipc	ra,0xfffff
    800027ae:	238080e7          	jalr	568(ra) # 800019e2 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027b2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027b6:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027b8:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027bc:	00005697          	auipc	a3,0x5
    800027c0:	84468693          	add	a3,a3,-1980 # 80007000 <_trampoline>
    800027c4:	00005717          	auipc	a4,0x5
    800027c8:	83c70713          	add	a4,a4,-1988 # 80007000 <_trampoline>
    800027cc:	8f15                	sub	a4,a4,a3
    800027ce:	040007b7          	lui	a5,0x4000
    800027d2:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027d4:	07b2                	sll	a5,a5,0xc
    800027d6:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027d8:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027dc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027de:	18002673          	csrr	a2,satp
    800027e2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027e4:	6d30                	ld	a2,88(a0)
    800027e6:	6138                	ld	a4,64(a0)
    800027e8:	6585                	lui	a1,0x1
    800027ea:	972e                	add	a4,a4,a1
    800027ec:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027ee:	6d38                	ld	a4,88(a0)
    800027f0:	00000617          	auipc	a2,0x0
    800027f4:	13460613          	add	a2,a2,308 # 80002924 <usertrap>
    800027f8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800027fa:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800027fc:	8612                	mv	a2,tp
    800027fe:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002800:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002804:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002808:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000280c:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80002810:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002812:	6f18                	ld	a4,24(a4)
    80002814:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002818:	6928                	ld	a0,80(a0)
    8000281a:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000281c:	00005717          	auipc	a4,0x5
    80002820:	88070713          	add	a4,a4,-1920 # 8000709c <userret>
    80002824:	8f15                	sub	a4,a4,a3
    80002826:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002828:	577d                	li	a4,-1
    8000282a:	177e                	sll	a4,a4,0x3f
    8000282c:	8d59                	or	a0,a0,a4
    8000282e:	9782                	jalr	a5
}
    80002830:	60a2                	ld	ra,8(sp)
    80002832:	6402                	ld	s0,0(sp)
    80002834:	0141                	add	sp,sp,16
    80002836:	8082                	ret

0000000080002838 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002838:	1101                	add	sp,sp,-32
    8000283a:	ec06                	sd	ra,24(sp)
    8000283c:	e822                	sd	s0,16(sp)
    8000283e:	e426                	sd	s1,8(sp)
    80002840:	1000                	add	s0,sp,32
  acquire(&tickslock);
    80002842:	0018b497          	auipc	s1,0x18b
    80002846:	6fe48493          	add	s1,s1,1790 # 8018df40 <tickslock>
    8000284a:	8526                	mv	a0,s1
    8000284c:	ffffe097          	auipc	ra,0xffffe
    80002850:	386080e7          	jalr	902(ra) # 80000bd2 <acquire>
  ticks++;
    80002854:	00006517          	auipc	a0,0x6
    80002858:	24c50513          	add	a0,a0,588 # 80008aa0 <ticks>
    8000285c:	411c                	lw	a5,0(a0)
    8000285e:	2785                	addw	a5,a5,1
    80002860:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002862:	00000097          	auipc	ra,0x0
    80002866:	97a080e7          	jalr	-1670(ra) # 800021dc <wakeup>
  release(&tickslock);
    8000286a:	8526                	mv	a0,s1
    8000286c:	ffffe097          	auipc	ra,0xffffe
    80002870:	41a080e7          	jalr	1050(ra) # 80000c86 <release>
}
    80002874:	60e2                	ld	ra,24(sp)
    80002876:	6442                	ld	s0,16(sp)
    80002878:	64a2                	ld	s1,8(sp)
    8000287a:	6105                	add	sp,sp,32
    8000287c:	8082                	ret

000000008000287e <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    8000287e:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80002882:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    80002884:	0807df63          	bgez	a5,80002922 <devintr+0xa4>
{
    80002888:	1101                	add	sp,sp,-32
    8000288a:	ec06                	sd	ra,24(sp)
    8000288c:	e822                	sd	s0,16(sp)
    8000288e:	e426                	sd	s1,8(sp)
    80002890:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    80002892:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002896:	46a5                	li	a3,9
    80002898:	00d70d63          	beq	a4,a3,800028b2 <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    8000289c:	577d                	li	a4,-1
    8000289e:	177e                	sll	a4,a4,0x3f
    800028a0:	0705                	add	a4,a4,1
    return 0;
    800028a2:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028a4:	04e78e63          	beq	a5,a4,80002900 <devintr+0x82>
  }
}
    800028a8:	60e2                	ld	ra,24(sp)
    800028aa:	6442                	ld	s0,16(sp)
    800028ac:	64a2                	ld	s1,8(sp)
    800028ae:	6105                	add	sp,sp,32
    800028b0:	8082                	ret
    int irq = plic_claim();
    800028b2:	00003097          	auipc	ra,0x3
    800028b6:	546080e7          	jalr	1350(ra) # 80005df8 <plic_claim>
    800028ba:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028bc:	47a9                	li	a5,10
    800028be:	02f50763          	beq	a0,a5,800028ec <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    800028c2:	4785                	li	a5,1
    800028c4:	02f50963          	beq	a0,a5,800028f6 <devintr+0x78>
    return 1;
    800028c8:	4505                	li	a0,1
    } else if(irq){
    800028ca:	dcf9                	beqz	s1,800028a8 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    800028cc:	85a6                	mv	a1,s1
    800028ce:	00006517          	auipc	a0,0x6
    800028d2:	a6a50513          	add	a0,a0,-1430 # 80008338 <states.0+0x38>
    800028d6:	ffffe097          	auipc	ra,0xffffe
    800028da:	cb0080e7          	jalr	-848(ra) # 80000586 <printf>
      plic_complete(irq);
    800028de:	8526                	mv	a0,s1
    800028e0:	00003097          	auipc	ra,0x3
    800028e4:	53c080e7          	jalr	1340(ra) # 80005e1c <plic_complete>
    return 1;
    800028e8:	4505                	li	a0,1
    800028ea:	bf7d                	j	800028a8 <devintr+0x2a>
      uartintr();
    800028ec:	ffffe097          	auipc	ra,0xffffe
    800028f0:	0a8080e7          	jalr	168(ra) # 80000994 <uartintr>
    if(irq)
    800028f4:	b7ed                	j	800028de <devintr+0x60>
      virtio_disk_intr();
    800028f6:	00004097          	auipc	ra,0x4
    800028fa:	9ec080e7          	jalr	-1556(ra) # 800062e2 <virtio_disk_intr>
    if(irq)
    800028fe:	b7c5                	j	800028de <devintr+0x60>
    if(cpuid() == 0){
    80002900:	fffff097          	auipc	ra,0xfffff
    80002904:	0b6080e7          	jalr	182(ra) # 800019b6 <cpuid>
    80002908:	c901                	beqz	a0,80002918 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    8000290a:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000290e:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80002910:	14479073          	csrw	sip,a5
    return 2;
    80002914:	4509                	li	a0,2
    80002916:	bf49                	j	800028a8 <devintr+0x2a>
      clockintr();
    80002918:	00000097          	auipc	ra,0x0
    8000291c:	f20080e7          	jalr	-224(ra) # 80002838 <clockintr>
    80002920:	b7ed                	j	8000290a <devintr+0x8c>
}
    80002922:	8082                	ret

0000000080002924 <usertrap>:
{
    80002924:	1101                	add	sp,sp,-32
    80002926:	ec06                	sd	ra,24(sp)
    80002928:	e822                	sd	s0,16(sp)
    8000292a:	e426                	sd	s1,8(sp)
    8000292c:	e04a                	sd	s2,0(sp)
    8000292e:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002930:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80002934:	1007f793          	and	a5,a5,256
    80002938:	e7c1                	bnez	a5,800029c0 <usertrap+0x9c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000293a:	00003797          	auipc	a5,0x3
    8000293e:	3b678793          	add	a5,a5,950 # 80005cf0 <kernelvec>
    80002942:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002946:	fffff097          	auipc	ra,0xfffff
    8000294a:	09c080e7          	jalr	156(ra) # 800019e2 <myproc>
    8000294e:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80002950:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002952:	14102773          	csrr	a4,sepc
    80002956:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002958:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    8000295c:	47a1                	li	a5,8
    8000295e:	06f70963          	beq	a4,a5,800029d0 <usertrap+0xac>
    80002962:	14202773          	csrr	a4,scause
  else if(r_scause() == 12 || r_scause() == 13 || r_scause() == 15){
    80002966:	47b1                	li	a5,12
    80002968:	00f70c63          	beq	a4,a5,80002980 <usertrap+0x5c>
    8000296c:	14202773          	csrr	a4,scause
    80002970:	47b5                	li	a5,13
    80002972:	00f70763          	beq	a4,a5,80002980 <usertrap+0x5c>
    80002976:	14202773          	csrr	a4,scause
    8000297a:	47bd                	li	a5,15
    8000297c:	08f71a63          	bne	a4,a5,80002a10 <usertrap+0xec>
    if(killed(p))
    80002980:	8526                	mv	a0,s1
    80002982:	00000097          	auipc	ra,0x0
    80002986:	ab6080e7          	jalr	-1354(ra) # 80002438 <killed>
    8000298a:	ed2d                	bnez	a0,80002a04 <usertrap+0xe0>
    page_fault_handler();
    8000298c:	00004097          	auipc	ra,0x4
    80002990:	c96080e7          	jalr	-874(ra) # 80006622 <page_fault_handler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002994:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002998:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000299c:	10079073          	csrw	sstatus,a5
  if(killed(p))
    800029a0:	8526                	mv	a0,s1
    800029a2:	00000097          	auipc	ra,0x0
    800029a6:	a96080e7          	jalr	-1386(ra) # 80002438 <killed>
    800029aa:	ed4d                	bnez	a0,80002a64 <usertrap+0x140>
  usertrapret();
    800029ac:	00000097          	auipc	ra,0x0
    800029b0:	df6080e7          	jalr	-522(ra) # 800027a2 <usertrapret>
}
    800029b4:	60e2                	ld	ra,24(sp)
    800029b6:	6442                	ld	s0,16(sp)
    800029b8:	64a2                	ld	s1,8(sp)
    800029ba:	6902                	ld	s2,0(sp)
    800029bc:	6105                	add	sp,sp,32
    800029be:	8082                	ret
    panic("usertrap: not from user mode");
    800029c0:	00006517          	auipc	a0,0x6
    800029c4:	99850513          	add	a0,a0,-1640 # 80008358 <states.0+0x58>
    800029c8:	ffffe097          	auipc	ra,0xffffe
    800029cc:	b74080e7          	jalr	-1164(ra) # 8000053c <panic>
    if(killed(p))
    800029d0:	00000097          	auipc	ra,0x0
    800029d4:	a68080e7          	jalr	-1432(ra) # 80002438 <killed>
    800029d8:	e105                	bnez	a0,800029f8 <usertrap+0xd4>
    p->trapframe->epc += 4;
    800029da:	6cb8                	ld	a4,88(s1)
    800029dc:	6f1c                	ld	a5,24(a4)
    800029de:	0791                	add	a5,a5,4
    800029e0:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029e2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029e6:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029ea:	10079073          	csrw	sstatus,a5
    syscall();
    800029ee:	00000097          	auipc	ra,0x0
    800029f2:	2dc080e7          	jalr	732(ra) # 80002cca <syscall>
    800029f6:	b76d                	j	800029a0 <usertrap+0x7c>
      exit(-1);
    800029f8:	557d                	li	a0,-1
    800029fa:	00000097          	auipc	ra,0x0
    800029fe:	8c2080e7          	jalr	-1854(ra) # 800022bc <exit>
    80002a02:	bfe1                	j	800029da <usertrap+0xb6>
      exit(-1);
    80002a04:	557d                	li	a0,-1
    80002a06:	00000097          	auipc	ra,0x0
    80002a0a:	8b6080e7          	jalr	-1866(ra) # 800022bc <exit>
    80002a0e:	bfbd                	j	8000298c <usertrap+0x68>
  else if((which_dev = devintr()) != 0){
    80002a10:	00000097          	auipc	ra,0x0
    80002a14:	e6e080e7          	jalr	-402(ra) # 8000287e <devintr>
    80002a18:	892a                	mv	s2,a0
    80002a1a:	c901                	beqz	a0,80002a2a <usertrap+0x106>
  if(killed(p))
    80002a1c:	8526                	mv	a0,s1
    80002a1e:	00000097          	auipc	ra,0x0
    80002a22:	a1a080e7          	jalr	-1510(ra) # 80002438 <killed>
    80002a26:	c529                	beqz	a0,80002a70 <usertrap+0x14c>
    80002a28:	a83d                	j	80002a66 <usertrap+0x142>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a2a:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80002a2e:	5890                	lw	a2,48(s1)
    80002a30:	00006517          	auipc	a0,0x6
    80002a34:	94850513          	add	a0,a0,-1720 # 80008378 <states.0+0x78>
    80002a38:	ffffe097          	auipc	ra,0xffffe
    80002a3c:	b4e080e7          	jalr	-1202(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a40:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a44:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a48:	00006517          	auipc	a0,0x6
    80002a4c:	96050513          	add	a0,a0,-1696 # 800083a8 <states.0+0xa8>
    80002a50:	ffffe097          	auipc	ra,0xffffe
    80002a54:	b36080e7          	jalr	-1226(ra) # 80000586 <printf>
    setkilled(p);
    80002a58:	8526                	mv	a0,s1
    80002a5a:	00000097          	auipc	ra,0x0
    80002a5e:	9b2080e7          	jalr	-1614(ra) # 8000240c <setkilled>
    80002a62:	bf3d                	j	800029a0 <usertrap+0x7c>
  if(killed(p))
    80002a64:	4901                	li	s2,0
    exit(-1);
    80002a66:	557d                	li	a0,-1
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	854080e7          	jalr	-1964(ra) # 800022bc <exit>
  if(which_dev == 2)
    80002a70:	4789                	li	a5,2
    80002a72:	f2f91de3          	bne	s2,a5,800029ac <usertrap+0x88>
    yield();
    80002a76:	fffff097          	auipc	ra,0xfffff
    80002a7a:	6c6080e7          	jalr	1734(ra) # 8000213c <yield>
    80002a7e:	b73d                	j	800029ac <usertrap+0x88>

0000000080002a80 <kerneltrap>:
{
    80002a80:	7179                	add	sp,sp,-48
    80002a82:	f406                	sd	ra,40(sp)
    80002a84:	f022                	sd	s0,32(sp)
    80002a86:	ec26                	sd	s1,24(sp)
    80002a88:	e84a                	sd	s2,16(sp)
    80002a8a:	e44e                	sd	s3,8(sp)
    80002a8c:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a8e:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a92:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a96:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a9a:	1004f793          	and	a5,s1,256
    80002a9e:	cb85                	beqz	a5,80002ace <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002aa0:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002aa4:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002aa6:	ef85                	bnez	a5,80002ade <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002aa8:	00000097          	auipc	ra,0x0
    80002aac:	dd6080e7          	jalr	-554(ra) # 8000287e <devintr>
    80002ab0:	cd1d                	beqz	a0,80002aee <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002ab2:	4789                	li	a5,2
    80002ab4:	06f50a63          	beq	a0,a5,80002b28 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002ab8:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002abc:	10049073          	csrw	sstatus,s1
}
    80002ac0:	70a2                	ld	ra,40(sp)
    80002ac2:	7402                	ld	s0,32(sp)
    80002ac4:	64e2                	ld	s1,24(sp)
    80002ac6:	6942                	ld	s2,16(sp)
    80002ac8:	69a2                	ld	s3,8(sp)
    80002aca:	6145                	add	sp,sp,48
    80002acc:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002ace:	00006517          	auipc	a0,0x6
    80002ad2:	8fa50513          	add	a0,a0,-1798 # 800083c8 <states.0+0xc8>
    80002ad6:	ffffe097          	auipc	ra,0xffffe
    80002ada:	a66080e7          	jalr	-1434(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002ade:	00006517          	auipc	a0,0x6
    80002ae2:	91250513          	add	a0,a0,-1774 # 800083f0 <states.0+0xf0>
    80002ae6:	ffffe097          	auipc	ra,0xffffe
    80002aea:	a56080e7          	jalr	-1450(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002aee:	85ce                	mv	a1,s3
    80002af0:	00006517          	auipc	a0,0x6
    80002af4:	92050513          	add	a0,a0,-1760 # 80008410 <states.0+0x110>
    80002af8:	ffffe097          	auipc	ra,0xffffe
    80002afc:	a8e080e7          	jalr	-1394(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002b00:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002b04:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002b08:	00006517          	auipc	a0,0x6
    80002b0c:	91850513          	add	a0,a0,-1768 # 80008420 <states.0+0x120>
    80002b10:	ffffe097          	auipc	ra,0xffffe
    80002b14:	a76080e7          	jalr	-1418(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002b18:	00006517          	auipc	a0,0x6
    80002b1c:	92050513          	add	a0,a0,-1760 # 80008438 <states.0+0x138>
    80002b20:	ffffe097          	auipc	ra,0xffffe
    80002b24:	a1c080e7          	jalr	-1508(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002b28:	fffff097          	auipc	ra,0xfffff
    80002b2c:	eba080e7          	jalr	-326(ra) # 800019e2 <myproc>
    80002b30:	d541                	beqz	a0,80002ab8 <kerneltrap+0x38>
    80002b32:	fffff097          	auipc	ra,0xfffff
    80002b36:	eb0080e7          	jalr	-336(ra) # 800019e2 <myproc>
    80002b3a:	4d18                	lw	a4,24(a0)
    80002b3c:	4791                	li	a5,4
    80002b3e:	f6f71de3          	bne	a4,a5,80002ab8 <kerneltrap+0x38>
    yield();
    80002b42:	fffff097          	auipc	ra,0xfffff
    80002b46:	5fa080e7          	jalr	1530(ra) # 8000213c <yield>
    80002b4a:	b7bd                	j	80002ab8 <kerneltrap+0x38>

0000000080002b4c <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b4c:	1101                	add	sp,sp,-32
    80002b4e:	ec06                	sd	ra,24(sp)
    80002b50:	e822                	sd	s0,16(sp)
    80002b52:	e426                	sd	s1,8(sp)
    80002b54:	1000                	add	s0,sp,32
    80002b56:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b58:	fffff097          	auipc	ra,0xfffff
    80002b5c:	e8a080e7          	jalr	-374(ra) # 800019e2 <myproc>
  switch (n) {
    80002b60:	4795                	li	a5,5
    80002b62:	0497e163          	bltu	a5,s1,80002ba4 <argraw+0x58>
    80002b66:	048a                	sll	s1,s1,0x2
    80002b68:	00006717          	auipc	a4,0x6
    80002b6c:	90870713          	add	a4,a4,-1784 # 80008470 <states.0+0x170>
    80002b70:	94ba                	add	s1,s1,a4
    80002b72:	409c                	lw	a5,0(s1)
    80002b74:	97ba                	add	a5,a5,a4
    80002b76:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b78:	6d3c                	ld	a5,88(a0)
    80002b7a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6105                	add	sp,sp,32
    80002b84:	8082                	ret
    return p->trapframe->a1;
    80002b86:	6d3c                	ld	a5,88(a0)
    80002b88:	7fa8                	ld	a0,120(a5)
    80002b8a:	bfcd                	j	80002b7c <argraw+0x30>
    return p->trapframe->a2;
    80002b8c:	6d3c                	ld	a5,88(a0)
    80002b8e:	63c8                	ld	a0,128(a5)
    80002b90:	b7f5                	j	80002b7c <argraw+0x30>
    return p->trapframe->a3;
    80002b92:	6d3c                	ld	a5,88(a0)
    80002b94:	67c8                	ld	a0,136(a5)
    80002b96:	b7dd                	j	80002b7c <argraw+0x30>
    return p->trapframe->a4;
    80002b98:	6d3c                	ld	a5,88(a0)
    80002b9a:	6bc8                	ld	a0,144(a5)
    80002b9c:	b7c5                	j	80002b7c <argraw+0x30>
    return p->trapframe->a5;
    80002b9e:	6d3c                	ld	a5,88(a0)
    80002ba0:	6fc8                	ld	a0,152(a5)
    80002ba2:	bfe9                	j	80002b7c <argraw+0x30>
  panic("argraw");
    80002ba4:	00006517          	auipc	a0,0x6
    80002ba8:	8a450513          	add	a0,a0,-1884 # 80008448 <states.0+0x148>
    80002bac:	ffffe097          	auipc	ra,0xffffe
    80002bb0:	990080e7          	jalr	-1648(ra) # 8000053c <panic>

0000000080002bb4 <fetchaddr>:
{
    80002bb4:	1101                	add	sp,sp,-32
    80002bb6:	ec06                	sd	ra,24(sp)
    80002bb8:	e822                	sd	s0,16(sp)
    80002bba:	e426                	sd	s1,8(sp)
    80002bbc:	e04a                	sd	s2,0(sp)
    80002bbe:	1000                	add	s0,sp,32
    80002bc0:	84aa                	mv	s1,a0
    80002bc2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002bc4:	fffff097          	auipc	ra,0xfffff
    80002bc8:	e1e080e7          	jalr	-482(ra) # 800019e2 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002bcc:	653c                	ld	a5,72(a0)
    80002bce:	02f4f863          	bgeu	s1,a5,80002bfe <fetchaddr+0x4a>
    80002bd2:	00848713          	add	a4,s1,8
    80002bd6:	02e7e663          	bltu	a5,a4,80002c02 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002bda:	46a1                	li	a3,8
    80002bdc:	8626                	mv	a2,s1
    80002bde:	85ca                	mv	a1,s2
    80002be0:	6928                	ld	a0,80(a0)
    80002be2:	fffff097          	auipc	ra,0xfffff
    80002be6:	b3c080e7          	jalr	-1220(ra) # 8000171e <copyin>
    80002bea:	00a03533          	snez	a0,a0
    80002bee:	40a00533          	neg	a0,a0
}
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	64a2                	ld	s1,8(sp)
    80002bf8:	6902                	ld	s2,0(sp)
    80002bfa:	6105                	add	sp,sp,32
    80002bfc:	8082                	ret
    return -1;
    80002bfe:	557d                	li	a0,-1
    80002c00:	bfcd                	j	80002bf2 <fetchaddr+0x3e>
    80002c02:	557d                	li	a0,-1
    80002c04:	b7fd                	j	80002bf2 <fetchaddr+0x3e>

0000000080002c06 <fetchstr>:
{
    80002c06:	7179                	add	sp,sp,-48
    80002c08:	f406                	sd	ra,40(sp)
    80002c0a:	f022                	sd	s0,32(sp)
    80002c0c:	ec26                	sd	s1,24(sp)
    80002c0e:	e84a                	sd	s2,16(sp)
    80002c10:	e44e                	sd	s3,8(sp)
    80002c12:	1800                	add	s0,sp,48
    80002c14:	892a                	mv	s2,a0
    80002c16:	84ae                	mv	s1,a1
    80002c18:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002c1a:	fffff097          	auipc	ra,0xfffff
    80002c1e:	dc8080e7          	jalr	-568(ra) # 800019e2 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002c22:	86ce                	mv	a3,s3
    80002c24:	864a                	mv	a2,s2
    80002c26:	85a6                	mv	a1,s1
    80002c28:	6928                	ld	a0,80(a0)
    80002c2a:	fffff097          	auipc	ra,0xfffff
    80002c2e:	b82080e7          	jalr	-1150(ra) # 800017ac <copyinstr>
    80002c32:	00054e63          	bltz	a0,80002c4e <fetchstr+0x48>
  return strlen(buf);
    80002c36:	8526                	mv	a0,s1
    80002c38:	ffffe097          	auipc	ra,0xffffe
    80002c3c:	210080e7          	jalr	528(ra) # 80000e48 <strlen>
}
    80002c40:	70a2                	ld	ra,40(sp)
    80002c42:	7402                	ld	s0,32(sp)
    80002c44:	64e2                	ld	s1,24(sp)
    80002c46:	6942                	ld	s2,16(sp)
    80002c48:	69a2                	ld	s3,8(sp)
    80002c4a:	6145                	add	sp,sp,48
    80002c4c:	8082                	ret
    return -1;
    80002c4e:	557d                	li	a0,-1
    80002c50:	bfc5                	j	80002c40 <fetchstr+0x3a>

0000000080002c52 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c52:	1101                	add	sp,sp,-32
    80002c54:	ec06                	sd	ra,24(sp)
    80002c56:	e822                	sd	s0,16(sp)
    80002c58:	e426                	sd	s1,8(sp)
    80002c5a:	1000                	add	s0,sp,32
    80002c5c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c5e:	00000097          	auipc	ra,0x0
    80002c62:	eee080e7          	jalr	-274(ra) # 80002b4c <argraw>
    80002c66:	c088                	sw	a0,0(s1)
}
    80002c68:	60e2                	ld	ra,24(sp)
    80002c6a:	6442                	ld	s0,16(sp)
    80002c6c:	64a2                	ld	s1,8(sp)
    80002c6e:	6105                	add	sp,sp,32
    80002c70:	8082                	ret

0000000080002c72 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c72:	1101                	add	sp,sp,-32
    80002c74:	ec06                	sd	ra,24(sp)
    80002c76:	e822                	sd	s0,16(sp)
    80002c78:	e426                	sd	s1,8(sp)
    80002c7a:	1000                	add	s0,sp,32
    80002c7c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c7e:	00000097          	auipc	ra,0x0
    80002c82:	ece080e7          	jalr	-306(ra) # 80002b4c <argraw>
    80002c86:	e088                	sd	a0,0(s1)
}
    80002c88:	60e2                	ld	ra,24(sp)
    80002c8a:	6442                	ld	s0,16(sp)
    80002c8c:	64a2                	ld	s1,8(sp)
    80002c8e:	6105                	add	sp,sp,32
    80002c90:	8082                	ret

0000000080002c92 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c92:	7179                	add	sp,sp,-48
    80002c94:	f406                	sd	ra,40(sp)
    80002c96:	f022                	sd	s0,32(sp)
    80002c98:	ec26                	sd	s1,24(sp)
    80002c9a:	e84a                	sd	s2,16(sp)
    80002c9c:	1800                	add	s0,sp,48
    80002c9e:	84ae                	mv	s1,a1
    80002ca0:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002ca2:	fd840593          	add	a1,s0,-40
    80002ca6:	00000097          	auipc	ra,0x0
    80002caa:	fcc080e7          	jalr	-52(ra) # 80002c72 <argaddr>
  return fetchstr(addr, buf, max);
    80002cae:	864a                	mv	a2,s2
    80002cb0:	85a6                	mv	a1,s1
    80002cb2:	fd843503          	ld	a0,-40(s0)
    80002cb6:	00000097          	auipc	ra,0x0
    80002cba:	f50080e7          	jalr	-176(ra) # 80002c06 <fetchstr>
}
    80002cbe:	70a2                	ld	ra,40(sp)
    80002cc0:	7402                	ld	s0,32(sp)
    80002cc2:	64e2                	ld	s1,24(sp)
    80002cc4:	6942                	ld	s2,16(sp)
    80002cc6:	6145                	add	sp,sp,48
    80002cc8:	8082                	ret

0000000080002cca <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002cca:	1101                	add	sp,sp,-32
    80002ccc:	ec06                	sd	ra,24(sp)
    80002cce:	e822                	sd	s0,16(sp)
    80002cd0:	e426                	sd	s1,8(sp)
    80002cd2:	e04a                	sd	s2,0(sp)
    80002cd4:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002cd6:	fffff097          	auipc	ra,0xfffff
    80002cda:	d0c080e7          	jalr	-756(ra) # 800019e2 <myproc>
    80002cde:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002ce0:	05853903          	ld	s2,88(a0)
    80002ce4:	0a893783          	ld	a5,168(s2)
    80002ce8:	0007869b          	sext.w	a3,a5
  
  /* Adil: debugging */
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002cec:	37fd                	addw	a5,a5,-1
    80002cee:	4751                	li	a4,20
    80002cf0:	00f76f63          	bltu	a4,a5,80002d0e <syscall+0x44>
    80002cf4:	00369713          	sll	a4,a3,0x3
    80002cf8:	00005797          	auipc	a5,0x5
    80002cfc:	79078793          	add	a5,a5,1936 # 80008488 <syscalls>
    80002d00:	97ba                	add	a5,a5,a4
    80002d02:	639c                	ld	a5,0(a5)
    80002d04:	c789                	beqz	a5,80002d0e <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002d06:	9782                	jalr	a5
    80002d08:	06a93823          	sd	a0,112(s2)
    80002d0c:	a839                	j	80002d2a <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002d0e:	15848613          	add	a2,s1,344
    80002d12:	588c                	lw	a1,48(s1)
    80002d14:	00005517          	auipc	a0,0x5
    80002d18:	73c50513          	add	a0,a0,1852 # 80008450 <states.0+0x150>
    80002d1c:	ffffe097          	auipc	ra,0xffffe
    80002d20:	86a080e7          	jalr	-1942(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002d24:	6cbc                	ld	a5,88(s1)
    80002d26:	577d                	li	a4,-1
    80002d28:	fbb8                	sd	a4,112(a5)
  }
}
    80002d2a:	60e2                	ld	ra,24(sp)
    80002d2c:	6442                	ld	s0,16(sp)
    80002d2e:	64a2                	ld	s1,8(sp)
    80002d30:	6902                	ld	s2,0(sp)
    80002d32:	6105                	add	sp,sp,32
    80002d34:	8082                	ret

0000000080002d36 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002d36:	1101                	add	sp,sp,-32
    80002d38:	ec06                	sd	ra,24(sp)
    80002d3a:	e822                	sd	s0,16(sp)
    80002d3c:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002d3e:	fec40593          	add	a1,s0,-20
    80002d42:	4501                	li	a0,0
    80002d44:	00000097          	auipc	ra,0x0
    80002d48:	f0e080e7          	jalr	-242(ra) # 80002c52 <argint>
  exit(n);
    80002d4c:	fec42503          	lw	a0,-20(s0)
    80002d50:	fffff097          	auipc	ra,0xfffff
    80002d54:	56c080e7          	jalr	1388(ra) # 800022bc <exit>
  return 0;  // not reached
}
    80002d58:	4501                	li	a0,0
    80002d5a:	60e2                	ld	ra,24(sp)
    80002d5c:	6442                	ld	s0,16(sp)
    80002d5e:	6105                	add	sp,sp,32
    80002d60:	8082                	ret

0000000080002d62 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d62:	1141                	add	sp,sp,-16
    80002d64:	e406                	sd	ra,8(sp)
    80002d66:	e022                	sd	s0,0(sp)
    80002d68:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002d6a:	fffff097          	auipc	ra,0xfffff
    80002d6e:	c78080e7          	jalr	-904(ra) # 800019e2 <myproc>
}
    80002d72:	5908                	lw	a0,48(a0)
    80002d74:	60a2                	ld	ra,8(sp)
    80002d76:	6402                	ld	s0,0(sp)
    80002d78:	0141                	add	sp,sp,16
    80002d7a:	8082                	ret

0000000080002d7c <sys_fork>:

uint64
sys_fork(void)
{
    80002d7c:	1141                	add	sp,sp,-16
    80002d7e:	e406                	sd	ra,8(sp)
    80002d80:	e022                	sd	s0,0(sp)
    80002d82:	0800                	add	s0,sp,16
  return fork();
    80002d84:	fffff097          	auipc	ra,0xfffff
    80002d88:	0f4080e7          	jalr	244(ra) # 80001e78 <fork>
}
    80002d8c:	60a2                	ld	ra,8(sp)
    80002d8e:	6402                	ld	s0,0(sp)
    80002d90:	0141                	add	sp,sp,16
    80002d92:	8082                	ret

0000000080002d94 <sys_wait>:

uint64
sys_wait(void)
{
    80002d94:	1101                	add	sp,sp,-32
    80002d96:	ec06                	sd	ra,24(sp)
    80002d98:	e822                	sd	s0,16(sp)
    80002d9a:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d9c:	fe840593          	add	a1,s0,-24
    80002da0:	4501                	li	a0,0
    80002da2:	00000097          	auipc	ra,0x0
    80002da6:	ed0080e7          	jalr	-304(ra) # 80002c72 <argaddr>
  return wait(p);
    80002daa:	fe843503          	ld	a0,-24(s0)
    80002dae:	fffff097          	auipc	ra,0xfffff
    80002db2:	6bc080e7          	jalr	1724(ra) # 8000246a <wait>
}
    80002db6:	60e2                	ld	ra,24(sp)
    80002db8:	6442                	ld	s0,16(sp)
    80002dba:	6105                	add	sp,sp,32
    80002dbc:	8082                	ret

0000000080002dbe <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002dbe:	7179                	add	sp,sp,-48
    80002dc0:	f406                	sd	ra,40(sp)
    80002dc2:	f022                	sd	s0,32(sp)
    80002dc4:	ec26                	sd	s1,24(sp)
    80002dc6:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002dc8:	fdc40593          	add	a1,s0,-36
    80002dcc:	4501                	li	a0,0
    80002dce:	00000097          	auipc	ra,0x0
    80002dd2:	e84080e7          	jalr	-380(ra) # 80002c52 <argint>
  addr = myproc()->sz;
    80002dd6:	fffff097          	auipc	ra,0xfffff
    80002dda:	c0c080e7          	jalr	-1012(ra) # 800019e2 <myproc>
    80002dde:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002de0:	fdc42503          	lw	a0,-36(s0)
    80002de4:	fffff097          	auipc	ra,0xfffff
    80002de8:	fa6080e7          	jalr	-90(ra) # 80001d8a <growproc>
    80002dec:	00054863          	bltz	a0,80002dfc <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002df0:	8526                	mv	a0,s1
    80002df2:	70a2                	ld	ra,40(sp)
    80002df4:	7402                	ld	s0,32(sp)
    80002df6:	64e2                	ld	s1,24(sp)
    80002df8:	6145                	add	sp,sp,48
    80002dfa:	8082                	ret
    return -1;
    80002dfc:	54fd                	li	s1,-1
    80002dfe:	bfcd                	j	80002df0 <sys_sbrk+0x32>

0000000080002e00 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002e00:	7139                	add	sp,sp,-64
    80002e02:	fc06                	sd	ra,56(sp)
    80002e04:	f822                	sd	s0,48(sp)
    80002e06:	f426                	sd	s1,40(sp)
    80002e08:	f04a                	sd	s2,32(sp)
    80002e0a:	ec4e                	sd	s3,24(sp)
    80002e0c:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002e0e:	fcc40593          	add	a1,s0,-52
    80002e12:	4501                	li	a0,0
    80002e14:	00000097          	auipc	ra,0x0
    80002e18:	e3e080e7          	jalr	-450(ra) # 80002c52 <argint>
  acquire(&tickslock);
    80002e1c:	0018b517          	auipc	a0,0x18b
    80002e20:	12450513          	add	a0,a0,292 # 8018df40 <tickslock>
    80002e24:	ffffe097          	auipc	ra,0xffffe
    80002e28:	dae080e7          	jalr	-594(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002e2c:	00006917          	auipc	s2,0x6
    80002e30:	c7492903          	lw	s2,-908(s2) # 80008aa0 <ticks>
  while(ticks - ticks0 < n){
    80002e34:	fcc42783          	lw	a5,-52(s0)
    80002e38:	cf9d                	beqz	a5,80002e76 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002e3a:	0018b997          	auipc	s3,0x18b
    80002e3e:	10698993          	add	s3,s3,262 # 8018df40 <tickslock>
    80002e42:	00006497          	auipc	s1,0x6
    80002e46:	c5e48493          	add	s1,s1,-930 # 80008aa0 <ticks>
    if(killed(myproc())){
    80002e4a:	fffff097          	auipc	ra,0xfffff
    80002e4e:	b98080e7          	jalr	-1128(ra) # 800019e2 <myproc>
    80002e52:	fffff097          	auipc	ra,0xfffff
    80002e56:	5e6080e7          	jalr	1510(ra) # 80002438 <killed>
    80002e5a:	ed15                	bnez	a0,80002e96 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e5c:	85ce                	mv	a1,s3
    80002e5e:	8526                	mv	a0,s1
    80002e60:	fffff097          	auipc	ra,0xfffff
    80002e64:	318080e7          	jalr	792(ra) # 80002178 <sleep>
  while(ticks - ticks0 < n){
    80002e68:	409c                	lw	a5,0(s1)
    80002e6a:	412787bb          	subw	a5,a5,s2
    80002e6e:	fcc42703          	lw	a4,-52(s0)
    80002e72:	fce7ece3          	bltu	a5,a4,80002e4a <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e76:	0018b517          	auipc	a0,0x18b
    80002e7a:	0ca50513          	add	a0,a0,202 # 8018df40 <tickslock>
    80002e7e:	ffffe097          	auipc	ra,0xffffe
    80002e82:	e08080e7          	jalr	-504(ra) # 80000c86 <release>
  return 0;
    80002e86:	4501                	li	a0,0
}
    80002e88:	70e2                	ld	ra,56(sp)
    80002e8a:	7442                	ld	s0,48(sp)
    80002e8c:	74a2                	ld	s1,40(sp)
    80002e8e:	7902                	ld	s2,32(sp)
    80002e90:	69e2                	ld	s3,24(sp)
    80002e92:	6121                	add	sp,sp,64
    80002e94:	8082                	ret
      release(&tickslock);
    80002e96:	0018b517          	auipc	a0,0x18b
    80002e9a:	0aa50513          	add	a0,a0,170 # 8018df40 <tickslock>
    80002e9e:	ffffe097          	auipc	ra,0xffffe
    80002ea2:	de8080e7          	jalr	-536(ra) # 80000c86 <release>
      return -1;
    80002ea6:	557d                	li	a0,-1
    80002ea8:	b7c5                	j	80002e88 <sys_sleep+0x88>

0000000080002eaa <sys_kill>:

uint64
sys_kill(void)
{
    80002eaa:	1101                	add	sp,sp,-32
    80002eac:	ec06                	sd	ra,24(sp)
    80002eae:	e822                	sd	s0,16(sp)
    80002eb0:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002eb2:	fec40593          	add	a1,s0,-20
    80002eb6:	4501                	li	a0,0
    80002eb8:	00000097          	auipc	ra,0x0
    80002ebc:	d9a080e7          	jalr	-614(ra) # 80002c52 <argint>
  return kill(pid);
    80002ec0:	fec42503          	lw	a0,-20(s0)
    80002ec4:	fffff097          	auipc	ra,0xfffff
    80002ec8:	4ce080e7          	jalr	1230(ra) # 80002392 <kill>
}
    80002ecc:	60e2                	ld	ra,24(sp)
    80002ece:	6442                	ld	s0,16(sp)
    80002ed0:	6105                	add	sp,sp,32
    80002ed2:	8082                	ret

0000000080002ed4 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002ed4:	1101                	add	sp,sp,-32
    80002ed6:	ec06                	sd	ra,24(sp)
    80002ed8:	e822                	sd	s0,16(sp)
    80002eda:	e426                	sd	s1,8(sp)
    80002edc:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002ede:	0018b517          	auipc	a0,0x18b
    80002ee2:	06250513          	add	a0,a0,98 # 8018df40 <tickslock>
    80002ee6:	ffffe097          	auipc	ra,0xffffe
    80002eea:	cec080e7          	jalr	-788(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002eee:	00006497          	auipc	s1,0x6
    80002ef2:	bb24a483          	lw	s1,-1102(s1) # 80008aa0 <ticks>
  release(&tickslock);
    80002ef6:	0018b517          	auipc	a0,0x18b
    80002efa:	04a50513          	add	a0,a0,74 # 8018df40 <tickslock>
    80002efe:	ffffe097          	auipc	ra,0xffffe
    80002f02:	d88080e7          	jalr	-632(ra) # 80000c86 <release>
  return xticks;
}
    80002f06:	02049513          	sll	a0,s1,0x20
    80002f0a:	9101                	srl	a0,a0,0x20
    80002f0c:	60e2                	ld	ra,24(sp)
    80002f0e:	6442                	ld	s0,16(sp)
    80002f10:	64a2                	ld	s1,8(sp)
    80002f12:	6105                	add	sp,sp,32
    80002f14:	8082                	ret

0000000080002f16 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002f16:	7179                	add	sp,sp,-48
    80002f18:	f406                	sd	ra,40(sp)
    80002f1a:	f022                	sd	s0,32(sp)
    80002f1c:	ec26                	sd	s1,24(sp)
    80002f1e:	e84a                	sd	s2,16(sp)
    80002f20:	e44e                	sd	s3,8(sp)
    80002f22:	e052                	sd	s4,0(sp)
    80002f24:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002f26:	00005597          	auipc	a1,0x5
    80002f2a:	61258593          	add	a1,a1,1554 # 80008538 <syscalls+0xb0>
    80002f2e:	0018b517          	auipc	a0,0x18b
    80002f32:	02a50513          	add	a0,a0,42 # 8018df58 <bcache>
    80002f36:	ffffe097          	auipc	ra,0xffffe
    80002f3a:	c0c080e7          	jalr	-1012(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002f3e:	00193797          	auipc	a5,0x193
    80002f42:	01a78793          	add	a5,a5,26 # 80195f58 <bcache+0x8000>
    80002f46:	00193717          	auipc	a4,0x193
    80002f4a:	27a70713          	add	a4,a4,634 # 801961c0 <bcache+0x8268>
    80002f4e:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002f52:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f56:	0018b497          	auipc	s1,0x18b
    80002f5a:	01a48493          	add	s1,s1,26 # 8018df70 <bcache+0x18>
    b->next = bcache.head.next;
    80002f5e:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002f60:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002f62:	00005a17          	auipc	s4,0x5
    80002f66:	5dea0a13          	add	s4,s4,1502 # 80008540 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002f6a:	2b893783          	ld	a5,696(s2)
    80002f6e:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002f70:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002f74:	85d2                	mv	a1,s4
    80002f76:	01048513          	add	a0,s1,16
    80002f7a:	00001097          	auipc	ra,0x1
    80002f7e:	496080e7          	jalr	1174(ra) # 80004410 <initsleeplock>
    bcache.head.next->prev = b;
    80002f82:	2b893783          	ld	a5,696(s2)
    80002f86:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f88:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f8c:	45848493          	add	s1,s1,1112
    80002f90:	fd349de3          	bne	s1,s3,80002f6a <binit+0x54>
  }
}
    80002f94:	70a2                	ld	ra,40(sp)
    80002f96:	7402                	ld	s0,32(sp)
    80002f98:	64e2                	ld	s1,24(sp)
    80002f9a:	6942                	ld	s2,16(sp)
    80002f9c:	69a2                	ld	s3,8(sp)
    80002f9e:	6a02                	ld	s4,0(sp)
    80002fa0:	6145                	add	sp,sp,48
    80002fa2:	8082                	ret

0000000080002fa4 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002fa4:	7179                	add	sp,sp,-48
    80002fa6:	f406                	sd	ra,40(sp)
    80002fa8:	f022                	sd	s0,32(sp)
    80002faa:	ec26                	sd	s1,24(sp)
    80002fac:	e84a                	sd	s2,16(sp)
    80002fae:	e44e                	sd	s3,8(sp)
    80002fb0:	1800                	add	s0,sp,48
    80002fb2:	892a                	mv	s2,a0
    80002fb4:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002fb6:	0018b517          	auipc	a0,0x18b
    80002fba:	fa250513          	add	a0,a0,-94 # 8018df58 <bcache>
    80002fbe:	ffffe097          	auipc	ra,0xffffe
    80002fc2:	c14080e7          	jalr	-1004(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002fc6:	00193497          	auipc	s1,0x193
    80002fca:	24a4b483          	ld	s1,586(s1) # 80196210 <bcache+0x82b8>
    80002fce:	00193797          	auipc	a5,0x193
    80002fd2:	1f278793          	add	a5,a5,498 # 801961c0 <bcache+0x8268>
    80002fd6:	02f48f63          	beq	s1,a5,80003014 <bread+0x70>
    80002fda:	873e                	mv	a4,a5
    80002fdc:	a021                	j	80002fe4 <bread+0x40>
    80002fde:	68a4                	ld	s1,80(s1)
    80002fe0:	02e48a63          	beq	s1,a4,80003014 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002fe4:	449c                	lw	a5,8(s1)
    80002fe6:	ff279ce3          	bne	a5,s2,80002fde <bread+0x3a>
    80002fea:	44dc                	lw	a5,12(s1)
    80002fec:	ff3799e3          	bne	a5,s3,80002fde <bread+0x3a>
      b->refcnt++;
    80002ff0:	40bc                	lw	a5,64(s1)
    80002ff2:	2785                	addw	a5,a5,1
    80002ff4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ff6:	0018b517          	auipc	a0,0x18b
    80002ffa:	f6250513          	add	a0,a0,-158 # 8018df58 <bcache>
    80002ffe:	ffffe097          	auipc	ra,0xffffe
    80003002:	c88080e7          	jalr	-888(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003006:	01048513          	add	a0,s1,16
    8000300a:	00001097          	auipc	ra,0x1
    8000300e:	440080e7          	jalr	1088(ra) # 8000444a <acquiresleep>
      return b;
    80003012:	a8b9                	j	80003070 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003014:	00193497          	auipc	s1,0x193
    80003018:	1f44b483          	ld	s1,500(s1) # 80196208 <bcache+0x82b0>
    8000301c:	00193797          	auipc	a5,0x193
    80003020:	1a478793          	add	a5,a5,420 # 801961c0 <bcache+0x8268>
    80003024:	00f48863          	beq	s1,a5,80003034 <bread+0x90>
    80003028:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000302a:	40bc                	lw	a5,64(s1)
    8000302c:	cf81                	beqz	a5,80003044 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    8000302e:	64a4                	ld	s1,72(s1)
    80003030:	fee49de3          	bne	s1,a4,8000302a <bread+0x86>
  panic("bget: no buffers");
    80003034:	00005517          	auipc	a0,0x5
    80003038:	51450513          	add	a0,a0,1300 # 80008548 <syscalls+0xc0>
    8000303c:	ffffd097          	auipc	ra,0xffffd
    80003040:	500080e7          	jalr	1280(ra) # 8000053c <panic>
      b->dev = dev;
    80003044:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80003048:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    8000304c:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80003050:	4785                	li	a5,1
    80003052:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003054:	0018b517          	auipc	a0,0x18b
    80003058:	f0450513          	add	a0,a0,-252 # 8018df58 <bcache>
    8000305c:	ffffe097          	auipc	ra,0xffffe
    80003060:	c2a080e7          	jalr	-982(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80003064:	01048513          	add	a0,s1,16
    80003068:	00001097          	auipc	ra,0x1
    8000306c:	3e2080e7          	jalr	994(ra) # 8000444a <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80003070:	409c                	lw	a5,0(s1)
    80003072:	cb89                	beqz	a5,80003084 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80003074:	8526                	mv	a0,s1
    80003076:	70a2                	ld	ra,40(sp)
    80003078:	7402                	ld	s0,32(sp)
    8000307a:	64e2                	ld	s1,24(sp)
    8000307c:	6942                	ld	s2,16(sp)
    8000307e:	69a2                	ld	s3,8(sp)
    80003080:	6145                	add	sp,sp,48
    80003082:	8082                	ret
    virtio_disk_rw(b, 0);
    80003084:	4581                	li	a1,0
    80003086:	8526                	mv	a0,s1
    80003088:	00003097          	auipc	ra,0x3
    8000308c:	02a080e7          	jalr	42(ra) # 800060b2 <virtio_disk_rw>
    b->valid = 1;
    80003090:	4785                	li	a5,1
    80003092:	c09c                	sw	a5,0(s1)
  return b;
    80003094:	b7c5                	j	80003074 <bread+0xd0>

0000000080003096 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003096:	1101                	add	sp,sp,-32
    80003098:	ec06                	sd	ra,24(sp)
    8000309a:	e822                	sd	s0,16(sp)
    8000309c:	e426                	sd	s1,8(sp)
    8000309e:	1000                	add	s0,sp,32
    800030a0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030a2:	0541                	add	a0,a0,16
    800030a4:	00001097          	auipc	ra,0x1
    800030a8:	440080e7          	jalr	1088(ra) # 800044e4 <holdingsleep>
    800030ac:	cd01                	beqz	a0,800030c4 <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    800030ae:	4585                	li	a1,1
    800030b0:	8526                	mv	a0,s1
    800030b2:	00003097          	auipc	ra,0x3
    800030b6:	000080e7          	jalr	ra # 800060b2 <virtio_disk_rw>
}
    800030ba:	60e2                	ld	ra,24(sp)
    800030bc:	6442                	ld	s0,16(sp)
    800030be:	64a2                	ld	s1,8(sp)
    800030c0:	6105                	add	sp,sp,32
    800030c2:	8082                	ret
    panic("bwrite");
    800030c4:	00005517          	auipc	a0,0x5
    800030c8:	49c50513          	add	a0,a0,1180 # 80008560 <syscalls+0xd8>
    800030cc:	ffffd097          	auipc	ra,0xffffd
    800030d0:	470080e7          	jalr	1136(ra) # 8000053c <panic>

00000000800030d4 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800030d4:	1101                	add	sp,sp,-32
    800030d6:	ec06                	sd	ra,24(sp)
    800030d8:	e822                	sd	s0,16(sp)
    800030da:	e426                	sd	s1,8(sp)
    800030dc:	e04a                	sd	s2,0(sp)
    800030de:	1000                	add	s0,sp,32
    800030e0:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800030e2:	01050913          	add	s2,a0,16
    800030e6:	854a                	mv	a0,s2
    800030e8:	00001097          	auipc	ra,0x1
    800030ec:	3fc080e7          	jalr	1020(ra) # 800044e4 <holdingsleep>
    800030f0:	c925                	beqz	a0,80003160 <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    800030f2:	854a                	mv	a0,s2
    800030f4:	00001097          	auipc	ra,0x1
    800030f8:	3ac080e7          	jalr	940(ra) # 800044a0 <releasesleep>

  acquire(&bcache.lock);
    800030fc:	0018b517          	auipc	a0,0x18b
    80003100:	e5c50513          	add	a0,a0,-420 # 8018df58 <bcache>
    80003104:	ffffe097          	auipc	ra,0xffffe
    80003108:	ace080e7          	jalr	-1330(ra) # 80000bd2 <acquire>
  b->refcnt--;
    8000310c:	40bc                	lw	a5,64(s1)
    8000310e:	37fd                	addw	a5,a5,-1
    80003110:	0007871b          	sext.w	a4,a5
    80003114:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003116:	e71d                	bnez	a4,80003144 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80003118:	68b8                	ld	a4,80(s1)
    8000311a:	64bc                	ld	a5,72(s1)
    8000311c:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    8000311e:	68b8                	ld	a4,80(s1)
    80003120:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003122:	00193797          	auipc	a5,0x193
    80003126:	e3678793          	add	a5,a5,-458 # 80195f58 <bcache+0x8000>
    8000312a:	2b87b703          	ld	a4,696(a5)
    8000312e:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003130:	00193717          	auipc	a4,0x193
    80003134:	09070713          	add	a4,a4,144 # 801961c0 <bcache+0x8268>
    80003138:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000313a:	2b87b703          	ld	a4,696(a5)
    8000313e:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80003140:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80003144:	0018b517          	auipc	a0,0x18b
    80003148:	e1450513          	add	a0,a0,-492 # 8018df58 <bcache>
    8000314c:	ffffe097          	auipc	ra,0xffffe
    80003150:	b3a080e7          	jalr	-1222(ra) # 80000c86 <release>
}
    80003154:	60e2                	ld	ra,24(sp)
    80003156:	6442                	ld	s0,16(sp)
    80003158:	64a2                	ld	s1,8(sp)
    8000315a:	6902                	ld	s2,0(sp)
    8000315c:	6105                	add	sp,sp,32
    8000315e:	8082                	ret
    panic("brelse");
    80003160:	00005517          	auipc	a0,0x5
    80003164:	40850513          	add	a0,a0,1032 # 80008568 <syscalls+0xe0>
    80003168:	ffffd097          	auipc	ra,0xffffd
    8000316c:	3d4080e7          	jalr	980(ra) # 8000053c <panic>

0000000080003170 <bpin>:

void
bpin(struct buf *b) {
    80003170:	1101                	add	sp,sp,-32
    80003172:	ec06                	sd	ra,24(sp)
    80003174:	e822                	sd	s0,16(sp)
    80003176:	e426                	sd	s1,8(sp)
    80003178:	1000                	add	s0,sp,32
    8000317a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000317c:	0018b517          	auipc	a0,0x18b
    80003180:	ddc50513          	add	a0,a0,-548 # 8018df58 <bcache>
    80003184:	ffffe097          	auipc	ra,0xffffe
    80003188:	a4e080e7          	jalr	-1458(ra) # 80000bd2 <acquire>
  b->refcnt++;
    8000318c:	40bc                	lw	a5,64(s1)
    8000318e:	2785                	addw	a5,a5,1
    80003190:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003192:	0018b517          	auipc	a0,0x18b
    80003196:	dc650513          	add	a0,a0,-570 # 8018df58 <bcache>
    8000319a:	ffffe097          	auipc	ra,0xffffe
    8000319e:	aec080e7          	jalr	-1300(ra) # 80000c86 <release>
}
    800031a2:	60e2                	ld	ra,24(sp)
    800031a4:	6442                	ld	s0,16(sp)
    800031a6:	64a2                	ld	s1,8(sp)
    800031a8:	6105                	add	sp,sp,32
    800031aa:	8082                	ret

00000000800031ac <bunpin>:

void
bunpin(struct buf *b) {
    800031ac:	1101                	add	sp,sp,-32
    800031ae:	ec06                	sd	ra,24(sp)
    800031b0:	e822                	sd	s0,16(sp)
    800031b2:	e426                	sd	s1,8(sp)
    800031b4:	1000                	add	s0,sp,32
    800031b6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800031b8:	0018b517          	auipc	a0,0x18b
    800031bc:	da050513          	add	a0,a0,-608 # 8018df58 <bcache>
    800031c0:	ffffe097          	auipc	ra,0xffffe
    800031c4:	a12080e7          	jalr	-1518(ra) # 80000bd2 <acquire>
  b->refcnt--;
    800031c8:	40bc                	lw	a5,64(s1)
    800031ca:	37fd                	addw	a5,a5,-1
    800031cc:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800031ce:	0018b517          	auipc	a0,0x18b
    800031d2:	d8a50513          	add	a0,a0,-630 # 8018df58 <bcache>
    800031d6:	ffffe097          	auipc	ra,0xffffe
    800031da:	ab0080e7          	jalr	-1360(ra) # 80000c86 <release>
}
    800031de:	60e2                	ld	ra,24(sp)
    800031e0:	6442                	ld	s0,16(sp)
    800031e2:	64a2                	ld	s1,8(sp)
    800031e4:	6105                	add	sp,sp,32
    800031e6:	8082                	ret

00000000800031e8 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800031e8:	1101                	add	sp,sp,-32
    800031ea:	ec06                	sd	ra,24(sp)
    800031ec:	e822                	sd	s0,16(sp)
    800031ee:	e426                	sd	s1,8(sp)
    800031f0:	e04a                	sd	s2,0(sp)
    800031f2:	1000                	add	s0,sp,32
    800031f4:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800031f6:	00d5d59b          	srlw	a1,a1,0xd
    800031fa:	00193797          	auipc	a5,0x193
    800031fe:	43a7a783          	lw	a5,1082(a5) # 80196634 <sb+0x1c>
    80003202:	9dbd                	addw	a1,a1,a5
    80003204:	00000097          	auipc	ra,0x0
    80003208:	da0080e7          	jalr	-608(ra) # 80002fa4 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000320c:	0074f713          	and	a4,s1,7
    80003210:	4785                	li	a5,1
    80003212:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003216:	14ce                	sll	s1,s1,0x33
    80003218:	90d9                	srl	s1,s1,0x36
    8000321a:	00950733          	add	a4,a0,s1
    8000321e:	05874703          	lbu	a4,88(a4)
    80003222:	00e7f6b3          	and	a3,a5,a4
    80003226:	c69d                	beqz	a3,80003254 <bfree+0x6c>
    80003228:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000322a:	94aa                	add	s1,s1,a0
    8000322c:	fff7c793          	not	a5,a5
    80003230:	8f7d                	and	a4,a4,a5
    80003232:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80003236:	00001097          	auipc	ra,0x1
    8000323a:	0f6080e7          	jalr	246(ra) # 8000432c <log_write>
  brelse(bp);
    8000323e:	854a                	mv	a0,s2
    80003240:	00000097          	auipc	ra,0x0
    80003244:	e94080e7          	jalr	-364(ra) # 800030d4 <brelse>
}
    80003248:	60e2                	ld	ra,24(sp)
    8000324a:	6442                	ld	s0,16(sp)
    8000324c:	64a2                	ld	s1,8(sp)
    8000324e:	6902                	ld	s2,0(sp)
    80003250:	6105                	add	sp,sp,32
    80003252:	8082                	ret
    panic("freeing free block");
    80003254:	00005517          	auipc	a0,0x5
    80003258:	31c50513          	add	a0,a0,796 # 80008570 <syscalls+0xe8>
    8000325c:	ffffd097          	auipc	ra,0xffffd
    80003260:	2e0080e7          	jalr	736(ra) # 8000053c <panic>

0000000080003264 <balloc>:
{
    80003264:	711d                	add	sp,sp,-96
    80003266:	ec86                	sd	ra,88(sp)
    80003268:	e8a2                	sd	s0,80(sp)
    8000326a:	e4a6                	sd	s1,72(sp)
    8000326c:	e0ca                	sd	s2,64(sp)
    8000326e:	fc4e                	sd	s3,56(sp)
    80003270:	f852                	sd	s4,48(sp)
    80003272:	f456                	sd	s5,40(sp)
    80003274:	f05a                	sd	s6,32(sp)
    80003276:	ec5e                	sd	s7,24(sp)
    80003278:	e862                	sd	s8,16(sp)
    8000327a:	e466                	sd	s9,8(sp)
    8000327c:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000327e:	00193797          	auipc	a5,0x193
    80003282:	39e7a783          	lw	a5,926(a5) # 8019661c <sb+0x4>
    80003286:	cff5                	beqz	a5,80003382 <balloc+0x11e>
    80003288:	8baa                	mv	s7,a0
    8000328a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000328c:	00193b17          	auipc	s6,0x193
    80003290:	38cb0b13          	add	s6,s6,908 # 80196618 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003294:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003296:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003298:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000329a:	6c89                	lui	s9,0x2
    8000329c:	a061                	j	80003324 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000329e:	97ca                	add	a5,a5,s2
    800032a0:	8e55                	or	a2,a2,a3
    800032a2:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    800032a6:	854a                	mv	a0,s2
    800032a8:	00001097          	auipc	ra,0x1
    800032ac:	084080e7          	jalr	132(ra) # 8000432c <log_write>
        brelse(bp);
    800032b0:	854a                	mv	a0,s2
    800032b2:	00000097          	auipc	ra,0x0
    800032b6:	e22080e7          	jalr	-478(ra) # 800030d4 <brelse>
  bp = bread(dev, bno);
    800032ba:	85a6                	mv	a1,s1
    800032bc:	855e                	mv	a0,s7
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	ce6080e7          	jalr	-794(ra) # 80002fa4 <bread>
    800032c6:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    800032c8:	40000613          	li	a2,1024
    800032cc:	4581                	li	a1,0
    800032ce:	05850513          	add	a0,a0,88
    800032d2:	ffffe097          	auipc	ra,0xffffe
    800032d6:	9fc080e7          	jalr	-1540(ra) # 80000cce <memset>
  log_write(bp);
    800032da:	854a                	mv	a0,s2
    800032dc:	00001097          	auipc	ra,0x1
    800032e0:	050080e7          	jalr	80(ra) # 8000432c <log_write>
  brelse(bp);
    800032e4:	854a                	mv	a0,s2
    800032e6:	00000097          	auipc	ra,0x0
    800032ea:	dee080e7          	jalr	-530(ra) # 800030d4 <brelse>
}
    800032ee:	8526                	mv	a0,s1
    800032f0:	60e6                	ld	ra,88(sp)
    800032f2:	6446                	ld	s0,80(sp)
    800032f4:	64a6                	ld	s1,72(sp)
    800032f6:	6906                	ld	s2,64(sp)
    800032f8:	79e2                	ld	s3,56(sp)
    800032fa:	7a42                	ld	s4,48(sp)
    800032fc:	7aa2                	ld	s5,40(sp)
    800032fe:	7b02                	ld	s6,32(sp)
    80003300:	6be2                	ld	s7,24(sp)
    80003302:	6c42                	ld	s8,16(sp)
    80003304:	6ca2                	ld	s9,8(sp)
    80003306:	6125                	add	sp,sp,96
    80003308:	8082                	ret
    brelse(bp);
    8000330a:	854a                	mv	a0,s2
    8000330c:	00000097          	auipc	ra,0x0
    80003310:	dc8080e7          	jalr	-568(ra) # 800030d4 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003314:	015c87bb          	addw	a5,s9,s5
    80003318:	00078a9b          	sext.w	s5,a5
    8000331c:	004b2703          	lw	a4,4(s6)
    80003320:	06eaf163          	bgeu	s5,a4,80003382 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003324:	41fad79b          	sraw	a5,s5,0x1f
    80003328:	0137d79b          	srlw	a5,a5,0x13
    8000332c:	015787bb          	addw	a5,a5,s5
    80003330:	40d7d79b          	sraw	a5,a5,0xd
    80003334:	01cb2583          	lw	a1,28(s6)
    80003338:	9dbd                	addw	a1,a1,a5
    8000333a:	855e                	mv	a0,s7
    8000333c:	00000097          	auipc	ra,0x0
    80003340:	c68080e7          	jalr	-920(ra) # 80002fa4 <bread>
    80003344:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003346:	004b2503          	lw	a0,4(s6)
    8000334a:	000a849b          	sext.w	s1,s5
    8000334e:	8762                	mv	a4,s8
    80003350:	faa4fde3          	bgeu	s1,a0,8000330a <balloc+0xa6>
      m = 1 << (bi % 8);
    80003354:	00777693          	and	a3,a4,7
    80003358:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    8000335c:	41f7579b          	sraw	a5,a4,0x1f
    80003360:	01d7d79b          	srlw	a5,a5,0x1d
    80003364:	9fb9                	addw	a5,a5,a4
    80003366:	4037d79b          	sraw	a5,a5,0x3
    8000336a:	00f90633          	add	a2,s2,a5
    8000336e:	05864603          	lbu	a2,88(a2)
    80003372:	00c6f5b3          	and	a1,a3,a2
    80003376:	d585                	beqz	a1,8000329e <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003378:	2705                	addw	a4,a4,1
    8000337a:	2485                	addw	s1,s1,1
    8000337c:	fd471ae3          	bne	a4,s4,80003350 <balloc+0xec>
    80003380:	b769                	j	8000330a <balloc+0xa6>
  printf("balloc: out of blocks\n");
    80003382:	00005517          	auipc	a0,0x5
    80003386:	20650513          	add	a0,a0,518 # 80008588 <syscalls+0x100>
    8000338a:	ffffd097          	auipc	ra,0xffffd
    8000338e:	1fc080e7          	jalr	508(ra) # 80000586 <printf>
  return 0;
    80003392:	4481                	li	s1,0
    80003394:	bfa9                	j	800032ee <balloc+0x8a>

0000000080003396 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003396:	7179                	add	sp,sp,-48
    80003398:	f406                	sd	ra,40(sp)
    8000339a:	f022                	sd	s0,32(sp)
    8000339c:	ec26                	sd	s1,24(sp)
    8000339e:	e84a                	sd	s2,16(sp)
    800033a0:	e44e                	sd	s3,8(sp)
    800033a2:	e052                	sd	s4,0(sp)
    800033a4:	1800                	add	s0,sp,48
    800033a6:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800033a8:	47ad                	li	a5,11
    800033aa:	02b7e863          	bltu	a5,a1,800033da <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    800033ae:	02059793          	sll	a5,a1,0x20
    800033b2:	01e7d593          	srl	a1,a5,0x1e
    800033b6:	00b504b3          	add	s1,a0,a1
    800033ba:	0504a903          	lw	s2,80(s1)
    800033be:	06091e63          	bnez	s2,8000343a <bmap+0xa4>
      addr = balloc(ip->dev);
    800033c2:	4108                	lw	a0,0(a0)
    800033c4:	00000097          	auipc	ra,0x0
    800033c8:	ea0080e7          	jalr	-352(ra) # 80003264 <balloc>
    800033cc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    800033d0:	06090563          	beqz	s2,8000343a <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    800033d4:	0524a823          	sw	s2,80(s1)
    800033d8:	a08d                	j	8000343a <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    800033da:	ff45849b          	addw	s1,a1,-12
    800033de:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800033e2:	0ff00793          	li	a5,255
    800033e6:	08e7e563          	bltu	a5,a4,80003470 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    800033ea:	08052903          	lw	s2,128(a0)
    800033ee:	00091d63          	bnez	s2,80003408 <bmap+0x72>
      addr = balloc(ip->dev);
    800033f2:	4108                	lw	a0,0(a0)
    800033f4:	00000097          	auipc	ra,0x0
    800033f8:	e70080e7          	jalr	-400(ra) # 80003264 <balloc>
    800033fc:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003400:	02090d63          	beqz	s2,8000343a <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003404:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003408:	85ca                	mv	a1,s2
    8000340a:	0009a503          	lw	a0,0(s3)
    8000340e:	00000097          	auipc	ra,0x0
    80003412:	b96080e7          	jalr	-1130(ra) # 80002fa4 <bread>
    80003416:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003418:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    8000341c:	02049713          	sll	a4,s1,0x20
    80003420:	01e75593          	srl	a1,a4,0x1e
    80003424:	00b784b3          	add	s1,a5,a1
    80003428:	0004a903          	lw	s2,0(s1)
    8000342c:	02090063          	beqz	s2,8000344c <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003430:	8552                	mv	a0,s4
    80003432:	00000097          	auipc	ra,0x0
    80003436:	ca2080e7          	jalr	-862(ra) # 800030d4 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000343a:	854a                	mv	a0,s2
    8000343c:	70a2                	ld	ra,40(sp)
    8000343e:	7402                	ld	s0,32(sp)
    80003440:	64e2                	ld	s1,24(sp)
    80003442:	6942                	ld	s2,16(sp)
    80003444:	69a2                	ld	s3,8(sp)
    80003446:	6a02                	ld	s4,0(sp)
    80003448:	6145                	add	sp,sp,48
    8000344a:	8082                	ret
      addr = balloc(ip->dev);
    8000344c:	0009a503          	lw	a0,0(s3)
    80003450:	00000097          	auipc	ra,0x0
    80003454:	e14080e7          	jalr	-492(ra) # 80003264 <balloc>
    80003458:	0005091b          	sext.w	s2,a0
      if(addr){
    8000345c:	fc090ae3          	beqz	s2,80003430 <bmap+0x9a>
        a[bn] = addr;
    80003460:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80003464:	8552                	mv	a0,s4
    80003466:	00001097          	auipc	ra,0x1
    8000346a:	ec6080e7          	jalr	-314(ra) # 8000432c <log_write>
    8000346e:	b7c9                	j	80003430 <bmap+0x9a>
  panic("bmap: out of range");
    80003470:	00005517          	auipc	a0,0x5
    80003474:	13050513          	add	a0,a0,304 # 800085a0 <syscalls+0x118>
    80003478:	ffffd097          	auipc	ra,0xffffd
    8000347c:	0c4080e7          	jalr	196(ra) # 8000053c <panic>

0000000080003480 <iget>:
{
    80003480:	7179                	add	sp,sp,-48
    80003482:	f406                	sd	ra,40(sp)
    80003484:	f022                	sd	s0,32(sp)
    80003486:	ec26                	sd	s1,24(sp)
    80003488:	e84a                	sd	s2,16(sp)
    8000348a:	e44e                	sd	s3,8(sp)
    8000348c:	e052                	sd	s4,0(sp)
    8000348e:	1800                	add	s0,sp,48
    80003490:	89aa                	mv	s3,a0
    80003492:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003494:	00193517          	auipc	a0,0x193
    80003498:	1ac50513          	add	a0,a0,428 # 80196640 <itable>
    8000349c:	ffffd097          	auipc	ra,0xffffd
    800034a0:	736080e7          	jalr	1846(ra) # 80000bd2 <acquire>
  empty = 0;
    800034a4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034a6:	00193497          	auipc	s1,0x193
    800034aa:	1b248493          	add	s1,s1,434 # 80196658 <itable+0x18>
    800034ae:	00195697          	auipc	a3,0x195
    800034b2:	c3a68693          	add	a3,a3,-966 # 801980e8 <log>
    800034b6:	a039                	j	800034c4 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034b8:	02090b63          	beqz	s2,800034ee <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    800034bc:	08848493          	add	s1,s1,136
    800034c0:	02d48a63          	beq	s1,a3,800034f4 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800034c4:	449c                	lw	a5,8(s1)
    800034c6:	fef059e3          	blez	a5,800034b8 <iget+0x38>
    800034ca:	4098                	lw	a4,0(s1)
    800034cc:	ff3716e3          	bne	a4,s3,800034b8 <iget+0x38>
    800034d0:	40d8                	lw	a4,4(s1)
    800034d2:	ff4713e3          	bne	a4,s4,800034b8 <iget+0x38>
      ip->ref++;
    800034d6:	2785                	addw	a5,a5,1
    800034d8:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    800034da:	00193517          	auipc	a0,0x193
    800034de:	16650513          	add	a0,a0,358 # 80196640 <itable>
    800034e2:	ffffd097          	auipc	ra,0xffffd
    800034e6:	7a4080e7          	jalr	1956(ra) # 80000c86 <release>
      return ip;
    800034ea:	8926                	mv	s2,s1
    800034ec:	a03d                	j	8000351a <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800034ee:	f7f9                	bnez	a5,800034bc <iget+0x3c>
    800034f0:	8926                	mv	s2,s1
    800034f2:	b7e9                	j	800034bc <iget+0x3c>
  if(empty == 0)
    800034f4:	02090c63          	beqz	s2,8000352c <iget+0xac>
  ip->dev = dev;
    800034f8:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    800034fc:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003500:	4785                	li	a5,1
    80003502:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003506:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000350a:	00193517          	auipc	a0,0x193
    8000350e:	13650513          	add	a0,a0,310 # 80196640 <itable>
    80003512:	ffffd097          	auipc	ra,0xffffd
    80003516:	774080e7          	jalr	1908(ra) # 80000c86 <release>
}
    8000351a:	854a                	mv	a0,s2
    8000351c:	70a2                	ld	ra,40(sp)
    8000351e:	7402                	ld	s0,32(sp)
    80003520:	64e2                	ld	s1,24(sp)
    80003522:	6942                	ld	s2,16(sp)
    80003524:	69a2                	ld	s3,8(sp)
    80003526:	6a02                	ld	s4,0(sp)
    80003528:	6145                	add	sp,sp,48
    8000352a:	8082                	ret
    panic("iget: no inodes");
    8000352c:	00005517          	auipc	a0,0x5
    80003530:	08c50513          	add	a0,a0,140 # 800085b8 <syscalls+0x130>
    80003534:	ffffd097          	auipc	ra,0xffffd
    80003538:	008080e7          	jalr	8(ra) # 8000053c <panic>

000000008000353c <fsinit>:
fsinit(int dev) {
    8000353c:	7179                	add	sp,sp,-48
    8000353e:	f406                	sd	ra,40(sp)
    80003540:	f022                	sd	s0,32(sp)
    80003542:	ec26                	sd	s1,24(sp)
    80003544:	e84a                	sd	s2,16(sp)
    80003546:	e44e                	sd	s3,8(sp)
    80003548:	1800                	add	s0,sp,48
    8000354a:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    8000354c:	4585                	li	a1,1
    8000354e:	00000097          	auipc	ra,0x0
    80003552:	a56080e7          	jalr	-1450(ra) # 80002fa4 <bread>
    80003556:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003558:	00193997          	auipc	s3,0x193
    8000355c:	0c098993          	add	s3,s3,192 # 80196618 <sb>
    80003560:	02800613          	li	a2,40
    80003564:	05850593          	add	a1,a0,88
    80003568:	854e                	mv	a0,s3
    8000356a:	ffffd097          	auipc	ra,0xffffd
    8000356e:	7c0080e7          	jalr	1984(ra) # 80000d2a <memmove>
  brelse(bp);
    80003572:	8526                	mv	a0,s1
    80003574:	00000097          	auipc	ra,0x0
    80003578:	b60080e7          	jalr	-1184(ra) # 800030d4 <brelse>
  if(sb.magic != FSMAGIC)
    8000357c:	0009a703          	lw	a4,0(s3)
    80003580:	102037b7          	lui	a5,0x10203
    80003584:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003588:	02f71263          	bne	a4,a5,800035ac <fsinit+0x70>
  initlog(dev, &sb);
    8000358c:	00193597          	auipc	a1,0x193
    80003590:	08c58593          	add	a1,a1,140 # 80196618 <sb>
    80003594:	854a                	mv	a0,s2
    80003596:	00001097          	auipc	ra,0x1
    8000359a:	b2c080e7          	jalr	-1236(ra) # 800040c2 <initlog>
}
    8000359e:	70a2                	ld	ra,40(sp)
    800035a0:	7402                	ld	s0,32(sp)
    800035a2:	64e2                	ld	s1,24(sp)
    800035a4:	6942                	ld	s2,16(sp)
    800035a6:	69a2                	ld	s3,8(sp)
    800035a8:	6145                	add	sp,sp,48
    800035aa:	8082                	ret
    panic("invalid file system");
    800035ac:	00005517          	auipc	a0,0x5
    800035b0:	01c50513          	add	a0,a0,28 # 800085c8 <syscalls+0x140>
    800035b4:	ffffd097          	auipc	ra,0xffffd
    800035b8:	f88080e7          	jalr	-120(ra) # 8000053c <panic>

00000000800035bc <iinit>:
{
    800035bc:	7179                	add	sp,sp,-48
    800035be:	f406                	sd	ra,40(sp)
    800035c0:	f022                	sd	s0,32(sp)
    800035c2:	ec26                	sd	s1,24(sp)
    800035c4:	e84a                	sd	s2,16(sp)
    800035c6:	e44e                	sd	s3,8(sp)
    800035c8:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    800035ca:	00005597          	auipc	a1,0x5
    800035ce:	01658593          	add	a1,a1,22 # 800085e0 <syscalls+0x158>
    800035d2:	00193517          	auipc	a0,0x193
    800035d6:	06e50513          	add	a0,a0,110 # 80196640 <itable>
    800035da:	ffffd097          	auipc	ra,0xffffd
    800035de:	568080e7          	jalr	1384(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    800035e2:	00193497          	auipc	s1,0x193
    800035e6:	08648493          	add	s1,s1,134 # 80196668 <itable+0x28>
    800035ea:	00195997          	auipc	s3,0x195
    800035ee:	b0e98993          	add	s3,s3,-1266 # 801980f8 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800035f2:	00005917          	auipc	s2,0x5
    800035f6:	ff690913          	add	s2,s2,-10 # 800085e8 <syscalls+0x160>
    800035fa:	85ca                	mv	a1,s2
    800035fc:	8526                	mv	a0,s1
    800035fe:	00001097          	auipc	ra,0x1
    80003602:	e12080e7          	jalr	-494(ra) # 80004410 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003606:	08848493          	add	s1,s1,136
    8000360a:	ff3498e3          	bne	s1,s3,800035fa <iinit+0x3e>
}
    8000360e:	70a2                	ld	ra,40(sp)
    80003610:	7402                	ld	s0,32(sp)
    80003612:	64e2                	ld	s1,24(sp)
    80003614:	6942                	ld	s2,16(sp)
    80003616:	69a2                	ld	s3,8(sp)
    80003618:	6145                	add	sp,sp,48
    8000361a:	8082                	ret

000000008000361c <ialloc>:
{
    8000361c:	7139                	add	sp,sp,-64
    8000361e:	fc06                	sd	ra,56(sp)
    80003620:	f822                	sd	s0,48(sp)
    80003622:	f426                	sd	s1,40(sp)
    80003624:	f04a                	sd	s2,32(sp)
    80003626:	ec4e                	sd	s3,24(sp)
    80003628:	e852                	sd	s4,16(sp)
    8000362a:	e456                	sd	s5,8(sp)
    8000362c:	e05a                	sd	s6,0(sp)
    8000362e:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    80003630:	00193717          	auipc	a4,0x193
    80003634:	ff472703          	lw	a4,-12(a4) # 80196624 <sb+0xc>
    80003638:	4785                	li	a5,1
    8000363a:	04e7f863          	bgeu	a5,a4,8000368a <ialloc+0x6e>
    8000363e:	8aaa                	mv	s5,a0
    80003640:	8b2e                	mv	s6,a1
    80003642:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    80003644:	00193a17          	auipc	s4,0x193
    80003648:	fd4a0a13          	add	s4,s4,-44 # 80196618 <sb>
    8000364c:	00495593          	srl	a1,s2,0x4
    80003650:	018a2783          	lw	a5,24(s4)
    80003654:	9dbd                	addw	a1,a1,a5
    80003656:	8556                	mv	a0,s5
    80003658:	00000097          	auipc	ra,0x0
    8000365c:	94c080e7          	jalr	-1716(ra) # 80002fa4 <bread>
    80003660:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003662:	05850993          	add	s3,a0,88
    80003666:	00f97793          	and	a5,s2,15
    8000366a:	079a                	sll	a5,a5,0x6
    8000366c:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    8000366e:	00099783          	lh	a5,0(s3)
    80003672:	cf9d                	beqz	a5,800036b0 <ialloc+0x94>
    brelse(bp);
    80003674:	00000097          	auipc	ra,0x0
    80003678:	a60080e7          	jalr	-1440(ra) # 800030d4 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000367c:	0905                	add	s2,s2,1
    8000367e:	00ca2703          	lw	a4,12(s4)
    80003682:	0009079b          	sext.w	a5,s2
    80003686:	fce7e3e3          	bltu	a5,a4,8000364c <ialloc+0x30>
  printf("ialloc: no inodes\n");
    8000368a:	00005517          	auipc	a0,0x5
    8000368e:	f6650513          	add	a0,a0,-154 # 800085f0 <syscalls+0x168>
    80003692:	ffffd097          	auipc	ra,0xffffd
    80003696:	ef4080e7          	jalr	-268(ra) # 80000586 <printf>
  return 0;
    8000369a:	4501                	li	a0,0
}
    8000369c:	70e2                	ld	ra,56(sp)
    8000369e:	7442                	ld	s0,48(sp)
    800036a0:	74a2                	ld	s1,40(sp)
    800036a2:	7902                	ld	s2,32(sp)
    800036a4:	69e2                	ld	s3,24(sp)
    800036a6:	6a42                	ld	s4,16(sp)
    800036a8:	6aa2                	ld	s5,8(sp)
    800036aa:	6b02                	ld	s6,0(sp)
    800036ac:	6121                	add	sp,sp,64
    800036ae:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800036b0:	04000613          	li	a2,64
    800036b4:	4581                	li	a1,0
    800036b6:	854e                	mv	a0,s3
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	616080e7          	jalr	1558(ra) # 80000cce <memset>
      dip->type = type;
    800036c0:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800036c4:	8526                	mv	a0,s1
    800036c6:	00001097          	auipc	ra,0x1
    800036ca:	c66080e7          	jalr	-922(ra) # 8000432c <log_write>
      brelse(bp);
    800036ce:	8526                	mv	a0,s1
    800036d0:	00000097          	auipc	ra,0x0
    800036d4:	a04080e7          	jalr	-1532(ra) # 800030d4 <brelse>
      return iget(dev, inum);
    800036d8:	0009059b          	sext.w	a1,s2
    800036dc:	8556                	mv	a0,s5
    800036de:	00000097          	auipc	ra,0x0
    800036e2:	da2080e7          	jalr	-606(ra) # 80003480 <iget>
    800036e6:	bf5d                	j	8000369c <ialloc+0x80>

00000000800036e8 <iupdate>:
{
    800036e8:	1101                	add	sp,sp,-32
    800036ea:	ec06                	sd	ra,24(sp)
    800036ec:	e822                	sd	s0,16(sp)
    800036ee:	e426                	sd	s1,8(sp)
    800036f0:	e04a                	sd	s2,0(sp)
    800036f2:	1000                	add	s0,sp,32
    800036f4:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800036f6:	415c                	lw	a5,4(a0)
    800036f8:	0047d79b          	srlw	a5,a5,0x4
    800036fc:	00193597          	auipc	a1,0x193
    80003700:	f345a583          	lw	a1,-204(a1) # 80196630 <sb+0x18>
    80003704:	9dbd                	addw	a1,a1,a5
    80003706:	4108                	lw	a0,0(a0)
    80003708:	00000097          	auipc	ra,0x0
    8000370c:	89c080e7          	jalr	-1892(ra) # 80002fa4 <bread>
    80003710:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003712:	05850793          	add	a5,a0,88
    80003716:	40d8                	lw	a4,4(s1)
    80003718:	8b3d                	and	a4,a4,15
    8000371a:	071a                	sll	a4,a4,0x6
    8000371c:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000371e:	04449703          	lh	a4,68(s1)
    80003722:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003726:	04649703          	lh	a4,70(s1)
    8000372a:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000372e:	04849703          	lh	a4,72(s1)
    80003732:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    80003736:	04a49703          	lh	a4,74(s1)
    8000373a:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    8000373e:	44f8                	lw	a4,76(s1)
    80003740:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003742:	03400613          	li	a2,52
    80003746:	05048593          	add	a1,s1,80
    8000374a:	00c78513          	add	a0,a5,12
    8000374e:	ffffd097          	auipc	ra,0xffffd
    80003752:	5dc080e7          	jalr	1500(ra) # 80000d2a <memmove>
  log_write(bp);
    80003756:	854a                	mv	a0,s2
    80003758:	00001097          	auipc	ra,0x1
    8000375c:	bd4080e7          	jalr	-1068(ra) # 8000432c <log_write>
  brelse(bp);
    80003760:	854a                	mv	a0,s2
    80003762:	00000097          	auipc	ra,0x0
    80003766:	972080e7          	jalr	-1678(ra) # 800030d4 <brelse>
}
    8000376a:	60e2                	ld	ra,24(sp)
    8000376c:	6442                	ld	s0,16(sp)
    8000376e:	64a2                	ld	s1,8(sp)
    80003770:	6902                	ld	s2,0(sp)
    80003772:	6105                	add	sp,sp,32
    80003774:	8082                	ret

0000000080003776 <idup>:
{
    80003776:	1101                	add	sp,sp,-32
    80003778:	ec06                	sd	ra,24(sp)
    8000377a:	e822                	sd	s0,16(sp)
    8000377c:	e426                	sd	s1,8(sp)
    8000377e:	1000                	add	s0,sp,32
    80003780:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003782:	00193517          	auipc	a0,0x193
    80003786:	ebe50513          	add	a0,a0,-322 # 80196640 <itable>
    8000378a:	ffffd097          	auipc	ra,0xffffd
    8000378e:	448080e7          	jalr	1096(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003792:	449c                	lw	a5,8(s1)
    80003794:	2785                	addw	a5,a5,1
    80003796:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003798:	00193517          	auipc	a0,0x193
    8000379c:	ea850513          	add	a0,a0,-344 # 80196640 <itable>
    800037a0:	ffffd097          	auipc	ra,0xffffd
    800037a4:	4e6080e7          	jalr	1254(ra) # 80000c86 <release>
}
    800037a8:	8526                	mv	a0,s1
    800037aa:	60e2                	ld	ra,24(sp)
    800037ac:	6442                	ld	s0,16(sp)
    800037ae:	64a2                	ld	s1,8(sp)
    800037b0:	6105                	add	sp,sp,32
    800037b2:	8082                	ret

00000000800037b4 <ilock>:
{
    800037b4:	1101                	add	sp,sp,-32
    800037b6:	ec06                	sd	ra,24(sp)
    800037b8:	e822                	sd	s0,16(sp)
    800037ba:	e426                	sd	s1,8(sp)
    800037bc:	e04a                	sd	s2,0(sp)
    800037be:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    800037c0:	c115                	beqz	a0,800037e4 <ilock+0x30>
    800037c2:	84aa                	mv	s1,a0
    800037c4:	451c                	lw	a5,8(a0)
    800037c6:	00f05f63          	blez	a5,800037e4 <ilock+0x30>
  acquiresleep(&ip->lock);
    800037ca:	0541                	add	a0,a0,16
    800037cc:	00001097          	auipc	ra,0x1
    800037d0:	c7e080e7          	jalr	-898(ra) # 8000444a <acquiresleep>
  if(ip->valid == 0){
    800037d4:	40bc                	lw	a5,64(s1)
    800037d6:	cf99                	beqz	a5,800037f4 <ilock+0x40>
}
    800037d8:	60e2                	ld	ra,24(sp)
    800037da:	6442                	ld	s0,16(sp)
    800037dc:	64a2                	ld	s1,8(sp)
    800037de:	6902                	ld	s2,0(sp)
    800037e0:	6105                	add	sp,sp,32
    800037e2:	8082                	ret
    panic("ilock");
    800037e4:	00005517          	auipc	a0,0x5
    800037e8:	e2450513          	add	a0,a0,-476 # 80008608 <syscalls+0x180>
    800037ec:	ffffd097          	auipc	ra,0xffffd
    800037f0:	d50080e7          	jalr	-688(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800037f4:	40dc                	lw	a5,4(s1)
    800037f6:	0047d79b          	srlw	a5,a5,0x4
    800037fa:	00193597          	auipc	a1,0x193
    800037fe:	e365a583          	lw	a1,-458(a1) # 80196630 <sb+0x18>
    80003802:	9dbd                	addw	a1,a1,a5
    80003804:	4088                	lw	a0,0(s1)
    80003806:	fffff097          	auipc	ra,0xfffff
    8000380a:	79e080e7          	jalr	1950(ra) # 80002fa4 <bread>
    8000380e:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003810:	05850593          	add	a1,a0,88
    80003814:	40dc                	lw	a5,4(s1)
    80003816:	8bbd                	and	a5,a5,15
    80003818:	079a                	sll	a5,a5,0x6
    8000381a:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000381c:	00059783          	lh	a5,0(a1)
    80003820:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003824:	00259783          	lh	a5,2(a1)
    80003828:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000382c:	00459783          	lh	a5,4(a1)
    80003830:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003834:	00659783          	lh	a5,6(a1)
    80003838:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    8000383c:	459c                	lw	a5,8(a1)
    8000383e:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003840:	03400613          	li	a2,52
    80003844:	05b1                	add	a1,a1,12
    80003846:	05048513          	add	a0,s1,80
    8000384a:	ffffd097          	auipc	ra,0xffffd
    8000384e:	4e0080e7          	jalr	1248(ra) # 80000d2a <memmove>
    brelse(bp);
    80003852:	854a                	mv	a0,s2
    80003854:	00000097          	auipc	ra,0x0
    80003858:	880080e7          	jalr	-1920(ra) # 800030d4 <brelse>
    ip->valid = 1;
    8000385c:	4785                	li	a5,1
    8000385e:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80003860:	04449783          	lh	a5,68(s1)
    80003864:	fbb5                	bnez	a5,800037d8 <ilock+0x24>
      panic("ilock: no type");
    80003866:	00005517          	auipc	a0,0x5
    8000386a:	daa50513          	add	a0,a0,-598 # 80008610 <syscalls+0x188>
    8000386e:	ffffd097          	auipc	ra,0xffffd
    80003872:	cce080e7          	jalr	-818(ra) # 8000053c <panic>

0000000080003876 <iunlock>:
{
    80003876:	1101                	add	sp,sp,-32
    80003878:	ec06                	sd	ra,24(sp)
    8000387a:	e822                	sd	s0,16(sp)
    8000387c:	e426                	sd	s1,8(sp)
    8000387e:	e04a                	sd	s2,0(sp)
    80003880:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80003882:	c905                	beqz	a0,800038b2 <iunlock+0x3c>
    80003884:	84aa                	mv	s1,a0
    80003886:	01050913          	add	s2,a0,16
    8000388a:	854a                	mv	a0,s2
    8000388c:	00001097          	auipc	ra,0x1
    80003890:	c58080e7          	jalr	-936(ra) # 800044e4 <holdingsleep>
    80003894:	cd19                	beqz	a0,800038b2 <iunlock+0x3c>
    80003896:	449c                	lw	a5,8(s1)
    80003898:	00f05d63          	blez	a5,800038b2 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000389c:	854a                	mv	a0,s2
    8000389e:	00001097          	auipc	ra,0x1
    800038a2:	c02080e7          	jalr	-1022(ra) # 800044a0 <releasesleep>
}
    800038a6:	60e2                	ld	ra,24(sp)
    800038a8:	6442                	ld	s0,16(sp)
    800038aa:	64a2                	ld	s1,8(sp)
    800038ac:	6902                	ld	s2,0(sp)
    800038ae:	6105                	add	sp,sp,32
    800038b0:	8082                	ret
    panic("iunlock");
    800038b2:	00005517          	auipc	a0,0x5
    800038b6:	d6e50513          	add	a0,a0,-658 # 80008620 <syscalls+0x198>
    800038ba:	ffffd097          	auipc	ra,0xffffd
    800038be:	c82080e7          	jalr	-894(ra) # 8000053c <panic>

00000000800038c2 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    800038c2:	7179                	add	sp,sp,-48
    800038c4:	f406                	sd	ra,40(sp)
    800038c6:	f022                	sd	s0,32(sp)
    800038c8:	ec26                	sd	s1,24(sp)
    800038ca:	e84a                	sd	s2,16(sp)
    800038cc:	e44e                	sd	s3,8(sp)
    800038ce:	e052                	sd	s4,0(sp)
    800038d0:	1800                	add	s0,sp,48
    800038d2:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    800038d4:	05050493          	add	s1,a0,80
    800038d8:	08050913          	add	s2,a0,128
    800038dc:	a021                	j	800038e4 <itrunc+0x22>
    800038de:	0491                	add	s1,s1,4
    800038e0:	01248d63          	beq	s1,s2,800038fa <itrunc+0x38>
    if(ip->addrs[i]){
    800038e4:	408c                	lw	a1,0(s1)
    800038e6:	dde5                	beqz	a1,800038de <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    800038e8:	0009a503          	lw	a0,0(s3)
    800038ec:	00000097          	auipc	ra,0x0
    800038f0:	8fc080e7          	jalr	-1796(ra) # 800031e8 <bfree>
      ip->addrs[i] = 0;
    800038f4:	0004a023          	sw	zero,0(s1)
    800038f8:	b7dd                	j	800038de <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    800038fa:	0809a583          	lw	a1,128(s3)
    800038fe:	e185                	bnez	a1,8000391e <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003900:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003904:	854e                	mv	a0,s3
    80003906:	00000097          	auipc	ra,0x0
    8000390a:	de2080e7          	jalr	-542(ra) # 800036e8 <iupdate>
}
    8000390e:	70a2                	ld	ra,40(sp)
    80003910:	7402                	ld	s0,32(sp)
    80003912:	64e2                	ld	s1,24(sp)
    80003914:	6942                	ld	s2,16(sp)
    80003916:	69a2                	ld	s3,8(sp)
    80003918:	6a02                	ld	s4,0(sp)
    8000391a:	6145                	add	sp,sp,48
    8000391c:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000391e:	0009a503          	lw	a0,0(s3)
    80003922:	fffff097          	auipc	ra,0xfffff
    80003926:	682080e7          	jalr	1666(ra) # 80002fa4 <bread>
    8000392a:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000392c:	05850493          	add	s1,a0,88
    80003930:	45850913          	add	s2,a0,1112
    80003934:	a021                	j	8000393c <itrunc+0x7a>
    80003936:	0491                	add	s1,s1,4
    80003938:	01248b63          	beq	s1,s2,8000394e <itrunc+0x8c>
      if(a[j])
    8000393c:	408c                	lw	a1,0(s1)
    8000393e:	dde5                	beqz	a1,80003936 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003940:	0009a503          	lw	a0,0(s3)
    80003944:	00000097          	auipc	ra,0x0
    80003948:	8a4080e7          	jalr	-1884(ra) # 800031e8 <bfree>
    8000394c:	b7ed                	j	80003936 <itrunc+0x74>
    brelse(bp);
    8000394e:	8552                	mv	a0,s4
    80003950:	fffff097          	auipc	ra,0xfffff
    80003954:	784080e7          	jalr	1924(ra) # 800030d4 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003958:	0809a583          	lw	a1,128(s3)
    8000395c:	0009a503          	lw	a0,0(s3)
    80003960:	00000097          	auipc	ra,0x0
    80003964:	888080e7          	jalr	-1912(ra) # 800031e8 <bfree>
    ip->addrs[NDIRECT] = 0;
    80003968:	0809a023          	sw	zero,128(s3)
    8000396c:	bf51                	j	80003900 <itrunc+0x3e>

000000008000396e <iput>:
{
    8000396e:	1101                	add	sp,sp,-32
    80003970:	ec06                	sd	ra,24(sp)
    80003972:	e822                	sd	s0,16(sp)
    80003974:	e426                	sd	s1,8(sp)
    80003976:	e04a                	sd	s2,0(sp)
    80003978:	1000                	add	s0,sp,32
    8000397a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000397c:	00193517          	auipc	a0,0x193
    80003980:	cc450513          	add	a0,a0,-828 # 80196640 <itable>
    80003984:	ffffd097          	auipc	ra,0xffffd
    80003988:	24e080e7          	jalr	590(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000398c:	4498                	lw	a4,8(s1)
    8000398e:	4785                	li	a5,1
    80003990:	02f70363          	beq	a4,a5,800039b6 <iput+0x48>
  ip->ref--;
    80003994:	449c                	lw	a5,8(s1)
    80003996:	37fd                	addw	a5,a5,-1
    80003998:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000399a:	00193517          	auipc	a0,0x193
    8000399e:	ca650513          	add	a0,a0,-858 # 80196640 <itable>
    800039a2:	ffffd097          	auipc	ra,0xffffd
    800039a6:	2e4080e7          	jalr	740(ra) # 80000c86 <release>
}
    800039aa:	60e2                	ld	ra,24(sp)
    800039ac:	6442                	ld	s0,16(sp)
    800039ae:	64a2                	ld	s1,8(sp)
    800039b0:	6902                	ld	s2,0(sp)
    800039b2:	6105                	add	sp,sp,32
    800039b4:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800039b6:	40bc                	lw	a5,64(s1)
    800039b8:	dff1                	beqz	a5,80003994 <iput+0x26>
    800039ba:	04a49783          	lh	a5,74(s1)
    800039be:	fbf9                	bnez	a5,80003994 <iput+0x26>
    acquiresleep(&ip->lock);
    800039c0:	01048913          	add	s2,s1,16
    800039c4:	854a                	mv	a0,s2
    800039c6:	00001097          	auipc	ra,0x1
    800039ca:	a84080e7          	jalr	-1404(ra) # 8000444a <acquiresleep>
    release(&itable.lock);
    800039ce:	00193517          	auipc	a0,0x193
    800039d2:	c7250513          	add	a0,a0,-910 # 80196640 <itable>
    800039d6:	ffffd097          	auipc	ra,0xffffd
    800039da:	2b0080e7          	jalr	688(ra) # 80000c86 <release>
    itrunc(ip);
    800039de:	8526                	mv	a0,s1
    800039e0:	00000097          	auipc	ra,0x0
    800039e4:	ee2080e7          	jalr	-286(ra) # 800038c2 <itrunc>
    ip->type = 0;
    800039e8:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    800039ec:	8526                	mv	a0,s1
    800039ee:	00000097          	auipc	ra,0x0
    800039f2:	cfa080e7          	jalr	-774(ra) # 800036e8 <iupdate>
    ip->valid = 0;
    800039f6:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    800039fa:	854a                	mv	a0,s2
    800039fc:	00001097          	auipc	ra,0x1
    80003a00:	aa4080e7          	jalr	-1372(ra) # 800044a0 <releasesleep>
    acquire(&itable.lock);
    80003a04:	00193517          	auipc	a0,0x193
    80003a08:	c3c50513          	add	a0,a0,-964 # 80196640 <itable>
    80003a0c:	ffffd097          	auipc	ra,0xffffd
    80003a10:	1c6080e7          	jalr	454(ra) # 80000bd2 <acquire>
    80003a14:	b741                	j	80003994 <iput+0x26>

0000000080003a16 <iunlockput>:
{
    80003a16:	1101                	add	sp,sp,-32
    80003a18:	ec06                	sd	ra,24(sp)
    80003a1a:	e822                	sd	s0,16(sp)
    80003a1c:	e426                	sd	s1,8(sp)
    80003a1e:	1000                	add	s0,sp,32
    80003a20:	84aa                	mv	s1,a0
  iunlock(ip);
    80003a22:	00000097          	auipc	ra,0x0
    80003a26:	e54080e7          	jalr	-428(ra) # 80003876 <iunlock>
  iput(ip);
    80003a2a:	8526                	mv	a0,s1
    80003a2c:	00000097          	auipc	ra,0x0
    80003a30:	f42080e7          	jalr	-190(ra) # 8000396e <iput>
}
    80003a34:	60e2                	ld	ra,24(sp)
    80003a36:	6442                	ld	s0,16(sp)
    80003a38:	64a2                	ld	s1,8(sp)
    80003a3a:	6105                	add	sp,sp,32
    80003a3c:	8082                	ret

0000000080003a3e <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003a3e:	1141                	add	sp,sp,-16
    80003a40:	e422                	sd	s0,8(sp)
    80003a42:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    80003a44:	411c                	lw	a5,0(a0)
    80003a46:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003a48:	415c                	lw	a5,4(a0)
    80003a4a:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003a4c:	04451783          	lh	a5,68(a0)
    80003a50:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003a54:	04a51783          	lh	a5,74(a0)
    80003a58:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003a5c:	04c56783          	lwu	a5,76(a0)
    80003a60:	e99c                	sd	a5,16(a1)
}
    80003a62:	6422                	ld	s0,8(sp)
    80003a64:	0141                	add	sp,sp,16
    80003a66:	8082                	ret

0000000080003a68 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003a68:	457c                	lw	a5,76(a0)
    80003a6a:	0ed7e963          	bltu	a5,a3,80003b5c <readi+0xf4>
{
    80003a6e:	7159                	add	sp,sp,-112
    80003a70:	f486                	sd	ra,104(sp)
    80003a72:	f0a2                	sd	s0,96(sp)
    80003a74:	eca6                	sd	s1,88(sp)
    80003a76:	e8ca                	sd	s2,80(sp)
    80003a78:	e4ce                	sd	s3,72(sp)
    80003a7a:	e0d2                	sd	s4,64(sp)
    80003a7c:	fc56                	sd	s5,56(sp)
    80003a7e:	f85a                	sd	s6,48(sp)
    80003a80:	f45e                	sd	s7,40(sp)
    80003a82:	f062                	sd	s8,32(sp)
    80003a84:	ec66                	sd	s9,24(sp)
    80003a86:	e86a                	sd	s10,16(sp)
    80003a88:	e46e                	sd	s11,8(sp)
    80003a8a:	1880                	add	s0,sp,112
    80003a8c:	8b2a                	mv	s6,a0
    80003a8e:	8bae                	mv	s7,a1
    80003a90:	8a32                	mv	s4,a2
    80003a92:	84b6                	mv	s1,a3
    80003a94:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a96:	9f35                	addw	a4,a4,a3
    return 0;
    80003a98:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a9a:	0ad76063          	bltu	a4,a3,80003b3a <readi+0xd2>
  if(off + n > ip->size)
    80003a9e:	00e7f463          	bgeu	a5,a4,80003aa6 <readi+0x3e>
    n = ip->size - off;
    80003aa2:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003aa6:	0a0a8963          	beqz	s5,80003b58 <readi+0xf0>
    80003aaa:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003aac:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003ab0:	5c7d                	li	s8,-1
    80003ab2:	a82d                	j	80003aec <readi+0x84>
    80003ab4:	020d1d93          	sll	s11,s10,0x20
    80003ab8:	020ddd93          	srl	s11,s11,0x20
    80003abc:	05890613          	add	a2,s2,88
    80003ac0:	86ee                	mv	a3,s11
    80003ac2:	963a                	add	a2,a2,a4
    80003ac4:	85d2                	mv	a1,s4
    80003ac6:	855e                	mv	a0,s7
    80003ac8:	fffff097          	auipc	ra,0xfffff
    80003acc:	acc080e7          	jalr	-1332(ra) # 80002594 <either_copyout>
    80003ad0:	05850d63          	beq	a0,s8,80003b2a <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003ad4:	854a                	mv	a0,s2
    80003ad6:	fffff097          	auipc	ra,0xfffff
    80003ada:	5fe080e7          	jalr	1534(ra) # 800030d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ade:	013d09bb          	addw	s3,s10,s3
    80003ae2:	009d04bb          	addw	s1,s10,s1
    80003ae6:	9a6e                	add	s4,s4,s11
    80003ae8:	0559f763          	bgeu	s3,s5,80003b36 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003aec:	00a4d59b          	srlw	a1,s1,0xa
    80003af0:	855a                	mv	a0,s6
    80003af2:	00000097          	auipc	ra,0x0
    80003af6:	8a4080e7          	jalr	-1884(ra) # 80003396 <bmap>
    80003afa:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003afe:	cd85                	beqz	a1,80003b36 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003b00:	000b2503          	lw	a0,0(s6)
    80003b04:	fffff097          	auipc	ra,0xfffff
    80003b08:	4a0080e7          	jalr	1184(ra) # 80002fa4 <bread>
    80003b0c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b0e:	3ff4f713          	and	a4,s1,1023
    80003b12:	40ec87bb          	subw	a5,s9,a4
    80003b16:	413a86bb          	subw	a3,s5,s3
    80003b1a:	8d3e                	mv	s10,a5
    80003b1c:	2781                	sext.w	a5,a5
    80003b1e:	0006861b          	sext.w	a2,a3
    80003b22:	f8f679e3          	bgeu	a2,a5,80003ab4 <readi+0x4c>
    80003b26:	8d36                	mv	s10,a3
    80003b28:	b771                	j	80003ab4 <readi+0x4c>
      brelse(bp);
    80003b2a:	854a                	mv	a0,s2
    80003b2c:	fffff097          	auipc	ra,0xfffff
    80003b30:	5a8080e7          	jalr	1448(ra) # 800030d4 <brelse>
      tot = -1;
    80003b34:	59fd                	li	s3,-1
  }
  return tot;
    80003b36:	0009851b          	sext.w	a0,s3
}
    80003b3a:	70a6                	ld	ra,104(sp)
    80003b3c:	7406                	ld	s0,96(sp)
    80003b3e:	64e6                	ld	s1,88(sp)
    80003b40:	6946                	ld	s2,80(sp)
    80003b42:	69a6                	ld	s3,72(sp)
    80003b44:	6a06                	ld	s4,64(sp)
    80003b46:	7ae2                	ld	s5,56(sp)
    80003b48:	7b42                	ld	s6,48(sp)
    80003b4a:	7ba2                	ld	s7,40(sp)
    80003b4c:	7c02                	ld	s8,32(sp)
    80003b4e:	6ce2                	ld	s9,24(sp)
    80003b50:	6d42                	ld	s10,16(sp)
    80003b52:	6da2                	ld	s11,8(sp)
    80003b54:	6165                	add	sp,sp,112
    80003b56:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003b58:	89d6                	mv	s3,s5
    80003b5a:	bff1                	j	80003b36 <readi+0xce>
    return 0;
    80003b5c:	4501                	li	a0,0
}
    80003b5e:	8082                	ret

0000000080003b60 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003b60:	457c                	lw	a5,76(a0)
    80003b62:	10d7e863          	bltu	a5,a3,80003c72 <writei+0x112>
{
    80003b66:	7159                	add	sp,sp,-112
    80003b68:	f486                	sd	ra,104(sp)
    80003b6a:	f0a2                	sd	s0,96(sp)
    80003b6c:	eca6                	sd	s1,88(sp)
    80003b6e:	e8ca                	sd	s2,80(sp)
    80003b70:	e4ce                	sd	s3,72(sp)
    80003b72:	e0d2                	sd	s4,64(sp)
    80003b74:	fc56                	sd	s5,56(sp)
    80003b76:	f85a                	sd	s6,48(sp)
    80003b78:	f45e                	sd	s7,40(sp)
    80003b7a:	f062                	sd	s8,32(sp)
    80003b7c:	ec66                	sd	s9,24(sp)
    80003b7e:	e86a                	sd	s10,16(sp)
    80003b80:	e46e                	sd	s11,8(sp)
    80003b82:	1880                	add	s0,sp,112
    80003b84:	8aaa                	mv	s5,a0
    80003b86:	8bae                	mv	s7,a1
    80003b88:	8a32                	mv	s4,a2
    80003b8a:	8936                	mv	s2,a3
    80003b8c:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b8e:	00e687bb          	addw	a5,a3,a4
    80003b92:	0ed7e263          	bltu	a5,a3,80003c76 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b96:	00043737          	lui	a4,0x43
    80003b9a:	0ef76063          	bltu	a4,a5,80003c7a <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b9e:	0c0b0863          	beqz	s6,80003c6e <writei+0x10e>
    80003ba2:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003ba4:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003ba8:	5c7d                	li	s8,-1
    80003baa:	a091                	j	80003bee <writei+0x8e>
    80003bac:	020d1d93          	sll	s11,s10,0x20
    80003bb0:	020ddd93          	srl	s11,s11,0x20
    80003bb4:	05848513          	add	a0,s1,88
    80003bb8:	86ee                	mv	a3,s11
    80003bba:	8652                	mv	a2,s4
    80003bbc:	85de                	mv	a1,s7
    80003bbe:	953a                	add	a0,a0,a4
    80003bc0:	fffff097          	auipc	ra,0xfffff
    80003bc4:	a2a080e7          	jalr	-1494(ra) # 800025ea <either_copyin>
    80003bc8:	07850263          	beq	a0,s8,80003c2c <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003bcc:	8526                	mv	a0,s1
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	75e080e7          	jalr	1886(ra) # 8000432c <log_write>
    brelse(bp);
    80003bd6:	8526                	mv	a0,s1
    80003bd8:	fffff097          	auipc	ra,0xfffff
    80003bdc:	4fc080e7          	jalr	1276(ra) # 800030d4 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003be0:	013d09bb          	addw	s3,s10,s3
    80003be4:	012d093b          	addw	s2,s10,s2
    80003be8:	9a6e                	add	s4,s4,s11
    80003bea:	0569f663          	bgeu	s3,s6,80003c36 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003bee:	00a9559b          	srlw	a1,s2,0xa
    80003bf2:	8556                	mv	a0,s5
    80003bf4:	fffff097          	auipc	ra,0xfffff
    80003bf8:	7a2080e7          	jalr	1954(ra) # 80003396 <bmap>
    80003bfc:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c00:	c99d                	beqz	a1,80003c36 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003c02:	000aa503          	lw	a0,0(s5)
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	39e080e7          	jalr	926(ra) # 80002fa4 <bread>
    80003c0e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c10:	3ff97713          	and	a4,s2,1023
    80003c14:	40ec87bb          	subw	a5,s9,a4
    80003c18:	413b06bb          	subw	a3,s6,s3
    80003c1c:	8d3e                	mv	s10,a5
    80003c1e:	2781                	sext.w	a5,a5
    80003c20:	0006861b          	sext.w	a2,a3
    80003c24:	f8f674e3          	bgeu	a2,a5,80003bac <writei+0x4c>
    80003c28:	8d36                	mv	s10,a3
    80003c2a:	b749                	j	80003bac <writei+0x4c>
      brelse(bp);
    80003c2c:	8526                	mv	a0,s1
    80003c2e:	fffff097          	auipc	ra,0xfffff
    80003c32:	4a6080e7          	jalr	1190(ra) # 800030d4 <brelse>
  }

  if(off > ip->size)
    80003c36:	04caa783          	lw	a5,76(s5)
    80003c3a:	0127f463          	bgeu	a5,s2,80003c42 <writei+0xe2>
    ip->size = off;
    80003c3e:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003c42:	8556                	mv	a0,s5
    80003c44:	00000097          	auipc	ra,0x0
    80003c48:	aa4080e7          	jalr	-1372(ra) # 800036e8 <iupdate>

  return tot;
    80003c4c:	0009851b          	sext.w	a0,s3
}
    80003c50:	70a6                	ld	ra,104(sp)
    80003c52:	7406                	ld	s0,96(sp)
    80003c54:	64e6                	ld	s1,88(sp)
    80003c56:	6946                	ld	s2,80(sp)
    80003c58:	69a6                	ld	s3,72(sp)
    80003c5a:	6a06                	ld	s4,64(sp)
    80003c5c:	7ae2                	ld	s5,56(sp)
    80003c5e:	7b42                	ld	s6,48(sp)
    80003c60:	7ba2                	ld	s7,40(sp)
    80003c62:	7c02                	ld	s8,32(sp)
    80003c64:	6ce2                	ld	s9,24(sp)
    80003c66:	6d42                	ld	s10,16(sp)
    80003c68:	6da2                	ld	s11,8(sp)
    80003c6a:	6165                	add	sp,sp,112
    80003c6c:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003c6e:	89da                	mv	s3,s6
    80003c70:	bfc9                	j	80003c42 <writei+0xe2>
    return -1;
    80003c72:	557d                	li	a0,-1
}
    80003c74:	8082                	ret
    return -1;
    80003c76:	557d                	li	a0,-1
    80003c78:	bfe1                	j	80003c50 <writei+0xf0>
    return -1;
    80003c7a:	557d                	li	a0,-1
    80003c7c:	bfd1                	j	80003c50 <writei+0xf0>

0000000080003c7e <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c7e:	1141                	add	sp,sp,-16
    80003c80:	e406                	sd	ra,8(sp)
    80003c82:	e022                	sd	s0,0(sp)
    80003c84:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c86:	4639                	li	a2,14
    80003c88:	ffffd097          	auipc	ra,0xffffd
    80003c8c:	116080e7          	jalr	278(ra) # 80000d9e <strncmp>
}
    80003c90:	60a2                	ld	ra,8(sp)
    80003c92:	6402                	ld	s0,0(sp)
    80003c94:	0141                	add	sp,sp,16
    80003c96:	8082                	ret

0000000080003c98 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c98:	7139                	add	sp,sp,-64
    80003c9a:	fc06                	sd	ra,56(sp)
    80003c9c:	f822                	sd	s0,48(sp)
    80003c9e:	f426                	sd	s1,40(sp)
    80003ca0:	f04a                	sd	s2,32(sp)
    80003ca2:	ec4e                	sd	s3,24(sp)
    80003ca4:	e852                	sd	s4,16(sp)
    80003ca6:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003ca8:	04451703          	lh	a4,68(a0)
    80003cac:	4785                	li	a5,1
    80003cae:	00f71a63          	bne	a4,a5,80003cc2 <dirlookup+0x2a>
    80003cb2:	892a                	mv	s2,a0
    80003cb4:	89ae                	mv	s3,a1
    80003cb6:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cb8:	457c                	lw	a5,76(a0)
    80003cba:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003cbc:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003cbe:	e79d                	bnez	a5,80003cec <dirlookup+0x54>
    80003cc0:	a8a5                	j	80003d38 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003cc2:	00005517          	auipc	a0,0x5
    80003cc6:	96650513          	add	a0,a0,-1690 # 80008628 <syscalls+0x1a0>
    80003cca:	ffffd097          	auipc	ra,0xffffd
    80003cce:	872080e7          	jalr	-1934(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003cd2:	00005517          	auipc	a0,0x5
    80003cd6:	96e50513          	add	a0,a0,-1682 # 80008640 <syscalls+0x1b8>
    80003cda:	ffffd097          	auipc	ra,0xffffd
    80003cde:	862080e7          	jalr	-1950(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ce2:	24c1                	addw	s1,s1,16
    80003ce4:	04c92783          	lw	a5,76(s2)
    80003ce8:	04f4f763          	bgeu	s1,a5,80003d36 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003cec:	4741                	li	a4,16
    80003cee:	86a6                	mv	a3,s1
    80003cf0:	fc040613          	add	a2,s0,-64
    80003cf4:	4581                	li	a1,0
    80003cf6:	854a                	mv	a0,s2
    80003cf8:	00000097          	auipc	ra,0x0
    80003cfc:	d70080e7          	jalr	-656(ra) # 80003a68 <readi>
    80003d00:	47c1                	li	a5,16
    80003d02:	fcf518e3          	bne	a0,a5,80003cd2 <dirlookup+0x3a>
    if(de.inum == 0)
    80003d06:	fc045783          	lhu	a5,-64(s0)
    80003d0a:	dfe1                	beqz	a5,80003ce2 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003d0c:	fc240593          	add	a1,s0,-62
    80003d10:	854e                	mv	a0,s3
    80003d12:	00000097          	auipc	ra,0x0
    80003d16:	f6c080e7          	jalr	-148(ra) # 80003c7e <namecmp>
    80003d1a:	f561                	bnez	a0,80003ce2 <dirlookup+0x4a>
      if(poff)
    80003d1c:	000a0463          	beqz	s4,80003d24 <dirlookup+0x8c>
        *poff = off;
    80003d20:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003d24:	fc045583          	lhu	a1,-64(s0)
    80003d28:	00092503          	lw	a0,0(s2)
    80003d2c:	fffff097          	auipc	ra,0xfffff
    80003d30:	754080e7          	jalr	1876(ra) # 80003480 <iget>
    80003d34:	a011                	j	80003d38 <dirlookup+0xa0>
  return 0;
    80003d36:	4501                	li	a0,0
}
    80003d38:	70e2                	ld	ra,56(sp)
    80003d3a:	7442                	ld	s0,48(sp)
    80003d3c:	74a2                	ld	s1,40(sp)
    80003d3e:	7902                	ld	s2,32(sp)
    80003d40:	69e2                	ld	s3,24(sp)
    80003d42:	6a42                	ld	s4,16(sp)
    80003d44:	6121                	add	sp,sp,64
    80003d46:	8082                	ret

0000000080003d48 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003d48:	711d                	add	sp,sp,-96
    80003d4a:	ec86                	sd	ra,88(sp)
    80003d4c:	e8a2                	sd	s0,80(sp)
    80003d4e:	e4a6                	sd	s1,72(sp)
    80003d50:	e0ca                	sd	s2,64(sp)
    80003d52:	fc4e                	sd	s3,56(sp)
    80003d54:	f852                	sd	s4,48(sp)
    80003d56:	f456                	sd	s5,40(sp)
    80003d58:	f05a                	sd	s6,32(sp)
    80003d5a:	ec5e                	sd	s7,24(sp)
    80003d5c:	e862                	sd	s8,16(sp)
    80003d5e:	e466                	sd	s9,8(sp)
    80003d60:	1080                	add	s0,sp,96
    80003d62:	84aa                	mv	s1,a0
    80003d64:	8b2e                	mv	s6,a1
    80003d66:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003d68:	00054703          	lbu	a4,0(a0)
    80003d6c:	02f00793          	li	a5,47
    80003d70:	02f70263          	beq	a4,a5,80003d94 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003d74:	ffffe097          	auipc	ra,0xffffe
    80003d78:	c6e080e7          	jalr	-914(ra) # 800019e2 <myproc>
    80003d7c:	15053503          	ld	a0,336(a0)
    80003d80:	00000097          	auipc	ra,0x0
    80003d84:	9f6080e7          	jalr	-1546(ra) # 80003776 <idup>
    80003d88:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d8a:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d8e:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d90:	4b85                	li	s7,1
    80003d92:	a875                	j	80003e4e <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d94:	4585                	li	a1,1
    80003d96:	4505                	li	a0,1
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	6e8080e7          	jalr	1768(ra) # 80003480 <iget>
    80003da0:	8a2a                	mv	s4,a0
    80003da2:	b7e5                	j	80003d8a <namex+0x42>
      iunlockput(ip);
    80003da4:	8552                	mv	a0,s4
    80003da6:	00000097          	auipc	ra,0x0
    80003daa:	c70080e7          	jalr	-912(ra) # 80003a16 <iunlockput>
      return 0;
    80003dae:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003db0:	8552                	mv	a0,s4
    80003db2:	60e6                	ld	ra,88(sp)
    80003db4:	6446                	ld	s0,80(sp)
    80003db6:	64a6                	ld	s1,72(sp)
    80003db8:	6906                	ld	s2,64(sp)
    80003dba:	79e2                	ld	s3,56(sp)
    80003dbc:	7a42                	ld	s4,48(sp)
    80003dbe:	7aa2                	ld	s5,40(sp)
    80003dc0:	7b02                	ld	s6,32(sp)
    80003dc2:	6be2                	ld	s7,24(sp)
    80003dc4:	6c42                	ld	s8,16(sp)
    80003dc6:	6ca2                	ld	s9,8(sp)
    80003dc8:	6125                	add	sp,sp,96
    80003dca:	8082                	ret
      iunlock(ip);
    80003dcc:	8552                	mv	a0,s4
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	aa8080e7          	jalr	-1368(ra) # 80003876 <iunlock>
      return ip;
    80003dd6:	bfe9                	j	80003db0 <namex+0x68>
      iunlockput(ip);
    80003dd8:	8552                	mv	a0,s4
    80003dda:	00000097          	auipc	ra,0x0
    80003dde:	c3c080e7          	jalr	-964(ra) # 80003a16 <iunlockput>
      return 0;
    80003de2:	8a4e                	mv	s4,s3
    80003de4:	b7f1                	j	80003db0 <namex+0x68>
  len = path - s;
    80003de6:	40998633          	sub	a2,s3,s1
    80003dea:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003dee:	099c5863          	bge	s8,s9,80003e7e <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003df2:	4639                	li	a2,14
    80003df4:	85a6                	mv	a1,s1
    80003df6:	8556                	mv	a0,s5
    80003df8:	ffffd097          	auipc	ra,0xffffd
    80003dfc:	f32080e7          	jalr	-206(ra) # 80000d2a <memmove>
    80003e00:	84ce                	mv	s1,s3
  while(*path == '/')
    80003e02:	0004c783          	lbu	a5,0(s1)
    80003e06:	01279763          	bne	a5,s2,80003e14 <namex+0xcc>
    path++;
    80003e0a:	0485                	add	s1,s1,1
  while(*path == '/')
    80003e0c:	0004c783          	lbu	a5,0(s1)
    80003e10:	ff278de3          	beq	a5,s2,80003e0a <namex+0xc2>
    ilock(ip);
    80003e14:	8552                	mv	a0,s4
    80003e16:	00000097          	auipc	ra,0x0
    80003e1a:	99e080e7          	jalr	-1634(ra) # 800037b4 <ilock>
    if(ip->type != T_DIR){
    80003e1e:	044a1783          	lh	a5,68(s4)
    80003e22:	f97791e3          	bne	a5,s7,80003da4 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003e26:	000b0563          	beqz	s6,80003e30 <namex+0xe8>
    80003e2a:	0004c783          	lbu	a5,0(s1)
    80003e2e:	dfd9                	beqz	a5,80003dcc <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003e30:	4601                	li	a2,0
    80003e32:	85d6                	mv	a1,s5
    80003e34:	8552                	mv	a0,s4
    80003e36:	00000097          	auipc	ra,0x0
    80003e3a:	e62080e7          	jalr	-414(ra) # 80003c98 <dirlookup>
    80003e3e:	89aa                	mv	s3,a0
    80003e40:	dd41                	beqz	a0,80003dd8 <namex+0x90>
    iunlockput(ip);
    80003e42:	8552                	mv	a0,s4
    80003e44:	00000097          	auipc	ra,0x0
    80003e48:	bd2080e7          	jalr	-1070(ra) # 80003a16 <iunlockput>
    ip = next;
    80003e4c:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003e4e:	0004c783          	lbu	a5,0(s1)
    80003e52:	01279763          	bne	a5,s2,80003e60 <namex+0x118>
    path++;
    80003e56:	0485                	add	s1,s1,1
  while(*path == '/')
    80003e58:	0004c783          	lbu	a5,0(s1)
    80003e5c:	ff278de3          	beq	a5,s2,80003e56 <namex+0x10e>
  if(*path == 0)
    80003e60:	cb9d                	beqz	a5,80003e96 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003e62:	0004c783          	lbu	a5,0(s1)
    80003e66:	89a6                	mv	s3,s1
  len = path - s;
    80003e68:	4c81                	li	s9,0
    80003e6a:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003e6c:	01278963          	beq	a5,s2,80003e7e <namex+0x136>
    80003e70:	dbbd                	beqz	a5,80003de6 <namex+0x9e>
    path++;
    80003e72:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003e74:	0009c783          	lbu	a5,0(s3)
    80003e78:	ff279ce3          	bne	a5,s2,80003e70 <namex+0x128>
    80003e7c:	b7ad                	j	80003de6 <namex+0x9e>
    memmove(name, s, len);
    80003e7e:	2601                	sext.w	a2,a2
    80003e80:	85a6                	mv	a1,s1
    80003e82:	8556                	mv	a0,s5
    80003e84:	ffffd097          	auipc	ra,0xffffd
    80003e88:	ea6080e7          	jalr	-346(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e8c:	9cd6                	add	s9,s9,s5
    80003e8e:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e92:	84ce                	mv	s1,s3
    80003e94:	b7bd                	j	80003e02 <namex+0xba>
  if(nameiparent){
    80003e96:	f00b0de3          	beqz	s6,80003db0 <namex+0x68>
    iput(ip);
    80003e9a:	8552                	mv	a0,s4
    80003e9c:	00000097          	auipc	ra,0x0
    80003ea0:	ad2080e7          	jalr	-1326(ra) # 8000396e <iput>
    return 0;
    80003ea4:	4a01                	li	s4,0
    80003ea6:	b729                	j	80003db0 <namex+0x68>

0000000080003ea8 <dirlink>:
{
    80003ea8:	7139                	add	sp,sp,-64
    80003eaa:	fc06                	sd	ra,56(sp)
    80003eac:	f822                	sd	s0,48(sp)
    80003eae:	f426                	sd	s1,40(sp)
    80003eb0:	f04a                	sd	s2,32(sp)
    80003eb2:	ec4e                	sd	s3,24(sp)
    80003eb4:	e852                	sd	s4,16(sp)
    80003eb6:	0080                	add	s0,sp,64
    80003eb8:	892a                	mv	s2,a0
    80003eba:	8a2e                	mv	s4,a1
    80003ebc:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003ebe:	4601                	li	a2,0
    80003ec0:	00000097          	auipc	ra,0x0
    80003ec4:	dd8080e7          	jalr	-552(ra) # 80003c98 <dirlookup>
    80003ec8:	e93d                	bnez	a0,80003f3e <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003eca:	04c92483          	lw	s1,76(s2)
    80003ece:	c49d                	beqz	s1,80003efc <dirlink+0x54>
    80003ed0:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003ed2:	4741                	li	a4,16
    80003ed4:	86a6                	mv	a3,s1
    80003ed6:	fc040613          	add	a2,s0,-64
    80003eda:	4581                	li	a1,0
    80003edc:	854a                	mv	a0,s2
    80003ede:	00000097          	auipc	ra,0x0
    80003ee2:	b8a080e7          	jalr	-1142(ra) # 80003a68 <readi>
    80003ee6:	47c1                	li	a5,16
    80003ee8:	06f51163          	bne	a0,a5,80003f4a <dirlink+0xa2>
    if(de.inum == 0)
    80003eec:	fc045783          	lhu	a5,-64(s0)
    80003ef0:	c791                	beqz	a5,80003efc <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003ef2:	24c1                	addw	s1,s1,16
    80003ef4:	04c92783          	lw	a5,76(s2)
    80003ef8:	fcf4ede3          	bltu	s1,a5,80003ed2 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003efc:	4639                	li	a2,14
    80003efe:	85d2                	mv	a1,s4
    80003f00:	fc240513          	add	a0,s0,-62
    80003f04:	ffffd097          	auipc	ra,0xffffd
    80003f08:	ed6080e7          	jalr	-298(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003f0c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003f10:	4741                	li	a4,16
    80003f12:	86a6                	mv	a3,s1
    80003f14:	fc040613          	add	a2,s0,-64
    80003f18:	4581                	li	a1,0
    80003f1a:	854a                	mv	a0,s2
    80003f1c:	00000097          	auipc	ra,0x0
    80003f20:	c44080e7          	jalr	-956(ra) # 80003b60 <writei>
    80003f24:	1541                	add	a0,a0,-16
    80003f26:	00a03533          	snez	a0,a0
    80003f2a:	40a00533          	neg	a0,a0
}
    80003f2e:	70e2                	ld	ra,56(sp)
    80003f30:	7442                	ld	s0,48(sp)
    80003f32:	74a2                	ld	s1,40(sp)
    80003f34:	7902                	ld	s2,32(sp)
    80003f36:	69e2                	ld	s3,24(sp)
    80003f38:	6a42                	ld	s4,16(sp)
    80003f3a:	6121                	add	sp,sp,64
    80003f3c:	8082                	ret
    iput(ip);
    80003f3e:	00000097          	auipc	ra,0x0
    80003f42:	a30080e7          	jalr	-1488(ra) # 8000396e <iput>
    return -1;
    80003f46:	557d                	li	a0,-1
    80003f48:	b7dd                	j	80003f2e <dirlink+0x86>
      panic("dirlink read");
    80003f4a:	00004517          	auipc	a0,0x4
    80003f4e:	70650513          	add	a0,a0,1798 # 80008650 <syscalls+0x1c8>
    80003f52:	ffffc097          	auipc	ra,0xffffc
    80003f56:	5ea080e7          	jalr	1514(ra) # 8000053c <panic>

0000000080003f5a <namei>:

struct inode*
namei(char *path)
{
    80003f5a:	1101                	add	sp,sp,-32
    80003f5c:	ec06                	sd	ra,24(sp)
    80003f5e:	e822                	sd	s0,16(sp)
    80003f60:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003f62:	fe040613          	add	a2,s0,-32
    80003f66:	4581                	li	a1,0
    80003f68:	00000097          	auipc	ra,0x0
    80003f6c:	de0080e7          	jalr	-544(ra) # 80003d48 <namex>
}
    80003f70:	60e2                	ld	ra,24(sp)
    80003f72:	6442                	ld	s0,16(sp)
    80003f74:	6105                	add	sp,sp,32
    80003f76:	8082                	ret

0000000080003f78 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f78:	1141                	add	sp,sp,-16
    80003f7a:	e406                	sd	ra,8(sp)
    80003f7c:	e022                	sd	s0,0(sp)
    80003f7e:	0800                	add	s0,sp,16
    80003f80:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f82:	4585                	li	a1,1
    80003f84:	00000097          	auipc	ra,0x0
    80003f88:	dc4080e7          	jalr	-572(ra) # 80003d48 <namex>
}
    80003f8c:	60a2                	ld	ra,8(sp)
    80003f8e:	6402                	ld	s0,0(sp)
    80003f90:	0141                	add	sp,sp,16
    80003f92:	8082                	ret

0000000080003f94 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f94:	1101                	add	sp,sp,-32
    80003f96:	ec06                	sd	ra,24(sp)
    80003f98:	e822                	sd	s0,16(sp)
    80003f9a:	e426                	sd	s1,8(sp)
    80003f9c:	e04a                	sd	s2,0(sp)
    80003f9e:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003fa0:	00194917          	auipc	s2,0x194
    80003fa4:	14890913          	add	s2,s2,328 # 801980e8 <log>
    80003fa8:	01892583          	lw	a1,24(s2)
    80003fac:	02892503          	lw	a0,40(s2)
    80003fb0:	fffff097          	auipc	ra,0xfffff
    80003fb4:	ff4080e7          	jalr	-12(ra) # 80002fa4 <bread>
    80003fb8:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003fba:	02c92603          	lw	a2,44(s2)
    80003fbe:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003fc0:	00c05f63          	blez	a2,80003fde <write_head+0x4a>
    80003fc4:	00194717          	auipc	a4,0x194
    80003fc8:	15470713          	add	a4,a4,340 # 80198118 <log+0x30>
    80003fcc:	87aa                	mv	a5,a0
    80003fce:	060a                	sll	a2,a2,0x2
    80003fd0:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003fd2:	4314                	lw	a3,0(a4)
    80003fd4:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003fd6:	0711                	add	a4,a4,4
    80003fd8:	0791                	add	a5,a5,4
    80003fda:	fec79ce3          	bne	a5,a2,80003fd2 <write_head+0x3e>
  }
  bwrite(buf);
    80003fde:	8526                	mv	a0,s1
    80003fe0:	fffff097          	auipc	ra,0xfffff
    80003fe4:	0b6080e7          	jalr	182(ra) # 80003096 <bwrite>
  brelse(buf);
    80003fe8:	8526                	mv	a0,s1
    80003fea:	fffff097          	auipc	ra,0xfffff
    80003fee:	0ea080e7          	jalr	234(ra) # 800030d4 <brelse>
}
    80003ff2:	60e2                	ld	ra,24(sp)
    80003ff4:	6442                	ld	s0,16(sp)
    80003ff6:	64a2                	ld	s1,8(sp)
    80003ff8:	6902                	ld	s2,0(sp)
    80003ffa:	6105                	add	sp,sp,32
    80003ffc:	8082                	ret

0000000080003ffe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003ffe:	00194797          	auipc	a5,0x194
    80004002:	1167a783          	lw	a5,278(a5) # 80198114 <log+0x2c>
    80004006:	0af05d63          	blez	a5,800040c0 <install_trans+0xc2>
{
    8000400a:	7139                	add	sp,sp,-64
    8000400c:	fc06                	sd	ra,56(sp)
    8000400e:	f822                	sd	s0,48(sp)
    80004010:	f426                	sd	s1,40(sp)
    80004012:	f04a                	sd	s2,32(sp)
    80004014:	ec4e                	sd	s3,24(sp)
    80004016:	e852                	sd	s4,16(sp)
    80004018:	e456                	sd	s5,8(sp)
    8000401a:	e05a                	sd	s6,0(sp)
    8000401c:	0080                	add	s0,sp,64
    8000401e:	8b2a                	mv	s6,a0
    80004020:	00194a97          	auipc	s5,0x194
    80004024:	0f8a8a93          	add	s5,s5,248 # 80198118 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004028:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    8000402a:	00194997          	auipc	s3,0x194
    8000402e:	0be98993          	add	s3,s3,190 # 801980e8 <log>
    80004032:	a00d                	j	80004054 <install_trans+0x56>
    brelse(lbuf);
    80004034:	854a                	mv	a0,s2
    80004036:	fffff097          	auipc	ra,0xfffff
    8000403a:	09e080e7          	jalr	158(ra) # 800030d4 <brelse>
    brelse(dbuf);
    8000403e:	8526                	mv	a0,s1
    80004040:	fffff097          	auipc	ra,0xfffff
    80004044:	094080e7          	jalr	148(ra) # 800030d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004048:	2a05                	addw	s4,s4,1
    8000404a:	0a91                	add	s5,s5,4
    8000404c:	02c9a783          	lw	a5,44(s3)
    80004050:	04fa5e63          	bge	s4,a5,800040ac <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80004054:	0189a583          	lw	a1,24(s3)
    80004058:	014585bb          	addw	a1,a1,s4
    8000405c:	2585                	addw	a1,a1,1
    8000405e:	0289a503          	lw	a0,40(s3)
    80004062:	fffff097          	auipc	ra,0xfffff
    80004066:	f42080e7          	jalr	-190(ra) # 80002fa4 <bread>
    8000406a:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    8000406c:	000aa583          	lw	a1,0(s5)
    80004070:	0289a503          	lw	a0,40(s3)
    80004074:	fffff097          	auipc	ra,0xfffff
    80004078:	f30080e7          	jalr	-208(ra) # 80002fa4 <bread>
    8000407c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    8000407e:	40000613          	li	a2,1024
    80004082:	05890593          	add	a1,s2,88
    80004086:	05850513          	add	a0,a0,88
    8000408a:	ffffd097          	auipc	ra,0xffffd
    8000408e:	ca0080e7          	jalr	-864(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80004092:	8526                	mv	a0,s1
    80004094:	fffff097          	auipc	ra,0xfffff
    80004098:	002080e7          	jalr	2(ra) # 80003096 <bwrite>
    if(recovering == 0)
    8000409c:	f80b1ce3          	bnez	s6,80004034 <install_trans+0x36>
      bunpin(dbuf);
    800040a0:	8526                	mv	a0,s1
    800040a2:	fffff097          	auipc	ra,0xfffff
    800040a6:	10a080e7          	jalr	266(ra) # 800031ac <bunpin>
    800040aa:	b769                	j	80004034 <install_trans+0x36>
}
    800040ac:	70e2                	ld	ra,56(sp)
    800040ae:	7442                	ld	s0,48(sp)
    800040b0:	74a2                	ld	s1,40(sp)
    800040b2:	7902                	ld	s2,32(sp)
    800040b4:	69e2                	ld	s3,24(sp)
    800040b6:	6a42                	ld	s4,16(sp)
    800040b8:	6aa2                	ld	s5,8(sp)
    800040ba:	6b02                	ld	s6,0(sp)
    800040bc:	6121                	add	sp,sp,64
    800040be:	8082                	ret
    800040c0:	8082                	ret

00000000800040c2 <initlog>:
{
    800040c2:	7179                	add	sp,sp,-48
    800040c4:	f406                	sd	ra,40(sp)
    800040c6:	f022                	sd	s0,32(sp)
    800040c8:	ec26                	sd	s1,24(sp)
    800040ca:	e84a                	sd	s2,16(sp)
    800040cc:	e44e                	sd	s3,8(sp)
    800040ce:	1800                	add	s0,sp,48
    800040d0:	892a                	mv	s2,a0
    800040d2:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    800040d4:	00194497          	auipc	s1,0x194
    800040d8:	01448493          	add	s1,s1,20 # 801980e8 <log>
    800040dc:	00004597          	auipc	a1,0x4
    800040e0:	58458593          	add	a1,a1,1412 # 80008660 <syscalls+0x1d8>
    800040e4:	8526                	mv	a0,s1
    800040e6:	ffffd097          	auipc	ra,0xffffd
    800040ea:	a5c080e7          	jalr	-1444(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    800040ee:	0149a583          	lw	a1,20(s3)
    800040f2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    800040f4:	0109a783          	lw	a5,16(s3)
    800040f8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    800040fa:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    800040fe:	854a                	mv	a0,s2
    80004100:	fffff097          	auipc	ra,0xfffff
    80004104:	ea4080e7          	jalr	-348(ra) # 80002fa4 <bread>
  log.lh.n = lh->n;
    80004108:	4d30                	lw	a2,88(a0)
    8000410a:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000410c:	00c05f63          	blez	a2,8000412a <initlog+0x68>
    80004110:	87aa                	mv	a5,a0
    80004112:	00194717          	auipc	a4,0x194
    80004116:	00670713          	add	a4,a4,6 # 80198118 <log+0x30>
    8000411a:	060a                	sll	a2,a2,0x2
    8000411c:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    8000411e:	4ff4                	lw	a3,92(a5)
    80004120:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004122:	0791                	add	a5,a5,4
    80004124:	0711                	add	a4,a4,4
    80004126:	fec79ce3          	bne	a5,a2,8000411e <initlog+0x5c>
  brelse(buf);
    8000412a:	fffff097          	auipc	ra,0xfffff
    8000412e:	faa080e7          	jalr	-86(ra) # 800030d4 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80004132:	4505                	li	a0,1
    80004134:	00000097          	auipc	ra,0x0
    80004138:	eca080e7          	jalr	-310(ra) # 80003ffe <install_trans>
  log.lh.n = 0;
    8000413c:	00194797          	auipc	a5,0x194
    80004140:	fc07ac23          	sw	zero,-40(a5) # 80198114 <log+0x2c>
  write_head(); // clear the log
    80004144:	00000097          	auipc	ra,0x0
    80004148:	e50080e7          	jalr	-432(ra) # 80003f94 <write_head>
}
    8000414c:	70a2                	ld	ra,40(sp)
    8000414e:	7402                	ld	s0,32(sp)
    80004150:	64e2                	ld	s1,24(sp)
    80004152:	6942                	ld	s2,16(sp)
    80004154:	69a2                	ld	s3,8(sp)
    80004156:	6145                	add	sp,sp,48
    80004158:	8082                	ret

000000008000415a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000415a:	1101                	add	sp,sp,-32
    8000415c:	ec06                	sd	ra,24(sp)
    8000415e:	e822                	sd	s0,16(sp)
    80004160:	e426                	sd	s1,8(sp)
    80004162:	e04a                	sd	s2,0(sp)
    80004164:	1000                	add	s0,sp,32
  acquire(&log.lock);
    80004166:	00194517          	auipc	a0,0x194
    8000416a:	f8250513          	add	a0,a0,-126 # 801980e8 <log>
    8000416e:	ffffd097          	auipc	ra,0xffffd
    80004172:	a64080e7          	jalr	-1436(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004176:	00194497          	auipc	s1,0x194
    8000417a:	f7248493          	add	s1,s1,-142 # 801980e8 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000417e:	4979                	li	s2,30
    80004180:	a039                	j	8000418e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004182:	85a6                	mv	a1,s1
    80004184:	8526                	mv	a0,s1
    80004186:	ffffe097          	auipc	ra,0xffffe
    8000418a:	ff2080e7          	jalr	-14(ra) # 80002178 <sleep>
    if(log.committing){
    8000418e:	50dc                	lw	a5,36(s1)
    80004190:	fbed                	bnez	a5,80004182 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004192:	5098                	lw	a4,32(s1)
    80004194:	2705                	addw	a4,a4,1
    80004196:	0027179b          	sllw	a5,a4,0x2
    8000419a:	9fb9                	addw	a5,a5,a4
    8000419c:	0017979b          	sllw	a5,a5,0x1
    800041a0:	54d4                	lw	a3,44(s1)
    800041a2:	9fb5                	addw	a5,a5,a3
    800041a4:	00f95963          	bge	s2,a5,800041b6 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800041a8:	85a6                	mv	a1,s1
    800041aa:	8526                	mv	a0,s1
    800041ac:	ffffe097          	auipc	ra,0xffffe
    800041b0:	fcc080e7          	jalr	-52(ra) # 80002178 <sleep>
    800041b4:	bfe9                	j	8000418e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    800041b6:	00194517          	auipc	a0,0x194
    800041ba:	f3250513          	add	a0,a0,-206 # 801980e8 <log>
    800041be:	d118                	sw	a4,32(a0)
      release(&log.lock);
    800041c0:	ffffd097          	auipc	ra,0xffffd
    800041c4:	ac6080e7          	jalr	-1338(ra) # 80000c86 <release>
      break;
    }
  }
}
    800041c8:	60e2                	ld	ra,24(sp)
    800041ca:	6442                	ld	s0,16(sp)
    800041cc:	64a2                	ld	s1,8(sp)
    800041ce:	6902                	ld	s2,0(sp)
    800041d0:	6105                	add	sp,sp,32
    800041d2:	8082                	ret

00000000800041d4 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    800041d4:	7139                	add	sp,sp,-64
    800041d6:	fc06                	sd	ra,56(sp)
    800041d8:	f822                	sd	s0,48(sp)
    800041da:	f426                	sd	s1,40(sp)
    800041dc:	f04a                	sd	s2,32(sp)
    800041de:	ec4e                	sd	s3,24(sp)
    800041e0:	e852                	sd	s4,16(sp)
    800041e2:	e456                	sd	s5,8(sp)
    800041e4:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    800041e6:	00194497          	auipc	s1,0x194
    800041ea:	f0248493          	add	s1,s1,-254 # 801980e8 <log>
    800041ee:	8526                	mv	a0,s1
    800041f0:	ffffd097          	auipc	ra,0xffffd
    800041f4:	9e2080e7          	jalr	-1566(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    800041f8:	509c                	lw	a5,32(s1)
    800041fa:	37fd                	addw	a5,a5,-1
    800041fc:	0007891b          	sext.w	s2,a5
    80004200:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004202:	50dc                	lw	a5,36(s1)
    80004204:	e7b9                	bnez	a5,80004252 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004206:	04091e63          	bnez	s2,80004262 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000420a:	00194497          	auipc	s1,0x194
    8000420e:	ede48493          	add	s1,s1,-290 # 801980e8 <log>
    80004212:	4785                	li	a5,1
    80004214:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004216:	8526                	mv	a0,s1
    80004218:	ffffd097          	auipc	ra,0xffffd
    8000421c:	a6e080e7          	jalr	-1426(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80004220:	54dc                	lw	a5,44(s1)
    80004222:	06f04763          	bgtz	a5,80004290 <end_op+0xbc>
    acquire(&log.lock);
    80004226:	00194497          	auipc	s1,0x194
    8000422a:	ec248493          	add	s1,s1,-318 # 801980e8 <log>
    8000422e:	8526                	mv	a0,s1
    80004230:	ffffd097          	auipc	ra,0xffffd
    80004234:	9a2080e7          	jalr	-1630(ra) # 80000bd2 <acquire>
    log.committing = 0;
    80004238:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000423c:	8526                	mv	a0,s1
    8000423e:	ffffe097          	auipc	ra,0xffffe
    80004242:	f9e080e7          	jalr	-98(ra) # 800021dc <wakeup>
    release(&log.lock);
    80004246:	8526                	mv	a0,s1
    80004248:	ffffd097          	auipc	ra,0xffffd
    8000424c:	a3e080e7          	jalr	-1474(ra) # 80000c86 <release>
}
    80004250:	a03d                	j	8000427e <end_op+0xaa>
    panic("log.committing");
    80004252:	00004517          	auipc	a0,0x4
    80004256:	41650513          	add	a0,a0,1046 # 80008668 <syscalls+0x1e0>
    8000425a:	ffffc097          	auipc	ra,0xffffc
    8000425e:	2e2080e7          	jalr	738(ra) # 8000053c <panic>
    wakeup(&log);
    80004262:	00194497          	auipc	s1,0x194
    80004266:	e8648493          	add	s1,s1,-378 # 801980e8 <log>
    8000426a:	8526                	mv	a0,s1
    8000426c:	ffffe097          	auipc	ra,0xffffe
    80004270:	f70080e7          	jalr	-144(ra) # 800021dc <wakeup>
  release(&log.lock);
    80004274:	8526                	mv	a0,s1
    80004276:	ffffd097          	auipc	ra,0xffffd
    8000427a:	a10080e7          	jalr	-1520(ra) # 80000c86 <release>
}
    8000427e:	70e2                	ld	ra,56(sp)
    80004280:	7442                	ld	s0,48(sp)
    80004282:	74a2                	ld	s1,40(sp)
    80004284:	7902                	ld	s2,32(sp)
    80004286:	69e2                	ld	s3,24(sp)
    80004288:	6a42                	ld	s4,16(sp)
    8000428a:	6aa2                	ld	s5,8(sp)
    8000428c:	6121                	add	sp,sp,64
    8000428e:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004290:	00194a97          	auipc	s5,0x194
    80004294:	e88a8a93          	add	s5,s5,-376 # 80198118 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004298:	00194a17          	auipc	s4,0x194
    8000429c:	e50a0a13          	add	s4,s4,-432 # 801980e8 <log>
    800042a0:	018a2583          	lw	a1,24(s4)
    800042a4:	012585bb          	addw	a1,a1,s2
    800042a8:	2585                	addw	a1,a1,1
    800042aa:	028a2503          	lw	a0,40(s4)
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	cf6080e7          	jalr	-778(ra) # 80002fa4 <bread>
    800042b6:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    800042b8:	000aa583          	lw	a1,0(s5)
    800042bc:	028a2503          	lw	a0,40(s4)
    800042c0:	fffff097          	auipc	ra,0xfffff
    800042c4:	ce4080e7          	jalr	-796(ra) # 80002fa4 <bread>
    800042c8:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    800042ca:	40000613          	li	a2,1024
    800042ce:	05850593          	add	a1,a0,88
    800042d2:	05848513          	add	a0,s1,88
    800042d6:	ffffd097          	auipc	ra,0xffffd
    800042da:	a54080e7          	jalr	-1452(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    800042de:	8526                	mv	a0,s1
    800042e0:	fffff097          	auipc	ra,0xfffff
    800042e4:	db6080e7          	jalr	-586(ra) # 80003096 <bwrite>
    brelse(from);
    800042e8:	854e                	mv	a0,s3
    800042ea:	fffff097          	auipc	ra,0xfffff
    800042ee:	dea080e7          	jalr	-534(ra) # 800030d4 <brelse>
    brelse(to);
    800042f2:	8526                	mv	a0,s1
    800042f4:	fffff097          	auipc	ra,0xfffff
    800042f8:	de0080e7          	jalr	-544(ra) # 800030d4 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800042fc:	2905                	addw	s2,s2,1
    800042fe:	0a91                	add	s5,s5,4
    80004300:	02ca2783          	lw	a5,44(s4)
    80004304:	f8f94ee3          	blt	s2,a5,800042a0 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004308:	00000097          	auipc	ra,0x0
    8000430c:	c8c080e7          	jalr	-884(ra) # 80003f94 <write_head>
    install_trans(0); // Now install writes to home locations
    80004310:	4501                	li	a0,0
    80004312:	00000097          	auipc	ra,0x0
    80004316:	cec080e7          	jalr	-788(ra) # 80003ffe <install_trans>
    log.lh.n = 0;
    8000431a:	00194797          	auipc	a5,0x194
    8000431e:	de07ad23          	sw	zero,-518(a5) # 80198114 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004322:	00000097          	auipc	ra,0x0
    80004326:	c72080e7          	jalr	-910(ra) # 80003f94 <write_head>
    8000432a:	bdf5                	j	80004226 <end_op+0x52>

000000008000432c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000432c:	1101                	add	sp,sp,-32
    8000432e:	ec06                	sd	ra,24(sp)
    80004330:	e822                	sd	s0,16(sp)
    80004332:	e426                	sd	s1,8(sp)
    80004334:	e04a                	sd	s2,0(sp)
    80004336:	1000                	add	s0,sp,32
    80004338:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    8000433a:	00194917          	auipc	s2,0x194
    8000433e:	dae90913          	add	s2,s2,-594 # 801980e8 <log>
    80004342:	854a                	mv	a0,s2
    80004344:	ffffd097          	auipc	ra,0xffffd
    80004348:	88e080e7          	jalr	-1906(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    8000434c:	02c92603          	lw	a2,44(s2)
    80004350:	47f5                	li	a5,29
    80004352:	06c7c563          	blt	a5,a2,800043bc <log_write+0x90>
    80004356:	00194797          	auipc	a5,0x194
    8000435a:	dae7a783          	lw	a5,-594(a5) # 80198104 <log+0x1c>
    8000435e:	37fd                	addw	a5,a5,-1
    80004360:	04f65e63          	bge	a2,a5,800043bc <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80004364:	00194797          	auipc	a5,0x194
    80004368:	da47a783          	lw	a5,-604(a5) # 80198108 <log+0x20>
    8000436c:	06f05063          	blez	a5,800043cc <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004370:	4781                	li	a5,0
    80004372:	06c05563          	blez	a2,800043dc <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004376:	44cc                	lw	a1,12(s1)
    80004378:	00194717          	auipc	a4,0x194
    8000437c:	da070713          	add	a4,a4,-608 # 80198118 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004380:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004382:	4314                	lw	a3,0(a4)
    80004384:	04b68c63          	beq	a3,a1,800043dc <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004388:	2785                	addw	a5,a5,1
    8000438a:	0711                	add	a4,a4,4
    8000438c:	fef61be3          	bne	a2,a5,80004382 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004390:	0621                	add	a2,a2,8
    80004392:	060a                	sll	a2,a2,0x2
    80004394:	00194797          	auipc	a5,0x194
    80004398:	d5478793          	add	a5,a5,-684 # 801980e8 <log>
    8000439c:	97b2                	add	a5,a5,a2
    8000439e:	44d8                	lw	a4,12(s1)
    800043a0:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    800043a2:	8526                	mv	a0,s1
    800043a4:	fffff097          	auipc	ra,0xfffff
    800043a8:	dcc080e7          	jalr	-564(ra) # 80003170 <bpin>
    log.lh.n++;
    800043ac:	00194717          	auipc	a4,0x194
    800043b0:	d3c70713          	add	a4,a4,-708 # 801980e8 <log>
    800043b4:	575c                	lw	a5,44(a4)
    800043b6:	2785                	addw	a5,a5,1
    800043b8:	d75c                	sw	a5,44(a4)
    800043ba:	a82d                	j	800043f4 <log_write+0xc8>
    panic("too big a transaction");
    800043bc:	00004517          	auipc	a0,0x4
    800043c0:	2bc50513          	add	a0,a0,700 # 80008678 <syscalls+0x1f0>
    800043c4:	ffffc097          	auipc	ra,0xffffc
    800043c8:	178080e7          	jalr	376(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    800043cc:	00004517          	auipc	a0,0x4
    800043d0:	2c450513          	add	a0,a0,708 # 80008690 <syscalls+0x208>
    800043d4:	ffffc097          	auipc	ra,0xffffc
    800043d8:	168080e7          	jalr	360(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    800043dc:	00878693          	add	a3,a5,8
    800043e0:	068a                	sll	a3,a3,0x2
    800043e2:	00194717          	auipc	a4,0x194
    800043e6:	d0670713          	add	a4,a4,-762 # 801980e8 <log>
    800043ea:	9736                	add	a4,a4,a3
    800043ec:	44d4                	lw	a3,12(s1)
    800043ee:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    800043f0:	faf609e3          	beq	a2,a5,800043a2 <log_write+0x76>
  }
  release(&log.lock);
    800043f4:	00194517          	auipc	a0,0x194
    800043f8:	cf450513          	add	a0,a0,-780 # 801980e8 <log>
    800043fc:	ffffd097          	auipc	ra,0xffffd
    80004400:	88a080e7          	jalr	-1910(ra) # 80000c86 <release>
}
    80004404:	60e2                	ld	ra,24(sp)
    80004406:	6442                	ld	s0,16(sp)
    80004408:	64a2                	ld	s1,8(sp)
    8000440a:	6902                	ld	s2,0(sp)
    8000440c:	6105                	add	sp,sp,32
    8000440e:	8082                	ret

0000000080004410 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80004410:	1101                	add	sp,sp,-32
    80004412:	ec06                	sd	ra,24(sp)
    80004414:	e822                	sd	s0,16(sp)
    80004416:	e426                	sd	s1,8(sp)
    80004418:	e04a                	sd	s2,0(sp)
    8000441a:	1000                	add	s0,sp,32
    8000441c:	84aa                	mv	s1,a0
    8000441e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80004420:	00004597          	auipc	a1,0x4
    80004424:	29058593          	add	a1,a1,656 # 800086b0 <syscalls+0x228>
    80004428:	0521                	add	a0,a0,8
    8000442a:	ffffc097          	auipc	ra,0xffffc
    8000442e:	718080e7          	jalr	1816(ra) # 80000b42 <initlock>
  lk->name = name;
    80004432:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80004436:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000443a:	0204a423          	sw	zero,40(s1)
}
    8000443e:	60e2                	ld	ra,24(sp)
    80004440:	6442                	ld	s0,16(sp)
    80004442:	64a2                	ld	s1,8(sp)
    80004444:	6902                	ld	s2,0(sp)
    80004446:	6105                	add	sp,sp,32
    80004448:	8082                	ret

000000008000444a <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    8000444a:	1101                	add	sp,sp,-32
    8000444c:	ec06                	sd	ra,24(sp)
    8000444e:	e822                	sd	s0,16(sp)
    80004450:	e426                	sd	s1,8(sp)
    80004452:	e04a                	sd	s2,0(sp)
    80004454:	1000                	add	s0,sp,32
    80004456:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004458:	00850913          	add	s2,a0,8
    8000445c:	854a                	mv	a0,s2
    8000445e:	ffffc097          	auipc	ra,0xffffc
    80004462:	774080e7          	jalr	1908(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    80004466:	409c                	lw	a5,0(s1)
    80004468:	cb89                	beqz	a5,8000447a <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    8000446a:	85ca                	mv	a1,s2
    8000446c:	8526                	mv	a0,s1
    8000446e:	ffffe097          	auipc	ra,0xffffe
    80004472:	d0a080e7          	jalr	-758(ra) # 80002178 <sleep>
  while (lk->locked) {
    80004476:	409c                	lw	a5,0(s1)
    80004478:	fbed                	bnez	a5,8000446a <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000447a:	4785                	li	a5,1
    8000447c:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    8000447e:	ffffd097          	auipc	ra,0xffffd
    80004482:	564080e7          	jalr	1380(ra) # 800019e2 <myproc>
    80004486:	591c                	lw	a5,48(a0)
    80004488:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000448a:	854a                	mv	a0,s2
    8000448c:	ffffc097          	auipc	ra,0xffffc
    80004490:	7fa080e7          	jalr	2042(ra) # 80000c86 <release>
}
    80004494:	60e2                	ld	ra,24(sp)
    80004496:	6442                	ld	s0,16(sp)
    80004498:	64a2                	ld	s1,8(sp)
    8000449a:	6902                	ld	s2,0(sp)
    8000449c:	6105                	add	sp,sp,32
    8000449e:	8082                	ret

00000000800044a0 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    800044a0:	1101                	add	sp,sp,-32
    800044a2:	ec06                	sd	ra,24(sp)
    800044a4:	e822                	sd	s0,16(sp)
    800044a6:	e426                	sd	s1,8(sp)
    800044a8:	e04a                	sd	s2,0(sp)
    800044aa:	1000                	add	s0,sp,32
    800044ac:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800044ae:	00850913          	add	s2,a0,8
    800044b2:	854a                	mv	a0,s2
    800044b4:	ffffc097          	auipc	ra,0xffffc
    800044b8:	71e080e7          	jalr	1822(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    800044bc:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800044c0:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    800044c4:	8526                	mv	a0,s1
    800044c6:	ffffe097          	auipc	ra,0xffffe
    800044ca:	d16080e7          	jalr	-746(ra) # 800021dc <wakeup>
  release(&lk->lk);
    800044ce:	854a                	mv	a0,s2
    800044d0:	ffffc097          	auipc	ra,0xffffc
    800044d4:	7b6080e7          	jalr	1974(ra) # 80000c86 <release>
}
    800044d8:	60e2                	ld	ra,24(sp)
    800044da:	6442                	ld	s0,16(sp)
    800044dc:	64a2                	ld	s1,8(sp)
    800044de:	6902                	ld	s2,0(sp)
    800044e0:	6105                	add	sp,sp,32
    800044e2:	8082                	ret

00000000800044e4 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    800044e4:	7179                	add	sp,sp,-48
    800044e6:	f406                	sd	ra,40(sp)
    800044e8:	f022                	sd	s0,32(sp)
    800044ea:	ec26                	sd	s1,24(sp)
    800044ec:	e84a                	sd	s2,16(sp)
    800044ee:	e44e                	sd	s3,8(sp)
    800044f0:	1800                	add	s0,sp,48
    800044f2:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    800044f4:	00850913          	add	s2,a0,8
    800044f8:	854a                	mv	a0,s2
    800044fa:	ffffc097          	auipc	ra,0xffffc
    800044fe:	6d8080e7          	jalr	1752(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004502:	409c                	lw	a5,0(s1)
    80004504:	ef99                	bnez	a5,80004522 <holdingsleep+0x3e>
    80004506:	4481                	li	s1,0
  release(&lk->lk);
    80004508:	854a                	mv	a0,s2
    8000450a:	ffffc097          	auipc	ra,0xffffc
    8000450e:	77c080e7          	jalr	1916(ra) # 80000c86 <release>
  return r;
}
    80004512:	8526                	mv	a0,s1
    80004514:	70a2                	ld	ra,40(sp)
    80004516:	7402                	ld	s0,32(sp)
    80004518:	64e2                	ld	s1,24(sp)
    8000451a:	6942                	ld	s2,16(sp)
    8000451c:	69a2                	ld	s3,8(sp)
    8000451e:	6145                	add	sp,sp,48
    80004520:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004522:	0284a983          	lw	s3,40(s1)
    80004526:	ffffd097          	auipc	ra,0xffffd
    8000452a:	4bc080e7          	jalr	1212(ra) # 800019e2 <myproc>
    8000452e:	5904                	lw	s1,48(a0)
    80004530:	413484b3          	sub	s1,s1,s3
    80004534:	0014b493          	seqz	s1,s1
    80004538:	bfc1                	j	80004508 <holdingsleep+0x24>

000000008000453a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    8000453a:	1141                	add	sp,sp,-16
    8000453c:	e406                	sd	ra,8(sp)
    8000453e:	e022                	sd	s0,0(sp)
    80004540:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80004542:	00004597          	auipc	a1,0x4
    80004546:	17e58593          	add	a1,a1,382 # 800086c0 <syscalls+0x238>
    8000454a:	00194517          	auipc	a0,0x194
    8000454e:	ce650513          	add	a0,a0,-794 # 80198230 <ftable>
    80004552:	ffffc097          	auipc	ra,0xffffc
    80004556:	5f0080e7          	jalr	1520(ra) # 80000b42 <initlock>
}
    8000455a:	60a2                	ld	ra,8(sp)
    8000455c:	6402                	ld	s0,0(sp)
    8000455e:	0141                	add	sp,sp,16
    80004560:	8082                	ret

0000000080004562 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80004562:	1101                	add	sp,sp,-32
    80004564:	ec06                	sd	ra,24(sp)
    80004566:	e822                	sd	s0,16(sp)
    80004568:	e426                	sd	s1,8(sp)
    8000456a:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    8000456c:	00194517          	auipc	a0,0x194
    80004570:	cc450513          	add	a0,a0,-828 # 80198230 <ftable>
    80004574:	ffffc097          	auipc	ra,0xffffc
    80004578:	65e080e7          	jalr	1630(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000457c:	00194497          	auipc	s1,0x194
    80004580:	ccc48493          	add	s1,s1,-820 # 80198248 <ftable+0x18>
    80004584:	00195717          	auipc	a4,0x195
    80004588:	c6470713          	add	a4,a4,-924 # 801991e8 <disk>
    if(f->ref == 0){
    8000458c:	40dc                	lw	a5,4(s1)
    8000458e:	cf99                	beqz	a5,800045ac <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004590:	02848493          	add	s1,s1,40
    80004594:	fee49ce3          	bne	s1,a4,8000458c <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004598:	00194517          	auipc	a0,0x194
    8000459c:	c9850513          	add	a0,a0,-872 # 80198230 <ftable>
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	6e6080e7          	jalr	1766(ra) # 80000c86 <release>
  return 0;
    800045a8:	4481                	li	s1,0
    800045aa:	a819                	j	800045c0 <filealloc+0x5e>
      f->ref = 1;
    800045ac:	4785                	li	a5,1
    800045ae:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    800045b0:	00194517          	auipc	a0,0x194
    800045b4:	c8050513          	add	a0,a0,-896 # 80198230 <ftable>
    800045b8:	ffffc097          	auipc	ra,0xffffc
    800045bc:	6ce080e7          	jalr	1742(ra) # 80000c86 <release>
}
    800045c0:	8526                	mv	a0,s1
    800045c2:	60e2                	ld	ra,24(sp)
    800045c4:	6442                	ld	s0,16(sp)
    800045c6:	64a2                	ld	s1,8(sp)
    800045c8:	6105                	add	sp,sp,32
    800045ca:	8082                	ret

00000000800045cc <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    800045cc:	1101                	add	sp,sp,-32
    800045ce:	ec06                	sd	ra,24(sp)
    800045d0:	e822                	sd	s0,16(sp)
    800045d2:	e426                	sd	s1,8(sp)
    800045d4:	1000                	add	s0,sp,32
    800045d6:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    800045d8:	00194517          	auipc	a0,0x194
    800045dc:	c5850513          	add	a0,a0,-936 # 80198230 <ftable>
    800045e0:	ffffc097          	auipc	ra,0xffffc
    800045e4:	5f2080e7          	jalr	1522(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045e8:	40dc                	lw	a5,4(s1)
    800045ea:	02f05263          	blez	a5,8000460e <filedup+0x42>
    panic("filedup");
  f->ref++;
    800045ee:	2785                	addw	a5,a5,1
    800045f0:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    800045f2:	00194517          	auipc	a0,0x194
    800045f6:	c3e50513          	add	a0,a0,-962 # 80198230 <ftable>
    800045fa:	ffffc097          	auipc	ra,0xffffc
    800045fe:	68c080e7          	jalr	1676(ra) # 80000c86 <release>
  return f;
}
    80004602:	8526                	mv	a0,s1
    80004604:	60e2                	ld	ra,24(sp)
    80004606:	6442                	ld	s0,16(sp)
    80004608:	64a2                	ld	s1,8(sp)
    8000460a:	6105                	add	sp,sp,32
    8000460c:	8082                	ret
    panic("filedup");
    8000460e:	00004517          	auipc	a0,0x4
    80004612:	0ba50513          	add	a0,a0,186 # 800086c8 <syscalls+0x240>
    80004616:	ffffc097          	auipc	ra,0xffffc
    8000461a:	f26080e7          	jalr	-218(ra) # 8000053c <panic>

000000008000461e <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000461e:	7139                	add	sp,sp,-64
    80004620:	fc06                	sd	ra,56(sp)
    80004622:	f822                	sd	s0,48(sp)
    80004624:	f426                	sd	s1,40(sp)
    80004626:	f04a                	sd	s2,32(sp)
    80004628:	ec4e                	sd	s3,24(sp)
    8000462a:	e852                	sd	s4,16(sp)
    8000462c:	e456                	sd	s5,8(sp)
    8000462e:	0080                	add	s0,sp,64
    80004630:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80004632:	00194517          	auipc	a0,0x194
    80004636:	bfe50513          	add	a0,a0,-1026 # 80198230 <ftable>
    8000463a:	ffffc097          	auipc	ra,0xffffc
    8000463e:	598080e7          	jalr	1432(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004642:	40dc                	lw	a5,4(s1)
    80004644:	06f05163          	blez	a5,800046a6 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    80004648:	37fd                	addw	a5,a5,-1
    8000464a:	0007871b          	sext.w	a4,a5
    8000464e:	c0dc                	sw	a5,4(s1)
    80004650:	06e04363          	bgtz	a4,800046b6 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80004654:	0004a903          	lw	s2,0(s1)
    80004658:	0094ca83          	lbu	s5,9(s1)
    8000465c:	0104ba03          	ld	s4,16(s1)
    80004660:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80004664:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80004668:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    8000466c:	00194517          	auipc	a0,0x194
    80004670:	bc450513          	add	a0,a0,-1084 # 80198230 <ftable>
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	612080e7          	jalr	1554(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    8000467c:	4785                	li	a5,1
    8000467e:	04f90d63          	beq	s2,a5,800046d8 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004682:	3979                	addw	s2,s2,-2
    80004684:	4785                	li	a5,1
    80004686:	0527e063          	bltu	a5,s2,800046c6 <fileclose+0xa8>
    begin_op();
    8000468a:	00000097          	auipc	ra,0x0
    8000468e:	ad0080e7          	jalr	-1328(ra) # 8000415a <begin_op>
    iput(ff.ip);
    80004692:	854e                	mv	a0,s3
    80004694:	fffff097          	auipc	ra,0xfffff
    80004698:	2da080e7          	jalr	730(ra) # 8000396e <iput>
    end_op();
    8000469c:	00000097          	auipc	ra,0x0
    800046a0:	b38080e7          	jalr	-1224(ra) # 800041d4 <end_op>
    800046a4:	a00d                	j	800046c6 <fileclose+0xa8>
    panic("fileclose");
    800046a6:	00004517          	auipc	a0,0x4
    800046aa:	02a50513          	add	a0,a0,42 # 800086d0 <syscalls+0x248>
    800046ae:	ffffc097          	auipc	ra,0xffffc
    800046b2:	e8e080e7          	jalr	-370(ra) # 8000053c <panic>
    release(&ftable.lock);
    800046b6:	00194517          	auipc	a0,0x194
    800046ba:	b7a50513          	add	a0,a0,-1158 # 80198230 <ftable>
    800046be:	ffffc097          	auipc	ra,0xffffc
    800046c2:	5c8080e7          	jalr	1480(ra) # 80000c86 <release>
  }
}
    800046c6:	70e2                	ld	ra,56(sp)
    800046c8:	7442                	ld	s0,48(sp)
    800046ca:	74a2                	ld	s1,40(sp)
    800046cc:	7902                	ld	s2,32(sp)
    800046ce:	69e2                	ld	s3,24(sp)
    800046d0:	6a42                	ld	s4,16(sp)
    800046d2:	6aa2                	ld	s5,8(sp)
    800046d4:	6121                	add	sp,sp,64
    800046d6:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    800046d8:	85d6                	mv	a1,s5
    800046da:	8552                	mv	a0,s4
    800046dc:	00000097          	auipc	ra,0x0
    800046e0:	348080e7          	jalr	840(ra) # 80004a24 <pipeclose>
    800046e4:	b7cd                	j	800046c6 <fileclose+0xa8>

00000000800046e6 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    800046e6:	715d                	add	sp,sp,-80
    800046e8:	e486                	sd	ra,72(sp)
    800046ea:	e0a2                	sd	s0,64(sp)
    800046ec:	fc26                	sd	s1,56(sp)
    800046ee:	f84a                	sd	s2,48(sp)
    800046f0:	f44e                	sd	s3,40(sp)
    800046f2:	0880                	add	s0,sp,80
    800046f4:	84aa                	mv	s1,a0
    800046f6:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    800046f8:	ffffd097          	auipc	ra,0xffffd
    800046fc:	2ea080e7          	jalr	746(ra) # 800019e2 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004700:	409c                	lw	a5,0(s1)
    80004702:	37f9                	addw	a5,a5,-2
    80004704:	4705                	li	a4,1
    80004706:	04f76763          	bltu	a4,a5,80004754 <filestat+0x6e>
    8000470a:	892a                	mv	s2,a0
    ilock(f->ip);
    8000470c:	6c88                	ld	a0,24(s1)
    8000470e:	fffff097          	auipc	ra,0xfffff
    80004712:	0a6080e7          	jalr	166(ra) # 800037b4 <ilock>
    stati(f->ip, &st);
    80004716:	fb840593          	add	a1,s0,-72
    8000471a:	6c88                	ld	a0,24(s1)
    8000471c:	fffff097          	auipc	ra,0xfffff
    80004720:	322080e7          	jalr	802(ra) # 80003a3e <stati>
    iunlock(f->ip);
    80004724:	6c88                	ld	a0,24(s1)
    80004726:	fffff097          	auipc	ra,0xfffff
    8000472a:	150080e7          	jalr	336(ra) # 80003876 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000472e:	46e1                	li	a3,24
    80004730:	fb840613          	add	a2,s0,-72
    80004734:	85ce                	mv	a1,s3
    80004736:	05093503          	ld	a0,80(s2)
    8000473a:	ffffd097          	auipc	ra,0xffffd
    8000473e:	f58080e7          	jalr	-168(ra) # 80001692 <copyout>
    80004742:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80004746:	60a6                	ld	ra,72(sp)
    80004748:	6406                	ld	s0,64(sp)
    8000474a:	74e2                	ld	s1,56(sp)
    8000474c:	7942                	ld	s2,48(sp)
    8000474e:	79a2                	ld	s3,40(sp)
    80004750:	6161                	add	sp,sp,80
    80004752:	8082                	ret
  return -1;
    80004754:	557d                	li	a0,-1
    80004756:	bfc5                	j	80004746 <filestat+0x60>

0000000080004758 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004758:	7179                	add	sp,sp,-48
    8000475a:	f406                	sd	ra,40(sp)
    8000475c:	f022                	sd	s0,32(sp)
    8000475e:	ec26                	sd	s1,24(sp)
    80004760:	e84a                	sd	s2,16(sp)
    80004762:	e44e                	sd	s3,8(sp)
    80004764:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80004766:	00854783          	lbu	a5,8(a0)
    8000476a:	c3d5                	beqz	a5,8000480e <fileread+0xb6>
    8000476c:	84aa                	mv	s1,a0
    8000476e:	89ae                	mv	s3,a1
    80004770:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004772:	411c                	lw	a5,0(a0)
    80004774:	4705                	li	a4,1
    80004776:	04e78963          	beq	a5,a4,800047c8 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000477a:	470d                	li	a4,3
    8000477c:	04e78d63          	beq	a5,a4,800047d6 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004780:	4709                	li	a4,2
    80004782:	06e79e63          	bne	a5,a4,800047fe <fileread+0xa6>
    ilock(f->ip);
    80004786:	6d08                	ld	a0,24(a0)
    80004788:	fffff097          	auipc	ra,0xfffff
    8000478c:	02c080e7          	jalr	44(ra) # 800037b4 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004790:	874a                	mv	a4,s2
    80004792:	5094                	lw	a3,32(s1)
    80004794:	864e                	mv	a2,s3
    80004796:	4585                	li	a1,1
    80004798:	6c88                	ld	a0,24(s1)
    8000479a:	fffff097          	auipc	ra,0xfffff
    8000479e:	2ce080e7          	jalr	718(ra) # 80003a68 <readi>
    800047a2:	892a                	mv	s2,a0
    800047a4:	00a05563          	blez	a0,800047ae <fileread+0x56>
      f->off += r;
    800047a8:	509c                	lw	a5,32(s1)
    800047aa:	9fa9                	addw	a5,a5,a0
    800047ac:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800047ae:	6c88                	ld	a0,24(s1)
    800047b0:	fffff097          	auipc	ra,0xfffff
    800047b4:	0c6080e7          	jalr	198(ra) # 80003876 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    800047b8:	854a                	mv	a0,s2
    800047ba:	70a2                	ld	ra,40(sp)
    800047bc:	7402                	ld	s0,32(sp)
    800047be:	64e2                	ld	s1,24(sp)
    800047c0:	6942                	ld	s2,16(sp)
    800047c2:	69a2                	ld	s3,8(sp)
    800047c4:	6145                	add	sp,sp,48
    800047c6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800047c8:	6908                	ld	a0,16(a0)
    800047ca:	00000097          	auipc	ra,0x0
    800047ce:	3c2080e7          	jalr	962(ra) # 80004b8c <piperead>
    800047d2:	892a                	mv	s2,a0
    800047d4:	b7d5                	j	800047b8 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800047d6:	02451783          	lh	a5,36(a0)
    800047da:	03079693          	sll	a3,a5,0x30
    800047de:	92c1                	srl	a3,a3,0x30
    800047e0:	4725                	li	a4,9
    800047e2:	02d76863          	bltu	a4,a3,80004812 <fileread+0xba>
    800047e6:	0792                	sll	a5,a5,0x4
    800047e8:	00194717          	auipc	a4,0x194
    800047ec:	9a870713          	add	a4,a4,-1624 # 80198190 <devsw>
    800047f0:	97ba                	add	a5,a5,a4
    800047f2:	639c                	ld	a5,0(a5)
    800047f4:	c38d                	beqz	a5,80004816 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    800047f6:	4505                	li	a0,1
    800047f8:	9782                	jalr	a5
    800047fa:	892a                	mv	s2,a0
    800047fc:	bf75                	j	800047b8 <fileread+0x60>
    panic("fileread");
    800047fe:	00004517          	auipc	a0,0x4
    80004802:	ee250513          	add	a0,a0,-286 # 800086e0 <syscalls+0x258>
    80004806:	ffffc097          	auipc	ra,0xffffc
    8000480a:	d36080e7          	jalr	-714(ra) # 8000053c <panic>
    return -1;
    8000480e:	597d                	li	s2,-1
    80004810:	b765                	j	800047b8 <fileread+0x60>
      return -1;
    80004812:	597d                	li	s2,-1
    80004814:	b755                	j	800047b8 <fileread+0x60>
    80004816:	597d                	li	s2,-1
    80004818:	b745                	j	800047b8 <fileread+0x60>

000000008000481a <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    8000481a:	00954783          	lbu	a5,9(a0)
    8000481e:	10078e63          	beqz	a5,8000493a <filewrite+0x120>
{
    80004822:	715d                	add	sp,sp,-80
    80004824:	e486                	sd	ra,72(sp)
    80004826:	e0a2                	sd	s0,64(sp)
    80004828:	fc26                	sd	s1,56(sp)
    8000482a:	f84a                	sd	s2,48(sp)
    8000482c:	f44e                	sd	s3,40(sp)
    8000482e:	f052                	sd	s4,32(sp)
    80004830:	ec56                	sd	s5,24(sp)
    80004832:	e85a                	sd	s6,16(sp)
    80004834:	e45e                	sd	s7,8(sp)
    80004836:	e062                	sd	s8,0(sp)
    80004838:	0880                	add	s0,sp,80
    8000483a:	892a                	mv	s2,a0
    8000483c:	8b2e                	mv	s6,a1
    8000483e:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    80004840:	411c                	lw	a5,0(a0)
    80004842:	4705                	li	a4,1
    80004844:	02e78263          	beq	a5,a4,80004868 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004848:	470d                	li	a4,3
    8000484a:	02e78563          	beq	a5,a4,80004874 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000484e:	4709                	li	a4,2
    80004850:	0ce79d63          	bne	a5,a4,8000492a <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004854:	0ac05b63          	blez	a2,8000490a <filewrite+0xf0>
    int i = 0;
    80004858:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    8000485a:	6b85                	lui	s7,0x1
    8000485c:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004860:	6c05                	lui	s8,0x1
    80004862:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    80004866:	a851                	j	800048fa <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    80004868:	6908                	ld	a0,16(a0)
    8000486a:	00000097          	auipc	ra,0x0
    8000486e:	22a080e7          	jalr	554(ra) # 80004a94 <pipewrite>
    80004872:	a045                	j	80004912 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004874:	02451783          	lh	a5,36(a0)
    80004878:	03079693          	sll	a3,a5,0x30
    8000487c:	92c1                	srl	a3,a3,0x30
    8000487e:	4725                	li	a4,9
    80004880:	0ad76f63          	bltu	a4,a3,8000493e <filewrite+0x124>
    80004884:	0792                	sll	a5,a5,0x4
    80004886:	00194717          	auipc	a4,0x194
    8000488a:	90a70713          	add	a4,a4,-1782 # 80198190 <devsw>
    8000488e:	97ba                	add	a5,a5,a4
    80004890:	679c                	ld	a5,8(a5)
    80004892:	cbc5                	beqz	a5,80004942 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004894:	4505                	li	a0,1
    80004896:	9782                	jalr	a5
    80004898:	a8ad                	j	80004912 <filewrite+0xf8>
      if(n1 > max)
    8000489a:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000489e:	00000097          	auipc	ra,0x0
    800048a2:	8bc080e7          	jalr	-1860(ra) # 8000415a <begin_op>
      ilock(f->ip);
    800048a6:	01893503          	ld	a0,24(s2)
    800048aa:	fffff097          	auipc	ra,0xfffff
    800048ae:	f0a080e7          	jalr	-246(ra) # 800037b4 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800048b2:	8756                	mv	a4,s5
    800048b4:	02092683          	lw	a3,32(s2)
    800048b8:	01698633          	add	a2,s3,s6
    800048bc:	4585                	li	a1,1
    800048be:	01893503          	ld	a0,24(s2)
    800048c2:	fffff097          	auipc	ra,0xfffff
    800048c6:	29e080e7          	jalr	670(ra) # 80003b60 <writei>
    800048ca:	84aa                	mv	s1,a0
    800048cc:	00a05763          	blez	a0,800048da <filewrite+0xc0>
        f->off += r;
    800048d0:	02092783          	lw	a5,32(s2)
    800048d4:	9fa9                	addw	a5,a5,a0
    800048d6:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800048da:	01893503          	ld	a0,24(s2)
    800048de:	fffff097          	auipc	ra,0xfffff
    800048e2:	f98080e7          	jalr	-104(ra) # 80003876 <iunlock>
      end_op();
    800048e6:	00000097          	auipc	ra,0x0
    800048ea:	8ee080e7          	jalr	-1810(ra) # 800041d4 <end_op>

      if(r != n1){
    800048ee:	009a9f63          	bne	s5,s1,8000490c <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    800048f2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800048f6:	0149db63          	bge	s3,s4,8000490c <filewrite+0xf2>
      int n1 = n - i;
    800048fa:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800048fe:	0004879b          	sext.w	a5,s1
    80004902:	f8fbdce3          	bge	s7,a5,8000489a <filewrite+0x80>
    80004906:	84e2                	mv	s1,s8
    80004908:	bf49                	j	8000489a <filewrite+0x80>
    int i = 0;
    8000490a:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000490c:	033a1d63          	bne	s4,s3,80004946 <filewrite+0x12c>
    80004910:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004912:	60a6                	ld	ra,72(sp)
    80004914:	6406                	ld	s0,64(sp)
    80004916:	74e2                	ld	s1,56(sp)
    80004918:	7942                	ld	s2,48(sp)
    8000491a:	79a2                	ld	s3,40(sp)
    8000491c:	7a02                	ld	s4,32(sp)
    8000491e:	6ae2                	ld	s5,24(sp)
    80004920:	6b42                	ld	s6,16(sp)
    80004922:	6ba2                	ld	s7,8(sp)
    80004924:	6c02                	ld	s8,0(sp)
    80004926:	6161                	add	sp,sp,80
    80004928:	8082                	ret
    panic("filewrite");
    8000492a:	00004517          	auipc	a0,0x4
    8000492e:	dc650513          	add	a0,a0,-570 # 800086f0 <syscalls+0x268>
    80004932:	ffffc097          	auipc	ra,0xffffc
    80004936:	c0a080e7          	jalr	-1014(ra) # 8000053c <panic>
    return -1;
    8000493a:	557d                	li	a0,-1
}
    8000493c:	8082                	ret
      return -1;
    8000493e:	557d                	li	a0,-1
    80004940:	bfc9                	j	80004912 <filewrite+0xf8>
    80004942:	557d                	li	a0,-1
    80004944:	b7f9                	j	80004912 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    80004946:	557d                	li	a0,-1
    80004948:	b7e9                	j	80004912 <filewrite+0xf8>

000000008000494a <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000494a:	7179                	add	sp,sp,-48
    8000494c:	f406                	sd	ra,40(sp)
    8000494e:	f022                	sd	s0,32(sp)
    80004950:	ec26                	sd	s1,24(sp)
    80004952:	e84a                	sd	s2,16(sp)
    80004954:	e44e                	sd	s3,8(sp)
    80004956:	e052                	sd	s4,0(sp)
    80004958:	1800                	add	s0,sp,48
    8000495a:	84aa                	mv	s1,a0
    8000495c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000495e:	0005b023          	sd	zero,0(a1)
    80004962:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004966:	00000097          	auipc	ra,0x0
    8000496a:	bfc080e7          	jalr	-1028(ra) # 80004562 <filealloc>
    8000496e:	e088                	sd	a0,0(s1)
    80004970:	c551                	beqz	a0,800049fc <pipealloc+0xb2>
    80004972:	00000097          	auipc	ra,0x0
    80004976:	bf0080e7          	jalr	-1040(ra) # 80004562 <filealloc>
    8000497a:	00aa3023          	sd	a0,0(s4)
    8000497e:	c92d                	beqz	a0,800049f0 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004980:	ffffc097          	auipc	ra,0xffffc
    80004984:	162080e7          	jalr	354(ra) # 80000ae2 <kalloc>
    80004988:	892a                	mv	s2,a0
    8000498a:	c125                	beqz	a0,800049ea <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    8000498c:	4985                	li	s3,1
    8000498e:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004992:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004996:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    8000499a:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000499e:	00004597          	auipc	a1,0x4
    800049a2:	d6258593          	add	a1,a1,-670 # 80008700 <syscalls+0x278>
    800049a6:	ffffc097          	auipc	ra,0xffffc
    800049aa:	19c080e7          	jalr	412(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    800049ae:	609c                	ld	a5,0(s1)
    800049b0:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800049b4:	609c                	ld	a5,0(s1)
    800049b6:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800049ba:	609c                	ld	a5,0(s1)
    800049bc:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800049c0:	609c                	ld	a5,0(s1)
    800049c2:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800049c6:	000a3783          	ld	a5,0(s4)
    800049ca:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800049ce:	000a3783          	ld	a5,0(s4)
    800049d2:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800049d6:	000a3783          	ld	a5,0(s4)
    800049da:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800049de:	000a3783          	ld	a5,0(s4)
    800049e2:	0127b823          	sd	s2,16(a5)
  return 0;
    800049e6:	4501                	li	a0,0
    800049e8:	a025                	j	80004a10 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800049ea:	6088                	ld	a0,0(s1)
    800049ec:	e501                	bnez	a0,800049f4 <pipealloc+0xaa>
    800049ee:	a039                	j	800049fc <pipealloc+0xb2>
    800049f0:	6088                	ld	a0,0(s1)
    800049f2:	c51d                	beqz	a0,80004a20 <pipealloc+0xd6>
    fileclose(*f0);
    800049f4:	00000097          	auipc	ra,0x0
    800049f8:	c2a080e7          	jalr	-982(ra) # 8000461e <fileclose>
  if(*f1)
    800049fc:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004a00:	557d                	li	a0,-1
  if(*f1)
    80004a02:	c799                	beqz	a5,80004a10 <pipealloc+0xc6>
    fileclose(*f1);
    80004a04:	853e                	mv	a0,a5
    80004a06:	00000097          	auipc	ra,0x0
    80004a0a:	c18080e7          	jalr	-1000(ra) # 8000461e <fileclose>
  return -1;
    80004a0e:	557d                	li	a0,-1
}
    80004a10:	70a2                	ld	ra,40(sp)
    80004a12:	7402                	ld	s0,32(sp)
    80004a14:	64e2                	ld	s1,24(sp)
    80004a16:	6942                	ld	s2,16(sp)
    80004a18:	69a2                	ld	s3,8(sp)
    80004a1a:	6a02                	ld	s4,0(sp)
    80004a1c:	6145                	add	sp,sp,48
    80004a1e:	8082                	ret
  return -1;
    80004a20:	557d                	li	a0,-1
    80004a22:	b7fd                	j	80004a10 <pipealloc+0xc6>

0000000080004a24 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004a24:	1101                	add	sp,sp,-32
    80004a26:	ec06                	sd	ra,24(sp)
    80004a28:	e822                	sd	s0,16(sp)
    80004a2a:	e426                	sd	s1,8(sp)
    80004a2c:	e04a                	sd	s2,0(sp)
    80004a2e:	1000                	add	s0,sp,32
    80004a30:	84aa                	mv	s1,a0
    80004a32:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004a34:	ffffc097          	auipc	ra,0xffffc
    80004a38:	19e080e7          	jalr	414(ra) # 80000bd2 <acquire>
  if(writable){
    80004a3c:	02090d63          	beqz	s2,80004a76 <pipeclose+0x52>
    pi->writeopen = 0;
    80004a40:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004a44:	21848513          	add	a0,s1,536
    80004a48:	ffffd097          	auipc	ra,0xffffd
    80004a4c:	794080e7          	jalr	1940(ra) # 800021dc <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004a50:	2204b783          	ld	a5,544(s1)
    80004a54:	eb95                	bnez	a5,80004a88 <pipeclose+0x64>
    release(&pi->lock);
    80004a56:	8526                	mv	a0,s1
    80004a58:	ffffc097          	auipc	ra,0xffffc
    80004a5c:	22e080e7          	jalr	558(ra) # 80000c86 <release>
    kfree((char*)pi);
    80004a60:	8526                	mv	a0,s1
    80004a62:	ffffc097          	auipc	ra,0xffffc
    80004a66:	f82080e7          	jalr	-126(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    80004a6a:	60e2                	ld	ra,24(sp)
    80004a6c:	6442                	ld	s0,16(sp)
    80004a6e:	64a2                	ld	s1,8(sp)
    80004a70:	6902                	ld	s2,0(sp)
    80004a72:	6105                	add	sp,sp,32
    80004a74:	8082                	ret
    pi->readopen = 0;
    80004a76:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a7a:	21c48513          	add	a0,s1,540
    80004a7e:	ffffd097          	auipc	ra,0xffffd
    80004a82:	75e080e7          	jalr	1886(ra) # 800021dc <wakeup>
    80004a86:	b7e9                	j	80004a50 <pipeclose+0x2c>
    release(&pi->lock);
    80004a88:	8526                	mv	a0,s1
    80004a8a:	ffffc097          	auipc	ra,0xffffc
    80004a8e:	1fc080e7          	jalr	508(ra) # 80000c86 <release>
}
    80004a92:	bfe1                	j	80004a6a <pipeclose+0x46>

0000000080004a94 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a94:	711d                	add	sp,sp,-96
    80004a96:	ec86                	sd	ra,88(sp)
    80004a98:	e8a2                	sd	s0,80(sp)
    80004a9a:	e4a6                	sd	s1,72(sp)
    80004a9c:	e0ca                	sd	s2,64(sp)
    80004a9e:	fc4e                	sd	s3,56(sp)
    80004aa0:	f852                	sd	s4,48(sp)
    80004aa2:	f456                	sd	s5,40(sp)
    80004aa4:	f05a                	sd	s6,32(sp)
    80004aa6:	ec5e                	sd	s7,24(sp)
    80004aa8:	e862                	sd	s8,16(sp)
    80004aaa:	1080                	add	s0,sp,96
    80004aac:	84aa                	mv	s1,a0
    80004aae:	8aae                	mv	s5,a1
    80004ab0:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	f30080e7          	jalr	-208(ra) # 800019e2 <myproc>
    80004aba:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004abc:	8526                	mv	a0,s1
    80004abe:	ffffc097          	auipc	ra,0xffffc
    80004ac2:	114080e7          	jalr	276(ra) # 80000bd2 <acquire>
  while(i < n){
    80004ac6:	0b405663          	blez	s4,80004b72 <pipewrite+0xde>
  int i = 0;
    80004aca:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004acc:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004ace:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004ad2:	21c48b93          	add	s7,s1,540
    80004ad6:	a089                	j	80004b18 <pipewrite+0x84>
      release(&pi->lock);
    80004ad8:	8526                	mv	a0,s1
    80004ada:	ffffc097          	auipc	ra,0xffffc
    80004ade:	1ac080e7          	jalr	428(ra) # 80000c86 <release>
      return -1;
    80004ae2:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004ae4:	854a                	mv	a0,s2
    80004ae6:	60e6                	ld	ra,88(sp)
    80004ae8:	6446                	ld	s0,80(sp)
    80004aea:	64a6                	ld	s1,72(sp)
    80004aec:	6906                	ld	s2,64(sp)
    80004aee:	79e2                	ld	s3,56(sp)
    80004af0:	7a42                	ld	s4,48(sp)
    80004af2:	7aa2                	ld	s5,40(sp)
    80004af4:	7b02                	ld	s6,32(sp)
    80004af6:	6be2                	ld	s7,24(sp)
    80004af8:	6c42                	ld	s8,16(sp)
    80004afa:	6125                	add	sp,sp,96
    80004afc:	8082                	ret
      wakeup(&pi->nread);
    80004afe:	8562                	mv	a0,s8
    80004b00:	ffffd097          	auipc	ra,0xffffd
    80004b04:	6dc080e7          	jalr	1756(ra) # 800021dc <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004b08:	85a6                	mv	a1,s1
    80004b0a:	855e                	mv	a0,s7
    80004b0c:	ffffd097          	auipc	ra,0xffffd
    80004b10:	66c080e7          	jalr	1644(ra) # 80002178 <sleep>
  while(i < n){
    80004b14:	07495063          	bge	s2,s4,80004b74 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004b18:	2204a783          	lw	a5,544(s1)
    80004b1c:	dfd5                	beqz	a5,80004ad8 <pipewrite+0x44>
    80004b1e:	854e                	mv	a0,s3
    80004b20:	ffffe097          	auipc	ra,0xffffe
    80004b24:	918080e7          	jalr	-1768(ra) # 80002438 <killed>
    80004b28:	f945                	bnez	a0,80004ad8 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004b2a:	2184a783          	lw	a5,536(s1)
    80004b2e:	21c4a703          	lw	a4,540(s1)
    80004b32:	2007879b          	addw	a5,a5,512
    80004b36:	fcf704e3          	beq	a4,a5,80004afe <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004b3a:	4685                	li	a3,1
    80004b3c:	01590633          	add	a2,s2,s5
    80004b40:	faf40593          	add	a1,s0,-81
    80004b44:	0509b503          	ld	a0,80(s3)
    80004b48:	ffffd097          	auipc	ra,0xffffd
    80004b4c:	bd6080e7          	jalr	-1066(ra) # 8000171e <copyin>
    80004b50:	03650263          	beq	a0,s6,80004b74 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004b54:	21c4a783          	lw	a5,540(s1)
    80004b58:	0017871b          	addw	a4,a5,1
    80004b5c:	20e4ae23          	sw	a4,540(s1)
    80004b60:	1ff7f793          	and	a5,a5,511
    80004b64:	97a6                	add	a5,a5,s1
    80004b66:	faf44703          	lbu	a4,-81(s0)
    80004b6a:	00e78c23          	sb	a4,24(a5)
      i++;
    80004b6e:	2905                	addw	s2,s2,1
    80004b70:	b755                	j	80004b14 <pipewrite+0x80>
  int i = 0;
    80004b72:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004b74:	21848513          	add	a0,s1,536
    80004b78:	ffffd097          	auipc	ra,0xffffd
    80004b7c:	664080e7          	jalr	1636(ra) # 800021dc <wakeup>
  release(&pi->lock);
    80004b80:	8526                	mv	a0,s1
    80004b82:	ffffc097          	auipc	ra,0xffffc
    80004b86:	104080e7          	jalr	260(ra) # 80000c86 <release>
  return i;
    80004b8a:	bfa9                	j	80004ae4 <pipewrite+0x50>

0000000080004b8c <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b8c:	715d                	add	sp,sp,-80
    80004b8e:	e486                	sd	ra,72(sp)
    80004b90:	e0a2                	sd	s0,64(sp)
    80004b92:	fc26                	sd	s1,56(sp)
    80004b94:	f84a                	sd	s2,48(sp)
    80004b96:	f44e                	sd	s3,40(sp)
    80004b98:	f052                	sd	s4,32(sp)
    80004b9a:	ec56                	sd	s5,24(sp)
    80004b9c:	e85a                	sd	s6,16(sp)
    80004b9e:	0880                	add	s0,sp,80
    80004ba0:	84aa                	mv	s1,a0
    80004ba2:	892e                	mv	s2,a1
    80004ba4:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004ba6:	ffffd097          	auipc	ra,0xffffd
    80004baa:	e3c080e7          	jalr	-452(ra) # 800019e2 <myproc>
    80004bae:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004bb0:	8526                	mv	a0,s1
    80004bb2:	ffffc097          	auipc	ra,0xffffc
    80004bb6:	020080e7          	jalr	32(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bba:	2184a703          	lw	a4,536(s1)
    80004bbe:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bc2:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004bc6:	02f71763          	bne	a4,a5,80004bf4 <piperead+0x68>
    80004bca:	2244a783          	lw	a5,548(s1)
    80004bce:	c39d                	beqz	a5,80004bf4 <piperead+0x68>
    if(killed(pr)){
    80004bd0:	8552                	mv	a0,s4
    80004bd2:	ffffe097          	auipc	ra,0xffffe
    80004bd6:	866080e7          	jalr	-1946(ra) # 80002438 <killed>
    80004bda:	e949                	bnez	a0,80004c6c <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004bdc:	85a6                	mv	a1,s1
    80004bde:	854e                	mv	a0,s3
    80004be0:	ffffd097          	auipc	ra,0xffffd
    80004be4:	598080e7          	jalr	1432(ra) # 80002178 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004be8:	2184a703          	lw	a4,536(s1)
    80004bec:	21c4a783          	lw	a5,540(s1)
    80004bf0:	fcf70de3          	beq	a4,a5,80004bca <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf4:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004bf6:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bf8:	05505463          	blez	s5,80004c40 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004bfc:	2184a783          	lw	a5,536(s1)
    80004c00:	21c4a703          	lw	a4,540(s1)
    80004c04:	02f70e63          	beq	a4,a5,80004c40 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004c08:	0017871b          	addw	a4,a5,1
    80004c0c:	20e4ac23          	sw	a4,536(s1)
    80004c10:	1ff7f793          	and	a5,a5,511
    80004c14:	97a6                	add	a5,a5,s1
    80004c16:	0187c783          	lbu	a5,24(a5)
    80004c1a:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004c1e:	4685                	li	a3,1
    80004c20:	fbf40613          	add	a2,s0,-65
    80004c24:	85ca                	mv	a1,s2
    80004c26:	050a3503          	ld	a0,80(s4)
    80004c2a:	ffffd097          	auipc	ra,0xffffd
    80004c2e:	a68080e7          	jalr	-1432(ra) # 80001692 <copyout>
    80004c32:	01650763          	beq	a0,s6,80004c40 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004c36:	2985                	addw	s3,s3,1
    80004c38:	0905                	add	s2,s2,1
    80004c3a:	fd3a91e3          	bne	s5,s3,80004bfc <piperead+0x70>
    80004c3e:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004c40:	21c48513          	add	a0,s1,540
    80004c44:	ffffd097          	auipc	ra,0xffffd
    80004c48:	598080e7          	jalr	1432(ra) # 800021dc <wakeup>
  release(&pi->lock);
    80004c4c:	8526                	mv	a0,s1
    80004c4e:	ffffc097          	auipc	ra,0xffffc
    80004c52:	038080e7          	jalr	56(ra) # 80000c86 <release>
  return i;
}
    80004c56:	854e                	mv	a0,s3
    80004c58:	60a6                	ld	ra,72(sp)
    80004c5a:	6406                	ld	s0,64(sp)
    80004c5c:	74e2                	ld	s1,56(sp)
    80004c5e:	7942                	ld	s2,48(sp)
    80004c60:	79a2                	ld	s3,40(sp)
    80004c62:	7a02                	ld	s4,32(sp)
    80004c64:	6ae2                	ld	s5,24(sp)
    80004c66:	6b42                	ld	s6,16(sp)
    80004c68:	6161                	add	sp,sp,80
    80004c6a:	8082                	ret
      release(&pi->lock);
    80004c6c:	8526                	mv	a0,s1
    80004c6e:	ffffc097          	auipc	ra,0xffffc
    80004c72:	018080e7          	jalr	24(ra) # 80000c86 <release>
      return -1;
    80004c76:	59fd                	li	s3,-1
    80004c78:	bff9                	j	80004c56 <piperead+0xca>

0000000080004c7a <flags2perm>:

// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c7a:	1141                	add	sp,sp,-16
    80004c7c:	e422                	sd	s0,8(sp)
    80004c7e:	0800                	add	s0,sp,16
    80004c80:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c82:	8905                	and	a0,a0,1
    80004c84:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c86:	8b89                	and	a5,a5,2
    80004c88:	c399                	beqz	a5,80004c8e <flags2perm+0x14>
      perm |= PTE_W;
    80004c8a:	00456513          	or	a0,a0,4
    return perm;
}
    80004c8e:	6422                	ld	s0,8(sp)
    80004c90:	0141                	add	sp,sp,16
    80004c92:	8082                	ret

0000000080004c94 <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c94:	c749                	beqz	a4,80004d1e <loadseg+0x8a>
{
    80004c96:	711d                	add	sp,sp,-96
    80004c98:	ec86                	sd	ra,88(sp)
    80004c9a:	e8a2                	sd	s0,80(sp)
    80004c9c:	e4a6                	sd	s1,72(sp)
    80004c9e:	e0ca                	sd	s2,64(sp)
    80004ca0:	fc4e                	sd	s3,56(sp)
    80004ca2:	f852                	sd	s4,48(sp)
    80004ca4:	f456                	sd	s5,40(sp)
    80004ca6:	f05a                	sd	s6,32(sp)
    80004ca8:	ec5e                	sd	s7,24(sp)
    80004caa:	e862                	sd	s8,16(sp)
    80004cac:	e466                	sd	s9,8(sp)
    80004cae:	1080                	add	s0,sp,96
    80004cb0:	8aaa                	mv	s5,a0
    80004cb2:	8b2e                	mv	s6,a1
    80004cb4:	8bb2                	mv	s7,a2
    80004cb6:	8c36                	mv	s8,a3
    80004cb8:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004cba:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004cbc:	6c85                	lui	s9,0x1
    80004cbe:	6a05                	lui	s4,0x1
    80004cc0:	a815                	j	80004cf4 <loadseg+0x60>
      panic("loadseg: address should exist");
    80004cc2:	00004517          	auipc	a0,0x4
    80004cc6:	a4650513          	add	a0,a0,-1466 # 80008708 <syscalls+0x280>
    80004cca:	ffffc097          	auipc	ra,0xffffc
    80004cce:	872080e7          	jalr	-1934(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004cd2:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004cd4:	8726                	mv	a4,s1
    80004cd6:	012c06bb          	addw	a3,s8,s2
    80004cda:	4581                	li	a1,0
    80004cdc:	855e                	mv	a0,s7
    80004cde:	fffff097          	auipc	ra,0xfffff
    80004ce2:	d8a080e7          	jalr	-630(ra) # 80003a68 <readi>
    80004ce6:	2501                	sext.w	a0,a0
    80004ce8:	02951d63          	bne	a0,s1,80004d22 <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004cec:	012a093b          	addw	s2,s4,s2
    80004cf0:	03397563          	bgeu	s2,s3,80004d1a <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004cf4:	02091593          	sll	a1,s2,0x20
    80004cf8:	9181                	srl	a1,a1,0x20
    80004cfa:	95da                	add	a1,a1,s6
    80004cfc:	8556                	mv	a0,s5
    80004cfe:	ffffc097          	auipc	ra,0xffffc
    80004d02:	360080e7          	jalr	864(ra) # 8000105e <walkaddr>
    80004d06:	862a                	mv	a2,a0
    if(pa == 0)
    80004d08:	dd4d                	beqz	a0,80004cc2 <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004d0a:	412984bb          	subw	s1,s3,s2
    80004d0e:	0004879b          	sext.w	a5,s1
    80004d12:	fcfcf0e3          	bgeu	s9,a5,80004cd2 <loadseg+0x3e>
    80004d16:	84d2                	mv	s1,s4
    80004d18:	bf6d                	j	80004cd2 <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004d1a:	4501                	li	a0,0
    80004d1c:	a021                	j	80004d24 <loadseg+0x90>
    80004d1e:	4501                	li	a0,0
}
    80004d20:	8082                	ret
      return -1;
    80004d22:	557d                	li	a0,-1
}
    80004d24:	60e6                	ld	ra,88(sp)
    80004d26:	6446                	ld	s0,80(sp)
    80004d28:	64a6                	ld	s1,72(sp)
    80004d2a:	6906                	ld	s2,64(sp)
    80004d2c:	79e2                	ld	s3,56(sp)
    80004d2e:	7a42                	ld	s4,48(sp)
    80004d30:	7aa2                	ld	s5,40(sp)
    80004d32:	7b02                	ld	s6,32(sp)
    80004d34:	6be2                	ld	s7,24(sp)
    80004d36:	6c42                	ld	s8,16(sp)
    80004d38:	6ca2                	ld	s9,8(sp)
    80004d3a:	6125                	add	sp,sp,96
    80004d3c:	8082                	ret

0000000080004d3e <exec>:
{
    80004d3e:	7101                	add	sp,sp,-512
    80004d40:	ff86                	sd	ra,504(sp)
    80004d42:	fba2                	sd	s0,496(sp)
    80004d44:	f7a6                	sd	s1,488(sp)
    80004d46:	f3ca                	sd	s2,480(sp)
    80004d48:	efce                	sd	s3,472(sp)
    80004d4a:	ebd2                	sd	s4,464(sp)
    80004d4c:	e7d6                	sd	s5,456(sp)
    80004d4e:	e3da                	sd	s6,448(sp)
    80004d50:	ff5e                	sd	s7,440(sp)
    80004d52:	fb62                	sd	s8,432(sp)
    80004d54:	f766                	sd	s9,424(sp)
    80004d56:	f36a                	sd	s10,416(sp)
    80004d58:	ef6e                	sd	s11,408(sp)
    80004d5a:	0400                	add	s0,sp,512
    80004d5c:	89aa                	mv	s3,a0
    80004d5e:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80004d60:	ffffd097          	auipc	ra,0xffffd
    80004d64:	c82080e7          	jalr	-894(ra) # 800019e2 <myproc>
    80004d68:	8a2a                	mv	s4,a0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004d6a:	4615                	li	a2,5
    80004d6c:	00003597          	auipc	a1,0x3
    80004d70:	4d458593          	add	a1,a1,1236 # 80008240 <digits+0x200>
    80004d74:	854e                	mv	a0,s3
    80004d76:	ffffc097          	auipc	ra,0xffffc
    80004d7a:	028080e7          	jalr	40(ra) # 80000d9e <strncmp>
    80004d7e:	e159                	bnez	a0,80004e04 <exec+0xc6>
    80004d80:	160a0423          	sb	zero,360(s4) # 1168 <_entry-0x7fffee98>
  begin_op();
    80004d84:	fffff097          	auipc	ra,0xfffff
    80004d88:	3d6080e7          	jalr	982(ra) # 8000415a <begin_op>
  if((ip = namei(path)) == 0){
    80004d8c:	854e                	mv	a0,s3
    80004d8e:	fffff097          	auipc	ra,0xfffff
    80004d92:	1cc080e7          	jalr	460(ra) # 80003f5a <namei>
    80004d96:	84aa                	mv	s1,a0
    80004d98:	c959                	beqz	a0,80004e2e <exec+0xf0>
  ilock(ip);
    80004d9a:	fffff097          	auipc	ra,0xfffff
    80004d9e:	a1a080e7          	jalr	-1510(ra) # 800037b4 <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004da2:	04000713          	li	a4,64
    80004da6:	4681                	li	a3,0
    80004da8:	e5040613          	add	a2,s0,-432
    80004dac:	4581                	li	a1,0
    80004dae:	8526                	mv	a0,s1
    80004db0:	fffff097          	auipc	ra,0xfffff
    80004db4:	cb8080e7          	jalr	-840(ra) # 80003a68 <readi>
    80004db8:	04000793          	li	a5,64
    80004dbc:	00f51a63          	bne	a0,a5,80004dd0 <exec+0x92>
  if(elf.magic != ELF_MAGIC)
    80004dc0:	e5042703          	lw	a4,-432(s0)
    80004dc4:	464c47b7          	lui	a5,0x464c4
    80004dc8:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004dcc:	06f70763          	beq	a4,a5,80004e3a <exec+0xfc>
    iunlockput(ip);
    80004dd0:	8526                	mv	a0,s1
    80004dd2:	fffff097          	auipc	ra,0xfffff
    80004dd6:	c44080e7          	jalr	-956(ra) # 80003a16 <iunlockput>
    end_op();
    80004dda:	fffff097          	auipc	ra,0xfffff
    80004dde:	3fa080e7          	jalr	1018(ra) # 800041d4 <end_op>
  return -1;
    80004de2:	557d                	li	a0,-1
}
    80004de4:	70fe                	ld	ra,504(sp)
    80004de6:	745e                	ld	s0,496(sp)
    80004de8:	74be                	ld	s1,488(sp)
    80004dea:	791e                	ld	s2,480(sp)
    80004dec:	69fe                	ld	s3,472(sp)
    80004dee:	6a5e                	ld	s4,464(sp)
    80004df0:	6abe                	ld	s5,456(sp)
    80004df2:	6b1e                	ld	s6,448(sp)
    80004df4:	7bfa                	ld	s7,440(sp)
    80004df6:	7c5a                	ld	s8,432(sp)
    80004df8:	7cba                	ld	s9,424(sp)
    80004dfa:	7d1a                	ld	s10,416(sp)
    80004dfc:	6dfa                	ld	s11,408(sp)
    80004dfe:	20010113          	add	sp,sp,512
    80004e02:	8082                	ret
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004e04:	4609                	li	a2,2
    80004e06:	00003597          	auipc	a1,0x3
    80004e0a:	44258593          	add	a1,a1,1090 # 80008248 <digits+0x208>
    80004e0e:	854e                	mv	a0,s3
    80004e10:	ffffc097          	auipc	ra,0xffffc
    80004e14:	f8e080e7          	jalr	-114(ra) # 80000d9e <strncmp>
    80004e18:	00a037b3          	snez	a5,a0
    80004e1c:	16fa0423          	sb	a5,360(s4)
  if (p->ondemand == true) {
    80004e20:	d135                	beqz	a0,80004d84 <exec+0x46>
    print_ondemand_proc(path);
    80004e22:	854e                	mv	a0,s3
    80004e24:	00002097          	auipc	ra,0x2
    80004e28:	ac8080e7          	jalr	-1336(ra) # 800068ec <print_ondemand_proc>
    80004e2c:	bfa1                	j	80004d84 <exec+0x46>
    end_op();
    80004e2e:	fffff097          	auipc	ra,0xfffff
    80004e32:	3a6080e7          	jalr	934(ra) # 800041d4 <end_op>
    return -1;
    80004e36:	557d                	li	a0,-1
    80004e38:	b775                	j	80004de4 <exec+0xa6>
  if((pagetable = proc_pagetable(p)) == 0)
    80004e3a:	8552                	mv	a0,s4
    80004e3c:	ffffd097          	auipc	ra,0xffffd
    80004e40:	c6a080e7          	jalr	-918(ra) # 80001aa6 <proc_pagetable>
    80004e44:	8caa                	mv	s9,a0
    80004e46:	d549                	beqz	a0,80004dd0 <exec+0x92>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e48:	e7042903          	lw	s2,-400(s0)
    80004e4c:	e8845783          	lhu	a5,-376(s0)
    80004e50:	c7ed                	beqz	a5,80004f3a <exec+0x1fc>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004e52:	4b81                	li	s7,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e54:	4a81                	li	s5,0
    if(ph.type != ELF_PROG_LOAD)
    80004e56:	4d05                	li	s10,1
    if(ph.vaddr % PGSIZE != 0)
    80004e58:	6785                	lui	a5,0x1
    80004e5a:	fff78d93          	add	s11,a5,-1 # fff <_entry-0x7ffff001>
      memset(psa_tracker, false, PSASIZE);
    80004e5e:	fa078793          	add	a5,a5,-96
    80004e62:	e0f43423          	sd	a5,-504(s0)
    80004e66:	a0a9                	j	80004eb0 <exec+0x172>
    80004e68:	e0843603          	ld	a2,-504(s0)
    80004e6c:	4581                	li	a1,0
    80004e6e:	00194517          	auipc	a0,0x194
    80004e72:	4ba50513          	add	a0,a0,1210 # 80199328 <psa_tracker>
    80004e76:	ffffc097          	auipc	ra,0xffffc
    80004e7a:	e58080e7          	jalr	-424(ra) # 80000cce <memset>
      print_skip_section(path, ph.vaddr, ph.memsz);
    80004e7e:	e4042603          	lw	a2,-448(s0)
    80004e82:	e2843583          	ld	a1,-472(s0)
    80004e86:	854e                	mv	a0,s3
    80004e88:	00002097          	auipc	ra,0x2
    80004e8c:	a86080e7          	jalr	-1402(ra) # 8000690e <print_skip_section>
      sz = PGROUNDUP(ph.vaddr + ph.memsz);
    80004e90:	e2843b83          	ld	s7,-472(s0)
    80004e94:	e4043783          	ld	a5,-448(s0)
    80004e98:	9bbe                	add	s7,s7,a5
    80004e9a:	9bee                	add	s7,s7,s11
    80004e9c:	77fd                	lui	a5,0xfffff
    80004e9e:	00fbfbb3          	and	s7,s7,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004ea2:	2a85                	addw	s5,s5,1
    80004ea4:	0389091b          	addw	s2,s2,56
    80004ea8:	e8845783          	lhu	a5,-376(s0)
    80004eac:	08fad863          	bge	s5,a5,80004f3c <exec+0x1fe>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004eb0:	2901                	sext.w	s2,s2
    80004eb2:	03800713          	li	a4,56
    80004eb6:	86ca                	mv	a3,s2
    80004eb8:	e1840613          	add	a2,s0,-488
    80004ebc:	4581                	li	a1,0
    80004ebe:	8526                	mv	a0,s1
    80004ec0:	fffff097          	auipc	ra,0xfffff
    80004ec4:	ba8080e7          	jalr	-1112(ra) # 80003a68 <readi>
    80004ec8:	03800793          	li	a5,56
    80004ecc:	0af51c63          	bne	a0,a5,80004f84 <exec+0x246>
    if(ph.type != ELF_PROG_LOAD)
    80004ed0:	e1842783          	lw	a5,-488(s0)
    80004ed4:	fda797e3          	bne	a5,s10,80004ea2 <exec+0x164>
    if(ph.memsz < ph.filesz)
    80004ed8:	e4043b03          	ld	s6,-448(s0)
    80004edc:	e3843783          	ld	a5,-456(s0)
    80004ee0:	0afb6263          	bltu	s6,a5,80004f84 <exec+0x246>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004ee4:	e2843783          	ld	a5,-472(s0)
    80004ee8:	9b3e                	add	s6,s6,a5
    80004eea:	08fb6d63          	bltu	s6,a5,80004f84 <exec+0x246>
    if(ph.vaddr % PGSIZE != 0)
    80004eee:	01b7f7b3          	and	a5,a5,s11
    80004ef2:	ebc9                	bnez	a5,80004f84 <exec+0x246>
    if(p->ondemand == false){
    80004ef4:	168a4783          	lbu	a5,360(s4)
    80004ef8:	fba5                	bnez	a5,80004e68 <exec+0x12a>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004efa:	e1c42503          	lw	a0,-484(s0)
    80004efe:	00000097          	auipc	ra,0x0
    80004f02:	d7c080e7          	jalr	-644(ra) # 80004c7a <flags2perm>
    80004f06:	86aa                	mv	a3,a0
    80004f08:	865a                	mv	a2,s6
    80004f0a:	85de                	mv	a1,s7
    80004f0c:	8566                	mv	a0,s9
    80004f0e:	ffffc097          	auipc	ra,0xffffc
    80004f12:	4f6080e7          	jalr	1270(ra) # 80001404 <uvmalloc>
    80004f16:	8b2a                	mv	s6,a0
    80004f18:	c535                	beqz	a0,80004f84 <exec+0x246>
      if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004f1a:	e3842703          	lw	a4,-456(s0)
    80004f1e:	e2042683          	lw	a3,-480(s0)
    80004f22:	8626                	mv	a2,s1
    80004f24:	e2843583          	ld	a1,-472(s0)
    80004f28:	8566                	mv	a0,s9
    80004f2a:	00000097          	auipc	ra,0x0
    80004f2e:	d6a080e7          	jalr	-662(ra) # 80004c94 <loadseg>
    80004f32:	1a054263          	bltz	a0,800050d6 <exec+0x398>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f36:	8bda                	mv	s7,s6
    80004f38:	b7ad                	j	80004ea2 <exec+0x164>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f3a:	4b81                	li	s7,0
  iunlockput(ip);
    80004f3c:	8526                	mv	a0,s1
    80004f3e:	fffff097          	auipc	ra,0xfffff
    80004f42:	ad8080e7          	jalr	-1320(ra) # 80003a16 <iunlockput>
  end_op();
    80004f46:	fffff097          	auipc	ra,0xfffff
    80004f4a:	28e080e7          	jalr	654(ra) # 800041d4 <end_op>
  p = myproc();
    80004f4e:	ffffd097          	auipc	ra,0xffffd
    80004f52:	a94080e7          	jalr	-1388(ra) # 800019e2 <myproc>
    80004f56:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004f58:	653c                	ld	a5,72(a0)
    80004f5a:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004f5e:	6a05                	lui	s4,0x1
    80004f60:	1a7d                	add	s4,s4,-1 # fff <_entry-0x7ffff001>
    80004f62:	9a5e                	add	s4,s4,s7
    80004f64:	77fd                	lui	a5,0xfffff
    80004f66:	00fa7a33          	and	s4,s4,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004f6a:	4691                	li	a3,4
    80004f6c:	6609                	lui	a2,0x2
    80004f6e:	9652                	add	a2,a2,s4
    80004f70:	85d2                	mv	a1,s4
    80004f72:	8566                	mv	a0,s9
    80004f74:	ffffc097          	auipc	ra,0xffffc
    80004f78:	490080e7          	jalr	1168(ra) # 80001404 <uvmalloc>
    80004f7c:	8baa                	mv	s7,a0
    80004f7e:	ed09                	bnez	a0,80004f98 <exec+0x25a>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004f80:	8bd2                	mv	s7,s4
    80004f82:	4481                	li	s1,0
    proc_freepagetable(pagetable, sz);
    80004f84:	85de                	mv	a1,s7
    80004f86:	8566                	mv	a0,s9
    80004f88:	ffffd097          	auipc	ra,0xffffd
    80004f8c:	bba080e7          	jalr	-1094(ra) # 80001b42 <proc_freepagetable>
  return -1;
    80004f90:	557d                	li	a0,-1
  if(ip){
    80004f92:	e40489e3          	beqz	s1,80004de4 <exec+0xa6>
    80004f96:	bd2d                	j	80004dd0 <exec+0x92>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004f98:	75f9                	lui	a1,0xffffe
    80004f9a:	95aa                	add	a1,a1,a0
    80004f9c:	8566                	mv	a0,s9
    80004f9e:	ffffc097          	auipc	ra,0xffffc
    80004fa2:	690080e7          	jalr	1680(ra) # 8000162e <uvmclear>
  stackbase = sp - PGSIZE;
    80004fa6:	7b7d                	lui	s6,0xfffff
    80004fa8:	9b5e                	add	s6,s6,s7
  for(argc = 0; argv[argc]; argc++) {
    80004faa:	000c3503          	ld	a0,0(s8)
    80004fae:	c125                	beqz	a0,8000500e <exec+0x2d0>
    80004fb0:	e9040a13          	add	s4,s0,-368
    80004fb4:	f9040d93          	add	s11,s0,-112
  sp = sz;
    80004fb8:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80004fba:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fbc:	ffffc097          	auipc	ra,0xffffc
    80004fc0:	e8c080e7          	jalr	-372(ra) # 80000e48 <strlen>
    80004fc4:	2505                	addw	a0,a0,1
    80004fc6:	40a90533          	sub	a0,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004fca:	ff057913          	and	s2,a0,-16
    if(sp < stackbase)
    80004fce:	11696663          	bltu	s2,s6,800050da <exec+0x39c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004fd2:	000c3a83          	ld	s5,0(s8)
    80004fd6:	8556                	mv	a0,s5
    80004fd8:	ffffc097          	auipc	ra,0xffffc
    80004fdc:	e70080e7          	jalr	-400(ra) # 80000e48 <strlen>
    80004fe0:	0015069b          	addw	a3,a0,1
    80004fe4:	8656                	mv	a2,s5
    80004fe6:	85ca                	mv	a1,s2
    80004fe8:	8566                	mv	a0,s9
    80004fea:	ffffc097          	auipc	ra,0xffffc
    80004fee:	6a8080e7          	jalr	1704(ra) # 80001692 <copyout>
    80004ff2:	0e054663          	bltz	a0,800050de <exec+0x3a0>
    ustack[argc] = sp;
    80004ff6:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80004ffa:	0485                	add	s1,s1,1
    80004ffc:	0c21                	add	s8,s8,8
    80004ffe:	000c3503          	ld	a0,0(s8)
    80005002:	c901                	beqz	a0,80005012 <exec+0x2d4>
    if(argc >= MAXARG)
    80005004:	0a21                	add	s4,s4,8
    80005006:	fbba1be3          	bne	s4,s11,80004fbc <exec+0x27e>
  ip = 0;
    8000500a:	4481                	li	s1,0
    8000500c:	bfa5                	j	80004f84 <exec+0x246>
  sp = sz;
    8000500e:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80005010:	4481                	li	s1,0
  ustack[argc] = 0;
    80005012:	00349793          	sll	a5,s1,0x3
    80005016:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fe64cc8>
    8000501a:	97a2                	add	a5,a5,s0
    8000501c:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005020:	00148693          	add	a3,s1,1
    80005024:	068e                	sll	a3,a3,0x3
    80005026:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000502a:	ff097913          	and	s2,s2,-16
  sz = sz1;
    8000502e:	8a5e                	mv	s4,s7
  if(sp < stackbase)
    80005030:	f56968e3          	bltu	s2,s6,80004f80 <exec+0x242>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80005034:	e9040613          	add	a2,s0,-368
    80005038:	85ca                	mv	a1,s2
    8000503a:	8566                	mv	a0,s9
    8000503c:	ffffc097          	auipc	ra,0xffffc
    80005040:	656080e7          	jalr	1622(ra) # 80001692 <copyout>
    80005044:	f2054ee3          	bltz	a0,80004f80 <exec+0x242>
  p->trapframe->a1 = sp;
    80005048:	058d3783          	ld	a5,88(s10)
    8000504c:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005050:	0009c703          	lbu	a4,0(s3)
    80005054:	cf11                	beqz	a4,80005070 <exec+0x332>
    80005056:	00198793          	add	a5,s3,1
    if(*s == '/')
    8000505a:	02f00693          	li	a3,47
    8000505e:	a029                	j	80005068 <exec+0x32a>
  for(last=s=path; *s; s++)
    80005060:	0785                	add	a5,a5,1
    80005062:	fff7c703          	lbu	a4,-1(a5)
    80005066:	c709                	beqz	a4,80005070 <exec+0x332>
    if(*s == '/')
    80005068:	fed71ce3          	bne	a4,a3,80005060 <exec+0x322>
      last = s+1;
    8000506c:	89be                	mv	s3,a5
    8000506e:	bfcd                	j	80005060 <exec+0x322>
  safestrcpy(p->name, last, sizeof(p->name));
    80005070:	4641                	li	a2,16
    80005072:	85ce                	mv	a1,s3
    80005074:	158d0513          	add	a0,s10,344
    80005078:	ffffc097          	auipc	ra,0xffffc
    8000507c:	d9e080e7          	jalr	-610(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80005080:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80005084:	059d3823          	sd	s9,80(s10)
  p->sz = sz;
    80005088:	057d3423          	sd	s7,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    8000508c:	058d3783          	ld	a5,88(s10)
    80005090:	e6843703          	ld	a4,-408(s0)
    80005094:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80005096:	058d3783          	ld	a5,88(s10)
    8000509a:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000509e:	e0843583          	ld	a1,-504(s0)
    800050a2:	ffffd097          	auipc	ra,0xffffd
    800050a6:	aa0080e7          	jalr	-1376(ra) # 80001b42 <proc_freepagetable>
  for (int i = 0; i < MAXHEAP; i++) {
    800050aa:	170d0793          	add	a5,s10,368
    800050ae:	6699                	lui	a3,0x6
    800050b0:	f3068693          	add	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    800050b4:	96ea                	add	a3,a3,s10
    p->heap_tracker[i].addr            = 0xFFFFFFFFFFFFFFFF;
    800050b6:	577d                	li	a4,-1
    800050b8:	e398                	sd	a4,0(a5)
    p->heap_tracker[i].startblock      = -1;
    800050ba:	cbd8                	sw	a4,20(a5)
    p->heap_tracker[i].last_load_time  = 0xFFFFFFFFFFFFFFFF;
    800050bc:	e798                	sd	a4,8(a5)
    p->heap_tracker[i].loaded          = false;
    800050be:	00078823          	sb	zero,16(a5)
  for (int i = 0; i < MAXHEAP; i++) {
    800050c2:	07e1                	add	a5,a5,24
    800050c4:	fed79ae3          	bne	a5,a3,800050b8 <exec+0x37a>
  p->resident_heap_pages = 0;
    800050c8:	6799                	lui	a5,0x6
    800050ca:	9d3e                	add	s10,s10,a5
    800050cc:	f20d2823          	sw	zero,-208(s10)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050d0:	0004851b          	sext.w	a0,s1
    800050d4:	bb01                	j	80004de4 <exec+0xa6>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800050d6:	8bda                	mv	s7,s6
    800050d8:	b575                	j	80004f84 <exec+0x246>
  ip = 0;
    800050da:	4481                	li	s1,0
    800050dc:	b565                	j	80004f84 <exec+0x246>
    800050de:	4481                	li	s1,0
  if(pagetable)
    800050e0:	b555                	j	80004f84 <exec+0x246>

00000000800050e2 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800050e2:	7179                	add	sp,sp,-48
    800050e4:	f406                	sd	ra,40(sp)
    800050e6:	f022                	sd	s0,32(sp)
    800050e8:	ec26                	sd	s1,24(sp)
    800050ea:	e84a                	sd	s2,16(sp)
    800050ec:	1800                	add	s0,sp,48
    800050ee:	892e                	mv	s2,a1
    800050f0:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800050f2:	fdc40593          	add	a1,s0,-36
    800050f6:	ffffe097          	auipc	ra,0xffffe
    800050fa:	b5c080e7          	jalr	-1188(ra) # 80002c52 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800050fe:	fdc42703          	lw	a4,-36(s0)
    80005102:	47bd                	li	a5,15
    80005104:	02e7eb63          	bltu	a5,a4,8000513a <argfd+0x58>
    80005108:	ffffd097          	auipc	ra,0xffffd
    8000510c:	8da080e7          	jalr	-1830(ra) # 800019e2 <myproc>
    80005110:	fdc42703          	lw	a4,-36(s0)
    80005114:	01a70793          	add	a5,a4,26
    80005118:	078e                	sll	a5,a5,0x3
    8000511a:	953e                	add	a0,a0,a5
    8000511c:	611c                	ld	a5,0(a0)
    8000511e:	c385                	beqz	a5,8000513e <argfd+0x5c>
    return -1;
  if(pfd)
    80005120:	00090463          	beqz	s2,80005128 <argfd+0x46>
    *pfd = fd;
    80005124:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005128:	4501                	li	a0,0
  if(pf)
    8000512a:	c091                	beqz	s1,8000512e <argfd+0x4c>
    *pf = f;
    8000512c:	e09c                	sd	a5,0(s1)
}
    8000512e:	70a2                	ld	ra,40(sp)
    80005130:	7402                	ld	s0,32(sp)
    80005132:	64e2                	ld	s1,24(sp)
    80005134:	6942                	ld	s2,16(sp)
    80005136:	6145                	add	sp,sp,48
    80005138:	8082                	ret
    return -1;
    8000513a:	557d                	li	a0,-1
    8000513c:	bfcd                	j	8000512e <argfd+0x4c>
    8000513e:	557d                	li	a0,-1
    80005140:	b7fd                	j	8000512e <argfd+0x4c>

0000000080005142 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80005142:	1101                	add	sp,sp,-32
    80005144:	ec06                	sd	ra,24(sp)
    80005146:	e822                	sd	s0,16(sp)
    80005148:	e426                	sd	s1,8(sp)
    8000514a:	1000                	add	s0,sp,32
    8000514c:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    8000514e:	ffffd097          	auipc	ra,0xffffd
    80005152:	894080e7          	jalr	-1900(ra) # 800019e2 <myproc>
    80005156:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005158:	0d050793          	add	a5,a0,208
    8000515c:	4501                	li	a0,0
    8000515e:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005160:	6398                	ld	a4,0(a5)
    80005162:	cb19                	beqz	a4,80005178 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80005164:	2505                	addw	a0,a0,1
    80005166:	07a1                	add	a5,a5,8 # 6008 <_entry-0x7fff9ff8>
    80005168:	fed51ce3          	bne	a0,a3,80005160 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    8000516c:	557d                	li	a0,-1
}
    8000516e:	60e2                	ld	ra,24(sp)
    80005170:	6442                	ld	s0,16(sp)
    80005172:	64a2                	ld	s1,8(sp)
    80005174:	6105                	add	sp,sp,32
    80005176:	8082                	ret
      p->ofile[fd] = f;
    80005178:	01a50793          	add	a5,a0,26
    8000517c:	078e                	sll	a5,a5,0x3
    8000517e:	963e                	add	a2,a2,a5
    80005180:	e204                	sd	s1,0(a2)
      return fd;
    80005182:	b7f5                	j	8000516e <fdalloc+0x2c>

0000000080005184 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80005184:	715d                	add	sp,sp,-80
    80005186:	e486                	sd	ra,72(sp)
    80005188:	e0a2                	sd	s0,64(sp)
    8000518a:	fc26                	sd	s1,56(sp)
    8000518c:	f84a                	sd	s2,48(sp)
    8000518e:	f44e                	sd	s3,40(sp)
    80005190:	f052                	sd	s4,32(sp)
    80005192:	ec56                	sd	s5,24(sp)
    80005194:	e85a                	sd	s6,16(sp)
    80005196:	0880                	add	s0,sp,80
    80005198:	8b2e                	mv	s6,a1
    8000519a:	89b2                	mv	s3,a2
    8000519c:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    8000519e:	fb040593          	add	a1,s0,-80
    800051a2:	fffff097          	auipc	ra,0xfffff
    800051a6:	dd6080e7          	jalr	-554(ra) # 80003f78 <nameiparent>
    800051aa:	84aa                	mv	s1,a0
    800051ac:	14050b63          	beqz	a0,80005302 <create+0x17e>
    return 0;

  ilock(dp);
    800051b0:	ffffe097          	auipc	ra,0xffffe
    800051b4:	604080e7          	jalr	1540(ra) # 800037b4 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800051b8:	4601                	li	a2,0
    800051ba:	fb040593          	add	a1,s0,-80
    800051be:	8526                	mv	a0,s1
    800051c0:	fffff097          	auipc	ra,0xfffff
    800051c4:	ad8080e7          	jalr	-1320(ra) # 80003c98 <dirlookup>
    800051c8:	8aaa                	mv	s5,a0
    800051ca:	c921                	beqz	a0,8000521a <create+0x96>
    iunlockput(dp);
    800051cc:	8526                	mv	a0,s1
    800051ce:	fffff097          	auipc	ra,0xfffff
    800051d2:	848080e7          	jalr	-1976(ra) # 80003a16 <iunlockput>
    ilock(ip);
    800051d6:	8556                	mv	a0,s5
    800051d8:	ffffe097          	auipc	ra,0xffffe
    800051dc:	5dc080e7          	jalr	1500(ra) # 800037b4 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800051e0:	4789                	li	a5,2
    800051e2:	02fb1563          	bne	s6,a5,8000520c <create+0x88>
    800051e6:	044ad783          	lhu	a5,68(s5)
    800051ea:	37f9                	addw	a5,a5,-2
    800051ec:	17c2                	sll	a5,a5,0x30
    800051ee:	93c1                	srl	a5,a5,0x30
    800051f0:	4705                	li	a4,1
    800051f2:	00f76d63          	bltu	a4,a5,8000520c <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800051f6:	8556                	mv	a0,s5
    800051f8:	60a6                	ld	ra,72(sp)
    800051fa:	6406                	ld	s0,64(sp)
    800051fc:	74e2                	ld	s1,56(sp)
    800051fe:	7942                	ld	s2,48(sp)
    80005200:	79a2                	ld	s3,40(sp)
    80005202:	7a02                	ld	s4,32(sp)
    80005204:	6ae2                	ld	s5,24(sp)
    80005206:	6b42                	ld	s6,16(sp)
    80005208:	6161                	add	sp,sp,80
    8000520a:	8082                	ret
    iunlockput(ip);
    8000520c:	8556                	mv	a0,s5
    8000520e:	fffff097          	auipc	ra,0xfffff
    80005212:	808080e7          	jalr	-2040(ra) # 80003a16 <iunlockput>
    return 0;
    80005216:	4a81                	li	s5,0
    80005218:	bff9                	j	800051f6 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    8000521a:	85da                	mv	a1,s6
    8000521c:	4088                	lw	a0,0(s1)
    8000521e:	ffffe097          	auipc	ra,0xffffe
    80005222:	3fe080e7          	jalr	1022(ra) # 8000361c <ialloc>
    80005226:	8a2a                	mv	s4,a0
    80005228:	c529                	beqz	a0,80005272 <create+0xee>
  ilock(ip);
    8000522a:	ffffe097          	auipc	ra,0xffffe
    8000522e:	58a080e7          	jalr	1418(ra) # 800037b4 <ilock>
  ip->major = major;
    80005232:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005236:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    8000523a:	4905                	li	s2,1
    8000523c:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005240:	8552                	mv	a0,s4
    80005242:	ffffe097          	auipc	ra,0xffffe
    80005246:	4a6080e7          	jalr	1190(ra) # 800036e8 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000524a:	032b0b63          	beq	s6,s2,80005280 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    8000524e:	004a2603          	lw	a2,4(s4)
    80005252:	fb040593          	add	a1,s0,-80
    80005256:	8526                	mv	a0,s1
    80005258:	fffff097          	auipc	ra,0xfffff
    8000525c:	c50080e7          	jalr	-944(ra) # 80003ea8 <dirlink>
    80005260:	06054f63          	bltz	a0,800052de <create+0x15a>
  iunlockput(dp);
    80005264:	8526                	mv	a0,s1
    80005266:	ffffe097          	auipc	ra,0xffffe
    8000526a:	7b0080e7          	jalr	1968(ra) # 80003a16 <iunlockput>
  return ip;
    8000526e:	8ad2                	mv	s5,s4
    80005270:	b759                	j	800051f6 <create+0x72>
    iunlockput(dp);
    80005272:	8526                	mv	a0,s1
    80005274:	ffffe097          	auipc	ra,0xffffe
    80005278:	7a2080e7          	jalr	1954(ra) # 80003a16 <iunlockput>
    return 0;
    8000527c:	8ad2                	mv	s5,s4
    8000527e:	bfa5                	j	800051f6 <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005280:	004a2603          	lw	a2,4(s4)
    80005284:	00003597          	auipc	a1,0x3
    80005288:	4a458593          	add	a1,a1,1188 # 80008728 <syscalls+0x2a0>
    8000528c:	8552                	mv	a0,s4
    8000528e:	fffff097          	auipc	ra,0xfffff
    80005292:	c1a080e7          	jalr	-998(ra) # 80003ea8 <dirlink>
    80005296:	04054463          	bltz	a0,800052de <create+0x15a>
    8000529a:	40d0                	lw	a2,4(s1)
    8000529c:	00003597          	auipc	a1,0x3
    800052a0:	49458593          	add	a1,a1,1172 # 80008730 <syscalls+0x2a8>
    800052a4:	8552                	mv	a0,s4
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	c02080e7          	jalr	-1022(ra) # 80003ea8 <dirlink>
    800052ae:	02054863          	bltz	a0,800052de <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    800052b2:	004a2603          	lw	a2,4(s4)
    800052b6:	fb040593          	add	a1,s0,-80
    800052ba:	8526                	mv	a0,s1
    800052bc:	fffff097          	auipc	ra,0xfffff
    800052c0:	bec080e7          	jalr	-1044(ra) # 80003ea8 <dirlink>
    800052c4:	00054d63          	bltz	a0,800052de <create+0x15a>
    dp->nlink++;  // for ".."
    800052c8:	04a4d783          	lhu	a5,74(s1)
    800052cc:	2785                	addw	a5,a5,1
    800052ce:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	414080e7          	jalr	1044(ra) # 800036e8 <iupdate>
    800052dc:	b761                	j	80005264 <create+0xe0>
  ip->nlink = 0;
    800052de:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800052e2:	8552                	mv	a0,s4
    800052e4:	ffffe097          	auipc	ra,0xffffe
    800052e8:	404080e7          	jalr	1028(ra) # 800036e8 <iupdate>
  iunlockput(ip);
    800052ec:	8552                	mv	a0,s4
    800052ee:	ffffe097          	auipc	ra,0xffffe
    800052f2:	728080e7          	jalr	1832(ra) # 80003a16 <iunlockput>
  iunlockput(dp);
    800052f6:	8526                	mv	a0,s1
    800052f8:	ffffe097          	auipc	ra,0xffffe
    800052fc:	71e080e7          	jalr	1822(ra) # 80003a16 <iunlockput>
  return 0;
    80005300:	bddd                	j	800051f6 <create+0x72>
    return 0;
    80005302:	8aaa                	mv	s5,a0
    80005304:	bdcd                	j	800051f6 <create+0x72>

0000000080005306 <sys_dup>:
{
    80005306:	7179                	add	sp,sp,-48
    80005308:	f406                	sd	ra,40(sp)
    8000530a:	f022                	sd	s0,32(sp)
    8000530c:	ec26                	sd	s1,24(sp)
    8000530e:	e84a                	sd	s2,16(sp)
    80005310:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005312:	fd840613          	add	a2,s0,-40
    80005316:	4581                	li	a1,0
    80005318:	4501                	li	a0,0
    8000531a:	00000097          	auipc	ra,0x0
    8000531e:	dc8080e7          	jalr	-568(ra) # 800050e2 <argfd>
    return -1;
    80005322:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005324:	02054363          	bltz	a0,8000534a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005328:	fd843903          	ld	s2,-40(s0)
    8000532c:	854a                	mv	a0,s2
    8000532e:	00000097          	auipc	ra,0x0
    80005332:	e14080e7          	jalr	-492(ra) # 80005142 <fdalloc>
    80005336:	84aa                	mv	s1,a0
    return -1;
    80005338:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000533a:	00054863          	bltz	a0,8000534a <sys_dup+0x44>
  filedup(f);
    8000533e:	854a                	mv	a0,s2
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	28c080e7          	jalr	652(ra) # 800045cc <filedup>
  return fd;
    80005348:	87a6                	mv	a5,s1
}
    8000534a:	853e                	mv	a0,a5
    8000534c:	70a2                	ld	ra,40(sp)
    8000534e:	7402                	ld	s0,32(sp)
    80005350:	64e2                	ld	s1,24(sp)
    80005352:	6942                	ld	s2,16(sp)
    80005354:	6145                	add	sp,sp,48
    80005356:	8082                	ret

0000000080005358 <sys_read>:
{
    80005358:	7179                	add	sp,sp,-48
    8000535a:	f406                	sd	ra,40(sp)
    8000535c:	f022                	sd	s0,32(sp)
    8000535e:	1800                	add	s0,sp,48
  argaddr(1, &p);
    80005360:	fd840593          	add	a1,s0,-40
    80005364:	4505                	li	a0,1
    80005366:	ffffe097          	auipc	ra,0xffffe
    8000536a:	90c080e7          	jalr	-1780(ra) # 80002c72 <argaddr>
  argint(2, &n);
    8000536e:	fe440593          	add	a1,s0,-28
    80005372:	4509                	li	a0,2
    80005374:	ffffe097          	auipc	ra,0xffffe
    80005378:	8de080e7          	jalr	-1826(ra) # 80002c52 <argint>
  if(argfd(0, 0, &f) < 0)
    8000537c:	fe840613          	add	a2,s0,-24
    80005380:	4581                	li	a1,0
    80005382:	4501                	li	a0,0
    80005384:	00000097          	auipc	ra,0x0
    80005388:	d5e080e7          	jalr	-674(ra) # 800050e2 <argfd>
    8000538c:	87aa                	mv	a5,a0
    return -1;
    8000538e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005390:	0007cc63          	bltz	a5,800053a8 <sys_read+0x50>
  return fileread(f, p, n);
    80005394:	fe442603          	lw	a2,-28(s0)
    80005398:	fd843583          	ld	a1,-40(s0)
    8000539c:	fe843503          	ld	a0,-24(s0)
    800053a0:	fffff097          	auipc	ra,0xfffff
    800053a4:	3b8080e7          	jalr	952(ra) # 80004758 <fileread>
}
    800053a8:	70a2                	ld	ra,40(sp)
    800053aa:	7402                	ld	s0,32(sp)
    800053ac:	6145                	add	sp,sp,48
    800053ae:	8082                	ret

00000000800053b0 <sys_write>:
{
    800053b0:	7179                	add	sp,sp,-48
    800053b2:	f406                	sd	ra,40(sp)
    800053b4:	f022                	sd	s0,32(sp)
    800053b6:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800053b8:	fd840593          	add	a1,s0,-40
    800053bc:	4505                	li	a0,1
    800053be:	ffffe097          	auipc	ra,0xffffe
    800053c2:	8b4080e7          	jalr	-1868(ra) # 80002c72 <argaddr>
  argint(2, &n);
    800053c6:	fe440593          	add	a1,s0,-28
    800053ca:	4509                	li	a0,2
    800053cc:	ffffe097          	auipc	ra,0xffffe
    800053d0:	886080e7          	jalr	-1914(ra) # 80002c52 <argint>
  if(argfd(0, 0, &f) < 0)
    800053d4:	fe840613          	add	a2,s0,-24
    800053d8:	4581                	li	a1,0
    800053da:	4501                	li	a0,0
    800053dc:	00000097          	auipc	ra,0x0
    800053e0:	d06080e7          	jalr	-762(ra) # 800050e2 <argfd>
    800053e4:	87aa                	mv	a5,a0
    return -1;
    800053e6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053e8:	0007cc63          	bltz	a5,80005400 <sys_write+0x50>
  return filewrite(f, p, n);
    800053ec:	fe442603          	lw	a2,-28(s0)
    800053f0:	fd843583          	ld	a1,-40(s0)
    800053f4:	fe843503          	ld	a0,-24(s0)
    800053f8:	fffff097          	auipc	ra,0xfffff
    800053fc:	422080e7          	jalr	1058(ra) # 8000481a <filewrite>
}
    80005400:	70a2                	ld	ra,40(sp)
    80005402:	7402                	ld	s0,32(sp)
    80005404:	6145                	add	sp,sp,48
    80005406:	8082                	ret

0000000080005408 <sys_close>:
{
    80005408:	1101                	add	sp,sp,-32
    8000540a:	ec06                	sd	ra,24(sp)
    8000540c:	e822                	sd	s0,16(sp)
    8000540e:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005410:	fe040613          	add	a2,s0,-32
    80005414:	fec40593          	add	a1,s0,-20
    80005418:	4501                	li	a0,0
    8000541a:	00000097          	auipc	ra,0x0
    8000541e:	cc8080e7          	jalr	-824(ra) # 800050e2 <argfd>
    return -1;
    80005422:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005424:	02054463          	bltz	a0,8000544c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005428:	ffffc097          	auipc	ra,0xffffc
    8000542c:	5ba080e7          	jalr	1466(ra) # 800019e2 <myproc>
    80005430:	fec42783          	lw	a5,-20(s0)
    80005434:	07e9                	add	a5,a5,26
    80005436:	078e                	sll	a5,a5,0x3
    80005438:	953e                	add	a0,a0,a5
    8000543a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000543e:	fe043503          	ld	a0,-32(s0)
    80005442:	fffff097          	auipc	ra,0xfffff
    80005446:	1dc080e7          	jalr	476(ra) # 8000461e <fileclose>
  return 0;
    8000544a:	4781                	li	a5,0
}
    8000544c:	853e                	mv	a0,a5
    8000544e:	60e2                	ld	ra,24(sp)
    80005450:	6442                	ld	s0,16(sp)
    80005452:	6105                	add	sp,sp,32
    80005454:	8082                	ret

0000000080005456 <sys_fstat>:
{
    80005456:	1101                	add	sp,sp,-32
    80005458:	ec06                	sd	ra,24(sp)
    8000545a:	e822                	sd	s0,16(sp)
    8000545c:	1000                	add	s0,sp,32
  argaddr(1, &st);
    8000545e:	fe040593          	add	a1,s0,-32
    80005462:	4505                	li	a0,1
    80005464:	ffffe097          	auipc	ra,0xffffe
    80005468:	80e080e7          	jalr	-2034(ra) # 80002c72 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000546c:	fe840613          	add	a2,s0,-24
    80005470:	4581                	li	a1,0
    80005472:	4501                	li	a0,0
    80005474:	00000097          	auipc	ra,0x0
    80005478:	c6e080e7          	jalr	-914(ra) # 800050e2 <argfd>
    8000547c:	87aa                	mv	a5,a0
    return -1;
    8000547e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005480:	0007ca63          	bltz	a5,80005494 <sys_fstat+0x3e>
  return filestat(f, st);
    80005484:	fe043583          	ld	a1,-32(s0)
    80005488:	fe843503          	ld	a0,-24(s0)
    8000548c:	fffff097          	auipc	ra,0xfffff
    80005490:	25a080e7          	jalr	602(ra) # 800046e6 <filestat>
}
    80005494:	60e2                	ld	ra,24(sp)
    80005496:	6442                	ld	s0,16(sp)
    80005498:	6105                	add	sp,sp,32
    8000549a:	8082                	ret

000000008000549c <sys_link>:
{
    8000549c:	7169                	add	sp,sp,-304
    8000549e:	f606                	sd	ra,296(sp)
    800054a0:	f222                	sd	s0,288(sp)
    800054a2:	ee26                	sd	s1,280(sp)
    800054a4:	ea4a                	sd	s2,272(sp)
    800054a6:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054a8:	08000613          	li	a2,128
    800054ac:	ed040593          	add	a1,s0,-304
    800054b0:	4501                	li	a0,0
    800054b2:	ffffd097          	auipc	ra,0xffffd
    800054b6:	7e0080e7          	jalr	2016(ra) # 80002c92 <argstr>
    return -1;
    800054ba:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054bc:	10054e63          	bltz	a0,800055d8 <sys_link+0x13c>
    800054c0:	08000613          	li	a2,128
    800054c4:	f5040593          	add	a1,s0,-176
    800054c8:	4505                	li	a0,1
    800054ca:	ffffd097          	auipc	ra,0xffffd
    800054ce:	7c8080e7          	jalr	1992(ra) # 80002c92 <argstr>
    return -1;
    800054d2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800054d4:	10054263          	bltz	a0,800055d8 <sys_link+0x13c>
  begin_op();
    800054d8:	fffff097          	auipc	ra,0xfffff
    800054dc:	c82080e7          	jalr	-894(ra) # 8000415a <begin_op>
  if((ip = namei(old)) == 0){
    800054e0:	ed040513          	add	a0,s0,-304
    800054e4:	fffff097          	auipc	ra,0xfffff
    800054e8:	a76080e7          	jalr	-1418(ra) # 80003f5a <namei>
    800054ec:	84aa                	mv	s1,a0
    800054ee:	c551                	beqz	a0,8000557a <sys_link+0xde>
  ilock(ip);
    800054f0:	ffffe097          	auipc	ra,0xffffe
    800054f4:	2c4080e7          	jalr	708(ra) # 800037b4 <ilock>
  if(ip->type == T_DIR){
    800054f8:	04449703          	lh	a4,68(s1)
    800054fc:	4785                	li	a5,1
    800054fe:	08f70463          	beq	a4,a5,80005586 <sys_link+0xea>
  ip->nlink++;
    80005502:	04a4d783          	lhu	a5,74(s1)
    80005506:	2785                	addw	a5,a5,1
    80005508:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000550c:	8526                	mv	a0,s1
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	1da080e7          	jalr	474(ra) # 800036e8 <iupdate>
  iunlock(ip);
    80005516:	8526                	mv	a0,s1
    80005518:	ffffe097          	auipc	ra,0xffffe
    8000551c:	35e080e7          	jalr	862(ra) # 80003876 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005520:	fd040593          	add	a1,s0,-48
    80005524:	f5040513          	add	a0,s0,-176
    80005528:	fffff097          	auipc	ra,0xfffff
    8000552c:	a50080e7          	jalr	-1456(ra) # 80003f78 <nameiparent>
    80005530:	892a                	mv	s2,a0
    80005532:	c935                	beqz	a0,800055a6 <sys_link+0x10a>
  ilock(dp);
    80005534:	ffffe097          	auipc	ra,0xffffe
    80005538:	280080e7          	jalr	640(ra) # 800037b4 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000553c:	00092703          	lw	a4,0(s2)
    80005540:	409c                	lw	a5,0(s1)
    80005542:	04f71d63          	bne	a4,a5,8000559c <sys_link+0x100>
    80005546:	40d0                	lw	a2,4(s1)
    80005548:	fd040593          	add	a1,s0,-48
    8000554c:	854a                	mv	a0,s2
    8000554e:	fffff097          	auipc	ra,0xfffff
    80005552:	95a080e7          	jalr	-1702(ra) # 80003ea8 <dirlink>
    80005556:	04054363          	bltz	a0,8000559c <sys_link+0x100>
  iunlockput(dp);
    8000555a:	854a                	mv	a0,s2
    8000555c:	ffffe097          	auipc	ra,0xffffe
    80005560:	4ba080e7          	jalr	1210(ra) # 80003a16 <iunlockput>
  iput(ip);
    80005564:	8526                	mv	a0,s1
    80005566:	ffffe097          	auipc	ra,0xffffe
    8000556a:	408080e7          	jalr	1032(ra) # 8000396e <iput>
  end_op();
    8000556e:	fffff097          	auipc	ra,0xfffff
    80005572:	c66080e7          	jalr	-922(ra) # 800041d4 <end_op>
  return 0;
    80005576:	4781                	li	a5,0
    80005578:	a085                	j	800055d8 <sys_link+0x13c>
    end_op();
    8000557a:	fffff097          	auipc	ra,0xfffff
    8000557e:	c5a080e7          	jalr	-934(ra) # 800041d4 <end_op>
    return -1;
    80005582:	57fd                	li	a5,-1
    80005584:	a891                	j	800055d8 <sys_link+0x13c>
    iunlockput(ip);
    80005586:	8526                	mv	a0,s1
    80005588:	ffffe097          	auipc	ra,0xffffe
    8000558c:	48e080e7          	jalr	1166(ra) # 80003a16 <iunlockput>
    end_op();
    80005590:	fffff097          	auipc	ra,0xfffff
    80005594:	c44080e7          	jalr	-956(ra) # 800041d4 <end_op>
    return -1;
    80005598:	57fd                	li	a5,-1
    8000559a:	a83d                	j	800055d8 <sys_link+0x13c>
    iunlockput(dp);
    8000559c:	854a                	mv	a0,s2
    8000559e:	ffffe097          	auipc	ra,0xffffe
    800055a2:	478080e7          	jalr	1144(ra) # 80003a16 <iunlockput>
  ilock(ip);
    800055a6:	8526                	mv	a0,s1
    800055a8:	ffffe097          	auipc	ra,0xffffe
    800055ac:	20c080e7          	jalr	524(ra) # 800037b4 <ilock>
  ip->nlink--;
    800055b0:	04a4d783          	lhu	a5,74(s1)
    800055b4:	37fd                	addw	a5,a5,-1
    800055b6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800055ba:	8526                	mv	a0,s1
    800055bc:	ffffe097          	auipc	ra,0xffffe
    800055c0:	12c080e7          	jalr	300(ra) # 800036e8 <iupdate>
  iunlockput(ip);
    800055c4:	8526                	mv	a0,s1
    800055c6:	ffffe097          	auipc	ra,0xffffe
    800055ca:	450080e7          	jalr	1104(ra) # 80003a16 <iunlockput>
  end_op();
    800055ce:	fffff097          	auipc	ra,0xfffff
    800055d2:	c06080e7          	jalr	-1018(ra) # 800041d4 <end_op>
  return -1;
    800055d6:	57fd                	li	a5,-1
}
    800055d8:	853e                	mv	a0,a5
    800055da:	70b2                	ld	ra,296(sp)
    800055dc:	7412                	ld	s0,288(sp)
    800055de:	64f2                	ld	s1,280(sp)
    800055e0:	6952                	ld	s2,272(sp)
    800055e2:	6155                	add	sp,sp,304
    800055e4:	8082                	ret

00000000800055e6 <sys_unlink>:
{
    800055e6:	7151                	add	sp,sp,-240
    800055e8:	f586                	sd	ra,232(sp)
    800055ea:	f1a2                	sd	s0,224(sp)
    800055ec:	eda6                	sd	s1,216(sp)
    800055ee:	e9ca                	sd	s2,208(sp)
    800055f0:	e5ce                	sd	s3,200(sp)
    800055f2:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800055f4:	08000613          	li	a2,128
    800055f8:	f3040593          	add	a1,s0,-208
    800055fc:	4501                	li	a0,0
    800055fe:	ffffd097          	auipc	ra,0xffffd
    80005602:	694080e7          	jalr	1684(ra) # 80002c92 <argstr>
    80005606:	18054163          	bltz	a0,80005788 <sys_unlink+0x1a2>
  begin_op();
    8000560a:	fffff097          	auipc	ra,0xfffff
    8000560e:	b50080e7          	jalr	-1200(ra) # 8000415a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005612:	fb040593          	add	a1,s0,-80
    80005616:	f3040513          	add	a0,s0,-208
    8000561a:	fffff097          	auipc	ra,0xfffff
    8000561e:	95e080e7          	jalr	-1698(ra) # 80003f78 <nameiparent>
    80005622:	84aa                	mv	s1,a0
    80005624:	c979                	beqz	a0,800056fa <sys_unlink+0x114>
  ilock(dp);
    80005626:	ffffe097          	auipc	ra,0xffffe
    8000562a:	18e080e7          	jalr	398(ra) # 800037b4 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000562e:	00003597          	auipc	a1,0x3
    80005632:	0fa58593          	add	a1,a1,250 # 80008728 <syscalls+0x2a0>
    80005636:	fb040513          	add	a0,s0,-80
    8000563a:	ffffe097          	auipc	ra,0xffffe
    8000563e:	644080e7          	jalr	1604(ra) # 80003c7e <namecmp>
    80005642:	14050a63          	beqz	a0,80005796 <sys_unlink+0x1b0>
    80005646:	00003597          	auipc	a1,0x3
    8000564a:	0ea58593          	add	a1,a1,234 # 80008730 <syscalls+0x2a8>
    8000564e:	fb040513          	add	a0,s0,-80
    80005652:	ffffe097          	auipc	ra,0xffffe
    80005656:	62c080e7          	jalr	1580(ra) # 80003c7e <namecmp>
    8000565a:	12050e63          	beqz	a0,80005796 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000565e:	f2c40613          	add	a2,s0,-212
    80005662:	fb040593          	add	a1,s0,-80
    80005666:	8526                	mv	a0,s1
    80005668:	ffffe097          	auipc	ra,0xffffe
    8000566c:	630080e7          	jalr	1584(ra) # 80003c98 <dirlookup>
    80005670:	892a                	mv	s2,a0
    80005672:	12050263          	beqz	a0,80005796 <sys_unlink+0x1b0>
  ilock(ip);
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	13e080e7          	jalr	318(ra) # 800037b4 <ilock>
  if(ip->nlink < 1)
    8000567e:	04a91783          	lh	a5,74(s2)
    80005682:	08f05263          	blez	a5,80005706 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005686:	04491703          	lh	a4,68(s2)
    8000568a:	4785                	li	a5,1
    8000568c:	08f70563          	beq	a4,a5,80005716 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005690:	4641                	li	a2,16
    80005692:	4581                	li	a1,0
    80005694:	fc040513          	add	a0,s0,-64
    80005698:	ffffb097          	auipc	ra,0xffffb
    8000569c:	636080e7          	jalr	1590(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800056a0:	4741                	li	a4,16
    800056a2:	f2c42683          	lw	a3,-212(s0)
    800056a6:	fc040613          	add	a2,s0,-64
    800056aa:	4581                	li	a1,0
    800056ac:	8526                	mv	a0,s1
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	4b2080e7          	jalr	1202(ra) # 80003b60 <writei>
    800056b6:	47c1                	li	a5,16
    800056b8:	0af51563          	bne	a0,a5,80005762 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800056bc:	04491703          	lh	a4,68(s2)
    800056c0:	4785                	li	a5,1
    800056c2:	0af70863          	beq	a4,a5,80005772 <sys_unlink+0x18c>
  iunlockput(dp);
    800056c6:	8526                	mv	a0,s1
    800056c8:	ffffe097          	auipc	ra,0xffffe
    800056cc:	34e080e7          	jalr	846(ra) # 80003a16 <iunlockput>
  ip->nlink--;
    800056d0:	04a95783          	lhu	a5,74(s2)
    800056d4:	37fd                	addw	a5,a5,-1
    800056d6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800056da:	854a                	mv	a0,s2
    800056dc:	ffffe097          	auipc	ra,0xffffe
    800056e0:	00c080e7          	jalr	12(ra) # 800036e8 <iupdate>
  iunlockput(ip);
    800056e4:	854a                	mv	a0,s2
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	330080e7          	jalr	816(ra) # 80003a16 <iunlockput>
  end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	ae6080e7          	jalr	-1306(ra) # 800041d4 <end_op>
  return 0;
    800056f6:	4501                	li	a0,0
    800056f8:	a84d                	j	800057aa <sys_unlink+0x1c4>
    end_op();
    800056fa:	fffff097          	auipc	ra,0xfffff
    800056fe:	ada080e7          	jalr	-1318(ra) # 800041d4 <end_op>
    return -1;
    80005702:	557d                	li	a0,-1
    80005704:	a05d                	j	800057aa <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005706:	00003517          	auipc	a0,0x3
    8000570a:	03250513          	add	a0,a0,50 # 80008738 <syscalls+0x2b0>
    8000570e:	ffffb097          	auipc	ra,0xffffb
    80005712:	e2e080e7          	jalr	-466(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005716:	04c92703          	lw	a4,76(s2)
    8000571a:	02000793          	li	a5,32
    8000571e:	f6e7f9e3          	bgeu	a5,a4,80005690 <sys_unlink+0xaa>
    80005722:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005726:	4741                	li	a4,16
    80005728:	86ce                	mv	a3,s3
    8000572a:	f1840613          	add	a2,s0,-232
    8000572e:	4581                	li	a1,0
    80005730:	854a                	mv	a0,s2
    80005732:	ffffe097          	auipc	ra,0xffffe
    80005736:	336080e7          	jalr	822(ra) # 80003a68 <readi>
    8000573a:	47c1                	li	a5,16
    8000573c:	00f51b63          	bne	a0,a5,80005752 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005740:	f1845783          	lhu	a5,-232(s0)
    80005744:	e7a1                	bnez	a5,8000578c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005746:	29c1                	addw	s3,s3,16
    80005748:	04c92783          	lw	a5,76(s2)
    8000574c:	fcf9ede3          	bltu	s3,a5,80005726 <sys_unlink+0x140>
    80005750:	b781                	j	80005690 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005752:	00003517          	auipc	a0,0x3
    80005756:	ffe50513          	add	a0,a0,-2 # 80008750 <syscalls+0x2c8>
    8000575a:	ffffb097          	auipc	ra,0xffffb
    8000575e:	de2080e7          	jalr	-542(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005762:	00003517          	auipc	a0,0x3
    80005766:	00650513          	add	a0,a0,6 # 80008768 <syscalls+0x2e0>
    8000576a:	ffffb097          	auipc	ra,0xffffb
    8000576e:	dd2080e7          	jalr	-558(ra) # 8000053c <panic>
    dp->nlink--;
    80005772:	04a4d783          	lhu	a5,74(s1)
    80005776:	37fd                	addw	a5,a5,-1
    80005778:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000577c:	8526                	mv	a0,s1
    8000577e:	ffffe097          	auipc	ra,0xffffe
    80005782:	f6a080e7          	jalr	-150(ra) # 800036e8 <iupdate>
    80005786:	b781                	j	800056c6 <sys_unlink+0xe0>
    return -1;
    80005788:	557d                	li	a0,-1
    8000578a:	a005                	j	800057aa <sys_unlink+0x1c4>
    iunlockput(ip);
    8000578c:	854a                	mv	a0,s2
    8000578e:	ffffe097          	auipc	ra,0xffffe
    80005792:	288080e7          	jalr	648(ra) # 80003a16 <iunlockput>
  iunlockput(dp);
    80005796:	8526                	mv	a0,s1
    80005798:	ffffe097          	auipc	ra,0xffffe
    8000579c:	27e080e7          	jalr	638(ra) # 80003a16 <iunlockput>
  end_op();
    800057a0:	fffff097          	auipc	ra,0xfffff
    800057a4:	a34080e7          	jalr	-1484(ra) # 800041d4 <end_op>
  return -1;
    800057a8:	557d                	li	a0,-1
}
    800057aa:	70ae                	ld	ra,232(sp)
    800057ac:	740e                	ld	s0,224(sp)
    800057ae:	64ee                	ld	s1,216(sp)
    800057b0:	694e                	ld	s2,208(sp)
    800057b2:	69ae                	ld	s3,200(sp)
    800057b4:	616d                	add	sp,sp,240
    800057b6:	8082                	ret

00000000800057b8 <sys_open>:

uint64
sys_open(void)
{
    800057b8:	7131                	add	sp,sp,-192
    800057ba:	fd06                	sd	ra,184(sp)
    800057bc:	f922                	sd	s0,176(sp)
    800057be:	f526                	sd	s1,168(sp)
    800057c0:	f14a                	sd	s2,160(sp)
    800057c2:	ed4e                	sd	s3,152(sp)
    800057c4:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800057c6:	f4c40593          	add	a1,s0,-180
    800057ca:	4505                	li	a0,1
    800057cc:	ffffd097          	auipc	ra,0xffffd
    800057d0:	486080e7          	jalr	1158(ra) # 80002c52 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057d4:	08000613          	li	a2,128
    800057d8:	f5040593          	add	a1,s0,-176
    800057dc:	4501                	li	a0,0
    800057de:	ffffd097          	auipc	ra,0xffffd
    800057e2:	4b4080e7          	jalr	1204(ra) # 80002c92 <argstr>
    800057e6:	87aa                	mv	a5,a0
    return -1;
    800057e8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800057ea:	0a07c863          	bltz	a5,8000589a <sys_open+0xe2>

  begin_op();
    800057ee:	fffff097          	auipc	ra,0xfffff
    800057f2:	96c080e7          	jalr	-1684(ra) # 8000415a <begin_op>

  if(omode & O_CREATE){
    800057f6:	f4c42783          	lw	a5,-180(s0)
    800057fa:	2007f793          	and	a5,a5,512
    800057fe:	cbdd                	beqz	a5,800058b4 <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005800:	4681                	li	a3,0
    80005802:	4601                	li	a2,0
    80005804:	4589                	li	a1,2
    80005806:	f5040513          	add	a0,s0,-176
    8000580a:	00000097          	auipc	ra,0x0
    8000580e:	97a080e7          	jalr	-1670(ra) # 80005184 <create>
    80005812:	84aa                	mv	s1,a0
    if(ip == 0){
    80005814:	c951                	beqz	a0,800058a8 <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005816:	04449703          	lh	a4,68(s1)
    8000581a:	478d                	li	a5,3
    8000581c:	00f71763          	bne	a4,a5,8000582a <sys_open+0x72>
    80005820:	0464d703          	lhu	a4,70(s1)
    80005824:	47a5                	li	a5,9
    80005826:	0ce7ec63          	bltu	a5,a4,800058fe <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000582a:	fffff097          	auipc	ra,0xfffff
    8000582e:	d38080e7          	jalr	-712(ra) # 80004562 <filealloc>
    80005832:	892a                	mv	s2,a0
    80005834:	c56d                	beqz	a0,8000591e <sys_open+0x166>
    80005836:	00000097          	auipc	ra,0x0
    8000583a:	90c080e7          	jalr	-1780(ra) # 80005142 <fdalloc>
    8000583e:	89aa                	mv	s3,a0
    80005840:	0c054a63          	bltz	a0,80005914 <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005844:	04449703          	lh	a4,68(s1)
    80005848:	478d                	li	a5,3
    8000584a:	0ef70563          	beq	a4,a5,80005934 <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    8000584e:	4789                	li	a5,2
    80005850:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80005854:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80005858:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    8000585c:	f4c42783          	lw	a5,-180(s0)
    80005860:	0017c713          	xor	a4,a5,1
    80005864:	8b05                	and	a4,a4,1
    80005866:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000586a:	0037f713          	and	a4,a5,3
    8000586e:	00e03733          	snez	a4,a4
    80005872:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005876:	4007f793          	and	a5,a5,1024
    8000587a:	c791                	beqz	a5,80005886 <sys_open+0xce>
    8000587c:	04449703          	lh	a4,68(s1)
    80005880:	4789                	li	a5,2
    80005882:	0cf70063          	beq	a4,a5,80005942 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	fee080e7          	jalr	-18(ra) # 80003876 <iunlock>
  end_op();
    80005890:	fffff097          	auipc	ra,0xfffff
    80005894:	944080e7          	jalr	-1724(ra) # 800041d4 <end_op>

  return fd;
    80005898:	854e                	mv	a0,s3
}
    8000589a:	70ea                	ld	ra,184(sp)
    8000589c:	744a                	ld	s0,176(sp)
    8000589e:	74aa                	ld	s1,168(sp)
    800058a0:	790a                	ld	s2,160(sp)
    800058a2:	69ea                	ld	s3,152(sp)
    800058a4:	6129                	add	sp,sp,192
    800058a6:	8082                	ret
      end_op();
    800058a8:	fffff097          	auipc	ra,0xfffff
    800058ac:	92c080e7          	jalr	-1748(ra) # 800041d4 <end_op>
      return -1;
    800058b0:	557d                	li	a0,-1
    800058b2:	b7e5                	j	8000589a <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    800058b4:	f5040513          	add	a0,s0,-176
    800058b8:	ffffe097          	auipc	ra,0xffffe
    800058bc:	6a2080e7          	jalr	1698(ra) # 80003f5a <namei>
    800058c0:	84aa                	mv	s1,a0
    800058c2:	c905                	beqz	a0,800058f2 <sys_open+0x13a>
    ilock(ip);
    800058c4:	ffffe097          	auipc	ra,0xffffe
    800058c8:	ef0080e7          	jalr	-272(ra) # 800037b4 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800058cc:	04449703          	lh	a4,68(s1)
    800058d0:	4785                	li	a5,1
    800058d2:	f4f712e3          	bne	a4,a5,80005816 <sys_open+0x5e>
    800058d6:	f4c42783          	lw	a5,-180(s0)
    800058da:	dba1                	beqz	a5,8000582a <sys_open+0x72>
      iunlockput(ip);
    800058dc:	8526                	mv	a0,s1
    800058de:	ffffe097          	auipc	ra,0xffffe
    800058e2:	138080e7          	jalr	312(ra) # 80003a16 <iunlockput>
      end_op();
    800058e6:	fffff097          	auipc	ra,0xfffff
    800058ea:	8ee080e7          	jalr	-1810(ra) # 800041d4 <end_op>
      return -1;
    800058ee:	557d                	li	a0,-1
    800058f0:	b76d                	j	8000589a <sys_open+0xe2>
      end_op();
    800058f2:	fffff097          	auipc	ra,0xfffff
    800058f6:	8e2080e7          	jalr	-1822(ra) # 800041d4 <end_op>
      return -1;
    800058fa:	557d                	li	a0,-1
    800058fc:	bf79                	j	8000589a <sys_open+0xe2>
    iunlockput(ip);
    800058fe:	8526                	mv	a0,s1
    80005900:	ffffe097          	auipc	ra,0xffffe
    80005904:	116080e7          	jalr	278(ra) # 80003a16 <iunlockput>
    end_op();
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	8cc080e7          	jalr	-1844(ra) # 800041d4 <end_op>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	b761                	j	8000589a <sys_open+0xe2>
      fileclose(f);
    80005914:	854a                	mv	a0,s2
    80005916:	fffff097          	auipc	ra,0xfffff
    8000591a:	d08080e7          	jalr	-760(ra) # 8000461e <fileclose>
    iunlockput(ip);
    8000591e:	8526                	mv	a0,s1
    80005920:	ffffe097          	auipc	ra,0xffffe
    80005924:	0f6080e7          	jalr	246(ra) # 80003a16 <iunlockput>
    end_op();
    80005928:	fffff097          	auipc	ra,0xfffff
    8000592c:	8ac080e7          	jalr	-1876(ra) # 800041d4 <end_op>
    return -1;
    80005930:	557d                	li	a0,-1
    80005932:	b7a5                	j	8000589a <sys_open+0xe2>
    f->type = FD_DEVICE;
    80005934:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80005938:	04649783          	lh	a5,70(s1)
    8000593c:	02f91223          	sh	a5,36(s2)
    80005940:	bf21                	j	80005858 <sys_open+0xa0>
    itrunc(ip);
    80005942:	8526                	mv	a0,s1
    80005944:	ffffe097          	auipc	ra,0xffffe
    80005948:	f7e080e7          	jalr	-130(ra) # 800038c2 <itrunc>
    8000594c:	bf2d                	j	80005886 <sys_open+0xce>

000000008000594e <sys_mkdir>:

uint64
sys_mkdir(void)
{
    8000594e:	7175                	add	sp,sp,-144
    80005950:	e506                	sd	ra,136(sp)
    80005952:	e122                	sd	s0,128(sp)
    80005954:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005956:	fffff097          	auipc	ra,0xfffff
    8000595a:	804080e7          	jalr	-2044(ra) # 8000415a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    8000595e:	08000613          	li	a2,128
    80005962:	f7040593          	add	a1,s0,-144
    80005966:	4501                	li	a0,0
    80005968:	ffffd097          	auipc	ra,0xffffd
    8000596c:	32a080e7          	jalr	810(ra) # 80002c92 <argstr>
    80005970:	02054963          	bltz	a0,800059a2 <sys_mkdir+0x54>
    80005974:	4681                	li	a3,0
    80005976:	4601                	li	a2,0
    80005978:	4585                	li	a1,1
    8000597a:	f7040513          	add	a0,s0,-144
    8000597e:	00000097          	auipc	ra,0x0
    80005982:	806080e7          	jalr	-2042(ra) # 80005184 <create>
    80005986:	cd11                	beqz	a0,800059a2 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	08e080e7          	jalr	142(ra) # 80003a16 <iunlockput>
  end_op();
    80005990:	fffff097          	auipc	ra,0xfffff
    80005994:	844080e7          	jalr	-1980(ra) # 800041d4 <end_op>
  return 0;
    80005998:	4501                	li	a0,0
}
    8000599a:	60aa                	ld	ra,136(sp)
    8000599c:	640a                	ld	s0,128(sp)
    8000599e:	6149                	add	sp,sp,144
    800059a0:	8082                	ret
    end_op();
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	832080e7          	jalr	-1998(ra) # 800041d4 <end_op>
    return -1;
    800059aa:	557d                	li	a0,-1
    800059ac:	b7fd                	j	8000599a <sys_mkdir+0x4c>

00000000800059ae <sys_mknod>:

uint64
sys_mknod(void)
{
    800059ae:	7135                	add	sp,sp,-160
    800059b0:	ed06                	sd	ra,152(sp)
    800059b2:	e922                	sd	s0,144(sp)
    800059b4:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    800059b6:	ffffe097          	auipc	ra,0xffffe
    800059ba:	7a4080e7          	jalr	1956(ra) # 8000415a <begin_op>
  argint(1, &major);
    800059be:	f6c40593          	add	a1,s0,-148
    800059c2:	4505                	li	a0,1
    800059c4:	ffffd097          	auipc	ra,0xffffd
    800059c8:	28e080e7          	jalr	654(ra) # 80002c52 <argint>
  argint(2, &minor);
    800059cc:	f6840593          	add	a1,s0,-152
    800059d0:	4509                	li	a0,2
    800059d2:	ffffd097          	auipc	ra,0xffffd
    800059d6:	280080e7          	jalr	640(ra) # 80002c52 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800059da:	08000613          	li	a2,128
    800059de:	f7040593          	add	a1,s0,-144
    800059e2:	4501                	li	a0,0
    800059e4:	ffffd097          	auipc	ra,0xffffd
    800059e8:	2ae080e7          	jalr	686(ra) # 80002c92 <argstr>
    800059ec:	02054b63          	bltz	a0,80005a22 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800059f0:	f6841683          	lh	a3,-152(s0)
    800059f4:	f6c41603          	lh	a2,-148(s0)
    800059f8:	458d                	li	a1,3
    800059fa:	f7040513          	add	a0,s0,-144
    800059fe:	fffff097          	auipc	ra,0xfffff
    80005a02:	786080e7          	jalr	1926(ra) # 80005184 <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005a06:	cd11                	beqz	a0,80005a22 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a08:	ffffe097          	auipc	ra,0xffffe
    80005a0c:	00e080e7          	jalr	14(ra) # 80003a16 <iunlockput>
  end_op();
    80005a10:	ffffe097          	auipc	ra,0xffffe
    80005a14:	7c4080e7          	jalr	1988(ra) # 800041d4 <end_op>
  return 0;
    80005a18:	4501                	li	a0,0
}
    80005a1a:	60ea                	ld	ra,152(sp)
    80005a1c:	644a                	ld	s0,144(sp)
    80005a1e:	610d                	add	sp,sp,160
    80005a20:	8082                	ret
    end_op();
    80005a22:	ffffe097          	auipc	ra,0xffffe
    80005a26:	7b2080e7          	jalr	1970(ra) # 800041d4 <end_op>
    return -1;
    80005a2a:	557d                	li	a0,-1
    80005a2c:	b7fd                	j	80005a1a <sys_mknod+0x6c>

0000000080005a2e <sys_chdir>:

uint64
sys_chdir(void)
{
    80005a2e:	7135                	add	sp,sp,-160
    80005a30:	ed06                	sd	ra,152(sp)
    80005a32:	e922                	sd	s0,144(sp)
    80005a34:	e526                	sd	s1,136(sp)
    80005a36:	e14a                	sd	s2,128(sp)
    80005a38:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005a3a:	ffffc097          	auipc	ra,0xffffc
    80005a3e:	fa8080e7          	jalr	-88(ra) # 800019e2 <myproc>
    80005a42:	892a                	mv	s2,a0
  
  begin_op();
    80005a44:	ffffe097          	auipc	ra,0xffffe
    80005a48:	716080e7          	jalr	1814(ra) # 8000415a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005a4c:	08000613          	li	a2,128
    80005a50:	f6040593          	add	a1,s0,-160
    80005a54:	4501                	li	a0,0
    80005a56:	ffffd097          	auipc	ra,0xffffd
    80005a5a:	23c080e7          	jalr	572(ra) # 80002c92 <argstr>
    80005a5e:	04054b63          	bltz	a0,80005ab4 <sys_chdir+0x86>
    80005a62:	f6040513          	add	a0,s0,-160
    80005a66:	ffffe097          	auipc	ra,0xffffe
    80005a6a:	4f4080e7          	jalr	1268(ra) # 80003f5a <namei>
    80005a6e:	84aa                	mv	s1,a0
    80005a70:	c131                	beqz	a0,80005ab4 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005a72:	ffffe097          	auipc	ra,0xffffe
    80005a76:	d42080e7          	jalr	-702(ra) # 800037b4 <ilock>
  if(ip->type != T_DIR){
    80005a7a:	04449703          	lh	a4,68(s1)
    80005a7e:	4785                	li	a5,1
    80005a80:	04f71063          	bne	a4,a5,80005ac0 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005a84:	8526                	mv	a0,s1
    80005a86:	ffffe097          	auipc	ra,0xffffe
    80005a8a:	df0080e7          	jalr	-528(ra) # 80003876 <iunlock>
  iput(p->cwd);
    80005a8e:	15093503          	ld	a0,336(s2)
    80005a92:	ffffe097          	auipc	ra,0xffffe
    80005a96:	edc080e7          	jalr	-292(ra) # 8000396e <iput>
  end_op();
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	73a080e7          	jalr	1850(ra) # 800041d4 <end_op>
  p->cwd = ip;
    80005aa2:	14993823          	sd	s1,336(s2)
  return 0;
    80005aa6:	4501                	li	a0,0
}
    80005aa8:	60ea                	ld	ra,152(sp)
    80005aaa:	644a                	ld	s0,144(sp)
    80005aac:	64aa                	ld	s1,136(sp)
    80005aae:	690a                	ld	s2,128(sp)
    80005ab0:	610d                	add	sp,sp,160
    80005ab2:	8082                	ret
    end_op();
    80005ab4:	ffffe097          	auipc	ra,0xffffe
    80005ab8:	720080e7          	jalr	1824(ra) # 800041d4 <end_op>
    return -1;
    80005abc:	557d                	li	a0,-1
    80005abe:	b7ed                	j	80005aa8 <sys_chdir+0x7a>
    iunlockput(ip);
    80005ac0:	8526                	mv	a0,s1
    80005ac2:	ffffe097          	auipc	ra,0xffffe
    80005ac6:	f54080e7          	jalr	-172(ra) # 80003a16 <iunlockput>
    end_op();
    80005aca:	ffffe097          	auipc	ra,0xffffe
    80005ace:	70a080e7          	jalr	1802(ra) # 800041d4 <end_op>
    return -1;
    80005ad2:	557d                	li	a0,-1
    80005ad4:	bfd1                	j	80005aa8 <sys_chdir+0x7a>

0000000080005ad6 <sys_exec>:

uint64
sys_exec(void)
{
    80005ad6:	7121                	add	sp,sp,-448
    80005ad8:	ff06                	sd	ra,440(sp)
    80005ada:	fb22                	sd	s0,432(sp)
    80005adc:	f726                	sd	s1,424(sp)
    80005ade:	f34a                	sd	s2,416(sp)
    80005ae0:	ef4e                	sd	s3,408(sp)
    80005ae2:	eb52                	sd	s4,400(sp)
    80005ae4:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005ae6:	e4840593          	add	a1,s0,-440
    80005aea:	4505                	li	a0,1
    80005aec:	ffffd097          	auipc	ra,0xffffd
    80005af0:	186080e7          	jalr	390(ra) # 80002c72 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005af4:	08000613          	li	a2,128
    80005af8:	f5040593          	add	a1,s0,-176
    80005afc:	4501                	li	a0,0
    80005afe:	ffffd097          	auipc	ra,0xffffd
    80005b02:	194080e7          	jalr	404(ra) # 80002c92 <argstr>
    80005b06:	87aa                	mv	a5,a0
    return -1;
    80005b08:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005b0a:	0c07c263          	bltz	a5,80005bce <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005b0e:	10000613          	li	a2,256
    80005b12:	4581                	li	a1,0
    80005b14:	e5040513          	add	a0,s0,-432
    80005b18:	ffffb097          	auipc	ra,0xffffb
    80005b1c:	1b6080e7          	jalr	438(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005b20:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005b24:	89a6                	mv	s3,s1
    80005b26:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005b28:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005b2c:	00391513          	sll	a0,s2,0x3
    80005b30:	e4040593          	add	a1,s0,-448
    80005b34:	e4843783          	ld	a5,-440(s0)
    80005b38:	953e                	add	a0,a0,a5
    80005b3a:	ffffd097          	auipc	ra,0xffffd
    80005b3e:	07a080e7          	jalr	122(ra) # 80002bb4 <fetchaddr>
    80005b42:	02054a63          	bltz	a0,80005b76 <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005b46:	e4043783          	ld	a5,-448(s0)
    80005b4a:	c3b9                	beqz	a5,80005b90 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005b4c:	ffffb097          	auipc	ra,0xffffb
    80005b50:	f96080e7          	jalr	-106(ra) # 80000ae2 <kalloc>
    80005b54:	85aa                	mv	a1,a0
    80005b56:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005b5a:	cd11                	beqz	a0,80005b76 <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005b5c:	6605                	lui	a2,0x1
    80005b5e:	e4043503          	ld	a0,-448(s0)
    80005b62:	ffffd097          	auipc	ra,0xffffd
    80005b66:	0a4080e7          	jalr	164(ra) # 80002c06 <fetchstr>
    80005b6a:	00054663          	bltz	a0,80005b76 <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005b6e:	0905                	add	s2,s2,1
    80005b70:	09a1                	add	s3,s3,8
    80005b72:	fb491de3          	bne	s2,s4,80005b2c <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b76:	f5040913          	add	s2,s0,-176
    80005b7a:	6088                	ld	a0,0(s1)
    80005b7c:	c921                	beqz	a0,80005bcc <sys_exec+0xf6>
    kfree(argv[i]);
    80005b7e:	ffffb097          	auipc	ra,0xffffb
    80005b82:	e66080e7          	jalr	-410(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b86:	04a1                	add	s1,s1,8
    80005b88:	ff2499e3          	bne	s1,s2,80005b7a <sys_exec+0xa4>
  return -1;
    80005b8c:	557d                	li	a0,-1
    80005b8e:	a081                	j	80005bce <sys_exec+0xf8>
      argv[i] = 0;
    80005b90:	0009079b          	sext.w	a5,s2
    80005b94:	078e                	sll	a5,a5,0x3
    80005b96:	fd078793          	add	a5,a5,-48
    80005b9a:	97a2                	add	a5,a5,s0
    80005b9c:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005ba0:	e5040593          	add	a1,s0,-432
    80005ba4:	f5040513          	add	a0,s0,-176
    80005ba8:	fffff097          	auipc	ra,0xfffff
    80005bac:	196080e7          	jalr	406(ra) # 80004d3e <exec>
    80005bb0:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bb2:	f5040993          	add	s3,s0,-176
    80005bb6:	6088                	ld	a0,0(s1)
    80005bb8:	c901                	beqz	a0,80005bc8 <sys_exec+0xf2>
    kfree(argv[i]);
    80005bba:	ffffb097          	auipc	ra,0xffffb
    80005bbe:	e2a080e7          	jalr	-470(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005bc2:	04a1                	add	s1,s1,8
    80005bc4:	ff3499e3          	bne	s1,s3,80005bb6 <sys_exec+0xe0>
  return ret;
    80005bc8:	854a                	mv	a0,s2
    80005bca:	a011                	j	80005bce <sys_exec+0xf8>
  return -1;
    80005bcc:	557d                	li	a0,-1
}
    80005bce:	70fa                	ld	ra,440(sp)
    80005bd0:	745a                	ld	s0,432(sp)
    80005bd2:	74ba                	ld	s1,424(sp)
    80005bd4:	791a                	ld	s2,416(sp)
    80005bd6:	69fa                	ld	s3,408(sp)
    80005bd8:	6a5a                	ld	s4,400(sp)
    80005bda:	6139                	add	sp,sp,448
    80005bdc:	8082                	ret

0000000080005bde <sys_pipe>:

uint64
sys_pipe(void)
{
    80005bde:	7139                	add	sp,sp,-64
    80005be0:	fc06                	sd	ra,56(sp)
    80005be2:	f822                	sd	s0,48(sp)
    80005be4:	f426                	sd	s1,40(sp)
    80005be6:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	dfa080e7          	jalr	-518(ra) # 800019e2 <myproc>
    80005bf0:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005bf2:	fd840593          	add	a1,s0,-40
    80005bf6:	4501                	li	a0,0
    80005bf8:	ffffd097          	auipc	ra,0xffffd
    80005bfc:	07a080e7          	jalr	122(ra) # 80002c72 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005c00:	fc840593          	add	a1,s0,-56
    80005c04:	fd040513          	add	a0,s0,-48
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	d42080e7          	jalr	-702(ra) # 8000494a <pipealloc>
    return -1;
    80005c10:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005c12:	0c054463          	bltz	a0,80005cda <sys_pipe+0xfc>
  fd0 = -1;
    80005c16:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005c1a:	fd043503          	ld	a0,-48(s0)
    80005c1e:	fffff097          	auipc	ra,0xfffff
    80005c22:	524080e7          	jalr	1316(ra) # 80005142 <fdalloc>
    80005c26:	fca42223          	sw	a0,-60(s0)
    80005c2a:	08054b63          	bltz	a0,80005cc0 <sys_pipe+0xe2>
    80005c2e:	fc843503          	ld	a0,-56(s0)
    80005c32:	fffff097          	auipc	ra,0xfffff
    80005c36:	510080e7          	jalr	1296(ra) # 80005142 <fdalloc>
    80005c3a:	fca42023          	sw	a0,-64(s0)
    80005c3e:	06054863          	bltz	a0,80005cae <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c42:	4691                	li	a3,4
    80005c44:	fc440613          	add	a2,s0,-60
    80005c48:	fd843583          	ld	a1,-40(s0)
    80005c4c:	68a8                	ld	a0,80(s1)
    80005c4e:	ffffc097          	auipc	ra,0xffffc
    80005c52:	a44080e7          	jalr	-1468(ra) # 80001692 <copyout>
    80005c56:	02054063          	bltz	a0,80005c76 <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005c5a:	4691                	li	a3,4
    80005c5c:	fc040613          	add	a2,s0,-64
    80005c60:	fd843583          	ld	a1,-40(s0)
    80005c64:	0591                	add	a1,a1,4
    80005c66:	68a8                	ld	a0,80(s1)
    80005c68:	ffffc097          	auipc	ra,0xffffc
    80005c6c:	a2a080e7          	jalr	-1494(ra) # 80001692 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005c70:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005c72:	06055463          	bgez	a0,80005cda <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005c76:	fc442783          	lw	a5,-60(s0)
    80005c7a:	07e9                	add	a5,a5,26
    80005c7c:	078e                	sll	a5,a5,0x3
    80005c7e:	97a6                	add	a5,a5,s1
    80005c80:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005c84:	fc042783          	lw	a5,-64(s0)
    80005c88:	07e9                	add	a5,a5,26
    80005c8a:	078e                	sll	a5,a5,0x3
    80005c8c:	94be                	add	s1,s1,a5
    80005c8e:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005c92:	fd043503          	ld	a0,-48(s0)
    80005c96:	fffff097          	auipc	ra,0xfffff
    80005c9a:	988080e7          	jalr	-1656(ra) # 8000461e <fileclose>
    fileclose(wf);
    80005c9e:	fc843503          	ld	a0,-56(s0)
    80005ca2:	fffff097          	auipc	ra,0xfffff
    80005ca6:	97c080e7          	jalr	-1668(ra) # 8000461e <fileclose>
    return -1;
    80005caa:	57fd                	li	a5,-1
    80005cac:	a03d                	j	80005cda <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005cae:	fc442783          	lw	a5,-60(s0)
    80005cb2:	0007c763          	bltz	a5,80005cc0 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005cb6:	07e9                	add	a5,a5,26
    80005cb8:	078e                	sll	a5,a5,0x3
    80005cba:	97a6                	add	a5,a5,s1
    80005cbc:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005cc0:	fd043503          	ld	a0,-48(s0)
    80005cc4:	fffff097          	auipc	ra,0xfffff
    80005cc8:	95a080e7          	jalr	-1702(ra) # 8000461e <fileclose>
    fileclose(wf);
    80005ccc:	fc843503          	ld	a0,-56(s0)
    80005cd0:	fffff097          	auipc	ra,0xfffff
    80005cd4:	94e080e7          	jalr	-1714(ra) # 8000461e <fileclose>
    return -1;
    80005cd8:	57fd                	li	a5,-1
}
    80005cda:	853e                	mv	a0,a5
    80005cdc:	70e2                	ld	ra,56(sp)
    80005cde:	7442                	ld	s0,48(sp)
    80005ce0:	74a2                	ld	s1,40(sp)
    80005ce2:	6121                	add	sp,sp,64
    80005ce4:	8082                	ret
	...

0000000080005cf0 <kernelvec>:
    80005cf0:	7111                	add	sp,sp,-256
    80005cf2:	e006                	sd	ra,0(sp)
    80005cf4:	e40a                	sd	sp,8(sp)
    80005cf6:	e80e                	sd	gp,16(sp)
    80005cf8:	ec12                	sd	tp,24(sp)
    80005cfa:	f016                	sd	t0,32(sp)
    80005cfc:	f41a                	sd	t1,40(sp)
    80005cfe:	f81e                	sd	t2,48(sp)
    80005d00:	fc22                	sd	s0,56(sp)
    80005d02:	e0a6                	sd	s1,64(sp)
    80005d04:	e4aa                	sd	a0,72(sp)
    80005d06:	e8ae                	sd	a1,80(sp)
    80005d08:	ecb2                	sd	a2,88(sp)
    80005d0a:	f0b6                	sd	a3,96(sp)
    80005d0c:	f4ba                	sd	a4,104(sp)
    80005d0e:	f8be                	sd	a5,112(sp)
    80005d10:	fcc2                	sd	a6,120(sp)
    80005d12:	e146                	sd	a7,128(sp)
    80005d14:	e54a                	sd	s2,136(sp)
    80005d16:	e94e                	sd	s3,144(sp)
    80005d18:	ed52                	sd	s4,152(sp)
    80005d1a:	f156                	sd	s5,160(sp)
    80005d1c:	f55a                	sd	s6,168(sp)
    80005d1e:	f95e                	sd	s7,176(sp)
    80005d20:	fd62                	sd	s8,184(sp)
    80005d22:	e1e6                	sd	s9,192(sp)
    80005d24:	e5ea                	sd	s10,200(sp)
    80005d26:	e9ee                	sd	s11,208(sp)
    80005d28:	edf2                	sd	t3,216(sp)
    80005d2a:	f1f6                	sd	t4,224(sp)
    80005d2c:	f5fa                	sd	t5,232(sp)
    80005d2e:	f9fe                	sd	t6,240(sp)
    80005d30:	d51fc0ef          	jal	80002a80 <kerneltrap>
    80005d34:	6082                	ld	ra,0(sp)
    80005d36:	6122                	ld	sp,8(sp)
    80005d38:	61c2                	ld	gp,16(sp)
    80005d3a:	7282                	ld	t0,32(sp)
    80005d3c:	7322                	ld	t1,40(sp)
    80005d3e:	73c2                	ld	t2,48(sp)
    80005d40:	7462                	ld	s0,56(sp)
    80005d42:	6486                	ld	s1,64(sp)
    80005d44:	6526                	ld	a0,72(sp)
    80005d46:	65c6                	ld	a1,80(sp)
    80005d48:	6666                	ld	a2,88(sp)
    80005d4a:	7686                	ld	a3,96(sp)
    80005d4c:	7726                	ld	a4,104(sp)
    80005d4e:	77c6                	ld	a5,112(sp)
    80005d50:	7866                	ld	a6,120(sp)
    80005d52:	688a                	ld	a7,128(sp)
    80005d54:	692a                	ld	s2,136(sp)
    80005d56:	69ca                	ld	s3,144(sp)
    80005d58:	6a6a                	ld	s4,152(sp)
    80005d5a:	7a8a                	ld	s5,160(sp)
    80005d5c:	7b2a                	ld	s6,168(sp)
    80005d5e:	7bca                	ld	s7,176(sp)
    80005d60:	7c6a                	ld	s8,184(sp)
    80005d62:	6c8e                	ld	s9,192(sp)
    80005d64:	6d2e                	ld	s10,200(sp)
    80005d66:	6dce                	ld	s11,208(sp)
    80005d68:	6e6e                	ld	t3,216(sp)
    80005d6a:	7e8e                	ld	t4,224(sp)
    80005d6c:	7f2e                	ld	t5,232(sp)
    80005d6e:	7fce                	ld	t6,240(sp)
    80005d70:	6111                	add	sp,sp,256
    80005d72:	10200073          	sret
    80005d76:	00000013          	nop
    80005d7a:	00000013          	nop
    80005d7e:	0001                	nop

0000000080005d80 <timervec>:
    80005d80:	34051573          	csrrw	a0,mscratch,a0
    80005d84:	e10c                	sd	a1,0(a0)
    80005d86:	e510                	sd	a2,8(a0)
    80005d88:	e914                	sd	a3,16(a0)
    80005d8a:	6d0c                	ld	a1,24(a0)
    80005d8c:	7110                	ld	a2,32(a0)
    80005d8e:	6194                	ld	a3,0(a1)
    80005d90:	96b2                	add	a3,a3,a2
    80005d92:	e194                	sd	a3,0(a1)
    80005d94:	4589                	li	a1,2
    80005d96:	14459073          	csrw	sip,a1
    80005d9a:	6914                	ld	a3,16(a0)
    80005d9c:	6510                	ld	a2,8(a0)
    80005d9e:	610c                	ld	a1,0(a0)
    80005da0:	34051573          	csrrw	a0,mscratch,a0
    80005da4:	30200073          	mret
	...

0000000080005daa <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005daa:	1141                	add	sp,sp,-16
    80005dac:	e422                	sd	s0,8(sp)
    80005dae:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005db0:	0c0007b7          	lui	a5,0xc000
    80005db4:	4705                	li	a4,1
    80005db6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005db8:	c3d8                	sw	a4,4(a5)
}
    80005dba:	6422                	ld	s0,8(sp)
    80005dbc:	0141                	add	sp,sp,16
    80005dbe:	8082                	ret

0000000080005dc0 <plicinithart>:

void
plicinithart(void)
{
    80005dc0:	1141                	add	sp,sp,-16
    80005dc2:	e406                	sd	ra,8(sp)
    80005dc4:	e022                	sd	s0,0(sp)
    80005dc6:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005dc8:	ffffc097          	auipc	ra,0xffffc
    80005dcc:	bee080e7          	jalr	-1042(ra) # 800019b6 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005dd0:	0085171b          	sllw	a4,a0,0x8
    80005dd4:	0c0027b7          	lui	a5,0xc002
    80005dd8:	97ba                	add	a5,a5,a4
    80005dda:	40200713          	li	a4,1026
    80005dde:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005de2:	00d5151b          	sllw	a0,a0,0xd
    80005de6:	0c2017b7          	lui	a5,0xc201
    80005dea:	97aa                	add	a5,a5,a0
    80005dec:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005df0:	60a2                	ld	ra,8(sp)
    80005df2:	6402                	ld	s0,0(sp)
    80005df4:	0141                	add	sp,sp,16
    80005df6:	8082                	ret

0000000080005df8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005df8:	1141                	add	sp,sp,-16
    80005dfa:	e406                	sd	ra,8(sp)
    80005dfc:	e022                	sd	s0,0(sp)
    80005dfe:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005e00:	ffffc097          	auipc	ra,0xffffc
    80005e04:	bb6080e7          	jalr	-1098(ra) # 800019b6 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005e08:	00d5151b          	sllw	a0,a0,0xd
    80005e0c:	0c2017b7          	lui	a5,0xc201
    80005e10:	97aa                	add	a5,a5,a0
  return irq;
}
    80005e12:	43c8                	lw	a0,4(a5)
    80005e14:	60a2                	ld	ra,8(sp)
    80005e16:	6402                	ld	s0,0(sp)
    80005e18:	0141                	add	sp,sp,16
    80005e1a:	8082                	ret

0000000080005e1c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005e1c:	1101                	add	sp,sp,-32
    80005e1e:	ec06                	sd	ra,24(sp)
    80005e20:	e822                	sd	s0,16(sp)
    80005e22:	e426                	sd	s1,8(sp)
    80005e24:	1000                	add	s0,sp,32
    80005e26:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005e28:	ffffc097          	auipc	ra,0xffffc
    80005e2c:	b8e080e7          	jalr	-1138(ra) # 800019b6 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005e30:	00d5151b          	sllw	a0,a0,0xd
    80005e34:	0c2017b7          	lui	a5,0xc201
    80005e38:	97aa                	add	a5,a5,a0
    80005e3a:	c3c4                	sw	s1,4(a5)
}
    80005e3c:	60e2                	ld	ra,24(sp)
    80005e3e:	6442                	ld	s0,16(sp)
    80005e40:	64a2                	ld	s1,8(sp)
    80005e42:	6105                	add	sp,sp,32
    80005e44:	8082                	ret

0000000080005e46 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005e46:	1141                	add	sp,sp,-16
    80005e48:	e406                	sd	ra,8(sp)
    80005e4a:	e022                	sd	s0,0(sp)
    80005e4c:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005e4e:	479d                	li	a5,7
    80005e50:	04a7cc63          	blt	a5,a0,80005ea8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005e54:	00193797          	auipc	a5,0x193
    80005e58:	39478793          	add	a5,a5,916 # 801991e8 <disk>
    80005e5c:	97aa                	add	a5,a5,a0
    80005e5e:	0187c783          	lbu	a5,24(a5)
    80005e62:	ebb9                	bnez	a5,80005eb8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005e64:	00451693          	sll	a3,a0,0x4
    80005e68:	00193797          	auipc	a5,0x193
    80005e6c:	38078793          	add	a5,a5,896 # 801991e8 <disk>
    80005e70:	6398                	ld	a4,0(a5)
    80005e72:	9736                	add	a4,a4,a3
    80005e74:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005e78:	6398                	ld	a4,0(a5)
    80005e7a:	9736                	add	a4,a4,a3
    80005e7c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005e80:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005e84:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005e88:	97aa                	add	a5,a5,a0
    80005e8a:	4705                	li	a4,1
    80005e8c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005e90:	00193517          	auipc	a0,0x193
    80005e94:	37050513          	add	a0,a0,880 # 80199200 <disk+0x18>
    80005e98:	ffffc097          	auipc	ra,0xffffc
    80005e9c:	344080e7          	jalr	836(ra) # 800021dc <wakeup>
}
    80005ea0:	60a2                	ld	ra,8(sp)
    80005ea2:	6402                	ld	s0,0(sp)
    80005ea4:	0141                	add	sp,sp,16
    80005ea6:	8082                	ret
    panic("free_desc 1");
    80005ea8:	00003517          	auipc	a0,0x3
    80005eac:	8d050513          	add	a0,a0,-1840 # 80008778 <syscalls+0x2f0>
    80005eb0:	ffffa097          	auipc	ra,0xffffa
    80005eb4:	68c080e7          	jalr	1676(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005eb8:	00003517          	auipc	a0,0x3
    80005ebc:	8d050513          	add	a0,a0,-1840 # 80008788 <syscalls+0x300>
    80005ec0:	ffffa097          	auipc	ra,0xffffa
    80005ec4:	67c080e7          	jalr	1660(ra) # 8000053c <panic>

0000000080005ec8 <virtio_disk_init>:
{
    80005ec8:	1101                	add	sp,sp,-32
    80005eca:	ec06                	sd	ra,24(sp)
    80005ecc:	e822                	sd	s0,16(sp)
    80005ece:	e426                	sd	s1,8(sp)
    80005ed0:	e04a                	sd	s2,0(sp)
    80005ed2:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005ed4:	00003597          	auipc	a1,0x3
    80005ed8:	8c458593          	add	a1,a1,-1852 # 80008798 <syscalls+0x310>
    80005edc:	00193517          	auipc	a0,0x193
    80005ee0:	43450513          	add	a0,a0,1076 # 80199310 <disk+0x128>
    80005ee4:	ffffb097          	auipc	ra,0xffffb
    80005ee8:	c5e080e7          	jalr	-930(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005eec:	100017b7          	lui	a5,0x10001
    80005ef0:	4398                	lw	a4,0(a5)
    80005ef2:	2701                	sext.w	a4,a4
    80005ef4:	747277b7          	lui	a5,0x74727
    80005ef8:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005efc:	14f71b63          	bne	a4,a5,80006052 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f00:	100017b7          	lui	a5,0x10001
    80005f04:	43dc                	lw	a5,4(a5)
    80005f06:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005f08:	4709                	li	a4,2
    80005f0a:	14e79463          	bne	a5,a4,80006052 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f0e:	100017b7          	lui	a5,0x10001
    80005f12:	479c                	lw	a5,8(a5)
    80005f14:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005f16:	12e79e63          	bne	a5,a4,80006052 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005f1a:	100017b7          	lui	a5,0x10001
    80005f1e:	47d8                	lw	a4,12(a5)
    80005f20:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005f22:	554d47b7          	lui	a5,0x554d4
    80005f26:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005f2a:	12f71463          	bne	a4,a5,80006052 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f2e:	100017b7          	lui	a5,0x10001
    80005f32:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f36:	4705                	li	a4,1
    80005f38:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f3a:	470d                	li	a4,3
    80005f3c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005f3e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005f40:	c7ffe6b7          	lui	a3,0xc7ffe
    80005f44:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47e64497>
    80005f48:	8f75                	and	a4,a4,a3
    80005f4a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005f4c:	472d                	li	a4,11
    80005f4e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005f50:	5bbc                	lw	a5,112(a5)
    80005f52:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005f56:	8ba1                	and	a5,a5,8
    80005f58:	10078563          	beqz	a5,80006062 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005f5c:	100017b7          	lui	a5,0x10001
    80005f60:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005f64:	43fc                	lw	a5,68(a5)
    80005f66:	2781                	sext.w	a5,a5
    80005f68:	10079563          	bnez	a5,80006072 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005f6c:	100017b7          	lui	a5,0x10001
    80005f70:	5bdc                	lw	a5,52(a5)
    80005f72:	2781                	sext.w	a5,a5
  if(max == 0)
    80005f74:	10078763          	beqz	a5,80006082 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005f78:	471d                	li	a4,7
    80005f7a:	10f77c63          	bgeu	a4,a5,80006092 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005f7e:	ffffb097          	auipc	ra,0xffffb
    80005f82:	b64080e7          	jalr	-1180(ra) # 80000ae2 <kalloc>
    80005f86:	00193497          	auipc	s1,0x193
    80005f8a:	26248493          	add	s1,s1,610 # 801991e8 <disk>
    80005f8e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005f90:	ffffb097          	auipc	ra,0xffffb
    80005f94:	b52080e7          	jalr	-1198(ra) # 80000ae2 <kalloc>
    80005f98:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005f9a:	ffffb097          	auipc	ra,0xffffb
    80005f9e:	b48080e7          	jalr	-1208(ra) # 80000ae2 <kalloc>
    80005fa2:	87aa                	mv	a5,a0
    80005fa4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005fa6:	6088                	ld	a0,0(s1)
    80005fa8:	cd6d                	beqz	a0,800060a2 <virtio_disk_init+0x1da>
    80005faa:	00193717          	auipc	a4,0x193
    80005fae:	24673703          	ld	a4,582(a4) # 801991f0 <disk+0x8>
    80005fb2:	cb65                	beqz	a4,800060a2 <virtio_disk_init+0x1da>
    80005fb4:	c7fd                	beqz	a5,800060a2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005fb6:	6605                	lui	a2,0x1
    80005fb8:	4581                	li	a1,0
    80005fba:	ffffb097          	auipc	ra,0xffffb
    80005fbe:	d14080e7          	jalr	-748(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005fc2:	00193497          	auipc	s1,0x193
    80005fc6:	22648493          	add	s1,s1,550 # 801991e8 <disk>
    80005fca:	6605                	lui	a2,0x1
    80005fcc:	4581                	li	a1,0
    80005fce:	6488                	ld	a0,8(s1)
    80005fd0:	ffffb097          	auipc	ra,0xffffb
    80005fd4:	cfe080e7          	jalr	-770(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005fd8:	6605                	lui	a2,0x1
    80005fda:	4581                	li	a1,0
    80005fdc:	6888                	ld	a0,16(s1)
    80005fde:	ffffb097          	auipc	ra,0xffffb
    80005fe2:	cf0080e7          	jalr	-784(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005fe6:	100017b7          	lui	a5,0x10001
    80005fea:	4721                	li	a4,8
    80005fec:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005fee:	4098                	lw	a4,0(s1)
    80005ff0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005ff4:	40d8                	lw	a4,4(s1)
    80005ff6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005ffa:	6498                	ld	a4,8(s1)
    80005ffc:	0007069b          	sext.w	a3,a4
    80006000:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006004:	9701                	sra	a4,a4,0x20
    80006006:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000600a:	6898                	ld	a4,16(s1)
    8000600c:	0007069b          	sext.w	a3,a4
    80006010:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006014:	9701                	sra	a4,a4,0x20
    80006016:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000601a:	4705                	li	a4,1
    8000601c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000601e:	00e48c23          	sb	a4,24(s1)
    80006022:	00e48ca3          	sb	a4,25(s1)
    80006026:	00e48d23          	sb	a4,26(s1)
    8000602a:	00e48da3          	sb	a4,27(s1)
    8000602e:	00e48e23          	sb	a4,28(s1)
    80006032:	00e48ea3          	sb	a4,29(s1)
    80006036:	00e48f23          	sb	a4,30(s1)
    8000603a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000603e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006042:	0727a823          	sw	s2,112(a5)
}
    80006046:	60e2                	ld	ra,24(sp)
    80006048:	6442                	ld	s0,16(sp)
    8000604a:	64a2                	ld	s1,8(sp)
    8000604c:	6902                	ld	s2,0(sp)
    8000604e:	6105                	add	sp,sp,32
    80006050:	8082                	ret
    panic("could not find virtio disk");
    80006052:	00002517          	auipc	a0,0x2
    80006056:	75650513          	add	a0,a0,1878 # 800087a8 <syscalls+0x320>
    8000605a:	ffffa097          	auipc	ra,0xffffa
    8000605e:	4e2080e7          	jalr	1250(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80006062:	00002517          	auipc	a0,0x2
    80006066:	76650513          	add	a0,a0,1894 # 800087c8 <syscalls+0x340>
    8000606a:	ffffa097          	auipc	ra,0xffffa
    8000606e:	4d2080e7          	jalr	1234(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80006072:	00002517          	auipc	a0,0x2
    80006076:	77650513          	add	a0,a0,1910 # 800087e8 <syscalls+0x360>
    8000607a:	ffffa097          	auipc	ra,0xffffa
    8000607e:	4c2080e7          	jalr	1218(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80006082:	00002517          	auipc	a0,0x2
    80006086:	78650513          	add	a0,a0,1926 # 80008808 <syscalls+0x380>
    8000608a:	ffffa097          	auipc	ra,0xffffa
    8000608e:	4b2080e7          	jalr	1202(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80006092:	00002517          	auipc	a0,0x2
    80006096:	79650513          	add	a0,a0,1942 # 80008828 <syscalls+0x3a0>
    8000609a:	ffffa097          	auipc	ra,0xffffa
    8000609e:	4a2080e7          	jalr	1186(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    800060a2:	00002517          	auipc	a0,0x2
    800060a6:	7a650513          	add	a0,a0,1958 # 80008848 <syscalls+0x3c0>
    800060aa:	ffffa097          	auipc	ra,0xffffa
    800060ae:	492080e7          	jalr	1170(ra) # 8000053c <panic>

00000000800060b2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800060b2:	7159                	add	sp,sp,-112
    800060b4:	f486                	sd	ra,104(sp)
    800060b6:	f0a2                	sd	s0,96(sp)
    800060b8:	eca6                	sd	s1,88(sp)
    800060ba:	e8ca                	sd	s2,80(sp)
    800060bc:	e4ce                	sd	s3,72(sp)
    800060be:	e0d2                	sd	s4,64(sp)
    800060c0:	fc56                	sd	s5,56(sp)
    800060c2:	f85a                	sd	s6,48(sp)
    800060c4:	f45e                	sd	s7,40(sp)
    800060c6:	f062                	sd	s8,32(sp)
    800060c8:	ec66                	sd	s9,24(sp)
    800060ca:	e86a                	sd	s10,16(sp)
    800060cc:	1880                	add	s0,sp,112
    800060ce:	8a2a                	mv	s4,a0
    800060d0:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800060d2:	00c52c83          	lw	s9,12(a0)
    800060d6:	001c9c9b          	sllw	s9,s9,0x1
    800060da:	1c82                	sll	s9,s9,0x20
    800060dc:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    800060e0:	00193517          	auipc	a0,0x193
    800060e4:	23050513          	add	a0,a0,560 # 80199310 <disk+0x128>
    800060e8:	ffffb097          	auipc	ra,0xffffb
    800060ec:	aea080e7          	jalr	-1302(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    800060f0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    800060f2:	44a1                	li	s1,8
      disk.free[i] = 0;
    800060f4:	00193b17          	auipc	s6,0x193
    800060f8:	0f4b0b13          	add	s6,s6,244 # 801991e8 <disk>
  for(int i = 0; i < 3; i++){
    800060fc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060fe:	00193c17          	auipc	s8,0x193
    80006102:	212c0c13          	add	s8,s8,530 # 80199310 <disk+0x128>
    80006106:	a095                	j	8000616a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006108:	00fb0733          	add	a4,s6,a5
    8000610c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006110:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006112:	0207c563          	bltz	a5,8000613c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006116:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006118:	0591                	add	a1,a1,4
    8000611a:	05560d63          	beq	a2,s5,80006174 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000611e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006120:	00193717          	auipc	a4,0x193
    80006124:	0c870713          	add	a4,a4,200 # 801991e8 <disk>
    80006128:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000612a:	01874683          	lbu	a3,24(a4)
    8000612e:	fee9                	bnez	a3,80006108 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006130:	2785                	addw	a5,a5,1
    80006132:	0705                	add	a4,a4,1
    80006134:	fe979be3          	bne	a5,s1,8000612a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006138:	57fd                	li	a5,-1
    8000613a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000613c:	00c05e63          	blez	a2,80006158 <virtio_disk_rw+0xa6>
    80006140:	060a                	sll	a2,a2,0x2
    80006142:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80006146:	0009a503          	lw	a0,0(s3)
    8000614a:	00000097          	auipc	ra,0x0
    8000614e:	cfc080e7          	jalr	-772(ra) # 80005e46 <free_desc>
      for(int j = 0; j < i; j++)
    80006152:	0991                	add	s3,s3,4
    80006154:	ffa999e3          	bne	s3,s10,80006146 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006158:	85e2                	mv	a1,s8
    8000615a:	00193517          	auipc	a0,0x193
    8000615e:	0a650513          	add	a0,a0,166 # 80199200 <disk+0x18>
    80006162:	ffffc097          	auipc	ra,0xffffc
    80006166:	016080e7          	jalr	22(ra) # 80002178 <sleep>
  for(int i = 0; i < 3; i++){
    8000616a:	f9040993          	add	s3,s0,-112
{
    8000616e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80006170:	864a                	mv	a2,s2
    80006172:	b775                	j	8000611e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006174:	f9042503          	lw	a0,-112(s0)
    80006178:	00a50713          	add	a4,a0,10
    8000617c:	0712                	sll	a4,a4,0x4

  if(write)
    8000617e:	00193797          	auipc	a5,0x193
    80006182:	06a78793          	add	a5,a5,106 # 801991e8 <disk>
    80006186:	00e786b3          	add	a3,a5,a4
    8000618a:	01703633          	snez	a2,s7
    8000618e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80006190:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80006194:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80006198:	f6070613          	add	a2,a4,-160
    8000619c:	6394                	ld	a3,0(a5)
    8000619e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800061a0:	00870593          	add	a1,a4,8
    800061a4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800061a6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800061a8:	0007b803          	ld	a6,0(a5)
    800061ac:	9642                	add	a2,a2,a6
    800061ae:	46c1                	li	a3,16
    800061b0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800061b2:	4585                	li	a1,1
    800061b4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800061b8:	f9442683          	lw	a3,-108(s0)
    800061bc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800061c0:	0692                	sll	a3,a3,0x4
    800061c2:	9836                	add	a6,a6,a3
    800061c4:	058a0613          	add	a2,s4,88
    800061c8:	00c83023          	sd	a2,0(a6) # 1000 <_entry-0x7ffff000>
  disk.desc[idx[1]].len = BSIZE;
    800061cc:	0007b803          	ld	a6,0(a5)
    800061d0:	96c2                	add	a3,a3,a6
    800061d2:	40000613          	li	a2,1024
    800061d6:	c690                	sw	a2,8(a3)
  if(write)
    800061d8:	001bb613          	seqz	a2,s7
    800061dc:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800061e0:	00166613          	or	a2,a2,1
    800061e4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800061e8:	f9842603          	lw	a2,-104(s0)
    800061ec:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800061f0:	00250693          	add	a3,a0,2
    800061f4:	0692                	sll	a3,a3,0x4
    800061f6:	96be                	add	a3,a3,a5
    800061f8:	58fd                	li	a7,-1
    800061fa:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800061fe:	0612                	sll	a2,a2,0x4
    80006200:	9832                	add	a6,a6,a2
    80006202:	f9070713          	add	a4,a4,-112
    80006206:	973e                	add	a4,a4,a5
    80006208:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000620c:	6398                	ld	a4,0(a5)
    8000620e:	9732                	add	a4,a4,a2
    80006210:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006212:	4609                	li	a2,2
    80006214:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006218:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000621c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006220:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006224:	6794                	ld	a3,8(a5)
    80006226:	0026d703          	lhu	a4,2(a3)
    8000622a:	8b1d                	and	a4,a4,7
    8000622c:	0706                	sll	a4,a4,0x1
    8000622e:	96ba                	add	a3,a3,a4
    80006230:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006234:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006238:	6798                	ld	a4,8(a5)
    8000623a:	00275783          	lhu	a5,2(a4)
    8000623e:	2785                	addw	a5,a5,1
    80006240:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006244:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006248:	100017b7          	lui	a5,0x10001
    8000624c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006250:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006254:	00193917          	auipc	s2,0x193
    80006258:	0bc90913          	add	s2,s2,188 # 80199310 <disk+0x128>
  while(b->disk == 1) {
    8000625c:	4485                	li	s1,1
    8000625e:	00b79c63          	bne	a5,a1,80006276 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006262:	85ca                	mv	a1,s2
    80006264:	8552                	mv	a0,s4
    80006266:	ffffc097          	auipc	ra,0xffffc
    8000626a:	f12080e7          	jalr	-238(ra) # 80002178 <sleep>
  while(b->disk == 1) {
    8000626e:	004a2783          	lw	a5,4(s4)
    80006272:	fe9788e3          	beq	a5,s1,80006262 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006276:	f9042903          	lw	s2,-112(s0)
    8000627a:	00290713          	add	a4,s2,2
    8000627e:	0712                	sll	a4,a4,0x4
    80006280:	00193797          	auipc	a5,0x193
    80006284:	f6878793          	add	a5,a5,-152 # 801991e8 <disk>
    80006288:	97ba                	add	a5,a5,a4
    8000628a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000628e:	00193997          	auipc	s3,0x193
    80006292:	f5a98993          	add	s3,s3,-166 # 801991e8 <disk>
    80006296:	00491713          	sll	a4,s2,0x4
    8000629a:	0009b783          	ld	a5,0(s3)
    8000629e:	97ba                	add	a5,a5,a4
    800062a0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800062a4:	854a                	mv	a0,s2
    800062a6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800062aa:	00000097          	auipc	ra,0x0
    800062ae:	b9c080e7          	jalr	-1124(ra) # 80005e46 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800062b2:	8885                	and	s1,s1,1
    800062b4:	f0ed                	bnez	s1,80006296 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800062b6:	00193517          	auipc	a0,0x193
    800062ba:	05a50513          	add	a0,a0,90 # 80199310 <disk+0x128>
    800062be:	ffffb097          	auipc	ra,0xffffb
    800062c2:	9c8080e7          	jalr	-1592(ra) # 80000c86 <release>
}
    800062c6:	70a6                	ld	ra,104(sp)
    800062c8:	7406                	ld	s0,96(sp)
    800062ca:	64e6                	ld	s1,88(sp)
    800062cc:	6946                	ld	s2,80(sp)
    800062ce:	69a6                	ld	s3,72(sp)
    800062d0:	6a06                	ld	s4,64(sp)
    800062d2:	7ae2                	ld	s5,56(sp)
    800062d4:	7b42                	ld	s6,48(sp)
    800062d6:	7ba2                	ld	s7,40(sp)
    800062d8:	7c02                	ld	s8,32(sp)
    800062da:	6ce2                	ld	s9,24(sp)
    800062dc:	6d42                	ld	s10,16(sp)
    800062de:	6165                	add	sp,sp,112
    800062e0:	8082                	ret

00000000800062e2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800062e2:	1101                	add	sp,sp,-32
    800062e4:	ec06                	sd	ra,24(sp)
    800062e6:	e822                	sd	s0,16(sp)
    800062e8:	e426                	sd	s1,8(sp)
    800062ea:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    800062ec:	00193497          	auipc	s1,0x193
    800062f0:	efc48493          	add	s1,s1,-260 # 801991e8 <disk>
    800062f4:	00193517          	auipc	a0,0x193
    800062f8:	01c50513          	add	a0,a0,28 # 80199310 <disk+0x128>
    800062fc:	ffffb097          	auipc	ra,0xffffb
    80006300:	8d6080e7          	jalr	-1834(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006304:	10001737          	lui	a4,0x10001
    80006308:	533c                	lw	a5,96(a4)
    8000630a:	8b8d                	and	a5,a5,3
    8000630c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000630e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006312:	689c                	ld	a5,16(s1)
    80006314:	0204d703          	lhu	a4,32(s1)
    80006318:	0027d783          	lhu	a5,2(a5)
    8000631c:	04f70863          	beq	a4,a5,8000636c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006320:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006324:	6898                	ld	a4,16(s1)
    80006326:	0204d783          	lhu	a5,32(s1)
    8000632a:	8b9d                	and	a5,a5,7
    8000632c:	078e                	sll	a5,a5,0x3
    8000632e:	97ba                	add	a5,a5,a4
    80006330:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006332:	00278713          	add	a4,a5,2
    80006336:	0712                	sll	a4,a4,0x4
    80006338:	9726                	add	a4,a4,s1
    8000633a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000633e:	e721                	bnez	a4,80006386 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006340:	0789                	add	a5,a5,2
    80006342:	0792                	sll	a5,a5,0x4
    80006344:	97a6                	add	a5,a5,s1
    80006346:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006348:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000634c:	ffffc097          	auipc	ra,0xffffc
    80006350:	e90080e7          	jalr	-368(ra) # 800021dc <wakeup>

    disk.used_idx += 1;
    80006354:	0204d783          	lhu	a5,32(s1)
    80006358:	2785                	addw	a5,a5,1
    8000635a:	17c2                	sll	a5,a5,0x30
    8000635c:	93c1                	srl	a5,a5,0x30
    8000635e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006362:	6898                	ld	a4,16(s1)
    80006364:	00275703          	lhu	a4,2(a4)
    80006368:	faf71ce3          	bne	a4,a5,80006320 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000636c:	00193517          	auipc	a0,0x193
    80006370:	fa450513          	add	a0,a0,-92 # 80199310 <disk+0x128>
    80006374:	ffffb097          	auipc	ra,0xffffb
    80006378:	912080e7          	jalr	-1774(ra) # 80000c86 <release>
}
    8000637c:	60e2                	ld	ra,24(sp)
    8000637e:	6442                	ld	s0,16(sp)
    80006380:	64a2                	ld	s1,8(sp)
    80006382:	6105                	add	sp,sp,32
    80006384:	8082                	ret
      panic("virtio_disk_intr status");
    80006386:	00002517          	auipc	a0,0x2
    8000638a:	4da50513          	add	a0,a0,1242 # 80008860 <syscalls+0x3d8>
    8000638e:	ffffa097          	auipc	ra,0xffffa
    80006392:	1ae080e7          	jalr	430(ra) # 8000053c <panic>

0000000080006396 <read_current_timestamp>:

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
    80006396:	1101                	add	sp,sp,-32
    80006398:	ec06                	sd	ra,24(sp)
    8000639a:	e822                	sd	s0,16(sp)
    8000639c:	e426                	sd	s1,8(sp)
    8000639e:	1000                	add	s0,sp,32
  uint64 curticks = 0;
  acquire(&tickslock);
    800063a0:	00188517          	auipc	a0,0x188
    800063a4:	ba050513          	add	a0,a0,-1120 # 8018df40 <tickslock>
    800063a8:	ffffb097          	auipc	ra,0xffffb
    800063ac:	82a080e7          	jalr	-2006(ra) # 80000bd2 <acquire>
  curticks = ticks;
    800063b0:	00002517          	auipc	a0,0x2
    800063b4:	6f050513          	add	a0,a0,1776 # 80008aa0 <ticks>
    800063b8:	00056483          	lwu	s1,0(a0)
  wakeup(&ticks);
    800063bc:	ffffc097          	auipc	ra,0xffffc
    800063c0:	e20080e7          	jalr	-480(ra) # 800021dc <wakeup>
  release(&tickslock);
    800063c4:	00188517          	auipc	a0,0x188
    800063c8:	b7c50513          	add	a0,a0,-1156 # 8018df40 <tickslock>
    800063cc:	ffffb097          	auipc	ra,0xffffb
    800063d0:	8ba080e7          	jalr	-1862(ra) # 80000c86 <release>
  return curticks;
}
    800063d4:	8526                	mv	a0,s1
    800063d6:	60e2                	ld	ra,24(sp)
    800063d8:	6442                	ld	s0,16(sp)
    800063da:	64a2                	ld	s1,8(sp)
    800063dc:	6105                	add	sp,sp,32
    800063de:	8082                	ret

00000000800063e0 <init_psa_regions>:

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    800063e0:	1141                	add	sp,sp,-16
    800063e2:	e422                	sd	s0,8(sp)
    800063e4:	0800                	add	s0,sp,16
    for (int i = 0; i < PSASIZE; i++) 
    800063e6:	00193797          	auipc	a5,0x193
    800063ea:	f4278793          	add	a5,a5,-190 # 80199328 <psa_tracker>
    800063ee:	00194717          	auipc	a4,0x194
    800063f2:	eda70713          	add	a4,a4,-294 # 8019a2c8 <end>
        psa_tracker[i] = false;
    800063f6:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PSASIZE; i++) 
    800063fa:	0785                	add	a5,a5,1
    800063fc:	fee79de3          	bne	a5,a4,800063f6 <init_psa_regions+0x16>
}
    80006400:	6422                	ld	s0,8(sp)
    80006402:	0141                	add	sp,sp,16
    80006404:	8082                	ret

0000000080006406 <evict_page_to_disk>:

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    80006406:	7139                	add	sp,sp,-64
    80006408:	fc06                	sd	ra,56(sp)
    8000640a:	f822                	sd	s0,48(sp)
    8000640c:	f426                	sd	s1,40(sp)
    8000640e:	f04a                	sd	s2,32(sp)
    80006410:	ec4e                	sd	s3,24(sp)
    80006412:	e852                	sd	s4,16(sp)
    80006414:	e456                	sd	s5,8(sp)
    80006416:	e05a                	sd	s6,0(sp)
    80006418:	0080                	add	s0,sp,64
    8000641a:	892a                	mv	s2,a0
    /* Find free block */
    int blockno = 0;
    // Find 4 free blocks in the PSA.
    for (int i = 0; i < PSASIZE; i+=4) {
    8000641c:	00193797          	auipc	a5,0x193
    80006420:	f0c78793          	add	a5,a5,-244 # 80199328 <psa_tracker>
    80006424:	4481                	li	s1,0
    80006426:	6685                	lui	a3,0x1
    80006428:	fa068693          	add	a3,a3,-96 # fa0 <_entry-0x7ffff060>
        if (psa_tracker[i] == false) {
    8000642c:	0007c703          	lbu	a4,0(a5)
    80006430:	c719                	beqz	a4,8000643e <evict_page_to_disk+0x38>
    for (int i = 0; i < PSASIZE; i+=4) {
    80006432:	2491                	addw	s1,s1,4
    80006434:	0791                	add	a5,a5,4
    80006436:	fed49be3          	bne	s1,a3,8000642c <evict_page_to_disk+0x26>
    int blockno = 0;
    8000643a:	4481                	li	s1,0
    8000643c:	a809                	j	8000644e <evict_page_to_disk+0x48>
            psa_tracker[i] = true;
    8000643e:	00193797          	auipc	a5,0x193
    80006442:	eea78793          	add	a5,a5,-278 # 80199328 <psa_tracker>
    80006446:	97a6                	add	a5,a5,s1
    80006448:	4705                	li	a4,1
    8000644a:	00e78023          	sb	a4,0(a5)
    }
    
    // Find the victim page address and victim timestamp using FIFO.
    uint64 victim_addr = 0, idx = 0;
    uint64 victim_timestamp = 0xFFFFFFFFFFFFFFFF;
    for(int i=0; i<MAXHEAP; i++) {
    8000644e:	17890793          	add	a5,s2,376
    int blockno = 0;
    80006452:	4701                	li	a4,0
    uint64 victim_timestamp = 0xFFFFFFFFFFFFFFFF;
    80006454:	55fd                	li	a1,-1
    uint64 victim_addr = 0, idx = 0;
    80006456:	4981                	li	s3,0
    for(int i=0; i<MAXHEAP; i++) {
    80006458:	3e800613          	li	a2,1000
    8000645c:	a029                	j	80006466 <evict_page_to_disk+0x60>
    8000645e:	0705                	add	a4,a4,1
    80006460:	07e1                	add	a5,a5,24
    80006462:	00c70b63          	beq	a4,a2,80006478 <evict_page_to_disk+0x72>
        if(p->heap_tracker[i].loaded == true) {
    80006466:	0087c683          	lbu	a3,8(a5)
    8000646a:	daf5                	beqz	a3,8000645e <evict_page_to_disk+0x58>
            if(p->heap_tracker[i].last_load_time < victim_timestamp) {
    8000646c:	6394                	ld	a3,0(a5)
    8000646e:	feb6f8e3          	bgeu	a3,a1,8000645e <evict_page_to_disk+0x58>
                victim_addr = p->heap_tracker[i].addr;
                victim_timestamp = p->heap_tracker[i].last_load_time;
    80006472:	85b6                	mv	a1,a3
                idx = i;
    80006474:	89ba                	mv	s3,a4
    80006476:	b7e5                	j	8000645e <evict_page_to_disk+0x58>
            }
        }
    }

    p->heap_tracker[idx].startblock = blockno;
    80006478:	00199a13          	sll	s4,s3,0x1
    8000647c:	9a4e                	add	s4,s4,s3
    8000647e:	0a0e                	sll	s4,s4,0x3
    80006480:	9a4a                	add	s4,s4,s2
    80006482:	189a2223          	sw	s1,388(s4)
    p->heap_tracker[idx].loaded = false;
    80006486:	180a0023          	sb	zero,384(s4)

    /* Print statement. */
    print_evict_page(p->heap_tracker[idx].addr, p->heap_tracker[idx].startblock);
    8000648a:	85a6                	mv	a1,s1
    8000648c:	170a3503          	ld	a0,368(s4)
    80006490:	00000097          	auipc	ra,0x0
    80006494:	4e4080e7          	jalr	1252(ra) # 80006974 <print_evict_page>

    /* Read memory from the user to kernel memory first. */
    // Copy victim page from user memory to kernel memory using copyin function.
    char *kernel_alloc;
    kernel_alloc = (char*)kalloc();
    80006498:	ffffa097          	auipc	ra,0xffffa
    8000649c:	64a080e7          	jalr	1610(ra) # 80000ae2 <kalloc>
    800064a0:	8aaa                	mv	s5,a0
    memset(kernel_alloc, 0, PGSIZE);
    800064a2:	6605                	lui	a2,0x1
    800064a4:	4581                	li	a1,0
    800064a6:	ffffb097          	auipc	ra,0xffffb
    800064aa:	828080e7          	jalr	-2008(ra) # 80000cce <memset>
    copyin(p->pagetable, kernel_alloc, (char*)p->heap_tracker[idx].addr, PGSIZE);
    800064ae:	6685                	lui	a3,0x1
    800064b0:	170a3603          	ld	a2,368(s4)
    800064b4:	85d6                	mv	a1,s5
    800064b6:	05093503          	ld	a0,80(s2)
    800064ba:	ffffb097          	auipc	ra,0xffffb
    800064be:	264080e7          	jalr	612(ra) # 8000171e <copyin>
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    // write the kernel memory to the 4 disk blocks using memmove and bwrite
    for (int i = 0; i < 4; i++) {
    800064c2:	0214849b          	addw	s1,s1,33
    800064c6:	6b05                	lui	s6,0x1
    800064c8:	9b56                	add	s6,s6,s5
        struct buf* b;
        b = bread(1, PSASTART+(blockno+i));
    800064ca:	85a6                	mv	a1,s1
    800064cc:	4505                	li	a0,1
    800064ce:	ffffd097          	auipc	ra,0xffffd
    800064d2:	ad6080e7          	jalr	-1322(ra) # 80002fa4 <bread>
    800064d6:	8a2a                	mv	s4,a0
        memmove(b->data, kernel_alloc, 1024);
    800064d8:	40000613          	li	a2,1024
    800064dc:	85d6                	mv	a1,s5
    800064de:	05850513          	add	a0,a0,88
    800064e2:	ffffb097          	auipc	ra,0xffffb
    800064e6:	848080e7          	jalr	-1976(ra) # 80000d2a <memmove>
        bwrite(b);
    800064ea:	8552                	mv	a0,s4
    800064ec:	ffffd097          	auipc	ra,0xffffd
    800064f0:	baa080e7          	jalr	-1110(ra) # 80003096 <bwrite>
        brelse(b);
    800064f4:	8552                	mv	a0,s4
    800064f6:	ffffd097          	auipc	ra,0xffffd
    800064fa:	bde080e7          	jalr	-1058(ra) # 800030d4 <brelse>
        kernel_alloc += 1024;
    800064fe:	400a8a93          	add	s5,s5,1024
    for (int i = 0; i < 4; i++) {
    80006502:	2485                	addw	s1,s1,1
    80006504:	fd6a93e3          	bne	s5,s6,800064ca <evict_page_to_disk+0xc4>
    }


    /* Unmap swapped out page */
    // use the victim address to unmap the page using uvmunmap
    uvmunmap(p->pagetable, p->heap_tracker[idx].addr, 1, 1);
    80006508:	00199793          	sll	a5,s3,0x1
    8000650c:	97ce                	add	a5,a5,s3
    8000650e:	078e                	sll	a5,a5,0x3
    80006510:	97ca                	add	a5,a5,s2
    80006512:	4685                	li	a3,1
    80006514:	4605                	li	a2,1
    80006516:	1707b583          	ld	a1,368(a5)
    8000651a:	05093503          	ld	a0,80(s2)
    8000651e:	ffffb097          	auipc	ra,0xffffb
    80006522:	d48080e7          	jalr	-696(ra) # 80001266 <uvmunmap>

    /* Update the resident heap tracker. */
    p->resident_heap_pages -= 1;
    80006526:	6799                	lui	a5,0x6
    80006528:	993e                	add	s2,s2,a5
    8000652a:	f3092783          	lw	a5,-208(s2)
    8000652e:	37fd                	addw	a5,a5,-1 # 5fff <_entry-0x7fffa001>
    80006530:	f2f92823          	sw	a5,-208(s2)
}
    80006534:	70e2                	ld	ra,56(sp)
    80006536:	7442                	ld	s0,48(sp)
    80006538:	74a2                	ld	s1,40(sp)
    8000653a:	7902                	ld	s2,32(sp)
    8000653c:	69e2                	ld	s3,24(sp)
    8000653e:	6a42                	ld	s4,16(sp)
    80006540:	6aa2                	ld	s5,8(sp)
    80006542:	6b02                	ld	s6,0(sp)
    80006544:	6121                	add	sp,sp,64
    80006546:	8082                	ret

0000000080006548 <retrieve_page_from_disk>:

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    80006548:	715d                	add	sp,sp,-80
    8000654a:	e486                	sd	ra,72(sp)
    8000654c:	e0a2                	sd	s0,64(sp)
    8000654e:	fc26                	sd	s1,56(sp)
    80006550:	f84a                	sd	s2,48(sp)
    80006552:	f44e                	sd	s3,40(sp)
    80006554:	f052                	sd	s4,32(sp)
    80006556:	ec56                	sd	s5,24(sp)
    80006558:	e85a                	sd	s6,16(sp)
    8000655a:	e45e                	sd	s7,8(sp)
    8000655c:	e062                	sd	s8,0(sp)
    8000655e:	0880                	add	s0,sp,80
    80006560:	8aaa                	mv	s5,a0
    80006562:	84ae                	mv	s1,a1
    /* Find where the page is located in disk */
    int blockno = 0;
    for(int i=0; i<MAXHEAP; i++) {
    80006564:	17050793          	add	a5,a0,368
    80006568:	4701                	li	a4,0
    8000656a:	3e800613          	li	a2,1000
    8000656e:	a029                	j	80006578 <retrieve_page_from_disk+0x30>
    80006570:	2705                	addw	a4,a4,1
    80006572:	07e1                	add	a5,a5,24
    80006574:	0ac70563          	beq	a4,a2,8000661e <retrieve_page_from_disk+0xd6>
        if(p->heap_tracker[i].addr == uvaddr) {
    80006578:	6394                	ld	a3,0(a5)
    8000657a:	fe969be3          	bne	a3,s1,80006570 <retrieve_page_from_disk+0x28>
            if(p->heap_tracker[i].loaded == false){
    8000657e:	0107c683          	lbu	a3,16(a5)
    80006582:	f6fd                	bnez	a3,80006570 <retrieve_page_from_disk+0x28>
                blockno = p->heap_tracker[i].startblock;
    80006584:	00171793          	sll	a5,a4,0x1
    80006588:	97ba                	add	a5,a5,a4
    8000658a:	078e                	sll	a5,a5,0x3
    8000658c:	97d6                	add	a5,a5,s5
    8000658e:	1847ac03          	lw	s8,388(a5)
        }
    }

    // p->heap_tracker[blockno].startblock = blockno;
    // p->heap_tracker[blockno].loaded = false;
    psa_tracker[blockno] = false;
    80006592:	00193797          	auipc	a5,0x193
    80006596:	d9678793          	add	a5,a5,-618 # 80199328 <psa_tracker>
    8000659a:	97e2                	add	a5,a5,s8
    8000659c:	00078023          	sb	zero,0(a5)

    /* Copy from temp kernel page to uvaddr (use copyout) */
    char *kernel_alloc;
    kernel_alloc = (char*)kalloc();
    800065a0:	ffffa097          	auipc	ra,0xffffa
    800065a4:	542080e7          	jalr	1346(ra) # 80000ae2 <kalloc>
    800065a8:	8baa                	mv	s7,a0

    /* Read the disk block into temp kernel page. */
    for (int i = 0; i < 4; i++) {
    800065aa:	021c0a1b          	addw	s4,s8,33
    800065ae:	6b05                	lui	s6,0x1
    800065b0:	9b2a                	add	s6,s6,a0
    kernel_alloc = (char*)kalloc();
    800065b2:	89aa                	mv	s3,a0
        struct buf* b;
        b = bread(1, PSASTART+(blockno+i));
    800065b4:	85d2                	mv	a1,s4
    800065b6:	4505                	li	a0,1
    800065b8:	ffffd097          	auipc	ra,0xffffd
    800065bc:	9ec080e7          	jalr	-1556(ra) # 80002fa4 <bread>
    800065c0:	892a                	mv	s2,a0
        memmove(kernel_alloc, b->data, 1024);
    800065c2:	40000613          	li	a2,1024
    800065c6:	05850593          	add	a1,a0,88
    800065ca:	854e                	mv	a0,s3
    800065cc:	ffffa097          	auipc	ra,0xffffa
    800065d0:	75e080e7          	jalr	1886(ra) # 80000d2a <memmove>
        brelse(b);
    800065d4:	854a                	mv	a0,s2
    800065d6:	ffffd097          	auipc	ra,0xffffd
    800065da:	afe080e7          	jalr	-1282(ra) # 800030d4 <brelse>
        kernel_alloc += 1024;
    800065de:	40098993          	add	s3,s3,1024
    for (int i = 0; i < 4; i++) {
    800065e2:	2a05                	addw	s4,s4,1
    800065e4:	fd6998e3          	bne	s3,s6,800065b4 <retrieve_page_from_disk+0x6c>
    }
    
    copyout(p->pagetable, (char*)uvaddr, kernel_alloc-PGSIZE, PGSIZE);
    800065e8:	6685                	lui	a3,0x1
    800065ea:	865e                	mv	a2,s7
    800065ec:	85a6                	mv	a1,s1
    800065ee:	050ab503          	ld	a0,80(s5)
    800065f2:	ffffb097          	auipc	ra,0xffffb
    800065f6:	0a0080e7          	jalr	160(ra) # 80001692 <copyout>

    /* Print statement. */
    print_retrieve_page(uvaddr, blockno);
    800065fa:	85e2                	mv	a1,s8
    800065fc:	8526                	mv	a0,s1
    800065fe:	00000097          	auipc	ra,0x0
    80006602:	39e080e7          	jalr	926(ra) # 8000699c <print_retrieve_page>

    /* Create a kernel page to read memory temporarily into first. */
    
}
    80006606:	60a6                	ld	ra,72(sp)
    80006608:	6406                	ld	s0,64(sp)
    8000660a:	74e2                	ld	s1,56(sp)
    8000660c:	7942                	ld	s2,48(sp)
    8000660e:	79a2                	ld	s3,40(sp)
    80006610:	7a02                	ld	s4,32(sp)
    80006612:	6ae2                	ld	s5,24(sp)
    80006614:	6b42                	ld	s6,16(sp)
    80006616:	6ba2                	ld	s7,8(sp)
    80006618:	6c02                	ld	s8,0(sp)
    8000661a:	6161                	add	sp,sp,80
    8000661c:	8082                	ret
    int blockno = 0;
    8000661e:	4c01                	li	s8,0
    80006620:	bf8d                	j	80006592 <retrieve_page_from_disk+0x4a>

0000000080006622 <page_fault_handler>:


void page_fault_handler(void) 
{
    80006622:	7155                	add	sp,sp,-208
    80006624:	e586                	sd	ra,200(sp)
    80006626:	e1a2                	sd	s0,192(sp)
    80006628:	fd26                	sd	s1,184(sp)
    8000662a:	f94a                	sd	s2,176(sp)
    8000662c:	f54e                	sd	s3,168(sp)
    8000662e:	f152                	sd	s4,160(sp)
    80006630:	ed56                	sd	s5,152(sp)
    80006632:	e95a                	sd	s6,144(sp)
    80006634:	e55e                	sd	s7,136(sp)
    80006636:	0980                	add	s0,sp,208
    /* Current process struct */
    struct proc *p = myproc();
    80006638:	ffffb097          	auipc	ra,0xffffb
    8000663c:	3aa080e7          	jalr	938(ra) # 800019e2 <myproc>
    80006640:	8a2a                	mv	s4,a0
    80006642:	143029f3          	csrr	s3,stval
    faulting_addr = r_stval();
    
    // get the faulting address from stval and find the base address of the page
    // faulting_addr = PGROUNDDOWN(faulting_addr);
    faulting_addr >>= 12;
    faulting_addr <<= 12;
    80006646:	77fd                	lui	a5,0xfffff
    80006648:	00f9f9b3          	and	s3,s3,a5
    print_page_fault(p->name, faulting_addr);
    8000664c:	15850493          	add	s1,a0,344
    80006650:	85ce                	mv	a1,s3
    80006652:	8526                	mv	a0,s1
    80006654:	00000097          	auipc	ra,0x0
    80006658:	2e0080e7          	jalr	736(ra) # 80006934 <print_page_fault>

    for(int i=0; i<MAXHEAP; i++) {
    8000665c:	170a0913          	add	s2,s4,368
    print_page_fault(p->name, faulting_addr);
    80006660:	874a                	mv	a4,s2
    for(int i=0; i<MAXHEAP; i++) {
    80006662:	4781                	li	a5,0
    80006664:	3e800613          	li	a2,1000
        if(p->heap_tracker[i].addr == faulting_addr) {
    80006668:	6314                	ld	a3,0(a4)
    8000666a:	07368b63          	beq	a3,s3,800066e0 <page_fault_handler+0xbe>
    for(int i=0; i<MAXHEAP; i++) {
    8000666e:	2785                	addw	a5,a5,1 # fffffffffffff001 <end+0xffffffff7fe64d39>
    80006670:	0761                	add	a4,a4,24
    80006672:	fec79be3          	bne	a5,a2,80006668 <page_fault_handler+0x46>
    uint64 pagesize = PGSIZE, allowed_size = 0, offset = 0, sz = 0;
    pagetable_t pagetable = 0;
    char* path = p->name;

    // same checks as in exec.c
    begin_op();    
    80006676:	ffffe097          	auipc	ra,0xffffe
    8000667a:	ae4080e7          	jalr	-1308(ra) # 8000415a <begin_op>

    if((ip = namei(path)) == 0){
    8000667e:	8526                	mv	a0,s1
    80006680:	ffffe097          	auipc	ra,0xffffe
    80006684:	8da080e7          	jalr	-1830(ra) # 80003f5a <namei>
    80006688:	892a                	mv	s2,a0
    8000668a:	c545                	beqz	a0,80006732 <page_fault_handler+0x110>
        end_op();
    }
    ilock(ip);
    8000668c:	ffffd097          	auipc	ra,0xffffd
    80006690:	128080e7          	jalr	296(ra) # 800037b4 <ilock>
    
    // read the elf header
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006694:	04000713          	li	a4,64
    80006698:	4681                	li	a3,0
    8000669a:	f7040613          	add	a2,s0,-144
    8000669e:	4581                	li	a1,0
    800066a0:	854a                	mv	a0,s2
    800066a2:	ffffd097          	auipc	ra,0xffffd
    800066a6:	3c6080e7          	jalr	966(ra) # 80003a68 <readi>
    800066aa:	04000793          	li	a5,64
    800066ae:	20f51463          	bne	a0,a5,800068b6 <page_fault_handler+0x294>
        goto bad;

    if(elf.magic != ELF_MAGIC)
    800066b2:	f7042703          	lw	a4,-144(s0)
    800066b6:	464c47b7          	lui	a5,0x464c4
    800066ba:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800066be:	1ef71c63          	bne	a4,a5,800068b6 <page_fault_handler+0x294>
        goto bad;

    if((pagetable = p->pagetable) == 0)
    800066c2:	050a3a83          	ld	s5,80(s4)
    800066c6:	1e0a8663          	beqz	s5,800068b2 <page_fault_handler+0x290>
        goto bad;

    // read the program section headers to find the one that contains the faulting address
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800066ca:	f9042483          	lw	s1,-112(s0)
    800066ce:	fa845783          	lhu	a5,-88(s0)
    800066d2:	14078d63          	beqz	a5,8000682c <page_fault_handler+0x20a>
    800066d6:	4a01                	li	s4,0
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            goto bad;
        if(ph.type != ELF_PROG_LOAD)
    800066d8:	4b05                	li	s6,1
            continue;
        if(ph.memsz < ph.filesz)
            goto bad;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            goto bad;
        if(ph.vaddr % PGSIZE != 0)
    800066da:	6b85                	lui	s7,0x1
    800066dc:	1bfd                	add	s7,s7,-1 # fff <_entry-0x7ffff001>
    800066de:	a055                	j	80006782 <page_fault_handler+0x160>
            if(p->heap_tracker[i].startblock != -1) {
    800066e0:	00179713          	sll	a4,a5,0x1
    800066e4:	97ba                	add	a5,a5,a4
    800066e6:	078e                	sll	a5,a5,0x3
    800066e8:	97d2                	add	a5,a5,s4
    800066ea:	1847a483          	lw	s1,388(a5)
    /* Go to out, since the remainder of this code is for the heap. */
    goto out;

heap_handle:
    /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages >= MAXRESHEAP) {
    800066ee:	6799                	lui	a5,0x6
    800066f0:	97d2                	add	a5,a5,s4
    800066f2:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    800066f6:	06300793          	li	a5,99
    800066fa:	12e7cf63          	blt	a5,a4,80006838 <page_fault_handler+0x216>
        evict_page_to_disk(p);
    }

    /* 2.3: Map a heap page into the process' address space. (Hint: check growproc) */
    uint64 size, idx;
    uvmalloc(p->pagetable, faulting_addr, faulting_addr+PGSIZE, PTE_W);
    800066fe:	6a85                	lui	s5,0x1
    80006700:	9ace                	add	s5,s5,s3
    80006702:	4691                	li	a3,4
    80006704:	8656                	mv	a2,s5
    80006706:	85ce                	mv	a1,s3
    80006708:	050a3503          	ld	a0,80(s4)
    8000670c:	ffffb097          	auipc	ra,0xffffb
    80006710:	cf8080e7          	jalr	-776(ra) # 80001404 <uvmalloc>

    /* 2.4: Heap page was swapped to disk previously. We must load it from disk. */
    if (load_from_disk) {
    80006714:	57fd                	li	a5,-1
    80006716:	12f49763          	bne	s1,a5,80006844 <page_fault_handler+0x222>
        retrieve_page_from_disk(p, faulting_addr);
    }

    /* 2.4: Update the last load time and the loaded boolean for the loaded heap page in p->heap_tracker. */
    for(int i=0; i<MAXHEAP; i++) {
    8000671a:	4481                	li	s1,0
    8000671c:	3e800713          	li	a4,1000
        if(p->heap_tracker[i].addr == faulting_addr) {
    80006720:	00093783          	ld	a5,0(s2)
    80006724:	13378763          	beq	a5,s3,80006852 <page_fault_handler+0x230>
    for(int i=0; i<MAXHEAP; i++) {
    80006728:	2485                	addw	s1,s1,1
    8000672a:	0961                	add	s2,s2,24
    8000672c:	fee49ae3          	bne	s1,a4,80006720 <page_fault_handler+0xfe>
    80006730:	a289                	j	80006872 <page_fault_handler+0x250>
        end_op();
    80006732:	ffffe097          	auipc	ra,0xffffe
    80006736:	aa2080e7          	jalr	-1374(ra) # 800041d4 <end_op>
    ilock(ip);
    8000673a:	4501                	li	a0,0
    8000673c:	ffffd097          	auipc	ra,0xffffd
    80006740:	078080e7          	jalr	120(ra) # 800037b4 <ilock>
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80006744:	04000713          	li	a4,64
    80006748:	4681                	li	a3,0
    8000674a:	f7040613          	add	a2,s0,-144
    8000674e:	4581                	li	a1,0
    80006750:	4501                	li	a0,0
    80006752:	ffffd097          	auipc	ra,0xffffd
    80006756:	316080e7          	jalr	790(ra) # 80003a68 <readi>
    8000675a:	04000793          	li	a5,64
    8000675e:	12f51763          	bne	a0,a5,8000688c <page_fault_handler+0x26a>
    if(elf.magic != ELF_MAGIC)
    80006762:	f7042703          	lw	a4,-144(s0)
    80006766:	464c47b7          	lui	a5,0x464c4
    8000676a:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000676e:	10f71f63          	bne	a4,a5,8000688c <page_fault_handler+0x26a>
    80006772:	bf81                	j	800066c2 <page_fault_handler+0xa0>
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006774:	2a05                	addw	s4,s4,1
    80006776:	0384849b          	addw	s1,s1,56
    8000677a:	fa845783          	lhu	a5,-88(s0)
    8000677e:	0afa5763          	bge	s4,a5,8000682c <page_fault_handler+0x20a>
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80006782:	2481                	sext.w	s1,s1
    80006784:	03800713          	li	a4,56
    80006788:	86a6                	mv	a3,s1
    8000678a:	f3840613          	add	a2,s0,-200
    8000678e:	4581                	li	a1,0
    80006790:	854a                	mv	a0,s2
    80006792:	ffffd097          	auipc	ra,0xffffd
    80006796:	2d6080e7          	jalr	726(ra) # 80003a68 <readi>
    8000679a:	03800793          	li	a5,56
    8000679e:	10f51463          	bne	a0,a5,800068a6 <page_fault_handler+0x284>
        if(ph.type != ELF_PROG_LOAD)
    800067a2:	f3842783          	lw	a5,-200(s0)
    800067a6:	fd6797e3          	bne	a5,s6,80006774 <page_fault_handler+0x152>
        if(ph.memsz < ph.filesz)
    800067aa:	f6043783          	ld	a5,-160(s0)
    800067ae:	f5843703          	ld	a4,-168(s0)
    800067b2:	0ee7ea63          	bltu	a5,a4,800068a6 <page_fault_handler+0x284>
        if(ph.vaddr + ph.memsz < ph.vaddr)
    800067b6:	f4843703          	ld	a4,-184(s0)
    800067ba:	97ba                	add	a5,a5,a4
    800067bc:	0ee7e563          	bltu	a5,a4,800068a6 <page_fault_handler+0x284>
        if(ph.vaddr % PGSIZE != 0)
    800067c0:	017776b3          	and	a3,a4,s7
    800067c4:	e2ed                	bnez	a3,800068a6 <page_fault_handler+0x284>
        if((faulting_addr >= ph.vaddr) && (faulting_addr < (ph.vaddr + ph.memsz))){
    800067c6:	fae9e7e3          	bltu	s3,a4,80006774 <page_fault_handler+0x152>
    800067ca:	faf9f5e3          	bgeu	s3,a5,80006774 <page_fault_handler+0x152>
            allowed_size = ph.vaddr + ph.memsz - faulting_addr;
    800067ce:	413784b3          	sub	s1,a5,s3
            if (allowed_size < pagesize)
    800067d2:	6785                	lui	a5,0x1
    800067d4:	0097f363          	bgeu	a5,s1,800067da <page_fault_handler+0x1b8>
    800067d8:	6485                	lui	s1,0x1
            offset = faulting_addr - ph.vaddr + ph.off;
    800067da:	f4043a03          	ld	s4,-192(s0)
    800067de:	40ea0a33          	sub	s4,s4,a4
    800067e2:	9a4e                	add	s4,s4,s3
            uvmalloc(pagetable, faulting_addr, faulting_addr + pagesize, flags2perm(ph.flags));
    800067e4:	01348b33          	add	s6,s1,s3
    800067e8:	f3c42503          	lw	a0,-196(s0)
    800067ec:	ffffe097          	auipc	ra,0xffffe
    800067f0:	48e080e7          	jalr	1166(ra) # 80004c7a <flags2perm>
    800067f4:	86aa                	mv	a3,a0
    800067f6:	865a                	mv	a2,s6
    800067f8:	85ce                	mv	a1,s3
    800067fa:	8556                	mv	a0,s5
    800067fc:	ffffb097          	auipc	ra,0xffffb
    80006800:	c08080e7          	jalr	-1016(ra) # 80001404 <uvmalloc>
            loadseg(pagetable, faulting_addr, ip, offset, pagesize);
    80006804:	2481                	sext.w	s1,s1
    80006806:	8726                	mv	a4,s1
    80006808:	000a069b          	sext.w	a3,s4
    8000680c:	864a                	mv	a2,s2
    8000680e:	85ce                	mv	a1,s3
    80006810:	8556                	mv	a0,s5
    80006812:	ffffe097          	auipc	ra,0xffffe
    80006816:	482080e7          	jalr	1154(ra) # 80004c94 <loadseg>
            print_load_seg(faulting_addr, ph.off, pagesize);
    8000681a:	8626                	mv	a2,s1
    8000681c:	f4043583          	ld	a1,-192(s0)
    80006820:	854e                	mv	a0,s3
    80006822:	00000097          	auipc	ra,0x0
    80006826:	1a2080e7          	jalr	418(ra) # 800069c4 <print_load_seg>
            goto out;
    8000682a:	a08d                	j	8000688c <page_fault_handler+0x26a>
    iunlockput(ip);
    8000682c:	854a                	mv	a0,s2
    8000682e:	ffffd097          	auipc	ra,0xffffd
    80006832:	1e8080e7          	jalr	488(ra) # 80003a16 <iunlockput>
    goto out;
    80006836:	a899                	j	8000688c <page_fault_handler+0x26a>
        evict_page_to_disk(p);
    80006838:	8552                	mv	a0,s4
    8000683a:	00000097          	auipc	ra,0x0
    8000683e:	bcc080e7          	jalr	-1076(ra) # 80006406 <evict_page_to_disk>
    80006842:	bd75                	j	800066fe <page_fault_handler+0xdc>
        retrieve_page_from_disk(p, faulting_addr);
    80006844:	85ce                	mv	a1,s3
    80006846:	8552                	mv	a0,s4
    80006848:	00000097          	auipc	ra,0x0
    8000684c:	d00080e7          	jalr	-768(ra) # 80006548 <retrieve_page_from_disk>
    80006850:	b5e9                	j	8000671a <page_fault_handler+0xf8>
            p->heap_tracker[i].last_load_time = read_current_timestamp();
    80006852:	00000097          	auipc	ra,0x0
    80006856:	b44080e7          	jalr	-1212(ra) # 80006396 <read_current_timestamp>
    8000685a:	00149793          	sll	a5,s1,0x1
    8000685e:	00978733          	add	a4,a5,s1
    80006862:	070e                	sll	a4,a4,0x3
    80006864:	9752                	add	a4,a4,s4
    80006866:	16a73c23          	sd	a0,376(a4)
            p->heap_tracker[i].loaded = true;
    8000686a:	87ba                	mv	a5,a4
    8000686c:	4705                	li	a4,1
    8000686e:	18e78023          	sb	a4,384(a5) # 1180 <_entry-0x7fffee80>
    }
    
    

    /* Track that another heap page has been brought into memory. */
    p->resident_heap_pages++;
    80006872:	6799                	lui	a5,0x6
    80006874:	97d2                	add	a5,a5,s4
    80006876:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    8000687a:	2705                	addw	a4,a4,1
    8000687c:	f2e7a823          	sw	a4,-208(a5)

    // // CHECK!
    if (p->sz > faulting_addr + PGSIZE)
    80006880:	048a3783          	ld	a5,72(s4)
    80006884:	00fae463          	bltu	s5,a5,8000688c <page_fault_handler+0x26a>
        p->sz = p->sz;
    else{
        p->sz = faulting_addr + PGSIZE;
    80006888:	055a3423          	sd	s5,72(s4)
  asm volatile("sfence.vma zero, zero");
    8000688c:	12000073          	sfence.vma

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
    80006890:	60ae                	ld	ra,200(sp)
    80006892:	640e                	ld	s0,192(sp)
    80006894:	74ea                	ld	s1,184(sp)
    80006896:	794a                	ld	s2,176(sp)
    80006898:	79aa                	ld	s3,168(sp)
    8000689a:	7a0a                	ld	s4,160(sp)
    8000689c:	6aea                	ld	s5,152(sp)
    8000689e:	6b4a                	ld	s6,144(sp)
    800068a0:	6baa                	ld	s7,136(sp)
    800068a2:	6169                	add	sp,sp,208
    800068a4:	8082                	ret
        proc_freepagetable(pagetable, sz);
    800068a6:	4581                	li	a1,0
    800068a8:	8556                	mv	a0,s5
    800068aa:	ffffb097          	auipc	ra,0xffffb
    800068ae:	298080e7          	jalr	664(ra) # 80001b42 <proc_freepagetable>
    if(ip){
    800068b2:	fc090de3          	beqz	s2,8000688c <page_fault_handler+0x26a>
        iunlockput(ip);
    800068b6:	854a                	mv	a0,s2
    800068b8:	ffffd097          	auipc	ra,0xffffd
    800068bc:	15e080e7          	jalr	350(ra) # 80003a16 <iunlockput>
        end_op();
    800068c0:	ffffe097          	auipc	ra,0xffffe
    800068c4:	914080e7          	jalr	-1772(ra) # 800041d4 <end_op>
    800068c8:	b7d1                	j	8000688c <page_fault_handler+0x26a>

00000000800068ca <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    800068ca:	1141                	add	sp,sp,-16
    800068cc:	e406                	sd	ra,8(sp)
    800068ce:	e022                	sd	s0,0(sp)
    800068d0:	0800                	add	s0,sp,16
    800068d2:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    800068d4:	00002517          	auipc	a0,0x2
    800068d8:	fa450513          	add	a0,a0,-92 # 80008878 <syscalls+0x3f0>
    800068dc:	ffffa097          	auipc	ra,0xffffa
    800068e0:	caa080e7          	jalr	-854(ra) # 80000586 <printf>
}
    800068e4:	60a2                	ld	ra,8(sp)
    800068e6:	6402                	ld	s0,0(sp)
    800068e8:	0141                	add	sp,sp,16
    800068ea:	8082                	ret

00000000800068ec <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    800068ec:	1141                	add	sp,sp,-16
    800068ee:	e406                	sd	ra,8(sp)
    800068f0:	e022                	sd	s0,0(sp)
    800068f2:	0800                	add	s0,sp,16
    800068f4:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    800068f6:	00002517          	auipc	a0,0x2
    800068fa:	faa50513          	add	a0,a0,-86 # 800088a0 <syscalls+0x418>
    800068fe:	ffffa097          	auipc	ra,0xffffa
    80006902:	c88080e7          	jalr	-888(ra) # 80000586 <printf>
}
    80006906:	60a2                	ld	ra,8(sp)
    80006908:	6402                	ld	s0,0(sp)
    8000690a:	0141                	add	sp,sp,16
    8000690c:	8082                	ret

000000008000690e <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    8000690e:	1141                	add	sp,sp,-16
    80006910:	e406                	sd	ra,8(sp)
    80006912:	e022                	sd	s0,0(sp)
    80006914:	0800                	add	s0,sp,16
    80006916:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    80006918:	862e                	mv	a2,a1
    8000691a:	85aa                	mv	a1,a0
    8000691c:	00002517          	auipc	a0,0x2
    80006920:	fac50513          	add	a0,a0,-84 # 800088c8 <syscalls+0x440>
    80006924:	ffffa097          	auipc	ra,0xffffa
    80006928:	c62080e7          	jalr	-926(ra) # 80000586 <printf>
        name, vaddr, size);
}
    8000692c:	60a2                	ld	ra,8(sp)
    8000692e:	6402                	ld	s0,0(sp)
    80006930:	0141                	add	sp,sp,16
    80006932:	8082                	ret

0000000080006934 <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    80006934:	1101                	add	sp,sp,-32
    80006936:	ec06                	sd	ra,24(sp)
    80006938:	e822                	sd	s0,16(sp)
    8000693a:	e426                	sd	s1,8(sp)
    8000693c:	e04a                	sd	s2,0(sp)
    8000693e:	1000                	add	s0,sp,32
    80006940:	84aa                	mv	s1,a0
    80006942:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    80006944:	00002517          	auipc	a0,0x2
    80006948:	fcc50513          	add	a0,a0,-52 # 80008910 <syscalls+0x488>
    8000694c:	ffffa097          	auipc	ra,0xffffa
    80006950:	c3a080e7          	jalr	-966(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    80006954:	864a                	mv	a2,s2
    80006956:	85a6                	mv	a1,s1
    80006958:	00002517          	auipc	a0,0x2
    8000695c:	fe850513          	add	a0,a0,-24 # 80008940 <syscalls+0x4b8>
    80006960:	ffffa097          	auipc	ra,0xffffa
    80006964:	c26080e7          	jalr	-986(ra) # 80000586 <printf>
}
    80006968:	60e2                	ld	ra,24(sp)
    8000696a:	6442                	ld	s0,16(sp)
    8000696c:	64a2                	ld	s1,8(sp)
    8000696e:	6902                	ld	s2,0(sp)
    80006970:	6105                	add	sp,sp,32
    80006972:	8082                	ret

0000000080006974 <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    80006974:	1141                	add	sp,sp,-16
    80006976:	e406                	sd	ra,8(sp)
    80006978:	e022                	sd	s0,0(sp)
    8000697a:	0800                	add	s0,sp,16
    8000697c:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    8000697e:	0035869b          	addw	a3,a1,3
    80006982:	85aa                	mv	a1,a0
    80006984:	00002517          	auipc	a0,0x2
    80006988:	fdc50513          	add	a0,a0,-36 # 80008960 <syscalls+0x4d8>
    8000698c:	ffffa097          	auipc	ra,0xffffa
    80006990:	bfa080e7          	jalr	-1030(ra) # 80000586 <printf>
}
    80006994:	60a2                	ld	ra,8(sp)
    80006996:	6402                	ld	s0,0(sp)
    80006998:	0141                	add	sp,sp,16
    8000699a:	8082                	ret

000000008000699c <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    8000699c:	1141                	add	sp,sp,-16
    8000699e:	e406                	sd	ra,8(sp)
    800069a0:	e022                	sd	s0,0(sp)
    800069a2:	0800                	add	s0,sp,16
    800069a4:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    800069a6:	0035869b          	addw	a3,a1,3
    800069aa:	85aa                	mv	a1,a0
    800069ac:	00002517          	auipc	a0,0x2
    800069b0:	fdc50513          	add	a0,a0,-36 # 80008988 <syscalls+0x500>
    800069b4:	ffffa097          	auipc	ra,0xffffa
    800069b8:	bd2080e7          	jalr	-1070(ra) # 80000586 <printf>
}
    800069bc:	60a2                	ld	ra,8(sp)
    800069be:	6402                	ld	s0,0(sp)
    800069c0:	0141                	add	sp,sp,16
    800069c2:	8082                	ret

00000000800069c4 <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    800069c4:	1141                	add	sp,sp,-16
    800069c6:	e406                	sd	ra,8(sp)
    800069c8:	e022                	sd	s0,0(sp)
    800069ca:	0800                	add	s0,sp,16
    800069cc:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    800069ce:	862e                	mv	a2,a1
    800069d0:	85aa                	mv	a1,a0
    800069d2:	00002517          	auipc	a0,0x2
    800069d6:	fde50513          	add	a0,a0,-34 # 800089b0 <syscalls+0x528>
    800069da:	ffffa097          	auipc	ra,0xffffa
    800069de:	bac080e7          	jalr	-1108(ra) # 80000586 <printf>
}
    800069e2:	60a2                	ld	ra,8(sp)
    800069e4:	6402                	ld	s0,0(sp)
    800069e6:	0141                	add	sp,sp,16
    800069e8:	8082                	ret

00000000800069ea <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    800069ea:	1141                	add	sp,sp,-16
    800069ec:	e406                	sd	ra,8(sp)
    800069ee:	e022                	sd	s0,0(sp)
    800069f0:	0800                	add	s0,sp,16
    800069f2:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    800069f4:	862e                	mv	a2,a1
    800069f6:	85aa                	mv	a1,a0
    800069f8:	00002517          	auipc	a0,0x2
    800069fc:	fe050513          	add	a0,a0,-32 # 800089d8 <syscalls+0x550>
    80006a00:	ffffa097          	auipc	ra,0xffffa
    80006a04:	b86080e7          	jalr	-1146(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    80006a08:	60a2                	ld	ra,8(sp)
    80006a0a:	6402                	ld	s0,0(sp)
    80006a0c:	0141                	add	sp,sp,16
    80006a0e:	8082                	ret
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
