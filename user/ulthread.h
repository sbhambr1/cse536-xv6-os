#ifndef __UTHREAD_H__
#define __UTHREAD_H__

#include <stdbool.h>

#define MAXULTHREADS 100

// create a data structure to hold the thread information
struct ulthread {
  int tid;
  int priority;
  enum ulthread_state state;
  uint64 ra;
  uint64 sp;
  uint64 args[4];
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

#endif