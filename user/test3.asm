
user/_test3:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <ul_start_func>:
#include <stdarg.h>

/* Stack region for different threads */
char stacks[PGSIZE*MAXULTHREADS];

void ul_start_func(int a1) {
   0:	1101                	add	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	add	s0,sp,32
   a:	84aa                	mv	s1,a0
    printf("[.] started the thread function (tid = %d, a1 = %d) \n", get_current_tid(), a1);
   c:	00001097          	auipc	ra,0x1
  10:	856080e7          	jalr	-1962(ra) # 862 <get_current_tid>
  14:	85aa                	mv	a1,a0
  16:	8626                	mv	a2,s1
  18:	00001517          	auipc	a0,0x1
  1c:	bc850513          	add	a0,a0,-1080 # be0 <ulthread_context_switch+0x86>
  20:	00000097          	auipc	ra,0x0
  24:	6a4080e7          	jalr	1700(ra) # 6c4 <printf>

    /* Notify for a thread exit. */
    ulthread_destroy();
  28:	00001097          	auipc	ra,0x1
  2c:	ae4080e7          	jalr	-1308(ra) # b0c <ulthread_destroy>
}
  30:	60e2                	ld	ra,24(sp)
  32:	6442                	ld	s0,16(sp)
  34:	64a2                	ld	s1,8(sp)
  36:	6105                	add	sp,sp,32
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
  54:	10a080e7          	jalr	266(ra) # 15a <memset>

    /* Initialize the user-level threading library */
    ulthread_init(ROUNDROBIN);
  58:	4501                	li	a0,0
  5a:	00001097          	auipc	ra,0x1
  5e:	81e080e7          	jalr	-2018(ra) # 878 <ulthread_init>

    /* Create a user-level thread */
    uint64 args[6] = {1,1,1,1,0,0};
  62:	00001797          	auipc	a5,0x1
  66:	bfe78793          	add	a5,a5,-1026 # c60 <ulthread_context_switch+0x106>
  6a:	6388                	ld	a0,0(a5)
  6c:	678c                	ld	a1,8(a5)
  6e:	6b90                	ld	a2,16(a5)
  70:	6f94                	ld	a3,24(a5)
  72:	7398                	ld	a4,32(a5)
  74:	779c                	ld	a5,40(a5)
  76:	fca43023          	sd	a0,-64(s0)
  7a:	fcb43423          	sd	a1,-56(s0)
  7e:	fcc43823          	sd	a2,-48(s0)
  82:	fcd43c23          	sd	a3,-40(s0)
  86:	fee43023          	sd	a4,-32(s0)
  8a:	fef43423          	sd	a5,-24(s0)
    ulthread_create((uint64) ul_start_func, (uint64) stacks+PGSIZE, args, -1);
  8e:	56fd                	li	a3,-1
  90:	fc040613          	add	a2,s0,-64
  94:	00002597          	auipc	a1,0x2
  98:	f9c58593          	add	a1,a1,-100 # 2030 <stacks+0x1000>
  9c:	00000517          	auipc	a0,0x0
  a0:	f6450513          	add	a0,a0,-156 # 0 <ul_start_func>
  a4:	00001097          	auipc	ra,0x1
  a8:	826080e7          	jalr	-2010(ra) # 8ca <ulthread_create>

    /* Schedule all of the threads */
    ulthread_schedule();
  ac:	00001097          	auipc	ra,0x1
  b0:	8be080e7          	jalr	-1858(ra) # 96a <ulthread_schedule>

    printf("[*] User-Level Threading Test #3 (Arguments Checking) Complete.\n");
  b4:	00001517          	auipc	a0,0x1
  b8:	b6450513          	add	a0,a0,-1180 # c18 <ulthread_context_switch+0xbe>
  bc:	00000097          	auipc	ra,0x0
  c0:	608080e7          	jalr	1544(ra) # 6c4 <printf>
    return 0;
}
  c4:	4501                	li	a0,0
  c6:	70e2                	ld	ra,56(sp)
  c8:	7442                	ld	s0,48(sp)
  ca:	6121                	add	sp,sp,64
  cc:	8082                	ret

00000000000000ce <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  ce:	1141                	add	sp,sp,-16
  d0:	e406                	sd	ra,8(sp)
  d2:	e022                	sd	s0,0(sp)
  d4:	0800                	add	s0,sp,16
  extern int main();
  main();
  d6:	00000097          	auipc	ra,0x0
  da:	f64080e7          	jalr	-156(ra) # 3a <main>
  exit(0);
  de:	4501                	li	a0,0
  e0:	00000097          	auipc	ra,0x0
  e4:	274080e7          	jalr	628(ra) # 354 <exit>

00000000000000e8 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  e8:	1141                	add	sp,sp,-16
  ea:	e422                	sd	s0,8(sp)
  ec:	0800                	add	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ee:	87aa                	mv	a5,a0
  f0:	0585                	add	a1,a1,1
  f2:	0785                	add	a5,a5,1
  f4:	fff5c703          	lbu	a4,-1(a1)
  f8:	fee78fa3          	sb	a4,-1(a5)
  fc:	fb75                	bnez	a4,f0 <strcpy+0x8>
    ;
  return os;
}
  fe:	6422                	ld	s0,8(sp)
 100:	0141                	add	sp,sp,16
 102:	8082                	ret

0000000000000104 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 104:	1141                	add	sp,sp,-16
 106:	e422                	sd	s0,8(sp)
 108:	0800                	add	s0,sp,16
  while(*p && *p == *q)
 10a:	00054783          	lbu	a5,0(a0)
 10e:	cb91                	beqz	a5,122 <strcmp+0x1e>
 110:	0005c703          	lbu	a4,0(a1)
 114:	00f71763          	bne	a4,a5,122 <strcmp+0x1e>
    p++, q++;
 118:	0505                	add	a0,a0,1
 11a:	0585                	add	a1,a1,1
  while(*p && *p == *q)
 11c:	00054783          	lbu	a5,0(a0)
 120:	fbe5                	bnez	a5,110 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 122:	0005c503          	lbu	a0,0(a1)
}
 126:	40a7853b          	subw	a0,a5,a0
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	add	sp,sp,16
 12e:	8082                	ret

0000000000000130 <strlen>:

uint
strlen(const char *s)
{
 130:	1141                	add	sp,sp,-16
 132:	e422                	sd	s0,8(sp)
 134:	0800                	add	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 136:	00054783          	lbu	a5,0(a0)
 13a:	cf91                	beqz	a5,156 <strlen+0x26>
 13c:	0505                	add	a0,a0,1
 13e:	87aa                	mv	a5,a0
 140:	86be                	mv	a3,a5
 142:	0785                	add	a5,a5,1
 144:	fff7c703          	lbu	a4,-1(a5)
 148:	ff65                	bnez	a4,140 <strlen+0x10>
 14a:	40a6853b          	subw	a0,a3,a0
 14e:	2505                	addw	a0,a0,1
    ;
  return n;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	add	sp,sp,16
 154:	8082                	ret
  for(n = 0; s[n]; n++)
 156:	4501                	li	a0,0
 158:	bfe5                	j	150 <strlen+0x20>

000000000000015a <memset>:

void*
memset(void *dst, int c, uint n)
{
 15a:	1141                	add	sp,sp,-16
 15c:	e422                	sd	s0,8(sp)
 15e:	0800                	add	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 160:	ca19                	beqz	a2,176 <memset+0x1c>
 162:	87aa                	mv	a5,a0
 164:	1602                	sll	a2,a2,0x20
 166:	9201                	srl	a2,a2,0x20
 168:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 16c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 170:	0785                	add	a5,a5,1
 172:	fee79de3          	bne	a5,a4,16c <memset+0x12>
  }
  return dst;
}
 176:	6422                	ld	s0,8(sp)
 178:	0141                	add	sp,sp,16
 17a:	8082                	ret

000000000000017c <strchr>:

char*
strchr(const char *s, char c)
{
 17c:	1141                	add	sp,sp,-16
 17e:	e422                	sd	s0,8(sp)
 180:	0800                	add	s0,sp,16
  for(; *s; s++)
 182:	00054783          	lbu	a5,0(a0)
 186:	cb99                	beqz	a5,19c <strchr+0x20>
    if(*s == c)
 188:	00f58763          	beq	a1,a5,196 <strchr+0x1a>
  for(; *s; s++)
 18c:	0505                	add	a0,a0,1
 18e:	00054783          	lbu	a5,0(a0)
 192:	fbfd                	bnez	a5,188 <strchr+0xc>
      return (char*)s;
  return 0;
 194:	4501                	li	a0,0
}
 196:	6422                	ld	s0,8(sp)
 198:	0141                	add	sp,sp,16
 19a:	8082                	ret
  return 0;
 19c:	4501                	li	a0,0
 19e:	bfe5                	j	196 <strchr+0x1a>

00000000000001a0 <gets>:

char*
gets(char *buf, int max)
{
 1a0:	711d                	add	sp,sp,-96
 1a2:	ec86                	sd	ra,88(sp)
 1a4:	e8a2                	sd	s0,80(sp)
 1a6:	e4a6                	sd	s1,72(sp)
 1a8:	e0ca                	sd	s2,64(sp)
 1aa:	fc4e                	sd	s3,56(sp)
 1ac:	f852                	sd	s4,48(sp)
 1ae:	f456                	sd	s5,40(sp)
 1b0:	f05a                	sd	s6,32(sp)
 1b2:	ec5e                	sd	s7,24(sp)
 1b4:	1080                	add	s0,sp,96
 1b6:	8baa                	mv	s7,a0
 1b8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ba:	892a                	mv	s2,a0
 1bc:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1be:	4aa9                	li	s5,10
 1c0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1c2:	89a6                	mv	s3,s1
 1c4:	2485                	addw	s1,s1,1
 1c6:	0344d863          	bge	s1,s4,1f6 <gets+0x56>
    cc = read(0, &c, 1);
 1ca:	4605                	li	a2,1
 1cc:	faf40593          	add	a1,s0,-81
 1d0:	4501                	li	a0,0
 1d2:	00000097          	auipc	ra,0x0
 1d6:	19a080e7          	jalr	410(ra) # 36c <read>
    if(cc < 1)
 1da:	00a05e63          	blez	a0,1f6 <gets+0x56>
    buf[i++] = c;
 1de:	faf44783          	lbu	a5,-81(s0)
 1e2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1e6:	01578763          	beq	a5,s5,1f4 <gets+0x54>
 1ea:	0905                	add	s2,s2,1
 1ec:	fd679be3          	bne	a5,s6,1c2 <gets+0x22>
  for(i=0; i+1 < max; ){
 1f0:	89a6                	mv	s3,s1
 1f2:	a011                	j	1f6 <gets+0x56>
 1f4:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1f6:	99de                	add	s3,s3,s7
 1f8:	00098023          	sb	zero,0(s3)
  return buf;
}
 1fc:	855e                	mv	a0,s7
 1fe:	60e6                	ld	ra,88(sp)
 200:	6446                	ld	s0,80(sp)
 202:	64a6                	ld	s1,72(sp)
 204:	6906                	ld	s2,64(sp)
 206:	79e2                	ld	s3,56(sp)
 208:	7a42                	ld	s4,48(sp)
 20a:	7aa2                	ld	s5,40(sp)
 20c:	7b02                	ld	s6,32(sp)
 20e:	6be2                	ld	s7,24(sp)
 210:	6125                	add	sp,sp,96
 212:	8082                	ret

0000000000000214 <stat>:

int
stat(const char *n, struct stat *st)
{
 214:	1101                	add	sp,sp,-32
 216:	ec06                	sd	ra,24(sp)
 218:	e822                	sd	s0,16(sp)
 21a:	e426                	sd	s1,8(sp)
 21c:	e04a                	sd	s2,0(sp)
 21e:	1000                	add	s0,sp,32
 220:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 222:	4581                	li	a1,0
 224:	00000097          	auipc	ra,0x0
 228:	170080e7          	jalr	368(ra) # 394 <open>
  if(fd < 0)
 22c:	02054563          	bltz	a0,256 <stat+0x42>
 230:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 232:	85ca                	mv	a1,s2
 234:	00000097          	auipc	ra,0x0
 238:	178080e7          	jalr	376(ra) # 3ac <fstat>
 23c:	892a                	mv	s2,a0
  close(fd);
 23e:	8526                	mv	a0,s1
 240:	00000097          	auipc	ra,0x0
 244:	13c080e7          	jalr	316(ra) # 37c <close>
  return r;
}
 248:	854a                	mv	a0,s2
 24a:	60e2                	ld	ra,24(sp)
 24c:	6442                	ld	s0,16(sp)
 24e:	64a2                	ld	s1,8(sp)
 250:	6902                	ld	s2,0(sp)
 252:	6105                	add	sp,sp,32
 254:	8082                	ret
    return -1;
 256:	597d                	li	s2,-1
 258:	bfc5                	j	248 <stat+0x34>

000000000000025a <atoi>:

int
atoi(const char *s)
{
 25a:	1141                	add	sp,sp,-16
 25c:	e422                	sd	s0,8(sp)
 25e:	0800                	add	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 260:	00054683          	lbu	a3,0(a0)
 264:	fd06879b          	addw	a5,a3,-48
 268:	0ff7f793          	zext.b	a5,a5
 26c:	4625                	li	a2,9
 26e:	02f66863          	bltu	a2,a5,29e <atoi+0x44>
 272:	872a                	mv	a4,a0
  n = 0;
 274:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 276:	0705                	add	a4,a4,1
 278:	0025179b          	sllw	a5,a0,0x2
 27c:	9fa9                	addw	a5,a5,a0
 27e:	0017979b          	sllw	a5,a5,0x1
 282:	9fb5                	addw	a5,a5,a3
 284:	fd07851b          	addw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 288:	00074683          	lbu	a3,0(a4)
 28c:	fd06879b          	addw	a5,a3,-48
 290:	0ff7f793          	zext.b	a5,a5
 294:	fef671e3          	bgeu	a2,a5,276 <atoi+0x1c>
  return n;
}
 298:	6422                	ld	s0,8(sp)
 29a:	0141                	add	sp,sp,16
 29c:	8082                	ret
  n = 0;
 29e:	4501                	li	a0,0
 2a0:	bfe5                	j	298 <atoi+0x3e>

00000000000002a2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2a2:	1141                	add	sp,sp,-16
 2a4:	e422                	sd	s0,8(sp)
 2a6:	0800                	add	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a8:	02b57463          	bgeu	a0,a1,2d0 <memmove+0x2e>
    while(n-- > 0)
 2ac:	00c05f63          	blez	a2,2ca <memmove+0x28>
 2b0:	1602                	sll	a2,a2,0x20
 2b2:	9201                	srl	a2,a2,0x20
 2b4:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b8:	872a                	mv	a4,a0
      *dst++ = *src++;
 2ba:	0585                	add	a1,a1,1
 2bc:	0705                	add	a4,a4,1
 2be:	fff5c683          	lbu	a3,-1(a1)
 2c2:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c6:	fee79ae3          	bne	a5,a4,2ba <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2ca:	6422                	ld	s0,8(sp)
 2cc:	0141                	add	sp,sp,16
 2ce:	8082                	ret
    dst += n;
 2d0:	00c50733          	add	a4,a0,a2
    src += n;
 2d4:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d6:	fec05ae3          	blez	a2,2ca <memmove+0x28>
 2da:	fff6079b          	addw	a5,a2,-1 # 63fff <stacks+0x62fcf>
 2de:	1782                	sll	a5,a5,0x20
 2e0:	9381                	srl	a5,a5,0x20
 2e2:	fff7c793          	not	a5,a5
 2e6:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e8:	15fd                	add	a1,a1,-1
 2ea:	177d                	add	a4,a4,-1
 2ec:	0005c683          	lbu	a3,0(a1)
 2f0:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f4:	fee79ae3          	bne	a5,a4,2e8 <memmove+0x46>
 2f8:	bfc9                	j	2ca <memmove+0x28>

00000000000002fa <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2fa:	1141                	add	sp,sp,-16
 2fc:	e422                	sd	s0,8(sp)
 2fe:	0800                	add	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 300:	ca05                	beqz	a2,330 <memcmp+0x36>
 302:	fff6069b          	addw	a3,a2,-1
 306:	1682                	sll	a3,a3,0x20
 308:	9281                	srl	a3,a3,0x20
 30a:	0685                	add	a3,a3,1
 30c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30e:	00054783          	lbu	a5,0(a0)
 312:	0005c703          	lbu	a4,0(a1)
 316:	00e79863          	bne	a5,a4,326 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 31a:	0505                	add	a0,a0,1
    p2++;
 31c:	0585                	add	a1,a1,1
  while (n-- > 0) {
 31e:	fed518e3          	bne	a0,a3,30e <memcmp+0x14>
  }
  return 0;
 322:	4501                	li	a0,0
 324:	a019                	j	32a <memcmp+0x30>
      return *p1 - *p2;
 326:	40e7853b          	subw	a0,a5,a4
}
 32a:	6422                	ld	s0,8(sp)
 32c:	0141                	add	sp,sp,16
 32e:	8082                	ret
  return 0;
 330:	4501                	li	a0,0
 332:	bfe5                	j	32a <memcmp+0x30>

0000000000000334 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 334:	1141                	add	sp,sp,-16
 336:	e406                	sd	ra,8(sp)
 338:	e022                	sd	s0,0(sp)
 33a:	0800                	add	s0,sp,16
  return memmove(dst, src, n);
 33c:	00000097          	auipc	ra,0x0
 340:	f66080e7          	jalr	-154(ra) # 2a2 <memmove>
}
 344:	60a2                	ld	ra,8(sp)
 346:	6402                	ld	s0,0(sp)
 348:	0141                	add	sp,sp,16
 34a:	8082                	ret

000000000000034c <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 34c:	4885                	li	a7,1
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <exit>:
.global exit
exit:
 li a7, SYS_exit
 354:	4889                	li	a7,2
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <wait>:
.global wait
wait:
 li a7, SYS_wait
 35c:	488d                	li	a7,3
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 364:	4891                	li	a7,4
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <read>:
.global read
read:
 li a7, SYS_read
 36c:	4895                	li	a7,5
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <write>:
.global write
write:
 li a7, SYS_write
 374:	48c1                	li	a7,16
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <close>:
.global close
close:
 li a7, SYS_close
 37c:	48d5                	li	a7,21
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <kill>:
.global kill
kill:
 li a7, SYS_kill
 384:	4899                	li	a7,6
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <exec>:
.global exec
exec:
 li a7, SYS_exec
 38c:	489d                	li	a7,7
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <open>:
.global open
open:
 li a7, SYS_open
 394:	48bd                	li	a7,15
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 39c:	48c5                	li	a7,17
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 3a4:	48c9                	li	a7,18
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3ac:	48a1                	li	a7,8
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <link>:
.global link
link:
 li a7, SYS_link
 3b4:	48cd                	li	a7,19
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3bc:	48d1                	li	a7,20
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3c4:	48a5                	li	a7,9
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <dup>:
.global dup
dup:
 li a7, SYS_dup
 3cc:	48a9                	li	a7,10
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3d4:	48ad                	li	a7,11
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3dc:	48b1                	li	a7,12
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3e4:	48b5                	li	a7,13
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3ec:	48b9                	li	a7,14
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <ctime>:
.global ctime
ctime:
 li a7, SYS_ctime
 3f4:	48d9                	li	a7,22
 ecall
 3f6:	00000073          	ecall
 ret
 3fa:	8082                	ret

00000000000003fc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3fc:	1101                	add	sp,sp,-32
 3fe:	ec06                	sd	ra,24(sp)
 400:	e822                	sd	s0,16(sp)
 402:	1000                	add	s0,sp,32
 404:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 408:	4605                	li	a2,1
 40a:	fef40593          	add	a1,s0,-17
 40e:	00000097          	auipc	ra,0x0
 412:	f66080e7          	jalr	-154(ra) # 374 <write>
}
 416:	60e2                	ld	ra,24(sp)
 418:	6442                	ld	s0,16(sp)
 41a:	6105                	add	sp,sp,32
 41c:	8082                	ret

000000000000041e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 41e:	7139                	add	sp,sp,-64
 420:	fc06                	sd	ra,56(sp)
 422:	f822                	sd	s0,48(sp)
 424:	f426                	sd	s1,40(sp)
 426:	f04a                	sd	s2,32(sp)
 428:	ec4e                	sd	s3,24(sp)
 42a:	0080                	add	s0,sp,64
 42c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 42e:	c299                	beqz	a3,434 <printint+0x16>
 430:	0805c963          	bltz	a1,4c2 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 434:	2581                	sext.w	a1,a1
  neg = 0;
 436:	4881                	li	a7,0
 438:	fc040693          	add	a3,s0,-64
  }

  i = 0;
 43c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 43e:	2601                	sext.w	a2,a2
 440:	00001517          	auipc	a0,0x1
 444:	8b050513          	add	a0,a0,-1872 # cf0 <digits>
 448:	883a                	mv	a6,a4
 44a:	2705                	addw	a4,a4,1
 44c:	02c5f7bb          	remuw	a5,a1,a2
 450:	1782                	sll	a5,a5,0x20
 452:	9381                	srl	a5,a5,0x20
 454:	97aa                	add	a5,a5,a0
 456:	0007c783          	lbu	a5,0(a5)
 45a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 45e:	0005879b          	sext.w	a5,a1
 462:	02c5d5bb          	divuw	a1,a1,a2
 466:	0685                	add	a3,a3,1
 468:	fec7f0e3          	bgeu	a5,a2,448 <printint+0x2a>
  if(neg)
 46c:	00088c63          	beqz	a7,484 <printint+0x66>
    buf[i++] = '-';
 470:	fd070793          	add	a5,a4,-48
 474:	00878733          	add	a4,a5,s0
 478:	02d00793          	li	a5,45
 47c:	fef70823          	sb	a5,-16(a4)
 480:	0028071b          	addw	a4,a6,2

  while(--i >= 0)
 484:	02e05863          	blez	a4,4b4 <printint+0x96>
 488:	fc040793          	add	a5,s0,-64
 48c:	00e78933          	add	s2,a5,a4
 490:	fff78993          	add	s3,a5,-1
 494:	99ba                	add	s3,s3,a4
 496:	377d                	addw	a4,a4,-1
 498:	1702                	sll	a4,a4,0x20
 49a:	9301                	srl	a4,a4,0x20
 49c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 4a0:	fff94583          	lbu	a1,-1(s2)
 4a4:	8526                	mv	a0,s1
 4a6:	00000097          	auipc	ra,0x0
 4aa:	f56080e7          	jalr	-170(ra) # 3fc <putc>
  while(--i >= 0)
 4ae:	197d                	add	s2,s2,-1
 4b0:	ff3918e3          	bne	s2,s3,4a0 <printint+0x82>
}
 4b4:	70e2                	ld	ra,56(sp)
 4b6:	7442                	ld	s0,48(sp)
 4b8:	74a2                	ld	s1,40(sp)
 4ba:	7902                	ld	s2,32(sp)
 4bc:	69e2                	ld	s3,24(sp)
 4be:	6121                	add	sp,sp,64
 4c0:	8082                	ret
    x = -xx;
 4c2:	40b005bb          	negw	a1,a1
    neg = 1;
 4c6:	4885                	li	a7,1
    x = -xx;
 4c8:	bf85                	j	438 <printint+0x1a>

00000000000004ca <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ca:	715d                	add	sp,sp,-80
 4cc:	e486                	sd	ra,72(sp)
 4ce:	e0a2                	sd	s0,64(sp)
 4d0:	fc26                	sd	s1,56(sp)
 4d2:	f84a                	sd	s2,48(sp)
 4d4:	f44e                	sd	s3,40(sp)
 4d6:	f052                	sd	s4,32(sp)
 4d8:	ec56                	sd	s5,24(sp)
 4da:	e85a                	sd	s6,16(sp)
 4dc:	e45e                	sd	s7,8(sp)
 4de:	e062                	sd	s8,0(sp)
 4e0:	0880                	add	s0,sp,80
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4e2:	0005c903          	lbu	s2,0(a1)
 4e6:	18090c63          	beqz	s2,67e <vprintf+0x1b4>
 4ea:	8aaa                	mv	s5,a0
 4ec:	8bb2                	mv	s7,a2
 4ee:	00158493          	add	s1,a1,1
  state = 0;
 4f2:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 4f4:	02500a13          	li	s4,37
 4f8:	4b55                	li	s6,21
 4fa:	a839                	j	518 <vprintf+0x4e>
        putc(fd, c);
 4fc:	85ca                	mv	a1,s2
 4fe:	8556                	mv	a0,s5
 500:	00000097          	auipc	ra,0x0
 504:	efc080e7          	jalr	-260(ra) # 3fc <putc>
 508:	a019                	j	50e <vprintf+0x44>
    } else if(state == '%'){
 50a:	01498d63          	beq	s3,s4,524 <vprintf+0x5a>
  for(i = 0; fmt[i]; i++){
 50e:	0485                	add	s1,s1,1
 510:	fff4c903          	lbu	s2,-1(s1)
 514:	16090563          	beqz	s2,67e <vprintf+0x1b4>
    if(state == 0){
 518:	fe0999e3          	bnez	s3,50a <vprintf+0x40>
      if(c == '%'){
 51c:	ff4910e3          	bne	s2,s4,4fc <vprintf+0x32>
        state = '%';
 520:	89d2                	mv	s3,s4
 522:	b7f5                	j	50e <vprintf+0x44>
      if(c == 'd'){
 524:	13490263          	beq	s2,s4,648 <vprintf+0x17e>
 528:	f9d9079b          	addw	a5,s2,-99
 52c:	0ff7f793          	zext.b	a5,a5
 530:	12fb6563          	bltu	s6,a5,65a <vprintf+0x190>
 534:	f9d9079b          	addw	a5,s2,-99
 538:	0ff7f713          	zext.b	a4,a5
 53c:	10eb6f63          	bltu	s6,a4,65a <vprintf+0x190>
 540:	00271793          	sll	a5,a4,0x2
 544:	00000717          	auipc	a4,0x0
 548:	75470713          	add	a4,a4,1876 # c98 <ulthread_context_switch+0x13e>
 54c:	97ba                	add	a5,a5,a4
 54e:	439c                	lw	a5,0(a5)
 550:	97ba                	add	a5,a5,a4
 552:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 554:	008b8913          	add	s2,s7,8
 558:	4685                	li	a3,1
 55a:	4629                	li	a2,10
 55c:	000ba583          	lw	a1,0(s7)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	ebc080e7          	jalr	-324(ra) # 41e <printint>
 56a:	8bca                	mv	s7,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 56c:	4981                	li	s3,0
 56e:	b745                	j	50e <vprintf+0x44>
        printint(fd, va_arg(ap, uint64), 10, 0);
 570:	008b8913          	add	s2,s7,8
 574:	4681                	li	a3,0
 576:	4629                	li	a2,10
 578:	000ba583          	lw	a1,0(s7)
 57c:	8556                	mv	a0,s5
 57e:	00000097          	auipc	ra,0x0
 582:	ea0080e7          	jalr	-352(ra) # 41e <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	b751                	j	50e <vprintf+0x44>
        printint(fd, va_arg(ap, int), 16, 0);
 58c:	008b8913          	add	s2,s7,8
 590:	4681                	li	a3,0
 592:	4641                	li	a2,16
 594:	000ba583          	lw	a1,0(s7)
 598:	8556                	mv	a0,s5
 59a:	00000097          	auipc	ra,0x0
 59e:	e84080e7          	jalr	-380(ra) # 41e <printint>
 5a2:	8bca                	mv	s7,s2
      state = 0;
 5a4:	4981                	li	s3,0
 5a6:	b7a5                	j	50e <vprintf+0x44>
        printptr(fd, va_arg(ap, uint64));
 5a8:	008b8c13          	add	s8,s7,8
 5ac:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 5b0:	03000593          	li	a1,48
 5b4:	8556                	mv	a0,s5
 5b6:	00000097          	auipc	ra,0x0
 5ba:	e46080e7          	jalr	-442(ra) # 3fc <putc>
  putc(fd, 'x');
 5be:	07800593          	li	a1,120
 5c2:	8556                	mv	a0,s5
 5c4:	00000097          	auipc	ra,0x0
 5c8:	e38080e7          	jalr	-456(ra) # 3fc <putc>
 5cc:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5ce:	00000b97          	auipc	s7,0x0
 5d2:	722b8b93          	add	s7,s7,1826 # cf0 <digits>
 5d6:	03c9d793          	srl	a5,s3,0x3c
 5da:	97de                	add	a5,a5,s7
 5dc:	0007c583          	lbu	a1,0(a5)
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e1a080e7          	jalr	-486(ra) # 3fc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 5ea:	0992                	sll	s3,s3,0x4
 5ec:	397d                	addw	s2,s2,-1
 5ee:	fe0914e3          	bnez	s2,5d6 <vprintf+0x10c>
        printptr(fd, va_arg(ap, uint64));
 5f2:	8be2                	mv	s7,s8
      state = 0;
 5f4:	4981                	li	s3,0
 5f6:	bf21                	j	50e <vprintf+0x44>
        s = va_arg(ap, char*);
 5f8:	008b8993          	add	s3,s7,8
 5fc:	000bb903          	ld	s2,0(s7)
        if(s == 0)
 600:	02090163          	beqz	s2,622 <vprintf+0x158>
        while(*s != 0){
 604:	00094583          	lbu	a1,0(s2)
 608:	c9a5                	beqz	a1,678 <vprintf+0x1ae>
          putc(fd, *s);
 60a:	8556                	mv	a0,s5
 60c:	00000097          	auipc	ra,0x0
 610:	df0080e7          	jalr	-528(ra) # 3fc <putc>
          s++;
 614:	0905                	add	s2,s2,1
        while(*s != 0){
 616:	00094583          	lbu	a1,0(s2)
 61a:	f9e5                	bnez	a1,60a <vprintf+0x140>
        s = va_arg(ap, char*);
 61c:	8bce                	mv	s7,s3
      state = 0;
 61e:	4981                	li	s3,0
 620:	b5fd                	j	50e <vprintf+0x44>
          s = "(null)";
 622:	00000917          	auipc	s2,0x0
 626:	66e90913          	add	s2,s2,1646 # c90 <ulthread_context_switch+0x136>
        while(*s != 0){
 62a:	02800593          	li	a1,40
 62e:	bff1                	j	60a <vprintf+0x140>
        putc(fd, va_arg(ap, uint));
 630:	008b8913          	add	s2,s7,8
 634:	000bc583          	lbu	a1,0(s7)
 638:	8556                	mv	a0,s5
 63a:	00000097          	auipc	ra,0x0
 63e:	dc2080e7          	jalr	-574(ra) # 3fc <putc>
 642:	8bca                	mv	s7,s2
      state = 0;
 644:	4981                	li	s3,0
 646:	b5e1                	j	50e <vprintf+0x44>
        putc(fd, c);
 648:	02500593          	li	a1,37
 64c:	8556                	mv	a0,s5
 64e:	00000097          	auipc	ra,0x0
 652:	dae080e7          	jalr	-594(ra) # 3fc <putc>
      state = 0;
 656:	4981                	li	s3,0
 658:	bd5d                	j	50e <vprintf+0x44>
        putc(fd, '%');
 65a:	02500593          	li	a1,37
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	d9c080e7          	jalr	-612(ra) # 3fc <putc>
        putc(fd, c);
 668:	85ca                	mv	a1,s2
 66a:	8556                	mv	a0,s5
 66c:	00000097          	auipc	ra,0x0
 670:	d90080e7          	jalr	-624(ra) # 3fc <putc>
      state = 0;
 674:	4981                	li	s3,0
 676:	bd61                	j	50e <vprintf+0x44>
        s = va_arg(ap, char*);
 678:	8bce                	mv	s7,s3
      state = 0;
 67a:	4981                	li	s3,0
 67c:	bd49                	j	50e <vprintf+0x44>
    }
  }
}
 67e:	60a6                	ld	ra,72(sp)
 680:	6406                	ld	s0,64(sp)
 682:	74e2                	ld	s1,56(sp)
 684:	7942                	ld	s2,48(sp)
 686:	79a2                	ld	s3,40(sp)
 688:	7a02                	ld	s4,32(sp)
 68a:	6ae2                	ld	s5,24(sp)
 68c:	6b42                	ld	s6,16(sp)
 68e:	6ba2                	ld	s7,8(sp)
 690:	6c02                	ld	s8,0(sp)
 692:	6161                	add	sp,sp,80
 694:	8082                	ret

0000000000000696 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 696:	715d                	add	sp,sp,-80
 698:	ec06                	sd	ra,24(sp)
 69a:	e822                	sd	s0,16(sp)
 69c:	1000                	add	s0,sp,32
 69e:	e010                	sd	a2,0(s0)
 6a0:	e414                	sd	a3,8(s0)
 6a2:	e818                	sd	a4,16(s0)
 6a4:	ec1c                	sd	a5,24(s0)
 6a6:	03043023          	sd	a6,32(s0)
 6aa:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 6ae:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 6b2:	8622                	mv	a2,s0
 6b4:	00000097          	auipc	ra,0x0
 6b8:	e16080e7          	jalr	-490(ra) # 4ca <vprintf>
}
 6bc:	60e2                	ld	ra,24(sp)
 6be:	6442                	ld	s0,16(sp)
 6c0:	6161                	add	sp,sp,80
 6c2:	8082                	ret

00000000000006c4 <printf>:

void
printf(const char *fmt, ...)
{
 6c4:	711d                	add	sp,sp,-96
 6c6:	ec06                	sd	ra,24(sp)
 6c8:	e822                	sd	s0,16(sp)
 6ca:	1000                	add	s0,sp,32
 6cc:	e40c                	sd	a1,8(s0)
 6ce:	e810                	sd	a2,16(s0)
 6d0:	ec14                	sd	a3,24(s0)
 6d2:	f018                	sd	a4,32(s0)
 6d4:	f41c                	sd	a5,40(s0)
 6d6:	03043823          	sd	a6,48(s0)
 6da:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 6de:	00840613          	add	a2,s0,8
 6e2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 6e6:	85aa                	mv	a1,a0
 6e8:	4505                	li	a0,1
 6ea:	00000097          	auipc	ra,0x0
 6ee:	de0080e7          	jalr	-544(ra) # 4ca <vprintf>
}
 6f2:	60e2                	ld	ra,24(sp)
 6f4:	6442                	ld	s0,16(sp)
 6f6:	6125                	add	sp,sp,96
 6f8:	8082                	ret

00000000000006fa <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 6fa:	1141                	add	sp,sp,-16
 6fc:	e422                	sd	s0,8(sp)
 6fe:	0800                	add	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 700:	ff050693          	add	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 704:	00001797          	auipc	a5,0x1
 708:	90c7b783          	ld	a5,-1780(a5) # 1010 <freep>
 70c:	a02d                	j	736 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 70e:	4618                	lw	a4,8(a2)
 710:	9f2d                	addw	a4,a4,a1
 712:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 716:	6398                	ld	a4,0(a5)
 718:	6310                	ld	a2,0(a4)
 71a:	a83d                	j	758 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 71c:	ff852703          	lw	a4,-8(a0)
 720:	9f31                	addw	a4,a4,a2
 722:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 724:	ff053683          	ld	a3,-16(a0)
 728:	a091                	j	76c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 72a:	6398                	ld	a4,0(a5)
 72c:	00e7e463          	bltu	a5,a4,734 <free+0x3a>
 730:	00e6ea63          	bltu	a3,a4,744 <free+0x4a>
{
 734:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 736:	fed7fae3          	bgeu	a5,a3,72a <free+0x30>
 73a:	6398                	ld	a4,0(a5)
 73c:	00e6e463          	bltu	a3,a4,744 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 740:	fee7eae3          	bltu	a5,a4,734 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 744:	ff852583          	lw	a1,-8(a0)
 748:	6390                	ld	a2,0(a5)
 74a:	02059813          	sll	a6,a1,0x20
 74e:	01c85713          	srl	a4,a6,0x1c
 752:	9736                	add	a4,a4,a3
 754:	fae60de3          	beq	a2,a4,70e <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 758:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 75c:	4790                	lw	a2,8(a5)
 75e:	02061593          	sll	a1,a2,0x20
 762:	01c5d713          	srl	a4,a1,0x1c
 766:	973e                	add	a4,a4,a5
 768:	fae68ae3          	beq	a3,a4,71c <free+0x22>
    p->s.ptr = bp->s.ptr;
 76c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 76e:	00001717          	auipc	a4,0x1
 772:	8af73123          	sd	a5,-1886(a4) # 1010 <freep>
}
 776:	6422                	ld	s0,8(sp)
 778:	0141                	add	sp,sp,16
 77a:	8082                	ret

000000000000077c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 77c:	7139                	add	sp,sp,-64
 77e:	fc06                	sd	ra,56(sp)
 780:	f822                	sd	s0,48(sp)
 782:	f426                	sd	s1,40(sp)
 784:	f04a                	sd	s2,32(sp)
 786:	ec4e                	sd	s3,24(sp)
 788:	e852                	sd	s4,16(sp)
 78a:	e456                	sd	s5,8(sp)
 78c:	e05a                	sd	s6,0(sp)
 78e:	0080                	add	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 790:	02051493          	sll	s1,a0,0x20
 794:	9081                	srl	s1,s1,0x20
 796:	04bd                	add	s1,s1,15
 798:	8091                	srl	s1,s1,0x4
 79a:	0014899b          	addw	s3,s1,1
 79e:	0485                	add	s1,s1,1
  if((prevp = freep) == 0){
 7a0:	00001517          	auipc	a0,0x1
 7a4:	87053503          	ld	a0,-1936(a0) # 1010 <freep>
 7a8:	c515                	beqz	a0,7d4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7aa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7ac:	4798                	lw	a4,8(a5)
 7ae:	02977f63          	bgeu	a4,s1,7ec <malloc+0x70>
  if(nu < 4096)
 7b2:	8a4e                	mv	s4,s3
 7b4:	0009871b          	sext.w	a4,s3
 7b8:	6685                	lui	a3,0x1
 7ba:	00d77363          	bgeu	a4,a3,7c0 <malloc+0x44>
 7be:	6a05                	lui	s4,0x1
 7c0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 7c4:	004a1a1b          	sllw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 7c8:	00001917          	auipc	s2,0x1
 7cc:	84890913          	add	s2,s2,-1976 # 1010 <freep>
  if(p == (char*)-1)
 7d0:	5afd                	li	s5,-1
 7d2:	a895                	j	846 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 7d4:	00065797          	auipc	a5,0x65
 7d8:	85c78793          	add	a5,a5,-1956 # 65030 <base>
 7dc:	00001717          	auipc	a4,0x1
 7e0:	82f73a23          	sd	a5,-1996(a4) # 1010 <freep>
 7e4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 7e6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 7ea:	b7e1                	j	7b2 <malloc+0x36>
      if(p->s.size == nunits)
 7ec:	02e48c63          	beq	s1,a4,824 <malloc+0xa8>
        p->s.size -= nunits;
 7f0:	4137073b          	subw	a4,a4,s3
 7f4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 7f6:	02071693          	sll	a3,a4,0x20
 7fa:	01c6d713          	srl	a4,a3,0x1c
 7fe:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 800:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 804:	00001717          	auipc	a4,0x1
 808:	80a73623          	sd	a0,-2036(a4) # 1010 <freep>
      return (void*)(p + 1);
 80c:	01078513          	add	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 810:	70e2                	ld	ra,56(sp)
 812:	7442                	ld	s0,48(sp)
 814:	74a2                	ld	s1,40(sp)
 816:	7902                	ld	s2,32(sp)
 818:	69e2                	ld	s3,24(sp)
 81a:	6a42                	ld	s4,16(sp)
 81c:	6aa2                	ld	s5,8(sp)
 81e:	6b02                	ld	s6,0(sp)
 820:	6121                	add	sp,sp,64
 822:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 824:	6398                	ld	a4,0(a5)
 826:	e118                	sd	a4,0(a0)
 828:	bff1                	j	804 <malloc+0x88>
  hp->s.size = nu;
 82a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 82e:	0541                	add	a0,a0,16
 830:	00000097          	auipc	ra,0x0
 834:	eca080e7          	jalr	-310(ra) # 6fa <free>
  return freep;
 838:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 83c:	d971                	beqz	a0,810 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 83e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 840:	4798                	lw	a4,8(a5)
 842:	fa9775e3          	bgeu	a4,s1,7ec <malloc+0x70>
    if(p == freep)
 846:	00093703          	ld	a4,0(s2)
 84a:	853e                	mv	a0,a5
 84c:	fef719e3          	bne	a4,a5,83e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 850:	8552                	mv	a0,s4
 852:	00000097          	auipc	ra,0x0
 856:	b8a080e7          	jalr	-1142(ra) # 3dc <sbrk>
  if(p == (char*)-1)
 85a:	fd5518e3          	bne	a0,s5,82a <malloc+0xae>
        return 0;
 85e:	4501                	li	a0,0
 860:	bf45                	j	810 <malloc+0x94>

0000000000000862 <get_current_tid>:
enum ulthread_scheduling_algorithm scheduling_algorithm;

int prev_tid = 0;

/* Get thread ID */
int get_current_tid(void) {
 862:	1141                	add	sp,sp,-16
 864:	e422                	sd	s0,8(sp)
 866:	0800                	add	s0,sp,16
    return current_thread->tid;
}
 868:	00000797          	auipc	a5,0x0
 86c:	7b87b783          	ld	a5,1976(a5) # 1020 <current_thread>
 870:	4388                	lw	a0,0(a5)
 872:	6422                	ld	s0,8(sp)
 874:	0141                	add	sp,sp,16
 876:	8082                	ret

0000000000000878 <ulthread_init>:

/* Thread initialization */
void ulthread_init(int schedalgo) {
 878:	1141                	add	sp,sp,-16
 87a:	e422                	sd	s0,8(sp)
 87c:	0800                	add	s0,sp,16

    struct ulthread *t;
    int i = 0;
 87e:	4681                	li	a3,0
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 1 to MAXULTHREADS
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 880:	00064797          	auipc	a5,0x64
 884:	7c078793          	add	a5,a5,1984 # 65040 <ulthread>
 888:	00069617          	auipc	a2,0x69
 88c:	5d860613          	add	a2,a2,1496 # 69e60 <ulthread+0x4e20>
        t->state = FREE;
 890:	0007a423          	sw	zero,8(a5)
        t->tid = i++;
 894:	c394                	sw	a3,0(a5)
 896:	2685                	addw	a3,a3,1 # 1001 <scheduler_thread+0x1>
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
 898:	0c878793          	add	a5,a5,200
 89c:	fec79ae3          	bne	a5,a2,890 <ulthread_init+0x18>
    }
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    scheduler_thread->state = RUNNABLE;
 8a0:	00000797          	auipc	a5,0x0
 8a4:	76078793          	add	a5,a5,1888 # 1000 <scheduler_thread>
 8a8:	6398                	ld	a4,0(a5)
 8aa:	4685                	li	a3,1
 8ac:	c714                	sw	a3,8(a4)
    scheduler_thread->tid = 0;
 8ae:	00072023          	sw	zero,0(a4)
    // Set the current thread to the scheduler thread
    current_thread = scheduler_thread;
 8b2:	639c                	ld	a5,0(a5)
 8b4:	00000717          	auipc	a4,0x0
 8b8:	76f73623          	sd	a5,1900(a4) # 1020 <current_thread>

    scheduling_algorithm = schedalgo;
 8bc:	00000797          	auipc	a5,0x0
 8c0:	76a7a023          	sw	a0,1888(a5) # 101c <scheduling_algorithm>
}
 8c4:	6422                	ld	s0,8(sp)
 8c6:	0141                	add	sp,sp,16
 8c8:	8082                	ret

00000000000008ca <ulthread_create>:

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
 8ca:	7179                	add	sp,sp,-48
 8cc:	f406                	sd	ra,40(sp)
 8ce:	f022                	sd	s0,32(sp)
 8d0:	ec26                	sd	s1,24(sp)
 8d2:	e84a                	sd	s2,16(sp)
 8d4:	e44e                	sd	s3,8(sp)
 8d6:	e052                	sd	s4,0(sp)
 8d8:	1800                	add	s0,sp,48
 8da:	892a                	mv	s2,a0
 8dc:	89ae                	mv	s3,a1
 8de:	8a36                	mv	s4,a3

    struct ulthread *t;

    // Find a free thread slot and initialize it
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 8e0:	00065497          	auipc	s1,0x65
 8e4:	82848493          	add	s1,s1,-2008 # 65108 <ulthread+0xc8>
 8e8:	00069717          	auipc	a4,0x69
 8ec:	57870713          	add	a4,a4,1400 # 69e60 <ulthread+0x4e20>
        if(t->state == FREE){
 8f0:	449c                	lw	a5,8(s1)
 8f2:	c799                	beqz	a5,900 <ulthread_create+0x36>
    for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 8f4:	0c848493          	add	s1,s1,200
 8f8:	fee49ce3          	bne	s1,a4,8f0 <ulthread_create+0x26>
            t->priority = priority;
            break;
        }
    }
    if(t == &ulthread[MAXULTHREADS]){
        return false;
 8fc:	4501                	li	a0,0
 8fe:	a8a1                	j	956 <ulthread_create+0x8c>
            t->state = RUNNABLE;
 900:	4785                	li	a5,1
 902:	c49c                	sw	a5,8(s1)
            t->context.ra = start;
 904:	0324b423          	sd	s2,40(s1)
            t->context.sp = stack;
 908:	0334b823          	sd	s3,48(s1)
            t->context.s0 = args[0];
 90c:	621c                	ld	a5,0(a2)
 90e:	fc9c                	sd	a5,56(s1)
            t->context.s1 = args[1];
 910:	661c                	ld	a5,8(a2)
 912:	e0bc                	sd	a5,64(s1)
            t->context.s2 = args[2];
 914:	6a1c                	ld	a5,16(a2)
 916:	e4bc                	sd	a5,72(s1)
            t->context.s3 = args[3];
 918:	6e1c                	ld	a5,24(a2)
 91a:	e8bc                	sd	a5,80(s1)
            t->context.s4 = args[4];
 91c:	721c                	ld	a5,32(a2)
 91e:	ecbc                	sd	a5,88(s1)
            t->context.s5 = args[5];
 920:	761c                	ld	a5,40(a2)
 922:	f0bc                	sd	a5,96(s1)
            t->ctime = ctime();
 924:	00000097          	auipc	ra,0x0
 928:	ad0080e7          	jalr	-1328(ra) # 3f4 <ctime>
 92c:	f088                	sd	a0,32(s1)
            t->priority = priority;
 92e:	0144a223          	sw	s4,4(s1)
    if(t == &ulthread[MAXULTHREADS]){
 932:	00069797          	auipc	a5,0x69
 936:	52e78793          	add	a5,a5,1326 # 69e60 <ulthread+0x4e20>
 93a:	02f48663          	beq	s1,a5,966 <ulthread_create+0x9c>
    }

    // current_thread = t;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", t->tid, start, stack);
 93e:	86ce                	mv	a3,s3
 940:	864a                	mv	a2,s2
 942:	408c                	lw	a1,0(s1)
 944:	00000517          	auipc	a0,0x0
 948:	3c450513          	add	a0,a0,964 # d08 <digits+0x18>
 94c:	00000097          	auipc	ra,0x0
 950:	d78080e7          	jalr	-648(ra) # 6c4 <printf>

    return true;
 954:	4505                	li	a0,1
}
 956:	70a2                	ld	ra,40(sp)
 958:	7402                	ld	s0,32(sp)
 95a:	64e2                	ld	s1,24(sp)
 95c:	6942                	ld	s2,16(sp)
 95e:	69a2                	ld	s3,8(sp)
 960:	6a02                	ld	s4,0(sp)
 962:	6145                	add	sp,sp,48
 964:	8082                	ret
        return false;
 966:	4501                	li	a0,0
 968:	b7fd                	j	956 <ulthread_create+0x8c>

000000000000096a <ulthread_schedule>:

/* Thread scheduler */
void ulthread_schedule(void) {
 96a:	715d                	add	sp,sp,-80
 96c:	e486                	sd	ra,72(sp)
 96e:	e0a2                	sd	s0,64(sp)
 970:	fc26                	sd	s1,56(sp)
 972:	f84a                	sd	s2,48(sp)
 974:	f44e                	sd	s3,40(sp)
 976:	f052                	sd	s4,32(sp)
 978:	ec56                	sd	s5,24(sp)
 97a:	e85a                	sd	s6,16(sp)
 97c:	e45e                	sd	s7,8(sp)
 97e:	e062                	sd	s8,0(sp)
 980:	0880                	add	s0,sp,80

    current_thread = scheduler_thread;
 982:	00000797          	auipc	a5,0x0
 986:	67e7b783          	ld	a5,1662(a5) # 1000 <scheduler_thread>
 98a:	00000717          	auipc	a4,0x0
 98e:	68f73b23          	sd	a5,1686(a4) # 1020 <current_thread>

        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){

            // printf("t->tid: %d\n", t->tid);
            
            if(scheduling_algorithm == 0){
 992:	00000917          	auipc	s2,0x0
 996:	68a90913          	add	s2,s2,1674 # 101c <scheduling_algorithm>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 99a:	00069497          	auipc	s1,0x69
 99e:	4c648493          	add	s1,s1,1222 # 69e60 <ulthread+0x4e20>
                }
            }
        
            if(t != 0){
                
                current_thread = t;
 9a2:	00000a97          	auipc	s5,0x0
 9a6:	67ea8a93          	add	s5,s5,1662 # 1020 <current_thread>

                flag = 1;

                /* Add this statement to denote which thread-id is being scheduled next */
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 9aa:	00000a17          	auipc	s4,0x0
 9ae:	386a0a13          	add	s4,s4,902 # d30 <digits+0x40>

                // Switch between thread contexts from the scheduler thread to the new thread
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 9b2:	00000997          	auipc	s3,0x0
 9b6:	64e98993          	add	s3,s3,1614 # 1000 <scheduler_thread>
void ulthread_schedule(void) {
 9ba:	4701                	li	a4,0
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 9bc:	00064b17          	auipc	s6,0x64
 9c0:	74cb0b13          	add	s6,s6,1868 # 65108 <ulthread+0xc8>
                flag = 1;
 9c4:	4b85                	li	s7,1
            else if(scheduling_algorithm == 2){
 9c6:	4c09                	li	s8,2
 9c8:	a83d                	j	a06 <ulthread_schedule+0x9c>
            else if(scheduling_algorithm == 1){
 9ca:	07778163          	beq	a5,s7,a2c <ulthread_schedule+0xc2>
            else if(scheduling_algorithm == 2){
 9ce:	09878a63          	beq	a5,s8,a62 <ulthread_schedule+0xf8>
            if(t != 0){
 9d2:	040b0163          	beqz	s6,a14 <ulthread_schedule+0xaa>
                current_thread = t;
 9d6:	016ab023          	sd	s6,0(s5)
                printf("[*] ultschedule (next tid: %d)\n", get_current_tid());
 9da:	000b2583          	lw	a1,0(s6)
 9de:	8552                	mv	a0,s4
 9e0:	00000097          	auipc	ra,0x0
 9e4:	ce4080e7          	jalr	-796(ra) # 6c4 <printf>
                ulthread_context_switch(&scheduler_thread->context, &t->context);
 9e8:	0009b503          	ld	a0,0(s3)
 9ec:	028b0593          	add	a1,s6,40
 9f0:	02850513          	add	a0,a0,40
 9f4:	00000097          	auipc	ra,0x0
 9f8:	166080e7          	jalr	358(ra) # b5a <ulthread_context_switch>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 9fc:	00064b17          	auipc	s6,0x64
 a00:	7d4b0b13          	add	s6,s6,2004 # 651d0 <ulthread+0x190>
                flag = 1;
 a04:	875e                	mv	a4,s7
            if(scheduling_algorithm == 0){
 a06:	00092783          	lw	a5,0(s2)
 a0a:	f3e1                	bnez	a5,9ca <ulthread_schedule+0x60>
                if(t->state != RUNNABLE){
 a0c:	008b2783          	lw	a5,8(s6)
 a10:	fd7783e3          	beq	a5,s7,9d6 <ulthread_schedule+0x6c>
        for(t = &ulthread[1]; t < &ulthread[MAXULTHREADS]; t++){
 a14:	0c8b0b13          	add	s6,s6,200
 a18:	fe9b67e3          	bltu	s6,s1,a06 <ulthread_schedule+0x9c>

                t = &ulthread[1];
            }
            
        }
        if(flag == 0){
 a1c:	c749                	beqz	a4,aa6 <ulthread_schedule+0x13c>
            break;
        }
        else{
            flag = 0;
            struct ulthread *t1 = 0;
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 a1e:	00064797          	auipc	a5,0x64
 a22:	6ea78793          	add	a5,a5,1770 # 65108 <ulthread+0xc8>
                if(t1->state == YIELD){
 a26:	4689                	li	a3,2
                    t1->state = RUNNABLE;
 a28:	4605                	li	a2,1
 a2a:	a88d                	j	a9c <ulthread_schedule+0x132>
                if(t->state != RUNNABLE){
 a2c:	008b2783          	lw	a5,8(s6)
 a30:	ff7792e3          	bne	a5,s7,a14 <ulthread_schedule+0xaa>
 a34:	85da                	mv	a1,s6
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a36:	00064797          	auipc	a5,0x64
 a3a:	6d278793          	add	a5,a5,1746 # 65108 <ulthread+0xc8>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 a3e:	4685                	li	a3,1
 a40:	a029                	j	a4a <ulthread_schedule+0xe0>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a42:	0c878793          	add	a5,a5,200
 a46:	00978b63          	beq	a5,s1,a5c <ulthread_schedule+0xf2>
                    if((temp->state == RUNNABLE) && (temp->priority > max_priority_thread->priority)){
 a4a:	4798                	lw	a4,8(a5)
 a4c:	fed71be3          	bne	a4,a3,a42 <ulthread_schedule+0xd8>
 a50:	43d0                	lw	a2,4(a5)
 a52:	41d8                	lw	a4,4(a1)
 a54:	fec757e3          	bge	a4,a2,a42 <ulthread_schedule+0xd8>
 a58:	85be                	mv	a1,a5
 a5a:	b7e5                	j	a42 <ulthread_schedule+0xd8>
                if(max_priority_thread != 0){
 a5c:	ddad                	beqz	a1,9d6 <ulthread_schedule+0x6c>
 a5e:	8b2e                	mv	s6,a1
 a60:	bf9d                	j	9d6 <ulthread_schedule+0x6c>
                if(t->state != RUNNABLE){
 a62:	008b2683          	lw	a3,8(s6)
 a66:	4785                	li	a5,1
 a68:	faf696e3          	bne	a3,a5,a14 <ulthread_schedule+0xaa>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a6c:	00064797          	auipc	a5,0x64
 a70:	69c78793          	add	a5,a5,1692 # 65108 <ulthread+0xc8>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 a74:	4605                	li	a2,1
 a76:	a029                	j	a80 <ulthread_schedule+0x116>
                for(temp = &ulthread[1]; temp < &ulthread[MAXULTHREADS]; temp++){
 a78:	0c878793          	add	a5,a5,200
 a7c:	f4978de3          	beq	a5,s1,9d6 <ulthread_schedule+0x6c>
                    if((temp->ctime < min_ctime->ctime) && (temp->state == RUNNABLE)){
 a80:	7394                	ld	a3,32(a5)
 a82:	020b3703          	ld	a4,32(s6)
 a86:	fee6f9e3          	bgeu	a3,a4,a78 <ulthread_schedule+0x10e>
 a8a:	4798                	lw	a4,8(a5)
 a8c:	fec716e3          	bne	a4,a2,a78 <ulthread_schedule+0x10e>
 a90:	8b3e                	mv	s6,a5
 a92:	b7dd                	j	a78 <ulthread_schedule+0x10e>
            for(t1 = &ulthread[1]; t1 < &ulthread[MAXULTHREADS]; t1++){
 a94:	0c878793          	add	a5,a5,200
 a98:	f29781e3          	beq	a5,s1,9ba <ulthread_schedule+0x50>
                if(t1->state == YIELD){
 a9c:	4798                	lw	a4,8(a5)
 a9e:	fed71be3          	bne	a4,a3,a94 <ulthread_schedule+0x12a>
                    t1->state = RUNNABLE;
 aa2:	c790                	sw	a2,8(a5)
 aa4:	bfc5                	j	a94 <ulthread_schedule+0x12a>
                }
            }
        }
    }
}
 aa6:	60a6                	ld	ra,72(sp)
 aa8:	6406                	ld	s0,64(sp)
 aaa:	74e2                	ld	s1,56(sp)
 aac:	7942                	ld	s2,48(sp)
 aae:	79a2                	ld	s3,40(sp)
 ab0:	7a02                	ld	s4,32(sp)
 ab2:	6ae2                	ld	s5,24(sp)
 ab4:	6b42                	ld	s6,16(sp)
 ab6:	6ba2                	ld	s7,8(sp)
 ab8:	6c02                	ld	s8,0(sp)
 aba:	6161                	add	sp,sp,80
 abc:	8082                	ret

0000000000000abe <ulthread_yield>:

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {
 abe:	1101                	add	sp,sp,-32
 ac0:	ec06                	sd	ra,24(sp)
 ac2:	e822                	sd	s0,16(sp)
 ac4:	e426                	sd	s1,8(sp)
 ac6:	1000                	add	s0,sp,32

    current_thread->state = YIELD;
 ac8:	00000497          	auipc	s1,0x0
 acc:	55848493          	add	s1,s1,1368 # 1020 <current_thread>
 ad0:	609c                	ld	a5,0(s1)
 ad2:	4709                	li	a4,2
 ad4:	c798                	sw	a4,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid());
 ad6:	438c                	lw	a1,0(a5)
 ad8:	00000517          	auipc	a0,0x0
 adc:	27850513          	add	a0,a0,632 # d50 <digits+0x60>
 ae0:	00000097          	auipc	ra,0x0
 ae4:	be4080e7          	jalr	-1052(ra) # 6c4 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 ae8:	6088                	ld	a0,0(s1)
 aea:	00000597          	auipc	a1,0x0
 aee:	5165b583          	ld	a1,1302(a1) # 1000 <scheduler_thread>
 af2:	02858593          	add	a1,a1,40
 af6:	02850513          	add	a0,a0,40
 afa:	00000097          	auipc	ra,0x0
 afe:	060080e7          	jalr	96(ra) # b5a <ulthread_context_switch>
    
}
 b02:	60e2                	ld	ra,24(sp)
 b04:	6442                	ld	s0,16(sp)
 b06:	64a2                	ld	s1,8(sp)
 b08:	6105                	add	sp,sp,32
 b0a:	8082                	ret

0000000000000b0c <ulthread_destroy>:

/* Destroy thread */
void ulthread_destroy(void) {
 b0c:	1101                	add	sp,sp,-32
 b0e:	ec06                	sd	ra,24(sp)
 b10:	e822                	sd	s0,16(sp)
 b12:	e426                	sd	s1,8(sp)
 b14:	1000                	add	s0,sp,32

    // find the current running thread and mark it as FREE
    current_thread->state = FREE;
 b16:	00000497          	auipc	s1,0x0
 b1a:	50a48493          	add	s1,s1,1290 # 1020 <current_thread>
 b1e:	609c                	ld	a5,0(s1)
 b20:	0007a423          	sw	zero,8(a5)

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid());
 b24:	438c                	lw	a1,0(a5)
 b26:	00000517          	auipc	a0,0x0
 b2a:	24250513          	add	a0,a0,578 # d68 <digits+0x78>
 b2e:	00000097          	auipc	ra,0x0
 b32:	b96080e7          	jalr	-1130(ra) # 6c4 <printf>

    ulthread_context_switch(&current_thread->context, &scheduler_thread->context);
 b36:	6088                	ld	a0,0(s1)
 b38:	00000597          	auipc	a1,0x0
 b3c:	4c85b583          	ld	a1,1224(a1) # 1000 <scheduler_thread>
 b40:	02858593          	add	a1,a1,40
 b44:	02850513          	add	a0,a0,40
 b48:	00000097          	auipc	ra,0x0
 b4c:	012080e7          	jalr	18(ra) # b5a <ulthread_context_switch>
}
 b50:	60e2                	ld	ra,24(sp)
 b52:	6442                	ld	s0,16(sp)
 b54:	64a2                	ld	s1,8(sp)
 b56:	6105                	add	sp,sp,32
 b58:	8082                	ret

0000000000000b5a <ulthread_context_switch>:
 b5a:	00153023          	sd	ra,0(a0)
 b5e:	00253423          	sd	sp,8(a0)
 b62:	e900                	sd	s0,16(a0)
 b64:	ed04                	sd	s1,24(a0)
 b66:	03253023          	sd	s2,32(a0)
 b6a:	03353423          	sd	s3,40(a0)
 b6e:	03453823          	sd	s4,48(a0)
 b72:	03553c23          	sd	s5,56(a0)
 b76:	05653023          	sd	s6,64(a0)
 b7a:	05753423          	sd	s7,72(a0)
 b7e:	05853823          	sd	s8,80(a0)
 b82:	05953c23          	sd	s9,88(a0)
 b86:	07a53023          	sd	s10,96(a0)
 b8a:	07b53423          	sd	s11,104(a0)
 b8e:	0005b083          	ld	ra,0(a1)
 b92:	0085b103          	ld	sp,8(a1)
 b96:	6980                	ld	s0,16(a1)
 b98:	6d84                	ld	s1,24(a1)
 b9a:	0205b903          	ld	s2,32(a1)
 b9e:	0285b983          	ld	s3,40(a1)
 ba2:	0305ba03          	ld	s4,48(a1)
 ba6:	0385ba83          	ld	s5,56(a1)
 baa:	0405bb03          	ld	s6,64(a1)
 bae:	0485bb83          	ld	s7,72(a1)
 bb2:	0505bc03          	ld	s8,80(a1)
 bb6:	0585bc83          	ld	s9,88(a1)
 bba:	0605bd03          	ld	s10,96(a1)
 bbe:	0685bd83          	ld	s11,104(a1)
 bc2:	00040513          	mv	a0,s0
 bc6:	00048593          	mv	a1,s1
 bca:	00090613          	mv	a2,s2
 bce:	00098693          	mv	a3,s3
 bd2:	000a0713          	mv	a4,s4
 bd6:	000a8793          	mv	a5,s5
 bda:	8082                	ret
