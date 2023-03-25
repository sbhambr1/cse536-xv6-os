#ifndef __UTHREAD_H__
#define __UTHREAD_H__

#include <stdbool.h>

#define MAXULTHREADS 100

// create a data structure to hold the thread information
struct ulthread {

  struct spinlock lock;

  int tid;
  int priority;
  enum ulthread_state state;
  void *chan;
  int killed;
  int xstate;

  struct ulthread *parent;

  uint64 stack;
  uint64 ctime = r_time();

  struct context context;
  uint64 args[6];
};

struct context {
  uint64 ra;
  uint64 sp;
  uint64 s0;
  uint64 s1;
  uint64 s2;
  uint64 s3;
  uint64 s4;
  uint64 s5;
  uint64 s6;
  uint64 s7;
  uint64 s8;
  uint64 s9;
  uint64 s10;
  uint64 s11;
};

struct spinlock {
  uint locked;       // Is the lock held?

  // For debugging:
  char *name;        // Name of lock.
  struct cpu *cpu;   // The cpu holding the lock.
};

static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
  return x;
}


enum ulthread_state {
  FREE,
  RUNNABLE,
  YIELD,
};

enum ulthread_scheduling_algorithm {
  ROUNDROBIN,   
  PRIORITY,     
  FCFS,         // first-come-first serve
};

#endif