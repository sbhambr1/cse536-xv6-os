
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	c1010113          	add	sp,sp,-1008 # 80008c10 <stack0>
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
    80000054:	a8070713          	add	a4,a4,-1408 # 80008ad0 <timer_scratch>
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
    80000066:	c7e78793          	add	a5,a5,-898 # 80005ce0 <timervec>
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
    8000009a:	7ff70713          	add	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7fe650cf>
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
    8000012e:	44a080e7          	jalr	1098(ra) # 80002574 <either_copyin>
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
    80000188:	a8c50513          	add	a0,a0,-1396 # 80010c10 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	a7c48493          	add	s1,s1,-1412 # 80010c10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	b0c90913          	add	s2,s2,-1268 # 80010ca8 <cons+0x98>
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
    800001c0:	206080e7          	jalr	518(ra) # 800023c2 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	f38080e7          	jalr	-200(ra) # 80002102 <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	a3270713          	add	a4,a4,-1486 # 80010c10 <cons>
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
    80000214:	30e080e7          	jalr	782(ra) # 8000251e <either_copyout>
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
    8000022c:	9e850513          	add	a0,a0,-1560 # 80010c10 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00011517          	auipc	a0,0x11
    80000242:	9d250513          	add	a0,a0,-1582 # 80010c10 <cons>
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
    80000272:	a2f72d23          	sw	a5,-1478(a4) # 80010ca8 <cons+0x98>
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
    800002cc:	94850513          	add	a0,a0,-1720 # 80010c10 <cons>
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
    800002f2:	2dc080e7          	jalr	732(ra) # 800025ca <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00011517          	auipc	a0,0x11
    800002fa:	91a50513          	add	a0,a0,-1766 # 80010c10 <cons>
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
    8000031e:	8f670713          	add	a4,a4,-1802 # 80010c10 <cons>
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
    80000348:	8cc78793          	add	a5,a5,-1844 # 80010c10 <cons>
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
    80000376:	9367a783          	lw	a5,-1738(a5) # 80010ca8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00011717          	auipc	a4,0x11
    8000038a:	88a70713          	add	a4,a4,-1910 # 80010c10 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00011497          	auipc	s1,0x11
    8000039a:	87a48493          	add	s1,s1,-1926 # 80010c10 <cons>
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
    800003d6:	83e70713          	add	a4,a4,-1986 # 80010c10 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addw	a5,a5,-1
    800003e8:	00011717          	auipc	a4,0x11
    800003ec:	8cf72423          	sw	a5,-1848(a4) # 80010cb0 <cons+0xa0>
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
    80000412:	80278793          	add	a5,a5,-2046 # 80010c10 <cons>
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
    80000436:	86c7ad23          	sw	a2,-1926(a5) # 80010cac <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00011517          	auipc	a0,0x11
    8000043e:	86e50513          	add	a0,a0,-1938 # 80010ca8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	d24080e7          	jalr	-732(ra) # 80002166 <wakeup>
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
    80000460:	7b450513          	add	a0,a0,1972 # 80010c10 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00198797          	auipc	a5,0x198
    80000478:	d3c78793          	add	a5,a5,-708 # 801981b0 <devsw>
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
    8000054c:	7807a423          	sw	zero,1928(a5) # 80010cd0 <pr+0x18>
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
    8000056e:	4c650513          	add	a0,a0,1222 # 80008a30 <syscalls+0x5a0>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	50f72a23          	sw	a5,1300(a4) # 80008a90 <panicked>
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
    800005bc:	718dad83          	lw	s11,1816(s11) # 80010cd0 <pr+0x18>
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
    800005fa:	6c250513          	add	a0,a0,1730 # 80010cb8 <pr>
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
    80000758:	56450513          	add	a0,a0,1380 # 80010cb8 <pr>
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
    80000774:	54848493          	add	s1,s1,1352 # 80010cb8 <pr>
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
    800007d4:	50850513          	add	a0,a0,1288 # 80010cd8 <uart_tx_lock>
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
    80000800:	2947a783          	lw	a5,660(a5) # 80008a90 <panicked>
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
    80000838:	2647b783          	ld	a5,612(a5) # 80008a98 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	26473703          	ld	a4,612(a4) # 80008aa0 <uart_tx_w>
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
    80000862:	47aa0a13          	add	s4,s4,1146 # 80010cd8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	23248493          	add	s1,s1,562 # 80008a98 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	23298993          	add	s3,s3,562 # 80008aa0 <uart_tx_w>
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
    80000894:	8d6080e7          	jalr	-1834(ra) # 80002166 <wakeup>
    
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
    800008d0:	40c50513          	add	a0,a0,1036 # 80010cd8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	1b47a783          	lw	a5,436(a5) # 80008a90 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	1ba73703          	ld	a4,442(a4) # 80008aa0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	1aa7b783          	ld	a5,426(a5) # 80008a98 <uart_tx_r>
    800008f6:	02078793          	add	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	3de98993          	add	s3,s3,990 # 80010cd8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	19648493          	add	s1,s1,406 # 80008a98 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	19690913          	add	s2,s2,406 # 80008aa0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	7e8080e7          	jalr	2024(ra) # 80002102 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	add	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	3a848493          	add	s1,s1,936 # 80010cd8 <uart_tx_lock>
    80000938:	01f77793          	and	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	add	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	14e7be23          	sd	a4,348(a5) # 80008aa0 <uart_tx_w>
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
    800009ba:	32248493          	add	s1,s1,802 # 80010cd8 <uart_tx_lock>
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
    800009fc:	d3878793          	add	a5,a5,-712 # 80199730 <end>
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
    80000a1c:	2f890913          	add	s2,s2,760 # 80010d10 <kmem>
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
    80000aba:	25a50513          	add	a0,a0,602 # 80010d10 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	sll	a1,a1,0x1b
    80000aca:	00199517          	auipc	a0,0x199
    80000ace:	c6650513          	add	a0,a0,-922 # 80199730 <end>
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
    80000af0:	22448493          	add	s1,s1,548 # 80010d10 <kmem>
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
    80000b08:	20c50513          	add	a0,a0,524 # 80010d10 <kmem>
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
    80000b34:	1e050513          	add	a0,a0,480 # 80010d10 <kmem>
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
    80000d42:	0705                	add	a4,a4,1 # fffffffffffff001 <end+0xffffffff7fe658d1>
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
    80000e86:	c2670713          	add	a4,a4,-986 # 80008aa8 <started>
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
    80000ebc:	85c080e7          	jalr	-1956(ra) # 80002714 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	e60080e7          	jalr	-416(ra) # 80005d20 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	082080e7          	jalr	130(ra) # 80001f4a <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00008517          	auipc	a0,0x8
    80000ee4:	b5050513          	add	a0,a0,-1200 # 80008a30 <syscalls+0x5a0>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	add	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00008517          	auipc	a0,0x8
    80000f04:	b3050513          	add	a0,a0,-1232 # 80008a30 <syscalls+0x5a0>
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
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	7bc080e7          	jalr	1980(ra) # 800026ec <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	7dc080e7          	jalr	2012(ra) # 80002714 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	dca080e7          	jalr	-566(ra) # 80005d0a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	dd8080e7          	jalr	-552(ra) # 80005d20 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	f50080e7          	jalr	-176(ra) # 80002ea0 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	5ee080e7          	jalr	1518(ra) # 80003546 <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	564080e7          	jalr	1380(ra) # 800044c4 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	ec0080e7          	jalr	-320(ra) # 80005e28 <virtio_disk_init>
    init_psa_regions();
    80000f70:	00005097          	auipc	ra,0x5
    80000f74:	3d0080e7          	jalr	976(ra) # 80006340 <init_psa_regions>
    userinit();      // first user process
    80000f78:	00001097          	auipc	ra,0x1
    80000f7c:	d5e080e7          	jalr	-674(ra) # 80001cd6 <userinit>
    __sync_synchronize();
    80000f80:	0ff0000f          	fence
    started = 1;
    80000f84:	4785                	li	a5,1
    80000f86:	00008717          	auipc	a4,0x8
    80000f8a:	b2f72123          	sw	a5,-1246(a4) # 80008aa8 <started>
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
    80000f9e:	b167b783          	ld	a5,-1258(a5) # 80008ab0 <kernel_pagetable>
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
    80001018:	3a5d                	addw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7fe658c7>
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
    8000125a:	84a7bd23          	sd	a0,-1958(a5) # 80008ab0 <kernel_pagetable>
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
    80001844:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7fe658d0>
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
    8000188c:	8d848493          	add	s1,s1,-1832 # 80011160 <proc>
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
    800018ac:	6b8a8a93          	add	s5,s5,1720 # 8018df60 <tickslock>
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
    80001930:	40450513          	add	a0,a0,1028 # 80010d30 <pid_lock>
    80001934:	fffff097          	auipc	ra,0xfffff
    80001938:	20e080e7          	jalr	526(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    8000193c:	00007597          	auipc	a1,0x7
    80001940:	8bc58593          	add	a1,a1,-1860 # 800081f8 <digits+0x1b8>
    80001944:	0000f517          	auipc	a0,0xf
    80001948:	40450513          	add	a0,a0,1028 # 80010d48 <wait_lock>
    8000194c:	fffff097          	auipc	ra,0xfffff
    80001950:	1f6080e7          	jalr	502(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001954:	00010497          	auipc	s1,0x10
    80001958:	80c48493          	add	s1,s1,-2036 # 80011160 <proc>
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
    80001980:	5e4a0a13          	add	s4,s4,1508 # 8018df60 <tickslock>
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
    800019ea:	37a50513          	add	a0,a0,890 # 80010d60 <cpus>
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
    80001a12:	32270713          	add	a4,a4,802 # 80010d30 <pid_lock>
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
    80001a4a:	ffa7a783          	lw	a5,-6(a5) # 80008a40 <first.1>
    80001a4e:	eb89                	bnez	a5,80001a60 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a50:	00001097          	auipc	ra,0x1
    80001a54:	cdc080e7          	jalr	-804(ra) # 8000272c <usertrapret>
}
    80001a58:	60a2                	ld	ra,8(sp)
    80001a5a:	6402                	ld	s0,0(sp)
    80001a5c:	0141                	add	sp,sp,16
    80001a5e:	8082                	ret
    first = 0;
    80001a60:	00007797          	auipc	a5,0x7
    80001a64:	fe07a023          	sw	zero,-32(a5) # 80008a40 <first.1>
    fsinit(ROOTDEV);
    80001a68:	4505                	li	a0,1
    80001a6a:	00002097          	auipc	ra,0x2
    80001a6e:	a5c080e7          	jalr	-1444(ra) # 800034c6 <fsinit>
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
    80001a84:	2b090913          	add	s2,s2,688 # 80010d30 <pid_lock>
    80001a88:	854a                	mv	a0,s2
    80001a8a:	fffff097          	auipc	ra,0xfffff
    80001a8e:	148080e7          	jalr	328(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a92:	00007797          	auipc	a5,0x7
    80001a96:	fb278793          	add	a5,a5,-78 # 80008a44 <nextpid>
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
    80001c12:	55248493          	add	s1,s1,1362 # 80011160 <proc>
    80001c16:	6919                	lui	s2,0x6
    80001c18:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    80001c1c:	0018c997          	auipc	s3,0x18c
    80001c20:	34498993          	add	s3,s3,836 # 8018df60 <tickslock>
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
    80001cee:	dca7b723          	sd	a0,-562(a5) # 80008ab8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001cf2:	03400613          	li	a2,52
    80001cf6:	00007597          	auipc	a1,0x7
    80001cfa:	d5a58593          	add	a1,a1,-678 # 80008a50 <initcode>
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
    80001d38:	1b0080e7          	jalr	432(ra) # 80003ee4 <namei>
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
    80001d9e:	1101                	add	sp,sp,-32
    80001da0:	ec06                	sd	ra,24(sp)
    80001da2:	e822                	sd	s0,16(sp)
    80001da4:	e426                	sd	s1,8(sp)
    80001da6:	e04a                	sd	s2,0(sp)
    80001da8:	1000                	add	s0,sp,32
    80001daa:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001dac:	00000097          	auipc	ra,0x0
    80001db0:	c4a080e7          	jalr	-950(ra) # 800019f6 <myproc>
    80001db4:	84aa                	mv	s1,a0
  n = PGROUNDUP(n);
    80001db6:	6605                	lui	a2,0x1
    80001db8:	367d                	addw	a2,a2,-1 # fff <_entry-0x7ffff001>
    80001dba:	0126063b          	addw	a2,a2,s2
    80001dbe:	77fd                	lui	a5,0xfffff
    80001dc0:	8e7d                	and	a2,a2,a5
  sz = p->sz;
    80001dc2:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001dc4:	00c04c63          	bgtz	a2,80001ddc <growproc+0x3e>
  } else if(n < 0){
    80001dc8:	02064563          	bltz	a2,80001df2 <growproc+0x54>
  p->sz = sz;
    80001dcc:	e4ac                	sd	a1,72(s1)
  return 0;
    80001dce:	4501                	li	a0,0
}
    80001dd0:	60e2                	ld	ra,24(sp)
    80001dd2:	6442                	ld	s0,16(sp)
    80001dd4:	64a2                	ld	s1,8(sp)
    80001dd6:	6902                	ld	s2,0(sp)
    80001dd8:	6105                	add	sp,sp,32
    80001dda:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001ddc:	4691                	li	a3,4
    80001dde:	962e                	add	a2,a2,a1
    80001de0:	6928                	ld	a0,80(a0)
    80001de2:	fffff097          	auipc	ra,0xfffff
    80001de6:	622080e7          	jalr	1570(ra) # 80001404 <uvmalloc>
    80001dea:	85aa                	mv	a1,a0
    80001dec:	f165                	bnez	a0,80001dcc <growproc+0x2e>
      return -1;
    80001dee:	557d                	li	a0,-1
    80001df0:	b7c5                	j	80001dd0 <growproc+0x32>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001df2:	962e                	add	a2,a2,a1
    80001df4:	6928                	ld	a0,80(a0)
    80001df6:	fffff097          	auipc	ra,0xfffff
    80001dfa:	5c6080e7          	jalr	1478(ra) # 800013bc <uvmdealloc>
    80001dfe:	85aa                	mv	a1,a0
    80001e00:	b7f1                	j	80001dcc <growproc+0x2e>

0000000080001e02 <fork>:
{
    80001e02:	7139                	add	sp,sp,-64
    80001e04:	fc06                	sd	ra,56(sp)
    80001e06:	f822                	sd	s0,48(sp)
    80001e08:	f426                	sd	s1,40(sp)
    80001e0a:	f04a                	sd	s2,32(sp)
    80001e0c:	ec4e                	sd	s3,24(sp)
    80001e0e:	e852                	sd	s4,16(sp)
    80001e10:	e456                	sd	s5,8(sp)
    80001e12:	0080                	add	s0,sp,64
  struct proc *p = myproc();
    80001e14:	00000097          	auipc	ra,0x0
    80001e18:	be2080e7          	jalr	-1054(ra) # 800019f6 <myproc>
    80001e1c:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001e1e:	00000097          	auipc	ra,0x0
    80001e22:	de2080e7          	jalr	-542(ra) # 80001c00 <allocproc>
    80001e26:	12050063          	beqz	a0,80001f46 <fork+0x144>
    80001e2a:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001e2c:	048ab603          	ld	a2,72(s5)
    80001e30:	692c                	ld	a1,80(a0)
    80001e32:	050ab503          	ld	a0,80(s5)
    80001e36:	fffff097          	auipc	ra,0xfffff
    80001e3a:	73a080e7          	jalr	1850(ra) # 80001570 <uvmcopy>
    80001e3e:	04054863          	bltz	a0,80001e8e <fork+0x8c>
  np->sz = p->sz;
    80001e42:	048ab783          	ld	a5,72(s5)
    80001e46:	04f9b423          	sd	a5,72(s3)
  *(np->trapframe) = *(p->trapframe);
    80001e4a:	058ab683          	ld	a3,88(s5)
    80001e4e:	87b6                	mv	a5,a3
    80001e50:	0589b703          	ld	a4,88(s3)
    80001e54:	12068693          	add	a3,a3,288
    80001e58:	0007b803          	ld	a6,0(a5) # fffffffffffff000 <end+0xffffffff7fe658d0>
    80001e5c:	6788                	ld	a0,8(a5)
    80001e5e:	6b8c                	ld	a1,16(a5)
    80001e60:	6f90                	ld	a2,24(a5)
    80001e62:	01073023          	sd	a6,0(a4)
    80001e66:	e708                	sd	a0,8(a4)
    80001e68:	eb0c                	sd	a1,16(a4)
    80001e6a:	ef10                	sd	a2,24(a4)
    80001e6c:	02078793          	add	a5,a5,32
    80001e70:	02070713          	add	a4,a4,32
    80001e74:	fed792e3          	bne	a5,a3,80001e58 <fork+0x56>
  np->trapframe->a0 = 0;
    80001e78:	0589b783          	ld	a5,88(s3)
    80001e7c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001e80:	0d0a8493          	add	s1,s5,208
    80001e84:	0d098913          	add	s2,s3,208
    80001e88:	150a8a13          	add	s4,s5,336
    80001e8c:	a00d                	j	80001eae <fork+0xac>
    freeproc(np);
    80001e8e:	854e                	mv	a0,s3
    80001e90:	00000097          	auipc	ra,0x0
    80001e94:	d18080e7          	jalr	-744(ra) # 80001ba8 <freeproc>
    release(&np->lock);
    80001e98:	854e                	mv	a0,s3
    80001e9a:	fffff097          	auipc	ra,0xfffff
    80001e9e:	dec080e7          	jalr	-532(ra) # 80000c86 <release>
    return -1;
    80001ea2:	597d                	li	s2,-1
    80001ea4:	a079                	j	80001f32 <fork+0x130>
  for(i = 0; i < NOFILE; i++)
    80001ea6:	04a1                	add	s1,s1,8
    80001ea8:	0921                	add	s2,s2,8
    80001eaa:	01448b63          	beq	s1,s4,80001ec0 <fork+0xbe>
    if(p->ofile[i])
    80001eae:	6088                	ld	a0,0(s1)
    80001eb0:	d97d                	beqz	a0,80001ea6 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001eb2:	00002097          	auipc	ra,0x2
    80001eb6:	6a4080e7          	jalr	1700(ra) # 80004556 <filedup>
    80001eba:	00a93023          	sd	a0,0(s2)
    80001ebe:	b7e5                	j	80001ea6 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001ec0:	150ab503          	ld	a0,336(s5)
    80001ec4:	00002097          	auipc	ra,0x2
    80001ec8:	83c080e7          	jalr	-1988(ra) # 80003700 <idup>
    80001ecc:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ed0:	4641                	li	a2,16
    80001ed2:	158a8593          	add	a1,s5,344
    80001ed6:	15898513          	add	a0,s3,344
    80001eda:	fffff097          	auipc	ra,0xfffff
    80001ede:	f3c080e7          	jalr	-196(ra) # 80000e16 <safestrcpy>
  np->ondemand = p->ondemand;
    80001ee2:	168ac783          	lbu	a5,360(s5)
    80001ee6:	16f98423          	sb	a5,360(s3)
  pid = np->pid;
    80001eea:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001eee:	854e                	mv	a0,s3
    80001ef0:	fffff097          	auipc	ra,0xfffff
    80001ef4:	d96080e7          	jalr	-618(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001ef8:	0000f497          	auipc	s1,0xf
    80001efc:	e5048493          	add	s1,s1,-432 # 80010d48 <wait_lock>
    80001f00:	8526                	mv	a0,s1
    80001f02:	fffff097          	auipc	ra,0xfffff
    80001f06:	cd0080e7          	jalr	-816(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001f0a:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001f0e:	8526                	mv	a0,s1
    80001f10:	fffff097          	auipc	ra,0xfffff
    80001f14:	d76080e7          	jalr	-650(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001f18:	854e                	mv	a0,s3
    80001f1a:	fffff097          	auipc	ra,0xfffff
    80001f1e:	cb8080e7          	jalr	-840(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001f22:	478d                	li	a5,3
    80001f24:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001f28:	854e                	mv	a0,s3
    80001f2a:	fffff097          	auipc	ra,0xfffff
    80001f2e:	d5c080e7          	jalr	-676(ra) # 80000c86 <release>
}
    80001f32:	854a                	mv	a0,s2
    80001f34:	70e2                	ld	ra,56(sp)
    80001f36:	7442                	ld	s0,48(sp)
    80001f38:	74a2                	ld	s1,40(sp)
    80001f3a:	7902                	ld	s2,32(sp)
    80001f3c:	69e2                	ld	s3,24(sp)
    80001f3e:	6a42                	ld	s4,16(sp)
    80001f40:	6aa2                	ld	s5,8(sp)
    80001f42:	6121                	add	sp,sp,64
    80001f44:	8082                	ret
    return -1;
    80001f46:	597d                	li	s2,-1
    80001f48:	b7ed                	j	80001f32 <fork+0x130>

0000000080001f4a <scheduler>:
{
    80001f4a:	715d                	add	sp,sp,-80
    80001f4c:	e486                	sd	ra,72(sp)
    80001f4e:	e0a2                	sd	s0,64(sp)
    80001f50:	fc26                	sd	s1,56(sp)
    80001f52:	f84a                	sd	s2,48(sp)
    80001f54:	f44e                	sd	s3,40(sp)
    80001f56:	f052                	sd	s4,32(sp)
    80001f58:	ec56                	sd	s5,24(sp)
    80001f5a:	e85a                	sd	s6,16(sp)
    80001f5c:	e45e                	sd	s7,8(sp)
    80001f5e:	0880                	add	s0,sp,80
    80001f60:	8792                	mv	a5,tp
  int id = r_tp();
    80001f62:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001f64:	00779b13          	sll	s6,a5,0x7
    80001f68:	0000f717          	auipc	a4,0xf
    80001f6c:	dc870713          	add	a4,a4,-568 # 80010d30 <pid_lock>
    80001f70:	975a                	add	a4,a4,s6
    80001f72:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001f76:	0000f717          	auipc	a4,0xf
    80001f7a:	df270713          	add	a4,a4,-526 # 80010d68 <cpus+0x8>
    80001f7e:	9b3a                	add	s6,s6,a4
        p->state = RUNNING;
    80001f80:	4b91                	li	s7,4
        c->proc = p;
    80001f82:	079e                	sll	a5,a5,0x7
    80001f84:	0000fa97          	auipc	s5,0xf
    80001f88:	daca8a93          	add	s5,s5,-596 # 80010d30 <pid_lock>
    80001f8c:	9abe                	add	s5,s5,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f8e:	6999                	lui	s3,0x6
    80001f90:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80001f94:	0018ca17          	auipc	s4,0x18c
    80001f98:	fcca0a13          	add	s4,s4,-52 # 8018df60 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f9c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001fa0:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001fa4:	10079073          	csrw	sstatus,a5
    80001fa8:	0000f497          	auipc	s1,0xf
    80001fac:	1b848493          	add	s1,s1,440 # 80011160 <proc>
      if(p->state == RUNNABLE) {
    80001fb0:	490d                	li	s2,3
    80001fb2:	a809                	j	80001fc4 <scheduler+0x7a>
      release(&p->lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	cd0080e7          	jalr	-816(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001fbe:	94ce                	add	s1,s1,s3
    80001fc0:	fd448ee3          	beq	s1,s4,80001f9c <scheduler+0x52>
      acquire(&p->lock);
    80001fc4:	8526                	mv	a0,s1
    80001fc6:	fffff097          	auipc	ra,0xfffff
    80001fca:	c0c080e7          	jalr	-1012(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001fce:	4c9c                	lw	a5,24(s1)
    80001fd0:	ff2792e3          	bne	a5,s2,80001fb4 <scheduler+0x6a>
        p->state = RUNNING;
    80001fd4:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    80001fd8:	029ab823          	sd	s1,48(s5)
        swtch(&c->context, &p->context);
    80001fdc:	06048593          	add	a1,s1,96
    80001fe0:	855a                	mv	a0,s6
    80001fe2:	00000097          	auipc	ra,0x0
    80001fe6:	6a0080e7          	jalr	1696(ra) # 80002682 <swtch>
        c->proc = 0;
    80001fea:	020ab823          	sd	zero,48(s5)
    80001fee:	b7d9                	j	80001fb4 <scheduler+0x6a>

0000000080001ff0 <sched>:
{
    80001ff0:	7179                	add	sp,sp,-48
    80001ff2:	f406                	sd	ra,40(sp)
    80001ff4:	f022                	sd	s0,32(sp)
    80001ff6:	ec26                	sd	s1,24(sp)
    80001ff8:	e84a                	sd	s2,16(sp)
    80001ffa:	e44e                	sd	s3,8(sp)
    80001ffc:	1800                	add	s0,sp,48
  struct proc *p = myproc();
    80001ffe:	00000097          	auipc	ra,0x0
    80002002:	9f8080e7          	jalr	-1544(ra) # 800019f6 <myproc>
    80002006:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80002008:	fffff097          	auipc	ra,0xfffff
    8000200c:	b50080e7          	jalr	-1200(ra) # 80000b58 <holding>
    80002010:	c93d                	beqz	a0,80002086 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80002012:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80002014:	2781                	sext.w	a5,a5
    80002016:	079e                	sll	a5,a5,0x7
    80002018:	0000f717          	auipc	a4,0xf
    8000201c:	d1870713          	add	a4,a4,-744 # 80010d30 <pid_lock>
    80002020:	97ba                	add	a5,a5,a4
    80002022:	0a87a703          	lw	a4,168(a5)
    80002026:	4785                	li	a5,1
    80002028:	06f71763          	bne	a4,a5,80002096 <sched+0xa6>
  if(p->state == RUNNING)
    8000202c:	4c98                	lw	a4,24(s1)
    8000202e:	4791                	li	a5,4
    80002030:	06f70b63          	beq	a4,a5,800020a6 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002034:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002038:	8b89                	and	a5,a5,2
  if(intr_get())
    8000203a:	efb5                	bnez	a5,800020b6 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000203c:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000203e:	0000f917          	auipc	s2,0xf
    80002042:	cf290913          	add	s2,s2,-782 # 80010d30 <pid_lock>
    80002046:	2781                	sext.w	a5,a5
    80002048:	079e                	sll	a5,a5,0x7
    8000204a:	97ca                	add	a5,a5,s2
    8000204c:	0ac7a983          	lw	s3,172(a5)
    80002050:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80002052:	2781                	sext.w	a5,a5
    80002054:	079e                	sll	a5,a5,0x7
    80002056:	0000f597          	auipc	a1,0xf
    8000205a:	d1258593          	add	a1,a1,-750 # 80010d68 <cpus+0x8>
    8000205e:	95be                	add	a1,a1,a5
    80002060:	06048513          	add	a0,s1,96
    80002064:	00000097          	auipc	ra,0x0
    80002068:	61e080e7          	jalr	1566(ra) # 80002682 <swtch>
    8000206c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000206e:	2781                	sext.w	a5,a5
    80002070:	079e                	sll	a5,a5,0x7
    80002072:	993e                	add	s2,s2,a5
    80002074:	0b392623          	sw	s3,172(s2)
}
    80002078:	70a2                	ld	ra,40(sp)
    8000207a:	7402                	ld	s0,32(sp)
    8000207c:	64e2                	ld	s1,24(sp)
    8000207e:	6942                	ld	s2,16(sp)
    80002080:	69a2                	ld	s3,8(sp)
    80002082:	6145                	add	sp,sp,48
    80002084:	8082                	ret
    panic("sched p->lock");
    80002086:	00006517          	auipc	a0,0x6
    8000208a:	1d250513          	add	a0,a0,466 # 80008258 <digits+0x218>
    8000208e:	ffffe097          	auipc	ra,0xffffe
    80002092:	4ae080e7          	jalr	1198(ra) # 8000053c <panic>
    panic("sched locks");
    80002096:	00006517          	auipc	a0,0x6
    8000209a:	1d250513          	add	a0,a0,466 # 80008268 <digits+0x228>
    8000209e:	ffffe097          	auipc	ra,0xffffe
    800020a2:	49e080e7          	jalr	1182(ra) # 8000053c <panic>
    panic("sched running");
    800020a6:	00006517          	auipc	a0,0x6
    800020aa:	1d250513          	add	a0,a0,466 # 80008278 <digits+0x238>
    800020ae:	ffffe097          	auipc	ra,0xffffe
    800020b2:	48e080e7          	jalr	1166(ra) # 8000053c <panic>
    panic("sched interruptible");
    800020b6:	00006517          	auipc	a0,0x6
    800020ba:	1d250513          	add	a0,a0,466 # 80008288 <digits+0x248>
    800020be:	ffffe097          	auipc	ra,0xffffe
    800020c2:	47e080e7          	jalr	1150(ra) # 8000053c <panic>

00000000800020c6 <yield>:
{
    800020c6:	1101                	add	sp,sp,-32
    800020c8:	ec06                	sd	ra,24(sp)
    800020ca:	e822                	sd	s0,16(sp)
    800020cc:	e426                	sd	s1,8(sp)
    800020ce:	1000                	add	s0,sp,32
  struct proc *p = myproc();
    800020d0:	00000097          	auipc	ra,0x0
    800020d4:	926080e7          	jalr	-1754(ra) # 800019f6 <myproc>
    800020d8:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800020da:	fffff097          	auipc	ra,0xfffff
    800020de:	af8080e7          	jalr	-1288(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    800020e2:	478d                	li	a5,3
    800020e4:	cc9c                	sw	a5,24(s1)
  sched();
    800020e6:	00000097          	auipc	ra,0x0
    800020ea:	f0a080e7          	jalr	-246(ra) # 80001ff0 <sched>
  release(&p->lock);
    800020ee:	8526                	mv	a0,s1
    800020f0:	fffff097          	auipc	ra,0xfffff
    800020f4:	b96080e7          	jalr	-1130(ra) # 80000c86 <release>
}
    800020f8:	60e2                	ld	ra,24(sp)
    800020fa:	6442                	ld	s0,16(sp)
    800020fc:	64a2                	ld	s1,8(sp)
    800020fe:	6105                	add	sp,sp,32
    80002100:	8082                	ret

0000000080002102 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80002102:	7179                	add	sp,sp,-48
    80002104:	f406                	sd	ra,40(sp)
    80002106:	f022                	sd	s0,32(sp)
    80002108:	ec26                	sd	s1,24(sp)
    8000210a:	e84a                	sd	s2,16(sp)
    8000210c:	e44e                	sd	s3,8(sp)
    8000210e:	1800                	add	s0,sp,48
    80002110:	89aa                	mv	s3,a0
    80002112:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002114:	00000097          	auipc	ra,0x0
    80002118:	8e2080e7          	jalr	-1822(ra) # 800019f6 <myproc>
    8000211c:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000211e:	fffff097          	auipc	ra,0xfffff
    80002122:	ab4080e7          	jalr	-1356(ra) # 80000bd2 <acquire>
  release(lk);
    80002126:	854a                	mv	a0,s2
    80002128:	fffff097          	auipc	ra,0xfffff
    8000212c:	b5e080e7          	jalr	-1186(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    80002130:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002134:	4789                	li	a5,2
    80002136:	cc9c                	sw	a5,24(s1)

  /* Adil: sleeping. */
  // printf("Sleeping and yielding CPU.");

  sched();
    80002138:	00000097          	auipc	ra,0x0
    8000213c:	eb8080e7          	jalr	-328(ra) # 80001ff0 <sched>

  // Tidy up.
  p->chan = 0;
    80002140:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002144:	8526                	mv	a0,s1
    80002146:	fffff097          	auipc	ra,0xfffff
    8000214a:	b40080e7          	jalr	-1216(ra) # 80000c86 <release>
  acquire(lk);
    8000214e:	854a                	mv	a0,s2
    80002150:	fffff097          	auipc	ra,0xfffff
    80002154:	a82080e7          	jalr	-1406(ra) # 80000bd2 <acquire>
}
    80002158:	70a2                	ld	ra,40(sp)
    8000215a:	7402                	ld	s0,32(sp)
    8000215c:	64e2                	ld	s1,24(sp)
    8000215e:	6942                	ld	s2,16(sp)
    80002160:	69a2                	ld	s3,8(sp)
    80002162:	6145                	add	sp,sp,48
    80002164:	8082                	ret

0000000080002166 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002166:	7139                	add	sp,sp,-64
    80002168:	fc06                	sd	ra,56(sp)
    8000216a:	f822                	sd	s0,48(sp)
    8000216c:	f426                	sd	s1,40(sp)
    8000216e:	f04a                	sd	s2,32(sp)
    80002170:	ec4e                	sd	s3,24(sp)
    80002172:	e852                	sd	s4,16(sp)
    80002174:	e456                	sd	s5,8(sp)
    80002176:	e05a                	sd	s6,0(sp)
    80002178:	0080                	add	s0,sp,64
    8000217a:	8aaa                	mv	s5,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000217c:	0000f497          	auipc	s1,0xf
    80002180:	fe448493          	add	s1,s1,-28 # 80011160 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002184:	4a09                	li	s4,2
        p->state = RUNNABLE;
    80002186:	4b0d                	li	s6,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002188:	6919                	lui	s2,0x6
    8000218a:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    8000218e:	0018c997          	auipc	s3,0x18c
    80002192:	dd298993          	add	s3,s3,-558 # 8018df60 <tickslock>
    80002196:	a809                	j	800021a8 <wakeup+0x42>
      }
      release(&p->lock);
    80002198:	8526                	mv	a0,s1
    8000219a:	fffff097          	auipc	ra,0xfffff
    8000219e:	aec080e7          	jalr	-1300(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800021a2:	94ca                	add	s1,s1,s2
    800021a4:	03348663          	beq	s1,s3,800021d0 <wakeup+0x6a>
    if(p != myproc()){
    800021a8:	00000097          	auipc	ra,0x0
    800021ac:	84e080e7          	jalr	-1970(ra) # 800019f6 <myproc>
    800021b0:	fea489e3          	beq	s1,a0,800021a2 <wakeup+0x3c>
      acquire(&p->lock);
    800021b4:	8526                	mv	a0,s1
    800021b6:	fffff097          	auipc	ra,0xfffff
    800021ba:	a1c080e7          	jalr	-1508(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    800021be:	4c9c                	lw	a5,24(s1)
    800021c0:	fd479ce3          	bne	a5,s4,80002198 <wakeup+0x32>
    800021c4:	709c                	ld	a5,32(s1)
    800021c6:	fd5799e3          	bne	a5,s5,80002198 <wakeup+0x32>
        p->state = RUNNABLE;
    800021ca:	0164ac23          	sw	s6,24(s1)
    800021ce:	b7e9                	j	80002198 <wakeup+0x32>
    }
  }
}
    800021d0:	70e2                	ld	ra,56(sp)
    800021d2:	7442                	ld	s0,48(sp)
    800021d4:	74a2                	ld	s1,40(sp)
    800021d6:	7902                	ld	s2,32(sp)
    800021d8:	69e2                	ld	s3,24(sp)
    800021da:	6a42                	ld	s4,16(sp)
    800021dc:	6aa2                	ld	s5,8(sp)
    800021de:	6b02                	ld	s6,0(sp)
    800021e0:	6121                	add	sp,sp,64
    800021e2:	8082                	ret

00000000800021e4 <reparent>:
{
    800021e4:	7139                	add	sp,sp,-64
    800021e6:	fc06                	sd	ra,56(sp)
    800021e8:	f822                	sd	s0,48(sp)
    800021ea:	f426                	sd	s1,40(sp)
    800021ec:	f04a                	sd	s2,32(sp)
    800021ee:	ec4e                	sd	s3,24(sp)
    800021f0:	e852                	sd	s4,16(sp)
    800021f2:	e456                	sd	s5,8(sp)
    800021f4:	0080                	add	s0,sp,64
    800021f6:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800021f8:	0000f497          	auipc	s1,0xf
    800021fc:	f6848493          	add	s1,s1,-152 # 80011160 <proc>
      pp->parent = initproc;
    80002200:	00007a97          	auipc	s5,0x7
    80002204:	8b8a8a93          	add	s5,s5,-1864 # 80008ab8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002208:	6919                	lui	s2,0x6
    8000220a:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    8000220e:	0018ca17          	auipc	s4,0x18c
    80002212:	d52a0a13          	add	s4,s4,-686 # 8018df60 <tickslock>
    80002216:	a021                	j	8000221e <reparent+0x3a>
    80002218:	94ca                	add	s1,s1,s2
    8000221a:	01448d63          	beq	s1,s4,80002234 <reparent+0x50>
    if(pp->parent == p){
    8000221e:	7c9c                	ld	a5,56(s1)
    80002220:	ff379ce3          	bne	a5,s3,80002218 <reparent+0x34>
      pp->parent = initproc;
    80002224:	000ab503          	ld	a0,0(s5)
    80002228:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    8000222a:	00000097          	auipc	ra,0x0
    8000222e:	f3c080e7          	jalr	-196(ra) # 80002166 <wakeup>
    80002232:	b7dd                	j	80002218 <reparent+0x34>
}
    80002234:	70e2                	ld	ra,56(sp)
    80002236:	7442                	ld	s0,48(sp)
    80002238:	74a2                	ld	s1,40(sp)
    8000223a:	7902                	ld	s2,32(sp)
    8000223c:	69e2                	ld	s3,24(sp)
    8000223e:	6a42                	ld	s4,16(sp)
    80002240:	6aa2                	ld	s5,8(sp)
    80002242:	6121                	add	sp,sp,64
    80002244:	8082                	ret

0000000080002246 <exit>:
{
    80002246:	7179                	add	sp,sp,-48
    80002248:	f406                	sd	ra,40(sp)
    8000224a:	f022                	sd	s0,32(sp)
    8000224c:	ec26                	sd	s1,24(sp)
    8000224e:	e84a                	sd	s2,16(sp)
    80002250:	e44e                	sd	s3,8(sp)
    80002252:	e052                	sd	s4,0(sp)
    80002254:	1800                	add	s0,sp,48
    80002256:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002258:	fffff097          	auipc	ra,0xfffff
    8000225c:	79e080e7          	jalr	1950(ra) # 800019f6 <myproc>
    80002260:	89aa                	mv	s3,a0
  if(p == initproc)
    80002262:	00007797          	auipc	a5,0x7
    80002266:	8567b783          	ld	a5,-1962(a5) # 80008ab8 <initproc>
    8000226a:	0d050493          	add	s1,a0,208
    8000226e:	15050913          	add	s2,a0,336
    80002272:	02a79363          	bne	a5,a0,80002298 <exit+0x52>
    panic("init exiting");
    80002276:	00006517          	auipc	a0,0x6
    8000227a:	02a50513          	add	a0,a0,42 # 800082a0 <digits+0x260>
    8000227e:	ffffe097          	auipc	ra,0xffffe
    80002282:	2be080e7          	jalr	702(ra) # 8000053c <panic>
      fileclose(f);
    80002286:	00002097          	auipc	ra,0x2
    8000228a:	322080e7          	jalr	802(ra) # 800045a8 <fileclose>
      p->ofile[fd] = 0;
    8000228e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002292:	04a1                	add	s1,s1,8
    80002294:	01248563          	beq	s1,s2,8000229e <exit+0x58>
    if(p->ofile[fd]){
    80002298:	6088                	ld	a0,0(s1)
    8000229a:	f575                	bnez	a0,80002286 <exit+0x40>
    8000229c:	bfdd                	j	80002292 <exit+0x4c>
  begin_op();
    8000229e:	00002097          	auipc	ra,0x2
    800022a2:	e46080e7          	jalr	-442(ra) # 800040e4 <begin_op>
  iput(p->cwd);
    800022a6:	1509b503          	ld	a0,336(s3)
    800022aa:	00001097          	auipc	ra,0x1
    800022ae:	64e080e7          	jalr	1614(ra) # 800038f8 <iput>
  end_op();
    800022b2:	00002097          	auipc	ra,0x2
    800022b6:	eac080e7          	jalr	-340(ra) # 8000415e <end_op>
  p->cwd = 0;
    800022ba:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800022be:	0000f497          	auipc	s1,0xf
    800022c2:	a8a48493          	add	s1,s1,-1398 # 80010d48 <wait_lock>
    800022c6:	8526                	mv	a0,s1
    800022c8:	fffff097          	auipc	ra,0xfffff
    800022cc:	90a080e7          	jalr	-1782(ra) # 80000bd2 <acquire>
  reparent(p);
    800022d0:	854e                	mv	a0,s3
    800022d2:	00000097          	auipc	ra,0x0
    800022d6:	f12080e7          	jalr	-238(ra) # 800021e4 <reparent>
  wakeup(p->parent);
    800022da:	0389b503          	ld	a0,56(s3)
    800022de:	00000097          	auipc	ra,0x0
    800022e2:	e88080e7          	jalr	-376(ra) # 80002166 <wakeup>
  acquire(&p->lock);
    800022e6:	854e                	mv	a0,s3
    800022e8:	fffff097          	auipc	ra,0xfffff
    800022ec:	8ea080e7          	jalr	-1814(ra) # 80000bd2 <acquire>
  p->xstate = status;
    800022f0:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800022f4:	4795                	li	a5,5
    800022f6:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800022fa:	8526                	mv	a0,s1
    800022fc:	fffff097          	auipc	ra,0xfffff
    80002300:	98a080e7          	jalr	-1654(ra) # 80000c86 <release>
  sched();
    80002304:	00000097          	auipc	ra,0x0
    80002308:	cec080e7          	jalr	-788(ra) # 80001ff0 <sched>
  panic("zombie exit");
    8000230c:	00006517          	auipc	a0,0x6
    80002310:	fa450513          	add	a0,a0,-92 # 800082b0 <digits+0x270>
    80002314:	ffffe097          	auipc	ra,0xffffe
    80002318:	228080e7          	jalr	552(ra) # 8000053c <panic>

000000008000231c <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000231c:	7179                	add	sp,sp,-48
    8000231e:	f406                	sd	ra,40(sp)
    80002320:	f022                	sd	s0,32(sp)
    80002322:	ec26                	sd	s1,24(sp)
    80002324:	e84a                	sd	s2,16(sp)
    80002326:	e44e                	sd	s3,8(sp)
    80002328:	e052                	sd	s4,0(sp)
    8000232a:	1800                	add	s0,sp,48
    8000232c:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000232e:	0000f497          	auipc	s1,0xf
    80002332:	e3248493          	add	s1,s1,-462 # 80011160 <proc>
    80002336:	6999                	lui	s3,0x6
    80002338:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    8000233c:	0018ca17          	auipc	s4,0x18c
    80002340:	c24a0a13          	add	s4,s4,-988 # 8018df60 <tickslock>
    acquire(&p->lock);
    80002344:	8526                	mv	a0,s1
    80002346:	fffff097          	auipc	ra,0xfffff
    8000234a:	88c080e7          	jalr	-1908(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    8000234e:	589c                	lw	a5,48(s1)
    80002350:	01278c63          	beq	a5,s2,80002368 <kill+0x4c>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002354:	8526                	mv	a0,s1
    80002356:	fffff097          	auipc	ra,0xfffff
    8000235a:	930080e7          	jalr	-1744(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000235e:	94ce                	add	s1,s1,s3
    80002360:	ff4492e3          	bne	s1,s4,80002344 <kill+0x28>
  }
  return -1;
    80002364:	557d                	li	a0,-1
    80002366:	a829                	j	80002380 <kill+0x64>
      p->killed = 1;
    80002368:	4785                	li	a5,1
    8000236a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000236c:	4c98                	lw	a4,24(s1)
    8000236e:	4789                	li	a5,2
    80002370:	02f70063          	beq	a4,a5,80002390 <kill+0x74>
      release(&p->lock);
    80002374:	8526                	mv	a0,s1
    80002376:	fffff097          	auipc	ra,0xfffff
    8000237a:	910080e7          	jalr	-1776(ra) # 80000c86 <release>
      return 0;
    8000237e:	4501                	li	a0,0
}
    80002380:	70a2                	ld	ra,40(sp)
    80002382:	7402                	ld	s0,32(sp)
    80002384:	64e2                	ld	s1,24(sp)
    80002386:	6942                	ld	s2,16(sp)
    80002388:	69a2                	ld	s3,8(sp)
    8000238a:	6a02                	ld	s4,0(sp)
    8000238c:	6145                	add	sp,sp,48
    8000238e:	8082                	ret
        p->state = RUNNABLE;
    80002390:	478d                	li	a5,3
    80002392:	cc9c                	sw	a5,24(s1)
    80002394:	b7c5                	j	80002374 <kill+0x58>

0000000080002396 <setkilled>:

void
setkilled(struct proc *p)
{
    80002396:	1101                	add	sp,sp,-32
    80002398:	ec06                	sd	ra,24(sp)
    8000239a:	e822                	sd	s0,16(sp)
    8000239c:	e426                	sd	s1,8(sp)
    8000239e:	1000                	add	s0,sp,32
    800023a0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800023a2:	fffff097          	auipc	ra,0xfffff
    800023a6:	830080e7          	jalr	-2000(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800023aa:	4785                	li	a5,1
    800023ac:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800023ae:	8526                	mv	a0,s1
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8d6080e7          	jalr	-1834(ra) # 80000c86 <release>
}
    800023b8:	60e2                	ld	ra,24(sp)
    800023ba:	6442                	ld	s0,16(sp)
    800023bc:	64a2                	ld	s1,8(sp)
    800023be:	6105                	add	sp,sp,32
    800023c0:	8082                	ret

00000000800023c2 <killed>:

int
killed(struct proc *p)
{
    800023c2:	1101                	add	sp,sp,-32
    800023c4:	ec06                	sd	ra,24(sp)
    800023c6:	e822                	sd	s0,16(sp)
    800023c8:	e426                	sd	s1,8(sp)
    800023ca:	e04a                	sd	s2,0(sp)
    800023cc:	1000                	add	s0,sp,32
    800023ce:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    800023d0:	fffff097          	auipc	ra,0xfffff
    800023d4:	802080e7          	jalr	-2046(ra) # 80000bd2 <acquire>
  k = p->killed;
    800023d8:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	8a8080e7          	jalr	-1880(ra) # 80000c86 <release>
  return k;
}
    800023e6:	854a                	mv	a0,s2
    800023e8:	60e2                	ld	ra,24(sp)
    800023ea:	6442                	ld	s0,16(sp)
    800023ec:	64a2                	ld	s1,8(sp)
    800023ee:	6902                	ld	s2,0(sp)
    800023f0:	6105                	add	sp,sp,32
    800023f2:	8082                	ret

00000000800023f4 <wait>:
{
    800023f4:	715d                	add	sp,sp,-80
    800023f6:	e486                	sd	ra,72(sp)
    800023f8:	e0a2                	sd	s0,64(sp)
    800023fa:	fc26                	sd	s1,56(sp)
    800023fc:	f84a                	sd	s2,48(sp)
    800023fe:	f44e                	sd	s3,40(sp)
    80002400:	f052                	sd	s4,32(sp)
    80002402:	ec56                	sd	s5,24(sp)
    80002404:	e85a                	sd	s6,16(sp)
    80002406:	e45e                	sd	s7,8(sp)
    80002408:	0880                	add	s0,sp,80
    8000240a:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    8000240c:	fffff097          	auipc	ra,0xfffff
    80002410:	5ea080e7          	jalr	1514(ra) # 800019f6 <myproc>
    80002414:	892a                	mv	s2,a0
  acquire(&wait_lock);
    80002416:	0000f517          	auipc	a0,0xf
    8000241a:	93250513          	add	a0,a0,-1742 # 80010d48 <wait_lock>
    8000241e:	ffffe097          	auipc	ra,0xffffe
    80002422:	7b4080e7          	jalr	1972(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002426:	4a95                	li	s5,5
        havekids = 1;
    80002428:	4b05                	li	s6,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000242a:	6999                	lui	s3,0x6
    8000242c:	f3898993          	add	s3,s3,-200 # 5f38 <_entry-0x7fffa0c8>
    80002430:	0018ca17          	auipc	s4,0x18c
    80002434:	b30a0a13          	add	s4,s4,-1232 # 8018df60 <tickslock>
    80002438:	a0d9                	j	800024fe <wait+0x10a>
          pid = pp->pid;
    8000243a:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    8000243e:	000b8e63          	beqz	s7,8000245a <wait+0x66>
    80002442:	4691                	li	a3,4
    80002444:	02c48613          	add	a2,s1,44
    80002448:	85de                	mv	a1,s7
    8000244a:	05093503          	ld	a0,80(s2)
    8000244e:	fffff097          	auipc	ra,0xfffff
    80002452:	258080e7          	jalr	600(ra) # 800016a6 <copyout>
    80002456:	04054063          	bltz	a0,80002496 <wait+0xa2>
          freeproc(pp);
    8000245a:	8526                	mv	a0,s1
    8000245c:	fffff097          	auipc	ra,0xfffff
    80002460:	74c080e7          	jalr	1868(ra) # 80001ba8 <freeproc>
          release(&pp->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	820080e7          	jalr	-2016(ra) # 80000c86 <release>
          release(&wait_lock);
    8000246e:	0000f517          	auipc	a0,0xf
    80002472:	8da50513          	add	a0,a0,-1830 # 80010d48 <wait_lock>
    80002476:	fffff097          	auipc	ra,0xfffff
    8000247a:	810080e7          	jalr	-2032(ra) # 80000c86 <release>
}
    8000247e:	854e                	mv	a0,s3
    80002480:	60a6                	ld	ra,72(sp)
    80002482:	6406                	ld	s0,64(sp)
    80002484:	74e2                	ld	s1,56(sp)
    80002486:	7942                	ld	s2,48(sp)
    80002488:	79a2                	ld	s3,40(sp)
    8000248a:	7a02                	ld	s4,32(sp)
    8000248c:	6ae2                	ld	s5,24(sp)
    8000248e:	6b42                	ld	s6,16(sp)
    80002490:	6ba2                	ld	s7,8(sp)
    80002492:	6161                	add	sp,sp,80
    80002494:	8082                	ret
            release(&pp->lock);
    80002496:	8526                	mv	a0,s1
    80002498:	ffffe097          	auipc	ra,0xffffe
    8000249c:	7ee080e7          	jalr	2030(ra) # 80000c86 <release>
            release(&wait_lock);
    800024a0:	0000f517          	auipc	a0,0xf
    800024a4:	8a850513          	add	a0,a0,-1880 # 80010d48 <wait_lock>
    800024a8:	ffffe097          	auipc	ra,0xffffe
    800024ac:	7de080e7          	jalr	2014(ra) # 80000c86 <release>
            return -1;
    800024b0:	59fd                	li	s3,-1
    800024b2:	b7f1                	j	8000247e <wait+0x8a>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b4:	94ce                	add	s1,s1,s3
    800024b6:	03448463          	beq	s1,s4,800024de <wait+0xea>
      if(pp->parent == p){
    800024ba:	7c9c                	ld	a5,56(s1)
    800024bc:	ff279ce3          	bne	a5,s2,800024b4 <wait+0xc0>
        acquire(&pp->lock);
    800024c0:	8526                	mv	a0,s1
    800024c2:	ffffe097          	auipc	ra,0xffffe
    800024c6:	710080e7          	jalr	1808(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    800024ca:	4c9c                	lw	a5,24(s1)
    800024cc:	f75787e3          	beq	a5,s5,8000243a <wait+0x46>
        release(&pp->lock);
    800024d0:	8526                	mv	a0,s1
    800024d2:	ffffe097          	auipc	ra,0xffffe
    800024d6:	7b4080e7          	jalr	1972(ra) # 80000c86 <release>
        havekids = 1;
    800024da:	875a                	mv	a4,s6
    800024dc:	bfe1                	j	800024b4 <wait+0xc0>
    if(!havekids || killed(p)){
    800024de:	c715                	beqz	a4,8000250a <wait+0x116>
    800024e0:	854a                	mv	a0,s2
    800024e2:	00000097          	auipc	ra,0x0
    800024e6:	ee0080e7          	jalr	-288(ra) # 800023c2 <killed>
    800024ea:	e105                	bnez	a0,8000250a <wait+0x116>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024ec:	0000f597          	auipc	a1,0xf
    800024f0:	85c58593          	add	a1,a1,-1956 # 80010d48 <wait_lock>
    800024f4:	854a                	mv	a0,s2
    800024f6:	00000097          	auipc	ra,0x0
    800024fa:	c0c080e7          	jalr	-1012(ra) # 80002102 <sleep>
    havekids = 0;
    800024fe:	4701                	li	a4,0
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002500:	0000f497          	auipc	s1,0xf
    80002504:	c6048493          	add	s1,s1,-928 # 80011160 <proc>
    80002508:	bf4d                	j	800024ba <wait+0xc6>
      release(&wait_lock);
    8000250a:	0000f517          	auipc	a0,0xf
    8000250e:	83e50513          	add	a0,a0,-1986 # 80010d48 <wait_lock>
    80002512:	ffffe097          	auipc	ra,0xffffe
    80002516:	774080e7          	jalr	1908(ra) # 80000c86 <release>
      return -1;
    8000251a:	59fd                	li	s3,-1
    8000251c:	b78d                	j	8000247e <wait+0x8a>

000000008000251e <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000251e:	7179                	add	sp,sp,-48
    80002520:	f406                	sd	ra,40(sp)
    80002522:	f022                	sd	s0,32(sp)
    80002524:	ec26                	sd	s1,24(sp)
    80002526:	e84a                	sd	s2,16(sp)
    80002528:	e44e                	sd	s3,8(sp)
    8000252a:	e052                	sd	s4,0(sp)
    8000252c:	1800                	add	s0,sp,48
    8000252e:	84aa                	mv	s1,a0
    80002530:	892e                	mv	s2,a1
    80002532:	89b2                	mv	s3,a2
    80002534:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002536:	fffff097          	auipc	ra,0xfffff
    8000253a:	4c0080e7          	jalr	1216(ra) # 800019f6 <myproc>
  if(user_dst){
    8000253e:	c08d                	beqz	s1,80002560 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002540:	86d2                	mv	a3,s4
    80002542:	864e                	mv	a2,s3
    80002544:	85ca                	mv	a1,s2
    80002546:	6928                	ld	a0,80(a0)
    80002548:	fffff097          	auipc	ra,0xfffff
    8000254c:	15e080e7          	jalr	350(ra) # 800016a6 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002550:	70a2                	ld	ra,40(sp)
    80002552:	7402                	ld	s0,32(sp)
    80002554:	64e2                	ld	s1,24(sp)
    80002556:	6942                	ld	s2,16(sp)
    80002558:	69a2                	ld	s3,8(sp)
    8000255a:	6a02                	ld	s4,0(sp)
    8000255c:	6145                	add	sp,sp,48
    8000255e:	8082                	ret
    memmove((char *)dst, src, len);
    80002560:	000a061b          	sext.w	a2,s4
    80002564:	85ce                	mv	a1,s3
    80002566:	854a                	mv	a0,s2
    80002568:	ffffe097          	auipc	ra,0xffffe
    8000256c:	7c2080e7          	jalr	1986(ra) # 80000d2a <memmove>
    return 0;
    80002570:	8526                	mv	a0,s1
    80002572:	bff9                	j	80002550 <either_copyout+0x32>

0000000080002574 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002574:	7179                	add	sp,sp,-48
    80002576:	f406                	sd	ra,40(sp)
    80002578:	f022                	sd	s0,32(sp)
    8000257a:	ec26                	sd	s1,24(sp)
    8000257c:	e84a                	sd	s2,16(sp)
    8000257e:	e44e                	sd	s3,8(sp)
    80002580:	e052                	sd	s4,0(sp)
    80002582:	1800                	add	s0,sp,48
    80002584:	892a                	mv	s2,a0
    80002586:	84ae                	mv	s1,a1
    80002588:	89b2                	mv	s3,a2
    8000258a:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000258c:	fffff097          	auipc	ra,0xfffff
    80002590:	46a080e7          	jalr	1130(ra) # 800019f6 <myproc>
  if(user_src){
    80002594:	c08d                	beqz	s1,800025b6 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002596:	86d2                	mv	a3,s4
    80002598:	864e                	mv	a2,s3
    8000259a:	85ca                	mv	a1,s2
    8000259c:	6928                	ld	a0,80(a0)
    8000259e:	fffff097          	auipc	ra,0xfffff
    800025a2:	194080e7          	jalr	404(ra) # 80001732 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800025a6:	70a2                	ld	ra,40(sp)
    800025a8:	7402                	ld	s0,32(sp)
    800025aa:	64e2                	ld	s1,24(sp)
    800025ac:	6942                	ld	s2,16(sp)
    800025ae:	69a2                	ld	s3,8(sp)
    800025b0:	6a02                	ld	s4,0(sp)
    800025b2:	6145                	add	sp,sp,48
    800025b4:	8082                	ret
    memmove(dst, (char*)src, len);
    800025b6:	000a061b          	sext.w	a2,s4
    800025ba:	85ce                	mv	a1,s3
    800025bc:	854a                	mv	a0,s2
    800025be:	ffffe097          	auipc	ra,0xffffe
    800025c2:	76c080e7          	jalr	1900(ra) # 80000d2a <memmove>
    return 0;
    800025c6:	8526                	mv	a0,s1
    800025c8:	bff9                	j	800025a6 <either_copyin+0x32>

00000000800025ca <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    800025ca:	715d                	add	sp,sp,-80
    800025cc:	e486                	sd	ra,72(sp)
    800025ce:	e0a2                	sd	s0,64(sp)
    800025d0:	fc26                	sd	s1,56(sp)
    800025d2:	f84a                	sd	s2,48(sp)
    800025d4:	f44e                	sd	s3,40(sp)
    800025d6:	f052                	sd	s4,32(sp)
    800025d8:	ec56                	sd	s5,24(sp)
    800025da:	e85a                	sd	s6,16(sp)
    800025dc:	e45e                	sd	s7,8(sp)
    800025de:	e062                	sd	s8,0(sp)
    800025e0:	0880                	add	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    800025e2:	00006517          	auipc	a0,0x6
    800025e6:	44e50513          	add	a0,a0,1102 # 80008a30 <syscalls+0x5a0>
    800025ea:	ffffe097          	auipc	ra,0xffffe
    800025ee:	f9c080e7          	jalr	-100(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800025f2:	0000f497          	auipc	s1,0xf
    800025f6:	cc648493          	add	s1,s1,-826 # 800112b8 <proc+0x158>
    800025fa:	0018c997          	auipc	s3,0x18c
    800025fe:	abe98993          	add	s3,s3,-1346 # 8018e0b8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002602:	4b95                	li	s7,5
      state = states[p->state];
    else
      state = "???";
    80002604:	00006a17          	auipc	s4,0x6
    80002608:	cbca0a13          	add	s4,s4,-836 # 800082c0 <digits+0x280>
    printf("%d %s %s", p->pid, state, p->name);
    8000260c:	00006b17          	auipc	s6,0x6
    80002610:	cbcb0b13          	add	s6,s6,-836 # 800082c8 <digits+0x288>
    printf("\n");
    80002614:	00006a97          	auipc	s5,0x6
    80002618:	41ca8a93          	add	s5,s5,1052 # 80008a30 <syscalls+0x5a0>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000261c:	00006c17          	auipc	s8,0x6
    80002620:	cecc0c13          	add	s8,s8,-788 # 80008308 <states.0>
  for(p = proc; p < &proc[NPROC]; p++){
    80002624:	6919                	lui	s2,0x6
    80002626:	f3890913          	add	s2,s2,-200 # 5f38 <_entry-0x7fffa0c8>
    8000262a:	a005                	j	8000264a <procdump+0x80>
    printf("%d %s %s", p->pid, state, p->name);
    8000262c:	ed86a583          	lw	a1,-296(a3)
    80002630:	855a                	mv	a0,s6
    80002632:	ffffe097          	auipc	ra,0xffffe
    80002636:	f54080e7          	jalr	-172(ra) # 80000586 <printf>
    printf("\n");
    8000263a:	8556                	mv	a0,s5
    8000263c:	ffffe097          	auipc	ra,0xffffe
    80002640:	f4a080e7          	jalr	-182(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002644:	94ca                	add	s1,s1,s2
    80002646:	03348263          	beq	s1,s3,8000266a <procdump+0xa0>
    if(p->state == UNUSED)
    8000264a:	86a6                	mv	a3,s1
    8000264c:	ec04a783          	lw	a5,-320(s1)
    80002650:	dbf5                	beqz	a5,80002644 <procdump+0x7a>
      state = "???";
    80002652:	8652                	mv	a2,s4
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002654:	fcfbece3          	bltu	s7,a5,8000262c <procdump+0x62>
    80002658:	02079713          	sll	a4,a5,0x20
    8000265c:	01d75793          	srl	a5,a4,0x1d
    80002660:	97e2                	add	a5,a5,s8
    80002662:	6390                	ld	a2,0(a5)
    80002664:	f661                	bnez	a2,8000262c <procdump+0x62>
      state = "???";
    80002666:	8652                	mv	a2,s4
    80002668:	b7d1                	j	8000262c <procdump+0x62>
  }
}
    8000266a:	60a6                	ld	ra,72(sp)
    8000266c:	6406                	ld	s0,64(sp)
    8000266e:	74e2                	ld	s1,56(sp)
    80002670:	7942                	ld	s2,48(sp)
    80002672:	79a2                	ld	s3,40(sp)
    80002674:	7a02                	ld	s4,32(sp)
    80002676:	6ae2                	ld	s5,24(sp)
    80002678:	6b42                	ld	s6,16(sp)
    8000267a:	6ba2                	ld	s7,8(sp)
    8000267c:	6c02                	ld	s8,0(sp)
    8000267e:	6161                	add	sp,sp,80
    80002680:	8082                	ret

0000000080002682 <swtch>:
    80002682:	00153023          	sd	ra,0(a0)
    80002686:	00253423          	sd	sp,8(a0)
    8000268a:	e900                	sd	s0,16(a0)
    8000268c:	ed04                	sd	s1,24(a0)
    8000268e:	03253023          	sd	s2,32(a0)
    80002692:	03353423          	sd	s3,40(a0)
    80002696:	03453823          	sd	s4,48(a0)
    8000269a:	03553c23          	sd	s5,56(a0)
    8000269e:	05653023          	sd	s6,64(a0)
    800026a2:	05753423          	sd	s7,72(a0)
    800026a6:	05853823          	sd	s8,80(a0)
    800026aa:	05953c23          	sd	s9,88(a0)
    800026ae:	07a53023          	sd	s10,96(a0)
    800026b2:	07b53423          	sd	s11,104(a0)
    800026b6:	0005b083          	ld	ra,0(a1)
    800026ba:	0085b103          	ld	sp,8(a1)
    800026be:	6980                	ld	s0,16(a1)
    800026c0:	6d84                	ld	s1,24(a1)
    800026c2:	0205b903          	ld	s2,32(a1)
    800026c6:	0285b983          	ld	s3,40(a1)
    800026ca:	0305ba03          	ld	s4,48(a1)
    800026ce:	0385ba83          	ld	s5,56(a1)
    800026d2:	0405bb03          	ld	s6,64(a1)
    800026d6:	0485bb83          	ld	s7,72(a1)
    800026da:	0505bc03          	ld	s8,80(a1)
    800026de:	0585bc83          	ld	s9,88(a1)
    800026e2:	0605bd03          	ld	s10,96(a1)
    800026e6:	0685bd83          	ld	s11,104(a1)
    800026ea:	8082                	ret

00000000800026ec <trapinit>:

extern int devintr();

void
trapinit(void)
{
    800026ec:	1141                	add	sp,sp,-16
    800026ee:	e406                	sd	ra,8(sp)
    800026f0:	e022                	sd	s0,0(sp)
    800026f2:	0800                	add	s0,sp,16
  initlock(&tickslock, "time");
    800026f4:	00006597          	auipc	a1,0x6
    800026f8:	c4458593          	add	a1,a1,-956 # 80008338 <states.0+0x30>
    800026fc:	0018c517          	auipc	a0,0x18c
    80002700:	86450513          	add	a0,a0,-1948 # 8018df60 <tickslock>
    80002704:	ffffe097          	auipc	ra,0xffffe
    80002708:	43e080e7          	jalr	1086(ra) # 80000b42 <initlock>
}
    8000270c:	60a2                	ld	ra,8(sp)
    8000270e:	6402                	ld	s0,0(sp)
    80002710:	0141                	add	sp,sp,16
    80002712:	8082                	ret

0000000080002714 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002714:	1141                	add	sp,sp,-16
    80002716:	e422                	sd	s0,8(sp)
    80002718:	0800                	add	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000271a:	00003797          	auipc	a5,0x3
    8000271e:	53678793          	add	a5,a5,1334 # 80005c50 <kernelvec>
    80002722:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002726:	6422                	ld	s0,8(sp)
    80002728:	0141                	add	sp,sp,16
    8000272a:	8082                	ret

000000008000272c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000272c:	1141                	add	sp,sp,-16
    8000272e:	e406                	sd	ra,8(sp)
    80002730:	e022                	sd	s0,0(sp)
    80002732:	0800                	add	s0,sp,16
  struct proc *p = myproc();
    80002734:	fffff097          	auipc	ra,0xfffff
    80002738:	2c2080e7          	jalr	706(ra) # 800019f6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000273c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002740:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002742:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002746:	00005697          	auipc	a3,0x5
    8000274a:	8ba68693          	add	a3,a3,-1862 # 80007000 <_trampoline>
    8000274e:	00005717          	auipc	a4,0x5
    80002752:	8b270713          	add	a4,a4,-1870 # 80007000 <_trampoline>
    80002756:	8f15                	sub	a4,a4,a3
    80002758:	040007b7          	lui	a5,0x4000
    8000275c:	17fd                	add	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000275e:	07b2                	sll	a5,a5,0xc
    80002760:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002762:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002766:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002768:	18002673          	csrr	a2,satp
    8000276c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000276e:	6d30                	ld	a2,88(a0)
    80002770:	6138                	ld	a4,64(a0)
    80002772:	6585                	lui	a1,0x1
    80002774:	972e                	add	a4,a4,a1
    80002776:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80002778:	6d38                	ld	a4,88(a0)
    8000277a:	00000617          	auipc	a2,0x0
    8000277e:	13460613          	add	a2,a2,308 # 800028ae <usertrap>
    80002782:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002784:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80002786:	8612                	mv	a2,tp
    80002788:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000278a:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    8000278e:	eff77713          	and	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002792:	02076713          	or	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002796:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000279a:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    8000279c:	6f18                	ld	a4,24(a4)
    8000279e:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800027a2:	6928                	ld	a0,80(a0)
    800027a4:	8131                	srl	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800027a6:	00005717          	auipc	a4,0x5
    800027aa:	8f670713          	add	a4,a4,-1802 # 8000709c <userret>
    800027ae:	8f15                	sub	a4,a4,a3
    800027b0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800027b2:	577d                	li	a4,-1
    800027b4:	177e                	sll	a4,a4,0x3f
    800027b6:	8d59                	or	a0,a0,a4
    800027b8:	9782                	jalr	a5
}
    800027ba:	60a2                	ld	ra,8(sp)
    800027bc:	6402                	ld	s0,0(sp)
    800027be:	0141                	add	sp,sp,16
    800027c0:	8082                	ret

00000000800027c2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800027c2:	1101                	add	sp,sp,-32
    800027c4:	ec06                	sd	ra,24(sp)
    800027c6:	e822                	sd	s0,16(sp)
    800027c8:	e426                	sd	s1,8(sp)
    800027ca:	1000                	add	s0,sp,32
  acquire(&tickslock);
    800027cc:	0018b497          	auipc	s1,0x18b
    800027d0:	79448493          	add	s1,s1,1940 # 8018df60 <tickslock>
    800027d4:	8526                	mv	a0,s1
    800027d6:	ffffe097          	auipc	ra,0xffffe
    800027da:	3fc080e7          	jalr	1020(ra) # 80000bd2 <acquire>
  ticks++;
    800027de:	00006517          	auipc	a0,0x6
    800027e2:	2e250513          	add	a0,a0,738 # 80008ac0 <ticks>
    800027e6:	411c                	lw	a5,0(a0)
    800027e8:	2785                	addw	a5,a5,1
    800027ea:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    800027ec:	00000097          	auipc	ra,0x0
    800027f0:	97a080e7          	jalr	-1670(ra) # 80002166 <wakeup>
  release(&tickslock);
    800027f4:	8526                	mv	a0,s1
    800027f6:	ffffe097          	auipc	ra,0xffffe
    800027fa:	490080e7          	jalr	1168(ra) # 80000c86 <release>
}
    800027fe:	60e2                	ld	ra,24(sp)
    80002800:	6442                	ld	s0,16(sp)
    80002802:	64a2                	ld	s1,8(sp)
    80002804:	6105                	add	sp,sp,32
    80002806:	8082                	ret

0000000080002808 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002808:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000280c:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000280e:	0807df63          	bgez	a5,800028ac <devintr+0xa4>
{
    80002812:	1101                	add	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	e426                	sd	s1,8(sp)
    8000281a:	1000                	add	s0,sp,32
     (scause & 0xff) == 9){
    8000281c:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002820:	46a5                	li	a3,9
    80002822:	00d70d63          	beq	a4,a3,8000283c <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002826:	577d                	li	a4,-1
    80002828:	177e                	sll	a4,a4,0x3f
    8000282a:	0705                	add	a4,a4,1
    return 0;
    8000282c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000282e:	04e78e63          	beq	a5,a4,8000288a <devintr+0x82>
  }
}
    80002832:	60e2                	ld	ra,24(sp)
    80002834:	6442                	ld	s0,16(sp)
    80002836:	64a2                	ld	s1,8(sp)
    80002838:	6105                	add	sp,sp,32
    8000283a:	8082                	ret
    int irq = plic_claim();
    8000283c:	00003097          	auipc	ra,0x3
    80002840:	51c080e7          	jalr	1308(ra) # 80005d58 <plic_claim>
    80002844:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002846:	47a9                	li	a5,10
    80002848:	02f50763          	beq	a0,a5,80002876 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000284c:	4785                	li	a5,1
    8000284e:	02f50963          	beq	a0,a5,80002880 <devintr+0x78>
    return 1;
    80002852:	4505                	li	a0,1
    } else if(irq){
    80002854:	dcf9                	beqz	s1,80002832 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002856:	85a6                	mv	a1,s1
    80002858:	00006517          	auipc	a0,0x6
    8000285c:	ae850513          	add	a0,a0,-1304 # 80008340 <states.0+0x38>
    80002860:	ffffe097          	auipc	ra,0xffffe
    80002864:	d26080e7          	jalr	-730(ra) # 80000586 <printf>
      plic_complete(irq);
    80002868:	8526                	mv	a0,s1
    8000286a:	00003097          	auipc	ra,0x3
    8000286e:	512080e7          	jalr	1298(ra) # 80005d7c <plic_complete>
    return 1;
    80002872:	4505                	li	a0,1
    80002874:	bf7d                	j	80002832 <devintr+0x2a>
      uartintr();
    80002876:	ffffe097          	auipc	ra,0xffffe
    8000287a:	11e080e7          	jalr	286(ra) # 80000994 <uartintr>
    if(irq)
    8000287e:	b7ed                	j	80002868 <devintr+0x60>
      virtio_disk_intr();
    80002880:	00004097          	auipc	ra,0x4
    80002884:	9c2080e7          	jalr	-1598(ra) # 80006242 <virtio_disk_intr>
    if(irq)
    80002888:	b7c5                	j	80002868 <devintr+0x60>
    if(cpuid() == 0){
    8000288a:	fffff097          	auipc	ra,0xfffff
    8000288e:	140080e7          	jalr	320(ra) # 800019ca <cpuid>
    80002892:	c901                	beqz	a0,800028a2 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002894:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80002898:	9bf5                	and	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000289a:	14479073          	csrw	sip,a5
    return 2;
    8000289e:	4509                	li	a0,2
    800028a0:	bf49                	j	80002832 <devintr+0x2a>
      clockintr();
    800028a2:	00000097          	auipc	ra,0x0
    800028a6:	f20080e7          	jalr	-224(ra) # 800027c2 <clockintr>
    800028aa:	b7ed                	j	80002894 <devintr+0x8c>
}
    800028ac:	8082                	ret

00000000800028ae <usertrap>:
{
    800028ae:	1101                	add	sp,sp,-32
    800028b0:	ec06                	sd	ra,24(sp)
    800028b2:	e822                	sd	s0,16(sp)
    800028b4:	e426                	sd	s1,8(sp)
    800028b6:	e04a                	sd	s2,0(sp)
    800028b8:	1000                	add	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800028ba:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800028be:	1007f793          	and	a5,a5,256
    800028c2:	e7c1                	bnez	a5,8000294a <usertrap+0x9c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800028c4:	00003797          	auipc	a5,0x3
    800028c8:	38c78793          	add	a5,a5,908 # 80005c50 <kernelvec>
    800028cc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800028d0:	fffff097          	auipc	ra,0xfffff
    800028d4:	126080e7          	jalr	294(ra) # 800019f6 <myproc>
    800028d8:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800028da:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028dc:	14102773          	csrr	a4,sepc
    800028e0:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028e2:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800028e6:	47a1                	li	a5,8
    800028e8:	06f70963          	beq	a4,a5,8000295a <usertrap+0xac>
    800028ec:	14202773          	csrr	a4,scause
  else if(r_scause() == 12 || r_scause() == 13 || r_scause() == 15){
    800028f0:	47b1                	li	a5,12
    800028f2:	00f70c63          	beq	a4,a5,8000290a <usertrap+0x5c>
    800028f6:	14202773          	csrr	a4,scause
    800028fa:	47b5                	li	a5,13
    800028fc:	00f70763          	beq	a4,a5,8000290a <usertrap+0x5c>
    80002900:	14202773          	csrr	a4,scause
    80002904:	47bd                	li	a5,15
    80002906:	08f71a63          	bne	a4,a5,8000299a <usertrap+0xec>
    if(killed(p))
    8000290a:	8526                	mv	a0,s1
    8000290c:	00000097          	auipc	ra,0x0
    80002910:	ab6080e7          	jalr	-1354(ra) # 800023c2 <killed>
    80002914:	ed2d                	bnez	a0,8000298e <usertrap+0xe0>
    page_fault_handler();
    80002916:	00004097          	auipc	ra,0x4
    8000291a:	aae080e7          	jalr	-1362(ra) # 800063c4 <page_fault_handler>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000291e:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002922:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002926:	10079073          	csrw	sstatus,a5
  if(killed(p))
    8000292a:	8526                	mv	a0,s1
    8000292c:	00000097          	auipc	ra,0x0
    80002930:	a96080e7          	jalr	-1386(ra) # 800023c2 <killed>
    80002934:	ed4d                	bnez	a0,800029ee <usertrap+0x140>
  usertrapret();
    80002936:	00000097          	auipc	ra,0x0
    8000293a:	df6080e7          	jalr	-522(ra) # 8000272c <usertrapret>
}
    8000293e:	60e2                	ld	ra,24(sp)
    80002940:	6442                	ld	s0,16(sp)
    80002942:	64a2                	ld	s1,8(sp)
    80002944:	6902                	ld	s2,0(sp)
    80002946:	6105                	add	sp,sp,32
    80002948:	8082                	ret
    panic("usertrap: not from user mode");
    8000294a:	00006517          	auipc	a0,0x6
    8000294e:	a1650513          	add	a0,a0,-1514 # 80008360 <states.0+0x58>
    80002952:	ffffe097          	auipc	ra,0xffffe
    80002956:	bea080e7          	jalr	-1046(ra) # 8000053c <panic>
    if(killed(p))
    8000295a:	00000097          	auipc	ra,0x0
    8000295e:	a68080e7          	jalr	-1432(ra) # 800023c2 <killed>
    80002962:	e105                	bnez	a0,80002982 <usertrap+0xd4>
    p->trapframe->epc += 4;
    80002964:	6cb8                	ld	a4,88(s1)
    80002966:	6f1c                	ld	a5,24(a4)
    80002968:	0791                	add	a5,a5,4
    8000296a:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000296c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002970:	0027e793          	or	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002974:	10079073          	csrw	sstatus,a5
    syscall();
    80002978:	00000097          	auipc	ra,0x0
    8000297c:	2dc080e7          	jalr	732(ra) # 80002c54 <syscall>
    80002980:	b76d                	j	8000292a <usertrap+0x7c>
      exit(-1);
    80002982:	557d                	li	a0,-1
    80002984:	00000097          	auipc	ra,0x0
    80002988:	8c2080e7          	jalr	-1854(ra) # 80002246 <exit>
    8000298c:	bfe1                	j	80002964 <usertrap+0xb6>
      exit(-1);
    8000298e:	557d                	li	a0,-1
    80002990:	00000097          	auipc	ra,0x0
    80002994:	8b6080e7          	jalr	-1866(ra) # 80002246 <exit>
    80002998:	bfbd                	j	80002916 <usertrap+0x68>
  else if((which_dev = devintr()) != 0){
    8000299a:	00000097          	auipc	ra,0x0
    8000299e:	e6e080e7          	jalr	-402(ra) # 80002808 <devintr>
    800029a2:	892a                	mv	s2,a0
    800029a4:	c901                	beqz	a0,800029b4 <usertrap+0x106>
  if(killed(p))
    800029a6:	8526                	mv	a0,s1
    800029a8:	00000097          	auipc	ra,0x0
    800029ac:	a1a080e7          	jalr	-1510(ra) # 800023c2 <killed>
    800029b0:	c529                	beqz	a0,800029fa <usertrap+0x14c>
    800029b2:	a83d                	j	800029f0 <usertrap+0x142>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029b4:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029b8:	5890                	lw	a2,48(s1)
    800029ba:	00006517          	auipc	a0,0x6
    800029be:	9c650513          	add	a0,a0,-1594 # 80008380 <states.0+0x78>
    800029c2:	ffffe097          	auipc	ra,0xffffe
    800029c6:	bc4080e7          	jalr	-1084(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800029ca:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800029ce:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800029d2:	00006517          	auipc	a0,0x6
    800029d6:	9de50513          	add	a0,a0,-1570 # 800083b0 <states.0+0xa8>
    800029da:	ffffe097          	auipc	ra,0xffffe
    800029de:	bac080e7          	jalr	-1108(ra) # 80000586 <printf>
    setkilled(p);
    800029e2:	8526                	mv	a0,s1
    800029e4:	00000097          	auipc	ra,0x0
    800029e8:	9b2080e7          	jalr	-1614(ra) # 80002396 <setkilled>
    800029ec:	bf3d                	j	8000292a <usertrap+0x7c>
  if(killed(p))
    800029ee:	4901                	li	s2,0
    exit(-1);
    800029f0:	557d                	li	a0,-1
    800029f2:	00000097          	auipc	ra,0x0
    800029f6:	854080e7          	jalr	-1964(ra) # 80002246 <exit>
  if(which_dev == 2)
    800029fa:	4789                	li	a5,2
    800029fc:	f2f91de3          	bne	s2,a5,80002936 <usertrap+0x88>
    yield();
    80002a00:	fffff097          	auipc	ra,0xfffff
    80002a04:	6c6080e7          	jalr	1734(ra) # 800020c6 <yield>
    80002a08:	b73d                	j	80002936 <usertrap+0x88>

0000000080002a0a <kerneltrap>:
{
    80002a0a:	7179                	add	sp,sp,-48
    80002a0c:	f406                	sd	ra,40(sp)
    80002a0e:	f022                	sd	s0,32(sp)
    80002a10:	ec26                	sd	s1,24(sp)
    80002a12:	e84a                	sd	s2,16(sp)
    80002a14:	e44e                	sd	s3,8(sp)
    80002a16:	1800                	add	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a18:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a1c:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a20:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a24:	1004f793          	and	a5,s1,256
    80002a28:	cb85                	beqz	a5,80002a58 <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a2a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a2e:	8b89                	and	a5,a5,2
  if(intr_get() != 0)
    80002a30:	ef85                	bnez	a5,80002a68 <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a32:	00000097          	auipc	ra,0x0
    80002a36:	dd6080e7          	jalr	-554(ra) # 80002808 <devintr>
    80002a3a:	cd1d                	beqz	a0,80002a78 <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002a3c:	4789                	li	a5,2
    80002a3e:	06f50a63          	beq	a0,a5,80002ab2 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a42:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a46:	10049073          	csrw	sstatus,s1
}
    80002a4a:	70a2                	ld	ra,40(sp)
    80002a4c:	7402                	ld	s0,32(sp)
    80002a4e:	64e2                	ld	s1,24(sp)
    80002a50:	6942                	ld	s2,16(sp)
    80002a52:	69a2                	ld	s3,8(sp)
    80002a54:	6145                	add	sp,sp,48
    80002a56:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a58:	00006517          	auipc	a0,0x6
    80002a5c:	97850513          	add	a0,a0,-1672 # 800083d0 <states.0+0xc8>
    80002a60:	ffffe097          	auipc	ra,0xffffe
    80002a64:	adc080e7          	jalr	-1316(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    80002a68:	00006517          	auipc	a0,0x6
    80002a6c:	99050513          	add	a0,a0,-1648 # 800083f8 <states.0+0xf0>
    80002a70:	ffffe097          	auipc	ra,0xffffe
    80002a74:	acc080e7          	jalr	-1332(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    80002a78:	85ce                	mv	a1,s3
    80002a7a:	00006517          	auipc	a0,0x6
    80002a7e:	99e50513          	add	a0,a0,-1634 # 80008418 <states.0+0x110>
    80002a82:	ffffe097          	auipc	ra,0xffffe
    80002a86:	b04080e7          	jalr	-1276(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a8a:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a8e:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a92:	00006517          	auipc	a0,0x6
    80002a96:	99650513          	add	a0,a0,-1642 # 80008428 <states.0+0x120>
    80002a9a:	ffffe097          	auipc	ra,0xffffe
    80002a9e:	aec080e7          	jalr	-1300(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002aa2:	00006517          	auipc	a0,0x6
    80002aa6:	99e50513          	add	a0,a0,-1634 # 80008440 <states.0+0x138>
    80002aaa:	ffffe097          	auipc	ra,0xffffe
    80002aae:	a92080e7          	jalr	-1390(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING) {
    80002ab2:	fffff097          	auipc	ra,0xfffff
    80002ab6:	f44080e7          	jalr	-188(ra) # 800019f6 <myproc>
    80002aba:	d541                	beqz	a0,80002a42 <kerneltrap+0x38>
    80002abc:	fffff097          	auipc	ra,0xfffff
    80002ac0:	f3a080e7          	jalr	-198(ra) # 800019f6 <myproc>
    80002ac4:	4d18                	lw	a4,24(a0)
    80002ac6:	4791                	li	a5,4
    80002ac8:	f6f71de3          	bne	a4,a5,80002a42 <kerneltrap+0x38>
    yield();
    80002acc:	fffff097          	auipc	ra,0xfffff
    80002ad0:	5fa080e7          	jalr	1530(ra) # 800020c6 <yield>
    80002ad4:	b7bd                	j	80002a42 <kerneltrap+0x38>

0000000080002ad6 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002ad6:	1101                	add	sp,sp,-32
    80002ad8:	ec06                	sd	ra,24(sp)
    80002ada:	e822                	sd	s0,16(sp)
    80002adc:	e426                	sd	s1,8(sp)
    80002ade:	1000                	add	s0,sp,32
    80002ae0:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002ae2:	fffff097          	auipc	ra,0xfffff
    80002ae6:	f14080e7          	jalr	-236(ra) # 800019f6 <myproc>
  switch (n) {
    80002aea:	4795                	li	a5,5
    80002aec:	0497e163          	bltu	a5,s1,80002b2e <argraw+0x58>
    80002af0:	048a                	sll	s1,s1,0x2
    80002af2:	00006717          	auipc	a4,0x6
    80002af6:	98670713          	add	a4,a4,-1658 # 80008478 <states.0+0x170>
    80002afa:	94ba                	add	s1,s1,a4
    80002afc:	409c                	lw	a5,0(s1)
    80002afe:	97ba                	add	a5,a5,a4
    80002b00:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b02:	6d3c                	ld	a5,88(a0)
    80002b04:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b06:	60e2                	ld	ra,24(sp)
    80002b08:	6442                	ld	s0,16(sp)
    80002b0a:	64a2                	ld	s1,8(sp)
    80002b0c:	6105                	add	sp,sp,32
    80002b0e:	8082                	ret
    return p->trapframe->a1;
    80002b10:	6d3c                	ld	a5,88(a0)
    80002b12:	7fa8                	ld	a0,120(a5)
    80002b14:	bfcd                	j	80002b06 <argraw+0x30>
    return p->trapframe->a2;
    80002b16:	6d3c                	ld	a5,88(a0)
    80002b18:	63c8                	ld	a0,128(a5)
    80002b1a:	b7f5                	j	80002b06 <argraw+0x30>
    return p->trapframe->a3;
    80002b1c:	6d3c                	ld	a5,88(a0)
    80002b1e:	67c8                	ld	a0,136(a5)
    80002b20:	b7dd                	j	80002b06 <argraw+0x30>
    return p->trapframe->a4;
    80002b22:	6d3c                	ld	a5,88(a0)
    80002b24:	6bc8                	ld	a0,144(a5)
    80002b26:	b7c5                	j	80002b06 <argraw+0x30>
    return p->trapframe->a5;
    80002b28:	6d3c                	ld	a5,88(a0)
    80002b2a:	6fc8                	ld	a0,152(a5)
    80002b2c:	bfe9                	j	80002b06 <argraw+0x30>
  panic("argraw");
    80002b2e:	00006517          	auipc	a0,0x6
    80002b32:	92250513          	add	a0,a0,-1758 # 80008450 <states.0+0x148>
    80002b36:	ffffe097          	auipc	ra,0xffffe
    80002b3a:	a06080e7          	jalr	-1530(ra) # 8000053c <panic>

0000000080002b3e <fetchaddr>:
{
    80002b3e:	1101                	add	sp,sp,-32
    80002b40:	ec06                	sd	ra,24(sp)
    80002b42:	e822                	sd	s0,16(sp)
    80002b44:	e426                	sd	s1,8(sp)
    80002b46:	e04a                	sd	s2,0(sp)
    80002b48:	1000                	add	s0,sp,32
    80002b4a:	84aa                	mv	s1,a0
    80002b4c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b4e:	fffff097          	auipc	ra,0xfffff
    80002b52:	ea8080e7          	jalr	-344(ra) # 800019f6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b56:	653c                	ld	a5,72(a0)
    80002b58:	02f4f863          	bgeu	s1,a5,80002b88 <fetchaddr+0x4a>
    80002b5c:	00848713          	add	a4,s1,8
    80002b60:	02e7e663          	bltu	a5,a4,80002b8c <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b64:	46a1                	li	a3,8
    80002b66:	8626                	mv	a2,s1
    80002b68:	85ca                	mv	a1,s2
    80002b6a:	6928                	ld	a0,80(a0)
    80002b6c:	fffff097          	auipc	ra,0xfffff
    80002b70:	bc6080e7          	jalr	-1082(ra) # 80001732 <copyin>
    80002b74:	00a03533          	snez	a0,a0
    80002b78:	40a00533          	neg	a0,a0
}
    80002b7c:	60e2                	ld	ra,24(sp)
    80002b7e:	6442                	ld	s0,16(sp)
    80002b80:	64a2                	ld	s1,8(sp)
    80002b82:	6902                	ld	s2,0(sp)
    80002b84:	6105                	add	sp,sp,32
    80002b86:	8082                	ret
    return -1;
    80002b88:	557d                	li	a0,-1
    80002b8a:	bfcd                	j	80002b7c <fetchaddr+0x3e>
    80002b8c:	557d                	li	a0,-1
    80002b8e:	b7fd                	j	80002b7c <fetchaddr+0x3e>

0000000080002b90 <fetchstr>:
{
    80002b90:	7179                	add	sp,sp,-48
    80002b92:	f406                	sd	ra,40(sp)
    80002b94:	f022                	sd	s0,32(sp)
    80002b96:	ec26                	sd	s1,24(sp)
    80002b98:	e84a                	sd	s2,16(sp)
    80002b9a:	e44e                	sd	s3,8(sp)
    80002b9c:	1800                	add	s0,sp,48
    80002b9e:	892a                	mv	s2,a0
    80002ba0:	84ae                	mv	s1,a1
    80002ba2:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002ba4:	fffff097          	auipc	ra,0xfffff
    80002ba8:	e52080e7          	jalr	-430(ra) # 800019f6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002bac:	86ce                	mv	a3,s3
    80002bae:	864a                	mv	a2,s2
    80002bb0:	85a6                	mv	a1,s1
    80002bb2:	6928                	ld	a0,80(a0)
    80002bb4:	fffff097          	auipc	ra,0xfffff
    80002bb8:	c0c080e7          	jalr	-1012(ra) # 800017c0 <copyinstr>
    80002bbc:	00054e63          	bltz	a0,80002bd8 <fetchstr+0x48>
  return strlen(buf);
    80002bc0:	8526                	mv	a0,s1
    80002bc2:	ffffe097          	auipc	ra,0xffffe
    80002bc6:	286080e7          	jalr	646(ra) # 80000e48 <strlen>
}
    80002bca:	70a2                	ld	ra,40(sp)
    80002bcc:	7402                	ld	s0,32(sp)
    80002bce:	64e2                	ld	s1,24(sp)
    80002bd0:	6942                	ld	s2,16(sp)
    80002bd2:	69a2                	ld	s3,8(sp)
    80002bd4:	6145                	add	sp,sp,48
    80002bd6:	8082                	ret
    return -1;
    80002bd8:	557d                	li	a0,-1
    80002bda:	bfc5                	j	80002bca <fetchstr+0x3a>

0000000080002bdc <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002bdc:	1101                	add	sp,sp,-32
    80002bde:	ec06                	sd	ra,24(sp)
    80002be0:	e822                	sd	s0,16(sp)
    80002be2:	e426                	sd	s1,8(sp)
    80002be4:	1000                	add	s0,sp,32
    80002be6:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002be8:	00000097          	auipc	ra,0x0
    80002bec:	eee080e7          	jalr	-274(ra) # 80002ad6 <argraw>
    80002bf0:	c088                	sw	a0,0(s1)
}
    80002bf2:	60e2                	ld	ra,24(sp)
    80002bf4:	6442                	ld	s0,16(sp)
    80002bf6:	64a2                	ld	s1,8(sp)
    80002bf8:	6105                	add	sp,sp,32
    80002bfa:	8082                	ret

0000000080002bfc <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002bfc:	1101                	add	sp,sp,-32
    80002bfe:	ec06                	sd	ra,24(sp)
    80002c00:	e822                	sd	s0,16(sp)
    80002c02:	e426                	sd	s1,8(sp)
    80002c04:	1000                	add	s0,sp,32
    80002c06:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c08:	00000097          	auipc	ra,0x0
    80002c0c:	ece080e7          	jalr	-306(ra) # 80002ad6 <argraw>
    80002c10:	e088                	sd	a0,0(s1)
}
    80002c12:	60e2                	ld	ra,24(sp)
    80002c14:	6442                	ld	s0,16(sp)
    80002c16:	64a2                	ld	s1,8(sp)
    80002c18:	6105                	add	sp,sp,32
    80002c1a:	8082                	ret

0000000080002c1c <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c1c:	7179                	add	sp,sp,-48
    80002c1e:	f406                	sd	ra,40(sp)
    80002c20:	f022                	sd	s0,32(sp)
    80002c22:	ec26                	sd	s1,24(sp)
    80002c24:	e84a                	sd	s2,16(sp)
    80002c26:	1800                	add	s0,sp,48
    80002c28:	84ae                	mv	s1,a1
    80002c2a:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c2c:	fd840593          	add	a1,s0,-40
    80002c30:	00000097          	auipc	ra,0x0
    80002c34:	fcc080e7          	jalr	-52(ra) # 80002bfc <argaddr>
  return fetchstr(addr, buf, max);
    80002c38:	864a                	mv	a2,s2
    80002c3a:	85a6                	mv	a1,s1
    80002c3c:	fd843503          	ld	a0,-40(s0)
    80002c40:	00000097          	auipc	ra,0x0
    80002c44:	f50080e7          	jalr	-176(ra) # 80002b90 <fetchstr>
}
    80002c48:	70a2                	ld	ra,40(sp)
    80002c4a:	7402                	ld	s0,32(sp)
    80002c4c:	64e2                	ld	s1,24(sp)
    80002c4e:	6942                	ld	s2,16(sp)
    80002c50:	6145                	add	sp,sp,48
    80002c52:	8082                	ret

0000000080002c54 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002c54:	1101                	add	sp,sp,-32
    80002c56:	ec06                	sd	ra,24(sp)
    80002c58:	e822                	sd	s0,16(sp)
    80002c5a:	e426                	sd	s1,8(sp)
    80002c5c:	e04a                	sd	s2,0(sp)
    80002c5e:	1000                	add	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c60:	fffff097          	auipc	ra,0xfffff
    80002c64:	d96080e7          	jalr	-618(ra) # 800019f6 <myproc>
    80002c68:	84aa                	mv	s1,a0
  num = p->trapframe->a7;
    80002c6a:	05853903          	ld	s2,88(a0)
    80002c6e:	0a893783          	ld	a5,168(s2)
    80002c72:	0007869b          	sext.w	a3,a5
  
  /* Adil: debugging */
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002c76:	37fd                	addw	a5,a5,-1
    80002c78:	4751                	li	a4,20
    80002c7a:	00f76f63          	bltu	a4,a5,80002c98 <syscall+0x44>
    80002c7e:	00369713          	sll	a4,a3,0x3
    80002c82:	00006797          	auipc	a5,0x6
    80002c86:	80e78793          	add	a5,a5,-2034 # 80008490 <syscalls>
    80002c8a:	97ba                	add	a5,a5,a4
    80002c8c:	639c                	ld	a5,0(a5)
    80002c8e:	c789                	beqz	a5,80002c98 <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002c90:	9782                	jalr	a5
    80002c92:	06a93823          	sd	a0,112(s2)
    80002c96:	a839                	j	80002cb4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002c98:	15848613          	add	a2,s1,344
    80002c9c:	588c                	lw	a1,48(s1)
    80002c9e:	00005517          	auipc	a0,0x5
    80002ca2:	7ba50513          	add	a0,a0,1978 # 80008458 <states.0+0x150>
    80002ca6:	ffffe097          	auipc	ra,0xffffe
    80002caa:	8e0080e7          	jalr	-1824(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002cae:	6cbc                	ld	a5,88(s1)
    80002cb0:	577d                	li	a4,-1
    80002cb2:	fbb8                	sd	a4,112(a5)
  }
}
    80002cb4:	60e2                	ld	ra,24(sp)
    80002cb6:	6442                	ld	s0,16(sp)
    80002cb8:	64a2                	ld	s1,8(sp)
    80002cba:	6902                	ld	s2,0(sp)
    80002cbc:	6105                	add	sp,sp,32
    80002cbe:	8082                	ret

0000000080002cc0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cc0:	1101                	add	sp,sp,-32
    80002cc2:	ec06                	sd	ra,24(sp)
    80002cc4:	e822                	sd	s0,16(sp)
    80002cc6:	1000                	add	s0,sp,32
  int n;
  argint(0, &n);
    80002cc8:	fec40593          	add	a1,s0,-20
    80002ccc:	4501                	li	a0,0
    80002cce:	00000097          	auipc	ra,0x0
    80002cd2:	f0e080e7          	jalr	-242(ra) # 80002bdc <argint>
  exit(n);
    80002cd6:	fec42503          	lw	a0,-20(s0)
    80002cda:	fffff097          	auipc	ra,0xfffff
    80002cde:	56c080e7          	jalr	1388(ra) # 80002246 <exit>
  return 0;  // not reached
}
    80002ce2:	4501                	li	a0,0
    80002ce4:	60e2                	ld	ra,24(sp)
    80002ce6:	6442                	ld	s0,16(sp)
    80002ce8:	6105                	add	sp,sp,32
    80002cea:	8082                	ret

0000000080002cec <sys_getpid>:

uint64
sys_getpid(void)
{
    80002cec:	1141                	add	sp,sp,-16
    80002cee:	e406                	sd	ra,8(sp)
    80002cf0:	e022                	sd	s0,0(sp)
    80002cf2:	0800                	add	s0,sp,16
  return myproc()->pid;
    80002cf4:	fffff097          	auipc	ra,0xfffff
    80002cf8:	d02080e7          	jalr	-766(ra) # 800019f6 <myproc>
}
    80002cfc:	5908                	lw	a0,48(a0)
    80002cfe:	60a2                	ld	ra,8(sp)
    80002d00:	6402                	ld	s0,0(sp)
    80002d02:	0141                	add	sp,sp,16
    80002d04:	8082                	ret

0000000080002d06 <sys_fork>:

uint64
sys_fork(void)
{
    80002d06:	1141                	add	sp,sp,-16
    80002d08:	e406                	sd	ra,8(sp)
    80002d0a:	e022                	sd	s0,0(sp)
    80002d0c:	0800                	add	s0,sp,16
  return fork();
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	0f4080e7          	jalr	244(ra) # 80001e02 <fork>
}
    80002d16:	60a2                	ld	ra,8(sp)
    80002d18:	6402                	ld	s0,0(sp)
    80002d1a:	0141                	add	sp,sp,16
    80002d1c:	8082                	ret

0000000080002d1e <sys_wait>:

uint64
sys_wait(void)
{
    80002d1e:	1101                	add	sp,sp,-32
    80002d20:	ec06                	sd	ra,24(sp)
    80002d22:	e822                	sd	s0,16(sp)
    80002d24:	1000                	add	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d26:	fe840593          	add	a1,s0,-24
    80002d2a:	4501                	li	a0,0
    80002d2c:	00000097          	auipc	ra,0x0
    80002d30:	ed0080e7          	jalr	-304(ra) # 80002bfc <argaddr>
  return wait(p);
    80002d34:	fe843503          	ld	a0,-24(s0)
    80002d38:	fffff097          	auipc	ra,0xfffff
    80002d3c:	6bc080e7          	jalr	1724(ra) # 800023f4 <wait>
}
    80002d40:	60e2                	ld	ra,24(sp)
    80002d42:	6442                	ld	s0,16(sp)
    80002d44:	6105                	add	sp,sp,32
    80002d46:	8082                	ret

0000000080002d48 <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d48:	7179                	add	sp,sp,-48
    80002d4a:	f406                	sd	ra,40(sp)
    80002d4c:	f022                	sd	s0,32(sp)
    80002d4e:	ec26                	sd	s1,24(sp)
    80002d50:	1800                	add	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d52:	fdc40593          	add	a1,s0,-36
    80002d56:	4501                	li	a0,0
    80002d58:	00000097          	auipc	ra,0x0
    80002d5c:	e84080e7          	jalr	-380(ra) # 80002bdc <argint>
  addr = myproc()->sz;
    80002d60:	fffff097          	auipc	ra,0xfffff
    80002d64:	c96080e7          	jalr	-874(ra) # 800019f6 <myproc>
    80002d68:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d6a:	fdc42503          	lw	a0,-36(s0)
    80002d6e:	fffff097          	auipc	ra,0xfffff
    80002d72:	030080e7          	jalr	48(ra) # 80001d9e <growproc>
    80002d76:	00054863          	bltz	a0,80002d86 <sys_sbrk+0x3e>
    return -1;

  return addr;
}
    80002d7a:	8526                	mv	a0,s1
    80002d7c:	70a2                	ld	ra,40(sp)
    80002d7e:	7402                	ld	s0,32(sp)
    80002d80:	64e2                	ld	s1,24(sp)
    80002d82:	6145                	add	sp,sp,48
    80002d84:	8082                	ret
    return -1;
    80002d86:	54fd                	li	s1,-1
    80002d88:	bfcd                	j	80002d7a <sys_sbrk+0x32>

0000000080002d8a <sys_sleep>:

uint64
sys_sleep(void)
{
    80002d8a:	7139                	add	sp,sp,-64
    80002d8c:	fc06                	sd	ra,56(sp)
    80002d8e:	f822                	sd	s0,48(sp)
    80002d90:	f426                	sd	s1,40(sp)
    80002d92:	f04a                	sd	s2,32(sp)
    80002d94:	ec4e                	sd	s3,24(sp)
    80002d96:	0080                	add	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002d98:	fcc40593          	add	a1,s0,-52
    80002d9c:	4501                	li	a0,0
    80002d9e:	00000097          	auipc	ra,0x0
    80002da2:	e3e080e7          	jalr	-450(ra) # 80002bdc <argint>
  acquire(&tickslock);
    80002da6:	0018b517          	auipc	a0,0x18b
    80002daa:	1ba50513          	add	a0,a0,442 # 8018df60 <tickslock>
    80002dae:	ffffe097          	auipc	ra,0xffffe
    80002db2:	e24080e7          	jalr	-476(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002db6:	00006917          	auipc	s2,0x6
    80002dba:	d0a92903          	lw	s2,-758(s2) # 80008ac0 <ticks>
  while(ticks - ticks0 < n){
    80002dbe:	fcc42783          	lw	a5,-52(s0)
    80002dc2:	cf9d                	beqz	a5,80002e00 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002dc4:	0018b997          	auipc	s3,0x18b
    80002dc8:	19c98993          	add	s3,s3,412 # 8018df60 <tickslock>
    80002dcc:	00006497          	auipc	s1,0x6
    80002dd0:	cf448493          	add	s1,s1,-780 # 80008ac0 <ticks>
    if(killed(myproc())){
    80002dd4:	fffff097          	auipc	ra,0xfffff
    80002dd8:	c22080e7          	jalr	-990(ra) # 800019f6 <myproc>
    80002ddc:	fffff097          	auipc	ra,0xfffff
    80002de0:	5e6080e7          	jalr	1510(ra) # 800023c2 <killed>
    80002de4:	ed15                	bnez	a0,80002e20 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002de6:	85ce                	mv	a1,s3
    80002de8:	8526                	mv	a0,s1
    80002dea:	fffff097          	auipc	ra,0xfffff
    80002dee:	318080e7          	jalr	792(ra) # 80002102 <sleep>
  while(ticks - ticks0 < n){
    80002df2:	409c                	lw	a5,0(s1)
    80002df4:	412787bb          	subw	a5,a5,s2
    80002df8:	fcc42703          	lw	a4,-52(s0)
    80002dfc:	fce7ece3          	bltu	a5,a4,80002dd4 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e00:	0018b517          	auipc	a0,0x18b
    80002e04:	16050513          	add	a0,a0,352 # 8018df60 <tickslock>
    80002e08:	ffffe097          	auipc	ra,0xffffe
    80002e0c:	e7e080e7          	jalr	-386(ra) # 80000c86 <release>
  return 0;
    80002e10:	4501                	li	a0,0
}
    80002e12:	70e2                	ld	ra,56(sp)
    80002e14:	7442                	ld	s0,48(sp)
    80002e16:	74a2                	ld	s1,40(sp)
    80002e18:	7902                	ld	s2,32(sp)
    80002e1a:	69e2                	ld	s3,24(sp)
    80002e1c:	6121                	add	sp,sp,64
    80002e1e:	8082                	ret
      release(&tickslock);
    80002e20:	0018b517          	auipc	a0,0x18b
    80002e24:	14050513          	add	a0,a0,320 # 8018df60 <tickslock>
    80002e28:	ffffe097          	auipc	ra,0xffffe
    80002e2c:	e5e080e7          	jalr	-418(ra) # 80000c86 <release>
      return -1;
    80002e30:	557d                	li	a0,-1
    80002e32:	b7c5                	j	80002e12 <sys_sleep+0x88>

0000000080002e34 <sys_kill>:

uint64
sys_kill(void)
{
    80002e34:	1101                	add	sp,sp,-32
    80002e36:	ec06                	sd	ra,24(sp)
    80002e38:	e822                	sd	s0,16(sp)
    80002e3a:	1000                	add	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e3c:	fec40593          	add	a1,s0,-20
    80002e40:	4501                	li	a0,0
    80002e42:	00000097          	auipc	ra,0x0
    80002e46:	d9a080e7          	jalr	-614(ra) # 80002bdc <argint>
  return kill(pid);
    80002e4a:	fec42503          	lw	a0,-20(s0)
    80002e4e:	fffff097          	auipc	ra,0xfffff
    80002e52:	4ce080e7          	jalr	1230(ra) # 8000231c <kill>
}
    80002e56:	60e2                	ld	ra,24(sp)
    80002e58:	6442                	ld	s0,16(sp)
    80002e5a:	6105                	add	sp,sp,32
    80002e5c:	8082                	ret

0000000080002e5e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e5e:	1101                	add	sp,sp,-32
    80002e60:	ec06                	sd	ra,24(sp)
    80002e62:	e822                	sd	s0,16(sp)
    80002e64:	e426                	sd	s1,8(sp)
    80002e66:	1000                	add	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e68:	0018b517          	auipc	a0,0x18b
    80002e6c:	0f850513          	add	a0,a0,248 # 8018df60 <tickslock>
    80002e70:	ffffe097          	auipc	ra,0xffffe
    80002e74:	d62080e7          	jalr	-670(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002e78:	00006497          	auipc	s1,0x6
    80002e7c:	c484a483          	lw	s1,-952(s1) # 80008ac0 <ticks>
  release(&tickslock);
    80002e80:	0018b517          	auipc	a0,0x18b
    80002e84:	0e050513          	add	a0,a0,224 # 8018df60 <tickslock>
    80002e88:	ffffe097          	auipc	ra,0xffffe
    80002e8c:	dfe080e7          	jalr	-514(ra) # 80000c86 <release>
  return xticks;
}
    80002e90:	02049513          	sll	a0,s1,0x20
    80002e94:	9101                	srl	a0,a0,0x20
    80002e96:	60e2                	ld	ra,24(sp)
    80002e98:	6442                	ld	s0,16(sp)
    80002e9a:	64a2                	ld	s1,8(sp)
    80002e9c:	6105                	add	sp,sp,32
    80002e9e:	8082                	ret

0000000080002ea0 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ea0:	7179                	add	sp,sp,-48
    80002ea2:	f406                	sd	ra,40(sp)
    80002ea4:	f022                	sd	s0,32(sp)
    80002ea6:	ec26                	sd	s1,24(sp)
    80002ea8:	e84a                	sd	s2,16(sp)
    80002eaa:	e44e                	sd	s3,8(sp)
    80002eac:	e052                	sd	s4,0(sp)
    80002eae:	1800                	add	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002eb0:	00005597          	auipc	a1,0x5
    80002eb4:	69058593          	add	a1,a1,1680 # 80008540 <syscalls+0xb0>
    80002eb8:	0018b517          	auipc	a0,0x18b
    80002ebc:	0c050513          	add	a0,a0,192 # 8018df78 <bcache>
    80002ec0:	ffffe097          	auipc	ra,0xffffe
    80002ec4:	c82080e7          	jalr	-894(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002ec8:	00193797          	auipc	a5,0x193
    80002ecc:	0b078793          	add	a5,a5,176 # 80195f78 <bcache+0x8000>
    80002ed0:	00193717          	auipc	a4,0x193
    80002ed4:	31070713          	add	a4,a4,784 # 801961e0 <bcache+0x8268>
    80002ed8:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002edc:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002ee0:	0018b497          	auipc	s1,0x18b
    80002ee4:	0b048493          	add	s1,s1,176 # 8018df90 <bcache+0x18>
    b->next = bcache.head.next;
    80002ee8:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002eea:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002eec:	00005a17          	auipc	s4,0x5
    80002ef0:	65ca0a13          	add	s4,s4,1628 # 80008548 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002ef4:	2b893783          	ld	a5,696(s2)
    80002ef8:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002efa:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002efe:	85d2                	mv	a1,s4
    80002f00:	01048513          	add	a0,s1,16
    80002f04:	00001097          	auipc	ra,0x1
    80002f08:	496080e7          	jalr	1174(ra) # 8000439a <initsleeplock>
    bcache.head.next->prev = b;
    80002f0c:	2b893783          	ld	a5,696(s2)
    80002f10:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002f12:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002f16:	45848493          	add	s1,s1,1112
    80002f1a:	fd349de3          	bne	s1,s3,80002ef4 <binit+0x54>
  }
}
    80002f1e:	70a2                	ld	ra,40(sp)
    80002f20:	7402                	ld	s0,32(sp)
    80002f22:	64e2                	ld	s1,24(sp)
    80002f24:	6942                	ld	s2,16(sp)
    80002f26:	69a2                	ld	s3,8(sp)
    80002f28:	6a02                	ld	s4,0(sp)
    80002f2a:	6145                	add	sp,sp,48
    80002f2c:	8082                	ret

0000000080002f2e <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002f2e:	7179                	add	sp,sp,-48
    80002f30:	f406                	sd	ra,40(sp)
    80002f32:	f022                	sd	s0,32(sp)
    80002f34:	ec26                	sd	s1,24(sp)
    80002f36:	e84a                	sd	s2,16(sp)
    80002f38:	e44e                	sd	s3,8(sp)
    80002f3a:	1800                	add	s0,sp,48
    80002f3c:	892a                	mv	s2,a0
    80002f3e:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002f40:	0018b517          	auipc	a0,0x18b
    80002f44:	03850513          	add	a0,a0,56 # 8018df78 <bcache>
    80002f48:	ffffe097          	auipc	ra,0xffffe
    80002f4c:	c8a080e7          	jalr	-886(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002f50:	00193497          	auipc	s1,0x193
    80002f54:	2e04b483          	ld	s1,736(s1) # 80196230 <bcache+0x82b8>
    80002f58:	00193797          	auipc	a5,0x193
    80002f5c:	28878793          	add	a5,a5,648 # 801961e0 <bcache+0x8268>
    80002f60:	02f48f63          	beq	s1,a5,80002f9e <bread+0x70>
    80002f64:	873e                	mv	a4,a5
    80002f66:	a021                	j	80002f6e <bread+0x40>
    80002f68:	68a4                	ld	s1,80(s1)
    80002f6a:	02e48a63          	beq	s1,a4,80002f9e <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002f6e:	449c                	lw	a5,8(s1)
    80002f70:	ff279ce3          	bne	a5,s2,80002f68 <bread+0x3a>
    80002f74:	44dc                	lw	a5,12(s1)
    80002f76:	ff3799e3          	bne	a5,s3,80002f68 <bread+0x3a>
      b->refcnt++;
    80002f7a:	40bc                	lw	a5,64(s1)
    80002f7c:	2785                	addw	a5,a5,1
    80002f7e:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002f80:	0018b517          	auipc	a0,0x18b
    80002f84:	ff850513          	add	a0,a0,-8 # 8018df78 <bcache>
    80002f88:	ffffe097          	auipc	ra,0xffffe
    80002f8c:	cfe080e7          	jalr	-770(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002f90:	01048513          	add	a0,s1,16
    80002f94:	00001097          	auipc	ra,0x1
    80002f98:	440080e7          	jalr	1088(ra) # 800043d4 <acquiresleep>
      return b;
    80002f9c:	a8b9                	j	80002ffa <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002f9e:	00193497          	auipc	s1,0x193
    80002fa2:	28a4b483          	ld	s1,650(s1) # 80196228 <bcache+0x82b0>
    80002fa6:	00193797          	auipc	a5,0x193
    80002faa:	23a78793          	add	a5,a5,570 # 801961e0 <bcache+0x8268>
    80002fae:	00f48863          	beq	s1,a5,80002fbe <bread+0x90>
    80002fb2:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002fb4:	40bc                	lw	a5,64(s1)
    80002fb6:	cf81                	beqz	a5,80002fce <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002fb8:	64a4                	ld	s1,72(s1)
    80002fba:	fee49de3          	bne	s1,a4,80002fb4 <bread+0x86>
  panic("bget: no buffers");
    80002fbe:	00005517          	auipc	a0,0x5
    80002fc2:	59250513          	add	a0,a0,1426 # 80008550 <syscalls+0xc0>
    80002fc6:	ffffd097          	auipc	ra,0xffffd
    80002fca:	576080e7          	jalr	1398(ra) # 8000053c <panic>
      b->dev = dev;
    80002fce:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002fd2:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002fd6:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002fda:	4785                	li	a5,1
    80002fdc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002fde:	0018b517          	auipc	a0,0x18b
    80002fe2:	f9a50513          	add	a0,a0,-102 # 8018df78 <bcache>
    80002fe6:	ffffe097          	auipc	ra,0xffffe
    80002fea:	ca0080e7          	jalr	-864(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002fee:	01048513          	add	a0,s1,16
    80002ff2:	00001097          	auipc	ra,0x1
    80002ff6:	3e2080e7          	jalr	994(ra) # 800043d4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ffa:	409c                	lw	a5,0(s1)
    80002ffc:	cb89                	beqz	a5,8000300e <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ffe:	8526                	mv	a0,s1
    80003000:	70a2                	ld	ra,40(sp)
    80003002:	7402                	ld	s0,32(sp)
    80003004:	64e2                	ld	s1,24(sp)
    80003006:	6942                	ld	s2,16(sp)
    80003008:	69a2                	ld	s3,8(sp)
    8000300a:	6145                	add	sp,sp,48
    8000300c:	8082                	ret
    virtio_disk_rw(b, 0);
    8000300e:	4581                	li	a1,0
    80003010:	8526                	mv	a0,s1
    80003012:	00003097          	auipc	ra,0x3
    80003016:	000080e7          	jalr	ra # 80006012 <virtio_disk_rw>
    b->valid = 1;
    8000301a:	4785                	li	a5,1
    8000301c:	c09c                	sw	a5,0(s1)
  return b;
    8000301e:	b7c5                	j	80002ffe <bread+0xd0>

0000000080003020 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80003020:	1101                	add	sp,sp,-32
    80003022:	ec06                	sd	ra,24(sp)
    80003024:	e822                	sd	s0,16(sp)
    80003026:	e426                	sd	s1,8(sp)
    80003028:	1000                	add	s0,sp,32
    8000302a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000302c:	0541                	add	a0,a0,16
    8000302e:	00001097          	auipc	ra,0x1
    80003032:	440080e7          	jalr	1088(ra) # 8000446e <holdingsleep>
    80003036:	cd01                	beqz	a0,8000304e <bwrite+0x2e>
    panic("bwrite");

  virtio_disk_rw(b, 1);
    80003038:	4585                	li	a1,1
    8000303a:	8526                	mv	a0,s1
    8000303c:	00003097          	auipc	ra,0x3
    80003040:	fd6080e7          	jalr	-42(ra) # 80006012 <virtio_disk_rw>
}
    80003044:	60e2                	ld	ra,24(sp)
    80003046:	6442                	ld	s0,16(sp)
    80003048:	64a2                	ld	s1,8(sp)
    8000304a:	6105                	add	sp,sp,32
    8000304c:	8082                	ret
    panic("bwrite");
    8000304e:	00005517          	auipc	a0,0x5
    80003052:	51a50513          	add	a0,a0,1306 # 80008568 <syscalls+0xd8>
    80003056:	ffffd097          	auipc	ra,0xffffd
    8000305a:	4e6080e7          	jalr	1254(ra) # 8000053c <panic>

000000008000305e <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    8000305e:	1101                	add	sp,sp,-32
    80003060:	ec06                	sd	ra,24(sp)
    80003062:	e822                	sd	s0,16(sp)
    80003064:	e426                	sd	s1,8(sp)
    80003066:	e04a                	sd	s2,0(sp)
    80003068:	1000                	add	s0,sp,32
    8000306a:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    8000306c:	01050913          	add	s2,a0,16
    80003070:	854a                	mv	a0,s2
    80003072:	00001097          	auipc	ra,0x1
    80003076:	3fc080e7          	jalr	1020(ra) # 8000446e <holdingsleep>
    8000307a:	c925                	beqz	a0,800030ea <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    8000307c:	854a                	mv	a0,s2
    8000307e:	00001097          	auipc	ra,0x1
    80003082:	3ac080e7          	jalr	940(ra) # 8000442a <releasesleep>

  acquire(&bcache.lock);
    80003086:	0018b517          	auipc	a0,0x18b
    8000308a:	ef250513          	add	a0,a0,-270 # 8018df78 <bcache>
    8000308e:	ffffe097          	auipc	ra,0xffffe
    80003092:	b44080e7          	jalr	-1212(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003096:	40bc                	lw	a5,64(s1)
    80003098:	37fd                	addw	a5,a5,-1
    8000309a:	0007871b          	sext.w	a4,a5
    8000309e:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800030a0:	e71d                	bnez	a4,800030ce <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800030a2:	68b8                	ld	a4,80(s1)
    800030a4:	64bc                	ld	a5,72(s1)
    800030a6:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    800030a8:	68b8                	ld	a4,80(s1)
    800030aa:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    800030ac:	00193797          	auipc	a5,0x193
    800030b0:	ecc78793          	add	a5,a5,-308 # 80195f78 <bcache+0x8000>
    800030b4:	2b87b703          	ld	a4,696(a5)
    800030b8:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    800030ba:	00193717          	auipc	a4,0x193
    800030be:	12670713          	add	a4,a4,294 # 801961e0 <bcache+0x8268>
    800030c2:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    800030c4:	2b87b703          	ld	a4,696(a5)
    800030c8:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800030ca:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800030ce:	0018b517          	auipc	a0,0x18b
    800030d2:	eaa50513          	add	a0,a0,-342 # 8018df78 <bcache>
    800030d6:	ffffe097          	auipc	ra,0xffffe
    800030da:	bb0080e7          	jalr	-1104(ra) # 80000c86 <release>
}
    800030de:	60e2                	ld	ra,24(sp)
    800030e0:	6442                	ld	s0,16(sp)
    800030e2:	64a2                	ld	s1,8(sp)
    800030e4:	6902                	ld	s2,0(sp)
    800030e6:	6105                	add	sp,sp,32
    800030e8:	8082                	ret
    panic("brelse");
    800030ea:	00005517          	auipc	a0,0x5
    800030ee:	48650513          	add	a0,a0,1158 # 80008570 <syscalls+0xe0>
    800030f2:	ffffd097          	auipc	ra,0xffffd
    800030f6:	44a080e7          	jalr	1098(ra) # 8000053c <panic>

00000000800030fa <bpin>:

void
bpin(struct buf *b) {
    800030fa:	1101                	add	sp,sp,-32
    800030fc:	ec06                	sd	ra,24(sp)
    800030fe:	e822                	sd	s0,16(sp)
    80003100:	e426                	sd	s1,8(sp)
    80003102:	1000                	add	s0,sp,32
    80003104:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003106:	0018b517          	auipc	a0,0x18b
    8000310a:	e7250513          	add	a0,a0,-398 # 8018df78 <bcache>
    8000310e:	ffffe097          	auipc	ra,0xffffe
    80003112:	ac4080e7          	jalr	-1340(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80003116:	40bc                	lw	a5,64(s1)
    80003118:	2785                	addw	a5,a5,1
    8000311a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000311c:	0018b517          	auipc	a0,0x18b
    80003120:	e5c50513          	add	a0,a0,-420 # 8018df78 <bcache>
    80003124:	ffffe097          	auipc	ra,0xffffe
    80003128:	b62080e7          	jalr	-1182(ra) # 80000c86 <release>
}
    8000312c:	60e2                	ld	ra,24(sp)
    8000312e:	6442                	ld	s0,16(sp)
    80003130:	64a2                	ld	s1,8(sp)
    80003132:	6105                	add	sp,sp,32
    80003134:	8082                	ret

0000000080003136 <bunpin>:

void
bunpin(struct buf *b) {
    80003136:	1101                	add	sp,sp,-32
    80003138:	ec06                	sd	ra,24(sp)
    8000313a:	e822                	sd	s0,16(sp)
    8000313c:	e426                	sd	s1,8(sp)
    8000313e:	1000                	add	s0,sp,32
    80003140:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003142:	0018b517          	auipc	a0,0x18b
    80003146:	e3650513          	add	a0,a0,-458 # 8018df78 <bcache>
    8000314a:	ffffe097          	auipc	ra,0xffffe
    8000314e:	a88080e7          	jalr	-1400(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003152:	40bc                	lw	a5,64(s1)
    80003154:	37fd                	addw	a5,a5,-1
    80003156:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003158:	0018b517          	auipc	a0,0x18b
    8000315c:	e2050513          	add	a0,a0,-480 # 8018df78 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	b26080e7          	jalr	-1242(ra) # 80000c86 <release>
}
    80003168:	60e2                	ld	ra,24(sp)
    8000316a:	6442                	ld	s0,16(sp)
    8000316c:	64a2                	ld	s1,8(sp)
    8000316e:	6105                	add	sp,sp,32
    80003170:	8082                	ret

0000000080003172 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003172:	1101                	add	sp,sp,-32
    80003174:	ec06                	sd	ra,24(sp)
    80003176:	e822                	sd	s0,16(sp)
    80003178:	e426                	sd	s1,8(sp)
    8000317a:	e04a                	sd	s2,0(sp)
    8000317c:	1000                	add	s0,sp,32
    8000317e:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003180:	00d5d59b          	srlw	a1,a1,0xd
    80003184:	00193797          	auipc	a5,0x193
    80003188:	4d07a783          	lw	a5,1232(a5) # 80196654 <sb+0x1c>
    8000318c:	9dbd                	addw	a1,a1,a5
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	da0080e7          	jalr	-608(ra) # 80002f2e <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003196:	0074f713          	and	a4,s1,7
    8000319a:	4785                	li	a5,1
    8000319c:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    800031a0:	14ce                	sll	s1,s1,0x33
    800031a2:	90d9                	srl	s1,s1,0x36
    800031a4:	00950733          	add	a4,a0,s1
    800031a8:	05874703          	lbu	a4,88(a4)
    800031ac:	00e7f6b3          	and	a3,a5,a4
    800031b0:	c69d                	beqz	a3,800031de <bfree+0x6c>
    800031b2:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    800031b4:	94aa                	add	s1,s1,a0
    800031b6:	fff7c793          	not	a5,a5
    800031ba:	8f7d                	and	a4,a4,a5
    800031bc:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800031c0:	00001097          	auipc	ra,0x1
    800031c4:	0f6080e7          	jalr	246(ra) # 800042b6 <log_write>
  brelse(bp);
    800031c8:	854a                	mv	a0,s2
    800031ca:	00000097          	auipc	ra,0x0
    800031ce:	e94080e7          	jalr	-364(ra) # 8000305e <brelse>
}
    800031d2:	60e2                	ld	ra,24(sp)
    800031d4:	6442                	ld	s0,16(sp)
    800031d6:	64a2                	ld	s1,8(sp)
    800031d8:	6902                	ld	s2,0(sp)
    800031da:	6105                	add	sp,sp,32
    800031dc:	8082                	ret
    panic("freeing free block");
    800031de:	00005517          	auipc	a0,0x5
    800031e2:	39a50513          	add	a0,a0,922 # 80008578 <syscalls+0xe8>
    800031e6:	ffffd097          	auipc	ra,0xffffd
    800031ea:	356080e7          	jalr	854(ra) # 8000053c <panic>

00000000800031ee <balloc>:
{
    800031ee:	711d                	add	sp,sp,-96
    800031f0:	ec86                	sd	ra,88(sp)
    800031f2:	e8a2                	sd	s0,80(sp)
    800031f4:	e4a6                	sd	s1,72(sp)
    800031f6:	e0ca                	sd	s2,64(sp)
    800031f8:	fc4e                	sd	s3,56(sp)
    800031fa:	f852                	sd	s4,48(sp)
    800031fc:	f456                	sd	s5,40(sp)
    800031fe:	f05a                	sd	s6,32(sp)
    80003200:	ec5e                	sd	s7,24(sp)
    80003202:	e862                	sd	s8,16(sp)
    80003204:	e466                	sd	s9,8(sp)
    80003206:	1080                	add	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80003208:	00193797          	auipc	a5,0x193
    8000320c:	4347a783          	lw	a5,1076(a5) # 8019663c <sb+0x4>
    80003210:	cff5                	beqz	a5,8000330c <balloc+0x11e>
    80003212:	8baa                	mv	s7,a0
    80003214:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80003216:	00193b17          	auipc	s6,0x193
    8000321a:	422b0b13          	add	s6,s6,1058 # 80196638 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000321e:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003220:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003222:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003224:	6c89                	lui	s9,0x2
    80003226:	a061                	j	800032ae <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003228:	97ca                	add	a5,a5,s2
    8000322a:	8e55                	or	a2,a2,a3
    8000322c:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003230:	854a                	mv	a0,s2
    80003232:	00001097          	auipc	ra,0x1
    80003236:	084080e7          	jalr	132(ra) # 800042b6 <log_write>
        brelse(bp);
    8000323a:	854a                	mv	a0,s2
    8000323c:	00000097          	auipc	ra,0x0
    80003240:	e22080e7          	jalr	-478(ra) # 8000305e <brelse>
  bp = bread(dev, bno);
    80003244:	85a6                	mv	a1,s1
    80003246:	855e                	mv	a0,s7
    80003248:	00000097          	auipc	ra,0x0
    8000324c:	ce6080e7          	jalr	-794(ra) # 80002f2e <bread>
    80003250:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003252:	40000613          	li	a2,1024
    80003256:	4581                	li	a1,0
    80003258:	05850513          	add	a0,a0,88
    8000325c:	ffffe097          	auipc	ra,0xffffe
    80003260:	a72080e7          	jalr	-1422(ra) # 80000cce <memset>
  log_write(bp);
    80003264:	854a                	mv	a0,s2
    80003266:	00001097          	auipc	ra,0x1
    8000326a:	050080e7          	jalr	80(ra) # 800042b6 <log_write>
  brelse(bp);
    8000326e:	854a                	mv	a0,s2
    80003270:	00000097          	auipc	ra,0x0
    80003274:	dee080e7          	jalr	-530(ra) # 8000305e <brelse>
}
    80003278:	8526                	mv	a0,s1
    8000327a:	60e6                	ld	ra,88(sp)
    8000327c:	6446                	ld	s0,80(sp)
    8000327e:	64a6                	ld	s1,72(sp)
    80003280:	6906                	ld	s2,64(sp)
    80003282:	79e2                	ld	s3,56(sp)
    80003284:	7a42                	ld	s4,48(sp)
    80003286:	7aa2                	ld	s5,40(sp)
    80003288:	7b02                	ld	s6,32(sp)
    8000328a:	6be2                	ld	s7,24(sp)
    8000328c:	6c42                	ld	s8,16(sp)
    8000328e:	6ca2                	ld	s9,8(sp)
    80003290:	6125                	add	sp,sp,96
    80003292:	8082                	ret
    brelse(bp);
    80003294:	854a                	mv	a0,s2
    80003296:	00000097          	auipc	ra,0x0
    8000329a:	dc8080e7          	jalr	-568(ra) # 8000305e <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000329e:	015c87bb          	addw	a5,s9,s5
    800032a2:	00078a9b          	sext.w	s5,a5
    800032a6:	004b2703          	lw	a4,4(s6)
    800032aa:	06eaf163          	bgeu	s5,a4,8000330c <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    800032ae:	41fad79b          	sraw	a5,s5,0x1f
    800032b2:	0137d79b          	srlw	a5,a5,0x13
    800032b6:	015787bb          	addw	a5,a5,s5
    800032ba:	40d7d79b          	sraw	a5,a5,0xd
    800032be:	01cb2583          	lw	a1,28(s6)
    800032c2:	9dbd                	addw	a1,a1,a5
    800032c4:	855e                	mv	a0,s7
    800032c6:	00000097          	auipc	ra,0x0
    800032ca:	c68080e7          	jalr	-920(ra) # 80002f2e <bread>
    800032ce:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800032d0:	004b2503          	lw	a0,4(s6)
    800032d4:	000a849b          	sext.w	s1,s5
    800032d8:	8762                	mv	a4,s8
    800032da:	faa4fde3          	bgeu	s1,a0,80003294 <balloc+0xa6>
      m = 1 << (bi % 8);
    800032de:	00777693          	and	a3,a4,7
    800032e2:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800032e6:	41f7579b          	sraw	a5,a4,0x1f
    800032ea:	01d7d79b          	srlw	a5,a5,0x1d
    800032ee:	9fb9                	addw	a5,a5,a4
    800032f0:	4037d79b          	sraw	a5,a5,0x3
    800032f4:	00f90633          	add	a2,s2,a5
    800032f8:	05864603          	lbu	a2,88(a2)
    800032fc:	00c6f5b3          	and	a1,a3,a2
    80003300:	d585                	beqz	a1,80003228 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003302:	2705                	addw	a4,a4,1
    80003304:	2485                	addw	s1,s1,1
    80003306:	fd471ae3          	bne	a4,s4,800032da <balloc+0xec>
    8000330a:	b769                	j	80003294 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    8000330c:	00005517          	auipc	a0,0x5
    80003310:	28450513          	add	a0,a0,644 # 80008590 <syscalls+0x100>
    80003314:	ffffd097          	auipc	ra,0xffffd
    80003318:	272080e7          	jalr	626(ra) # 80000586 <printf>
  return 0;
    8000331c:	4481                	li	s1,0
    8000331e:	bfa9                	j	80003278 <balloc+0x8a>

0000000080003320 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003320:	7179                	add	sp,sp,-48
    80003322:	f406                	sd	ra,40(sp)
    80003324:	f022                	sd	s0,32(sp)
    80003326:	ec26                	sd	s1,24(sp)
    80003328:	e84a                	sd	s2,16(sp)
    8000332a:	e44e                	sd	s3,8(sp)
    8000332c:	e052                	sd	s4,0(sp)
    8000332e:	1800                	add	s0,sp,48
    80003330:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003332:	47ad                	li	a5,11
    80003334:	02b7e863          	bltu	a5,a1,80003364 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003338:	02059793          	sll	a5,a1,0x20
    8000333c:	01e7d593          	srl	a1,a5,0x1e
    80003340:	00b504b3          	add	s1,a0,a1
    80003344:	0504a903          	lw	s2,80(s1)
    80003348:	06091e63          	bnez	s2,800033c4 <bmap+0xa4>
      addr = balloc(ip->dev);
    8000334c:	4108                	lw	a0,0(a0)
    8000334e:	00000097          	auipc	ra,0x0
    80003352:	ea0080e7          	jalr	-352(ra) # 800031ee <balloc>
    80003356:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000335a:	06090563          	beqz	s2,800033c4 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    8000335e:	0524a823          	sw	s2,80(s1)
    80003362:	a08d                	j	800033c4 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003364:	ff45849b          	addw	s1,a1,-12
    80003368:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    8000336c:	0ff00793          	li	a5,255
    80003370:	08e7e563          	bltu	a5,a4,800033fa <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003374:	08052903          	lw	s2,128(a0)
    80003378:	00091d63          	bnez	s2,80003392 <bmap+0x72>
      addr = balloc(ip->dev);
    8000337c:	4108                	lw	a0,0(a0)
    8000337e:	00000097          	auipc	ra,0x0
    80003382:	e70080e7          	jalr	-400(ra) # 800031ee <balloc>
    80003386:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000338a:	02090d63          	beqz	s2,800033c4 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    8000338e:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003392:	85ca                	mv	a1,s2
    80003394:	0009a503          	lw	a0,0(s3)
    80003398:	00000097          	auipc	ra,0x0
    8000339c:	b96080e7          	jalr	-1130(ra) # 80002f2e <bread>
    800033a0:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800033a2:	05850793          	add	a5,a0,88
    if((addr = a[bn]) == 0){
    800033a6:	02049713          	sll	a4,s1,0x20
    800033aa:	01e75593          	srl	a1,a4,0x1e
    800033ae:	00b784b3          	add	s1,a5,a1
    800033b2:	0004a903          	lw	s2,0(s1)
    800033b6:	02090063          	beqz	s2,800033d6 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    800033ba:	8552                	mv	a0,s4
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	ca2080e7          	jalr	-862(ra) # 8000305e <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800033c4:	854a                	mv	a0,s2
    800033c6:	70a2                	ld	ra,40(sp)
    800033c8:	7402                	ld	s0,32(sp)
    800033ca:	64e2                	ld	s1,24(sp)
    800033cc:	6942                	ld	s2,16(sp)
    800033ce:	69a2                	ld	s3,8(sp)
    800033d0:	6a02                	ld	s4,0(sp)
    800033d2:	6145                	add	sp,sp,48
    800033d4:	8082                	ret
      addr = balloc(ip->dev);
    800033d6:	0009a503          	lw	a0,0(s3)
    800033da:	00000097          	auipc	ra,0x0
    800033de:	e14080e7          	jalr	-492(ra) # 800031ee <balloc>
    800033e2:	0005091b          	sext.w	s2,a0
      if(addr){
    800033e6:	fc090ae3          	beqz	s2,800033ba <bmap+0x9a>
        a[bn] = addr;
    800033ea:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800033ee:	8552                	mv	a0,s4
    800033f0:	00001097          	auipc	ra,0x1
    800033f4:	ec6080e7          	jalr	-314(ra) # 800042b6 <log_write>
    800033f8:	b7c9                	j	800033ba <bmap+0x9a>
  panic("bmap: out of range");
    800033fa:	00005517          	auipc	a0,0x5
    800033fe:	1ae50513          	add	a0,a0,430 # 800085a8 <syscalls+0x118>
    80003402:	ffffd097          	auipc	ra,0xffffd
    80003406:	13a080e7          	jalr	314(ra) # 8000053c <panic>

000000008000340a <iget>:
{
    8000340a:	7179                	add	sp,sp,-48
    8000340c:	f406                	sd	ra,40(sp)
    8000340e:	f022                	sd	s0,32(sp)
    80003410:	ec26                	sd	s1,24(sp)
    80003412:	e84a                	sd	s2,16(sp)
    80003414:	e44e                	sd	s3,8(sp)
    80003416:	e052                	sd	s4,0(sp)
    80003418:	1800                	add	s0,sp,48
    8000341a:	89aa                	mv	s3,a0
    8000341c:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    8000341e:	00193517          	auipc	a0,0x193
    80003422:	24250513          	add	a0,a0,578 # 80196660 <itable>
    80003426:	ffffd097          	auipc	ra,0xffffd
    8000342a:	7ac080e7          	jalr	1964(ra) # 80000bd2 <acquire>
  empty = 0;
    8000342e:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003430:	00193497          	auipc	s1,0x193
    80003434:	24848493          	add	s1,s1,584 # 80196678 <itable+0x18>
    80003438:	00195697          	auipc	a3,0x195
    8000343c:	cd068693          	add	a3,a3,-816 # 80198108 <log>
    80003440:	a039                	j	8000344e <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003442:	02090b63          	beqz	s2,80003478 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003446:	08848493          	add	s1,s1,136
    8000344a:	02d48a63          	beq	s1,a3,8000347e <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    8000344e:	449c                	lw	a5,8(s1)
    80003450:	fef059e3          	blez	a5,80003442 <iget+0x38>
    80003454:	4098                	lw	a4,0(s1)
    80003456:	ff3716e3          	bne	a4,s3,80003442 <iget+0x38>
    8000345a:	40d8                	lw	a4,4(s1)
    8000345c:	ff4713e3          	bne	a4,s4,80003442 <iget+0x38>
      ip->ref++;
    80003460:	2785                	addw	a5,a5,1
    80003462:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003464:	00193517          	auipc	a0,0x193
    80003468:	1fc50513          	add	a0,a0,508 # 80196660 <itable>
    8000346c:	ffffe097          	auipc	ra,0xffffe
    80003470:	81a080e7          	jalr	-2022(ra) # 80000c86 <release>
      return ip;
    80003474:	8926                	mv	s2,s1
    80003476:	a03d                	j	800034a4 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003478:	f7f9                	bnez	a5,80003446 <iget+0x3c>
    8000347a:	8926                	mv	s2,s1
    8000347c:	b7e9                	j	80003446 <iget+0x3c>
  if(empty == 0)
    8000347e:	02090c63          	beqz	s2,800034b6 <iget+0xac>
  ip->dev = dev;
    80003482:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003486:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000348a:	4785                	li	a5,1
    8000348c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003490:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003494:	00193517          	auipc	a0,0x193
    80003498:	1cc50513          	add	a0,a0,460 # 80196660 <itable>
    8000349c:	ffffd097          	auipc	ra,0xffffd
    800034a0:	7ea080e7          	jalr	2026(ra) # 80000c86 <release>
}
    800034a4:	854a                	mv	a0,s2
    800034a6:	70a2                	ld	ra,40(sp)
    800034a8:	7402                	ld	s0,32(sp)
    800034aa:	64e2                	ld	s1,24(sp)
    800034ac:	6942                	ld	s2,16(sp)
    800034ae:	69a2                	ld	s3,8(sp)
    800034b0:	6a02                	ld	s4,0(sp)
    800034b2:	6145                	add	sp,sp,48
    800034b4:	8082                	ret
    panic("iget: no inodes");
    800034b6:	00005517          	auipc	a0,0x5
    800034ba:	10a50513          	add	a0,a0,266 # 800085c0 <syscalls+0x130>
    800034be:	ffffd097          	auipc	ra,0xffffd
    800034c2:	07e080e7          	jalr	126(ra) # 8000053c <panic>

00000000800034c6 <fsinit>:
fsinit(int dev) {
    800034c6:	7179                	add	sp,sp,-48
    800034c8:	f406                	sd	ra,40(sp)
    800034ca:	f022                	sd	s0,32(sp)
    800034cc:	ec26                	sd	s1,24(sp)
    800034ce:	e84a                	sd	s2,16(sp)
    800034d0:	e44e                	sd	s3,8(sp)
    800034d2:	1800                	add	s0,sp,48
    800034d4:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800034d6:	4585                	li	a1,1
    800034d8:	00000097          	auipc	ra,0x0
    800034dc:	a56080e7          	jalr	-1450(ra) # 80002f2e <bread>
    800034e0:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800034e2:	00193997          	auipc	s3,0x193
    800034e6:	15698993          	add	s3,s3,342 # 80196638 <sb>
    800034ea:	02800613          	li	a2,40
    800034ee:	05850593          	add	a1,a0,88
    800034f2:	854e                	mv	a0,s3
    800034f4:	ffffe097          	auipc	ra,0xffffe
    800034f8:	836080e7          	jalr	-1994(ra) # 80000d2a <memmove>
  brelse(bp);
    800034fc:	8526                	mv	a0,s1
    800034fe:	00000097          	auipc	ra,0x0
    80003502:	b60080e7          	jalr	-1184(ra) # 8000305e <brelse>
  if(sb.magic != FSMAGIC)
    80003506:	0009a703          	lw	a4,0(s3)
    8000350a:	102037b7          	lui	a5,0x10203
    8000350e:	04078793          	add	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80003512:	02f71263          	bne	a4,a5,80003536 <fsinit+0x70>
  initlog(dev, &sb);
    80003516:	00193597          	auipc	a1,0x193
    8000351a:	12258593          	add	a1,a1,290 # 80196638 <sb>
    8000351e:	854a                	mv	a0,s2
    80003520:	00001097          	auipc	ra,0x1
    80003524:	b2c080e7          	jalr	-1236(ra) # 8000404c <initlog>
}
    80003528:	70a2                	ld	ra,40(sp)
    8000352a:	7402                	ld	s0,32(sp)
    8000352c:	64e2                	ld	s1,24(sp)
    8000352e:	6942                	ld	s2,16(sp)
    80003530:	69a2                	ld	s3,8(sp)
    80003532:	6145                	add	sp,sp,48
    80003534:	8082                	ret
    panic("invalid file system");
    80003536:	00005517          	auipc	a0,0x5
    8000353a:	09a50513          	add	a0,a0,154 # 800085d0 <syscalls+0x140>
    8000353e:	ffffd097          	auipc	ra,0xffffd
    80003542:	ffe080e7          	jalr	-2(ra) # 8000053c <panic>

0000000080003546 <iinit>:
{
    80003546:	7179                	add	sp,sp,-48
    80003548:	f406                	sd	ra,40(sp)
    8000354a:	f022                	sd	s0,32(sp)
    8000354c:	ec26                	sd	s1,24(sp)
    8000354e:	e84a                	sd	s2,16(sp)
    80003550:	e44e                	sd	s3,8(sp)
    80003552:	1800                	add	s0,sp,48
  initlock(&itable.lock, "itable");
    80003554:	00005597          	auipc	a1,0x5
    80003558:	09458593          	add	a1,a1,148 # 800085e8 <syscalls+0x158>
    8000355c:	00193517          	auipc	a0,0x193
    80003560:	10450513          	add	a0,a0,260 # 80196660 <itable>
    80003564:	ffffd097          	auipc	ra,0xffffd
    80003568:	5de080e7          	jalr	1502(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    8000356c:	00193497          	auipc	s1,0x193
    80003570:	11c48493          	add	s1,s1,284 # 80196688 <itable+0x28>
    80003574:	00195997          	auipc	s3,0x195
    80003578:	ba498993          	add	s3,s3,-1116 # 80198118 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    8000357c:	00005917          	auipc	s2,0x5
    80003580:	07490913          	add	s2,s2,116 # 800085f0 <syscalls+0x160>
    80003584:	85ca                	mv	a1,s2
    80003586:	8526                	mv	a0,s1
    80003588:	00001097          	auipc	ra,0x1
    8000358c:	e12080e7          	jalr	-494(ra) # 8000439a <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003590:	08848493          	add	s1,s1,136
    80003594:	ff3498e3          	bne	s1,s3,80003584 <iinit+0x3e>
}
    80003598:	70a2                	ld	ra,40(sp)
    8000359a:	7402                	ld	s0,32(sp)
    8000359c:	64e2                	ld	s1,24(sp)
    8000359e:	6942                	ld	s2,16(sp)
    800035a0:	69a2                	ld	s3,8(sp)
    800035a2:	6145                	add	sp,sp,48
    800035a4:	8082                	ret

00000000800035a6 <ialloc>:
{
    800035a6:	7139                	add	sp,sp,-64
    800035a8:	fc06                	sd	ra,56(sp)
    800035aa:	f822                	sd	s0,48(sp)
    800035ac:	f426                	sd	s1,40(sp)
    800035ae:	f04a                	sd	s2,32(sp)
    800035b0:	ec4e                	sd	s3,24(sp)
    800035b2:	e852                	sd	s4,16(sp)
    800035b4:	e456                	sd	s5,8(sp)
    800035b6:	e05a                	sd	s6,0(sp)
    800035b8:	0080                	add	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    800035ba:	00193717          	auipc	a4,0x193
    800035be:	08a72703          	lw	a4,138(a4) # 80196644 <sb+0xc>
    800035c2:	4785                	li	a5,1
    800035c4:	04e7f863          	bgeu	a5,a4,80003614 <ialloc+0x6e>
    800035c8:	8aaa                	mv	s5,a0
    800035ca:	8b2e                	mv	s6,a1
    800035cc:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800035ce:	00193a17          	auipc	s4,0x193
    800035d2:	06aa0a13          	add	s4,s4,106 # 80196638 <sb>
    800035d6:	00495593          	srl	a1,s2,0x4
    800035da:	018a2783          	lw	a5,24(s4)
    800035de:	9dbd                	addw	a1,a1,a5
    800035e0:	8556                	mv	a0,s5
    800035e2:	00000097          	auipc	ra,0x0
    800035e6:	94c080e7          	jalr	-1716(ra) # 80002f2e <bread>
    800035ea:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800035ec:	05850993          	add	s3,a0,88
    800035f0:	00f97793          	and	a5,s2,15
    800035f4:	079a                	sll	a5,a5,0x6
    800035f6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800035f8:	00099783          	lh	a5,0(s3)
    800035fc:	cf9d                	beqz	a5,8000363a <ialloc+0x94>
    brelse(bp);
    800035fe:	00000097          	auipc	ra,0x0
    80003602:	a60080e7          	jalr	-1440(ra) # 8000305e <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80003606:	0905                	add	s2,s2,1
    80003608:	00ca2703          	lw	a4,12(s4)
    8000360c:	0009079b          	sext.w	a5,s2
    80003610:	fce7e3e3          	bltu	a5,a4,800035d6 <ialloc+0x30>
  printf("ialloc: no inodes\n");
    80003614:	00005517          	auipc	a0,0x5
    80003618:	fe450513          	add	a0,a0,-28 # 800085f8 <syscalls+0x168>
    8000361c:	ffffd097          	auipc	ra,0xffffd
    80003620:	f6a080e7          	jalr	-150(ra) # 80000586 <printf>
  return 0;
    80003624:	4501                	li	a0,0
}
    80003626:	70e2                	ld	ra,56(sp)
    80003628:	7442                	ld	s0,48(sp)
    8000362a:	74a2                	ld	s1,40(sp)
    8000362c:	7902                	ld	s2,32(sp)
    8000362e:	69e2                	ld	s3,24(sp)
    80003630:	6a42                	ld	s4,16(sp)
    80003632:	6aa2                	ld	s5,8(sp)
    80003634:	6b02                	ld	s6,0(sp)
    80003636:	6121                	add	sp,sp,64
    80003638:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000363a:	04000613          	li	a2,64
    8000363e:	4581                	li	a1,0
    80003640:	854e                	mv	a0,s3
    80003642:	ffffd097          	auipc	ra,0xffffd
    80003646:	68c080e7          	jalr	1676(ra) # 80000cce <memset>
      dip->type = type;
    8000364a:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    8000364e:	8526                	mv	a0,s1
    80003650:	00001097          	auipc	ra,0x1
    80003654:	c66080e7          	jalr	-922(ra) # 800042b6 <log_write>
      brelse(bp);
    80003658:	8526                	mv	a0,s1
    8000365a:	00000097          	auipc	ra,0x0
    8000365e:	a04080e7          	jalr	-1532(ra) # 8000305e <brelse>
      return iget(dev, inum);
    80003662:	0009059b          	sext.w	a1,s2
    80003666:	8556                	mv	a0,s5
    80003668:	00000097          	auipc	ra,0x0
    8000366c:	da2080e7          	jalr	-606(ra) # 8000340a <iget>
    80003670:	bf5d                	j	80003626 <ialloc+0x80>

0000000080003672 <iupdate>:
{
    80003672:	1101                	add	sp,sp,-32
    80003674:	ec06                	sd	ra,24(sp)
    80003676:	e822                	sd	s0,16(sp)
    80003678:	e426                	sd	s1,8(sp)
    8000367a:	e04a                	sd	s2,0(sp)
    8000367c:	1000                	add	s0,sp,32
    8000367e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003680:	415c                	lw	a5,4(a0)
    80003682:	0047d79b          	srlw	a5,a5,0x4
    80003686:	00193597          	auipc	a1,0x193
    8000368a:	fca5a583          	lw	a1,-54(a1) # 80196650 <sb+0x18>
    8000368e:	9dbd                	addw	a1,a1,a5
    80003690:	4108                	lw	a0,0(a0)
    80003692:	00000097          	auipc	ra,0x0
    80003696:	89c080e7          	jalr	-1892(ra) # 80002f2e <bread>
    8000369a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000369c:	05850793          	add	a5,a0,88
    800036a0:	40d8                	lw	a4,4(s1)
    800036a2:	8b3d                	and	a4,a4,15
    800036a4:	071a                	sll	a4,a4,0x6
    800036a6:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    800036a8:	04449703          	lh	a4,68(s1)
    800036ac:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    800036b0:	04649703          	lh	a4,70(s1)
    800036b4:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    800036b8:	04849703          	lh	a4,72(s1)
    800036bc:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800036c0:	04a49703          	lh	a4,74(s1)
    800036c4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800036c8:	44f8                	lw	a4,76(s1)
    800036ca:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800036cc:	03400613          	li	a2,52
    800036d0:	05048593          	add	a1,s1,80
    800036d4:	00c78513          	add	a0,a5,12
    800036d8:	ffffd097          	auipc	ra,0xffffd
    800036dc:	652080e7          	jalr	1618(ra) # 80000d2a <memmove>
  log_write(bp);
    800036e0:	854a                	mv	a0,s2
    800036e2:	00001097          	auipc	ra,0x1
    800036e6:	bd4080e7          	jalr	-1068(ra) # 800042b6 <log_write>
  brelse(bp);
    800036ea:	854a                	mv	a0,s2
    800036ec:	00000097          	auipc	ra,0x0
    800036f0:	972080e7          	jalr	-1678(ra) # 8000305e <brelse>
}
    800036f4:	60e2                	ld	ra,24(sp)
    800036f6:	6442                	ld	s0,16(sp)
    800036f8:	64a2                	ld	s1,8(sp)
    800036fa:	6902                	ld	s2,0(sp)
    800036fc:	6105                	add	sp,sp,32
    800036fe:	8082                	ret

0000000080003700 <idup>:
{
    80003700:	1101                	add	sp,sp,-32
    80003702:	ec06                	sd	ra,24(sp)
    80003704:	e822                	sd	s0,16(sp)
    80003706:	e426                	sd	s1,8(sp)
    80003708:	1000                	add	s0,sp,32
    8000370a:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000370c:	00193517          	auipc	a0,0x193
    80003710:	f5450513          	add	a0,a0,-172 # 80196660 <itable>
    80003714:	ffffd097          	auipc	ra,0xffffd
    80003718:	4be080e7          	jalr	1214(ra) # 80000bd2 <acquire>
  ip->ref++;
    8000371c:	449c                	lw	a5,8(s1)
    8000371e:	2785                	addw	a5,a5,1
    80003720:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003722:	00193517          	auipc	a0,0x193
    80003726:	f3e50513          	add	a0,a0,-194 # 80196660 <itable>
    8000372a:	ffffd097          	auipc	ra,0xffffd
    8000372e:	55c080e7          	jalr	1372(ra) # 80000c86 <release>
}
    80003732:	8526                	mv	a0,s1
    80003734:	60e2                	ld	ra,24(sp)
    80003736:	6442                	ld	s0,16(sp)
    80003738:	64a2                	ld	s1,8(sp)
    8000373a:	6105                	add	sp,sp,32
    8000373c:	8082                	ret

000000008000373e <ilock>:
{
    8000373e:	1101                	add	sp,sp,-32
    80003740:	ec06                	sd	ra,24(sp)
    80003742:	e822                	sd	s0,16(sp)
    80003744:	e426                	sd	s1,8(sp)
    80003746:	e04a                	sd	s2,0(sp)
    80003748:	1000                	add	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000374a:	c115                	beqz	a0,8000376e <ilock+0x30>
    8000374c:	84aa                	mv	s1,a0
    8000374e:	451c                	lw	a5,8(a0)
    80003750:	00f05f63          	blez	a5,8000376e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003754:	0541                	add	a0,a0,16
    80003756:	00001097          	auipc	ra,0x1
    8000375a:	c7e080e7          	jalr	-898(ra) # 800043d4 <acquiresleep>
  if(ip->valid == 0){
    8000375e:	40bc                	lw	a5,64(s1)
    80003760:	cf99                	beqz	a5,8000377e <ilock+0x40>
}
    80003762:	60e2                	ld	ra,24(sp)
    80003764:	6442                	ld	s0,16(sp)
    80003766:	64a2                	ld	s1,8(sp)
    80003768:	6902                	ld	s2,0(sp)
    8000376a:	6105                	add	sp,sp,32
    8000376c:	8082                	ret
    panic("ilock");
    8000376e:	00005517          	auipc	a0,0x5
    80003772:	ea250513          	add	a0,a0,-350 # 80008610 <syscalls+0x180>
    80003776:	ffffd097          	auipc	ra,0xffffd
    8000377a:	dc6080e7          	jalr	-570(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000377e:	40dc                	lw	a5,4(s1)
    80003780:	0047d79b          	srlw	a5,a5,0x4
    80003784:	00193597          	auipc	a1,0x193
    80003788:	ecc5a583          	lw	a1,-308(a1) # 80196650 <sb+0x18>
    8000378c:	9dbd                	addw	a1,a1,a5
    8000378e:	4088                	lw	a0,0(s1)
    80003790:	fffff097          	auipc	ra,0xfffff
    80003794:	79e080e7          	jalr	1950(ra) # 80002f2e <bread>
    80003798:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000379a:	05850593          	add	a1,a0,88
    8000379e:	40dc                	lw	a5,4(s1)
    800037a0:	8bbd                	and	a5,a5,15
    800037a2:	079a                	sll	a5,a5,0x6
    800037a4:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800037a6:	00059783          	lh	a5,0(a1)
    800037aa:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800037ae:	00259783          	lh	a5,2(a1)
    800037b2:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    800037b6:	00459783          	lh	a5,4(a1)
    800037ba:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800037be:	00659783          	lh	a5,6(a1)
    800037c2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800037c6:	459c                	lw	a5,8(a1)
    800037c8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800037ca:	03400613          	li	a2,52
    800037ce:	05b1                	add	a1,a1,12
    800037d0:	05048513          	add	a0,s1,80
    800037d4:	ffffd097          	auipc	ra,0xffffd
    800037d8:	556080e7          	jalr	1366(ra) # 80000d2a <memmove>
    brelse(bp);
    800037dc:	854a                	mv	a0,s2
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	880080e7          	jalr	-1920(ra) # 8000305e <brelse>
    ip->valid = 1;
    800037e6:	4785                	li	a5,1
    800037e8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800037ea:	04449783          	lh	a5,68(s1)
    800037ee:	fbb5                	bnez	a5,80003762 <ilock+0x24>
      panic("ilock: no type");
    800037f0:	00005517          	auipc	a0,0x5
    800037f4:	e2850513          	add	a0,a0,-472 # 80008618 <syscalls+0x188>
    800037f8:	ffffd097          	auipc	ra,0xffffd
    800037fc:	d44080e7          	jalr	-700(ra) # 8000053c <panic>

0000000080003800 <iunlock>:
{
    80003800:	1101                	add	sp,sp,-32
    80003802:	ec06                	sd	ra,24(sp)
    80003804:	e822                	sd	s0,16(sp)
    80003806:	e426                	sd	s1,8(sp)
    80003808:	e04a                	sd	s2,0(sp)
    8000380a:	1000                	add	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000380c:	c905                	beqz	a0,8000383c <iunlock+0x3c>
    8000380e:	84aa                	mv	s1,a0
    80003810:	01050913          	add	s2,a0,16
    80003814:	854a                	mv	a0,s2
    80003816:	00001097          	auipc	ra,0x1
    8000381a:	c58080e7          	jalr	-936(ra) # 8000446e <holdingsleep>
    8000381e:	cd19                	beqz	a0,8000383c <iunlock+0x3c>
    80003820:	449c                	lw	a5,8(s1)
    80003822:	00f05d63          	blez	a5,8000383c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003826:	854a                	mv	a0,s2
    80003828:	00001097          	auipc	ra,0x1
    8000382c:	c02080e7          	jalr	-1022(ra) # 8000442a <releasesleep>
}
    80003830:	60e2                	ld	ra,24(sp)
    80003832:	6442                	ld	s0,16(sp)
    80003834:	64a2                	ld	s1,8(sp)
    80003836:	6902                	ld	s2,0(sp)
    80003838:	6105                	add	sp,sp,32
    8000383a:	8082                	ret
    panic("iunlock");
    8000383c:	00005517          	auipc	a0,0x5
    80003840:	dec50513          	add	a0,a0,-532 # 80008628 <syscalls+0x198>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	cf8080e7          	jalr	-776(ra) # 8000053c <panic>

000000008000384c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    8000384c:	7179                	add	sp,sp,-48
    8000384e:	f406                	sd	ra,40(sp)
    80003850:	f022                	sd	s0,32(sp)
    80003852:	ec26                	sd	s1,24(sp)
    80003854:	e84a                	sd	s2,16(sp)
    80003856:	e44e                	sd	s3,8(sp)
    80003858:	e052                	sd	s4,0(sp)
    8000385a:	1800                	add	s0,sp,48
    8000385c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    8000385e:	05050493          	add	s1,a0,80
    80003862:	08050913          	add	s2,a0,128
    80003866:	a021                	j	8000386e <itrunc+0x22>
    80003868:	0491                	add	s1,s1,4
    8000386a:	01248d63          	beq	s1,s2,80003884 <itrunc+0x38>
    if(ip->addrs[i]){
    8000386e:	408c                	lw	a1,0(s1)
    80003870:	dde5                	beqz	a1,80003868 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003872:	0009a503          	lw	a0,0(s3)
    80003876:	00000097          	auipc	ra,0x0
    8000387a:	8fc080e7          	jalr	-1796(ra) # 80003172 <bfree>
      ip->addrs[i] = 0;
    8000387e:	0004a023          	sw	zero,0(s1)
    80003882:	b7dd                	j	80003868 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003884:	0809a583          	lw	a1,128(s3)
    80003888:	e185                	bnez	a1,800038a8 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000388a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    8000388e:	854e                	mv	a0,s3
    80003890:	00000097          	auipc	ra,0x0
    80003894:	de2080e7          	jalr	-542(ra) # 80003672 <iupdate>
}
    80003898:	70a2                	ld	ra,40(sp)
    8000389a:	7402                	ld	s0,32(sp)
    8000389c:	64e2                	ld	s1,24(sp)
    8000389e:	6942                	ld	s2,16(sp)
    800038a0:	69a2                	ld	s3,8(sp)
    800038a2:	6a02                	ld	s4,0(sp)
    800038a4:	6145                	add	sp,sp,48
    800038a6:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800038a8:	0009a503          	lw	a0,0(s3)
    800038ac:	fffff097          	auipc	ra,0xfffff
    800038b0:	682080e7          	jalr	1666(ra) # 80002f2e <bread>
    800038b4:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800038b6:	05850493          	add	s1,a0,88
    800038ba:	45850913          	add	s2,a0,1112
    800038be:	a021                	j	800038c6 <itrunc+0x7a>
    800038c0:	0491                	add	s1,s1,4
    800038c2:	01248b63          	beq	s1,s2,800038d8 <itrunc+0x8c>
      if(a[j])
    800038c6:	408c                	lw	a1,0(s1)
    800038c8:	dde5                	beqz	a1,800038c0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800038ca:	0009a503          	lw	a0,0(s3)
    800038ce:	00000097          	auipc	ra,0x0
    800038d2:	8a4080e7          	jalr	-1884(ra) # 80003172 <bfree>
    800038d6:	b7ed                	j	800038c0 <itrunc+0x74>
    brelse(bp);
    800038d8:	8552                	mv	a0,s4
    800038da:	fffff097          	auipc	ra,0xfffff
    800038de:	784080e7          	jalr	1924(ra) # 8000305e <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800038e2:	0809a583          	lw	a1,128(s3)
    800038e6:	0009a503          	lw	a0,0(s3)
    800038ea:	00000097          	auipc	ra,0x0
    800038ee:	888080e7          	jalr	-1912(ra) # 80003172 <bfree>
    ip->addrs[NDIRECT] = 0;
    800038f2:	0809a023          	sw	zero,128(s3)
    800038f6:	bf51                	j	8000388a <itrunc+0x3e>

00000000800038f8 <iput>:
{
    800038f8:	1101                	add	sp,sp,-32
    800038fa:	ec06                	sd	ra,24(sp)
    800038fc:	e822                	sd	s0,16(sp)
    800038fe:	e426                	sd	s1,8(sp)
    80003900:	e04a                	sd	s2,0(sp)
    80003902:	1000                	add	s0,sp,32
    80003904:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003906:	00193517          	auipc	a0,0x193
    8000390a:	d5a50513          	add	a0,a0,-678 # 80196660 <itable>
    8000390e:	ffffd097          	auipc	ra,0xffffd
    80003912:	2c4080e7          	jalr	708(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003916:	4498                	lw	a4,8(s1)
    80003918:	4785                	li	a5,1
    8000391a:	02f70363          	beq	a4,a5,80003940 <iput+0x48>
  ip->ref--;
    8000391e:	449c                	lw	a5,8(s1)
    80003920:	37fd                	addw	a5,a5,-1
    80003922:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003924:	00193517          	auipc	a0,0x193
    80003928:	d3c50513          	add	a0,a0,-708 # 80196660 <itable>
    8000392c:	ffffd097          	auipc	ra,0xffffd
    80003930:	35a080e7          	jalr	858(ra) # 80000c86 <release>
}
    80003934:	60e2                	ld	ra,24(sp)
    80003936:	6442                	ld	s0,16(sp)
    80003938:	64a2                	ld	s1,8(sp)
    8000393a:	6902                	ld	s2,0(sp)
    8000393c:	6105                	add	sp,sp,32
    8000393e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003940:	40bc                	lw	a5,64(s1)
    80003942:	dff1                	beqz	a5,8000391e <iput+0x26>
    80003944:	04a49783          	lh	a5,74(s1)
    80003948:	fbf9                	bnez	a5,8000391e <iput+0x26>
    acquiresleep(&ip->lock);
    8000394a:	01048913          	add	s2,s1,16
    8000394e:	854a                	mv	a0,s2
    80003950:	00001097          	auipc	ra,0x1
    80003954:	a84080e7          	jalr	-1404(ra) # 800043d4 <acquiresleep>
    release(&itable.lock);
    80003958:	00193517          	auipc	a0,0x193
    8000395c:	d0850513          	add	a0,a0,-760 # 80196660 <itable>
    80003960:	ffffd097          	auipc	ra,0xffffd
    80003964:	326080e7          	jalr	806(ra) # 80000c86 <release>
    itrunc(ip);
    80003968:	8526                	mv	a0,s1
    8000396a:	00000097          	auipc	ra,0x0
    8000396e:	ee2080e7          	jalr	-286(ra) # 8000384c <itrunc>
    ip->type = 0;
    80003972:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003976:	8526                	mv	a0,s1
    80003978:	00000097          	auipc	ra,0x0
    8000397c:	cfa080e7          	jalr	-774(ra) # 80003672 <iupdate>
    ip->valid = 0;
    80003980:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003984:	854a                	mv	a0,s2
    80003986:	00001097          	auipc	ra,0x1
    8000398a:	aa4080e7          	jalr	-1372(ra) # 8000442a <releasesleep>
    acquire(&itable.lock);
    8000398e:	00193517          	auipc	a0,0x193
    80003992:	cd250513          	add	a0,a0,-814 # 80196660 <itable>
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	23c080e7          	jalr	572(ra) # 80000bd2 <acquire>
    8000399e:	b741                	j	8000391e <iput+0x26>

00000000800039a0 <iunlockput>:
{
    800039a0:	1101                	add	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	1000                	add	s0,sp,32
    800039aa:	84aa                	mv	s1,a0
  iunlock(ip);
    800039ac:	00000097          	auipc	ra,0x0
    800039b0:	e54080e7          	jalr	-428(ra) # 80003800 <iunlock>
  iput(ip);
    800039b4:	8526                	mv	a0,s1
    800039b6:	00000097          	auipc	ra,0x0
    800039ba:	f42080e7          	jalr	-190(ra) # 800038f8 <iput>
}
    800039be:	60e2                	ld	ra,24(sp)
    800039c0:	6442                	ld	s0,16(sp)
    800039c2:	64a2                	ld	s1,8(sp)
    800039c4:	6105                	add	sp,sp,32
    800039c6:	8082                	ret

00000000800039c8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800039c8:	1141                	add	sp,sp,-16
    800039ca:	e422                	sd	s0,8(sp)
    800039cc:	0800                	add	s0,sp,16
  st->dev = ip->dev;
    800039ce:	411c                	lw	a5,0(a0)
    800039d0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800039d2:	415c                	lw	a5,4(a0)
    800039d4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800039d6:	04451783          	lh	a5,68(a0)
    800039da:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800039de:	04a51783          	lh	a5,74(a0)
    800039e2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800039e6:	04c56783          	lwu	a5,76(a0)
    800039ea:	e99c                	sd	a5,16(a1)
}
    800039ec:	6422                	ld	s0,8(sp)
    800039ee:	0141                	add	sp,sp,16
    800039f0:	8082                	ret

00000000800039f2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039f2:	457c                	lw	a5,76(a0)
    800039f4:	0ed7e963          	bltu	a5,a3,80003ae6 <readi+0xf4>
{
    800039f8:	7159                	add	sp,sp,-112
    800039fa:	f486                	sd	ra,104(sp)
    800039fc:	f0a2                	sd	s0,96(sp)
    800039fe:	eca6                	sd	s1,88(sp)
    80003a00:	e8ca                	sd	s2,80(sp)
    80003a02:	e4ce                	sd	s3,72(sp)
    80003a04:	e0d2                	sd	s4,64(sp)
    80003a06:	fc56                	sd	s5,56(sp)
    80003a08:	f85a                	sd	s6,48(sp)
    80003a0a:	f45e                	sd	s7,40(sp)
    80003a0c:	f062                	sd	s8,32(sp)
    80003a0e:	ec66                	sd	s9,24(sp)
    80003a10:	e86a                	sd	s10,16(sp)
    80003a12:	e46e                	sd	s11,8(sp)
    80003a14:	1880                	add	s0,sp,112
    80003a16:	8b2a                	mv	s6,a0
    80003a18:	8bae                	mv	s7,a1
    80003a1a:	8a32                	mv	s4,a2
    80003a1c:	84b6                	mv	s1,a3
    80003a1e:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003a20:	9f35                	addw	a4,a4,a3
    return 0;
    80003a22:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003a24:	0ad76063          	bltu	a4,a3,80003ac4 <readi+0xd2>
  if(off + n > ip->size)
    80003a28:	00e7f463          	bgeu	a5,a4,80003a30 <readi+0x3e>
    n = ip->size - off;
    80003a2c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a30:	0a0a8963          	beqz	s5,80003ae2 <readi+0xf0>
    80003a34:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a36:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003a3a:	5c7d                	li	s8,-1
    80003a3c:	a82d                	j	80003a76 <readi+0x84>
    80003a3e:	020d1d93          	sll	s11,s10,0x20
    80003a42:	020ddd93          	srl	s11,s11,0x20
    80003a46:	05890613          	add	a2,s2,88
    80003a4a:	86ee                	mv	a3,s11
    80003a4c:	963a                	add	a2,a2,a4
    80003a4e:	85d2                	mv	a1,s4
    80003a50:	855e                	mv	a0,s7
    80003a52:	fffff097          	auipc	ra,0xfffff
    80003a56:	acc080e7          	jalr	-1332(ra) # 8000251e <either_copyout>
    80003a5a:	05850d63          	beq	a0,s8,80003ab4 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003a5e:	854a                	mv	a0,s2
    80003a60:	fffff097          	auipc	ra,0xfffff
    80003a64:	5fe080e7          	jalr	1534(ra) # 8000305e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003a68:	013d09bb          	addw	s3,s10,s3
    80003a6c:	009d04bb          	addw	s1,s10,s1
    80003a70:	9a6e                	add	s4,s4,s11
    80003a72:	0559f763          	bgeu	s3,s5,80003ac0 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003a76:	00a4d59b          	srlw	a1,s1,0xa
    80003a7a:	855a                	mv	a0,s6
    80003a7c:	00000097          	auipc	ra,0x0
    80003a80:	8a4080e7          	jalr	-1884(ra) # 80003320 <bmap>
    80003a84:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a88:	cd85                	beqz	a1,80003ac0 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003a8a:	000b2503          	lw	a0,0(s6)
    80003a8e:	fffff097          	auipc	ra,0xfffff
    80003a92:	4a0080e7          	jalr	1184(ra) # 80002f2e <bread>
    80003a96:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a98:	3ff4f713          	and	a4,s1,1023
    80003a9c:	40ec87bb          	subw	a5,s9,a4
    80003aa0:	413a86bb          	subw	a3,s5,s3
    80003aa4:	8d3e                	mv	s10,a5
    80003aa6:	2781                	sext.w	a5,a5
    80003aa8:	0006861b          	sext.w	a2,a3
    80003aac:	f8f679e3          	bgeu	a2,a5,80003a3e <readi+0x4c>
    80003ab0:	8d36                	mv	s10,a3
    80003ab2:	b771                	j	80003a3e <readi+0x4c>
      brelse(bp);
    80003ab4:	854a                	mv	a0,s2
    80003ab6:	fffff097          	auipc	ra,0xfffff
    80003aba:	5a8080e7          	jalr	1448(ra) # 8000305e <brelse>
      tot = -1;
    80003abe:	59fd                	li	s3,-1
  }
  return tot;
    80003ac0:	0009851b          	sext.w	a0,s3
}
    80003ac4:	70a6                	ld	ra,104(sp)
    80003ac6:	7406                	ld	s0,96(sp)
    80003ac8:	64e6                	ld	s1,88(sp)
    80003aca:	6946                	ld	s2,80(sp)
    80003acc:	69a6                	ld	s3,72(sp)
    80003ace:	6a06                	ld	s4,64(sp)
    80003ad0:	7ae2                	ld	s5,56(sp)
    80003ad2:	7b42                	ld	s6,48(sp)
    80003ad4:	7ba2                	ld	s7,40(sp)
    80003ad6:	7c02                	ld	s8,32(sp)
    80003ad8:	6ce2                	ld	s9,24(sp)
    80003ada:	6d42                	ld	s10,16(sp)
    80003adc:	6da2                	ld	s11,8(sp)
    80003ade:	6165                	add	sp,sp,112
    80003ae0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003ae2:	89d6                	mv	s3,s5
    80003ae4:	bff1                	j	80003ac0 <readi+0xce>
    return 0;
    80003ae6:	4501                	li	a0,0
}
    80003ae8:	8082                	ret

0000000080003aea <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003aea:	457c                	lw	a5,76(a0)
    80003aec:	10d7e863          	bltu	a5,a3,80003bfc <writei+0x112>
{
    80003af0:	7159                	add	sp,sp,-112
    80003af2:	f486                	sd	ra,104(sp)
    80003af4:	f0a2                	sd	s0,96(sp)
    80003af6:	eca6                	sd	s1,88(sp)
    80003af8:	e8ca                	sd	s2,80(sp)
    80003afa:	e4ce                	sd	s3,72(sp)
    80003afc:	e0d2                	sd	s4,64(sp)
    80003afe:	fc56                	sd	s5,56(sp)
    80003b00:	f85a                	sd	s6,48(sp)
    80003b02:	f45e                	sd	s7,40(sp)
    80003b04:	f062                	sd	s8,32(sp)
    80003b06:	ec66                	sd	s9,24(sp)
    80003b08:	e86a                	sd	s10,16(sp)
    80003b0a:	e46e                	sd	s11,8(sp)
    80003b0c:	1880                	add	s0,sp,112
    80003b0e:	8aaa                	mv	s5,a0
    80003b10:	8bae                	mv	s7,a1
    80003b12:	8a32                	mv	s4,a2
    80003b14:	8936                	mv	s2,a3
    80003b16:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003b18:	00e687bb          	addw	a5,a3,a4
    80003b1c:	0ed7e263          	bltu	a5,a3,80003c00 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003b20:	00043737          	lui	a4,0x43
    80003b24:	0ef76063          	bltu	a4,a5,80003c04 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b28:	0c0b0863          	beqz	s6,80003bf8 <writei+0x10e>
    80003b2c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b2e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003b32:	5c7d                	li	s8,-1
    80003b34:	a091                	j	80003b78 <writei+0x8e>
    80003b36:	020d1d93          	sll	s11,s10,0x20
    80003b3a:	020ddd93          	srl	s11,s11,0x20
    80003b3e:	05848513          	add	a0,s1,88
    80003b42:	86ee                	mv	a3,s11
    80003b44:	8652                	mv	a2,s4
    80003b46:	85de                	mv	a1,s7
    80003b48:	953a                	add	a0,a0,a4
    80003b4a:	fffff097          	auipc	ra,0xfffff
    80003b4e:	a2a080e7          	jalr	-1494(ra) # 80002574 <either_copyin>
    80003b52:	07850263          	beq	a0,s8,80003bb6 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003b56:	8526                	mv	a0,s1
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	75e080e7          	jalr	1886(ra) # 800042b6 <log_write>
    brelse(bp);
    80003b60:	8526                	mv	a0,s1
    80003b62:	fffff097          	auipc	ra,0xfffff
    80003b66:	4fc080e7          	jalr	1276(ra) # 8000305e <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003b6a:	013d09bb          	addw	s3,s10,s3
    80003b6e:	012d093b          	addw	s2,s10,s2
    80003b72:	9a6e                	add	s4,s4,s11
    80003b74:	0569f663          	bgeu	s3,s6,80003bc0 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003b78:	00a9559b          	srlw	a1,s2,0xa
    80003b7c:	8556                	mv	a0,s5
    80003b7e:	fffff097          	auipc	ra,0xfffff
    80003b82:	7a2080e7          	jalr	1954(ra) # 80003320 <bmap>
    80003b86:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003b8a:	c99d                	beqz	a1,80003bc0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003b8c:	000aa503          	lw	a0,0(s5)
    80003b90:	fffff097          	auipc	ra,0xfffff
    80003b94:	39e080e7          	jalr	926(ra) # 80002f2e <bread>
    80003b98:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003b9a:	3ff97713          	and	a4,s2,1023
    80003b9e:	40ec87bb          	subw	a5,s9,a4
    80003ba2:	413b06bb          	subw	a3,s6,s3
    80003ba6:	8d3e                	mv	s10,a5
    80003ba8:	2781                	sext.w	a5,a5
    80003baa:	0006861b          	sext.w	a2,a3
    80003bae:	f8f674e3          	bgeu	a2,a5,80003b36 <writei+0x4c>
    80003bb2:	8d36                	mv	s10,a3
    80003bb4:	b749                	j	80003b36 <writei+0x4c>
      brelse(bp);
    80003bb6:	8526                	mv	a0,s1
    80003bb8:	fffff097          	auipc	ra,0xfffff
    80003bbc:	4a6080e7          	jalr	1190(ra) # 8000305e <brelse>
  }

  if(off > ip->size)
    80003bc0:	04caa783          	lw	a5,76(s5)
    80003bc4:	0127f463          	bgeu	a5,s2,80003bcc <writei+0xe2>
    ip->size = off;
    80003bc8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003bcc:	8556                	mv	a0,s5
    80003bce:	00000097          	auipc	ra,0x0
    80003bd2:	aa4080e7          	jalr	-1372(ra) # 80003672 <iupdate>

  return tot;
    80003bd6:	0009851b          	sext.w	a0,s3
}
    80003bda:	70a6                	ld	ra,104(sp)
    80003bdc:	7406                	ld	s0,96(sp)
    80003bde:	64e6                	ld	s1,88(sp)
    80003be0:	6946                	ld	s2,80(sp)
    80003be2:	69a6                	ld	s3,72(sp)
    80003be4:	6a06                	ld	s4,64(sp)
    80003be6:	7ae2                	ld	s5,56(sp)
    80003be8:	7b42                	ld	s6,48(sp)
    80003bea:	7ba2                	ld	s7,40(sp)
    80003bec:	7c02                	ld	s8,32(sp)
    80003bee:	6ce2                	ld	s9,24(sp)
    80003bf0:	6d42                	ld	s10,16(sp)
    80003bf2:	6da2                	ld	s11,8(sp)
    80003bf4:	6165                	add	sp,sp,112
    80003bf6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003bf8:	89da                	mv	s3,s6
    80003bfa:	bfc9                	j	80003bcc <writei+0xe2>
    return -1;
    80003bfc:	557d                	li	a0,-1
}
    80003bfe:	8082                	ret
    return -1;
    80003c00:	557d                	li	a0,-1
    80003c02:	bfe1                	j	80003bda <writei+0xf0>
    return -1;
    80003c04:	557d                	li	a0,-1
    80003c06:	bfd1                	j	80003bda <writei+0xf0>

0000000080003c08 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003c08:	1141                	add	sp,sp,-16
    80003c0a:	e406                	sd	ra,8(sp)
    80003c0c:	e022                	sd	s0,0(sp)
    80003c0e:	0800                	add	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003c10:	4639                	li	a2,14
    80003c12:	ffffd097          	auipc	ra,0xffffd
    80003c16:	18c080e7          	jalr	396(ra) # 80000d9e <strncmp>
}
    80003c1a:	60a2                	ld	ra,8(sp)
    80003c1c:	6402                	ld	s0,0(sp)
    80003c1e:	0141                	add	sp,sp,16
    80003c20:	8082                	ret

0000000080003c22 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003c22:	7139                	add	sp,sp,-64
    80003c24:	fc06                	sd	ra,56(sp)
    80003c26:	f822                	sd	s0,48(sp)
    80003c28:	f426                	sd	s1,40(sp)
    80003c2a:	f04a                	sd	s2,32(sp)
    80003c2c:	ec4e                	sd	s3,24(sp)
    80003c2e:	e852                	sd	s4,16(sp)
    80003c30:	0080                	add	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003c32:	04451703          	lh	a4,68(a0)
    80003c36:	4785                	li	a5,1
    80003c38:	00f71a63          	bne	a4,a5,80003c4c <dirlookup+0x2a>
    80003c3c:	892a                	mv	s2,a0
    80003c3e:	89ae                	mv	s3,a1
    80003c40:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c42:	457c                	lw	a5,76(a0)
    80003c44:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003c46:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c48:	e79d                	bnez	a5,80003c76 <dirlookup+0x54>
    80003c4a:	a8a5                	j	80003cc2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003c4c:	00005517          	auipc	a0,0x5
    80003c50:	9e450513          	add	a0,a0,-1564 # 80008630 <syscalls+0x1a0>
    80003c54:	ffffd097          	auipc	ra,0xffffd
    80003c58:	8e8080e7          	jalr	-1816(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003c5c:	00005517          	auipc	a0,0x5
    80003c60:	9ec50513          	add	a0,a0,-1556 # 80008648 <syscalls+0x1b8>
    80003c64:	ffffd097          	auipc	ra,0xffffd
    80003c68:	8d8080e7          	jalr	-1832(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003c6c:	24c1                	addw	s1,s1,16
    80003c6e:	04c92783          	lw	a5,76(s2)
    80003c72:	04f4f763          	bgeu	s1,a5,80003cc0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003c76:	4741                	li	a4,16
    80003c78:	86a6                	mv	a3,s1
    80003c7a:	fc040613          	add	a2,s0,-64
    80003c7e:	4581                	li	a1,0
    80003c80:	854a                	mv	a0,s2
    80003c82:	00000097          	auipc	ra,0x0
    80003c86:	d70080e7          	jalr	-656(ra) # 800039f2 <readi>
    80003c8a:	47c1                	li	a5,16
    80003c8c:	fcf518e3          	bne	a0,a5,80003c5c <dirlookup+0x3a>
    if(de.inum == 0)
    80003c90:	fc045783          	lhu	a5,-64(s0)
    80003c94:	dfe1                	beqz	a5,80003c6c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003c96:	fc240593          	add	a1,s0,-62
    80003c9a:	854e                	mv	a0,s3
    80003c9c:	00000097          	auipc	ra,0x0
    80003ca0:	f6c080e7          	jalr	-148(ra) # 80003c08 <namecmp>
    80003ca4:	f561                	bnez	a0,80003c6c <dirlookup+0x4a>
      if(poff)
    80003ca6:	000a0463          	beqz	s4,80003cae <dirlookup+0x8c>
        *poff = off;
    80003caa:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003cae:	fc045583          	lhu	a1,-64(s0)
    80003cb2:	00092503          	lw	a0,0(s2)
    80003cb6:	fffff097          	auipc	ra,0xfffff
    80003cba:	754080e7          	jalr	1876(ra) # 8000340a <iget>
    80003cbe:	a011                	j	80003cc2 <dirlookup+0xa0>
  return 0;
    80003cc0:	4501                	li	a0,0
}
    80003cc2:	70e2                	ld	ra,56(sp)
    80003cc4:	7442                	ld	s0,48(sp)
    80003cc6:	74a2                	ld	s1,40(sp)
    80003cc8:	7902                	ld	s2,32(sp)
    80003cca:	69e2                	ld	s3,24(sp)
    80003ccc:	6a42                	ld	s4,16(sp)
    80003cce:	6121                	add	sp,sp,64
    80003cd0:	8082                	ret

0000000080003cd2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003cd2:	711d                	add	sp,sp,-96
    80003cd4:	ec86                	sd	ra,88(sp)
    80003cd6:	e8a2                	sd	s0,80(sp)
    80003cd8:	e4a6                	sd	s1,72(sp)
    80003cda:	e0ca                	sd	s2,64(sp)
    80003cdc:	fc4e                	sd	s3,56(sp)
    80003cde:	f852                	sd	s4,48(sp)
    80003ce0:	f456                	sd	s5,40(sp)
    80003ce2:	f05a                	sd	s6,32(sp)
    80003ce4:	ec5e                	sd	s7,24(sp)
    80003ce6:	e862                	sd	s8,16(sp)
    80003ce8:	e466                	sd	s9,8(sp)
    80003cea:	1080                	add	s0,sp,96
    80003cec:	84aa                	mv	s1,a0
    80003cee:	8b2e                	mv	s6,a1
    80003cf0:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003cf2:	00054703          	lbu	a4,0(a0)
    80003cf6:	02f00793          	li	a5,47
    80003cfa:	02f70263          	beq	a4,a5,80003d1e <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003cfe:	ffffe097          	auipc	ra,0xffffe
    80003d02:	cf8080e7          	jalr	-776(ra) # 800019f6 <myproc>
    80003d06:	15053503          	ld	a0,336(a0)
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	9f6080e7          	jalr	-1546(ra) # 80003700 <idup>
    80003d12:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003d14:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003d18:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003d1a:	4b85                	li	s7,1
    80003d1c:	a875                	j	80003dd8 <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003d1e:	4585                	li	a1,1
    80003d20:	4505                	li	a0,1
    80003d22:	fffff097          	auipc	ra,0xfffff
    80003d26:	6e8080e7          	jalr	1768(ra) # 8000340a <iget>
    80003d2a:	8a2a                	mv	s4,a0
    80003d2c:	b7e5                	j	80003d14 <namex+0x42>
      iunlockput(ip);
    80003d2e:	8552                	mv	a0,s4
    80003d30:	00000097          	auipc	ra,0x0
    80003d34:	c70080e7          	jalr	-912(ra) # 800039a0 <iunlockput>
      return 0;
    80003d38:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003d3a:	8552                	mv	a0,s4
    80003d3c:	60e6                	ld	ra,88(sp)
    80003d3e:	6446                	ld	s0,80(sp)
    80003d40:	64a6                	ld	s1,72(sp)
    80003d42:	6906                	ld	s2,64(sp)
    80003d44:	79e2                	ld	s3,56(sp)
    80003d46:	7a42                	ld	s4,48(sp)
    80003d48:	7aa2                	ld	s5,40(sp)
    80003d4a:	7b02                	ld	s6,32(sp)
    80003d4c:	6be2                	ld	s7,24(sp)
    80003d4e:	6c42                	ld	s8,16(sp)
    80003d50:	6ca2                	ld	s9,8(sp)
    80003d52:	6125                	add	sp,sp,96
    80003d54:	8082                	ret
      iunlock(ip);
    80003d56:	8552                	mv	a0,s4
    80003d58:	00000097          	auipc	ra,0x0
    80003d5c:	aa8080e7          	jalr	-1368(ra) # 80003800 <iunlock>
      return ip;
    80003d60:	bfe9                	j	80003d3a <namex+0x68>
      iunlockput(ip);
    80003d62:	8552                	mv	a0,s4
    80003d64:	00000097          	auipc	ra,0x0
    80003d68:	c3c080e7          	jalr	-964(ra) # 800039a0 <iunlockput>
      return 0;
    80003d6c:	8a4e                	mv	s4,s3
    80003d6e:	b7f1                	j	80003d3a <namex+0x68>
  len = path - s;
    80003d70:	40998633          	sub	a2,s3,s1
    80003d74:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003d78:	099c5863          	bge	s8,s9,80003e08 <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003d7c:	4639                	li	a2,14
    80003d7e:	85a6                	mv	a1,s1
    80003d80:	8556                	mv	a0,s5
    80003d82:	ffffd097          	auipc	ra,0xffffd
    80003d86:	fa8080e7          	jalr	-88(ra) # 80000d2a <memmove>
    80003d8a:	84ce                	mv	s1,s3
  while(*path == '/')
    80003d8c:	0004c783          	lbu	a5,0(s1)
    80003d90:	01279763          	bne	a5,s2,80003d9e <namex+0xcc>
    path++;
    80003d94:	0485                	add	s1,s1,1
  while(*path == '/')
    80003d96:	0004c783          	lbu	a5,0(s1)
    80003d9a:	ff278de3          	beq	a5,s2,80003d94 <namex+0xc2>
    ilock(ip);
    80003d9e:	8552                	mv	a0,s4
    80003da0:	00000097          	auipc	ra,0x0
    80003da4:	99e080e7          	jalr	-1634(ra) # 8000373e <ilock>
    if(ip->type != T_DIR){
    80003da8:	044a1783          	lh	a5,68(s4)
    80003dac:	f97791e3          	bne	a5,s7,80003d2e <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003db0:	000b0563          	beqz	s6,80003dba <namex+0xe8>
    80003db4:	0004c783          	lbu	a5,0(s1)
    80003db8:	dfd9                	beqz	a5,80003d56 <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003dba:	4601                	li	a2,0
    80003dbc:	85d6                	mv	a1,s5
    80003dbe:	8552                	mv	a0,s4
    80003dc0:	00000097          	auipc	ra,0x0
    80003dc4:	e62080e7          	jalr	-414(ra) # 80003c22 <dirlookup>
    80003dc8:	89aa                	mv	s3,a0
    80003dca:	dd41                	beqz	a0,80003d62 <namex+0x90>
    iunlockput(ip);
    80003dcc:	8552                	mv	a0,s4
    80003dce:	00000097          	auipc	ra,0x0
    80003dd2:	bd2080e7          	jalr	-1070(ra) # 800039a0 <iunlockput>
    ip = next;
    80003dd6:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003dd8:	0004c783          	lbu	a5,0(s1)
    80003ddc:	01279763          	bne	a5,s2,80003dea <namex+0x118>
    path++;
    80003de0:	0485                	add	s1,s1,1
  while(*path == '/')
    80003de2:	0004c783          	lbu	a5,0(s1)
    80003de6:	ff278de3          	beq	a5,s2,80003de0 <namex+0x10e>
  if(*path == 0)
    80003dea:	cb9d                	beqz	a5,80003e20 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003dec:	0004c783          	lbu	a5,0(s1)
    80003df0:	89a6                	mv	s3,s1
  len = path - s;
    80003df2:	4c81                	li	s9,0
    80003df4:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003df6:	01278963          	beq	a5,s2,80003e08 <namex+0x136>
    80003dfa:	dbbd                	beqz	a5,80003d70 <namex+0x9e>
    path++;
    80003dfc:	0985                	add	s3,s3,1
  while(*path != '/' && *path != 0)
    80003dfe:	0009c783          	lbu	a5,0(s3)
    80003e02:	ff279ce3          	bne	a5,s2,80003dfa <namex+0x128>
    80003e06:	b7ad                	j	80003d70 <namex+0x9e>
    memmove(name, s, len);
    80003e08:	2601                	sext.w	a2,a2
    80003e0a:	85a6                	mv	a1,s1
    80003e0c:	8556                	mv	a0,s5
    80003e0e:	ffffd097          	auipc	ra,0xffffd
    80003e12:	f1c080e7          	jalr	-228(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003e16:	9cd6                	add	s9,s9,s5
    80003e18:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003e1c:	84ce                	mv	s1,s3
    80003e1e:	b7bd                	j	80003d8c <namex+0xba>
  if(nameiparent){
    80003e20:	f00b0de3          	beqz	s6,80003d3a <namex+0x68>
    iput(ip);
    80003e24:	8552                	mv	a0,s4
    80003e26:	00000097          	auipc	ra,0x0
    80003e2a:	ad2080e7          	jalr	-1326(ra) # 800038f8 <iput>
    return 0;
    80003e2e:	4a01                	li	s4,0
    80003e30:	b729                	j	80003d3a <namex+0x68>

0000000080003e32 <dirlink>:
{
    80003e32:	7139                	add	sp,sp,-64
    80003e34:	fc06                	sd	ra,56(sp)
    80003e36:	f822                	sd	s0,48(sp)
    80003e38:	f426                	sd	s1,40(sp)
    80003e3a:	f04a                	sd	s2,32(sp)
    80003e3c:	ec4e                	sd	s3,24(sp)
    80003e3e:	e852                	sd	s4,16(sp)
    80003e40:	0080                	add	s0,sp,64
    80003e42:	892a                	mv	s2,a0
    80003e44:	8a2e                	mv	s4,a1
    80003e46:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003e48:	4601                	li	a2,0
    80003e4a:	00000097          	auipc	ra,0x0
    80003e4e:	dd8080e7          	jalr	-552(ra) # 80003c22 <dirlookup>
    80003e52:	e93d                	bnez	a0,80003ec8 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e54:	04c92483          	lw	s1,76(s2)
    80003e58:	c49d                	beqz	s1,80003e86 <dirlink+0x54>
    80003e5a:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e5c:	4741                	li	a4,16
    80003e5e:	86a6                	mv	a3,s1
    80003e60:	fc040613          	add	a2,s0,-64
    80003e64:	4581                	li	a1,0
    80003e66:	854a                	mv	a0,s2
    80003e68:	00000097          	auipc	ra,0x0
    80003e6c:	b8a080e7          	jalr	-1142(ra) # 800039f2 <readi>
    80003e70:	47c1                	li	a5,16
    80003e72:	06f51163          	bne	a0,a5,80003ed4 <dirlink+0xa2>
    if(de.inum == 0)
    80003e76:	fc045783          	lhu	a5,-64(s0)
    80003e7a:	c791                	beqz	a5,80003e86 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e7c:	24c1                	addw	s1,s1,16
    80003e7e:	04c92783          	lw	a5,76(s2)
    80003e82:	fcf4ede3          	bltu	s1,a5,80003e5c <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003e86:	4639                	li	a2,14
    80003e88:	85d2                	mv	a1,s4
    80003e8a:	fc240513          	add	a0,s0,-62
    80003e8e:	ffffd097          	auipc	ra,0xffffd
    80003e92:	f4c080e7          	jalr	-180(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003e96:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e9a:	4741                	li	a4,16
    80003e9c:	86a6                	mv	a3,s1
    80003e9e:	fc040613          	add	a2,s0,-64
    80003ea2:	4581                	li	a1,0
    80003ea4:	854a                	mv	a0,s2
    80003ea6:	00000097          	auipc	ra,0x0
    80003eaa:	c44080e7          	jalr	-956(ra) # 80003aea <writei>
    80003eae:	1541                	add	a0,a0,-16
    80003eb0:	00a03533          	snez	a0,a0
    80003eb4:	40a00533          	neg	a0,a0
}
    80003eb8:	70e2                	ld	ra,56(sp)
    80003eba:	7442                	ld	s0,48(sp)
    80003ebc:	74a2                	ld	s1,40(sp)
    80003ebe:	7902                	ld	s2,32(sp)
    80003ec0:	69e2                	ld	s3,24(sp)
    80003ec2:	6a42                	ld	s4,16(sp)
    80003ec4:	6121                	add	sp,sp,64
    80003ec6:	8082                	ret
    iput(ip);
    80003ec8:	00000097          	auipc	ra,0x0
    80003ecc:	a30080e7          	jalr	-1488(ra) # 800038f8 <iput>
    return -1;
    80003ed0:	557d                	li	a0,-1
    80003ed2:	b7dd                	j	80003eb8 <dirlink+0x86>
      panic("dirlink read");
    80003ed4:	00004517          	auipc	a0,0x4
    80003ed8:	78450513          	add	a0,a0,1924 # 80008658 <syscalls+0x1c8>
    80003edc:	ffffc097          	auipc	ra,0xffffc
    80003ee0:	660080e7          	jalr	1632(ra) # 8000053c <panic>

0000000080003ee4 <namei>:

struct inode*
namei(char *path)
{
    80003ee4:	1101                	add	sp,sp,-32
    80003ee6:	ec06                	sd	ra,24(sp)
    80003ee8:	e822                	sd	s0,16(sp)
    80003eea:	1000                	add	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003eec:	fe040613          	add	a2,s0,-32
    80003ef0:	4581                	li	a1,0
    80003ef2:	00000097          	auipc	ra,0x0
    80003ef6:	de0080e7          	jalr	-544(ra) # 80003cd2 <namex>
}
    80003efa:	60e2                	ld	ra,24(sp)
    80003efc:	6442                	ld	s0,16(sp)
    80003efe:	6105                	add	sp,sp,32
    80003f00:	8082                	ret

0000000080003f02 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003f02:	1141                	add	sp,sp,-16
    80003f04:	e406                	sd	ra,8(sp)
    80003f06:	e022                	sd	s0,0(sp)
    80003f08:	0800                	add	s0,sp,16
    80003f0a:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003f0c:	4585                	li	a1,1
    80003f0e:	00000097          	auipc	ra,0x0
    80003f12:	dc4080e7          	jalr	-572(ra) # 80003cd2 <namex>
}
    80003f16:	60a2                	ld	ra,8(sp)
    80003f18:	6402                	ld	s0,0(sp)
    80003f1a:	0141                	add	sp,sp,16
    80003f1c:	8082                	ret

0000000080003f1e <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003f1e:	1101                	add	sp,sp,-32
    80003f20:	ec06                	sd	ra,24(sp)
    80003f22:	e822                	sd	s0,16(sp)
    80003f24:	e426                	sd	s1,8(sp)
    80003f26:	e04a                	sd	s2,0(sp)
    80003f28:	1000                	add	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003f2a:	00194917          	auipc	s2,0x194
    80003f2e:	1de90913          	add	s2,s2,478 # 80198108 <log>
    80003f32:	01892583          	lw	a1,24(s2)
    80003f36:	02892503          	lw	a0,40(s2)
    80003f3a:	fffff097          	auipc	ra,0xfffff
    80003f3e:	ff4080e7          	jalr	-12(ra) # 80002f2e <bread>
    80003f42:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003f44:	02c92603          	lw	a2,44(s2)
    80003f48:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003f4a:	00c05f63          	blez	a2,80003f68 <write_head+0x4a>
    80003f4e:	00194717          	auipc	a4,0x194
    80003f52:	1ea70713          	add	a4,a4,490 # 80198138 <log+0x30>
    80003f56:	87aa                	mv	a5,a0
    80003f58:	060a                	sll	a2,a2,0x2
    80003f5a:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003f5c:	4314                	lw	a3,0(a4)
    80003f5e:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003f60:	0711                	add	a4,a4,4
    80003f62:	0791                	add	a5,a5,4
    80003f64:	fec79ce3          	bne	a5,a2,80003f5c <write_head+0x3e>
  }
  bwrite(buf);
    80003f68:	8526                	mv	a0,s1
    80003f6a:	fffff097          	auipc	ra,0xfffff
    80003f6e:	0b6080e7          	jalr	182(ra) # 80003020 <bwrite>
  brelse(buf);
    80003f72:	8526                	mv	a0,s1
    80003f74:	fffff097          	auipc	ra,0xfffff
    80003f78:	0ea080e7          	jalr	234(ra) # 8000305e <brelse>
}
    80003f7c:	60e2                	ld	ra,24(sp)
    80003f7e:	6442                	ld	s0,16(sp)
    80003f80:	64a2                	ld	s1,8(sp)
    80003f82:	6902                	ld	s2,0(sp)
    80003f84:	6105                	add	sp,sp,32
    80003f86:	8082                	ret

0000000080003f88 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003f88:	00194797          	auipc	a5,0x194
    80003f8c:	1ac7a783          	lw	a5,428(a5) # 80198134 <log+0x2c>
    80003f90:	0af05d63          	blez	a5,8000404a <install_trans+0xc2>
{
    80003f94:	7139                	add	sp,sp,-64
    80003f96:	fc06                	sd	ra,56(sp)
    80003f98:	f822                	sd	s0,48(sp)
    80003f9a:	f426                	sd	s1,40(sp)
    80003f9c:	f04a                	sd	s2,32(sp)
    80003f9e:	ec4e                	sd	s3,24(sp)
    80003fa0:	e852                	sd	s4,16(sp)
    80003fa2:	e456                	sd	s5,8(sp)
    80003fa4:	e05a                	sd	s6,0(sp)
    80003fa6:	0080                	add	s0,sp,64
    80003fa8:	8b2a                	mv	s6,a0
    80003faa:	00194a97          	auipc	s5,0x194
    80003fae:	18ea8a93          	add	s5,s5,398 # 80198138 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fb2:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fb4:	00194997          	auipc	s3,0x194
    80003fb8:	15498993          	add	s3,s3,340 # 80198108 <log>
    80003fbc:	a00d                	j	80003fde <install_trans+0x56>
    brelse(lbuf);
    80003fbe:	854a                	mv	a0,s2
    80003fc0:	fffff097          	auipc	ra,0xfffff
    80003fc4:	09e080e7          	jalr	158(ra) # 8000305e <brelse>
    brelse(dbuf);
    80003fc8:	8526                	mv	a0,s1
    80003fca:	fffff097          	auipc	ra,0xfffff
    80003fce:	094080e7          	jalr	148(ra) # 8000305e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003fd2:	2a05                	addw	s4,s4,1
    80003fd4:	0a91                	add	s5,s5,4
    80003fd6:	02c9a783          	lw	a5,44(s3)
    80003fda:	04fa5e63          	bge	s4,a5,80004036 <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003fde:	0189a583          	lw	a1,24(s3)
    80003fe2:	014585bb          	addw	a1,a1,s4
    80003fe6:	2585                	addw	a1,a1,1
    80003fe8:	0289a503          	lw	a0,40(s3)
    80003fec:	fffff097          	auipc	ra,0xfffff
    80003ff0:	f42080e7          	jalr	-190(ra) # 80002f2e <bread>
    80003ff4:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003ff6:	000aa583          	lw	a1,0(s5)
    80003ffa:	0289a503          	lw	a0,40(s3)
    80003ffe:	fffff097          	auipc	ra,0xfffff
    80004002:	f30080e7          	jalr	-208(ra) # 80002f2e <bread>
    80004006:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004008:	40000613          	li	a2,1024
    8000400c:	05890593          	add	a1,s2,88
    80004010:	05850513          	add	a0,a0,88
    80004014:	ffffd097          	auipc	ra,0xffffd
    80004018:	d16080e7          	jalr	-746(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    8000401c:	8526                	mv	a0,s1
    8000401e:	fffff097          	auipc	ra,0xfffff
    80004022:	002080e7          	jalr	2(ra) # 80003020 <bwrite>
    if(recovering == 0)
    80004026:	f80b1ce3          	bnez	s6,80003fbe <install_trans+0x36>
      bunpin(dbuf);
    8000402a:	8526                	mv	a0,s1
    8000402c:	fffff097          	auipc	ra,0xfffff
    80004030:	10a080e7          	jalr	266(ra) # 80003136 <bunpin>
    80004034:	b769                	j	80003fbe <install_trans+0x36>
}
    80004036:	70e2                	ld	ra,56(sp)
    80004038:	7442                	ld	s0,48(sp)
    8000403a:	74a2                	ld	s1,40(sp)
    8000403c:	7902                	ld	s2,32(sp)
    8000403e:	69e2                	ld	s3,24(sp)
    80004040:	6a42                	ld	s4,16(sp)
    80004042:	6aa2                	ld	s5,8(sp)
    80004044:	6b02                	ld	s6,0(sp)
    80004046:	6121                	add	sp,sp,64
    80004048:	8082                	ret
    8000404a:	8082                	ret

000000008000404c <initlog>:
{
    8000404c:	7179                	add	sp,sp,-48
    8000404e:	f406                	sd	ra,40(sp)
    80004050:	f022                	sd	s0,32(sp)
    80004052:	ec26                	sd	s1,24(sp)
    80004054:	e84a                	sd	s2,16(sp)
    80004056:	e44e                	sd	s3,8(sp)
    80004058:	1800                	add	s0,sp,48
    8000405a:	892a                	mv	s2,a0
    8000405c:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000405e:	00194497          	auipc	s1,0x194
    80004062:	0aa48493          	add	s1,s1,170 # 80198108 <log>
    80004066:	00004597          	auipc	a1,0x4
    8000406a:	60258593          	add	a1,a1,1538 # 80008668 <syscalls+0x1d8>
    8000406e:	8526                	mv	a0,s1
    80004070:	ffffd097          	auipc	ra,0xffffd
    80004074:	ad2080e7          	jalr	-1326(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80004078:	0149a583          	lw	a1,20(s3)
    8000407c:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000407e:	0109a783          	lw	a5,16(s3)
    80004082:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80004084:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004088:	854a                	mv	a0,s2
    8000408a:	fffff097          	auipc	ra,0xfffff
    8000408e:	ea4080e7          	jalr	-348(ra) # 80002f2e <bread>
  log.lh.n = lh->n;
    80004092:	4d30                	lw	a2,88(a0)
    80004094:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80004096:	00c05f63          	blez	a2,800040b4 <initlog+0x68>
    8000409a:	87aa                	mv	a5,a0
    8000409c:	00194717          	auipc	a4,0x194
    800040a0:	09c70713          	add	a4,a4,156 # 80198138 <log+0x30>
    800040a4:	060a                	sll	a2,a2,0x2
    800040a6:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    800040a8:	4ff4                	lw	a3,92(a5)
    800040aa:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800040ac:	0791                	add	a5,a5,4
    800040ae:	0711                	add	a4,a4,4
    800040b0:	fec79ce3          	bne	a5,a2,800040a8 <initlog+0x5c>
  brelse(buf);
    800040b4:	fffff097          	auipc	ra,0xfffff
    800040b8:	faa080e7          	jalr	-86(ra) # 8000305e <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800040bc:	4505                	li	a0,1
    800040be:	00000097          	auipc	ra,0x0
    800040c2:	eca080e7          	jalr	-310(ra) # 80003f88 <install_trans>
  log.lh.n = 0;
    800040c6:	00194797          	auipc	a5,0x194
    800040ca:	0607a723          	sw	zero,110(a5) # 80198134 <log+0x2c>
  write_head(); // clear the log
    800040ce:	00000097          	auipc	ra,0x0
    800040d2:	e50080e7          	jalr	-432(ra) # 80003f1e <write_head>
}
    800040d6:	70a2                	ld	ra,40(sp)
    800040d8:	7402                	ld	s0,32(sp)
    800040da:	64e2                	ld	s1,24(sp)
    800040dc:	6942                	ld	s2,16(sp)
    800040de:	69a2                	ld	s3,8(sp)
    800040e0:	6145                	add	sp,sp,48
    800040e2:	8082                	ret

00000000800040e4 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800040e4:	1101                	add	sp,sp,-32
    800040e6:	ec06                	sd	ra,24(sp)
    800040e8:	e822                	sd	s0,16(sp)
    800040ea:	e426                	sd	s1,8(sp)
    800040ec:	e04a                	sd	s2,0(sp)
    800040ee:	1000                	add	s0,sp,32
  acquire(&log.lock);
    800040f0:	00194517          	auipc	a0,0x194
    800040f4:	01850513          	add	a0,a0,24 # 80198108 <log>
    800040f8:	ffffd097          	auipc	ra,0xffffd
    800040fc:	ada080e7          	jalr	-1318(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80004100:	00194497          	auipc	s1,0x194
    80004104:	00848493          	add	s1,s1,8 # 80198108 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004108:	4979                	li	s2,30
    8000410a:	a039                	j	80004118 <begin_op+0x34>
      sleep(&log, &log.lock);
    8000410c:	85a6                	mv	a1,s1
    8000410e:	8526                	mv	a0,s1
    80004110:	ffffe097          	auipc	ra,0xffffe
    80004114:	ff2080e7          	jalr	-14(ra) # 80002102 <sleep>
    if(log.committing){
    80004118:	50dc                	lw	a5,36(s1)
    8000411a:	fbed                	bnez	a5,8000410c <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000411c:	5098                	lw	a4,32(s1)
    8000411e:	2705                	addw	a4,a4,1
    80004120:	0027179b          	sllw	a5,a4,0x2
    80004124:	9fb9                	addw	a5,a5,a4
    80004126:	0017979b          	sllw	a5,a5,0x1
    8000412a:	54d4                	lw	a3,44(s1)
    8000412c:	9fb5                	addw	a5,a5,a3
    8000412e:	00f95963          	bge	s2,a5,80004140 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004132:	85a6                	mv	a1,s1
    80004134:	8526                	mv	a0,s1
    80004136:	ffffe097          	auipc	ra,0xffffe
    8000413a:	fcc080e7          	jalr	-52(ra) # 80002102 <sleep>
    8000413e:	bfe9                	j	80004118 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004140:	00194517          	auipc	a0,0x194
    80004144:	fc850513          	add	a0,a0,-56 # 80198108 <log>
    80004148:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000414a:	ffffd097          	auipc	ra,0xffffd
    8000414e:	b3c080e7          	jalr	-1220(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004152:	60e2                	ld	ra,24(sp)
    80004154:	6442                	ld	s0,16(sp)
    80004156:	64a2                	ld	s1,8(sp)
    80004158:	6902                	ld	s2,0(sp)
    8000415a:	6105                	add	sp,sp,32
    8000415c:	8082                	ret

000000008000415e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000415e:	7139                	add	sp,sp,-64
    80004160:	fc06                	sd	ra,56(sp)
    80004162:	f822                	sd	s0,48(sp)
    80004164:	f426                	sd	s1,40(sp)
    80004166:	f04a                	sd	s2,32(sp)
    80004168:	ec4e                	sd	s3,24(sp)
    8000416a:	e852                	sd	s4,16(sp)
    8000416c:	e456                	sd	s5,8(sp)
    8000416e:	0080                	add	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004170:	00194497          	auipc	s1,0x194
    80004174:	f9848493          	add	s1,s1,-104 # 80198108 <log>
    80004178:	8526                	mv	a0,s1
    8000417a:	ffffd097          	auipc	ra,0xffffd
    8000417e:	a58080e7          	jalr	-1448(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    80004182:	509c                	lw	a5,32(s1)
    80004184:	37fd                	addw	a5,a5,-1
    80004186:	0007891b          	sext.w	s2,a5
    8000418a:	d09c                	sw	a5,32(s1)
  if(log.committing)
    8000418c:	50dc                	lw	a5,36(s1)
    8000418e:	e7b9                	bnez	a5,800041dc <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004190:	04091e63          	bnez	s2,800041ec <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004194:	00194497          	auipc	s1,0x194
    80004198:	f7448493          	add	s1,s1,-140 # 80198108 <log>
    8000419c:	4785                	li	a5,1
    8000419e:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800041a0:	8526                	mv	a0,s1
    800041a2:	ffffd097          	auipc	ra,0xffffd
    800041a6:	ae4080e7          	jalr	-1308(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800041aa:	54dc                	lw	a5,44(s1)
    800041ac:	06f04763          	bgtz	a5,8000421a <end_op+0xbc>
    acquire(&log.lock);
    800041b0:	00194497          	auipc	s1,0x194
    800041b4:	f5848493          	add	s1,s1,-168 # 80198108 <log>
    800041b8:	8526                	mv	a0,s1
    800041ba:	ffffd097          	auipc	ra,0xffffd
    800041be:	a18080e7          	jalr	-1512(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800041c2:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800041c6:	8526                	mv	a0,s1
    800041c8:	ffffe097          	auipc	ra,0xffffe
    800041cc:	f9e080e7          	jalr	-98(ra) # 80002166 <wakeup>
    release(&log.lock);
    800041d0:	8526                	mv	a0,s1
    800041d2:	ffffd097          	auipc	ra,0xffffd
    800041d6:	ab4080e7          	jalr	-1356(ra) # 80000c86 <release>
}
    800041da:	a03d                	j	80004208 <end_op+0xaa>
    panic("log.committing");
    800041dc:	00004517          	auipc	a0,0x4
    800041e0:	49450513          	add	a0,a0,1172 # 80008670 <syscalls+0x1e0>
    800041e4:	ffffc097          	auipc	ra,0xffffc
    800041e8:	358080e7          	jalr	856(ra) # 8000053c <panic>
    wakeup(&log);
    800041ec:	00194497          	auipc	s1,0x194
    800041f0:	f1c48493          	add	s1,s1,-228 # 80198108 <log>
    800041f4:	8526                	mv	a0,s1
    800041f6:	ffffe097          	auipc	ra,0xffffe
    800041fa:	f70080e7          	jalr	-144(ra) # 80002166 <wakeup>
  release(&log.lock);
    800041fe:	8526                	mv	a0,s1
    80004200:	ffffd097          	auipc	ra,0xffffd
    80004204:	a86080e7          	jalr	-1402(ra) # 80000c86 <release>
}
    80004208:	70e2                	ld	ra,56(sp)
    8000420a:	7442                	ld	s0,48(sp)
    8000420c:	74a2                	ld	s1,40(sp)
    8000420e:	7902                	ld	s2,32(sp)
    80004210:	69e2                	ld	s3,24(sp)
    80004212:	6a42                	ld	s4,16(sp)
    80004214:	6aa2                	ld	s5,8(sp)
    80004216:	6121                	add	sp,sp,64
    80004218:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    8000421a:	00194a97          	auipc	s5,0x194
    8000421e:	f1ea8a93          	add	s5,s5,-226 # 80198138 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004222:	00194a17          	auipc	s4,0x194
    80004226:	ee6a0a13          	add	s4,s4,-282 # 80198108 <log>
    8000422a:	018a2583          	lw	a1,24(s4)
    8000422e:	012585bb          	addw	a1,a1,s2
    80004232:	2585                	addw	a1,a1,1
    80004234:	028a2503          	lw	a0,40(s4)
    80004238:	fffff097          	auipc	ra,0xfffff
    8000423c:	cf6080e7          	jalr	-778(ra) # 80002f2e <bread>
    80004240:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004242:	000aa583          	lw	a1,0(s5)
    80004246:	028a2503          	lw	a0,40(s4)
    8000424a:	fffff097          	auipc	ra,0xfffff
    8000424e:	ce4080e7          	jalr	-796(ra) # 80002f2e <bread>
    80004252:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004254:	40000613          	li	a2,1024
    80004258:	05850593          	add	a1,a0,88
    8000425c:	05848513          	add	a0,s1,88
    80004260:	ffffd097          	auipc	ra,0xffffd
    80004264:	aca080e7          	jalr	-1334(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    80004268:	8526                	mv	a0,s1
    8000426a:	fffff097          	auipc	ra,0xfffff
    8000426e:	db6080e7          	jalr	-586(ra) # 80003020 <bwrite>
    brelse(from);
    80004272:	854e                	mv	a0,s3
    80004274:	fffff097          	auipc	ra,0xfffff
    80004278:	dea080e7          	jalr	-534(ra) # 8000305e <brelse>
    brelse(to);
    8000427c:	8526                	mv	a0,s1
    8000427e:	fffff097          	auipc	ra,0xfffff
    80004282:	de0080e7          	jalr	-544(ra) # 8000305e <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004286:	2905                	addw	s2,s2,1
    80004288:	0a91                	add	s5,s5,4
    8000428a:	02ca2783          	lw	a5,44(s4)
    8000428e:	f8f94ee3          	blt	s2,a5,8000422a <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004292:	00000097          	auipc	ra,0x0
    80004296:	c8c080e7          	jalr	-884(ra) # 80003f1e <write_head>
    install_trans(0); // Now install writes to home locations
    8000429a:	4501                	li	a0,0
    8000429c:	00000097          	auipc	ra,0x0
    800042a0:	cec080e7          	jalr	-788(ra) # 80003f88 <install_trans>
    log.lh.n = 0;
    800042a4:	00194797          	auipc	a5,0x194
    800042a8:	e807a823          	sw	zero,-368(a5) # 80198134 <log+0x2c>
    write_head();    // Erase the transaction from the log
    800042ac:	00000097          	auipc	ra,0x0
    800042b0:	c72080e7          	jalr	-910(ra) # 80003f1e <write_head>
    800042b4:	bdf5                	j	800041b0 <end_op+0x52>

00000000800042b6 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800042b6:	1101                	add	sp,sp,-32
    800042b8:	ec06                	sd	ra,24(sp)
    800042ba:	e822                	sd	s0,16(sp)
    800042bc:	e426                	sd	s1,8(sp)
    800042be:	e04a                	sd	s2,0(sp)
    800042c0:	1000                	add	s0,sp,32
    800042c2:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800042c4:	00194917          	auipc	s2,0x194
    800042c8:	e4490913          	add	s2,s2,-444 # 80198108 <log>
    800042cc:	854a                	mv	a0,s2
    800042ce:	ffffd097          	auipc	ra,0xffffd
    800042d2:	904080e7          	jalr	-1788(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800042d6:	02c92603          	lw	a2,44(s2)
    800042da:	47f5                	li	a5,29
    800042dc:	06c7c563          	blt	a5,a2,80004346 <log_write+0x90>
    800042e0:	00194797          	auipc	a5,0x194
    800042e4:	e447a783          	lw	a5,-444(a5) # 80198124 <log+0x1c>
    800042e8:	37fd                	addw	a5,a5,-1
    800042ea:	04f65e63          	bge	a2,a5,80004346 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800042ee:	00194797          	auipc	a5,0x194
    800042f2:	e3a7a783          	lw	a5,-454(a5) # 80198128 <log+0x20>
    800042f6:	06f05063          	blez	a5,80004356 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800042fa:	4781                	li	a5,0
    800042fc:	06c05563          	blez	a2,80004366 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004300:	44cc                	lw	a1,12(s1)
    80004302:	00194717          	auipc	a4,0x194
    80004306:	e3670713          	add	a4,a4,-458 # 80198138 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    8000430a:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000430c:	4314                	lw	a3,0(a4)
    8000430e:	04b68c63          	beq	a3,a1,80004366 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    80004312:	2785                	addw	a5,a5,1
    80004314:	0711                	add	a4,a4,4
    80004316:	fef61be3          	bne	a2,a5,8000430c <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    8000431a:	0621                	add	a2,a2,8
    8000431c:	060a                	sll	a2,a2,0x2
    8000431e:	00194797          	auipc	a5,0x194
    80004322:	dea78793          	add	a5,a5,-534 # 80198108 <log>
    80004326:	97b2                	add	a5,a5,a2
    80004328:	44d8                	lw	a4,12(s1)
    8000432a:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    8000432c:	8526                	mv	a0,s1
    8000432e:	fffff097          	auipc	ra,0xfffff
    80004332:	dcc080e7          	jalr	-564(ra) # 800030fa <bpin>
    log.lh.n++;
    80004336:	00194717          	auipc	a4,0x194
    8000433a:	dd270713          	add	a4,a4,-558 # 80198108 <log>
    8000433e:	575c                	lw	a5,44(a4)
    80004340:	2785                	addw	a5,a5,1
    80004342:	d75c                	sw	a5,44(a4)
    80004344:	a82d                	j	8000437e <log_write+0xc8>
    panic("too big a transaction");
    80004346:	00004517          	auipc	a0,0x4
    8000434a:	33a50513          	add	a0,a0,826 # 80008680 <syscalls+0x1f0>
    8000434e:	ffffc097          	auipc	ra,0xffffc
    80004352:	1ee080e7          	jalr	494(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    80004356:	00004517          	auipc	a0,0x4
    8000435a:	34250513          	add	a0,a0,834 # 80008698 <syscalls+0x208>
    8000435e:	ffffc097          	auipc	ra,0xffffc
    80004362:	1de080e7          	jalr	478(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    80004366:	00878693          	add	a3,a5,8
    8000436a:	068a                	sll	a3,a3,0x2
    8000436c:	00194717          	auipc	a4,0x194
    80004370:	d9c70713          	add	a4,a4,-612 # 80198108 <log>
    80004374:	9736                	add	a4,a4,a3
    80004376:	44d4                	lw	a3,12(s1)
    80004378:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000437a:	faf609e3          	beq	a2,a5,8000432c <log_write+0x76>
  }
  release(&log.lock);
    8000437e:	00194517          	auipc	a0,0x194
    80004382:	d8a50513          	add	a0,a0,-630 # 80198108 <log>
    80004386:	ffffd097          	auipc	ra,0xffffd
    8000438a:	900080e7          	jalr	-1792(ra) # 80000c86 <release>
}
    8000438e:	60e2                	ld	ra,24(sp)
    80004390:	6442                	ld	s0,16(sp)
    80004392:	64a2                	ld	s1,8(sp)
    80004394:	6902                	ld	s2,0(sp)
    80004396:	6105                	add	sp,sp,32
    80004398:	8082                	ret

000000008000439a <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000439a:	1101                	add	sp,sp,-32
    8000439c:	ec06                	sd	ra,24(sp)
    8000439e:	e822                	sd	s0,16(sp)
    800043a0:	e426                	sd	s1,8(sp)
    800043a2:	e04a                	sd	s2,0(sp)
    800043a4:	1000                	add	s0,sp,32
    800043a6:	84aa                	mv	s1,a0
    800043a8:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800043aa:	00004597          	auipc	a1,0x4
    800043ae:	30e58593          	add	a1,a1,782 # 800086b8 <syscalls+0x228>
    800043b2:	0521                	add	a0,a0,8
    800043b4:	ffffc097          	auipc	ra,0xffffc
    800043b8:	78e080e7          	jalr	1934(ra) # 80000b42 <initlock>
  lk->name = name;
    800043bc:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800043c0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800043c4:	0204a423          	sw	zero,40(s1)
}
    800043c8:	60e2                	ld	ra,24(sp)
    800043ca:	6442                	ld	s0,16(sp)
    800043cc:	64a2                	ld	s1,8(sp)
    800043ce:	6902                	ld	s2,0(sp)
    800043d0:	6105                	add	sp,sp,32
    800043d2:	8082                	ret

00000000800043d4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800043d4:	1101                	add	sp,sp,-32
    800043d6:	ec06                	sd	ra,24(sp)
    800043d8:	e822                	sd	s0,16(sp)
    800043da:	e426                	sd	s1,8(sp)
    800043dc:	e04a                	sd	s2,0(sp)
    800043de:	1000                	add	s0,sp,32
    800043e0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800043e2:	00850913          	add	s2,a0,8
    800043e6:	854a                	mv	a0,s2
    800043e8:	ffffc097          	auipc	ra,0xffffc
    800043ec:	7ea080e7          	jalr	2026(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800043f0:	409c                	lw	a5,0(s1)
    800043f2:	cb89                	beqz	a5,80004404 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800043f4:	85ca                	mv	a1,s2
    800043f6:	8526                	mv	a0,s1
    800043f8:	ffffe097          	auipc	ra,0xffffe
    800043fc:	d0a080e7          	jalr	-758(ra) # 80002102 <sleep>
  while (lk->locked) {
    80004400:	409c                	lw	a5,0(s1)
    80004402:	fbed                	bnez	a5,800043f4 <acquiresleep+0x20>
  }
  lk->locked = 1;
    80004404:	4785                	li	a5,1
    80004406:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004408:	ffffd097          	auipc	ra,0xffffd
    8000440c:	5ee080e7          	jalr	1518(ra) # 800019f6 <myproc>
    80004410:	591c                	lw	a5,48(a0)
    80004412:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80004414:	854a                	mv	a0,s2
    80004416:	ffffd097          	auipc	ra,0xffffd
    8000441a:	870080e7          	jalr	-1936(ra) # 80000c86 <release>
}
    8000441e:	60e2                	ld	ra,24(sp)
    80004420:	6442                	ld	s0,16(sp)
    80004422:	64a2                	ld	s1,8(sp)
    80004424:	6902                	ld	s2,0(sp)
    80004426:	6105                	add	sp,sp,32
    80004428:	8082                	ret

000000008000442a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000442a:	1101                	add	sp,sp,-32
    8000442c:	ec06                	sd	ra,24(sp)
    8000442e:	e822                	sd	s0,16(sp)
    80004430:	e426                	sd	s1,8(sp)
    80004432:	e04a                	sd	s2,0(sp)
    80004434:	1000                	add	s0,sp,32
    80004436:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004438:	00850913          	add	s2,a0,8
    8000443c:	854a                	mv	a0,s2
    8000443e:	ffffc097          	auipc	ra,0xffffc
    80004442:	794080e7          	jalr	1940(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    80004446:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000444a:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    8000444e:	8526                	mv	a0,s1
    80004450:	ffffe097          	auipc	ra,0xffffe
    80004454:	d16080e7          	jalr	-746(ra) # 80002166 <wakeup>
  release(&lk->lk);
    80004458:	854a                	mv	a0,s2
    8000445a:	ffffd097          	auipc	ra,0xffffd
    8000445e:	82c080e7          	jalr	-2004(ra) # 80000c86 <release>
}
    80004462:	60e2                	ld	ra,24(sp)
    80004464:	6442                	ld	s0,16(sp)
    80004466:	64a2                	ld	s1,8(sp)
    80004468:	6902                	ld	s2,0(sp)
    8000446a:	6105                	add	sp,sp,32
    8000446c:	8082                	ret

000000008000446e <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    8000446e:	7179                	add	sp,sp,-48
    80004470:	f406                	sd	ra,40(sp)
    80004472:	f022                	sd	s0,32(sp)
    80004474:	ec26                	sd	s1,24(sp)
    80004476:	e84a                	sd	s2,16(sp)
    80004478:	e44e                	sd	s3,8(sp)
    8000447a:	1800                	add	s0,sp,48
    8000447c:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    8000447e:	00850913          	add	s2,a0,8
    80004482:	854a                	mv	a0,s2
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	74e080e7          	jalr	1870(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    8000448c:	409c                	lw	a5,0(s1)
    8000448e:	ef99                	bnez	a5,800044ac <holdingsleep+0x3e>
    80004490:	4481                	li	s1,0
  release(&lk->lk);
    80004492:	854a                	mv	a0,s2
    80004494:	ffffc097          	auipc	ra,0xffffc
    80004498:	7f2080e7          	jalr	2034(ra) # 80000c86 <release>
  return r;
}
    8000449c:	8526                	mv	a0,s1
    8000449e:	70a2                	ld	ra,40(sp)
    800044a0:	7402                	ld	s0,32(sp)
    800044a2:	64e2                	ld	s1,24(sp)
    800044a4:	6942                	ld	s2,16(sp)
    800044a6:	69a2                	ld	s3,8(sp)
    800044a8:	6145                	add	sp,sp,48
    800044aa:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800044ac:	0284a983          	lw	s3,40(s1)
    800044b0:	ffffd097          	auipc	ra,0xffffd
    800044b4:	546080e7          	jalr	1350(ra) # 800019f6 <myproc>
    800044b8:	5904                	lw	s1,48(a0)
    800044ba:	413484b3          	sub	s1,s1,s3
    800044be:	0014b493          	seqz	s1,s1
    800044c2:	bfc1                	j	80004492 <holdingsleep+0x24>

00000000800044c4 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800044c4:	1141                	add	sp,sp,-16
    800044c6:	e406                	sd	ra,8(sp)
    800044c8:	e022                	sd	s0,0(sp)
    800044ca:	0800                	add	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800044cc:	00004597          	auipc	a1,0x4
    800044d0:	1fc58593          	add	a1,a1,508 # 800086c8 <syscalls+0x238>
    800044d4:	00194517          	auipc	a0,0x194
    800044d8:	d7c50513          	add	a0,a0,-644 # 80198250 <ftable>
    800044dc:	ffffc097          	auipc	ra,0xffffc
    800044e0:	666080e7          	jalr	1638(ra) # 80000b42 <initlock>
}
    800044e4:	60a2                	ld	ra,8(sp)
    800044e6:	6402                	ld	s0,0(sp)
    800044e8:	0141                	add	sp,sp,16
    800044ea:	8082                	ret

00000000800044ec <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800044ec:	1101                	add	sp,sp,-32
    800044ee:	ec06                	sd	ra,24(sp)
    800044f0:	e822                	sd	s0,16(sp)
    800044f2:	e426                	sd	s1,8(sp)
    800044f4:	1000                	add	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800044f6:	00194517          	auipc	a0,0x194
    800044fa:	d5a50513          	add	a0,a0,-678 # 80198250 <ftable>
    800044fe:	ffffc097          	auipc	ra,0xffffc
    80004502:	6d4080e7          	jalr	1748(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004506:	00194497          	auipc	s1,0x194
    8000450a:	d6248493          	add	s1,s1,-670 # 80198268 <ftable+0x18>
    8000450e:	00195717          	auipc	a4,0x195
    80004512:	cfa70713          	add	a4,a4,-774 # 80199208 <disk>
    if(f->ref == 0){
    80004516:	40dc                	lw	a5,4(s1)
    80004518:	cf99                	beqz	a5,80004536 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    8000451a:	02848493          	add	s1,s1,40
    8000451e:	fee49ce3          	bne	s1,a4,80004516 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004522:	00194517          	auipc	a0,0x194
    80004526:	d2e50513          	add	a0,a0,-722 # 80198250 <ftable>
    8000452a:	ffffc097          	auipc	ra,0xffffc
    8000452e:	75c080e7          	jalr	1884(ra) # 80000c86 <release>
  return 0;
    80004532:	4481                	li	s1,0
    80004534:	a819                	j	8000454a <filealloc+0x5e>
      f->ref = 1;
    80004536:	4785                	li	a5,1
    80004538:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000453a:	00194517          	auipc	a0,0x194
    8000453e:	d1650513          	add	a0,a0,-746 # 80198250 <ftable>
    80004542:	ffffc097          	auipc	ra,0xffffc
    80004546:	744080e7          	jalr	1860(ra) # 80000c86 <release>
}
    8000454a:	8526                	mv	a0,s1
    8000454c:	60e2                	ld	ra,24(sp)
    8000454e:	6442                	ld	s0,16(sp)
    80004550:	64a2                	ld	s1,8(sp)
    80004552:	6105                	add	sp,sp,32
    80004554:	8082                	ret

0000000080004556 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004556:	1101                	add	sp,sp,-32
    80004558:	ec06                	sd	ra,24(sp)
    8000455a:	e822                	sd	s0,16(sp)
    8000455c:	e426                	sd	s1,8(sp)
    8000455e:	1000                	add	s0,sp,32
    80004560:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004562:	00194517          	auipc	a0,0x194
    80004566:	cee50513          	add	a0,a0,-786 # 80198250 <ftable>
    8000456a:	ffffc097          	auipc	ra,0xffffc
    8000456e:	668080e7          	jalr	1640(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004572:	40dc                	lw	a5,4(s1)
    80004574:	02f05263          	blez	a5,80004598 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004578:	2785                	addw	a5,a5,1
    8000457a:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    8000457c:	00194517          	auipc	a0,0x194
    80004580:	cd450513          	add	a0,a0,-812 # 80198250 <ftable>
    80004584:	ffffc097          	auipc	ra,0xffffc
    80004588:	702080e7          	jalr	1794(ra) # 80000c86 <release>
  return f;
}
    8000458c:	8526                	mv	a0,s1
    8000458e:	60e2                	ld	ra,24(sp)
    80004590:	6442                	ld	s0,16(sp)
    80004592:	64a2                	ld	s1,8(sp)
    80004594:	6105                	add	sp,sp,32
    80004596:	8082                	ret
    panic("filedup");
    80004598:	00004517          	auipc	a0,0x4
    8000459c:	13850513          	add	a0,a0,312 # 800086d0 <syscalls+0x240>
    800045a0:	ffffc097          	auipc	ra,0xffffc
    800045a4:	f9c080e7          	jalr	-100(ra) # 8000053c <panic>

00000000800045a8 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800045a8:	7139                	add	sp,sp,-64
    800045aa:	fc06                	sd	ra,56(sp)
    800045ac:	f822                	sd	s0,48(sp)
    800045ae:	f426                	sd	s1,40(sp)
    800045b0:	f04a                	sd	s2,32(sp)
    800045b2:	ec4e                	sd	s3,24(sp)
    800045b4:	e852                	sd	s4,16(sp)
    800045b6:	e456                	sd	s5,8(sp)
    800045b8:	0080                	add	s0,sp,64
    800045ba:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800045bc:	00194517          	auipc	a0,0x194
    800045c0:	c9450513          	add	a0,a0,-876 # 80198250 <ftable>
    800045c4:	ffffc097          	auipc	ra,0xffffc
    800045c8:	60e080e7          	jalr	1550(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800045cc:	40dc                	lw	a5,4(s1)
    800045ce:	06f05163          	blez	a5,80004630 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800045d2:	37fd                	addw	a5,a5,-1
    800045d4:	0007871b          	sext.w	a4,a5
    800045d8:	c0dc                	sw	a5,4(s1)
    800045da:	06e04363          	bgtz	a4,80004640 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800045de:	0004a903          	lw	s2,0(s1)
    800045e2:	0094ca83          	lbu	s5,9(s1)
    800045e6:	0104ba03          	ld	s4,16(s1)
    800045ea:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800045ee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800045f2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800045f6:	00194517          	auipc	a0,0x194
    800045fa:	c5a50513          	add	a0,a0,-934 # 80198250 <ftable>
    800045fe:	ffffc097          	auipc	ra,0xffffc
    80004602:	688080e7          	jalr	1672(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    80004606:	4785                	li	a5,1
    80004608:	04f90d63          	beq	s2,a5,80004662 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    8000460c:	3979                	addw	s2,s2,-2
    8000460e:	4785                	li	a5,1
    80004610:	0527e063          	bltu	a5,s2,80004650 <fileclose+0xa8>
    begin_op();
    80004614:	00000097          	auipc	ra,0x0
    80004618:	ad0080e7          	jalr	-1328(ra) # 800040e4 <begin_op>
    iput(ff.ip);
    8000461c:	854e                	mv	a0,s3
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	2da080e7          	jalr	730(ra) # 800038f8 <iput>
    end_op();
    80004626:	00000097          	auipc	ra,0x0
    8000462a:	b38080e7          	jalr	-1224(ra) # 8000415e <end_op>
    8000462e:	a00d                	j	80004650 <fileclose+0xa8>
    panic("fileclose");
    80004630:	00004517          	auipc	a0,0x4
    80004634:	0a850513          	add	a0,a0,168 # 800086d8 <syscalls+0x248>
    80004638:	ffffc097          	auipc	ra,0xffffc
    8000463c:	f04080e7          	jalr	-252(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004640:	00194517          	auipc	a0,0x194
    80004644:	c1050513          	add	a0,a0,-1008 # 80198250 <ftable>
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	63e080e7          	jalr	1598(ra) # 80000c86 <release>
  }
}
    80004650:	70e2                	ld	ra,56(sp)
    80004652:	7442                	ld	s0,48(sp)
    80004654:	74a2                	ld	s1,40(sp)
    80004656:	7902                	ld	s2,32(sp)
    80004658:	69e2                	ld	s3,24(sp)
    8000465a:	6a42                	ld	s4,16(sp)
    8000465c:	6aa2                	ld	s5,8(sp)
    8000465e:	6121                	add	sp,sp,64
    80004660:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004662:	85d6                	mv	a1,s5
    80004664:	8552                	mv	a0,s4
    80004666:	00000097          	auipc	ra,0x0
    8000466a:	348080e7          	jalr	840(ra) # 800049ae <pipeclose>
    8000466e:	b7cd                	j	80004650 <fileclose+0xa8>

0000000080004670 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004670:	715d                	add	sp,sp,-80
    80004672:	e486                	sd	ra,72(sp)
    80004674:	e0a2                	sd	s0,64(sp)
    80004676:	fc26                	sd	s1,56(sp)
    80004678:	f84a                	sd	s2,48(sp)
    8000467a:	f44e                	sd	s3,40(sp)
    8000467c:	0880                	add	s0,sp,80
    8000467e:	84aa                	mv	s1,a0
    80004680:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004682:	ffffd097          	auipc	ra,0xffffd
    80004686:	374080e7          	jalr	884(ra) # 800019f6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000468a:	409c                	lw	a5,0(s1)
    8000468c:	37f9                	addw	a5,a5,-2
    8000468e:	4705                	li	a4,1
    80004690:	04f76763          	bltu	a4,a5,800046de <filestat+0x6e>
    80004694:	892a                	mv	s2,a0
    ilock(f->ip);
    80004696:	6c88                	ld	a0,24(s1)
    80004698:	fffff097          	auipc	ra,0xfffff
    8000469c:	0a6080e7          	jalr	166(ra) # 8000373e <ilock>
    stati(f->ip, &st);
    800046a0:	fb840593          	add	a1,s0,-72
    800046a4:	6c88                	ld	a0,24(s1)
    800046a6:	fffff097          	auipc	ra,0xfffff
    800046aa:	322080e7          	jalr	802(ra) # 800039c8 <stati>
    iunlock(f->ip);
    800046ae:	6c88                	ld	a0,24(s1)
    800046b0:	fffff097          	auipc	ra,0xfffff
    800046b4:	150080e7          	jalr	336(ra) # 80003800 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800046b8:	46e1                	li	a3,24
    800046ba:	fb840613          	add	a2,s0,-72
    800046be:	85ce                	mv	a1,s3
    800046c0:	05093503          	ld	a0,80(s2)
    800046c4:	ffffd097          	auipc	ra,0xffffd
    800046c8:	fe2080e7          	jalr	-30(ra) # 800016a6 <copyout>
    800046cc:	41f5551b          	sraw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800046d0:	60a6                	ld	ra,72(sp)
    800046d2:	6406                	ld	s0,64(sp)
    800046d4:	74e2                	ld	s1,56(sp)
    800046d6:	7942                	ld	s2,48(sp)
    800046d8:	79a2                	ld	s3,40(sp)
    800046da:	6161                	add	sp,sp,80
    800046dc:	8082                	ret
  return -1;
    800046de:	557d                	li	a0,-1
    800046e0:	bfc5                	j	800046d0 <filestat+0x60>

00000000800046e2 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800046e2:	7179                	add	sp,sp,-48
    800046e4:	f406                	sd	ra,40(sp)
    800046e6:	f022                	sd	s0,32(sp)
    800046e8:	ec26                	sd	s1,24(sp)
    800046ea:	e84a                	sd	s2,16(sp)
    800046ec:	e44e                	sd	s3,8(sp)
    800046ee:	1800                	add	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800046f0:	00854783          	lbu	a5,8(a0)
    800046f4:	c3d5                	beqz	a5,80004798 <fileread+0xb6>
    800046f6:	84aa                	mv	s1,a0
    800046f8:	89ae                	mv	s3,a1
    800046fa:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800046fc:	411c                	lw	a5,0(a0)
    800046fe:	4705                	li	a4,1
    80004700:	04e78963          	beq	a5,a4,80004752 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004704:	470d                	li	a4,3
    80004706:	04e78d63          	beq	a5,a4,80004760 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000470a:	4709                	li	a4,2
    8000470c:	06e79e63          	bne	a5,a4,80004788 <fileread+0xa6>
    ilock(f->ip);
    80004710:	6d08                	ld	a0,24(a0)
    80004712:	fffff097          	auipc	ra,0xfffff
    80004716:	02c080e7          	jalr	44(ra) # 8000373e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    8000471a:	874a                	mv	a4,s2
    8000471c:	5094                	lw	a3,32(s1)
    8000471e:	864e                	mv	a2,s3
    80004720:	4585                	li	a1,1
    80004722:	6c88                	ld	a0,24(s1)
    80004724:	fffff097          	auipc	ra,0xfffff
    80004728:	2ce080e7          	jalr	718(ra) # 800039f2 <readi>
    8000472c:	892a                	mv	s2,a0
    8000472e:	00a05563          	blez	a0,80004738 <fileread+0x56>
      f->off += r;
    80004732:	509c                	lw	a5,32(s1)
    80004734:	9fa9                	addw	a5,a5,a0
    80004736:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004738:	6c88                	ld	a0,24(s1)
    8000473a:	fffff097          	auipc	ra,0xfffff
    8000473e:	0c6080e7          	jalr	198(ra) # 80003800 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004742:	854a                	mv	a0,s2
    80004744:	70a2                	ld	ra,40(sp)
    80004746:	7402                	ld	s0,32(sp)
    80004748:	64e2                	ld	s1,24(sp)
    8000474a:	6942                	ld	s2,16(sp)
    8000474c:	69a2                	ld	s3,8(sp)
    8000474e:	6145                	add	sp,sp,48
    80004750:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004752:	6908                	ld	a0,16(a0)
    80004754:	00000097          	auipc	ra,0x0
    80004758:	3c2080e7          	jalr	962(ra) # 80004b16 <piperead>
    8000475c:	892a                	mv	s2,a0
    8000475e:	b7d5                	j	80004742 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004760:	02451783          	lh	a5,36(a0)
    80004764:	03079693          	sll	a3,a5,0x30
    80004768:	92c1                	srl	a3,a3,0x30
    8000476a:	4725                	li	a4,9
    8000476c:	02d76863          	bltu	a4,a3,8000479c <fileread+0xba>
    80004770:	0792                	sll	a5,a5,0x4
    80004772:	00194717          	auipc	a4,0x194
    80004776:	a3e70713          	add	a4,a4,-1474 # 801981b0 <devsw>
    8000477a:	97ba                	add	a5,a5,a4
    8000477c:	639c                	ld	a5,0(a5)
    8000477e:	c38d                	beqz	a5,800047a0 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004780:	4505                	li	a0,1
    80004782:	9782                	jalr	a5
    80004784:	892a                	mv	s2,a0
    80004786:	bf75                	j	80004742 <fileread+0x60>
    panic("fileread");
    80004788:	00004517          	auipc	a0,0x4
    8000478c:	f6050513          	add	a0,a0,-160 # 800086e8 <syscalls+0x258>
    80004790:	ffffc097          	auipc	ra,0xffffc
    80004794:	dac080e7          	jalr	-596(ra) # 8000053c <panic>
    return -1;
    80004798:	597d                	li	s2,-1
    8000479a:	b765                	j	80004742 <fileread+0x60>
      return -1;
    8000479c:	597d                	li	s2,-1
    8000479e:	b755                	j	80004742 <fileread+0x60>
    800047a0:	597d                	li	s2,-1
    800047a2:	b745                	j	80004742 <fileread+0x60>

00000000800047a4 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    800047a4:	00954783          	lbu	a5,9(a0)
    800047a8:	10078e63          	beqz	a5,800048c4 <filewrite+0x120>
{
    800047ac:	715d                	add	sp,sp,-80
    800047ae:	e486                	sd	ra,72(sp)
    800047b0:	e0a2                	sd	s0,64(sp)
    800047b2:	fc26                	sd	s1,56(sp)
    800047b4:	f84a                	sd	s2,48(sp)
    800047b6:	f44e                	sd	s3,40(sp)
    800047b8:	f052                	sd	s4,32(sp)
    800047ba:	ec56                	sd	s5,24(sp)
    800047bc:	e85a                	sd	s6,16(sp)
    800047be:	e45e                	sd	s7,8(sp)
    800047c0:	e062                	sd	s8,0(sp)
    800047c2:	0880                	add	s0,sp,80
    800047c4:	892a                	mv	s2,a0
    800047c6:	8b2e                	mv	s6,a1
    800047c8:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800047ca:	411c                	lw	a5,0(a0)
    800047cc:	4705                	li	a4,1
    800047ce:	02e78263          	beq	a5,a4,800047f2 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800047d2:	470d                	li	a4,3
    800047d4:	02e78563          	beq	a5,a4,800047fe <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800047d8:	4709                	li	a4,2
    800047da:	0ce79d63          	bne	a5,a4,800048b4 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800047de:	0ac05b63          	blez	a2,80004894 <filewrite+0xf0>
    int i = 0;
    800047e2:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800047e4:	6b85                	lui	s7,0x1
    800047e6:	c00b8b93          	add	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800047ea:	6c05                	lui	s8,0x1
    800047ec:	c00c0c1b          	addw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800047f0:	a851                	j	80004884 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800047f2:	6908                	ld	a0,16(a0)
    800047f4:	00000097          	auipc	ra,0x0
    800047f8:	22a080e7          	jalr	554(ra) # 80004a1e <pipewrite>
    800047fc:	a045                	j	8000489c <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800047fe:	02451783          	lh	a5,36(a0)
    80004802:	03079693          	sll	a3,a5,0x30
    80004806:	92c1                	srl	a3,a3,0x30
    80004808:	4725                	li	a4,9
    8000480a:	0ad76f63          	bltu	a4,a3,800048c8 <filewrite+0x124>
    8000480e:	0792                	sll	a5,a5,0x4
    80004810:	00194717          	auipc	a4,0x194
    80004814:	9a070713          	add	a4,a4,-1632 # 801981b0 <devsw>
    80004818:	97ba                	add	a5,a5,a4
    8000481a:	679c                	ld	a5,8(a5)
    8000481c:	cbc5                	beqz	a5,800048cc <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    8000481e:	4505                	li	a0,1
    80004820:	9782                	jalr	a5
    80004822:	a8ad                	j	8000489c <filewrite+0xf8>
      if(n1 > max)
    80004824:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    80004828:	00000097          	auipc	ra,0x0
    8000482c:	8bc080e7          	jalr	-1860(ra) # 800040e4 <begin_op>
      ilock(f->ip);
    80004830:	01893503          	ld	a0,24(s2)
    80004834:	fffff097          	auipc	ra,0xfffff
    80004838:	f0a080e7          	jalr	-246(ra) # 8000373e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    8000483c:	8756                	mv	a4,s5
    8000483e:	02092683          	lw	a3,32(s2)
    80004842:	01698633          	add	a2,s3,s6
    80004846:	4585                	li	a1,1
    80004848:	01893503          	ld	a0,24(s2)
    8000484c:	fffff097          	auipc	ra,0xfffff
    80004850:	29e080e7          	jalr	670(ra) # 80003aea <writei>
    80004854:	84aa                	mv	s1,a0
    80004856:	00a05763          	blez	a0,80004864 <filewrite+0xc0>
        f->off += r;
    8000485a:	02092783          	lw	a5,32(s2)
    8000485e:	9fa9                	addw	a5,a5,a0
    80004860:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004864:	01893503          	ld	a0,24(s2)
    80004868:	fffff097          	auipc	ra,0xfffff
    8000486c:	f98080e7          	jalr	-104(ra) # 80003800 <iunlock>
      end_op();
    80004870:	00000097          	auipc	ra,0x0
    80004874:	8ee080e7          	jalr	-1810(ra) # 8000415e <end_op>

      if(r != n1){
    80004878:	009a9f63          	bne	s5,s1,80004896 <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    8000487c:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004880:	0149db63          	bge	s3,s4,80004896 <filewrite+0xf2>
      int n1 = n - i;
    80004884:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    80004888:	0004879b          	sext.w	a5,s1
    8000488c:	f8fbdce3          	bge	s7,a5,80004824 <filewrite+0x80>
    80004890:	84e2                	mv	s1,s8
    80004892:	bf49                	j	80004824 <filewrite+0x80>
    int i = 0;
    80004894:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004896:	033a1d63          	bne	s4,s3,800048d0 <filewrite+0x12c>
    8000489a:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    8000489c:	60a6                	ld	ra,72(sp)
    8000489e:	6406                	ld	s0,64(sp)
    800048a0:	74e2                	ld	s1,56(sp)
    800048a2:	7942                	ld	s2,48(sp)
    800048a4:	79a2                	ld	s3,40(sp)
    800048a6:	7a02                	ld	s4,32(sp)
    800048a8:	6ae2                	ld	s5,24(sp)
    800048aa:	6b42                	ld	s6,16(sp)
    800048ac:	6ba2                	ld	s7,8(sp)
    800048ae:	6c02                	ld	s8,0(sp)
    800048b0:	6161                	add	sp,sp,80
    800048b2:	8082                	ret
    panic("filewrite");
    800048b4:	00004517          	auipc	a0,0x4
    800048b8:	e4450513          	add	a0,a0,-444 # 800086f8 <syscalls+0x268>
    800048bc:	ffffc097          	auipc	ra,0xffffc
    800048c0:	c80080e7          	jalr	-896(ra) # 8000053c <panic>
    return -1;
    800048c4:	557d                	li	a0,-1
}
    800048c6:	8082                	ret
      return -1;
    800048c8:	557d                	li	a0,-1
    800048ca:	bfc9                	j	8000489c <filewrite+0xf8>
    800048cc:	557d                	li	a0,-1
    800048ce:	b7f9                	j	8000489c <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800048d0:	557d                	li	a0,-1
    800048d2:	b7e9                	j	8000489c <filewrite+0xf8>

00000000800048d4 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800048d4:	7179                	add	sp,sp,-48
    800048d6:	f406                	sd	ra,40(sp)
    800048d8:	f022                	sd	s0,32(sp)
    800048da:	ec26                	sd	s1,24(sp)
    800048dc:	e84a                	sd	s2,16(sp)
    800048de:	e44e                	sd	s3,8(sp)
    800048e0:	e052                	sd	s4,0(sp)
    800048e2:	1800                	add	s0,sp,48
    800048e4:	84aa                	mv	s1,a0
    800048e6:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800048e8:	0005b023          	sd	zero,0(a1)
    800048ec:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800048f0:	00000097          	auipc	ra,0x0
    800048f4:	bfc080e7          	jalr	-1028(ra) # 800044ec <filealloc>
    800048f8:	e088                	sd	a0,0(s1)
    800048fa:	c551                	beqz	a0,80004986 <pipealloc+0xb2>
    800048fc:	00000097          	auipc	ra,0x0
    80004900:	bf0080e7          	jalr	-1040(ra) # 800044ec <filealloc>
    80004904:	00aa3023          	sd	a0,0(s4)
    80004908:	c92d                	beqz	a0,8000497a <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000490a:	ffffc097          	auipc	ra,0xffffc
    8000490e:	1d8080e7          	jalr	472(ra) # 80000ae2 <kalloc>
    80004912:	892a                	mv	s2,a0
    80004914:	c125                	beqz	a0,80004974 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004916:	4985                	li	s3,1
    80004918:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000491c:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004920:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004924:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004928:	00004597          	auipc	a1,0x4
    8000492c:	de058593          	add	a1,a1,-544 # 80008708 <syscalls+0x278>
    80004930:	ffffc097          	auipc	ra,0xffffc
    80004934:	212080e7          	jalr	530(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    80004938:	609c                	ld	a5,0(s1)
    8000493a:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    8000493e:	609c                	ld	a5,0(s1)
    80004940:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004944:	609c                	ld	a5,0(s1)
    80004946:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000494a:	609c                	ld	a5,0(s1)
    8000494c:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004950:	000a3783          	ld	a5,0(s4)
    80004954:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004958:	000a3783          	ld	a5,0(s4)
    8000495c:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004960:	000a3783          	ld	a5,0(s4)
    80004964:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004968:	000a3783          	ld	a5,0(s4)
    8000496c:	0127b823          	sd	s2,16(a5)
  return 0;
    80004970:	4501                	li	a0,0
    80004972:	a025                	j	8000499a <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004974:	6088                	ld	a0,0(s1)
    80004976:	e501                	bnez	a0,8000497e <pipealloc+0xaa>
    80004978:	a039                	j	80004986 <pipealloc+0xb2>
    8000497a:	6088                	ld	a0,0(s1)
    8000497c:	c51d                	beqz	a0,800049aa <pipealloc+0xd6>
    fileclose(*f0);
    8000497e:	00000097          	auipc	ra,0x0
    80004982:	c2a080e7          	jalr	-982(ra) # 800045a8 <fileclose>
  if(*f1)
    80004986:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000498a:	557d                	li	a0,-1
  if(*f1)
    8000498c:	c799                	beqz	a5,8000499a <pipealloc+0xc6>
    fileclose(*f1);
    8000498e:	853e                	mv	a0,a5
    80004990:	00000097          	auipc	ra,0x0
    80004994:	c18080e7          	jalr	-1000(ra) # 800045a8 <fileclose>
  return -1;
    80004998:	557d                	li	a0,-1
}
    8000499a:	70a2                	ld	ra,40(sp)
    8000499c:	7402                	ld	s0,32(sp)
    8000499e:	64e2                	ld	s1,24(sp)
    800049a0:	6942                	ld	s2,16(sp)
    800049a2:	69a2                	ld	s3,8(sp)
    800049a4:	6a02                	ld	s4,0(sp)
    800049a6:	6145                	add	sp,sp,48
    800049a8:	8082                	ret
  return -1;
    800049aa:	557d                	li	a0,-1
    800049ac:	b7fd                	j	8000499a <pipealloc+0xc6>

00000000800049ae <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    800049ae:	1101                	add	sp,sp,-32
    800049b0:	ec06                	sd	ra,24(sp)
    800049b2:	e822                	sd	s0,16(sp)
    800049b4:	e426                	sd	s1,8(sp)
    800049b6:	e04a                	sd	s2,0(sp)
    800049b8:	1000                	add	s0,sp,32
    800049ba:	84aa                	mv	s1,a0
    800049bc:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800049be:	ffffc097          	auipc	ra,0xffffc
    800049c2:	214080e7          	jalr	532(ra) # 80000bd2 <acquire>
  if(writable){
    800049c6:	02090d63          	beqz	s2,80004a00 <pipeclose+0x52>
    pi->writeopen = 0;
    800049ca:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800049ce:	21848513          	add	a0,s1,536
    800049d2:	ffffd097          	auipc	ra,0xffffd
    800049d6:	794080e7          	jalr	1940(ra) # 80002166 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800049da:	2204b783          	ld	a5,544(s1)
    800049de:	eb95                	bnez	a5,80004a12 <pipeclose+0x64>
    release(&pi->lock);
    800049e0:	8526                	mv	a0,s1
    800049e2:	ffffc097          	auipc	ra,0xffffc
    800049e6:	2a4080e7          	jalr	676(ra) # 80000c86 <release>
    kfree((char*)pi);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffc097          	auipc	ra,0xffffc
    800049f0:	ff8080e7          	jalr	-8(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800049f4:	60e2                	ld	ra,24(sp)
    800049f6:	6442                	ld	s0,16(sp)
    800049f8:	64a2                	ld	s1,8(sp)
    800049fa:	6902                	ld	s2,0(sp)
    800049fc:	6105                	add	sp,sp,32
    800049fe:	8082                	ret
    pi->readopen = 0;
    80004a00:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004a04:	21c48513          	add	a0,s1,540
    80004a08:	ffffd097          	auipc	ra,0xffffd
    80004a0c:	75e080e7          	jalr	1886(ra) # 80002166 <wakeup>
    80004a10:	b7e9                	j	800049da <pipeclose+0x2c>
    release(&pi->lock);
    80004a12:	8526                	mv	a0,s1
    80004a14:	ffffc097          	auipc	ra,0xffffc
    80004a18:	272080e7          	jalr	626(ra) # 80000c86 <release>
}
    80004a1c:	bfe1                	j	800049f4 <pipeclose+0x46>

0000000080004a1e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004a1e:	711d                	add	sp,sp,-96
    80004a20:	ec86                	sd	ra,88(sp)
    80004a22:	e8a2                	sd	s0,80(sp)
    80004a24:	e4a6                	sd	s1,72(sp)
    80004a26:	e0ca                	sd	s2,64(sp)
    80004a28:	fc4e                	sd	s3,56(sp)
    80004a2a:	f852                	sd	s4,48(sp)
    80004a2c:	f456                	sd	s5,40(sp)
    80004a2e:	f05a                	sd	s6,32(sp)
    80004a30:	ec5e                	sd	s7,24(sp)
    80004a32:	e862                	sd	s8,16(sp)
    80004a34:	1080                	add	s0,sp,96
    80004a36:	84aa                	mv	s1,a0
    80004a38:	8aae                	mv	s5,a1
    80004a3a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004a3c:	ffffd097          	auipc	ra,0xffffd
    80004a40:	fba080e7          	jalr	-70(ra) # 800019f6 <myproc>
    80004a44:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004a46:	8526                	mv	a0,s1
    80004a48:	ffffc097          	auipc	ra,0xffffc
    80004a4c:	18a080e7          	jalr	394(ra) # 80000bd2 <acquire>
  while(i < n){
    80004a50:	0b405663          	blez	s4,80004afc <pipewrite+0xde>
  int i = 0;
    80004a54:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004a56:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004a58:	21848c13          	add	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004a5c:	21c48b93          	add	s7,s1,540
    80004a60:	a089                	j	80004aa2 <pipewrite+0x84>
      release(&pi->lock);
    80004a62:	8526                	mv	a0,s1
    80004a64:	ffffc097          	auipc	ra,0xffffc
    80004a68:	222080e7          	jalr	546(ra) # 80000c86 <release>
      return -1;
    80004a6c:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004a6e:	854a                	mv	a0,s2
    80004a70:	60e6                	ld	ra,88(sp)
    80004a72:	6446                	ld	s0,80(sp)
    80004a74:	64a6                	ld	s1,72(sp)
    80004a76:	6906                	ld	s2,64(sp)
    80004a78:	79e2                	ld	s3,56(sp)
    80004a7a:	7a42                	ld	s4,48(sp)
    80004a7c:	7aa2                	ld	s5,40(sp)
    80004a7e:	7b02                	ld	s6,32(sp)
    80004a80:	6be2                	ld	s7,24(sp)
    80004a82:	6c42                	ld	s8,16(sp)
    80004a84:	6125                	add	sp,sp,96
    80004a86:	8082                	ret
      wakeup(&pi->nread);
    80004a88:	8562                	mv	a0,s8
    80004a8a:	ffffd097          	auipc	ra,0xffffd
    80004a8e:	6dc080e7          	jalr	1756(ra) # 80002166 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004a92:	85a6                	mv	a1,s1
    80004a94:	855e                	mv	a0,s7
    80004a96:	ffffd097          	auipc	ra,0xffffd
    80004a9a:	66c080e7          	jalr	1644(ra) # 80002102 <sleep>
  while(i < n){
    80004a9e:	07495063          	bge	s2,s4,80004afe <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004aa2:	2204a783          	lw	a5,544(s1)
    80004aa6:	dfd5                	beqz	a5,80004a62 <pipewrite+0x44>
    80004aa8:	854e                	mv	a0,s3
    80004aaa:	ffffe097          	auipc	ra,0xffffe
    80004aae:	918080e7          	jalr	-1768(ra) # 800023c2 <killed>
    80004ab2:	f945                	bnez	a0,80004a62 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004ab4:	2184a783          	lw	a5,536(s1)
    80004ab8:	21c4a703          	lw	a4,540(s1)
    80004abc:	2007879b          	addw	a5,a5,512
    80004ac0:	fcf704e3          	beq	a4,a5,80004a88 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004ac4:	4685                	li	a3,1
    80004ac6:	01590633          	add	a2,s2,s5
    80004aca:	faf40593          	add	a1,s0,-81
    80004ace:	0509b503          	ld	a0,80(s3)
    80004ad2:	ffffd097          	auipc	ra,0xffffd
    80004ad6:	c60080e7          	jalr	-928(ra) # 80001732 <copyin>
    80004ada:	03650263          	beq	a0,s6,80004afe <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004ade:	21c4a783          	lw	a5,540(s1)
    80004ae2:	0017871b          	addw	a4,a5,1
    80004ae6:	20e4ae23          	sw	a4,540(s1)
    80004aea:	1ff7f793          	and	a5,a5,511
    80004aee:	97a6                	add	a5,a5,s1
    80004af0:	faf44703          	lbu	a4,-81(s0)
    80004af4:	00e78c23          	sb	a4,24(a5)
      i++;
    80004af8:	2905                	addw	s2,s2,1
    80004afa:	b755                	j	80004a9e <pipewrite+0x80>
  int i = 0;
    80004afc:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004afe:	21848513          	add	a0,s1,536
    80004b02:	ffffd097          	auipc	ra,0xffffd
    80004b06:	664080e7          	jalr	1636(ra) # 80002166 <wakeup>
  release(&pi->lock);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	ffffc097          	auipc	ra,0xffffc
    80004b10:	17a080e7          	jalr	378(ra) # 80000c86 <release>
  return i;
    80004b14:	bfa9                	j	80004a6e <pipewrite+0x50>

0000000080004b16 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004b16:	715d                	add	sp,sp,-80
    80004b18:	e486                	sd	ra,72(sp)
    80004b1a:	e0a2                	sd	s0,64(sp)
    80004b1c:	fc26                	sd	s1,56(sp)
    80004b1e:	f84a                	sd	s2,48(sp)
    80004b20:	f44e                	sd	s3,40(sp)
    80004b22:	f052                	sd	s4,32(sp)
    80004b24:	ec56                	sd	s5,24(sp)
    80004b26:	e85a                	sd	s6,16(sp)
    80004b28:	0880                	add	s0,sp,80
    80004b2a:	84aa                	mv	s1,a0
    80004b2c:	892e                	mv	s2,a1
    80004b2e:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004b30:	ffffd097          	auipc	ra,0xffffd
    80004b34:	ec6080e7          	jalr	-314(ra) # 800019f6 <myproc>
    80004b38:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004b3a:	8526                	mv	a0,s1
    80004b3c:	ffffc097          	auipc	ra,0xffffc
    80004b40:	096080e7          	jalr	150(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b44:	2184a703          	lw	a4,536(s1)
    80004b48:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b4c:	21848993          	add	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b50:	02f71763          	bne	a4,a5,80004b7e <piperead+0x68>
    80004b54:	2244a783          	lw	a5,548(s1)
    80004b58:	c39d                	beqz	a5,80004b7e <piperead+0x68>
    if(killed(pr)){
    80004b5a:	8552                	mv	a0,s4
    80004b5c:	ffffe097          	auipc	ra,0xffffe
    80004b60:	866080e7          	jalr	-1946(ra) # 800023c2 <killed>
    80004b64:	e949                	bnez	a0,80004bf6 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004b66:	85a6                	mv	a1,s1
    80004b68:	854e                	mv	a0,s3
    80004b6a:	ffffd097          	auipc	ra,0xffffd
    80004b6e:	598080e7          	jalr	1432(ra) # 80002102 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004b72:	2184a703          	lw	a4,536(s1)
    80004b76:	21c4a783          	lw	a5,540(s1)
    80004b7a:	fcf70de3          	beq	a4,a5,80004b54 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b7e:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004b80:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004b82:	05505463          	blez	s5,80004bca <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004b86:	2184a783          	lw	a5,536(s1)
    80004b8a:	21c4a703          	lw	a4,540(s1)
    80004b8e:	02f70e63          	beq	a4,a5,80004bca <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004b92:	0017871b          	addw	a4,a5,1
    80004b96:	20e4ac23          	sw	a4,536(s1)
    80004b9a:	1ff7f793          	and	a5,a5,511
    80004b9e:	97a6                	add	a5,a5,s1
    80004ba0:	0187c783          	lbu	a5,24(a5)
    80004ba4:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004ba8:	4685                	li	a3,1
    80004baa:	fbf40613          	add	a2,s0,-65
    80004bae:	85ca                	mv	a1,s2
    80004bb0:	050a3503          	ld	a0,80(s4)
    80004bb4:	ffffd097          	auipc	ra,0xffffd
    80004bb8:	af2080e7          	jalr	-1294(ra) # 800016a6 <copyout>
    80004bbc:	01650763          	beq	a0,s6,80004bca <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004bc0:	2985                	addw	s3,s3,1
    80004bc2:	0905                	add	s2,s2,1
    80004bc4:	fd3a91e3          	bne	s5,s3,80004b86 <piperead+0x70>
    80004bc8:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004bca:	21c48513          	add	a0,s1,540
    80004bce:	ffffd097          	auipc	ra,0xffffd
    80004bd2:	598080e7          	jalr	1432(ra) # 80002166 <wakeup>
  release(&pi->lock);
    80004bd6:	8526                	mv	a0,s1
    80004bd8:	ffffc097          	auipc	ra,0xffffc
    80004bdc:	0ae080e7          	jalr	174(ra) # 80000c86 <release>
  return i;
}
    80004be0:	854e                	mv	a0,s3
    80004be2:	60a6                	ld	ra,72(sp)
    80004be4:	6406                	ld	s0,64(sp)
    80004be6:	74e2                	ld	s1,56(sp)
    80004be8:	7942                	ld	s2,48(sp)
    80004bea:	79a2                	ld	s3,40(sp)
    80004bec:	7a02                	ld	s4,32(sp)
    80004bee:	6ae2                	ld	s5,24(sp)
    80004bf0:	6b42                	ld	s6,16(sp)
    80004bf2:	6161                	add	sp,sp,80
    80004bf4:	8082                	ret
      release(&pi->lock);
    80004bf6:	8526                	mv	a0,s1
    80004bf8:	ffffc097          	auipc	ra,0xffffc
    80004bfc:	08e080e7          	jalr	142(ra) # 80000c86 <release>
      return -1;
    80004c00:	59fd                	li	s3,-1
    80004c02:	bff9                	j	80004be0 <piperead+0xca>

0000000080004c04 <flags2perm>:

// static 
int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004c04:	1141                	add	sp,sp,-16
    80004c06:	e422                	sd	s0,8(sp)
    80004c08:	0800                	add	s0,sp,16
    80004c0a:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004c0c:	8905                	and	a0,a0,1
    80004c0e:	050e                	sll	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004c10:	8b89                	and	a5,a5,2
    80004c12:	c399                	beqz	a5,80004c18 <flags2perm+0x14>
      perm |= PTE_W;
    80004c14:	00456513          	or	a0,a0,4
    return perm;
}
    80004c18:	6422                	ld	s0,8(sp)
    80004c1a:	0141                	add	sp,sp,16
    80004c1c:	8082                	ret

0000000080004c1e <loadseg>:
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004c1e:	c749                	beqz	a4,80004ca8 <loadseg+0x8a>
{
    80004c20:	711d                	add	sp,sp,-96
    80004c22:	ec86                	sd	ra,88(sp)
    80004c24:	e8a2                	sd	s0,80(sp)
    80004c26:	e4a6                	sd	s1,72(sp)
    80004c28:	e0ca                	sd	s2,64(sp)
    80004c2a:	fc4e                	sd	s3,56(sp)
    80004c2c:	f852                	sd	s4,48(sp)
    80004c2e:	f456                	sd	s5,40(sp)
    80004c30:	f05a                	sd	s6,32(sp)
    80004c32:	ec5e                	sd	s7,24(sp)
    80004c34:	e862                	sd	s8,16(sp)
    80004c36:	e466                	sd	s9,8(sp)
    80004c38:	1080                	add	s0,sp,96
    80004c3a:	8aaa                	mv	s5,a0
    80004c3c:	8b2e                	mv	s6,a1
    80004c3e:	8bb2                	mv	s7,a2
    80004c40:	8c36                	mv	s8,a3
    80004c42:	89ba                	mv	s3,a4
  for(i = 0; i < sz; i += PGSIZE){
    80004c44:	4901                	li	s2,0
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004c46:	6c85                	lui	s9,0x1
    80004c48:	6a05                	lui	s4,0x1
    80004c4a:	a815                	j	80004c7e <loadseg+0x60>
      panic("loadseg: address should exist");
    80004c4c:	00004517          	auipc	a0,0x4
    80004c50:	ac450513          	add	a0,a0,-1340 # 80008710 <syscalls+0x280>
    80004c54:	ffffc097          	auipc	ra,0xffffc
    80004c58:	8e8080e7          	jalr	-1816(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004c5c:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c5e:	8726                	mv	a4,s1
    80004c60:	012c06bb          	addw	a3,s8,s2
    80004c64:	4581                	li	a1,0
    80004c66:	855e                	mv	a0,s7
    80004c68:	fffff097          	auipc	ra,0xfffff
    80004c6c:	d8a080e7          	jalr	-630(ra) # 800039f2 <readi>
    80004c70:	2501                	sext.w	a0,a0
    80004c72:	02951d63          	bne	a0,s1,80004cac <loadseg+0x8e>
  for(i = 0; i < sz; i += PGSIZE){
    80004c76:	012a093b          	addw	s2,s4,s2
    80004c7a:	03397563          	bgeu	s2,s3,80004ca4 <loadseg+0x86>
    pa = walkaddr(pagetable, va + i);
    80004c7e:	02091593          	sll	a1,s2,0x20
    80004c82:	9181                	srl	a1,a1,0x20
    80004c84:	95da                	add	a1,a1,s6
    80004c86:	8556                	mv	a0,s5
    80004c88:	ffffc097          	auipc	ra,0xffffc
    80004c8c:	3d6080e7          	jalr	982(ra) # 8000105e <walkaddr>
    80004c90:	862a                	mv	a2,a0
    if(pa == 0)
    80004c92:	dd4d                	beqz	a0,80004c4c <loadseg+0x2e>
    if(sz - i < PGSIZE)
    80004c94:	412984bb          	subw	s1,s3,s2
    80004c98:	0004879b          	sext.w	a5,s1
    80004c9c:	fcfcf0e3          	bgeu	s9,a5,80004c5c <loadseg+0x3e>
    80004ca0:	84d2                	mv	s1,s4
    80004ca2:	bf6d                	j	80004c5c <loadseg+0x3e>
      return -1;
  }
  
  return 0;
    80004ca4:	4501                	li	a0,0
    80004ca6:	a021                	j	80004cae <loadseg+0x90>
    80004ca8:	4501                	li	a0,0
}
    80004caa:	8082                	ret
      return -1;
    80004cac:	557d                	li	a0,-1
}
    80004cae:	60e6                	ld	ra,88(sp)
    80004cb0:	6446                	ld	s0,80(sp)
    80004cb2:	64a6                	ld	s1,72(sp)
    80004cb4:	6906                	ld	s2,64(sp)
    80004cb6:	79e2                	ld	s3,56(sp)
    80004cb8:	7a42                	ld	s4,48(sp)
    80004cba:	7aa2                	ld	s5,40(sp)
    80004cbc:	7b02                	ld	s6,32(sp)
    80004cbe:	6be2                	ld	s7,24(sp)
    80004cc0:	6c42                	ld	s8,16(sp)
    80004cc2:	6ca2                	ld	s9,8(sp)
    80004cc4:	6125                	add	sp,sp,96
    80004cc6:	8082                	ret

0000000080004cc8 <exec>:
{
    80004cc8:	7101                	add	sp,sp,-512
    80004cca:	ff86                	sd	ra,504(sp)
    80004ccc:	fba2                	sd	s0,496(sp)
    80004cce:	f7a6                	sd	s1,488(sp)
    80004cd0:	f3ca                	sd	s2,480(sp)
    80004cd2:	efce                	sd	s3,472(sp)
    80004cd4:	ebd2                	sd	s4,464(sp)
    80004cd6:	e7d6                	sd	s5,456(sp)
    80004cd8:	e3da                	sd	s6,448(sp)
    80004cda:	ff5e                	sd	s7,440(sp)
    80004cdc:	fb62                	sd	s8,432(sp)
    80004cde:	f766                	sd	s9,424(sp)
    80004ce0:	f36a                	sd	s10,416(sp)
    80004ce2:	ef6e                	sd	s11,408(sp)
    80004ce4:	0400                	add	s0,sp,512
    80004ce6:	89aa                	mv	s3,a0
    80004ce8:	8c2e                	mv	s8,a1
  struct proc *p = myproc();
    80004cea:	ffffd097          	auipc	ra,0xffffd
    80004cee:	d0c080e7          	jalr	-756(ra) # 800019f6 <myproc>
    80004cf2:	8a2a                	mv	s4,a0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004cf4:	4615                	li	a2,5
    80004cf6:	00004597          	auipc	a1,0x4
    80004cfa:	a3a58593          	add	a1,a1,-1478 # 80008730 <syscalls+0x2a0>
    80004cfe:	854e                	mv	a0,s3
    80004d00:	ffffc097          	auipc	ra,0xffffc
    80004d04:	09e080e7          	jalr	158(ra) # 80000d9e <strncmp>
    p->ondemand = false;
    80004d08:	4781                	li	a5,0
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004d0a:	e159                	bnez	a0,80004d90 <exec+0xc8>
    80004d0c:	16fa0423          	sb	a5,360(s4) # 1168 <_entry-0x7fffee98>
  begin_op();
    80004d10:	fffff097          	auipc	ra,0xfffff
    80004d14:	3d4080e7          	jalr	980(ra) # 800040e4 <begin_op>
  if((ip = namei(path)) == 0){
    80004d18:	854e                	mv	a0,s3
    80004d1a:	fffff097          	auipc	ra,0xfffff
    80004d1e:	1ca080e7          	jalr	458(ra) # 80003ee4 <namei>
    80004d22:	84aa                	mv	s1,a0
    80004d24:	c159                	beqz	a0,80004daa <exec+0xe2>
  ilock(ip);
    80004d26:	fffff097          	auipc	ra,0xfffff
    80004d2a:	a18080e7          	jalr	-1512(ra) # 8000373e <ilock>
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004d2e:	04000713          	li	a4,64
    80004d32:	4681                	li	a3,0
    80004d34:	e5040613          	add	a2,s0,-432
    80004d38:	4581                	li	a1,0
    80004d3a:	8526                	mv	a0,s1
    80004d3c:	fffff097          	auipc	ra,0xfffff
    80004d40:	cb6080e7          	jalr	-842(ra) # 800039f2 <readi>
    80004d44:	04000793          	li	a5,64
    80004d48:	00f51a63          	bne	a0,a5,80004d5c <exec+0x94>
  if(elf.magic != ELF_MAGIC)
    80004d4c:	e5042703          	lw	a4,-432(s0)
    80004d50:	464c47b7          	lui	a5,0x464c4
    80004d54:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004d58:	04f70f63          	beq	a4,a5,80004db6 <exec+0xee>
    iunlockput(ip);
    80004d5c:	8526                	mv	a0,s1
    80004d5e:	fffff097          	auipc	ra,0xfffff
    80004d62:	c42080e7          	jalr	-958(ra) # 800039a0 <iunlockput>
    end_op();
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	3f8080e7          	jalr	1016(ra) # 8000415e <end_op>
  return -1;
    80004d6e:	557d                	li	a0,-1
}
    80004d70:	70fe                	ld	ra,504(sp)
    80004d72:	745e                	ld	s0,496(sp)
    80004d74:	74be                	ld	s1,488(sp)
    80004d76:	791e                	ld	s2,480(sp)
    80004d78:	69fe                	ld	s3,472(sp)
    80004d7a:	6a5e                	ld	s4,464(sp)
    80004d7c:	6abe                	ld	s5,456(sp)
    80004d7e:	6b1e                	ld	s6,448(sp)
    80004d80:	7bfa                	ld	s7,440(sp)
    80004d82:	7c5a                	ld	s8,432(sp)
    80004d84:	7cba                	ld	s9,424(sp)
    80004d86:	7d1a                	ld	s10,416(sp)
    80004d88:	6dfa                	ld	s11,408(sp)
    80004d8a:	20010113          	add	sp,sp,512
    80004d8e:	8082                	ret
  if (strncmp(path, "/init", 5) == 0 || strncmp(path, "sh", 2) == 0) {
    80004d90:	4609                	li	a2,2
    80004d92:	00004597          	auipc	a1,0x4
    80004d96:	9a658593          	add	a1,a1,-1626 # 80008738 <syscalls+0x2a8>
    80004d9a:	854e                	mv	a0,s3
    80004d9c:	ffffc097          	auipc	ra,0xffffc
    80004da0:	002080e7          	jalr	2(ra) # 80000d9e <strncmp>
    80004da4:	00a037b3          	snez	a5,a0
    80004da8:	b795                	j	80004d0c <exec+0x44>
    end_op();
    80004daa:	fffff097          	auipc	ra,0xfffff
    80004dae:	3b4080e7          	jalr	948(ra) # 8000415e <end_op>
    return -1;
    80004db2:	557d                	li	a0,-1
    80004db4:	bf75                	j	80004d70 <exec+0xa8>
  if((pagetable = proc_pagetable(p)) == 0)
    80004db6:	8552                	mv	a0,s4
    80004db8:	ffffd097          	auipc	ra,0xffffd
    80004dbc:	d02080e7          	jalr	-766(ra) # 80001aba <proc_pagetable>
    80004dc0:	8caa                	mv	s9,a0
    80004dc2:	dd49                	beqz	a0,80004d5c <exec+0x94>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dc4:	e7042903          	lw	s2,-400(s0)
    80004dc8:	e8845783          	lhu	a5,-376(s0)
    80004dcc:	cbf1                	beqz	a5,80004ea0 <exec+0x1d8>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004dce:	4b81                	li	s7,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004dd0:	4a81                	li	s5,0
    if(ph.type != ELF_PROG_LOAD)
    80004dd2:	4d05                	li	s10,1
    if(ph.vaddr % PGSIZE != 0)
    80004dd4:	6d85                	lui	s11,0x1
    80004dd6:	1dfd                	add	s11,s11,-1 # fff <_entry-0x7ffff001>
    80004dd8:	a83d                	j	80004e16 <exec+0x14e>
      print_ondemand_proc(path);
    80004dda:	854e                	mv	a0,s3
    80004ddc:	00002097          	auipc	ra,0x2
    80004de0:	812080e7          	jalr	-2030(ra) # 800065ee <print_ondemand_proc>
      print_skip_section(path, ph.vaddr, ph.memsz);
    80004de4:	e4042603          	lw	a2,-448(s0)
    80004de8:	e2843583          	ld	a1,-472(s0)
    80004dec:	854e                	mv	a0,s3
    80004dee:	00002097          	auipc	ra,0x2
    80004df2:	822080e7          	jalr	-2014(ra) # 80006610 <print_skip_section>
      sz = PGROUNDUP(ph.vaddr + ph.memsz);
    80004df6:	e2843b83          	ld	s7,-472(s0)
    80004dfa:	e4043783          	ld	a5,-448(s0)
    80004dfe:	9bbe                	add	s7,s7,a5
    80004e00:	9bee                	add	s7,s7,s11
    80004e02:	77fd                	lui	a5,0xfffff
    80004e04:	00fbfbb3          	and	s7,s7,a5
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004e08:	2a85                	addw	s5,s5,1
    80004e0a:	0389091b          	addw	s2,s2,56
    80004e0e:	e8845783          	lhu	a5,-376(s0)
    80004e12:	08fad863          	bge	s5,a5,80004ea2 <exec+0x1da>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004e16:	2901                	sext.w	s2,s2
    80004e18:	03800713          	li	a4,56
    80004e1c:	86ca                	mv	a3,s2
    80004e1e:	e1840613          	add	a2,s0,-488
    80004e22:	4581                	li	a1,0
    80004e24:	8526                	mv	a0,s1
    80004e26:	fffff097          	auipc	ra,0xfffff
    80004e2a:	bcc080e7          	jalr	-1076(ra) # 800039f2 <readi>
    80004e2e:	03800793          	li	a5,56
    80004e32:	0af51c63          	bne	a0,a5,80004eea <exec+0x222>
    if(ph.type != ELF_PROG_LOAD)
    80004e36:	e1842783          	lw	a5,-488(s0)
    80004e3a:	fda797e3          	bne	a5,s10,80004e08 <exec+0x140>
    if(ph.memsz < ph.filesz)
    80004e3e:	e4043b03          	ld	s6,-448(s0)
    80004e42:	e3843783          	ld	a5,-456(s0)
    80004e46:	0afb6263          	bltu	s6,a5,80004eea <exec+0x222>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004e4a:	e2843783          	ld	a5,-472(s0)
    80004e4e:	9b3e                	add	s6,s6,a5
    80004e50:	08fb6d63          	bltu	s6,a5,80004eea <exec+0x222>
    if(ph.vaddr % PGSIZE != 0)
    80004e54:	01b7f7b3          	and	a5,a5,s11
    80004e58:	ebc9                	bnez	a5,80004eea <exec+0x222>
    if(p->ondemand == false){
    80004e5a:	168a4783          	lbu	a5,360(s4)
    80004e5e:	ffb5                	bnez	a5,80004dda <exec+0x112>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e60:	e1c42503          	lw	a0,-484(s0)
    80004e64:	00000097          	auipc	ra,0x0
    80004e68:	da0080e7          	jalr	-608(ra) # 80004c04 <flags2perm>
    80004e6c:	86aa                	mv	a3,a0
    80004e6e:	865a                	mv	a2,s6
    80004e70:	85de                	mv	a1,s7
    80004e72:	8566                	mv	a0,s9
    80004e74:	ffffc097          	auipc	ra,0xffffc
    80004e78:	590080e7          	jalr	1424(ra) # 80001404 <uvmalloc>
    80004e7c:	8b2a                	mv	s6,a0
    80004e7e:	c535                	beqz	a0,80004eea <exec+0x222>
      if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004e80:	e3842703          	lw	a4,-456(s0)
    80004e84:	e2042683          	lw	a3,-480(s0)
    80004e88:	8626                	mv	a2,s1
    80004e8a:	e2843583          	ld	a1,-472(s0)
    80004e8e:	8566                	mv	a0,s9
    80004e90:	00000097          	auipc	ra,0x0
    80004e94:	d8e080e7          	jalr	-626(ra) # 80004c1e <loadseg>
    80004e98:	1a054263          	bltz	a0,8000503c <exec+0x374>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004e9c:	8bda                	mv	s7,s6
    80004e9e:	b7ad                	j	80004e08 <exec+0x140>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ea0:	4b81                	li	s7,0
  iunlockput(ip);
    80004ea2:	8526                	mv	a0,s1
    80004ea4:	fffff097          	auipc	ra,0xfffff
    80004ea8:	afc080e7          	jalr	-1284(ra) # 800039a0 <iunlockput>
  end_op();
    80004eac:	fffff097          	auipc	ra,0xfffff
    80004eb0:	2b2080e7          	jalr	690(ra) # 8000415e <end_op>
  p = myproc();
    80004eb4:	ffffd097          	auipc	ra,0xffffd
    80004eb8:	b42080e7          	jalr	-1214(ra) # 800019f6 <myproc>
    80004ebc:	8d2a                	mv	s10,a0
  uint64 oldsz = p->sz;
    80004ebe:	653c                	ld	a5,72(a0)
    80004ec0:	e0f43423          	sd	a5,-504(s0)
  sz = PGROUNDUP(sz);
    80004ec4:	6a05                	lui	s4,0x1
    80004ec6:	1a7d                	add	s4,s4,-1 # fff <_entry-0x7ffff001>
    80004ec8:	9a5e                	add	s4,s4,s7
    80004eca:	77fd                	lui	a5,0xfffff
    80004ecc:	00fa7a33          	and	s4,s4,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004ed0:	4691                	li	a3,4
    80004ed2:	6609                	lui	a2,0x2
    80004ed4:	9652                	add	a2,a2,s4
    80004ed6:	85d2                	mv	a1,s4
    80004ed8:	8566                	mv	a0,s9
    80004eda:	ffffc097          	auipc	ra,0xffffc
    80004ede:	52a080e7          	jalr	1322(ra) # 80001404 <uvmalloc>
    80004ee2:	8baa                	mv	s7,a0
    80004ee4:	ed09                	bnez	a0,80004efe <exec+0x236>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ee6:	8bd2                	mv	s7,s4
    80004ee8:	4481                	li	s1,0
    proc_freepagetable(pagetable, sz);
    80004eea:	85de                	mv	a1,s7
    80004eec:	8566                	mv	a0,s9
    80004eee:	ffffd097          	auipc	ra,0xffffd
    80004ef2:	c68080e7          	jalr	-920(ra) # 80001b56 <proc_freepagetable>
  return -1;
    80004ef6:	557d                	li	a0,-1
  if(ip){
    80004ef8:	e6048ce3          	beqz	s1,80004d70 <exec+0xa8>
    80004efc:	b585                	j	80004d5c <exec+0x94>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004efe:	75f9                	lui	a1,0xffffe
    80004f00:	95aa                	add	a1,a1,a0
    80004f02:	8566                	mv	a0,s9
    80004f04:	ffffc097          	auipc	ra,0xffffc
    80004f08:	73e080e7          	jalr	1854(ra) # 80001642 <uvmclear>
  stackbase = sp - PGSIZE;
    80004f0c:	7b7d                	lui	s6,0xfffff
    80004f0e:	9b5e                	add	s6,s6,s7
  for(argc = 0; argv[argc]; argc++) {
    80004f10:	000c3503          	ld	a0,0(s8)
    80004f14:	c125                	beqz	a0,80004f74 <exec+0x2ac>
    80004f16:	e9040a13          	add	s4,s0,-368
    80004f1a:	f9040d93          	add	s11,s0,-112
  sp = sz;
    80004f1e:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80004f20:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004f22:	ffffc097          	auipc	ra,0xffffc
    80004f26:	f26080e7          	jalr	-218(ra) # 80000e48 <strlen>
    80004f2a:	2505                	addw	a0,a0,1
    80004f2c:	40a90533          	sub	a0,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004f30:	ff057913          	and	s2,a0,-16
    if(sp < stackbase)
    80004f34:	11696663          	bltu	s2,s6,80005040 <exec+0x378>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004f38:	000c3a83          	ld	s5,0(s8)
    80004f3c:	8556                	mv	a0,s5
    80004f3e:	ffffc097          	auipc	ra,0xffffc
    80004f42:	f0a080e7          	jalr	-246(ra) # 80000e48 <strlen>
    80004f46:	0015069b          	addw	a3,a0,1
    80004f4a:	8656                	mv	a2,s5
    80004f4c:	85ca                	mv	a1,s2
    80004f4e:	8566                	mv	a0,s9
    80004f50:	ffffc097          	auipc	ra,0xffffc
    80004f54:	756080e7          	jalr	1878(ra) # 800016a6 <copyout>
    80004f58:	0e054663          	bltz	a0,80005044 <exec+0x37c>
    ustack[argc] = sp;
    80004f5c:	012a3023          	sd	s2,0(s4)
  for(argc = 0; argv[argc]; argc++) {
    80004f60:	0485                	add	s1,s1,1
    80004f62:	0c21                	add	s8,s8,8
    80004f64:	000c3503          	ld	a0,0(s8)
    80004f68:	c901                	beqz	a0,80004f78 <exec+0x2b0>
    if(argc >= MAXARG)
    80004f6a:	0a21                	add	s4,s4,8
    80004f6c:	fbba1be3          	bne	s4,s11,80004f22 <exec+0x25a>
  ip = 0;
    80004f70:	4481                	li	s1,0
    80004f72:	bfa5                	j	80004eea <exec+0x222>
  sp = sz;
    80004f74:	895e                	mv	s2,s7
  for(argc = 0; argv[argc]; argc++) {
    80004f76:	4481                	li	s1,0
  ustack[argc] = 0;
    80004f78:	00349793          	sll	a5,s1,0x3
    80004f7c:	f9078793          	add	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7fe65860>
    80004f80:	97a2                	add	a5,a5,s0
    80004f82:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004f86:	00148693          	add	a3,s1,1
    80004f8a:	068e                	sll	a3,a3,0x3
    80004f8c:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004f90:	ff097913          	and	s2,s2,-16
  sz = sz1;
    80004f94:	8a5e                	mv	s4,s7
  if(sp < stackbase)
    80004f96:	f56968e3          	bltu	s2,s6,80004ee6 <exec+0x21e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004f9a:	e9040613          	add	a2,s0,-368
    80004f9e:	85ca                	mv	a1,s2
    80004fa0:	8566                	mv	a0,s9
    80004fa2:	ffffc097          	auipc	ra,0xffffc
    80004fa6:	704080e7          	jalr	1796(ra) # 800016a6 <copyout>
    80004faa:	f2054ee3          	bltz	a0,80004ee6 <exec+0x21e>
  p->trapframe->a1 = sp;
    80004fae:	058d3783          	ld	a5,88(s10)
    80004fb2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004fb6:	0009c703          	lbu	a4,0(s3)
    80004fba:	cf11                	beqz	a4,80004fd6 <exec+0x30e>
    80004fbc:	00198793          	add	a5,s3,1
    if(*s == '/')
    80004fc0:	02f00693          	li	a3,47
    80004fc4:	a029                	j	80004fce <exec+0x306>
  for(last=s=path; *s; s++)
    80004fc6:	0785                	add	a5,a5,1
    80004fc8:	fff7c703          	lbu	a4,-1(a5)
    80004fcc:	c709                	beqz	a4,80004fd6 <exec+0x30e>
    if(*s == '/')
    80004fce:	fed71ce3          	bne	a4,a3,80004fc6 <exec+0x2fe>
      last = s+1;
    80004fd2:	89be                	mv	s3,a5
    80004fd4:	bfcd                	j	80004fc6 <exec+0x2fe>
  safestrcpy(p->name, last, sizeof(p->name));
    80004fd6:	4641                	li	a2,16
    80004fd8:	85ce                	mv	a1,s3
    80004fda:	158d0513          	add	a0,s10,344
    80004fde:	ffffc097          	auipc	ra,0xffffc
    80004fe2:	e38080e7          	jalr	-456(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004fe6:	050d3503          	ld	a0,80(s10)
  p->pagetable = pagetable;
    80004fea:	059d3823          	sd	s9,80(s10)
  p->sz = sz;
    80004fee:	057d3423          	sd	s7,72(s10)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004ff2:	058d3783          	ld	a5,88(s10)
    80004ff6:	e6843703          	ld	a4,-408(s0)
    80004ffa:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004ffc:	058d3783          	ld	a5,88(s10)
    80005000:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80005004:	e0843583          	ld	a1,-504(s0)
    80005008:	ffffd097          	auipc	ra,0xffffd
    8000500c:	b4e080e7          	jalr	-1202(ra) # 80001b56 <proc_freepagetable>
  for (int i = 0; i < MAXHEAP; i++) {
    80005010:	170d0793          	add	a5,s10,368
    80005014:	6699                	lui	a3,0x6
    80005016:	f3068693          	add	a3,a3,-208 # 5f30 <_entry-0x7fffa0d0>
    8000501a:	96ea                	add	a3,a3,s10
    p->heap_tracker[i].addr            = 0xFFFFFFFFFFFFFFFF;
    8000501c:	577d                	li	a4,-1
    8000501e:	e398                	sd	a4,0(a5)
    p->heap_tracker[i].startblock      = -1;
    80005020:	cbd8                	sw	a4,20(a5)
    p->heap_tracker[i].last_load_time  = 0xFFFFFFFFFFFFFFFF;
    80005022:	e798                	sd	a4,8(a5)
    p->heap_tracker[i].loaded          = false;
    80005024:	00078823          	sb	zero,16(a5)
  for (int i = 0; i < MAXHEAP; i++) {
    80005028:	07e1                	add	a5,a5,24
    8000502a:	fed79ae3          	bne	a5,a3,8000501e <exec+0x356>
  p->resident_heap_pages = 0;
    8000502e:	6799                	lui	a5,0x6
    80005030:	9d3e                	add	s10,s10,a5
    80005032:	f20d2823          	sw	zero,-208(s10)
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80005036:	0004851b          	sext.w	a0,s1
    8000503a:	bb1d                	j	80004d70 <exec+0xa8>
      if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    8000503c:	8bda                	mv	s7,s6
    8000503e:	b575                	j	80004eea <exec+0x222>
  ip = 0;
    80005040:	4481                	li	s1,0
    80005042:	b565                	j	80004eea <exec+0x222>
    80005044:	4481                	li	s1,0
  if(pagetable)
    80005046:	b555                	j	80004eea <exec+0x222>

0000000080005048 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80005048:	7179                	add	sp,sp,-48
    8000504a:	f406                	sd	ra,40(sp)
    8000504c:	f022                	sd	s0,32(sp)
    8000504e:	ec26                	sd	s1,24(sp)
    80005050:	e84a                	sd	s2,16(sp)
    80005052:	1800                	add	s0,sp,48
    80005054:	892e                	mv	s2,a1
    80005056:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80005058:	fdc40593          	add	a1,s0,-36
    8000505c:	ffffe097          	auipc	ra,0xffffe
    80005060:	b80080e7          	jalr	-1152(ra) # 80002bdc <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005064:	fdc42703          	lw	a4,-36(s0)
    80005068:	47bd                	li	a5,15
    8000506a:	02e7eb63          	bltu	a5,a4,800050a0 <argfd+0x58>
    8000506e:	ffffd097          	auipc	ra,0xffffd
    80005072:	988080e7          	jalr	-1656(ra) # 800019f6 <myproc>
    80005076:	fdc42703          	lw	a4,-36(s0)
    8000507a:	01a70793          	add	a5,a4,26
    8000507e:	078e                	sll	a5,a5,0x3
    80005080:	953e                	add	a0,a0,a5
    80005082:	611c                	ld	a5,0(a0)
    80005084:	c385                	beqz	a5,800050a4 <argfd+0x5c>
    return -1;
  if(pfd)
    80005086:	00090463          	beqz	s2,8000508e <argfd+0x46>
    *pfd = fd;
    8000508a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000508e:	4501                	li	a0,0
  if(pf)
    80005090:	c091                	beqz	s1,80005094 <argfd+0x4c>
    *pf = f;
    80005092:	e09c                	sd	a5,0(s1)
}
    80005094:	70a2                	ld	ra,40(sp)
    80005096:	7402                	ld	s0,32(sp)
    80005098:	64e2                	ld	s1,24(sp)
    8000509a:	6942                	ld	s2,16(sp)
    8000509c:	6145                	add	sp,sp,48
    8000509e:	8082                	ret
    return -1;
    800050a0:	557d                	li	a0,-1
    800050a2:	bfcd                	j	80005094 <argfd+0x4c>
    800050a4:	557d                	li	a0,-1
    800050a6:	b7fd                	j	80005094 <argfd+0x4c>

00000000800050a8 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    800050a8:	1101                	add	sp,sp,-32
    800050aa:	ec06                	sd	ra,24(sp)
    800050ac:	e822                	sd	s0,16(sp)
    800050ae:	e426                	sd	s1,8(sp)
    800050b0:	1000                	add	s0,sp,32
    800050b2:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    800050b4:	ffffd097          	auipc	ra,0xffffd
    800050b8:	942080e7          	jalr	-1726(ra) # 800019f6 <myproc>
    800050bc:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    800050be:	0d050793          	add	a5,a0,208
    800050c2:	4501                	li	a0,0
    800050c4:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    800050c6:	6398                	ld	a4,0(a5)
    800050c8:	cb19                	beqz	a4,800050de <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    800050ca:	2505                	addw	a0,a0,1
    800050cc:	07a1                	add	a5,a5,8 # 6008 <_entry-0x7fff9ff8>
    800050ce:	fed51ce3          	bne	a0,a3,800050c6 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    800050d2:	557d                	li	a0,-1
}
    800050d4:	60e2                	ld	ra,24(sp)
    800050d6:	6442                	ld	s0,16(sp)
    800050d8:	64a2                	ld	s1,8(sp)
    800050da:	6105                	add	sp,sp,32
    800050dc:	8082                	ret
      p->ofile[fd] = f;
    800050de:	01a50793          	add	a5,a0,26
    800050e2:	078e                	sll	a5,a5,0x3
    800050e4:	963e                	add	a2,a2,a5
    800050e6:	e204                	sd	s1,0(a2)
      return fd;
    800050e8:	b7f5                	j	800050d4 <fdalloc+0x2c>

00000000800050ea <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800050ea:	715d                	add	sp,sp,-80
    800050ec:	e486                	sd	ra,72(sp)
    800050ee:	e0a2                	sd	s0,64(sp)
    800050f0:	fc26                	sd	s1,56(sp)
    800050f2:	f84a                	sd	s2,48(sp)
    800050f4:	f44e                	sd	s3,40(sp)
    800050f6:	f052                	sd	s4,32(sp)
    800050f8:	ec56                	sd	s5,24(sp)
    800050fa:	e85a                	sd	s6,16(sp)
    800050fc:	0880                	add	s0,sp,80
    800050fe:	8b2e                	mv	s6,a1
    80005100:	89b2                	mv	s3,a2
    80005102:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80005104:	fb040593          	add	a1,s0,-80
    80005108:	fffff097          	auipc	ra,0xfffff
    8000510c:	dfa080e7          	jalr	-518(ra) # 80003f02 <nameiparent>
    80005110:	84aa                	mv	s1,a0
    80005112:	14050b63          	beqz	a0,80005268 <create+0x17e>
    return 0;

  ilock(dp);
    80005116:	ffffe097          	auipc	ra,0xffffe
    8000511a:	628080e7          	jalr	1576(ra) # 8000373e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    8000511e:	4601                	li	a2,0
    80005120:	fb040593          	add	a1,s0,-80
    80005124:	8526                	mv	a0,s1
    80005126:	fffff097          	auipc	ra,0xfffff
    8000512a:	afc080e7          	jalr	-1284(ra) # 80003c22 <dirlookup>
    8000512e:	8aaa                	mv	s5,a0
    80005130:	c921                	beqz	a0,80005180 <create+0x96>
    iunlockput(dp);
    80005132:	8526                	mv	a0,s1
    80005134:	fffff097          	auipc	ra,0xfffff
    80005138:	86c080e7          	jalr	-1940(ra) # 800039a0 <iunlockput>
    ilock(ip);
    8000513c:	8556                	mv	a0,s5
    8000513e:	ffffe097          	auipc	ra,0xffffe
    80005142:	600080e7          	jalr	1536(ra) # 8000373e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80005146:	4789                	li	a5,2
    80005148:	02fb1563          	bne	s6,a5,80005172 <create+0x88>
    8000514c:	044ad783          	lhu	a5,68(s5)
    80005150:	37f9                	addw	a5,a5,-2
    80005152:	17c2                	sll	a5,a5,0x30
    80005154:	93c1                	srl	a5,a5,0x30
    80005156:	4705                	li	a4,1
    80005158:	00f76d63          	bltu	a4,a5,80005172 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    8000515c:	8556                	mv	a0,s5
    8000515e:	60a6                	ld	ra,72(sp)
    80005160:	6406                	ld	s0,64(sp)
    80005162:	74e2                	ld	s1,56(sp)
    80005164:	7942                	ld	s2,48(sp)
    80005166:	79a2                	ld	s3,40(sp)
    80005168:	7a02                	ld	s4,32(sp)
    8000516a:	6ae2                	ld	s5,24(sp)
    8000516c:	6b42                	ld	s6,16(sp)
    8000516e:	6161                	add	sp,sp,80
    80005170:	8082                	ret
    iunlockput(ip);
    80005172:	8556                	mv	a0,s5
    80005174:	fffff097          	auipc	ra,0xfffff
    80005178:	82c080e7          	jalr	-2004(ra) # 800039a0 <iunlockput>
    return 0;
    8000517c:	4a81                	li	s5,0
    8000517e:	bff9                	j	8000515c <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005180:	85da                	mv	a1,s6
    80005182:	4088                	lw	a0,0(s1)
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	422080e7          	jalr	1058(ra) # 800035a6 <ialloc>
    8000518c:	8a2a                	mv	s4,a0
    8000518e:	c529                	beqz	a0,800051d8 <create+0xee>
  ilock(ip);
    80005190:	ffffe097          	auipc	ra,0xffffe
    80005194:	5ae080e7          	jalr	1454(ra) # 8000373e <ilock>
  ip->major = major;
    80005198:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    8000519c:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800051a0:	4905                	li	s2,1
    800051a2:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800051a6:	8552                	mv	a0,s4
    800051a8:	ffffe097          	auipc	ra,0xffffe
    800051ac:	4ca080e7          	jalr	1226(ra) # 80003672 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800051b0:	032b0b63          	beq	s6,s2,800051e6 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    800051b4:	004a2603          	lw	a2,4(s4)
    800051b8:	fb040593          	add	a1,s0,-80
    800051bc:	8526                	mv	a0,s1
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	c74080e7          	jalr	-908(ra) # 80003e32 <dirlink>
    800051c6:	06054f63          	bltz	a0,80005244 <create+0x15a>
  iunlockput(dp);
    800051ca:	8526                	mv	a0,s1
    800051cc:	ffffe097          	auipc	ra,0xffffe
    800051d0:	7d4080e7          	jalr	2004(ra) # 800039a0 <iunlockput>
  return ip;
    800051d4:	8ad2                	mv	s5,s4
    800051d6:	b759                	j	8000515c <create+0x72>
    iunlockput(dp);
    800051d8:	8526                	mv	a0,s1
    800051da:	ffffe097          	auipc	ra,0xffffe
    800051de:	7c6080e7          	jalr	1990(ra) # 800039a0 <iunlockput>
    return 0;
    800051e2:	8ad2                	mv	s5,s4
    800051e4:	bfa5                	j	8000515c <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800051e6:	004a2603          	lw	a2,4(s4)
    800051ea:	00003597          	auipc	a1,0x3
    800051ee:	55658593          	add	a1,a1,1366 # 80008740 <syscalls+0x2b0>
    800051f2:	8552                	mv	a0,s4
    800051f4:	fffff097          	auipc	ra,0xfffff
    800051f8:	c3e080e7          	jalr	-962(ra) # 80003e32 <dirlink>
    800051fc:	04054463          	bltz	a0,80005244 <create+0x15a>
    80005200:	40d0                	lw	a2,4(s1)
    80005202:	00003597          	auipc	a1,0x3
    80005206:	54658593          	add	a1,a1,1350 # 80008748 <syscalls+0x2b8>
    8000520a:	8552                	mv	a0,s4
    8000520c:	fffff097          	auipc	ra,0xfffff
    80005210:	c26080e7          	jalr	-986(ra) # 80003e32 <dirlink>
    80005214:	02054863          	bltz	a0,80005244 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005218:	004a2603          	lw	a2,4(s4)
    8000521c:	fb040593          	add	a1,s0,-80
    80005220:	8526                	mv	a0,s1
    80005222:	fffff097          	auipc	ra,0xfffff
    80005226:	c10080e7          	jalr	-1008(ra) # 80003e32 <dirlink>
    8000522a:	00054d63          	bltz	a0,80005244 <create+0x15a>
    dp->nlink++;  // for ".."
    8000522e:	04a4d783          	lhu	a5,74(s1)
    80005232:	2785                	addw	a5,a5,1
    80005234:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005238:	8526                	mv	a0,s1
    8000523a:	ffffe097          	auipc	ra,0xffffe
    8000523e:	438080e7          	jalr	1080(ra) # 80003672 <iupdate>
    80005242:	b761                	j	800051ca <create+0xe0>
  ip->nlink = 0;
    80005244:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80005248:	8552                	mv	a0,s4
    8000524a:	ffffe097          	auipc	ra,0xffffe
    8000524e:	428080e7          	jalr	1064(ra) # 80003672 <iupdate>
  iunlockput(ip);
    80005252:	8552                	mv	a0,s4
    80005254:	ffffe097          	auipc	ra,0xffffe
    80005258:	74c080e7          	jalr	1868(ra) # 800039a0 <iunlockput>
  iunlockput(dp);
    8000525c:	8526                	mv	a0,s1
    8000525e:	ffffe097          	auipc	ra,0xffffe
    80005262:	742080e7          	jalr	1858(ra) # 800039a0 <iunlockput>
  return 0;
    80005266:	bddd                	j	8000515c <create+0x72>
    return 0;
    80005268:	8aaa                	mv	s5,a0
    8000526a:	bdcd                	j	8000515c <create+0x72>

000000008000526c <sys_dup>:
{
    8000526c:	7179                	add	sp,sp,-48
    8000526e:	f406                	sd	ra,40(sp)
    80005270:	f022                	sd	s0,32(sp)
    80005272:	ec26                	sd	s1,24(sp)
    80005274:	e84a                	sd	s2,16(sp)
    80005276:	1800                	add	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005278:	fd840613          	add	a2,s0,-40
    8000527c:	4581                	li	a1,0
    8000527e:	4501                	li	a0,0
    80005280:	00000097          	auipc	ra,0x0
    80005284:	dc8080e7          	jalr	-568(ra) # 80005048 <argfd>
    return -1;
    80005288:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    8000528a:	02054363          	bltz	a0,800052b0 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    8000528e:	fd843903          	ld	s2,-40(s0)
    80005292:	854a                	mv	a0,s2
    80005294:	00000097          	auipc	ra,0x0
    80005298:	e14080e7          	jalr	-492(ra) # 800050a8 <fdalloc>
    8000529c:	84aa                	mv	s1,a0
    return -1;
    8000529e:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    800052a0:	00054863          	bltz	a0,800052b0 <sys_dup+0x44>
  filedup(f);
    800052a4:	854a                	mv	a0,s2
    800052a6:	fffff097          	auipc	ra,0xfffff
    800052aa:	2b0080e7          	jalr	688(ra) # 80004556 <filedup>
  return fd;
    800052ae:	87a6                	mv	a5,s1
}
    800052b0:	853e                	mv	a0,a5
    800052b2:	70a2                	ld	ra,40(sp)
    800052b4:	7402                	ld	s0,32(sp)
    800052b6:	64e2                	ld	s1,24(sp)
    800052b8:	6942                	ld	s2,16(sp)
    800052ba:	6145                	add	sp,sp,48
    800052bc:	8082                	ret

00000000800052be <sys_read>:
{
    800052be:	7179                	add	sp,sp,-48
    800052c0:	f406                	sd	ra,40(sp)
    800052c2:	f022                	sd	s0,32(sp)
    800052c4:	1800                	add	s0,sp,48
  argaddr(1, &p);
    800052c6:	fd840593          	add	a1,s0,-40
    800052ca:	4505                	li	a0,1
    800052cc:	ffffe097          	auipc	ra,0xffffe
    800052d0:	930080e7          	jalr	-1744(ra) # 80002bfc <argaddr>
  argint(2, &n);
    800052d4:	fe440593          	add	a1,s0,-28
    800052d8:	4509                	li	a0,2
    800052da:	ffffe097          	auipc	ra,0xffffe
    800052de:	902080e7          	jalr	-1790(ra) # 80002bdc <argint>
  if(argfd(0, 0, &f) < 0)
    800052e2:	fe840613          	add	a2,s0,-24
    800052e6:	4581                	li	a1,0
    800052e8:	4501                	li	a0,0
    800052ea:	00000097          	auipc	ra,0x0
    800052ee:	d5e080e7          	jalr	-674(ra) # 80005048 <argfd>
    800052f2:	87aa                	mv	a5,a0
    return -1;
    800052f4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800052f6:	0007cc63          	bltz	a5,8000530e <sys_read+0x50>
  return fileread(f, p, n);
    800052fa:	fe442603          	lw	a2,-28(s0)
    800052fe:	fd843583          	ld	a1,-40(s0)
    80005302:	fe843503          	ld	a0,-24(s0)
    80005306:	fffff097          	auipc	ra,0xfffff
    8000530a:	3dc080e7          	jalr	988(ra) # 800046e2 <fileread>
}
    8000530e:	70a2                	ld	ra,40(sp)
    80005310:	7402                	ld	s0,32(sp)
    80005312:	6145                	add	sp,sp,48
    80005314:	8082                	ret

0000000080005316 <sys_write>:
{
    80005316:	7179                	add	sp,sp,-48
    80005318:	f406                	sd	ra,40(sp)
    8000531a:	f022                	sd	s0,32(sp)
    8000531c:	1800                	add	s0,sp,48
  argaddr(1, &p);
    8000531e:	fd840593          	add	a1,s0,-40
    80005322:	4505                	li	a0,1
    80005324:	ffffe097          	auipc	ra,0xffffe
    80005328:	8d8080e7          	jalr	-1832(ra) # 80002bfc <argaddr>
  argint(2, &n);
    8000532c:	fe440593          	add	a1,s0,-28
    80005330:	4509                	li	a0,2
    80005332:	ffffe097          	auipc	ra,0xffffe
    80005336:	8aa080e7          	jalr	-1878(ra) # 80002bdc <argint>
  if(argfd(0, 0, &f) < 0)
    8000533a:	fe840613          	add	a2,s0,-24
    8000533e:	4581                	li	a1,0
    80005340:	4501                	li	a0,0
    80005342:	00000097          	auipc	ra,0x0
    80005346:	d06080e7          	jalr	-762(ra) # 80005048 <argfd>
    8000534a:	87aa                	mv	a5,a0
    return -1;
    8000534c:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    8000534e:	0007cc63          	bltz	a5,80005366 <sys_write+0x50>
  return filewrite(f, p, n);
    80005352:	fe442603          	lw	a2,-28(s0)
    80005356:	fd843583          	ld	a1,-40(s0)
    8000535a:	fe843503          	ld	a0,-24(s0)
    8000535e:	fffff097          	auipc	ra,0xfffff
    80005362:	446080e7          	jalr	1094(ra) # 800047a4 <filewrite>
}
    80005366:	70a2                	ld	ra,40(sp)
    80005368:	7402                	ld	s0,32(sp)
    8000536a:	6145                	add	sp,sp,48
    8000536c:	8082                	ret

000000008000536e <sys_close>:
{
    8000536e:	1101                	add	sp,sp,-32
    80005370:	ec06                	sd	ra,24(sp)
    80005372:	e822                	sd	s0,16(sp)
    80005374:	1000                	add	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005376:	fe040613          	add	a2,s0,-32
    8000537a:	fec40593          	add	a1,s0,-20
    8000537e:	4501                	li	a0,0
    80005380:	00000097          	auipc	ra,0x0
    80005384:	cc8080e7          	jalr	-824(ra) # 80005048 <argfd>
    return -1;
    80005388:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    8000538a:	02054463          	bltz	a0,800053b2 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    8000538e:	ffffc097          	auipc	ra,0xffffc
    80005392:	668080e7          	jalr	1640(ra) # 800019f6 <myproc>
    80005396:	fec42783          	lw	a5,-20(s0)
    8000539a:	07e9                	add	a5,a5,26
    8000539c:	078e                	sll	a5,a5,0x3
    8000539e:	953e                	add	a0,a0,a5
    800053a0:	00053023          	sd	zero,0(a0)
  fileclose(f);
    800053a4:	fe043503          	ld	a0,-32(s0)
    800053a8:	fffff097          	auipc	ra,0xfffff
    800053ac:	200080e7          	jalr	512(ra) # 800045a8 <fileclose>
  return 0;
    800053b0:	4781                	li	a5,0
}
    800053b2:	853e                	mv	a0,a5
    800053b4:	60e2                	ld	ra,24(sp)
    800053b6:	6442                	ld	s0,16(sp)
    800053b8:	6105                	add	sp,sp,32
    800053ba:	8082                	ret

00000000800053bc <sys_fstat>:
{
    800053bc:	1101                	add	sp,sp,-32
    800053be:	ec06                	sd	ra,24(sp)
    800053c0:	e822                	sd	s0,16(sp)
    800053c2:	1000                	add	s0,sp,32
  argaddr(1, &st);
    800053c4:	fe040593          	add	a1,s0,-32
    800053c8:	4505                	li	a0,1
    800053ca:	ffffe097          	auipc	ra,0xffffe
    800053ce:	832080e7          	jalr	-1998(ra) # 80002bfc <argaddr>
  if(argfd(0, 0, &f) < 0)
    800053d2:	fe840613          	add	a2,s0,-24
    800053d6:	4581                	li	a1,0
    800053d8:	4501                	li	a0,0
    800053da:	00000097          	auipc	ra,0x0
    800053de:	c6e080e7          	jalr	-914(ra) # 80005048 <argfd>
    800053e2:	87aa                	mv	a5,a0
    return -1;
    800053e4:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800053e6:	0007ca63          	bltz	a5,800053fa <sys_fstat+0x3e>
  return filestat(f, st);
    800053ea:	fe043583          	ld	a1,-32(s0)
    800053ee:	fe843503          	ld	a0,-24(s0)
    800053f2:	fffff097          	auipc	ra,0xfffff
    800053f6:	27e080e7          	jalr	638(ra) # 80004670 <filestat>
}
    800053fa:	60e2                	ld	ra,24(sp)
    800053fc:	6442                	ld	s0,16(sp)
    800053fe:	6105                	add	sp,sp,32
    80005400:	8082                	ret

0000000080005402 <sys_link>:
{
    80005402:	7169                	add	sp,sp,-304
    80005404:	f606                	sd	ra,296(sp)
    80005406:	f222                	sd	s0,288(sp)
    80005408:	ee26                	sd	s1,280(sp)
    8000540a:	ea4a                	sd	s2,272(sp)
    8000540c:	1a00                	add	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000540e:	08000613          	li	a2,128
    80005412:	ed040593          	add	a1,s0,-304
    80005416:	4501                	li	a0,0
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	804080e7          	jalr	-2044(ra) # 80002c1c <argstr>
    return -1;
    80005420:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005422:	10054e63          	bltz	a0,8000553e <sys_link+0x13c>
    80005426:	08000613          	li	a2,128
    8000542a:	f5040593          	add	a1,s0,-176
    8000542e:	4505                	li	a0,1
    80005430:	ffffd097          	auipc	ra,0xffffd
    80005434:	7ec080e7          	jalr	2028(ra) # 80002c1c <argstr>
    return -1;
    80005438:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000543a:	10054263          	bltz	a0,8000553e <sys_link+0x13c>
  begin_op();
    8000543e:	fffff097          	auipc	ra,0xfffff
    80005442:	ca6080e7          	jalr	-858(ra) # 800040e4 <begin_op>
  if((ip = namei(old)) == 0){
    80005446:	ed040513          	add	a0,s0,-304
    8000544a:	fffff097          	auipc	ra,0xfffff
    8000544e:	a9a080e7          	jalr	-1382(ra) # 80003ee4 <namei>
    80005452:	84aa                	mv	s1,a0
    80005454:	c551                	beqz	a0,800054e0 <sys_link+0xde>
  ilock(ip);
    80005456:	ffffe097          	auipc	ra,0xffffe
    8000545a:	2e8080e7          	jalr	744(ra) # 8000373e <ilock>
  if(ip->type == T_DIR){
    8000545e:	04449703          	lh	a4,68(s1)
    80005462:	4785                	li	a5,1
    80005464:	08f70463          	beq	a4,a5,800054ec <sys_link+0xea>
  ip->nlink++;
    80005468:	04a4d783          	lhu	a5,74(s1)
    8000546c:	2785                	addw	a5,a5,1
    8000546e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005472:	8526                	mv	a0,s1
    80005474:	ffffe097          	auipc	ra,0xffffe
    80005478:	1fe080e7          	jalr	510(ra) # 80003672 <iupdate>
  iunlock(ip);
    8000547c:	8526                	mv	a0,s1
    8000547e:	ffffe097          	auipc	ra,0xffffe
    80005482:	382080e7          	jalr	898(ra) # 80003800 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005486:	fd040593          	add	a1,s0,-48
    8000548a:	f5040513          	add	a0,s0,-176
    8000548e:	fffff097          	auipc	ra,0xfffff
    80005492:	a74080e7          	jalr	-1420(ra) # 80003f02 <nameiparent>
    80005496:	892a                	mv	s2,a0
    80005498:	c935                	beqz	a0,8000550c <sys_link+0x10a>
  ilock(dp);
    8000549a:	ffffe097          	auipc	ra,0xffffe
    8000549e:	2a4080e7          	jalr	676(ra) # 8000373e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    800054a2:	00092703          	lw	a4,0(s2)
    800054a6:	409c                	lw	a5,0(s1)
    800054a8:	04f71d63          	bne	a4,a5,80005502 <sys_link+0x100>
    800054ac:	40d0                	lw	a2,4(s1)
    800054ae:	fd040593          	add	a1,s0,-48
    800054b2:	854a                	mv	a0,s2
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	97e080e7          	jalr	-1666(ra) # 80003e32 <dirlink>
    800054bc:	04054363          	bltz	a0,80005502 <sys_link+0x100>
  iunlockput(dp);
    800054c0:	854a                	mv	a0,s2
    800054c2:	ffffe097          	auipc	ra,0xffffe
    800054c6:	4de080e7          	jalr	1246(ra) # 800039a0 <iunlockput>
  iput(ip);
    800054ca:	8526                	mv	a0,s1
    800054cc:	ffffe097          	auipc	ra,0xffffe
    800054d0:	42c080e7          	jalr	1068(ra) # 800038f8 <iput>
  end_op();
    800054d4:	fffff097          	auipc	ra,0xfffff
    800054d8:	c8a080e7          	jalr	-886(ra) # 8000415e <end_op>
  return 0;
    800054dc:	4781                	li	a5,0
    800054de:	a085                	j	8000553e <sys_link+0x13c>
    end_op();
    800054e0:	fffff097          	auipc	ra,0xfffff
    800054e4:	c7e080e7          	jalr	-898(ra) # 8000415e <end_op>
    return -1;
    800054e8:	57fd                	li	a5,-1
    800054ea:	a891                	j	8000553e <sys_link+0x13c>
    iunlockput(ip);
    800054ec:	8526                	mv	a0,s1
    800054ee:	ffffe097          	auipc	ra,0xffffe
    800054f2:	4b2080e7          	jalr	1202(ra) # 800039a0 <iunlockput>
    end_op();
    800054f6:	fffff097          	auipc	ra,0xfffff
    800054fa:	c68080e7          	jalr	-920(ra) # 8000415e <end_op>
    return -1;
    800054fe:	57fd                	li	a5,-1
    80005500:	a83d                	j	8000553e <sys_link+0x13c>
    iunlockput(dp);
    80005502:	854a                	mv	a0,s2
    80005504:	ffffe097          	auipc	ra,0xffffe
    80005508:	49c080e7          	jalr	1180(ra) # 800039a0 <iunlockput>
  ilock(ip);
    8000550c:	8526                	mv	a0,s1
    8000550e:	ffffe097          	auipc	ra,0xffffe
    80005512:	230080e7          	jalr	560(ra) # 8000373e <ilock>
  ip->nlink--;
    80005516:	04a4d783          	lhu	a5,74(s1)
    8000551a:	37fd                	addw	a5,a5,-1
    8000551c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005520:	8526                	mv	a0,s1
    80005522:	ffffe097          	auipc	ra,0xffffe
    80005526:	150080e7          	jalr	336(ra) # 80003672 <iupdate>
  iunlockput(ip);
    8000552a:	8526                	mv	a0,s1
    8000552c:	ffffe097          	auipc	ra,0xffffe
    80005530:	474080e7          	jalr	1140(ra) # 800039a0 <iunlockput>
  end_op();
    80005534:	fffff097          	auipc	ra,0xfffff
    80005538:	c2a080e7          	jalr	-982(ra) # 8000415e <end_op>
  return -1;
    8000553c:	57fd                	li	a5,-1
}
    8000553e:	853e                	mv	a0,a5
    80005540:	70b2                	ld	ra,296(sp)
    80005542:	7412                	ld	s0,288(sp)
    80005544:	64f2                	ld	s1,280(sp)
    80005546:	6952                	ld	s2,272(sp)
    80005548:	6155                	add	sp,sp,304
    8000554a:	8082                	ret

000000008000554c <sys_unlink>:
{
    8000554c:	7151                	add	sp,sp,-240
    8000554e:	f586                	sd	ra,232(sp)
    80005550:	f1a2                	sd	s0,224(sp)
    80005552:	eda6                	sd	s1,216(sp)
    80005554:	e9ca                	sd	s2,208(sp)
    80005556:	e5ce                	sd	s3,200(sp)
    80005558:	1980                	add	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    8000555a:	08000613          	li	a2,128
    8000555e:	f3040593          	add	a1,s0,-208
    80005562:	4501                	li	a0,0
    80005564:	ffffd097          	auipc	ra,0xffffd
    80005568:	6b8080e7          	jalr	1720(ra) # 80002c1c <argstr>
    8000556c:	18054163          	bltz	a0,800056ee <sys_unlink+0x1a2>
  begin_op();
    80005570:	fffff097          	auipc	ra,0xfffff
    80005574:	b74080e7          	jalr	-1164(ra) # 800040e4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005578:	fb040593          	add	a1,s0,-80
    8000557c:	f3040513          	add	a0,s0,-208
    80005580:	fffff097          	auipc	ra,0xfffff
    80005584:	982080e7          	jalr	-1662(ra) # 80003f02 <nameiparent>
    80005588:	84aa                	mv	s1,a0
    8000558a:	c979                	beqz	a0,80005660 <sys_unlink+0x114>
  ilock(dp);
    8000558c:	ffffe097          	auipc	ra,0xffffe
    80005590:	1b2080e7          	jalr	434(ra) # 8000373e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80005594:	00003597          	auipc	a1,0x3
    80005598:	1ac58593          	add	a1,a1,428 # 80008740 <syscalls+0x2b0>
    8000559c:	fb040513          	add	a0,s0,-80
    800055a0:	ffffe097          	auipc	ra,0xffffe
    800055a4:	668080e7          	jalr	1640(ra) # 80003c08 <namecmp>
    800055a8:	14050a63          	beqz	a0,800056fc <sys_unlink+0x1b0>
    800055ac:	00003597          	auipc	a1,0x3
    800055b0:	19c58593          	add	a1,a1,412 # 80008748 <syscalls+0x2b8>
    800055b4:	fb040513          	add	a0,s0,-80
    800055b8:	ffffe097          	auipc	ra,0xffffe
    800055bc:	650080e7          	jalr	1616(ra) # 80003c08 <namecmp>
    800055c0:	12050e63          	beqz	a0,800056fc <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    800055c4:	f2c40613          	add	a2,s0,-212
    800055c8:	fb040593          	add	a1,s0,-80
    800055cc:	8526                	mv	a0,s1
    800055ce:	ffffe097          	auipc	ra,0xffffe
    800055d2:	654080e7          	jalr	1620(ra) # 80003c22 <dirlookup>
    800055d6:	892a                	mv	s2,a0
    800055d8:	12050263          	beqz	a0,800056fc <sys_unlink+0x1b0>
  ilock(ip);
    800055dc:	ffffe097          	auipc	ra,0xffffe
    800055e0:	162080e7          	jalr	354(ra) # 8000373e <ilock>
  if(ip->nlink < 1)
    800055e4:	04a91783          	lh	a5,74(s2)
    800055e8:	08f05263          	blez	a5,8000566c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    800055ec:	04491703          	lh	a4,68(s2)
    800055f0:	4785                	li	a5,1
    800055f2:	08f70563          	beq	a4,a5,8000567c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800055f6:	4641                	li	a2,16
    800055f8:	4581                	li	a1,0
    800055fa:	fc040513          	add	a0,s0,-64
    800055fe:	ffffb097          	auipc	ra,0xffffb
    80005602:	6d0080e7          	jalr	1744(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005606:	4741                	li	a4,16
    80005608:	f2c42683          	lw	a3,-212(s0)
    8000560c:	fc040613          	add	a2,s0,-64
    80005610:	4581                	li	a1,0
    80005612:	8526                	mv	a0,s1
    80005614:	ffffe097          	auipc	ra,0xffffe
    80005618:	4d6080e7          	jalr	1238(ra) # 80003aea <writei>
    8000561c:	47c1                	li	a5,16
    8000561e:	0af51563          	bne	a0,a5,800056c8 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005622:	04491703          	lh	a4,68(s2)
    80005626:	4785                	li	a5,1
    80005628:	0af70863          	beq	a4,a5,800056d8 <sys_unlink+0x18c>
  iunlockput(dp);
    8000562c:	8526                	mv	a0,s1
    8000562e:	ffffe097          	auipc	ra,0xffffe
    80005632:	372080e7          	jalr	882(ra) # 800039a0 <iunlockput>
  ip->nlink--;
    80005636:	04a95783          	lhu	a5,74(s2)
    8000563a:	37fd                	addw	a5,a5,-1
    8000563c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80005640:	854a                	mv	a0,s2
    80005642:	ffffe097          	auipc	ra,0xffffe
    80005646:	030080e7          	jalr	48(ra) # 80003672 <iupdate>
  iunlockput(ip);
    8000564a:	854a                	mv	a0,s2
    8000564c:	ffffe097          	auipc	ra,0xffffe
    80005650:	354080e7          	jalr	852(ra) # 800039a0 <iunlockput>
  end_op();
    80005654:	fffff097          	auipc	ra,0xfffff
    80005658:	b0a080e7          	jalr	-1270(ra) # 8000415e <end_op>
  return 0;
    8000565c:	4501                	li	a0,0
    8000565e:	a84d                	j	80005710 <sys_unlink+0x1c4>
    end_op();
    80005660:	fffff097          	auipc	ra,0xfffff
    80005664:	afe080e7          	jalr	-1282(ra) # 8000415e <end_op>
    return -1;
    80005668:	557d                	li	a0,-1
    8000566a:	a05d                	j	80005710 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    8000566c:	00003517          	auipc	a0,0x3
    80005670:	0e450513          	add	a0,a0,228 # 80008750 <syscalls+0x2c0>
    80005674:	ffffb097          	auipc	ra,0xffffb
    80005678:	ec8080e7          	jalr	-312(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000567c:	04c92703          	lw	a4,76(s2)
    80005680:	02000793          	li	a5,32
    80005684:	f6e7f9e3          	bgeu	a5,a4,800055f6 <sys_unlink+0xaa>
    80005688:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000568c:	4741                	li	a4,16
    8000568e:	86ce                	mv	a3,s3
    80005690:	f1840613          	add	a2,s0,-232
    80005694:	4581                	li	a1,0
    80005696:	854a                	mv	a0,s2
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	35a080e7          	jalr	858(ra) # 800039f2 <readi>
    800056a0:	47c1                	li	a5,16
    800056a2:	00f51b63          	bne	a0,a5,800056b8 <sys_unlink+0x16c>
    if(de.inum != 0)
    800056a6:	f1845783          	lhu	a5,-232(s0)
    800056aa:	e7a1                	bnez	a5,800056f2 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800056ac:	29c1                	addw	s3,s3,16
    800056ae:	04c92783          	lw	a5,76(s2)
    800056b2:	fcf9ede3          	bltu	s3,a5,8000568c <sys_unlink+0x140>
    800056b6:	b781                	j	800055f6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    800056b8:	00003517          	auipc	a0,0x3
    800056bc:	0b050513          	add	a0,a0,176 # 80008768 <syscalls+0x2d8>
    800056c0:	ffffb097          	auipc	ra,0xffffb
    800056c4:	e7c080e7          	jalr	-388(ra) # 8000053c <panic>
    panic("unlink: writei");
    800056c8:	00003517          	auipc	a0,0x3
    800056cc:	0b850513          	add	a0,a0,184 # 80008780 <syscalls+0x2f0>
    800056d0:	ffffb097          	auipc	ra,0xffffb
    800056d4:	e6c080e7          	jalr	-404(ra) # 8000053c <panic>
    dp->nlink--;
    800056d8:	04a4d783          	lhu	a5,74(s1)
    800056dc:	37fd                	addw	a5,a5,-1
    800056de:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800056e2:	8526                	mv	a0,s1
    800056e4:	ffffe097          	auipc	ra,0xffffe
    800056e8:	f8e080e7          	jalr	-114(ra) # 80003672 <iupdate>
    800056ec:	b781                	j	8000562c <sys_unlink+0xe0>
    return -1;
    800056ee:	557d                	li	a0,-1
    800056f0:	a005                	j	80005710 <sys_unlink+0x1c4>
    iunlockput(ip);
    800056f2:	854a                	mv	a0,s2
    800056f4:	ffffe097          	auipc	ra,0xffffe
    800056f8:	2ac080e7          	jalr	684(ra) # 800039a0 <iunlockput>
  iunlockput(dp);
    800056fc:	8526                	mv	a0,s1
    800056fe:	ffffe097          	auipc	ra,0xffffe
    80005702:	2a2080e7          	jalr	674(ra) # 800039a0 <iunlockput>
  end_op();
    80005706:	fffff097          	auipc	ra,0xfffff
    8000570a:	a58080e7          	jalr	-1448(ra) # 8000415e <end_op>
  return -1;
    8000570e:	557d                	li	a0,-1
}
    80005710:	70ae                	ld	ra,232(sp)
    80005712:	740e                	ld	s0,224(sp)
    80005714:	64ee                	ld	s1,216(sp)
    80005716:	694e                	ld	s2,208(sp)
    80005718:	69ae                	ld	s3,200(sp)
    8000571a:	616d                	add	sp,sp,240
    8000571c:	8082                	ret

000000008000571e <sys_open>:

uint64
sys_open(void)
{
    8000571e:	7131                	add	sp,sp,-192
    80005720:	fd06                	sd	ra,184(sp)
    80005722:	f922                	sd	s0,176(sp)
    80005724:	f526                	sd	s1,168(sp)
    80005726:	f14a                	sd	s2,160(sp)
    80005728:	ed4e                	sd	s3,152(sp)
    8000572a:	0180                	add	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000572c:	f4c40593          	add	a1,s0,-180
    80005730:	4505                	li	a0,1
    80005732:	ffffd097          	auipc	ra,0xffffd
    80005736:	4aa080e7          	jalr	1194(ra) # 80002bdc <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000573a:	08000613          	li	a2,128
    8000573e:	f5040593          	add	a1,s0,-176
    80005742:	4501                	li	a0,0
    80005744:	ffffd097          	auipc	ra,0xffffd
    80005748:	4d8080e7          	jalr	1240(ra) # 80002c1c <argstr>
    8000574c:	87aa                	mv	a5,a0
    return -1;
    8000574e:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80005750:	0a07c863          	bltz	a5,80005800 <sys_open+0xe2>

  begin_op();
    80005754:	fffff097          	auipc	ra,0xfffff
    80005758:	990080e7          	jalr	-1648(ra) # 800040e4 <begin_op>

  if(omode & O_CREATE){
    8000575c:	f4c42783          	lw	a5,-180(s0)
    80005760:	2007f793          	and	a5,a5,512
    80005764:	cbdd                	beqz	a5,8000581a <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    80005766:	4681                	li	a3,0
    80005768:	4601                	li	a2,0
    8000576a:	4589                	li	a1,2
    8000576c:	f5040513          	add	a0,s0,-176
    80005770:	00000097          	auipc	ra,0x0
    80005774:	97a080e7          	jalr	-1670(ra) # 800050ea <create>
    80005778:	84aa                	mv	s1,a0
    if(ip == 0){
    8000577a:	c951                	beqz	a0,8000580e <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    8000577c:	04449703          	lh	a4,68(s1)
    80005780:	478d                	li	a5,3
    80005782:	00f71763          	bne	a4,a5,80005790 <sys_open+0x72>
    80005786:	0464d703          	lhu	a4,70(s1)
    8000578a:	47a5                	li	a5,9
    8000578c:	0ce7ec63          	bltu	a5,a4,80005864 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80005790:	fffff097          	auipc	ra,0xfffff
    80005794:	d5c080e7          	jalr	-676(ra) # 800044ec <filealloc>
    80005798:	892a                	mv	s2,a0
    8000579a:	c56d                	beqz	a0,80005884 <sys_open+0x166>
    8000579c:	00000097          	auipc	ra,0x0
    800057a0:	90c080e7          	jalr	-1780(ra) # 800050a8 <fdalloc>
    800057a4:	89aa                	mv	s3,a0
    800057a6:	0c054a63          	bltz	a0,8000587a <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    800057aa:	04449703          	lh	a4,68(s1)
    800057ae:	478d                	li	a5,3
    800057b0:	0ef70563          	beq	a4,a5,8000589a <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    800057b4:	4789                	li	a5,2
    800057b6:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    800057ba:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    800057be:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    800057c2:	f4c42783          	lw	a5,-180(s0)
    800057c6:	0017c713          	xor	a4,a5,1
    800057ca:	8b05                	and	a4,a4,1
    800057cc:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    800057d0:	0037f713          	and	a4,a5,3
    800057d4:	00e03733          	snez	a4,a4
    800057d8:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    800057dc:	4007f793          	and	a5,a5,1024
    800057e0:	c791                	beqz	a5,800057ec <sys_open+0xce>
    800057e2:	04449703          	lh	a4,68(s1)
    800057e6:	4789                	li	a5,2
    800057e8:	0cf70063          	beq	a4,a5,800058a8 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    800057ec:	8526                	mv	a0,s1
    800057ee:	ffffe097          	auipc	ra,0xffffe
    800057f2:	012080e7          	jalr	18(ra) # 80003800 <iunlock>
  end_op();
    800057f6:	fffff097          	auipc	ra,0xfffff
    800057fa:	968080e7          	jalr	-1688(ra) # 8000415e <end_op>

  return fd;
    800057fe:	854e                	mv	a0,s3
}
    80005800:	70ea                	ld	ra,184(sp)
    80005802:	744a                	ld	s0,176(sp)
    80005804:	74aa                	ld	s1,168(sp)
    80005806:	790a                	ld	s2,160(sp)
    80005808:	69ea                	ld	s3,152(sp)
    8000580a:	6129                	add	sp,sp,192
    8000580c:	8082                	ret
      end_op();
    8000580e:	fffff097          	auipc	ra,0xfffff
    80005812:	950080e7          	jalr	-1712(ra) # 8000415e <end_op>
      return -1;
    80005816:	557d                	li	a0,-1
    80005818:	b7e5                	j	80005800 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000581a:	f5040513          	add	a0,s0,-176
    8000581e:	ffffe097          	auipc	ra,0xffffe
    80005822:	6c6080e7          	jalr	1734(ra) # 80003ee4 <namei>
    80005826:	84aa                	mv	s1,a0
    80005828:	c905                	beqz	a0,80005858 <sys_open+0x13a>
    ilock(ip);
    8000582a:	ffffe097          	auipc	ra,0xffffe
    8000582e:	f14080e7          	jalr	-236(ra) # 8000373e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005832:	04449703          	lh	a4,68(s1)
    80005836:	4785                	li	a5,1
    80005838:	f4f712e3          	bne	a4,a5,8000577c <sys_open+0x5e>
    8000583c:	f4c42783          	lw	a5,-180(s0)
    80005840:	dba1                	beqz	a5,80005790 <sys_open+0x72>
      iunlockput(ip);
    80005842:	8526                	mv	a0,s1
    80005844:	ffffe097          	auipc	ra,0xffffe
    80005848:	15c080e7          	jalr	348(ra) # 800039a0 <iunlockput>
      end_op();
    8000584c:	fffff097          	auipc	ra,0xfffff
    80005850:	912080e7          	jalr	-1774(ra) # 8000415e <end_op>
      return -1;
    80005854:	557d                	li	a0,-1
    80005856:	b76d                	j	80005800 <sys_open+0xe2>
      end_op();
    80005858:	fffff097          	auipc	ra,0xfffff
    8000585c:	906080e7          	jalr	-1786(ra) # 8000415e <end_op>
      return -1;
    80005860:	557d                	li	a0,-1
    80005862:	bf79                	j	80005800 <sys_open+0xe2>
    iunlockput(ip);
    80005864:	8526                	mv	a0,s1
    80005866:	ffffe097          	auipc	ra,0xffffe
    8000586a:	13a080e7          	jalr	314(ra) # 800039a0 <iunlockput>
    end_op();
    8000586e:	fffff097          	auipc	ra,0xfffff
    80005872:	8f0080e7          	jalr	-1808(ra) # 8000415e <end_op>
    return -1;
    80005876:	557d                	li	a0,-1
    80005878:	b761                	j	80005800 <sys_open+0xe2>
      fileclose(f);
    8000587a:	854a                	mv	a0,s2
    8000587c:	fffff097          	auipc	ra,0xfffff
    80005880:	d2c080e7          	jalr	-724(ra) # 800045a8 <fileclose>
    iunlockput(ip);
    80005884:	8526                	mv	a0,s1
    80005886:	ffffe097          	auipc	ra,0xffffe
    8000588a:	11a080e7          	jalr	282(ra) # 800039a0 <iunlockput>
    end_op();
    8000588e:	fffff097          	auipc	ra,0xfffff
    80005892:	8d0080e7          	jalr	-1840(ra) # 8000415e <end_op>
    return -1;
    80005896:	557d                	li	a0,-1
    80005898:	b7a5                	j	80005800 <sys_open+0xe2>
    f->type = FD_DEVICE;
    8000589a:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    8000589e:	04649783          	lh	a5,70(s1)
    800058a2:	02f91223          	sh	a5,36(s2)
    800058a6:	bf21                	j	800057be <sys_open+0xa0>
    itrunc(ip);
    800058a8:	8526                	mv	a0,s1
    800058aa:	ffffe097          	auipc	ra,0xffffe
    800058ae:	fa2080e7          	jalr	-94(ra) # 8000384c <itrunc>
    800058b2:	bf2d                	j	800057ec <sys_open+0xce>

00000000800058b4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    800058b4:	7175                	add	sp,sp,-144
    800058b6:	e506                	sd	ra,136(sp)
    800058b8:	e122                	sd	s0,128(sp)
    800058ba:	0900                	add	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    800058bc:	fffff097          	auipc	ra,0xfffff
    800058c0:	828080e7          	jalr	-2008(ra) # 800040e4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    800058c4:	08000613          	li	a2,128
    800058c8:	f7040593          	add	a1,s0,-144
    800058cc:	4501                	li	a0,0
    800058ce:	ffffd097          	auipc	ra,0xffffd
    800058d2:	34e080e7          	jalr	846(ra) # 80002c1c <argstr>
    800058d6:	02054963          	bltz	a0,80005908 <sys_mkdir+0x54>
    800058da:	4681                	li	a3,0
    800058dc:	4601                	li	a2,0
    800058de:	4585                	li	a1,1
    800058e0:	f7040513          	add	a0,s0,-144
    800058e4:	00000097          	auipc	ra,0x0
    800058e8:	806080e7          	jalr	-2042(ra) # 800050ea <create>
    800058ec:	cd11                	beqz	a0,80005908 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800058ee:	ffffe097          	auipc	ra,0xffffe
    800058f2:	0b2080e7          	jalr	178(ra) # 800039a0 <iunlockput>
  end_op();
    800058f6:	fffff097          	auipc	ra,0xfffff
    800058fa:	868080e7          	jalr	-1944(ra) # 8000415e <end_op>
  return 0;
    800058fe:	4501                	li	a0,0
}
    80005900:	60aa                	ld	ra,136(sp)
    80005902:	640a                	ld	s0,128(sp)
    80005904:	6149                	add	sp,sp,144
    80005906:	8082                	ret
    end_op();
    80005908:	fffff097          	auipc	ra,0xfffff
    8000590c:	856080e7          	jalr	-1962(ra) # 8000415e <end_op>
    return -1;
    80005910:	557d                	li	a0,-1
    80005912:	b7fd                	j	80005900 <sys_mkdir+0x4c>

0000000080005914 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005914:	7135                	add	sp,sp,-160
    80005916:	ed06                	sd	ra,152(sp)
    80005918:	e922                	sd	s0,144(sp)
    8000591a:	1100                	add	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000591c:	ffffe097          	auipc	ra,0xffffe
    80005920:	7c8080e7          	jalr	1992(ra) # 800040e4 <begin_op>
  argint(1, &major);
    80005924:	f6c40593          	add	a1,s0,-148
    80005928:	4505                	li	a0,1
    8000592a:	ffffd097          	auipc	ra,0xffffd
    8000592e:	2b2080e7          	jalr	690(ra) # 80002bdc <argint>
  argint(2, &minor);
    80005932:	f6840593          	add	a1,s0,-152
    80005936:	4509                	li	a0,2
    80005938:	ffffd097          	auipc	ra,0xffffd
    8000593c:	2a4080e7          	jalr	676(ra) # 80002bdc <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005940:	08000613          	li	a2,128
    80005944:	f7040593          	add	a1,s0,-144
    80005948:	4501                	li	a0,0
    8000594a:	ffffd097          	auipc	ra,0xffffd
    8000594e:	2d2080e7          	jalr	722(ra) # 80002c1c <argstr>
    80005952:	02054b63          	bltz	a0,80005988 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005956:	f6841683          	lh	a3,-152(s0)
    8000595a:	f6c41603          	lh	a2,-148(s0)
    8000595e:	458d                	li	a1,3
    80005960:	f7040513          	add	a0,s0,-144
    80005964:	fffff097          	auipc	ra,0xfffff
    80005968:	786080e7          	jalr	1926(ra) # 800050ea <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000596c:	cd11                	beqz	a0,80005988 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000596e:	ffffe097          	auipc	ra,0xffffe
    80005972:	032080e7          	jalr	50(ra) # 800039a0 <iunlockput>
  end_op();
    80005976:	ffffe097          	auipc	ra,0xffffe
    8000597a:	7e8080e7          	jalr	2024(ra) # 8000415e <end_op>
  return 0;
    8000597e:	4501                	li	a0,0
}
    80005980:	60ea                	ld	ra,152(sp)
    80005982:	644a                	ld	s0,144(sp)
    80005984:	610d                	add	sp,sp,160
    80005986:	8082                	ret
    end_op();
    80005988:	ffffe097          	auipc	ra,0xffffe
    8000598c:	7d6080e7          	jalr	2006(ra) # 8000415e <end_op>
    return -1;
    80005990:	557d                	li	a0,-1
    80005992:	b7fd                	j	80005980 <sys_mknod+0x6c>

0000000080005994 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005994:	7135                	add	sp,sp,-160
    80005996:	ed06                	sd	ra,152(sp)
    80005998:	e922                	sd	s0,144(sp)
    8000599a:	e526                	sd	s1,136(sp)
    8000599c:	e14a                	sd	s2,128(sp)
    8000599e:	1100                	add	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    800059a0:	ffffc097          	auipc	ra,0xffffc
    800059a4:	056080e7          	jalr	86(ra) # 800019f6 <myproc>
    800059a8:	892a                	mv	s2,a0
  
  begin_op();
    800059aa:	ffffe097          	auipc	ra,0xffffe
    800059ae:	73a080e7          	jalr	1850(ra) # 800040e4 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    800059b2:	08000613          	li	a2,128
    800059b6:	f6040593          	add	a1,s0,-160
    800059ba:	4501                	li	a0,0
    800059bc:	ffffd097          	auipc	ra,0xffffd
    800059c0:	260080e7          	jalr	608(ra) # 80002c1c <argstr>
    800059c4:	04054b63          	bltz	a0,80005a1a <sys_chdir+0x86>
    800059c8:	f6040513          	add	a0,s0,-160
    800059cc:	ffffe097          	auipc	ra,0xffffe
    800059d0:	518080e7          	jalr	1304(ra) # 80003ee4 <namei>
    800059d4:	84aa                	mv	s1,a0
    800059d6:	c131                	beqz	a0,80005a1a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    800059d8:	ffffe097          	auipc	ra,0xffffe
    800059dc:	d66080e7          	jalr	-666(ra) # 8000373e <ilock>
  if(ip->type != T_DIR){
    800059e0:	04449703          	lh	a4,68(s1)
    800059e4:	4785                	li	a5,1
    800059e6:	04f71063          	bne	a4,a5,80005a26 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    800059ea:	8526                	mv	a0,s1
    800059ec:	ffffe097          	auipc	ra,0xffffe
    800059f0:	e14080e7          	jalr	-492(ra) # 80003800 <iunlock>
  iput(p->cwd);
    800059f4:	15093503          	ld	a0,336(s2)
    800059f8:	ffffe097          	auipc	ra,0xffffe
    800059fc:	f00080e7          	jalr	-256(ra) # 800038f8 <iput>
  end_op();
    80005a00:	ffffe097          	auipc	ra,0xffffe
    80005a04:	75e080e7          	jalr	1886(ra) # 8000415e <end_op>
  p->cwd = ip;
    80005a08:	14993823          	sd	s1,336(s2)
  return 0;
    80005a0c:	4501                	li	a0,0
}
    80005a0e:	60ea                	ld	ra,152(sp)
    80005a10:	644a                	ld	s0,144(sp)
    80005a12:	64aa                	ld	s1,136(sp)
    80005a14:	690a                	ld	s2,128(sp)
    80005a16:	610d                	add	sp,sp,160
    80005a18:	8082                	ret
    end_op();
    80005a1a:	ffffe097          	auipc	ra,0xffffe
    80005a1e:	744080e7          	jalr	1860(ra) # 8000415e <end_op>
    return -1;
    80005a22:	557d                	li	a0,-1
    80005a24:	b7ed                	j	80005a0e <sys_chdir+0x7a>
    iunlockput(ip);
    80005a26:	8526                	mv	a0,s1
    80005a28:	ffffe097          	auipc	ra,0xffffe
    80005a2c:	f78080e7          	jalr	-136(ra) # 800039a0 <iunlockput>
    end_op();
    80005a30:	ffffe097          	auipc	ra,0xffffe
    80005a34:	72e080e7          	jalr	1838(ra) # 8000415e <end_op>
    return -1;
    80005a38:	557d                	li	a0,-1
    80005a3a:	bfd1                	j	80005a0e <sys_chdir+0x7a>

0000000080005a3c <sys_exec>:

uint64
sys_exec(void)
{
    80005a3c:	7121                	add	sp,sp,-448
    80005a3e:	ff06                	sd	ra,440(sp)
    80005a40:	fb22                	sd	s0,432(sp)
    80005a42:	f726                	sd	s1,424(sp)
    80005a44:	f34a                	sd	s2,416(sp)
    80005a46:	ef4e                	sd	s3,408(sp)
    80005a48:	eb52                	sd	s4,400(sp)
    80005a4a:	0380                	add	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005a4c:	e4840593          	add	a1,s0,-440
    80005a50:	4505                	li	a0,1
    80005a52:	ffffd097          	auipc	ra,0xffffd
    80005a56:	1aa080e7          	jalr	426(ra) # 80002bfc <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005a5a:	08000613          	li	a2,128
    80005a5e:	f5040593          	add	a1,s0,-176
    80005a62:	4501                	li	a0,0
    80005a64:	ffffd097          	auipc	ra,0xffffd
    80005a68:	1b8080e7          	jalr	440(ra) # 80002c1c <argstr>
    80005a6c:	87aa                	mv	a5,a0
    return -1;
    80005a6e:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005a70:	0c07c263          	bltz	a5,80005b34 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    80005a74:	10000613          	li	a2,256
    80005a78:	4581                	li	a1,0
    80005a7a:	e5040513          	add	a0,s0,-432
    80005a7e:	ffffb097          	auipc	ra,0xffffb
    80005a82:	250080e7          	jalr	592(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005a86:	e5040493          	add	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    80005a8a:	89a6                	mv	s3,s1
    80005a8c:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005a8e:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005a92:	00391513          	sll	a0,s2,0x3
    80005a96:	e4040593          	add	a1,s0,-448
    80005a9a:	e4843783          	ld	a5,-440(s0)
    80005a9e:	953e                	add	a0,a0,a5
    80005aa0:	ffffd097          	auipc	ra,0xffffd
    80005aa4:	09e080e7          	jalr	158(ra) # 80002b3e <fetchaddr>
    80005aa8:	02054a63          	bltz	a0,80005adc <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    80005aac:	e4043783          	ld	a5,-448(s0)
    80005ab0:	c3b9                	beqz	a5,80005af6 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005ab2:	ffffb097          	auipc	ra,0xffffb
    80005ab6:	030080e7          	jalr	48(ra) # 80000ae2 <kalloc>
    80005aba:	85aa                	mv	a1,a0
    80005abc:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005ac0:	cd11                	beqz	a0,80005adc <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005ac2:	6605                	lui	a2,0x1
    80005ac4:	e4043503          	ld	a0,-448(s0)
    80005ac8:	ffffd097          	auipc	ra,0xffffd
    80005acc:	0c8080e7          	jalr	200(ra) # 80002b90 <fetchstr>
    80005ad0:	00054663          	bltz	a0,80005adc <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005ad4:	0905                	add	s2,s2,1
    80005ad6:	09a1                	add	s3,s3,8
    80005ad8:	fb491de3          	bne	s2,s4,80005a92 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005adc:	f5040913          	add	s2,s0,-176
    80005ae0:	6088                	ld	a0,0(s1)
    80005ae2:	c921                	beqz	a0,80005b32 <sys_exec+0xf6>
    kfree(argv[i]);
    80005ae4:	ffffb097          	auipc	ra,0xffffb
    80005ae8:	f00080e7          	jalr	-256(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005aec:	04a1                	add	s1,s1,8
    80005aee:	ff2499e3          	bne	s1,s2,80005ae0 <sys_exec+0xa4>
  return -1;
    80005af2:	557d                	li	a0,-1
    80005af4:	a081                	j	80005b34 <sys_exec+0xf8>
      argv[i] = 0;
    80005af6:	0009079b          	sext.w	a5,s2
    80005afa:	078e                	sll	a5,a5,0x3
    80005afc:	fd078793          	add	a5,a5,-48
    80005b00:	97a2                	add	a5,a5,s0
    80005b02:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005b06:	e5040593          	add	a1,s0,-432
    80005b0a:	f5040513          	add	a0,s0,-176
    80005b0e:	fffff097          	auipc	ra,0xfffff
    80005b12:	1ba080e7          	jalr	442(ra) # 80004cc8 <exec>
    80005b16:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b18:	f5040993          	add	s3,s0,-176
    80005b1c:	6088                	ld	a0,0(s1)
    80005b1e:	c901                	beqz	a0,80005b2e <sys_exec+0xf2>
    kfree(argv[i]);
    80005b20:	ffffb097          	auipc	ra,0xffffb
    80005b24:	ec4080e7          	jalr	-316(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005b28:	04a1                	add	s1,s1,8
    80005b2a:	ff3499e3          	bne	s1,s3,80005b1c <sys_exec+0xe0>
  return ret;
    80005b2e:	854a                	mv	a0,s2
    80005b30:	a011                	j	80005b34 <sys_exec+0xf8>
  return -1;
    80005b32:	557d                	li	a0,-1
}
    80005b34:	70fa                	ld	ra,440(sp)
    80005b36:	745a                	ld	s0,432(sp)
    80005b38:	74ba                	ld	s1,424(sp)
    80005b3a:	791a                	ld	s2,416(sp)
    80005b3c:	69fa                	ld	s3,408(sp)
    80005b3e:	6a5a                	ld	s4,400(sp)
    80005b40:	6139                	add	sp,sp,448
    80005b42:	8082                	ret

0000000080005b44 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005b44:	7139                	add	sp,sp,-64
    80005b46:	fc06                	sd	ra,56(sp)
    80005b48:	f822                	sd	s0,48(sp)
    80005b4a:	f426                	sd	s1,40(sp)
    80005b4c:	0080                	add	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005b4e:	ffffc097          	auipc	ra,0xffffc
    80005b52:	ea8080e7          	jalr	-344(ra) # 800019f6 <myproc>
    80005b56:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005b58:	fd840593          	add	a1,s0,-40
    80005b5c:	4501                	li	a0,0
    80005b5e:	ffffd097          	auipc	ra,0xffffd
    80005b62:	09e080e7          	jalr	158(ra) # 80002bfc <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005b66:	fc840593          	add	a1,s0,-56
    80005b6a:	fd040513          	add	a0,s0,-48
    80005b6e:	fffff097          	auipc	ra,0xfffff
    80005b72:	d66080e7          	jalr	-666(ra) # 800048d4 <pipealloc>
    return -1;
    80005b76:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005b78:	0c054463          	bltz	a0,80005c40 <sys_pipe+0xfc>
  fd0 = -1;
    80005b7c:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005b80:	fd043503          	ld	a0,-48(s0)
    80005b84:	fffff097          	auipc	ra,0xfffff
    80005b88:	524080e7          	jalr	1316(ra) # 800050a8 <fdalloc>
    80005b8c:	fca42223          	sw	a0,-60(s0)
    80005b90:	08054b63          	bltz	a0,80005c26 <sys_pipe+0xe2>
    80005b94:	fc843503          	ld	a0,-56(s0)
    80005b98:	fffff097          	auipc	ra,0xfffff
    80005b9c:	510080e7          	jalr	1296(ra) # 800050a8 <fdalloc>
    80005ba0:	fca42023          	sw	a0,-64(s0)
    80005ba4:	06054863          	bltz	a0,80005c14 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005ba8:	4691                	li	a3,4
    80005baa:	fc440613          	add	a2,s0,-60
    80005bae:	fd843583          	ld	a1,-40(s0)
    80005bb2:	68a8                	ld	a0,80(s1)
    80005bb4:	ffffc097          	auipc	ra,0xffffc
    80005bb8:	af2080e7          	jalr	-1294(ra) # 800016a6 <copyout>
    80005bbc:	02054063          	bltz	a0,80005bdc <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005bc0:	4691                	li	a3,4
    80005bc2:	fc040613          	add	a2,s0,-64
    80005bc6:	fd843583          	ld	a1,-40(s0)
    80005bca:	0591                	add	a1,a1,4
    80005bcc:	68a8                	ld	a0,80(s1)
    80005bce:	ffffc097          	auipc	ra,0xffffc
    80005bd2:	ad8080e7          	jalr	-1320(ra) # 800016a6 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005bd6:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005bd8:	06055463          	bgez	a0,80005c40 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005bdc:	fc442783          	lw	a5,-60(s0)
    80005be0:	07e9                	add	a5,a5,26
    80005be2:	078e                	sll	a5,a5,0x3
    80005be4:	97a6                	add	a5,a5,s1
    80005be6:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005bea:	fc042783          	lw	a5,-64(s0)
    80005bee:	07e9                	add	a5,a5,26
    80005bf0:	078e                	sll	a5,a5,0x3
    80005bf2:	94be                	add	s1,s1,a5
    80005bf4:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005bf8:	fd043503          	ld	a0,-48(s0)
    80005bfc:	fffff097          	auipc	ra,0xfffff
    80005c00:	9ac080e7          	jalr	-1620(ra) # 800045a8 <fileclose>
    fileclose(wf);
    80005c04:	fc843503          	ld	a0,-56(s0)
    80005c08:	fffff097          	auipc	ra,0xfffff
    80005c0c:	9a0080e7          	jalr	-1632(ra) # 800045a8 <fileclose>
    return -1;
    80005c10:	57fd                	li	a5,-1
    80005c12:	a03d                	j	80005c40 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005c14:	fc442783          	lw	a5,-60(s0)
    80005c18:	0007c763          	bltz	a5,80005c26 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005c1c:	07e9                	add	a5,a5,26
    80005c1e:	078e                	sll	a5,a5,0x3
    80005c20:	97a6                	add	a5,a5,s1
    80005c22:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005c26:	fd043503          	ld	a0,-48(s0)
    80005c2a:	fffff097          	auipc	ra,0xfffff
    80005c2e:	97e080e7          	jalr	-1666(ra) # 800045a8 <fileclose>
    fileclose(wf);
    80005c32:	fc843503          	ld	a0,-56(s0)
    80005c36:	fffff097          	auipc	ra,0xfffff
    80005c3a:	972080e7          	jalr	-1678(ra) # 800045a8 <fileclose>
    return -1;
    80005c3e:	57fd                	li	a5,-1
}
    80005c40:	853e                	mv	a0,a5
    80005c42:	70e2                	ld	ra,56(sp)
    80005c44:	7442                	ld	s0,48(sp)
    80005c46:	74a2                	ld	s1,40(sp)
    80005c48:	6121                	add	sp,sp,64
    80005c4a:	8082                	ret
    80005c4c:	0000                	unimp
	...

0000000080005c50 <kernelvec>:
    80005c50:	7111                	add	sp,sp,-256
    80005c52:	e006                	sd	ra,0(sp)
    80005c54:	e40a                	sd	sp,8(sp)
    80005c56:	e80e                	sd	gp,16(sp)
    80005c58:	ec12                	sd	tp,24(sp)
    80005c5a:	f016                	sd	t0,32(sp)
    80005c5c:	f41a                	sd	t1,40(sp)
    80005c5e:	f81e                	sd	t2,48(sp)
    80005c60:	fc22                	sd	s0,56(sp)
    80005c62:	e0a6                	sd	s1,64(sp)
    80005c64:	e4aa                	sd	a0,72(sp)
    80005c66:	e8ae                	sd	a1,80(sp)
    80005c68:	ecb2                	sd	a2,88(sp)
    80005c6a:	f0b6                	sd	a3,96(sp)
    80005c6c:	f4ba                	sd	a4,104(sp)
    80005c6e:	f8be                	sd	a5,112(sp)
    80005c70:	fcc2                	sd	a6,120(sp)
    80005c72:	e146                	sd	a7,128(sp)
    80005c74:	e54a                	sd	s2,136(sp)
    80005c76:	e94e                	sd	s3,144(sp)
    80005c78:	ed52                	sd	s4,152(sp)
    80005c7a:	f156                	sd	s5,160(sp)
    80005c7c:	f55a                	sd	s6,168(sp)
    80005c7e:	f95e                	sd	s7,176(sp)
    80005c80:	fd62                	sd	s8,184(sp)
    80005c82:	e1e6                	sd	s9,192(sp)
    80005c84:	e5ea                	sd	s10,200(sp)
    80005c86:	e9ee                	sd	s11,208(sp)
    80005c88:	edf2                	sd	t3,216(sp)
    80005c8a:	f1f6                	sd	t4,224(sp)
    80005c8c:	f5fa                	sd	t5,232(sp)
    80005c8e:	f9fe                	sd	t6,240(sp)
    80005c90:	d7bfc0ef          	jal	80002a0a <kerneltrap>
    80005c94:	6082                	ld	ra,0(sp)
    80005c96:	6122                	ld	sp,8(sp)
    80005c98:	61c2                	ld	gp,16(sp)
    80005c9a:	7282                	ld	t0,32(sp)
    80005c9c:	7322                	ld	t1,40(sp)
    80005c9e:	73c2                	ld	t2,48(sp)
    80005ca0:	7462                	ld	s0,56(sp)
    80005ca2:	6486                	ld	s1,64(sp)
    80005ca4:	6526                	ld	a0,72(sp)
    80005ca6:	65c6                	ld	a1,80(sp)
    80005ca8:	6666                	ld	a2,88(sp)
    80005caa:	7686                	ld	a3,96(sp)
    80005cac:	7726                	ld	a4,104(sp)
    80005cae:	77c6                	ld	a5,112(sp)
    80005cb0:	7866                	ld	a6,120(sp)
    80005cb2:	688a                	ld	a7,128(sp)
    80005cb4:	692a                	ld	s2,136(sp)
    80005cb6:	69ca                	ld	s3,144(sp)
    80005cb8:	6a6a                	ld	s4,152(sp)
    80005cba:	7a8a                	ld	s5,160(sp)
    80005cbc:	7b2a                	ld	s6,168(sp)
    80005cbe:	7bca                	ld	s7,176(sp)
    80005cc0:	7c6a                	ld	s8,184(sp)
    80005cc2:	6c8e                	ld	s9,192(sp)
    80005cc4:	6d2e                	ld	s10,200(sp)
    80005cc6:	6dce                	ld	s11,208(sp)
    80005cc8:	6e6e                	ld	t3,216(sp)
    80005cca:	7e8e                	ld	t4,224(sp)
    80005ccc:	7f2e                	ld	t5,232(sp)
    80005cce:	7fce                	ld	t6,240(sp)
    80005cd0:	6111                	add	sp,sp,256
    80005cd2:	10200073          	sret
    80005cd6:	00000013          	nop
    80005cda:	00000013          	nop
    80005cde:	0001                	nop

0000000080005ce0 <timervec>:
    80005ce0:	34051573          	csrrw	a0,mscratch,a0
    80005ce4:	e10c                	sd	a1,0(a0)
    80005ce6:	e510                	sd	a2,8(a0)
    80005ce8:	e914                	sd	a3,16(a0)
    80005cea:	6d0c                	ld	a1,24(a0)
    80005cec:	7110                	ld	a2,32(a0)
    80005cee:	6194                	ld	a3,0(a1)
    80005cf0:	96b2                	add	a3,a3,a2
    80005cf2:	e194                	sd	a3,0(a1)
    80005cf4:	4589                	li	a1,2
    80005cf6:	14459073          	csrw	sip,a1
    80005cfa:	6914                	ld	a3,16(a0)
    80005cfc:	6510                	ld	a2,8(a0)
    80005cfe:	610c                	ld	a1,0(a0)
    80005d00:	34051573          	csrrw	a0,mscratch,a0
    80005d04:	30200073          	mret
	...

0000000080005d0a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005d0a:	1141                	add	sp,sp,-16
    80005d0c:	e422                	sd	s0,8(sp)
    80005d0e:	0800                	add	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005d10:	0c0007b7          	lui	a5,0xc000
    80005d14:	4705                	li	a4,1
    80005d16:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005d18:	c3d8                	sw	a4,4(a5)
}
    80005d1a:	6422                	ld	s0,8(sp)
    80005d1c:	0141                	add	sp,sp,16
    80005d1e:	8082                	ret

0000000080005d20 <plicinithart>:

void
plicinithart(void)
{
    80005d20:	1141                	add	sp,sp,-16
    80005d22:	e406                	sd	ra,8(sp)
    80005d24:	e022                	sd	s0,0(sp)
    80005d26:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005d28:	ffffc097          	auipc	ra,0xffffc
    80005d2c:	ca2080e7          	jalr	-862(ra) # 800019ca <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005d30:	0085171b          	sllw	a4,a0,0x8
    80005d34:	0c0027b7          	lui	a5,0xc002
    80005d38:	97ba                	add	a5,a5,a4
    80005d3a:	40200713          	li	a4,1026
    80005d3e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005d42:	00d5151b          	sllw	a0,a0,0xd
    80005d46:	0c2017b7          	lui	a5,0xc201
    80005d4a:	97aa                	add	a5,a5,a0
    80005d4c:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005d50:	60a2                	ld	ra,8(sp)
    80005d52:	6402                	ld	s0,0(sp)
    80005d54:	0141                	add	sp,sp,16
    80005d56:	8082                	ret

0000000080005d58 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005d58:	1141                	add	sp,sp,-16
    80005d5a:	e406                	sd	ra,8(sp)
    80005d5c:	e022                	sd	s0,0(sp)
    80005d5e:	0800                	add	s0,sp,16
  int hart = cpuid();
    80005d60:	ffffc097          	auipc	ra,0xffffc
    80005d64:	c6a080e7          	jalr	-918(ra) # 800019ca <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005d68:	00d5151b          	sllw	a0,a0,0xd
    80005d6c:	0c2017b7          	lui	a5,0xc201
    80005d70:	97aa                	add	a5,a5,a0
  return irq;
}
    80005d72:	43c8                	lw	a0,4(a5)
    80005d74:	60a2                	ld	ra,8(sp)
    80005d76:	6402                	ld	s0,0(sp)
    80005d78:	0141                	add	sp,sp,16
    80005d7a:	8082                	ret

0000000080005d7c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005d7c:	1101                	add	sp,sp,-32
    80005d7e:	ec06                	sd	ra,24(sp)
    80005d80:	e822                	sd	s0,16(sp)
    80005d82:	e426                	sd	s1,8(sp)
    80005d84:	1000                	add	s0,sp,32
    80005d86:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005d88:	ffffc097          	auipc	ra,0xffffc
    80005d8c:	c42080e7          	jalr	-958(ra) # 800019ca <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005d90:	00d5151b          	sllw	a0,a0,0xd
    80005d94:	0c2017b7          	lui	a5,0xc201
    80005d98:	97aa                	add	a5,a5,a0
    80005d9a:	c3c4                	sw	s1,4(a5)
}
    80005d9c:	60e2                	ld	ra,24(sp)
    80005d9e:	6442                	ld	s0,16(sp)
    80005da0:	64a2                	ld	s1,8(sp)
    80005da2:	6105                	add	sp,sp,32
    80005da4:	8082                	ret

0000000080005da6 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005da6:	1141                	add	sp,sp,-16
    80005da8:	e406                	sd	ra,8(sp)
    80005daa:	e022                	sd	s0,0(sp)
    80005dac:	0800                	add	s0,sp,16
  if(i >= NUM)
    80005dae:	479d                	li	a5,7
    80005db0:	04a7cc63          	blt	a5,a0,80005e08 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005db4:	00193797          	auipc	a5,0x193
    80005db8:	45478793          	add	a5,a5,1108 # 80199208 <disk>
    80005dbc:	97aa                	add	a5,a5,a0
    80005dbe:	0187c783          	lbu	a5,24(a5)
    80005dc2:	ebb9                	bnez	a5,80005e18 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005dc4:	00451693          	sll	a3,a0,0x4
    80005dc8:	00193797          	auipc	a5,0x193
    80005dcc:	44078793          	add	a5,a5,1088 # 80199208 <disk>
    80005dd0:	6398                	ld	a4,0(a5)
    80005dd2:	9736                	add	a4,a4,a3
    80005dd4:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005dd8:	6398                	ld	a4,0(a5)
    80005dda:	9736                	add	a4,a4,a3
    80005ddc:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005de0:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005de4:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005de8:	97aa                	add	a5,a5,a0
    80005dea:	4705                	li	a4,1
    80005dec:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005df0:	00193517          	auipc	a0,0x193
    80005df4:	43050513          	add	a0,a0,1072 # 80199220 <disk+0x18>
    80005df8:	ffffc097          	auipc	ra,0xffffc
    80005dfc:	36e080e7          	jalr	878(ra) # 80002166 <wakeup>
}
    80005e00:	60a2                	ld	ra,8(sp)
    80005e02:	6402                	ld	s0,0(sp)
    80005e04:	0141                	add	sp,sp,16
    80005e06:	8082                	ret
    panic("free_desc 1");
    80005e08:	00003517          	auipc	a0,0x3
    80005e0c:	98850513          	add	a0,a0,-1656 # 80008790 <syscalls+0x300>
    80005e10:	ffffa097          	auipc	ra,0xffffa
    80005e14:	72c080e7          	jalr	1836(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005e18:	00003517          	auipc	a0,0x3
    80005e1c:	98850513          	add	a0,a0,-1656 # 800087a0 <syscalls+0x310>
    80005e20:	ffffa097          	auipc	ra,0xffffa
    80005e24:	71c080e7          	jalr	1820(ra) # 8000053c <panic>

0000000080005e28 <virtio_disk_init>:
{
    80005e28:	1101                	add	sp,sp,-32
    80005e2a:	ec06                	sd	ra,24(sp)
    80005e2c:	e822                	sd	s0,16(sp)
    80005e2e:	e426                	sd	s1,8(sp)
    80005e30:	e04a                	sd	s2,0(sp)
    80005e32:	1000                	add	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005e34:	00003597          	auipc	a1,0x3
    80005e38:	97c58593          	add	a1,a1,-1668 # 800087b0 <syscalls+0x320>
    80005e3c:	00193517          	auipc	a0,0x193
    80005e40:	4f450513          	add	a0,a0,1268 # 80199330 <disk+0x128>
    80005e44:	ffffb097          	auipc	ra,0xffffb
    80005e48:	cfe080e7          	jalr	-770(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e4c:	100017b7          	lui	a5,0x10001
    80005e50:	4398                	lw	a4,0(a5)
    80005e52:	2701                	sext.w	a4,a4
    80005e54:	747277b7          	lui	a5,0x74727
    80005e58:	97678793          	add	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005e5c:	14f71b63          	bne	a4,a5,80005fb2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e60:	100017b7          	lui	a5,0x10001
    80005e64:	43dc                	lw	a5,4(a5)
    80005e66:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005e68:	4709                	li	a4,2
    80005e6a:	14e79463          	bne	a5,a4,80005fb2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e6e:	100017b7          	lui	a5,0x10001
    80005e72:	479c                	lw	a5,8(a5)
    80005e74:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005e76:	12e79e63          	bne	a5,a4,80005fb2 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005e7a:	100017b7          	lui	a5,0x10001
    80005e7e:	47d8                	lw	a4,12(a5)
    80005e80:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005e82:	554d47b7          	lui	a5,0x554d4
    80005e86:	55178793          	add	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005e8a:	12f71463          	bne	a4,a5,80005fb2 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e8e:	100017b7          	lui	a5,0x10001
    80005e92:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e96:	4705                	li	a4,1
    80005e98:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e9a:	470d                	li	a4,3
    80005e9c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005e9e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005ea0:	c7ffe6b7          	lui	a3,0xc7ffe
    80005ea4:	75f68693          	add	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47e6502f>
    80005ea8:	8f75                	and	a4,a4,a3
    80005eaa:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005eac:	472d                	li	a4,11
    80005eae:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005eb0:	5bbc                	lw	a5,112(a5)
    80005eb2:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005eb6:	8ba1                	and	a5,a5,8
    80005eb8:	10078563          	beqz	a5,80005fc2 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005ebc:	100017b7          	lui	a5,0x10001
    80005ec0:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005ec4:	43fc                	lw	a5,68(a5)
    80005ec6:	2781                	sext.w	a5,a5
    80005ec8:	10079563          	bnez	a5,80005fd2 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005ecc:	100017b7          	lui	a5,0x10001
    80005ed0:	5bdc                	lw	a5,52(a5)
    80005ed2:	2781                	sext.w	a5,a5
  if(max == 0)
    80005ed4:	10078763          	beqz	a5,80005fe2 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005ed8:	471d                	li	a4,7
    80005eda:	10f77c63          	bgeu	a4,a5,80005ff2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005ede:	ffffb097          	auipc	ra,0xffffb
    80005ee2:	c04080e7          	jalr	-1020(ra) # 80000ae2 <kalloc>
    80005ee6:	00193497          	auipc	s1,0x193
    80005eea:	32248493          	add	s1,s1,802 # 80199208 <disk>
    80005eee:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005ef0:	ffffb097          	auipc	ra,0xffffb
    80005ef4:	bf2080e7          	jalr	-1038(ra) # 80000ae2 <kalloc>
    80005ef8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005efa:	ffffb097          	auipc	ra,0xffffb
    80005efe:	be8080e7          	jalr	-1048(ra) # 80000ae2 <kalloc>
    80005f02:	87aa                	mv	a5,a0
    80005f04:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005f06:	6088                	ld	a0,0(s1)
    80005f08:	cd6d                	beqz	a0,80006002 <virtio_disk_init+0x1da>
    80005f0a:	00193717          	auipc	a4,0x193
    80005f0e:	30673703          	ld	a4,774(a4) # 80199210 <disk+0x8>
    80005f12:	cb65                	beqz	a4,80006002 <virtio_disk_init+0x1da>
    80005f14:	c7fd                	beqz	a5,80006002 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005f16:	6605                	lui	a2,0x1
    80005f18:	4581                	li	a1,0
    80005f1a:	ffffb097          	auipc	ra,0xffffb
    80005f1e:	db4080e7          	jalr	-588(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005f22:	00193497          	auipc	s1,0x193
    80005f26:	2e648493          	add	s1,s1,742 # 80199208 <disk>
    80005f2a:	6605                	lui	a2,0x1
    80005f2c:	4581                	li	a1,0
    80005f2e:	6488                	ld	a0,8(s1)
    80005f30:	ffffb097          	auipc	ra,0xffffb
    80005f34:	d9e080e7          	jalr	-610(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005f38:	6605                	lui	a2,0x1
    80005f3a:	4581                	li	a1,0
    80005f3c:	6888                	ld	a0,16(s1)
    80005f3e:	ffffb097          	auipc	ra,0xffffb
    80005f42:	d90080e7          	jalr	-624(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005f46:	100017b7          	lui	a5,0x10001
    80005f4a:	4721                	li	a4,8
    80005f4c:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005f4e:	4098                	lw	a4,0(s1)
    80005f50:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005f54:	40d8                	lw	a4,4(s1)
    80005f56:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005f5a:	6498                	ld	a4,8(s1)
    80005f5c:	0007069b          	sext.w	a3,a4
    80005f60:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005f64:	9701                	sra	a4,a4,0x20
    80005f66:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005f6a:	6898                	ld	a4,16(s1)
    80005f6c:	0007069b          	sext.w	a3,a4
    80005f70:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005f74:	9701                	sra	a4,a4,0x20
    80005f76:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005f7a:	4705                	li	a4,1
    80005f7c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005f7e:	00e48c23          	sb	a4,24(s1)
    80005f82:	00e48ca3          	sb	a4,25(s1)
    80005f86:	00e48d23          	sb	a4,26(s1)
    80005f8a:	00e48da3          	sb	a4,27(s1)
    80005f8e:	00e48e23          	sb	a4,28(s1)
    80005f92:	00e48ea3          	sb	a4,29(s1)
    80005f96:	00e48f23          	sb	a4,30(s1)
    80005f9a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005f9e:	00496913          	or	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005fa2:	0727a823          	sw	s2,112(a5)
}
    80005fa6:	60e2                	ld	ra,24(sp)
    80005fa8:	6442                	ld	s0,16(sp)
    80005faa:	64a2                	ld	s1,8(sp)
    80005fac:	6902                	ld	s2,0(sp)
    80005fae:	6105                	add	sp,sp,32
    80005fb0:	8082                	ret
    panic("could not find virtio disk");
    80005fb2:	00003517          	auipc	a0,0x3
    80005fb6:	80e50513          	add	a0,a0,-2034 # 800087c0 <syscalls+0x330>
    80005fba:	ffffa097          	auipc	ra,0xffffa
    80005fbe:	582080e7          	jalr	1410(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005fc2:	00003517          	auipc	a0,0x3
    80005fc6:	81e50513          	add	a0,a0,-2018 # 800087e0 <syscalls+0x350>
    80005fca:	ffffa097          	auipc	ra,0xffffa
    80005fce:	572080e7          	jalr	1394(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005fd2:	00003517          	auipc	a0,0x3
    80005fd6:	82e50513          	add	a0,a0,-2002 # 80008800 <syscalls+0x370>
    80005fda:	ffffa097          	auipc	ra,0xffffa
    80005fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005fe2:	00003517          	auipc	a0,0x3
    80005fe6:	83e50513          	add	a0,a0,-1986 # 80008820 <syscalls+0x390>
    80005fea:	ffffa097          	auipc	ra,0xffffa
    80005fee:	552080e7          	jalr	1362(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005ff2:	00003517          	auipc	a0,0x3
    80005ff6:	84e50513          	add	a0,a0,-1970 # 80008840 <syscalls+0x3b0>
    80005ffa:	ffffa097          	auipc	ra,0xffffa
    80005ffe:	542080e7          	jalr	1346(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80006002:	00003517          	auipc	a0,0x3
    80006006:	85e50513          	add	a0,a0,-1954 # 80008860 <syscalls+0x3d0>
    8000600a:	ffffa097          	auipc	ra,0xffffa
    8000600e:	532080e7          	jalr	1330(ra) # 8000053c <panic>

0000000080006012 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80006012:	7159                	add	sp,sp,-112
    80006014:	f486                	sd	ra,104(sp)
    80006016:	f0a2                	sd	s0,96(sp)
    80006018:	eca6                	sd	s1,88(sp)
    8000601a:	e8ca                	sd	s2,80(sp)
    8000601c:	e4ce                	sd	s3,72(sp)
    8000601e:	e0d2                	sd	s4,64(sp)
    80006020:	fc56                	sd	s5,56(sp)
    80006022:	f85a                	sd	s6,48(sp)
    80006024:	f45e                	sd	s7,40(sp)
    80006026:	f062                	sd	s8,32(sp)
    80006028:	ec66                	sd	s9,24(sp)
    8000602a:	e86a                	sd	s10,16(sp)
    8000602c:	1880                	add	s0,sp,112
    8000602e:	8a2a                	mv	s4,a0
    80006030:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80006032:	00c52c83          	lw	s9,12(a0)
    80006036:	001c9c9b          	sllw	s9,s9,0x1
    8000603a:	1c82                	sll	s9,s9,0x20
    8000603c:	020cdc93          	srl	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80006040:	00193517          	auipc	a0,0x193
    80006044:	2f050513          	add	a0,a0,752 # 80199330 <disk+0x128>
    80006048:	ffffb097          	auipc	ra,0xffffb
    8000604c:	b8a080e7          	jalr	-1142(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80006050:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80006052:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006054:	00193b17          	auipc	s6,0x193
    80006058:	1b4b0b13          	add	s6,s6,436 # 80199208 <disk>
  for(int i = 0; i < 3; i++){
    8000605c:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    8000605e:	00193c17          	auipc	s8,0x193
    80006062:	2d2c0c13          	add	s8,s8,722 # 80199330 <disk+0x128>
    80006066:	a095                	j	800060ca <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80006068:	00fb0733          	add	a4,s6,a5
    8000606c:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006070:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80006072:	0207c563          	bltz	a5,8000609c <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80006076:	2605                	addw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80006078:	0591                	add	a1,a1,4
    8000607a:	05560d63          	beq	a2,s5,800060d4 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    8000607e:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80006080:	00193717          	auipc	a4,0x193
    80006084:	18870713          	add	a4,a4,392 # 80199208 <disk>
    80006088:	87ca                	mv	a5,s2
    if(disk.free[i]){
    8000608a:	01874683          	lbu	a3,24(a4)
    8000608e:	fee9                	bnez	a3,80006068 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80006090:	2785                	addw	a5,a5,1
    80006092:	0705                	add	a4,a4,1
    80006094:	fe979be3          	bne	a5,s1,8000608a <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80006098:	57fd                	li	a5,-1
    8000609a:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    8000609c:	00c05e63          	blez	a2,800060b8 <virtio_disk_rw+0xa6>
    800060a0:	060a                	sll	a2,a2,0x2
    800060a2:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    800060a6:	0009a503          	lw	a0,0(s3)
    800060aa:	00000097          	auipc	ra,0x0
    800060ae:	cfc080e7          	jalr	-772(ra) # 80005da6 <free_desc>
      for(int j = 0; j < i; j++)
    800060b2:	0991                	add	s3,s3,4
    800060b4:	ffa999e3          	bne	s3,s10,800060a6 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800060b8:	85e2                	mv	a1,s8
    800060ba:	00193517          	auipc	a0,0x193
    800060be:	16650513          	add	a0,a0,358 # 80199220 <disk+0x18>
    800060c2:	ffffc097          	auipc	ra,0xffffc
    800060c6:	040080e7          	jalr	64(ra) # 80002102 <sleep>
  for(int i = 0; i < 3; i++){
    800060ca:	f9040993          	add	s3,s0,-112
{
    800060ce:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    800060d0:	864a                	mv	a2,s2
    800060d2:	b775                	j	8000607e <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800060d4:	f9042503          	lw	a0,-112(s0)
    800060d8:	00a50713          	add	a4,a0,10
    800060dc:	0712                	sll	a4,a4,0x4

  if(write)
    800060de:	00193797          	auipc	a5,0x193
    800060e2:	12a78793          	add	a5,a5,298 # 80199208 <disk>
    800060e6:	00e786b3          	add	a3,a5,a4
    800060ea:	01703633          	snez	a2,s7
    800060ee:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800060f0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800060f4:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800060f8:	f6070613          	add	a2,a4,-160
    800060fc:	6394                	ld	a3,0(a5)
    800060fe:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006100:	00870593          	add	a1,a4,8
    80006104:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80006106:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80006108:	0007b803          	ld	a6,0(a5)
    8000610c:	9642                	add	a2,a2,a6
    8000610e:	46c1                	li	a3,16
    80006110:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80006112:	4585                	li	a1,1
    80006114:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80006118:	f9442683          	lw	a3,-108(s0)
    8000611c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80006120:	0692                	sll	a3,a3,0x4
    80006122:	9836                	add	a6,a6,a3
    80006124:	058a0613          	add	a2,s4,88
    80006128:	00c83023          	sd	a2,0(a6) # 1000 <_entry-0x7ffff000>
  disk.desc[idx[1]].len = BSIZE;
    8000612c:	0007b803          	ld	a6,0(a5)
    80006130:	96c2                	add	a3,a3,a6
    80006132:	40000613          	li	a2,1024
    80006136:	c690                	sw	a2,8(a3)
  if(write)
    80006138:	001bb613          	seqz	a2,s7
    8000613c:	0016161b          	sllw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80006140:	00166613          	or	a2,a2,1
    80006144:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80006148:	f9842603          	lw	a2,-104(s0)
    8000614c:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006150:	00250693          	add	a3,a0,2
    80006154:	0692                	sll	a3,a3,0x4
    80006156:	96be                	add	a3,a3,a5
    80006158:	58fd                	li	a7,-1
    8000615a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000615e:	0612                	sll	a2,a2,0x4
    80006160:	9832                	add	a6,a6,a2
    80006162:	f9070713          	add	a4,a4,-112
    80006166:	973e                	add	a4,a4,a5
    80006168:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000616c:	6398                	ld	a4,0(a5)
    8000616e:	9732                	add	a4,a4,a2
    80006170:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006172:	4609                	li	a2,2
    80006174:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006178:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000617c:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80006180:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006184:	6794                	ld	a3,8(a5)
    80006186:	0026d703          	lhu	a4,2(a3)
    8000618a:	8b1d                	and	a4,a4,7
    8000618c:	0706                	sll	a4,a4,0x1
    8000618e:	96ba                	add	a3,a3,a4
    80006190:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006194:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006198:	6798                	ld	a4,8(a5)
    8000619a:	00275783          	lhu	a5,2(a4)
    8000619e:	2785                	addw	a5,a5,1
    800061a0:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    800061a4:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    800061a8:	100017b7          	lui	a5,0x10001
    800061ac:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    800061b0:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800061b4:	00193917          	auipc	s2,0x193
    800061b8:	17c90913          	add	s2,s2,380 # 80199330 <disk+0x128>
  while(b->disk == 1) {
    800061bc:	4485                	li	s1,1
    800061be:	00b79c63          	bne	a5,a1,800061d6 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    800061c2:	85ca                	mv	a1,s2
    800061c4:	8552                	mv	a0,s4
    800061c6:	ffffc097          	auipc	ra,0xffffc
    800061ca:	f3c080e7          	jalr	-196(ra) # 80002102 <sleep>
  while(b->disk == 1) {
    800061ce:	004a2783          	lw	a5,4(s4)
    800061d2:	fe9788e3          	beq	a5,s1,800061c2 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    800061d6:	f9042903          	lw	s2,-112(s0)
    800061da:	00290713          	add	a4,s2,2
    800061de:	0712                	sll	a4,a4,0x4
    800061e0:	00193797          	auipc	a5,0x193
    800061e4:	02878793          	add	a5,a5,40 # 80199208 <disk>
    800061e8:	97ba                	add	a5,a5,a4
    800061ea:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800061ee:	00193997          	auipc	s3,0x193
    800061f2:	01a98993          	add	s3,s3,26 # 80199208 <disk>
    800061f6:	00491713          	sll	a4,s2,0x4
    800061fa:	0009b783          	ld	a5,0(s3)
    800061fe:	97ba                	add	a5,a5,a4
    80006200:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006204:	854a                	mv	a0,s2
    80006206:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000620a:	00000097          	auipc	ra,0x0
    8000620e:	b9c080e7          	jalr	-1124(ra) # 80005da6 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006212:	8885                	and	s1,s1,1
    80006214:	f0ed                	bnez	s1,800061f6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006216:	00193517          	auipc	a0,0x193
    8000621a:	11a50513          	add	a0,a0,282 # 80199330 <disk+0x128>
    8000621e:	ffffb097          	auipc	ra,0xffffb
    80006222:	a68080e7          	jalr	-1432(ra) # 80000c86 <release>
}
    80006226:	70a6                	ld	ra,104(sp)
    80006228:	7406                	ld	s0,96(sp)
    8000622a:	64e6                	ld	s1,88(sp)
    8000622c:	6946                	ld	s2,80(sp)
    8000622e:	69a6                	ld	s3,72(sp)
    80006230:	6a06                	ld	s4,64(sp)
    80006232:	7ae2                	ld	s5,56(sp)
    80006234:	7b42                	ld	s6,48(sp)
    80006236:	7ba2                	ld	s7,40(sp)
    80006238:	7c02                	ld	s8,32(sp)
    8000623a:	6ce2                	ld	s9,24(sp)
    8000623c:	6d42                	ld	s10,16(sp)
    8000623e:	6165                	add	sp,sp,112
    80006240:	8082                	ret

0000000080006242 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80006242:	1101                	add	sp,sp,-32
    80006244:	ec06                	sd	ra,24(sp)
    80006246:	e822                	sd	s0,16(sp)
    80006248:	e426                	sd	s1,8(sp)
    8000624a:	1000                	add	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000624c:	00193497          	auipc	s1,0x193
    80006250:	fbc48493          	add	s1,s1,-68 # 80199208 <disk>
    80006254:	00193517          	auipc	a0,0x193
    80006258:	0dc50513          	add	a0,a0,220 # 80199330 <disk+0x128>
    8000625c:	ffffb097          	auipc	ra,0xffffb
    80006260:	976080e7          	jalr	-1674(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006264:	10001737          	lui	a4,0x10001
    80006268:	533c                	lw	a5,96(a4)
    8000626a:	8b8d                	and	a5,a5,3
    8000626c:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000626e:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006272:	689c                	ld	a5,16(s1)
    80006274:	0204d703          	lhu	a4,32(s1)
    80006278:	0027d783          	lhu	a5,2(a5)
    8000627c:	04f70863          	beq	a4,a5,800062cc <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006280:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006284:	6898                	ld	a4,16(s1)
    80006286:	0204d783          	lhu	a5,32(s1)
    8000628a:	8b9d                	and	a5,a5,7
    8000628c:	078e                	sll	a5,a5,0x3
    8000628e:	97ba                	add	a5,a5,a4
    80006290:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006292:	00278713          	add	a4,a5,2
    80006296:	0712                	sll	a4,a4,0x4
    80006298:	9726                	add	a4,a4,s1
    8000629a:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    8000629e:	e721                	bnez	a4,800062e6 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    800062a0:	0789                	add	a5,a5,2
    800062a2:	0792                	sll	a5,a5,0x4
    800062a4:	97a6                	add	a5,a5,s1
    800062a6:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    800062a8:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800062ac:	ffffc097          	auipc	ra,0xffffc
    800062b0:	eba080e7          	jalr	-326(ra) # 80002166 <wakeup>

    disk.used_idx += 1;
    800062b4:	0204d783          	lhu	a5,32(s1)
    800062b8:	2785                	addw	a5,a5,1
    800062ba:	17c2                	sll	a5,a5,0x30
    800062bc:	93c1                	srl	a5,a5,0x30
    800062be:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800062c2:	6898                	ld	a4,16(s1)
    800062c4:	00275703          	lhu	a4,2(a4)
    800062c8:	faf71ce3          	bne	a4,a5,80006280 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800062cc:	00193517          	auipc	a0,0x193
    800062d0:	06450513          	add	a0,a0,100 # 80199330 <disk+0x128>
    800062d4:	ffffb097          	auipc	ra,0xffffb
    800062d8:	9b2080e7          	jalr	-1614(ra) # 80000c86 <release>
}
    800062dc:	60e2                	ld	ra,24(sp)
    800062de:	6442                	ld	s0,16(sp)
    800062e0:	64a2                	ld	s1,8(sp)
    800062e2:	6105                	add	sp,sp,32
    800062e4:	8082                	ret
      panic("virtio_disk_intr status");
    800062e6:	00002517          	auipc	a0,0x2
    800062ea:	59250513          	add	a0,a0,1426 # 80008878 <syscalls+0x3e8>
    800062ee:	ffffa097          	auipc	ra,0xffffa
    800062f2:	24e080e7          	jalr	590(ra) # 8000053c <panic>

00000000800062f6 <read_current_timestamp>:

int loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz);
int flags2perm(int flags);

/* CSE 536: (2.4) read current time. */
uint64 read_current_timestamp() {
    800062f6:	1101                	add	sp,sp,-32
    800062f8:	ec06                	sd	ra,24(sp)
    800062fa:	e822                	sd	s0,16(sp)
    800062fc:	e426                	sd	s1,8(sp)
    800062fe:	1000                	add	s0,sp,32
  uint64 curticks = 0;
  acquire(&tickslock);
    80006300:	00188517          	auipc	a0,0x188
    80006304:	c6050513          	add	a0,a0,-928 # 8018df60 <tickslock>
    80006308:	ffffb097          	auipc	ra,0xffffb
    8000630c:	8ca080e7          	jalr	-1846(ra) # 80000bd2 <acquire>
  curticks = ticks;
    80006310:	00002517          	auipc	a0,0x2
    80006314:	7b050513          	add	a0,a0,1968 # 80008ac0 <ticks>
    80006318:	00056483          	lwu	s1,0(a0)
  wakeup(&ticks);
    8000631c:	ffffc097          	auipc	ra,0xffffc
    80006320:	e4a080e7          	jalr	-438(ra) # 80002166 <wakeup>
  release(&tickslock);
    80006324:	00188517          	auipc	a0,0x188
    80006328:	c3c50513          	add	a0,a0,-964 # 8018df60 <tickslock>
    8000632c:	ffffb097          	auipc	ra,0xffffb
    80006330:	95a080e7          	jalr	-1702(ra) # 80000c86 <release>
  return curticks;
}
    80006334:	8526                	mv	a0,s1
    80006336:	60e2                	ld	ra,24(sp)
    80006338:	6442                	ld	s0,16(sp)
    8000633a:	64a2                	ld	s1,8(sp)
    8000633c:	6105                	add	sp,sp,32
    8000633e:	8082                	ret

0000000080006340 <init_psa_regions>:

bool psa_tracker[PSASIZE];

/* All blocks are free during initialization. */
void init_psa_regions(void)
{
    80006340:	1141                	add	sp,sp,-16
    80006342:	e422                	sd	s0,8(sp)
    80006344:	0800                	add	s0,sp,16
    for (int i = 0; i < PSASIZE; i++) 
    80006346:	00193797          	auipc	a5,0x193
    8000634a:	00278793          	add	a5,a5,2 # 80199348 <psa_tracker>
    8000634e:	00193717          	auipc	a4,0x193
    80006352:	3e270713          	add	a4,a4,994 # 80199730 <end>
        psa_tracker[i] = false;
    80006356:	00078023          	sb	zero,0(a5)
    for (int i = 0; i < PSASIZE; i++) 
    8000635a:	0785                	add	a5,a5,1
    8000635c:	fee79de3          	bne	a5,a4,80006356 <init_psa_regions+0x16>
}
    80006360:	6422                	ld	s0,8(sp)
    80006362:	0141                	add	sp,sp,16
    80006364:	8082                	ret

0000000080006366 <evict_page_to_disk>:

/* Evict heap page to disk when resident pages exceed limit */
void evict_page_to_disk(struct proc* p) {
    80006366:	1101                	add	sp,sp,-32
    80006368:	ec06                	sd	ra,24(sp)
    8000636a:	e822                	sd	s0,16(sp)
    8000636c:	e426                	sd	s1,8(sp)
    8000636e:	1000                	add	s0,sp,32
    /* Find free block */
    int blockno = 0;
    /* Find victim page using FIFO. */
    /* Print statement. */
    print_evict_page(0, 0);
    80006370:	4581                	li	a1,0
    80006372:	4501                	li	a0,0
    80006374:	00000097          	auipc	ra,0x0
    80006378:	302080e7          	jalr	770(ra) # 80006676 <print_evict_page>
    /* Read memory from the user to kernel memory first. */
    
    /* Write to the disk blocks. Below is a template as to how this works. There is
     * definitely a better way but this works for now. :p */
    struct buf* b;
    b = bread(1, PSASTART+(blockno));
    8000637c:	02100593          	li	a1,33
    80006380:	4505                	li	a0,1
    80006382:	ffffd097          	auipc	ra,0xffffd
    80006386:	bac080e7          	jalr	-1108(ra) # 80002f2e <bread>
    8000638a:	84aa                	mv	s1,a0
        // Copy page contents to b.data using memmove.
    bwrite(b);
    8000638c:	ffffd097          	auipc	ra,0xffffd
    80006390:	c94080e7          	jalr	-876(ra) # 80003020 <bwrite>
    brelse(b);
    80006394:	8526                	mv	a0,s1
    80006396:	ffffd097          	auipc	ra,0xffffd
    8000639a:	cc8080e7          	jalr	-824(ra) # 8000305e <brelse>

    /* Unmap swapped out page */
    /* Update the resident heap tracker. */
}
    8000639e:	60e2                	ld	ra,24(sp)
    800063a0:	6442                	ld	s0,16(sp)
    800063a2:	64a2                	ld	s1,8(sp)
    800063a4:	6105                	add	sp,sp,32
    800063a6:	8082                	ret

00000000800063a8 <retrieve_page_from_disk>:

/* Retrieve faulted page from disk. */
void retrieve_page_from_disk(struct proc* p, uint64 uvaddr) {
    800063a8:	1141                	add	sp,sp,-16
    800063aa:	e406                	sd	ra,8(sp)
    800063ac:	e022                	sd	s0,0(sp)
    800063ae:	0800                	add	s0,sp,16
    /* Find where the page is located in disk */

    /* Print statement. */
    print_retrieve_page(0, 0);
    800063b0:	4581                	li	a1,0
    800063b2:	4501                	li	a0,0
    800063b4:	00000097          	auipc	ra,0x0
    800063b8:	2ea080e7          	jalr	746(ra) # 8000669e <print_retrieve_page>
    /* Create a kernel page to read memory temporarily into first. */
    
    /* Read the disk block into temp kernel page. */

    /* Copy from temp kernel page to uvaddr (use copyout) */
}
    800063bc:	60a2                	ld	ra,8(sp)
    800063be:	6402                	ld	s0,0(sp)
    800063c0:	0141                	add	sp,sp,16
    800063c2:	8082                	ret

00000000800063c4 <page_fault_handler>:


void page_fault_handler(void) 
{
    800063c4:	7155                	add	sp,sp,-208
    800063c6:	e586                	sd	ra,200(sp)
    800063c8:	e1a2                	sd	s0,192(sp)
    800063ca:	fd26                	sd	s1,184(sp)
    800063cc:	f94a                	sd	s2,176(sp)
    800063ce:	f54e                	sd	s3,168(sp)
    800063d0:	f152                	sd	s4,160(sp)
    800063d2:	ed56                	sd	s5,152(sp)
    800063d4:	e95a                	sd	s6,144(sp)
    800063d6:	e55e                	sd	s7,136(sp)
    800063d8:	e162                	sd	s8,128(sp)
    800063da:	0980                	add	s0,sp,208
    /* Current process struct */
    struct proc *p = myproc();
    800063dc:	ffffb097          	auipc	ra,0xffffb
    800063e0:	61a080e7          	jalr	1562(ra) # 800019f6 <myproc>
    800063e4:	8aaa                	mv	s5,a0
    800063e6:	14302a73          	csrr	s4,stval
    uint64 faulting_addr = 0;
    faulting_addr = r_stval();
    // get the faulting address from stval and find the base address of the page
    // faulting_addr = PGROUNDDOWN(faulting_addr);
    faulting_addr >>= 12;
    faulting_addr <<= 12;
    800063ea:	77fd                	lui	a5,0xfffff
    800063ec:	00fa7a33          	and	s4,s4,a5
    print_page_fault(p->name, faulting_addr);
    800063f0:	15850493          	add	s1,a0,344
    800063f4:	85d2                	mv	a1,s4
    800063f6:	8526                	mv	a0,s1
    800063f8:	00000097          	auipc	ra,0x0
    800063fc:	23e080e7          	jalr	574(ra) # 80006636 <print_page_fault>
    uint64 pagesize = PGSIZE, allowed_size = 0, offset = 0, sz = 0;
    pagetable_t pagetable = 0;
    char* path = p->name;

    // same checks as in exec.c
    begin_op();    
    80006400:	ffffe097          	auipc	ra,0xffffe
    80006404:	ce4080e7          	jalr	-796(ra) # 800040e4 <begin_op>

    if((ip = namei(path)) == 0){
    80006408:	8526                	mv	a0,s1
    8000640a:	ffffe097          	auipc	ra,0xffffe
    8000640e:	ada080e7          	jalr	-1318(ra) # 80003ee4 <namei>
    80006412:	892a                	mv	s2,a0
    80006414:	c939                	beqz	a0,8000646a <page_fault_handler+0xa6>
        end_op();
    }
    ilock(ip);
    80006416:	ffffd097          	auipc	ra,0xffffd
    8000641a:	328080e7          	jalr	808(ra) # 8000373e <ilock>
    
    // read the elf header
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000641e:	04000713          	li	a4,64
    80006422:	4681                	li	a3,0
    80006424:	f7040613          	add	a2,s0,-144
    80006428:	4581                	li	a1,0
    8000642a:	854a                	mv	a0,s2
    8000642c:	ffffd097          	auipc	ra,0xffffd
    80006430:	5c6080e7          	jalr	1478(ra) # 800039f2 <readi>
    80006434:	04000793          	li	a5,64
    80006438:	14f51d63          	bne	a0,a5,80006592 <page_fault_handler+0x1ce>
        goto bad;

    if(elf.magic != ELF_MAGIC)
    8000643c:	f7042703          	lw	a4,-144(s0)
    80006440:	464c47b7          	lui	a5,0x464c4
    80006444:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80006448:	14f71563          	bne	a4,a5,80006592 <page_fault_handler+0x1ce>
        goto bad;

    if((pagetable = p->pagetable) == 0)
    8000644c:	050abb03          	ld	s6,80(s5)
    80006450:	120b0f63          	beqz	s6,8000658e <page_fault_handler+0x1ca>
        goto bad;

    // read the program section headers to find the one that contains the faulting address
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80006454:	f9042483          	lw	s1,-112(s0)
    80006458:	fa845783          	lhu	a5,-88(s0)
    8000645c:	10078463          	beqz	a5,80006564 <page_fault_handler+0x1a0>
    80006460:	4981                	li	s3,0
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
            goto bad;
        if(ph.type != ELF_PROG_LOAD)
    80006462:	4b85                	li	s7,1
            continue;
        if(ph.memsz < ph.filesz)
            goto bad;
        if(ph.vaddr + ph.memsz < ph.vaddr)
            goto bad;
        if(ph.vaddr % PGSIZE != 0)
    80006464:	6c05                	lui	s8,0x1
    80006466:	1c7d                	add	s8,s8,-1 # fff <_entry-0x7ffff001>
    80006468:	a889                	j	800064ba <page_fault_handler+0xf6>
        end_op();
    8000646a:	ffffe097          	auipc	ra,0xffffe
    8000646e:	cf4080e7          	jalr	-780(ra) # 8000415e <end_op>
    ilock(ip);
    80006472:	4501                	li	a0,0
    80006474:	ffffd097          	auipc	ra,0xffffd
    80006478:	2ca080e7          	jalr	714(ra) # 8000373e <ilock>
    if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    8000647c:	04000713          	li	a4,64
    80006480:	4681                	li	a3,0
    80006482:	f7040613          	add	a2,s0,-144
    80006486:	4581                	li	a1,0
    80006488:	4501                	li	a0,0
    8000648a:	ffffd097          	auipc	ra,0xffffd
    8000648e:	568080e7          	jalr	1384(ra) # 800039f2 <readi>
    80006492:	04000793          	li	a5,64
    80006496:	10f51763          	bne	a0,a5,800065a4 <page_fault_handler+0x1e0>
    if(elf.magic != ELF_MAGIC)
    8000649a:	f7042703          	lw	a4,-144(s0)
    8000649e:	464c47b7          	lui	a5,0x464c4
    800064a2:	57f78793          	add	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800064a6:	0ef71f63          	bne	a4,a5,800065a4 <page_fault_handler+0x1e0>
    800064aa:	b74d                	j	8000644c <page_fault_handler+0x88>
    for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800064ac:	2985                	addw	s3,s3,1
    800064ae:	0384849b          	addw	s1,s1,56
    800064b2:	fa845783          	lhu	a5,-88(s0)
    800064b6:	0af9d763          	bge	s3,a5,80006564 <page_fault_handler+0x1a0>
        if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    800064ba:	2481                	sext.w	s1,s1
    800064bc:	03800713          	li	a4,56
    800064c0:	86a6                	mv	a3,s1
    800064c2:	f3840613          	add	a2,s0,-200
    800064c6:	4581                	li	a1,0
    800064c8:	854a                	mv	a0,s2
    800064ca:	ffffd097          	auipc	ra,0xffffd
    800064ce:	528080e7          	jalr	1320(ra) # 800039f2 <readi>
    800064d2:	03800793          	li	a5,56
    800064d6:	0af51663          	bne	a0,a5,80006582 <page_fault_handler+0x1be>
        if(ph.type != ELF_PROG_LOAD)
    800064da:	f3842783          	lw	a5,-200(s0)
    800064de:	fd7797e3          	bne	a5,s7,800064ac <page_fault_handler+0xe8>
        if(ph.memsz < ph.filesz)
    800064e2:	f6043783          	ld	a5,-160(s0)
    800064e6:	f5843703          	ld	a4,-168(s0)
    800064ea:	08e7ec63          	bltu	a5,a4,80006582 <page_fault_handler+0x1be>
        if(ph.vaddr + ph.memsz < ph.vaddr)
    800064ee:	f4843703          	ld	a4,-184(s0)
    800064f2:	97ba                	add	a5,a5,a4
    800064f4:	08e7e763          	bltu	a5,a4,80006582 <page_fault_handler+0x1be>
        if(ph.vaddr % PGSIZE != 0)
    800064f8:	018776b3          	and	a3,a4,s8
    800064fc:	e2d9                	bnez	a3,80006582 <page_fault_handler+0x1be>
            goto bad;
        // find the program section header that contains the faulting address
        if((faulting_addr >= ph.vaddr) && (faulting_addr < (ph.vaddr + ph.memsz))){
    800064fe:	faea67e3          	bltu	s4,a4,800064ac <page_fault_handler+0xe8>
    80006502:	fafa75e3          	bgeu	s4,a5,800064ac <page_fault_handler+0xe8>

            allowed_size = ph.vaddr + ph.memsz - faulting_addr;
    80006506:	414784b3          	sub	s1,a5,s4
            if (allowed_size < pagesize)
    8000650a:	6785                	lui	a5,0x1
    8000650c:	0097f363          	bgeu	a5,s1,80006512 <page_fault_handler+0x14e>
    80006510:	6485                	lui	s1,0x1
                pagesize = allowed_size;

            offset = faulting_addr - ph.vaddr + ph.off;
    80006512:	f4043983          	ld	s3,-192(s0)
    80006516:	40e989b3          	sub	s3,s3,a4
    8000651a:	99d2                	add	s3,s3,s4

            // allocate a free page for the faulting address
            uvmalloc(pagetable, faulting_addr, faulting_addr + pagesize, flags2perm(ph.flags));
    8000651c:	01448ab3          	add	s5,s1,s4
    80006520:	f3c42503          	lw	a0,-196(s0)
    80006524:	ffffe097          	auipc	ra,0xffffe
    80006528:	6e0080e7          	jalr	1760(ra) # 80004c04 <flags2perm>
    8000652c:	86aa                	mv	a3,a0
    8000652e:	8656                	mv	a2,s5
    80006530:	85d2                	mv	a1,s4
    80006532:	855a                	mv	a0,s6
    80006534:	ffffb097          	auipc	ra,0xffffb
    80006538:	ed0080e7          	jalr	-304(ra) # 80001404 <uvmalloc>
            // load the program section into the allocated page
            loadseg(pagetable, faulting_addr, ip, offset, pagesize);
    8000653c:	2481                	sext.w	s1,s1
    8000653e:	8726                	mv	a4,s1
    80006540:	0009869b          	sext.w	a3,s3
    80006544:	864a                	mv	a2,s2
    80006546:	85d2                	mv	a1,s4
    80006548:	855a                	mv	a0,s6
    8000654a:	ffffe097          	auipc	ra,0xffffe
    8000654e:	6d4080e7          	jalr	1748(ra) # 80004c1e <loadseg>
            print_load_seg(faulting_addr, ph.off, pagesize);
    80006552:	8626                	mv	a2,s1
    80006554:	f4043583          	ld	a1,-192(s0)
    80006558:	8552                	mv	a0,s4
    8000655a:	00000097          	auipc	ra,0x0
    8000655e:	16c080e7          	jalr	364(ra) # 800066c6 <print_load_seg>
            goto out;
    80006562:	a089                	j	800065a4 <page_fault_handler+0x1e0>
    /* Go to out, since the remainder of this code is for the heap. */
    goto out;

heap_handle:
    /* 2.4: Check if resident pages are more than heap pages. If yes, evict. */
    if (p->resident_heap_pages == MAXRESHEAP) {
    80006564:	6799                	lui	a5,0x6
    80006566:	97d6                	add	a5,a5,s5
    80006568:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    8000656c:	06400793          	li	a5,100
    80006570:	04f70863          	beq	a4,a5,800065c0 <page_fault_handler+0x1fc>
    if (load_from_disk) {
        retrieve_page_from_disk(p, faulting_addr);
    }

    /* Track that another heap page has been brought into memory. */
    p->resident_heap_pages++;
    80006574:	6799                	lui	a5,0x6
    80006576:	97d6                	add	a5,a5,s5
    80006578:	f307a703          	lw	a4,-208(a5) # 5f30 <_entry-0x7fffa0d0>
    8000657c:	2705                	addw	a4,a4,1
    8000657e:	f2e7a823          	sw	a4,-208(a5)

bad:
    if(pagetable)
        proc_freepagetable(pagetable, sz);
    80006582:	4581                	li	a1,0
    80006584:	855a                	mv	a0,s6
    80006586:	ffffb097          	auipc	ra,0xffffb
    8000658a:	5d0080e7          	jalr	1488(ra) # 80001b56 <proc_freepagetable>
    if(ip){
    8000658e:	00090b63          	beqz	s2,800065a4 <page_fault_handler+0x1e0>
        iunlockput(ip);
    80006592:	854a                	mv	a0,s2
    80006594:	ffffd097          	auipc	ra,0xffffd
    80006598:	40c080e7          	jalr	1036(ra) # 800039a0 <iunlockput>
        end_op();
    8000659c:	ffffe097          	auipc	ra,0xffffe
    800065a0:	bc2080e7          	jalr	-1086(ra) # 8000415e <end_op>
  asm volatile("sfence.vma zero, zero");
    800065a4:	12000073          	sfence.vma

out:
    /* Flush stale page table entries. This is important to always do. */
    sfence_vma();
    return;
    800065a8:	60ae                	ld	ra,200(sp)
    800065aa:	640e                	ld	s0,192(sp)
    800065ac:	74ea                	ld	s1,184(sp)
    800065ae:	794a                	ld	s2,176(sp)
    800065b0:	79aa                	ld	s3,168(sp)
    800065b2:	7a0a                	ld	s4,160(sp)
    800065b4:	6aea                	ld	s5,152(sp)
    800065b6:	6b4a                	ld	s6,144(sp)
    800065b8:	6baa                	ld	s7,136(sp)
    800065ba:	6c0a                	ld	s8,128(sp)
    800065bc:	6169                	add	sp,sp,208
    800065be:	8082                	ret
        evict_page_to_disk(p);
    800065c0:	8556                	mv	a0,s5
    800065c2:	00000097          	auipc	ra,0x0
    800065c6:	da4080e7          	jalr	-604(ra) # 80006366 <evict_page_to_disk>
    800065ca:	b76d                	j	80006574 <page_fault_handler+0x1b0>

00000000800065cc <print_static_proc>:
#include "spinlock.h"
#include "proc.h"
#include "defs.h"
#include "elf.h"

void print_static_proc(char* name) {
    800065cc:	1141                	add	sp,sp,-16
    800065ce:	e406                	sd	ra,8(sp)
    800065d0:	e022                	sd	s0,0(sp)
    800065d2:	0800                	add	s0,sp,16
    800065d4:	85aa                	mv	a1,a0
    printf("Static process creation (proc: %s)\n", name);
    800065d6:	00002517          	auipc	a0,0x2
    800065da:	2ba50513          	add	a0,a0,698 # 80008890 <syscalls+0x400>
    800065de:	ffffa097          	auipc	ra,0xffffa
    800065e2:	fa8080e7          	jalr	-88(ra) # 80000586 <printf>
}
    800065e6:	60a2                	ld	ra,8(sp)
    800065e8:	6402                	ld	s0,0(sp)
    800065ea:	0141                	add	sp,sp,16
    800065ec:	8082                	ret

00000000800065ee <print_ondemand_proc>:

void print_ondemand_proc(char* name) {
    800065ee:	1141                	add	sp,sp,-16
    800065f0:	e406                	sd	ra,8(sp)
    800065f2:	e022                	sd	s0,0(sp)
    800065f4:	0800                	add	s0,sp,16
    800065f6:	85aa                	mv	a1,a0
    printf("Ondemand process creation (proc: %s)\n", name);
    800065f8:	00002517          	auipc	a0,0x2
    800065fc:	2c050513          	add	a0,a0,704 # 800088b8 <syscalls+0x428>
    80006600:	ffffa097          	auipc	ra,0xffffa
    80006604:	f86080e7          	jalr	-122(ra) # 80000586 <printf>
}
    80006608:	60a2                	ld	ra,8(sp)
    8000660a:	6402                	ld	s0,0(sp)
    8000660c:	0141                	add	sp,sp,16
    8000660e:	8082                	ret

0000000080006610 <print_skip_section>:

void print_skip_section(char* name, uint64 vaddr, int size) {
    80006610:	1141                	add	sp,sp,-16
    80006612:	e406                	sd	ra,8(sp)
    80006614:	e022                	sd	s0,0(sp)
    80006616:	0800                	add	s0,sp,16
    80006618:	86b2                	mv	a3,a2
    printf("Skipping program section loading (proc: %s, addr: %x, size: %d)\n", 
    8000661a:	862e                	mv	a2,a1
    8000661c:	85aa                	mv	a1,a0
    8000661e:	00002517          	auipc	a0,0x2
    80006622:	2c250513          	add	a0,a0,706 # 800088e0 <syscalls+0x450>
    80006626:	ffffa097          	auipc	ra,0xffffa
    8000662a:	f60080e7          	jalr	-160(ra) # 80000586 <printf>
        name, vaddr, size);
}
    8000662e:	60a2                	ld	ra,8(sp)
    80006630:	6402                	ld	s0,0(sp)
    80006632:	0141                	add	sp,sp,16
    80006634:	8082                	ret

0000000080006636 <print_page_fault>:

void print_page_fault(char* name, uint64 vaddr) {
    80006636:	1101                	add	sp,sp,-32
    80006638:	ec06                	sd	ra,24(sp)
    8000663a:	e822                	sd	s0,16(sp)
    8000663c:	e426                	sd	s1,8(sp)
    8000663e:	e04a                	sd	s2,0(sp)
    80006640:	1000                	add	s0,sp,32
    80006642:	84aa                	mv	s1,a0
    80006644:	892e                	mv	s2,a1
    printf("----------------------------------------\n");
    80006646:	00002517          	auipc	a0,0x2
    8000664a:	2e250513          	add	a0,a0,738 # 80008928 <syscalls+0x498>
    8000664e:	ffffa097          	auipc	ra,0xffffa
    80006652:	f38080e7          	jalr	-200(ra) # 80000586 <printf>
    printf("#PF: Proc (%s), Page (%x)\n", name, vaddr);
    80006656:	864a                	mv	a2,s2
    80006658:	85a6                	mv	a1,s1
    8000665a:	00002517          	auipc	a0,0x2
    8000665e:	2fe50513          	add	a0,a0,766 # 80008958 <syscalls+0x4c8>
    80006662:	ffffa097          	auipc	ra,0xffffa
    80006666:	f24080e7          	jalr	-220(ra) # 80000586 <printf>
}
    8000666a:	60e2                	ld	ra,24(sp)
    8000666c:	6442                	ld	s0,16(sp)
    8000666e:	64a2                	ld	s1,8(sp)
    80006670:	6902                	ld	s2,0(sp)
    80006672:	6105                	add	sp,sp,32
    80006674:	8082                	ret

0000000080006676 <print_evict_page>:

void print_evict_page(uint64 vaddr, int startblock) {
    80006676:	1141                	add	sp,sp,-16
    80006678:	e406                	sd	ra,8(sp)
    8000667a:	e022                	sd	s0,0(sp)
    8000667c:	0800                	add	s0,sp,16
    8000667e:	862e                	mv	a2,a1
    printf("EVICT: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    80006680:	0035869b          	addw	a3,a1,3
    80006684:	85aa                	mv	a1,a0
    80006686:	00002517          	auipc	a0,0x2
    8000668a:	2f250513          	add	a0,a0,754 # 80008978 <syscalls+0x4e8>
    8000668e:	ffffa097          	auipc	ra,0xffffa
    80006692:	ef8080e7          	jalr	-264(ra) # 80000586 <printf>
}
    80006696:	60a2                	ld	ra,8(sp)
    80006698:	6402                	ld	s0,0(sp)
    8000669a:	0141                	add	sp,sp,16
    8000669c:	8082                	ret

000000008000669e <print_retrieve_page>:

void print_retrieve_page(uint64 vaddr, int startblock) {
    8000669e:	1141                	add	sp,sp,-16
    800066a0:	e406                	sd	ra,8(sp)
    800066a2:	e022                	sd	s0,0(sp)
    800066a4:	0800                	add	s0,sp,16
    800066a6:	862e                	mv	a2,a1
    printf("RETRIEVE: Page (%x) --> PSA (%d - %d)\n", vaddr, startblock, startblock+3);
    800066a8:	0035869b          	addw	a3,a1,3
    800066ac:	85aa                	mv	a1,a0
    800066ae:	00002517          	auipc	a0,0x2
    800066b2:	2f250513          	add	a0,a0,754 # 800089a0 <syscalls+0x510>
    800066b6:	ffffa097          	auipc	ra,0xffffa
    800066ba:	ed0080e7          	jalr	-304(ra) # 80000586 <printf>
}
    800066be:	60a2                	ld	ra,8(sp)
    800066c0:	6402                	ld	s0,0(sp)
    800066c2:	0141                	add	sp,sp,16
    800066c4:	8082                	ret

00000000800066c6 <print_load_seg>:

void print_load_seg(uint64 vaddr, uint64 seg, int size) {
    800066c6:	1141                	add	sp,sp,-16
    800066c8:	e406                	sd	ra,8(sp)
    800066ca:	e022                	sd	s0,0(sp)
    800066cc:	0800                	add	s0,sp,16
    800066ce:	86b2                	mv	a3,a2
    printf("LOAD: Addr (%x), SEG: (%x), SIZE (%d)\n", vaddr, seg, size);
    800066d0:	862e                	mv	a2,a1
    800066d2:	85aa                	mv	a1,a0
    800066d4:	00002517          	auipc	a0,0x2
    800066d8:	2f450513          	add	a0,a0,756 # 800089c8 <syscalls+0x538>
    800066dc:	ffffa097          	auipc	ra,0xffffa
    800066e0:	eaa080e7          	jalr	-342(ra) # 80000586 <printf>
}
    800066e4:	60a2                	ld	ra,8(sp)
    800066e6:	6402                	ld	s0,0(sp)
    800066e8:	0141                	add	sp,sp,16
    800066ea:	8082                	ret

00000000800066ec <print_skip_heap_region>:

void print_skip_heap_region(char* name, uint64 vaddr, int npages) {
    800066ec:	1141                	add	sp,sp,-16
    800066ee:	e406                	sd	ra,8(sp)
    800066f0:	e022                	sd	s0,0(sp)
    800066f2:	0800                	add	s0,sp,16
    800066f4:	86b2                	mv	a3,a2
    printf("Skipping heap region allocation (proc: %s, addr: %x, npages: %d)\n", 
    800066f6:	862e                	mv	a2,a1
    800066f8:	85aa                	mv	a1,a0
    800066fa:	00002517          	auipc	a0,0x2
    800066fe:	2f650513          	add	a0,a0,758 # 800089f0 <syscalls+0x560>
    80006702:	ffffa097          	auipc	ra,0xffffa
    80006706:	e84080e7          	jalr	-380(ra) # 80000586 <printf>
        name, vaddr, npages);
}
    8000670a:	60a2                	ld	ra,8(sp)
    8000670c:	6402                	ld	s0,0(sp)
    8000670e:	0141                	add	sp,sp,16
    80006710:	8082                	ret
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
