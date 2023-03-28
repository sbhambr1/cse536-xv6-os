/* CSE 536: User-Level Threading Library */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "user/ulthread.h"

/* Standard definitions */
#include <stdbool.h>
#include <stddef.h> 

struct ulthread ulthread[MAXULTHREADS];

enum ulthread_scheduling_algorithm scheduling_algorithm;

/* Get thread ID */
int get_current_tid(void) {
    struct  ulthread *t;
    return t->tid;
}

/* Thread initialization */
void ulthread_init(int schedalgo) {

    struct ulthread *t;
    // Initialize the thread data structure and set the state to FREE and initialize the ids from 0 to MAXULTHREADS
    // Mark the first thread as the scheduler thread and set its state to RUNNABLE
    for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
        t->tid = t - ulthread;
        t->state = FREE;
    }
    ulthread[0].state = RUNNABLE;

    scheduling_algorithm = schedalgo;
}

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {

    struct ulthread *t;
    t->context.ra = start;
    t->context.sp = stack;
    for (int i = 0; i < 6; i++) {
        t->args[i] = args[i];
    }
    t->priority = priority;
    memset(&t->context, 0, sizeof(t->context));

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", get_current_tid(), start, stack);

    if(t->state == RUNNABLE){
        return true;        
    }

    return false;
}

/* Thread scheduler */
void ulthread_schedule(void) {

    struct ulthread *t;

    for(;;){
        if(scheduling_algorithm == 0){
            // Round Robin
            for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
                struct ulthread *newt;
                if(t->state == RUNNABLE){
                    newt = t;
                    ulthread_context_switch(&newt->context, &t->context);
                }
                if(t->state == YIELD){
                    t->state = RUNNABLE;
                }
            }
        }
        else if(scheduling_algorithm == 1){
            // Priority
            struct ulthread *newt;
            struct ulthread *highest;
            //find the highest priority thread
            for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
                if(newt->priority < highest->priority && newt->state == RUNNABLE){
                    highest = newt;
                }
                ulthread_context_switch(&highest->context, &t->context);
                if(t->state == YIELD){
                    t->state = RUNNABLE;
                }
            }
        }
        else if(scheduling_algorithm == 2){
            // FCFS
            for(t = ulthread; t < &ulthread[MAXULTHREADS]; t++){
                struct ulthread *newt;
                if(t->ctime < newt->ctime && t->state == RUNNABLE){
                    newt = t;
                    ulthread_context_switch(&newt->context, &t->context);
                }
                if(t->state == YIELD){
                    t->state = RUNNABLE;
                }
            }
        }
    }

    /* Add this statement to denote which thread-id is being scheduled next */
    printf("[*] ultschedule (next tid: %d)\n", get_current_tid());

}

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {

    struct ulthread *t;
    t->state = YIELD;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid);
}

/* Destroy thread */
void ulthread_destroy(void) {

    struct ulthread *t;
    t->state = FREE;

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultdestroy(tid: %d)\n", get_current_tid);
}
