
user/_test4:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
    /* Replace with ctime */
    return ctime();
}

/* Simple example that allocates heap memory and accesses it. */
void ul_start_func(int a1) {
   0:	7179                	add	sp,sp,-48
   2:	f406                	sd	ra,40(sp)
   4:	f022                	sd	s0,32(sp)
   6:	ec26                	sd	s1,24(sp)
   8:	e84a                	sd	s2,16(sp)
   a:	e44e                	sd	s3,8(sp)
   c:	e052                	sd	s4,0(sp)
   e:	1800                	add	s0,sp,48
  10:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d) \n", 
  12:	00001097          	auipc	ra,0x1
  16:	8d4080e7          	jalr	-1836(ra) # 8e6 <get_current_tid>
  1a:	85aa                	mv	a1,a0
  1c:	8626                	mv	a2,s1
  1e:	00001517          	auipc	a0,0x1
  22:	c4250513          	add	a0,a0,-958 # c60 <ulthread_context_switch+0x82>
  26:	00000097          	auipc	ra,0x0
  2a:	722080e7          	jalr	1826(ra) # 748 <printf>
    return ctime();
  2e:	00000097          	auipc	ra,0x0
  32:	44a080e7          	jalr	1098(ra) # 478 <ctime>
  36:	84aa                	mv	s1,a0
        get_current_tid(), a1);
    
    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;

    int scheduling_rounds = 0;
  38:	4901                	li	s2,0
    while (scheduling_rounds < 5) {
  3a:	4a15                	li	s4,5
        /* If 10000 cycles have passed, yield the CPU. */
        if ((get_current_time() - prev_time) >= 10000) {
  3c:	6989                	lui	s3,0x2
  3e:	70f98993          	add	s3,s3,1807 # 270f <stacks+0x16df>
    while (scheduling_rounds < 5) {
  42:	03490463          	beq	s2,s4,6a <ul_start_func+0x6a>
    return ctime();
  46:	00000097          	auipc	ra,0x0
  4a:	432080e7          	jalr	1074(ra) # 478 <ctime>
        if ((get_current_time() - prev_time) >= 10000) {
  4e:	8d05                	sub	a0,a0,s1
  50:	fea9f9e3          	bgeu	s3,a0,42 <ul_start_func+0x42>
            ulthread_yield();
  54:	00001097          	auipc	ra,0x1
  58:	aee080e7          	jalr	-1298(ra) # b42 <ulthread_yield>
    return ctime();
  5c:	00000097          	auipc	ra,0x0
  60:	41c080e7          	jalr	1052(ra) # 478 <ctime>
  64:	84aa                	mv	s1,a0
            /* Get time using ctime() */
            prev_time = get_current_time();
            scheduling_rounds++;
  66:	2905                	addw	s2,s2,1
  68:	bfe9                	j	42 <ul_start_func+0x42>
        }
    }

    /* Notify for a thread exit. */
    ulthread_destroy();
  6a:	00001097          	auipc	ra,0x1
  6e:	b26080e7          	jalr	-1242(ra) # b90 <ulthread_destroy>
}
  72:	70a2                	ld	ra,40(sp)
  74:	7402                	ld	s0,32(sp)
  76:	64e2                	ld	s1,24(sp)
  78:	6942                	ld	s2,16(sp)
  7a:	69a2                	ld	s3,8(sp)
  7c:	6a02                	ld	s4,0(sp)
  7e:	6145                	add	sp,sp,48
  80:	8082                	ret

0000000000000082 <get_current_time>:
uint64 get_current_time(void) {
  82:	1141                	add	sp,sp,-16
  84:	e406                	sd	ra,8(sp)
  86:	e022                	sd	s0,0(sp)
  88:	0800                	add	s0,sp,16
    return ctime();
  8a:	00000097          	auipc	ra,0x0
  8e:	3ee080e7          	jalr	1006(ra) # 478 <ctime>
}
  92:	60a2                	ld	ra,8(sp)
  94:	6402                	ld	s0,0(sp)
  96:	0141                	add	sp,sp,16
  98:	8082                	ret

000000000000009a <main>:

int
main(int argc, char *argv[])
{
  9a:	711d                	add	sp,sp,-96
  9c:	ec86                	sd	ra,88(sp)
  9e:	e8a2                	sd	s0,80(sp)
  a0:	e4a6                	sd	s1,72(sp)
  a2:	e0ca                	sd	s2,64(sp)
  a4:	fc4e                	sd	s3,56(sp)
  a6:	f852                	sd	s4,48(sp)
  a8:	1080                	add	s0,sp,96
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  aa:	00064637          	lui	a2,0x64
  ae:	4581                	li	a1,0
  b0:	00001517          	auipc	a0,0x1
  b4:	f8050513          	add	a0,a0,-128 # 1030 <stacks>
  b8:	00000097          	auipc	ra,0x0
  bc:	126080e7          	jalr	294(ra) # 1de <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  c0:	4501                	li	a0,0
  c2:	00001097          	auipc	ra,0x1
  c6:	83a080e7          	jalr	-1990(ra) # 8fc <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  ca:	00001797          	auipc	a5,0x1
  ce:	c0e78793          	add	a5,a5,-1010 # cd8 <ulthread_context_switch+0xfa>
  d2:	6388                	ld	a0,0(a5)
  d4:	678c                	ld	a1,8(a5)
  d6:	6b90                	ld	a2,16(a5)
  d8:	6f94                	ld	a3,24(a5)
  da:	7398                	ld	a4,32(a5)
  dc:	779c                	ld	a5,40(a5)
  de:	faa43023          	sd	a0,-96(s0)
  e2:	fab43423          	sd	a1,-88(s0)
  e6:	fac43823          	sd	a2,-80(s0)
  ea:	fad43c23          	sd	a3,-72(s0)
  ee:	fce43023          	sd	a4,-64(s0)
  f2:	fcf43423          	sd	a5,-56(s0)
    for (int i = 0; i < 3; i++)
  f6:	00002497          	auipc	s1,0x2
  fa:	f3a48493          	add	s1,s1,-198 # 2030 <stacks+0x1000>
  fe:	00005a17          	auipc	s4,0x5
 102:	f32a0a13          	add	s4,s4,-206 # 5030 <stacks+0x4000>
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 106:	00000997          	auipc	s3,0x0
 10a:	efa98993          	add	s3,s3,-262 # 0 <ul_start_func>
    for (int i = 0; i < 3; i++)
 10e:	6905                	lui	s2,0x1
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, -1);
 110:	56fd                	li	a3,-1
 112:	fa040613          	add	a2,s0,-96
 116:	85a6                	mv	a1,s1
 118:	854e                	mv	a0,s3
 11a:	00001097          	auipc	ra,0x1
 11e:	834080e7          	jalr	-1996(ra) # 94e <ulthread_create>
    for (int i = 0; i < 3; i++)
 122:	94ca                	add	s1,s1,s2
 124:	ff4496e3          	bne	s1,s4,110 <main+0x76>

    /* Schedule all of the threads */
    ulthread_schedule();
 128:	00001097          	auipc	ra,0x1
 12c:	8c6080e7          	jalr	-1850(ra) # 9ee <ulthread_schedule>

    printf("[*] User-Level Threading Test #4 (RR Collaborative) Complete.\n");
 130:	00001517          	auipc	a0,0x1
 134:	b6850513          	add	a0,a0,-1176 # c98 <ulthread_context_switch+0xba>
 138:	00000097          	auipc	ra,0x0
 13c:	610080e7          	jalr	1552(ra) # 748 <printf>
    return 0;
 140:	4501                	li	a0,0
 142:	60e6                	ld	ra,88(sp)
 144:	6446                	ld	s0,80(sp)
 146:	64a6                	ld	s1,72(sp)
 148:	6906                	ld	s2,64(sp)
 14a:	79e2                	ld	s3,56(sp)
 14c:	7a42                	ld	s4,48(sp)
 14e:	6125                	add	sp,sp,96
 150:	8082                	ret

0000000000000152 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 152:	1141                	add	sp,sp,-16
 154:	e406                	sd	ra,8(sp)
 156:	e022                	sd	s0,0(sp)
 158:	0800                	add	s0,sp,16
  extern int main();
  main();
 15a:	00000097          	auipc	ra,0x0
 15e:	f40080e7          	jalr	-192(ra) # 9a <main>
  exit(0);
 162:	4501                	li	a0,0
 164:	00000097          	auipc	ra,0x0
 168:	274080e7          	jalr	628(ra) # 3d8 <exit>

000000000000016c <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 16c:	1141                	add	sp,sp,-16
 16e:	e422                	sd	s0,8(sp)
 170:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 172:	87aa                	mv	a5,a0
 174:	0585                	add	a1,a1,1
 176:	0785                	add	a5,a5,1
 178:	fff5c703          	lbu	a4,-1(a1)
 17c:	fee78fa3          	sb	a4,-1(a5)
 180:	fb75                	bnez	a4,174 <strcpy+0x8>
    ;
  return os;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	add	sp,sp,16
 186:	8082                	ret

0000000000000188 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 188:	1141                	add	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb91                	beqz	a5,1a6 <strcmp+0x1e>
 194:	0005c703          	lbu	a4,0(a1)
 198:	00f71763          	bne	a4,a5,1a6 <strcmp+0x1e>
    p++, q++;
 19c:	0505                	add	a0,a0,1
 19e:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	fbe5                	bnez	a5,194 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1a6:	0005c503          	lbu	a0,0(a1)
}
 1aa:	40a7853b          	subw	a0,a5,a0
 1ae:	6422                	ld	s0,8(sp)
 1b0:	0141                	add	sp,sp,16
 1b2:	8082                	ret

00000000000001b4 <strlen>:

uint
strlen(const char *s)
{
 1b4:	1141                	add	sp,sp,-16
 1b6:	e422                	sd	s0,8(sp)
 1b8:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1ba:	00054783          	lbu	a5,0(a0)
 1be:	cf91                	beqz	a5,1da <strlen+0x26>
 1c0:	0505                	add	a0,a0,1
 1c2:	87aa                	mv	a5,a0
 1c4:	86be                	mv	a3,a5
 1c6:	0785                	add	a5,a5,1
 1c8:	fff7c703          	lbu	a4,-1(a5)
 1cc:	ff65                	bnez	a4,1c4 <strlen+0x10>
 1ce:	40a6853b          	subw	a0,a3,a0
 1d2:	2505                	addw	a0,a0,1
    ;
  return n;
}
 1d4:	6422                	ld	s0,8(sp)
 1d6:	0141                	add	sp,sp,16
 1d8:	8082                	ret
  for(n = 0; s[n]; n++)
 1da:	4501                	li	a0,0
 1dc:	bfe5                	j	1d4 <strlen+0x20>

00000000000001de <memset>:

void*
memset(void *dst, int c, uint n)
{
 1de:	1141                	add	sp,sp,-16
 1e0:	e422                	sd	s0,8(sp)
 1e2:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1e4:	ca19                	beqz	a2,1fa <memset+0x1c>
 1e6:	87aa                	mv	a5,a0
 1e8:	1602                	sll	a2,a2,0x20
 1ea:	9201                	srl	a2,a2,0x20
 1ec:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 1f0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1f4:	0785                	add	a5,a5,1
 1f6:	fee79de3          	bne	a5,a4,1f0 <memset+0x12>
  }
  return dst;
}
 1fa:	6422                	ld	s0,8(sp)
 1fc:	0141                	add	sp,sp,16
 1fe:	8082                	ret

0000000000000200 <strchr>:

char*
strchr(const char *s, char c)
{
 200:	1141                	add	sp,sp,-16
 202:	e422                	sd	s0,8(sp)
 204:	0800                	add	s0,sp,16
  for(; *s; s++)
 206:	00054783          	lbu	a5,0(a0)
 20a:	cb99                	beqz	a5,220 <strchr+0x20>
    if(*s == c)
 20c:	00f58763          	beq	a1,a5,21a <strchr+0x1a>
  for(; *s; s++)
 210:	0505                	add	a0,a0,1
 212:	00054783          	lbu	a5,0(a0)
 216:	fbfd                	bnez	a5,20c <strchr+0xc>
      return (char*)s;
  return 0;
 218:	4501                	li	a0,0
}
 21a:	6422                	ld	s0,8(sp)
 21c:	0141                	add	sp,sp,16
 21e:	8082                	ret
  return 0;
 220:	4501                	li	a0,0
 222:	bfe5                	j	21a <strchr+0x1a>

0000000000000224 <gets>:

char*
gets(char *buf, int max)
{
 224:	711d                	add	sp,sp,-96
 226:	ec86                	sd	ra,88(sp)
 228:	e8a2                	sd	s0,80(sp)
 22a:	e4a6                	sd	s1,72(sp)
 22c:	e0ca                	sd	s2,64(sp)
 22e:	fc4e                	sd	s3,56(sp)
 230:	f852                	sd	s4,48(sp)
 232:	f456                	sd	s5,40(sp)
 234:	f05a                	sd	s6,32(sp)
 236:	ec5e                	sd	s7,24(sp)
 238:	1080                	add	s0,sp,96
 23a:	8baa                	mv	s7,a0
 23c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 23e:	892a                	mv	s2,a0
 240:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 242:	4aa9                	li	s5,10
 244:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 246:	89a6                	mv	s3,s1
 248:	2485                	addw	s1,s1,1
 24a:	0344d863          	bge	s1,s4,27a <gets+0x56>
    cc = read(0, &c, 1);
 24e:	4605                	li	a2,1
 250:	faf40593          	add	a1,s0,-81
 254:	4501                	li	a0,0
 256:	00000097          	auipc	ra,0x0
 25a:	19a080e7          	jalr	410(ra) # 3f0 <read>
    if(cc < 1)
 25e:	00a05e63          	blez	a0,27a <gets+0x56>
    buf[i++] = c;
 262:	faf44783          	lbu	a5,-81(s0)
 266:	00f90023          	sb	a5,0(s2) # 1000 <scheduler_thread>
    if(c == '\n' || c == '\r')
 26a:	01578763          	beq	a5,s5,278 <gets+0x54>
 26e:	0905                	add	s2,s2,1
 270:	fd679be3          	bne	a5,s6,246 <gets+0x22>
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	a011                	j	27a <gets+0x56>
 278:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 27a:	99de                	add	s3,s3,s7
 27c:	00098023          	sb	zero,0(s3)
  return buf;
}
 280:	855e                	mv	a0,s7
 282:	60e6                	ld	ra,88(sp)
 284:	6446                	ld	s0,80(sp)
 286:	64a6                	ld	s1,72(sp)
 288:	6906                	ld	s2,64(sp)
 28a:	79e2                	ld	s3,56(sp)
 28c:	7a42                	ld	s4,48(sp)
 28e:	7aa2                	ld	s5,40(sp)
 290:	7b02                	ld	s6,32(sp)
 292:	6be2                	ld	s7,24(sp)
 294:	6125                	add	sp,sp,96
 296:	8082                	ret

0000000000000298 <stat>:

int
stat(const char *n, struct stat *st)
{
 298:	1101                	add	sp,sp,-32
 29a:	ec06                	sd	ra,24(sp)
 29c:	e822                	sd	s0,16(sp)
 29e:	e426                	sd	s1,8(sp)
 2a0:	e04a                	sd	s2,0(sp)
 2a2:	1000                	add	s0,sp,32
 2a4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2a6:	4581                	li	a1,0
 2a8:	00000097          	auipc	ra,0x0
 2ac:	170080e7          	jalr	368(ra) # 418 <open>
  if(fd < 0)
 2b0:	02054563          	bltz	a0,2da <stat+0x42>
 2b4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2b6:	85ca                	mv	a1,s2
 2b8:	00000097          	auipc	ra,0x0
 2bc:	178080e7          	jalr	376(ra) # 430 <fstat>
 2c0:	892a                	mv	s2,a0
  close(fd);
 2c2:	8526                	mv	a0,s1
 2c4:	00000097          	auipc	ra,0x0
 2c8:	13c080e7          	jalr	316(ra) # 400 <close>
  return r;
}
 2cc:	854a                	mv	a0,s2
 2ce:	60e2                	ld	ra,24(sp)
 2d0:	6442                	ld	s0,16(sp)
 2d2:	64a2                	ld	s1,8(sp)
 2d4:	6902                	ld	s2,0(sp)
 2d6:	6105                	add	sp,sp,32
 2d8:	8082                	ret
    return -1;
 2da:	597d                	li	s2,-1
 2dc:	bfc5                	j	2cc <stat+0x34>

00000000000002de <atoi>:

int
atoi(const char *s)
{
 2de:	1141                	add	sp,sp,-16
 2e0:	e422                	sd	s0,8(sp)
 2e2:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2e4:	00054683          	lbu	a3,0(a0)
 2e8:	fd06879b          	addw	a5,a3,-48
 2ec:	0ff7f793          	zext.b	a5,a5
 2f0:	4625                	li	a2,9
 2f2:	02f66863          	bltu	a2,a5,322 <atoi+0x44>
 2f6:	872a                	mv	a4,a0
  n = 0;
 2f8:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 2fa:	0705                	add	a4,a4,1
 2fc:	0025179b          	sllw	a5,a0,0x2
 300:	9fa9                	addw	a5,a5,a0
 302:	0017979b          	sllw	a5,a5,0x1
 306:	9fb5                	addw	a5,a5,a3
 308:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 30c:	00074683          	lbu	a3,0(a4)
 310:	fd06879b          	addw	a5,a3,-48
 314:	0ff7f793          	zext.b	a5,a5
 318:	fef671e3          	bgeu	a2,a5,2fa <atoi+0x1c>
  return n;
}
 31c:	6422                	ld	s0,8(sp)
 31e:	0141                	add	sp,sp,16
 320:	8082                	ret
  n = 0;
 322:	4501                	li	a0,0
 324:	bfe5                	j	31c <atoi+0x3e>

0000000000000326 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 326:	1141                	add	sp,sp,-16
 328:	e422                	sd	s0,8(sp)
 32a:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 32c:	02b57463          	bgeu	a0,a1,354 <memmove+0x2e>
    while(n-- > 0)
 330:	00c05f63          	blez	a2,34e <memmove+0x28>
 334:	1602                	sll	a2,a2,0x20
 336:	9201                	srl	a2,a2,0x20
 338:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 33c:	872a                	mv	a4,a0
      *dst++ = *src++;
 33e:	0585                	add	a1,a1,1
 340:	0705                	add	a4,a4,1
 342:	fff5c683          	lbu	a3,-1(a1)
 346:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 34a:	fee79ae3          	bne	a5,a4,33e <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 34e:	6422                	ld	s0,8(sp)
 350:	0141                	add	sp,sp,16
 352:	8082                	ret
    dst += n;
 354:	00c50733          	add	a4,a0,a2
    src += n;
 358:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 35a:	fec05ae3          	blez	a2,34e <memmove+0x28>
 35e:	fff6079b          	addw	a5,a2,-1 # 63fff <stacks+0x62fcf>
 362:	1782                	sll	a5,a5,0x20
 364:	9381                	srl	a5,a5,0x20
 366:	fff7c793          	not	a5,a5
 36a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 36c:	15fd                	add	a1,a1,-1
 36e:	177d                	add	a4,a4,-1
 370:	0005c683          	lbu	a3,0(a1)
 374:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 378:	fee79ae3          	bne	a5,a4,36c <memmove+0x46>
 37c:	bfc9                	j	34e <memmove+0x28>

000000000000037e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 37e:	1141                	add	sp,sp,-16
 380:	e422                	sd	s0,8(sp)
 382:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 384:	ca05                	beqz	a2,3b4 <memcmp+0x36>
 386:	fff6069b          	addw	a3,a2,-1
 38a:	1682                	sll	a3,a3,0x20
 38c:	9281                	srl	a3,a3,0x20
 38e:	0685                	add	a3,a3,1
 390:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 392:	00054783          	lbu	a5,0(a0)
 396:	0005c703          	lbu	a4,0(a1)
 39a:	00e79863          	bne	a5,a4,3aa <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 39e:	0505                	add	a0,a0,1
    p2++;
 3a0:	0585                	add	a1,a1,1
  while (n-- > 0) {
 3a2:	fed518e3          	bne	a0,a3,392 <memcmp+0x14>
  }
  return 0;
 3a6:	4501                	li	a0,0
 3a8:	a019                	j	3ae <memcmp+0x30>
      return *p1 - *p2;
 3aa:	40e7853b          	subw	a0,a5,a4
}
 3ae:	6422                	ld	s0,8(sp)
 3b0:	0141                	add	sp,sp,16
 3b2:	8082                	ret
  return 0;
 3b4:	4501                	li	a0,0
 3b6:	bfe5                	j	3ae <memcmp+0x30>

00000000000003b8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3b8:	1141                	add	sp,sp,-16
 3ba:	e406                	sd	ra,8(sp)
 3bc:	e022                	sd	s0,0(sp)
 3be:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 3c0:	00000097          	auipc	ra,0x0
 3c4:	f66080e7          	jalr	-154(ra) # 326 <memmove>
}
 3c8:	60a2                	ld	ra,8(sp)
 3ca:	6402                	ld	s0,0(sp)
 3cc:	0141                	add	sp,sp,16
 3ce:	8082                	ret

00000000000003d0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3d0:	4885                	li	a7,1
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3d8:	4889                	li	a7,2
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3e0:	488d                	li	a7,3
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3e8:	4891                	li	a7,4
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <read>:
.global read
read:
 li a7, SYS_read
 3f0:	4895                	li	a7,5
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <write>:
.global write
write:
 li a7, SYS_write
 3f8:	48c1                	li	a7,16
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <close>:
.global close
close:
 li a7, SYS_close
 400:	48d5                	li	a7,21
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <kill>:
.global kill
kill:
 li a7, SYS_kill
 408:	4899                	li	a7,6
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <exec>:
.global exec
exec:
 li a7, SYS_exec
 410:	489d                	li	a7,7
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <open>:
.global open
open:
 li a7, SYS_open
 418:	48bd                	li	a7,15
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 420:	48c5                	li	a7,17
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 428:	48c9                	li	a7,18
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 430:	48a1                	li	a7,8
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <link>:
.global link
link:
 li a7, SYS_link
 438:	48cd                	li	a7,19
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 440:	48d1                	li	a7,20
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 448:	48a5                	li	a7,9
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <dup>:
.global dup
dup:
 li a7, SYS_dup
 450:	48a9                	li	a7,10
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 458:	48ad                	li	a7,11
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 460:	48b1                	li	a7,12
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 468:	48b5                	li	a7,13
 ecall
 46a:	00000073          	ecall
 ret
 46e:	8082                	ret

0000000000000470 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 470:	48b9                	li	a7,14
 ecall
 472:	00000073          	ecall
 ret
 476:	8082                	ret

0000000000000478 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 478:	48d9                	li	a7,22
 ecall
 47a:	00000073          	ecall
 ret
 47e:	8082                	ret

0000000000000480 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 480:	1101                	add	sp,sp,-32
 482:	ec06                	sd	ra,24(sp)
 484:	e822                	sd	s0,16(sp)
 486:	1000                	add	s0,sp,32
 488:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 48c:	4605                	li	a2,1
 48e:	fef40593          	add	a1,s0,-17
 492:	00000097          	auipc	ra,0x0
 496:	f66080e7          	jalr	-154(ra) # 3f8 <write>
}
 49a:	60e2                	ld	ra,24(sp)
 49c:	6442                	ld	s0,16(sp)
 49e:	6105                	add	sp,sp,32
 4a0:	8082                	ret

00000000000004a2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4a2:	7139                	add	sp,sp,-64
 4a4:	fc06                	sd	ra,56(sp)
 4a6:	f822                	sd	s0,48(sp)
 4a8:	f426                	sd	s1,40(sp)
 4aa:	f04a                	sd	s2,32(sp)
 4ac:	ec4e                	sd	s3,24(sp)
 4ae:	0080                	add	s0,sp,64
 4b0:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4b2:	c299                	beqz	a3,4b8 <printint+0x16>
 4b4:	0805c963          	bltz	a1,546 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4b8:	2581                	sext.w	a1,a1
  neg = 0;
 4ba:	4881                	li	a7,0
 4bc:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 4c0:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4c2:	2601                	sext.w	a2,a2
 4c4:	00001517          	auipc	a0,0x1
 4c8:	8a450513          	add	a0,a0,-1884 # d68 <digits>
 4cc:	883a                	mv	a6,a4
 4ce:	2705                	addw	a4,a4,1
 4d0:	02c5f7bb          	remuw	a5,a1,a2
 4d4:	1782                	sll	a5,a5,0x20
 4d6:	9381                	srl	a5,a5,0x20
 4d8:	97aa                	add	a5,a5,a0
 4da:	0007c783          	lbu	a5,0(a5)
 4de:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4e2:	0005879b          	sext.w	a5,a1
 4e6:	02c5d5bb          	divuw	a1,a1,a2
 4ea:	0685                	add	a3,a3,1
 4ec:	fec7f0e3          	bgeu	a5,a2,4cc <printint+0x2a>
  if(neg)
 4f0:	00088c63          	beqz	a7,508 <printint+0x66>
    buf[i++] = '-';
 4f4:	fd070793          	add	a5,a4,-48
 4f8:	00878733          	add	a4,a5,s0
 4fc:	02d00793          	li	a5,45
 500:	fef70823          	sb	a5,-16(a4)
 504:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 508:	02e05863          	blez	a4,538 <printint+0x96>
 50c:	fc040793          	add	a5,s0,-64
 510:	00e78933          	add	s2,a5,a4
 514:	fff78993          	add	s3,a5,-1
 518:	99ba                	add	s3,s3,a4
 51a:	377d                	addw	a4,a4,-1
 51c:	1702                	sll	a4,a4,0x20
 51e:	9301                	srl	a4,a4,0x20
 520:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 524:	fff94583          	lbu	a1,-1(s2)
 528:	8526                	mv	a0,s1
 52a:	00000097          	auipc	ra,0x0
 52e:	f56080e7          	jalr	-170(ra) # 480 <putc>
  while(--i >= 0)
 532:	197d                	add	s2,s2,-1
 534:	ff3918e3          	bne	s2,s3,524 <printint+0x82>
}
 538:	70e2                	ld	ra,56(sp)
 53a:	7442                	ld	s0,48(sp)
 53c:	74a2                	ld	s1,40(sp)
 53e:	7902                	ld	s2,32(sp)
 540:	69e2                	ld	s3,24(sp)
 542:	6121                	add	sp,sp,64
 544:	8082                	ret
    x = -xx;
 546:	40b005bb          	negw	a1,a1
    neg = 1;
 54a:	4885                	li	a7,1
    x = -xx;
 54c:	bf85                	j	4bc <printint+0x1a>

000000000000054e <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 54e:	715d                	add	sp,sp,-80
 550:	e486                	sd	ra,72(sp)
 552:	e0a2                	sd	s0,64(sp)
 554:	fc26                	sd	s1,56(sp)
 556:	f84a                	sd	s2,48(sp)
 558:	f44e                	sd	s3,40(sp)
 55a:	f052                	sd	s4,32(sp)
 55c:	ec56                	sd	s5,24(sp)
 55e:	e85a                	sd	s6,16(sp)
 560:	e45e                	sd	s7,8(sp)
 562:	e062                	sd	s8,0(sp)
 564:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 566:	0005c903          	lbu	s2,0(a1)
 56a:	18090c63          	beqz	s2,702 <vprintf+0x1b4>
 56e:	8aaa                	mv	s5,a0
 570:	8bb2                	mv	s7,a2
 572:	00158493          	add	s1,a1,1
  state = 0;
 576:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 578:	02500a13          	li	s4,37
 57c:	4b55                	li	s6,21
 57e:	a839                	j	59c <vprintf+0x4e>
        putc(fd, c);
 580:	85ca                	mv	a1,s2
 582:	8556                	mv	a0,s5
 584:	00000097          	auipc	ra,0x0
 588:	efc080e7          	jalr	-260(ra) # 480 <putc>
 58c:	a019                	j	592 <vprintf+0x44>
    } else if(state == '%'){
 58e:	01498d63          	beq	s3,s4,5a8 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 592:	0485                	add	s1,s1,1
 594:	fff4c903          	lbu	s2,-1(s1)
 598:	16090563          	beqz	s2,702 <vprintf+0x1b4>
    if(state == 0){
 59c:	fe0999e3          	bnez	s3,58e <vprintf+0x40>
      if(c == '%'){
 5a0:	ff4910e3          	bne	s2,s4,580 <vprintf+0x32>
        state = '%';
 5a4:	89d2                	mv	s3,s4
 5a6:	b7f5                	j	592 <vprintf+0x44>
      if(c == 'd'){
 5a8:	13490263          	beq	s2,s4,6cc <vprintf+0x17e>
 5ac:	f9d9079b          	addw	a5,s2,-99
 5b0:	0ff7f793          	zext.b	a5,a5
 5b4:	12fb6563          	bltu	s6,a5,6de <vprintf+0x190>
 5b8:	f9d9079b          	addw	a5,s2,-99
 5bc:	0ff7f713          	zext.b	a4,a5
 5c0:	10eb6f63          	bltu	s6,a4,6de <vprintf+0x190>
 5c4:	00271793          	sll	a5,a4,0x2
 5c8:	00000717          	auipc	a4,0x0
 5cc:	74870713          	add	a4,a4,1864 # d10 <ulthread_context_switch+0x132>
 5d0:	97ba                	add	a5,a5,a4
 5d2:	439c                	lw	a5,0(a5)
 5d4:	97ba                	add	a5,a5,a4
 5d6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 5d8:	008b8913          	add	s2,s7,8
 5dc:	4685                	li	a3,1
 5de:	4629                	li	a2,10
 5e0:	000ba583          	lw	a1,0(s7)
 5e4:	8556                	mv	a0,s5
 5e6:	00000097          	auipc	ra,0x0
 5ea:	ebc080e7          	jalr	-324(ra) # 4a2 <printint>
 5ee:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b745                	j	592 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 5f4:	008b8913          	add	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4629                	li	a2,10
 5fc:	000ba583          	lw	a1,0(s7)
 600:	8556                	mv	a0,s5
 602:	00000097          	auipc	ra,0x0
 606:	ea0080e7          	jalr	-352(ra) # 4a2 <printint>
 60a:	8bca                	mv	s7,s2
      state = 0;
 60c:	4981                	li	s3,0
 60e:	b751                	j	592 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 610:	008b8913          	add	s2,s7,8
 614:	4681                	li	a3,0
 616:	4641                	li	a2,16
 618:	000ba583          	lw	a1,0(s7)
 61c:	8556                	mv	a0,s5
 61e:	00000097          	auipc	ra,0x0
 622:	e84080e7          	jalr	-380(ra) # 4a2 <printint>
 626:	8bca                	mv	s7,s2
      state = 0;
 628:	4981                	li	s3,0
 62a:	b7a5                	j	592 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 62c:	008b8c13          	add	s8,s7,8
 630:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 634:	03000593          	li	a1,48
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	e46080e7          	jalr	-442(ra) # 480 <putc>
  putc(fd, 'x');
 642:	07800593          	li	a1,120
 646:	8556                	mv	a0,s5
 648:	00000097          	auipc	ra,0x0
 64c:	e38080e7          	jalr	-456(ra) # 480 <putc>
 650:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 652:	00000b97          	auipc	s7,0x0
 656:	716b8b93          	add	s7,s7,1814 # d68 <digits>
 65a:	03c9d793          	srl	a5,s3,0x3c
 65e:	97de                	add	a5,a5,s7
 660:	0007c583          	lbu	a1,0(a5)
 664:	8556                	mv	a0,s5
 666:	00000097          	auipc	ra,0x0
 66a:	e1a080e7          	jalr	-486(ra) # 480 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 66e:	0992                	sll	s3,s3,0x4
 670:	397d                	addw	s2,s2,-1
 672:	fe0914e3          	bnez	s2,65a <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 676:	8be2                	mv	s7,s8
      state = 0;
 678:	4981                	li	s3,0
 67a:	bf21                	j	592 <vprintf+0x44>
        s = va_arg(ap, char*);
 67c:	008b8993          	add	s3,s7,8
 680:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 684:	02090163          	beqz	s2,6a6 <vprintf+0x158>
        while(*s != 0){
 688:	00094583          	lbu	a1,0(s2)
 68c:	c9a5                	beqz	a1,6fc <vprintf+0x1ae>
          putc(fd, *s);
 68e:	8556                	mv	a0,s5
 690:	00000097          	auipc	ra,0x0
 694:	df0080e7          	jalr	-528(ra) # 480 <putc>
          s++;
 698:	0905                	add	s2,s2,1
        while(*s != 0){
 69a:	00094583          	lbu	a1,0(s2)
 69e:	f9e5                	bnez	a1,68e <vprintf+0x140>
        s = va_arg(ap, char*);
 6a0:	8bce                	mv	s7,s3
      state = 0;
 6a2:	4981                	li	s3,0
 6a4:	b5fd                	j	592 <vprintf+0x44>
          s = "(null)";
 6a6:	00000917          	auipc	s2,0x0
 6aa:	66290913          	add	s2,s2,1634 # d08 <ulthread_context_switch+0x12a>
        while(*s != 0){
 6ae:	02800593          	li	a1,40
 6b2:	bff1                	j	68e <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6b4:	008b8913          	add	s2,s7,8
 6b8:	000bc583          	lbu	a1,0(s7)
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	dc2080e7          	jalr	-574(ra) # 480 <putc>
 6c6:	8bca                	mv	s7,s2
      state = 0;
 6c8:	4981                	li	s3,0
 6ca:	b5e1                	j	592 <vprintf+0x44>
        putc(fd, c);
 6cc:	02500593          	li	a1,37
 6d0:	8556                	mv	a0,s5
 6d2:	00000097          	auipc	ra,0x0
 6d6:	dae080e7          	jalr	-594(ra) # 480 <putc>
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd5d                	j	592 <vprintf+0x44>
        putc(fd, '%');
 6de:	02500593          	li	a1,37
 6e2:	8556                	mv	a0,s5
 6e4:	00000097          	auipc	ra,0x0
 6e8:	d9c080e7          	jalr	-612(ra) # 480 <putc>
        putc(fd, c);
 6ec:	85ca                	mv	a1,s2
 6ee:	8556                	mv	a0,s5
 6f0:	00000097          	auipc	ra,0x0
 6f4:	d90080e7          	jalr	-624(ra) # 480 <putc>
      state = 0;
 6f8:	4981                	li	s3,0
 6fa:	bd61                	j	592 <vprintf+0x44>
        s = va_arg(ap, char*);
 6fc:	8bce                	mv	s7,s3
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bd49                	j	592 <vprintf+0x44>
    }
  }
}
 702:	60a6                	ld	ra,72(sp)
 704:	6406                	ld	s0,64(sp)
 706:	74e2                	ld	s1,56(sp)
 708:	7942                	ld	s2,48(sp)
 70a:	79a2                	ld	s3,40(sp)
 70c:	7a02                	ld	s4,32(sp)
 70e:	6ae2                	ld	s5,24(sp)
 710:	6b42                	ld	s6,16(sp)
 712:	6ba2                	ld	s7,8(sp)
 714:	6c02                	ld	s8,0(sp)
 716:	6161                	add	sp,sp,80
 718:	8082                	ret

000000000000071a <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 71a:	715d                	add	sp,sp,-80
 71c:	ec06                	sd	ra,24(sp)
 71e:	e822                	sd	s0,16(sp)
 720:	1000                	add	s0,sp,32
 722:	e010                	sd	a2,0(s0)
 724:	e414                	sd	a3,8(s0)
 726:	e818                	sd	a4,16(s0)
 728:	ec1c                	sd	a5,24(s0)
 72a:	03043023          	sd	a6,32(s0)
 72e:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 732:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 736:	8622                	mv	a2,s0
 738:	00000097          	auipc	ra,0x0
 73c:	e16080e7          	jalr	-490(ra) # 54e <vprintf>
}
 740:	60e2                	ld	ra,24(sp)
 742:	6442                	ld	s0,16(sp)
 744:	6161                	add	sp,sp,80
 746:	8082                	ret

0000000000000748 <printf>:

void
printf(const char *fmt, ...)
{
 748:	711d                	add	sp,sp,-96
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	add	s0,sp,32
 750:	e40c                	sd	a1,8(s0)
 752:	e810                	sd	a2,16(s0)
 754:	ec14                	sd	a3,24(s0)
 756:	f018                	sd	a4,32(s0)
 758:	f41c                	sd	a5,40(s0)
 75a:	03043823          	sd	a6,48(s0)
 75e:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 762:	00840613          	add	a2,s0,8
 766:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 76a:	85aa                	mv	a1,a0
 76c:	4505                	li	a0,1
 76e:	00000097          	auipc	ra,0x0
 772:	de0080e7          	jalr	-544(ra) # 54e <vprintf>
}
 776:	60e2                	ld	ra,24(sp)
 778:	6442                	ld	s0,16(sp)
 77a:	6125                	add	sp,sp,96
 77c:	8082                	ret

000000000000077e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 77e:	1141                	add	sp,sp,-16
 780:	e422                	sd	s0,8(sp)
 782:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 784:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 788:	00001797          	auipc	a5,0x1
 78c:	8887b783          	ld	a5,-1912(a5) # 1010 <freep>
 790:	a02d                	j	7ba <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 792:	4618                	lw	a4,8(a2)
 794:	9f2d                	addw	a4,a4,a1
 796:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 79a:	6398                	ld	a4,0(a5)
 79c:	6310                	ld	a2,0(a4)
 79e:	a83d                	j	7dc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7a0:	ff852703          	lw	a4,-8(a0)
 7a4:	9f31                	addw	a4,a4,a2
 7a6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7a8:	ff053683          	ld	a3,-16(a0)
 7ac:	a091                	j	7f0 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ae:	6398                	ld	a4,0(a5)
 7b0:	00e7e463          	bltu	a5,a4,7b8 <free+0x3a>
 7b4:	00e6ea63          	bltu	a3,a4,7c8 <free+0x4a>
{
 7b8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	fed7fae3          	bgeu	a5,a3,7ae <free+0x30>
 7be:	6398                	ld	a4,0(a5)
 7c0:	00e6e463          	bltu	a3,a4,7c8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c4:	fee7eae3          	bltu	a5,a4,7b8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7c8:	ff852583          	lw	a1,-8(a0)
 7cc:	6390                	ld	a2,0(a5)
 7ce:	02059813          	sll	a6,a1,0x20
 7d2:	01c85713          	srl	a4,a6,0x1c
 7d6:	9736                	add	a4,a4,a3
 7d8:	fae60de3          	beq	a2,a4,792 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7dc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7e0:	4790                	lw	a2,8(a5)
 7e2:	02061593          	sll	a1,a2,0x20
 7e6:	01c5d713          	srl	a4,a1,0x1c
 7ea:	973e                	add	a4,a4,a5
 7ec:	fae68ae3          	beq	a3,a4,7a0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7f0:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7f2:	00001717          	auipc	a4,0x1
 7f6:	80f73f23          	sd	a5,-2018(a4) # 1010 <freep>
}
 7fa:	6422                	ld	s0,8(sp)
 7fc:	0141                	add	sp,sp,16
 7fe:	8082                	ret

0000000000000800 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 800:	7139                	add	sp,sp,-64
 802:	fc06                	sd	ra,56(sp)
 804:	f822                	sd	s0,48(sp)
 806:	f426                	sd	s1,40(sp)
 808:	f04a                	sd	s2,32(sp)
 80a:	ec4e                	sd	s3,24(sp)
 80c:	e852                	sd	s4,16(sp)
 80e:	e456                	sd	s5,8(sp)
 810:	e05a                	sd	s6,0(sp)
 812:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 814:	02051493          	sll	s1,a0,0x20
 818:	9081                	srl	s1,s1,0x20
 81a:	04bd                	add	s1,s1,15
 81c:	8091                	srl	s1,s1,0x4
 81e:	0014899b          	addw	s3,s1,1
 822:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 824:	00000517          	auipc	a0,0x0
 828:	7ec53503          	ld	a0,2028(a0) # 1010 <freep>
 82c:	c515                	beqz	a0,858 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 830:	4798                	lw	a4,8(a5)
 832:	02977f63          	bgeu	a4,s1,870 <malloc+0x70>
  if(nu < 4096)
 836:	8a4e                	mv	s4,s3
 838:	0009871b          	sext.w	a4,s3
 83c:	6685                	lui	a3,0x1
 83e:	00d77363          	bgeu	a4,a3,844 <malloc+0x44>
 842:	6a05                	lui	s4,0x1
 844:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 848:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84c:	00000917          	auipc	s2,0x0
 850:	7c490913          	add	s2,s2,1988 # 1010 <freep>
  if(p == (char*)-1)
 854:	5afd                	li	s5,-1
 856:	a895                	j	8ca <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 858:	00064797          	auipc	a5,0x64
 85c:	7d878793          	add	a5,a5,2008 # 65030 <base>
 860:	00000717          	auipc	a4,0x0
 864:	7af73823          	sd	a5,1968(a4) # 1010 <freep>
 868:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 86a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86e:	b7e1                	j	836 <malloc+0x36>
      if(p->s.size == nunits)
 870:	02e48c63          	beq	s1,a4,8a8 <malloc+0xa8>
        p->s.size -= nunits;
 874:	4137073b          	subw	a4,a4,s3
 878:	c798                	sw	a4,8(a5)
        p += p->s.size;
 87a:	02071693          	sll	a3,a4,0x20
 87e:	01c6d713          	srl	a4,a3,0x1c
 882:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 884:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 888:	00000717          	auipc	a4,0x0
 88c:	78a73423          	sd	a0,1928(a4) # 1010 <freep>
      return (void*)(p + 1);
 890:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 894:	70e2                	ld	ra,56(sp)
 896:	7442                	ld	s0,48(sp)
 898:	74a2                	ld	s1,40(sp)
 89a:	7902                	ld	s2,32(sp)
 89c:	69e2                	ld	s3,24(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
 8a4:	6121                	add	sp,sp,64
 8a6:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a8:	6398                	ld	a4,0(a5)
 8aa:	e118                	sd	a4,0(a0)
 8ac:	bff1                	j	888 <malloc+0x88>
  hp->s.size = nu;
 8ae:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8b2:	0541                	add	a0,a0,16
 8b4:	00000097          	auipc	ra,0x0
 8b8:	eca080e7          	jalr	-310(ra) # 77e <free>
  return freep;
 8bc:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8c0:	d971                	beqz	a0,894 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8c2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c4:	4798                	lw	a4,8(a5)
 8c6:	fa9775e3          	bgeu	a4,s1,870 <malloc+0x70>
    if(p == freep)
 8ca:	00093703          	ld	a4,0(s2)
 8ce:	853e                	mv	a0,a5
 8d0:	fef719e3          	bne	a4,a5,8c2 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 8d4:	8552                	mv	a0,s4
 8d6:	00000097          	auipc	ra,0x0
 8da:	b8a080e7          	jalr	-1142(ra) # 460 <sbrk>
  if(p == (char*)-1)
 8de:	fd5518e3          	bne	a0,s5,8ae <malloc+0xae>
        return 0;
 8e2:	4501                	li	a0,0
 8e4:	bf45                	j	894 <malloc+0x94>

00000000000008e6 <get_current_tid>:
enum ulthread_scheduling_algorithm scheduling_algorithm;

int prev_tid = 0;

/* Get thread ID */
int get_current_tid(void) {
 8e6:	1141                	add	sp,sp,-16
 8e8:	e422                	sd	s0,8(sp)
 8ea:	0800                	add	s0,sp,16
    return current_thread->tid;
}
 8ec:	00000797          	auipc	a5,0x0
 8f0:	7347b783          	ld	a5,1844(a5) # 1020 <current_thread>
 8f4:	4388                	lw	a0,0(a5)
 8f6:	6422                	ld	s0,8(sp)
 8f8:	0141                	add	sp,sp,16
 8fa:	8082                	ret

00000000000008fc <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo) {
 8fc:	1141                	add	sp,sp,-16
 8fe:	e422                	sd	s0,8(sp)
 900:	0800                	add	s0,sp,16

    struct ulthread *t;
    int i = 0;
 902:	4681                	li	a3,0
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 1 to MAXULTHREADS
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 904:	00064797          	auipc	a5,0x64
 908:	73c78793          	add	a5,a5,1852 # 65040 <ulthread>
 90c:	00069617          	auipc	a2,0x69
 910:	55460613          	add	a2,a2,1364 # 69e60 <ulthread+0x4e20>
        t->state = FREE;
 914:	0007a423          	sw	zero,8(a5)
        t->tid = i++;
 918:	c394                	sw	a3,0(a5)
 91a:	2685                	addw	a3,a3,1 # 1001 <scheduler_thread+0x1>
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 91c:	0c878793          	add	a5,a5,200
 920:	fec79ae3          	bne	a5,a2,914 <ulthread_init+0x18>
    }
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    scheduler_thread->state = RUNNABLE;
 924:	00000797          	auipc	a5,0x0
 928:	6dc78793          	add	a5,a5,1756 # 1000 <scheduler_thread>
 92c:	6398                	ld	a4,0(a5)
 92e:	4685                	li	a3,1
 930:	c714                	sw	a3,8(a4)
    scheduler_thread->tid = 0;
 932:	00072023          	sw	zero,0(a4)
    // Set the current thread to the scheduler thread
    current_thread = scheduler_thread;
 936:	639c                	ld	a5,0(a5)
 938:	00000717          	auipc	a4,0x0
 93c:	6ef73423          	sd	a5,1768(a4) # 1020 <current_thread>

    scheduling_algorithm = schedalgo;
 940:	00000797          	auipc	a5,0x0
 944:	6ca7ae23          	sw	a0,1756(a5) # 101c <scheduling_algorithm>
}
 948:	6422                	ld	s0,8(sp)
 94a:	0141                	add	sp,sp,16
 94c:	8082                	ret

000000000000094e <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
 94e:	7179                	add	sp,sp,-48
 950:	f406                	sd	ra,40(sp)
 952:	f022                	sd	s0,32(sp)
 954:	ec26                	sd	s1,24(sp)
 956:	e84a                	sd	s2,16(sp)
 958:	e44e                	sd	s3,8(sp)
 95a:	e052                	sd	s4,0(sp)
 95c:	1800                	add	s0,sp,48
 95e:	892a                	mv	s2,a0
 960:	89ae                	mv	s3,a1
 962:	8a36                	mv	s4,a3

    struct ulthread *t;

    // Find a free thread slot and initialize it
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 964:	00064497          	auipc	s1,0x64
 968:	7a448493          	add	s1,s1,1956 # 65108 <ulthread+0xc8>
 96c:	00069717          	auipc	a4,0x69
 970:	4f470713          	add	a4,a4,1268 # 69e60 <ulthread+0x4e20>
        if(t->state == FREE){
 974:	449c                	lw	a5,8(s1)
 976:	c799                	beqz	a5,984 <ulthread_create+0x36>
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 978:	0c848493          	add	s1,s1,200
 97c:	fee49ce3          	bne	s1,a4,974 <ulthread_create+0x26>
            t->priority = priority;
            break;
        }
    }
    if(t == &ulthread[MAXULTHREADS]){
        return false;
 980:	4501                	li	a0,0
 982:	a8a1                	j	9da <ulthread_create+0x8c>
            t->state = RUNNABLE;
 984:	4785                	li	a5,1
 986:	c49c                	sw	a5,8(s1)
            t->context.ra = start;
 988:	0324b423          	sd	s2,40(s1)
            t->context.sp = stack;
 98c:	0334b823          	sd	s3,48(s1)
            t->context.s0 = args[0];
 990:	621c                	ld	a5,0(a2)
 992:	fc9c                	sd	a5,56(s1)
            t->context.s1 = args[1];
 994:	661c                	ld	a5,8(a2)
 996:	e0bc                	sd	a5,64(s1)
            t->context.s2 = args[2];
 998:	6a1c                	ld	a5,16(a2)
 99a:	e4bc                	sd	a5,72(s1)
            t->context.s3 = args[3];
 99c:	6e1c                	ld	a5,24(a2)
 99e:	e8bc                	sd	a5,80(s1)
            t->context.s4 = args[4];
 9a0:	721c                	ld	a5,32(a2)
 9a2:	ecbc                	sd	a5,88(s1)
            t->context.s5 = args[5];
 9a4:	761c                	ld	a5,40(a2)
 9a6:	f0bc                	sd	a5,96(s1)
            t->ctime = ctime();
 9a8:	00000097          	auipc	ra,0x0
 9ac:	ad0080e7          	jalr	-1328(ra) # 478 <ctime>
 9b0:	f088                	sd	a0,32(s1)
            t->priority = priority;
 9b2:	0144a223          	sw	s4,4(s1)
    if(t == &ulthread[MAXULTHREADS]){
 9b6:	00069797          	auipc	a5,0x69
 9ba:	4aa78793          	add	a5,a5,1194 # 69e60 <ulthread+0x4e20>
 9be:	02f48663          	beq	s1,a5,9ea <ulthread_create+0x9c>
    }

    // current_thread = t;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 9c2:	86ce                	mv	a3,s3
 9c4:	864a                	mv	a2,s2
 9c6:	408c                	lw	a1,0(s1)
 9c8:	00000517          	auipc	a0,0x0
 9cc:	3b850513          	add	a0,a0,952 # d80 <digits+0x18>
 9d0:	00000097          	auipc	ra,0x0
 9d4:	d78080e7          	jalr	-648(ra) # 748 <printf>

    return true;
 9d8:	4505                	li	a0,1
}
 9da:	70a2                	ld	ra,40(sp)
 9dc:	7402                	ld	s0,32(sp)
 9de:	64e2                	ld	s1,24(sp)
 9e0:	6942                	ld	s2,16(sp)
 9e2:	69a2                	ld	s3,8(sp)
 9e4:	6a02                	ld	s4,0(sp)
 9e6:	6145                	add	sp,sp,48
 9e8:	8082                	ret
        return false;
 9ea:	4501                	li	a0,0
 9ec:	b7fd                	j	9da <ulthread_create+0x8c>

00000000000009ee <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void) {
 9ee:	715d                	add	sp,sp,-80
 9f0:	e486                	sd	ra,72(sp)
 9f2:	e0a2                	sd	s0,64(sp)
 9f4:	fc26                	sd	s1,56(sp)
 9f6:	f84a                	sd	s2,48(sp)
 9f8:	f44e                	sd	s3,40(sp)
 9fa:	f052                	sd	s4,32(sp)
 9fc:	ec56                	sd	s5,24(sp)
 9fe:	e85a                	sd	s6,16(sp)
 a00:	e45e                	sd	s7,8(sp)
 a02:	e062                	sd	s8,0(sp)
 a04:	0880                	add	s0,sp,80

    current_thread = scheduler_thread;
 a06:	00000797          	auipc	a5,0x0
 a0a:	5fa7b783          	ld	a5,1530(a5) # 1000 <scheduler_thread>
 a0e:	00000717          	auipc	a4,0x0
 a12:	60f73923          	sd	a5,1554(a4) # 1020 <current_thread>

        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){

            // printf("t->tid: %d\n", t->tid);
            
            if(scheduling_algorithm == 0){
 a16:	00000917          	auipc	s2,0x0
 a1a:	60690913          	add	s2,s2,1542 # 101c <scheduling_algorithm>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a1e:	00069497          	auipc	s1,0x69
 a22:	44248493          	add	s1,s1,1090 # 69e60 <ulthread+0x4e20>
                }
            }
        
            if(t != 0){
                
                current_thread = t;
 a26:	00000a97          	auipc	s5,0x0
 a2a:	5faa8a93          	add	s5,s5,1530 # 1020 <current_thread>

                flag = 1;

                /* Add this statement to denote which thread-id is being scheduled next */
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a2e:	00000a17          	auipc	s4,0x0
 a32:	37aa0a13          	add	s4,s4,890 # da8 <digits+0x40>

                // Switch between thread contexts from the scheduler thread to the new thread
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 a36:	00000997          	auipc	s3,0x0
 a3a:	5ca98993          	add	s3,s3,1482 # 1000 <scheduler_thread>
void ulthread_schedule(void) {
 a3e:	4701                	li	a4,0
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a40:	00064b17          	auipc	s6,0x64
 a44:	6c8b0b13          	add	s6,s6,1736 # 65108 <ulthread+0xc8>
                flag = 1;
 a48:	4b85                	li	s7,1
            else if(scheduling_algorithm == 2){
 a4a:	4c09                	li	s8,2
 a4c:	a83d                	j	a8a <ulthread_schedule+0x9c>
            else if(scheduling_algorithm == 1){
 a4e:	07778163          	beq	a5,s7,ab0 <ulthread_schedule+0xc2>
            else if(scheduling_algorithm == 2){
 a52:	09878a63          	beq	a5,s8,ae6 <ulthread_schedule+0xf8>
            if(t != 0){
 a56:	040b0163          	beqz	s6,a98 <ulthread_schedule+0xaa>
                current_thread = t;
 a5a:	016ab023          	sd	s6,0(s5)
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a5e:	000b2583          	lw	a1,0(s6)
 a62:	8552                	mv	a0,s4
 a64:	00000097          	auipc	ra,0x0
 a68:	ce4080e7          	jalr	-796(ra) # 748 <printf>
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 a6c:	0009b503          	ld	a0,0(s3)
 a70:	028b0593          	add	a1,s6,40
 a74:	02850513          	add	a0,a0,40
 a78:	00000097          	auipc	ra,0x0
 a7c:	166080e7          	jalr	358(ra) # bde <ulthread_context_switch>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a80:	00064b17          	auipc	s6,0x64
 a84:	750b0b13          	add	s6,s6,1872 # 651d0 <ulthread+0x190>
                flag = 1;
 a88:	875e                	mv	a4,s7
            if(scheduling_algorithm == 0){
 a8a:	00092783          	lw	a5,0(s2)
 a8e:	f3e1                	bnez	a5,a4e <ulthread_schedule+0x60>
                if(t->state != RUNNABLE){
 a90:	008b2783          	lw	a5,8(s6)
 a94:	fd7783e3          	beq	a5,s7,a5a <ulthread_schedule+0x6c>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a98:	0c8b0b13          	add	s6,s6,200
 a9c:	fe9b67e3          	bltu	s6,s1,a8a <ulthread_schedule+0x9c>

                t = &ulthread[1];
            }
            
        }
        if(flag == 0){
 aa0:	c749                	beqz	a4,b2a <ulthread_schedule+0x13c>
            break;
        }
        else{
            flag = 0;
            struct ulthread *t1 = 0;
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 aa2:	00064797          	auipc	a5,0x64
 aa6:	66678793          	add	a5,a5,1638 # 65108 <ulthread+0xc8>
                if(t1->state == YIELD){
 aaa:	4689                	li	a3,2
                    t1->state = RUNNABLE;
 aac:	4605                	li	a2,1
 aae:	a88d                	j	b20 <ulthread_schedule+0x132>
                if(t->state != RUNNABLE){
 ab0:	008b2783          	lw	a5,8(s6)
 ab4:	ff7792e3          	bne	a5,s7,a98 <ulthread_schedule+0xaa>
 ab8:	85da                	mv	a1,s6
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 aba:	00064797          	auipc	a5,0x64
 abe:	64e78793          	add	a5,a5,1614 # 65108 <ulthread+0xc8>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 ac2:	4685                	li	a3,1
 ac4:	a029                	j	ace <ulthread_schedule+0xe0>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 ac6:	0c878793          	add	a5,a5,200
 aca:	00978b63          	beq	a5,s1,ae0 <ulthread_schedule+0xf2>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 ace:	4798                	lw	a4,8(a5)
 ad0:	fed71be3          	bne	a4,a3,ac6 <ulthread_schedule+0xd8>
 ad4:	43d0                	lw	a2,4(a5)
 ad6:	41d8                	lw	a4,4(a1)
 ad8:	fec757e3          	bge	a4,a2,ac6 <ulthread_schedule+0xd8>
 adc:	85be                	mv	a1,a5
 ade:	b7e5                	j	ac6 <ulthread_schedule+0xd8>
                if(max_priority_thread != 0){
 ae0:	ddad                	beqz	a1,a5a <ulthread_schedule+0x6c>
 ae2:	8b2e                	mv	s6,a1
 ae4:	bf9d                	j	a5a <ulthread_schedule+0x6c>
                if(t->state != RUNNABLE){
 ae6:	008b2683          	lw	a3,8(s6)
 aea:	4785                	li	a5,1
 aec:	faf696e3          	bne	a3,a5,a98 <ulthread_schedule+0xaa>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 af0:	00064797          	auipc	a5,0x64
 af4:	61878793          	add	a5,a5,1560 # 65108 <ulthread+0xc8>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 af8:	4605                	li	a2,1
 afa:	a029                	j	b04 <ulthread_schedule+0x116>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 afc:	0c878793          	add	a5,a5,200
 b00:	f4978de3          	beq	a5,s1,a5a <ulthread_schedule+0x6c>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 b04:	7394                	ld	a3,32(a5)
 b06:	020b3703          	ld	a4,32(s6)
 b0a:	fee6f9e3          	bgeu	a3,a4,afc <ulthread_schedule+0x10e>
 b0e:	4798                	lw	a4,8(a5)
 b10:	fec716e3          	bne	a4,a2,afc <ulthread_schedule+0x10e>
 b14:	8b3e                	mv	s6,a5
 b16:	b7dd                	j	afc <ulthread_schedule+0x10e>
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 b18:	0c878793          	add	a5,a5,200
 b1c:	f29781e3          	beq	a5,s1,a3e <ulthread_schedule+0x50>
                if(t1->state == YIELD){
 b20:	4798                	lw	a4,8(a5)
 b22:	fed71be3          	bne	a4,a3,b18 <ulthread_schedule+0x12a>
                    t1->state = RUNNABLE;
 b26:	c790                	sw	a2,8(a5)
 b28:	bfc5                	j	b18 <ulthread_schedule+0x12a>
                }
            }
        }
    }
}
 b2a:	60a6                	ld	ra,72(sp)
 b2c:	6406                	ld	s0,64(sp)
 b2e:	74e2                	ld	s1,56(sp)
 b30:	7942                	ld	s2,48(sp)
 b32:	79a2                	ld	s3,40(sp)
 b34:	7a02                	ld	s4,32(sp)
 b36:	6ae2                	ld	s5,24(sp)
 b38:	6b42                	ld	s6,16(sp)
 b3a:	6ba2                	ld	s7,8(sp)
 b3c:	6c02                	ld	s8,0(sp)
 b3e:	6161                	add	sp,sp,80
 b40:	8082                	ret

0000000000000b42 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {
 b42:	1101                	add	sp,sp,-32
 b44:	ec06                	sd	ra,24(sp)
 b46:	e822                	sd	s0,16(sp)
 b48:	e426                	sd	s1,8(sp)
 b4a:	1000                	add	s0,sp,32

    current_thread->state = YIELD;
 b4c:	00000497          	auipc	s1,0x0
 b50:	4d448493          	add	s1,s1,1236 # 1020 <current_thread>
 b54:	609c                	ld	a5,0(s1)
 b56:	4709                	li	a4,2
 b58:	c798                	sw	a4,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid());
 b5a:	438c                	lw	a1,0(a5)
 b5c:	00000517          	auipc	a0,0x0
 b60:	26c50513          	add	a0,a0,620 # dc8 <digits+0x60>
 b64:	00000097          	auipc	ra,0x0
 b68:	be4080e7          	jalr	-1052(ra) # 748 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 b6c:	6088                	ld	a0,0(s1)
 b6e:	00000597          	auipc	a1,0x0
 b72:	4925b583          	ld	a1,1170(a1) # 1000 <scheduler_thread>
 b76:	02858593          	add	a1,a1,40
 b7a:	02850513          	add	a0,a0,40
 b7e:	00000097          	auipc	ra,0x0
 b82:	060080e7          	jalr	96(ra) # bde <ulthread_context_switch>
    
}
 b86:	60e2                	ld	ra,24(sp)
 b88:	6442                	ld	s0,16(sp)
 b8a:	64a2                	ld	s1,8(sp)
 b8c:	6105                	add	sp,sp,32
 b8e:	8082                	ret

0000000000000b90 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void) {
 b90:	1101                	add	sp,sp,-32
 b92:	ec06                	sd	ra,24(sp)
 b94:	e822                	sd	s0,16(sp)
 b96:	e426                	sd	s1,8(sp)
 b98:	1000                	add	s0,sp,32

    // find the current running thread and mark it as FREE
    current_thread->state = FREE;
 b9a:	00000497          	auipc	s1,0x0
 b9e:	48648493          	add	s1,s1,1158 # 1020 <current_thread>
 ba2:	609c                	ld	a5,0(s1)
 ba4:	0007a423          	sw	zero,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 ba8:	438c                	lw	a1,0(a5)
 baa:	00000517          	auipc	a0,0x0
 bae:	23650513          	add	a0,a0,566 # de0 <digits+0x78>
 bb2:	00000097          	auipc	ra,0x0
 bb6:	b96080e7          	jalr	-1130(ra) # 748 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 bba:	6088                	ld	a0,0(s1)
 bbc:	00000597          	auipc	a1,0x0
 bc0:	4445b583          	ld	a1,1092(a1) # 1000 <scheduler_thread>
 bc4:	02858593          	add	a1,a1,40
 bc8:	02850513          	add	a0,a0,40
 bcc:	00000097          	auipc	ra,0x0
 bd0:	012080e7          	jalr	18(ra) # bde <ulthread_context_switch>
}
 bd4:	60e2                	ld	ra,24(sp)
 bd6:	6442                	ld	s0,16(sp)
 bd8:	64a2                	ld	s1,8(sp)
 bda:	6105                	add	sp,sp,32
 bdc:	8082                	ret

0000000000000bde <ulthread_context_switch>:
 bde:	00153023          	sd	ra,0(a0)
 be2:	00253423          	sd	sp,8(a0)
 be6:	e900                	sd	s0,16(a0)
 be8:	ed04                	sd	s1,24(a0)
 bea:	03253023          	sd	s2,32(a0)
 bee:	03353423          	sd	s3,40(a0)
 bf2:	03453823          	sd	s4,48(a0)
 bf6:	03553c23          	sd	s5,56(a0)
 bfa:	05653023          	sd	s6,64(a0)
 bfe:	05753423          	sd	s7,72(a0)
 c02:	05853823          	sd	s8,80(a0)
 c06:	05953c23          	sd	s9,88(a0)
 c0a:	07a53023          	sd	s10,96(a0)
 c0e:	07b53423          	sd	s11,104(a0)
 c12:	0005b083          	ld	ra,0(a1)
 c16:	0085b103          	ld	sp,8(a1)
 c1a:	6980                	ld	s0,16(a1)
 c1c:	6d84                	ld	s1,24(a1)
 c1e:	0205b903          	ld	s2,32(a1)
 c22:	0285b983          	ld	s3,40(a1)
 c26:	0305ba03          	ld	s4,48(a1)
 c2a:	0385ba83          	ld	s5,56(a1)
 c2e:	0405bb03          	ld	s6,64(a1)
 c32:	0485bb83          	ld	s7,72(a1)
 c36:	0505bc03          	ld	s8,80(a1)
 c3a:	0585bc83          	ld	s9,88(a1)
 c3e:	0605bd03          	ld	s10,96(a1)
 c42:	0685bd83          	ld	s11,104(a1)
 c46:	00040513          	mv	a0,s0
 c4a:	00048593          	mv	a1,s1
 c4e:	00090613          	mv	a2,s2
 c52:	00098693          	mv	a3,s3
 c56:	000a0713          	mv	a4,s4
 c5a:	000a8793          	mv	a5,s5
 c5e:	8082                	ret
