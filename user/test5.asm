
user/_test5:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
    /* Replace with ctime */
    return ctime();
}

/* Simple example that allocates heap memory and accesses it. */
void ul_start_func(int a1) {
   0:	7139                	add	sp,sp,-64
   2:	fc06                	sd	ra,56(sp)
   4:	f822                	sd	s0,48(sp)
   6:	f426                	sd	s1,40(sp)
   8:	f04a                	sd	s2,32(sp)
   a:	ec4e                	sd	s3,24(sp)
   c:	e852                	sd	s4,16(sp)
   e:	e456                	sd	s5,8(sp)
  10:	0080                	add	s0,sp,64
  12:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d) \n", 
  14:	00001097          	auipc	ra,0x1
  18:	900080e7          	jalr	-1792(ra) # 914 <get_current_tid>
  1c:	85aa                	mv	a1,a0
  1e:	8626                	mv	a2,s1
  20:	00001517          	auipc	a0,0x1
  24:	c7050513          	add	a0,a0,-912 # c90 <ulthread_context_switch+0x84>
  28:	00000097          	auipc	ra,0x0
  2c:	74e080e7          	jalr	1870(ra) # 776 <printf>
    return ctime();
  30:	00000097          	auipc	ra,0x0
  34:	476080e7          	jalr	1142(ra) # 4a6 <ctime>
  38:	8a2a                	mv	s4,a0

    uint64 start_time = get_current_time();
    uint64 prev_time = start_time;

    /* Execute for a really long period */
    for (int i = 0; i < 10000000; i++) {
  3a:	4481                	li	s1,0
        if (i%1000000 == 0) {
  3c:	000f49b7          	lui	s3,0xf4
  40:	2409899b          	addw	s3,s3,576 # f4240 <ulthread+0x8f200>
            if ((get_current_time() - prev_time) >= 10000) { 
  44:	6a89                	lui	s5,0x2
  46:	70fa8a93          	add	s5,s5,1807 # 270f <stacks+0x16df>
    for (int i = 0; i < 10000000; i++) {
  4a:	00989937          	lui	s2,0x989
  4e:	68090913          	add	s2,s2,1664 # 989680 <ulthread+0x924640>
  52:	a021                	j	5a <ul_start_func+0x5a>
  54:	2485                	addw	s1,s1,1
  56:	03248763          	beq	s1,s2,84 <ul_start_func+0x84>
        if (i%1000000 == 0) {
  5a:	0334e7bb          	remw	a5,s1,s3
  5e:	fbfd                	bnez	a5,54 <ul_start_func+0x54>
    return ctime();
  60:	00000097          	auipc	ra,0x0
  64:	446080e7          	jalr	1094(ra) # 4a6 <ctime>
            if ((get_current_time() - prev_time) >= 10000) { 
  68:	414507b3          	sub	a5,a0,s4
  6c:	fefaf4e3          	bgeu	s5,a5,54 <ul_start_func+0x54>
                ulthread_yield();
  70:	00001097          	auipc	ra,0x1
  74:	b00080e7          	jalr	-1280(ra) # b70 <ulthread_yield>
    return ctime();
  78:	00000097          	auipc	ra,0x0
  7c:	42e080e7          	jalr	1070(ra) # 4a6 <ctime>
  80:	8a2a                	mv	s4,a0
  82:	bfc9                	j	54 <ul_start_func+0x54>
            }
        }
    }

    /* Notify for a thread exit. */
    ulthread_destroy();
  84:	00001097          	auipc	ra,0x1
  88:	b3a080e7          	jalr	-1222(ra) # bbe <ulthread_destroy>
}
  8c:	70e2                	ld	ra,56(sp)
  8e:	7442                	ld	s0,48(sp)
  90:	74a2                	ld	s1,40(sp)
  92:	7902                	ld	s2,32(sp)
  94:	69e2                	ld	s3,24(sp)
  96:	6a42                	ld	s4,16(sp)
  98:	6aa2                	ld	s5,8(sp)
  9a:	6121                	add	sp,sp,64
  9c:	8082                	ret

000000000000009e <get_current_time>:
uint64 get_current_time(void) {
  9e:	1141                	add	sp,sp,-16
  a0:	e406                	sd	ra,8(sp)
  a2:	e022                	sd	s0,0(sp)
  a4:	0800                	add	s0,sp,16
    return ctime();
  a6:	00000097          	auipc	ra,0x0
  aa:	400080e7          	jalr	1024(ra) # 4a6 <ctime>
}
  ae:	60a2                	ld	ra,8(sp)
  b0:	6402                	ld	s0,0(sp)
  b2:	0141                	add	sp,sp,16
  b4:	8082                	ret

00000000000000b6 <main>:

int
main(int argc, char *argv[])
{
  b6:	715d                	add	sp,sp,-80
  b8:	e486                	sd	ra,72(sp)
  ba:	e0a2                	sd	s0,64(sp)
  bc:	fc26                	sd	s1,56(sp)
  be:	0880                	add	s0,sp,80
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  c0:	00064637          	lui	a2,0x64
  c4:	4581                	li	a1,0
  c6:	00001517          	auipc	a0,0x1
  ca:	f6a50513          	add	a0,a0,-150 # 1030 <stacks>
  ce:	00000097          	auipc	ra,0x0
  d2:	13e080e7          	jalr	318(ra) # 20c <memset>

    /* Initialize the user-level threading library */
    ulthread_init(FCFS);
  d6:	4509                	li	a0,2
  d8:	00001097          	auipc	ra,0x1
  dc:	852080e7          	jalr	-1966(ra) # 92a <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  e0:	00001797          	auipc	a5,0x1
  e4:	c3078793          	add	a5,a5,-976 # d10 <ulthread_context_switch+0x104>
  e8:	6388                	ld	a0,0(a5)
  ea:	678c                	ld	a1,8(a5)
  ec:	6b90                	ld	a2,16(a5)
  ee:	6f94                	ld	a3,24(a5)
  f0:	7398                	ld	a4,32(a5)
  f2:	779c                	ld	a5,40(a5)
  f4:	faa43823          	sd	a0,-80(s0)
  f8:	fab43c23          	sd	a1,-72(s0)
  fc:	fcc43023          	sd	a2,-64(s0)
 100:	fcd43423          	sd	a3,-56(s0)
 104:	fce43823          	sd	a4,-48(s0)
 108:	fcf43c23          	sd	a5,-40(s0)
    for (int i = 0; i < 3; i++)
        ulthread_create((uint64) ul_start_func, (uint64) (stacks+((i+1)*PGSIZE)), args, i%5);
 10c:	00000497          	auipc	s1,0x0
 110:	ef448493          	add	s1,s1,-268 # 0 <ul_start_func>
 114:	4681                	li	a3,0
 116:	fb040613          	add	a2,s0,-80
 11a:	00002597          	auipc	a1,0x2
 11e:	f1658593          	add	a1,a1,-234 # 2030 <stacks+0x1000>
 122:	8526                	mv	a0,s1
 124:	00001097          	auipc	ra,0x1
 128:	858080e7          	jalr	-1960(ra) # 97c <ulthread_create>
 12c:	4685                	li	a3,1
 12e:	fb040613          	add	a2,s0,-80
 132:	00003597          	auipc	a1,0x3
 136:	efe58593          	add	a1,a1,-258 # 3030 <stacks+0x2000>
 13a:	8526                	mv	a0,s1
 13c:	00001097          	auipc	ra,0x1
 140:	840080e7          	jalr	-1984(ra) # 97c <ulthread_create>
 144:	4689                	li	a3,2
 146:	fb040613          	add	a2,s0,-80
 14a:	00004597          	auipc	a1,0x4
 14e:	ee658593          	add	a1,a1,-282 # 4030 <stacks+0x3000>
 152:	8526                	mv	a0,s1
 154:	00001097          	auipc	ra,0x1
 158:	828080e7          	jalr	-2008(ra) # 97c <ulthread_create>

    /* Schedule all of the threads */
    ulthread_schedule();
 15c:	00001097          	auipc	ra,0x1
 160:	8c0080e7          	jalr	-1856(ra) # a1c <ulthread_schedule>

    printf("[*] User-Level Threading Test #5 (PRIO Collaborative) Complete.\n");
 164:	00001517          	auipc	a0,0x1
 168:	b6450513          	add	a0,a0,-1180 # cc8 <ulthread_context_switch+0xbc>
 16c:	00000097          	auipc	ra,0x0
 170:	60a080e7          	jalr	1546(ra) # 776 <printf>
    return 0;
}
 174:	4501                	li	a0,0
 176:	60a6                	ld	ra,72(sp)
 178:	6406                	ld	s0,64(sp)
 17a:	74e2                	ld	s1,56(sp)
 17c:	6161                	add	sp,sp,80
 17e:	8082                	ret

0000000000000180 <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 180:	1141                	add	sp,sp,-16
 182:	e406                	sd	ra,8(sp)
 184:	e022                	sd	s0,0(sp)
 186:	0800                	add	s0,sp,16
  extern int main();
  main();
 188:	00000097          	auipc	ra,0x0
 18c:	f2e080e7          	jalr	-210(ra) # b6 <main>
  exit(0);
 190:	4501                	li	a0,0
 192:	00000097          	auipc	ra,0x0
 196:	274080e7          	jalr	628(ra) # 406 <exit>

000000000000019a <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 19a:	1141                	add	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1a0:	87aa                	mv	a5,a0
 1a2:	0585                	add	a1,a1,1
 1a4:	0785                	add	a5,a5,1
 1a6:	fff5c703          	lbu	a4,-1(a1)
 1aa:	fee78fa3          	sb	a4,-1(a5)
 1ae:	fb75                	bnez	a4,1a2 <strcpy+0x8>
    ;
  return os;
}
 1b0:	6422                	ld	s0,8(sp)
 1b2:	0141                	add	sp,sp,16
 1b4:	8082                	ret

00000000000001b6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1b6:	1141                	add	sp,sp,-16
 1b8:	e422                	sd	s0,8(sp)
 1ba:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 1bc:	00054783          	lbu	a5,0(a0)
 1c0:	cb91                	beqz	a5,1d4 <strcmp+0x1e>
 1c2:	0005c703          	lbu	a4,0(a1)
 1c6:	00f71763          	bne	a4,a5,1d4 <strcmp+0x1e>
    p++, q++;
 1ca:	0505                	add	a0,a0,1
 1cc:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 1ce:	00054783          	lbu	a5,0(a0)
 1d2:	fbe5                	bnez	a5,1c2 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1d4:	0005c503          	lbu	a0,0(a1)
}
 1d8:	40a7853b          	subw	a0,a5,a0
 1dc:	6422                	ld	s0,8(sp)
 1de:	0141                	add	sp,sp,16
 1e0:	8082                	ret

00000000000001e2 <strlen>:

uint
strlen(const char *s)
{
 1e2:	1141                	add	sp,sp,-16
 1e4:	e422                	sd	s0,8(sp)
 1e6:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1e8:	00054783          	lbu	a5,0(a0)
 1ec:	cf91                	beqz	a5,208 <strlen+0x26>
 1ee:	0505                	add	a0,a0,1
 1f0:	87aa                	mv	a5,a0
 1f2:	86be                	mv	a3,a5
 1f4:	0785                	add	a5,a5,1
 1f6:	fff7c703          	lbu	a4,-1(a5)
 1fa:	ff65                	bnez	a4,1f2 <strlen+0x10>
 1fc:	40a6853b          	subw	a0,a3,a0
 200:	2505                	addw	a0,a0,1
    ;
  return n;
}
 202:	6422                	ld	s0,8(sp)
 204:	0141                	add	sp,sp,16
 206:	8082                	ret
  for(n = 0; s[n]; n++)
 208:	4501                	li	a0,0
 20a:	bfe5                	j	202 <strlen+0x20>

000000000000020c <memset>:

void*
memset(void *dst, int c, uint n)
{
 20c:	1141                	add	sp,sp,-16
 20e:	e422                	sd	s0,8(sp)
 210:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 212:	ca19                	beqz	a2,228 <memset+0x1c>
 214:	87aa                	mv	a5,a0
 216:	1602                	sll	a2,a2,0x20
 218:	9201                	srl	a2,a2,0x20
 21a:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 21e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 222:	0785                	add	a5,a5,1
 224:	fee79de3          	bne	a5,a4,21e <memset+0x12>
  }
  return dst;
}
 228:	6422                	ld	s0,8(sp)
 22a:	0141                	add	sp,sp,16
 22c:	8082                	ret

000000000000022e <strchr>:

char*
strchr(const char *s, char c)
{
 22e:	1141                	add	sp,sp,-16
 230:	e422                	sd	s0,8(sp)
 232:	0800                	add	s0,sp,16
  for(; *s; s++)
 234:	00054783          	lbu	a5,0(a0)
 238:	cb99                	beqz	a5,24e <strchr+0x20>
    if(*s == c)
 23a:	00f58763          	beq	a1,a5,248 <strchr+0x1a>
  for(; *s; s++)
 23e:	0505                	add	a0,a0,1
 240:	00054783          	lbu	a5,0(a0)
 244:	fbfd                	bnez	a5,23a <strchr+0xc>
      return (char*)s;
  return 0;
 246:	4501                	li	a0,0
}
 248:	6422                	ld	s0,8(sp)
 24a:	0141                	add	sp,sp,16
 24c:	8082                	ret
  return 0;
 24e:	4501                	li	a0,0
 250:	bfe5                	j	248 <strchr+0x1a>

0000000000000252 <gets>:

char*
gets(char *buf, int max)
{
 252:	711d                	add	sp,sp,-96
 254:	ec86                	sd	ra,88(sp)
 256:	e8a2                	sd	s0,80(sp)
 258:	e4a6                	sd	s1,72(sp)
 25a:	e0ca                	sd	s2,64(sp)
 25c:	fc4e                	sd	s3,56(sp)
 25e:	f852                	sd	s4,48(sp)
 260:	f456                	sd	s5,40(sp)
 262:	f05a                	sd	s6,32(sp)
 264:	ec5e                	sd	s7,24(sp)
 266:	1080                	add	s0,sp,96
 268:	8baa                	mv	s7,a0
 26a:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 26c:	892a                	mv	s2,a0
 26e:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 270:	4aa9                	li	s5,10
 272:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 274:	89a6                	mv	s3,s1
 276:	2485                	addw	s1,s1,1
 278:	0344d863          	bge	s1,s4,2a8 <gets+0x56>
    cc = read(0, &c, 1);
 27c:	4605                	li	a2,1
 27e:	faf40593          	add	a1,s0,-81
 282:	4501                	li	a0,0
 284:	00000097          	auipc	ra,0x0
 288:	19a080e7          	jalr	410(ra) # 41e <read>
    if(cc < 1)
 28c:	00a05e63          	blez	a0,2a8 <gets+0x56>
    buf[i++] = c;
 290:	faf44783          	lbu	a5,-81(s0)
 294:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 298:	01578763          	beq	a5,s5,2a6 <gets+0x54>
 29c:	0905                	add	s2,s2,1
 29e:	fd679be3          	bne	a5,s6,274 <gets+0x22>
  for(i=0; i+1 < max; ){
 2a2:	89a6                	mv	s3,s1
 2a4:	a011                	j	2a8 <gets+0x56>
 2a6:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2a8:	99de                	add	s3,s3,s7
 2aa:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ae:	855e                	mv	a0,s7
 2b0:	60e6                	ld	ra,88(sp)
 2b2:	6446                	ld	s0,80(sp)
 2b4:	64a6                	ld	s1,72(sp)
 2b6:	6906                	ld	s2,64(sp)
 2b8:	79e2                	ld	s3,56(sp)
 2ba:	7a42                	ld	s4,48(sp)
 2bc:	7aa2                	ld	s5,40(sp)
 2be:	7b02                	ld	s6,32(sp)
 2c0:	6be2                	ld	s7,24(sp)
 2c2:	6125                	add	sp,sp,96
 2c4:	8082                	ret

00000000000002c6 <stat>:

int
stat(const char *n, struct stat *st)
{
 2c6:	1101                	add	sp,sp,-32
 2c8:	ec06                	sd	ra,24(sp)
 2ca:	e822                	sd	s0,16(sp)
 2cc:	e426                	sd	s1,8(sp)
 2ce:	e04a                	sd	s2,0(sp)
 2d0:	1000                	add	s0,sp,32
 2d2:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2d4:	4581                	li	a1,0
 2d6:	00000097          	auipc	ra,0x0
 2da:	170080e7          	jalr	368(ra) # 446 <open>
  if(fd < 0)
 2de:	02054563          	bltz	a0,308 <stat+0x42>
 2e2:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2e4:	85ca                	mv	a1,s2
 2e6:	00000097          	auipc	ra,0x0
 2ea:	178080e7          	jalr	376(ra) # 45e <fstat>
 2ee:	892a                	mv	s2,a0
  close(fd);
 2f0:	8526                	mv	a0,s1
 2f2:	00000097          	auipc	ra,0x0
 2f6:	13c080e7          	jalr	316(ra) # 42e <close>
  return r;
}
 2fa:	854a                	mv	a0,s2
 2fc:	60e2                	ld	ra,24(sp)
 2fe:	6442                	ld	s0,16(sp)
 300:	64a2                	ld	s1,8(sp)
 302:	6902                	ld	s2,0(sp)
 304:	6105                	add	sp,sp,32
 306:	8082                	ret
    return -1;
 308:	597d                	li	s2,-1
 30a:	bfc5                	j	2fa <stat+0x34>

000000000000030c <atoi>:

int
atoi(const char *s)
{
 30c:	1141                	add	sp,sp,-16
 30e:	e422                	sd	s0,8(sp)
 310:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 312:	00054683          	lbu	a3,0(a0)
 316:	fd06879b          	addw	a5,a3,-48
 31a:	0ff7f793          	zext.b	a5,a5
 31e:	4625                	li	a2,9
 320:	02f66863          	bltu	a2,a5,350 <atoi+0x44>
 324:	872a                	mv	a4,a0
  n = 0;
 326:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 328:	0705                	add	a4,a4,1
 32a:	0025179b          	sllw	a5,a0,0x2
 32e:	9fa9                	addw	a5,a5,a0
 330:	0017979b          	sllw	a5,a5,0x1
 334:	9fb5                	addw	a5,a5,a3
 336:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 33a:	00074683          	lbu	a3,0(a4)
 33e:	fd06879b          	addw	a5,a3,-48
 342:	0ff7f793          	zext.b	a5,a5
 346:	fef671e3          	bgeu	a2,a5,328 <atoi+0x1c>
  return n;
}
 34a:	6422                	ld	s0,8(sp)
 34c:	0141                	add	sp,sp,16
 34e:	8082                	ret
  n = 0;
 350:	4501                	li	a0,0
 352:	bfe5                	j	34a <atoi+0x3e>

0000000000000354 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 354:	1141                	add	sp,sp,-16
 356:	e422                	sd	s0,8(sp)
 358:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 35a:	02b57463          	bgeu	a0,a1,382 <memmove+0x2e>
    while(n-- > 0)
 35e:	00c05f63          	blez	a2,37c <memmove+0x28>
 362:	1602                	sll	a2,a2,0x20
 364:	9201                	srl	a2,a2,0x20
 366:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 36a:	872a                	mv	a4,a0
      *dst++ = *src++;
 36c:	0585                	add	a1,a1,1
 36e:	0705                	add	a4,a4,1
 370:	fff5c683          	lbu	a3,-1(a1)
 374:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 378:	fee79ae3          	bne	a5,a4,36c <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 37c:	6422                	ld	s0,8(sp)
 37e:	0141                	add	sp,sp,16
 380:	8082                	ret
    dst += n;
 382:	00c50733          	add	a4,a0,a2
    src += n;
 386:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 388:	fec05ae3          	blez	a2,37c <memmove+0x28>
 38c:	fff6079b          	addw	a5,a2,-1 # 63fff <stacks+0x62fcf>
 390:	1782                	sll	a5,a5,0x20
 392:	9381                	srl	a5,a5,0x20
 394:	fff7c793          	not	a5,a5
 398:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 39a:	15fd                	add	a1,a1,-1
 39c:	177d                	add	a4,a4,-1
 39e:	0005c683          	lbu	a3,0(a1)
 3a2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3a6:	fee79ae3          	bne	a5,a4,39a <memmove+0x46>
 3aa:	bfc9                	j	37c <memmove+0x28>

00000000000003ac <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3ac:	1141                	add	sp,sp,-16
 3ae:	e422                	sd	s0,8(sp)
 3b0:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3b2:	ca05                	beqz	a2,3e2 <memcmp+0x36>
 3b4:	fff6069b          	addw	a3,a2,-1
 3b8:	1682                	sll	a3,a3,0x20
 3ba:	9281                	srl	a3,a3,0x20
 3bc:	0685                	add	a3,a3,1
 3be:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3c0:	00054783          	lbu	a5,0(a0)
 3c4:	0005c703          	lbu	a4,0(a1)
 3c8:	00e79863          	bne	a5,a4,3d8 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3cc:	0505                	add	a0,a0,1
    p2++;
 3ce:	0585                	add	a1,a1,1
  while (n-- > 0) {
 3d0:	fed518e3          	bne	a0,a3,3c0 <memcmp+0x14>
  }
  return 0;
 3d4:	4501                	li	a0,0
 3d6:	a019                	j	3dc <memcmp+0x30>
      return *p1 - *p2;
 3d8:	40e7853b          	subw	a0,a5,a4
}
 3dc:	6422                	ld	s0,8(sp)
 3de:	0141                	add	sp,sp,16
 3e0:	8082                	ret
  return 0;
 3e2:	4501                	li	a0,0
 3e4:	bfe5                	j	3dc <memcmp+0x30>

00000000000003e6 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3e6:	1141                	add	sp,sp,-16
 3e8:	e406                	sd	ra,8(sp)
 3ea:	e022                	sd	s0,0(sp)
 3ec:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 3ee:	00000097          	auipc	ra,0x0
 3f2:	f66080e7          	jalr	-154(ra) # 354 <memmove>
}
 3f6:	60a2                	ld	ra,8(sp)
 3f8:	6402                	ld	s0,0(sp)
 3fa:	0141                	add	sp,sp,16
 3fc:	8082                	ret

00000000000003fe <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3fe:	4885                	li	a7,1
 ecall
 400:	00000073          	ecall
 ret
 404:	8082                	ret

0000000000000406 <exit>:
.global exit
exit:
 li a7, SYS_exit
 406:	4889                	li	a7,2
 ecall
 408:	00000073          	ecall
 ret
 40c:	8082                	ret

000000000000040e <wait>:
.global wait
wait:
 li a7, SYS_wait
 40e:	488d                	li	a7,3
 ecall
 410:	00000073          	ecall
 ret
 414:	8082                	ret

0000000000000416 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 416:	4891                	li	a7,4
 ecall
 418:	00000073          	ecall
 ret
 41c:	8082                	ret

000000000000041e <read>:
.global read
read:
 li a7, SYS_read
 41e:	4895                	li	a7,5
 ecall
 420:	00000073          	ecall
 ret
 424:	8082                	ret

0000000000000426 <write>:
.global write
write:
 li a7, SYS_write
 426:	48c1                	li	a7,16
 ecall
 428:	00000073          	ecall
 ret
 42c:	8082                	ret

000000000000042e <close>:
.global close
close:
 li a7, SYS_close
 42e:	48d5                	li	a7,21
 ecall
 430:	00000073          	ecall
 ret
 434:	8082                	ret

0000000000000436 <kill>:
.global kill
kill:
 li a7, SYS_kill
 436:	4899                	li	a7,6
 ecall
 438:	00000073          	ecall
 ret
 43c:	8082                	ret

000000000000043e <exec>:
.global exec
exec:
 li a7, SYS_exec
 43e:	489d                	li	a7,7
 ecall
 440:	00000073          	ecall
 ret
 444:	8082                	ret

0000000000000446 <open>:
.global open
open:
 li a7, SYS_open
 446:	48bd                	li	a7,15
 ecall
 448:	00000073          	ecall
 ret
 44c:	8082                	ret

000000000000044e <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 44e:	48c5                	li	a7,17
 ecall
 450:	00000073          	ecall
 ret
 454:	8082                	ret

0000000000000456 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 456:	48c9                	li	a7,18
 ecall
 458:	00000073          	ecall
 ret
 45c:	8082                	ret

000000000000045e <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 45e:	48a1                	li	a7,8
 ecall
 460:	00000073          	ecall
 ret
 464:	8082                	ret

0000000000000466 <link>:
.global link
link:
 li a7, SYS_link
 466:	48cd                	li	a7,19
 ecall
 468:	00000073          	ecall
 ret
 46c:	8082                	ret

000000000000046e <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 46e:	48d1                	li	a7,20
 ecall
 470:	00000073          	ecall
 ret
 474:	8082                	ret

0000000000000476 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 476:	48a5                	li	a7,9
 ecall
 478:	00000073          	ecall
 ret
 47c:	8082                	ret

000000000000047e <dup>:
.global dup
dup:
 li a7, SYS_dup
 47e:	48a9                	li	a7,10
 ecall
 480:	00000073          	ecall
 ret
 484:	8082                	ret

0000000000000486 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 486:	48ad                	li	a7,11
 ecall
 488:	00000073          	ecall
 ret
 48c:	8082                	ret

000000000000048e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 48e:	48b1                	li	a7,12
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 496:	48b5                	li	a7,13
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 49e:	48b9                	li	a7,14
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 4a6:	48d9                	li	a7,22
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ae:	1101                	add	sp,sp,-32
 4b0:	ec06                	sd	ra,24(sp)
 4b2:	e822                	sd	s0,16(sp)
 4b4:	1000                	add	s0,sp,32
 4b6:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4ba:	4605                	li	a2,1
 4bc:	fef40593          	add	a1,s0,-17
 4c0:	00000097          	auipc	ra,0x0
 4c4:	f66080e7          	jalr	-154(ra) # 426 <write>
}
 4c8:	60e2                	ld	ra,24(sp)
 4ca:	6442                	ld	s0,16(sp)
 4cc:	6105                	add	sp,sp,32
 4ce:	8082                	ret

00000000000004d0 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4d0:	7139                	add	sp,sp,-64
 4d2:	fc06                	sd	ra,56(sp)
 4d4:	f822                	sd	s0,48(sp)
 4d6:	f426                	sd	s1,40(sp)
 4d8:	f04a                	sd	s2,32(sp)
 4da:	ec4e                	sd	s3,24(sp)
 4dc:	0080                	add	s0,sp,64
 4de:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4e0:	c299                	beqz	a3,4e6 <printint+0x16>
 4e2:	0805c963          	bltz	a1,574 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4e6:	2581                	sext.w	a1,a1
  neg = 0;
 4e8:	4881                	li	a7,0
 4ea:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 4ee:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4f0:	2601                	sext.w	a2,a2
 4f2:	00001517          	auipc	a0,0x1
 4f6:	8ae50513          	add	a0,a0,-1874 # da0 <digits>
 4fa:	883a                	mv	a6,a4
 4fc:	2705                	addw	a4,a4,1
 4fe:	02c5f7bb          	remuw	a5,a1,a2
 502:	1782                	sll	a5,a5,0x20
 504:	9381                	srl	a5,a5,0x20
 506:	97aa                	add	a5,a5,a0
 508:	0007c783          	lbu	a5,0(a5)
 50c:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 510:	0005879b          	sext.w	a5,a1
 514:	02c5d5bb          	divuw	a1,a1,a2
 518:	0685                	add	a3,a3,1
 51a:	fec7f0e3          	bgeu	a5,a2,4fa <printint+0x2a>
  if(neg)
 51e:	00088c63          	beqz	a7,536 <printint+0x66>
    buf[i++] = '-';
 522:	fd070793          	add	a5,a4,-48
 526:	00878733          	add	a4,a5,s0
 52a:	02d00793          	li	a5,45
 52e:	fef70823          	sb	a5,-16(a4)
 532:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 536:	02e05863          	blez	a4,566 <printint+0x96>
 53a:	fc040793          	add	a5,s0,-64
 53e:	00e78933          	add	s2,a5,a4
 542:	fff78993          	add	s3,a5,-1
 546:	99ba                	add	s3,s3,a4
 548:	377d                	addw	a4,a4,-1
 54a:	1702                	sll	a4,a4,0x20
 54c:	9301                	srl	a4,a4,0x20
 54e:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 552:	fff94583          	lbu	a1,-1(s2)
 556:	8526                	mv	a0,s1
 558:	00000097          	auipc	ra,0x0
 55c:	f56080e7          	jalr	-170(ra) # 4ae <putc>
  while(--i >= 0)
 560:	197d                	add	s2,s2,-1
 562:	ff3918e3          	bne	s2,s3,552 <printint+0x82>
}
 566:	70e2                	ld	ra,56(sp)
 568:	7442                	ld	s0,48(sp)
 56a:	74a2                	ld	s1,40(sp)
 56c:	7902                	ld	s2,32(sp)
 56e:	69e2                	ld	s3,24(sp)
 570:	6121                	add	sp,sp,64
 572:	8082                	ret
    x = -xx;
 574:	40b005bb          	negw	a1,a1
    neg = 1;
 578:	4885                	li	a7,1
    x = -xx;
 57a:	bf85                	j	4ea <printint+0x1a>

000000000000057c <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 57c:	715d                	add	sp,sp,-80
 57e:	e486                	sd	ra,72(sp)
 580:	e0a2                	sd	s0,64(sp)
 582:	fc26                	sd	s1,56(sp)
 584:	f84a                	sd	s2,48(sp)
 586:	f44e                	sd	s3,40(sp)
 588:	f052                	sd	s4,32(sp)
 58a:	ec56                	sd	s5,24(sp)
 58c:	e85a                	sd	s6,16(sp)
 58e:	e45e                	sd	s7,8(sp)
 590:	e062                	sd	s8,0(sp)
 592:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 594:	0005c903          	lbu	s2,0(a1)
 598:	18090c63          	beqz	s2,730 <vprintf+0x1b4>
 59c:	8aaa                	mv	s5,a0
 59e:	8bb2                	mv	s7,a2
 5a0:	00158493          	add	s1,a1,1
  state = 0;
 5a4:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5a6:	02500a13          	li	s4,37
 5aa:	4b55                	li	s6,21
 5ac:	a839                	j	5ca <vprintf+0x4e>
        putc(fd, c);
 5ae:	85ca                	mv	a1,s2
 5b0:	8556                	mv	a0,s5
 5b2:	00000097          	auipc	ra,0x0
 5b6:	efc080e7          	jalr	-260(ra) # 4ae <putc>
 5ba:	a019                	j	5c0 <vprintf+0x44>
    } else if(state == '%'){
 5bc:	01498d63          	beq	s3,s4,5d6 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 5c0:	0485                	add	s1,s1,1
 5c2:	fff4c903          	lbu	s2,-1(s1)
 5c6:	16090563          	beqz	s2,730 <vprintf+0x1b4>
    if(state == 0){
 5ca:	fe0999e3          	bnez	s3,5bc <vprintf+0x40>
      if(c == '%'){
 5ce:	ff4910e3          	bne	s2,s4,5ae <vprintf+0x32>
        state = '%';
 5d2:	89d2                	mv	s3,s4
 5d4:	b7f5                	j	5c0 <vprintf+0x44>
      if(c == 'd'){
 5d6:	13490263          	beq	s2,s4,6fa <vprintf+0x17e>
 5da:	f9d9079b          	addw	a5,s2,-99
 5de:	0ff7f793          	zext.b	a5,a5
 5e2:	12fb6563          	bltu	s6,a5,70c <vprintf+0x190>
 5e6:	f9d9079b          	addw	a5,s2,-99
 5ea:	0ff7f713          	zext.b	a4,a5
 5ee:	10eb6f63          	bltu	s6,a4,70c <vprintf+0x190>
 5f2:	00271793          	sll	a5,a4,0x2
 5f6:	00000717          	auipc	a4,0x0
 5fa:	75270713          	add	a4,a4,1874 # d48 <ulthread_context_switch+0x13c>
 5fe:	97ba                	add	a5,a5,a4
 600:	439c                	lw	a5,0(a5)
 602:	97ba                	add	a5,a5,a4
 604:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 606:	008b8913          	add	s2,s7,8
 60a:	4685                	li	a3,1
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	8556                	mv	a0,s5
 614:	00000097          	auipc	ra,0x0
 618:	ebc080e7          	jalr	-324(ra) # 4d0 <printint>
 61c:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 61e:	4981                	li	s3,0
 620:	b745                	j	5c0 <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 622:	008b8913          	add	s2,s7,8
 626:	4681                	li	a3,0
 628:	4629                	li	a2,10
 62a:	000ba583          	lw	a1,0(s7)
 62e:	8556                	mv	a0,s5
 630:	00000097          	auipc	ra,0x0
 634:	ea0080e7          	jalr	-352(ra) # 4d0 <printint>
 638:	8bca                	mv	s7,s2
      state = 0;
 63a:	4981                	li	s3,0
 63c:	b751                	j	5c0 <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 63e:	008b8913          	add	s2,s7,8
 642:	4681                	li	a3,0
 644:	4641                	li	a2,16
 646:	000ba583          	lw	a1,0(s7)
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	e84080e7          	jalr	-380(ra) # 4d0 <printint>
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
 658:	b7a5                	j	5c0 <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 65a:	008b8c13          	add	s8,s7,8
 65e:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 662:	03000593          	li	a1,48
 666:	8556                	mv	a0,s5
 668:	00000097          	auipc	ra,0x0
 66c:	e46080e7          	jalr	-442(ra) # 4ae <putc>
  putc(fd, 'x');
 670:	07800593          	li	a1,120
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	e38080e7          	jalr	-456(ra) # 4ae <putc>
 67e:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 680:	00000b97          	auipc	s7,0x0
 684:	720b8b93          	add	s7,s7,1824 # da0 <digits>
 688:	03c9d793          	srl	a5,s3,0x3c
 68c:	97de                	add	a5,a5,s7
 68e:	0007c583          	lbu	a1,0(a5)
 692:	8556                	mv	a0,s5
 694:	00000097          	auipc	ra,0x0
 698:	e1a080e7          	jalr	-486(ra) # 4ae <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 69c:	0992                	sll	s3,s3,0x4
 69e:	397d                	addw	s2,s2,-1
 6a0:	fe0914e3          	bnez	s2,688 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 6a4:	8be2                	mv	s7,s8
      state = 0;
 6a6:	4981                	li	s3,0
 6a8:	bf21                	j	5c0 <vprintf+0x44>
        s = va_arg(ap, char*);
 6aa:	008b8993          	add	s3,s7,8
 6ae:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 6b2:	02090163          	beqz	s2,6d4 <vprintf+0x158>
        while(*s != 0){
 6b6:	00094583          	lbu	a1,0(s2)
 6ba:	c9a5                	beqz	a1,72a <vprintf+0x1ae>
          putc(fd, *s);
 6bc:	8556                	mv	a0,s5
 6be:	00000097          	auipc	ra,0x0
 6c2:	df0080e7          	jalr	-528(ra) # 4ae <putc>
          s++;
 6c6:	0905                	add	s2,s2,1
        while(*s != 0){
 6c8:	00094583          	lbu	a1,0(s2)
 6cc:	f9e5                	bnez	a1,6bc <vprintf+0x140>
        s = va_arg(ap, char*);
 6ce:	8bce                	mv	s7,s3
      state = 0;
 6d0:	4981                	li	s3,0
 6d2:	b5fd                	j	5c0 <vprintf+0x44>
          s = "(null)";
 6d4:	00000917          	auipc	s2,0x0
 6d8:	66c90913          	add	s2,s2,1644 # d40 <ulthread_context_switch+0x134>
        while(*s != 0){
 6dc:	02800593          	li	a1,40
 6e0:	bff1                	j	6bc <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 6e2:	008b8913          	add	s2,s7,8
 6e6:	000bc583          	lbu	a1,0(s7)
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	dc2080e7          	jalr	-574(ra) # 4ae <putc>
 6f4:	8bca                	mv	s7,s2
      state = 0;
 6f6:	4981                	li	s3,0
 6f8:	b5e1                	j	5c0 <vprintf+0x44>
        putc(fd, c);
 6fa:	02500593          	li	a1,37
 6fe:	8556                	mv	a0,s5
 700:	00000097          	auipc	ra,0x0
 704:	dae080e7          	jalr	-594(ra) # 4ae <putc>
      state = 0;
 708:	4981                	li	s3,0
 70a:	bd5d                	j	5c0 <vprintf+0x44>
        putc(fd, '%');
 70c:	02500593          	li	a1,37
 710:	8556                	mv	a0,s5
 712:	00000097          	auipc	ra,0x0
 716:	d9c080e7          	jalr	-612(ra) # 4ae <putc>
        putc(fd, c);
 71a:	85ca                	mv	a1,s2
 71c:	8556                	mv	a0,s5
 71e:	00000097          	auipc	ra,0x0
 722:	d90080e7          	jalr	-624(ra) # 4ae <putc>
      state = 0;
 726:	4981                	li	s3,0
 728:	bd61                	j	5c0 <vprintf+0x44>
        s = va_arg(ap, char*);
 72a:	8bce                	mv	s7,s3
      state = 0;
 72c:	4981                	li	s3,0
 72e:	bd49                	j	5c0 <vprintf+0x44>
    }
  }
}
 730:	60a6                	ld	ra,72(sp)
 732:	6406                	ld	s0,64(sp)
 734:	74e2                	ld	s1,56(sp)
 736:	7942                	ld	s2,48(sp)
 738:	79a2                	ld	s3,40(sp)
 73a:	7a02                	ld	s4,32(sp)
 73c:	6ae2                	ld	s5,24(sp)
 73e:	6b42                	ld	s6,16(sp)
 740:	6ba2                	ld	s7,8(sp)
 742:	6c02                	ld	s8,0(sp)
 744:	6161                	add	sp,sp,80
 746:	8082                	ret

0000000000000748 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 748:	715d                	add	sp,sp,-80
 74a:	ec06                	sd	ra,24(sp)
 74c:	e822                	sd	s0,16(sp)
 74e:	1000                	add	s0,sp,32
 750:	e010                	sd	a2,0(s0)
 752:	e414                	sd	a3,8(s0)
 754:	e818                	sd	a4,16(s0)
 756:	ec1c                	sd	a5,24(s0)
 758:	03043023          	sd	a6,32(s0)
 75c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 760:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 764:	8622                	mv	a2,s0
 766:	00000097          	auipc	ra,0x0
 76a:	e16080e7          	jalr	-490(ra) # 57c <vprintf>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6161                	add	sp,sp,80
 774:	8082                	ret

0000000000000776 <printf>:

void
printf(const char *fmt, ...)
{
 776:	711d                	add	sp,sp,-96
 778:	ec06                	sd	ra,24(sp)
 77a:	e822                	sd	s0,16(sp)
 77c:	1000                	add	s0,sp,32
 77e:	e40c                	sd	a1,8(s0)
 780:	e810                	sd	a2,16(s0)
 782:	ec14                	sd	a3,24(s0)
 784:	f018                	sd	a4,32(s0)
 786:	f41c                	sd	a5,40(s0)
 788:	03043823          	sd	a6,48(s0)
 78c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 790:	00840613          	add	a2,s0,8
 794:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 798:	85aa                	mv	a1,a0
 79a:	4505                	li	a0,1
 79c:	00000097          	auipc	ra,0x0
 7a0:	de0080e7          	jalr	-544(ra) # 57c <vprintf>
}
 7a4:	60e2                	ld	ra,24(sp)
 7a6:	6442                	ld	s0,16(sp)
 7a8:	6125                	add	sp,sp,96
 7aa:	8082                	ret

00000000000007ac <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7ac:	1141                	add	sp,sp,-16
 7ae:	e422                	sd	s0,8(sp)
 7b0:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7b2:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b6:	00001797          	auipc	a5,0x1
 7ba:	85a7b783          	ld	a5,-1958(a5) # 1010 <freep>
 7be:	a02d                	j	7e8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7c0:	4618                	lw	a4,8(a2)
 7c2:	9f2d                	addw	a4,a4,a1
 7c4:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7c8:	6398                	ld	a4,0(a5)
 7ca:	6310                	ld	a2,0(a4)
 7cc:	a83d                	j	80a <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7ce:	ff852703          	lw	a4,-8(a0)
 7d2:	9f31                	addw	a4,a4,a2
 7d4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7d6:	ff053683          	ld	a3,-16(a0)
 7da:	a091                	j	81e <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7dc:	6398                	ld	a4,0(a5)
 7de:	00e7e463          	bltu	a5,a4,7e6 <free+0x3a>
 7e2:	00e6ea63          	bltu	a3,a4,7f6 <free+0x4a>
{
 7e6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e8:	fed7fae3          	bgeu	a5,a3,7dc <free+0x30>
 7ec:	6398                	ld	a4,0(a5)
 7ee:	00e6e463          	bltu	a3,a4,7f6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7f2:	fee7eae3          	bltu	a5,a4,7e6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7f6:	ff852583          	lw	a1,-8(a0)
 7fa:	6390                	ld	a2,0(a5)
 7fc:	02059813          	sll	a6,a1,0x20
 800:	01c85713          	srl	a4,a6,0x1c
 804:	9736                	add	a4,a4,a3
 806:	fae60de3          	beq	a2,a4,7c0 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 80a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 80e:	4790                	lw	a2,8(a5)
 810:	02061593          	sll	a1,a2,0x20
 814:	01c5d713          	srl	a4,a1,0x1c
 818:	973e                	add	a4,a4,a5
 81a:	fae68ae3          	beq	a3,a4,7ce <free+0x22>
    p->s.ptr = bp->s.ptr;
 81e:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 820:	00000717          	auipc	a4,0x0
 824:	7ef73823          	sd	a5,2032(a4) # 1010 <freep>
}
 828:	6422                	ld	s0,8(sp)
 82a:	0141                	add	sp,sp,16
 82c:	8082                	ret

000000000000082e <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 82e:	7139                	add	sp,sp,-64
 830:	fc06                	sd	ra,56(sp)
 832:	f822                	sd	s0,48(sp)
 834:	f426                	sd	s1,40(sp)
 836:	f04a                	sd	s2,32(sp)
 838:	ec4e                	sd	s3,24(sp)
 83a:	e852                	sd	s4,16(sp)
 83c:	e456                	sd	s5,8(sp)
 83e:	e05a                	sd	s6,0(sp)
 840:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 842:	02051493          	sll	s1,a0,0x20
 846:	9081                	srl	s1,s1,0x20
 848:	04bd                	add	s1,s1,15
 84a:	8091                	srl	s1,s1,0x4
 84c:	0014899b          	addw	s3,s1,1
 850:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 852:	00000517          	auipc	a0,0x0
 856:	7be53503          	ld	a0,1982(a0) # 1010 <freep>
 85a:	c515                	beqz	a0,886 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 85c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 85e:	4798                	lw	a4,8(a5)
 860:	02977f63          	bgeu	a4,s1,89e <malloc+0x70>
  if(nu < 4096)
 864:	8a4e                	mv	s4,s3
 866:	0009871b          	sext.w	a4,s3
 86a:	6685                	lui	a3,0x1
 86c:	00d77363          	bgeu	a4,a3,872 <malloc+0x44>
 870:	6a05                	lui	s4,0x1
 872:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 876:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 87a:	00000917          	auipc	s2,0x0
 87e:	79690913          	add	s2,s2,1942 # 1010 <freep>
  if(p == (char*)-1)
 882:	5afd                	li	s5,-1
 884:	a895                	j	8f8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 886:	00064797          	auipc	a5,0x64
 88a:	7aa78793          	add	a5,a5,1962 # 65030 <base>
 88e:	00000717          	auipc	a4,0x0
 892:	78f73123          	sd	a5,1922(a4) # 1010 <freep>
 896:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 898:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 89c:	b7e1                	j	864 <malloc+0x36>
      if(p->s.size == nunits)
 89e:	02e48c63          	beq	s1,a4,8d6 <malloc+0xa8>
        p->s.size -= nunits;
 8a2:	4137073b          	subw	a4,a4,s3
 8a6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8a8:	02071693          	sll	a3,a4,0x20
 8ac:	01c6d713          	srl	a4,a3,0x1c
 8b0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8b6:	00000717          	auipc	a4,0x0
 8ba:	74a73d23          	sd	a0,1882(a4) # 1010 <freep>
      return (void*)(p + 1);
 8be:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8c2:	70e2                	ld	ra,56(sp)
 8c4:	7442                	ld	s0,48(sp)
 8c6:	74a2                	ld	s1,40(sp)
 8c8:	7902                	ld	s2,32(sp)
 8ca:	69e2                	ld	s3,24(sp)
 8cc:	6a42                	ld	s4,16(sp)
 8ce:	6aa2                	ld	s5,8(sp)
 8d0:	6b02                	ld	s6,0(sp)
 8d2:	6121                	add	sp,sp,64
 8d4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8d6:	6398                	ld	a4,0(a5)
 8d8:	e118                	sd	a4,0(a0)
 8da:	bff1                	j	8b6 <malloc+0x88>
  hp->s.size = nu;
 8dc:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8e0:	0541                	add	a0,a0,16
 8e2:	00000097          	auipc	ra,0x0
 8e6:	eca080e7          	jalr	-310(ra) # 7ac <free>
  return freep;
 8ea:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ee:	d971                	beqz	a0,8c2 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f2:	4798                	lw	a4,8(a5)
 8f4:	fa9775e3          	bgeu	a4,s1,89e <malloc+0x70>
    if(p == freep)
 8f8:	00093703          	ld	a4,0(s2)
 8fc:	853e                	mv	a0,a5
 8fe:	fef719e3          	bne	a4,a5,8f0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 902:	8552                	mv	a0,s4
 904:	00000097          	auipc	ra,0x0
 908:	b8a080e7          	jalr	-1142(ra) # 48e <sbrk>
  if(p == (char*)-1)
 90c:	fd5518e3          	bne	a0,s5,8dc <malloc+0xae>
        return 0;
 910:	4501                	li	a0,0
 912:	bf45                	j	8c2 <malloc+0x94>

0000000000000914 <get_current_tid>:
enum ulthread_scheduling_algorithm scheduling_algorithm;

int prev_tid = 0;

/* Get thread ID */
int get_current_tid(void) {
 914:	1141                	add	sp,sp,-16
 916:	e422                	sd	s0,8(sp)
 918:	0800                	add	s0,sp,16
    return current_thread->tid;
}
 91a:	00000797          	auipc	a5,0x0
 91e:	7067b783          	ld	a5,1798(a5) # 1020 <current_thread>
 922:	4388                	lw	a0,0(a5)
 924:	6422                	ld	s0,8(sp)
 926:	0141                	add	sp,sp,16
 928:	8082                	ret

000000000000092a <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo) {
 92a:	1141                	add	sp,sp,-16
 92c:	e422                	sd	s0,8(sp)
 92e:	0800                	add	s0,sp,16

    struct ulthread *t;
    int i = 0;
 930:	4681                	li	a3,0
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 1 to MAXULTHREADS
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 932:	00064797          	auipc	a5,0x64
 936:	70e78793          	add	a5,a5,1806 # 65040 <ulthread>
 93a:	00069617          	auipc	a2,0x69
 93e:	52660613          	add	a2,a2,1318 # 69e60 <ulthread+0x4e20>
        t->state = FREE;
 942:	0007a423          	sw	zero,8(a5)
        t->tid = i++;
 946:	c394                	sw	a3,0(a5)
 948:	2685                	addw	a3,a3,1 # 1001 <scheduler_thread+0x1>
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 94a:	0c878793          	add	a5,a5,200
 94e:	fec79ae3          	bne	a5,a2,942 <ulthread_init+0x18>
    }
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    scheduler_thread->state = RUNNABLE;
 952:	00000797          	auipc	a5,0x0
 956:	6ae78793          	add	a5,a5,1710 # 1000 <scheduler_thread>
 95a:	6398                	ld	a4,0(a5)
 95c:	4685                	li	a3,1
 95e:	c714                	sw	a3,8(a4)
    scheduler_thread->tid = 0;
 960:	00072023          	sw	zero,0(a4)
    // Set the current thread to the scheduler thread
    current_thread = scheduler_thread;
 964:	639c                	ld	a5,0(a5)
 966:	00000717          	auipc	a4,0x0
 96a:	6af73d23          	sd	a5,1722(a4) # 1020 <current_thread>

    scheduling_algorithm = schedalgo;
 96e:	00000797          	auipc	a5,0x0
 972:	6aa7a723          	sw	a0,1710(a5) # 101c <scheduling_algorithm>
}
 976:	6422                	ld	s0,8(sp)
 978:	0141                	add	sp,sp,16
 97a:	8082                	ret

000000000000097c <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
 97c:	7179                	add	sp,sp,-48
 97e:	f406                	sd	ra,40(sp)
 980:	f022                	sd	s0,32(sp)
 982:	ec26                	sd	s1,24(sp)
 984:	e84a                	sd	s2,16(sp)
 986:	e44e                	sd	s3,8(sp)
 988:	e052                	sd	s4,0(sp)
 98a:	1800                	add	s0,sp,48
 98c:	892a                	mv	s2,a0
 98e:	89ae                	mv	s3,a1
 990:	8a36                	mv	s4,a3

    struct ulthread *t;

    // Find a free thread slot and initialize it
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 992:	00064497          	auipc	s1,0x64
 996:	77648493          	add	s1,s1,1910 # 65108 <ulthread+0xc8>
 99a:	00069717          	auipc	a4,0x69
 99e:	4c670713          	add	a4,a4,1222 # 69e60 <ulthread+0x4e20>
        if(t->state == FREE){
 9a2:	449c                	lw	a5,8(s1)
 9a4:	c799                	beqz	a5,9b2 <ulthread_create+0x36>
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 9a6:	0c848493          	add	s1,s1,200
 9aa:	fee49ce3          	bne	s1,a4,9a2 <ulthread_create+0x26>
            t->priority = priority;
            break;
        }
    }
    if(t == &ulthread[MAXULTHREADS]){
        return false;
 9ae:	4501                	li	a0,0
 9b0:	a8a1                	j	a08 <ulthread_create+0x8c>
            t->state = RUNNABLE;
 9b2:	4785                	li	a5,1
 9b4:	c49c                	sw	a5,8(s1)
            t->context.ra = start;
 9b6:	0324b423          	sd	s2,40(s1)
            t->context.sp = stack;
 9ba:	0334b823          	sd	s3,48(s1)
            t->context.s0 = args[0];
 9be:	621c                	ld	a5,0(a2)
 9c0:	fc9c                	sd	a5,56(s1)
            t->context.s1 = args[1];
 9c2:	661c                	ld	a5,8(a2)
 9c4:	e0bc                	sd	a5,64(s1)
            t->context.s2 = args[2];
 9c6:	6a1c                	ld	a5,16(a2)
 9c8:	e4bc                	sd	a5,72(s1)
            t->context.s3 = args[3];
 9ca:	6e1c                	ld	a5,24(a2)
 9cc:	e8bc                	sd	a5,80(s1)
            t->context.s4 = args[4];
 9ce:	721c                	ld	a5,32(a2)
 9d0:	ecbc                	sd	a5,88(s1)
            t->context.s5 = args[5];
 9d2:	761c                	ld	a5,40(a2)
 9d4:	f0bc                	sd	a5,96(s1)
            t->ctime = ctime();
 9d6:	00000097          	auipc	ra,0x0
 9da:	ad0080e7          	jalr	-1328(ra) # 4a6 <ctime>
 9de:	f088                	sd	a0,32(s1)
            t->priority = priority;
 9e0:	0144a223          	sw	s4,4(s1)
    if(t == &ulthread[MAXULTHREADS]){
 9e4:	00069797          	auipc	a5,0x69
 9e8:	47c78793          	add	a5,a5,1148 # 69e60 <ulthread+0x4e20>
 9ec:	02f48663          	beq	s1,a5,a18 <ulthread_create+0x9c>
    }

    // current_thread = t;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 9f0:	86ce                	mv	a3,s3
 9f2:	864a                	mv	a2,s2
 9f4:	408c                	lw	a1,0(s1)
 9f6:	00000517          	auipc	a0,0x0
 9fa:	3c250513          	add	a0,a0,962 # db8 <digits+0x18>
 9fe:	00000097          	auipc	ra,0x0
 a02:	d78080e7          	jalr	-648(ra) # 776 <printf>

    return true;
 a06:	4505                	li	a0,1
}
 a08:	70a2                	ld	ra,40(sp)
 a0a:	7402                	ld	s0,32(sp)
 a0c:	64e2                	ld	s1,24(sp)
 a0e:	6942                	ld	s2,16(sp)
 a10:	69a2                	ld	s3,8(sp)
 a12:	6a02                	ld	s4,0(sp)
 a14:	6145                	add	sp,sp,48
 a16:	8082                	ret
        return false;
 a18:	4501                	li	a0,0
 a1a:	b7fd                	j	a08 <ulthread_create+0x8c>

0000000000000a1c <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void) {
 a1c:	715d                	add	sp,sp,-80
 a1e:	e486                	sd	ra,72(sp)
 a20:	e0a2                	sd	s0,64(sp)
 a22:	fc26                	sd	s1,56(sp)
 a24:	f84a                	sd	s2,48(sp)
 a26:	f44e                	sd	s3,40(sp)
 a28:	f052                	sd	s4,32(sp)
 a2a:	ec56                	sd	s5,24(sp)
 a2c:	e85a                	sd	s6,16(sp)
 a2e:	e45e                	sd	s7,8(sp)
 a30:	e062                	sd	s8,0(sp)
 a32:	0880                	add	s0,sp,80

    current_thread = scheduler_thread;
 a34:	00000797          	auipc	a5,0x0
 a38:	5cc7b783          	ld	a5,1484(a5) # 1000 <scheduler_thread>
 a3c:	00000717          	auipc	a4,0x0
 a40:	5ef73223          	sd	a5,1508(a4) # 1020 <current_thread>

        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){

            // printf("t->tid: %d\n", t->tid);
            
            if(scheduling_algorithm == 0){
 a44:	00000917          	auipc	s2,0x0
 a48:	5d890913          	add	s2,s2,1496 # 101c <scheduling_algorithm>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a4c:	00069497          	auipc	s1,0x69
 a50:	41448493          	add	s1,s1,1044 # 69e60 <ulthread+0x4e20>
                }
            }
        
            if(t != 0){
                
                current_thread = t;
 a54:	00000a97          	auipc	s5,0x0
 a58:	5cca8a93          	add	s5,s5,1484 # 1020 <current_thread>

                flag = 1;

                /* Add this statement to denote which thread-id is being scheduled next */
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a5c:	00000a17          	auipc	s4,0x0
 a60:	384a0a13          	add	s4,s4,900 # de0 <digits+0x40>

                // Switch between thread contexts from the scheduler thread to the new thread
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 a64:	00000997          	auipc	s3,0x0
 a68:	59c98993          	add	s3,s3,1436 # 1000 <scheduler_thread>
void ulthread_schedule(void) {
 a6c:	4701                	li	a4,0
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a6e:	00064b17          	auipc	s6,0x64
 a72:	69ab0b13          	add	s6,s6,1690 # 65108 <ulthread+0xc8>
                flag = 1;
 a76:	4b85                	li	s7,1
            else if(scheduling_algorithm == 2){
 a78:	4c09                	li	s8,2
 a7a:	a83d                	j	ab8 <ulthread_schedule+0x9c>
            else if(scheduling_algorithm == 1){
 a7c:	07778163          	beq	a5,s7,ade <ulthread_schedule+0xc2>
            else if(scheduling_algorithm == 2){
 a80:	09878a63          	beq	a5,s8,b14 <ulthread_schedule+0xf8>
            if(t != 0){
 a84:	040b0163          	beqz	s6,ac6 <ulthread_schedule+0xaa>
                current_thread = t;
 a88:	016ab023          	sd	s6,0(s5)
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 a8c:	000b2583          	lw	a1,0(s6)
 a90:	8552                	mv	a0,s4
 a92:	00000097          	auipc	ra,0x0
 a96:	ce4080e7          	jalr	-796(ra) # 776 <printf>
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 a9a:	0009b503          	ld	a0,0(s3)
 a9e:	028b0593          	add	a1,s6,40
 aa2:	02850513          	add	a0,a0,40
 aa6:	00000097          	auipc	ra,0x0
 aaa:	166080e7          	jalr	358(ra) # c0c <ulthread_context_switch>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 aae:	00064b17          	auipc	s6,0x64
 ab2:	722b0b13          	add	s6,s6,1826 # 651d0 <ulthread+0x190>
                flag = 1;
 ab6:	875e                	mv	a4,s7
            if(scheduling_algorithm == 0){
 ab8:	00092783          	lw	a5,0(s2)
 abc:	f3e1                	bnez	a5,a7c <ulthread_schedule+0x60>
                if(t->state != RUNNABLE){
 abe:	008b2783          	lw	a5,8(s6)
 ac2:	fd7783e3          	beq	a5,s7,a88 <ulthread_schedule+0x6c>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 ac6:	0c8b0b13          	add	s6,s6,200
 aca:	fe9b67e3          	bltu	s6,s1,ab8 <ulthread_schedule+0x9c>

                t = &ulthread[1];
            }
            
        }
        if(flag == 0){
 ace:	c749                	beqz	a4,b58 <ulthread_schedule+0x13c>
            break;
        }
        else{
            flag = 0;
            struct ulthread *t1 = 0;
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 ad0:	00064797          	auipc	a5,0x64
 ad4:	63878793          	add	a5,a5,1592 # 65108 <ulthread+0xc8>
                if(t1->state == YIELD){
 ad8:	4689                	li	a3,2
                    t1->state = RUNNABLE;
 ada:	4605                	li	a2,1
 adc:	a88d                	j	b4e <ulthread_schedule+0x132>
                if(t->state != RUNNABLE){
 ade:	008b2783          	lw	a5,8(s6)
 ae2:	ff7792e3          	bne	a5,s7,ac6 <ulthread_schedule+0xaa>
 ae6:	85da                	mv	a1,s6
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 ae8:	00064797          	auipc	a5,0x64
 aec:	62078793          	add	a5,a5,1568 # 65108 <ulthread+0xc8>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 af0:	4685                	li	a3,1
 af2:	a029                	j	afc <ulthread_schedule+0xe0>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 af4:	0c878793          	add	a5,a5,200
 af8:	00978b63          	beq	a5,s1,b0e <ulthread_schedule+0xf2>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 afc:	4798                	lw	a4,8(a5)
 afe:	fed71be3          	bne	a4,a3,af4 <ulthread_schedule+0xd8>
 b02:	43d0                	lw	a2,4(a5)
 b04:	41d8                	lw	a4,4(a1)
 b06:	fec757e3          	bge	a4,a2,af4 <ulthread_schedule+0xd8>
 b0a:	85be                	mv	a1,a5
 b0c:	b7e5                	j	af4 <ulthread_schedule+0xd8>
                if(max_priority_thread != 0){
 b0e:	ddad                	beqz	a1,a88 <ulthread_schedule+0x6c>
 b10:	8b2e                	mv	s6,a1
 b12:	bf9d                	j	a88 <ulthread_schedule+0x6c>
                if(t->state != RUNNABLE){
 b14:	008b2683          	lw	a3,8(s6)
 b18:	4785                	li	a5,1
 b1a:	faf696e3          	bne	a3,a5,ac6 <ulthread_schedule+0xaa>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 b1e:	00064797          	auipc	a5,0x64
 b22:	5ea78793          	add	a5,a5,1514 # 65108 <ulthread+0xc8>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 b26:	4605                	li	a2,1
 b28:	a029                	j	b32 <ulthread_schedule+0x116>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 b2a:	0c878793          	add	a5,a5,200
 b2e:	f4978de3          	beq	a5,s1,a88 <ulthread_schedule+0x6c>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 b32:	7394                	ld	a3,32(a5)
 b34:	020b3703          	ld	a4,32(s6)
 b38:	fee6f9e3          	bgeu	a3,a4,b2a <ulthread_schedule+0x10e>
 b3c:	4798                	lw	a4,8(a5)
 b3e:	fec716e3          	bne	a4,a2,b2a <ulthread_schedule+0x10e>
 b42:	8b3e                	mv	s6,a5
 b44:	b7dd                	j	b2a <ulthread_schedule+0x10e>
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 b46:	0c878793          	add	a5,a5,200
 b4a:	f29781e3          	beq	a5,s1,a6c <ulthread_schedule+0x50>
                if(t1->state == YIELD){
 b4e:	4798                	lw	a4,8(a5)
 b50:	fed71be3          	bne	a4,a3,b46 <ulthread_schedule+0x12a>
                    t1->state = RUNNABLE;
 b54:	c790                	sw	a2,8(a5)
 b56:	bfc5                	j	b46 <ulthread_schedule+0x12a>
                }
            }
        }
    }
}
 b58:	60a6                	ld	ra,72(sp)
 b5a:	6406                	ld	s0,64(sp)
 b5c:	74e2                	ld	s1,56(sp)
 b5e:	7942                	ld	s2,48(sp)
 b60:	79a2                	ld	s3,40(sp)
 b62:	7a02                	ld	s4,32(sp)
 b64:	6ae2                	ld	s5,24(sp)
 b66:	6b42                	ld	s6,16(sp)
 b68:	6ba2                	ld	s7,8(sp)
 b6a:	6c02                	ld	s8,0(sp)
 b6c:	6161                	add	sp,sp,80
 b6e:	8082                	ret

0000000000000b70 <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {
 b70:	1101                	add	sp,sp,-32
 b72:	ec06                	sd	ra,24(sp)
 b74:	e822                	sd	s0,16(sp)
 b76:	e426                	sd	s1,8(sp)
 b78:	1000                	add	s0,sp,32

    current_thread->state = YIELD;
 b7a:	00000497          	auipc	s1,0x0
 b7e:	4a648493          	add	s1,s1,1190 # 1020 <current_thread>
 b82:	609c                	ld	a5,0(s1)
 b84:	4709                	li	a4,2
 b86:	c798                	sw	a4,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid());
 b88:	438c                	lw	a1,0(a5)
 b8a:	00000517          	auipc	a0,0x0
 b8e:	27650513          	add	a0,a0,630 # e00 <digits+0x60>
 b92:	00000097          	auipc	ra,0x0
 b96:	be4080e7          	jalr	-1052(ra) # 776 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 b9a:	6088                	ld	a0,0(s1)
 b9c:	00000597          	auipc	a1,0x0
 ba0:	4645b583          	ld	a1,1124(a1) # 1000 <scheduler_thread>
 ba4:	02858593          	add	a1,a1,40
 ba8:	02850513          	add	a0,a0,40
 bac:	00000097          	auipc	ra,0x0
 bb0:	060080e7          	jalr	96(ra) # c0c <ulthread_context_switch>
    
}
 bb4:	60e2                	ld	ra,24(sp)
 bb6:	6442                	ld	s0,16(sp)
 bb8:	64a2                	ld	s1,8(sp)
 bba:	6105                	add	sp,sp,32
 bbc:	8082                	ret

0000000000000bbe <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void) {
 bbe:	1101                	add	sp,sp,-32
 bc0:	ec06                	sd	ra,24(sp)
 bc2:	e822                	sd	s0,16(sp)
 bc4:	e426                	sd	s1,8(sp)
 bc6:	1000                	add	s0,sp,32

    // find the current running thread and mark it as FREE
    current_thread->state = FREE;
 bc8:	00000497          	auipc	s1,0x0
 bcc:	45848493          	add	s1,s1,1112 # 1020 <current_thread>
 bd0:	609c                	ld	a5,0(s1)
 bd2:	0007a423          	sw	zero,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 bd6:	438c                	lw	a1,0(a5)
 bd8:	00000517          	auipc	a0,0x0
 bdc:	24050513          	add	a0,a0,576 # e18 <digits+0x78>
 be0:	00000097          	auipc	ra,0x0
 be4:	b96080e7          	jalr	-1130(ra) # 776 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 be8:	6088                	ld	a0,0(s1)
 bea:	00000597          	auipc	a1,0x0
 bee:	4165b583          	ld	a1,1046(a1) # 1000 <scheduler_thread>
 bf2:	02858593          	add	a1,a1,40
 bf6:	02850513          	add	a0,a0,40
 bfa:	00000097          	auipc	ra,0x0
 bfe:	012080e7          	jalr	18(ra) # c0c <ulthread_context_switch>
}
 c02:	60e2                	ld	ra,24(sp)
 c04:	6442                	ld	s0,16(sp)
 c06:	64a2                	ld	s1,8(sp)
 c08:	6105                	add	sp,sp,32
 c0a:	8082                	ret

0000000000000c0c <ulthread_context_switch>:
 c0c:	00153023          	sd	ra,0(a0)
 c10:	00253423          	sd	sp,8(a0)
 c14:	e900                	sd	s0,16(a0)
 c16:	ed04                	sd	s1,24(a0)
 c18:	03253023          	sd	s2,32(a0)
 c1c:	03353423          	sd	s3,40(a0)
 c20:	03453823          	sd	s4,48(a0)
 c24:	03553c23          	sd	s5,56(a0)
 c28:	05653023          	sd	s6,64(a0)
 c2c:	05753423          	sd	s7,72(a0)
 c30:	05853823          	sd	s8,80(a0)
 c34:	05953c23          	sd	s9,88(a0)
 c38:	07a53023          	sd	s10,96(a0)
 c3c:	07b53423          	sd	s11,104(a0)
 c40:	0005b083          	ld	ra,0(a1)
 c44:	0085b103          	ld	sp,8(a1)
 c48:	6980                	ld	s0,16(a1)
 c4a:	6d84                	ld	s1,24(a1)
 c4c:	0205b903          	ld	s2,32(a1)
 c50:	0285b983          	ld	s3,40(a1)
 c54:	0305ba03          	ld	s4,48(a1)
 c58:	0385ba83          	ld	s5,56(a1)
 c5c:	0405bb03          	ld	s6,64(a1)
 c60:	0485bb83          	ld	s7,72(a1)
 c64:	0505bc03          	ld	s8,80(a1)
 c68:	0585bc83          	ld	s9,88(a1)
 c6c:	0605bd03          	ld	s10,96(a1)
 c70:	0685bd83          	ld	s11,104(a1)
 c74:	00040513          	mv	a0,s0
 c78:	00048593          	mv	a1,s1
 c7c:	00090613          	mv	a2,s2
 c80:	00098693          	mv	a3,s3
 c84:	000a0713          	mv	a4,s4
 c88:	000a8793          	mv	a5,s5
 c8c:	8082                	ret
