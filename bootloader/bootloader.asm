
bootloader/bootloader:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00001117          	auipc	sp,0x1
    80000004:	87010113          	addi	sp,sp,-1936 # 80000870 <bl_stack>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	18a000ef          	jal	ra,800001a0 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <r_vendor>:
#ifndef __ASSEMBLER__

// CSE 536: Task 2.6
static inline uint64
r_vendor()
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec22                	sd	s0,24(sp)
    80000020:	1000                	addi	s0,sp,32
  uint64 vendor_id;
  asm volatile("csrr %0, mvendorid" : "=r" (vendor_id));
    80000022:	f11027f3          	csrr	a5,mvendorid
    80000026:	fef43423          	sd	a5,-24(s0)
  return vendor_id;
    8000002a:	fe843783          	ld	a5,-24(s0)
}
    8000002e:	853e                	mv	a0,a5
    80000030:	6462                	ld	s0,24(sp)
    80000032:	6105                	addi	sp,sp,32
    80000034:	8082                	ret

0000000080000036 <r_architecture>:
 
// CSE 536: Task 2.6
static inline uint64
r_architecture()
{
    80000036:	1101                	addi	sp,sp,-32
    80000038:	ec22                	sd	s0,24(sp)
    8000003a:	1000                	addi	s0,sp,32
  uint64 arch_id; 
  asm volatile("csrr %0, marchid" : "=r" (arch_id));
    8000003c:	f12027f3          	csrr	a5,marchid
    80000040:	fef43423          	sd	a5,-24(s0)
  return arch_id;
    80000044:	fe843783          	ld	a5,-24(s0)
}
    80000048:	853e                	mv	a0,a5
    8000004a:	6462                	ld	s0,24(sp)
    8000004c:	6105                	addi	sp,sp,32
    8000004e:	8082                	ret

0000000080000050 <r_implementation>:
 
// CSE 536: Task 2.6
static inline uint64
r_implementation()
{
    80000050:	1101                	addi	sp,sp,-32
    80000052:	ec22                	sd	s0,24(sp)
    80000054:	1000                	addi	s0,sp,32
  uint64 imp_id; 
  asm volatile("csrr %0, mimpid" : "=r" (imp_id));
    80000056:	f13027f3          	csrr	a5,mimpid
    8000005a:	fef43423          	sd	a5,-24(s0)
  return imp_id;
    8000005e:	fe843783          	ld	a5,-24(s0)
}
    80000062:	853e                	mv	a0,a5
    80000064:	6462                	ld	s0,24(sp)
    80000066:	6105                	addi	sp,sp,32
    80000068:	8082                	ret

000000008000006a <r_mhartid>:

// which hart (core) is this?
static inline uint64
r_mhartid()
{
    8000006a:	1101                	addi	sp,sp,-32
    8000006c:	ec22                	sd	s0,24(sp)
    8000006e:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000070:	f14027f3          	csrr	a5,mhartid
    80000074:	fef43423          	sd	a5,-24(s0)
  return x;
    80000078:	fe843783          	ld	a5,-24(s0)
}
    8000007c:	853e                	mv	a0,a5
    8000007e:	6462                	ld	s0,24(sp)
    80000080:	6105                	addi	sp,sp,32
    80000082:	8082                	ret

0000000080000084 <r_mstatus>:
#define MSTATUS_MPP_U (0L << 11)
#define MSTATUS_MIE (1L << 3)    // machine-mode interrupt enable.

static inline uint64
r_mstatus()
{
    80000084:	1101                	addi	sp,sp,-32
    80000086:	ec22                	sd	s0,24(sp)
    80000088:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000008a:	300027f3          	csrr	a5,mstatus
    8000008e:	fef43423          	sd	a5,-24(s0)
  return x;
    80000092:	fe843783          	ld	a5,-24(s0)
}
    80000096:	853e                	mv	a0,a5
    80000098:	6462                	ld	s0,24(sp)
    8000009a:	6105                	addi	sp,sp,32
    8000009c:	8082                	ret

000000008000009e <w_mstatus>:

static inline void 
w_mstatus(uint64 x)
{
    8000009e:	1101                	addi	sp,sp,-32
    800000a0:	ec22                	sd	s0,24(sp)
    800000a2:	1000                	addi	s0,sp,32
    800000a4:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	fe843783          	ld	a5,-24(s0)
    800000ac:	30079073          	csrw	mstatus,a5
}
    800000b0:	0001                	nop
    800000b2:	6462                	ld	s0,24(sp)
    800000b4:	6105                	addi	sp,sp,32
    800000b6:	8082                	ret

00000000800000b8 <w_mepc>:
// machine exception program counter, holds the
// instruction address to which a return from
// exception will go.
static inline void 
w_mepc(uint64 x)
{
    800000b8:	1101                	addi	sp,sp,-32
    800000ba:	ec22                	sd	s0,24(sp)
    800000bc:	1000                	addi	s0,sp,32
    800000be:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000c2:	fe843783          	ld	a5,-24(s0)
    800000c6:	34179073          	csrw	mepc,a5
}
    800000ca:	0001                	nop
    800000cc:	6462                	ld	s0,24(sp)
    800000ce:	6105                	addi	sp,sp,32
    800000d0:	8082                	ret

00000000800000d2 <r_sie>:
#define SIE_SEIE (1L << 9) // external
#define SIE_STIE (1L << 5) // timer
#define SIE_SSIE (1L << 1) // software
static inline uint64
r_sie()
{
    800000d2:	1101                	addi	sp,sp,-32
    800000d4:	ec22                	sd	s0,24(sp)
    800000d6:	1000                	addi	s0,sp,32
  uint64 x;
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000d8:	104027f3          	csrr	a5,sie
    800000dc:	fef43423          	sd	a5,-24(s0)
  return x;
    800000e0:	fe843783          	ld	a5,-24(s0)
}
    800000e4:	853e                	mv	a0,a5
    800000e6:	6462                	ld	s0,24(sp)
    800000e8:	6105                	addi	sp,sp,32
    800000ea:	8082                	ret

00000000800000ec <w_sie>:

static inline void 
w_sie(uint64 x)
{
    800000ec:	1101                	addi	sp,sp,-32
    800000ee:	ec22                	sd	s0,24(sp)
    800000f0:	1000                	addi	s0,sp,32
    800000f2:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw sie, %0" : : "r" (x));
    800000f6:	fe843783          	ld	a5,-24(s0)
    800000fa:	10479073          	csrw	sie,a5
}
    800000fe:	0001                	nop
    80000100:	6462                	ld	s0,24(sp)
    80000102:	6105                	addi	sp,sp,32
    80000104:	8082                	ret

0000000080000106 <w_medeleg>:
  return x;
}

static inline void 
w_medeleg(uint64 x)
{
    80000106:	1101                	addi	sp,sp,-32
    80000108:	ec22                	sd	s0,24(sp)
    8000010a:	1000                	addi	s0,sp,32
    8000010c:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000110:	fe843783          	ld	a5,-24(s0)
    80000114:	30279073          	csrw	medeleg,a5
}
    80000118:	0001                	nop
    8000011a:	6462                	ld	s0,24(sp)
    8000011c:	6105                	addi	sp,sp,32
    8000011e:	8082                	ret

0000000080000120 <w_mideleg>:
  return x;
}

static inline void 
w_mideleg(uint64 x)
{
    80000120:	1101                	addi	sp,sp,-32
    80000122:	ec22                	sd	s0,24(sp)
    80000124:	1000                	addi	s0,sp,32
    80000126:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000012a:	fe843783          	ld	a5,-24(s0)
    8000012e:	30379073          	csrw	mideleg,a5
}
    80000132:	0001                	nop
    80000134:	6462                	ld	s0,24(sp)
    80000136:	6105                	addi	sp,sp,32
    80000138:	8082                	ret

000000008000013a <w_pmpcfg0>:
}

// Physical Memory Protection
static inline void
w_pmpcfg0(uint64 x)
{
    8000013a:	1101                	addi	sp,sp,-32
    8000013c:	ec22                	sd	s0,24(sp)
    8000013e:	1000                	addi	s0,sp,32
    80000140:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    80000144:	fe843783          	ld	a5,-24(s0)
    80000148:	3a079073          	csrw	pmpcfg0,a5
}
    8000014c:	0001                	nop
    8000014e:	6462                	ld	s0,24(sp)
    80000150:	6105                	addi	sp,sp,32
    80000152:	8082                	ret

0000000080000154 <w_pmpaddr0>:

static inline void
w_pmpaddr0(uint64 x)
{
    80000154:	1101                	addi	sp,sp,-32
    80000156:	ec22                	sd	s0,24(sp)
    80000158:	1000                	addi	s0,sp,32
    8000015a:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    8000015e:	fe843783          	ld	a5,-24(s0)
    80000162:	3b079073          	csrw	pmpaddr0,a5
}
    80000166:	0001                	nop
    80000168:	6462                	ld	s0,24(sp)
    8000016a:	6105                	addi	sp,sp,32
    8000016c:	8082                	ret

000000008000016e <w_satp>:

// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
    8000016e:	1101                	addi	sp,sp,-32
    80000170:	ec22                	sd	s0,24(sp)
    80000172:	1000                	addi	s0,sp,32
    80000174:	fea43423          	sd	a0,-24(s0)
  asm volatile("csrw satp, %0" : : "r" (x));
    80000178:	fe843783          	ld	a5,-24(s0)
    8000017c:	18079073          	csrw	satp,a5
}
    80000180:	0001                	nop
    80000182:	6462                	ld	s0,24(sp)
    80000184:	6105                	addi	sp,sp,32
    80000186:	8082                	ret

0000000080000188 <w_tp>:
  return x;
}

static inline void 
w_tp(uint64 x)
{
    80000188:	1101                	addi	sp,sp,-32
    8000018a:	ec22                	sd	s0,24(sp)
    8000018c:	1000                	addi	s0,sp,32
    8000018e:	fea43423          	sd	a0,-24(s0)
  asm volatile("mv tp, %0" : : "r" (x));
    80000192:	fe843783          	ld	a5,-24(s0)
    80000196:	823e                	mv	tp,a5
}
    80000198:	0001                	nop
    8000019a:	6462                	ld	s0,24(sp)
    8000019c:	6105                	addi	sp,sp,32
    8000019e:	8082                	ret

00000000800001a0 <start>:
extern void _entry(void);

// entry.S jumps here in machine mode on stack0.
void
start()
{
    800001a0:	715d                	addi	sp,sp,-80
    800001a2:	e486                	sd	ra,72(sp)
    800001a4:	e0a2                	sd	s0,64(sp)
    800001a6:	fc26                	sd	s1,56(sp)
    800001a8:	0880                	addi	s0,sp,80
  // keep each CPU's hartid in its tp register, for cpuid().
  int id = r_mhartid();
    800001aa:	00000097          	auipc	ra,0x0
    800001ae:	ec0080e7          	jalr	-320(ra) # 8000006a <r_mhartid>
    800001b2:	87aa                	mv	a5,a0
    800001b4:	fcf42e23          	sw	a5,-36(s0)
  w_tp(id);
    800001b8:	fdc42783          	lw	a5,-36(s0)
    800001bc:	853e                	mv	a0,a5
    800001be:	00000097          	auipc	ra,0x0
    800001c2:	fca080e7          	jalr	-54(ra) # 80000188 <w_tp>

  // set M Previous Privilege mode to Supervisor, for mret.
  unsigned long x = r_mstatus();
    800001c6:	00000097          	auipc	ra,0x0
    800001ca:	ebe080e7          	jalr	-322(ra) # 80000084 <r_mstatus>
    800001ce:	fca43823          	sd	a0,-48(s0)
  x &= ~MSTATUS_MPP_MASK;
    800001d2:	fd043703          	ld	a4,-48(s0)
    800001d6:	77f9                	lui	a5,0xffffe
    800001d8:	7ff78793          	addi	a5,a5,2047 # ffffffffffffe7ff <kernel_phdr+0xffffffff7fff5f7f>
    800001dc:	8ff9                	and	a5,a5,a4
    800001de:	fcf43823          	sd	a5,-48(s0)
  x |= MSTATUS_MPP_S;
    800001e2:	fd043703          	ld	a4,-48(s0)
    800001e6:	6785                	lui	a5,0x1
    800001e8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    800001ec:	8fd9                	or	a5,a5,a4
    800001ee:	fcf43823          	sd	a5,-48(s0)
  w_mstatus(x);
    800001f2:	fd043503          	ld	a0,-48(s0)
    800001f6:	00000097          	auipc	ra,0x0
    800001fa:	ea8080e7          	jalr	-344(ra) # 8000009e <w_mstatus>

  // disable paging for now.
  w_satp(0);
    800001fe:	4501                	li	a0,0
    80000200:	00000097          	auipc	ra,0x0
    80000204:	f6e080e7          	jalr	-146(ra) # 8000016e <w_satp>

  // delegate all interrupts and exceptions to supervisor mode.
  w_medeleg(0xffff);
    80000208:	67c1                	lui	a5,0x10
    8000020a:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000020e:	00000097          	auipc	ra,0x0
    80000212:	ef8080e7          	jalr	-264(ra) # 80000106 <w_medeleg>
  w_mideleg(0xffff);
    80000216:	67c1                	lui	a5,0x10
    80000218:	fff78513          	addi	a0,a5,-1 # ffff <_entry-0x7fff0001>
    8000021c:	00000097          	auipc	ra,0x0
    80000220:	f04080e7          	jalr	-252(ra) # 80000120 <w_mideleg>
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    80000224:	00000097          	auipc	ra,0x0
    80000228:	eae080e7          	jalr	-338(ra) # 800000d2 <r_sie>
    8000022c:	87aa                	mv	a5,a0
    8000022e:	2227e793          	ori	a5,a5,546
    80000232:	853e                	mv	a0,a5
    80000234:	00000097          	auipc	ra,0x0
    80000238:	eb8080e7          	jalr	-328(ra) # 800000ec <w_sie>

  // CSE 536: Task 2.4
  //  Enable R/W/X access to all parts of the address space, 
  //  except for the upper 10 MB (0 - 117 MB) using PMP
  w_pmpaddr0(0x21d40000);
    8000023c:	21d40537          	lui	a0,0x21d40
    80000240:	00000097          	auipc	ra,0x0
    80000244:	f14080e7          	jalr	-236(ra) # 80000154 <w_pmpaddr0>
  w_pmpcfg0(0xf);
    80000248:	453d                	li	a0,15
    8000024a:	00000097          	auipc	ra,0x0
    8000024e:	ef0080e7          	jalr	-272(ra) # 8000013a <w_pmpcfg0>

  // CSE 536: Task 2.5
  // Load the kernel binary to its correct location
  uint64 kernel_entry_addr = 0;
    80000252:	fc043423          	sd	zero,-56(s0)
  uint64 kernel_load_addr  = 0;
    80000256:	fc043023          	sd	zero,-64(s0)
  uint64 kernel_size       = 0;
    8000025a:	fa043c23          	sd	zero,-72(s0)

  // CSE 536: Task 2.5.1
  // Find the loading address of the kernel binary
  kernel_load_addr  = find_kernel_load_addr();
    8000025e:	00000097          	auipc	ra,0x0
    80000262:	526080e7          	jalr	1318(ra) # 80000784 <find_kernel_load_addr>
    80000266:	fca43023          	sd	a0,-64(s0)

  // CSE 536: Task 2.5.2
  // Find the kernel binary size and copy it to the load address
  kernel_size       = find_kernel_size();
    8000026a:	00000097          	auipc	ra,0x0
    8000026e:	57c080e7          	jalr	1404(ra) # 800007e6 <find_kernel_size>
    80000272:	faa43c23          	sd	a0,-72(s0)
  memmove((char *)kernel_load_addr, (char *)RAMDISK+4096, (kernel_size-4096));
    80000276:	fc043683          	ld	a3,-64(s0)
    8000027a:	fb843783          	ld	a5,-72(s0)
    8000027e:	0007871b          	sext.w	a4,a5
    80000282:	77fd                	lui	a5,0xfffff
    80000284:	9fb9                	addw	a5,a5,a4
    80000286:	2781                	sext.w	a5,a5
    80000288:	863e                	mv	a2,a5
    8000028a:	000847b7          	lui	a5,0x84
    8000028e:	0785                	addi	a5,a5,1 # 84001 <_entry-0x7ff7bfff>
    80000290:	00c79593          	slli	a1,a5,0xc
    80000294:	8536                	mv	a0,a3
    80000296:	00000097          	auipc	ra,0x0
    8000029a:	21c080e7          	jalr	540(ra) # 800004b2 <memmove>

  // CSE 536: Task 2.5.3
  // Find the entry address and write it to mepc
  kernel_entry_addr = find_kernel_entry_addr();
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	5a4080e7          	jalr	1444(ra) # 80000842 <find_kernel_entry_addr>
    800002a6:	fca43423          	sd	a0,-56(s0)
  w_mepc(kernel_entry_addr);
    800002aa:	fc843503          	ld	a0,-56(s0)
    800002ae:	00000097          	auipc	ra,0x0
    800002b2:	e0a080e7          	jalr	-502(ra) # 800000b8 <w_mepc>

  // CSE 536: Task 2.6
  // Provide system information to the kernel
  sys_info_ptr = (struct sys_info*)SYSINFOADDR;
    800002b6:	00008797          	auipc	a5,0x8
    800002ba:	5ba78793          	addi	a5,a5,1466 # 80008870 <sys_info_ptr>
    800002be:	01001737          	lui	a4,0x1001
    800002c2:	071e                	slli	a4,a4,0x7
    800002c4:	e398                	sd	a4,0(a5)
  sys_info_ptr->bl_start = (uint64)0x80000000;
    800002c6:	00008797          	auipc	a5,0x8
    800002ca:	5aa78793          	addi	a5,a5,1450 # 80008870 <sys_info_ptr>
    800002ce:	639c                	ld	a5,0(a5)
    800002d0:	4705                	li	a4,1
    800002d2:	077e                	slli	a4,a4,0x1f
    800002d4:	ef98                	sd	a4,24(a5)
  sys_info_ptr->bl_end = end;
    800002d6:	00008797          	auipc	a5,0x8
    800002da:	59a78793          	addi	a5,a5,1434 # 80008870 <sys_info_ptr>
    800002de:	639c                	ld	a5,0(a5)
    800002e0:	00008717          	auipc	a4,0x8
    800002e4:	59070713          	addi	a4,a4,1424 # 80008870 <sys_info_ptr>
    800002e8:	6318                	ld	a4,0(a4)
    800002ea:	f398                	sd	a4,32(a5)
  sys_info_ptr->dr_start = (uint64)0x80000000;
    800002ec:	00008797          	auipc	a5,0x8
    800002f0:	58478793          	addi	a5,a5,1412 # 80008870 <sys_info_ptr>
    800002f4:	639c                	ld	a5,0(a5)
    800002f6:	4705                	li	a4,1
    800002f8:	077e                	slli	a4,a4,0x1f
    800002fa:	f798                	sd	a4,40(a5)
  sys_info_ptr->dr_end = (uint64)0x4D4B400;
    800002fc:	00008797          	auipc	a5,0x8
    80000300:	57478793          	addi	a5,a5,1396 # 80008870 <sys_info_ptr>
    80000304:	639c                	ld	a5,0(a5)
    80000306:	04d4b737          	lui	a4,0x4d4b
    8000030a:	40070713          	addi	a4,a4,1024 # 4d4b400 <_entry-0x7b2b4c00>
    8000030e:	fb98                	sd	a4,48(a5)
  sys_info_ptr->vendor = r_vendor();
    80000310:	00008797          	auipc	a5,0x8
    80000314:	56078793          	addi	a5,a5,1376 # 80008870 <sys_info_ptr>
    80000318:	6384                	ld	s1,0(a5)
    8000031a:	00000097          	auipc	ra,0x0
    8000031e:	d02080e7          	jalr	-766(ra) # 8000001c <r_vendor>
    80000322:	87aa                	mv	a5,a0
    80000324:	e09c                	sd	a5,0(s1)
  sys_info_ptr->arch = r_architecture();
    80000326:	00008797          	auipc	a5,0x8
    8000032a:	54a78793          	addi	a5,a5,1354 # 80008870 <sys_info_ptr>
    8000032e:	6384                	ld	s1,0(a5)
    80000330:	00000097          	auipc	ra,0x0
    80000334:	d06080e7          	jalr	-762(ra) # 80000036 <r_architecture>
    80000338:	87aa                	mv	a5,a0
    8000033a:	e49c                	sd	a5,8(s1)
  sys_info_ptr->impl = r_implementation();  
    8000033c:	00008797          	auipc	a5,0x8
    80000340:	53478793          	addi	a5,a5,1332 # 80008870 <sys_info_ptr>
    80000344:	6384                	ld	s1,0(a5)
    80000346:	00000097          	auipc	ra,0x0
    8000034a:	d0a080e7          	jalr	-758(ra) # 80000050 <r_implementation>
    8000034e:	87aa                	mv	a5,a0
    80000350:	e89c                	sd	a5,16(s1)

  // CSE 536: Task 2.5.3
  // Jump to the OS kernel code
  asm volatile("mret");
    80000352:	30200073          	mret
    80000356:	0001                	nop
    80000358:	60a6                	ld	ra,72(sp)
    8000035a:	6406                	ld	s0,64(sp)
    8000035c:	74e2                	ld	s1,56(sp)
    8000035e:	6161                	addi	sp,sp,80
    80000360:	8082                	ret

0000000080000362 <kernel_copy>:

// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
kernel_copy(struct buf *b)
{
    80000362:	7179                	addi	sp,sp,-48
    80000364:	f406                	sd	ra,40(sp)
    80000366:	f022                	sd	s0,32(sp)
    80000368:	1800                	addi	s0,sp,48
    8000036a:	fca43c23          	sd	a0,-40(s0)
  /* Ramdisk is not even reading from the damn file.. */
  if(b->blockno >= FSSIZE)
    8000036e:	fd843783          	ld	a5,-40(s0)
    80000372:	47dc                	lw	a5,12(a5)
    80000374:	873e                	mv	a4,a5
    80000376:	7cf00793          	li	a5,1999
    8000037a:	00e7f663          	bgeu	a5,a4,80000386 <kernel_copy+0x24>
    spin();
    8000037e:	00000097          	auipc	ra,0x0
    80000382:	c9c080e7          	jalr	-868(ra) # 8000001a <spin>

  uint64 diskaddr = b->blockno * BSIZE;
    80000386:	fd843783          	ld	a5,-40(s0)
    8000038a:	47dc                	lw	a5,12(a5)
    8000038c:	00a7979b          	slliw	a5,a5,0xa
    80000390:	2781                	sext.w	a5,a5
    80000392:	1782                	slli	a5,a5,0x20
    80000394:	9381                	srli	a5,a5,0x20
    80000396:	fef43423          	sd	a5,-24(s0)
  char *addr = (char *)RAMDISK + diskaddr;
    8000039a:	fe843703          	ld	a4,-24(s0)
    8000039e:	02100793          	li	a5,33
    800003a2:	07ea                	slli	a5,a5,0x1a
    800003a4:	97ba                	add	a5,a5,a4
    800003a6:	fef43023          	sd	a5,-32(s0)

  // read from the location
  memmove(b->data, addr, BSIZE);
    800003aa:	fd843783          	ld	a5,-40(s0)
    800003ae:	02878793          	addi	a5,a5,40
    800003b2:	40000613          	li	a2,1024
    800003b6:	fe043583          	ld	a1,-32(s0)
    800003ba:	853e                	mv	a0,a5
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	0f6080e7          	jalr	246(ra) # 800004b2 <memmove>
}
    800003c4:	0001                	nop
    800003c6:	70a2                	ld	ra,40(sp)
    800003c8:	7402                	ld	s0,32(sp)
    800003ca:	6145                	addi	sp,sp,48
    800003cc:	8082                	ret

00000000800003ce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    800003ce:	7179                	addi	sp,sp,-48
    800003d0:	f422                	sd	s0,40(sp)
    800003d2:	1800                	addi	s0,sp,48
    800003d4:	fca43c23          	sd	a0,-40(s0)
    800003d8:	87ae                	mv	a5,a1
    800003da:	8732                	mv	a4,a2
    800003dc:	fcf42a23          	sw	a5,-44(s0)
    800003e0:	87ba                	mv	a5,a4
    800003e2:	fcf42823          	sw	a5,-48(s0)
  char *cdst = (char *) dst;
    800003e6:	fd843783          	ld	a5,-40(s0)
    800003ea:	fef43023          	sd	a5,-32(s0)
  int i;
  for(i = 0; i < n; i++){
    800003ee:	fe042623          	sw	zero,-20(s0)
    800003f2:	a00d                	j	80000414 <memset+0x46>
    cdst[i] = c;
    800003f4:	fec42783          	lw	a5,-20(s0)
    800003f8:	fe043703          	ld	a4,-32(s0)
    800003fc:	97ba                	add	a5,a5,a4
    800003fe:	fd442703          	lw	a4,-44(s0)
    80000402:	0ff77713          	zext.b	a4,a4
    80000406:	00e78023          	sb	a4,0(a5)
  for(i = 0; i < n; i++){
    8000040a:	fec42783          	lw	a5,-20(s0)
    8000040e:	2785                	addiw	a5,a5,1
    80000410:	fef42623          	sw	a5,-20(s0)
    80000414:	fec42703          	lw	a4,-20(s0)
    80000418:	fd042783          	lw	a5,-48(s0)
    8000041c:	2781                	sext.w	a5,a5
    8000041e:	fcf76be3          	bltu	a4,a5,800003f4 <memset+0x26>
  }
  return dst;
    80000422:	fd843783          	ld	a5,-40(s0)
}
    80000426:	853e                	mv	a0,a5
    80000428:	7422                	ld	s0,40(sp)
    8000042a:	6145                	addi	sp,sp,48
    8000042c:	8082                	ret

000000008000042e <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    8000042e:	7139                	addi	sp,sp,-64
    80000430:	fc22                	sd	s0,56(sp)
    80000432:	0080                	addi	s0,sp,64
    80000434:	fca43c23          	sd	a0,-40(s0)
    80000438:	fcb43823          	sd	a1,-48(s0)
    8000043c:	87b2                	mv	a5,a2
    8000043e:	fcf42623          	sw	a5,-52(s0)
  const uchar *s1, *s2;

  s1 = v1;
    80000442:	fd843783          	ld	a5,-40(s0)
    80000446:	fef43423          	sd	a5,-24(s0)
  s2 = v2;
    8000044a:	fd043783          	ld	a5,-48(s0)
    8000044e:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    80000452:	a0a1                	j	8000049a <memcmp+0x6c>
    if(*s1 != *s2)
    80000454:	fe843783          	ld	a5,-24(s0)
    80000458:	0007c703          	lbu	a4,0(a5)
    8000045c:	fe043783          	ld	a5,-32(s0)
    80000460:	0007c783          	lbu	a5,0(a5)
    80000464:	02f70163          	beq	a4,a5,80000486 <memcmp+0x58>
      return *s1 - *s2;
    80000468:	fe843783          	ld	a5,-24(s0)
    8000046c:	0007c783          	lbu	a5,0(a5)
    80000470:	0007871b          	sext.w	a4,a5
    80000474:	fe043783          	ld	a5,-32(s0)
    80000478:	0007c783          	lbu	a5,0(a5)
    8000047c:	2781                	sext.w	a5,a5
    8000047e:	40f707bb          	subw	a5,a4,a5
    80000482:	2781                	sext.w	a5,a5
    80000484:	a01d                	j	800004aa <memcmp+0x7c>
    s1++, s2++;
    80000486:	fe843783          	ld	a5,-24(s0)
    8000048a:	0785                	addi	a5,a5,1
    8000048c:	fef43423          	sd	a5,-24(s0)
    80000490:	fe043783          	ld	a5,-32(s0)
    80000494:	0785                	addi	a5,a5,1
    80000496:	fef43023          	sd	a5,-32(s0)
  while(n-- > 0){
    8000049a:	fcc42783          	lw	a5,-52(s0)
    8000049e:	fff7871b          	addiw	a4,a5,-1
    800004a2:	fce42623          	sw	a4,-52(s0)
    800004a6:	f7dd                	bnez	a5,80000454 <memcmp+0x26>
  }

  return 0;
    800004a8:	4781                	li	a5,0
}
    800004aa:	853e                	mv	a0,a5
    800004ac:	7462                	ld	s0,56(sp)
    800004ae:	6121                	addi	sp,sp,64
    800004b0:	8082                	ret

00000000800004b2 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800004b2:	7139                	addi	sp,sp,-64
    800004b4:	fc22                	sd	s0,56(sp)
    800004b6:	0080                	addi	s0,sp,64
    800004b8:	fca43c23          	sd	a0,-40(s0)
    800004bc:	fcb43823          	sd	a1,-48(s0)
    800004c0:	87b2                	mv	a5,a2
    800004c2:	fcf42623          	sw	a5,-52(s0)
  const char *s;
  char *d;

  if(n == 0)
    800004c6:	fcc42783          	lw	a5,-52(s0)
    800004ca:	2781                	sext.w	a5,a5
    800004cc:	e781                	bnez	a5,800004d4 <memmove+0x22>
    return dst;
    800004ce:	fd843783          	ld	a5,-40(s0)
    800004d2:	a855                	j	80000586 <memmove+0xd4>
  
  s = src;
    800004d4:	fd043783          	ld	a5,-48(s0)
    800004d8:	fef43423          	sd	a5,-24(s0)
  d = dst;
    800004dc:	fd843783          	ld	a5,-40(s0)
    800004e0:	fef43023          	sd	a5,-32(s0)
  if(s < d && s + n > d){
    800004e4:	fe843703          	ld	a4,-24(s0)
    800004e8:	fe043783          	ld	a5,-32(s0)
    800004ec:	08f77463          	bgeu	a4,a5,80000574 <memmove+0xc2>
    800004f0:	fcc46783          	lwu	a5,-52(s0)
    800004f4:	fe843703          	ld	a4,-24(s0)
    800004f8:	97ba                	add	a5,a5,a4
    800004fa:	fe043703          	ld	a4,-32(s0)
    800004fe:	06f77b63          	bgeu	a4,a5,80000574 <memmove+0xc2>
    s += n;
    80000502:	fcc46783          	lwu	a5,-52(s0)
    80000506:	fe843703          	ld	a4,-24(s0)
    8000050a:	97ba                	add	a5,a5,a4
    8000050c:	fef43423          	sd	a5,-24(s0)
    d += n;
    80000510:	fcc46783          	lwu	a5,-52(s0)
    80000514:	fe043703          	ld	a4,-32(s0)
    80000518:	97ba                	add	a5,a5,a4
    8000051a:	fef43023          	sd	a5,-32(s0)
    while(n-- > 0)
    8000051e:	a01d                	j	80000544 <memmove+0x92>
      *--d = *--s;
    80000520:	fe843783          	ld	a5,-24(s0)
    80000524:	17fd                	addi	a5,a5,-1
    80000526:	fef43423          	sd	a5,-24(s0)
    8000052a:	fe043783          	ld	a5,-32(s0)
    8000052e:	17fd                	addi	a5,a5,-1
    80000530:	fef43023          	sd	a5,-32(s0)
    80000534:	fe843783          	ld	a5,-24(s0)
    80000538:	0007c703          	lbu	a4,0(a5)
    8000053c:	fe043783          	ld	a5,-32(s0)
    80000540:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    80000544:	fcc42783          	lw	a5,-52(s0)
    80000548:	fff7871b          	addiw	a4,a5,-1
    8000054c:	fce42623          	sw	a4,-52(s0)
    80000550:	fbe1                	bnez	a5,80000520 <memmove+0x6e>
  if(s < d && s + n > d){
    80000552:	a805                	j	80000582 <memmove+0xd0>
  } else
    while(n-- > 0)
      *d++ = *s++;
    80000554:	fe843703          	ld	a4,-24(s0)
    80000558:	00170793          	addi	a5,a4,1
    8000055c:	fef43423          	sd	a5,-24(s0)
    80000560:	fe043783          	ld	a5,-32(s0)
    80000564:	00178693          	addi	a3,a5,1
    80000568:	fed43023          	sd	a3,-32(s0)
    8000056c:	00074703          	lbu	a4,0(a4)
    80000570:	00e78023          	sb	a4,0(a5)
    while(n-- > 0)
    80000574:	fcc42783          	lw	a5,-52(s0)
    80000578:	fff7871b          	addiw	a4,a5,-1
    8000057c:	fce42623          	sw	a4,-52(s0)
    80000580:	fbf1                	bnez	a5,80000554 <memmove+0xa2>

  return dst;
    80000582:	fd843783          	ld	a5,-40(s0)
}
    80000586:	853e                	mv	a0,a5
    80000588:	7462                	ld	s0,56(sp)
    8000058a:	6121                	addi	sp,sp,64
    8000058c:	8082                	ret

000000008000058e <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000058e:	7179                	addi	sp,sp,-48
    80000590:	f406                	sd	ra,40(sp)
    80000592:	f022                	sd	s0,32(sp)
    80000594:	1800                	addi	s0,sp,48
    80000596:	fea43423          	sd	a0,-24(s0)
    8000059a:	feb43023          	sd	a1,-32(s0)
    8000059e:	87b2                	mv	a5,a2
    800005a0:	fcf42e23          	sw	a5,-36(s0)
  return memmove(dst, src, n);
    800005a4:	fdc42783          	lw	a5,-36(s0)
    800005a8:	863e                	mv	a2,a5
    800005aa:	fe043583          	ld	a1,-32(s0)
    800005ae:	fe843503          	ld	a0,-24(s0)
    800005b2:	00000097          	auipc	ra,0x0
    800005b6:	f00080e7          	jalr	-256(ra) # 800004b2 <memmove>
    800005ba:	87aa                	mv	a5,a0
}
    800005bc:	853e                	mv	a0,a5
    800005be:	70a2                	ld	ra,40(sp)
    800005c0:	7402                	ld	s0,32(sp)
    800005c2:	6145                	addi	sp,sp,48
    800005c4:	8082                	ret

00000000800005c6 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    800005c6:	7179                	addi	sp,sp,-48
    800005c8:	f422                	sd	s0,40(sp)
    800005ca:	1800                	addi	s0,sp,48
    800005cc:	fea43423          	sd	a0,-24(s0)
    800005d0:	feb43023          	sd	a1,-32(s0)
    800005d4:	87b2                	mv	a5,a2
    800005d6:	fcf42e23          	sw	a5,-36(s0)
  while(n > 0 && *p && *p == *q)
    800005da:	a005                	j	800005fa <strncmp+0x34>
    n--, p++, q++;
    800005dc:	fdc42783          	lw	a5,-36(s0)
    800005e0:	37fd                	addiw	a5,a5,-1
    800005e2:	fcf42e23          	sw	a5,-36(s0)
    800005e6:	fe843783          	ld	a5,-24(s0)
    800005ea:	0785                	addi	a5,a5,1
    800005ec:	fef43423          	sd	a5,-24(s0)
    800005f0:	fe043783          	ld	a5,-32(s0)
    800005f4:	0785                	addi	a5,a5,1
    800005f6:	fef43023          	sd	a5,-32(s0)
  while(n > 0 && *p && *p == *q)
    800005fa:	fdc42783          	lw	a5,-36(s0)
    800005fe:	2781                	sext.w	a5,a5
    80000600:	c385                	beqz	a5,80000620 <strncmp+0x5a>
    80000602:	fe843783          	ld	a5,-24(s0)
    80000606:	0007c783          	lbu	a5,0(a5)
    8000060a:	cb99                	beqz	a5,80000620 <strncmp+0x5a>
    8000060c:	fe843783          	ld	a5,-24(s0)
    80000610:	0007c703          	lbu	a4,0(a5)
    80000614:	fe043783          	ld	a5,-32(s0)
    80000618:	0007c783          	lbu	a5,0(a5)
    8000061c:	fcf700e3          	beq	a4,a5,800005dc <strncmp+0x16>
  if(n == 0)
    80000620:	fdc42783          	lw	a5,-36(s0)
    80000624:	2781                	sext.w	a5,a5
    80000626:	e399                	bnez	a5,8000062c <strncmp+0x66>
    return 0;
    80000628:	4781                	li	a5,0
    8000062a:	a839                	j	80000648 <strncmp+0x82>
  return (uchar)*p - (uchar)*q;
    8000062c:	fe843783          	ld	a5,-24(s0)
    80000630:	0007c783          	lbu	a5,0(a5)
    80000634:	0007871b          	sext.w	a4,a5
    80000638:	fe043783          	ld	a5,-32(s0)
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	2781                	sext.w	a5,a5
    80000642:	40f707bb          	subw	a5,a4,a5
    80000646:	2781                	sext.w	a5,a5
}
    80000648:	853e                	mv	a0,a5
    8000064a:	7422                	ld	s0,40(sp)
    8000064c:	6145                	addi	sp,sp,48
    8000064e:	8082                	ret

0000000080000650 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000650:	7139                	addi	sp,sp,-64
    80000652:	fc22                	sd	s0,56(sp)
    80000654:	0080                	addi	s0,sp,64
    80000656:	fca43c23          	sd	a0,-40(s0)
    8000065a:	fcb43823          	sd	a1,-48(s0)
    8000065e:	87b2                	mv	a5,a2
    80000660:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    80000664:	fd843783          	ld	a5,-40(s0)
    80000668:	fef43423          	sd	a5,-24(s0)
  while(n-- > 0 && (*s++ = *t++) != 0)
    8000066c:	0001                	nop
    8000066e:	fcc42783          	lw	a5,-52(s0)
    80000672:	fff7871b          	addiw	a4,a5,-1
    80000676:	fce42623          	sw	a4,-52(s0)
    8000067a:	02f05e63          	blez	a5,800006b6 <strncpy+0x66>
    8000067e:	fd043703          	ld	a4,-48(s0)
    80000682:	00170793          	addi	a5,a4,1
    80000686:	fcf43823          	sd	a5,-48(s0)
    8000068a:	fd843783          	ld	a5,-40(s0)
    8000068e:	00178693          	addi	a3,a5,1
    80000692:	fcd43c23          	sd	a3,-40(s0)
    80000696:	00074703          	lbu	a4,0(a4)
    8000069a:	00e78023          	sb	a4,0(a5)
    8000069e:	0007c783          	lbu	a5,0(a5)
    800006a2:	f7f1                	bnez	a5,8000066e <strncpy+0x1e>
    ;
  while(n-- > 0)
    800006a4:	a809                	j	800006b6 <strncpy+0x66>
    *s++ = 0;
    800006a6:	fd843783          	ld	a5,-40(s0)
    800006aa:	00178713          	addi	a4,a5,1
    800006ae:	fce43c23          	sd	a4,-40(s0)
    800006b2:	00078023          	sb	zero,0(a5)
  while(n-- > 0)
    800006b6:	fcc42783          	lw	a5,-52(s0)
    800006ba:	fff7871b          	addiw	a4,a5,-1
    800006be:	fce42623          	sw	a4,-52(s0)
    800006c2:	fef042e3          	bgtz	a5,800006a6 <strncpy+0x56>
  return os;
    800006c6:	fe843783          	ld	a5,-24(s0)
}
    800006ca:	853e                	mv	a0,a5
    800006cc:	7462                	ld	s0,56(sp)
    800006ce:	6121                	addi	sp,sp,64
    800006d0:	8082                	ret

00000000800006d2 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800006d2:	7139                	addi	sp,sp,-64
    800006d4:	fc22                	sd	s0,56(sp)
    800006d6:	0080                	addi	s0,sp,64
    800006d8:	fca43c23          	sd	a0,-40(s0)
    800006dc:	fcb43823          	sd	a1,-48(s0)
    800006e0:	87b2                	mv	a5,a2
    800006e2:	fcf42623          	sw	a5,-52(s0)
  char *os;

  os = s;
    800006e6:	fd843783          	ld	a5,-40(s0)
    800006ea:	fef43423          	sd	a5,-24(s0)
  if(n <= 0)
    800006ee:	fcc42783          	lw	a5,-52(s0)
    800006f2:	2781                	sext.w	a5,a5
    800006f4:	00f04563          	bgtz	a5,800006fe <safestrcpy+0x2c>
    return os;
    800006f8:	fe843783          	ld	a5,-24(s0)
    800006fc:	a0a9                	j	80000746 <safestrcpy+0x74>
  while(--n > 0 && (*s++ = *t++) != 0)
    800006fe:	0001                	nop
    80000700:	fcc42783          	lw	a5,-52(s0)
    80000704:	37fd                	addiw	a5,a5,-1
    80000706:	fcf42623          	sw	a5,-52(s0)
    8000070a:	fcc42783          	lw	a5,-52(s0)
    8000070e:	2781                	sext.w	a5,a5
    80000710:	02f05563          	blez	a5,8000073a <safestrcpy+0x68>
    80000714:	fd043703          	ld	a4,-48(s0)
    80000718:	00170793          	addi	a5,a4,1
    8000071c:	fcf43823          	sd	a5,-48(s0)
    80000720:	fd843783          	ld	a5,-40(s0)
    80000724:	00178693          	addi	a3,a5,1
    80000728:	fcd43c23          	sd	a3,-40(s0)
    8000072c:	00074703          	lbu	a4,0(a4)
    80000730:	00e78023          	sb	a4,0(a5)
    80000734:	0007c783          	lbu	a5,0(a5)
    80000738:	f7e1                	bnez	a5,80000700 <safestrcpy+0x2e>
    ;
  *s = 0;
    8000073a:	fd843783          	ld	a5,-40(s0)
    8000073e:	00078023          	sb	zero,0(a5)
  return os;
    80000742:	fe843783          	ld	a5,-24(s0)
}
    80000746:	853e                	mv	a0,a5
    80000748:	7462                	ld	s0,56(sp)
    8000074a:	6121                	addi	sp,sp,64
    8000074c:	8082                	ret

000000008000074e <strlen>:

int
strlen(const char *s)
{
    8000074e:	7179                	addi	sp,sp,-48
    80000750:	f422                	sd	s0,40(sp)
    80000752:	1800                	addi	s0,sp,48
    80000754:	fca43c23          	sd	a0,-40(s0)
  int n;

  for(n = 0; s[n]; n++)
    80000758:	fe042623          	sw	zero,-20(s0)
    8000075c:	a031                	j	80000768 <strlen+0x1a>
    8000075e:	fec42783          	lw	a5,-20(s0)
    80000762:	2785                	addiw	a5,a5,1
    80000764:	fef42623          	sw	a5,-20(s0)
    80000768:	fec42783          	lw	a5,-20(s0)
    8000076c:	fd843703          	ld	a4,-40(s0)
    80000770:	97ba                	add	a5,a5,a4
    80000772:	0007c783          	lbu	a5,0(a5)
    80000776:	f7e5                	bnez	a5,8000075e <strlen+0x10>
    ;
  return n;
    80000778:	fec42783          	lw	a5,-20(s0)
}
    8000077c:	853e                	mv	a0,a5
    8000077e:	7422                	ld	s0,40(sp)
    80000780:	6145                	addi	sp,sp,48
    80000782:	8082                	ret

0000000080000784 <find_kernel_load_addr>:
#include <stdbool.h>

struct elfhdr* kernel_elfhdr;
struct proghdr* kernel_phdr;

uint64 find_kernel_load_addr(void) {
    80000784:	1101                	addi	sp,sp,-32
    80000786:	ec22                	sd	s0,24(sp)
    80000788:	1000                	addi	s0,sp,32
    // CSE 536: task 2.5.1
    kernel_elfhdr =  (struct elfhdr*)RAMDISK;
    8000078a:	00008797          	auipc	a5,0x8
    8000078e:	0ee78793          	addi	a5,a5,238 # 80008878 <kernel_elfhdr>
    80000792:	02100713          	li	a4,33
    80000796:	076a                	slli	a4,a4,0x1a
    80000798:	e398                	sd	a4,0(a5)
    kernel_phdr = (struct proghdr*)(RAMDISK + kernel_elfhdr->phoff + kernel_elfhdr->phentsize);
    8000079a:	00008797          	auipc	a5,0x8
    8000079e:	0de78793          	addi	a5,a5,222 # 80008878 <kernel_elfhdr>
    800007a2:	639c                	ld	a5,0(a5)
    800007a4:	739c                	ld	a5,32(a5)
    800007a6:	00008717          	auipc	a4,0x8
    800007aa:	0d270713          	addi	a4,a4,210 # 80008878 <kernel_elfhdr>
    800007ae:	6318                	ld	a4,0(a4)
    800007b0:	03675703          	lhu	a4,54(a4)
    800007b4:	973e                	add	a4,a4,a5
    800007b6:	02100793          	li	a5,33
    800007ba:	07ea                	slli	a5,a5,0x1a
    800007bc:	97ba                	add	a5,a5,a4
    800007be:	873e                	mv	a4,a5
    800007c0:	00008797          	auipc	a5,0x8
    800007c4:	0c078793          	addi	a5,a5,192 # 80008880 <kernel_phdr>
    800007c8:	e398                	sd	a4,0(a5)
    uint64 kernel_load_addr = kernel_phdr->vaddr; 
    800007ca:	00008797          	auipc	a5,0x8
    800007ce:	0b678793          	addi	a5,a5,182 # 80008880 <kernel_phdr>
    800007d2:	639c                	ld	a5,0(a5)
    800007d4:	6b9c                	ld	a5,16(a5)
    800007d6:	fef43423          	sd	a5,-24(s0)
    return kernel_load_addr;
    800007da:	fe843783          	ld	a5,-24(s0)
}
    800007de:	853e                	mv	a0,a5
    800007e0:	6462                	ld	s0,24(sp)
    800007e2:	6105                	addi	sp,sp,32
    800007e4:	8082                	ret

00000000800007e6 <find_kernel_size>:

uint64 find_kernel_size(void) {
    800007e6:	1101                	addi	sp,sp,-32
    800007e8:	ec22                	sd	s0,24(sp)
    800007ea:	1000                	addi	s0,sp,32
    // CSE 536: task 2.5.2
    kernel_elfhdr = (struct elfhdr*)RAMDISK;
    800007ec:	00008797          	auipc	a5,0x8
    800007f0:	08c78793          	addi	a5,a5,140 # 80008878 <kernel_elfhdr>
    800007f4:	02100713          	li	a4,33
    800007f8:	076a                	slli	a4,a4,0x1a
    800007fa:	e398                	sd	a4,0(a5)
    uint64 kernel_size = kernel_elfhdr->shoff + (kernel_elfhdr->shnum * kernel_elfhdr->shentsize);
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	07c78793          	addi	a5,a5,124 # 80008878 <kernel_elfhdr>
    80000804:	639c                	ld	a5,0(a5)
    80000806:	779c                	ld	a5,40(a5)
    80000808:	00008717          	auipc	a4,0x8
    8000080c:	07070713          	addi	a4,a4,112 # 80008878 <kernel_elfhdr>
    80000810:	6318                	ld	a4,0(a4)
    80000812:	03c75703          	lhu	a4,60(a4)
    80000816:	0007069b          	sext.w	a3,a4
    8000081a:	00008717          	auipc	a4,0x8
    8000081e:	05e70713          	addi	a4,a4,94 # 80008878 <kernel_elfhdr>
    80000822:	6318                	ld	a4,0(a4)
    80000824:	03a75703          	lhu	a4,58(a4)
    80000828:	2701                	sext.w	a4,a4
    8000082a:	02e6873b          	mulw	a4,a3,a4
    8000082e:	2701                	sext.w	a4,a4
    80000830:	97ba                	add	a5,a5,a4
    80000832:	fef43423          	sd	a5,-24(s0)
    return kernel_size;
    80000836:	fe843783          	ld	a5,-24(s0)
}
    8000083a:	853e                	mv	a0,a5
    8000083c:	6462                	ld	s0,24(sp)
    8000083e:	6105                	addi	sp,sp,32
    80000840:	8082                	ret

0000000080000842 <find_kernel_entry_addr>:

uint64 find_kernel_entry_addr(void) {
    80000842:	1101                	addi	sp,sp,-32
    80000844:	ec22                	sd	s0,24(sp)
    80000846:	1000                	addi	s0,sp,32
    // CSE 536: task 2.5.3
    uint64 kernel_entry_addr = kernel_elfhdr->entry;
    80000848:	00008797          	auipc	a5,0x8
    8000084c:	03078793          	addi	a5,a5,48 # 80008878 <kernel_elfhdr>
    80000850:	639c                	ld	a5,0(a5)
    80000852:	6f9c                	ld	a5,24(a5)
    80000854:	fef43423          	sd	a5,-24(s0)
    return kernel_entry_addr;
    80000858:	fe843783          	ld	a5,-24(s0)
    8000085c:	853e                	mv	a0,a5
    8000085e:	6462                	ld	s0,24(sp)
    80000860:	6105                	addi	sp,sp,32
    80000862:	8082                	ret
