#ifndef __UTHREAD_H__
#define __UTHREAD_H__

#include <stdbool.h>

#define MAXULTHREADS 100

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

// create a data structure to hold the thread information
struct ulthread {

  int tid;
  int priority;
  enum ulthread_state state;
  struct ulthread *parent;
  uint64 stack;
  uint64 ctime;
  struct context context;
  uint64 args[6];
};

// machine-mode cycle counter
static inline uint64
ctime()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
  return x;
}

#endif