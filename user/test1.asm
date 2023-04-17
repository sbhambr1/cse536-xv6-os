
user/_test1:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(void) {
   0:	1141                	add	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	add	s0,sp,16
   8:	3e800793          	li	a5,1000
    /* Start the thread here. */
    for (int i = 0; i < 1000; i++);
   c:	37fd                	addw	a5,a5,-1
   e:	fffd                	bnez	a5,c <ul_start_func+0xc>

    printf("[.] started the thread function (tid = %d) \n", get_current_tid());
  10:	00001097          	auipc	ra,0x1
  14:	83e080e7          	jalr	-1986(ra) # 84e <get_current_tid>
  18:	85aa                	mv	a1,a0
  1a:	00001517          	auipc	a0,0x1
  1e:	bb650513          	add	a0,a0,-1098 # bd0 <ulthread_context_switch+0x8a>
  22:	00000097          	auipc	ra,0x0
  26:	68e080e7          	jalr	1678(ra) # 6b0 <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  2a:	00001097          	auipc	ra,0x1
  2e:	ace080e7          	jalr	-1330(ra) # af8 <ulthread_destroy>
}
  32:	60a2                	ld	ra,8(sp)
  34:	6402                	ld	s0,0(sp)
  36:	0141                	add	sp,sp,16
  38:	8082                	ret

000000000000003a <main>:

int
main(int argc, char *argv[])
{
  3a:	7139                	add	sp,sp,-64
  3c:	fc06                	sd	ra,56(sp)
  3e:	f822                	sd	s0,48(sp)
  40:	0080                	add	s0,sp,64
    /* Clear the stack region */
    memset(&stacks, 0, sizeof(stacks));
  42:	00064637          	lui	a2,0x64
  46:	4581                	li	a1,0
  48:	00001517          	auipc	a0,0x1
  4c:	fe850513          	add	a0,a0,-24 # 1030 <stacks>
  50:	00000097          	auipc	ra,0x0
  54:	0f6080e7          	jalr	246(ra) # 146 <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  58:	4501                	li	a0,0
  5a:	00001097          	auipc	ra,0x1
  5e:	80a080e7          	jalr	-2038(ra) # 864 <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {0,0,0,0,0,0};    
  62:	fc043023          	sd	zero,-64(s0)
  66:	fc043423          	sd	zero,-56(s0)
  6a:	fc043823          	sd	zero,-48(s0)
  6e:	fc043c23          	sd	zero,-40(s0)
  72:	fe043023          	sd	zero,-32(s0)
  76:	fe043423          	sd	zero,-24(s0)
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, -1);
  7a:	56fd                	li	a3,-1
  7c:	fc040613          	add	a2,s0,-64
  80:	00002597          	auipc	a1,0x2
  84:	fb058593          	add	a1,a1,-80 # 2030 <stacks+0x1000>
  88:	00000517          	auipc	a0,0x0
  8c:	f7850513          	add	a0,a0,-136 # 0 <ul_start_func>
  90:	00001097          	auipc	ra,0x1
  94:	826080e7          	jalr	-2010(ra) # 8b6 <ulthread_create>

    /* Schedule some of the threads */
    ulthread_schedule();
  98:	00001097          	auipc	ra,0x1
  9c:	8be080e7          	jalr	-1858(ra) # 956 <ulthread_schedule>

    printf("[*] User-Level Threading Test #1 Complete.\n");
  a0:	00001517          	auipc	a0,0x1
  a4:	b6050513          	add	a0,a0,-1184 # c00 <ulthread_context_switch+0xba>
  a8:	00000097          	auipc	ra,0x0
  ac:	608080e7          	jalr	1544(ra) # 6b0 <printf>
    return 0;
}
  b0:	4501                	li	a0,0
  b2:	70e2                	ld	ra,56(sp)
  b4:	7442                	ld	s0,48(sp)
  b6:	6121                	add	sp,sp,64
  b8:	8082                	ret

00000000000000ba <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ba:	1141                	add	sp,sp,-16
  bc:	e406                	sd	ra,8(sp)
  be:	e022                	sd	s0,0(sp)
  c0:	0800                	add	s0,sp,16
  extern int main();
  main();
  c2:	00000097          	auipc	ra,0x0
  c6:	f78080e7          	jalr	-136(ra) # 3a <main>
  exit(0);
  ca:	4501                	li	a0,0
  cc:	00000097          	auipc	ra,0x0
  d0:	274080e7          	jalr	628(ra) # 340 <exit>

00000000000000d4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  d4:	1141                	add	sp,sp,-16
  d6:	e422                	sd	s0,8(sp)
  d8:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  da:	87aa                	mv	a5,a0
  dc:	0585                	add	a1,a1,1
  de:	0785                	add	a5,a5,1
  e0:	fff5c703          	lbu	a4,-1(a1)
  e4:	fee78fa3          	sb	a4,-1(a5)
  e8:	fb75                	bnez	a4,dc <strcpy+0x8>
    ;
  return os;
}
  ea:	6422                	ld	s0,8(sp)
  ec:	0141                	add	sp,sp,16
  ee:	8082                	ret

00000000000000f0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f0:	1141                	add	sp,sp,-16
  f2:	e422                	sd	s0,8(sp)
  f4:	0800                	add	s0,sp,16
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	cb91                	beqz	a5,10e <strcmp+0x1e>
  fc:	0005c703          	lbu	a4,0(a1)
 100:	00f71763          	bne	a4,a5,10e <strcmp+0x1e>
    p++, q++;
 104:	0505                	add	a0,a0,1
 106:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 108:	00054783          	lbu	a5,0(a0)
 10c:	fbe5                	bnez	a5,fc <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 10e:	0005c503          	lbu	a0,0(a1)
}
 112:	40a7853b          	subw	a0,a5,a0
 116:	6422                	ld	s0,8(sp)
 118:	0141                	add	sp,sp,16
 11a:	8082                	ret

000000000000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	1141                	add	sp,sp,-16
 11e:	e422                	sd	s0,8(sp)
 120:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 122:	00054783          	lbu	a5,0(a0)
 126:	cf91                	beqz	a5,142 <strlen+0x26>
 128:	0505                	add	a0,a0,1
 12a:	87aa                	mv	a5,a0
 12c:	86be                	mv	a3,a5
 12e:	0785                	add	a5,a5,1
 130:	fff7c703          	lbu	a4,-1(a5)
 134:	ff65                	bnez	a4,12c <strlen+0x10>
 136:	40a6853b          	subw	a0,a3,a0
 13a:	2505                	addw	a0,a0,1
    ;
  return n;
}
 13c:	6422                	ld	s0,8(sp)
 13e:	0141                	add	sp,sp,16
 140:	8082                	ret
  for(n = 0; s[n]; n++)
 142:	4501                	li	a0,0
 144:	bfe5                	j	13c <strlen+0x20>

0000000000000146 <memset>:

void*
memset(void *dst, int c, uint n)
{
 146:	1141                	add	sp,sp,-16
 148:	e422                	sd	s0,8(sp)
 14a:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 14c:	ca19                	beqz	a2,162 <memset+0x1c>
 14e:	87aa                	mv	a5,a0
 150:	1602                	sll	a2,a2,0x20
 152:	9201                	srl	a2,a2,0x20
 154:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 158:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 15c:	0785                	add	a5,a5,1
 15e:	fee79de3          	bne	a5,a4,158 <memset+0x12>
  }
  return dst;
}
 162:	6422                	ld	s0,8(sp)
 164:	0141                	add	sp,sp,16
 166:	8082                	ret

0000000000000168 <strchr>:

char*
strchr(const char *s, char c)
{
 168:	1141                	add	sp,sp,-16
 16a:	e422                	sd	s0,8(sp)
 16c:	0800                	add	s0,sp,16
  for(; *s; s++)
 16e:	00054783          	lbu	a5,0(a0)
 172:	cb99                	beqz	a5,188 <strchr+0x20>
    if(*s == c)
 174:	00f58763          	beq	a1,a5,182 <strchr+0x1a>
  for(; *s; s++)
 178:	0505                	add	a0,a0,1
 17a:	00054783          	lbu	a5,0(a0)
 17e:	fbfd                	bnez	a5,174 <strchr+0xc>
      return (char*)s;
  return 0;
 180:	4501                	li	a0,0
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	add	sp,sp,16
 186:	8082                	ret
  return 0;
 188:	4501                	li	a0,0
 18a:	bfe5                	j	182 <strchr+0x1a>

000000000000018c <gets>:

char*
gets(char *buf, int max)
{
 18c:	711d                	add	sp,sp,-96
 18e:	ec86                	sd	ra,88(sp)
 190:	e8a2                	sd	s0,80(sp)
 192:	e4a6                	sd	s1,72(sp)
 194:	e0ca                	sd	s2,64(sp)
 196:	fc4e                	sd	s3,56(sp)
 198:	f852                	sd	s4,48(sp)
 19a:	f456                	sd	s5,40(sp)
 19c:	f05a                	sd	s6,32(sp)
 19e:	ec5e                	sd	s7,24(sp)
 1a0:	1080                	add	s0,sp,96
 1a2:	8baa                	mv	s7,a0
 1a4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1a6:	892a                	mv	s2,a0
 1a8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1aa:	4aa9                	li	s5,10
 1ac:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ae:	89a6                	mv	s3,s1
 1b0:	2485                	addw	s1,s1,1
 1b2:	0344d863          	bge	s1,s4,1e2 <gets+0x56>
    cc = read(0, &c, 1);
 1b6:	4605                	li	a2,1
 1b8:	faf40593          	add	a1,s0,-81
 1bc:	4501                	li	a0,0
 1be:	00000097          	auipc	ra,0x0
 1c2:	19a080e7          	jalr	410(ra) # 358 <read>
    if(cc < 1)
 1c6:	00a05e63          	blez	a0,1e2 <gets+0x56>
    buf[i++] = c;
 1ca:	faf44783          	lbu	a5,-81(s0)
 1ce:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1d2:	01578763          	beq	a5,s5,1e0 <gets+0x54>
 1d6:	0905                	add	s2,s2,1
 1d8:	fd679be3          	bne	a5,s6,1ae <gets+0x22>
  for(i=0; i+1 < max; ){
 1dc:	89a6                	mv	s3,s1
 1de:	a011                	j	1e2 <gets+0x56>
 1e0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1e2:	99de                	add	s3,s3,s7
 1e4:	00098023          	sb	zero,0(s3)
  return buf;
}
 1e8:	855e                	mv	a0,s7
 1ea:	60e6                	ld	ra,88(sp)
 1ec:	6446                	ld	s0,80(sp)
 1ee:	64a6                	ld	s1,72(sp)
 1f0:	6906                	ld	s2,64(sp)
 1f2:	79e2                	ld	s3,56(sp)
 1f4:	7a42                	ld	s4,48(sp)
 1f6:	7aa2                	ld	s5,40(sp)
 1f8:	7b02                	ld	s6,32(sp)
 1fa:	6be2                	ld	s7,24(sp)
 1fc:	6125                	add	sp,sp,96
 1fe:	8082                	ret

0000000000000200 <stat>:

int
stat(const char *n, struct stat *st)
{
 200:	1101                	add	sp,sp,-32
 202:	ec06                	sd	ra,24(sp)
 204:	e822                	sd	s0,16(sp)
 206:	e426                	sd	s1,8(sp)
 208:	e04a                	sd	s2,0(sp)
 20a:	1000                	add	s0,sp,32
 20c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	4581                	li	a1,0
 210:	00000097          	auipc	ra,0x0
 214:	170080e7          	jalr	368(ra) # 380 <open>
  if(fd < 0)
 218:	02054563          	bltz	a0,242 <stat+0x42>
 21c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 21e:	85ca                	mv	a1,s2
 220:	00000097          	auipc	ra,0x0
 224:	178080e7          	jalr	376(ra) # 398 <fstat>
 228:	892a                	mv	s2,a0
  close(fd);
 22a:	8526                	mv	a0,s1
 22c:	00000097          	auipc	ra,0x0
 230:	13c080e7          	jalr	316(ra) # 368 <close>
  return r;
}
 234:	854a                	mv	a0,s2
 236:	60e2                	ld	ra,24(sp)
 238:	6442                	ld	s0,16(sp)
 23a:	64a2                	ld	s1,8(sp)
 23c:	6902                	ld	s2,0(sp)
 23e:	6105                	add	sp,sp,32
 240:	8082                	ret
    return -1;
 242:	597d                	li	s2,-1
 244:	bfc5                	j	234 <stat+0x34>

0000000000000246 <atoi>:

int
atoi(const char *s)
{
 246:	1141                	add	sp,sp,-16
 248:	e422                	sd	s0,8(sp)
 24a:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 24c:	00054683          	lbu	a3,0(a0)
 250:	fd06879b          	addw	a5,a3,-48
 254:	0ff7f793          	zext.b	a5,a5
 258:	4625                	li	a2,9
 25a:	02f66863          	bltu	a2,a5,28a <atoi+0x44>
 25e:	872a                	mv	a4,a0
  n = 0;
 260:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 262:	0705                	add	a4,a4,1
 264:	0025179b          	sllw	a5,a0,0x2
 268:	9fa9                	addw	a5,a5,a0
 26a:	0017979b          	sllw	a5,a5,0x1
 26e:	9fb5                	addw	a5,a5,a3
 270:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 274:	00074683          	lbu	a3,0(a4)
 278:	fd06879b          	addw	a5,a3,-48
 27c:	0ff7f793          	zext.b	a5,a5
 280:	fef671e3          	bgeu	a2,a5,262 <atoi+0x1c>
  return n;
}
 284:	6422                	ld	s0,8(sp)
 286:	0141                	add	sp,sp,16
 288:	8082                	ret
  n = 0;
 28a:	4501                	li	a0,0
 28c:	bfe5                	j	284 <atoi+0x3e>

000000000000028e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 28e:	1141                	add	sp,sp,-16
 290:	e422                	sd	s0,8(sp)
 292:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 294:	02b57463          	bgeu	a0,a1,2bc <memmove+0x2e>
    while(n-- > 0)
 298:	00c05f63          	blez	a2,2b6 <memmove+0x28>
 29c:	1602                	sll	a2,a2,0x20
 29e:	9201                	srl	a2,a2,0x20
 2a0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2a4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2a6:	0585                	add	a1,a1,1
 2a8:	0705                	add	a4,a4,1
 2aa:	fff5c683          	lbu	a3,-1(a1)
 2ae:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2b2:	fee79ae3          	bne	a5,a4,2a6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2b6:	6422                	ld	s0,8(sp)
 2b8:	0141                	add	sp,sp,16
 2ba:	8082                	ret
    dst += n;
 2bc:	00c50733          	add	a4,a0,a2
    src += n;
 2c0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2c2:	fec05ae3          	blez	a2,2b6 <memmove+0x28>
 2c6:	fff6079b          	addw	a5,a2,-1 # 63fff <stacks+0x62fcf>
 2ca:	1782                	sll	a5,a5,0x20
 2cc:	9381                	srl	a5,a5,0x20
 2ce:	fff7c793          	not	a5,a5
 2d2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2d4:	15fd                	add	a1,a1,-1
 2d6:	177d                	add	a4,a4,-1
 2d8:	0005c683          	lbu	a3,0(a1)
 2dc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2e0:	fee79ae3          	bne	a5,a4,2d4 <memmove+0x46>
 2e4:	bfc9                	j	2b6 <memmove+0x28>

00000000000002e6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2e6:	1141                	add	sp,sp,-16
 2e8:	e422                	sd	s0,8(sp)
 2ea:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ec:	ca05                	beqz	a2,31c <memcmp+0x36>
 2ee:	fff6069b          	addw	a3,a2,-1
 2f2:	1682                	sll	a3,a3,0x20
 2f4:	9281                	srl	a3,a3,0x20
 2f6:	0685                	add	a3,a3,1
 2f8:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2fa:	00054783          	lbu	a5,0(a0)
 2fe:	0005c703          	lbu	a4,0(a1)
 302:	00e79863          	bne	a5,a4,312 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 306:	0505                	add	a0,a0,1
    p2++;
 308:	0585                	add	a1,a1,1
  while (n-- > 0) {
 30a:	fed518e3          	bne	a0,a3,2fa <memcmp+0x14>
  }
  return 0;
 30e:	4501                	li	a0,0
 310:	a019                	j	316 <memcmp+0x30>
      return *p1 - *p2;
 312:	40e7853b          	subw	a0,a5,a4
}
 316:	6422                	ld	s0,8(sp)
 318:	0141                	add	sp,sp,16
 31a:	8082                	ret
  return 0;
 31c:	4501                	li	a0,0
 31e:	bfe5                	j	316 <memcmp+0x30>

0000000000000320 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 320:	1141                	add	sp,sp,-16
 322:	e406                	sd	ra,8(sp)
 324:	e022                	sd	s0,0(sp)
 326:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 328:	00000097          	auipc	ra,0x0
 32c:	f66080e7          	jalr	-154(ra) # 28e <memmove>
}
 330:	60a2                	ld	ra,8(sp)
 332:	6402                	ld	s0,0(sp)
 334:	0141                	add	sp,sp,16
 336:	8082                	ret

0000000000000338 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 338:	4885                	li	a7,1
 ecall
 33a:	00000073          	ecall
 ret
 33e:	8082                	ret

0000000000000340 <exit>:
.global exit
exit:
 li a7, SYS_exit
 340:	4889                	li	a7,2
 ecall
 342:	00000073          	ecall
 ret
 346:	8082                	ret

0000000000000348 <wait>:
.global wait
wait:
 li a7, SYS_wait
 348:	488d                	li	a7,3
 ecall
 34a:	00000073          	ecall
 ret
 34e:	8082                	ret

0000000000000350 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 350:	4891                	li	a7,4
 ecall
 352:	00000073          	ecall
 ret
 356:	8082                	ret

0000000000000358 <read>:
.global read
read:
 li a7, SYS_read
 358:	4895                	li	a7,5
 ecall
 35a:	00000073          	ecall
 ret
 35e:	8082                	ret

0000000000000360 <write>:
.global write
write:
 li a7, SYS_write
 360:	48c1                	li	a7,16
 ecall
 362:	00000073          	ecall
 ret
 366:	8082                	ret

0000000000000368 <close>:
.global close
close:
 li a7, SYS_close
 368:	48d5                	li	a7,21
 ecall
 36a:	00000073          	ecall
 ret
 36e:	8082                	ret

0000000000000370 <kill>:
.global kill
kill:
 li a7, SYS_kill
 370:	4899                	li	a7,6
 ecall
 372:	00000073          	ecall
 ret
 376:	8082                	ret

0000000000000378 <exec>:
.global exec
exec:
 li a7, SYS_exec
 378:	489d                	li	a7,7
 ecall
 37a:	00000073          	ecall
 ret
 37e:	8082                	ret

0000000000000380 <open>:
.global open
open:
 li a7, SYS_open
 380:	48bd                	li	a7,15
 ecall
 382:	00000073          	ecall
 ret
 386:	8082                	ret

0000000000000388 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 388:	48c5                	li	a7,17
 ecall
 38a:	00000073          	ecall
 ret
 38e:	8082                	ret

0000000000000390 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 390:	48c9                	li	a7,18
 ecall
 392:	00000073          	ecall
 ret
 396:	8082                	ret

0000000000000398 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 398:	48a1                	li	a7,8
 ecall
 39a:	00000073          	ecall
 ret
 39e:	8082                	ret

00000000000003a0 <link>:
.global link
link:
 li a7, SYS_link
 3a0:	48cd                	li	a7,19
 ecall
 3a2:	00000073          	ecall
 ret
 3a6:	8082                	ret

00000000000003a8 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3a8:	48d1                	li	a7,20
 ecall
 3aa:	00000073          	ecall
 ret
 3ae:	8082                	ret

00000000000003b0 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3b0:	48a5                	li	a7,9
 ecall
 3b2:	00000073          	ecall
 ret
 3b6:	8082                	ret

00000000000003b8 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3b8:	48a9                	li	a7,10
 ecall
 3ba:	00000073          	ecall
 ret
 3be:	8082                	ret

00000000000003c0 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3c0:	48ad                	li	a7,11
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3c8:	48b1                	li	a7,12
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3d0:	48b5                	li	a7,13
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3d8:	48b9                	li	a7,14
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 3e0:	48d9                	li	a7,22
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3e8:	1101                	add	sp,sp,-32
 3ea:	ec06                	sd	ra,24(sp)
 3ec:	e822                	sd	s0,16(sp)
 3ee:	1000                	add	s0,sp,32
 3f0:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3f4:	4605                	li	a2,1
 3f6:	fef40593          	add	a1,s0,-17
 3fa:	00000097          	auipc	ra,0x0
 3fe:	f66080e7          	jalr	-154(ra) # 360 <write>
}
 402:	60e2                	ld	ra,24(sp)
 404:	6442                	ld	s0,16(sp)
 406:	6105                	add	sp,sp,32
 408:	8082                	ret

000000000000040a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 40a:	7139                	add	sp,sp,-64
 40c:	fc06                	sd	ra,56(sp)
 40e:	f822                	sd	s0,48(sp)
 410:	f426                	sd	s1,40(sp)
 412:	f04a                	sd	s2,32(sp)
 414:	ec4e                	sd	s3,24(sp)
 416:	0080                	add	s0,sp,64
 418:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 41a:	c299                	beqz	a3,420 <printint+0x16>
 41c:	0805c963          	bltz	a1,4ae <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 420:	2581                	sext.w	a1,a1
  neg = 0;
 422:	4881                	li	a7,0
 424:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 428:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 42a:	2601                	sext.w	a2,a2
 42c:	00001517          	auipc	a0,0x1
 430:	86450513          	add	a0,a0,-1948 # c90 <digits>
 434:	883a                	mv	a6,a4
 436:	2705                	addw	a4,a4,1
 438:	02c5f7bb          	remuw	a5,a1,a2
 43c:	1782                	sll	a5,a5,0x20
 43e:	9381                	srl	a5,a5,0x20
 440:	97aa                	add	a5,a5,a0
 442:	0007c783          	lbu	a5,0(a5)
 446:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 44a:	0005879b          	sext.w	a5,a1
 44e:	02c5d5bb          	divuw	a1,a1,a2
 452:	0685                	add	a3,a3,1
 454:	fec7f0e3          	bgeu	a5,a2,434 <printint+0x2a>
  if(neg)
 458:	00088c63          	beqz	a7,470 <printint+0x66>
    buf[i++] = '-';
 45c:	fd070793          	add	a5,a4,-48
 460:	00878733          	add	a4,a5,s0
 464:	02d00793          	li	a5,45
 468:	fef70823          	sb	a5,-16(a4)
 46c:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 470:	02e05863          	blez	a4,4a0 <printint+0x96>
 474:	fc040793          	add	a5,s0,-64
 478:	00e78933          	add	s2,a5,a4
 47c:	fff78993          	add	s3,a5,-1
 480:	99ba                	add	s3,s3,a4
 482:	377d                	addw	a4,a4,-1
 484:	1702                	sll	a4,a4,0x20
 486:	9301                	srl	a4,a4,0x20
 488:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 48c:	fff94583          	lbu	a1,-1(s2)
 490:	8526                	mv	a0,s1
 492:	00000097          	auipc	ra,0x0
 496:	f56080e7          	jalr	-170(ra) # 3e8 <putc>
  while(--i >= 0)
 49a:	197d                	add	s2,s2,-1
 49c:	ff3918e3          	bne	s2,s3,48c <printint+0x82>
}
 4a0:	70e2                	ld	ra,56(sp)
 4a2:	7442                	ld	s0,48(sp)
 4a4:	74a2                	ld	s1,40(sp)
 4a6:	7902                	ld	s2,32(sp)
 4a8:	69e2                	ld	s3,24(sp)
 4aa:	6121                	add	sp,sp,64
 4ac:	8082                	ret
    x = -xx;
 4ae:	40b005bb          	negw	a1,a1
    neg = 1;
 4b2:	4885                	li	a7,1
    x = -xx;
 4b4:	bf85                	j	424 <printint+0x1a>

00000000000004b6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4b6:	715d                	add	sp,sp,-80
 4b8:	e486                	sd	ra,72(sp)
 4ba:	e0a2                	sd	s0,64(sp)
 4bc:	fc26                	sd	s1,56(sp)
 4be:	f84a                	sd	s2,48(sp)
 4c0:	f44e                	sd	s3,40(sp)
 4c2:	f052                	sd	s4,32(sp)
 4c4:	ec56                	sd	s5,24(sp)
 4c6:	e85a                	sd	s6,16(sp)
 4c8:	e45e                	sd	s7,8(sp)
 4ca:	e062                	sd	s8,0(sp)
 4cc:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4ce:	0005c903          	lbu	s2,0(a1)
 4d2:	18090c63          	beqz	s2,66a <vprintf+0x1b4>
 4d6:	8aaa                	mv	s5,a0
 4d8:	8bb2                	mv	s7,a2
 4da:	00158493          	add	s1,a1,1
  state = 0;
 4de:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4e0:	02500a13          	li	s4,37
 4e4:	4b55                	li	s6,21
 4e6:	a839                	j	504 <vprintf+0x4e>
        putc(fd, c);
 4e8:	85ca                	mv	a1,s2
 4ea:	8556                	mv	a0,s5
 4ec:	00000097          	auipc	ra,0x0
 4f0:	efc080e7          	jalr	-260(ra) # 3e8 <putc>
 4f4:	a019                	j	4fa <vprintf+0x44>
    } else if(state == '%'){
 4f6:	01498d63          	beq	s3,s4,510 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 4fa:	0485                	add	s1,s1,1
 4fc:	fff4c903          	lbu	s2,-1(s1)
 500:	16090563          	beqz	s2,66a <vprintf+0x1b4>
    if(state == 0){
 504:	fe0999e3          	bnez	s3,4f6 <vprintf+0x40>
      if(c == '%'){
 508:	ff4910e3          	bne	s2,s4,4e8 <vprintf+0x32>
        state = '%';
 50c:	89d2                	mv	s3,s4
 50e:	b7f5                	j	4fa <vprintf+0x44>
      if(c == 'd'){
 510:	13490263          	beq	s2,s4,634 <vprintf+0x17e>
 514:	f9d9079b          	addw	a5,s2,-99
 518:	0ff7f793          	zext.b	a5,a5
 51c:	12fb6563          	bltu	s6,a5,646 <vprintf+0x190>
 520:	f9d9079b          	addw	a5,s2,-99
 524:	0ff7f713          	zext.b	a4,a5
 528:	10eb6f63          	bltu	s6,a4,646 <vprintf+0x190>
 52c:	00271793          	sll	a5,a4,0x2
 530:	00000717          	auipc	a4,0x0
 534:	70870713          	add	a4,a4,1800 # c38 <ulthread_context_switch+0xf2>
 538:	97ba                	add	a5,a5,a4
 53a:	439c                	lw	a5,0(a5)
 53c:	97ba                	add	a5,a5,a4
 53e:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 540:	008b8913          	add	s2,s7,8
 544:	4685                	li	a3,1
 546:	4629                	li	a2,10
 548:	000ba583          	lw	a1,0(s7)
 54c:	8556                	mv	a0,s5
 54e:	00000097          	auipc	ra,0x0
 552:	ebc080e7          	jalr	-324(ra) # 40a <printint>
 556:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 558:	4981                	li	s3,0
 55a:	b745                	j	4fa <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 55c:	008b8913          	add	s2,s7,8
 560:	4681                	li	a3,0
 562:	4629                	li	a2,10
 564:	000ba583          	lw	a1,0(s7)
 568:	8556                	mv	a0,s5
 56a:	00000097          	auipc	ra,0x0
 56e:	ea0080e7          	jalr	-352(ra) # 40a <printint>
 572:	8bca                	mv	s7,s2
      state = 0;
 574:	4981                	li	s3,0
 576:	b751                	j	4fa <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 578:	008b8913          	add	s2,s7,8
 57c:	4681                	li	a3,0
 57e:	4641                	li	a2,16
 580:	000ba583          	lw	a1,0(s7)
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	e84080e7          	jalr	-380(ra) # 40a <printint>
 58e:	8bca                	mv	s7,s2
      state = 0;
 590:	4981                	li	s3,0
 592:	b7a5                	j	4fa <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 594:	008b8c13          	add	s8,s7,8
 598:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 59c:	03000593          	li	a1,48
 5a0:	8556                	mv	a0,s5
 5a2:	00000097          	auipc	ra,0x0
 5a6:	e46080e7          	jalr	-442(ra) # 3e8 <putc>
  putc(fd, 'x');
 5aa:	07800593          	li	a1,120
 5ae:	8556                	mv	a0,s5
 5b0:	00000097          	auipc	ra,0x0
 5b4:	e38080e7          	jalr	-456(ra) # 3e8 <putc>
 5b8:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ba:	00000b97          	auipc	s7,0x0
 5be:	6d6b8b93          	add	s7,s7,1750 # c90 <digits>
 5c2:	03c9d793          	srl	a5,s3,0x3c
 5c6:	97de                	add	a5,a5,s7
 5c8:	0007c583          	lbu	a1,0(a5)
 5cc:	8556                	mv	a0,s5
 5ce:	00000097          	auipc	ra,0x0
 5d2:	e1a080e7          	jalr	-486(ra) # 3e8 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5d6:	0992                	sll	s3,s3,0x4
 5d8:	397d                	addw	s2,s2,-1
 5da:	fe0914e3          	bnez	s2,5c2 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5de:	8be2                	mv	s7,s8
      state = 0;
 5e0:	4981                	li	s3,0
 5e2:	bf21                	j	4fa <vprintf+0x44>
        s = va_arg(ap, char*);
 5e4:	008b8993          	add	s3,s7,8
 5e8:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 5ec:	02090163          	beqz	s2,60e <vprintf+0x158>
        while(*s != 0){
 5f0:	00094583          	lbu	a1,0(s2)
 5f4:	c9a5                	beqz	a1,664 <vprintf+0x1ae>
          putc(fd, *s);
 5f6:	8556                	mv	a0,s5
 5f8:	00000097          	auipc	ra,0x0
 5fc:	df0080e7          	jalr	-528(ra) # 3e8 <putc>
          s++;
 600:	0905                	add	s2,s2,1
        while(*s != 0){
 602:	00094583          	lbu	a1,0(s2)
 606:	f9e5                	bnez	a1,5f6 <vprintf+0x140>
        s = va_arg(ap, char*);
 608:	8bce                	mv	s7,s3
      state = 0;
 60a:	4981                	li	s3,0
 60c:	b5fd                	j	4fa <vprintf+0x44>
          s = "(null)";
 60e:	00000917          	auipc	s2,0x0
 612:	62290913          	add	s2,s2,1570 # c30 <ulthread_context_switch+0xea>
        while(*s != 0){
 616:	02800593          	li	a1,40
 61a:	bff1                	j	5f6 <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 61c:	008b8913          	add	s2,s7,8
 620:	000bc583          	lbu	a1,0(s7)
 624:	8556                	mv	a0,s5
 626:	00000097          	auipc	ra,0x0
 62a:	dc2080e7          	jalr	-574(ra) # 3e8 <putc>
 62e:	8bca                	mv	s7,s2
      state = 0;
 630:	4981                	li	s3,0
 632:	b5e1                	j	4fa <vprintf+0x44>
        putc(fd, c);
 634:	02500593          	li	a1,37
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	dae080e7          	jalr	-594(ra) # 3e8 <putc>
      state = 0;
 642:	4981                	li	s3,0
 644:	bd5d                	j	4fa <vprintf+0x44>
        putc(fd, '%');
 646:	02500593          	li	a1,37
 64a:	8556                	mv	a0,s5
 64c:	00000097          	auipc	ra,0x0
 650:	d9c080e7          	jalr	-612(ra) # 3e8 <putc>
        putc(fd, c);
 654:	85ca                	mv	a1,s2
 656:	8556                	mv	a0,s5
 658:	00000097          	auipc	ra,0x0
 65c:	d90080e7          	jalr	-624(ra) # 3e8 <putc>
      state = 0;
 660:	4981                	li	s3,0
 662:	bd61                	j	4fa <vprintf+0x44>
        s = va_arg(ap, char*);
 664:	8bce                	mv	s7,s3
      state = 0;
 666:	4981                	li	s3,0
 668:	bd49                	j	4fa <vprintf+0x44>
    }
  }
}
 66a:	60a6                	ld	ra,72(sp)
 66c:	6406                	ld	s0,64(sp)
 66e:	74e2                	ld	s1,56(sp)
 670:	7942                	ld	s2,48(sp)
 672:	79a2                	ld	s3,40(sp)
 674:	7a02                	ld	s4,32(sp)
 676:	6ae2                	ld	s5,24(sp)
 678:	6b42                	ld	s6,16(sp)
 67a:	6ba2                	ld	s7,8(sp)
 67c:	6c02                	ld	s8,0(sp)
 67e:	6161                	add	sp,sp,80
 680:	8082                	ret

0000000000000682 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 682:	715d                	add	sp,sp,-80
 684:	ec06                	sd	ra,24(sp)
 686:	e822                	sd	s0,16(sp)
 688:	1000                	add	s0,sp,32
 68a:	e010                	sd	a2,0(s0)
 68c:	e414                	sd	a3,8(s0)
 68e:	e818                	sd	a4,16(s0)
 690:	ec1c                	sd	a5,24(s0)
 692:	03043023          	sd	a6,32(s0)
 696:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 69a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 69e:	8622                	mv	a2,s0
 6a0:	00000097          	auipc	ra,0x0
 6a4:	e16080e7          	jalr	-490(ra) # 4b6 <vprintf>
}
 6a8:	60e2                	ld	ra,24(sp)
 6aa:	6442                	ld	s0,16(sp)
 6ac:	6161                	add	sp,sp,80
 6ae:	8082                	ret

00000000000006b0 <printf>:

void
printf(const char *fmt, ...)
{
 6b0:	711d                	add	sp,sp,-96
 6b2:	ec06                	sd	ra,24(sp)
 6b4:	e822                	sd	s0,16(sp)
 6b6:	1000                	add	s0,sp,32
 6b8:	e40c                	sd	a1,8(s0)
 6ba:	e810                	sd	a2,16(s0)
 6bc:	ec14                	sd	a3,24(s0)
 6be:	f018                	sd	a4,32(s0)
 6c0:	f41c                	sd	a5,40(s0)
 6c2:	03043823          	sd	a6,48(s0)
 6c6:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6ca:	00840613          	add	a2,s0,8
 6ce:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6d2:	85aa                	mv	a1,a0
 6d4:	4505                	li	a0,1
 6d6:	00000097          	auipc	ra,0x0
 6da:	de0080e7          	jalr	-544(ra) # 4b6 <vprintf>
}
 6de:	60e2                	ld	ra,24(sp)
 6e0:	6442                	ld	s0,16(sp)
 6e2:	6125                	add	sp,sp,96
 6e4:	8082                	ret

00000000000006e6 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6e6:	1141                	add	sp,sp,-16
 6e8:	e422                	sd	s0,8(sp)
 6ea:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 6ec:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6f0:	00001797          	auipc	a5,0x1
 6f4:	9207b783          	ld	a5,-1760(a5) # 1010 <freep>
 6f8:	a02d                	j	722 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 6fa:	4618                	lw	a4,8(a2)
 6fc:	9f2d                	addw	a4,a4,a1
 6fe:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 702:	6398                	ld	a4,0(a5)
 704:	6310                	ld	a2,0(a4)
 706:	a83d                	j	744 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 708:	ff852703          	lw	a4,-8(a0)
 70c:	9f31                	addw	a4,a4,a2
 70e:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 710:	ff053683          	ld	a3,-16(a0)
 714:	a091                	j	758 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 716:	6398                	ld	a4,0(a5)
 718:	00e7e463          	bltu	a5,a4,720 <free+0x3a>
 71c:	00e6ea63          	bltu	a3,a4,730 <free+0x4a>
{
 720:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 722:	fed7fae3          	bgeu	a5,a3,716 <free+0x30>
 726:	6398                	ld	a4,0(a5)
 728:	00e6e463          	bltu	a3,a4,730 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72c:	fee7eae3          	bltu	a5,a4,720 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 730:	ff852583          	lw	a1,-8(a0)
 734:	6390                	ld	a2,0(a5)
 736:	02059813          	sll	a6,a1,0x20
 73a:	01c85713          	srl	a4,a6,0x1c
 73e:	9736                	add	a4,a4,a3
 740:	fae60de3          	beq	a2,a4,6fa <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 744:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 748:	4790                	lw	a2,8(a5)
 74a:	02061593          	sll	a1,a2,0x20
 74e:	01c5d713          	srl	a4,a1,0x1c
 752:	973e                	add	a4,a4,a5
 754:	fae68ae3          	beq	a3,a4,708 <free+0x22>
    p->s.ptr = bp->s.ptr;
 758:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 75a:	00001717          	auipc	a4,0x1
 75e:	8af73b23          	sd	a5,-1866(a4) # 1010 <freep>
}
 762:	6422                	ld	s0,8(sp)
 764:	0141                	add	sp,sp,16
 766:	8082                	ret

0000000000000768 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 768:	7139                	add	sp,sp,-64
 76a:	fc06                	sd	ra,56(sp)
 76c:	f822                	sd	s0,48(sp)
 76e:	f426                	sd	s1,40(sp)
 770:	f04a                	sd	s2,32(sp)
 772:	ec4e                	sd	s3,24(sp)
 774:	e852                	sd	s4,16(sp)
 776:	e456                	sd	s5,8(sp)
 778:	e05a                	sd	s6,0(sp)
 77a:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 77c:	02051493          	sll	s1,a0,0x20
 780:	9081                	srl	s1,s1,0x20
 782:	04bd                	add	s1,s1,15
 784:	8091                	srl	s1,s1,0x4
 786:	0014899b          	addw	s3,s1,1
 78a:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 78c:	00001517          	auipc	a0,0x1
 790:	88453503          	ld	a0,-1916(a0) # 1010 <freep>
 794:	c515                	beqz	a0,7c0 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 796:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 798:	4798                	lw	a4,8(a5)
 79a:	02977f63          	bgeu	a4,s1,7d8 <malloc+0x70>
  if(nu < 4096)
 79e:	8a4e                	mv	s4,s3
 7a0:	0009871b          	sext.w	a4,s3
 7a4:	6685                	lui	a3,0x1
 7a6:	00d77363          	bgeu	a4,a3,7ac <malloc+0x44>
 7aa:	6a05                	lui	s4,0x1
 7ac:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7b0:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7b4:	00001917          	auipc	s2,0x1
 7b8:	85c90913          	add	s2,s2,-1956 # 1010 <freep>
  if(p == (char*)-1)
 7bc:	5afd                	li	s5,-1
 7be:	a895                	j	832 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7c0:	00065797          	auipc	a5,0x65
 7c4:	87078793          	add	a5,a5,-1936 # 65030 <base>
 7c8:	00001717          	auipc	a4,0x1
 7cc:	84f73423          	sd	a5,-1976(a4) # 1010 <freep>
 7d0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7d2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7d6:	b7e1                	j	79e <malloc+0x36>
      if(p->s.size == nunits)
 7d8:	02e48c63          	beq	s1,a4,810 <malloc+0xa8>
        p->s.size -= nunits;
 7dc:	4137073b          	subw	a4,a4,s3
 7e0:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7e2:	02071693          	sll	a3,a4,0x20
 7e6:	01c6d713          	srl	a4,a3,0x1c
 7ea:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 7ec:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 7f0:	00001717          	auipc	a4,0x1
 7f4:	82a73023          	sd	a0,-2016(a4) # 1010 <freep>
      return (void*)(p + 1);
 7f8:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 7fc:	70e2                	ld	ra,56(sp)
 7fe:	7442                	ld	s0,48(sp)
 800:	74a2                	ld	s1,40(sp)
 802:	7902                	ld	s2,32(sp)
 804:	69e2                	ld	s3,24(sp)
 806:	6a42                	ld	s4,16(sp)
 808:	6aa2                	ld	s5,8(sp)
 80a:	6b02                	ld	s6,0(sp)
 80c:	6121                	add	sp,sp,64
 80e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 810:	6398                	ld	a4,0(a5)
 812:	e118                	sd	a4,0(a0)
 814:	bff1                	j	7f0 <malloc+0x88>
  hp->s.size = nu;
 816:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 81a:	0541                	add	a0,a0,16
 81c:	00000097          	auipc	ra,0x0
 820:	eca080e7          	jalr	-310(ra) # 6e6 <free>
  return freep;
 824:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 828:	d971                	beqz	a0,7fc <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82c:	4798                	lw	a4,8(a5)
 82e:	fa9775e3          	bgeu	a4,s1,7d8 <malloc+0x70>
    if(p == freep)
 832:	00093703          	ld	a4,0(s2)
 836:	853e                	mv	a0,a5
 838:	fef719e3          	bne	a4,a5,82a <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 83c:	8552                	mv	a0,s4
 83e:	00000097          	auipc	ra,0x0
 842:	b8a080e7          	jalr	-1142(ra) # 3c8 <sbrk>
  if(p == (char*)-1)
 846:	fd5518e3          	bne	a0,s5,816 <malloc+0xae>
        return 0;
 84a:	4501                	li	a0,0
 84c:	bf45                	j	7fc <malloc+0x94>

000000000000084e <get_current_tid>:
enum ulthread_scheduling_algorithm scheduling_algorithm;

int prev_tid = 0;

/* Get thread ID */
int get_current_tid(void) {
 84e:	1141                	add	sp,sp,-16
 850:	e422                	sd	s0,8(sp)
 852:	0800                	add	s0,sp,16
    return current_thread->tid;
}
 854:	00000797          	auipc	a5,0x0
 858:	7cc7b783          	ld	a5,1996(a5) # 1020 <current_thread>
 85c:	4388                	lw	a0,0(a5)
 85e:	6422                	ld	s0,8(sp)
 860:	0141                	add	sp,sp,16
 862:	8082                	ret

0000000000000864 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo) {
 864:	1141                	add	sp,sp,-16
 866:	e422                	sd	s0,8(sp)
 868:	0800                	add	s0,sp,16

    struct ulthread *t;
    int i = 0;
 86a:	4681                	li	a3,0
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 1 to MAXULTHREADS
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 86c:	00064797          	auipc	a5,0x64
 870:	7d478793          	add	a5,a5,2004 # 65040 <ulthread>
 874:	00069617          	auipc	a2,0x69
 878:	5ec60613          	add	a2,a2,1516 # 69e60 <ulthread+0x4e20>
        t->state = FREE;
 87c:	0007a423          	sw	zero,8(a5)
        t->tid = i++;
 880:	c394                	sw	a3,0(a5)
 882:	2685                	addw	a3,a3,1 # 1001 <scheduler_thread+0x1>
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 884:	0c878793          	add	a5,a5,200
 888:	fec79ae3          	bne	a5,a2,87c <ulthread_init+0x18>
    }
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    scheduler_thread->state = RUNNABLE;
 88c:	00000797          	auipc	a5,0x0
 890:	77478793          	add	a5,a5,1908 # 1000 <scheduler_thread>
 894:	6398                	ld	a4,0(a5)
 896:	4685                	li	a3,1
 898:	c714                	sw	a3,8(a4)
    scheduler_thread->tid = 0;
 89a:	00072023          	sw	zero,0(a4)
    // Set the current thread to the scheduler thread
    current_thread = scheduler_thread;
 89e:	639c                	ld	a5,0(a5)
 8a0:	00000717          	auipc	a4,0x0
 8a4:	78f73023          	sd	a5,1920(a4) # 1020 <current_thread>

    scheduling_algorithm = schedalgo;
 8a8:	00000797          	auipc	a5,0x0
 8ac:	76a7aa23          	sw	a0,1908(a5) # 101c <scheduling_algorithm>
}
 8b0:	6422                	ld	s0,8(sp)
 8b2:	0141                	add	sp,sp,16
 8b4:	8082                	ret

00000000000008b6 <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
 8b6:	7179                	add	sp,sp,-48
 8b8:	f406                	sd	ra,40(sp)
 8ba:	f022                	sd	s0,32(sp)
 8bc:	ec26                	sd	s1,24(sp)
 8be:	e84a                	sd	s2,16(sp)
 8c0:	e44e                	sd	s3,8(sp)
 8c2:	e052                	sd	s4,0(sp)
 8c4:	1800                	add	s0,sp,48
 8c6:	892a                	mv	s2,a0
 8c8:	89ae                	mv	s3,a1
 8ca:	8a36                	mv	s4,a3

    struct ulthread *t;

    // Find a free thread slot and initialize it
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 8cc:	00065497          	auipc	s1,0x65
 8d0:	83c48493          	add	s1,s1,-1988 # 65108 <ulthread+0xc8>
 8d4:	00069717          	auipc	a4,0x69
 8d8:	58c70713          	add	a4,a4,1420 # 69e60 <ulthread+0x4e20>
        if(t->state == FREE){
 8dc:	449c                	lw	a5,8(s1)
 8de:	c799                	beqz	a5,8ec <ulthread_create+0x36>
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 8e0:	0c848493          	add	s1,s1,200
 8e4:	fee49ce3          	bne	s1,a4,8dc <ulthread_create+0x26>
            t->priority = priority;
            break;
        }
    }
    if(t == &ulthread[MAXULTHREADS]){
        return false;
 8e8:	4501                	li	a0,0
 8ea:	a8a1                	j	942 <ulthread_create+0x8c>
            t->state = RUNNABLE;
 8ec:	4785                	li	a5,1
 8ee:	c49c                	sw	a5,8(s1)
            t->context.ra = start;
 8f0:	0324b423          	sd	s2,40(s1)
            t->context.sp = stack;
 8f4:	0334b823          	sd	s3,48(s1)
            t->context.s0 = args[0];
 8f8:	621c                	ld	a5,0(a2)
 8fa:	fc9c                	sd	a5,56(s1)
            t->context.s1 = args[1];
 8fc:	661c                	ld	a5,8(a2)
 8fe:	e0bc                	sd	a5,64(s1)
            t->context.s2 = args[2];
 900:	6a1c                	ld	a5,16(a2)
 902:	e4bc                	sd	a5,72(s1)
            t->context.s3 = args[3];
 904:	6e1c                	ld	a5,24(a2)
 906:	e8bc                	sd	a5,80(s1)
            t->context.s4 = args[4];
 908:	721c                	ld	a5,32(a2)
 90a:	ecbc                	sd	a5,88(s1)
            t->context.s5 = args[5];
 90c:	761c                	ld	a5,40(a2)
 90e:	f0bc                	sd	a5,96(s1)
            t->ctime = ctime();
 910:	00000097          	auipc	ra,0x0
 914:	ad0080e7          	jalr	-1328(ra) # 3e0 <ctime>
 918:	f088                	sd	a0,32(s1)
            t->priority = priority;
 91a:	0144a223          	sw	s4,4(s1)
    if(t == &ulthread[MAXULTHREADS]){
 91e:	00069797          	auipc	a5,0x69
 922:	54278793          	add	a5,a5,1346 # 69e60 <ulthread+0x4e20>
 926:	02f48663          	beq	s1,a5,952 <ulthread_create+0x9c>
    }

    // current_thread = t;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 92a:	86ce                	mv	a3,s3
 92c:	864a                	mv	a2,s2
 92e:	408c                	lw	a1,0(s1)
 930:	00000517          	auipc	a0,0x0
 934:	37850513          	add	a0,a0,888 # ca8 <digits+0x18>
 938:	00000097          	auipc	ra,0x0
 93c:	d78080e7          	jalr	-648(ra) # 6b0 <printf>

    return true;
 940:	4505                	li	a0,1
}
 942:	70a2                	ld	ra,40(sp)
 944:	7402                	ld	s0,32(sp)
 946:	64e2                	ld	s1,24(sp)
 948:	6942                	ld	s2,16(sp)
 94a:	69a2                	ld	s3,8(sp)
 94c:	6a02                	ld	s4,0(sp)
 94e:	6145                	add	sp,sp,48
 950:	8082                	ret
        return false;
 952:	4501                	li	a0,0
 954:	b7fd                	j	942 <ulthread_create+0x8c>

0000000000000956 <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void) {
 956:	715d                	add	sp,sp,-80
 958:	e486                	sd	ra,72(sp)
 95a:	e0a2                	sd	s0,64(sp)
 95c:	fc26                	sd	s1,56(sp)
 95e:	f84a                	sd	s2,48(sp)
 960:	f44e                	sd	s3,40(sp)
 962:	f052                	sd	s4,32(sp)
 964:	ec56                	sd	s5,24(sp)
 966:	e85a                	sd	s6,16(sp)
 968:	e45e                	sd	s7,8(sp)
 96a:	e062                	sd	s8,0(sp)
 96c:	0880                	add	s0,sp,80

    current_thread = scheduler_thread;
 96e:	00000797          	auipc	a5,0x0
 972:	6927b783          	ld	a5,1682(a5) # 1000 <scheduler_thread>
 976:	00000717          	auipc	a4,0x0
 97a:	6af73523          	sd	a5,1706(a4) # 1020 <current_thread>

        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){

            // printf("t->tid: %d\n", t->tid);
            
            if(scheduling_algorithm == 0){
 97e:	00000917          	auipc	s2,0x0
 982:	69e90913          	add	s2,s2,1694 # 101c <scheduling_algorithm>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 986:	00069497          	auipc	s1,0x69
 98a:	4da48493          	add	s1,s1,1242 # 69e60 <ulthread+0x4e20>
                }
            }
        
            if(t != 0){
                
                current_thread = t;
 98e:	00000a97          	auipc	s5,0x0
 992:	692a8a93          	add	s5,s5,1682 # 1020 <current_thread>

                flag = 1;

                /* Add this statement to denote which thread-id is being scheduled next */
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 996:	00000a17          	auipc	s4,0x0
 99a:	33aa0a13          	add	s4,s4,826 # cd0 <digits+0x40>

                // Switch between thread contexts from the scheduler thread to the new thread
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 99e:	00000997          	auipc	s3,0x0
 9a2:	66298993          	add	s3,s3,1634 # 1000 <scheduler_thread>
void ulthread_schedule(void) {
 9a6:	4701                	li	a4,0
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 9a8:	00064b17          	auipc	s6,0x64
 9ac:	760b0b13          	add	s6,s6,1888 # 65108 <ulthread+0xc8>
                flag = 1;
 9b0:	4b85                	li	s7,1
            else if(scheduling_algorithm == 2){
 9b2:	4c09                	li	s8,2
 9b4:	a83d                	j	9f2 <ulthread_schedule+0x9c>
            else if(scheduling_algorithm == 1){
 9b6:	07778163          	beq	a5,s7,a18 <ulthread_schedule+0xc2>
            else if(scheduling_algorithm == 2){
 9ba:	09878a63          	beq	a5,s8,a4e <ulthread_schedule+0xf8>
            if(t != 0){
 9be:	040b0163          	beqz	s6,a00 <ulthread_schedule+0xaa>
                current_thread = t;
 9c2:	016ab023          	sd	s6,0(s5)
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 9c6:	000b2583          	lw	a1,0(s6)
 9ca:	8552                	mv	a0,s4
 9cc:	00000097          	auipc	ra,0x0
 9d0:	ce4080e7          	jalr	-796(ra) # 6b0 <printf>
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 9d4:	0009b503          	ld	a0,0(s3)
 9d8:	028b0593          	add	a1,s6,40
 9dc:	02850513          	add	a0,a0,40
 9e0:	00000097          	auipc	ra,0x0
 9e4:	166080e7          	jalr	358(ra) # b46 <ulthread_context_switch>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 9e8:	00064b17          	auipc	s6,0x64
 9ec:	7e8b0b13          	add	s6,s6,2024 # 651d0 <ulthread+0x190>
                flag = 1;
 9f0:	875e                	mv	a4,s7
            if(scheduling_algorithm == 0){
 9f2:	00092783          	lw	a5,0(s2)
 9f6:	f3e1                	bnez	a5,9b6 <ulthread_schedule+0x60>
                if(t->state != RUNNABLE){
 9f8:	008b2783          	lw	a5,8(s6)
 9fc:	fd7783e3          	beq	a5,s7,9c2 <ulthread_schedule+0x6c>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a00:	0c8b0b13          	add	s6,s6,200
 a04:	fe9b67e3          	bltu	s6,s1,9f2 <ulthread_schedule+0x9c>

                t = &ulthread[1];
            }
            
        }
        if(flag == 0){
 a08:	c749                	beqz	a4,a92 <ulthread_schedule+0x13c>
            break;
        }
        else{
            flag = 0;
            struct ulthread *t1 = 0;
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 a0a:	00064797          	auipc	a5,0x64
 a0e:	6fe78793          	add	a5,a5,1790 # 65108 <ulthread+0xc8>
                if(t1->state == YIELD){
 a12:	4689                	li	a3,2
                    t1->state = RUNNABLE;
 a14:	4605                	li	a2,1
 a16:	a88d                	j	a88 <ulthread_schedule+0x132>
                if(t->state != RUNNABLE){
 a18:	008b2783          	lw	a5,8(s6)
 a1c:	ff7792e3          	bne	a5,s7,a00 <ulthread_schedule+0xaa>
 a20:	85da                	mv	a1,s6
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a22:	00064797          	auipc	a5,0x64
 a26:	6e678793          	add	a5,a5,1766 # 65108 <ulthread+0xc8>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 a2a:	4685                	li	a3,1
 a2c:	a029                	j	a36 <ulthread_schedule+0xe0>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a2e:	0c878793          	add	a5,a5,200
 a32:	00978b63          	beq	a5,s1,a48 <ulthread_schedule+0xf2>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 a36:	4798                	lw	a4,8(a5)
 a38:	fed71be3          	bne	a4,a3,a2e <ulthread_schedule+0xd8>
 a3c:	43d0                	lw	a2,4(a5)
 a3e:	41d8                	lw	a4,4(a1)
 a40:	fec757e3          	bge	a4,a2,a2e <ulthread_schedule+0xd8>
 a44:	85be                	mv	a1,a5
 a46:	b7e5                	j	a2e <ulthread_schedule+0xd8>
                if(max_priority_thread != 0){
 a48:	ddad                	beqz	a1,9c2 <ulthread_schedule+0x6c>
 a4a:	8b2e                	mv	s6,a1
 a4c:	bf9d                	j	9c2 <ulthread_schedule+0x6c>
                if(t->state != RUNNABLE){
 a4e:	008b2683          	lw	a3,8(s6)
 a52:	4785                	li	a5,1
 a54:	faf696e3          	bne	a3,a5,a00 <ulthread_schedule+0xaa>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a58:	00064797          	auipc	a5,0x64
 a5c:	6b078793          	add	a5,a5,1712 # 65108 <ulthread+0xc8>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 a60:	4605                	li	a2,1
 a62:	a029                	j	a6c <ulthread_schedule+0x116>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a64:	0c878793          	add	a5,a5,200
 a68:	f4978de3          	beq	a5,s1,9c2 <ulthread_schedule+0x6c>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 a6c:	7394                	ld	a3,32(a5)
 a6e:	020b3703          	ld	a4,32(s6)
 a72:	fee6f9e3          	bgeu	a3,a4,a64 <ulthread_schedule+0x10e>
 a76:	4798                	lw	a4,8(a5)
 a78:	fec716e3          	bne	a4,a2,a64 <ulthread_schedule+0x10e>
 a7c:	8b3e                	mv	s6,a5
 a7e:	b7dd                	j	a64 <ulthread_schedule+0x10e>
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 a80:	0c878793          	add	a5,a5,200
 a84:	f29781e3          	beq	a5,s1,9a6 <ulthread_schedule+0x50>
                if(t1->state == YIELD){
 a88:	4798                	lw	a4,8(a5)
 a8a:	fed71be3          	bne	a4,a3,a80 <ulthread_schedule+0x12a>
                    t1->state = RUNNABLE;
 a8e:	c790                	sw	a2,8(a5)
 a90:	bfc5                	j	a80 <ulthread_schedule+0x12a>
                }
            }
        }
    }
}
 a92:	60a6                	ld	ra,72(sp)
 a94:	6406                	ld	s0,64(sp)
 a96:	74e2                	ld	s1,56(sp)
 a98:	7942                	ld	s2,48(sp)
 a9a:	79a2                	ld	s3,40(sp)
 a9c:	7a02                	ld	s4,32(sp)
 a9e:	6ae2                	ld	s5,24(sp)
 aa0:	6b42                	ld	s6,16(sp)
 aa2:	6ba2                	ld	s7,8(sp)
 aa4:	6c02                	ld	s8,0(sp)
 aa6:	6161                	add	sp,sp,80
 aa8:	8082                	ret

0000000000000aaa <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {
 aaa:	1101                	add	sp,sp,-32
 aac:	ec06                	sd	ra,24(sp)
 aae:	e822                	sd	s0,16(sp)
 ab0:	e426                	sd	s1,8(sp)
 ab2:	1000                	add	s0,sp,32

    current_thread->state = YIELD;
 ab4:	00000497          	auipc	s1,0x0
 ab8:	56c48493          	add	s1,s1,1388 # 1020 <current_thread>
 abc:	609c                	ld	a5,0(s1)
 abe:	4709                	li	a4,2
 ac0:	c798                	sw	a4,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid());
 ac2:	438c                	lw	a1,0(a5)
 ac4:	00000517          	auipc	a0,0x0
 ac8:	22c50513          	add	a0,a0,556 # cf0 <digits+0x60>
 acc:	00000097          	auipc	ra,0x0
 ad0:	be4080e7          	jalr	-1052(ra) # 6b0 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 ad4:	6088                	ld	a0,0(s1)
 ad6:	00000597          	auipc	a1,0x0
 ada:	52a5b583          	ld	a1,1322(a1) # 1000 <scheduler_thread>
 ade:	02858593          	add	a1,a1,40
 ae2:	02850513          	add	a0,a0,40
 ae6:	00000097          	auipc	ra,0x0
 aea:	060080e7          	jalr	96(ra) # b46 <ulthread_context_switch>
    
}
 aee:	60e2                	ld	ra,24(sp)
 af0:	6442                	ld	s0,16(sp)
 af2:	64a2                	ld	s1,8(sp)
 af4:	6105                	add	sp,sp,32
 af6:	8082                	ret

0000000000000af8 <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void) {
 af8:	1101                	add	sp,sp,-32
 afa:	ec06                	sd	ra,24(sp)
 afc:	e822                	sd	s0,16(sp)
 afe:	e426                	sd	s1,8(sp)
 b00:	1000                	add	s0,sp,32

    // find the current running thread and mark it as FREE
    current_thread->state = FREE;
 b02:	00000497          	auipc	s1,0x0
 b06:	51e48493          	add	s1,s1,1310 # 1020 <current_thread>
 b0a:	609c                	ld	a5,0(s1)
 b0c:	0007a423          	sw	zero,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 b10:	438c                	lw	a1,0(a5)
 b12:	00000517          	auipc	a0,0x0
 b16:	1f650513          	add	a0,a0,502 # d08 <digits+0x78>
 b1a:	00000097          	auipc	ra,0x0
 b1e:	b96080e7          	jalr	-1130(ra) # 6b0 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 b22:	6088                	ld	a0,0(s1)
 b24:	00000597          	auipc	a1,0x0
 b28:	4dc5b583          	ld	a1,1244(a1) # 1000 <scheduler_thread>
 b2c:	02858593          	add	a1,a1,40
 b30:	02850513          	add	a0,a0,40
 b34:	00000097          	auipc	ra,0x0
 b38:	012080e7          	jalr	18(ra) # b46 <ulthread_context_switch>
}
 b3c:	60e2                	ld	ra,24(sp)
 b3e:	6442                	ld	s0,16(sp)
 b40:	64a2                	ld	s1,8(sp)
 b42:	6105                	add	sp,sp,32
 b44:	8082                	ret

0000000000000b46 <ulthread_context_switch>:
 b46:	00153023          	sd	ra,0(a0)
 b4a:	00253423          	sd	sp,8(a0)
 b4e:	e900                	sd	s0,16(a0)
 b50:	ed04                	sd	s1,24(a0)
 b52:	03253023          	sd	s2,32(a0)
 b56:	03353423          	sd	s3,40(a0)
 b5a:	03453823          	sd	s4,48(a0)
 b5e:	03553c23          	sd	s5,56(a0)
 b62:	05653023          	sd	s6,64(a0)
 b66:	05753423          	sd	s7,72(a0)
 b6a:	05853823          	sd	s8,80(a0)
 b6e:	05953c23          	sd	s9,88(a0)
 b72:	07a53023          	sd	s10,96(a0)
 b76:	07b53423          	sd	s11,104(a0)
 b7a:	0005b083          	ld	ra,0(a1)
 b7e:	0085b103          	ld	sp,8(a1)
 b82:	6980                	ld	s0,16(a1)
 b84:	6d84                	ld	s1,24(a1)
 b86:	0205b903          	ld	s2,32(a1)
 b8a:	0285b983          	ld	s3,40(a1)
 b8e:	0305ba03          	ld	s4,48(a1)
 b92:	0385ba83          	ld	s5,56(a1)
 b96:	0405bb03          	ld	s6,64(a1)
 b9a:	0485bb83          	ld	s7,72(a1)
 b9e:	0505bc03          	ld	s8,80(a1)
 ba2:	0585bc83          	ld	s9,88(a1)
 ba6:	0605bd03          	ld	s10,96(a1)
 baa:	0685bd83          	ld	s11,104(a1)
 bae:	00040513          	mv	a0,s0
 bb2:	00048593          	mv	a1,s1
 bb6:	00090613          	mv	a2,s2
 bba:	00098693          	mv	a3,s3
 bbe:	000a0713          	mv	a4,s4
 bc2:	000a8793          	mv	a5,s5
 bc6:	8082                	ret
