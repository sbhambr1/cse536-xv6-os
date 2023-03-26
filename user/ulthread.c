/* CSE 536: User-Level Threading Library */
#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fcntl.h"
#include "user/user.h"
#include "user/ulthread.h"

/* Standard definitions */
#include <stdbool.h>
#include <stddef.h> 

enum ulthread_scheduling_algorithm scheduling_algorithm;

/* Get thread ID */
int get_current_tid(void) {
    struct  ulthread *t;
    return t->tid;
}

/* Thread initialization */
void ulthread_init(int schedalgo) {

    struct ulthread *t;
    // TODO: Get the current kernel thread and switch to the user-level thread

    ulthread_context_switch(&t->context, &t->parent->context);
    scheduling_algorithm = schedalgo;
}

/* Thread creation */
bool ulthread_create(uint64 start, uint64 stack, uint64 args[], int priority) {
    /* Please add thread-id instead of '0' here. */
    printf("[*] ultcreate(tid: %d, ra: %p, sp: %p)\n", get_current_tid(), start, stack);

    struct ulthread *t;
    t->context.ra = start;
    t->context.sp = stack;
    for (int i = 0; i < 6; i++) {
        t->args[i] = args[i];
    }
    t->priority = priority;
    
    //TODO: save the context of the current thread
    ulthread_context_switch(&t->context, &t->parent->context);

    if(t->state == RUNNABLE){
        return true;        
    }

    return false;
}

/* Thread scheduler */
void ulthread_schedule(void) {

    struct ulthread *t;

    acqure(&t->lock);

    for(;;){
        if(scheduling_algorithm == 0){
            // Round Robin
            for(int i = 0; i < MAXULTHREADS; i++){
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
            for(int i = 0; i < MAXULTHREADS; i++){
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
            for(int i = 0; i < MAXULTHREADS; i++){
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

    release(&t->lock);

    /* Add this statement to denote which thread-id is being scheduled next */
    printf("[*] ultschedule (next tid: %d)\n", get_current_tid());

}

/* Yield CPU time to some other thread. */
void ulthread_yield(void) {

    struct ulthread *t;
    acqure(&t->lock);
    t->state = YIELD;
    release(&t->lock);

    /* Please add thread-id instead of '0' here. */
    printf("[*] ultyield(tid: %d)\n", get_current_tid);
}

/* Destroy thread */
void ulthread_destroy(void) {}

/* Get thread time */
